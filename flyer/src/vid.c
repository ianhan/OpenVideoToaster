/*********************************************************************\
*
* $Vid.c - Video handling functions$
*
* $Id: vid.c,v 1.16 1997/02/06 18:17:41 Holt Exp Holt $
*
* $Log: vid.c,v $
*Revision 1.16  1997/02/06  18:17:41  Holt
*turued off hq6
*
*Revision 1.15  1996/12/09  17:45:18  Holt
*turned off debugging.
*
*Revision 1.14  1996/11/12  15:34:09  Holt
**** empty log message ***
*
*Revision 1.13  1996/08/13  15:04:12  Holt
*Added support for HQ6
*
*Revision 1.12  1995/11/21  12:24:52  Flick
*LoadVid() is now absent on shipping versions (saves space)
*
*Revision 1.11  1995/11/17  12:45:52  Flick
*Fixed DoRecMachine to allow recording from channel 1 (altho it's always SN)
*
*Revision 1.10  1995/11/16  11:43:53  Flick
*Replaced 2 accesses to SharedCtrl struct w/ standard fn ExtraErrInfo()
*Implemented timeout mechanism to prevent matte blk from hanging "play" when
*clip is corrupt and it stops w/ an emergency flush.
*
*Revision 1.9  1995/10/26  17:57:04  Flick
*Added better support of FIELD stillmode (audio now works, can specify which field)
*
*Revision 1.8  1995/10/10  01:43:07  Flick
*PlayVidMachine now honors HostAbort input for aborting
*Added tie-in to SharedCtrl structure during recording -- lets host watch/count dropped frames
*
*Revision 1.7  1995/09/07  09:34:45  Flick
*(Release 4.06)
*Swapped A/B record channels back again, so A is aggressive (1 write).
*B is fall-back, takes 2 writes (This helps Seagates not drop frames in HQ5)
*
*Revision 1.6  1995/09/01  13:58:58  Flick
*NoSync LED now lites for 1 second each time we get funky video IRQ's (were
*invisible before).  When playing video clips, now checks for a bad header
*before checking VTASC version (so better error is reported).
*Fixed audio bug in engines: if audio was to stay enabled, then a command
*came along (besides AUDCHG) that had audchan=0, audio would stay enabled forever!
*
*Revision 1.5  1995/08/28  10:01:07  Flick
*Added VideoReset() function for panic situations
*Added ClipHeaders Grade fld & logic (to recognize HQ5 and beyond clips)
*Reinstated code to wait for stable video IRQ's before going into play/rec modes
*
*Revision 1.4  1995/08/21  12:09:38  Flick
*Last minute fix for 4.05, flush was holding for matte buffer on seq abort!
*
*Revision 1.3  1995/08/15  17:22:09  Flick
*First release (4.05)
*Big changes to Engine system (formalized use, semaphored resource, more
*efficient FIFO buffering logic -- callers can stack data in buffer now!)
*
*Revision 1.2  1995/05/04  17:08:32  Flick
*Phx/Flyer duality improved, some stub code moved into AmiShar.c
*
*Revision 1.1  1995/05/03  10:47:21  Flick
*Automated prototypes, and reduced includes when possible
*
*Revision 1.0  1995/05/02  11:06:13  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	12/17/92		Charles	Created
*	03/07/94		Marty		Overhauled
*	02/06/95		Marty		Ported to C
\*********************************************************************/

#define	LOCALDEBUG		0			// Debugging switch for this module only

#include <Types.h>
#include <Flyer.h>
#include <Exec.h>
#include <Errors.h>
#include <Vid.h>
#include <Chips.h>
#include <Heads.h>
#include <DMA.h>
#include <Audio.h>
#include <Ser.h>
#include <Lists.h>
#include <SCSI.h>
#include <Debug.h>

#include <string.h>			// SAS include

#include <proto.h>
#include <Vid.ps>

#define	OPSENG	(1+1)		/* For debugging only */

extern const ULONG SRAMbase;		// Base of shared SRAM memory map
extern UBYTE	BarType;
extern UBYTE	VTASCversion;
extern UBYTE *sermem;
extern ULONG	Debugging;
extern TimerRouter *TR_serchip;				// Pointer to the base of the TimerRouter
extern _3PORT *_3Port;							// Base of 3Port
extern BOOL		FullyUp;
extern ULONG	GlobalOptions;
extern UBYTE	ProhibitSCSIdirect;

extern struct FBUF Abufctrl[NUMAUDCHANS][NUMAUDBUFS];
#define	baseof_Abufctrl	LOAUDMACHNUM
extern struct AUDIOMACH	audmach[NUMAUDCHANS];
#define	baseof_audmach		1
extern struct FRAMEHDR	(*Ahdrs)[NUMAUDCHANS];
#define	baseof_Ahdrs	LOAUDMACHNUM
extern struct SMPTEbuff	SMPTEa[2];
extern struct Semaphore	SCSIsema[NUMSCSICHANS];
extern UBYTE	RxAfill;
extern UBYTE	SerPortDevices[2];
extern UBYTE	SerPortMakes[2];
extern UWORD	PlaySkewA,PlaySkewB,RecSkew;
extern UWORD	PlayOffsetA,PlayOffsetB;
extern UWORD	RecOffsetA,RecOffsetB;
extern UWORD	PedestalA,PedestalB;
extern UBYTE	PwrUpDIPs;
extern BOOL		Sequencing;

#define	VIDEOTASKS	0		/* Run video in interrupts */
#define	FIELDTASKS	0		/* Run TOF,MOF in interrupts */


#define	NOISEWAIT 1000			// .5s for noise to settle on P/R transitions
#define	SYNCTIMEOUT 10000		// 5s time out if bad noise or no sync


/* DMA Channel Conversions */
#define	VID2DMA(x)		(x+VIDDMACHAN0)

static const UBYTE OLDBLACKSEQ[16] = {
	0xC5,0x80,0x12,0x21,0x58,0x04,0x00,0x00,		// 0000
	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00		// 00BD
};
static const UBYTE NEWBLACKSEQ[16] = {
	0xC5,0x00,0x00,0x00,0x00,0x00,0x00,0x00,		// 0000
	0xA0,0x44,0x08,0xEE,0x00,0x00,0x00,0x00		// 00BD
};
//static const UBYTE BLANKSEQ[16] = {
//	0xBA,0x00,0x25,0x42,0x10,0xA8,0x0B,0x00,		// 0000
//	0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00		// 00BD
//};


#define	MODE_STD_NOMSIZE	0x70
#define	MODE_STD_MAXSIZE	0x7A

#define	MODE_HQ5_NOMSIZE	0x92
#define	MODE_HQ5_MAXSIZE	0x9C

//#define	MODE_HQ6_NOMSIZE	0xB2
//#define	MODE_HQ6_MAXSIZE	0xBC
#define	MODE_HQ6_NOMSIZE		0xBF-0x0a		//0xB2
#define	MODE_HQ6_MAXSIZE		0xBF		   	//0xBC


/* Clip file headers for Video/Audio */
struct FRAMEHDR (*Vhdrs)[NUMVIDCHANS][NUMVIDBUFS] = (struct FRAMEHDR (*)[][])VHDRSBASE;
#define	baseof_Vhdrs	LOVIDMACHNUM

/* Scratch headers */
union ANYHDR (*mischdrs)[NUMVIDCHANS+NUMAUDCHANS] = (union ANYHDR (*)[])MISCHDRSBASE;
	
/* Audio/Video Play & Rec state machine */
struct MACHINE AVmachine[NUMVIDCHANS+NUMAUDCHANS];
#define	baseof_AVmachine	LOVIDMACHNUM

/* Audio/Video engine */
struct ENGINE Engine[NUMVIDCHANS+NUMAUDCHANS];
#define	baseof_Engine	LOVIDMACHNUM
	
///* LED bar graphs -- TESTING ONLY */
//UBYTE	BufsFull[NUMVIDCHANS+NUMAUDCHANS];
//#define	baseof_BufsFull	LOVIDMACHNUM

/* Control structures for each channel's video buffers */
struct FBUF Vbufctrl[NUMVIDCHANS][NUMVIDBUFS];
#define	baseof_Vbufctrl	LOVIDMACHNUM

/* Custom FIR coefficients (Pre/Post) */
struct FIRSET CustomFIRcoefs[2];

struct VTASC_CHANNEL *VTASC_serchips =
	(struct VTASC_CHANNEL *)VID0BASE; // Pointer to base of Video chips

//	struct FIRSET FIRcoefstore;

struct PlayArgs NullAudioArgs;			// All audio args/flags = 0

ULONG	FrameClock;
UBYTE	CurrentField;
UBYTE	LastField;
UBYTE	VideoMode;
BOOL	VidPaused;				// Recording is paused
UBYTE	VidGrade = GRADE_STD;

UBYTE	Lateness[NUMVIDCHANS];

/* Indexing stuff */
UWORD	NdxBlks;					// Index blocks stored
UWORD	NdxEnt;					// Index entry in current block
UWORD	NdxTotal;				// Index entry
ULONG	Back15Ptrs[15];		// Backward ptrs 15/second
UWORD	NdxCtr;					// Frame counter (MOD 16)
ULONG	*NdxTable = (ULONG *)INDEXBASE;	// Blk from table


/* Video preferences */
/* A set for each compression version */
struct PREFS prefs[2];
#define	baseof_prefs	1		// Bias when using this array
	
UBYTE	LockVidRamCntr;
UBYTE	LockVidRamMode;
//BOOL	GettingIRQ6;
UBYTE	KickOffFld;
UWORD	RecKey;
UBYTE	MinTols[2];
UBYTE	MaxTols[2];
UBYTE	MinAlgo,MaxAlgo;
UBYTE	SpecialChoices;
UBYTE	SpecialToggle[2];

BOOL	Arunning;				// A (de)compressor returned first IRQ
BOOL	Brunning;

BOOL	NoAdjust = FALSE;

//ULONG	StartClkIndex;
//ULONG	StartClkTable[100];
//ULONG	PauseClkIndex;
//ULONG	PauseClkTable[100];

UBYTE	WhichIRQ;
ULONG	FieldClock;
UBYTE	DoneLine[2];
BOOL	SyncNoise;
UBYTE	SyncProblem;			// Retriggerable one-shot counter for LED
BOOL	NoSyncLED;
BOOL	NoSyncLast;
BOOL	DroppedFields;			// Fields missed while recording
UBYTE	RecBiasLine;
BOOL	HighSpeedVTASC;
BOOL	VeryHSVTASC;			//HQ-X
UBYTE	VTLINE_A,VTLINE_B;
UBYTE	gl_FldOffset;

struct TaskCtrl *FieldTask,*VideoDriver0,*VideoDriver1;


#if FORCEVID
UWORD	ForceRndFreq,ForceRndBits,ForceRndSeed;
#endif


/*
 *  VideoReset - Panic reset of video internals
 */
void VideoReset(ULONG flags)
{
	ULONG	i;

//	DBUG(print(DB_VIDEO,"RESET!\n");)

	if (flags & 1)		// Serious panic?
	{
		for (i=0 ; i<NUMVIDCHANS ; i++)
			CleanupAudBuffers(i+LOVIDMACHNUM,PLAY);		// Spiffy up buffers & pointers

		BlackOut();
	}
}


/*
 *	VidParam - Set Video Compression parameters (command)
 */
UBYTE VidParam(UBYTE mintol, UBYTE maxtol, UBYTE freq, UBYTE vmaxlen, UBYTE vlength,
	UBYTE firset, UBYTE special)
{
	UBYTE	temp;
	UWORD	i;
	struct	PREFS	*pp;
	UBYTE	error = ERR_OKAY;

	DBUG(print(DB_TEST,"Min/Max=%l/%l freq=%l len=%l\n",
		mintol,maxtol,freq,vlength);)

	SpecialChoices = special;

	/* If min/max are inverted, correct them */
	if (mintol > maxtol)
	{
		temp = mintol;
		mintol	= maxtol;
		maxtol	= temp;
	}

	for (i=VTASC_OLDD2;i<=VTASC_NEWD2;i++)
	{
		pp = &prefs[i-baseof_prefs];
		pp->p_tol	= mintol & 0x3;
		pp->p_bits	= mintol & 0x3;
		if (freq != 0)
			pp->p_freq	= freq;			// 0 = keep same

		pp->p_seed	= 1;
		if (vlength != 0)
		{
			pp->p_len = vlength;			// 0 = keep same
			pp->p_maxlen = vmaxlen;

//			if (vlength == VID_SIZE_1)
//				pp->p_maxlen = 0x9F;			// Super grade
//			else
//				pp->p_maxlen = 0x7A;			// Std grade

		}

		pp->p_mintol = mintol;
		pp->p_maxtol = maxtol;
		pp->p_firset = firset;

		if ((VideoMode == VM_RECORD) && (i == VTASCversion))
		{
			PreloadEngPrefs(0,i);					// Use immediately!
			PreloadEngPrefs(1,i);					// Use immediately!
		}
	}

	if (vmaxlen > TURBO_THRESHOLD)		// User enabled high-speed VTASC?
	{
		if (vmaxlen > SUPER_THRESHOLD)
		{	
			DBUG(print(DB_ALWAYS," \n SUPER_THRESHOLD\n ");)
			VidGrade = GRADE_HQ6;
			SpeedUpChips(3);
		}
		else
		{
			DBUG(print(DB_ALWAYS," \n TRUBO_THRESHOLD\n ");)
			VidGrade = GRADE_HQ5;
			SpeedUpChips(2);
		}
	}
	else
	{
		DBUG(print(DB_ALWAYS," \n STANDARD_THRESHOLD\n ");)
		VidGrade = GRADE_STD;
		SpeedUpChips(1);

	}
	return(error);
}


/*
 * SpeedUpChips - Set M/Pcoder clks to faster rates for mode 1 video
 */
void SpeedUpChips(int flag)
{
	ULONG	Mspd,Pspd,Dspd;

	DBUG(print(DB_ALWAYS," \nSwitching to mode %l \n ",flag);)
	if (VideoMode == VM_RECORD)				// Record settings.
	{
		switch(flag)	{
		case	(1):
			Mspd = 80000000;	// Std Mode
			Pspd = 49000000;
			SetClockFreq(0,79100000);
			break;
		case	(2):
			Mspd = 84000000;	// HQ5 Mode
			Pspd = 49000000;
			SetClockFreq(0,79100000);
			break;
		case	(3):

//			Mspd = 89900000;	// HQ6 Mode
			Mspd = 91900000;	// HQ6 Mode
//			Pspd = 69500000;
			Pspd = 71500000;
			SetClockFreq(0,85100000);

		break;
		}	
	}
	else	//Playback
	{
		switch(flag)	{
		case	(1):
			Mspd = 81000000;  // Std Mode
			Pspd = 50000000;
			SetClockFreq(0,79100000);
			break;
		case	(2):
			Mspd = 85000000;  //	HQ5 Mode
			Pspd = 50000000;
			SetClockFreq(0,79100000);
			break;
		case	(3):
			Mspd = 94000000;  // HQ6 Mode
			Pspd = 75900000;
			SetClockFreq(0,85100000);
			break;

		}		
	}

	DBUG(print(DB_ALWAYS,"SpeedUp: fl=%d M=%l P=%l\n",flag,Mspd,Pspd);)
	
	//SetClockFreq(0,Dspd);
	SetClockFreq(2,Mspd);
	SetClockFreq(3,Pspd);
}


/*
 *	LoadVid - Load video data into output buffer
 */
void LoadVid(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		addr;
		ULONG		length;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
#if DEBUG
	struct FRAMEHDR	*fhp;
	struct FBUF			*bfp;
	struct FLDINFO		*fip;
	APTR	from;
	ULONG	to;
	UBYTE	buf;
	UBYTE	vchan;
	ULONG	blks,i;

	vchan = 0;

	buf = GetNextVideoBuffer(vchan,TRUE);
	from = (APTR)(cmdptr->addr+SRAMbase);		// Get address of data
	to = Vbufctrl[vchan-baseof_Vbufctrl][buf].bf_addr;

	blks = (cmdptr->length+511) / 512;

	DBUG(print(DB_OPS,"LoadVid!\n");)

	/* Move data into buffer in DRAM */
	CpuXferMemWait(from,to,blks,READ);

	/* Make counterfeit frame header to use */
	fhp = &(*Vhdrs)[vchan-baseof_Vhdrs][buf];
	fhp->fh_id = ID_CFRM;
	fhp->fh_vidflag = TRUE;
	fhp->fh_audchans = 0;
	fhp->fh_audlen	= 0;					// No audio please

	bfp = &Vbufctrl[vchan-baseof_Vbufctrl][buf];
	bfp->bf_empty = FALSE;				// Fake data is here
	bfp->bf_flags |= BFF_OUTSIDE;		// Points outside buffer area

//	Engine[vchan-baseof_Engine].e_bufsfull++;
	((struct ENGINE *)GetEngine(vchan))->e_bufsfull++;

//	BufsFull[vchan-baseof_BufsFull]++;

	for (i=1;i<=4;i++)
	{
		fip = &fhp->fh_fld[i-baseof_fhfld];

		if (i == 1)
		{
			fip->fi_vloc	= HEADERLEN;
			fip->fi_vlen	= VBUFSIZE;
		}
		else
		{
			fip->fi_vloc	= HEADERLEN+MATTEDRAM-to;	// Point to matte area
			fip->fi_vlen	= MATTEBLKS;
		}
		fip->fi_tol	= 0;
		fip->fi_rndsz	= 0;
		fip->fi_rndfrq	= 0;
		fip->fi_seed	= 0;
	}

	/* Advance to next frame */
	EngineCommand(vchan,AVCMD_ADVFRM,0,1,&NullAudioArgs,0);
#else
	cmdptr->error = ERR_BADCOMMAND;			// Not supported if debugging is off
#endif
}


/*
 *	 DfltVidPrefs - Set video chip default preferences
 */
void DfltVidPrefs(void)
{
	register struct PREFS *pp;

	pp = &prefs[VTASC_OLDD2-baseof_prefs];
	pp->p_tol		= 1;				// 1 bit tolerance
	pp->p_bits		= pp->p_tol;	// same
	pp->p_freq		= 13;				// Looks nice
	pp->p_seed		= 0;				// Arbitrary
	pp->p_len		= MODE_STD_NOMSIZE;			// Desired video data length
	pp->p_maxlen	= MODE_STD_MAXSIZE;			// Maximum video data length
	pp->p_mintol	= 0;
	pp->p_maxtol	= 3;
	pp->p_firset	= 3;				// 50% precomp

	pp = &prefs[VTASC_NEWD2-baseof_prefs];
	pp->p_tol		= 0;				// 0 bit tolerance
	pp->p_bits		= pp->p_tol;	// same
	pp->p_freq		= 122;			// Looks nicer
	pp->p_seed		= 0;				// Arbitrary
	pp->p_len		= MODE_STD_NOMSIZE;			// Desired video data length
	pp->p_maxlen	= MODE_STD_MAXSIZE;			// Maximum video data length
	pp->p_mintol	= 0;				// D2,0
	pp->p_maxtol	= 6;				// SN,2
	pp->p_firset	= 2;				// 33% precomp

	VidGrade = GRADE_STD;

//	if (DIP_HighSpeed & PwrUpDIPs)
	if (HighSpeedVTASC)
	{
		pp->p_len		= MODE_HQ5_NOMSIZE;			// Desired video data length
		pp->p_maxlen	= MODE_HQ5_MAXSIZE;			// Maximum video data length

		VidGrade = GRADE_HQ5;
	}
	if (VeryHSVTASC)
	{	
		pp->p_len		= MODE_HQ6_NOMSIZE;
		pp->p_maxlen	= MODE_HQ6_MAXSIZE;
		VidGrade = GRADE_HQ6;
	}


}


/*
 *	 GetLegalVidSize - Return legal video field sizes (i.e. for compression)
 */
UWORD GetLegalVidSize(void)
{
// This would return the last used compression mode, say while recording
//	return(prefs[VTASC_NEWD2-baseof_prefs].p_len);


	if (VeryHSVTASC)
	{
		return(MODE_HQ6_NOMSIZE);
	}
	else
	{

		if (HighSpeedVTASC)
			return(MODE_HQ5_NOMSIZE);
		else
			return(MODE_STD_NOMSIZE);
	}
}


/*
 *  StartVid - Start video (de)compression
 */
static void StartVid(	struct ENGINE *ep,
								BOOL	read,
								BOOL	softstart)
{
	UBYTE		vchan;
	register struct VTASC_CHANNEL *vtc;
	struct FBUF			*bfp;
	UBYTE	zero = 0;
	UBYTE	dmachan;
	UBYTE	VTver;
	UBYTE	enbl;
#if FORCEVID
	UBYTE	temp;
#endif

	vchan = ep->e_engnum;
	vtc = &VTASC_serchips[vchan];

	dmachan = VID2DMA(vchan);

	VTver = VTASCversion;

	EndDma(dmachan);					// Reset DMA

	if (VTver == VTASC_NEWD2)	// New D2/SN VTASC
	{
		/* Disable compressor */
		vtc->ENABLE = zero;
		vtc->RNDBIT	= zero;

		/* Set random number frequency */
#if FORCEVID
		temp = (ForceRndFreq == 0xFF)?ep->e_rndfrq:ForceRndFreq;

		DBUG(
			if (vchan == 0)
				print(DB_HEADS,"%w",temp);
		)

		vtc->RNDSEED	= temp;
		vtc->ENABLE		= VTEF_LoadFreq;			// Load freq
#else
		vtc->RNDSEED	= ep->e_rndfrq;
		vtc->ENABLE		= VTEF_LoadFreq;			// Load freq
#endif


		/* Set random number seed */
#if FORCEVID
		temp = (ForceRndSeed == 0xFF)?ep->e_rndseed:ForceRndSeed;

		DBUG(
			if (vchan == 0)
				print(DB_CLOCK,"%w",temp);
		)

		vtc->RNDSEED	= temp;
#else
		vtc->RNDSEED	= ep->e_rndseed;
#endif


		/* Calculate random number enable value */
#if FORCEVID
		temp = (ForceRndBits == 0xFF)?ep->e_rndbit:ForceRndBits;

		DBUG(
			if (vchan == 0)
				printchar(DB_TEST,temp+'0');
		)

		vtc->RNDBIT		= 0x80 + ((temp & 0x3) << 4);
#else
		vtc->RNDBIT		= 0x80 + ((ep->e_rndbit & 0x3) << 4);
#endif

		/* Clear and reenable compressor */
		vtc->ENABLE = VTEF_ClrErrors | VTEF_ClrFIFO;

		if (ep->e_algo != 0)
		{
			enbl = VTEF_Enable + VTEF_SubNyqMode + ep->e_tol;		// SN mode
		}
		else
			enbl = VTEF_Enable + ep->e_tol;		// D2 mode

		if (softstart)
		{
			enbl += VTEF_SoftStart;					// Set soft-start bit
			DBUG(printchar(DB_ALARMS,'$');)
		}

		vtc->ENABLE = enbl;
		bfp = &Vbufctrl[vchan-baseof_Vbufctrl][ep->e_curbuf];
		if ((BFF_OUTSIDE & bfp->bf_flags) || (bfp->bf_ptr < bfp->bf_lastaddr))
		{
			StartDma(dmachan,bfp->bf_ptr,bfp->bf_lastaddr - bfp->bf_ptr,read);
		}
		else
		{
			DBUG(print(DB_ALWAYS,"SKIP!");)
		}
	}
	else									// Old D2 VTASC
	{
		/* Disable compressor */
		vtc->ENABLE = zero;
		vtc->RNDBIT = zero;

		/* Set random number parameters */
		vtc->RNDSEED = ep->e_rndseed;

		/* Calculate random number enable value */
		vtc->RNDBIT = (ep->e_rndbit * 16) + ep->e_rndfrq + 0x80;

		/* Clear and reenable compressor */
		vtc->ENABLE = VTEF_ClrErrors | VTEF_ClrFIFO;
		vtc->ENABLE = VTEF_Enable + ep->e_tol;
		bfp = &Vbufctrl[vchan-baseof_Vbufctrl][ep->e_curbuf];
		if ((BFF_OUTSIDE & bfp->bf_flags) || (bfp->bf_ptr < bfp->bf_lastaddr))
		{
			StartDma(dmachan,bfp->bf_ptr,bfp->bf_lastaddr - bfp->bf_ptr,read);
		}
	}

//	DBUG(
//		if (vchan == 1)
//			printchar(DB_TOLER,ep->e_algo*4 + ep->e_tol+'0');
//		else
//		{
//			printchar(DB_VIDB,ep->e_algo*4 + ep->e_tol+'0');
////			if (!softstart)
////				DBUG(SetLEDs(0x02);)
//		}
//	)

}


/* 
 *  NewSeed - Generate New random number seed
 */
static void NewSeed(struct ENGINE *ep)
{
	if (++ep->e_rndseed == 0xFF)
		ep->e_rndseed = 0;
}


/*
 * FirstField - Do video stuff before the very first video field
 */
static void FirstField(UBYTE eng)
{
	struct ENGINE		*ep;
	UBYTE	err;

//	ep = &Engine[eng-baseof_Engine];							// Get pointer to engine
	ep = GetEngine(eng);

	if (ep->e_dir == PLAY)
	{
		err = PickupFieldParams(ep);
		if (err != 0)
		{
			DBUG(print(DB_ALARMS,"PFP:%b\n",err);)
		}
	}

	/* Start video soon */
	ep->e_flags |= EFLG_KICKME;
	DBUG(print(DB_VIDEO,"KICK!");)
}


/*
 * DoEngine - Do audio and/or video stuff
 */
BOOL DoEngine(	struct ENGINE *ep,
					UBYTE	howlate)
{
	struct FRAMEHDR	*fhp;
	struct FBUF			*bfp;
	struct FLDINFO		*fip;
	struct SMPTEbuff	*sbp;
	BYTEBITS	vidbits;
	UBYTE	eng, nextbuf, offset;
	UBYTE	fld;				// TEST ONLY
	BOOL	dosignal, newframe, mtflag, softstart, bumpSN, newcmd;
	UWORD	dmaptr;
//	UBYTE	zero = 0;

	eng = ep->e_engnum;

	dosignal = FALSE;

	/* Soft-start compressors? */
	if ((howlate == 1) || (howlate == 2))
		softstart = TRUE;
	else
		softstart = FALSE;

	/* Bump into SN mode to get easier compression? */
	if (howlate >= 2)
		bumpSN = TRUE;
	else
		bumpSN = FALSE;

	DBUG(printchar(DB_VIDEO,eng+'0');)

	if (!(EFLG_ACTIVE & ep->e_flags))
	{
//		DBUG(print(DB_ALWAYS,"Idle!");)
		return(dosignal);
	}

	if (eng <= HIVIDMACHNUM)
	{
		EndDma(VID2DMA(eng));			// Stop old DMA

		vidbits = SerRead(&VTASC_serchips[eng].STATUS);

		if (VTST_OVRUN & vidbits)
		{
//			DBUG(print(DB_ALWAYS,"OVRN!");)
			DBUG(printchar(DB_ALARMS,'o');)
		}
	}

	/* Grind to a halt? */
	if (EFLG_BREAK & ep->e_flags)
	{
		DBUG(print(DB_ALWAYS,"STOP!");)

		DBUG(print(DB_VIDEO2,"Ebrk");)

		if (eng <= HIVIDMACHNUM)
			InitCompressor(eng);				// Disable (de)compressor

		ep->e_flags &= ~EFLG_ACTIVE;
		return dosignal;						// Return without starting more
	}

	if (ep->e_dir == PLAY)
	{
		ep->e_field++;
		ep->e_fldctr++;						// Another field completed

		/* Skip a field to get back in sync? */
		if (ep->e_adjust && (!NoAdjust))
		{
			ep->e_field++;
			ep->e_adjust = FALSE;
		}

		if (ep->e_field > FIELDSPERFRAME)				// Starting new color frame?
		{

//			DBUG(printchar(DB_VIDEO,'|');)

			ep->e_field -= FIELDSPERFRAME;
			ep->e_frmctr++;

			ep->e_wasaudchan = ep->e_audchan;

			/* Time to auto-switch to a new command? */
			if (GetEngEvent(ep,FieldClock+4))
			{
				newcmd = TRUE;
				DBUG(
//					print(DB_CLOCK,"(%b)@%l ",ep->e_cmd,FieldClock);
					print(DB_CLOCK,"(%b,%l) ",ep->e_cmd,ep->e_duration);
					if (eng==0)
					{
						print(DB_OPS,"+%d,%d,%d",eng,ep->e_cmd,ep->e_audchan);
//						print(DB_OPS,"+%l",ep->e_duration);
//						print(DB_OPS,"+%b",ep->e_cmd);
					}
				)

//				/* DEBUGGING - TAKE THIS OUT! */
//				if (ep->e_cmd == AVCMD_PLAY)
//				{
//					if (StartClkIndex<100)
//						StartClkTable[StartClkIndex++] = FieldClock;
//				}

//				switch (ep->e_cmd)
//				{
//				case AVCMD_PLAY:
//					if (ep->e_audchan != 0)
//						AudioEnable(ep->e_audchan);
//					break;
//				}
			}
			else
				newcmd = FALSE;

//			if (EFLG_AUDCHG & ep->e_flags)
//			{
//				if (ep->e_audchan == 0)
//					AudioDisable(ep->e_wasaudchan);
//				else
//					AudioEnable(ep->e_audchan);
//
//				ep->e_flags &= ~EFLG_AUDCHG;
//			}
//			ep->e_wasaudchan = ep->e_audchan;


//~~~~~~~~~~ Commands that come along w/o audio must shut down audio from prev command ~~~~
			if (newcmd && (ep->e_wasaudchan) && (ep->e_audenbl) && (ep->e_audchan==0))
			{
				DBUG(print(DB_OPS,"4ya");)
				ep->e_audenbl = FALSE;
				AudioDisable(ep->e_wasaudchan);
			}

//------------------------
			// Automatically disable old audio channel if:
			// A play/flush and play are butted together, the channels change,
			// but there's no STILL between them?  Need a better mechanism in 4.1!!!
//			if ((ep->e_wasaudchan != ep->e_audchan) && (ep->e_cmd == AVCMD_PLAY))
			if (ep->e_wasaudchan != ep->e_audchan)
			{
				DBUG(printchar(DB_OPS,'@');)
				if ((EFLG_AUDMUTE & ep->e_flags) && (ep->e_wasaudchan) && (ep->e_audenbl))
				{
					ep->e_audenbl = FALSE;
					AudioDisable(ep->e_wasaudchan);
				}
			}
//------------------------


			/* Should we loop current frame or move on? */
			switch (ep->e_cmd)
			{
				case AVCMD_STILL:
				case AVCMD_COLOR:
				case AVCMD_2FIELD:
				case AVCMD_FIELD:
					if (EFLG_AUDMUTE & ep->e_flags)
					{
						// Be sure audio channel is turned off if necessary
						if ((ep->e_audchan) && (ep->e_audenbl))
						{
							ep->e_audenbl = FALSE;
							AudioDisable(ep->e_audchan);
						}

						ep->e_audchan = 0;						// Disconnect from audio channel
					}

					ep->e_cmd = ep->e_stillcmd;			// Go to still mode of choice

/*
					DBUG(
						if (eng == 0)
							printchar(DB_VIDEO3,':');
						else if (eng == 1)
							printchar(DB_VIDB,';');
						else if (eng == OPSENG)
							printchar(DB_OPS,':');
					)
*/
					ep->e_flags |= EFLG_HOLD;
					break;
				case AVCMD_AUDCHG:
					DBUG(printchar(DB_OPS,'A');)

					DBUG(print(DB_TEST,"\n*=%d,%d,%d",ep->e_wasaudchan,ep->e_audchan,ep->e_audenbl);)

					// Disable and unlink from old audio channel (if any)
					// This will never execute, because of the "4ya" audio disabler added
					// above, which disables an enabled audio channel if new command has no audchan
					if ((ep->e_wasaudchan) && (ep->e_audenbl))
					{
						ep->e_audenbl = FALSE;
						AudioDisable(ep->e_wasaudchan);
					}

					if ((ep->e_audchan) && (!ep->e_audenbl))
					{
						ep->e_audenbl = TRUE;
						AudioEnable(ep->e_audchan);
					}
					ep->e_cmd = ep->e_stillcmd;
					ep->e_duration = 0;
					break;

				case AVCMD_PLAY:				// Play 'n' frames, then still
				case AVCMD_ADVFRM:			// Advance 'n' frames (w/audio), then still

					// Be sure audio channel is turned on if needed
					if ((newcmd) && (ep->e_audchan))
					{
						if (!ep->e_audenbl)						// Don't re-enable if already!!
						{
							DBUG(printchar(DB_OPS,'a');)
							ep->e_audenbl = TRUE;
							AudioEnable(ep->e_audchan);
						}

						if (ep->e_cmdflags & AVCF_AUDMUTE)
						{
							DBUG(printchar(DB_OPS,'l');)
							ep->e_flags |= EFLG_AUDMUTE;		// Go quiet when still
						}
						else
						{
							DBUG(printchar(DB_OPS,'q');)
							ep->e_flags &= ~EFLG_AUDMUTE;		// Don't go quiet when still
						}
					}
					goto noflush;

				case AVCMD_FLUSH:
				case AVCMD_FLUSHNOW:
					DBUG(printchar(DB_VIDEO3,'f');)

noflush:
					if (eng <= HIVIDMACHNUM)
					{
						nextbuf	= NextVidBufNum(ep->e_curbuf);
						bfp =     &Vbufctrl[eng-baseof_Vbufctrl][nextbuf];
						mtflag	= bfp->bf_empty;
					}
					else
					{
						nextbuf	= NextAudBufNum(ep->e_curbuf);
						bfp =     &Abufctrl[eng-baseof_Abufctrl][nextbuf];
						mtflag	= bfp->bf_empty;
					}
					ep->e_flags &= ~EFLG_HOLD;

					/* Buffer empty? */
					if (mtflag)
					{
						DBUG(
							if (eng == 0)
								printchar(DB_VIDEO3,'.');
							else if (eng == 1)
								printchar(DB_VIDB,',');
							else if (eng == OPSENG)
								printchar(DB_OPS,'.');
							printchar(DB_OPS,'0'+nextbuf);
						)

						if ((ep->e_cmd == AVCMD_FLUSH) || (ep->e_cmd == AVCMD_FLUSHNOW))
						{
							ep->e_cmd = ep->e_stillcmd;
							ep->e_duration = 0;
							DBUG(printchar(DB_TEST,'*');)
						}
						else
						{
							// Uhoh, we were unable to maintain playback!  Show error to app.
							// Note that we proceed anyway, unless app aborts play

							if (ep->e_UserID)			// Ignore errors if UserID = NULL
							{
								// Indicate error, dropped count +=4
								ExtraErrInfo(ERR_DROPPEDFLDS,(ULONG)ep->e_UserID,4);
							}
						}

//						/* DEBUGGING - TAKE THIS OUT ! */
//						if (ep->e_cmd == AVCMD_PLAY)
//						{
//							if (PauseClkIndex<100)
//								PauseClkTable[PauseClkIndex++] = FieldClock;
//						}
					}
					else
					{
						DBUG(
							if (eng == 0)
								printchar(DB_VIDEO3,'>');
							else if (eng == 1)
								printchar(DB_VIDB,')');
							else if (eng == OPSENG)
								printchar(DB_OPS,'>');
						)

//-----------------------------------------
						// Special test: Stop flushes at fences!
						if (((ep->e_cmd == AVCMD_FLUSH) || (ep->e_cmd == AVCMD_FLUSHNOW))
						&& (BFF_FENCE & bfp->bf_flags))		// Still points to [nextbuf]
						{
							ep->e_cmd = ep->e_stillcmd;
							ep->e_duration = 0;
//							DBUG(print(DB_TEST,"Fence!");)
							break;
						}
//-----------------------------------------

						if (eng <= HIVIDMACHNUM)
							bfp = &Vbufctrl[eng-baseof_Vbufctrl][ep->e_curbuf];
						else
							bfp = &Abufctrl[eng-baseof_Abufctrl][ep->e_curbuf];
						bfp->bf_empty = TRUE;	// Relinquish buffer I was using

						ep->e_bufsfull--;
//						BufsFull[eng-baseof_BufsFull]--;

						DBUG(DrawBar(eng);)

						dosignal = TRUE;
						ep->e_curbuf = nextbuf;					// Advance


//						// For ADVFRM only, kick audio on in sync with this new frame
//						if ((ep->e_cmd == AVCMD_ADVFRM) && (ep->e_audchan != 0))
//						{
// (elsewhere)			AudioEnable(ep->e_audchan);		// Move audio for this frame
//
//							// Check caller's preference for audio looping
//							if (ep->e_cmdflags & AVCF_AUDMUTE)
//							{
//								DBUG(printchar(DB_OPS,'l');)
//								ep->e_flags |= EFLG_AUDMUTE;		// Go quiet when still
//							}
//							else
//							{
//								DBUG(printchar(DB_OPS,'q');)
//								ep->e_flags &= ~EFLG_AUDMUTE;		// Don't go quiet when still
//							}
//						}

						if (ep->e_duration)
							ep->e_duration--;			// Did one more

						if (ep->e_duration == 0)
						{
							ep->e_cmd = ep->e_stillcmd;	// Go still

//							DBUG(print(DB_TEST,"%d",ep->e_audchan);)
							DBUG(printchar(DB_TEST,'|');)
						}
					}

//					/* Frame advance stops on next frame */
//					if (ep->e_cmd == AVCMD_ADVFRM)
//					{
//						ep->e_flags |= EFLG_HOLD;
//						ep->e_cmd = ep->e_stillcmd;
//					}

					break;
				default:
					DBUG(print(DB_VIDEO,"Bad command!\n");)
					break;
			}
		}

		if (eng <= HIVIDMACHNUM)
		{
			ep->e_error = PickupFieldParams(ep);
			if (ep->e_error != 0)
			{
				DBUG(print(DB_ALARMS,"PFP:%b\n",ep->e_error);)
			}

			/* Start video decompress */
			StartVid(ep,WRITE,softstart);
		}

		if (eng <= HIVIDMACHNUM)
			offset = 0;					// No header to skip
		else
			offset = HEADERLEN;		// Header to skip


		switch (ep->e_cmd)
		{
			case AVCMD_FIELD:
				fld = gl_FldOffset+1;
				break;
			case AVCMD_2FIELD:
				fld = ((ep->e_field-1) & 0x1)+1;
				break;
			default:
				fld = ep->e_field;
		}
/*P*/	AudioMachine(ep->e_audchan,eng,fld,ep->e_curbuf,offset,ep->e_monochan);
	}
	else	// REC
	{
		if (eng <= HIVIDMACHNUM)
		{
			dmaptr = ReadPtr(VID2DMA(eng));

			fld = ep->e_field;
			fip = &(*Vhdrs)[eng-baseof_Vhdrs][ep->e_curbuf].fh_fld[ep->e_field-baseof_fhfld];
			bfp = &Vbufctrl[eng-baseof_Vbufctrl][ep->e_curbuf];

			if (dmaptr > bfp->bf_lastaddr)
			{
				bfp->bf_flags |= BFF_BADVID;		// Video data is probably unusable

				DBUG(print(DB_ALARMS,"Overran end:%w\n",dmaptr);)
			}

			/* Save field parameters - before we update them */
			fip->fi_vloc = bfp->bf_ptr - bfp->bf_addr;	// Offset to field data
			fip->fi_vlen = dmaptr - bfp->bf_ptr;			// field data length
			fip->fi_tol	= ep->e_tol;
			fip->fi_FIRset= ep->e_firset;						// Remember FIR set used

			DBUG(
				if ((eng == 1) && (ep->e_field == 1))
					print(DB_SIZE,"%b ",fip->fi_vlen);
			)

			if (VTASCversion == VTASC_NEWD2)				// New video chips?
			{
				if (ep->e_algo != 0)
					fip->fi_flags |= FIF_SUBNYQ;				// SN mode
				else
					fip->fi_flags &= ~FIF_SUBNYQ;				// D2 mode

			}
			fip->fi_rndsz	= ep->e_rndbit;
			fip->fi_rndfrq	= ep->e_rndfrq;
			fip->fi_seed	= ep->e_rndseed;
//			fip->fi_key		= RecKey;

			sbp = &SMPTEa[1-RxAfill];

			fip->fi_serlen = sbp->sb_Index;				// length of serial stuff
			fip->fi_sertype= SerPortDevices[0];			// Type of device
			fip->fi_sermake= SerPortMakes[0];			// Make of device
			if (fip->fi_serlen >= SERIALMAXLEN)
				fip->fi_serlen = SERIALMAXLEN;

			/* Now copy field's serial data into header */
			CopyMem(&sbp->sb_Buffer,&fip->fi_serial,fip->fi_serlen);

			bfp->bf_ptr	= dmaptr;							// Bump ptr for next field

/*** Eventually, we could adjust FIR precomp here too.  But first, we ***/
/*** must quit using constant ch_FIRset and start using fi_FIRset at  ***/
/*** each field start!																 ***/

			/******************************\
			** Optimize compression modes **
			\******************************/

			if (SpecialChoices == 1)			// Alternate across algo's
			{
				if (fld == 4)					// Only change each color frm
				{
					if ((++SpecialToggle[eng]) & 1)
					{
						ep->e_algo	= MinAlgo;
						ep->e_tol	= MinTols[MinAlgo];
					}
					else
					{
						ep->e_algo	= MaxAlgo;
						ep->e_tol	= MaxTols[MaxAlgo];
					}
				}
			}
			else if (eng == 1)		// Backup (safe) video mode
			{
				ep->e_algo = 1;					// Always SN tolerance 1 (#5)
				ep->e_tol  = 1;
			}
			else if (bumpSN)		// Scramble for easier compress?
			{
				if (ep->e_algo < MaxAlgo)	// Can we bump to SN?
				{
					ep->e_algo++;					// Next algo
					ep->e_tol = MinTols[ep->e_algo];	// Lowest tolerance
				}
			}
			else		// Normal, size-based choice
			{
				// Huge impulse test (tough scene transitions)
				if (fip->fi_vlen > ep->e_vmaxlen)
				{
					// Video data is probably unusable
					// This implies that we should use alt compression data (from A)
					bfp->bf_flags |= BFF_BADVID;
					DBUG(printchar(DB_ALARMS,'+');)
				}

				if (fip->fi_vlen > ep->e_vlen)		// Too much data?
				{
					if (ep->e_tol < MaxTols[ep->e_algo])
					{
						ep->e_tol++;						// Same algo, higher toler
					}
					else if (ep->e_algo < MaxAlgo)
					{
						ep->e_algo++;						// Next algo
						ep->e_tol = MinTols[ep->e_algo];	// Lowest tolerance
					}
				}
				else if (fip->fi_vlen <= ep->e_llim)		// Too little data?
				{
					if (ep->e_tol > MinTols[ep->e_algo])
					{
						ep->e_tol--;						// Same algo, lower toler
					}
					else if (ep->e_algo > MinAlgo)
					{
						ep->e_algo--;						// Prev algo
						ep->e_tol = MaxTols[ep->e_algo];	// Highest tolerance
					}
				}
			}

			ep->e_rndbit = ep->e_tol;

			NewSeed(ep);
		}
		else
		{
			/* Handle audio-only recording */
/*R*/		AudioMachine(ep->e_audchan,eng,ep->e_field,ep->e_curbuf,HEADERLEN,0);
		}

		ep->e_field++;
		ep->e_fldctr++;						// Another field completed

		/* Skip a field to get back in sync? */
		if (ep->e_adjust && (!NoAdjust))
		{
			if (eng <= HIVIDMACHNUM)
			{
				/* Mark missing field as non-existent */

				fip = &(*Vhdrs)[eng-baseof_Vhdrs][ep->e_curbuf].fh_fld[ep->e_field-baseof_fhfld];

				/* Save field parameters - before we update them */
				fip->fi_vloc	= 0;			// Offset to field data
				fip->fi_vlen	= 0;			// field data length
				fip->fi_seed	= ep->e_rndseed;
				fip->fi_serlen = 0;			// length of serial stuff
				NewSeed(ep);
			}

			ep->e_field++;
			ep->e_adjust = FALSE;

			DBUG(printchar(DB_ALARMS,'f');)
		}

		newframe = FALSE;

		if (ep->e_field > FIELDSPERFRAME)
		{
			if (eng == 0)
				RecKey++;

			ep->e_field = ep->e_field - FIELDSPERFRAME;
			newframe = TRUE;

//			/* Time to auto-switch to a new command? */
//			if ((ep->e_syncflag) && ((FieldClock+4) >= ep->e_synctime))
//			{
//				DBUG(printchar(DB_VIDEO2,'+');)
//
//				ep->e_cmd = ep->e_synccmd;
//				ep->e_syncflag = FALSE;			// Deactivate now
//			}

			/* Time to auto-switch to a new command? */
			if (GetEngEvent(ep,FieldClock+4))
			{
				DBUG(printchar(DB_VIDEO2,'+');)
			}

			/* Should we loop in current buffer or move on? */
			switch (ep->e_cmd)
			{
				case AVCMD_LIVE:
				case AVCMD_STOPREC:
/*
					DBUG(
						if (eng == 0)
							printchar(DB_VIDEO3,':');
						else if (eng == 1)
							printchar(DB_VIDB,':');
						else if (eng == OPSENG)
							printchar(DB_OPS,':');
					)
*/
					ep->e_cmd = AVCMD_LIVE;			// Go live if not already
					ep->e_lastbuf = ep->e_curbuf;
					ep->e_flags |= EFLG_HOLD;
					break;
				case AVCMD_REC:
					ep->e_flags &= ~EFLG_HOLD;
					if (eng <= HIVIDMACHNUM)
					{
						nextbuf	= NextVidBufNum(ep->e_curbuf);
						mtflag	= Vbufctrl[eng-baseof_Vbufctrl][nextbuf].bf_empty;
					}
					else
					{
						nextbuf	= NextAudBufNum(ep->e_curbuf);
						mtflag	= Abufctrl[eng-baseof_Abufctrl][nextbuf].bf_empty;
					}

					if (VidPaused)
					{
						ep->e_lastbuf = ep->e_curbuf;
					}
					else if (mtflag)
					{
						DBUG(
							if (eng == 1)
								printchar(DB_VIDB,'<');
							else
								printchar(DB_VIDEO3,'<');
						)
						ep->e_lastbuf = ep->e_curbuf;
						ep->e_curbuf = nextbuf;
					}
					else
					{
						DBUG(
							if (eng == 1)
								printchar(DB_VIDB,',');
							else
								printchar(DB_VIDEO3,',');
							printchar(DB_ALARMS,'!');
						)
						ep->e_lastbuf = ep->e_curbuf;

						// In case app is watching, show dropped frame count
						ExtraErrInfo(ERR_DROPPEDFLDS,(ULONG)ep->e_UserID,4);

						// (user) option to stop recording since we dropped fields
						// Only notice dropped frame (and hence stop) if enabled
						if (OPTF_DROPFRMDET & GlobalOptions)
							DroppedFields = TRUE;
					}
					break;
				case AVCMD_ADVFRM:
					ep->e_flags &= ~EFLG_HOLD;
					ep->e_lastbuf = ep->e_curbuf;
					ep->e_curbuf = NextVidBufNum(ep->e_curbuf);	// Advance
					ep->e_cmd = AVCMD_LIVE;								// Just once!
					ep->e_duration = 0;									// Command expired
					ep->e_flags |= EFLG_HOLD;
					break;
				case AVCMD_STARTREC:
					ep->e_cmd = AVCMD_REC;	// Loop again on this buffer, then rec
					break;
			}

			if (eng <= HIVIDMACHNUM)
			{
				bfp = &Vbufctrl[eng-baseof_Vbufctrl][ep->e_curbuf];

				// No fields have overrun yet, we're just ready to get frame
				bfp->bf_flags &= ~BFF_BADVID;

				// Set initial pointer for the buffer to be used
				bfp->bf_ptr = bfp->bf_addr + HEADERLEN + MONOAUDFRAME * ep->e_numaudchans;
			}
		}

		if (eng <= HIVIDMACHNUM)
		{
			/* Start video compress */
			StartVid(ep,READ,softstart);
		}

		/* Need to finish compiling/saving data for previous buffer? */
		if ((newframe) && (ep->e_lastbuf != ep->e_curbuf))
		{
			if (eng <= HIVIDMACHNUM)
			{
				fhp = &(*Vhdrs)[eng-baseof_Vhdrs][ep->e_lastbuf];
				bfp = &Vbufctrl[eng-baseof_Vbufctrl][ep->e_lastbuf];
				fhp->fh_chunklen	= bfp->bf_ptr - bfp->bf_addr;
				fhp->fh_vidcmpver	= VTASCversion;
				fhp->fh_audcmpver	= AUDIO_VERSION;
				bfp->bf_empty		= FALSE;				// Have data to move!
				bfp->bf_flags &= ~BFF_OUTSIDE;		// Points inside buffer area
			}
			else
			{
				/* Have data to move! */
				bfp = &Abufctrl[eng-baseof_Abufctrl][ep->e_lastbuf];
				bfp->bf_empty		= FALSE;
				bfp->bf_flags &= ~BFF_OUTSIDE;		// Points inside buffer area
			}

			ep->e_bufsfull++;
//			BufsFull[eng-baseof_BufsFull]++;
			DBUG(DrawBar(eng);)
		}
	}

	return(dosignal);
}


/*
 * EngineCommand - Send command to Audio/Video Engine
 */
void EngineCommand(UBYTE	eng,
						UBYTE	command,
						ULONG	gotime,
						ULONG	length,
						APTR	args,
						ULONG	ID)
{
	struct ENGINE	*ep;
	UBYTE	err;
	DBUG(UBYTE try=0;)

	DBUG(print(DB_VIDEO2,"Sync Cmd--->%b\n",command);)

//	ep = &Engine[eng-baseof_Engine];
	ep = GetEngine(eng);

	while ((err = AddEngEvent(ep,gotime,length,command,args,ID)) != ERR_OKAY)
	{
		DBUG(print(DB_ALARMS,"VC%b!",++try);)
		Delay(1);

		if (GetSignals() & SIGF_ABORT)					// Watch for abort here!
			break;
	}

//	ep->e_synccmd = command;
//	ep->e_synctime = gotime;
//	ep->e_syncflag = TRUE;
}


/*
 *  AddEngEvent -- insert event into sorted list for engine
 */
static UBYTE AddEngEvent(	struct ENGINE *engine,
									ULONG	when,
									ULONG length,
									UBYTE	cmd,
									APTR args,
									ULONG	ID)
{
	struct EngineEvent	*this,*new,**nextptr;
	ULONG						i;
	UBYTE						err;

	Disable();

	DBUG(print(DB_CLOCK,"(%b~%l)",cmd,length);)

	/*** FLUSHNOW causes all previous events to flush out without waiting ***/
	if (cmd == AVCMD_FLUSHNOW)
	{
		for (this = engine->e_1stevent ; this ; this=this->ee_next)
			this->ee_time = 0;
	}

	/* Find spot to insert event so they are time-sorted */
	/* Events with time==0 go at end of list */
	for (nextptr=&engine->e_1stevent; this=*nextptr ; nextptr=&this->ee_next)
	{
		if ((when != 0) && (when < this->ee_time))
			break;
	}

	err = ERR_CMDFAILED;		// Default

	for (i=NUMENGEVENTS,new=&engine->e_events[0] ; i ; i--,new++)
	{
		if (!new->ee_active)
		{
			*nextptr = new;					// Insert into list
			new->ee_next = this;				// Put remainder after me

			new->ee_time = when;				// Fill in goodies
			new->ee_len  = length;
			new->ee_cmd  = cmd;
			new->ee_UserID = ID;				// User ID number, or NULL

			if (args)
				memcpy(new->ee_args,args,sizeof(struct PlayArgs));

			new->ee_active = TRUE;
			err = ERR_OKAY;
			break;
		}
	}

	Enable();
	return(err);
}


/*
 *  GetEngEvent -- get next event that is due for engine (IRQ code!)
 */
static BOOL GetEngEvent(	struct ENGINE *engine,
									ULONG	clock)
{
	struct EngineEvent	*this;
	BOOL gotone = FALSE;

//	Disable();		// !$!  Called from IRQ code currently

	this = engine->e_1stevent;

	DBUG(
		if ((this) && (this->ee_time <= clock))							// Is it due?
		{
			if (engine->e_duration == 0)							// Are we ready for it?
				printchar(DB_TEST,'+');
			else
				print(DB_TEST,"!%l",engine->e_duration);
		}
	)

	if ((this != NULL)										// Is an event waiting?
	&& (this->ee_time <= clock)							// Is it due?
	&& ((engine->e_duration == 0)							// Are we ready for it?
	|| (!(AV_QUEUED_TYPE & this->ee_cmd))))			//  Or if not, take it anyway?
	{
		engine->e_cmd = this->ee_cmd;						// Retrieve info
		engine->e_duration = this->ee_len;

		if (this->ee_UserID)
			engine->e_UserID = this->ee_UserID;			// Grab user's ID, if non-NULL

		switch (this->ee_cmd)
		{
		case AVCMD_PLAY:
		case AVCMD_ADVFRM:
		case AVCMD_AUDCHG:
			engine->e_audchan = ((struct PlayArgs *)this->ee_args)->AudChan;
			engine->e_monochan = ((struct PlayArgs *)this->ee_args)->MonoChan;
			engine->e_numaudchans = ((struct PlayArgs *)this->ee_args)->NumAudChans;
			engine->e_cmdflags = ((struct PlayArgs *)this->ee_args)->Flags;
			break;
		}

		this->ee_active = FALSE;					// Took this

		engine->e_1stevent = this->ee_next;		// Unlink me

		gotone = TRUE;
	}

//	Enable();		// !$!

	return(gotone);
}


/* 
 *  PickupFieldParams - Move params for current field into Engine
 */
UBYTE PickupFieldParams(struct ENGINE *ep)
{
	struct FLDINFO		*fip;
	struct FRAMEHDR	*fhp;
	struct FBUF			*bfp;
	UBYTE	fld,vchan;

	vchan = ep->e_engnum;
	fhp = &(*Vhdrs)[vchan-baseof_Vhdrs][ep->e_curbuf];		// Get pointer to header

	if (fhp->fh_id != ID_CFRM)
		return(ERR_BADVIDHDR);

	switch (ep->e_cmd)
	{
		case AVCMD_FIELD:
			fld = gl_FldOffset+1;
			break;
		case AVCMD_2FIELD:
			fld = ((ep->e_field-1) & 0x1)+1;
			break;
		default:
			fld = ep->e_field;
	}

	fip = &fhp->fh_fld[fld-baseof_fhfld];						// Get pointer to FldInfo

	bfp = &Vbufctrl[vchan-baseof_Vbufctrl][ep->e_curbuf];	// Get pointer to Vbufctrl

	bfp->bf_ptr = bfp->bf_addr + fip->fi_vloc - HEADERLEN;

	if (FIF_SUBNYQ & fip->fi_flags)
		ep->e_algo = 1;
	else
		ep->e_algo = 0;

	ep->e_tol			= fip->fi_tol;
	ep->e_rndbit		= fip->fi_rndsz;
	ep->e_rndfrq		= fip->fi_rndfrq;
	ep->e_rndseed		= fip->fi_seed;

	return(ERR_OKAY);
}


/*
 *  PlayVidMachine - Video/audio playback (variable length frames)
 */
BOOL PlayVidMachine(UBYTE mach, UWORD ID, UBYTE *HostAbort)
{
	struct MACHINE		*avm;
	struct ENGINE		*ep;
	struct FRAMEHDR	*fhp;
	struct FBUF			*bfp;
	struct PlayArgs myplayargs;
	UBYTE	nextbuf;
	ULONG	slen;					// Blocks in this transfer
	ULONG	frmstodo,timeout;
	BOOL	firstframe=TRUE,success=TRUE;

	avm = &AVmachine[mach-baseof_AVmachine];
//	ep = &Engine[mach-baseof_Engine];
	ep = GetEngine(mach);


	DBUG(printchar(DB_MACH,'0');)

	avm->m_frmsdone = 0;				// Start at 0
//	avm->m_didpragma= FALSE;		// Have not set colors pragmatically

	avm->m_saddr = avm->m_startaddr;		// Start location

	/* Do some error checking on the request */
	if ((avm->m_stopaddr!=0) && (avm->m_saddr >= avm->m_stopaddr))
	{
		avm->m_error = ERR_BADPARAM;
		goto finish;
	}

//	if (MF_INHEAD & avm->m_flags)
//	{
//		drive	= avm->m_shdrive;
//		blk	= avm->m_shaddr;
//	}
//	else
//	{
//		drive	= avm->m_sdrive;
//		blk	= avm->m_saddr;
//	}
//	/* Seek to start block */
//	avm->m_error = DoSCSI(drive,SCMD_SEEK,blk,NULL,0);
//	if (avm->m_error != 0)
//		goto finish;


	/* Pick buffer to start filling */
	avm->m_curbuf = PrevVidBufNum(ep->e_userbuf);			// Where to start

	DBUG(if (mach==0)	print(DB_ALWAYS,"(%b)",avm->m_curbuf);	)

	slen = 0;											// No data to gather first time - just hdr
//	avm->m_priming = TRUE;							// Special first read

	/* Tell video when to start pumping */
	myplayargs.AudChan = avm->m_achan;					// Audio off/channel for clip
	myplayargs.MonoChan = avm->m_monochan;				// Mono L/R channel selector
	myplayargs.NumAudChans = avm->m_numaudchans;		// Number of channels
//	DBUG(print(DB_ALWAYS,"|-%d,%d-|",avm->m_monochan,avm->m_numaudchans);)
	myplayargs.Flags = 0;
//	if (!Sequencing)
	myplayargs.Flags |= AVCF_AUDMUTE;				// Mute when finished

	frmstodo = avm->m_stopfrm;
	if (MF_GOMATTE & avm->m_flags)
		frmstodo++;

	EngineCommand(mach,AVCMD_PLAY,avm->m_goclock,frmstodo,&myplayargs,ID);

//	/* Submit audio events */
//	if (avm->m_numaudchans > 0)
//	{
//		if (avm->m_attackclk != 0)
//			err = AddAudEvent(avm->m_attackclk,avm->m_achan,avm->m_volume,avm->m_pan,avm->m_attack);
//
//		if (avm->m_decayclk != 0)
//			err = AddAudEvent(avm->m_decayclk,avm->m_achan,0,avm->m_pan,avm->m_decay);
//
//		if (audmach[avm->m_achan-baseof_audmach].am_stereo)
//		{
//			if (avm->m_attackclk != 0)
//			{
//				err = AddAudEvent(avm->m_attackclk,avm->m_achan+1,avm->m_volume2,avm->m_pan2,
//				avm->m_attack);
//			}
//			if (avm->m_decayclk != 0)
//				err = AddAudEvent(avm->m_decayclk,avm->m_achan+1,0,avm->m_pan,avm->m_decay);
//
//		}
//	}

	/*********************************************/
	/* Read the header for the first color frame */
	/*********************************************/

	// Wait here until I have exclusive use of this SCSI channel
	ObtainSemaphore(&SCSIsema[avm->m_sdrive >> 3]);

	// This supports the sequencing "order" mechanism, in which the clips are lined up
	// in a specific order in which they are to attempt to allocate their SCSI drive
	if (avm->m_OrderPtr)
		(*avm->m_OrderPtr)++;				// Okay, I'm going, next guy get ready!

	DBUG(printchar(DB_TEST,'O');)

	// Compute address to receive header (end of buffer for currently displayed frame)
	avm->m_loadaddr = Vbufctrl[mach-baseof_Vbufctrl][avm->m_curbuf].bf_addr
		+ VBUFSIZE-HEADERLEN;

	/* Do SCSI read -- goes to sleep until done */
	avm->m_error = DoSCSI(avm->m_sdrive,SCMD_READ,avm->m_saddr,
		(APTR)avm->m_loadaddr,HEADERLEN);
	if (avm->m_error)
		goto dealloc;

	avm->m_saddr += HEADERLEN;			// Update SCSI address

	/* Plug location of header read into next frame's struct */
	nextbuf = NextVidBufNum(avm->m_curbuf);
	Vbufctrl[mach-baseof_Vbufctrl][nextbuf].bf_hdraddr = avm->m_loadaddr;

	/* Skip to next buffer now */
	avm->m_curbuf = nextbuf;


	/*** Do all requested frames ***/
	while ((avm->m_stopfrm == 0) || (avm->m_frmsdone < avm->m_stopfrm))
	{
		DBUG(if (mach==0)	printchar(DB_MACH,'1');)

		if ((HostAbort) && (*HostAbort == 0))		// Host aborting playback?
			break;

		ProhibitSCSIdirect = 2;				// Keep holding off CD-ROM accesses

		bfp = &Vbufctrl[mach-baseof_Vbufctrl][avm->m_curbuf];

		/*** Wait for an empty buffer to hold another frame ***/

		for (;;)
		{
			DBUG(if (mach==0)	printchar(DB_MACH,'2');)

			/* If user requesting abort, initiate shut-down */
			if (GetSignals() & SIGF_ABORT)					// User abort?
			{
				DBUG(print(DB_TEST,"Vabrt%l\n",mach);)
//				error = ERR_ABORTED;	???
				avm->m_break = TRUE;		// STOP!
			}

			if (avm->m_break)								// Aborted?
			{
//				/* Mute audio now! */
//				if (avm->m_achan != 0)
//				{
//					AddAudEvent(0,avm->m_achan,0,0,0);
//					if (audmach[avm->m_achan-baseof_audmach].am_stereo)
//						AddAudEvent(0,avm->m_achan+1,0,0,0);
//				}
//				/* Need to do something to prevent flushing too early */

//Do this below, AFTER we make a black frame buffer (so it doesn't get missed!)
//				EngineCommand(mach,AVCMD_FLUSHNOW,0,999,NULL,0);		// Use all data, hold last

				goto dealloc;		// Shut myself down gracefully
			}

			// Do we have our buffer?
			if (bfp->bf_empty == TRUE)
				break;

			Delay(1);			// Go to sleep for a bit, then try again later
			// THIS WOULD BETTER BE DONE BY A SIGNAL WHICH INDICATES A BUFFER HAS BEEN FREED!!!
		}

		fhp = &(*Vhdrs)[mach-baseof_Vhdrs][avm->m_curbuf];

		/* DMA header from DRAM into header buffer */
		CpuXferMemWait(fhp, bfp->bf_hdraddr, HEADERLEN,WRITE);


		DBUG(print(DB_SIZE,"%b ",fhp->fh_fld[1-baseof_fhfld].fi_vlen);)

		if (fhp->fh_id != ID_CFRM)		// Read a bad header?
		{
			DBUG(print(DB_MACH,"Bad ID - mach=%b buf=%b id=%l (addr %l)\n",
				mach,avm->m_curbuf,fhp->fh_id,&fhp->fh_id);)
			DBUG(print(DB_MACH,"(%l frames done)\n",avm->m_frmsdone);)

			avm->m_error = ERR_BADVIDHDR;
			goto dealloc;
		}

		/* Playing incompatible clip? */
		if (fhp->fh_vidcmpver != VTASCversion)
		{
			DBUG(print(DB_MACH,"Incompatible clip\n");)

			avm->m_error = ERR_OLDDATA;
			goto dealloc;
		}

		/* Grab audio version for audio code */
		if (avm->m_achan != 0)
			audmach[avm->m_achan-baseof_audmach].am_version = fhp->fh_audcmpver;

//		/* Update SCSI address */
//		avm->m_saddr += slen+HEADERLEN;
//		avm->m_shaddr += slen+HEADERLEN;

		/* Compute number of blocks to read */
		slen = fhp->fh_chunklen-HEADERLEN;

//		/* Color adjustment pragma's */
//		if ((!avm->m_didpragma) && (fhp->fh__Pragma == 0xBEEF))
//		{
//			if (mach == 0)
//			{
//				SetVideoOffset(0,fhp->fh__Offset);
//				tempword = fhp->fh__CourseA;
//				SetVideoSkew(0,&tempword);
//			}
//			else
//			{
//				SetVideoOffset(1,fhp->fh__Offset);
//				tempword = fhp->fh__CourseB;
//				SetVideoSkew(1,&tempword);
//			}
//
//			avm->m_didpragma = TRUE;
//		}


		/******************************/
		/* Read a color frame of data */
		/******************************/

		DBUG(if (mach==0)		printchar(DB_MACH,'3');		)

		/* This test is subtle, but we must read one extra block,
		since we're reading this frame's data with next frame's header */

		/* Make sure this SCSI read wont go beyond end address */
		if ((avm->m_stopaddr!=0)
		&& ((avm->m_saddr + (slen+HEADERLEN)) > avm->m_stopaddr))
		{
			avm->m_error = ERR_EXHAUSTED;
			DBUG(print(DB_MACH,"exhausted\n");)
			goto dealloc;
		}

		/* Compute address to receive data */
		avm->m_loadaddr = bfp->bf_addr;

		/* Do SCSI read -- goes to sleep until done */
		avm->m_error = DoSCSI(avm->m_sdrive,SCMD_READ,avm->m_saddr,
			(APTR)avm->m_loadaddr,slen+HEADERLEN);
		if (avm->m_error != ERR_OKAY)
		{
			DBUG(print(DB_MACH,"read failed (%b)\n",avm->m_error);)
			goto dealloc;
		}

		/* Update SCSI address */
		avm->m_saddr += slen+HEADERLEN;
//		avm->m_shaddr += slen+HEADERLEN;

		/* Plug location of header read into next frame's struct */
		nextbuf = NextVidBufNum(avm->m_curbuf);
		Vbufctrl[mach-baseof_Vbufctrl][nextbuf].bf_hdraddr = avm->m_loadaddr + slen;

		DBUG(if (mach==0)		printchar(DB_MACH,'4');		)

		if (firstframe)
		{
			bfp->bf_flags |= BFF_FENCE;		// Don't let flushes slip thru!
			firstframe = FALSE;
//			DBUG(print(DB_TEST,"||");)
		}
		else
			bfp->bf_flags &= ~BFF_FENCE;		// Don't let flushes slip thru!
		bfp->bf_flags &= ~BFF_OUTSIDE;		// Points inside buffer area
		bfp->bf_empty = FALSE;					// Mark buffer as not empty!

		ep->e_bufsfull++;
//		BufsFull[mach-baseof_BufsFull]++;
		DBUG(DrawBar(mach);)

		frmstodo--;									// Did one more promised frame

		ep->e_userbuf = nextbuf;				// Remember next buffer to fill
		avm->m_frmsdone++;

		/* Ran out of data? */
		if (fhp->fh_nextfrm == 0)
		{
			avm->m_error = ERR_EXHAUSTED;
			avm->m_curbuf = nextbuf;			// Go ahead and skip to next???
			goto dealloc;
		}

		/* Skip to next buffer now */
		avm->m_curbuf = nextbuf;
	}

	/* Done all requested fields */

dealloc:

	// Free SCSI channel to be used by others
	ReleaseSemaphore(&SCSIsema[avm->m_sdrive >> 3]);

	DBUG(printchar(DB_TEST,'R');)


wrapup:		/*** Wrap up (maybe put up matte) ***/
	DBUG(if (mach==0)		printchar(DB_MACH,'-');		)

	/* End with a matte color? (Also if aborted) */
	if ((MF_GOMATTE & avm->m_flags) || (avm->m_break))
	{

		timeout = 0;

		/* Wait for free space in buffer to build matte */
		while (!(Vbufctrl[mach-baseof_Vbufctrl][avm->m_curbuf].bf_empty))
		{
			DBUG(if (mach==0)		printchar(DB_MACH,']');		)
			Delay(1);

			if ((avm->m_break) && ((++timeout) > 40))			// 400ms
				goto bailout;
			if ((++timeout) > 200)			// 2 seconds absolute max!
				goto bailout;
		}

		MakeMatteFrame(mach,avm->m_curbuf);		// (Bumps e_userbuf)

		frmstodo--;									// Did one more promised frame

bailout:
		if (avm->m_break)								// Aborted?
		{
			DBUG(if (mach==0)		printchar(DB_MACH,'^');		)
//			nextbuf = ep->e_userbuf+1;			// Buffer where next provider should start
//			EngineCommand(mach,AVCMD_FLUSHNOW,0,999,&nextbuf,0);	// Flush all MY data
			EngineCommand(mach,AVCMD_FLUSHNOW,0,999,&NullAudioArgs,0);	// Use all data, hold last
		}

		DBUG(if (mach==0)		printchar(DB_MACH,'5');		)
	}

	if ((!avm->m_break) && (frmstodo > 0))
	{
		DBUG(print(DB_MACH,"Emergency flush!\n");)
		EngineCommand(mach,AVCMD_FLUSHNOW,0,999,&NullAudioArgs,0);		// Use all data, hold last

		success = FALSE;

//		while (frmstodo--)
//		{
//			DBUG(print(DB_MACH,"Emergency black!\n");)
//
//			avm->m_curbuf = NextVidBufNum(avm->m_curbuf);
//
//			/* Wait for free space in buffer to build matte */
//			while (!(Vbufctrl[mach-baseof_Vbufctrl][avm->m_curbuf].bf_empty))
//				Delay(1);
//
//			MakeMatteFrame(mach,avm->m_curbuf);		// (Bumps e_userbuf)
//		}
	}

//	if (avm->m_die)
//		EngineCommand(mach,AVCMD_STILL,0,0,NULL,0);		// Stop immediately
//	else
//		EngineCommand(mach,AVCMD_FLUSH,0,0,NULL,0);		// Use all data, hold last

finish:
	DBUG(if (mach==0)		printchar(DB_MACH,'=');		)

//	/* Wait until video is holding with no more events in queue */
//	while ((!(EFLG_HOLD & ep->e_flags)) || (ep->e_1stevent))
//		Delay(1);

//	ep->e_audchan = 0;	// Disconnect from audio channel

//	if (avm->m_break)
//		CleanupVidBuffers(mach,PLAY);		// Throw away unused data

	DBUG(print(DB_ALWAYS,"Left with eng=%b, user=%b\n",ep->e_curbuf,ep->e_userbuf);)

	return(success);							// Returns FALSE if stopped due to error
}


/*
 *  PlayVidBlack - Put up black video
 */
BOOL PlayVidBlack(UBYTE mach, ULONG goclock)
{
	struct ENGINE		*ep;
	struct FBUF			*bfp;
	UBYTE	buf;

	DBUG(print(DB_MACH,"2blk");)

//	ep = &Engine[mach-baseof_Engine];
	ep = GetEngine(mach);

	/* Pick buffer to start filling */
	buf = ep->e_userbuf;			// Where to start

	// Tell video engine to play our 1 black frame at specified time
	EngineCommand(mach,AVCMD_PLAY,goclock,1,&NullAudioArgs,0);

	bfp = &Vbufctrl[mach-baseof_Vbufctrl][buf];

	/* Wait for free space in buffer to build matte */
	while (!bfp->bf_empty)
		Delay(1);

	MakeMatteFrame(mach,buf);						// (Bumps e_userbuf)

	return(TRUE);
}


/*
 *  DoRecMachine - State Machine for video/audio recording
 */
void DoRecMachine(UBYTE mach, UBYTE *contflag)
{
	struct ENGINE	*ep,*ep1;
	struct MACHINE	*avm;
//	UBYTE		nextbuf;
//	UBYTE		zero = 0;
	struct FBUF		*ctrlptr,*ctrlalt;
	struct FRAMEHDR	*hdrptr;
	struct PRIVHEADSBLOCK	*hp;
	union	ANYHDR	*ahp;
	UBYTE		err;
	ULONG		temp;
	BOOL		usesafevid;

	avm = &AVmachine[mach-baseof_AVmachine];
//	ep  = &Engine[mach-baseof_Engine];
	ep = GetEngine(mach);
	ep1 = &Engine[1-baseof_Engine];
	ahp = &(*mischdrs)[mach];

	/*** Wait until A/V engine is ready - Setup record machine ***/

	DBUG(print(DB_TEST,"contflag=%l\n",contflag);)

	DBUG(printchar(DB_MACH,'1');)

	while (!(EFLG_HOLD & ep->e_flags))	// Wait until channel is holding
		Delay(1);

	DBUG(printchar(DB_MACH,'2');)

	ep->e_frmctr = 0;
	ep->e_numaudchans = avm->m_numaudchans;	// Copy to engine

	// Setup dual-channel video recording
	if (mach == 0)
	{
		// Needs to know how much room to allow
		ep1->e_numaudchans = avm->m_numaudchans;
	}

	avm->m_frmsdone	= 0;							// Start at 0
	avm->m_flushing	= FALSE;
//	avm->m_rolling		= FALSE;			// Show user we're not yet rolling
	avm->m_prevaddr	= 0;

	/* Start location (leave room for CLIPHDR) */
	avm->m_saddr		= avm->m_startaddr+1;

	/* Do some error checking on the request */
	if ((avm->m_stopaddr) && (avm->m_saddr >= avm->m_stopaddr))
	{
		avm->m_error = ERR_BADPARAM;
		goto stop;
	}

//	/* Seek to start block */
//	avm->m_error = DoSCSI(avm->m_sdrive,SCMD_SEEK,avm->m_saddr,NULL,0);
//	if (avm->m_error != 0)
//		goto stop;

	/* Index builder stuff */
	for (NdxCtr=0;NdxCtr<15;NdxCtr++)
		Back15Ptrs[NdxCtr] = 0;

	NdxCtr	= 0;		// On an indexed frame
	NdxBlks	= 0;		// Have built no blocks in table yet
	NdxEnt	= 0;		// On 0th entry
	NdxTotal	= 0;		// On 0th entry
	ClearMemory(NdxTable,512);

	DroppedFields = FALSE;


	/*************************/
	/* Set record start time */
	/*************************/

	DBUG(printchar(DB_MACH,'3');)

	avm->m_curbuf = ep->e_curbuf;	// Where to start

	// Handle dual-channel recording
	if (mach == 0)
		avm->m_altbuf = ep1->e_curbuf;

	ep->e_audchan = avm->m_achan;	// Audio off/channel for clip

	/* Tell audio/video when to start pumping (use ID=1 so we watch for dropped fields) */
	EngineCommand(mach,AVCMD_STARTREC,avm->m_goclock,0,&NullAudioArgs,1);
	// Handle dual-channel recording
	if (mach == 0)
		EngineCommand(1,AVCMD_STARTREC,avm->m_goclock,0,&NullAudioArgs,1);


	/***********************************/
	/* Wait for buffer full, write out */
	/***********************************/

	for (;;)
	{
		DBUG(printchar(DB_MACH,'4');)

		ProhibitSCSIdirect = 2;		// Keep holding off CD-ROM accesses

		VidPaused = (*contflag == 0xFF)?TRUE:FALSE;		// Paused?

		DBUG(print(DB_TEST,"(%b)",*contflag);)
//		/* If user requesting abort, initiate shut-down */
		if ((*contflag == 0) || (GetSignals() & SIGF_ABORT))			// User abort?
		{
			DBUG(print(DB_TEST,"Back1 (%b %l)\n",*contflag,GetSignals());)

//			error = ERR_ABORTED;	???
			avm->m_break = TRUE;	// STOP!
		}

		/* User abort? */
		if (avm->m_break && (!avm->m_flushing))
		{
			DBUG(printchar(DB_MACH,'-');)
			avm->m_flushing = TRUE;

			/* This should somehow flush command queue when implemented,
			in case video channel IRQ stream is dead, just clear out */

			EngineCommand(mach,AVCMD_STOPREC,0,0,&NullAudioArgs,0);		// Stop real soon
			// Handle dual-channel recording
			if (mach == 0)
				EngineCommand(1,AVCMD_STOPREC,0,0,&NullAudioArgs,0);		// Stop real soon
		}

		// Should we abort recording?
		if (DroppedFields)
		{
			DBUG(print(DB_TEST,"Dropped!\n");)
			avm->m_error = ERR_EXHAUSTED;
			break;							// Stop audio/video and terminate file
//Wouldn't this be better?
//			avm->m_break = TRUE;			// Stop recording, flush all fields to disk
		}

		if ((avm->m_stopfrm) && (avm->m_frmsdone >= avm->m_stopfrm))
		{
			avm->m_error = ERR_OKAY;
			break;							// Stop audio/video and terminate file
		}

		DBUG(printchar(DB_MACH,'5');)

		if (mach <= HIVIDMACHNUM)
		{
			ctrlptr	= &Vbufctrl[mach-baseof_Vbufctrl][avm->m_curbuf];
			ctrlalt	= &Vbufctrl[1-baseof_Vbufctrl][avm->m_altbuf];	// Only used if mach==0
			hdrptr	= &(*Vhdrs)[mach-baseof_Vhdrs][avm->m_curbuf];
		}
		else
		{
			ctrlptr	= &Abufctrl[mach-baseof_Abufctrl][avm->m_curbuf];
			hdrptr	= &(*Ahdrs)[mach-baseof_Ahdrs];
		}

		// New frame buffer to write?
		if ((ctrlptr->bf_empty == FALSE) && ((mach != 0) || (ctrlalt->bf_empty == FALSE)))
		{
			DBUG(printchar(DB_MACH,'6');)

			// Decide whether to use safe(0) or better(1) video frame data
			if (mach == 0)
			{
				usesafevid = (BFF_BADVID & ctrlptr->bf_flags)?TRUE:FALSE;
//				usesafevid = (m_frmsdone & 0x20)?FALSE:TRUE;		// Testing only!!!

				// Use backup(safe) video (whole color frame)
				if (usesafevid)
				{
					DBUG(printchar(DB_ALWAYS,'@');)
					// Use header built by 'B' compressor
					hdrptr = &(*Vhdrs)[1-baseof_Vhdrs][avm->m_curbuf];
				}
				else
				{
					// Use header built by 'A' compressor
					hdrptr = &(*Vhdrs)[0-baseof_Vhdrs][avm->m_altbuf];
				}
			}

			/* Set audio length/channels */
			if (avm->m_achan != 0)
			{
				hdrptr->fh_audchans	= avm->m_numaudchans;
#ifdef FLYERVER3
				hdrptr->fh_audlen	= MONOAUDFIELD * avm->m_numaudchans;
#else
				hdrptr->fh_audlen	= MONOAUDFIELD;
#endif
			}
			else
			{
				hdrptr->fh_audchans	= 0;
				hdrptr->fh_audlen	= 0;
			}

			if (mach <= HIVIDMACHNUM)
			{
				/* Video chunklen set by AV engine */
				hdrptr->fh_vidflag = TRUE;
			}
			else
			{
//				hdrptr->fh_chunklen = HEADERLEN + AudSize[mach-baseof_AudSize][avm->m_curbuf];
#ifdef FLYERVER3
				hdrptr->fh_chunklen = HEADERLEN + hdrptr->fh_audlen * FIELDSPERFRAME;
//				hdrptr->fh_chunklen = HEADERLEN + MONOAUDFRAME * avm->m_numaudchans;
#else
				hdrptr->fh_chunklen = HEADERLEN + FIELDSPERFRAME *
					((UWORD)hdrptr->fh_audlen * (UWORD)hdrptr->fh_audchans);
//				hdrptr->fh_chunklen = HEADERLEN + MONOAUDFRAME;
#endif
				hdrptr->fh_vidflag = FALSE;
			}

			hdrptr->fh_frmnum = avm->m_frmsdone;

			avm->m_fallback = avm->m_prevaddr;

			if (avm->m_prevaddr == 0)
				hdrptr->fh_prevfrm = 0;
			else
				hdrptr->fh_prevfrm = avm->m_prevaddr - avm->m_saddr;	// offset

			hdrptr->fh_nextfrm = hdrptr->fh_chunklen;

			// Remember size of this color frame
			// For dual video channels, A's bufctrl.bf_datasz gets the size,
			// whether that is video from A or B
			ctrlptr->bf_datasz = hdrptr->fh_chunklen;		// Amt of SCSI data

			avm->m_prevaddr = avm->m_saddr;

			/* General header info */
			hdrptr->fh_id			= ID_CFRM;
			hdrptr->fh_version	= FLYER_VERSION;
			hdrptr->fh_vidcmpver	= VTASCversion;
			hdrptr->fh_audcmpver	= AUDIO_VERSION;

//			DBUG(print(DB_SIZE,"%b ",hdrptr->fh_fld[1-baseof_fhfld].fi_vlen);)

//			CopyMemFast(&CustomFIRcoefs,&hdrptr->fh_FIRcoefs,16);

			if (NdxCtr == 0)		// A "milestone" frame?
			{
				/* Copy backptrs array into header */
				Copy15Ptrs(&Back15Ptrs,&hdrptr->fh_backptrs,avm->m_saddr);

				/* Now add as entry in index table */
				NdxTable[NdxEnt] = avm->m_saddr;
				NdxTotal++;
				NdxEnt++;
				/* Time to save off next block in table? */
				if (NdxEnt == STONESPERBLK)
				{
					AppendNdxBlock();
					NdxEnt = 0;
				}

				for (NdxCtr=0;NdxCtr<15;NdxCtr++)
				{
					Back15Ptrs[NdxCtr] = 0;
				}
				NdxCtr = 15;
			}
			else
			{
				/* For others, just log their location into array */
				Back15Ptrs[NdxCtr-1] = avm->m_saddr;
				NdxCtr--;

				/* Copy backptrs array into header */
				Copy15Ptrs(&Back15Ptrs,&hdrptr->fh_backptrs,avm->m_saddr);
			}

//			DBUG(printchar(DB_MACH,'A');)

			/* Move frame header into place in DRAM */
			CpuXferMemWait(hdrptr,ctrlptr->bf_addr,HEADERLEN,READ);

//			DBUG(printchar(DB_MACH,'B');)

			// Make sure SCSI write(s) wont go beyond end address
			// This works correctly for dual-rec channels, as A has B's size
			// if using alternate video
			if ((avm->m_stopaddr) && ((avm->m_saddr + ctrlptr->bf_datasz +
			   NdxBlks+(1+HEADTABLESIZE+USERAREASIZE)) > avm->m_stopaddr))
			{
				DBUG(print(DB_MACH,"Beyond");)

				avm->m_prevaddr = avm->m_fallback;		// Didn't write this one!
				avm->m_error = ERR_EXHAUSTED;
				break;
			}

			// Can we use better video?
			if ((mach == 0) && (usesafevid))
			{
				DBUG(printchar(DB_MACH,'9');)

				temp = HEADERLEN + MONOAUDFRAME * avm->m_numaudchans;

				// Write out just header and any audio gathered
				avm->m_error = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_saddr,
					(APTR)ctrlptr->bf_addr,temp);

				DBUG(printchar(DB_MACH,'W');)

				if (avm->m_error == ERR_OKAY)
				{
					// Write out alternate video data
					avm->m_error = DoSCSI(
						avm->m_sdrive,SCMD_WRITE,
						avm->m_saddr+temp,
						(APTR)(ctrlalt->bf_addr+temp),
						ctrlptr->bf_datasz-temp
					);
				}
			}
			else
			{
				DBUG(printchar(DB_MACH,'8');)
				avm->m_error = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_saddr,
					(APTR)ctrlptr->bf_addr,ctrlptr->bf_datasz);
			}

			if (avm->m_error != ERR_OKAY)
			{
				avm->m_prevaddr = avm->m_fallback;	// Didn't write this one!
				break;
			}

			avm->m_frmsdone++;

			/* Mark buffer as empty now */
			ctrlptr->bf_empty = TRUE;
			if (mach == 0)
				ctrlalt->bf_empty = TRUE;


			ep->e_bufsfull--;
//			BufsFull[mach-baseof_BufsFull]--;
			DBUG(DrawBar(mach);)

			/* Update SCSI address */
			// This also works for dual-rec video (A or B)
			avm->m_saddr += ctrlptr->bf_datasz;

			/* Skip to next buffer now */
			if (mach <= HIVIDMACHNUM)
			{
				avm->m_curbuf = NextVidBufNum(avm->m_curbuf);
				avm->m_altbuf = NextVidBufNum(avm->m_altbuf);
			}
			else
			{
				avm->m_curbuf = NextAudBufNum(avm->m_curbuf);
			}
		}
		else if (avm->m_flushing)						// Flushing complete?
		{
			DBUG(printchar(DB_MACH,'7');)

			while (!(EFLG_HOLD & ep->e_flags))
			{
				DBUG(printchar(DB_TEST,'2');)
				Delay(1);				// Wait for video engine stable
			}

			goto readlast;
		}
//		else
//			Delay(1);					// Don't hog CPU waiting for next buffers
	}


stop:					// Stop video recording
	DBUG(print(DB_MACH,"20/");)
	EngineCommand(mach,AVCMD_STOPREC,0,0,&NullAudioArgs,0);		// Stop soon
	if (mach == 0)
		EngineCommand(1,AVCMD_STOPREC,0,0,&NullAudioArgs,0);		// Stop soon

readlast:			// Read last header back in - start read
	DBUG(print(DB_MACH,"21/");)

	/* If no video recorded, skip wrap-up */
	if (avm->m_prevaddr == 0)				// Don't terminate?
	{
		avm->m_stopaddr = avm->m_startaddr;		// No data collected

		if (avm->m_error != ERR_EXHAUSTED)
			avm->m_error = ERR_CMDFAILED;		// Set error (but preserve "FULL" error)
		goto finish;
	}

	/* If a fatal error occurred, skip wrap-up */
	if ((avm->m_error != ERR_OKAY) && (avm->m_error != ERR_EXHAUSTED))
	{
		goto finish;
	}

	/* Wait for video engine stable */
	while (!(EFLG_HOLD & ep->e_flags))
		Delay(1);

	/* Find a buffer that's a safe place to work */
	if (mach <= HIVIDMACHNUM)
	{
		avm->m_curbuf = NextVidBufNum(Engine[0-baseof_Engine].e_curbuf);
		ctrlptr	= &Vbufctrl[0-baseof_Vbufctrl][avm->m_curbuf];
	}
	else
	{
		avm->m_curbuf = NextAudBufNum(ep->e_curbuf);
		ctrlptr	= &Abufctrl[mach-baseof_Abufctrl][avm->m_curbuf];
	}

	/* Read in last frame header */
	err = DoSCSI(avm->m_sdrive,SCMD_READ,avm->m_prevaddr,(APTR)ctrlptr->bf_addr,HEADERLEN);
	if (err != ERR_OKAY)
	{
		avm->m_error = err;
		goto finish;
	}

	// *** Now we DMA in, modify, DMA out, Write back out ***

	if (mach <= HIVIDMACHNUM)
	{
//		ctrlptr	= &Vbufctrl[0-baseof_Vbufctrl][avm->m_curbuf];
		hdrptr	= &(*Vhdrs)[0-baseof_Vhdrs][avm->m_curbuf];
	}
	else
	{
//		ctrlptr	= &Abufctrl[mach-baseof_Abufctrl][avm->m_curbuf];
		hdrptr	= &(*Ahdrs)[mach-baseof_Ahdrs];
	}

	/* DMA header from DRAM into header buffer */
	CpuXferMemWait(hdrptr,ctrlptr->bf_addr,HEADERLEN,WRITE);

	hdrptr->fh_nextfrm = 0;					// The end!!

	/* Move header back into DRAM */
	CpuXferMemWait(hdrptr,ctrlptr->bf_addr,HEADERLEN,READ);

	err = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_prevaddr,(APTR)ctrlptr->bf_addr,HEADERLEN);

	// *** Now write out index table ***

	/***********************/
	/* Do Indexing wrap-up */
	/***********************/

	/* Add entry for last frame recorded */
	NdxTable[NdxEnt] = avm->m_prevaddr;
	NdxTotal++;
	NdxEnt++;
	AppendNdxBlock();		// Save off partial or full block

	/* Convert the index table I've been building to relatives */
	MakeRelIndices(avm->m_saddr);

	/* Now write out the index table */
	err = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_saddr+1,(APTR)TABLEDRAM,NdxBlks);
	if (err != ERR_OKAY)
	{
		avm->m_error = err;
		goto finish;
	}

	// *** Now write out TAIL header ***

	/* Manufacture a "TAIL" header for clip */
	ClearMemory(ahp,512);
	ahp->th.th_ID				= ID_TAIL;

	/* Locate index table just after this header */
	ahp->th.th_Table			= 1;
	ahp->th.th_NdxTabSize	= NdxBlks;
	ahp->th.th_NdxCount		= NdxTotal;
					
	/* Locate head list just past index table */
	ahp->th.th_HeadList		= ahp->th.th_Table+(ULONG)NdxBlks;
	ahp->th.th_HeadBlks		= HEADTABLESIZE;

	/* Locate user area just past head list */
	ahp->th.th_UserArea		= ahp->th.th_HeadList+(ULONG)ahp->th.th_HeadBlks;
	ahp->th.th_UserBlks		= USERAREASIZE;

	ahp->th.th_ChunkLen		= 1+NdxBlks+HEADTABLESIZE+USERAREASIZE;


	/* Now DMA header into DRAM */
	CpuXferMemWait(ahp,MISCDRAM+3,HEADERLEN,READ);

	/* Now write TAIL at end of clip */				
	err = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_saddr,(APTR)(MISCDRAM+3),HEADERLEN);

	/* Move clip end pointer to head/user blocks */
	avm->m_stopaddr = avm->m_saddr+1+NdxBlks;

	for (avm->m_count=0
	 ; avm->m_count < (HEADTABLESIZE+USERAREASIZE)
	 ; avm->m_count++)
	{
		/* Create data on all head blocks and first user block */
		if (avm->m_count <= HEADTABLESIZE)
		{
			hp = (struct PRIVHEADSBLOCK *) ahp;

			/* Clear a block */
			ClearMemory(hp,512);

			/* Only fill in fields in head blocks */
			if (avm->m_count < HEADTABLESIZE)
			{
				hp->ph_HeadID = ID_HEAD;
				hp->ph_Heads[0].phe_startfld = LISTEND ;

				if (avm->m_count < (HEADTABLESIZE-1))
					hp->ph_Next = 1;		// Link to more table blks
				else
					hp->ph_Next = 0;		// No link
			}

			/* Now DMA header into DRAM */
			CpuXferMemWait(hp,MISCDRAM+3,1,READ);
		}

		/* Write out another block */				
		err = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_stopaddr,(APTR)(MISCDRAM+3),1);
		if (err != ERR_OKAY)
		{
			avm->m_error = err;
			goto finish;
		}

		avm->m_stopaddr++;
	}


	/* Manufacture a "CLIP" master header for clip */

	ahp->ch.ch_id				= ID_CLIP;
	ahp->ch.ch_blksize		= 512;
	ahp->ch.ch_chunklen		= avm->m_stopaddr - avm->m_startaddr;	// Total size
	ahp->ch.ch_version		= FLYER_VERSION;
	ahp->ch.ch_vidcmpver		= VTASCversion;
	ahp->ch.ch_audcmpver		= AUDIO_VERSION;
	ahp->ch.ch_vidgrade		= VidGrade;
	ahp->ch.ch_fields			= avm->m_frmsdone * 4;
	ahp->ch.ch_datastart		= 1;		// Starts just after this header
	ahp->ch.ch_dataend		= avm->m_saddr - avm->m_startaddr;
	ahp->ch.ch_tail			= ahp->ch.ch_dataend;	// No gap to tail

	if (mach <= HIVIDMACHNUM)
		ahp->ch.ch_vidflag = TRUE;
	else
		ahp->ch.ch_vidflag = FALSE;

	if (avm->m_achan != 0)
	{
		ahp->ch.ch_audchans	= avm->m_numaudchans;
#ifdef FLYERVER3
		ahp->ch.ch_audlen	= MONOAUDFIELD * avm->m_numaudchans;
#else
		ahp->ch.ch_audlen	= MONOAUDFIELD;
#endif
	}
	else
	{
		ahp->ch.ch_audchans	= 0;
		ahp->ch.ch_audlen	= 0;
	}
	ahp->ch.ch_pedestal	= NTSC_BLANK;		// Default pedestal value
	ahp->ch.ch_FIRset		= ep->e_firset;

	/* Copy custom coefficient set into clip header */
	CopyMemFast(&CustomFIRcoefs,&ahp->ch.ch_custFIRcoefs,
		2 * sizeof(struct FIRSET));			// Pre & Post coefficients

	/* Now DMA header into DRAM */
	CpuXferMemWait(ahp,MISCDRAM+3,1,READ);

	/* Now write CLIP at start of clip */				
	err = DoSCSI(avm->m_sdrive,SCMD_WRITE,avm->m_startaddr,(APTR)(MISCDRAM+3),1);


finish:			// Wrap up
	DBUG(printchar(DB_MACH,'=');)

	while (!(EFLG_HOLD & ep->e_flags))		// Wait til stable
	{
		DBUG(printchar(DB_TEST,'3');)
		Delay(1);
	}

	ep->e_audchan = 0;							// Disconnect from audio channel
	if (mach <= HIVIDMACHNUM)
	{
		CleanupVidBuffers(0,REC);				// Throw away unused data
		CleanupVidBuffers(1,REC);				// Throw away unused data
	}
	else
		CleanupAudBuffers(mach,REC);				// Throw away unused data

	// Return more specific error codes than okay/exhausted
	if ((avm->m_error == ERR_EXHAUSTED) && (DroppedFields))
		avm->m_error = ERR_DROPPEDFLDS;

	avm->m_active = FALSE;							// Show caller we're done
}


/*
 * AppendNdxBlock - Move current index block to table in DRAM
 */
void AppendNdxBlock(void)
{
	/* Move block to DRAM */
	CpuXferMemWait(NdxTable,TABLEDRAM+NdxBlks,1,READ);
	NdxBlks++;
	ClearMemory(NdxTable,512);
}


/*
 * MakeRelIndices - Convert index table absolutes to relatives
 */
void MakeRelIndices(ULONG base)
{
	ULONG	i,j,*lp;
	UWORD	left;

	left = NdxTotal;

	for (i=0;i<NdxBlks;i++)
	{
		/* Move block from DRAM */
		CpuXferMemWait(NdxTable,TABLEDRAM+i,1,WRITE);

		lp = (ULONG *)NdxTable;
		for (j=0;j<STONESPERBLK;j++)
		{
			if (left>0)
			{
//				NdxTable[j] -= base;		// Doesn't compile index correctly!
				lp[j] -= base;
				left--;
			}
		}

		/* Move block back to DRAM */
		CpuXferMemWait(NdxTable,TABLEDRAM+i,1,READ);
	}
}


/*
 *  NextVidBufNum - return next video buffer number, with wrap-around
 */
UBYTE NextVidBufNum(UBYTE oldbuf)
{
	UBYTE	newbuf;

	newbuf = oldbuf+1;
	if (newbuf >= NUMVIDBUFS)
		newbuf = 0;

	return(newbuf);
}


/*
 *  PrevVidBufNum - return prev video buffer number, with wrap-around
 */
UBYTE PrevVidBufNum(UBYTE oldbuf)
{
	if (oldbuf == 0)
		return(NUMVIDBUFS-1);
	else
		return((UBYTE)(oldbuf-1));
}


/*
 *  GetNextVideoBuffer - return next video buffer to be used
 */
UBYTE GetNextVideoBuffer(UBYTE vchan, BOOL flush)
{
	struct ENGINE	*ep;
//	ULONG	timeout;

//	ep = &Engine[vchan-baseof_Engine];
	ep = GetEngine(vchan);

	if (flush)
	{
//		timeout = 5 * TICKSPERSEC;			// Abort after 5 seconds!

		/*** Wait for video engine to stabilize, give me next buffer ***/
		while ((ep->e_1stevent != NULL) || (ep->e_cmd == AVCMD_ADVFRM))
		{
//			DBUG(printchar(DB_INTERN,'*');)

//			if (--timeout == 0)
//			{
//				DBUG(print(DB_ALWAYS,"ABORT!\n");)
//				break;
//			}

			Delay(1);
		}

		ep->e_userbuf = NextVidBufNum(ep->e_curbuf);
//		DBUG(print(DB_OPS,"Buf %d\n",ep->e_userbuf);)
	}
	else
	{
//		DBUG(print(DB_OPS,"(Usr %d)\n",ep->e_userbuf);)
	}

	return(ep->e_userbuf);					// Next buffer that I should try to fill
}


/*
 *  GetCurVideoBuffer - return current video buffer being used
 */
UBYTE GetCurVideoBuffer(UBYTE vchan)
{
	struct ENGINE	*ep;

	/*** Wait for video engine to stabilize ***/
	ep = WaitEngineDone(vchan);

	return(ep->e_curbuf);
}


/*
 *  WaitEngineDone - wait until video engine finishes all events and is holding
 */
struct ENGINE * WaitEngineDone(UBYTE vchan)
{
	struct ENGINE	*ep;
	ULONG	timeout;

//	ep = &Engine[vchan-baseof_Engine];
	ep = GetEngine(vchan);

	timeout = 5 * TICKSPERSEC;			// Abort after 5 seconds!

	/*** Wait for video engine to stabilize, give me current buffer ***/
	while ((ep->e_1stevent != NULL) || (ep->e_cmd == AVCMD_ADVFRM))
	{
//		DBUG(printchar(DB_INTERN,'*');)
		DBUG(print(DB_INTERN,"(%b) evnt:%l cmd:%b\n",vchan,ep->e_1stevent,ep->e_cmd);)

		if (--timeout == 0)
		{
			DBUG(print(DB_ALWAYS,"ABORT!\n");)
			break;
		}

		Delay(1);
	}

	return(ep);
}


///*
// *  WaitEngineIdle - wait until engine goes idle
// */
//void WaitEngineIdle(UBYTE eng)
//{
//	struct ENGINE	*ep;
//	ULONG	timeout;
//
////	ep = &Engine[eng-baseof_Engine];
//	ep = GetEngine(eng);
//
//	timeout = 5 * TICKSPERSEC;			// Abort after 5 seconds!
//
//	// Wait for engine to finish last command and go idle
//	while ((!(EFLG_HOLD & ep->e_flags)) || (ep->e_1stevent))
//	{
//		DBUG(printchar(DB_MACH,'*');)
//
//		if (--timeout == 0)
//		{
//			DBUG(print(DB_ALWAYS,"ABORT!\n");)
//			break;
//		}
//
//		Delay(1);
//	}
//}


/*
 *  BumpUserVidBufNum - Bump user buffer number -- take it
 */
void BumpUserVidBufNum(struct ENGINE *ep)
{
	ep->e_userbuf = NextVidBufNum(ep->e_userbuf);
}


/*
 *	 InitCompressor - Initialize Video (De)compressors
 */
void InitCompressor(UBYTE vchan)
{
	register struct VTASC_CHANNEL *vtc;
	UBYTE	zero = 0;

	vtc = &VTASC_serchips[vchan];

	vtc->ENABLE = zero;
	vtc->RNDBIT = zero;
	vtc->RNDSEED = zero;
	vtc->ENABLE = VTEF_ClrErrors | VTEF_ClrFIFO;
}


/*
 *	 SetupCompressor - Setup Video (De)compressors
 */
void SetupCompressor(UBYTE	vchan,
							UBYTE	rnden,
							UBYTE	seed)
{
	register struct VTASC_CHANNEL *vtc;
	UBYTE	zero = 0;

	vtc = &VTASC_serchips[vchan];

	vtc->ENABLE = zero;
	vtc->RNDBIT = rnden;
	vtc->RNDSEED = seed;
	vtc->ENABLE = VTEF_ClrErrors | VTEF_ClrFIFO;
}


/*
 *  InitFixedVidBufs - Initialize fixed buffer structures
 */
void InitFixedVidBufs(UBYTE mach)
{
	struct FBUF			*bfp;
	UWORD	i;
	ULONG	addrptr;
	ULONG	sizeeach;

	sizeeach	= VBUFSIZE;
	addrptr	= VID0DRAM + (mach * VBUFSIZE * NUMVIDBUFS);

	for (i=0;i<NUMVIDBUFS;i++)
	{
		bfp = &Vbufctrl[mach-baseof_Vbufctrl][i];
		bfp->bf_empty		= TRUE;
		bfp->bf_addr		= addrptr;
		bfp->bf_lastaddr	= addrptr + (sizeeach-1);
		bfp->bf_ptr	= bfp->bf_addr;

		addrptr = addrptr + sizeeach;
	}
//	Engine[mach-baseof_Engine].e_bufsfull = 0;
	((struct ENGINE *)GetEngine(mach))->e_bufsfull = 0;

//	BufsFull[mach-baseof_BufsFull] = 0;
	DBUG(DrawBar(mach);)
}


/*
 *  CleanupVidBuffers - Clears all buffers except active
 */
void CleanupVidBuffers(	UBYTE	eng,
								BOOL	mode)
{
	struct FBUF		*bfp;
	struct ENGINE	*ep;
	UWORD	i;
	UBYTE	cur;
	UBYTE	count;

//	ep = &Engine[eng-baseof_Engine];
	ep = GetEngine(eng);

	cur = ep->e_curbuf;

	ep->e_userbuf = ep->e_curbuf;

	count = 0;
	for (i=0;i<NUMVIDBUFS;i++)
	{
		bfp = &Vbufctrl[eng-baseof_Vbufctrl][i];
		if (i == cur)
		{
			if (mode == PLAY)
			{
				bfp->bf_empty = FALSE;
				BumpUserVidBufNum(ep);
// Not really needed, as we clear just before start of frame
//				bfp->bf_flags &= ~BFF_BADVID;
				count++;
			}
			else
			{
				bfp->bf_empty = TRUE;
			}
		}
		else
		{
			bfp->bf_empty = TRUE;
		}
	}
	ep->e_bufsfull = count;
//	BufsFull[eng-baseof_BufsFull] = count;
	DBUG(DrawBar(eng);)
}


/*
 *  InitAVMachine - Initialize the Audio/Video Play/Rec Machine for use
 */
void InitAVMachine(UBYTE mach)
{
	struct MACHINE		*avm;

	avm = &AVmachine[mach-baseof_AVmachine];
//	avm->m_state	= 1;				// Start state machine
	avm->m_break	= FALSE;			// Dont abort
//	avm->m_die		= FALSE;			// Dont abort
	avm->m_active	= TRUE;			// Actively processing
	avm->m_error	= 0;				// No error
	avm->m_flags	= 0;

//	avm->m_splitout = FALSE;		// Default: not an audio split
//	avm->m_splitwait= FALSE;

	avm->m_OrderPtr = NULL;			// By default, there's no order mechanism
}


/*
 *  VideoIRQ_Handler - Video A&B (de)compressor interrupt handler
 */
void VideoIRQ_Handler(void)
{
	register struct VTASC_CHANNEL *vtc = VTASC_serchips;
//	TimerRouter *tr = TR_serchip;
//	struct ENGINE	*ep;
	WORDBITS	irqbits;
//	BOOL	sig0,sig1;
//	UBYTE	line,howlate;

//	printchar(DB_ALWAYS,'6');

//	GettingIRQ6 = TRUE;

//	sig0 = FALSE;
//	sig1 = FALSE;

//	/* Get line number */
//	line = ((SerRead(&tr->FLBITS) & 0x3F) * 8) + (SerRead(&tr->LN3BITS) & 0x7);

	irqbits = _3Port->IrqCtrl;

	if (IRQF_VIDEOA & irqbits)			// Video A done
	{
		vtc[0].VIRQ = VTIF_ClrIrq;				// Clear IRQ

//		VTLINE_A = line;
//		DBUG(LateBar(0,line);)
//		DBUG(printchar(DB_IRQ,'A');)
//
//		ep = &Engine[0-baseof_Engine];
//		if (ep->e_late)
//		{
//			ep->e_late	= FALSE;
//			if ((line < 200) && (ep->e_latecnt < 4))		// A little late?
//			{
//				ep->e_latecnt++;											// Soft-starts in a row
//				DBUG(printchar(DB_ALARMS,'(');)
//				howlate	= 2;
//			}
//			else
//			{
//				ep->e_latecnt = 0;
//				ep->e_adjust = TRUE;			// Too late, drop a field
//				howlate	= 3;
//			}
//		}
//		else
//		{
//			if (line > RecBiasLine)		// Getting too ong to play?
//				//DBUG(printchar(DB_ALARMS,':');)
//				howlate = 4;				// Just bump tolerance
//			else
//				howlate = 0;
//		}
//		Arunning = TRUE;
//		sig0 = DoEngine(ep,howlate);
	}

	if (IRQF_VIDEOB & irqbits)			// Video B done
	{
		vtc[1].VIRQ = VTIF_ClrIrq;			// Clear IRQ

//		LateBar(1,line);
//		DBUG(printchar(DB_IRQ,'B');)
//
//		ep = &Engine[1-baseof_Engine];
//		if (ep->e_late)
//		{
//			ep->e_late	= FALSE;
//			if ((line < 200) && (ep->e_latecnt < 4))		// A little late?
//			{
//				ep->e_latecnt++;											// Soft-starts in a row
//				DBUG(printchar(DB_ALARMS,')');)
//				howlate	= 2;
//			}
//			else
//			{
//				ep->e_latecnt = 0;
//				ep->e_adjust = TRUE;			// Too late, drop a field
//				howlate	= 3;
//			}
//		}
//		else
//		{
//			if (line > RecBiasLine)		// Getting too ong to play?
//				DBUG(printchar(DB_ALARMS,';');)
//				howlate = 4;				// Just bump tolerance
//			else
//				howlate = 0;
//		}
//		Brunning = TRUE;
//		sig1 = DoEngine(ep,howlate);
	}
}


/*
 *  FieldIRQ_Handler - Interrupt routine to maintain internal frame clock
 */
void FieldIRQ_Handler(void)
{
	TimerRouter *tr = TR_serchip;
	UBYTE		flbits;
	BYTEBITS	irqbits;
	UBYTE		zero = 0;
	UBYTE		line;
	BOOL		haveline = FALSE;

//	DBUG(printchar(DB_IRQ,'4');)

	irqbits = SerRead(&tr->VIDIRQ);

//	DBUG(print(DB_VIDEO3," %b",irqbits);)

	if (VIRQF_FIELD & irqbits)					// Vertical interrupt(s)
	{
		tr->FLBITS = zero;							// Clear interrupt bit

		flbits = SerRead(&tr->FLBITS);

		/* Detect special "just-started video" IRQ on Rev 4 board */
		if ((flbits & 0x3F)>7)
		{
#if FIELDTASKS
			// Seems to cause field alignment problems, manifesting themselves
			// as interlace and color-frame errors
			SignalIRQ(FieldTask,SIGF_IRQ2);
#else
			middleoffield();
#endif
			DBUG(printchar(DB_IRQ,'m');)
		}
		else			// Top-of-field interrupt
		{
			CurrentField = flbits >> 6;				// Update field counter

#if FIELDTASKS
			// Seems to cause field alignment problems, manifesting themselves
			// as interlace and color-frame errors
			SignalIRQ(FieldTask,SIGF_IRQ);
#else
			topoffield();
#endif

//			DBUG(ClrLEDs(0x02);)

			DBUG(printchar(DB_IRQ,'t');)
		}
	}

//	/* Get line number (only if needed) */
//	if ((VIRQF_VIDEOA | VIRQF_VIDEOB) & irqbits)
//		line = (SerRead(&tr->LN3BITS) & 0x7) + ((SerRead(&tr->FLBITS) & 0x3F) * 8);

	irqbits = SerRead(&tr->VIDIRQ);		// Regrab, in case Vid IRQ occurred recently???

	if (VIRQF_VIDEOA & irqbits)							// Video A done
	{
		if (!haveline)
		{
			line = (SerRead(&tr->LN3BITS) & 0x7) + ((SerRead(&tr->FLBITS) & 0x3F) * 8);
			haveline = TRUE;
		}
		VTLINE_A = line;

		tr->HORBITS = zero;							// Clr bit

#if VIDEOTASKS
		SignalIRQ(VideoDriver0,SIGF_QUEUE);
#else
		// Seems to cause occasional video glitching when the CPU is very
		// busy (CPU not waiting on play to finish).  Doesn't happen if
		// task is waiting on finish, or if we use the VideoDriversx tasks
		dovidstuff(&Engine[0-baseof_Engine]);
#endif

//		DBUG(printchar(DB_IRQ,'a');)
	}

	irqbits = SerRead(&tr->VIDIRQ);		// Regrab, in case Vid IRQ occurred recently???

	if (VIRQF_VIDEOB & irqbits)							// Video B done
	{
		if (!haveline)
		{
			line = (SerRead(&tr->LN3BITS) & 0x7) + ((SerRead(&tr->FLBITS) & 0x3F) * 8);
			haveline = TRUE;
		}

		VTLINE_B = line;

		tr->LN3BITS = zero;							// Clr bit

#if VIDEOTASKS
		SignalIRQ(VideoDriver1,SIGF_QUEUE);
#else
		// Seems to cause occasional video glitching when the CPU is very
		// busy (CPU not waiting on play to finish).  Doesn't happen if
		// task is waiting on finish, or if we use the VideoDriversx tasks
		dovidstuff(&Engine[1-baseof_Engine]);
#endif

//		DBUG(printchar(DB_IRQ,'b');)
	}

	/* Show loss of sync on LED (unless other bar using LED's) */
	/* For time effeciency, don't write except to change LED */

	if ((UPF_GENLOCKED & irqbits) && (SyncProblem == 0))
	{
		/* Have sync, but did we just regain it? */
		if (NoSyncLast)
		{
			DBUG(print(DB_ALWAYS,"CP");)
			EnsureColorPhase();
			NoSyncLast = FALSE;
		}
		if ((BarType == 99) && (NoSyncLED))
		{
			ClrLEDs(LED_SyncLost);
			NoSyncLED = FALSE;
		}
	}
	else
	{
		/* Do not have sync */
		SyncNoise = TRUE;
		NoSyncLast = TRUE;

		if ((BarType == 99) && (NoSyncLED == FALSE))
		{
			SetLEDs(LED_SyncLost);
			NoSyncLED = TRUE;
		}

		if (SyncProblem)			// Time one-shot to clear LED
			SyncProblem--;
	}
}


/*
 * FieldTaskProc - task to perform things at top- and mid-field
 */
static void __regargs FieldTaskProc(ULONG arg)
{
	DBUG(print(DB_ALWAYS,"FieldTask alive\n");)

	for (;;)
	{

		/**************************************/
		/*** Wait til mid-field and do work ***/
		/**************************************/

		// Go to sleep until top of field
		Wait(SIGF_IRQ);

		DBUG(printchar(DB_IRQ,'t');)

		topoffield();

		/**************************************/
		/*** Wait til mid-field and do work ***/
		/**************************************/

		// Go to sleep until mid-field
		Wait(SIGF_IRQ2);

		DBUG(printchar(DB_IRQ,'m');)

		middleoffield();

	}
}


/*
 * topoffield - do TOF stuff
 */
static void topoffield(void)
{
	struct ENGINE	*ep;
	UBYTE		vidfld;
	UBYTE		eng;
	BOOL		wrongfld;

	vidfld = CurrentField;

	FieldClock++;
	if ((vidfld == 1) && ((FieldClock & 3)!=0))
	{
		FieldClock &= ~3;
		DBUG(printchar(DB_ALARMS,'z');)
	}

	if (WhichIRQ == 0)		// 2 TOF's w/o an intervening MOF?
	{
		DBUG(print(DB_ALWAYS,"T!");)
		SyncNoise = TRUE;
		SyncProblem = 60;		// Stay on for 1 more second
	}
	WhichIRQ = 0;

	/* Flip SMPTE buffers (double-buffered) */
	RxAfill = 1-RxAfill;
	SMPTEa[RxAfill].sb_Index = 0;		// Reset new buffer

	DBUG(
		printchar(DB_VIDEO2,'^');
		printchar(DB_VIDEO2,vidfld+'0');
	)

	/* Do any DSP changes that are due on this field */
	DoAudioEvents(FieldClock);

	/* Determine if any audio engine needs adjusted to be in phase w/video */
	/* e_field will be ++ before doing audio on this field */
	ep = &Engine[LOAUDMACHNUM-baseof_Engine];
	for (eng=LOAUDMACHNUM ; eng<=HIAUDMACHNUM ; eng++,ep++)
	{
		wrongfld = FALSE;
		if (VideoMode == VM_PLAY)
		{
			if ((CurrentField & 3) != (ep->e_field & 3))
				wrongfld = TRUE;
		}
		else if (VideoMode == VM_RECORD)
		{
			if (CurrentField != ((ep->e_field+1) & 3))
				wrongfld = TRUE;
		}

		if (wrongfld)
		{
			DBUG(
				printchar(DB_ALARMS,'*');
				printchar(DB_ALARMS,eng+'0');
			)
			ep->e_adjust = TRUE;			// Drop a field
		}
	}

	/* Record audio data from DSP for audio w/video */
	/* NOTE: this will break if a video field compresses faster than 2:1 */
	if (VideoMode == VM_RECORD)
	{
		ep = &Engine[LOVIDMACHNUM-baseof_Engine];
		for (eng=LOVIDMACHNUM ; eng<=HIVIDMACHNUM ; eng++,ep++)
/*R*/		AudioMachine(ep->e_audchan,eng,ep->e_field,ep->e_curbuf,HEADERLEN,0);
	}

	/* Handle audio-only machines */
	ep = &Engine[LOAUDMACHNUM-baseof_Engine];
	for (eng=LOAUDMACHNUM ; eng<=HIAUDMACHNUM ; eng++,ep++)
	{
		DoEngine(ep,0);					// No audio soft-start
	}

	ep = &Engine[LOVIDMACHNUM-baseof_Engine];
	for (eng=LOVIDMACHNUM ; eng<=HIVIDMACHNUM ; eng++,ep++)
	{
		if (EFLG_KICKME & ep->e_flags)		// Start-up video interrupt stream?
		{
			if ((ep->e_dir == PLAY) && (vidfld == KickOffFld))		// Is it time?
			{
				EndDma(VID2DMA(eng));					// Reset DMA
				StartVid(ep,WRITE,FALSE);
				ep->e_flags &= ~EFLG_KICKME;
			}
			else if ((ep->e_dir == REC) && (vidfld == (KickOffFld+1)))	// Is it time?
			{
				EndDma(VID2DMA(eng));					// Reset DMA
				StartVid(ep,READ,FALSE);
				ep->e_flags &= ~EFLG_KICKME;
			}
		}
	}

	// Send any switcher events that are due on the next field
	// This does nothing on a Flyer (it has no Switcher)
	DoSwitcherEvents(FieldClock);

	// Let sequencer perform housekeeping
	SequenceStatus(FieldClock);
}


/*
 * middleoffield - do MOF stuff
 */
static void middleoffield(void)
{
	struct ENGINE	*ep;
	BYTEBITS	vidbits;
	UBYTE		eng,nextfld;
	BOOL		wrongfld;
//	UWORD		i;


	if (WhichIRQ == 1)		// 2 MOF's w/o an intervening TOF?
	{
		DBUG(print(DB_ALWAYS,"M!");)
		SyncNoise = TRUE;
		SyncProblem = 60;		// Stay on for 1 more second
	}
	WhichIRQ = 1;

	/* Determine if either video channel just started the wrong field */
	/* Indicates a major overrun condition */
	ep = &Engine[LOVIDMACHNUM-baseof_Engine];
	for (eng=LOVIDMACHNUM ; eng<=HIVIDMACHNUM ; eng++,ep++)
	{
//		DBUG(
//			// No DMA happening?  This looks like a problem!
//			if (DmaDone(VID2DMA(eng)))
//				print(DB_ALWAYS,"BOOM%d",eng);
//		)

		wrongfld = FALSE;
		if (VideoMode == VM_PLAY)
		{
			nextfld = (CurrentField+1) & 0x3;	// Next field # 
			if (nextfld != (ep->e_field & 0x3))
				wrongfld = TRUE;
		}
		else if (VideoMode == VM_RECORD)
		{
			if (CurrentField != ((ep->e_field+0) & 0x3))
				wrongfld = TRUE;
		}

		if (wrongfld)
		{
			DBUG(
				if (eng==0)
					printchar(DB_ALARMS,'\'');
				else
					printchar(DB_ALARMS,'"');
			)
			if (ep->e_syncup)
			{
				DBUG(printchar(DB_ALARMS,'s');)
				ep->e_adjust = TRUE;			// Adjust to new record mode
			}
			else if (DmaClogged(VID2DMA(eng)))
			{
				/* DMA stopped while compressor has more data */
				/* Make compressor soft-start to avoid death */
				DBUG(printchar(DB_ALARMS,'*');)
				DoEngine(ep,1);					// Soft start
			}
			else	/* Late! */
			{
				ep->e_late = TRUE;		// Handle when video finishes
//				ep->e_latecnt++; (???!!!)
				DBUG(
					if (eng==0)
						printchar(DB_ALARMS,'{');
					else
						printchar(DB_ALARMS,'[');
				)
			}
		}
		else
		{
			vidbits = SerRead(&VTASC_serchips[eng].STATUS);

			ep->e_latecnt = 0;

			/* Did we just miss the hardware start? */
			if ((!(VTST_GO & vidbits))		// Must be active!!
			&& (EFLG_ACTIVE & ep->e_flags))
			{
				if (ep->e_dir == PLAY)
					StartVid(ep,WRITE,TRUE);			// Re-start!
				else
					StartVid(ep,READ,TRUE);			// Re-start!

				DBUG(
					if (eng==0)
						printchar(DB_ALARMS,'}');
					else
						printchar(DB_ALARMS,']');
				)
			}

			if (Arunning && Brunning)
			{
				ep->e_syncup = FALSE;
			}
		}
	}
}


/*
 * VideoDriverProc - task to keep video chips running
 */
static void __regargs VideoDriverProc(ULONG arg)
{
#if VIDEOTASKS
	struct ENGINE	*ep;
	UBYTE	chan;

	chan = (UBYTE)arg;

	DBUG(print(DB_ALWAYS,"VidDriverTask %b alive\n",chan);)

//	ep = &Engine[chan-baseof_Engine];
	ep = GetEngine(chan);

	for (;;)
	{

		/**********************************************************/
		/*** Wait for signal that video channel needs attention ***/
		/**********************************************************/

		// Go to sleep until top of field
		Wait(SIGF_QUEUE);

		dovidstuff(ep);
	}
#endif
}


/*
 * dovidstuff - do stuff for video chip set
 */
static void dovidstuff(struct ENGINE *ep)
{
	UBYTE	chan,howlate,line;
//	static UBYTE rndA = 0,rndB = 0;

	chan = ep->e_engnum;

	line = (chan==0)?VTLINE_A:VTLINE_B;

//	DBUG(
//		if (chan==0)
//		{
//			if ((++rndA & 63) == 0)
//				print(DB_CLIP,"%b ",line);
//		}
//		else
//		{
//			if ((++rndB & 63) == 0)
//				print(DB_PROJECT,"%b ",line);
//		}
//	)

	DBUG(LateBar(chan,line);)

	DBUG(printchar(DB_IRQ,'a'+chan);)

	if (ep->e_late)
	{
		ep->e_late	= FALSE;
		if ((line < 200) && (ep->e_latecnt < 4))		// A little late?
		{
			ep->e_latecnt++;											// Soft-starts in a row
			DBUG(printchar(DB_ALARMS,'('+chan);)
			howlate	= 2;
		}
		else
		{
			// Video data is probably unusable
			Vbufctrl[chan-baseof_Vbufctrl][ep->e_curbuf].bf_flags |= BFF_BADVID;
			DBUG(printchar(DB_ALARMS,'=');)

			ep->e_latecnt = 0;
			ep->e_adjust = TRUE;			// Too late, drop a field
			howlate	= 3;
		}
	}
	else
	{
//		if (line > RecBiasLine)		// Getting too ong to play?
//			DBUG(printchar(DB_ALARMS,':');)
//			howlate = 4;				// Just bump tolerance
//		else
			howlate = 0;
	}

	if (chan==0)
		Arunning = TRUE;
	else
		Brunning = TRUE;

	DoEngine(ep,howlate);
}


/*
 * LateBar - Display compression finish time on LED's
 */
void LateBar(	UBYTE	eng,
					UBYTE	line)
{
DBUG(
	UBYTE	late;

	DoneLine[eng] = line;

	line >>= 3;

	if (line<5)
		late = 1;
	else if (line > 18)
		late = 8;
	else
		late = (line-3) / 2;				// 17 = 7 LED's

	Lateness[eng] = late;
	DrawBar(2+eng);
)
}


/*
 *  GetFieldClock - Read field clock and return value
 */
ULONG GetFieldClock(void)
{
	return(FieldClock);
}


/*
 * KillVideo - Kill video engines
 */
UBYTE KillVideo(void)
{
	ULONG	timeout;
	struct ENGINE	*ep0,*ep1;

	ep0 = &Engine[0-baseof_Engine];
	ep1 = &Engine[1-baseof_Engine];

	/* Tell engines to quit */
	ep0->e_flags |= EFLG_BREAK;
	ep1->e_flags |= EFLG_BREAK;

	/* Wait til both stopped */
	timeout = 100000;
	while ((EFLG_ACTIVE & ep0->e_flags) || (EFLG_ACTIVE & ep1->e_flags))
	{
		if (--timeout == 0)
			return(ERR_CMDFAILED);
	}

	return(ERR_OKAY);
}


/*
 * RecordMode - Put Flyer in Record Mode
 */
void RecordMode(void)
{
	struct FBUF		*bfp;
	struct ENGINE	*ep;
	UBYTE	eng;
	ULONG	count,timeout;

	// *************
	// *** Check ***
	// *************

	if (VideoMode == VM_RECORD)
		return;

	if (VideoMode == VM_PLAY)
		KillVideo();					// Shut down play engine

	VideoMode = VM_RECORD;

	/**** Eventually, we should do the following ourselves ****/

	/* Download both sets of M/P Coders */

	/* Setup serial registers with routing & settings for rec mode */
	TR_serchip->MUXCTRL = 0xF0;

	SetVideoOffset(0,RecOffsetA);
	SetVideoOffset(1,RecOffsetB);

	/* Select camcorder reference input */
//	Skew_serchip->ROUTE = 0x80;		// Camcorder input
//	Skew_serchip->ROUTE = 0x21;		// Toaster input 2
//	Skew_serchip->ROUTE = 0x20;		// Toaster input 1

	DownloadFIRpresets(PRECOMP);		// Download FIR presets for record

	AudioRecMode();						// Set DSP into record mode

	/* Only doing this because DSP code needs lots of time to stabilize */
	/* When fixed, enable the channel we get allocated, just before */
	/* beginning record session */
//	AudioEnable(AUDRECCHAN);			// Enable record channel


	// *************
	// *** Start ***
	// *************

	ep = &Engine[LOVIDMACHNUM-baseof_Engine];
	for (eng=LOVIDMACHNUM ; eng<=HIAUDMACHNUM ; eng++,ep++)
	{
		ep->e_dir		= REC;
		ep->e_cmd		= AVCMD_LIVE;
		ep->e_duration	= 0;		// Must clear this, as non-0 here can mess up recording!
		ep->e_curbuf	= 0;
		ep->e_userbuf	= 0;
		ep->e_field		= 1;				// Ready for field 1
		ep->e_flags 	|= EFLG_ACTIVE;
		ep->e_flags 	&= ~EFLG_BREAK;
		ep->e_adjust	= FALSE;
		ep->e_late		= FALSE;
		ep->e_syncup	= TRUE;
		ep->e_latecnt	= 0;
		ep->e_dropflds	= 0;
		Arunning = FALSE;
		Brunning = FALSE;
		ep->e_error		= 0;
		ep->e_numaudchans = 2;

		/* Routines below will not work right if we have already set mode */
		/* Investigate and fix this!!! */
		VideoMode = VM_NADA;
		if (eng <= HIVIDMACHNUM)
		{
			InitFixedVidBufs(eng);

			/* Prepare for first compress */
			bfp = &Vbufctrl[eng-baseof_Vbufctrl][ep->e_curbuf];
			bfp->bf_ptr = bfp->bf_addr + HEADERLEN + MONOAUDFRAME * ep->e_numaudchans;
		}
		else
		{
			InitAudioBuffers(eng,1,TRUE);

			/* Prepare for first compress */
			bfp = &Abufctrl[eng-baseof_Abufctrl][ep->e_curbuf];
			bfp->bf_ptr = bfp->bf_addr + HEADERLEN;
		}
		VideoMode = VM_RECORD;

		/* Load prefs for version of VTASC */
		if (eng <= HIVIDMACHNUM)
			PreloadEngPrefs(eng,VTASCversion);
	}
		
	for (eng=LOVIDMACHNUM;eng<=HIVIDMACHNUM;eng++)
	{
		FirstField(eng);						// Start video stream
	}

	DBUG(print(DB_ALWAYS,"Rec...");)


	if (HighSpeedVTASC|VeryHSVTASC)
	{	
		if (VeryHSVTASC)
			SpeedUpChips(3);
		else
			SpeedUpChips(2);
		
	}

	// *****************
	// *** Calibrate ***
	// *****************

	count	= 0;
	timeout	= 0;

	do
	{
		count++;
		timeout++;

		if (SyncNoise)
		{
			SyncNoise = FALSE;
			count = 0;
			DBUG(printchar(DB_ALWAYS,'z');)
		}
	} while ((count < NOISEWAIT) && (timeout < SYNCTIMEOUT));

	DBUG(print(DB_ALWAYS,"Cal!\n");)

	SetVideoSkew(2,&RecSkew);

//	Skew_serchip->ROUTE = 0x62;	// Sync from Toaster again
//	TR_serchip->MapRamFlags = zero;	// Enable FIR now
}


/*
 * PreloadEngPrefs - load prefs into Engine
 */
static void PreloadEngPrefs(	UBYTE	eng,
										UBYTE	ver)
{
	struct ENGINE	*ep;
	struct PREFS	*pp;
	UBYTE	maxD2tol;

	if (ver == VTASC_OLDD2)
		maxD2tol = 3;
	else
		maxD2tol = 1;

//	ep = &Engine[eng-baseof_Engine];
	ep = GetEngine(eng);
	pp = &prefs[ver-baseof_prefs];

	ep->e_vlen		= pp->p_len;
	ep->e_vmaxlen	= pp->p_maxlen;
	ep->e_llim		= ep->e_vlen - (ep->e_vlen / 5);
	ep->e_tol		= pp->p_tol;
	ep->e_rndbit	= pp->p_bits;
	ep->e_rndfrq	= pp->p_freq;
	ep->e_rndseed	= pp->p_seed;
	ep->e_firset	= pp->p_firset;

	PickFirSet(eng,ep->e_firset);			// Set FIR set in hardware

	MinAlgo	= pp->p_mintol / 4;
	MaxAlgo	= pp->p_maxtol / 4;

	ep->e_algo		= MinAlgo;

	MinTols[0] = pp->p_mintol;
	if (pp->p_maxtol > maxD2tol)
		MaxTols[0] = maxD2tol;
	else
		MaxTols[0] = pp->p_maxtol;

	if (pp->p_mintol < 4)
		MinTols[1] = 0;
	else
		MinTols[1] = pp->p_mintol-4;

	MaxTols[1] = pp->p_maxtol-4;
}


/*
 * PlayMode - Put Flyer in Play Mode
 */
void PlayMode(void)
{
	struct FBUF		*bfp;
	struct ENGINE	*ep;
	UBYTE	eng;
	ULONG	count,timeout;

	// *************
	// *** Check ***
	// *************

	if (VideoMode == VM_PLAY)
		return;

	if (VideoMode == VM_RECORD)
		KillVideo();					// Shut down record engine

	VideoMode = VM_PLAY;

	/**** Eventually, we should do the following ourselves ****/

	/* Download both sets of M/P Decoders */
	/***** Currently done by library ******/

	/* Setup serial registers with routing & settings for play mode */
	TR_serchip->MUXCTRL = 0x0D;			// A->0  B->1

	SetVideoOffset(0,PlayOffsetA);
	SetVideoOffset(1,PlayOffsetB);

	/* Select reference input/pass preview */
//	Skew_serchip->ROUTE = 0x20;

	DownloadFIRpresets(POSTCOMP);		// Download FIR presets for play
	/* Select 033 for both FIR channels */
	/* Improve this later to change on the fly, based on fi_firset */
	PickFirSet(0,2);
	PickFirSet(1,2);

	AudioPlayMode();						// Set DSP into play mode


	// ************************
	// *** Make Matte black ***
	// ************************

	if (VTASCversion == VTASC_OLDD2)
		CreateMatteField((const UBYTE *)&OLDBLACKSEQ);
	else
		CreateMatteField((const UBYTE *)&NEWBLACKSEQ);

	ep = &Engine[LOVIDMACHNUM-baseof_Engine];
	for (eng=LOVIDMACHNUM ; eng<=HIAUDMACHNUM ; eng++,ep++)
	{
		ep->e_dir		= PLAY;
		ep->e_flags 	|= EFLG_ACTIVE;
		ep->e_flags 	&= ~EFLG_BREAK;
		ep->e_adjust	= FALSE;
		ep->e_late		= FALSE;
		ep->e_syncup	= TRUE;
		ep->e_latecnt	= 0;
		ep->e_dropflds	= 0;
		Arunning = FALSE;
		Brunning = FALSE;
		ep->e_error		= 0;
		ep->e_curbuf	= 0;
		ep->e_userbuf	= 0;
		ep->e_field		= 1;

		/* Routines below will not work right if we have already set mode */
		/* Investigate and fix this!!! */
		VideoMode = VM_NADA;
		if (eng <= HIVIDMACHNUM)
		{
			InitFixedVidBufs(eng);
			MakeMatteFrame(eng,ep->e_curbuf);		// (Bumps e_userbuf)
		}
		else
		{
			InitAudioBuffers(eng,1,TRUE);		// Looks at VideoMode!
			bfp = &Abufctrl[eng-baseof_Abufctrl][0];
			bfp->bf_empty = FALSE;				// Fake data is here
			bfp->bf_flags = 0;					// Points inside buffer area

			BumpUserVidBufNum(ep);					// Start just after fake data

			ep->e_bufsfull++;
//			BufsFull[eng-baseof_BufsFull]++;
			DBUG(DrawBar(eng);)
		}

		VideoMode = VM_PLAY;

		ep->e_cmd = ep->e_stillcmd;
	}

	for (eng=LOVIDMACHNUM;eng<=HIVIDMACHNUM;eng++)
	{
		FirstField(eng);							// Start video stream
	}

	DBUG(print(DB_ALWAYS,"Play...");)



	if (HighSpeedVTASC|VeryHSVTASC)
	{	
		if (VeryHSVTASC)
			SpeedUpChips(3);
		else
			SpeedUpChips(2);
	
	}	

	// *****************
	// *** Calibrate ***
	// *****************

	count	= 0;
	timeout	= 0;

	do
	{
		count++;
		timeout++;

		if (SyncNoise)
		{
			SyncNoise = FALSE;
			count = 0;
			DBUG(printchar(DB_ALWAYS,'z');)
		}
	} while ((count < NOISEWAIT) && (timeout < SYNCTIMEOUT));

	DBUG(print(DB_ALWAYS,"Cal!\n");)

	SetVideoSkew(0,&PlaySkewA);
	SetVideoSkew(1,&PlaySkewB);

//	Align_serchip->DACACTRL = zero;
//	Align_serchip->DACBCTRL = 0x01;

//	Skew_serchip->ROUTE = 0x62;		// Sync from Toaster again
//	TR_serchip->MapRamFlags = zero;		// Enable FIR now

	FullyUp = TRUE;					// Start LED sweeper (if not already)
}


/*
 * NoMode - Put Flyer in neither Play or Record Mode
 */
UBYTE NoMode(void)
{
	UWORD	i;
	UBYTE	err;

	AbortSequence();			// In case something's playing, better let it stop gracefully

	err = KillVideo();
	if (err == ERR_OKAY)
	{
		VideoMode = VM_NADA;

		for (i=1;i<=NUMAUDCHANS;i++)		// Isn't this just a hack!?!!!
		{
			AudioDisable(i);
		}

//		/* Tell all engines to disable audio */
//		for (eng=LOVIDMACHNUM ; eng<=HIAUDMACHNUM ; eng++)
//		{
//			EngineCommand(eng,AVCMD_AUDCHG,0,0,&NullAudioArgs,0);	// Disable audio
//		}
//
//		for (eng=LOVIDMACHNUM ; eng<=HIAUDMACHNUM ; eng++)
//		{
//			WaitEngineDone(eng);									// Wait to "take"
//		}
	}

	return(err);
}


/*
 * SetStillMode - Select choice of still modes (1,2,4)
 */
UBYTE SetStillMode(	UBYTE	vchan,
							UBYTE	mode)
{
	UBYTE	cmd;

	switch (mode)
	{
		case 1:	cmd = AVCMD_FIELD;		break;
		case 2:	cmd = AVCMD_2FIELD;	break;
		case 4:	cmd = AVCMD_COLOR;		break;
		default:
			return(ERR_BADPARAM);
	}

//	Engine[vchan-baseof_Engine].e_stillcmd = cmd;
//	((struct ENGINE *)GetEngine(vchan))->e_stillcmd = cmd;
	((struct ENGINE *)GetEngine(0))->e_stillcmd = cmd;
	((struct ENGINE *)GetEngine(1))->e_stillcmd = cmd;

	gl_FldOffset = vchan;

	return(ERR_OKAY);
}


/*
 * MakeMatteFrame - Use our matte field that is in DRAM
 */
void MakeMatteFrame(	UBYTE	mach,
							UBYTE	buf)
{
	struct ENGINE	*ep;
	struct FRAMEHDR	*fhp;
	struct FBUF			*bfp;
	struct FLDINFO		*fip;
	UWORD	i;
	UWORD	addr;
//	UWORD	sz;

//	ep = &Engine[mach-baseof_Engine];
	ep = GetEngine(mach);

	/* Make counterfeit frame header to use */
	fhp = &(*Vhdrs)[mach-baseof_Vhdrs][buf];
	fhp->fh_id = ID_CFRM;
	if (mach <= HIVIDMACHNUM)
	{
		fhp->fh_vidflag	= TRUE;
		fhp->fh_audchans	= 0;
		fhp->fh_audlen		= 0;			// No audio please
	}
	else
	{
		fhp->fh_vidflag	= FALSE;
		fhp->fh_audchans	= 2;			// ???
#ifdef FLYERVER3
		fhp->fh_audlen	= (MONOAUDFIELD * 2);	// Only if recording audio
#else
		fhp->fh_audlen	= MONOAUDFIELD;			// Only if recording audio
#endif
	}

	bfp = &Vbufctrl[mach-baseof_Vbufctrl][buf];
	addr = bfp->bf_addr;
	bfp->bf_empty = FALSE;				// Fake data is here
	bfp->bf_flags |= BFF_OUTSIDE;		// Points outside buffer area

	BumpUserVidBufNum(ep);					// Bump user buffer number

	ep->e_bufsfull++;
//	BufsFull[mach-baseof_BufsFull]++;
	DBUG(DrawBar(mach);)

	if (mach <= HIVIDMACHNUM)
	{
		for (i=1;i<=4;i++)
		{
			/* "PickupFieldParams" currently subs out a HEADERLEN */
			fip = &(*Vhdrs)[mach-baseof_Vhdrs][buf].fh_fld[i-baseof_fhfld];
			fip->fi_vloc	= HEADERLEN+MATTEDRAM-addr;	// Point to matte area
			fip->fi_vlen	= MATTEBLKS;
			fip->fi_tol		= 0;
			fip->fi_rndsz	= 0;
			fip->fi_rndfrq = 0;
			fip->fi_seed	= 0;
			fip->fi_flags	= 0;
		}
	}
}


/*
 * CreateMatteField - Create a field of the matte color in DRAM space
 */
void CreateMatteField(const UBYTE *data)
{
#define	WORKBLKS	4
#define	WORKSIZE (WORKBLKS * 512)

	UBYTE	*workptr;
	UWORD	left,addr,sz;
//	ULONG	i;

	workptr = AllocSRAM(WORKBLKS);
	if (workptr == NULL)
		return;

	ClearMemory(workptr,WORKSIZE);						// All 0 bits except...
	CopyMem((APTR)data,(APTR)workptr,8);				// magic matte values at 0000
	CopyMem((APTR)(data+8),(APTR)(workptr+0xBF),8);	// magic matte values at 00BF

	left = MATTEBLKS;					// Need to fill all blocks
	addr = MATTEDRAM;

	/* Move first block into buffer in DRAM */
	CpuXferMemWait(workptr,addr,1,READ);

	left--;
	addr++;

	ClearMemory(workptr,512);		// All 0 bits from now on...

	while (left > 0)
	{
		sz = WORKBLKS;
		if (sz > left)
			sz = left;

		/* Move data into buffer in DRAM */
		CpuXferMemWait(workptr,addr,sz,READ);

		left -= sz;
		addr += sz;
	}
	FreeSRAM(workptr,WORKBLKS);
}


/*
 * LockVideoRAM - Ensure we can use video DRAM for high-speed copying
 *						If in record mode, shuts down DMA
 *						If in play mode, plays matte black
 */
void LockVideoRAM(void)		
{
	if (LockVidRamCntr == 0)
	{
		/* Remember video mode to restore */
		LockVidRamMode = VideoMode;

		if (VideoMode == VM_RECORD)
		{
			DBUG(print(DB_INTERN,"None");)
			/* Shut down video */
			NoMode();
		}
		else if (VideoMode == VM_PLAY)
		{
			BlackOut();					// All channels to matte black
		}
	}
	LockVidRamCntr++;
}


/*
 * UnLockVideoRAM - Free video RAM back to video engines
 */
void UnLockVideoRAM(void)
{
	if (--LockVidRamCntr == 0)
	{
		if (LockVidRamMode == VM_RECORD)
		{
			DBUG(print(DB_INTERN,"Rec,");)
			RecordMode();
		}
	}
}


/*
 * BlackOut - Output black on all channels if in play mode
 */
void BlackOut(void)
{
	UBYTE	buf,eng;

	if (VideoMode == VM_PLAY)
	{
		DBUG(print(DB_ALWAYS,"BlackOut...");)

		/* All channels to matte black */
		for (eng=LOVIDMACHNUM;eng<=HIVIDMACHNUM;eng++)
		{
			buf = GetNextVideoBuffer(eng,TRUE);
			DBUG(print(DB_INTERN,"1");)
			MakeMatteFrame(eng,buf);							// (Bumps e_userbuf)
			DBUG(print(DB_INTERN,"2");)
			EngineCommand(eng,AVCMD_PLAY,0,1,&NullAudioArgs,0);	// (Was _ADVFRM)
			DBUG(print(DB_INTERN,"3");)
		}

		DBUG(print(DB_INTERN,"Mattes done\n");)

		for (eng=LOVIDMACHNUM;eng<=HIVIDMACHNUM;eng++)
		{
			WaitEngineDone(eng);									// Wait to "take"
		}

		DBUG(print(DB_ALWAYS,"Done\n");)
	}
}


__asm struct ENGINE *GetEngine(register __d0 ULONG eng)
{
	static struct ENGINE *engtable[NUMVIDCHANS+NUMAUDCHANS] = {
		&Engine[0],
		&Engine[1],
		&Engine[2],
		&Engine[3],
		&Engine[4],
		&Engine[5],
		&Engine[6],
		&Engine[7],
		&Engine[8],
		&Engine[9]
	};

#if ((NUMVIDCHANS+NUMAUDCHANS)-10)
	HEY! MUST CHANGE THIS HARD CODED TABLE TO MATCH # OF ENGINES!!!
#endif

	return(engtable[eng-baseof_Engine]);

//	return(&Engine[eng-baseof_Engine]);
}


/*
 * InitVid -- Initialization code
 */
void InitVid(void)
{
	register struct ENGINE	*ep;
	struct EngineEvent	*ee;
	ULONG	mach,i;

	/* Clear FieldClock */
	FieldClock = 0;
	LastField = 0;
	LockVidRamCntr = 0;
	KickOffFld	= 0;
	SpecialChoices = 0;

	ep = &Engine[LOVIDMACHNUM-baseof_Engine];
	for (mach=LOVIDMACHNUM ; mach<=HIAUDMACHNUM ; mach++,ep++)
	{
		ep->e_engnum	= mach;			// So we can get eng from ep->
		ep->e_cmd		= AVCMD_IDLE;
//		ep->e_synccmd	= AVCMD_IDLE;
//		ep->e_syncflag	= FALSE;
		ep->e_flags &= ~EFLG_ACTIVE;
		ep->e_flags &= ~EFLG_KICKME;
		ep->e_adjust	= FALSE;
		ep->e_late		= FALSE;
		ep->e_syncup	= FALSE;
		ep->e_latecnt	= 0;
		ep->e_dropflds	= 0;
		ep->e_stillcmd	= AVCMD_COLOR;		// Default to Color stills
		ep->e_audchan	= 0;					// none

		for (i=NUMENGEVENTS,ee=&ep->e_events[0];i--;ee++)
		{
			ee->ee_next = NULL;
			ee->ee_active = FALSE;
		}
		ep->e_1stevent = NULL;

//		AVmachine[mach-baseof_AVmachine].m_state = 0;

		if (mach <= HIVIDMACHNUM)			// Video?
			InitCompressor(mach);

		ep->e_bufsfull = 0;
	}

	HighSpeedVTASC = FALSE;
		

	DfltVidPrefs();								// Set default video prefs

	VideoMode = VM_NADA;
	NoSyncLED = FALSE;
	NoSyncLast= FALSE;

// Moved up into 'ep' loop above
//	for (mach=LOVIDMACHNUM ; mach<=HIAUDMACHNUM ; mach++)
//		BufsFull[mach-baseof_BufsFull] = 0;

	VidPaused = FALSE;
//	RecBiasLine = 150;		// Tweak this!

#if FORCEVID
	ForceRndFreq = 0xFF;
	ForceRndBits = 0xFF;
	ForceRndSeed = 0xFF;
#endif

#if FIELDTASKS
	// Spawn Field Task
	FieldTask = StartTask((PROC)&FieldTaskProc,20,FIELDTASKSTACKSIZE,0,"Field");
	DBUG(print(DB_ALWAYS,"FieldTask @ %l\n",FieldTask);)
#endif

#if VIDEOTASKS
	// Spawn VideoDriver Tasks
	VideoDriver0 = StartTask((PROC)&VideoDriverProc,80,VIDDRVRTASKSTACKSIZE,0,"VideoA");
	VideoDriver1 = StartTask((PROC)&VideoDriverProc,80,VIDDRVRTASKSTACKSIZE,1,"VideoB");
	DBUG(print(DB_ALWAYS,"VidDrvr0 @ %l\n",VideoDriver0);)
	DBUG(print(DB_ALWAYS,"VidDrvr1 @ %l\n",VideoDriver1);)
#endif
}
