/********************************************************************
* $GadgetHelp.c$
* $Id: GadgetHelp.c,v 2.17 1995/09/28 10:07:58 Flick Exp $
* $Log: GadgetHelp.c,v $
*Revision 2.17  1995/09/28  10:07:58  Flick
*Now uses RawKeyCodes.h
*
*Revision 2.16  1995/09/13  12:16:00  Flick
*Superficial SMPTE cleanup/debugging code (no functional changes)
*
*Revision 2.15  1995/08/09  17:52:12  Flick
*New f'n: SafeCalcNewPot
*
*Revision 2.14  1995/06/06  12:32:16  Flick
*New DropFrames formula cures time-code bugs
*
*Revision 2.13  1995/02/27  22:13:24  pfrench
*required another freegadgets function because the backup
*program was inclined to call gadtools library on the
*gadgets the editor created for it
*
*Revision 2.12  1995/02/22  10:14:07  CACHELIN4000
*Add TimeCode cut/paste
*
*Revision 2.11  1995/02/12  17:02:32  CACHELIN4000
*Add dfopframe supptor to SMPTEToLOng
*
*Revision 2.10  1995/02/11  16:47:03  CACHELIN4000
*Add SMPTEToLong() f'n
*
*Revision 2.9  1994/10/12  14:04:05  CACHELIN4000
*Add Rounded Border routine, fix FreeGadget for borders, change UWORD to WORD args
*
*Revision 2.8  94/09/10  23:03:45  CACHELIN4000
**** empty log message ***
*
*Revision 2.7  94/09/06  22:25:13  CACHELIN4000
*Move TimeCode functions out of overcrowded Panel.c, so linking will succeed
*
*Revision 2.6  94/07/22  11:41:10  CACHELIN4000
**** empty log message ***
*
*Revision 2.5  94/07/11  17:59:17  CACHELIN4000
*Use TCFont.
*
*Revision 2.4  94/06/07  10:16:32  CACHELIN4000
**** empty log message ***
*
*Revision 2.3  94/04/20  17:32:43  CACHELIN4000
**** empty log message ***
*
*Revision 2.2  94/03/17  09:52:55  Kell
**** empty log message ***
*
*Revision 2.1  94/03/14  00:31:08  CACHELIN4000
*Check PathGadget string buffer size (SI->MaxChars)
*
*Revision 2.0  94/02/17  16:23:54  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  15:56:54  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  14:44:11  Kell
*FirstCheckIn
*
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	10-7-92		Hartford	Added ImageToBitMap()
*	11-4-92		Hartford	Added UpdateStringGadgetText()
*	12-17-92	Steve H		Convert to use SmartStrings
*	10-15-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/sghooks.h>
#include <utility/hooks.h>
#include <stdio.h>
#include <string.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include <editwindow.h>
#include <panel.h>
#include <flyer.h>
#include <RawKeyCodes.h>

#ifndef PROTO_PASS
#include <proto.h>
#endif

//#define SERDEBUG	1
#include <serialdebug.h>

#define MAX_STRING_BUFFER 300
#define MAX_INTUI_BUFFER 368
#define BORDER_COUNT 6
#define LEFT_COUNT 4
extern struct TextFont *EditFont;
extern struct TextFont *TCFont;

/* This fixes the black string gadget BG, but only under WB 2.0 */
struct StringExtend PathExt = {
	NULL,   // Font
	0,2,    // pens
	0,2,    // act. pens
	NULL,   // Initial Modes ( for TC SGM_REPLACE|SGM_FIXEDFIELD)
	NULL,		// EditHook
	NULL,		// workbuffer
	0,0,0,0	// reserved[4]
};

struct StringExtend TCExt = {
	NULL,   // Font
	0,2,    // pens
	0,2,    // act. pens
	SGM_REPLACE|SGM_FIXEDFIELD|SGM_NOFILTER,   // Initial Modes
	NULL,		// EditHook
	NULL,		// workbuffer
	0,0,0,0	// reserved[4]
};

struct Hook	TCHook;
UBYTE TCWorkBuf[16],TCPasteBuf[16];
BOOL UseDropFrame=TRUE;

struct SGWork StrWork = {
	NULL,				// Gadget
	NULL,				// Stringinfo
	NULL,	NULL, // work, prev buffers
	NULL,				// modes
	NULL,				// IE
	0,0,0,			// code, pos, chars
	NULL,NULL,	// actions,longint
	NULL,				// gadgetinfo
	0						//editop
};

VOID gh_FreeGadgets(struct Gadget *FirstGadget);

ULONG	TC_HookFn(struct Hook *hook, struct SGWork *sgw, ULONG *msg)
{
	ULONG ret=1;
	if(*msg == SGH_KEY)
		if( (sgw->EditOp == EO_REPLACECHAR) || (sgw->EditOp == EO_INSERTCHAR) )
		{
			DUMPHEXIL("EO_REP: msg=",*msg,"  ");
			DUMPHEXIB("code=",sgw->Code,"  ");
			DUMPHEXIB("iecode=",sgw->IEvent->ie_Code," ");
			DUMPHEXIB("qual=",sgw->IEvent->ie_Qualifier,"\\");
			DUMPHEXIW("BufferPos = ",sgw->BufferPos," ");
			DUMPHEXIW("SIChars = ",sgw->StringInfo->NumChars," ");
			DUMPHEXIW("SGWChars = ",sgw->NumChars,"\\ ");

			if( (sgw->Code =='c') || (sgw->Code =='C') )
			{
				sgw->WorkBuffer[sgw->BufferPos-1] = sgw->PrevBuffer[sgw->BufferPos-1];
				sgw->WorkBuffer[sgw->BufferPos] = sgw->PrevBuffer[sgw->BufferPos];
				strncpy(TCPasteBuf,sgw->WorkBuffer,15);
			}
			else if( (sgw->Code =='v') || (sgw->Code =='V') )
				strncpy(sgw->WorkBuffer,TCPasteBuf,15);

			else if( (sgw->Code >='0') && (sgw->Code <='9')
				&& ((sgw->BufferPos==0) || (sgw->PrevBuffer[sgw->BufferPos-1]!=':')) )
			{
				if( sgw->WorkBuffer[sgw->BufferPos] == ':' ) sgw->BufferPos++;
			}

			else if(sgw->IEvent->ie_Code == RAWKEY_TAB)  // Jump to prev/Next set of digits
			{
				sgw->WorkBuffer[sgw->BufferPos-1] = sgw->PrevBuffer[sgw->BufferPos-1];
				sgw->WorkBuffer[sgw->BufferPos] = sgw->PrevBuffer[sgw->BufferPos];
				if(sgw->IEvent->ie_Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT) )  // Jump to prev/Next set of digits
				{
					if(sgw->BufferPos==1) sgw->Actions &= ~SGA_USE;
					else while( (sgw->BufferPos >2) && (sgw->WorkBuffer[sgw->BufferPos]!=':') )
							sgw->BufferPos--;
					if( sgw->WorkBuffer[sgw->BufferPos] == ':' ) sgw->BufferPos -= 2;
				}
				else
				{
					if(sgw->BufferPos==sgw->StringInfo->NumChars-1) sgw->Actions &= ~SGA_USE;
					else while( (sgw->BufferPos < sgw->StringInfo->NumChars-3) && (sgw->WorkBuffer[sgw->BufferPos]!=':') )
							sgw->BufferPos++;
					if( sgw->WorkBuffer[sgw->BufferPos] == ':' ) sgw->BufferPos++;
				}
			}
			else sgw->Actions &= ~SGA_USE;
		}
		else if(sgw->EditOp == EO_MOVECURSOR)
		{
			if( sgw->WorkBuffer[sgw->BufferPos] == ':' )
				if(sgw->IEvent->ie_Code == RAWKEY_LEFT)
					sgw->BufferPos--;
				else
					sgw->BufferPos++;
		}
	if(*msg != SGH_CLICK)	ret=0;
	return(ret);
}

ULONG __saveds __asm hookEntry(register __a0 struct Hook *hookptr,
		register __a2 void *object,
		register __a1 void *message)
{
	ULONG	(*hookfn)(struct Hook *, struct SGWork *, ULONG *);
	hookfn=hookptr->h_SubEntry;
	return((*hookfn)(hookptr,object,message));
}

void initHook(struct Hook *hook,ULONG (*ccode)())
{
	hook->h_Entry = (unsigned long (* )())hookEntry;
	hook->h_SubEntry = ccode;
	hook->h_Data = 0;
}

// Attach TC hook to string gadget
void InstallTCHook(struct Gadget *sgad)
{
	struct StringExtend *SX = &TCExt;
	sgad->Activation=GACT_RELVERIFY|GACT_STRINGEXTEND;
	((struct StringInfo *)(sgad->SpecialInfo))->Extension=SX;
	((struct StringInfo *)(sgad->SpecialInfo))->BufferPos = 6; //0;
	SX->WorkBuffer = TCWorkBuf;
	SX->EditHook = &TCHook;
	// SX->Font = EditFont;
	SX->Font = TCFont;
	initHook(&TCHook,TC_HookFn);
}


__inline void	StringBorder(struct RastPort *RP, struct Gadget *Str)
{
	NewBorderBox(RP,Str->LeftEdge-4,Str->TopEdge-5,
		Str->LeftEdge+Str->Width+3,Str->TopEdge+Str->Height+2,BOX_REV_BORDER);
//		Str->LeftEdge+Str->Width+4-1,Str->TopEdge+Str->Height+4-1,BOX_REV_BORDER);
}

__inline void Divider(struct Window *w, UWORD	Y)
{
	Y -= PNL_DIV>>1;
	NewBorderBox(w->RPort,PNL_X1,Y,w->Width-PNL_X1,Y+PNL_DIV,BOX_REV);
}

#define RAIL_H 20
//*******************************************************************
VOID InitLRKnobRail(struct RastPort *RP,struct Gadget *Prop)
{
	LONG X,Y,X2,Y2;

	X = Prop->LeftEdge;
	X2 = Prop->LeftEdge+Prop->Width-1;
	Y = Prop->TopEdge ;
	if(Prop->Height > RAIL_H) Y+= ((Prop->Height - RAIL_H)>>1);
	else  Y -= ((RAIL_H - Prop->Height)>>1);
	Y2 = Y + RAIL_H - 1;

	SetAPen(RP,PAL_LBLACK);
	Move(RP,X-2,Y+1);
	Draw(RP,X-2,Y2-1);
	Move(RP,X-1,Y);
	Draw(RP,X-1,Y2-2);
	Move(RP,X2+1,Y+1);
	Draw(RP,X2+2,Y+1);
	Move(RP,X,Y);
	Draw(RP,X2,Y);
	Move(RP,X,Y+1);
	Draw(RP,X2,Y+1);

	SetAPen(RP,PAL_LGRAY);
	Move(RP,X-1,Y2-1);
	Draw(RP,X-1,Y2);
	Move(RP,X2+1,Y+2);
	Draw(RP,X2+1,Y2);
	Move(RP,X2+2,Y+1);
	Draw(RP,X2+2,Y2-1);
	Move(RP,X,Y2);
	Draw(RP,X2,Y2);
	Move(RP,X,Y2-1);
	Draw(RP,X2,Y2-1);
}


/*
 * SafeCalcNewPot -- Calculates a new Pot value based on 32 bit low/high/current values
 *                   This is 32-bit ready, which exceeds most math in Prop code!
 */
UWORD SafeCalcNewPot(struct Gadget *gad,ULONG current, ULONG low, ULONG high)
{
	ULONG A;
	UWORD Pot;

	/* Scale all values down so that 16 bit math will not break */
	while ((high - low) > 0xFFFF)
	{
		low >>= 1;
		high >>= 1;
		current >>= 1;
	}

	if (high - low)	// Avoid /0
	{
		A = ((current - low)*MAXPOT)/(high - low);
		Pot = A & 0xFFFF;
	}
	else
		Pot = 0;

	return(Pot);
}


//*******************************************************************
// converts HH:MM:SS:FF to LONG # of FRAMEs
VOID TimeToLong(char *T,ULONG *L)
{
	ULONG A = 0,B = 0,Z[5] = {0,0,0,0,0},*P,a;
	char c;
#ifdef SERDEBUG
	char *tt=T;
#endif
	P = Z;
	while (c = *T) {
		T++;
		if ((c >= '0') && (c <= '9')) {
			B *= 10;
			B += (c - '0');
		}
		if ((!(*T)) || (c == ':') || (c == ';') || (c == ' ') || (c == '.')) {
			*P++ = B;
			A++;
			if (A > 4) break;
			B = 0;
		}
	}
	if (A == 1) *L = Z[0];
	else if (A == 2) *L = Z[0]*30 + Z[1];
	else if (A == 3) *L = Z[0]*1800 + Z[1]*30 + Z[2];
	else if (A >= 4) *L = Z[0]*108000 + Z[1]*1800 + Z[2]*30 + Z[3];
	a=*L;
	if(UseDropFrame) *L=PickUpFrames(*L);

	if(a!=*L)
	{
		DUMPSTR("{T2L}		Time Code: ");
		DUMPSTR(tt);
		DUMPUDECL(" Frames: ",*L," ");
		DUMPUDECL("Time (Secs/30):",a,"\\");
	}

}


//*******************************************************************
// converts SMPTEinfo to LONG # of FRAMEs
ULONG SMPTEToLong(struct SMPTEinfo *si)
{
	ULONG L;

	if(!si->SMPTEvalid)
		return(0);
	L = si->SMPTEhours*108000 + si->SMPTEminutes*1800 +
			si->SMPTEseconds*30 + si->SMPTEframes;

	DUMPUDECB("SMPTE: ",si->SMPTEhours,"");
	DUMPUDECB(":",si->SMPTEminutes," ");
	DUMPUDECB(":",si->SMPTEseconds," ");
	DUMPUDECB(":",si->SMPTEframes," ");
	DUMPUDECL("= ",L," frames\\");
	if(si->SMPTEflags&SIF_DropFrame)
	{
		L=PickUpFrames(L);
		DUMPUDECL("After PickedUpFrames: ",L,"\\");
	}
	return(L);
}

// Add time to counters to account for longer frame times
// convert from 30 ticks/sec time to drop-frame SMPTE 29.97 fps
// drop 2 frames every minute... except the 10th
//
__inline ULONG DropFrames(ULONG	ticks)
{
// This formula is weak!  It starts drifting at about 20 minutes, and totally breaks
// at 2 hours, 12 minutes
//	ULONG	mins;
//	if(ticks>0)
//		if(mins=(18000*(ticks-1)/17981)/1800)
//			return( ticks + 2*((mins) - ((mins)/10)) );

	ULONG	frms,extra = 0;

	frms = ticks;

	// This formula is perfect, it will only break on time codes > 2.2 years!!!  JMF

	// Every 10 minutes, add 2 frms at 9 of the 10 minute crossings
	while (ticks >= 17982)
	{
		extra += 2*9;
		ticks -= 17982;
	}

	// Of the remaining time, add 2 frames every minute crossing
	if (ticks >= 2)
		extra += 2 * ((ticks-2)/1798);

	return(frms+extra);
}


ULONG PickUpFrames(ULONG	ticks)
{
	ULONG	mins;      // return(17981*ticks/18000);
	mins=ticks/1800;  // 60 secs/min * 30 frames/secs
	if(ticks>0)
		return( ticks - (mins*2) // drop 2 frames every minute
					+ 2*(mins/10)				// ... except the 10th
		);
	return(0);
}

//*******************************************************************
// Convert # of frames to SMPTE string -- HH:MM:SS:FF
VOID LongToTime(ULONG *L,char *T)
{
	ULONG F=0,M=0,S=0,H=0,a;
	if(L)
	{
		if(*L&0x80000000) *L=0;  // Watch for pesky signed LONGs, limit max time code

		if (UseDropFrame)
		{
			DUMPUDECL("DropFrames from ",*L," ");
			F=DropFrames(*L); // add extra time since frames last longer than 1/30
			DUMPUDECL("to ",F,"\\");
		}
		else
			F = *L;

		a=F;
		H = F/108000;
		F	%= 108000;
		M = F / 1800;  // 60 secs/min * 30 frames/secs
		F %= 1800;
		S = F / 30;
		F %= 30;
	}
	sprintf(T,"%02ld:%02ld:%02ld:%02ld",H,M,S,F);
	DUMPSTR("{L2T}		Time Code: ");
	DUMPSTR(T);
	DUMPUDECL(" Frames: ",*L," ");
	DUMPUDECL("Time (Secs/30):",a,"\\");
}

//*******************************************************************
// Convert # of frames to "SMPTE" length string -- SS:FF
VOID LongToLen(ULONG *L,char *T)
{
	ULONG A=0,C=0;

	if(L)
	{
		if(*L&0x80000000) *L=0;  // Watch for pesky signed LONGs, limit max time code
		A = *L;
		if(UseDropFrame) A=DropFrames(*L);
		C = A / 30;
		A %= 30;
	}
	sprintf(T,"%02ld:%02ld",C,A);
}



/****** GadgetHelp/InitStringExtend *********************************
*
*   NAME
*	InitStringExtend
*
*   SYNOPSIS
*	VOID InitStringExtend(struct TextFont *Font,UWORD Color0,UWORD Color2)
*
*   FUNCTION
*	initializes StringExtend structure for any AllocOneGadget() calls
*
*********************************************************************
*/
VOID InitStringExtend(struct TextFont *Font,UWORD Color0,UWORD Color2)
{
	PathExt.Pens[0] = Color0;
	PathExt.Pens[1] = Color2;
	PathExt.ActivePens[0] = Color0;
	PathExt.ActivePens[1] = Color2;
	PathExt.Font = Font;
}

/****** GadgetHelp/FindGadget *******************************************
*
*   NAME
*	FindGadget
*
*   SYNOPSIS
*	struct Gadget *FindGadget(struct Gadget *FirstGadget,UWORD GadgetID)
*
*   FUNCTION
*	Searches a linked list for a GadgetID
*
*********************************************************************
*/
struct Gadget *FindGadget(struct Gadget *FirstGadget,UWORD GadgetID)
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

/****** GadgetHelp/AllocGadgetIDS ***********************************
*
*   NAME
*	AllocGadgetIDList
*
*   SYNOPSIS
*	struct Gadget *AllocGadgetIDS(UWORD IDS[],struct Gadget *FirstGadget)
*
*   FUNCTION
*	Searches for all Gadget IDS in FirstGadget list,
*	clones them and creates new list, allocates
*	everything except any actual chip Image data
*
*	INPUTS
*	IDS - array of Gadget IDs, terminated with zero entry
*	FirstGadget - first gadget in list
*
*	RESULT
*	Returns gadget list, or NULL if out of memory,
*	or can't find a gadget
*
*********************************************************************
*/
struct Gadget *AllocGadgetIDS(UWORD IDS[],struct Gadget *FirstGadget)
{
	UWORD *ThisID;
	struct Gadget *NewList = NULL,*Source,*Clone,*LastClone;

	ThisID = &IDS[0];
	while (*ThisID) {
		if ((Source = FindGadget(FirstGadget,*ThisID))
			&& (Clone = AllocOneGadget(Source))) {
			if (!NewList) LastClone = NewList = Clone;
			else {
				LastClone->NextGadget = Clone;
				LastClone = Clone;
			}
		} else { // error
			if (NewList) {
				FreeGadgets(NewList);
				NewList = NULL;
			}
			goto Exit;
		}
		ThisID++;
	}
Exit:
	return(NewList);
}

#ifdef ASDFG
/****** GadgetHelp/AllocGadgetList **************************************
*
*   NAME
*	AllocGadgetList
*
*   SYNOPSIS
*	struct Gadget *AllocGadgetList(struct Gadget *FirstGadget)
*
*   FUNCTION
*	Clones existing Gadget list, allocates memory and copies
*	everything except any actual chip Image data
*
*	INPUTS
*	FirstGadget - first gadget in list
*	Font - TextFont to use for string gadgets
*
*	RESULT
*	Returns gadget list, or NULL if out of memory
*
*********************************************************************
*/
struct Gadget *AllocGadgetList(struct Gadget *FirstGadget)
{
	struct Gadget *SourceGadget,*PrevGadget = NULL,*ThisGadget = NULL,
		*Result = NULL;

	SourceGadget = FirstGadget;
	while (SourceGadget) {
		if (!(ThisGadget = AllocOneGadget(SourceGadget))) {
			FreeGadgets(Result);
			Result = NULL;
			goto Exit;
		}
		if (PrevGadget) PrevGadget->NextGadget = ThisGadget;
		else Result = ThisGadget;
		PrevGadget = ThisGadget;
		SourceGadget = SourceGadget->NextGadget;
	}
Exit:
	return(Result);
}
#endif

/****** GadgetHelp/AllocOneGadget ***************************************
*
*   NAME
*	AllocOneGadget
*
*   SYNOPSIS
*	struct Gadget *AllocOneGadget(struct Gadget *SourceGadget)
*
*   FUNCTION
*	Clones existing Gadget, allocates memory and copies
*	everything except any actual chip Image data
*
*********************************************************************
*/
struct Gadget *AllocOneGadget(struct Gadget *SourceGadget)
{
	struct Gadget *ThisGadget;
	struct StringInfo *SI;
	BOOL Success = FALSE;

	if (ThisGadget = (struct Gadget *)AllocMem(sizeof(struct Gadget),
		MEMF_PUBLIC)) {

		CopyMem(SourceGadget,ThisGadget,sizeof(struct Gadget));
		ThisGadget->NextGadget = NULL;
		ThisGadget->GadgetRender = NULL;
		ThisGadget->SelectRender = NULL;
		ThisGadget->GadgetText = NULL;
		ThisGadget->SpecialInfo = NULL;

		if (SourceGadget->GadgetRender &&
			((SourceGadget->Flags & GFLG_GADGIMAGE) ||
			SourceGadget->GadgetType == GTYP_PROPGADGET))
			if (!(ThisGadget->GadgetRender = (APTR)AllocImage(
				SourceGadget->GadgetRender))) goto Exit;

		if (SourceGadget->SelectRender &&
			(SourceGadget->Flags & GFLG_GADGHIMAGE))
			if (!(ThisGadget->SelectRender = (APTR)AllocImage(
				SourceGadget->SelectRender))) goto Exit;

		if (SourceGadget->SpecialInfo &&
			(SourceGadget->GadgetType == GTYP_PROPGADGET)) {
			if (!(ThisGadget->SpecialInfo = (APTR)AllocMem
				(sizeof(struct PropInfo),MEMF_PUBLIC))) goto Exit;
			CopyMem(SourceGadget->SpecialInfo,ThisGadget->SpecialInfo,
				sizeof(struct PropInfo));
		}

		if (SourceGadget->SpecialInfo &&
			(SourceGadget->GadgetType & GTYP_STRGADGET)) {
			if (!(ThisGadget->SpecialInfo=(APTR)AllocMem
				(sizeof(struct StringInfo),MEMF_PUBLIC|MEMF_CLEAR))) goto Exit;
			SI = (struct StringInfo *)ThisGadget->SpecialInfo;
			if(SourceGadget->Activation & GACT_LONGINT)
			{
				SI->MaxChars = 15;
				if (!(SI->Buffer = AllocMem(SI->MaxChars, MEMF_PUBLIC|MEMF_CLEAR)))
					goto Exit;
				if (!(SI->UndoBuffer = AllocMem(SI->MaxChars, MEMF_PUBLIC|MEMF_CLEAR)))
					goto Exit;
			}
			else
			{
				if (!(SI->Buffer = AllocMem(MAX_STRING_BUFFER+1,
					MEMF_PUBLIC|MEMF_CLEAR))) goto Exit;
				if (!(SI->UndoBuffer = AllocMem(MAX_STRING_BUFFER+1,
					MEMF_PUBLIC|MEMF_CLEAR))) goto Exit;
				SI->MaxChars = MAX_STRING_BUFFER+1;
			}

			ThisGadget->Flags |= GFLG_STRINGEXTEND|GFLG_GADGHCOMP;
			SI->Extension = &PathExt;
		}
		Success = TRUE;
Exit:
		if (!Success) {
			FreeGadgets(ThisGadget);
			ThisGadget = NULL;
		}
	}
	return(ThisGadget);
}

/****** GadgetHelp/AllocImage **************************************
*
*   NAME
*	AllocImage
*
*   SYNOPSIS
*	struct Image *AllocImage(struct Image *SourceImage)
*
*   FUNCTION
*
*	INPUTS
*
*	RESULT
*
*********************************************************************
*/
struct Image *AllocImage(struct Image *SourceImage)
{
	struct Image *Image = NULL;

	Image = (struct Image *)AllocMem(sizeof(struct Image),MEMF_PUBLIC);
	if (Image) {
		CopyMem(SourceImage,Image,sizeof(struct Image));
		Image->NextImage = NULL;
	}
	return(Image);
}

/****** GadgetHelp/AllocBorders *************************************
*
*   NAME
*	AllocBorders
*
*   SYNOPSIS
*	struct Border *AllocBorders(UWORD X1,UWORD Y1,UWORD X2,UWORD Y2,BOOL Inny,
*	BOOL LeftEdge,UWORD Color0,UWORD Color2,UWORD Color3)
*
*   FUNCTION
*
*	INPUTS
*	if LeftEdge, user wants light grey padding on left side for string gadget
*	if Inny, border appears to be pushed in (reverse shadow)
*
*	RESULT
*	pointer to 2 or 3 linked Border structures, or NULL if out of memory
*
*********************************************************************
*/
struct Border *AllocBorders(WORD X1,WORD Y1,WORD X2,WORD Y2,BOOL Inny,
	BOOL LeftEdge,UWORD Color0,UWORD Color2,UWORD Color3)
{
	struct Border *B1 = NULL,*B2 = NULL,*B3 = NULL;
	BOOL Success = FALSE;
	WORD *XY;

	if (!(B1 = (struct Border *)AllocMem(sizeof(struct Border),MEMF_CLEAR|
		MEMF_PUBLIC))) return(NULL);
	if (!(B2 = (struct Border *)AllocMem(sizeof(struct Border),MEMF_CLEAR|
		MEMF_PUBLIC))) goto Exit;
	B1->NextBorder = B2; // do now so error routine can free B2

	if (LeftEdge) {
		if (!(B3 = (struct Border *)AllocMem(sizeof(struct Border),MEMF_CLEAR|
			MEMF_PUBLIC))) goto Exit;
		B2->NextBorder = B3;
		if (!(B3->XY = (WORD *)AllocMem(LEFT_COUNT*4,MEMF_PUBLIC))) goto Exit;
		B3->FrontPen = Color2;
		B3->DrawMode = JAM2;
		B3->Count = LEFT_COUNT;
	}

	if (Inny) {
		B1->FrontPen = Color0;
		B2->FrontPen = Color3;
	} else {
		B1->FrontPen = Color3;
		B2->FrontPen = Color0;
	}

	B1->DrawMode = B2->DrawMode = JAM2;
//	B1->Count = B2->Count = BORDER_COUNT;
	B1->Count = B2->Count = BORDER_COUNT + 1;
	if (!(B1->XY = (WORD *)AllocMem(B1->Count*4,MEMF_PUBLIC))) goto Exit;
	if (!(B2->XY = (WORD *)AllocMem(B2->Count*4,MEMF_PUBLIC))) goto Exit;

	if (LeftEdge) {
		XY = B3->XY;
		XY[0] = X1+2;	XY[1] = Y1+2;
		XY[2] = X1+2;	XY[3] = Y2-2;
		XY[4] = X1+3;	XY[5] = Y2-2;
		XY[6] = X1+3;	XY[7] = Y1+2;
	}

//	CalculateBorder(B1,X1,Y1,X2,Y2);
	CalculateRoundBorder(B1,X1,Y1,X2,Y2);
	Success = TRUE;
Exit:
	if (!Success) {
		FreeBorders(B1);
		B1 = NULL;
	}
	return(B1);
}

/****** GadgetHelp/CalculateBorder **********************************
*
*   NAME
*	CalculateBorder
*
*   SYNOPSIS
*	VOID CalculateBorder(struct Border *B1,UWORD X1,UWORD Y1,UWORD X2,
*	UWORD Y2)
*
*   FUNCTION
*	Calculates B1->XY array
*
*	INPUTS
*
*	RESULT
*
*********************************************************************
*/
VOID CalculateBorder(struct Border *B1,WORD X1,WORD Y1,WORD X2,WORD Y2)
{
	WORD *XY;

	XY = B1->XY;
	XY[0] = X1+1;	XY[1] = Y2-1;
	XY[2] = X1+1;	XY[3] = Y1+1;
	XY[4] = X2-1;	XY[5] = Y1+1;
	XY[6] = X2;		XY[7] = Y1;
	XY[8] = X1;		XY[9] = Y1;
	XY[10] = X1;	XY[11] = Y2;

	XY = B1->NextBorder->XY;
	XY[0] = X1+2;	XY[1] = Y2-1;
	XY[2] = X2-1;	XY[3] = Y2-1;
	XY[4] = X2-1;	XY[5] = Y1+2;
	XY[6] = X2;		XY[7] = Y1+1;
	XY[8] = X2;		XY[9] = Y2;
	XY[10] = X1+1;	XY[11] = Y2;
}

VOID CalculateRoundBorder(struct Border *B1,WORD X1,WORD Y1,WORD X2,WORD Y2)
{
	WORD *XY;

	XY = B1->XY;
	XY[0] = X1+1;		XY[1] = Y2-1;
	XY[2] = X1+1;		XY[3] = Y1+1;
	XY[4] = X2-1;		XY[5] = Y1+1;
	XY[6] = X2-1;		XY[7] = Y1;
	XY[8] = X1+1;		XY[9] = Y1;
	XY[10]= X1;			XY[11]= Y1+1;
	XY[12]= X1;			XY[13]= Y2-1;

	XY = B1->NextBorder->XY;
	XY[0] = X1+2;		XY[1] = Y2-1;
	XY[2] = X2-1;		XY[3] = Y2-1;
	XY[4] = X2-1;		XY[5] = Y1+2;
	XY[6] = X2;			XY[7] = Y1+2;
	XY[8] = X2;			XY[9] = Y2-1;
	XY[10]= X2-1;		XY[11]= Y2;
	XY[12]= X1+1;		XY[13]= Y2;
}

/****** GadgetHelp/FreeBorders **************************************
*
*   NAME
*	FreeBorders
*
*   SYNOPSIS
*	VOID FreeBorders(struct Border *Border)
*
*   FUNCTION
*	Frees border list
*
*	INPUTS
*
*	RESULT
*
*********************************************************************
*/
VOID FreeBorders(struct Border *Border)
{
	if (Border) {
		if (Border->NextBorder) FreeBorders(Border->NextBorder);
		if (Border->XY) FreeMem(Border->XY,Border->Count*4);
		FreeMem(Border,sizeof(struct Border));
	}
}

/****** GadgetHelp/FreeStringInfo ***********************************
*
*   NAME
*	FreeStringInfo
*
*   SYNOPSIS
*	VOID FreeStringInfo(struct Gadget *ThisGadget)
*
*   FUNCTION
*	Frees string info structure, Buffer, and UndoBuffer
*
*	INPUTS
*
*	RESULT
*
*********************************************************************
*/
VOID FreeStringInfo(struct Gadget *ThisGadget)
{
	struct StringInfo *SI;

	SI = (struct StringInfo *)ThisGadget->SpecialInfo;
	if (SI) {
		if (SI->Buffer) FreeMem(SI->Buffer,SI->MaxChars);
		if (SI->UndoBuffer) FreeMem(SI->UndoBuffer,SI->MaxChars);
		FreeMem(SI,sizeof(struct StringInfo));
	}
}

/****** GadgetHelp/AllocIntuiText ***********************************
*
*   NAME
*	AllocIntuiText
*
*   SYNOPSIS
*	struct IntuiText *AllocIntuiText(UWORD FrontPen,UWORD BackPen,
*		UWORD LeftEdge, UWORD TopEdge)
*
*   FUNCTION
*
*	INPUTS
*
*	RESULT
*	IText size set to MAX_INTUI_BUFFER
*
*********************************************************************
*/
struct IntuiText *AllocIntuiText(UWORD FrontPen,UWORD BackPen,
	UWORD LeftEdge, UWORD TopEdge, char *Text)
{
	struct IntuiText *IT = NULL;

	if (IT = AllocMem(sizeof(struct IntuiText),MEMF_CLEAR|MEMF_PUBLIC)) {
		IT->FrontPen = FrontPen;
		IT->BackPen = BackPen;
		IT->DrawMode = JAM2;
		IT->LeftEdge = LeftEdge;
		IT->TopEdge = TopEdge;
		if (!(IT->IText = AllocMem(MAX_INTUI_BUFFER+1,MEMF_CLEAR|MEMF_PUBLIC)))
		{
			FreeIntuiText(IT);
			return(NULL);
		}
		if(*Text) strncpy(IT->IText,Text,MAX_INTUI_BUFFER);
	}
	return(IT);
}

/****** GadgetHelp/FreeIntuiText ************************************
*
*   NAME
*	FreeIntuiText
*
*   SYNOPSIS
*	VOID FreeIntuiText(struct IntuiText *IT)
*
*   FUNCTION
*
*	INPUTS
*
*	RESULT
*
*********************************************************************
*/
VOID FreeIntuiText(struct IntuiText *IT)
{
	if (IT) {
		if (IT->NextText) FreeIntuiText(IT->NextText);
		if (IT->IText) FreeMem(IT->IText,MAX_INTUI_BUFFER+1);
		FreeMem(IT,sizeof(struct IntuiText));
	}
}

/****** GadgetHelp/FreeGadgets **************************************
*
*   NAME
*	FreeGadgets
*
*   SYNOPSIS
*	VOID FreeGadgets(struct Gadget *FirstGadget)
*
*   FUNCTION
*	Frees gadget list and all related structures (except actual
*	Image structure chip data)
*
*********************************************************************
*/
VOID FreeGadget(struct Gadget *Gadget)
{
		if (Gadget->GadgetRender) {
			if ((Gadget->Flags & GFLG_GADGIMAGE) ||
			(Gadget->GadgetType == GTYP_PROPGADGET))
				FreeMem(Gadget->GadgetRender,sizeof(struct Image));
			else if(!(Gadget->Flags & GFLG_GADGIMAGE))
				FreeBorders(Gadget->GadgetRender);
		}

		if (Gadget->SelectRender)
		{
			if(Gadget->Flags & GFLG_GADGIMAGE)
				FreeMem(Gadget->SelectRender,sizeof(struct Image));
			else if(Gadget->Flags & GFLG_GADGHIMAGE)
				FreeBorders(Gadget->SelectRender);
		}

		if (Gadget->SpecialInfo && (
			Gadget->GadgetType == GTYP_PROPGADGET)) FreeMem(
			Gadget->SpecialInfo,sizeof(struct PropInfo));

		if (Gadget->SpecialInfo && (
			Gadget->GadgetType == GTYP_STRGADGET))
				FreeStringInfo(Gadget);

		if (Gadget->GadgetText) FreeIntuiText(Gadget->GadgetText);

		FreeMem(Gadget,sizeof(struct Gadget));
}

VOID gh_FreeGadgets(struct Gadget *FirstGadget)
{
	FreeGadgets(FirstGadget);
}

VOID FreeGadgets(struct Gadget *FirstGadget)
{
	struct Gadget *ThisGadget,*NextGadget;

	ThisGadget = FirstGadget;
	while (ThisGadget) {
		NextGadget = ThisGadget->NextGadget;
		FreeGadget(ThisGadget);
		ThisGadget = NextGadget;
	}
}

/****** GadgetHelp/ImageToBitMap ************************************
*
*   NAME
*	ImageToBitMap
*
*   SYNOPSIS
*	BOOL ImageToBitMap(struct Image *Image,struct BitMap *BitMap)
*
*   FUNCTION
*	Converts Image structure to an empty BitMap structure,
*	(both structures must already be allocated, and Image->ImageData
*	must be valid)
*
*********************************************************************
*/
BOOL ImageToBitMap(struct Image *Image,struct BitMap *BitMap)
{
	BOOL Success = FALSE;
	UBYTE *Plane;
	ULONG PlaneSize;
	UWORD a;

	if (Image && BitMap) {
		BitMap->BytesPerRow = ((Image->Width + 15)/16)*2;
		BitMap->Rows = Image->Height;
		BitMap->Flags = 0;
		BitMap->Depth = Image->Depth;

		PlaneSize = BitMap->BytesPerRow * BitMap->Rows;
		Plane = (UBYTE *)Image->ImageData;
		for (a=0; a < Image->Depth; a++) {
			BitMap->Planes[a] = Plane;
			Plane += PlaneSize;
		}
		Success = TRUE;
	}
	return(Success);
}

/****** Grazer/UpdateStringGadgetText *******************************
*
*   NAME
*	UpdateStringGadgetText
*
*   SYNOPSIS
*	BOOL UpdateStringGadgetText(struct Window *Window,struct Gadget *Gadget,
*		char *Text)
*
*   FUNCTION
*	Changes text in string gadget, does not redraw gadget
*
*********************************************************************
*/
BOOL UpdateStringGadgetText(struct Window *Window,struct Gadget *Gadget,
	char *Text)
{
	BOOL Success = FALSE;
	UWORD Position;
	UBYTE *Buffer;
	struct StringInfo *SI;
	ULONG l;

	if (Gadget && Text) {
		SI = ((struct StringInfo *)Gadget->SpecialInfo);
		Buffer = SI->Buffer;
		Position = RemoveGadget(Window,Gadget);
		strncpy(Buffer,Text,SI->MaxChars-1);
		l = strlen(Buffer);
		SI->BufferPos = l;
		if (l > (SI->DispCount-1)) SI->DispPos = l-(SI->DispCount-1);
		else SI->DispPos = 0;
		DUMPUDECW("StrGad: ",l," ");
		DUMPMSG(Buffer);
		if (Position != -1) {
			AddGadget(Window,Gadget,Position);
			Success = TRUE;
		}
	}
	return(Success);
}

// end of gadgethelp.c
