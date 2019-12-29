*********************************************************************
* $instinct.i$
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: INSTINCT.I,v 2.98 94/07/28 11:24:09 Holt Exp $
*
* $Log:	INSTINCT.I,v $
*Revision 2.98  94/07/28  11:24:09  Holt
*ADDED ICONCOPYLINES FOR CG USE.
*
*Revision 2.97  94/07/17  17:12:09  Holt
*added grabicon, mkpicon,mkpiconrgb
*
*Revision 2.96  94/07/14  01:00:46  Holt
*added PIcon functions to TB.
*
*Revision 2.95  94/07/01  13:01:16  Kell
*Added new binary to ascii conversion routines to TB.
*Added some requester related functions to TB.
*Added FGC_O/M/P button commands to TB.
*
*Revision 2.94  94/06/04  04:06:08  Kell
*Added TB_RequesterResult field.
*Improved the definition and usage of the TB_DisplayRenderMode bits.
*
*Revision 2.93  94/05/24  22:18:36  Kell
*Many FGC_....Commands rename to this new naming convention.
*
*Revision 2.92  94/05/24  22:17:18  Kell
*FGC_EVENT replaced by FGC_TOMAIN command.  FGC_TOPRVW added.
*WaitTime field and Wait4Time() and FGC_TakeCommand() functions added to TB
*
*Revision 2.91  94/04/21  17:29:06  Kell
*Added TB_GUImode field to TB
*
*Revision 2.90  94/03/31  13:10:20  Kell
**** empty log message ***
*
*Revision 2.89  94/03/19  00:36:29  Kell
*
*cd /bat
*
*
*
*
*Revision 2.88  94/03/18  17:18:02  Kell
*New TB field for TB_VideoDuration
*
*Revision 2.87  94/03/18  09:23:38  Kell
*New fields for flyer starttime.
*
*Revision 2.86  94/03/15  23:50:27  Kell
*New SendFGC2Crouton routine added to TB
*
*Revision 2.85  94/03/15  14:12:55  Kell
*New TB functs
*
*Revision 2.84  94/03/09  17:44:41  Kell
**** empty log message ***
*
*Revision 2.83  94/03/07  22:29:48  Kell
**** empty log message ***
*
*Revision 2.82  94/03/07  09:30:30  Kell
**** empty log message ***
*
*Revision 2.81  94/03/07  08:19:16  Kell
*New lib offsets for the Buffered (not Buffer) dos routines.
*
*Revision 2.80  94/03/06  16:42:53  Kell
**** empty log message ***
*
*Revision 2.79  94/03/06  16:40:28  Kell
**** empty log message ***
*
*Revision 2.78  94/02/17  12:36:05  Kell
**** empty log message ***
*
*Revision 2.77  94/02/07  15:55:48  Kell
*Various changes to support the new 4.0 croutons & projects.
*
*Revision 2.76  94/01/08  01:47:10  Kell
*New LoadAnimHeader function added to TB
*
*Revision 2.75  94/01/07  14:30:25  Kell
*New field that works with FGC_LOAD during project loading.
*
*Revision 2.74  93/12/04  00:01:27  Turcotte
**** empty log message ***
*
*Revision 2.73  93/11/19  17:57:52  Turcotte
**** empty log message ***
*
*Revision 2.72  93/11/06  04:23:51  Kell
**** empty log message ***
*
*Revision 2.71  93/11/03  23:10:15  Turcotte
**** empty log message ***
*
*Revision 2.70  93/10/29  03:28:05  Kell
*New Mouse button & position functions added to TB
*New InstallAVE/C noWait functions added to TB
*
*Revision 2.69  93/10/28  15:49:39  Turcotte
**** empty log message ***
*
*Revision 2.68  93/10/23  05:50:00  Kell
*New ANIMFX_BIT to indicate if current effect is an ANIM FX.
*
*Revision 2.67  93/10/19  18:12:05  Turcotte
*Added new routines for Popup Menu
*
*Revision 2.66  93/06/08  19:50:24  Kell
**** empty log message ***
*
*Revision 2.65  93/06/05  07:40:54  Kell
*DoSafeWriteRGB and SimpleBMcoplistRGB data fields added to TB
*
*Revision 2.64  93/05/30  13:08:28  Kell
*New TB fields for substituting custom TBar rendering routines.
*
*Revision 2.63  93/05/29  04:16:14  Kell
**** empty log message ***
*
*Revision 2.62  93/05/29  02:09:41  Turcotte
**** empty log message ***
*
*Revision 2.61  93/05/28  23:39:15  Kell
*New flag for FX comments on/off
*
*Revision 2.60  93/05/28  21:19:00  Kell
**** empty log message ***
*
*Revision 2.59  93/05/28  15:13:45  Kell
**** empty log message ***
*
*Revision 2.58  93/05/27  17:47:38  Hartford2
*FASTMEMSIZE now 504,000 for CG PS Renderer
*
*Revision 2.57  93/05/27  17:08:05  Turcotte
*Added new filed for number of framestores on current device
*
*Revision 2.56  93/05/27  04:33:10  Kell
*New fields in the FGS and TBPE stuctures for adding a block to the end of each project entry for a long comment or what ever.
*
*Revision 2.55  93/05/24  16:53:01  Turcotte
*Remove Screen Fudge
*
*Revision 2.54  93/05/24  06:03:25  Kell
**** empty log message ***
*
*Revision 2.53  93/05/21  06:28:35  Turcotte
**** empty log message ***
*
*Revision 2.52  93/05/13  20:21:29  Kell
**** empty log message ***
*
*Revision 2.51  93/05/12  17:20:14  Hartford
*CHIP now 560,000
*
*Revision 2.50  93/05/12  17:19:16  Turcotte
**** empty log message ***
*
*Revision 2.49  93/05/08  15:00:45  Kell
*Added DVElutoff function to TB
*
*Revision 2.48  93/05/07  22:06:57  Kell
**** empty log message ***
*
*Revision 2.47  93/05/07  00:12:28  Kell
*New SetupAndInstallSSBM() function added to TB
*
*Revision 2.46  93/05/06  10:44:21  Turcotte
**** empty log message ***
*
*Revision 2.45  93/05/06  01:34:40  Kell
*Added TB_DoTBarYMouse, TB_NumFieldsSlow/Medium/Fast data fields to TB
*and added ForceDoTBar2Top() function.
*
*Revision 2.44  93/05/05  20:33:27  Kell
*Added TB_StashCount field to TB
*
*Revision 2.43  93/05/05  02:15:40  Turcotte
**** empty log message ***
*
*Revision 2.42  93/04/27  21:38:34  Kell
*Added AnimFXHander() to TB
*
*Revision 2.41  93/04/27  20:55:37  Turcotte
**** empty log message ***
*
*Revision 2.40  93/04/18  07:12:21  Kell
*Added audio function to TB.
*
*Revision 2.39  93/04/17  04:10:01  Kell
*Added TB_BGColorFGL to ToastBase.  Added FGS_CustomMatteColor to fastgadgets.
*
*Revision 2.38  93/04/16  10:19:05  Kell
**** empty log message ***
*
*Revision 2.37  93/04/16  10:03:17  Kell
*Added FGS_MatteColor to extended fastgadget structure, for default
*latch matte colors.
*
*Revision 2.36  93/04/16  04:11:38  Turcotte
**** empty log message ***
*
*Revision 2.35  93/04/13  02:12:30  Kell
**** empty log message ***
*
*Revision 2.34  93/04/12  17:58:25  Turcotte
**** empty log message ***
*
*Revision 2.33  93/04/07  08:47:18  Kell
**** empty log message ***
*
*Revision 2.32  93/04/07  00:12:02  Kell
*Added TB_TBarTime field into ToasterBase
*
*Revision 2.31  93/04/06  03:28:29  Kell
*Added GetFileLoadName and GetFileSaveName functions that use the ASL file requester.
*
*
*Revision 2.30  93/04/02  00:06:04  Turcotte
*Added new ham animation functions.
*
*Revision 2.29  93/03/31  23:49:40  Kell
*Added MasterTimerEvent & MasterTimerData fields for field events
*
*Revision 2.28  93/03/25  21:31:19  Kell
*Fixed CALL.w macro.
*
*Revision 2.27  93/03/25  06:22:25  Kell
*SetupSBMCopListAA & SetupSSBM functions added to ToastBase.
*
*Revision 2.26  93/03/22  22:38:32  Hartford2
*Added dosbuffer routines
*
*Revision 2.25  93/03/18  17:19:09  Hartford2
*Added SendRGBExtBeginRegion()
*
*Revision 2.24  93/03/17  16:29:43  Kell
*Added Draw/Comp CroutonImage functions to TB.
*
*Revision 2.23  93/03/15  15:34:59  Hartford2
*Added SendRGBExtInit()
*
*Revision 2.22  93/03/11  01:08:02  Turcotte
*Change to Grid stuff for ARexx.
*
*Revision 2.21  93/03/10  05:38:56  Kell
*New TB_InterfaceDepth field.
*
*Revision 2.20  93/03/09  18:01:57  Turcotte
*Changes to allow softsprite to move to bottom of the screen
*
*Revision 2.19  93/03/04  19:42:07  Finch
*Added New Anim Vectors
*
*Revision 2.18  93/03/02  20:28:20  Turcotte
*New routines for LW Preview
*
*Revision 2.17  93/03/01  16:47:46  Kell
*Added InstallSBM***** & InstallAVE***doELHlist functions
*
*Revision 2.16  93/02/28  02:31:12  Kell
**** empty log message ***
*
*Revision 2.15  93/02/27  21:08:53  Turcotte
*Added SoftSpriteAudioOnScreen.
*
*Revision 2.14  93/02/24  15:46:58  Turcotte
*added SoftSpriteOnScreen to ToastBase
*
*Revision 2.13  93/02/24  03:21:47  Kell
*Added some new AA Toaster functions to ToasterBase.
*
*Revision 2.12  93/02/13  23:01:38  Kell
*Fixed ESCFETCH typo
*
*Revision 2.11  93/02/13  14:31:36  Kell
*AACHIP bit, new CHIPMem and FASTMem chuck sizes
*
*Revision 2.10  93/01/22  10:40:52  Kell
*Added DoSyncWrite function to ToastBase
*
*Revision 2.9  93/01/21  04:20:11  Turcotte
*Changes for new Grids
*
*Revision 2.8  93/01/20  20:45:42  Kell
*Added InitReadScanLine funtion to Library
*
*Revision 2.7  93/01/20  16:10:06  Turcotte
**** empty log message ***
*
*Revision 2.6  92/12/17  17:56:02  Kell
*Added TB_BPLCON0orBits, TB_Flags2, TB_Flags3 fields
*
*Revision 2.5  92/10/07  17:42:22  Finch
*Removed Unused AnimWipe Vectors, Added Free Vectors 1 to 5
*
*Revision 2.4  92/09/27  23:36:41  Turcotte
*Added IDCMP flag MOUSEUP
*
*Revision 2.3  92/09/22  16:55:19  Finch
*Added IFND LABEL ENDC for Includes
*
*Revision 2.2  92/09/18  03:46:48  Kell
*Changed MAXDISPLAYDEPTH to 2 (from 4).  Documented death of
*DISPLAYMODEs 0 & 1, due to changing to 2 field user interface.
*
*Revision 2.1  92/09/12  02:11:10  Kell
*Added fields for the Master Clock, & Disable/EnableInterrups functions.
*
*Revision 2.0  92/05/18  21:24:17  Hartford
**** empty log message ***
*
*********************************************************************

	IFND	NEWTEK_INSTINCT_I
NEWTEK_INSTINCT_I	SET	1
	IFND	EXEC_MACROS_I
	include "exec/macros.i"	; CLEAR and CLEARA, among other stuff
	ENDC
	IFND	INTUITION_INTUITION_I
	INCLUDE	'intuition/intuition.i'
	ENDC
	IFND	VTHAND_I
	INCLUDE	'vthand.i'
	ENDC
	IFND	ELH_I
	INCLUDE	'elh.i'
	ENDC
	IFND	TAGS_I
	INCLUDE	'tags.i'
	ENDC

************************************************************************
*
* instinct.i
*
* Toaster interface display include file.
*
* Copyright NewTek Inc., 6/1/89.
*
*********

_CCODE		EQU	0	; define this symbol as non-0 to allow the
*				; generation of code for supporting linked
*				; C code calling Toaster library functions
*				; directly

DISPLAYWIDTH	EQU	768	; actual data fetch is ALWAYS 768
DISPLAYHEIGHT	EQU	481	; assume interlace with 2,4 or 8 fields
*				; corresponding to allowables plane depths of
*				; 1,2, or 4
*				; (currently the Toaster interface code
*				; and suport code all assume a depth of 4)


* It is best to check the depth by looking in TB_InterfaceDepth!
* NOTE: CHANGE THIS FROM 2 TO SUPPORT THE 3 PLAIN DISPLAY. SKELL 3/10/93
* NOTE: CHANGE THIS FROM 4 TO SUPPORT THE 2 PLAIN DISPLAY. SKELL 9/18/92
MAXDISPLAYDEPTH	EQU	3	; ...ditto from just above

*					; initial and standard view mode
*					; settings for interface/switcher's
*					; display screen
DEFSMODES	EQU	V_HIRES+V_LACE
*					; initial and standard screen flag
*					; settings for interface/switcher's
*					; display screen
DEFSFLAGS	EQU	CUSTOMSCREEN+SCREENQUIET+SCREENBEHIND+CUSTOMBITMAP
*					; initial and standard IDCMP flag
*					; settings for interface/switcher's
*					; display window
__tmp	SET	GADGETDOWN+RAWKEY+MOUSEBUTTONS+DISKINSERTED+DISKREMOVED
DEFWIDCMP	EQU	GADGETUP+INTUITICKS+__tmp
*					; default and standard window
*					; characteristics flags for
*					; interface/switcher's display window

__tmp	SET	BACKDROP+BORDERLESS+SMART_REFRESH+RMBTRAP
__tmp	SET	NOCAREREFRESH+ACTIVATE+__tmp
DEFWFLAGS	EQU	__tmp
DEFWTYPE	EQU	CUSTOMSCREEN	; initial and standard window type
*					; of the interface/switcher's display
*					; initial and standard activation
*					; flags for area control gadgets
DEFGACTI	EQU	GADGIMMEDIATE
*					; initial and standard flags for
*					; area control gadgets
DEFGFLAGS	EQU	GADGHNONE
DEFGTYPE	EQU	BOOLGADGET	; initial and standard gadget type
*					; for area control gadgets

SCREENFUDGEX	EQU	0 ;48	; offset subtracted from sc_LeftEdge
SCREENFUDGEY	EQU	0 ;36	; offset subtracted from sc_TopEdge
*				; the above offsets are to adjust the mouse
*				; position on the interface/switcher display
*				; NOTE: if you plan to go back to WB without
*				; closing down the interface/switcher display
*				; - you need to temporarily fix sc_LeftEdge
*				; and sc_TopEdge by adding back these offsets
*				; - otherwise the display will be messed up
*				; - when returning from WB, or wherever,
*				; subtract the offsets again

*	The following labels have been added to 3.0 to allow easy positioning
*	of the interface screen gadgets.


POSY_TITLE1		EQU	30+1
POSY_TBFG		EQU	43+1
POSY_GRIDROW		EQU	433+1	;243+1
POSY_TITLE2		EQU	272+1
POSY_TBAR		EQU	286+1
POSY_NUMPAD		EQU	285+1
POSY_SUPERIMPOSE	EQU	383+1
POSY_MAIN		EQU	297+1
POSY_PREVIEW		EQU	359+1
POSY_FREEZROW		EQU	413+1
POSY_LOGO		EQU	440+1

POSX_LEFTEDGE		EQU	48+16
POSX_GRIDROW		EQU	224+16
POSX_LOGO		EQU	224+16
POSX_TBAR		EQU	407+16
POSX_NUMPAD		EQU	523+16
POSX_SUPERIMPOSE	EQU	523+16
POSX_AUTO		EQU	240
POSX_TAKE		EQU	160
POSX_SPEED		EQU	304

*+ Constants governing ToolBox FastGadgets and the ToolBox grid. Must be
*+ adhered to as they are used as constants in most ToolBox FG
*+ manipulating library functions.

TBFG_LEFTEDGE	EQU	POSX_LEFTEDGE ; 48		; display and mouse offsets from 0,0
TBFG_TOPEDGE	EQU	POSY_TBFG ;30	; of containing window

TBFG_WIDTH	EQU	80		; dimensions of ToolBox FastGadget
TBFG_HEIGHT	EQU	50		; imagery and select box

TBFG_GRIDSIZE	EQU	32		; number of FG on a single
*					; displayable grid
TBFG_GRIDACROSS	EQU	8		; number of FastGadgets across
TBFG_GRIDROWS	EQU	4		; and Fastgadget rows in grid
TBFG_GRIDNUM	EQU	9		; number of ToolBox FG grids - MUST
*					; match number of ToolBox FastGadget
*					; lists in ToasterBase
*					; DO NOT USE THIS CONSTANT.  USE
*					; TB_NUMGRIDS if version >=3.0

******************************************************************
*+ More FastGadget tidbits:
*+ FastGadget imagery must have a multiple of 16 pixels specified for width.
*+ When rendered by the FastGadget functions, they must be rendered at WORD
*+ boundries (0,16,32,etc.). Also FastGadgets and FastGadget functions assume
*+ and depend heavily on the DISPLAYWIDTH value defined. Currently the
*+ FastGadget functions assume a bitplane depth of 4. Also FastGadget
*+ functions usually assume that the FastGadgets are tethered directly, or
*+ indirectly through a requester, to a window. Never directly to a screen.

*+ The FG_ModeType field must setup to denote how the FastGadget data is to
*+ be rendered into the BitMap by the FastGList functions. There are 4
*+ display modes to choose from:
*+ DISPLAYMODE0 (4 data planes - primarily for 256 color displays),
*+ DISPLAYMODE1 (2 data planes - primarily for 16 color displays),
*+ DISPLAYMODE2 (2 data planes - primarily for 4 grey scale displays),
*+ DISPLAYMODE3 (1 data plane - primarily for black and white displays).

* NOTE!!! As of Sept 18,1992, pre version 3.0, all modes but 2 & 3 have been
* disabled!! Because now we support only the 2 field user interface, not
* the original 4 field display.  You can still use the old data formats
* except only the lower 2 of the 4 planes will get rendered. SKELL 9/18/92

*+
*+ FastGadget dataplane images are word interleaved. Instead of having
*+ contiguous data words for each separate 1,2, or 4 planes where each
*+ dataplane would be copied to its corresponding bitplane in its entirety
*+ before continuing with the next dataplane and bitplane, the dataplane is
*+ organized so that a contiguous group of words update a single word
*+ position in all bitplanes before continuing to update the next word
*+ position in all bitplanes with the next contiguous group of interleaved
*+ dataplane words. Also the SoftSprite is rendered with interleaved data.
*+ The advantage to rendering with interleaved data is to reduce the flicker
*+ associated with biplane updating where the video beam is displaying an
*+ image that is not completely rendered. With interleaved data no more than
*+ a word (16 pixels on a single line) will likely cause a flicker error. In
*+ contrast, data copied a bitplane at a time can have an flicker error the
*+ size of image being placed.

DISPLAYMODE0	EQU	0		; 4 data planes copied to 4 bitplanes
*					; dataplanes: A B C D
*					; bitplanes:  1 2 3 4
*					; 256 colors supported
DISPLAYMODE1	EQU	4		; 2 data planes copied to 4 bitplanes
*					; dataplanes: A  B
*					; bitplanes:  12 34
*					; 16 colors supported
DISPLAYMODE2	EQU	8		; 2 data planes copied to 4 bitplanes
*					; dataplanes: A  B
*					; bitplanes:  13 24
*					; 4 grey levels supported
DISPLAYMODE3	EQU	12		; 1 data plane copied to 4 bitplanes
*					; dataplanes: A
*					; bitplanes:  1234
*					; black and white supported
DISPLAYMODE4	EQU	16		; 3 data planes+Mask copied to 3 or 2
DISPLAYMODE5	EQU	20		; 2 data planes copied to 3 or 2 planes
					; use standard mask for hilite, and data
					; plane 3

DISPLAYMODE6	EQU	24		; Used by version 4.0 icons. The ->icon
					; is actually a ptr to a BM structure!

*+ Addendum 11/7/89: Discussion of 2 new FastGadget fields: FG_HiLiteVal and
*+ FG_HiLiteMask.
*+ These 2 fields are part of a special FastGadget imagery hi-lighting
*+ system understood by the function DrawFastGList(). The FG_HiLiteVal field
*+ contains a byte value that can be doubled into a mask value for the
*+ FG_HiLiteMask field. The FG_HiLiteMask field is actually the controlling
*+ field, if it is non-zero, it is taken as a mask value to be processed
*+ along with the FastGadget imagery into the display thereby providing
*+ a form of highlighting. If the value is zero, normal rendering of the
*+ FastGadget imagery is performed. The primary motivation behind creating
*+ this system was to provide hi-lighting without requiring an alternate
*+ (and memory hungry) FastGadget image.
***********************************************************************

   STRUCTURE	FastGadget,gg_SIZEOF	; superset of a Gadget structure
*					; (align to longword for enhanced
*					;  68020/30/40 performance)
	WORD	FG_ModeType		; FastGadget type for display render
					; This was DISPLAYMODE2 on all 1.0
					; and 2.0 ToolBox Croutons. You can
					; use this field to identify pre 3.0
					; or pre 4.0 effects.
					
	WORD	FG_WWidth		; word width-1 counter
	WORD	FG_Height		; height-1 counter
	WORD	FG_Modulus		; byte modulus from line to line
	LONG	FG_Offset		; byte offset within container
	APTR	FG_Data			; ptr to current source image data
	WORD	FG_EntrySize		; # of source image ptrs in PTRTable
	WORD	FG_PTRIndex		; index into PTRTable for Data ptr
	APTR	FG_PTRTable		; ptr to source image ptr array
	APTR	FG_Function		; routine to run on FastGadget select
	BYTE	FG_LoadFlag		; non-0 if loaded from external src
	BYTE	FG_DispFlag		; non-0 if not to be displayed
	BYTE	FG_MouseFlag		; non-0 if not to listen to mouse
	BYTE	FG_HiLiteVal		; value to make FG_HiLiteMask
	WORD	FG_IndexID		; for indexing FG by WORD value
	WORD	FG_HiLiteMask		; non-0 to cause special hi-lighting
*					; to occur during rendering
	WORD	FG_BorderCon		; non-0 AND FG_HiLiteMask non-0 cause
*					; special border masking to be used
*					; on the imagery to be rendered
*					; Addendum 1/24/90: added border
*					; control fields
	WORD	FG_TopSize		; number of lines to mask on top
	WORD	FG_BotSize		; number of lines to mask on bottom
	WORD	FG_LeftWSize		; number of word to mask on left
	WORD	FG_RightWSize		; number of word to mask on right
	WORD	FG_LeftMask		; bit mask for left edge
	WORD	FG_RightMask		; bit mask for right edge

	LABEL	FG_Extra1 ;old defunct label (was a WORD)	

	UBYTE	FG_Flags1		; Various flags for expansion uses
	UBYTE	FG_Flags2

	STRUCT	FG_spare1,16		; Added 1-13-94

* Always pad your hardcoded FG structure to a length of FG_SIZ !!!!
* FG_SIZ may change in the future, so do something like this:
*  dcb.b FG_SIZ-FG_Extra1-2,0

	LABEL	FG_SIZ			;

* FG_Flags1 bits
TRIMARK_BIT	EQU  0			; Addendum 10-17-91:
TRIMARK_MASK	EQU  (1<<TRIMARK_BIT) 	; This bit indicates to DrawFastGList
					; to put a flashing Triangular Mark
					; in the upper left corner of the
					; ToolBox Crouton.
*					; the FastGadget structure can be
*					; extended by the programmer to
*					; contain additional private
*					; information - the above structure
*					; represents what is needed by the
*					; Toaster system - that has been
*					; defined

*					; Addendum 9/11/89: This structure is
*					; extended on certain types of
*					; FastGadgets - most notably ToolBox
*					; FastGadgets


**********************************************************************
*+ Addendum 9/13/89: The following section is devoted to the ToolBox
*+ FastGadget system.

*+ The following structure defines the standard FastGadget structure
*+ extension that must be appended onto the back of a FastGadget structure
*+ of a ToolBox grid FastGadget "crouton". It contains user definable -
*+ universal data structures shared by all FastGadgets that are ToolBox
*+ grid FastGadgets. NOTE FOR THE FOLLOWING: The following fields are
*+ assumed to be there space wise, it is the perogative of the ToolBox FG
*+ system in place as to whether or not to insure their contents and usage.
*+ They should be initialized to zero if not used.

   STRUCTURE	StandardToolFGExt,FG_SIZ

  	APTR	FGS_FileName		; BSTR with UWORD EVEN length
					; This block gets allocated by
					; LoadFastG, and deallocated by
					; UnLoadFastG.

	LONG	FGS_ObjectType		; Crouton Type (see CrUD_ in tags.i)
	LONG	FGS_ObjectVersion	; Version of Crouton (see CrUD_ in tags.i)

	APTR	FGS_EntryLibrary	; A pointer to a library that is
					; automatically opened when the
					; crouton is loaded.  This Lib
					; must contain a crouton handler.

	LONG	FGS_EntryRoutine	; The negative library offset for
					; the crouton handler = (the routine ID)
					; Currently, only one library, the
					; "effects.library" will be
					; automatically opened. Though, soon
					; we will actually state the library
					; name(s), in a FORM chunk in the
					; crouton file.

	APTR	FGS_TagLists		; Offset from start of FG to
					; link list of taglists.
					; The first list (maybe NULL)
					; is a LoadSeged tag list, all
					; others were AllocMemed. Some of	
					; this stuff is saved in projects,
					; And stompped on by project loading.
					; These lists should follow our
					; standard TagList format so any code
					; can look thru a croutons taglist,
					; though FGC commands would be a
					; better way of Getting/Putting items
					; into the TAG list.

	LONG	FGS_LocalData		; Normally a crouton will contain
					; some tag item which can be used
					; for local data.  But if a Crouton
					; wishes to allocate it's own memory
					; then, it can use this as a pointer
					; to memory nodes. Because we need
					; to be able to locate local data
					; from just the FG ptr, we must use
					; either tag items or this pointer.

* If new fields must be added to this top FGS section, please take
* these fields from the following STRUCT!!!!
	STRUCT	FGS_spare1,16

     LABEL FGS_SIZ

*****************************************************************
	STRUCTURE	TagListNode,0
		APTR	TLN_NextNode	;->next node
		APTR	TLN_Size	;->size of this node (includes this structure)

* Ideas for the future. Not currently used!!!
		APTR	TLN_PreviousNode
		APTR	TLN_Name	;nodes name / ID
		LONG	TLN_Priority	;nodes priority
	LABEL	TLN_SIZEOF
* Data is appended here

*****************************************************************

*+ DOC NOTE: The FG_IndexID field of a ToolBox FastGadget is entrusted to
*+ provide information on the position of the TB FG in a ToolBox display grid
*+ as well as the sequence position of the particular TB FastGadget in the
*+ total ToolBox FastGadget project.

*+ Addendum 9/18/89: The following represents a file memory image of an
*+ entry structure of a TB FastGadget (both external and internal types) in a
*+ project script to load/save ToolBox FastGadgets to/from disk. Has quite a
*+ bit of a direct relationship to some of the ToolBox FastGadget extensions
*+ mentioned just above.

   STRUCTURE	TBProjectEntry,0

	LONG	TBPE_EntrySize	; 0=end of file, EVEN size!!!
			; (all bytes upto next entry, not including these 4)

	WORD	TBPE_FileNameSize	;pad to an EVEN size!!!!	
	LABEL	TBPE_FileName	; Null terminated file name.
				; Defaults to Effects drawer, but may
				; contain a full path.
	
*	dc.b	'name here',0
*	CNOP	0,2
	
*	LABEL	TBPE_Parameters

* A "Special TAG list" will follow the filename.
* The project loader only uses the TBPE_EntrySize, so this data
* doesn't need to be a TAG list, but could be any block of memory of
* size TBPE_EntrySize-(TBPE_Parameters-TBPE_IndexID).
* Example:
*	ULONG	FGStagID_MatteColor	;
*	ULONG	FGStagSZ_MatteColor	;Length of MatteColor EVEN SIZE
*	 UWORD	.			;MatteColor value

*	ULONG	FGStagID_FCountMode	;
*	ULONG	FGStagSZ_FCountMode	;Length of FCountMode EVEN SIZE
*	 UWORD	.			;FCountMode value

*	ULONG	FGStagID_IndexID	; the FG_IndexID for the ToolBox FG -
*	ULONG	FGStagSZ_IndexID	; determines the placement of the
*	 UWORD   .			; ToolBox FastGadget

*	etc.
*	ULONG	0			;end of tag list

*+ Addendum 2/22/90:
*+ The TBPE structure file image mentioned up above is always read/written
*+ in one chunk by the Toaster system software, which means it is linear and
*+ contiguous. The AddOn data specified by in the standard portion of the
*+ TBPE structure is always positioned directly AFTER standard portion of
*+ the TBPE structure and is ONLY VALID for external ToolBox FastGadgets. The
*+ AddOn data fields are ignored in the internal ToolBox FastGadget and so
*+ the standard TBPE structure will be followed directly by the internal
*+ ToolBox FastGadget's ParmSize system to be handled by the parenting Slice.
*+ In the case of an external ToolBox FastGadget, the AddOn data will be
*+ managed by the Switcher using the ReadProject system.

*+ The main user interface display is subdivided in such a way in order to
*+ be able to break down into separate lists the FastGadgets living in the
*+ display so we can search selectively and therefore quickly. Also because
*+ of the separate FastGadget list, it often allows us the advantage of
*+ being able to selectively update the interface display. Each subdivision
*+ of the interface/switcher display is managed by a control area gadget.
*+ Each control area gadget is in actuality a BOOLEAN gadget with no
*+ imagery and an activation flag of GADGIMMEDIATE. These control area
*+ gadgets are linked into the interface window to intercept FastGadget
*+ selection via the IDCMP. Because of the linked nature of intuition
*+ gadgets, you can overlap them in limited fashion and take advantage of
*+ gadget ordering when subdividing the interface/switcher display window.
*+ FastGadgets are not linked into interface window. They are instead found
*+ via list pointers in the ToasterBase structure. On a select of an control
*+ area gadget, the appropriate FastGadget list(s) is/are searched for the
*+ FastGadget that the mouse was over when the select button was hit. If one
*+ found, the function code of the FastGadget is called with an long value
*+ arguments placed on the stack (ala C) of the command FGC_SELECT, a pointer
*+ to the governing FastGadget, and a pointer to the ToasterBase structure.
*+ The the C template would look like the following:
*+
*+ void CFunction( FastGadget cmd, FastGadget ptr, ToasterBase ptr );
*+
*+ The stack at function code entry looks like:
*+ SP+00 Return Address
*+ SP+04 FastGadget cmd
*+ SP+08 FastGadget ptr
*+ SP+12 ToasterBase ptr
*+
*+ (this new protocol was added 9/27/89)
*+
*+ The called function code has access to all of the CPU registers, none of
*+ them need be saved and restored at exit. This means that you should save
*+ and restore registers pertinent to you when threading down other function
*+ code routines, don't expect to get them back. Also note that upon entry
*+ into your function code, you cannot assume the contents of any registers.
*+ If you are an HLL function code routine, such as C, you will need to
*+ insure that your environment is loaded so that you can execute. Also the
*+ above mentioned stack space is completely local to the called function
*+ code and can be used as pleased. If and when your function code invokes
*+ other function code routines, the above appropriate stack arguments MUST
*+ be placed on the stack.
*+
*+ When a FastGadget function has been called it is in total control (it will
*+ be the only entity in the Toaster system actively running) of the Toaster
*+ system. It can do as it likes (should of course be governed by the
*+ FGC_xxxx command it received), but must register all changes made to the
*+ Toaster system in ToasterBase, if those elements are changeable. Those
*+ elements that are not changeable can still be used, but must be restored
*+ prior to returning to caller, an example of this being the parameters
*+ in the interface/switcher's window structure.
*+
*+ Addendum: In reference to saving the state of the interface/switcher
*+ display screen and window, the standard settings used and that should be
*+ preserved are denoted at the top of this include file.

   STRUCTURE	ToastProto,0
	LONG	TBS_RetAddr
	LONG	TBS_FGC
	APTR	TBS_FG
	APTR	TBS_TB
	LABEL	TBS_SIZ

*+ Addendum 10/8/89:
*+ The above protocol works fine for those FG systems that can be LoadSeged
*+ into memory and invoked directly, much like a memory overlay. However,
*+ some HLLs require that part of their setup be done within the startup
*+ code. This has the unfortunate requirement that those code entities must
*+ not be just separate code entities, but separate code entities within a
*+ separate *PROCESS*. One method to have one of these type FG systems work
*+ within the Toaster system with little resistance requires that a little
*+ extra work in the form of an intermediate function code handler that
*+ intercepts the standard FGC protocol described above and translates it
*+ into an FGC message and then using the Exec message handling system to
*+ complete the protocol transaction with the main HLL function code handler.
*+ Since in the Toaster system, only one entity can be running at a time,
*+ the intermediate function code handler must wait until the primary HLL
*+ function code handler is done and has returned the message before it
*+ continues. (ToasterBase has Exec message system support for intermediate
*+ function handlers just described)

   STRUCTURE	ToastProtoMsg,MN_SIZE
	LONG	TBM_FGC
	APTR	TBM_FG
	APTR	TBM_TB
	LONG	TBM_UserData	; Addendum 1/12/90: for JR's CG mostly
	APTR	TBM_UserData2	; Addendum 3/19/91:
	LABEL	TBM_SIZ

*+ Addendum 3/30/90:
*+ There is a caveat to run the Video Toaster system when you are a separate
*+ process. You can not use certain ToasterBase fields or functions that
*+ will directly/indirectly require use of a resource (most notably Signals)
*+ that are Process/Task private. Conventional overlay/subroutine type addons
*+ will be running under the Switcher process and do not have this
*+ restriction. PLEASE TREAD CAREFULLY when you are a separate process.

*	These are currently hardcoded and represent the area map of the
*	boolean area gadgets attached to the interface display window.
*	Please note that area control gadgets MUST supply a function code
*	routine to be run.

TOOLLEFT	EQU	TBFG_LEFTEDGE		; dims for ToolBox area
TOOLTOP		EQU	TBFG_TOPEDGE
TOOLWIDTH	EQU	TBFG_WIDTH*TBFG_GRIDACROSS
TOOLHEIGHT	EQU	TBFG_HEIGHT*TBFG_GRIDROWS

CTRLLEFT	EQU	TOOLLEFT		; dims for Control area
CTRLTOP		EQU	TOOLTOP+TOOLHEIGHT
CTRLWIDTH	EQU	TOOLWIDTH/2+(32)
CTRLHEIGHT	EQU	(DISPLAYHEIGHT-40-1)-TOOLHEIGHT

 ifeq 1
MISCLEFT	EQU	TOOLLEFT+CTRLWIDTH	; dims for Misc area
MISCTOP		EQU	CTRLTOP
MISCWIDTH	EQU	TOOLWIDTH-CTRLWIDTH
MISCHEIGHT	EQU	CTRLHEIGHT
 endc

 ifeq 0
MISCLEFT	EQU	TOOLLEFT		; dims for Misc area
MISCTOP		EQU	CTRLTOP
MISCWIDTH	EQU	TOOLWIDTH
MISCHEIGHT	EQU	CTRLHEIGHT
 endc

*	These are the various commands that can be passed as a stack
*	argument to the function code routine to be executed.

FGC_LOAD	EQU	0		; this LONG command indicates to
*					; an external FastGadget just loaded
*					; that it indeed has just loaded and
*					; to perform whatever one-shot
*					; initializations are critical for
*					; the function code routine, such as
*					; C function code routines assuring
*					; that their C environment is in
*					; place, opening libraries, etc.
*+					; addendum 8/28/89: all allocations
*+					; of all resources needed MUST be
*+					; done on this FGC_xxxx command. A
*+					; failure is to be denoted by an
*+					; error code placed in the TB_ErrFlag
*+					; field in ToasterBase and you should
*+					; cleanup all already allocated
*+					; resources prior to exiting to your
*+					; caller - success on the other
*+					; hand will be denoted by the
*+					; TB_ErrFlag field being cleared
*+					; NOTE: if while on a FGC_LOAD
*+					; command code execution, you load
*+					; a FG and issue a FGC_LOAD command,
*+					; you should propagate whatever
*+					; result is returned in TB_ErrFlag
*+					; back to your caller after taking
*+					; any indicated actions.
FGC_UNLOAD	EQU	1		; this LONG command indicates to an
*					; external loaded FastGadget that it
*					; is about to be removed and to clean
*					; up and close down everything before
*					; it is removed - Addendum 9/11/89:
*					; internal ToolBox FastGadgets WILL
*					; unload themselves on this command
*					; call
FGC_SELECT	EQU	2		; this will be the LONG argument
*					; placed on the stack when your
*					; application code is initially
*					; selected by mouse so that it may:
*					; 1) de-select other FastGadgets
*					; that may be currently selected
*					; 2) install itself in ToasterBase
*					; and perform whatever initialization
*					; needs to be done
FGC_REMOVE	EQU	3		; this LONG command indicates that
*					; the application code de-select
*					; its FastGadget and close down
FGC_AUTO	EQU	4		; this LONG command indicates to
*					; the application code to perform
*					; whatever function it does in
*					; responce to the Auto control button
*					; before returning to the interface/
*					; switcher code
FGC_TBAR	EQU	5		; this LONG command indicates to
*					; the application code to take action
*					; in responce to a change in the
*					; TBar slider value in ToasterBase
FGC_FCOUNT	EQU	6		; this LONG command indicates to
*					; the application code that the frame
*					; count in the Speedo FG has been
*					; tampered with and possibly changed
*					; Addendum 9/11/89:
*					; (not used in V1.0)
FGC_GENFG	EQU	7		; this special LONG command indicates
*					; to special ToolBox FastGadget
*					; generating slices to create a
*					; ToolBox FastGadget from provided
*					; parameters and place it in the
*					; denoted ToolBox FastGadget list -
*					; this FGC command is another area
*					; where the TB_ErrFlag system should
*					; be used since alot of dynamic
*					; initializations could occur during
*					; the FastGadget creation process -
*					; the usage of TB_ErrFlag is defined
*					; in the FGC_LOAD command docs
*					; (not used in V1.0)

* For version 4.0, we removed the relvarify feature of
* DoHiliteSelect(), switcher rendering features of DoHiliteSelect(),
* DoHiliteSelectK() and DoHiliteRemove().
* So, now we only have DoHiliteSelect() and DoHiLiteRemove(),
* which act like the old DoHiliteSelectQ() and DoHiLiteRemoveQ().
* ToolBox FG Rendering/Relvarify are now features of the editor task,
* not the switcher. So, we will always use only FGC_SELECT and FGC_REMOVE
* commands with 4.0 ToolBox FGs.
*

FGC_SELECTQ	EQU	8		; this LONG command is functionally
*					; identical to the FGC_SELECT command
*					; except that no actual highlighting
*					; will occur and no user IDCMP is
*					; checked to insure FG selection
FGC_REMOVEQ	EQU	9		; this LONG command is functionally
*					; identical to the FGC_REMOVE command
*					; except that no actual
*					; de-highlighting will occur
FGC_NUMVAL	EQU	10		; this LONG command indicates to the
*					; the application code to take action
*					; in responce to a value specified
*					; by the Numeric FG or by a ToolBox
*					; FG to CG, Frame store, etc.
*					; ADDENDUM 10/5/89:
FGC_SELECTK	EQU	11		; this long command is functionally
*					; identical to the FGC_SELECT command
*					; except that it denotes that the
*					; selection took place was via a
*					; RAWKEY instead of the mouse as is
*					; the case with an FGC_SELECT and
*					; therefore we need no release verify
*					; we also don't need a sibling
*					; FGC_REMOVEK since the FGC_REMOVE
*					; will work fine
FGC_UPDATE	EQU	12		; this LONG command is rather an
*					; internal command issued only from
*					; the UpdateDisplay and ReDoDisplay
*					; library routines to those special
*					; FastGadget sub-systems that can be
*					; changed indirectly by other
*					; FGs (notably the ToolBox FGs
*					; during an effect when the display
*					; can not be presented) and needs to
*					; be refreshed for the user at the
*					; interface/switcher display - this
*					; command is tied very closely to the
*					; fixed internal format of the
*					; interface/switcher code and should
*					; never been issued from anywhere
*					; else other that the above library
*					; routines - nor seen by any other
*					; FG except for special fixed and
*					; known about FG systems - within
*					; this system, each FastGadget system
*					; that is known about by the
*					; interface/switcher has a pair of
*					; word fields TB_xxxPri and TB_xxxSec
*					; - TB_xxxPri is the current state of
*					; the FastGadget system's display and
*					; can only be updated by the
*					; interface/switcher during display
*					; updating - FastGadget systems,
*					; including the FastGadget system
*					; that the fields are pertinent to
*					; can modify the TB_xxxSec field -
*					; when performing a display refresh,
*					; the interface/switcher notices any
*					; differences between these fields
*					; and calls only those FGs that need
*					; updating with an FGC_UPDATE so that
*					; the FastGadget can not only change
*					; its displayable imagery, but also
*					; reflect the new settings in other
*					; internal ways as well - the FG
*					; getting this call should NOT
*					; display its changed imagery! will
*					; be done by the interface/switcher
*??					; Addendum 10/5/89:
FGC_RAWKEY	EQU	13		; this LONG command is rather an
*					; internal command issued from the
*					; interface/switcher to those FG
*					; systems (notably the Numeric FG)
*					; that the interface/switcher always
*					; considers active for keyboard
*					; input - under this system the FG
*					; called can find out the RAWKEY from
*					; the ToasterBase fields and perform
*					; accordingly
*??					; Addendum 10/10/89:
*??					; Addendum 10/23/89: usually the
*					; ToasterBase RAWKEY fields contains
*					; just that on FGC_RAWKEY calls -
*					; however, the TB_KeyCode field will
*					; contain "cooked" input for input
*					; heading for the Numeric FastGadget
FGC_TAKE	EQU	14		; Addendum 12/13/89: This LONG
*					; command indicates to the
*					; application code to perform some
*					; action in responce to the Take
*					; button being punched
FGC_FREEZE	EQU	15		; Addendum 12/13/89: This LONG
*					; command indicates to the
*					; application code to perform some
*					; action in responce to the
*					; freeze/live button being punched
FGC_OBUTTON	EQU	16		; Addendum 12/13/89: This LONG
*					; command indicates to the
*					; application code to perform some
*					; action in responce to a button
*					; being punched on the overlay row,
*					; also historically known as the
*					; LumKey row
FGC_MBUTTON	EQU	17		; Addendum 12/13/89: This LONG
*					; command indicates to the
*					; application code to perform some
*					; action in responce to a button
*					; being punched on the main row
FGC_PBUTTON	EQU	18		; Addendum 12/13/89: This LONG
*					; command indicates to the
*					; application code to perform some
*					; action in responce to a button
*					; being punched on the preview row
FGC_CLIP	EQU	19		; Addendum 1/5/90: This LONG command
*					; indicates to the application code
*					; to perform some action in responce
*					; to the clip level setting being
*					; changed or the key mode setting
*					; being altered
FGC_FSLOAD	EQU	20		; Addendum 1/22/90: This LONG command
*					; indicates to the application code
*					; to perform some action in responce
*					; to the user requesting that a
*					; frame store be loaded.
FGC_FSSAVE	EQU	21		; Addendum 1/22/90: This LONG command
*					; indicates to the application code
*					; to perform some action in responce
*					; to the user requesting that a
*					; frame store be saved.
FGC_MOUSEXY	EQU	22		; Addendum 9/7/90:
*					; provides a means to pass MOUSEMOVE
*					; IDCMP mouse x/y coordinates to a
*					; FG entity
FGC_BG		EQU	23		; Addendum 4/16/91:
*					; Denotes to the controlling entity
*					; that the user has changed the
*					; background (matte) color
FGC_BORDER	EQU	24		; Addendum 4/16/91:
*					; Denotes to the controlling entity
*					; that the user has changed the
*					; border color
FGC_UNAUTO	EQU	25		; If mid-effect, it transitions the
*					; TBar towards the top.
FGC_STDEFX	EQU	26		; Non-Transition effects or others
*					; that operate by a non-standard set
*					; of rules must give up command to a
*					; "Standard" crouton (usually A011)

*--------- New for 4.0 --------------------------
FGC_PUTVALUE	EQU	27		; Uses TB_TagID, TB_TagSize, and
				 	; TB_Data as a source.
					; Allows a FG to put a tag source
					; value into its own local data.

* If the source is larger than the destination, then the destination
* will use the least significant partion of the source. This allows for
* easy conversion between BYTE, WORD, and LONG values.
*
* If the source is smaller than the destination, then the destination
* will "ext" to the larger size on signed values, or pad the upper bytes
* with zeros on non-signed values.

FGC_GETVALUE	EQU	28		; Uses TB_TagID, TB_TagSize, and
				 	; TB_Data as a destination.
					; Allows a FG to return a tag value
					; from its own local data.

* If the source is larger than the destination, then the destination
* will use the least significant partion of the source. This allows for
* easy conversion between BYTE, WORD, and LONG values.
*
* If the source is smaller than the destination, then the destination
* will "ext" to the larger size on signed values, or pad the upper bytes
* with zeros on non-signed values.


FGC_LOADTAGS	EQU	29		; Uses TB_Tags. Lets an FG get a
					; complete list of Tags.  This is
					; used during ProjectLoading.
FGC_SAVETAGS	EQU	30		; Returns TB_Tags. A FG is told to
					; create a linked list of tag lists,
					; which it wants stashed in the
					; project.  Used by ProjectSaving.
* The following two commands are not currently used
FGC_PANEL	EQU	31		; Tells a "selected" FG to open it's
					; control panel.  
FGC_NEXT	EQU	32		; TB_NextCrouton field will contain
					; a pointer to the next crouton.
					; This is filled in by the FG
					; crouton, for use by the sequencer.
					; If TB_NextCrouton is set to NULL,
					; then we are at the end of the
					; project or at a hault. This command
					; must work on croutons that aren't
					; currently selected.
FGC_TOMAIN	EQU	33		; Bring the content to Main with
					; a Take.  Use AUTO if you want
					; to use the Default Fade to bring
					; in the Clip, Still, etc.

FGC_TOPRVW	EQU	34		; Bring the content to Prvw if possible

**********************************************************************
*					; Addendum 9/14/89: The FGC_SELECTQ
*					; and FGC_REMOVEQ commands were added
*					; to allow application function code
*					; that has taken over the system to
*					; cause installation of other FG
*					; systems (notably ToolBox FGs)
*					; under program control and without
*					; causing the interface/switcher
*					; display bitmap to be rendered into.
*					; An FG getting one of these
*					; commands should behave exactly the
*					; same except for rendering the
*					; image change (they should still
*					; change the image pointer within the
*					; FG structure!) and waiting for user
*					; interaction. This was installed
*					; mostly for ToolBox FG sequencing
*					; and manipulating, and for handling
*					; external video sources outside of
*					; the control FGs.

*					; DOC NOTE: it is important to
*					; note that whenever an application
*					; routine is called by the interface/
*					; switcher code, it is in control on
*					; the whole game and can do whatever
*					; provided that it updates the
*					; ToasterBase before relinquishing
*					; control so that others know the
*					; state of the machine and that it
*					; is reflected on the interface
*					; display

*					; Addendum 8/23/89: All FastGadget
*					; function code routines should
*					; monitor the FGC_xxxx command type
*					; and NEVER make assumptions as to
*					; the FGC_xxxx command upon the
*					; function code being invoked and to
*					; be able to handle all cases

*	order of FGs and indexs IDs to the Main, Preview, and LumKey
*	output source control boolean FastGadgets:
*	please note that these are logical placements constants - they
*	do not represent hardware states or assignment of that source
*	in any way

S1INDEX		EQU	0		; input 1
S2INDEX		EQU	1		; input 2
S3INDEX		EQU	2		; input 3
S4INDEX		EQU	3		; input 4
SDV0INDEX	EQU	4		; DV 0 source
SDV1INDEX	EQU	5		; DV 1 source
SCLRINDEX	EQU	6		; encoder source (not used on LumKey)
SCOMPKEY	EQU	6		; computer keymask (LumKey only)
*						; Addendum 12/1/89:

* Order and indexes to Slice row FGs.

;;EFXSLICEID	EQU	0		; Effects slice
;;CGSLICEID	EQU	1		; CG slice
;;FSSLICEID	EQU	2		; Frame Store slice
;;SEQSLICEID	EQU	3		; Sequence and ToolBox editor slice
;;CFGSLICEID	EQU	4		; Configuration slice

* Addendum 11/20/89: The above Slice row FG IDs have been removed for Toaster
* product 1.0. The new "skinny" Slice row FGs IDs are now:

;;MTSLICEID	EQU	0		; Configuration slice
;;LTSLICEID	EQU	1		; LUT mode configuration slice
;;CGSLICEID	EQU	2		; CG slice

* Addendum 5/23/90: The new Slice row FG ID for Toaster product 1.5.

MTSLICEID	EQU	0		; Configuration slice
LTSLICEID	EQU	1		; LUT mode configuration slice
PTSLICEID	EQU	2		; Paint slice
CGSLICEID	EQU	3		; CG slice
TDSLICEID	EQU	4		; 3D and Modeler slice
AJSLICEID	EQU	5		; Hardware Setupt (Adjust) slice

* Order and indexes to the Grid Select row FGs.

GRIDAID		EQU	0		; ToolBox Grid A
GRIDBID		EQU	1		; ToolBox Grid B
GRIDCID		EQU	2		; ToolBox Grid C
GRIDDID		EQU	3		; ToolBox Grid D
GRIDEID		EQU	4		; ToolBox Grid E - Addendum 3/26/91:
GRIDFID		EQU	5		; ToolBox Grid F - Addendum 4/8/91:

GRIDGID		EQU	6		; ToolBox Grid G
GRIDHID		EQU	7		; ToolBox Grid H
GRIDIID		EQU	8		; ToolBox Grid I

GRIDMAXID	equ	GRIDIID

* Order and indexes to the Numeric Keypad FastGadget list.

NUMPADID	EQU	0		; current Numeric Keypad input
CGSELID		EQU	1		; CG slice FG as Numeric Keypad dest
TBSELID		EQU	2		; selected TBFG - Numeric Keypad dest
FLSELID		EQU	3		; Frame load FG - Numeric Keypad dest
FSSELID		EQU	4		; Frame save FG - Numeric Keypad dest
FCMNTID		EQU	5		; File comment string gadget/FG

* Order and indexes to the Transition FastGadget list.

AUTOID		EQU	0		; Auto transition
TAKEID		EQU	1		; swap Preview/Main
FRLVID		EQU	2		; freeze/live toggle

* Order and indexes to Clip FastGadget list.

CLIPAID		EQU	0		; clip A control
CLIPMODEID	EQU	1		; clip mode control

* Order and indexes to Frame Count FastGadget list.

FMCSLOWID	EQU	0		; Frame count - slow
FMCMEDID	EQU	1		; Frame count - medium
FMCFASTID	EQU	2		; Frame count - fast
FMCVARID	EQU	3		; Frame count - var

* Order and indexes to T-Bar FastGadget list.

TBARID		EQU	0		; T-Bar
TBEFXID		EQU	1		; EFX active LED - Addendum 12/11/89:

*+ Addendum 8/30/89: A new field has been added to the FastGadget structure,
*+ FG_IndexID, for indexing FastGadgets in a FastGadget list via a WORD
*+ value. This was primarily to address the issue of location assignment
*+ and the finding of FastGadgets via location assignment in a ToolBox
*+ FastGadget list. Using the FG_IndexID field for location assignment rather
*+ than a position index in the FastGadget list gives us 2 benefits: 1)
*+ Order does not have to be maintained in the FastGadget lists. 2) The
*+ FastGadgets list can be variable size and can have "holes" in the grid
*+ where no FastGadgets are located, and still be functional.

*+ The control FastGadgets are internal FastGadget structures, imagery and
*+ code. Internal FastGadgets will always have a NULL FG_LoadFlag field to
*+ signify that they are internal FastGadgets, and as such, they have not
*+ been loaded under the interface/switcher code from an external source.
*+ External FastGadgets will have a non-NULL FG_LoadFlag and are from an
*+ external source via a LoadSeg(). The first memory segment in the SegList
*+ must have the actual full initialized FastGadget structure at its start.
*+ Also the seglist must contain the FastGadget imagery and code, which
*+ must also be reflected in the initialized FastGadget structure loaded.
*+ To return the external FastGadget via UnLoadSeg(), take the pointer to
*+ the external FastGadget structure, subtract 4, form it into a BCPL
*+ pointer, and the use it as the argument to UnLoadSeg(). The toolbox
*+ FastGadgets will be external FastGadgets and under user control as to
*+ what effects FastGadget systems are in place in the toolbox matrix.

*+ Addendum 9/11/89: The ToolBox FastGadgets will no longer be totally
*+ external FastGadgets, they can be internal as well, as denoted by the
*+ FG_LoadFlag field of the FG structure. However in the case of the
*+ ToolBox FastGadgets (only!), internal does not mean part of the interface/
*+ switcher code and data segments, but rather that they were internally
*+ generated and when time comes to FGC_UNLOAD them, they will de-allocate
*+ themselves. Because they will de-allocate themselves as a result of the
*+ FGC_UNLOAD command (no other FastGadget type acts this way) you MUST
*+ obtain the links from the ToolBox FastGadget to be FGC_UNLOADed BEFORE you
*+ make the FGC_UNLOAD command since they cannot be depended on to be there
*+ after the FGC_UNLOAD command!
*+ Addendum to above Addendum - 11/23/89: There will be no internal ToolBox
*+ FastGadgets for Toaster version 1.0.

*+ Addendum 8/30/89: Previously to this date, the interface/switcher
*+ software did not issue FGC_LOAD and FGC_UNLOAD commands to internal
*+ FastGadgets. This was because it was niavely assumed that internal
*+ FastGadgets would have nothing to initialize and to close down. Now all
*+ FastGadgets in the system will be guaranteed to have an FGC_LOAD and an
*+ FGC_UNLOAD issued to them.

*+ It is possible to disable a FastGadget from being displayed by the
*+ FastGadget rendering functions by setting the FG_DispFlag of the
*+ FastGadget to non-NULL. Conversely, when the FG_DispFlag is NULL, it
*+ can and will be rendered by FastGadget rendering functions. Note: only
*+ direct FastGadget rendering functions such as DrawFastGList() pay
*+ attention to this flag, not the indirect FastGadget rendering functions
*+ that effect the BitMap area of the FastGadget such as CompFastGList()
*+ and ClearFastGList(). This is because this field was added primarily to
*+ support invisible gadgets, which can still, however, be selected. Be
*+ aware of the aforementioned side effects.

*+ A programmer can also disable a FastGadget from getting mouse attention
*+ from the MouseFastGList function by setting the FG_MouseFlag to non-NULL.

*	This is the SoftSprite VertBlankInfo control structure.

   STRUCTURE	VertBlankInfo,0		; info for SoftSprite VB server
*					; (longword align for 68020/30/40)
	APTR	VBI_Offset		; current offset into screen bitmap
*					; where background data was saved and
*					; where it will need to be replaced -
*					; will be -1 when there is no
*					; background area saved (used by
*					; SoftSpriteOff() to insure bitmap
*					; integrity before return to caller)
*					; (must set to -1 at startup)
	APTR	VBI_Screen		; pointer to screen - mouse position
*					; relative to screen and bitmap for
*					; rendering are found within screen
*					; structure
	WORD	VBI_MouseY		; current Y position
	WORD	VBI_MouseX		; current X position
*					; mouse coordinates are kept so that
*					; they can be compared with the
*					; mouse coordinates of the next VB
*					; interrupt, if they are the same,
*					; the SoftSprite will not be
*					; re-rendered - they can also
*					; invalidated by setting each to
*					; $7FFF to force the SoftSprite to be
*					; rendered
*					; (must set each at startup to $7FFF)
	WORD	VBI_OnOff		; SoftSprite On/Off switch
*					; 0 = SoftSprite enabled - non0 =
*					; SoftSprite disabled
*					; (must set to 0 at startup)
	WORD	VBI_Nest		; SoftSprite On/Off nest count of
*					; SoftSpriteOn() (increment nest
*					; count) and SoftSpriteOff()
*					; (decrement nest count) calls -
*					; SoftSprite is enabled when the nest
*					; count is at -1
*					; (must set to -1 at startup)
	WORD	VBI_Count		; counts 1/60 ticks - is used for
*					; forcing the SoftSprite to be
*					; rendered actively at only 1/15
*					; second rate - SoftSprite still
*					; responds to SoftSpriteOn() and
*					; SoftSpriteOff() in 1/60 second
	WORD	VBI_PointerHeight	; Current rendered pointer Height.
					; Heigth may be <32 if pointer is
					; at the bottom of the screen.
	LABEL	VBI_SIZ

*+ The VertBlankInfo structure contains information for managing a SoftSprite
*+ pointer and is not dependant on the interrupt method employed to run the
*+ SoftSprite handler code every 1/60 second. Currently the method used is
*+ using audio channels 0/1 to generate an interrupt every 1/60 of a second.
*+ To improve interrupt overhead and to make the audio channels available to
*+ the Toaster when it has taken over the AMIGA, 0/1 of the audio channels
*+ are allocated permantly via the Audio.device and the level 4 processor
*+ interrupt re-directed from Exec to our own interupt handler code. Later
*+ on when the program is shutting down, everything will be released and
*+ restored.

FRAMECOUNT	EQU	525		; sum of a long and a short frame
*					; making up an interlaced display
SAMPLEPERIOD	EQU	113		; sample period needed by an audio
*					; channel to insure a new sample is
*					; taken each scan line
VBEAMSYNCHMIN	EQU	10<<8		; minimum scan line we will allow an
*					; audio channel to be synchronized to
*					; (for internal use)
VBEAMSYNCHMAX	EQU	250<<8		; maximum scan line we will allow an
*					; audio channel to be synchronized to
*					; (for internal use)
VBEAMSYNCH	EQU	234		; default scan line we will
*					; synchronize an audio channel to
*					; (what we recommend)

*+ Addendum 9/27/89: Important note to those application code routines that
*+ take over the display copper lists in order to do your own custom work.
*+ The SoftSprite system is interrupt driven from audio channels 0/1
*+ done/reload. One of the first things the interrupt handler does is write
*+ to bplcon0 requesting 3 planes. This is because the SoftSprite system
*+ assumes that the 4 plane interface is showing and attempts to free up DMA
*+ time when past the end of the viewable display by performing the above
*+ trick. Therefore when doing work with your own copper lists, DO NOT assume
*+ that using SoftSpriteOff() will effect this write to bplcon0! You must
*+ disable the audio channels 0/1 interrupts in some manner.

*+?? Addendum 11/1/89: The SoftSprite now obtains the bplcon0 value to stuff
*+ from ToasterBase. Also if this value is found to be zero by the SoftSprite
*+ interrupt handler, the current bplcon0 value will remain in effect. A
*+ pair of ToasterBase library functions, SoftSpriteAudioOn/Off, has been
*+ provided to manage completely enabling/disabling the SoftSprite, interrupt
*+ and all. Also see the SoftSpriteBPLCON0On/Off functions.

*?? Addendum 11/16/89: The SoftSprite used to be driven from just audio
*+ channel 0 interrupts occuring every 1/60th of a second. This required that
*+ the SoftSprite audio interrupt handler toggle between 263/262 lines per
*+ frame depending on the frame flop bit and write this info into audio
*+ channel 0. Unfortunately this did not work well if audio interrupts were
*+ disabled while the audio DMA was allowed to continue, particularly if in
*+ interlaced mode. The scheme was nice in that the SoftSprite interrupt
*+ handler could manage either interlaced or non-interlaced displays. The
*+ Toaster system is now known to never operate outside of interlaced mode.
*+ With this in mind, a new system of generating audio interrupts was
*+ devised using both channels 0 and 1, each generating an interrupt at a
*+ certain video beam location every 1/30th of a second (525 lines), but
*+ interleaved so that an interrupt still occurs every 1/60th of a second for
*+ the SoftSprite. This scheme has an advantage of never needed re-synching
*+ as in the scenario mentioned earlier. It can only be used in interlaced
*+ mode.

*??	Addendum 10/25/89: Memory Management Additions:
*+ The following structure represents our meager attempts at memory
*+ management. SRK.

   STRUCTURE	MemoryBlockUse,0
	LONG	MBU_size		;# bytes in block
	WORD	MBU_type		;is it grabbable?
	WORD	MBU_UserID		;who is using the memory
	LABEL	MBU_SIZEOF

*?? Addendum 12/1/89: The size of a MemoryBlockUse chunk of CHIP memory MUST
*+ be of the size DISPLAYWIDTH*DISPLAYHEIGHT/8

*+ ToasterBase info:
*+ The ToasterBase is a psuedo library. It is not a true library in the
*+ AMIGA's definition of a library, but in its use by external programs and
*+ function code routines, it is very much like a library. The ToasterBase
*+ is part of the interface/switcher code program and is initialized and
*+ closed down exclusively by the interface/switcher code. At positive
*+ offets to ToasterBase are data items and structures that represent the
*+ current state of the Video Toaster hardware, the interface/switcher code,
*+ and other separate code entities that may be linked into the interface/
*+ switcher code system via the FastGadgets. For code entities that are
*+ tied into the interface/switcher code via the FastGadgets, the address of
*+ the ToasterBase will always be passed as an argument to the function code
*+ routine. For those code entities that are totally external to the
*+ interface/switcher code system, the ToasterBase can be found by searching
*+ the Exec library list for a node name of "ToasterBase". At negative
*+ offsets to ToasterBase are 6 byte jump vectors to the library functions
*+ that are available. ToasterBase function calling conventions are very
*+ similar to those used for normal AMIGA libraries, the function vectors
*+ are referenced as a negative offset from the ToasterBase address in A5
*+ (not A6 as in AMIGA libraries).

*== At base of ToasterBase is a standard Exec link node.

   STRUCTURE	__ToasterBase,LIB_SIZE	; A library structure: string
*					; name should be "ToasterBase" for
*					; dynamic lookup and can be found in
*					; the Exec library list. For those
*					; who expect to be linked in with
*					; the interface/switcher code, the
*					; external name for the ToasterBase
*					; structure is "_ToasterBase" and is
*					; to be defined within interface/
*					; switcher code module
*					; ToasterBase structure should be
*					; zeroed out at startup except
*					; where noted (for the most part)
*					; (longword align for 68020/30/40)
	WORD	TB_InList		; after the ToasterBase structure has
*					; been added to the Exec library list
*					; - this flag will be set to non-0
*					; to denote that ToasterBase is now
*					; linked in (really only of use
*					; internally to the interface/
*					; switcher code)

*== Libraries opened and available that can be used in support code.

	APTR	TB_SYSBase		; pointer to ExecBase
	APTR	TB_GFXBase		; pointer to GfxBase
	APTR	TB_ITUBase		; pointer to IntuitionBase
	APTR	TB_DOSBase		; pointer to DOSBase

	STRUCT	TB_LibList,MLH_SIZE	; list anchor to list of private
*					; libraries opened and used by
*					; external application code routines
*					; see the functions OpenAuxLib(),
*					; CloseAuxLib(), and RemoveAuxLib()

*== SoftSprite and interrupt support.

	APTR	TB_VBR			; address contained in Vector Base
*					; register on AMIGAs with later than
*					; a 68000 processor - always 0 for
*					; 68000 based AMIGAs - this is where
*					; the system supplied vector table
*					; will be located - a little
*					; redundant with the field described
*					; below, but could be useful if you
*					; wish to monkey with the VBR reg
	APTR	TB_Int4Vector		; Exec interrupt 4 vector displaced
*					; (currently using audio channel 0/1)
	APTR	TB_Int4Address		; address of interrupt 4 autovector -
*					; is always $70 on 68000 AMIGAs, but
*					; may be relocated off of the vector
*					; base register of later 680X0
*					; processors in a future AMIGA OS
*					; (1.4?)
*					; (note: the 3 above fields are
*					; actually setup by the
*					; OpenSoftSprite() function - called
*					; internally by the interface/
*					; switcher initialization code)
	STRUCT	TB_SoftSprite,VBI_SIZ	; VertBlankInfo structure for
*					; managing the SoftSprite - contains
*					; VBI_Screen (from this you can get
*					; many other graphics item you may
*					; need) - certain fields in this
*					; structure need to be initialized
*					; to certain values mentioned above
*					; before call to OpenSoftSprite()

*== Video Toaster interface/switcher display window/Intuition baggage
*== and support.

	APTR	TB_Screen		; pointer to custom screen the
*					; interface/switcher display
*					; resides in
	APTR	TB_Window		; pointer to window the interface/
*					; switcher display resides in - it
*					; covers the entire display and is
*					; borderless - if you link into the
*					; FastGadget system of the interface/
*					; switcher display - you must assume
*					; that you are to be placed in this
*					; window with no requesters
	APTR	TB_BitMap		; pointer to the BitMap of the above
*					; interface/switcher display screen
	APTR	TB_RastPort		; pointer to the interface/switcher's
*					; display window rastport
	APTR	TB_MsgPort		; pointer to the interface/switcher's
*					; display window user IDCMP port
	APTR	TB_Font			; Addendum 10/26/89: this is the font
*					; active for the interface/switcher
*					; display - if NULL - the system
*					; default will be used
	WORD	TB_CleanUp		; this is a flag which when set to
*					; non-zero by application code will
*					; denote to the interface/switcher
*					; code that the above display memory
*					; mentioned has been trashed by the
*					; application and that the display
*					; must be totally refreshed via the
*					; ReDoDisplay library call - if zero
*					; the interface/switcher code
*					; will attempt to update the
*					; interface display selectively via
*					; the UpdateDisplay library call -
*					; please use the methods of selective
*					; updating of those FG systems that
*					; support it and avoid causing a
*					; total interface/switcher screen
*					; display if possible
	WORD	TB_ErrFlag		; added 8/28/89: this field is only
*					; pertinent when an entity has been
*					; loaded and is called with an
*					; FGC_LOAD command - your code should
*					; check the value of this flag field
*					; after control returns to you from
*					; the code entity you issued an
*					; FGC_LOAD command to. If this field
*					; is clear - then all went OK, if
*					; non-zero - an error occured. You
*					; should propagate this flag back to
*					; your caller (if you were called)
*					; Addendum 9/12/89: The TB_ErrFlag is
*					; also used in the same way with the
*					; special FGC_GENFG command. This
*					; system was included to handle the
*					; generation of internal ToolBox
*					; FastGadgets
					; As of 1-13-94 many FG commands may
					; use this field for error returns.

	WORD	TB_BGColor		; background pen (not color!) chosen
*					; for the interface/switcher display
	WORD	TB_ButtonFlag		; Addendum 12/6/89:
*					; this field denotes which button,
*					; left or right, is being held down
*					; while adjusting one of the Switcher
*					; slider type FGs
*					; 0    - denotes left button active
*					; non0 - denotes right button active

*== Video Toaster system memory allocations and management support.

	LONG	TB_CHIPMemSIZE		; size of the single CHIP memory
*					; chunk that we will obtain by
*					; by AllocMem()
*					; NOTE: in order to maximize the
*					; size of CHIP memory -
*					; the interface/switcher code will
*					; attempt to close down the WB
*					; screen at program startup
*					; - it will attempt to re-open the
*					; WB screen when it is shutting down

*					; this is the default total CHIP
*					; memory size that we will need
*					; and the size of a single bitplane

*TB_CHIPMEMSIZE	EQU	DISPLAYWIDTH*DISPLAYHEIGHT	; MUST be at least
*							; enought for
*							; 8 bitplanes
TB_CHIPMEMSIZE	EQU	560000		;2-12-93 was 376000 pre 3.0
TB_CHIPMEMBLOCKSIZE	EQU	DISPLAYWIDTH*DISPLAYHEIGHT/8

	STRUCT	TB_CHIPMem,8*4		; this is a set of pointers to the
*					; 8 individual CHIP bitplanes the
*					; single CHIP chunk is divided into -
*					; the pointers in this list address
*					; consecutive bitplanes in memory
*					; starting from the low memory start
*					; of the CHIP chunk - map of CHIP is:
*					; the low 2 (was 4) bitplanes are the
*					; planes always used by the interface/
*					; switcher display when it is active,
*					; the other 6 high bitplanes can be
*					; used by application code
*					; whenever it has taken over the
*					; display and machine resources for
*					; its own purposes
*					; These pointer will be DOUBLE LONG
*					; WORD Aligned!

	STRUCT	TB_CHIPMemUsage,8*MBU_SIZEOF
*					; this is a set of ID structs - one
*					; for each CHIP memory bitplane that
*					; allows for crude memory management
*					; between application code routines
*					; that have a common convention for
*					; using it - just remember that the
*					; interface/switcher will always
*					; discard the contents of its
*					; bitplanes with its own stuff if
*					; TB_CleanUp is set (when it gets
*					; control again)

*??					; Addendum 12/1/89:
*					; The total CHIP chunk size is now
*					; greater than the 8 bitplanes is
*					; was originally designed to support
*					; - however the only entity that
*					; should take advantage of this extra
*					; memory past the last plane pointer
*					; and memory management structures
*					; is the CG

	LONG	TB_FASTMemSIZE		; the size of the single FAST memory
*					; chunk that we will obtain via
*					; AllocMem()

*					; this is the default total FAST
*					; memory size that we will need
*					; and a divide by 8 sliver size

TB_FASTMEMSIZE		EQU	504000  ;5-27-93 old value was 144K	;12/3/91 old value was 576000
TB_FASTMEMBLOCKSIZE	EQU	((TB_FASTMEMSIZE)/8)

	STRUCT	TB_FASTMem,8*4		; this is a list of pointer to the
*					; single FAST memory chunk that will
*					; also be divided 8 ways as was the
*					; above CHIP memory

	STRUCT	TB_FASTMemUsage,8*MBU_SIZEOF
*					; this is a set of ID structs - one
*					; for each of 8 segments that the
*					; single FAST memory chunk will be
*					; divided into - this allows for
*					; crude memory management as
*					; explained for TB_CHIPMemUsage -
*					; the interface/switcher code never
*					; uses this memory
*??					; Addendum 10/25/89:
*??					; added FAST memory system

*??					; Addendum 12/1/89:
*					; added code that hamstrings the
*					; system on a 1 meg system by not
*					; allowing the CG slice to appear
*					; (which prevents the CG from being
*					; loaded) and only allocating a 180K
*					; FAST memory chunk - this allows the
*					; Toaster system to function
*					; somewhat on a 1 meg AMIGA - the CG
*					; will be allowed to run on larger
*					; machines and will take care of its
*					; own FAST memory needs rather than
*					; disturb the FAST memory allocated
*					; above (used primarily by the
*					; effects system)

*??					; Addendum 7/19/90:
*					; No longer hamstringing the system
*					; since the CG, among other slices,
*					; can configured out of the Toaster
*					; system via Project load info.
*					; No longer allocating 180K. Look at
*					; what is in TB_FastMemSIZE.

*== External/Separate process application code systems support.

	APTR	TB_TBMsgPort		; added 8/28/89: this ToasterBase
*!!!					; private message port and following
*					; special message pointer fields are
*					; for synchronous communication
*					; between code entities of the
*					; Toaster system only. It is provided
*					; mostly to allow the use of HLL
*					; FastGadget systems that need
*					; to startup as a separate process
*					; to exist within the framework
*					; calling protocol of the Toaster
*					; system. As noted before, convention
*					; requires that only one code entity,
*					; be it called code or a separate
*					; process sent a message to perform
*					; an action, can be running at a
*					; given moment. This is due to the
*					; fact that the ToasterBase is a
*					; shared global structure. The
*					; TB_TBMsgPort field contains a
*					; pointer to a public port which can
*					; also be found in the system's
*					; port list under the name
*					; "ToasterSwitcher.port"
	APTR	TB_TBMsg		; this field contains a pointer to
*					; the single Toaster message. We
*					; only need this one considering
*					; that only one entity can be running
*					; at a time. It is a message
*					; structure with three additional
*					: LONG fields appended. The third
*					; LONG field will hold a pointer
*					; to ToasterBase. The second LONG
*					; field will hold a pointer to the
*					; FastGadget structure involved.
*					; The first LONG field will
*					; hold the FGC_xxxx command issued.
*					; The use of the message should be
*					; that the ToasterBase pointer field
*					; is READ-ONLY, and will be
*					; initialized when this message is
*					; created
*					; Addendum 1/15/90: now has 4
*					; longword fields with
*					; TBM_UserData

*== File buffer and general purpose scratch area support.

	APTR	TB_FileBuff		; this is a pointer to a 4K DOS
*					; file buffer area - usages include
*					; reading from and writing to disk
*					; ToolBox projects, and application
*					; function code if they wish to use
*					; DOS services and need a file buffer
*					; DOC NOTE 9/12/89: This field was
*					; added - also in regards to DOS
*					; fileIO usage, remember that DOS
*					; requsters have been disabled under
*					; the ToasterBase system

*== FastGadget system lists.

	APTR	TB_ToolBoxPTR		; *special*: it is not a FastGadget
*					; list anchor but instead points to
*					; the ToolBox FastGadget list anchor
*					; that is currently active grid
	APTR	TB_SliceFGL		; the Slice row
	APTR	TB_LumKeyFGL		; the LumKey row
	APTR	TB_MainFGL		; the Main row
	APTR	TB_PrvwFGL		; the Preview row
	APTR	TB_GridSelFGL		; the ToolBox grid select row
	APTR	TB_TransFGL		; contains the Take and Auto FGs -
*					; first is Auto followed by Take
	APTR	TB_TBarFGL		; first FG in list is the actual
*					; TBar FG
	APTR	TB_FMCountFGL		; first FG in list is the actual
*					; Frame Count input FG
	APTR	TB_NumPadFGL		; first FG in list is the actual
*					; Numeric Pad input FG - the next
*					; three are support input FGs -
*					; (CG dest, FS dest, and TB dest) -
*					; then there is a special string
*					; gadget/FG for a file comment
	APTR	TB_ClipFGL		; first FG in list is the actual
*					; Clip A FG - the second is the
*					; Clip B FG
	APTR	TB_MiscFGL		; this is a list of afterthought
*					; FastGadget systems that are not
*					; directly supporting the interface/
*					; switcher program (such as a close
*					; FastGadget etc.)
*					; probably will not be used)
*					; Addendum 10/18/89:

*					; Addendum 9/12/89: the following
*					; fields represent all of the ToolBox
*					; FastGadget lists - only one of
*					; which can actually be displayed
*					; and receive input - PLEASE NOTE!! -
*					; if you make changes to any
*					; of the below lists - and a change
*					; causes a need for a new list to be
*					; displayed, then place the pointer
*					; the ToolBox FastGadget list base
*					; in the TB_ToolBoxPTR field.
*					; REMEMBER THIS...

*					; Addendum 10/11/89: all of the
*					; above FastGadget list have
*					; strict ordering of the FG members -
*					; sequence as well as IndexID EXCEPT
*					; for the ToolBox FG list - most of
*					; them have a strict length as well

*					; The following pointer fields must
*					; be consecutive and in order to
*					; maintain the order of the ToolBox
*					; FastGadgets and their IndexID
*					; values. FastGadgets and
*					; their IndexID values should be
*					; maintained in the ToolBox
*					; FastGadget list that they belong
*					; in. Also the number of consecutive
*					; ToolBox FastGadget pointers must
*					; match the constant of TBFG_GRIDNUM,
*					; which is depended on be a number of
*					; library functions that manipulate
*					; the ToolBox FastGadget lists.
 ifeq 1

	APTR	TB_ToolBox1FGL
	APTR	TB_ToolBox2FGL
	APTR	TB_ToolBox3FGL
	APTR	TB_ToolBox4FGL

	APTR	TB_ToolBox5FGL		; Addendum 3/26/91:
	APTR	TB_ToolBox6FGL
	APTR	TB_ToolBox7FGL
	APTR	TB_ToolBox8FGL
 endc

	APTR	TB_ToolBoxGrids
	LONG	TB_NUMGRIDS
	STRUCT	TB_pad0,(6*4)	;Were at one time used


*					; Addendum 10/6/89: All of the FG
*					; lists anchor fields listed above
*					; can be NULL and be supported under
*					; the Toaster system (no crashes) -
*					; some FGLs are of known length and
*					; where the pertinent FGs within them
*					; are - these include TB_TBarFGL,
*					; TB_FMCountFGL, TB_NumPadFGL, and
*					; TB_ClipFGL - in these FGLs - the
*					; library call ReDoDisplay will
*					; render the FGs (if any) past the
*					; pertinent FGs in the list before
*					; ANYTHING else is rendered from the
*					; FastGadgets - rendering order is
*					; the same as specified in the field
*					; list earlier - this allows for the
*					; creation of backdrops, etc. Also
*					; note that since the interface/
*					; switcher knows and assumes the
*					; length of these FG lists - it will
*					; not allow the select via mouse of
*					; any of the FastGadgets past the
*					; pertinent FG(s) in the front of the
*					; FastGadget list

*					; Addendum 10/11/89: concerning the
*					; FG list extensions for background
*					; display just above - those
*					; FastGadgets in the extension are
*					; should have their FG_MouseFlag set
*					; to non-NULL and their FG_Function
*					; fields set to NULL so that they
*					; can never be accidently invoked
*					; for any reason

*== Active ToolBox FastGadget support.

	APTR	TB_EfxFG		; pointer to FastGadget structure
*					; representing the effect that is
*					; currently selected and active in
*					; the ToolBox FastGadget grid - NULL
*					; if no FastGadget structure has been
*					; selected
					
					; At the begining of a FGC_SELECTx
					; cmd this points to the current, soon
					; to be previous effect.  TB_EfxFG is
					; updated, just before a FGC_REMOVE
					; is sent out by DoHiLiteSelectx
					; During a FGC_REMOVEx cmd, TB_EfxFG
					; points to the soon to be new FG.

*== State of interface/switcher support.

	WORD	TB_ToastActive		; flag denoting operational status
*					; of the Toaster - if non-0 the
*					; Toaster is open and active in the
*					; AMIGA - if it is 0 the Toaster the
*					; Toaster is closed and inactive
*					; in the AMIGA (mostly pertinemt and
*					; maintained by the interface/
*					; switcher code)

*== RAWKEY support.
*??					; Addendum 10/7/89:

	WORD	TB_KeyCode		; copy of im_Code field of RAWKEY
*					; class gathered by the interface/
*					; switcher and broadcast to the
*					; apprpriate FG destination via an
*					; FGC_SELECTK command
	WORD	TB_QualCode		; copy of im_Qualifier field of
*					; same RAWKEY class message as
*					; the field just above

*== FGC_NUMVAL support.

	WORD	TB_Number		; value usually created by the
*					; numeric FastGadget, but can be
*					; filled in by other sources and is
*					; always the pertinent value to the
*					; application function code when
*					; called via FGC_NUMVAL command -
*					; used for such things as denoting
*					; page numbers to CG or frame store,
*					; or ToolBox FastGadget select.
*??					; Addendum 10/3/89

*== Main row support.
*??					; Addendum 10/7/89:

	APTR	TB_MainSelFG		; this field is only valid when
*					; the main input is a source other
*					; than what could be available on the
*					; button row

	WORD	TB_MainPri		; these fields are for allowing
	WORD	TB_MainSec		; other FG systems to change the
*					; display of the main row buttons
*					; to reflect *hopefully* the Toaster
*					; hardware state and have the
*					; interface/switcher refresh the
*					; display accordingly upon its
*					; re-activation - the xxxPri field
*					; is private to the interface/
*					; switcher controlling the display
*					; and the xxxSec field is
*					; for all FG systems to modify
*					; to represent the new state they
*					; want displayed - the interface/
*					; switcher code upon regaining
*					; control from a dispatched FG
*					; system will check for a difference
*					; between the xxxPri and xxxSec
*					; fields, if a difference is noted -
*					; then an FGC_UPDATE is issued to
*					; the pertinent controlling FG
*					; system to update its imagery - the
*					; interface/switcher code will then
*					; redisplay the changed FGs -
*					; with this pair of control word,
*					; each FG in the main row is
*					; represented as a bit in the control
*					; words in the position denoted by
*					; its FG_IndexID - bit as 1 denotes
*					; that the particular FG on the row
*					; should be highlighted - bit as 0
*					; denotes that the particular FG on
*					; the row should be de-highlighted

*					; Addendum 11/2/89: The TB_xxxPri
*					; fields are not so private to the
*					; interface/switcher. Any system can
*					; use them (carefully!!) to insure
*					; the interface/switcher display
*					; routines of UpdateDisplay() and
*					; ReDoDisplay() behave in a desired
*					; fashion

*== Preview row support.
*??					; Addendum 10/7/89:

	APTR	TB_PrvwSelFG		; this field is only valid when
*					; the preview input is a source other
*					; than what could be available on the
*					; button row

	WORD	TB_PrvwPri		; see the equivalents on the main row
	WORD	TB_PrvwSec		; - these are identical for preview

*== LumKey row (DAC A) and DV LumKey (DAC B) support.
*??					; Addendum 10/7/89:

	APTR	TB_LumKeyASelFG		; this field is only valid when
*					; the LumKeyA input is a source other
*					; than what could be available on the
*					; button row

* *Only* source for DAC B is the DV input select.

	LABEL	TB_OLayPri
	WORD	TB_LumKeyAPri		; see the equivalents on the main row
	LABEL	TB_OLaySec
	WORD	TB_LumKeyASec		; - these are identical for LumKey

* A clip level of 0   = keying turned off = Foreground video
* A clip level of 257 = keying turned off = Background video

ClipAMax	EQU	257

	WORD	TB_ClipAPri		; this is the clip level for DAC A
	WORD	TB_ClipASec		; (range of 0 to 257)

	WORD	TB_ClipBPri		; this is the clip level for DAC B
	WORD	TB_ClipBSec		; (range of 0 to 257)

	WORD	TB_KeyModePri		; WORD is <0 if KeyEnabled
	WORD	TB_KeyModeSec		; LSBYTE is <0 if KeyOnBlack

B_KeyEnable	EQU	15

M_KeyEnable	EQU	(1<<B_KeyEnable)
M_KeyOnBlack	EQU	(-1)
M_KeyOnWhite	EQU	1
M_KeyOnGray	EQU	0	;for dual threshold key ??

	WORD	TB_UserOn		;0 if 3 monitors, -1, if 2 monitors

* anytime TB_...Sec is changed with a new Analog value (or BKG), TB_....Save
* will also be updated.  These save values are used when ever the user goes
* to LIVE DVE after showing a frozen DVE bank.
	WORD	TB_OLaySave
	WORD	TB_MainSave		
	WORD	TB_PrvwSave

* anytime TB_...Sec is changed to a new Frozen value, TB_....Froze will
* also be updated.  These save values are used when ever the user goes to
* Frozen DVE after showing a LIVE DVE bank.
	WORD	TB_OLayFroze
	WORD	TB_MainFroze		
	WORD	TB_PrvwFroze

*					; Addendum 10/29/89: The above clip
*					; level fields must be consective and
*					; matchup with the IndexIDs of their
*					; pertinent FG systems in order for
*					; the Clip handler code to work!
*					; Addendum 1/5/90: The remark just
*					; above is no longer true as only
*					; clip A is accessable from the
*					; Switcher interface - however we
*					; will still leave it this way in
*					; case we should ever need it

* Addendum 11/2/89: The following definitions are mostly for internal use by
* the Main, Preview, and LumKey systems, they are derived from the Pri/Sec
* field values. Although they are symbolically defined, don't let that fool
* ya. The Main/Preview/Lumkey systems and the library functions of
* MaskToIndex() and IndexToMask() depend heavily on peculiarities of their
* value - so beware...

* Addendum 12/14/89: The Pri and Sec fields are now a little different for
* the Main, Preview, and LumKey rows - the lower byte of the word only is now
* used by the Switcher for button state info - the upper byte contains
* modifiers to describe what can not presently be shown on the buttons rows.

I_EXTER		EQU	0		; (LumKey only - I_MONO Main/Preview)
I_MONO		EQU	0		; Index values - these values
I_ENCODER	EQU	1		; represent not only the direct
I_VIDEO1	EQU	2		; hardware setup of an A/B channel,
I_VIDEO2	EQU	3		; but also what can be shown on the
I_VIDEO3	EQU	4		; button row which can include some
I_VIDEO4	EQU	5		; modifiers from the DV channels.
I_DV0		EQU	6		; These internal values can be
I_DV1		EQU	7		; massaged as needed and then
I_DVE_EXTER	EQU	8		; translated into the needed mask to
I_DVE_ENCODER	EQU	9		; cause the button row to be lit up
I_DVE_VIDEO1	EQU	10		; as needed
I_DVE_VIDEO2	EQU	11
I_DVE_VIDEO3	EQU	12
I_DVE_VIDEO4	EQU	13

B_VIDEO1	EQU	0		; --+
B_VIDEO2	EQU	1		;   |
B_VIDEO3	EQU	2		;   |
B_VIDEO4	EQU	3		;   | Can be shown on the Button rows
B_DV0		EQU	4		;   |
B_DV1		EQU	5		;   |
B_ENCODER	EQU	6		; --+
B_MONO		EQU	8		; --+
B_MAIN		EQU	9		;   | private modifier - can't be
B_EXTER		EQU	10		; --+ represented on the Button rows

M_VIDEO1	EQU	(1<<B_VIDEO1)
M_VIDEO2	EQU	(1<<B_VIDEO2)
M_VIDEO3	EQU	(1<<B_VIDEO3)
M_VIDEO4	EQU	(1<<B_VIDEO4)
M_DV0		EQU	(1<<B_DV0)
M_DV1		EQU	(1<<B_DV1)
M_ENCODER	EQU	(1<<B_ENCODER)
M_MONO		EQU	(1<<B_MONO)
M_MAIN		EQU	(1<<B_MAIN)
M_EXTER		EQU	(1<<B_EXTER)

M_VIDEO		EQU	(M_VIDEO4!M_VIDEO3!M_VIDEO2!M_VIDEO1)
M_DVE		EQU	(M_DV1!M_DV0)

M_DVE_VIDEO1	EQU	(M_DVE!M_VIDEO1)
M_DVE_VIDEO2	EQU	(M_DVE!M_VIDEO2)
M_DVE_VIDEO3	EQU	(M_DVE!M_VIDEO3)
M_DVE_VIDEO4	EQU	(M_DVE!M_VIDEO4)
M_DVE_MAIN	EQU	(M_DVE!M_MAIN)
M_DVE_EXTER	EQU	(M_DVE!M_EXTER)
M_DVE_ENCODER	EQU	(M_DVE!M_ENCODER)
M_DVE_MONO	EQU	(M_DVE!M_MONO)

*== DV support.
*??					; Addendum 10/18/89:

* Documentation note: DV channels can only be assigned in 3 ways:
* 1) DV can be assigned automatically to live video or still video by an
*    effects transition.
* 2) DV can be assigned by external FastGadget applications such as CG,
*    Frame store, Paint, etc.
* 3) DV can be assigned to an analog camera source on the Main row only,
*    and then only if the video state denotes live video active.

	APTR	TB_DV0SelFG		; these are pointer fields to the
	APTR	TB_DV1SelFG		; external DV source FG. Valid
*					; only when the corresponding
*					; TB_DVxInput field is not a value
*					; of an analog camera source -
*					; in the case of an external live
*					; video source, both of these fields
*					; should be set to the same external
*					; FG. Both should also be cleared at
*					; the same time

*== TBar support.
*??					; Addendum 10/7/89:
*??					; Addendum 5/5/90: added 512 as new
*??					; resolution to TBar movement

TValMin	EQU	0
TValMax	EQU	511

	WORD	TB_TValPri		; this is the TBar slider value
	WORD	TB_TValSec		; (range 0-511)

*					; Addendum 11/2/89: Additional info -
*					; the above values will also be used
*					; to toggle the Main/Preview
*					; channels, reset the TBar to 0, and
*					; assure that the Toaster A and B
*					; channels are the same when
*					; reaching 511 by the UpdateDisplay()
*					; and ReDoDisplay() functions -
*					; the code for the sequencer control
*					; code also performs this service
*					; upon return of control from a
*					; crouton

*== Frame count support.
*??					; Addendum 10/7/89:

* On non-ANIM FX this is the number of fields an FX will use.
* On ANIM FX, it is the number of fields per displayed bitmap.

* BEFORE 1-13-94 the was true ......
* On some ANIM FX, the upper byte will indicate the speed to use for
* 68000 based machines.  If this byte is zero, use the lower byte.
* NOW TB_FCountPri/Sec are always correct for the given CPU

	WORD	TB_FCountPri		; this is the frame count value
	WORD	TB_FCountSec		; (range 0-9999)

* BEFORE 1-13-94 Upper 14 bits of TB_FCountModePri/Sec = variable speed setting
* NOW only low two bits have any meaning.

	WORD	TB_FCountModePri	; this denotes frame count row
	WORD	TB_FCountModeSec	; button state

					; Lower 2 bits
*					;  0 for medium
*					;  1 for fast
					;  2 for variable
					;  3 for slow

FCountMode_Variable EQU 2
FCountMode_Fast     EQU 1
FCountMode_Medium   EQU 0
FCountMode_Slow     EQU 3

*					; Addendum 2/2/90:
*					; also note that the Switcher update
*					; system previously used TB_FCountPri
*					; and TB_FCountSec - they are now
*					; bogus for that system, but
*					; TB_FCountPri is still used by the
*					; effects system to hold the real
*					; frame count. TB_FCountSec is bogus.

					; As of 1-13-94 TB_FCountSec/Pri are
					; once again both used in the update
					; system.	

					; As of 5-6-93 only the low order two
					; bits should be looked at for mode.
					; 3=slow, 0=med, 1=fast, 2=variable
					; If the upper 14 bits are all 0s or 1s
					; the effect doesn't support variable
					; duration. Else, the upper 14 bits are
					; the current variable duration.

*== Numeric FastGadget support.
*??					; Addendum 10/10/89:

	APTR	TB_FGTarget		; FG system to be enlightened with
*					; an FGC_NUMVAL command as a result
*					; of numeric input dispatched by the
*					; user - points either to the
*					; appropriate slice FG (CG only in
*					; V1.0), a pointer to the same
*					; FG as in the TB_CurrSelFG which
*					; must be able to handle the
*					; FGC_NUMVAL command properly, or
*					; finally NULL
	APTR	TB_CurrSelFG		; the Numeric keypad select FG
*					; currently in effect - NULL if none
*					; Addendum 10/24/89: field added.
	WORD	TB_NumPadPri		; the current NumPad value
	WORD	TB_NumPadSec		; (range 0-999)
	APTR	TB_FCString		; pointer to the file comment string
*					; buffer - which can hold up to 13
*					; characters, including the
*					; terminating NULL
*					; (Addendum 11/20/89:)
	APTR	TB_FCStringSec		; Addendum 3/2/90: file comment
*					; string now part of the Switcher
*					; update system

*??					; Addendum 10/25/89: Numpad string
*					; FastGadget tidbits: The Numpad
*					; string FastGadget (for file
*					; comments) is unusual in that in
*					; within the system, intuition is
*					; actually allowed to render into
*					; the display using a standard
*					; string gadget - which is part of
*					; the string FastGadget structure

*====	Freeze/Live toggle support.
*??					; Addendum 11/27/89:

	WORD	TB_VideoFlagPri		; these word fields describe the
	WORD	TB_VideoFlagSec		; current video state of the Video
*					; Toaster - 0 denotes LIVE video
*					; currently enabled - 1 (or non-0)
*					; denotes FROZEN video currently
*					; enabled
*					; these flags affect how the the USER
*					; selection on the LumKey, Main, and
*					; Preview rows is to be performed.
*					; Also the info is available and
*					; these flags can be set from Toolbox
*					; FastGadgets
*					; currently the freeze/live FG lives
*					; in the TransFGL FastGadget list

*====	Computer generated key mask support.
*??					; Addendum 12/1/89:

	WORD	TB_KeyGenPri		; these word fields describe the
	WORD	TB_KeyGenSec		; current video state of the Video
*					; Toaster - 0 denotes normal mode
*					; where keymask come only from within
*					; the Toaster system or from video
*					; sources. Non-0 denotes that a
*					; keymask is being generated by the
*					; AMIGA.
*					; these word states are not
*					; accessable by the user - only
*					; enabled/disabled under FG systems
*					; hosted by the switcher

*====	Miscellaneous control fields.

	WORD	TB_IFaceCon		; this field conveys to ToolBox
*					; Grid FastGadget systems on the
*					; status they should maintain in
*					; regards to user interface/switcher
*					; display:
*					; -1 - keep display up during effect
*					; 0  - no display or display restore
*					; 1  - restore display when done
*					; Addendum 10/30/89: added field
*					; (not used in V1.0)

	WORD	TB_BPLCON0		; this is the current bltcon0 value
*					; to be used by the SoftSprite
*					; interrupt handler - NOTE: if this
*					; field is 0 then it will not be
*					; loaded into BPLCON0 by the
*					; SoftSprite interrupt handler!!
*					; Addendum 10/30/89: added field

	WORD	TB_BPLCON0Nest		; nest count of SoftSpriteBPLCON0On/
*					; Off calls - at -1 the TB_BPLCON0
*					; field is used by the SoftSprite
*					; interrupt handler - NOTE: when
*					; disengaging/engaging the BPLCON0,
*					; SoftSpriteOff/On will also be
*					; invoked respectively - when nest
*					; count is not -1, a minimul
*					; interrupt handler will have been
*					; installed instead of the main
*					; SoftSprite interrupt handler
*					; Addendum 10/30/89: added field

	WORD	TB_AudioNest		; nest count of SoftSpriteAudioOn/
*					; Off calls - at -1 the SoftSprite
*					; interrupt handler is allowed to
*					; function - NOTE: when disengaging/
*					; engaging the audio interrupts and
*					; DMA, the SoftSpriteOff/On will also
*					; be invoked respectively
*					; Addendum 10/30/89: added field

	WORD	TB_ToastBGC		; current color index/value for the
*					; Toaster background (matte) color
*					; Format:
*					; Bits 0-3   - MP value
*					; Bits 4-7   - MB value
*					; Bits 8-11  - MA value
*					; Bit  12    - not used - set to 0
*					; Bit  13    - MATT_CHANGE_FLAG	
*					; Bits 14    - MATT_LOCK_FLAG
					; Bit  15    - 1 if snow
*					; Addendum 12/18/89:

	WORD	TB_BorderC		; current color index/value for the
*					; Effects border color (0-7)
*					; Addendum 12/18/89:

	WORD	TB_InputTerm		; current setting of what video
*					; inputs are terminated - the
*					; settings are reflected in a bit
*					; mask where 1 denotes the
*					; corresponding video input is
*					; terminated - 0 for not. Bit
*					; positions are as follows:
*					; BIT 3 -> Video 1 input
*					; BIT 2 -> Video 2 input
*					; BIT 1 -> Video 3 input
*					; BIT 0 -> Video 4 input
*					; Addendum 1/10/90:

	WORD	TB_FloppyAlloc		; Floppy disk drive units available -
*					; units 0-3 denoted as bits 0-3 in
*					; this flag field. 1 denotes the
*					; particular unit is available - 0
*					; denotes that the particular unit
*					; is not available.
*					; Addendum 2/14/90:

	APTR	TB_BorderPalette	; pointer to a 8 longword palette
*					; table for border colors indexed by
*					; the value in TB_BorderC
*					; Addendum 1/30/90: not implemented
*					; Addendum 2/6/90: implemented

*====	Toaster AmigaDOS file system environment control fields.
*====	Addendum 1/14/90:

	APTR	TB_BootLock		; pointer to the file lock
*					; representing the Toaster/Switcher
*					; ROOT
	APTR	TB_ProjDev		; pointer to the device pathname for
*					; storing and retrieving projects
	APTR	TB_FSDev		; pointer to the device pathname for
*					; storing and retrieving frame stores

*					; the above pointers to device
*					; pathnames actually point to a
*					; complete uppercase device name
*					; which is a hybrid of BSTR and C
*					; strings. At the beginning of the
*					; string is a byte count of the
*					; device name which DOES NOT include
*					; the terminating NULL byte

	WORD	TB_CurrentPJNumber	; current project number in effect
*					; or -1 if default project
*					; Addendum 2/26/90:
	WORD	TB_InterfaceOn		; this when non-0 denotes that the
*					; user interface is present for the
*					; error message display system
*					; Addendum 3/13/90:

	APTR	TB_ProjStrings		; pointer to file comment strings
*					; for projects
	APTR	TB_FSStrings		; pointer to file comment strings
*					; for frame stores
	LONG	TB_LastGlobalError	; used by many of the Toaster DOS
*					; system functions to return a more
*					; revealing secondary info code to
*					; the caller in addition to the
*					; standard error code passed back
*					; in D0 - Note that this field is
*					; CONTEXT SENSITIVE to the error code
*					; of the function that returned it
*					; Addendum 3/7/90:

**;;      LABEL	TB_EffectsData		;temporary

	APTR	TB_CurrentCopList	;->a copperlist that can be installed
	APTR	TB_CurrentFourFieldTBL	;info so can install a 4 field coplist at anytime.
	APTR	TB_CurrentSprite1	;supplies line#s for ELH to sprite stuff

* TB_CurrentSpriteTable is newer and is synonymous with TB_CurrentSpr0Tbl
* At one time we only needed to manipulate sprite0 (freezethaw/grab1field),
* but now sprite1 needs to also be changed for color cycling. All coplists
* have the sprite1 ptrs following the sprite0 ptrs. 
      LABEL	TB_CurrentSpriteTable	;->spr0pt & spr1pts
	APTR	TB_CurrentSpr0Tbl	;->tbl of ->spr0pt instructions

	WORD	TB_CurrentInstallField	;a value that indicates how to install
					;the CurrentCopList

	WORD	TB_CurrentVStart	;top of sprites, usually 21
* Dont't forget to update TB_BPLCON0 also

	LONG	TB_CurrentSprite0Ctrl	; Addendum 2/7/90:
	LONG	TB_CurrentSprite1Ctrl
		
	WORD	TB_ColorOrBW		;during transitions, -1=BG is B/W
					;1=FG is B/W, 0=all color.
					;Not during transition, 0=use color
					;non-zero = use B/W video					

	WORD	padX			;to maintain long word alignment

* NOTE: The VTSetUp and EffectsBase STRUCTs were removed from here
* and put at the end of TB to help avoid offset problems each time these
* STRUCTs change in size.  1/13/94 SKell

*====	Additional stuff - Addendum 6/14/90:

	APTR	TB_ARexxPort		; private port for ARexx message
*					; input only
*					; Addendum 6/14/90:
	WORD	TB_ProjectNumber	; reflects the project #currently set
*					; by the user in the config slice.
*					; DOES NOT necessarily reflect what
*					; is the current project last loaded
*					; or saved - that is reflected by
*					; TB_CurrentPJNumber
*					; Addendum 6/26/90:

*					; The following is for the
*					; FGC_MouseXY system:
*					; Addendum 9/7/90:
	WORD	TB_MouseNest		; mouse state info and nest count:
*					; -1  - mouse is inactive
*					; >-1 - mouse is active
*					; this field should be initialized
*					; to -1 at program startup
	ULONG	TB_OrgIDCMP		; stash of the original IDCMP flags
*					; prior to the mouse being activated
*					; so that we can later restore it
	WORD	TB_MouseX		; contains the X component and
	WORD	TB_MouseY		; the Y component copied directly
*					; from an IDCMP MOUSEMOVE message

*					; Addendum 9/13/90:
	WORD	TB_CGSelVal		; these values are backup values for
	WORD	TB_TBSelVal		; TB_NumPadPri and TB_NumPadSec so
	WORD	TB_FLSelVal		; that the current state of the
	WORD	TB_FSSelVal		; respective NumPad entity system is
*					; remembered so that it can be
*					; restored later
*					; Addendum 10/2/90: the TB_TBSelVal
*					; field no longer serves as a backup
*					; to the TB_NumPad Pri and Sec fields
*					; when the ToolBox NumPad system is
*					; made the active NumPad recipient.
*					; Instead TB_EfxFG will be used.
*					; However TB_TBSelVal will continue
*					; to be written into and indeed must
*					; be present since it occupies a
*					; legitimate array member when the
*					; above TB_XXSelVal fields are
*					; accessed via an index.

*					; Addendum 9/16/90:
	APTR	TB_LUTFGL		; FastGadget list of LUT ToolBox
*					; croutons. They no longer will
*					; exist in the normal ToolBox grid
*					; FGLs and therefore will not be
*					; available for direct user
*					; selection, but rather selected via
*					; the LUT slice. Otherwise they look
*					; and behave like normal ToolBox
*					; croutons except they will have a
*					; negative FG_IndexID field. This is
*					; primarily for the benefit of the
*					; Switcher during loading and saving
*					; of projects so that it will know
*					; to place LUT croutons in this
*					; special FGL. Also other entities
*					; in the Toaster system can find out
*					; if the controlling entity of the
*					; ToolBox system is a LUT crouton.

	LONG	TB_ARexxResult		; -> ARexx return data
	LONG	TB_ARexxResultSize	; length of ARexx return data

	LONG	TB_LastSeconds		; Addendum 10/23/90: These fields
	LONG	TB_LastMicros		; are set to the value of each IDCMP
*					; message that passes through the
*					; Switcher. The use of these fields
*					; however may extend beyond just used
*					; to monitor IDCMP timestamps of the
*					; Switcher. The config slice IDCMP
*					; handler also sets these fields

*					; Addendum 10/30/90:
	APTR	TB_SwitcherTask		; pointer to the Switcher task
*					; (actually a Process)
	WORD	TB_DisplayState		; maintains current display state -
*					; 0 if Switcher state active - -1 if
*					; AMIGA WB state active

*					; Addendum 10/31/90:
	UBYTE	TB_CycleFlags		; flag/counter used by the LUT color
*					; cycling system. Bit 0 is cycle
*					; enable bit, Bit 1 is used to stash
*					; frameflop bit.
	BYTE	TB_Flags		; for longword align and....
*					; Addendum 12/6/90: This is a flag
*					; bit field for various control
*					; flags
IMAGERY_ONOFF_BIT	EQU	7	; Addendum 12/6/90:
IMAGERY_ONOFF_MASK	EQU	$80	; imagery/softsprite enable/disable
*					; control bit for use ONLY at the
*					; Switcher interface screen. If the
*					; bit is 0 - all is enabled. If 1 -
*					; disabled. Please refer to the
*					; functions ImageryOn()/ImageryOff()
*					; for details on the use and
*					; limitations on this control bit.
REQACTI_ONOFF_BIT	EQU	6	; Addendum 1/4/91:
REQACTI_ONOFF_MASK	EQU	$40	; Switcher requester active/inactive
*					; flag bit. If the bit is 0 - no
*					; Switcher requester is active and
*					; the hotkey, if active will work
*					; normally. If the bit is 1 - there
*					; is a Switcher requester active and
*					; the hotkey, if active will be
*					; disabled.
CIAA_TOD_ONOFF_BIT	EQU	5	; Addendum 1/25/91:
CIAA_TOD_ONOFF_MASK	EQU	$20	; CIAA_TOD clock frequence flag bit.
*					; If the bit is 0 - the clock
*					; frequency driving the CIAA_TOD
*					; will be 60HZ. If the bit is 1 -
*					; then the frequency will be 30HZ.
TOWB_ONOFF_BIT		EQU	4	; Addendum 1/29/91:
TOWB_ONOFF_MASK		EQU	$10	; If set (by hotkey input.device
*					; handler only!) to a 1, then a
*					; switch to WB is pending and will
*					; be handled by the Switcher IDCMP
*					; handler. Once the switch is made
*					; this bit should be reset by any
*					; entity after making a switch to WB.
GRAB68000_OK_BIT	EQU	3	; Addendum 3/11/91:
GRAB68000_OK_MASK	EQU	$08	; If the bit is 1 - then use the
*					; standard 68000 frame grabbing. If		
*					; the bit is 0, use ReadScanLine().
AVEI_BIT		EQU	2	; Addendum 10/3/91:
AVEI_MASK		EQU	$04	; If the bit is 1 - then AVEI is
*					; installed. Else its non-AVEI.

MASKDOSSPECIAL_BIT	EQU	1	;Set if /, and : are to masked from
MASKDOSSPECIAL_MASK	EQU	$02	;input stream.


ABORTVBCHAIN_BIT	EQU	0	;Set if the Vert Blank chain is to
ABORTVBCHAIN_MASK	EQU	$01	;be interrupted after the sequencer

	APTR	TB_ColorCycle		; pointer/flag - when the LUT color
*					; cycling system is enabled, this
*					; field will not be NULL, it instead
*					; will point to the color cycling
*					; function responsible for producing
*					; the LUT color cycling
	APTR	TB_VBIntServer		; pointer to the interrupt structure
*					; managing a high priority AMIGA
*					; interrupt server primarily for the
*					; benfit of the LUT color cycling
*					; system

	WORD	TB_BackGround		; Addendum 4/11/91: Holds the current
*					; FG_IndexID of the active matte
*					; color

	BYTE	TB_LutBus		;which rows control LUT

* TB_LutBus bit definitions (all cleared when not in LUT mode)
* At the current time, these bits are mutually exclusive.
B_LUTBUS_PRVW	EQU	0	;bit set if Prvw row controls lut
B_LUTBUS_MAIN	EQU	1	;           Main
B_LUTBUS_OLAY	EQU	2	;           OLay

M_LUTBUS_NONE	EQU	0
M_LUTBUS_PRVW	EQU	(1<<B_LUTBUS_PRVW)	;Prvw row controls lut
M_LUTBUS_MAIN	EQU	(1<<B_LUTBUS_MAIN)	;Main
M_LUTBUS_OLAY	EQU	(1<<B_LUTBUS_OLAY)	;OLay

	BYTE	TB_LutMode	;are we using B/W or Color Luts

LUTMODE_BW	EQU	1
LUTMODE_COLOR	EQU	2

	LONG	TB_LightFont			;font used by requesters
	LONG	TB_TioBase			;This is the tio library

	APTR	TB_EFXbase			;->effects.library

	APTR	TB_ToasterConfig		;->ToasterConfig HardSets

	LONG	TB_spare0	;These are free for future expansion.
	LONG	TB_spare1	;We may use these in silent revs?
	LONG	TB_spare2
	LONG	TB_spare3
	LONG	TB_spare4
	LONG	TB_spare5
	LONG	TB_spare6
	LONG	TB_spare7
	LONG	TB_spare8
	LONG	TB_spare9
	LONG	TB_spareA
	LONG	TB_spareB
	LONG	TB_spareC
	LONG	TB_spareD
	LONG	TB_spareE
	LONG	TB_spareF

*---------	SKELL 9/11/92
	LONG	TB_MasterClock	;->MasterClock server
	LONG	TB_MasterTime	;# frames since startup of switcher
	LONG	TB_MasterTimer	;used for frame count downs during sequencing
*---------

	WORD	TB_BPLCON0orBits ;these bits are always ORed to any words
				 ;that are written to BPLCON0.
				 ;See Switcher.a for bit list.

	BYTE	TB_Flags2	;miscell. bits

* This used to be called A4000_BIT & A4000_MASK
AACHIPS_BIT	EQU	7	;set if this is an A4000 AA Chip Set
AACHIPS_MASK	EQU	$80

ECSFETCH_BIT	EQU	6	;set if running non AA code
ECSFETCH_MASK	EQU	$40

MAINFEEDBACK_BIT  EQU	5    ;set if Toaster has filtered Main connected
MAINFEEDBACK_MASK EQU	$20  ;to IS_EXT. Requires calls to TestMainFeedback()

EFFECTBORDERCOLOR_BIT	 EQU	4    ;set if Setup screen determines effect DVE
EFFECTBORDERCOLOR_MASK   EQU	$10  ;Border color instead of Effect Matte color.

FXCOMMENT_BIT	 EQU	3    ;set if FX comment is to be shown.
FXCOMMENT_MASK   EQU	$8

ANIMFX_BIT	 EQU	2    ;set if Animated (ANIM) FX is in control
ANIMFX_MASK   	 EQU	$4   ;Clear on algrithmic or ILBM FX.

PAL_BIT		 EQU	1    ;set if in "PAL" mode = Passport4000 is present.
PAL_MASK  	 EQU	2    ;Clear if in NTSC mode.

INMOTION_BIT	 EQU	0    ;set if ANIM, ALGOFX, SCROLL/CRAWL, Animation
INMOTION_MASK  	 EQU	1    ;etc., are in progress (moving). Clear otherwise.
			     ;The MasterClock uses this in conjunction with
			     ;the PAL_BIT, inorder to waste time.

	BYTE	TB_Flags3	;some spare bits for future use

	WORD	TB_Hilightoff		; 1 GLOBAL DISABLE HILIGHT SELECTING

	UWORD	TB_InterfaceDepth	; 2 on A2000, may be 3 on AA machines

	APTR	TB_MasterTimerEvent	;->event that will occur when TB_MasterTimer has counted down to zero
	APTR	TB_MasterTimerData	;->data used by above event

	UWORD	TB_TBarTime		;0-$FFFF during DoTBar drag
					;(TB_TBarTime>>7) = TB_TValSec during drag

	IFND	TBarTimeMax
TBarTimeMax	EQU	($ffff)		;Maximum TBar position	
	ENDC

	UBYTE	TB_StashCount		;IS and Clip stash count, used by ChangeIS and ChangeClip
	UBYTE	TB_pad

	APTR	TB_BGColorFGL		;->Setup screens Background
					; Matte color fast gadget list
	LONG	TB_DoTBarYMouse		; Current value used by DoTBar

	WORD	TB_NumFramesSlow
	WORD	TB_NumFramesMedium	; 0 = speed locked out.
	WORD	TB_NumFramesFast	; Transition durations (bit 15 set = loop)	

	WORD	TB_EffectColor		; (0-8) Matte color used by Latch effects

	LONG	TB_CURRENTPOPUP		;This is the current popup to display
	LONG	TB_NUMCGPAGES
	LONG	TB_CGPAGEARRAY

	APTR	TB_BColorFGL		;->Setup screens Border (Effect)
		
	WORD	TB_CurrentEffectColor	;->How Setup buttons are currently set

       LABEL	TB_GUImode		; Read/Write both Top & Bottom fields
	UBYTE	TB_GUImodeTop		; Switcher/project, project/files etc.
	UBYTE	TB_GUImodeBottom

* The following bits are used in both the GUImodeBottom and GUImodeTop fields.
* The GUImodeBottom will always have some bit set.  If the GUImodeTop field
* is null then the GUImodeBottom applies to the entire display.
* If the GUImodeTop is non-null, then the display is split into two modes.

SWITCHER_BIT	 EQU	0    ;set if switcher is being shown
SWITCHER_MASK  	 EQU	1

PPOJECT_BIT	 EQU	1    ;set if switcher is being shown
PROJECT_MASK  	 EQU	2

FILES_BIT	 EQU	2    ;set if switcher is being shown
FILES_MASK  	 EQU	4

	WORD	TB_HasSoundPri
	WORD	TB_HasSoundSec
	LONG	TB_NumFramestores	; Current number of framestores
					; Color fast gadget list ??????

					;If the following fields are non-null
	APTR	TB_CustomTBarRendering	    ;the TBar routines will call
	APTR	TB_CustomMidTransRendering  ;these for rendering.

	WORD	TB_DoSafeWriteRGB	;Color for writing area on AA machines
	WORD	TB_SimpleBMspriteRGB	;Color for SimpleBMcoplist sprite
					; on AA machines
	APTR	TB_CustomClipRendering	
	APTR	TB_EditSegList		;seg list for project editor

	LONG	TB_DisplayRenderMode	;Usually only the most sig. byte is looked at
* bit 7 of msb = set   if editor   controls the top half of the display
*              = clear if switcher controls the top half of the display
* bit 6 of msb = set   if editor   controls the bottom half of the display
*              = clear if switcher controls the bottom half of the display
* bit 5 of msb = set   if editor   controls the top overscan borders
*              = clear if switcher controls the top overscan borders
* bit 4 of msb = set while sequencing (prevents AVEI & ReDoDisplays etc.)


	LONG	TB_LoadAddOnSize	;During project loading, a FGC_LOAD
					;will be sent to each crouton.  So,
					;the Crouton will have a chance to
					;specify a desired AddOnSize that may
					;differ from TBPE_AddOnSize.  Also,
					;the crouton may change
					;TBPE_AddOnOffset at that time.

	LABEL	TB_End_1_13_94		;On 1/13/94 this was the end of data
					;before a 512 space, before
					;STRUCT VTSetUp

* These Tag fields are used by FGC_GETVALUE, FGC_PUTVALUE
	APTR	TB_TagData
	LONG	TB_TagID	;TAG_CTRL + TAG_ID
	LONG	TB_TagSize

	LONG	TB_TagLongData	;used by GetLongValue

	APTR	TB_Tags		;used by FGC_LOADTAGS, FGC_SAVETAGS
	APTR	TB_CroutonBase	;->Crouton.library
	APTR	TB_FlyerBase	;->DHD.library
	LONG	TB_StartTime	;Clip start time
	LONG	TB_VideoDuration	;clips play length

	LONG	TB_NumFramesVariable	; Transition durations (bit 15 set = loop)	

	LONG	TB_WaitTime		; Time for first field of AUTO.
					; This is used by sequencing.
					; If 0, AUTO works as normal w/o
					; a wait to this time.

	LONG	TB_RequesterResult	: This field allows master removal of requesters!
					; 0=enable requesters
					; 1= Right (OK/Continue) positive result
					;-1= Left (Cancel) negative result

* New DATA goes here !!!!!!!!!!!!!!!!!!


* BYTES WILL BE DELETED FROM THE FOLLOWING "STRUCT" WHEN ADDING NEW DATA!!!!
* If we've added more than 1024 bytes beyond the TB_End_1_13_94 label,
* things will blow up!!!!!!!

	STRUCT	TB_End_Current,((TB_End_1_13_94+1024)-TB_End_Current)

**************************************************************************

	STRUCT	TB_VTSetUp,VTSU_SIZEOF	;Current VideoToasterSetUp bits
* DELETE BYTES FROM THE FOLLOWING STRUCT WHEN ADDING TO THE ABOVE STRUCT!!!!
	STRUCT	TB_VTSetUpPAD,64

	STRUCT	TB_EffectsBase,EFB_SIZEOF	;effects stuff

* DO NOT put new DATA here!!!! See above!!!!

	LABEL	TB_POSSIZ		; size of the positive body of the
*					; ToasterBase structure comprising
*					; global data and data structures
**************************************************************************
**************************************************************************
**************************************************************************


*+ DOCUMENTATION TIMEOUT: Note the the library functions about to be
*+ discussed ARE NOT the same as the FastGadget function code routines
*+ explained earlier.
*+
*+ The following entries comprise the ToasterBase library function vector
*+ offsets for use by external program code. To make a ToasterBase vector
*+ function call, use an offset from the ToasterBase pointer in A5. All
*+ ToasterBase library functions at a minimum preserve D2-D7 and A2-A6 and
*+ typically use D0,D1,A0, and A1 as scratch. The primary return value if any
*+ will be in D0. Often if the function returns result(s), then usually the
*+ condition codes will in some way reflect the result in the primary return
*+ value (for assembler language programmers), otherwise the condition codes
*+ will be trashed. The functions called through the library vectors below
*+ essentially call the assembler language interface for the particular
*+ function and therefore require the registers parameters to be setup as
*+ defined below. The return value(s) will also be in the specified
*+ register(s). Note that the assembler parameters and results can be any of
*+ the data sizes and will be specified in detail in the documentation for
*+ each function. It will be up to you, if calling these vector library
*+ functions from some HLL to have the neccessary glue code to both pass
*+ parameters to and make use of results from these library vector functions.
*+
*+ Internal to the interface/switcher code, if you have code that is to
*+ directly link up with the interface/switcher code, are 2 interfaces for
*+ each of the library function mentioned below. One is the assembler
*+ interface language, described in detail earlier, and the other is setup
*+ with the C language in mind. The assembler language labels are the
*+ function names specified below. The C language names will be prefixed by
*+ an "_", which is normally produced by the C compiler. The C language
*+ interface requires that the parameters specified are pushed onto the
*+ stack in order of back to front (again normal for C compilers on the
*+ AMIGA). All parameter are assumed LONG. Any pointers to scalar data are
*+ assumed to point to LONG data types that however are still in the proper
*+ format when loaded into the pertinent registers to complete the function
*+ through the assembler routine. All returned values, either directly in
*+ D0, or indirectly through supplied pointers will be a LONG value, and the
*+ condition code results will not aplly as they sometimes do in the
*+ assemler language interface. Also the C interface eliminates the need of
*+ special glue code to setup A5 to point to the ToasterBase structure when
*+ needed, as it will be taken care of by the C interface code. Programmers
*+ using the assemler language interface will have to take care of setting
*+ up A5, if the function requires it. With C, just have your C program call
*+ the C interface label with the parameters, if needed, setup. IMPORTANT
*+ NOTE: The C language parameters and return values for a particular
*+ function when using the C language interface may not always mirror the
*+ parameter lists shown below for that function (they represent the
*+ assembly language interface). Please refer to the documentation for that
*+ library function.

*+ Addendum 2/25/90: ToasterBase now is more of a formal Exec library, as it
*+ now includes its library structure. It is still not a full library, as it
*+ is managed completely by the Switcher process, rather than by the system
*+ using the library private routines Open, Close, Expunge, and ExtFunc. You
*+ can however use SetFunction() on it.

	LIBINIT		; start of public function vectors of ToasterBase

*	FastGadget related functions.

	LIBDEF	_LVODrawFastGList
* void DrawFastGList( Count, Offset, FastGadget, Window, Req );
*                      D0     D1      A0          A1      A2

	LIBDEF	_LVOCompFastGList
* void CompFastGList( Count, Offset, FastGadget, Window, Req );
*                      D0     D1      A0          A1      A2

	LIBDEF	_LVOClearFastGList
* void ClearFastGList( Count, Offset, FastGadget, Window, Req );
*                       D0     D1      A0          A1      A2

	LIBDEF	_LVOSaveFastGList
* void SaveFastGList( Count, Offset, FastGadget, Window, Req, Buffer );
*                      D0     D1      A0          A1      A2   A3

	LIBDEF	_LVOLoadFastGList
* void LoadFastGList( Count, Offset, FastGadget, Window, Req, Buffer );
*                      D0     D1      A0          A1      A2   A3

	LIBDEF	_LVODigitFastG
* void DigitFastG( X, Y, DigitIndex, ImageTableIndex, FastGadget );
*                  D0 D1  D2          D3               A0

	LIBDEF	_LVOCompBoolSelect
* LONG CompBoolSelect( FastGadget, Window, Req );
*  D0                   A0          A1      A2

	LIBDEF	_LVOImageBoolSelect
* LONG ImageBoolSelect( FalseIndex, TrueIndex, FastGadget, Window, Req );
*  D0                    D0          D1         A0          A1      A2

	LIBDEF	_LVOHiLiteBoolSelect
* LONG HiLiteBoolSelect( FastGadget, Window, Req );
*  D0                     A0          A1      A2

	LIBDEF	_LVOMouseFastGList
* LONG MouseFastGList( Count, MouseX, MouseY, FastGadget, Req );
*  D0                   D0     D1      D2      A0          A1

	LIBDEF	_LVOLoadFastG
* LONG LoadFastG( FastGadgetStringName );
*  D0              A0

	LIBDEF	_LVOUnLoadFastG
* void UnLoadFastG( FastGadget );
*                    A0

	LIBDEF	_LVOAddFastGList
* LONG AddFastGList( Count, Position, FastGadgetSrc, FastGadgetDestBase );
*  D0                 D0     D1        A0             A1

	LIBDEF	_LVORemoveFastGList
* LONG RemoveFastGList( Count, FastGadgetSrc, FastGadgetDestBase );
*  D0                    D0     A0             A1

	LIBDEF	_LVOIndexFastG
* LONG IndexFastG( Index, FastGadgetListBase );
*  D0               D0     A0

	LIBDEF	_LVOIndexIDFastG
* LONG IndexIDFastG( IndexID, FastGadgetListBase );
*  D0                 D0       A0

	LIBDEF	_LVOAddressFastG
* LONG AddressFastG( FastGadget, FastGadgetListBase );
*  D0                 A0          A1

	LIBDEF	_LVOPutNewLocTB
* LONG PutNewLocTB( TBFastGadget );
*  D0                A0

	LIBDEF	_LVOInsertTB
* LONG InsertTB( IndexID );
*  D0             D0

	LIBDEF	_LVODeleteTB
* LONG DeleteTB( IndexID );
*  D0             D0

	LIBDEF	_LVOReadProjEntry
* LONG ReadProjEntry( FileHandle );
*  D0                  A0

	LIBDEF	_LVOWriteProjEntry
* LONG WriteProjEntry( FileHandle, TBFastGadget );
*  D0                   A0          A1

	LIBDEF	_LVOReadProject
* LONG ReadProject( ProjectNum );
*  D0                D0

	LIBDEF	_LVOReadDefaultProject
* LONG ReadDefaultProject();
*  D0

	LIBDEF	_LVOWriteProject
* LONG WriteProject( ProjectNum, CommentSTR );
*  D0                 D0          A0

	LIBDEF	_LVOReadCurrentProject
* LONG ReadCurrentProject();
*  D0

	LIBDEF	_LVOWriteCurrentProject
* LONG WriteCurrentProject( ProjectNum );
*  D0                        D0

	LIBDEF	_LVOInitFileBuffering
* void InitFileBuffering( Input, Output );
*                          A0     A1

	LIBDEF	_LVOBuffInput
* LONG BuffInput();
*  D0

	LIBDEF	_LVOBuffOutput
* LONG BuffOutput();
*  D0

	LIBDEF	_LVOBuffGetChar
* LONG BuffGetChar();
*  D0

	LIBDEF	_LVOBuffPutChar
* LONG BuffPutChar( Char );
*  D0                D0

	LIBDEF	_LVOBuffRead
* LONG BuffRead( Count, Buffer );
*  D0             D0     A0

	LIBDEF	_LVOBuffWrite
* LONG BuffWrite( Count, Buffer );
*  D0              D0     A0

	LIBDEF	_LVOUnLoadToolBox
* void UnLoadToolBox();

	LIBDEF	_LVORemoveTBFG
* void RemoveTBFG( TBFG);
*                   A0

	LIBDEF	_LVOPlaceTBFG
* void PlaceTBFG( TBFastGadget );
*                  A0

	LIBDEF	_LVORefreshFCString
* void RefreshFCString( FCFastGadget );
*                        A0

	LIBDEF	_LVOActivateFCString
* void ActivateFCString( FCFastGadget );
*                         A0

	LIBDEF	_LVOUpDateFC
* void UpDateFC():

*	SoftSprite related functions.

	LIBDEF	_LVOSoftSpriteOn
* void SoftSpriteOn();

	LIBDEF	_LVOSoftSpriteOff
* void SoftSpriteOff();

	LIBDEF	_LVOSoftSpriteBPLCON0On
* void SoftSpriteBPLCON0On();

	LIBDEF	_LVOSoftSpriteBPLCON0Off
* void SoftSpriteBPLCON0Off();

	LIBDEF	_LVOSoftSpriteAudioOn
* void SoftSpriteAudioOn();

	LIBDEF	_LVOSoftSpriteAudioOff
* void SoftSpriteAudioOff();

	LIBDEF	_LVOSoftSpriteVSynch
* void SoftSpriteVSynch( VBeamPos );
*                         D0

	LIBDEF	_LVOOpenSoftSprite
* LONG OpenSoftSprite( VBeamPos );
*  D0                   D0

	LIBDEF	_LVOCloseSoftSprite
* void SoftSpriteClose();

	LIBDEF	_LVOMoveSoftSpriteABS
* void MoveSoftSpriteABS( XCoord, YCoord );
*                          D0      D1

	LIBDEF	_LVOMoveSoftSpriteREL
* void MoveSoftSpriteREL( XOffset, YOffset );
*                          D0       D1

*	Miscellaneous and special interest related functions.

	IFD	NEEDED

	LIBDEF	_LVOSlope
* LONG Slope( DeltaX, DeltaY );
*  D0          D0      D1

	LIBDEF	_LVOSine
* LONG Sine( Position );
*  D0         D0

	ENDC

	LIBDEF	_LVOSelectButtonState
* void SelectButtonState();

	LIBDEF	_LVODeltaYMouse
* DeltaYResult NewYMouse DeltaYMouse( OldYMouse );
*  D0           D1                     D1

	LIBDEF	_LVODeltaXMouse
* DeltaXResult NewXMouse DeltaXMouse( OldXMouse );
*  D0           D1                     D1

	LIBDEF	_LVOMaskToIndex
* WORD MaskToIndex( Mask );
*  D0                D0

	LIBDEF	_LVOIndexToMask
* WORD IndexToMask( Index );
*  D0                D0

	LIBDEF	_LVOReDoDisplay
* void ReDoDisplay();

	LIBDEF	_LVOUpdateDisplay
* void UpdateDisplay();

	LIBDEF	_LVOClearToastDisplay
* void ClearToastDisplay();

	LIBDEF	_LVOClearToolBoxArea
* void ClearToolBoxArea();

	LIBDEF	_LVODiskDeviceList
* void DiskDeviceList( Container );
*                       A0

	LIBDEF	_LVOReValidate
* void ReValidate( Mask );
*                   D0

;;;;	LIBDEF	_LVODisplayMessageAndWait		; Addendum 4/26/90:
;;;;* void DisplayMessageAndWait( Message1, Message2 );	; - removed
;;;;*                              A0        A1

	LIBDEF	_LVOSwitcherAutoRequest
* LONG SwitcherAutoRequest( ControlFlag, ArrayPointer );
*  D0                        D0           A0

	LIBDEF	_LVODoSwitcherRequester
* LONG DoSwitcherRequester
*  D0  ( OKIDCMP, CancelIDCMP, Msg1, Msg2, OKMsg, CancelMsg );
*         D0       D1           A0    A1    A2     A3

	LIBDEF	_LVOEnableKeyRepeat
* void EnableKeyRepeat();

	LIBDEF	_LVODisableKeyRepeat
* void DisableKeyRepeat();

	LIBDEF	_LVOAutoRequestEnable
* void AutoRequestEnable();

	LIBDEF	_LVOAutoRequestDisable
* void AutoRequestDisable();

	LIBDEF	_LVOFloppyDiskInfo
* void FloppyDiskInfo();

	LIBDEF	_LVOFloppyDiskFormat
* LONG FloppyDiskFormat( Unit, ShowFlag, Name );
*  D0                     D0    D1        A0

	LIBDEF	_LVOFloppyInOut
* void FloppyInOut();

	LIBDEF	_LVOFloppyDiskTest
* LONG FloppyDiskTest():
*  D0

	LIBDEF	_LVORemFloppyDiskPort
* void RemFloppyDiskPort():

	LIBDEF	_LVOFloppyDiskChange
* LONG FloppyDiskChange():
*  D0

	LIBDEF	_LVOFloppyDiskQuery
* LONG FloppyDiskQuery():
*  D0

;;	LIBDEF	_LVOFindFileEntity
;;* LONG FindFileEntity( Value, Type, Count, DevPath, Container );
;;*  D0                   D0     D1    D2     A0       A1

	LIBDEF	_LVOBuildFileName
* LONG BuildFileName( Value, Type, Comment, Container );
*  D0                  D0     D1    A0       A1

	LIBDEF	_LVOBuildFSTable
* LONG BuildFSTable();
*  D0

	LIBDEF	_LVOBuildProjectTable
* LONG BuildProjectTable();
*  D0

	LIBDEF	_LVOLockEffects
* LONG LockEffects( Mode );
*  D0                D0

	LIBDEF	_LVOLockFS
* LONG LockFS();
*  D0

	LIBDEF	_LVOLockProject
* LONG LockProject();
*  D0

	LIBDEF	_LVOLockAuxLibs
* LONG LockAuxLibs();
*  D0

	LIBDEF	_LVOLockToasterFonts
* LONG LockToasterFonts( Mode );
*  D0                     D0

	LIBDEF	_LVOClearIDCMP
* void ClearIDCMP( IDCMPMsgPort );
*                   A0

	LIBDEF	_LVOSetLibVector
* LONG SetLibVector( Offset, Library, NewVector );
*  D0                 D0      A0       A1

*	String support.

	LIBDEF	_LVOIsaDigit
* LONG IsaDigit( Char );
*  D0             D0

	LIBDEF	_LVOToUpperCase
* LONG ToUpperCase( Char );
*  D0                D0

	LIBDEF	_LVOSTRcopy
* LONG STRcopy( STR1, STR2 );
*  D0            A0    A1

	LIBDEF	_LVOSTRNcopy
* LONG STRNcopy( Count, STR1, STR2 );
*  D0             D0     A0    A1

	LIBDEF	_LVOBSTRcmp
* LONG BSTRcmp( BSTR1, BSTR2 );
*  D0            A0     A1

	LIBDEF	_LVOSTRcmp
* LONG STRcmp( STR1, STR2 );
*  D0           A0    A1

	LIBDEF	_LVOSTRlen
* LONG STRlen( STR );
*  D0           A0

	LIBDEF	_LVOByteSubSet
* LONG ByteSubSet( Count, ByteSeq1, ByteSeq2 );
*  D0               D0     A0        A1

*	ToolBox FastGadget (croutons) support functions.

	LIBDEF	_LVOToolBoxFill
* void ToolBoxFill( TBFGListBase );
*                    A0

	LIBDEF	_LVODrawBorderBox
* void DrawBorderBox( X1, Y1, Width, Height );
*                     D0  D1   D2     D3

	LIBDEF	_LVODoHiLiteSelect
* LONG DoHiLiteSelect( FastGadget );
*  D0                   A0

	LIBDEF	_LVODoHiLiteSelectK
* LONG DoHiLiteSelectK( FastGadget );
*  D0                    A0

	LIBDEF	_LVODoHiLiteSelectQ
* LONG DoHiLiteSelectQ( FastGadget );
*  D0                    A0

	LIBDEF	_LVODoHiLiteRemove
* void DoHiLiteRemove( FastGadget );
*                       A0

	LIBDEF	_LVODoHiLiteRemoveQ
* void DoHiLiteRemoveQ( FastGadget );
*                        A0

	LIBDEF	_LVODoTBar
* LONG DoTBar( Handler );
*  D0           A0

	LIBDEF	_LVOCookAndServeOLay
	LIBDEF	_LVOCookAndServeMain
	LIBDEF	_LVOCookAndServePrvw
	LIBDEF	_LVOCookAndServeClipA
	LIBDEF	_LVOCookAndServeKeyButton
	LIBDEF	_LVOCookAndServeTake
	LIBDEF	_LVOCookAndServeFreeze

	LIBDEF	_LVOCookOLay
	LIBDEF	_LVOCookMain
	LIBDEF	_LVOCookPrvw
	LIBDEF	_LVOCookClipA
	LIBDEF	_LVOCookKeyButton
	LIBDEF	_LVOCookTake
	LIBDEF	_LVOCookFreeze

*	Internal library list handling functions.

	LIBDEF	_LVOOpenAuxLib
* LONG OpenAuxLib( LibraryName );
*  D0               A0

	LIBDEF	_LVOCloseAuxLib
* void CloseAuxLib( Library );
*                    A0

	LIBDEF	_LVORemoveAuxLib
* LONG RemoveAuxLib( Library );
*  D0                 A0

* SKELLS FUNCTIONS  ***********************************

;;	LIBDEF	_LVOInitSAWrite	
;;	LIBDEF	_LVOSetUpSAWrite
 	LIBDEF	_LVOInitDVECopList1
	LIBDEF	_LVOSetUpDVECopList1
	LIBDEF	_LVOInitDVEInterface1
	LIBDEF	_LVOSetUpDVEInterface1
	LIBDEF	_LVOInitToaster		;used by old InstallToaster
	LIBDEF	_LVOInitBytes2BmLUT
	LIBDEF	_LVODoLineWrite		
	LIBDEF	_LVOInitDVESprite1Buff
	LIBDEF	_LVOInitDVEBitMapBuff
;;	LIBDEF	_LVOHorizEdges2CompBmList


	 IFD	DYNAMICSPRITES
	LIBDEF	_LVOInitSprite0Live
	LIBDEF	_LVOInitSprite0Freeze
	LIBDEF	_LVOInitSprite1Linear
	LIBDEF	_LVOInitSprite0
	LIBDEF	_LVOInitSprite1
	LIBDEF	_LVOInitSpriteNull
	 ENDC	;DYNAMICSPRITES


	LIBDEF	_LVOBytes2Sprite1
	LIBDEF	_LVOFillSprite
	LIBDEF	_LVOCopySprite2Sprite
	LIBDEF	_LVOELH2Sprite0
	LIBDEF	_LVOELH2Sprite1
	LIBDEF	_LVOBytes2BitMaps
	LIBDEF	_LVOWait4Top
	LIBDEF	_LVOInstallField
	LIBDEF	_LVOInstallFieldAndWait
	LIBDEF	_LVOInstallFieldIorIII
	LIBDEF	_LVORestoreCopperList
	LIBDEF	_LVOSendELH2Toaster
	LIBDEF	_LVOGetFileLength
	LIBDEF	_LVOReadFile
	LIBDEF	_LVOInterruptsOff
	LIBDEF	_LVOInterruptsOn
	LIBDEF	_LVODMAoff
	LIBDEF	_LVODMAon
	LIBDEF	_LVOMemoryMapCopLists
	LIBDEF	_LVOMemoryMapPlanes
	LIBDEF	_LVOInitAVECopLists
	LIBDEF	_LVOInitAVEInterfaces
	LIBDEF	_LVOSetUpEntrySprites
	LIBDEF	_LVOSendSprites2Toaster
	LIBDEF	_LVOGetEPhase
	LIBDEF	_LVOSyncCPU2Video
	LIBDEF	_LVOGrabField
	LIBDEF	_LVOInitReadCopList
	LIBDEF	_LVOGrabbed2Planes
	LIBDEF	_LVOInstallFieldI
	LIBDEF	_LVOReinstallCurrentCopList
	LIBDEF	_LVOInitFieldWrite
	LIBDEF	_LVOSetUpFieldWrite
	LIBDEF	_LVOSetUpAVECopList
	LIBDEF	_LVOSetUpAVEInterface
	LIBDEF	_LVOFreezeThawDVE
	LIBDEF	_LVOInstallAVE
	LIBDEF	_LVOInstallAVEI
	LIBDEF	_LVOInitEFX
	LIBDEF	_LVOInitEFXChipMem
	LIBDEF	_LVOInitDVEFastMem
	LIBDEF	_LVOInitDVEChipMem
	LIBDEF	_LVOELH2Sprites

	LIBDEF	_LVOMask2AM
	LIBDEF	_LVOMask2BM
	LIBDEF	_LVOMask2IS
	LIBDEF	_LVOMask2PV
	LIBDEF	_LVOMask2LK

	LIBDEF	_LVOAM2Mask
	LIBDEF	_LVOBM2Mask
	LIBDEF	_LVOIS2Mask
	LIBDEF	_LVOPV2Mask
	LIBDEF	_LVOLK2Mask

	LIBDEF	_LVOSetUpELHEntrySprites

;;	LIBDEF	_LVOTransSwitcherABFreeze
;;	LIBDEF	_LVOTransSwitcherABTake
;;	LIBDEF	_LVOTransSwitcherABDuring
;;	LIBDEF	_LVOTransSwitcherABInit

;;	LIBDEF	_LVOTransDVEOnABInit
;;	LIBDEF	_LVOTransDVEOffABInit
;;	LIBDEF	_LVOTransDVEOnABTake
;;	LIBDEF	_LVOTransDVEOffABTake
;;	LIBDEF	_LVOTransDVEABDuring
;;	LIBDEF	_LVOTransDVEABFreeze

;;	LIBDEF	_LVOTransSwitcherABUnTake
;;	LIBDEF	_LVOTransDVEOnABUnTake
;;	LIBDEF	_LVOTransDVEOffABUnTake

	LIBDEF	_LVOUpdateTBar
	LIBDEF	_LVOShortOutFader

	LIBDEF	_LVOProcessLoadButton
	LIBDEF	_LVOProcessSaveButton

	LIBDEF	_LVOInstallAVEIdoELH
	LIBDEF	_LVOInstallAVEdoELH
	LIBDEF	_LVOInitWipeInterface1
	LIBDEF	_LVOSetUpWipeInterface1
	LIBDEF	_LVOInstallFieldIthruIV
	LIBDEF	_LVOELHList2Sprites
	LIBDEF	_LVOSendELHList2Toaster
	LIBDEF	_LVOSetSaveBank
	LIBDEF	_LVOSetLoadBank
	LIBDEF	_LVODoBlockWrite
	LIBDEF	_LVODoFieldWrite
	LIBDEF	_LVOBytes2Planes
	LIBDEF	_LVOWriteYIQBlock

 	LIBDEF	_LVOInitDVECopList2
	LIBDEF	_LVOSetUpDVECopList2
	LIBDEF	_LVOBytes2BitMapsDVE2

	LIBDEF	_LVODoTake
	LIBDEF	_LVOGray2Bank

	LIBDEF	_LVOReadCIAA_TOD
	LIBDEF	_LVOResetFrameBase
	LIBDEF	_LVOGetFrameBase
	LIBDEF	_LVOWaitFrameCount

	LIBDEF	_LVOEnableInput
	LIBDEF	_LVODisableInput

	LIBDEF	_LVOInitSafeWrite
	LIBDEF	_LVOOldDoSafeWrite
	LIBDEF	_LVOInitSimpleBMCopLists
	LIBDEF	_LVOSetUpSimpleBMCopList
	LIBDEF	_LVOInitReadScanLineBMs
	LIBDEF	_LVOReadScanLine

	LIBDEF	_LVOTestReadScanLine
	LIBDEF	_LVOCaliReadScanLine
	LIBDEF	_LVOAutoCalibrate
	LIBDEF	_LVOSetDigitalPhase	;was _LVOSetDAHue
	LIBDEF	_LVOSetPedestal
	LIBDEF	_LVOSetGain
	LIBDEF	_LVOGrab1Bank
	LIBDEF	_LVOWriteGrayPulse
	LIBDEF	_LVONoTransFreeze
	LIBDEF	_LVOTestAutoCal
	LIBDEF	_LVOSendBytes2Toaster

	LIBDEF	_LVOAllInterruptsOn
	LIBDEF	_LVOAllInterruptsOff

	LIBDEF	_LVOReadHardSets
	LIBDEF	_LVOWriteHardSets
	LIBDEF	_LVOLoadHardSets
	LIBDEF	_LVOSaveHardSets

	LIBDEF	_LVORestoreBorderColor

	LIBDEF	_LVOReDoAllButtonRows

	LIBDEF	_LVOMouseOn
	LIBDEF	_LVOMouseOff

	LIBDEF	_LVOFlashVideoOn
	LIBDEF	_LVOFlashVideoOff

	LIBDEF	_LVOWriteLineZero

	LIBDEF	_LVORestoreMattColor
_LVOSetMatteColor	EQU	_LVORestoreMattColor

	LIBDEF	_LVOCancelCG
	LIBDEF	_LVOUpdateClipA

	LIBDEF	_LVOFrameSave
	LIBDEF	_LVOFrameLoad

	LIBDEF	_LVOSMPTEbars

	LIBDEF	_LVOForceSoftSpriteOn

	LIBDEF	_LVOULongMultiply
	LIBDEF	_LVOCreateInterrupt
	LIBDEF	_LVODeleteInterrupt

	LIBDEF	_LVOULongDivide

	LIBDEF	_LVOGetFrameFreeCount

	LIBDEF	_LVOStringToUpper

	LIBDEF	_LVOInitRGB2YIQ
	LIBDEF	_LVORGB2YIQ
	LIBDEF	_LVOInitYIQ2Composite
	LIBDEF	_LVOYIQ2Composite
	LIBDEF	_LVODitherYIQ
	LIBDEF	_LVOSendRGBInit
	LIBDEF	_LVOSendRGBBeginRegion
	LIBDEF	_LVOSendRGBAddLine
	LIBDEF	_LVOSendRGBRegion
	LIBDEF	_LVOSendRGBCleanup

	LIBDEF	_LVOImageryOn
	LIBDEF	_LVOImageryOff

	LIBDEF	_LVOTestVid1Camera
	LIBDEF	_LVOTestMain2Vid4
	LIBDEF	_LVOAutoTerm
	LIBDEF	_LVOAutoHue
	LIBDEF	_LVOInitRead7QuadsBMs
	LIBDEF	_LVOSetExternalPhase
	LIBDEF	_LVOReadScatter
	LIBDEF	_LVOScatter2IQs
	LIBDEF	_LVOSquareRootUWORD
	LIBDEF	_LVOSquareRootULONG
	LIBDEF	_LVODeltaPhase

	LIBDEF	_LVOSendOutputGPI
	LIBDEF	_LVONewSwitcherRequester

	LIBDEF	_LVODisplayNormalSprite
	LIBDEF	_LVODisplayWaitSprite
	LIBDEF	_LVOGetDisplaySprite

	LIBDEF	_LVOTest68000Grab

	LIBDEF	_LVOOpenCommonRGB
	LIBDEF	_LVOCloseCommonRGB
	LIBDEF	_LVOKillCommonRGB
	LIBDEF	_LVOUnlockCommonRGB
	LIBDEF	_LVOLockCommonRGB

	LIBDEF	_LVOQueryFile
	LIBDEF	_LVOCloseQuery
	LIBDEF	_LVOLoadRGBPicture
	LIBDEF	_LVOSaveRGBPicture

	LIBDEF	_LVOSendRGBPicture

	LIBDEF	_LVOInstallAVEC
	LIBDEF	_LVOInstallAVECdoELH

	LIBDEF	_LVOSetBackGround

	LIBDEF	_LVORoundSigned
	LIBDEF	_LVORoundUnsigned
	LIBDEF	_LVOSingleRGB2YIQ
	LIBDEF	_LVOSendRGBAddComposite
	LIBDEF	_LVOByteFillMemory

	LIBDEF	_LVOStartSaveRGBPicture
	LIBDEF	_LVOStopSaveRGBPicture
	LIBDEF	_LVOAddRGBLine

	LIBDEF	_LVOAnimWipeCroutonEffect
	LIBDEF	_LVOAnimLoad
	LIBDEF	_LVOAnimUnload
	LIBDEF	_LVOAnimSetupForward
	LIBDEF	_LVOAnimPlayForward
	LIBDEF	_LVOAnimPlayReverse

	LIBDEF	_LVOStartLoadRGBPicture
	LIBDEF	_LVOStopLoadRGBPicture
	LIBDEF	_LVOLoadRGBLine
	LIBDEF	_LVOGrabRGBField

	LIBDEF	_LVOWritePlanes
	LIBDEF	_LVOWritePlanesBW
	LIBDEF	_LVOBumpLineCount
	LIBDEF	_LVOFindDebugHunk
	LIBDEF	_LVOGetChunkType

	LIBDEF	_LVODoSafeWrite
	LIBDEF	_LVOWait4Copper

	LIBDEF	_LVOSetUp2FI
	LIBDEF	_LVOInit2FI
	LIBDEF	_LVOInstall2FIdoELH
	LIBDEF	_LVOInstall2FI
	LIBDEF	_LVOInstallFieldIorII
	LIBDEF	_LVOInstallIKey
	LIBDEF	_LVOInstallIKeyDoELH

	LIBDEF	_LVOWait4Blit
	LIBDEF	_LVOAutoMatte

	LIBDEF	_LVOLUToff
	LIBDEF	_LVOAttachSprite0
	LIBDEF	_LVOAttachSprite1
	LIBDEF	_LVOAttachSprites
	LIBDEF	_LVOVBServer1

	LIBDEF	_LVOPadFile
	LIBDEF	_LVOPadFileL
	LIBDEF	_LVOCopyFileBytes

	LIBDEF	_LVOLoadSegment			;LoadSegment(filename)
	LIBDEF	_LVONLoadSegment		;NLoadSegment(filename,buffersize)
	LIBDEF	_LVOUnLoadSegment		;UnLoadSegment(segmentlist)


	LIBDEF	_LVOWriteBMLineBW
	LIBDEF	_LVOWriteBMLine
	LIBDEF	_LVOWriteLine

	LIBDEF	_LVOSetSaveYPosition
	LIBDEF	_LVOLockToasterELH

	LIBDEF	_LVODrawTriMark

	LIBDEF	_LVOLoadPictureData
	LIBDEF	_LVOFreeIFF24OrFS
	LIBDEF	_LVOLoadIFF24OrFS	; CommonRGB.a
	LIBDEF	_LVOAllocateBufferMem	; size,att

	LIBDEF	_LVOFrameLoadNew

	LIBDEF	_LVOOpenKbdState
	LIBDEF	_LVOCloseKbdState
	LIBDEF	_LVOGetKbdState	

	LIBDEF	_LVODoMouseXY
	LIBDEF	_LVOProgramChips
	LIBDEF	_LVOLoadPatches
	LIBDEF	_LVOSetPedestalCrude
	LIBDEF	_LVOSetGainCrude
	LIBDEF	_LVOAllocPlanes
	LIBDEF	_LVOFreePlanes
	LIBDEF	_LVOFieldSave
	LIBDEF	_LVONewProcessSaveButton

	LIBDEF	_LVOSendBytes2ToasterAVEI
	LIBDEF	_LVOWriteYIQBlockAVEI
	LIBDEF	_LVODoBlockWriteAVEI
	LIBDEF	_LVORestoreBorderAVEI

	LIBDEF	_LVODoTakeNoKey

	LIBDEF	_LVOFileCopy
	LIBDEF	_LVOCancelNonStdEfx
	LIBDEF	_LVOSelectStdEfx

	LIBDEF	_LVODisableInterrupts
	LIBDEF	_LVOEnableInterrupts

	LIBDEF	_LVOInitReadScanLine
	LIBDEF	_LVODoSyncWrite
	LIBDEF	_LVOSoft2HardColor
	
	LIBDEF	_LVOInstallToaster	;new sync write
	LIBDEF	_LVOInitToaster2	;used by new sync write
	LIBDEF	_LVOTestMain2EXT
	LIBDEF	_LVOTestRGBTermination
	LIBDEF	_LVOSoftSpriteOnScreen
	LIBDEF	_LVOSoftSpriteAudioOnScreen

	LIBDEF	_LVOSetupSSBM
	LIBDEF	_LVOInstallSBMdoELHlistNoWait
	LIBDEF	_LVOInstallSBMdoELHnoWait
	LIBDEF	_LVOInstallSBMnoWait
	LIBDEF	_LVOInstallSBMdoELHlist
	LIBDEF	_LVOInstallSBMdoELH
	LIBDEF	_LVOInstallSBM
	LIBDEF	_LVOInstallAVEIdoELHlist
	LIBDEF	_LVOInstallAVECdoELHlist
	LIBDEF	_LVOInstallAVEdoELHlist

	LIBDEF	_LVOPlayAnim
	LIBDEF	_LVOFreeAnim
	LIBDEF	_LVOLoadAnim

	LIBDEF	_LVOSendRGBExtInit
	LIBDEF	_LVODrawCroutonImage
	LIBDEF	_LVOCompCroutonImage
	LIBDEF	_LVOSendRGBExtBeginRegion

	LIBDEF	_LVOBufferedClose	;was _LVOBufferClose
	LIBDEF	_LVOBufferedWrite	;was _LVOBufferWrite
	LIBDEF	_LVOBufferedRead	;was _LVOBufferRead	
	LIBDEF	_LVOBufferedOpen	;was _LVOBufferOpen  

	LIBDEF	_LVOSetupSBMCopListAA

	LIBDEF	_LVOStartHamAnimSave
	LIBDEF	_LVOStopHamAnimSave
	LIBDEF	_LVOAddHamAnimFrame
	LIBDEF	_LVOGetPalette
	LIBDEF	_LVOPrepareHam
	LIBDEF	_LVOEncodeHam

	LIBDEF	_LVOGetFileLoadName
	LIBDEF	_LVOGetFileSaveName

	LIBDEF	_LVOInitFXAudioChannels
	LIBDEF	_LVOFreeFXAudioChannels
	LIBDEF	_LVOLoadFXAudio
	LIBDEF	_LVOFreeFXAudio
	LIBDEF	_LVOPlayFXAudio
	LIBDEF	_LVOAbortFXAudio

	LIBDEF	_LVODrawBorderBoxRP

	LIBDEF	_LVOAnimFXHandler

	LIBDEF	_LVOLockAnimPalette

	LIBDEF	_LVOForceDoTBar2Top
	LIBDEF	_LVOSetupAndInstallSSBM
	LIBDEF	_LVODVElutoff

	LIBDEF	_LVOUpdateSoundImage

	LIBDEF	_LVOSomeInterruptsOff
	LIBDEF	_LVOSomeInterruptsOn

	LIBDEF	_LVOWindowDoPopList

	LIBDEF	_LVOGetMouseXY	;SetFunctionable!
	LIBDEF	_LVOIsLMBdown	;SetFunctionable!
	LIBDEF	_LVOIsRMBdown	;SetFunctionable!

	LIBDEF	_LVOIsLMBup
	LIBDEF	_LVOIsRMBup

	LIBDEF	_LVOWait4LMBup
	LIBDEF	_LVOWait4LMBdown
	LIBDEF	_LVOWait4RMBup
	LIBDEF	_LVOWait4RMBdown	

	LIBDEF	_LVOInstallAVEnoWait
	LIBDEF	_LVOInstallAVECnoWait

	LIBDEF	_LVOLoadAnimHeader
	LIBDEF	_LVOStuffFCount

	LIBDEF	_LVOFGC_PutValueCommand
	LIBDEF	_LVOFGC_GetValueCommand
	LIBDEF	_LVOFGC_LoadTagsCommand
	LIBDEF	_LVOFGC_SaveTagsCommand
		
	LIBDEF	_LVOPutStructValue
	LIBDEF	_LVOGetStructValue
	LIBDEF	_LVOPutLongValue
	LIBDEF	_LVOGetLongValue

	LIBDEF	_LVOSearchLists4TagID
	LIBDEF	_LVOSearch4TagID
	LIBDEF	_LVOMoveTag2Value
	LIBDEF	_LVOMoveValue2Tag
		
	LIBDEF	_LVOFGC_NextCommand
	LIBDEF	_LVOFGC_ToPrvwCommand
	LIBDEF	_LVOFGC_ToMainCommand

	LIBDEF	_LVOBufferedSeek	;was _LVOBufferSeek

	LIBDEF	_LVOSearchLists4TagGetID
	LIBDEF	_LVOSearch4TagGetID
	LIBDEF	_LVOSearchLists4TagPutID
	LIBDEF	_LVOSearch4TagPutID
	LIBDEF	_LVOSearchFG4Struct

	LIBDEF	_LVOAlgoFXHandler
	LIBDEF	_LVOGetTagValue

	LIBDEF	_LVOReadBufferedByte
	LIBDEF	_LVOReadBufferedWord
	LIBDEF	_LVOReadBufferedLong

	LIBDEF	_LVOSeek2CrUDchunk
	LIBDEF	_LVOCloseCroutonFile
	LIBDEF	_LVOOpenCroutonFile

	LIBDEF	_LVOExamineCroutonIconFile
	LIBDEF	_LVOExamineCroutonDataFile
	LIBDEF	_LVOExamineCroutonDefaults

	LIBDEF	_LVOAllocIconBM
	LIBDEF	_LVOFreeIconBM

	LIBDEF	_LVOFGC_LoadCommand
	LIBDEF	_LVOFGC_RemoveCommand
	LIBDEF	_LVOFGC_AutoCommand
	LIBDEF	_LVOFGC_RemoveQCommand
	LIBDEF	_LVOFGC_UnloadCommand
	LIBDEF	_LVOFGC_SelectCommand
	LIBDEF	_LVOFGC_SelectQCommand
	LIBDEF	_LVOFGC_SelectKCommand

	LIBDEF	_LVONewReadProject
	LIBDEF	_LVONewReadDefaultProject
	LIBDEF	_LVONewUnloadToolbox
	LIBDEF	_LVONewWriteProject

	LIBDEF	_LVOMakeTagListsOld
	LIBDEF	_LVOMakeTagListOld
	LIBDEF	_LVOSendFGC2Crouton
	LIBDEF	_LVOFGC_BGCommand
	LIBDEF	_LVOLoadCroutonFile

	LIBDEF	_LVOWait4Time
	LIBDEF	_LVOFGC_TakeCommand

	LIBDEF	_LVOSignedLong2ASCII
	LIBDEF	_LVOSignedWord2ASCII
	LIBDEF	_LVOSignedByte2ASCII
	LIBDEF	_LVOLong2ASCII
	LIBDEF	_LVOWord2ASCII
	LIBDEF	_LVOByte2ASCII

	LIBDEF	_LVOContinueMessage
	LIBDEF	_LVORetryOrCancel

	LIBDEF	_LVOFGC_PbuttonCommand
	LIBDEF	_LVOFGC_MbuttonCommand
	LIBDEF	_LVOFGC_ObuttonCommand

	LIBDEF	_LVOStopSavePIconRGB
	LIBDEF	_LVOIcon_CopyPIC
	LIBDEF	_LVOIcon_CopyRGB
	LIBDEF	_LVOCopy2PIconRGB
	LIBDEF	_LVOCopy2PIcon	
	LIBDEF	_LVOPCON_Save        
	LIBDEF	_LVOIcon_CopySL
	LIBDEF	_LVOStartSavePIcon
	LIBDEF	_LVOStopSavePIcon
	LIBDEF	_LVOGrabIcon
	LIBDEF	_LVOMKPIcon
	LIBDEF	_LVOMKPIconRGB
	LIBDEF	_LVOSingleLineDecode_Icon
	LIBDEF	_LVOIcon_CopyLines





* New Functions Go Here  *********************************

TB_NEGSIZ	EQU	(-COUNT_LIB)-6	; size of the function vectors in
*					; the negative offset region of
*					; the ToasterBase structure

*+ The following is a constant and macro repository for the Toaster system.
*+ Addendum 10/8/89:

ABSSYSBASE	EQU	4
CHIPBASE	EQU	$DFF000

* Amiga library ROM calls.

CALLROM	MACRO
	IFNC	'\2',''
	move.l	\2,a6
	ENDC
	jsr	_LVO\1(a6)
	ENDM

* Amiga library ROM jumps.

JUMPROM	MACRO
	IFNC	'\2',''
	move.l	\2,a6
	ENDC
	jmp	_LVO\1(a6)
	ENDM

* PC relative subroutine calls.

CALL	MACRO
	IFC	'\0','W'
	bsr	\1
	MEXIT
	ENDC
	IFC	'\0','w'
	bsr	\1
	MEXIT
	ENDC
	bsr.\0	\1
	ENDM

* External subroutine call.

XCALL	MACRO
	XREF	\1
	jsr	\1
	ENDM

* External subroutine or label jump.

XJUMP	MACRO
	XREF	\1
	jmp	\1
	ENDM

* ToasterBase library calls.

CALLTL	MACRO
	jsr	_LVO\1(a5)
	ENDM

* ToasterBase library jumps.

JUMPTL	MACRO
	jmp	_LVO\1(a5)
	ENDM

* Generates library vectors for ToasterBase.

LIBJMP	MACRO
	XREF	\1
	DC.w	$4EF9
	DC.l	\1
	ENDM

* Taken out because in 2.0's exec/macros.i

* Zeroes a data register.

*CLEAR	MACRO
*	moveq	#0,\1
*	ENDM

* Zeroes an address register.

*CLEARA	MACRO
*	sub.l	\1,\1
*	ENDM

* Generates an offset from a base symbol.

DATASYM	MACRO
\1	EQU	*-\2
	ENDM

* Read a value from ToasterBase.

GET	MACRO
	move.\0	\1(a5),\2
	ENDM

* Write a value to ToasterBase.

PUT	MACRO
	move.\0	\1,\2(a5)
	ENDM

* Address a value in ToasterBase.

DEA	MACRO
	lea	\1(a5),\2
	ENDM

* Save registers on the stack.

SAVE	MACRO
	movem.l	\1,-(sp)
	ENDM

* Restore registers off the stack.

REST	MACRO
	movem.l	(sp)+,\1
	ENDM

* Save a register on the stack.

SAVE1	MACRO
	move.l	\1,-(sp)
	ENDM

* Restore a register off the stack.

REST1	MACRO
	move.l	(sp)+,\1
	ENDM

* Sets internal error level flag.

SETERR	MACRO
__EFLAG	SET	\1
	ENDM

* Abort to specified routine with error flag.

ABORT	MACRO
	move.l	#__EFLAG,d0
__EFLAG	SET	__EFLAG+1
	jmp	\1
	ENDM

*-------------------------------------------

**************************************************************************
* Macros useful for bit field operations.
* All of these macros use an immediate mask.
*
* For all bits set in the mask, clear the corresponding destination bits

BITCLEAR	MACRO	;mask, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  andi  #~\1,\2
	  MEXIT
	ENDC
	  andi.\0 #~\1,\2
	ENDM

*-------------------------------------------
* For all bits set in the mask, set the corresponding destination bits
BITSET	MACRO	;mask, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  ori  #\1,\2
	  MEXIT
	ENDC
	  ori.\0 #\1,\2
	ENDM

*-------------------------------------------
* For all bits set in the mask, compliment the corresponding destination bits
BITNOT	MACRO	;mask, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  eori  #\1,\2
	  MEXIT
	ENDC
	  eori.\0 #\1,\2
	ENDM

*-------------------------------------------
* For all bits set in the mask, if any corresponding destination bits are
* set, then the result is Not Equal.
BITSETTEST	MACRO	;mask, source (i.e d0, (a0), 4(a0)), scratch data reg
	IFC	'','\0'
	  move	\2,\3
	  andi  #\1,\3
	  MEXIT
	ENDC
	  move.\0  \2,\3
	  andi.\0  #\1,\3
	ENDM

*-------------------------------------------
* For all bits set in the mask, if any corresponding destination bits are
* clear, then the result is Not Equal.
BITCLEARTEST	MACRO	;mask, source (i.e d0, (a0), 4(a0)), scratch data reg
	IFC	'','\0'
	  move	\2,\3
	  not	\3
	  andi  #\1,\3
	  MEXIT
	ENDC
	  move.\0  \2,\3
	  not.\0 \3
	  andi.\0  #\1,\3
	ENDM

*-------------------------------------------
* For all bits set in the mask, if the register source bits = the
* destination bits, the result is Equal. The destination is destroyed.
BITEQUALTEST_R	MACRO	;mask, source, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  eor	\2,\3
	  andi  #\1,\3
	  MEXIT
	ENDC
	  eor.\0   \2,\3
	  andi.\0  #\1,\3
	ENDM

*-------------------------------------------
* For all bits set in the mask, if the immediate source bits = the
* destination bits, the result is Equal. The destination is destroyed.
BITEQUALTEST_I	MACRO	;mask, source, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  eori	#\2,\3
	  andi  #\1,\3
	  MEXIT
	ENDC
	  eori.\0  #\2,\3
	  andi.\0  #\1,\3
	ENDM

*-------------------------------------------
* For all bits set in the mask, put the corresponding register source bits
* into the destination. The source is masked out.
BITPUT_R MACRO	;mask, source, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  BITCLEAR \1,\3
	  andi	   #\1,\2
	  or	   \2,\3	
	  MEXIT
	ENDC
	  BITCLEAR.\0 \1,\3
          andi.\0    #\1,\2
	  or.\0     \2,\3	
	ENDM

*-------------------------------------------
* For all bits set in the mask, put the corresponding immediate source bits
* into the destination.
BITPUT_I MACRO	;mask, source, destination (i.e d0, (a0), 4(a0))
	IFC	'','\0'
	  BITCLEAR \1,\3
	  BITSET   \2,\3	
	  MEXIT
	ENDC
	  BITCLEAR.\0 \1,\3
	  BITSET.\0   \2,\3	
	ENDM

*********************************************************************
* NOT EQUAL if LIVE DVE is on, NOTE: \1 must be a data register !!
ISLIVEDVEON	MACRO	;mask
	btst	#B_DV1,\1
	beq.s	*+6		;jump to after next btst, if LIVEDVE unused
	btst	#B_DV0,\1	;eq if LIVEDVE unused	
	ENDM

*-------------------------------
* NOT EQUAL if a FROZEN DVE is on, NOTE: \1 must be a data register !!
ISFROZENDVEON	MACRO	;mask
	btst	#B_DV1,\1
	bne.s	*+8		;jump to after bra.s
	btst	#B_DV0,\1
	bra.s	*+10		;jump outahere
	bchg	#B_DV0,\1
	bchg	#B_DV0,\1
	ENDM

*----------------------------------------
TURNLIVEDVEON	MACRO	;mask
	BITSET.w M_DVE,\1
	ENDM

*----------------------------------------
TURNLIVEDVEOFF	MACRO	;mask
	BITCLEAR.w M_DVE,\1
	ENDM

*----------------------------------------
ISDVEINUSE	MACRO	;mask
	btst	#B_DV1,\1
	bne.s	*+6		;jump to after next btst
	btst	#B_DV0,\1
	ENDM

*----------------------------------------
ISANALOGINUSE	MACRO	;mask
	movem.l	\1/a0,-(sp)	;a0 only so it is a valid movem
	andi.w	#M_VIDEO!M_ENCODER,\1	
	movem.l	(sp)+,\1/a0
	ENDM

*----------------------------------------
;;	The following bits of TB_ToastBGC are used to indicate the status
;;	of the matt color.  If MATT_LOCK_FLAG is set then you should never
;;	call the function RestoreMattColor.

MATT_SNOW_FLAG		equ	15
MATT_LOCK_FLAG		equ	14
MATT_CHANGE_FLAG	equ	13

LOCK_MATT	MACRO
		BSET.B	#MATT_LOCK_FLAG-8,TB_ToastBGC(a5)
		ENDM

UNLOCK_MATT	MACRO
		BCLR.B	#MATT_LOCK_FLAG-8,TB_ToastBGC(a5)
		ENDM

TEST_MATT_LOCK	MACRO
		BTST.B	#MATT_LOCK_FLAG-8,TB_ToastBGC(a5)
		ENDM

SET_MATT	MACRO
		move.w	\1,-(sp)
		move.w	TB_ToastBGC(a5),\1
		and.w	#1<<MATT_LOCK_FLAG,\1		;Keep MATT_LOCK_FLAG
		or.w	#(1<<MATT_CHANGE_FLAG),\1
		or.w	(sp)+,\1
		PUT.w	\1,TB_ToastBGC
		ENDM

CALC_FGDRAW	MACRO

_StartWord	SET	(_l/16)*2
_EndWord	SET	((_l+_w+15)/16)*2

;		dc.l	'test'

		dc.w	((_EndWord-_StartWord)/2)-1		;FG_Width
		dc.w	_h-1					;FG_Height
		dc.w	(DISPLAYWIDTH/8)-(_EndWord-_StartWord)	;FG_Modulus
		dc.l	((DISPLAYWIDTH/8)*_t)+_StartWord	;FG_Offset
		ENDM



	ENDC	;NEWTEK_INSTINCT_I
