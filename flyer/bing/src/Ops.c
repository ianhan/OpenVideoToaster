/*********************************************************************\
*
* $Ops.c - Miscellaneous operations$
*
* $Id: Ops.c,v 1.7 1995/11/21 12:01:11 Flick Exp $
*
* $Log: Ops.c,v $
*Revision 1.7  1995/11/21  12:01:11  Flick
*Removed CallMod()
*
*Revision 1.6  1995/10/26  17:44:03  Flick
*Added (crippled) Flooby test items
*
*Revision 1.5  1995/10/10  01:19:38  Flick
*Ammended call to CopyData slightly due to change in args.
*
*Revision 1.4  1995/09/07  09:31:08  Flick
*Made SCSI read test double-buffering optional (on #define).  Is on now.
*(Release 4.06)
*
*Revision 1.3  1995/08/15  17:14:34  Flick
*First release (4.05)
*
*Revision 1.2  1995/05/04  17:15:27  Flick
*Phx/Flyer duality improved, lots of stub code moved into AmiShar.c
*
*Revision 1.1  1995/05/03  10:46:35  Flick
*Automated prototypes, and reduced includes when possible
*
*Revision 1.0  1995/05/02  11:07:12  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	08/24/94		Marty	created
*	02/06/95		Marty	Ported to C
\*********************************************************************/

#define	LOCALDEBUG		0			// Debugging switch for this module only

#include <Types.h>
#include <Flyer.h>
#include <Errors.h>
#include <Ops.h>
#include <SMPTE.h>
#include <Exec.h>
#include <Chips.h>
#include <Vid.h>
#include <Switcher.h>
#include <SCSI.h>
#include <Debug.h>

#include <proto.h>
#include <Ops.ps>

extern const ULONG SRAMbase;		// Base of shared SRAM memory map
extern UBYTE	BarType;
extern UBYTE	VideoMode;
extern UWORD	PlaySkewA,PlaySkewB,RecSkew;
extern UWORD	PlayOffsetA,PlayOffsetB,RecOffsetA,RecOffsetB;
extern UWORD	PedestalA,PedestalB;
extern ULONG	GlobalOptions;
extern BOOL		HighSpeedVTASC;

struct SMPTEINFO	LastSMPTE;		// Latest SMPTE Time-Code



/**************************/
/*   Operation Routines   */
/**************************/

/*
 *	Firmware - Run supplied control software
 */
void Firmware(APTR ptr)
{
	DBUG(print(DB_ALWAYS,"Code already running!\n");)
}

#if 0
/*
 *	CallMod - Call supplied software module
 */
void CallMod(APTR ptr)
{
#if DEBUG
	struct	CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UWORD		argc;
		UWORD		rev;
		ULONG		arg1;
		ULONG		arg2;
		ULONG		arg3;
		ULONG		arg4;
		ULONG		arg5;
		ULONG		arg6;
	};

	typedef void (*ROUT)(APTR);

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	APTR	addr;
	ROUT	sub;

	addr = (APTR)DATABASE;					// Calculate address of code

	cmdptr->rev = GetRevision();

	sub = (ROUT) addr;						// Assign addr to Procedure type

	DBUG(print(DB_ALWAYS,"->");)

	sub(ptr);									// Call code

	DBUG(
		if (cmdptr->error == ERR_BADMODULE)
			print(DB_ALWAYS,"Module is incompatible with the code which is running\n");
	)
#endif
}
#endif

/*
 * CpuDma_cmd - Dma CPU SRAM <w---r> DMA buffer
 */
void CpuDma_cmd(APTR ptr)
{

	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		ULONG		cpu;
		ULONG		dma;
		UWORD		blkcnt;
		BOOL		readflg;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	UWORD	cpuadr;
	UWORD	dmaadr;

	dmaadr = (UWORD) cmdptr->dma;
	cpuadr = (UWORD) cmdptr->cpu;

	DBUG(print(DB_DMA,"DMA - cpu:%l dma:%l len:%w read:%b\n",
			cmdptr->cpu,cmdptr->dma,cmdptr->blkcnt,(ULONG)cmdptr->readflg);)

	/* Start DMA Transfer */
	CpuXferMemWait((APTR)((cpuadr<<9) + SRAMbase),
		dmaadr,cmdptr->blkcnt,cmdptr->readflg);
}


#ifdef PHXCODE

const struct	SwitcherItem	SWlist_hide[] = {
	SWIT_REG_AMUX,		MM_VID1,
	SWIT_REG_BMUX,		MM_VID1,
	SWIT_REG_PVMUX,	PM_VID1
};
const struct	SwitcherItem	SWlist_appear[] = {
	SWIT_REG_AMUX,		MM_FLYA,
	SWIT_REG_FADER,	0x00,
	SWIT_REG_PVMUX,	PM_FLYB
};

/*
 *	PlayModeAuto - Set Flyer into play mode using data in ROM
 */
void PlayModeAuto(void)
{
	int	i;

	DBUG(print(DB_GEN,"Auto play mode...\n");)

	// Remove all Flyer video paths
	SendSwitcherList((APTR)SWlist_hide,sizeof(SWlist_hide),TRUE);

	NoMode();					// Ensure video dead

	for (i=3;i<=6;i++)
		UnPgmFPGA(i);			// Unprogram all VTASC chips

	ConfigROMchip(FPGA_PCODER1,VM_PLAY);	// Set P clk and configure both P-coders
	ConfigROMchip(FPGA_MCODER1,VM_PLAY);	// Set M clk and configure both M-coders

	PlayMode();								// Go into play mode

	// Route FlyA to Main, FlyB to preview
	SendSwitcherList((APTR)SWlist_appear,sizeof(SWlist_appear),FALSE);
}


/*
 *	RecModeAuto - Set Flyer into record mode using data in ROM
 */
void RecModeAuto(void)
{
	int	i;

	DBUG(print(DB_GEN,"Auto record mode...\n");)

	// Remove all Flyer video paths
	SendSwitcherList((APTR)SWlist_hide,sizeof(SWlist_hide),TRUE);

	NoMode();					// Ensure video dead
	for (i=3;i<=6;i++)
		UnPgmFPGA(i);			// Unprogram all VTASC chips

	ConfigROMchip(FPGA_PCODER1,VM_RECORD);	// Set P clk and configure both P-coders
	ConfigROMchip(FPGA_MCODER1,VM_RECORD);	// Set M clk and configure both M-coders

	RecordMode();

	// Route FlyA to Main, FlyB to preview
	SendSwitcherList((APTR)SWlist_appear,sizeof(SWlist_appear),FALSE);
}

#endif


/*
 *	NoMode_cmd - Set Flyer in neither play nor record mode
 */
void NoMode_cmd(APTR ptr)
{
	ULONG	i;
//	UBYTE	err;

//	/* Kill video output during transition - may look prettier */
//	TR_serchip->MapRamFlags = MRF_Test;		// Disable FIR now
//	/* Toaster sync may bobble, so get off it for a while */
//	Skew_serchip->ROUTE = 0x22;		// Sync from Toaster input 1

	NoMode();					// Ensure video dead
	for (i=3;i<=6;i++)
		UnPgmFPGA(i);			// Unprogram all VTASC chips
}


/*
 *	GetSMPTE - Copy latest SMPTE structure
 */
void GetSMPTE(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		infoptr;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	CopyMem(&LastSMPTE,(APTR)(cmdptr->infoptr+SRAMbase),sizeof(struct SMPTEINFO));
	cmdptr->error = ERR_OKAY;
}


/*
 *	CopyData_cmd - Copy data from drive to drive (with verify someday?!)
 */
void CopyData_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		pad2;
		UBYTE		srcdrive;
		UBYTE		pad3;
		UBYTE		dstdrive;
		ULONG		addr;
		ULONG		blkcnt;
		ULONG		destaddr;
		UBYTE		verf;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	BOOL	verfflag;

	if (cmdptr->verf == 0)
		verfflag = FALSE;
	else
		verfflag = TRUE;

	DBUG(print(DB_OPS,"Copying from drive %b LBA %l to drive %b LBA %l\n",
		cmdptr->srcdrive,cmdptr->addr,cmdptr->dstdrive,cmdptr->destaddr);)

	cmdptr->error = CopyData(
		cmdptr->srcdrive,
		cmdptr->dstdrive,
		cmdptr->addr,
		cmdptr->destaddr,
		cmdptr->blkcnt,
		NULL						// Could tie in HostAbort here someday
	);
}


/*
 * SCSIcall - Do SCSI command
 */
void SCSIcall(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad1;
		UBYTE		error;
		UBYTE		pad1a;
		UBYTE		drive;
		UBYTE		cmd;
		UBYTE		pad2;
		ULONG		addr;
		UWORD		length;
		ULONG		extra;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	APTR	address;

	if (cmdptr->drive < NUMSCSIDRIVES)
	{
		address = (APTR)(cmdptr->addr+SRAMbase);		// Get address of data

		/* Do command and put result in error reg */
//		cmdptr->error = ScsiGeneric(cmdptr->drive,cmdptr->cmd,address,cmdptr->length,cmdptr->extra);
		cmdptr->error = DoSCSI(cmdptr->drive,cmdptr->cmd,
			cmdptr->extra,address,cmdptr->length);
		DBUG(print(DB_SCSI,"SCSI(%b) err:%b\n",cmdptr->cmd,cmdptr->error);)
	}
	else
		cmdptr->error = ERR_BADPARAM;						// Set Error code
}


/*
 *	ReadCapac - Read drive capacity
 */
void ReadCapac(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		pad2;
		UBYTE		drive;
		ULONG		_size;
		ULONG		_blklen;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	if (cmdptr->drive < NUMSCSIDRIVES)
	{
		/* Read drive capacity */
		cmdptr->error = ReadCapacity(cmdptr->drive,&cmdptr->_size,&cmdptr->_blklen);
	}
	else
		cmdptr->error = ERR_BADPARAM;							// Set Error code
}


/*
 *	Read10 - Do SCSI Read10 Command
 */
void Read10(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		pad2;
		UBYTE		drive;
		ULONG		lba;
		UWORD		length;
		ULONG		addr;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	if (cmdptr->drive < NUMSCSIDRIVES)
	{
		cmdptr->error = DoSCSI(cmdptr->drive,SCMD_READ,
			cmdptr->lba,(APTR)cmdptr->addr,cmdptr->length);
	}
	else
		cmdptr->error = ERR_BADPARAM;					// Set Error code
}


/*
 *	ReadTest - Perform drive read speed test
 */
UBYTE ReadTest(UBYTE	drive,
					ULONG	lba,
					ULONG	length,
					ULONG	repeat,
					UBYTE	flag)
{
#define	DBLBUFF_SPEEDTEST		1

	ULONG		blk;
	UBYTE		err;
#if DBLBUFF_SPEEDTEST
	struct ScsiMsg	msgs[2],*msg;
	int		i;
	UBYTE		this,last;
#endif

	LockVideoRAM();						// Must ensure video is shut down

#if DBLBUFF_SPEEDTEST
	for (i=0 ; i<2 ; i++)
	{
		msg = &msgs[i];

		msg->sm_Active = FALSE;
		msg->sm_SigBit = AllocSignal();
		DBUG(print(DB_SCSI,"SigBit %b\n",msg->sm_SigBit);)
	}

	err	= ERR_OKAY;
	blk	= lba;
	this	= 0;

	while ((repeat > 0) && (err == ERR_OKAY))
	{
		if (flag != 0)		// Double-buffer?
			last = 1-this;
		else
			last = this;

		/* Wait for old read to finish */
		if (msgs[this].sm_Active)
		{
			WaitSCSIdone(&msgs[this]);
//			timeout = 50000;
//			while ((!ScsiDone(skey[this],&err)) && (timeout != 0))
//			{
//				timeout--;
//			}
//			if (timeout == 0)
//			{
//				DBUG(print(DB_SCENG,"TIMEOUT!\n");)
//				err = 0x0E;
//				goto abort;
//			}
			msgs[this].sm_Active = FALSE;
		}

		if (err == ERR_OKAY)
		{
			StartSCSI(&msgs[this],drive,SCMD_READ,blk,NULL,length);
			msgs[this].sm_Active = TRUE;

			repeat--;
			blk += length;
		}
		this = last;
	}

	/* Wait for both reads to finish */
	for (i=0;i<=1;i++)
	{
		if (msgs[i].sm_Active)
		{
			WaitSCSIdone(&msgs[i]);

//			timeout = 50001+i;
//			while ((!ScsiDone(skey[i],&err)) && (timeout != 0))
//			{
//				timeout--;
//			}
//			if (timeout == 0)
//			{
//				DBUG(print(DB_SCENG,"TIMEOUT!\n");)
//
//				err = 0x0E;
//				goto abort;
//			}
		}
	}
#else
	err = ERR_OKAY;
	blk	= lba;
	while ((err==0) && (repeat > 0))
	{
		err = DoSCSI(drive,SCMD_READ,blk,0,length);
		repeat--;
		blk += length;
	}
#endif

abort:

#if DBLBUFF_SPEEDTEST
	for (i=0 ; i<2 ; i++)
	{
		FreeSignal(msgs[i].sm_SigBit);
	}
#endif

	UnLockVideoRAM();							// Okay for video to run now

	return(err);
}


/*
 *	WriteTest_cmd - Perform drive write test
 */
void WriteTest_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		pad2;
		UBYTE		drive;
		ULONG		lba;
		ULONG		length;
		ULONG		repeat;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
//	UBYTE	err;
	ULONG	addr;

	cmdptr->error = ERR_OKAY;
	addr	= cmdptr->lba;
	while ((cmdptr->error==0) && (cmdptr->repeat > 0))
	{
		cmdptr->error = DoSCSI(cmdptr->drive,SCMD_WRITE,addr,0,cmdptr->length);
		cmdptr->repeat--;
		addr += cmdptr->length;
	}
}


/*
 *	Write10 - Do SCSI Write10 Command
 */
void Write10(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		pad2;
		UBYTE		drive;
		ULONG		addr;
		UWORD		length;
		ULONG		lba;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	if (cmdptr->drive < NUMSCSIDRIVES)
	{
		cmdptr->error = DoSCSI(cmdptr->drive,SCMD_WRITE,cmdptr->lba,
			(APTR)cmdptr->addr,cmdptr->length);
	}
	else
		cmdptr->error = ERR_BADPARAM;					// Set Error code
}


/*
 *	SetFloobyDust - Set misc variables
 */
void SetFloobyDust(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		chan;
		UBYTE		item;
		ULONG		value;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	UBYTE	bval;
	UWORD	wval;
	UBYTE	out;
	ULONG	delay;
	UBYTE	err = ERR_OKAY;

	bval = (UBYTE)cmdptr->value;
	wval = (UWORD)cmdptr->value;

	switch (cmdptr->item)
	{
		case 0:	DBUG(DebugHelp(cmdptr->chan,cmdptr->value);)
					break;
		case 4:	GenlockExchange(4);
					delay = 500000;					// BIG delay for calibration
					do
					{
						delay--;
					} while (delay != 0);

					GenlockExchange(0x7F);			// Pull in high byte
					GenlockExchange(0x81);
					out = GenlockExchange(0);
					wval = out << 8;
					GenlockExchange(0x7F);			// Pull in low byte
					GenlockExchange(0x82);
					out = GenlockExchange(0);
					wval += out;
					err = EEwrite(NVOL_PLLNULL,wval);
					break;
		case 7:	SetClockFreq(cmdptr->chan,cmdptr->value);
					break;
		case 8:	SetClockGen(cmdptr->chan,cmdptr->value);
					break;
		case 9:	err = SetStillMode(cmdptr->chan,bval);
					break;
		case 10:	GenlockExchange(bval);
					break;
		case 11:	BarType = bval;
					DrawBar(bval);
					break;
		case 14:	ClrLEDs(63-bval);
					SetLEDs(bval);
					break;
		case 15:	SetVideoSkew(cmdptr->chan,&wval);
					break;
		case 16:	EstablishSkew();
					break;
#if 0
		case 17: SCSItarget(cmdptr->chan,bval);
					break;
		case 18: DSPdebug(cmdptr->value,&cmdptr->cont);
					break;
#endif
		case 69:
//	Ver 1			err = LowFormat(cmdptr->chan,cmdptr->value);
//	Ver 2			err = ScsiGeneric((cmdptr->chan * 8)+cmdptr->value,SCMD_FORMAT,NULL,0,0);
					err = DoSCSI((cmdptr->chan * 8)+cmdptr->value,SCMD_FORMAT,0,NULL,0);
					DBUG(print(DB_SCSI,"LOW FORMAT, err:%b\n",err);)
					break;
	}
	cmdptr->error = err;
}


/*
 *	WriteCalib - Use (and maybe save) calibration variables
 */
UBYTE WriteCalib(UWORD item, UWORD value, UBYTE saveit)
{
	UWORD	oldval;
	UBYTE	oldedge;
	UBYTE	oldcourse;
	UBYTE	oldfine;
	UBYTE	chan,error=ERR_OKAY;

	DBUG(print(DB_OPS,"WriteCalib %w with %w (%w)\n",item,value,saveit);)

	switch (item)
	{
		case CALIB_HPLAYOFFSETA:
			PlayOffsetA = value;
			if (VideoMode == VM_PLAY)
				SetVideoOffset(0,value);
			if (saveit != 0)
				error = EEwrite(NVOL_APLAYOFF,value);
			break;
		case CALIB_HPLAYOFFSETB:
			PlayOffsetB = value;
			if (VideoMode == VM_PLAY)
				SetVideoOffset(1,value);
			if (saveit != 0)
				error = EEwrite(NVOL_BPLAYOFF,value);
			break;
		case CALIB_HRECOFFSETA:
		case CALIB_HRECOFFSETB:
			RecOffsetA = value;
			RecOffsetB = value;
			if (VideoMode == VM_RECORD)
			{
				SetVideoOffset(0,value);
				SetVideoOffset(1,value);
			}
			if (saveit != 0)
			{
				error = EEwrite(NVOL_ARECOFF,value);
				error = EEwrite(NVOL_BRECOFF,value);
			}
			break;
		case CALIB_DACA_PHASE_EDGE:
		case CALIB_DACA_PHASE_COURSE:
		case CALIB_DACA_PHASE_FINE:
		case CALIB_DACB_PHASE_EDGE:
		case CALIB_DACB_PHASE_COURSE:
		case CALIB_DACB_PHASE_FINE:
		case CALIB_ADC_PHASE_EDGE:
		case CALIB_ADC_PHASE_COURSE:
		case CALIB_ADC_PHASE_FINE:
			chan = (UBYTE)(UWORD)((UWORD)item / (UWORD)3);
			item -= chan * 3;
			switch (chan)
			{
				case 0:	oldval = PlaySkewA;	break;
				case 1:	oldval = PlaySkewB;	break;
				case 2:	oldval = RecSkew;		break;
			}
			oldedge = (oldval >> 7) & 3;
			oldcourse = (oldval >> 3) & 0xF;
			oldfine = oldval & 0x7;
			switch (item)
			{
				case 0: oldedge	= value;	break;
				case 1: oldcourse	= value;	break;
				case 2: oldfine	= value;	break;
			}

			value = (oldedge << 7) | (oldcourse << 3) | oldfine;
			switch (chan)
			{
				case 0:
					if (VideoMode == VM_PLAY)
					{
						SetVideoSkew(0,&value);
						/* Also picks aligner edge and sets "lock" */
					}
					PlaySkewA = value;
					if (saveit != 0)
						error = EEwrite(NVOL_DACAPHASE,value);
					break;
				case 1:
					if (VideoMode == VM_PLAY)
					{
						SetVideoSkew(1,&value);
						/* Also picks aligner edge and sets "lock" */
					}
					PlaySkewB = value;
					if (saveit != 0)
						error = EEwrite(NVOL_DACBPHASE,value);
					break;
				case 2:
					if (VideoMode == VM_RECORD)
					{
						SetVideoSkew(2,&value);
						/* Also picks aligner edge and sets "lock" */
					}
					RecSkew = value;
					if (saveit != 0)
						error = EEwrite(NVOL_ADCPHASE,value);
					break;
			}
			break;
		case CALIB_PEDESTALA:
			PedestalA = value;
			if (VideoMode == VM_PLAY)
				SetPedestal(0,value);
			if (saveit != 0)
				error = EEwrite(NVOL_PEDESTALA,value);
			break;
		case CALIB_PEDESTALB:
			PedestalB = value;
			if (VideoMode == VM_PLAY)
				SetPedestal(1,value);
			if (saveit != 0)
				error = EEwrite(NVOL_PEDESTALB,value);
			break;
	}

	return(error);
}


/*
 *	ReadCalib - Read calibration variables
 */
UBYTE ReadCalib(UWORD item, UWORD *value)
{
	UWORD	oldval;
	UBYTE	chan;

	switch (item)
	{
		case CALIB_HPLAYOFFSETA:
			*value = PlayOffsetA;	break;
		case CALIB_HPLAYOFFSETB:
			*value = PlayOffsetB;	break;
		case CALIB_HRECOFFSETA:
			*value = RecOffsetA;		break;
		case CALIB_HRECOFFSETB:
			*value = RecOffsetB;		break;
		case CALIB_DACA_PHASE_EDGE:
		case CALIB_DACA_PHASE_COURSE:
		case CALIB_DACA_PHASE_FINE:
		case CALIB_DACB_PHASE_EDGE:
		case CALIB_DACB_PHASE_COURSE:
		case CALIB_DACB_PHASE_FINE:
		case CALIB_ADC_PHASE_EDGE:
		case CALIB_ADC_PHASE_COURSE:
		case CALIB_ADC_PHASE_FINE:
			chan = (UBYTE)(UWORD)((UWORD)item / (UWORD)3);
			item -= chan * 3;
			switch (chan)
			{
				case 0:	oldval = PlaySkewA;	break;
				case 1:	oldval = PlaySkewB;	break;
				case 2:	oldval = RecSkew;		break;
			}
			switch (item)
			{
				case 0: *value = (oldval >> 7) & 0x3;	break;
				case 1: *value = (oldval >> 3) & 0xF;	break;
				case 2: *value = oldval & 0x7;			break;
			}
			break;
		case CALIB_PEDESTALA:
			*value = PedestalA;	break;
		case CALIB_PEDESTALB:
			*value = PedestalB;	break;
	}

	return(ERR_OKAY);
}


/*
 *	GetSetOptions - Get/Set options (saved in EEPROM)
 */
UBYTE GetSetOptions(ULONG *options, UBYTE setit)
{
	UBYTE	err;
	UWORD	wh,wl;
	ULONG	changes;

	if (setit)
	{
		DBUG(print(DB_OPS,"Setting options: %l\n",*options);)

		changes = (*options) ^ GlobalOptions;

		// Don't write to EEPROM unless something is really changed,
		// as these chips have a limited number of write cycles before
		// they'll wear out (albeit lots of cycles)
		if (changes)
		{
			wl = (*options) & 0xFFFF;
			wh = ((*options)>>16) & 0xFFFF;

			err = EEwrite(NVOL_OPTIONSHI,wh);
			if (err!=ERR_OKAY) return(err);
			err = EEwrite(NVOL_OPTIONSLO,wl);
			if (err!=ERR_OKAY) return(err);

			GlobalOptions = *options;
		}

		// Changing status of HQ5 enable?
		if (changes & OPTF_NOT_HQ5)
		{
			if (GlobalOptions & OPTF_NOT_HQ5)			// Disabled it
			{
				HighSpeedVTASC = FALSE;
				SpeedUpChips(FALSE);
			}
			else														// Enabled it
			{
				HighSpeedVTASC = TRUE;
				SpeedUpChips(TRUE);
			}
		}

	}

	*options = GlobalOptions;		// Return local copy, as it is always current

	DBUG(print(DB_OPS,"Getting options: %l\n",GlobalOptions);)

	return(ERR_OKAY);
}
