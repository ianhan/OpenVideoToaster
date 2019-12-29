/********************************************************************
* $GraphicHelp.c$
* $Id: graphichelp.c,v 2.68 1995/12/01 12:41:21 pfrench Exp $
* $Log: graphichelp.c,v $
*Revision 2.68  1995/12/01  12:41:21  pfrench
*Fixed Arexx Requester redraw bug
*
*Revision 2.67  1995/11/08  15:31:47  Flick
*Moved defines for Tools/Programs popups into Edit.h for others to safely see
*Upped limit for Tools popup to 32 (20 user tools).
*
*Revision 2.66  1995/10/12  16:34:32  Flick
*Reordered Tools & Views popups, now use VIEW_xxx defines everywhere!
*
*Revision 2.65  1995/10/10  17:21:09  Flick
*Made Views,Programs,Tools popups all left-justify
*
*Revision 2.64  1995/10/09  16:40:47  Flick
*Finds popup.h in new home
*
*Revision 2.63  1995/10/05  18:37:03  Flick
*Auto split ---> Auto Insert
*
*Revision 2.62  1995/10/03  18:06:30  Flick
*Tools popup now supports user-installable tools (from ARexx)
*Added divider line to tools popup and at bottom of Programs & Tools if custom things present
*
*Revision 2.61  1995/10/02  15:15:53  Flick
*Support for new POPUP_TOOLS gadget + dispatch to all items
*
*Revision 2.60  1995/09/28  10:08:35  Flick
*Now uses RawKeyCodes.h, changed "QUIT" to "SHUTDOWN", Project-Project msg now reads "Hit 'OK' "
*
*Revision 2.59  1995/09/13  12:16:38  Flick
*ENTER key appeased requesters but returned FALSE (fixed this)
*
*Revision 2.58  1995/03/05  17:03:04  CACHELIN4000
*Add GrazerGetFile(), fix ASync String width
*
*Revision 2.57  1995/02/27  15:36:15  pfrench
*Now using new backup button on requester.
*
*Revision 2.56  1995/02/25  16:00:08  CACHELIN4000
*Make Programs popup extensible through static global array kludge for ARexx
*
*Revision 2.55  1995/02/24  12:06:18  pfrench
*Not sure if change I made does anything.
*
*Revision 2.54  1995/01/25  19:36:25  pfrench
*Added support for backup button in the async requester
*
*Revision 2.53  1995/01/13  13:00:05  CACHELIN4000
*Set ViewMode initial value to 2, match initial Proj/Switcher mode.
*
*Revision 2.52  1994/12/31  08:14:02  pfrench
*No longer shuts out dump-lightwave menu item
*
*Revision 2.51  1994/12/29  16:17:05  CACHELIN4000
*Create SetView() out of guts of HandleView()
*
*Revision 2.50  1994/12/23  18:26:39  pfrench
*Disabled un-loading of lightwave, as it can cause crashes
*
*Revision 2.49  1994/12/23  13:37:32  pfrench
*Fixed "continue" bug on save project requester.
*
*Revision 2.48  1994/12/22  23:13:35  pfrench
*Added SwitcherSwitch(TRUE) when going to a slice
*
*Revision 2.47  1994/12/22  23:07:55  CACHELIN4000
*Return early out of QUIT in HandleView()
*
*Revision 2.46  1994/12/22  21:58:26  CACHELIN4000
*Attempt to fix crashy quit, check in so I can updateme
*
*Revision 2.45  1994/12/16  21:01:49  CACHELIN4000
*Add verification requester to HandleView() QUIT option
*
*Revision 2.44  1994/12/07  21:50:37  pfrench
*Reversed left/right of buttons
*
*Revision 2.43  1994/12/07  15:53:20  pfrench
*GrazerRequest code now handles finangling the paths before
*the layout of the interface changes
*
*Revision 2.42  1994/12/05  14:02:43  pfrench
*Added support for moving to project save directory
*
*Revision 2.41  1994/11/09  20:10:35  Kell
*New ErrorMessageBoolRequest function.
*
*Revision 2.40  1994/11/09  14:34:13  Kell
*New ErrorMessageRequest function.
*
*Revision 2.39  1994/11/07  19:47:22  pfrench
*Added loadedslices command before popup
*
*Revision 2.38  1994/11/07  16:42:10  pfrench
*Added getloadedslices
*
*Revision 2.37  1994/11/04  00:17:55  CACHELIN4000
**** empty log message ***
*
*Revision 2.36  94/11/03  23:02:07  CACHELIN4000
*Close windows on QUIT
*
*Revision 2.35  94/10/21  14:54:53  CACHELIN4000
*Add nascent LostCrouton panel code, fix prototypes for PROTO_PASS compile
*
*Revision 2.34  94/10/12  19:44:42  CACHELIN4000
*Remove prototypes
*
*Revision 2.33  94/09/29  15:58:48  CACHELIN4000
**** empty log message ***
*
*Revision 2.32  94/09/27  23:08:05  pfrench
*Whoops, GadgetID mixup
*
*Revision 2.31  1994/09/27  16:27:05  pfrench
*Many changes to rendering/popup code
*
*Revision 2.30  1994/09/23  10:10:34  CACHELIN4000
*change DisplayRunningTime(), add SetRunningTime, global TotalFields
*
*Revision 2.28  94/09/21  21:31:57  pfrench
*Using new FlushWindowPort call
*
*Revision 2.27  1994/09/13  18:37:41  pfrench
*Smarter support for variable-height fittext.
*
*Revision 2.26  1994/09/08  16:18:20  pfrench
*Now redraws window at correct times
*
*Revision 2.25  1994/09/06  22:26:19  CACHELIN4000
*enable ES_QUIT message
*
*Revision 2.24  94/08/30  22:23:19  pfrench
*BeginGrazerRequest clears VALIDFILENAME bit before
*continueing.
*
*Revision 2.23  1994/08/30  15:35:16  CACHELIN4000
*Make displays match artwork (for now)
*
*Revision 2.22  94/08/30  10:38:33  Kell
*Changed SendSwitcherReply calls to work with new ESParams structures.
*
*Revision 2.21  1994/08/29  20:39:59  CACHELIN4000
*DisplayMessage, Time tweaks.
*
*Revision 2.20  94/08/29  18:56:11  pfrench
*borders on filename/time matches artwork (for now)
*
*Revision 2.19  1994/08/27  00:27:53  CACHELIN4000
*Change DisplayRunningTime() to take fields, add DisplayMessage()
*
*Revision 2.18  94/08/26  16:23:32  CACHELIN4000
*duoooh!
*
*Revision 2.17  94/08/26  15:53:51  CACHELIN4000
*Cosmetic help for DisplayCroutonName(), created cousin f'n DisplayRunningTime()
*
*Revision 2.16  94/08/22  13:49:59  pfrench
*Fixed enforcer hit in filename gadget.
*
*Revision 2.15  1994/08/11  16:55:46  pfrench
*Added string gadget in async requester for specifying
*a file name when saving.
*
*Revision 2.14  1994/08/01  16:42:46  pfrench
*Added code that flushes MOUSEMOVES out of the window's
*IDCMP port. As somehow they were sneaking in to the
*eventloop() and causing the editor to crash.
*
*Revision 2.13  1994/07/31  14:42:20  pfrench
*Slightly smarter grazerreq code.
*
*Revision 2.12  1994/07/28  18:19:46  pfrench
*Added filename display in upper corner of screen.
*
*Revision 2.11  1994/07/28  11:36:58  pfrench
*Found correct gadget IDs for async continue/cancel buttons
*
*Revision 2.10  1994/07/27  16:48:30  pfrench
*Added response code to "New Project" button in bottom project.
*
*Revision 2.9  1994/07/21  18:54:37  pfrench
*Yet even more stuff for proj/proj edit.  Filtering of file types.
*
*Revision 2.8  1994/07/21  12:29:30  pfrench
*Added async file requester stuff
*
*Revision 2.7  1994/07/14  12:00:31  pfrench
*Initial code for requesting file types.
*
*Revision 2.6  94/07/08  10:10:05  CACHELIN4000
*replace SendSwitcher() calls with SendSwitcherReply()
*
*Revision 2.5  94/07/07  11:27:04  pfrench
*Added initial support for project/project editing
*
*Revision 2.4  94/06/04  02:25:32  Kell
*Changed order of events when going in/out of switcher mode, to reduce
*annoying interface redraws.
*
*Revision 2.3  94/04/22  14:54:49  CACHELIN4000
**** empty log message ***
*
*Revision 2.2  94/04/22  14:30:46  CACHELIN4000
*Send ES_GUImode messages with HandleView()
*
*Revision 2.1  94/04/20  17:34:04  CACHELIN4000
**** empty log message ***
*
*Revision 2.0  94/02/17  16:24:18  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  15:57:24  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  14:44:37  Kell
*FirstCheckIn
*
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
* 11-4-92	Steve H		Created
* 10-12-93	Steve H		Last Update
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
#include <math.h>
#include <crouton_all.h>
#include <popup.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include <request.h>
#include <gadgets.h>

#include <edit.h>
#include <editwindow.h>
#include <editswit.h>
#include <panel.h>
#include <grazer.h>
#include <filelist.h>
#include <grazerrequest.h>
#include <RawKeyCodes.h>

LONG EndFileRequest( struct GrazerRequest *, LONG);
#ifndef PROTO_PASS
#include <proto.h>
#else
struct Gadget *FindGadget(struct Gadget *G,WORD);
LONG EndLostCroutonRequest( struct GrazerRequest *, LONG);
LONG EndProjProjRequest( struct GrazerRequest *, LONG);
struct EditWindow *AsyncReqCancelHandler(struct EditWindow *,struct IntuiMessage *);
struct EditWindow *AsyncReqContinueHandler(struct EditWindow *,struct IntuiMessage *);
struct EditWindow *AsyncReqBackupHandler(struct EditWindow *Edit,struct IntuiMessage *im );
struct EditWindow *AsyncReqHandlePath(struct EditWindow *,struct IntuiMessage *);
BOOL AsyncReqResize(struct EditWindow *, UWORD );
VOID AsyncReqClose(struct EditWindow *);
VOID AsyncReqFree(struct EditWindow *);
BOOL AsyncReqOpen(struct EditWindow *);
#endif

/*********************************************/
//#define SERDEBUG	1
#include <serialdebug.h>
/*****8***************************************/

#define MAX_FILE 256
#define HELP_LINES 12
#define MAX_WIDTH 640
#define MIN_WIDTH 320

static char *ProjProjReqText[] = {
	"Project-to-Project Editing",
	"Locate the source project below using the file requester.",
	"Select \"OK\" to display its contents.",
	"To edit from project to project, drag croutons to the upper project.",
};
#define PROJ_PROJ_REQTEXT_NUMLINES	4

static char ProjProjReqFileTypes[] = {
	CR_PROJECT,
};
#define PROJ_PROJ_NUM_FILETYPES	1

struct GrazerRequest ProjProjGrazRequest = {

	ProjProjReqText,
	PROJ_PROJ_REQTEXT_NUMLINES,

	ProjProjReqFileTypes,
	PROJ_PROJ_NUM_FILETYPES,

	EW_PROJECT,
	TOP_SMALL,
	EW_PROJECT,

	NULL,

	EndProjProjRequest,
};

static char *LostCroutonReqText[] = {
	"Locate Missing Crouton",
	"Locate the source project below using the file requester.",
	"Select \"OK\" to display its contents.",
	"To edit from project to project, drag croutons to the upper project.",
};
#define LOSTCROUTON_REQTEXT_NUMLINES	4

static char LostCroutonReqFileTypes[] = {0};
#define LOSTCROUTON_NUM_FILETYPES		0
struct GrazerRequest LostCroutonGrazRequest = {
	LostCroutonReqText,
	LOSTCROUTON_REQTEXT_NUMLINES,
	NULL, //LostCroutonReqFileTypes,
	LOSTCROUTON_NUM_FILETYPES,
	0,0,0,
	NULL,
	EndLostCroutonRequest,
};

#define FILE_REQ_TIT_LEN 64
static char FileReqLabel[FILE_REQ_TIT_LEN+1] = "Select A File";
static char *FileReqText[] = { FileReqLabel };
#define FILE_REQTEXT_NUMLINES 1

static char FileReqFileTypes[] = {0};
#define FILE_NUM_FILETYPES		0
int FileReqLen=0;
struct GrazerRequest FileGrazRequest = {

	FileReqText,
	FILE_REQTEXT_NUMLINES,

	NULL, //FileReqFileTypes,
	FILE_NUM_FILETYPES,

	0,
	0,
	0,

	GRAZREQ_ALLOWCREATE|GRAZREQ_RESTOREVIEW,

	EndFileRequest,
};


extern struct SmartString *TopPath,*BottomPath;
extern struct Window *access_win;
extern struct TextFont *EditFont,*DarkFont,*TCFont;
extern struct Gadget Gadget1;
extern struct EditWindow *EditTop,*EditBottom;
extern struct FastGadget **PtrProject,**XtrProject;
extern struct MsgPort *EditPort,*SwitPort;
extern struct AccessWindow *global_aw;

extern struct ESParams1 ESparams1;
extern struct ESParams2 ESparams2;

static struct Window *NoticeWind = NULL,*RetWindow = NULL;
static struct Gadget *NCancel = NULL;
static WORD MaxLen,GlobalSp;

struct GrazerRequest	*global_gr;
struct st_PopupRender PopUp;
struct TextExtent LastExtent;
WORD ViewMode = VIEW_PROJ_SWIT,PrevViewMode=VIEW_PROJ_FILES;
VOID __asm DumpRP(register __a0 struct Layer *);

//*******************************************************************
VOID __asm SafeColorText(
	register __a1 struct RastPort *RP,
	register __a0 STRPTR String,
	register __d0 WORD Length)
{
	WORD Save;

	Save = RP->Mask;
	SafeSetWriteMask(RP,FONT_MASK);
	SetDrMd(RP,JAM2);
	SetAPen(RP,3);
	Text(RP,String,Length);
	SafeSetWriteMask(RP,Save);
}

//*********************************************************************
UWORD __asm SafeFitText(
	register __a1 struct RastPort *RP,
	register __a0 STRPTR String,
	register __d0 WORD Length,
	register __d1 WORD WidthAvail,
	register __d2 BOOL RenderIt)
{
	UWORD Chars;

// if prop font, this was a bug in V37
	if (((struct Library *)GfxBase)->lib_Version < 39) WidthAvail++;
	if (Chars = TextFit(RP,String,Length,&LastExtent,NULL,1,WidthAvail,
		RP->Font->tf_YSize)) {
		if (RenderIt) SafeColorText(RP,String,Chars);
	}
	return(Chars);
}

/****** GraphicHelp/HelpAllocRastPort ***********************************
*
*   NAME
*	HelpAllocRastPort
*
*   SYNOPSIS
*	struct RastPort *HelpAllocRastPort(UWORD Width,UWORD Height,UWORD Depth,
*		ULONG PlaneMemoryType)
*
*   FUNCTION
*	Allocates rastport, bitmap structure and planes
*
*********************************************************************
*/
struct RastPort *HelpAllocRastPort(UWORD Width,UWORD Height,UWORD Depth,
	ULONG PlaneMemoryType)
{
	struct RastPort *RP;

	if (RP = (struct RastPort *)SafeAllocMem(sizeof(struct RastPort),
		MEMF_CLEAR)) {
		InitRastPort(RP);
		if (!(RP->BitMap = HelpAllocBitMap(Width,Height,Depth,PlaneMemoryType))) {
			HelpFreeRastPort(RP);
			RP = NULL;
		}
	}
	return(RP);
}

/****** GraphicHelp/HelpFreeRastPort ************************************
*
*   NAME
*	HelpFreeRastPort
*
*   SYNOPSIS
*	VOID HelpFreeRastPort(struct RastPort *RP)
*
*   FUNCTION
*	Frees rastport, bitmap structure and planes
*
*********************************************************************
*/
VOID HelpFreeRastPort(struct RastPort *RP)
{
	if (RP) {
		if (RP->BitMap) HelpFreeBitMap(RP->BitMap);
		FreeMem(RP,sizeof(struct RastPort));
	}
}

/****** GraphicHelp/HelpAllocBitMap *************************************
*
*   NAME
*	HelpAllocBitMap
*
*   SYNOPSIS
*	struct BitMap *HelpAllocBitMap(UWORD Width,UWORD Height,UWORD Depth,
*		ULONG PlaneMemoryType)
*
*   FUNCTION
*	Allocates bitmap structure and planes
*
*********************************************************************
*/
struct BitMap *HelpAllocBitMap(UWORD Width,UWORD Height,UWORD Depth,
	ULONG PlaneMemoryType)
{
	struct BitMap *BM;

	if (BM = (struct BitMap *)SafeAllocMem(sizeof(struct BitMap),
		MEMF_CLEAR)) {
		BM->BytesPerRow = (Width+7)>>3;
		BM->Rows = Height;
		BM->Depth = Depth;
		if (!HelpAllocBitMapPlanes(BM,PlaneMemoryType)) {
			HelpFreeBitMap(BM);
			BM = NULL;
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
*	VOID HelpFreeBitMap(struct BitMap *BM)
*
*   FUNCTION
*	Frees any planes and the BitMap structure
*
*********************************************************************
*/
VOID HelpFreeBitMap(struct BitMap *BM)
{
	if (BM) {
		HelpFreeBitMapPlanes(BM);
		FreeMem(BM,sizeof(struct BitMap));
	}
}

/****** GraphicHelp/HelpAllocBitMapPlanes *******************************
*
*   NAME
*	HelpAllocBitMapPlanes
*
*   SYNOPSIS
*	BOOL HelpAllocBitMapPlanes(struct BitMap *BitMap,ULONG MemReq)
*
*   FUNCTION
*	Just allocates bit map planes - assumes rest of BitMap
*	struct is correct, Plane array better be cleared!
*
*********************************************************************
*/
BOOL HelpAllocBitMapPlanes(struct BitMap *BitMap,ULONG MemReq)
{
	UWORD a;
	PLANEPTR *Plane;
	ULONG PlaneSize;
	BOOL Success = FALSE;

	if (BitMap && BitMap->Depth && (PlaneSize=BitMap->BytesPerRow*
		BitMap->Rows)) {
		Plane = &BitMap->Planes[0];
		for (a=0; a<BitMap->Depth; a++) {
			if (!(*Plane = SafeAllocMem(PlaneSize,MemReq))) {
				HelpFreeBitMapPlanes(BitMap);
				return(FALSE);
			}
			Plane++;
		}
		Success = TRUE;
	}
	return(Success);
}

/****** GraphicHelp/HelpFreeBitMapPlanes ********************************
*
*   NAME
*	HelpFreeBitMapPlanes
*
*   SYNOPSIS
*	VOID HelpFreeBitMapPlanes(struct BitMap *BitMap)
*
*   FUNCTION
*	Just frees planes
*
*********************************************************************
*/
VOID HelpFreeBitMapPlanes(struct BitMap *BitMap)
{
	UWORD a;
	PLANEPTR *Plane;
	ULONG PlaneSize;

	if (BitMap && BitMap->Depth && (PlaneSize=BitMap->BytesPerRow*
		BitMap->Rows)) {
		Plane = &BitMap->Planes[0];
		for (a=0; a<BitMap->Depth; a++) {
			if (*Plane) {
				FreeMem(*Plane,PlaneSize);
				*Plane = NULL;
			}
			Plane++;
		}
	}
}

//*******************************************************************
//*******************************************************************
VOID __asm DrawBorderBoxRP(
	register __d0 UWORD MinX,
	register __d1 UWORD MinY,
	register __d2 UWORD Width,
	register __d3 UWORD Height,
	register __a0 struct RastPort *RP,
	register __a1 BYTE *Palette,
	register __d4 BOOL BlackBorderFlag);

BYTE Box1[] = { 2,3,1 }, // BOX_STANDARD
	 Box2[] = { 2,4,3,1 }, // BOX_STD_BORDER (requesters,croutons,gadgets)
	 Box3[] = { 1,5,2 }, // BOX_REV (grid border)
	 Box4[] = { 2,4,1,3 }, // BOX_REV_BORDER (string gadgets)
	 Box5[] = { 1,4,2,5 }; // BOX_CP_BORDER (control panels)
BYTE *BoxTypes[] = { Box1,Box2,Box3,Box4,Box5 };
WORD BorderOn[] = { FALSE,TRUE,FALSE,TRUE,TRUE };

static UBYTE Corner[12];
static BOOL CornerSaved = FALSE;
//*******************************************************************
VOID __regargs SaveBorder(
	struct RastPort *RP,
	WORD MinX,
	WORD MinY,
	WORD MaxX,
	WORD MaxY)
{
	UBYTE *A;

	A = Corner;
	*A++ = ReadPixel(RP,MinX,MinY+1); // clockwise order
	*A++ = ReadPixel(RP,MinX,MinY);
	*A++ = ReadPixel(RP,MinX+1,MinY);

	*A++ = ReadPixel(RP,MaxX-1,MinY);
	*A++ = ReadPixel(RP,MaxX,MinY);
	*A++ = ReadPixel(RP,MaxX,MinY+1);

	*A++ = ReadPixel(RP,MaxX,MaxY-1);
	*A++ = ReadPixel(RP,MaxX,MaxY);
	*A++ = ReadPixel(RP,MaxX-1,MaxY);

	*A++ = ReadPixel(RP,MinX+1,MaxY);
	*A++ = ReadPixel(RP,MinX,MaxY);
	*A = ReadPixel(RP,MinX,MaxY-1);
	CornerSaved = TRUE;
}

//*******************************************************************
VOID __regargs NewBorderBox(
	struct RastPort *RP,
	WORD MinX,
	WORD MinY,
	WORD MaxX,
	WORD MaxY,
	WORD Type)
{
	UBYTE *A;

	DrawBorderBoxRP(MinX,MinY,MaxX-MinX+1,MaxY-MinY+1,RP,
		BoxTypes[Type],BorderOn[Type]);
	if (CornerSaved) {
		SetDrMd(RP,JAM2);
		A = Corner;
		SetAPen(RP,*A++);
		WritePixel(RP,MinX,MinY+1); // clockwise order
		SetAPen(RP,*A++);
		WritePixel(RP,MinX,MinY);
		SetAPen(RP,*A++);
		WritePixel(RP,MinX+1,MinY);

		SetAPen(RP,*A++);
		WritePixel(RP,MaxX-1,MinY);
		SetAPen(RP,*A++);
		WritePixel(RP,MaxX,MinY);
		SetAPen(RP,*A++);
		WritePixel(RP,MaxX,MinY+1);

		SetAPen(RP,*A++);
		WritePixel(RP,MaxX,MaxY-1);
		SetAPen(RP,*A++);
		WritePixel(RP,MaxX,MaxY);
		SetAPen(RP,*A++);
		WritePixel(RP,MaxX-1,MaxY);

		SetAPen(RP,*A++);
		WritePixel(RP,MinX+1,MaxY);
		SetAPen(RP,*A++);
		WritePixel(RP,MinX,MaxY);
		SetAPen(RP,*A);
		WritePixel(RP,MinX,MaxY-1);
		CornerSaved = FALSE;
	}
}

//*******************************************************************
#define REQ_MESS_H 26
#define REQ_GADG_H 20

#define TEXT_BASE 9
#define CONT_MINY (10+8+1)
#define LINE_HEIGHT (TEXT_HEIGHT+4)
#define OK_HEIGHT 18
#define MAX_REQ_LINES 14

#define STRING_ID 1002

struct StringExtend StrExt = {
	NULL,
	0,2,
	0,2,
	NULL,
	NULL,
	NULL,
	0,0,0,0
};

char strbuf[MAX_FILE],strubuf[MAX_FILE];
struct StringInfo StrInf = {
	strbuf,strubuf,0,MAX_FILE,0,0,0,0,0,0,&StrExt,0,NULL };

struct Gadget StringGadg = {
	NULL,
	0,0,
	76,TEXT_HEIGHT,
	GFLG_GADGHCOMP,
	GACT_RELVERIFY|GACT_STRINGEXTEND|GACT_STRINGCENTER,
	GTYP_STRGADGET,
	NULL,	/* gadget border or image to be rendered */
	NULL,	/* alternate imagery for selection */
	NULL,	/* first IntuiText structure */
	NULL,	/* gadget mutual-exclude long word */
	&StrInf,
	STRING_ID,
	NULL
};

extern struct TagItem nw_ti[2];
struct ExtNewWindow ReqNW = {
	0,0,	/* window XY origin relative to TopLeft of screen */
	656,400,	/* window width and height */
	1,0,	/* detail and block pens */
	IDCMP_GADGETUP|IDCMP_RAWKEY,	/* IDCMP flags */
	SMART_REFRESH|BORDERLESS|ACTIVATE|RMBTRAP|NOCAREREFRESH|WFLG_NW_EXTENDED,	/* other window flags */
	NULL,	/* first gadget in gadget list */
	NULL,	/* custom CHECKMARK imagery */
	NULL,	/* window title */
	NULL,	/* custom screen pointer */
	NULL,	/* custom bitmap */
	5,5,	/* minimum width and height */
	656,400,	/* maximum width and height */
	CUSTOMSCREEN,	/* destination screen type */
	&nw_ti[0]
};

static struct Screen *Screen;
static WORD MaxLen;
#define SLACK 12
#define MIN_STR 160

//*******************************************************************
BOOL __regargs SimpleRequest(
	struct Window *DestWindow,
	char *Message[],
	UWORD Lines,
	UWORD Flags,
	APTR String)	// ptr to LONG or (char *)
{
	struct Window *Window;
	BOOL Going = TRUE,Result = FALSE;
	struct IntuiMessage *IntuiMsg;
	struct RastPort *RP;
	WORD A,B,C,Sp;
	UWORD Len[MAX_REQ_LINES],BitW[MAX_REQ_LINES],StrWid,ID,StrBitW;
	struct Gadget *OK=NULL,*Cancel=NULL,*First,*Gadget;
	struct Screen *Screen;
	LONG L;

	Screen = DestWindow->WScreen;
	ReqNW.Screen = Screen;

	// find widest lines, make window that wide
	C = MIN_WIDTH;
	for (A = 0; A < Lines; A++) {
// assume our RPort is same
		Len[A] = SafeFitText(DestWindow->RPort,Message[A],
			strlen(Message[A]),MAX_WIDTH-SLACK,FALSE);
		BitW[A] = LastExtent.te_Width;
		if (LastExtent.te_Width > C) C = LastExtent.te_Width;
	}
	ReqNW.Width = C + SLACK;
	if (ReqNW.Width >  MAX_WIDTH)
		ReqNW.Width = MAX_WIDTH;

	if (Lines > 2) Sp = 4;
	else Sp = 20;
	ReqNW.Height = 2+Sp+(Lines * LINE_HEIGHT)+Sp+OK_HEIGHT+4+2;
	if (Flags & (REQ_LONG|REQ_STRING)) {
		ReqNW.Height += TEXT_HEIGHT + 22;
	}
	if (ReqNW.Height > Screen->Height)
		ReqNW.Height = Screen->Height;

	if (Flags & REQ_H_CENTER) {
		ReqNW.TopEdge = (Screen->Height - ReqNW.Height)/2;
	} else {
		ReqNW.TopEdge = 4; // BAR_0_MAXY+3;
	}
	ReqNW.LeftEdge = DestWindow->LeftEdge +
		((DestWindow->Width - ReqNW.Width)>>1);

// (string),(OK/Cancel)|(Continue)
	First = NULL;
	if (Flags & (REQ_LONG|REQ_STRING)) {
		First = &StringGadg;
		StringGadg.TopEdge = 2+Sp+(Lines*LINE_HEIGHT)+Sp;
		StrExt.Font = EditFont;
		strbuf[0] = 0;
		strubuf[0] = 0;
		StrInf.BufferPos = 0;
		StrInf.DispPos = 0;
		StrWid = 6;
		StrBitW = 20*8;
		if (Flags & REQ_LONG) {
			L = *(LONG *)String;
			strbuf[0] = ' ';
			stcl_d(&strbuf[1],L);
		} else {
			if (String) {
				strcpy(strbuf,String);
				StrWid = SafeFitText(DestWindow->RPort,String,strlen(String),
					MAX_WIDTH-SLACK,FALSE);
				StrBitW = LastExtent.te_Width;
				if (StrBitW < 20*8) StrBitW = 20*8;
				if (StrBitW > C) StrBitW = C;
			}
		}
		StringGadg.Width = StrBitW;
		StringGadg.LeftEdge = ((ReqNW.Width - StringGadg.Width)>>1);
	}

	if (Flags & REQ_OK_CANCEL) {
		Gadget = FindGadget(&Gadget1,ID_REQ_CANCEL);
		if (!(Cancel = AllocOneGadget(Gadget))) goto ErrExit;
		Cancel->TopEdge = (ReqNW.Height-Cancel->Height-6);
		Cancel->LeftEdge = (ReqNW.Width-Cancel->Width-6);
		Cancel->NextGadget = NULL;

		Gadget = FindGadget(&Gadget1,ID_REQ_OK);
		if (!(OK = AllocOneGadget(Gadget))) goto ErrExit;
		if (First) First->NextGadget = OK;
		else First = OK;
		OK->NextGadget = Cancel;
		OK->LeftEdge = Cancel->LeftEdge-4-OK->Width;
		OK->TopEdge = Cancel->TopEdge;

	} else if (Flags & REQ_RETURN_OPEN) {
		if (!(Flags & REQ_NO_CANCEL)) {
		Gadget = FindGadget(&Gadget1,ID_REQ_CANCEL);
		if (!(Cancel = AllocOneGadget(Gadget))) goto ErrExit;
		Cancel->TopEdge = (ReqNW.Height-Cancel->Height-6);
		Cancel->LeftEdge = (ReqNW.Width-Cancel->Width-6);
		Cancel->NextGadget = NULL;
		if (First) First->NextGadget = Cancel;
		else First = Cancel;
		}
	} else {
		Gadget = FindGadget(&Gadget1,ID_REQ_CONTINUE);
		if (!(OK = AllocOneGadget(Gadget))) goto ErrExit;
		if (First) First->NextGadget = OK;
		else First = OK;
		OK->LeftEdge = (ReqNW.Width-OK->Width-6);
		OK->TopEdge = (ReqNW.Height-OK->Height-6);
		OK->NextGadget = NULL;

		if (Flags & REQ_CONT_CANCEL) {
			Gadget = FindGadget(&Gadget1,ID_REQ_CANCEL);
			if (!(Cancel = AllocOneGadget(Gadget))) goto ErrExit;
			Cancel->TopEdge = OK->TopEdge;
			Cancel->LeftEdge = (ReqNW.Width-Cancel->Width-6);
			OK->NextGadget = Cancel;
			Cancel->NextGadget = NULL;
			OK->LeftEdge = Cancel->LeftEdge-4-OK->Width;
		}
	}
	ReqNW.FirstGadget = NULL; // mask prob

	SaveBorder(&Screen->RastPort,ReqNW.LeftEdge,ReqNW.TopEdge,
		ReqNW.LeftEdge+ReqNW.Width-1,ReqNW.TopEdge+ReqNW.Height-1);
	if (Window = OpenWindow((struct NewWindow *)&ReqNW)) {
		RP = Window->RPort;
		SetDrMd(RP,JAM2);
		SetFont(RP,EditFont);
		if (First) AddGList(Window,First,0,-1,NULL);
		NewBorderBox(RP,0,0,Window->Width-1,Window->Height-1,BOX_STD_BORDER);

		if (Flags & (REQ_LONG|REQ_STRING))
		NewBorderBox(RP,StringGadg.LeftEdge-4,StringGadg.TopEdge-6,
			StringGadg.LeftEdge+StringGadg.Width+4-1,
			StringGadg.TopEdge+StringGadg.Height+5-1,
			BOX_REV_BORDER);
		if (First) RefreshGList(First,Window,NULL,-1);

	// DumpRP(RP->Layer);

		B = 2+Sp+2+TEXT_BASE;
		for (A = 0; A < Lines; A++) {
			if (Flags & REQ_CENTER)
				Move(RP,(ReqNW.Width - BitW[A])>>1,B);
			else {
				Move(RP,4,B);
			}
			SafeColorText(RP,Message[A],Len[A]);
			B += LINE_HEIGHT;
		}

		if (Flags & (REQ_LONG|REQ_STRING))
			ActivateGadget(&StringGadg,Window,NULL);

		if (Flags & REQ_RETURN_OPEN) {
			NCancel = Cancel;
			RetWindow = Window;
			GlobalSp = Sp;
			return(TRUE);
		}

		goto GetEm;
		while (Going) {
				WaitPort(Window->UserPort);
			GetEm:
			while (IntuiMsg = (struct IntuiMessage *)GetMsg(Window->UserPort)) {
				switch(IntuiMsg->Class) {
				case IDCMP_GADGETUP:
					ID = ((struct Gadget *)IntuiMsg->IAddress)->GadgetID;
					if ((ID == ID_REQ_OK) ||
						(ID == STRING_ID)) Result = TRUE;
					if ((ID == ID_REQ_CONTINUE) && (Flags & REQ_CONT_CANCEL))
						Result = TRUE;
					Going = FALSE;
					break;

				case IDCMP_RAWKEY:
					A = IntuiMsg->Code;
					if ( (A == RAWKEY_PAD_ENTER)
						||(A == RAWKEY_RETURN)
						||(A == RAWKEY_ESC)
						||(A == RAWKEY_HELP))
					{
						if (Flags & REQ_OK_CANCEL)
						{
							if ((A == RAWKEY_RETURN) || (A == RAWKEY_PAD_ENTER))
								Result = TRUE;
						}
						Going = FALSE;
					}
				}
				ReplyMsg((struct Message *)IntuiMsg);
				}
		}
		CloseWindow(Window);
		WaitBlit();
	}

	if (Result) {
		if (Flags & REQ_LONG) {
			if (strbuf[0] == ' ') strbuf[0] = '0';
			stcd_l(strbuf,String);
		} else if (Flags & REQ_STRING)
			strcpy(String,strbuf);
	}
ErrExit:
	if (OK) {
		OK->NextGadget = NULL;
		FreeGadgets(OK);
	}
	if (Cancel) {
		Cancel->NextGadget = NULL;
		FreeGadgets(Cancel);
	}
	return(Result);
}

//*******************************************************************v
void	ErrorMessageRequest(struct Window *DestWindow, char *Text[])
{
	UWORD	lines=0;
	char	**string;	// null terminated table of string pointers

	string = Text;
	while(*string++) lines++;

	SimpleRequest(DestWindow,Text,lines,REQ_H_CENTER,NULL);
}

//*******************************************************************v
// Returns TRUE if OK is clicked, FALSE if Cancel was clicked.
BOOL	ErrorMessageBoolRequest(struct Window *DestWindow, char *Text[])
{
	UWORD	lines=0;
	char	**string;	// null terminated table of string pointers

	string = Text;
	while(*string++) lines++;

	return((BOOL)SimpleRequest(DestWindow,Text,lines,REQ_OK_CANCEL | REQ_H_CENTER,NULL));
}

//*******************************************************************
BOOL __asm ContinueRequest(
	register __a0 struct Window *DestWindow,
	register __a1 char *Message)
{
	char *MPtr[1];

	MPtr[0] = Message;
	return(SimpleRequest(DestWindow,MPtr,1,REQ_CENTER | REQ_H_CENTER,NULL));
}

//*******************************************************************
BOOL __asm BoolRequest(
	register __a0 struct Window *DestWindow,
	register __a1 char *Message)
{
	char *MPtr[1];

	MPtr[0] = Message;
	return(SimpleRequest(DestWindow,MPtr,1,REQ_OK_CANCEL | REQ_CENTER | REQ_H_CENTER,NULL));
}

//*******************************************************************
//*******************************************************************
VOID CloseNoticeWindow(VOID)
{
	if (NoticeWind) {
		CloseWindow(NoticeWind);
		WaitBlit();
		NoticeWind = NULL;
	}
	if (NCancel) {
		NCancel->NextGadget = NULL;
		FreeGadgets(NCancel);
		NCancel = NULL;
	}
}

//*******************************************************************
BOOL CheckNoticeCancel(VOID)
{
	BOOL Cancelled = FALSE;
	struct IntuiMessage *IntuiMsg;
	UWORD ID;
	struct Window *Window = NoticeWind;

	if (Window) {
	while (IntuiMsg = (struct IntuiMessage *)GetMsg(Window->UserPort)) {
		if (IntuiMsg->Class == IDCMP_GADGETUP) {
			ID = ((struct Gadget *)IntuiMsg->IAddress)->GadgetID;
			if (ID == ID_REQ_CANCEL)
				Cancelled = TRUE;
		}
		ReplyMsg((struct Message *)IntuiMsg);
	}
	}
	return(Cancelled);
}

//*******************************************************************
BOOL __regargs UpdateNotice(
	char Message[],
	UWORD LineNumber)
{
	UWORD Len;
	WORD B;
	struct Window *Window = NoticeWind;

	if (Window && Message) {
		B = 2+GlobalSp+2+TEXT_BASE+(LINE_HEIGHT*LineNumber);
		Len = SafeFitText(Window->RPort,Message,strlen(Message),
			Window->Width-SLACK,FALSE);
		SetDrMd(Window->RPort,JAM2);
		SetAPen(Window->RPort,SOLID_PEN);
		RectFill(Window->RPort,3,B-TEXT_BASE,Window->Width-6,B+2);
		Move(Window->RPort,(Window->Width - LastExtent.te_Width)>>1,B);
		SafeColorText(Window->RPort,Message,Len);
	}
	return(TRUE);
}

//*******************************************************************
BOOL __regargs OpenNoticeWindow(
	struct Window *SrcWindow,
	char *Message[],
	UWORD Lines,
	BOOL Option)
{
	UWORD Flags;

	if (Option) Flags = REQ_RETURN_OPEN|REQ_CENTER|REQ_H_CENTER;
	else Flags = REQ_NO_CANCEL|REQ_RETURN_OPEN|REQ_CENTER|REQ_H_CENTER;

	SimpleRequest(SrcWindow,Message,Lines,Flags,NULL);
	if (NoticeWind = RetWindow) return(TRUE);
	return(FALSE);
}

//*******************************************************************
// changes to stuart's code:
//	comment out LockLayer/UnLockLayer
//	change hilite to 2bp
//	cuntsetjmp/cuntlongjmp
//	IntuiText->DrawMode = JAM2
//

#define NUM_VIEW 7

/*** THESE MUST MATCH VIEW_xxx DEFINES IN EDITWINDOW.H!!! ***/
char
		View1[] = "Files/Files",
		View2[] = "Project",
		View3[] = "Project/Files",
		View4[] = "Project/Project",
		View5[] = "Project/Switcher",
		View6[] = "\x81\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x83",
		View7[] = "SHUTDOWN";
char *ViewNames[] = { View1,View2,View3,View4,View5,View6,View7 };

// AAR -- frzl
char *NameFcn(void *frzl, int Entries)
{
	if (Entries < 0) Entries = 0;
	else if (Entries > (NUM_VIEW-1)) Entries = NUM_VIEW-1;
	return(ViewNames[Entries]);
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
	struct Image *Image;
	WORD X;

	NewBorderBox(RP,0,0,Width-1,Height-1,BOX_STD_BORDER);
	Image = FindGadget(&Gadget1,ID_POPUP_UP)->GadgetRender;
	X = (Width-Image->Width)/2;
	if (TopArrow) DrawImage(RP,Image,X,4);
	if (BtmArrow) {
		Image = FindGadget(&Gadget1,ID_POPUP_DOWN)->GadgetRender;
		DrawImage(RP,Image,X,Height - 4 - Image->Height);
	}
}

//*******************************************************************
VOID __regargs AnyPopupText(
	struct Gadget *Gadget,
	char *Text,
	struct Window *Window,
	WORD RightSave)
{
	UWORD A,Len;
	struct RastPort *RP;

	RP = Window->RPort;
	SetDrMd(RP,JAM2);
	// SetFont(RP,EditFont);
	RefreshGList(Gadget,Window,NULL,1);
	Len = SafeFitText(RP,Text,strlen(Text),Gadget->Width-RightSave,FALSE);
	A = Gadget->Width - RightSave - LastExtent.te_Width;
	A = (A >> 1);
	if (RightSave) A += 4;
	Move(RP,Gadget->LeftEdge+A,Gadget->TopEdge+13);
	SafeColorText(RP,Text,strlen(Text));
}

//*******************************************************************
static void DrawPopupUnselected( struct Gadget *gad, STRPTR txt, struct RastPort *rp );
VOID RedrawPopupText(struct EditWindow *Edit)
{
	struct Gadget *Gadget;

	if (Gadget = FindGadget(Edit->Gadgets,ID_POPUP_PROGRAMS))
	{
		// AnyPopupText(Gadget,"Programs",Edit->Window,20);
		DrawPopupUnselected(Gadget,"Programs", Edit->Window->RPort );
	}

	if (Gadget = FindGadget(Edit->Gadgets,ID_POPUP_VIEWS))
	{
		// AnyPopupText(Gadget,"Views",Edit->Window,20);
		DrawPopupUnselected(Gadget,"Views", Edit->Window->RPort );
	}

	if (Gadget = FindGadget(Edit->Gadgets,ID_POPUP_TOOLS))
	{
		// AnyPopupText(Gadget,"Tools",Edit->Window,20);
		DrawPopupUnselected(Gadget,"Tools", Edit->Window->RPort );
	}
}

static void DrawPopupUnselected( struct Gadget *gad, STRPTR txt, struct RastPort *rp )
{
	WORD					 A,Len;
	struct Image		*Image;

	NewBorderBox(rp,	gad->LeftEdge,gad->TopEdge,
							gad->LeftEdge + gad->Width,
							gad->TopEdge + gad->Height,
							BOX_STD_BORDER);

	Len = SafeFitText(rp,txt,strlen(txt),gad->Width-20,FALSE);
	A = (gad->Width - 20) - LastExtent.te_Width;	/* how much space left? */
	A = (A >> 1) + 4;
	Move(rp, gad->LeftEdge + A, gad->TopEdge + rp->TxBaseline + 5 );
	SafeColorText(rp,txt,Len);

	Image = FindGadget(&Gadget1,ID_POPUP_UP)->GadgetRender;
	A = gad->LeftEdge + gad->Width - (Image->Width + 4);
	DrawImage(rp,Image,A,gad->TopEdge + (gad->Height >> 1) - Image->Height );
	Image = FindGadget(&Gadget1,ID_POPUP_DOWN)->GadgetRender;
	DrawImage(rp,Image,A,gad->TopEdge + (gad->Height >> 1) + 2 );
}

/****** GraphicHelp/HandleView ************************************
*
*   NAME
*	HandleView
*
*   SYNOPSIS
*	struct EditWindow *HandleView(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
struct EditWindow *HandleView(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	PopUpID ID;
	struct Gadget *Gadget;
	WORD A,X,Y,OldMode=ViewMode;

	PUCDefaultRender(&PopUp);
	PopUp.textPosition = 0;		// Left-justify
	PopUp.drawBG = (DrawBGFunc *)DrawBG;
	Gadget = FindGadget(Edit->Gadgets,ID_POPUP_VIEWS);
	X = Gadget->LeftEdge /* + (Gadget->Width >> 1) */;
	Y = Gadget->TopEdge + (Gadget->Height >> 1);
	ID = PUCCreate((NameFunc *)NameFcn,NULL,&PopUp);
	PUCSetNumItems(ID,NUM_VIEW);
	PUCSetCurItem(ID,ViewMode);

	Edit->Window->Flags |= WFLG_REPORTMOUSE;
	A = PUCActivate(ID,Edit->Window,X,Y,IntuiMsg->MouseX,IntuiMsg->MouseY);
	Edit->Window->Flags &= ~WFLG_REPORTMOUSE;

	// Remove all MouseMoves as they were causing the editor to crash
	FlushWindowPort(Edit->Window,IDCMP_MOUSEMOVE);

	PUCDestroy(ID);

	if (A >= 0)
	{
		if (A != ViewMode)
		{
			ViewMode = A;
			RedrawPopupText(Edit);
			switch(A)
			{
			case VIEW_PROJ_FILES:
			case VIEW_FILES_FILES:
			case VIEW_PROJ_SWIT:
			case VIEW_PROJ:
			case VIEW_PROJ_PROJ:
				SetView(A);
				break;

			case 5:
				// Do nada for the '----' bar
				break;
			case 6:	 // QUIT
				if(EditTop && BoolRequest(EditTop->Window,"Are you really sure you want to quit?"))
				{
					MakeLayout(EW_EMPTY,TOP_SMALL,EW_EMPTY);
					ESparams1.Data1=NULL;
					SendSwitcherReply(ES_QUIT,&ESparams1);
					return(NULL);
				}
				else ViewMode=OldMode;
				RedrawPopupText(Edit);
				break;
			}
			Edit = EditTop; // old one gone
		} else RedrawPopupText(Edit);
	}
	if(OldMode!=ViewMode) PrevViewMode=OldMode;
	return(Edit);
}


/****** GraphicHelp/SetView ************************************
*
*   NAME
*	SetView
*
*   SYNOPSIS
*	void SetView(UWORD View)
*
*   FUNCTION
*	Set editor display mode, valid value 0-4
*
*********************************************************************
*/
void SetView(UWORD View)
{
	DUMPHEXIW(" SetView( ",View,") ");
	switch(View)
	{
		case VIEW_PROJ_FILES:
			ESparams1.Data1=GUI_T_PROJ|GUI_B_GRAZ;
			SendSwitcherReply(ES_GUImode,&ESparams1);
			SwitcherSwitch(FALSE);
			MakeLayout(EW_PROJECT,TOP_SMALL,EW_GRAZER);
			break;
		case VIEW_FILES_FILES:
			ESparams1.Data1=GUI_T_GRAZ|GUI_B_GRAZ;
			SendSwitcherReply(ES_GUImode,&ESparams1);
			SwitcherSwitch(FALSE);
			MakeLayout(EW_GRAZER,TOP_SMALL,EW_GRAZER);
			break;
		case VIEW_PROJ_SWIT:
			MakeLayout(EW_PROJECT,TOP_SMALL,EW_EMPTY);
			ESparams1.Data1=GUI_T_PROJ|GUI_B_SWIT;
			SendSwitcherReply(ES_GUImode,&ESparams1);
			SwitcherSwitch(TRUE);
			aw_Redraw(global_aw);
			break;
		case VIEW_PROJ:
			ESparams1.Data1=GUI_T_NONE|GUI_B_PROJ;
			SendSwitcherReply(ES_GUImode,&ESparams1);
			SwitcherSwitch(FALSE);
			MakeLayout(EW_PROJECT,TOP_LARGE,EW_EMPTY);
			break;
		case VIEW_PROJ_PROJ:
			if ( XtrProject )
			{
				ESparams1.Data1=GUI_T_PROJ|GUI_B_PROJ;
				SendSwitcherReply(ES_GUImode,&ESparams1);
				SwitcherSwitch(FALSE);
				MakeLayout(EW_PROJECT,TOP_SMALL,EW_PROJECT);
			}
			else
			{
				BeginGrazerRequest( &ProjProjGrazRequest );
			}
			break;
		default:
			break;
	}
	DUMPMSG("	...Exited ");
}


/****** GraphicHelp/HandlePrograms **********************************
*
*   NAME
*	HandlePrograms
*
*   SYNOPSIS
*	struct EditWindow *HandleView(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
LONG global_LoadSliceCommand = 0;

#define NUM_APPNAMES 6

/*
char *AppNames[] =
{
	" ",
	"  LightWave  ",
	"  ToasterPaint  ",
	"  ToasterCG  ",
	"  ChromaFX  ",
};
*/

far char	AppNames[MAX_APPNAMES][MAX_APPNAME_LEN+1] =
{
	" ",
	"  LightWave  ",
	"  ToasterPaint  ",
	"  ToasterCG  ",
	"  ChromaFX  ",
	"\x81\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x83",
};

ULONG NumSysApps = NUM_APPNAMES;			// This one never changes
ULONG TotalAppNum	= NUM_APPNAMES;		// This one is the current total for the popup
UBYTE	AppFlags[MAX_APPNAMES] = "";
far char	AppCommand[MAX_APPNAMES+1][MAX_APPCMD_LEN+1] = {
	"", // First 6 are internal apps
	"",
	"",
	"",
	"",
	"",
} ;



#define SLICE_LIGHTWAVE	1
#define SLICE_PAINT		2
#define SLICE_CG			3
#define SLICE_CHROMAFX	4

static struct st_PopupRender	 AppPopUp;

static char *AppNameFcn( void *huh, int Entries );

static char *AppNameFcn( void *huh, int Entries )
{
	if (Entries < 0) Entries = 0;
	else if (Entries >= TotalAppNum) Entries = (TotalAppNum - 1);
	return(AppNames[Entries]);
}

struct EditWindow *HandlePrograms(struct EditWindow *Edit,struct IntuiMessage *im )
{
	PopUpID			 ID;
	WORD				 AppNum,X,Y;
	ULONG				 es_command = 0;
	ULONG				 last_qual;
	struct Gadget	*gad = im->IAddress;
	struct Window	*win = Edit->Window;
	ULONG	numitems;

	GetLoadedSlices();

	PUCDefaultRender(&AppPopUp);
	AppPopUp.textPosition = 0;		// Left-justify
	AppPopUp.drawBG = (DrawBGFunc *)DrawBG;
	X = gad->LeftEdge + (gad->Width >> 1);
	Y = gad->TopEdge + (gad->Height >> 1);
	ID = PUCCreate((NameFunc *)AppNameFcn,NULL,&AppPopUp);

	numitems = TotalAppNum;
	if (numitems == NUM_APPNAMES)		// Trim off bottom divider line if no custom progs
		numitems--;
	PUCSetNumItems(ID,numitems);

	PUCSetCurItem(ID,0);

	win->Flags |= WFLG_REPORTMOUSE;
	AppNum = PUCActivate(ID,win,X,Y,im->MouseX,im->MouseY);
	win->Flags &= ~WFLG_REPORTMOUSE;

	// Remove all remaining MouseMoves as they
	// were causing the editor to crash
	FlushWindowPort(win,IDCMP_MOUSEMOVE);

	last_qual = PUCDestroy(ID);

	if(AppNum<NUM_APPNAMES)
	{
		switch ( AppNum )
		{
			case SLICE_LIGHTWAVE:
				es_command = ES_LightWave;
			break;
			case SLICE_PAINT:
				es_command = ES_ToasterPaint;
			break;
			case SLICE_CG:
				es_command = ES_ToasterCG;
			break;
			case SLICE_CHROMAFX:
				es_command = ES_ChromaFX;
			break;
		}

		// A program was chosen, so there
		if ( es_command )
		{
			if ( last_qual & (IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT) )
			{
				// Unload the application
				ESparams1.Data1=FGC_UNLOAD;

				if(!SendSwitcherReply(es_command,&ESparams1))
				{
					// Success
					AppNames[AppNum][0] = ' ';
				}
			}
			else
			{
				// Tell eventloop to load and run a slice
				global_LoadSliceCommand = es_command;
				AppNames[AppNum][0] = '*';
			}
		}
	}
	else // User added app
	{
#ifdef SERDEBUG
		DUMPUDECL(" User App #name ",(LONG)AppNum,AppNames[AppNum]);
		if(AppFlags[AppNum]&APPF_AREXX)
			DUMPMSG("  is an Arexx Macro");
		else
			DUMPMSG("  is a DOS Call");
#endif
		if(AppFlags[AppNum]&APPF_AREXX)
			ARexxMacro(AppCommand[AppNum]);
		else
			Execute(AppCommand[AppNum],NULL,NULL);
	}

	return(Edit);
}

/*	COPIED FROM SWITCHER/INC/TAGS.I
* LoadedSlices Bits
SLICE_SETUP			EQU	0	;=Switcher Prefs, ignored because its always loaded
SLICE_CHROMAFX		EQU	1
SLICE_PAINT			EQU	2
SLICE_CG				EQU	3
SLICE_LIGHTWAVE	EQU	4
SLICE_HARDWARE		EQU	5	;ignored because its always loaded
*/

ULONG GetLoadedSlices()
{
	ULONG			retval;

	retval = SendSwitcherReply(ES_LoadedSlices,&ESparams1);

	if ( retval & (1 << 1) )	/* ChromaFX */
		AppNames[SLICE_CHROMAFX][0] = '*';
	else
		AppNames[SLICE_CHROMAFX][0] = ' ';

	if ( retval & (1 << 2) )	/* Paint */
		AppNames[SLICE_PAINT][0] = '*';
	else
		AppNames[SLICE_PAINT][0] = ' ';

	if ( retval & (1 << 3) )	/* CG */
		AppNames[SLICE_CG][0] = '*';
	else
		AppNames[SLICE_CG][0] = ' ';

	if ( retval & (1 << 4) )	/* Lightwave */
		AppNames[SLICE_LIGHTWAVE][0] = '*';
	else
		AppNames[SLICE_LIGHTWAVE][0] = ' ';

	return(retval);
}

LONG LoadSlice( LONG slicecommand )
{
	LONG			retval;

	// Load the application
	ESparams1.Data1=FGC_LOAD;

	if(!(retval = SendSwitcherReply(slicecommand,&ESparams1)) )
	{
		MakeLayout(EW_EMPTY,TOP_SMALL,EW_EMPTY);
		SwitcherSwitch(TRUE);
		CloseAccessWindow();
		access_win = NULL;

		ESparams1.Data1=FGC_SELECT;
		retval = (LONG) PutSwitcher(slicecommand,(LONG *)&ESparams1);
	}

	return(retval);
}


/****** GraphicHelp/HandleTools ************************************
*
*   NAME
*	HandleTools
*
*   SYNOPSIS
*	struct EditWindow *HandleTools(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/

#define NUM_TOOLS		12

static struct st_PopupRender	 ToolPopUp;

ULONG NumSysTools = NUM_TOOLS;				// This one never changes
ULONG TotalToolsNum	= NUM_TOOLS;
UBYTE	ToolFlags[MAX_TOOLNAMES];
far char	ToolNames[MAX_TOOLNAMES][MAX_TOOLNAME_LEN+1] =
{
	"Audio on/off (Alt A)",
	"Auto insert  (Alt I)",
	"Cut clip (Alt C)",
	"Edit to all audio",
	"Edit to crouton",
	"Lock/Unlock (Alt L)",
	"Process clip (Alt P)",
	"Quick Adjust (Ctrl)",
	"\x81\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x83",
	"Hardware setup",
	"Options",
	"\x81\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x82\x83",
};
far char	ToolCommand[MAX_TOOLNAMES+1][MAX_TOOLCMD_LEN+1] =
{
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
};

char *ToolsNameFcn(void *foo, int Entries)
{
	if (Entries < 0)
		Entries = 0;
	else if (Entries >= TotalToolsNum)
		Entries = TotalToolsNum-1;
	return(ToolNames[Entries]);
}

struct EditWindow *HandleTools(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	static WORD	LastTool=7;		// First default is "quick adjust"
	PopUpID ID;
	struct Gadget *gad;
	WORD tool,X,Y;
	struct IntuiMessage	fakemsg;
	struct Window	*win = Edit->Window;
	ULONG	numitems;

	PUCDefaultRender(&ToolPopUp);
	ToolPopUp.textPosition = 0;		// Left-justify
	ToolPopUp.drawBG = (DrawBGFunc *)DrawBG;
//	gad = FindGadget(Edit->Gadgets,ID_POPUP_TOOLS);
	gad = IntuiMsg->IAddress;
	X = gad->LeftEdge + (gad->Width >> 1);
	Y = gad->TopEdge + (gad->Height >> 1);
	ID = PUCCreate((NameFunc *)ToolsNameFcn,NULL,&ToolPopUp);

	numitems = TotalToolsNum;
	if (numitems == NUM_TOOLS)				// Trim off bottom divider line if no custom tools
		numitems--;
	PUCSetNumItems(ID,numitems);

	if (LastTool>=TotalToolsNum)			// Don't try to come up on a removed tool
		LastTool = 0;
	PUCSetCurItem(ID,LastTool);

	win->Flags |= WFLG_REPORTMOUSE;
	tool = PUCActivate(ID,win,X,Y,IntuiMsg->MouseX,IntuiMsg->MouseY);
	win->Flags &= ~WFLG_REPORTMOUSE;

	// Remove all MouseMoves as they were causing the editor to crash
	FlushWindowPort(win,IDCMP_MOUSEMOVE);

	PUCDestroy(ID);

	if (tool >= 0)
	{
		LastTool = tool;

//		RedrawPopupText(Edit);

		switch(tool)
		{
			case 0:
				HandleAudioOnOff(EditTop);
				break;
			case 1:
				HandleAudioUnder(EditTop);
				break;
			case 2:
				ProcessCrouton(Edit,TRUE);			// Destructively cut clip
				break;
			case 3:
				// Fake Play handler into thinking it was invoked as ALT play
				fakemsg.Qualifier = IEQUALIFIER_LALT;
				fakemsg.Class = IDCMP_RAWKEY;
				fakemsg.Code = 0;		//(dont care) RAWKEY_TAB;
				HandlePlay(EditTop,&fakemsg);
				break;
			case 4:
				// Fake Play handler into thinking it was invoked as ALT play-from
				fakemsg.Qualifier = IEQUALIFIER_LSHIFT | IEQUALIFIER_LALT;
				fakemsg.Class = IDCMP_RAWKEY;
				fakemsg.Code = 0;		//(dont care) RAWKEY_TAB;
				HandlePlay(EditTop,&fakemsg);
				break;
			case 5:
				HandleLockDown(EditTop);
				break;
			case 6:
				ProcessCrouton(Edit,FALSE);		// Process clip
				break;
			case 7:
				QuickVIDEOPanel(EditTop,NULL);
				break;
			case 8:		// Divider line
				break;
			case 9:
				DoSetupPanel(Edit,NULL);
				break;
			case 10:
				DoOptionsPanel(Edit,NULL);
				break;
			case 11:		// Divider line
				break;
			default:		// Must be a user tool
				if(ToolFlags[tool]&APPF_AREXX)
				{
					DUMPMSG("Arexx");
					ARexxMacro(ToolCommand[tool]);
				}
				else
				{
					DUMPMSG("DOS");
					Execute(ToolCommand[tool],NULL,NULL);
				}
				break;
		}
	}

	return(Edit);
}

// end of graphichelp.c
//*******************************************************************
//*******************************************************************
//*******************************************************************

LONG BeginGrazerRequest( struct GrazerRequest *gr )
{
	LONG		result = TRUE;

	gr->gr_Flags &= ~(GRAZREQ_VALIDFILENAME);

	if ( EditTop )
	{
		gr->gr_CancelTopType = EditTop->Node.Type;
		gr->gr_CancelTopHeight = EditTop->Height;
	}
	else
	{
		gr->gr_CancelTopType = EW_EMPTY;
		gr->gr_CancelTopHeight = 0;
	}

		/* Swap the paths so the grazer comes up in the inital directory */
	if ( gr->gr_InitialPath )
	{
		if ( EditBottom && EditBottom->Node.Type == EW_GRAZER )
		{
			/* This window is going to remain open, so modify the path */
			struct SmartString	*s;

			s = ((struct Grazer *)EditBottom->Special)->Path;
			((struct Grazer *)EditBottom->Special)->Path = gr->gr_InitialPath;
			gr->gr_InitialPath = s;
		}
		else
		{
			struct SmartString	*s;

			/* The grazer window will open with this path */
			s = BottomPath;
			BottomPath = gr->gr_InitialPath;
			gr->gr_InitialPath = s;
		}
	}

	if (EditBottom)
	{
		if ( EditBottom->Node.Type == EW_GRAZER )
		{
			DoAllNewDir(EditBottom);
		}
		gr->gr_CancelBottomType = EditBottom->Node.Type;
	}
	else
	{
		gr->gr_CancelBottomType = EW_EMPTY;
	}

	global_gr = gr;

	/* SendSwitcherReply(ES_GUImode,GUI_T_PROJ|GUI_B_GRAZ,0,0); */
	SwitcherSwitch(FALSE);
	MakeLayout(EW_ASYNCREQ,TOP_SMALL,EW_GRAZER);

	return(result);
}

LONG EndGrazerRequest( LONG mode )
{
	struct GrazerRequest	*gr = global_gr;
	LONG						 retval = 0;

	global_gr = NULL;

	if ( gr->gr_InitialPath )
	{
		struct SmartString	*s;

		/* Swap path of grazer back to where we were before (potentially) closing */
		s = ((struct Grazer *)EditBottom->Special)->Path;
		((struct Grazer *)EditBottom->Special)->Path = gr->gr_InitialPath;
		gr->gr_InitialPath = s;

		/* Just free it */
		FreeSmartString(s);
		gr->gr_InitialPath = NULL;

		DoAllNewDir(EditBottom);
	}

	if ( gr->gr_EndRequest )
	{
		// The user may free the GrazerRequest structure
		// during this call, so "gr" should be considered
		// invalid after this call.
		retval = gr->gr_EndRequest(gr,mode);
	}

	return(retval);
}

LONG req_DoLayout( WORD TopType, WORD TopHeight, WORD BottomType )
{
	LONG		 retval = 0;
	ULONG		 guimode = 0;

	switch (TopType)
	{
		case EW_PROJECT:
		guimode |= GUI_T_PROJ;
		break;

		case EW_GRAZER:
		guimode |= GUI_T_GRAZ;
		break;
	}

	switch (BottomType)
	{
		case EW_PROJECT:
		guimode |= GUI_B_PROJ;
		break;

		case EW_GRAZER:
		guimode |= GUI_B_GRAZ;
		break;

		case EW_EMPTY:
		if (TopHeight != TOP_LARGE)
		{
			guimode |= GUI_B_SWIT;
		}
		break;
	}

	ESparams1.Data1=guimode;

	if ( (BottomType == EW_EMPTY) && (TopHeight != TOP_LARGE) )
	{
		MakeLayout(	TopType, TopHeight, BottomType);
		SendSwitcherReply(ES_GUImode,&ESparams1);
		SwitcherSwitch(TRUE);
		aw_Redraw(global_aw);
	}
	else
	{
		SendSwitcherReply(ES_GUImode,&ESparams1);
		SwitcherSwitch(FALSE);
		MakeLayout(	TopType, TopHeight, BottomType);
	}

	return(retval);
}

LONG EndProjProjRequest( struct GrazerRequest *gr, LONG mode )
{
	LONG						 retval = 0;

	/*	Success can be determined by either double-clicking on a
		file of the correct type or by selecting the file and
		hitting "continue" in the async requester, or by typing
		in a file name in the grazer string and hitting return.
	 */

	// For now, mode will be NULL if the request failed, in which
	// case, we want to restore the screen to the mode it was in
	// before the requesters came up.
	if ( mode && (gr->gr_Flags & GRAZREQ_VALIDFILENAME) )
	{
		ESparams2.Data1=1;
		ESparams2.Data2=(LONG)GetCString(gr->gr_FilePath);
		if ( !SendSwitcherReply(ES_LoadProject,&ESparams2) )
		{
			XtrProject = &PtrProject[1];

			req_DoLayout(	gr->gr_ContinueTopType,
								gr->gr_ContinueTopHeight,
								gr->gr_ContinueBottomType);
		}
	}
	else
	{
		req_DoLayout(	gr->gr_CancelTopType,
							gr->gr_CancelTopHeight,
							gr->gr_CancelBottomType);

	}

	if (gr->gr_FilePath)
	{
		FreeSmartString(gr->gr_FilePath);
		gr->gr_FilePath = NULL;
	}

	return(retval);
}

// ----------------------------------------------------------
// ----------------------------------------------------------

LONG EndLostCroutonRequest( struct GrazerRequest *gr, LONG mode )
{
	LONG						 retval = 0;

	if ( mode && (gr->gr_Flags & GRAZREQ_VALIDFILENAME) )
	{
		struct FastGadget		*fg;

		/* Ask the switcher to load the data */
		if ( fg = AllocProj(GetCString(gr->gr_FilePath)) )
		{
			// struct FastGadget		*old_fg = (struct FastGadget *)gr->gr_UserData;

			/* Replace old Crouton with new one just loaded */

			// RemoveProjNode(Edit,old_fg);

			// SomehowCopyTaglists(old_fg,fg);

			// FreeProjectNode(old_fg);

			FreeProjectNode(fg);
		}
	}

	if ( gr->gr_FilePath )
	{
		FreeSmartString(gr->gr_FilePath);
		gr->gr_FilePath = NULL;
	}

	req_DoLayout(	gr->gr_CancelTopType,
						gr->gr_CancelTopHeight,
						gr->gr_CancelBottomType);

	return(retval);
}


LONG EndFileRequest( struct GrazerRequest *gr, LONG mode )
{
	LONG						 retval = 0;

	if ( mode && (gr->gr_Flags & GRAZREQ_VALIDFILENAME) )
	{
		strncpy((char *)gr->gr_UserData,GetCString(gr->gr_FilePath),FileReqLen);
	}
	else *((char *)gr->gr_UserData)=1;
	if ( gr->gr_FilePath )
	{
		FreeSmartString(gr->gr_FilePath);
		gr->gr_FilePath = NULL;
	}

	req_DoLayout(	gr->gr_CancelTopType,
						gr->gr_CancelTopHeight,
						gr->gr_CancelBottomType);

	return(retval);
}



BOOL GrazerGetFile(char *Tit, char *Path, char *File, char *buf, int buflen)
{
	FileGrazRequest.gr_UserData = (LONG)buf;
	FileReqLen=buflen;
	if(*Path) FileGrazRequest.gr_InitialPath = AllocSmartString(Path,NULL);
	if(*File) strncpy(FileGrazRequest.gr_InitialFileName,File,39);
	if(*Tit) strncpy(FileGrazRequest.gr_reqtext[0],Tit,FILE_REQ_TIT_LEN);
	else strcpy(FileGrazRequest.gr_reqtext[0],"Select A File");
	BeginGrazerRequest(&FileGrazRequest);

	if ( EditBottom && (EditBottom->Node.Type == EW_GRAZER) )
	{
		EditBottom->RedrawSelect = TRUE;
		EditBottom->DisplayGrid = TRUE;
		EditBottom->ew_OptRender = FALSE;
		UpdateDisplay(EditBottom);
	}

	return(TRUE);
}

// ----------------------------------------------------------
// ----------------------------------------------------------

struct EditWindow *AllocInitAsyncReq(struct NewEditWindow *NewEdit )
{
	struct EditWindow *Edit;
	BOOL Success = FALSE;

	if (	(Edit = (struct EditWindow *)AllocSmartNode(NULL,sizeof(struct EditWindow),MEMF_CLEAR)) &&
			(Edit->Special = (struct EditSpecial *)AllocSmartNode(NULL,sizeof(struct EditSpecial),MEMF_CLEAR)) )
	{
		Edit->Node.Type = EW_ASYNCREQ;

		Edit->Resize = AsyncReqResize;
		Edit->Open = AsyncReqOpen;
		Edit->Close = AsyncReqClose;
		Edit->Free = AsyncReqFree;

		if ( InitEditWindow(Edit,NewEdit) )
		{
			Edit->DisplayGrid = FALSE;
			Edit->AllowDrag = FALSE;
			Success = TRUE;
		}

		if (!Success && Edit )
		{
			(*Edit->Free)(Edit);
			Edit = NULL;
		}
	} // if AllocMem() EditWindow & Grazer
	return(Edit);
}

BOOL AsyncReqOpen(struct EditWindow *Edit )
{
	struct GrazerRequest	*gr = global_gr;
	struct NewWindow		*NW;
	struct Gadget			*Gadget,*OK,*Cancel,*FileName,*Backup;
	BOOL						 Success = FALSE;
	WORD						 i,max_txt_width;
	UWORD						 Len[MAX_REQ_LINES],
								 BitW[MAX_REQ_LINES];
	struct RastPort		 srp;

	NW = (struct NewWindow *)&ReqNW;	// uses NewWindow from powerwindows output
	NW->FirstGadget = NULL; 			// don't add until after open
	NW->DetailPen = SCREEN_PEN;
	NW->Screen = Edit->Screen;
	NW->LeftEdge = Edit->LeftEdge;
	NW->TopEdge = Edit->TopEdge;

#ifndef SWIT_ONLY
	if (SwitPort) {
#endif
	NW->LeftEdge += 32;
	NW->TopEdge += 44;
#ifndef SWIT_ONLY
	}
#endif

	NW->Width = Edit->Width;
	/* NW->Height = Edit->Height - SLACK; */
	NW->Height = ((gr->gr_num_reqlines+1) * LINE_HEIGHT)
						+ SLACK + ((8 + PNL_DIV) << 1);

	InitRastPort(&srp);
	SetFont(&srp,DarkFont);

	max_txt_width = MIN_WIDTH;

	for ( i = 0; i < gr->gr_num_reqlines; i++ )
	{
		Len[i] = SafeFitText(&srp,gr->gr_reqtext[i],
			strlen(gr->gr_reqtext[i]),MAX_WIDTH-SLACK,FALSE);

		BitW[i] = LastExtent.te_Width;
		if (LastExtent.te_Width > max_txt_width)
			max_txt_width = LastExtent.te_Width;
	}
	NW->Width = max_txt_width + (SLACK << 1);
	if (NW->Width >  MAX_WIDTH)
		NW->Width = MAX_WIDTH;

	NW->LeftEdge += (MAX_WIDTH - NW->Width) >> 1;
	if ( gr->gr_Flags & GRAZREQ_ALLOWCREATE )
	{
		NW->Height += LINE_HEIGHT + (LINE_HEIGHT >> 1);
	}

	Gadget = FindGadget(&Gadget1,ID_REQ_DARK_CANCEL);
	if (!(Cancel = AllocOneGadget(Gadget))) goto ErrExit;
	NW->Height += Cancel->Height;
	Cancel->UserData = (APTR) AsyncReqCancelHandler;
	Cancel->TopEdge = (NW->Height - Cancel->Height - 6);
	Cancel->LeftEdge = NW->Width - Cancel->Width - 6;
	Cancel->NextGadget = NULL;

	Gadget = FindGadget(&Gadget1,ID_DARK_CONTINUE);
	if (!(OK = AllocOneGadget(Gadget))) goto ErrExit;
	OK->UserData = (APTR) AsyncReqContinueHandler;
	OK->TopEdge = NW->Height - OK->Height - 6;
	OK->LeftEdge = 6;

	Edit->Gadgets = Cancel;
	Cancel->NextGadget = OK;

	if ( gr->gr_Flags & GRAZREQ_ALLOWCREATE )
	{
		Gadget = FindGadget(&Gadget1,ID_PATH);
		if (!(FileName = AllocOneGadget(Gadget))) goto ErrExit;
		FileName->UserData = (APTR) AsyncReqHandlePath;
		OK->NextGadget = FileName;
		FileName->Width = NW->Width-32;
		FileName->TopEdge = OK->TopEdge - (FileName->Height + 18);
		FileName->LeftEdge = (NW->Width - FileName->Width)>> 1;
		FileName->Height = TEXT_HEIGHT;
	}
	else FileName = NULL;

	if ( gr->gr_Flags & GRAZREQ_BACKUP )
	{
		Gadget = FindGadget(&Gadget1,ID_BU_BACKUP);
		if (!(Backup = AllocOneGadget(Gadget))) goto ErrExit;
		Backup->UserData = (APTR) AsyncReqBackupHandler;
		Backup->TopEdge = NW->Height - Backup->Height - 6;
		Backup->LeftEdge = (NW->Width - Backup->Width) >> 1;

		if ( FileName )
			FileName->NextGadget = Backup;
		else
			OK->NextGadget = Backup;
	}

	NW->Flags |= WFLG_SIMPLE_REFRESH;

// then make SMART_REFRESH (to get around clear to color 0 problem)
	if ( Edit->Window = OpenWindow(NW) )
	{
		struct RastPort	*rp = Edit->Window->RPort;
		WORD						 y_offset;

		MakeSimpleSmart(Edit->Window);
		SetDrMd(rp,JAM2);
		SetFont(rp,DarkFont);
		NewBorderBox(rp,0,0,Edit->Window->Width-1,Edit->Window->Height-1,BOX_CP_BORDER);

		if ( FileName )
		{
			NewBorderBox(rp,FileName->LeftEdge-4,FileName->TopEdge-2-3,
				FileName->LeftEdge+FileName->Width+3,
				FileName->TopEdge+FileName->Height+4-1,BOX_REV_BORDER);

			if ( gr->gr_InitialPath )
			{
				UpdateStringGadgetText(Edit->Window,FileName,gr->gr_InitialFileName);
			}
		}

		y_offset = 8+TEXT_BASE;
		for ( i = 0; i < gr->gr_num_reqlines; i++ )
		{
			Move(rp,(Edit->Window->Width - BitW[i])>>1, y_offset );
			SafeColorText(rp,gr->gr_reqtext[i],Len[i]);
			y_offset += LINE_HEIGHT;

			if ( i==0 )
			{
				NewBorderBox(rp,PNL_X1,y_offset-8,Edit->Window->Width-PNL_X1,y_offset-8+PNL_DIV,BOX_REV);
				y_offset += 8 + PNL_DIV;
			}
		}

		NewBorderBox(rp,PNL_X1,OK->TopEdge-12,Edit->Window->Width-PNL_X1,OK->TopEdge-12+PNL_DIV,BOX_REV);
		AddGList(Edit->Window,Edit->Gadgets,0,-1,NULL);
		RefreshGList(Edit->Gadgets,Edit->Window,NULL,-1);

		BuildWaitMask();
		Success = TRUE;
	}

	NW->Flags &= ~WFLG_SIMPLE_REFRESH;

	ErrExit:
	return(Success);
}

// Put ptr to this func in the gad->UserData function
struct EditWindow *AsyncReqCancelHandler(struct EditWindow *Edit,struct IntuiMessage *im)
{
	if (im->Class == IDCMP_GADGETUP)
	{
		EndGrazerRequest(FALSE);
		Edit = NULL;
	}

	return(Edit);
}

// Put ptr to this func in the gad->UserData function
struct EditWindow *AsyncReqContinueHandler(struct EditWindow *Edit,struct IntuiMessage *im )
{
	if (im->Class == IDCMP_GADGETUP)
	{
		/* This requester has a filename string gadget */
		if ( FindGadget(Edit->Gadgets,ID_PATH) )
		{
			Edit = AsyncReqHandlePath(Edit,im);
		}
		else
		{
			EndGrazerRequest(TRUE);
			Edit = NULL;
		}
	}

	return(Edit);
}

struct EditWindow *AsyncReqBackupHandler(struct EditWindow *Edit,struct IntuiMessage *im )
{
	if (im->Class == IDCMP_GADGETUP)
	{
		/* One more sneaky hack, set userdata to one to tell project
		 * requester end code that the backup button was hit
		 */
		global_gr->gr_UserData = 0x01;

		/* This requester has a filename string gadget */
		if ( FindGadget(Edit->Gadgets,ID_PATH) )
		{
			Edit = AsyncReqHandlePath(Edit,im);
		}
		else
		{
			EndGrazerRequest(TRUE);
			Edit = NULL;
		}
	}

	return(Edit);
}

struct EditWindow *AsyncReqHandlePath(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct GrazerRequest	*gr = global_gr;
	struct Grazer			*Grazer;

	// No valid pathname set as of yet.
	gr->gr_Flags &= ~(GRAZREQ_VALIDFILENAME);

	if ( Grazer = (struct Grazer *)EditBottom->Special )
	{
		if ( gr->gr_FilePath ) FreeSmartString(gr->gr_FilePath);

		if ( gr->gr_FilePath = DuplicateSmartString(Grazer->Path) )
		{
			struct Gadget	*Gadget;
			char				 ch;

			ch = SmartStringRight(gr->gr_FilePath);
			if ( (ch != ':') && (ch != '/') )
				AppendCSmartString("/",gr->gr_FilePath);

			Gadget = FindGadget(Edit->Gadgets,ID_PATH);

			if ( AppendCSmartString(((struct StringInfo *)Gadget->SpecialInfo)->Buffer,gr->gr_FilePath) )
			{
				gr->gr_Flags |= GRAZREQ_VALIDFILENAME;

				EndGrazerRequest(TRUE);
				Edit = NULL;
			}
		}
	}

	return(Edit);
}

BOOL AsyncReqResize(struct EditWindow *Edit, UWORD NewHeight)
{
	return(0);
}

VOID AsyncReqClose(struct EditWindow *Edit )
{
	if (Edit)	CloseEditWindow(Edit);
}

VOID AsyncReqFree(struct EditWindow *Edit )
{
	if (Edit)
	{
		FreeEditWindow(Edit);

		if (Edit->Special)
			FreeMem(Edit->Special,sizeof(struct EditSpecial));

		FreeSmartNode(&Edit->Node);
	}
}

LONG IsRequestedFileType( struct EditNode *Node )
{
	struct GrazerRequest	*gr;
	LONG						 use_it = TRUE;

	if ( gr = global_gr )
	{
		if ( ((struct GrazerNode *)Node)->DOSClass == EN_FILE )
		{
			LONG			 i = gr->gr_num_filetypes;
			BYTE			*ch = gr->gr_filetypes;

			if ( ch )
			{
				use_it = FALSE;

				while (i--)
				{
					if ( ((struct GrazerNode *)Node)->Type == *ch++ )
					{
						use_it = TRUE;
						break;
					}
				}
			}
		}
	}
	return(use_it);
}

struct EditWindow *BotProjNewProject(
		struct EditWindow *Edit,
		struct IntuiMessage *im )
{
	if ( im->Class == IDCMP_GADGETUP )
	{
		BeginGrazerRequest( &ProjProjGrazRequest );
		Edit = EditTop;
	}

	return(Edit);
}
