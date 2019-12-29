/*********************************************************************\
*
* Drive2File - Pull in a Flyer drive, make it into an Amiga file!
*
* $Id: drive2file.c,v 1.1 1997/01/09 12:30:17 Hayes Exp $
*
* $Log: drive2file.c,v $
*Revision 1.1  1997/01/09  12:30:17  Hayes
*no changes
*
*Revision 1.0  1995/05/05  15:49:01  Flick
*FirstCheckIn
*
*
* Copyright (c) 1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	02/15/95		Marty	created
\*********************************************************************/

#include <exec/types.h>
#include <exec/memory.h>
#include <string.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <dos/dos.h>
#include <clib/dos_protos.h>

#include "flyerlib.h"
#include "flyer.h"
#include "intfsprivate.h"

ULONG doit(void);
void GetArg(char *arg,int *var,int lo,int hi,char *label);
void GetLongArg(char *arg,ULONG *var,ULONG lo,ULONG hi,char *label);
ULONG SCSI_Read(ULONG lba, ULONG size);

#define	CHUNK		128		//64K
#define	DMABLK	0xA00
#define	RAMBLK	0x20		// Use EC4000 - ED4000

struct Library *FlyerBase;
struct FlyerVolume FlyVol;
struct ClipAction	 Action;
struct FlyerVolInfo	FVIbuff;

BPTR	handle;

struct DATESTAMP {
	ULONG		days;
	ULONG		minutes;
	ULONG		ticks;
};

main(int argc,char **argv)
{
	int	drive;
	ULONG	res;

	if ((argc!=3)||(argv[1][0]=='?')) {
		printf("Usage: %ls <drive> <filename>\n",argv[0]);
		return(20);
	}

	FlyVol.Board = 0;
	GetArg(argv[1],&drive,0,23,"Drive");
	FlyVol.SCSIdrive = drive;

	if ((FlyerBase = OpenLibrary(FLYERLIBNAME,0))==0) {
		printf("Open flyer.library failed\n");
		return(20);
	}

	res = PlayMode(0);
	res = RecordMode(0);
	res = PlayMode(0);

	Action.Volume = &FlyVol;
	Action.ReturnTime = RT_STOPPED;

	handle = Open(argv[2],MODE_NEWFILE);
	if (handle) {
		res = doit();
		if (res)
			printf("Error %ld - %ls\n",res,Error2String(res));

		Close(handle);
	}
	else {
		printf("Couldn't create file '%ls'\n",argv[2]);
		res = 1;
	}

	CloseLibrary(FlyerBase);

	if (res)
		return(10);
	else
		return(0);
}


ULONG doit(void)
{
	ULONG	lba,size,res,maxblock,actual;
	UBYTE	*buffer;
	struct ROOTHDR	*root;

	buffer = (UBYTE *)0xEC0000 + (512 * RAMBLK);

	FVIbuff.len = sizeof(struct FlyerVolInfo);
	res = FlyerDriveInfo(&FlyVol,&FVIbuff);
	if (res) {
		printf("FVI ");
		return(res);
	}

	res = SCSI_Read(0,1);		// Read ROOT info in
	if (res) {
		printf("Root ");
		return(res);
	}

	root = (struct ROOTHDR *)buffer;

	maxblock = root->videoend;
	printf("Maxblk = %lx\n",maxblock);
	if (maxblock > 0x135F1B) {
		printf("The drive specified seems too big to fit on a CD-ROM!\n");
		return(FERR_CMDFAILED);
	}

	root->flags |= FVIF_WRITEPROT;		// Will be read-only

	actual = Write(handle,root,sizeof(struct ROOTHDR));
	if (actual != sizeof(struct ROOTHDR)) {
		printf("Hdr write failed\n");
		return(FERR_CMDFAILED);
	}

//	maxblock = 5;			//!!!!!

	// Ensure we have an integral number of 2K blocks
	maxblock = (maxblock + 3) & (~3);

	printf("Creating a volume with $%lx blocks\n",maxblock);
	printf("File size should be %ld\n",maxblock * 512);

	for (lba=1;lba<maxblock;lba+=size) {
		size = CHUNK;
		if ((lba+size) > maxblock)
			size = (maxblock - lba);

//		printf("Read %ld\n",size);
		res = SCSI_Read(lba,size);			// Read next chunk of data
		if (res) {
			printf("Read ");
			return(res);
		}

//		printf("Write %ld\n",size);
		actual = Write(handle,buffer,size * 512);
		if (actual != size * 512) {
			printf("Write failure\n");
			return(FERR_CMDFAILED);
		}
	}
	return(FERR_OKAY);
}


ULONG SCSI_Read(ULONG lba, ULONG size)
{
	ULONG	 res;

	res = Read10(&Action,size,lba,DMABLK);
	if (res)
		printf("Read10 Error %ld - %ls\n",res,Error2String(res));
	else {
		res = CPUDMA(0,RAMBLK,DMABLK,size,0);		/* Write to CPU */
		if (res)
			printf("CPUDMA Error %ld - %ls\n",res,Error2String(res));
	}
	return(res);
}


void GetArg(char *arg,int *var,int lo,int hi,char *label)
{
	stch_i(arg,var);
	if ((*var < lo)||(*var > hi)) {
		printf("Error: %ls is out of range\n",label);
		exit(20);
	}
}

void GetLongArg(char *arg,ULONG *var,ULONG lo,ULONG hi,char *label)
{
	stch_l(arg,(long *)var);
	if ((*var < lo)||(*var > hi)) {
		printf("Error: %ls is out of range\n",label);
		exit(20);
	}
}
