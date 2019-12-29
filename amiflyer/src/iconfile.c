/********************************************************************
* $iconfile.c$
* $Id: iconfile.c,v 5.15 1995/01/03 23:00:12 pfrench Exp $
* $Log: iconfile.c,v $
*Revision 5.15  1995/01/03  23:00:12  pfrench
*Jeezo! was incorrectly overwriting the source filename that
*the file's bitmap was located in
*
*Revision 5.14  1995/01/03  22:39:10  pfrench
*Making sure we call croutonlib with the data file name
*
*Revision 5.13  1995/01/03  22:32:47  pfrench
*Now call croutonlib if crouton type undetermined after scanning
*files and finding images but not CrUD chunks
*
*Revision 5.12  1995/01/03  21:27:54  pfrench
*Now will delete allicons file if error on write
*
*Revision 5.11  1995/01/03  21:01:03  pfrench
*Maybe fixed tiny bug in allicons generation, found that most
*of the problems were actually in the icon files themselves,
*many of them didn't have CrUD chunks, which is a major no-no
*
*Revision 5.10  1994/12/23  21:49:35  pfrench
*Decided to put those tags back in.  I'll re-enable buffering
*in proof.library when it works.
*
*Revision 5.9  1994/12/23  20:44:59  pfrench
*Temporarily removing buffered io from iconfile build routines.
*
*Revision 5.8  1994/12/22  21:25:31  pfrench
*Fixed bug where cdrom check was messing up directory parsing
*if there was an .allicons file, but the date wasn't recent
*enough.  Fixed by re-examine()ing the dirlock
*
*Revision 5.7  1994/12/19  22:39:51  pfrench
*Modified for now shared-code proof.library.
*
*Revision 5.6  1994/12/02  14:10:16  pfrench
*changed ".allicons" to ".allicons.i" and using new buffer sizes.
*
*Revision 5.5  1994/11/30  23:42:32  pfrench
*fixed a couple of parsing errors.
*
*Revision 5.4  1994/11/29  13:07:16  pfrench
*put in some defines to allow allicons utility to link
*with little extra code.
*
*Revision 5.3  1994/11/28  20:38:25  pfrench
*First working version.
*
*Revision 5.2  1994/11/28  14:47:48  pfrench
*Got everything compiling correctly, ready to test.
*
*Revision 5.1  1994/11/23  13:53:07  pfrench
*Code still untested. added crouton scanning code.
*
*Revision 5.0  1994/11/23  13:17:59  pfrench
*FirstCheckIn
*
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <string.h>
#include <iffp/ilbm.h>

#include <crouton_all.h>

#include <filelist.h>
#include <grazer.h>

#ifndef CLASSBASE_H
#include "classbase.h"
#endif

#ifndef PROOF_LIB_H
#include <proof_lib.h>
#endif

#ifndef PROOF_STREAM_H
#include "stream.h"
#endif

#include <proto/exec.h>
#include <proto/dos.h>

#ifndef PROTO_PASS
#include <proto.h>
#endif

extern struct Library	*ProofBase;
extern struct ClassBase	*ClassBase;

extern UBYTE AAMachine;

#define BUILD_ICONFILE	TRUE

#define CDROM_BYTESPERBLOCK		(2 * 1024)

#define CROUTON_WIDTH		80
#define CROUTON_HEIGHT		50

extern LONG KPrintF( STRPTR fmt, ... );

extern __asm struct BitMap *AllocIconBM(
	register __d0 LONG width,
	register __d1 LONG height,
	register __d2 LONG depth );

LONG IsCDROMDirectory( BPTR dirlock, struct FileInfoBlock *fib );
LONG BuildFileListFromCDROM( struct List *list, BPTR dirlock, struct FileInfoBlock *fib );
struct GrazerNode *ife_GetEntry( struct IconFileEntry *ife, APTR fh );
struct BitMap *LoadIconBitMap( APTR fh );

ULONG ob_SeekUp2IconsBitMap( APTR fh );
ULONG ob_Seek2IconsBitMap( APTR fh );

ULONG ob_IsGoodIconBM( APTR fh );

ULONG ob_SeekUp2Form( APTR fh, ULONG form_id );
ULONG ob_Seek2Form( APTR fh, ULONG form_id );

ULONG ob_SeekPrevForm( APTR fh );
ULONG ob_SeekNextForm( APTR fh );
LONG BuildIconFile( STRPTR dirname );
LONG WriteIconFile( struct IconBuildHeader *ibh, APTR fh );
LONG IsCroutonFile( struct FileInfoBlock *fib );
LONG ibn_GetCroutonInfo( struct IconBuildNode *ibn );
LONG ExamineCroutonFile( struct IconBuildNode *ibn, APTR fh, LONG direction );


struct IconFileEntry
{
	UBYTE					ife_filename[32];		/* filename w/in the directory */

	UBYTE					ife_flags;				/* flag bits for IconFileEntry */
	UBYTE					ife_pad[3];				/* padding for filename (long align) */

	/* Info extracted from CroutonInfo and ".i" files */
	ULONG					ife_cr_type;			/* Crouton Type */
	ULONG					ife_cr_offset;			/* offset from beginning of file */
	ULONG					ife_cr_size;			/* size of captured ".i" file */

	/* These store the information on where the ".i" file for this 
	 *	filename is in this in this larger group of icons.
	 */

	/* Info to fill out GrazerNodes with */
	ULONG					ife_gn_filesize;		/* size of _actual_ file, _not_ '.i' */
	ULONG					ife_gn_protection;	/* from fib_Protection */
	struct DateStamp	ife_gn_ds;				/* from fib_Date (last modified) */
	UWORD					ife_gn_dosclass;
	UWORD					ife_gn_type;
};

#define IFEF_GETDEFAULT		0x01		/* Use Default image for type */

#define ICONFILE_NAME		".allicons.i"

#define ICONFILE_ID			MAKE_ID('I','A','L','L')
#define ICONFILE_VERSION	1

struct IconFileHeader
{
	ULONG		ifh_ID;				/* MUST == ICONFILE_ID */

	UWORD		ifh_version;		/* version of icon file creation software */

	UWORD		ifh_numentries;	/* how many icons are stored here */

	/* structure is allocation extended */

	struct IconFileEntry	ifh_ife[0];

};

#ifndef ICONFILE_WRITE_ONLY
LONG IsCDROMDirectory( BPTR dirlock, struct FileInfoBlock *fib )
{
	LONG			result = FALSE;
	BPTR			icon;

	if ( icon = Lock(ICONFILE_NAME,ACCESS_READ) )
	{
#ifdef ALLICON_CDROMS_ONLY
		struct InfoData	*id;

		if ( id = AllocMem( sizeof(struct InfoData),MEMF_PUBLIC|MEMF_CLEAR) )
		{
			if ( Info(dirlock, id) )
			{
				if ( id->id_DiskState == ID_WRITE_PROTECTED )
				{
					if ( id->id_BytesPerBlock == CDROM_BYTESPERBLOCK )
					{
						result = TRUE;
					}
				}
			}

			FreeMem(id,sizeof(*id));
		}
#else
		struct DateStamp	 ds = fib->fib_Date;

		if ( Examine(icon,fib) )
		{
			/* If ".allicons" date >= directory date */
			if (	(fib->fib_Date.ds_Days		>= ds.ds_Days) &&
					(fib->fib_Date.ds_Minute	>= ds.ds_Minute) &&
					(fib->fib_Date.ds_Tick		>= ds.ds_Tick) )
			{
				result = TRUE;
			}
		}

		/* MUST re-examine the directory lock */
		Examine(dirlock,fib);
#endif

		UnLock(icon);
	}

	return(result);
}

LONG BuildFileListFromCDROM(
	struct List *list,
	BPTR dirlock,
	struct FileInfoBlock *fib )
{
	LONG		result = 0;
	APTR		all_fh;

	if ( all_fh = ob_NewObject( NULL,FILESTREAMCLASS,
						FSTMA_FileName, ICONFILE_NAME,
						TAG_DONE) )
	{
		struct IconFileHeader	*ifh;
		LONG							 len;

		ob_Seek(all_fh,0,OFFSET_END);
		len = ob_Seek(all_fh,0,OFFSET_BEGINNING);

		if ( ifh = (struct IconFileHeader *) ob_AllocMemObj(ClassBase->cb_allocator_ob,len) )
		{
			/* Read Entire icon file into memory!!! */
			if ( ob_Read(all_fh,ifh,len) == len )
			{
				if ( ifh->ifh_ID == ICONFILE_ID )
				{
					if ( ifh->ifh_version <= ICONFILE_VERSION )
					{
						APTR			mem;

						if ( mem = ob_NewObject( NULL, MEMSTREAMCLASS,
										MEMSTMA_Buf,	ifh,
										MEMSTMA_Len,	1,
										TAG_DONE) )
						{
							WORD			i;

							for ( i=0; i < ifh->ifh_numentries; i++ )
							{
								struct GrazerNode		*gn;

								/* Set the memory stream attrs to the buffered ".i" file */
								ob_SetAttrs(mem,
									MEMSTMA_Buf,	(char *)ifh + ifh->ifh_ife[i].ife_cr_offset,
									MEMSTMA_Len,	ifh->ifh_ife[i].ife_cr_size,
									TAG_DONE);

								if ( gn = ife_GetEntry(&ifh->ifh_ife[i],mem) )
								{
									AddTail(list,(struct Node *)gn);
								}
								else break;
							}

							/* did we get all the entries ??? */
							if ( i == ifh->ifh_numentries )
							{
								result = TRUE;
							}

							ob_Dispose(mem);	/* dispose memory stream */
						}
					}
				}
			}

			ob_Dispose(ifh);	/* Dispose the icon header */
		}

		ob_Dispose(all_fh);
	}

	return(result);
}

struct GrazerNode *ife_GetEntry( struct IconFileEntry *ife, APTR fh )
{
	struct GrazerNode		*gn = NULL;
	struct SmartString	*ss;

	if ( ss = AllocSmartString(ife->ife_filename,NULL) )
	{
		gn = (struct GrazerNode *)AllocGrazerNode(ss);
		FreeSmartString(ss);

		if ( gn )
		{
			gn->FileSize	= ife->ife_gn_filesize;
			gn->Protection	= ife->ife_gn_protection;
			gn->DateStamp	= ife->ife_gn_ds;
			gn->DOSClass	= ife->ife_gn_dosclass;
			gn->Type			= ife->ife_gn_type;

			//if( ife->ife_cr_type != CT_UNSEEN )
			//	gn->Type=CRuDToCR( ife->ife_cr_type );
			//else
			//	gn->Type=CR_UNKNOWN;

			/* Set up behavior of the node */
			gn->EditNode.Behavior = EN_DRAGGABLE;
			if ( gn->DOSClass == EN_DIRECTORY )
				gn->EditNode.Behavior |= EN_DOUBLE_ACTION;

			switch(gn->Type)
			{
				case CR_VIDEO:
				case CR_CONTROL:
				case CR_AUDIO:
				case CR_FXANIM:
				case CR_FXILBM:
				case CR_FXALGO:
				case CR_FXCR:
				case CR_PROJECT:
				case CR_REXX:
				case CR_FRAMESTORE:
				case CR_KEY:
					gn->EditNode.Behavior |= EN_DOUBLE_ACTION;
			}

			if ( ife->ife_flags & IFEF_GETDEFAULT )
			{
				gn->BitMap = GetDefaultBitmap(gn->Type);
			}
			else
			{
				/* seek to end of crouton ".i" file */
				ob_Seek(fh,0,OFFSET_END);

				if ( ob_SeekUp2IconsBitMap(fh) )
				{
					gn->BitMap = LoadIconBitMap(fh);
				}

				if ( !gn->BitMap )
				{
					/* seek to beginning of crouton ".i" file */
					ob_Seek(fh,0,OFFSET_BEGINNING);
		
					if ( ob_Seek2IconsBitMap(fh) )
					{
						gn->BitMap = LoadIconBitMap(fh);
					}
				}
				
			}
		}
	}

	return(gn);
}
#endif /* ICONFILE_WRITE_ONLY */

struct FORMHeader
{
	ULONG			fh_ID;
	ULONG			fh_len;
};

struct FORMHeaderForward
{
	ULONG			fh_ID;
	ULONG			fh_len;
	ULONG			fh_type;
};

struct PUSChunk
{
	struct FORMHeader	pc_fh;				/* Always == { ID_FORM, 0x10 } */
	ULONG					pc_ID;				/* Always == ID_PUS */
	ULONG					pc_prevID;			/* previous FORM type */
	ULONG					pc_formlen;			/* Always == 4 */
	ULONG					pc_prevlen;			/* size of previous form */
};

#define ID_PUS			MAKE_ID(' ','P','U','S')
#define ID_CrUD		MAKE_ID('C','r','U','D')
#define ID_TYPE		MAKE_ID('T','Y','P','E')

#ifndef ICONFILE_WRITE_ONLY
struct BitMap *LoadIconBitMap( APTR fh )
{
	struct BitMap			*bm = NULL;
	LONG						oldpos;
	BOOL						gotit = FALSE, err = 0;

	LONG						dat[2];

	/* seek past [FORM....ILBM] */

	oldpos = ob_Seek(fh,3*sizeof(ULONG),OFFSET_CURRENT);

	while ( !gotit && !err )
	{
		/* Read two longs, chunk_id and chunk_len */

		if ( ob_Read(fh,dat,sizeof(dat)) == sizeof(dat) )
		{
			if ( dat[0] == ID_BMHD )
			{
				BitMapHeader	bmh;

				/* read the chunk length */
				if ( (dat[0] = ob_Read(fh,&bmh,sizeof(bmh))) == sizeof(bmh) )
				{
					bm = AllocIconBM(bmh.w,bmh.h,bmh.nPlanes);
				}
				else err = TRUE;

				/* seek to end of chunk (size of chunk - amount read) */
				ob_Seek(fh,dat[1]-dat[0],OFFSET_CURRENT);
			}
			else if ( dat[0] == ID_BODY )
			{
				if ( bm )
				{
					LONG			bp_offset = 0;
					WORD			row;

					for ( row = 0; row < bm->Rows; row++ )
					{
						WORD	plane;

						for ( plane = 0; plane < bm->Depth ; plane++ )
						{
							if ( ob_Read(fh,((char *)bm->Planes[plane])+bp_offset,
									bm->BytesPerRow) != bm->BytesPerRow )
							{
								err = TRUE;
								break;
							}
						}

            		if (err)	break;

						bp_offset += bm->BytesPerRow;
					}

					if ( !err )
						gotit = TRUE;
				}
			}
			else
			{
				/* skip this chunk, move on to next chunk */
				ob_Seek(fh,dat[1],OFFSET_CURRENT);
			}
		}
		else err = TRUE;	/* read error */
	}

	/* return to beginning of FORM */
	ob_Seek(fh,oldpos,OFFSET_BEGINNING);

	if ( !gotit && bm )
	{
		FreeIconBM(bm);
		bm = NULL;
	}

	return(bm);
}

ULONG ob_SeekUp2IconsBitMap( APTR fh )
{
	ULONG			retval = 0;

	while ( retval = ob_SeekUp2Form(fh,ID_ILBM) )
	{
		if ( ob_IsGoodIconBM(fh) )
		{
			break;
		}
	}

	return(retval);
}

ULONG ob_Seek2IconsBitMap( APTR fh )
{
	ULONG								retval = 0;

	while ( !retval )
	{
		LONG								len;
		struct FORMHeaderForward	fhf;

		/* Read FORMHeader */
		if ( (len = ob_Read(fh,&fhf,sizeof(fhf))) > 0 )
		{
			/* Is this a 'FORM....ILBM' ? */
			if (	(len == sizeof(fhf)) &&
					(fhf.fh_ID == ID_FORM) &&
					(fhf.fh_type == ID_ILBM) )
			{
				retval = fhf.fh_ID;	/* Just try it */
			}

			/* back to beginning of form */
			ob_Seek(fh,-len,OFFSET_CURRENT);
		}
		else break;

		if ( retval )
		{
			if ( !ob_IsGoodIconBM(fh) )
				retval = NULL;
		}

		if ( !retval )
		{
			if (len == sizeof(fhf))
			{
				/* Seek to next FORM */
				ob_Seek(fh,fhf.fh_len + sizeof(struct FORMHeader),OFFSET_CURRENT);
			}
			else break;
		}
	}

	return(retval);
}

ULONG ob_IsGoodIconBM( APTR fh )
{
	ULONG				retval = 0;
	ULONG				len;
	BitMapHeader	bmh;

	/* seek past [FORM....ILBMBMHD....] */

	ob_Seek(fh,5*sizeof(ULONG),OFFSET_CURRENT);
	
	if ( (len = ob_Read(fh,&bmh,sizeof(bmh))) == sizeof(bmh) )
	{
		if (	(bmh.w == CROUTON_WIDTH) &&
				(bmh.h == CROUTON_HEIGHT) &&
				(bmh.compression == cmpNone) )
		{
			if (	(bmh.nPlanes == 3) ||
					((AAMachine) ? (bmh.nPlanes == 6) : (bmh.nPlanes == 2)) )
			{
				retval = TRUE;
			}
		}
	}

	/* Seek back to beginning of the FORM */
	ob_Seek(fh,-((5*sizeof(ULONG))+len),OFFSET_CURRENT);

	return(retval);
}

ULONG ob_SeekUp2Form( APTR fh, ULONG form_id )
{
	ULONG					retval = 0;

	while ( retval = ob_SeekPrevForm(fh) )
	{
		/* retval now == the form id */

		if ( retval == form_id )
		{
			break;	/* just return form_id */
		}
	}

	return(retval);
}
#endif /* ICONFILE_WRITE_ONLY */

ULONG ob_SeekPrevForm( APTR fh )
{
	ULONG					formtype = 0;

	struct PUSChunk	pc;

	/* Seek back one PUS chunk size */
	if ( ((LONG)ob_Seek(fh,-sizeof(pc),OFFSET_CURRENT)) >= 0 )
	{
		/* Read it */
		if ( ob_Read(fh,&pc,sizeof(pc)) == sizeof(pc) )
		{
			/* Is this is a ' PUS' chunk ? */
			if ( (pc.pc_fh.fh_ID == ID_FORM) && (pc.pc_ID == ID_PUS) )
			{
				LONG				offset;

				/* how far (with direction) do we want to seek */
				offset = -(pc.pc_prevlen+sizeof(pc)+sizeof(struct FORMHeader));

				/* Seek back to previous FORM */
				if ( ((LONG)ob_Seek(fh,offset,OFFSET_CURRENT)) >= 0 )
				{
					/* return previous FORM ID */
					formtype = pc.pc_prevID;
				}
			}
		}
	}

	/* Return what type of FORM the pus chunk said this was. */
	return(formtype);
}

ULONG ob_SeekNextForm( APTR fh )
{
	ULONG								formtype = 0;
	LONG								len;
	struct FORMHeaderForward	fhf;

	/* Read it */
	if ( (len = ob_Read(fh,&fhf,sizeof(fhf))) == sizeof(fhf) )
	{
		/* Is this a 'FORM' ? */
		if ( fhf.fh_ID == ID_FORM )
		{
			/* return this FORM ID */
			formtype = fhf.fh_type;
		}
	}

	if ( len > 0 )
	{
		/* seek back to beginning of the FORM */
		ob_Seek(fh,-len,OFFSET_CURRENT);
	}

	/* Return what type of FORM the pus chunk said this was. */
	return(formtype);
}

#ifdef BUILD_ICONFILE

struct IconBuildHeader
{
	struct MinList				ibh_lh;
	struct IconFileHeader	ibh_ifh;
};

struct IconBuildNode
{
	struct MinNode			ibn_mn;

	char						ibn_filename[32];

	LONG						ibn_filepos;

	struct IconFileEntry	ibn_ife;
};

LONG BuildIconFile( STRPTR dirname )
{
	LONG							result = 0;
	BPTR							dirlock;
	struct IconBuildHeader	ibh;

	NewList( (struct List *) &ibh.ibh_lh );
	ibh.ibh_ifh.ifh_ID = ICONFILE_ID;
	ibh.ibh_ifh.ifh_version = ICONFILE_VERSION;
	ibh.ibh_ifh.ifh_numentries = 0;

	if (dirlock = Lock(dirname,ACCESS_READ))
	{
		struct FileInfoBlock		*fib;

		if (fib = AllocMem(sizeof(struct FileInfoBlock),MEMF_PUBLIC|MEMF_CLEAR))
		{
			if (Examine(dirlock, fib))
			{
				if (fib->fib_DirEntryType >= 0)
				{
					BPTR				olddir;

					result = TRUE;

					olddir = CurrentDir(dirlock);

					while (ExNext(dirlock,fib))
					{
						if ( IsCroutonFile(fib) )
						{
							struct IconBuildNode	*ibn;

							if ( ibn = (struct IconBuildNode	*)ob_AllocMemObj(ClassBase->cb_allocator_ob,sizeof(*ibn)) )
							{
								strcpy(ibn->ibn_ife.ife_filename,fib->fib_FileName);
								ibn->ibn_ife.ife_gn_filesize = fib->fib_Size;
								ibn->ibn_ife.ife_gn_protection = fib->fib_Protection;
								ibn->ibn_ife.ife_gn_ds = fib->fib_Date;

								if (fib->fib_DirEntryType >= 0)
								{
									ibn->ibn_ife.ife_gn_dosclass = EN_DIRECTORY;
									ibn->ibn_ife.ife_cr_type = CT_DIR;
									ibn->ibn_ife.ife_gn_type = CRuDToCR(CT_DIR);
								}
								else
								{
									ibn->ibn_ife.ife_gn_dosclass = EN_FILE;
								}

								ibn_GetCroutonInfo( ibn );

								// Now, add the item to the list
								ibh.ibh_ifh.ifh_numentries++;
								AddTail( (struct List *) &ibh.ibh_lh, (struct Node *) ibn );
							}
							else
							{
								result = FALSE;
								break;
							}
						}
					}

					if ( result )
					{
						APTR				ifh;

						/* Write out the ".allicons" file in this directory */
						if ( ifh = ob_NewObject( NULL,STREAMBUFFERCLASS,
											STMBUFA_BufSize,	(1024 * 4),
											STMBUFA_StmClassName, FILESTREAMCLASS,
											FSTMA_FileName,	ICONFILE_NAME,
											FSTMA_OpenMode,	MODE_NEWFILE,
											TAG_DONE) )
						{
							if ( WriteIconFile(&ibh,ifh) )
							{
								result = FALSE;
							}

							ob_Dispose(ifh);
						}

						if ( !result )
						{
							DeleteFile(ICONFILE_NAME);
						}
					}

					CurrentDir(olddir);

				}	// is a directory

			} // examine

			FreeMem(fib,sizeof(*fib));
		} // alloc mem

		UnLock(dirlock);
	}

	/* No conditions, just free the directory list */
	{
		struct Node	*node;

		/* free entries in reverse order to reduce fragmentation */
		while ( node = RemTail((struct List *) &ibh.ibh_lh) )
		{
			ob_Dispose(node);
		}
	}

	return(result);
}

LONG WriteIconFile( struct IconBuildHeader *ibh, APTR fh )
{
	LONG			err = 0;		/* This function returns an error!!!! */

	/* Write the header */
	if ( ob_Write(fh,&ibh->ibh_ifh,sizeof(struct IconFileHeader)) == sizeof(struct IconFileHeader) )
	{
		struct IconBuildNode	*ibn;
		LONG						 offset;

		offset = sizeof(struct IconFileHeader) +
					(sizeof(struct IconFileEntry) * ibh->ibh_ifh.ifh_numentries);

		/* We need to pre-compute the file offsets that will be written to disk */
		for ( ibn = (struct IconBuildNode *)ibh->ibh_lh.mlh_Head;
				ibn->ibn_mn.mln_Succ;
				ibn = (struct IconBuildNode *)ibn->ibn_mn.mln_Succ )
		{
			if ( ibn->ibn_ife.ife_cr_size )
			{
				/* offset withing large icon file */
				ibn->ibn_ife.ife_cr_offset = offset;
				offset += ibn->ibn_ife.ife_cr_size;
			}
		}

		/* Now, write all of the struct IconFileEntry's to disk */
		for ( ibn = (struct IconBuildNode *)ibh->ibh_lh.mlh_Head;
				ibn->ibn_mn.mln_Succ;
				ibn = (struct IconBuildNode *)ibn->ibn_mn.mln_Succ )
		{
			if ( ob_Write(fh,&ibn->ibn_ife,sizeof(ibn->ibn_ife)) != sizeof(ibn->ibn_ife) )
			{
				err = TRUE;
				break;
			}
		}

		if ( !err )
		{
			/* concatenate all of the extracted ".I" files to this file */
			for ( ibn = (struct IconBuildNode *)ibh->ibh_lh.mlh_Head;
					ibn->ibn_mn.mln_Succ;
					ibn = (struct IconBuildNode *)ibn->ibn_mn.mln_Succ )
			{
				/* There was some crud in this file */
				if ( ibn->ibn_ife.ife_cr_size )
				{
					APTR			buf;

					if ( buf = (APTR)ob_AllocMemObj(ClassBase->cb_allocator_ob,ibn->ibn_ife.ife_cr_size) )
					{
						APTR			icon_fh;

						/* ibn_filename will either be the source file or the ".i" file */

						if ( icon_fh = ob_NewObject( NULL,FILESTREAMCLASS,
											FSTMA_FileName, ibn->ibn_filename,
											TAG_DONE) )
						{
							ob_Seek(icon_fh,ibn->ibn_filepos,OFFSET_BEGINNING);

							/* Read into the buffer */
							if ( ob_Read(icon_fh,buf,ibn->ibn_ife.ife_cr_size) == ibn->ibn_ife.ife_cr_size )
							{
								/* concatenate on to the iconfile */
								if ( ob_Write(fh,buf,ibn->ibn_ife.ife_cr_size) != ibn->ibn_ife.ife_cr_size )
									err = TRUE;
							}
							else err = TRUE;

							ob_Dispose(icon_fh);
						}
						else err = TRUE;

						ob_Dispose(buf);
					}
					else err = TRUE;
				}

				if ( err ) break;
			}
		}
		
		if ( !err )
		{
			/* Write out a pad to prevent this file from being
			 *	parsed backwards via the " PUS" chunk of the last
			 * included ".i" file.
			 */

			/* This pad could be anything, but this time it's a ULONG
			 * that will contain the "IALL" longword in the header
			 */
			if ( ob_Write(fh,&ibh->ibh_ifh,sizeof(ULONG)) != sizeof(ULONG) )
			{
				err = TRUE;
			}
		}
	}
	else err = TRUE;

	return(err);
}

LONG IsCroutonFile( struct FileInfoBlock *fib )
{
	LONG			result = FALSE;
	LONG			len;

	if ( len = strlen(fib->fib_FileName) )
	{
		result = TRUE;

      if (!(stricmp(".i",&fib->fib_FileName[len-2])) )
      	result = FALSE;
		else if ( !(stricmp(".info",&fib->fib_FileName[len-5])) )
			result = FALSE;
	}

	return(result);
}

LONG ibn_GetCroutonInfo( struct IconBuildNode *ibn )
{
	LONG			result = 0;
	APTR			fh;

	/*	Plan of attack
	 *
	 *		A.	Examine the crouton Icon (.i) file, else
	 *		B.	Examine the crouton file, extract the ".i" else
	 *		C.	Use CroutonLib to determine file type,etc.
	 *
	 */

	/* append ".i" to filename */

	strcpy(ibn->ibn_filename,ibn->ibn_ife.ife_filename);
	strcat(ibn->ibn_filename,".i");

	if ( fh = ob_NewObject( NULL, STREAMBUFFERCLASS,
						STMBUFA_BufSize,	1024 * 2,
						STMBUFA_StmClassName, FILESTREAMCLASS,
						FSTMA_FileName, ibn->ibn_filename,
						TAG_DONE) )
	{
		/* parse the ".i" file forwards only */
		ob_Seek(fh,0,OFFSET_BEGINNING);

		if ( ExamineCroutonFile(ibn,fh,1) )
		{
			result = TRUE;
		}

		ob_Dispose(fh);
	}

	/* use original filename */

	if ( !result )
	{
		strcpy(ibn->ibn_filename,ibn->ibn_ife.ife_filename);

		if ( fh = ob_NewObject( NULL, STREAMBUFFERCLASS,
							STMBUFA_BufSize,	1024 * 2,
							STMBUFA_StmClassName, FILESTREAMCLASS,
							FSTMA_FileName, ibn->ibn_filename,
							TAG_DONE) )
		{
			ob_Seek(fh,0,OFFSET_END);

			if ( ExamineCroutonFile(ibn,fh,0) )
			{
				result = TRUE;
			}

			ob_Dispose(fh);
		}
	}

	if ( !result || !ibn->ibn_ife.ife_cr_type )
	{
		// non-zero members won't be filled
		struct CroutonInfo ci={CT_UNSEEN,0,(char *)1, 1, (APTR)1, (struct BitMap *) 1};

		/* see if the crouton library can be of any help */
		GetCroutonInfo(ibn->ibn_ife.ife_filename,&ci);

		if ( ibn->ibn_ife.ife_gn_dosclass != EN_DIRECTORY )
		{
			if ( ci.CroutonType == CT_UNSEEN )
				ibn->ibn_ife.ife_gn_type = CR_UNKNOWN;
			else
				ibn->ibn_ife.ife_gn_type = CRuDToCR(ci.CroutonType);

			ibn->ibn_ife.ife_cr_type = ci.CroutonType;
		}

		/* If we didn't get a bitmap from scanning the file earlier */
		if ( !result )
		{
			ibn->ibn_ife.ife_cr_offset = 0;
			ibn->ibn_ife.ife_cr_size = 0;
			ibn->ibn_ife.ife_flags = IFEF_GETDEFAULT;
		}

		result = TRUE;
	}

	return(result);
}

LONG ExamineCroutonFile( struct IconBuildNode *ibn, APTR fh, LONG direction )
{
	LONG			retval = 0;
	ULONG			type;
	LONG			pos;
	BOOL			found_ilbm = 0;

	pos = ob_Seek(fh,0,OFFSET_CURRENT);

	if ( ibn->ibn_ife.ife_gn_dosclass == EN_DIRECTORY )
	{
		retval = TRUE;
	}

	while ( type = ((direction>0)? ob_SeekNextForm(fh):ob_SeekPrevForm(fh)) )
	{
		BOOL			err = 0;

		if ( type == ID_CrUD )
		{
			LONG			oldpos;
			LONG			dat[2];

			/* seek past [FORM....CrUD] */

			oldpos = ob_Seek(fh,3*sizeof(ULONG),OFFSET_CURRENT);

			while ( !retval && !err )
			{
				/* Read two longs, chunk_id and chunk_len */

				if ( ob_Read(fh,dat,sizeof(dat)) == sizeof(dat) )
				{
					if ( dat[0] == ID_TYPE )
					{
						ULONG			crud[2];

						/* read two longs from the chunk */
						if ( (dat[0] = ob_Read(fh,crud,sizeof(crud))) == sizeof(crud) )
						{
							ibn->ibn_ife.ife_cr_type = crud[0];
							ibn->ibn_ife.ife_gn_type = CRuDToCR(crud[0]);
							retval = TRUE;
						}
						else err = TRUE;

						/* seek to end of chunk (size of chunk - amount read) */
						if ( dat[1] != dat[0] )
							ob_Seek(fh,dat[1]-dat[0],OFFSET_CURRENT);
					}
					else
					{
						/* skip this chunk, move on to next chunk */
						ob_Seek(fh,dat[1],OFFSET_CURRENT);
					}
				}
				else err = TRUE;
			}

			ob_Seek(fh,oldpos,OFFSET_BEGINNING);
		}
		else if ( type == ID_ILBM )
		{
			LONG				oldpos;
			BitMapHeader	bmh;

			/* seek past [FORM....ILBMBMHD....] */

			oldpos = ob_Seek(fh,5*sizeof(ULONG),OFFSET_CURRENT);

			if ( ob_Read(fh,&bmh,sizeof(bmh)) == sizeof(bmh) )
			{
				if (	(bmh.w == CROUTON_WIDTH) &&
						(bmh.h == CROUTON_HEIGHT) &&
						(bmh.compression == cmpNone) )
				{
					/* Does not discern between AA and old chipsets */
					if (	(bmh.nPlanes == 3) ||
							(bmh.nPlanes == 6) ||
							(bmh.nPlanes == 2) )
					{
						found_ilbm = TRUE;
					}
				}
			}

			ob_Seek(fh,oldpos,OFFSET_BEGINNING);
		}

		if ( direction > 0 )
		{
			LONG			dat[2];

			/* Read [FORM....] */

			if ( ob_Read(fh,dat,sizeof(dat)) == sizeof(dat) )
			{
				ob_Seek(fh,dat[1],OFFSET_CURRENT);
			}
			else err = TRUE;
		}

		if (err) break;
	}

	/* get length by seeking to starting position */

	if ( direction > 0 )
	{
		ibn->ibn_filepos = pos;						/* beginning position */
		pos = ob_Seek(fh,pos,OFFSET_CURRENT);	/* ending position */
	}
	else
	{
		ibn->ibn_filepos = ob_Seek(fh,pos,OFFSET_BEGINNING);
	}

	ibn->ibn_ife.ife_cr_size = pos - ibn->ibn_filepos;

	return( retval || found_ilbm );
}

#endif /* BUILD_ICONFILE */
