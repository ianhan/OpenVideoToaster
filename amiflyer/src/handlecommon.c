/********************************************************************
* $HandleCommon.c - routines common to projects & grazers$
* $Id: handlecommon.c,v 2.84 1996/07/29 10:27:28 Holt Exp $
* $Log: handlecommon.c,v $
*Revision 2.84  1996/07/29  10:27:28  Holt
*added keyboard eq for changing effect speeds without opening its panel
*
*Revision 2.83  1996/02/09  15:46:45  Holt
**** empty log message ***
*
*Revision 2.82  1995/10/14  10:17:27  Flick
*Added DTM_RefreshTabs to SetupWindow()  (for Grazers only)
*
*Revision 2.81  1995/10/12  16:35:41  Flick
*Replaced hard-coded ViewMode values with VIEW_XXX defines (popup rearranged)
*
*Revision 2.80  1995/10/09  16:42:52  Flick
*Added project TagList dumper (debugging ver only), now gets Tags.h
*
*Revision 2.79  1995/10/06  16:11:19  Flick
*Bumped rev to read 4.1 -- corrected Auto Insert doc, added Alt-C Alt-P
*
*Revision 2.78  1995/10/05  18:37:32  Flick
*Auto insert bound to Alt-I
*
*Revision 2.77  1995/10/05  03:43:19  Flick
*Using copyright symbol in InterfaceLG font instead of "(c)"
*
*Revision 2.76  1995/10/03  17:30:32  Flick
*Added Alt-P and Alt-C hotkeys for processing and cutting clips
*
*Revision 2.75  1995/10/02  15:19:43  Flick
*Moved quick-tune hotkey to CTRL, removed date-compiled from HELP panel (still in "About")
*Added Options panel to F10 key as well as Setup panel
*
*Revision 2.74  1995/09/28  10:09:52  Flick
*Now uses RawKeyCodes.h, made "prev view" key toggle correctly between last 2 views
*
*Revision 2.73  1995/09/25  12:20:01  Flick
*Added right-ALT quick tune
*
*Revision 2.72  1995/09/13  12:17:25  Flick
*Bumped rev to 4.08
*
*Revision 2.71  1995/08/31  16:15:09  Flick
*Bumped version to 4.06, changed content of about box
*
*Revision 2.70  1995/08/28  16:41:09  Flick
*One more rename/adjustment on help panel, moved Alt U to Alt S
*
*Revision 2.69  1995/08/28  15:24:31  Flick
*Cleaned up keyboard shortcuts panel, added new ALT stuff
*
*Revision 2.68  1995/08/28  10:39:38  Flick
*Added audio-under hotkey
*
*Revision 2.67  1995/08/18  16:46:21  Flick
*Slight change for maintaining project current time
*
*Revision 2.66  1995/08/09  17:54:33  Flick
*Changed hotkeys to make .allicons. to RALT,CTRL,HELP
*Removed ALT-ALT-TILDE hotkey sequence -- not needed, we have a button for this
*
*Revision 2.65  1995/07/13  13:09:18  Flick
*Fixed bugs w/ HandleLockDown() and HandleAudioOnOff() -- they get EditTop now
*
*Revision 2.64  1995/07/07  19:24:19  Flick
*Moved DEL-verify out of RAW_DELETE handler (ugh!)
*
*Revision 2.63  1995/07/07  17:04:42  Flick
*Added "About" window, fixed wrongly doc'd keyboard shortcuts
*Added verify to DEL key in project
*
*Revision 2.62  1995/07/05  14:57:47  Flick
*Added easy audio on/off switch via hot-key
*Minor changes to lock/unlock handling code (new keys)
*
*Revision 2.61  1995/06/28  18:08:03  Flick
*Moved ESC,DEL,BKSP keys around a bit (per James)
*Added lock/unlock and Cut to Music function keys
*
*Revision 2.60  1995/06/20  23:47:14  Flick
*Bumped rev #'s to 4.05, attempts to de-uglify key shortcuts help panel
*
*Revision 2.59  1995/04/27  11:05:41  Flick
*Bumped rev to 4.04, we've shipped 4.03
*
*Revision 2.58  1995/04/26  14:35:42  Flick
*Bumped version number and string
*
*Revision 2.57  1995/03/07  16:09:06  CACHELIN4000
*Add FAstDrive recording mode qualifier on  record panel hotkey (Tilde)
*
*Revision 2.56  1995/03/02  12:34:48  pfrench
*Added switcher un-used rawkey handling code
*
*Revision 2.55  1995/02/28  10:10:47  pfrench
*Fixed ViewMode problems, now brute force checking going on
*inside the MakeLayout function
*
*Revision 2.54  1995/02/22  10:17:14  CACHELIN4000
*Make Help key toggle preview overlay like switcher
*
*Revision 2.53  1995/01/12  12:05:43  CACHELIN4000
*Remove viewmode set from makelayout(), add redrawpopup after view hotkey
*
*Revision 2.52  1994/12/30  19:35:31  CACHELIN4000
*Change help panel, version #
*
*Revision 2.51  1994/12/29  16:15:47  CACHELIN4000
*Add f8 to cycle views, esc to return to last view, ctrl-alt-f8 for editor exit
*
*Revision 2.50  1994/12/28  16:29:56  CACHELIN4000
*Change NewGrazer to VALID_VOLUMES, so files display defaults to volumes not devices
*
*Revision 2.49  1994/12/21  17:31:10  CACHELIN4000
*Add keys for record, play, stop
*
*Revision 2.48  1994/12/19  22:38:35  pfrench
*Modified for now shared-code proof.library.
*
*Revision 2.47  1994/12/07  15:54:23  pfrench
*Removed InitialPath hack in makelayout, now properly
*handled in GraphicHelp
*
*Revision 2.46  1994/12/05  14:02:17  pfrench
*Added support for moving to project save directory
*
*Revision 2.45  1994/11/29  13:10:50  pfrench
*Added CDROM directory optimizations
*
*Revision 2.44  1994/11/15  17:54:14  pfrench
*Added support to highlight delayed error croutons when
*the error is posted, and not before.
*
*Revision 2.43  1994/11/15  13:46:43  pfrench
*Made sure enter key worked correctly in switcher mode.
*
*Revision 2.42  1994/11/09  20:11:00  Kell
*Now LALT+RAMIGA+HELP hack uses LALT+RSHIFT+HELP
*
*Revision 2.41  1994/11/09  17:39:06  Kell
**** empty log message ***
*
*Revision 2.40  1994/11/09  16:49:58  Kell
*Hack code for testing out all the sequencing error messages.
*
*Revision 2.39  1994/11/09  12:49:54  pfrench
*Added initial support for croutongrid object
*
*Revision 2.38  1994/10/20  11:50:03  CACHELIN4000
*Add Setup-screen (alt for old mode), alt-help for 2-3 monitor mode toggle
*
*Revision 2.37  94/10/12  18:58:06  CACHELIN4000
**** empty log message ***
*
*Revision 2.36  94/10/11  21:41:02  CACHELIN4000
**** empty log message ***
*
*Revision 2.35  94/10/10  21:19:37  CACHELIN4000
**** empty log message ***
*
*Revision 2.34  94/10/10  17:17:29  CACHELIN4000
*Fix Controls (f9) hotkey, ignore key-up events
*
*Revision 2.33  94/09/20  22:49:02  pfrench
*Modified to work with dircache (Editwindow has ptr to list now)
*
*Revision 2.32  1994/09/12  18:40:16  pfrench
*Navigation now works according to spec
*
*Revision 2.31  1994/09/09  16:42:06  pfrench
*Tied in a accesswindow rowcount hack
*
*Revision 2.30  1994/09/08  16:18:43  pfrench
*Removed call to redraw accesswindow
*
*Revision 2.29  1994/09/08  15:53:03  pfrench
*Added redraw code for accesswindow in MakeLayout()
*
*Revision 2.28  1994/09/06  23:57:01  pfrench
*Added basic accesswindow calls
*
*Revision 2.27  1994/09/02  08:24:41  Kell
*Disabled SERDEBUG flag
*
*Revision 2.26  1994/08/30  10:42:11  Kell
*Changed SendSwitcherReply calls to work with new ESParams structures.
*
*Revision 2.25  1994/08/27  17:45:28  CACHELIN4000
*Refresh on Enter
*
*Revision 2.24  94/08/27  00:29:58  CACHELIN4000
*Handle RAW_ENTER
*
*Revision 2.23  94/08/26  15:00:46  pfrench
*Fixed bug with spacebar handling, also added
*bad crouton support.
*
*Revision 2.22  1994/08/16  19:05:31  pfrench
*Now de-selects all current croutons when switching to
*project/switcher mode
*
*Revision 2.21  1994/08/16  17:12:55  pfrench
*Now disables "select all" button in switcher mode
*
*Revision 2.20  1994/08/02  21:48:31  pfrench
*Now re-scans dir in file-requester mode.
*
*Revision 2.19  1994/07/21  12:28:42  pfrench
*Added async requester window type.
*
*Revision 2.18  1994/07/14  15:25:27  CACHELIN4000
*Fixed new bug/typo in 'sweet spot' in OpenEditScreen
*
*Revision 2.17  94/07/14  11:59:49  pfrench
*Added sweet spot for adding async requesters.
*
*Revision 2.16  94/07/08  10:09:08  CACHELIN4000
*replace SendSwitcher() calls with SendSwitcherReply()
*
*Revision 2.15  94/07/07  11:26:43  pfrench
*Added initial support for project/project editing
*
*Revision 2.14  94/07/04  19:14:56  pfrench
*Modified indenting a little, no code changes.
*
*Revision 2.13  94/07/01  15:08:06  CACHELIN4000
*Begin to reinstate Proj2Proj
*
*Revision 2.12  94/06/07  15:18:23  CACHELIN4000
**** empty log message ***
*
*Revision 2.11  94/04/23  17:45:27  CACHELIN4000
**** empty log message ***
*
*Revision 2.10  94/04/22  17:46:07  CACHELIN4000
*Intercept RAW_SPACE, translate to ES_AUTO call
*
*Revision 2.9  94/04/20  17:33:48  CACHELIN4000
**** empty log message ***
*
*Revision 2.8  94/03/15  16:40:09  CACHELIN4000
*comment out F10 switching
*
*Revision 2.7  94/03/14  21:57:21  CACHELIN4000
**** empty log message ***
*
*Revision 2.6  94/03/14  00:37:00  CACHELIN4000
**** empty log message ***
*
*Revision 2.5  94/03/13  07:50:33  Kell
*Reworded the HELP requester
*
*Revision 2.4  94/03/12  20:01:16  CACHELIN4000
**** empty log message ***
*
*Revision 2.3  94/03/10  18:16:47  CACHELIN4000
*added __AMIGADATE__ to info, version strings
*
*Revision 2.2  94/03/09  01:56:43  CACHELIN4000
**** empty log message ***
*
*Revision 2.1  94/03/02  21:05:01  CACHELIN4000
**** empty log message ***
*
*Revision 2.0  94/02/17  16:24:37  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  15:57:47  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  14:44:54  Kell
*FirstCheckIn
*
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	12-17-92	Steve H		Convert to use SmartStrings
*	11-30-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <crouton_all.h>
#include <stdio.h>

#include <editwindow.h>
#include <editswit.h>
#include <gadgets.h>
#include <project.h>
#include <grazer.h>
#include <filelist.h>
#include <request.h>
#include <panel.h>
#include <RawKeyCodes.h>
#include <Tags.h>
#include <DirTabs.h>

#ifndef PROOF_LIB_H
#include <proof_lib.h>
#endif

#include <croutongrid.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

//#define SERDEBUG	1
#include <serialdebug.h>

#ifndef PROTO_PASS
#include <proto.h>
#endif

LONG UpdateAccessWindowRows( LONG newrows );

extern struct Library *ProofBase, *FlyerBase;
extern struct SmartString *TopPath,*BottomPath;
extern struct EditWindow *EditTop,*EditBottom;
extern struct Screen *EditScreen;
extern struct List WindowList;
extern WORD GrazerLayout;
extern struct NewWindow NewWindowStructure3;
extern struct MsgPort *EditPort,*SwitPort;
extern struct Window *SwitWind;
extern struct FastGadget *CurFG,*SKellFG;
extern int	CurGrid,CurRow,CurCol;
//extern BOOL GlobalFastDrives;
extern BOOL	EditingLive;
extern CFAR struct TagHelp TagNames[];

extern char	**ErrMsgs[];

extern struct ESParams1 ESparams1;


struct NewProject NewProject = {
	EW_PROJECT,
	0,0,WINDOW_WIDTH,TOP_SMALL,
	SCREEN_EXISTING,
	OPTION_ALLOW_DRAG,
	EW_TOP,
	NULL
};

struct NewGrazer NewGrazer = {
	EW_GRAZER,
	0,0,WINDOW_WIDTH,TOP_SMALL,
	SCREEN_EXISTING,
	OPTION_ALLOW_DRAG,
	EW_TOP,
	NULL,

	VALID_FILES|VALID_DIRECTORIES|VALID_VOLUMES,
};

#define MAX_UWORD 65535

#define SWITCHER_MODE	( (!EditBottom) && (EditTop->Height != TOP_LARGE) )
#define EDITOR_MODE		(!SWITCHER_MODE)

extern WORD ViewMode,PrevViewMode;

struct EditWindow *AllocInitAsyncReq(struct NewEditWindow *NewEdit );

VOID KPutStr(char *);
#ifdef SERDEBUG
static void DumpProject(struct EditWindow *Edit);
#endif

/****** HandleCommon/HandleDummy ************************************
*
*   NAME
*	HandleDummy
*
*   SYNOPSIS
*	struct EditWindow *HandleDummy(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
struct EditWindow *HandleDummy(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	return(Edit);
}

//*********************************************************************
struct EditWindow *HandleLogo(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct EditWindow *Next,*Draw;

	GrazerLayout ^= 1;
	Draw = (struct EditWindow *)WindowList.lh_Head;
	while (Next = (struct EditWindow *)Draw->Node.MinNode.mln_Succ) {
	if (Draw->Node.Type == EW_GRAZER) {
		GrazGrid(Draw); // err check !!!
		Draw->RowOffset = Draw->ScrollOffset = 0;
		RowOffsetToPot(Draw);
		NewGridLength(Draw);
		RenderEditWindow(Draw,FALSE);
		Draw->RedrawList = TRUE;
	}
	Draw = Next;
	}
	return(Edit);
}

/****** HandleCommon/HandleDelete ************************************
*
*   NAME
*	HandleDelete
*
*   SYNOPSIS
*	struct EditWindow *HandleDelete(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*	Finds which window (top/bottom) has selected items, calls
*	window's handler for delete
*
*********************************************************************
*/
struct EditWindow *HandleDelete(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct EditWindow *W = NULL;

	if (CheckNodeStatus(EditTop,EN_SELECTED)) W = EditTop;
	else if (EditBottom)
		if (CheckNodeStatus(EditBottom,EN_SELECTED)) W = EditBottom;
	if (W && (W->NodeDeleted)) W->NodeDeleted(W);
	return(Edit);
}

BOOL CheckNodeStatus(
	struct EditWindow *Edit,
	UWORD Status)
{
	struct EditNode *Node,*Next;
	struct FastGadget *FG;

	switch(Edit->Node.Type)
	{
	case EW_GRAZER:
		Node = (struct EditNode *)Edit->Special->pEditList->lh_Head;
		while (Next=(struct EditNode *)Node->Node.MinNode.mln_Succ)
		{
			if (Node->Status == Status)
				return(TRUE);
			Node = Next;
		}
	break;

	case EW_PROJECT:
		FG = *(((struct Project *)Edit->Special)->PtrPtr);
		while (FG)
		{
			if (FG->FGDiff.FGNode.Status == Status)
				return(TRUE);
			FG = FG->NextGadget;
		}
	}
	return(FALSE);
}

/****** HandleCommon/HandleDuplicate ********************************
*
*   NAME
*	HandleDuplicate
*
*   SYNOPSIS
*	struct EditWindow *HandleDuplicate(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*	Finds which window (top/bottom) has selected items, calls
*	window's handler for delete
*
*********************************************************************
*/
struct EditWindow *HandleDuplicate(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct EditWindow *W = NULL;

	if (CheckNodeStatus(EditTop,EN_SELECTED)) W = EditTop;
	else if (EditBottom)
		if (CheckNodeStatus(EditBottom,EN_SELECTED)) W = EditBottom;
	if (W && (W->NodeDuplicate)) W->NodeDuplicate(W);
	return(Edit);
}

//*********************************************************************
VOID EraseGadget(struct Window *Window,UWORD ID)
{
	struct Gadget *Gadget;
	struct RastPort *RP;

	if (Gadget = FindGadget(Window->FirstGadget,ID)) {
		RP = Window->RPort;
		SetAPen(RP,SCREEN_PEN);
		SetDrMd(RP,JAM2);
		RectFill(RP,Gadget->LeftEdge,Gadget->TopEdge,
			Gadget->LeftEdge+Gadget->Width-1,
			Gadget->TopEdge+Gadget->Height-1);
	}
}

//*********************************************************************
// turn Project into Grazer without Close/OpenWindow() so looks nice
// assumes Window stays same size in same place
BOOL MorphWindow(WORD Location,WORD NewType)
{
	struct EditWindow *Edit,*Old;
	struct NewEditWindow *NewEdit;
	struct IntuiMessage *IntuiMsg;
	struct Gadget *G;
	struct RastPort *RP;

	if (NewType == EW_GRAZER) NewEdit = &NewGrazer.NewEdit;
	else NewEdit = &NewProject.NewEdit;

	if (Location == EW_TOP) {
		Old = EditTop;
		NewEdit->Height = TOP_SMALL;
	} else if (Location == EW_BOTTOM) {
		Old = EditBottom;
		NewEdit->Height = BOTTOM_SMALL;
	}
	else return(FALSE);

// first do things without window updates
	RemoveGList(Old->Window,Old->Gadgets,MAX_UWORD);
	NewEdit->Screen = EditScreen;
	NewEdit->Location = Location;

	if (Location == EW_TOP)
		NewEdit->TopEdge = 0;
	else
		NewEdit->TopEdge = TOP_SMALL; //EditScreen->Height - NewEdit->Height;

	if (NewType == EW_PROJECT)
	{
		if (!(Edit = AllocInitProject(&NewProject)))
			return(FALSE);
	}
	else
	{
		if (!(Edit = AllocInitGrazer(&NewGrazer)))
			return(FALSE);
	}

// flush IDCMP port for the window so anymore messages are forgotten
	while (IntuiMsg = (struct IntuiMessage *)GetMsg(Old->Window->UserPort))
		ReplyMsg((struct Message *)IntuiMsg);

// now do actual window updates
	RP = Old->Window->RPort;
	SetAPen(RP,SCREEN_PEN);
	SetDrMd(RP,JAM2);

	Edit->Window = Old->Window;
	Old->Window = NULL; // so not closed

	if (Location == EW_TOP)
	{
		if (NewType == EW_GRAZER)
		{
			/* erase section going away */

			G = FindGadget(Old->Gadgets,ID_GRID);

			RectFill(RP,G->LeftEdge-BORD_W,
				G->TopEdge+175,
				G->LeftEdge+G->Width+BORD_W-1,
				G->TopEdge+G->Height+BORD_H-1);
		}

		if ( Edit->ew_cg )
		{
			/* Need _NEW_ grid */

			G = FindGadget(Edit->Gadgets,ID_GRID);

			ob_SetAttrs( Edit->ew_cg,
					CRGRIDA_DestLeft,		Edit->Window->LeftEdge + G->LeftEdge,
					CRGRIDA_DestTop,		Edit->Window->TopEdge + G->TopEdge,
					CRGRIDA_DestWidth,	G->Width,
					CRGRIDA_DestHeight,	G->Height,
					TAG_DONE );
		}
	}

	AddGList(Edit->Window,Edit->Gadgets,0,MAX_UWORD,NULL);
	Old->Free(Old);
	if (Location == EW_TOP)	EditTop = Edit;
	else EditBottom = Edit;
	SetupWindow(Edit);

	RenderEditWindow(Edit,FALSE);
	BuildWaitMask();
	return(TRUE);
}

/****** HandleCommon/MakeLayout *************************************
*
*   NAME
*	MakeLayout
*
*   SYNOPSIS
*	BOOL MakeLayout(WORD NewTopType, WORD NewTopHeight, WORD NewBottomType)
*
*   FUNCTION
*	Changes whatever is currently on EditScreen to match parameters
*
*********************************************************************
*/
BOOL MakeLayout(WORD NewTopType, WORD NewTopHeight, WORD NewBottomType)
{
	UBYTE TopType = EW_EMPTY, BottomType = EW_EMPTY;
	BOOL Success = TRUE;

	if (EditTop) TopType = EditTop->Node.Type;
	if (EditBottom) BottomType = EditBottom->Node.Type;

	if ( NewTopType == EW_PROJECT )
	{
		if ( NewBottomType == EW_EMPTY )
		{
			if ( NewTopHeight == TOP_SMALL )
				ViewMode = VIEW_PROJ_SWIT;		/* Proj/switcher */
			else
				ViewMode = VIEW_PROJ;			/* Big proj */
		}
		else if ( NewBottomType == EW_GRAZER )
			ViewMode = VIEW_PROJ_FILES;		/* Proj/Files */
		else
			ViewMode = VIEW_PROJ_PROJ;			/* Proj/Proj */
	}
	else if ( NewTopType == EW_GRAZER )
	{
		ViewMode = VIEW_FILES_FILES;			/* Files/Files */
	}
	else	/* Async requester on top or empty */
	{
		/* ViewMode = ??; */
	}

// special cases to make redisplay nicer
	if (EditTop && (NewTopHeight == TOP_SMALL) &&
		(EditTop->Height == TOP_SMALL))
	{
		if ((TopType == EW_GRAZER) && (NewTopType == EW_PROJECT))
		{
			if (!MorphWindow(EW_TOP,EW_PROJECT)) return(FALSE);
				TopType = EditTop->Node.Type;
		} else if ((TopType == EW_PROJECT) && (NewTopType == EW_GRAZER))
		{
			if (!MorphWindow(EW_TOP,EW_GRAZER)) return(FALSE);
				TopType = EditTop->Node.Type;
		} else if ((TopType == EW_PROJECT) && (NewTopType == EW_PROJECT))
		{
			if (!MorphWindow(EW_TOP,EW_PROJECT)) return(FALSE);
				TopType = EditTop->Node.Type;
		}
	}

// if top wrong type, close
	if ( EditTop && (TopType != NewTopType) )
   {
		DUMPMSG("Closing top window");

		EditTop->Close(EditTop);
		EditTop->Free(EditTop);
		EditTop = NULL;
	}

// if bottom wrong type, close
	if (EditBottom && (BottomType != NewBottomType))
	{
		DUMPMSG("Closing bottom window");

		EditBottom->Close(EditBottom);
		EditBottom->Free(EditBottom);
		EditBottom = NULL;
	}

// if top not open, and one requested, open at correct size
	if (!EditTop && (NewTopType != EW_EMPTY))
	{
		DUMPMSG("Opening top window");

		if (!OpenEditScreenWindow(NewTopHeight,NewTopType,EW_TOP))
			Success = FALSE;
	}
	else	// if top open but wrong size, resize
	{
		if (EditTop && (EditTop->Height != NewTopHeight))
		{
			DUMPMSG("Resizing top window");

			if (!ResizeEditWindow(EditTop,NewTopHeight)) Success = FALSE;
		}
	}

	if ( EditTop && (ViewMode == VIEW_PROJ_SWIT) )
		ChangeStatusList(EditTop,EN_SELECTED,EN_NORMAL);

// if bottom not open, and one requested, open at correct size
	if (!EditBottom &&
		((NewBottomType == EW_GRAZER) || (NewBottomType == EW_PROJECT)))
	{
		DUMPMSG("Opening bottom window");

		if (!OpenEditScreenWindow(BOTTOM_SMALL,NewBottomType,EW_BOTTOM))
			Success = FALSE;
	}

	DUMPHEXIL("MakeLayout returning ",(LONG)Success,"\\");

	return(Success);
}


/****** HandleCommon/OpenEditScreenWindow ***************************
*
*   NAME
*	OpenEditScreenWindow
*
*   SYNOPSIS
*	BOOL OpenEditScreenWindow(WORD Height,WORD Type,WORD Location)
*
*   FUNCTION
*	Takes care of allocating and opening EditWindow on the EditScreen
*
*********************************************************************
*/
BOOL OpenEditScreenWindow(WORD Height,WORD Type,WORD Location)
{
	struct EditWindow *Edit;
	struct NewEditWindow *NewEdit;
	BOOL Success = FALSE;

	if (Type == EW_GRAZER) NewEdit = &NewGrazer.NewEdit;
	else NewEdit = &NewProject.NewEdit;

	NewEdit->Screen = EditScreen;
	NewEdit->Height = Height;
	NewEdit->Location = Location;
	if (Location == EW_TOP) NewEdit->TopEdge = 0;
	else NewEdit->TopEdge = TOP_SMALL; // EditScreen->Height - Height;

	if (Type == EW_PROJECT) {
		if (!(Edit = AllocInitProject(&NewProject))) goto Exit;
	} else if (Type == EW_GRAZER) {
		if (!(Edit = AllocInitGrazer(&NewGrazer))) goto Exit;
	} else if (Type == EW_ASYNCREQ) {
		/*	**************************************
					Insert Async Requester code here!!
				************************************** */
		if (!(Edit = AllocInitAsyncReq(NewEdit))) goto Exit;
	} else goto Exit;

	if (Location == EW_TOP) NewWindowStructure3.IDCMPFlags |= DISKINSERTED+DISKREMOVED;
	else NewWindowStructure3.IDCMPFlags &= (~(DISKINSERTED+DISKREMOVED));

// something is allocated now
	if (Edit->Open(Edit))
	{
		if (Location == EW_TOP) EditTop = Edit;
		else if (Location == EW_BOTTOM) EditBottom = Edit;

		SetupWindow(Edit);
		UpdateDisplay(Edit);

		Success = TRUE;

	} else
		Edit->Free(Edit);

Exit:
	return(Success);
}

//*******************************************************************
VOID SetupWindow(struct EditWindow *E)
{
	if (E->Node.Type == EW_GRAZER)
	{
		APTR				 dirtab_gad;

		/* NOW it is safe to refresh this window's DirTab's */
		dirtab_gad = FindGadget(E->Gadgets,ID_DIRTAB_CYCLE);
		ob_DoMethod(dirtab_gad,DTM_RefreshTabs);
		RefreshGList(E->Gadgets,E->Window,NULL,MAX_UWORD);

		DoAllNewDir(E);
	}
	else if (E->Node.Type == EW_PROJECT)
	{
#ifndef SWIT_ONLY
	if (!SwitPort) {
		AddNodes(E,2);
	} else
#endif
		GetLoadedProject(E);
		SafeFixRowCount(E);
		NewGridLength(E);
		UpdateAccessWindowRows( E->CurrentRows );
		E->RedrawList = TRUE;
	}
}

//*******************************************************************
VOID AddNodes(struct EditWindow *Edit,UWORD T)
{
	int a;
	struct FastGadget *Node;

	for (a=0; a<T; a++) {
		Node = AllocProj(NULL);
		AddProjTail((struct Project *)Edit->Special,Node);
	}
}

/****** ARexxPort/OpenAuxWindow *************************************
*
*   NAME
*	OpenAuxWindow
*
*   SYNOPSIS
*	struct EditWindow *OpenAuxWindow(struct NewEditWindow *NewEdit)
*
*   FUNCTION
*
*
*********************************************************************
*/
#ifdef ASDFG
struct EditWindow *OpenAuxWindow(struct NewEditWindow *NewEdit)
{
	struct EditWindow *Edit = NULL;

	NewEdit->Location = EW_REQUEST;

	if (NewEdit->Type == EW_PROJECT) {
		if (!(Edit = AllocInitProject((struct NewProject *)NewEdit))) goto Exit;
	}
	else if (!(Edit = AllocInitGrazer((struct NewGrazer *)NewEdit))) goto Exit;

// something is allocated now
	if (Edit->Open(Edit)) {

		SetupWindow(Edit);

	} else {
		Edit->Free(Edit);
		Edit = NULL;
	}

Exit:
	return(Edit);
}
#endif

/****** HandleCommon/HandleAll ************************************
*
*   NAME
*	HandleAll
*
*   SYNOPSIS
*	struct EditWindow *HandleAll(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
struct EditWindow *HandleAll(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct EditWindow *W = NULL;

	if (EditBottom && (CheckNodeStatus(EditBottom,EN_SELECTED)))
		W = EditBottom;
	else
		W = EditTop;

	if (W && (W->SelectAll)) W->SelectAll(W);

	SetCurrentTime(-1);				// Remove

	return(Edit);
}


#define LITTLEVERSION "Video Toaster Editor 4.1"
#define VERSIONSTR "$VER: " LITTLEVERSION __DATE__

UBYTE		ver_str[]=VERSIONSTR ;

char HelpMsg1[] = "   " LITTLEVERSION " Keyboard Shortcuts",
	HelpMsg2[] = " Prog Prev Key  ",
	HelpMsg3[] = " F1   1    Q : Input 1      Alt A : Audio on/off",
	HelpMsg4[] = " F2   2   W : Input 2      Alt L : Lock/Unlock",
	HelpMsg5[] = " F3   3    E : Input 3      Alt I : Auto Insert",
	HelpMsg6[] = " F4   4    R : Input 4      Alt C : Cut clip",
	HelpMsg7[] = " F5   5    T : DV1          Alt P : Process clip",
	HelpMsg8[] = " F6   6    Y : DV2          Help : 2/3-Monitors",
	HelpMsg9f[]= " F7   7    U : DV3          (tilde) : Flyer Record",
	HelpMsg9[] = " F7   7    U : DV3                            ",
	HelpMsg10[]= " F8 : Cycle Views          Bksp : Previous View",
	HelpMsg11[]= " F9 : Info/Controls        Tab : Play",
	HelpMsg12[] =" F10: Setup Panel          Esc : Stop",
	HelpMsg13[] =" ",
	*HelpMsg[] = { HelpMsg1,HelpMsg13,HelpMsg2,HelpMsg3,HelpMsg4,HelpMsg5,
		HelpMsg6,HelpMsg7,HelpMsg8,HelpMsg9,HelpMsg10,HelpMsg11,HelpMsg12 };

char
	AboutMsg1[] = "   " LITTLEVERSION " " __DATE__,
	AboutMsg2[] = " ",
	AboutMsg3[] = "   Copyright \xA9 1994, 1995 NewTek, Inc.",
	AboutMsg4[] = " ",
	AboutMsg5[] = "   Written by...",
	AboutMsg6[] = "       Pat Brouillette",
	AboutMsg7[] = "       Arnie Cachelin",
	AboutMsg8[] = "       Marty Flickinger",
	AboutMsg9[] = "       David Holt",
	AboutMsg10[] ="   Based on demo code by Jr Hartford",

	*AboutMsg[] = { AboutMsg1,AboutMsg2,AboutMsg3,AboutMsg4,AboutMsg5,AboutMsg6,AboutMsg7,
		AboutMsg8,AboutMsg9,AboutMsg10 };

//*******************************************************************
BOOL __regargs SendIntuiSwitcher(struct IntuiMessage *IntuiMsg)
{
	struct IntuiMessage *MyIntuiMsg;

	if (SwitWind) {
		if (MyIntuiMsg = SafeAllocMem(sizeof(struct IntuiMessage),0)) {
			CopyMem(IntuiMsg,MyIntuiMsg,sizeof(struct IntuiMessage));
			MyIntuiMsg->IDCMPWindow = SwitWind; // is this ok?
			MyIntuiMsg->SpecialLink = NULL;
			MyIntuiMsg->ExecMessage.mn_ReplyPort = EditPort;
			MyIntuiMsg->ExecMessage.mn_Length = sizeof(struct IntuiMessage);
			MyIntuiMsg->ExecMessage.mn_Node.ln_Name = NULL;
			MyIntuiMsg->ExecMessage.mn_Node.ln_Succ = NULL;
			MyIntuiMsg->ExecMessage.mn_Node.ln_Pred = NULL;
			PutMsg(SwitWind->UserPort,&MyIntuiMsg->ExecMessage);
			return(TRUE);
			}
		}
	return(FALSE);
}

//*******************************************************************
struct EditWindow *HandleKey(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{  // Should probably return EditWindow if changes like MakeLayout are done
	BOOL Processed = FALSE;
	UWORD TV;
	char	***ErrorMessages;

	if ( AccessPanelGetsMessage(IntuiMsg) )
	{
		// Report this key to the numeric pad handler so it
		// can update the text in the box, etc.
		// HandleNumericPad(IntuiMsg->Code);
		Processed = TRUE;
	}
	else if ( IntuiMsg->Code >0x80 ) // absorb key-ups
	{
		Processed = TRUE;
	}
	else
	{
	DUMPHEXIL("Key=",(LONG)IntuiMsg->Code,"\\");
	switch ( IntuiMsg->Code )
	{
	case RAWKEY_PAD_PERIOD:
		DUMPHEXIL("  STATUS: CurFG = ",(LONG)CurFG,"  ");
		DUMPUDECB("Row: ",CurRow," ");
		DUMPUDECB("Column: ",CurCol," ");
		DUMPUDECB("Number: ",CurGrid,"\\ ");
		Processed = TRUE;
		break;

	case RAWKEY_UP:
		NavigateUp(Edit,IntuiMsg->Qualifier);
		Processed = TRUE;
		break;
	case RAWKEY_DOWN:
		NavigateDown(Edit,IntuiMsg->Qualifier);
		Processed = TRUE;
		break;
	case RAWKEY_LEFT:
	case RAWKEY_PAD_MINUS:
		NavigateLeft(Edit,IntuiMsg->Qualifier);
		Processed = TRUE;
		break;
	case RAWKEY_RIGHT:
	case RAWKEY_PAD_PLUS:
		NavigateRight(Edit,IntuiMsg->Qualifier);
		Processed = TRUE;
		break;

	case RAWKEY_HELP:
		//*** LALT+RSHIFT+HELP ---> Preview all error requesters
		if((IntuiMsg->Qualifier & IEQUALIFIER_LALT) && (IntuiMsg->Qualifier & IEQUALIFIER_RSHIFT))
		{
			ErrorMessages=ErrMsgs;

			while(*ErrorMessages && ErrorMessageBoolRequest(Edit->Window,*ErrorMessages++));;

			Processed = TRUE;
			break;
		}
		//*** RALT+CTRL+HELP ---> Build .allicons.i file
		if ((IntuiMsg->Qualifier & IEQUALIFIER_RALT) && (IntuiMsg->Qualifier & IEQUALIFIER_CONTROL))
		{
			if ( Edit->Node.Type == EW_GRAZER )
			{
				BuildIconFile(GetCString(((struct Grazer *)Edit->Special)->Path));
			}
			Processed = TRUE;
			break;
		}
		//*** CTRL+HELP ---> Put up "About" requester
		if( IntuiMsg->Qualifier & IEQUALIFIER_CONTROL )
		{
			SimpleRequest(Edit->Window,AboutMsg,10,REQ_H_CENTER,NULL);
			Processed = TRUE;
			break;
		}
		//*** ELSE ---> Put up general Editor Help requester
		if(FlyerBase) HelpMsg[9] = HelpMsg9f;
		else HelpMsg[9] = HelpMsg9;
		SimpleRequest(Edit->Window,HelpMsg,13,REQ_H_CENTER,NULL);
		break;
	case RAWKEY_SPACE:
		DUMPMSG("SPACE");

		if (EditingLive)
		{
			HandleLockDown(EditTop);
			NavigateRight(Edit,IntuiMsg->Qualifier);
			Processed = TRUE;
		}
		break;

	case RAWKEY_COMMA:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			HandleMultiCroutonsSp(EditTop,3);
		}
		break;

	case RAWKEY_PERIOD:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			HandleMultiCroutonsSp(EditTop,0);
		}
		break;


	case RAWKEY_SLASH:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
//			HandleLockDown(EditTop);    //this is a test this is going to be Speedset.
			HandleMultiCroutonsSp(EditTop,1);
		}
		else
		{
			DUMPMSG("Slash");

			if(EDITOR_MODE && CurFG)
			{
				ESparams1.Data1=(LONG)CurFG;
	
				if(CurFG==SKellFG)
					SendSwitcherReply(ES_Auto,&ESparams1);
				else if(!SendSwitcherReply(ES_Select,&ESparams1))
				{
					SendSwitcherReply(ES_Auto,&ESparams1);
					SKellFG=CurFG;
				}
				else
				{
					CurFG->FGDiff.FGNode.Behavior |= EN_BADCROUTON;
					CurFG->FGDiff.FGNode.Redraw = TRUE;
					SKellFG=NULL;
				}
				Processed = TRUE;
			}
		}
		break;
	case RAWKEY_L:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			HandleLockDown(EditTop);
			Processed = TRUE;
		}
		break;
	case RAWKEY_A:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			HandleAudioOnOff(EditTop);
			Processed = TRUE;
		}
		break;
	case RAWKEY_I:		// Auto insert
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			HandleAudioUnder(EditTop);
			Processed = TRUE;
		}
		break;
	case RAWKEY_P:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			ProcessCrouton(EditTop,FALSE);		// Process clip
			Processed = TRUE;
		}
		break;
	case RAWKEY_C:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			ProcessCrouton(EditTop,TRUE);		// Destructively cut clip
			Processed = TRUE;
		}
		break;
#ifdef SERDEBUG
	case RAWKEY_D:
		if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
		{
			DumpProject(EditTop);		// Dump project to serial terminal
			Processed = TRUE;
		}
		break;
#endif
	case RAWKEY_PAD_ENTER:
		if (EditingLive)
			HandleLockDown(EditTop);
		else if (IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT))
			HandleLockDown(EditTop);
		else if( CurFG && (CurFG!=SKellFG) )
		{
			/* THIS MUST BE BEFORE THE SENDSWITCHERREPLY
			 *
			 *	The switcher may send a REDRAW before the
			 * SELECT comes back.  Redraw will automatically
			 * clear the OptRender flag.
			 *
			 */
			Edit->ew_OptRender = TRUE;

			ESparams1.Data1=(LONG)CurFG;

			if(	SendSwitcherReply(ES_Select,&ESparams1) ||
					((SWITCHER_MODE) ? SendSwitcherReply(ES_Select,&ESparams1):0) )
			{
				// CurFG->FGDiff.FGNode.Behavior |= EN_BADCROUTON;
				// CurFG->FGDiff.FGNode.Redraw = TRUE;
				SKellFG=NULL;
			}
			else
			{
				SKellFG=CurFG;
				CurFG->FGDiff.FGNode.Redraw = TRUE;
			}

			if ( Edit->ew_cg )
			{
				LONG			nodenum;

				nodenum = GetProjNodeOrder(Edit,CurFG);

				ob_DoMethod( Edit->ew_cg,CRGRIDM_SelectCrouton,
					nodenum,GRIDSELECT_NORMAL,CROUTONSELECT_SELECTED);
			}

			Edit->RedrawSelect = TRUE;
			Edit->DisplayGrid = TRUE;
		}
		Processed = TRUE;
		break;

	case RAWKEY_RAMIGA:
    HandleLogo(Edit,IntuiMsg);
		Processed = TRUE;
    break;

	case RAWKEY_TAB:  // Play
		HandlePlay(Edit,IntuiMsg);
		Processed = TRUE;
		break;

	case RAWKEY_ESC:  // Stop
		DUMPMSG("Try to STOP!");
		HandleStop(Edit,IntuiMsg);
		Processed = TRUE;
		break;

	case RAWKEY_DELETE:	// Equivalent for delete button
		HandleDelete(Edit,IntuiMsg);
		Processed = TRUE;
		break;

	case RAWKEY_TILDE:  // record
//		if(GlobalFastDrives || ((IntuiMsg->Qualifier&IEQUALIFIER_LALT) && (IntuiMsg->Qualifier&IEQUALIFIER_RALT)))
//			GlobalFastDrives=TRUE;
//		else
//			GlobalFastDrives=FALSE;

		HandleNewClip(Edit,IntuiMsg);
		Processed = TRUE;
		break;

	case RAWKEY_F10:
		if(IntuiMsg->Qualifier & (IEQUALIFIER_LALT | IEQUALIFIER_RALT) )
		{
			if(IntuiMsg->Qualifier & IEQUALIFIER_CONTROL)		// Trying to quit?
				break;
			else
				DoOptionsPanel(Edit,NULL);
		}
		else
			DoSetupPanel(Edit,NULL);
		Processed = TRUE; // absorb F10s if not in PJ/Switcher mode
		break;

	case RAWKEY_F9:
		GrazerHandleInfo(Edit,IntuiMsg);
		Processed = TRUE;
		break;

	case RAWKEY_F8:
		if( (IntuiMsg->Qualifier&IEQUALIFIER_LALT) && (IntuiMsg->Qualifier&IEQUALIFIER_CONTROL) )
			return(NULL); // This will cause Edit to quit!!!
		Processed = TRUE;
		PrevViewMode=ViewMode;
		ViewMode++;
		if(ViewMode==VIEW_PROJ_PROJ) ViewMode++;		// Avoid this one here
		if(ViewMode>=USABLE_VIEWS) ViewMode=0;			// Wrap around
		SetView(ViewMode);
		Edit = EditTop;
		RedrawPopupText(Edit);
		break;

	case RAWKEY_BKSPACE:		// Toggle between most recently used views
		Processed = TRUE;
//		SetView(PrevViewMode);
//		TV=PrevViewMode;
//		PrevViewMode=ViewMode;
//		ViewMode=TV;

		TV=ViewMode;
		SetView(PrevViewMode);	// Sets ViewMode for us
		PrevViewMode=TV;

		Edit = EditTop;
		RedrawPopupText(Edit);
		break;
	case RAWKEY_CTRL:		// Ctrl key
		QuickVIDEOPanel(Edit,CurFG);
		Processed = TRUE;
	}
	}

	if ( !Processed )
	{
		/* "Class" will be cleared in main event loop if it is the
		 * result of getting an ES_SwitcherRAWKEY from the switcher.
		 * (see Edit.c)
		 */
		if ( IntuiMsg->Class )
		{
			SendIntuiSwitcher(IntuiMsg);
			DUMPMSG("Key passed to Switcher");
		}
	}
	else DUMPMSG("Key Handled by Edit");
	return(Edit);
}


#ifdef SERDEBUG
static BOOL DumpProjFunc(APTR tagptr,APTR data)
{
	ULONG	tagid,tagflags,*tptr;

	tptr = (ULONG *)tagptr;
	tagflags = *tptr++;

	if (TAGCTRL_UNSAVED & tagflags)
		DUMPSTR("(unsaved)");

	tagid = tagflags & 0x00FFFFFF;
	DUMPSTR(TagNames[tagid].th_Name);
	if (TAGCTRL_LONG & tagflags)
	{
		if (*tptr <= 999999)		// Show in hex on really big numbers, else decimal
			DUMPUDECL(" = ",*tptr,"\\");
		else
			DUMPHEXIL(" = ",*tptr,"\\");
	}
	else
	{
		switch (tagid)
		{
			case TAG_OriginalLocation:
			case TAG_CommentList:
				DUMPSTR(" = \"");
				DUMPSTR((UBYTE *)(tptr+1));
				DUMPMSG("\"");
				break;
			default:
//				DUMPUDECL(" (",*tptr," bytes of data)\\");
				DUMPMEM(" = ",(APTR)(tptr+1),*tptr);
		}
	}

	return(TRUE);
}

static void DumpProject(struct EditWindow *Edit)
{
	struct ExtFastGadget *FG;
	char	TypeStr[5];

	if (Edit->Node.Type == EW_PROJECT)			// Only works from project window
	{
		FG = (struct ExtFastGadget *) *((struct Project *)Edit->Special)->PtrPtr;
		for (; FG; FG=(struct ExtFastGadget *)FG->FG.NextGadget)
		{
			DUMPSTR("------");
			DUMPSTR(FG->FileName);
			DUMPSTR("------");
			*((ULONG *)TypeStr) = FG->ObjectType;
			TypeStr[4] = 0;
			DUMPSTR(TypeStr);
			DUMPHEXIL("------ (FG:",(LONG)FG,")\\");

			WalkTagList(FG,DumpProjFunc,NULL);		// Print each tag for this crouton
		}
	}
}
#endif


// end of handlecommon.c
