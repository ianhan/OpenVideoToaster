/*********************************************************************\
*
* $AmiShar.c - Amiga(or Host)/Flyer shared RAM interface functions$
*
* $Id: amishar.c,v 1.16 1997/05/14 11:25:35 Holt Exp Holt $
*
* $Log: amishar.c,v $
*Revision 1.16  1997/05/14  11:25:35  Holt
*small changes only.
*
*Revision 1.15  1997/04/03  16:26:12  Holt
*debug off
*
*Revision 1.14  1997/03/26  16:32:20  Holt
*added more High Speed multi-block read/write code.
*
*Revision 1.13  1997/02/05  16:41:54  Hayes
*Turned off Debugging
*
*Revision 1.12  1997/02/05  16:32:53  Hayes
*Changed FileSeek_cmd to handle 64-bit file sizes
*
*Revision 1.11  1997/01/09  14:14:15  Holt
*interim SRAM fixes
*
*Revision 1.10  1996/12/19  17:07:26  Holt
*added FileExtend which extends a file without writing data to it.
*
*Revision 1.9  1996/12/09  17:37:38  Holt
*turned off debuging.
*
*Revision 1.8  1996/07/16  10:24:09  Holt
*added more audio env. support.
*
*Revision 1.7  1996/06/25  17:22:16  Holt
*made numerous changes to audio envelopes support
*
*Revision 1.6  1996/04/02  14:46:40  Holt
**** empty log message ***
*
*Revision 1.5  1995/11/21  11:30:42  Flick
*Now used for Flyer AND Phoenix builds, has opt. stuff for Phx-only
*
*Revision 1.4  1995/11/13  13:59:41  Flick
*New fn 'ExtraErrInfo' for planting extra error info into SharedCtrl struct
*ActsReset is now a stub.  'CallMod' changed to 'RunTest'.
*
*Revision 1.3  1995/10/10  01:36:41  Flick
*DeFrag, EndSequence, CopyFile commands all tie-in HostAbort to their functions, command structure
*now includes "Progress" field, for someday doing a gas guage to show progress (ready to go now)
*Play1Clip now updates LastFieldDone when done, so does DoSearch
*
*Revision 1.2  1995/09/07  09:21:51  Flick
*SCSI R/W tests now multitask and run at pri 5
*(release 4.06)
*
*Revision 1.1  1995/08/15  16:47:10  Flick
*First release (4.05)
*
*Revision 1.0  1995/05/04  17:17:45  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	05/03/95		Marty	created
\*********************************************************************/

#define	LOCALDEBUG		0			// Debugging switch for this module only

#define	VERBOSE			0

#include <Types.h>
#include <Flyer.h>
#include <Errors.h>
#include <Exec.h>
#include <Acts.h>
#include <AmiShar.h>
#include <FileSys.h>
#include <Hard.h>
#include <Debug.h>

#include <string.h>			// SAS include

#include <proto.h>
#include <AmiShar.ps>

#ifdef PHXCODE
static UBYTE PlayClipAuto(UBYTE chan,UBYTE drive,char *clipname,BOOL sync,ULONG field,ULONG fields,UWORD volramp);
#endif

extern const ULONG SRAMbase;			// Base of shared SRAM memory map


// Amiga/Flyer shared RAM command area
struct COMMANDS	* const cmd = (struct COMMANDS *) CMDBASE;

BOOL	FullyUp;

//#if DEBUG
#if VERBOSE
/* Flyer Control Command Names (debugging only) */
char *OpcodeNames[] = {
	"NIL",
	"Firmware",
	"RunTest",	//"CallMod",
	"PgmFPGA",
	"SbusW",
	"SbusR",
	"CpuWrite",
	"CpuRead",
	"GetFieldClock",
	"FirInit",
	"FirXchg",
	"LoadFirMap",
	"DSPboot",
	"CpuDma",
	"VidParam",
	"PlayMode",
	"RecordMode",
	"NoMode",
	"ToasterMux",
	"InputSelect",
	"Termination",
	"SearchArgs",
	"DoSearch",
	"Play1Clip",
	"FlyerRecord",
	"ChangeAudio",
	"GetSMPTE",
	"NewHeadList",
	"EndHeadList",
	"AddClipHead",
	"VoidHead",
	"KillAllHeads",
	"AudEnvelope",								/*"???",*/
	"ScsiInit",
	"ScsiInitChan",
	"FindDrives",
	"CopyData",
	"SCSIcall",
	"ReadCapac",
	"Read10",
	"Write10",
	"FSinfo",
	"FSlocate",
	"FreeGrip",
	"CopyGrip",
	"???",
	"Parent",
	"???",
	"FSdirlist",
	"FileInfo",
	"FileOpen",
	"FileClose",
	"FileSeek",
	"FileRead",
	"FileWrite",
	"CreateDir",
	"FSdelete",
	"FSrename",
	"FSrenamedisk",
	"FSformat",
	"DeFrag",
	"FSsetbits",
	"FSsetdate",
	"FSsetcomment",
	"WriteProt",
	"???",
	"CreateFile",
	"CopyFile",
	"DebugFlags",
	"SetFloobyDust",
	"ReadTest",
	"WriteTest",
	"Suicide",
	"ScsiDirect",
	"???",
	"OpenWrFld",
	"CloseField",
	"???",
	"???",
	"???",
	"???",
	"GetCompInfo",
	"SetTimeClock",
	"StripAudio",
	"WriteCalib",
	"ReadCalib",
	"EEwrite",
	"EEread",
	"ActsReset",
	"SetClockFreq",
	"LoadVid",
	"SetDevice",
	"???",
	"TBC",
	"NewCutList",
	"AddSubClip",
	"MakeSubClips",
	"CODEC",
	"NewSequence",
	"AddSequenceClip",
	"EndSequence",
	"PlaySequence",
	"GetSetOptions",
	"LocateField",
	"CacheTest",
	"FileExtend",
	"FileHSRead",
	"FileHSWrite",
};
#endif
//#endif



#define	NewCmd(cmdptr)		((UWORD)(((UWORD)((struct CMDHDR *)cmdptr)->opcode) & (UWORD)0xC000) == (UWORD)0x4000)


#if DEBUG
/*
 *  CommandDone - Mark command in SRAM as done
 */
void static CommandDone(APTR ptr)
{
	register struct CMDHDR *cmdptr = (struct CMDHDR *)ptr;

	UWORD	opcode,newcode;

	/* Split up to prevent asynchronous errors in debugging output */

	opcode = cmdptr->opcode;

	newcode = opcode | 0xC000;
#if VERBOSE
	print(DB_INTERP,"(%s,%b) * ",OpcodeNames[newcode & 0x3FFF],cmdptr->error);
#else
	print(DB_INTERP,"%b,%b*",newcode & 0x3FFF,cmdptr->error);
#endif
	cmdptr->opcode = newcode;

//	cmdptr->opcode |= 0xC000;
}
#else
#define	CommandDone(cmdptr)		(((struct CMDHDR *)cmdptr)->opcode |= (UWORD)0xC000)
#endif


/*
 *  CommandBusy - Mark command in SRAM as busy processing
 */
void static CommandBusy(APTR ptr)
{
	register struct CMDHDR *cmdptr = (struct CMDHDR *)ptr;
	UWORD	opcode;

	opcode = cmdptr->opcode;

	cmdptr->opcode = (opcode & 0x3FFF) | 0x8000;
	cmdptr->error	= ERR_OKAY;							// No error by default
}



/*
 *	Null_cmd - Do-nothing command
 */
void static __regargs Null_cmd(APTR ptr)
{
// Guts go here
}


/*
 * Unknown - Handle unknown command
 */
void static Unknown(APTR ptr)
{
	struct CMDHDR *cmdptr = (struct CMDHDR *)ptr;

	cmdptr->error = ERR_BADCOMMAND;					// Don't understand!

//	DBUG(print(DB_ALWAYS,"Unknown command:%w\n",cmdptr->opcode);)
}


/*
 *	Suicide_cmd - Shut down Flyer
 */
void Suicide_cmd(APTR ptr)
{
	struct CMDHDR *cmdptr = (struct CMDHDR *)ptr;
	ULONG		timeout;

//	CommandBusy(ptr);			/* Mark command as in progress (DONE FOR ME ALREADY NOW) */

//	KillVideo();				/* Shut down video engines if running */


//	DBUG(print(DB_ALWAYS,"Bye");)

	CommandDone(ptr);			/* Mark command as done */

	timeout = 0;
	/* Wait until library clears out command */
	while ((cmdptr->opcode & 0xC000) != 0x0000)
	{
		if (++timeout > 100000)
		{
			//DBUG(print(DB_ALWAYS,"Timeout!!");)
			break;
		}
	}

	ColdBoot();				/* Reboot Flyer */
}


/*
 *	FSinfo_cmd - Stub for FSinfo
 */
void static FSinfo_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		ULONG	infoptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FSinfo(
		cmdptr->drive,
		(struct FlyerVolInfo *)(cmdptr->infoptr + SRAMbase)	// Address of data structure
	);
}


/*
 *	FileInfo_cmd - Stub for FileInfo
 */
void static FileInfo_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	volptr;
		ULONG	infoptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	struct FlyerVolume	*volume;

	volume = (struct FlyerVolume *)(cmdptr->volptr + SRAMbase);

	cmdptr->error = FileInfo(
		volume->v_SCSIdrive,
		NULL,
		(char *)(volume->v_Name + SRAMbase),				// Get address of name
		(struct ClipInfo *)(cmdptr->infoptr + SRAMbase)	// Get address of data structure
	);
}


/*
 *	FSlocate_cmd - Stub to FSlocate
 */
void static FSlocate_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION			*action;
	FlyerVolume		*volume;
	GRIP				*newgrip,*oldgrip;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	oldgrip = (GRIP *)action->a_Grip;

	cmdptr->error = FS_Locate(
		volume->v_SCSIdrive,
		oldgrip,
		action->a_Access,
		(char *)(volume->v_Name + SRAMbase),	// Get address of name
		&newgrip,
		&action->a_StartBlk
	);

	action->a_Grip = (ULONG)newgrip;
}


/*
 *	FreeGrip_cmd - Stub to FreeGrip
 */
void static FreeGrip_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FreeGrip(cmdptr->drive,cmdptr->grip);
}


/*
 *	CopyGrip_cmd - Stub to CopyGrip
 */
void static CopyGrip_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
		GRIP	*_newgrip;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = CopyGrip(
		cmdptr->drive,
		cmdptr->grip,
		&cmdptr->_newgrip
	);
}


/*
 *	FSdirlist_cmd - Stub to FSdirlist
 */
void static FSdirlist_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
		ULONG	infoptr;
		UBYTE	firstflg;
		UBYTE	fsonlyflg;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error= DirList(
		cmdptr->drive,
		cmdptr->grip,
		(struct ClipInfo *)(cmdptr->infoptr + SRAMbase),	// Addr of data structure
		cmdptr->firstflg,
		(cmdptr->fsonlyflg == 0)?TRUE:FALSE						// Extra?
	);
}


/*
 *	Parent_cmd - Stub for Parent
 */
void static Parent_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
		GRIP	*_newgrip;
		ULONG	_block;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = Parent(
		cmdptr->drive,
		cmdptr->grip,
		&cmdptr->_newgrip,
		&cmdptr->_block
	);
}


/*
 *	CopyFile_cmd - Stub for CopyFile
 */
void static CopyFile_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;			// Used to abort copy
		UBYTE	error;
		ULONG	srcvolptr;
		ULONG	dstvolptr;
		BOOL	verify;
		UBYTE	pad1;
		UWORD	pad2;
		ULONG	pad3[3];
		ULONG	progress;	// 0.32 fraction for how complete so far
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	FlyerVolume	*srcvol,*dstvol;

	srcvol	= (FlyerVolume *)(cmdptr->srcvolptr + SRAMbase);
	dstvol	= (FlyerVolume *)(cmdptr->dstvolptr + SRAMbase);

	cmdptr->error = CopyFile(
		srcvol->v_SCSIdrive,							// Source drive
		(char *)(srcvol->v_Name + SRAMbase),	// Source name
		dstvol->v_SCSIdrive,							// Dest drive
		(char *)(dstvol->v_Name + SRAMbase),	// Dest name
		&cmdptr->cont);								// Host Abort input
}


/*
 *	CreateFile_cmd - Stub for CreateFile
 */
void static CreateFile_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	volptr;		// Drive and name to make
		ULONG	size;			// Requested size (blocks)
		ULONG	__start;		// Allocated data area
		ULONG	fragbytes;	// Residual bytes over 'size' blocks
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	FlyerVolume	*vol;
	ULONG	blocks;

	vol	= (FlyerVolume *)(cmdptr->volptr + SRAMbase);
	blocks = cmdptr->size;

	if (cmdptr->fragbytes != 0)				// 1 more block if there are residual bytes
		blocks++;

	cmdptr->error = CreateFile(
		vol->v_SCSIdrive,							// Drive
		(char *)(vol->v_Name + SRAMbase),	// Get address of name
		blocks,										// Blocks to contain (rounded up)
		cmdptr->fragbytes,						// Bytes in addition to 'Blocks' above
		&cmdptr->__start
	);
}


/*
 *	FSsetbits_cmd - Stub for FSsetbits
 */
void static FSsetbits_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
		ULONG	bits;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FSsetbits(
		cmdptr->drive,
		cmdptr->grip,
		cmdptr->bits
	);
}


/*
 *	FSsetcomment_cmd - Stub for FSsetcomment
 */
void static FSsetcomment_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
		ULONG	comment;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FSsetcomment(
		cmdptr->drive,
		cmdptr->grip,
		(char *)(cmdptr->comment + SRAMbase)		// Get address of comment
	);
}


/*
 *	FileOpen_cmd - Stub to FileOpen
 */
void static FileOpen_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION	*action;
	FlyerVolume	*volume;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	action->a_reserved0[1] = 0x22222222;
	action->a_reserved1[0] |= 0x100;

	cmdptr->error = FileOpen(
		volume->v_SCSIdrive,
		(GRIP *)action->a_Grip,
		(char *)(volume->v_Name + SRAMbase),		// Get address of name
		action->a_Access,
		&action->a_FileID,
		&action->a_StartBlk
	);
}


/*
 *	FileClose_cmd - Stub to FileClose
 */
void static FileClose_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		APTR	fileid;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FileClose(
		cmdptr->drive,
		cmdptr->fileid
	);
}


/*
 *	FileSeek_cmd - Stub to FileSeek
 */
void static FileSeek_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad1a;
		UBYTE	drive;
		UBYTE	mode;
		UBYTE	pad2;
		APTR	fileid;
		ULONG	newpos_ext;
		ULONG	newpos;
		ULONG	_oldpos_ext;
		ULONG	_oldpos;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FileSeek(
		cmdptr->drive,
		cmdptr->fileid,
		cmdptr->mode,
		cmdptr->newpos_ext,
		cmdptr->newpos,
		&cmdptr->_oldpos_ext,
		&cmdptr->_oldpos
	);
//	DBUG(print(DB_FILESYS,"err = %b, Oldpos = %l\n",cmdptr->error,cmdptr->_oldpos);)
}


/*
 *	FileRead_cmd - Stub to FileRead
 */
void static FileRead_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		APTR	fileid;
		ULONG	length;
		ULONG	buff;
		ULONG	_actual;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FileRead(
		cmdptr->drive,
		cmdptr->fileid,
		cmdptr->length,
		(APTR)(cmdptr->buff + SRAMbase),		// Get address of buffer
		&cmdptr->_actual
	);
}


/*
 *	FileWrite_cmd - Stub to FileWrite
 */
void static FileWrite_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		APTR	fileid;
		ULONG	length;
		ULONG	buff;
		ULONG	_actual;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FileWrite(
		cmdptr->drive,
		cmdptr->fileid,
		cmdptr->length,
		(APTR)(cmdptr->buff + SRAMbase),		// Get address of buffer
		&cmdptr->_actual
	);
}



/*
 *	CreateDir_cmd - Stub to CreateDir
 */
void static CreateDir_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION	*action;
	FlyerVolume	*volume;
	GRIP	*newgrip;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	cmdptr->error = CreateDir(
		volume->v_SCSIdrive,
		(GRIP *)action->a_Grip,
		(char *)(volume->v_Name + SRAMbase),	// Get address of name
		&newgrip
	);
	action->a_Grip = (ULONG)newgrip;
}


/*
 *	FSdelete_cmd - Stub to FSdelete
 */
void static FSdelete_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION	*action;
	FlyerVolume	*volume;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	cmdptr->error = Delete(
		volume->v_SCSIdrive,
		(GRIP *)action->a_Grip,
		(char *)(volume->v_Name + SRAMbase)		// Get address of name
	);
}


/*
 *	FSrename_cmd - Stub to FSrename 
 */
void static FSrename_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	actptr;
		GRIP	*newgrip;
		ULONG	newfname;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION	*action;
	FlyerVolume	*volume;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	cmdptr->error = Rename(
		volume->v_SCSIdrive,
		(GRIP *)action->a_Grip,
		(char *)(volume->v_Name + SRAMbase),	// Old name
		cmdptr->newgrip,
		(char *)(cmdptr->newfname + SRAMbase)	// New name
	);
}


/*
 *	FSrenamedisk_cmd - Stub to FSrenamedisk
 */
void static FSrenamedisk_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		ULONG	filename;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = RenameDisk(
		cmdptr->drive,
		(char *)(cmdptr->filename + SRAMbase)		// Get address of name
	);
}


/*
 *	FSformat_cmd - Stub to FSformat
 */
void static FSformat_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		ULONG	volname;
		struct FlyerDate stamp;
		ULONG	blocks;
		BYTEBITS	flags;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = Format(
		cmdptr->drive,
		(char *)(cmdptr->volname + SRAMbase),	// Volume name
		&cmdptr->stamp,
		cmdptr->blocks,
		cmdptr->flags
	);
}


/*
 *	FSsetdate_cmd - Stub for FSsetdate
 */
void static FSsetdate_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		GRIP	*grip;
		ULONG	days;
		ULONG	mins;
		ULONG	ticks;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = SetDate(
		cmdptr->drive,
		cmdptr->grip,
		cmdptr->days,
		cmdptr->mins,
		cmdptr->ticks
	);
}


/*
 *	WriteProt_cmd - Stub: Test/set state of write protect flag for drive
 */
void static WriteProt_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		UBYTE	value;
		UBYTE	setit;
	};
//// Currently unimplemented
//	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

//	WriteProt(cmdptr->chan,cmdptr->value,cmdptr->setit);
}


/*
 *	DebugFlags_cmd - Stub for DebugFlags
 */
void static DebugFlags_cmd(APTR ptr)
{
#if DEBUG
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		LONGBITS	flags;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = DebugFlags(cmdptr->flags);
	//print(DB_INTERP,"SETTING DEBUG FLAGS %l \n",cmdptr->flags);


#endif
}


/*
 *	GetSetOptions_cmd - Stub for GetSetOptions
 */
void static GetSetOptions_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		LONGBITS	flags;
		UBYTE		setit;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = GetSetOptions(&cmdptr->flags,cmdptr->setit);

	DBUG(print(DB_ALWAYS,"getting/Setting Options Flags %l   %l \n",(unsigned char)cmdptr->flags,cmdptr->setit);)

}


/*
 * SbusW_cmd - Stub for SbusW
 */
void static SbusW_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	addr;
		UBYTE	data;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = SbusW(cmdptr->addr,cmdptr->data);

	DBUG(
		while (cmdptr->cont != 0)
			cmdptr->error = SbusW(cmdptr->addr,cmdptr->data);
	)
}


/*
 * SbusR_cmd - Stub for SbusR
 */
void static SbusR_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	addr;
		UBYTE	_data;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	DBUG(
		while (cmdptr->cont != 0)
			cmdptr->error = SbusR(cmdptr->addr, &cmdptr->_data);	// Keep reading serial bus
	)
	cmdptr->error = SbusR(cmdptr->addr, &cmdptr->_data);
}


/*
 *	WriteCalib_cmd - Stub for WriteCalib
 */
void static WriteCalib_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UWORD		item;
		UWORD		value;
		UBYTE		saveit;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = WriteCalib(
		cmdptr->item,
		cmdptr->value,
		cmdptr->saveit
	);
}


/*
 *	ReadCalib_cmd - Stub for ReadCalib
 */
void static ReadCalib_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UWORD		item;
		UWORD		_value;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = ReadCalib(
		cmdptr->item,
		&cmdptr->_value
	);
}


/*
 *	VidParam_cmd - Stub for VidParam
 */
void static VidParam_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		vchan;			// OBSOLETE!
		UBYTE		mintol;
		UBYTE		maxtol;
		UBYTE		freq;
		UWORD		vmaxlen;
		UWORD		vlength;
		UBYTE		firset;
		UBYTE		special;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = VidParam(
		cmdptr->mintol,
		cmdptr->maxtol,
		cmdptr->freq,
		cmdptr->vmaxlen,
		cmdptr->vlength,
		cmdptr->firset,
		cmdptr->special
	);
}


/*
 * SearchArgs_cmd - Stub for SearchArgs
 */
void static SearchArgs_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
		UBYTE		flag;
//Eliminated under exec
//		UBYTE		__state;
//		ULONG		__index;
//		ULONG		__maxfld;
//		BYTEBITS	__flags;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = SearchArgs(
		(ACTION *)(cmdptr->actptr + SRAMbase),		// Action structure
		cmdptr->flag
	);
}


/*
 *	DoSearch_cmd - Stub for DoSearch
 */
void static DoSearch_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	struct	ACTION	*act;

	act = (ACTION *)(cmdptr->actptr + SRAMbase);		// Get action structure

	cmdptr->error = DoSearch(act);						// Action structure

	// Update LastFieldDone for folks who don't know what they just asked for!
	if (cmdptr->error == ERR_OKAY)
	{
		if (act->a_Flags & AF_VIDEO)
			act->a_LastFieldDone = act->a_VidStartField;
		else if (act->a_Flags & (AF_AUDIOL | AF_AUDIOR))
			act->a_LastFieldDone = act->a_AudStartField;
	}
}


/*
 *	LocateField_cmd - Stub for LocateField
 */
void static LocateField_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = LocateField(
		(ACTION *)(cmdptr->actptr + SRAMbase)		// Action structure
	);
}


/*
 *	Play1Clip_cmd - Stub for Play1Clip
 */
void static Play1Clip_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	struct	ACTION	*act;

	act = (ACTION *)(cmdptr->actptr + SRAMbase);		// Get action structure

	cmdptr->cont = 2;		// Not timely anymore, but at least let'em know we started

	cmdptr->error = Play1Clip(
		act,									// Action structure
		TRUE,									// Play synchronous (wait for complete)
		&cmdptr->cont,						// Tie-in host abort input
		&act->a_LastFieldDone			// Tie-in
	);

	// Correct LastFieldDone based on where started
	if (cmdptr->error == ERR_OKAY)
	{
		if (act->a_Flags & AF_VIDEO)
			act->a_LastFieldDone += act->a_VidStartField;
		else if (act->a_Flags & (AF_AUDIOL | AF_AUDIOR))
			act->a_LastFieldDone += act->a_AudStartField;
	}
}


/*
 *	FlyerRecord_cmd - Stub for FlyerRecord
 */
void static FlyerRecord_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FlyerRecord(
		(ACTION *)(cmdptr->actptr + SRAMbase),		// Action structure
		&cmdptr->cont										// Continue flag
	);
}


/*
 *	SetTimeClock_cmd - Stub for SetTimeClock
 */
void static SetTimeClock_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		days;
		ULONG		minutes;
		ULONG		ticks;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = SetTimeClock(
		cmdptr->days,
		cmdptr->minutes,
		cmdptr->ticks
	);
}


/*
 *	DeFrag_cmd - Stub for DeFrag
 */
void static DeFrag_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		pad1;
		UBYTE		drive;
		UWORD		pad2;
		ULONG		pad3[5];
		ULONG		progress;	// 0.32 fraction for how complete so far
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = DeFrag(
		cmdptr->drive,
		&cmdptr->cont				// If this goes FALSE, abort defrag
	);
}


/*
 * PgmFPGA_cmd - Stub for PgmFPGA
 */
void static PgmFPGA_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	addr;
		ULONG	length;
		UBYTE	chipnumber;
		BOOL	dual;
		UBYTE	chiprev;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = PgmFPGA(
		(APTR)(cmdptr->addr+SRAMbase),		// Address of data
		cmdptr->length,
		cmdptr->chipnumber,
		cmdptr->dual,
		cmdptr->chiprev
	);
}


/*
 *	LoadFirMap_cmd - Stub for LoadFirMap
 */
void static LoadFirMap_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	bank;
		UBYTE	scale;
		UBYTE	shape;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = LoadFirMap(
		cmdptr->bank,
		cmdptr->scale,
		cmdptr->shape
	);
}


/*
 * DSPboot_cmd - Stub for DSPboot
 */
void static DSPboot_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		ULONG	addr;
		ULONG	length;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = DSPboot(
		(APTR)(cmdptr->addr+SRAMbase),
		cmdptr->length
	);
}


/*
 * CpuWrite_cmd - Write data to memory
 */
void static CpuWrite_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UWORD	*addr;
		UWORD	data;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	*cmdptr->addr = cmdptr->data;				// Write (WORD) data to Memory
}


/*
 * CpuRead_cmd - Read data from memory
 */
void static CpuRead_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UWORD	*addr;
		UWORD	_data;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->_data = *cmdptr->addr;		// Store (WORD) data in command
}


/*
 * SetClockFreq_cmd - Stub for SetClockFreq
 */
void static SetClockFreq_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	clock;
		UBYTE	pad2;
		ULONG	freq;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = SetClockFreq(
		cmdptr->clock,
		cmdptr->freq
	);
}


/*
 * ToasterMux_cmd - Stub for ToasterMux
 */
void static ToasterMux_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	input3;
		UBYTE	input4;
		UBYTE	preview;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = ToasterMux(
		cmdptr->input3,
		cmdptr->input4,
		cmdptr->preview
	);
}


/*
 * InputSelect_cmd - Stub for InputSelect
 */
void static InputSelect_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	source;
		UBYTE	sync;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = InputSelect(
		cmdptr->source,
		cmdptr->sync
	);
}


/*
 * Termination_cmd - Stub for Termination
 */
void static Termination_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	flags;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = Termination(cmdptr->flags);
}


/*
 * FirInit_cmd - Stub for FirInit
 */
void static FirInit_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UWORD	data0;
		UWORD	data1;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	FirInit(
		cmdptr->data0,
		cmdptr->data1
	);
}


/*
 * FirXchg_cmd - Stub for FirXchg
 */
void static FirXchg_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		setnum;
		UBYTE		readflag;
		UBYTE		prepost;
		UBYTE		pad2;
		struct FIRSET	data;		// 8 coefs/scale
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FirXchg(
		cmdptr->setnum,
		cmdptr->readflag,
		cmdptr->prepost,
		&cmdptr->data
	);
}


/*
 *	GetCompInfo_cmd - Stub for GetCompInfo
 */
void static GetCompInfo_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		drive;
		UBYTE		field;
		ULONG		lba;
		ULONG		vciptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = GetCompInfo(
		cmdptr->drive,
		cmdptr->field,
		cmdptr->lba,
		(struct VidCompInfo *)(cmdptr->vciptr + SRAMbase)	// VidCompInfo structure
	);
}


/*
 *	NewCutList_cmd - Stub for NewCutList
 */
void static NewCutList_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
		BYTEBITS	operflags;			// Operation flags
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION		*action;
	FlyerVolume	*volume;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	cmdptr->error = NewCutList(
		volume->v_SCSIdrive,								// Drive which contains clip to cut
		(char *)(volume->v_Name + SRAMbase),		// Name of clip to cut
		cmdptr->operflags
	);
}


/*
 *	AddSubClip_cmd - Stub for AddSubClip
 */
void static AddSubClip_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		drive;
		BYTEBITS	CAFflags;		// From ca_Flags
		UWORD		refnum;
		ULONG		startfld;
		ULONG		numflds;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = AddSubClip(
		cmdptr->drive,
		cmdptr->CAFflags,
		cmdptr->refnum,
		cmdptr->startfld,
		cmdptr->numflds
	);
}


/*
 *	MakeSubClips_cmd - Make sub-clips
 */
void static MakeSubClips_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		doit;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = MakeSubClips(cmdptr->doit);
}


/*
 *	SetDevice_cmd - Stub for SetDevice
 */
void static SetDevice_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		port;
		UBYTE		type;
		UBYTE		make;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = SetDevice(
		cmdptr->port,
		cmdptr->type,
		cmdptr->make
	);
}


/*
 *	NewHeadList_cmd - Stub for NewHeadList
 */
void static NewHeadList_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = NewHeadList();
}


/*
 *	EndHeadList_cmd - Stub for EndHeadList
 */
void static EndHeadList_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		doit;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = EndHeadList(cmdptr->doit);
}


/*
 *	AddClipHead_cmd - Stub for AddClipHead
 */
void static AddClipHead_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION		*action;
	FlyerVolume	*volume;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	cmdptr->error = AddClipHead(
		volume->v_SCSIdrive,								// Drive that contains
		(char *)(volume->v_Name + SRAMbase),		// Name of clip
		action->a_VidStartField,
		action->a_VidFieldCount,
		action->a_AudStartField,
		action->a_AudFieldCount
	);
}



/*
 *	KillAllHeads_cmd - Stub for KillAllHeads
 */
void static KillAllHeads_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = KillAllHeads();
}


/*
 *	AudEnvelope - Add an audio envelope to proceding clip
 */
void static AudEnvelope(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
	};

	//DBUG(print(DB_INTERP,"AddAudEnvelope:\n");)
				
}




/*
 *  ScsiDirect_cmd - Stub for ScsiDirect
 */
void static ScsiDirect_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		drive;
		UBYTE		pad;
		ULONG		infoptr;
//		SCSIKEY	__skey;
//		UBYTE		__state;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = ScsiDirect(
		cmdptr->drive,
		(struct SCSIcmd *)(cmdptr->infoptr + SRAMbase)		// SCSIcmd structure
	);
}


/*
 *	OpenWrFld_cmd - Stub for OpenWrFld
 */
void static OpenWrFld_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
		ULONG		cmpinfptr;
		ULONG		field;
		BYTEBITS	mode;
		UBYTE		pad;
		ULONG		_refnum;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	ACTION	*action;
	FlyerVolume	*volume;

	action = (ACTION *)(cmdptr->actptr + SRAMbase);	// Get ptr to action structure
	volume = (FlyerVolume *)(action->a_Volume + SRAMbase);

	cmdptr->error = OpenWrFld(
		volume->v_SCSIdrive,													// Drive number
		(char *)(volume->v_Name + SRAMbase),							// File name
		(GRIP *)action->a_Grip,												// Grip (???)
		(struct VidCompInfo *)(cmdptr->cmpinfptr + SRAMbase),		// VidCompInfo structure
		&cmdptr->field,			// Read & possible modified!
		cmdptr->mode,
		&cmdptr->_refnum
	);
}


/*
 *	CloseField_cmd - Stub for CloseField
 */
void static CloseField_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		refnum;
		UBYTE		wrote;			// Wrote some data?
		UBYTE		pad;
		ULONG		finalptr;		// LBA just past field data
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = CloseField(
		cmdptr->refnum,
		cmdptr->wrote,
		cmdptr->finalptr
	);
}



/*
 *	EEwrite_cmd - Stub for EEwrite
 */
void static EEwrite_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		addr;
		UBYTE		pad2;
		UWORD		data;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = EEwrite(
		cmdptr->addr,
		cmdptr->data
	);
}


/*
 *	EEread_cmd - Stub for EEread
 */
void static EEread_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		addr;
		UBYTE		pad2;
		UWORD		_data;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = EEread(
		cmdptr->addr,
		&cmdptr->_data
	);
}


/*
 *	ReadTest_cmd - Stub for ReadTest
 */
void static ReadTest_cmd(APTR ptr)
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
		UBYTE		flag;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = ReadTest(
		cmdptr->drive,
		cmdptr->lba,
		cmdptr->length,
		cmdptr->repeat,
		cmdptr->flag
	);
}


/*
 *	GetFieldClock_cmd - Stub for GetFieldClock
 */
void static GetFieldClock_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		_clock;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->_clock = GetFieldClock();

	//DBUG(printchar(DB_VIDEO2,(cmdptr->_clock & 3)+'0'+5);)
}


/*
 *	PlayMode_cmd - Stub for PlayMode
 */
void static PlayMode_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
	};

	PlayMode();
}


/*
 *	RecordMode_cmd - Stub for RecordMode
 */
void static RecordMode_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
	};

	RecordMode();
}


/*
 * ScsiInitChan_cmd - Stub for ScsiInitChan
 */
void static ScsiInitChan_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		UBYTE		pad2;
		UBYTE		drive;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = ScsiInitChan(
		cmdptr->drive >> 3				// Get channel number from drive
	);
}


/*
 * ScsiInit_cmd - Stub for ScsiInit
 */
void static ScsiInit_cmd(APTR ptr)
{
	ScsiInit();									// Master SCSI Init
}


/*
 * FindDrives_cmd - Find responding drives on Scsi bus
 */
void FindDrives_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad1;
		UBYTE		error;
		UBYTE		pad1a;
		UBYTE		drive;
		UBYTE		drvbits;
		UBYTE		pad2;
		UBYTE		versions[8];
		UBYTE		lengths[8];
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
	UBYTE	chan;

	chan = cmdptr->drive >> 3;				// Get channel from drive
	if (chan < NUMSCSICHANS)
	{
		// Find Drives
		cmdptr->drvbits = FindDrives(
			chan,
			&cmdptr->versions[0],
			&cmdptr->lengths[0]
		);
	}
	else
		cmdptr->error = ERR_BADPARAM;				// Set Error code
}


/*
 *	NewSequence_cmd - Stub for NewSequence
 */
void static NewSequence_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = NewSequence();
}


/*
 *	AddSequenceClip_cmd - Stub for AddSequenceClip
 */
void static AddSequenceClip_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		actptr;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = AddSequenceClip(
		(ACTION *)(cmdptr->actptr + SRAMbase)		// Get ptr to action structure
	);
}


/*
 * AddAudEKey_cmd -- SRAM STUB FOR GETTING AUDIO ENVELOPE KEY. 
 */
void AddAudEKey_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		time;
		ULONG		durr;
		UWORD		Flags;
		UWORD		VOL1;
		UWORD		VOL2;
		WORD		PAN1;	
		WORD		PAN2;	
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	//DBUG(print(DB_SEQ,"time=%l durr=%l flags=%w vol1=%w vol2=%w pan1=%w pan2=%w \n",
	//				cmdptr->time,cmdptr->durr,cmdptr->Flags,cmdptr->VOL1,cmdptr->VOL2,
	//				cmdptr->PAN1,cmdptr->PAN2);)
	
	cmdptr->error = AddAudEKey(cmdptr->time,
						 				cmdptr->durr,
										cmdptr->Flags,
										cmdptr->VOL1,
										cmdptr->VOL2,
										cmdptr->PAN1,
										cmdptr->PAN2);
	
}


/*
 *	EndSequence_cmd - Stub for EndSequence
 */
void static EndSequence_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		UBYTE		doit;
		UBYTE		pad1;
		UWORD		pad2;
		ULONG		pad3[5];
		ULONG		progress;	// 0.32 fraction for how complete so far
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = EndSequence(
		cmdptr->doit,
		&cmdptr->cont		// Host abort input
	);
}


/*
 *	PlaySequence_cmd - Stub for PlaySequence
 */
void static PlaySequence_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		basetime;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = PlaySequence(cmdptr->basetime);
}


/*
 *	CacheTest_cmd - Help Host test for cache problems with Flyer's shared RAM
 */
void static CacheTest_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		cont;
		UBYTE		error;
		ULONG		skip[6];
		ULONG		value;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;
//	ULONG		*value;

//	value = (ULONG *)SRAMbase;

	cmdptr->value = 0xFEEDF00D;

	Disable();

	// Busy wait is okay here, since this is only done at init time, and we want our
	// latency to be as low as possible
	while (cmdptr->cont) {}

	cmdptr->value = 0x12345678;

	Enable();
}


/*
 *	ActsReset_cmd - Stub for Reset parameters
 */
void static ActsReset_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD		opcode;
		UBYTE		pad;
		UBYTE		error;
		ULONG		flags;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	ActsReset(cmdptr->flags);
}

/*
 * FileExtend_cmd - Test to tryout new HP-file io code.
 */
void static FileExtend_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	pad2;
		UBYTE	drive;
		APTR	fileid;
		ULONG	length;
	};
	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;

	cmdptr->error = FileExtend(
		cmdptr->drive,
		cmdptr->fileid,
		cmdptr->length
	);
}



/*
 * FileHSRead_cmd - Test to tryout new HS-file IO code.
 */
void static FileHSRead_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	WFLAG;
		UBYTE	drive;
		APTR	fileid;
		ULONG	Start_Blk;
		ULONG	Blk_Count;		//should max out at about 96blocks = 48K
		ULONG	buff;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;


	//print(DB_FILESYS,"HS - buff: %l\n",cmdptr->buff);
	
	

	cmdptr->error = FileHSWrite(
		cmdptr->drive,
		cmdptr->fileid,
		cmdptr->Start_Blk,
		cmdptr->Blk_Count,
		(APTR)(cmdptr->buff + SRAMbase),
		cmdptr->WFLAG
	);
}




/*
 * FileHSWrite_cmd - Test to tryout new HS-file IO code.
 * Why not do both? read and write with same code?! (DEH 2/18/97)	
 */
void static FileHSWrite_cmd(APTR ptr)
{
	struct CMD_ORG {
		UWORD	opcode;
		UBYTE	cont;
		UBYTE	error;
		UBYTE	WFLAG;
		UBYTE	drive;
		APTR	fileid;
		ULONG	Start_Blk;
		ULONG	Blk_Count;		//should max out at about 96blocks = 48K
		ULONG buff;
	};

	register struct CMD_ORG *cmdptr = (struct CMD_ORG *)ptr;


	//print(DB_FILESYS,"HS - buff: %l\n",cmdptr->buff);



	cmdptr->error = FileHSWrite(
		cmdptr->drive,
		cmdptr->fileid,
		cmdptr->Start_Blk,
		cmdptr->Blk_Count,
		(APTR)(cmdptr->buff + SRAMbase),
		cmdptr->WFLAG
	);
}



/* Flyer Control Command Vectors */
struct FuncEntry	FuncTable[] = {
	FALSE,0,Null_cmd,
	FALSE,0,Firmware,
	FALSE,0,RunTest_cmd,		// CallMod
	FALSE,0,PgmFPGA_cmd,
	FALSE,0,SbusW_cmd,
	FALSE,0,SbusR_cmd,
	FALSE,0,CpuWrite_cmd,
	FALSE,0,CpuRead_cmd,
	FALSE,0,GetFieldClock_cmd,
	FALSE,0,FirInit_cmd,
	FALSE,0,FirXchg_cmd,
	FALSE,0,LoadFirMap_cmd,
	FALSE,0,DSPboot_cmd,
	FALSE,0,CpuDma_cmd,
	FALSE,0,VidParam_cmd,
	FALSE,0,PlayMode_cmd,
	FALSE,0,RecordMode_cmd,
	FALSE,0,NoMode_cmd,
	FALSE,0,ToasterMux_cmd,
	FALSE,0,InputSelect_cmd,
	FALSE,0,Termination_cmd,
	FALSE,0,SearchArgs_cmd,
	FALSE,0,DoSearch_cmd,
	TRUE ,3,Play1Clip_cmd,
	TRUE ,0,FlyerRecord_cmd,	// Must run at pri 0 until it quits hogging CPU
	FALSE,0,ChangeAudio,
	FALSE,0,GetSMPTE,
	FALSE,0,NewHeadList_cmd,
	FALSE,0,EndHeadList_cmd,
	FALSE,0,AddClipHead_cmd,
	FALSE,0,VoidHead,
	FALSE,0,KillAllHeads_cmd,
	FALSE,0,AddAudEKey_cmd,						//AudEnvelope,Unknown, AUDCTRL 
	FALSE,0,ScsiInit_cmd,
	FALSE,0,ScsiInitChan_cmd,
	FALSE,0,FindDrives_cmd,
	FALSE,0,CopyData_cmd,
	FALSE,0,SCSIcall,
	FALSE,0,ReadCapac,
	FALSE,0,Read10,
	FALSE,0,Write10,
	FALSE,0,FSinfo_cmd,
	FALSE,0,FSlocate_cmd,
	FALSE,0,FreeGrip_cmd,
	FALSE,0,CopyGrip_cmd,
	FALSE,0,Unknown,			/* CMPGRIPS */
	FALSE,0,Parent_cmd,
	FALSE,0,Unknown,			/* EXAMINE */
	FALSE,0,FSdirlist_cmd,
	FALSE,0,FileInfo_cmd,
	FALSE,0,FileOpen_cmd,
	FALSE,0,FileClose_cmd,
	FALSE,0,FileSeek_cmd,
	FALSE,0,FileRead_cmd,
	FALSE,0,FileWrite_cmd,
	FALSE,0,CreateDir_cmd,
	FALSE,0,FSdelete_cmd,
	FALSE,0,FSrename_cmd,
	FALSE,0,FSrenamedisk_cmd,
	FALSE,0,FSformat_cmd,
	FALSE,0,DeFrag_cmd,
	FALSE,0,FSsetbits_cmd,
	FALSE,0,FSsetdate_cmd,
	FALSE,0,FSsetcomment_cmd,
	FALSE,0,WriteProt_cmd,
	FALSE,0,Unknown,			/* FSCHGMODE */
	FALSE,0,CreateFile_cmd,
	FALSE,0,CopyFile_cmd,
	FALSE,0,DebugFlags_cmd,
	FALSE,0,SetFloobyDust,
	TRUE,5,ReadTest_cmd,
	TRUE,5,WriteTest_cmd,
	FALSE,0,Suicide_cmd,
	TRUE,0,ScsiDirect_cmd,
	FALSE,0,Unknown,	/* (1,Clip.OpenRdFld), */
	FALSE,0,OpenWrFld_cmd,
	FALSE,0,CloseField_cmd,
	FALSE,0,Unknown,	/* (1,Clip.ReadLine), */
	FALSE,0,Unknown,	/* (1,Clip.WriteLine), */
	FALSE,0,Unknown,	/* (1,Clip.SetFillColor), */
	FALSE,0,Unknown,	/* (1,Clip.SkipLines), */
	FALSE,0,GetCompInfo_cmd,
	FALSE,0,SetTimeClock_cmd,
	FALSE,0,StripAudio_cmd,
	FALSE,0,WriteCalib_cmd,
	FALSE,0,ReadCalib_cmd,
	FALSE,0,EEwrite_cmd,
	FALSE,0,EEread_cmd,
	FALSE,0,ActsReset_cmd,
	FALSE,0,SetClockFreq_cmd,
	FALSE,0,LoadVid,
	FALSE,0,SetDevice_cmd,
	FALSE,0,Unknown,				// SelfTest
	FALSE,0,TBC_cmd,
	FALSE,0,NewCutList_cmd,
	FALSE,0,AddSubClip_cmd,
	FALSE,0,MakeSubClips_cmd,
	FALSE,0,CODEC_cmd,
	FALSE,0,NewSequence_cmd,
	FALSE,0,AddSequenceClip_cmd,
	FALSE,0,EndSequence_cmd,
	FALSE,0,PlaySequence_cmd,
	FALSE,0,GetSetOptions_cmd,
	FALSE,0,LocateField_cmd,
	FALSE,0,CacheTest_cmd,
	FALSE,0,FileExtend_cmd,
	FALSE,0,FileHSRead_cmd,
	FALSE,0,FileHSWrite_cmd,

};
#define	FUNCTABENTRIES	(sizeof(FuncTable)/sizeof(struct FuncEntry))


/*****************************/
/*   Main Interpreter Loop   */
/*****************************/

/*
 *	CommandWrapper - Wrapper to perform a command as its own task
 */
void static __asm CommandWrapper(register __d0 APTR ptr)
{
	struct CMDHDR	*cmdptr;
	ULONG		opcode;
	OPSPROC	func;

	cmdptr = (struct CMDHDR *)ptr;
	opcode = cmdptr->opcode & 0x3FFF;

	func = FuncTable[opcode].fn;

	func(cmdptr);				/* Perform the command! */
	CommandDone(cmdptr);		/* Mark command as done */

//	DBUG(print(DB_INTERP,"*Dead*");)
}



/*
 *  MainLoop - the main Flyer command loop
 */
void MainLoop(void)
{
static const UBYTE LED_ScannerData[] = {
	0x01, 0x02, 0x04, 0x08, 0x10, 0x08, 0x04, 0x02
};

	struct COMMAND	*cmdptr;
	struct FuncEntry *infoptr;
	OPSPROC	func;
	ULONG		opcode;
	UBYTE		ndx;
	ULONG		back = 0;
	UBYTE		image,curimage=99;

#define	SPAWNSTACKSIZE	1024

	DBUG(print(DB_ALWAYS,"--main loop--\n");)

	CommandDone(&cmd->slot[0]);		// Tell caller "done" - I'm running

#ifdef PHXCODE
	if (DIP_SignOn & DIPswitches())
		PlayClipAuto(0,0,"SignOn_clip",TRUE,0,0,3);
#endif

	//DBUG(print(DB_ALWAYS,"Memory free in pool = %l\n",MemCheck());)

	for (;;)
	{
		//print(DB_INTERP," ÐONT PANIC \N");		//testing 
		//AudEnvelope(cmdptr);							//testing

		DBUG(WatchReset();)		// Watch for Reset DIP -- DEBUGGING ONLY!!!

		cmdptr = &cmd->slot[0];
		for (ndx=NUMCMDSLOTS; ndx ;ndx--,cmdptr++)
		{
#ifdef PHXCODE
			HonorSerCmd();			// Check if serial command has arrived
#endif

			if (NewCmd(cmdptr))
			{
				DBUG(print(DB_INTERP,"Cmd:%w-- ",((struct CMDHDR *)cmdptr)->opcode);)
				//print(DB_INTERP,"Cmd:%w-- ",((struct CMDHDR *)cmdptr)->opcode);

				opcode = ((struct CMDHDR *)cmdptr)->opcode & 0x3FFF;
				if (opcode < FUNCTABENTRIES)
				{
					infoptr = &FuncTable[opcode];

					CommandBusy(cmdptr);			// Mark command as in progress
#if VERBOSE
					//DBUG(print(DB_INTERP,"%s",OpcodeNames[opcode]);)
#endif

					if (infoptr->spawn)			// Spawn a separate task for this?
					{
#if VERBOSE
						DBUG(printchar(DB_INTERP,'+');)
#endif
						StartTask((PROC)&CommandWrapper,infoptr->pri,SPAWNSTACKSIZE,
							(ULONG)cmdptr,"Shell");
					}
					else
					{
#if VERBOSE
						DBUG(printchar(DB_INTERP,'>');)
#endif
						func = infoptr->fn;
						func((struct CMDHDR *)cmdptr);		// Perform the command!
						CommandDone(cmdptr);						// Mark command as done
					}
				}
				else
				{
					Unknown(cmdptr);
					CommandDone(cmdptr);		/* Mark command as done */
				}
			}	// If
		}	// For


		if (FullyUp)			// Can we play with LED's now?
		{
			back++;
			image = LED_ScannerData[(back>>9)&7];
//			image = LED_ScannerData[(back>>2)&7];

//			image = 0;		// Kill it for now!

			// Only write to LED hardware when a change is required
			if (image != curimage)
			{
				ClrLEDs(image ^ 0x3F);
				SetLEDs(image);
				curimage = image;
			}
		}

		// This causes slow response from high-volume stuff like FileSystem
		// How can we do this and still respond quickly?
//		Delay(2);

	} /* FOREVER */
}


/*
 * ShowHostCrash - Do what's needed to show host that we crashed!
 */
void ShowHostCrash(void)
{
	struct COMMAND	*slot;
	int	i;

	slot = &cmd->slot[0];
	for (i=NUMCMDSLOTS;i;i--,slot++)
	{
		((struct CMDHDR *)slot)->error = ERR_CRASH;		// Show error!
		CommandDone(slot);				// Free all commands
	}
}


/*
 * CheckHostReset - Reset if instructed by host
 */
void CheckHostReset(void)
{
	struct COMMAND	*slot;
	int	i;

	slot = &cmd->slot[0];
	for (i=NUMCMDSLOTS;i;i--,slot++)
	{
		if (((struct CMDHDR *)slot)->opcode == 0x4048)
		{
			//DBUG(print(DB_ALWAYS,"Quitting\n");)
			Suicide_cmd((APTR)slot);
		}
	}
}


/************* Amiga/Flyer shared control structure (extra error info) ***************/
//	/* Amiga/Flyer shared control structure */
extern struct SHAREDCTRLSTRUCT *SharedCtrl;

void ExtraErrInfo(UBYTE error, ULONG id, ULONG inc)
{
	if (SharedCtrl->SeqError == ERR_OKAY)		// Only record 1st error
	{
		SharedCtrl->SeqError = error;
		SharedCtrl->UserID = id;
	}

	// If our type of error recorded, run up the tally
	if (SharedCtrl->SeqError == error)
		SharedCtrl->MoreInfo += inc;
}



#ifdef PHXCODE
/*
 * PlayClipAuto - Play a clip
 */
static UBYTE PlayClipAuto(	UBYTE chan,
									UBYTE drive,
									char *clipname,
									BOOL sync,
									ULONG	field,
									ULONG fields,
									UWORD	volramp)
{
	ACTION	action;
	struct FlyerVolume	volume;


	//DBUG(print(DB_GEN,"PlayClipAuto '%s'\n",clipname);)

	memset(&volume,0,sizeof(FlyerVolume));
	volume.v_Name = ((ULONG)clipname) - SRAMbase;		// Make offset
//	volume.v_Board = 0;
	volume.v_SCSIdrive = drive;
//	volume.v_Flags = 0;

	memset(&action,0,sizeof(ACTION));
	action.a_Volume = ((ULONG)&volume) - SRAMbase;		// Make offset
	action.a_Channel = chan;
	action.a_VidStartField = action.a_AudStartField = field;
	action.a_VidFieldCount = action.a_AudFieldCount = fields;
	action.a_VolSust1 = action.a_VolSust2 = 0xFFFF;
	action.a_Flags = AF_VIDEO | AF_AUDIOL | AF_AUDIOR;
	action.a_PermissFlags = APF_STEALOURVIDEO | APF_KILLOTHERVIDEO;
	action.a_AudioPan1 = 0x7FFF;
	action.a_AudioPan2 = -0x8000;
	action.a_VolAttack = volramp;
	action.a_VolDecay = volramp;

	return(Play1Clip(&action,sync,NULL,NULL));
}
#endif
