* CutPaste.asm

	XDEF Cut	;creates a brush from screen
	XDEF CutLoadedBrush	;may06
	XDEF CutorPaste	;cutpaste mode, button up, newcut or pastedown handler
	XDEF EndCutPaste
	XDEF InitCutPaste
	XDEF MoveDoubleFront	;swap screen, doublebitmap, update display
	XDEF Paste		;sticks PasteBitMap=>ScreenBitMap at MyDrawX,Y
	XDEF Paste_Again

	XDEF DoShowPaste	;timer'd version of 'showpaste'
	;XDEF DoMinShowPaste	;enforce minimum timing on brush display
	XDEF ReallyShowPaste	;quick "blit" of brush to screen
	XDEF UnShowPaste	;guarantees that ScreenBitMap is 'clean'

* old/slowish/glitchyish display (blits.o//reseepaste) still used if no memory,
* ...else DoubleBitMap_ used to build display image, clean copy too

	include "ds:basestuff.i"
	include "lotsa-includes.i"
	include "libraries/dos.i"
	include "graphics/gfx.i"	;BitMap structure
	include "graphics/rastport.i"	;RastPort stuff
	include "windows.i"
	include "screens.i"
	include "ds:savergb.i"
	include "messages.i"	;MOUSEBUTTONS define

	xref ActionCode_
	xref BB1Ptr_	;CAN WE SUBSTITUE BB_Bitmap+bm_Planes ?????...no!
	xref BB_BitMap_
	xref BigPicHt_
	xref BigPicWt_
	xref BigPicWt_W_
	xref BrushGrabX_
	xref BrushGrabY_
	xref DoubleBitMap_
	xref DoubleBitMap_RP_
	xref bytes_per_row_
	xref EffectNumber_
	xref SwapBitMap_
	xref CutFlagPaste_


	xref CPUnDoBitMap_Planes_
	xref EffectNumber_	;mirror?...if so dont clear (yet)
	xref FlagAAlias_
	xref FlagBitMapSaved_	;reset, restart new 'edges' of rect,circ
	xref FlagBSmooth_	;smooth (connected dots) draw mode
	xref FlagCirc_		;test.l checks circ,curv,rect,line modes
	xref FlagCloseWB_
	xref FlagCutPaste_
	xref FlagCutShading_
	xref FlagDither_	;needed by paintcode
	xref FlagDisplayBeep_
	;xref FlagFrbx_		;asks for 'screen arrange'
	xref FlagHShading_
	xref FlagLace_
	xref FlagMagnifyStart_
	xref FlagMagnify_
	xref FlagMaskOnly_
	xref FlagMenu_
	xref FlagNeedGadRef_
	xref FlagNeedIntFix_
	xref FlagNeedMagnify_
	xref FlagNeedRepaint_
	xref FlagNeedShowPaste_
	xref FlagPick_
	xref FlagRepainting_
	xref FlagOpen_
	xref FlagText_		;set/cleared in textstuff.o
	xref last_paste_x_	;these are for pasting "again"
	xref last_paste_y_	;these are for pasting "again"
	xref line_offset_
	xref line_x_
	xref line_y_
	xref MagnifyOffsetX_
	xref MagnifyOffsetY_
	xref MaxTick_
	xref MWindowPtr_
	xref MyDrawX_
	xref MyDrawY_
	xref paint_leftside_	;ONLY USED BY REPAINT
	xref PasteBitMap_
	xref PasteBitMap_Planes_
	xref PasteMaskBitMap_
	xref PMBM_Planes_	;Paste Mask Bit Map _Planes_
	xref paste_clipy_	;#lines of top of scr
	xref paste_height_
	xref paste_leftblank_	;#pixels before 1st masked pixel in a brush
	xref paste_offsetx_
	xref paste_offsety_
	xref paste_width_
	xref paste_x_
	xref paste_y_
	xref PasteRastPort_
	xref pixels_row_less1_W_
	xref PlaneSize_
	xref save_display_x_
	xref save_display_y_
	xref ScreenBitMap_
	xref ScreenBitMap_Planes_
	xref DoubleBitMap_Planes_
	xref ScreenPtr_
	xref ShowPasteTick_
	xref Ticker_
	xref WindowPtr_
	xref Zeros_


Paste_Again:	;come here when again gadget hit, already have brush
	movem.w	last_paste_x_(BP),d0/d1	;x,y

		;MAY22late...dont allow cut/paste (ck if coords neg)
	tst.w	d0
	bpl.s	1$
	st	FlagDisplayBeep_(BP)
	rts
1$
	movem.w	d0/d1,save_display_x_(BP)
	movem.w	d0/d1,MyDrawX_(BP) ;for 'redo' when brush//mode//etc changes

Paste:	xjsr	SetAltPointerWait	;pointers.o, "wait" while redrawing shape
	xjsr	ClearBrushMask	;strokebounds.o;Clear out Brush/Repaint mask

	movem.l	Zeros_(BP),D0-d7/a2
	lea PasteMaskBitMap_(BP),A0	;"from" BRUSH'S MASK
	lea BB_BitMap_(BP),a1		;"to" 'REGULAR' drawing screensize MASK
	move.w	(a0),d4 ;bm_BytesPerRow(a0),d4
	asl.w	#3,d4			;#pixels=#bytes*8
	move.w	paste_height_(BP),d5	;d5=size Y  = height of dest. window

	move.w	paste_leftblank_(BP),paint_leftside_(BP) ;USED BY REPAINT
	move.w	MyDrawX_(BP),d2		;'center' of mousepointer
	sub.w	paste_offsetx_(BP),d2	;leftedge to blit whole brush to
	bpl.s	1$

	sub.w	d2,D0	;bump "fromX" to the right
	add.w	d2,d4	;reduce width (d4=width)
	SUB.w	d2,paint_leftside_(BP)	;USED BY REPAINT increase left->image
	;ADD.w	d2,paint_leftside_(BP)	;ONLY USED BY REPAINT reduce leftoffset
	moveq	#0,d2	;clear "to	X"
1$
	move.w	d2,d6	;check if off right side... (d6=temp)
	add.w	d4,d6	;toX+width
	subq.w	#1,d6	;...-1=rightside pixel	#
	cmp.w	BigPicWt_W_(BP),d6
	bcs.s	199$	;not off right side...
	move.w	BigPicWt_W_(BP),d4
	sub.w	d2,d4	;-toX = new width
199$
	clr.w	paste_clipy_(BP)	;this time only (used by repaint)
	move.w	MyDrawY_(BP),d3		;"to" y
	sub.w	paste_offsety_(BP),d3
	bpl.s	2$
	sub.w	d3,d1	;bump "fromY" down
	add.w	d3,d5	;reduce height
	sub.w	d3,paste_clipy_(BP)	;save positive "#lines off top of scr"
	moveq	#0,d3	;clear "to Y"
2$
	move.w	BigPicHt_(BP),d6	;max bot Y
	sub.w	d3,d6	; - "toY"
	cmp.w	d5,d6	;current ht <= dist to bottom edge?
	bcc.s	3$	;yes
	move.w	d6,d5	;no, only go up to right edge
3$
	move.b	#$C0,d6			;d6=minterm  , $C0="vanilla copy"
	moveq	#1,d7 ;move.b	#%00000001,d7		;d7=bitplane mask ("planepick")
	CALLIB Graphics,BltBitMap

	;move.w	save_display_x_(BP),last_paste_x_(BP) ;for "paste..[again]'
	;move.w	save_display_y_(BP),last_paste_y_(BP)
		;MAY15
	movem.W	MyDrawX_(BP),d0/d1
	;movem.w	save_display_x_(BP),d0/d1	;x,y
	movem.w	d0/d1,last_paste_x_(BP)
	movem.w	d0/d1,save_display_x_(BP)
	;movem.w	d0/d1,MyDrawX_(BP) ;for 'redo' when brush//mode//etc changes


	xjmp	RePaint_Picture		;scratch.o ;Again
	;rts		;Paste


MostlyEndCutPaste:	;subr...MACRO
	bsr	UnShowPaste		;remove brush image from visible screen
	xjsr	FreeLoResMask		;remove 'anti-alias' mask (textstuff.o ref')
	xjsr	FreeDouble		;removes double bitmap (if any)
	xjsr	FreeAreaStuff

	tst.l	PasteBitMap_Planes_(BP)	;any brush (anyway)?
	beq.s	no_old_brush
	sf	FlagNeedRepaint_(BP)	;may02...helps w/next std brush?
no_old_brush:
	xjsr	FreePaste		;memories.o, frees pastebitmap

	lea	PasteRastPort_(BP),a0	;rport,1 bitplane, shape&sizeof brush
	clr.l	rp_TmpRas(A0)	;RASTPORT why? graphics paradigm sometimes weak
	clr.W	paste_width_(BP)
	clr.W	paste_height_(BP)	;prevents InitBitPlanes from pasteinit
	clr.W	paste_leftblank_(BP)	;need cleared for fx
	sf	FlagBitMapSaved_(BP)	;primarily ref'd in memories.o
	st	FlagNeedGadRef_(BP)	;signal to redraw gadgets, reset brush
	sf	FlagCutPaste_(BP)	;kill cutpaste
	RTS	;		ENDM


InitCutPaste:
	;;xjsr	QuitPainting	;canceler.o	APRIL12'89

	bsr.s	MostlyEndCutPaste	;doesn't kill cpundo:xtra cutpaste undo

	;xjsr	AllocAndSaveCPUnDo	;memories.o
		;MAY18late....helps w/effects
	tst.l	CPUnDoBitMap_Planes_(BP)
	bne.s	9$
	xjsr	AllocCPUnDo		;alloc another backup bitmap
	cmp.b	#3,EffectNumber_(BP)	;flip horiz or rotate+/- ?
	bcs.s	8$			;no...save to copy
	tst.l	CPUnDoBitMap_Planes_(BP) ;did extra get alloc'd?
	beq.s	9$			;no...lowmem...skipthis
8$:	xjsr	SaveCPUnDo
9$:
	xjsr	CopyScreenSuper	;MAY19...fixes(?) draw-undo-cut-repeat

	tst.b	FlagCloseWB_(BP)
	bne.s	noundo_ok

	tst.l	CPUnDoBitMap_Planes_(BP)	;cutpaste undo screen copy
	beq.s	cprts ;EndCutPaste		;sorry, charlie, no undo around?
noundo_ok:

	sf	FlagRepainting_(BP)	;right *now* we're not 'repaint'ing
	sf	FlagNeedRepaint_(BP)	;we coulda cancel'd
	st	FlagCutPaste_(BP)	;reset to (newly 'on') cutpaste mode
	tst.l	FlagCirc_(BP)		;if no modes (circ/line/rect)...
	seq	FlagBSmooth_(BP)	;...ensure 'smooth' mode on
	;xjmp	ResetPointer		;pointers.o
	;bra	_ResetPointer

	xjmp	SetPointerCut		;may05'89....helps with kybd 'B'rush, 'A'gain

;may05;_ClearPointer:
;may05;	xjmp	ClearPointer		;pointers.o


EndCutPaste:
	tst.b	FlagCutPaste_(BP)	;"in" cutpaste mode, anyway? april01'89
	beq.s	1$			;yup...skip "clearpointer"
	pea	_ClearANDFixPointer		;call intuition LAST
1$:	bsr	MostlyEndCutPaste	;doesn't kill cpundo:xtra cutpaste undo
	xjsr	RestoreCPUnDo		;cpundo->regular "undobitmap" undo
	xjsr	FreeCPUnDo

	;sf	FlagNeedRepaint_(BP)
cprts:	rts

abort_cut:			;turn on a 'normal' brush, now
	;JUNE01;st	FlagFrbx_(BP)	;arrange screens (so can see the 'beep')
	st	FlagDisplayBeep_(BP)
	bsr.s	EndCutPaste
	;APRIL24;bsr	_CopySuperScreen		;'undo'
	sf	FlagNeedRepaint_(BP)

	;APRIL24
	;cmp.l	#'Redo',ActionCode_(BP)	;brush-repeat?
	;beq	_ClearANDFixPointer
	;bra	_CopySuperScreenRSTP	;copy undo->chipscreen, then resetpointer
_ClearANDFixPointer:
	;xjmp	ClearPointer	;APRIL24
	xjsr	ClearPointer	;APRIL24
	xjsr	AproPointer
	xjmp	FixPointer	;may16

CutorPaste:	;copy bitmaps (using 7th plane of paste map for brush mask)
	tst.l	PasteBitMap_Planes_(BP)	;do we already have a brush?
	bne	Paste			;already allocated

		;MAY22late...bummout last paste coords
	moveq	#-1,d0
	move.l	d0,last_paste_x_(BP)	;.w, last_paste_y.w too


;MAY29;	tst.l	FlagCirc_(BP)		;any modes?
;MAY29;	beq.s	Cut
	xjsr	SetAltPointerWait	;pointers.o, "wait" while redrawing shape

	st	FlagNeedHiresAct_(BP)	;april30
	xjsr	ReallyActivate	;main.o	;april30


	st	FlagMaskOnly_(BP) ;forces next routine to happen, no cancel
	st	FlagRepainting_(BP)	;"fool" drawbrush into entire shape
	xjsr	DoSpecialMode	;drawb.mode.i (norml'y called by main.o)
	sf	FlagRepainting_(BP)	;un-"fool"
	xjsr	KillLineList	;drawb.mode.i ;removes 'current shape'
	sf	FlagMaskOnly_(BP)
	xjsr	CheckCancel		;cancel'd while drawing/cutting shape?
	bne	abort_cut

Cut:	;creates a brush (if none), DOES screen->brushimage, superbit->screen
		;july06 new sequence: up-pri, endcutpaste, activate, setpointer

	sf	FlagNeedRepaint_(BP)	;MAY22
	xjsr	SetHigherPriority	;(background ok), main loop slows it
	bsr	MostlyEndCutPaste	;july06...helps w/magnify+singlepix cut?


;JULY06;	xjsr	SetAltPointerWait	;pointers.o, "wait" while redrawing shape
	xref FlagNeedHiresAct_
	st	FlagNeedHiresAct_(BP)
	xjsr	ReallyActivate	;main.o
;JULY06;	bsr	MostlyEndCutPaste
		;july06..lastly, set the pointer
	xjsr	SetAltPointerWait	;pointers.o, "wait" while redrawing shape

	tst.b	FlagText_(BP)	;gonna cut text?
	bne.s	textskipflood	;...if so, no 'flood'
	cmp.b	#3,EffectNumber_(BP)	;3=mirror,4=rot90,5=rot-90
	bcc.s	textskipflood	;...if so, no 'flood'

		;march27...flagclosewb check
	xref FlagCloseWB_
	tst.b	FlagCloseWB_(BP)
	beq.s	9$			;skip 'dealloc' of undo
	xjsr	RestoreCPUnDo		;cpundo->regular "undobitmap" undo
	xjsr	FreeCPUnDo	;march26'89...lowmem flood helper
9$:	xjsr	DoFlood		;newflood.o, flood fills drawing mask

  ifc 't','f' ;JULY05...bug fix for: single pixel cut not happen?
		;may05'89...
		;abort if flood fill didnt/couldnt happen
	tst.b	FlagDisplayBeep_(BP)
	;bne	abort_cut	;empty bitmap?
	beq.s	textskipflood		;no error from 'flood', continue
	xjsr	MarkedUnDo		;removes 'cutout' edge from screen
	bra	abort_cut
  endc

textskipflood:



	;APRIL02'89
	tst.B	FlagText_(BP)
	bne.s	noblowchip
	tst.W	FlagOpen_(BP)		;file requester alive? (dont undo)
	bne.s	noblowchip

	cmp.b	#3,EffectNumber_(BP)	;mirror?...if so dont clear (yet)
	bcc.s	noblowchip		;effect#3,4,5 (flips/rotates)
	xjsr	MarkedUnDo		;removes 'cutout' edge from screen
	;?;ALLOWS CUT,then paste right away;;;xjsr	ClearBrushMask		;strokebounds.o;blitclears drawing mask
	xjsr	ReMask		;handle transparency, "slicing of mask"

noblowchip:


	;APRIL02'89;xjsr	ReMask		;handle transparency, "slicing of mask"

		;get D0=xmin d1=ymin d2=xmax d3=ymax d4=width d5=height
CutLoadedBrush:		;may06
	xjsr	StrokeBounds	;strokeb.o, finds 'rectangle' inside drawmask
	bmi	abort_cut	;empty bitmap?

		;july07...fixing width, blew it with bstripe extra, for stretch fix?
	move.w	d4,paste_width_(BP) ;-(sp)	;"real", calc width, from bitmap JULY07 GONNA STACK 2x
	moveq	#3,d4	;blows calc'd imagewidth
	sub.w	d4,d0	;bup-3, starting x
	bcc.s	1$
	;move.w	d0,d4
	;neg.w	d4	;leftedge bup width, now
	addq	#3,d0	;original leftedge
	move.w	d0,d4	;=new leftblank
	moveq	#0,d0	;leftedge=0, now
1$:	move.w	d0,paste_x_(BP)
	move.w	d4,paste_leftblank_(BP)

	move.w	paste_width_(BP),d4
	asr.w	#1,d4
	add.w	paste_leftblank_(BP),d4
	move.w	d4,paste_offsetx_(BP)

	move.w	d1,paste_y_(BP)
	move.w	d5,paste_height_(BP)
	asr.w	#1,d5
	move.w	d5,paste_offsety_(BP)


	xjsr	AllocPaste		;Memories.o, subr frees current first

	tst.l	PasteBitMap_Planes_(BP)	;did get requested memory?
	beq	abort_cut		;(label at top of this module)
	xjsr	InitBitPlanes		;scratch.o, inits rastports, bitmaps
	st	FlagCutPaste_(BP)
	st	FlagNeedGadRef_(BP)	;will remove 'drawmodes' gadg-hilight'g

		;code to handle "scis"sors/draw/cutout/"repeat lineup" bug
	moveM.w	paste_x_(BP),d0/d1	;x,y
	add.w	paste_offsetx_(BP),d0
	add.w	paste_offsety_(BP),d1
	moveM.w	d0/d1,MyDrawX_(BP)	;x,y
	moveM.w	d0/d1,save_display_x_(BP)	;x,y


	movem.l	Zeros_(BP),D0-d7/a2	;from/to x/y =0
	lea BB_BitMap_(BP),A0		;"from" normal fullsize drawmask
	lea PasteMaskBitMap_(BP),a1	;"to" paste MASK bitmap

	move.w	paste_x_(BP),D0		;"from" x
	move.w	paste_y_(BP),d1		;"from" y ;D2=toX D3=toY

	move.w	(a1),d4 ;bm_BytesPerRow(a1),d4	;'to' bitmap width
	asl.w	#3,d4			;bytes/row in bitmap *8 = #pixels/row

	move.w	paste_height_(BP),d5	;d5=size Y = height of dest. window
	move.b	#$C0,d6			;d6=minterm $C0="vanilla copy"

	movem.l	D0-d6,-(sp)		;STACK all blit parameters
	move.b	#%00000001,d7		;d7=bitplane mask ("planepick")
	CALLIB Graphics,BltBitMap	;queue up blitter, THEN proc' copy

	tst.B	FlagText_(BP)
	bne.s	grabtextimage
	tst.W	FlagOpen_(BP)		;file requester alive? (dont undo)
	bne.s	grabtextimage

	cmp.b	#3,EffectNumber_(BP)	;mirror?...if so dont clear (yet)
	bcc.s	grabtextimage		;effect#3,4,5 (flips/rotates)
	xjsr	MarkedUnDo		;removes 'cutout' edge from screen
	;?;ALLOWS CUT,then paste right away;;;xjsr	ClearBrushMask		;strokebounds.o;blitclears drawing mask

grabtextimage:

	movem.l	Zeros_(BP),d7/a2
	lea PasteBitMap_(BP),a1		;"to" BRUSH IMAGERY bitmap
	movem.l	(sp)+,D0-d6		;deSTACK blit parms from prev mask blit

	move.w	d0,BrushGrabX_(BP)	;upper left for this brush image
	move.w	d1,BrushGrabY_(BP) 

	lea ScreenBitMap_(BP),A0	;"FROM" VISIBLE SCREEN bitmap

	move.b	#%00111111,d7		;d7=bitplane mask ("planepick")
	CALLIB	Graphics,BltBitMap	;this blit SCREEN->PasteBitMap


	tst.l	CPUnDoBitMap_Planes_(BP) ;already have 'cutpaste' undo?
	bne.s	29$
	xjsr	AllocCPUnDo	;Memories.o, Cut Paste UnDo (fastmem)

		;MAY18late...lowmem...no cpundo?
	tst.l	CPUnDoBitMap_Planes_(BP) ;already have 'cutpaste' undo?
	bne.s	28$
	cmp.b	#3,EffectNumber_(BP)	;3=mirror,4=rot90,5=rot-90
	bcc.s	29$
28$
	xjsr	CopyScreenCPUnDo
29$
	xjsr	GraphicsWaitBlit	;wait before munge blit-sourceMAY06'89

	xjsr	BStripe		;June24

30$
		;APRIL03'89
	tst.b	FlagText_(BP)
	beq.s	40$
	sf	FlagText_(BP)
	bra.s	_CopySuperScreenRSTP

40$
	xjsr	SwapSuperCPUnDo	;memories.o

_CopySuperScreenRSTP:
	st	FlagBitMapSaved_(BP)	;primarily ref'd in memories.o
	bsr.s	_CopySuperScreen	;*this* removes the text, reg undo->visible
;_ResetPointer:
	;?needed?march24'89;xjmp	ResetPointer
	;xjmp	ClearPointer
	bra	_ClearANDFixPointer
	;rts	;Cut

_CopySuperScreen:
	xjmp	CopySuperScreen	;*this* removes the text, reg undo->visible


DoShowPaste:				;'poll' this routine (main loop)
	move.l	ShowPasteTick_(BP),d0	;last 'tick time' we magnified
	sub.l	Ticker_(BP),d0
	bcc.s	1$
	neg.l	d0
1$	cmp.W	MaxTick_(BP),d0	
	bcc.s	ReallyShowPaste	;'maxcount' or more ticks have gone by
zmagrts	rts

ReallyShowPaste: ;guarantees that ScreenBitMap shows current pastebrush
	move.l	Ticker_(BP),ShowPasteTick_(BP)	;reset ticker b4 'unshow's
	sf	FlagNeedShowPaste_(BP)	;ONLY PLACE CLEARED in whole program
	st	FlagNeedMagnify_(BP) ;<-should only set this if "truly" needed

		;MAY14
	tst.b	FlagMagnify_(BP)
	beq.s	1$
	tst.b	FlagMagnifyStart_(BP)	;magnify locked in?
	beq	UnShowAndFreeDouble	;nope...outta here...
1$
		;NOV/DECEMBER 1990...as per richie k., remove brush when printing
	xref	FlagPrintReq_	;used by 'redohires' to sense 'which gadgets'
	tst.b	FlagPrintReq_(BP)	;used by 'redohires' to sense 'which gadgets'
	bne	UnShowAndFreeDouble	;UnShowPaste	;yep...outta here...

	tst.b	FlagMenu_(BP)	;menu displayed?
	bne	UnShowAndFreeDouble	;UnShowPaste	;yep...outta here...

	;st	FlagNeedMagnify_(BP) ;<-should only set this if "truly" needed

	tst.W	FlagOpen_(BP)		;filerequester alive?
	bne	UnShowPaste		;...flagopen or flagsave, noshow now
	tst.b	FlagCutPaste_(BP)	;don't show brush
	beq	UnShowPaste		;...when NOT in cutpaste
	tst.b	FlagPick_(BP)

	;may23;bne	UnShowPaste	;...when IN pick mode
	;bne	zmagrts		;MAY23	;leave brush alone when in pick mode
	beq.s	10$
	xref LastM_Window_
	xref GWindowPtr_
	move.l	LastM_Window_(BP),d0
	beq.s	10$			;no 'last msg' window?, continue&show
	cmp.l	GWindowPtr_(BP),d0	;'last msg' window=hires?
	beq.s	10$			;...yep, continue	
	;bne.s	zmagrts			;last msg NOT from hires, "stop"
	xref FlagSingleBit_	;indicates 'single bitplane undo' of cutpaste
	tst.b	FlagSingleBit_(BP)	;indicates 'single bitplane undo' of cutpaste
	bne.s	10$
	bra.s	zmagrts			;last msg NOT from hires, "stop"
10$
	tst.l	PasteBitMap_Planes_(BP)
	beq	UnShowPaste		;...when NO brush

	xjsr	SetHigherPriority	;(background ok), main loop slows it

		;handle remote (Ugad) action code....
		;grab coords from MyDrawX,Y...NOT mouse position

	xjsr	grab_arg_a0		;gadgetrtns.o
	beq.s	use_mouse
	move.l	ScreenPtr_(BP),D0
	beq	enda_showpaste		;nobigpic, wha?
	move.l	D0,A0			;a0=bigpic screen ptr
	moveq	#0,d0
	moveq	#0,d1
	movem.w	MyDrawX_(BP),d0/d1
	bra	gots_xy
use_mouse:


	move.l	MWindowPtr_(BP),D0
	beq.s	noton_mags		;not on magnify screen
	tst.b	FlagMagnifyStart_(BP)	;is magnify'ing already in progress?
	beq.s	noton_mags
	move.l	D0,A0		;MWindowPTr (magnify window)
	move.w	wd_MouseX(A0),D0
	move.w	wd_MouseY(A0),d1
	bmi.s	noton_mags	;mousepointer "above" magnify window on magscr
	asr.w	#3,D0		;x/8 (remember, weir doing a *8 magnify)
	asr.w	#2,d1		;y/4 (remember, weir doing a *8 magnify)
	tst.b	FlagLace_(BP)
	bne.s	7$
	;asr.w	#1,d0	;/8
	asr.w	#1,d1	;/8   MAY15
7$	add.w	MagnifyOffsetX_(BP),D0
	add.w	MagnifyOffsetY_(BP),d1
	;;bra.s	gots_xy		;got show x,y
	move.w	D0,save_display_x_(BP)	;parm for 'ReSeePaste' in blits.o
	move.w	d1,save_display_y_(BP)
	bra.s	okre_bottom
noton_mags:

	move.l	ScreenPtr_(BP),D0
	beq.s	enda_showpaste		;nobigpic, wha?
	move.l	D0,A0			;a0=bigpic screen ptr
	move.w	sc_MouseX(A0),D0
	move.w	sc_MouseY(A0),d1
	lea	sc_ViewPort(A0),a2	;a2=viewport
	move.l	vp_RasInfo(a2),a2	;a2=rasinfo
	add.w	ri_RxOffset(a2),D0	;d0=current x offset
	add.w	ri_RyOffset(a2),d1	;d1=current y offset

gots_xy:
	move.w	D0,save_display_x_(BP)	;parm for 'ReSeePaste' in blits.o
	move.w	d1,save_display_y_(BP)

		;if pointer is "off edge of screen BITMAP", 'hang up' at rtedge
		;MAY23......unshow if off bottom
	;cmp.w	sc_Width(a0),d0
	asr.w	#3,d0		;pixels->bytes
	cmp.w	sc_BitMap+bm_BytesPerRow(a0),d0	;past rt edge?
	bcs.s	okre_side
	move.w	sc_BitMap+bm_BytesPerRow(a0),d0
	asl.w	#3,d0
	subq	#1,d0	;rightmost pixel# in bitmap
	move.w	D0,save_display_x_(BP)	;parm for 'ReSeePaste' in blits.o
	;PEA	UnShowPaste	;MAY23...causes flicker
	BRA	UnShowPaste	;MAY23
okre_side:
		;if pointer is "off bottom", revert//hang up on bottom
		;MAY23......unshow if off bottom
	cmp.w	sc_BitMap+bm_Rows(a0),d1	;past bot end of bitmap?
	bcs.s	okre_bottom
	move.w	sc_BitMap+bm_Rows(a0),d1	;#rows in bitmap
	subq.w	#1,d1				;"last row#"
	move.w	d1,save_display_y_(BP)
	;PEA	UnShowPaste	;MAY23...causes flicker
	BRA	UnShowPaste	;MAY23
okre_bottom:
	movem.w	d0/d1,MyDrawX_(BP) ;for 'redo' when brush//mode//etc changes

	bsr.s	DoDouble
	bne.s	enda_showpaste	;else no memory for double scrn, do old way

	move.l	ScreenPtr_(BP),A0
	lea	sc_ViewPort(A0),A0
	bsr.s	internal_usp	;UnShowPaste	;remove brush from screen
	xjsr	ReSeePaste	;simple blit to see
enda_showpaste:
	;the following line ensures we dont "count" time while displaying
	move.l	Ticker_(BP),ShowPasteTick_(BP)	;reset ticktime for showpaste

	rts


	xref DeadY_
	xref DeadHt_	;only need to clear this many lines (unshow)
	xref FlagSingleBit_


UnShowPaste:	;guar' that ScreenBitMap is 'clean'
		;this routine also has NASTY HABIT of deleting the undo screen
	;tst.b	FlagMenu_(BP)	;menu displayed?
	;bne	enda_unshowp	;guru if dont stop upon menu?

	tst.w	DeadHt_(BP)
	beq.s	enda_unshowp	;nothing to "unshow"

	lea	DoubleBitMap_(BP),a1
	tst.l	bm_Planes(a1)		;get the bitmap (have plane adrs?)
	beq.s	checkdo_usp	;processor copy fastmem undobitmap->screen
	bsr	MoveDoubleFront	;removes brush by showing 'clean' bitmap
	clr.w	DeadHt_(BP)	;signal 'nothing to undo'
	;do not delete double buff';xjmp FreeDouble ;chip copy of screen for dbl buf'
	rts

 ;xdef UnShowAndFreeDouble
UnShowAndFreeDouble:
	bsr	UnShowPaste
	xjmp	FreeDouble

checkdo_usp:
	tst.l	PasteBitMap_Planes_(BP)	;really carrying a brush?
	beq.s	enda_unshowp

internal_usp:	;remove brush image from current 'gonna be screen' bitmap
	move.w	DeadHt_(BP),d5
	beq.s	enda_unshowp	;probably not happen...
	clr.w	DeadHt_(BP)	;for next time...so dont do 2x
	move.w	DeadY_(BP),d1	;d1 will calc 2b lineoffset to first line

 	xjsr	GraphicsWaitBlit ;memories.o, preserves allexcept A6

	tst.b	FlagSingleBit_(BP)
	beq.s	doiuall
	sf	FlagSingleBit_(BP)
	xjsr	IndSingleUndo
	bra.s	enda_unshowp
doiuall:
	xjsr	IndicatedUndo	;d1=first y line, d5=#lines

enda_unshowp:
	rts	



DoDouble:	;allocate CHIP backup of screen, for building 'final blit'
	lea	DoubleBitMap_(BP),a1
	tst.l	bm_Planes(a1)		;get the bitmap (have plane adrs?)
	beq.s	getnew_doub
	tst.w	DeadHt_(BP)
	bne.s	had_double	;ok, valid...
getnew_doub:
	move.l	a1,a0	;a0 is arg for initbitmap ;lea DoubleBitMap_(BP),a0
	movem.l	Zeros_(BP),d0-d2
	moveq	#6,d0			;6 bitplanes, please
	move.w	BigPicWt_W_(BP),d1	;big picture/page size
	move.w	BigPicHt_(BP),d2
	CALLIB	Graphics,InitBitMap

	xjsr	AllocDouble		;memories.o, allocs bitplanes
	lea	DoubleBitMap_(BP),a1	;alloc double returns non-cleared bitmap
	tst.l	bm_Planes(a1)		;get the bitmap (have plane adrs?)
	beq	nodouble
	xjsr	CopySuperDouble	;memories.o 'clean undo' into 'doublebitmap'

	lea	DoubleBitMap_(BP),a1
	lea	DoubleBitMap_RP_(BP),A0

	movem.l	A0/a1,-(sp)		;a0=rastport, a1=bitmap
	move.l	A0,a1			;a1 is args for next syscall
	CALLIB Graphics,InitRastPort	;sets fgpen=1, bg=0, aol=1
	move.l	(sp),a1			;rastport, stacked first,froma0
	moveq	#1,D0
	CALLIB	SAME,SetAPen
	movem.l	(sp)+,A0/a1		;a0=rastport, a1=bitmap

had_double:

	lea	DoubleBitMap_(BP),a1
	lea	DoubleBitMap_RP_(BP),A0

	move.l	a1,rp_BitMap(A0)	;shove A1=bitmap into A0 rastport struct
	move.b  #1,rp_FgPen(A0)
	move.b  #0,rp_BgPen(A0)
	move.b  #1,rp_AOLPen(A0)

 xref brush_x_
 xref brush_y_
 xref newblit_height_
 xref newblit_width_
scrx_d3		equr d3
scry_d4		equr d4

		;calc screen_(start_x,end_x,newblit_width_(BP)),brush_x
	lea	DoubleBitMap_(BP),a0	;bup copy of screen
	move.w	save_display_x_(BP),scrx_d3
	move.w	save_display_y_(BP),scry_d4
	clr.w	brush_x_(BP)		;starting x in brush bitmap

	move.w	PasteBitMap_(BP),d0	;bytesPERrow is 1st in struct
	asl.w	#3,d0			;*8
	move.w	d0,newblit_width_(BP)

	sub.w	paste_offsetx_(BP),scrx_d3
	bpl.s	10$			;branch when result >0 ;off left side?
	sub.w	scrx_d3,brush_x_(BP)	;move starting point to right
	add.w	scrx_d3,newblit_width_(BP)	;reduce our width when going off left
	clr.w	scrx_d3
10$	move.w scrx_d3,d0
	add.w	newblit_width_(BP),d0

	cmp.w	BigPicWt_W_(BP),d0	;NormalWidth_(BP),d0 ;#384,d0	;max right edge, #320,d0
	bcs.s	12$			;negative? ok, does fit on the screen
	sub.w	BigPicWt_W_(BP),d0
	sub.w	d0,newblit_width_(BP)	;reduce width
12$
	clr.w	brush_y_(BP)		;brush's bitmap

		;calc screen_(y,height)
	move.w paste_height_(BP),newblit_height_(BP)
	sub.w  paste_offsety_(BP),scry_d4
	bcc.s	20$			;branch when result >0 ;off top side?
	sub.w  scry_d4,brush_y_(BP)	;move starting point to down
	add.w  scry_d4,newblit_height_(BP)	;reduce height when going off top
	clr.w  scry_d4
20$	move.w scry_d4,d0
	add.w  newblit_height_(BP),d0
	subq.w #1,d0		;ending position = starting + width - 1
	cmp.w  bm_Rows(a0),d0	;BigPicHt_(BP),d0
	bcs.s  22$		;negative?(<ScrHt) ok, we fit on the screen
	move.w bm_Rows(a0),d0	;BigPicHt_(BP),d0
	subq.w #1,d0		;new ending pos. is line#(totalscreenheight-1)
22$	sub.w  scry_d4,d0
	addq.w #1,d0
	move.w d0,newblit_height_(BP)	;=endingpos-startingpos-1

	lea	PasteBitMap_(BP),a0	;FROM BITMAP
	lea	DoubleBitMap_RP_(BP),a1	;TO copy of screen

	moveq	#0,d0
	move.w	brush_x_(BP),d0
	;addq.w	#3,d0			;starting x inside paste brush
	moveq	#0,d1
	move.w	brush_y_(BP),d1
	moveq	#0,d2
	move.w	scrx_d3,d2
	moveq	#0,d3
	move.w	scry_d4,d3
	moveq	#0,d4
	move.w	newblit_width_(BP),d4
	moveq	#0,d5
	move.w	newblit_height_(BP),d5
	moveq	#0,d6
	move.b	#%11101010,d6 ;#$c3,d6 ;$C2,d6 ;#$60,d6 ;#$CA,d6 ;#$C0,d6 ;bumminterm for g-lib; #VANILLA_BLIT,d6	;equ $F0 ;  minterm bits (7,6,5,4)
	moveq	#0,d7
	move.b	#%00111111,d7	;bitplane mask
	move.l	PMBM_Planes_(BP),a2	;Paste MASK BitMap Planes

	movem.w	d3/d5,-(sp)	;STACK dead(y,height) parms

		; NDEF BltMaskBitMapRastPort,$FFFFFD84
		; BltMaskBitMapRastPort
	; (srcbm,srcx,srcy,destrp,destX,destY,sizeX,sizeY,minterm,bltmask)
		; (A0,D0/D1,A1,D2/D3/D4/D5/D6,A2)

	CALLIB	Graphics,BltMaskBitMapRastPort
	xjsr	GraphicsWaitBlit	;wait for blitter b4 showing double
	bsr.s	MoveDoubleFront	;removes brush by showing 'clean' bitmap

		;cleanup the 'doublebitmap'
	move.w	DeadY_(BP),d1	;"2nd last time ago" parms
	move.w	DeadHt_(BP),d5
	xjsr	DoubleUndo	;d1=first y line, d5=#lines

	move.w	(sp)+,DeadY_(BP)	;DESTACK
	move.w	(sp)+,DeadHt_(BP)

	moveq	#-1,d0		;flag notequal means 'DoDouble finished ok'
	rts		;DoDouble

nodouble:
	moveq	#0,d0	;flag zero means couldnt do it
	rts		;DoDouble

MoveDoubleFront:	;swap bitplanes btwn doublebitmap and screenbitmap
			;returns zero flag NE if ok, zero if no double

	lea	ScreenBitMap_Planes_(BP),a0
	lea	DoubleBitMap_Planes_(BP),a1

	moveq	#6-1,d0
swapbpp	move.l	(a1),d1		;bitplane ptr FROM doublebitmap
	beq.s	endamdf		;no bitplane(?)...outta here
	move.l	(a0),(a1)+
	move.l	d1,(a0)+
	dbf	d0,swapbpp

	;COPY bitplanes FROM 'good'(current) struct TO intuit'screen struct
	move.l	ScreenPtr_(BP),a0		;A0=arg for makescreen
	lea	ScreenBitMap_Planes_(BP),a1	;a1=basepage source 'good'
	lea	sc_BitMap+bm_Planes(a0),a2	;a2='real live',intuit's struct
	moveq	#6-1,d0
copybpp	move.l	(a1)+,(a2)+
	dbf	d0,copybpp
	CALLIB	Intuition,MakeScreen	;construct new copper stuff for vp

	st	FlagNeedIntFix_(BP)	;signals for makescreen
	xjmp	FixInterLace		;main.key.i ;NOW b4 any more blits
endamdf:
	rts	


  END