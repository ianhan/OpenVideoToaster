/*********************************************************************\
*
* Flyer FileSystem - Interfaces AmigaDOS to the Flyer card(s)
*							Module 2 - Volumes and misc support
*
* $Id: flyerfs2.c,v 1.3 1997/04/18 16:55:02 Holt Exp $
*
* $Log: flyerfs2.c,v $
*Revision 1.3  1997/04/18  16:55:02  Holt
*changed version number.
*
*Revision 1.2  1995/08/11  13:07:46  Flick
*Now uses ControlMsg string made by BSTRtoCSTR, not an array on stack
*
*Revision 1.1  1995/08/04  15:05:19  Flick
*Big cleanup -- removed all globals
*
*Revision 1.0  1995/05/05  15:49:38  Flick
*FirstCheckIn
*
*
* Copyright (c) 1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	02/22/94		Marty	created
\*********************************************************************/

#include "exec/types.h"
#include "exec/io.h"
#include "exec/memory.h"
#include "exec/tasks.h"
#include "exec/alerts.h"
#include "devices/timer.h"
#include "devices/trackdisk.h"
#include "devices/input.h"
#include "devices/inputevent.h"
#include "intuition/intuition.h"
#include "dos/dosextens.h"
#include "dos/filehandler.h"
#include "proto/exec.h"
#include "proto/dos.h"
#include "string.h"

#include "flyerlib.h"
#include "flyer.h"
#include	"FlyerFS.h"

#include "FlyerFS2.ps"
#include "FlyerFS1.p"
#include "FlyerFS2.p"
#include "FlyerFS3.p"

#define	DEBUGGING	0

#if DEBUGGING
#define	DBUG(x)	x
void kprintf(char *, ... );
#else
#define	DBUG(x)	/* nada */
#endif


/* These are never used, except for external viewing pleasure */
char static const	VersionString[] = "$VER: FlyerFileSystem 4.2 (04.18.97)";
char static const CopyrightString[] = "Copyright © 1997 NewTek, Inc.";
char static const AuthorString[] = "Written by Flickinger,Hayes,Holt";


BPTR DuplicateLock(struct FSbase *FS,BPTR lock)
{
	struct	LongLock		*ll,*l2;
	struct	DeviceList	*vol;
	BPTR		newlock,hold;
	ULONG		grip,newgrip,err;

	if (lock == NULL) 		/* Lock on root? */
		return(0);

	grip = Lock2Grip(lock);

	ll = (struct LongLock *)BADDR(lock);

//	if (ll->ll_Key == 0)			/* Invalid lock? */
//		return(DOSFALSE);

	if (FS->myVolume != ll->ll_Volume) 		// If duplock on unmounted volume
	{
		hold = FS->MasterLockList;				// Be sure to add new lock to THAT volume
		vol = (struct DeviceList *)BADDR(ll->ll_Volume);
		FS->MasterLockList = vol->dl_LockList;
		newlock = RequestLock(FS,ll->ll_Key,SHARED_LOCK,grip);
		if (newlock)
		{
			l2 = (struct LongLock *)BADDR(newlock);
			l2->ll_Volume = ll->ll_Volume;
		}
		vol->dl_LockList = FS->MasterLockList;
		FS->MasterLockList = hold;
	}
	else
	{
		FS->FlyVol.Path = 0;
		err = FlyerCopyGrip(&FS->FlyVol,grip,&newgrip);
		if (err==FERR_OKAY)
			newlock = RequestLock(FS,ll->ll_Key,SHARED_LOCK,newgrip);
		else
			newlock = 0;
	}

	return(newlock);
}


void RingMeBack(struct FSbase *FS,int seconds)
{
	register	struct	timerequest	*ior;

	ior = &FS->IntervalTimer;

	FS->TimerPkt.Action = ACTION_TIMER;		// Counterfeit packet when time up
	FS->TimerPkt.Link = (APTR)ior;
	ior->tr_node.io_Message.mn_Node.ln_Name = (char *)&FS->TimerPkt;
	ior->tr_node.io_Command = TR_ADDREQUEST;
	ior->tr_time.tv_secs = seconds;
	ior->tr_time.tv_micro = 0;
	SendIO((struct IORequest *)ior);
}


/* This routine locks the directory that is the parent of the locked item */

BPTR GetParent(struct FSbase *FS,BPTR lock)
{
	ULONG		grip,newgrip,block,err;

	grip = Lock2Grip(lock);

	FS->FlyVol.Path = NULL;
	err = FlyerParent(&FS->FlyVol,grip,&newgrip,&block);
	if (err)
	{
		FS->DOSerror = 0;
		lock = 0;
	}
	else
	{
		lock = RequestLock(FS,block,SHARED_LOCK,newgrip);

		DBUG(kprintf("\nMade lock %lx: Block:%lx  Grip:%lx",lock,block,newgrip);)

		if (lock==0)
			FS->DOSerror = ERROR_OBJECT_NOT_FOUND;
	}

	return(lock);
}


void GetMuchoStuffOnDrive(struct FSbase *FS)
{
	register	struct	FileSysStartupMsg	*fssm;
	register	ULONG		*env;
	struct	DevInfo	*dviptr;
	char		*ControlMsg;

	DBUG(kprintf("%ls\n",VersionString+6);)

	/* Get OS version 34, 36, 37, etc. */
	FS->OSversion = GetOSversion();

	fssm = (struct FileSysStartupMsg *)BADDR(FS->DosPkt->dp_Arg2);		// fssm ptr
	env = (ULONG *)BADDR(fssm->fssm_Environ);
	dviptr = (struct DevInfo *)BADDR(FS->DosPkt->dp_Arg3);

	/* Copy control string into local buffer and null-terminate it */
	ControlMsg = BSTRtoCSTR(env[DE_CONTROL]);
	if (ControlMsg==NULL)
	{
		Cleanup(FS);
		FS->ID = 0;			// Failure
		return;
	}

	DBUG(kprintf("Control string = ->%ls<-\n",ControlMsg);)

	FS->FSinfo.len = sizeof(struct FlyerVolInfo);
	FS->FlyVol.Path = 0;
	FS->FlyVol.Board = (UBYTE)GrabArg(ControlMsg,"BOARD",0);			/* Board number */
	FS->FlyVol.SCSIdrive = ((UBYTE)GrabArg(ControlMsg,"CHAN",0)<<3) +
						(UBYTE)GrabArg(ControlMsg,"UNIT",0);	/* SCSI unit number */
	FS->FlyerDrive = FS->FlyVol.SCSIdrive;		// Keep (just for debugging)
	FS->FlyVol.Flags = FVF_USENUMS;			// Always use these hard numbers

	FS->ClipAct.Volume = &FS->FlyVol;
	FS->ClipAct.ReturnTime = RT_STOPPED;	// All are syncronous

	DBUG(kprintf("Startup packet indicates...\n");)
	DBUG(kprintf("   board: %ld\n",FS->FlyVol.Board);)
	DBUG(kprintf("   drive: %ld\n",FS->FlyVol.SCSIdrive);)

	FS->TimerErr = FS->IEerr = -1;

	FS->IEReply = (struct MsgPort *)CreatePort(0,0);		// Open inputevent.dev
	if (FS->IEReply)
		FS->IEIO = (struct IOStdReq *)CreateStdIO(FS->IEReply);
	if (FS->IEIO)
		FS->IEerr = OpenDevice((UBYTE *)"input.device",0,
			(struct IORequest *)FS->IEIO,0);

	FS->TimerErr = OpenDevice("timer.device",UNIT_VBLANK,		// Open timer
		(struct IORequest *)&FS->IntervalTimer,0);
	if (FS->TimerErr)
	{
		Cleanup(FS);
		FS->ID = 0;			// Failure
	}
	else
	{
		FS->ClockTime = FS->IntervalTimer;		// Clone it

		FS->IntervalTimer.tr_node.io_Message.mn_ReplyPort = FS->myMsgPort;
		FS->ClockTime.tr_node.io_Message.mn_ReplyPort = &FS->ClockReplyPort;

		if (GetVolumeInfo(FS))			// Get volume node, drive info
			DiskInOut(FS,1);				// Might cause problems for WB1.3

		DBUG(kprintf("dvi @ %lx\n",dviptr);)
		dviptr->dvi_Task = (APTR)FS->myMsgPort;		// Complete DevInfo so doesn't spawn more
	}

	FreeVec(ControlMsg);					// Free this string
}


ULONG GrabArg(char *startup,char *keyword,ULONG dflt)
{
	register	char *ptr,*scan,*cmp;
	ULONG		val;
	char		c;

	for (scan=startup;*scan;scan++)
	{
		ptr = scan;
		cmp = keyword;
		do
		{
			if (*cmp == 0)
			{
				if (*ptr++ != '=')
					return(1);			/* Flag only */
				val = 0;
				while ((c=*ptr++,c>='0')&&(c<='9'))
				{
					val *= 10;
					val += (ULONG)(c-'0');
				}
				return(val);
			}
		} while (uppercase(*cmp++) == uppercase(*ptr++));
	}

	return(dflt);
}


char uppercase(char in)
{
	if ((in>='a')||(in<='z'))
		return((char)(in-32));
	else
		return(in);
}


void Cleanup(struct FSbase *FS)
{
	if (!FS->TimerErr)
		CloseDevice((struct IORequest *)&FS->IntervalTimer);

	if (!FS->IEerr)	CloseDevice((struct IORequest *)FS->IEIO);
	if (FS->IEIO)		DeleteStdIO(FS->IEIO);
	if (FS->IEReply)	DeletePort(FS->IEReply);
}


struct DeviceList *MakeVolume(char *name)
{
	register	struct	DeviceList	*vol;
	register	BPTR		*first;
	register	UBYTE		*mem;

	vol = (struct DeviceList *)AllocMem(sizeof(struct DeviceList),MEMF_PUBLIC|MEMF_CLEAR);
	if (vol)
	{
		mem = (UBYTE *)AllocMem(*name + 2,MEMF_PUBLIC|MEMF_CLEAR);
		if (mem == NULL)
		{
			FreeMem((UBYTE *)vol,sizeof(struct DeviceList));
			vol = NULL;
		}
		else
		{
			vol->dl_Name = (BSTR)MKBADDR(mem);
			vol->dl_DiskType = ID_FLYER_DISK;
//			vol->dl_DiskType = ID_DOS_DISK;

			strncpy(mem,name,*name+1);		/* Copy BSTR */
				// This is not smart; I have to null-terminate a BSTR!!
				// But DOS seems to like it that way!?!?
				// Now, even my code is relying on this elsewhere!
			mem[1 + *mem] = 0;

			/* Insert it into DeviceList at top */
			Forbid();
//~~~~~~~~~~~~~~
			first = GetDevListPtr();
			vol->dl_Next = *first;
			*first = (BPTR)MKBADDR(vol);
//~~~~~~~~~~~~~~
			Permit();
		}
	}

	return(vol);
}


void DeleteVolume(BPTR vol)
{
	register	struct	DeviceList	*volptr;
	register	BPTR		*list;
	register	char		*name;

	if (vol)
	{
		DBUG(kprintf("Deleting volume\n");)

		Forbid();
//~~~~~~~~~~~~~~
		for (list=GetDevListPtr() ; *list ; list=(BPTR *)BADDR(*list))
		{
			if (*list == vol)
			{
				volptr = (struct DeviceList *)BADDR(vol);
				*list = volptr->dl_Next;							// link around it
				name = (char *)BADDR(volptr->dl_Name);
				FreeMem((UBYTE *)name,*name+2);
				FreeMem((UBYTE *)volptr,sizeof(struct DeviceList));
			}
		}
//~~~~~~~~~~~~~~
		Permit();
	}
}


void UndoVolume(struct FSbase *FS)
{
	register	struct	DeviceList	*vol;
	register	BPTR		*ptr;

	DBUG(kprintf("Undoing volume\n");)

	if (FS->myVolume)						// Is the mounted volume?
	{
		/*** If volume has any locks outstanding, copy into volume node ***/
		if (FS->MasterLockList)
		{
			vol = (struct DeviceList *)BADDR(FS->myVolume);
			ptr = &vol->dl_LockList;
			while (*ptr)							// Find last one in list
				ptr = (BPTR *)BADDR(*ptr);

			*ptr = FS->MasterLockList;			// Append Master locklist
			vol->dl_Task = 0;						// Volume is unmounted
		}
		else
		{
			DeleteVolume(FS->myVolume);		// Locks, forget about volume
		}
		FS->MasterLockList = FS->myVolume = 0;		// "UnMount" volume
	}
}


void DiskChanges(struct FSbase *FS)
{
	int	nowloaded;

	nowloaded = GetDiskState(FS);						// Find out if disk is in or out

	if ((FS->DiskLoaded) && (nowloaded == 0))		// Disk removed?
	{
		DBUG(kprintf("Ejected\n");)

		UndoVolume(FS);
		DiskInOut(FS,0);					// Create DISKREMOVED input event
		FS->ID = ID_NO_DISK_PRESENT;
	}

	if ((FS->DiskLoaded == 0) && (nowloaded))		// Disk inserted?
	{
		DBUG(kprintf("Inserted\n");)

		GetVolumeInfo(FS);		// Make sure it knows a disk is loaded!
		DiskInOut(FS,1);			// Create DISKINSERTED input event
	}

	FS->DiskLoaded = nowloaded;
}


BPTR *GetDevListPtr(VOID)
{
	return(&((struct DosInfo *)BADDR(((struct RootNode *)DOSBase->dl_Root)->rn_Info))->di_DevInfo);
}


struct DeviceList * GetVolumeInfo(struct FSbase *FS)
{
	register	struct	DeviceList	*vol;
	register	BPTR		link;
				BPTR		*p7;
	ULONG	error;
	BOOL	conflict,foundmine;

	DBUG(kprintf("Mounting disc volume...\n");)

	/* Setup excuse in case any data read fails (unformatted disk) */
	FS->ID = ID_NOT_REALLY_DOS;

	if (FS->FlyerState != FLYST_OKAY)		// No Flyer yet, keep waiting
	{
		FS->ID = ID_NO_DISK_PRESENT;
		return(0);
	}

	FS->FlyVol.Path = 0;
	FS->FSinfo.len = sizeof(struct FlyerVolInfo);
	error = FlyerDriveInfo(&FS->FlyVol,&FS->FSinfo);	/* Talk to Flyer... */

	DBUG(kprintf("FSinfo error code %ld\n",error);)

	if (error == FERR_SELTIMEOUT)			// If no drive here
		FS->ID = ID_NO_DISK_PRESENT;

	if (error)
		return(0);

	if (FS->FSinfo.Ident != 0x524f4f54)
	{
		FS->ID = ID_NOT_REALLY_DOS;
/*		FS->ID = ID_UNREADABLE_DISK; */
		return(0);
	}
	FS->ID = ID_FLYER_DISK;

	SetLogicalInfo(FS);						// Setup for Log Blk Size

	/* Work volume name */
	FS->FSinfo.LTitle = strlen(FS->FSinfo.Title);	/* Convert C-string to L-string */

	DBUG(kprintf("The disc's title: %ls\n",FS->FSinfo.Title);)

	/* Now find volume for disc, or make new one */

	conflict = foundmine = FALSE;

	Forbid();
//~~~~~~~~~~~~~~~~~
	vol = NULL;
	for (link=*(GetDevListPtr()) ; link ; link = vol->dl_Next)
	{
		vol = (struct DeviceList *)BADDR(link);
		if (vol->dl_Type == DLT_VOLUME)
		{
			if (CompareBSTRs(&FS->FSinfo.LTitle,(char *)BADDR(vol->dl_Name)))
			{
				/* Different FS with same volume name? */
				if ((vol->dl_Task) && (vol->dl_Task != (struct MsgPort *)FS->myMsgPort))
					conflict = TRUE;
				else
				{
					if ((vol->dl_VolumeDate.ds_Days == FS->FSinfo.DiskDate.ds_Days)
					&&(vol->dl_VolumeDate.ds_Minute == FS->FSinfo.DiskDate.ds_Minute)
					&&(vol->dl_VolumeDate.ds_Tick == FS->FSinfo.DiskDate.ds_Tick))
					{
						foundmine = TRUE;			// My volume probably
						break;
					}
				}
			}
		}
	}

	if (!foundmine)
	{
		/* Go ahead and make a new volume, even if similar one already exists */

		vol = MakeVolume(&FS->FSinfo.LTitle);	/* Allocate volume node, plug in title */
		if (vol)
		{
			/* Fill in rest of volume node */
			vol->dl_Lock = 0;
			vol->dl_LockList = 0;
			vol->dl_Type = DLT_VOLUME;
			vol->dl_VolumeDate = FS->FSinfo.DiskDate;	/* Copy Disk datestamp */
		}
	}

	if (vol)
	{
		vol->dl_Task = (struct MsgPort *)FS->myMsgPort;	// Show it's mounted
		FS->myVolume = (BPTR)MKBADDR(vol);					// Keep ptr --> current volume node

		/* Move locks listed in volume node ----> My master lock list */
		p7 = &FS->MasterLockList;
		while (*p7)
		{
			p7 = (BPTR *)BADDR(*p7);				/* scan for end of MasterLockList */
		}
		*p7 = vol->dl_LockList;
		vol->dl_LockList = 0;
	}
//~~~~~~~~~~~~~~~~~
	Permit();

	if (conflict)
	{
		DBUG(kprintf("Conflict\n");)
		DuplicateVolumeError(FS,vol);		/* Warn user! */
	}

	return(vol);
}



/* Find logical block size to use (smallest one that will contain 'logsize') */
/* Set all variables needed for logical block reading */
void SetLogicalInfo(struct FSbase *FS)
{
	int	i;

	for (i=0;i<16;i++)			/* Compute shift bits for logblk size */
	{
		if ((1<<i) >= FS->FSinfo.BlkSize)
			break;
	}
	FS->LogBlkShift = i;
}



// CompareBSTRs:
//
// A straight comparison of the 2 BSTR's is made (all characters must be
// the same (not case-sensitive) and lengths must match.

BOOL CompareBSTRs(char *s1,char *s2)
{
	register	char	chr1,chr2;
	register	char	*p1,*p2;
	register	UBYTE	len;

	p1 = s1;
	p2 = s2;

	len = *p1++;

	if (len != *p2++)			// If different lengths, give up!
		return(FALSE);

	while (len--)
	{
		chr1 = *p1++;
		if ((chr1 >= 'a')&&(chr1 <= 'z')) chr1-=32;  // make upper case

		chr2 = *p2++;
		if ((chr2 >= 'a')&&(chr2 <= 'z')) chr2-=32;  // make upper case

		if (chr1 != chr2)
			return(FALSE);				// mismatch!
	}
	return(TRUE);						// same!
}


void DiskInOut(struct FSbase *FS,int flag)
{
				struct	InputEvent	event;
	register	struct	IOStdReq		*iob;

	iob = FS->IEIO;

	DBUG(kprintf("Disk in/out %ld\n",flag);)

	if (!FS->IEerr)
	{
		iob->io_Command = IND_WRITEEVENT;
		iob->io_Flags = 0;
		iob->io_Length = sizeof(struct InputEvent);
		iob->io_Data = (APTR)&event;

		event.ie_Class = (flag)?IECLASS_DISKINSERTED:IECLASS_DISKREMOVED;
		event.ie_Code = IECODE_NOBUTTON;
		event.ie_NextEvent = 0;
		event.ie_Qualifier = 0;

		DoIO((struct IORequest *)iob);
	}
}


void GetDateStamp(struct FSbase *FS,struct DateStamp *stamp)
{
	register ULONG secs,temp;

	FS->ClockTime.tr_node.io_Command = TR_GETSYSTIME;
	FS->ClockTime.tr_node.io_Flags = 1;

	DoIO((struct IORequest *)&FS->ClockTime);		/* get system time */

	secs = FS->ClockTime.tr_time.tv_secs;
	temp = secs/86400;
	secs -= temp*86400;
	stamp->ds_Days = temp;			/* set days */

	temp = secs/60;
	secs -= temp*60;
	stamp->ds_Minute = temp;		/* set minutes */

	stamp->ds_Tick = secs*50 + FS->ClockTime.tr_time.tv_micro/20000;
}
