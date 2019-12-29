/********************************************************************
* newgadgets.c 
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
* $Id: NewGadgets.c,v 2.0 1995/08/31 15:27:31 Holt Exp $
* $Log: NewGadgets.c,v $
 * Revision 2.0  1995/08/31  15:27:31  Holt
 * FirstCheckIn
 *
*********************************************************************/
/********************************************************************
* NewGadgets.c
*
* Copyright �1993 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	2-27-93	Steve H		Created
*	6-5-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <stdio.h>
#include <string.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <proto/intuition.h>

#include <book.h>
#include <newsupport.h>
#include <gadgets.h>
#include <toastfont.h>
#include <newfunction.h>
#include <newscroll.h>
#include <panel.h>
#include <cg:popup/popup.h>
#include <commonrgb.h>

void DrawSafeArea(struct RastPort *);
#ifndef PROTO_PASS
extern long            IsRexxMsg( struct RexxMsg *msg );
#include "protos.h"
#endif

#define NUM_CORNERS 8
#define COPY_LEN 60
#define TEXT_PEN 3
//#define DISABLE(g)	g->Flags |= GFLG_DISABLED;
//#define ENABLE(g)	g->Flags &= (~GFLG_DISABLED);

extern struct NewWindow NewWindowStructure1;
extern struct RenderData *RD;
extern struct Gadget Gadget1,*FirstGadget;
extern BOOL DraggingBar;
extern struct Gadget *BKGList,*LoadList,*TopBtmList,*TextTopBtmList,*TCList,
  *DraggingSlider,*AlphaList,*RGBList,*OLTopBtmList,*OCList;
extern struct Gadget *PageProp;
extern struct MsgPort *CGRexxPort;

extern char Dummy[],DefaultMsg[],BadTypeMsg[],FontInfoMsg1[],FontInfoMsg2[],
	SpaceMsg[],DefFileName[],Def2Path[],FontInfoMsg3[],
	FontInfoMsg4[],*FontTypeText[],BrushTypeText[],BoxTypeText[],*DrawTypeText[],
	Def3File[],Def2File[],SaveBookSuccess[],SaveBookFail[],OverWriteBook[],Def3File[],
	FontInfoMsg5[],FontInfoMsg6[],FontInfoMsg7[],DefaultAAMsg[],
	NoProjMsg[],OutMemoryMsg[],PagesPath[];

ULONG WaitMask;
struct Gadget *CurrentBarList,*CurrentBottomList,
	*AllGadgets[TOTAL_GADGETS];
char SliderLabels[4][2] = "R","G","B","A";
WORD OpenY = TOP_MINY,BottomMaxX = 0;

struct st_PopupRender PopUp;

//*******************************************************************
BOOL __asm TemplateOn(
	register __d0 UWORD BarMode)
{
	BOOL Success = TRUE;

	if (!RD->MenuBarWindow) {
		Success = OpenMenuBar(BarMode);
	} else {
		if (RD->BarMode != BarMode) {
			RenderBar(BarMode);
		}
	}
	return(Success);
}

//*******************************************************************
VOID TemplateOff(VOID)
{
	struct Window *Window;

	if (Window = RD->MenuBarWindow) {
		CloseMenuBar();
		RD->UpdateInterface = TRUE;
	}
}

//*******************************************************************
// Done once, when program started
VOID BuildGadgetArray(VOID)
{
	UWORD A;
	if(InitGadgetImagery())
		for (A = 0; A < TOTAL_GADGETS; A++)
		{
			if (!(AllGadgets[A] = FindGadget(FirstGadget,A)))
			{
				DisplayBeep(NULL);
			}
			AllGadgets[A] = FindGadget(FirstGadget,A);
		}
}

//*******************************************************************
struct Gadget *__regargs FindGadget(
	struct Gadget *FirstGadget,
	UWORD GadgetID)
{
	struct Gadget *ThisGadget;

	if (FirstGadget) {
		ThisGadget = FirstGadget;
		while (ThisGadget) {
			if (ThisGadget->GadgetID == GadgetID) return(ThisGadget);
			ThisGadget = ThisGadget->NextGadget;
		}
	}
	return(NULL);
}

//*******************************************************************
// Handle any non-ARexx messages received
WORD __regargs ProcessMessage(
	struct IntuiMessage *IntuiMsg)
{
	WORD Result = REFRESH_NONE;
	WORD __asm (*Handler)(register __a0 struct IntuiMessage *);
	struct Gadget *Gadget;
	struct IntuiMessage CopyMsg;

	CopyMem(IntuiMsg,&CopyMsg,sizeof(struct IntuiMessage));
	ReplyMsg((struct Message *)IntuiMsg);

  if( RD->BarMode==BAR_FEP && FindFEP() )  // FEP in control
  {
    FEP_IntuiMsg(&CopyMsg);
    return(REFRESH_NONE);
  }
	switch (CopyMsg.Class) {
		case IDCMP_RAWKEY:
			if (DraggingBar) Result = ReleaseBar(&CopyMsg);
			else Result = CaseRawKey(&CopyMsg);
			break;

		case IDCMP_GADGETDOWN:
		case IDCMP_GADGETUP:
			if (DraggingBar) {
				Result = ReleaseBar(&CopyMsg);
			}
			else {
				Gadget = CopyMsg.IAddress;
				Handler = (WORD __asm (*)(register __a0 struct IntuiMessage *))Gadget->UserData; // ignore warning
				if (Handler) Result = Handler(&CopyMsg);
			}
			break;

		case MOUSEBUTTONS:
			if (DraggingBar) Result = ReleaseBar(&CopyMsg);
			else Result = HandleButton(&CopyMsg,RD->CurrentPage);
			break;

		case MOUSEMOVE:
			if (DraggingBar) MoveBar(&CopyMsg);
			else if (DraggingSlider) HandleSliderMove();
			else Result = HandleMouseMove(&CopyMsg,RD->CurrentPage);
			break;
	}

	return(Result);
}

//*******************************************************************
VOID EraseEditPage(VOID)
{
	struct RenderData *R;

	R = RD;
	if ((R->OldPageType != 255) && (R->OldPageType != PAGE_EMPTY)) {
		if (R->OldPageType == PAGE_SCROLL) {
			SetAPen(R->InterfaceRastPort,0);
			SetDrMd(R->InterfaceRastPort,JAM2);
			RectFill(R->InterfaceRastPort,SCROLL_MIN_X,0,INTERFACE_WIDTH-1,
				INTERFACE_HEIGHT-1);
			WaitBlit();
		} else EraseTotalInterface();
	}
}

//*******************************************************************
VOID EraseTotalInterface(VOID)
{
	if (RD->InterfaceRastPort) {
		SetRast(RD->InterfaceRastPort,0);
		WaitBlit();
	}
}

//*******************************************************************
ULONG BuildWaitMask(VOID)
{
	ULONG Mask;

	struct RenderData *R;

	R = RD;
	Mask = 1 << R->InterfaceWindow->UserPort->mp_SigBit;
	if (R->MenuBarWindow)	Mask |= 1 << R->MenuBarWindow->UserPort->mp_SigBit;
	if(CGRexxPort) Mask |= 1 << CGRexxPort->mp_SigBit;
	return(Mask);
}

//*******************************************************************
WORD WaitForKey(VOID)
{
	BOOL Done = FALSE;
	WORD Code = 0;
	struct IntuiMessage *IntuiMsg;
	struct RenderData *R;

	R = RD;
	goto Proc;
	while (!Done) {
		Wait(WaitMask);
Proc:
		while ((IntuiMsg = (struct IntuiMessage *)GetMsg(R->InterfaceWindow->
			UserPort)) ||
			(R->MenuBarWindow && (IntuiMsg = (struct IntuiMessage *)
				GetMsg(R->MenuBarWindow->UserPort)))) {
			switch(IntuiMsg->Class) {
			case IDCMP_RAWKEY:
				Code = IntuiMsg->Code;
				if (Code < 0x80) Done = TRUE; // make sure not an up
				break;
			case IDCMP_GADGETDOWN:
			case IDCMP_GADGETUP:
			case IDCMP_MOUSEBUTTONS:
				Done = TRUE;
				break;
			}
			ReplyMsg((struct Message *)IntuiMsg);
		}
	}
	return(Code);
}

//*******************************************************************
// careful with this one
WORD __asm WaitForClass(
	register __d0 ULONG Class)
{
	BOOL Done = FALSE;
	struct IntuiMessage *IntuiMsg;
	struct RenderData *R;
	WORD Code = 0;

	R = RD;
	goto Proc;
	while (!Done) {
		Wait(WaitMask);
Proc:
		while ((IntuiMsg = (struct IntuiMessage *)GetMsg(R->InterfaceWindow->
			UserPort)) ||
			(R->MenuBarWindow && (IntuiMsg = (struct IntuiMessage *)
				GetMsg(R->MenuBarWindow->UserPort)))) {
			if (IntuiMsg->Class == Class) {
				if (!((Class == IDCMP_RAWKEY) && (Code > 0x80))) {
					Code = IntuiMsg->Code;
					Done = TRUE;
				}
			}
			ReplyMsg((struct Message *)IntuiMsg);
		}
	}
	return(Code);
}

//*******************************************************************
VOID DoCG(VOID)
{
	BOOL Done = FALSE;
	struct IntuiMessage *IntuiMsg;
	struct RenderData *R;
	WORD Result;
  ULONG signal=0,rxsig=(1<<CGRexxPort->mp_SigBit);
	// struct LockBuffer *LB;

	R = RD;
	R->SetupPageProp = TRUE;
	SetupPageProp(R->CurrentPage);
	UpdatePageBody(TRUE);

// AAR -- junk
/*
	LB = BufferedOpen("hd0:junk",MODE_NEWFILE,80,R->ByteStrip->Planes[1],DOSBase);
	for (Result = 0; Result < 12; Result++)
		BufferedWrite("0123456789AB",12,LB);
	BufferedClose(LB);
*/

	WaitMask = BuildWaitMask();
	goto Proc;
	while (!Done)
  {
		signal=Wait(WaitMask);
Proc:
	  while	( (IntuiMsg = R->HoldIntuiMessage) ||
  	(IntuiMsg = (struct IntuiMessage *)GetMsg(R->InterfaceWindow->UserPort)) ||
	  (R->MenuBarWindow &&
      (IntuiMsg = (struct IntuiMessage *)GetMsg(R->MenuBarWindow->UserPort)))
    || (IntuiMsg = (struct IntuiMessage *)GetMsg(CGRexxPort)))
    {
      if (R->HoldIntuiMessage) R->HoldIntuiMessage = NULL;
      if( CGRexxPort && (signal&rxsig) )
        Result=HandleARexxMess((struct RexxMsg *)IntuiMsg);
      else
        Result = ProcessMessage(IntuiMsg);
      if (!Result)    	// if Result == 0, then want DoAsmCG()
      {
      	if (R->DeleteBuffer && R->PageBuffered)
        {
      		DeletePicture();
      		R->DeleteBuffer = R->PageBuffered = NULL;
      		R->UpdateInterface = TRUE;
      	}
      	DoAsmCG();
      }
      else if (Result > 0) Done = TRUE;
	  }
	}
}

//*******************************************************************
BOOL __asm OpenMenuBar(
	register __d0 UWORD BarMode)
{
	BOOL Success = FALSE;
	struct NewWindow *NW;
	struct RenderData *R;

	R = RD;
	if (!R->MenuBarWindow) {
		NW = &NewWindowStructure1;
		NW->Screen = R->InterfaceScreen;
		NW->LeftEdge = TOP_MINX;
		NW->TopEdge = OpenY;
		NW->Width = BAR_WIDTH+1;
		if (BarMode == BAR_COLOR) NW->Height = BAR_2_MAXY+1;
		else NW->Height = BAR_0_MAXY+1;

		NW->IDCMPFlags |= IDCMP_CHANGEWINDOW;
		RenderBar(BarMode);
		NW->FirstGadget = CurrentBarList;
		if (R->MenuBarWindow = OpenWindow(NW)) {
			RedisplayBar(BarMode);
			Success = TRUE;
		}
		WaitMask = BuildWaitMask();
	} else Success = TRUE;
	return(Success);
}

//*******************************************************************
VOID CloseMenuBar(VOID)
{
	struct Window *Window;

	if (Window = RD->MenuBarWindow) {
		OpenY = Window->TopEdge;
		CloseWindow(Window);
		RD->MenuBarWindow = NULL;
	}
	if (CurrentBarList) {
		SafeRemoveGList(NULL,CurrentBarList);
		CurrentBarList = NULL;
		CurrentBottomList = NULL;
	}
	WaitMask = BuildWaitMask();
//	DrawSafeArea(RD->InterfaceRastPort);
}

//*******************************************************************
VOID __regargs LinkGadget(
	struct Gadget *Last,
	struct Gadget *Gadget,
	WORD MinY)
{
	Gadget->TopEdge = MinY;
	Gadget->NextGadget = NULL;
	if (Last)
		Last->NextGadget = Gadget;
	if (Last && 
		((Last->GadgetID == ID_BAR_PAGE_DOWN) || 
		(Last->TopEdge == MinY)))
		Gadget->LeftEdge = Last->LeftEdge + Last->Width;
	else
		Gadget->LeftEdge = 0;
}

//*******************************************************************
struct Gadget *__regargs AddEmptyGadget(
	struct Gadget *Last,
	WORD MinY)
{
	struct Gadget *Gadget;

	if (Gadget = AllocOneGadget(AllGadgets[ID_BLANK])) {
		LinkGadget(Last,Gadget,MinY);
	} else {
		RD->UpdateInterface = TRUE;
		return(Last);
	}
	return(Gadget);
}

//*******************************************************************
struct Gadget *__regargs AddBarGadget(
	struct Gadget *Last,
	UWORD GadgetID,
	WORD MinY)
{
	struct Gadget *Gadget;

	Gadget = AllGadgets[GadgetID];
	LinkGadget(Last,Gadget,MinY);
	return(Gadget);
}

//*******************************************************************
struct Gadget *__regargs GetLastGadget(
	struct Gadget *Gadget)
{
	struct Gadget *Last;

	Last = Gadget;
	while (Gadget) {
		if (!(Gadget->GadgetType & GTYP_SYSGADGET))
			Last = Gadget;
		Gadget = Gadget->NextGadget;
	}
	return(Last);
}

//*******************************************************************
// RedispalyBar/RenderBottomBar/RenderBar - actual routines to call
// UpdateTopBar/UpdateBottomBar - lower level routines

//*******************************************************************
VOID __asm RedisplayBar(
	register __d0 UWORD BarMode)
{
	struct Window *Window;

	if (Window = RD->MenuBarWindow) {
		PreRefreshBottomBar(BarMode);
		RefreshGList(CurrentBarList,Window,NULL,-1);
		UpdateTopBar(BarMode);
		UpdateBottomBar(BarMode);
	}
}

//*******************************************************************
// remove all non-system gadgets starting with Gadget
VOID __regargs SafeRemoveGList(
	struct Window *Window,
	struct Gadget *Gadget)
{
	struct Gadget *Next;

	while (Gadget) {
		Next = Gadget->NextGadget;
		if (!(Gadget->GadgetType & GTYP_SYSGADGET)) {
			if (Gadget->GadgetID != ID_PAGE_PROP) { // managed in NewScroll.c
				if (Window) RemoveGadget(Window,Gadget);
				if (Gadget->GadgetID == ID_BLANK) FreeOneGadget(Gadget);
			}
		}
		Gadget = Next;
	}
}

//*******************************************************************
// assumes gadgets already there
VOID __asm RenderBottomBar(
	register __d0 UWORD BarMode)
{
	struct Gadget *Gadget;
	struct RenderData *R;
	struct Window *Window;

	R = RD;
	if (Window = R->MenuBarWindow) {

// remove previous gadget list
	if (CurrentBottomList) {
		SafeRemoveGList(Window,CurrentBottomList);
		CurrentBottomList = NULL;
	}

// add next one
	if (Gadget = AllocBottomBar(BarMode,NULL)) {
		CurrentBottomList = Gadget;
		AddGList(Window,Gadget,-1,-1,NULL);
		PreRefreshBottomBar(BarMode);
		RefreshGList(Gadget,Window,NULL,-1);
		UpdateBottomBar(BarMode);
	}
	}
}

//*******************************************************************
// Can call this one even when window closed
VOID __asm RenderBar(
	register __d0 UWORD BarMode)
{
	struct Gadget *Gadget,*Bottom;
	struct RenderData *R;
	struct Window *Window;

	R = RD;
	Window = R->MenuBarWindow;
//	DrawSafeArea(RD->InterfaceRastPort);

  if(BarMode==BAR_FEP) return;

// remove previous gadget list
	if (CurrentBarList) {
		SafeRemoveGList(Window,CurrentBarList);
		CurrentBarList = NULL;
		CurrentBottomList = NULL;
	}

// add next one
Again:
	if ((Gadget = AllocTopBar(BarMode)) &&
		(Bottom = AllocBottomBar(BarMode,GetLastGadget(Gadget)))) {
		CurrentBarList = Gadget;
		CurrentBottomList = Bottom;

		if (Window) {
			AddGList(Window,Gadget,0,-1,NULL);
			PreRefreshBottomBar(BarMode);
			RefreshGList(Gadget,Window,NULL,-1);
			UpdateTopBar(BarMode);
			UpdateBottomBar(BarMode);
			if (BarMode == BAR_COLOR)
				SetSliderColor(&RD->DefaultAttr.FaceColor); // after gadg added
		}

		R->BarMode = BarMode; // only if successful
	} else {
		if (Gadget) SafeRemoveGList(NULL,Gadget);
		R->UpdateInterface = TRUE;
		BarMode = BAR_NORMAL;
		R->NewBarMode = BAR_NORMAL; // give up
		goto Again; // not possible for this bar mode to fail
			// empty gadgets might not be allocated, but so what
	}
}

//*******************************************************************
struct Gadget *__asm AllocTopBar(
	register __d0 UWORD BarMode)
{
	struct Gadget *First,*Next,*Last;

	switch(BarMode) {
		case BAR_NORMAL:
			First = Next = AddBarGadget(NULL,ID_MESSAGE,TOP_MINY);
			Next = AddBarGadget(Next,ID_CURRENT_FONT,TOP_MINY);
			Next = AddBarGadget(Next,ID_PAGE_NUMBER,TOP_MINY);

			Last = Next = AddBarGadget(Next,ID_BAR_PAGE_UP,TOP_MINY);
			Next = AddBarGadget(Next,ID_BAR_PAGE_DOWN,TOP_MINY);
			Next->LeftEdge = Last->LeftEdge;
			Next->TopEdge = Last->TopEdge + Last->Height;
			break;

		case BAR_PAGE_TYPE:
			First = Next = AddBarGadget(NULL,ID_PAGE_TYPE,TOP_MINY);
			Next = AddBarGadget(Next,ID_BAR_CONTINUE,TOP_MINY);
			break;

		case BAR_COLOR:
			First = Next = AddBarGadget(NULL,ID_PAGE_TYPE,TOP_MINY);
			Next = AddBarGadget(Next,ID_BAR_CONTINUE,TOP_MINY);
			break;

		case BAR_PAGE_CMDS:
			First = Next = AddBarGadget(NULL,ID_MESSAGE,TOP_MINY);
			Next = AddBarGadget(Next,ID_CURRENT_FONT,TOP_MINY);
			Next = AddBarGadget(Next,ID_BAR_CONTINUE,TOP_MINY);
			break;
	}
	AddBarGadget(Next,ID_SWITCHER,TOP_MINY);
	return(First);
}

//*******************************************************************
VOID __asm UpdateBottomBar(
	register __d0 UWORD BarMode)
{
	struct RenderData *R;
	struct RastPort *RP;

	R = RD;
	if (R->MenuBarWindow) {
		if (((BarMode == BAR_NORMAL) || (BarMode == BAR_PAGE_TYPE) ||
			(BarMode == BAR_PAGE_CMDS)) &&
			(BottomMaxX < R->MenuBarWindow->Width-1)) {
			RP = R->MenuBarWindow->RPort;
			SetDrMd(RP,JAM2);
			SetAPen(RP,0);
			RectFill(RP,BottomMaxX,BTM_MINY,R->MenuBarWindow->Width-1,BTM_MAXY);
		}
		if (BarMode == BAR_COLOR)
			RenderThick();
	}
}

//*******************************************************************
VOID LowMemoryStatus(VOID)
{
	if (RD->MenuBarWindow)
		NewUpdateMessage(OutMemoryMsg);
}

//*******************************************************************
VOID UpdateMessage(VOID)
{
	NewUpdateMessage(NULL);
}

//*******************************************************************
VOID __asm NewUpdateMessage(
	register __a0 char Mess[])
{
	struct RenderData *R;
	struct Gadget *Gadget;
	struct RastPort *RP;
	char *C;
	WORD A;

	R = RD;
	if (R->MenuBarWindow) {

	// check if memory still low
		if ((R->StatusMessage == OutMemoryMsg) && (!MemoryIsLow()))
			R->StatusMessage = NULL;

	// leave out of memory message up
		if ((Mess) &&
			(R->StatusMessage != OutMemoryMsg)) R->StatusMessage = Mess;

		RP = R->MenuBarWindow->RPort;
		if ((R->NewBarMode == BAR_PAGE_TYPE) ||
			(R->NewBarMode == BAR_COLOR)) Gadget = AllGadgets[ID_PAGE_TYPE];
		else Gadget = AllGadgets[ID_MESSAGE];
		SetDrMd(RP,JAM2);
		Move(RP,Gadget->LeftEdge+4,BAR_TEXT_Y);
		C = R->StatusMessage;
		if (!C) {
			if (R->AAChips)
				C = DefaultAAMsg;
			else
				C = DefaultMsg;
		}
		SetAPen(RP,2);
		A = CutText(C,RP,Gadget->Width-16-1) * TEXT_WIDTH;
		RectFill(RP,Gadget->LeftEdge+4+A,Gadget->TopEdge+2,
			Gadget->LeftEdge+Gadget->Width-4,
			Gadget->TopEdge+Gadget->Height-3);
	}
}

//*******************************************************************
WORD __asm CutText(
	register __a0 char *String,
	register __a1 struct RastPort *RP,
	register __d0 WORD MaxLen)
{
	WORD A;

	A = strlen(String);
	while (A && (TextLength(RP,String,A) > MaxLen)) {
		A--;
	}
	if (A) Text(RP,String,A);
	return(A);
}

//*******************************************************************
VOID DrawSliderBorders(VOID)
{
	struct Gadget *Gadget;
	WORD A;
	struct RastPort *RP;
	struct RenderData *R;
	char *C;

	R = RD;
	RP = R->MenuBarWindow->RPort;
	for (A=ID_COLOR_RED; A <= ID_COLOR_ALPHA; A++) {
		Gadget = AllGadgets[A];
		if (((A == ID_COLOR_ALPHA) && (AlphaList)) ||
			((A < ID_COLOR_ALPHA) && RGBList)) {
			NewBorderBox(RP,Gadget->LeftEdge-4,Gadget->TopEdge-2,
				Gadget->LeftEdge+Gadget->Width+3,
				Gadget->TopEdge+Gadget->Height+1,
				BOX_REV);
			Move(RP,Gadget->LeftEdge - 16,Gadget->TopEdge+TEXT_BASELINE);
			C = &SliderLabels[A-ID_COLOR_RED][0];
			Text(RP,C,1);
			}
	}
}

//*******************************************************************
VOID __asm PreRefreshBottomBar(
	register __d0 UWORD BarMode)
{
	struct RenderData *R;
	struct RastPort *RP;

	R = RD;
	if (R->MenuBarWindow) {
		if (BarMode == BAR_COLOR) {
			RP = R->MenuBarWindow->RPort;
			NewBorderBox(RP,0,BAR_BTM_MIN_Y,BAR_WIDTH-2,BAR_2_MAXY,
				BOX_REV);
			DrawSliderBorders();
			DrawAlphaMarks();
		}
	}
}

//*******************************************************************
VOID __asm UpdateTopBar(
	register __d0 UWORD BarMode)
{
	char Buff[10],*C;
	struct RastPort *RP;
	struct RenderData *R;
	struct Gadget *Gadget;
	struct LineData *Data;

	R = RD;
	if (R->MenuBarWindow) {
		RP = R->MenuBarWindow->RPort;
		NewUpdateMessage(0);

// font/brush/box
		if ((BarMode == BAR_NORMAL) || (BarMode == BAR_PAGE_CMDS)) {
		Gadget = AllGadgets[ID_CURRENT_FONT];
		Move(RP,Gadget->LeftEdge+4,BAR_TEXT_Y);
		SetAPen(RP,TEXT_PEN);
		if (Data = GetData(R->DefaultAttr.ID)) {
			C = Data->DisplayName;
			CutText(C,RP,Gadget->Width-8);
		}
		}

// page number
		if (BarMode == BAR_NORMAL) {
		Gadget = AllGadgets[ID_PAGE_NUMBER];
		strcpy(Buff,"Page    ");
		Word2Ascii(R->PageNumber,&Buff[4]);
		if (R->PageBuffered) {
			Buff[7] = 0x5c;
		}
		Move(RP,Gadget->LeftEdge+4+4,BAR_TEXT_Y);
		Text(RP,Buff,8);
		}
	}
}

//*******************************************************************
// returns ptr to first gadget in bottom list
struct Gadget *__asm AllocBottomBar(
	register __d0 UWORD BarMode,
	register __a0 struct Gadget *Prev)
{
	struct Gadget *First,*Next,*Current;
	struct CGLine *Line;
	struct Attributes *Attr;
	struct CGPage *Page;
	struct RenderData *R;
	WORD A;

	R = RD;
	Line = &R->DefaultLine;
	Attr = &R->DefaultAttr;
	Page = R->CurrentPage;

	switch(BarMode) {

//***************************
	case BAR_NORMAL:

// Page Type,Color,Shad Type,Shad Dir,Shad Len,Outline Type,Shad Pri
// Horiz Center, Horiz Lower, +-Fonts, Page Cmds,Rend Line,Rend Page,Take
	First = Next = AddBarGadget(NULL,ID_PAGE_EMPTY+Page->Type,ICON_MINY);
	First->Flags &= (~GFLG_SELECTED);

	Next = AddBarGadget(Next,ID_PAGE_COMMANDS,ICON_MINY);
	Next = AddBarGadget(Next,ID_COLOR,ICON_MINY);

	A = ID_SHADOW_NONE+Attr->ShadowType;
	Next = AddBarGadget(Next,A,ICON_MINY);

	if (A != ID_SHADOW_NONE) {
		Next = AddBarGadget(Next,ID_SHADOW_NORTH+Attr->ShadowDirection,ICON_MINY);
// shad len: 2,4,6,8,10
		Next = AddBarGadget(Next,ID_SHADOW_1+((Attr->ShadowLength-2)>>1),ICON_MINY);
	} else {
		Next = AddEmptyGadget(Next,ICON_MINY);
		Next = AddEmptyGadget(Next,ICON_MINY);
	}

// 0 to (os_SizeOf*3), os_SizeOf = 8
	Next = AddBarGadget(Next,ID_OUTLINE_NONE+(Attr->OutlineType),ICON_MINY);

	if ((Attr->ShadowType || Attr->OutlineType) &&
		(Page->Type != PAGE_SCROLL) && (Page->Type != PAGE_EMPTY))
		Next = AddBarGadget(Next,ID_OUTLINE_PRIORITY+Attr->ShadowPriority,
			ICON_MINY);
	else
		Next = AddEmptyGadget(Next,ICON_MINY);

	if ((Page->Type) && (Page->Type != PAGE_CRAWL))
		Next = AddBarGadget(Next,ID_JUSTIFY_NONE+Line->JustifyMode,ICON_MINY);
	else
		Next = AddEmptyGadget(Next,ICON_MINY);

	if ((Page->Type != PAGE_SCROLL) && (Page->Type != PAGE_EMPTY)) {
		Next = AddBarGadget(Next,ID_HORIZ_CENTER,ICON_MINY);
		Next = AddBarGadget(Next,ID_HORIZ_LOWER,ICON_MINY);
	} else {
		Next = AddEmptyGadget(Next,ICON_MINY);
		Next = AddEmptyGadget(Next,ICON_MINY);
	}
	switch(Page->Type) {
		case PAGE_EMPTY:
			Next = AddEmptyGadget(Next,ICON_MINY);
			Next = AddEmptyGadget(Next,ICON_MINY);
			Next = AddEmptyGadget(Next,ICON_MINY);
			Next = AddEmptyGadget(Next,ICON_MINY);
			break;

		case PAGE_STATIC:
		case PAGE_BUFFER:
			Next = AddBarGadget(Next,ID_COPY_PAGE,ICON_MINY);
//		Next = AddBarGadget(Next,ID_RENDER_DISK,ICON_MINY);
			Next = AddBarGadget(Next,ID_RENDER_LINE,ICON_MINY);
			Next = AddBarGadget(Next,ID_RENDER_PAGE,ICON_MINY);
			if (R->State & MASK_READY)
				Next = AddBarGadget(Next,ID_TAKE,ICON_MINY);
			else
				Next = AddEmptyGadget(Next,ICON_MINY);
			break;

		case PAGE_SCROLL:
			Next = AddBarGadget(Next,ID_COPY_PAGE,ICON_MINY);
//			Next = AddEmptyGadget(Next,ICON_MINY);
// scroll 0 to 8, step 2
			Next = AddBarGadget(Next,ID_SCROLL_SPEED_1+(Page->Speed>>1),ICON_MINY);
			goto PlayMode;

// crawl 0 to 3, step 1
		case PAGE_CRAWL:
			Next = AddBarGadget(Next,ID_COPY_PAGE,ICON_MINY);
//			Next = AddEmptyGadget(Next,ICON_MINY);
			Next = AddBarGadget(Next,ID_CRAWL_SPEED_1+Page->Speed,ICON_MINY);
		PlayMode:
			A = Page->PlaybackMode;
			if (Page->PlaybackMode < 0) A = 2;
			Next = AddBarGadget(Next,ID_PLAY_ONCE+A,ICON_MINY);
			Next = AddBarGadget(Next,ID_TAKE,ICON_MINY);
	}
	break;

//***************************
	case BAR_PAGE_TYPE:
	First = AddBarGadget(NULL,ID_PAGE_STATIC,ICON_MINY);
	First->Flags &=  (~GFLG_SELECTED);
	Next = AddBarGadget(First,ID_PAGE_BUFFER,ICON_MINY);
	Next->Flags &=  (~GFLG_SELECTED);
	Next = AddBarGadget(Next,ID_PAGE_SCROLL,ICON_MINY);
	Next->Flags &=  (~GFLG_SELECTED);
	Next = AddBarGadget(Next,ID_PAGE_CRAWL,ICON_MINY);
	Next->Flags &=  (~GFLG_SELECTED);
	Current = AllGadgets[ID_PAGE_EMPTY+Page->Type];
	Current->Flags |= (GFLG_SELECTED);
	break;

//***************************
	case BAR_COLOR:
	if (PageProp) SetupPageProp(Page); // must do now before redraw

	if (Page->Type == PAGE_BUFFER) {
		First = AddBarGadget(NULL,ID_COLOR_BKG,COLOR_WHICH_MINY);
		First->LeftEdge = COLOR_WHICH_MINX;
		Next = AddBarGadget(First,ID_COLOR_TEXT,COLOR_WHICH_MINY);
	} else {
		First = Next = AddBarGadget(NULL,ID_COLOR_TEXT,COLOR_WHICH_MINY);
		First->LeftEdge = COLOR_WHICH_MINX + COLOR_WHICH_WIDTH;
	}
	Next = AddBarGadget(Next,ID_COLOR_SHADOW,COLOR_WHICH_MINY);
	if (!MovingPage(Page))
		Next = AddBarGadget(Next,ID_COLOR_OUTLINE,COLOR_WHICH_MINY);

	Next = AddBarGadget(Next,ID_COLOR_DEFAULTS,DEFAULTS_MINY);
	Next->LeftEdge = SWATCH_MINX;

	Next->NextGadget = Current = AllGadgets[ID_COLOR_RED];
	Current->LeftEdge = COLOR_SLIDER_MINX;
	Current->TopEdge = COLOR_SLIDER_MINY+2;
	Next = Current;
	RGBList = Next; // mark RGB as on

	Next->NextGadget = Current = AllGadgets[ID_COLOR_GREEN];
	Current->LeftEdge = COLOR_SLIDER_MINX;
	Current->TopEdge = Next->TopEdge+Next->Height+4;
	Next = Current;

	Next->NextGadget = Current = AllGadgets[ID_COLOR_BLUE];
	Current->LeftEdge = COLOR_SLIDER_MINX;
	Current->TopEdge = Next->TopEdge+Next->Height+4;
	Next = Current;
	Next->NextGadget = NULL;

	if (!MovingPage(Page))
  {
		Next->NextGadget = Current = AllGadgets[ID_COLOR_ALPHA];
    ENABLE(Current);
		Current->LeftEdge = COLOR_SLIDER_MINX;
		Current->TopEdge = COLOR_ALPHA_MINY+2;
		Next = Current;
		Next->NextGadget = NULL;
		AlphaList = Next;	// mark alpha gadget as on

    TCList =	Next= AddBarGadget(Next,ID_TEXTCOLOR_SOLID,COLOR_2_MINY);
    Next->LeftEdge = COLOR_2_MINX;
    Next = AddBarGadget(Next,ID_TEXTCOLOR_GRADATION,COLOR_2_MINY);
    Next->NextGadget = NULL;
    if (R->DefaultAttr.SpecialFill & FILL_TBGRAD)
    {
      AllGadgets[ID_TEXTCOLOR_SOLID]->Flags &= (~GFLG_SELECTED);
    	AllGadgets[ID_TEXTCOLOR_GRADATION]->Flags |= GFLG_SELECTED;
      TextTopBtmList = Next = AddBarGadget(Next,ID_TEXTCOLOR_TOP,COLOR_2_MINY);
    	Next->LeftEdge = COLOR_3_MINX;
    	Next =AddBarGadget(Next,ID_TEXTCOLOR_BOTTOM,COLOR_2_MINY);
    	AllGadgets[ID_TEXTCOLOR_TOP]->Flags |= GFLG_SELECTED;
    	AllGadgets[ID_TEXTCOLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);
    	Next->NextGadget = NULL;
    }
    else
    {
    	AllGadgets[ID_TEXTCOLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
    	AllGadgets[ID_TEXTCOLOR_SOLID]->Flags |= GFLG_SELECTED;
    }
	}
  else
  {
   AlphaList = NULL;
   TCList = NULL;
  }
	SelectColorText();
	BKGList = NULL;
	TopBtmList = NULL;
	OLTopBtmList = NULL;
	OCList = NULL;
	LoadList = NULL;
	break;

//***************************
	case BAR_PAGE_CMDS:
	if (MovingPage(Page)) {
		First = Next = AddEmptyGadget(NULL,ICON_MINY);
		Next = AddEmptyGadget(Next,ICON_MINY);
	} else {
		First = Next = AddBarGadget(NULL,ID_DEPTH_FRONT,ICON_MINY);
		Next = AddBarGadget(Next,ID_DEPTH_BACK,ICON_MINY);
	}

	Next = AddBarGadget(Next,ID_FONT_ADD,ICON_MINY);

	Next = AddBarGadget(Next,ID_LOAD_DRAW,ICON_MINY);

	Next = AddBarGadget(Next,ID_BRUSH_ADD,ICON_MINY);
	Next = AddBarGadget(Next,ID_FONT_INFO,ICON_MINY);
	Next = AddBarGadget(Next,ID_FONT_CLEAR,ICON_MINY);

	Next = AddBarGadget(Next,ID_SAVE_BOOK,ICON_MINY);

	Next = AddBarGadget(Next,ID_LOAD_BOOK,ICON_MINY);

	Next = AddBarGadget(Next,ID_SAVE_PAGE,ICON_MINY); // SAVE PAGE
	if (Page->Type != PAGE_EMPTY)
		Next = AddBarGadget(Next,ID_LOAD_TEXT,ICON_MINY);
	Next = AddEmptyGadget(Next,ICON_MINY);

	if ((Page->Type == PAGE_CRAWL) || (Page->Type == PAGE_EMPTY))
		 Next = AddEmptyGadget(Next,ICON_MINY);
	else Next = AddBarGadget(Next,ID_ERASE_LINE,ICON_MINY);

	Next = AddBarGadget(Next,ID_ERASE_PAGE,ICON_MINY);
	Next = AddBarGadget(Next,ID_ERASE_BOOK,ICON_MINY);
	break;
	}

	BottomMaxX = Next->LeftEdge + Next->Width; // used for clearing space
	if (Prev)
		Prev->NextGadget = First;
	return(First);
}

//*******************************************************************
// changes to stuart's code:
//	comment out LockLayer/UnLockLayer
//	change hilite to 2bp
//	cuntsetjmp/cuntlongjmp
//	IntuiText->DrawMode = JAM2
//
// AAR -- junk
char *NameFcn(void *junk, int Entries)
{
	struct LineData *Data;
	char *C = NULL;

	Data = (struct LineData *)GetListPosition(&RD->CurrentBook->DataList,
		Entries);
	if (Data) C = Data->DisplayName;
	if (!C) C = Dummy;
	return(C);
}

//*******************************************************************
void DrawBG(
	struct st_PopupRender *Pop,
	struct RastPort *RP,
	long Width,
	long Height,
	int TopArrow,
	int BtmArrow)
{
	struct Image *Image=NULL;
	WORD X;

	NewBorderBox(RP,0,0,Width-1,Height-1,BOX_STANDARD);
	Image = AllGadgets[ID_POPUP_UP]->GadgetRender;
	X = (Width-Image->Width)/2;
	if (TopArrow) DrawImage(RP,Image,X,2);
	if (BtmArrow) {
		Image = AllGadgets[ID_POPUP_DOWN]->GadgetRender;
		DrawImage(RP,Image,X,Height - 2 - Image->Height);
	}
}

//*******************************************************************
WORD __asm CaseCurrentFont(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	PopUpID ID;
	struct Gadget *Gadget;
	WORD X,Y,A,Refresh = REFRESH_NONE;
	struct LineData *Data;
  struct DrawData *Draw;
	char *Message[2];
	struct RenderData *R;

	R = RD;
	PUCDefaultRender(&PopUp);
	PopUp.drawBG = (DrawBGFunc *)DrawBG;
	Gadget = AllGadgets[ID_CURRENT_FONT];
	X = Gadget->LeftEdge + (Gadget->Width >> 1);
	Y = Gadget->TopEdge + (Gadget->Height >> 1);
	ID = PUCCreate((NameFunc *)NameFcn,NULL,&PopUp);
	PUCSetNumItems(ID,NodesThisList(&R->CurrentBook->DataList));

	A = 0;
	if (Data = GetData(R->DefaultAttr.ID)) {
		A = NodeToOffset((struct List *)&R->CurrentBook->DataList,&Data->Node);
		if (A) A--;
	}
	PUCSetCurItem(ID,A);

	RD->MenuBarWindow->Flags |= WFLG_REPORTMOUSE;
	A = PUCActivate(ID,R->MenuBarWindow,X,Y,IntuiMsg->MouseX,IntuiMsg->MouseY);
	RD->MenuBarWindow->Flags &= ~WFLG_REPORTMOUSE;
	PUCDestroy(ID);

	if (A >= 0) {
		Data = (struct LineData *)GetListPosition(&R->CurrentBook->DataList,A);
		if (Data) {
			if (PageIDOK(Data->ID)) {
				R->DefaultLine.Type = Data->Type;
				R->DefaultAttr.ID = Data->ID;
				if (Data->Type == LINE_TEXT) R->LastDefaultFont = Data->ID;
				else if (Data->Type == LINE_DRAW)
				{
					Draw=(struct DrawData *)Data->Data;
					R->DefaultLine.FaceWidth = Draw->w;
					R->CurrentLine->FaceWidth = R->DefaultLine.FaceWidth;
					R->DefaultLine.FaceHeight = Draw->h;   // Draw->ury - Draw->lly;
					R->CurrentLine->FaceHeight = R->DefaultLine.FaceHeight;
					RefreshDraw(R->CurrentLine);
				}
				SetSelectAttrib(R->CurrentPage,(UBYTE *)&Data->ID,ATTR_ID);
				UpdateFixPage();
				R->UpdatePage = UPDATE_PAGE_OLD;
			} else {
				Message[0] = BadTypeMsg;
				if (R->AdditionalError) {
					Message[0] = R->AdditionalError;
					R->AdditionalError = NULL;
				}
				CGMultiRequest(Message,1,REQ_CENTER|REQ_H_CENTER);
			}
			R->UpdateInterface = TRUE;
			Refresh = REFRESH_YES;
		}
	}
	return(Refresh);
}

//*******************************************************************
UWORD __asm ParseLongString(
	register __a0 char *Source,
	register __a1 char *Array[],
	register __d0 UWORD DestMax)
{
	UWORD Dest = 0,DLen;
	char *CurrDest,C;

	CurrDest = *Array++;
	DLen = 0;
	while (C = *Source++) {
		if ((C == 0x0D) || ((DLen > (COPY_LEN-10))&&(C == ' '))
		|| (DLen > COPY_LEN)) {
			if ((Dest+1) >= DestMax) goto Exit;
			Dest++;
			CurrDest = *Array++;
			DLen = 0;
		}
		if (C != 0x5c) { // '\'
			*CurrDest++ = C;
			DLen++;
		}
	}
Exit:
	*CurrDest = 0;
	Dest++;
	return(Dest);
}

//*******************************************************************
WORD __asm CaseFontInfo(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	char *Mess[14],**M,*Buff,str[100];
	struct LineData *Data;
	struct RenderData *R;
	struct ToasterFont *Font;
	UWORD A,Count = 0;
  WORD  H,W;
	struct KenByteMap *BM;

	R = RD;
	if (!(Buff = SafeAllocMem(5*(COPY_LEN+2),MEMF_CLEAR))) {
		return(REFRESH_YES);
	}
	if (Data = GetData(R->DefaultAttr.ID))
  {
		M = &Mess[0];
    strcpy(DefFileName,GetJustFile(Data->FileName));
    RemoveFontExt(DefFileName);
		switch(Data->Type) {
			case LINE_TEXT:
				Font = Data->Data;
        *M++ = DefFileName;
        Count++;
				if (Font) {
					if ((Font->Copyright) && (Font->Copyright[0])) {
						*M = Buff;
						*(M+1) = Buff+(COPY_LEN+2);
						*(M+2) = Buff+((COPY_LEN+2)*2);
						*(M+3) = Buff+((COPY_LEN+2)*3);
						*(M+4) = Buff+((COPY_LEN+2)*4);
						A = ParseLongString(Font->Copyright,M,5);
						Count += A;
						M += A;
					}
					A = Font->Type;
					*M++ = SpaceMsg;
					*M++ = FontTypeText[A];
					Count += 2;
       // font kern pairs
					if (Font->Type == FONT_TYPE_PS) {
						if (Font->KernPairs) {
							strcpy(Def3File,FontInfoMsg5);
							A = strlen(Def3File);
							stcul_d(&Def3File[A],Font->KernPairs);
							*M++ = Def3File;
						} else {
							*M++ = FontInfoMsg7;
						}
						Count++;
					} else if (Font->Type == FONT_TYPE_BULLET) {
						*M++ = FontInfoMsg6;
						Count++;
					}
				}
				break;

			case LINE_BRUSH:
        *M++ = DefFileName;
				*M++ = SpaceMsg;
				*M++ = BrushTypeText;
				Count += 3;
				break;

			case LINE_DRAW:
        sprintf(str,"Rotate: %d�    Slant: %d�",
          ((struct DrawData *)(Data->Data))->rot,
          ((struct DrawData *)(Data->Data))->skew);
        *M++ = DrawTypeText[((struct DrawData *)(Data->Data))->Type];
				*M++ = SpaceMsg;
				*M++ = ((struct DrawData *)(Data->Data))->Text;
        *M++ = DefFileName;
				*M++ = str;
				Count += 5;
				break;
			case LINE_BOX:
				*M++ = BoxTypeText;
				Count++;
				break;
		}

// Height
		H = 0;
		Def2File[0] = 0;
		switch(Data->Type) {
			case LINE_TEXT:
				if (Font)
					H = Font->TextBM.Rows;
          W=0;
				goto AddIt;
			case LINE_BRUSH:
				BM = &((struct Picture *)Data->Data)->RGB;
				H = BM->Rows;
        W = BM->BytesPerRow ; // <<3; oops bytemap has 1byte/pix
				goto AddIt;
			case LINE_DRAW:
				// H = Data->Height;
        // W = ((struct DrawData *)(Data->Data))->urx;
        // W -= ((struct DrawData *)(Data->Data))->llx;
        W = ((struct DrawData *)(Data->Data))->Alfa.BytesPerRow<<3;
        H = ((struct DrawData *)(Data->Data))->Alfa.Rows;
				goto AddIt;
			case LINE_BOX:
        W=R->CurrentLine->FaceWidth;
        H=R->CurrentLine->FaceHeight;
		AddIt:
				if (H)
        {
					strcpy(Def2File,FontInfoMsg1);
					A = strlen(Def2File);
					stcu_d(&Def2File[A],H);
					*M++ = Def2File;
					Count++;
				}
        if (W)
        {
          strcat(Def2File," x ");
					A = strlen(Def2File);
					stcu_d(&Def2File[A],W);
				}
		}

// disk size
		if (Data->DiskSize) {
			strcpy(Def2Path,FontInfoMsg3);
			A = strlen(Def2Path);
			stcul_d(&Def2Path[A],Data->DiskSize);
			strcat(Def2Path,FontInfoMsg4);
			*M++ = Def2Path;
			Count++;
		}

// CurrentPath
		if ( (Data->Type != LINE_BOX) &&(Data->Type != LINE_BOX) )
    {
			*M++ = FontInfoMsg2;
			*M = Data->FileName;
			Count += 2;
		}
		CGMultiRequest(Mess,Count,REQ_CENTER|REQ_H_CENTER);
	}
Exit:
	FreeMem(Buff,5*(COPY_LEN+2));
	return(REFRESH_YES);
}

//*******************************************************************
// if currentline empty, and box/brush selected underneath, make it currentline
BOOL __regargs FindSelBoxBrush(
	WORD X,
	WORD Y,
	struct CGPage *Page)
{
	struct CGLine *Line,*Next;
	WORD A;
	WORD CX,MinY,MaxY;
	struct TempInfo *Temp;

	CX = X;
	if (Page->Type == PAGE_SCROLL) {
		CX -= SCROLL_MIN_X; // scroll pages 640 centered
		if (CX < 0) return(FALSE);
	}

	for (A = MAX_PRI; A >= 0; A--) {
	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ) {
		if ((Line->Type != LINE_TEXT) && (Line->RenderPri == A)) {

		MinY = LineMinY(Page,Line)+Line->FaceMinY;
		MaxY = MinY + Line->FaceMinY + Line->FaceHeight - 1;
		if ((Y >= MinY) && (Y < MaxY)) {
			Temp = &Line->Temp[0];

// if get one, and hit, process
			if ((CX >= Temp->StartX) && (CX <= Temp->EndX)) {
				NewCurrentLine(Line);
				return(TRUE);
			}
		}
		}
		Line = Next;
	}
	}
	return(FALSE);
}

//*******************************************************************
WORD __asm CaseDepthFront(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct CGLine *Line;
	struct CGPage *Page;
	struct RenderData *R;
	WORD Refresh = REFRESH_NONE;

	R = RD;
	if (Line = R->CurrentLine) {

		Page = R->CurrentPage;
		if (IsWhiteSpaceLine(Line)) {
			if (FindSelBoxBrush(Line->XOffset,Line->YOffset+Line->FaceMinY+
				Line->Baseline,Page))
				Line = R->CurrentLine;
		}

		if ((Page->Type != PAGE_CRAWL)&&(Page->Type != PAGE_EMPTY)) {
			Line->RenderPri = PRI_IGNORE;
			SortPageRenderPri(Page);
			Line->RenderPri = GetNextAvailPri(Page,Line->Type,0);
			R->UpdateLine = TRUE;
			Refresh = REFRESH_YES;
		}
	}
	return(Refresh);
}

//*******************************************************************
WORD __asm CaseDepthBack(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct CGLine *Line;
	struct CGPage *Page;
	struct RenderData *R;
	WORD Refresh = REFRESH_NONE;

	R = RD;
	if (Line = R->CurrentLine) {

		Page = R->CurrentPage;
		if (IsWhiteSpaceLine(Line)) {
			if (FindSelBoxBrush(Line->XOffset,Line->YOffset+Line->FaceMinY+
				Line->Baseline,Page))
				Line = R->CurrentLine;
		}

		if ((Page->Type != PAGE_CRAWL)&&(Page->Type != PAGE_EMPTY)) {
			Line->RenderPri = PRI_IGNORE;
			SortPageRenderPri(Page);
			BumpAllRenderPri(Page,Line->Type);
			Line->RenderPri = 0;
			R->UpdatePage = UPDATE_PAGE_OLD;
			Refresh = REFRESH_YES;
		}
	}
	return(Refresh);
}

//*******************************************************************
WORD __asm CaseSaveBook(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	char BookName[60]="NewBook",*Mess[1],*tit="Save Book";
	struct RenderData *R;
	BPTR BL;

	R = RD;

  if(FileRequest(tit,BookName,PagesPath))
	{
		if (BL = Lock(BookName,MODE_OLDFILE))
		{
			UnLock(BL);
			Mess[0] = DefFileName;
			strcpy(DefFileName,OverWriteBook);
			strcat(DefFileName,BookName);
			strcat(DefFileName,"?");
			if (!(CGMultiRequest(Mess,1,REQ_OK_CANCEL|REQ_CENTER|REQ_H_CENTER)))
				return(REFRESH_NONE);
		}
		if (!(SaveBook(BookName,R->CurrentBook))) {
			strcpy(DefFileName,SaveBookFail);
			strcat(DefFileName,BookName);
			CGRequest(DefFileName);
		} else {
			strcpy(DefFileName,SaveBookSuccess);
			strcat(DefFileName,BookName);
			CGRequest(DefFileName);
		}
	}
	return(REFRESH_YES);
}


// end of NewGadgets.c
