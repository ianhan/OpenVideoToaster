/********************************************************************
* newscroll.c 
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
* $Id: newscroll.c,v 2.3 1995/12/14 13:24:20 Holt Exp $
* $Log: newscroll.c,v $
 * Revision 2.3  1995/12/14  13:24:20  Holt
 * *** empty log message ***
 *
 * Revision 2.2  1995/11/10  16:21:27  Holt
 * fixed problem with scroll pg. so page is rejustifyed correctly
 * --- before being saved.  also made change in newedit.c, justifyline for this also.
 *
 * Revision 2.1  1995/10/25  12:17:38  Holt
 * fixed problem with font ID = 0 in countglyphs and getcharinfo
 *
 * Revision 2.0  1995/08/31  15:27:31  Holt
 * FirstCheckIn
 *
*********************************************************************/
/********************************************************************
* NewScroll.c
*
* Copyright ©1993 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* Scroll page rules:
*	- Lines can not overlap Y coords
*	- one text face color per Line
*	- shadow and outline are opaque and black
*	- max 640 wide
*
*	2-12-93	Steve H		Created
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <stdio.h>
#include <math.h>
#include <libraries/iff.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <proto/intuition.h>

#include <book.h>
#include <toastfont.h>
#include <graphichelp.h>
#include <newsupport.h>
#include <newscroll.h>
#include <gadgets.h>
#include <panel.h>
#include <newfunction.h>
#include <MovePage.h>


//#define SERDEBUG	1
#include <serialdebug.h>

#ifndef PROTO_PASS
#include <protos.h>
#endif
#ifdef PROTO_PASS
#include "crlib:libinc/crouton_all.h"
BOOL __asm RenderFace(register __a0 struct CharCall * );
#endif

VOID WaitButton(VOID);
extern struct RenderData *RD;
extern struct Gadget *CurrentBottomList, *AllGadgets[];

extern UBYTE *OutlineTable[];
extern WORD ShadowDX[];
extern WORD ShadowDY[];
extern struct OutlineStuff *Outlines;

struct ScrollInfo {
	struct BitMap *TempChar;
	struct BitMap *CharAlpha;
	struct BitMap *ScrollTextA;
	struct BitMap *ScrollTextB;
	struct BitMap *ScrollBM;

	struct BitMap *SrcFakeBM;	// source, (not used in Layer)
	struct BitMap *DstFakeBM;	// used in Layer
	struct Layer_Info *FakeLayerInfo;
	struct Layer *FakeLayer;

	struct Rectangle TotalRect; // current ScrollTextA/B rect
};

struct MovePage	*MyMP=NULL;
struct ScrollInfo *SI = NULL;
struct BitMap *ScrollTextA, *ScrollTextB,*ScrollBM;
UBYTE *AfterScroll,num=0,NewBM=0;
struct Gadget *PageProp = NULL;
UWORD PagePropType;
UBYTE	namebuff[100];
struct Library *IFFBase;
static struct Gadget *MenuSave=NULL,*IntSave=NULL;


//#ifdef SERDEBUG
//				sprintf(namebuffB,": %d ",d);
//				DUMPMSG(namebuffB);
//#endif


#ifdef SERDEBUG
UBYTE	namebuffD[100];
#endif







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

/****** NewScroll/RenderMoveLine ************************************
*
*   NAME
*	RenderMoveLine
*
*   SYNOPSIS
*	BOOL RenderMoveLine(
*		struct CGLine *Line,
*		struct BitMap *DestBM,
*		struct Rectangle *TotalRect,
*		struct Rectangle *FaceRect,
*		struct Layer *FakeLayer,
*		struct BitMap *TempBM,
*		UWORD RendFlags)
*
*   FUNCTION
*		Renders face in planes 0,1, Out&Shad in plane 2
*		if InterfaceOnly, just does face
*		FakeLayer must contain bitmap 1bp deep,
*		TempBM must contain seperate 1bp deep bitplane
*		TotalRect can be undefined
*		FaceRect is for multiple face passes (crawls)
*		line_YOffset/XOffset must be right for DestBM
*		See NewScroll.h for RendFlags:
*		ClearFirst is TRUE if want DestBM to be cleared first
*
********************************************************************/
BOOL RenderMoveLine(
	struct CGLine *Line,
	struct BitMap *DestBM,
	struct Rectangle *TotalRect,
	struct Rectangle *FaceRect,
	struct Layer *FakeLayer,
	struct BitMap *TempBM,
	UWORD RendFlags)
{
	struct BitMap *LayerBM;
	PLANEPTR TempBP;
	struct CharCall Call;
	struct Rectangle NewFace,ShadRect,OutRect;
	UWORD SaveYOffset;
	struct Attributes *Attr;

	LayerBM = FakeLayer->rp->BitMap;
	TempBP = TempBM->Planes[0];

// always render the line at the top of the DestBM
	SaveYOffset = Line->YOffset;
	Line->YOffset = 0;
	if (RendFlags & REND_INTERFACE_ONLY) {
		TotalRect->MaxX = TotalRect->MinX = 0;
		TotalRect->MinY = 0;
		TotalRect->MaxY = Line->TotalHeight - 1;
	} else {
		CalcLineYMinMax(Line,TotalRect);
	}

	Call.ShowSelect = RendFlags & REND_INTERFACE_ONLY;
	Call.InterfaceOnly = RendFlags & REND_INTERFACE_ONLY;
	Call.ByteStrip = NULL;
	Call.FullAlpha = DestBM;
	Call.Line = Line;
	Attr = Line->Text[0].Attr; // always exists
	Call.Attr = Attr;
	Call.Empty = NULL;
	Call.PageWidth = DestBM->BytesPerRow << 3;
	Call.StripRect.MinX = Call.StripRect.MinY = 0;
	Call.StripRect.MaxX = Call.PageWidth - 1;
	Call.StripRect.MaxY = DestBM->Rows - 1;
	Call.MasterRender = TRUE;

	Attr->FaceColor.Alpha = ALPHA_OPAQUE;
	Attr->ShadowPriority = FALSE;

// clear only height being used
	if (RendFlags & REND_CLEAR_FIRST)
		ClearYBlock(DestBM,0,Line->TotalHeight-1);

// make face in BP 0,1
	if (RendFlags & REND_DO_FACE) {
		LineCall(RenderFace,&Call,&NewFace); // FaceRect clipped
		if (!(FaceRect->MinX)) // is this first DO_FACE?
			FaceRect->MinX = NewFace.MinX; // yes
		FaceRect->MaxX = NewFace.MaxX;
		FaceRect->MinY = NewFace.MinY;
		FaceRect->MaxY = NewFace.MaxY;
	}

	TotalRect->MinX += FaceRect->MinX;
	TotalRect->MaxX += FaceRect->MaxX;  // TotalRect not clipped

// avoid junk on scrolls if line empty
	if (RendFlags & REND_DO_OUT_SHAD) {

	CalcShadOutRect(Attr,FaceRect,&ShadRect,&OutRect); // SO not clipped

// if no out/shad, done
	if ((!(RendFlags & REND_INTERFACE_ONLY)) &&
		(Attr->OutlineType || Attr->ShadowType)) {

// OR into BP 2
	ORIntoMS(DestBM,FaceRect);


#ifndef DONTDEBUG
	if (!Line->Text[0].Ascii) {
		DumpMem("FaceRect",(UBYTE *)FaceRect,sizeof(struct Rectangle));
		DumpMem("ShadRect",(UBYTE *)&ShadRect,sizeof(struct Rectangle));
		DumpMem("OutRect",(UBYTE *)&OutRect,sizeof(struct Rectangle));
	}
#endif

// make outline into Temp BP
		TempBM->Planes[0] = DestBM->Planes[2];
		LayerBM->Planes[0] = TempBP;
		if (Attr->OutlineType)
			MakeOutline(TempBM,FaceRect,FakeLayer->rp,&OutRect,
				Attr->OutlineType);
		else BltBitMap(TempBM,FaceRect->MinX,FaceRect->MinY,
			LayerBM,FaceRect->MinX,FaceRect->MinY,
			(FaceRect->MaxX-FaceRect->MinX+1),(FaceRect->MaxY-FaceRect->MinY+1),
			0xc0,0x1,NULL);

// make shadow into BP 2
		TempBM->Planes[0] = TempBP;
		LayerBM->Planes[0] = DestBM->Planes[2];
		if (Attr->ShadowType) {
			MakeShadow(TempBM,&OutRect,FakeLayer->rp,&ShadRect,Attr,
				FALSE,OutRect.MinX,OutRect.MinY);
		} else BltBitMap(TempBM,OutRect.MinX,OutRect.MinY,
			LayerBM,OutRect.MinX,OutRect.MinY,
			(OutRect.MaxX-OutRect.MinX+1),(OutRect.MaxY-OutRect.MinY+1),
			0xc0,0x1,NULL);
	}
	}
	ClipRect(NULL,&Call.StripRect,TotalRect,NULL); // clip MaxX to strip

/* done with palette now
	if (!(RendFlags & REND_INTERFACE_ONLY)) {
		TempBM->Planes[0] = TempBP;
		FixScrollAlpha(DestBM,TotalRect,TempBM);
	}
*/

	Line->YOffset = SaveYOffset;
	return(TRUE);
}

//*******************************************************************
VOID __regargs AdjustScrollXOffset(
	struct CGLine *Line)
{
	struct Rectangle FaceRect;
	WORD A;

// if shad/out would force off left edge, adjust XOffset to prevent this
	CalcLineYMinMax(Line,&FaceRect);
	A = FaceRect.MinX + (WORD)Line->XOffset;
	if (A < 0) {
		Line->XOffset = 0 - FaceRect.MinX;
	}
}

/****** NewScroll/RenderScrollLine **********************************
*
*   NAME
*	RenderScrollLine
*
*   SYNOPSIS
*	BOOL __asm RenderScrollLine(
*		register __a0 struct CGPage *Page,
*		register __a1 struct CGLine *Line,
*		register __a2 struct BitMap *DestBM,
*		register __d0 BOOL InterfaceOnly)
*
*   FUNCTION
*		Renders face in planes 0,1, Out&Shad in plane 2
*		if InterfaceOnly, just does face
*
********************************************************************/
BOOL __asm RenderScrollLine(
	register __a0 struct CGPage *Page,
	register __a1 struct CGLine *Line,
	register __a2 struct BitMap *DestBM,
	register __d0 BOOL InterfaceOnly)
{
	register struct ScrollInfo *S;
	struct Rectangle FaceRect;
	UWORD Flags;

	S = SI;

// renderer can't handle empty lines
	if (Line->Text[0].Ascii == 0) {
		ClearYBlock(DestBM,0,Line->TotalHeight-1);
		S->TotalRect.MinY = 0;
		S->TotalRect.MaxY = Line->TotalHeight-1;
		S->TotalRect.MinX = 80;
		S->TotalRect.MaxX = 90;
		WaitBlit();
		return(TRUE);
	}

	if (!DestBM)
		DestBM = S->ScrollTextA;

	if (InterfaceOnly) Flags = REND_INTERFACE_ONLY | REND_CLEAR_FIRST | REND_DO_FACE;
	else Flags = REND_CLEAR_FIRST | REND_DO_FACE | REND_DO_OUT_SHAD;

	AdjustScrollXOffset(Line);

	FaceRect.MinX = 0; // flag that first DO_FACE

//	if(MyMP) DoMPLine(DestBM,&FaceRect,S->SrcFakeBM,MyMP);
//	else
		RenderMoveLine(Line,DestBM,&S->TotalRect,&FaceRect,S->FakeLayer,S->SrcFakeBM,Flags);

// DEBUG
/*
	S->DstFakeBM->Planes[0] = DestBM->Planes[2];
	BltBitMap(S->DstFakeBM,S->TotalRect.MinX,0,
		InterfaceBM,S->TotalRect.MinX,0,
		(S->TotalRect.MaxX-S->TotalRect.MinX+1),
		(S->TotalRect.MaxY),
		0xc0,0x1,NULL);
*/

	WaitBlit();
	return(TRUE);
}

/****** NewScroll/DisplayScrollLine *********************************
*
*   NAME
*	DisplayScrollLine
*
*   SYNOPSIS
*	BOOL __asm DisplayScrollLine(
*		register __a0 struct CGLine *Line,
*		register __a1 struct BitMap *SrcBM,
*		register __d0 WORD MinY)
*
*   FUNCTION
*
********************************************************************/
BOOL __asm DisplayScrollLine(
	register __a0 struct CGLine *Line,
	register __a1 struct BitMap *SrcBM,
	register __d0 WORD MinY)
{
	register struct ScrollInfo *S;
	struct Rectangle *T;
	WORD W,MinX,H;
	struct Rectangle Clear;
	struct RastPort *RP;

	S = SI;
	T = &S->TotalRect;
	RP = RD->InterfaceRastPort;
	W = T->MaxX - T->MinX + 1;
	H = T->MaxY - T->MinY + 1;
	if (W > SCROLL_WIDTH) W = SCROLL_WIDTH;
	MinX = T->MinX + SCROLL_MIN_X;

	SetDrMd(RP,JAM2);
	SetAPen(RP,BG_PEN);

	Clear.MinY = MinY;
	Clear.MaxY = MinY + H - 1;
	if (T->MinX) {	// clear left side box
		Clear.MinX = SCROLL_MIN_X;
		Clear.MaxX = MinX;
		RectFill(RP,Clear.MinX,Clear.MinY,Clear.MaxX,Clear.MaxY);
	}

	// clear right side box
	Clear.MinX = MinX + W;
	Clear.MaxX = (RD->Interface->BytesPerRow << 3) - 1;
	RectFill(RP,Clear.MinX,Clear.MinY,Clear.MaxX,Clear.MaxY);

	BltBitMapRastPort(SrcBM,T->MinX,T->MinY,RP,MinX,MinY,W,H,0xc0);
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
********************************************************************/
BOOL __asm InitScrollRenderer(
	register __a0 UBYTE *ChipMem,
	register __a1 struct BitMap *TempChar,
	register __a2 struct BitMap *CharAlpha)
{
	BOOL Success = FALSE;
	register struct ScrollInfo *S;

	if (SI = SafeAllocMem(sizeof(struct ScrollInfo),MEMF_CLEAR)) {
		S = SI;
//		DumpMsg("InitScrollRenderer: Entry");
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

//		DumpMsg("InitScrollRenderer: OK");

		Success = TRUE;
		} } } } }
	}
	return(Success);
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

//		DumpMsg("OpenScrollLayers: OK");

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
********************************************************************/
VOID __asm FreeScrollRenderer(VOID)
{
	register struct ScrollInfo *S;

	if (S = SI) {
		if (S->DstFakeBM) HelpFreeBitMap(S->DstFakeBM);
		if (S->SrcFakeBM) HelpFreeBitMap(S->SrcFakeBM);

		if (S->ScrollBM) HelpFreeBitMap(S->ScrollBM);
		if (S->ScrollTextB) HelpFreeBitMap(S->ScrollTextB);
		if (S->ScrollTextA) HelpFreeBitMap(S->ScrollTextA);
		FreeMem(S,sizeof(struct ScrollInfo));
	}
}

//*******************************************************************
VOID __asm UpdateScrollInterface(
	register __d0 LONG DeltaY)
{
	struct RenderData *R;

	R = RD;
	R->ScrollYOffset += DeltaY;
	SetBPen(R->InterfaceRastPort,0);
	ScrollRaster(R->InterfaceRastPort,0,DeltaY,
		SCROLL_MIN_X,0,INTERFACE_WIDTH-1,INTERFACE_HEIGHT-1);

}

//*******************************************************************
BOOL __asm LineOnScreen(
	register __a0 struct CGLine *Line)
{
	UWORD A;

	A = RD->ScrollYOffset;

	if ((Line->YOffset < (A+INTERFACE_HEIGHT)) &&
		((Line->YOffset+Line->TotalHeight-1) >= A)) return(TRUE);
	return(FALSE);
}

//*******************************************************************
WORD __asm GetLineYOffset(
	register __a0 struct CGPage *Page,
	register __a1 struct CGLine *Line)
{
	WORD Y;

	Y = Line->YOffset;
	if (Page->Type == PAGE_SCROLL) Y -= RD->ScrollYOffset;
	return(Y);
}

//*******************************************************************
VOID __asm DisplayScrollUserLine(
	register __a0 struct CGLine *Line,
	register __d0 BOOL MoveScreen)
{
	struct RenderData *R;
	UWORD Y,LineMaxY;
	WORD A;

	R = RD;
	Y = R->ScrollYOffset;
	LineMaxY = Line->YOffset + Line->TotalHeight - 1;
	if (MoveScreen) {

// scroll up
		if (LineMaxY > (Y + INTERFACE_HEIGHT - 1)) {
			A = LineMaxY - (Y+INTERFACE_HEIGHT-1);
			UpdateScrollInterface(A);

// scroll down
		} else if (Line->YOffset < Y) {
			A = Line->YOffset - Y; // negative
			UpdateScrollInterface(A);
		}
	}

	if (LineOnScreen(Line)) {
		A = (WORD)Line->YOffset - (WORD)R->ScrollYOffset;
		DisplayScrollLine(Line,R->FullAlpha,A);
	}
}

//*******************************************************************
VOID __regargs DrawPropBox(
	struct RastPort *RP,
	WORD MinX,
	WORD MinY,
	WORD MaxX,
	WORD MaxY)
{

	SetDrMd(RP,JAM2);
	SetAPen(RP,2);
	RectFill(RP,MinX+2,MinY+2,MaxX-2,MaxY-2);
	NewBorderBox(RP,MinX,MinY,MaxX,MaxY,BOX_REV);
}

//*******************************************************************
// Adds/Removes page prop gadget, sets up initial prop pot/body
//
VOID __asm SetupPageProp(
	register __a0 struct CGPage *Page)
{
	struct Gadget *Gadget;
	struct RenderData *R;
	struct PropInfo *PInfo;
	struct Window *Window;

// check NewBarMode instead of BarMode because called from AllocBottomBar(),
// before BarMode set

	R = RD;
	Gadget = AllGadgets[ID_PAGE_PROP];
	PInfo = Gadget->SpecialInfo;
	if (PageProp) {
		if (PagePropType == PAGE_SCROLL) Window = R->InterfaceWindow;
		else if (PagePropType == PAGE_CRAWL) {
			Window = R->MenuBarWindow;
			if ((Window) && (R->NewBarMode != BAR_COLOR) &&
				(Window->Height > (BAR_0_MAXY+1)))
				MakeMenuBarHeight(BAR_0_MAXY+1);
		}
		if (Window) {
			RemoveGadget(Window,PageProp);

// when remove and stay on scroll page, clear imagery
			if ((PagePropType == PAGE_SCROLL) && (Page->Type == PAGE_SCROLL)){
				SetAPen(Window->RPort,0);
				SetDrMd(Window->RPort,JAM2);
				RectFill(Window->RPort,Gadget->LeftEdge-4,Gadget->TopEdge-2,
					Gadget->LeftEdge+Gadget->Width-1+4,
					Gadget->TopEdge+Gadget->Height-1+2);	
				WaitBlit();
			}
		}
		PageProp = NULL;
		PagePropType = 0;
	}
	if ((R->NewBarMode == BAR_NORMAL) || (R->NewBarMode == BAR_PAGE_CMDS)) {
	switch (Page->Type) {
		case PAGE_SCROLL:
		if (Window = R->InterfaceWindow) {
			Gadget->NextGadget = NULL;
			Gadget->Width = 10;
			Gadget->LeftEdge = TOP_MINX - Gadget->Width - 6;
			Gadget->Height = INTERFACE_HEIGHT-4;
			Gadget->TopEdge = 2;
			PInfo->HorizBody = MAXBODY;
			PInfo->HorizPot = 0;
			PInfo->VertBody = 0; // force update
			PInfo->VertPot = MAXPOT;
			PInfo->Flags = AUTOKNOB+FREEVERT+PROPBORDERLESS;
			AddGadget(Window,Gadget,-1);
			PagePropType = PAGE_SCROLL;
			PageProp = Gadget;
			DrawPropBox(Window->RPort,Gadget->LeftEdge-4,Gadget->TopEdge-2,
				Gadget->LeftEdge+Gadget->Width-1+4,
				Gadget->TopEdge+Gadget->Height-1+2);
		}
		break;

		case PAGE_CRAWL:
		if (Window = R->MenuBarWindow) {
			Gadget->NextGadget = NULL;
			Gadget->Width = BAR_WIDTH-4-1;
			Gadget->LeftEdge = 2;
			Gadget->Height = 10;
			Gadget->TopEdge = BAR_0_MAXY+6;
			if (Window->Height < BAR_0_MAXY+Gadget->Height+10)
				MakeMenuBarHeight(BAR_0_MAXY+Gadget->Height+10);

			PInfo->VertBody = MAXBODY;
			PInfo->VertPot = 0;
			PInfo->HorizBody = 1; // force update
			PInfo->HorizPot = MAXPOT;
			PInfo->Flags = AUTOKNOB+FREEHORIZ+PROPBORDERLESS;
			AddGadget(Window,Gadget,-1);
			PagePropType = PAGE_CRAWL;
			PageProp = Gadget;
			DrawPropBox(Window->RPort,Gadget->LeftEdge-2,Gadget->TopEdge-4,
				Gadget->LeftEdge+Gadget->Width-1+2,
				Gadget->TopEdge+Gadget->Height-1+4);
		}
	}
	}
}

//*******************************************************************
// Call anytime line added/deleted from page
// Modifies prop.body based on new page height
VOID __asm UpdatePageBody(
	register __d0 BOOL WholeRedraw)
{
	struct Gadget *Gadget;
	struct RenderData *R;
	struct PropInfo *PInfo;
	UWORD Pot,Body;
	struct CGPage *Page;
	struct Window *Window;

	R = RD;
	Page = R->CurrentPage;
	if (Gadget = PageProp) {
	PInfo = Gadget->SpecialInfo;
	switch (PagePropType) {
		case PAGE_SCROLL:
		if (Window = R->InterfaceWindow) {
		FindScrollerValues(GetScrollPageOff(Page),
			INTERFACE_HEIGHT,R->ScrollYOffset,0,&Body,&Pot);
		if (WholeRedraw) {
			DrawPropBox(Window->RPort,Gadget->LeftEdge-4,Gadget->TopEdge-2,
				Gadget->LeftEdge+Gadget->Width-1+4,
				Gadget->TopEdge+Gadget->Height-1+2);

			ModifyProp(Gadget,Window,NULL,PInfo->Flags,
				PInfo->HorizPot,Pot,PInfo->HorizBody,Body);
		}
		else if ((Pot != PInfo->VertPot) || (Body != PInfo->VertBody)) {
			NewModifyProp(Gadget,Window,NULL,PInfo->Flags,
				PInfo->HorizPot,Pot,PInfo->HorizBody,Body,1);
		}
		}
		break;

// treat CRAWL prop as Slider (not Scroller) since don't know
// how many characters will fit on screen (displayable)
// CrawlLineLength+1 because cursor can by at length
		case PAGE_CRAWL:
		if (Window = R->MenuBarWindow) {
		FindSliderValues(CrawlLineLength(Page)+1,R->CursorPosition,&Body,&Pot);
		if (WholeRedraw) {
			DrawPropBox(Window->RPort,Gadget->LeftEdge-2,Gadget->TopEdge-4,
				Gadget->LeftEdge+Gadget->Width-1+2,
				Gadget->TopEdge+Gadget->Height-1+4);

			ModifyProp(Gadget,Window,NULL,PInfo->Flags,
				Pot,PInfo->VertPot,Body,PInfo->VertBody);
		} else if ((Pot != PInfo->HorizPot) || (Body != PInfo->HorizBody)) {
			NewModifyProp(Gadget,Window,NULL,PInfo->Flags,
				Pot,PInfo->VertPot,Body,PInfo->VertBody,1);
		}
		}
	}
	}
}

//*******************************************************************
struct CGLine *__regargs FindCloseLine(
	struct CGPage *Page,
	UWORD Y)
{
	struct CGLine *Line,*Next;

	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ) {
		if (Line->YOffset >= Y) return(Line);
		Line = Next;
	}
	return((struct CGLine *)Page->LineList.mlh_TailPred);
}

//*******************************************************************
UWORD __regargs GetScrollPageOff(
	struct CGPage *Page)
{
	struct CGLine *Line;
	UWORD H = 0;

	if (Page->LineList.mlh_TailPred != (struct MinNode *)&Page->LineList) {
		Line = (struct CGLine *)Page->LineList.mlh_TailPred;
		H = Line->YOffset+Line->TotalHeight;
	}
	return(H);
}

//*******************************************************************
// Go from prop.pot to R->ScrollYOffset, update page
//
WORD __asm CasePageProp(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct Gadget *Gadget;
	struct RenderData *R;
	struct PropInfo *PInfo;
	UWORD Y;
	WORD Refresh = REFRESH_NONE;

	R = RD;
	if (IntuiMsg->Class == GADGETDOWN) {
	SoftSpriteOff();
	} else {
	if (Gadget = PageProp) {
		PInfo = Gadget->SpecialInfo;
		switch (R->CurrentPage->Type) {
			case PAGE_SCROLL:
				Y = FindScrollerTop(GetScrollPageOff(R->CurrentPage),
					INTERFACE_HEIGHT,PInfo->VertPot);
				if (Y != R->ScrollYOffset) {
					R->ScrollYOffset = Y;
					NewCurrentLine(FindCloseLine(R->CurrentPage,Y));
					R->UpdatePage = UPDATE_PAGE_OLD;
				}
			break;
			case PAGE_CRAWL:
				Y = FindSliderLevel(CrawlLineLength(R->CurrentPage)+1,
					PInfo->HorizPot);
				if (Y != R->CursorPosition) {
					NewCurrentCursor(Y);
					R->UpdatePage = UPDATE_PAGE_OLD;
				}
		}
	}
	Refresh = REFRESH_YES;
	SoftSpriteOnScreen(R->InterfaceScreen);
	}
	return(Refresh);
}

//*******************************************************************
VOID FindSliderValues(UWORD NumLevels,UWORD Level,UWORD *Body,UWORD *Pot)
{
	if (NumLevels > 0) (*Body) = (MAXBODY)/NumLevels;
	else (*Body) = MAXBODY;
	if (NumLevels > 1) (*Pot) = (((ULONG)MAXPOT) * Level)/(NumLevels-1);
	else (*Pot) = 0;
}

//*******************************************************************
UWORD FindSliderLevel(UWORD NumLevels,UWORD Pot)
{
	UWORD Level;

	if (NumLevels > 1) Level = (((ULONG)Pot)*(NumLevels-1)+MAXPOT/2)/MAXPOT;
	else Level = 0;
	return(Level);
}

//*******************************************************************
// make sure nothing messes up shared chip memory
// (only when in CG, not when in switcher)
//
VOID PrepareEffectBegin(VOID)
{
	struct RenderData *R;
	struct Window *W;

	R = RD;
	SoftSpriteOff();
	if (W = R->MenuBarWindow)
		if (MenuSave = W->FirstGadget) RemoveGList(W,W->FirstGadget,-1);
	if (W = R->InterfaceWindow)
		if (IntSave = W->FirstGadget) RemoveGList(W,W->FirstGadget,-1);

	PreRenderPage(R->CurrentPage,NULL);
		// in case cancelled pre-rendering of book
}

//*******************************************************************
// restore
//
VOID PrepareEffectEnd(VOID)
{
	struct RenderData *R;
	struct Window *W;

	R = RD;
	R->WholePropUpdate = TRUE;
	if (W = R->MenuBarWindow)
		if (MenuSave) AddGList(W,MenuSave,0,-1,NULL);
	if (W = R->InterfaceWindow)
		if (IntSave) AddGList(W,IntSave,0,-1,NULL);
	SoftSpriteOnScreen(R->InterfaceScreen);
}


BOOL	__asm InitIff()
{
	DUMPMSG("InitIff()");
	if(!(IFFBase = OpenLibrary(IFFNAME,IFFVERSION)))
		return(FALSE);
	return(TRUE);
}

void	__asm CloseIff()
{
	DUMPMSG("CloseIff()");
	if(IFFBase) CloseLibrary(IFFBase);	/* MUST ALWAYS BE CLOSED !! */
	IFFBase=NULL;
}

struct BitMap	*LoadBitMap(char *file, BOOL chip_bm)
{
	struct IFFL_BMHD *bmhd;
	ULONG *iff_file;
	UWORD w,h,d;
	struct BitMap	*bm;
	if(!(iff_file=IFFL_OpenIFF(file,IFFL_MODE_READ))) return(NULL);
	if(iff_file[2]==ID_ILBM || iff_file[2]==ID_ANIM )
		if((bmhd=IFFL_GetBMHD(iff_file)))
		{
			w=bmhd->w; h=bmhd->h; d=bmhd->nPlanes;
			if(chip_bm)
				bm=AllocBitMap(w,h,d,BMF_CLEAR,NULL);
			else
				bm=AllocFastBitMap(w,h,d);
			if(bm)
			{
				if(IFFL_DecodePic(iff_file,bm))
				{
					IFFL_CloseIFF(iff_file);
					return(bm);
				}
				FreeFastBitMap(bm);
			}
		}
	IFFL_CloseIFF(iff_file);
}


// *******************************************************************
ULONG __asm CountChars(register __a0 struct CGPage *Page)
{
	struct CGLine *Line,*Next;
	ULONG T=0,A;

//	DUMPMSG("CountChars");
	if (Page->Type == PAGE_EMPTY) return(0);
	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ)
	{
		A=0;
		while(Line->Text[A].Ascii)
			A++;
		Line = Next;
		T+=A;
	}
	return(T);
}

//*******************************************************************
// Count number of different char faces on page, by Ascii, AttrID (font),
// initialize letter array with index, attributes, XPos
// buf better point to enough mem for 3*max WORDs  (6*max bytes), let[max] also
// width,height  will  have the size for the big glyph BM
// now checking attributes, so multi-font pages do work
//
int __asm CountGlyphs(
	register __a0 struct CGPage *Page,
	register __a1 UWORD *buf,
	register __d0 int max,
	register __a2 struct Letter *let,
	register __a3 ULONG *Width,
	register __a4 ULONG *Height)
{
	struct CGLine *Line,*Next;
	struct ToasterFont *Font;
	struct ToasterChar *Char;
	int T=0,A,i,g=0;
	ULONG	aflags=0;
	UWORD	glyf,ID=0,LastID=6969,CharSP=0;
	struct Attributes *Attr;
	if (Page->Type == PAGE_EMPTY) return(0);

	Line = (struct CGLine *)Page->LineList.mlh_Head;		//importaint!!!

	*Height = 0;
	*Width = 0;

	//FixScrollPage(Page);
	JustifyThisPage(Page);		//all chars present but left just.
	//MakePageIDsOK(Page);			//on real effect.
	//if (RenderPage(Page,TRUE,FALSE))
	//	DUMPMSG("rendered alright");
	//else
	// DUMPMSG("Bad Render!");
	
	//FixScrollLineAttr(Page);
	

	DUMPMSG("CountGlyphs");
	while (Next = (struct CGLine *)Line->Node.mln_Succ)
	{
		if(Line->TotalHeight > *Height) *Height = Line->TotalHeight;
		A=0;
		while( (glyf=Line->Text[A].Ascii) )
		{
			//DUMPMSG("loop1 in CountGlyphs");
			i=0;
			if(Attr=Line->Text[A].Attr)		// changed attr means (possibly) changed font, O/S
			{
				LastID=ID;
				ID = Attr->ID;
				SET_SHADLEN(aflags,Attr->ShadowLength );
				SET_SHADTYPE(aflags,Attr->ShadowType );
				SET_OLTYPE(aflags,Attr->OutlineType );
				SET_SHADDIR(aflags,Attr->ShadowDirection );
				SET_SHADPRI(aflags,Attr->ShadowPriority );
			}
			while( ((glyf!=buf[i*3])||(ID!=buf[1+(i*3)])) && (i<max) && (buf[i*3]) )
				i++;
			if(i>=max) return(max);
			//DUMPMSG("BEFORE GetFontStructure");
			//DumpUDecW("ID: ",ID," ");
			if(LastID!=ID) Font = GetFontStructure(ID);
			//DUMPMSG("AFTER GetFontStructure");
			//DUMPMSG("Calling GetCharacterInfo");

//			DumpUDecW("Glyph: ",glyf,"\\");

//			sprintf(namebuff,"\t Glyph: %d",glyf);
//			DumpMsg(namebuff);
	
			//if(glyf!=32)
         	if((ID!=0)||(glyf!=32)) 
					Char=GetCharacterInfo(Font,glyf,0);
				else
					{
					Char=GetCharacterInfo(0,0,0);
					//DUMPMSG("had to call info000");	
					}	
			if( buf[i*3]==0 )  // new one! (no match found)
			{
				//DUMPMSG("Newone no match found.");	
				buf[i*3]=glyf;
				buf[1+(i*3)]=ID;
				buf[2+(i*3)]= Line->Temp[A].DataEndX - Line->Temp[A].DataStartX +1 ;
				if( (Page->Type == PAGE_CRAWL) && (Char) )
					buf[2+(i*3)] = Char->CharBitWidth;
				*Width += buf[2+(i*3)];
				g++;
			}
			let[T+A].Flags = aflags ;
			let[T+A].Index = i;
			if( (Page->Type == PAGE_CRAWL) && (Char) )
			{
				//DUMPMSG("In pg adj X");	
				let[T+A].XPos = Char->CharSpace - Char->CharBitWidth+Line->Text[A].Kerning + Char->CharKern;
//				let[T+A].XPos = CharSP + Line->Text[A].Kerning + Char->CharKern;
				let[T+A].Flags |= REL_XPOS;
			}
			else
				{

				Line->Temp[A].DataStartX += Line->XOffset;			//added 111095deh
				let[T+A].XPos = Line->Temp[A].DataStartX;

				//DumpSDecW("letxpos ",let[T+A].XPos,"  ");

				//DumpSDecW("XOffset ",Line->XOffset,"  ");
				//DumpSDecW("XPos===> ",Line->Temp[A].DataStartX,"  ");
				//DUMPMSG("Setting let - XPos");	
				}				

#ifdef DEBUG
			DumpUDecW("Letter: ",T+A,"  ");
			DumpUDecW("BitWidth: ",Char->CharBitWidth,"  ");
			DumpUDecW("Space: ",Char->CharSpace,"  ");
			DumpSDecW("XPos: ", let[T+A].XPos,"  ");
			DumpUDecW("Glyph Index: ",let[T+A].Index,"\\");
#endif
			A++;
		}
		T+=A;
		Line = Next;
	}
	//DUMPMSG("done counting Glyphs");	
	return(g);
}

#define BUFF_SIZE 90000 // uses R->ByteStrip->Planes[i]

// ****************************************************************************
//
void FillGlyphList(struct MovePage *MP)
{
	struct ToasterFont *Font;
	struct Glyph *Gly=MP->Glyphs;
	ULONG	X=0,g;
	UWORD	ID=0;
	WORD	X1;
	BOOL __asm (* Func)(
		register __a0 struct ToasterFont *Font,
		register __a1 struct BitMap *BitMap,
		register __d0 UWORD Glyph);
	Font = GetFontStructure(ID);
	Func = Font->GetCharAlpha;
	MP->W=(MP->Glyphs[0]).W;
	MP->H=(MP->Glyphs[0]).H;
	DUMPMSG("FillGlyphList");
	for(g=0;g<MP->GlyphNum;g++)
	{
		if(Gly[g].AttrIndx != ID)
		{
			ID = Gly[g].AttrIndx;
			Font = GetFontStructure(ID);
			if(Font->GetCharAlpha)
				Func = Font->GetCharAlpha;
		}
		Gly[g].H = Font->TextBM.Rows;
		if((Gly[g]).H > MP->H) MP->H=(Gly[g]).H;
		if((Gly[g]).W > MP->W) MP->W=(Gly[g]).W;
		Gly[g].Y=0;
		Gly[g].X=X;
		ClearBitMap(RD->FullAlpha);
		if((X1=Func(Font,RD->FullAlpha,Gly[g].Code)) > -1)
		{
			if(Gly[g].W>1)
			    BltBitMap(RD->FullAlpha,X1,0,MP->GBM,Gly[g].X,0,Gly[g].W,Gly[g].H,0xc0,0xff,NULL);
//			sprintf(namebuff,"Would be doing blit");
//			DumpMsg(namebuff);
		}
		//sprintf(namebuff,"Char: %c 	At:	 (%d,0)	 Size:	 (%d,%d)",(Gly[g].Code&0x00FF),Gly[g].X,Gly[g].W,Gly[g].H);
		//DumpMsg(namebuff);
		X += Gly[g].W;
	}
//	if(MP->tmpBM= AllocBitMap(MP->W+63,MP->H,2,BMF_CLEAR,NULL))
//	sprintf(namebuff,"all done with fillglyphlist");
//	DumpMsg(namebuff);
}

void ShowGlyphList(struct MovePage *MP)
{
	struct Glyph *Gly=MP->Glyphs;
	ULONG	g;
	for(g=0;g<MP->GlyphNum;g++)
	{
		sprintf(namebuff,"Glyphs[%d]: %c 	At:	 (%d,0)	 Size:	 (%d,%d)",g,(Gly[g].Code&0x00FF),Gly[g].X,Gly[g].W,Gly[g].H);
		DumpMsg(namebuff);
	}
}

void ShowLines(struct MovePage *MP)
{
	struct Glyph *Gly=MP->Glyphs;
	ULONG	g,i;
	for( MP->CurLine=0, MP->CurChar=0; MP->CurLine<MP->LineNum; MP->CurLine++)
	{
		DumpUDecL("Line # ",MP->CurLine,"  ");
		DumpUDecW(" At Y = ",MP->Lines[MP->CurLine].YPos,"   ");
		DumpUDecW(" has ",MP->Lines[MP->CurLine].Length," char.s \\");
		for( i=0; i<MP->Lines[MP->CurLine].Length; i++,MP->CurChar++ )
		{
			g=MP->Letters[MP->CurChar].Index;
			sprintf(namebuff,"   %c ",(Gly[g].Code&0x00FF));
			DumpStr(namebuff);
			DumpUDecW("Letter #: ",MP->CurChar,"  ");
			DumpSDecW("XPos: ",MP->Letters[MP->CurChar].XPos,"  ");
			DumpUDecW("Glyph: ",g," \\ ");
		}
	}
}

// ****************************************************************************
// Initialize Letter and Glyph array, and Glyph bitmap by counting char.s, glyphs
//	return number of glyphs temp bitmap, MP_>W,MP->H are not initialized 'til FillGlyphList()
struct MovePage *InitMovePage(struct CGPage *page)
{
	struct MovePage *MP;
	struct Letter *let;
	struct MPLine *lin;
	int g,i=0;
	struct Glyph *Gly;
	ULONG	W=0,H=0,c;
	UWORD	*buf;
	struct CGLine *Line,*Next;


	DUMPMSG("InitMovePage");
	if( !(c = CountChars(page)))	return(NULL);
	if(!(MP=SafeAllocMem(sizeof(struct MovePage), MEMF_CLEAR))) return(MP);
	MP->CharNum = c;

	Line = (struct CGLine *)page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ)
	{
		MP->LineNum++;
		Line = Next;
	}
	if(!(lin=SafeAllocMem(MP->LineNum*sizeof(struct MPLine), MEMF_CLEAR)))
	{
		FreeMem(MP,sizeof(struct MovePage));
		return(NULL);
	}
	MP->Lines=lin;
#ifdef DEBUG
	DumpUDecL("Alloc MP->Lines: ",MP->LineNum," Lines\\");
	DumpUDecL("               : ",MP->LineNum*sizeof(struct MPLine)," bytes\\");
	DumpHexiL("     @         : ",(LONG)MP->Lines,"\\");
#endif
	Line = (struct CGLine *)page->LineList.mlh_Head;
	MP->FaceColor = (Line->Text[0].Attr)->FaceColor;
	MP->OSColor = (Line->Text[0].Attr)->ShadowColor;
	MP->PlayMode = page->PlaybackMode  + 1; // -1,0,1 --> 0,1,2 (loop,once,freeze)
	MP->Speed = page->Speed;
	while (Next = (struct CGLine *)Line->Node.mln_Succ)
	{
		lin[i].Length = TextInfoLength(&Line->Text[0]);
		lin[i].YPos = Line->YOffset;
#ifdef DEBUG
		DumpUDecL("Line # ",i,"  ");
		DumpUDecW(" At Y = ",lin[i].YPos,"   ");
		DumpUDecW(" has ",lin[i].Length," char.s \\");
#endif
		i++;
		Line = Next;
	}

	if(!(let = (struct Letter *)SafeAllocMem(MP->CharNum*sizeof(struct Letter),MEMF_CLEAR)))
	{
		FreeMem(lin,MP->LineNum*sizeof(struct MPLine));
		FreeMem(MP,sizeof(struct MovePage));
		return(NULL);
	}
	if(!(buf = (UWORD *)SafeAllocMem(MP->CharNum*6,MEMF_CLEAR)))
	{
		FreeMem(lin,MP->LineNum*sizeof(struct MPLine));
		FreeMem(MP,sizeof(struct MovePage));
		FreeMem(let,MP->CharNum*sizeof(struct Letter));
		return(NULL);
	}
	MP->Letters = let;
	DUMPMSG("Calling CountGlyphs");
	g=CountGlyphs(page,buf,MP->CharNum,let,&W,&H);
	DUMPMSG("returned from CountGlyphs");	
	MP->GlyphNum = g;
#ifdef SERDEBUG
	DumpUDecL("Page Has ",MP->CharNum," Chars ");
	DumpUDecL("with ",MP->GlyphNum," different glyphs ");
	DumpUDecL("Size: ( ",W," x");
	DumpUDecL(" ",H," )\\ ");
#endif
	if( !(Gly=SafeAllocMem(MP->GlyphNum*sizeof(struct Glyph),MEMF_CLEAR)) )
	{
		FreeMem(lin,MP->LineNum*sizeof(struct MPLine));
		FreeMem(MP,sizeof(struct MovePage));
		FreeMem(let,MP->CharNum*sizeof(struct Letter));
		FreeMem(buf,MP->CharNum*6);
		return(NULL);
	}

	for(i=0;i<MP->GlyphNum;i++)
	{
		Gly[i].Code = buf[i*3];
		Gly[i].AttrIndx = buf[1+(i*3)];
		Gly[i].W = buf[2+(i*3)];
	}

	FreeMem(buf,MP->CharNum*6);
	MP->Glyphs=(struct Glyph *)Gly;
//	DumpUDecL("\\Alloc BM: ( ",W," x");
//	DumpUDecL(" ",H," ) ");

//	MP->GBM=AllocBitMap(W,H,2,BMF_CLEAR,NULL); // should use allocated chip in scrolltext planes

	DUMPMSG("allocating bitmap");
	MP->GBM=AllocChipBitMap(W,H,2); // should use allocated chip in scrolltext planes
	DUMPMSG("done allocating bitmap");
	if(!MP->GBM)
	{
		NewBM=0;
//		DumpMsg("Can't get NEW Chip BM!!");
		MP->GBM=HelpAllocBitMap(W,H,2,(UBYTE *)(SI->ScrollTextA->Planes[0]),FALSE);
		ClearBitMap(MP->GBM);
	}
	else NewBM=1;

	if(!(MP->Glyphs && MP->GBM))
	{
		DumpMsg("Can't get Chip BM!!");
		FreeMem(lin,MP->LineNum*sizeof(struct MPLine));
		FreeMem(let,MP->CharNum*sizeof(struct Letter));
		if(NewBM && MP->GBM) FreeFastBitMap(MP->GBM);
		FreeMem(MP,sizeof(struct MovePage));
		return(NULL);
	}
//	DumpHexiL("    @       : ",(LONG)MP->GBM,"\\");
	return(MP);
}

void FreeMovePage(struct MovePage *MP)
{
	if(MP)
	{
//		DumpUDecL("Free MP->Glyphs: ",MP->GlyphNum*sizeof(struct Glyph)," bytes\\");
//		DumpHexiL("    @         : ",(LONG)MP->Glyphs,"\\");
		if(MP->Glyphs)	FreeMem(MP->Glyphs,	MP->GlyphNum*sizeof(struct Glyph));
//		DumpUDecL("Free MP->Letters: ",MP->CharNum*sizeof(struct Letter)," bytes\\");
//		DumpHexiL("    @         : ",(LONG)MP->Letters,"\\");
		if(MP->Letters)	FreeMem(MP->Letters,	MP->CharNum*sizeof(struct Letter));
//		DumpUDecL("Free MP->Lines: ",MP->LineNum*sizeof(struct MPLine)," bytes\\");
//		DumpHexiL("    @         : ",(LONG)MP->Lines,"\\");
		if(MP->Lines)		FreeMem(MP->Lines,MP->LineNum*sizeof(struct MPLine));
//		DumpUDecL("Free MP->GBM: ",sizeof(struct BitMap)," bytes\\");
//		DumpHexiL("    @       : ",(LONG)MP->GBM,"\\");

//		if(NewBM && MP->GBM) FreeBitMap(MP->GBM);

		if(NewBM && MP->GBM) FreeFastBitMap(MP->GBM);

		if(MP->tmpBM) FreeBitMap(MP->tmpBM);
//		DumpUDecL("Free MP: ",sizeof(struct MovePage)," bytes\\");
		FreeMem(MP,sizeof(struct MovePage));
	}
}

int MPSize(struct MovePage *MP)
{
	int n=sizeof(struct MovePage);
	n +=MP->GlyphNum*sizeof(struct Glyph);
	n +=MP->CharNum*sizeof(struct Letter);
	n +=MP->LineNum*sizeof(struct MPLine);
	return(n);
}

//int SCSpeed[]={1,1,2,3,4,5,6,7,8}; //  lines/field
int SCSpeed[]={1,1,2,3,4,5,6,7,8}; //  lines/field
int CRSpeed[]={2,4,8,16};  //  pixs/field
// calculate duration of Moving Page while moving, including clear off screen
int MPDuration(struct MovePage *MP, UBYTE PType)
{
	int n=0,dist,i;

#ifdef DEBUG
	kprintf("Speed is %ld\n",MP->Speed);
#endif

	if(PType==PAGE_SCROLL)
	{
#ifdef DEBUG
		kprintf("Factor is %ld\n",SCSpeed[MP->Speed]);
#endif
		dist = 480;
		if(MP->PlayMode!=PLAY_FREEZE) dist += 480; // Get text off screen
		dist += (MP->Lines[MP->LineNum-1]).YPos + MP->H;
		dist += dist/5;				//posable fix for scroll problem.
//This was broken, because speed is already in lines/field!
		if(MP->Speed)
			n=dist/SCSpeed[MP->Speed];
		else
			n=dist*2; // Slowest = 1/2 line/field

#ifdef DEBUG
		kprintf("Scroll distance = %ld\n",dist);
		kprintf("Fields = %ld\n",n);
#endif
	}
	else if(PType==PAGE_CRAWL)
	{
		struct Letter *let;
		struct Glyph	*gly;
		dist = 768<<1; // Space to get on and off screen
		for(i=0; i<MP->CharNum; i++)
		{
			let=&(MP->Letters[i]);
			gly = &(MP->Glyphs[let->Index]);
			dist += gly->W + let->XPos;
		}
//	if(MP->Speed)
		n=dist/CRSpeed[MP->Speed];

#ifdef DEBUG
		kprintf("Crawl distance = %ld\n",dist);
		kprintf("Fields = %ld\n",n);
#endif
	}
	return(n);
}

// Fix field count for page based on new speed
int NewDuration(int Dur, int OldSpeed, int NewSpeed, UBYTE PType)
{
	int n=0,dist,i;

	if(OldSpeed==NewSpeed) return(Dur);
	if(PType==PAGE_SCROLL)
	{
		if(OldSpeed)
			dist=SCSpeed[OldSpeed]*Dur;
		else
			dist = Dur/2;

		if(NewSpeed)
			n=dist/SCSpeed[NewSpeed];
		else
			n=dist*2; // Slowest = 1/2 line/field
	}
	else if(PType==PAGE_CRAWL)
	{
		dist=CRSpeed[OldSpeed]*Dur;
		n=dist/CRSpeed[NewSpeed];
	}

#ifdef DEBUG
	kprintf("Old speed was %ld, new is %ld\n",OldSpeed,NewSpeed);
#endif

	return(n);
}


// ********************************************************************
// Writes MovePage into file (already opened and positioned)
int WriteMP(struct BufferLock *LB,struct MovePage *MP)
{
	int	n=0;
	DUMPMSG("WriteMP");
//	DumpStr(" Write: ");
	if(CR_ERR_NONE !=BufferWrite(LB,(UBYTE *)MP,sizeof(struct MovePage))) return(n);
	n += sizeof(struct MovePage);
//	DumpStr(" MP ");
	if(CR_ERR_NONE !=BufferWrite(LB,(UBYTE *)MP->Glyphs,MP->GlyphNum*sizeof(struct Glyph))) return(n);
	n += MP->GlyphNum*sizeof(struct Glyph);
//	DumpStr(" Glyphs ");
	if(CR_ERR_NONE !=BufferWrite(LB,(UBYTE *)MP->Letters,	MP->CharNum*sizeof(struct Letter) )) return(n);
	n += MP->CharNum*sizeof(struct Letter);
//	DumpStr(" Letters ");
	if(CR_ERR_NONE !=BufferWrite(LB, (UBYTE *)MP->Lines,MP->LineNum*sizeof(struct MPLine))) return(n);
	n += MP->LineNum*sizeof(struct MPLine);
	return(n);
}

// ********************************************************************
// Allocates and fills  MovePage from file (already opened and positioned)
struct MovePage *ReadMP(struct BufferLock *LB)
{
	struct MovePage *MP;
	if (!LB->File) return(NULL);
	if(!(MP=SafeAllocMem(sizeof(struct MovePage), MEMF_CLEAR))) return(MP);
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP,sizeof(struct MovePage))) goto Failure;
	if(!(MP->Glyphs = (struct Glyph *)	SafeAllocMem(MP->GlyphNum*sizeof(struct Glyph),MEMF_CLEAR))) goto Failure;
	if(!(MP->Letters = (struct Letter *)SafeAllocMem(MP->CharNum*sizeof(struct Letter),MEMF_CLEAR))) goto Failure;
	if(!(MP->Lines = (struct MPLine *)	SafeAllocMem(MP->LineNum*sizeof(struct MPLine), MEMF_CLEAR))) goto Failure;

	if(CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP->Glyphs ,MP->GlyphNum*sizeof(struct Glyph) )) goto Failure;
	if(CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP->Letters,MP->CharNum*sizeof(struct Letter) )) goto Failure;
	if(CR_ERR_NONE != BufferRead(LB,(UBYTE *)MP->Lines	,MP->LineNum*sizeof(struct MPLine) )) goto Failure;
	MP->GBM = NULL;
	MP->tmpBM = NULL;

  return(MP);
Failure:	// OK so i created a goto...  i feel dirty, but look at InitMovePage()..
	if(MP)
	{
		if(MP->Glyphs) FreeMem(MP->Glyphs,	MP->GlyphNum*sizeof(struct Glyph));
		if(MP->Letters) FreeMem(MP->Letters,	MP->CharNum*sizeof(struct Letter));
		if(MP->Lines) FreeMem(MP->Lines,MP->LineNum*sizeof(struct MPLine));
		FreeMem(MP,sizeof(struct MovePage));
	}
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

	if ((LB = BufferOpen(file,MODE_OLDFILE,1024,NULL)))
	{
		if( (CR_ERR_NONE==BufferRead(LB,(UBYTE *)Buff,12)) && (Buff[0]==FORM) )
		{
			while(Buff[2]!=MVPG)
			{
/*
				DumpHexiL("MPChunk: ",Buff[0],"  { ");
				DumpStr((UBYTE *)Buff);
				DumpUDecL(" }  Size: ",Buff[1],"  ");
				DumpHexiL("Type: ",Buff[2],"   ");
				DumpMsg((UBYTE *)&(Buff[2]));
*/
				BufferSeek( LB, Buff[1]-4, OFFSET_CURRENT );		// Skip chunk
				if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,12)) break;
			}
			MP=ReadMP(LB);
			//if( MP ) ShowGlyphList(MP);
		}
		BufferClose(LB);
		if( MP )
			if(MP->GBM=LoadBitMap(file,0))
				if(MP->tmpBM = AllocBitMap(MP->W+63,MP->H,MP->GBM->Depth,BMF_CLEAR,NULL))
					return(MP);
		FreeMovePage(MP);
	}
	return(NULL);
}

//*******************************************************************************
// Save MovePage bitmap, structure, and data  still needs icon, CrUD appended
void	SaveMovePage(char *name,struct MovePage *MP)
{
	ULONG	PUS[6]={FORM,16,PUSS,ILBM,4,0},buf[3];
	WORD ColorTab[4]={0x000,0xF00,0x0F0,0x00F};
	struct BufferLock *file;

	DUMPMSG("SaveMovePage");
	ColorTab[1] = RGB2Amiga12(&(MP->FaceColor));
	ColorTab[2] = RGB2Amiga12(&(MP->OSColor));
	DUMPMSG("ABOUT TO SAVE THE BITMAP");
	IFFL_SaveBitMap(name,MP->GBM,ColorTab,1);
//	DumpStr("Saved ");
	DUMPMSG("BITMAP SAVED");
	if (file = BufferOpen(name,MODE_READWRITE,1024,NULL))
	{
//		DumpStr(name);
		BufferSeek(file,0,OFFSET_BEGINNING);
		if( (CR_ERR_NONE==BufferRead(file,(UBYTE *)buf,12)) && (buf[0]==FORM) )
		{
			PUS[5]=buf[1]; // size
			PUS[3]=buf[2]; // type
			BufferSeek(file,0,OFFSET_END);
			BufferWrite(file,(UBYTE *)PUS,24);
			buf[1] = MPSize(MP) + 4;
			PUS[5]=buf[1]; // size
			buf[2] = MVPG; // type
			PUS[3]=buf[2];
			BufferWrite(file,(UBYTE *)buf,12);
			buf[0]=WriteMP(file,MP); // should return buf[1]-4, unless error
			BufferWrite(file,(UBYTE *)PUS,24);
#ifdef DEBUG
			sprintf(namebuff,"\t MVPG size nom.: %d	 Act.: %d	",buf[1],buf[0]+4);
			DumpMsg(namebuff);
			ShowGlyphList(MP);
#endif
		}
		BufferClose(file);
	}
}

void	ShowMovePage(struct MovePage *MP)
{
	struct Rectangle rectum;
	struct BitMap	*tmp;
	DumpMsg("ShowMovePage");

	if(tmp=AllocBitMap( (RD->Interface->BytesPerRow)<<3, (RD->Interface)->Rows,1,BMF_CLEAR,NULL ))
	{
		for( MP->CurLine=0, MP->CurChar=0; MP->CurLine<MP->LineNum; MP->CurLine++)
	//		RenderMPLine(RD->Interface,MP,&rectum);
			DoMPLine(RD->Interface,&rectum,tmp,MP);
		MP->CurLine=0;
		MP->CurChar=0;
		FreeBitMap(tmp);
	}
}

// render current char into destBM, return dx for new X
UWORD RenderMPChar(
	struct BitMap *DestBM, // dest chip BM
	struct MovePage *MP,
	WORD X, WORD Y)
{
	struct BitMap *tbm = MP->tmpBM, FBM1,FBM2;
	struct Letter *let;
	struct Glyph	*gly;
	int	dx;
	struct Rectangle Face,Out,Shad;
	UWORD	W=0;

	FBM1 = *tbm;
	FBM1.Depth = 1;
	FBM2 = *DestBM;
	FBM2.Depth = 1;
	FBM2.Planes[0] = DestBM->Planes[2] ;
	if(MP->CurChar<MP->CharNum)
	{
		let=&(MP->Letters[MP->CurChar]);
		if(let->Flags & REL_XPOS) X += let->XPos;

		Face.MinX = X;
		Face.MinY = 0;

		gly = &(MP->Glyphs[let->Index]);
		dx = gly->X&0x001F;	  // last 5 bits offset due to long alignment in Copy LongBlock
		CopyLongBlock(MP->GBM,tbm,gly->X,gly->Y,gly->W,gly->H);
		BltBitMap(tbm,dx,0,DestBM,X,Y,gly->W,gly->H,0xe0,0x7,NULL); // MinTerm 60 = B&~C + ~B&C
		BltBitMap(DestBM,X,Y,tbm,dx,0,gly->W,gly->H,0x00,0x3,NULL); // MinTerm 00 =Clear?
		MP->CurChar++;
		W = gly->W;
		Face.MaxX = gly->W-1;
		Face.MaxY = gly->H-1;
		if(let->Flags & REL_XPOS) W += let->XPos;
		WaitBlit();
		if( SHADTYPE((MP->Letters[MP->CurChar]).Flags) || OLTYPE((MP->Letters[MP->CurChar]).Flags) )
		{
			CalcOSRect((MP->Letters[MP->CurChar]).Flags,&Face,&Shad,&Out); // SO not clipped
			ORIntoMS(DestBM,&Face); // OR into BP 2
			if (OLTYPE((MP->Letters[MP->CurChar]).Flags) )
			{
				BltClear(FBM1.Planes[0],FBM1.BytesPerRow*FBM1.Rows,1);
				DoBMOutline(&FBM2,&Face,&FBM1,Out.MinX,Out.MinY,OLTYPE((MP->Letters[MP->CurChar]).Flags) );
			}
			else BltBitMap(&FBM2,Face.MinX,Face.MinY,&FBM1,Face.MinX,Face.MinY,
				(Face.MaxX-Face.MinX+1),(Face.MaxY-Face.MinY+1),
				0xc0,0x1,NULL);
			if (SHADTYPE((MP->Letters[MP->CurChar]).Flags) )		// make shadow into BP 2
				MakeBMShadow(&FBM1,&Out,&FBM2,&Shad,TRUE,Out.MinX,Out.MinY,(MP->Letters[MP->CurChar]).Flags);
			else BltBitMap(&FBM1,Out.MinX,Out.MinY,&FBM2,Out.MinX,Out.MinY,
				(Out.MaxX-Out.MinX+1),(Out.MaxY-Out.MinY+1),0xc0,0x1,NULL);
		}
	}
	else MP->CurChar = 0;
	return(W);
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
	UWORD	X=0,Y,dx;

	if(MP->CurLine<MP->LineNum)
	{
		Y = 0; //MP->Lines[MP->CurLine].YPos;
		rect->MinY = Y;
		rect->MaxY = Y + MP->H;
		rect->MinX = let->XPos;
		Y%=400;

		for( i=0; i<MP->Lines[MP->CurLine].Length; i++ )
		{
			if(let->Flags & REL_XPOS)
				X += let->XPos;
			else
				X = let->XPos;
			gly = &(MP->Glyphs[let->Index]);
			dx = gly->X&0x001F;	  // last 5 bits offset due to long alignment in Copy LongBlock
//			sprintf(namebuff,"Line: %d Let[%d]=%c\tIndex: %d\tFastBlit: %d %d %d %d ",MP->CurLine,MP->CurChar,gly->Code&0x00ff, let->Index,gly->X,gly->Y,gly->W,gly->H);
//			DumpStr(namebuff);
			CopyLongBlock(MP->GBM,tbm,gly->X,gly->Y,gly->W,gly->H);
//			sprintf(namebuff,"  ChipBlit: %d 0 TO %d %d ",dx,X,Y);
//			DumpMsg(namebuff);
			BltBitMap(tbm,dx,0,DestBM,X,Y,gly->W,gly->H,0xe0,0x7,NULL); // MinTerm 60 = B&~C + ~B&C
			BltBitMap(DestBM,X,Y,tbm,dx,0,gly->W,gly->H,0x00,0x3,NULL); // MinTerm 00 =Clear?
			MP->CurChar++;
			let++;
		}
		rect->MaxX = X + gly->W;
		WaitBlit();
		sprintf(namebuff,"FaceRect: %d %d %d %d ",rect->MinX,rect->MinY,rect->MaxX,rect->MaxY);
//		DumpMsg(namebuff);
	}
	else
	{
		MP->CurLine = 0;
		MP->CurChar = 0;
	}
}

BOOL TestMP(char *buf)
{
	if(MyMP=LoadMovePage(buf))
		ShowMovePage(MyMP);
	FreeMovePage(MyMP);
	MyMP=NULL;
	return(FALSE);
}

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
/*
	struct Attributes Attr;

	Attr.ShadowLength 		= SHADLEN(AtrFlags);
	Attr.ShadowType 			= SHADTYPE(AtrFlags);
	Attr.OutlineType 			= OLTYPE(AtrFlags);
	Attr.ShadowDirection 	= SHADDIR(AtrFlags);
	Attr.ShadowPriority 	= SHADPRI(AtrFlags);
*/
	TempBP = TempBM->Planes[0];

// always render the line at the top of the DestBM
	ClearYBlock(DestBM,0,MP->H-1);

// make face in BP 0,1
		RenderMPLine(DestBM,MP,FaceRect); // FaceRect clipped
		WaitButton();

	CalcOSRect(AtrFlags,FaceRect,&ShadRect,&OutRect); // SO not clipped
		sprintf(namebuff,"\tShadRect: %d %d %d %d ",ShadRect.MinX,ShadRect.MinY,ShadRect.MaxX,ShadRect.MaxY);
		DumpMsg(namebuff);
		sprintf(namebuff,"\tOutRect: %d %d %d %d ",OutRect.MinX,OutRect.MinY,OutRect.MaxX,OutRect.MaxY);
		DumpMsg(namebuff);

// if no out/shad, done
	if( SHADTYPE(AtrFlags) || OLTYPE(AtrFlags) )
	{
		BltClear(DestBM->Planes[2],DestBM->BytesPerRow*DestBM->Rows,1);
		ORIntoMS(DestBM,FaceRect); // OR into BP 2
// make outline into Temp BP
		TempBM->Planes[0] = DestBM->Planes[2];
		FakeBM->Planes[0] = TempBP;
		if (OLTYPE(AtrFlags))
		{
			BltClear(TempBP,FakeBM->BytesPerRow*FakeBM->Rows,1);
			DoBMOutline(TempBM,FaceRect,FakeBM,OutRect.MinX,OutRect.MinY,OLTYPE(AtrFlags));
		}
		else BltBitMap(TempBM,FaceRect->MinX,FaceRect->MinY,
			FakeBM,FaceRect->MinX,FaceRect->MinY,
			(FaceRect->MaxX-FaceRect->MinX+1),(FaceRect->MaxY-FaceRect->MinY+1),
			0xc0,0x1,NULL);

// make shadow into BP 2
		TempBM->Planes[0] = TempBP;
		FakeBM->Planes[0] = DestBM->Planes[2];
		if (SHADTYPE(AtrFlags))
		{
			MakeBMShadow(TempBM,&OutRect,FakeBM,&ShadRect,
				TRUE,OutRect.MinX,OutRect.MinY,AtrFlags);
		} else BltBitMap(TempBM,OutRect.MinX,OutRect.MinY,
			FakeBM,OutRect.MinX,OutRect.MinY,
			(OutRect.MaxX-OutRect.MinX+1),(OutRect.MaxY-OutRect.MinY+1),
			0xc0,0x1,NULL);
	}
	WaitButton();
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
	W = SourceRect->MaxX-SourceRect->MinX+1;
	H = SourceRect->MaxY-SourceRect->MinY+1;
	DX = ShadowDX[SHADDIR(AtrFlags)];
	DY = ShadowDY[SHADDIR(AtrFlags)];
	if (SHADTYPE(AtrFlags) == SHADOW_DROP) {
		for (A = 0; A < SHADLEN(AtrFlags); A++) {
			BltBitMap(SourceBM,SourceRect->MinX,SourceRect->MinY,
				DestBM,X,Y,W,H,0xe0,1,NULL);
			X += DX;
			Y += DY;
		}
	} else { // SHADOW_CAST
		BltBitMap(SourceBM,SourceRect->MinX,SourceRect->MinY,
			DestBM,X+(DX * SHADLEN(AtrFlags)),
				Y+(DY * SHADLEN(AtrFlags)),W,H,0xc0,1,NULL);
		if (IncludeFaceInCast)
			BltBitMap(SourceBM,SourceRect->MinX,SourceRect->MinY,
				DestBM,X,Y,W,H,0xe0,1,NULL);
	}
}

//***********************************************
VOID __regargs CalcShad(
	ULONG flags,
	struct Rectangle *Source,
	struct Rectangle *Shadow)
{
	WORD A;

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
		Outline->MaxY += (OS->TotalHeight-OS->LeftHeight);
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

BOOL __asm CalcOSMinMax(
	register __d0 ULONG flags,
	register __a0 struct Rectangle *FaceRect)
{
	struct Rectangle ShadowRect,OutlineRect;

	if (SHADPRI(flags)) { // shadow comes first
		CalcShad(flags,FaceRect,&ShadowRect);
		CalcOL(flags,&ShadowRect,&OutlineRect);
		CopyMem(&OutlineRect,FaceRect,sizeof(struct Rectangle));
	} else {
		CalcOL(flags,FaceRect,&OutlineRect);
		CalcShad(flags,&OutlineRect,&ShadowRect);
		CopyMem(&ShadowRect,FaceRect,sizeof(struct Rectangle));
	}
	return(TRUE);
}


VOID __asm CalcOSYMinMax(
	register __d0 ULONG flags,
	register __a1 struct Rectangle *Rect)
{
	WORD A;
	struct OutlineStuff *OS;
	WORD TestDX1,TestDX2;

	TestDX1 = TestDX2 = 0;
	if (SHADTYPE(flags))
	{
		A = ShadowDX[SHADDIR(flags)] * SHADLEN(flags);
		if (A > 0) TestDX2 = A;
		else if (A < 0) TestDX1 = A;
	}
	if (OLTYPE(flags))
	{
		OS = &Outlines[OLTYPE(flags)];
		TestDX1 -= OS->LeftWidth;
		TestDX2 += (OS->TotalWidth-OS->LeftWidth);
	}
	Rect->MinX = TestDX1;
	Rect->MaxX = TestDX2;
}


// end of newscroll.c
