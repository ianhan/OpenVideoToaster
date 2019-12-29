/********************************************************************
* $EditWindow.c$
* $Id: editwindow.c,v 2.67 1997/04/02 12:47:46 MIKE Exp $
* $Log: editwindow.c,v $
*Revision 2.67  1997/04/02  12:47:46  MIKE
*got es_message ready to recieve new command -- ES_REDRAW_ALL --
*
*Revision 2.66  1995/06/14  14:53:46  pfrench
*Moved FrameSave command to end of EndGrazRequest
*
*Revision 2.65  1995/03/16  14:36:12  CACHELIN4000
**** empty log message ***
*
*Revision 2.64  1995/03/02  12:34:38  pfrench
*Added switcher un-used rawkey handling code
*
*Revision 2.63  1995/02/20  16:11:42  pfrench
*Now properly responds to locate file.
*
*Revision 2.62  1995/02/20  13:46:11  pfrench
*Made path greater again now that we've got some global
*data moved into the far section.
*
*Revision 2.61  1995/02/19  16:50:16  pfrench
*temporarily un-sized editwindow request buffer size
*
*Revision 2.60  1995/02/18  19:08:16  Kell
*Moved the SetEditDepth call in Render_EDIT handling so it would also happen before windows are opened.
*
*Revision 2.59  1995/02/17  17:07:58  pfrench
*Added check for global edit depth
*
*Revision 2.58  1995/02/17  16:39:31  pfrench
*Added tons o' stuff for skell
*
*Revision 2.57  1995/02/17  15:06:58  pfrench
*Now reply's to messageport of save file initiator
*
*Revision 2.56  1995/02/17  14:21:14  pfrench
*modified text of locate file requester
*
*Revision 2.55  1995/02/17  14:20:11  pfrench
*Added support for es_locatefile messages from switcher
*
*Revision 2.54  1994/12/31  03:31:27  pfrench
*Now SendSwitcher does same thing as sendswitcherreply, without
*the return value
*
*Revision 2.53  1994/12/30  18:45:44  CACHELIN4000
*Comment out weird Msg->Error=NULL which seems to cause 2000 to have timing dependent communication problems.
*
*Revision 2.52  1994/12/23  14:41:00  pfrench
*Slight optimization in FlushWindowPort()
*
*Revision 2.51  1994/12/21  23:31:09  pfrench
*Tried to fix visual ickyness with directory tabs/crouton border.
*
*Revision 2.50  1994/12/21  23:16:04  pfrench
*Removed explicit rendering calls from directory tabs,
*as the text is now being handled by intuition.
*
*Revision 2.49  1994/12/21  21:31:02  pfrench
*Hopefully final tweaking of grid position
*
*Revision 2.48  1994/12/21  20:05:15  pfrench
*Added Directory tabs images
*
*Revision 2.47  1994/12/20  19:38:35  CACHELIN4000
*Only use close gadget in Arrange() with grazer windows
*
*Revision 2.46  1994/12/19  22:39:14  pfrench
*Modified for now shared-code proof.library.
*
*Revision 2.45  1994/12/17  04:50:44  Kell
*Removed ES_FlyerVolumes handling.  This is now sent to the Switcher, instead of recieved from the Switcher.
*
*Revision 2.44  1994/12/09  15:38:59  pfrench
*Cleaned up a few things while fixing wbtofront/back
*
*Revision 2.43  1994/12/08  13:25:30  CACHELIN4000
*Change Vertical Slider width and position
*
*Revision 2.42  1994/11/15  17:50:26  pfrench
*Added support to highlight delayed error croutons when
*the error is posted, and not before.
*
*Revision 2.41  1994/11/09  12:46:40  pfrench
*Added initial support for proof.lib
*
*Revision 2.40  1994/10/21  23:22:40  CACHELIN4000
**** empty log message ***
*
*Revision 2.39  94/10/17  14:33:55  CACHELIN4000
*Correct SwitcherOn test&toggle in SwitcherSwitch
*
*Revision 2.37  94/10/14  13:36:55  CACHELIN4000
**** empty log message ***
*
*Revision 2.36  94/10/14  09:52:56  CACHELIN4000
*Add ES_FlyerVolumes support to HandleSwitcher()
*
*Revision 2.35  94/10/12  18:56:19  CACHELIN4000
*Fix call to DisplayMessage()
*
*Revision 2.34  94/09/23  20:08:24  pfrench
*Moved loadslice to main event loop
*
*Revision 2.33  1994/09/21  21:32:47  pfrench
*Added new FlushWindowPort call
*
*Revision 2.32  1994/09/20  22:46:29  pfrench
*No longer initializes its own FG list as that is done
*through the dir cache.
*
*Revision 2.31  1994/09/08  15:40:55  pfrench
*Added support for refreshing the accesswindow
*
*Revision 2.30  1994/09/02  01:34:45  pfrench
*Now gets delay time from msg->Error.
*
*Revision 2.29  1994/09/01  23:50:14  pfrench
*Added temporary delayed message stuff
*
*Revision 2.28  1994/09/01  22:27:03  pfrench
*Added DelayedError timer.device message handling
*
*Revision 2.27  1994/09/01  18:41:42  pfrench
*Fixed problems with ESMessage allocation/free
*
*Revision 2.26  1994/09/01  18:29:15  pfrench
*put preliminary support for delayed error messages.
*
*Revision 2.25  1994/08/31  23:07:52  Kell
*new debugs
*
*Revision 2.24  1994/08/30  16:24:45  pfrench
*Fixed mungwall hit with message allocation
*
*Revision 2.23  1994/08/30  10:35:59  Kell
*Changed SendSwitcherReply(), SendSwitcher() and PutSwitcher() to work with ESParams structures so we can easily work with any number of parameters.
*
*Revision 2.22  1994/08/27  00:19:20  CACHELIN4000
**** empty log message ***
*
*Revision 2.21  94/07/08  10:11:16  CACHELIN4000
*replace SendSwitcher() with PutSwitcher() in SendSwitcherReply(),
*
*Revision 2.20  94/07/07  17:00:50  CACHELIN4000
*Fix Message bug w/ LastMsg global in HandleSwitcher()
*
*Revision 2.19  94/07/07  00:42:46  CACHELIN4000
*SnedSwitcherReply --> register args
*
*Revision 2.18  94/07/04  18:37:15  CACHELIN4000
**** empty log message ***
*
*Revision 2.17  94/06/04  02:27:21  Kell
*Went back to the using SIMPLE_REFRESH on the edit windows. Necessary!!
*When leaving switcher mode, the editor now waits on the switcher.
*
*Revision 2.16  94/06/03  19:52:36  Kell
*Restored the edit windows SIMPLE_REFRESH (killed a bad idea)
*
*Revision 2.15  94/06/03  19:02:13  CACHELIN4000
*remove window's WFLG_SIMPLE_REFRESH
*
*Revision 2.14  94/04/22  14:31:39  CACHELIN4000
**** empty log message ***
*
*Revision 2.13  94/03/17  09:52:43  Kell
**** empty log message ***
*
*Revision 2.12  94/03/15  14:57:54  Kell
**** empty log message ***
*
*Revision 2.11  94/03/15  13:46:11  CACHELIN4000
**** empty log message ***
*
*Revision 2.10  94/03/15  13:40:09  CACHELIN4000
*Eliminate DefaultFG = internalcroutons from ES_STARTUP
*
*Revision 2.9  94/03/13  07:54:41  Kell
*Reworked the way debug statements work.  Added ES_QUIT handler.
*
*Revision 2.8  94/03/11  14:55:35  Kell
**** empty log message ***
*
*Revision 2.7  94/03/11  14:38:30  CACHELIN4000
**** empty log message ***
*
*Revision 2.6  94/03/11  14:30:15  Kell
*Added some debug statements
*
*Revision 2.5  94/03/11  09:32:09  Kell
**** empty log message ***
*
*Revision 2.4  94/03/05  21:05:14  CACHELIN4000
**** empty log message ***
*
*Revision 2.3  94/02/28  18:10:40  CACHELIN4000
**** empty log message ***
*
*Revision 2.2  94/02/23  14:52:22  Kell
**** empty log message ***
*
*Revision 2.1  94/02/19  09:34:15  Kell
**** empty log message ***
*
*Revision 2.0  94/02/17  16:23:50  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  15:56:50  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  14:44:08  Kell
*FirstCheckIn
*
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	12-17-92	Steve H		Convert to use SmartStrings
*	12-8-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <stdio.h>
#include <string.h>

#include <rexx/storage.h>       /* off of ARexx disk */
// #include <rexx/rxslib.h>        /* off of ARexx disk */
// #include <rexx/errors.h>

#include <editwindow.h>
#include <gadgets.h>
#include <prophelp.h>
#include <editswit.h>
#include <delayerr.h>
#include <crouton_all.h>

#ifndef PROOF_LIB_H
#include <proof_lib.h>
#endif

#include <dirtabs.h>
#include <croutongrid.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#ifndef PROTO_PASS
#include <proto.h>
#endif

#ifdef CUSTOM_BODY
#include <customprop.p>
#endif

/****************************************/
//#define SERDEBUG	1
#include <serialdebug.h>

#define DBHMSG NA("HandleSwitcher")
/****************************************/
#define REG(x) register __##x

VOID DumpRP(UBYTE *);

extern struct IntuiMessage	global_sw_im;
extern struct Library *ProofBase;
extern struct Window *access_win;
extern struct FastGadget **DefaultFG;
extern struct Gadget Gadget1,*FT_Gadget1,*GRZ_Gadget1;
extern struct List WindowList;
extern struct EditWindow *EditTop,*EditBottom;
extern struct Screen *EditScreen;
extern struct MsgPort *EditPort,*SwitPort;
extern struct TextFont *EditFont;
extern struct Window *SwitWind;
extern struct MsgPort *DelayedErrMsgPort;
extern struct DelayedErrorRequest *global_der;
extern BOOL DelayedErrorPending;
extern struct AccessWindow *global_aw;

extern struct ESParams1 ESparams1;
extern struct ESParams5 ESparams5;
extern UBYTE *FlyerDrives[];
extern LONG FlyerDriveCount;
#define ICON_WIDTH 80
#define MAX_UWORD 65535
#define LEFT_EDGE 8		// LeftEdge of leftmost gadget in relation to window

extern VOID KPutStr(char *String);
extern LONG KPrintF( STRPTR fmt, ... );

extern VOID SoftSpriteOn(VOID);
extern VOID SoftSpriteOff(VOID);

BOOL SwitcherOn = TRUE;
LONG global_EditScreenDepth;

//extern struct ESMessage OurESMessage;

extern struct Hook DummyHook;
struct TagItem nw_ti[2] = {
	{ WA_BackFill,(ULONG)&DummyHook },
	{ TAG_DONE,TRUE }
};
struct ExtNewWindow NewWindowStructure3 = {
	0,0,	/* window XY origin relative to TopLeft of screen */
	640,400,	/* window width and height */
	0,1,	/* detail and block pens */
	NEWSIZE+MOUSEBUTTONS+MOUSEMOVE+GADGETDOWN+GADGETUP+RAWKEY+REQCLEAR+DISKINSERTED+DISKREMOVED,	/* IDCMP flags */
	WFLG_SIMPLE_REFRESH+BORDERLESS+ACTIVATE+RMBTRAP+WFLG_NW_EXTENDED,	/* other window flags */
	&Gadget1,	/* first gadget in gadget list */
	NULL,	/* custom CHECKMARK imagery */
	NULL,	/* window title */
	NULL,	/* custom screen pointer */
	NULL,	/* custom bitmap */
	5,5,	/* minimum width and height */
	640,600,	/* maximum width and height */
	CUSTOMSCREEN,	/* destination screen type */
	&nw_ti[0]
};

static ULONG global_LocateFileType;
static ULONG global_LocateFileFlags;
static ULONG global_LocateFileMode;
static struct MsgPort *global_LocateFile_mp;
static STRPTR global_LocateFileName;
static STRPTR *global_LocateFileTxt;
LONG global_do_locatefile;

extern struct FastGadget **PtrProject;
extern struct FastGadget **XtrProject;

LONG SetEditDepth( LONG depth );
BOOL __regargs HandleErrPort( struct MsgPort *Port );

struct ESMessage __asm *PutESPort(
	REG(d0) WORD Type, REG(d1) LONG *D1, REG(a0) struct MsgPort *mp );

static BOOL __regargs HandleSwitcherReply(
	struct MsgPort *Port, struct ESMessage *lastmsg, LONG *pLastReply );

LONG do_LocateFileRequest( void );
static LONG EndLocateFileRequest( struct GrazerRequest *gr, LONG mode );

#ifdef LATER
static struct ESMessage *GetOnlyMsg(
	struct MsgPort *mp, struct ESMessage *lastmsg );
#endif

/****** EditWindow/OpenEditWindow *************************************
*
*   NAME
*	OpenEditWindow
*
*   SYNOPSIS
*	BOOL OpenEditWindow(struct EditWindow *Edit)
*
*   FUNCTION
*
*
*********************************************************************
*/
BOOL OpenEditWindow(struct EditWindow *Edit)
{
	struct ExtNewWindow *NW;
	BOOL Success = FALSE;
	struct Gadget *Gadget;
	struct PropInfo *PropInfo=NULL;

	NW = &NewWindowStructure3; 	// uses NewWindow from powerwindows output
	NW->FirstGadget = NULL; 	// don't add until after open
	NW->DetailPen = SCREEN_PEN;
	NW->Screen = Edit->Screen;
	NW->LeftEdge = 0;// Edit->LeftEdge;
	NW->TopEdge = Edit->TopEdge;

#ifndef SWIT_ONLY
	if (SwitPort) {
#endif
	NW->LeftEdge = 32;
	NW->TopEdge += 44;
#ifndef SWIT_ONLY
	}
#endif

	NW->Width = Edit->Width;
	NW->Height = Edit->Height;

// note that NW->IDCMPFlags set in HandleCommon.c

	if (Gadget = FindGadget(Edit->Gadgets,ID_KNOB)) {
		PropInfo = Gadget->SpecialInfo;
		PropInfo->VertPot = 0; // always open at top
	}

// first open as SIMPLE_REFRESH
	Edit->Window = OpenWindow((struct NewWindow *)NW);

// then make SMART_REFRESH (to get around clear to color 0 problem)
	if (Edit->Window)
	{
		if ( Edit->ew_cg )
		{
			struct Gadget *Grid;

			Grid = FindGadget(Edit->Gadgets,ID_GRID);

			ob_SetAttrs( Edit->ew_cg,
				CRGRIDA_DestLeft,		Edit->Window->LeftEdge + Grid->LeftEdge,
				CRGRIDA_DestTop,		Edit->Window->TopEdge + Grid->TopEdge,
				CRGRIDA_DestWidth,	Grid->Width,
				CRGRIDA_DestHeight,	Grid->Height,
				TAG_DONE );
		}

		MakeSimpleSmart(Edit->Window);
		SetFont(Edit->Window->RPort,EditFont);
		AddGList(Edit->Window,Edit->Gadgets,0,MAX_UWORD,NULL);

		if (Success = RenderEditWindow(Edit,TRUE))
			BuildWaitMask();
	}
	return(Success);
}

/****** EditWindow/RenderEditWindow *********************************
*
*   NAME
*	RenderEditWindow
*
*   SYNOPSIS
*	BOOL RenderEditWindow(struct EditWindow *Edit,BOOL Erase)
*
*   FUNCTION
*	Does everything needed to render entire EditWindow
*
*********************************************************************
*/
BOOL RenderEditWindow(struct EditWindow *Edit,BOOL Erase)
{
	BOOL Success = FALSE;

	if ( global_EditScreenDepth )
	{
		struct Gadget *Gadget;
		struct RastPort *RP;

		RP = Edit->Window->RPort;
		if (Erase) {
			SetRast(Edit->Window->RPort,SCREEN_PEN);
		}

		if (Gadget = FindGadget(Edit->Gadgets,ID_PATH)) {
			NewBorderBox(RP,Gadget->LeftEdge-4,Gadget->TopEdge-2-3,
				Gadget->LeftEdge+Gadget->Width+3,
				Gadget->TopEdge+Gadget->Height+4-1,BOX_REV_BORDER);
		}

		if (Gadget = FindGadget(Edit->Gadgets,ID_GRID))
		{
			if ( Edit->Node.Type == EW_GRAZER )
			{
				/* Draw Outer border containing directory tabs, then... */

				NewBorderBox(RP,Gadget->LeftEdge-2,Gadget->TopEdge-2,
					Gadget->LeftEdge+Gadget->Width+1,
					Gadget->TopEdge+Gadget->Height+1+16+8,BOX_REV);
			}

			NewBorderBox(RP,Gadget->LeftEdge-2,Gadget->TopEdge-2,
				Gadget->LeftEdge+Gadget->Width+1,
				Gadget->TopEdge+Gadget->Height+1,BOX_REV);
		}

		RefreshGList(Edit->Gadgets,Edit->Window,NULL,MAX_UWORD);
		RedrawPopupText(Edit);
		InitKnobRail(Edit);
		DrawKnobRail(Edit); // don't want to wait
		Edit->DisplayGrid = TRUE;
		Edit->RenderRail = FALSE;
	}

	Success = TRUE;
	return(Success);
}

/****** EditWindow/CloseEditWindow **********************************
*
*   NAME
*	CloseEditWindow
*
*   SYNOPSIS
*	VOID CloseEditWindow(struct EditWindow *Edit)
*
*   FUNCTION
*
*
*********************************************************************
*/
VOID CloseEditWindow(struct EditWindow *Edit)
{
	if (Edit) {
		if (Edit->Window) {
			CloseWindow(Edit->Window);
			Edit->Window = NULL;
			BuildWaitMask();
		}
	}
}

/****** EditWindow/InitEditWindow *************************************
*
*   NAME
*	InitEditWindow
*
*   SYNOPSIS
*	BOOL InitEditWindow(struct EditWindow *Edit,struct NewEditWindow *New)
*
*   FUNCTION
*	First time setup of EditWindow structure - assumed to be cleared
*
*********************************************************************
*/
BOOL InitEditWindow(struct EditWindow *Edit,struct NewEditWindow *New)
{
	BOOL Success = FALSE;

	if (Edit && New && Edit->Special) {

		AddTail(&WindowList,(struct Node *)&Edit->Node.MinNode);
		NewList(&Edit->DragList);

		if (New->Options & OPTION_ALLOW_DRAG) Edit->AllowDrag = TRUE;
		Edit->Screen = New->Screen;
		Edit->Location = New->Location;
		Edit->IconWidth = ICON_WIDTH;
		Edit->IconHeight = ICON_HEIGHT;
		Edit->LeftEdge = New->LeftEdge;
		Edit->TopEdge = New->TopEdge;
		Edit->Width = New->Width;
		Edit->Height = New->Height;

		Success = TRUE;
	}
	return(Success);
}

/****** EditWindow/FreeEditWindow *************************************
*
*   NAME
*	FreeEditWindow
*
*   SYNOPSIS
*	VOID FreeEditWindow(struct EditWindow *Edit)
*
*   FUNCTION
*	Frees EditWindow stuff,
*	Does NOT free Edit->Special or Special->EditList or EditWindow itself
*
*********************************************************************
*/
VOID FreeEditWindow(struct EditWindow *Edit)
{
	if (Edit) {
		if (Edit->Gadgets) FreeGadgets(Edit->Gadgets);
		Remove((struct Node *)&Edit->Node.MinNode); // from WindowList
		FreeGrid(Edit);
	}
}

/****** EditWindow/AllocEditNode ******************************************
*
*   NAME
*	AllocEditNode
*
*   SYNOPSIS
*	struct EditNode *AllocEditNode(struct SmartString *Name)
*
*   FUNCTION
*	The Name SmartString is duplicated into the EditNode.
*	Therefore, you must still free Name yourself.
*
*********************************************************************
*/
struct EditNode *AllocEditNode(struct SmartString *Name)
{
	struct EditNode *Node;

	if (Node = (struct EditNode *)AllocSmartNode(Name,sizeof(struct EditNode),
		MEMF_CLEAR)) {
		Node->Node.Type = EN_STANDARD;
		Node->Redraw = TRUE;
	}
	return(Node);
}

/****** EditWindow/ArrangeEditGadgets **********************************
*
*   NAME
*	ArrangeEditGadgets
*
*   SYNOPSIS
*	BOOL ArrangeEditGadgets(struct EditWindow *Edit)
*
*   FUNCTION
*	Positions [ID_CLOSE],ID_KNOB,ID_UP,ID_DOWN gadgets,
*	Initializes ID_GRID's LeftEdge, and Width
*	(TopEdge,Height must be initialized before calling this routine)
*
*********************************************************************
*/
#define DOWN_BTM 204
BOOL ArrangeEditGadgets(struct EditWindow *Edit)
{
	struct Gadget *Close,*Prop,*Up,*Down,*Grid;
	BOOL success = FALSE;

	if(Edit->Node.Type!=EW_PROJECT)
		Close = FindGadget(Edit->Gadgets,ID_CLOSE);
	else
		Close=NULL;
	if ((Prop = FindGadget(Edit->Gadgets,ID_KNOB)) &&
		(Up = FindGadget(Edit->Gadgets,ID_UP)) &&
		(Down = FindGadget(Edit->Gadgets,ID_DOWN)) &&
		(Grid = FindGadget(Edit->Gadgets,ID_GRID))) {

		Up->LeftEdge = LEFT_EDGE;
		Down->LeftEdge = Up->LeftEdge;
		Prop->LeftEdge = Up->LeftEdge + 2;
		Prop->Width = Up->Width-4;
		Grid->LeftEdge = GRID_LEFT;
		Grid->Width = GRID_WIDTH;

		if (Edit->Location == EW_TOP)
			if (Edit->Height == TOP_SMALL)
				Down->TopEdge = 204 - Down->Height;
			else
				Down->TopEdge = 404 - Down->Height;
		else
			Down->TopEdge = BOTTOM_SMALL - Down->Height;

		Up->TopEdge = Down->TopEdge - Up->Height;
	if(Close)
	{
		Close->LeftEdge = LEFT_EDGE;
		Close->TopEdge = 0;
		Prop->TopEdge = Close->TopEdge+Close->Height+4;
	}
	else Prop->TopEdge = 4;
	Prop->Height = Up->TopEdge - 4 - Prop->TopEdge;

		success = TRUE;
	}
	return(success);
}

/****** EditWindow/ResizeEditWindow *********************************
*
*   NAME
*	ResizeEditWindow
*
*   SYNOPSIS
*	BOOL ResizeEditWindow(struct EditWindow *Edit,UWORD NewHeight)
*
*   FUNCTION
*	First calls EditWindow->ResizeWindow(), then
*	calls SizeWindow(), waits for IDCMP_NEWSIZE, then renders gadgets
*
*********************************************************************
*/
VOID MakeSimpleSmart(struct Window *Window)
{
	struct Layer *Layer;

	Forbid();
	Layer = Window->RPort->Layer;
	Layer->Flags &= (~LAYERSIMPLE);
	Layer->Flags |= LAYERSMART;
	Window->Flags &= (~WFLG_SIMPLE_REFRESH); // WFLG_SMART_REFRESH is 0
	Permit();
}

//*******************************************************************
VOID MakeSmartSimple(struct Window *Window)
{
	struct Layer *Layer;

	Forbid();
	Layer = Window->RPort->Layer;
	Layer->Flags &= (~LAYERSMART);
	Layer->Flags |= LAYERSIMPLE;
	Window->Flags |= WFLG_SIMPLE_REFRESH; // WFLG_SMART_REFRESH is 0
	Permit();
}

//*******************************************************************
BOOL ResizeEditWindow(struct EditWindow *Edit,UWORD NewHeight)
{
	BOOL Success = FALSE;
	struct Gadget *Gadget;
	struct RastPort *RP;

	Edit->Height = NewHeight;
	RemoveGList(Edit->Window,Edit->Gadgets,MAX_UWORD);
	Edit->Resize(Edit,NewHeight);
	FreeGrid(Edit);

	if (Gadget = FindGadget(Edit->Gadgets,ID_KNOB)) {
	if (AllocGrid(Edit))
		Success = TRUE;
	} else Success = TRUE;

//	SizeWindow(Edit->Window,0,((WORD)NewHeight) - Edit->Window->Height);
	RP = Edit->Window->RPort;
//	SetDrMd(RP,JAM2);
//	SetRast(RP,SCREEN_PEN);

	MakeSmartSimple(Edit->Window);
	ChangeWindowBox(Edit->Window,Edit->Window->LeftEdge,
		Edit->Window->TopEdge,Edit->Window->Width,NewHeight);
	WaitForClass(Edit->Window->UserPort,IDCMP_NEWSIZE);
	MakeSimpleSmart(Edit->Window);

	AddGList(Edit->Window,Edit->Gadgets,0,MAX_UWORD,NULL);
	RenderEditWindow(Edit,TRUE);
	Edit->RedrawList = TRUE;

	return(Success);
}

/****** EditWindow/WaitForClass *************************************
*
*   NAME
*	WaitForClass
*
*   SYNOPSIS
*	VOID WaitForClass(struct MsgPort *UserPort,ULONG Class)
*
*   FUNCTION
*
*********************************************************************
*/
VOID WaitForClass(struct MsgPort *UserPort,ULONG Class)
{
	BOOL Done = FALSE;
	struct IntuiMessage *IntuiMsg;

	while (!Done) {
		while (IntuiMsg = (struct IntuiMessage *)GetMsg(UserPort)) {
			if (IntuiMsg->Class == Class) Done = TRUE;
			ReplyMsg((struct Message *)IntuiMsg);
		}
		if (!Done) WaitPort(UserPort);
	}
}

//*******************************************************************
VOID RefreshEdit(VOID)
{
	struct EditWindow *Edit,*Next;

	Edit = (struct EditWindow *)WindowList.lh_Head;
	while (Next = (struct EditWindow *)Edit->Node.MinNode.mln_Succ) {
		Edit->ew_OptRender = FALSE;
		if (Edit->Window) RenderEditWindow(Edit,TRUE);
		Edit = Next;
	}
}

LONG SetEditDepth( LONG depth )
{
	struct EditWindow *Edit,*Next;

	global_EditScreenDepth = depth;

	Edit = (struct EditWindow *)WindowList.lh_Head;

	while ( Next = (struct EditWindow *)Edit->Node.MinNode.mln_Succ )
	{
		Edit->ew_OptRender = FALSE;

		if ( Edit->ew_cg )
		{
			ob_SetAttrs( Edit->ew_cg,
				CRGRIDA_DestDepth,	depth,
				TAG_DONE );
		}

		if ( Edit->Window )
		{
			Edit->Window->RPort->Mask = (1 << depth) - 1;

			RenderEditWindow(Edit,TRUE);
		}

		Edit = Next;
	}

	return(depth);
}

//*******************************************************************
BOOL __regargs HandleSwitcher(
	struct MsgPort *Port)
{
	return(HandleSwitcherReply(Port,NULL,NULL));
}

static BOOL __regargs HandleSwitcherReply(
	struct MsgPort *Port, struct ESMessage *lastmsg, LONG *pLastReply )
{
	struct ESMessage *Msg;
	BOOL	quit=FALSE;

	do
	{
		while (Msg = (struct ESMessage *)GetMsg(Port))
		{	// IDCMP msgs I send to switcher also come back to this port
			DUMPHEXIL("Editor Received Message: ",(LONG)Msg,"...  ");
			DUMPHEXIW("Cookie: ",(WORD)Msg->Cookie,"\\");
			if ( Msg->Cookie == EDIT_COOKIE )
			{
				if ( pLastReply )
					*pLastReply = Msg->Reply;

				switch(Msg->Type)
				{
					case ES_STARTUP:
						if( ((struct RexxMsg *)Msg)->rm_Node.mn_Node.ln_Type == NT_REPLYMSG )
								break;
						PtrProject = (struct FastGadget **)Msg->Reply;
						Msg->Reply = ES_ERR_NONE;
						SwitWind = (struct Window *)Msg->Data[2]; // switcher's window (IDCMP)
								// SwitWind never changes during program (important for us)
							if(!(EditScreen = (struct Screen *)Msg->Data[0]))
				//				|| (!(DefaultFG = (struct FastGadget **)Msg->Data[1])))
								Msg->Reply = ES_ERR_GENERIC; // fail
							else InitScreenStuff();
						break;

					case ES_RENDER_EDIT:
						DEBUGMSG(DBHMSG,"ES_RENDER_EDIT");
						Msg->Reply = ES_ERR_NONE;
						if (Msg->Data[0] == 0) // Switcher wants all our windows closed
						{
							CloseAccessWindow();
							access_win = NULL;
							MakeLayout(EW_EMPTY,TOP_SMALL,EW_EMPTY);
						}
						else	// Switcher wants us open
						{
							SetEditDepth( Msg->Data[1] );

							if (EditTop)// If our windows are already open, then we just need to refresh them
							{
//								SetEditDepth( Msg->Data[1] );

								SoftSpriteOff();
								RefreshEdit();           
                        //was disabled
								aw_Redraw(global_aw);
								SoftSpriteOn();
							}
							else	// Else, open them
							{
								if ( !(access_win = OpenAccessWindow()) )
									Msg->Reply = 2;
								if (!MakeLayout(EW_PROJECT,TOP_SMALL,EW_EMPTY))
									Msg->Reply = 2;
							}
						}
						break;

					case ES_QUIT:
					//DEBUGMSG(DBHMSG,"ES_QUIT");
						quit=TRUE;
						break;

					case ES_RENDER_SWIT: // a reply
						DEBUGMSG(DBHMSG,"ES_RENDER_SWIT .. (a reply?)");
						break;

					case ES_LocateFile:
					{
						if ( Msg->Message.mn_Node.ln_Type != NT_REPLYMSG )
						{
							global_LocateFile_mp = Msg->Message.mn_ReplyPort;
							global_LocateFileType = Msg->Data[0];
							global_LocateFileName = (STRPTR) Msg->Data[1];
							global_LocateFileFlags = Msg->Data[2];
							global_LocateFileTxt = (STRPTR *) Msg->Data[3];
							global_LocateFileMode = Msg->Data[4];
							global_do_locatefile = TRUE;

//KPrintF("LocateFile( %08lx, \"%s\", %ld, %ld)\n",
//	Msg->Data[0],Msg->Data[1],Msg->Data[2],Msg->Data[4]);
						}
					}
					break;

					case ES_SwitcherRAWKEY:
					{
						if ( Msg->Message.mn_Node.ln_Type != NT_REPLYMSG )
						{
							global_sw_im.Class		= IDCMP_RAWKEY;
							global_sw_im.Code			= Msg->Data[0];
							global_sw_im.Qualifier	= Msg->Data[1];
						}
					}
					break;

				} // switch Type

				if ( Msg->Message.mn_Node.ln_Type == NT_REPLYMSG )
				{
					struct DelayedError	*de;
					if ( lastmsg == Msg )
						lastmsg=NULL;
					/*	Check for delayed Error information in reply
					 *	If non-NULL, build a timer request according
					 *	to the value that's in there
					 */
					if ( de = Msg->Error )
					{
//						Msg->Error = NULL; // This causes stuff to break on 2000 w/out debuggery
						// DelayedErrorPending flags
						// 0x01 == Message is being communicated
						// 0x02 == Next Error should be displayed

						if ( DelayedErrorPending & 0x01 )
						{
							AbortIO( (struct IORequest *)global_der );
							WaitIO( (struct IORequest *)global_der );
							GetMsg( DelayedErrMsgPort );
						}
						// Copy the information over and send it off
						global_der->der_de = *de;
						global_der->der_timerequest.tr_time.tv_secs = de->de_hottime.tv_secs;
						global_der->der_timerequest.tr_time.tv_micro = de->de_hottime.tv_micro;
						// Set crouton num for error
						if ( (Msg->Type == ES_Select) || (Msg->Type == ES_Auto) )
						{
							if ( EditTop )
								global_der->der_croutonnum =
									GetProjNodeOrder(EditTop,(struct FastGadget *)((ULONG *)Msg->Data)[0]);
							else
								global_der->der_croutonnum = -1;
						}
						else
						{
							global_der->der_croutonnum = -1;
						}
						DelayedErrorPending = 0x03;
						SendIO( (struct IORequest *)global_der );
					}
					DUMPHEXIL("Free Message: ",(LONG)Msg,"...  ");
					DUMPUDECL("size of Message: ",(LONG)Msg->Message.mn_Length,"\\");
					FreeMem(Msg,Msg->Message.mn_Length);
					Msg = NULL;
				}
			}
			else if ( ((struct IntuiMessage *)Msg)->IDCMPWindow == SwitWind )
			{
				DUMPHEXIL("IntuiMessage: ",(LONG)Msg,"...  ");
				DUMPHEXIW("non-Cookie: ",(WORD)Msg->Cookie," ");
				DUMPHEXIL("sizeof(IntuiMessage) = ",(LONG)sizeof(struct IntuiMessage),"\\");
				FreeMem(Msg,sizeof(struct IntuiMessage));
				Msg = NULL;
			}

			if ( Msg && (Msg->Message.mn_Node.ln_Type == NT_MESSAGE) )
			{
				ReplyMsg(&Msg->Message);
			}
		}
		if(lastmsg) WaitPort(Port);
	} while (lastmsg);

	return(quit); // exit edit?
}

#ifdef LATER
static struct ESMessage *GetOnlyMsg(
	struct MsgPort *mp, struct ESMessage *lastmsg )
{
	struct Message	*msg;

	if ( lastmsg )
	{
		do
		{
			Forbid();
			{
				struct Message	*nextmsg;

				for ( msg = (struct Message *)mp->mp_MsgList.lh_Head;
						nextmsg = (struct Message *)msg->mn_Node.ln_Succ;
						msg = nextmsg )
				{
					if ( msg == (struct Message *)lastmsg )
					{
						lastmsg = NULL;
						Remove((struct Node *)msg);
						Signal(mp->mp_SigTask,(1L << mp->mp_SigBit));
						break;
					}
				}

			}
			Permit();

			if (lastmsg)
				WaitPort(mp);

		} while (lastmsg);
	}
	else
	{
		msg = GetMsg(mp);
	}

	return((struct ESMessage *)msg);
}
#endif

//*******************************************************************
struct ESMessage __asm __inline *PutSwitcher(
	REG(d0) WORD Type, REG(d1) LONG *D1)
{

	if (!SwitPort)
		return(NULL);
	else
		return(PutESPort(Type,D1,SwitPort));
}

struct ESMessage __asm *PutESPort(
	REG(d0) WORD Type, REG(d1) LONG *D1, REG(a0) struct MsgPort *mp )
{
	struct ESMessage *Msg;
	LONG *dataptr;
	LONG	i=0;

	if(D1)
	{
 		i = *D1++;
		if(i>MAX_ESPARAMS) i=MAX_ESPARAMS; // May cause bogus calls!!!
	}

	if (Msg = SafeAllocMem(sizeof(struct ESMessage)+(i<<2),MEMF_CLEAR))
	{
		// DelayedErrorPending flags
		// 0x01 == Message is being communicated
		// 0x02 == Next Error should be displayed
		if ( DelayedErrorPending & 0x01 )
		{
			AbortIO( (struct IORequest *)global_der );
			WaitIO( (struct IORequest *)global_der );
			GetMsg( DelayedErrMsgPort );
		}
		DelayedErrorPending = 0;

		Msg->Cookie = EDIT_COOKIE;
		Msg->Type = Type;
		Msg->Message.mn_ReplyPort = EditPort;
		Msg->Message.mn_Length = sizeof(struct ESMessage)+(i<<2);
		DUMPHEXIL("Allocate Message: ",(LONG)Msg,"...  ");
		DUMPUDECL(" of ",(LONG)Msg->Message.mn_Length," bytes");
		DUMPUDECL(" with ",(LONG)i," parameters \\");
		dataptr = Msg->Data;

		while (i--)	*dataptr++ = *D1++;

		PutMsg(mp,&Msg->Message);
	}

	DUMPHEXIL("PutSwitcher() Msg= ",(LONG)Msg," ");
	DUMPUDECL("length= ",Msg->Message.mn_Length,"\\");
	return(Msg);
}

// Dummy wrapper, eliminated async messaging options
void __inline __asm SendSwitcher(REG(d0) WORD Type, REG(d1) APTR D1)
{
//	PutSwitcher(Type,(LONG *)D1);
	SendSwitcherReply(Type,D1);
}

//*******************************************************************
LONG __asm SendSwitcherReply(
	REG(d0) WORD Type, REG(d1) APTR D1)
{
	struct ESMessage	*lastmsg;
	LONG					 reply;

#ifndef SWIT_ONLY
	if (!SwitPort) return(NULL);
#endif

//	KPrintF("PutSwitcher(%ld)...",(long)Type);
	lastmsg = PutSwitcher(Type,(LONG *)D1);
//	KPrintF("HandleSwitcher...");
//	Delay(10);
	HandleSwitcherReply(EditPort,lastmsg,&reply);
//	KPrintF("HS Done\n");

	return(reply);
}

//*******************************************************************
// called when user changes views
// send message to switcher only if needs to
BOOL __regargs SwitcherSwitch(
	BOOL Power)
{
	if (Power && (!SwitcherOn))
	{
		//DEBUGMSG(DBHMSG,"Before SwitcherSwitch() sends ES_RENDER_SWIT TRUE");
		ESparams1.Data1=TRUE;
		SendSwitcherReply(ES_RENDER_SWIT,&ESparams1);	// need to wait for switcher to clear its bm
		//DEBUGMSG(DBHMSG,"  After SwitcherSwitch() sent ES_RENDER_SWIT TRUE");
		SwitcherOn=TRUE;
	}
	else if ((!Power) && (SwitcherOn))
	{
		//DEBUGMSG(DBHMSG,"Before SwitcherSwitch() sends ES_RENDER_SWIT FALSE");
		ESparams1.Data1=FALSE;
		SendSwitcherReply(ES_RENDER_SWIT,&ESparams1);
		//DEBUGMSG(DBHMSG,"  After SwitcherSwitch() sent ES_RENDER_SWIT FALSE");
		SwitcherOn=FALSE;
	}
	return(TRUE);
}

BOOL __regargs HandleErrPort( struct MsgPort *Port )
{
	if ( GetMsg(Port) )
	{
		if ( DelayedErrorPending & 0x02 )
		{
			DisplayMessage(global_der->der_de.de_errstr);

			if ( (global_der->der_croutonnum >= 0) && EditTop )
			{
				EditTop->DisplayGrid = TRUE;
				EditTop->ew_OptRender = TRUE;

				if ( EditTop->ew_cg )
				{
					ob_DoMethod( EditTop->ew_cg,CRGRIDM_SelectCrouton,
						global_der->der_croutonnum,GRIDSELECT_MULTIPLE,
						CROUTONSELECT_SELECTED|CROUTONSELECT_ERROR);
				}

				UpdateDisplay(EditTop);
			}
		}
	}

	global_der->der_croutonnum = -1;

	DelayedErrorPending = 0;

	return(DelayedErrorPending);
}

void FlushWindowPort( struct Window *win, ULONG idcmpflags )
{
	struct IntuiMessage *this_im;
	ULONG next_im;

	Forbid();

	for ( this_im = (struct IntuiMessage *)win->UserPort->mp_MsgList.lh_Head;
			next_im = (ULONG) this_im->ExecMessage.mn_Node.ln_Succ;
			this_im = (struct IntuiMessage *) next_im )
	{
		if ( this_im->Class & idcmpflags )
		{
			Remove( (struct Node *)this_im );
			ReplyMsg( (struct Message *)this_im );
		}
	}

	Permit();
}

//*******************************************************************
//*******************************************************************

static char *LocateFileReqText[] = {
	"Save File",
	"Locate the directory and file below using the file requester.",
	"Enter a filename and Select \"Continue\" to save the file.",
};
#define LOCATE_FILE_REQTEXT_NUMLINES	3

static struct GrazerRequest LocateFileGrazRequest = {

	LocateFileReqText,
	LOCATE_FILE_REQTEXT_NUMLINES,

	NULL,
	0,

	0,
	0,
	0,

	GRAZREQ_RESTOREVIEW,

	EndLocateFileRequest,
};

LONG LocateFileRequest( void )
{
	STRPTR	 filename = global_LocateFileName;
	STRPTR	*txtarray = global_LocateFileTxt;
	char		*f;

	global_do_locatefile = FALSE;

	if ( global_LocateFileFlags & 0x01 )
		LocateFileGrazRequest.gr_Flags |= GRAZREQ_ALLOWCREATE;
	else
		LocateFileGrazRequest.gr_Flags &= ~(GRAZREQ_ALLOWCREATE);

	/* only get path part of project name */
	if ( filename && strlen(filename) && (f = FilePart(filename)) )
	{
		char	c;

		/* Store the file name */
		strcpy(LocateFileGrazRequest.gr_InitialFileName,f);

		c = *f;	*f = '\0';

		/* Store the directory */
		LocateFileGrazRequest.gr_InitialPath = AllocSmartString(filename,NULL);
		*f = c;
	}
	else
	{
		LocateFileGrazRequest.gr_InitialFileName[0] = '\0';
		LocateFileGrazRequest.gr_InitialPath = NULL;
	}

	if ( txtarray )
	{
		LocateFileGrazRequest.gr_num_reqlines = 0;
		LocateFileGrazRequest.gr_reqtext = txtarray;

		while ( *txtarray++ )
			LocateFileGrazRequest.gr_num_reqlines++;
	}
	else
	{
		LocateFileGrazRequest.gr_reqtext = LocateFileReqText;
		LocateFileGrazRequest.gr_num_reqlines = LOCATE_FILE_REQTEXT_NUMLINES;
	}

	BeginGrazerRequest( &LocateFileGrazRequest );
	return(0);
}

static char global_LocateFilePath[320];

static LONG EndLocateFileRequest( struct GrazerRequest *gr, LONG mode )
{
	LONG						 retval = 0;

	if ( mode && (gr->gr_Flags & GRAZREQ_VALIDFILENAME) )
	{
		strcpy(global_LocateFilePath,GetCString(gr->gr_FilePath));

		// Success!
		retval = TRUE;
	}

	if ( gr->gr_CancelBottomType == EW_GRAZER )
		DoAllNewDir(EditBottom);

	req_DoLayout(	gr->gr_CancelTopType,
						gr->gr_CancelTopHeight,
						gr->gr_CancelBottomType);

	if (gr->gr_FilePath)
	{
		FreeSmartString(gr->gr_FilePath);
		gr->gr_FilePath = NULL;
	}


	if ( retval )
	{
		ESparams5.Data1=global_LocateFileType;
		ESparams5.Data2=(LONG)global_LocateFilePath;
		ESparams5.Data3=global_LocateFileFlags;
		ESparams5.Data4=NULL;
		ESparams5.Data5=global_LocateFileMode;

		/* message is asynchronous as the switcher may not
		 * be sending this message.
		 */
		PutESPort(ES_FoundFile,(LONG *)&ESparams5,global_LocateFile_mp);
	}

	return(retval);
}

// end of editwindow.c
