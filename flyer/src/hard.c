/*********************************************************************\
*
* $Hard.c - Low-level hardware support functions$
*
* $Id: hard.c,v 1.5 1995/11/21 11:59:02 Flick Exp Holt $
*
* $Log: hard.c,v $
*Revision 1.5  1995/11/21  11:59:02  Flick
*Removed DSPdebug code (no longer needed)
*
*Revision 1.4  1995/10/26  18:02:04  Flick
*Improved DSPboot function to verify code before booting (w/retries)
*Also does a quick test for DSP mortality after booted, retries if fails
*
*Revision 1.3  1995/08/15  17:06:41  Flick
*First release (4.05) -- aesthetic cleanup
*Added support for GlobalOptions
*
*Revision 1.2  1995/05/04  17:10:24  Flick
*Phx/Flyer duality improved, some stub code moved into AmiShar.c
*
*Revision 1.1  1995/05/03  10:44:52  Flick
*Automated prototypes, and reduced includes when possible
*
*Revision 1.0  1995/05/02  11:06:23  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	08/04/94		Marty	created
*	02/06/95		Marty	Ported to C
\*********************************************************************/

#define	LOCALDEBUG		0			// Debugging switch for this module only

#include <Types.h>
#include <Flyer.h>
#include <Errors.h>
#include <Exec.h>
#include <Hard.h>
#include <Chips.h>
#include <Vid.h>
#include <TBC.h>			// Brooktree defines
#include <Debug.h>

#include <limits.h>

#include <proto.h>
#include <Hard.ps>

extern const ULONG SRAMbase;			// Base of shared SRAM memory map
extern struct FIRSET CustomFIRcoefs[2];
extern UBYTE	VideoMode;
extern AudioCtrl *AUD_serchip;		// Base of Audio ctrl chip
extern BOOL		HighSpeedVTASC;
extern BOOL		VeryHSVTASC;


UWORD	PlaySkewA,PlaySkewB,RecSkew;
UWORD	PlayOffsetA,PlayOffsetB;
UWORD	RecOffsetA,RecOffsetB;
UWORD	PedestalA,PedestalB;


AlignChip *Align_serchip = (AlignChip *)ALIGNBASE;		// Base of Aligner
SkewChip *Skew_serchip = (SkewChip *)SKEWBASE;			// Base of Skew
TimerRouter *TR_serchip = (TimerRouter *)TMRTBASE;		// Base of TimerRouter
TBC *TBC_serchip = (TBC *)TBCBASE;							// Base of TBC board

_3PORT *_3Port = (_3PORT *)_3PORTBASE;						// Base of 3Port

struct FIRREG *FIRreg = (struct FIRREG *)FIRBASE;
struct FIRCHIPCOEFS *FIRcoef = (struct FIRCHIPCOEFS *)FIRCOEFBASE;

UBYTE	VTASCversion;			// Version of VTASC chips loaded
UWORD	BoardRev;
ULONG	GlobalOptions;

WORDBITS	ChipsUp;				// Keeps track of chips programmed
BYTEBITS	Routing;				// Current mux settings (local copy)
UBYTE	InputSource;			// Selected source
BOOL	TBCpresent;				// TBC module attached?
UBYTE	TBC_DecInpFmt;			// Local storage for this TBC ctrl register

ULONG	RecFudge;				// Record rotate bits amount (0-3)
ULONG	PlayFudge;				// Play rotate bits amount (0-3)
UBYTE	SkewBases[2];


#define	NUMFIRPRESETS	4

struct FIRSET FIRPRESETS[NUMFIRPRESETS][2] = {
{	{0x003,0x004,0x006,0x00D,0x00F,0x00B,0x019,0x033, 0x200},	// 25
	{0x026,0x3FE,0x3CA,0x00C,0x3E2,0x314,0x3C4,0x1CC, 0x200}		// 25i
},{
	{0x004,0x003,0x005,0x00D,0x00D,0x007,0x019,0x03A, 0x200},	// 33
//	{0x015,0x3F6,0x3DC,0x010,0x3E9,0x357,0x3E4,0x163, 0x200},	// 33i old
	{0x025,0x3D2,0x008,0x3E4,0x3D5,0x3FA,0x2E1,0x1ED, 0x200}		// 33i tweaked
},{
	{0x004,0x001,0x002,0x00C,0x00A,0x400,0x018,0x049, 0x200},	// 50
	{0x400,0x3F5,0x017,0x3C3,0x003,0x016,0x334,0x164, 0x200}		// 50i
},{
	{0x3FF,0x003,0x3FA,0x00A,0x3F0,0x01B,0x3CD,0x0A2, 0x200},	// 100
	{0x3FF,0x003,0x3FA,0x00A,0x3F0,0x01B,0x3CD,0x0A2, 0x200}		// 100i
}
};



/*
 * InitHard -- Initialization code
 */
void InitHard(void)
{
	ChipsUp = 0;					// None configured
	_3Port->HC05ctrl = 9;		// Remove HC05 reset
	RecFudge = 2;					// Tested!
	PlayFudge = 1;					// Tested!
}


/*
 * ConfigROMchip -- configure FPGA from image in ROM
 */
UBYTE ConfigROMchip(ULONG type, UBYTE vidmode)
{
	ULONG	revision,size,clk,patch;
	APTR	ptr;
	UBYTE	err;
	BOOL	dualflag;
	int	clocknum;

	switch (type)
	{
	case FPGA_PCODER1:
		if (vidmode == VM_PLAY)
			patch = FPGA_DEF_PD;
		else
			patch = FPGA_DEF_PE;
		dualflag = TRUE;
		clocknum = 3;
		break;
	case FPGA_MCODER1:
		if (vidmode == VM_PLAY)
			patch = FPGA_DEF_MD;
		else
			patch = FPGA_DEF_ME;
		dualflag = TRUE;
		clocknum = 2;
		break;
	case FPGA_DMA:
		patch = type;
		clocknum = 0;
		dualflag = FALSE;
		break;
	default:
		patch = type;
		clocknum = -1;
		dualflag = FALSE;
	}

	DBUG(print(DB_ALWAYS,"+Looking for patch %l\n",patch);)

	revision = 0;

	ptr = FindROMpatch(patch,&revision,&size,&clk);
	if (ptr)
	{
		DBUG(print(DB_ALWAYS,"+Found revision %l at $%l\n",revision,ptr);)

		// Set clock synthesizer for chips which have this control
		if ((clocknum >= 0) && (clk))
		{
			DBUG(print(DB_ALWAYS,"+clk(%b) speed = %l\n",clocknum,clk);)
			SetClockFreq(clocknum,clk);
		}

		if (patch == MICROCODE_DSP)
		{
			DSPboot(ptr,size);
			err = ERR_OKAY;
		}
		else
		{
			err = PgmFPGA(ptr,size,type,dualflag,revision);
		}
		return(err);
	}
	else
	{
		DBUG(print(DB_ALWAYS,"+Not found!\n");)
		return(ERR_OBJNOTFOUND);
	}
}


/*
 * PgmFPGA - Program Individual FPGA Chip
 */
UBYTE PgmFPGA(	APTR	addr,
					ULONG	length,
					UBYTE	chipnum,
					BOOL	dualflag,
					UBYTE	chiprev)
{

// These delays are in uSec, and represent the init delay before config
#define	DLY_1C03		151
#define	DLY_1C05		180
#define	DLY_1C07		208
#define	DLY_1C09		236
#define	DLY_3030		500

static const UWORD	CHIPDELAYS[NUMFPGACHIPS] = {
	DLY_3030,	// Skew
	DLY_1C05,	// Timer/router
	DLY_1C07,	// Pcoder
	DLY_1C07,	// Pcoder
	DLY_1C03,	// Mcoder
	DLY_1C03,	// Mcoder
	DLY_1C07,	// DMA
	DLY_1C03,	// Audio
	DLY_1C03		// Aligner
};

	volatile register BYTEBITS	*chipadr1,*chipadr2;
	UWORD	delay,count;
	BOOL	go1,go2;
	UBYTE	err = ERR_OKAY;

	/* Apply slightly extra delay just to be safe */
	delay = (CHIPDELAYS[chipnum-1] * 15) >> 4;

	if ((chipnum < 1) || (chipnum > NUMFPGACHIPS))
	{
		return(ERR_BADPARAM);			// Set Error code
	}

	go1 = TRUE;
	go2 = FALSE;

	/* Get address of config bits for specified chip */
	chipadr1	= &_3Port->FPGAconfig.chips[chipnum-1].bits;
	if (dualflag)
	{
		chipadr2	= &_3Port->FPGAconfig.chips[chipnum-1+1].bits;
		go2 = TRUE;
	}

//	if (BoardRev != 1)
//	{
		DBUG(print(DB_GEN,"New FPGA\n");)

		*chipadr1 = FPGAF_PROG;				// PROG,INIT, not DONE
		if (dualflag)
			*chipadr2 = FPGAF_PROG;			// PROG,INIT, not DONE

		if (chipnum == FPGA_SKEW)
			MicroSeconds(10);					// Busy wait for 10us -- Xilinx only

		*chipadr1 = FPGAF_INIT_;			// not PROG, not INIT, not DONE
		if (dualflag)
			*chipadr2 = FPGAF_INIT_;		// not PROG, not INIT, not DONE

		count = delay;
		while (!(FPGAF_INIT_ & *chipadr1))		// Wait for INIT high
		{
			if (--count == 0)
			{
				go1 = FALSE;
				break;
			}
		}
		*chipadr1 = FPGAF_INIT_ | FPGAF_DONE;		// not PROG, not INIT, DONE

		if (dualflag)
		{
			count = delay;
			while (!(FPGAF_INIT_ & *chipadr2))	// Wait for INIT high
			{
				if (--count == 0)
				{
					go2 = FALSE;
					break;
				}
			}
			*chipadr2 = FPGAF_INIT_ | FPGAF_DONE;	// not PROG, not INIT, DONE
		}
//	}
//	else
//	{
//		DBUG(print(DB_GEN,"Old FPGA\n");)
//
//		*chipadr1 = zero;						// All Programming Pins Lo
//		if (dualflag)
//			*chipadr2 = zero;					// All Programming Pins Lo
//
//		MicroSeconds(7);						// Busy wait for 7us
//
//		*chipadr1 = FPGAF_PROG | FPGAF_RESET_ | FPGAF_DONE;	// _Reset & D_P & _PROG Hi
//		if (dualflag)
//			*chipadr2 = FPGAF_PROG | FPGAF_RESET_ | FPGAF_DONE;
//
//		MicroSeconds(delay);					// Busy wait for proper amount of time
//	}

	// If all setup went well, shovel configuration bits to chip(s)

	if (go1 || go2)
	{
		DBUG(print(DB_GEN,"Shoveling...\n");)

		// Send data to FPGA chip(s)
		ProgFPGAbits(addr,length);

		MicroSeconds(50);					// Needed???
	}

	// Handle chip configuration failures

	if ((!(FPGAF_DONE & *chipadr1)) || (!go1))
	{
		UnPgmFPGA(chipnum);
		err = ERR_CMDFAILED;			// Set Error code
	}
	else
	{
		DBUG(print(DB_GEN,"okay\n");)
		// Get version of VTASC we're using
		if ((chipnum >= FPGA_PCODER1) && (chipnum <= FPGA_MCODER2))
		{
			VTASCversion = chiprev;
//			DBUG(print(DB_GEN,"VTASC version = %b\n",chiprev);)
		}
		ChipDefaults(chipnum);				// Setup chip registers
		InitDispatch(chipnum);				// Init stuff as chips come up
	}
	
	if (dualflag)
	{
		// Handle chip configuration failure
		if ((!(FPGAF_DONE & *chipadr2)) || (!go2))
		{
			UnPgmFPGA(chipnum+1);
			err = ERR_CMDFAILED;	// Set Error code
		}
		else
		{
			DBUG(print(DB_GEN,"okay2\n");)
			ChipDefaults(chipnum+1);			// Setup chip registers
			InitDispatch(chipnum+1);			// Init stuff as chips come up
		}
	}
	return(err);
}


/*
 * UnPgmFPGA - Un-Program Individual FPGA Chip
 */
void UnPgmFPGA(UBYTE chipnum)
{
	volatile register BYTEBITS	*chipadr;
	UBYTE	zero = 0;

	DBUG(print(DB_GEN,"Unpgm %b\n",chipnum);)

	/* Get address of config bits for specified chip */
	chipadr	= &_3Port->FPGAconfig.chips[chipnum-1].bits;
	if (BoardRev != 1)
	{
		*chipadr = FPGAF_PROG | FPGAF_INIT_ | FPGAF_DONE;	// Prog=T, Init=F
		*chipadr = FPGAF_PROG;										// Prog=T, Init=T

		if (chipnum == FPGA_SKEW)
			MicroSeconds(10);		// Busy wait for 10us -- Xilinx only

		*chipadr = zero;			// Prog=F, Init=T
	}
	else
	{
		*chipadr = zero;			// Xilinx/Old orca - all Programming Pins Lo
	}
}


/*
 * ChipDefaults - Setup chip registers with defaults
 */
static void ChipDefaults(UBYTE chipnum)
{
struct DFLTENTRY {
	ULONG	addr;
	UBYTE	val;
	UBYTE	whichchip;
};

static struct DFLTENTRY	ChipDefaultsArray[] = {
	//	Register			Value			Chip
	SKEWBASE+OFFST(SkewChip_regs,Term),
							0x60,			FPGA_SKEW,		// Term inputs 3 and 4 only
	SKEWBASE+OFFST(SkewChip_regs,Route),
							DFLT_ROUTING, FPGA_SKEW,	// Get sync/vid from Toaster

	TMRTBASE+OFFST(TimerRouter_regs,FIRBNKA),
							0x00,			FPGA_TMRT,		// Linear ROM, linear RAM
	TMRTBASE+OFFST(TimerRouter_regs,FIRBNKB),
							0x00,			FPGA_TMRT,		// Linear ROM, linear RAM
	TMRTBASE+OFFST(TimerRouter_regs,COEFA),
							3,				FPGA_TMRT,		// FIR coeff bank for chan 0
	TMRTBASE+OFFST(TimerRouter_regs,COEFB),
							3,				FPGA_TMRT,		// FIR coeff bank for chan 1
	TMRTBASE+OFFST(TimerRouter_regs,VPEDA),
							60,			FPGA_TMRT,		// Pedestal for chan A
	TMRTBASE+OFFST(TimerRouter_regs,VPEDB),
							60,			FPGA_TMRT,		// Pedestal for chan B
	TMRTBASE+OFFST(TimerRouter_regs,VIDCTRL),
		TRVCF_HalfLines+TRVCF_InvFld, FPGA_TMRT,		// half-lines, correct field
	TMRTBASE+OFFST(TimerRouter_regs,MUXCTRL),
							0xF8,			FPGA_TMRT,		// Input from A/D
	TMRTBASE+OFFST(TimerRouter_regs,VINSELA),
							0,				FPGA_TMRT,		// TM0 to VTASC A
	TMRTBASE+OFFST(TimerRouter_regs,VINSELB),
							0,				FPGA_TMRT,		// TM0 to VTASC B

	ALIGNBASE+OFFST(Aligner_regs,DACACTRL),
							0,				FPGA_ALIGNER,	// Output 1 = chan 0
	ALIGNBASE+OFFST(Aligner_regs,DACBCTRL),
							1,				FPGA_ALIGNER,	// Output 2 = chan 1
	ALIGNBASE+OFFST(Aligner_regs,ADCTRL),
							0,				FPGA_ALIGNER,	// Input on channel 0

	0,0,0	// End!
};

	register struct DFLTENTRY	*node;

	for (node=ChipDefaultsArray;node->whichchip;node++)
	{
		if (node->whichchip == chipnum)
		{
			DBUG(print(DB_TEST,"Dflt: chip %b, addr %l, val %b\n",
			chipnum,node->addr,node->val);)
			*(UBYTE *)node->addr = node->val;		// This is a serial bus write!
		}
	}
}


/*
 * FirInit - Initialize FIR Filter
 */
void FirInit(UWORD data0, UWORD data1)
{
	register struct FIRREG *fr = FIRreg;

	fr->ctrl0 = data0;				// Load reg 0 value
	fr->ctrl1 = data1;				// Load reg 1 value
}


/*
 * FirInitDefaults - Initialize FIR Filter
 */
UBYTE FirInitDefaults(void)
{
	UBYTE	bank;

	FirInit(0x81,0x1A);			// Load reg0,1 values

	for (bank=0;bank<8;bank++)
	{
		LoadFirMap(bank,2,0);		// 2x linear
	}

	return(ERR_OKAY);
}


/*
 * FirXchg - Read/Write FIR Coefficients/scale
 */
UBYTE FirXchg(UBYTE setnum, UBYTE readflag, UBYTE prepost, struct FIRSET *data)
{
	UBYTE error = ERR_OKAY;

	UWORD	count;
	struct FIRSET	*setptr;

	if (readflag != 0)
	{
		DBUG(print(DB_OPS,"\Read Coefs %b (type %b): ",setnum,prepost);)

		if (setnum == 0)
			setptr = &CustomFIRcoefs[prepost];	// Custom
		else
			setptr = &FIRPRESETS[setnum-1][prepost];	// Presets

		*data = *setptr;				// Copy FIRSET to SRAM
	}
	else if (setnum == 0)
	{
		DBUG(print(DB_OPS,"\Write Coefs0 (type %b): ",prepost);)

		/* Copy coefs/scale into storage (will copy into clip headers) */
		CustomFIRcoefs[prepost] = *data;

		/* Need to make immediate change to hardware? */
		if (((prepost == 0) && (VideoMode == VM_RECORD))
		|| ((prepost == 1) && (VideoMode == VM_PLAY)))
		{
			DBUG(print(DB_OPS,"(live)");)
			for (count=0;count<8;count++)
			{
				FIRcoef->bank[0].coef[count] = data->coefs[count];
			}
		}
	}
	else
	{
		error = ERR_BADPARAM;
	}

	DBUG(
		for (count=0;count<8;count++)
			print(DB_INTERN,"%w ",data->coefs[count]);
		print(DB_INTERN,"\n");
	)

	return(error);
}


/*
 * DownloadFIRpresets - Load FIR coefficient presets into FIR chip
 */
void DownloadFIRpresets(UBYTE prepost)
{
	register UWORD *fptr;
	register struct FIRSET	*setptr;
	UWORD	count,coef,this;

	fptr = &FIRcoef->bank[0].coef[0];

	// (Coef 0 is "custom", 1-n are fixed)
	for (coef=0;coef<=NUMFIRPRESETS;coef++)
	{
		DBUG(print(DB_INTERN,"\Coef bank %w: ",coef);)

		if (coef == 0)
			setptr = &CustomFIRcoefs[prepost];			// Custom set
		else
			setptr = &FIRPRESETS[coef-1][prepost];		// Presets

		for (count=0;count<8;count++)
		{
			this = setptr->coefs[count];					// Get coefficient
//			FIRcoef->bank[coef].coef[count] = this;
			*fptr++ = this;									// Write to FIR chip
			DBUG(print(DB_INTERN,"%w ",this);)
		}
		/* Handle scale value! Maybe set MapRam according to scale?! */
	}
}


static const UBYTE INVSIN_TABLE[256] = {
	0x1A,0x1A,0x1A,0x1A,0x1A,0x1A,0x1A,0x1A,
	0x1B,0x1B,0x1B,0x1B,0x1B,0x1C,0x1C,0x1C,
	0x1D,0x1D,0x1D,0x1E,0x1E,0x1F,0x1F,0x20,
	0x20,0x21,0x21,0x22,0x22,0x23,0x23,0x24,
	0x25,0x25,0x26,0x27,0x27,0x28,0x29,0x2A,
	0x2A,0x2B,0x2C,0x2D,0x2E,0x2E,0x2F,0x30,
	0x31,0x32,0x33,0x34,0x35,0x35,0x36,0x37,
	0x38,0x39,0x3A,0x3B,0x3C,0x3D,0x3E,0x3F,
	0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,
	0x48,0x49,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,
	0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,
	0x58,0x59,0x5A,0x5B,0x5C,0x5D,0x5E,0x5F,
	0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,
	0x68,0x69,0x69,0x6A,0x6B,0x6C,0x6D,0x6E,
	0x6F,0x70,0x71,0x72,0x73,0x74,0x75,0x76,
	0x77,0x77,0x78,0x79,0x7A,0x7B,0x7C,0x7D,
	0x7E,0x7F,0x80,0x80,0x81,0x82,0x83,0x84,
	0x85,0x86,0x86,0x87,0x88,0x89,0x8A,0x8B,
	0x8B,0x8C,0x8D,0x8E,0x8F,0x8F,0x90,0x91,
	0x92,0x92,0x93,0x94,0x95,0x95,0x96,0x97,
	0x98,0x98,0x99,0x9A,0x9B,0x9B,0x9C,0x9D,
	0x9D,0x9E,0x9F,0x9F,0xA0,0xA1,0xA1,0xA2,
	0xA2,0xA3,0xA4,0xA4,0xA5,0xA6,0xA6,0xA7,
	0xA7,0xA8,0xA8,0xA9,0xA9,0xAA,0xAB,0xAB,
	0xAC,0xAC,0xAD,0xAD,0xAE,0xAE,0xAF,0xAF,
	0xAF,0xB0,0xB0,0xB1,0xB1,0xB2,0xB2,0xB2,
	0xB3,0xB3,0xB4,0xB4,0xB4,0xB5,0xB5,0xB5,
	0xB6,0xB6,0xB6,0xB7,0xB7,0xB7,0xB8,0xB8,
	0xB8,0xB8,0xB9,0xB9,0xB9,0xB9,0xB9,0xBA,
	0xBA,0xBA,0xBA,0xBA,0xBB,0xBB,0xBB,0xBB,
	0xBB,0xBB,0xBB,0xBC,0xBC,0xBC,0xBC,0xBC,
	0xBC,0xBC,0xBC,0xBC,0xBC,0xBC,0xBC,0xBC
};


/*
 *	LoadFirMap - Load FIR Map RAM with table
 */
UBYTE LoadFirMap(	UBYTE	bank,
						UBYTE	scale,
						UBYTE	shape)
{
	register TimerRouter *tr = TR_serchip;
	UWORD	data,scldat;
	UBYTE	laddr,haddr;
	UBYTE	zero = 0;
	UBYTE error = ERR_OKAY;

	DBUG(print(DB_GEN,"Loading FIR bank %b, scale %b, shape %b\n",
		bank,scale,shape);)

	/* FIR data output is in the format sxxxxxxxxx.xx where s is the sign bit */

	/* There are 8 banks in the 32K RAM part */

	tr->MapRamFlags = MRF_RWenbl | MRF_AddrInc;	// Enable R/W, ADDR++ (non func)

	/* Clear High Address */
	haddr = bank * 16;
	tr->MapRamAddrHi = haddr;			// Write address

//	for (bank=0;bank<8;bank++)			// (OLD VERSION)
	laddr = 0;								// Clear Low Address
	for (data=0;data<4096;data++)	// 12 bits
	{
		tr->MapRamAddrLo = laddr;
		if (data < 2048)
		{
			if (scale == 1)
				scldat = data / 4;			// 0xxxxxxxxx.xx
			else if (scale == 2)
				scldat = data / 2;			// 0xxxxxxxxxx.x
			else if (scale == 4)
				scldat = data;					// 0xxxxxxxxxxx.
			else
				scldat = data;					// ???

			if (scldat > 0xFF)
				scldat = 0xFF;
			else if (shape == 2)
				scldat = INVSIN_TABLE[scldat];
		}
		else
			scldat = 0;							// 1xxxxxxxxxxx = 0

		tr->MapRamData = scldat;

		if (++laddr==0)						// Increment low addr every byte
		{
			haddr++;
			tr->MapRamAddrHi = haddr;		// Write address
		}
	}

	tr->MapRamFlags = zero;					// Return to normal FIR mode
	tr->MapRamAddrLo = zero;				// Reset MAP RAM address
	tr->MapRamAddrHi = zero;

	return(error);
}


#define DSPVERIFY	1

/*
 * DSPboot - Load DSP Boot RAM and Reset/Boot DSP
 */
UBYTE DSPboot(APTR addr, ULONG length)
{
	register UBYTE	*srcadr,*dstadr;
	register AudioCtrl *aud = AUD_serchip;
	ULONG	count;
	UBYTE	samp,try=0,retry,zero = 0,error = ERR_OKAY;
	BOOL success;

	retry = 10;
	while (retry--)
	{
		DBUG(print(DB_GEN,"Loading DSP...");)

		aud->CtrlFlags = ACF_RWenbl | ACF_AddrInc;	// Set write mode, reset DSP

//		count = 0x50000;
//		while (count--)
//			try++;

		DBUG(print(DB_GEN,"doit");)

		dstadr = &aud->setup.Data;							// SRAM Data Read/Write Location

		try = 0;
		do
		{
			DBUG(
				if (try>0) print(DB_GEN,"Retrying!");
			)

			aud->setup.AddrHi = zero;			// Store Address in interface chip
			aud->setup.AddrLo = zero;
			srcadr = (UBYTE *)addr;								// Get address of data

			count = length;						// Byte length of Data
			while (count--)
			{
				*dstadr = *srcadr++;						// Write next byte to DSP RAM
				MicroSeconds(2);
			}

			error = ERR_OKAY;						// Hope for the best

#if DSPVERIFY
			// Now we verify the code loaded okay
			aud->setup.AddrHi = zero;					// Reset address to base
			aud->setup.AddrLo = zero;
			srcadr = (UBYTE *)addr;								// Get address of data

			count = length;						// Byte length of Data
			while (count--)
			{
				samp = SerRead(dstadr);
				if (samp != *srcadr++)		// Compare next byte against DSP RAM
				{
					DBUG(print(DB_GEN,"mismatch: at %l (%b vs. %b)\n",length-count-1,samp,*(srcadr-1));)
					error = ERR_CMDFAILED;
					break;
				}
				MicroSeconds(2);
			}
#endif
		} while (error && (++try)<15);

		aud->CtrlFlags = zero;						// Normal Ram Mode

		if (error == ERR_OKAY)
		{
			aud->CtrlFlags = ACF_DSPrun;			// If successful, Clear DSP reset, boot & run!

			MicroSeconds(150000);						// Give it a few msec to come up

			DBUG(print(DB_GEN,"(test)");)
			success = WriteDSP(0x60,0);				// A DSP no-operation
		}

		if (success || error)		// Stop if never verified, or if seems up okay
			break;
	}

	DBUG(print(DB_GEN,"Done (err=%b,succ=%b)\n",error,success);)

	return(error);
}


/*
 * SbusW - Write data to serial bus
 */
UBYTE SbusW(UBYTE addr, UBYTE data)
{
	UBYTE		*seradr;

	seradr = (UBYTE *)(SERBASE+1 + addr * 2);		// Get address

	*seradr = data;							// Write data to Serial Bus

	return(ERR_OKAY);
}


/*
 * SbusR - Read data from serial bus
 */
UBYTE SbusR(UBYTE addr, UBYTE *data)
{
	UBYTE		*seradr;

	seradr = (UBYTE *)(SERBASE+1 + addr * 2);		// Get address

	*data = SerRead(seradr);		// Write data to command

	return(ERR_OKAY);
}


/*
 * InitDispatch - Run code depending on chips that are programmed
 */
static void InitDispatch(UBYTE chipnum)
{
typedef UBYTE (*AUTOPROC)(void);

	struct INITENTRY {
		WORDBITS	chips;
		BOOL		repeat;			// Repeat if chip(s) re-programmed?
		AUTOPROC	initcode;
	};


	static const struct INITENTRY	INITRULES[] = {
		1<<FPGA_TMRT,			FALSE,	FirInitDefaults,	// per Charles
		1<<FPGA_DMA,			TRUE,		ScanDrives,			// per Charles
//		(1<<FPGA_SKEW)|(1<<FPGA_ALIGNER),	TRUE,		EstablishSkew,
		0,							FALSE,	NULL
	};

	register const struct INITENTRY	*node;
//	UBYTE	err;
	BOOL	redo;

	redo = ((1<<chipnum) & ChipsUp);		// Was already programmed?

	ChipsUp |= (1<<chipnum);				// Remember that chip is configured

	for (node=INITRULES;node->initcode;node++)
	{
		/* Check if this chip is involved */
		if ((1<<chipnum) & node->chips)
		{
			/* Make sure this is the first config for chip (unless "repeat") */
			/* is TRUE where we execute every time chip is programmed) */
			if ((!redo) || (node->repeat))
			{
				/* If all needed chips are configured, do routine */
				if ((node->chips & ChipsUp) == node->chips)
				{
					node->initcode();
				}
			}
		}
	}
}


/*
 * ToasterMux - Set Toaster/Flyer mux switches
 */
UBYTE ToasterMux(UBYTE input3, UBYTE input4, UBYTE preview)
{
	DBUG(print(DB_INTERN,"in3=%b in4=%b pre=%b ---",input3,input4,preview);)

	Routing &= ~(SKRF_SelPreVu | SKRF_Sel4 | SKRF_Sel3); // Clear bits we control

	if (input3 == 0)
		Routing |= SKRF_Sel3;			// Pass thru Toaster input 3

	if (input4 == 0)
		Routing |= SKRF_Sel4;			// Pass thru Toaster input 4

	if (preview == 0)
		Routing |= SKRF_SelPreVu;		// Pass thru Toaster preview

	Skew_serchip->Route = Routing;
	DBUG(print(DB_INTERN,"Routing = %b\n",Routing);)

	return(ERR_OKAY);
}


/*
 * InputSelect - Set Flyer input select switches
 */
UBYTE InputSelect(UBYTE source, UBYTE sync)
{
	DBUG(print(DB_INTERN,"src=%b sync=%b ---",source,sync);)

	/* Clear all bits we control */
	Routing &= ~(SKRF_Camcorder | SKRF_MainRef | SKRF_ISMASK);

	InputSource = source;

	switch (source)
	{
	case 0:				// Source = camcorder?
		TBCpick(1);							// Tell TBC to select camcorder
		Routing |= SKRF_Camcorder;		// Select camcorder video & ref
		break;
	case 1:				// Source = SVHS?
		TBCpick(0);							// Tell TBC to select SVHS
		Routing |= SKRF_Camcorder;		// Select camcorder video & ref
		break;
	default:
		Routing |= (source-2);
		break;
	}

	if (sync == 0)
		Routing |= SKRF_MainRef;		// Use Toaster Main as reference

	Skew_serchip->Route = Routing;
	DBUG(print(DB_INTERN,"Routing = %b\n",Routing);)

	return(ERR_OKAY);
}


/*
 * Termination - Set Video termination on/off
 */
UBYTE Termination(UBYTE flags)
{
	Skew_serchip->Term = flags << 4;

	return(ERR_OKAY);
}


/*
 * EEwrite - Write EEPROM word
 */
UBYTE EEwrite(	UBYTE	addr,
					UWORD	data)
{
	UBYTE	err;
	UWORD	dummy;

	DBUG(print(DB_ALWAYS,"EEW %b = %w\n",addr,data);)

	EEcore(EE_ENBL,0,&dummy);
	err  = EEcore(EE_WRITE,addr,&data);
	EEcore(EE_DSBL,0,&dummy);

	return(err);
}


/*
 * EEread - Read EEPROM word
 */
UBYTE EEread(	UBYTE	addr,
					UWORD	*data)
{
	UBYTE	err;

	err = EEcore(EE_READ,addr,data);

	DBUG(print(DB_ALWAYS,"EER %b = %w\n",addr,*data);)

	return(err);
}


/*
 * EEcore - Talk to EEPROM
 */
static UBYTE EEcore(	UBYTE	cmd,
							UBYTE	addr,
							UWORD	*data)
{
	volatile register BYTEBITS	*chipptr;
	ULONG	count,shiftout,data16;
	UBYTE	local,err;
	UBYTE	zero = 0;
	ULONG	waste = 0;		// avoid warnings

	err = ERR_OKAY;
	chipptr = &_3Port->EEctrl;

	/* Assemble start/ctrl/addr/data bits */
	shiftout = ((((0x10 + cmd) << 4) + addr) << 16) + *data;

	/* Select chip, CLK=0, DIN=0 */
	*chipptr = zero;			// Pull CLK lo, DIN lo, (CS lo)
	*chipptr = EE_CS;			// Pull CS hi

	count = 9;

	if ((cmd == EE_WRITE) || (cmd == EE_WRAL))
		count += 16;			// Send data word too

	/* Send start bit,ctrl,address,(opt)data */
	while (count--)
	{
		/* Clk out appropriate data bit */
		if ((1<<24) & shiftout)
			local = EE_CS + EE_DIN;			// DIN = 1
		else
			local = EE_CS;						// DIN = 0

		*chipptr = local;						// Set DIN, CLK lo
		*chipptr = local | EE_CLK;			// Pull CLK hi
		waste++;
		waste++;
		*chipptr = local;						// Pull CLK lo again

		shiftout <<= 1;
	}

	/* Clock in data word (read) */
	if (cmd == EE_READ)
	{
		data16 = 0;
		count = 16;
		while (count--)
		{
			*chipptr = EE_CS | EE_CLK;		// Pull CLK hi
			data16 <<= 1;
			if (EE_DOUT & (*chipptr))		// Get next data bit
				data16++;

			*chipptr = EE_CS;					// Pull CLK lo
		}
		*data = data16;						// Write data word to caller
	}

	/* Wait for completion */
	if ((cmd==EE_WRITE) || (cmd==EE_ERASE) || (cmd==EE_ERAL) || (cmd==EE_WRAL))
	{
		*chipptr = zero;						// Pulse CS low
		waste++;
		waste++;
		*chipptr = EE_CS;						// CS hi again
		waste++;

		count = 500000;
		/* Wait for done bit */
		while (!(EE_DOUT & (*chipptr)))
		{
			if (--count == 0)
			{
				err = ERR_EEFAILURE;
				break;
			}
		}
	}

	*chipptr = zero;			// Release CS, all lines

	return(err);
}


/*
 * SetClockFreq - calculates and sets clock generator parameters
 * for given channel and frequency.  (To change either Vclk we should
 * really set up the next (of 3) registers, then set select lines to
 * use that clock when we exit -- instead of just "hot-changing" reg0)
 *
 * (0=DMA, 1=Audio, 2=Mcoder, 3=Pcoder
 */
UBYTE SetClockFreq(UBYTE clock, ULONG freq)
{
#define	REFCLK	1431818							// 14.3 MHz ref clk into synthesizers
#define	QLO		((REFCLK+99999)/100000)		// Lowest legal Q value for reference
#define	QHI		(REFCLK / 20000)				// Highest legal Q value

static const ULONG VCOindexTable[] = {
	 5100000,
	 5320000,
	 5850000,
	 6070000,
	 6440000,
	 6680000,
	 7350000,
	 7560000,
	 8090000,
	 8320000,
	 9150000,
	10000000,
	11000000,		// Typo in Cypress data book???
	ULONG_MAX
};


	ULONG	pre,bestpre,scref,scref2,targetvco,p,q,bestp,bestq;
	int	err,besterr;
	ULONG	mux,bestmux,maxpre,flooby;
	UBYTE	index,thechip;

	DBUG(print(DB_ALWAYS,"Frequency desired (%b) = %l\n",clock,freq);)

	freq /= 10;				// All values in 10 Hz increments
	besterr = INT_MAX;

	if (clock & 1)
		maxpre = 2;			// Audio, Pcoder clocks can use 2x or 4x
	else
		maxpre = 1;			// DMA, Mcoder clocks can use 1x only

	for (pre=1;pre<=maxpre;pre++)
	{
		scref = REFCLK << pre;			// Scaled reference clock
		scref2 = scref >> 1;				// Half the scaled reference
		for (mux=0;mux<=7;mux++)
		{
			targetvco = freq << mux;	// Ideal VCO speed
			/* Ensure this VCO speed is even legal */
			if ((targetvco >= 5000000) && (targetvco <= 12000000))
			{
				for (q=QLO;q<=QHI;q++)
				{
					p = ((targetvco * q)+scref2) / scref;
					/* Reject illegal P values */
					if ((p>=4) && (p<=130))
					{
						/* Calculate error from ideal */
						err = targetvco - (scref * p / q);
						if (err<0)
							err = -err;


						DBUG(print(DB_ALWAYS,"Try: err=%l P=%l Q=%l M=%l S=%l\n",
								err,p,q,mux,pre);)

						/* Keep best one */
						if (err < besterr)
						{
							besterr	= err;
							bestpre	= pre;
							bestmux	= mux;
							bestp		= p;
							bestq		= q;
						}
					}
				}
			}
		}
	}

	/* If no legal parameters found to even come close, abort! */
	if (besterr == INT_MAX)
	{
		DBUG(print(DB_ALWAYS,"Illegal clock value\n");)
		return(ERR_CMDFAILED);
	}

	targetvco = ((REFCLK << bestpre) * bestp) / bestq;
	index=0;
	while (targetvco > VCOindexTable[index])
		index++;

	bestp = bestp-3;
	bestq = bestq-2;

	DBUG(print(DB_ALWAYS,"Best: err=%l P'=%l Q'=%l M=%l I=%l S=%l\n",
		besterr,bestp,bestq,bestmux,index,bestpre);)

	thechip = clock >> 1;
	if (clock & 1)
	{
		flooby = 0xC10000;				// Default bits for CNTL register
		if (bestpre == 2)
			flooby |= 0x1000;				// Set 4x bit

		SetClockGen(thechip,flooby);	// Set prescale to 2x or 4x (Audio/Pcoder)
	}

	if (clock & 1)
		flooby = 0x000000;		// Vclk0 (Audio/Pcoder)
	else
		flooby = 0x600000;		// Mclk  (DMA/Mcoder)

	flooby |= (index << 17) | (bestp << 10) | (bestmux << 7) | bestq;

	SetClockGen(thechip,flooby);

	return(ERR_OKAY);
}


/*
 * SetClockGen - Set programmable clock generator
 */
void SetClockGen(UBYTE chan, ULONG val)
{
	volatile register BYTEBITS	*chipptr;
	ULONG	i;
	UBYTE	zero = 0;

	DBUG(print(DB_ALWAYS,"Clock gen chan %b, value %l\n",chan,val);)

	/**************************************************/
	/* Interrupts disabled here -- time critical code */
	/**************************************************/
	Disable();

	if (chan==0)
		chipptr = &_3Port->ClkGen.DMA_Audio;
	else
		chipptr = &_3Port->ClkGen.M_P;

	/* Unlock chip */
	for (i=1;i<=7;i++)
	{
		*chipptr = VCO_DATA | VCO_CLK;
		*chipptr = VCO_DATA;
	}
	*chipptr = zero;
	*chipptr = VCO_CLK;

	/* Start bit */
	*chipptr = zero;
	*chipptr = VCO_CLK;

	/* Clock in 24 bits of data */
	for (i=1;i<=24;i++)
	{
		if (1 & val)
		{
			*chipptr = VCO_CLK;
			*chipptr = zero;
			*chipptr = VCO_DATA;
			*chipptr = VCO_DATA | VCO_CLK;
		}
		else
		{
			*chipptr = VCO_DATA | VCO_CLK;
			*chipptr = VCO_DATA;
			*chipptr = zero;
			*chipptr = VCO_CLK;
		}
		val >>= 1;
	}

	/* Stop bit */
	*chipptr = VCO_DATA | VCO_CLK;
	*chipptr = VCO_DATA;
	*chipptr = VCO_DATA | VCO_CLK;

	*chipptr = zero;			// Select V register 0 (1,2 unused)

	Enable();
}


/*
 * GenlockExchange - Exchange byte with genlock microcontroller
 */
UBYTE GenlockExchange(UBYTE input)
{
	volatile register BYTEBITS	*chipptr;
	UBYTE	val;
	ULONG	build;
	ULONG	i;
//	ULONG	delay;

	DBUG(print(DB_OPS,"Genlock cmd = %b\n",input);)

	chipptr = &_3Port->HC05ctrl;
	build	= 0;

	*chipptr = HC05_RESET_ | HC05_CLK;			// Reset false, CLK hi

	for (i=1;i<=8;i++)
	{
		if ((1<<7) & input)
			val = HC05_SDI;
		else
			val = 0;

		*chipptr = val | HC05_RESET_ | HC05_CLK;		// Set SDI bit properly
		input <<= 1;
		*chipptr = val | HC05_RESET_;						// Exchange bits
		build	<<= 1;
		if (HC05_SDO & (*chipptr))
			build |= 1;											// Get next bit from uP

		*chipptr = val | HC05_RESET_ | HC05_CLK;		// CLK hi again
	}

	DBUG(print(DB_OPS,"Genlock returned %b\n",build);)
	
	/* We need a delay here for PLL CPU to pick up new data (no handshaking) */
	MicroSeconds(10000);

//	delay = 10000;
//	while (delay)
//		delay--;

	return((UBYTE)build);
}



/*
 * SetVideoOffset - Set the horizontal/vertical video offsets
 */
void SetVideoOffset(UBYTE chan, UWORD horiz)
{
	register TimerRouter *tr = TR_serchip;
	UBYTE	hlo,hhi;
	UBYTE	vert;

	if ((1<<15) & horiz)
	{
		vert = 0;
		horiz += 910;
	}
	else
		vert = 1;

	hlo = horiz & 0xFF;
	hhi = (horiz >> 8) & 0x7F;

	DBUG(print(DB_GEN,"(%b) voff=%b, hoffh=%b, hoffl=%b\n",chan,vert,hhi,hlo);)

	if (chan == 0)
	{
		tr->HOROFAL = hlo;
		tr->HOROFAH = hhi;
		tr->VRTOFFA = vert;
	}
	else
	{
		tr->HOROFBL = hlo;
		tr->HOROFBH = hhi;
		tr->VRTOFFB = vert;
	}
}


/*
 * EstablishSkew - Characterize ranges of skew for MSB states
 */
void EstablishSkew(void)
{
	register UBYTE	*crsreg,*finereg,*alnreg;
	UBYTE	chan,bits8,diff,samp1,samp2;
	UBYTE	zero = 0;

	for (chan=0;chan<=1;chan++)
	{
		if (chan == 0)
		{
			crsreg	= &Skew_serchip->APHASEC;		// DAC A
			finereg	= &Skew_serchip->APHASEF;
			alnreg	= &Align_serchip->DACACTRL;
		}
		else
		{
			crsreg	= &Skew_serchip->BPHASEC;		// DAC B
			finereg	= &Skew_serchip->BPHASEF;
			alnreg	= &Align_serchip->DACBCTRL;
		}

		*finereg = zero;

		/* Set hardware skew registers */

		*crsreg = zero;
		samp1 = Read4Bits(alnreg);
		DBUG(print(DB_GEN,"Samp1:%b\n",samp1);)

		*crsreg = 5;
		samp2 = Read4Bits(alnreg);			// Shift by 1/2 bit, sample again
		DBUG(print(DB_GEN,"Samp2:%b\n",samp2);)
		diff = DiffDelay(samp1,&samp2);

		if (diff>1)
		{
			*crsreg = 0x85;
			samp2 = Read4Bits(alnreg);		// Shift by 1/2 bit, sample again
			DBUG(print(DB_GEN,"Samp2a:%b\n",samp2);)
			diff = DiffDelay(samp1,&samp2);
		}

		if (diff<=1)							// Make sure pairs basically agree
			bits8 = samp1 + samp2;			// Merge both 4-bits
		else
			bits8 = samp1 * 2;				// Fallback: use just first

		DBUG(print(DB_GEN,"diff:%b base:%b\n",diff,bits8);)
		
		SkewBases[chan] = bits8;
	}

	EEwrite(NVOL_SKEWBASELINE,(SkewBases[0] << 3) + SkewBases[1]);
}


/*
 * Read4Bits - Convert aligner 4-bits to a delay value
 */
static UBYTE Read4Bits(UBYTE *reg)
{
/* Clock bits are in time sequence (rvs from position in reg) 9 = invalid */
static const UBYTE EDGESORT[16] = {
	9,		// 0000
	0,		// 1000
	1,		// 0100
	0,		// 1100
	2,		// 0010
	9,		// 1010
	1,		// 0110
	0,		// 1110
	3,		// 0001
	3,		// 1001
	9,		// 0101
	3,		// 1101
	2,		// 0011
	2,		// 1011
	1,		// 0111
	9		// 1111
};

	UBYTE	alnbits,delay;

	alnbits = SerRead(reg) >> 4;
	delay = EDGESORT[alnbits];

	DBUG(print(DB_GEN,"4:%b=%b\n",alnbits,delay);)

	return(delay);
}


/*
 * SetVideoSkew - Set the video skew -- Bit 14 determines which aligner edge
 *						to use with this skew setting.  Bit 15 is a "lock" for this
 *						bit.  If the lock bit = 1, will use aligner edge in bit 14.
 *						If lock bit = 0, will determine best edge to use, select it,
 *						set lock=1, & assert that value into bit 14 of the VAR skew
 *						(presumably to be saved with the skew value)
 */
void SetVideoSkew(UBYTE	chan,
						UWORD	*skew)
{
	register UBYTE	*crsreg,*finereg,*alnreg;
	UBYTE	fine,coarse,edge,theedge,clkbits,skwbits,alnbits;
	UBYTE	keep,phasebit,baseline;
	ULONG	timeout;

	#define	EDGELOCKED	(1<<15)		// Edge is locked
	#define	LOCKEDGE		(1<<14)		// Edge for lock (if locked)

	/* Clock bits appear in time sequence (reverse from position in reg) */
	/* 0 = invalid, 1 = use positive edge, 2 = use negative edge */
static const EDGEPICK[16] = {
	0,		// 0000
	1,		// 1000
	2,		// 0100
	1,		// 1100
	2,		// 0010
	0,		// 1010
	2,		// 0110  VERIFIED
	1,		// 1110
	1,		// 0001
	1,		// 1001  VERIFIED
	0,		// 0101
	1,		// 1101
	2,		// 0011
	2,		// 1011
	2,		// 0111
	0		// 1111
};

	if (chan == 0)
	{
		baseline	= SkewBases[0];
		crsreg	= &Skew_serchip->APHASEC;		// DAC A
		finereg	= &Skew_serchip->APHASEF;
		alnreg	= &Align_serchip->DACACTRL;
	}
	else if (chan == 1)
	{
		baseline	= SkewBases[1];
		crsreg	= &Skew_serchip->BPHASEC;		// DAC B
		finereg	= &Skew_serchip->BPHASEF;
		alnreg	= &Align_serchip->DACBCTRL;
	}
	else
	{
		baseline	= SkewBases[1];
		crsreg	= &Skew_serchip->BPHASEC;		// A/D
		finereg	= &Skew_serchip->BPHASEF;
		alnreg	= &Align_serchip->ADCTRL;
	}

	edge		= (*skew >> 7) & 0x3;
	coarse	= (*skew >> 3) & 0xF;
	fine		= *skew & 0x7;

	DBUG(print(DB_GEN,"(%b) Edge=%b, coarse=%b, fine=%b\n",chan,edge,coarse,fine);)

	/* Set hardware skew registers */
	*finereg	= fine;
	*crsreg	= (edge * 64) + coarse;

	/* Does the other way seem better? */
	if (OutOfPhase(alnreg,baseline,edge,coarse))
	{
		theedge = (edge+2) & 0x3;				// Opposite MSB of edge
		*crsreg = (theedge * 64) + coarse;

		DBUG(printchar(DB_GEN,'-');)

		/* But does the other way seem better? */
		if (OutOfPhase(alnreg,baseline,edge,coarse))
		{
			/* 50% tie-breaker here */
			if (edge & 1)
			{
				/* Revert to original way */
				*crsreg = (edge * 64) + coarse;

				DBUG(printchar(DB_GEN,'-');)
			}
		}
	}
	else
	{
		DBUG(printchar(DB_GEN,'+');)
	}


	/********************************************************************/
	/*** Now we adjust the aligner to get valid samples in the TM bus ***/
	/********************************************************************/

	if (EDGELOCKED & *skew)					// Edge locked?
	{
		if (LOCKEDGE & *skew)
			phasebit = 1;
		else
			phasebit = 0;

		DBUG(print(DB_GEN,"Locked to edge %b\n",phasebit);)
	}
	else
	{
		timeout = 100;
		do
		{
			skwbits = SerRead(finereg) >> 4;
			alnbits = SerRead(alnreg) >> 4;

			if (chan == 2)
			{
				/* Retard 'RecFudge' bits in record mode */
				clkbits = Rotate4Bits(alnbits,RecFudge);
			}
			else
			{
				/* Retard 'PlayFudge' bits in play mode */
				clkbits = Rotate4Bits(alnbits,PlayFudge);
			}

			theedge = EDGEPICK[clkbits];

			timeout--;
		} while ((theedge == 0) && (timeout != 0));

		if (theedge == 2)					// If "falling", set PHASE bit to 1
			phasebit = 1;
		else
			phasebit = 0;					// If "rising", set PHASE bit to 0

		DBUG(
			print(DB_GEN,"Based on A:%b S:%b >%b<\n",alnbits,skwbits,clkbits);
			print(DB_GEN,"I pick edge %b\n",phasebit);
		)

		*skew |= EDGELOCKED;					// Set "lock" bit

		if (phasebit != 0)
			*skew |= LOCKEDGE;				// Set phase bit == 1
		else
			*skew &= ~LOCKEDGE;				// Set phase bit == 0
	}

	if (phasebit == 1)					// If "falling", set PHASE bit to 1
		theedge = 2;
	else
		theedge = 0;						// If "rising", set PHASE bit to 0

	if (chan == 0)
		keep = 0 + theedge;				// Time Mux bus channel 0
	else if (chan == 1)
		keep = 1 + theedge;				// Time Mux bus channel 1
	else
		keep = 0 + theedge;				// Time Mux bus channel 0

	*alnreg = keep;

	DBUG(
		print(DB_GEN,"TMB align = %b [%b]\n",keep,clkbits);
		print(DB_GEN,"----------------\n");
	)
}


/*
 * CheckSkew - Check skew, correct flip-flop if necessary
 */
void CheckSkew(UBYTE	chan,
					UWORD	skew)
{
	register UBYTE	*crsreg,*alnreg;
	UBYTE	baseline,edge,coarse,theedge;

	if (chan == 0)
	{
		baseline	= SkewBases[0];
		crsreg	= &Skew_serchip->APHASEC;		// DAC A
		alnreg	= &Align_serchip->DACACTRL;
	}
	else if (chan == 1)
	{
		baseline	= SkewBases[1];
		crsreg	= &Skew_serchip->BPHASEC;		// DAC B
		alnreg	= &Align_serchip->DACBCTRL;
	}
	else
	{
		baseline	= SkewBases[1];
		crsreg	= &Skew_serchip->BPHASEC;		// A/D
		alnreg	= &Align_serchip->ADCTRL;
	}

	edge		= (skew >> 7) & 0x3;
	coarse	= (skew >> 3) & 0xF;

	DBUG(print(DB_GEN,"Checking (%b) %b,%b,xx\n",chan,edge,coarse);)

	/* Determine edge that is currently programmed */
	theedge = SerRead(crsreg) >> 6;

	/* Has flip-flop flipped? */
	if (OutOfPhase(alnreg,baseline,edge,coarse))
	{
		theedge = (theedge+2) & 0x3;				// Opposite MSB of edge
		*crsreg = (theedge * 64) + coarse;

		DBUG(printchar(DB_GEN,'-');)

		/* But does the other way seem better? */
		if (OutOfPhase(alnreg,baseline,edge,coarse))
		{
			theedge = (theedge+2) & 0x3;			// Opposite MSB of edge
			*crsreg = (theedge * 64) + coarse;

			DBUG(printchar(DB_GEN,'-');)
		}
	}
	else
	{
		DBUG(printchar(DB_GEN,'+');)
	}
}


/*
 * DiffDelay - Measure difference between 2 delay values
 */
static UBYTE DiffDelay(	UBYTE	val1,
								UBYTE	*val2)
{
	if ((val1 == 9) || (*val2 == 9))			// Either illegal, return illegal
		return(9);

	if (*val2 < val1)								// Adjust 2nd arg to make rational
		*val2 += 4;

	return((UBYTE)(*val2-val1));				// Difference
}


/*
 * OutOfPhase - Decide if we are 180 degrees out (clk MSB is off)
 */
static BOOL OutOfPhase(	UBYTE	*reg,
								UBYTE	base,
								UBYTE	edge,
								UBYTE	coarse)
{
	UBYTE	predict;
	UBYTE	actual;
	UBYTE	legal1;
	UBYTE	legal2;
	UBYTE	legal3;

	/* Make prediction about where skew should be */
	predict	= base + (edge*2);			// Factor in the edge value

	if (coarse >= 8)							// Factor in the coarse value
		predict += 2;
	else if (coarse >= 3)
		predict++;

	predict	&= 0x7;							// Wraps around from 7 to 0

	/* Compute 2 legal values for skew */
	legal1 = ((predict + 7) & 0x7) >> 1;		// -1
	legal2 = predict >> 1;							// +0
	legal3 = ((predict + 1) & 0x7) >> 1;		// +1

	/* Now take actual skew reading */
	actual	= Read4Bits(reg);

	DBUG(
		print(DB_GEN,"OOP:pred=%b leg1=%b leg2=%b leg3=%b ",
			predict,legal1,legal2,legal3);
		print(DB_GEN,"act=%b\n",actual);
	)

	/* Is this close enough to say we're okay? */
	if ((actual == legal1) || (actual == legal2) || (actual == legal3))
		return(FALSE);
	else
		return(TRUE);
}


/*
 * EnsureColorPhase - make sure we still have good phase calibration
 */
void EnsureColorPhase(void)
{
	if (VideoMode == VM_PLAY)
	{
		CheckSkew(0,PlaySkewA);
		CheckSkew(1,PlaySkewB);
	}
	else if (VideoMode == VM_RECORD)
	{
		CheckSkew(2,RecSkew);
	}
}


/*
 * Rotate4Bits - Rotate a 4-bit value by 'n' bits to left
 */
static UBYTE Rotate4Bits(	UBYTE	input,
									UWORD	count)
{
	register ULONG	val;

	val = input;
	while (count--)
	{
		/* Rotate left */
		val <<= 1;
		if (0x10 & val)
			val++;
	}
	return((UBYTE)(val & 0xF));
}


/*
 * SetPedestal - Set one of the output pedestal register
 */
void SetPedestal(	UBYTE	chan,
						UBYTE	value)
{
	DBUG(print(DB_GEN,"(%b) ped=%b\n",chan,value);)

	if (chan == 0)
		TR_serchip->VPEDA = value;
	else
		TR_serchip->VPEDB = value;
}


/*
 * PickFirSet - Select FIR coefficient bank
 */
void PickFirSet(	UBYTE	chan,
						UBYTE	value)
{
	BOOL	seta;
	BOOL	setb;

	DBUG(print(DB_GEN,"FIR (%b) =%b\n",chan,value);)

	if (VideoMode == VM_RECORD)
	{
		seta = TRUE;							// Recording: set both FIR levels
		setb = TRUE;
	}
	else
	{
		if (chan == 0)
		{
			seta = TRUE;						// Playing: just set spec'd chan
			setb = FALSE;
		}
		else
		{
			seta = FALSE;
			setb = TRUE;
		}
	}

	if (seta)
		TR_serchip->COEFA = value;

	if (setb)
		TR_serchip->COEFB = value;
}


/*
 * DetectTBC - detect if TBC is present
 */
void DetectTBC(void)
{
#define	TBC_TESTVAL 0x7E

struct TBCSTUFF {
	UBYTE	reg;
	UBYTE	data;
};

#define	SERREG	0x00
#define	BT261		0x40
#define	BT812		0x80
#define	BT858		0xC0

static const struct TBCSTUFF	TBCSETUP[] = {
	BT261+0x00,0x88,	// Cmd Reg 0
	BT261+0x01,0xCB,	// Cmd Reg 1
	BT261+0x02,0xF1,	// Cmd Reg 2
	BT261+0x03,0x96,	// Cmd Reg 3
	BT261+0x04,0x96,	// Vsync sample
	BT261+0x05,0x02,	// Osc count low
	BT261+0x06,0x02,	// Osc count high
	BT261+0x07,0x00,	// Status
	BT261+0x08,0x42,	// HSync start low
	BT261+0x09,0x00,	// HSync start high
	BT261+0x0A,0x00,	// HSync stop low
	BT261+0x0B,0x00,	// HSync stop high
	BT261+0x0C,0x76,	// Clamp start low
//	BT261+0x0C,0x86,	// Clamp start low (old)
	BT261+0x0D,0x00,	// Clamp start high
	BT261+0x0E,0x70,	// Clamp stop low
//	BT261+0x0E,0x00,	// Clamp stop low (old)
	BT261+0x0F,0x03,	// Clamp stop high
//	BT261+0x0F,0x00,	// Clamp stop high
	BT261+0x10,0x32,	// Zero start low
	BT261+0x11,0x00,	// Zero start high
	BT261+0x12,0x58,	// Zero stop low
//	BT261+0x12,0x66,	// Zero stop low
	BT261+0x13,0x03,	// Zero stop high
	BT261+0x14,0xBC,	// Field gate start low
	BT261+0x15,0x02,	// Field gate start high
	BT261+0x16,0xFA,	// Field gate stop low
	BT261+0x17,0x00,	// Field gate stop high
	BT261+0x18,0xD0,	// Noise gate start low
	BT261+0x19,0x07,	// Noise gate start high
	BT261+0x1A,0x00,	// Noise gate stop low
	BT261+0x1B,0x00,	// Noise gate stop high
	BT261+0x1C,0x8D,	// HCount start low
	BT261+0x1D,0x03,	// HCount start high

	BT858+0x00,0x00,	// CR0
	BT858+0x01,0x0C,	// CR1
	BT858+0x02,0xF0,	// CR2
	BT858+0x03,0x06,	// CR3
	BT858+0x04,0x30,	// CR4
	BT858+0x06,0x00,	// P1 low
	BT858+0x07,0x02,	// P1 high
	BT858+0x08,0x00,	// P2 low
	BT858+0x09,0x00,	// P2 high
	BT858+0x0A,0x00,	// Fsc low
	BT858+0x0B,0x00,	// Fsc high
	BT858+0x0C,0x8E,	// HCount low
	BT858+0x0D,0x03,	// HCount high
	BT858+0x0E,0x00,	// Color key 0
	BT858+0x0F,0xFF,	// Color mask 0
	(UBYTE)OFFST(TBC_regs,PIXELMASK),0xFF,		// Pixel mask

	BT858+0x00,0xA0,	// CR0 -- Changed!
	BT858+0x01,0x0C,	// CR1
	BT858+0x02,0xF0,	// CR2
	BT858+0x03,0x02,	// CR3 -- Changed!
	BT858+0x04,0x30,	// CR4
	BT858+0x06,0x00,	// P1 low
	BT858+0x07,0x02,	// P1 high
	BT858+0x08,0x00,	// P2 low
	BT858+0x09,0x00,	// P2 high
	BT858+0x0A,0x00,	// Fsc low
	BT858+0x0B,0x00,	// Fsc high
	BT858+0x0C,0x8E,	// HCount low
	BT858+0x0D,0x03,	// HCount high
	BT858+0x0E,0x00,	// Color key 0
	BT858+0x0F,0xFF,	// Color mask 0
	(UBYTE)OFFST(TBC_regs,PIXELMASK),0xFF,		// Pixel mask

	BT812+0x3F,0x00,	// Reset chip
	BT812+0x00,0x00,	// Input select
	BT812+0x01,0x80,	// reserved
	BT812+0x02,0x00,	// Status/ADC
	BT812+0x03,0xC0,	// Output format
	BT812+0x04,0x08,	// Mode select
	BT812+0x05,0x00,	// Input format
	BT812+0x06,0x00,	// Clock def
	BT812+0x07,0x00,	// Video timing
	BT812+0x08,0x00,	// Brightness
	BT812+0x09,0x80,	// Contrast
	BT812+0x0A,0x80,	// Saturation
	BT812+0x0B,0x00,	// Hue
	BT812+0x0C,0x8E,	// HClock low
	BT812+0x0D,0x03,	// HClock high
	BT812+0x0E,0x88,	// HDelay low
	BT812+0x0F,0x00,	// HDelay high
	BT812+0x10,0xF1,	// Active pixels low
	BT812+0x11,0x02,	// Active pixels high
	BT812+0x12,0x0C,	// VDelay low
	BT812+0x13,0x00,	// VDelay high
	BT812+0x14,0xE4,	// Active lines low
	BT812+0x15,0x01,	// Active lines high
	BT812+0x16,0x00,	// P low
	BT812+0x17,0x00,	// P med
	BT812+0x18,0x10,	// P high
	BT812+0x19,0x68,	// AGC delay
	BT812+0x1A,0x53,	// Burst delay
	BT812+0x1B,0x00,	// Sample rate low
	BT812+0x1C,0x00,	// Sample rate high
	BT812+0x1D,0x35,	// Video timing polarity

	(UBYTE)OFFST(TBC_regs,CTRL),0x81,	// Term comp in, Select Flyer comp jack
	(UBYTE)OFFST(TBC_regs,KEYER),0x80	// Live video
};
#define	TBCSETUPENTRIES	(sizeof(TBCSETUP)/sizeof(struct TBCSTUFF))

	register TBC *tbc = TBC_serchip;
	UBYTE	reg;
	UBYTE	data;
	UBYTE	group;
	ULONG	index,delay;

	DBUG(print(DB_GEN,"TBC detection...");)

	tbc->DECADDR = 9;						// Select contrast register
	tbc->DECDATA = TBC_TESTVAL;		// Set to about half scale
	tbc->DECADDR = 9;						// Select contrast register
	data = SerRead(&tbc->DECDATA);	// Read back out

	/* NOTE: Unimplemented serial addresses will usually return FF */

	if (data != TBC_TESTVAL)
	{
		DBUG(print(DB_GEN,"NONE!\n");)
		TBCpresent = FALSE;
		return;
	}

	DBUG(print(DB_GEN,"Found - setting up\n");)

	/* Setup TBC to default configuration (output bars) */
	for (index=0;index < TBCSETUPENTRIES;index++)
	{
		for (delay=5000;delay;delay--) {}

// Maybe put a big delay here, because TBC fails to take init list fast

		reg = TBCSETUP[index].reg;
		data= TBCSETUP[index].data;
		group = reg >> 6;
		reg	&= 0x3F;
		if (reg == 0x3F)
			reg = 0xFF;

		switch (group)
		{
			case 0: 		// Serial register direct
				*(reg + (UBYTE *)TBC_serchip) = data;		// Write data to serial address
				break;
			case 1: 		// BT261
				tbc->GENADDR = reg;			// Select register
				tbc->GENDATA = data;			// Write data
				break;
			case 2:		// BT812
				tbc->DECADDR = reg;			// Select register
				tbc->DECDATA = data;			// Write data
				break;
			case 3: 		// BT858
				tbc->ENCADDR = reg;			// Select register
				tbc->ENCDATA = data;			// Write data
				break;
		}
	}

	TBCpresent = TRUE;
	TBC_DecInpFmt = 0;			// Default to local storage
}


/*
 * TBC_cmd - Control/check TBC module
 */
void TBC_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		ptr;
		UBYTE		oper;
	};

	struct TBCctrl {
		UBYTE		Status;
		UBYTE		Flags;
		UBYTE		DecFlags;
		UBYTE		EncFlags;
		UBYTE		InputSel;
		UBYTE		Term;
		UBYTE		Bright;
		UBYTE		Contrast;
		UBYTE		Sat;
		UBYTE		Hue;
		UWORD		Phase;
		UWORD		HorAdj;
		UBYTE		Fader;
		UBYTE		KeyFlags;
	};

#define	TBCOP_STATUS	(1<<0)
#define	TBCOP_MODES		(1<<1)
#define	TBCOP_ADJUST	(1<<2)

#define	TBCSTS_MODULE	(1<<0)
#define	TBCSTS_VIDEO	(1<<1)
#define	TBCSTS_STABLE	(1<<2)

#define	TBCFLG_BYPASS	(1<<0)
#define	TBCFLG_FREEZE	(1<<1)

#define	TBCDEC_AGC		(1<<0)
#define	TBCDEC_CHRAGC	(1<<1)
#define	TBCDEC_MONO		(1<<2)

#define	TBCENC_BARS			(1<<0)
#define	TBCENC_KILLCOLOR	(1<<1)

#define	KEY_SRC_B		(1<<0)		// Is from source B as opposed to A
#define	KEY_MODE0		(1<<1)		// Keyer is enabled
#define	KEY_MODE1		(1<<2)		// Is 2 bits as opposed to 1 bit
#define	KEY_FADEROUT	(1<<3)		// FADEROUT

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	register struct TBCctrl	*ctrl;
	register TBC *tbc = TBC_serchip;
	UBYTE	data;
	BYTEBITS	bits;
	UBYTE	zero = 0;

	ctrl = (struct TBCctrl *)(cmdptr->ptr + SRAMbase);	// Get address of structure

//	if ((1<<3) & cmdptr->oper)		// Testing only!
//		DetectTBC();

	/* Wants to set values? Make sure TBC exists */
	if ((TBCOP_MODES & cmdptr->oper) || (TBCOP_ADJUST & cmdptr->oper))
	{
		/* We have a TBC? */
		if (!TBCpresent)
		{
			ctrl->Status = 0;
			cmdptr->error = ERR_CMDFAILED;
			return;
		}
	}

	/* Wants to adjust modes? */
	if (TBCOP_MODES & cmdptr->oper)
	{
		bits = ctrl->Term & 0xBC;					// Just legal termination bits
		if (TBCFLG_BYPASS & ctrl->Flags)
		{
			bits |= TBCCTLF_PASS;
			DBUG(print(DB_GEN,"***pass***\n");)
		}
		DBUG(print(DB_GEN,"InputSel = %b\n",ctrl->InputSel);)
		switch (ctrl->InputSel & 0x3)
		{
			case 0: data = 1;	break;
			case 1: data = 1;	break;
			case 2: data = 0;	break;
			case 3: data = 2;	break;
		}
		bits |= data;								// OR in input select bits
		tbc->CTRL = bits;							// Set TBC control bits
		DBUG(print(DB_GEN,"Input = %b, CTRL=%b\n",data,bits);)

		bits = TDEC_MDF_LOCLRDET;					// Default: low color det. enabled
		if (TBCDEC_AGC & ctrl->DecFlags)
			bits |= TDEC_MDF_AGC;

		if (TBCDEC_CHRAGC & ctrl->DecFlags)
			bits |= TDEC_MDF_CHROMAAGC;

		tbc->DECADDR = TDREG_MODES;			// CR4
		tbc->DECDATA = bits;						// Write data to CR4
		DBUG(print(DB_GEN,"Dec 4 = %b\n",bits);)

		bits = TBC_DecInpFmt;						// Get out of storage
		if (TBCDEC_MONO & ctrl->DecFlags)
			bits |= TDEC_IFMTF_MONO;				// Mono
		else
			bits &= ~TDEC_IFMTF_MONO;				// Color
		TBC_DecInpFmt = bits;			// Back to storage (Used by "TBCpick")

		TBCpick(ctrl->InputSel);		// Setup for Y/C or composite

		bits = 0;							// Default:
		if (TBCENC_BARS & ctrl->EncFlags)
		{
			bits |= TENC_OFMTF_BARS;
			data = TENC_IFMT_RGB24;		// CR0 = 24 bit RGB
		}
		else
		{
			data = TENC_IFMT_YCrCb16;	// CR0 = 16-bit YCrCb
		}

		if (TBCENC_KILLCOLOR & ctrl->EncFlags)
			bits |= TENC_OFMTF_KILLCLR;

		tbc->ENCADDR = zero;				// TEREG_INPFORMAT
		tbc->ENCDATA = data<<4;			// Write data to CR0
		DBUG(print(DB_GEN,"Enc 0 = %b\n",data);)

		tbc->ENCADDR = TEREG_OUTFORMAT;	// CR3
		tbc->ENCDATA = bits;					// Write data to CR3
		DBUG(print(DB_GEN,"Enc 3 = %b\n",bits);)

		/* Keyer stuff */
		bits = ctrl->KeyFlags | TBCKEYF_FREEZE;
		if (TBCFLG_FREEZE & ctrl->Flags)
			bits &= ~TBCKEYF_FREEZE;

//		if (KEY_SRC_B & ctrl->KeyFlags)
//			bits |= TBCKEYF_SRC;
//
//		if (KEY_MODE0 & ctrl->KeyFlags)
//			bits |= TBCKEYF_MD0;
//
//		if (KEY_MODE1 & ctrl->KeyFlags)
//			bits |= TBCKEYF_MD1;
//
//		if (KEY_FADEROUT & ctrl->KeyFlags)
//			bits |= TBCKEYF_OUTMUX;

		tbc->KEYER = bits;
	}

	/* Wants to adjust values? */
	if (TBCOP_ADJUST & cmdptr->oper)
	{
		tbc->DECADDR = TDREG_BRIGHT;			// Start at brightness register

		tbc->DECDATA = ctrl->Bright * 2;		// Write data
		tbc->DECDATA = ctrl->Contrast * 2;	// Write data
		tbc->DECDATA = ctrl->Sat * 2;			// Write data
		tbc->DECDATA = ctrl->Hue * 2;			// Write data
		DBUG(print(DB_GEN,"TBC BCSH = %b %b %b %b\n",
			ctrl->Bright * 2,ctrl->Contrast * 2,ctrl->Sat * 2,ctrl->Hue * 2);)

		tbc->ENCADDR = TEREG_PHASELO;			// Start at Fsc low register
		tbc->ENCDATA = ctrl->Phase & 0xFF;	// Write low data
		tbc->ENCDATA = ctrl->Phase >> 8;		// Write high data
		DBUG(print(DB_GEN,"TBC Phase = %b/%b\n",ctrl->Phase>>8,ctrl->Phase & 0xFF);)

		tbc->GENADDR = TGREG_ZEROSTOPLO;		// Start at Zero stop low register
		tbc->GENDATA = ctrl->HorAdj & 0xFF;	// Write low data
		tbc->GENDATA = ctrl->HorAdj >> 8;	// Write high data
		DBUG(print(DB_GEN,"TBC Horiz = %b/%b\n",ctrl->HorAdj>>8,ctrl->HorAdj & 0xFF);)

		tbc->FADER = ctrl->Fader;				// Set fader value
		DBUG(print(DB_GEN,"Fader = %b\n",ctrl->Fader);)
	}

	/* Wants status bits updated? */
	if (TBCOP_STATUS & cmdptr->oper)
	{
		ctrl->Status = 0;
		if (TBCpresent)
		{
			ctrl->Status |= TBCSTS_MODULE;

			tbc->DECADDR = TDREG_STATUS;		// Read status flags
			data = SerRead(&tbc->DECDATA);	// Read back out
			if (TDEC_STF_VIDPRESENT & data)
				ctrl->Status |= TBCSTS_VIDEO;

			if (TDEC_STF_VIDSTABLE & data)
				ctrl->Status |= TBCSTS_STABLE;

		}
	}
}


/*
 * TBCpick - pick type of TBC input: Y/C or Composite
 */
static void TBCpick(UBYTE type)
{
	register TBC *tbc = TBC_serchip;
	UBYTE	data;
	BYTEBITS	bits;
	UBYTE	zero = 0;

	if (TBCpresent)
	{
		if (type == 0)
			data = 0x28;			// Y/C muxes
		else
			data = 0x00;			// Composite muxes

		tbc->DECADDR = zero;		// CR0
		tbc->DECDATA = data;		// Write data to CR0

		bits = TBC_DecInpFmt;		// Get out of storage
		if (type == 0)
			bits |= TDEC_IFMTF_YC;	// Y/C source
		else
			bits &= ~TDEC_IFMTF_YC;	// Composite source

		TBC_DecInpFmt = bits;	// Back to storage
		tbc->DECADDR = TDREG_INPFORMAT;	// CR5
		tbc->DECDATA = bits;					// Write data to CR5
		DBUG(print(DB_GEN,"Dec 5 = %b\n",bits);)
	}
}


/*
 * GetDefaults -- set defaults (read parameters from EEPROM)
 */
void GetDefaults(void)
{
	UBYTE	err;
	UWORD	magicvalue,vco,aword;

	Routing = DFLT_ROUTING;					// Sync and video from Toaster Main
	InputSource = 4;							// Ditto

	BoardRev = 0;
	err = EEread(NVOL_BOARDREV,&BoardRev);		// Read board rev from EEPROM

	GlobalOptions = 0;
	err = EEread(NVOL_OPTIONSHI,&aword);			// Read hi 16 options
	GlobalOptions = (aword<<16);
	err = EEread(NVOL_OPTIONSLO,&aword);			// Read lo 16 options
	GlobalOptions |= aword;

	/*** Interpret some GlobalOptions ***/
	if (!(OPTF_NOT_HQ5 & GlobalOptions))
	{
		if(!(OPTF_NOT_HQ6 & GlobalOptions))
		{
			VeryHSVTASC = TRUE;
			HighSpeedVTASC = TRUE;
			DfltVidPrefs();		// Re-set default video prefs for new mode
		}
		else
		{
			VeryHSVTASC = FALSE;
			HighSpeedVTASC = TRUE;
			DfltVidPrefs();		// Re-set default video prefs for new mode
		}
	}

	/* Get hard-coded defaults */
	PlaySkewA	= 0x0000;
	PlaySkewB	= 0x0000;
	RecSkew		= 0x78;			// Was 0F -- coarse only
	PlayOffsetA	= 0xFFDD;		// -line + 377H
	PlayOffsetB	= 0xFFDD;		// -line + 377H
	RecOffsetA	= 21;
	RecOffsetB	= 21;
	PedestalA	= NTSC_BLANK;
	PedestalB	= NTSC_BLANK;

	/* Write default values to EEPROM if never setup */
	err = EEread(NVOL_MAJIC,&magicvalue);
	if ((err == ERR_OKAY) && (magicvalue != NVOL_SETUPMAGIC))
	{
		/* Write default values to EEPROM if never setup */
		err = EEread(NVOL_MAJIC,&magicvalue);
		if ((err == ERR_OKAY) && (magicvalue != NVOL_SETUPMAGIC))
		{

			EEwrite(NVOL_MAJIC,NVOL_SETUPMAGIC);
			EEwrite(NVOL_APLAYOFF,PlayOffsetA);
			EEwrite(NVOL_BPLAYOFF,PlayOffsetB);
			EEwrite(NVOL_ARECOFF,RecOffsetA);
			EEwrite(NVOL_BRECOFF,RecOffsetB);
			EEwrite(NVOL_DACAPHASE,PlaySkewA);
			EEwrite(NVOL_DACBPHASE,PlaySkewB);
			EEwrite(NVOL_ADCPHASE,RecSkew);
			EEwrite(NVOL_PEDESTALA,PedestalA);
			EEwrite(NVOL_PEDESTALB,PedestalB);
		}
	}


	/* Read saved settings from EEPROM */
	EEread(NVOL_APLAYOFF,&PlayOffsetA);
	EEread(NVOL_BPLAYOFF,&PlayOffsetB);
	EEread(NVOL_ARECOFF,&RecOffsetA);
	EEread(NVOL_BRECOFF,&RecOffsetB);
	EEread(NVOL_DACAPHASE,&PlaySkewA);
	EEread(NVOL_DACBPHASE,&PlaySkewB);
	EEread(NVOL_ADCPHASE,&RecSkew);
	EEread(NVOL_PEDESTALA,&PedestalA);
	EEread(NVOL_PEDESTALB,&PedestalB);
	EEread(NVOL_SKEWBASELINE,&aword);
	SkewBases[0] = (aword >> 3) & 0x7;
	SkewBases[1] = aword & 0x7;

	// Force genlock controller to correct calibrated value
	// This is weak, but it's better than using a default for all boards
	// Really need to unlock timer/router and send and auto-cal to PLL
	EEread(NVOL_PLLNULL,&vco);
	if (vco != 0xFFFF)
	{
		GenlockExchange(0x82);
		GenlockExchange(vco >> 8);
		GenlockExchange(vco & 0xFF);
		DBUG(print(DB_GEN,"PLL target = %w\n",vco);)
	}
}
