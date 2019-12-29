/* $Id: panelhelp.c,v 1.18 1997/05/13 15:52:19 Holt Exp $
* $Log: panelhelp.c,v $
*Revision 1.18  1997/05/13  15:52:19  Holt
*added inheritance for Chromafx Croutons.
*
*Revision 1.17  1997/04/18  17:06:02  Holt
*added inhertance for keys.
*
*Revision 1.16  1996/11/18  18:30:16  Holt
*added more audio envelope support.
*
*Revision 1.15  1996/07/29  10:29:04  Holt
*added part of the audioenv panel
*
*Revision 1.14  1995/12/27  15:08:11  Holt
**** empty log message ***
*
*Revision 1.12  1995/12/26  18:24:16  Holt
*fixed eztime panelgadgets to stay on even frame values.
*
*Revision 1.11  1995/11/14  18:21:56  Flick
*Inherits variable speeds for FX/FX.
*Now sends FGC_FCOUNT command to new effect to let it rethink things.
*
*Revision 1.10  1995/11/14  18:03:01  Flick
*Now gives Ok/Cancel if can't inherit fully because it's too short, can cancel now
*Inherit an FX from another will now pickup the speed button.
*
*Revision 1.9  1995/10/24  17:14:13  Flick
*InheritTags now reports if it fails or is aborted
*
*Revision 1.8  1995/10/09  23:31:43  Flick
*Fixed quick adjust shadow math (always positive!)
*
*Revision 1.7  1995/10/09  16:44:51  Flick
*Inherit() can now pull tags out of a "Lost Crouton"
*New fn's: TagMoveFunc, LegalizeInOutPoints, WalkTagList
*
*Revision 1.6  1995/10/05  03:44:30  Flick
*Processing/Cutting panels now show/hear in-point of subclip when changing active one
*
*Revision 1.5  1995/10/03  18:12:39  Flick
*PNL_DIFF's now use TCDarkFont, removed RectFill's that were needed w/ proportional font
*
*Revision 1.4  1995/10/02  15:38:02  Flick
*QuickRenderFunc improved to handle partner &/or shadow locking
*
*Revision 1.3  1995/09/28  10:17:28  Flick
*Improved QuickRenderFunc to render 2 points ganged together, superficial changes to function
*args to imply a path arg, not just a volume name.
*
*Revision 1.2  1995/09/25  13:05:57  Flick
*Added InheritTags function, FRAC32 support math, QuickRenderFunc for quick tune RCB's
*
*Revision 1.1  1995/09/19  12:26:58  Flick
*Changes to help functions, such as: removed old Continue/Cancel hard-coded stuff and added MakeStdContinue/MakeStdCancel functions, added InitPanelLines to build an Easy/Expert panel from compact
*initializers, added DoGenButton(), changes to support omission of icon slider for cutting room
*on audio clips.
*
*Revision 1.0  1995/09/13  13:14:09  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	9-9-95	Marty F		Created this file
*********************************************************************/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/sghooks.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>

#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <time.h>
#include <editwindow.h>
#include <project.h>
#include <gadgets.h>
#include <prophelp.h>
#include <grazer.h>
#include <popup.h>
#include <editswit.h>
#include <crouton_all.h>
#include <request.h>
#include <tags.h>
#include <panel.h>
#include <flyer.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/diskfont.h>

//#define SERDEBUG	1
#include <serialdebug.h>

#ifndef PROTO_PASS
#include <proto.h>
#else
void __asm RenderFunc( REG(a0) struct RenderCallBack *);
DrawBGFunc *DrawBG();
#endif

//#define NO_CUTTING_ROOM


extern UBYTE __asm OppChanOnPrvw(void);

// *** External Globals ***
extern struct Gadget Gadget1;
extern struct Gadget *FirstG;
extern ULONG	*HiTime,*LoTime,*ALoTime,*AHiTime;
extern struct PanelLine *CurPLine,*Start;
extern struct TextFont *EditFont,*DarkFont,*TCDarkFont;
extern char ClipName[CLIP_PATH_MAX];
extern struct st_PopupRender PopUp;
extern struct EditWindow *EditTop,*EditBottom;
extern BOOL UseDropFrame;
extern UBYTE AAMachine;

extern struct ESParams1 ESparams1;
extern struct ESParams2 ESparams2;
extern struct ESParams3 ESparams3;
extern struct ESParams4 ESparams4;
extern char pstr[100],*PatienceMsg[];
extern char	*global_CurVolumeName;				// Current Flyer volume name (used for ReOrg)

extern __far struct PanelLine PLineDefaults[];

extern VOID __asm ByteFillMemory(register __a0 UBYTE *MemBlock,
									 register __d0 BYTE FillValue,
									 register __d1 ULONG MemSize);


// *** Global Data ***
struct RenderCallBack StudlyRCB={RenderFunc,NULL,0,0,0,0,NULL,NULL}, *MyRCB=&StudlyRCB;
//static char str[100];
LONG	InOrOut=0;
WORD	Rect[21];

UWORD	CandyStripe[] = {  // striped fill pattern
  0xe3e3,  0xf1f1,  0xf8f8,  0x7c7c,
  0x3e3e,  0x1f1f,  0x8f8f,  0xc7c7
};

UWORD	BCandyStripe[] = {  // striped fill pattern
  0xc7c7,  0x8f8f,  0x1f1f,  0x3e3e,
  0x7c7c,  0xf8f8,  0xf1f1,  0xe3e3
};


struct ClipCrUD {
	ULONG	FORM;		// FORM
	ULONG	fSize;	// FORMSize
	ULONG	CrUD;		// CrUD
	ULONG	Type;		// TYPE
	ULONG	cSize;	// 8
	ULONG	Clip;		// CLIP
	ULONG	ClipEnd;		// NULL
	ULONG	LIBS;		// LIBS
	ULONG	lSize;	// 0x18
	ULONG	lOff;		// 0xFFFFFCD0
	UWORD	lHuh;		// 0x0010
	UBYTE	lName[18]; // "effects.library"
	ULONG	TAGS;		// TAGS
	ULONG	tSize;	// COMMENT_MAX + 12
	ULONG	CommentTag; // TAG_CommentList
	ULONG	ctSize;	// COMMENT_MAX
	UBYTE	Comment[COMMENT_MAX];
/*
	ULONG	tDuration;
	ULONG	Dur;
	ULONG	tRecFields;
	ULONG	Fields;
*/
	ULONG	TagsEnd; // NULL
};

#define ID_CLIP  0x434C4950
#define ID_STIL  0x5354494C


//*******************************************************************
//      General Panel Utilities
//*******************************************************************

//*******************************************************************
VOID AddPanelG(struct Gadget **First,struct Gadget **This,struct Gadget **New)
{
	if (!(*First))
		*First = *This = *New;
	else
	{
		if(*This)
			(*This)->NextGadget = *New;
		*This = *New;
	}
}


//struct Gadget *CreateContCancel(UWORD	X1,UWORD	H, struct Gadget **ThisG,UWORD Tune)
//{
//	struct Gadget *NewG,*con=NULL,*can=NULL;
//	if ((NewG = AllocOneGadget(FindGadget(&Gadget1,ID_REQ_DARK_CANCEL))))
//	{
//		NewG->LeftEdge = X1 + PNL_WIDTH - NewG->Width - 8;
//		NewG->TopEdge = H + PNL_YADD - 8;
//		NewG->NextGadget = NULL;
//		can=NewG;
//		AddPanelG(&FirstG,ThisG,&NewG);
//	} else return(can);
//	if ((NewG = AllocOneGadget(FindGadget(&Gadget1,ID_DARK_CONTINUE))))
//	{
//		NewG->LeftEdge = 8;
//		NewG->TopEdge = H + PNL_YADD - 8;
//		NewG->NextGadget = NULL;
//		con=NewG;
//		AddPanelG(&FirstG,ThisG,&NewG);
//	} else
//	{
//		FreeGadgets(*ThisG);
//		return((struct Gadget *)NULL);
//	}
//	if(Tune)
//	{
//		if ((NewG = AllocOneGadget(FindGadget(&Gadget1,(Tune&TUNE_QUICK ? ID_QUICK_TUNE:ID_FINE_TUNE) ))) )
//		{
//			NewG->LeftEdge = con->LeftEdge + con->Width;
//			NewG->LeftEdge += (can->LeftEdge - NewG->LeftEdge - NewG->Width)>>1 ;
//			NewG->TopEdge = H + PNL_YADD - 9;
//			NewG->NextGadget = NULL;
//			AddPanelG(&FirstG,ThisG,&NewG);
//		} else
//		{
//			FreeGadgets(*ThisG);
//			return((struct Gadget *)NULL);
//		}
//	}
//	return( can );
//}


struct Gadget *CreateNewClipGads(struct NewWindow *NW, UWORD Y1, struct Gadget **ThisG)
{
	struct Gadget *Gadget, *Ret=NULL;
	UWORD Y;

	Y = NW->Height - 28;

//#ifdef NO_CUTTING_ROOM
//	Gadget = FindGadget(&Gadget1,ID_DARK_CONTINUE);
//#else
//	Gadget = FindGadget(&Gadget1,ID_MARK_PANEL);
//#endif
//	if ((Gadget = AllocOneGadget(Gadget)))
//	{
//		AddPanelG(&FirstG,ThisG,&Gadget);
//		(*ThisG)->TopEdge = Y = NW->Height - 8 - (*ThisG)->Height;
//		(*ThisG)->LeftEdge = (NW->Width - (*ThisG)->Width)>>1;
//		(*ThisG)->NextGadget = NULL;
//		(*ThisG)->UserData = NULL;
//		Ret = *ThisG;
//	}
//	else return(NULL);
//
//
//#ifndef NO_CUTTING_ROOM
//	if ((Gadget = AllocOneGadget(FindGadget(&Gadget1,ID_REQ_DARK_CANCEL))))
//	{
//		(*ThisG)->NextGadget = Gadget;
//		(*ThisG)= Gadget;
//		(*ThisG)->UserData = NULL;
//		(*ThisG)->LeftEdge = NW->Width - (*ThisG)->Width - 8;
//		(*ThisG)->TopEdge = Y;
//		(*ThisG)->NextGadget = NULL;
//	}
//
//	if ((Gadget = AllocOneGadget(FindGadget(&Gadget1,ID_DARK_CONTINUE))))
//	{
//		(*ThisG)->NextGadget = Gadget;
//		(*ThisG)= Gadget;
//		(*ThisG)->UserData = NULL;
//		(*ThisG)->LeftEdge = 8;
//		(*ThisG)->TopEdge = Y;
//		(*ThisG)->NextGadget = NULL;
//	}
//#endif
//	if(Y1)
//	{
//		Gadget = FindGadget(&Gadget1,ID_REORG);
//		if ((Gadget = AllocOneGadget(Gadget)))
//		{
//			(*ThisG)->NextGadget = Gadget;
//			(*ThisG) = Gadget;
//			(*ThisG)->LeftEdge = (NW->Width - (*ThisG)->Width - (PNL_X1<<1) +2 );
//			(*ThisG)->TopEdge = Y1;
//			(*ThisG)->NextGadget = NULL;
//			(*ThisG)->UserData = NULL;
//		}
//	}

	Gadget = FindGadget(&Gadget1,ID_VCR_PAUSE);
	if ((Gadget = AllocOneGadget(Gadget)))
	{
		Ret = Gadget;			// Return pointer to first extra gadget
		(*ThisG)->NextGadget = Gadget;
		(*ThisG) = Gadget;
		(*ThisG)->Activation |= GACT_TOGGLESELECT;
		(*ThisG)->LeftEdge = (NW->Width>>1)-(4*Gadget->Width) - 8;
		(*ThisG)->TopEdge = Y - 24 - Gadget->Height;
		(*ThisG)->NextGadget = NULL;
		(*ThisG)->UserData = NULL;
	}

	Gadget = FindGadget(&Gadget1,ID_VCR_REC);
	if ((Gadget = AllocOneGadget(Gadget)))
	{
		(*ThisG)->NextGadget = Gadget;
		(*ThisG) = Gadget;
		(*ThisG)->Activation |= GACT_TOGGLESELECT;
		(*ThisG)->LeftEdge = (NW->Width>>1)-(3*Gadget->Width) - 8;
		(*ThisG)->TopEdge = Y - 24 - Gadget->Height;
		(*ThisG)->NextGadget = NULL;
		(*ThisG)->UserData = NULL;
	}

	Gadget = FindGadget(&Gadget1,ID_REQ_STOP);
	if ((Gadget = AllocOneGadget(Gadget)))
	{
		(*ThisG)->NextGadget = Gadget;
		Gadget->LeftEdge = (NW->Width>>1) -(2*((*ThisG)->Width)) - 8;
		Gadget->TopEdge = (*ThisG)->TopEdge;
		Gadget->Activation |= GACT_IMMEDIATE;
		Gadget->NextGadget = NULL;
		Gadget->UserData = NULL;
		(*ThisG) = Gadget;
	}
	return(Ret);
}


UWORD DrawPanel(struct PanelLine *PLine)
{
	UWORD	X1=0,Y=0,Y1,H=PNL_Y1;
	struct Window *win=PLine->Win;
	while (PLine->Type)
	{
		if(PLine->Type != PNL_SKIP)
		{
			if (PPOS_HALF2 & PLine->Align)
				X1 = PNL_WIDTH;

			// Call the gadget's create function
			if(PLine->Draw)		Y1=PLine->Draw(X1,H,PLine,win);

			if(PPOS_WIDER & PLine->Align)
			{
				X1 = PNL_WIDTH;
				Y = Y1;
			}
			else
			{
				if (Y>0)
					H += MAX(Y,Y1);		// Don't forget left half
				else
					H += Y1;					// Was no left half
				X1 = 0;
				Y = 0;
			}
		}
		PLine++;
	}

	return(H);
}


// Set global variables (side effects!!) return 1 for out, 0 for in point
ULONG	SetHiLo(struct PanelLine *PLine)
{
	ULONG	retval,*hi,*lo;

	DUMPMSG("* SetHiLo *");

	if(PLine->Flags&PL_OUT) // Adjusting Out Point
	{
		if (PLine->Flags & PL_SHADOW)
		{
			hi = &PLine->PropEnd;				// Slider max
			lo = &PLine->PropStart;				// Slider min (+ offset)
			PLine->ShadowOffset = *PLine->Param2 - *PLine->Param;		// Difference

			MyRCB->Max = (*hi - PLine->PropStart + (LONG)PLine->G2)<<1;
			MyRCB->Min = (*lo + PLine->ShadowOffset - PLine->PropStart + (LONG)PLine->G2)<<1;
		}
		else
		{
			hi = &PLine->PropEnd;				// Slider max
			lo = PLine->Param;					// In-point knob
			MyRCB->Max = (*hi - PLine->PropStart + (LONG)PLine->G2)<<1;
			MyRCB->Min = (*lo - PLine->PropStart + (LONG)PLine->G2)<<1;
		}

		retval = 1;
	}
	else if(PLine->Flags&PL_IN) // Adjusting In Point
	{
		if (PLine->Flags & PL_SHADOW)
		{
			hi = &PLine->PropEnd;				// Slider max (- offset)
			lo = &PLine->PropStart;				// Slider min
			PLine->ShadowOffset = *PLine->Param2 - *PLine->Param;		// Difference

			MyRCB->Max = (*hi - PLine->ShadowOffset - PLine->PropStart + (LONG)PLine->G2)<<1;
			MyRCB->Min = (*lo - PLine->PropStart + (LONG)PLine->G2)<<1;
		}
		else
		{
			hi = PLine->Param2;					// Out-point knob
			lo = &PLine->PropStart;				// Slider min
			MyRCB->Max = (*hi - PLine->PropStart + (LONG)PLine->G2)<<1;
			MyRCB->Min = (*lo - PLine->PropStart + (LONG)PLine->G2)<<1;
		}
		retval = 0;
	}
	else return(0);


	if(PLine->Flags&PL_AUDIO)
	{
		AHiTime=hi;
		ALoTime=lo;
	}
	else
	{
		HiTime=hi;
		LoTime=lo;
	}

	return(retval);
}



void LegalizeIconSlide(struct CutClipData *ccd)
{
	struct NewClip	*cl;

	if (ccd->FramePL == NULL)		// If no icon slider, do nothing!
		return;

	if(cl=ccd->cl)
	{
		// Update icon's max range from new in/out points
		ccd->FramePL->PropEnd	= cl->out;
		ccd->FramePL->PropStart	= cl->in;
		if(cl->in==cl->out)
		{
			ccd->FramePL->PropEnd += 2;
			cl->icon=cl->in;
		}

		// Clip icon frame # to be within new range
		if (cl->icon < cl->in)
			cl->icon = cl->in;
		if (cl->icon > cl->out)
			cl->icon = cl->out;

		// Change icon's frame number string
		UpdateTime(ccd->Frame,ccd->Window,cl->icon);

		// Move icon slider knob to correct position for updated end points/current frame
		ccd->FramePL->G2 =(struct Gadget *) (ccd->FramePL->PropStart-ccd->Tmin);
		UpdatePanProp(ccd->FramePL,ccd->Window);
	}
}


// Set slider after change in time string, use 0 (LOOKS LIKE THIS IS USED BY NO ONE!)
__inline void UpdateClipSlider(struct ClipDisplay *cd,struct Gadget *Prop,struct Window *Window,ULONG Val)
{
		struct PropInfo *pi= ((struct PropInfo *)Prop->SpecialInfo);
//		Val=(Val*MAXPOT)/(cd->MaxVal - cd->MinVal);
		Val = SafeCalcNewPot(Prop, Val, cd->MinVal, cd->MaxVal);
		NewModifyProp(Prop,Window,NULL,pi->Flags,Val&0xFFFF,pi->VertPot,pi->HorizBody,pi->VertBody,1);
}


//*******************************************************************
// recalculates difference and prints it if changed, returns 0 if props need update
LONG UpdateDiff(struct RastPort *RP,struct PanelLine *PLine,struct Window *Window)
{
	LONG A,X,Y;
	char ch[32];

	A = *(PLine->Param) - *(PLine->Param2);
	if (A < 0)
	{
		A = 0;
		*(PLine->Param) = *(PLine->Param2) ;
	}
	A += (ULONG)PLine->G5;
	if (A != PLine->PropEnd) {
		PLine->PropEnd = A;
		ch[0] = 0;
		LongToTime((ULONG *)&PLine->PropEnd,&ch[strlen(ch)]);

		X=PLine->PropStart>>16;
		Y=PLine->PropStart&0xFFFF;
//Don't need this, using NP font (reduces flashiness, too)
//		SetDrMd(RP,JAM2);
//		SetAPen(RP,SCREEN_PEN);
//		RectFill(RP,X+80,Y,X+96,Y+TEXT_HEIGHT);
		Move(RP,X,Y+TEXT_BASE-1);
		SetFont(RP,TCDarkFont);
		SafeColorText(RP,ch,11);
		SetFont(RP,DarkFont);
	}
	return(A);
}

//*******************************************************************
// checks all PNL_DIFF PLines for change
VOID UpdateAllDiff(struct RastPort *RP,struct PanelLine *PLine,struct Window *Window)
{
	LONG FixProp=1;
	if(PLine==NULL) PLine=Start;
	while(PLine && PLine->Type)
	{
		if (PLine->Type == PNL_DIFF)
			FixProp *= UpdateDiff(RP,PLine,Window);
		else if ( (FixProp==0) && (PLine->Type==PNL_TIME) )
		{
			DUMPMSG("UpdateAllDiff");
			UpdatePanProp(PLine,Window);
			UpdatePanStr(PLine,Window);
		}
		PLine++;
	}
}

//*******************************************************************
// checks all PNL_FXTIME PLines for change
VOID UpdateFXTime(struct RastPort *RP,struct PanelLine *PLine,LONG t,struct Window *Window)
{
	if(t)
	{
		while (PLine->Type)
		{
			if (PLine->Type == PNL_FXTIME)
			{
				*PLine->Param=t;
				*PLine->Param2=0;
				UpdateDiff(RP,PLine,Window);
			}
			PLine++;
		}
	}
}

// Set FXSpeed button ot given SMFV, return framecount
LONG UpdateFXSpeed(struct PanelLine *PLine,LONG t,struct Window *Window)
{
	struct Gadget **PPGadg;
	struct PanelLine *temp;
	UWORD	A;

	if( (PLine->Type == PNL_FXSPEED) && PLine->Param2[t] )
	{
		*PLine->Param=t;
		PPGadg = &PLine->G1;
		for (A=0;A<4;A++)
		{
			if (*PPGadg)
			{
				if(A!=t)	(*PPGadg++)->Flags &= (~GFLG_SELECTED);
				else (*PPGadg++)->Flags |= GFLG_SELECTED;
			}
		}
		if( (t==3) && (temp=(struct PanelLine *)PLine->PropStart))
			PLine->Param2[3]=*(temp->Param);
		RefreshGList(PLine->G1,Window,0,4);
		return(PLine->Param2[t]); // value to set time to
	}
	return(0);
}


ULONG CalcFrac32(LONG value, LONG max)
{
	if (value == max)
		return(0xFFFFFFFF);

	return( ((( (ULONG)value)<<16)/(ULONG)max) <<16 );
}

//*******************************************************************
VOID UpdateFracTime(struct PanelLine *PLine,struct Window *Window,ULONG newmax)
{
	ULONG	frac;

	frac = (ULONG) *PLine->Param2;

	DUMPHEXIL("UpdateFracTime (frac32=",frac,")\\");
	// Using current (hidden) frac32, calc field out of new max field range
	*PLine->Param = (((frac>>16) * newmax + 0x8000) >>16);
	PLine->PropEnd = newmax;			// Keep new max value
	UpdatePanStr(PLine,Window);
}


//*******************************************************************
// goes from *(PLine->Param) to StrGadg
//#define ENDFUDGE	12
VOID UpdatePanStr(struct PanelLine *PLine,struct Window *Window)
{
	struct Gadget *ThisG, *ThatG;
	LONG A,B,I;

	if( !(ThisG=PLine->StrGadg) ) return;
	A = RemoveGadget(Window,ThisG);
	switch(PLine->Type)
	{
		case PNL_TIME:		
		case PNL_EZTIME:
			I = *PLine->Param;
			*PLine->Param = ((I/2)*2);
			LongToTime((ULONG *)PLine->Param,((struct StringInfo *)ThisG->SpecialInfo)->Buffer);
			break;
		case PNL_DUOSLIDE:
			LongToTime((ULONG *)PLine->Param,((struct StringInfo *)ThisG->SpecialInfo)->Buffer);
			if (ThatG=PLine->G4)
			{
				B = RemoveGadget(Window,ThatG);
				LongToTime((ULONG *)PLine->Param2,((struct StringInfo *)ThatG->SpecialInfo)->Buffer);
				AddGadget(Window,ThatG,B);
				// Refresh!???
			}
			break;
		case PNL_EZLEN:
			LongToLen((ULONG *)PLine->Param,((struct StringInfo *)ThisG->SpecialInfo)->Buffer);
			break;
		case PNL_EZNUM:
		case PNL_NUMSLIDER:
			stcl_d( ((struct StringInfo *)ThisG->SpecialInfo)->Buffer,*PLine->Param);
			break;
	}
	AddGadget(Window,ThisG,A);
	RefreshGList(ThisG,Window,NULL,1);
}

//*******************************************************************
// goes from prop position to *(PLine->Param)
VOID UpdateParam(struct PanelLine *PLine,struct Window *Window)
{
	LONG A;

	A = PLine->PropEnd-PLine->PropStart;
	A = (((struct PropInfo *)PLine->PropGadg->SpecialInfo)->HorizPot * A)
		 / MAXPOT;
	A += PLine->PropStart;
	*(PLine->Param) = A;
	UpdatePanStr(PLine,Window);
	DUMPMSG("UpdateParam");
}

//*******************************************************************
// goes from *(PLine->Param) to prop position between PropStart/PropEnd
VOID UpdatePanProp(struct PanelLine *PLine,struct Window *Window)
{
	LONG A=0;

	if (PLine->Param)
		A = *(PLine->Param);
	else
		return;

	DUMPUDECL("UPP:(",A,")");

	if (PLine->PropEnd == PLine->PropStart)
		return;

	if (PLine->PropGadg)
	{
		struct PropInfo *pi= ((struct PropInfo *)PLine->PropGadg->SpecialInfo);

		if (A > PLine->PropEnd)
			A = PLine->PropEnd;
		else if (A < PLine->PropStart)
			A = PLine->PropStart;

		if( (A!=*(PLine->Param)) )  // If bounds exceeded
		{
			*(PLine->Param)=A;
			UpdatePanStr(PLine,Window);
		}

		DUMPUDECL("--",A,"");
		DUMPUDECL(",",(LONG)PLine->G2,"");
		DUMPUDECL(",",PLine->PropStart,"");
		DUMPUDECL(",",PLine->PropEnd,"");

//		A -= PLine->PropStart;
//		A += (LONG)PLine->G2;
//		A=(A*MAXPOT)/(PLine->PropEnd - PLine->PropStart);

// This would cause G2<>0 to force knob to the wrong position, needed PropStart to balance correctly
//		A = SafeCalcNewPot(PLine->PropGadg, A+(LONG)PLine->G2, PLine->PropStart, PLine->PropEnd);
		A = SafeCalcNewPot(PLine->PropGadg, A-PLine->PropStart+(LONG)PLine->G2, PLine->PropStart, PLine->PropEnd);

		DUMPHEXIW("---->Pot ",A,"\\");

		NewModifyProp(PLine->PropGadg,Window,NULL,
				pi->Flags,A&0xFFFF,pi->VertPot,pi->HorizBody,pi->VertBody,1);
	}

	if (PLine->Param2)
		A = *(PLine->Param2);
	else
		return;

	if( (PLine->Type==PNL_DUOSLIDE) )
	{
		if(PLine->G5)
		{
			struct PropInfo *pi= ((struct PropInfo *)PLine->G5->SpecialInfo);

			if (A > PLine->PropEnd)
				A = PLine->PropEnd;
			else if (A < *PLine->Param)
				A = *PLine->Param+2;

			if( (A!=*(PLine->Param2)) )  // If bounds exceeded
			{
				*(PLine->Param2)=A;
				UpdatePanStr(PLine,Window);
			}
//			A -= PLine->PropStart;
//			A += (LONG)PLine->G2;
//			A=(A*MAXPOT)/(PLine->PropEnd - PLine->PropStart);
			A = SafeCalcNewPot(PLine->G5, A+(LONG)PLine->G2, PLine->PropStart, PLine->PropEnd);
			NewModifyProp(PLine->G5,Window,NULL,
					pi->Flags,A&0xFFFF,pi->VertPot,pi->HorizBody,pi->VertBody,1);
		}
	}
}



void RenderSlide(
	struct RenderCallBack *Call,
	long *frame,
	struct Gadget *pgad,
	struct Gadget *sgad )
{
	struct PanelLine *PLine;
	struct PropInfo *pi;
	ULONG	A;
//	ULONG scaled_ps,scaled_pe,scaled_fr;
	UWORD Val;

#ifdef SERDEBUG
	sprintf(pstr,"RS: Frame=%lx\n",*frame);
	DUMPSTR(pstr);
#endif

	if( (!Call) || (!(PLine = Call->pline)))
		return;

	if(pgad)
	{
		pi= ((struct PropInfo *)pgad->SpecialInfo);
//		A=((*frame-PLine->PropStart - (LONG)PLine->G2)*MAXPOT)/(PLine->PropEnd - PLine->PropStart);
//		A=((*frame-PLine->PropStart)*MAXPOT)/(PLine->PropEnd - PLine->PropStart);

//		/* Scale all frame numbers down so that 16 bit math will not break */
//		scaled_ps = PLine->PropStart;
//		scaled_pe = PLine->PropEnd;
//		scaled_fr = (ULONG)*frame;
//		while ((scaled_pe - scaled_ps) > 0xFFFF)
//		{
//			scaled_ps >>= 1;
//			scaled_pe >>= 1;
//			scaled_fr >>= 1;
//		}
//
//		A=((scaled_fr-scaled_ps)*MAXPOT)/(scaled_pe - scaled_ps);
//		Val = A&0xFFFF;
		Val = SafeCalcNewPot(pgad, (ULONG)*frame, PLine->PropStart, PLine->PropEnd);

#ifdef SERDEBUG
//	sprintf(pstr,"RS: NewPot=%lx\n",Val);
//	DUMPSTR(pstr);
#endif

		if((Call->Flags&DHD_MOUSE_UPDATE))
		{
			A=Val* (pgad->Width - ((struct Image *)pgad->GadgetRender)->Width);
			A = (A/MAXPOT) + pgad->LeftEdge + Call->win->LeftEdge;
			Call->MouseX = (A&0xFFFF) + (((struct Image *)pgad->GadgetRender)->Width>>1);
		}
		NewModifyProp(pgad,Call->win,NULL,pi->Flags,Val,pi->VertPot,pi->HorizBody,pi->VertBody,1);
	}

	if(sgad)
	{
		A = RemoveGadget(Call->win,sgad);
		LongToTime((ULONG *)frame,((struct StringInfo *)sgad->SpecialInfo)->Buffer);
		AddGadget(Call->win,sgad,A);
		RefreshGList(sgad,Call->win,NULL,1);
	}
}

/* ***************  from Panel.h

struct RenderCallBack {
	void __asm (*RenderFn)(register __a0 APTR);
	struct FastGadget *FG;
	ULONG	Frame;  // Starting at 0, not SMPTE
	ULONG	Min;
	ULONG	Max;
	ULONG	Flags;
	struct Window *win;
	struct PanelLine *pline;
	WORD	MouseY;		//initially same as sc_MouseY
	WORD	MouseX;		//initially same as sc_MouseX
	WORD	VelocityNumerator;
	UWORD	VelocityDenominator;
};

************** */


//*******************************************************************
//      Render call-back utilities
//*******************************************************************

void __saveds __asm RenderFunc(REG(a0) struct RenderCallBack *Call)
{
	struct PanelLine *PLine,*PartPL;
	if(!Call) return;

	if(PLine = Call->pline)
	{
#ifdef SERDEBUG
		sprintf(pstr,"RCB: Frame=%x   Min=%d   Max=%d\n",MyRCB->Frame,MyRCB->Min,MyRCB->Max);
		DUMPSTR(pstr);
		sprintf(pstr,"PLine: Param=%d   PropStart=%d   PropEnd=%d   G2=%d\n",*PLine->Param,PLine->PropStart,PLine->PropEnd,(LONG)PLine->G2);
		DUMPSTR(pstr);
#endif

		if( (PLine->Type==PNL_DUOSLIDE) && (PLine->Flags&PL_OUT) )
		{
			*PLine->Param2 = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart - (LONG)PLine->G2); // even frame #s
//			*PLine->Param2 = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart ); // even frame #s
			if (PLine->Flags & PL_SHADOW)
			{
				// Calc/render shadowed in-point based on out-point
				*PLine->Param = *PLine->Param2 - PLine->ShadowOffset;
				RenderSlide(Call,PLine->Param,PLine->PropGadg,PLine->StrGadg);
			}
			RenderSlide(Call,PLine->Param2,PLine->G5,PLine->G4);
		}
		else
		{
			*PLine->Param = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart - (LONG)PLine->G2); // even frame #s
//			*PLine->Param = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart ); // even frame #s
			if( (PLine->Type==PNL_DUOSLIDE) && (PLine->Flags & PL_SHADOW) )
			{
				// Calc/render shadowed out-point based on in-point
				*PLine->Param2 = *PLine->Param + PLine->ShadowOffset;
				RenderSlide(Call,PLine->Param2,PLine->G5,PLine->G4);
			}
			RenderSlide(Call,PLine->Param,PLine->PropGadg,PLine->StrGadg);
		}

		if( (PLine->Flags&PL_PARTNER) && (PartPL=PLine->Partners) )
		{
			Call->pline = PartPL;
			if( (PartPL->Type==PNL_DUOSLIDE) && (PartPL->Flags&PL_OUT) )
			{
//				*PartPL->Param2 = EVEN(1+(Call->Frame>>1)); // even frame #s
				*PartPL->Param2 = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart - (LONG)PLine->G2); // even frame #s
				if (PLine->Flags & PL_SHADOW)
				{
					// Calc/render shadowed in-point based on out-point
					*PartPL->Param = *PartPL->Param2 - PLine->ShadowOffset;
					RenderSlide(Call,PartPL->Param,PartPL->PropGadg,PartPL->StrGadg);
				}
				RenderSlide(Call,PartPL->Param2,PartPL->G5,PartPL->G4);
			}
			else
			{
				*PartPL->Param = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart - (LONG)PLine->G2); // even frame #s
//				*PartPL->Param = EVEN(1+(Call->Frame>>1)); // even frame #s
				if( (PartPL->Type==PNL_DUOSLIDE) && (PLine->Flags & PL_SHADOW) )
				{
					// Calc/render shadowed out-point based on in-point
					*PartPL->Param2 = *PartPL->Param + PLine->ShadowOffset;
					RenderSlide(Call,PartPL->Param2,PartPL->G5,PartPL->G4);
				}
				RenderSlide(Call,PartPL->Param,PartPL->PropGadg,PartPL->StrGadg);
			}
			Call->pline = PLine;
		}

		UpdateAllDiff(Call->win->RPort,NULL,Call->win);
	}
}


void __saveds __asm QuickRenderFunc(REG(a0) struct RenderCallBack *Call)
{
	struct PanelLine *PLine,*PartPL;
	int	which;
	LONG	value;

	if(!Call) return;

	if(PLine = Call->pline)
	{
#ifdef SERDEBUG
		sprintf(pstr,"QRCB: Frame=%x   Min=%d   Max=%d\n",MyRCB->Frame,MyRCB->Min,MyRCB->Max);
		DUMPSTR(pstr);
		sprintf(pstr,"PLine: Param=%d   PropStart=%d   PropEnd=%d   G2=%d\n",*PLine->Param,PLine->PropStart,PLine->PropEnd,(LONG)PLine->G2);
		DUMPSTR(pstr);
#endif

		which = 0;
		if (Call->Flags & DHD_AUDIOSLIDER)
			which += 2;
		if (Call->Flags & DHD_OUTPOINT)
			which ++;

		*PLine->Param = EVEN( (1+(Call->Frame>>1)) + PLine->PropStart - (LONG)PLine->G2); // even frame #s
		DispQuickTime(PLine->Win,which,*PLine->Param,NULL,TRUE);

		if ((PLine->Flags&PL_PARTNER) && (PartPL=PLine->Partners))
		{
			*PartPL->Param = *PLine->Param;			// Snap to other partner
			DispQuickTime(PartPL->Win,which^2,*PartPL->Param,NULL,FALSE);
		}

		if ((PLine->Flags&PL_SHADOW) && (PartPL=(struct PanelLine *)PLine->Param2))
		{
			if (PLine->Flags & PL_IN)
				value = *PLine->Param + PLine->ShadowOffset;		// Constant from inpoint
			else
				value = *PLine->Param - PLine->ShadowOffset;		// Constant from outpoint

			*PartPL->Param = value;				// Maintain duration
			DispQuickTime(PartPL->Win,which^1,*PartPL->Param,NULL,FALSE);

			if ((PLine->Flags&PL_PARTNER) && (PartPL=PartPL->Partners))
			{
				*PartPL->Param = value;				// Maintain duration
				DispQuickTime(PartPL->Win,which^3,*PartPL->Param,NULL,FALSE);
			}
		}
	}
}


//*******************************************************************
//      Panel Specific Popup f'ns .. use global CurPLine
//*******************************************************************

// AAR -- frzl
char *NameFn(void *frzl, int Entries)
{
	char **PopUpNames=(char **)(CurPLine->Param);
	if (Entries < 0) Entries = 0;
	else if (Entries > ((CurPLine->PropEnd)-1)) Entries = (CurPLine->PropEnd)-1;
	return(PopUpNames[Entries]);
}

VOID RedrawPopText(struct Window *Window)
{
	char *C;
	struct Gadget *Gadget;

	if (Gadget = CurPLine->G1 ) {
		C = NameFn(NULL,( (int)CurPLine->PropStart ));
		SetFont(Window->RPort,EditFont);
		AnyPopupText(Gadget,C,Window,20);
	}
}

VOID HandlePopUp(struct Window *Window,struct IntuiMessage *IntuiMsg, struct PanelLine *PLine)
{
	PopUpID ID;
	struct Gadget *Gadget;
	WORD A,X,Y;

	CurPLine=PLine;
	PUCDefaultRender(&PopUp);
	PopUp.drawBG = (DrawBGFunc *)DrawBG;
	Gadget = CurPLine->G1;
	X = Gadget->LeftEdge + (Gadget->Width >> 1);
	Y = Gadget->TopEdge + (Gadget->Height >> 1);
	ID = PUCCreate((NameFunc *)NameFn,NULL,&PopUp);
	PUCSetNumItems(ID,CurPLine->PropEnd);
	PUCSetCurItem(ID,CurPLine->PropStart);

	Window->Flags |= WFLG_REPORTMOUSE;
	A = PUCActivate(ID,Window,X,Y,IntuiMsg->MouseX,IntuiMsg->MouseY);
	Window->Flags &= ~WFLG_REPORTMOUSE;
	PUCDestroy(ID);
	if (A >= 0)
	{
		if (A != ( (int)CurPLine->PropStart ))
		{
			CurPLine->PropStart = A;
		}
		RedrawPopText(Window);
	}
}

//*******************************************************************
//		Functions to assist with Cutting/Processing panels
//		First, name string checks
//*******************************************************************

static char *mes[3] = {"File already exists"," Please enter new name for"};
BOOL GetNewName(struct Window *win,char *name, char *PathPre)
{
	BPTR L;
	strncpy(ClipName,PathPre,CLIP_PATH_MAX);
	strncat(ClipName,name,CLIP_PATH_MAX);
	while((L=Lock(ClipName,ACCESS_READ)))
	{
		UnLock(L);
		if(SimpleRequest(win,mes,2,REQ_STRING|REQ_CENTER|REQ_H_CENTER|REQ_OK_CANCEL,name))
		{
			strncpy(ClipName,PathPre,CLIP_PATH_MAX);
			strncat(ClipName,name,CLIP_PATH_MAX);
		}
		else return(FALSE);
	}
	return(TRUE);
}


int ClipDisplayNameCheck(struct ClipDisplay	*cd,char *PathPre, struct Window *win)
{
	struct NewClip	*cl,*cl2,*ncl,*ncl2;
	char *MPtr[3];

	// First check to see that new sub-clip names do not exist on the drive already
	cl=(struct NewClip *)cd->Clips.mlh_Head;
	while(cl && (ncl=(struct NewClip *)cl->Node.mln_Succ) )
	{
		if(!GetNewName(win,cl->Name,PathPre))
			return(0);		// "Cancel"
		cl=ncl;
	}

	// Now check for duplicates in the name list
	cl=(struct NewClip *)cd->Clips.mlh_Head;
	while(cl && (ncl=(struct NewClip *)cl->Node.mln_Succ) )
	{
		cl2=ncl;
		while(cl2 && (ncl2=(struct NewClip *)cl2->Node.mln_Succ) )
		{
			if(stricmp(cl->Name,cl2->Name)==0)			// Found a duplication?
			{
				sprintf(pstr,"New clip name %s",cl->Name);
				MPtr[0] = pstr;
				MPtr[1] = "used more than once.  Fix and try again";
				SimpleRequest(win,MPtr,2,REQ_CENTER|REQ_H_CENTER,NULL);
				return(-1);		// "ReOpen"
			}

			cl2=ncl2;
		}
		cl=ncl;
	}

	return(1);		// "Okay"
}


//===================================================================================
// RemoveClipsDone
//		Deletes any clip definitions that seem to have been made already
//===================================================================================
void RemoveClipsDone(struct ClipDisplay *cd,char *PathPre, struct Window *win)
{
	struct NewClip	*cl,*ncl;
	BPTR L;

	DUMPMSG("RCD called");

	cl=(struct NewClip *)cd->Clips.mlh_Head;
	while (cl && (ncl=(struct NewClip *)cl->Node.mln_Succ) )
	{
		strncpy(ClipName,PathPre,CLIP_PATH_MAX);
		strncat(ClipName,cl->Name,CLIP_PATH_MAX);
		DUMPSTR(ClipName);
		DUMPSTR(" -- ");

		if (L=Lock(ClipName,ACCESS_READ))
		{
			UnLock(L);
			DUMPMSG(" must have been successful");

			KillClip(cd,cl);
		}
		else
			DUMPMSG(" missing");

		cl=ncl;
	}
}


//*******************************************************************
//		Functions to assist with Cutting/Processing panels
//		Specifically, ones that use CutClipData structure
//*******************************************************************

void NextActiveClip(struct CutClipData *ccd)
{
	struct NewClip	*ncl;

	// Find next sub-clip
	ncl = (struct NewClip *)ccd->cl->Node.mln_Succ;

	// If hit end of list, go back to beginning
	if ((ncl==NULL) || (ncl->Node.mln_Succ==NULL))
		ncl = (struct NewClip *)ccd->ClipDisp->Clips.mlh_Head;

	if (ncl)
		ChangeActiveClip(ccd,ncl);				// Highlight next
}

void PrevActiveClip(struct CutClipData *ccd)
{
	struct NewClip	*ncl;

	// Find prev sub-clip
	ncl = (struct NewClip *)ccd->cl->Node.mln_Pred;

	// If hit front of list, go to end
	if ((ncl==NULL) || (ncl->Node.mln_Pred==NULL))
		ncl = (struct NewClip *)ccd->ClipDisp->Clips.mlh_TailPred;

	if (ncl)
		ChangeActiveClip(ccd,ncl);				// Highlight prev
}


void ChangeActiveClip(struct CutClipData *ccd, struct NewClip *newcl)
{
	struct NewClip *cl,*oldcl;
	WORD	order;
	BOOL	goingrvs;

	if (newcl == ccd->cl)			// Do nothing if to me again
		return;

	oldcl = cl = ccd->cl;

	cl->type=CLIP_LOCKED;
	newcl->type=CLIP_ACTIVE;
	ccd->cl = cl= newcl;
	InOrOut=1;

	DUMPUDECL("Clip: ",(LONG)cl," \\  ");
	DUMPUDECL("In: ",(LONG)cl->in,"  ");
	DUMPUDECL("Out: ",(LONG)cl->out,"  ");

	DrawClipDisplay(ccd->ClipDisp);			// Draw all clips in the bar

	// Point Length and In/Out stuff at new clip
	ccd->LenPL->Param2	= ccd->TimePL->Param		= &cl->in;
	ccd->LenPL->Param		= ccd->TimePL->Param2	= &cl->out;
	DUMPUDECL("In: ",(LONG)*(ccd->TimePL->Param),"  ");
	DUMPUDECL("Out: ",(LONG)*(ccd->TimePL->Param2),"\\");
//	TimePL->PropStart = Tmin;
//	TimePL->PropEnd =  Tmax;
//	TimePL->G2 =0;

//	if( (ncl=(struct NewClip *)cl->Node.mln_Pred) && ncl->Node.mln_Pred )
//	{
//		DUMPSTR("Previous ");
//		DumpClip(ncl);
////		TimePL->PropStart = ncl->out;
////		TimePL->G2 =(struct Gadget *) (ncl->out-Tmin);
//	}
//	if( (ncl=(struct NewClip *)cl->Node.mln_Succ) && ncl->Node.mln_Succ )
//	{
//		DUMPSTR("Next ");
//		DumpClip(ncl);
////		TimePL->PropEnd = ncl->in;
//	}

	UpdateAllDiff(ccd->RP,Start,ccd->Window);

	HiTime=&ccd->TimePL->PropEnd;
	LoTime=&ccd->TimePL->PropStart;
	MyRCB->Max = (*HiTime - ccd->Tmin)<<1;			// Converting frms to flds?
	MyRCB->Min = (*LoTime - ccd->Tmin)<<1;			// ditto?
	MyRCB->pline = ccd->TimePL;
	DUMPUDECL("Param ",*ccd->TimePL->Param,"	");
	DUMPUDECL("Start ",ccd->TimePL->PropStart,"	");
	DUMPUDECL("End ",ccd->TimePL->PropEnd,"\\");
	DUMPUDECL("Limits ",*LoTime,",	");
	DUMPUDECL(" to ",*HiTime,"\\");


// We need to move each knob on the duoslide to a new location.  To prevent the first
// one we move from clobbering the 2nd (and then leaving a pot-hole when the 2nd is
// moved), we must update them in the proper order.  We determine this by comparing
// the old/new in-points.

	goingrvs = (newcl->in < oldcl->in);
	if (!goingrvs)
	{
		MyRCB->Frame = (ULONG)(*ccd->TimePL->Param2 - ccd->TimePL->PropStart)<<1;
		ccd->TimePL->Flags |= PL_OUT;
		ccd->TimePL->Flags &= ~PL_IN;
		DHD_JustJump(MyRCB);				// Re-render out-point knob
	}
	MyRCB->Frame = (ULONG)(*ccd->TimePL->Param - ccd->TimePL->PropStart)<<1;
	ccd->TimePL->Flags &= ~PL_OUT;
	ccd->TimePL->Flags |= PL_IN;
	DHD_Jump(MyRCB,TRUE);				// Re-render in-point knob + program out (go quiet)

	if (goingrvs)
	{
		MyRCB->Frame = (ULONG)(*ccd->TimePL->Param2 - ccd->TimePL->PropStart)<<1;
		ccd->TimePL->Flags |= PL_OUT;
		ccd->TimePL->Flags &= ~PL_IN;
		DHD_JustJump(MyRCB);				// Re-render out-point knob
	}

	if (ccd->FramePL)		// Do this stuff only if there is an icon slider
	{
		UpdateTime(ccd->Frame,ccd->Window,cl->icon);
		ccd->FramePL->Param = &cl->icon;
		ccd->FramePL->PropStart = cl->in;
		ccd->FramePL->PropEnd = cl->out;
		if(cl->in==cl->out)
		{
			ccd->FramePL->PropEnd += 2;
			cl->icon=cl->in;
		}
		ccd->FramePL->G2 =(struct Gadget *) (ccd->FramePL->PropStart - ccd->Tmin);
		UpdatePanProp(ccd->FramePL,ccd->Window);
	}

	order = RemoveGadget(ccd->Window,ccd->String);
	strncpy(((struct StringInfo *)ccd->String->SpecialInfo)->Buffer,cl->Name,CLIP_NAME_MAX-1);
	ccd->StrPL->Param = (LONG *) cl->Name;
	AddGadget(ccd->Window,ccd->String,order);
	RefreshGList(ccd->String,ccd->Window,NULL,1);

	order = RemoveGadget(ccd->Window,ccd->CommPL->StrGadg);
	strncpy(((struct StringInfo *)ccd->CommPL->StrGadg->SpecialInfo)->Buffer,cl->Comment,COMMENT_MAX-1);
	ccd->CommPL->Param = (LONG *) cl->Comment;
	AddGadget(ccd->Window,ccd->CommPL->StrGadg,order);
	RefreshGList(ccd->CommPL->StrGadg,ccd->Window,NULL,1);
}


// GEEZ, THIS HAS GOT A LOT OF REDUNDANT CODE w/ FUNCTION "CHANGEACTIVECLIP()"
// HAVE ONE USE THE OTHER SOON!!!
void RemoveActiveClip(struct CutClipData *ccd)
{
	WORD	order;
	ULONG	oldinpt;
	struct NewClip	*ncl;
	BOOL	goingrvs;

	if(ccd->cl)
	{
		if( ((ncl=(struct NewClip *)ccd->cl->Node.mln_Pred) && ncl->Node.mln_Pred)
		|| ((ncl=(struct NewClip *)ccd->cl->Node.mln_Succ) && ncl->Node.mln_Succ) )
		{
			oldinpt = ccd->cl->in;			// Will need this for later rendering test

			if (ccd->cl=KillClip(ccd->ClipDisp,ccd->cl))
				ccd->cl->type=CLIP_ACTIVE;

//Don't ever back clipnum down, since we can't guarantee we deleted the highest #'d one.
//Could cause duplicate temp clip names!
//			ccd->clipnum--;

			DrawClipDisplay(ccd->ClipDisp);
			if(ccd->cl)
			{
				// Point Length and In/Out stuff at new clip
				ccd->LenPL->Param2	= ccd->TimePL->Param		= &ccd->cl->in;
				ccd->LenPL->Param		= ccd->TimePL->Param2	= &ccd->cl->out;
				ccd->TimePL->PropStart = ccd->Tmin;
				ccd->TimePL->PropEnd =  ccd->Tmax;
				ccd->TimePL->G2 =0;

//				if( (ncl=(struct NewClip *)ccd->cl->Node.mln_Pred) && ncl->Node.mln_Pred )
//				{
//					DUMPSTR("Previous ");
//					DumpClip(ncl);
////					ccd->TimePL->PropStart = ncl->out;
////					ccd->TimePL->G2 =(struct Gadget *) (ncl->out-ccd->Tmin);
//				}
//				if( (ncl=(struct NewClip *)ccd->cl->Node.mln_Succ) && ncl->Node.mln_Succ )
//				{
//					DUMPSTR("Next ");
//					DumpClip(ncl);
////					ccd->TimePL->PropEnd = ncl->in;
//				}

				UpdateAllDiff(ccd->RP,Start,ccd->Window);

				HiTime=&ccd->TimePL->PropEnd;
				LoTime=&ccd->TimePL->PropStart;
				MyRCB->Max = (*HiTime - ccd->Tmin)<<1;
				MyRCB->Min = (*LoTime - ccd->Tmin)<<1;
				MyRCB->pline = ccd->TimePL;
				DUMPUDECL("Param ",*ccd->TimePL->Param,"	");
				DUMPUDECL("Start ",ccd->TimePL->PropStart,"	");
				DUMPUDECL("End ",ccd->TimePL->PropEnd,"\\");
				DUMPUDECL("Limits ",*LoTime,",	");
				DUMPUDECL(" to ",*HiTime,"\\");

// We need to move each knob on the duoslide to a new location.  To prevent the first
// one we move from clobbering the 2nd (and then leaving a pot-hole when the 2nd is
// moved), we must update them in the proper order.  We determine this by comparing
// the old/new in-points.

				goingrvs = (ccd->cl->in < oldinpt);
				if (!goingrvs)
				{
					MyRCB->Frame = (ULONG)(*ccd->TimePL->Param2 - ccd->Tmin)<<1;
					ccd->TimePL->Flags |= PL_OUT;
					ccd->TimePL->Flags &= ~PL_IN;
					DHD_JustJump(MyRCB);		// Render out-point knob
				}

				MyRCB->Frame = (ULONG)(*ccd->TimePL->Param - ccd->Tmin)<<1;
				ccd->TimePL->Flags &= ~PL_OUT;
				ccd->TimePL->Flags |= PL_IN;
				DHD_JustJump(MyRCB);			// Render in-point knob

				if (goingrvs)
				{
					MyRCB->Frame = (ULONG)(*ccd->TimePL->Param2 - ccd->Tmin)<<1;
					ccd->TimePL->Flags |= PL_OUT;
					ccd->TimePL->Flags &= ~PL_IN;
					DHD_JustJump(MyRCB);		// Render out-point knob
				}

				if (ccd->FramePL)		// Do this stuff only if there is an icon slider
				{
					UpdateTime(ccd->Frame,ccd->Window,ccd->cl->icon);
					ccd->FramePL->Param = &ccd->cl->icon;
					ccd->FramePL->PropStart = ccd->cl->in;
					ccd->FramePL->PropEnd = ccd->cl->out;
					if(ccd->cl->in==ccd->cl->out)
					{
						ccd->FramePL->PropEnd += 2;
						ccd->cl->icon=ccd->cl->in;
					}
					ccd->FramePL->G2 =(struct Gadget *) (ccd->FramePL->PropStart-ccd->Tmin);
					UpdatePanProp(ccd->FramePL,ccd->Window);
				}

				order = RemoveGadget(ccd->Window,ccd->String);
				strncpy(((struct StringInfo *)ccd->String->SpecialInfo)->Buffer,ccd->cl->Name,CLIP_NAME_MAX-1);
				ccd->StrPL->Param = (LONG *) ccd->cl->Name;
				AddGadget(ccd->Window,ccd->String,order);
				RefreshGList(ccd->String,ccd->Window,NULL,1);

				order = RemoveGadget(ccd->Window,ccd->CommPL->StrGadg);
				strncpy(((struct StringInfo *)ccd->CommPL->StrGadg->SpecialInfo)->Buffer,ccd->cl->Comment,COMMENT_MAX-1);
				ccd->CommPL->Param = (LONG *) ccd->cl->Comment;
				AddGadget(ccd->Window,ccd->CommPL->StrGadg,order);
				RefreshGList(ccd->CommPL->StrGadg,ccd->Window,NULL,1);
			}
		}
	}
}


//*******************************************************************
//		Functions to assist with Cutting/Processing panels
//		Flyer downloading functions
//*******************************************************************

ULONG CutClipDownload(struct ClipDisplay	*cd,char *PathPre,ULONG Flags)
{
	ULONG	error = FERR_OKAY;
	char *MPtr[3],Line3[32];

	struct NewClip	*cl,*ncl;
	cl=(struct NewClip *)cd->Clips.mlh_Head;
	DisplayWaitSprite();

	while(cl && (ncl=(struct NewClip *)cl->Node.mln_Succ) )
	{
		cl->in -= cd->MinVal;
		if(cl->out>cd->MaxVal) cl->out=cd->MaxVal;
		cl->out -= cd->MinVal;
		error = DHD_AddClip(cl,PathPre,Flags);
		if (error != FERR_OKAY)
		{
			DisplayNormalSprite();

			MPtr[0] = "Unable to cut clip";
			strncpy(pstr,cl->Name,100);
			MPtr[1] = pstr;
			sprintf(Line3,"Internal error %d",error);
			MPtr[2] = Line3;

			// Put up internal error requester, check proceed or cancel
			if ((BOOL)SimpleRequest(EditTop->Window,MPtr,3,
			REQ_OK_CANCEL | REQ_CENTER | REQ_H_CENTER,NULL))
			{
				error = FERR_OKAY;			// User chose to ignore
				DisplayWaitSprite();
			}
			else
				break;							// User cancelled
		}
//		cl->in -= cd->MinVal;
//		cl->out -= cd->MinVal;
		cl=ncl;
	}
	DisplayNormalSprite();

	return(error);
}


void ClipDisplayIcons(struct ClipDisplay	*cd,char *PathPre)
{
	struct NewClip	*cl,*ncl;
	cl=(struct NewClip *)cd->Clips.mlh_Head;
	DisplayWaitSprite();
	while(cl && (ncl=(struct NewClip *)cl->Node.mln_Succ) )
	{
		cl->in -= cd->MinVal;
		if(cl->out>cd->MaxVal) cl->out=cd->MaxVal;
		cl->out -= cd->MinVal;
		if(cl->icon>cd->MaxVal) cl->icon=cd->MaxVal;
		cl->icon -= cd->MinVal;
		DHD_ClipIcon(cl,PathPre);
//		cl->in -= cd->MinVal;
//		cl->out -= cd->MinVal;
//		cl->icon -= cd->MinVal;
		cl=ncl;
	}
	DisplayNormalSprite();
}


struct ClipDisplay *InitClipDisplay(int x,int y,int w,int h,int min,int max, struct Window *Win)
{
	struct ClipDisplay	*cd;
	if(cd=SafeAllocMem(sizeof(struct ClipDisplay),MEMF_CLEAR) )
	{
		cd->X=x+2; //+Win->LeftEdge;
		cd->Y=y+2; //+Win->TopEdge;
		cd->W=w-4;
		cd->H=h-4;
		cd->MinVal=min;
		if((cd->MaxVal=max) && (max>min) ) // max =0 for un-initialized display
			cd->Scale=(cd->W*0xFFFF)/(max-min) ;  // Fixed Point Fraction...
		NewList((struct List *)&(cd->Clips));
		cd->RP = Win->RPort;
	}
	return(cd);
}

void FreeClipDisplay(struct ClipDisplay	*cd)
{
	struct NewClip	*cl,*ncl;
	cl=(struct NewClip *)cd->Clips.mlh_Head;
	while(ncl=(struct NewClip *)cl->Node.mln_Succ)
	{
		Remove((struct Node *)cl);
		FreeMem(cl,sizeof(struct NewClip)+CLIP_NAME_MAX+COMMENT_MAX+1);
		cl=ncl;
	}
	FreeMem(cd,sizeof(struct ClipDisplay));
}

struct NewClip	*GetClip(struct ClipDisplay	*cd,int val)
{
	struct NewClip	*cl,	*ret=NULL;
	if( (val<=cd->MaxVal) && (val>=cd->MinVal) )
	{
		cl=(struct NewClip *)cd->Clips.mlh_Head;
		while(cl->Node.mln_Succ && (val>=cl->in) )
		{
			if(val <= cl->out) ret=cl;
			cl=(struct NewClip *)cl->Node.mln_Succ;
		}
	}
	return(ret);
}

struct NewClip	*NextClip(struct ClipDisplay	*cd,int val)
{
	struct NewClip	*cl;
	if( (val<=cd->MaxVal) && (val>=cd->MinVal) )
	{
		cl=(struct NewClip *)cd->Clips.mlh_Head;
		while(cl && cl->Node.mln_Succ )
		{
			if(val>cl->in)
				cl=(struct NewClip *)cl->Node.mln_Succ;
			else return(cl);
		}
	}
	return(NULL);
}

void	InsertClip(struct ClipDisplay	*cd,struct NewClip	*cl)
{
	struct NewClip	*ncl;
	ncl=(struct NewClip *)cd->Clips.mlh_Head;
	while(ncl->Node.mln_Succ && (cl->in>=ncl->in) )
		ncl=(struct NewClip *)ncl->Node.mln_Succ;
	ncl=(struct NewClip *)ncl->Node.mln_Pred;
	Insert((struct List *)(&cd->Clips),(struct Node *)cl,(struct Node *)ncl);
}

struct NewClip	*AddClip(struct ClipDisplay	*cd,int in, int out,int type, char *name)
{
	struct NewClip	*cl=NULL;
	int t1,t2;
	if(cd->MaxVal>0) // display already has first clip at least
	{
		if( in>(cd->MaxVal) ) return(NULL);
		if( in<cd->MinVal ) in=cd->MinVal;
		if( out>cd->MaxVal ) out=cd->MaxVal ;
		if(in==out) out=in + FRAME_QUANT;
		if( cl=GetClip(cd,in) )
		{
			if(cl->out < (cd->MaxVal+FRAME_QUANT) )
				t1 = cl->out + FRAME_QUANT;
			else return(NULL); // ERROR Condition: clip past end
		}
		else t1=in;           // duoooh!!!

		if(out<t1) t2=t1 + FRAME_QUANT;
		else if( cl && (cl=(struct NewClip *)cl->Node.mln_Succ) && cl->Node.mln_Succ)
		{
			if(cl->in > out) t2=out;
			else t2=cl->in - FRAME_QUANT;
		}
		else if( cl=GetClip(cd,out) )
		{
			t2=cl->in - FRAME_QUANT;
		}
		else t2=out;

		if( (t2>t1) && (cl=SafeAllocMem(sizeof(struct NewClip)+CLIP_NAME_MAX+COMMENT_MAX+1,MEMF_CLEAR)) )
		{
			cl->in = t1;
			cl->out = t2;
			cl->icon = (cl->out + cl->in)/2;
			cl->type = type;
			cl->Name = (UBYTE *)( (ULONG)cl+sizeof(struct NewClip) );
			cl->Comment = (UBYTE *)(cl->Name+CLIP_NAME_MAX );
			strncpy(cl->Name,name,CLIP_NAME_MAX-1);

			DUMPSTR("AddClip: ");
			DUMPUDECL(cl->Name,cl->in," , ");
			DUMPUDECL(" ",cl->out," \\");

		}
		else return(cl);
	}
	else // first clip in has to set MaxVal!
	{
		cd->MinVal = in;
		if(cd->MaxVal = out)	cd->Scale=(cd->W*0xFFFF)/(cd->MaxVal-cd->MinVal) ;  // Fixed Point Fraction...
		if(cl=SafeAllocMem(sizeof(struct NewClip)+CLIP_NAME_MAX+COMMENT_MAX+1,MEMF_CLEAR))
		{
			cl->in=cd->MinVal;
			cl->out=out;  // When 1st clip is added it has to be nameless and empty
			cl->type = CLIP_EMPTY;
			cl->Name = (UBYTE *)( (ULONG)cl+sizeof(struct NewClip) );
			cl->Comment = (UBYTE *)(cl->Name+CLIP_NAME_MAX );
		}
		else return(cl);
	}
	InsertClip(cd,cl);
	return(cl);
}

struct NewClip	*KillClip(struct ClipDisplay	*cd,struct NewClip	*cl)
{
	struct NewClip	*ncl;
	if(cl==NULL) 	return(cl);
	if(ncl=(struct NewClip *)cl->Node.mln_Pred)
	{
		Remove((struct Node *)cl);
		FreeMem(cl,sizeof(struct NewClip)+CLIP_NAME_MAX+COMMENT_MAX+1);
	}
	if(ncl->Node.mln_Pred) return(ncl);
	else if( (ncl=(struct NewClip	*)ncl->Node.mln_Succ) && ncl->Node.mln_Succ)
		return(ncl);
	else return(NULL);
}

// Change clip's in and/or out val.s
BOOL SetClip(struct ClipDisplay	*cd, struct NewClip	*cl,ULONG in, ULONG out)
{
	struct NewClip	*tcl;
	ULONG t1,t2;
	in &=~1;    // only even frame #s
	out = (out+1)&~1; // round up
	if(out>cd->MaxVal) out=cd->MaxVal;
	if(in<cd->MinVal) in=cd->MinVal;
	if( cl->in <= in ) // move in-point in
	{
		if( cl->out > in ) t1=in;
		else t1=cl->out; // - STILL_QUANT; // cl->in; NOT // can't move in past old out.. need 2 calls or more code
	}
	else if( (tcl=(struct NewClip *)cl->Node.mln_Pred) && tcl->Node.mln_Pred )
	{
		if(in >= tcl->out + FRAME_QUANT ) t1=in;
		else t1=tcl->out + FRAME_QUANT;
	}
	else t1=in;

	if( cl->out >= out ) // move out-point in
	{
		if( t1 <= out ) t2=out;
		else t2=t1; // + FRAME_QUANT; // can't move out past new in..
	}
	else if( (tcl=(struct NewClip *)cl->Node.mln_Succ) && tcl->Node.mln_Succ )
	{
		if(out <= tcl->in - FRAME_QUANT ) t2=out;
		else t2 = tcl->in - FRAME_QUANT;
	}
	else t2=out;

	if( (cl->in!=t1) || (cl->out!=t2) ) // did anything change??
	{
		cl->in = t1;
		cl->out = t2;
		return(TRUE);  // doesn't fail on illegal moves (i.e. out!=t2)
	}
	return(FALSE);
}


/*  __inline void	Box(struct RastPort *RP,UWORD	x,UWORD y,UWORD	w,UWORD h)
{
	Rect[0] = x;		Rect[1] = y;
	Rect[2] = x + w;		Rect[3] = Rect[1];
	Rect[4] = Rect[2];			Rect[5] = y + h;
	Rect[6] = Rect[0];			Rect[7] = Rect[5];
	Rect[8] = Rect[0];			Rect[9] = Rect[3];
	Move(RP,Rect[0],Rect[1]);
	PolyDraw(RP,5,Rect);
}
 */

__inline void	BoxClip(struct ClipDisplay	*cd,UWORD	x1,UWORD x2)
{
	Rect[0] = cd->X + x1;		Rect[1] = cd->Y;
	Rect[2] = cd->X + x2;		Rect[5] = cd->Y + cd->H;
	Rect[4] = Rect[2];
	Rect[6] = Rect[0];
	Rect[8] = Rect[0];
	Rect[7] = Rect[5];
	Rect[9] = (Rect[3] = Rect[1]);

	Rect[10] = Rect[0] + 1;
	Rect[18] = (Rect[16] = Rect[10]);
	Rect[11] = Rect[1] + 1;
	Rect[19] = (Rect[13] = Rect[11]);
	Rect[14] = (Rect[12] = Rect[2] - 1);
	Rect[17] = (Rect[15] = Rect[5] - 1);
	Move(cd->RP,Rect[0],Rect[1]);
	PolyDraw(cd->RP,10,Rect);
}


//****************************************************************
//*********** Some special imagery stuff for these panels ********
//****************************************************************

void DrawClip(struct ClipDisplay *cd,struct NewClip *cl)
{
	UWORD	x1,x2;
	BYTE	APen=cd->RP->FgPen,BPen=cd->RP->BgPen,Dr=cd->RP->DrawMode;
	x1 = ((cl->in - cd->MinVal)*cd->Scale)/0xFFFF ;
	x2 = ((cl->out - cd->MinVal)*cd->Scale)/0xFFFF ;
	if(x1<0) x1=0;
	if(x2<0) x2=2;
	if(x2>=cd->W) x2=cd->W;
	if(x1>=cd->W) x1=cd->W-2;
	if(x2<=x1) x2=x1+2;
	switch(cl->type)
	{
		case CLIP_EMPTY:
//			SetAfPt(cd->RP,BCandyStripe,3);  // Nice stripes
			SetAPen(cd->RP,PAL_DGRAY);
			SetBPen(cd->RP,PAL_LGRAY);
			SetDrMd(cd->RP,JAM2);
			RectFill(cd->RP,cd->X + x1, cd->Y, cd->X + x2, cd->Y + cd->H);
//			SetAfPt(cd->RP,NULL,0);					// Clear pattern
			SetAPen(cd->RP,APen); // restore pens
			SetBPen(cd->RP,BPen); // restore pens
			SetDrMd(cd->RP,Dr); // restore pens
			break;
		case CLIP_ACTIVE:
			SetDrMd(cd->RP,JAM2);
			SetAPen(cd->RP,PAL_LYELLOW);
			RectFill(cd->RP,cd->X + x1, cd->Y, cd->X + x2, cd->Y + cd->H);
			SetAPen(cd->RP,PAL_BLACK);
			BoxClip(cd,x1,x2);
//			SetAfPt(cd->RP,NULL,0);					// Clear pattern
			SetAPen(cd->RP,APen); // restore pens
			SetBPen(cd->RP,BPen); // restore pens
			SetDrMd(cd->RP,Dr); // restore pens
			break;
		case CLIP_LOCKED:
			SetAfPt(cd->RP,CandyStripe,3);  // Nice stripes
			SetAPen(cd->RP,PAL_LBLACK);
			SetBPen(cd->RP,PAL_DYELLOW);
			SetDrMd(cd->RP,JAM2);
			RectFill(cd->RP,cd->X + x1, cd->Y, cd->X + x2, cd->Y + cd->H);
//			SetAPen(cd->RP,PAL_BLACK);
			BoxClip(cd,x1,x2);
			SetAfPt(cd->RP,NULL,0);					// Clear pattern
			SetAPen(cd->RP,APen); // restore pens
			SetBPen(cd->RP,BPen); // restore pens
			SetDrMd(cd->RP,Dr); // restore pens
			break;
	}
}


void	DrawClipDisplay(struct ClipDisplay	*cd)
{
	struct NewClip	*cl,*ncl;
	BYTE	APen=cd->RP->FgPen,BPen=cd->RP->BgPen,Dr=cd->RP->DrawMode;


	NewBorderBox(cd->RP,cd->X-2,cd->Y-2,cd->X+cd->W+2,cd->Y+cd->H+2,BOX_REV);

	SetAfPt(cd->RP,BCandyStripe,3);  // Nice stripes
			SetAPen(cd->RP,PAL_DGRAY);
			SetBPen(cd->RP,PAL_LGRAY);
			SetDrMd(cd->RP,JAM2);

	RectFill(cd->RP,cd->X , cd->Y, cd->X + cd->W, cd->Y + cd->H);

	SetAfPt(cd->RP,NULL,0);					// Clear pattern
			SetAPen(cd->RP,APen); // restore pens
			SetBPen(cd->RP,BPen); // restore pens
			SetDrMd(cd->RP,Dr); // restore pens

	cl=(struct NewClip *)cd->Clips.mlh_Head;
	while(ncl=(struct NewClip *)cl->Node.mln_Succ)
	{
		if (cl->type != CLIP_ACTIVE)
			DrawClip(cd,cl);			// Draw all the inactive ones
		cl=ncl;
	}

	cl=(struct NewClip *)cd->Clips.mlh_Head;
	while(ncl=(struct NewClip *)cl->Node.mln_Succ)
	{
		if (cl->type == CLIP_ACTIVE)
		{
			DrawClip(cd,cl);			// Just draw active one
			break;
		}
		cl=ncl;
	}

}


//*******************************************************************
//		Misc time functions
//*******************************************************************

// Set time string after change in slider
void UpdateTime(struct Gadget *Time,struct Window *Window,ULONG Val)
{
	ULONG	A;
	A = RemoveGadget(Window,Time);
	LongToTime((ULONG *)&Val,((struct StringInfo *)Time->SpecialInfo)->Buffer);
	AddGadget(Window,Time,A);
	RefreshGList(Time,Window,NULL,1);
}

//*******************************************************************
// Correct time string (i.e. :32 ->1:02), fill *Param with frame #
// converts HH:MM:SS:FF to LONG # of FRAMEs,,
// if Even is true, number is rounded down to colorframe even
ULONG FixTimeStr(struct PanelLine *PLine, struct Window *Window, BOOL Even)
{
	ULONG oldpos,a,*L,F=0,M=0,S=0,H=0;
	ULONG	argcount,*ndx,arg,args[5] = {0,0,0,0,0};
	char c,*ptr;
	struct Gadget *ThisG;

	if( (PLine->Type==PNL_DUOSLIDE) && (PLine->Flags&PL_OUT) )
	{
		L=(ULONG *)PLine->Param2;
		ThisG=PLine->G4;
	}
	else {
		L=(ULONG *)PLine->Param;
		ThisG=PLine->StrGadg;
	}

	if( !ThisG ) return(0);

	oldpos = RemoveGadget(Window,ThisG);

	ptr = ((struct StringInfo *)ThisG->SpecialInfo)->Buffer;
	ndx = args;
	argcount = arg = 0;
	while (c = *ptr)
	{
		ptr++;
		if ((c >= '0') && (c <= '9'))
		{
			arg *= 10;
			arg += (c - '0');
		}
		if (((*ptr)==NULL) || (c == ':') || (c == ';') || (c == ' ') || (c == '.'))
		{
			*ndx++ = arg;
			argcount++;
			if (argcount > 4) break;
			arg = 0;
		}
	}

	if (argcount == 1)
		*L = args[0];
	else if (argcount == 2)
		*L = args[0]*30 + args[1];
	else if (argcount == 3)
		*L = args[0]*1800 + args[1]*30 + args[2];
	else if (argcount >= 4)
		*L = args[0]*108000 + args[1]*1800 + args[2]*30 + args[3];

	if(Even) (*L) &= 0xFFFFFFFE;
	a=*L;
	if (UseDropFrame) *L=PickUpFrames(*L);
	if(ThisG->Width != PLENSTRING_W)
	{
		F = a;
		H = F/108000;
		F	%= 108000;
		M = F / 1800;  // 60 secs/min * 30 frames/secs
		F %= 1800;
		S = F / 30;
		F %= 30;
		sprintf(((struct StringInfo *)ThisG->SpecialInfo)->Buffer,"%02ld:%02ld:%02ld:%02ld",H,M,S,F);
	}
	else
	{
		F = a;
		S = F / 30;
		F %= 30;
		sprintf(((struct StringInfo *)ThisG->SpecialInfo)->Buffer,"%02ld:%02ld",S,F);
	}

	AddGadget(Window,ThisG,oldpos);
	RefreshGList(ThisG,Window,NULL,1);
	return(*L);
}


//*******************************************************************
//		Bar Graph Support
//*******************************************************************

#define	BAR_DECAY_SLEW		16		/* Max decay per update */
#define	BAR_PEAK_HOLDTIME	10		/* Peak indicator hold time */
#define	BAR_CLIP_HOLDTIME	4		/* Clip indicator hold time */

#define	NOBARCOLOR	PAL_DGRAY

UBYTE	AAbarColors[NUMBARSEGS]		= {PAL_LGREEN,	PAL_LYELLOW,	PAL_RED};
UBYTE	ECSbarColors[NUMBARSEGS]	= {PAL_BLACK,	PAL_LGRAY,		PAL_WHITE};
UBYTE	AAclipColors[2]	= {PAL_DGRAY, PAL_RED};
UBYTE	ECSclipColors[2]	= {PAL_DGRAY, PAL_WHITE};
UBYTE	BarBoundaries[NUMBARSEGS] = {0xE7, 0xF7, 0xFF};

/*
 * InitBarGraph -- Initialize a segmented bar graph (w/ peak ind & clip light)
 */
struct SegBarGraph *InitBarGraph(int x,int y,int w,int h,int max, struct Window *Win)
{
	struct SegBarGraph	*bg;
	UWORD	prev;
	int	i;

	if(!max) return(NULL);

	if(bg=SafeAllocMem(sizeof(struct SegBarGraph),MEMF_CLEAR) )
	{
		bg->X=x+2; //+Win->LeftEdge;
		bg->Y=y+2; //+Win->TopEdge;
		bg->W=w-4;
		bg->H=h-4;

		DUMPHEXIW("BAR --->X=",bg->X," ");

//		bg->MaxVal=max;
		bg->Val=0;
		bg->RP = Win->RPort;
		bg->Scale = (bg->W*0xFFFF)/max ;  // Fixed Point Fraction...

		DUMPHEXIL("Scale=",bg->Scale,"\\");

		bg->ClipW = 16;
		bg->ClipH = 4;
		bg->ClipX = bg->X + 217;
		bg->ClipY = bg->Y - ((bg->ClipH - bg->H) >>1);

		bg->ClipLit = FALSE;
		bg->ClipHoldTime = bg->PeakHoldTime = bg->PeakValue = 0;
		bg->DecaySlew = BAR_DECAY_SLEW;

		for (prev=0,i=0; i<NUMBARSEGS; i++)
		{
			bg->MinVal[i] = prev;
//			prev = bg->MaxVal[i] = BarBoundaries[i];
			prev = bg->MaxVal[i] = (BarBoundaries[i] * bg->Scale)/0xFFFF;

			prev++;

			DUMPHEXIW("Min=",bg->MinVal[i]," ");
			DUMPHEXIW("Max=",bg->MaxVal[i],"\\");
		}

		// Render the bar
		NewBorderBox(bg->RP,bg->X-2,bg->Y-2,bg->X+bg->W+2,bg->Y+bg->H+2,BOX_REV);
		SetAPen(bg->RP,NOBARCOLOR);
		RectFill(bg->RP,bg->X , bg->Y, bg->X + bg->W, bg->Y + bg->H);

		// Render the clip light
		NewBorderBox(bg->RP,bg->ClipX-2, bg->ClipY-2,
			bg->ClipX+bg->ClipW+2, bg->ClipY+bg->ClipH+2, BOX_REV);
		SetAPen(bg->RP,AAMachine?AAclipColors[0]:ECSclipColors[0]);
		RectFill(bg->RP, bg->ClipX, bg->ClipY, bg->ClipX+bg->ClipW, bg->ClipY+bg->ClipH);
	}
	return(bg);
}

void FreeBarGraph(struct SegBarGraph *bg)
{
	if(bg) FreeMem(bg,sizeof(struct SegBarGraph));
}


/*
 * UpdateBarGraph -- Render changes to multi-colored bar, peak & clip indicators
 */
void UpdateBarGraph(struct SegBarGraph *bg, UWORD Val, BOOL clipping)
{
	UWORD oldx,newx,diff,lo,hi;
	int	i;

	// Implement slow bar decay
	if (Val < bg->Val)
	{
		diff = bg->Val - Val;
		if (diff > bg->DecaySlew)				// Limit decay per update
			Val = bg->Val - bg->DecaySlew;
	}

	if (Val>0xFF)		// Trim new value so it's legal (just to be sure)
		Val = 0xFF;

	// Calculate pixel positions for bar now and on previous update
	oldx = bg->X + (bg->Val*bg->Scale)/0xFFFF;
	newx = bg->X + (Val*bg->Scale)/0xFFFF;

	if (newx < oldx)			// Bar shrinking
	{
		newx++;					// Want bar up to newx still rendered

		if (oldx == bg->PeakValue)		// Don't clobber the peak indicator
			oldx--;

		if (newx <= oldx)		// Still something left to erase?
		{
			SetAPen(bg->RP,NOBARCOLOR);
			RectFill(bg->RP,newx,bg->Y,oldx,bg->Y+bg->H);
		}

		newx--;					// Restore *real* value
	}
	else if (newx > oldx)	// Bar growing
	{
		if (oldx != bg->PeakValue)		// Don't re-render this old point unnecessarily,
			oldx++;							// (unless it was a peak value, which is wrong color)

		for (i=0 ; i<NUMBARSEGS ; i++)		// Do rendering for each color segment separately
		{
			lo = bg->X + bg->MinVal[i];		// Get pixel range for this segment
			hi = bg->X + bg->MaxVal[i];

			if ((oldx <= hi) && (newx >= lo))		// Need to render in this segment?
			{
				// Clip points so we don't render outside our segment!
				if (oldx > lo)
					lo = oldx;
				if (newx < hi)
					hi = newx;

				// Render our part of new bar imagery
				SetAPen(bg->RP,AAMachine?AAbarColors[i]:ECSbarColors[i]);
				RectFill(bg->RP,lo,bg->Y,hi,bg->Y+bg->H);
			}
		}
	}
	bg->Val = Val;						// Keep new current value

	// Handle/render peak mark
	if (newx >= bg->PeakValue)		// New recent record (based on pixel pos)?
	{
		bg->PeakValue = newx;
		bg->PeakHoldTime = BAR_PEAK_HOLDTIME;				// Hold this for a bit
		SetAPen(bg->RP,PAL_WHITE);
		RectFill(bg->RP,newx,bg->Y,newx,bg->Y+bg->H);	// Put peak ind. here
	}
	else if (bg->PeakHoldTime)
	{
		if (--bg->PeakHoldTime == 0)
		{
			// Remove old peak
			SetAPen(bg->RP,NOBARCOLOR);
			RectFill(bg->RP,bg->PeakValue,bg->Y,bg->PeakValue,bg->Y+bg->H);
			bg->PeakValue = 0;			// Start new record now
		}
	}

	// Implement clip light hold time
	if (clipping)
		bg->ClipHoldTime = BAR_CLIP_HOLDTIME;			// .5 seconds
	else if (bg->ClipHoldTime)
	{
		clipping = TRUE;
		bg->ClipHoldTime--;
	}

	if (clipping != bg->ClipLit)		// Need to re-render?
	{
		if (AAMachine)
			SetAPen(bg->RP,AAclipColors[clipping?1:0]);
		else
			SetAPen(bg->RP,ECSclipColors[clipping?1:0]);

		RectFill(bg->RP,bg->ClipX,bg->ClipY,bg->ClipX+bg->ClipW,bg->ClipY+bg->ClipH);

		bg->ClipLit = clipping;
	}
}


#if OLD_DUAL_CLIPLIGHTS
struct AudIndicator *InitAudIndicator(int x,int y,int w,int h,int max,UBYTE *Clipping, struct Window *Win)
{
	struct AudIndicator	*aInd;
	DUMPHEXIL("Indictor Clipping",(LONG)Clipping,"  ");
	if(!Clipping || !max) return(NULL);
	DUMPUDECL(" Making AudIndicator: ",sizeof(struct AudIndicator)," Bytes ");
	if(aInd=SafeAllocMem(sizeof(struct AudIndicator),MEMF_CLEAR) )
	{
		DUMPMSG(" Allocation OK ");
		aInd->X=x+2; //+Win->LeftEdge;
		aInd->Y=y+2; //+Win->TopEdge;
		aInd->W=w-4;
		aInd->H=h-4;
		aInd->ClipX=aInd->X + (aInd->W*14);
		aInd->Clip=Clipping;
		aInd->MaxVal=max;
		aInd->RP = Win->RPort;
		aInd->Clip1Lit = aInd->Clip2Lit = FALSE;
		NewBorderBox(aInd->RP,aInd->X-2,aInd->Y-2,aInd->X+aInd->W+2,aInd->Y+aInd->H+2,BOX_REV);
		NewBorderBox(aInd->RP,aInd->ClipX-2,aInd->Y-2,aInd->ClipX+aInd->W+2,aInd->Y+aInd->H+2,BOX_REV);
		SetAPen(aInd->RP,PAL_DGRAY);
		RectFill(aInd->RP,aInd->X , aInd->Y, aInd->X + aInd->W, aInd->Y + aInd->H);
		RectFill(aInd->RP,aInd->ClipX , aInd->Y, aInd->ClipX + aInd->W, aInd->Y + aInd->H);
	}
	return(aInd);
}

void FreeAudIndicator(struct AudIndicator *aInd)
{
	if(aInd) FreeMem(aInd,sizeof(struct AudIndicator));
}

void UpdateAudIndicator(struct AudIndicator *aInd, UWORD Val)
{
	BOOL	newstate;

	if (Val>0)
		newstate = TRUE;
	else
		newstate = FALSE;

	if (newstate != aInd->Clip1Lit)		// Need to re-render?
	{
		SetAPen(aInd->RP,newstate ? PAL_DYELLOW : PAL_DGRAY);
		RectFill(aInd->RP,aInd->X , aInd->Y, aInd->X + aInd->W, aInd->Y + aInd->H);
		aInd->Clip1Lit = newstate;
	}

//	if(Val>aInd->MaxVal)				// Make 2nd LED "sticky"
//		*(aInd->Clip)=1;
//	if(!*(aInd->Clip))

	if (Val>1)							// Make 2nd LED "live"
		newstate = TRUE;
	else
		newstate = FALSE;

	if (newstate != aInd->Clip2Lit)		// Need to re-render?
	{
		SetAPen(aInd->RP,newstate ? PAL_LYELLOW : PAL_DGRAY);
		RectFill(aInd->RP,aInd->ClipX , aInd->Y, aInd->ClipX + aInd->W, aInd->Y + aInd->H);
		aInd->Clip2Lit = newstate;
	}
}
#endif



struct ClipCrUD MyCrUD = { 0x464F524D,0,0x43725544,0x54595045,8,
		ID_CLIP,0,
		0x4C494253,0x18,0xFFFFFCD0,0x0010,"effects.library",
		0x54414753,COMMENT_MAX + 12,
		TAG_CommentList,COMMENT_MAX,"",
//		TAG_Duration,180,TAG_RecFields,4,
		NULL};

// NOTA BENE!!!  Assumes clip in/out relative to raw clip start==0
ULONG	DHD_ClipIcon(struct NewClip	*cl, char *PathPre)
{
	ULONG	x=FALSE,f=0;	//assume error

	strncpy(ClipName,PathPre,CLIP_PATH_MAX);
	strncat(ClipName,cl->Name,CLIP_PATH_MAX);

	f=cl->icon - cl->in;

	// If we get a bogus icon field, just take the last field
	if (f > (cl->out - cl->in))
		f = cl->out - cl->in -1;

	DUMPSTR("DHD_ClipIcon( ");
	DUMPSTR(ClipName);
	DUMPUDECL(", ",f," )\\");

	if(cl->in==cl->out)
	{
		f=0;
		MyCrUD.Clip = ID_STIL;
	}
 	else
	{
//		MyCrUD.Dur = MyCrUD.Fields = (cl->out - cl->in + 2)<<1;
		MyCrUD.Clip = ID_CLIP;
	}
	CopyMem(cl->Comment,&(MyCrUD.Comment[0]),COMMENT_MAX);
	MyCrUD.fSize = sizeof(struct ClipCrUD)-8;
	ESparams4.Data1=(LONG)ClipName;
	ESparams4.Data2=(LONG)&MyCrUD;
	ESparams4.Data3=(LONG)sizeof(struct ClipCrUD);
	ESparams4.Data4=(LONG)(f&~1)<<1;
	x=(ULONG)SendSwitcherReply(ES_MakeClipIcon,&ESparams4);
//	ESparams1.Data1=(LONG)ClipName;
//	SendSwitcherReply(ES_AppendIcon,&ESparams1);
	return(x);
}


BOOL MaybeDoReorg(struct Window *window, char *drivename)
{
	if(*drivename==AUDIO_BYTE)
		drivename+=2;					// Skip speaker symbol char and space

	sprintf(pstr,"If I reorganize %s, it may take a while... ",drivename);
	if(BoolRequest(window,pstr))
	{
		sprintf(pstr,"Reorganizing Flyer drive %s",drivename);
		OpenNoticeWindow(window,PatienceMsg,2,TRUE);
		DisplayWaitSprite();
		DHD_Reorganize(drivename);
		DisplayNormalSprite();
		CloseNoticeWindow();
		return(TRUE);
	}
	return(FALSE);
}


void MakeStdContinue(struct PanelLine *pl)
{
//	pl->Label = "Continue";
	pl->PropStart = 1;						// Want colored hilite
	pl->PropEnd = 2;							// Always use size 2 button (medium)
	pl->Param =(LONG *)GB_CONTINUE;		// General button code for "continue"
	pl->Flags = PL_GENBUTT;
}

void MakeStdCancel(struct PanelLine *pl)
{
//	pl->Label = "Cancel";
	pl->PropStart = 1;						// Want colored hilite
	pl->PropEnd = 2;							// Always use size 2 button (medium)
	pl->Param =(LONG *)GB_CANCEL;			// General button code for "cancel"
	pl->Flags = PL_GENBUTT;
}


void DoGenButtons(
	struct PanelLine *PLine,
	struct Window *Window,
	UWORD *success,
	BOOL *going)
{
	if (PLine->Flags & PL_GENBUTT)
	{
		switch ((ULONG)PLine->Param)
		{
		case GB_CONTINUE:
			*success = PAN_CONTINUE;
			*going = FALSE;
			break;
		case GB_CANCEL:
//			*success = FALSE;	???
			*going = FALSE;
			break;
		case GB_FINE_TUNE:
			*success = PAN_EXPERT;
			*going = FALSE;
			break;
		case GB_QUICK_TUNE:
			*success = PAN_EASY;
			*going = FALSE;
			break;
		case GB_REORG:				// Reorganize drive
			if (global_CurVolumeName)
				MaybeDoReorg(Window,global_CurVolumeName);
			break;
		case GB_PROCESS:		// Process clip
			*going = FALSE;
			*success = PAN_PROCESS;
			break;
		case GB_CUT:			// Cut clip
			*going = FALSE;
			*success = PAN_CUTUP;
			break;
		case GB_AUDIOENV:
			*going = FALSE;
			*success = PAN_ENVL;
			break;
		}
	}
}


void InitPanelLines(struct PanelLine panel[], struct InitPanelLine *ipl)
{
	struct PanelLine	*pl = panel;

	while (ipl->Type)
	{
		//Start with defaults for particular PLine type
		*pl = PLineDefaults[ipl->Type];

		//Customize position, spacing, and text (from IPL table for panel)
		CopyMem(ipl,pl,sizeof(struct InitPanelLine));

		pl++;
		ipl++;
	}
	pl->Type = 0;			// List terminator
}


struct InhTags {
	ULONG	Type;				// CT_xxx
	BOOL	Lockable;		// Supports lock flag & lock time?
	BOOL	Relative;		// Supports lock to & delay?
	ULONG	LenTag;			// Tag which describes overall duration
	BOOL	SpdBtns;			// Supports speed buttons
};

struct InhTags InhArray[] = {
	{	CT_FXANIM,		FALSE,	FALSE,	0,							TRUE	},
	{	CT_FXILBM,		FALSE,	FALSE,	0,							TRUE	},
	{	CT_FXALGO,		FALSE,	FALSE,	0,							TRUE	},
	{	CT_FXCR,			FALSE,	FALSE,	0,							FALSE	},
	{	CT_VIDEO,		TRUE,		FALSE,	TAG(Duration),			FALSE	},
	{	CT_AUDIO,		FALSE,	TRUE,		TAG(AudioDuration),	FALSE	},
	{	CT_CONTROL,		FALSE,	FALSE,	0,							FALSE	},
	{	CT_FRAMESTORE,	TRUE,		FALSE,	TAG(Duration),			FALSE	},
	{	CT_KEY,			FALSE,	TRUE,		TAG(Duration),			FALSE	},
	{	CT_SCROLL,		FALSE,	TRUE,		TAG(Duration),			FALSE	},
	{	CT_CRAWL,		FALSE,	TRUE,		TAG(Duration),			FALSE	},
	{	CT_MAIN,			TRUE,		FALSE,	TAG(Duration),			FALSE	},
	{	CT_STILL,		TRUE,		FALSE,	TAG(Duration),			FALSE	},

	{	CT_VIDEOANIM,	TRUE,		FALSE,	0},		// Need to know more about these...
	{	CT_KEYEDANIM,	FALSE,	FALSE,	0},
	{	0,					0,			0,			0}
};

ULONG	AudioTags[] = {
	TAG(AudioStart),
	TAG(AudioDuration),
	TAG(AudioAttack),
	TAG(AudioDecay),
	TAG(AudioVolume1),
	TAG(AudioVolume2),
	TAG(TimeMode),
	TAG(Delay),
//	TAG(AudioOn),
	TAG(AudioPan1),
	TAG(AudioPan2),
	TAG(PanelMode),
	0
};

ULONG	VideoTags[] = {
	TAG(ClipStartField),
	TAG(Duration),
	TAG(AudioStart),
	TAG(AudioDuration),
	TAG(AudioVolume1),
	TAG(AudioVolume2),
	TAG(AudioAttack),
	TAG(AudioDecay),
	TAG(TimeMode),
	TAG(Delay),
	TAG(AudioPan1),
	TAG(AudioPan2),
	TAG(PanelMode),
	0
};


KeyTags[] = {
	TAG(Duration),
	TAG(Delay),
	TAG(TimeMode),
	TAG(Speed),
	TAG(FadeInDuration),
	TAG(FCountMode),
	TAG(VariableFCount),
	TAG(VariableFCount68000),
	0
};

CRFXTags[] = {
	TAG(Delay),
	TAG(TimeMode),
	TAG(Duration),
	TAG(TakeOffset),
	TAG(ASourceLen),
	TAG(BSourceLen),
	TAG(DataMode),
	TAG(ColorMode),
	TAG(CycleMode),
	TAG(NumFramesSlow),
	TAG(NumFramesMedium),
	TAG(NumFramesFast),
	TAG(DataMode),
	TAG(TBarPosition),
	TAG(FCountMode),
	0
};




#ifdef SERDEBUG
extern CFAR struct TagHelp TagNames[];
#endif

static BOOL TagMoveFunc(APTR tagptr,APTR data)
{
	struct FastGadget	*FG;
	ULONG	tagid,*tptr;

	tptr = (ULONG *)tagptr;
	FG = (struct FastGadget *)data;

	tagid = (*tptr++) & (0x00FFFFFF | TAGCTRL_LONG);	// Strip off all flags except 'LONG'

	switch (tagid)
	{
		// DO NOT copy these tags!!!
		case TAG_OriginalLocation:
			break;

		default:		// Copy all other tags
			DUMPSTR("Moving ");
			DUMPMSG(TagNames[tagid & 0xFFFFFF].th_Name);

			if (TAGCTRL_LONG & tagid)
				PutValue(FG,tagid,*tptr);
			else
				PutTable(FG,tagid,(APTR)(tptr+1),*tptr);
	}

	return(TRUE);
}


BOOL InheritTags(struct Window *window, struct FastGadget *old, struct FastGadget *new)
{
	struct	InhTags	*ih;
	LONG	dur,lock,time,speed=0,varspd=60;
	ULONG	oldtype,newtype,audon;
	BOOL	lockable,relative;

	DUMPMSG("Inherit!!!");

	oldtype=((struct ExtFastGadget *)old)->ObjectType;
	newtype=((struct ExtFastGadget *)new)->ObjectType;

	// Special section for replacing a lost crouton
	if (oldtype == CT_ERROR)
	{
		if (newtype != ((struct ExtFastGadget *)old)->LocalData)
		{
			ContinueRequest(window,"Cannot inherit from lost crouton -- incorrect crouton type");
			return(FALSE);
		}
		else
		{
			DUMPMSG("Lost crouton replacement");

			// Move all tags from 'old' to 'new'
			WalkTagList((struct ExtFastGadget *)old,TagMoveFunc,(APTR)new);

			/*** Special test to make sure in/out points are legal ***/
			if ((newtype == CT_VIDEO) || (newtype == CT_AUDIO))
			{
				if (!LegalizeInOutPoints(window,new))		// Make points sane, maybe warn user/abort
					return(FALSE);
			}
		}
		return(TRUE);
	}

	for (ih=InhArray; ih->Type; ih++)
	{
		if (ih->Type == oldtype)
			break;
	}
	if (ih->Type == 0)			// If not in tags inherit table, cannot do much else
		return(TRUE);


	lockable = ih->Lockable;
	relative = ih->Relative;
	if (ih->SpdBtns)
	{
		speed = GetValue(old,TAG(FCountMode));
		varspd = GetValue(old,TAG(NumFramesVariable));
	}

	if (lockable || relative)
	{
		lock = GetValue(old,TAG(TimeMode));
		time = GetValue(old,TAG(Delay));
	}

	if (ih->LenTag)
		dur = GetValue(old,ih->LenTag);
	else
		dur = 0;


	for (ih=InhArray; ih->Type; ih++)
	{
		if (ih->Type == newtype)
			break;
	}
	if (ih->Type == 0)			// If not in tags inherit table, cannot do much else
		return(TRUE);


	if ((lockable || relative) && (ih->Lockable || ih->Relative))
	{
		PutValue(new,TAG(TimeMode),lock);
		PutValue(new,TAG(Delay),time);
	}

	if (ih->LenTag)
		PutValue(new,ih->LenTag,dur);

	if (ih->SpdBtns)
	{
		PutValue(new,TAG(FCountMode),speed);
		PutValue(new,TAG(VariableFCount),Frms2Flds(varspd));

		ESparams2.Data1=(LONG)new;
		ESparams2.Data2=FGC_FCOUNT;
		SendSwitcherReply(ES_FGcommand,&ESparams2);
	}

	/*** For some crouton types, inherit all tags if overwriting same type ***/
	if (oldtype==newtype)
	{
		BOOL audonflag = FALSE;
		ULONG	*taglist,temp;

		switch (newtype)
		{
			case CT_AUDIO:
				taglist = AudioTags;
				audonflag = TRUE;
				break;
			case CT_VIDEO:
				taglist = VideoTags;
				audonflag = TRUE;
				break;
			case CT_KEY:
				taglist = KeyTags;
				break;

			case CT_FXCR:
				taglist = CRFXTags;
				break;	
							

			default:
				taglist = NULL;
		}

		if (taglist)
		{
			while (*taglist)
			{
				PutValue(new,*taglist,GetValue(old,*taglist));		// Copy each tag listed
				taglist++;
			}
		}

		DUMPMSG("About to deal with audio");
		if (audonflag)			// Special handling of "AudioOn" tag?
		{
			DUMPMSG("Dealing with audio");
			// Try to inherit audio flags, but must keep & honor "presence" flags in new clip
			audon = GetValue(new,TAG(AudioOn)) & (AUDF_Channel1Recorded | AUDF_Channel2Recorded);
			temp  = GetValue(old,TAG(AudioOn));
			if ((temp & AUDF_Channel1Enabled) && (audon & AUDF_Channel1Recorded))
				audon |= AUDF_Channel1Enabled;
			if ((temp & AUDF_Channel2Enabled) && (audon & AUDF_Channel2Recorded))
				audon |= AUDF_Channel2Enabled;
			PutValue(new,TAG(AudioOn),audon);		// Put merged audio flags back
		}
	}
	else		//	!(oldtype==newtype)
	{
		// if new type is video and oldtype was something else use new crounton aud. flags.
		if (newtype==CT_VIDEO)
		{		
			audon = GetValue(new,TAG(AudioOn)) & (AUDF_Channel1Recorded | AUDF_Channel2Recorded);
			if (audon&AUDF_Channel1Recorded)
				audon |= AUDF_Channel1Enabled;
			if	(audon&AUDF_Channel2Recorded)
				audon |= AUDF_Channel2Enabled; 	
			
			if (oldtype!=CT_VIDEO)
			{
				PutValue(new,TAG(AudioStart),GetValue(new,TAG(ClipStartField)));
				PutValue(new,TAG(AudioDuration),GetValue(new,TAG(Duration)));
			}
			
			
		}

	}

	/*** Special test to make sure in/out points are legal ***/
	if ((newtype == CT_VIDEO) || (newtype == CT_AUDIO))
	{
		if (!LegalizeInOutPoints(window,new))		// Make points sane, maybe warn user
			return(FALSE);
	}

	/*** Set/Clr corner pic flags based on lock & audio status ***/
	if (newtype == CT_VIDEO)
	{
		if (
			((audon&AUDF_Channel1Recorded)&&(audon&AUDF_Channel1Enabled))
		|| ((audon&AUDF_Channel2Recorded)&&(audon&AUDF_Channel2Enabled))
		)
			{
				DUMPMSG("Audio on");
				((struct ExtFastGadget *)new)->SymbolFlags |= SYMF_AUDIO;	// Audio is on
			}
		else
			{
				DUMPMSG("Audio off");
				((struct ExtFastGadget *)new)->SymbolFlags &= ~SYMF_AUDIO;	// Audio is off
			}
	}
	if (ih->Lockable)
	{
		if (GetValue(new,TAG(TimeMode)) == TIMEMODE_ABSTIME)
			((struct ExtFastGadget *)new)->SymbolFlags |= SYMF_LOCKED;
		else
			((struct ExtFastGadget *)new)->SymbolFlags &= ~SYMF_LOCKED;
	}

	return(TRUE);
}


BOOL LegalizeInOutPoints(struct Window *win, struct FastGadget *FG)
{
	LONG	in,out,total,dur;
	ULONG	type;
	BOOL	legal=TRUE;

	type=((struct ExtFastGadget *)FG)->ObjectType;
	total = GetValue(FG,TAG(RecFields));
	total &= ~3;		// Trim off any residual fields, use only whole color frames

	if (type == CT_VIDEO)
	{
		in  = GetValue(FG,TAG(ClipStartField));
		dur = GetValue(FG,TAG(Duration));
		out = in + dur;

		if (dur > total)
		{
			// Max out in/out points, but warn that we failed
			PutValue(FG,TAG(ClipStartField),0);
			PutValue(FG,TAG(Duration),total);
			legal = FALSE;
		}
		else if (out > total)
		{
			PutValue(FG,TAG(Duration),dur);
			PutValue(FG,TAG(ClipStartField),total-dur);
		}
	}

	in  = GetValue(FG,TAG(AudioStart));
	dur = GetValue(FG,TAG(AudioDuration));
	out = in + dur;

	if (dur > total)
	{
		// Max out in/out points, but warn that we failed
		PutValue(FG,TAG(AudioStart),0);
		PutValue(FG,TAG(AudioDuration),total);
		legal = FALSE;
	}
	else if (out > total)
	{
		PutValue(FG,TAG(AudioDuration),dur);
		PutValue(FG,TAG(AudioStart),total-dur);
	}

	if (!legal)
	{
		if (BoolRequest(win,"Warning: new clip is too short to inherit old duration fully"))
			legal = TRUE;			// Not legal, but they'll live with it
	}

	return(legal);
}


void PutUpPrevLastFrame(struct FastGadget *FG)
{
	struct ExtFastGadget *pfg;
	UBYTE	chan;
	ULONG	fld;
	BOOL	doit;

	// Put up last frame of previous crouton on preview (if a Flyer clip/still)
	pfg = GetPrevGadget((struct ExtFastGadget *)FG);
	if (pfg)
	{
		if (pfg->ObjectType == CT_VIDEO)
		{
			doit = TRUE;
			// Play last frame of clip
			fld = GetValue((struct FastGadget *)pfg,TAG(ClipStartField)) +
					GetValue((struct FastGadget *)pfg,TAG(Duration)) - 4;
		}
		else if (pfg->ObjectType == CT_STILL)
		{
			doit = TRUE;
			fld = 0;										// Play 1st/only frame of still
		}
		else
			doit = FALSE;

		if (doit)
		{
			chan = OppChanOnPrvw();						// Put proper channel on preview bus

			// Now show selected frame of clip/still
			PlayFlyerEvent(chan, pfg->FileName, fld, 4);
		}
	}
}


/*
 * WalkTagList - Walk thru all TagLists for the provided crouton, calling
 *						'ClientFunc' for each tag found.  'ClientFunc' should return
 *						return TRUE to keep processing, or FALSE to abort.  'ClientData'
 *						is a client-private ptr passed to the handler function.
 *
 *						This function will return TRUE when done, or FALSE if aborted.
 */
BOOL WalkTagList(struct ExtFastGadget *FG, BOOL (*ClientFunc)(APTR,APTR), APTR ClientData)
{
	struct TagListNode *tln;
	ULONG	*tptr,tagflags;
	BOOL	go = TRUE;

	if (FG->TagLists)			// Any taglists?
	{
		// Walk thru linked list of TagListNode's
		tln = (struct TagListNode *)((LONG)FG + (LONG)FG->TagLists);
		for (; tln; tln=(struct TagListNode *)tln->NextNode)
		{
			tptr = (ULONG *)((LONG)tln + sizeof(struct TagListNode));

			// Walk thru each tag in this taglist (or until aborted)
			while (go && (tagflags = *tptr))
			{
				go = ClientFunc((APTR)tptr,ClientData);	// Let client process this tag

				if (TAGCTRL_LONG & tagflags)
					tptr+=2;		//Skip tag.l and value.l
				else
					tptr = (ULONG *)  ((ULONG)tptr + 8 + tptr[1]);	// Skip tag.l, len.l, data.?
			}
		}
	}

	return(go);
}



void	SW_BltClear(UWORD* Plane, UWORD ByteSize, UWORD FillP)
{
	UWORD	*NEXTP;
	UWORD	WordCount;
	if(Plane!=0)
	{
		for(WordCount=ByteSize/2;WordCount>0;WordCount--){
			*Plane = (UWORD)FillP;
			Plane=Plane+2;
		}
	}
}


void	ClearBM(struct BitMap *BMP)
{
	UBYTE PN_CT;
	for(PN_CT=0;PN_CT<BMP->Depth;PN_CT++){
	//BltClear(BMP->Planes[PN_CT],(484/8)*50,1);	
	//SW_BltClear(BMP->Planes[PN_CT],(484/8)*50,0);
	ByteFillMemory(BMP->Planes[PN_CT],0,(484/8)*50);			//484);

	}
}


/*******************************************
 * 
 * RedrawAudioevn
 *
 * Needs:
 * AudEnv - the audioenvelope structure
 *
 *
 ******************************************/
void	RedrawAudioevn(struct AudEnvDisp *aev)
{
	BYTE	APen=aev->RP->FgPen,BPen=aev->RP->BgPen,Dr=aev->RP->DrawMode;

	WORD	bd_LineSeg[] = { 0,0,0,0 };

	WORD	bd_ActKey[] = { 0,0, 0,-2, 0,2, 0,0, -2,0, 2,0 };
	WORD	bd_SelKey[] = { -2,2, -2,-2, 2,-2, 2,2, -1,2, -1,-1, 1,-1, 1,1,
								0,1, 0,0 };

	struct Border AELineSeg = {0, 0, 2, 1, 1, 2, 0, 0 };
	struct Border ActKey = {0, 0, 3, 1, 1, 6, 0, 0 };
	struct Border SelKey = {0, 0, 7, 1, 1, 10, 0, 0 };

	struct AEDKey *AEDNode;
	struct MinList *AEDHead;

	struct BitMap	*DBM;

	//Check AEDKeys,AEDKey
	AEDHead=&aev->AEDKeys;	
	//DUMPHEXIL("AEDHeader=",(LONG)AEDHead,"\\");
	AEDNode=AEDHead->mlh_Head;
	//DUMPHEXIL("AEDNode=",(LONG)AEDNode,"\\");

// *DEBUG* List Times of all nodes in list
/*
	for(AEDNode=AEDHead->mlh_Head;AEDNode->mln_Succ;AEDNode=AEDNode->mln_Succ)
	{
		DUMPHEXIL("NewAEDNode->Time=",(LONG)AEDNode->Time,"\\");
	}
*/

// init boarder display structures 	
	ActKey.XY = &bd_ActKey;
	SelKey.XY = &bd_SelKey;
	AELineSeg.XY = &bd_LineSeg;

// Clear envlope display area
	SetAfPt(aev->DRP,NULL,0);				// Clear pattern
	SetAPen(aev->DRP,1); 			
	SetBPen(aev->DRP,2); 			
	SetDrMd(aev->DRP,1); 			

//	ClearBM(aev->DRP->BitMap);

	RectFill(aev->DRP,0,0,aev->W+7,aev->H+8);

// Draw the lines 
	AEDNode = AEDHead->mlh_Head;

	while(AEDNode->mln_Succ)
	{
		while ((AEDNode->Act==AEDKey_Inact)&(AEDNode->mln_Succ!=0))
		{
			AEDNode = AEDNode->mln_Succ;
		}
		bd_LineSeg[0]=(WORD)AEDNode->Scaled_Time-aev->MinVal;
		bd_LineSeg[1]=(WORD)AEDNode->Scaled_Val;
		AEDNode = AEDNode->mln_Succ;

		//If an endofline node is set inactive then scan through list until 
		//an active one is found or end of list is hit.
		while ((AEDNode->Act==AEDKey_Inact)&(AEDNode->mln_Succ!=0))
		{
			AEDNode = AEDNode->mln_Succ;
		}
		//If not at endofline 
		if (AEDNode->mln_Succ)
		{
			bd_LineSeg[2]=(WORD)AEDNode->Scaled_Time-aev->MinVal;
			bd_LineSeg[3]=(WORD)AEDNode->Scaled_Val;
			//DUMPHEXIW("ls1",(WORD)bd_LineSeg[1],"\\");
			//DUMPHEXIW("ls2",(WORD)bd_LineSeg[2],"\\");
			//DUMPHEXIW("ls3",(WORD)bd_LineSeg[3],"\\");
			//DUMPHEXIW("ls4",(WORD)bd_LineSeg[4],"\\");
			DrawBorder(aev->DRP,&AELineSeg,2,2);
		}
	}

// Plot the key points frist
	for(AEDNode=AEDHead->mlh_Head;AEDNode->mln_Succ;AEDNode=AEDNode->mln_Succ)
	{
		switch(AEDNode->Act)
		{
			case	AEDKey_Inact:
				break;
			case	AEDKey_act:
				ActKey.LeftEdge = AEDNode->Scaled_Time-aev->MinVal;	
				ActKey.TopEdge = AEDNode->Scaled_Val;	
				DrawBorder(aev->DRP,&ActKey,2,2);
				break;
			case	AEDKey_sel:
				SelKey.LeftEdge = AEDNode->Scaled_Time-aev->MinVal;	
				SelKey.TopEdge = AEDNode->Scaled_Val;	
				DrawBorder(aev->DRP,&SelKey,2,2);
				break;
		}
	}

	DBM = aev->DRP->BitMap;
	BltBitMapRastPort(DBM,0,0,aev->RP,aev->X-2,aev->Y-2,aev->W,aev->H-2,0xC0);

}

