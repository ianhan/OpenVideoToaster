/*********************************************************************\
*
* $FileSys.c - Disk FileSystem$
*
* $Id: FILESYS.C,v 1.21 1997/05/14 11:25:03 Holt Exp $
*
* $Log: FILESYS.C,v $
*Revision 1.21  1997/05/14  11:25:03  Holt
*FINISHED HS FILE XFER.
*
*Revision 1.20  1997/04/18  16:59:28  Holt
*turned debug on and off
*
*Revision 1.19  1997/04/03  16:25:11  Holt
*debug off
*
*Revision 1.18  1997/03/26  16:33:45  Holt
*added more high speed multi-block read/write code.
*fixed Todds Read/write bugs.
*
*Revision 1.17  1997/02/06  23:37:22  Holt
*no real changes.
*
*Revision 1.15  1997/02/05  19:08:52  Hayes
*Fixed Defrag to allow 0 length files to defrag properly
*
*Revision 1.14  1997/02/05  16:43:08  Hayes
*Turned off Debugging
*
*Revision 1.13  1997/02/05  16:33:49  Hayes
*changed FileSeek to handle files of 64-bit size
*
*Revision 1.12  1997/01/17  18:42:47  Hayes
*Expanded filesystem to handle files of 64 bit bytelengths in grip structure
*and operations
*
*Revision 1.11  1997/01/09  14:14:54  Holt
*interim SRAM fixes
*
*Revision 1.10  1996/12/19  17:09:05  Holt
*added FileExtend which extends a file without writing data to it.
*
*Revision 1.9  1996/12/09  17:38:14  Holt
*turned off debuggin.
*g..
*
*Revision 1.8  1995/12/18  13:49:48  pfrench
*Added temporary hack of CopyFile Semaphore access
*
*Revision 1.7  1995/11/21  11:34:09  Flick
*New fn "FindPatchArea"
*
*Revision 1.6  1995/10/10  01:26:46  Flick
*GetClipInfo now reports VidGrade, DeFrag is now Host-abortable
*Cleaned up some commented-out crufty code that I don't even want to see anymore
*GetBlock now takes R/W flag arg, lots of new code added to correctly support exclusive access
*to a block so that two tasks that want it at same time don't stomp on each other.  Exclusive-
*access code IFDEF'd out until after 4.1 ships, because it seems buggy.
*Now uses semaphore to arbitrate for the one DRAM block for transferring caches to/from disk!!
*This may have been trashing drives' FS, but just in case, added failsafe to prevent anything
*from ever writing non-ROOT buffer to 0.  Now uses FSDRAM block thruout (was MISCDRAM+4)
*
*Revision 1.5  1995/09/07  09:27:22  Flick
*(Release 4.06)
*Added improved head-cleanup mechanism.  Does head flushing when formatting or
*defrag'ing.
*
*Revision 1.4  1995/08/30  17:44:44  Flick
*Make ZapAllHeads do cleanup for disassociated clips/heads (big problem!)
*
*Revision 1.3  1995/08/15  17:00:55  Flick
*Fi
*First release (4.05)
*
*Revision 1.2  1995/05/04  17:14:40  Flick
*Phx/Flyer duality improved, some stub code moved into AmiShar.c
*
*Revision 1.1  1995/05/03  10:44:21  Flick
*Automated prototypes, and reduced includes when possible
*
*Revision 1.0  1995/05/02  11:05:53  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	03/01/94		Marty	created
*	02/06/95		Marty	Ported to C
\*********************************************************************/

#define	LOCALDEBUG		0			// Debugging switch for this module only

#include <Types.h>
#include <Flyer.h>
#include <Errors.h>
#include <Exec.h>
#include <FileSys.h>
#include <Vid.h>
#include <Lists.h>
#include <Ser.h>
#include <SCSI.h>
#include <Debug.h>

#include <proto.h>
#include <FileSys.ps>

#define	EXCL_SUPPORT	0

extern const ULONG SRAMbase;			// Base of shared SRAM memory map
extern struct DriveStuff	DrvInfo[NUMSCSIDRIVES];
extern struct TOD RealTimeClock;		// Internal Flyer real-time clock


GRIP	RootGrip;			// Default grip when 0 specified
union FSBUFF	(*Buffs)[NUMFSBUFS] = (union FSBUFF (*)[])FSBASE;
#define	baseof_Buffs		1

struct Semaphore	DramTempSema;
struct Semaphore	CopyFileSema;

struct BufCtl	BuffCtrl[NUMFSBUFS];
#define	baseof_BuffCtrl	1

struct List BufsFree;

BOOL	FlyerDrives[NUMSCSIDRIVES];	// Flyer-formatted drives
UBYTE	BigUnit[NUMSCSICHANS];			// Biggest video-ready unit on each channel
UBYTE	OppChan[NUMSCSICHANS];			// Correlation array -- "opposite" channels
UBYTE	AudScsiChan;	// Channel on which audio drive(s) found (or FF if none)
UBYTE	AudScsiDrive;				// Main audio drive (or FF if none)
ULONG	GripCount;					// Number of GRIPs that are currently allocated
ULONG	HdrHint;						// Last header block that was given me


/*
 * InitFileSys -- Initialization code
 */
void InitFileSys(void)
{
	struct BufCtl	*bc;
	UWORD	i;

	NewList(&BufsFree);			// Init free FS buffers list

	bc = &BuffCtrl[1-baseof_BuffCtrl];
	for (i=1; i<=NUMFSBUFS; i++,bc++)
	{
		bc->block = NIX;			// No valid block data cached here yet
		bc->users = 0;				// No users of this buffer
		bc->dispose = FALSE;		// No trouble yet for this block
		bc->ndx = i;
#if EXCL_SUPPORT
		bc->locked = FALSE;		// Not exclusively locked
		InitSemaphore(&bc->exclsema);		// For arbitrating exclusive access to block
#endif
		AddTail((struct Node *)bc,&BufsFree);	// Add to "free" list
	}

	InitSemaphore(&DramTempSema);		// For arbitrating use of DRAM temp buffer
	InitSemaphore(&CopyFileSema);		// For arbitrating CopyFile semaphore

	RootGrip.g_header = 0;
	RootGrip.g_type = TYPE_ROOT;
	RootGrip.g_parent = 0;

	GripCount = 0;
	HdrHint	 = 0;
}

/*
 *  ReadBlock - Read 1 block from SCSI channel
 */
UBYTE ReadBlock(	UBYTE	drive,
						ULONG	blk,
						union FSBUFF	*buff)
{
	UBYTE	err;

	//DBUG(printchar(DB_ALWAYS,'r');)

	ObtainSemaphore(&DramTempSema);		// Wait until we own the temp DRAM buffer

	/* DMA block to DRAM to buffer */
	err = ScsiReadSRAM(drive,blk,FSDRAM,buff,1);

	ReleaseSemaphore(&DramTempSema);		// Free up for others

	return(err);
}


/*
 *  WriteBlock - Write 1 block to SCSI channel
 */
UBYTE WriteBlock(	UBYTE	drive,
						ULONG	blk,
						union FSBUFF	*buff)
{
	UBYTE	err;

	// Special test to prevent me from clobbering a drive (until FS stabilizes a bit)
	if ((blk==0) && (buff->root.id != ID_ROOT))
		return(ERR_FSFAIL);

	//DBUG(printchar(DB_ALWAYS,'w');)

	ObtainSemaphore(&DramTempSema);		// Wait until we own the temp DRAM buffer

	/* From SRAM to DRAM to disk */
	err = ScsiWriteSRAM(drive,buff,FSDRAM,blk,1);

	ReleaseSemaphore(&DramTempSema);		// Free up for others

	return(err);
}


/*
 * Buff2Ctrl - Convert buffer ptr to its associated BuffCtrl index
 */
static UWORD Buff2Ctrl(union FSBUFF *buff)
{
	UWORD	index;

	if (buff == NULL)
		index = 0;
	else
	{
		index = (((ULONG)buff - FSBASE) / 512) +1;
		if (index > NUMFSBUFS)
			index = 0;
	}
	return(index);
}


/*
 *  GetBlock - Reads data from specified SCSI drive and return ptr to
 *					buffer which contains the data.  If data is already cached,
 *					will simply return pointer to it.  When done processing the
 *					data, you must call 'FreeBlock' to avoid hogging a buffer.
 */
UBYTE GetBlock(UBYTE	drive,
					ULONG	blk,
					BOOL	readflag,
					union FSBUFF **buff)
{
	UBYTE	err;
	ULONG	i,ndx;
	struct BufCtl *bc;

//	DBUG(print(DB_TEST,"GetBlock: drv %b, blk %l\n",drive,blk);)

retry:
	Forbid();		// Prevent others from accessing free list and altering buffers

	/*** First, try to find our block cached in some buffer ***/
	/*** This may be in the list of free buffers (users=0) or may be in use ***/
	/*** by someone.  It may even have an exclusive lock on it (locked=TRUE) ***/
	bc = &BuffCtrl[0];
	for (i=NUMFSBUFS ; i ; i--,bc++)
	{
		if ((bc->block == blk) && (drive == bc->scsidrv))		// Found it?
		{
			ndx = bc->ndx;

			//DBUG(print(DB_INTERN,"block %l found in cache %l\n",blk,ndx);)
			//DBUG(print(DB_SCSI,"(lba:%l from cache)\n",blk);)

#if EXCL_SUPPORT
			// If we want exclusive lock on a block that is cached for READ-only,
			// we must keep waiting/retrying until all users are done looking at it
			if ((bc->users != 0) && (!bc->locked) && (!readflag))
			{
				//DBUG(printchar(DB_ALWAYS,'W');)
				Permit();		// Allow other users to wrap up work
				Delay(1);		// Don't hog CPU waiting
				goto retry;		// Must rescan for this, as it could get flushed
			}

			if ((bc->locked)				// Someone is modifying this block?
			|| (!readflag))				// or we need exclusive access?
			{
				// If so, we must wait until it's available and then take exclusive access
				//DBUG(printchar(DB_ALWAYS,'L');)
				ObtainSemaphore(&bc->exclsema);
				if (readflag)
				{
					//DBUG(printchar(DB_ALWAYS,'U');)
					ReleaseSemaphore(&bc->exclsema);	// Return if don't need exclusive access
				}
				else
					bc->locked = TRUE;					// Someone (me) owns this now
			}
#endif

			if (bc->users==0)								// Am I the first user?
				Remove((struct Node *)bc);				// If so, remove from free list
			bc->users++;									// Bump use count

			*buff = &(*Buffs)[ndx-baseof_Buffs];	// Return pointer to buffer

			Permit();
			return(ERR_OKAY);
		}
	}

	// Okay, the block is not held in any of the buffers
	// Need to get a buffer that I can use to hold data from the drive

	bc = (struct BufCtl *)RemHead(&BufsFree);		// Get stalest free buffer in cache
	if (bc)
	{
		ndx = bc->ndx;

		//DBUG(print(DB_INTERN,"Reuse %l-was %l\n",ndx,bc->block);)

		bc->block = NIX;
		bc->users = 1;								// I'm the only user of this so far

#if EXCL_SUPPORT
		if (readflag)
		{
			bc->locked = FALSE;
		}
		else
		{
			//DBUG(printchar(DB_ALWAYS,'L');)
			ObtainSemaphore(&bc->exclsema);	// Won't ever wait, no one owns it
			bc->locked = TRUE;
		}
#endif
	}
	else				// No buffer free to load another?
	{
		*buff = NULL;
		//DBUG(print(DB_INTERN,"Failed to get a new buf\n");)

		Permit();

		return(ERR_FSFAIL);
	}


	*buff = &(*Buffs)[ndx-baseof_Buffs];	// Return pointer to buffer

	Permit();

	err = ReadBlock(drive,blk,*buff);		// Read new data into buffer
	if (err == ERR_OKAY)
	{
		//DBUG(print(DB_INTERN,"Read lba %l into cache %l\n",blk,ndx);)

		// I can avoid doing a Forbid() here because 'block' is NIX, we set it last!
		bc->scsidrv = drive;		// These help others find this block cached in memory
		bc->block = blk;			// As of now the block can be found by others, its valid
	}
	else
	{
		// Oh crud!  Read failed!  Return buffer to free pool or it'll be lost forever

		Forbid();					// All this stuff should be atomic!

#if EXCL_SUPPORT
		if (bc->locked)
		{
			bc->locked = FALSE;
			//DBUG(printchar(DB_ALWAYS,'U');)
			ReleaseSemaphore(&bc->exclsema);
		}
#endif

		bc->users = 0;
		AddHead((struct Node *)bc,&BufsFree);	// Put back on top of list where we got it
		Permit();

		*buff = NULL;
	}

	return(err);
}


/*
 *  PutBlock - Write block of data out to disk
 */
UBYTE PutBlock(union FSBUFF *buff)
{
	UBYTE	err;
	UWORD	ndx;
	struct BufCtl *bc;

	ndx = Buff2Ctrl(buff);
	if (ndx == 0)
	{
		err = ERR_FSFAIL;
		//DBUG(print(DB_INTERN,"Bad BufNdx\n");)
	}
	else
	{
		bc = &BuffCtrl[ndx-baseof_BuffCtrl];
		//DBUG(print(DB_INTERN,"Writing cache %l back out (blk %l)\n",ndx,bc->block);)

		err = WriteBlock(bc->scsidrv,bc->block,buff);
		if (err)
			bc->dispose = TRUE;		// Note that we had trouble, dispose of when freed
	}

	return(err);
}


/*
 *  FreeBlock - Free up data buffer for possible reuse
 */
void FreeBlock(union FSBUFF **buff)
{
	struct BufCtl *bc;
	UWORD	ndx;

	if (*buff != NULL)
	{
		ndx = Buff2Ctrl(*buff);
		if (ndx != 0)
		{
			//DBUG(print(DB_INTERN,"Freeing cache %l\n",ndx);)

			bc = &BuffCtrl[ndx-baseof_BuffCtrl];

			Forbid();											// Prevent others from accessing list
			bc->users--;										// Release my lock on this block
			if (bc->users == 0)								// Was I the only remaining locker?
			{
				AddTail((struct Node *)bc,&BufsFree);	// Add back into free cache (at bot)

				if (bc->dispose)
				{
					bc->block = NIX;					// Data may be bad, don't keep in cache
					bc->dispose = FALSE;
				}
			}

#if EXCL_SUPPORT
			if (bc->locked)							// If I had an exclusive lock, free it
			{
				bc->locked = FALSE;
				//DBUG(printchar(DB_ALWAYS,'U');)
				ReleaseSemaphore(&bc->exclsema);
			}
#endif

			Permit();		// Someone else may run here if waiting on this block's sema
		}
		*buff = NULL;
	}
	else
	{
		//DBUG(print(DB_ALWAYS,"FreeTwice!");)
	}
}


/*
 *  FlushDrive - Flush all buffers for given drive
 */
void FlushDrive(UBYTE drive)
{
	ULONG	i;
	struct BufCtl *bc;

	//DBUG(print(DB_FILESYS,"Flushing cache for drive %b\n",drive);)

	bc = &BuffCtrl[0];
	for (i=NUMFSBUFS ; i ; i--,bc++)
	{
		if ((bc->block != NIX) && (drive == bc->scsidrv))
		{
			if (bc->users == 0)
				bc->block = NIX;
		}
	}
}


/*
 *  CalcHash - Calculate filename hash value
 */
static UWORD CalcHash(char *filename)
{
	UWORD	val;

	val = 0;
	/* Stop on NULL or '/' */
	while ((*filename != 0) && (*filename != '/'))
	{
		val = (val*13 + toupper(*filename++)) & 2047;
	}
	val %= ROOTENTRIES;

	return(val);
}



/*
 *  Format - Formats drive's filesystem (all blank)
 */
UBYTE Format(	UBYTE	drive,
					char	*name,
					struct FlyerDate *stamp,
					ULONG	blocks,
					BYTEBITS	flags)
{
	union FSBUFF	*buff,*buff2;
	UBYTE	err;
	UWORD	entry;
	ULONG	blk,fmtblks,megs,size,count,mapsize;
	BOOL	vidready;

	// This is not so elegant, but it's an easy way to ensure that we don't
	// disassociate clip head data from the definitions on another drive.  Improve???
//	KillAllHeads();
	CleanupHeads();		// This is faster/less severe, doesn't do rebuild surgery

	//DBUG(print(DB_FILESYS,"Asking for flags %b\n",flags);)

	/* Determine if drive is video-ready */
	vidready = DriveVidReady(drive);
	if (! vidready)
		flags &= ~FVIF_VIDEOREADY;

	//DBUG(print(DB_FILESYS,"Using flags %b\n",flags);)

	/* Ask drive how big it is */
	fmtblks = GetUnitSize(drive);

	//DBUG(print(DB_FILESYS,"I see drive has %l blocks\n",fmtblks);)

	/* User wants to format only a portion of the drive? */
	if ((blocks != 0) && (blocks < fmtblks))
		fmtblks = blocks;

	//DBUG(print(DB_FILESYS,"User spec'd %l, so %l it is\n",
	//	blocks,fmtblks);)

	err = GetBlock(drive,RootGrip.g_header,WRITE,&buff);		// Read block to get a buffer
	if (err != ERR_OKAY)
		return(err);

	ClearMemory(buff,512);		// Start with blank buffer

	buff->root.id = ID_ROOT;
	buff->root.flags = flags;
	buff->root.diskokay	= TRUE;
	buff->root.blksize	= DFLTBLKSIZE;			// Change this!
	megs = fmtblks >> (MEGABYTESHIFT - DFLTBLKSZSHIFT);	// Drive size (MB)
	buff->root.parent		= 0;

	CopyString(name,buff->root.volname,VOLNAMELENGTH);

	/* Allocate stuff at bottom of drive */

	buff->root.freelist	= 1;
	mapsize = (megs+MAPENTRIES-1) / MAPENTRIES;
	if (mapsize < MINFREEMAPBLKS)
		mapsize = MINFREEMAPBLKS;			// Not too small!

	buff->root.headlist	= buff->root.freelist + mapsize;
	size = HEADLISTSIZE;		// Tune this?
	buff->root.newheadlist	= buff->root.headlist + size;

	buff->root.hdrsarea	= buff->root.newheadlist + size;
	buff->root.unused		= buff->root.hdrsarea;
	size = megs * 2;		// Allow avg file size down to 1 MB
	if (size < MINFILEHDRS)
		size = MINFILEHDRS;	// Always have this minimum # of file/dir headers

	buff->root.dataarea	= buff->root.hdrsarea + size;

	/* Now allocate stuff at top of drive */

	buff->root.videoend	= fmtblks - CHIPPATCHAREA;
	buff->root.headspace	= 0;						// No heads on drive yet

	buff->root.version = FS_VERSION;
	buff->root.type = TYPE_ROOT;

	/* Record date/time formatted */
	CopyMem(stamp,&buff->root.date,sizeof(struct FlyerDate));

	buff->root.userblks	= buff->root.videoend-buff->root.dataarea;
/*	buff->root.blksfree	= buff->root.userblks; */

	for (entry=0;entry<ROOTENTRIES;entry++)
	{
		buff->root.entries[entry] = 0;
	}

	err = PutBlock(buff);
	if (err == ERR_OKAY)
	{
		/* Create freelist for an empty drive */
		blk = buff->root.freelist;
		count = mapsize;
		do
		{
			err = GetBlock(drive,blk,WRITE,&buff2);	// Read block in
			if (err == ERR_OKAY)
			{
				ClearMemory(buff2,512);				// Start with blank buffer
				buff2->map.mb_ID = MAP_ID;
				if (count == 1)
					buff2->map.mb_Next = 0;			// Last block
				else
					buff2->map.mb_Next = 1;

				if (blk == buff->root.freelist)
				{
					buff2->map.mb_Entries[0].me_Block = buff->root.dataarea;
					buff2->map.mb_Entries[0].me_Length= buff->root.userblks;
					buff2->map.mb_Entries[1].me_Block = LISTEND;
				}
				err = PutBlock(buff2);
				FreeBlock(&buff2);
				blk++;
				count--;
			}
		} while ((err == ERR_OKAY) && (count != 0));

		/* Create empty headlist (present) */
		err = BlankHeadList(drive,buff->root.headlist,HEADLISTSIZE);
		/* Create empty headlist (new) */
		err = BlankHeadList(drive,buff->root.newheadlist,HEADLISTSIZE);

		if (err == ERR_OKAY)
		{
			err = GetBlock(drive,buff->root.hdrsarea,WRITE,&buff2);	// Get a buffer
			if (err == ERR_OKAY)
			{
				/* Clear file/dir headers area */
				ClearMemory(buff2,512);		// Start with blank buffer
				buff->file.id = 0;

				for (blk=buff->root.hdrsarea;blk<buff->root.dataarea;blk++)
				{
					if (err == ERR_OKAY)
					{
						err = WriteBlock(drive,blk,buff2);
					}
				}
				FreeBlock(&buff2);
			}
		}
	}

	FreeBlock(&buff);				// Release root block
	FlushDrive(drive);			// Invalidate all drive's buffers

	DriveSurvey();					// Resurvey what drives are where


//	volptr = AddVolume(name,schan,0);	// Add to system MountedVolume list


	return(err);
}


/*
 *  LocObj - Find named object on drive.  If no error, leaves 'buff' allocated
 *				 with the found object's header in it (caller must free it)
 *				 Whether succeeds or fails, returns info about search in prevblk,
 *				 linkhash,block,and buff,linkblk,momblk
 */
UBYTE LocObj(	UBYTE	drive,
					GRIP	*grip,
					char	*filename,
					char	**basename,
					ULONG	*linkblk,
					WORD	*linkhash,
					ULONG	*block,
					union FSBUFF	**buff,
					ULONG	*momblk)
{
	union FSBUFF	*buff2;
	UBYTE	err,hold;
	char	*token,*name,*termptr;
	BOOL	same;
	ULONG	*longptr;

	if (grip == NULL)
		grip = &RootGrip;

	/* Strip dev: off filename */
	name = StripDevName(filename);

	*block = grip->g_header;			// Place to start looking

	/* Pre-load buffer to start loop */
	err = GetBlock(drive,*block,WRITE,&(*buff));
	if (err != ERR_OKAY)
		return(err);

	/* Look for each part of pathname */
	do
	{
		if (*name == '/')
		{
			name++;

			/* Find parent */
			if ((*buff)->file.type == TYPE_ROOT)
				err = ERR_OBJNOTFOUND;
			else
			{
				*block = (*buff)->file.parent;
				*basename = NULL;

				/* Close previous header */
				FreeBlock(&(*buff));

				err = GetBlock(drive,*block,WRITE,&(*buff));
			}
		}
		else
		{
			token = name;
			name = SkipSubName(name,&termptr);

			/* If we get successfully to the bottom of the pathname,
				return pointer to the base name, else return NULL
				to signify that higher levels of the path were invalid */
			if (*name == 0)
				*basename = token;
			else
				*basename = NULL;

			*momblk = *block;					// Block of my parent
			*linkblk = *block;				// Block for me to link to

			*linkhash = CalcHash(token);

			//DBUG(print(DB_FILESYS,"hash = %w\n",(ULONG)*linkhash);)

			/* Consult hash table for where to look */
			*block = (*buff)->root.entries[*linkhash];

			/* Close previous header */
			FreeBlock(&(*buff));

			for (;;)
			{
				if (*block == 0)
				{
					err = ERR_OBJNOTFOUND;
					break;
				}

				err = GetBlock(drive,*block,WRITE,&(*buff));
				if (err != ERR_OKAY)
					break;

				/* Make sure we have a valid dir or file header */
				if (((*buff)->file.id != ID_FILE) && ((*buff)->dir.id != ID_DIR))
				{
					err = ERR_OBJNOTFOUND;
					break;
				}

				hold = *termptr;
				*termptr = 0;					// Temporarily null-terminate
				same = CompareStrings((*buff)->file.name,token);
				*termptr = hold;				// Restore
				if (same)
					break;

				*linkblk = *block;					// Place to find link to this
				*block = (*buff)->file.nexthash;	// Try next file in hash chain
				*linkhash = -1;						// Show is an extension, not child

				FreeBlock(&(*buff));
			}
		}

		/* If more to pathname, prepare to descend to next level */
		if ((err == ERR_OKAY) && (*name != 0))
		{
			if ((*buff)->dir.type == TYPE_FILE)
				err = ERR_WRONGTYPE;
			else
				err = ERR_OKAY;
		}

		if (err != ERR_OKAY)
		{
			if (*buff != NULL)
				FreeBlock(&(*buff));

			//DBUG(print(DB_FILESYS,"Mom=%l,Link=%l,Hash=%w (err %b)\n",
				//*momblk,*linkblk,*linkhash,err);)
			return(err);
		}
	} while (*name != 0);

	/* --- (buff has the located header in it) --- */

	if ((*buff)->file.type == TYPE_ROOT)
	{
		*momblk = NIX;
		*linkblk= NIX;
		return(ERR_OKAY);
	}

	/* Found the specified (or implied) object, get real momptr and linkptr */
	*momblk = (*buff)->file.parent;	// Block of my parent directory

	*linkhash = CalcHash((*buff)->file.name);

	//DBUG(print(DB_FILESYS,"final name = %s (hash = %w)\n",
	//	(ULONG)&(*buff)->file.name,*linkhash);)

	*linkblk = *momblk;
	err = GetBlock(drive,*linkblk,READ,&buff2);
	if (err == ERR_OKAY)
	{
		longptr = &buff2->dir.entries[*linkhash];

		/* Search for child thru hash and any extensions */
		while ((*longptr != 0) && (*longptr != *block))
		{
			*linkblk	= *longptr;
			*linkhash	= -1;				// Show is an extension, not child
			FreeBlock(&buff2);
			err = GetBlock(drive,*linkblk,READ,&buff2);
			if (err != ERR_OKAY)
				return(err);

			longptr = &buff2->file.nexthash;
		}
		if (*longptr == 0)
			err = ERR_FSFAIL;			// FS link problem

		FreeBlock(&buff2);
	}

	//DBUG(print(DB_FILESYS,"Mom=%l,Link=%l,Hash=%w (err %b)\n",
	//	*momblk,*linkblk,*linkhash,err);)

	return(err);
}


/*
 *  Locate - Find named object on drive.  Returns object information and
 *				 creates a grip that points to object (leaves no buffs allocated)
 */
UBYTE FS_Locate(	UBYTE	drive,
						GRIP	*grip,
						UBYTE	access,
						char	*filename,
						GRIP	**newgrip,
						ULONG	*block)
{
	union FSBUFF	*buff;
	UBYTE	err;
	ULONG	blk,linkblk,mom;
	char	*name,*base;
	WORD	hash;

	//DBUG(print(DB_FILESYS,"Locate - drv:%b acc:%b grip:%l name:\"%s\"\n",
	//	drive,access,grip,filename);)

	/* Strip dev: off filename */
	name = StripDevName(filename);

	/* If no name specified, nothing to find - just copy input grip */
	if (*name == 0)
	{
		err = CopyGrip(drive,grip,&(*newgrip));
		if (err == ERR_OKAY)
			*block = (*newgrip)->g_header;

		return(err);
	}

	err = LocObj(drive,grip,filename,&base,&linkblk,&hash,&blk,&buff,&mom);
	if (err == ERR_OKAY)
	{
		if (buff->file.type == TYPE_FILE)
			*block = buff->file.start;
		else
			*block = blk;

		*newgrip = AllocGrip(drive);		// Need a grip
		if (*newgrip == NULL)
		{
			FreeBlock(&buff);
			return(ERR_NOMEM);
		}
		(*newgrip)->g_header = blk;
		(*newgrip)->g_type = buff->file.type;
		(*newgrip)->g_parent = buff->file.parent;

		//DBUG(print(DB_FILESYS,"(Grip loc:%l)",blk);)

		FreeBlock(&buff);

		return(ERR_OKAY);
	}
	else
	{
		return(ERR_OBJNOTFOUND);
	}
}


/*
 *  LookupHeader - Get clip start block from header "ID" (location)
 */
UBYTE LookupHeader(	UBYTE	drive,
							ULONG	ID,
							ULONG	*start)
{
	union FSBUFF	*buff;
	UBYTE	err;

	err = GetBlock(drive,ID,READ,&buff);
	if (err == ERR_OKAY)
	{
		*start = buff->file.start;
		FreeBlock(&buff);
	}
	return(err);
}


/*
 *  AllocGrip - Allocate a "grip" structure
 */
GRIP *AllocGrip(UBYTE drive)
{
	GRIP	*grip;

	grip = AllocMem(sizeof(GRIP));
	if (grip != NULL)
	{
		grip->g_magic			= GRIPMAGIC;
		grip->g_header			= 0;
		grip->g_parent			= 0;
		grip->g_drv				= drive;
		grip->g_type			= TYPE_NONE;
		grip->g_DL_blk			= 0;
		grip->g_DL_dir			= 0;
		grip->g_DL_link		= 0;
		grip->g_DL_hash		= -1;
		grip->g_DL_done		= FALSE;
		grip->g_opened			= FALSE;
		grip->g_startblk		= 0;
		grip->g_curpos			= 0;
		grip->g_curpos_ext	= 0;
		grip->g_filelen		= 0;
		grip->g_filelen_ext	= 0;
		grip->g_physlen		= 0;
		grip->g_physlen_ext	= 0;

		GripCount++;
	}
	else
	{
//		DBUG(print(DB_ALWAYS,"Alloc'd NULL Grip!\n");)
	}

	//DBUG(print(DB_FILESYS,"AllocGrip - drv:%b grip:%l (%l now)\n",
	//	drive,grip,GripCount);)

	return(grip);
}


/*
 *  FreeGrip - Free a previously obtained grip on drive
 */
UBYTE FreeGrip(UBYTE	drive, GRIP *grip)
{
	if (grip != NULL)
	{
		if (grip == &RootGrip)							// Don't free this!
		{
			//DBUG(print(DB_FILESYS,"Not a valid grip!!\n");)
		}
		else if (grip->g_magic != GRIPMAGIC)		// Not a real grip, or already freed?
		{
			//DBUG(print(DB_FILESYS,"Not a valid grip!!\n");)
		}
		else
		{
			grip->g_magic = 0;
			FreeMem(grip,sizeof(GRIP));
			GripCount--;
		}
	}

	//DBUG(print(DB_FILESYS,"FreeGrip - drv:%b grip:%l (%l now)\n",
	//drive,grip,GripCount);)

	return(ERR_OKAY);
}


/*
 *  FindFreeList - Locate start of FreeList area on requested drive
 */
static UBYTE FindFreeList(	UBYTE	drive,
									ULONG	*mapstart)
{
	union FSBUFF	*buff;
	UBYTE	err;

	err = FormatCheck(drive);			// Drive formatted?
	if (err == ERR_OKAY)
	{
		err = GetBlock(drive,RootGrip.g_header,READ,&buff);
		if (err == ERR_OKAY)
		{
			*mapstart = buff->root.freelist;
			FreeBlock(&buff);
		}
	}
	return(err);
}


/*
 *  FindHeadList - Locate start of HeadList area on requested drive
 *			'Type' specifies master list (0) or new heads list (1)
 */
UBYTE FS_FindHeadList(	UBYTE	drive,
								UBYTE	type,
								ULONG	*headstart)
{
	union FSBUFF	*buff;
	UBYTE	err;

	err = FormatCheck(drive);			// Drive formatted?
	if (err == ERR_OKAY)
	{
		err = GetBlock(drive,RootGrip.g_header,READ,&buff);
		if (err == ERR_OKAY)
		{
			if (type == 0)
				*headstart = buff->root.headlist;
			else
				*headstart = buff->root.newheadlist;

			FreeBlock(&buff);
		}
	}
	return(err);
}


/*
 *  FindPatchArea - Locate start of patch area on requested drive
 */
UBYTE FindPatchArea(UBYTE drive, ULONG *start)
{
	union FSBUFF	*buff;
	UBYTE	err;

	err = FormatCheck(drive);			// Drive formatted?
	if (err == ERR_OKAY)
	{
		err = GetBlock(drive,RootGrip.g_header,READ,&buff);
		if (err == ERR_OKAY)
		{
			*start = buff->root.videoend;
			FreeBlock(&buff);
		}
	}
	return(err);
}


//UBYTE InitMapList(LISTCTRL	ctrl, UBYTE	drive)
//{
//	UBYTE	err;
//	ULONG	mapstart;
//
//	err = FindFreeList(drive,&mapstart);
//	if (err != ERR_OKAY)
//		return(err);
//
//	InitList(ctrl,drive,mapstart,MAPENTRIES,sizeof(struct MAPENTRY));
//
//	return(ERR_OKAY);
//}


/*
 *  GetFreeSpace - Get a range of free blocks on specified drive of at least
 *						 the requested size (0 for biggest contiguous chunk)
 */
UBYTE GetFreeSpace(	UBYTE	drive,
							ULONG	size,
							BOOL	last,
							ULONG	*start,
							ULONG	*end)
{
	struct LISTCTRLSTRUCT	ctrl;
	struct MAPENTRY			*ent;
	UBYTE	err;
	ULONG	bestlen,maparea;
	BOOL	gotone;

	err = FindFreeList(drive,&maparea);
	if (err != ERR_OKAY)
		return(err);

	if (size==0)
		bestlen = 0;
	else
		bestlen = 0xFFFFFFFF;

	*start = 0;
	*end	= 0;
	gotone= FALSE;

	InitList(&ctrl,drive,maparea,MAPENTRIES,sizeof(struct MAPENTRY));

	while ((err = NextNode(&ctrl,(APTR *)&ent)) == ERR_OKAY)
	{
		if (ent->me_Block == LISTEND)
		{
			//DBUG(print(DB_FILESYS,"GetFreeSpace choice: start:%l len:%l\n",
			//*start,bestlen);)

			err = ERR_OKAY;
			break;
		}

		if (size==0)			// Find biggest
		{
			if (ent->me_Length > bestlen)
			{
				gotone = TRUE;
				bestlen = ent->me_Length;
				*start = ent->me_Block;
				*end	= ent->me_Block + ent->me_Length;
			}
		}
		else
		{
			if (ent->me_Length >= size)		// Qualifies?
			{
				/* Keep best (if 'last' true, just find last one) */
				if ((ent->me_Length < bestlen) || (last))
				{
					gotone = TRUE;
					bestlen = ent->me_Length;
					*start = ent->me_Block;
					*end	= ent->me_Block + ent->me_Length;
				}
			}
		}
	}

	FreeList(&ctrl);

	if ((err == ERR_OKAY) && (! gotone))
		err = ERR_FULL;

	return(err);
}


/*
 *  GetExtendSpace - Report how far a file can be extended (remove from list)
 */
ULONG GetExtendSpace(UBYTE	drive,
							ULONG	next)
{
	struct LISTCTRLSTRUCT	ctrl;
	struct MAPENTRY			*ent;
	UBYTE	err;
	ULONG	maplist,count;

	count = 0;

	err = FindFreeList(drive,&maplist);
	if (err != ERR_OKAY)
		return(count);

	InitList(&ctrl,drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY));

	while ((err = NextNode(&ctrl,(APTR *)&ent)) == ERR_OKAY)
	{
		if (ent->me_Block == LISTEND)
			break;

		if (ent->me_Block == next)
		{
			count = ent->me_Length;
			break;
		}
	}

	FreeList(&ctrl);

	//DBUG(print(DB_FILESYS,"Can extend from blk %l for %l blocks\n",
	//	next,count);)

	/* Now remove area so that no one else jumps in and takes it */
	err = SubRange(drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY),next,count);
	if (err != ERR_OKAY)
		count = 0;			// Cannot have it if couldn't remove it

	return(count);
}


/*
 * AllocSpace - Allocate space from a drive's freelist
 */
UBYTE AllocSpace(	UBYTE	drive,
						ULONG	start,
						ULONG	length)
{
	ULONG	maplist;
	UBYTE	err;

	err = FindFreeList(drive,&maplist);
	if (err == ERR_OKAY)
	{
		err = SubRange(drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY),
			start,length);
	}

	return(err);
}


/*
 * FreeUpSpace - Free space back to a drive's freelist
 */
UBYTE FreeUpSpace(UBYTE	drive,
						ULONG	start,
						ULONG	length)
{
	ULONG	maplist;
	UBYTE	err;

	err = FindFreeList(drive,&maplist);
	if (err == ERR_OKAY)
	{
		err = AddRange(drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY),
			start,length);
	}

	return(err);
}


/*
 *  GetMapStats - Get information about a drive's freelist
 */
UBYTE FS_GetMapStats(UBYTE	drive,
							ULONG	*biglen,
							ULONG	*total)
{
	UBYTE	err;
	struct LISTCTRLSTRUCT	ctrl;
	struct MAPENTRY			*ent;
	ULONG	maparea;

	*biglen = 0;
	*total = 0;

	err = FindFreeList(drive,&maparea);
	if (err != ERR_OKAY)
		return(err);

	InitList(&ctrl,drive,maparea,MAPENTRIES,sizeof(struct MAPENTRY));

	while ((err = NextNode(&ctrl,(APTR *)&ent)) == ERR_OKAY)
	{
		if (ent->me_Block == LISTEND)
		{
			err = ERR_OKAY;
			break;
		}

 		*total += ent->me_Length;

		if (ent->me_Length > *biglen)
			*biglen = ent->me_Length;
	}

	FreeList(&ctrl);

	return(err);
}


/*
 *  NewFile - Write file info to filesystem
 */
UBYTE NewFile(	UBYTE	drive,
					ULONG	start,
					ULONG	blocks,			// Number of blocks needed to contain (rounded up)
					GRIP	*grip,
					char	*filename,
					BOOL	killold,
					ULONG	fragbytes,		// Actual size of partial last block (0 if whole block)
					GRIP	**newgrip)
{
	union FSBUFF	*buff;
	UBYTE	err;
	WORD	hash;
	ULONG	linkblk,blk,hdrblk,maplist,mom;
	char	*basename;
	GRIP	*parentgrip;
	UWORD	attempt;


	//DBUG(print(DB_FILESYS,"NewFile - name:%s ",(ULONG)filename);
	//print(DB_FILESYS,"start:d%l blks:%l fragbytes:%l\n",
	//start,blocks,fragbytes);)

	parentgrip = grip;
	if (parentgrip == NULL)
		parentgrip = &RootGrip;

	for (attempt=0;attempt<=1;)			// Give up after 1 delete attempt
	{
		/* Make sure name does not exist */
		err = LocObj(drive,parentgrip,filename,&basename,&linkblk,&hash,&blk,&buff,&mom);
		if (err != ERR_OKAY)
			break;								// This is good

		//DBUG(print(DB_FILESYS,"NewFile already exists!");)

		FreeBlock(&buff);

		if (killold)
		{
			err = Delete(drive,parentgrip,filename);
			attempt++;							// Try again
		}
		else
			return(ERR_EXISTS);
	}

	if ((err == ERR_OBJNOTFOUND) && (basename == NULL))
		return(ERR_OBJNOTFOUND);			// Couldn't find path leading to name

	if (err != ERR_OBJNOTFOUND)
		return(err);

	err = FindFreeList(drive,&maplist);
	if (err != ERR_OKAY)
		return(err);

	/* Look for an unused header block */
	err = GetFreeHdrBlock(drive,&hdrblk,&buff);
	if (err != ERR_OKAY)
		return(err);

	*newgrip = AllocGrip(drive);
	if (*newgrip == NULL)
	{
		FreeBlock(&buff);
		return(ERR_NOMEM);
	}

	(*newgrip)->g_type = TYPE_FILE;
	(*newgrip)->g_header = hdrblk;
	(*newgrip)->g_parent = mom;
	(*newgrip)->g_startblk = start;
	/* improved to handle double-longs!!! */
	Blocks2ExtBytes(blocks, &((*newgrip)->g_physlen_ext), &((*newgrip)->g_physlen) );
	if (fragbytes == 0)
	{
		Blocks2ExtBytes(blocks, &((*newgrip)->g_filelen_ext), &((*newgrip)->g_filelen) );
	}
	else
	{
		Blocks2ExtBytes(blocks-1, &((*newgrip)->g_filelen_ext), &((*newgrip)->g_filelen) );
		Add64( 0L, fragbytes, &((*newgrip)->g_filelen_ext), &((*newgrip)->g_filelen) );
	}

	(*newgrip)->g_curpos = 0;
	(*newgrip)->g_curpos_ext = 0;

	buff->file.id = ID_FILE;
	buff->file.nexthash = 0;				// No others after me at same hash
	buff->file.parent = mom;
	CopyString(basename,buff->file.name,FILENAMELENGTH);

	//DBUG(print(DB_FILESYS,"(hash = %w)",hash);)

	buff->file.comment[0] = 0;
	buff->file.type = TYPE_FILE;
	buff->file.start = start;
//	buff->file.key = start;

	/* Improved to handle double-longs! */
	buff->file.bytes_hi = (*newgrip)->g_filelen_ext;
	buff->file.bytes = (*newgrip)->g_filelen;

//	DBUG(print(DB_TEST,"Newfile: blks = %l(.%l), bytes = %l,%l\n",
//		blocks,fragbytes,buff->file.bytes_hi,buff->file.bytes);)

	GetDateStamp(&buff->file.date);		// Get date/time right now

	buff->file.bits = 0;
	buff->file.checksum = 0;

	/* Write out the file header */
	err = PutBlock(buff);
	FreeBlock(&buff);
	if (err != ERR_OKAY)
		return(err);

	/* Now link into filesystem */
	err = LinkOnChain(drive,hdrblk,linkblk,hash);

	ChangeDate(drive,mom);					// Update date on my parent

	/* Now remove area used from drive's FreeList */
	err = SubRange(drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY),
		start,blocks);
	/* NOTE: May return ERR_NOTINRANGE if allocating space for a clip
	that is owned by another clip, such as the destructive cutting room
	function.  Interpreting this as fatal or not is left to the caller */

	return(err);
}


/*
 * LinkOnChain - Link a new header into an existing one
 */
UBYTE LinkOnChain(UBYTE	drive,
						ULONG	hdrblk,
						ULONG	linkblk,
						WORD	hash)
{
	union FSBUFF	*buff;
	UBYTE	err;

	/* Read in the block we need to link to */
	err = GetBlock(drive,linkblk,WRITE,&buff);
	if (err != ERR_OKAY)
		return(err);

	if (hash == -1)
		buff->file.nexthash = hdrblk;				// I'm an extension
	else
		buff->dir.entries[hash] = hdrblk;		// I'm a child

	/* Write block back out */
	err = PutBlock(buff);
	FreeBlock(&buff);
	return(err);
}


/*
 *  DirTree - Call supplied routine for every file/dir on drive.  Routine
 *				  gets passed a pointer to a ClipInfo structure which contains
 *				  information about the next file/dir.  Also, the supplied
 *				  'custom' address is passed to the routine.  This may be used
 *				  to share a structure of variables for the caller and the handler
 *				  routine.  The handler routine should return ERR_OKAY -- if
 *				  anything else is returned, DirTree will abort before stepping
 *				  thru the entire drive tree (and will return the error to the
 *				  caller routine).  DirTree will return ERR_OKAY when done
 *				  (unless an error occurred).
 */
UBYTE DirTree(	UBYTE	drive,
					TREEROUT	routine,
					APTR	custom)
{
	UBYTE	err;
	GRIP	*grip;

	/* Make sure this volume is formatted before going thru tree! */
	err = FormatCheck(drive);
	if (err != ERR_OKAY)
		return(err);

	err = CopyGrip(drive,(GRIP *)0,&grip);		// Need a grip
	if (err != ERR_OKAY)
		return(err);

	//DBUG(print(DB_FILESYS,"At Root (start grip=%l)\n",grip);)

	err = DirWalk(drive,grip,routine,custom);

	FreeGrip(drive,grip);

	return(err);
}


/*
 *  DirWalk - Perform the DirTree function at one directory level
 *            Recurses for sub-directories found
 */
static UBYTE DirWalk(	UBYTE	drive,
								GRIP *grip,
								TREEROUT	routine,
								APTR	custom)
{
	UBYTE	err;
	GRIP	*newgrip;
	struct ClipInfo	ObjInf;

	//DBUG(print(DB_FILESYS,"***Dir (grip=%l)",grip);)

	ObjInf.len = sizeof(struct ClipInfo);
	err = DirList(drive,grip,&ObjInf,1,TRUE);			// Get info on Directory
	if (err == ERR_OKAY)
	{
		do
		{
			//DBUG(print(DB_FILESYS,"\n   Child ");)

			ObjInf.len = sizeof(struct ClipInfo);
			err = DirList(drive,grip,&ObjInf,0,TRUE);	// Get info on next item in dir
			if (err == ERR_OKAY)
			{
				//DBUG(print(DB_FILESYS," FUNC ");)

				/* Call User Routine, pass drive,ObjInf ptr,GRIP *,user addr */
				err = routine(drive,&ObjInf,grip,custom);
				//DBUG(print(DB_FILESYS," (err=%b) ",err);)
				if (err == ERR_OKAY)
				{
					if (ObjInf.Type == TYPE_DIR)	// A sub-dir, descend into it!
					{
						//DBUG(print(DB_FILESYS,"SubDir '%s' ",(ULONG)&ObjInf.Name);)

						// Get a grip on the sub-directory
						err = FS_Locate(drive,grip,ACCESS_SHARED,ObjInf.Name,&newgrip,&ObjInf.Start);
						if (err==ERR_OKAY)
						{
							//DBUG(print(DB_FILESYS," (newgrip=%l) ",newgrip);)
							err = DirWalk(drive,newgrip,routine,custom);
							FreeGrip(drive,newgrip);
						}
					}
				}
			}
			else if (err == ERR_EXHAUSTED)		// Done at this level?
			{
				err = ERR_OKAY;					// This is not cause for panic
				break;
			}
		} while (err==ERR_OKAY);
	}

	//DBUG(print(DB_FILESYS,"ERR=%b\n",err);)

	return(err);
}


/*
 *  DirList - List directory contents (one by one)
 */
UBYTE DirList(	UBYTE	drive,
					GRIP	*grip,
					struct ClipInfo *ptr,
					UBYTE	first,
					BOOL	extra)
{
	struct ClipInfo	*obj;
	union FSBUFF		*buff;
	UBYTE	err;
//	UWORD	entry;

	//DBUG(print(DB_FILESYS,"DirList - drv:%b grip:%l first:%b\n",
	//		drive,(ULONG)grip,first);)

	obj = (struct ClipInfo *)ptr;

	if (grip == NULL)
		grip = &RootGrip;			// Grip on directory to list

	if (first != 0)
	{
		/* Make sure drive is formatted before diving into it! */
		err = FormatCheck(drive);
		if (err != ERR_OKAY)
			return(err);

		grip->g_DL_done= FALSE;
		grip->g_DL_dir = grip->g_header;		// Start on my header
		grip->g_DL_hash = -1;					// Ready for hash 0
		grip->g_DL_link = 0;						// Not on a hash chain

		/* Read in header of interest */
		err = GetBlock(drive,grip->g_header,READ,&buff);
		if (err != ERR_OKAY)
			return(err);

		if (grip->g_type == TYPE_FILE)		// Lock on file
			err = Hdr2ClipInfo(drive,buff,obj,extra);
		else										// Lock on root/dir
		{
			/* Copy name */
			CopyString(buff->dir.name,obj->Name,CINAMELENGTH);
			if (grip->g_type == TYPE_ROOT)
				CopyString("Flyer drive",obj->Comment,CICOMMENTLENGTH);
			else
				obj->Comment[0] = 0;

			obj->Type = buff->dir.type;

			/* Copy date */
			CopyMem(&buff->dir.date,&obj->Date,sizeof(struct FlyerDate));

			obj->Bits = 0;
			obj->Fields = 0;
			obj->Start = 0;
			obj->Length = 0;
			obj->IndexBlk = 0;
			obj->EndBlk = 0;
		}

		FreeBlock(&buff);

		return(ERR_OKAY);
	}

	if (grip->g_DL_done)
		return(ERR_EXHAUSTED);

 	/* If out on a hash chain, continue til dead-ends */
	if (grip->g_DL_link != 0)
		grip->g_DL_blk = grip->g_DL_link;
	else
	{
		/* Scan thru entries in directory */
		err = GetBlock(drive,grip->g_DL_dir,READ,&buff);
		if (err != ERR_OKAY)
			return(err);

		do
		{
			grip->g_DL_hash++;
			/* Exhausted this directory list? */
			if (grip->g_DL_hash >= DIRENTRIES)
			{
				grip->g_DL_done = TRUE;
				FreeBlock(&buff);
				return(ERR_EXHAUSTED);
			}
		} while (buff->dir.entries[grip->g_DL_hash] == 0);

		grip->g_DL_blk = buff->dir.entries[grip->g_DL_hash];
		FreeBlock(&buff);
	}

	err = GetBlock(drive,grip->g_DL_blk,READ,&buff);
	if (err != ERR_OKAY)
		return(err);

	grip->g_DL_link = buff->file.nexthash;		// Stay on hash chain

	err = Hdr2ClipInfo(drive,buff,obj,extra);	// Copy to user's structure
// Errors legal?

	FreeBlock(&buff);

	return(ERR_OKAY);
}


/*
 *  FileInfo - Return info on object
 */
UBYTE FileInfo(UBYTE	drive,
					GRIP	*grip,
					char	*name,
					struct ClipInfo *ptr)
{
	struct ClipInfo	*obj;
	union FSBUFF		*buff;
	UBYTE	err;
	ULONG	blk,linkblk,mom;
	WORD	hash;
	char	*base;

	//DBUG(print(DB_FILESYS,"FileInfo - drv:%b grip:%l name:%s\n",
	//	drive,(ULONG)grip,(ULONG)name);)

	err = LocObj(drive,grip,name,&base,&linkblk,&hash,&blk,&buff,&mom);
	if (err != ERR_OKAY)
		return(err);

	obj = (struct ClipInfo *)ptr;
	err = Hdr2ClipInfo(drive,buff,obj,TRUE);			// Copy to user's structure
// Do what with error?  Errors legal?

	FreeBlock(&buff);

	return(ERR_OKAY);
}


/*
 *  CreateDir - Create a sub-directory
 */
UBYTE CreateDir(	UBYTE	drive,
						GRIP	*grip,
						char	*filename,
						GRIP	**newgrip)
{
	union FSBUFF	*buff;
	UBYTE	err;
	WORD	hash;
	ULONG	linkblk,blk,hdrblk,mom;
	char	*basename;
	GRIP	*parentgrip;
	UWORD	i;

	//DBUG(print(DB_FILESYS,"CreateDir - grip:%l name:%s ",(ULONG)grip,
	//	(ULONG)filename);)

	parentgrip = grip;
	if (parentgrip == NULL)
		parentgrip = &RootGrip;

	/* Make sure name does not exist */
	err = LocObj(drive,parentgrip,filename,&basename,&linkblk,&hash,&blk,&buff,&mom);
	if (err == ERR_OKAY)
	{
		//DBUG(print(DB_FILESYS,"CreateDir already exists!");)

		FreeBlock(&buff);
		return(ERR_EXISTS);
	}
	else if ((err == ERR_OBJNOTFOUND) && (basename == NULL))
		return(ERR_OBJNOTFOUND);		// Couldn't find path leading to name

	if (err != ERR_OBJNOTFOUND)
		return(err);

	/* Look for an unused header block */
	err = GetFreeHdrBlock(drive,&hdrblk,&buff);
	if (err != ERR_OKAY)
		return(err);

	*newgrip = AllocGrip(drive);
	if (*newgrip == NULL)
	{
		FreeBlock(&buff);
		return(ERR_NOMEM);
	}

	(*newgrip)->g_type = TYPE_DIR;
	(*newgrip)->g_header = hdrblk;
	(*newgrip)->g_parent = mom;
	(*newgrip)->g_startblk = 0;
	(*newgrip)->g_physlen = 0;
	(*newgrip)->g_physlen_ext = 0;
	(*newgrip)->g_filelen = 0;
	(*newgrip)->g_filelen_ext = 0;
	(*newgrip)->g_curpos = 0;
	(*newgrip)->g_curpos_ext = 0;

	buff->dir.id = ID_DIR;
	buff->dir.nexthash = 0;					// No others after me at same hash
	buff->dir.parent = mom;
	CopyString(basename,buff->dir.name,DIRNAMELENGTH);

	//DBUG(print(DB_FILESYS,"(hash = %w)",hash);)

	buff->dir.comment[0] = 0;
	buff->dir.flags = 0;
	buff->dir.type = TYPE_DIR;

	GetDateStamp(&buff->dir.date);		// Get date/time right now

	buff->dir.bits = 0;
	buff->dir.checksum = 0;

	for (i=0;i<DIRENTRIES;i++)
	{
		buff->dir.entries[i] = 0;
	}

	/* Write out the file header */
	err = PutBlock(buff);
	FreeBlock(&buff);
	if (err != ERR_OKAY)
		return(err);

	/* Now link into filesystem */
	err = LinkOnChain(drive,hdrblk,linkblk,hash);

	ChangeDate(drive,mom);		// Update date on my parent

	return(err);
}


/*
 *  Delete - Delete a file
 */
UBYTE Delete(	UBYTE	drive,
					GRIP	*grip,
					char	*filename)
{
	union FSBUFF	*buff;
	UBYTE	err,type;
	ULONG	blk,linkblk,hashchain,start,length,mom;
	WORD	hash;
	UWORD	i;
	char	*base;

	//DBUG(print(DB_FILESYS,"Delete - %s",filename);)

	/* Find object to delete */
	err = LocObj(drive,grip,filename,&base,&linkblk,&hash,&blk,&buff,&mom);
	if (err != ERR_OKAY)
		return(err);

	/* Make sure any heads that belong to this clip get deleted before we	*/
	/* throw the clip itself away!  Otherwise, we would have orphan heads	*/
	/* that would never get cleaned up.													*/
	KillFilesHeads(drive,blk);

	type = buff->file.type;

	/* Protected from deletion? */
	if (AMIPROT_DELETE & buff->file.bits)
	{
		FreeBlock(&buff);
		return(ERR_DELPROT);
	}

	if (type == TYPE_DIR)
	{
		/* Dirs: make sure it has no children before deleting */
		for (i=0;i<DIRENTRIES;i++)
		{
			if (buff->dir.entries[i] != 0)
			{
				FreeBlock(&buff);
				return(ERR_DIRNOTEMPTY);
			}
		}
	}
	else
	{
		/* Files: get info */
		start = buff->file.start;

		/* Improved to handle double-longs! */
		length = ExtBytes2Blocks(buff->file.bytes_hi,buff->file.bytes);

		//DBUG(print(DB_FILESYS,"start:%l len:%l\n",start,length);)
	}

	/* Get info and trash header */
	hashchain = buff->file.nexthash;
	buff->file.id = 0;

	err = PutBlock(buff);
	FreeBlock(&buff);
	if (err != ERR_OKAY)
		return(err);

	/* Unlink from directory */
	err = GetBlock(drive,linkblk,WRITE,&buff);
	if (err != ERR_OKAY)
		return(err);

	if (hash == -1)
		buff->file.nexthash = hashchain;			// I was an extension
	else
		buff->dir.entries[hash] = hashchain;	// I was a child

	err = PutBlock(buff);
	FreeBlock(&buff);
	if (err != ERR_OKAY)
		return(err);

	/* Files: return blocks to freelist */
	if (type == TYPE_FILE)
		err = FreeUpSpace(drive,start,length);

	ChangeDate(drive,mom);							// Update date on my parent

	return(err);
}


/*
 *  CopyGrip - Clone a previously obtained grip
 */
UBYTE CopyGrip(UBYTE	drive,
					GRIP	*grip,
					GRIP	**newgrip)
{
	UBYTE	res;
	GRIP	*mygrip;

	if (grip == NULL)
		grip = &RootGrip;

	*newgrip = mygrip = AllocGrip(drive);
	if (mygrip == NULL)
	{
		//DBUG(print(DB_ALWAYS,"Copied NULL Grip!\n");)
		res = ERR_NOMEM;
	}
	else
	{
		mygrip->g_header	= grip->g_header;
		mygrip->g_parent	= grip->g_parent;
		mygrip->g_type	= grip->g_type;
		res = ERR_OKAY;
	}

	//DBUG(print(DB_FILESYS,"CopyGrip - drv:%b grip:%l newgrip:%l\n",
	//	drive,(ULONG)grip,(ULONG)mygrip);)

	return(res);
}


/*
 *  FileOpen - Find and open a file for reading/writing
 */
UBYTE FileOpen(UBYTE	drive,
					GRIP	*grip,
					char	*filename,
					UBYTE	mode,
					APTR	*fileid,
					ULONG	*theblock)
{
	union FSBUFF	*buff;
	GRIP	*newgrip;
	UBYTE	err;
	ULONG	block,freespot,endspot;
	char	*name;

	/* Strip dev: off filename */
	name = StripDevName(filename);
	//DBUG(print(DB_FILESYS,"Starting Filesys:FileOpen\n");)

	if ((mode == MODE_INPUT) || (mode == MODE_UPDATE))
	{
		err = FS_Locate(drive,grip,ACCESS_SHARED,filename,&newgrip,&block);
		if (err == ERR_OKAY)
		{
			*theblock = block;

			if (newgrip->g_type != TYPE_FILE)
			{
				FreeGrip(drive,newgrip);
				err = ERR_WRONGTYPE;
			}
			else
			{
				err = GetBlock(drive,newgrip->g_header,READ,&buff);
				if (err == ERR_OKAY)
				{
					newgrip->g_opened = TRUE;
					newgrip->g_startblk = block;
					newgrip->g_curpos = 0;
					newgrip->g_curpos_ext = 0;
					newgrip->g_filelen = buff->file.bytes;
					newgrip->g_filelen_ext = buff->file.bytes_hi;
					newgrip->g_protbits= buff->file.bits;

					/* Improved to handle double-longs!!! */
					Blocks2ExtBytes(  ExtBytes2Blocks(  newgrip->g_filelen_ext, 
																	newgrip->g_filelen ), 
											&(newgrip->g_physlen_ext), 
											&(newgrip->g_physlen) );
					DBUG(print(DB_FILESYS,"Grip.g_filelen: %l, Grip.g_filelen_ext: %l\n", newgrip->g_filelen, newgrip->g_filelen_ext);)
					DBUG(print(DB_FILESYS,"Grip.g_physlen: %l, Grip.g_physlen_ext: %l\n", newgrip->g_physlen, newgrip->g_physlen_ext);)
					DBUG(print(DB_FILESYS,"Grip.g_curpos: %l, Grip.g_curpos_ext: %l\n", newgrip->g_curpos, newgrip->g_curpos_ext);)
					FreeBlock(&buff);
				}
			}
		}
	}

	if (mode == MODE_OUTPUT)
	{
		err = Delete(drive,grip,name);		// Delete file if it exists
	}

	if ((mode == MODE_OUTPUT)
	|| ((mode == MODE_UPDATE) && (err == ERR_OBJNOTFOUND)))
	{
		err = GetFreeSpace(drive,0,FALSE,&freespot,&endspot);
		if (err == ERR_OKAY)
		{
			*theblock = freespot;

			/* Create an empty data file */
			err = NewFile(drive,freespot,0,grip,name,FALSE,0,&newgrip);
			if (err == ERR_OKAY)
			{
				newgrip->g_opened = TRUE;
				newgrip->g_protbits = 0;
			}
		}
	}

	*fileid = newgrip;

	DBUG(print(DB_FILESYS,"err:%b FileID:%l\n",err,(ULONG)*fileid);)
	DBUG(print(DB_FILESYS,"Finished Filesys:FileOpen\n");)

	return(err);
}


/*
 *  FileClose - Close a file
 */
UBYTE FileClose(UBYTE drive, APTR fileid)
{
	UBYTE	err;
	GRIP	*grip;

	DBUG(print(DB_FILESYS,"Close - drv:%b id:%l\n",drive,(ULONG)fileid);)

	grip = (GRIP *)fileid;

	grip->g_opened = FALSE;

	err = ERR_OKAY;

	return(err);
}


/*
 *  FileRead - Read data from file
 */
UBYTE FileRead(UBYTE	drive,
					APTR	fileid,
					ULONG	length,
					UBYTE	*buffer,
					ULONG	*actual)
{
	union FSBUFF	*databuff;
	GRIP	*grip;
	ULONG	left,blk,offset,size,total,oldpos, oldpos_ext;
	UBYTE	err;
	ULONG temp64_hi, temp64_lo;

	DBUG(print(DB_FILESYS,"Read - drv:%b id:%l buff:%l len:%l\n",
		drive,(ULONG)fileid,(ULONG)buffer,length);)

	grip	= fileid;

	if ((grip == NULL) || (! grip->g_opened))
		return(ERR_OBJNOTFOUND);

	if (AMIPROT_READ & grip->g_protbits)
		return(ERR_READPROT);

	databuff = AllocSRAM(1);			// Get a block of memory
	if (databuff == NULL)
		return(ERR_NOMEM);

	left	= length;
	total	= 0;
	err	= ERR_OKAY;
	oldpos = grip->g_curpos;
	oldpos_ext = grip->g_curpos_ext;

	while (left)
	{
		DBUG(print(DB_FILESYS,">>>curpos:%l curpos_ext:%l\nfilelen:%l filelen_ext:%l\nleft:%l total:%l\n",
			grip->g_curpos,grip->g_curpos_ext,grip->g_filelen,grip->g_filelen_ext,left,total);)

		if ( (grip->g_curpos >= grip->g_filelen) && ( grip->g_curpos_ext >= grip->g_filelen_ext ) )
			break;
		
		/* Improved to handle double Longs */
		blk = grip->g_startblk + ExtBytes2Blocks( grip->g_curpos_ext, grip->g_curpos );
		DBUG(print(DB_FILESYS,"reading block:%l\n",blk);)
		offset = (UWORD)(grip->g_curpos & 511);
		size = 512 - offset;

		/* Don't read more than requested */
		if (size > left)
			size = left;
		
		temp64_hi = grip->g_curpos_ext;
		temp64_lo = grip->g_curpos;
		Add64( 0L, size, &temp64_hi, &temp64_lo );

		/* Don't read past end of file */
		if ( ( temp64_lo > grip->g_filelen ) && ( temp64_hi >= grip->g_filelen_ext ) )
		{
			DBUG(print(DB_FILESYS,"Size %l changed to %l\n",
				size,grip->g_filelen-grip->g_curpos);)
			temp64_hi = grip->g_filelen_ext;
			size = grip->g_filelen;
			Sub64( grip->g_curpos_ext, grip->g_curpos, &temp64_hi, &size );
		}

		DBUG(printchar(DB_FILESYS,'!');)

		DBUG(print(DB_FILESYS,"Reading Blk: %l into databuff: %l \n",blk,databuff);)

		// DEH.032697.needs more testing Todd's 64bit hhack is causing 
		// Block numbers to inc too soon. Partial block reads read wrong block.
		if(offset)
			blk--;

		err = ReadBlock(drive,blk,databuff);
		if (err != ERR_OKAY)
			break;

		DBUG(print(DB_FILESYS,"Doing Copy mem offset: %l size: %l \n",offset,size);)

		CopyMem((APTR)(offset+(ULONG)databuff),(APTR)buffer,size);

		left -= size;
		buffer += size;
		total += size;
		Add64( 0L, size, &(grip->g_curpos_ext), &(grip->g_curpos) );
		DBUG(print(DB_FILESYS,"new curpos:%l curpos_ext:%l\n",grip->g_curpos, grip->g_curpos_ext);)
	}

	*actual = total;

	DBUG(print(DB_FILESYS,"[err:%b actual:%l]\n",err,*actual);)

	/* Restore original pointer on failure */
	if (err != ERR_OKAY)
	{
		grip->g_curpos = oldpos;
		grip->g_curpos_ext = oldpos_ext;
		DBUG(print(DB_FILESYS,"restored old curpos:%l curpos_ext:%l\n",grip->g_curpos, grip->g_curpos_ext);)
	}

	FreeSRAM(databuff,1);			// Free this resource back up

	return(err);
}


/*
 *  FileWrite - Write data to file
 */
UBYTE FileWrite(	UBYTE	drive,
						APTR	fileid,
						ULONG	length,
						UBYTE	*buffer,
						ULONG	*actual)
{
	union FSBUFF	*databuff,*hdrbuff;
	GRIP	*grip;
	UBYTE	err;
	UWORD	offset,size;
	ULONG	left,blk,total,oldpos, oldpos_ext,newlen, newlen_ext,moreblks,firstnew,newcount,newmax;
	ULONG temp64_lo, temp64_hi,W_blk;

	DBUG(print(DB_FILESYS,"Write - drv:%b id:%l buff:%l len:%l\n",
		drive,(ULONG)fileid,(ULONG)buffer,length);)

	grip	= fileid;

	if ((grip == NULL) || (! grip->g_opened))
		return(ERR_OBJNOTFOUND);

	if (AMIPROT_WRITE & grip->g_protbits)
		return(ERR_WRITEPROT);

	databuff = AllocSRAM(1);			// Get a block of memory
	if (databuff == NULL)
		return(ERR_NOMEM);

	/* Pre-fetch this file's header into RAM */
	err = GetBlock(drive,grip->g_header,WRITE,&hdrbuff);
	if (err != ERR_OKAY)
		return(err);

	/* How far can we extend this file */
	/* Needs improved to handle double-longs!!! */
	firstnew = grip->g_startblk + ExtBytes2Blocks( grip->g_physlen_ext, grip->g_physlen );
	DBUG(print(DB_FILESYS,"first new block:%l\n",firstnew);)
	newcount = 0;
	newmax = GetExtendSpace(drive,firstnew);
	DBUG(print(DB_FILESYS,"Available space:%l\n",newmax);)


	left	= length;
	total	= 0;
	err	= ERR_OKAY;
	oldpos= grip->g_curpos;
	oldpos_ext = grip->g_curpos_ext;

	while (left != 0)
	{
		
		// ExtBytes2Blocks is returning 1 even if writing in the current block
		W_blk = ExtBytes2Blocks( grip->g_curpos_ext, grip->g_curpos );
		blk=W_blk;

		blk = grip->g_startblk +  W_blk;

		DBUG(print(DB_FILESYS,"Current Blk: %l More?: %l \n",blk,ExtBytes2Blocks( grip->g_curpos_ext, grip->g_curpos ));)

		offset = (UWORD)(grip->g_curpos & 511);
		size = 512 - offset;

		/* Write no more than requested */
		if (size > left)
			size = left;

		temp64_hi = grip->g_curpos_ext;
		temp64_lo = grip->g_curpos;

		Add64( 0L, size, &temp64_hi, &temp64_lo );

		if ( ( temp64_lo > grip->g_filelen ) && ( temp64_hi >= grip->g_filelen_ext ) )
		{
			newlen = temp64_lo;
			newlen_ext = temp64_hi;
		}
		else
		{
			newlen = grip->g_filelen;
			newlen_ext = grip->g_filelen_ext;
			DBUG(print(DB_FILESYS,"file will be not be extended\n");)
		}

		/* Need to physically extend file? */
		if ( (newlen > grip->g_physlen) && ( newlen_ext >= grip->g_physlen_ext ) )
		{
			/* Improved to handle double-longs!!! */
			temp64_hi = newlen_ext;
			temp64_lo = newlen;
			DBUG(print(DB_FILESYS,"Current values: temp64_hi:%l temp64_lo:%l\n physlen_ext:%l physlen:%l\n",
										temp64_hi, temp64_lo, grip->g_physlen_ext, grip->g_physlen);)
			DBUG(print(DB_FILESYS,"Subtracting physlen from temp64...\n");)
			Sub64( grip->g_physlen_ext, grip->g_physlen, &temp64_hi, &temp64_lo ); 
			DBUG(print(DB_FILESYS,"Current values: temp64_hi:%l temp64_lo:%l\n  physlen_ext:%l physlen:%l\n",
										temp64_hi, temp64_lo, grip->g_physlen_ext, grip->g_physlen);)
			moreblks = ExtBytes2Blocks( temp64_hi, temp64_lo );
			DBUG(print(DB_FILESYS,"file must be extended by %l more blocks\n",moreblks);)

			/* Try to allocate the extra room we need */
			if ( ( newcount + moreblks ) <= newmax )
			{
				newcount += moreblks;
				DBUG(print(DB_FILESYS,"file will be extended by a total of %l blocks\n",newcount);)
			}
			else
			{
//	???		err = ERR_CANTEXTEND;		// Not extensible
				err = ERR_FULL;
				DBUG(print(DB_FILESYS,"file cannot be extended\n");)
				break;
			}

			/* Needs improved to handle double-longs!!! */
			Blocks2ExtBytes( moreblks, &temp64_hi, &temp64_lo );
			Add64( temp64_hi, temp64_lo, &( grip->g_physlen_ext ), &( grip->g_physlen ) );
			DBUG(print(DB_FILESYS,"Grip g_physlen_ext:%l g_physlen:%l\n",
					grip->g_physlen_ext, grip->g_physlen);)
		}

		/* Need to logically extend file? */
		if ( ( newlen > grip->g_filelen ) && ( newlen_ext >= grip->g_filelen_ext ) )
		{
			hdrbuff->file.bytes = newlen;
			hdrbuff->file.bytes_hi = newlen_ext;
			DBUG(print(DB_FILESYS,"File header changed to bytes:%l bytes_hi:%l\n",
					hdrbuff->file.bytes, hdrbuff->file.bytes_hi);)
			grip->g_filelen = newlen;
			grip->g_filelen_ext = newlen_ext;
			DBUG(print(DB_FILESYS,"grip changed to g_filelen:%l g_filelen_ext:%l\n",
					grip->g_filelen, grip->g_filelen_ext);)
		}

		//DBUG(printchar(DB_FILESYS,'!');)

		/* Only pre-read the block if not writing whole thing */
		if ((offset != 0) || (size != 512))
		{
			if((W_blk)&&(offset))
				blk--;

			DBUG(print(DB_FILESYS,"**************\nReading block: %l...\n**************\n",blk);)
			err = ReadBlock(drive,blk,databuff);
			if (err != ERR_OKAY)
				break;
		}

		/* (Over)write data */
		DBUG(print(DB_FILESYS,"Doing a CopyMem size %l  offset: %l\n",size,offset);)
		CopyMem((APTR)buffer,(APTR)(offset+(ULONG)databuff),size);


		DBUG(print(DB_FILESYS,"Writing blk: %l  databuff: %l\n",blk,databuff);)
		err = WriteBlock(drive,blk,databuff);
		if (err != ERR_OKAY)
			break;

		left -= size;
		buffer += size;
		total += size;
		Add64( 0L, size, &( grip->g_curpos_ext ), &( grip->g_curpos ) );
	}

	/* Now add back into FreeList any space we didn't use */
	if ( newmax > newcount )
	{
		err = FreeUpSpace( drive, firstnew + newcount, newmax - newcount );
		if (err != ERR_OKAY)
			return(err);
	}

	/* Flush header back to disk */
	err = PutBlock(hdrbuff);
	FreeBlock(&hdrbuff);
	if (err != ERR_OKAY)
		return(err);

	*actual = total;

	/* Restore original pointer on failure */
	if (err != ERR_OKAY)
	{
		grip->g_curpos = oldpos;
		grip->g_curpos_ext = oldpos_ext;
		DBUG(print(DB_FILESYS,"restored old curpos:%l curpos_ext:%l\n",grip->g_curpos, grip->g_curpos_ext);)
	}

	FreeSRAM(databuff,1);			// Free this resource back up

	return(err);
}


/*
 *  FileSeek - Seek to a file position
 */
UBYTE FileSeek(UBYTE	drive,
					APTR	fileid,
					UBYTE	mode,
					ULONG	newpos_ext,
					ULONG	newpos,
					ULONG	*oldpos_ext,
					ULONG	*oldpos)
{
	GRIP	*grip;
	ULONG	pos_ext, pos;

	DBUG(print(DB_FILESYS,"Seek - drv:%b id:%l mode:%b pos:%#8lx%8lx\n",
		drive,(ULONG)fileid,mode,newpos_ext, newpos);)

	grip	= fileid;

	if ((grip == NULL) || (! grip->g_opened))
	{	
		DBUG(print(DB_FILESYS,"Seek - Error: Object Not Found\n");)
		return(ERR_OBJNOTFOUND);
	}
	*oldpos = grip->g_curpos;
	*oldpos_ext = grip->g_curpos_ext;

	switch (mode)
	{
		case OFFSET_BEGIN:
DBUG(print(DB_FILESYS,"mode = OFFSET_BEGIN\n");)
			pos = newpos;
			pos_ext = newpos_ext;
DBUG(print(DB_FILESYS,"pos_ext = %l, pos = %l\n",pos_ext, pos);)
			break;
		case OFFSET_CURRENT:
DBUG(print(DB_FILESYS,"mode = OFFSET_CURRENT\n");)
			pos = grip->g_curpos;
			pos_ext = grip->g_curpos_ext;
DBUG(print(DB_FILESYS,"pos_ext = %l, pos = %l\n",pos_ext, pos);)
DBUG(print(DB_FILESYS,"newpos_ext = %l, newpos = %l\n",newpos_ext, newpos);)
DBUG(print(DB_FILESYS,"adding...\n");)
			Add64( newpos_ext, newpos, &pos_ext, &pos );
DBUG(print(DB_FILESYS,"result: pos_ext = %l, pos = %l\n",pos_ext, pos);)
			break;
		case OFFSET_END:
DBUG(print(DB_FILESYS,"mode = OFFSET_END\n");)
			pos = grip->g_filelen;
			pos_ext = grip->g_filelen_ext;
DBUG(print(DB_FILESYS,"pos_ext = %l, pos = %l\n",pos_ext, pos);)
DBUG(print(DB_FILESYS,"newpos_ext = %l, newpos = %l\n",newpos_ext, newpos);)
DBUG(print(DB_FILESYS,"adding...\n");)
			Add64( newpos_ext, newpos, &pos_ext, &pos );		
DBUG(print(DB_FILESYS,"result: pos_ext = %l, pos = %l\n",pos_ext, pos);)
			break;
		default:
DBUG(print(DB_FILESYS,"mode = ERR_BADPARAM\n");)
			return(ERR_BADPARAM);
	}
DBUG(print(DB_FILESYS,"Finished Switch.\n");)

	if ( ( pos > grip->g_filelen ) && ( pos_ext >= grip->g_filelen_ext ) )
	{
DBUG(print(DB_FILESYS,"pos_ext = %l, pos = %l\n",pos_ext, pos);)
DBUG(print(DB_FILESYS,"g_filelen_ext = %l, g_filelen = %l\n",grip->g_filelen_ext, grip->g_filelen);)
DBUG(print(DB_FILESYS,"pos > g_filelen && pos_ext >= g_filelen_ext. ERR_BADPARAM\n");)
		return(ERR_BADPARAM);
	}
	else
	{
		grip->g_curpos = pos;
		grip->g_curpos_ext = pos_ext;
DBUG(print(DB_FILESYS,"grip->g_curpos_ext = %l, grip->g_curpos = %l", grip->g_curpos_ext, grip->g_curpos);)

		return(ERR_OKAY);
	}
}


/*
 *  _DefragHandler_ - individual file handler for DeFrag
 */
static UBYTE _DefragHandler_(	UBYTE	drive,
										struct ClipInfo	*objinfo,
										GRIP	*grip,
										APTR	custom)
{
	struct DEFRAGDATA	*sptr;

	sptr = custom;

	if (objinfo->Type == TYPE_FILE)			// Process only files
	{
		DBUG(print(DB_FILESYS,"Clip:%l\n",objinfo->Start);)

		if ( ( objinfo->LengthExt == 0 ) && ( objinfo->Length == 0 ) )
		{
			// This file is of zero length and does not need to be considered or moved
			return(ERR_OKAY);
		}

		if (objinfo->Start == sptr->dd_spot)
		{
			DBUG(print(DB_FILESYS,"CONNECT! ");)

			sptr->dd_spot += ExtBytes2Blocks(objinfo->LengthExt,objinfo->Length);
// WOULDN'T THIS BE BETTER !!!
//			sptr->dd_spot += (objinfo->EndBlk-objinfo->Start);

			sptr->dd_restart = TRUE;
			return(ERR_ABORTED);			// Quit tree immediately!
		}
		else if (objinfo->Start > sptr->dd_spot)
		{
			if (objinfo->Start < sptr->dd_bestloc)
			{
				DBUG(print(DB_FILESYS,"BETTER ");)

				sptr->dd_bestloc = objinfo->Start;
				sptr->dd_besthdr = grip->g_DL_blk;
			}
		}
	}
	return(ERR_OKAY);						// Continue thru drive tree structure
}


/*
 *	DeFrag - Perform drive de-fragmentation
 */
UBYTE DeFrag(UBYTE drive, UBYTE *HostAbort)
{
	struct DEFRAGDATA	strct,*sptr;
	union FSBUFF	*buff;
	ULONG	diff,blks,maplist;
	UWORD	moves;
	UBYTE	error;

	// This is not so elegant, but it's an easy way to ensure that we don't
	// disassociate clip head data from the definitions on another drive.  Improve???
	CleanupHeads();		// This is fast, doesn't do rebuild surgery

	sptr = &strct; 

	/* Make sure this volume is formatted before trying to defrag! */
	error = FormatCheck(drive);				// Drive formatted?
	if (error == ERR_OKAY)
	{
		error = GetBlock(drive,RootGrip.g_header,READ,&buff);
		if (error == ERR_OKAY)
		{
			sptr->dd_spot = buff->root.dataarea;	// Start at beginning of drive
			maplist	= buff->root.freelist;			// Drive's free map list
			FreeBlock(&buff);
		}
	}
	if (error != ERR_OKAY)
		return(error);

	LockVideoRAM();			// Kill video for entirety of this session

	moves = 0;		// ???

	for (;;)
	{
		// Quit searching for more files to move?
		if ((HostAbort) && (*HostAbort == 0))
		{
			DBUG(print(DB_FILESYS,"Aborted!\n");)
			error = ERR_ABORTED;
			break;
		}

		DBUG(print(DB_FILESYS,"(New Spot:%l)",sptr->dd_spot);)

		sptr->dd_bestloc = 0xFFFFFFFF;
		sptr->dd_restart = FALSE;

		/* Go thru disk tree structure, look for the best one to move */
		error = DirTree(drive,_DefragHandler_,&strct);
		if ((error != ERR_OKAY) && (error != ERR_ABORTED))
			break;

		/* Need to move a clip? */
		if (!sptr->dd_restart)
		{
			DBUG(print(DB_FILESYS,"Best:%l,hdr=%l\n",
				sptr->dd_bestloc,sptr->dd_besthdr);)

			/* If no eligible file was found to move, we're done */
			if (sptr->dd_bestloc == 0xFFFFFFFF)
			{
				error = ERR_OKAY;
				break;
			}

			/* Modify pointer in file header */
			error = GetBlock(drive,sptr->dd_besthdr,WRITE,&buff);
			if (error != ERR_OKAY)
				break;

			diff = sptr->dd_bestloc - sptr->dd_spot;
			if (buff->file.start != sptr->dd_bestloc)
			{
				DBUG(print(DB_ALWAYS,"Defrag mismatch: %l is not %l, hdr=%l\n",
					buff->file.start,sptr->dd_bestloc,sptr->dd_besthdr);)

				error = ERR_CMDFAILED;
				break;
			}
			buff->file.start -= diff;

			/* Improved to handle double-longs! */
			blks = ExtBytes2Blocks(buff->file.bytes_hi,buff->file.bytes);

			error = PutBlock(buff);
			FreeBlock(&buff);
			if (error != ERR_OKAY)
				break;

			DBUG(print(DB_FILESYS,"Moving %l-->%l (%l)\n",
				sptr->dd_bestloc,sptr->dd_spot,blks);)

			/* Move the clip (allow abort on this) */
			error = CopyData(drive,drive,sptr->dd_bestloc,sptr->dd_spot,blks,HostAbort);
			if (error == ERR_ABORTED)
			{
				// Uhoh, we didn't move it!  Change file header pointer back!!
				error = GetBlock(drive,sptr->dd_besthdr,WRITE,&buff);
				if (error == ERR_OKAY)
				{
					buff->file.start += diff;

					error = PutBlock(buff);
					FreeBlock(&buff);
				}
				error = ERR_ABORTED;
			}
			if (error != ERR_OKAY)
				break;

			/* Free the old clip space */
			error = AddRange(drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY),
				sptr->dd_bestloc,blks);
			if (error != ERR_OKAY)
				break;

			/* Allocate the new clip space */
			error = SubRange(drive,maplist,MAPENTRIES,sizeof(struct MAPENTRY),
				sptr->dd_spot,blks);
			if (error != ERR_OKAY)
				break;

			moves++;			/// Unused!
			sptr->dd_spot += blks;		// Start from end of this moved file
		}
	}
	UnLockVideoRAM();						// Okay, back to normal

	return(error);
}


/*
 *  SetDate - Set file/dir's datestamp
 */
UBYTE SetDate(	UBYTE	drive,
					GRIP	*grip,
					ULONG	days,
					ULONG	mins,
					ULONG	ticks)
{
	UBYTE	err;
	union FSBUFF	*buff;

	DBUG(
		print(DB_FILESYS,"SetDate - drv:%b grip:%l\n",
			drive,(ULONG)grip);
		print(DB_FILESYS,"          days:%l minutes:%l ticks:%l\n",
			days,mins,ticks);
	)

	if (grip == NULL)
		err = ERR_WRONGTYPE;			// Cannot set bits for root
	else
	{
		err = GetBlock(drive,grip->g_header,WRITE,&buff);
		if (err == 0)
		{
			buff->file.date.days = days;
			buff->file.date.minutes = mins;
			buff->file.date.ticks = ticks;

			err = PutBlock(buff);
			FreeBlock(&buff);
		}
	}
	return(err);
}


/*
 *  RenameDisk - Set new volume name
 */
UBYTE RenameDisk(UBYTE drive, char *name)
{
	UBYTE	err;
	union FSBUFF	*buff;

	DBUG(print(DB_FILESYS,"RenameDisk - name:%s\n",(ULONG)name);)

	err = GetBlock(drive,RootGrip.g_header,WRITE,&buff);
	if (err == 0)
	{
		CopyString(name,buff->root.volname,VOLNAMELENGTH);

		err = PutBlock(buff);
		FreeBlock(&buff);
	}
	return(err);
}


/*
 *  Rename - Change name of object
 */
UBYTE Rename(	UBYTE	drive,
					GRIP	*oldgrip,
					char	*oldname,
					GRIP	*newgrip,
					char	*newname)
{
	UBYTE	err;
	union FSBUFF	*hdrbuff,*tempbuff;
	char	*oldbasename,*newbasename;
	ULONG	oldlinkblk,newlinkblk,oldblk,newblk,oldmom,newmom,hashchain;
	WORD	oldhash,newhash;

	DBUG(print(DB_FILESYS,"Rename (drv %l) - from (%l)%s to (%l)%s\n",
		drive,(ULONG)oldgrip,(ULONG)oldname,(ULONG)newgrip,(ULONG)newname);)

	/* Make sure new name doesn't exist */
	err = LocObj(drive,newgrip,newname,&newbasename,
		&newlinkblk,&newhash,&newblk,&tempbuff,&newmom);
	if (err == ERR_OKAY)
	{
		DBUG(print(DB_FILESYS,"Rename already exists!");)
		FreeBlock(&tempbuff);
		return(ERR_EXISTS);
	}
	else if ((err == ERR_OBJNOTFOUND) && (newbasename == NULL))
		return(ERR_OBJNOTFOUND);		// Couldn't find path to new name

	if (err != ERR_OBJNOTFOUND)
		return(err);

	/* Find old name and associated goodies */
	err = LocObj(drive,oldgrip,oldname,&oldbasename,
		&oldlinkblk,&oldhash,&oldblk,&hdrbuff,&oldmom);
	if (err != ERR_OKAY)
		return(err);

	/* Unlink from directory */
	hashchain = hdrbuff->file.nexthash;
	err = GetBlock(drive,oldlinkblk,WRITE,&tempbuff);
	if (err != ERR_OKAY)
	{
		FreeBlock(&hdrbuff);
		return(err);
	}

	if (oldhash == -1)
		tempbuff->file.nexthash = hashchain;			// I was an extension
	else
		tempbuff->dir.entries[oldhash] = hashchain;	// I was a child

	err = PutBlock(tempbuff);
	FreeBlock(&tempbuff);
	if (err != ERR_OKAY)
	{
		FreeBlock(&hdrbuff);
		return(err);
	}

	/* Make sure we still have a valid path to new object location */
	err = LocObj(drive,newgrip,newname,&newbasename,
		&newlinkblk,&newhash,&newblk,&tempbuff,&newmom);
	if ((err != ERR_OBJNOTFOUND) || (newbasename == NULL))
	{
		/* Must be trying to move directory inside one of it's children!! */
		FreeBlock(&hdrbuff);

		/* Link back to original directory */
		LinkOnChain(drive,oldblk,oldlinkblk,oldhash);

		return(ERR_INUSE);						// Cannot allow this!
	}

	/* Rename the header -- modify object's header */
	hdrbuff->file.nexthash = 0;				// None after me w/same hash
	hdrbuff->file.parent = newmom;			// New link upwards
	CopyString(newbasename,hdrbuff->file.name,FILENAMELENGTH);

	err = PutBlock(hdrbuff);
	FreeBlock(&hdrbuff);
	if (err != ERR_OKAY)
		return(err);

	/* Now link into filesystem in new place */
	err = LinkOnChain(drive,oldblk,newlinkblk,newhash);

	ChangeDate(drive,oldmom);			// Update date on my old parent
	if (oldmom != newmom)
		ChangeDate(drive,newmom);		// Update date on my new parent (if we moved)

	return(err);
}


/*
 * StripDevName - Return pointer filename stripped of any device:
 *                (Does not make a copy, but just a ptr)
 */
char *StripDevName(char *name)
{
	char	*ptr,*spot;

	ptr = name;
	spot = ptr;
	while (*ptr)
	{
		if (*ptr == ':')
			spot = ptr+1;
		ptr++;
	}
	return(spot);
}


/*
 * SkipSubName - Strips sub-directory specification out of filename
 *             (Does not alter, just returns pointers)
 */
char *SkipSubName(	char	*name,
							char	**term)
{
	while ((*name != 0) && (*name != '/'))
		name++;

	*term = name;

	if (*name == '/')
		name++;

	return(name);
}


///*
// * CheckExists - Make sure named object does not exist, else error
// */
//UBYTE CheckExists(UBYTE	drive,
//						GRIP	*grip,
//						char	*name)
//{
//	UBYTE	err;
//	ULONG	blk,linkblk;
//	WORD	hash;
//	union FSBUFF	*buff;
//	APTR	base;
//	ULONG	mom;
//
//	/* Make sure new name doesn't exist */
//	err = LocObj(drive,grip,name,&base,&linkblk,&hash,&blk,&buff,&mom);
//	if (err == ERR_OKAY)
//	{
//		DBUG(print(DB_FILESYS,"Exists!");)
//		FreeBlock(&buff);
//		return(ERR_EXISTS);
//	}
//	else
//		return(ERR_OKAY);
//}


/*
 * Hdr2ClipInfo - Moves data from a file header to a ClipInfo structure
 */
UBYTE Hdr2ClipInfo(	UBYTE	drive,
							union FSBUFF	*buff,
							struct ClipInfo	*clip,
							BOOL	extra)
{
//	UWORD	len;
	UBYTE	err;
	ULONG	startloc;

	if (extra)
		ClipSMPTE(drive,buff->file.start+1);	// Get start SMPTE time code

	err = ERR_OKAY;
//Unused yet
//	len = clip->len;		// Use this to not clobber user's shorter structure

	/* Copy name */
	CopyString(buff->file.name,clip->Name,CINAMELENGTH);
	CopyString(buff->file.comment,clip->Comment,CICOMMENTLENGTH);

	clip->Type = buff->file.type;

	/* Copy date */
	CopyMem(&buff->file.date,&clip->Date,sizeof(struct FlyerDate));

	clip->Bits = buff->file.bits;

	if (buff->file.type == TYPE_FILE)
	{
		clip->Start		 = buff->file.start;
		clip->Length	 = buff->file.bytes;
		clip->LengthExt = buff->file.bytes_hi;

//	DBUG(print(DB_TEST,"H2CI: Bytes = %l,%l  blks=%l\n",
//		clip->LengthExt,clip->Length,ExtBytes2Blocks(clip->LengthExt,clip->Length));)

		/* Improved to handle double-longs! */
		clip->EndBlk = clip->Start + ExtBytes2Blocks(clip->LengthExt,clip->Length);

		/* Read in clip's master header -- if info requested */
		if (extra)
		{
			startloc = buff->file.start;
			err = GetClipInfo(drive,startloc,&clip->Flags,&clip->IndexBlk,
				&clip->Fields,&clip->NumAudChans,&clip->VideoGrade);
		}
	}

	return(err);
}


/*
 * GetClipInfo - Get stats of a file
 */
UBYTE GetClipInfo(UBYTE	drive,
						ULONG	start,
						BYTEBITS	*flags,
						ULONG	*index,
						ULONG	*fields,
						UBYTE	*audchans,
						UBYTE	*vidgrade)		// This one's optional
{
	UBYTE	err;
	struct CLIPHDR	*cliphdr;
	union FSBUFF	*databuff;

	databuff = AllocSRAM(1);			// Get a block of memory
	if (databuff == NULL)
		return(ERR_NOMEM);

	*flags = 0;
	*index	= 0;
	*fields= 0;

	/* Read in clip's master header */
	err = ReadBlock(drive,start,databuff);
	if (err == ERR_OKAY)
	{
		cliphdr = (struct CLIPHDR *)databuff;
		if (cliphdr->ch_id != ID_CLIP)
			err = ERR_BADVIDHDR;
		else
		{
			if (cliphdr->ch_vidflag)
				*flags |= CIF_HASVIDEO;

			*audchans = cliphdr->ch_audchans;
			if (cliphdr->ch_audchans != 0)
				*flags |= CIF_HASAUDIO;

			*fields = cliphdr->ch_fields;
			if (cliphdr->ch_tail == 0)
				*index = 0;
			else
				*index = start+cliphdr->ch_tail;

//			start += cliphdr->ch_datastart;		// Offset to start of data

			if (vidgrade)
				*vidgrade = cliphdr->ch_vidgrade;	// Report video grade (if desired)
		}
	}

	DBUG(print(DB_FILESYS,"GFS error:%b\n",err);)

	FreeSRAM(databuff,1);							// Free this resource back up

	return(err);
}


/*
 * BlankHeadList - Create a blank headlist for drive (either new or present)
 *			If count != 0, make list 'count' long.  If count = 0, do a "quick"
 *			blank operation
 */
UBYTE BlankHeadList(	UBYTE	drive,
							ULONG	blk,
							ULONG	size)
{
	UBYTE	err;
	union FSBUFF	*buff;
	ULONG	count,oldnext;

	DBUG(print(DB_HEADS,"Blanking list (drive %b, list %l)\n",drive,blk);)

	if (blk == 0)
		return(ERR_BADPARAM);

	count = 0;
	do
	{
		err = GetBlock(drive,blk,WRITE,&buff);		// Read block in
		if (err == ERR_OKAY)
		{
			count++;
			oldnext = buff->map.mb_Next;
			ClearMemory(buff,512);				// Start with blank buffer
			buff->map.mb_ID = HEADLIST_ID;
			if (size == 0)
				buff->map.mb_Next = oldnext;
			else if (count == size)
				buff->map.mb_Next = 0;			// Last block
			else
				buff->map.mb_Next = 1;

			if (count == 1)						// First block only
				buff->map.mb_Entries[0].me_Block = LISTEND;

			err = PutBlock(buff);
			FreeBlock(&buff);
			blk++;
		}
	} while ((err == ERR_OKAY) && (count!=size) && (size!=0));		// Quick clear
//	  while ((err == ERR_OKAY) && (count!=size) && ((size!=0) || (oldnext!=0)));

	return(err);
}


/*
 * AllocHead - Allocate room for a head on a drive
 */
UBYTE FS_AllocHead(	UBYTE	drive,
							ULONG	size,
							ULONG	*loc)
{
	UBYTE	err;
	ULONG	freelist,begin,end;
	union FSBUFF	*buff;

	err = FindFreeList(drive,&freelist);
	if (err != ERR_OKAY)
		return(err);

	/* Get topmost area that is big enough */
	err = GetFreeSpace(drive,size,TRUE,&begin,&end);
	if (err == ERR_OKAY)
	{
		begin = end-size;			// Use very top of range found

		/* Now remove area used from drive's FreeList */
		err = SubRange(drive,freelist,MAPENTRIES,sizeof(struct MAPENTRY),begin,size);
		if (err == ERR_OKAY)
		{
			/* Add size to total "headspace" in root info */
			err = GetBlock(drive,RootGrip.g_header,WRITE,&buff);
			if (err == ERR_OKAY)
			{
				buff->root.headspace += size;		// Add to space count
				err = PutBlock(buff);
				FreeBlock(&buff);
			}

			if (err == ERR_OKAY)
				*loc = begin;
			else
			{
				/* Oops, add it back to FreeList */
				err = AddRange(drive,freelist,MAPENTRIES,sizeof(struct MAPENTRY),
					begin,size);
			}
		}
	}

	return(err);
}


/*
 * FS_FreeHead - Free head's room on a drive
 */
UBYTE FS_FreeHead(UBYTE	drive,
					ULONG	start,
					ULONG	size)
{
	UBYTE	err;
	union FSBUFF	*buff;

	err = FreeUpSpace(drive,start,size);

	if (err == ERR_OKAY)
	{
		/* Remove size from total "headspace" in root info */
		err = GetBlock(drive,RootGrip.g_header,WRITE,&buff);
		if (err == ERR_OKAY)
		{
			buff->root.headspace -= size;		// Lower head space total
			err = PutBlock(buff);
			FreeBlock(&buff);
		}
	}

	return(err);
}


/*
 * _ZapHeadsHandler_ Destroy a clip's private head definitions
 *							(useful only for orphan'ed definitions!)
 */
static UBYTE _ZapHeadsHandler_(UBYTE	drive,
										struct ClipInfo	*objinfo,
										GRIP	*grip,
										APTR	custom)
{
	UBYTE	err;
	ULONG	ID;

	DBUG(print(DB_HEADS,"File:%l\n",objinfo->Start);)

	if((objinfo->Type == TYPE_FILE)								// Process only files
	&& ((CIF_HASVIDEO | CIF_HASAUDIO) & objinfo->Flags))	// Must be a clip
	{

		ID = grip->g_DL_blk;			// ID of file we're checking/cleaning

		DBUG(print(DB_HEADS,"Cleaning clip (ID=%l)\n",ID);)

//		/* Find clip's private head list */
//		err = GetIDsHeadList(drive,ID,&privlist);
//		if (err != ERR_OKAY)
//			return(err);

		// All we need to clean a clip's list is its tail header (IndexBlk)
		err = CleanPrivHeadList(drive,objinfo->IndexBlk);
		// Ignore error, because we want to give all clips a chance to clean up
	}

	return(ERR_OKAY);
}


/*
 * FS_ZapAllHeads - Destroy all clip private head definition's on a drive
 *						(useful only for orphan'ed definitions!)
 */
UBYTE FS_ZapAllHeads(UBYTE drive)
{
	UBYTE	error;

// Someday soon...

// Rebuild free list by clearing to all blocks, then subtracting out
// Each known data file

	DBUG(print(DB_HEADS,"Zapping heads for drive %b\n",drive);)

	/* Go thru disk tree structure, call ZapHeadsHandler on each item */
	error = DirTree(drive,_ZapHeadsHandler_,NULL);

	return(error);
}



/*
 *	KillFilesHeads - Kill any heads for file
 */
void KillFilesHeads(UBYTE drive, ULONG myID)
{
	struct LISTCTRLSTRUCT	ctrl;
	struct FSHEADENTRY		*ent;
	UBYTE	err;
	ULONG	headlist;

	DBUG(print(DB_FILESYS,"KillFileHeads on ID %l\n",myID);)

	err = FS_FindHeadList(drive,0,&headlist);
	if (err == ERR_OKAY)
	{

		/* Open the current list of heads */
		InitList(&ctrl,drive,headlist,FSHEADENTRIES,sizeof(struct FSHEADENTRY));

		err = NextNode(&ctrl,(APTR *)&ent);
		while ((err == ERR_OKAY) && (ent->fshe_start != LISTEND))
		{
			/* Is this head attached to our clip? */
			if (ent->fshe_ID != myID)
				err = NextNode(&ctrl,(APTR *)&ent);
			else
			{
				/* Delete head */
				err = DestroyHead(drive,ent->fshe_ID,ent->fshe_start,
					ent->fshe_length);
				if (err != ERR_OKAY)
					break;

				/* Now delete from current list */
				err = DeleteNode(&ctrl);
				if (err != ERR_OKAY)
					break;

				/* Get new entry at same location (after delete) */
				err = SameNode(&ctrl,(APTR *)&ent);
			}
		}

		/* Close list */
		FreeList(&ctrl);
	}
}


/*
 * GetFreeHdrBlock - Look for a free header block on drive, load and return
 *							Gets exclusive access to header block
 */
static UBYTE GetFreeHdrBlock(	UBYTE	drive,
										ULONG	*hblk,
										union FSBUFF	**buff)
{
	UBYTE	err;
	ULONG	hdrbeg,hdrend,blk,*ptr,i;

	err = GetBlock(drive,RootGrip.g_header,READ,&(*buff));
	if (err != ERR_OKAY)
		return(err);

	hdrbeg = (*buff)->root.hdrsarea;
	hdrend = (*buff)->root.dataarea-1;
	if (HdrHint == 0)
		HdrHint = hdrbeg;					// Look at beginning first time

	FreeBlock(&(*buff));

	/* Look for an unused header block -- start at hint point */
	for (blk=HdrHint;blk<=hdrend;blk++)
	{
		err = GetBlock(drive,blk,WRITE,&(*buff));
		if (err != ERR_OKAY)
			return(err);

		if ((*buff)->file.id == 0)
		{
			/* Blank out new header */
			ptr = (ULONG *)*buff;
			for (i=1;i<=128;i++)
				*ptr++ = 0;

			*hblk = blk;
			HdrHint = blk;
			return(ERR_OKAY);
		}
		else
			FreeBlock(&(*buff));
	}

	/* OK, punt.  Look back thru rest of hdrs for space */
	for (blk=hdrbeg;blk<=HdrHint;blk++)
	{
		err = GetBlock(drive,blk,WRITE,&(*buff));
		if (err != ERR_OKAY)
			return(err);

		if ((*buff)->file.id == 0)
		{
			/* Blank out new header */
			ptr = (ULONG *)*buff;
			for (i=1;i<=128;i++)
				*ptr++ = 0;

			*hblk = blk;
			HdrHint = blk;
			return(ERR_OKAY);
		}
		else
			FreeBlock(&(*buff));
	}

	return(ERR_DIRFULL);
}


void ChangeDate(UBYTE drive, ULONG blk)
{
	union FSBUFF	*buff;
	UBYTE	err,type;
	BOOL	doit;

	DBUG(print(DB_FILESYS,"ChangeDate on %l\n",blk);)

	err = GetBlock(drive,blk,WRITE,&buff);
	if (err == ERR_OKAY)
	{
		type = buff->dir.type;
		if (type == TYPE_DIR)
		{
			GetDateStamp(&buff->dir.date);
			doit = TRUE;
		}
		else if (type == TYPE_ROOT)
		{
			GetDateStamp(&buff->root.date);
			doit = TRUE;
		}
		else
			doit = FALSE;

		if (doit)
		{
			err = PutBlock(buff);
			DBUG(print(DB_FILESYS,"Did it (res %b)\n",err);)
		}
		FreeBlock(&buff);
	}
}


/*
 *	SetTimeClock - Set date/time clock to preset value
 */
UBYTE SetTimeClock(ULONG days, ULONG minutes, ULONG ticks)
{
	struct TOD *rtc;

	rtc = &RealTimeClock;

	DBUG(print(DB_ALWAYS,"Was: %l,%l,%l,%l\n",rtc->days,rtc->minutes,rtc->seconds,rtc->ticks);)

	Disable();

	rtc->days = days;
	rtc->minutes = minutes;
	rtc->seconds = ticks / AMIGATICKS;
	rtc->ticks = (ticks % AMIGATICKS) * 2;		// Conversion from Amiga time to Flyer time

// For old tick rate (15 Hz) -- Efficient coding of ticks * 3/10
//	rtc->ticks = (UBYTE)(UWORD)
//		((UWORD)(((ticks % AMIGATICKS)) * 3) / (UWORD)10);


	Enable();

	DBUG(print(DB_ALWAYS,"New: %l,%l,%l,%l\n",rtc->days,rtc->minutes,rtc->seconds,rtc->ticks);)

	return(ERR_OKAY);
}


/*
 *	GetDateStamp - Stamp the current date/time into caller's structure
 */
void GetDateStamp(struct FlyerDate *date)
{
	struct TOD *rtc;
	UWORD	aticks;

	rtc = &RealTimeClock;

	Disable();

	date->days = rtc->days;
	date->minutes = rtc->minutes;
	aticks = rtc->ticks/2;		// Conversion from Flyer time to Amiga time

// For old tick rate (15 Hz) -- Efficient coding of ticks * 10/3
//	aticks = (UWORD)(rtc->ticks*10) / (UWORD)3;

	date->ticks = (rtc->seconds * AMIGATICKS) + (ULONG)aticks;

	Enable();
}


/*
 *	TimeDiffmSec - Find time difference between two datestamps (in milliseconds)
 */
ULONG TimeDiffmSec(struct FlyerDate *date1, struct FlyerDate *date2)
{
	ULONG	tickdiff;

	DBUG(print(DB_FILESYS,"Time1: %l %l %l\n",date1->days,date1->minutes,date1->ticks);)
	DBUG(print(DB_FILESYS,"Time2: %l %l %l\n",date2->days,date2->minutes,date2->ticks);)

	tickdiff = (date2->days - date1->days) * 24*60*60*AMIGATICKS;
	tickdiff += (date2->minutes * 60*AMIGATICKS) + date2->ticks;
	tickdiff -= (date1->minutes * 60*AMIGATICKS) + date1->ticks;

	return(tickdiff * (1000/AMIGATICKS));
}


/*
 * FormatCheck - does a test to see if drive is formatted properly
 */
UBYTE FormatCheck(UBYTE	drive)
{
	UBYTE	err;
	union FSBUFF	*buff;

	err = GetBlock(drive,RootGrip.g_header,READ,&buff);
	if (err == ERR_OKAY)
	{
		if (buff->root.id != ID_ROOT)
			err = ERR_UNFORMATTED;
		FreeBlock(&buff);
	}

//	DBUG(print(DB_ALWAYS,"Format check on drive %b --> %b",drive,err);)

	return(err);
}


/*
 * DriveSurvey - Establish drive types and associations
 */
void DriveSurvey(void)
{
	UBYTE	drive;
	UBYTE	chan;
	ULONG	bigsize[NUMSCSICHANS];
	BYTEBITS	chanflags[NUMSCSICHANS];
	UBYTE	err;
	union FSBUFF	*buff;
	UBYTE	vchan[2];
	ULONG	j;
	struct DriveStuff *di;

#define	DSF_VIDEO	(1<<0)
#define	DSF_AUDIO	(1<<1)

	DBUG(print(DB_ALWAYS,"Drive survey...\n");)

	/* Ready to find biggest unit on each channel */
	for (chan=0;chan<NUMSCSICHANS;chan++)
	{
		bigsize[chan] = 0;
		BigUnit[chan] = 0;
		chanflags[chan] = 0;
	}

	AudScsiDrive = 0xFF;
	AudScsiChan = 0xFF;

	for (drive=0;drive<NUMSCSIDRIVES;drive++)
	{
		chan = drive >> 3;
		FlyerDrives[drive] = FALSE;						// Default

		di = &DrvInfo[drive];
		di->Abilities = 0;

		if ((di->Presence) && (!di->DontTouch))
		{
			if (FormatCheck(drive) == ERR_OKAY)			// Formatted?
			{
				FlyerDrives[drive] = TRUE;					// There's a Flyer drive here

				if (di->LastBlk > bigsize[chan])		// Biggest so far?
				{
					bigsize[chan] = di->LastBlk;
					BigUnit[chan] = drive & 0x7;
				}

				err = GetBlock(drive,RootGrip.g_header,READ,&buff);
				if (err == ERR_OKAY)
				{
					if (FVIF_VIDEOREADY & buff->root.flags)
					{
						di->Abilities |= DAF_VIDEO | DAF_AUDIO;
						chanflags[chan] |= DSF_VIDEO;
					}
					else if (FVIF_AUDIOREADY & buff->root.flags)
					{
						di->Abilities |= DAF_AUDIO;
						chanflags[chan] |= DSF_AUDIO;
						/* Remember last audio drive found */
						AudScsiDrive = drive;
						AudScsiChan = drive >> 3;
					}
					FreeBlock(&buff);
				}
			}
		}
	}

	/* Determine video channels (left over - prefer 0 & 1) */
	j = 0;
	vchan[0] = 0xFF;
	vchan[1] = 0xFF;
	for (chan=0;chan<NUMSCSICHANS;chan++)
	{
		if (chan != AudScsiChan)
		{
			if (DSF_VIDEO & chanflags[chan])
			{
				if (j<2)
					vchan[j++] = chan;
			}
		}
	}

	/* Check associations, kill audio if needed to ensure video A/B roll */
	for (j=0;j<=1;j++)
	{
		if ((AudScsiChan != 0xFF) && (DSF_VIDEO & chanflags[AudScsiChan]))
		{
			if (vchan[j] == 0xFF)
			{
				vchan[j] = AudScsiChan;
				AudScsiChan = 0xFF;
				AudScsiDrive= 0xFF;
			}
		}
	}

	/* Associate channels */
	for (chan=0;chan<NUMSCSICHANS;chan++)
	{
		OppChan[chan] = chan;			// All channels default to themselves
	}

	if ((vchan[0] != 0xFF) && (vchan[1] != 0xFF))
	{
		OppChan[vchan[0]] = vchan[1];
		OppChan[vchan[1]] = vchan[0];
	}

	DBUG(
		for (chan=0;chan<NUMSCSICHANS;chan++)
		{
			print(DB_FILESYS,"Channel %b:\n",chan);
			print(DB_FILESYS,"  BigUnit %b has %l blocks, flags=%b, Opp=%b\n",
			BigUnit[chan],bigsize[chan],chanflags[chan],OppChan[chan]);
		}

		print(DB_FILESYS,"Audio drive is %b\n",AudScsiChan);
	)
}


/*
 * DriveVidReady - Checks drive speed to see if it's video-ready
 */
BOOL DriveVidReady(UBYTE drive)
{
	struct FlyerDate	time1,time2;
	ULONG	expired;
	UBYTE	err;

	/* Get time stamp */
	GetDateStamp(&time1);

	/* Read 3 Megs from drive to measure approximate speed */
	err = ReadTest(drive,0,0x0200,12,1);

	/* Get time stamp */
	GetDateStamp(&time2);

	expired = TimeDiffmSec(&time1,&time2);

	DBUG(print(DB_FILESYS,"Took %d ms\n",expired);)

	/* If took longer than 1000 ms, not video */
	if (expired <= 1000)
		return(TRUE);
	else
		return(FALSE);
}


/*
 *	FSinfo - Return FileSystem info (put in user-supplied structure)
 */
UBYTE FSinfo(UBYTE drive, struct FlyerVolInfo *vip)
{
	union FSBUFF	*buff;
	UBYTE	err,error;

	DBUG(print(DB_FILESYS,"FSinfo drive:%b len:%w addr:%l\n",drive,vip->len,vip);)

	error = GetBlock(drive,RootGrip.g_header,READ,&buff);
	// This hack should really be handled by detecting a sense key 6!!!
	if (error == ERR_BADSTATUS)
	{
		error = GetBlock(drive,RootGrip.g_header,READ,&buff);
	}
	if (error == ERR_OKAY)
	{
		/* Copy to SRAM location specified */
		DBUG(printchar(DB_FILESYS,'$');)

// Unused yet
//		len = vip->len;		// Size of structure we can modify

		/* May have been removed/added/formatted since power-up */
		FlyerDrives[drive] = (buff->root.id == ID_ROOT)?TRUE:FALSE;

		vip->Ident		= buff->root.id;
		vip->Version	= buff->root.version;
		vip->LTitle	= 0;		// Host will handle this if needed
		CopyString(buff->root.volname,vip->Title,VOLNAMELENGTH);
		vip->Blocks		= buff->root.userblks;
		vip->Flags		= buff->root.flags;
		vip->DiskOkay	= buff->root.diskokay;
		vip->BlkSize	= buff->root.blksize;
		CopyMem(&buff->root.date,&vip->DiskDate,sizeof(struct FlyerDate));
		err = FS_GetMapStats(drive,&vip->Largest,&vip->BlksFree);
		vip->FragBlks	= vip->BlksFree - vip->Largest;
		vip->Optimized	= vip->BlksFree;

		FreeBlock(&buff);
	}

	return(error);
}


/*
 *	Parent - Get parent of a previously obtained grip
 */
UBYTE Parent(UBYTE drive, GRIP *grip, GRIP **newgrip, ULONG *block)
{
	union FSBUFF	*buff;
	UBYTE error = ERR_OKAY;

	DBUG(print(DB_FILESYS,"Parent - drv:%b grip:%l (root=%l)\n",drive,grip,&RootGrip);)

	if (grip == NULL)
		grip = &RootGrip;

	if (grip->g_type == TYPE_ROOT)
		error = ERR_OBJNOTFOUND;		// Root has no parent
	else
	{

//		if (grip->g_parent == 0)
//			*newgrip = &RootGrip;
//		else

		*newgrip = AllocGrip(drive);
		if (*newgrip == NULL)
			error = ERR_NOMEM;
		else
		{
			error = GetBlock(drive,grip->g_parent,READ,&buff);
			if (error == ERR_OKAY)
			{
				*block = grip->g_parent;
				(*newgrip)->g_header = grip->g_parent;
				(*newgrip)->g_type = buff->file.type;
				(*newgrip)->g_parent = buff->file.parent;
				FreeBlock(&buff);
			}
		}
	}
	DBUG(print(DB_FILESYS,"(newgrip = %l, blk=%l, err = %b)\n",*newgrip,*block,error);)

	return(error);
}


/*
 *	CopyFile - Copy a clip (to specified drive and specified new name)
 */
UBYTE CopyFile(UBYTE srcdrive,char *srcname, UBYTE dstdrive,char *dstname, UBYTE *HostAbort)
{
	struct ClipInfo	info;
	GRIP	*newgrip;
	ULONG	toblk,toend,size,fragbytes,tail;
	UBYTE	error = ERR_OKAY;

	DBUG(print(DB_FILESYS,"CopyClip (%d)%s to (%d)%s\n",srcdrive,srcname,dstdrive,dstname);)

	ObtainSemaphore(&CopyFileSema);

	error = FileInfo(srcdrive,0,srcname,&info);
	if (error == ERR_OKAY)
	{
		/* Make sure name doesn't already exist */
		error = FS_Locate(dstdrive,0,0,dstname,&newgrip,&toblk);
		if (error == ERR_OKAY)
		{
			/* Throw it away */
			FreeGrip(dstdrive,newgrip);
			error = ERR_EXISTS;
		}
		else
			error = ERR_OKAY;

		if (error == ERR_OKAY)
		{
			/* Now handles double-longs! */
			size = ExtBytes2Blocks(info.LengthExt,info.Length);
			fragbytes = info.Length & 511;

			error = GetFreeSpace(dstdrive,size,FALSE,&toblk,&toend);
			if ((error == ERR_OKAY) && ((toend-toblk) >= size))
			{
				DBUG(
					print(DB_ALWAYS,"CopyFile: from %b/%s to %b/%s\n",
						srcdrive,srcname,dstdrive,dstname);
					print(DB_ALWAYS,"from:%l to:%l size:%l\n",info.Start,toblk,size);
				)

				error = CopyData(srcdrive,dstdrive,info.Start,toblk,size,HostAbort);
				if (error == ERR_OKAY)		// Watch!  May get aborted by app!
				{
					error = NewFile(dstdrive,toblk,size,0,dstname,FALSE,fragbytes,&newgrip);

					/* Throw it away */
					if (error == ERR_OKAY)
						FreeGrip(dstdrive,newgrip);

					if ((CIF_HASVIDEO | CIF_HASAUDIO) & info.Flags)	// Clip's only!
					{
						// Empty a clip's headlist without trying to deallocate space for them
						tail = info.IndexBlk - info.Start + toblk;		// Tail header of new clip
						CleanPrivHeadList(dstdrive,tail);
						// Ignore error
					}
				}
			}
		}
	}

	ReleaseSemaphore(&CopyFileSema);

	return(error);
}


/*
 *	CreateFile - Make a file (no contents)
 */
UBYTE CreateFile(	UBYTE drive,
						char *name,
						ULONG blks,				// Number of blocks to contain (rounded up)
						ULONG fragbytes,		// Actual size of last block (0 if whole)
						ULONG *startblk)
{
	GRIP	*newgrip;
	ULONG	endblk;
	UBYTE	error = ERR_OKAY;

	error = GetFreeSpace(drive,blks,FALSE,&(*startblk),&endblk);
	if ((error == ERR_OKAY) && ((endblk - (*startblk)) >= blks))
	{
		DBUG(print(DB_FILESYS,"AllocFile: (%b) from %l to %l\n",
			drive,*startblk,endblk);)

		error = NewFile(drive,*startblk,blks,0,name,FALSE,fragbytes,&newgrip);
		if (error == ERR_OKAY)
			FreeGrip(drive,newgrip);	// Throw it away
	}

	return(error);
}


/*
 *	FSsetbits - Set file/dir's protect bits
 */
UBYTE FSsetbits(UBYTE drive, GRIP *grip, ULONG bits)
{
	union FSBUFF	*buff;
	UBYTE	error = ERR_OKAY;

	DBUG(print(DB_FILESYS,"SetBits - drv:%b grip:%l bits:%l\n",drive,grip,bits);)

	if (grip == NULL)
		error = ERR_WRONGTYPE;		// Cannot set bits for root
	else
	{
		error = GetBlock(drive,grip->g_header,WRITE,&buff);
		if (error == 0)
		{
			buff->file.bits = bits;
			error = PutBlock(buff);
			FreeBlock(&buff);
		}
	}

	return(error);
}


/*
 *	FSsetcomment - Set file/dir's comment
 */
UBYTE FSsetcomment(UBYTE drive, GRIP *grip, char *comment)
{
	union FSBUFF	*buff;
	UBYTE	error = ERR_OKAY;

	DBUG(print(DB_FILESYS,"SetComment - drv:%b grip:%l cmt:%s\n",drive,grip,comment);)

	if (grip == NULL)
		error = ERR_WRONGTYPE;		// Cannot set bits for root
	else
	{
		error = GetBlock(drive,grip->g_header,WRITE,&buff);
		if (error == 0)
		{
			CopyString(comment,buff->file.comment,FILECOMMENTLENGTH);

			error = PutBlock(buff);
			FreeBlock(&buff);
		}
	}

	return(error);
}



/*
 *  FileExtend - Extends a file.
 */
UBYTE FileExtend(	UBYTE drive,
						APTR  fileid,
						ULONG length)
{
	union FSBUFF	*databuff,*hdrbuff;
	APTR	MYBUFFER;
	GRIP	*grip;
	UBYTE	err,res;
	ULONG	total,oldpos,oldpos_ext,newlen,newlen_ext,moreblks,firstnew,newcount,newmax;
	ULONG temp64_hi, temp64_lo;

	DBUG(print(DB_FILESYS,"Extend - drv:%b id:%l len:%l\n",
		drive,(ULONG)fileid,length);)

	grip	= fileid;

	if ((grip == NULL) || (! grip->g_opened))
		return(ERR_OBJNOTFOUND);

	databuff = AllocSRAM(1);			// Get a block of memory
	if (databuff == NULL)
		return(ERR_NOMEM);

	/* Pre-fetch this file's header into RAM */
	err = GetBlock(drive,grip->g_header,WRITE,&hdrbuff);
	if (err == ERR_OKAY)
	{
		/* How far can we extend this file */
		/* Improved to handle double-longs!!! */
		firstnew = grip->g_startblk+ExtBytes2Blocks( grip->g_physlen_ext, grip->g_physlen );
		newcount = 0;
		newmax = GetExtendSpace(drive,firstnew);

		oldpos = grip->g_curpos;
		oldpos_ext = grip->g_curpos_ext;
		total	= 0;
		err	= ERR_OKAY;
		newlen = grip->g_filelen;
		newlen_ext = grip->g_filelen_ext;
		Add64( 0L, length, &newlen_ext, &newlen );


		DBUG(print(DB_FILESYS,"newmax: %l  firstnew: %l\n",newmax,firstnew);)

		temp64_hi = grip->g_filelen_ext;
		temp64_lo = grip->g_filelen;
		Add64( 0L, length, &temp64_hi, &temp64_lo );
		moreblks = ExtBytes2Blocks( temp64_hi, temp64_lo ) - ExtBytes2Blocks( grip->g_filelen_ext, grip->g_filelen );	

		DBUG(print(DB_FILESYS,"\n======================================\n");)

		DBUG(print(DB_FILESYS,"\ngrip->g_filelen: %l \n",grip->g_filelen);)
		DBUG(print(DB_FILESYS,"g_physlen: %l\n",grip->g_physlen);)

		DBUG(print(DB_FILESYS,"\n--------------------------------------\n");)

		DBUG(print(DB_FILESYS,"length to add bytes: %l\n",length);)

		DBUG(print(DB_FILESYS,"moreblks: %l\n",moreblks);)
		DBUG(print(DB_FILESYS,"newlen: %l\n",newlen);)
		DBUG(print(DB_FILESYS,"\n======================================\n");)


		/* See if file needs more blocks */
		if( moreblks )
		{
			/*	Extend the file if posable */
			/* Check for space to extend */

			if ( ( newcount + moreblks ) <= newmax )
			{
				newcount += moreblks;
				hdrbuff->file.bytes = newlen;
				hdrbuff->file.bytes_hi = newlen_ext;
				grip->g_filelen = newlen;
				grip->g_filelen_ext = newlen_ext;
				Blocks2ExtBytes( moreblks, &temp64_hi, &temp64_lo );
				Add64( temp64_hi, temp64_lo, &( grip->g_physlen_ext ), &( grip->g_physlen ) );
			}
			else
			{
				err = ERR_FULL;	
			}		

		}
		else	
		{
			hdrbuff->file.bytes = newlen;
			hdrbuff->file.bytes_hi = newlen_ext;
			grip->g_filelen = newlen;		
			grip->g_filelen_ext = newlen_ext;
		}


		/* Now add back into FreeList any space we didn't use */
		if ( newmax > newcount )
		{
			res = FreeUpSpace(drive, firstnew + newcount, newmax - newcount );
		}

		/* Flush header back to disk */
		PutBlock(hdrbuff);
		FreeBlock(&hdrbuff);
	}
	FreeSRAM(databuff,1);			// Free this resource back up
	return(err);
}


/*		>>>Not Used see FileHSWrite for both reading and writing.<<<
 *  FileHSRead - Read lots of blocks from file
 */
UBYTE	FileHSRead(UBYTE	drive,
						APTR	fileid,
						ULONG	Start_Blk,
						ULONG	length,
						ULONG	buffer,
						UBYTE WFLAG)
{
	union FSBUFF	*databuff;
	ULONG	XFERBuff;
	GRIP	*grip;
	ULONG	left,blk,offset,size,total,oldpos, oldpos_ext;
	UBYTE	err;

	DBUG(print(DB_FILESYS,"HSRead - drv:%b id:%l buff:%l len:%l\n",
		drive,(ULONG)fileid,(ULONG)buffer,length);)

	grip	= fileid;

	return(err);
}



/*
 *  FileHSWrite - Writes lots of blocks to file
 *  					File must allready be allocated on drive.
 */
UBYTE FileHSWrite(UBYTE	drive,
						APTR	fileid,
						ULONG	Start_Blk,
						ULONG	length,
						UBYTE	*buffer,
						UBYTE WFLAG)
{
	union FSBUFF	*databuff;
	ULONG	XFERBuff;
	GRIP	*grip;
	ULONG	left,blk,offset,size,total,oldpos, oldpos_ext;
	UBYTE	err;

	DBUG(print(DB_FILESYS,"HSWrite - drv: %b id: %l buff: %l stblk: %l len: %l\n",
		drive,fileid,buffer,Start_Blk,length);)

	grip	= fileid;

	if ((grip == NULL) || (! grip->g_opened))
		return(ERR_OBJNOTFOUND);


	if(databuff=AllocSRAM(1))			// Get a block of memory
	{
		if(XFERBuff = (ULONG)AllocDRAM(length))			// Get a block of memory
		{
			DBUG(print(DB_FILESYS,"XFERBuff: %l \n",XFERBuff);)
			
			if(WFLAG)
			{
				err=ScsiWriteSRAM(drive,buffer,XFERBuff,Start_Blk,length);
				DBUG(print(DB_FILESYS,"ScsiWriteSRAM err: %l XFERBuff: %l\n",err,XFERBuff);)
			}
			else 	
			{
				err=ScsiReadSRAM(drive,Start_Blk,XFERBuff,buffer,length);
				DBUG(print(DB_FILESYS,"ScsiReadSRAM err: %l XFERBuff: %l\n",err,XFERBuff);)
			}
		}
		else 
		{	
			DBUG(print(DB_FILESYS,"At ERR_NOMEM DRAM Alloc\n");)
			FreeSRAM(databuff,1);			// Free this resource back up
			return(ERR_NOMEM);
		}
	}
	else
	{	
		DBUG(print(DB_FILESYS,"At ERR_NOMEM SRAM Alloc\n");)
		return(ERR_NOMEM);
	}

	FreeDRAM(XFERBuff,length);			// Free this resource back up
	FreeSRAM(databuff,1);			// Free this resource back up

	return(err);
}

