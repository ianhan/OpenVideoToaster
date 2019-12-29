/********************************************************************
* newfunction.c 
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
* $Id: NewFunction.c,v 2.0 1995/08/31 15:27:31 Holt Exp $
* $Log: NewFunction.c,v $
 * Revision 2.0  1995/08/31  15:27:31  Holt
 * FirstCheckIn
 *
*********************************************************************/
/********************************************************************
* NewFunction.c
*
* Copyright ©1993 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*	3-2-93	Steve H		Created
*	6-7-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <stdio.h>
#include <string.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <proto/intuition.h>
#include <proto/console.h>
#include <proto/dos.h>

#include <book.h>
#include <newsupport.h>
#include <gadgets.h>
#include <newfunction.h>
#include <cg:popup/popup.h>
#include <commonrgb.h>

#ifndef PROTO_PASS
#include <protos.h>
#endif

void __asm SetGenlock(register __d0 BOOL);


#ifdef PROTO_PASS
void DrawBG(
	struct st_PopupRender *Pop,
	struct RastPort *RP,
	long Width,
	long Height,
	int TopArrow,
	int BtmArrow);
#endif

#define MIN_SHADOW_LENGTH 2
#define SHADOW_INCREMENT 2
#define MAX_OUTLINE_TYPE 3
#define MAX_SCROLL_SPEED 8
#define MIN_SCROLL_SPEED 0
#define SCROLL_JUMP 2
#define MAX_CRAWL_SPEED 3
#define MIN_CRAWL_SPEED 0
#define CRAWL_JUMP 1
#define CRAWL_HEIGHT 300

#define D_GREY 1

#define BKG_COUNT 3
#define TC_COUNT 2
#define TOP_BTM_COUNT 2
#define TEXTTOP_BTM_COUNT 2
#define RGB_COUNT 3
#define ALPHA_COUNT 1
#define SELECT(g)	g->Flags |= GFLG_SELECTED;
#define DESELECT(g)	g->Flags &= (~GFLG_SELECTED);
#define DISABLE(g)	g->Flags |= GFLG_DISABLED;
#define ENABLE(g)	g->Flags &= (~GFLG_DISABLED);


extern struct RenderData *RD;
extern struct Border Border;
extern struct Rectangle Bound;
extern struct Gadget *CurrentBottomList, *AllGadgets[];
extern struct st_PopupRender PopUp;
extern char PageCmdsMsg[],SurePageType[],SurePage2[],
	WorkMsg[],ChoosePage[],ChooseColor[],ChooseColorNoBG[],
	LoadBGMsg[],BGFilesPath[],DefFileName[],UnableBGMsg[],LoadingBGMsg[],
	FramestoreMsg[],*NoComRGBMsg[],CrawlTrimMsg[],CrawlTrim2[];

BOOL DraggingBar = FALSE;
WORD NowY,BeginX,BeginY,MaxY;
struct Gadget *BKGList=NULL,*TCList=NULL,*LoadList=NULL,*TopBtmList=NULL,
    *OCList=NULL,*OLTopBtmList=NULL,
    *TextTopBtmList=NULL,*DraggingSlider = NULL,*AlphaList=NULL,*RGBList=NULL;

struct TrueColor *SliderColor;
UBYTE *DragValueDest;
BOOL SetLineColor = FALSE;

#define NUM_DEFAULTS 10
UBYTE DefNames[NUM_DEFAULTS][20] = {
	"White","Grey","Black","Yellow","Red","Green","Light Blue","Dark Blue",
	"Purple","Orange"
};
struct TrueColor DefColors[NUM_DEFAULTS] = {
	{ 210,210,210,255 },
	{ 128,128,128,255 },
	{ 0,0,0,255 },
	{ 230,230,80,255 },
	{ 192,32,32,255 },
	{ 32,192,32,255 },
	{ 64,192,255,255 },
	{ 16,16,128,255 },
	{ 210,80,210,255 },
	{ 240,168,104,255 }
};

struct TrueColor Normal4 = { 128,128,64,0 };

//*******************************************************************
VOID __regargs PropValue(
	struct Gadget *Gadget,
	UBYTE Value)
{
	UBYTE T[10];
	struct RastPort *RP;

	RP = RD->MenuBarWindow->RPort;
	SetDrMd(RP,JAM2);
	SetAPen(RP,0);
	Word2Ascii(Value,T);
	Move(RP,COLOR_NUM_MINX,Gadget->TopEdge+TEXT_BASELINE);
	Text(RP,T,strlen(T));
}

//*******************************************************************
VOID __regargs PropSetColor(
	struct Gadget *Gadget,
	UBYTE *ValueDest)
{
	UBYTE V;
	struct PropInfo *Prop;
	UWORD Value;

	Prop = Gadget->SpecialInfo;
	Value = (((ULONG)Prop->HorizPot) * 255 + MAXPOT/2) / MAXPOT;
	V = Value;
	*ValueDest = V;
	PropValue(Gadget,Value);
	if (SliderColor) SetupPalColor(SliderColor);
	SmartInstall(TRUE,FALSE);
}

//*******************************************************************
// MOUSEMOVEs go here
VOID HandleSliderMove(VOID)
{
	if (DraggingSlider) PropSetColor(DraggingSlider,DragValueDest);
}

//*******************************************************************
// GADGETUP/DOWN go here
VOID __regargs HandleSlider(
	struct IntuiMessage *IntuiMsg,
	UBYTE *ValueDest)
{
	struct Gadget *Gadget;
	struct RenderData *R;

	R = RD;
	DragValueDest = ValueDest;
	Gadget = IntuiMsg->IAddress;
	PropSetColor(Gadget,ValueDest);
	if (IntuiMsg->Class == GADGETDOWN) {
		SoftSpriteOff();
		DraggingSlider = Gadget;
	} else {
		SoftSpriteOnScreen(R->InterfaceScreen);
		DraggingSlider = NULL;
	if (SetLineColor)
		SetSelectAttrib(R->CurrentPage,(UBYTE *)&R->DefaultAttr.FaceColor,ATTR_COLOR);
	}
}

//*******************************************************************
WORD __asm CaseColorRed(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	if (SliderColor) HandleSlider(IntuiMsg,&SliderColor->Red);
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorGreen(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	if (SliderColor) HandleSlider(IntuiMsg,&SliderColor->Green);
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorBlue(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	if (SliderColor) HandleSlider(IntuiMsg,&SliderColor->Blue);
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorAlpha(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	if (SliderColor) HandleSlider(IntuiMsg,&SliderColor->Alpha);
	return(REFRESH_NONE);
}

//*******************************************************************
VOID __regargs SetColor(
	WORD Index,
	UBYTE Value)
{
	struct Gadget *Gadget;
	struct PropInfo *Prop;

	Gadget = AllGadgets[Index];
  if( !(Gadget->Flags&GFLG_DISABLED) )
  {
	  Prop = Gadget->SpecialInfo;
  	ModifyProp(Gadget,RD->MenuBarWindow,NULL,Prop->Flags,
		  (((ULONG)(MAXPOT * Value)) / 255),Prop->VertPot,
	  	Prop->HorizBody,Prop->VertBody);
  	PropValue(Gadget,Value);
  }
}

//*******************************************************************
VOID __regargs SetSliderColor(
	struct TrueColor *Color)
{
	struct RastPort *RP;

	RP = RD->MenuBarWindow->RPort;
	SetDrMd(RP,JAM2);
	SetAPen(RP,0);
	if (RGBList) {
		SetColor(ID_COLOR_RED,Color->Red);
		SetColor(ID_COLOR_GREEN,Color->Green);
		SetColor(ID_COLOR_BLUE,Color->Blue);

		SetupPalColor(Color);
		SmartInstall(TRUE,FALSE);
	}
	if (AlphaList) SetColor(ID_COLOR_ALPHA,Color->Alpha);
	SliderColor   = Color;
}

//*******************************************************************
VOID RefreshColorGadg(VOID)
{
	RefreshGList(CurrentBottomList,RD->MenuBarWindow,NULL,-1);
}

//*******************************************************************
WORD __asm CaseColorBackground(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct Gadget *First,*Next;
	struct Window *Window;
	struct CGPage *Page;
	WORD A;
	struct RenderData *R;

	R = RD;
	Window = R->MenuBarWindow;
	Page = R->CurrentPage;
	RemoveClearGList(&TextTopBtmList,TEXTTOP_BTM_COUNT);
	RemoveClearGList(&TCList,2);
	RemoveClearGList(&OLTopBtmList,TEXTTOP_BTM_COUNT);
	RemoveClearGList(&OCList,2);
	AllGadgets[ID_COLOR_BKG]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_COLOR_TEXT]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_SHADOW]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_OUTLINE]->Flags &= (~GFLG_SELECTED);

	if (!BKGList) {
		First = AddBarGadget(NULL,ID_COLOR_SOLID,COLOR_2_MINY);
		First->LeftEdge = COLOR_2_MINX;
		Next = AddBarGadget(First,ID_COLOR_GRADATION,COLOR_2_MINY);
		AddBarGadget(Next,ID_COLOR_COM_RGB,COLOR_2_MINY);
		BKGList = First;
		for (A=0; A < 3; A++) {
			if (A == Page->Background)
				AllGadgets[ID_COLOR_SOLID+A]->Flags |= GFLG_SELECTED;
			else
				AllGadgets[ID_COLOR_SOLID+A]->Flags &= (~GFLG_SELECTED);
		}
		AddGList(Window,First,-1,-1,NULL); // add to end of list
		if (Page->Background == BACKGROUND_GRADATION) AddTopBtmGadg();
		else if (Page->Background == BACKGROUND_RGB_BUFFER) {
			RemoveSliderList(&RGBList,RGB_COUNT);
			AddLoadRGBGadg();
		}
		RemoveSliderList(&AlphaList,ALPHA_COUNT);
		if (Page->Background != BACKGROUND_RGB_BUFFER)
			SetSliderColor(&RD->CurrentPage->TopBackground);
	}
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
VOID DrawAlphaMarks(VOID)
{
	struct Window *Window;
	struct RastPort *RP;
	WORD MinX,MinY,MaxX,DX,MaxY;
	struct Gadget *First;

	First = AllGadgets[ID_COLOR_ALPHA];
	Window = RD->MenuBarWindow;
	RP = Window->RPort;
	if (RD->CurrentPage->Type == PAGE_STATIC) {
		SetDrMd(RP,JAM2);
		SetAPen(RP,D_GREY);
		MinX = First->LeftEdge;
		MaxX = First->LeftEdge+First->Width-1;
		MinY = First->TopEdge+First->Height+2;
		MaxY = MinY+4;

		DX = (MaxX-MinX+8)>>2;
		DX -= 4;
		RectFill(RP,MinX,MinY,MinX+DX,MaxY);
		MinX += DX+4;
		RectFill(RP,MinX,MinY,MinX+DX,MaxY);
		MinX += DX+4;
		RectFill(RP,MinX,MinY,MinX+DX,MaxY);
		MinX += DX+4;
		RectFill(RP,MinX,MinY,MinX+DX,MaxY);
/*
#ifdef ASDFG
		DX = (MaxX-MinX)/4;
		RectFill(RP,MinX,MinY,MinX+5,MinY+4);
		MinX += DX;
		RectFill(RP,MinX,MinY,MinX+5,MinY+4);
		MinX += DX-1;
		RectFill(RP,MinX,MinY,MinX+5,MinY+4);
		MinX += DX;
		RectFill(RP,MinX,MinY,MinX+5,MinY+4);
		RectFill(RP,MaxX-5,MinY,MaxX,MinY+4);
#endif
 */
	}
}

//*******************************************************************
VOID AddAlphaGadg(VOID)
{
	struct Gadget *First;
	struct Window *Window;

	Window = RD->MenuBarWindow;
	if (!AlphaList) {
		First = AddBarGadget(NULL,ID_COLOR_ALPHA,COLOR_2_MINY);
		First->LeftEdge = COLOR_SLIDER_MINX;
		First->TopEdge = COLOR_ALPHA_MINY+2;
		AlphaList = First;
		AddGadget(Window,First,-1); // add to end of list
		DrawSliderBorders();
		PropValue(First,SliderColor->Alpha);
		DrawAlphaMarks();
	}
  else OnGadget(AllGadgets[ID_COLOR_ALPHA],Window,NULL);
}

//*******************************************************************
VOID AddLoadRGBGadg(VOID)
{
	struct Gadget *First;
	struct Window *Window;

	Window = RD->MenuBarWindow;
	if (!LoadList) {
		First = AddBarGadget(NULL,ID_LOAD_RGB,COLOR_2_MINY);
		First->LeftEdge = COLOR_3_MINX;
		First->NextGadget = NULL;
		LoadList = First;
		AddGList(Window,First,-1,-1,NULL); // add to end of list
	}
}

//*******************************************************************
VOID AddTopBtmGadg(VOID)
{
	struct Gadget *First;
	struct Window *Window;

	Window = RD->MenuBarWindow;
	if (!TopBtmList) {
		First = AddBarGadget(NULL,ID_COLOR_TOP,COLOR_2_MINY);
		First->LeftEdge = COLOR_3_MINX;
		AddBarGadget(First,ID_COLOR_BOTTOM,COLOR_2_MINY);
		TopBtmList = First;
		AllGadgets[ID_COLOR_TOP]->Flags |= GFLG_SELECTED;
		AllGadgets[ID_COLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);
		AddGList(Window,First,-1,-1,NULL); // add to end of list
	}
}

//*******************************************************************
VOID AddTextTopBtmGadg(VOID)
{
	struct Gadget *First;
	struct Window *Window;

	Window = RD->MenuBarWindow;
	if (!TextTopBtmList) {
		First = AddBarGadget(NULL,ID_TEXTCOLOR_TOP,COLOR_2_MINY);
		First->LeftEdge = COLOR_3_MINX;
		AddBarGadget(First,ID_TEXTCOLOR_BOTTOM,COLOR_2_MINY);
		TextTopBtmList = First;
		AllGadgets[ID_TEXTCOLOR_TOP]->Flags |= GFLG_SELECTED;
		AllGadgets[ID_TEXTCOLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);
		AddGList(Window,First,-1,-1,NULL); // add to end of list
	}
}

//*******************************************************************
VOID AddOLTopBtmGadg(VOID)
{
	struct Gadget *First;
	struct Window *Window;

	Window = RD->MenuBarWindow;
	if (!OLTopBtmList) {
		First = AddBarGadget(NULL,ID_OLCOLOR_TOP,COLOR_2_MINY);
		First->LeftEdge = COLOR_3_MINX;
		AddBarGadget(First,ID_OLCOLOR_BOTTOM,COLOR_2_MINY);
		OLTopBtmList = First;
		AllGadgets[ID_OLCOLOR_TOP]->Flags |= GFLG_SELECTED;
		AllGadgets[ID_OLCOLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);
		AddGList(Window,First,-1,-1,NULL); // add to end of list
	}
}

//*******************************************************************
VOID AddRGBGadg(VOID)
{
	struct Gadget *First,*Next,*Last;
	struct Window *Window;

	Window = RD->MenuBarWindow;
	if (!RGBList) {
		First = AddBarGadget(NULL,ID_COLOR_RED,COLOR_2_MINY);
		First->LeftEdge = COLOR_SLIDER_MINX;
		First->TopEdge = COLOR_SLIDER_MINY+2;

		Next = AddBarGadget(First,ID_COLOR_GREEN,COLOR_2_MINY);
		First->NextGadget = Next;
		Next->LeftEdge = COLOR_SLIDER_MINX;
		Next->TopEdge = First->TopEdge+First->Height+4;
		Last = Next;

		Next = AddBarGadget(Next,ID_COLOR_BLUE,COLOR_2_MINY);
		Last->NextGadget = Next;
		Next->LeftEdge = COLOR_SLIDER_MINX;
		Next->TopEdge = Last->TopEdge+Last->Height+4;
		Next->NextGadget = NULL;

		RGBList = First;
		AddGList(Window,First,-1,-1,NULL); // add to end of list
		DrawSliderBorders();
		PropValue(First,SliderColor->Red);
		PropValue(Last,SliderColor->Green);
		PropValue(Next,SliderColor->Blue);
	}
}

//*******************************************************************
VOID SelectColorText(VOID)
{
	AllGadgets[ID_COLOR_BKG]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_TEXT]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_COLOR_SHADOW]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_OUTLINE]->Flags &= (~GFLG_SELECTED);
}

//*******************************************************************
VOID __regargs RemoveClearGList(
	struct Gadget **PGadget,
	UWORD Count)
{
	struct RastPort *RP;
	struct Gadget *Gadget,*Next;

	Gadget = *PGadget;
	while (Gadget && Count) {
		Next = Gadget->NextGadget;
		RemoveGadget(RD->MenuBarWindow,Gadget);
		RP = RD->MenuBarWindow->RPort;
		SetDrMd(RP,JAM2);
		SetAPen(RP,BOX_BG);
		RectFill(RP,Gadget->LeftEdge,Gadget->TopEdge,
			Gadget->LeftEdge+Gadget->Width-1,
			Gadget->TopEdge+Gadget->Height-1);
		WaitBlit();
		Gadget = Next;
		Count--;
	}
	*PGadget = NULL;
}

//*******************************************************************
// Also clears area for "RGBA" and value
VOID __regargs RemoveSliderList(
	struct Gadget **PGadget,
	UWORD Count)
{
	struct RastPort *RP;
	struct Gadget *Gadget,*Next;
	struct Rectangle Rect;
	WORD A,C;

	if (Gadget = *PGadget) {
		Rect.MinX = COLOR_RGBA_MINX-12;
		Rect.MaxX = COLOR_NUM_MINX + (TEXT_WIDTH*3);
		Rect.MinY = Gadget->TopEdge;
		Rect.MaxY = Gadget->TopEdge+Gadget->Height-1;

	// get erase bounding box
		Next = Gadget->NextGadget;
		C = Count - 1;
		while (Next && C) {
			if (Next->TopEdge < Rect.MinY) Rect.MinY = Next->TopEdge;
			A = Next->TopEdge+Next->Height-1;
			if (A > Rect.MaxY) Rect.MaxY = A;
			Next = Next->NextGadget;
			C--;
		}
		Rect.MinY -= 4;
		Rect.MaxY += 4;

		RemoveClearGList(PGadget,Count);
		RP = RD->MenuBarWindow->RPort;
		SetDrMd(RP,JAM2);
		SetAPen(RP,BOX_BG);
		RectFill(RP,Rect.MinX,Rect.MinY,Rect.MaxX,Rect.MaxY);
	}
}


VOID ClearAlphaGadg(VOID)
{
 	struct RastPort *RP;
  struct Gadget *Gadget;
	struct Rectangle Rect;

	Gadget = AllGadgets[ID_COLOR_ALPHA];
  RemoveClearGList(&Gadget,1);
	Rect.MinX = COLOR_RGBA_MINX-12;
	Rect.MaxX = COLOR_NUM_MINX + (TEXT_WIDTH*3);
	Rect.MinY = Gadget->TopEdge+Gadget->Height-1;
	Rect.MaxY = Rect.MinY + 8;

  RP = RD->MenuBarWindow->RPort;
	SetDrMd(RP,JAM2);
	SetAPen(RP,BOX_BG);
	RectFill(RP,Rect.MinX,Rect.MinY,Rect.MaxX,Rect.MaxY);
}

//*******************************************************************
BOOL __regargs MovingPage(
	struct CGPage *Page)
{
	UBYTE Type;

	Type = Page->Type;
	if ((Type == PAGE_SCROLL) || (Type == PAGE_CRAWL)) return(TRUE);
	return(FALSE);
}

//*******************************************************************
WORD __asm CaseColorText(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct Gadget *First;
	struct Window *Window;
	struct RenderData *R;

	R = RD;
	Window = R->MenuBarWindow;
	SetLineColor = TRUE;
	RemoveClearGList(&BKGList,BKG_COUNT);
	RemoveClearGList(&TopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&OLTopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&LoadList,1);
	RemoveClearGList(&OCList,TOP_BTM_COUNT);
	if ( !(R->DefaultAttr.SpecialFill & FILL_TBGRAD) )
   	RemoveClearGList(&TextTopBtmList,TOP_BTM_COUNT);
 	SelectColorText();
	AddRGBGadg();
	if (!MovingPage(RD->CurrentPage))
  {
    AddAlphaGadg();
    if (!TCList) {
    	First = AddBarGadget(NULL,ID_TEXTCOLOR_SOLID,COLOR_2_MINY);
    	First->LeftEdge = COLOR_2_MINX;
    	AddBarGadget(First,ID_TEXTCOLOR_GRADATION,COLOR_2_MINY);
    	TCList = First;
    	if (R->DefaultAttr.SpecialFill & FILL_TBGRAD)
      {
      	AllGadgets[ID_TEXTCOLOR_GRADATION]->Flags |= GFLG_SELECTED;
    		AllGadgets[ID_TEXTCOLOR_SOLID]->Flags &= (~GFLG_SELECTED);
      }
    	else
      {
      	AllGadgets[ID_TEXTCOLOR_SOLID]->Flags |= GFLG_SELECTED;
    		AllGadgets[ID_TEXTCOLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
      }
    	AddGList(Window,First,-1,-1,NULL); // add to end of list
    	if ( R->DefaultAttr.SpecialFill & FILL_TBGRAD ) AddTextTopBtmGadg();
    }
  }
 	SetSliderColor(&RD->DefaultAttr.FaceColor);
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorShadow(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_COLOR_BKG]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_TEXT]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_SHADOW]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_COLOR_OUTLINE]->Flags &= (~GFLG_SELECTED);

	AddRGBGadg();
	if (!MovingPage(RD->CurrentPage)) AddAlphaGadg();
	SetSliderColor(&RD->DefaultAttr.ShadowColor);
	SetLineColor = TRUE;
	RemoveClearGList(&BKGList,BKG_COUNT);
	RemoveClearGList(&TopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&TextTopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&OLTopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&TCList,TOP_BTM_COUNT);
	RemoveClearGList(&OCList,TOP_BTM_COUNT);
	RemoveClearGList(&LoadList,1);
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorOutline(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct Gadget *First;
	struct Window *Window;
	struct RenderData *R;

	R = RD;
	Window = R->MenuBarWindow;
	SetLineColor = TRUE;
	RemoveClearGList(&BKGList,BKG_COUNT);
	RemoveClearGList(&TopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&TextTopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&TCList,TOP_BTM_COUNT);
	RemoveClearGList(&LoadList,1);
	if ( !(R->DefaultAttr.SpecialFill & OLFILL_GRAD) )
   	RemoveClearGList(&OLTopBtmList,TOP_BTM_COUNT);

	AllGadgets[ID_COLOR_BKG]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_TEXT]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_SHADOW]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_OUTLINE]->Flags |= GFLG_SELECTED;

	AddRGBGadg();
	if (!MovingPage(RD->CurrentPage))
  {
    AddAlphaGadg();
    if (!OCList) {
    	First = AddBarGadget(NULL,ID_OLCOLOR_SOLID,COLOR_2_MINY);
    	First->LeftEdge = COLOR_2_MINX;
    	AddBarGadget(First,ID_OLCOLOR_GRADATION,COLOR_2_MINY);
    	OCList = First;
    	if (R->DefaultAttr.SpecialFill & OLFILL_GRAD)
      {
      	AllGadgets[ID_OLCOLOR_GRADATION]->Flags |= GFLG_SELECTED;
    		AllGadgets[ID_OLCOLOR_SOLID]->Flags &= (~GFLG_SELECTED);
      }
    	else
      {
      	AllGadgets[ID_OLCOLOR_SOLID]->Flags |= GFLG_SELECTED;
    		AllGadgets[ID_OLCOLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
      }
    	AddGList(Window,First,-1,-1,NULL); // add to end of list
    	if (R->DefaultAttr.SpecialFill & OLFILL_GRAD) AddOLTopBtmGadg();
    }
	}
	SetSliderColor(&RD->DefaultAttr.OutlineColor);
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorSolid(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_COLOR_SOLID]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_COLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_COM_RGB]->Flags &= (~GFLG_SELECTED);
	RD->CurrentPage->Background = BACKGROUND_SOLID;

	RemoveClearGList(&TopBtmList,TOP_BTM_COUNT);
	RemoveClearGList(&LoadList,1);
	SetSliderColor(&RD->CurrentPage->TopBackground);
	SetLineColor = FALSE;
	AddRGBGadg();
	RefreshColorGadg();
	return(REFRESH_NONE);
}


//*******************************************************************
WORD __asm CaseTextColorSolid(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_TEXTCOLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_TEXTCOLOR_SOLID]->Flags |= GFLG_SELECTED;
 	RemoveClearGList(&TextTopBtmList,TOP_BTM_COUNT);
	AddRGBGadg();
	if (!MovingPage(RD->CurrentPage)) AddAlphaGadg();
//	SelectColorText();
	RD->DefaultAttr.SpecialFill &= (~FILL_TBGRAD);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.SpecialFill,ATTR_FILL);
	SetSliderColor(&RD->DefaultAttr.FaceColor);
	SetLineColor = TRUE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseOLColorSolid(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_OLCOLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_OLCOLOR_SOLID]->Flags |= GFLG_SELECTED;
 	RemoveClearGList(&OLTopBtmList,TOP_BTM_COUNT);
	AddRGBGadg();
	if (!MovingPage(RD->CurrentPage)) AddAlphaGadg();
	RD->DefaultAttr.SpecialFill &= (~OLFILL_GRAD);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.SpecialFill,ATTR_FILL);
	SetSliderColor(&RD->DefaultAttr.OutlineColor);
	SetLineColor = TRUE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorGradation(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_COLOR_SOLID]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_GRADATION]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_COLOR_COM_RGB]->Flags &= (~GFLG_SELECTED);
	RD->CurrentPage->Background = BACKGROUND_GRADATION;

	RemoveClearGList(&LoadList,1);
	AddTopBtmGadg();
	SetSliderColor(&RD->CurrentPage->TopBackground);
	SetLineColor = FALSE;
	AddRGBGadg();
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseTextColorGradation(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_TEXTCOLOR_SOLID]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_TEXTCOLOR_GRADATION]->Flags |= GFLG_SELECTED;
	RD->DefaultAttr.SpecialFill |= FILL_TBGRAD;
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.SpecialFill,ATTR_FILL);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
	AddTextTopBtmGadg();
	SetSliderColor(&RD->DefaultAttr.FaceColor);
	SetLineColor = TRUE;
	AddRGBGadg();
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseOLColorGradation(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_OLCOLOR_SOLID]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_OLCOLOR_GRADATION]->Flags |= GFLG_SELECTED;
	RD->DefaultAttr.SpecialFill |= OLFILL_GRAD;
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.SpecialFill,ATTR_FILL);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
	AddOLTopBtmGadg();
	SetSliderColor(&RD->DefaultAttr.OutlineColor);
	SetLineColor = TRUE;
	AddRGBGadg();
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorComRGB(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	if (!RD->CommonRGB) CGMultiRequest(NoComRGBMsg,2,REQ_CENTER|REQ_H_CENTER);

	AllGadgets[ID_COLOR_SOLID]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_GRADATION]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_COM_RGB]->Flags |= GFLG_SELECTED;
	RD->CurrentPage->Background = BACKGROUND_RGB_BUFFER;

	RemoveClearGList(&TopBtmList,TOP_BTM_COUNT);
	RemoveSliderList(&RGBList,RGB_COUNT);
	AddLoadRGBGadg();
	RefreshColorGadg();
	return(REFRESH_NONE);
}
//*******************************************************************
WORD __asm CaseColorTop(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_COLOR_TOP]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_COLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);

	SetSliderColor(&RD->CurrentPage->TopBackground);
	SetLineColor = FALSE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseColorBottom(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_COLOR_TOP]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_COLOR_BOTTOM]->Flags |= GFLG_SELECTED;

	SetSliderColor(&RD->CurrentPage->BottomBackground);
	SetLineColor = FALSE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseTextColorTop(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_TEXTCOLOR_TOP]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_TEXTCOLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);

  if(RD->CurrentPage->Type==PAGE_STATIC)
    OnGadget(AllGadgets[ID_COLOR_ALPHA],RD->MenuBarWindow,NULL);
	SetSliderColor(&RD->DefaultAttr.FaceColor);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
	SetLineColor = TRUE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseTextColorBottom(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_TEXTCOLOR_TOP]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_TEXTCOLOR_BOTTOM]->Flags |= GFLG_SELECTED;

 	if(RD->CurrentPage->Type==PAGE_STATIC)
    OffGadget(AllGadgets[ID_COLOR_ALPHA],RD->MenuBarWindow,NULL);
	SetSliderColor(&RD->DefaultAttr.GradColor);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
	SetLineColor = TRUE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseOLColorTop(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_OLCOLOR_TOP]->Flags |= GFLG_SELECTED;
	AllGadgets[ID_OLCOLOR_BOTTOM]->Flags &= (~GFLG_SELECTED);

 	if(RD->CurrentPage->Type==PAGE_STATIC)
    OnGadget(AllGadgets[ID_COLOR_ALPHA],RD->MenuBarWindow,NULL);
	SetSliderColor(&RD->DefaultAttr.OutlineColor);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
	SetLineColor = TRUE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseOLColorBottom(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	AllGadgets[ID_OLCOLOR_TOP]->Flags &= (~GFLG_SELECTED);
	AllGadgets[ID_OLCOLOR_BOTTOM]->Flags |= GFLG_SELECTED;

 	if(RD->CurrentPage->Type==PAGE_STATIC)
    OffGadget(AllGadgets[ID_COLOR_ALPHA],RD->MenuBarWindow,NULL);
	SetSliderColor(&RD->DefaultAttr.OGradColor);
	SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
	SetLineColor = TRUE;
	RefreshColorGadg();
	return(REFRESH_NONE);
}

//*******************************************************************
VOID GoToNormal(VOID)
{
	struct RenderData *R;

	R = RD;

	R->NewBarMode = BAR_NORMAL;
	R->StatusMessage = NULL;
	R->UpdateInterface = TRUE;
}

//*******************************************************************
WORD __asm CaseContinue(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	struct Window *Window;

	R = RD;
	if (Window = R->MenuBarWindow) {
		switch(R->BarMode) {
			case BAR_COLOR:
      	TextTopBtmList = NULL;
      	TCList = NULL;
        SetGenlock(FALSE);
				SetRast(R->MenuBarWindow->RPort,0L);
				WaitBlit();
		// clear MS plane now, so doesn't flash
		if (!R->AAChips)
			ByteFillMemory(R->ThickInterface->Planes[2],0,
				(INTERFACE_WIDTH/8)*INTERFACE_HEIGHT);

				SetupPalColor(&Normal4);
				MakeMenuBarHeight(BAR_0_MAXY+1);
				SmartInstall(FALSE,FALSE);
			break;
		}
		GoToNormal();
	}
	return(REFRESH_YES);
}

//*******************************************************************
VOID PutMenuBarTop(WORD NewHeight)
{
	struct RenderData *R;
	struct Window *Window;

	R = RD;
	if (Window = R->MenuBarWindow) {
		if ((Window->TopEdge != 0) || (Window->Height != NewHeight)) {
			ChangeWindowBox(Window,TOP_MINX,TOP_MINY,Window->Width,NewHeight);
			WaitForClass(IDCMP_CHANGEWINDOW);
		}
	}
}

//*******************************************************************
VOID MakeMenuBarHeight(WORD NewHeight)
{
	struct RenderData *R;
	struct Window *Window;
	WORD Top;

	R = RD;
	if (Window = R->MenuBarWindow) {
		if (Window->Height != NewHeight) {
			Top = Window->TopEdge;
			if ((Window->TopEdge + NewHeight) > R->InterfaceScreen->Height)
				Top = R->InterfaceScreen->Height - NewHeight;
			ChangeWindowBox(Window,TOP_MINX,Top,Window->Width,NewHeight);
			WaitForClass(IDCMP_CHANGEWINDOW);
		}
	}
}

//*******************************************************************
VOID RenderThick(VOID)
{
	struct RastPort *RP;
	struct RenderData *R;
	struct Window *Window;
	struct Gadget *Gadget;

	R = RD;
	if (Window = R->MenuBarWindow) {
	RP = R->ThickRP;
	Gadget = AllGadgets[ID_COLOR_SWATCH];
	DrawImage(RP,Gadget->GadgetRender,Window->LeftEdge+SWATCH_MINX,
		Window->TopEdge+SWATCH_MINY);

	WaitBlit();
	}
}

//*******************************************************************
VOID EraseThick(VOID)
{
	struct RastPort *RP;
	struct RenderData *R;
	struct Window *Window;
	struct Gadget *Gadget;

	R = RD;
	if (Window = R->MenuBarWindow) {
	RP = R->ThickRP;
	Gadget = AllGadgets[ID_COLOR_SWATCH];
	SetAPen(RP,0);
	RectFill(RP,Window->LeftEdge+SWATCH_MINX,
		Window->TopEdge+SWATCH_MINY,
		Window->LeftEdge+SWATCH_MINX+Gadget->Width-1,
		Window->TopEdge+SWATCH_MINY+Gadget->Height-1);
	WaitBlit();
	}
}

//*******************************************************************
WORD __asm CaseColor(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	struct Window *Window;
	WORD Refresh = REFRESH_NONE;

	R = RD;
	if (Window = R->MenuBarWindow) {

    SetGenlock(TRUE);

		R->NewBarMode = BAR_COLOR;
		R->UpdateInterface = TRUE;
		if (R->CurrentPage->Type == PAGE_BUFFER)
			R->StatusMessage = ChooseColor;
		else
			R->StatusMessage = ChooseColorNoBG;

		MakeMenuBarHeight(BAR_2_MAXY+1);
		SetLineColor = TRUE;

	// clear MS plane now, about to be put up
	// (shared with others)
		if (!R->AAChips)
			ByteFillMemory(R->ThickInterface->Planes[2],0,
				(INTERFACE_WIDTH/8)*INTERFACE_HEIGHT);

		Refresh = REFRESH_YES;
	}
	return(Refresh);
}

//*******************************************************************
// ID_PAGE_TYPE also comes here
//
WORD __asm CaseMessage(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	WORD Refresh = REFRESH_NONE;
	struct Rectangle *Rect;
	struct Window *Window;
	struct RenderData *R;

	R = RD;
	// remove swatch
	if (R->BarMode == BAR_COLOR) EraseThick();

	Rect = &Bound;
	Window = R->MenuBarWindow;
	Rect->MinX = 0;
	Rect->MinY = 0;
	Rect->MaxX = Window->Width-1;
	Rect->MaxY = Window->Height-1;
	CalcBound(Rect,&Border);

// save start position
	BeginX = Window->LeftEdge;
	BeginY = Window->TopEdge;
	MaxY = INTERFACE_HEIGHT - Window->Height;
	if (BeginY < TOP_MINY) BeginY = TOP_MINY;
	if (BeginY > MaxY) BeginY = MaxY;
	NowY = BeginY;

// draw box
	DrawBorder(&R->InterfaceScreen->RastPort,&Border,BeginX,BeginY);
	DraggingBar = TRUE;
	Window->Flags |= WFLG_REPORTMOUSE;
	//ModifyIDCMP(Window,Window->IDCMPFlags | IDCMP_MOUSEBUTTONS);

	return(Refresh);
}

//*******************************************************************
VOID __asm MoveBar(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	struct Window *Window;
	WORD TestY;

	R = RD;
	Window = R->MenuBarWindow;
	TestY = IntuiMsg->MouseY + Window->TopEdge;
	if (TestY < TOP_MINY) TestY = TOP_MINY;
	else if (TestY > MaxY) TestY = MaxY;
	if (TestY != NowY) {
		DrawBorder(&R->InterfaceScreen->RastPort,&Border,BeginX,NowY);
		NowY = TestY;
		DrawBorder(&R->InterfaceScreen->RastPort,&Border,BeginX,NowY);
	}
}

//*******************************************************************
WORD __asm ReleaseBar(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	struct Window *Window;

	R = RD;
	Window = R->MenuBarWindow;
	//ModifyIDCMP(Window,Window->IDCMPFlags & (~IDCMP_MOUSEBUTTONS));
	Window->Flags &= ~WFLG_REPORTMOUSE;
	DrawBorder(&R->InterfaceScreen->RastPort,&Border,BeginX,NowY);
	WaitBlit();
	ChangeWindowBox(Window,TOP_MINX,NowY,Window->Width,Window->Height);
	DraggingBar = FALSE;
	WaitForClass(IDCMP_CHANGEWINDOW);
	// add swatch
	if (R->BarMode == BAR_COLOR) RenderThick();

	return(REFRESH_YES);
}

//*******************************************************************
struct CGLine *__asm GetNextHigherLine(
	register __a0 struct CGPage *Page,
	register __a1 struct CGLine *Line)
{
	struct CGLine *NextHi,*Check;
	UWORD CheckY,HiY;

	if (Page->Type == PAGE_SCROLL) {
		NextHi = (struct CGLine *)Line->Node.mln_Pred;
		if (!NextHi->Node.mln_Pred) NextHi = Line;

	} else {
		NextHi = Line;
		HiY = 0;
		Check = (struct CGLine *)Page->LineList.mlh_Head;
		while (Check->Node.mln_Succ) {
			CheckY = Check->YOffset;
			if ((CheckY >= HiY) && (CheckY < Line->YOffset)) {
				NextHi = Check;
				HiY = CheckY;
			}
			Check = (struct CGLine *)Check->Node.mln_Succ;
		}
	}
	return(NextHi);
}

//*******************************************************************
struct CGLine *__asm GetNextLowerLine(
	register __a0 struct CGPage *Page,
	register __a1 struct CGLine *Line)
{
	struct CGLine *NextLo,*Check;
	UWORD CheckY,LoY,LineMaxY;

	if (Page->Type == PAGE_SCROLL) {
		NextLo = (struct CGLine *)Line->Node.mln_Succ;
		if (!NextLo->Node.mln_Succ) NextLo = Line;

	} else {
		NextLo = Line;
		LoY = 65535;
		LineMaxY = Line->YOffset;
		Check = (struct CGLine *)Page->LineList.mlh_Head;
		while (Check->Node.mln_Succ) {
			CheckY = Check->YOffset;
			if ((CheckY <= LoY) && (CheckY > LineMaxY)) {
				NextLo = Check;
				LoY = CheckY;
			}
			Check = (struct CGLine *)Check->Node.mln_Succ;
		}
	}
	return(NextLo);
}

//*******************************************************************
struct CGLine *__asm GetTopmostLine(
	register __a0 struct MinList *List)
{
	struct CGLine *Line,*Top;
	UWORD TopY;

	Line = (struct CGLine *)List->mlh_Head;
	if (RD->CurrentPage->Type == PAGE_CRAWL) return(Line);
	Top = Line;
	TopY = 65535;
	while (Line->Node.mln_Succ) {
		if (Line->YOffset < TopY) {
			Top = Line;
			TopY = Line->YOffset;
		}
		Line = (struct CGLine *)Line->Node.mln_Succ;
	}
	return(Top);
}

//*******************************************************************
struct CGLine *__asm GetBottommostLine(
	register __a0 struct MinList *List)
{
	struct CGLine *Line,*Top;
	UWORD TopY;

	Line = (struct CGLine *)List->mlh_Head;
	if (RD->CurrentPage->Type == PAGE_CRAWL) return(Line);
	Top = Line;
	TopY = 0;
	while (Line->Node.mln_Succ) {
		if (Line->YOffset > TopY) {
			Top = Line;
			TopY = Line->YOffset;
		}
		Line = (struct CGLine *)Line->Node.mln_Succ;
	}
	return(Top);
}

#define RAW_F1 0x50
#define RAW_F10 0x59
//*******************************************************************
WORD __asm CaseRawKey(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	WORD Code, Refresh = REFRESH_NONE;
	struct InputEvent *IE;
	UBYTE Buffer[30];
	WORD __asm (*Handler)(register __a0 struct IntuiMessage *);
	struct RenderData *R;

	R = RD;
// if in raw key table, use that routine
	if (Handler = KeyRawFcn(IntuiMsg))  // ignore warning
	{
		Refresh = Handler(IntuiMsg);
	} else
	{
		Code = IntuiMsg->Code;
		if (((R->BarMode == BAR_NORMAL)||(R->BarMode == BAR_PAGE_CMDS) // else, if function key, and BAR_NORMAL, use that table
			||(R->BarMode == BAR_COLOR)) && (Code >= RAW_F1) && (Code <= RAW_F10) )
		{
			if( IntuiMsg->Qualifier&(IEQUALIFIER_LALT|IEQUALIFIER_RALT) )
				Refresh = CaseMacro(IntuiMsg);
			else if( Handler = KeyFunction(Code) )
				Refresh = Handler(IntuiMsg);
		} else   // else, if converts to 1 vanilla key, send to CaseDefault
		{
			IE = &RD->EatSquid;
			IE->ie_Class = IECLASS_RAWKEY;
			IE->ie_Code = Code;
			IE->ie_Qualifier = IntuiMsg->Qualifier;
			IE->ie_position.ie_addr = *((APTR*)IntuiMsg->IAddress);
			if (RawKeyConvert(IE,&Buffer[0],30,NULL) == 1)
			{
				Code = Buffer[0];
				if (Code >= 32)
					Refresh = CaseDefault(Code,0);
			}
		}
	}
	return(Refresh);
}

//*******************************************************************
WORD __asm CaseFXSpeed(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UBYTE Type;
	WORD Min,Max,Step;

	R = RD;
	Type = R->CurrentPage->Speed;

	if (R->CurrentPage->Type == PAGE_CRAWL) {
		Min = MIN_CRAWL_SPEED;
		Max = MAX_CRAWL_SPEED;
		Step = CRAWL_JUMP;
	} else {
		Min = MIN_SCROLL_SPEED;
		Max = MAX_SCROLL_SPEED;
		Step = SCROLL_JUMP;
	}
	if (Type >= Max) Type = Min;
	else Type += Step;

	R->CurrentPage->Speed = Type;
	R->UpdateBottomBar = TRUE;

	return(0);
}

//*******************************************************************
WORD __asm CasePlaybackMode(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	BYTE Type;
	WORD Max;

	R = RD;
	Type = R->CurrentPage->PlaybackMode;

	if (R->CurrentPage->Type == PAGE_CRAWL) {
		Max = PLAY_ONCE;
	} else {
		Max = PLAY_FREEZE;
	}

	if (Type >= Max) Type = PLAY_FOREVER;
	else Type += 1;

	R->CurrentPage->PlaybackMode = Type;
	R->UpdateBottomBar = TRUE;
	return(REFRESH_YES);
}

//*******************************************************************
WORD __asm CasePageType(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	struct Gadget *Gadget;
	WORD A,N;
	char *Save,*Mess[4];

	R = RD;
	switch(R->BarMode) {
		case BAR_NORMAL:
			R->NewBarMode = BAR_PAGE_TYPE; // CMDS
			R->UpdateInterface = TRUE;
			R->StatusMessage = ChoosePage; //PageCmdsMsg;
		break;

		//case BAR_PAGE_CMDS:
		case BAR_PAGE_TYPE:
			Gadget = IntuiMsg->IAddress;
			A = Gadget->GadgetID - ID_PAGE_EMPTY;
			R->UpdatePage = UPDATE_PAGE_OLD;

// display working status line
			if (A != R->CurrentPage->Type) {
			N = NodesThisList(&R->CurrentPage->LineList);
			if ((!N) || ((N == 1) && (!(((struct CGLine *)R->CurrentPage->
				LineList.mlh_Head)->Text[0].Ascii)))) goto Trivial;

			Mess[0] = SurePageType;
			Mess[1] = SurePage2;
			if (CGMultiRequest(Mess,2,REQ_CONT_CANCEL|REQ_CENTER|REQ_H_CENTER)) {
	Trivial:
				Save = R->StatusMessage;
				NewUpdateMessage(WorkMsg);
				R->StatusMessage = Save;
				ChangePageType(R->CurrentPage,A);
				R->UpdatePage = UPDATE_PAGE_NEW;
			}
			R->DeleteBuffer = TRUE;
			}
			GoToNormal();

			NewCurrentLineCursor((struct CGLine *)R->CurrentPage->
				LineList.mlh_Head,0);
			R->UpdateInterface = TRUE;
	}
	return(0);
}

//*******************************************************************
WORD __asm CaseJustify(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UBYTE Type;
	struct CGLine *Line,*Next;
	struct CGPage *Page;

	R = RD;
	Type = R->DefaultLine.JustifyMode;
	Page = R->CurrentPage;

	if ((Page->Type) && (Page->Type != PAGE_CRAWL)) {
	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ) {
		if (AnyCharSelected(Line) && (Line->JustifyMode != Type)) goto Skip;
		Line = Next;
	}
//	if (Type >= JUSTIFY_SKIP) Type = JUSTIFY_NONE;
	if (Type >= JUSTIFY_RIGHT) Type = JUSTIFY_NONE;
	else Type++;
	R->DefaultLine.JustifyMode = Type;
Skip:

	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ) {
		if (AnyCharSelected(Line)) {
			Line->JustifyMode = Type;
			JustifyThisLine(Line);
			R->UpdatePage = UPDATE_PAGE_OLD;
		}
		Line = Next;
	}
	R->UpdateBottomBar = TRUE;
	}
	return(REFRESH_YES);
}

//*******************************************************************
WORD __asm CaseOutline(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UBYTE Type;

	R = RD;
	Type = R->DefaultAttr.OutlineType;
	if (AllSelectSame(R->CurrentPage,&R->DefaultAttr,ATTR_OUTLINE_TYPE)) {
		if (Type == (MAX_OUTLINE_TYPE)) Type = 0;
		else Type += 1;
		R->DefaultAttr.OutlineType = Type;
	}
	SetSelectAttrib(R->CurrentPage,&Type,ATTR_OUTLINE_TYPE);
	UpdateFixPage();
	return(REFRESH_YES);
}

//*******************************************************************
WORD __asm CaseShadowPriority(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UBYTE Pri,Type;
	struct CGPage *Page;

	R = RD;
	Page = R->CurrentPage;
	Type = Page->Type;

	if ((R->DefaultAttr.ShadowType || R->DefaultAttr.OutlineType) &&
		(Type != PAGE_SCROLL) && (Type != PAGE_EMPTY)) {
	Pri = R->DefaultAttr.ShadowPriority;
	if (AllSelectSame(Page,&R->DefaultAttr,ATTR_SHADOW_PRIORITY)) {
		Pri ^= 1;
		R->DefaultAttr.ShadowPriority = Pri;
	}
	SetSelectAttrib(Page,&Pri,ATTR_SHADOW_PRIORITY);
	UpdateFixPage();
	}
	return(REFRESH_YES);
}

//*******************************************************************
WORD __asm CaseShadowLength(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UWORD Length;

	R = RD;
	if (R->DefaultAttr.ShadowType) {
		Length = R->DefaultAttr.ShadowLength;
		if (AllSelectSame(R->CurrentPage,&R->DefaultAttr,ATTR_SHADOW_LENGTH)) {
			if (Length >= MAX_SHADOW_LENGTH) Length = MIN_SHADOW_LENGTH;
			else Length += SHADOW_INCREMENT;
			R->DefaultAttr.ShadowLength = Length;
		}
		SetSelectAttrib(R->CurrentPage,(UBYTE *)&Length,ATTR_SHADOW_LENGTH);
		UpdateFixPage();
	}
	return(REFRESH_YES);
}

//*******************************************************************
WORD __asm CaseShadowDir(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UBYTE Dir;

	R = RD;
	if (R->DefaultAttr.ShadowType) {
		Dir = R->DefaultAttr.ShadowDirection;
		if (AllSelectSame(R->CurrentPage,&R->DefaultAttr,ATTR_SHADOW_DIRECTION)) {
			if (Dir == SHADOW_NORTHWEST) Dir = SHADOW_NORTH;
			else Dir++;
			R->DefaultAttr.ShadowDirection = Dir;
		}
		SetSelectAttrib(R->CurrentPage,&Dir,ATTR_SHADOW_DIRECTION);
		UpdateFixPage();
	}
	return(REFRESH_YES);
}

//*******************************************************************
VOID UpdateFixPage(VOID)
{
	struct RenderData *R;
	UBYTE Type;
	char *Mess[2];

	R = RD;
	R->UpdateBottomBar = TRUE;
	Type = R->CurrentPage->Type;
	if ((Type == PAGE_SCROLL)||(Type == PAGE_CRAWL)) {
		if ((Type == PAGE_CRAWL) && (R->CurrentLine->TotalHeight > CRAWL_HEIGHT)) {
			Mess[0] = CrawlTrimMsg;
			Mess[1] = CrawlTrim2;
			CGMultiRequest(Mess,2,REQ_CENTER|REQ_H_CENTER); // fixed below
		}
		if (!MakePageRight(R->CurrentPage,R->CurrentLine,FALSE,FALSE)) {
			NewCurrentLineCursor((struct CGLine *)R->CurrentPage->LineList
				.mlh_Head,0);
		}
	}
}

//*******************************************************************
WORD __asm CaseShadowType(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	UBYTE Type;
	R = RD;
	Type = R->DefaultAttr.ShadowType;
	if (AllSelectSame(R->CurrentPage,&R->DefaultAttr,ATTR_SHADOW_TYPE)) {
		if (Type == SHADOW_CAST) Type = SHADOW_NONE;
		else Type++;
		if (Type) {
			if (R->DefaultAttr.ShadowLength < MIN_SHADOW_LENGTH)
				R->DefaultAttr.ShadowLength = MIN_SHADOW_LENGTH;
		}
		R->DefaultAttr.ShadowType = Type;
	}
	SetSelectAttrib(R->CurrentPage,&Type,ATTR_SHADOW_TYPE);
	UpdateFixPage();
	return(REFRESH_YES);
}

//*******************************************************************
// AAR -- junk
char *DefNameFcn(void *junk, int Entries)
{
	return(&DefNames[Entries][0]);
}

//*******************************************************************
WORD __asm CaseColorDefaults(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	PopUpID ID;
	struct Gadget *Gadget;
	WORD X,Y,A;

	if (SliderColor) {
		EraseThick();
		PUCDefaultRender(&PopUp);
		PopUp.drawBG = (DrawBGFunc *)DrawBG;
		Gadget = AllGadgets[ID_COLOR_DEFAULTS];
		X = Gadget->LeftEdge + (Gadget->Width >> 1);
		Y = Gadget->TopEdge + (Gadget->Height) - 2;
		ID = PUCCreate((NameFunc *)DefNameFcn,NULL,&PopUp);
		PUCSetNumItems(ID,NUM_DEFAULTS);
		PUCSetCurItem(ID,0);
		RD->MenuBarWindow->Flags |= WFLG_REPORTMOUSE;
		A = PUCActivate(ID,RD->MenuBarWindow,X,Y,IntuiMsg->MouseX,IntuiMsg->MouseY);
		RD->MenuBarWindow->Flags &= ~WFLG_REPORTMOUSE;
		PUCDestroy(ID);
		RenderThick();
		if ((A >= 0) && (SliderColor)) {
			CopyMem(&DefColors[A],SliderColor,3); // don't copy alpha
			SetSliderColor(SliderColor);
    	if (SetLineColor)	
        SetSelectAttrib(RD->CurrentPage,(UBYTE *)&RD->DefaultAttr.FaceColor,ATTR_COLOR);
		}
	}

	return(REFRESH_NONE);
}

//*******************************************************************
WORD __asm CaseEscape(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	struct RenderData *R;
	struct Window *Window;

	R = RD;
	if (R->BarMode == BAR_NORMAL) return(REFRESH_EXIT);
	if (Window = R->MenuBarWindow) {
		switch(R->BarMode) {
			case BAR_COLOR:
				return(CaseContinue(IntuiMsg));
		}
		GoToNormal();
	}
	return(REFRESH_YES);
}

//*******************************************************************
VOID InitFSPath(VOID)
{
	char *C;

	BGFilesPath[0] = 0;
	if (C = GetFSDevice()) {
		strcpy(BGFilesPath,C);
		strcat(BGFilesPath,FramestoreMsg);
	}
}

//*******************************************************************
WORD __asm CaseLoadRGB(
	register __a0 struct IntuiMessage *IntuiMsg)
{
	char *C,*Mess[2],*Save;
	WORD A;
	struct RenderData *R;

	R = RD;
	DefFileName[0] = 0;
	CurrentDir(R->ToasterRoot);
	EraseThick();
	if (R->CommonRGB) {
	if (C = FileRequest(LoadBGMsg,DefFileName,BGFilesPath)) {
		Save = R->StatusMessage;
		NewUpdateMessage(LoadingBGMsg);
		DisplayWaitSprite();
		A = LoadRGBPicture(C,&R->CommonRGB->Picture);
		DisplayNormalSprite();
		if (A) {
			Mess[0] = UnableBGMsg;
			Mess[1] = DefFileName;
			CGMultiRequest(Mess,2,REQ_CENTER|REQ_H_CENTER);
		}
		NewUpdateMessage(Save);
	}
	} else CGMultiRequest(NoComRGBMsg,2,REQ_CENTER|REQ_H_CENTER);
	return(REFRESH_YES);
}

// end of NewFunction.c
