* GadgetRoutines.asm
* toaster-paint NOTE: FlagAnim is used for "1x/2x gadget screen"

	XDEF ACTable		;action code <=> routine address table
	XDEF EndFileRequ	;arrive here when CloseBox & filenames shown
	XDEF grab_arg_a0	;canceler, autorequests dont happen remote
	XDEF grab_xyrxarg	;grab INTEGER x,y args from rexmsg
	XDEF ScreenArrange

	include "ram:mod.i"
	
 xdef _Aoff_rx	;main.asm ref'
 xdef _Dflt_rx	;main.asm ref's
 xdef _Pro0_rx	;directly called by 'redohires'

PRINTMAXCOPIES	set 50	;per stevekell, sateve feb25'89 (WAS 9 copies max)
MINHT	set 20	;MAY23...minimum picture ht
MAXGRID	set 256	;DigiPaint PI

	include	"ps:basestuff.i"
	include "lotsa-includes.i"			;needed for screens.i
	include "windows.i"
	include "screens.i"
	include "gadgets.i"
	include "intuition-menu.i"			;for checking/unchecking menuitems....
;	include "intuition/intuitionbase.i"		;ib_FirstScreen
;	include	"ps:minimalrex.i"
	include	"ps:Palette.i"
	include	"ps:serialdebug.i"
	include "ps:intuitext.i"
	include "ps:MiniSlider.i"
	include "exec/ports.i"				;debug
	include	"ps:rexx/rxslib.i"			;ARexx
	include	"ps:rexx/storage.i"
	include	"ps:rexx/rexxio.i"
	include	"ps:rexx/errors.i"


	xref BigPicColorTable_
	xref BigPicHt_
	xref BigPicWt_W_
	xref BlendCurvePtr_
	xref BPaintred_	;background color
	xref BPaintgreen_
	xref BPaintblue_
	xref BrushNumber_
	xref BrushSize_
	xref BrushType_
	xref BrushGadgetPtr_				;stuff gadget address here
	xref CircRadiusSq_
	xref DefaultX_
	xref DefaultY_
	xref DisplayedBlue_
	xref DisplayedGreen_
	xref DisplayedRed_
	xref DirnameBuffer_
	xref DlvrCount_
	xref DlvrLine_
	xref DlvrPtr_
	xref EffectNumber_
	xref EffectNamePtr_
	xref FirstScreen_
	xref FlagAAlias_	;anti-alias switch
	xref FlagAnim_		;anim tools displayed (requested, anyway)
	xref FlagClin_		;curved lines/arcs drawing mode
	xref FlagCoord_		;coordinates display
	;xref FlagHelp_
	xref FlagMenu_		;set when menu displayed (main.msg)
	xref FlagRequest_	;set when "palette/hires/ok/cancel" displayed
	xref FileColorTable_
	xref FilenameBuffer_
	xref FlagAlphapaint_
	xref FlagCopyColor_	;set when in copy color mode.	
	xref RexxLibrary_
	xref LastItemAddress_	;dirrtns use for filename str's
	xref LS_String_
	xref FlagAir_		;digipaint pi, airbrush mode
	xref FlagFont_		;font load/save
	xref FlagBitMapSaved_
	xref FlagBrush_
	xref FlagBSmooth_
	xref FlagCirc_
	xref FlagBrushColorMode_	;BRUSH image vs single rgb color
	xref FlagColorZero_
	xref FlagCurv_
	xref FlagCutPaste_
	xref FlagDisplayBeep_
	xref FlagDither_
	xref FlagDitherRandom_
	xref FlagEffects_
	xref FlagFlood_
	xref Global_Flood_
	xref FlagFrbx_		;set anytime to ask for 'frontbox'
	xref FlagHShading_
	xref FlagHStretchingC_
	xref FlagHStretching_
	xref FlagLace_
	xref FlagLine_
	xref FlagMagnifyStart_
	xref FlagsMagnify_
	xref FlagNeedGadRef_	;need gadget refresh
	xref FlagNeedIntFix_	;"need interlace fix", after scr-to-front's
	xref FlagNeedShowPaste_
	xref FlagRedrawPal_	;used with flagrefham
	xref FlagPale_
	xref FlagProc_
	xref FlagPalette_
	xref FlagRefHam_	;gets refresh of ham toolbox
	xref FlagRefProp_	;gets refresh of prop gadgets
	xref FlagRefPtr_	;gets refresh of hires 'pointer' brush image
	xref FlagRotate_	;'perspective' mode
	xref FlagRepainting_
	xref FlagNeedText_
	;xref FlagNeedPicSave_
	xref FlagOpen_
	xref FlagPick_
	xref FlagPrintRgb_
	xref FlagPrintString_
	xref FlagPrint1Value_
	xref PrintValue_	;actual data
	xref FlagPrintReq_
	xref FlagPOnly_
	xref FlagQuit_
	xref FlagRemap_	;color boxes set this when they need to "createdetermine"
	xref FlagRect_
	xref FlagRub_
	xref FlagSave_
	xref FlagSizer_	;tells mainloop->redohires->display sizer gadgets
	xref FlagSkipTransparency_
	xref FlagStretch_
	xref FlagTextAct_
	xref FlagToolWindow_	;set if gadgets in front (desired, anyway)
	xref FlagCtrlText_	;flagCTRLtext refers to 'text control window'
	xref FlagText_		;flagTEXT refers to 'text in brush'
	xref FlagViewPage_
	xref FlagVShading_
	xref FlagVStretchingC_
	xref FlagVStretching_
	xref FlagWholeScreen_
	xref GWindowPtr_
	xref HamToolColorTable_
	xref LongColorTable_
	xref ModeNamePtr_
	xref MScreenPtr_		;magnify screen
	xref MsgPtr_
	xref MyDrawX_
	xref MyDrawY_
	xref Paintblue_
	xref Paintgreen_
	xref Paintred_
	xref PaintNumber_
	xref ModeNumber_
	xref PasteBitMap_Planes_
	xref PenColor_
	;xref PropSettings_
	xref ScreenPtr_		;ham//big picture
	xref ShadeOnOffNum_	;binary 0,1,2,3 for vert/hor on/offs
	xref StretchGain_
	xref SwapBitMap_Planes_	;check non-null=have alternate screen
	;;xref ToolWindowPtr_
	xref TiltZ_
	xref TiltX_
	xref TiltY_
	xref Transpblue_	;transparent color
	xref Transpgreen_
	xref Transpred_
	xref TScreenPtr_	;ham tools
	xref XTScreenPtr_	;xtended hi-res screen
	xref Zeros_
	xref FlagLaceNEW_	;for sizer lace determ
	xref NewSizeX_
	xref NewSizeY_
	xref TileX_		;stored as <<4
	xref TileY_
	xref FlagDisk_		;disp the Disk IO conrol panel
	xref MSG_MouseX_
	xref MSG_MouseY_
	xref CurrentFrameNbr_
	xref BigPicRGB_	

	xref FlagAlphaFS_	
	xref FlagAlpha4_
	xref FlagAlpha8_
	xref FlagLoadAlpha_
	xref	DestClipName 
	xref	FlagSelDestClip_

			;relocatables....yech.
	xref HArrowGadget
	xref HVArrowGadget
	xref VArrowGadget
	xref HVShadingGadget

	xref PointerCut_data
	xref PointerPickWhat_data
	xref PointerTo_data
	xref StdBut0Gadget	;Prop0_GadgetDEH062194
	xref StdBut1Gadget,Prop1_Gadget
*	xref Prop5_Gadget	;warp amt
	xref FlagOptions_
	xref FlagDevicesOnly_

;DigiPaint PI
	xref LastDrawX_
	xref FlagPrintXY_
	xref	StencilFlag_
	xref	StencilSign_

	xref	LastShade0_
	xref	LastShade1_
	xref	LastShadeMode_

	xref	StdPot0
	xref	StdPot1

	xref	ReallySaveUnDo	;memories.o

	xref	FUSoftEdgeGadget
	xref	BB1Ptr_
	xref	AirBrushOn_
	xref	FlagSelClip_
	xref	RexxResult_

	
	xref	DestClipPath
	xref	SourceClipPath
	



DUMPHEG: MACRO	;REPLACEMENT FOR DUMPREG	
	ENDM

DUMPBEM	MACRO	;REPLACEMENT FOR DUMPMEM 
	ENDM

DUMPCXG	MACRO 	;REPLACEMENT FOR DUMPMSG	
	ENDM




cbsr:	macro	;close call, xref link for smaller code
	bsr	_\1
	endm

cbra:	macro	;close call, xref link for smaller code
  ifnd _\1
_\1:
	xjmp	\1
  mexit
  endc
  iflt *-_\1-126
	bra.s	_\1
  mexit
  endc
	bra	_\1
	endm

; ifnd GdebugDisable
SERDEBUG	equ	1
; endc

*
* The following 'stubs' call EXTernal routines,
* being in here, they allow local (small, 'bra' type vs 'jmp') jump/branches.
*


_CopyScreenSuper
	xjmp	CopyScreenSuper	;memories.o, visible->normal undo
_HideToolWindow
	xjmp	HideToolWindow	;tool.code.i
_HiresPtrHires	;in case called with a 'key' instead of 'menu'
	xjmp	HiresPtrHires	;pointers.o, clrs hires ptr->user wbench set'g
_IFF_Load	;let repaint (//iffload?) do remap
	xjmp	IFF_Load		;let repaint (//iffload?) do remap

_SaveUnDo:
		;AUG171990....
	xref FlagBitMapSaved_	;force test to fail, copy to happen...
	tst.b	FlagBitMapSaved_(BP)	;force test to fail, copy to happen...
	bne.s	1$
	xjsr	SaveUnDoRGB	;AUG171990.....helps with swap screen, clear screen, etc
1$
	xjmp	SaveUnDo	;memories.o screen->super1 or super1->cpundo
				;fall thru...clear pointer when done w/display
	;rts

_Undo_rx:	;this label in Action table
_UnDo:		;this label for 'cbsr' macro use	
	tst.l	ScreenPtr_(BP)	;have big pic? digipaint pi
	beq.s	anrts ;9$	;no...bye
	xjmp	UnDo	;memories.o ;copy fastmem undo->visible screen
;9$	rts

_UnShowPaste:
	xjsr	UnShowPaste	;cutpaste.o, removes brush, kill doublebitmap
	xjmp	FreeDouble	;memories.o, removes doublebitmap (if any)
	;rts
_Vwpg_rx:
	st	FlagViewPage_(BP)	;signal main loop for overscan display
anrts:	rts
_Vwps_rx:	;'severe' view
	lea	FlagViewPage_(BP),a0
	st	1(a0)	;signal main loop for overscan display
	rts



_Aloa_rx:
	DUMPMSG	<begin _Aloa_rx>
	bsr	grab_srxarg
	lea	FilenameBuffer_(BP),a1
	xjsr	AddString

	xref	OKGadget_IntuiText
	move.l	#OKGadget_IntuiText,a0			;relocatable, from showfreq
	move.l	it_IText(a0),a0				;'Load/Save Brush/RGB/Frame'
	lea	4(a0),a0
	move.l	#' RGB',(a0)
	xref	FlagRexxSave_
	st	FlagRexxSave_(BP)
	sf	FlagBrush_(BP)
	xref	FlagCutLoadBrush_
	sf	FlagCutLoadBrush_(BP)
	st	FlagOpen_(BP)
	xref	Flag24_
	xref	FlagFont_
	xref	FlagCompFReq_
	st	Flag24_(BP)
	sf	FlagFont_(BP)	
	sf	FlagCompFReq_(BP) 
	xjsr	File_Load
	DUMPREG	<Regesters after loader>
	sf	FlagRexxSave_(BP)
	move.b	#0,FilenameBuffer_(a5)
	DUMPMSG	<end _Aloa_rx>
	rts	


_Asav_rx:
	bsr	grab_srxarg
	lea	FilenameBuffer_(BP),a1
	xjsr	AddString
	xref	OKGadget_IntuiText
	move.l	#OKGadget_IntuiText,a0		;relocatable, from showfreq
	move.l	it_IText(a0),a0			;'Load/Save Brush/RGB/Frame'
	lea	4(a0),a0
	move.l	#' RGB',(a0)
	st	FlagRexxSave_(BP)
	sf	FlagBrush_(BP)
	xref	FlagCutLoadBrush_
	sf	FlagCutLoadBrush_(BP)
	sf	FlagSave_(BP)
	st	Flag24_(BP)
	sf	FlagFont_(BP)	
	sf	FlagCompFReq_(BP) 
	sf	FlagBrush_(BP)			;say this is a file load
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	sf	FlagCompFReq_(BP) 		;file requester...NOT IN composite/sframestore mode?
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xjsr	File_Save
	move.b	#0,FilenameBuffer_(a5)
	sf	FlagRexxSave_(BP)
	rts	


	xdef	_Best_rx
_Best_rx:
	DUMPMSG	<Best>
 ifeq 0 
	xjsr	FixPaletteColors

	rts	


 endc
 ifeq 1
	lea	FilenameBuffer_(BP),a1
	lea	BestName,a0
	xjsr	AddString
	xref	OKGadget_IntuiText
	move.l	#OKGadget_IntuiText,a0		;relocatable, from showfreq
	move.l	it_IText(a0),a0			;'Load/Save Brush/RGB/Frame'
	lea	4(a0),a0
	move.l	#' RGB',(a0)
	sf	FlagBrush_(BP)
	xref	FlagCutLoadBrush_
	sf	FlagCutLoadBrush_(BP)
	sf	FlagSave_(BP)
	st	Flag24_(BP)
	sf	FlagFont_(BP)	
	sf	FlagCompFReq_(BP) 
	sf	FlagBrush_(BP)			;say this is a file load
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	sf	FlagCompFReq_(BP) 		;file requester...NOT IN composite/sframestore mode?
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xjsr	File_Save
	DUMPREG	<After File_Save>
	move.b	#0,FilenameBuffer_(a5)
 endc
 ifeq	1
	lea	FilenameBuffer_(BP),a1
	lea	BestName,a0
	xjsr	AddString

	xref	OKGadget_IntuiText
	move.l	#OKGadget_IntuiText,a0			;relocatable, from showfreq
	move.l	it_IText(a0),a0				;'Load/Save Brush/RGB/Frame'
	lea	4(a0),a0
	move.l	#' RGB',(a0)

	sf	FlagBrush_(BP)
	xref	FlagCutLoadBrush_
	sf	FlagCutLoadBrush_(BP)
	st	FlagOpen_(BP)
	xref	Flag24_
	xref	FlagFont_
	xref	FlagCompFReq_
	sf	Flag24_(BP)
	sf	FlagFont_(BP)	
	sf	FlagCompFReq_(BP) 
	xjsr	File_Load
	move.b	#0,FilenameBuffer_(a5)
 endc

 ifeq 1
	xjsr	RealARTest
	lea	BogStr,a0
	moveq	#0,d0
	move.l	a0,a1
1$	add.l	#1,d0
	tst.b	(a1)+
	bne	1$
	CALLIB	Rexx,CreateArgstring
	move.l	d0,RexxResult_(BP)
 endc

*	xjsr	TBFS2Clip
*	DUMPCXG	<allocating alpha bitplanes test>
*	xjsr	AllocateAlphaPlanes
*	xjsr	TimeCodeInc
*	DUMPCXG	<best>
*	xjsr	AlphaSaveBM
*	xjsr	SaveAlpha8bm
	rts
Best2Panic:
	DUMPMSG	<GetDefaultPath = null>	
	rts



**
*
* ARexx command for seting up default paths.
*
**
	xdef	_Gpat_rx
_Gpat_rx:
	DUMPMSG	<_Gpat_rx>
* Setup the Framestore Directory Default
	DUMPMSG	<SETING UP THE FRAM TYPE PATH>
	move.l	#'FRAM',d0			;file type
	lea	FrameDir,a0
	bsr	SetupPath			;go try to get default path.

* Setup the RGB? Directory Default
	DUMPMSG	<SETING UP THE RGBA TYPE PATH>
	move.l	#'RGBA',d0			;file type
	lea	RGBDir,a0
	bsr	SetupPath			;go try to get default path.

* Setup the Clip Directory Default
	DUMPMSG	<SETING UP THE CLIP TYPE PATH>
	move.l	#'CLIP',d0			;file type
	lea	ClipDir,a0
	bsr	SetupPath			;go try to get default path.
	
* Setup the Font Directory Default
	DUMPMSG	<SETING UP THE FONT TYPE PATH>
	move.l	#'FONT',d0			;file type
	lea	FontDir,a0
	bsr	SetupPath			;go try to get default path.

* Setup the ARexx Directory Default
	DUMPMSG	<SETING UP THE REXX TYPE PATH>
	move.l	#'REXX',d0			;file type
	xref	SIProcess_DIR
	lea	SIProcess_DIR,a0
	bsr	SetupPath			;go try to get default path.
	
*find end of string
1$	tst.b	(a0)+				;loop until null
	bne	1$
	lea	-1(a0),a0			;back over null

*is it a :
	cmp.b	#':',-1(a0)
	beq	2$
*is it a /
	cmp.b	#'/',-1(a0)
	beq	2$
	move.b	#'/',(a0)+				
2$

*add tprexx to it
	xref	TPREXX
	lea	TPREXX,a2
3$	move.b	(a2)+,(a0)+
	bne	3$	

	lea	SIProcess_DIR,a0
	DUMPMEM	<SIProcess>,(A0),#64	

	rts

***
*
* SetupPath(Type,StrPtr)
*	    d0   a0	
***
	xdef	SetupPath
SetupPath:
	movem.l	d0-d7/a0-a6,-(sp)	
*	move.l	#'FRAM',d0			;file type
	move.l	a0,a1				;output path to a1 str
	move.l	#1,d1				;path number 
	xjsr	GetDefaultPath			;go try to get default path.
	tst.l	d0
	beq	NullPath			;if no new path just exit
	move.l	d0,a0
	DUMPMEM	<path>,(A0),#64
1$	move.b	(a0)+,(a1)+			;copy path
	bne	1$	
NullPath
	movem.l	(sp)+,d0-d7/a0-a6	
	rts


	xdef	_B2st_rx
_B2st_rx:
*	xjsr	Move4Bit2Red
	xjsr	Copy2AlphaPlanes
	rts



_Fa24_rx: ;fail/quit if not in 24 bit mode, no buffers
	tst.l	Datared_(BP)	;rgb array for big picture?
	;beq	_Quia_rx	;ask for quit
	beq	_Quit_rx	;quit, but immediately, like...	
	rts			;ok, no problem


_Fu24_rx: ;fail/quit if not in 24 bit mode, no buffers
	xref UnDored_
	tst.l	UnDored_(BP)	;red-rgb array for undo buffer?
	;beq	_Quia_rx	;ask for quit
	;beq	_Quit_rx	;quit, but immediately, like...	
	bne.s	9$
	st	FlagQuit_(BP)
	xjsr	UnDoErrRtn	;canceler.asm requester for "no memory..."
9$
	rts			;ok, no problem

_Ke24_rx: ;keep 24 bit buffers in between runs...turn on once...
	xref FlagKeep24_	;don't delete 24 bit buffers from toaster/switcher
	st	FlagKeep24_(BP)
	rts

_Al24_rx:	;allocate 24bit rgb buffers....
	tst.l	Datared_(BP)		;june2690
	bne.s	90$			;do nothing if rgbs already there

	moveq	#0,d0
	moveq	#0,d1
	move.w	BigPicWt_W_(BP),d0
	move.w	BigPicHt_(BP),d1

	xjsr	AllocRGB		;rgbrtns.asm
	bne.s	99$
	st	FlagDisplayBeep_(BP)
90$	rts

99$:	;continue with clear screen, WANT COLOR 0 0 0

_Clrb_rx:	;label added SEPT011990...clear to BLACK action code is new

	move.l	Paintred_(BP),-(sp)	;save current paint color
	move.l	Paint8red_(BP),-(sp)	;11DEC91 red&green
	move.w	Paint8blue_(BP),-(sp)	;11DEC91
	move.l	#0,Paintred_(BP)	;stuff black, really
	move.l	#0,Paint8red_(BP)		;11DEC91
	move.w	#0,Paint8blue_(BP)		;11DEC91
	bsr Prgb_quick	;internal call, from "Al24"....setup specific color
	bsr.s	_Clrs_rx	;CLeaR Screen
	move.w	(sp)+,Paint8blue_(BP)	;11DEC91
	move.l	(sp)+,Paint8red_(BP)	;11DEC91 red&green
	move.l	(sp)+,Paintred_(BP)	;save current paint color
	bsr Prgb_quick	;internal call, from "Al24"....setup specific color
	rts

_Apw1_rx:	;Arexx wait pointer on
	xjsr	SetAltPointerWait	;non-interruptable sleep cloud AUG311990
;;	xjsr	SetPointerWait			;SEP041990
	rts

_Apw0_rx:	;Arexx wait pointer off	
;	xjsr	AproPointer	
	xjsr	ResetPointer
;	xjsr	FixPointer
	rts



_Clrs_rx:	;CLeaR Screen
;AUG281990;		;flag all lines as "to be rendered" JULY311990
;AUG281990;	lea	SolLineTable_(BP),a0
;AUG281990;	xjsr	FreeOneVariable		;resets so "all lines are replotted" in composite

		;re-instated AUG291990....since PutRGB (RGBRtns.asm)
		;...checks FlagMenu, and menu is still displayed...
		;flag all lines as "to be rendered" JULY311990
	lea	SolLineTable_(BP),a0
	xjsr	FreeOneVariable		;resets so "all lines are replotted" in composite

	xjsr	SetAltPointerWait	;non-interruptable sleep cloud AUG311990

 	xjsr	ReDoHires		;removes/replaces menu background on user display AUG311990

	cbsr	SaveUnDo
	tst.b	FlagCutPaste_(BP)
	beq.s	95$
	PEA	_CopyScreenSuper(pc)	;corrects 'real picture' for cutpaste
95$	xjmp	ClearScreen		;DlvrScr.o

_Coor_rx:	;coord flag flip
	lea	FlagCoord_(BP),a0
	tst.b	(a0)
	bne.s	_Coof_rx	;was "on", turn "off", else turn on
_Coon_rx:	;coords on
	st	FlagCoord_(BP)
	bra.s	eacoor
_Coof_rx:	;set coord display off
	sf	FlagCoord_(BP)
eacoor:
GadRefRTS:	;sup gadget refresh flag and 'rts'
	st	FlagNeedGadRef_(BP)	;causes redohires->updatemenu

;july071990;debugging...; ifc 't','f'
	rts
_Debu_rx:
	xref WindowPtr_
	xref ToolWindowPtr_
	xref GWindowPtr_

	move.l	WindowPtr_(BP),d0
	beq.s	noports
	move.l	d0,a0
	move.l	wd_WindowPort(a0),d0
	move.l	ToolWindowPtr_(BP),d1
	beq.s	noports
	move.l	d1,a1
	move.l	wd_WindowPort(a1),d1
	move.l	GWindowPtr_(BP),d2
	beq.s	noports
	move.l	d2,a2
	move.l	wd_WindowPort(a2),d2

	;suba.l	a3,a3
	;tst.l	MP_SIGTASK(a3,d0.l)
	;bne.s	calldebug
	;tst.l	MP_SIGTASK(a3,d1.l)
	;bne.s	calldebug
	;tst.l	MP_SIGTASK(a3,d2.l)
	;;bne.s	calldebug
	;beq.s	noports
calldebug:
	;?;CALLIB	Exec,Debug
;no need now...july101990;	xjsr DebugMe	;debugrtns.asm
noports

	;AUG071990...debugger test
	st	FlagNeedText_(BP)
	xjmp	DisplayText
	;rts

;july071990;debugging...;  endc
drts:	rts

_Dlva_rx:	;deliver ascii,  count line# r g b r g b r g b ...
	bsr	grab_arg_a0	;get a0 ptr ascii command
	beq.s	drts
	lea	4(a0),a0	;skip past 4char cmd//ascii action code
	move.l	a0,a4
	move.l	a4,DlvrPtr_(BP)	;stash converted back in place over msg
	bsr	_cva2i	;main.o	;ascii to int, result in D0
	tst.L	d0
	bmi.s	drts	;none converted

	move.w	d0,d1
	and.w	#~31,d0
	cmp.w	d0,d1
	bne.s	drts		;must be even #32

	move.w	d0,DlvrCount_(BP)
	bsr	_cva2i
	tst.L	d0
	bmi.s	drts		;none conv'd
	move.w	d0,DlvrLine_(BP)
	move.w	DlvrCount_(BP),d4
	subq	#1,d4		;count-1 for db' type loop
dlcvloop
	bsr	_cva2i
	tst.L	d0
	bmi.s	9$
	and.w	#%0000001111111111,d0	;be nice'n ensure tops
	move.w	d0,(a4)+	;red
	bsr	_cva2i
	tst.L	d0
	bmi.s	9$
	and.w	#%0000001111111111,d0	;be nice'n ensure tops
	move.w	d0,(a4)+	;gr
	bsr	_cva2i
	tst.L	d0
	bmi.s	9$
	and.w	#%0000001111111111,d0	;be nice'n ensure tops
	move.w	d0,(a4)+	;bl
	dbf	d4,dlcvloop
9$
	xjmp	DlvrRGB

_Dlvb_rx:	;deliver binary, args are binary words
	;bug fix to prevent "quitting" from hanging DigiView 
	;...while DigiView is sending a picture
	sf	FlagQuit_(BP)

	bsr	grab_arg_a0
	beq.s	9$
	lea	4(a0),a0	;skip past 4char cmd//ascii action code
	move.w	(a0)+,d0	;binary word from message
	move.w	d0,d1
	and.w	#~31,d0
	cmp.w	d0,d1
	bne.s	9$		;must be even #32
	move.w	d0,DlvrCount_(BP)	;#pixels to 'deliver'
	move.w	(a0)+,DlvrLine_(BP)	;line#
	move.L	a0,DlvrPtr_(BP)		;ptr to 3wordsper pixel
	xjmp	DlvrRGB
9$	rts


FindCodedGadget: MACRO ;CALL D0=actcode RTNS a0=gadget ptr, Z flag, destroys d1
	bsr	_FindGadget	;tool.code.i
	ENDM


_Pick_rx:	;turn on/off pick mode
	DUMPMSG	<PICK>
	tst.b	FlagPick_(BP)		;already picking?
	bne.s	_EndPick		;yeah...bye
	st	FlagPick_(BP)		;try turning it on ok?
	move.l	GWindowPtr_(BP),A0
	move.l	wd_Pointer(A0),A0
	lea	PointerPickWhat_data,a1
*	cmp.l	A0,a1			;'pick' pointer setup for hires?
*	beq.s	_EndPick		;yeah...pick//pick "really turns us off,man"
	xjmp	SetPointerPickWhat
_EndPick:
	xjmp	EndPick			;mousertns.o
 	rts
;	rts


 ifeq	1
_Ccto_rx:	;"copy color to"
	move.l	GWindowPtr_(BP),A0
	move.l	wd_Pointer(A0),A0
	lea	PointerTo_data,a1	;go pc relative, save on loading (not absolute)
	cmpa.l	a1,A0			;"To" pointer-from-window ?
	beq.s	clear_copy_state
	xjmp	SetPointerTo		;say "copy color TO" where?
clear_copy_state:
	;cbra	ResetPointer
	xref 	ThisActionCode_
	move.l	#0,ThisActionCode_(BP)	;02FEB92
_ClearPointer:
	xjmp	ClearPointer		;pointers.o
 endc

_Ccto_rx:	;"copy color to"
*	move.l	GWindowPtr_(BP),A0
*	move.l	wd_Pointer(A0),A0
*	lea	PointerTo_data,a1	;go pc relative, save on loading (not absolute)
*	cmpa.l	a1,A0			;"To" pointer-from-window ?
	xjsr	SetPointerTo		;say "copy color TO" where?
	st	FlagCopyColor_(BP)
	rts	

	

	;process the Rub Gadget
	;note: wont get here (gadget will be disabled) whene'r
	;  	there is no alternate screen (called Cut{Window,BitMap,etc})
_Rubt_rx:	;rub thru
	moveq	#7,d0		;"Real" paint number ("normal//Pmcl)
	moveq	#5,d1		;menu item # for text
	bsr	_pm_continue	;setup "paintname rubthru"
_Rubi_rx:			;rub thru ON (internal only)
	st	FlagRub_(BP)
	rts
 

_Aaof_rx:	;anti alias OFF
	lea	FlagAAlias_(BP),A0	;flag to affect
	sf	(a0)			;anti-alias OFF
	move.l	#'Aali',d0		;action code for "AntiAlias"
	bsr.s	setgad_fromflag ;a0=flag adr, d0=action code in gadget to find
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'

_Aaon_rx:	;anti alias ON
	lea	FlagAAlias_(BP),A0	;flag to affect
	st	(a0)			;anti-alias ON
	move.l	#'Aali',d0		;action code for "AntiAlias"
	bsr.s	setgad_fromflag ;a0=flag adr, d0=action code in gadget to find
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'

_Aali_rx:	;anti alias
	lea	FlagAAlias_(BP),A0	;flag to affect
 ifc 't','f' ;march21'89 to enable 'aali flip code' for keyboard
		;save/restore gadref flag, dont flippit in subr
	move.b	FlagNeedGadRef_(BP),d0
	move.w	d0,-(sp)
	bsr.s	setflag_thengad	;set flag based on gadget on/off
	move.w	(sp)+,d0
	move.b	d0,FlagNeedGadRef_(BP)
	rts
  endc
	tst.b	(a0) ;flippit
	seq	(a0)			;anti-alias ON
	move.l	#'Aali',d0		;action code for "AntiAlias"
	bsr.s	setgad_fromflag ;a0=flag adr, d0=action code in gadget to find
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'

setflag_thengad:	;flips flag (a0=flag adr), finds/sets gadget accord
	;SETS FLAG BASED ON GADGET (A0=Adr of Flag, D0=actioncode of Gadget)
	tst.b	(a0)
	seq	(a0)	;flippit
setgad_fromflag:	;a0=flag adr, d0=action code in gadget to find
	move.l	a0,A2		;save "flag var adr" in a2
	FindCodedGadget		;destroys d1 returns a0=gadget ptr, ZERO flag
	beq.s	enda_sgf	;gadget with this userdata field not found
	move.w	gg_Flags(a0),D0
	tst.b	(a2)		;(next branch with d0=flag valu frm gadget)
	beq.s	setup_sboff	;branch if should be off, else ensure on
	or.w	#SELECTED,D0	;always set selected status
	bra.s	updgad		;d0=desired flags, go update gadget
setup_sboff:	;gadget should be off, ensure that's so.
	and.w	#~SELECTED,D0	;ensure any except selected bit
updgad:	cmp.w	gg_Flags(a0),D0	;did we change it?
	sne	FlagNeedGadRef_(BP)
	move.w	d0,gg_Flags(a0)
enda_sgf:
	rts
;--------

_Flon_rx:	;flood mode ON
	move.b	#-1,FlagFlood_(BP)	;sets NE flag
	bra.s	contfl

_Flof_rx:	;flood mode OFF
	move.b	#0,FlagFlood_(BP)	;flag to affect, sets ZERO flag
	bra.s	contfl
_Floo_rx:	;flood mode FLIP (gadget)
	lea	FlagFlood_(BP),A0	;flag to affect
	tst.b	(a0)
	seq	(a0)
contfl	bne.s	9$			;was on, now OFF, no change other modes
	tst.l	FlagCirc_(BP)		;any 'modes':circ,line,curv,rect ?
	bne.s	9$			;yep, else if no modes then...
	st	FlagBSmooth_(BP)	;turn on smoothing (helps fill)
9$	st	FlagNeedGadRef_(BP)	;refresh in case from key or elsewhere
	bra	_EndCutPaste
	;rts

_Rdit_rx:	;flip random dither
	lea	FlagDitherRandom_(BP),A0	;flag to affect
	lea	FlagDither_(BP),A1	;flag to affect
	bra.s	mute2		;mutual exclude dither buttons

_Dith_rx:	;flip matrix dither
	lea	FlagDither_(BP),A0	;flag to affect
	lea	FlagDitherRandom_(BP),A1	;flag to affect
mute2:	tst.b	(a0)
	seq	(a0)		;flip the flag
	bne.s	affectpaint	;was on (flipped) now off
	sf	FlagDither_(BP)
	sf	FlagDitherRandom_(BP)
	st	(a0)		;this only allows current one on

affectpaint:
	tst.b	(a1)			;'other' flag on, too?
	;seq	FlagNeedGadRef_(BP)	;sets flags if newly turned on dither
	bne.s	1$
	st	FlagNeedGadRef_(BP)	;set flags if newly turned OFF dither
1$
	xjmp	InitDetermineRtn ;determine.o, flagdither,colorzero,ponly
	;rts

;may13;_Nham_rx:	;No Ham, (palette only) gadget
;may13;	not.b	FlagPOnly_(BP)	;flag to affect
;may13;	bsr.s	affectpaint	;(ask for gadget refresh), new determine mode
;may13;		;"fall thru" and re-show palette (without ham-mod, of course)

_Czer_rx:	;color zero
		;MAY19 late
	xjsr	RemoveHGadgets	;tool.code.i, remove ham tool gadgets
				;note: mainloop->suphamgads replaces ok

	cbsr	HideToolWindow
	st	FlagFrbx_(BP)	;want 'scr to front' apro time
	lea	FlagColorZero_(BP),A0	;flag to affect

	;bsr	setflag_thengad	;set flag based on gadget on/off
		;MAY19...late
	tst.b	(a0)
	seq	(a0)	;flippit



	;bsr.s	_CreateDetermine	;redo palette tables WITHOUT color zero
	;;xjmp	UpdatePalette
	;;st	FlagRefHam_(BP)
	;rts

_CreateDetermine:	;redo palette tables WITHOUT color zero
	xref FlagCDet_
	st	FlagCDet_(BP)	;"ask for" next subr
	xjmp	CreateDetermine	;redo palette tables WITHOUT color zero
	;rts

_Bsmo_rx:	;bsmooth gadget routin
	lea	FlagBSmooth_(BP),a0	;if flag brush smoothing...
	;JULY171990;bra.s	do_mutex
	tst.b	FlagToast_(BP)		;1x mode?
	beq.s	do_mutex
	sf	FlagFlood_(BP)		;disable flood, here, in 1x mode JULY171990
	bra.s	do_mutex

_Doty_rx:
	bsr	_EndCutPaste
	clr.L	FlagCirc_(BP)	;clear all drawing modes
	lea	FlagBSmooth_(BP),a0	;a0=arg for subr
	sf	(a0)		;smoothing flag off, too
	move.l	#'Bsmo',d0	;action code for "Be SMOoth"
	;bra	setgad_fromflag ;a0=flag adr, d0=action code in gadget to find
	bsr	setgad_fromflag ;a0=flag adr, d0=action code in gadget to find

	tst.b	FlagToast_(BP)		;1x mode?
	beq	GadRefRTS
	sf	FlagFlood_(BP)		;disable flood, here, in 1x mode JULY171990
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'

 XDEF _Drci_rx	;draw circles gadget routine XDEF'd SEP211990...for mousertns/linedraw kludge
_Drci_rx:	;draw circles gadget routine
	lea	FlagCirc_(BP),a0
	bra.s	do_mutex		;reset//redisplay hires tools

_Drar_rx:	;draw arc gadget
	lea	FlagCurv_(BP),a0
	bra.s	do_mutex

  IFC 'F','EXTRAS'

_Damo_rx: ;draw airbrush - use mouse to specify a 2 endpoints (rectangle)
	xref FlagSetAir_
	st	FlagSetAir_(BP)
;	sf	FlagAir_(BP)		;next few instruction set airbrush ON
	xjsr	AirBrushoff

_Drai_rx:	;draw airbrush gadget (toggles flag)
	lea	FlagAir_(BP),a0
	tst.b	(a0)
	;seq	(a0)
	;bra	GadRefRTS		;sup gadget refresh flag and 'rts'
	bne.s	_Daof_rx

_Daon_rx:	;draw airbrush mode ON
;	st	FlagAir_(BP)
	xjsr	AirBrushon	
	
	
	sf	FlagBSmooth_(BP)	;turn OFF connected-brushes
	;bra	GadRefRTS		;sup gadget refresh flag and 'rts'
	bsr	_Doty_rx
	bra	_Dotb_rx		;force single dot
	
	

_Daof_rx:	;draw airbrush mode OFF
;	sf	FlagAir_(BP)
	xjsr	AirBrushoff
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'
  ENDC
_Drre_rx:	;draw rectangles
	lea	FlagRect_(BP),a0
	;JULY171990;bra.s	do_mutex
	tst.b	FlagToast_(BP)		;1x mode?
	beq.s	do_mutex
	sf	FlagFlood_(BP)		;disable flood, here, in 1x mode JULY171990
	bra.s	do_mutex

_Drrf_rx: ;filled rectangles (1x mode tools) july021990
	lea	FlagRect_(BP),a0
	st	FlagFlood_(BP)
	bra.s	do_mutex ;if flagrect is set now, then clear the other 2 modes
	;rts

  IFC 'F','EXTRAS'

_Drcl_rx:	;draw curved lines DIGIPAINT PI
	lea	FlagLine_(BP),a0	;kludge...not quite there yet
	bSR.s	do_mutex ;if flagrect is set now, then clear the other 2 modes
	st	FlagClin_(BP)	;turn ON curved lines, too
	rts
  ENDC

_Drln_rx:	;draw lines
	lea	FlagLine_(BP),a0
	;bra.s	do_mutex ;if flagrect is set now, then clear the other 2 modes

do_mutex:	;DO MUTUAL EXCLUDE only 1 drawing mode/time
	pea	_Fiof_rx(pc)	;fill mode off...DigiPaint PI
	move.l	a0,-(sp)	;a0=flagptr, d0='action code'
;setflagandgad:	;sets flag and gadget on
	st	(a0)		;set flag
	move.l	a0,A2		;save "flag var adr" in a2
	FindCodedGadget		;destroys d1 returns a0=gadget ptr, ZERO flag
	beq.s	enda_sgaf	;gadget with this userdata field not found
	move.w	gg_Flags(a0),D0
	tst.b	(a2)		;(next branch with d0=flag valu frm gadget)
	beq.s	setup_xsboff	;branch if should be off, else ensure on
	or.w	#SELECTED,D0	;always set selected status
	bra.s	updxgad		;d0=desired flags, go update gadget
setup_xsboff:	;gadget should be off, ensure that's so.
	and.w	#~SELECTED,D0	;ensure any except selected bit
updxgad	cmp.w	gg_Flags(a0),D0	;did we change it?
	beq.s	enda_sgaf	;no change, it WAS on
	move.w	d0,gg_Flags(a0)
	st	FlagNeedGadRef_(BP)
enda_sgaf:
	clr.L	CircRadiusSq_(BP)	;the displayed/in use radius
	sf	FlagClin_(BP)		;clear "curved lines"
	sf	FlagBSmooth_(BP)	;clear all 'mode' flags
	clr.l	FlagCirc_(BP)		;clrs all modes:circ,line,curv,rect
	move.l	(SP)+,a0		;current 'mode flag' adr
	st	(a0)			;turn it back on (all others off)


	;march26'89;sf	FlagBitMapSaved_(BP)	;prevents (assumption) brush on-redraws
	xref FlagNeedRepaint_
	tst.b	FlagNeedRepaint_(BP)	;brushstroke in progress?
	bne.s	332$			;ontinue brushstroke...
	sf	FlagBitMapSaved_(BP)	;prevents (assumption) brush on-redraws
332$


	st	FlagNeedGadRef_(BP)

	tst.b	FlagCutPaste_(BP)
	beq.s	33$		;cp not 'on'
	tst.l	PasteBitMap_Planes_(BP)	;have a brush now?
	bne	_EndCutPaste	;end cutpaste (have a brush) when mode sel'd
33$
	rts

_Tron_rx:
	sf	FlagSkipTransparency_(BP)
	bra.s	tran_cont
_Trof_rx:
	st	FlagSkipTransparency_(BP)
	bra.s	tran_cont

_Tran_rx:	;transparent switch
	lea	FlagSkipTransparency_(BP),A0	;flag to affect
	;moveq	#0,d0	;no action code, just flip flag
	;bsr	setflag_thengad ;SETS FLAG BASED ON GADGET (A0=Adr of Flag, D0=Adr of Gadget)
	tst.b	(a0)
	seq	(a0)	;flippit
tran_cont
		;if the pointer = "To" word, set current color as transparent
	move.l	GWindowPtr_(BP),A0
	move.l	wd_Pointer(A0),A0
	lea	PointerTo_data,a1	;go pc relative, save on loading (not absolute)
	cmpa.l	a1,A0		;scissors = pointer-from-window ?
	bne.s	not_ptotransp
	move.w	Paintred_(BP),Transpred_(BP)	;red.b+green.b
	move.b	Paintblue_(BP),Transpblue_(BP)
	sf	FlagSkipTransparency_(BP)	;force flag on if 'copy to'
	st	FlagPrintRgb_(BP)	;trace out
	;cbra	ResetPointer
	cbra	ClearPointer
not_ptotransp:
	st	FlagNeedGadRef_(BP)	;need new menu status? "*" on transp
endof_transp:
	rts


NewMag


 ifeq 1
	move.l	WindowPtr_(BP),d0
	beq.s	1$
	move.l	d0,a0
	CALLIB  Intuition,CloseWindow
1$	clr.l	WindowPtr_(BP)

	move.l	ScreenPtr_(BP),a0
	xjsr	CloseScreenRoutine
 endc
	bsr	_Clsc_rx
;;	bsr	_Opsc_rx
;;	xjsr	WholeHam
	rts


	xref	 FlagMagnify_
_Magn_rx:	;magnify gadget
	tst.b	FlagMagnify_(BP)	;MAY12
	bne.s	_Endm_rx
	tst.b	AirBrushOn_(BP)
	bne	99$
	cbsr	UnShowPaste		;cutpaste.o, remove brush, dbl buffer	****!!! is this what causes the crash in aa paint? 
	xref	FlagCheckBegMag_	;may12'89 LATE
	st	FlagCheckBegMag_(BP)	;may12'89 LATE
99$
	rts


_Endm_rx: 	;end magnify mode
;_EndMagnify
	xref FlagCheckKillMag_
	st	FlagCheckKillMag_(BP)	;may11'89 LATE
	RTS

	;;;;;xjmp	EndMagnify

_Scis_rx:	;scissors/cut gadget
	tst.b	AirBrushOn_(BP)
	bne	99$
	tst.b	FlagCtrl_(BP)	;ON ctrl scr?
	beq.s	1$
	st	FlagNeedGadRef_(BP)	;digipaint pi...airb, etc imagery off
1$	xjmp	InitCutPaste		;cutpaste.o
99$
	rts

_Whsc_rx:	;Whole Screen button
	tst.b	FlagCutPaste_(BP)	;in 'scissors' mode? wanna cut screen?
	beq.s	1$
	cbsr	SaveUnDo		;copy screen, so dont get an 'undo'
1$
		;MAY23...wholescreen func + brush...no go
	tst.l	PasteBitMap_Planes_(BP)	;HAVE a brush?
	beq.s	9$			;no brush, continue ok
	tst.b	FlagStretch_(BP)	;MAY25
	bne.s	9$
	;cmp.b	#6,PaintNumber_(BP)	;'range' mode?
	cmp.b	#6,EffectNumber_(BP)	;'range' mode?, digipaint pi
	beq.s	9$
	st	FlagDisplayBeep_(BP)
	rts

9$
	xjsr	SetEntireScreenMask	;memories.o, whole screen
		;...fall thru and 'redo' cut/paste/stretch/paint/whatever
	tst.l	PasteBitMap_Planes_(BP)	;HAVE a brush? MAY27
	beq.s	_Redo_rx		;MAY27
	bra	_Again			;MAY26
	;rts				;MAY26

	xref	TCBuff01
	xref	ITTCBuff01

_Redo_rx:	;redo//again//repaint gadget
	DUMPMSG	<!!!!  Redo  !!!>

	tst.b	AirBrushOn_(BP)				;cant redo airbrush!!!
	bne.s	555$
	tst.l	ScreenPtr_(BP)	;have big pic? digipaint pi
	bne.s	001$
555$
	rts			;no screen....outta here
001$
;	move.l	GWindowPtr_(BP),A0	;scissors sprite lives on gadget window ptr
	xref	CurrentPointer_
	move.l	CurrentPointer_(BP),A0
	lea	PointerCut_data,a1	;RELOCATABLE YUCKEROO
	cmpa.l	a1,A0		;scissors = pointer-from-window ?
	DUMPMSG	<A0-WINDOWPRT A1-PointerCut_data>
	bne	SKP1		;yes....have scissors, hit "again"
	st	FlagText_(BP)	;disables CUT from flood+extra undo, etc
	DUMPMSG	<CUT!>
	xjsr	Cut		;...first go cut last brush ("again" mask)
	xjsr	UnDoRGB		;fixup "Scis","Redo"...rgb-wise, only ;AUG121990
	sf	FlagText_(BP)
	rts
SKP1:
	DUMPMSG	<SKP1>		;not scissors...cutpaste mode?
;	tst.b	FlagCutPaste_(BP)
	tst.L	PasteBitMap_Planes_(BP)	;carrying a brush?
	beq	SKP2
	DUMPMSG	<PASTE AGAIN>
	xjmp	Paste_Again	;cutpaste.o
SKP2:
_Again
*	xjmp	SaveBM		;TESTING!!!
*	xjmp	MakeVBar	;TESTING!!!

	tst.b	AirBrushOn_(BP)
	bne.s	555$	
	xjmp	Again		;...repaint (with new color/rub/whatever)
555$
	rts


_Alph_rx:
        tst.b   FlagAlphapaint_(BP)
        bne     100$
	sf	StencilFlag_(a5)

	tst.b	FlagSwaped_(BP)		;on screen 2?
	bne	99$			;skip swap if on screen 2
        bsr     _Swap_rx
99$
*       st      FlagWholeHam_(BP)    
100$	
*	xjsr	OpenLRScreen	
	xjsr	OpenAlphaScreen		;open or close the alpha screen! main.asm
	tst.b	FlagAlphapaint_(BP)
	bne	101$
	bsr	_Swap_rx	
	st	FlagWholeHam_(BP)	;need 'whole ham screen' redraw from rgb	
	moveq   #0,d0
	move.b  FrameBufferBank_(BP),d0
	xjsr    _SetFrameBufferBank
101$
	rts	


_Frbx_rx:	;front box gadget
	st	FlagFrbx_(BP)		;asks mainloop to arrange scr's
	st	FlagToolWindow_(BP)
frrts	rts

ScreenArrange:
;MAY31;	xjsr	AreWeAlive
;MAY31;	beq	frrts 		;just outta here...march28'89;_Babx_rx
reallyScrArrange:	;MAY28, local call only, ugad_rx
	tst.b	FlagFrbx_(BP)	;flag sup? asked for re-arrange?
	beq.s	frrts
	sf	FlagFrbx_(BP)	;clear out 'ask for front' flag, gonna do it

	tst.b	FlagPick_(BP)
	beq	notpicking
	
		;handle 'magnify screen' for pick mode
	xref LastM_Window_		;"window of last message"
	xref MWindowPtr_
	move.L	LastM_Window_(BP),d0	;"window of last message"
	beq.s	2$			;no window for last msg...wasnt magnify
	cmp.l	MWindowPtr_(BP),d0
	beq.s	1$
	move.l	MScreenPtr_(BP),d0	;magnify scr
	beq.s	2$			;none? wha?
	move.l	d0,a0
	xjmp	IntuScreenToBack ;;JMPLIB	Intuition,ScreenToBack	;end here, w/mag scr in BACK for pick
	;rts
1$
	move.l	MScreenPtr_(BP),d0	;magnify scr
	beq.s	2$			;none? wha?
	move.l	d0,a0
	xjsr	IntuScreenToFront	;CALLIB	Intuition,ScreenToFront
	move.l	XTScreenPtr_(BP),d0	;hires scr (#display)
	beq.s	2$			;none? wha?
	move.l	d0,a0
	xjmp	IntuScreenToFront	;JMPLIB	SAME,ScreenToFront
	;rts
2$

	tst.b	FlagPale_(BP)	;palette tools displayed?
	bne.s	notpicking	;nothing special...

	
	move.l	TScreenPtr_(BP),A0	;hamtools
	bsr	Isle_ScrToFront
	xref SkScreenPtr_
	move.l	SkScreenPtr_(BP),A0	;little rgb tools (if any)
	bra	Isle_ScrToFront
	;rts
notpicking:

	tst.b	FlagToolWindow_(BP)
	beq	_HideToolWindow

	;NO NEED?;move.l	IntuitionLibrary_(BP),a6
	move.l	FirstScreen_(BP),d0	;ib_FirstScreen(a6),d0
	beq.s	frt_not_hr		;march22'89, i-base blown? no 1stscr?

	cmp.l	TScreenPtr_(BP),d0	;ham tools screen
	beq.s	frt_not_hr

	cmp.l	XTScreenPtr_(BP),d0	;hires screen
	bne.s	frt_not_hr
		;here we know that the hires screen is in front NOV91
	tst.b	FlagMenu_(BP)		;set when menu displayed (main.msg)
	bne	frrts ;june13...no action when menu...menuarr			;hires->front
	move.l	d0,a0			;hires (1st) scr
	move.l	(a0),d0			;D0=screen after hires
	beq.s	frt_not_hr		;hires in back? march23'89

	tst.b	FlagSizer_(BP)	;SIZER has HAMTOOLS not visible?
	beq.s	1$		;not sizer else...
09$	bsr.s	menuarr		;hamtools->back, re-enabled march22'89
	bra	one_tf		;hires->front
1$
	tst.b	FlagRequest_(BP)	;fileopen, "pale from file""hires"etc
	;march22'89;bne.s	two_tf		;shows'em all...just really need hamtools
	;MAY12;bne.s	09$
	bne.s	one_tf		;hires->front MAY12

	;june16;tst.W	FlagOpen_(BP)	;filerequester load/save pic/brush/font
	;june16;bne.s	09$

	tst.b	FlagPrintReq_(BP)	;SIZER has HAMTOOLS not visible?
	bne.s	09$

	cmp.l	TScreenPtr_(BP),d0	;is the hamtools scr just AFTER hires?
	bne.s	two_tf		;mag to front, too...
		;here we know front=hires, then hamtools....NOV91
	move.l	d0,a0		;tscreenptr
	move.l	(a0),d0		;next screen after ham tools
	beq.s	two_tf		;no scr after hamtools...all to front march23'89
	tst.l	MScreenPtr_(BP)	;mag scr exist?
	beq.s	no_magscr

	tst.B	FlagMagnifyStart_(BP)	;magnify 'locked' yet?
	bne.s	89$
	move.l	MScreenPtr_(BP),a0	;keeping magnify in front of bigpic
	bra.s	Isle_ScrToFront		;...but 'behind' hamtools, hirestools
	;rts

89$:	cmp.l	MScreenPtr_(BP),d0
	beq.s	somerts		;hamtools->magnify...ok ok
	bra.s	two_tf

no_magscr
	cmp.l	ScreenPtr_(BP),d0
	beq.s	somerts
	;KILLS MENU, MENU RETURNS TO SWITCHER?;beq	_Quit_rx		;quit back to switcher NOV91
	bra.s	two_tf

frt_not_hr:				;front not hires (d0=front screen)
	tst.b	FlagMenu_(BP)		;set when menu displayed (main.msg)
	beq.s	no_menuarr
menuarr:
	move.l	TScreenPtr_(BP),a0	;menu time, move hamtools to back
	bra	Isle_ScrToBack
	;rts	;ScreenArrange

no_menuarr:
	cmp.l	TScreenPtr_(BP),d0	;ham tools in front?
	beq.s	one_tf
	move.l	ScreenPtr_(BP),A0
	cmp.l	a0,d0			;big pic in front?
	beq.s	three_tf
	bsr.s	Isle_ScrToFront		;force to front
three_tf:
	tst.b	FlagMenu_(BP)
	bne.s	one_tf			;skip hamtoolscr check when menu

two_tf:
	tst.l	MScreenPtr_(BP)
	beq.s	89$
	tst.B	FlagMagnifyStart_(BP)	;magnify 'locked' yet?
	bne.s	89$
	move.l	MScreenPtr_(BP),a0	;keeping magnify in front of bigpic
	bra.s	Isle_ScrToFront		;...but 'behind' hamtools, hirestools
	;rts

89$:	move.l	MScreenPtr_(BP),a0	;keeping magnify in front of bigpic
	bsr.s	Isle_ScrToFront		;...but 'behind' hamtools, hirestools
one_tf:	;KLUDGE....

	;dont arrange hamtools upon condition...june12...
	;june16;tst.l	FlagRequest_(BP)	;flags.b(request,sizer,open,save)
	tst.W	FlagRequest_(BP)	;flags.b(request,sizer) JUNE16
	bne.s	90$

	move.l	TScreenPtr_(BP),A0	;hamtools
	bsr.s	Isle_ScrToFront
90$


;;;may13'late;one_tf:
	move.l	XTScreenPtr_(BP),A0	;hires tools
	;april28;st	FlagNeedIntFix_(BP)	;"need interlace fix", re-arr scr's

Isle_ScrToFront:	;A0=*screen	;replacement for shorter code
	cmp.l	#0,A0
	beq.s	somerts

	sf	FlagNeedIntFix_(BP)	;no "need interlace fix" - APRIL28

	xjmp	IntuScreenToFront	;JMPLIB	Intuition,ScreenToFront
somerts	rts


_Clbx_rx:	;escape button, CLOSEBOX from (hires, magnify, sizer)
	DUMPMSG	<CloseBox>	
	tst.b	FlagRexxReq_(BP)		;user closing the file req so return the delayed message.
	beq	555$	
	sf	FlagRexxReq_(BP)		;turn off the ba ba flag.
;	CALLIB	Rexx,CreateArgstring
	move.l	RexxMsgRtnDelayed_(BP),a1
	move.l	#0,RexxMsgRtnDelayed_(BP)	;clearout delayed message ptr
	move.l	#0,rm_Result2(a1)
	move.l	#5,rm_Result1(a1)
	CALLIB	Exec,ReplyMsg		
555$	


;AUG281990;		;if 'composite display' is toggled on, turn it off...
;AUG281990;	tst.b	FlagViewComp_(BP)
;AUG281990;	bne	_Shcf_rx		;composite on? then just turn it off

		;MAY25...if magnify screen in front, then 'endm'
	move.l	IntuitionLibrary_(BP),a6
	move.l	MScreenPtr_(BP),d0
	beq.s	01$
	cmp.l	FirstScreen_(BP),d0	;ib_FirstScreen(a6),d0
	;beq	_Endm_rx	;wanna do '#'Endm'->Acode_(BP), but...
	bne.s	01$
	st	FlagCheckKillMag_(BP)	;may25;may11'89 LATE
	rts
01$

	tst.b	FlagSizer_(BP)
	bne	_Nsca_rx		;"new size cancel"

	tst.b	FlagRequest_(BP)
	beq.s	7$
	sf	FlagRequest_(BP)
	st	FlagNeedGadRef_(BP)
	xjmp	Close_Load_File		;filertns.o cancel fileload after pal'req
7$
	tst.b	FlagPrintReq_(BP)
	bne	_Pcca_rx		;print - cancel

	xjsr	ToggleToolWindow	;tool.code.i

	tst.W	FlagOpen_(BP)		;tests for save, too
	;bne.s	EndFileRequ
	beq.s	9$
	tst.b	FlagToolWindow_(BP)	;'flagtool' went to 'closed' stat?
	;may04;beq.s	EndFileRequ
	bne.s	9$		;tools visible, just show'em
	st	FlagToolWindow_(BP)
	bra	EndFileRequ
9$
	;;;;;;;xjmp	ToggleToolWindow	;tool.code.i MOVED HERE, AUG151990
	rts

_Tpik_rx:
	moveq	#0,d0
	move.w	MSG_MouseX_(BP),d0		;get mouse x on button 
*	asl.w	#1,d0
	xref	UserColors
	lea	UserColors,a0
	divu	#5,d0				;get cell number
	mulu	#3,d0				;get offset into usercolor list

	tst.b	FlagCopyColor_(BP)
	bne	NewCopyColor

	move.b	0(a0,d0),Paint8red_+1(a5)	;select color
	move.b	1(a0,d0),Paint8green_+1(a5)	
	move.b	2(a0,d0),Paint8blue_+1(a5)
	
	moveq.l	#0,d0
	move.b	Paint8red_+1(a5),d0
	lsl.w	#8,d0
	move.b	Paint8green_+1(a5),d0
	lsl.l	#8,d0
	move.b	Paint8blue_+1(a5),d0
	xjsr	WriteRGBSliders
	xjsr	DragCodeRGB_lite
;	xjsr	BuildPaletteBox
;	xjsr	PlotPaletteBox
	xjsr	ShowColor
*
*	move.l	wd_WScreen(a3),a3
*	lea	sc_RastPort(a3),a3
	xref	FlagColorMap_		;02FEB92...help w/2.0 sprite problem(?)
	st	FlagColorMap_(BP)	;02FEB92...help w/2.0 sprite problem(?)
	st	FlagGrayPointer_(BP) 	;usecolormap only does hires gray loadrgb4
	rts

	xdef 	KillCopyColor
NewCopyColor:
	move.b	Paint8red_+1(a5),0(a0,d0)	;select color
	move.b	Paint8green_+1(a5),1(a0,d0)	
	move.b	Paint8blue_+1(a5),2(a0,d0)
	xjsr	UCBarRGB
	xjsr	ViewBarHam
KillCopyColor:	
	xjsr	ClearPointer			;pointers.o
	sf	FlagCopyColor_(BP)		;turn off copy color
	xjsr	WriteUserPalette
	
	rts

_Gpik_rx:
	moveq	#0,d0
	move.w	MSG_MouseX_(BP),d0		;get mouse x on button 
	sub.w	#304/2,d0
	xref	Gray16
	lea	Gray16,a0
	divu	#5,d0				;get cell number
	mulu	#3,d0				;get offset into usercolor list

	move.b	0(a0,d0),Paint8red_+1(a5)	;select color
	move.b	1(a0,d0),Paint8green_+1(a5)	
	move.b	2(a0,d0),Paint8blue_+1(a5)
	
	moveq.l	#0,d0
	move.b	Paint8red_+1(a5),d0
	lsl.w	#8,d0
	move.b	Paint8green_+1(a5),d0
	lsl.l	#8,d0
	move.b	Paint8blue_+1(a5),d0
	xjsr	WriteRGBSliders
	xjsr	DragCodeRGB_lite
;	xjsr	BuildPaletteBox
;	xjsr	PlotPaletteBox
	xjsr	ShowColor
*
	xref	FlagColorMap_		;02FEB92...help w/2.0 sprite problem(?)
	st	FlagColorMap_(BP)	;02FEB92...help w/2.0 sprite problem(?)
	st	FlagGrayPointer_(BP) 	;usecolormap only does hires gray loadrgb4
	rts
	


_Babx_rx:	;back box gadget
	sf	FlagFrbx_(BP)		;screen re-arranger flag
	move.l	TScreenPtr_(BP),A0	;ham tools
	bsr.s	Isle_ScrToBack
	move.l	XTScreenPtr_(BP),A0	;hires tools
	bsr.s	Isle_ScrToBack
	move.l	TScreenPtr_(BP),A0	;ham tools
	bsr.s	Isle_ScrToBack
	move.l	MScreenPtr_(BP),a0	;magnify screen
	bsr.s	Isle_ScrToBack
	move.l	ScreenPtr_(BP),A0	;big pic
	bsr.s	Isle_ScrToBack

	cbsr	UnShowPaste		;cutpaste.o, remove brush, dbl buffer
	xjmp	SetLowerPriority	;go slower/background ALWAYS

Isle_ScrToBack:	;A0=*screen	;replacement for shorter code
	cmp.l	#0,A0
	beq.s	zqrts	;no screen, really
	xjmp	IntuScreenToBack	;JMPLIB	Intuition,ScreenToBack
zqrts	rts

	;If FlagOpen_(BP) or FlagSave_(BP) are set...
	;...and get a CancelGadget
	;...then cancel the save or load flags

EndFileRequ:	;arrive here when CloseBox & filenames shown
		;also....from dirroutines.o "dir not found"
	xref	FlagFontFirstTime_	;used to 'cd fonts:'
	sf	FlagFontFirstTime_(BP)
	sf	FlagFont_(BP)
	sf	FlagBrush_(BP)
	sf	DirnameBuffer_(BP)	;clears out dirname, in case sub-dir....AUG201990
	sf	FlagRexxReq_(BP)

;		;re-instated SEP201990
;		;SEP191990...bug fix for linedraw, etc.
;		;IF in 'drawing lines' mode
;		;...then reset for circles,
;		;...then reset back to line mode
;		;NOTE: IFFLoad clears 'open' status....so need this B4 test....
;	tst.b	FlagLine_(BP)
;	beq.s	011$
;	xjsr	DoInlineAction
;	dc.w	'Dr','ci'		;draw circles
;	;xjsr	ReDoHires		;tool.code.i
;	;xjsr	DoInlineAction
;	dc.w	'Ug','ad'
;	xjsr	DoInlineAction
;	dc.w	'Dr','ln'		;draw lines
;011$
	move.b	FlagOpen_(BP),d0	;set gadget refresh flag if open/save
	or.b	FlagSave_(BP),d0
	beq.s	9$			;filereq not open
	;or.b	d0,FlagNeedGadRef_(BP)	;need to fix/refresh gadgets(?)
	;or.b	d0,FlagFrbx_(BP)	;asks for 'screen arrange', too

	st	FlagNeedGadRef_(BP)	;need to fix/refresh gadgets(?)
	xjsr	AreWeAlive	;canceler.asm
	beq.s	88$
	st	FlagFrbx_(BP)
88$
	clr.W	FlagOpen_(BP)		;cancel Open-AND-Save status (2byte flags)
	st	FlagToolWindow_(BP)	;MAY12'89....see hamtools after filereq

	;march19'89...noneed?cancel usage?;xjmp	Close_Load_File	;filertns.o
9$:	rts

;AUG201990;	xdef ResetDirectory	;digipaint pi, ref'd in FileRtns after fontload
;AUG201990;ResetDirectory:	;reset to "last file/brush" dir when closing fonts
;AUG201990;	xjsr ReDirRoutine	;dirrtns, digipaint pi...force 'old' directory
;AUG201990;	xjmp DirRoutine	;dirrtns, digipaint pi...force 'old' directory
;AUG201990;	;rts

	xref	RexxMsgRtnDelayed_
	xref	SourceClipName
_Okls_rx:	;ok load/save button
;just don't allow empty filenames
	tst.b	FilenameBuffer_(BP)	;HAVE a filename?
	beq	okerts
1$
	xref	FlagRexxReq_
	tst.b	FlagRexxReq_(BP)
	beq	notrexxreq
	sf	FlagRexxReq_(BP)	;clear the flag.
	lea	FR_StrBuffer,a1

 ifeq	1
	lea	DirnameBuffer_(BP),a0
9$	move.b	(a0)+,(a1)+
	bne	9$	
	lea	-1(a1),a1		;back over null.
	lea	FilenameBuffer_(BP),a0
10$	move.b	(a0)+,(a1)+
	bne	10$	
 endc

	xref	current_dir_
	move.l	a1,d2
	move.l	current_dir_(BP),d1
	move.l	#92,d3
	CALLIB	DOS,NameFromLock
	
	lea	FR_StrBuffer,a1		;add filename to path	
555$	tst.b	(a1)+
	bne	555$	
	lea	-1(a1),a1		;back over null.
	cmp.b	#':',-1(a1)
	beq	666$
	cmp.b	#':',-1(a1)
	beq	666$
	move.b	#'/',(a1)+	
666$	
	lea	FilenameBuffer_(BP),a0
10$	move.b	(a0)+,(a1)+
	bne	10$	
;
	lea	FR_StrBuffer,a0
	moveq	#0,d0
	move.l	a0,a1			;count string for rexxarg	
12$	add.l	#1,d0
	tst.b	(a1)+
	bne	12$
	sub.l	#1,d0
	CALLIB	Rexx,CreateArgstring
	move.l	RexxMsgRtnDelayed_(BP),a0
	move.l	d0,rm_Result2(a0)
	move.l	#0,rm_Result1(a0)
	move.l	a0,a1
	CALLIB	Exec,ReplyMsg	
	bra	genda_save
	
notrexxreq
	tst.b	FlagSelDestClip_(BP)
	beq	notDestclipselect
	lea	FilenameBuffer_(BP),a0
	lea	DestClipName,a1

 ifeq 1		;removed not full path 091995
	lea	DirnameBuffer_(BP),a2
111$	move.b	(a2)+,(a1)+
	bne	111$
	lea	-1(a1),a1
 endc

115$	move.b	(a0)+,(a1)+
	bne	115$
	
	move.l	#DestClipPath,d2
	move.l	current_dir_(BP),d1
	move.l	#92,d3
	CALLIB	DOS,NameFromLock	
;	lea	DestClipPath,a1	
;	DUMPMEM	<DestClipPath>,(A1),#64

	move.l	#DestClipPath,d1
	move.l	#DestClipName,d2
	move.l	#100,d3
	CALLIB	SAME,AddPart

		
	lea	DestClipPath,a1
	DUMPBEM	<SELECTED A Dest CLIP>,(a1),#32	
	st	FlagNeedGadRef_(BP)	;need to fix/refresh gadgets
	sf	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)
	bsr	EndFileRequ	
	xref	FlagProcClip_
	tst.b	FlagProcClip_(BP)	
	beq	.notprocessing
	xjsr	ReDoHires
	bsr	BeginClipProcess
.notprocessing	
	rts
notDestclipselect
	tst.b	FlagSelClip_(BP)
	beq	notclipselect
	lea	FilenameBuffer_(BP),a0
	lea	SourceClipName,a1
 ifeq	1	
	lea	DirnameBuffer_(BP),a2
101$	move.b	(a2)+,(a1)+
	bne	101$
	lea	-1(a1),a1
 endc
105$	move.b	(a0)+,(a1)+
	bne	105$		

	move.l	#SourceClipPath,d2
	move.l	current_dir_(BP),d1
	move.l	#92,d3
	CALLIB	DOS,NameFromLock		
;	lea	SourceClipPath,a1
;	DUMPMEM	<SourceClipPath>,(A1),#64
	
	move.l	#SourceClipPath,d1
	move.l	#SourceClipName,d2
	move.l	#100,d3
	CALLIB	SAME,AddPart

	lea	SourceClipPath,a1
	xjsr	SourceClipRangeSet			;imagepro.asm120894


	DUMPBEM	<SELECTED A CLIP>,(a1),#32	
	st	FlagNeedGadRef_(BP)			;need to fix/refresh gadgets
	sf	FlagSelClip_(BP)
	bsr	EndFileRequ	
	rts
notclipselect	

	tst.w	FlagOpen_(BP)		;FileRequester set for Open-OR-Save?
	beq.s	genda_save
   	tst.b	FlagOpen_(BP)
	bne.s	Do_load
	xjsr	SetAltPointerWait	;indicate 'non-interrupt'
	cbsr	HideToolWindow
	sf	FlagSave_(BP)
 	xjsr	File_Save

;check for ':' or '/' in filename, if not, then do a new directory
	lea	FilenameBuffer_(BP),A0
	moveq	#60-1,d1		;maxlen filenamebuf (dbf)
otherdirloop:
	move.b	(A0)+,D0
	beq.s	noother			;endof this loop
	cmp.b	#':',D0
	beq.s	genda_save
	cmp.b	#'/',D0
	beq.s	genda_save
	dbf	d1,otherdirloop
noother:
	;AUG201990;bsr	_Dsel_rx 	;update our directory (want dironly?)
genda_save:
	bsr	EndFileRequ		;digipaint pi
	st	FlagNeedGadRef_(BP)	;need to fix/refresh gadgets
okerts:	rts

Do_load:
	xjmp	File_Load


	XREF	MS001
	XREF	MS002
HVTIEOFF:
	LEA	MS001,A1
	AND.L	#~MSISTIED,MS_FLAGS(A1)
	LEA	MS002,A1
	AND.L	#~MSISTIED,MS_FLAGS(A1)
	RTS

HVTIEON:
	LEA	MS001,A1
	OR.L	#MSISTIED,MS_FLAGS(A1)
	LEA	MS002,A1
	OR.L	#MSISTIED,MS_FLAGS(A1)
	RTS

 ifeq 1
_Usrg_rx:
	bsr	grab_srxarg
 endc		






_Hvof_rx:	;little button, 2way 'off'
*	lea	FUSoftEdgeGadget,a0		;removed the softedge button072794
*	bclr	#7,1+gg_Flags(a0)
	moveq	#0,d1		;#1=hor, #2=ver, #3=both, #0=none

	bsr	HVTIEON	
	tst.b	ShadeOnOffNum_(BP)
	beq	finish_hvs2
	move.w	StdPot0,LastShade0_(a5)
	move.w	StdPot1,LastShade1_(a5)
	bra	finish_hvs2
_Hvar_rx:
;	lea	FUSoftEdgeGadget,a0		;removed the softedge button072794
;	bset	#7,1+gg_Flags(a0)		;
	moveq	#3,d1		;desired type, both directions
	bsr	HVTIEOFF	
	bra.s	finish_hvs
_Harr_rx:
;	lea	FUSoftEdgeGadget,a0		;removed the softedge button072794
;	bset	#7,1+gg_Flags(a0)
	moveq	#1,d1		;#1=hor, #2=ver, #3=both, #0=none
	bsr	HVTIEOFF	
	bra.s	finish_hvs
_Varr_rx:
;	lea	FUSoftEdgeGadget,a0		;removed the softedge button072794
;	bset	#7,1+gg_Flags(a0)
	moveq	#2,d1		;#1=hor, #2=ver, #3=both, #0=none
	bsr	HVTIEOFF	
	bra.s	finish_hvs

_Ttog_rx:	 ;transparent 2-way direction toggle
	tst.b	FlagCtrl_(BP)	;ON ctrl scr?
	bne.s	1$
	st	FlagNeedGadRef_(BP)
	sf	FlagCtrlText_(BP)		;clear 3 diff tool display flags
	sf	FlagPale_(BP)
	st	FlagCtrl_(BP)
1$
	moveq	#0,d1
	bsr	HVTIEON	
	move.b	ShadeOnOffNum_(BP),d1	;#1=hor, #2=ver, #3=both, #0=none
		;WANT  0/off      3/2way    1/vert   2/hor   

	subq.w	#2,d1	;3...1 or 2....0	(result combo)
	bcc.s	finish_hvs
	neg.w	d1	;1...1fix  0...2fix
	addq.w	#1,d1	;1...2     0...3	(result combo)

finish_hvs:	;finish setup, hor/ver/both little buttons
	tst.b	ShadeOnOffNum_(BP)
	bne.s	finish_hvs2
	move.w	LastShade0_(a5),StdPot0
	move.w	LastShade1_(a5),StdPot1
	move.w	LastShade1_(a5),d0
	cmp.w	LastShade0_(a5),d0
	bne.s	finish_hvs2
	move.w	#$0000,StdPot0
	move.w	#$FFFF,StdPot1
finish_hvs2:
	st	FlagNeedGadRef_(BP)	;causes props to 'look right'...SEP011990
	;Process the arrow gadgets,
	;...setup Flag{H|V}Shading to reform the HVShadingGadget

	lea	ShadeOnOffNum_(BP),a0	;#1=hor, #2=ver, #3=both, #0=none
	cmp.b	(a0),d1
	bne.s	dosetst			;do set shading type
	moveq	#0,d1			;select 'no shading' direction
dosetst:
	move.b	d1,(a0)			;on/off number
		;08DEC91....if no direction, and range mode, reset to normal
	bne.s	100$			;08DEC91...if no direction, ensure not range paint...
	cmp.b	#7,PaintNumber_(BP)	;RANGE PAINT ON NOW?
	bne.s	100$
	tst.b	FlagStretch_(BP)	;09DEC91...don't disable if in warp mode
	bne.s	100$
	pea	_Pmcl_rx(pc)		;reset to normal....
100$
	lea	HVShadingGadget,A0	;2way blend gadget
	move.l	gg_SpecialInfo(a0),a3	;propinfo struct (gonna modify flags)
	move.w	#AUTOKNOB!PROPBORDERLESS,d0	;prop flags building for modprop call
	btst	#0,d1			;first bit?, requested type hor?
	sne	FlagHShading_(BP)	;set flag, yes/no, either way
	beq.s	1$
	or.w	#FREEHORIZ,d0
1$	btst	#1,d1			;second bit?
	sne	FlagVShading_(BP)
	beq.s	2$
	or.w	#FREEVERT,d0
2$	move.w	d0,pi_Flags(a3)		;auto-vert/hor
	st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	_Pro0_rx		;prop gadget msgs go here, too, tiepots
	;bra.s	needgad_rts

;--------

_Shva_rx:
	moveq	#3,d1		;desired type, both directions
	bra.s	finish_shvs
_Shar_rx:
	moveq	#1,d1		;#1=hor, #2=ver, #3=both, #0=none
	bra.s	finish_shvs
_Svar_rx:
	moveq	#2,d1		;#1=hor, #2=ver, #3=both, #0=none
	bra.s	finish_shvs

_Wtog_rx:	 ;warp 2-way direction toggle
	tst.b	FlagCtrl_(BP)	;ON ctrl scr?
	bne.s	1$
	st	FlagNeedGadRef_(BP)
	sf	FlagCtrlText_(BP)		;clear 3 diff tool display flags
	sf	FlagPale_(BP)
	st	FlagCtrl_(BP)
1$
	moveq	#0,d1
	move.b	StretchOnOffNum_(BP),d1	;#1=hor, #2=ver, #3=both
	add.w	#1,d1
	cmp.b	#4,d1	;past max? go-> hor ver both none etc
	bcs.s	finish_shvs
	moveq	#1,d1	;revert to type 1

finish_shvs:	;finish setup, hor/ver/both little buttons
	;Process the arrow gadgets,
	;...setup Flag{H|V}Stretching to reform the HVStretchingGadget

	xref StretchOnOffNum_
	lea	StretchOnOffNum_(BP),a0	;#1=hor, #2=ver, #3=both, #0=none
	cmp.b	(a0),d1
	bne.s	dossetst		;do set shading type
	moveq	#3,d1 ;both if none ;#0,d1 ;select 'no shading' direction
dossetst:
	move.b	d1,(a0)			;on/off number
	xref HVStretchingGadget		;2way blend gadget
	lea	HVStretchingGadget,A0	;2way blend gadget
	move.l	gg_SpecialInfo(a0),a3	;propinfo struct (gonna modify flags)
	move.w	#AUTOKNOB!PROPBORDERLESS,d0		;prop flags building for modprop call
	btst	#0,d1			;first bit?, requested type hor?
	sne	FlagHStretching_(BP)	;set flag, yes/no, either way
	beq.s	1$
	or.w	#FREEHORIZ,d0
1$	btst	#1,d1			;second bit?
	sne	FlagVStretching_(BP)
	beq.s	2$
	or.w	#FREEVERT,d0
2$	move.w	d0,pi_Flags(a3)		;auto-vert/hor
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra.s	needgad_rts
	;rts
;--------
_Poth_rx:	;EXTernal setting, ascii value (only one per line) => pot
	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	HVShadingGadget,A0
	move.l	gg_SpecialInfo(a0),a3
	move.w	d0,pi_HorizPot(a3)
	move.w	pi_Flags(a3),d0	;auto-vert/hor
	bra.s	needgad_rts

_Potv_rx:	;EXTernal setting, ascii value (only one per line) => pot
	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	HVShadingGadget,A0
	move.l	gg_SpecialInfo(a0),a3
	move.w	d0,pi_VertPot(a3)
	move.w	pi_Flags(a3),d0	;auto-vert/hor
	;bra.s	needgad_rts

needgad_rts:		;d0=flag from pi_Flags(a3)...propinfo struct
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'



_Spoh_rx:	;EXTernal setting, ascii value (only one per line) => pot
	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	HVStretchingGadget,A0
	move.l	gg_SpecialInfo(a0),a3
	move.w	d0,pi_HorizPot(a3)
	move.w	pi_Flags(a3),d0	;auto-vert/hor
	bra.s	needgad_rts

_Spov_rx:	;EXTernal setting, ascii value (only one per line) => pot
	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	HVStretchingGadget,A0
	move.l	gg_SpecialInfo(a0),a3
	move.w	d0,pi_VertPot(a3)
	move.w	pi_Flags(a3),d0	;auto-vert/hor
	bra.s	needgad_rts

_Tstr_rx:	;text string gadget, hit cr in string gad, come here
	xref TracePrintString_			;main.msg.i
	xref FlagPrintString_
*	lea	TextStringBuffer_(BP),a1	;string gadget ascii
*	move.l	a1,TracePrintString_(BP)	;adr for trace-out string print
*	st	FlagPrintString_(BP)
	xjsr	MakeTextBrush	;textstuff.o
	DUMPMSG	<after MakeTextBrush>
	rts		

_Tbbo_rx:	;text button bold
	tst.l	LastItemAddress_(BP)	;was it a "user gadget" (not msg?)
	bne.s	text_gset		;gadget sup by user (intuit)
	move.l	#'Tbbo',d0
	bra.s	textbstuff

_Tbun_rx:	;text button underline
	tst.l	LastItemAddress_(BP)	;was it a "user gadget" (not msg?)
	bne.s	text_gset		;gadget sup by user (intuit)
	move.l	#'Tbun',d0
	bra.s	textbstuff

_Tbit_rx:	;text button italic
	tst.l	LastItemAddress_(BP)	;was it a "user gadget" (not msg?)
	bne.s	text_gset		;gadget sup by user (intuit)
	move.l	#'Tbit',d0
		;MAY13
	bsr.s	textbstuff
	xjmp	ResetGadStyles		;textstuff.o


textbstuff:			;entry for text button gadgets
	bsr.s	_FindGadget ;arg D0=action code, rtns gadget in a0 AND d0, zero valid
	beq.s	text_gset		;couldn't find gadget
					;else flip gadget's selected bit
	lea	gg_Flags(a0),a0
	bchg	#7,1(a0)		;(.b assumed);SELECTED equ $0080
	st	FlagNeedGadRef_(BP)
	;;;xjsr	ResetGadStyles	;may11'LATE;change text buttons selected based on d0=newstyle
text_gset:
	rts


_FindGadget:	;more short code glue
	xjmp	FindGadget	;tool.o



DoColorBox:	macro	;#,code ;sets up 'std' routine
_Cbx\2_rx:
  ifc '\2','g'	;range color?	;SEP101990
	bsr	_Pmso_rx	;setup range paint mode....
  endc
  ifc '\2','h'	;range color?	;SEP101990
	bsr	_Pmso_rx	;setup range paint mode....
  endc
	moveq	#\1,d0
  ifc '\2','i'	;last one?
	mexit
  endc
	bra.s	UseColorRegister
	endm

   DoColorBox 0,0	;do palette box gadgets
   DoColorBox 1,1
   DoColorBox 2,2
   DoColorBox 3,3
   DoColorBox 4,4
   DoColorBox 5,5
   DoColorBox 6,6
   DoColorBox 7,7
   DoColorBox 8,8
   DoColorBox 9,9
   DoColorBox 10,a
   DoColorBox 11,b
   DoColorBox 12,c
   DoColorBox 13,d
   DoColorBox 14,e
   DoColorBox 15,f
   DoColorBox 16,g	;'FRONT'
   DoColorBox 17,h	;'BACK', '2nd color'
   DoColorBox 18,i	;CURRENT new 'PAINT' colorr

UseColorRegister:	;(D0=palette #,(or #16=foregnd, #17=backgnd)

	xref	FlagColorMap_		;02FEB92...help w/2.0 sprite problem(?)
	st	FlagColorMap_(BP)	;02FEB92...help w/2.0 sprite problem(?)

	moveq	#0,d1
	move.b	PenColor_(BP),d1	;D1=old color
	cmp.b	#16,d0			;new color front16 or back17 ?
	bcs.s	3$			;branch if not 16/17, pen#s only 16-18

	cmp.b	d1,d0	;same pencolor 2x?
	bne.s	2$
	moveq	#18,d0	;yes, simply reset to 'current' color (disable 16,17)
	pea	_Pmcl_rx(pc)		;SEP101990...reset to normal
2$
	move.b	d0,PenColor_(BP)	;var pencolor always only 16 or 17
3$
		;AUG231990
		;DO: if last-message-window = ham-tools, then 
		;   set last-message-window = HIRES-tools
		;BECAUSE: else program goes into "pick" mode
		;....when "new color flood fill" is turned on
	move.l	ToolWindowPtr_(BP),a0
	;?;cmp.l	LastM_Window_(BP),a0
	move.l	LastM_Window_(BP),a1
	cmp.l	#0,a0	;toolwindow not open?
	beq.s	38$
	cmp.l	a0,a1	;only reset window if from toolwindow(hamtools)
	bne.s	38$
	move.l	GWindowPtr_(BP),LastM_Window_(BP)
	;;;?;;;;bra.s	39$			;DON't set picking-mode-flag is Cbx...
38$
	st	FlagPick_(BP)		;needed so 'EndPick' really works
39$

	lea	LongColorTable_(BP),A0	;address of in-use color map
	lea	PointerTo_data,a1	;"copy color to" pointer
	move.l	GWindowPtr_(BP),a2	;hires window
	cmp.l	wd_Pointer(a2),a1	;"to-arrow" = pointer-from-window ?
	beq.s	handle_toptr
	xref LastActionCode_
	cmp.l	#'Ccto',LastActionCode_(BP)
	beq.s	handle_toptr

	;cmp.b	#16,d0	;March01'89
	;bcc.s	8$			;new color is 16 or 17, nochg pal
	asl.w	#2,d0			;old pencolor, 0..15, <<2 now
	move.l	0(a0,d0.w),Paintred_(BP) ;grab paint r,g,b,brite from tbl
	cmp.b	#(16*4),d0
	;cmp.b	#(17*4),d0	;march15'89 palette color when range BUGFIX?
	bcc.s	8$			;new color is 16 or 17, nochg pal

	asl.w	#2,d1			;old index, for tbl lup
	move.l	0(a0,d0.w),0(a0,d1.w)	;new/curt rgb => old color (16/17,f/b)
8$:
	st	FlagNeedText_(BP)
	st	FlagRefHam_(BP)	;main loop request for updatepalette/ucm
	st	FlagGrayPointer_(BP) ;usecolormap only does hires gray loadrgb4
	st	FlagRedrawPal_(BP)	;used with flagrefham
	;?;AUG231990;st	FlagPick_(BP)		;needed so 'EndPick' really works
	xjsr	Paint4to8Bit		;mousertns.o
	;AUG241990;cbra	EndPick			;mousertns.o (resets pencolor)
	st	FlagNeedGadRef_(BP)	;enables redo-menu-ghosted items...AUG241990
	tst.b	FlagFillMode_(BP)	;AUG24
	beq.s	123$			;if in flood fill....
	xref	FlagNeedHiresAct_
	st	FlagNeedHiresAct_(BP)	;then, asap, re-activate the hires
	;no need.....;xjsr	ReallyActivate		;main.asm
	;...mousertns, move_entry tests for "need hires act" flag
	xjsr	ReallyActivate		;main.asm	LOGICAL KLUDGE
	move.l	ToolWindowPtr_(BP),a0	;LOGICAL KLUDGE
	xjsr	ReturnMessages	;a0=windowptr  (destroys d0/d1/a1)
		;scans the 'input message list' and ReplyMsg's all
		;the msgs for window a0 (for use just before CloseWindow)
123$
	st	FlagPick_(BP)	;AUG241990.....
	xjmp	ReallyEndPick	;mousertns.asm

handle_toptr:			;mouse pointer "<==?" copy color to...
	asl.w	#2,d0			;pen#*4 for long word mode indexing
	lea	0(A0,d0.w),A0	;A0->pen# rgb in longcolortable
	cmpi.b	#(17<<2),d0	;copy to back color?
	bne.s	enda_tobg
	move.b	DisplayedRed_(BP),d0
	move.b	DisplayedGreen_(BP),d1
	move.b	DisplayedBlue_(BP),d2
	move.b	d0,d3
	cmp.b	d1,d3
	bcc.s	26$
	move.b	d1,d3
26$	cmp.b	d2,d3
	bcc.s	27$
	move.b	d2,d3
27$			;d0,1,2=r,g,b d3=highest 4bit valu
	lea	BPaintred_(BP),a1	;copy d0-d3 into background color
	move.b	d0,(a1)+	;paint red
	move.b	d1,(a1)+	;gr
	move.b	d2,(a1)+	;bl
	move.b	d3,(a1)+	;brite
	bra.s	skipctcopy
enda_tobg:

	cmpi.b	#(16<<2),d0	;copy to front color?
	beq.s	skipctcopy	;yep, this isnt a 'real' palette color...

	movem.l	d0/a0,-(SP)
	lea	FlagRemap_(BP),a0	;HANDLE REMAPPING flag
	tst.b	(a0)			;if flag NOT set,
	bne.s   2$ ;alrdy_copt		;...then EXCHG LongClrTab=>FileClrTab
	st      (a0)			;...later use FileColorTable for remap
	lea	FileColorTable_(BP),a0	;move Long/Exist Colors->File
	lea	LongColorTable_(BP),a1  ;...allows a remap later
	moveq	#(16-1),d0
1$	move.l	(a1)+,(a0)+
	dbf	d0,1$
2$	movem.l	(SP)+,d0/a0

	move.b	DisplayedRed_(BP),0(A0)	  ;rgb-> longcolor table, use it.
	move.b	DisplayedGreen_(BP),1(A0)
	move.b	DisplayedBlue_(BP),2(A0)

	move.b	(A0),Paintred_(BP)
	move.b	1(A0),Paintgreen_(BP)
	move.b	2(A0),Paintblue_(BP)

		;redo lutable every color change
	cbsr	CreateDetermine	;enable painting with new palette
	;st	FlagRefHam_(BP)	;main loop request for updatepalette/ucm
	st	FlagRedrawPal_(BP)	;used with flagrefham
	bra.s	enda_htp

skipctcopy:	;cleanup for copy 'to' FRONT or BACK color
	move.b	DisplayedRed_(BP),0(A0)	  ;rgb-> longcolor table, use it.
	move.b	DisplayedGreen_(BP),1(A0)
	move.b	DisplayedBlue_(BP),2(A0)

	move.b	(A0),Paintred_(BP)
	move.b	1(A0),Paintgreen_(BP)
	move.b	2(A0),Paintblue_(BP)

enda_htp:	;end of 'handle_toptr'
	st	FlagNeedGadRef_(BP)	;fixes 'remap' option on menu
	cbra	EndPick
	;rts


_Prfl_rx:			;PRop gadget, File List
	xjmp	ListRoutine	;dirrtns.o


* NOTE: use 'prop' gadget message to 'set newest value'

  IFC 'F','EXTRAS'
_Maxz_rx:
	move.L	#$3fff,d0	;q	#0,d0
	bra.s	setpot2
_Midz_rx:
	move.L	#$7fff,d0
	bra	setpot2
_Minz_rx:
	move.L	#$bfff,d0	;q	q	#-1,d0
	bra	setpot2

_Pro2_rx:	;rotate gadget
	; WANT TO....print current value
	xref	Prop2_Gadget
	lea	Prop2_Gadget,a0		;skinny tall prop gadget CTRblencd
	move.l	gg_SpecialInfo(A0),a3	;a3=propinfo struct ptr
	moveq	#0,d0
	move.w	pi_VertPot(a3),d0	;gonna set this, will it change?
	bra.s	setpot2

_Pot2_rx:	;EXTernal setting, ascii value (only one per line) => pot
	bsr	grab_rgbarg2	;actually, this subr grabs three args
setpot2:
	st	FlagNeedText_(BP)
	move.l	d0,PrintValue_(BP)
	move.W	d0,TiltZ_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	Prop2_Gadget,a0		;skinny tall prop gadget CTRblencd
	;bra	stdsw_rx		;D0=new setting
	;rts
	bra	rot_tilt_rx		;D0=new setting



_Maxx_rx:
	move.l	#$3fff,d0	;q	q	#0,d0
	bra.s	setpot3
_Midx_rx:
	move.l	#$7fff,d0
	bra	setpot3
_Minx_rx:
	move.l	#$bfff,d0	;q	q	#-1,d0
	bra	setpot3

_Pro3_rx:	;rotate gadget
	; WANT TO....print current value
	xref	Prop3_Gadget
	lea	Prop3_Gadget,a0		;skinny tall prop gadget CTRblencd
	move.l	gg_SpecialInfo(A0),a3	;a3=propinfo struct ptr
	moveq	#0,d0
	move.w	pi_VertPot(a3),d0	;gonna set this, will it change?
	bra.s	setpot3

_Pot3_rx:	;EXTernal setting, ascii value (only one per line) => pot
	bsr	grab_rgbarg2	;actually, this subr grabs three args
setpot3:
	st	FlagNeedText_(BP)
	move.l	d0,PrintValue_(BP)
	move.W	d0,TiltX_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	Prop3_Gadget,a0		;skinny tall prop gadget CTRblencd
	;bra	stdsw_rx		;D0=new setting
	;rts
	bra.s	rot_tilt_rx		;D0=new setting



_Maxy_rx:
	move.l	#$3fff,d0	;q	q	#0,d0
	bra.s	setpot4
_Midy_rx:
	move.l	#$7fff,d0
	bra	setpot4
_Miny_rx:
	move.l	#$bfff,d0	;q	q	#-1,d0
	bra	setpot4

_Pro4_rx:	;rotate gadget
	; WANT TO....print current value
	xref	Prop4_Gadget
	lea	Prop4_Gadget,a0		;skinny tall prop gadget CTRblencd
	move.l	gg_SpecialInfo(A0),a3	;a3=propinfo struct ptr
	moveq	#0,d0
	move.w	pi_VertPot(a3),d0	;gonna set this, will it change?
	bra.s	setpot4

_Pot4_rx:	;EXTernal setting, ascii value (only one per line) => pot
	bsr	grab_rgbarg2	;actually, this subr grabs three args
setpot4:
	st	FlagNeedText_(BP)
	move.l	d0,PrintValue_(BP)
	move.W	d0,TiltY_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	lea	Prop4_Gadget,a0		;skinny tall prop gadget CTRblencd
	;bra	stdsw_rx		;D0=new setting
	;rts
rot_tilt_rx:				;D0=new setting
	move.l	gg_SpecialInfo(A0),a3	;a3=propinfo struct ptr
	cmp.w	pi_VertPot(a3),d0	;new 16bit value-->propinfo struct
	beq.s	9$
	st	FlagNeedGadRef_(BP)
	move.w	d0,pi_VertPot(a3)	;new 16bit value-->propinfo struct
9$	st	FlagRefProp_(BP)	;useless flag?
	rts

  ENDC ;perspective stuff

_Pro0_rx:	;prop gadget msgs come here

	lea	StdPot0,a0
;	lea	Prop0_Gadget,a0		;skinny tall prop gadget CTRblencd
;		;june12
;	move.l	gg_SpecialInfo(a0),a2	;a0=prop(0,1)gadget pointer
;	cmp.w	pi_VertPot(a2),d0
;	cmp.w	StdPot0,d0		
;	beq.s	1$
;	st	FlagNeedGadRef_(BP)
;1$	move.w	d0,StdPot0	
;;	move.W	d0,pi_VertPot(a2)	;sup valu, right away


		;DigiPaint Pi...trace out for ALL props...
;	move.l	gg_SpecialInfo(a0),a3	;a0=prop(0,1)gadget pointer
	moveq	#0,d0
;;	move.w	pi_VertPot(a3),d0	;gonna set this, will it change?
;;	move.w	pi_HorizPot(a3),d0	;gonna set this, will it change?
	move.w	(a0),d0			;new mini slider adj.

	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	st	FlagNeedText_(BP)

	bra.s	tiepots			;GO SEE IF POT TIEING IS IN ORDER!
_Pro1_rx:
;;	lea	Prop1_Gadget,a0		;skinny tall prop gadget CTRblencd
	lea	StdPot1,a0		;skinny tall prop gadget CTRblencd
		;DigiPaint Pi...trace out for ALL props...
;;	move.l	gg_SpecialInfo(a0),a3	;a0=prop(0,1)gadget pointer
	moveq	#0,d0
;;	move.w	pi_VertPot(a3),d0	;gonna set this, will it change?
;;	move.w	pi_HorizPot(a3),d0	;gonna set this, will it change?
	move.w	(a0),d0			;gonna set this, will it change?
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
	st	FlagNeedText_(BP)
tiepots:				;CONNECTS 2 pots, lock sliders
	tst.W	FlagHShading_(BP)	;shading on at all?
	bne.s	9$			;yes...don't "tie" pots
	bsr	HVTIEON			;turnon minislider tieing of MS001,MS002 
;;	move.l	gg_SpecialInfo(a0),a2	;a0=prop(0,1)gadget pointer StdPot{0/1}!
;;	move.W	pi_VertPot(a2),d0
;;	move.W	pi_HorizPot(a2),d0
	move.W	(a0),d0

;;	lea	Prop0_Gadget,a0		;skinny tall prop gadget CTRblencdDEH
	lea 	StdPot0,a0
	bsr.s	8$			;set vertpot from d0
;;	lea	Prop1_Gadget,a0		;EDGE BLEND
	lea	StdPot1,a0

8$	
;;	move.l	gg_SpecialInfo(a0),a2
;;	cmp.w	pi_VertPot(a2),d0	;any change?
;;	cmp.w	pi_HorizPot(a2),d0	;any change?
	cmp.w	(a0),d0			;any change?
	beq.s	9$
	st	FlagNeedGadRef_(BP)	;remove/add gadgets if gonna chg, JUNE12
;	move.w	gg_Flags(a2),d1		;special info flags
;	and.w	#KNOBHIT,d1
;	bne.s	9$			;leave alone if 'active'
;;	move.W	d0,pi_VertPot(a2)
	move.W	d0,(a0)
9$	st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	;JUNE11'89;st	FlagNeedGadRef_(BP)	;march28'89 causes re-update ok
	rts

_Pot0_rx:	;EXTernal setting, ascii value (only one per line) => pot
;	lea	FUSoftEdgeGadget,a0		;removed the softedge button
;	bset	#7,1+gg_Flags(a0)

	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
setpot0:	;internal for 'txbt' routine
* 	lea	StdPot0,A0			;A0=gadget to affect
 	lea	MS001,A0			;A0=gadget to affect

	bsr.s	stdsw_rx
	bra	tiepots

stdsw_rx:				;D0=new setting
stdsw2_rx:				;D0=new setting, (no gadget ref')
	st	FlagNeedGadRef_(BP)
	move.l	d0,(a0)			;new 16bit value-->propinfo struct
justrefprop:
	st	FlagRefProp_(BP)	;NeedGadRef_(BP)
	rts

_Pot1_rx:	;EXTernal setting, ascii value (only one per line) => pot
;	lea	FUSoftEdgeGadget,a0	;removed the softedge button072794	
;	bset	#7,1+gg_Flags(a0)
	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
setpot1:
	st	FlagNeedText_(BP)
	move.l	d0,PrintValue_(BP)
	st	FlagPrint1Value_(BP)	;main.msg.i, output ref
;;	lea	Prop1_Gadget,A0		;A0=gadget to affect

	lea	MS002,a0
	bsr.s	stdsw_rx
	bra	tiepots


_Pro7_rx:
_Pro8_rx:
_Pro9_rx:
_ProA_rx:

_Pro6_rx:	;'prop 6' overall transp
	st	FlagNeedGadRef_(BP)
	rts
_Pro5_rx:	;'prop 5' is the WARP AMT
 	rts

_Pot5_rx:	;EXTernal setting, ascii value (only one per line) => pot
	;bsr	grab_rgbarg	;actually, this subr grabs three args
	bsr	grab_rgbarg2	;actually, this subr grabs three args
setpot5:
	xref	MS003
	move.l	d0,MS003
	xjmp	DsMiniSlider
	rts


_Dotb_rx:			;synonym for brush 06 (single dot width line)
_Brt1_rx:	move.w	#0,d1
		bra.s	eabrtr
_Brt2_rx:	move.w	#1,d1
		bra.s	eabrtr
_Brt3_rx:	move.w	#2,d1
		bra.s	eabrtr
_Brt4_rx:	move.w	#3,d1
		bra.s	eabrtr
_Brt5_rx:	move.w	#4,d1
		bra.s	eabrtr
_Brt6_rx:	move.w	#5,d1
		bra.s	eabrtr
_Brt7_rx:	move.w	#6,d1
		;bra.s	eabrtr

eabrtr:	st	FlagNeedGadRef_(BP)	;refresh gadgets is turned-off cutpaste
	move.w	d1,BrushType_(BP)
	subq	#1,d1
	bcc.s	1$
	moveq	#6,d1			;brush rtn #6 is single dot
	bra.s	2$			;type '0' (dotb) forces size, too
1$	mulu	#7,d1
	add.w	BrushSize_(BP),d1	;0..6
2$	move.w	d1,BrushNumber_(BP)	;0..41
	bra	_EndCutPaste
	;rts

_Bsz1_rx:	move.w	#6,d1	;single
		bra.s	eabszr
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
_Bsz2_rx:	move.w	#5,d1
		bra.s	eabszr
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
_Bsz3_rx:	move.w	#4,d1
		bra.s	eabszr
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
_Bsz4_rx:	move.w	#3,d1
		bra.s	eabszr
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
_Bsz5_rx:	move.w	#2,d1
		bra.s	eabszr
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
_Bsz6_rx:	move.w	#1,d1
		bra.s	eabszr
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
_Bsz7_rx:	move.w	#0,d1
		st	FlagUpdateCG_(BP)	;QUICK FIX,AUG041990, might flash on last one
		;bra.s	eabszr

eabszr:
	cmp.b	BrushSize_(BP),d1
	beq.s	1$
	st	FlagUpdateCG_(BP)

		;SEP101990....if size not a '.', and '.' TYPE, then use little circles
	cmp.b	#6,d1		;single dot SIZE?
	beq.s	1$		;yep...continue
	tst.w	BrushType_(BP)	;'dot' brushes?
	bne.s	1$
	pea	_Brt7_rx(pc)	;setup little circles....
1$
	move.w	d1,BrushSize_(BP)
	bra.s	cont_bchange
	
_Bszs_rx:	;brush size smaller
	move.w	BrushSize_(BP),d1
	addq	#1,d1		;internally, the numbers are really "other way"
	cmp.w	#7,d1
	bcs.s	cont_bsize
	moveq	#6,d1
	bra.s	cont_bsize
_Bszl_rx:	;brush size larger
	move.w	BrushSize_(BP),d1
	subq	#1,d1
	bcc.s	cont_bsize
	moveq	#0,d1
cont_bsize:
	xref FlagUpdateCG_	;set when need update of brush sizer
	;cmp.b	BrushSize_(BP),d1
	cmp.W	BrushSize_(BP),d1	;WAS BUG...WHY BRUSH SIZER DIDNT UPDATE AUG041990
	beq.s	1$
	st	FlagUpdateCG_(BP)
1$
	move.w	d1,BrushSize_(BP)
	;	;june291990...."ask" for update of "brush SIZE display"
	st	FlagUpdateCG_(BP)	;set when need update of brush sizer

	bra.s	cont_bchange

_Btog_rx:	 ;brush shape toggle,flips btwn brush shapes
	move.b	FlagCtrl_(BP),d1	;ON on scr other than 'regular tools'?
	or.b	FlagCtrlText_(BP),d1	;clear 3 diff tool display flags
	or.b	FlagPale_(BP),d1
	beq.s	1$			;ok...not "on" any other ctrl scr
	st	FlagNeedGadRef_(BP)
	sf	FlagCtrlText_(BP)	;clear 3 diff tool display flags
	sf	FlagPale_(BP)
	sf	FlagCtrl_(BP)
1$
	moveq	#0,d1
	move.w	BrushType_(BP),d1	;0..7
	subq	#1,d1
	bcc.s	2$
	moveq	#6,d1			;brush rtn #6 is single dot
2$	move.w	d1,BrushType_(BP)
	st	FlagNeedGadRef_(BP)
cont_bchange:
	;?AUG011990;	;june301990...."ask" for update of "brush SIZE display"
	;?AUG011990;xref FlagUpdateCG_	;set when need update of brush sizer
	;?AUG011990;st	FlagUpdateCG_(BP)	;set when need update of brush sizer

	bsr.s	SetupBrushNumber
	;june291990;st	FlagNeedGadRef_(BP)
_EndCutPaste:
	xjmp	EndCutPaste
	;rts

	xdef SetupBrushNumber		;used by CustomGads
SetupBrushNumber:
	move.w	BrushType_(BP),d1	;0..7
	subq	#1,d1
	bcc.s	1$
	moveq	#6,d1			;brush rtn #6 is single dot
	bra.s	2$			;type '0' (dotb) forces size, too
1$	mulu	#7,d1
	add.w	BrushSize_(BP),d1	;0..6
2$	move.w	d1,BrushNumber_(BP)	;0..41
	RTS	;SetupBrushNumber

_Noef_rx:
	moveq	#0,d0
	bra	enda_fx


_Proc_rx:	
	lea	FlagProc_(BP),a0	;This is the Image Processor screen
	sf	FlagNeedText_(BP)
	bra.s	toolswitch

_Disk_rx:	
	lea	FlagDisk_(BP),a0	;This is the Disk IO Panel 
	sf	FlagNeedText_(BP)
	bra.s	toolswitch

_Sopt_rx:
	lea	FlagOptions_(BP),a0	;This is the options screen
	bra.s	toolswitch

_Pale_rx:	;palette tools on/off button
	lea	FlagPale_(BP),a0	;already palette tools?
;;	st	FlagRedrawPal_(BP)
	bra.s	toolswitch

_Ctrl_rx:	;control tools on/off
	xref FlagCtrl_
	lea	FlagCtrl_(BP),a0
	bra.s	toolswitch

  IFC 'F','EXTRAS'
_Anbt_rx:	;control tools on/off
	lea	FlagAnim_(BP),a0
	bra.s	toolswitch
  ENDC
_Txbt_rx:	;text button (user set the on/off status...)
*	tst.b	FlagToast_(BP)	;"hires" mode? AUG1519890	*KEYWORD
*	bne.s	notext_1xmode	;AUG151990

	;tst.l	LastItemAddress_(BP)	;was it a "user gadget" (not msg?)
	;bne.s	1$			;yes...allow user selection of on/off
	xref	FakeIE_
	lea	FakeIE_(BP),a1
	cmp.l	MsgPtr_(BP),a1	;'msg from keystroke'?
	bne.s	09$
		;turn on text ONLY when from a keystroke
	xref	TextButtonGadget	;RELOC...SHOULD 'find gadget'
	lea	TextButtonGadget,a0
	move.w	#SELECTED,d0
	or.w	gg_Flags(a0),d0
	move.w	d0,gg_Flags(a0)
	st	FlagNeedGadRef_(BP)
09$
	lea	FlagCtrlText_(BP),a0

toolswitch:	;a0=ptr to flag(text,pal,ctrl).b
	move.B	(a0),d0				;.bite syzed flag
	st	FlagNeedGadRef_(BP)
	sf	FlagCtrlText_(BP)		;clear 3 diff tool display flags
	sf	FlagPale_(BP)
	sf	FlagCtrl_(BP)
	sf	FlagAnim_(BP)			;digipaint pi
	sf	FlagOptions_(BP)
	sf	FlagProc_(BP)
	sf	FlagDisk_(BP)
	;tst.B	d0				;'scc' doesnt AFFECT flags, just uses'em
	seq	(a0)				;flip flag from prev
	rts

notext_1xmode:
	st	FlagDisplayBeep_(BP)	;AUG151990
	lea	FlagCtrlText_(BP),a0
	tst.b	(a0)
	beq.s	9$
	clr.b	(a0)
	bra.s	toolswitch	;a0=ptr to flag(text,pal,ctrl).b
9$	rts

_Sizi_rx:	;Effects_Stretch:
	moveq	#7,d0		;"Real" paint number ("normal//Pmcl)
	moveq	#7,d1		;menu item #
;JUNE22;_Warp_rx:	;warp button (INTERNAL only)
;JUNE22;	moveq	#1,d0	;"internal" effect # 1
;JUNE22;	bra.s	enda_fx				;

	moveq	#1,d0	;"internal" effect # 1
	bra	enda_fx	;june25, replaced with "redo the screen" jump

_Warp_rx:	;june22;;warp immediate (leaves paintmode alone)
	moveq	#7,d0		;"Real" paint number ("normal//Pmcl)
	moveq	#7,d1		;menu item # for text
	bsr	_pm_continue	;setup "paintname rubthru"
_Txma_rx:			;txmap mode, immediate, combo w/others...

		;SEP091990
		;if no cutout brush, continue
		;if no SWAP brush, then transfer cutout brush to swap brush
		;...before continuing
	tst.l	PasteBitMap_Planes_(BP)		;have a cutout brush?
	beq.s	5$				;no...continue
	xref	AltPasteBitMap_Planes_		;have a swap brush?
	tst.l	AltPasteBitMap_Planes_(BP)	;have a swap brush?
	bne.s	5$				;yep...continue
	xjsr	UnShowPaste		;cutpaste.asm ensure brush removed  NOV91
	xjsr	MovePasteAlt		;memories.asm
	xjsr	EndCutPaste
5$



	st	FlagStretch_(BP)
	st	FlagNeedGadRef_(BP)
	move.b	#1,EffectNumber_(BP)	;set effect#=stretch
	rts

_Pmcl_rx:	;'normal' paint mode action code (digipaint pi replacement)
	moveq	#0,d1		;menu item # (for text display)
	moveq	#0,d0	;"internal" effect #0 - off
	sf	FlagRub_(BP)
	bra.s	enda_fx

_Blu2_rx:			;AUG051990
	;bsr.s	_Blur_rx
	move.b	#7,ModeNumber_(BP)	
_setup_blur2:
	bsr.s	really_setup_blur
	bsr	_Ugad_rx	;AUG101990
	move.b	#8,EffectNumber_(BP)
	xjsr	SetupModeName		;modenames.asm, AUG101990
	st	FlagNeedText_(BP)	;redisplay of modename....
	RTS


_Blur_rx:
	;digipaint pi
	;moveq	#6,d1		;menu item # (for text display)
	;moveq	#2,d0	;"internal" effect #2
	;bra.s	enda_fx

		;AUG101990...selecting BLUR mode 2x gets you "blur2" mode
	cmp.b	#2,EffectNumber_(BP)	;already setup for 'blur'?
	beq.s	_setup_blur2

really_setup_blur:
	moveq	#7,d0		;"Real" paint number ("normal//Pmcl)
	moveq	#6,d1		;menu item # for text
	bsr	_pm_continue	;setup "paintname rubthru"
_Blui_rx:			;blur mode immediate
	sf	FlagRotate_(BP)
	sf	FlagStretch_(BP)
	move.b	#2,EffectNumber_(BP)	;set effect#=blur (see DoEffect.asm)
	bra	refresh_if_ctrl	;digipaint pi



_Mirr_rx:
	moveq	#3,d0	;"internal" effect #2
	moveq	#0,d1	;menu item #0, "normal" (Pmcl)
	;bra.s	enda_fx
enda_fx:
		;june12...only "refgad" if new-or-old effect='stretch'
	cmp.b	#1,EffectNumber_(BP)	;old effect=stretch?
	beq.s	1$			;yep...get refresh
	cmp.b	#1,d0			;new effect=stretch?
	bne.s	2$			;nope...skip refresh
1$	;want refresh...to/from stretch sliders
	tst.b	FlagCtrl_(BP)		;control/sliders displayed?
	beq.s	2$			;nope...so no slider refresh
	st	FlagNeedGadRef_(BP)
2$


	move.b	d0,EffectNumber_(BP)
	sne	FlagEffects_(BP)	;true if any effects turned on
	cmp.b	#1,d0			;effect# = #1 = sizd offset to rtn, start of table
	seq	FlagStretch_(BP)
;	tst.b	FlagCtrl_(BP)		;control/slider screen displayed?
;	beq.s	1$
	;;st	FlagNeedGadRef_(BP)	;slider on/off visually
	;;june12
	;cmp.B	#7,CurrentFrameNbr_(BP)	;controls+warp sliders displayed?
	;bne.s	1$			;branch around when no warp sliders
	st	FlagNeedGadRef_(BP)	;gets remove/add of apro gadgets
;1$
	sf	FlagRotate_(BP)

	moveq	#7,d0		;"Real" paint number ("normal//Pmcl)
	bra	_pm_continue2	;d1=menu item#
	;rts

	xref	Flag24_		;Set when load/save 24 bit data

_Lobr_rx:	;;call up filename requester
	bsr	EndFileRequ		;AUG201990....really just need to clear out dirnamebuffer?
	move.l	#'Open',LS_String_(BP)	;requester sez it all
	st	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)	;this flag only pertains to 'file requester'
	st	FlagOpen_(BP)	;flag sez why FileRequester is alive
	sF	FlagCompFReq_(BP) ;file requester...NOT IN composite/framestore mode?
	SF	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 

*	move.b	#0,FilenameBuffer_(BP)


	bsr	setup_imagedirname	;NOV91
	bra	do_ShowFReq

_Sabr_rx:	;call up filename requester for saving brush
	bsr	EndFileRequ		;AUG201990....really just need to clear out dirnamebuffer?
	;ensure really HAVE a brush, before allow save (or any other opts)
	tst.l	PasteBitMap_Planes_(BP)
	bne.s	9$		
	st	FlagDisplayBeep_(BP)
	rts			
9$	
	move.l	#'Save',LS_String_(BP)	;requester sez it all
	st	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)	;this flag only pertains to 'file requester'
	st	FlagSave_(BP)	;flag sez why FileRequester is alive
	SF	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)
	sF	FlagCompFReq_(BP) ;file requester...NOT IN composite/framestore mode?
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	bsr	setup_imagedirname	;NOV91
	bra	do_ShowFReq

_Font_rx:	;call up font/filename requester
;;	tst.b	FlagToast_(BP)	;"hires" mode? 04DEC91	*KEYWORD
;;	bne.s	nofont_1xmode	;04DEC91

	move.l	#'Open',LS_String_(BP)	;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	st	FlagFont_(BP)	;this flag only pertains to 'file requester'
	st	FlagOpen_(BP)	;flag sez why FileRequester is alive
	sF	FlagCompFReq_(BP) ;file requester...NOT IN composite/framestore mode?
	sf	FlagImageDir_(BP)	;0=means 'need image directory' 15NOV91
	SF	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)
	move.b	#0,FilenameBuffer_(BP)

	bsr	setup_fontdirname
	bra	do_ShowFReq

nofont_1xmode:
	st	FlagDisplayBeep_(BP)
	rts

_Swp1_rx:
_Swp2_rx:
_Swap_rx:	;swap screens (rubthru image swap with current)
	;cbsr	UnShowPaste	;cutpaste.o, remove brush, SUBR rmvs dbl buffer
*	xref	FlagWholeHam_
*	st	FlagWholeHam_(BP)
	xjsr	SetAltPointerWait	;non-interruptable sleep cloud AUG311990
	xjsr	ReDoHires		;removes/replaces menu background on user display AUG311990
	xref	SwapButtonHD	
	xjsr	SwapButtonHD
	xjmp	SwapSwap		;memories.o;exchange alternate screen
*	xjmp	CopyPic	

_Cpic_rx:
	tst.b	FlagCutPaste_(BP)	;have a brush?
	beq.s	_CopyPic
	pea	_SaveUnDo(pc) 		;yes....save visible->backup screen when done
	;JUNE05;cbsr	UnDo		;memories.o	;copy super->visible screen

_CopyPic:
	xjsr	SetAltPointerWait	;non-interruptable sleep cloud AUG311990
	xjsr	ReDoHires		;removes/replaces menu background on user display AUG311990
	xjmp	CopyPic

_Dswa_rx:	;Delete Swap Screen
	tst.b	FlagCutPaste_(BP)	;have a brush?
	beq.s	1$
	pea	_SaveUnDo(pc)		;yes....save visible->backup screen when done
	cbsr	UnDo		;repaint.o	;copy super->visible screen
1$:
	xref	FlagSwaped_
	tst.b	FlagSwaped_(BP)		;check if on screen 2 
	beq	2$			;if not on screen 2 go on.
	bsr	_Swap_rx		;if on screen 2 swap back to 1 first
2$:
	cbra	FreeSwap		

_Mswa_rx:	;Merge Swap with Front pic
	tst.b	FlagCutPaste_(BP)	;have a brush?
	beq.s	1$
	pea	_SaveUnDo(pc) 		;yes....save visible->backup screen when done
	cbsr	UnDo		;repaint.o	;copy super->visible screen
1$:
	cbra	MergeCut
	;rts


_Clwb_rx:
	xref FlagCloseWB_	;march09'89
	st	FlagCloseWB_(BP)	;indicates to memories.o, "close if can"
	xjsr	ByeByeWorkBench	;memories.o, may12'89,CALLIB	Intuition,CloseWorkBench
	tst.b	d0
	seq	FlagDisplayBeep_(BP)	;'beep' in main loop if didn't close
	rts

_Opwb_rx:
	xjsr	CleanupMemory		;bye' hamtools (first)...MAY13
	sf	FlagCloseWB_(BP)	;indicates to memories.o, "dont close"
	JMPLIB	Intuition,OpenWorkBench
	;rts

;may13;_Bcmo_rx:	;brush color mode
;may13;	not.b	FlagColorMode_(BP)
;may13;	rts
_Bcmo_rx:	;brush color mode
	not.b	FlagBrushColorMode_(BP)
	rts


_Srgb_rx: ;source - rgb color
	st	FlagBrushColorMode_(BP)	;switches repaint to use rgb not brush
	sf	FlagRub_(BP)
	sf	FlagStretch_(BP)
	sf	FlagRotate_(BP)
	cmp.b	#1,EffectNumber_(BP)	;old effect=any?
	bne.s	1$
	st	FlagNeedGadRef_(BP)
1$
	sf	EffectNumber_(BP)	;clr.b
	rts

_Sbru_rx: ;source - brush image
	sf	FlagBrushColorMode_(BP)
	rts


_Pmad_rx:	moveq	#0,d0
		moveq	#10,d1	;1+10th menuitem 12,d1	;noname
		;bra.s	_pm_continue
		bra	_pm_continue
_Pmsu_rx:	moveq	#1,d0		
		moveq	#11,d1	;1+11th menuitem 12,d1	;noname
		bra	_pm_continue
_Pmdn_rx:	moveq	#2,d0		
		moveq	#3,d1	;item 3
		bra	_pm_continue
_Pmln_rx:	moveq	#3,d0		
		moveq	#2,d1	;text 2
		bra	_pm_continue
_Pmlr_rx:	moveq	#4,d0
		moveq	#6,d1 ;12,d1	;"no name menu item 11"
		bra	_pm_continue
_Pmdr_rx:	moveq	#5,d0		
		moveq	#7,d1 ;12,d1	;"no name menu item 11"
		bra	_pm_continue

_Pmso_rx:
		moveq	#7,d0	;paint mode 7=clear//none...
		moveq	#1,d1	;menu item #1 "range"
		bsr.s	_pm_continue
		;bsr.s	_pm_continue	;do like a normal mode sup
		;digipaint pi

_Rang_rx:				;range mode immediate
	move.b	#7,EffectNumber_(BP)
*	xjsr	ShowRange		;update range disp bar.	

	xjsr	RangeBarRGB
	xjsr	ViewBarHam

	;ensure that "blend" slider is on, at least 1 way
	lea	ShadeOnOffNum_(BP),a0	;#1=hor, #2=ver, #3=both, #0=none
	tst.b	(a0)
	bne.s	9$	;ok, at least 1 direction set on shade 2way prop
	moveq	#3,d1	;select 'both way shading' direction
	bra	dosetst	;sup 2way propgadget
9$
	;digipaint pi;rts
	bsr	refresh_if_ctrl	;digipaint pi

	moveq	#7,d0	;"internal" effect #2
;;;	moveq	#0,d1	;menu item #0, "normal" (Pmcl)
;;;	bra	enda_fx
;;;;enda_fx:
		;june12...only "refgad" if new-or-old effect='stretch'
	cmp.b	#1,EffectNumber_(BP)	;old effect=stretch?
	beq.s	1$			;yep...get refresh
	cmp.b	#1,d0			;new effect=stretch?
	bne.s	2$			;nope...skip refresh
1$	;want refresh...to/from stretch sliders
	tst.b	FlagCtrl_(BP)		;control/sliders displayed?
	beq.s	2$			;nope...so no slider refresh
	st	FlagNeedGadRef_(BP)
2$


	move.b	d0,EffectNumber_(BP)
	sne	FlagEffects_(BP)	;true if any effects turned on
	cmp.b	#1,d0			;effect# = #1 = sizd offset to rtn, start of table
	seq	FlagStretch_(BP)
	st	FlagNeedGadRef_(BP)	;gets remove/add of apro gadgets
	sf	FlagRotate_(BP)

	;;moveq	#7,d0		;"Real" paint number ("normal//Pmcl)
	;;bra	_pm_continue2	;d1=menu item#
	;rts
	rts	;PMSO....digipaint pi



;digipaint pi
;_Pmcl_rx:	
;	moveq	#7,d0		
;	moveq	#0,d1	;menu item #0, "normal"
;	bra.s	_pm_continue
_Pman_rx:
	moveq	#8,d0
	moveq	#8,d1	;.l	d0,d1	;menu # same item#
	bra.s	_pm_continue
_Pmor_rx:
	moveq	#9,d0
	moveq	#9,d1	;.l	d0,d1	;menu # same item#
	bra.s	_pm_continue
_Pmxo_rx:
	moveq	#10,d0
	moveq	#10,d1 ;#5,d1	;.l	d0,d1	;menu # same item#
	bra.s	_pm_continue
_Pmco_rx:
	moveq	#11,d0
	moveq	#4,d1	;menu item #4
	;bra.s	_pm_continue

_pm_continue:	;d0=paint number, d1=menu item number for text/name
	;june12...only "refgad" if old effect='stretch'
	cmp.b	#1,EffectNumber_(BP)	;old effect=stretch?
	bne.s	2$
	;june23;tst.b	FlagCtrl_(BP)		;control/sliders displayed?
	;june23;beq.s	2$			;nope...so no slider refresh
	st	FlagNeedGadRef_(BP)
2$
		;digipaint pi...refresh if rotate is involved
	cmp.b	#6,EffectNumber_(BP)	;old effect=stretch?
	bne.s	3$
	;june23;tst.b	FlagCtrl_(BP)		;control/sliders displayed?
	;june23;beq.s	2$			;nope...so no slider refresh
	st	FlagNeedGadRef_(BP)
3$
	sf	FlagRotate_(BP)

	clr.b	EffectNumber_(BP)	;clear all fx
	sf	FlagEffects_(BP)	;true if any effects turned on
	sf	FlagStretch_(BP)
	sf	FlagRotate_(BP)

_pm_continue2:	;d0=paint number, d1=menu item number for text/name
		;after fx setup
	move.b	d1,ModeNumber_(BP)
	move.b	d0,PaintNumber_(BP)
	sf	FlagRub_(BP)		;kill rub thru unless asked for
	st	FlagRedrawPal_(BP)	;tool.code.i, redoes the range box gadgets...SEP091990
					;sup modenameptr for hires text line
	xref	MENU3
	lea	MENU3,a0

	move.l	ModeNamePtr_(BP),d0	;pts to 2nd byte of menuitem-string
	beq.s	009$			;no "old" name stringptr?
	move.l	d0,a1
*	move.b	#' ',-1(a1)		;remove "*" from menuitem
009$
	st	FlagNeedText_(BP)	;june20...moved *here* from just b4 rts
	suba.l	a1,a1			;a1=0 (null name ptr)
	cmp.b	#12,d1			;"no name"?
	beq.s	enda_smn

;find menuitem->string, get "new mode name"-> ModeNamePtr
	move.l	mu_FirstItem(a0),a1
	move.w	d1,d0			;menu item# to find
	bra.s	2$
1$	move.l	(a1),a1			;link to next menuitem...skip a name//subitem
	subq	#1,d0			;keep count
2$	bne.s	1$			;done skipping mode names?
	move.l	mi_ItemFill(a1),a1	;A1 = menuitem's IntuiText
	move.l	it_IText(a1),a1	 	;from string
	;lea	1(a1),a1		;skip '*' (or "_")
;JULY131990;	move.b	#'*',(a1)+	;intuition menu display
;JULY131990; NOTE:probably can disable the whole little section...
*	move.b	#'*',(a1)+		;intuition menu display...REENABLED AUG081990
enda_smn:
	move.l	a1,ModeNamePtr_(BP)
	xjsr	SetupModeName		;modenames.asm, july111990

;june20;enda_smn:
;june20;st	FlagNeedText_(BP)
	RTS


 ifeq 1
ClearMenuStars:	;remove "*"s from all mode menu items
		;note, a0=menu structure ptr, valid
	movem.l	d0/a0/a1,-(sp)
		;find menuitem->string, get "new mode name"-> ModeNamePtr
	move.l	mu_FirstItem(a0),d0
1$	move.l	d0,a1
	move.l	mi_ItemFill(a1),a0	;A0 = menuitem's IntuiText
	move.l	it_IText(a0),a0		;a0=string-for-menutext
	move.b	#' ',(a0)

	move.l	(a1),d0
	bne.s	1$

	movem.l	(sp)+,d0/a0/a1
	RTS
 endc


_Prin_rx:	;Picture_Print:
	;DIGIPAINT PI;st	FlagFrbx_(BP)
	xjmp	InitPrintGads
	;xjmp	InitPrint	;PrintRoutine	;printrtns.o
	;rts


_Lo24_rx:	;call up filename requester, 24 bit load
	move.l	#'Open',LS_String_(BP)	;requester sez it all
	st	Flag24_(BP)
	st	FlagOpen_(BP)	;flag sez why FileRequester is alive
	bra.s	continue24

_Sa24_rx:	;call up filename requester, 24 bit save
	;xjsr	FindRGB		;rgbrtns
	xref Datared_
	tst.l	Datared_(BP)	;rgb array?
	bne.s	5$
	st	FlagDisplayBeep_(BP)
	rts
5$
	move.l	#'Save',LS_String_(BP)	;requester sez it all
	st	Flag24_(BP)
	st	FlagSave_(BP)	;flag sez why FileRequester is alive
	bra.s	 continue24

_Load_rx:	;call up filename requester
	bsr	EndFileRequ		;AUG201990....really just need to clear out dirnamebuffer?
	move.l	#'Open',LS_String_(BP)	;requester sez it all
	st	FlagOpen_(BP)	;flag sez why FileRequester is alive
	bra.s	cont_picstuff

_Save_rx:	;call up filename requester
	bsr	EndFileRequ		;AUG201990....really just need to clear out dirnamebuffer?
	move.l	#'Save',LS_String_(BP)	;requester sez it all
	st	FlagSave_(BP)	;flag sez why FileRequester is alive
cont_picstuff:
	sf	Flag24_(BP)
continue24:
	sf	FlagBrush_(BP)	;say this is a file load
	sf	FlagFont_(BP)	;this flag only pertains to 'file requester'
	SF	FlagCompFReq_(BP) ;file requester...NOT IN composite/sframestore mode?
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	bsr	setup_imagedirname	;NOV91
	bra	do_ShowFReq
	
_Bwpa_rx: ;black and white palette, digipaint pi
	xref BlackAndWhites
	;lea	BlackAndWhites,A2
	pea	BlackAndWhites
	bra.s	_newpalette

_Test_rx:
	xjmp	ShowColor
	rts

_Depa_rx: ;default palette, digipaint pi
	xref DefaultColors
	;lea	DefaultColors,A2
	pea	DefaultColors
_newpalette:

	lea	FlagRemap_(BP),a0	;HANDLE REMAPPING flag
	tst.b	(a0)			;if flag NOT set,
	bne.s   2$ ;alrdy_copt		;...then EXCHG LongClrTab=>FileClrTab
	st	(a0)

	lea	FileColorTable_(BP),a0	;move Long/Exist Colors->File
	lea	LongColorTable_(BP),a1  ;...allows a remap later
	moveq	#(16-1),d0
1$	move.l	(a1)+,(a0)+
	dbf	d0,1$
2$
	move.l	(SP)+,a0 ;a2,a1			;a2=color table
	lea	LongColorTable_(BP),a1

	movem.l	a2-a4,-(sp)		;STACK a2-a4 probably not needBsaved?

	moveq	#16-1,d0
setupdefault:
	;move.l	(A0)+,d1
	;move.l	d1,(a1)+
	move.l	(a0)+,(a1)+
	dbf	D0,setupdefault
	movem.l	(sp)+,a2-a4		;DE-STACK

	;xjsr	ComparePalettes	;iffload, compares filecolortable<->longcolors
	;beq.s	3$
		;redo lutable every color change
	cbsr	CreateDetermine	;enable painting with new palette
	st	FlagRefHam_(BP)	;main loop request for updatepalette/ucm
	st	FlagRedrawPal_(BP)	;used with flagrefham
3$	rts


_Pund_rx:	;palette undo routine (can be used instead of remap)
	st	FlagRefHam_(BP)	;main loop request for updatepalette/ucm

	lea	FlagRemap_(BP),a0
	tst.b	(a0)
	seq	(a0)		;flips remap flag, it works...(see _rema)
	bsr.s	swap_fctables
	beq.s	ea_pund		;nothing doing...(zeros in color table)
	xjsr	ComparePalettes	;iffload, compares filecolortable<->longcolors
	beq.s	ea_pund		;same colors...no remap
	bsr	ScreenArrange	;cbsr	HideToolWindow	;MAY23
	cbsr	CreateDetermine	;march13'89...keep up with 'palette-undo's?
	;xjsr	ShowPalette	;showpal.o...redo 'brite bars, etc'
	xref FlagNeedShowPal_
	st	FlagNeedShowPal_(BP)	;main loop trigger 4 showpallette call
	;st	FlagColorMap_(BP)	;may01
	xref FlagGrayPointer_
	st	FlagGrayPointer_(BP) ;usecolormap only does hires gray loadrgb4
ea_pund:
	bra	copycolors_endremap	;MAY23
	;MAY23;sf	FlagRemap_(BP)	;err'd...no ask for remap status now
	;MAY23;rts

swap_fctables:	;uses/destroys d0/d1/d2/a0/a1, swap File/Longword color tables
	bsr.s	TestFileColorsZero
	beq.s	enda_swapfc
	lea	FileColorTable_(BP),a0	  ;Long/Exist Colors<exchg>FileColors
	lea	LongColorTable_(BP),a1 ;...allows a remap later
	moveq	#(16-1),d0
swap_Fct_Lct:	move.l	(a0),d1
		move.l	(a1),d2
		move.l	d1,(a1)+
		move.l	d2,(a0)+
		dbf d0,swap_Fct_Lct
	moveq	#-1,d0		;return NE if successful
enda_swapfc:
	rts	;swap_fctables

TestFileColorsZero:
	moveq	#16-1,d0
	lea	FileColorTable_(BP),a0
tfczero_loop:
	tst.l	(a0)+
	bne.s	9$
	dbf	d0,tfczero_loop
	moveq	#0,d0	;return flag EQUAL if "all black" (zeros)
9$	rts

_Rema_rx:	;Palette_Remap:
	tst.b	FlagRemap_(BP)
	bne.s	9$		;flag set when user 'copy color to' changes cmap
	bsr.s	swap_fctables	;exch file/current color tables
	beq.s	ea_rema		;nothing doing...(zeros in color table)
	xjsr	ComparePalettes	;iffload, compares filecolortable<->longcolors
	beq.s	ea_rema		;same colors...no remap
9$	;LATEST 02-21-89
	cbsr	HideToolWindow

	cbsr	CreateDetermine	;enable painting with new palette
;AUG241990;	st	FlagRemap_(BP)	;tells iff_load to really do a remap, not load
;AUG241990;	cbsr	IFF_Load	;needs to see FlagRemap=TRUE, DOES REMAP
		;AUG241990...iff-load crashes with remap...
		;....use "wholeham" to re-do this, WONT WORK FOR NON-RGB MODE
	bsr	_Wham_rx	;sets flag for whole screen re-do

	tst.l	PasteBitMap_Planes_(BP)	;carrying a brush, now?
	beq.s	copycolors_endremap	;MAY23;ea_rema			;no...else
	bsr	_UnShowPaste
	bsr	_CopyScreenSuper		;save bup of screen

copycolors_endremap:
		;MAY23 late....after palette undo, then copy curt->file
	lea	FileColorTable_(BP),a0	  ;Long/Exist Colors<exchg>FileColors
	lea	LongColorTable_(BP),a1 ;...allows a remap later
	moveq	#(16-1),d0
move_lct_fct:
	move.l	(a1)+,(a0)+
	dbf d0,move_lct_fct

ea_rema:
	sf	FlagRemap_(BP)	;dont do it 2x
	rts

_Lopa_rx:	;Palette_Load:		;call up filename requester
	move.l	#'Open',LS_String_(BP)	;requester sez it all
	st	FlagOpen_(BP)
	bra.s	cont_palstuff

_Sapa_rx:	;Palette_Save:		;call up filename requester
	move.l	#'Save',LS_String_(BP)
	st	FlagSave_(BP)
cont_palstuff:
	sf	Flag24_(BP)
	sf	FlagBrush_(BP)		;say this is a file load
	sf	FlagFont_(BP)		;this flag only for 'file requester'
	st	FlagPalette_(BP)
	sF	FlagCompFReq_(BP)	;file requester...NOT IN composite/framestore mode?
	SF	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)


do_ShowFReq:
	;april28
	;bsr	grab_arg_a0	;get a0 ptr ascii command
	;beq	GadRefRTS	;not remote...just ask for gadref, g'way
	;xjmp	ShowFReq	;showfreq.o, SHOW File REQuester
	;DIGIPAINT PI;st	FlagFrbx_(BP)	;force 'tools to front' MAY06'89 (in case kybd cmd)
	bra	GadRefRTS	;ask mainloop for gadget ref

_Tvar_rx: ;remote/rexx only, text string gadget
	bsr	grab_srxarg
	xref TextStringBuffer_		;string gadget ascii
	lea	TextStringBuffer_(BP),a2
	bra.s	finish_stringstuff

_Fnam_rx: ;rexx only, filename string
	bsr	grab_srxarg		;grab string arg
	lea	FilenameBuffer_(BP),a2
	bra.s	finish_stringstuff

_Dnam_rx: ;rexx only, dirname string
	bsr	grab_srxarg
	lea	DirnameBuffer_(BP),a2
	;bra.s	finish_stringstuff
finish_stringstuff:
	move.l	a0,a1				;stringptr from remote
	st 	FlagNeedGadRef_(BP)			;display new string (if enuff time)
	xref 	TracePrintString_			;main.msg.i
	xref 	FlagPrintString_
	move.l	a1,TracePrintString_(BP)	;adr for trace-out string print
	st	FlagPrintString_(BP)
	xjsr	copy_string_a1_to_a2
	bra	_Dsel_rx		;actually change to the directory NOV91
	;rts

_Size_rx: ;x,y for use with 'sizer' (remote only)
	;bsr	_InitSizer
	;movem.W	MyDrawX_(BP),d0/d1
	;movem.W	d0/d1,NewSizeX_(BP)
	;bsr	grab_xyrxarg		;OPTIONAL x,y coord from remote
	;movem.W	NewSizeX_(BP),d0/d1
	;movem.W	d0/d1,MyDrawX_(BP)	;in case no x,y in msg, use defaults
	;st	FlagNeedText_(BP)
	;rts

	bsr	_InitSizer
	movem.W	MyDrawX_(BP),d0/d1

	movem.w	d0/d1,-(sp)
	movem.W	d0/d1,NewSizeX_(BP)

;MAY31;	bsr	grab_xyrxarg		;OPTIONAL x,y coord from remote
;MAY31;grab_xyrxarg:	;grab INTEGER x,y args from rexmsg
	bsr	grab_arg_a0
	beq.s	ea_Size_rx
	lea	4(a0),a0	;addq.l	#4,d0	;skip past 4char cmd//ascii action code
	;NO!;move.l	d0,a0	;point into command string (destroy'g a0, msgptr)

		;MAY09'89...helps w/penu a-code (if no x,y)
	move.b	(a0),d0
	beq.s	ea_Size_rx
	cmp.b	#($0d+1),d0
	bcs.s	ea_Size_rx


	bsr	_cva2i	;main.o	;ascii to int, result in D0
	tst.L	d0
	bmi.s	ea_Size_rx		;none converted
	st	FlagNeedText_(BP)

;		;validate MyDrawX,Y arg
;	move.w	BigPicWt_W_(BP),d1
;	subq	#1,d1
;	cmp.w	d1,d0	;MyDrawX_(BP),d0
;	bcs.s	7$
;	move.w	d1,d0
;7$
	add.w	#31,d0
	asr.w	#5,d0	;/32
	asl.w	#5,d0	;*32
	move.w	d0,MyDrawX_(BP)

	bsr	_cva2i		;gray 'y' from msg record
	tst.L	d0
	bmi.s	ea_Size_rx		;none conv'd

	bra.s	skip_altentry
finish_size_rx:		;kludgey...ONLY from "Whoo" hires/toggler
	movem.W	MyDrawX_(BP),d0/d1
	movem.w	d0/d1,-(sp)	;"Reason for being"...FIX STACK
	move.w	#TOASTMAXHT,d0		;'y' ht for wtog switcher
skip_altentry:

		;validate MyDrawY arg
;	move.w	BigPicHt_(BP),d1
;	subq	#1,d1
;	cmp.w	d1,d0		;MyDrawY_(BP),d1
;	bcs.s	89$
;	move.w	d1,d0	;use max if 'over bounds'...MyDrawY_(BP)
;89$
	add.w	#1,d0
	asr.w	#1,d0	;/2
	add.w	d0,d0	;*2
	move.w	d0,MyDrawY_(BP)
ea_Size_rx
	;movem.L Zeros_(BP),d0/d1 ;clear upper (6bytes)
	moveq	#0,d0
	moveq	#0,d1
	movem.W	MyDrawX_(BP),d0/d1	;x,y (existing, if not frm msg)

	;;rts

   ;.enda...may31.
	movem.W	MyDrawX_(BP),d0/d1	;in case no x,y in msg, use defaults
	tst.w	d0
	bne.s	10$
	move.w	BigPicWt_W_(BP),d0
10$	tst.w	d1
	bne.s	11$
	move.w	BigPicHt_(BP),d1
11$	movem.W	d0/d1,NewSizeX_(BP)
	movem.W	(sp)+,d0/d1

	movem.W	d0/d1,MyDrawX_(BP)
	st	FlagNeedText_(BP)
	rts

_Move_rx: ;x,y
	bsr	grab_xyrxarg	;sup MyDraw(X,Y)_(BP)
;_Mova_rx:	;"move again" does a move, but no new x,y (internal mousemoves)
	xjmp	Move_entry	;MouseRtns.o, just a drawbrush BUT smooth, too

_Pend_rx: ;{x{y}} x,y pen down, big pic assumed
	bsr	grab_xyrxarg
;_Pena_rx:	;"pen again"...pen down, no change to x,y
	xjmp	Pend_entry	;mousertns.o

_Penu_rx: ;pen up
	bsr	grab_xyrxarg	;OPTIONAL x,y coord from remote
	xjmp	Penu_entry	;mousertns.o

grab_srxarg:	;grab STRING from rexmsg, ptr in a0, zero flag set
	st	FlagPrintString_(BP)
	bsr.s	grab_arg_a0
	lea	4(a0),a0	;LEAve ptr just past 4char ascii cmd
	rts

grab_arg_a0:
	MOVEM.L	d1/a1,-(sp)
	move.l	MsgPtr_(BP),d0
	move.l	d0,a0
	beq.s	enda_msgarg	;no message? (shouldn't be...)

	move.l	LN_NAME(a0),d1
	beq.s	notcmdmsg
	move.l	d1,a1
	cmp.b	#'R',(a1)+	;Allowed names: REMOte and REXX
	bne.s	notcmdmsg
	cmp.b	#'E',(a1)+
	bne.s	notcmdmsg
	cmp.b	#'X',(a1)+
	bne.s	ckremomsg	;notcmd
	cmp.b	#'X',(a1)+
	bne.s	notcmdmsg
	tst.b	(a1)		;name ends with null
	bne.s	notcmdmsg	;not proppa name
	cmp.l	#(RXCOMM!RXFF_RESULT),rm_Action(a0)
*	cmp.l	#(RXCOMM!(1<<17)),rm_Action(a0)
	beq	cmdmsgX
	cmp.l	#RXCOMM,rm_Action(a0)
	bne.s	notcmdmsg	;not a 'command line'
cmdmsgX
	move.l	rm_Args(a0),d0	;rexx arg string?
	beq.s	notcmdmsg		;no ptr
	move.l	d0,a0
	bra.s	enda_msgarg

ckremomsg:	;found 'r' 'e' look for 'm' 'o' (finish scanning name)
	cmp.b	#'M',-1(a1)		;last char (scanned past it...)
	bne.s	notcmdmsg
	cmp.b	#'O',(a1)+
	bne.s	notcmdmsg
	lea	(4+MN_SIZE)(a0),a0	;msg= exec msg + (4charREMO) +cmd str

enda_msgarg:
	cmp.l	#0,a0	;FLAG SET?
	MOVEM.L	(SP)+,d1/a1
	rts	

notcmdmsg:
	moveq	#0,d0	;cmp.l	#0,a0	;FLAG SET?
	move.l	d0,a0
	MOVEM.L	(SP)+,d1/a1
	rts	;grab_arg_a0

grab_xyrxarg:	;grab INTEGER x,y args from rexmsg
	bsr.s	grab_arg_a0

	;?;helps with airbrush/fake "move" msg?
	;?;beq.s	9$
	tst.l	MsgPtr_(BP)
	;beq.s	9$		;current msg?

	lea	4(a0),a0	;addq.l	#4,d0	;skip past 4char cmd//ascii action code
	;NO!;move.l	d0,a0	;point into command string (destroy'g a0, msgptr)

		;MAY09'89...helps w/penu a-code (if no x,y)
	move.b	(a0),d0
	beq.s	9$
	cmp.b	#($0d+1),d0
	bcs.s	9$


	bsr.s	_cva2i	;main.o	;ascii to int, result in D0
	tst.L	d0
	bmi.s	9$		;none converted
	st	FlagNeedText_(BP)
		;validate MyDrawX,Y arg
;;	move.w	BigPicWt_W_(BP),d1
	move.w	751,d1
;	subq	#1,d1
	cmp.w	d1,d0	;MyDrawX_(BP),d0
	bcs.s	7$
	move.w	d1,d0
7$	
	asr.w	#1,d0				;4.0/2000 paint fix  031295DEH
	move.w	d0,MyDrawX_(BP)

	bsr.s	_cva2i		;gray 'y' from msg record
	tst.L	d0
	bmi.s	9$		;none conv'd
		;validate MyDrawY arg
	move.w	BigPicHt_(BP),d1
	subq	#1,d1
	cmp.w	d1,d0		;MyDrawY_(BP),d1
	bcs.s	89$
	move.w	d1,d0	;use max if 'over bounds'...MyDrawY_(BP)
89$	
	move.w	d0,MyDrawY_(BP)
9$
	;movem.L	Zeros_(BP),d0/d1	;clear upper (6bytes)
	moveq	#0,d0
	moveq	#0,d1
	movem.W	MyDrawX_(BP),d0/d1	;x,y (existing, if not frm msg)
	rts

_cva2i:
	xjmp	cva2i	;main.o	;ascii to integer a0=textptr, d0=res or 'minus'

grab_rgbarg:	;grab integer rgb#s args from rexmsg, rtn in d0/d1/d2
	;NOTE: GRAY specified ok by just the 'red' digit...
	st	FlagPrintRgb_(BP)
grab_rgbarg2:	;same thing, but without 'flag print rgb'
	st	FlagNeedText_(BP)
	bsr	grab_arg_a0
	;beq.s	9$	;wha?
	beq.s	90$		;no valid arg, probably an "internal" call...
	lea	4(a0),a0	;skip past 4char cmd//ascii action code
	move.w	#15,-(sp)	;stack blue default, collect at end
	move.w	#15,-(sp)	;stack green default, collect at end
	move.w	#15,-(sp)	;stack red default, collect at end

	bsr.s	_cva2i		;main.o	;ascii to int
	tst.L	d0
	bmi.s	8$	;bum? outta here...use resta defaults
	move.w	d0,(sp)		;just read red valu
	move.w	d0,2(sp)	;new default green
	move.w	d0,4(sp)	;new def blu

	bsr.s	_cva2i		;main.o	;ascii to int
	tst.L	d0
	bmi.s	8$
	move.w	d0,2(sp)	;new default green
	move.w	d0,4(sp)	;new def blu

	bsr.s	_cva2i		;main.o	;ascii to int
	tst.L	d0
	bmi.s	8$
	move.w	d0,4(sp)	;new def blu

	;move.w	(sp)+,d0	;red
	;move.w	(sp)+,d1	;green
	;move.w	(sp)+,d2	;blue
8$	movem.w	(sp)+,d0/d1/d2
9$	rts
90$:	;no arg, internal call, from customgads.o
	move.w	Paint8red_(BP),d0
	move.w	Paint8green_(BP),d1
	move.w	Paint8blue_(BP),d2
	rts

_Pixy_rx:	;Pick from x,y in message DigiPaint PI
	xref WindowPtr_		;big pic window
	bsr.s	grab_rgbarg		;2 words, anyway....
	asr.w	#1,d0			;4.0/2000 fix03295DEH
	move.l	WindowPtr_(BP),a3
	move.l	a3,d2			;NOV91...window arg really in d2
	clr.l	LastM_Window_(BP)	;NOV91....check label not_from_toolwindow in MouseRtns.asm

		;NOV91...setup fill table, if needed
	xref	FillTblPtr_
	tst.b	FlagFillMode_(BP)
	beq.s	1$
	tst.l	FillTblPtr_(BP)		;have a fill-color-table?
	bne.s	1$			;already have it?
	movem.l	d0-d3/a0-a2,-(sp)
	xjsr	AllocFillTbl		;get table to hold color, MouseRtns.asm
	xjsr	UnShowPaste		;cutpaste.asm, remove cutout brush while picking...AUG311990
	movem.l	(sp)+,d0-d3/a0-a2
1$

	xjsr	Move_Pick		;mouseroutines.asm

	;move.b	d0,Paintred_(BP)
	;move.b	d1,Paintgreen_(BP)
	;move.b	d2,Paintblue_(BP)
	lea	LongColorTable_(BP),A0	;address of in-use color map
	move.l	(18*4)(a0),Paintred_(BP)
	bra.s	finish_rgbrtn

_8rgb_rx:	;8bit paint color set
	bsr	grab_rgbarg
	xref Paint8red_
	xref Paint8green_
	xref Paint8blue_
	move.W	d0,Paint8red_(BP)
	move.W	d1,Paint8green_(BP)
	move.W	d2,Paint8blue_(BP)
	asr.w	#4,d0
	asr.w	#4,d1
	asr.w	#4,d2
	bra.s	cont_rgb_remo

_Prgb_rx:	;Paint color set
	bsr	grab_rgbarg
cont_rgb_remo:
	move.b	d0,Paintred_(BP)
	move.b	d1,Paintgreen_(BP)
	move.b	d2,Paintblue_(BP)
Prgb_quick:	;internal call, from "Al24"....setup specific color
	lea	LongColorTable_(BP),A0	;address of in-use color map
	move.l	Paintred_(BP),(18*4)(a0)
	bra.s	finish_rgbrtn
_Brgb_rx:	;Background color set
	bsr	grab_rgbarg
	move.b	d0,BPaintred_(BP)
	move.b	d1,BPaintgreen_(BP)
	move.b	d2,BPaintblue_(BP)
	lea	LongColorTable_(BP),A0	;address of in-use color map
	move.l	BPaintred_(BP),(17*4)(a0)
	bra.s	finish_rgbrtn
_Trgb_rx:	;Transparent color set
	bsr	grab_rgbarg
	move.b	d0,Transpred_(BP)
	move.b	d1,Transpgreen_(BP)
	move.b	d2,Transpblue_(BP)
	;bra.s	finish_rgbrtn
finish_rgbrtn:
	st	FlagNeedText_(BP)
	st	FlagRefHam_(BP)	;main loop request for updatepalette/ucm
	rts


_Fsel_rx:	;file selection
	xjmp	FSelRoutine	;dirroutines
_Dsel_rx:	;directory selection
	xjmp	DirRoutine	;dirroutines

;_Heon_rx: ;help on
;	st	FlagHelp_(BP)
;	bra.s	dohelp
;_Heof_rx: ;help off
;	sf	FlagHelp_(BP)
;	bra.s	dohelp
;_Help_rx: ;toggle
;	lea	FlagHelp_(BP),a0
;	tst.b	(a0)
;	seq	(a0)
;dohelp:	;bra.s	_Dflt_rx
;	xjmp	LoadPictureFile	;default.o,loads ".gads" or ".help" file

_Dflt_rx:	;loads default files (incl' gadget picture file)
		;july081990....ensure not alloc'd from toaster area
		xref	ToastChipPtr_
		move.l	ToastChipPtr_(BP),-(sp)
		clr.l	ToastChipPtr_(BP)
	xjsr	LoadDefaultFiles	;Default.asm
		move.l	(sp)+,ToastChipPtr_(BP)
	rts

_Blcv_rx:	;install new blend curve, 1 arg (hex ok)=ptr to 256 byte table
	bsr	grab_arg_a0
	beq.s	9$	;wha?
	lea	4(a0),a0	;skip 4 char cmd ascii action code
	move.l	(a0),d0		;next 4 chars TREAT AS A POINTER
	beq.s	9$		;NULL PTR? noboom nogo
	btst	#0,d0		;real simple test, odd bit (boom guru adr)
	bne.s	9$		;odd, outta here, can't be addr
	move.l	d0,BlendCurvePtr_(BP)
9$	rts

	;** KEYBOARD ARROW KEYS **
	;;xref ScrollSpeedX_	;x,y both .w JUNE01

_Ksrt_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_rt	
1$
	bra	key_arrow_rt
*	xjmp	key_rtn_rt	;main.key.i

_Kslt_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_lt
1$
	bra	key_arrow_lt
	rts	
*	xjmp	key_rtn_lt	;main.key.i
	

_Ksup_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_up
1$
	rts	
*	xjmp	key_rtn_up	;main.key.i

_Ksdn_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_dn
1$	
	rts
*	xjmp	key_rtn_dn	;main.key.i


	;AUG291991;
	;** [SHIFTED] KEYBOARD ARROW KEYS **
	;;xref ScrollSpeedX_	;x,y both .w JUNE01

_Kssr_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_rt
1$	
	rts
*	xjmp	skey_rtn_rt	;main.key.i

_Kssl_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_lt
1$	
	rts
*	xjmp	skey_rtn_lt	;main.key.i

_Kssu_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_up
1$
	rts
*	xjmp	skey_rtn_up	;main.key.i

_Kssd_rx:
	;;clr.L	ScrollSpeedX_(BP)	;JUNE01...scroll+kybd
	tst.b	FlagMagnifyStart_(BP)
	beq.s	1$			;magnify not 'locked' yet
	move.l	MScreenPtr_(BP),d0
	beq.s	1$		;no mag screen, move bigpic
	move.l	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$		;move bigpic if mouse above magnify screen
	xjmp	MagMove_dn
1$	
	rts
*	xjmp	skey_rtn_dn	;main.key.i



	;** SIZER WINDOW **
_Nnar_rx: ;narrower button NEW SCREEN ;SIZER SCREEN HANDLING
	lea	NewSizeX_(BP),a0
	move.w	(a0),d0
	sub.w	#32,d0
	beq.s	9$
	move.w	d0,(a0)
9$	bra.s	endsizegads
_Nwid_rx: ;wider
	lea	NewSizeX_(BP),a0
	move.w	(a0),d0
	add.w	#32,d0
	cmp.w	#1024+1,d0	;max wt 1024, always even#
	bcc.s	9$
	move.w	d0,(a0)
9$	bra.s	endsizegads
_Nsho_rx: ;shorter
	lea	NewSizeY_(BP),a0
	move.w	(a0),d0
	sub.w	#40,d0
	bcs.s	9$
	cmp.w	#MINHT,d0	;minimum #lines
	bcs.s	9$
	move.w	d0,(a0)
9$	bra.s	endsizegads
_Nlsh_rx: ;little shorter
	lea	NewSizeY_(BP),a0
	move.w	(a0),d0
	subq.w	#2,d0
	bcs.s	9$
	cmp.w	#MINHT,d0	;minimum #lines
	bcs.s	9$
	move.w	d0,(a0)
9$	bra.s	endsizegads

_Nlta_rx: ;little taller
	lea	NewSizeY_(BP),a0
	move.w	(a0),d0
	addq.w	#2,d0
	cmp.w	#1024+1,d0	;max ht 1024, always even#
	bcc.s	9$
	move.w	d0,(a0)
9$	bra.s	endsizegads

_Ntal_rx: ;taller
	lea	NewSizeY_(BP),a0
	move.w	(a0),d0
	add.w	#40,d0
	cmp.w	#1024+1,d0	;max ht 1024, always even#
	bcc.s	9$
	move.w	d0,(a0)
9$	bra.s	endsizegads



_Ndfl_rx: 	;new default (revert)
	move.w	DefaultX_(BP),NewSizeX_(BP)
	move.w	DefaultY_(BP),NewSizeY_(BP)

endsizegads:
	st	FlagNeedText_(BP)
	rts



		;grab "user setup" fields from sizer window
	xref bmhd_rastwidth_	;'parm' for openbigpic
	xref bmhd_rastheight_
	xref bmhd_nplanes_	;'parm' for InterpCAMG
	xref CAMG_
	xref bmhd_xaspect_
	xref bmhd_yaspect_

	xref UnDoBitMap_
	xref UnDoBitMap_Planes_


_Opsc_rx:	;Picture_Open: (only called by remote, mainloop and i-lace button)
	;DIGIPAINT PI;LATEST;st	FlagFrbx_(BP)	;ask for 'screens to front' apro' time
	bsr	_EndSizer
	bsr.s	sup_opsc

	bne.s	did_1st_opsc

	xref Initializing_
	tst.b	Initializing_(BP)
	;beq.s	did_1st_opsc	;not startup, leave with gads 'size smaller'

		;MAY06'89 elim bug....cant get original back....
		;restore original scr if cant get new size
;JULY051990;	bne.s	opsc_initting
	bsr	_InitSizer	;EQUAL flag means didn't open...sizer revert
	
	movem.W	NewSizeX_(BP),d0/d1

	movem.w	d0/d1,-(sp)
	movem.W	DefaultX_(BP),d0/d1
	movem.W	d0/d1,NewSizeX_(BP)
	bsr.s	sup_opsc	;re-open with "original" size
	movem.w	(sp)+,d0/d1

	movem.W	d0/d1,NewSizeX_(BP)
	bra.s	did_1st_opsc
				;may06 (end)

opsc_initting:
	xjsr	FreeUnDo	;MAY13.....fix bug, PAL sup w/256/216 mismatch


	moveq	#(1024/64),d0
	move.w	d0,-(sp)	;STACK.w = loopcounter, #tries to open scr
do_trysmall:
	bsr.s	try_smaller_scr	;->sup_opsc->openbigpic result is zero flag
	bne.s	did_sm_opsc	;yep, did 'smaller' open scr
	subq.w	#1,(sp)		;stack.w loopcounter
	bne.s	do_trysmall
did_sm_opsc:
	lea	2(sp),sp	;deSTACK loop counter

did_1st_opsc:
	beq.s	_InitSizer	;EQUAL flag means didn't open...sizer revert
	rts


try_smaller_scr:	;turn on sizer mode, reduce newsize width/ht, openscr
	bsr	_Nsho_rx 	;shorter
	tst.b	FlagLace_(BP)
	beq.s	1$
	bsr	_Nsho_rx	;shorter (again) for interlace
1$	bsr	_Nnar_rx	;narrower (typical startup #384-->#320)
	bsr	_Nnar_rx	;narrower

sup_opsc:	;sup OpenBigPic (screen) call, rtns zero flag, calls InterpCAMG
	move.w	NewSizeX_(BP),bmhd_rastwidth_(BP)	;'parm' for openbigpic
	move.w	NewSizeY_(BP),bmhd_rastheight_(BP)
	move.B	FlagLaceNEW_(BP),FlagLace_(BP)
	move.b	#6,bmhd_nplanes_(BP)
	clr.l	CAMG_(BP)		;InterpCAMG (from openbigpic) will reset
	clr.b	bmhd_xaspect_(BP)	;let openbigpic/intercamg set aspect
	move.b	#11,bmhd_yaspect_(BP)

_OpenBigPic:
	xjmp	OpenBigPic	;main.o

_Csiz_rx:	;"change size" routine...inits "requester" DIGIPAINT MENU OPTION
	;move.w	BigPicWt_W_(BP),NewSizeX_(BP)	;'parm' for openbigpic
	;move.w	BigPicHt_(BP),NewSizeY_(BP)
_InitSizer:
	xjmp	InitSizer	;then redo sizer
	;rts

_Nioo_rx: ;new interlace on/off (GADGET ONLY)
	lea	FlagLaceNEW_(BP),a0
	tst.b	(a0)
	seq	(a0)	;flip flag
	bra.s	interlace_new
_Nion_rx: ;new interlace ON
	st	FlagLaceNEW_(BP)
	bra.s	interlace_new
_Niof_rx: ;new interlace OFF
	sf	FlagLaceNEW_(BP)
interlace_new:
	st	FlagNeedGadRef_(BP)	;resets hiliting when fr/remote
	tst.l	ScreenPtr_(BP)	;screen open now, anyway?
	;beq	endsizegads	;gets text refresh
	bra	endsizegads	;gets text refresh, no immediate APRIL02'89

_Nsok_rx: ;new size ok, reopen with new screen size
	tst.l	ScreenPtr_(BP)
	beq.s	donewsize	;no scr? then endsizer (mainloop'll "Opsc")

	move.w	NewSizeX_(BP),d0
	cmp.w	BigPicWt_W_(BP),d0;'parm' for openbigpic
	bne.s	donewsize
	move.w	NewSizeY_(BP),d0
	cmp.w	BigPicHt_(BP),d0
	bne.s	donewsize
	move.B	FlagLaceNEW_(BP),d0
	cmp.B	FlagLace_(BP),d0
	beq.s	_Nsca_rx		;cancel 'closebigpic' if newsize=curt
donewsize:
	bsr.s	_EndSizer

_Clsc_rx:	;Picture_Close:
_CloseBigPic:
	xjmp	CloseBigPic	;main


_Nsca_rx: ;new size cancel
	xjsr	ResetSizer		;sizer.o, put "real" size back into sizer... MAY07
	tst.l	ScreenPtr_(BP)		;bigpic open?
	bne.s	_EndSizer		;HAVE a 'chip' picture...just end sizer
	tst.l	UnDoBitMap_Planes_(BP)	;no chip-pic, have undo scr?
	beq.s	_Quit_rx		;no pic, no undo, bye!
	bsr.s	_EndSizer
	bra	_Load_rx		;picture load (HAVE an undo...)


;;; Action Quia ;Quit - but 'ask' first
;;_Quia_rx:	;Picture_Quit:
;;	xjsr	ReturnMessage	;May09'89...helps remote user
;;	xjsr	ReallyQuitRtn	;canceler.o
;;	beq.s	quitrts
_Quit_rx:	;Picture_Quit:
	tst.b	FlagAlphapaint_(BP)
	beq	99$	
	xjsr	OpenAlphaScreen		;open or close the alpha screen! main.asm
99$
	st	FlagQuit_(BP)	;wait4mouse knows what 2 do with this...
	sf	FlagPale_(BP)	;don't Try to come up in Palette screen!
	st	FlagRedrawPal_(BP)
	sf	CurrentFrameNbr_(BP)  	;reopen only on frame 0!
		;june301990....eliminate error when 'Q' key (quit) during startup
	xref Initializing_
	clr.b	Initializing_(BP)	;only other place is in 'main.asm'
quitrts:
	rts

_EndSizer:
	xjmp	EndSizer	;clear out 'sizer' mode...NOT close/open bigpic
	;rts




	xref FlagFilePalette_
_Pfil_rx: ;use palette from file
	st	FlagFilePalette_(BP)
	bra.s	ea_newpal
_Pcur_rx: ;use current palette
	sf	FlagFilePalette_(BP)
	bra.s	ea_newpal
_Ptog_rx: ;toggle between current/file's palette
	lea	FlagFilePalette_(BP),a0
	bra.s	tog_newpal
	rts


	xref FlagCapture_
_X1on_rx:	;trace on
	st	FlagCapture_(BP)
	rts
_X1of_rx:	;trace off
	sf	FlagCapture_(BP)
	rts
_X1og_rx:	;trace toggle
	tst.B	FlagCapture_(BP)
	seq	FlagCapture_(BP)
	rts



	xref FlagHires_
_Sron_rx: ;shrink hires ON (re: picture loading)
	st	FlagHires_(BP)
	bra.s	ea_newpal
_Srof_rx: ;shrink hires OFF
	sf	FlagHires_(BP)
	bra.s	ea_newpal
_Sroo_rx: ;shrink hires toggle on/off
	lea	FlagHires_(BP),a0
tog_newpal:
	tst.b	(a0)
	seq	(a0)
ea_newpal:
	;st	FlagRequest_(BP)	;forces requester on if this a-code?
	bra	GadRefRTS		;sup gadget refresh flag and 'rts'

_Oklo_rx: ;ok-continue load (use Clbx to close/cancel)
	tst.b	FlagRequest_(BP)
	beq.s	norequ
	sf	FlagRequest_(BP)	;clear requester, now
	st	FlagNeedGadRef_(BP)
norequ:
	xjmp	Continue_Load

_Flix_rx:	;brush(scr?) flip x
	tst.l	PasteBitMap_Planes_(BP)	;have a brush?
	bne.s	_Flpx_rx
	rts
_Fliy_rx:	;brush flip y
	tst.l	PasteBitMap_Planes_(BP)	;have a brush?
	bne.s	_Flpy_rx
	st	FlagDisplayBeep_(BP)	;can't flip screen...
	rts
_Flpx_rx:	;brush(scr?) flip x
	cbsr	HideToolWindow
	xjmp	BFlipX
_Flpy_rx:	;brush flip y
	;JUNE19;st	FlagNeedShowPaste_(BP)
	xjmp	BFlipY	;BrushFx.asm, does a ham screen flip, only...bogus...

_Rotm_rx:	;brush rotate minus 90deg
	cbsr	HideToolWindow
	xjmp	BRotm	;BrushFx.o
_Rotp_rx:	;brush rotate plus 90deg
	cbsr	HideToolWindow
	xjmp	BRotp	;BrushFx.o

_Resi_rx:	;bum?
_Pixe_rx:	;bum?



	;TILE factors, how many 'repeats', TileX,Y stored as <<8 (really <<4, JUNE04)
_Txva_rx:	;tile x value
	bsr	grab_rgbarg	;actually, this subr grabs three args
	move.w	d0,TileX_(BP)
	bne.s	tiledone
	move.w	#$1<<4,TileX_(BP)
	bra.s	tiledone
	;st	FlagNeedText_(BP)	;flag calls for hires text display
	;rts
_Tyva_rx:	;tile y value
	bsr	grab_rgbarg	;actually, this subr grabs three args
	move.w	d0,TileY_(BP)
	bne.s	tiledone
	move.w	#$1<<4,TileY_(BP)
tiledone:
	st	FlagNeedText_(BP)	;flag calls for hires text display
	rts

_Txup_rx:
	lea	TileX_(BP),a0
	;move.w	#$100,d0		;incr
	move.w	#$10,d0		;incr ;JUNE
	bra.s	finish_tiler
_Txdn_rx:
	lea	TileX_(BP),a0
	bra.s	fintiledn		;decr
_Tyup_rx:
	lea	TileY_(BP),a0
	;move.w	#$100,d0		;incr
	move.w	#$10,d0		;incr JUNE04
	bra.s	finish_tiler
_Tydn_rx:
	lea	TileY_(BP),a0
fintiledn:
	;move.w	#-$100,d0		;decr
	move.w	#-$10,d0		;decr JUNE04
finish_tiler:
	move.w	(a0),d1
	add.w	d0,d1
	bpl.s	1$
	moveq	#0,d1
1$	tst.w	d1
	bne.s	2$
	;move.w	#$0100,d1
	move.w	#$0010,d1	;JUNE04
;2$	cmp.w	#(9*$0100),d1	;max tile?
2$	cmp.w	#(9*$010),d1	;max tile? JUNE04
	bcs.s	3$
	;move.w	#(9*$0100),d1	;=16*$100
	move.w	#(9*$0010),d1	;=16*$10 JUNE04
3$	move.w	d1,(a0)
	st	FlagNeedText_(BP)	;flag calls for hires text display
	rts	;enda tiler up/down gadgets


		;(Max,Mid,Min)(c,e,w) buttons to set sliders Center,Edge,Warp

_Maxc_rx:
	moveq	#0,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot0
_Midc_rx:
	move.w	#$7fff,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot0
_Minc_rx:
	moveq	#-1,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot0

_Maxe_rx:
	moveq	#0,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot1
_Mide_rx:
	move.w	#$7fff,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot1
_Mine_rx:
	moveq	#-1,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot1

_Maxw_rx:
	moveq	#0,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot5
_Midw_rx:
	move.w	#$7fff,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot5
_Minw_rx:
	moveq	#-1,d0
	;st	FlagNeedGadRef_(BP)	;cause remove/re-add
	;st	FlagRefProp_(BP)	;gets refresh of prop gadgets
	bra	setpot5

	xref FlagXLef_
	xref FlagXRig_
	xref FlagXSpe_

_Xlef_rx: ;left view, even lines (toggle on)
	st	FlagXLef_(BP)
	sf	FlagXRig_(BP)
	bra.s	tog_xon
_Xrig_rx: ;right view, odd lines (toggle on)
	sf	FlagXLef_(BP)
	st	FlagXRig_(BP)
	bra.s	tog_xon
_Xbot_rx: ;both view (toggle on)
	st	FlagXLef_(BP)
	st	FlagXRig_(BP)
tog_xon:
	tst.b	FlagLace_(BP)	;in interlace mode?
	beq.s	_Xoff_rx	;no...disable this
	st	FlagXSpe_(BP)
	rts
_Xoff_rx: ;disable
	sf	FlagXSpe_(BP)
	st	FlagXLef_(BP)
	st	FlagXRig_(BP)
	rts

_Bres_rx:	;brush restore
	;bsr.s	_Bdel_rx
	;SEP091990;xjsr	FreePaste	;MAY23
	xjsr	EndCutPaste		;kill the current brush.....SEP091990

		;...fall thru and call bswa to restore other


;;_DebugMe:	xjmp	DebugMe	;AUG311990
_Bswa_rx: ;swap brush restore is the same
	;;pea	_DebugMe(pc)	;AUG311990
	;;bsr.s	_DebugMe	;AUG311990
	xjmp	SwapAltPaste	;memories.o (Swap, alloc, free)AltPaste rtns
_Bdel_rx: ;delete SWAP brush
	xjmp	FreeAltPaste

_Bcop_rx: ;copy brush to alternate, by deleting alternate then 'swap'ing
	bsr.s	_Bdel_rx ;xjsr	FreeAltPaste	;free other brush (if any)...then fall thru
	;bsr.s	_Bswa_rx ;swap brush 1x creates bitmap
	bra.s	_Bswa_rx ;swap brush 2x does it

_Hvsh_rx: ;2way gadget (shading) imagery reset
_Hvst_rx: ;2way gadget (stretching) imagery reset
*	xjsr	ShowBUPImagery	;bgadrtns.o, redo-s 2way gadget imageryDEH061494COMOUT
	xjmp	RenderAllProps

_Pcfe_rx:	;print copies, fewer
	xref PrintCopies_
	lea	PrintCopies_(BP),a0
	move.B	(a0),d0
	subq.B	#1,d0
	beq.s	9$
	move.B	d0,(a0)
9$	st	FlagNeedText_(BP)
	rts
_Pcmo_rx:	;print copies, more
	lea	PrintCopies_(BP),a0
	move.B	(a0),d0
	addq.b	#1,d0
	cmp.b	#PRINTMAXCOPIES+1,d0	;max copies = 9?
	bcs.s	9$
	moveq	#PRINTMAXCOPIES,d0
9$	move.B	d0,(a0)
	st	FlagNeedText_(BP)
	rts

_Pcok_rx:	; ;print - ok
	xjmp	InitPrint		;go do it, printrtns.o

_Pcca_rx:	; ;print - cancel
	xjsr	AbortPrint
	sf	FlagPrintReq_(BP)
	clr.B	PrintCopies_(BP)
	st	FlagNeedGadRef_(BP)	;gets gadget refresh
	;DIGIPAINT PI;st	FlagFrbx_(BP)		;gets 'screen re-arrange'
	xjmp	EndPrintGads		;printreq
	;rts

_Aoff_rx:
	xjmp	AOff	;scratch.o	;initial all modes to 'off'

_Boot_rx: 	;performs "keyboard file" "boot" codes
	xjsr	ReturnMessage	;tester....send back msg (in case remote)
	move.l	#'Boot',d0	;d0=LONG # (equiv 4 ascii) ('boot' code(s))
	xjmp	ZipKeyFileAction ;main.key.i, reads keyfile for startup cond

_Ugad_rx: ;redo user gadget (hires+hamtools) display
		;simply calls thie 'display' rtns, but sets no flags
		;...so only the 'flagged' rtns happen
	xjsr	CheckKillMagnify		;may12
	xjsr	CheckBegMagnify			;may12

	xjsr	ReDoHires
	;may28;bsr	ScreenArrange
	bsr	reallyScrArrange	;MAY28
	xjsr	UpdatePalette		;showpal.o, show rgb sliders, cbrites
	xjsr	UseColorMap		;(pointers.o, for now)
	xjsr	RedrawPalette	;tool.code.i
	xjsr	DoMinDisplayText
	xjsr	ReallyShowPaste	;force it? DoShowPaste
	xjsr	DoMinMagnify
	xjsr	ShowPalette	;showpal.o, checks/clears FlagNeedShowPal

		;SEP011990...allow "ugad" to also
		;... render files, render to toaster...IF FROM REMOTE
	xref	FileHandle_
	xref	FlagViewComp_		;view composite...
;;  IFC 't','f' ;KLUDGE,WANT,*NEED*
		;display/update composite "view" (newcode)
	tst.l	FileHandle_(BP)		;*only* reason a file would be open,
	bne.s	96$ ;compositerender		;here, is when rendering->framestore file
	tst.W	FlagOpen_(BP)		;AUG241990...no rendering if in file requester
	bne.s	98$			;....eliminates 're-render' of whole screen
	lea	FlagViewComp_(BP),a0
	tst.w	(a0) ;FlagViewComp_(BP)	;view composite...
	beq.s	98$
	;NOPE....ACTION CODE Shcf CLEARS THIS;clr.w	(a0) ;FlagViewComp_(BP)
96$:	;compositerender:

	xref FlagPick_
	tst.b	FlagPick_(BP)
	bne.s	98$		;no rendering while picking a color...

	xref MsgPtr_		;SEP01....logical kludge....but works...
	move.l	MsgPtr_(BP),-(sp)	;checkcancel, inside of composite->rendercomp
	clr.l	MsgPtr_(BP)
	xjsr	CustomCopper	;copper.o
	xjsr	ReturnMessage	;any that might have come in...KLUDGEY but works
	move.l	(sp)+,MsgPtr_(BP)
98$
	rts



;DigiPaint PI code additions
	xref FlagFillMode_
	xref FlagGridMode_
	xref GridXMod_
	xref GridX1_
	xref GridYMod_
	xref GridY1_

_Gron_rx: ;grid-lock on
	st	FlagGridMode_(BP)	;flag to affect
	bra.s	gridcommon
	;rts
_Grof_rx: ;grid off
	sf	FlagGridMode_(BP)	;flag to affect
	bra.s	gridcommon
	;rts
_Grto_rx: ;grid toggle on-off.
	lea	FlagGridMode_(BP),a0	;flag to affect
	tst.b	(a0)
	seq	(a0)
	bra.s	gridcommon
	;rts
_Grmo_rx: ;grid mouse - use mouse to specify a 2 endpoints (rectangle)
	;***** NOT FINISHED *****
	xref FlagSetGrid_
	st	FlagSetGrid_(BP)	;set grid - on
	st	FlagGridMode_(BP)	;use grid - on sorta
	move.l	#'Grto',d0		;setup button accordlying
	lea	FlagGridMode_(BP),a0
	bsr	setgad_fromflag	st	FlagNeedGadRef_(BP)	;causes redohires->updatemenu, AUG211990
	st	FlagNeedText_(BP)	;hires tool display
	xjsr	UnShowPaste	
	sf	FlagGridMode_(BP)	;use grid - off
	st	FlagNeedGadRef_(BP)
	rts

_Grst_rx: ;## ## grid start x,y (upper left corner could be "fractional gridbox")
	bsr	grab_xyrxarg
	move.w	d0,GridX1_(BP)
	move.w	d1,GridY1_(BP)
	bra.s	print1xy
	;rts
_Grxy_rx: ;## ## grid size x, y
	bsr	grab_xyrxarg
	move.w	d0,GridXMod_(BP)
	move.w	d1,GridYMod_(BP)
print1xy:
	movem.w	d0/d1,LastDrawX_(BP)	;KLUDGE DigiPaint PI
	bra.s	prask1xy

_Gxva_rx: ;Grid X value 16 bit
	bsr	grab_xyrxarg
	move.w	d0,GridXMod_(BP)
	bra.s	prask1xy

_Gyva_rx: ;Grid y value 16 bit
	bsr	grab_xyrxarg
	move.w	d0,GridYMod_(BP)

prask1xy:
	st	FlagPrintXY_(BP)	;trace out...DigiPaint PI
gridcommon:
	st	FlagNeedGadRef_(BP)	;causes redohires->updatemenu, AUG211990
	st	FlagNeedText_(BP)	;hires tool display
	xjsr	UnShowPaste	

	move.l	#'Grto',d0		;setup button accordlying
	lea	FlagGridMode_(BP),a0
	bsr	setgad_fromflag
	st	FlagNeedGadRef_(BP)
	rts

_Gxup_rx:
	tst.b	FlagGridMode_(BP)	;if not in grid mode...
	beq	_Kssr_rx		;go to shifted arrow key routine
	lea	GridXMod_(BP),a0
	moveq	#1,d0	;.w	#$10,d0		;incr
	bra.s	finish_gridxy
_Gxdn_rx:
	tst.b	FlagGridMode_(BP)	;if not in grid mode...
	beq	_Kssl_rx		;go to shifted arrow key routine
	lea	GridXMod_(BP),a0
	bra.s	finish_gdn		;decr
_Gyup_rx:
	tst.b	FlagGridMode_(BP)	;if not in grid mode...
	beq	_Kssu_rx		;go to shifted arrow key routine
	tst.b	FlagGridMode_(BP)	;if not in grid mode...
	beq	_Kssu_rx		;go to shifted arrow key routine
	lea	GridYMod_(BP),a0
	moveq	#1,d0	;.w	#$10,d0		;incr
	bra.s	finish_gridxy
_Gydn_rx:
	tst.b	FlagGridMode_(BP)	;if not in grid mode...
	beq	_Kssd_rx		;go to shifted arrow key routine
	lea	GridYMod_(BP),a0
finish_gdn:
	moveq	#-1,d0	;.w	#-$10,d0	;decr
finish_gridxy:
	move.w	(a0),d1
	add.w	d0,d1
	bpl.s	1$
	moveq	#0,d1
1$	tst.w	d1
	bne.s	2$
	moveq	#1,d1	;.w	#$0010,d1	;JUNE04
2$	cmp.w	#MAXGRID,d1 ;BigPicWt_(BP),d1	;#(9*$010),d1	;max tile? JUNE04
	bcs.s	3$
	move.w	#MAXGRID,d1 ;BigPicWt_(BP),d1 ;#(9*$0010),d1	;=16*$10 JUNE04
3$	move.w	d1,(a0)
	st	FlagNeedText_(BP)	;flag calls for hires text display
	rts	;enda tiler up/down gadgets

_Film_rx: ;fill mode toggle
	lea	FlagFillMode_(BP),a0
	tst.b	(a0)
	;seq	(a0)
	;bra.s	fillend
	bne.s	_Fiof_rx

_Fion_rx: ;fill mode on
	st	FlagFillMode_(BP)
	sf	FlagFlood_(BP)
	sf	FlagLine_(BP)	;line drawing mode OFF (maybe just go "dotty"?)
	clr.L	FlagCirc_(BP)		;clear line/circe/rect/arc gadgets AUG241990
	bra.s	fillend
_Fiof_rx: ;fill mode off
	sf	FlagFillMode_(BP)
fillend:
	tst.L	PasteBitMap_Planes_(BP)	;already have a brush (was gonna paste?) SEP021990
	beq.s	9$
	cbsr	EndCutPaste		;cutpaste.asm, SEP021990
9$
	st	FlagNeedGadRef_(BP)
	rts

_Figm_rx: 	;Global Fillmode toggle
	tst.b	Global_Flood_(BP)
	bne	_Fgof_rx	
_Fgon_rx:
	st	Global_Flood_(BP)
	rts
_Fgof_rx:
	sf	Global_Flood_(BP)
	rts


  IFC 'F','EXTRAS'
_Rota_rx: ;rotate mode on (menuitem's action code)
	st	FlagRotate_(BP)
	sf	FlagStretch_(BP)
	move.b	#6,EffectNumber_(BP)	;set effect#=rotate (see DoEffect.asm)

	bra.s	refresh_if_ctrl	;digipaint pi
	;digipaint pi
	;;bra.s	refresh_if_ctrl
	;moveq	#1,d0	;paint #1
	;moveq	#11,d1	;menu item #
	;bra	_pm_continue2

_Roon_rx: ;rotate mode on
	;lea	FlagRotate_(BP),a0
	;tst.b	(a0)
	;seq	(a0)
	st	FlagRotate_(BP)
	sf	FlagStretch_(BP)
	bra.s	refresh_if_ctrl

_Roof_rx: ;rotate mode off
	sf	FlagRotate_(BP)
  ENDC

refresh_if_ctrl:
	tst.b	FlagCtrl_(BP)		;control/sliders displayed?
	beq.s	9$
	st	FlagNeedGadRef_(BP)
9$	rts


;_Seec_rx: ;show composite..."See color"
;	xref	FlagViewComp_		;view composite...
;
;	xjsr	ReturnMessage	;tester....send back msg (in case remote)
;
;	st	FlagViewComp_(BP)	;...handle composite display
;	;no need...;xjsr	KillCustomLists	;copper.asm,remove custom copper list (if any)
;	xjsr	FreeCompChip
;	CALLIB	Intuition,CloseWorkBench
;	bra	_Clsc_rx
;	;xjsr	AllocComp
;	;xjmp	CustomCopper	;copper.i (test interface)
;	rts


_Vwco_rx: ;view composite
_Shoo_rx: ;show overscan
_Shco_rx: ;show composite

	xref	FlagViewComp_		;view composite...
	st	FlagViewComp_(BP)	;...handle composite display
	;xjmp	CustomCopper	;copper.i (test interface)
	rts

_Shcf_rx: ;show composite OFF
	xref	FlagViewComp_		;view composite...
	sF	FlagViewComp_(BP)	;...handle composite display
	xjsr	KillCustomLists	;copper.asm,remove custom copper list (if any)
	;xjmp	CustomCopper	;copper.i (test interface)
	rts


_Vwct_rx: ;view composite TOGGLE...this is on menuitem
	xref	FlagViewComp_		;view composite...
 IFEQ 	1
	move.l  XTScreenPtr_(BP),a0
	move.l	#1,d0
	move.l	#1,d1 	
	CALLIB	Intuition,MoveScreen
 ENDC
 IFEQ	0 
	lea	FlagViewComp_(BP),a0
	tst.B	(a0)
	seq	(a0)				****!!!!
	xjsr	KillCustomLists	;copper.asm,remove custom copper list (if any)
 ENDC
	;xjmp	CustomCopper	;copper.i (test interface)
	rts

;?;MAY91;_Clip_rx: ;clip/save composite picture
;?;MAY91;	xjmp	SaveComposite	;savecomp.asm

	xref FlagToast_		;applies when allocating bitmaps,( rendering?)
_Toon_rx: ;toaster mode on
	st	FlagToast_(BP)
	rts

_Toof_rx: ;toaster mode off
	sf	FlagToast_(BP)
	rts

	xref FlagToastGads_		;applies when allocating bitmaps,( rendering?)
_Tgon_rx: ;toaster-type gadgets mode on
	st	FlagToastGads_(BP)
	rts

_Tgof_rx: ;toaster gadgets mode off
	sf	FlagToastGads_(BP)
	rts

_Wshr_rx: ;whole screen shrink...go skinnier, interlace
	bsr	MoveHamScreenDown	;04FEB92...helps so user can't click on it too fast...(?)
	xjsr	EndMagnify		;domagnify.asm, kills mag' screen JULY171990
	xjmp	WholeShrink	;WholeHam.asm
	;RTS

MoveHamScreenDown:	;04FEB92...helps so user can't click on it too fast...(?)
		;this routine moves the ham screen down just before shrinking...
		;the screen will be re-opened anyway so it shouldnt matter
	move.l	ScreenPtr_(BP),d0
	beq.s	9$
	move.l	d0,a0
	moveq	#0,d0
	move.l	#220,d1
	CALLIB	Intuition,MoveScreen
9$	RTS

_Whoo_rx: ;wholescreen (hires/lores/1x/2x) toggle
	xjsr	SetAltPointerWait	;"non-interrupatable" JULY171990
	xjsr	EndMagnify		;domagnify.asm, kills mag' screen JULY171990
		;go to rectangle mode if in lindraw mode...18NOV91
	tst.b	FlagLine_(BP)
	beq.s	1$
	bsr	_Drre_rx
	bsr	_Ugad_rx
1$
	lea	FlagToast_(BP),a0
	tst.b	(a0)
	seq	(a0)		;flip flag
	;beq.s	_Wshr_rx	;WAS equal, now set, go do shrink
	;else do 'expand'...was hires, go to lores
	;rts
	bne.s	want_expand
;want_shrink:
		;don't allow brushes (nor scissors) to be
		;..."carried into" 1x mode
;;	xjsr	KillBrush1x	;Canceler.asm.....JULY201990
	seq	FlagToast_(BP)
	bne.s	no_shrink
	xjsr	SetAltPointerWait
	;04FEB92;cbsr	HideToolWindow		;SEP011990
	xjsr	EndCutPaste	;cutpaste.asm

	;   < Wshr whole screen, horizontal shrink (before size narrower...)
	bsr.s	_Wshr_rx
	;   < Nion interlace ON
	bsr	_Nioo_rx
	;   < Size 384 480
	bsr	InitSizer
	;04FEB92;cbsr	HideToolWindow		;SEP011990
	move.w	#TOASTMAXWT/2,MyDrawX_(BP)
	move.w	#TOASTMAXHT,d0			;'y' arg
	bsr	finish_size_rx		;kludgey...ONLY from "Whoo" hires/toggler

	;   < Toon toaster hires ON
	bsr	_Toon_rx
	;   < Nsok
	bsr	_Nsok_rx

	;bsr	_Anbt_rx	;control tools on/off ANIM flag for 1x/2x mode
;july021990;	lea	FlagAnim_(BP),a0
;july021990;	bsr	toolswitch	;tool control panel "Arbitration"

	;	;1.3 KLUDGE, should fix "bogus tools copper list"  21JAN92
	;xref	TScreenPtr_
	;move.l	TScreenPtr_(BP),d0
	;beq.s	101$
	;move.l	d0,a0
	;xjsr	IntuScreenToFront
;101$

	bra.s	done_Whoo
want_expand:
	bsr.s	SetupForExpand
	;   > Nsok
	bsr	_Nsok_rx
	;   > Opsc Nsok new size...open screen (main loop flag)
	bsr	_Opsc_rx
	;   > Wexp whole screen, horizontal expand
	bsr.s	_Wexp_rx

done_Whoo:
;	lea	FlagAnim_(BP),a0
;	bsr	toolswitch	;tool control panel "Arbitration"

		;04FEB92....ensure proper screen order for re-do of ham display
;	xref	ScreenPtr_
;	move.l	ScreenPtr_(BP),d0
;	beq.s	101$
;	move.l	d0,a0
;	xjsr	IntuScreenToFront
101$
	xjsr	HideToolWindow	;tool.code.i  04FEB92
	st	FlagFrbx_(BP)	;flag sup? asked for re-arrange? 04FEB92 (in main loop call to ScreenArrange)
	bsr	ScreenArrange	;do it *now* (?) 04FEB92

	;   > Wham whole screen ham mode re-do (to see hires detail) before "wait"
	;RTS...fall thru, do 'wham' action

_Wham_rx: ;whole HAM screen re-do
	xref	FlagWholeHam_		;'main loop' handles this flag -> Wham.asm
	st	FlagWholeHam_(BP)	;need 'whole ham screen' redraw from rgb
no_shrink:		;label for "_whoo_rx"
	rts

 xdef SetupForExpand	;SEP031990, setup for 'return to switcher'
SetupForExpand:	;SEP031990
	;   > Niof interlace OFF
	bsr	_Niof_rx
	;   > Size 736 480
	bsr	InitSizer
	move.w	#TOASTMAXWT,MyDrawX_(BP)
	move.w	#TOASTMAXHT,d0			;'y' arg
	bsr	finish_size_rx		;kludgey...ONLY from "Whoo" hires/toggler
	;   > Toof toaster hires OFF
	bsr	_Toof_rx
	RTS

_Wexp_rx: ;whole screen expand...go "zoom", non-interlace, superbitmap
	xjsr	EndMagnify		;domagnify.asm, kills mag' screen JULY171990
	xjsr	WholeExpand	;WholeHam.asm
	xjsr	ReallySaveUnDo	;memories.asm  ;AUG271990
	xjmp	SaveUnDoRGB	;rgbrtns.asm  ;AUG271990
	;RTS

_Snap_rx: ;'snap centered view'...keeps toaster hires pic centered
	xref FlagSnap_
	st	FlagSnap_(BP)	;snap mode only works in hires
	rts

_Snof_rx: ;snap off
	sf	FlagSnap_(BP)
	rts

_Snoo_rx: ;'snap centered view'...on/off toggle SEP011990
	xref FlagSnap_
	tst.b	FlagToast_(BP)		;toaster mode?
	beq.s	snaperror
	lea	FlagSnap_(BP),a0	;snap mode only works in hires
	tst.b	(a0)
	seq	(a0)
	rts

snaperror:
	st	FlagDisplayBeep_(BP)
	rts

   IFC 't','f' ;  MAY91 ;MAY91

_Seet_rx: ;see toaster image...tester
	xref FlagToasterAlive_
;WANT,NEED,KLUDGEOUT;	tst.b FlagToasterAlive_(BP)
;WANT,NEED,KLUDGEOUT;	beq.s	9$
	tst.l	Datared_(BP)		;have any rgb data?
	beq.s	9$
	movem.l	d0-d7/a0-a6,-(sp)
	xjsr	Convert			;toaster/composite encoding
	bne.s	7$			;returns ZERO flag if 'bummer'
	st	FlagDisplayBeep_(BP)	;'beep/flash' if conversion failed
7$	movem.l	(sp)+,d0-d7/a0-a6
	rts
9$	st	FlagDisplayBeep_(BP)
	rts
  ENDC ;MAY91

_Resd_rx: ;reset "static" random dither pattern (WANT this as a BOOT code)
	xjmp ResetDither	;scratch.asm
	;rts

	xref FrameBufferBank_	;0 or 1
_Tdv1_rx: ;toaster dv1 (1st frame buffer)
	xref	ORenderDV2Gadget
	lea	ORenderDV2Gadget,a0
	and.w	#~SELECTED,gg_Flags(a0)
	lea	ORenderDV1Gadget,a0
	or.w	#SELECTED,gg_Flags(a0)

	lea	FrameBufferBank_(BP),a0
	tst.b	(a0)			;already on buffer 0 (1st one?)
	beq.s	dv1ok
	sf	(a0)			;else reset
	xref	SolLineTable_		;only other reference is in Convert.o
	lea	SolLineTable_(BP),a0
	xjsr	FreeOneVariable		;resets so "all lines are replotted" in composite
dv1ok:
	moveq	#0,d0
	bra.s	__SetFrameBufferBank
	;xjmp	_SetFrameBufferBank	;toastglue.asm
	;rts

_Tdv2_rx: ;toaster dv2 (2nd frame buffer)
	xref	ORenderDV1Gadget
	lea	ORenderDV1Gadget,a0
	and.w	#~SELECTED,gg_Flags(a0)
	lea	ORenderDV2Gadget,a0
	or.w	#SELECTED,gg_Flags(a0)

	lea	FrameBufferBank_(BP),a0
	cmp.b	#1,(a0)			;already on buffer 0 (1st one?)
	beq.s	dv2ok
	move.b	#1,(a0)			;else reset, frame buf #1 hardware, =dv2
	xref	SolLineTable_		;only other reference is in Convert.o
	lea	SolLineTable_(BP),a0
	xjsr	FreeOneVariable		;resets so "all lines are replotted" in composite
dv2ok:
	moveq	#1,d0
__SetFrameBufferBank:	;toastglue.asm
	st	FlagNeedGadRef_(BP)	;causes redohires->updatemenu, AUG211990
	xjmp	_SetFrameBufferBank	;toastglue.asm
	;rts

_Saco_rx: ;save-composite - render toaster-24 bit to a frame-store file
	move.l	#'Save',LS_String_(BP)	;requester sez it all
	st	FlagSave_(BP)
	sf	FlagOpen_(BP)
	st	FlagCompFReq_(BP)	;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	sf	FlagImageDir_(BP)	;0=means 'need image directory' 15NOV91
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 

	xref	DirnameBuffer_
	xref	ToastFSNamePtr_

*	move.l	ToastFSNamePtr_(BP),d0
*	beq.s	9$			;not from switcher, invalid pointer
*	ADDQ.L	#1,D0			;BUMP NAME POINTER FROM SWITCHER...
*	move.l	d0,a1
	lea	DirnameBuffer_(BP),a2	;fill in 'dir name' with framestore name...
	DUMPBEM	<DirnameBuffer>,(A2),#32
*	move.b	#0,(a2)+
*	xjsr	copy_string_a1_to_a2
*	lea	-1(a2),a2		;backup to "null"
*	lea	FrameStoreString(pc),a1	;append "framestore" to device name
	lea	FrameDir,a1
	xjsr	copy_string_a1_to_a2	;dirrtns.asm
9$:	rts
FrameStoreString:	dc.b	'Ram:',0
	cnop 0,2



setup_imagedirname:	;NOV91
	;does a 'cd' to "toaster/3d/images"

	xref	FlagImageDir_	;0=means 'need image directory', -1=leave dir alone
	;this flag is cleared by default at program startup time,
	;meaning that it will require a 'cd toaster/3d/images'.
	;the following routines clear this flag:
	;  Font_rx, Loco_rx, Saco_rx
	;clearing the flag forces a new 'cd' the next time
	;that Lo24_rx or Sa24_rx are called

	tst.b	FlagImageDir_(BP)	;0=means 'need image directory', -1=leave dir alone
	bne.s	9$
	st	FlagImageDir_(BP)	;=leave dir alone

	xref	ToastDirLock_	;setup by switcher, ToastGlue.asm
	move.l	ToastDirLock_(BP),d0
	move.l	d0,d1
	CALLIB	DOS,CurrentDir	;lock is a handle, now actually go there

	;move.l	ToastFSNamePtr_(BP),d0
	;beq.s	9$			;not from switcher, invalid pointer
	;ADDQ.L	#1,D0			;BUMP NAME POINTER FROM SWITCHER...
	;move.l	d0,a1
	lea	DirnameBuffer_(BP),a2	;fill in 'dir name' with toaster dir name
	;xjsr	copy_string_a1_to_a2
	;lea	-1(a2),a2		;backup to "null"
	xref	RGBDir
	
	lea	RGBDir,a1
*	lea	ImageStoreString(pc),a1	;append "framestore" to device name
	xjsr	copy_string_a1_to_a2	;dirrtns.asm
*	xjsr	MakeDirCurrent		;ensure DirnameBuffer is our current directory
*	xjmp	DirRoutine		;really just want to set a flag?
9$:	rts
ImageStoreString:	dc.b	'Ram:',0
	cnop 0,2




setup_fontdirname:	;NOV91
	;does a 'cd' to "toaster/3d/TosaterFonts"
	xref	FlagImageDir_	;0=means 'need image directory', -1=leave dir alone
	;this flag is cleared by default at program startup time,
	;meaning that it will require a 'cd toaster/3d/ToasterFontsimages'.
	;the following routines clear this flag:
	;  Font_rx, Loco_rx, Saco_rx
	;clearing the flag forces a new 'cd' the next time
	;that Lo24_rx or Sa24_rx are called

*	tst.b	FlagImageDir_(BP)	;0=means 'need image directory', -1=leave dir alone
*	bne.s	9$
*	st	FlagImageDir_(BP)	;=leave dir alone

	xref	ToastDirLock_		;setup by switcher, ToastGlue.asm
	move.l	ToastDirLock_(BP),d0
	move.l	d0,d1
	CALLIB	DOS,CurrentDir		;lock is a handle, now actually go there

	lea	DirnameBuffer_(BP),a2	;fill in 'dir name' with toaster dir name
	xref	FontDir
	lea	FontDir,a1	
*	lea	FontStoreString(pc),a1	;append "framestore" to device name
	xjsr	copy_string_a1_to_a2	;dirrtns.asm
9$:	rts
FontStoreString:	dc.b	'ToasterFonts',0
	cnop 0,2




_Loco_rx: ;load-composite - uses switcher/framestore directory for default
	move.l	#'Load',LS_String_(BP)	;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)	;this flag only pertains to 'file requester'
	sf	FlagSave_(BP)	;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)	;0=means 'need image directory' 15NOV91
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 


	xref FlagCompFReq_	;file requester...composite/framestore mode?
	st	FlagCompFReq_(BP)	;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	SF	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)


	move.b	#0,FilenameBuffer_(BP)
*	move.l	ToastFSNamePtr_(BP),d0
*	beq.s	9$			;not from switcher, invalid pointer
*	ADDQ.L	#1,D0			;BUMP NAME POINTER FROM SWITCHER...
*	move.l	d0,a1
	lea	DirnameBuffer_(BP),a2	;fill in 'dir name' with framestore name...
*	xjsr	copy_string_a1_to_a2
*	lea	-1(a2),a2		;backup to "null"

	xref	FrameDir
	lea	FrameDir,a1
*	lea	FrameStoreString(pc),a1	;append "framestore" to device name
	xjsr	copy_string_a1_to_a2	;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts




; Action Quia ;Quit - but 'ask' first
_Quia_rx:	;Picture_Quit:
	sf	FlagPale_(BP)   ;not palette! on start!
	xjsr	ReturnMessage	;May09'89...helps remote user
	xjsr	ReallyQuitRtn	;canceler.o
	beq.s	sq_rts

_Squt_rx: ;~ keyboard...super-quit...asks switcher for "unload from memory"
	xref FlagQuitSuper_
	tst.b	FlagAlphapaint_(BP)
	beq	99$	
	xjsr	OpenAlphaScreen		;open or close the alpha screen! main.asm
99$	st	FlagQuit_(BP)
	st	FlagQuitSuper_(BP)
	sf	FlagPale_(BP)   ;not palette! on start!
sq_rts	rts

	;[alt] key action codes for rectangle->swap aspect ration JULY131990
_Alof_rx: ;[alt] key off, for   locking rectangle->swap brush aspect ratio
	xref	FlagShiftKey_
	sf	FlagShiftKey_(BP)
	rts

_Alon_rx: ;shift on, for un-locking rectangle->swap brush aspect ratio
	st	FlagShiftKey_(BP)
	rts

_Bsmf_rx:	;"filled in freehand"...flood on, bsmooth...
	lea	FlagBSmooth_(BP),a0	;if flag brush smoothing...
	bsr	do_mutex		;sets this gadget "on"
	st	FlagNeedGadRef_(BP)
	st	FlagFlood_(BP)		;ensures flood fill mode is "on"
	rts

	xref FlagDelayBottom_
_Dela_rx:
	st	FlagDelayBottom_(BP)
	rts
_Delo_rx:
	sf	FlagDelayBottom_(BP)
	rts


_Aroo_rx:	;always render on/off
	xref FlagAlwaysRender_
	;SEP111990;lea	FlagAlwaysRender_(BP),a0
	;SEP111990;tst.b	(a0)
	;SEP111990;seq	(a0)
	;SEP111990;rts

		;if turning the flag OFF, then also kill the re-rendering...
	tst.b	FlagAlwaysRender_(BP)
	bne.s	_Arof_rx		;go turn it off

_Aron_rx:	;always render on
	st	FlagAlwaysRender_(BP)
	;SEP111990;rts
	bra	_Shco_rx	;show composite ON ;SEP111990;

_Arof_rx:	;always render off
	sf	FlagAlwaysRender_(BP)
	;;SEP111990;rts
	bra	_Shcf_rx	;show composite OFF



_Scoo_rx:	;scroll lock on/off
	xref FlagScrollLock_
	lea	FlagScrollLock_(BP),a0
	tst.b	(a0)
	seq	(a0)
	rts

_Scon_rx:	;scroll lock on
	st	FlagScrollLock_(BP)
	rts

_Scof_rx:	;scroll lock off
	sf	FlagScrollLock_(BP)
	rts


_Dirf_rx
	st	FlagDevicesOnly_(BP)
	bra.s	ReDoDir
_Dird_rx
	sf	FlagDevicesOnly_(BP)
	bra.s	ReDoDir
_Dirt_rx
	tst.b	FlagDevicesOnly_(BP)
	seq	FlagDevicesOnly_(BP)
ReDoDir
	lea	DirnameBuffer_(BP),a1
	clr.b	(a1)
	xjsr	DirRoutine
	rts

	xref DirnameBuffer_
_Dir0_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#'D',(a0)+
	move.b	#'f',(a0)+
	move.b	#'0',(a0)+
	move.b	#':',(a0)+
	clr.b	(a0)
;_DirRoutine:
	;xjmp	DirRoutine	;re-read directory, dirrtns.asm
_MakeDirCurrent:
	xjmp	MakeDirCurrent

_Dir1_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#'D',(a0)+
	move.b	#'f',(a0)+
	move.b	#'1',(a0)+
	move.b	#':',(a0)+
	clr.b	(a0)
	bra.s	_MakeDirCurrent	;re-read directory, dirrtns.asm
	;rts

_Dir2_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#'D',(a0)+
	move.b	#'f',(a0)+
	move.b	#'2',(a0)+
	move.b	#':',(a0)+
	clr.b	(a0)
	bra.s	_MakeDirCurrent	;re-read directory, dirrtns.asm
	;rts


;AUG241990......directory changes for default button on file requ
; Action Dir3 ;ram: directory selection for file requester
; Action Dir4 ;dh0: directory selection for file requester
	
_Dir3_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#'R',(a0)+
	move.b	#'A',(a0)+
	move.b	#'M',(a0)+
	move.b	#':',(a0)+
	clr.b	(a0)
	bra.s	_MakeDirCurrent	;re-read directory, dirrtns.asm
	;rts

_Dir4_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#'D',(a0)+
	move.b	#'h',(a0)+
	move.b	#'0',(a0)+
	move.b	#':',(a0)+
	clr.b	(a0)
	bra.s	_MakeDirCurrent	;re-read directory, dirrtns.asm
	;rts

_Dirr_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#':',(a0)+
	clr.b	(a0)
	bra.s	_MakeDirCurrent	;re-read directory, dirrtns.asm
	;rts

_Dirp_rx:
	lea	DirnameBuffer_(BP),a0
	move.b	#'/',(a0)+
	clr.b	(a0)
	bra.s	_MakeDirCurrent	;re-read directory, dirrtns.asm
	;rts

_Meoo_rx: ;memory display mode toggle
	xref FlagMemDisplay_
	lea	FlagMemDisplay_(BP),a0
	tst.b	(a0)
	seq	(a0)
	rts

_Meon_rx: ;memory display - on
	st	FlagMemDisplay_(BP)
	rts

_Meof_rx: ;memory display - off
	sf	FlagMemDisplay_(BP)
	rts


_Fboo_rx: ;framestore load, blacken left/rightside pixels mode toggle
	xref FlagFrameBlack_
	lea	FlagFrameBlack_(BP),a0
	tst.b	(a0)
	seq	(a0)
	rts

_Fbon_rx: ;framestore load, blacken left/rightside pixels - on
	st	FlagFrameBlack_(BP)
	rts

_Fbof_rx: ;framestore load, blacken left/rightside pixels - off
	sf	FlagFrameBlack_(BP)
	rts


_Rcvb_rx: ;receive binary data from ToasterPaint, same format as 'Dlvb'
	;bug fix to prevent "quitting" from hanging DigiView 
	;...while DigiView is sending a picture
	sf	FlagQuit_(BP)

	bsr	grab_arg_a0
	beq.s	9$
	lea	4(a0),a0	;skip past 4char cmd//ascii action code
	move.w	(a0)+,d0	;binary word from message
	move.w	d0,d1
	and.w	#~31,d0
	cmp.w	d0,d1
	bne.s	9$		;must be even #32
	move.w	d0,DlvrCount_(BP)	;#pixels to 'deliver'
	move.w	(a0)+,DlvrLine_(BP)	;line#
	move.L	a0,DlvrPtr_(BP)		;ptr to 3wordsper pixel
	xjmp	ReceiveRGB		;RGBrtns.asm
9$	rts
	;rts

_Exec_rx: ;execute string SEP021990
	xjsr	SetPointerWait			;SEP041990
	bsr	grab_srxarg
	;xref TracePrintString_			;main.msg.i
	;xref FlagPrintString_
	xref	StdOut_
	move.l	a0,TracePrintString_(BP)	;adr for trace-out string print
	st	FlagPrintString_(BP)
	move.l	a0,d1		;d1=string to execute
	moveq	#0,d2		;d2=input
	;16JAN92;move.l	StdOut_(BP),d3	;d3=output, (if any, c/b null)
	moveq	#0,d3		;d3=output using NULL 16JAN92
	;SEP041990;CALLIB	DOS,Execute
	;SEP041990;xjmp	GraphicsWaitBlit	;wait for cli to display (memories.asm)
	;SEP041990;rts
	JMPLIB	DOS,Execute
	;rts

_Gts1_rx
	moveq.l	#0,d0
	bra.s	dograb
_Gts2_rx
	moveq.l	#1,d0
	bra.s	dograb
_Gts3_rx
	moveq.l	#2,d0
	bra.s	dograb
_Gts4_rx
	moveq.l	#3,d0
dograb
	moveq	#0,d1		;bank #
	tst.b	FrameBufferBank_(BP)
	beq.s	1$
	moveq	#1,d1		;bank #
1$
	xjsr	doGrab1Bank
	rts

; Action Gdv1 ;grab dv1 MAR91
; Action Gdv2 ;grab dv1 MAR91

 xref	GrabFieldNbr_	;0,1,2,3

_Gdv1_rx:	moveq	#0,d0	;bank#
		bra.s	grab_and_display

_Gdv2_rx:	moveq	#1,d0	;bank#
grab_and_display:
	xref FlagToasterAlive_
	tst.b FlagToasterAlive_(BP)
	beq.s	9$
	move.l	GrabFieldNbr_(BP),d1	;0,1,2,3
	cmp.b	#4,d1
	bcs.s	1$
	moveq	#0,d1
1$	move.l	d1,GrabFieldNbr_(BP)	;0,1,2,3
	addq.L	#1,GrabFieldNbr_(BP)

	xjsr	ToastGlueGrabField
	bra	_Wham_rx	;whole-screen redisplay
9$	st	FlagDisplayBeep_(BP)	;boom!...no grab if not from toaster
	rts


_Gfrn_rx:
	moveq	#0,d0		;bank #
	tst.b	FrameBufferBank_(BP)
	beq.s	1$
	moveq	#1,d0		;bank #
1$
	moveq	#5,d1		;code for grab frame interfield comb filter
	bra.s	newgrabs
_Gfln_rx:
	moveq	#0,d0		;bank #
	tst.b	FrameBufferBank_(BP)
	
	beq.s	1$
	moveq	#1,d0		;bank #
1$
	moveq	#0,d1		;code for grab field band pass filter
	bra.s	newgrabs

_Gfr1_rx:	moveq	#1,d0	;bank#
	moveq	#0,d0		;bank #
	moveq	#4,d1		;code for grab frame (2 fields)
	bra.s	newgrabs
_Gfr2_rx:	moveq	#1,d0	;bank#
	moveq	#1,d0		;bank #
	moveq	#4,d1		;code for grab frame (2 fields)
	bra.s	newgrabs
_Gff1_rx:	moveq	#1,d0	;bank#
	moveq	#0,d0		;bank #
	moveq	#5,d1		;code for grab four fields
	bra.s	newgrabs
_Gff2_rx:	moveq	#1,d0	;bank#
	moveq	#1,d0		;bank #
	moveq	#5,d1		;code for grab four fields
	;bra.s	newgrabs
newgrabs:
	tst.b FlagToasterAlive_(BP)
	beq.s	9$
	xjsr	ToastGlueGrabField
	st	FlagRedrawPal_(BP)
;	xjsr	SupHamGads
	

	bra	_Wham_rx	;whole-screen redisplay
9$	st	FlagDisplayBeep_(BP)	;boom!...no grab if not from toaster
	rts






; Action Ccon ;compressed composite framestore save
; Action Ccof ;un-compressed framestore saves
	xref FlagSaveCompressed_
_Ccon_rx:
	st	FlagSaveCompressed_(BP)
	rts
_Ccof_rx:
	sf	FlagSaveCompressed_(BP)	;default, uncompressed
	rts

_SEDG_rx	;toggle softedge
;	lea	FUSoftEdgeGadget,a0			;removed the softedge button072794
;	btst	#7,1+gg_Flags(a0)
	beq.s	1$			;Soft Mode off
	move.w	LastShadeMode_(a5),d1

	move.w	LastShade0_(a5),StdPot0
	move.w	LastShade1_(a5),StdPot1
	bra	finish_hvs
1$
	move.w	StdPot0,LastShade0_(a5)
	move.w	StdPot1,LastShade1_(a5)
	moveq.l	#0,d0
	move.b	ShadeOnOffNum_(a5),d0
	move.w	d0,LastShadeMode_(a5)

	move.w	#0,StdPot0
	move.w	#0,StdPot1
	moveq.l	#0,d1
	bra	finish_hvs2

_Rng1_rx
	move.b	Paint8red_+1(a5),d0
	lsr.b	#4,d0
	move.b	d0,(17*4)+0(a5)
	move.b	Paint8green_+1(a5),d0
	lsr.b	#4,d0
	move.b	d0,(17*4)+1(a5)
	move.b	Paint8blue_+1(a5),d0
	lsr.b	#4,d0
	move.b	d0,(17*4)+2(a5)
	bra	_Rang_rx			;exit in range mode

_Rng2_rx
	move.b	Paint8red_+1(a5),d0
	lsr.b	#4,d0
	move.b	d0,(16*4)+0(a5)
	move.b	Paint8green_+1(a5),d0
	lsr.b	#4,d0
	move.b	d0,(16*4)+1(a5)
	move.b	Paint8blue_+1(a5),d0
	lsr.b	#4,d0
	move.b	d0,(16*4)+2(a5)
	bra	_Rang_rx			;exit in range mode


_Olin_rx
	rts
_STEN_rx
	tst.b	FlagAlphapaint_(BP)
	bne	99$
	eor.b	#$FF,StencilFlag_(a5)
	st	FlagNeedText_(BP)	;redisplay of modename....	
99$	
	rts

_STNP_rx
	tst.b	FlagAlphapaint_(BP)
	bne	99$	
	eor.b	#$FF,StencilSign_(a5)
	st	FlagNeedText_(BP)	;redisplay of modename....
99$		
	rts

_STOF_rx
	sf	StencilFlag_(a5)
	tst.b	FlagAlphapaint_(BP)
	beq	1$
	bsr	_Alph_rx
1$
	st	FlagNeedText_(BP)	;redisplay of modename....
	rts	

_STNE_rx
	tst.b	FlagAlphapaint_(BP)
	bne.s	88$		
	tst.b	FlagSwaped_(BP)	
	beq.s	99$
	bsr	_Swap_rx
99$
	st	StencilFlag_(a5)
	sf	StencilSign_(a5)
	st	FlagNeedText_(BP)	;redisplay of modename....
88$
	rts
	
_STPO_rx
	tst.b	FlagAlphapaint_(BP)
	bne.s	55$	

	tst.b	FlagSwaped_(BP)
	beq	99$
	bsr	_Swap_rx
99$
	st	StencilFlag_(a5)
	st	StencilSign_(a5)
	st	FlagNeedText_(BP)	;redisplay of modename....
55$
	rts


_STPL_rx				;load stencli
	xref	LoadNextStencil
	jsr	LoadNextStencil
	xref	UpDatePaintFromSaveBlock
	jsr	UpDatePaintFromSaveBlock

	xjsr	DoInlineAction
	dc.w	'Re','do'

 ifeq 1
	move.l	BB1Ptr_(BP),a0
	add.l	#4000,a0
	moveq.l	#100,d0

1$	move.l	#-1,(a0)+
	dbf	d0,1$
 endc
	rts

_STPS_rx				;save stencli
	xref	SaveNextStencil
	jsr	SaveNextStencil
 ifeq 1
	move.l	BB1Ptr_(BP),a0
	add.l	#2000,a0

	moveq.l	#100,d0

1$	move.l	#-1,(a0)+
	dbf	d0,1$
 endc

	rts

_ABRU_rx
;;	xref	AirBrush
;;	jmp	AirBrush

	tst.b	AirBrushOn_(BP)
	bne	99$
	tst.b	FlagMagnify_(BP)
	bne	88$
99$
	eor.b	#-1,AirBrushOn_(a5)
	tst.b	AirBrushOn_(a5)
	beq	77$
	sf	FlagFlood_(BP)		;old fill off
	sf	FlagFillMode_(BP)	;new fill off
	bsr	_Doty_rx
77$
*	xjsr	Enforce_ABFlag
	xjsr	AirBrushfix
	rts
88$
	xjsr	Enforce_ABFlag
	xjsr	AirBrushfix
	rts

_Trns_rx
	xjsr	SetTransport
	rts


_Dbru_rx:
	xref	PasteBitMap_Planes_
*	lea	PasteBitMap_Planes_(BP),a0
*	DUMPBEM	<BRUSH BIT MAP>,(A0),#64	

	xjsr	GoMakeanIcon

	RTS	


 ifeq	1
_Xxxx_rx:
	move.l	ScreenPtr_(BP),a2	;bigpicture
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	moveq	#0,d0
	moveq	#0,d1
	move.w	ri_RxOffset(a1),d0	;d2=current x offset (ends up in d0...)
	move.w	ri_RyOffset(a1),d1	;d1=current y offset
	DUMPHEG	<ri_ROffset  D0 = X,  D1 = Y>
	cmp.w	#$0f,d0
	beq.s	1$
	move.w	#$0f,ri_RxOffset(a1)
	bra	2$
1$
	move.w	#0,ri_RxOffset(a1)
2$		
	CALLIB	Graphics,ScrollVPort
	rts	
 endc


	xref	Script_Array
_Xxxx_rx:
 ifeq 1
*	xjsr	OpenLRScreen
	xjsr	LOAD_SIRexxScripts
*
	xjsr	BuildITArray
	move.l	d0,Script_Array			;KEEP ARRAY POINTER HANDY
	xjsr	Disp_IPS
	xjsr	Disp_IPC 
*
 endc
	rts	



** load the arexx list
_Srex_rx:
	move.l	Script_Array,d0
	beq	1$

	xjsr	FREE_IPARRAY
1$
	xjsr	LOAD_SIRexxScripts
	xjsr	BuildITArray
	move.l	d0,Script_Array			;KEEP ARRAY POINTER HANDY

	cmp.b	#18,CurrentFrameNbr_(BP)
	bne	2$

	xjsr	Disp_IPS
	xjsr	Disp_IPC 
*		
2$
	rts

** free the arexx list
	xdef 	_Frex_rx
_Frex_rx:
	DUMPCXG	<_Frex_rx>
	move.l	Script_Array,d0
	beq	1$
	xjsr	FREE_IPARRAY
1$
	rts

key_arrow_rt:

;	bsr	TestRPort
;	xjsr	TestClipIcon
 ifeq	0
	move.l	ScreenPtr_(BP),a2	;bigpicture
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	moveq	#0,d0
	moveq	#0,d1
	move.w	ri_RxOffset(a1),d0	;d2=current x offset (ends up in d0...)
	move.w	ri_RyOffset(a1),d1	;d1=current y offset
	move.w	#$0f,ri_RxOffset(a1)
	CALLIB	Graphics,ScrollVPort
	CALLIB	Intuition,RemakeDisplay		;RethinkDisplay
	DUMPCXG	<arrowkeyRT>
 endc
	rts

key_arrow_lt:
	move.l	ScreenPtr_(BP),a2	;bigpicture
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	moveq	#0,d0
	moveq	#0,d1
	move.w	ri_RxOffset(a1),d0	;d2=current x offset (ends up in d0...)
	move.w	ri_RyOffset(a1),d1	;d1=current y offset
	move.w	#$00,ri_RxOffset(a1)
	CALLIB	Graphics,ScrollVPort
	CALLIB	Intuition,RemakeDisplay		;RethinkDisplay
	DUMPCXG	<arrowkeyLT>
	rts


** Add field to flyer clip
_Apfc_rx:
	xdef	_Apfc_rx
	xjsr	SetAltPointerWait	;"non-interrupatable" JULY171990
*	move.l	#0,OutFields
	DUMPCXG	<Write field to clip>
* 	move.w	#4-1,d3
12$	xjsr	TestWriteClip
*	dbf	d3,12$
	rts


** Get Prev Frame
	xdef	_Gpfd_rx
_Gpfd_rx:
	tst.b	FlagField2loaded_(BP)		;0=do field2,dont inc;1=do field1,2=deinc, do field2	
	beq	.firstb
	cmp.b	#2,FlagField2loaded_(BP)
	beq	.notframedeinc
	bsr	DeIncCurrFrame
.firstb	DUMPMSG	<getting fd2>
	bsr	_Lfd2_rx
	move.b	#2,FlagField2loaded_(BP)
	lea	TCBuff01,a0
	rts	
.notframedeinc
	DUMPMSG	<getting fd1>
	bsr	_Lfd1_rx
	move.b	#1,FlagField2loaded_(BP)
	rts


** Get Next Frame
	xdef	_Gnfm_rx
_Gnfm_rx:
	bsr	_LfdB_rx
	bsr	IncCurrFrame
	move.b	#2,FlagField2loaded_(BP)
	rts


** Get Next Field
	xdef	_Gnfd_rx
_Gnfd_rx:
	tst.b	FlagField2loaded_(BP)		;0=do field1,dont inc;1=do field2,2=inc, do field1	
	beq	.first

	cmp.b	#1,FlagField2loaded_(BP)
	beq	.notframeinc
	bsr	IncCurrFrame
.first
	bsr	_Lfd1_rx
	add.b	#1,FlagField2loaded_(BP)
	lea	TCBuff01,a0
	rts	
.notframeinc
	bsr	_Lfd2_rx
	move.b	#2,FlagField2loaded_(BP)
	rts


DeIncCurrFrame:
	movem.l	D0-D7/A0-A6,-(SP)
	lea	TCBuff01,a0
	bsr	TC2LONG		
	tst.l	d0
	beq	.lowerlimit
	sub.l	#1,d0	
	lea	TCBuff01,a0
	bsr	LONG2TC		
	move.b	#1,FlagField2loaded_(BP)
.lowerlimit
	movem.l	(SP)+,D0-D7/A0-A6
	rts


IncCurrFrame:
	movem.l	D0-D7/A0-A6,-(SP)
	lea	TCBuff01,a0
	bsr	TC2LONG
	move.l	SRC_ClipLen,d1			get limit number
	sub.l	#1,d1				one less
	asr.l	#1,d1				div 2
	cmp.l	d0,d1
	beq	.upperlimit				
	add.l	#1,d0	
	lea	TCBuff01,a0
	bsr	LONG2TC		
	move.b	#1,FlagField2loaded_(BP)
.upperlimit
	movem.l	(SP)+,D0-D7/A0-A6
	rts

** Skip Next Field
	xdef	_Snfd_rx
_Snfd_rx:
	tst.b	FlagField2loaded_(BP)		;0=do field1,dont inc;1=do field2,2=inc, do field1	
	beq	.first2

	cmp.b	#1,FlagField2loaded_(BP)
	beq	.notframeinc2
	bsr	IncCurrFrame
.first2
*	bsr	_Lfd1_rx
	add.b	#1,FlagField2loaded_(BP)
	lea	TCBuff01,a0
	rts	
.notframeinc2
*	bsr	_Lfd2_rx
	move.b	#2,FlagField2loaded_(BP)
	rts






** Load fd1 from flyer in clip 
	xdef 	_Lfd1_rx
_Lfd1_rx:
	sf	FlagField2loaded_(BP)		;not loading field 2
*	xjsr	SaveAlphaTestBM
*	xjsr	TBFS2Clip
; 	use LoadClipField to get a field.			
;	Error=LoadClipField(BM,Name,Field#)
;	D0	            a0 a1   d0
;	ExpandField(BM,Field#)
;	 	     a0 d0
*
*	move.l	#(60*4),d0
	xjsr	SetAltPointerWait	;"non-interrupatable" JULY171990
	bsr	_TC01_rx
	bsr	TCLONG2FIELDS
	DUMPHEG	<D0-FIELDS>
	lea	SourceClipPath,a1
	lea	BigPicRGB_(a5),a0	;'RGBpicture' struct
	DUMPBEM <BIGPICTURERGB>,(A0),#128
	cmp.l	#0,a0
	beq	.error2
	xjsr	GoGrabClipField
	movem.l	d0-d6/a0-a3,-(sp)
	lea	SolLineTable_(a5),a0
	xref	FreeOneVariable
	jsr	FreeOneVariable		;falg all lines as "to be rendered"
	movem.l	(sp)+,d0-d6/a0-a3
	st	FlagWholeHam_(BP)	;need 'whole ham screen' redraw from rgb
.error2
	rts


** Load fd2 from flyer in clip 
	xdef 	_Lfd2_rx
_Lfd2_rx:
 ifeq	1
	xjsr	SaveAlphaTestBM
 endc
	st	FlagField2loaded_(BP)	;loading field 2
	xjsr	SetAltPointerWait	;"non-interrupatable" JULY171990
	bsr	_TC01_rx
	bsr	TCLONG2FIELDS
	add.l	#1,d0
	DUMPHEG	<D0-FIELDS>
*	move.l	#(60*4)+1,d0
	lea	SourceClipPath,a1
	lea	BigPicRGB_(a5),a0	;'RGBpicture' struct
	DUMPBEM <BIGPICTURERGB>,(A0),#128
	cmp.l	#0,a0
	beq	Lfd2_error
	xjsr	GoGrabClipField	
*
	movem.l	d0-d6/a0-a3,-(sp)
	lea	SolLineTable_(a5),a0
	xref	FreeOneVariable
	jsr	FreeOneVariable		;falg all lines as "to be rendered"
	movem.l	(sp)+,d0-d6/a0-a3
	st	FlagWholeHam_(BP)	;need 'whole ham screen' redraw from rgb
Lfd2_error
	rts


** Load FD1&2 from flyer in clip 
	xdef 	_LfdB_rx
_LfdB_rx:
	st	FlagField2loaded_(BP)	;loading field 2 both actulay!
	xjsr	SetAltPointerWait	;"non-interrupatable" JULY171990
	bsr	_TC01_rx
	bsr	TCLONG2FIELDS
*	add.l	#1,d0
	DUMPHEG	<D0-FIELDS>
*	move.l	#(60*4)+1,d0
	lea	SourceClipPath,a1
	lea	BigPicRGB_(a5),a0	;'RGBpicture' struct
	DUMPBEM <BIGPICTURERGB>,(A0),#128
	cmp.l	#0,a0
	beq	.error1
	xjsr	GoGrabClipFields	
*
	movem.l	d0-d6/a0-a3,-(sp)
	lea	SolLineTable_(a5),a0
	xref	FreeOneVariable
	jsr	FreeOneVariable		;falg all lines as "to be rendered"
	movem.l	(sp)+,d0-d6/a0-a3
	st	FlagWholeHam_(BP)	;need 'whole ham screen' redraw from rgb
.error1
	rts


** Select clip
_Slcp_rx:	
	DUMPCXG	<SELECT CLIP>
	move.l	#'Clip',LS_String_(BP)		;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	sf	FlagSave_(BP)			;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)		;0=means 'need image directory' 15NOV91
	st	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)

	xref FlagCompFReq_			;file requester...composite/framestore mode?
	sf	FlagCompFReq_(BP)		;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	move.b	#0,FilenameBuffer_(BP)

	lea	DirnameBuffer_(BP),a2		;fill in 'dir name' with...

	xref	ClipDir
	lea	ClipDir,a1
	xjsr	copy_string_a1_to_a2		;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts		
	


	xdef	_Rswp_rx
_Rswp_rx:
	move.b	(17*4)+0(a5),d0
	move.b	(16*4)+0(a5),(17*4)+0(a5)
	move.b	d0,(16*4)+0(a5)

	move.b	(17*4)+1(a5),d0
	move.b	(16*4)+1(a5),(17*4)+1(a5)
	move.b	d0,(16*4)+1(a5)

	move.b	(17*4)+2(a5),d0
	move.b	(16*4)+2(a5),(17*4)+2(a5)
	move.b	d0,(16*4)+2(a5)

	xjsr	RangeBarRGB
	xjsr	ViewBarHam

*	DUMPCXG	<SWAP RANGE ENDS PLEASE.>
	rts	


	xdef	_Tprx_rx
_Tprx_rx:	
 ifeq	0
	xjsr	Assemble_IPS_Arg
	move.l	RexxLibrary_(BP),d0
	DUMPREG	<D0-REXXBASE>
	xref	OnlyPort_
	lea	OnlyPort_(BP),a0	;port
*	move.l	#0,a0			;port
	move.l	#0,a1			;Extension
	move.l	#0,d0			;Host	
	CALLIB	Rexx,CreateRexxMsg
*	DUMPHEG	<d0-REXX MSG?>

	tst.l	d0
	beq	.norexxmsg
	move.l	d0,a4
	move.l	#RXCOMM!(1<<RXFB_NOIO)!RXFF_NONRET,rm_Action(a4)
	move.l	RexxLibrary_(BP),rm_LibBase(a4)
	
	xref	ArexxCL
	lea	ArexxCL,a0			;Arg string ptr
	bsr	StrLen

	DUMPMEM	<AREXXCL>,(A0),#100	

*	move.l	#9,d0				;length of argstring
	CALLIB	Rexx,CreateArgstring
	tst.l	d0
	beq	.norexxarg
	move.l	d0,ARG0(a4)
	
	lea	Rexxportname,a1
	CALLIB	Exec,FindPort
	tst.l	d0

	move.l	d0,a0
	move.l	a4,a1
	CALLIB	Exec,PutMsg
.norexxarg
.norexxmsg
 endc
	rts

****
*
* Begin Processing a clip. 
*
****
	xdef	_Cprx_rx
_Cprx_rx:	
	st	FlagProcClip_(BP)
	bsr	_Sacp_rx			;Have user select an output clip
	rts	

BeginClipProcess:
	sf	FlagProcClip_(BP)		;Now processing clip so turn off reminder flag!
	DUMPREG	<Begining clip process>	
;Copy Start frame to Current frame
	lea	TCBuff01,a0
	lea	TCBuff02,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	bsr	UpdateTCDisp
	bsr	ClipArexxProc			;go and start arexx process	
	rts


justcopythatsall:
 ifeq	1
	sf	FlagProcClip_(BP)		;Now processing clip so turn off reminder flag!
	DUMPHEG	<Cprx>	
;Copy Start frame to Current frame
	lea	TCBuff01,a0
	lea	TCBuff02,a1
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+

;Get end frame count into d4
	lea	TCBuff03,a0
	bsr	TC2LONG
	move.l	d0,d4
.ClipProcessLoop
**** Process field_1 ****
	bsr	_Lfd1_rx			;Process field_1 
	bsr	_Apfc_rx			;write field to outclip
	                 
**** Process field_2 ****
	bsr	_Lfd2_rx			;Process field_2
	bsr	_Apfc_rx			;write field to outclip

;Inc framecount
	lea	TCBuff01,a0
	bsr	TC2LONG
	add.l	#1,d0
	DUMPHEG	<d0 framecount, d4 total count>	
	cmp.l	d4,d0
	bhi	.endprocess
	lea	TCBuff01,a0
	bsr	LONG2TC	
	bsr	UpdateTCDisp
	bra	.ClipProcessLoop	
.endprocess
**** Add icon to outclip ****
	bsr	DoClipIcon
 endc
	rts

 ifeq	0
ClipArexxProc:
	movem.l	d1-d5/a0-a4,-(sp)
	xjsr	Assemble_IPS_ArgC
	move.l	RexxLibrary_(BP),d0
	DUMPREG	<D0-REXXBASE>
	xref	OnlyPort_
	lea	OnlyPort_(BP),a0	;port
*	move.l	#0,a0			;port
	move.l	#0,a1			;Extension
	move.l	#0,d0			;Host	
	CALLIB	Rexx,CreateRexxMsg
	DUMPREG	<d0-REXX MSG?>
	tst.l	d0
	beq	norexxmsg01
	move.l	d0,a4
	move.l	#RXCOMM!(1<<RXFB_NOIO)!RXFF_NONRET,rm_Action(a4)
	move.l	RexxLibrary_(BP),rm_LibBase(a4)
	xref	ArexxCL
	lea	ArexxCL,a0			;Arg string ptr
	bsr	StrLen
	DUMPMEM	<AREXXCL>,(A0),#100	
*	move.l	#9,d0				;length of argstring
	CALLIB	Rexx,CreateArgstring
	tst.l	d0
	beq	norexxarg01
	move.l	d0,ARG0(a4)
	lea	Rexxportname,a1
	CALLIB	Exec,FindPort
	tst.l	d0
	move.l	d0,a0
	move.l	a4,a1
	CALLIB	Exec,PutMsg
norexxarg01
norexxmsg01
	movem.l	(sp)+,d1-d5/a0-a4
	rts
 endc


** Save framestore with 4bit alpha.
_Safa_rx:
	DUMPCXG	<Safa>
	move.l	#'Save',LS_String_(BP)		;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	st	FlagSave_(BP)			;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)		;0=means 'need image directory' 15NOV91
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	st	FlagAlphaFS_(BP)		;Saving alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xref FlagCompFReq_			;file requester...composite/framestore mode?
	st	FlagCompFReq_(BP)		;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	move.b	#0,FilenameBuffer_(BP)
	lea	DirnameBuffer_(BP),a2		;fill in 'dir name' with...
	lea	FrameDir,a1
;	lea	FrameStoreString(pc),a1
	xjsr	copy_string_a1_to_a2		;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts		


** Save 4bit alpha alone.
_Sa4a_rx:
	DUMPCXG	<Sa4a>
	move.l	#'Save',LS_String_(BP)		;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	st	FlagSave_(BP)			;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)		;0=means 'need image directory' 15NOV91
	sf	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	st	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xref FlagCompFReq_			;file requester...composite/framestore mode?
	sf	FlagCompFReq_(BP)		;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	move.b	#0,FilenameBuffer_(BP)
	lea	DirnameBuffer_(BP),a2		;fill in 'dir name' with...
	lea	RGBDir,a1
	xjsr	copy_string_a1_to_a2		;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts		

** Save 8bit Alpha alone.
_Sa8a_rx:
	DUMPCXG	<Sa8a>
	move.l	#'Save',LS_String_(BP)		;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	st	FlagSave_(BP)			;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)		;0=means 'need image directory' 15NOV91
	sf	FlagSelDestClip_(BP)
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	st	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xref FlagCompFReq_			;file requester...composite/framestore mode?
	sf	FlagCompFReq_(BP)		;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	move.b	#0,FilenameBuffer_(BP)
	lea	DirnameBuffer_(BP),a2		;fill in 'dir name' with...
	lea	RGBDir,a1
	xjsr	copy_string_a1_to_a2		;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts		


	xref	FlagField2loaded_
** Select save clip.
_Sacp_rx:
	DUMPCXG	<Sacp>
	move.l	#'Clip',LS_String_(BP)		;requester sez it all
*	st	FlagField2loaded_(BP)		;Fake it into thinking its time for field 1
	move.b	#0,FlagField2loaded_(BP)	;on first frame do no frame inc
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
*	st	FlagSave_(BP)			;flag sez why FileRequester is alive
	sf	FlagSave_(BP)			;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)		;0=means 'need image directory' 15NOV91
	st	FlagSelDestClip_(BP)		;if both FlagSelDestClip_(BP) and FlagSelClip_(BP) then selecting output clip.
	st	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xref FlagCompFReq_			;file requester...composite/framestore mode?
	sf	FlagCompFReq_(BP)		;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	move.b	#0,FilenameBuffer_(BP)

	lea	DirnameBuffer_(BP),a2		;fill in 'dir name' with...

	xref	ClipDir
	lea	ClipDir,a1
	xjsr	copy_string_a1_to_a2		;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts		

_Iclp_rx:
	xjsr	DoClipIcon			;test makeing icon for paint clips
	rts



*** Allocate the 4bit fastram alpha buffer used in keeping and saving and loading 4 bit alpha images.
_Aa4b_rx:
	DUMPMSG	<_Aa4b>
	xjsr	AllocateAlphaPlanes	
*	xjsr	Copy2AlphaPlanes
	xjsr	GetAlphaTestImage
	rts

*** Free the 4bit fastram alpha buffer used in keeping and saving and loading 4 bit alpha images.
_Fa4b_rx:
*	xjsr	FreeAlphaPlanes
	xjsr	SaveAlphaTestBM
	rts

*** Copy 4 bit alpha to the 4 bit alpha buffer from the screen AlphaBM
_Ca4b_rx:
	xjsr	Copy2AlphaPlanes
	rts

*** Move the 4 bit alpha data into the Red byte buffer of the BigPicture
_Ma4b_rx:
	xjsr	Move4Bit2Red
	rts


** User fileReq called from arexx.
_Askf_rx:	
	DUMPMEM	<checking to see if msg still in a0 at _Askf_rx:>,(A0),#64	
	move.l	a0,RexxMsgRtnDelayed_(BP)		;keep this message for now
	bsr	grab_srxarg
	xref	RexxFBStr
	lea	RexxFBStr,a1
1$	move.b	(a0)+,(a1)+
        bne.s   1$

	clr.l	MsgPtr_(BP)				;clear out saved msg now
*	move.l	#'Rexx',LS_String_(BP)			;requester sez it all
	st	FlagRexxReq_(BP)
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)				;this flag only pertains to 'file requester'
	sf	FlagSave_(BP)				;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)			;0=means 'need image directory' 15NOV91
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8 
	sf	FlagLoadAlpha_(BP)		;Loading an Alpha image 


	xref FlagCompFReq_	;file requester...composite/framestore mode?
	sf	FlagCompFReq_(BP)	;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagSelDestClip_(BP)


	move.b	#0,FilenameBuffer_(BP)
*	move.l	ToastFSNamePtr_(BP),d0
*	beq.s	9$			;not from switcher, invalid pointer
*	ADDQ.L	#1,D0			;BUMP NAME POINTER FROM SWITCHER...
*	move.l	d0,a1
*	lea	DirnameBuffer_(BP),a2	;fill in 'dir name' with framestore name...
*	xjsr	copy_string_a1_to_a2
*	lea	-1(a2),a2		;backup to "null"

*	xref	FrameDir
*	lea	FrameDir,a1
*	lea	FrameStoreString(pc),a1	;append "framestore" to device name
*	xjsr	copy_string_a1_to_a2	;dirrtns.asm
*	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts



	xref	AUR_StrBuffer,RexxResult1_
	xref	UserText1,UserText2
** put up requestor and ask user for feedback.
_Asku_rx:		
	bsr	grab_srxarg
	DUMPMEM	<srxarg>,(A0),#64
	lea	UserText1,a1
	move.l	it_IText(a1),a1
	move.w	#20,d0
121$	cmp.b	#';',(a0)
	beq	130$	
	move.b	(a0)+,(a1)+
	dbeq	d0,121$
130$
	move.b	#0,(a1)	
	cmp.b	#';',(a0)
	beq	132$
131$
	cmp.b	#';',(a0)
	beq  	132$
	cmp.b	#0,(a0)
	beq	133$
	lea	1(a0),a0
	bra	131$
** null hit before ; no second string.
133$
	lea	UserText2,a1
	move.l	it_IText(a1),a1
	move.b	#0,(a1) 	
	lea	AUR_StrBuffer,a1
	move.b	#0,(a1)
	bra	135$	
132$
	lea	1(a0),a0
	lea	UserText2,a1
	move.l	it_IText(a1),a1
	move.w	#12,d0
138$	cmp.b	#';',(a0)
	beq	150$
	move.b	(a0)+,(a1)+
	dbeq	d0,138$		
****
150$
	move.b	#0,(a1)
	cmp.b	#';',(a0)
	beq	152$
151$
	cmp.b	#';',(a0)
	beq  	152$
	cmp.b	#0,(a0)
	beq	153$
	lea	1(a0),a0
	bra	151$
** null hit before ; no second string.
153$
	xref	AUR_StrBuffer
	lea	AUR_StrBuffer,a1
	move.b	#0,(a1) 	
	bra	135$	
152$
	lea	1(a0),a0
	lea	AUR_StrBuffer,a1
	move.w	#12,d0
158$	move.b	(a0)+,(a1)+
	dbeq	d0,158$		
	move.b	#0,(a1)

135$
;	bsr	Prep_Call
	DUMPMSG	<branching to RealARTest>
	xjsr	RealARTest
	DUMPMSG	<returned from RealARTest>	
	
	cmp.l	#'FAUL',d0
	bne	432$
	move.l	#5,RexxResult1_(BP)
	bra	440$
432$
	lea	AUR_StrBuffer,a0
	moveq	#0,d0
	move.l	a0,a1
1$	add.l	#1,d0
	tst.b	(a1)+
	bne	1$
	CALLIB	Rexx,CreateArgstring
	move.l	d0,RexxResult_(BP)
440$	DUMPMSG	<done with Asku>
	rts	



 ifeq 1
Prep_Call:
	movem.l	d0-d3/a0-a3,-(sp)
	lea	UserText1,a0
	moveq	#20,d0
	bsr	CText				
	movem.l	(sp)+,d0-d3/a0-a3
	rts	

**********************
*
*   CText(Str_Ptr, String_space)
*	  a0	   d0		
*
**********************
CText:	movem.l	d0-d7/a0-a6,-(sp)

	move.l	a0,a3		;keep vars safe
	move.l	d0,d3
	
	moveq	#1,d1
110$	tst.b	(a0)+
	beq	100$
	add.l	#1,d1
	bra	110$	
100$
	move.l	a3,a1

	DUMPREG	<d0=full space len, d1=just string len>	
	sub.l	d1,d0
	asr.l	#1,d0	
;	tst.l	d0
;	beq	end	
	DUMPREG	<d1=strlen, d0=cval >	
	add.l	d1,a1
	add.l	d0,a1
	move.l	d1,d2	

120$	move.b	-(a0),-(a1)
	dbf	d2,120$

*	move.l	a3,a1
*130$	move.b	#' ',-(a1)
*	sub.w	#1,d1	
*	bne	130$
	DUMPMEM	<At end for CText>,(A3),#64	

	movem.l	(sp)+,d0-d7/a0-a6
	rts
 endc

	xref	UserTextBL1,UserTextBL2
_Askb_rx:		
	bsr	grab_srxarg
	DUMPMEM	<srxarg>,(A0),#64
	lea	UserTextBL1,a1
	move.l	it_IText(a1),a1
	move.w	#20,d0
121$	cmp.b	#';',(a0)
	beq	130$	
	move.b	(a0)+,(a1)+
	dbeq	d0,121$
130$
	move.b	#0,(a1)	
	cmp.b	#';',(a0)
	beq	132$
131$
	cmp.b	#';',(a0)
	beq  	132$
	cmp.b	#0,(a0)
	beq	133$
	lea	1(a0),a0
	bra	131$
** null hit before ; no second string.
133$
	lea	UserTextBL2,a1
	move.l	it_IText(a1),a1
	move.b	#0,(a1) 	
	bra	135$	
**
132$
	lea	1(a0),a0
	lea	UserTextBL2,a1
	move.l	it_IText(a1),a1
	move.w	#20,d0
138$	move.b	(a0)+,(a1)+
	dbeq	d0,138$		
	move.b	#0,(a1)
135$
	xjsr	RealTFTest
	lea	UW,a0
	move.l	d0,(a0)

	moveq	#0,d0
	move.l	a0,a1
1$	add.l	#1,d0
	tst.b	(a1)+
	bne	1$
	CALLIB	Rexx,CreateArgstring
	move.l	d0,RexxResult_(BP)
	rts	


UW	dc.b	'0000',0,0,0,0

_Abou_rx:		
	xjsr	RealABTest
	lea	VerStr,a0
	moveq	#0,d0
	move.l	a0,a1
1$	add.l	#1,d0
	tst.b	(a1)+
	bne	1$
	CALLIB	Rexx,CreateArgstring
	move.l	d0,RexxResult_(BP)
	rts	

	xref	VerStr	
;VerStr	dc.b	'xxxx.xxxx',0	;moved to  AutoRequest.asm
;	nop


** Load alpha image only.
_Loai_rx:
	DUMPCXG	<Loai>
	move.l	#'Load',LS_String_(BP)		;requester sez it all
	sf	FlagBrush_(BP)
	sf	Flag24_(BP)
	sf	FlagFont_(BP)			;this flag only pertains to 'file requester'
	sf	FlagSave_(BP)			;flag sez why FileRequester is alive
	st	FlagOpen_(BP)
	sf	FlagImageDir_(BP)		;0=means 'need image directory' 15NOV91
	sf	FlagSelDestClip_(BP)
	sf	FlagSelClip_(BP)
	sf	FlagAlphaFS_(BP)		;Saveing alpha with framestore
	sf	FlagAlpha4_(BP)			;Saving alpha 4
	sf	FlagAlpha8_(BP)			;~Saving alpha 8
	st	FlagLoadAlpha_(BP)		;Loading an Alpha image 
	xref FlagCompFReq_			;file requester...composite/framestore mode?
	sf	FlagCompFReq_(BP)		;file requester...composite/framestore mode?
	st	FlagNeedGadRef_(BP)
	move.b	#0,FilenameBuffer_(BP)
	lea	DirnameBuffer_(BP),a2		;fill in 'dir name' with...
	lea	RGBDir,a1
	xjsr	copy_string_a1_to_a2		;dirrtns.asm
	DUMPBEM	<DirnameBuffer>,-16(A2),#32
9$:	rts		

	xref	numoffields
	xref	SRC_ClipLen
** Setup TimeCode for load clip
_TC01_rx
	xref	TCBuff01
	lea	TCBuff01,a0
	moveq	#0,d0
	bsr	TC2LONG
** range test
	move.l	SRC_ClipLen,d7			get limit number
	sub.l	#1,d7				one less
	asr.l	#1,d7				/2
	cmp.l	d0,d7
	bcc	10$
	move.l	d7,d0
10$
**
	move.l	d0,numoffields
	xjsr	Jogtest

	lea	TCBuff01,a0
	bsr	LONG2TC
	bsr	UpdateTCDisp	
	rts

** Setup TimeCode for Beg Process
_TC02_rx
	xref	TCBuff02
	lea	TCBuff02,a0
	moveq	#0,d0
	bsr	TC2LONG
** range test
	move.l	SRC_ClipLen,d7			get limit number
	sub.l	#1,d7				one less
	asr.l	#1,d7				/2
	cmp.l	d0,d7
	bcc	10$
	move.l	d7,d0
10$
**
	move.l	d0,numoffields
	xjsr	Jogtest

	lea	TCBuff02,a0
	bsr	LONG2TC
	bsr	UpdateTCDisp	
	rts

** Setup TimeCode for End Process
_TC03_rx
	xref	TCBuff03
	lea	TCBuff03,a0
	moveq	#0,d0
	bsr	TC2LONG
** range test
	move.l	SRC_ClipLen,d7			get limit number
	sub.l	#1,d7				one less
	asr.l	#1,d7				/2
	cmp.l	d0,d7
	bcc	10$
	move.l	d7,d0
10$
**
	move.l	d0,numoffields
	xjsr	Jogtest

	lea	TCBuff03,a0
	bsr	LONG2TC
	bsr	UpdateTCDisp	
	rts


** CONVERT LONG-TC TO A NUMBER OF FIELDS.
	xdef	TCLONG2FIELDS
TCLONG2FIELDS:
	movem.l	d1-d5,-(sp)
;	DUMPHEG	<TIMECODE IN = D0>
	
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

;	;//H = F/108000;
;	divu	#108000,d0
;	move.w	d0,d4		;get hours
;	;//F %= 108000;
;	swap	d0
;	and.l	#$0000ffff,d0
	move.l	#108000,d1
	bsr	Divide32	
	move.w	d0,d4		;get hours
	move.w	d1,d0
	and.l	#$0000ffff,d0

	;//M = F / 1800;  // 60 secs/min * 30 frames/secs
	divu	#1800,d0
	move.w	d0,d3		;get min
	;//F %= 1800;
	swap	d0
	and.l	#$0000ffff,d0

	;//S = F / 30;
	divu	#30,d0
	move.w	d0,d2		;get seconds
	swap	d0
	and.l	#$0000ffff,d0

	;//F %= 30;
	move.w	d0,d1

	moveq	#0,d0
*	move.l	d4,TCHours
*	mulu	#360000,d4
*	add.l	d4,d0	
*	move.l	d3,TCMins
	mulu	#3600,d3
	add.l	d3,d0		acc
*	move.l	d2,TCSecs
	mulu	#60,d2	
	add.l	d2,d0		acc
*	move.l	d1,TCFrames	
	mulu	#2,d1
;	DUMPHEG	<D1-TCFRAMES/FIELDS>
	add.l	d1,d0		acc
	movem.l	(sp)+,d1-d5
	rts



** convert from a tc_string(a0) to a timecode long.
	xdef	TC2LONG
TC2LONG:
;	DUMPCXG	<TC2LONG>	
	movem.l	d0-d6/a1-a6,-(sp)
*	lea	TimeCodeStr,a0
;	move.l	a0,a4
	moveq	#0,d3		init tc.long.acc
	bsr	Dec2Int		HH
*	mulu	#108000,d0	can't do that need diff mulx		
	move.l	d0,d1
	move.l	#108000,d2
	bsr	Mulu32
	add.l	d1,d3		acc
*	add.l	d0,d3		acc
;	DUMPHEG	<D1-HH>
	bsr	Dec2Int		MM
	mulu	#1800,d0	calc number
	add.l	d0,d3		acc
;	DUMPHEG	<D0-MM>
	bsr	Dec2Int		SS
	mulu	#30,d0		calc number
	add.l	d0,d3		acc
;	DUMPHEG	<D0-SS>
	bsr	Dec2Int		FF
	add.l	d0,d3		acc
;	DUMPHEG	<D0-FF>
	move.l	d3,d0
	bsr	pickupframes
	move.l	d0,(sp)
;	DUMPHEG	<D0-TIMECODE LONG>	
	movem.l	(sp)+,d0-d6/a1-a6
	rts

	xdef	UpdateTCDisp
UpdateTCDisp:
	DUMPCXG	<UpdateTCDisp>
	movem.l	d0-d4/a0-a6,-(sp)
	move.l	GWindowPtr_(BP),a0	;hires window?
	move.l	wd_RPort(a0),a0		;use WINDOW's not screen's rast port
	move.l	#0,d0
	move.l	#0,d1
	lea	ITTCBuff01,A1
	CALLIB	Intuition,PrintIText
	movem.l	(sp)+,d0-d4/a0-a6
	rts

* CONVERT A0->NNDECIMAL TO VALUE IN REG D0
Dec2Int:	
	moveq	#0,d0		init vars
	moveq	#0,d1
	move.b	(a0)+,d0	get 10's digit	
	sub.b	#$30,d0		convert from ascii
	mulu	#10,d0		get value of 10's
	move.b	(a0),d1		get 1's digit
	sub.b	#$30,d1		convert from ascii
	add.l	d1,d0		accumulate
	lea	2(a0),a0	skip X:				
	rts


** d0 = tc.long(L) a0 -> string(14)(*T)	
	xdef	LONG2TC
LONG2TC:	
;	DUMPHEG	<LONG2TC>
	movem.l	d0-d6/a2-a6,-(sp)
	;//F = L;
	moveq	#0,d2		;hours
	moveq	#0,d3		;mins
	moveq	#0,d4		;secs
	move.l	a0,a3		;outString
	
	;//if(UseDropFrame) F=DropFrames(L); // add extra time since frames last longer than 1/30
	bsr	Dropframes
	move.l	d0,d1		;long to c~onvert

	move.l	d0,-(sp)
;	;//H = F/108000;
;	divu	#108000,d1
;	move.w	d1,d2		;get hours
;	;//F %= 108000;
;	swap	d1
;	and.l	#$0000ffff,d1
	move.l	d1,d0
	move.l	#108000,d1
	bsr	Divide32	
	move.w	d0,d2		;get hours
;	DUMPHEG	<after Divide32 d0, d1=remainder>
	move.l	(sp)+,d0
*	and.l	#$0000ffff,d1				;dont do this it cuts off part of the remainder in the 2nd 1/2 hour.
;
	;//M = F / 1800;  // 60 secs/min * 30 frames/secs
	divu	#1800,d1
;	DUMPHEG	<After min dev>
	move.w	d1,d3		;get min
	;//F %= 1800;
	swap	d1
	and.l	#$0000ffff,d1

	;//S = F / 30;
	divu	#30,d1
	move.w	d1,d4		;get seconds
	swap	d1
	and.l	#$0000ffff,d1

	;//F %= 30;
*	and.l	#$0000ffff,d1
	;//sprintf(T,"%02ld:%02ld:%02ld:%02ld",H,M,S,F);

	move.l	d2,TCHours
	move.l	d3,TCMins
	move.l	d4,TCSecs
	move.l	d1,TCFrames

	lea	fmt_str,a0		;formatstring
	lea	TCHours,a1		;DataStream
	lea	stuffChar(pc),a2	;putchproc
*	lea	a3,a3			;putchdata

	CALLIB	Exec,RawDoFmt

	movem.l	(sp)+,d0-d6/a2-a6
	rts	

fmt_str	dc.b	'%02ld:%02ld:%02ld:%02ld',0

** d0 	
Dropframes:	
	movem.l	d0-d6/a2-a6,-(sp)
	tst.l	d0
	beq	99$			;zero so exit
	
	move.l	d0,d1
	sub.l	#1,d1
	divu	#17981,d1
	and.l	#$0000ffff,d1
	mulu	#18000,d1
	divu	#1800,d1
	and.l	#$0000ffff,d1
	tst.l	d1
	bne	99$
	
	move.l	d1,d2
	divu	#10,d2	
	and.l	#$0000ffff,d2
	sub.l	d2,d1
	mulu	#2,d1
	add.l	d1,(sp)
99$
	movem.l	(sp)+,d0-d6/a2-a6
	rts	

*	ULONG	mins;
*	if(ticks>0)
*		if(mins=(18000 * (ticks-1)/17981) /1800)
*			return( ticks + 2*((mins) - ((mins)/10)) );
*	return(ticks);


***** d0 = Ticks returned in d0
pickupframes:
	movem.l	d0-d6/a2-a6,-(sp)
*
	divu	#1800,d1
	and.l	#$0000ffff,d1
	tst.l	d0
	beq	99$		
	move.l	d1,d2
	divu	#10,d2
	and.l	#$0000ffff,d2
	sub.l	d2,d1
	asl.l	#1,d1
	add.l	d1,(sp)
99$
	movem.l	(sp)+,d0-d6/a2-a6
	rts
	

Mulu32:	
	movem.l	d3-d5,-(sp)	
	move.l	d1,d3			copy multipicand into d3
	move.l	d1,d4			and into d4	
	swap	d4			in swaped form	 
	move.l	d2,d5			copy multiplier into d5
	swap	d5			in swapped form 
	mulu	d2,d1			partial prodeuct #1
	mulu	d4,d2					 #2
	mulu	d5,d3					 #3
	mulu	d5,d4					 #4
	swap	d1			sum1 = pp #2 low +			
	add	d2,d1			pp #1 high
	clr.l	d5			
	addx.l	d5,d4			propagate carry into pp #4
	add	d3,d1			sum2 = sum1 + pp #3 low
	addx.l	d5,d4			propagate carry into pp #4		
	swap	d1			put low prod. in correct order
	clr	d2			
	swap	d2
	clr	d3
	swap	d3
	add.l	d3,d2			sum3 = pp #2 high + PP #3 high
	add.l	d4,d2			sum4 = sum3 + pp #4	
	movem.l	(sp)+,d3-d5	
	rts	
	
Divide32:
	movem.l	d2-d3,-(sp)	
	tst.l	d1
	beq.s	1$
	tst.l	d0
	beq.s	2$
	moveq	#0,d2
	moveq	#$1f,d3
4$	asl.l	#1,d0
	roxl.l	#1,d2
	cmp.l	d1,d2
	bcs.s	3$
	sub.l	d1,d2
	add.l	#1,d0
3$	dbf	d3,4$
	move.l	d2,d1
	bra	5$
2$	clr.l	d1
1$	clr.l	d0
5$ 	movem.l	(sp)+,d2-d3
	rts	

	xdef	_sprintf	
_sprintf:	movem.l	a2-a4/a6,-(sp)
		move.l	$14(sp),a3
		move.l	$18(sp),a0
		lea	$1C(sp),a1
		lea	stuffChar(pc),a2
		CALLIB	Exec,RawDoFmt
		DUMPCXG	<sprintf>
		movem.l	(sp)+,a2-a4/a6
		rts
	xdef	stuffChar
stuffChar:
		move.b	d0,(a3)+
		rts


 ifeq 1
TestRPort:
	movem.l	d0-d5/a0-a6,-(SP)
	move.l	GWindowPtr_(a5),a0		;window
	move.l	wd_RPort(a0),a1
	moveq	#0,d0
	move.b	rp_Mask(a1),d0
	DUMPHEG	<D0-rp_mask>
	movem.l	(SP)+,d0-d5/a0-a6
	rts
 endc



TestRPort:
	movem.l	d0-d5/a0-a6,-(SP)

	move.b	FlagPick_(BP),d0
	DUMPHEG	<D0-FlagPick>

	movem.l	(SP)+,d0-d5/a0-a6
	rts




StrLen:			; COUNT A STRING PASSED IN A0 RETURN D0 LEN
	MOVEM.L	D0-D1/A0,-(SP)
	MOVEQ	#0,D0
.REPEAT	TST.B	(A0)+
	BEQ	.DONE	
	ADD.L	#1,D0
	BRA	.REPEAT
.DONE	
	MOVE.L	D0,(SP)
	MOVEM.L	(SP)+,D0-D1/A0
	RTS


_Cunt_rx:
	st	FlagNeedGadRef_(BP)	;causes redohires->updatemenu
	rts



	ALLDUMPS	




TCHours		dc.l	0
TCMins		dc.l	0
TCSecs		dc.l	0
TCFrames	dc.l	0	


TESTCLIPNAME:	dc.b	'                                                 ',0
Rexxportname:	dc.b	'AREXX',0
TESTARGSTRING:	dc.b	'RAM:TEST',0,0


BestName:	dc.b	'ram:testbrush',0

			
BogStr:		dc.b	'Bogus messages, ya ya do the right thing!',0
FR_StrBuffer	dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


	nop

ACTable:	;table of Long action code, Word offset to rtn, start of table

Action:	macro	;next action code
	dc.l	'\1' 	;long ascii, mixed case
	dc.w	_\1_rx-ACTable
	endm

	include "ps:actions.i"	;ps: is source directory

 	dc.l	0
	dc.w	0	;*THIS* zero flags 'end of table'




  END 
