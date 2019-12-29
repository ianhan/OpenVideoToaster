/********************************************************************
* $Scroll.c$
*
* Copyright c1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
* $Id: scroll.c,v 2.29 1995/06/15 12:35:43 Holt Exp Holt $
* $Log: scroll.c,v $
*Revision 2.29  1995/06/15  12:35:43  Holt
**** empty log message ***
*
*Revision 2.28  1995/06/09  08:50:14  Holt
*changed letter positioning so it uses outlines only unless -shadow
*
*Revision 2.27  1995/06/08  11:16:10  Holt
*FIXED COUNTDOWN RENDER PROBLEM
*
*Revision 2.26  1995/06/07  16:25:17  Holt
*made a lot more twiks on Scrolls and crawls
*
*Revision 2.25  1995/06/05  11:02:32  Holt
*worked on reduceing the cuttoff parts of shadows
*in scrolls
*
*Revision 2.24  1995/06/05  09:25:11  Holt
*extended the MaxY on crawl boarders by Y not to exceed 300.
*
*Revision 2.23  1995/06/02  09:47:17  Holt
*may have fixed shadows and boarders on crawls.
*
*Revision 2.22  1995/06/01  15:07:41  Holt
*more fixes
*
*Revision 2.21  1995/05/19  17:59:40  Holt
*more fixes.
*
*Revision 2.20  1995/05/19  10:00:52  Holt
*some fixes.
*
*Revision 2.19  1995/03/18  00:50:26  pfrench
*Had to write replacement bitmap allocation functions
*for A2000's since they're not running V39
*
*Revision 2.18  1995/03/05  14:38:26  CACHELIN4000
*define out buggy shadows/outlines on scrolls/crawls ... we gotta ship NOW
*
*Revision 2.17  1995/02/28  16:19:00  CACHELIN4000
*Repair rendering glitch in  scroll
*
*Revision 2.16  1995/02/18  14:58:50  CACHELIN4000
**** empty log message ***
*
*Revision 2.15  1995/02/17  09:24:55  CACHELIN4000
**** empty log message ***
*
*Revision 2.13  1995/02/13  17:17:51  Kell
*Added some CopyFast routines for Keyed pages.
*
*Revision 2.12  1995/02/13  14:08:22  CACHELIN4000
**** empty log message ***
*
*Revision 2.11  1995/02/12  16:11:27  CACHELIN4000
**** empty log message ***
*
*Revision 2.10  1995/02/10  18:59:57  CACHELIN4000
**** empty log message ***
*
*Revision 2.9  1995/02/06  17:15:05  Kell
**** empty log message ***
*
*Revision 2.8  1995/02/06  15:15:59  Kell
*New Open/Close, Init/Free stuff for easier coding.
*
*Revision 2.7  1995/02/03  16:23:45  Kell
**** empty log message ***
*
*Revision 2.6  1995/02/01  18:56:00  Kell
**** empty log message ***
*
*Revision 2.5  1995/02/01  17:40:00  Kell
**** empty log message ***
*
*Revision 2.4  1995/02/01  17:31:35  Kell
**** empty log message ***
*
*Revision 2.1  1995/01/31  23:19:36  CACHELIN4000
*Added ClearBitMap...
*
*Revision 2.0  1995/01/31  17:01:14  Kell
*FirstCheckIn
*
*
* Scroll page rules:
*	- Lines can not overlap Y coords
*	- one text face color per Line
*	- shadow and outline are opaque and black
*	- max 640 wide
*
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <dos.h>
#include <stdio.h>
#include <math.h>
#include <libraries/iff.h>

#define SERDEBUG	1
#include <serialdebug.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <proto/intuition.h>
#include "crlib:libinc/crouton_all.h"

#include "movepage.h"

#ifndef PROTO_PASS
#include "sw:proto/Scroll.p"
#include "sw:proto/NewCrawl.p"

//*************************************************************
struct BitMap *wiener_AllocBitMap(
	ULONG w, ULONG h, ULONG d, ULONG flags, struct BitMap *friend );

UWORD DAVID;

VOID wiener_FreeBitMap(struct BitMap *bm);

UBYTE *__asm WordAfterPlanes(
	register __a0 struct BitMap *BM);

ULONG __asm CopyLongBlock2(
	register __a0 struct BitMap *SourceBitMap,
	register	__a1 struct BitMap *DestinationBitMap,
	register	__d0 UWORD X1,
	register	__d1 UWORD Y1,
	register	__d2 UWORD Width,
	register	__d3 UWORD Height);

BOOL __asm ORIntoMS(
	register __a0 struct BitMap *BitMap,
	register __a1 struct Rectangle *Rect);

VOID __asm DoBMOutline(
	register __a0 struct BitMap *SourceBM,
	register __a1 struct Rectangle *SourceRect,
	register __a2 struct BitMap *DestBM,
	register __d0 WORD DestMinX,
	register __d1 WORD DestMinY,
	register __d2 UWORD OutlineType);


VOID *__asm RoundLW2(
	register __d0 VOID *address );

VOID __asm ByteFillMemory(
	register __a0 UBYTE *MemBlock,
	register __d0 BYTE FillValue,
	register __d1 ULONG MemSize);

BOOL __asm ScrollPage(VOID);
BOOL __asm CrawlPage(VOID);

#endif
//*************************************************************

//#ifdef PROTO_PASS
//#include "crlib:libinc/crouton_all.h"
//#endif

VOID WaitButton(VOID);

extern struct Gadget *CurrentBottomList, *AllGadgets[];

extern UBYTE *ToastChipMem, *ToastFastMem;

struct RenderData OurRenderData;
struct MovePage	*CurrentMovePage=NULL;

//**********************
// 2.0 Shadow/Outline info
//WORD ShadowDX[] = { 0,1,1,1,0,-1,-1,-1 };
//WORD ShadowDY[] = {-1,-1,0,1,1,1,0,-1 };

// 3.0 Shadow/Outline info
WORD ShadowDX[] = { 0,-1,-1,-1,0,1,1,1 };
WORD ShadowDY[] = { 1,1,0,-1,-1,-1,0,1 };

// Outline matrices are in a 1.17 ratio so they appear of
// uniform width on all sides of text
struct OutlineStuff Outlines[] = {
	{ 0,0,0,0 },
	{ 4,2,8,4 },
	{ 4,2,8,4 },
	{ 8,4,16,8 }
};		// { 8,4,15,8 }


// Letter->Flags : bottom 2 BITS = OL type, next 2 Shad type, next shad pri,
// next 3 dir, next 3 len

#define	BUGGY_OS	1
#define	OL		0x00000003
#define	STYP		0x0000000C
#define	SPRI		0x00000010
#define	SDIR		0x000000E0
#define	SLEN		0x00000F00	// changed from x00000700
#define	OLMASK		~OL
#define	STYPMASK	~STYP
#define	SPRIMASK	~SPRI
#define	SDIRMASK	~SDIR
#define	SLENMASK	~SLEN
#define SET_OLTYPE(flags,type)		(flags=((flags&OLMASK	) | type))
#define SET_SHADTYPE(flags,type)	(flags=((flags&STYPMASK) | (type<<2) ))
#define SET_SHADPRI(flags,type)		(flags=((flags&SPRIMASK) | (type<<4) ))
#define SET_SHADDIR(flags,type)		(flags=((flags&SDIRMASK) | (type<<5) ))
#define SET_SHADLEN(flags,type)		(flags=((flags&SLENMASK) | (type<<8) ))
#define OLTYPE(flags)		(flags&OL	)
#define SHADTYPE(flags)	((flags&STYP)>>2)
#define SHADPRI(flags)	((flags&SPRI)>>4)
#define SHADDIR(flags)	((flags&SDIR)>>5)
#define SHADLEN(flags)	((flags&SLEN)>>8) //8
#define REL_XPOS	0x80000000 // use letter XPosition as relative to last one



struct ScrollInfo *SI = NULL;
struct BitMap *ScrollTextA, *ScrollTextB,*ScrollBM;
UBYTE *AfterScroll,num=0;

#ifdef SERDEBUG
UBYTE	namebuff[100];
#endif

struct Library *IFFBase;
struct Library *LayersBase;
extern struct GfxBase *GfxBase;

LONG	OpenCount=0;

/****** NewScroll/ClearYBlock ***************************************
*
*   NAME
*	ClearYBlock
*
*   SYNOPSIS
*	VOID __asm ClearYBlock(
*		register __a0 struct BitMap *BM,
*		register __d0 UWORD MinY,
*		register __d1 UWORD MaxY)
*
*   FUNCTION
*		Calls BltClear() to clear MinY to MaxY of bitmap
*
********************************************************************/
VOID __asm ClearYBlock(
	register __a0 struct BitMap *BM,
	register __d0 UWORD MinY,
	register __d1 UWORD MaxY)
{
	UWORD A;
	ULONG StartOffset,ClearSize;

	StartOffset = BM->BytesPerRow * MinY;
	ClearSize = (ULONG)(BM->BytesPerRow * (MaxY - MinY + 1));
	for (A = 0; A < BM->Depth; A++)
		BltClear(BM->Planes[A] + StartOffset,ClearSize,0);
	WaitBlit();
}



/****** NewSupport/ClearBitMap ***************************************
*
*   NAME
*	ClearBitMap
*
*   SYNOPSIS
*	VOID __asm ClearBitMap(
*		register __a0 struct BitMap *BitMap)
*
*   FUNCTION
*		clear bitmap with CPU
*
*********************************************************************/
VOID __asm ClearBitMap(
	register __a0 struct BitMap *BitMap)
{
	UWORD A;
	ULONG PlaneSize;

	PlaneSize = BitMap->BytesPerRow * BitMap->Rows;
	for (A = 0; A < BitMap->Depth; A++)
		ByteFillMemory(BitMap->Planes[A],0,PlaneSize);
}


/****** NewScroll/RenderScrollLine **********************************
*
*   NAME
*	RenderScrollLine
*
*   SYNOPSIS
*	BOOL __asm RenderScrollLine(
*		register __a0 struct MovePage *Page,
*		register __a2 struct BitMap *DestBM,
*
*   FUNCTION
*		Renders face in planes 0,1, Out&Shad in plane 2
*		if InterfaceOnly, just does face
*
********************************************************************/
BOOL __asm RenderScrollLine(
	register __a0 struct MovePage *Page,
	register __a2 struct BitMap *DestBM)
{
	register struct ScrollInfo *S;
	struct Rectangle FaceRect;

	S = SI;

	if (!DestBM)
		DestBM = S->ScrollTextA;

	FaceRect.MinX = 0; // flag that first DO_FACE

	if(Page)
	   DoMPLine(DestBM,&FaceRect,S->SrcFakeBM,Page);

	WaitBlit();

	return(TRUE);
}

/****** NewScroll/InitScrollRenderer ********************************
*
*   NAME
*	InitScrollRenderer
*
*   SYNOPSIS
*	BOOL __asm InitScrollRenderer(
*		register __a0 UBYTE *ChipMem,
*		register __a1 struct BitMap *TempChar,
*		register __a2 struct BitMap *CharAlpha)
*
*   FUNCTION
*		Readies scroll rendering engine
*
* THIS MAY BE CALLED MORE THAN ONCE
********************************************************************/
BOOL __asm InitScrollRenderer(
	register __a0 UBYTE *ChipMem,
	register __a1 struct BitMap *TempChar,
	register __a2 struct BitMap *CharAlpha)
{
	register struct ScrollInfo *S;

	if(!SI)
	{
	 if(SI = SafeAllocMem(sizeof(struct ScrollInfo),MEMF_CLEAR))
    {
		S = SI;

		S->TempChar = TempChar;
		S->CharAlpha = CharAlpha;

		if (S->ScrollTextA = HelpAllocBitMap(SCROLL_WIDTH,SCROLL_RENDER_HEIGHT,
			SCROLL_DEPTH,ChipMem,FALSE)) {
		ChipMem = WordAfterPlanes(S->ScrollTextA);
		if (S->ScrollTextB = HelpAllocBitMap(SCROLL_WIDTH,SCROLL_RENDER_HEIGHT,
			SCROLL_DEPTH,ChipMem,FALSE)) {
		ChipMem = WordAfterPlanes(S->ScrollTextB);
		if (S->ScrollBM = HelpAllocBitMap(SCROLL_WIDTH,SCROLL_HEIGHT,
			SCROLL_DEPTH,ChipMem,TRUE)) {

		// Fake bitmaps/layers used during shadow/outline rendering
		if (S->SrcFakeBM = HelpAllocBitMap(SCROLL_WIDTH,SCROLL_RENDER_HEIGHT,
			1,TempChar->Planes[0],FALSE)) {
		if (S->DstFakeBM = HelpAllocBitMap(SCROLL_WIDTH,SCROLL_RENDER_HEIGHT,
			1,TempChar->Planes[0],FALSE)) {

		ScrollTextA = S->ScrollTextA;
		ScrollTextB = S->ScrollTextB;
		ScrollBM = S->ScrollBM;

		AfterScroll = WordAfterPlanes(S->ScrollBM);

		return(TRUE);
		} } } } }

		FreeScrollRenderer();
	}

	return(FALSE);

  }
  else return(TRUE);
}

//*******************************************************************
// Layers opened/closed seperately because cleared with blitter
//
BOOL __asm OpenScrollLayers(VOID)
{
	BOOL Success = FALSE;
	register struct ScrollInfo *S;

	S = SI;
	if ((S->FakeLayerInfo = NewLayerInfo()) &&
		(S->FakeLayer = CreateUpfrontLayer(S->FakeLayerInfo,S->DstFakeBM,
		0,0,SCROLL_WIDTH-1,SCROLL_HEIGHT-1,LAYERSIMPLE,
		(struct BitMap *)NULL))) {

		Success = TRUE;
	}
	return(Success);
}

//*******************************************************************
VOID __asm CloseScrollLayers(VOID)
{
	register struct ScrollInfo *S;

	S = SI;
	S->FakeLayer->rp->BitMap->Planes[0] = S->TempChar->Planes[0];
	if (S->FakeLayer) {
		DeleteLayer(NULL,S->FakeLayer);
		S->FakeLayer = NULL;
	}
	if (S->FakeLayerInfo) {
		DisposeLayerInfo(S->FakeLayerInfo);
		S->FakeLayerInfo = NULL;
	}
	WaitBlit(); // DeleteLayer clears bitmap
}

/****** NewScroll/FreeScrollRenderer ********************************
*
*   NAME
*	FreeScrollRenderer
*
*   SYNOPSIS
*	VOID __asm FreeScrollRenderer(VOID)
*
*   FUNCTION
*		Frees scroll rendering engine
*
* THIS MAY BE CALLED MORE THAN ONCE
********************************************************************/
VOID __asm FreeScrollRenderer(VOID)
{
	register struct ScrollInfo *S;

	if (S = SI) {
		HelpFreeBitMap(S->DstFakeBM);
		HelpFreeBitMap(S->SrcFakeBM);
		HelpFreeBitMap(S->ScrollBM);
		HelpFreeBitMap(S->ScrollTextB);
		HelpFreeBitMap(S->ScrollTextA);

		FreeMem(S,sizeof(struct ScrollInfo));

		SI = NULL;
	}
}

// All open or none will be open.
BOOL	__asm OpenScrawlLibs()
{
	if(!IFFBase)
		if(!(IFFBase = OpenLibrary(IFFNAME,IFFVERSION)))
			return(FALSE);

	if(!LayersBase)
		if(!(LayersBase = OpenLibrary("layers.library",36L)))
	{
			CloseScrawlLibs();		//close the ones that did open
			return(FALSE);
	}

	return(TRUE);
}

void	__asm CloseScrawlLibs()
{
	if(IFFBase) CloseLibrary(IFFBase);
	IFFBase=NULL;

	if(LayersBase) CloseLibrary(LayersBase);
	LayersBase=NULL;
}

//#define	CHIP_BM
struct BitMap	*LoadBitMap(char *file)
{
	struct IFFL_BMHD *bmhd;
	ULONG *iff_file;
	UWORD w,h,d;
	struct BitMap	*bm;
	if(!(iff_file=IFFL_OpenIFF(file,IFFL_MODE_READ))) return(NULL);
	if(iff_file[2]==ID_ILBM || iff_file[2]==ID_ANIM )
	{
		if((bmhd=IFFL_GetBMHD(iff_file)))
		{
			w=bmhd->w; h=bmhd->h; d=bmhd->nPlanes;
#ifdef	CHIP_BM
			if(bm=wiener_AllocBitMap(w,h,d,BMF_CLEAR,NULL))
#else
			if(bm=AllocFastBitMap(w,h,d))
#endif
			{
#ifdef SERDEBUGger
				sprintf(namebuff,"Got BitMap: %d x %d x %d ",w,h,d);
				DUMPMSG(namebuff);
#endif
				if(IFFL_DecodePic(iff_file,bm))
				{
					IFFL_CloseIFF(iff_file);
					return(bm);
				}
				FreeFastBitMap(bm);
			}
		}
	}
	IFFL_CloseIFF(iff_file);
	return(NULL);
}

void FreeMovePage(struct MovePage *MP)
{
	if(MP)
	{
		DUMPUDECL("Free MP->Glyphs: ",MP->GlyphNum*sizeof(struct Glyph)," bytes\\");
		DUMPHEXIL("    @         : ",(LONG)MP->Glyphs,"\\");
		if(MP->Glyphs)	FreeMem(MP->Glyphs,	MP->GlyphNum*sizeof(struct Glyph));

		DUMPUDECL("Free MP->Letters: ",MP->CharNum*sizeof(struct Letter)," bytes\\");
		DUMPHEXIL("    @         : ",(LONG)MP->Letters,"\\");
		if(MP->Letters) FreeMem(MP->Letters,	MP->CharNum*sizeof(struct Letter));

		DUMPUDECL("Free MP->Lines: ",MP->LineNum*sizeof(struct MPLine)," bytes");
		DUMPUDECL("	 	",MP->LineNum," Lines\\");
		DUMPHEXIL("    @         : ",(LONG)MP->Lines,"\\");
		if(MP->Lines)	 FreeMem(MP->Lines,MP->LineNum*sizeof(struct MPLine));

		DUMPUDECL("Free MP->GBM: ",sizeof(struct BitMap)," bytes\\");
		DUMPHEXIL("    @       : ",(LONG)MP->GBM,"\\");
#ifdef	CHIP_BM
		if(MP->GBM) wiener_FreeBitMap(MP->GBM);
#else
		if(MP->GBM) FreeFastBitMap(MP->GBM);
#endif
		if(MP->tmpBM) wiener_FreeBitMap(MP->tmpBM);

		DUMPUDECL("Free MP: ",sizeof(struct MovePage)," bytes\\");
		FreeMem(MP,sizeof(struct MovePage));
		MP=NULL;
	}
}

// ********************************************************************
// Allocates and fills  MovePage from file (already opened and positioned)
struct MovePage *ReadMP(struct BufferLock *LB)
{
	struct MovePage *MP;
	if (!LB->File) return(NULL);
	if(!(MP=SafeAllocMem(sizeof(struct MovePage), MEMF_CLEAR))) return(NULL);

	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP,sizeof(struct MovePage))) goto Failure;
	if(!(MP->Glyphs = (struct Glyph *)	SafeAllocMem(MP->GlyphNum*sizeof(struct Glyph),MEMF_CLEAR))) goto Failure;
	if(!(MP->Letters = (struct Letter *)SafeAllocMem(MP->CharNum*sizeof(struct Letter),MEMF_CLEAR))) goto Failure;
	if(!(MP->Lines = (struct MPLine *)	SafeAllocMem(MP->LineNum*sizeof(struct MPLine), MEMF_CLEAR))) goto Failure;

	if(CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP->Glyphs ,MP->GlyphNum*sizeof(struct Glyph) )) goto Failure;
	if(CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP->Letters,MP->CharNum*sizeof(struct Letter) )) goto Failure;
	if(CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP->Lines	,MP->LineNum*sizeof(struct MPLine) )) goto Failure;
	MP->GBM = NULL;
	MP->tmpBM = NULL;

	DUMPHEXIL("MP @ ",(LONG)MP," = { ");
	DUMPUDECW("GlyphNum=",MP->GlyphNum,", ");
	DUMPUDECW("CharNum=",MP->CharNum,", ");
	DUMPUDECW("LineNum=",MP->LineNum,"}\\ ");

	return(MP);

Failure:	// OK so i created a goto...  i feel dirty, but look at InitMovePage()..
	DUMPMSG("LOAD MOVEPAGE FAILED FREEING MP STRUCT");
	FreeMovePage(MP);
	return(NULL);
}

#define PUSS	  0x20505553  //  PUS  = Parse Upwards Search Structure
#define FORM	  0x464F524D  // FORM
#define ILBM	  0x494C424D  // ILBM
#define MVPG	  0x4D565047  // MVPG

struct MovePage *LoadMovePage(char *file)
{
	struct MovePage *MP=NULL;
	struct BufferLock *LB;
	ULONG		Buff[8]={0,0,0,0,0,0,0,0};

	if ((LB = BufferOpen(file,MODE_OLDFILE,60024,NULL)))
	{
		if( (CR_ERR_NONE==BufferRead(LB,(UBYTE *)Buff,12)) && (Buff[0]==FORM) )
		{
			while(Buff[2]!=MVPG)
			{
				DUMPHEXIL("MPChunk: ",Buff[0],"  { ");
				DUMPSTR((UBYTE *)Buff);
				DUMPUDECL(" }  Size: ",Buff[1],"  ");
				DUMPHEXIL("Type: ",Buff[2],"   ");
				DUMPMSG((UBYTE *)&(Buff[2]));
				BufferSeek( LB, Buff[1]-4, OFFSET_CURRENT );		// Skip chunk
				if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,12)) break;
			}
			MP=ReadMP(LB);

#ifdef SERDEBUG
			if( MP ) ShowGlyphList(MP);
#endif
		}
		BufferClose(LB);
		if( MP )
		{
			if(MP->GBM=LoadBitMap(file))
			{
				DUMPHEXIL(" MP->GBM ",(LONG)MP->GBM," \\");
				if(MP->tmpBM = wiener_AllocBitMap(MP->W+63,MP->H,MP->GBM->Depth,BMF_CLEAR,NULL))
				{
					DUMPMSG("Return MP...");
					return(MP);
				}
			}
		}
		DUMPMSG("FAILED TO LOAD MP");
		FreeMovePage(MP);	//this on failure
	}
	return(NULL);
}

struct BitMap *wiener_AllocBitMap(
	ULONG w, ULONG h, ULONG d, ULONG flags, struct BitMap *friend )
{
	struct	BitMap *bm;
	BOOL	ok = FALSE;

	if ( bm = SafeAllocMem( sizeof(*bm),MEMF_CLEAR) )
	{
		ULONG			planesize;

		// planesize = RASSIZE(w,h);

		w = ((w + 15)>>4)<< 1;
		planesize = w * h;

#ifdef SERDEBUGger
		sprintf(namebuff,"W,H: %d %d",w,h);
		DUMPSTR(namebuff);
#endif

		if ( bm->Planes[0] = SafeAllocMem(planesize * d,MEMF_CHIP|MEMF_CLEAR) )
		{
			PLANEPTR			*pp = &bm->Planes[1];
			LONG				 p_offset = planesize;

			bm->BytesPerRow = w;
			bm->Rows = h;
			bm->Depth = d;

			/* Fill out all the plane ptrs */
			while ( --d )
			{
				*pp = (PLANEPTR) ((char *)bm->Planes[0] + p_offset);
				pp++;
				p_offset += planesize;
			}

			ok = TRUE;
		}

		if ( !ok )
		{
			FreeMem(bm,sizeof(*bm));
			bm = NULL;
		}
	}

	return(bm);
}

VOID wiener_FreeBitMap(struct BitMap *bm)
{
	if ( bm )
	{
		if ( bm->Planes[0] )
		{
			ULONG			planesize;

			planesize = bm->BytesPerRow * bm->Rows;


			FreeMem( bm->Planes[0], planesize * bm->Depth );
		}

		FreeMem(bm,sizeof(*bm));
	}
}

#ifdef asdfg
void	ShowMovePage(struct MovePage *MP, struct BitMap *dbm)
{
	struct Rectangle rectum;
	struct BitMap	*tmp;
	DUMPMSG("ShowMovePage");

	if(tmp=wiener_AllocBitMap( (dbm->BytesPerRow)<<3,dbm->Rows,1,BMF_CLEAR,NULL ))
	{
		for( MP->CurLine=0, MP->CurChar=0; MP->CurLine<MP->LineNum; MP->CurLine++)
			DoMPLine(dbm,&rectum,tmp,MP);
		MP->CurLine=0;
		MP->CurChar=0;
		wiener_FreeBitMap(tmp);
	}
}
#endif


// render current char into destBM, return dx for new X <<< USED BY 
UWORD RenderMPChar(struct BitMap *DestBM, struct MovePage *MP, WORD X, WORD Y)
{
	struct BitMap *tbm = MP->tmpBM;
 	struct BitMap FBM1,FBM2;
	struct Letter *let;
	struct Glyph	*gly;
	int    dx;
	struct Rectangle Face,Out,Shad;
	UWORD	W=0;
	char letter[3]="  ";

// create the forground plane.
//	FBM1 = *tbm;

//	FBM2.BytesPerRow = tbm->BytesPerRow;
//	FBM2.Rows = tbm->Rows;
//	FBM2.Flags = tbm->Flags;
//	FBM2.Depth = 1;
//	FBM2.Planes[0] = tbm->Planes[0];
//	FBM2.Planes[1] = tbm->Planes[1];

	FBM2.BytesPerRow = DestBM->BytesPerRow;
	FBM2.Rows = DestBM->Rows;
	FBM2.Flags = DestBM->Flags;
	FBM2.Depth = 1;
	FBM2.Planes[0] = DestBM->Planes[1] ;


// create the background plane.
//	FBM2 = *DestBM;
        
	FBM1.BytesPerRow = DestBM->BytesPerRow;
	FBM1.Rows = DestBM->Rows;
	FBM1.Flags = DestBM->Flags;
	FBM1.Depth = 1;
	FBM1.Planes[0] = DestBM->Planes[2] ;

/*
	DUMPHEXIL("MP @ ",(LONG)MP," = { ");
	DUMPSDECL("GlyphNum=",MP->GlyphNum,", ");
	DUMPSDECL("CharNum=",MP->CharNum,", ");
	DUMPUDECW("CurChar=",MP->CurChar,",\\ ");
	DUMPHEXIL("Glyphs @",(LONG)MP->Glyphs,", ");
	DUMPHEXIL("Letters @",(LONG)MP->Letters,"\\, ");
	DUMPSDECL("LineNum=",MP->LineNum,", ");
	DUMPUDECW("CurLine=",MP->CurLine,"}\\ ");
*/

	let=&(MP->Letters[MP->CurChar]);
	if( (MP->CurChar<MP->CharNum) && (let->Index<=MP->GlyphNum) )
	{
		
//		if(let->Flags & REL_XPOS) X += let->XPos; // This is for kerning...
		gly = &(MP->Glyphs[let->Index]);
		dx = gly->X&0x001F;	  // last 5 bits offset due to long alignment in Copy LongBlock

/*
#ifdef SERDEBUGger
		sprintf(namebuff,"MP: %08x Let[%d]=%c ",MP,MP->CurChar,gly->Code&0x00ff);
		DUMPMSG(namebuff);
		sprintf(namebuff,"Glyph Index: %d\tFastBlit: %d %d %d %d ",let->Index,gly->X,gly->Y,gly->W,gly->H);
		DUMPMSG(namebuff);
		sprintf(namebuff,"\tLet->XPos= %d\t Actual X= %d ",let->XPos,X);
		DUMPMSG(namebuff);
		DUMPHEXIL("CPU CopyLongBlock2( ",(LONG)MP->GBM," )...\\");
#endif
*/

// Copy the letter to chip ram from fast ram.
//		DUMPMEM("TBM",tbm,64);		//test deh
		CopyLongBlock2(MP->GBM,tbm,gly->X,gly->Y,gly->W,gly->H);
// This is where the actual letter in blited down on the screen.	
// BltBitMap(src,srcx,srcy,dest,destx,desty,w,h,minterm,mask,tempa)
//
//		sprintf(namebuff,"\tx,y w,h, dx %d %d %d %d %d ",X,Y,gly->W,gly->H,dx);
//		DUMPMSG(namebuff);

		BltBitMap(tbm,dx,0,DestBM,X,Y,gly->W,gly->H,0xe0,0x7,NULL); // MinTerm 60 = B&~C + ~B&C, e0=OR


// This does not seem to do anything really.?
//		BltBitMap(DestBM,X,Y,tbm,dx,0,gly->W,gly->H,0x00,0x3,NULL); // MinTerm 00 =Clear?
//
// 		MP->CurChar++;		// dont inc curchar here or last char WW!
		W = gly->W;
		Face.MinX = X;
		Face.MinY = Y;
		Face.MaxX = X+gly->W-1;
		Face.MaxY = gly->H-1;


#ifdef SERDEBUGger
			sprintf(namebuff,"max,min: %d %d %d %d",Face.MinX,Face.MinY,Face.MaxX,Face.MaxY);
			DUMPSTR(namebuff);
#endif
		if(let->Flags & REL_XPOS)
		{
			W += let->XPos;
			letter[0]=(UBYTE)gly->Code&0x00ff;
/*
#ifdef SERDEBUGger
			DUMPSTR(letter);
			DUMPSDECW("W = ",W,"     ");
			DUMPSDECW("gly->W = ",gly->W,"     ");
			DUMPSDECW("let->XPos = ",let->XPos,"\\");
#endif
*/
			if(W==0) W=1;
		}
		WaitBlit();


// test out making shadows and boarders.

	Out.MinX = X;
	Out.MinY = 0;
	Out.MaxX = (X+gly->W-1);
	Out.MaxY - gly->H-1+Y+8;
	if (Out.MaxY > 300) Out.MaxY=300;

	Face.MinX = X;
	Face.MinY = Y;
	Face.MaxX = (X+gly->W-1);
	Face.MaxY = gly->H-1+Y;
	if (Face.MaxY > 300) Face.MaxY=300;


// end of test out making shadows and boarders.
// #ifdef BUGGY_OS
		if( SHADTYPE((MP->Letters[MP->CurChar]).Flags) || OLTYPE((MP->Letters[MP->CurChar]).Flags))
		{
			CalcOSRect((MP->Letters[MP->CurChar]).Flags,&Face,&Shad,&Out); // SO not clipped
//			DUMPMSG("ORIntoMS...");
//			ORIntoMS(DestBM,&Face); // OR into BP 2
			if (OLTYPE((MP->Letters[MP->CurChar]).Flags))
			{
//				DUMPMSG("BlitClear...");
//				BltClear(FBM1.Planes[0],FBM1.BytesPerRow*FBM1.Rows,1);
//				DUMPMSG("DoBMOutline...");
//***!!! NEED THIS.  Commented out because it's messed up!
				DoBMOutline(&FBM2,&Face,&FBM1,Out.MinX,Out.MinY,OLTYPE((MP->Letters[MP->CurChar]).Flags) );

			}
			else
			   BltBitMap(&FBM2,Face.MinX,Face.MinY,&FBM1,Face.MinX,Face.MinY,
			   		(Face.MaxX-Face.MinX+1),(Face.MaxY-Face.MinY+1),
					0xc0,0x1,NULL); //0xc0
			if (SHADTYPE((MP->Letters[MP->CurChar]).Flags))		// make shadow into BP 2
				MakeBMShadow(&FBM2,&Out,&FBM1,&Shad,TRUE,Out.MinX,Out.MinY,(MP->Letters[MP->CurChar]).Flags);
				//MakeBMShadow(&FBM2,&Out,&FBM1,&Shad,TRUE,Out.MinX,Out.MinY,(MP->Letters[MP->CurChar]).Flags);
			   	//BltBitMap(&FBM2,Face.MinX,Face.MinY,&FBM1,Face.MinX,Face.MinY,
				//	(Face.MaxX-Face.MinX+1),(Face.MaxY-Face.MinY+1),
				//	0xe0,0x1,NULL); //0xc0
				
			else
				BltBitMap(&FBM2,Out.MinX,Out.MinY,&FBM1,Out.MinX,Out.MinY,
				(Out.MaxX-Out.MinX+1),(Out.MaxY-Out.MinY+1),0x60,0x1,NULL);

//				BltBitMap(&FBM2,Out.MinX,Out.MinY,&FBM1,Out.MinX,Out.MinY,
//				(Out.MaxX-Out.MinX+1),(Out.MaxY-Out.MinY+1),0xc0,0x1,NULL);
// 		MP->CurChar++;
		}
 		MP->CurChar++;
			

	}
#ifdef SERDEBUGger
				sprintf(namebuff,"W: %d",W);
				DUMPMSG(namebuff);
#endif

	return(W);		// return the width of char.
}


// render current line into destBM
void RenderMPLine(
	struct BitMap *DestBM, // dest chip BM
	struct MovePage *MP,
	struct Rectangle *rect)
{
	struct BitMap *tbm = MP->tmpBM;
	struct Letter *let=&(MP->Letters[MP->CurChar]);
	struct Glyph	*gly;
	int	i;
	UWORD	X=0,dx;
	WORD	Y=0;
	ULONG	flags;
	struct OutlineStuff *OS;


	flags = ((MP->Letters[MP->CurChar]).Flags);

	if ((MP->CurLine<MP->LineNum) && (MP->CurChar<MP->CharNum))
	{
//		Y = 0; //MP->Lines[MP->CurLine].YPos; // 8 needed for the anti-shadows
//		Y = 2; //MP->Lines[MP->CurLine].YPos;
//		Y = 8; //MP->Lines[MP->CurLine].YPos;
//		Y = 7; //MP->Lines[MP->CurLine].YPos;
		DUMPUDECW(" YPos = ",MP->Lines[MP->CurLine].YPos,"\\");
//		    10	

//		Y = (8 - (2*(ShadowDY[SHADDIR((MP->Letters[MP->CurChar]).Flags)] * SHADLEN((MP->Letters[MP->CurChar]).Flags))));
		Y = ((ShadowDY[SHADDIR((MP->Letters[MP->CurChar]).Flags)] * SHADLEN((MP->Letters[MP->CurChar]).Flags)));
	
		DUMPUDECW(" Y = ",Y,"\\");

		if (Y<0)
			Y = -Y;
		else 	
			Y = 0;			
		
		
		OS = &Outlines[OLTYPE(flags)];

		//if (SHADTYPE(flags) == SHADOW_DROP)
		//{
			Y = Y + (OS->LeftHeight)+1;


#ifdef SERDEBUG
			sprintf(namebuff,"Shad,OL: %d %d\t \\",
			(ShadowDY[SHADDIR((MP->Letters[MP->CurChar]).Flags)] * SHADLEN((MP->Letters[MP->CurChar]).Flags)),(OS->LeftHeight));
			DUMPSTR(namebuff);
#endif

		//}
		if (Y < 0) Y = 0; 
		if (Y > 8) Y = 8;

		
		rect->MaxY = 12 + Y + MP->H+((ShadowDY[(SHADDIR((MP->Letters[MP->CurChar]).Flags))] * SHADLEN((MP->Letters[MP->CurChar]).Flags)));
		
		
#ifdef SERDEBUG
			sprintf(namebuff,"Deaming of Y: %d\t \\",Y);
			DUMPSTR(namebuff);
#endif



//
//		if (1 == (ShadowDY[SHADDIR((MP->Letters[MP->CurChar]).Flags)]))
//		    	{Y = 5; //1
//			rect->MaxY = Y + MP->H+10;//
//			}
//		else
//			if (-1 == (ShadowDY[SHADDIR((MP->Letters[MP->CurChar]).Flags)]))	
//		    		{Y = 9;	//9
//				rect->MaxY = Y + MP->H+10;
//				}
//		   	else
//				{Y = 4; //0
//				rect->MaxY = Y + MP->H+8;
//				}

//		(MP->Letters[MP->CurChar]).Flags
		
		rect->MinY = Y;
//		rect->MaxY = Y + MP->H +  // + 10;
		rect->MinX = let->XPos;
		Y%=400;
/*
		DUMPUDECW(" Line # = ",MP->CurLine," ");
		DUMPUDECW(" of ",MP->LineNum," ");
		DUMPUDECW("just ",MP->Lines[MP->CurLine].Length," bytes long at ");
		DUMPUDECW(" Y = ",MP->Lines[MP->CurLine].YPos,"\\");
*/
		for( i=0; (i<MP->Lines[MP->CurLine].Length) && (MP->CurChar<MP->CharNum); i++ )
		{
#ifdef SERDEBUGger
			sprintf(namebuff,"Line: %d\t Xpos: %d \\",MP->CurLine,gly->Code&0x00ff, let->XPos);
			DUMPSTR(namebuff);
#endif
			if(let->Flags & REL_XPOS)
				X += let->XPos;
			else
				X = let->XPos;
			gly = &(MP->Glyphs[let->Index]);
			dx = gly->X&0x001F;	  // last 5 bits offset due to long alignment in Copy LongBlock
/*
#ifdef SERDEBUGger
			sprintf(namebuff,"Line: %d Let[%d]=%c\tIndex: %d\tFastBlit: %d %d %d %d \\",MP->CurLine,MP->CurChar,gly->Code&0x00ff, let->Index,gly->X,gly->Y,gly->W,gly->H);
			DUMPSTR(namebuff);
			sprintf(namebuff,"  ChipBlit: %d 0 TO %d %d ",dx,X,Y);
			DUMPMSG(namebuff);
#endif
*/
			CopyLongBlock2(MP->GBM,tbm,gly->X,gly->Y,gly->W,gly->H);
			BltBitMap(tbm,dx,0,DestBM,X,Y,gly->W,gly->H,0xe0,0x7,NULL); // MinTerm 60 = B&~C + ~B&C
//			BltBitMap(DestBM,X,Y,tbm,dx,0,gly->W,gly->H,0x00,0x3,NULL); // MinTerm 00 =Clear?
			MP->CurChar++;
			let++;
		}
		rect->MaxX = X + gly->W;
		WaitBlit();
/*
#ifdef SERDEBUGger
		sprintf(namebuff,"FaceRect: %d %d %d %d ",rect->MinX,rect->MinY,rect->MaxX,rect->MaxY);
		DUMPMSG(namebuff);
#endif
*/
	}
}

//*************************************************************
// This is called via a FGC_LOAD
// This may be safely called multiple times.
// If this fails, you need not ever call UnLoadScrawl.
BOOL __asm FGC_LoadScrawl(VOID)
{
	if(!OpenCount)
	{
		if(OpenScrawlLibs())
		{
		   if(!InitRenderer(&OurRenderData))	//sets up stuff for both Scrolls & Crawls
			{
				CloseScrawlLibs();	//if any were open
				return(FALSE);
			}
		}
		else return(FALSE);
	}

	OpenCount++;
	return(TRUE);
}

// This is called via a FGC_UNLOAD
// THIS IS ONLY SENT TO CROUTONS THAT HAVE SUCCESSFULLY FGC_LOADed
// This may be safely called multiple times.
VOID __asm FGC_UnloadScrawl(VOID)
{
	OpenCount--;
	if(!OpenCount)
	{
		FreeRenderer(&OurRenderData);
		CloseScrawlLibs();
	}
	else if(OpenCount<0) OpenCount=0;  //protection againest too many UnLoads
}

// This is called via a FGC_SELECT
// This may be safely called multiple times.
BOOL __asm FGC_SelectScrawl(register __a0 char *buf)
{
	if(!CurrentMovePage)
		if(!(CurrentMovePage=LoadMovePage(buf))) return(FALSE);

	return(TRUE);
}

// This is called via a FGC_REMOVE
// This may be safely called multiple times.
VOID __asm FGC_RemoveScrawl(VOID)
{
		if(CurrentMovePage) FreeMovePage(CurrentMovePage);
		CurrentMovePage=NULL;
}

// This is called via a FGC_AUTO (or FGC_TOMAIN)
// This may be safely called multiple times.
VOID __asm FGC_ToMainScroll(VOID)
{
			ScrollPage();
}

// This is called via a FGC_AUTO (or FGC_TOMAIN)
// This may be safely called multiple times.
VOID __asm FGC_ToMainCrawl(VOID)
{
			CrawlPage();
}

//*************************************************************

BOOL __asm TestMPscroll(register __a0 char *buf)
{
	BOOL success=FALSE;

	if(FGC_LoadScrawl())
	{
		if(FGC_SelectScrawl(buf))
		{
			FGC_ToMainScroll();
			FGC_RemoveScrawl();
			success=TRUE;
		}

		FGC_UnloadScrawl();
	}

	return(success);
}


BOOL __asm TestMPcrawl(register __a0 char *buf)
{
	BOOL success=FALSE;

	if(FGC_LoadScrawl())
	{
		if(FGC_SelectScrawl(buf))
		{
			FGC_ToMainCrawl();
			FGC_RemoveScrawl();
			success=TRUE;
		}

		FGC_UnloadScrawl();
	}

	return(success);
}

//************************************************************
BOOL DoMPLine(
	struct BitMap *DestBM,
	struct Rectangle *FaceRect,
	struct BitMap *TempBM,   
	struct MovePage *MP)
{
	struct BitMap FBM=*TempBM,*FakeBM=&FBM;
	PLANEPTR TempBP;
	struct Rectangle ShadRect,OutRect;
	ULONG AtrFlags = (MP->Letters[MP->CurChar]).Flags;

	TempBP = TempBM->Planes[0];


//	MP->H = MP->Lines[MP->CurLine].TotalHeight		//added 111395deh

// always render the line at the top of the DestBM
	ClearYBlock(DestBM,0,MP->H+10);

	if((MP->CurLine>=MP->LineNum) || (MP->CurChar>=MP->CharNum) || (MP->Lines[MP->CurLine].Length<=0) )
		return(FALSE);
// make face in BP 0,1
		
		RenderMPLine(DestBM,MP,FaceRect); // FaceRect clipped

//For Debugging
//		WaitButton();

	CalcOSRect(AtrFlags,FaceRect,&ShadRect,&OutRect); // SO not clipped
#ifdef SERDEBUGger
		sprintf(namebuff,"\tFaceRect: %d %d %d %d ",FaceRect->MinX,FaceRect->MinY,FaceRect->MaxX,FaceRect->MaxY);
		DUMPMSG(namebuff);
		sprintf(namebuff,"\t OutRect: %d %d %d %d ",OutRect.MinX,OutRect.MinY,OutRect.MaxX,OutRect.MaxY);
		DUMPMSG(namebuff);
		sprintf(namebuff,"\tShadRect: %d %d %d %d ",ShadRect.MinX,ShadRect.MinY,ShadRect.MaxX,ShadRect.MaxY);
		DUMPMSG(namebuff);
#endif



#ifdef BUGGY_OS
// if no out/shad, done
	if( SHADTYPE(AtrFlags) || OLTYPE(AtrFlags) )
	{
		BltClear(DestBM->Planes[2],DestBM->BytesPerRow*DestBM->Rows,1);
		BltClear(TempBM->Planes[0],TempBM->BytesPerRow*TempBM->Rows,1);
	   ORIntoMS(DestBM,FaceRect); // OR into BP 2

// make outline into Temp BP
		TempBM->Planes[0] = DestBM->Planes[2];
		FakeBM->Planes[0] = TempBP;
		BltClear(TempBP,TempBM->BytesPerRow*TempBM->Rows,1);
//	DUMPMEM("TempBM",DestBM,50);
//	DUMPMEM("FakeBM",FakeBM,50);
		if (OLTYPE(AtrFlags))
		{
			DUMPUDECL("Outline, MP->H = ",MP->H,"   ");
			BltClear(TempBP,FakeBM->BytesPerRow*FakeBM->Rows,1);
			DUMPUDECL("BM->Rows = ",FakeBM->Rows,"\\");
			//FaceRect->MaxY = 100;
			//OutRect.MaxY = 100;
			//ShadRect.MaxY = 100;

#ifdef SERDEBUGger
		sprintf(namebuff,"\tFaceRect: %d %d %d %d ",FaceRect->MinX,FaceRect->MinY,FaceRect->MaxX,FaceRect->MaxY);
		DUMPMSG(namebuff);
		sprintf(namebuff,"\t OutRect: %d %d %d %d ",OutRect.MinX,OutRect.MinY,OutRect.MaxX,OutRect.MaxY);
		DUMPMSG(namebuff);
		sprintf(namebuff,"\tShadRect: %d %d %d %d ",ShadRect.MinX,ShadRect.MinY,ShadRect.MaxX,ShadRect.MaxY);
		DUMPMSG(namebuff);
		sprintf(namebuff,"\tfakebm: %d %d ",TempBM->Rows,TempBM->BytesPerRow);
		DUMPMSG(namebuff);
	
#endif
			DoBMOutline(TempBM,FaceRect,FakeBM,OutRect.MinX,OutRect.MinY,OLTYPE(AtrFlags));
		}
		else 
			BltBitMap(TempBM,FaceRect->MinX,FaceRect->MinY,
			FakeBM,FaceRect->MinX,FaceRect->MinY,
			(FaceRect->MaxX-FaceRect->MinX),((FaceRect->MaxY-FaceRect->MinY)+20),
			0xc0,0x1,NULL);

// make shadow into BP 2
		TempBM->Planes[0] = TempBP;
		FakeBM->Planes[0] = DestBM->Planes[2];
		if(SHADTYPE(AtrFlags))
		{
			DUMPUDECL("Doing Shadow at y= ",OutRect.MinY,"\\");
			MakeBMShadow(TempBM,&OutRect,FakeBM,&ShadRect,
				          TRUE,OutRect.MinX,OutRect.MinY,AtrFlags);
		} else
			//DUMPUDECL("Doing Shadow at y= ",OutRect.MinY,"\\");
			BltBitMap(TempBM,OutRect.MinX,OutRect.MinY,
			FakeBM,OutRect.MinX,OutRect.MinY,
			(OutRect.MaxX-OutRect.MinX),(OutRect.MaxY-OutRect.MinY)+20,  //+10 +10
			0xc0,0x1,NULL);
	}

//For Debugging
//	WaitButton();

#endif

	WaitBlit();
	return(TRUE);
}

//*******************************************************************
VOID __asm MakeBMShadow(
	register __a0 struct BitMap *SourceBM,
	register __a1 struct Rectangle *SourceRect,
	register __a2 struct BitMap *DestBM,
	register __a3 struct Rectangle *DestRect,
	register __d0 BOOL IncludeFaceInCast, // TRUE when using shadow for outline
					 // and ShadowPriority==TRUE
	register __d1 WORD DestFirstX,
	register __d2 WORD DestFirstY,
	register __d3 ULONG AtrFlags)
{
	WORD W,H,X,Y,DX,DY,A;

	X = DestFirstX;
	Y = DestFirstY;

	W = SourceRect->MaxX-SourceRect->MinX+12;		//1;
	H = SourceRect->MaxY-SourceRect->MinY+12;		//1;
	DX = ShadowDX[SHADDIR(AtrFlags)];
	DY = ShadowDY[SHADDIR(AtrFlags)];

	if (SourceRect->MinY < 0) SourceRect->MinY=0;   // fix for garbage on top

	if (SHADTYPE(AtrFlags) == SHADOW_DROP) {
		for (A = 0; A < SHADLEN(AtrFlags); A++) {
			BltBitMap(SourceBM,SourceRect->MinX,SourceRect->MinY,
				DestBM,X,Y,W,H+20,0xe0,1,NULL);						//0xe0
			X += DX;
			Y += DY;
		}
	} 
		else { // SHADOW_CAST
//CLIPPING SEEMS TO BE HERE!!!! ALLTHOUGH NON OF THE VARABLES HERE HAVE ANY EFFEC
		BltBitMap(SourceBM,SourceRect->MinX,SourceRect->MinY,   //testdeh060795
			DestBM,X+(DX * SHADLEN(AtrFlags)),
				Y+(DY * SHADLEN(AtrFlags)),W,H+20,0xe0,1,NULL);  //0xc0 0x60
		if (IncludeFaceInCast)
			BltBitMap(SourceBM,SourceRect->MinX,SourceRect->MinY,
				DestBM,X,Y,W,H+20,0xe0,1,NULL);						//0xe0
	}
}

//***********************************************
VOID __regargs CalcShad(
	ULONG flags,
	struct Rectangle *Source,
	struct Rectangle *Shadow)
{
	WORD A;

#ifdef SERDEBUGger
		sprintf(namebuff,"FLAGS: %d %d %d %d %d",flags,SHADTYPE(flags),SHADPRI(flags),SHADDIR(flags),SHADLEN(flags));
		DUMPMSG(namebuff);
#endif
	CopyMem(Source,Shadow,sizeof(struct Rectangle));
	if (SHADTYPE(flags)) {
		A = ShadowDY[SHADDIR(flags)] * SHADLEN(flags);
		if (A > 0) Shadow->MaxY += A;
		else if (A < 0) Shadow->MinY += A;
		A = ShadowDX[SHADDIR(flags)] * SHADLEN(flags);
		if (A > 0) Shadow->MaxX += A;
		else if (A < 0) Shadow->MinX += A;
	}
}

//***********************************************
/* VOID __asm CalcOSYMinMax( */
VOID __asm CalcLineOSMinMax(
	register __d0 ULONG flags,
	register __a1 struct Rectangle *Rect)
{
	WORD A;
	struct OutlineStuff *OS;
	WORD TestDX1,TestDX2,TestDY1,TestDY2;

#ifdef SERDEBUGGER
		sprintf(namebuff,"FLAGS: %d %d %d %d %d",flags,SHADTYPE(flags),SHADPRI(flags),SHADDIR(flags),SHADLEN(flags));
		DUMPMSG(namebuff);
#endif

	TestDY1 = TestDY2 = 0;
	TestDX1 = TestDX2 = 0;
	if (SHADTYPE(flags))
	{
		A = ShadowDX[SHADDIR(flags)]; // * SHADLEN(flags); //TEST!!!051095DEH
		//if (A > 0) 
		//	TestDX2 = A;
		//else if (A < 0) 
		//	TestDX1 = A;
		
		A = ShadowDY[SHADDIR(flags)]; // * SHADLEN(flags); //TEST!!!051095DEH
		if (A > 0) 
			TestDY2 = A;
		else if (A < 0) 
			TestDY1 = A;

	}
	if (OLTYPE(flags))
	{
		OS = &Outlines[OLTYPE(flags)];   
		//TestDX1 -= OS->LeftWidth;	
		//TestDX2 += (OS->TotalWidth-OS->LeftWidth); 
		TestDY1 -= OS->LeftHeight;	
		TestDY2 += (OS->TotalHeight-OS->LeftHeight); 
	}

	Rect->MinX = TestDX1;   //test DEH
	Rect->MaxX = TestDX2;   //test DEH
	Rect->MinY = TestDY1;   //test DEH
	Rect->MaxY = TestDY2+10;   //test DEH

#ifdef SERDEBUGger
		sprintf(namebuff,"stuff: %d %d %d %d",TestDX1, TestDX2, OS->TotalWidth, OS->LeftWidth);
		DUMPMSG(namebuff);
#endif


}

VOID __regargs CalcOL(
	ULONG flags,
	struct Rectangle *Source,
	struct Rectangle *Outline)
{
	struct OutlineStuff *OS;

	CopyMem(Source,Outline,sizeof(struct Rectangle));
	if (OLTYPE(flags)) {
		OS = &Outlines[OLTYPE(flags)];
		Outline->MinX -= OS->LeftWidth;
		Outline->MinY -= OS->LeftHeight;
		Outline->MaxX += (OS->TotalWidth-OS->LeftWidth);
		Outline->MaxY += (OS->TotalHeight-OS->LeftHeight)+4;
	}
}

BOOL __asm CalcOSRect(
	register __d0 ULONG flags,
	register __a0 struct Rectangle *FaceRect,
	register __a1 struct Rectangle *ShadowRect,
	register __a2 struct Rectangle *OutlineRect)
{
	if (SHADPRI(flags)) { // shadow comes first
		CalcShad(flags,FaceRect,ShadowRect);
		CalcOL(flags,ShadowRect,OutlineRect);
	} else {
		CalcOL(flags,FaceRect,OutlineRect);
		CalcShad(flags,OutlineRect,ShadowRect);
	}
	return(TRUE);
}



/****** GraphicHelp/HelpAllocBitMap *********************************
*
*   NAME
*	HelpAllocBitMap
*
*   SYNOPSIS
*	struct BitMap *__asm HelpAllocBitMap(
*		register __d0 UWORD Width,
*		register __d1 UWORD Height,
*		register __d2 UWORD Depth,
*		register __a0 UBYTE *Planes,
*		register __d3 BOOL Round)
*
*   FUNCTION
*	Allocates bitmap structure and planes
*	if Planes non-NULL, used for bitplane memory (assumed continguous)
*	Round if TRUE aligns planes on double-longword boundaries
*
*********************************************************************
*/
struct BitMap *__asm HelpAllocBitMap(
	register __d0 UWORD Width,
	register __d1 UWORD Height,
	register __d2 UWORD Depth,
	register __a0 UBYTE *Planes,
	register __d3 BOOL Round)
{
	struct BitMap *BM;
	ULONG PlaneSize;
	UWORD A;

	if (Planes) {
	if (BM = (struct BitMap *)SafeAllocMem(sizeof(struct BitMap),
		MEMF_CLEAR)) {
		BM->BytesPerRow = (Width+7)>>3;
		BM->Rows = Height;
		BM->Depth = Depth;
		PlaneSize = BM->BytesPerRow * Height;
		for (A = 0; A < Depth; A++) {
			if (Round)
				Planes = RoundLW2(Planes);
			BM->Planes[A] = Planes;
			Planes += PlaneSize;
		}
	}
	}
	return(BM);
}

/****** GraphicHelp/HelpFreeBitMap **************************************
*
*   NAME
*	HelpFreeBitMap
*
*   SYNOPSIS
*	VOID __asm HelpFreeBitMap(
*		register __a0 struct BitMap *BM)
*
*   FUNCTION
*	Frees the BitMap structure
*
*********************************************************************
*/
VOID __asm HelpFreeBitMap(
	register __a0 struct BitMap *BM)
{
	if (BM) FreeMem(BM,sizeof(struct BitMap));
}

//*******************************************************************


/****** GraphicHelp/AllocFastBitMap *********************************
*
*   NAME
*	AllocFastBitMap
*
*   SYNOPSIS
*	struct BitMap *__asm AllocFastBitMap(
*		register __d0 UWORD Width,
*		register __d1 UWORD Height,
*		register __d2 UWORD Depth)
*
*   FUNCTION
*	Allocates bitmap structure and planes from fast RAM
*
*********************************************************************
*/
struct BitMap *__asm AllocFastBitMap(
	register __d0 UWORD Width,
	register __d1 UWORD Height,
	register __d2 UWORD Depth)
{
	struct BitMap *BM;
	ULONG PlaneSize, flag=TRUE;
	UWORD A;

	if(!(Width && Height && Depth)) return(NULL);
	if (BM = (struct BitMap *)SafeAllocMem(sizeof(struct BitMap),MEMF_CLEAR))
	{
		BM->BytesPerRow = (Width+7)>>3;
		BM->Rows = Height;
		BM->Depth = Depth;
		PlaneSize = BM->BytesPerRow * Height;
		for (A = 0; (A < Depth) && flag; A++)
		{
			BM->Planes[A] = SafeAllocMem(PlaneSize,MEMF_CLEAR);
			flag = (ULONG)(BM->Planes[A]);
		}
		if(A!=Depth) // failure in allocation
		{
			while(A>=0)
				if(BM->Planes[A]) FreeMem(BM->Planes[A--],PlaneSize);
			FreeMem(BM,sizeof(struct BitMap));
			return(NULL);
		}
	}
	DUMPMEM("FAST_BM",BM,100);
	return(BM);
}

/****** GraphicHelp/FreeFastBitMap **************************************
*
*   NAME
*	FreeFastBitMap
*
*   SYNOPSIS
*	VOID __asm FreeFastBitMap(
*		register __a0 struct BitMap *BM)
*
*   FUNCTION
*	Frees the BitMap structure
*
*********************************************************************
*/
VOID __asm FreeFastBitMap(
	register __a0 struct BitMap *BM)
{
	UWORD A;
	ULONG PlaneSize;
	if (BM)
	{
		PlaneSize = BM->BytesPerRow * BM->Rows;
		for( A=0; (A<BM->Depth) && BM->Planes[A]; A++ )
			FreeMem(BM->Planes[A],PlaneSize);
		FreeMem(BM,sizeof(struct BitMap));
	}
}


/****** NewSupport/InitRenderer *************************************
*
*   NAME
*	InitRender
*
*   SYNOPSIS
*	BOOL __asm InitRenderer(
*		register __a0 struct RenderData *D)
*
*   FUNCTION
*		Initializes rendering engine,
*		Allocates buffers needed to render pages
*		(Does not allocate any CHIP memory)
*
* THIS MAY BE CALLED MORE THAN ONCE
********************************************************************/
BOOL __asm InitRenderer(
	register __a0 struct RenderData *D)
{
	UBYTE *A,*B;

// asm allocates structure (which is actually gb_ structure)

	if (ToastFastMem && ToastChipMem) {

	// fast shared
		A = ToastFastMem;

		if (D->FastKey || (D->FastKey = HelpAllocBitMap(KEY_WIDTH,KEY_HEIGHT,
			KEY_DEPTH,A,FALSE))) {

	// every page type uses these chip buffers
		A = ToastChipMem;

		if (D->TempKey || (D->TempKey = HelpAllocBitMap(KEY_WIDTH,KEY_HEIGHT,
			KEY_DEPTH,A,TRUE))) { // TempKey shared with TempChar

		if (D->TempChar || (D->TempChar = HelpAllocBitMap(TEMP_CHAR_WIDTH,PAGE_HEIGHT,
			ALPHA_DEPTH,A,FALSE))) {
		A = WordAfterPlanes(D->TempChar);

		if (D->CharAlpha || (D->CharAlpha = HelpAllocBitMap(PAGE_WIDTH,PAGE_HEIGHT,
			ALPHA_DEPTH,A,FALSE))) {
		B = A = WordAfterPlanes(D->CharAlpha);

	// PAGE_SCROLL
		if (InitScrollRenderer(B,D->TempChar,D->CharAlpha)) {

	// PAGE_CRAWL
		if (InitCrawlRenderer(B,D->TempChar,D->CharAlpha)) {
			return(TRUE);
	 } } } } }

	FreeRenderer(D);
	}}
	return(FALSE);
}

//*******************************************************************
// Layers opened/closed seperately because cleared with blitter
//
BOOL __asm OpenCGLayers(VOID)
{
	struct RenderData *D;
	BOOL Success = FALSE;

	D = &OurRenderData;

//	DUMPMSG("Before NewLayerInfo 1");
//	DUMPHEXIL("GfxBase=",(LONG)GfxBase,"\\");
//	DUMPHEXIL("LayersBase=",(LONG)LayersBase,"\\");

//	if ((D->AlphaLayerInfo = NewLayerInfo()) &&
//	(D->AlphaLayer = CreateUpfrontLayer(D->AlphaLayerInfo,D->CharAlpha,0,0,
//		(D->CharAlpha->BytesPerRow*8)-1,D->CharAlpha->Rows-1,LAYERSIMPLE,
//		(struct BitMap *)NULL))) {


	if (D->AlphaLayerInfo = NewLayerInfo())
	{
//		DUMPMSG("Before CreateUpfrontLayer 1");

		if (D->AlphaLayer = CreateUpfrontLayer(D->AlphaLayerInfo,D->CharAlpha,0,0,
		(D->CharAlpha->BytesPerRow*8)-1,D->CharAlpha->Rows-1,LAYERSIMPLE,
		(struct BitMap *)NULL)) {

//		DUMPMSG("Before CreateUpfrontLayer 2");

	if ((D->TempLayerInfo = NewLayerInfo()) &&
	(D->TempLayer = CreateUpfrontLayer(D->TempLayerInfo,D->TempChar,0,0,
		(D->TempChar->BytesPerRow*8)-1,D->TempChar->Rows-1,LAYERSIMPLE,
		(struct BitMap *)NULL))) {

//	DUMPMSG("Before OpenScrollLayers() && OpenCrawlLayers()");

	if (OpenScrollLayers() && OpenCrawlLayers()) {

		Success = TRUE;
	} } } }
	return(Success);
}

//*******************************************************************
VOID __asm CloseCGLayers(VOID)
{
	struct RenderData *D;

	D = &OurRenderData;

	CloseCrawlLayers();
	CloseScrollLayers();
	if (D->TempLayer) {
		DeleteLayer(NULL,D->TempLayer);
		D->TempLayer = NULL;
	}
	if (D->TempLayerInfo) {
		DisposeLayerInfo(D->TempLayerInfo);
		D->TempLayerInfo = NULL;
	}
	if (D->AlphaLayer) {
		DeleteLayer(NULL,D->AlphaLayer);
		D->AlphaLayer = NULL;
	}
	if (D->AlphaLayerInfo) {
		DisposeLayerInfo(D->AlphaLayerInfo);
		D->AlphaLayerInfo = NULL;
	}
	WaitBlit(); // DeleteLayer clears bitmap
}

/****** NewSupport/FreeRenderer *************************************
*
*   NAME
*	FreeRender
*
*   SYNOPSIS
*	VOID __asm FreeRenderer(
*		register __a0 struct RenderData *D)
*
*   FUNCTION
*		Free buffers needed to render pages
*
* THIS MAY BE CALLED MORE THAN ONCE
********************************************************************/
VOID __asm FreeRenderer(
	register __a0 struct RenderData *D)
{
	if (D)
  {

// PAGE_CRAWL
		FreeCrawlRenderer();	   //deletes CI structure & associated BMs

// PAGE_SCROLL
		FreeScrollRenderer();	//deletes SI structure & associated BMs

// every page type uses these chip buffers
	HelpFreeBitMap(D->CharAlpha);
	HelpFreeBitMap(D->TempChar);
	HelpFreeBitMap(D->TempKey);

// fast shared
	HelpFreeBitMap(D->FastKey);

	D->CharAlpha=NULL;
	D->TempChar=NULL;
	D->TempKey=NULL;
	D->FastKey=NULL;
  }
}

// THE FOLLOWING COPYFAST ROUTONS ARE USED BY KEYED PAGES & CALLED BY THE SWITCHER!!!
/****** NewInterface/CopyFastBMOH ***********************************
*
*   NAME
*	CopyFastBMOH
*
*   SYNOPSIS
*	VOID __asm CopyFastBMOH(
*		register __a0 struct BitMap *Source,
*		register __a1 struct BitMap *Dest,
*		register __d0 ULONG SourceRowOffset,
*		register __d1 ULONG Height,
*		register __d2 ULONG DestRowOffset)
*
*   FUNCTION
*		SourceRowOffset = #rows into SourceBM to start on
*
********************************************************************/
VOID __asm CopyFastBMOH(
	register __a0 struct BitMap *Source,
	register __a1 struct BitMap *Dest,
	register __d0 ULONG SourceRowOffset,
	register __d1 ULONG Height,
	register __d2 ULONG DestRowOffset)
{
	UWORD MaxP,P,R;
	ULONG CopySize,Rows;
	UBYTE *S,*D;

	MaxP = min(Source->Depth,Dest->Depth);
	Rows = min((Source->Rows-SourceRowOffset),(Dest->Rows-DestRowOffset));
	Rows = min(Rows,Height);
	if (Source->BytesPerRow > Dest->BytesPerRow)
		CopySize = Dest->BytesPerRow;
	else
		CopySize = Source->BytesPerRow;

	SourceRowOffset *= Source->BytesPerRow;
	DestRowOffset *= Dest->BytesPerRow;

	for (P=0; P < MaxP; P++) {
		S = Source->Planes[P] + SourceRowOffset;
		D = Dest->Planes[P] + DestRowOffset;
		for (R = 0; R < Rows; R++) {
			CopyMem(S,D,CopySize);
			S += Source->BytesPerRow;
			D += Dest->BytesPerRow;
		}
	}
}

/****** NewInterface/CopyFastBM ************************************
*
*   NAME
*	CopyFastBM
*
*   SYNOPSIS
*	VOID __asm CopyFastBM(
*		register __a0 struct BitMap *Source,
*		register __a1 struct BitMap *Dest)
*
*   FUNCTION
*		Copies one bitmap to another, can handle
*		one smaller than the other (clips it)
*
********************************************************************/
VOID __asm CopyFastBM(
	register __a0 struct BitMap *Source,
	register __a1 struct BitMap *Dest)
{
	CopyFastBMOH(Source,Dest,0,65000,0);
}

//**********************************************************
#ifdef SERDEBUG
void ShowGlyphList(struct MovePage *MP)
{
	struct Glyph *Gly=MP->Glyphs;
	ULONG	g;
	for(g=0;g<MP->GlyphNum;g++)
	{
		sprintf(namebuff,"Glyphs[%d/%d]: %c At:	 (%d,0)	 Size:	 (%d,%d)",g,MP->GlyphNum,(Gly[g].Code&0x00FF),Gly[g].X,Gly[g].W,Gly[g].H);
		DUMPMSG(namebuff);
	}
	for(g=0; g<MP->LineNum; g++)
	{
		sprintf(namebuff," Line %d of %d: Length= %d",g,MP->LineNum,MP->Lines[g].Length);
		DUMPMSG(namebuff);
	}

}
#endif

#ifndef SERDEBUG
void ShowGlyphList(struct MovePage *MP) { }
#endif

// end of newscroll.c
