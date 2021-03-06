/********************************************************************
* newcrawl.c 
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
* $Id: NewCrawl.c,v 2.0 1995/08/31 15:27:31 Holt Exp $
* $Log: NewCrawl.c,v $
 * Revision 2.0  1995/08/31  15:27:31  Holt
 * FirstCheckIn
 *
*********************************************************************/
/********************************************************************
* NewCrawl.c
*
* Copyright �1993 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* Crawl page rules:
*	- one color / one font (for now)
*	- shadow and outline are opaque and black
*	- up to CRAWL_HEIGHT lines tall fonts supported (no more)
*
* 3.0 rendering engine changes:
*	- renders directly into displayed bitmap (2x screen width)
*	- uses RP to clip instead of saving seam manually
*
*	2-15-93	Steve H		Created
*	3-12-93	Steve H		Attr
*	5-12-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <stdio.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/layers.h>

#include <toastfont.h>
#include <graphichelp.h>
#include <book.h>
#include <newsupport.h>
#include <newscroll.h>

#ifndef PROTO_PASS
#include <protos.h>
#endif
#ifdef PROTO_PASS
BOOL __asm RenderFace(register __a0 struct CharCall * );
#endif

/*
crawl page rendering:
needs buffers on left and right because whole line's shadow and outline
done at once, and chars which might be offscreen influence shad & out

1) render at 742 (716 with prev) w/seam at 1509 (end when StartX past seam)
2) do out & shad from 716 to 1535
3) copy (742,1509) to (768,1535)
4) blit old RHS to LHS (or clear if first)
*/

#define CRAWL_WIDTH 1536
#define CRAWL_HEIGHT 300
#define CRAWL_DEPTH 3
#define FINAL_MINX 768
#define FINAL_WIDTH 768
#define RENDER_MINX (FINAL_MINX-MAX_ADDITIONAL)	// 742
#define RENDER_SEAM (RENDER_MINX+FINAL_WIDTH-1)	// 1509
#define RENDER_PREV_MINX (RENDER_MINX-MAX_ADDITIONAL) // 716

// VOID WaitButton(VOID);

struct Glyph
{
	UWORD	Code; 				// ASCII/EUC code
	UWORD	X,Y,W,H;			// Blit coordinates in big BM
	UBYTE	AttrIndx;			// ==0 for now
	UBYTE	Flags;				// reserved
};

struct	Letter
{
	WORD	Index;				// index into array of glyphs
	UWORD	XPos;					// pixel on dest line to blit to (at current Y, w/ W from Glyph
	ULONG	Flags;				// on-the-fly Attribute switches (O/S)
};

struct	MPLine
{
	UWORD	Length;				//
	UWORD	YPos;					// pixel on dest line to blit to (at current X, w/ W from Glyph
};

struct MovePage
{
	int CharNum;
	int GlyphNum;
	int LineNum;
	UWORD	W;  // Max Glyph size, for chip bm used to blit from
	UWORD	H;
	UWORD	CurLine;
	UWORD	CurChar;		// oops no more than 65536 chars!!!
	UBYTE	PlayMode;		// 0,1,2 (loop,once,freeze)
	UBYTE	Speed;
	UWORD	Flags;
	struct TrueColor	FaceColor;
	struct TrueColor	OSColor; //if no ShadowType & no OutlineType, go to Black
	struct MPLine	*Lines;
	struct Letter	*Letters;
	struct Glyph	*Glyphs;
	struct BitMap	*GBM;
	struct BitMap	*tmpBM;  // chip bm used to blit temp 1 char from (MP->W+63)xMP->H
};

extern char CrawlFailMsg[],CrawlFail2[];

struct CrawlInfo {
	struct BitMap *TempChar;
	struct BitMap *CharAlpha;
	struct BitMap *CrawlBM1;
	struct BitMap *CrawlBM2;

	struct BitMap *SrcFakeBM;	// source, (not used in Layer)
	struct BitMap *DstFakeBM;	// used in Layer
	struct Layer_Info *FakeLayerInfo;
	struct Layer *FakeLayer;

	struct Rectangle TotalRect; // current CrawlBM1/2 rect
};

struct CrawlInfo *CI = NULL;
struct BitMap *CrawlBM1,*CrawlBM2;
UBYTE *AfterCrawl;
struct CGLine CrawlLine; // DoCrawlLine() sets, others examine
UWORD LinePosition; // set by GetCrawlLine()
UWORD CharOffset,BitOffset;
UBYTE FinalCountdown; // CrawlPage()
UWORD UserMinX,UserMaxX; // for cursor

#define SAFE_XOFFSET 56
#define DEFAULT_CURSOR_WIDTH 32

extern struct RenderData *RD;

//*******************************************************************
BOOL FillLineText(struct CGLine *SrcLine,struct CGLine *DstLine,
	UWORD Position)
{
	UWORD D = 0;
	struct TextInfo *Src,*Dst;
	BOOL AnyChars = FALSE;
	struct CGLine *First;

	Src = &SrcLine->Text[Position];
	Dst = &DstLine->Text[0];

	while ((D < LINE_LENGTH) && (SrcLine->Node.mln_Succ)) {
		if ((Position < LINE_LENGTH) && (Dst->Ascii = Src->Ascii)) {
			AnyChars = TRUE;
			Dst->Kerning = Src->Kerning;
			Dst->Attr = NULL;
			Src++;
			Dst++;
			D++;
			Position++;
		} else {
			SrcLine = (struct CGLine *)SrcLine->Node.mln_Succ;
			Src = &SrcLine->Text[0];
			Position = 0;
		}
	}
	//if (RD->CursorPosition > 14) JUNK2();
	First = (struct CGLine *)RD->CurrentPage->LineList.mlh_Head;
	DstLine->Text[0].Attr = First->Text[0].Attr;

	return(AnyChars);
}

//*******************************************************************
UWORD GetCrawlLength(struct CGPage *Page)
{
	struct CGLine *Line;
	UWORD A, L = 0;
	struct TextInfo *Text;

	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Line->Node.mln_Succ) {
		Text = &Line->Text[0];
		A = 0;
		while ((A < LINE_LENGTH) && (Text->Ascii)) {
			A++;
			L++;
			Text++;
		}
		Line = (struct CGLine *)Line->Node.mln_Succ;
	}
	return(L);
}

//*******************************************************************
struct CGLine *GetCrawlLine(struct CGPage *Page,UWORD Position)
{
	struct CGLine *Line;

	if (GetCrawlLength(Page) <= Position) return(NULL);

	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while ((Line->Node.mln_Succ) && (Position >= LINE_LENGTH)) {
		Position -= LINE_LENGTH;
		Line = (struct CGLine *)Line->Node.mln_Succ;
	}
	if (Line->Node.mln_Succ) {
		LinePosition = Position;
		return(Line);
	}
	else return(NULL);
}

/****** NewCrawl/RenderCrawlingLine *********************************
*
*   NAME   
*	RenderCrawlingLine
*
*   SYNOPSIS
*	BOOL __asm RenderCrawlingLine(
*		register __a0 struct CGPage *Page,
*		register __a1 UWORD *CharOffset,
*		register __a2 UWORD *BitOffset,
*		register __d0 UWORD WhichBM)
*
*   FUNCTION
*
********************************************************************/
/*
VOID FakeMessup(VOID)
{
	struct CGPage *Page;
	UWORD Char=0,Bit=0;

	Page = &RD->CurrentBook->Page[3];
	RenderCrawlingLine(Page,&Char,&Bit,0);
}*/

BOOL __asm RenderCrawlingLine(
	register __a0 struct CGPage *Page,
	register __a1 UWORD *CharOffset,
	register __a2 UWORD *BitOffset,
	register __d0 UWORD WhichBM)
{
	struct TempInfo *Temp;
	struct BitMap *RendBM,*PrevBM;
	UWORD A,TotalHeight;
	struct CGLine *Line;
	struct Rectangle CalcRect,SaveFace;
	BOOL AnythingRendered = FALSE,FirstTime = FALSE;
	struct CrawlInfo *C;

	C = CI;
	if (WhichBM) {
		RendBM = C->CrawlBM2;
		PrevBM = C->CrawlBM1;
	} else {
		RendBM = C->CrawlBM1;
		PrevBM = C->CrawlBM2;
	}

	SaveFace.MinX = 0; // flag that first DO_FACE
	Line = (struct CGLine *)Page->LineList.mlh_Head;
	TotalHeight = Line->TotalHeight;
	if (TotalHeight < CRAWL_HEIGHT) TotalHeight++; 
		// because might have rounded up in crawl.a

	CrawlLine.TotalHeight = Line->TotalHeight;
	CrawlLine.Baseline = Line->Baseline;
	CrawlLine.YOffset = 0;
	CrawlLine.Type = LINE_TEXT;
	CrawlLine.JustifyMode = JUSTIFY_NONE;

	if (!(*CharOffset)) FirstTime = TRUE;

// CalcRect temp used to clear RHS
	CalcRect.MinX = RENDER_PREV_MINX;
	CalcRect.MinY = 0;
	CalcRect.MaxX = CRAWL_WIDTH-1;
	CalcRect.MaxY = TotalHeight-1;
	ClearWordRect(RendBM,&CalcRect);

// CalcRect now holds DX1,DX2
	CalcLineYMinMax(Line,&CalcRect);

// if first render, make sure all shad/out in (else BitOffset already setup)
	if (FirstTime)
		*BitOffset = RENDER_MINX - CalcRect.MinX;

RenderMore:
	if (DoCrawlLine(Page,&SaveFace,CharOffset,BitOffset,RendBM,
		REND_DO_FACE)) {
		AnythingRendered = TRUE;

// see if went over seam
	Temp = &CrawlLine.Temp[0];
	for (A=0; A < LINE_LENGTH; A++) 
	{
		if (!Temp->EndX) goto NoneOver;
		// take the first char which had any part over seam,
		// and setup next render to render part over seam again
		if (((Temp->DataEndX + CalcRect.MaxX) > RENDER_SEAM) ||
			((Temp->EndX + CalcRect.MaxX) > RENDER_SEAM))
		{
			// RENDER_MINX - (RENDER_SEAM + 1 - StartX) =
			// 742 - (1510 - startX) = StartX - FINAL_WIDTH
			*BitOffset = Temp->StartX - FINAL_WIDTH;
			*CharOffset += A;
			goto ValidExit;
		}
		Temp++;
	}

// if none over edge, try to render more
NoneOver:
		*CharOffset += A;		// start with next char
		*BitOffset = CrawlLine.Temp[A-1].EndX + 1; // put it right next to last
		if (GetCrawlLength(Page) > (*CharOffset)) goto RenderMore;
	}

ValidExit:
	if (AnythingRendered) {
		RenderMoveLine(&CrawlLine,RendBM,&C->TotalRect,&SaveFace,
			C->FakeLayer,C->SrcFakeBM,REND_DO_OUT_SHAD);

// blit right into place
		BltBitMap(RendBM,RENDER_MINX,0,RendBM,FINAL_MINX,0,
			FINAL_WIDTH,TotalHeight,0xc0,0x7,NULL);
	}

// if nothing rendered, start finalcountdown (unless already started)
		if ((!AnythingRendered) && (!FinalCountdown))
			FinalCountdown = 3;

// Copy previous RHS to this LHS (or clear if first time)
	if (FirstTime) {
		CalcRect.MinX = CalcRect.MinY = 0;
		CalcRect.MaxX = FINAL_WIDTH-1;
		CalcRect.MaxY = TotalHeight-1;
		ClearWordRect(RendBM,&CalcRect);
	} else {
		BltBitMap(PrevBM,FINAL_MINX,0,
			RendBM,0,0,FINAL_WIDTH,TotalHeight,
			0xc0,0x7,NULL);
	}

// debug
/*
	ClearYBlock(InterfaceBM,0,200);
	BltBitMap(RendBM,768,0,
		InterfaceBM,40,0,
		384,
		TotalHeight,
		0xc0,0x3,NULL);

	BltBitMap(RendBM,768+384,0,
		InterfaceBM,40,TotalHeight,
		384,
		TotalHeight,
		0xc0,0x3,NULL);

	CI->DstFakeBM->Planes[0] = RendBM->Planes[2];
	BltBitMap(CI->DstFakeBM,768,0,
		InterfaceBM,40,0,
		384,
		TotalHeight,
		0xc0,0x1,NULL);

	BltBitMap(CI->DstFakeBM,768+384,0,
		InterfaceBM,40,TotalHeight,
		384,
		TotalHeight,
		0xc0,0x1,NULL);
*/

	WaitBlit();
	return(TRUE);
}

/****** NewCrawl/RenderCrawlUserLine ********************************
*
*   NAME   
*	RenderCrawlUserLine
*
*   SYNOPSIS
*	BOOL __asm RenderCrawlUserLine(
*		register __a0 struct CGPage *Page,
*		register __a1 UWORD *CharOffset,
*		register __d0 UWORD Fred)
*
*   FUNCTION
*		called by RenderUserCrawlLine
*
********************************************************************/
BOOL __asm RenderCrawlUserLine(
	register __a0 struct CGPage *Page,
	register __a1 UWORD *CharOffset,
	register __d0 UWORD Fred)
{
	UWORD BitOffset;
	struct Rectangle FaceRect;
	struct CrawlInfo *C;
	struct CGLine *Line;

//	DumpUDecW("RenderCrawlUserLine... Cursor: ",Fred,"  ");
// This hack works arpound weirdness in crawl.a line 185...


//	DumpUDecW("Real Position:  ",RD->CursorPosition,"  ");
//	DumpUDecW("Char Offset:  ",*CharOffset," \\");

	C = CI;
	FaceRect.MinX = 0; // flags that first DO_FACE
	BitOffset = SCROLL_MIN_X;

	if (!(DoCrawlLine(Page,&FaceRect,CharOffset,&BitOffset,
	RD->FullAlpha,(REND_INTERFACE_ONLY | REND_CLEAR_FIRST | REND_DO_FACE)))){

// if nothing rendered, fill in TempRect ourselves
		Line = (struct CGLine *)Page->LineList.mlh_Head;
		C->TotalRect.MinY = 0;
		C->TotalRect.MaxY = Line->TotalHeight-1;
		C->TotalRect.MinX = C->TotalRect.MaxX = 0;
	}

// setup cursor
	if (UserMaxX = CrawlLine.Temp[Fred].EndX) 	// 5-6-93 no longer uses DataEnd
	{
		UserMinX = CrawlLine.Temp[Fred].StartX;
//		DumpUDecW("Cursor At x=",UserMinX," to ");
//		DumpUDecW(" x=",UserMaxX," \\");
	} else {
		if (Fred) {
			UserMinX = CrawlLine.Temp[Fred-1].EndX;
		} else {
			UserMinX = SAFE_XOFFSET;
		}
		UserMaxX = UserMinX + DEFAULT_CURSOR_WIDTH;
	}

// debug
/*
	ClearYBlock(InterfaceBM,0,200);
	BltBitMap(CI->CrawlBM1,768,0,
		InterfaceBM,40,0,
		384,
		80,
		0xc0,0x3,NULL);
	BltBitMap(CI->CrawlBM1,768+384,0,
		InterfaceBM,40,80,
		384,
		80,
		0xc0,0x3,NULL);
*/

	return(TRUE);
}

/****** NewCrawl/DisplayCrawlUserLine *******************************
*
*   NAME   
*	DisplayCrawlUserLine
*
*   SYNOPSIS
*	BOOL __asm DisplayCrawlUserLine(
*		register __a0 struct CGPage *Page)
*
*   FUNCTION
*
********************************************************************/
BOOL __asm DisplayCrawlUserLine(
	register __a0 struct CGPage *Page)
{
	struct RenderData *R;
	struct CrawlInfo *C;
	UWORD MinY,Width,Height;
	struct Rectangle Clear;
	struct RastPort *RP;

	C = CI;
	R = RD;
	RP = R->InterfaceRastPort;
	MinY = C->TotalRect.MinY + ((struct CGLine *)Page->LineList.mlh_Head)
		->YOffset;
	Width = C->TotalRect.MaxX-C->TotalRect.MinX+1;
	Height = C->TotalRect.MaxY-C->TotalRect.MinY+1;

	Clear.MinX = C->TotalRect.MinX + Width - 1;
	Clear.MaxX = (R->Interface->BytesPerRow << 3) - 1;
	Clear.MinY = MinY;
	Clear.MaxY = MinY+Height-1;

	SetDrMd(RP,JAM2);
	SetAPen(RP,BG_PEN);
	RectFill(RP,Clear.MinX,Clear.MinY,Clear.MaxX,Clear.MaxY);

	if (Width > 1)
		BltBitMapRastPort(R->FullAlpha,C->TotalRect.MinX,C->TotalRect.MinY,
			RP,C->TotalRect.MinX,MinY,Width,Height,0xc0);

	R->OldCursorX1 = UserMinX;
	R->OldCursorX2 = UserMaxX;

	WaitBlit();
	return(TRUE);
}

/****** NewCrawl/DoCrawlLine ****************************************
*
*   NAME
*	DoCrawlLine
*
*   SYNOPSIS
*	BOOL DoCrawlLine(
*		struct CGPage *Page,
*		struct Rectangle *FaceRect,
*		UWORD *CharOffset,
*		UWORD *BitOffset,
*		struct BitMap *RendBM,
*		UWORD RendFlags)
*
*   FUNCTION
*		Renders face in planes 0,1, Out&Shad in plane 2
*		if InterfaceOnly, just does face
*		WhichBM 0/1 -> CrawlBM1/2
*
********************************************************************/
BOOL DoCrawlLine(
	struct CGPage *Page,
	struct Rectangle *FaceRect,
	UWORD *CharOffset,
	UWORD *BitOffset,
	struct BitMap *RendBM,
	UWORD RendFlags)
{
	register struct CrawlInfo *C;
	struct CGLine *Line;
	BOOL Success = FALSE;

	C = CI;
	if (Line = GetCrawlLine(Page,*CharOffset)) {
		CrawlLine.XOffset = *BitOffset;
		if (RendBM->Depth > 2) C->DstFakeBM->Planes[0] = RendBM->Planes[2];
		if (FillLineText(Line,&CrawlLine,LinePosition)) {
			RenderMoveLine(&CrawlLine,RendBM,&C->TotalRect,FaceRect,
				C->FakeLayer,C->SrcFakeBM,RendFlags);
			Success = TRUE;
		}
	}
	return(Success);
}

/****** NewCrawl/InitCrawlRenderer ********************************
*
*   NAME
*	InitCrawlRenderer
*
*   SYNOPSIS
*	BOOL __asm InitCrawlRenderer(
*		register __a0 UBYTE *ChipMem,
*		register __a1 struct BitMap *TempChar,
*		register __a2 struct BitMap *CharAlpha)
*
*   FUNCTION
*		Readies Crawl rendering engine
*
********************************************************************/
BOOL __asm InitCrawlRenderer(
	register __a0 UBYTE *ChipMem,
	register __a1 struct BitMap *TempChar,
	register __a2 struct BitMap *CharAlpha)
{

	BOOL Success = FALSE;
	register struct CrawlInfo *C;

	if (CI = SafeAllocMem(sizeof(struct CrawlInfo),MEMF_CLEAR)) {
//		DumpMsg("InitCrawlRenderer: Entry");
		C = CI;
		C->TempChar = TempChar;
		C->CharAlpha = CharAlpha;

		if (C->CrawlBM1 = HelpAllocBitMap(CRAWL_WIDTH,CRAWL_HEIGHT,
			CRAWL_DEPTH,ChipMem,TRUE)) {
		ChipMem = WordAfterPlanes(C->CrawlBM1);
		if (C->CrawlBM2 = HelpAllocBitMap(CRAWL_WIDTH,CRAWL_HEIGHT,
			CRAWL_DEPTH,ChipMem,TRUE)) {
		// ChipMem = WordAfterPlanes(C->CrawlBM2);

		// Fake bitmaps/layers used during shadow/outline rendering
		if (C->SrcFakeBM = HelpAllocBitMap(CRAWL_WIDTH,CRAWL_HEIGHT,
			1,TempChar->Planes[0],FALSE)) {
		if (C->DstFakeBM = HelpAllocBitMap(CRAWL_WIDTH,CRAWL_HEIGHT,
			1,TempChar->Planes[0],FALSE)) {

		CrawlBM1 = C->CrawlBM1;
		CrawlBM2 = C->CrawlBM2;
		AfterCrawl = WordAfterPlanes(C->CrawlBM2);

//		DumpMsg("InitCrawlRenderer: OK");
		Success = TRUE;
		} } } }
	}
	return(Success);
}

//*******************************************************************
// Layers opened/closed seperately because cleared with blitter
//
BOOL __asm OpenCrawlLayers(VOID)
{
	BOOL Success = FALSE;
	register struct CrawlInfo *C;

	C = CI;
	if ((C->FakeLayerInfo = NewLayerInfo()) &&
		(C->FakeLayer = CreateUpfrontLayer(C->FakeLayerInfo,C->DstFakeBM,
		RENDER_PREV_MINX,0,CRAWL_WIDTH-1,CRAWL_HEIGHT-1,LAYERSIMPLE,
		(struct BitMap *)NULL))) {

//		DumpMsg("OpenCrawlLayers: OK");

		Success = TRUE;
	} 
	return(Success);
}

//*******************************************************************
VOID __asm CloseCrawlLayers(VOID)
{
	register struct CrawlInfo *C;

	C = CI;
	C->FakeLayer->rp->BitMap->Planes[0] = C->TempChar->Planes[0];
	if (C->FakeLayer) {
		DeleteLayer(NULL,C->FakeLayer);
		C->FakeLayer = NULL;
	}
	if (C->FakeLayerInfo) {
		DisposeLayerInfo(C->FakeLayerInfo);
		C->FakeLayerInfo = NULL;
	}
	WaitBlit(); // DeleteLayer clears bitmap
}

/****** NewCrawl/FreeCrawlRenderer ********************************
*
*   NAME   
*	FreeCrawlRenderer
*
*   SYNOPSIS
*	VOID __asm FreeCrawlRenderer(VOID)
*
*   FUNCTION
*		Frees Crawl rendering engine
*
********************************************************************/
VOID __asm FreeCrawlRenderer(VOID)
{
	register struct CrawlInfo *C;

	if (C = CI) {
		if (C->DstFakeBM) HelpFreeBitMap(C->DstFakeBM);
		if (C->SrcFakeBM) HelpFreeBitMap(C->SrcFakeBM);
		if (C->CrawlBM2) HelpFreeBitMap(C->CrawlBM2);
		if (C->CrawlBM1) HelpFreeBitMap(C->CrawlBM1);
		FreeMem(C,sizeof(struct CrawlInfo));
	}
}

//*******************************************************************
VOID CrawlFailed(VOID)
{
	struct RenderData *R;
	char *Mess[2];

	R = RD;
	if ((R->InterfaceWindow) || (R->SwitcherScreen)) {
		Mess[0] = CrawlFailMsg;
		Mess[1] = CrawlFail2;
		CGMultiRequest(Mess,2,REQ_CENTER | REQ_H_CENTER);
	}
}

BOOL __asm RenderCrawlingMPLine(
	register __a0 struct MovePage *MP,
	register __a1 UWORD *CharOffset,
	register __a2 UWORD *BitOffset,
	register __d0 UWORD WhichBM)
{
	struct BitMap *RendBM,*PrevBM;
	UWORD TotalHeight,X,XMax,dX;
	struct CGLine *Line;
	struct Rectangle CalcRect,SaveFace;
	BOOL AnythingRendered = FALSE,FirstTime = FALSE;
	struct CrawlInfo *C;

	C = CI;
	if (WhichBM) {
		RendBM = C->CrawlBM2;
		PrevBM = C->CrawlBM1;
	} else {
		RendBM = C->CrawlBM1;
		PrevBM = C->CrawlBM2;
	}

	Line = (struct CGLine *)RD->CurrentPage->LineList.mlh_Head;
	SaveFace.MinX = 0; // flag that first DO_FACE

	TotalHeight = C->CrawlBM2->Rows;

	if (!(*CharOffset)) FirstTime = TRUE;

// CalcRect temp used to clear RHS
	CalcRect.MinX = RENDER_PREV_MINX;
	CalcRect.MinY = 0;
	CalcRect.MaxX = CRAWL_WIDTH-1;
	CalcRect.MaxY = TotalHeight-1;
	ClearWordRect(RendBM,&CalcRect);

// CalcRect now holds DX1,DX2 - The offsets due to OS
	CalcLineYMinMax(Line,&CalcRect);

// if first render, make sure all shad/out in (else BitOffset already setup)
	if (FirstTime)
		*BitOffset = RENDER_MINX - CalcRect.MinX;

	C->TotalRect.MinX = *BitOffset;
	C->TotalRect.MinY = CalcRect.MinY;
	C->TotalRect.MaxY = CalcRect.MaxY;
	XMax = RENDER_SEAM - CalcRect.MaxX;
	for(X = *BitOffset; X<=XMax; X+=dX)
	{
		dX = RenderMPChar(RendBM,MP,X,0);
		AnythingRendered = TRUE;
	}
	*BitOffset = X - dX;
	C->TotalRect.MaxX = *BitOffset;
	if(MP->CurChar) MP->CurChar--;

// blit right into place
		BltBitMap(RendBM,RENDER_MINX,0,RendBM,FINAL_MINX,0,
			FINAL_WIDTH,TotalHeight,0xc0,0x7,NULL);

// if nothing rendered, start finalcountdown (unless already started)
		if ((!AnythingRendered) && (!FinalCountdown))
			FinalCountdown = 3;

// Copy previous RHS to this LHS (or clear if first time)
	if (FirstTime) {
		CalcRect.MinX = CalcRect.MinY = 0;
		CalcRect.MaxX = FINAL_WIDTH-1;
		CalcRect.MaxY = TotalHeight-1;
		ClearWordRect(RendBM,&CalcRect);
	} else {
		BltBitMap(PrevBM,FINAL_MINX,0,
			RendBM,0,0,FINAL_WIDTH,TotalHeight,
			0xc0,0x7,NULL);
	}

	WaitBlit();
	return(TRUE);
}


// end of NewCrawl.c
