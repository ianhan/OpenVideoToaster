/********************************************************************
* $Project.c$ - EditWindow for Croutons hierarchy
* $Id: project.c,v 2.146 1996/11/18 18:42:29 Holt Exp $
* $Log: project.c,v $
*Revision 2.146  1996/11/18  18:42:29  Holt
**** empty log message ***
*
*Revision 2.145  1996/02/15  11:39:26  Holt
*added es_take support
*
*Revision 2.144  1995/11/21  16:19:39  Flick
*Now puts up requester if project save fails for any reason (dope!!!)
*
*Revision 2.143  1995/11/14  18:22:51  Flick
*Project saves default to toaster:Projects the first time
*
*Revision 2.142  1995/10/24  17:31:41  Flick
*If InheritTags is aborted or fails, will now undo the overwrite (and not insert either)
*
*Revision 2.141  1995/10/14  10:41:24  Flick
*Additional line in overwrite verification requester (CANCEL will insert)
*
*Revision 2.140  1995/10/12  16:38:41  Flick
*Replaced hard-coded ViewMode values with VIEW_XXX defines (popup rearranged)
*
*Revision 2.139  1995/10/10  17:20:33  Flick
*Removed special text-rendering test for "lost" croutons -- now renders text on them too
*
*Revision 2.138  1995/10/09  23:58:47  Flick
*Changed inherit operation to list crouton name in requester, and to NOT OVERWRITE if user
*cancels.  Also supports CTRL key to manually override requester in novice mode.
*
*Revision 2.137  1995/10/09  16:46:56  Flick
*Removed unnecessary usage of popup.h
*Changed ProjectRenderNode to NOT render text over Lost Croutons (special test)
*
*Revision 2.136  1995/10/06  16:13:14  Flick
*Now erases Current Time display after deleting croutons from project
*
*Revision 2.135  1995/10/03  18:07:30  Flick
*Changed requester skipping to use individual flags in prefs, rather than global user level
*
*Revision 2.134  1995/10/02  15:24:24  Flick
*Added POPUP_TOOLS to button row, now puts up "Sure you want to inherit..." msg before doing
*an inherit, rather than after.  Many lesser warning requesters now skipped if UserLevel (in
*options panel) ==GENIUS (Delete from proj, overwrite, inherit)
*
*Revision 2.133  1995/09/25  12:44:35  Flick
*Added overwrite verification, and support for inherit-drop
*
*Revision 2.132  1995/08/18  17:09:19  Flick
*Maintenance of project running time after dragging/duplicating
*
*Revision 2.131  1995/07/13  16:56:56  Flick
*Modified text slightly for "delete croutons from project" req
*
*Revision 2.130  1995/07/13  13:08:33  Flick
*Modified text slightly on delete croutons verify requester
*
*Revision 2.129  1995/07/07  19:23:44  Flick
*Moved DEL-verify message to ProjectDropped, where it should be
*
*Revision 2.128  1995/07/07  17:03:45  Flick
*Fixed +1 vert placement bug with corner symbols during drag
*
*Revision 2.127  1995/07/06  18:21:40  Flick
*Added support for ID_CROUTONSTAMP_AUDIO
*
*Revision 2.126  1995/07/05  16:34:24  pfrench
*Now rendering locks on dragging croutons
*
*Revision 2.125  1995/02/13  17:17:44  pfrench
*Added hack to play-forward-from-crouton button's handler
*function pointer.
*
*Revision 2.124  1995/01/27  14:07:11  pfrench
*Now lets project bring up its own requester
*
*Revision 2.123  1995/01/26  09:18:47  pfrench
*Now has backup function scan for drives
*
*Revision 2.122  1995/01/25  19:35:18  pfrench
*Added Hack for putting "backup" button on save project requester
*
*Revision 2.121  1995/01/12  14:04:28  CACHELIN4000
*Tweak cosmetic button spacing...
*
*Revision 2.120  1995/01/12  12:46:54  CACHELIN4000
*change SWITCHER_MODE define to avoud enf. hit on NULL EditTop
*
*Revision 2.119  1995/01/12  12:07:28  CACHELIN4000
*add PLAY_PART button
*
*Revision 2.118  1995/01/06  18:43:44  pfrench
*Final bug fix for select all gadget
*
*Revision 2.117  1995/01/06  18:30:23  pfrench
*Added (and temporarily removed) code that replaced
*select all gadget with same gad with correct imagery
*
*Revision 2.116  1994/12/31  07:06:05  pfrench
*Now voiding project length on project edit
*
*Revision 2.115  1994/12/29  19:32:36  CACHELIN4000
*Update CurFG when new crouton is dropped onto it ==> fix crashy sequencing bug
*
*Revision 2.114  1994/12/20  19:37:42  CACHELIN4000
*Remove ID_CLOSE gadget from project IDS array ==> from project editwindow
*
*Revision 2.113  1994/12/19  22:38:56  pfrench
*Modified for now shared-code proof.library.
*
*Revision 2.112  1994/12/07  15:52:27  pfrench
*Finally got project save request going
*
*Revision 2.111  1994/12/05  14:01:31  pfrench
*ci Project.c
*Added support for moving to project save directory
*
*Revision 2.110  1994/11/18  17:13:35  pfrench
*Wasn't correctly displaying a new project after loading
*
*Revision 2.109  1994/11/18  13:14:11  pfrench
*small typo with last checked in version
*
*Revision 2.108  1994/11/18  13:11:00  pfrench
*Now redraws correctly when empty project is loaded
*
*Revision 2.107  1994/11/18  12:27:18  pfrench
*Fixed problem with dragging drawers to project not
*redrawing in their source grazer.
*
*Revision 2.106  1994/11/18  12:02:16  CACHELIN4000
*Add refresh after Denying folders access to Project Dropping.
*
*Revision 2.105  1994/11/17  19:13:48  CACHELIN4000
*Make sure ProjectDropped only accepts grazer nodes with DosClass==EN_FILE..
*
*Revision 2.104  1994/11/15  17:52:44  pfrench
*Added support to highlight delayed error croutons when
*the error is posted, and not before.
*
*Revision 2.103  1994/11/15  13:34:50  pfrench
*Added better error handling to select code.
*
*Revision 2.102  1994/11/11  11:54:13  pfrench
*Got Select All working correctly
*
*Revision 2.101  1994/11/09  12:49:38  pfrench
*Added initial support for croutongrid object
*
*Revision 2.100  1994/10/11  16:56:56  CACHELIN4000
*Add Flage to ES_LoadCrouton fro Project vs. Grazer loading
*
*Revision 2.99  94/09/28  16:14:56  pfrench
*Removed NEW_CLIP from Gadget lists
*
*Revision 2.98  1994/09/27  19:59:57  pfrench
*Needed to add POP_VIEWS ID
*
*Revision 2.97  1994/09/27  16:26:01  pfrench
*Added programs popup to the bottom of the window
*
*Revision 2.96  1994/09/20  22:51:22  pfrench
*Modified to work with dircache (Editwindow has ptr to list now)
*
*Revision 2.95  1994/09/12  18:41:43  pfrench
*get order of fast gadet now return (0...n-1)
*
*Revision 2.94  1994/09/09  16:42:39  pfrench
*Tied in an accesswindow rowcount hack. Also tried to fix
*a select problem with some croutons.
*
*Revision 2.93  1994/09/08  15:45:56  pfrench
*Added new function to assist accesswindow updating
*
*Revision 2.92  1994/08/30  22:41:17  pfrench
*Removed un-used code.
*
*Revision 2.91  1994/08/30  21:39:13  pfrench
*Modified text of project save requester
*
*Revision 2.90  1994/08/30  17:39:32  pfrench
*Fixed multiple-select-drag from grazer to project to
*leave all dragged croutons highlighted
*
*Revision 2.89  1994/08/30  17:04:21  pfrench
*Duplicate in Switcher mode doesn't highlight selected
*crouton.
*
*Revision 2.88  1994/08/30  10:48:00  Kell
*Changed SendSwitcherReply calls to work with new ESParams structures.
*
*Revision 2.87  1994/08/29  20:32:50  pfrench
*Fixed couple more bugs
*
*Revision 2.86  1994/08/29  18:39:49  pfrench
*Redraws correctly on crouton select.
*
*Revision 2.85  1994/08/29  18:00:54  CACHELIN4000
*Move Text label for default crouton bmaps over by 2 pixels
*
*Revision 2.84  94/08/29  17:22:42  pfrench
*Whooops.
*
*Revision 2.83  1994/08/29  17:20:39  pfrench
*Removed annoying code that selected first gad in
*project every time.
*
*Revision 2.82  1994/08/27  17:53:54  CACHELIN4000
**** empty log message ***
*
*Revision 2.81  94/08/27  16:18:55  CACHELIN4000
*add Stop, Play buttons, remove NewClip from ArrangeProjectGadgets()
*
*Revision 2.80  94/08/26  15:01:46  pfrench
*Added bad crouton support.
*
*Revision 2.79  1994/08/25  17:03:11  pfrench
*Added full volume name support for files loaded into project
*
*Revision 2.78  1994/08/25  14:45:31  pfrench
*Dragging croutons in switcher mode leaves them un-highlighted.
*
*Revision 2.77  1994/08/25  14:36:26  pfrench
*Duplicate now correctly sets CurFG to NULL
*
*Revision 2.76  1994/08/24  17:41:28  pfrench
*Now correctly handles double-clicking on Current FG.
*
*Revision 2.75  1994/08/22  20:03:32  pfrench
*Got project/duplicate working a little closer to
*acutal reality.  Now "duplicate" copies all selected
*croutons and inserts them contiguously after the
*last selected crouton.
*
*Revision 2.74  1994/08/22  14:09:10  pfrench
*Couple more fixes.
*
*Revision 2.73  1994/08/22  12:57:21  pfrench
*Fixed long-standing project editing bug with dragging
*multiple croutons messing up the FastGadget list.
*
*Revision 2.72  1994/08/16  17:12:29  pfrench
*Now disables "select all" button in switcher mode
*
*Revision 2.71  1994/08/06  11:48:29  pfrench
*Fixed problem with double/single click.
*
*Revision 2.70  1994/08/01  15:55:01  pfrench
*Removed calls to req file type as those files are being
*filtered out of the grazer again.
*
*Revision 2.69  1994/07/31  14:41:28  pfrench
*Now uses grazer for for saving project.
*
*Revision 2.68  1994/07/27  16:47:22  pfrench
*Added "New Project" button to bottom project.
*
*Revision 2.67  1994/07/21  18:56:20  pfrench
*Fancy support for filtering requested file types.
*
*Revision 2.66  1994/07/15  18:25:23  pfrench
*No longer hacks loading the hardcoded project name
*
*Revision 2.65  1994/07/12  14:50:44  pfrench
*Bottom project height was getting initialized too tall
*
*Revision 2.64  94/07/11  13:57:22  pfrench
*More preliminary project/project support
*
*Revision 2.63  94/07/07  17:02:29  CACHELIN4000
**** empty log message ***
*
*Revision 2.62  94/07/07  11:29:00  pfrench
*Whoops, bug fix.
*
*Revision 2.61  94/07/07  11:25:34  pfrench
*Added micro-hack to load a default project
*
*Revision 2.60  94/07/04  18:40:38  CACHELIN4000
**** empty log message ***
*
*Revision 2.59  94/06/07  15:17:56  CACHELIN4000
**** empty log message ***
*
*Revision 2.58  94/05/25  20:45:34  CACHELIN4000
*let NO FG be selected again
*
*Revision 2.53  94/05/12  08:31:57  CACHELIN4000
*add EDITORMODE logic, ES_DefaultSelect
*
*Revision 2.52  94/04/22  14:45:53  CACHELIN4000
**** empty log message ***
*
*Revision 2.51  94/04/22  14:29:57  CACHELIN4000
*Stop filtering FGC_SELECTs
*
*Revision 2.50  94/04/20  17:32:59  CACHELIN4000
*Move Panel stuff to Panel.c
*
*Revision 2.48  94/03/29  19:00:03  Kell
*Some error messages added.
*
*Revision 2.44  94/03/19  15:51:18  CACHELIN4000
*DHD Support, Expert mode record panel
*
*Revision 2.42  94/03/19  13:05:05  CACHELIN4000
*Fix Jr.s dumb parentheses bug in PNL_IN_TYPE
*
*Revision 2.39  94/03/19  03:12:10  CACHELIN4000
*DHD TAG type support
*
*Revision 2.38  94/03/19  00:55:08  CACHELIN4000
*Fix SMPTE string .
*
*Revision 2.36  94/03/18  21:13:29  CACHELIN4000
**** empty log message ***
*
*Revision 2.35  94/03/18  18:20:23  CACHELIN4000
*re-enable default project name if(*ProjectName==0)
*
*Revision 2.34  94/03/18  17:14:29  CACHELIN4000
*Add Icon to Panel
*
*Revision 2.33  94/03/18  09:26:41  Kell
**** empty log message ***
*
*Revision 2.32  94/03/18  06:11:34  Kell
**** empty log message ***
*
*Revision 2.31  94/03/18  05:04:48  CACHELIN4000
*Video Clip support
*
*Revision 2.30  94/03/17  21:28:11  CACHELIN4000
**** empty log message ***
*
*Revision 2.29  94/03/17  09:53:38  Kell
**** empty log message ***
*
*Revision 2.28  94/03/16  19:33:58  CACHELIN4000
**** empty log message ***
*
*Revision 2.16  94/03/15  14:22:03  CACHELIN4000
*Refresh Switcher after selecting croutons
*
*Revision 2.12  94/03/13  07:49:32  Kell
*Deleted some unused variables
*
*Revision 2.10  94/03/12  13:38:32  CACHELIN4000
*Add path name to crouton dropped into project
*
*Revision 2.9  94/03/11  12:19:21  CACHELIN4000
*Re-Do ProjectRenderNode()
*
*Revision 2.6  94/03/10  18:15:54  CACHELIN4000
*Fix ProjectRenderNode() to call GrazerRenderNode()
*
*Revision 2.1  94/02/19  09:34:25  Kell
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/sghooks.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>

#include <edit.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <time.h>
#include <editwindow.h>
#include <project.h>
#include <filelist.h>
#include <gadgets.h>
#include <prophelp.h>
#include <grazer.h>
#include <editswit.h>
#include <crouton_all.h>
#include <request.h>
#include <tags.h>
#include <panel.h>

#ifndef PROOF_LIB_H
#include <proof_lib.h>
#endif

#include <croutongrid.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/diskfont.h>

#ifndef PROTO_PASS
#include <proto.h>
#else
extern APTR OpenEditWindow,CloseEditWindow;
DrawBGFunc *DrawBG();
struct EditWindow *HandleSaveProject(struct EditWindow *,struct IntuiMessage *);
#endif
LONG UpdateAccessWindowRows( LONG newrows );

//#define SERDEBUG	1
#include <serialdebug.h>

extern struct Library *ProofBase;
extern struct EditWindow *BotProjNewProject(struct EditWindow *,struct IntuiMessage *);
extern VOID KPutStr(char *);
extern LONG KPrintF( STRPTR fmt, ... );

extern WORD ViewMode;
extern WORD GrazerLayout;
extern struct Screen *EditScreen;
extern struct Gadget Gadget1;
extern struct BitMap FileBitMap;
extern ULONG CopyFastBitMap(struct BitMap *Source,
		ULONG SrcLeftEdge,ULONG SrcTopEdge,
		struct BitMap *Dest,ULONG DestLeftEdge,ULONG DestTopEdge,
		ULONG Width,ULONG Height);

extern struct TextFont *EditFont,*DarkFont;
extern struct EditWindow *EditTop,*EditBottom;
extern struct TextExtent LastExtent;
extern struct MsgPort *EditPort,*SwitPort;
extern char TempCh[],TempC2[],*DTNames[];
extern UBYTE *TempMem,*TempMem2;
extern struct EditPrefs UserPrefs;		// User preferences live here

// The following structures are used as temparary storage space for
// holding parameters that will be stuffed into a message and set
// to the switcher.  We have the different sized structures to make
// it easy to indicate the number of parameters being set.
struct ESParams1 ESparams1 = {1};
struct ESParams2 ESparams2 = {2};
struct ESParams3 ESparams3 = {3};
struct ESParams4 ESparams4 = {4};
struct ESParams5 ESparams5 = {5};
struct ESParams6 ESparams6 = {6};
struct ESParams7 ESparams7 = {7};
struct ESParams8 ESparams8 = {8};

struct FastGadget *CurFG,*FirstFG;
int	CurGrid=0,CurRow=0,CurCol=0;

char filepathbuf[300];

VOID __asm CopyCrut(
	register __a0 struct BitMap *SrcBM,
	register __a1 struct BitMap *DstBM,
	register __d0 WORD DestX,
	register __d1 WORD DestY,
	register __d2 WORD Height);

VOID DisplayWaitSprite(VOID);
VOID DisplayNormalSprite(VOID);

static UWORD TopIDS[] = {
	ID_UP,ID_DOWN,ID_KNOB,ID_GRID,
	ID_VCR_PLAY,ID_PLAY_PART,ID_REQ_STOP,ID_CONTROLS,
	ID_ALL,ID_DELETE,ID_DUPLICATE,ID_SAVE_PROJECT,
	ID_POPUP_PROGRAMS,ID_POPUP_VIEWS,ID_POPUP_TOOLS,
	ID_END_OF_LIST
};

static UWORD BottomIDS[] = {
	ID_UP,ID_DOWN,ID_CLOSE,ID_KNOB,ID_GRID,
	ID_NEW_PROJECT,
	ID_END_OF_LIST
};

#define MAX_STRING_BUFFER	300
#define DEF_PROJ_NAME		"WorkProject"
#define DEF_PROJ_DIR		"RAM:"
UBYTE PjName[369]  ="Toaster:Projects/"; // "RAM:WorkProject";
UBYTE *ProjectName=&(PjName[0]);
struct FastGadget **PtrProject = NULL;
struct FastGadget **XtrProject = NULL;
struct FastGadget *NoSwitPtr = NULL,*SKellFG;

#define SWITCHER_MODE	( (!EditBottom) && (!EditTop || (EditTop->Height!=TOP_LARGE)) )
#define EDITOR_MODE		(!SWITCHER_MODE)

BOOL ProjectSelect(struct EditWindow *Edit,struct EditNode *Node)
{
//	DUMPMSG("ProjectSelect");

	if (Node)
	{
		if( SWITCHER_MODE )
		{
			/* THIS MUST BE BEFORE THE SENDSWITCHERREPLY
			 *
			 *	The switcher may send a REDRAW before the
			 * SELECT comes back.  Redraw will automatically
			 * clear the OptRender flag.
			 *
			 */
			Edit->ew_OptRender = TRUE;

			ESparams1.Data1=(LONG)Node;
			SKellFG=(struct FastGadget *)Node;

			if(	SendSwitcherReply(ES_Select,&ESparams1) ||
					SendSwitcherReply(ES_Select,&ESparams1) )
			{
				// struct FastGadget	*fg = (struct FastGadget *)Node;

				// fg->FGDiff.FGNode.Behavior |= EN_BADCROUTON;
				// fg->FGDiff.FGNode.Redraw = TRUE;
			}

			if ( Edit->ew_cg )
			{
				LONG			nodenum;

				nodenum = GetProjNodeOrder(Edit,(struct FastGadget *)Node);

				ob_DoMethod( Edit->ew_cg,CRGRIDM_SelectCrouton,
					nodenum,GRIDSELECT_NORMAL,CROUTONSELECT_SELECTED);
			}

			Edit->RedrawSelect = TRUE;
			Edit->DisplayGrid = TRUE;
		}
		else
		{
			if ( Node != (struct EditNode *) SKellFG ) {
				SKellFG=NULL;
				SendSwitcher(ES_SelectDefault,NULL);
			}
		}
	}
	return(FALSE);
}

/****** Project/ProjectDuplicate **************************************
*
*   NAME
*	ProjectDuplicate
*
*   SYNOPSIS
*	BOOL ProjectDuplicate(struct EditWindow *Edit)
*
*   FUNCTION
*
*
*********************************************************************
*/
BOOL ProjectDuplicate(struct EditWindow *Edit)
{
	struct FastGadget	*fg,*ins_fg = NULL;
	struct FastGadget	*first_fg = NULL,*tail_fg,*duped;
	int	dupecount=0;

	// Since "next" pointer is first LONG of the FastGadget,
	// we just substitute the Address of the FG list head
	fg = (struct FastGadget *)((struct Project *)Edit->Special)->PtrPtr;

	// Copy all of the selected croutons into their
	// own little FastGadget list.

	while ( fg = (struct FastGadget *)GetNextEditNode(Edit,(struct EditNode *)fg) )
	{
		if ( fg->FGDiff.FGNode.Status == EN_SELECTED )
		{
			struct FastGadget	*dupe_fg;

			// Insert at last selected Node
			ins_fg = fg;

			fg->FGDiff.FGNode.Status = EN_NORMAL;
			fg->FGDiff.FGNode.Redraw = TRUE;

			if (dupe_fg = DupeProjNode(fg))
			{
				if (!first_fg)
				{
					first_fg = dupe_fg;
					tail_fg = first_fg;
				}
				else
				{
					tail_fg->NextGadget = dupe_fg;
					tail_fg = dupe_fg;
				}

				if ( EDITOR_MODE )
				{
					dupe_fg->FGDiff.FGNode.Status = EN_SELECTED;
					dupe_fg->FGDiff.FGNode.Redraw = TRUE;
				}

				dupecount++;
				duped = dupe_fg;
			}
		}
	}

	// Now Insert them into the list
	if ( first_fg )
	{
		// Insert these nodes into the list
		tail_fg->NextGadget = ins_fg->NextGadget;
		ins_fg->NextGadget = first_fg;
		CurFG = NULL;

		NewLengthUpdate(Edit);

		if( EDITOR_MODE ) {
			SKellFG=NULL;
			SendSwitcher(ES_SelectDefault,NULL);
		}
	}

	if (dupecount==1)
	{
		// Calculate and update crouton's current time
		CalcCurrentTime(duped);
	}
	else
		SetCurrentTime(-1);			// For a group, can't show a time

	return(FALSE);
}

/****** Project/ProjectDouble **************************************
*
*   NAME
*	ProjectDouble
*
*   SYNOPSIS
*	BOOL ProjectDouble(struct EditWindow *Edit,struct EditNode *Node)
*
*   FUNCTION
*
*
*********************************************************************
*/
BOOL ProjectDouble(struct EditWindow *Edit,struct EditNode *Node)
{
	DUMPMSG("ProjectDouble");

	if (Node)
	{
		ESparams1.Data1=(LONG)Node;

		if(SKellFG==(struct FastGadget *)Node)
		{
			DUMPMSG("SENT AUTO");
			SendSwitcherReply(ES_Auto,&ESparams1);
			//DUMPMSG("SENT Take");
			//SendSwitcher(ES_Take,&ESparams1);			//testing 021496DEH
		}
		else if(!SendSwitcherReply(ES_Select,&ESparams1))
		{
			DUMPMSG("SENT SELECT");
			SendSwitcher(ES_Auto,&ESparams1);
			DUMPMSG("SENT AUTO");
			CurFG=(struct FastGadget *)Node;
			SKellFG=(struct FastGadget *)Node;
			//DUMPMSG("SENT Take");
			//SendSwitcher(ES_Take,&ESparams1);			//testing 021496DEH
			
		}
		else
		{
			struct FastGadget	*fg = (struct FastGadget *)Node;

			DUMPMSG("ITS A BAD CROUTON");
			fg->FGDiff.FGNode.Behavior |= EN_BADCROUTON;
			fg->FGDiff.FGNode.Redraw = TRUE;
		}
	}
	return(FALSE);
}

/****** Project/ProjectDeleted **************************************
*
*   NAME
*	ProjectDeleted
*
*   SYNOPSIS
*	BOOL ProjectDeleted(struct EditWindow *Edit)
*
*   FUNCTION
*	Called when user deletes nodes in Edit
*
*********************************************************************
*/
BOOL ProjectDeleted(struct EditWindow *Edit)
{
	struct FastGadget *FG,*Next;
	BOOL Any = FALSE;

	if ((!(WFF_WARN_PROJDEL & UserPrefs.WarnFlags))		// Avoid req if disabled
	|| BoolRequest(Edit->Window,"Remove crouton(s) from project?"))
	{
		FG = *((struct Project *)Edit->Special)->PtrPtr;
		DisplayWaitSprite();
		while (FG)
		{
			Next = FG->NextGadget;
			if (FG->FGDiff.FGNode.Status == EN_SELECTED)
			{
				Any = TRUE;
				RemoveProjNode(Edit,FG);
				FreeProjectNode(FG);
			}
			FG = Next;
		}
		if (Any)
		{
			NewLengthUpdate(Edit);
			SKellFG=NULL;
			SendSwitcher(ES_SelectDefault,NULL);
			CurFG=NULL;
			SetCurrentTime(-1);				// Will be nothing hilited now, so erase this
		}
		DisplayNormalSprite();
	}
	return(FALSE);
}

/****** Project/ProjectRenderNode *************************************
*
*   NAME
*	ProjectRenderNode
*
*   SYNOPSIS
*	VOID ProjectRenderNode(struct EditWindow *Edit,struct EditNode *Node,
*		struct RastPort *RP,UWORD LeftEdge,UWORD TopEdge);
*
*   FUNCTION
*
*
*********************************************************************
*/
// #define SMALL_FX
VOID ProjectRenderNode(struct EditWindow *Edit,struct EditNode *Node,
		struct RastPort *RP,UWORD LeftEdge,UWORD TopEdge)
{
	UWORD X1,Y1,Y2,Max;
	struct BitMap *BM;
	struct FastGadget *FG;
	char *S;
#ifdef SMALL_FX
	UWORD X2;
	struct Gadget *Gadget;
	struct SmartString *S;
#endif

	X1 = LeftEdge;
	Y1 = TopEdge;

#ifdef SMALL_FX
	if(GrazerLayout) // Small icons, 160x25
	{
		Gadget = FindGadget(&Gadget1,ID_CROUTON_SMALL);
		DrawImage(RP,(struct Image *)Gadget->GadgetRender,X1,Y1);
		Gadget = FindGadget(&Gadget1,ID_SMALL_EFFECT);  // Should do custom image for CrUD_TYPE here
		DrawImage(RP,(struct Image *)Gadget->GadgetRender,X1+5,Y1+5);
		if (S = Node->Node.Name)
		{
			X2 = 5 + Gadget->Width;
			Move(RP,X1+X2,TopEdge+7+TEXT_BASELINE);
			SafeFitText(RP,GetCString(S),SmartStringLength(S),
			Edit->ImageWidth - X2 - 3,TRUE);
		}
	}
	else  // 80x50
#endif
	{
		Y2 = TopEdge + Edit->ImageHeight - 7;
		FG = (struct FastGadget *)Node;

		if( BM=(struct BitMap *)FG->Data )
		{
			struct Gadget	*Gadget = NULL;

			SetAPen(RP,SCREEN_PEN);
			SetDrMd(RP,JAM2);
			RectFill(RP,X1,Y1,X1+Edit->ColumnSize-1,Y1+Edit->RowSize-1);
			Y2 += 1;
			WaitBlit();
//			DUMPMEM("pj BM=",(APTR)BM,(LONG)sizeof(struct BitMap));
//			DUMPMEM("pj RPBM=",(APTR)(RP->BitMap),(LONG)sizeof(struct BitMap));
//			DUMPUDECL("pj X1=",(LONG)X1," ");
//			DUMPUDECL("pj Y1=",(LONG)X1," ");
//			DUMPUDECL("pj Rows=",(LONG)(Edit->RowSize),"\\");
			CopyCrut(BM,RP->BitMap,X1,Y1+1,Edit->RowSize-2);

			if ( ((struct ExtFastGadget *)FG)->SymbolFlags & SYMF_LOCKED )
			{
				Gadget = FindGadget(&Gadget1,ID_CROUTONSTAMP_LOCKED);
				if ( Gadget )
				{
					DrawImage(	RP,
						(struct Image *)Gadget->GadgetRender,
						X1 + 5,
						Y1 + 5 );
				}
			}

			if ( ((struct ExtFastGadget *)FG)->SymbolFlags & SYMF_AUDIO )
			{
				Gadget = FindGadget(&Gadget1,ID_CROUTONSTAMP_AUDIO);
				if ( Gadget )
				{
					DrawImage(	RP,
						(struct Image *)Gadget->GadgetRender,
						X1 + 80 - 13 - 5,			// Right-justified
						Y1 + 5 );
				}
			}

			if(
			/* (((struct ExtFastGadget *)FG)->ObjectType != CT_ERROR) && */	// NOT over "Lost" BM's
			   (BM->pad==0) ) // default icon, needs name
			{
				S = ((struct ExtFastGadget *)FG)->FileName;
				Max = strlen(S);
				S+=Max;
				Max=0;
				while((*(S-1)!=':') && (*(S-1)!='/') && (S>(char *)((struct ExtFastGadget *)FG)->FileName) )
				{
					S--;
					Max++;
				}
				Max = SafeFitText(RP,S,Max,Edit->ImageWidth - 6,FALSE);
				X1 += 8 + ((Edit->ImageWidth - 6) - LastExtent.te_Width)>>1;
				Move(RP,X1,Y2);
				SafeColorText(RP,S,Max);
			}
		}
	}
	WaitBlit();
}

/****** Project/ProjectDropped ****************************************
*
*   NAME
*	ProjectDropped
*
*   SYNOPSIS
*	BOOL ProjectDropped(struct EditWindow *Source,struct EditWindow *Dest,
*		UWORD DropMode, struct EditNode *DestNode)
*
*   FUNCTION
*	Called when Dest is EW_PROJECT, Source is (same)PROJECT/GRAZER
*	Drop all nodes in Source list into Dest Window at DropMode/DestNode
*	Source may == Dest
*
*********************************************************************
*/

// DropMode (if crouton dropped in current location)
#define DROP_INVALID 0
#define DROP_VALID 1	// if DragDestination FALSE, just VALID
#define DROP_INSERT 2	// if DragDestination TRUE, either INSERT/OVERWRITE
#define DROP_OVERWRITE 3
extern LONG RebuildGrazerGrid( struct EditWindow *Edit );

VOID NewLengthUpdate(struct EditWindow *E)
{
	if (E) {
		SafeFixRowCount(E);
		NewGridLength(E);

		CalcRunningTime();		// Re-calculate sequence running time
		DisplayRunningTime();	// Forces display, will clear message

		UpdateAccessWindowRows( E->CurrentRows );
		E->DisplayGrid = TRUE;
		E->RedrawList = TRUE;
	}
}

BOOL ProjectDropped(struct EditWindow *Source,struct EditWindow *Dest,
	UWORD DropMode, struct EditNode *DestNode, UWORD qualifiers)
{
	BOOL AnyDrop = FALSE;
	struct FastGadget *FG,*FDest,*dropped,*srcFG=NULL;
	struct EditNode *Node,*Next;
	struct Project *Project;
	char *MPtr[3];
	int	droppedcount=0;

	struct SmartString *Path,*Item;

//	DUMPMSG("Entered ProjectDropped() ... ");

	if (!DestNode) DestNode = GetLastEditNode(Dest);
	else if (DropMode == DROP_INSERT)
		DestNode = GetPrevEditNode(Dest,DestNode);

// *******************
// grazer->project
	if ( Source->Node.Type == EW_GRAZER )
	{
		// start of end of list so multiple selected stuff inserts correctly
		Node = (struct EditNode *)Source->Special->pEditList->lh_TailPred;
		while (Next=(struct EditNode *)Node->Node.MinNode.mln_Pred)
		{
			if ( Node->Status==EN_DRAGGING )
			{
				Node->Status = EN_NORMAL;
				Node->Redraw = TRUE;

				if ( !AnyDrop )
				{
					if( Dest->ew_cg )
					{
						ULONG		nodenum;

						nodenum = GetProjNodeOrder(Dest,SKellFG);

						if( EDITOR_MODE )
						{
							SKellFG=NULL;
							SendSwitcher(ES_SelectDefault,NULL);
							nodenum = -1;
						}

						ob_DoMethod( Dest->ew_cg,CRGRIDM_SelectCrouton,
							nodenum,GRIDSELECT_NORMAL,CROUTONSELECT_SELECTED);
					}
					else
					{
						ChangeStatusList(Dest,EN_SELECTED,EN_NORMAL);

						if( EDITOR_MODE )
						{
							SKellFG=NULL;
							SendSwitcher(ES_SelectDefault,NULL);
						}
						else if( SKellFG ) /* && SWITCHER_MODE  is this possible??*/
						{
							ChangeStatusNode(Dest,(struct EditNode *)SKellFG,EN_SELECTED);
						}
					}

					AnyDrop = TRUE;
				}

				if ( ((struct GrazerNode *)Node)->DOSClass==EN_FILE )		// Only LOAD files
				{
					Path = ((struct Grazer *)Source->Special)->Path;
					if ( (Item = DuplicateSmartString(Path)) && AppendToPath(Node->Node.Name,Item) )
					{
						if( (FG = AllocProj(GetCString(Item))) )
						{
							DUMPSTR("Adding Crouton ... ");
							//DUMPUDECL("FG type ",GetLongValue(FG,TAG_CroutonType),"\\");

							if (DestNode)
							{
								FG->NextGadget = ((struct FastGadget *)DestNode)->NextGadget;
								((struct FastGadget *)DestNode)->NextGadget = FG;
							}
							else
							{	// insert at beginning
								Project = (struct Project *)Dest->Special;
								FG->NextGadget = *(Project->PtrPtr);
								*(Project->PtrPtr) = FG;
							}

							if( EDITOR_MODE )
							{
								ChangeStatusNode(Dest,(struct EditNode *)FG,EN_SELECTED);
							}
							DUMPMSG("  . . . Crouton Added. ");

							droppedcount++;
							dropped = FG;

//							CurFG = FG;			// We need a CurFG valid after dropping!

							if (!srcFG)			// Can only inherit to one new FG
								srcFG = FG;
						}
					}

					if (Item) FreeSmartString(Item);
				}
			}

			Node = Next;
		}
		// *******************
		// project->project (may be same project)
	} else if (	Source->Node.Type == EW_PROJECT )
	{
		struct FastGadget	*prev_fg;

		// Temporary FG list
		struct FastGadget	*first_fg = NULL,*tail_fg;

		FDest = (struct FastGadget *)DestNode; // may be NULL

		// if dropped over itself, abort
		if (FDest && (FDest->FGDiff.FGNode.Status == EN_DRAGGING))
			DropMode = DROP_INVALID; // flag to move nothing

		// Since "next" pointer is first LONG of the FastGadget,
		// we just substitute the Address of the source FG list head
		prev_fg = (struct FastGadget *)((struct Project *)Source->Special)->PtrPtr;

		// Move all of the selected source gadgets into their
		// own little FastGadget list.

		while ( FG = (struct FastGadget *)GetNextEditNode(Source,(struct EditNode *)prev_fg) )
		{
			if ( FG->FGDiff.FGNode.Status == EN_DRAGGING )
			{
				droppedcount++;
				dropped = FG;

				FG->FGDiff.FGNode.Status = EN_NORMAL;
				FG->FGDiff.FGNode.Redraw = TRUE;
				AnyDrop = TRUE;

				srcFG = FG;			// Remember last FG of those selected

				switch( DropMode )
				{
				case DROP_OVERWRITE:
				case DROP_INSERT:
					Dest->RedrawList = TRUE;
					Dest->DisplayGrid = TRUE;

					if ( Dest->Location == EW_TOP )
					{
						if (Source == Dest)
						{	// Movement within project

							// Remove the gad from the list
							prev_fg->NextGadget = FG->NextGadget;

							if (!first_fg)
							{
								first_fg = FG;
								tail_fg = first_fg;
							}
							else
							{
								tail_fg->NextGadget = FG;
								tail_fg = FG;
							}

							if ( EDITOR_MODE )
								FG->FGDiff.FGNode.Status = EN_SELECTED;
						}
						else
						{	// From bottom (read only) project to work proj
							struct FastGadget	*New;

							if (New = DupeProjNode(FG))
							{
								if (!first_fg)
								{
									first_fg = New;
									tail_fg = first_fg;
								}
								else
								{
									tail_fg->NextGadget = New;
									tail_fg = New;
								}

								if ( EDITOR_MODE )
									New->FGDiff.FGNode.Status = EN_SELECTED;
							}
						}
					}
				}
			}
			else
			{
				prev_fg = (struct FastGadget *)GetNextEditNode(Source,(struct EditNode *)prev_fg);
			}
		}

		// Now Insert them into the list
		if ( first_fg )
		{
			struct FastGadget	*ins_fg = (struct FastGadget *)DestNode;

			if ( !ins_fg )
			{
				ins_fg = (struct FastGadget *)((struct Project *)Dest->Special)->PtrPtr;
			}

			// Insert these node into the list
			tail_fg->NextGadget = ins_fg->NextGadget;
			ins_fg->NextGadget = first_fg;

			srcFG = first_fg;		// This one inherits the tags on overwrite
		}
	}

// handle OVERWRITE
	if (AnyDrop && DestNode && (DropMode == DROP_OVERWRITE))
	{
		struct FastGadget	*wasFG;
		BOOL	doit=FALSE, inherit=FALSE, backout=FALSE;

		// Verify we should overwrite & inherit
		if ((droppedcount==1) && (qualifiers & (IEQUALIFIER_LALT|IEQUALIFIER_RALT)))
		{
			inherit = TRUE;		// Assuming we pass requester test below

			MPtr[0] = "Are you sure you want to overwrite and inherit info from";

			if ((!(WFF_WARN_INHERIT & UserPrefs.WarnFlags))	// Avoid req if disabled
			|| (qualifiers & IEQUALIFIER_CONTROL))				// Manually override req?
				doit = TRUE;
		}
		else	// Verify we should overwrite
		{
			MPtr[0] = "Are you sure you want to overwrite";
			// Double-check to MAKE SURE we should overwrite this guy!

			if ((!(WFF_WARN_PROJOVERWR & UserPrefs.WarnFlags))	// Avoid req if disabled
			|| (qualifiers & IEQUALIFIER_CONTROL))					// Manually override req?
				doit = TRUE;
		}

		// If overwriting not yet approved, ask user
		if (!doit)
		{
			MPtr[1] = ((struct ExtFastGadget *)DestNode)->FileName;	// Crouton name
			MPtr[2] = "Press OK to overwrite, CANCEL to insert";
			doit = SimpleRequest(Dest->Window,MPtr,3,REQ_CENTER|REQ_H_CENTER|REQ_OK_CANCEL,NULL);
		}

		if (doit)		// Should we overwrite?
		{
			DUMPHEXIL("CurFG was: ",(LONG)CurFG,"		");
			Node = GetPrevEditNode(Dest,DestNode);

			if (Node)
			{
				wasFG = ((struct FastGadget *)Node)->NextGadget;

				((struct FastGadget *)Node)->NextGadget =
					((struct FastGadget *)DestNode)->NextGadget;
			}
			else
			{
				wasFG = *((struct Project *)Dest->Special)->PtrPtr;

				*((struct Project *)Dest->Special)->PtrPtr =
					((struct FastGadget *)DestNode)->NextGadget;
			}
			if(CurFG==(struct FastGadget *)DestNode)
			{
				DUMPHEXIL("CurFG was: ",(LONG)CurFG,"		");
				CurFG=(struct FastGadget *)FG;
				DUMPHEXIL("CurFG is: ",(LONG)CurFG,"\\");
			}
			if(SKellFG==(struct FastGadget *)DestNode) SKellFG=NULL;

			//Wanted me to inherit tags?
			if (inherit)
			{
				if (!InheritTags(Dest->Window,(struct FastGadget *)DestNode,srcFG))
					backout = TRUE;		// If cancelled this or failed, back out!
			}

			if (backout)			// Undo the overwrite (do not insert either)
			{
				// Reinsert deleted original
				if (Node)
					((struct FastGadget *)Node)->NextGadget = wasFG;
				else
					*((struct Project *)Dest->Special)->PtrPtr = wasFG;

//				wasFG = ((struct FastGadget *)DestNode)->NextGadget;
//				RemoveProjNode(EditTop,wasFG);		// Remove new insert
//				FreeProjectNode(wasFG);					// Free it
			}
			else
				FreeProjectNode((struct FastGadget *)DestNode);
		}
	}

	if ((droppedcount==1) && (DropMode != DROP_INVALID))
	{
		// Calculate and update crouton's current time
		CalcCurrentTime(dropped);
	}
	else
		SetCurrentTime(-1);			// For a group, can't show a time

	NewLengthUpdate(Dest);

	if (Dest != Source)
		NewLengthUpdate(Source);

	return(FALSE);
}

/****** Project/ArrangeProjectGadgets *********************************
*
*   NAME
*	ArrangeProjectGadgets
*
*   SYNOPSIS
*	VOID ArrangeProjectGadgets(struct EditWindow *Edit,UWORD WindowHeight)
*
*   FUNCTION
*	Arranges gadgets given Project
*
*********************************************************************
*/
#define X_GAP1 1
#define XX 5
VOID ArrangeProjectGadgets(struct EditWindow *Edit,UWORD WindowHeight)
{
	struct Gadget *Grid,*Play,*Control,
		*All,*Delete,*Duplicate,*Save,*ViewPop,*ProgPop,*ToolsPop,
		*NewProj,*Stop,*PlayPart;

// please note the Window may not be open
	Grid = FindGadget(Edit->Gadgets,ID_GRID);
	Grid->TopEdge = GRID_TOP;

	if ( Edit->Location == EW_TOP )
	{
		if (Edit->Height == TOP_SMALL) Grid->Height = 200;
		else Grid->Height = 400;
	}
	else Grid->Height = 175;

	// setup ID_GRID's Height
	if (Edit->Location == EW_TOP)
	{
		// Close = FindGadget(Edit->Gadgets,ID_CLOSE);
		Play = FindGadget(Edit->Gadgets,ID_VCR_PLAY);

		PlayPart = FindGadget(Edit->Gadgets,ID_PLAY_PART);
		PlayPart->UserData = (APTR) HandlePlay;

		Stop = FindGadget(Edit->Gadgets,ID_REQ_STOP);
		Control = FindGadget(Edit->Gadgets,ID_CONTROLS);


		/* Hack "select all" to be disabled */
		All = FindGadget(Edit->Gadgets,ID_ALL);

		/* temporarily using the delete gadget to find correct imagery */
//		if ( SWITCHER_MODE )
		if ( ViewMode == VIEW_PROJ_SWIT )
			Delete = FindGadget(&Gadget1,ID_GHOST_ALL);
		else
			Delete = FindGadget(&Gadget1,ID_ALL);

		/* Clone it, allocating new imagery */
		if ( Delete = AllocOneGadget(Delete) )
		{
			/* Replace the "All" gadget in the list */
			/* Currently, its predecessor is the Controls gadget */

			Control->NextGadget = Delete;
			Delete->NextGadget = All->NextGadget;
			FreeGadget(All);

			All = Delete;
			All->GadgetID = ID_ALL;
		}

		Delete = FindGadget(Edit->Gadgets,ID_DELETE);
		Duplicate = FindGadget(Edit->Gadgets,ID_DUPLICATE);
		Save = FindGadget(Edit->Gadgets,ID_SAVE_PROJECT);

		ProgPop = FindGadget(Edit->Gadgets,ID_POPUP_PROGRAMS);
		ViewPop = FindGadget(Edit->Gadgets,ID_POPUP_VIEWS);
		ToolsPop = FindGadget(Edit->Gadgets,ID_POPUP_TOOLS);
	}
	else
	{
		NewProj = FindGadget(Edit->Gadgets,ID_NEW_PROJECT);
		NewProj->UserData = (APTR) BotProjNewProject;;
	}

	if (ArrangeEditGadgets(Edit))
	{
		if (Edit->Location == EW_TOP)
		{
			Stop->TopEdge = Control->TopEdge = PlayPart->TopEdge =
			All->TopEdge = Delete->TopEdge = Duplicate->TopEdge =
			ToolsPop->TopEdge = Save->TopEdge = ViewPop->TopEdge =
			ProgPop->TopEdge = Play->TopEdge = Grid->Height + 5;

			ToolsPop->Width = 59;

			Delete->LeftEdge = GRID_LEFT;

			All->LeftEdge = Delete->LeftEdge + Delete->Width + 2*XX-1;
			Duplicate->LeftEdge = All->LeftEdge + All->Width;
			ToolsPop->LeftEdge = Duplicate->LeftEdge + Duplicate->Width;
			Control->LeftEdge = ToolsPop->LeftEdge + ToolsPop->Width + 1;

			Play->LeftEdge =  Control->LeftEdge + Control->Width + 2*XX-1;
			PlayPart->LeftEdge = Play->LeftEdge + Play->Width-1;
			Stop->LeftEdge = PlayPart->LeftEdge + PlayPart->Width;
			Save->LeftEdge = Stop->LeftEdge + Stop->Width + 2*XX-1;

			ProgPop->LeftEdge = Save->LeftEdge + Save->Width + 2*XX-1;
			ProgPop->Width = 92;
			ViewPop->Width = 65;
			ToolsPop->Height = ProgPop->Height = ViewPop->Height = 19;
			ViewPop->LeftEdge = ProgPop->LeftEdge + ProgPop->Width+1;

		}
		else
		{
			NewProj->TopEdge = Grid->Height + 5;
			NewProj->LeftEdge = (Grid->LeftEdge + Grid->Width) - (NewProj->Width + XX);
		}
	}
}

/****** Project/FreeProject ******************************************
*
*   NAME
*	FreeProject
*
*   SYNOPSIS
*	VOID FreeProject(struct EditWindow *Edit)
*
*   FUNCTION
*	Frees it all
*
*********************************************************************
*/
VOID FreeProjectNode(struct FastGadget *FG)
{
#ifndef SWIT_ONLY
	if (!SwitPort) {
		if (FG->Data)
			FreeMem(FG->Data,CR_PLANE*2);
		FreeMem(FG,sizeof(struct FastGadget));
	} else {
#endif
	DUMPMSG("Before FreeProjectNode() sends ES_FreeCrouton");
	ESparams1.Data1=(LONG)FG;
	SendSwitcher(ES_FreeCrouton,&ESparams1);
	DUMPMSG("  After FreeProjectNode() sent ES_FreeCrouton");
#ifndef SWIT_ONLY
	}
#endif
}

//*******************************************************************
VOID FreeProjectList(struct Project *Project)
{
	struct FastGadget *FG,*Next;

	FG = *(Project->PtrPtr);
	while (FG) {
		Next = FG->NextGadget;
		FreeProjectNode(FG);
		FG = Next;
	}
	*(Project->PtrPtr) = NULL;
}

//*******************************************************************
VOID FreeProject(struct EditWindow *Edit)
{
	if (Edit) {
		FreeEditWindow(Edit);
		if (Edit->Special) {
#ifndef SWIT_ONLY
		if (!SwitPort) FreeProjectList((struct Project *)Edit->Special);
#endif
			FreeMem(Edit->Special,sizeof(struct Project));
		}
		FreeSmartNode(&Edit->Node);
	}
}

//*******************************************************************
// sets up my fields in FG for use by project editor
BOOL __regargs ProjFGInit(struct FastGadget *FG)
{
	if (FG) {
		FG->FGDiff.FGNode.Behavior = EN_DRAGGABLE | EN_SELECT_ACTION
			| EN_DOUBLE_ACTION;
		return(TRUE);
	}
	return(FALSE);
}

//*******************************************************************
BOOL __regargs InitProject(struct Project *Project)
{
	struct FastGadget *FG;

	if( (FG=*(Project->PtrPtr))==NULL )
		return(FALSE);

	CurFG = NULL;

	while (FG) {
		if (!ProjFGInit(FG)) return(FALSE);
		FG = FG->NextGadget;
	}

	return(TRUE);
}


BOOL TagFilter(struct ExtFastGadget *FG)
{

	ULONG	KeyFade = 0;
	
	DUMPMSG("***************** IN TAGFILTER *****************");
//	DUMPUDECL("*FG ",FG,"\\");
//	DUMPUDECL("FG type ",GetLongValue(FG,TAG_CroutonType),"\\");
	DUMPHEXIL("FG type ",(struct ExtFastGadget *)FG->ObjectType,"\\");
	DUMPHEXIL("FG type ",(struct ExtFastGadget *)FG->TagLists,"\\");

	// see if its a key
	if (((struct ExtFastGadget *)FG)->ObjectType==0x4b455946)
	{
		// if it is a key check UserPrefs
		if (!(UserPrefs.CGKeyFlagsOn))
			KeyFade = 1; 
		if (!(UserPrefs.CGKeyFlagsOff))
			KeyFade |= 2; 
		//  put the correct tag as set by UserPrefs.
		PutValue(FG,TAG(Speed),KeyFade);
	}
	return(TRUE);
} 




//*******************************************************************
BOOL __regargs InitSetupProject(struct EditWindow *E)
{
	InitProject((struct Project *)E->Special);

	NewLengthUpdate(E);
// DOES ALL THIS PLUS CALC'ING PROGRAM TIME
//	SafeFixRowCount(E);
//	NewGridLength(E);
//	UpdateAccessWindowRows( E->CurrentRows );
//	E->RedrawList = TRUE;
//	E->DisplayGrid = TRUE;

	E->ew_OptRender = FALSE;
	return(TRUE);
}

//*******************************************************************
struct FastGadget *AllocProj(char *FileName)
{
	struct FastGadget *New = NULL;

	if (!SwitPort)
	{
		if (New = SafeAllocMem(sizeof(struct FastGadget),MEMF_CLEAR))
			New->Flags2 = CR_VidEvent;
	}
	else
	{
		BPTR		lock;

		if ( lock = Lock(FileName,ACCESS_READ) )
		{
			BOOL			gotvolpath;

			gotvolpath = NameFromLock(lock,filepathbuf,sizeof(filepathbuf));

			UnLock(lock);

			if ( gotvolpath )
			{
				ESparams2.Data1=(LONG)filepathbuf;
				ESparams2.Data2=0;
				New = (struct FastGadget *)SendSwitcherReply(ES_LoadCrouton,&ESparams2);
			}
		}
	}
	if (New)
	{	
		ProjFGInit(New);
		TagFilter(New);
	}
	return(New);
}

//*******************************************************************
struct FastGadget *DupeProjNode(struct FastGadget *FG)
{
	struct FastGadget *New;

#ifndef SWIT_ONLY
	if (!SwitPort) {
	if (New = AllocProj(NULL)) {
		CopyMem(FG,New,sizeof(struct FastGadget));
		New->NextGadget = NULL;
		if (FG->Data) {
			if (New->Data = SafeAllocMem(CR_PLANE*2,0))
				CopyMem(FG->Data,New->Data,CR_PLANE*2);
		}
	}
	} else {
#endif
		DUMPMSG("Before DupeProjNode() sends ES_DuplicateCrouton");
		ESparams1.Data1=(LONG)FG;
		New = (struct FastGadget *)
			SendSwitcherReply(ES_DuplicateCrouton,&ESparams1);
		DUMPMSG("  After DupeProjNode() sent ES_DuplicateCrouton");
	if (New) ProjFGInit(New);
#ifndef SWIT_ONLY
	}
#endif
	return(New);
}

//*******************************************************************
BOOL __regargs GetLoadedProject(struct EditWindow *Edit)
{
	BOOL Success = FALSE;

	if ( Edit!=EditBottom )
	{
		if ( PtrProject )
		{
			((struct Project *)Edit->Special)->PtrPtr = PtrProject;
			InitProject((struct Project *)Edit->Special);

			if ( Edit->ew_cg )
				ob_DoMethod( Edit->ew_cg,CRGRIDM_BuildGridFromFGList,
					((struct Project *)Edit->Special)->PtrPtr );
			Success = TRUE;
		}
	}
	else if ( XtrProject )
	{
		((struct Project *)Edit->Special)->PtrPtr = XtrProject;
		InitProject((struct Project *)Edit->Special);

		if ( Edit->ew_cg )
			ob_DoMethod( Edit->ew_cg,CRGRIDM_BuildGridFromFGList,
				((struct Project *)Edit->Special)->PtrPtr );
    Success = TRUE;
	}
	return(Success);
}

/****** Project/ResizeProject ***************************************
*
*   NAME
*	ResizeProject
*
*   SYNOPSIS
*	BOOL ResizeProject(struct EditWindow *Edit,UWORD NewHeight)
*
*   FUNCTION
*	Called by ResizeEditWindow(), does project-specific changes
*
*********************************************************************
*/
BOOL ResizeProject(struct EditWindow *Edit,UWORD NewHeight)
{
	BOOL Success;

	ArrangeProjectGadgets(Edit,NewHeight);
	CalcGridDimensions(Edit); // re-calc as soon as grid re-sized
	NewGridLength(Edit);

	if ( Edit->ew_cg )
	{
		struct Gadget *Grid;

		Grid = FindGadget(Edit->Gadgets,ID_GRID);

		ob_SetAttrs( Edit->ew_cg,
			CRGRIDA_DestHeight,	Grid->Height,
			TAG_DONE );
	}

	Success = TRUE;
	return(Success);
}

/****** Project/ProjectAll **********************************
*
*   NAME
*	ProjectAll
*
*   SYNOPSIS
*	BOOL ProjectAll(struct EditWindow *Edit)
*
*   FUNCTION
*
*
*********************************************************************
*/
BOOL ProjectAll(struct EditWindow *Edit)
{
	SKellFG=NULL;
	SendSwitcher(ES_SelectDefault,NULL);

	if ( Edit->ew_cg )
	{
		ob_DoMethod( Edit->ew_cg,CRGRIDM_SelectCrouton,
			CROUTONNUM_ALL,GRIDSELECT_NORMAL,CROUTONSELECT_SELECTED);

		Edit->ew_OptRender = TRUE;
		Edit->RedrawSelect = TRUE;
		Edit->DisplayGrid = TRUE;
	}
	else
	{
		ChangeStatusList(Edit,EN_NOT_STATUS,EN_SELECTED);
	}

	return(TRUE);
}

/****** Project/AllocInitProject ******************************************
*
*   NAME
*	AllocInitProject
*
*   SYNOPSIS
*	struct EditWindow *AllocInitProject(struct NewProject *NewProject)
*
*   FUNCTION
*	Allocates a Project, but does not open it
*
*********************************************************************
*/
struct EditWindow *AllocInitProject(struct NewProject *NewProject)
{
	struct Project *Project;
	struct EditWindow *Edit;
	UWORD *IDS;
	BOOL Success = FALSE;
	struct Gadget *Gadget;

	if (NewProject->NewEdit.Location == EW_TOP)
	{
		IDS = TopIDS;
	}
	else IDS = BottomIDS;

	if ((Edit=(struct EditWindow *)AllocSmartNode(NULL,sizeof(struct EditWindow),
		MEMF_CLEAR)) &&
		(Edit->Special = (struct EditSpecial *)AllocSmartNode(NULL,sizeof(struct Project),
		MEMF_CLEAR))) {

		Project = (struct Project *)Edit->Special;
		Project->PtrPtr = &NoSwitPtr;

		Edit->Node.Type = EW_PROJECT;
		Edit->DragDestination = TRUE;
		Edit->NodeDropped = ProjectDropped;
		Edit->NodeDeleted = ProjectDeleted;
		Edit->NodeDuplicate = ProjectDuplicate;
		Edit->NodeDouble = ProjectDouble;
		Edit->SelectAll = ProjectAll;
		Edit->NodeSelect = ProjectSelect;

		Edit->RenderNode = ProjectRenderNode;
		Edit->Resize = ResizeProject;
		Edit->Open = OpenEditWindow; // no special requirements
		Edit->Close = CloseEditWindow;  // no special requirements
		Edit->Free = FreeProject;

		if ((InitEditWindow(Edit,&NewProject->NewEdit))
			&& (Edit->Gadgets = AllocGadgetIDS(IDS,&Gadget1))) {

			ArrangeProjectGadgets(Edit,NewProject->NewEdit.Height);

			Edit->ColumnSize = Edit->IconWidth;
			Edit->RowSize = Edit->IconHeight;
			Edit->ImageWidth = Edit->ColumnSize-2;
			Edit->ImageHeight = Edit->RowSize-2;
			CalcGridDimensions(Edit);

			Gadget = FindGadget(Edit->Gadgets,ID_KNOB);
			if (AllocGrid(Edit)) {
				Success = TRUE;
			}
		}

		if (!Success) {
			if (Edit) {
				FreeProject(Edit);
				Edit = NULL;
			}
		}
	}
	return(Edit);
}

//*******************************************************************
VOID AddProjTail(struct Project *Project,struct FastGadget *FG)
{
	struct FastGadget *End;

	End = *(Project->PtrPtr);
	if (!End) {
		*(Project->PtrPtr) = FG;
	} else {
		while (End->NextGadget) End = End->NextGadget;
		End->NextGadget = FG;
	}
}

//*******************************************************************
VOID AddProjHead(struct Project *Project,struct FastGadget *FG)
{
	if (FG) {
		FG->NextGadget = *(Project->PtrPtr);
		*(Project->PtrPtr) = FG;
	}
}

//*******************************************************************
// starts numbering with zero
struct FastGadget *GetProjNode(struct FastGadget *Node,UWORD A)
{
	while (A && Node) {
		Node = Node->NextGadget;
		A--;
	}
	return(Node);
}

//*******************************************************************
struct EditNode *GetEditNode(struct EditWindow *Edit,UWORD A)
{
	if (A < 1) A = 1; // starts with 1, like GetNode()

	if (Edit->Node.Type == EW_GRAZER)
	{
		struct EditNode *Node = (struct EditNode *)Edit->Special->pEditList->lh_Head;

		while ( Node->Node.MinNode.mln_Succ )
		{
			if ( !(--A) )
				break;

			Node = (struct EditNode *)Node->Node.MinNode.mln_Succ;
		}

		if (Node->Node.MinNode.mln_Succ)
			return(Node);
		else
			return(NULL);
	}
	else
		return((struct EditNode *)GetProjNode(*(((struct Project *)
			Edit->Special)->PtrPtr),A-1));
}

//*******************************************************************
UWORD GetEditNodeStatus(struct EditWindow *Edit,struct EditNode *Node)
{
	if (Edit->Node.Type == EW_GRAZER) return(Node->Status);
	else return(((struct FastGadget *)Node)->FGDiff.FGNode.Status);
}

//*******************************************************************
UWORD GetEditNodeBehavior(struct EditWindow *Edit,struct EditNode *Node)
{
	if (Edit->Node.Type == EW_GRAZER) return(Node->Behavior);
	else return(((struct FastGadget *)Node)->FGDiff.FGNode.Behavior);
}

//*******************************************************************
struct EditNode *GetNextEditNode(struct EditWindow *Edit,struct EditNode *Node)
{
	if (!Node) return(NULL);
	if (Edit->Node.Type == EW_GRAZER)
	{
		Node = (struct EditNode *)Node->Node.MinNode.mln_Succ;

		if (Node->Node.MinNode.mln_Succ)
			return(Node);
		else
			return(NULL);
	} else
		return((struct EditNode *)((struct FastGadget *)Node)->NextGadget);
}

//*******************************************************************
struct EditNode *GetPrevEditNode(struct EditWindow *Edit,struct EditNode *Node)
{
	struct EditNode *Next;
	struct FastGadget *FG;

	if (!Node) return(NULL);
	if (Edit->Node.Type == EW_GRAZER) {
		Next = (struct EditNode *)Node->Node.MinNode.mln_Pred;
		if (Next->Node.MinNode.mln_Pred) return(Next);
		else return(NULL);
	} else {
		FG = *(((struct Project *)Edit->Special)->PtrPtr);
		while (FG) {
			if (FG->NextGadget == (struct FastGadget *)Node)
				return((struct EditNode *)FG);
			FG = FG->NextGadget;
		}
		return(NULL);
	}
}

//*******************************************************************
VOID RemoveProjNode(struct EditWindow *Edit,struct FastGadget *FG)
{
	struct FastGadget *FNext;

	if (FG) {
		FNext = (struct FastGadget *)GetPrevEditNode(Edit,(struct EditNode *)FG);
		if (FNext) FNext->NextGadget = FG->NextGadget;
		else *(((struct Project *)Edit->Special)->PtrPtr) = FG->NextGadget;
	}
}

//*******************************************************************
// if Exist NULL, add to head of list
VOID InsertProjNode(struct EditWindow *Edit,struct FastGadget *Exist,
	struct FastGadget *FG)
{
	if (FG) {
		if (!Exist) AddProjHead((struct Project *)Edit->Special,FG);
		else {
			FG->NextGadget = Exist->NextGadget;
			Exist->NextGadget = FG;
		}
	}
}

//*******************************************************************
LONG GetProjNodeOrder(struct EditWindow *Edit,struct FastGadget *find_fg )
{
	LONG						 retval = -1,order = 0;
	struct FastGadget		*fg;

	fg = *(((struct Project *)Edit->Special)->PtrPtr);

	while ( fg )
	{
		if ( fg == find_fg )
		{
			retval = order;
			break;
		}

		fg = fg->NextGadget;
		order++;
	}

	return(retval);
}

LONG GetGrazerNodeOrder(struct EditWindow *Edit,struct EditNode *find_en )
{
	LONG						 retval = -1,order = 0;
	struct EditNode		*en;

	en = (struct EditNode *)Edit->Special->pEditList->lh_Head;

	while ( en->Node.MinNode.mln_Succ )
	{
		if ( en == find_en )
		{
			retval = order;
			break;
		}

		en = (struct EditNode *)en->Node.MinNode.mln_Succ;
		order++;
	}

	return(retval);
}

//*******************************************************************
struct EditNode *GetLastEditNode(struct EditWindow *Edit)
{

	if (Edit->Node.Type == EW_GRAZER)
	{
		struct EditNode *Node;

		Node = (struct EditNode *)Edit->Special->pEditList->lh_TailPred;
		if (!Node->Node.MinNode.mln_Pred) return(NULL);
		else return(Node);

	}
	else
	{
		struct FastGadget *FG;

		FG = *(((struct Project *)Edit->Special)->PtrPtr);
		if (!FG) return(NULL);
		while (FG->NextGadget) {
			FG = FG->NextGadget;
		}

		return((struct EditNode *)FG);
	}
}

//*******************************************************************
UWORD GetEditListLen(struct EditWindow *Edit)
{
	if (Edit->Node.Type == EW_GRAZER)
		return((UWORD)ListLength(Edit->Special->pEditList));
	else
		return(SingleListLength(*(((struct Project *)Edit->Special)->PtrPtr)));
}

//*******************************************************************
UWORD SingleListLength(struct FastGadget *FG)
{
	UWORD A=0;

	while (FG) {
		A++;
		FG = FG->NextGadget;
	}
	return(A);
}

//*******************************************************************
BOOL GetEditNodeRedraw(struct EditWindow *Edit,struct EditNode *Node)
{
	if (Edit->Node.Type == EW_GRAZER) return(Node->Redraw);
	else return(((struct FastGadget *)Node)->FGDiff.FGNode.Redraw);
}

//*******************************************************************
BOOL SafeFixRowCount(struct EditWindow *Edit)
{
	UWORD A;

	if ( Edit->ew_cg )
		A = FALSE;
	else
		A = FixIconRowCount(Edit->ScrollGrid,GetEditListLen(Edit));

	if (A) ContinueRequest(Edit->Window,IoErrToText(ERROR_NO_FREE_STORE));
	return(TRUE);
}

//*******************************************************************
// attempts to get imagery out of grazer node
VOID GetImageGrazer(struct FastGadget *FG,struct GrazerNode *Node)
{
	UWORD A,Depth;
	UBYTE *B;

	if (FG && Node && Node->BitMap) {
		Depth = Node->BitMap->Depth;
		if (FG->Data = SafeAllocMem(CR_PLANE*Depth,0)) {
			B = FG->Data;
			for (A=0; A < Depth; A++) {
				CopyMem(Node->BitMap->Planes[A],B,CR_PLANE);
				B += CR_PLANE;
			}
		}
	}
}

//*******************************************************************
LONG EndProjSaveRequest( struct GrazerRequest *gr, LONG mode );

static char *ProjSaveReqText[] = {
	"Save Project",
	"Locate the directory and project below using the file requester.",
	"Enter a filename and Select \"Continue\" to save the project.",
};
#define PROJ_SAVE_REQTEXT_NUMLINES	3

struct GrazerRequest ProjSaveGrazRequest = {

	ProjSaveReqText,
	PROJ_SAVE_REQTEXT_NUMLINES,

	NULL,
	0,

	0,
	0,
	0,

	GRAZREQ_ALLOWCREATE | GRAZREQ_RESTOREVIEW | GRAZREQ_BACKUP,

	EndProjSaveRequest,
};

struct EditWindow *HandleSaveProject(
	struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	/* Set initial path of grazer */
	char		*f,c;

	/* only get path part of project name */
	f = FilePart(ProjectName);

	/* Store the file name */
	strcpy(ProjSaveGrazRequest.gr_InitialFileName,f);

	c = *f;	*f = '\0';

	/* Store the directory */
	ProjSaveGrazRequest.gr_InitialPath = AllocSmartString(ProjectName,NULL);
	*f = c;

	/* Determine if there are any tape drives out there, and enable
	 * the "Backup" button if there are any.
	 */

	/* Clear this for "Backup" button */
	ProjSaveGrazRequest.gr_UserData = 0;

	BeginGrazerRequest( &ProjSaveGrazRequest );
	Edit = EditTop; // old one gone
	return(Edit);
}

LONG EndProjSaveRequest( struct GrazerRequest *gr, LONG mode )
{
	LONG						 retval = 0;

	if ( mode && (gr->gr_Flags & GRAZREQ_VALIDFILENAME) )
	{
		ESparams2.Data1=0;
		ESparams2.Data2=(LONG)GetCString(gr->gr_FilePath);
		if ( !SendSwitcherReply(ES_SaveProject,&ESparams2) )
		{
		// Success!
			retval = TRUE;
			strcpy(ProjectName,GetCString(gr->gr_FilePath));

			/* "Backup" button will set "gr_UserData" */
			if ( gr->gr_UserData )
			{
				extern LONG DoProjectBackup( STRPTR projname, STRPTR device, LONG unit, struct Window *win );
				struct Window		*win;

				win = EditTop->Window;

				DoProjectBackup( ProjectName, "flyerscsi.device", -1, win );
			}
		}
		else
		{
			// Some Error condition.
			ContinueRequest(EditTop->Window,"Error -- Project not saved!");
		}
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

	return(retval);
}
// end of project.c
