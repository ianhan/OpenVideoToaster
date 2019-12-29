******
* 
*  
*
*****

 XDEF Again
 XDEF Effect_RePaint	;entry for brushfx (rotates)
 XDEF EnsureWorkHires	;ensures savearray is doubled, called from RGBRtns
 XDEF EnsureWorkLores	;ensures savearray is doubled, called from RGBRtns
 XDEF InitBitNumSA	;SaveArray, inits s_BitNumber fields

 XDEF RePaint		;repaints window, mathematically is accurate than brush'
			;...gets called after DrawBrush, gets called from DrawBrush
 XDEF RePaint_Picture	;entry point for textstuff, cutting out text

LOWERDITHER	set 3 	;#to LOWER 6 bit max dither thresh by

* note: sunday june2490, an extra 32 pixels, on the left side, are
* calculated for.  These extra pixels are not plotted, though.
* This is done to eliminate the need for "startup colors" being correct...
* ...after recalculating the 32 ham pixels, we should have the correct
* correct 4 bit colors...

	xref HVStretchPotV	;STretching hor/ver combo pot, vertical value
	xref HVStretchPotH	;STretching hor/ver combo pot, hor value
	xref SinTab
	xref StdPot5		;warp amt	LOCATABLE, yuck
	xref StdPot6

	xref AirHeight_
	xref AirWidth_
	xref AirHalfHeight_
	xref AirHalfWidth_
	xref BB1Ptr_
	xref BigPicHt_
	xref BigPicRGB_
	xref BigPicWt_W_
	xref BlendCurvePtr_
	xref bmhd_rastwidth_
	xref bytes_per_row_
	xref bytes_per_row_W_
	xref bytes_row_less1_W_
	xref col_offset_
	xref CPUnDoBitMap_Planes_
	xref Datared_
	xref DetermineRtn_
	xref EffectNumber_
	xref ElliXRadius_
	xref ElliYRadius_
	xref FirstScreen_
	xref first_line_y_
	xref Flag24_
	xref FlagAgain_
	xref FlagBitMapSaved_
	xref FlagBrushColorMode_
	xref FlagCheckKillMag_
	xref FlagCirc_
	xref FlagColorZero_
	xref FlagCutPaste_
	xref FlagDisplayBeep_
	xref FlagDitherRandom_
	xref FlagDither_
	xref FlagFillMode_
	xref FlagFirstLine_
	xref FlagFirstLine_
	xref FlagFlood_
	xref FlagHShading_
	xref FlagHStretching_
	xref FlagLace_
	xref FlagMagnify_
	xref FlagMaskOnly_
	xref FlagNeedHiresAct_
	xref FlagNeedHiresAct_
	xref FlagNeedIntFix_
	xref FlagNeedMagnify_
	xref FlagNeedRepaint_
	xref FlagRepainting_
	xref FlagRub_
	xref FlagSetAir_
	xref FlagSetGrid_
	xref FlagSkipTransparency_
	xref FlagStretch_
	xref FlagText_
	xref FlagToast_
	xref FlagVShading_
	xref FlagVStretching_
	xref FlagWorkHires_
	xref FlagXLef_
	xref FlagXRig_
	xref FlagXSpe_
	xref fx_left_
	xref fx_right_
	xref halfpaint_width_
	xref LastPlot_
	xref LastRepaintX_
	xref last_line_y_
	xref last_paste_x_
	xref linecol_offset_
	xref line_offset_
	xref line_offset_
	xref line_y_
	xref LongColorTable_
	xref LoResMask_
	xref MagnifyOffsetY_
	xref MaxBit_
	xref MaxTick_
	xref MWindowPtr_
	xref Paint8red_
	xref Paint8green_
	xref Paint8blue_
	xref PaintNumber_
	xref paint_width_
	xref PasteBitMap_
	xref PaintRoutinePtr_
	xref PasteRGB_
	xref paste_clipy_
	xref paste_offsetx_
	xref paste_width_
	xref PasteBitMap_Planes_
	xref plwords_row_less1_
	xref Pot0Temp_
	xref Pot1Temp_
	xref ppix_row_less1_
	xref Pred_
	xref Predold_
	xref pwords_row_less1_
	xref random_seed_
	xref SAStartRecord_
	xref SAStartX_
	xref SaveArray_
	xref ScreenPtr_
	xref ScreenPtr_
	xref ShadeOnOffNum_
	xref StretchGain_
	xref StretchGainAlt_
	xref StretchHPot_
	xref StretchVPot_
	xref SwapBitMap_
	xref SwapRGB_
	xref Transpred_	;.word = red.b, green.b
	xref Transpblue_	;.byte
	xref TScreenPtr_
	xref UnDoBitMap_
	xref UnDoBitMap_Planes_

	;AUG291990, no need...yes, need;
	xref v_extraleft_

	xref WindowPtr_
	xref XMidPoint_
	xref XTScreenPtr_

SelectUp	equ $68!$80	;these codes basicly come from
SelectDown	equ $68	;....devices/inputevent.i
MenuDown	equ $69
MenuUp		equ $69!$80

;SERDEBUG	equ	1

	include "ram:mod.i"
	include "ps:basestuff.i"
	include "lotsa-includes.i"
	include "ps:raystuff.i"
	;include "libraries/dos.i"	;fib_ fileinfoblock struct for var
	;include "graphics/gfx.i"	;BitMap structure
	;include "graphics/rastport.i"	;RastPort stuff
	include "windows.i"
	include "screens.i"
	include "messages.i"	;06/24/87; for cancel message type
	include "ps:SaveRgb.i"
	include "requester.i"
	include	"exec/nodes.i"
	include	"exec/memory.i" ;needed for AllocMem/AllocRemeber requirements
	include "exec/ports.i"	;for mp_size message port struct
	;include "exec/interrupts.i"	;for is_size interrupt server
	;include "exec/io.i"	;for exec io_sizeof
	;include "devices/printer.i"	; for printer io req size
	;;include "intuition/intuitionbase.i"	;ib_FirstScreen
	include "ps:TopOFile.i"
	include	"ps:serialdebug.i"


*****
CHECKMASK:	MACRO	;(destroys d2/d3/d4)  (args d0=x d1=y a0=maskplane)
	move.w	d1,d4			;d4 gonna be address in bitplane
	mulu	PasteBitMap_(BP),d4	;y*#bytes per row in brush

	move.w	d0,d3	;d3=copy of x for BYTE
	asr.w	#3,d3	;x/8
	add.L	d3,d4	;upper bits of D3 guaranteed cleared by caller
	moveq	#7,d2	;prep for...
	sub.w	d0,d2	;d2=bit # in byte (+junk >7, ignored in  bXXX.b opcode)
	btst	d2,0(a0,d4.L)
 ENDM


STARTaLOOP:	MACRO	; dreg
	move.l	SAStartRecord_(BP),\1	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),\2	;Paint PIXels per row, minus one
 ENDM

STARTaWordLOOP:	MACRO	; dreg	;sets up reg for long word counted loop
	move.l	SAStartRecord_(BP),\1	;1st pixel's "record" inside savearray
	move.w	pwords_row_less1_(BP),\2	;Paint (short) Words per row
 ENDM

STARTaLongLOOP:	MACRO	; dreg	;sets up reg for long word counted loop
	move.l	SAStartRecord_(BP),\1	;1st pixel's "record" inside savearray
	move.w	plwords_row_less1_(BP),\2	;Paint Long Words per row
 ENDM

ivp:	MACRO	;requires d2=#s_SIZEOF (digipaint pi)
	move.l	d1,(a6)	;clears 2 words, verpixel & maxverpixel fields
	add.l	d2,a6	;lea	s_SIZEOF(a6),a6
 endm

ivp8:	MACRO	;codesize6*8=48bytes
	ivp
	ivp
	ivp
	ivp

	ivp
	ivp
	ivp
	ivp
 endm	ivp8


REMOVEMSG:	MACRO	;cloned from exec/lists
	MOVE.L	(A1),A0
	MOVE.L	LN_PRED(A1),A1
	MOVE.L	A0,(A1)
	MOVE.L	A1,LN_PRED(A0)
 ENDM

rset_addrbit:	MACRO	;codesize 20bytes
	;not for static...;nxtrandom d6		;MACRO, compute another random #
		;compute static dither
	;AUG211990;move.B	(a0)+,d6
	;;eor.B	d0,d6	;row constant, static dither	

	;;and.W	#$003f,d6;6 bits, only, for dither

	move.b	d7,(a6)+ ;s_PlotFlag
	;AUG211990;move.b d6,(a6)	;june22;d6,s_DitherThresh-s_PlotFlag(a6)
	move.B	(a0)+,(a6)
	;june22;lea	s_SIZEOF(a6),a6
	lea	(s_SIZEOF-1)(a6),a6	;june22;s_SIZEOF(a6),a6
 ENDM

rsnybble:	  MACRO
	rset_addrbit
	rset_addrbit
	rset_addrbit
	rset_addrbit
 ENDM

set_dithbit:	MACRO
	;move.B  (a1)+,(a6)		;dither value.b FROM table INTO savearray
	move.b	d7,(a6)+		;s_PlotFlag(a6)
	move.B	(a1)+,(a6)		;june22;(a1)+,s_DitherThresh-s_PlotFlag(a6)

	clr.b	(a6)			;test only dither fix

	add.l	d0,a6			;june;lea s_SIZEOF(a6),a6
 ENDM

setdbyte:	MACRO
	move.l	A0,a1			;re-setup threshold ptr
	set_dithbit
	set_dithbit
	set_dithbit
	set_dithbit

	set_dithbit
	set_dithbit
	set_dithbit
	set_dithbit
 ENDM

setonebrushbit:	MACRO	;code size 10bytes
	;JUNE061990;roxl.W	#1,d1	;our databit -> eXtend bit (and carry bit, also) 6+2=8 cy
	addx.W	d1,d1	;our databit -> eXtend bit (and carry bit, also) ;4 cy
	scs	(a6)	;true if brush bit, else zero (17cy vs. 21prev)
	add.l	d2,a6	;lea	s_SIZEOF(a6),a6
 endm

set4bits:	MACRO	;code size 40 bytes
	setonebrushbit
	setonebrushbit
	setonebrushbit
	setonebrushbit
 endm


;setone2brushbit:	MACRO	;code size 10bytes
;	;roxl.W	#1,d1	;our databit -> eXtend bit (and carry bit, also)
;	addx.W	d1,d1	;our databit -> eXtend bit (and carry bit, also)
;	scs	(a6)	;true if brush bit, else zero (17cy vs. 21prev)
;	add.l	d2,a6	;lea	s_SIZEOF(a6),a6
;	scs	(a6)	;true if brush bit, else zero (17cy vs. 21prev)
;	add.l	d2,a6	;lea	s_SIZEOF(a6),a6
;  endm
;JUNE061990

setone2brushbit:	MACRO	;code size 10bytes
	;roxl.W	#1,d1	;our databit -> eXtend bit (and carry bit, also)
	addx.W	d1,d1	;our databit -> eXtend bit (and carry bit, also)
	scs	(a6)	;true if brush bit, else zero (17cy vs. 21prev)
	;add.l	d2,a6	;lea	s_SIZEOF(a6),a6 8 CYCLES
	;scs	(a6)	;true if brush bit, else zero (17cy vs. 21prev) 12 cy
			;total WAS 8+12=20 cycles
	scs	0(a6,d3.w)	;total is now 18 cyles
	add.l	d2,a6	;(now =2*s_SIZEOF) ...;lea	s_SIZEOF(a6),a6
 endm

set4doublebits:	MACRO	;code size 40 bytes
	setone2brushbit
	setone2brushbit
	setone2brushbit
	setone2brushbit
 endm

dither_dx_l2s:	MACRO	;dreg {long register d0 or d2, WordINT.FRACword}
	;ADD.L	#(3<<(16-6))!(%111111),\1	;add 'constant' to # b4 subtr dither (=dither-4)

	;SUB.L	d4,\1	;(how novel!);ADD.L	d4,\1
; DitherRemove test only	ADD.L	d4,\1	;digipaint pi...add +/- 1/2 dither value
; DitherRemove test only	bpl.s	nddx\@	;not 0 (or negative)
; DitherRemove test only	moveq	#0,\1

nddx\@:	swap	\1

	cmp.w	#$0040,\1
	bcs.s	ndok\@
	moveq	#$3f,\1	;.w	#$000f,\1
ndok\@

	ENDM		;dither_dx_l2s



do_add:	MACRO	;color	(d2=#15)
	IFC '\1','red'
	move.b	(a6),d1
	add.b	(a1),d1 ;s_Paint\1(a6),d1	;add paint color
	ENDC
	IFNC '\1','red'
	move.b	s_\1(a6),d1
	add.b	s_\1(a1),d1 ;s_Paint\1(a6),d1	;add paint color
	ENDC
	bcc.s	do_add_end\@	;new color <= 255 is ok
	move.B	d2,d1	;q #15,d1
do_add_end\@:
	;17NOV91;move.b	d1,s_Paint\1(a6)
	move.b	d1,s_\1(a1)
 ENDM


do_sub:	MACRO	;color
	IFC '\1','red'
	move.b	(a6),d1
	sub.b	(a1),d1 ;s_Paint\1(a6),d1	;subtract paint color
	ENDC
	IFNC '\1','red'
	move.b	s_\1(a6),d1
	sub.b	s_\1(a1),d1 ;s_Paint\1(a6),d1	;subtract paint color
	ENDC
	bcc.s do_sub_end\@	;new color >= 0 is ok
	moveq	#0,d1
do_sub_end\@:
	;move.b	d1,s_Paint\1(a6)
	move.b	d1,s_\1(a1)
	ENDM

ditherend:	MACRO	;\1=color
	move.b	s_Paint\1(a6),d2
	swap	d2		;8.16  w.w
	asr.w	#4,d2
	dither_dx_l2s d2
	;2.0;move.b	d2,s_\1(a6)	;is what weir gonna (try to) plot
	move.b	d2,s_\1(a1)	;is what weir gonna (try to) plot
 ENDM

COPY1LOTOHI:	MACRO		;20 code bytes?
		;copy all-at-once-with-no-loops BLOWS A5=BP, From A0, To A1*2
	movem.l	(a0),d2-d5/a2-a5	;8 .long = 32 bytes
	movem.l	d2-d5/a2-a5,s_SIZEOF(a1)
	movem.l	d2-d5/a2-a5,(a1)	;8+8n=72cy
 ENDM	;rts	;copy1lotohi


LOHIINNER:	MACRO		;32 bytes per (?)
	COPY1LOTOHI			;from a0 record to 2 records...a1,a1*2
	lea	-2*s_SIZEOF(a1),a1	;doubling...backup destination
	ADD.L	d0,a0 ;lea	-s_SIZEOF(A0),A0	;source...backup
 ENDM

HITOLOINNER:	MACRO	;record size is 8.5*4(byte->lwords)=32+2=34 bytes
;	moveq.l	#((s_SIZEOF)/2)-1,d0	;db' loop count, rest of record
;to_lores_loop\@:
;	move.w	(a0)+,(a1)+
;	dbf	d0,to_lores_loop\@
;	lea	s_SIZEOF(a0),a0

;following code REQUIRES S_SIZEOF = 32
;copy all-at-once-with-no-loops BLOWS A5=BP
;...average colors between pixels...

  IFC 't','f' ;...it didn't handle the overflow....AUG091990
	move.B	(a0),d2		;red
	add.b	s_SIZEOF(a0),d2
	asr.b	#1,d2
	move.b	d2,(a0)
	move.B	1(a0),d2	;green
	add.b	1+s_SIZEOF(a0),d2
	asr.b	#1,d2
	move.b	d2,1(a0)
	move.B	2(a0),d2	;blue
	add.b	2+s_SIZEOF(a0),d2
	asr.b	#1,d2
	move.b	d2,2(a0)
  ENDC

  IFC 't','f' ;AUG271990....no 'averaging...'
	moveq	#0,d2
	moveq	#0,d3
	move.B	(a0),d2		;red
	move.B	s_SIZEOF(a0),d3
	add.W	d3,d2
	asr.W	#1,d2
	move.b	d2,(a0)

	moveq	#0,d2
	;moveq	#0,d3
	move.B	1(a0),d2		;green
	move.B	1+s_SIZEOF(a0),d3
	add.W	d3,d2
	asr.W	#1,d2
	move.b	d2,1(a0)

	moveq	#0,d2
	moveq	#0,d3
	move.B	2(a0),d2		;blue
	move.B	2+s_SIZEOF(a0),d3
	add.W	d3,d2
	asr.W	#1,d2
	move.b	d2,2(a0)
  ENDC ;AUG271990....no 'averaging...'

	movem.l	(a0)+,d2-d5/a2-a5	;8 .long = 32 bytes  adjusts a0=next
	movem.l	d2-d5/a2-a5,(a1)	;8+8n=72cy
	ADD.L	d0,a1 			;lea	32(a1),a1		;8 cy    point to very next record
	ADD.L	d0,a0 			;lea	s_SIZEOF(a0),a0		; skip a record
	ENDM


fixbrite:	macro
	add.l	d2,d2			;kludge for 2*briteness allowance
;BUGFIX june24 for "colors getting darker"
;only do this if "solid blend"....
	cmp.w	#$ff00,Pot0Temp_(BP)
	bcs.s	noincr\@
	;;cmp.w	#$ffff,Pot1Temp_(BP)
	;;bne.s	noincr\@

	cmp.l	#$10000,d2		;<1 already?
	bcs.s	noincr\@		;...yep

	;addq.w	#1,d2			;add '1' to final 8 bit value of each r,g,b
	;add.L	#$8000,d2		;just add .5 (8 bit integer, + this, corrects?)
	;add.L	#$c000,d2		;just add .75 (8 bit integer, + this, corrects?)
	;add.L	#$ffff,d2		;just add .99 (8 bit integer, + this, corrects?)
	ADD.L	#$10000,d2		;add 1  (NOTICE! color #1 might be gone...)
noincr\@:
	cmp.l	d5,d2			;#$ffFFff,d2	;1.99999
	bcs.s	fb\@
	move.l	d5,d2			;#$ffFFff,d2
fb\@:
   endm


;FINAL MOVE s_Paint(color) to s_(color)(a6)
; D2="RatioA" with 15 bit fraction, d5=RatioB with 15 bit frac
shade24_color:	MACRO	;macro used by 'range' and 'clr' paint types
 ifc '\1','red'
	moveq	#0,d0
	moveq	#0,d1
	move.b	(a1),d0			;s_Paintred(a6),d0
	move.b	(a6),d1			;s_red(a6),d1
	mulu	d2,d0			;ratioa, 15 bit fraction
	mulu	d5,d1			;ratiob, 15 bit fraction
	add.L	d1,d0
	ADD.L	d0,d0			;<<1, since 15 bit fractions in d2,d5
	swap	d0
	move.b	d0,(a6) ;s_\1(a6)	;s_red	;is what weir gonna (try to) plot
			MEXIT		;ENDM
  endc ;'red'
	moveq	#0,d0
	moveq	#0,d1
	move.b	s_\1(a1),d0		;s_Paint\1(a6),d0
	move.b	s_\1(a6),d1		;s_red(a6),d1
	mulu	d2,d0			;ratioa, 15 bit fraction
	mulu	d5,d1			;ratiob, 15 bit fraction
	add.L	d1,d0
	ADD.L	d0,d0			;<<1, since 15 bit fractions in d2,d5
	swap	d0
	move.b	d0,s_\1(a6)		;s_red	;is what weir gonna (try to) plot
 ENDM


SkipScroll:	;scroll hires screen down if needed
		;digipaint pi...code also in 'hide tool window'
		;scroll big picture 'down' if bottom//below is 'gonna show'
	;;tst.b	FlagNeedRepaint_(BP)
	;;bne.s	dosnap			;DONT 'jump down' if painting

	;Paint PI;tst.b	FlagToolWindow_(BP)
	;bne.s	dosnap			;DONT 'scroll jump down' if tools shown
	;no need;move.l	IntuitionLibrary_(BP),a6	;library base

	move.l	FirstScreen_(BP),d0	;ib_FirstScreen(a6),d0
	cmp.l	XTScreenPtr_(BP),d0	;hires tools
	beq.s	dosnap			;DON't scroll jump if hires tools in front

 xdef ForceSkipScroll	;xdef'd for screenmoves....SEP071990	
ForceSkipScroll:	;xdef'd for screenmoves....SEP071990	
	move.l	ScreenPtr_(BP),d1	;d1='real' screenptr
	beq.s	dosnap
	move.l	d1,a2			;a2=screen
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	move.w	ri_RyOffset(a1),d1	;d1=current y offset
	add.w	sc_Height(a2),d1
	sub.w	BigPicHt_(BP),d1
	beq.s	dosnap
	bcs.s	dosnap
	sub.w	d1,ri_RyOffset(a1)	;current y offset
	moveq	#0,d0
	CALLIB	Graphics,ScrollVPort
	;LATEMAY1990;st	FlagNeedMakeScr_(BP)	;need MakeScreen (showpaste could, too)
	st	FlagNeedIntFix_(BP)	;need RethinkDisplay
	xjsr	FixInterLace 		;main.key.i ;help out intuition, as needed... (DESTROYS d0/d1/a0/a1/a6)
	rts	;SkipScroll
dosnap:
	xjsr	SnapScroll		;main.key.i
	xjmp	FixInterLace 		;main.key.i ;help out intuition, as needed... (DESTROYS d0/d1/a0/a1/a6)
	;rts	;SkipScroll


SayWait:	;justa subr, used only "here" (MUST end w/checkcancel)
	bsr	SkipScroll		;scroll hires screen down if needed
	st	FlagNeedHiresAct_(BP)	;before checkcancel call
	bsr.s	_CheckCancel		;dumpmoves, return cancel status
	bne.s	ea_saywait		;outta here w/no activate...cancel msg waiting

	xjsr	ReallyActivate		;main (stops mousemoves apro')

	xjsr	SetPointerWait		;'other' waitptr, flood, then reg

;checkcancel to dump current moves before first line
;ok to 'not do anything' with returned code...
;...(it'll come back again)
;fix bug: hang when startpick while drawing/repainting

	bsr.s	_CheckCancel		;dumpmoves, return cancel status
	bne.s	ea_saywait		;outta here w/no activate...cancel msg waiting

	xjsr	ResetIDCMP		;removes mousemoves from hires
;SEP091990;ELIMINATE PROP FLASHING IN RANGE MODE?;
	cmp.b	#7,EffectNumber_(BP)
	beq.s	_CheckCancel
	xjsr	ReDoHires		;tool.code.i, also does 'unshowpaste' may01
_CheckCancel:
	xjmp	CheckCancel		;dumpmoves, return cancel status
ea_saywait:
	rts

Effect_RePaint:	;entry for brushfx (rotates)
	sf	FlagAgain_(BP)
	bsr.s	SayWait			;force pointer="wait"
	bra	nostartcancel		;june271990...cont_start	*go do real work

RePaint:
	xjsr	sayRepaint
	xjsr	MakeStroke8Bits
	tst.b	FlagSetGrid_(BP)	;grid size setup?
	bne.s	endgrid
	tst.b	FlagSetAir_(BP)		;airbrush setup?
	bne.s	endair

	bsr	SayWait			;force pointer="wait"
	bne.s	dontpaint
	tst.l	FlagCirc_(BP)		;any modes?
	beq.s	98$			;nope
	st	FlagRepainting_(BP)	;dospecial completes shape if this flag
	st	FlagMaskOnly_(BP) 	;force next rtn to happen, no cancel
	xjsr	DoSpecialMode		;drawbrush.o,drawb.mode.i
	xjsr	KillLineList		;drawb.mode.i ;removes 'current shape'
98$:					;no spec'mode like circle, rectangle...
	sf	FlagMaskOnly_(BP)	;moved to always occur
	tst.b	FlagXSpe_(BP)		;dont skip shading h/v savearray record fill?
	beq.s	99$
	xjsr	CopySuperScreen		;quick "undo"
99$
	tst.b	FlagFillMode_(BP)	;repaint (NOT again) for new fill?
	bne.s	RePaint_Picture		;(digipaint pi)

Again:	moveq	#-1,d0			;value for flagagain, AGAIN gadget rtn
	bra.s	agst			;'again start'


RePaint_Picture:			;screen='dirty' and UnDoBitMap='clean'
	moveq	#0,d0			;valu for 'flagagain'
agst:	move.b	d0,FlagAgain_(BP)
	clr.L	line_offset_(BP)	;NEED IN CASE ABORT
	bsr	SayWait			;force pointer="wait"
	beq.s	nostartcancel		*go do the real work

endair:		;DigiPaint PI
	sf	FlagSetAir_(BP)
	move.w	ElliXRadius_(BP),d0	;as if rectangle, x width (c/be 0)
	move.w	d0,AirHalfWidth_(BP)
	add.w	d0,d0
	addq.w	#1,d0
	move.w	d0,AirWidth_(BP)
	move.w	ElliYRadius_(BP),d0	;as if rectangle, x width (c/be 0)
	move.w	d0,AirHalfHeight_(BP)
	add.w	d0,d0
	addq.w	#1,d0
	move.w	d0,AirHeight_(BP)
	bra.s	endup

endgrid:	;DigiPaint PI
	sf	FlagSetGrid_(BP)	;DigiPaint PI
endup:
	xjsr	ResetPointer		;pointer/brush fixup?
dontpaint:	;because 'cancel'd with a button in the input msg stream
	xjsr	MarkedUnDo		;JUNE02...
	;nothing to undo, no putrgbs happened yet...;xjsr	UnDoRGB		;ensure rgb buffers "undone"....SEP121990 (??)
	sf	FlagBitMapSaved_(BP)	;=-1 if 'undo' saved but not restored (?)
	sf	FlagNeedRepaint_(BP)	;we coulda cancel'd
	sf	FlagRepainting_(BP)	;right *now* we're not 'repaint'ing
	sf	FlagAgain_(BP)
	rts	;abort'd repaint



nostartcancel:
	tst.b	FlagText_(BP)		;AUG261990
	bne.s	123$

	xjsr	SaveUnDo 		;memories.o;screenbitmap => UnDoBitMap ONLY IF NEEDED
	xjsr	SaveUnDoRGB		;rgbrtns.asm, copy 24 bit buffers....
123$:
;cont_start:
	st	FlagRepainting_(BP)
	clr.w	line_y_(BP)
	clr.L	line_offset_(BP)	;NEED IN CASE ABORT

	tst.b	FlagAgain_(BP)		;redo//again (not penup) (for fill mode?)
	bne	1$			;yep...don't re-flood
	xjsr	DoColorFlood		;newflood.asm, digipaint pi
	xjsr	ScrollAndCheckCancel	;AUG271990
	bne.s	2$			;AUG271990
1$	xjsr	StrokeBounds		;determine bounds of brush stroke
;;;d0=xmin d1=ymin d2=xmax d3=ymax d4=width d5=height d6=-1 if empty
	;bmi	cancel_repaint		;-->ABORT, nothing in brush bitmap
	bpl.s	have_a_mask
2$	st	FlagDisplayBeep_(BP)	;BEEP! in main loop
	bra	cancel_repaint		;-->ABORT, nothing in brush bitmap


have_a_mask:
	asl.L	#4,d4			;<<4 for stretching purposes...
	move.w	d4,halfpaint_width_(BP)	;*only* used by Vstretch...;SEP201990;
	asr.L	#4,d4

	clr.w	v_extraleft_(BP)	;SEP201990

	cmp.w	#32,d0			;already "at/near" leftedge?  june2490
	xref FlagBump32_		;june2690
	scc	FlagBump32_(BP)		;*only* used here, and just before LinePlot
	bcs.s	001$
	sub.w	#32,d0			;extra 32 pixels on leftedge
	add.w	#32,d4			;bump width, too
	move.w	#32,v_extraleft_(BP)	;SEP201990...= #pixels to skip on leftside...
001$
	movem.w d0/d1/d4/d5,LastRepaintX_(BP) ;X,Y,Width,Ht, for UndoRGB

;no "last repaint ht" if this is a BRUSH effect...AUG191990
	tst.l	PasteBitMap_Planes_(BP)	;ham brush?
	beq.s	ok_nobrush_eff
	cmp.b	#3,EffectNumber_(BP)	;mirror flip horizontal
	beq.s	no_lastrepaintht
	cmp.b	#4,EffectNumber_(BP)	;rotate plus
	beq.s	no_lastrepaintht
	cmp.b	#5,EffectNumber_(BP)	;rotate minus
	;beq.s	no_lastrepaintht
	bne.s	ok_nobrush_eff
no_lastrepaintht:
	xref LastRepaintHt_		;used mainly by UnDoComp in composite.asm
	clr.w	LastRepaintHt_(BP)
ok_nobrush_eff:
	st	FlagFirstLine_(BP)	;used by anti-alias (doeffect.o)
	;xref paint_width_		;greatest paint width (strokebounds result)
	;xref halfpaint_width_
	move.w	d4,paint_width_(BP)	;greatest paint width (strokebounds result)

;for VStretch (vertical stretching)
	move.w	d0,-(sp)
	and.w	#(32-1),d0		;left offset to 1st painted pixel
	;move.w	d0,v_extraleft_(BP)
	ADD.w	d0,v_extraleft_(BP)	;SEP201990
	move.w	(sp)+,d0

	move.w  d1,first_line_y_(BP)
	move.w  d1,line_y_(BP)		;LINE_Y_ represents current working y
	move.w  d3,last_line_y_(BP)
	
	addq.w	#4,d2			;adjust d2=ending x, accounts for (4) potential cleanups
	cmp.w	BigPicWt_W_(BP),d2
	bcs.s	winbounds
	move.w	BigPicWt_W_(BP),d2
	subq.w	#1,d2

winbounds:
	asr.w	#5,d0			;startx/32= D0=paint start long word #
	asr.w	#5,d2			;ditto for endx
	sub.w	d0,d2	
	move.w	d2,plwords_row_less1_(BP)	;paint longwords less1

	addq.w	#1,d2
	add.w	d2,d2	;longwords->words
	subq.w	#1,d2
	move.w	d2,pwords_row_less1_(BP)	;paint wordsperrow less1 JUNE

	addq.w	#1,d2
	asl.w	#4,d2	;*16 words->pixels
	subq.w	#1,d2
	move.w	d2,ppix_row_less1_(BP)		;paint pixelsperrow less1

	asl.w	#2,d0			;<<2= D0=offset to 1st byte on line 
	move.w	d0,col_offset_(BP)	;image offset, on current line to bit

	mulu	bytes_per_row_W_(BP),d1	;d1 already=first line y
	move.L  d1,line_offset_(BP)	;cur't work'g offset into bitplane

	add.L	d0,d1	;+byte//column offset
	move.L	d1,linecol_offset_(BP)

*NOTE: variable 'linecol_offset' used by 'doeffect-mirror' to find/flip mask

	asl.w	#3,d0			;<<3=*8=#pixels
	move.w	d0,SAStartX_(BP)	;starting 'x' value (line_y_ is 'y' analog) ;MAY90
	ext.L	d0
	asl.L	#5,d0	;*32;mulu	#s_SIZEOF,d0
	lea	SaveArray_(BP),a6
	add.l	d0,a6			;JUNE;lea	0(a6,d0.l),a6
	move.l	a6,SAStartRecord_(BP)	;1st pixel's "record" inside savearray

;hide the tool window, so we can see bottom of 'repaint area'
	move.l	TScreenPtr_(BP),d0
	bne.s	1$
	move.l	XTScreenPtr_(BP),d0	;"gotta" be there if drawing
1$	move.l	d0,a0			;ham toolscreen -or- hires
	move.w  sc_TopEdge(A0),D0

;; removed to work with lace ham screen;	tst.b	FlagLace_(BP)
;; removed to work with lace ham screen;	beq.s	notint

	add.W	D0,D0			;yep, double screen topedge since always in non-int
notint:
	move.l	ScreenPtr_(BP),a2	;a2=screen
	
	
	lea	sc_ViewPort(a2),A0	;A0=viewport
	move.l	vp_RasInfo(A0),a1	;a1=rasinfo
	add.w	ri_RyOffset(a1),D0	;Y OFFSET
	cmp.w	d3,D0			;LAST LINE "below" top of tool box?
	bcc.s	skip_ht
	xjsr	CloseToolWindow	;hide it, and set flag to keep tools hidden
	bsr	SkipScroll		;skip/scroll the screen down

skip_ht:
	;FLOOD FILL single bitplane, just once
	tst.b	FlagFlood_(BP)
	beq.s	enda_ff
	tst.b	FlagCutPaste_(BP)	;but NOT in cutpaste mode...(blitter)
	bne.s	enda_ff
	xjsr	DoFlood			;NewFlood.o
	tst.b	FlagDisplayBeep_(BP)
	bne	cancel_repaint		;-->ABORT,...couldn't flood fill
enda_ff:

	move.l	#$B0bB0bD1,random_seed_(BP)	;for same dither every time

	xjsr	ClearSaveArray			;for antialias/doeffect
	move.W	bytes_row_less1_W_(BP),D0
	bsr	InitBitNumSA		;inits s_BitNumber fields in SaveArray


	moveq	#0,D0
	cmp.B	#6,PaintNumber_(BP)	;range paint?
	beq.s	dodo_htcalcs		;if so, need 'shading' parms
	move.b	FlagStretch_(BP),D0
	or.w	FlagHShading_(BP),D0	;h.b AND v.b, test BOTH h&v flags
	beq	endof_height_calcs	;none of these 'modes'

dodo_htcalcs:
	;STARTaLongLOOP A6,d0
	;addq.w	#1,d0			;dbf type looper, #longwords
	;add.w	d0,d0			;*2=#words (=16bits) (shorter code within loop)
	;subq.w	#1,d0			;still, a db' type loop index
	STARTaWordLOOP A6,d0
	lea	s_VerPixel(a6),a6
	moveq	#0,d1
	moveq.l	#s_SIZEOF,d2		;'ivp' macro needs this

init_VerP_loop:	;inits s_VerPixel(savearray) as "#pixels in the COLUMN"
	ivp8
	ivp8
	dbf	D0,init_VerP_loop	;1 word, 16 pixels per iteration

	move.l	BB1Ptr_(BP),A0
	moveq	#0,d2			;clear upper bits, we use it as a byte...

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray

	moveq	#0,d1			;plane offset, starting
	move.w	col_offset_(BP),d1
	add.L	line_offset_(BP),d1	;offset this starting line in plane

	move.w	last_line_y_(BP),d4
	sub.w	first_line_y_(BP),d4
	;addq	#1,d4 ;=#lines to scan
	;subq	#1,d4 ;for db' type loop
	;paint pi...be accurate!	;asr.w	#3,d4	;/8, count up 8 lines per loop (could overrun bitmap!)
	move.w	d4,-(sp)		;loop ctr for inner loop (cvloop)
	moveq	#0,d6
	move.w	bytes_per_row_W_(BP),d6	;increments to next line in bitmap
	move.W	ppix_row_less1_(BP),d0	;pixels_row_less1_W_(BP),D0	;count for next loop

init_MaxVerP_loop:
	move.L  d1,d3	;plane offset
	move.b  s_BitNumber(a6),d2	;D2 = WORKING BIT# in byte in bitplane
;no need MAY90;	bne.s	1$
;no need MAY90;	addq.w  #1,d1		;incr. starting plane address
;no need MAY90;1$:
;ABSOLUTELY REQUIRED...any "vertical shading" BREAKS without this...
	bne.s	1$
	addq.w  #1,d1			;incr. starting plane address
1$:
	move.w	(sp),d4			;db' type loop ctr, ht=#lines to paint//scan
	CLR.W	D5			;only saved word!

cvloop:
	btst.b  d2,0(A0,d3.L)
	beq.s	cvnope
	addq.w  #1,d5			;s_MaxVerPixel(a6)
cvnope	add.L	d6,d3			;.w bytes_per_row_W_(BP),d3	;#40,d3
	dbf	d4,cvloop		;1 longword, 32 pixels per iteration

	ADDQ.W	#1,d5			;maxverpixel var really is 1 wider...
	move.w	d5,s_MaxVerPixel(a6)
	lea	s_SIZEOF(a6),a6

	dbf	D0,init_MaxVerP_loop

	lea	2(sp),sp		;(d4) ht loop ctr, cvloop


  IFC 't','f'
;LATEOCTOBER'90
;extra loop to smooth vertical shading....eliminate "jitters"
	STARTaLOOP A6,d7
	lea	s_SIZEOF+s_MaxVerPixel(a6),a6
	subq.w	#2,d7			;loop 2 less times...
	bcs.s	no_sjfilt
sj_loop:	;smoothjitter:
	;ALWAYS SMOOTH IT...		;move.w	(a6),d0			;this vertical size...s_MaxVerPixel(a6)
	;move.w	d0,d1			;build d1="filtered" vertical
	;add.w	d1,d1
	;move.w	2*s_SIZEOF(a6),d1
	;add.w	-2*s_SIZEOF(a6),d1
	;add.w	-2*s_SIZEOF(a6),d1
	move.w	(a6),d1
	add.w	d1,d1
	add.w	-s_SIZEOF(a6),d1
	add.w	-s_SIZEOF(a6),d1
	;add.w	s_SIZEOF(a6),d1
	asr.w	#2,d1
	;asr.w	#3,d1	;/8
	;ALWAYS SMOOTH IT...;cmp.w	d0,d1		;use original if it's larger (go right to edge)
	;ALWAYS SMOOTH IT...;bcs.s	1$
	move.w	d1,(a6)		;...else use filtered (higher) value
1$	lea	s_SIZEOF(a6),a6
	dbf	d7,sj_loop
no_sjfilt:
 ENDC


;determine vertical shading (Array) parameters: (s_fx_{lrtb) fields)
;  WORD s_MaxVerPixel,WORD s_MidPointY top,midpoint pixel # on shading curve
;  WORD s_fx_top,s_f_bottom
	cmp.B	#6,PaintNumber_(BP)	;range paint?
	beq.s	dodo_vscalcs		;if so, need 'shading' parms
	tst.W	FlagHShading_(BP)	;h.b AND v.b horiz&vert, either on?
	beq.s	skip_vshadecomput
dodo_vscalcs:


YMidPoint equr d3
YBotSize equr d4

	STARTaLOOP A6,d7
	lea	s_MaxVerPixel(a6),a6
	moveq	#0,YBotSize	;clear upper word (foll'g code keeps it clear)
compute_VerP_loop:
	move.w	HVShadingPotV,YMidPoint	;midpoint = int.frac = center*MaxBit
	move.w	(a6)+,YBotSize ;s_MaxVerPixel,A6=A6+2
	mulu	YBotSize,YMidPoint
	;ext.l	YBotSize
	add.l	YBotSize,YMidPoint ; make multiply by $FFFF = multiply by ($FFFF+1)
	clr.w	YMidPoint ;12/10move.w	#0,YMidPoint	;clear out "fraction"
	swap	YMidPoint	;useful value in lower 16 bits	;midpoint=maxver*pot/$10000
	move.w	YMidPoint,(a6)+	;save s_YMidPointY	;tst.w  YMidPoint
			; s_fx_top = 1/topsize, s_fx_bottom = 1/bottomsize
	bne.s	1$
	moveq	#0,D0		;topside=0, factor=zero
	bra.s	computed_fx_top
1$:	;move.l	#$0000FFFF,D0	;move.l #imm,dn  12 cycles
	moveq	#0,d0	;4cy
	not.W	d0	;4cy=8cy total, d0=$0000ffff
	divu	YMidPoint,D0	;do=1/topsize
computed_fx_top:
	move.w	D0,(a6)+	;s_fx_top

	sub.w	YMidPoint,YBotSize	;ybot WAS maxver, NOW is bot size
	bne.s	2$
	moveq	#-1,D0
	bra.s	computed_fx_bot
2$:	;move.l	#$0000FFFF,D0	;move.l #imm,dn  12 cycles
	moveq	#0,d0	;4cy
	not.W	d0	;4cy=8cy total, d0=$0000ffff
	divu	YBotSize,D0	;do=1/bottomsize
computed_fx_bot:
	move.w	D0,(a6)	;s_fx_bot ;LAST ONE, DON'T CYCLE FOR A6 PTR INCREMENT
	lea	s_SIZEOF-(2*3)(a6),a6
	dbf d7,compute_VerP_loop

skip_vshadecomput:

endof_height_calcs:

	bsr	InitPaintRtn	;inside paintcode.i
	xjsr	ResetPriority	;'fast' for initial calc...normal for remainder
	st	Flag24_(BP)	;...Flag24 is set at ReadBody, then set/reset after GetRGB

;for each line to be plotted
	;get current line (screen image) into savearray
	;get s_Paint(rgb)(), set to be "paint" color or rubthru image OR EFFECT
	;call PaintCode.i.asm (paint) routine... result to s_Paint(rgb)()
	;    doshad moves s_Paint(rgb)() to s_(rgb)()
	;call QuickDetermine for entire line
	;call LinePlot in order to plot the entire line

	;	;1st time thru, fix up offsets...SEP121990
	;move.l	bytes_per_row_(BP),D0
	;sub.L	D0,line_offset_(BP)
	;sub.L	D0,linecol_offset_(BP)								
	;addq.w  #1,line_y_(BP)
	;bra.s	recheck		;1st time thru, check for cancel...SEP121990
	xjsr	ScrollAndCheckCancel	;canceler.o
	beq.s	check_line_loop
	cmpi.l	#MENUVERIFY,D0		;MENUBUTTON?
	beq	cancel_repaint		;...take new paste off screen
	tst.l	PasteBitMap_Planes_(BP)	;'pasting'?
	bne	cancel_repaint ;1$	;if pasting, DONT cancel with left button

check_line_loop:	;for each line... *** MAIN REPAINT LOOP ***

	bsr	InitPaintPtr		;inside paintcode.i, handle 'realtime' sliders
	bsr	Repaint_Line		;TA DA! we call the MAIN (b)LOOPER here

	sf	FlagFirstLine_(BP)	;used by anti-alias (doeffect.o)

	tst.b	FlagMagnify_(BP)	;is magnify turned on?
	beq.s	enda_21linemag
	move.w	line_y_(BP),d0
	move.w	MagnifyOffsetY_(BP),d1
	cmp.w	d1,d0			;MagnifyOffsetY_(BP),d0
	bcs.s	enda_magflag		;skip mag, before line...
	moveq	#(200/8),d2
	sub.w	d2,d0 			;#lines magnified (det' range)
	bcs.s	do_magflag		;skip mag, before line...
	tst.b	FlagLace_(BP)
	beq.s	magnl			;interlace mode has 2x many mag'lines
	sub.w	d2,d0			;#lines magnified (det' range)
	bcs.s	do_magflag		;skip mag, before line...
magnl:	cmp.w	d1,d0			;MagnifyOffsetY_(BP),d0
	bcc.s	enda_magflag
do_magflag:
	st	FlagNeedMagnify_(BP)	;FORCE/say we WANT a magnify
enda_magflag:
	;JUNE;xjsr	DoMinMagnify		;'blow up' screen (slo-timer'd)
	xjsr	DoMagnify		;'blow up' screen (slo-timer'd) JUNE
enda_21linemag:
recheck:
	xjsr	ScrollAndCheckCancel	;canceler.o
	beq.s	continue_text		;disposed of m'moves need coord display
	cmpi.l	#MENUVERIFY,D0		;MENUBUTTON?
	beq	cancel_repaint		;...take new paste off screen
	tst.l	PasteBitMap_Planes_(BP)	;'pasting'?
	bne	cancel_repaint ;1$	;if pasting, DONT cancel with left button
	cmpi.l	#MOUSEBUTTONS,D0
	beq.s	cancel_chkbutton

	cmpi.l	#CLOSEWINDOW,d0
	bne.s	notcw
	move.l	a0,a1		;CLOSEWINDOW msg ptr
	REMOVEMSG		;gets 'closewindow' OUT of incoming msg stream
	st	FlagCheckKillMag_(BP)
	bra.s	recheck		;note: intuit de-alloc closewin msg when win closed
notcw:
	tst.l	PasteBitMap_Planes_(BP)
	beq.s	notcpcan
	move.l	A0,-(sp)		;STACK save msgptr
	move.l	A0,a1
	REMOVEMSG			;'getmsg' of 'not first in list'
	move.l	(sp)+,a1		;deSTACK mousemove
	CALLIB	Exec,ReplyMsg		;rtnmsg
	st	FlagNeedHiresAct_(BP)	;'asks' mainloop for hires window activate
notcpcan:

	bra.s	cancel_repaint		;spacebar from 'checkcancel'

continue_text:
	;june;xjsr	DisplayText
	xjsr	DoMinDisplayText	;june

;continue_repaint:			;check if done with all the lines
	;moveq	#0,D0			;clears upper word
	;move.w	bytes_per_row_W_(BP),D0
	move.l	bytes_per_row_(BP),D0
	add.L	D0,line_offset_(BP)
	add.L	D0,linecol_offset_(BP)								

	move.w  line_y_(BP),D0
	cmp.w	last_line_y_(BP),D0	;last could be=1st
	beq.s	end_repaint		;checkend before incr
	addq.w  #1,D0
	move.w  D0,line_y_(BP)
	bra	check_line_loop	;REPAINT LINE, LOOP AGAIN

cancel_chkbutton:		;definitely leaving, select 'undo' (if any)
;fixes guru when 'pick color hamtools' while repaint
	move.l	im_IDCMPWindow(a0),d0	;"window of message"
	beq.s	cancel_repaint		;no window?
	cmp.l	WindowPtr_(BP),d0	;from bigpic?
	beq.s	paintwindow_cancel	;yep...continue 'normal' ckcancel end
	cmp.l	MWindowPtr_(BP),d0	;from bigpic?
	bne.s	cancel_repaint

paintwindow_cancel:
	move.w  im_Code(A0),D0
	cmpi.w  #MenuDown,D0
	beq.s	cancel_repaint

;some other button (left button), outta here with no ptr reset
	move.b	FlagRepainting_(BP),FlagNeedRepaint_(BP) ;we coulda cancel'd
;AUG201990;bra.s	contend_rp
;AUG201990......rgb mode, start painting again while redrawing
	tst.l	PasteBitMap_Planes_(BP)		;"pasting"?
	bne.s	contend_rp
	xjsr	UnDoRGB		;help out, lots....
	bra.s	contend_rp
	;rts			;END OF REPAINT, with a button down

cancel_repaint:
;if "low memory" - no cutpaste undo, then remove ENTIRE image
	tst.l	PasteBitMap_Planes_(BP)		;"pasting"?
	beq.s	8$

	tst.l	CPUnDoBitMap_Planes_(BP)	;pasting, but have cpundo?
	bne.s	8$				;yup, continue...nothing special
	st	FlagNeedHiresAct_(BP)
	xjsr	ReallyActivate			;main (stops mousemoves apro')
	xjsr	CopySuperScreen
	bra.s	cont_pastend
8$:
	move.L	line_offset_(BP),D0		;arg for partialunddo
	xjsr	PartialUnDo			;memories.o ;D0=lineoffset a5=Base
	;no...;xjsr	UnDoRGB			;ensure rgb buffers "undone"....SEP121990 (??)

end_repaint:
	sf	FlagNeedRepaint_(BP)		;we coulda cancel'd
	sf	FlagBitMapSaved_(BP)		;=-1 if 'undo' saved but not restored (?)

contend_rp:	
		;MAY14
	tst.l	PasteBitMap_Planes_(BP)		;"pasting"?
	beq.s	after_rtnm

	st	FlagNeedHiresAct_(BP)
	xjsr	ReallyActivate		;main (stops mousemoves apro'

cont_pastend:
	move.l	WindowPtr_(BP),a0	;bigpic
	xjsr	ReturnMessages	;a0=windowptr  (destroys d0/d1/a1)
;scans the 'input message list' and ReplyMsg's all
;the msgs for window a0 (for use just before CloseWindow)
	move.l	MWindowPtr_(BP),d0	;magnify window
	beq.s	after_rtnm
	move.l	d0,a0
	xjsr	ReturnMessages	;a0=windowptr  (destroys d0/d1/a1)

after_rtnm:
	sf	FlagRepainting_(BP)	;right *now* we're not 'repaint'ing
	sf	FlagAgain_(BP)

	;move.w	#2,MaxTick_(BP)	;using '2', ALWAYS as min. retick for brush, etc
	move.w	#3,MaxTick_(BP)	;using '2', ALWAYS as min. retick for brush, etc

	tst.b	FlagCutPaste_(BP)
	beq.s	95$

	cmp.b	#6,EffectNumber_(BP)	;6=perspective
	bcc.s	94$			;want if range paint
	;cmp.b	#7,EffectNumber_(BP)	;7=range paint? digipaint pi
	;beq.s	94$			;want if range paint
	cmp.b	#3,EffectNumber_(BP)
	bcc.s	95$			;skip if flip horiz, rot+, rot-
94$	xjsr	CopyScreenSuper
95$

;;	;AUG061990....kludge for fixing "flip horizontal"
;;	cmp.b	#3,EffectNumber_(BP)	;(brush) flip x?
;;	bne.s	97$
;;	xjsr	UnDoRGB		;help!
;;97$
;handle "always render" mode....AUG011990

	;xref	SolLineTable_
	;tst.l	SolLineTable_(BP)	;any lines to be rendered?
	;beq.s	norender
	xref FlagAlwaysRender_
	tst.b	FlagAlwaysRender_(BP)
	beq.s	norender
	xref	ActionCode_
	move.l	#'Vwco',ActionCode_(BP)	;view composite action code
norender:
	rts	;END OF REPAINT

*****
InitBitNumSA:	;SaveArray, inits s_BitNumber fields (D0=#pixels/row - 1)
	;lea	SaveArray_(BP),A0
	;lea	s_BitNumber(A0),A0
	lea	s_BitNumber+SaveArray_(BP),A0	;JUNE

	moveq #7,d7
	moveq #6,d6	;here i init' the 'bit number in a byte'
	moveq #5,d5	;...fields (for Bset/clr purposes later...)
	moveq #4,d4
	moveq #3,d3
	moveq #2,d2
	moveq #1,d1
	;subq	#1,D0	;db' type loop, CALLED with arg d0 already set for loop
init_BitN_loop:
	move.b  d7,(A0)
	move.b  d6,((7-6)*s_SIZEOF)(A0)
	move.b  d5,((7-5)*s_SIZEOF)(A0)
	move.b  d4,((7-4)*s_SIZEOF)(A0)
	move.b  d3,((7-3)*s_SIZEOF)(A0)
	move.b  d2,((7-2)*s_SIZEOF)(A0)
	move.b  d1,((7-1)*s_SIZEOF)(A0)
	;clr.b	((7-0)*s_SIZEOF)(A0)
	sf	((7-0)*s_SIZEOF)(A0)	;"sf" is better'n clr.b on a 68000
	lea	(8*s_SIZEOF)(A0),A0
	dbf D0,init_BitN_loop
	rts
*****
Repaint_Line:	;SUBROUTINE, happens once for each line

	sf	FlagWorkHires_(BP)	;savearray in lores format, to start
		;THIS FLAG IS SET INSIDE OF 'GENGETGRB' in RGBRtns.asm

	;eventually....bsr	DitherSetup	;1st LOOP sets ditherthreshold,planeadr in each savearray record
DitherSetup:	;1st LOOP sets ditherthreshold,planeadr in each savearray record
	STARTaWordLOOP A6,d4
	addq.w	#1,d4	;dbf type looper, #longwords
	add.w	d4,d4	;*2=#bytes (shorter code within loop)
	subq.w	#1,d4	;still, a db' type loop index
	moveq	#0,d7	;plotflag

	;"latest"
	cmp.b	#8,EffectNumber_(BP)	;#8=blur2
	beq.s	1$
	cmp.b	#4,EffectNumber_(BP)	;#4=rotate+90, effect#5=-90
	bcs.s	1$
	cmp.b	#6,EffectNumber_(BP)	;6=perspective
	bcc.s	1$
	;cmp.b	#7,EffectNumber_(BP)	;#7=RANGE
	;beq.s	1$
	moveq	#-1,d7	;SET PLOTFLAG if rotate types...causes "redetermine"
1$
	lea	s_PlotFlag(a6),a6

 ifeq 1
	tst.b	FlagDitherRandom_(BP)
	bne.s	setup_randomd		;do random dither setup
	tst.b	FlagDither_(BP)
	bne	setup_matrixd		;do matrix dither setup
;setup_nodither:	;SETUP DITHER THRESH for 'no' dither (none)
	;move.w	#(63-LOWERDITHER),d6	;correct value, comes out zero for 'uncorrect'
	;june---doesnt work...?;
	moveq	#0,d6	;default dither threshold (gets subtracted)
set_addrbit:	MACRO	;(10codebytes?)
	move.b	d7,(a6)+	;s_PlotFlag(a6)
	move.b	d6,(a6)		;june22;d6,s_DitherThresh-s_PlotFlag(a6)
	lea	(s_SIZEOF-1)(a6),a6	;june22;s_SIZEOF(a6),a6
	ENDM
setadrbyte:	MACRO	;(80codebytes?)
	set_addrbit
	set_addrbit
	set_addrbit
	set_addrbit
	set_addrbit
	set_addrbit
	set_addrbit
	set_addrbit
	;WO?;addq.l	#1,d3
	ENDM
set_addrlwloop:	;this loop sets all the dith'thresholds to #63
	setadrbyte
	dbf	d4,set_addrlwloop
	bra	enda_dithsup	;end of (none,matrix,random) dither setup
setup_randomd:	;SETUP RANDOM DITHER
  IFC 't','f' ;....using new "static random dither" stuff...
;		;macro codesize 8bytes
;nxtrandom:	MACRO	;d-register,  (using d5 as subst for random_seed)
;	MOVE.W	d5,\1	;compute next random seed (longword)
;	LSR.W	#1,\1
;	BCC.s	norflip\@
;	EOR.W	d1,\1	;#$B400,\1	;algo ref: Dr. Dobb's Nov86 pg 50,55
;norflip\@:
;	MOVE.W	\1,d5	;random_seed_(BP)
;		;JUNE
;	and.W	d0,\1	;i.b #$3f,d6		;.byte of randumbness
;	subq	#LOWERDITHER,\1
;	bcc.s	nxrok\@
;	moveq	#0,\1
;nxrok\@:
;		ENDM
  ENDC
	;move.w	#$3f,d0		;mask for requ'd random bits
	;move.w	#$B400,d1	;algo ref: Dr. Dobb's Nov86 pg 50,55
	;MOVE.W	random_seed_(BP),d5	;d5 is subst for random_seed in macro
*
	move.w	LastRepaintX_(BP),d0	;x column (another variable is available?)
	and.w	#~(32-1),d0	;round to nearest(leftside) longword
	move.w	line_y_(BP),d1
	xjsr	GimmeDither	;d0/1=x/y.w returns a0=table, d0=constant
	addq	#1,d4	;=bytesperrow (to repaint)
	add.w	d4,d4	;=nybblesperrow
	subq	#1,d4	;db' type loop counter
rset_lwloop:
	rsnybble	;4bits
	dbf	d4,rset_lwloop
	;not for static;MOVE.W	d5,random_seed_(BP)	;d5 is subst for random_seed in macro
	bra.s	enda_dithsup	;end of (none,matrix,random) dither setup
setup_matrixd:	;SETUP MATRIX DITHER
	move.w	line_y_(BP),d0
	andi.w	#7,d0		;use line # mod 8
	asl.w	#3,d0		;*8
	lea	ThresholdTable(pc),A0
	lea	0(A0,d0.w),A0	;reset to this 'start of a line of 8 byte values'
	move.L	#(s_SIZEOF-1),d0	;june22;#s_SIZEOF,d0	;june
sdithlwloop:
	setdbyte
	;setdbyte
	;setdbyte
	;setdbyte
	dbf	d4,sdithlwloop
enda_dithsup:
 endc	;remove all dithering



;WORKS TO HERE;  RTS ;KLUDGEOUT EARLY END TO REPAINT_LINE
	;LOOP DE-PLOT a ham line into SaveArray given:
	clr.W	-(sp)		;STACK!!! used in next 'flagged twice' loop

	tst.l	Datared_(BP)	;june031990
	bne	do24bitcolor

	move.l	linecol_offset_(BP),d1
	STARTaLOOP A6,d0
	addq.w	#1,d0			;=#pixels
	lea	s_LastPlot(a6),a6
;	xjsr	UnPlot_SaveArray	;get image bits into savearray
		;SEP91..."auto" scroll the screen more often
		;SEP91...repaint calls "PutRGB" before a other time consuming things...
;	xjsr	SimplyScroll		;"auto" scroll the screen   ;SEP91

;OK TO HERE;  lea 2(sp),sp ;KLUDGE,TEst....work?
;OK TO HERE;  RTS ;KLUDGEOUT EARLY END TO REPAINT_LINE ** CRASHES BEFORE HERE...

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one DBF'er
	lea	UnDoBitMap_(BP),a3	;pull colors from undo
	move.w	col_offset_(BP),d0	;image offset, on current line to bit
	asl.w	#3,d0			;='x'

	;;;;bsr	GetHamColors	;a3=bitmap, d3=counter-1

;;GetHamColors:	;a3=bitmap, d3=counter-1
get_save_colors:		;a3=bitmap, d3=counter-1
		;get rgb for 1st pixel (wether painted or not)
	move.w	line_y_(BP),d1
get_save_colors_haveY:
	lea	bm_Planes(a3),a3
	move.l	d3,-(sp)		;#pixels-1 (diff for cutpaste)

;left edge sup
	subq.w	#1,d0
	bpl.s	1$
	move.l	LongColorTable_(BP),d0	;WE REALLY *SHOULD* 'getold' rgb
	clr.B	d0
	move.l	d0,Predold_(BP) ;left edge starting clrs
	bra.s	2$
1$
	;xjsr	QuickGetOldBM		;d0,1 = x,y WATCH a3=BITPLANE PTRs
;WO!SATURDAYMAY13'1990;;move.l	-8(a3),a3		;bitmap ptr
	lea.l	-bm_Planes(a3),a3		;bitmap ptr
	xjsr	GetOldfromBitMap	;find the P(rgb)old at this point
2$	move.l	(sp)+,d3
	
	;move.l	Predold_(BP),-s_SIZEOF(a6)	;4 bit
	;AHA....glitchie blackness on left side....
	move.l	Predold_(BP),d0
	asl.l	#4,d0		;make leftside colors be 8 bits...
	move.B	LastPlot_(BP),d0
	move.l	d0,-s_SIZEOF(a6)

	lea	LongColorTable_(BP),a2
	;move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one DBF'er
	;digipaint24....get 24bit values, not ham screen...
	tst.l	Datared_(BP)
	beq.s	get_savearray_loop

	;pea	ScreenBitMap_Planes_(BP)	;calc adr of screen bitplanes
	pea	UnDoBitMap_Planes_(BP)	;calc adr of screen(undo//src) bitplanes
	cmp.l	(sp)+,a3			;are we doing screen?
	bne.s	get_savearray_loop		;no...continue unpack...

do24bitcolor:	
	bsr	EnsureWorkHires		;JULY171990

	;24 bit mode...get rgbs from 'rgb arrays' instead of bitmap
	;tst.b	Flag24_(BP)
	;beq.s	skipgetrgbs
	movem.l	d0-d7/a0-a6,-(sp)	;GROSS KLUDGE...KLEAN UP
	move.w	col_offset_(BP),d0	;image offset, on current line to bit
	asl.w	#3,d0			;='x'
	move.w	line_y_(BP),d1
	move.w	ppix_row_less1_(BP),d2	;Paint PIXels per row, minus one DBF'er
	addq.w	#1,d2
	move.l	SAStartRecord_(BP),a0	;1st pixel's "record" inside savearray
	;xjsr GetRGB	;get pixel data from RGB arrays (ZERO flag if none)
	lea	BigPicRGB_(BP),a1
	xjsr GenGetRGB	;get pixel data from RGB arrays (ZERO flag if none)
	sne	Flag24_(BP)	;...Flag24 is set at ReadBody, then set/reset after GetRGB
		;d0=pixel# (even multiple of 32)
		;d1=row#
		;d2=#pixels
		;a0=savearray
	movem.l	(sp)+,d0-d7/a0-a6		;GROSS KLUDGE...KLEAN UP
;skipgetrgbs:
	bra	all_done_end_save_colors




get_savearray_loop:	;get colors from screen into SaveArray
	moveq #0,D0
	move.b  s_LastPlot(a6),D0
	;;;move.b	d0,s_dummy(a6)		;LAST PLOTTED 6 BIT VALUE, see det_loop at end
	cmpi.b  #16,D0
	bcc.s	save_ham_colors
	move.W	D0,d1					;4
	add.w	d1,d1					;4
	add.w	d1,d1					;4
	move.l	0(a2,d1.w),d1	;copy rg from LCT	;18
	;no help...;CLR.B	d1	;clear brite from table, dont mess up lo blue bits
	ASL.L	#4,d1	;<<4, using 8 bits, now...
	;wha?;AND.W	#$F000,d1	;only 4 bits, really, for blue
	;no need?;AND.W	#$FFF0,d1		;4 bit colors...no needed, tho?
	move.B	D0,d1		;lastplot		;4
	move.l	d1,(a6)		;...into SaveArray(r,g,b,LastP) ;14=48cy
	;move.l	0(a2,d1.w),(a6)	;LCT(r,g,b,brite) -> savearray
	lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
	dbf	d3,get_savearray_loop
	bra.s all_done_end_save_colors

save_ham_colors:
	cmp.b	#32,D0
	bcc.s	2$
	;no need;andi.b  #$0f,D0
	asl.B	#4,d0	;8 bit paintcode
	move.b  D0,s_blue(a6)
	move.W	s_red-s_SIZEOF(a6),(a6) ;s_red;we KNOW we're aligned ok
	lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
	dbf	d3,get_savearray_loop
	bra.s all_done_end_save_colors

2$	cmp.b	#48,D0
	bcc.s	3$
;no need;andi.b  #$0f,D0
	asl.B	#4,d0	;8 bit paintcode
	move.b  D0,(a6) ;red
	move.b  s_green-s_SIZEOF(a6),s_green(a6)	;21cy
	move.b  s_blue-s_SIZEOF(a6),s_blue(a6)		;21cy
	;move.L	-s_SIZEOF(a6),(a6)	;lastrgb->thisrgb	;30cy
	;move.b  D0,(a6) ;red
	lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
	dbf	d3,get_savearray_loop
	bra.s all_done_end_save_colors

3$	;no need;andi.b  #$0f,D0
	asl.B	#4,d0	;8 bit paintcode
	move.b  D0,s_green(a6)
	move.b  s_red-s_SIZEOF(a6),(a6)	;s_red;
	move.b  s_blue-s_SIZEOF(a6),s_blue(a6)
	;move.L	-s_SIZEOF(a6),(a6)	;lastrgb->thisrgb	;30cy
	;move.b  D0,s_green(a6)
	lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
	dbf	d3,get_savearray_loop
all_done_end_save_colors:

;==== get colors (Rgb) into savearray for Rub-thru or brush image

	tst.w	(sp)			;2nd time thru?
	;bne.s	donegettingcolors	;used loop 2x, regular and rub//brush
	beq.s	still_1st_time
	tst.l	LoResMask_(BP)		;brush, "real" UNantialias'd mask
	beq	donegettingcolors	;used loop 2x, regular and rub//brush

	bsr	TextAntiAlias		;special loop for aa-text
	bra	donegettingcolors	;used loop 2x, regular and rub//brush

still_1st_time:
	move.w	#-1,(sp) ;set flag saying "2nd time" (i.e. time#1) thru

	tst.b	FlagRub_(BP)
	;bne.s	rubcolors
	bne	rubcolors

	tst.b	FlagCutPaste_(BP)	;WANT 2nd "unplot" - for brush pixels?
	beq	donegettingcolors 	;no->end of 2nd unplot/get color loop
	tst.b	FlagStretch_(BP)	;are we "warping"
	bne	donegettingcolors 	;yes, warping, warp fills in rgb diff'

	cmp.b	#8,EffectNumber_(BP)	;
	beq.s	111$
	cmp.b	#7,EffectNumber_(BP)	;RANGE PAINT?, digipaint pi (6=perspective)
	beq.s	111$
	cmp.b	#3,EffectNumber_(BP)	;mirror/flip horizontal?
	beq.s	111$
	cmp.b	#4,EffectNumber_(BP)	;rotate plus
	beq.s	111$
	cmp.b	#5,EffectNumber_(BP)	;rotate minus
	beq.s	111$

	cmp.b	#4,EffectNumber_(BP)	;fix rotate first time
	bcc	donegettingcolors 	;yes, warping, warp fills in rgb diff'
111$
	lea	SaveArray_(BP),a6
	move.w	last_paste_x_(BP),d0 	;for "paste..[again]' ("x" on scr)
	sub.w	paste_offsetx_(BP),d0	;leftside of brush (off left of scr OK)
	bmi.s	leftcheck
	add.w	paste_width_(BP),d0
	cmp.w	#MAXWIDTH+RIGHTWIDTH,d0
	bcc.s	pastecancel

leftcheck:
	move.w	last_paste_x_(BP),d0 	;for "paste..[again]' ("x" on scr)
	sub.w	paste_offsetx_(BP),d0	;leftside of brush (off left of scr OK)
	bpl.s	pasteleftok
	neg.w	d0
	;04DEC91;cmp.w	#LEFTWIDTH,d0	;max bump off leftside?
	cmp.w	#384,d0	;max bump off leftside?
	bcs.s	plok_neg
pastecancel:
	lea	2(sp),sp	;STACK cleanup 1st/2nd time flag
	st	FlagDisplayBeep_(BP)	;BEEP! off left side too far (<160pixels)
	;bra	cancel_repaint
	bra	skipthis		;rts @ end of repaint_line subr

plok_neg:
	neg.w	d0
pasteleftok:
	ext.L	d0
	asl.L	#5,d0	;*32;mulS	#s_SIZEOF,d0

	add.L	d0,a6			;bup acct for anti-a brush 1/2 offset

	;24 bit mode...get rgbs from 'rgb arrays' instead of bitmap
	movem.l	d0-d7/a0-a6,-(sp)	;GROSS KLUDGE...KLEAN UP

	move.l	a6,a0			;a0="savearray" struct...ptr *inside* struct
	lea	s_Paintred(a0),a0	;point to "paint" colors

	lea	PasteRGB_(BP),a1		;rgb style bitmap for swap screen

	moveq	#0,d0	;'x'=0 for "brush leftside, always

	move.w  line_y_(BP),d1		;current working y on big pic
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)

	move.w	(a1),d2			;bytes per row, brush
	;NO NEED;add.w	#8,d2			;KLUDGE OCT31'91....fix black stripe on right?

;MAY141990;
;MAY141990;	;bummer...fix args
;MAY141990;	tst.l	bm_Planes(a1)	;Datared_(BP)
;MAY141990;	beq.s	111$
;MAY141990;	tst.B	4(a1)			;is this a HIRES BITMAP?
;MAY141990;	beq.s	111$			;don't clear flag just because *this* bitmap not hires
;MAY141990;	;;;tst.b	FlagWorkHires_(BP)
;MAY141990;	;;;bne.s	111$			;want hires...are args already hires?
;MAY141990;	;;;always double args, for brush rgb grab from hires
;MAY141990;	add.w	d0,d0			;double arg, starting pixel#
;MAY141990;	add.w	d2,d2			;double arg, #pixels
;MAY141990;111$

	xjsr GenGetRGB			;get pixel data from RGB arrays (ZERO flag if none)
	;d0=pixel# (even multiple of 32)
	;d1=row#
	;d2=#pixels
	;a0=savearray
	;a1=rgb bitmap <<<==== addtional for 'gen'eric routine

	movem.l	(sp)+,d0-d7/a0-a6	;GROSS KLUDGE...KLEAN UP
	bne	donegettingcolors	;GotRubRGBs

	move.w	PasteBitMap_(BP),d0	;bm_BytesPerRow (1st field in struct)

	move.w  line_y_(BP),d1		;current working y on big pic
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)
	mulu	d0,d1			;bm_BytesPerRow(a6),d1	;offset to start of line in brush
	asl.w	#3,d0			;bm_BytesPerRow(a6)*8=#pixels in brush bitmap

	MOVEM.L	d0/a6,-(sp)		;starting savearray record, loop ctr
	lea	s_effectbyte(a6),a6
	xjsr	UnPlot_PSaveArray	;lineplot.o brush image -> savearray
	MOVEM.L	(sp)+,d3/a6		;starting savearray record, loop ctr

	lea	PasteBitMap_(BP),a3	;pull colors from BRUSH

	lea	s_Paintred(a6),a6
	subq.w	#1,d3			;pixelsperrow-1
	moveq	#0,d0			;x, leftedge in brush

	move.w  line_y_(BP),d1		;current working y on big pic
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)

	bra	get_save_colors_haveY
;--------
rubcolors:
	;24 bit mode...get rgbs from 'rgb arrays' instead of bitmap
	movem.l	d0-d7/a0-a6,-(sp)	;GROSS KLUDGE...KLEAN UP
	move.w	col_offset_(BP),d0	;image offset, on current line to bit
	asl.w	#3,d0			;='x' in pixels per row
	move.w	line_y_(BP),d1

	move.w	ppix_row_less1_(BP),d2	;Paint PIXels per row, minus one DBF'er
	addq.w	#1,d2

	move.l	SAStartRecord_(BP),a0	;1st pixel's "record" inside savearray
	lea	s_Paintred(a0),a0	;point to "paint" colors, swap bitmap

	lea	SwapRGB_(BP),a1		;rgb style bitmap for swap screen
	xjsr GenGetRGB	;get pixel data from RGB arrays (ZERO flag if none)

	;d0=pixel# (even multiple of 32)
	;d1=row#
	;d2=#pixels
	;a0=savearray
	;a1=rgb bitmap <<<==== addtional for 'gen'eric routine

	movem.l	(sp)+,d0-d7/a0-a6		;GROSS KLUDGE...KLEAN UP
	bne.s	donegettingcolors	;	GotRubRGBs

	move.l	linecol_offset_(BP),d1
	STARTaLOOP A6,d0
	addq	#1,d0			;D0=#pixels, now
	lea	s_effectbyte(a6),a6
	xjsr	UnPlot_RSaveArray	;lineplot.o rubthru image -> savearray

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	lea	s_Paintred(a6),a6

	lea	SwapBitMap_(BP),a3
	move.w	col_offset_(BP),d0	;image offset, on current line to bit
	asl.w	#3,d0			;='x'

	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one
	bra	get_save_colors
;--------
donegettingcolors:		;end of 2nd unplot/get color loop
	lea	2(sp),sp	;STACK cleanup 1st/2nd time flag

;DECEMBER 1990...force antialias (text) brushes
	tst.l	LoResMask_(BP)		;brush, "real" UNantialias'd mask
	beq.s	123$
	bsr	TextAntiAlias		;special loop for aa-text
123$:

;LATER?;GotRGBs:	;arrives 'here' when grabbed rgbs from hambone

;OK TO HERE...;  RTS ;KLUDGEOUT EARLY END TO REPAINT_LINE ** CRASHES BEFORE HERE...

;=====set s_PaintFlag(SaveArray) = 0 (no paint) or 1 (paint here)
;...by pulling bits from the 'brush stroke' bitmap
;grab new mask//remask anyway for anti-alias text

	STARTaWordLOOP A6,d0
	lea	s_PaintFlag(a6),a6

	move.l	BB1Ptr_(BP),A0		;where FROM (brush bitplane)
	adda.l	linecol_offset_(BP),a0	;point to current line
	moveq.l	#s_SIZEOF,d2

	tst.b	FlagWorkHires_(BP)
	bne.s	doubledmaskstart	;set 2 bits in array for every mask bit
settoolword_loop:
	move.W	(A0)+,d1 ;get 16bits worth of brushstroke
	set4bits	;code size 40 bytes here
	set4bits
	set4bits
	set4bits

	dbf	D0,settoolword_loop
	bra	gotmaskbits

doubledmaskstart:
	asr.w	#1,d0	;since doubled, and doing 2 per macro, use 1/2 count
	move.w	d2,d3	;s_SIZEOF
	add.w	d2,d2	;s_SIZEOF*2
doubledmaskloop:
	move.W	(A0)+,d1 ;get 16bits worth of brushstroke
	set4doublebits	;code size 40 bytes here
	set4doublebits
	set4doublebits
	set4doublebits

	dbf	D0,doubledmaskloop

gotmaskbits:
	;:set s_HorPixel to reflect bit # for HORIZONTAL shading or STRETCHING
	;:init MaxBit if stretch, shading
	;:init(incr) s_VerPixel

	tst.b	FlagXSpe_(BP)	;dont skip shading h/v savearray record fill?
	bne.s	shadecounts
	moveq	#0,D0
	move.b	FlagStretch_(BP),D0
	or.W	FlagHShading_(BP),D0	;h.b & v.b
	beq	done_shading_ands	;done//not shading and//nor stretching
shadecounts:
	moveq	#0,d4	;MaxBit

	STARTaLOOP A6,d3
	lea	-s_SIZEOF(a6),a6
set_shading_loop:
	lea	s_SIZEOF(a6),a6	;point to next savearray record
	tst.b	s_PaintFlag(a6)
	dbne	d3,set_shading_loop ;decrement and branch until 'ne' (while false)
	beq.s	endof_loopsetshade
	addq.w  #1,d4			;MaxBit+1
	move.w  d4,s_HorPixel(a6)	;current pixel #, left->rt, this line
	addq.w  #1,s_VerPixel(a6)	;curt pix#, top->bot, this 'column'
	dbf	d3,set_shading_loop
endof_loopsetshade:

;regshade:			;'regular' shading
	ADDQ.W	#1,d4		;maxbit var really is 1 wider... WO? WORKED, BUT....
	move.w  d4,MaxBit_(BP)	;just calc'd # of pixels to paint
;check only painting odd/even but AFTER stretching verticals
	move.w	line_y_(BP),d0
	btst.b	#0,d0
	beq.s	evenline
	tst.b	FlagXRig_(BP)	;right/odd lines
	beq	skipthis
	bra.s	dodis
evenline
	tst.b	FlagXLef_(BP)	;left/even lines
	beq	skipthis
dodis:

	tst.b	FlagHShading_(BP) ;just check hor...	tst.W	FlagHShading_(BP)	;h.b & v.b
	beq.s	done_shading

;compute horizontal shading stuff, XMidPoint,fx_left,fx_right
	move.w	HVShadingPotH,d3	;midpoint = int.frac = center*MaxBit
	move.w	MaxBit_(BP),d4	;s_MaxVerPixel,A6=A6+2
	mulu	d4,d3
	ext.l	d4
	add.l	d4,d3 ; make multiply by $FFFF = multiply by ($FFFF+1)
	clr.w	d3	;clear out "fraction"
	swap	d3	;lower 16 bits	;midpoint=maxver*pot/$10000
	move.w	d3,XMidPoint_(BP)
	bne.s	1$
	moveq	#0,D0	;topside=0, factor=zero
	bra.s	computed_fx_left
1$:	;move.l	#$0000FFFF,D0	;move.l #imm,dn  12 cycles ;MAYBE want $10000 ?
	moveq	#0,d0	;4cy
	not.W	d0	;4cy=8cy total, d0=$0000ffff
	divu	d3,D0	;do=.999/leftsidesize

computed_fx_left:
	move.w	D0,fx_left_(BP)	;(a6)+	;s_fx_top

	sub.w	d3,d4 ;NOW this is really this right side size
	bne.s	2$
	moveq	#-1,D0
	bra.s	computed_fx_right
2$:	;move.l	#$0000FFFF,D0	;move.l #imm,dn  12 cycles
	moveq	#0,d0	;4cy
	not.W	d0	;4cy=8cy total, d0=$0000ffff
	divu	d4,D0	;do=.999/rightsidesize
computed_fx_right:
	move.w	D0,fx_right_(BP)	;s_fx_bot ;LAST ONE, DON'T CYCLE FOR A6 PTR INCREMENT

done_shading:

done_shading_ands:	;"done with shading AND Stretching"


	move.b	FlagRub_(BP),D0		;if rubthru
	or.b	FlagStretch_(BP),D0	;or stretch/tile
;"BRUSH COLOR MODE" FORCE;or.b	FlagCutPaste_(BP),D0	;or cutpaste
	bne	done_pcolorfillin	;...then already have paint colors

	tst.b	FlagCutPaste_(BP)	;or cutpaste
	beq.s	7$ ;done_pcolorfillin	;...then already have paint colors
	cmp.b	#7,PaintNumber_(BP)	;"normal" paint?
	beq.s	done_pcolorfillin	;...then already have paint colors

	tst.b	FlagBrushColorMode_(BP)	;"if not" brush color mode
	beq.s	done_pcolorfillin	;...then already have paint colors
7$
	move.b	EffectNumber_(BP),D0

	cmpi.b	#2,d0			;2='blur;',3=fliph,4=rot90,5=rot-90
	;beq.s	done_pcolorfillin	;...then already have paint colors
					;6=RANGE COLORS...ok to skip, paint pi
	bcc.s	done_pcolorfillin	;...then already have paint colors


;dodisppaint:	;use 'displayed rgb #' as paint for these pixels
;may1990
	move.w	Paint8red_(BP),d5
	asl.W	#8,d5
	move.W	Paint8green_(BP),d3	;this is a WORD sized var (byte valid)
	move.B	d3,d5
	move.W	Paint8blue_(BP),d6

	STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
	lea	s_Paintred(a6),a6	;A6=> RED PAINT offset in record

	;may1990
	;move.W	DisplayedRed_(BP),d5 ;(a6)		;paint red,green in s'array
	;move.b	DisplayedBlue_(BP),d6 ;2(a6)	;s_Paintblue
	;asl.W	#4,d5
	;asl.b	#4,d6			;r,g,b <<4, 8 bit paint, now

;gross kludge but needed to fix bug...
;colorize with black messes up so...
;if {colorize (paint#11) AND paint=black}, THEN paint=white

	cmp.b	#11,PaintNumber_(BP)
	bne.s	pcolfillin_loop		;not colorize
	tst.W	d5			;red.b,green.b WORD
	bne.s	pcolfillin_loop		;not BLACK
	tst.b	d6			;blue.b
	bne.s	pcolfillin_loop		;not BLACK
	;move.w	#$0f0f,d5		;red.b,gr.b=WHITE
	;move.B	#$0f,d6			;blue.b=WHITE
	move.w	#$ffff,d5		;red.b,gr.b=WHITE
	move.B	#$ff,d6			;blue.b=WHITE

pcolfillin_loop:	;set s_Paint(rgb)(a?) to be color 2b painted (quick now)
	tst.b	s_PaintFlag-s_Paintred(a6)
	beq.s	1$
	move.W	d5,(a6)+	;DisplayedRed_(BP),(a6)	;paint red,green in s'array
	;move.b	d6,2(a6)	;DisplayedBlue_(BP),2(a6)	;s_Paintblue
	move.b	d6,(a6)		;DisplayedBlue_(BP),2(a6)	;s_Paintblue
	lea	s_SIZEOF-2(a6),a6
	dbf	d3,pcolfillin_loop
	bsr	EnsureWorkHires
	bra.s	after_tp	 ;cant be transp if we're filling in...

1$	move.l	s_red-s_Paintred(a6),(a6)	;old value if no paint here...
	lea	s_SIZEOF(a6),a6
	dbf	d3,pcolfillin_loop
	bsr	EnsureWorkHires
	bra.s	after_tp	 ;cant be transp if we're filling in...

done_pcolorfillin:
	bsr	EnsureWorkHires

	moveq	#0,d0
	move.b	EffectNumber_(BP),d0
	beq.s	no_fx
;SEP91..."auto" scroll the screen more often
;SEP91...repaint calls "PutRGB" before a other time consuming things...
	;BLOWS d0, SEPT 21;xjsr	SimplyScroll		;"auto" scroll the screen   ;SEP91

	xjsr	DoEffect	;DoEffect.o
	xjsr	SimplyScroll		;"auto" scroll the screen ;SEP91 sept21,91  bug fix
no_fx:
	;do "TRANSPARENCY" tranparent tranparency Transparecy
	tst.b	FlagSkipTransparency_(BP)
	bne.s	after_tp
;normal 'rubthru' transparency
	STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray

	move.W	Transpred_(BP),d5
	move.B	Transpblue_(BP),d6
	asl.W	#4,d5
	asl.b	#4,d6			;r,g,b <<4, 8 bit paint, now
transp_loop:
	;cmp.W	s_Paintred(a6),d5	;d5=transparent red.b+green.b
	move.W	s_Paintred(a6),d0	;d5=transparent red.b+green.b
	and.w	#$f0f0,d0
	cmp.w	d0,d5
	bne.s	no_tp_thisone
	;cmp.B	s_Paintblue(a6),d6	;d6=transp blue
	move.B	s_Paintblue(a6),d0	;d6=transp blue
	and.b	#$f0,d0
	cmp.w	d0,d6
	bne.s	no_tp_thisone
	move.L	(a6),s_Paintred(a6)	;s_red(a6),s_Paintred(a6)	;set paint same as existing
no_tp_thisone:
	lea	s_SIZEOF(a6),a6
	dbf	d3,transp_loop
after_tp:


  IFC 't','f'
;DigiPaint Pi...do "fill mode colors"...test array values...
	tst.b	FlagFillMode_(BP)
	beq.s	after_fm
	move.l	FillTblPtr_(BP),d5
	beq.s	after_fm
	move.l	d5,a0
	STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
film_loop:
	move.W	(a6),d5			;=0000rrrr 0000gggg
	asl.B	#4,d5			;=0000rrrr gggg0000
	or.b	s_blue(a6),d5		;=0000rrrr ggggbbbb
	tst.b	0(a0,d5.w)
	bne.s	newcolor_thisone	;use 'paint' if color "set" in table
	move.L	(a6),s_Paintred(a6)	;s_red(a6),s_Paintred(a6)	;set paint same as existing
newcolor_thisone:
	lea	s_SIZEOF(a6),a6
	dbf	d3,film_loop
after_fm:
  ENDC



;range front/back fixer...
	movem.l	(16*4)(BP),d0/d1
	movem.l	d0/d1,-(sp)
	tst.B	ShadeOnOffNum_(BP)	;#1=hor, #2=ver, #3=both, #0=none
	bne.s	1$
	exg.l	d0,d1
	movem.l	d0/d1,(16*4)(BP)	;switch front/back color if no range
1$
	cmp.b	#6,EffectNumber_(BP)	;6=perspective, 7=range
	bcc.s	2$
	;JULY141990;cmp.b	#3,EffectNumber_(BP)	;3=mirror
	cmp.b	#4,EffectNumber_(BP)	;4=rotateplus, 5=rotateminus
	;beq	done_with_paint_code
	bcc	done_with_paint_code	;any effect?
2$
	;24bit mode...using Flag24
	;GetRGB only called if Flag24
	;...Flag24 is set at RePaintLine, then set/reset after GetRGB
	;paintcode.24.i only if Flag24
	;PutRGB only called if Flag24

	clr.w	-(sp)	;june18...skip line if no pixels painted
	STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray

paintcode_loop:			;actually does the 'paint' math...
	tst.b	s_PaintFlag(a6)	;flagged as a brushstroke?
	bne.s	paintit
	lea	s_SIZEOF(a6),a6
	dbf	d3,paintcode_loop ;"decr, branch UNTIL not="


	bra	done_with_paint_loop	;june18;code
paintit:
	st	(sp)	;actually, a word, flag saying 'something' painted june18

	;...flag next 4 pixels as needing replotting
	;...note:	this is rePLOTing, (same or diff paintcolor)
	;...it only indicates that we will reDetermine this dot
	;...this should take care of any cleanup problems

;after_paint_code:	MACRO ;CALLED IN PAINTCODE
; ENDM ;after_paint_code	;NOTE:PAINTCODE ONLY HAS <1> EXIT NOW...


*****************************************************************************
;;  include "PS:paintcode.i" ;new code for 24bit, 8bit color in s_Paint(rgb)*
*****************************************************************************
* PaintCode.i.asm ...included by DoBrushLine and Scratch//RePaint
; determines color to paint given "what was there" and Paint color
; a6 -> s_{rgb},s_Paint{rgb} valid, sets s_{rgb} to result (SaveArray record)
;	feel free to modify what a6 points at (rgb) because it's only used here
; ...must not change a6 itself, but data a6 pts2 needs 2b molested
;REGISTERS....lotsa, a1=substitue for current s_Paintred
;using a3,a2 for shortmuls
;using a3 for temp, britetable

; NOTICE: 'LongColorTable_' is the FIRST variable, so am using a5 as ref'

	xref HVShadingPotV
	xref HVShadingPotH
	xref HVStretchingPotV
	xref HVStretchingPotH

	;load d4.long with dither (table/random/none) value
 IFND RePaint	;"if not the SCRATCH.o module"
	xref EffectNumber_	;3=horflip//mirror,4=rot90,5=-90
	;xref LongColorTablePtr_
	xref Pot0Temp_	;1st slider to right of shading gadgets
	xref Pot1Temp_	;2nd slider to right of shading gadgets (edge)
	;xref Pot2Temp_
	;xref Pot3Temp_
	xref ShortMulTablePtr_
	xref BriteTablePtr_
	xref FlagHStretching_
	xref FlagVStretching_
	xref StretchHPot_
	xref StretchVPot_
	xref StretchGain_
	xref StretchGainAlt_
	xref FlagText_

	move.l	(a6),d4			;s_(r,g,b)
	asl.l	#2,d4			;4 color now 8 bit			
	move.B	3(a6),d4
	move.l	d4,(a6)
	move.l	s_Paintred(a6),d4
	asl.l	#2,d4	;4 color now 8 bit					
	move.B	3+s_Paintred(a6),d4
	move.l	d4,(a6)


	moveq	#0,d4		;default dither (none)
	tst.b	FlagDither_(BP)
	beq.s	skip_myditherset
	move.w	MyDrawY_(BP),d4
	andi.w	#7,d4		;use line # mod 8
	asl.w	#3,d4		;*8
	add.b	s_BitNumber(a6),d4	;byte#, word is valid (valu fitzinbyte)
	move.B	ThresholdTable(pc,d4.w),d4
skip_myditherset:
 ENDC
 IFD RePaint	;"if this IS scratch.o"
	moveq	#0,d4			;clear upper,lower word
	move.b	s_DitherThresh(a6),d4	;only using .B size
 ENDC

	ADDQ.W	#4,d4	;kludge...but it really fixes dither...
	ext.w	d4
	swap	d4	;6.16, preserve sign
	clr.W	d4
	asr.l	#6,d4	;top 6 bits... (max=+/- .5)

	;move.l	BriteTablePtr_(BP),a3	;fix s_(rgb)(),sup 4th byte BRITEVALU
	;move.W	(a6),d0			;2bytes,   0000rrrr0000gggg	;12c
	;asl.b	#4,d0			;green<<4  0000rrrrgggg0000	;14c
	;or.b	2(A6),d0		;          0000rrrrggggbbbb	;12cy
	;move.b	0(a3,d0.w),s_LastPlot(A6)	;8bit bright from table

	move.b	(a6),d0		;red
	move.W	(a6),d2	;only using 2nd byte;move.b	1(a6),d2
	cmp.b	d2,d0
	bcc.s	1$
	move.b	d2,d0	;1(a6),d0
1$	;cmp.b		2(a6),d0
	move.b	2(a6),d2
	cmp.b	d2,d0
	bcc.s	2$
	move.b	d2,d0	;2(a6),d0
2$
;	SUBQ.B	#4,d0		;DITHER FIX...march'90, lastplot brite-4 ditherbits
;	bpl.s	3$
;	moveq	#0,d0
;3$
	move.b	d0,s_LastPlot(a6)	;"highest"/brightest

	LEA	s_Paintred(a6),A1	;POINT TO PAINT.b(r,g,b,brite//lastplot)

	move.b	(a1),d1		;red
	move.W	(a1),d2	;only using 2nd byte;move.b	1(a1),d2
	cmp.b	d2,d1
	bcc.s	11$
	move.b	d2,d1	;1(a1),d1
11$	move.b	2(a1),d2
	cmp.b	d2,d1
	bcc.s	12$
	move.b	d2,d1	;2(a1),d1
12$
;	tst.b	FlagRub_(BP)	;RUB THRU KLUDGE...4bits ...to 8 bits
;	beq.s	13$
;	asl.l	#4,d1
;13$
	move.b	d1,s_LastPlot(a1)


	cmp.b	#7,EffectNumber_(BP)	;range paint?
	bne.s	notrangepaint
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	Brush_Paint_Sol	;ding:	;*****, clear (black) background
	movem.l	(sp)+,d0-d7/a0-a6
notrangepaint:

	move.l	PaintRoutinePtr_(BP),a0
	jmp	(a0)		;d0=bg brite, d1=paint brite


;;;  ifc 't','f' ;JUNE08
ThresholdTable:
	dc.b	00,08,53,61,02,10,55,63
	dc.b	16,24,37,45,18,26,39,47
	dc.b	49,57,04,12,51,59,06,14
	dc.b	33,41,20,28,35,43,22,30
	dc.b	03,11,54,62,01,09,52,60
	dc.b	19,27,38,46,17,25,36,44
	dc.b	50,58,07,15,48,56,05,13
	dc.b	34,42,23,31,32,40,21,29
;;;  endc
  ifc 't','f' ;Feb'90
ThresholdTable:
	dc.b	00-0,08-3,53-3,61-3,02-2,10-3,55-3,63-3
	dc.b	16-3,24-3,37-3,45-3,18-3,26-3,39-3,47-3
	dc.b	49-3,57-3,04-3,12-3,51-3,59-3,06-3,14-3
	dc.b	33-3,41-3,20-3,28-3,35-3,43-3,22-3,30-3
	dc.b	03-3,11-3,54-3,62-3,01-1,09-3,52-3,60-3
	dc.b	19-3,27-3,38-3,46-3,17-3,25-3,36-3,44-3
	dc.b	50-3,58-3,07-3,15-3,48-3,56-3,05-3,13-3
	dc.b	34-3,42-3,23-3,31-3,32-3,40-3,21-3,29-3
  endc
	ifnd StdPot0
 xref StdPot0	;1st slider to right of shading gadgets RELOC'uck...
 xref StdPot1	;2nd slider to right of shading gadgets (edge)
* xref StdPot6	;main control transparency
	endc
	ifnd RePaint	;scratch module? no?
 xref StdPot5 ;warp amt	LOCATABLE, yuck
	endc

InitPaintPtr:	;sup pot values, call once per LINE
		;this grabs 'real time' intuition pot values->basepage temps

		;IF doing a (flip or rotate) OR (text brush paint)
		;...set pots for "maximum blend"

	move.l	d1,-(sp)

	tst.b	FlagText_(BP)
	bne.s	1$
	cmp.b	#3,EffectNumber_(BP)	;3=horflip//mirror,4=rot90,5=-90
	bcs.s	2$
	cmp.b	#7,EffectNumber_(BP)	;range paint (digipaint pi)
	bcc.s	2$

1$	moveq	#-1,d0
	move.w	d0,Pot0Temp_(BP)
	move.w	d0,Pot1Temp_(BP)
	bra.s	3$
2$
	moveq	#0,d0		;clear upper words (in case realtime...april30)
	move.w	StdPot0,d0	;relocatable ref, REALTIME potvalu

  ifd DoBrushLine	;april30.....avg sliders for realtime paint
	add.w	StdPot1,d0
	bcc.s	22$
	swap	d0
	addq.W	#1,d0
	swap	d0
22$	asr.L	#1,d0	;d0=average of 2 sliders...
  endc

	not.w	d0		;flip inTWIT's valu


 ifeq 0

	moveq.l	#0,d1
*	move.w	StdPot6,d1
	move.w	#$0,d1
	not.w	d1
	mulu.w	d1,d0
	tst.w	d0
	bne.s	556$
	add.l	#$10000,d0
556$	swap.w	d0
 endc


	move.w	d0,Pot0Temp_(BP)

    ifd DoBrushLine	;SEP101990...trying to fix 'real time paint...
	move.w	d0,Pot1Temp_(BP)
	bra.s	3$
    endc

	move.w	StdPot1,d0	;relocatable ref, REALTIME potvalu

	not.w	d0		;flip inTWIT's valu


 ifeq 0
	mulu.w	d1,d0
	tst.w	d0
	bne.s	555$
	add.l	#$10000,d0
555$	swap.w	d0
 endc



	move.w	d0,Pot1Temp_(BP)
3$
	moveq	#0,d0		;no warp amt if not stretch hor or vert
	tst.W	FlagHStretching_(BP)	;test TWO flags (.w) vert too
	beq.s	dfltga
	move.w	StdPot5,d0
;	not.w	d0		;flip to bot=0, top=-1 (now) NOT!070594
	;asr.w	#1,d0		;USES 1/2 (flipped) pot valu
	;and.W	#$7fff,d0	;max, tops allowable
dfltga	move.w	d0,StretchGain_(BP)
	not.w	d0
	move.w	d0,StretchGainAlt_(BP)
	

		;set stretch{h,v}pot_ vars to reflect "adjusted" values
	move.w	#$7fff,d0	;default 'y' stretch pot value center'd
	tst.b	FlagHStretching_(BP)
	beq.s	dfltsh
	move.w	HVStretchingPotH,d0	;RELOCATABLES
dfltsh	move.w	d0,StretchHPot_(BP)
	move.w	#$7fff,d0	;default 'y', too
	tst.b	FlagVStretching_(BP)
	beq.s	dfltsv
	move.w	HVStretchingPotV,d0
dfltsv	move.w	d0,StretchVPot_(BP)

	move.l	(sp)+,d1
	rts	;initpaintPTR

InitPaintRtn:	;sets up paint TYPE, only checks once per 'screen'
	moveq	#0,d0
	move.b	PaintNumber_(BP),d0
	add.w	d0,d0			;word size table entries
	lea	PcOffsetTable(pc),a0	;table of offsets to paintcode adrs's
	move.w	0(a0,d0.W),d0		;d0=.w offset to start of table
	lea	0(a0,d0.W),a0		;a0=addr of paintcode=(table+offs)
	move.l	a0,PaintRoutinePtr_(BP)
	rts

PcOffsetTable:	;table of WORDS
	dc.w	Brush_Paint_Add-PcOffsetTable
	dc.w	Brush_Paint_Sub-PcOffsetTable
	dc.w	Brush_Paint_Dkn-PcOffsetTable
	dc.w	Brush_Paint_Ltn-PcOffsetTable

	dc.w	Brush_Paint_Lig-PcOffsetTable
	dc.w	Brush_Paint_Dar-PcOffsetTable
	dc.w	Brush_Paint_Sol-PcOffsetTable
	dc.w	Brush_Paint_Clr-PcOffsetTable

	dc.w	Brush_Paint_And-PcOffsetTable
	dc.w	Brush_Paint_Or-PcOffsetTable
	dc.w	Brush_Paint_Xor-PcOffsetTable
	dc.w	Brush_Paint_Hue-PcOffsetTable	;Colorize	;(hue)



	;generate dithered \1 based on D4(=ThresholdTable)
	;given \1.LONG= integerhiword.fractionloword
	;returns \1.BYTE
			;KLUDGE ADD.L IN MACRO, CLUP PLEASE

  ifnd RePaint ;...if not scratch.o, the module where this bp var is declare
	xref BPaintred_
  endc

Ctab4to8:	dc.b	$00,$10,$20,$30		;18NOV91...cloned from MouseRtns
		dc.b	$40,$50,$60,$70
		dc.b	$80,$90,$a0,$b0
		dc.b	$c0,$d0,$e0,$ff	;note: '$f'->'$ff' skewed, desired.


Brush_Paint_Sol:	;ding:	;*****, clear (black) background
	MOVE.L	(a6),-(sp)	;STACK original background color


;18NOV91;move.l	(17*4)(BP),d0
;18NOV91;asl.L	#4,d0			;back color of 'range' paint
;18NOV91;move.l	d0,(a6)

		;convert $0f to $ff     18NOV91
	moveq	#0,d0
	move.b	0+(17*4)(BP),d0
	move.b	Ctab4to8(pc,d0.W),(a6)+
	move.b	1+(17*4)(BP),d0
	move.b	Ctab4to8(pc,d0.W),(a6)+
	move.b	2+(17*4)(BP),d0
	move.b	Ctab4to8(pc,d0.W),(a6)+
;;	move.b	3+(17*4)(BP),d0			;handle brightness, too			
;;	move.b	Ctab4to8(pc,d0.W),(a6)+
	lea -3(a6),a6

	move.b	(a6),d0		;red
	move.W	(a6),d2	;only using 2nd byte;move.b	1(a6),d2
	cmp.b	d2,d0
	bcc.s	1$
	move.b	d2,d0	;1(a6),d0
1$	
;	cmp.b	2(a6),d0
	move.b	2(a6),d2
	cmp.b	d2,d0
	bcc.s	2$
	move.b	d2,d0	;2(a6),d0
2$	move.b	d0,s_LastPlot(A6)	;8bit bright from table

	;move.L	(16*4)(a0),d0		;rgbb.long front color of 'range'
	move.L	(16*4)(BP),d0		;rgbb.long front color of 'range'
;MAY23....both colors of range the same?
	cmp.l	(17*4)(BP),d0
	beq	keepblack		;both colors the same...end of range

;18NOV91;asl.L	#4,d0			;front color of 'range' paint
;18NOV91;move.L	d0,(a1)			;front color of 'range'=paint
		;convert $0f to $ff     18NOV91
	moveq	#0,d0
	move.b	(16*4)(BP),d0
	move.b	Ctab4to8(pc,d0.W),(a1)
	move.b	1+(16*4)(BP),d0
	move.b	Ctab4to8(pc,d0.W),1(a1)
	move.b	2+(16*4)(BP),d0
	move.b	Ctab4to8(pc,d0.W),2(a1)						
;;	move.b	3+(16*4)(BP),d0		;handle brightness, too
;;	move.b	Ctab4to8(pc,d0.W),3(a1)

	move.b	(a1),d0		;red
	move.W	(a1),d2	;only using 2nd byte;move.b	1(a6),d2
	cmp.b	d2,d0
	bcc.s	11$
	move.b	d2,d0	;1(a6),d0
11$	;cmp.b		2(a6),d0
	move.b	2(a1),d2
	cmp.b	d2,d0
	bcc.s	12$
	move.b	d2,d0	;2(a6),d0
12$	move.b	d0,s_LastPlot(A1)	;8bit bright from table

  ifnd DoBrushLine
	;move.w	#-1,d2 			;'highest' 'max' 16bit frac
	;moveq	#-1,d0	;default if no shading
	;move.l	#$8000,d2

	moveq.l	#1,d2
	swap	d2
	moveq	#-1,d0	;default if no shading

	;move.l	d2,d0
	;moveq.l	#1,d2
	;swap	d2
	;asr.l	#1,d2	;=$0.8000= 1>>1
	;move.l	d2,d0

	tst.W	FlagHShading_(BP)	;tests.b	flagVshading too
	beq.s	RNG_dobov	;do both if no shading selected ;RNG_dend
	tst.b	FlagVShading_(BP)
	beq.s	RNG_gbrat
RNG_dobov:	
	move.w	s_MidPointY(a6),d2	;midpt in pixels, adj per slider
	move.w	s_VerPixel(a6),d0	;ThisBit
	cmp.w	d2,d0			;< Slider?
	bge.s	RNG_dobss
	mulu	s_fx_top(a6),d0
	bra.s	RNG_gbrat
RNG_dobss:	sub.w	d2,d0		;-sliderpos leaves pos on bot half
	mulu	s_fx_bottom(a6),d0
	not.L	d0
RNG_gbrat:
	moveq	#-1,d1	;default if no shading
	tst.W	FlagHShading_(BP)	;tests.b	flagVshading too
	beq.s	RNG_doboh	;do both if no shading selected ;RNG_dend
	tst.b	FlagHShading_(BP)
	beq.s	RNG_grrat			;skip, no horiz shade, use #-1
RNG_doboh:
	move.w	 s_HorPixel(a6),d1
	cmp.w	XMidPoint_(BP),d1	;< Slider?
	bge.s	RNG_dorss			; do right sideshade
	mulu	fx_left_(BP),d1
	bra.s	RNG_grrat
RNG_dorss:	sub.w	XMidPoint_(BP),d1
	mulu	fx_right_(BP),d1
	not.L	d1	;~((pixelnbr-midpoint)*fx_right_(BP))
RNG_grrat:
	asr.w	#8,d0		;ratioa, using just 8 bits now
	andi.w	#$FF,d0
	move.l	BlendCurvePtr_(BP),a0	;256 byte size entries, 1 table 2ways
	move.b	0(a0,d0.w),d0	;straightline - > curve
	;digipaint pi
	beq.s	1$
	addq.w	#1,d0
1$
	asr.w	#8,d1		;ratioB, 8bits now
	andi.w	#$FF,d1
	move.b	0(a0,d1.w),d1	;straightline - > curve
	;digipaint pi
	beq.s	2$
	addq.w	#1,d1
2$

	move.w	d0,d2
	mulu	d1,d2		;d0 = vert * hor ;byte*byte=16bitfraction
RNG_dend:
  endc	;ifnd dobrushline
  ifd DoBrushLine
	;SUNDAYjune2490;moveq	#-1,d2
	moveq.l	#1,d2
	swap	d2		;d2=$1.0000
  endc
	asr.l	#1,d2		;16bits frac >>1 leaves 15 bits frac
	;?;swap	d2		;d2=15bit fraction, "1"=$8000
	move.l	#$8000,d5
	sub.l	d2,d5		;d5=back ratio

	;apply shading to COLOR

	shade24_color red	;move s_Paint(rgb) to s_(rgb) in shaded fashion
	shade24_color green
	shade24_color blue	;s_(rgb) now are 8 BIT VALUES from shade_color

	;apply shading to BRITENESS

	moveq	#0,d0
	moveq	#0,d1
	move.b	s_LastPlot(a1),d0	;s_Paint\1(a6),d0
	move.b	s_LastPlot(a6),d1	;s_red(a6),d1
	mulu	d2,d0		;ratioa, 15 bit fraction
	mulu	d5,d1		;ratiob, 15 bit fraction
	add.L	d1,d0
	ADD.L	d0,d0		;<<1, since 15 bit fractions in d2,d5
	swap	d0
	move.b	d0,s_LastPlot(a6) ;8bit brite of new (ranged) color

		;s_(rgb)(a6)=UNnormalized correct new color, get d1=highestcolor
		;s_(brite=lastplot)=valid 8 bits
  IFC 't','f' ;...no need (?)
		;extract s_rgb's 8 bit britest value, each rgb is 8bits, now
	move.b	(a6),d1		;8bit s_red
	cmp.b	s_green(a6),d1
	bcc.s	23$
	move.b	s_green(a6),d1
23$	cmp.b	s_blue(a6),d1
	bcc.s	24$
	move.b	s_blue(a6),d1
24$				;d0 (still) = 'correct' new brite
	tst.B	d1		;d1=8bit brite of new result color (b-out brite)
	beq.s	keepblack	;black is black is black (stays black)
	
	;WANNADO: each color *(d0=newbrite) /(d1=currentbrite)

	swap	d0	;8bits<<16=24bits
	asr.L	#4,d0	;24bits>>4=20bits

	divu	d1,d0	;20bits/8bits=12bits
	bvc.s	235$
	move.w	#$0fff,d0	;'real high' 12 bit number
235$	;d0='12bit brite factor'

	moveq	#0,d2
	move.b	(a6),d2		;s_red 8 bit
	mulu	d0,d2		;*newbrite    8bit*12bit=4bitint.16bitfrac
	asl.L	#4,d2		;now 8 bit int
	swap	d2
	move.b	d2,(a6) ;s_red(a6) ;is what weir gonna (try to) plot

	moveq	#0,d2
	move.b	s_green(a6),d2	;8 bit
	mulu	d0,d2		;*newbrite    8bit*12bit=4bitint.16bitfrac
	asl.L	#4,d2		;now 8 bit int
	swap	d2
	move.b	d2,s_green(a6)	;is what weir gonna (try to) plot

	moveq	#0,d2
	move.b	s_blue(a6),d2	;8 bit
	mulu	d0,d2		;*newbrite    8bit*12bit=4bitint.16bitfrac
	asl.L	#4,d2		;now 8 bit int
	swap	d2
	move.b	d2,s_blue(a6)	;is what weir gonna (try to) plot
  ENDC

keepblack:	;black is black is black (stays black)
	move.l	(a6),(a1)	;new (ranged) paint (WAS in bg/prev fields)
	MOVE.L	(sp)+,(a6)	;destack original background color (rgb+okBRITE)
		;...end of range paint, continue & blend it in now

	;;;bra resetB_Clr	;"reset Brite (of paint rgb) and do Brush_Paint_Clr"

	;digipaint pi;bra	Brush_Paint_Clr	;end of solidpaint, finish up at 'clr' rtn
	RTS	;BrushPaintSol, digipaint pi





Brush_Paint_Add:
	;MAR91;moveq	#15,d2	;d0_add MACRO 'parm'
	moveq	#-1,d2	;d0_add MACRO 'parm', maximum value
	do_add red
	do_add green
	do_add blue
	;bra.s	Brush_Paint_Clr		;"normal" - background/paintcolor set
	;MAY91;bra	Brush_Paint_Clr		;"normal" - background/paintcolor set
	bra	BP_addsub_end


Brush_Paint_Sub:
	do_sub red
	do_sub green
	do_sub blue
	;bra.s	Brush_Paint_Clr	 ;"normal" - background/paintcolor set
	;bra	Brush_Paint_Clr	 ;"normal" - background/paintcolor set
	;bra	BP_addsub_end
	;both pm-add and pm-sub end up here...so brightness is not disturbed...
BP_addsub_end:

	;ditherend	red
	;ditherend	green
	;ditherend	blue
	;
	;bra	b_is_b_is_b	;black is black is black (stays black)
	bra	Brush_Paint_Clr	 ;"normal" - background/paintcolor set
				;...actually...end of all paint-mode-code

Brush_Paint_Lig:	;lighter ;OK24
	move.l	(a6),d0
	cmp.l	(a1),d0
	;bcs	didpaint	;branch when paint is lighter
	bge	didpaint	;branch when paint is lighter or same
	move.l	(a6),(a1) ;s_Paintred(a6)	;shuffle existing->paint
	bra	didpaint

Brush_Paint_Dar:	;darker ;OK24
	move.l	(a6),d0
	cmp.l	(a1),d0
	bcc	didpaint	;branch when paint is already <=
	move.l	(a6),(a1) ;s_Paintred(a6)	;shuffle existing->paint
	bra.s	didpaint

Brush_Paint_Dkn:	;darken this one (just like lighten, with a twist) OK24
	;DARKEN the paint color	;NOTE: LOWERS CONTRAST
	move.L	(a6),d0	;old r/g/b/brite
	moveq	#0,d1	;clear upper bits (ALREADY CLEARED?)
	move.B	d0,d1	;8bit brite
		;digipaint pi/24....2* darker
	;;;;asr.W	#1,d1	;1/2 as bright
;	sub.b	d1,d0	;original-.5brite=.5 times original bright
;	bcc.s	9$	;underflo?
;	CLR.B	d0	;only clear the brightness
;9$

	asr.w	#1,d1	;brite/2
	move.B	d1,d0	;oldcolor, newbrite
	move.L	d0,(a1)	;new color, brite	


	BRA.s	didpaint	;okoknow...(compute_newhue-no!)
	;BRA	didpaint	;okoknow...(compute_newhue-no!)

Brush_Paint_Ltn:	;LIGHTEN the paint color	;NOTE: RAISES CONTRAST OK24
	move.L	(a6),d0	;old r/g/b/brite
	moveq	#0,d1	;clear upper bits (ALREADY CLEARED?)
	move.B	d0,d1	;8bit brite
		;digipaint pi/24....2* brighter
;	;;;;asr.W	#1,d1	;1/2 as bright
;
	add.b	d1,d0	;original+.5brite=1.5 times original bright

	;;add.b	d0,d0	;double brite
	;ASL.b	d0,d0	;double brite
	bcc.s	9$	;overflo?
	move.B	#-1,d0	;else set brightest
9$
	move.L	d0,(a1)	;new color, brite	
	BRA.s	didpaint	;okoknow...(compute_newhue-no!)


Brush_Paint_Hue:	; (Colorize)	;oh wow real quick?
	;;move.b	s_LastPlot(a6),s_effectbyte(a6)	;use ORIGINAL brite, NEW color
	move.b	s_LastPlot(a6),s_LastPlot(a1) ;use ORIGINAL brite, NEW color
	;;BRA.s	didpaint
	bra.s	Brush_Paint_Clr	;("normal") ;OK24

Brush_Paint_And:	;DO A RECALC *HERE* FOR BRITE... OK24 *no* LOWER BITS?
	move.l	(a1),d1 ;s_Paintred(a6),d1
	and.l	(a6),d1
	;move.b	3(a1),d1	;preserve existing brite valu
	move.l	d1,(a1) ;s_Paintred(a6) ;s_red(a6); 
	bra.s	resetB_Clr	;Brush_Paint_Clr	;	didpaint

Brush_Paint_Or:	;OK24
	move.l	(a1),d1 ;s_Paintred(a6),d1
	or.l	(a6),d1
	;move.b	3(a1),d1	;preserve existing brite valu
	move.l	d1,(a1) ;s_Paintred(a6) ;s_red(a6); 
	bra.s	resetB_Clr	;Brush_Paint_Clr	;	didpaint

Brush_Paint_Xor:	;OK24 no lower bits for regular paint?
	move.l	(a1),d1 ;s_Paintred(a6),d1
	;eor.l	(a6),d1	;illegal opcode blah blah blah
	move.l	(a6),d0
	eor.l	d0,d1
	;move.b	3(a1),d1	;preserve existing brite valu
	move.l	d1,(a1) ;s_Paintred(a6)
	;bra.s	resetB_Clr	;Brush_Paint_Clr	;didpaint

resetB_Clr:	;"reset Brite (of paint rgb) and do Brush_Paint_Clr"
	move.b	(a1),d1
	move.W	(a1),d2	;only using 2nd byte;move.b	1(a1),d2
	cmp.b	d2,d1
	bcc.s	11$
	move.b	d2,d1	;1(a1),d1
11$	move.b	2(a1),d2
	cmp.b	d2,d1
	bcc.s	12$
	move.b	d2,d1
12$	move.b	d1,s_LastPlot(a1)
	;bra.s	Brush_Paint_Clr

Brush_Paint_Clr:	;("normal") ;OK24
	;NOTE: GOT TO RE-COLORIZE...BRIGHTNESS...HUE BLENDING

didpaint:	;have a1=s_paint(r,g,b,BRITE)
	;*all* paint types end up here, in order to 'shade' results
	;s_(rgb)(a6) is old color, s_Paint(rgb)(a6) is calc'd paint

  ifnd DoBrushLine
	moveq.l	#1,d2
	swap	d2			;d2=$1.0000

	tst.W	FlagHShading_(BP)	;tests.b	flagVshading too
	beq.s	dend

	moveq	#-1,d0	;default if no shading
	tst.b	FlagVShading_(BP)
	beq.s	gbrat
	move.w	s_MidPointY(a6),d2	;midpt in pixels, adj per slider
	move.w	s_VerPixel(a6),d0	;ThisBit
	cmp.w	d2,d0			;< Slider?
	bge.s	dobss
	mulu	s_fx_top(a6),d0
	bra.s	gbrat
dobss:	sub.w	d2,d0		;-sliderpos leaves pos on bot half
	mulu	s_fx_bottom(a6),d0
	not.L	d0
gbrat:
	moveq	#-1,d1	;default if no shading
	tst.b	FlagHShading_(BP)
	beq.s	grrat			;skip, no horiz shade, use #-1
	move.w	 s_HorPixel(a6),d1
	cmp.w	XMidPoint_(BP),d1	;< Slider?
	bge.s	dorss			; do right sideshade
	mulu	fx_left_(BP),d1
	bra.s	grrat
dorss:	sub.w	XMidPoint_(BP),d1
	mulu	fx_right_(BP),d1
	not.L	d1	;~((pixelnbr-midpoint)*fx_right_(BP))
grrat:
	asr.w	#8,d0		;ratioa, using just 8 bits now
	andi.w	#$FF,d0
	move.l	BlendCurvePtr_(BP),a0	;256 byte size entries, 1 table 2ways
	move.b	0(a0,d0.w),d0	;straightline - > curve
	beq.s	azero
	ADDQ.W	#1,d0		;front ratio max now $0100, not $00ff
azero:
	asr.w	#8,d1		;ratioB, 8bits now
	andi.w	#$FF,d1
	move.b	0(a0,d1.w),d1	;straightline - > curve
	beq.s	bzero
	ADDQ.W	#1,d1		;BACK ratio max now $0100, not $00ff
bzero:

	move.w	d0,d2
	mulu	d1,d2		;d0 = vert * hor ;byte*byte=16bitfraction
				;d0 maximum 1.0 = $0001.0000
dend:
  endc	;ifnd dobrushline

  ifd DoBrushLine
	moveq.l	#1,d2
	swap	d2
  endc
	asr.l	#1,d2		;16bits frac >> 1 leaves 15 bits frac

	move.w	d2,d1		;save in reg, ratiob build
	mulu	Pot0Temp_(BP),d2 ;=shading ratio * pot0(inverted ok)
	;not.w	d1		;buildt ratiob
	move.l	#$8000,d5	;constant for next instruction, used soon
	sub.w	d5,d1		;#$8000,d1
	neg.w	d1

	mulu	Pot1Temp_(BP),d1 ;=~shading ratio * pot1
	add.L	d1,d2
	swap	d2		;d2=15bit fraction, "1"=$8000
	sub.l	d2,d5		;d5=$0.8000-d2=back ratio

;D2,D5 = FRONT/BACK SHADING/BLENDING RATIOS
;COMPUTE NEW COLOR (SHADE BETWEEN RGBS)
;COMPUTE NEW BRITE (SHADE BETWEEN BRITES)
;COMPUTE NEW RESULT (NEW BRITE, NEW RGB COLOR)


	;COMPUTE NEW COLOR (SHADE BETWEEN RGBS)
	shade24_color red		;move s_Paint(rgb) to s_(rgb) in shaded fashion
	shade24_color green
	shade24_color blue	;s_(rgb) now are 8 BIT VALUES from shade_color
	; s_(red,gr,bl)(A6) = correct color s_LastPlot(A6)=original brite, backg
	; s_(red,gr,bl)(A1) = junked  color s_LastPlot(A1)=original brite, paint

	;COMPUTE NEW BRITE (SHADE BETWEEN BRITES)
	moveq	#0,d0
	moveq	#0,d1
	move.b	s_LastPlot(a1),d0	;8bit brite paint result, no shading
	move.b	s_LastPlot(a6),d1	;8bit brite original/backgrnd
	mulu	d2,d0 	;=ratioa * paint brite
	mulu	d5,d1	;=ratiob * background brite
	add.L	d1,d0	;="new brite"
	ADD.L	d0,d0	;<<1, since 15 bit fractions in d2,d5
		;s_(rgb)(a6)=UNnormalized correct new color, get d1=highestcolor

;COMPUTE NEW RESULT (NEW BRITE, NEW RGB COLOR)
;compute d1=new paint result briteness
;note: really want to recompute 2nd color? (or, colorize s/b diff')
;move.B	s_LastPlot(a6),d1	;8bit brite of background//existing
;compute newbrite from new rgb
	moveq	#0,d1
	move.b	(a6),d1		;red
	move.W	(a6),d2	;only using 2nd byte;move.b	1(a6),d2
	cmp.b	d2,d1
	bcc.s	1$
	move.b	d2,d1	;1(a6),d1
1$	move.b	2(a6),d2
	cmp.b	d2,d1
	bcc.s	2$
	move.b	d2,d1	;2(a6),d1
2$	tst.b	d1
	;beq	b_is_b_is_b	;black is black is black (stays black)
	bne.s	200$
	moveq	#0,d0	;"black" blend ration, color set...
	bra.s	235$
200$

	swap	d0	;8 bits in lower word for compare
	cmp.b	d0,d1	;same as old?
	bne.s	222$	
	move.l	#$08000,d0 ;="1.0">>1 ;#0,d0	;"black" blend/brite adjust ratio
	bra.s	235$
222$
	swap	d0	;8 bits in upper word, int.frac form
	
;WANNADO: each color *(d0=newbrite) /(d1=currentbrite)
	ASR.L	#1,d0	;kludge....lets briteness get "doubled"
	divu	d1,d0	;24bits/8bits=d0.w=16bits fraction
	bvc.s	235$
	move.w	#$ffff,d0	;'real high' 16 bit number
235$	;d0='12bit brite factor'

	move.l	#$ffFFff,d5	;d5=constant for macro, 1.99999

	moveq	#0,d2
	move.b	(a6),d2		;s_red 8 bit
	mulu	d0,d2		;*newbrite    8bit*12bit=4bitint.16bitfrac
	fixbrite
	move.l	d2,d1
	swap	d1
	move.b	d1,(a1) ;s_Paintred(a6)	;save 8 bits
	asr.l	#2,d2	;20bits....  4.16
	dither_dx_l2s d2
	move.b	d2,(a6)	;s_red	;is what weir gonna (try to) plot

	moveq	#0,d2
	move.b	s_green(a6),d2	;8 bit
	mulu	d0,d2		;*newbrite    8bit*12bit=4bitint.16bitfrac
	fixbrite
	move.l	d2,d1
	swap	d1
	move.b	d1,s_Paintgreen(a6)	;save 8 bits
	asr.l	#2,d2	;20bits....  4.16
	dither_dx_l2s d2
	move.b	d2,s_green(a6)	;is what weir gonna (try to) plot

	moveq	#0,d2
	move.b	s_blue(a6),d2	;8 bit
	mulu	d0,d2		;*newbrite    8bit*12bit=4bitint.16bitfrac
	fixbrite
	move.l	d2,d1
	swap	d1
	move.b	d1,s_Paintblue(a6)	;save 8 bits
	asr.l	#2,d2	;20bits....  4.16
	dither_dx_l2s d2
	move.b	d2,s_blue(a6)	;is what weir gonna (try to) plot

b_is_b_is_b:	;black is black is black (stays black)
*************
*
*************

	moveq	#-1,d2			;use this register to fill in flags
	move.b  d2,s_PlotFlag(a6)	;flag as needing a replot

	lea	s_SIZEOF(a6),a6		;=>next savearray record
	move.b  d2,s_PlotFlag(a6)
	move.b  d2,(1*s_SIZEOF+s_PlotFlag)(a6)
	move.b  d2,(2*s_SIZEOF+s_PlotFlag)(a6)
	move.b  d2,(3*s_SIZEOF+s_PlotFlag)(a6)

	dbf d3,paintcode_loop

done_with_paint_loop:
	tst.w	(sp)+	;june18...any pixels painted/masked?
	bne.s	done_with_paint_code	;june18
	bsr	EnsureWorkLores		;AUG161990...fixes for 1x mode, skipped lines
	movem.l	(sp)+,d0/d1		;range paint fix
	movem.l	d0/d1,(16*4)(BP)
	rts	;repaint_line, early, no paintcode happen, no det'+plot

done_with_paint_code:

	;24bit ...save back 8 bit colors from s_Paint(rgb) to rgb arrays
	;tst.b	Flag24_(BP)
	tst.l	Datared_(BP)		;rgb mode for big picture? APRIL90
	beq	skipputrgbs
	movem.l	d0-d7/a0-a6,-(sp)	;GROSS KLUDGE...KLEAN UP
	move.w	line_y_(BP),d0

	move.w	col_offset_(BP),d1	;image offset, on current line to bit
	asl.w	#3,d1			;='x'

	move.w	ppix_row_less1_(BP),d2	;Paint PIXels per row, minus one DBF'er
	addq.w	#1,d2

	move.l	SAStartRecord_(BP),a0	;1st pixel's "record" inside savearray

	xjsr PutRGB	;put pixel data 'back' into RGB arrays (ZERO flag if none)
;WANT....WORKS!;	xjsr PutAllRGB	;put pixel data 'back' into RGB arrays (ZERO flag if none)
	;put"ALL"rgb rtn ignores "paintflag", stuffs ALL values...
	;d0=row#
	;d1=pixel# (even multiple of 32)
	;d2=#pixels
	;a0=savearray

;;;  ifc 't','f' ;WANT, KLUDGE
	bsr	EnsureWorkLores
;;;  ENDC
	;SEP91..."auto" scroll the screen more often
	;SEP91...repaint calls "PutRGB" before a other time consuming things...
	xjsr	SimplyScroll		;"auto" scroll the screen   ;SEP91

	movem.l	(sp)+,d0-d7/a0-a6		;GROSS KLUDGE...KLEAN UP
skipputrgbs:

	;range front/back fixer...
	movem.l	(sp)+,d0/d1
	movem.l	d0/d1,(16*4)(BP)

	;genlock 'fixer upper'...
	;IF   not paintflag (painted pixel)
	;AND  s_PlotFlag (cleanup pixel) 
	;AND  color zero is color (genlock clear)
	;THEN clear plotflag (cause no re-determine)
	tst.b	FlagColorZero_(BP)
	beq.s	notgenlock
	STARTaLOOP A6,d0
genloop:
	tst.b	s_PaintFlag(a6)	;painted?
	bne.s	nextgen		;yep, dont fix
	tst.b	s_PlotFlag(a6)	;clup pixel?
	beq.s	nextgen		;not a cleanup, dont fix
	tst.b	s_LastPlot(a6)	;WAS it color zero?
	bne.s	nextgen		;not genlock clear/color zero
	sf	s_PlotFlag(a6)	;clearing this flag causes NO redetermine
nextgen:
	lea	s_SIZEOF(a6),a6	;next record in savearray
	dbf	d0,genloop
notgenlock:

	STARTaLOOP A6,d2 	;d0
	move.l	DetermineRtn_(BP),A4	;D2,A4 *not* used by DetermineRtn

	move.l	-s_SIZEOF(a6),d1
	clr.B	d1
	move.l	d1,Predold_(BP)

	tst.L	Datared_(BP)		;rgb mode?
	bne.s	start_determineall	;if so....recompute ham for every pixel

det_loop:
	tst.b	s_PaintFlag(a6)
	bne.s	gpdet			;skip redeterm' if no replot here
;*need*, speeds up ham, too...;;  ifc 't','f' ;want,;may1990 kludge...
	tst.b	s_PlotFlag(a6)
	beq.s	saveoldrgb	;skip_newham
				;KNOW no need DETERMINE this one...
;;;  endc ;forces re-determine of all pixels...oh well, no need to save old//lastplot.b, then, tho...

	;;move.l	(a6),Predold_(BP)	;sets up 'old' for next guy's determine
	move.l	(a6),d0 ;s_red	;set up 'old' for next guy's determine
	asR.l	#2,d0		;8bits down to 4
;;	and.l	#$0f0f0f00,d0	;top bit strip (asr crawl down)
	and.l	#$3f3f3f00,d0	;top bit strip (asr crawl down)
	;move.l	d0,Predold_(BP)	;NOTE: messes up 'last plot', lost it long ago...
	move.l	d0,Pred_(BP)	;old/existing rgb colors

	;move.b	s_dummy(a6),d0		;LAST PLOTTED 6 BIT VALUE, see det_loop at end
	;bra.s	skipndet		;get/go/pick determine for plot
	bra.s	call_det

gpdet:
	move.l	(a6),Pred_(BP) 		;(rgb).b args for Determine
call_det:
	jsr	(A4)			;Determine Routine
skipndet:
	move.b  D0,s_LastPlot(a6)	;determ'd result, what we're gonna plot
	bra.s	skip_newham
saveoldrgb:
	move.l	(a6),d0 ;s_red	;set up 'old' for next guy's determine
	asR.l	#2,d0		;8bits down to 4
	and.l	#$3f3f3f00,d0	;top bit strip (asr crawl down)
	move.B	s_LastPlot(a6),d0	;FIX?....maybe no help...24bit vs just ham?
	move.l	d0,Predold_(BP)	;NOTE: messes up 'last plot', lost it long ago...

skip_newham:
	lea	s_SIZEOF(a6),a6		;next pixel record
	;subq.w	#1,(sp)			;line_x_(BP)
	;bcc.s	det_loop
	dbf	d2,det_loop

	;;;lea	2(sp),sp	;dispose of counter from last loop

	bra	skipdetermineall
****
Dsix	 equr	d1   ;d1/d3-d7 
Dfifteen equr	d3
Dhundred equr	d4

start_determineall:
;;	moveq	#6,Dsix
;;	moveq	#$f,Dfifteen
;;	move.w	#$0100,Dhundred		;256 really ("hundred in hex")

	moveq	#$3f,Dfifteen
	move.w	#$0100,Dhundred		;256 really ("hundred in hex")
	moveq	#4,Dsix

determineallloop:
;gross...AUG091990
;if effect# 4 or 5 (rot-, rot+) then do the dithering...
	move.b	EffectNumber_(BP),d0
	subq.b	#4,d0
	beq.s	ditherdown
	subq.b	#1,d0
	beq.s	ditherdown
	tst.b	s_PaintFlag(a6)
	bne.s	didpaintthis		;else...dither 8->4...
ditherdown:
	move.l	(a6),s_Paintred(a6)	;"putrgb","putallrgb" save "paint" field(s)
		;s_paintred is valid.....guaranteed above....
;;;	move.l	s_Paintred(a6),(a6)	;"putrgb","putallrgb" save "paint" field(s)

;QUICK'NDIRTY DITHER...CLEANUP...
	moveq	#0,d0
	move.b	(a6),d0		;8 bit old/background
	add.w	d0,d0		;9 bit
	add.w	d0,d0		;10 bit
; DitherRemove test only	add.B	s_DitherThresh(a6),d0	;+6bit dither (10 bit result, still)
; DitherRemove test only	bcc.s	1$
; DitherRemove test only	add.w	Dhundred,d0
1$:	asr.w	Dsix,d0		;10>6 leaves 4 bit
	cmp.b	Dfifteen,d0
	bcs.s	noRclip
	move.w	Dfifteen,d0
noRclip	move.b	d0,(a6)

	moveq	#0,d0
	move.b	s_green(a6),d0		;8 bit old/background
	add.w	d0,d0		;9 bit
	add.w	d0,d0		;10 bit
; DitherRemove test only	add.B	s_DitherThresh(a6),d0	;+6bit dither (10 bit result, still)
; DitherRemove test only	bcc.s	1$
; DitherRemove test only	add.w	Dhundred,d0
1$:	asr.w	Dsix,d0		;4 bit
	cmp.b	Dfifteen,d0
	bcs.s	noGclip
	move.w	Dfifteen,d0
noGclip	move.b	d0,s_green(a6)

	moveq	#0,d0
	move.b	s_blue(a6),d0		;8 bit old/background
	add.w	d0,d0		;9 bit
	add.w	d0,d0		;10 bit
; DitherRemove test only	add.B	s_DitherThresh(a6),d0	;+6bit dither (10 bit result, still)
; DitherRemove test only	bcc.s	1$
; DitherRemove test only	add.w	Dhundred,d0
1$:	asr.w	Dsix,d0		;4 bit
	cmp.b	Dfifteen,d0
	bcs.s	noBclip
	move.w	Dfifteen,d0
noBclip	move.b	d0,s_blue(a6)

didpaintthis:
	move.l	(a6),Pred_(BP) 		;(rgb).b args for Determine
nowcalldet:

	movem.l	Dsix/Dfifteen/Dhundred,-(sp)
	jsr	(A4)			;Determine Routine
	movem.l	(sp)+,Dsix/Dfifteen/Dhundred


	move.b  D0,s_LastPlot(a6)	;determ'd result, what we're gonna plot
	lea	s_SIZEOF(a6),a6		;next pixel record
	dbf	d2,determineallloop

;	lea	2(sp),sp	;dispose of counter from last loop
****
skipdetermineall:
	STARTaLOOP A6,d0
	addq	#1,d0			;=#pixels to paint//plot
	move.l	linecol_offset_(BP),d1	;offset of image byte(lword)

;	tst.w	LastRepaintX_(BP)	;at leftedge?   june2490
	tst.b	FlagBump32_(BP)
	beq.s	noremove32
	cmp.w	#32+1,d0			;already near the leftedge?
	bcs.s	noremove32
	addq.L	#4,d1			;bump by 4*8=32 pixels
	sub.w	#32,d0			;remove "count for 32" pixels
	lea	32*s_SIZEOF(a6),a6	;bump savearray ptr, skipping pixels
noremove32:
	xjmp	LinePlot_SaveArray	;go and plot lines on HAM Screen
skipthis:
	rts	;end of RePaint_Line subr


**************************************************

	;if in hires format...then double lores->hires, but not PAINT COLORS
EnsureWorkHires:		;scratch.asm....ensures savearray is doubled
	tst.b	FlagToast_(BP)		;toaster mode, anyway?
	beq	done_toasterhires	;...done
;MAY171990;;EnsureWorkHires:		;scratch.asm....ensures savearray is doubled
	tst.b	FlagWorkHires_(BP)	;savearray in lores format, to start
	bne	done_toasterhires	;already...
	;SANITY CHECK
	cmp.w	#MAXWIDTH-2,ppix_row_less1_(BP)
	bcc	done_toasterhires
;;  IFC 't','f' ;WANT,KLUDGE
	MOVEM.L	d0/d1/d2-d5/a0/a1/a2-a5,-(sp)	;saving used regs

	;SANITY CHECK
	;cmp.w	#MAXWIDTH-2,ppix_row_less1_(BP)
	move.w	col_offset_(BP),d0
	asl.w	#3,d0		;*8, bytes->pixels
	add.w	ppix_row_less1_(BP),d0
	add.w	d0,d0		;going to double these...
	cmp.w	#MAXWIDTH-2,d0
	
	bcc	after_sanity
	st	FlagWorkHires_(BP)	;FLAG ONLY SET *HERE*

**************	;double loop values, etc
	move.l	SAStartRecord_(BP),a1
	MOVE.L	A1,-(SP)	;STACK old array start

	move.w	ppix_row_less1_(BP),d0	;Paint PIXels per row, minus one
	MOVE.W	d0,d1		;D1=LOOP COUNTER...watch!
	add.w	d0,d0
	addq.w	#1,d0

;	;SANITY CHECK...KLUDGE
;	cmp.w	#MAXWIDTH-2,d0
;	bcs.s	okhireswidth
;	st	FlagDisplayBeep_(BP)
;	move.w	ppix_row_less1_(BP),d1		;D1=LOOP COUNTER...watch!
;	bra.s	endofdoublevalues	;DON'T double anything, now
;okhireswidth:

	move.w	d0,ppix_row_less1_(BP)	;Paint PIXels per row, minus one
	;move.w	col_offset_(BP),d0
	;add.w	d0,d0
	;move.w	d0,col_offset_(BP)
	asl.w	col_offset_(BP)
	asl.w	SAStartX_(BP)	;starting 'x' value (line_y_ is 'y' analog) ;MAY90

	move.w	pwords_row_less1_(BP),d0	;Paint (short) Words per row
	add.w	d0,d0
	addq.w	#1,d0
	move.w	d0,pwords_row_less1_(BP)	;Paint (short) Words per row

	move.w	plwords_row_less1_(BP),d0	;Paint Long Words per row
	add.w	d0,d0
	addq.w	#1,d0
	move.w	d0,plwords_row_less1_(BP)	;Paint Long Words per row

;;  ifc 't','f'	;want, kludge
	lea	SaveArray_(BP),a0
	sub.l	a0,a1		;a1=SAStartRecord....setup earlier
	add.l	a1,a0		;a0=original offset
	add.l	a1,a0		;a0="doubled" offset
	move.l	a0,SAStartRecord_(BP)
;;  endc

	asl.w	bmhd_rastwidth_(BP)	;helps with rgb file load
endofdoublevalues:
********

	;STARTaLOOP A0,d1
	;move.w	#(MAXWIDTH/2)-1,d1	;loop counter
	;move.w	BigPicWt_W_(BP),d1	;(lores count) loop counter
	;subq.w	#1,d1			;db' type loop
	;a0 already = new addr;lea	SaveArray_(BP),a0

	MOVE.L	(sp)+,a0		;source="old start"
	move.W	d1,d2	;#pixels-1
	;;addq	#1,d2

	ext.l	d2	;mulu	#s_SIZEOF,d2
	asl.L	#5,d2	;*32=s_SIZEOF
	add.l	d2,a0			;source--->midpoint, last original skinny

	move.l	SAStartRecord_(BP),a1
	add.l	d2,a1			;dest--->(1/2x-1)
	add.l	d2,a1			;dest--->(1/2x-1) (1/2x-1)
	;;;add.l	#s_SIZEOF,a1		;a1 points to last new record

	ASR.W	#2,d1		;/4 macros per loop
	move.L	#-s_SIZEOF,d0	;constant, macro, inner loop
lotohiloop:

	LOHIINNER
	LOHIINNER
	LOHIINNER
	LOHIINNER

	dbf	d1,lotohiloop
	
after_sanity:

	MOVEM.L	(sp)+,d0/d1/d2-d5/a0/a1/a2-a5		;saving used regs
;;  ENDC
done_toasterhires:
	RTS	;LORES TO HIRES subroutine



*** hires back to lores for ham

EnsureWorkLores: ;hires back to lores for ham stuff, done with rgb info
;;  RTS ;KLUDGE,WANT
	tst.b	FlagWorkHires_(BP)	;fix//double loop counter if hires
	beq	nohitolo
;NO NEED?;tst.b	FlagToast_(BP)
;NO NEED?;beq	nohitolo

	MOVEM.L	a2-a5,-(sp)		;macro used "a5=bp=basepage"
	SF	FlagWorkHires_(BP)	;flag as "now in lores" format

**************	;halve loop values, etc
	asr.w	ppix_row_less1_(BP)	;Paint PIXels per row, minus one
	asr.w	col_offset_(BP)
	asr.w	SAStartX_(BP)	;starting 'x' value (line_y_ is 'y' analog) ;MAY90
	asr.w	pwords_row_less1_(BP)	;Paint (short) Words per row
	asr.w	plwords_row_less1_(BP)	;Paint Long Words per row

;;;  ifc 't','f'	;want, kludge
	lea	SaveArray_(BP),a0
	move.l	SAStartRecord_(BP),a1
	move.l	a1,-(SP)	;STACK OLD ADDRESS
	sub.l	a0,a1
	move.l	a1,d0
	asr.l	#1,d0		;offset/2  (ok since widths are 64/32/16 etc)
	add.l	d0,a0		;start + 1/2pixeloffset
	move.l	a0,SAStartRecord_(BP)
;;;  endc
	asr.w	bmhd_rastwidth_(BP)	;helps with rgb file load
********

	;STARTaLOOP A0,d1
	;move.w	#(MAXWIDTH/2)-1,d1		;loop counter
	;move.w	BigPicWt_W_(BP),d1	;(lores count) loop counter
	;subq.w	#1,d1			;db' type loop
	move.w	ppix_row_less1_(BP),d1	;Paint PIXels per row, minus one

	;a0=new/current start array adr;lea	SaveArray_(BP),a0
	move.l	a0,a1		;new record (lores)

	;move.l	a0,a1			;from/to pixels
	move.l	(SP)+,a0	;old address
	;ASR.W	#3,d1		;/8 macros per loop
	ASR.W	#2,d1		;/4 macros per loop
	move.L	#s_SIZEOF,d0	;constant, macro, inner loop
hitololoop:

	HITOLOINNER
	HITOLOINNER
	HITOLOINNER
	HITOLOINNER

	dbf	d1,hitololoop

	movem.l	(sp)+,a2-a5	;restore BASEPAGE
nohitolo:
	RTS
***



TextAntiAlias:	;converts 'lores' brush into paintcolors in savearray
	move.l	d7,-(sp)	;digipaint pi...pro'lly not needed?

	lea	SaveArray_(BP),a6
	move.w	last_paste_x_(BP),d0 	;for "paste..[again]' ("x" on scr)
	sub.w	paste_offsetx_(BP),d0	;leftside of brush (off left of scr OK)
	;mulS	#s_SIZEOF,d0
	ext.L	d0
	asl.L	#5,d0			;s_SIZEOF=#32
	add.L	d0,a6			;bup acct for anti-a brush 1/2 offset
	lea	(a6),a4			;a4, dup, begins at same pt

	;a6 lined up for screen (as if anti-ali//smaller brush)
	;a4 lined up further left, as if NOT-anti-alias'd

	clr.w	-(sp)			;brush x
	move.w	PasteBitMap_(BP),d6	;bm_BytesPerRow (1st field in struct)
	asl.w	#2,d6			;*4=#pixels/2
	subq.w	#1,d6			;loop counter?
	moveq	#0,d3			;clear upper bitsaD3 for CHECKMASK macro
taaloop:				;"text anti-alias" loop
	sf	s_PaintFlag(a6)

	moveq	#0,d0
	move.w	(sp),d0			;x on stack
	moveq	#0,d1
	move.w	line_y_(BP),d1
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)
	move.l	LoResMask_(BP),a0	;'unshrunk' bitplane

	move.l	(a6),d5			;d5=r.b,g.b,b.b,?.b OLD COLOR
	CHECKMASK 			;(args d0=x d1=y a0=maskplane),(destroys d2/d3/d4)
	beq.s	1$			;use old color or color from brush?
	move.l	s_Paintred(a4),d5	;2x as fast, new paint color
	st	s_PaintFlag(a6)
;1$	and.l	#$0f0f0f00,d5
1$	;and.l	#$ffffff00,d5
	asr.l	#2,d5			;strip 2 bits...use 6 bits (yuck)
	and.l	#$3f3f3f00,d5

	lea	s_SIZEOF(a4),a4		;2x quicker, brush pixels
	addq.w	#1,(sp)	;brush x

	moveq	#0,d0
	move.w	(sp),d0			;x on stack
	moveq	#0,d1
	move.w	line_y_(BP),d1
	sub.w	first_line_y_(BP),d1	;y="line# in brush"
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)
	move.l	LoResMask_(BP),a0
	CHECKMASK 			;(args d0=x d1=y a0=maskplane),(destroys d2/d3/d4)
	beq.s	2$

	;2nd one IS mask/brush pixel, check if first was
	tst.b	s_PaintFlag(a6)
	bne.s	18$			;yes, 1st AND 2nd pixels set
		;here, 1st NOT, 2nd IS
	;add.l	s_Paintred(a4),d5	;=1x colors from brush
	;add.l	s_Paintred(a4),d5	;=2x colors from brush
	;add.l	s_Paintred(a4),d5	;=3x colors from brush
	move.l	s_Paintred(a4),d7
	asr.l	#2,d7		;	strip 2 bits...use 6 bits (yuck)
	and.l	#$3f3f3f00,d7
	add.l	d7,d5
	add.l	d7,d5
	add.l	d7,d5

	;nope;asr.l	#2,d5	;=(first//bg + 3xsecond//paint)/4
	bra.s	4$		;go mask bits and resave this rgb

18$	;add.l	s_Paintred(a4),d5 ;=2x colors from brush
	move.l	s_Paintred(a4),d7
	asr.l	#2,d7		;strip 2 bits...use 6 bits (yuck)
	and.l	#$3f3f3f00,d7
	add.l	d7,d5

	st	s_PaintFlag(a6)
	bra.s	3$
2$
	;2nd one NOT mask/brush pixel, check if first was
	tst.b	s_PaintFlag(a6)
	beq.s	28$		;bra when 1st NOT mask, also
	move.l	d5,-(sp)
	add.l	d5,d5		;=2x 1st one
	add.l	(sp)+,d5	;=3x 1st one

	;add.l	(a6),d5		;second/background color
	move.l	(a6),d7
	asr.l	#2,d7		;strip 2 bits...use 6 bits (yuck)
	and.l	#$3f3f3f00,d7
	add.l	d7,d5

	;nope;asr.l	#2,d5		;=(3xfirst//paint + second//bg)/4
	bra.s	4$			;go mask bits and resave this rgb
28$	;add.l	(a6),d5			;s_red(a6) ;OLD COLOR "right here"
	move.l	(a6),d7
	asr.l	#2,d7			;strip 2 bits...use 6 bits (yuck)
	and.l	#$3f3f3f00,d7
	add.l	d7,d5
3$
	;nope;asr.l	#1,d5			;almost meaningless, double of bg or paint
	add.l	d5,d5

;4$	and.l	#$0f0f0f00,d5
4$	and.l	#$ffffff00,d5
	move.b	3+s_Paintred(a6),d5
	move.l	d5,s_Paintred(a6)	;"new" "antialiased" (ha!) paint


	lea	s_SIZEOF(a4),a4		;stepping 2x as fast, brush pixels
	addq.w	#1,(sp)	;brush x
	lea	s_SIZEOF(a6),a6		;savearray, next record

	dbf	d6,taaloop
	lea	2(sp),sp		;relieve stack (ahhh....) (loop counter...burp!)

	move.l	(sp)+,d7		;digipaint pi...pro'lly not needed?
	rts

	RDUMP

	end

