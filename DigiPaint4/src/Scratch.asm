*Scratch.asm this module also contains the basepage XDEFclarations

 XDEF Again
 XDEF AOff		;turn OFF all 'modes', reset paint, no effects, etc
 XDEF ClearSaveArray	;clears out the 'per pixel data struct' array
 XDEF Effect_RePaint	;entry for brushfx (rotates)
 XDEF InitBitPlanes	;initializes rastports and bitmaps for bitplane buffers
 XDEF InitBitNumSA	;SaveArray, inits s_BitNumber fields
 XDEF InitScratch
 XDEF RePaint		;repaints window, mathematically is accurate than brush'
			;...gets called after DrawBrush, gets called from DrawBrush
 XDEF RePaint_Picture	;entry point for textstuff, cutting out text

LOWERDITHER	set 3 	;#to LOWER 6 bit max dither thresh by
LEFTWIDTH	set 80 ;160 ;max leftside savearray allowance
RIGHTWIDTH	set 32 ;80	;rightside max past 1024 paste down width

	xref HVStretchPotV	;STretching hor/ver combo pot, vertical value
	xref HVStretchPotH	;STretching hor/ver combo pot, hor value
	xref SinTab
	xref StdPot5		;warp amt	LOCATABLE, yuck

 NOLIST
	Section code,CODE
_scratch:	;label for "basestuff.i"...prevents xref's

	include "ds:basestuff.i"
	include "lotsa-includes.i"
	include "libraries/dos.i"	;fib_ fileinfoblock struct for var
	include "graphics/gfx.i"	;BitMap structure
	include "graphics/rastport.i"	;RastPort stuff
	include "windows.i"
	include "screens.i"
	include "messages.i"	;06/24/87; for cancel message type
	include "ds:SaveRgb.i"
	include "requester.i"
	include	"exec/memory.i" ;needed for AllocMem/AllocRemeber requirements
	include "exec/ports.i"	;for mp_size message port struct
	include "exec/interrupts.i"	;for is_size interrupt server
	;include "exec/io.i"	;for exec io_sizeof
	include "devices/printer.i"	; for printer io req size
	include "ds:TopOFile.i"
 LIST 
SelectUp	equ $68!$80	;these codes basicly come from
SelectDown	equ $68	;....devices/inputevent.i
MenuDown	equ $69
MenuUp	equ $69!$80

;	Section code,CODE
;_scratch:	;label for "digipaint.i"...prevents xref's

InitBitPlanes:
	xjsr	GraphicsWaitBlit	;play catch-up?
	lea	PasteBitMap_(BP),a0	;>6< bitplaner

	tst.l	bm_Planes(a0)		;bitplane(s) alloc'd?
	beq.s	nopastemap
	move.w	(a0),d1	;bm_BytesPerRow(a0),d1	;paste_width_(BP),d1
	beq.s	nopastemap
	asl.w	#3,d1		;#pixels=#bytes*(8bytesperpixel)
	moveq	#6,D0		;DEPTH
	moveq	#0,d2
	move.w	bm_Rows(a0),d2	;paste_height_(BP),d2
	beq.s	nopastemap
	movem.l	d1/d2,-(sp)		;STACK! width,height

	CALLIB	Graphics,InitBitMap

	movem.l	(sp)+,d1/d2		;width,ht
	moveq	#1,d0			;depth
	lea	PasteMaskBitMap_(BP),a0	;single bitplaner
	CALLIB	Graphics,InitBitMap

	lea	PasteRastPort_(BP),A0	;rastport for flooding
	lea	PasteMaskBitMap_(BP),a1
	bsr.s	inita_rport

nopastemap:

	lea	TextMask_RP_(BP),A0	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	lea	BB_BitMap_(BP),a1
	bsr.s	inita_rport		;single bitplane rport for brush
	move.l	4+bm_Planes(a1),d1	;d1=adr of tmpras for AREA fill (SECOND)
	move.w	bm_Rows(a1),d0
	;?;;;mulu	bm_BytesPerRow(BP),d0	;d1=planesize?
	mulu	(a1),d0 ;bm_BytesPerRow(BP),d0	;d1=planesize?

	lea	FillTmpRas_(BP),a1	;a1=tmpras
	move.l	a1,rp_TmpRas(A0)	;RASTPORT why? graphics paradigm sometimes weak
	move.l	a1,a0			;a0=filltmpras
	move.l	d1,a1			;a1=tmpras 2nd bitplane from brush mask bitmap
	CALLIB	Graphics,InitTmpRas


	lea	SwapBitMap_RP_(BP),A0	;rport for swap screen ("getold" usage)
	lea	SwapBitMap_(BP),a1
	;bsr.s	inita_rport
	;rts			;InitBitPlanes

inita_rport:		;CALL WITH a1=bitmap, A0=rastport
	movem.l	A0/a1,-(sp)
	move.l	A0,a1			;a1 is args for next syscall
	CALLIB Graphics,InitRastPort	;sets fgpen=1, bg=0, aol=1

	movem.l	(sp),A0/a1
	move.l	a0,a1	;rastport arg
	moveq	#1,D0
	CALLIB	SAME,SetAPen

	movem.l	(sp)+,A0/a1
	move.l	a1,rp_BitMap(A0)	;shove A1=bitmap into A0 rastport struct
	move.b  #1,rp_FgPen(A0)
	move.b  #0,rp_BgPen(A0)
	move.b  #1,rp_AOLPen(A0)

	rts	;inita_rport


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
init_BitNumber:
	move.b  d7,(A0)
	move.b  d6,((7-6)*s_SIZEOF)(A0)
	move.b  d5,((7-5)*s_SIZEOF)(A0)
	move.b  d4,((7-4)*s_SIZEOF)(A0)
	move.b  d3,((7-3)*s_SIZEOF)(A0)
	move.b  d2,((7-2)*s_SIZEOF)(A0)
	move.b  d1,((7-1)*s_SIZEOF)(A0)
	clr.b	((7-0)*s_SIZEOF)(A0)
	lea	(8*s_SIZEOF)(A0),A0
	dbf D0,init_BitNumber
	rts


SayWait:	;justa subr, used only "here" (MUST end w/checkcancel)
	st	FlagNeedHiresAct_(BP)	;may15LATE....before checkcancel call

	bsr.s	_CheckCancel	;dumpmoves, return cancel status
	bne.s	ea_saywait		;outta here w/no activate...cancel msg waiting

	xjsr	ReallyActivate		;main (stops mousemoves apro')

	xjsr	SetPointerWait	;'other' waitptr, flood, then reg
		;checkcancel to dump current moves before first line
		;ok to 'not do anything' with returned code...
		;...(it'll come back again)
		;fix bug: hang when startpick while drawing/repainting APRIL13
	bsr.s	_CheckCancel	;dumpmoves, return cancel status
	bne.s	ea_saywait		;outta here w/no activate...cancel msg waiting

	xjsr	ResetIDCMP	;may01...removes mousemoves from hires
	xjsr	ReDoHires	;tool.code.i, also does 'unshowpaste' may01
_CheckCancel:
	xjmp	CheckCancel	;dumpmoves, return cancel status
ea_saywait:
	rts

Effect_RePaint:	;entry for brushfx (rotates)
	sf	FlagAgain_(BP)
	bsr.s	SayWait		;force pointer="wait"
	bra.s	cont_start

RePaint:
	bsr.s	SayWait			;force pointer="wait"
	bne.s	dontpaint
	tst.l	FlagCirc_(BP)		;any modes?
	beq.s	98$			;nope
	st	FlagRepainting_(BP)	;dospecial completes shape if this flag
	st	FlagMaskOnly_(BP) 	;force next rtn to happen, no cancel
	xjsr	DoSpecialMode		;drawbrush.o,drawb.mode.i
	xjsr	KillLineList	;drawb.mode.i ;removes 'current shape'
98$:					;no spec'mode like circle, rectangle...
	sf	FlagMaskOnly_(BP)	;moved to always occur APRIL23
	tst.b	FlagXSpe_(BP)	;dont skip shading h/v savearray record fill?
	beq.s	99$
	xjsr	CopySuperScreen	;quick "undo"
99$

Again:	moveq	#-1,d0		;value for flagagain, AGAIN gadget rtn
	bra.s	agst		;'again start'

RePaint_Picture:		;screen='dirty' and UnDoBitMap='clean'
	moveq	#0,d0		;valu for 'flagagain'
agst:	move.b	d0,FlagAgain_(BP)
	clr.L	line_offset_(BP)	;NEED IN CASE ABORT
	bsr	SayWait		;force pointer="wait"
	beq.s	nostartcancel

;may15late;		;may15late...re-enabled to kill brush grodiness at left edge
;may15late;	xjsr	CopySuperScreen
;may15late;	xjsr	ReallyShowPaste	;sup save_display_x/y   may15
;may15late;	xjsr	UnShowPaste	;removes brush from screen may15

dontpaint:	;because 'cancel'd with a button in the input msg stream
	xjsr	MarkedUnDo		;JUNE02...
	sf	FlagBitMapSaved_(BP)	;=-1 if 'undo' saved but not restored (?)
	sf	FlagNeedRepaint_(BP)	;we coulda cancel'd
	sf	FlagRepainting_(BP)	;right *now* we're not 'repaint'ing
	sf	FlagAgain_(BP)
	rts	;abort'd repaint

nostartcancel:

;may15late;		;may15late...re-enabled to kill brush grodiness at left edge
;may15late;	xjsr	CopySuperScreen
;may15late;	xjsr	ReallyShowPaste	;sup save_display_x/y   may15
;may15late;	xjsr	UnShowPaste	;removes brush from screen may15

	xjsr	SaveUnDo ;memories.o;screenbitmap => UnDoBitMap ONLY IF NEEDED
cont_start:
	st	FlagRepainting_(BP)
	clr.w	line_y_(BP)
	clr.L	line_offset_(BP)	;NEED IN CASE ABORT

	xjsr	StrokeBounds	;determine bounds of brush stroke
	;;;d0=xmin d1=ymin d2=xmax d3=ymax d4=width d5=height d6=-1 if empty
	bmi	cancel_repaint	;-->ABORT, nothing in brush bitmap

	st	FlagFirstLine_(BP)	;used by anti-alias (doeffect.o)
	;xref paint_width_	;greatest paint width (strokebounds result)
	;xref halfpaint_width_
	move.w	d4,paint_width_(BP)	;greatest paint width (strokebounds result)
	move.w	d4,halfpaint_width_(BP)	;used by VStrecth (only)
	addq.w	#1,halfpaint_width_(BP)
	asr.w	halfpaint_width_(BP)	;memory mode...only shiftzit (1)
	
		;MAY17...for VStretch (vertical stretching)
	move.w	d0,-(sp)
	and.w	#(32-1),d0	;left offset to 1st painted pixel
	move.w	d0,v_extraleft_(BP)
	move.w	(sp)+,d0

	move.w  d1,first_line_y_(BP)
	move.w  d1,line_y_(BP)		;LINE_Y_ represents current working y
	move.w  d3,last_line_y_(BP)
	
	addq.w	#4,d2	;adjust d2=ending x, accounts for (4) potential cleanups
	cmp.w	BigPicWt_W_(BP),d2
	bcs.s	winbounds
	move.w	BigPicWt_W_(BP),d2
	subq.w	#1,d2
winbounds:
	asr.w	#5,d0	;startx/32= D0=paint start long word #
	asr.w	#5,d2	;ditto for endx
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

	asl.w	#2,d0	;<<2= D0=offset to 1st byte on line 
	move.w	d0,col_offset_(BP)	;image offset, on current line to bit

	mulu	bytes_per_row_W_(BP),d1	;d1 already=first line y
	move.L  d1,line_offset_(BP)	;cur't work'g offset into bitplane

	add.L	d0,d1	;+byte//column offset
	move.L	d1,linecol_offset_(BP)
*NOTE: variable 'linecol_offset' used by 'doeffect-mirror' to find/flip mask

	asl.w	#3,d0	;<<3=*8=#pixels
	mulu	#s_SIZEOF,d0
	lea	SaveArray_(BP),a6
	add.l	d0,a6		;JUNE;lea	0(a6,d0.l),a6
	move.l	a6,SAStartRecord_(BP)	;1st pixel's "record" inside savearray

		;hide the tool window, so we can see bottom of 'repaint area'
	;march23'89;;move.l	TScreenPtr_(BP),A0
	move.l	TScreenPtr_(BP),d0
	bne.s	1$
	move.l	XTScreenPtr_(BP),d0	;"gotta" be there if drawing
1$	move.l	d0,a0			;ham toolscreen -or- hires
	move.w  sc_TopEdge(A0),D0
	tst.b	FlagLace_(BP)
	beq.s	notint
	add.W	D0,D0	;yep, double screen topedge since always in non-int
notint:

	move.l	ScreenPtr_(BP),a2	;a2=screen
	lea	sc_ViewPort(a2),A0	;A0=viewport
	move.l	vp_RasInfo(A0),a1	;a1=rasinfo
	add.w	ri_RyOffset(a1),D0	;Y OFFSET
	cmp.w	d3,D0			;LAST LINE "below" top of tool box?
	bcc.s	skip_ht
	xjsr	CloseToolWindow	;hide it, and set flag to keep tools hidden
skip_ht:

	;FLOOD FILL single bitplane, just once
	tst.b	FlagFlood_(BP)
	beq.s	enda_ff
	tst.b	FlagCutPaste_(BP)	;but NOT in cutpaste mode...(blitter)
	bne.s	enda_ff
	xjsr	DoFlood		;NewFlood.o
	tst.b	FlagDisplayBeep_(BP)
	bne	cancel_repaint	;-->ABORT,...couldn't flood fill
enda_ff:

	move.l	#$B0bB0bD1,random_seed_(BP)	;for same dither every time

	bsr	ClearSaveArray			;march26'89...antialias/doeffect
	move.W	bytes_row_less1_W_(BP),D0
	bsr	InitBitNumSA		;inits s_BitNumber fields in SaveArray

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

	moveq	#0,D0
	cmp.B	#6,PaintNumber_(BP)	;range paint?
	beq.s	dodo_htcalcs		;if so, need 'shading' parms
	move.b	FlagStretch_(BP),D0
	or.w	FlagHShading_(BP),D0	;h.b AND v.b, test BOTH h&v flags
	beq	endof_height_calcs	;none of these 'modes'
dodo_htcalcs:

ivp:	MACRO	;codesize6bytes
	move.l	d1,(a6)	;clears 2 words, verpixel & maxverpixel fields
	lea	s_SIZEOF(a6),a6
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

	;STARTaLongLOOP A6,d0
	;addq.w	#1,d0	;dbf type looper, #longwords
	;add.w	d0,d0	;*2=#words (=16bits) (shorter code within loop)
	;subq.w	#1,d0	;still, a db' type loop index
	STARTaWordLOOP A6,d0
	lea	s_VerPixel(a6),a6
	moveq #0,d1

init_VerPixels:	;inits s_VerPixel(savearray) as "#pixels in the COLUMN"
	ivp8
	ivp8
	dbf	D0,init_VerPixels	;1 word, 16 pixels per iteration

	move.l	BB1Ptr_(BP),A0
	moveq	#0,d2	;clear upper bits, we use it as a byte...

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray

	moveq	#0,d1			;plane offset, starting
	move.w	col_offset_(BP),d1
	add.L	line_offset_(BP),d1	;offset this starting line in plane

	move.w	last_line_y_(BP),d4
	sub.w	first_line_y_(BP),d4
		;addq	#1,d4 ;=#lines to scan
		;subq	#1,d4 ;for db' type loop
	asr.w	#3,d4	;/8, count up 8 lines per loop (could overrun bitmap!)
	move.w	d4,-(sp)	;loop ctr for inner loop (cvloop)
	moveq	#0,d6
	move.w	bytes_per_row_W_(BP),d6	;increments to next line in bitmap
	move.W	ppix_row_less1_(BP),d0	;pixels_row_less1_W_(BP),D0	;count for next loop

init_MaxVerPixel:
	move.L  d1,d3	;plane offset
	move.b  s_BitNumber(a6),d2	;D2 = WORKING BIT# in byte in bitplane
	bne.s	1$
	addq.w  #1,d1	;incr. starting plane address
1$:	move.w	(sp),d4	;db' type loop ctr, ht=#lines to paint//scan
	CLR.W	D5	;only saved word!

count_vertical:	MACRO	;codesize 10bytes
	btst.b  d2,0(A0,d3.L)
	beq.s	cv\@
	addq.w  #1,d5 ;s_MaxVerPixel(a6)
cv\@:	add.L	d6,d3	;.w bytes_per_row_W_(BP),d3	;#40,d3
	endm

cvloop:
	count_vertical
	count_vertical
	count_vertical
	count_vertical

	count_vertical
	count_vertical
	count_vertical
	count_vertical

	dbf	d4,cvloop	;1 longword, 32 pixels per iteration

	ADDQ.W	#1,d5		;maxverpixel var really is 1 wider...
	move.w	d5,s_MaxVerPixel(a6)
	lea	s_SIZEOF(a6),a6

	dbf	D0,init_MaxVerPixel

	lea	2(sp),sp	;(d4) ht loop ctr, cvloop


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
compute_VerPixels:
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
	dbf d7,compute_VerPixels

skip_vshadecomput:

endof_height_calcs:

	bsr	InitPaintRtn	;inside paintcode.i
	xjsr	ResetPriority	;'fast' for initial calc...normal for remainder

;for each line to be plotted
	;get current line (screen image) into savearray
	;get s_Paint(rgb)(), set to be "paint" color or rubthru image OR EFFECT
	;call PaintCode.i.asm (paint) routine... result to s_Paint(rgb)()
	;    doshad moves s_Paint(rgb)() to s_(rgb)()
	;call QuickDetermine for entire line
	;call LinePlot in order to plot the entire line

check_a_line:	;for each line... *** MAIN REPAINT LOOP ***
	bsr	InitPaintPtr	;inside paintcode.i, handle 'realtime' sliders

	bsr	Repaint_Line	;TA DA! we call the MAIN (b)LOOPER here
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

		;MAY14
	tst.l	PasteBitMap_Planes_(BP)	;'pasting'?
	bne	cancel_repaint ;1$	;if pasting, DONT cancel with left button
	cmpi.l	#MOUSEBUTTONS,D0
	beq.s	cancel_chkbutton
;may14;	beq	cancel_chkbutton
;may14;	bra.s	2$
;may14;1$
;may14;	move.l	WindowPtr_(BP),a0	;bigpic
;may14;	xjsr	ReturnMessages	;a0=windowptr  (destroys d0/d1/a1)
;may14;		;scans the 'input message list' and ReplyMsg's all
;may14;		;the msgs for window a0 (for use just before CloseWindow)
;may14;	move.l	MWindowPtr_(BP),d0	;magnify window
;may14;	beq.s	15$
;may14;	move.l	d0,a0
;may14;	xjsr	ReturnMessages	;a0=windowptr  (destroys d0/d1/a1)
;may14;15$
;may14;	bra	cancel_repaint

;may14;2$




REMOVEMSG:	MACRO	;cloned from exec/lists
	MOVE.L	(A1),A0
	MOVE.L	LN_PRED(A1),A1
	MOVE.L	A0,(A1)
	MOVE.L	A1,LN_PRED(A0)
	ENDM

	cmpi.l	#CLOSEWINDOW,d0
	bne.s	notcw
	move.l	a0,a1		;CLOSEWINDOW msg ptr
	REMOVEMSG		;gets 'closewindow' OUT of incoming msg stream
	;may12;xjsr	EndMagnify	;domagnify.o, "kills" magnify scr/win/etc
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
	st	FlagNeedHiresAct_(BP)	;MAY15late
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
	bra	check_a_line	;REPAINT LINE, LOOP AGAIN

cancel_chkbutton:		;definitely leaving, select 'undo' (if any)
		;may03'89...fixbug, guru when 'pick color hamtools' while repaint
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
	bra.s	contend_rp
	;rts			;END OF REPAINT, with a button down

cancel_repaint:
		;march23'89
		;if "low memory" - no cutpaste undo, then remove ENTIRE image
	tst.l	PasteBitMap_Planes_(BP)		;"pasting"?
	beq.s	8$

;may16;	st	FlagNeedHiresAct_(BP)	;MAY14...
;may16;	xjsr	ReallyActivate		;main (stops mousemoves apro')

	tst.l	CPUnDoBitMap_Planes_(BP)	;pasting, but have cpundo?
	bne.s	8$				;yup, continue...nothing special
	st	FlagNeedHiresAct_(BP)	;MAY16
	xjsr	ReallyActivate		;MAY16 main (stops mousemoves apro')
	xjsr	CopySuperScreen
	bra.s	cont_pastend		;MAY16end_repaint
8$:
	move.L	line_offset_(BP),D0	;arg for partialunddo
	xjsr	PartialUnDo	;memories.o ;D0=lineoffset a5=Base
end_repaint:

	sf	FlagNeedRepaint_(BP)	;we coulda cancel'd
	sf	FlagBitMapSaved_(BP)	;=-1 if 'undo' saved but not restored (?)
contend_rp:

		;MAY14
	tst.l	PasteBitMap_Planes_(BP)		;"pasting"?
	beq.s	after_rtnm

	st	FlagNeedHiresAct_(BP)	;MAY14...
	xjsr	ReallyActivate		;main (stops mousemoves apro')

;may15;	xjsr	CopyScreenSuper	;MAY15
;may15;	xjsr	ReallyShowPaste	;MAY15
;may15;
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
;may15;	xref ReallyShowPaste	;MAY15
;may15;	PEA ReallyShowPaste	;MAY15
	

	sf	FlagRepainting_(BP)	;right *now* we're not 'repaint'ing
	sf	FlagAgain_(BP)

	;move.w	#2,MaxTick_(BP)	;using '2', ALWAYS as min. retick for brush, etc
	move.w	#3,MaxTick_(BP)	;using '2', ALWAYS as min. retick for brush, etc

	tst.b	FlagCutPaste_(BP)
	beq.s	95$

		;MAY18late
	cmp.b	#3,EffectNumber_(BP)
	bcc.s	95$			;skip if flip horiz, rot+, rot-
	xjsr	CopyScreenSuper
95$
	rts	;END OF REPAINT

******

Repaint_Line:	;SUBROUTINE

	;1st LOOP sets ditherthreshold,planeadr in each savearray record
	;STARTaLongLOOP A6,d4
	STARTaWordLOOP A6,d4
	addq.w	#1,d4	;dbf type looper, #longwords
	;add.w	d4,d4
	add.w	d4,d4	;*2=#bytes (shorter code within loop)
	subq.w	#1,d4	;still, a db' type loop index
	moveq	#0,d7	;plotflag

		;"latest"
	cmp.b	#4,EffectNumber_(BP)	;#4=rotate+90, effect#5=-90
	bcs.s	1$
	moveq	#-1,d7	;SET PLOTFLAG if rotate types...causes "redetermine"
1$
	lea	s_PlotFlag(a6),a6

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

set_addrlw:	;this loop sets all the dith'thresholds to #63
	setadrbyte
	dbf	d4,set_addrlw
	bra	enda_dithsup	;end of (none,matrix,random) dither setup

setup_randomd:	;SETUP RANDOM DITHER

		;macro codesize 8bytes
nxtrandom:	MACRO	;d-register,  (using d5 as subst for random_seed)
	MOVE.W	d5,\1	;compute next random seed (longword)
	LSR.W	#1,\1
	BCC.s	norflip\@
	EOR.W	d1,\1	;#$B400,\1	;algo ref: Dr. Dobb's Nov86 pg 50,55
norflip\@:
	MOVE.W	\1,d5	;random_seed_(BP)
		;JUNE
	and.W	d0,\1	;i.b #$3f,d6		;.byte of randumbness
	subq	#LOWERDITHER,\1
	bcc.s	nxrok\@
	moveq	#0,\1
nxrok\@:
		ENDM

rset_addrbit:	MACRO	;codesize 20bytes
	nxtrandom d6		;MACRO, compute another random #
	;JUNE;and.b	d0,d6	;i.b #$3f,d6		;.byte of randumbness
	move.b	d7,(a6)+	;s_PlotFlag
	move.b	d6,(a6)	;june22;d6,s_DitherThresh-s_PlotFlag(a6)
	;june22;lea	s_SIZEOF(a6),a6
	lea	(s_SIZEOF-1)(a6),a6	;june22;s_SIZEOF(a6),a6
	ENDM
rsnybble:	  MACRO
	rset_addrbit
	rset_addrbit
	rset_addrbit
	rset_addrbit
	ENDM

	move.w	#$3f,d0		;mask for requ'd random bits
	move.w	#$B400,d1	;algo ref: Dr. Dobb's Nov86 pg 50,55
	MOVE.W	random_seed_(BP),d5	;d5 is subst for random_seed in macro
	addq	#1,d4	;=bytesperrow
	add.w	d4,d4	;=nybblesperrow
	subq	#1,d4	;db' type loop counter
rset_lw:
	rsnybble	;4bits
	dbf	d4,rset_lw
	MOVE.W	d5,random_seed_(BP)	;d5 is subst for random_seed in macro
	bra.s	enda_dithsup	;end of (none,matrix,random) dither setup


setup_matrixd:	;SETUP MATRIX DITHER
	move.w	line_y_(BP),d0
	andi.w	#7,d0		;use line # mod 8
	asl.w	#3,d0		;*8
	lea	ThresholdTable(pc),A0
	lea	0(A0,d0.w),A0	;reset to this 'start of a line of 8 byte values'
	move.L	#(s_SIZEOF-1),d0	;june22;#s_SIZEOF,d0	;june

set_dithbit:	MACRO
	;move.B  (a1)+,(a6)	;dither value.b FROM table INTO savearray
	move.b	d7,(a6)+		;s_PlotFlag(a6)
	move.B	(a1)+,(a6)	;june22;(a1)+,s_DitherThresh-s_PlotFlag(a6)
	add.l	d0,a6		;june;lea	s_SIZEOF(a6),a6
	ENDM
setdbyte:	MACRO
	move.l	A0,a1	;re-setup threshold ptr
	set_dithbit
	set_dithbit
	set_dithbit
	set_dithbit

	set_dithbit
	set_dithbit
	set_dithbit
	set_dithbit
	ENDM
sdithlw:
	setdbyte
	;setdbyte
	;setdbyte
	;setdbyte
	dbf	d4,sdithlw

enda_dithsup:


	;LOOP DE-PLOT a ham line into SaveArray given:
	clr.W	-(sp)		;STACK!!! used in next 'flagged twice' loop
	move.l	linecol_offset_(BP),d1
	STARTaLOOP A6,d0
	addq.w	#1,d0			;=#pixels
	lea	s_LastPlot(a6),a6
	xjsr	UnPlot_SaveArray	;get image bits into savearray

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one DBF'er
	lea	UnDoBitMap_(BP),a3	;pull colors from undo APRIL02'89
	move.w	col_offset_(BP),d0	;image offset, on current line to bit
	asl.w	#3,d0			;='x'

get_save_colors:
		;get rgb for 1st pixel (wether painted or not)
	move.w	line_y_(BP),d1

get_save_colors_haveY:

	;lea	UnDoBitMap_Planes_(BP),a3
	lea	bm_Planes(a3),a3	;april02'89

	move.l	d3,-(sp)		;#pixels-1 (diff for cutpaste)

		;MAY24...left edge sup
	subq.w	#1,d0		;MAY24
	bpl.s	1$
	move.l	LongColorTable_(BP),d0	;WE REALLY *SHOULD* 'getold' rgb
	clr.B	d0
	move.l	d0,Predold_(BP) ;left edge starting clrs
	bra.s	2$
1$
	xjsr	QuickGetOldBM		;d0,1 = x,y WATCH a3=BITPLANE PTRs
2$	move.l	(sp)+,d3
	move.l	Predold_(BP),-s_SIZEOF(a6)

	lea	LongColorTable_(BP),a2
	;move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one DBF'er
	
loop_get_savearray:	;get colors from screen into SaveArray

	moveq #0,D0
	move.b  s_LastPlot(a6),D0
	cmpi.b  #16,D0
	bcc.s	save_ham_colors
		move.W	D0,d1					;4
		add.w	d1,d1					;4
		add.w	d1,d1					;4

		move.l	0(a2,d1.w),d1	;copy rg from LCT	;18
		move.B	D0,d1		;lastplot		;4
		move.l	d1,(a6)		;...into SaveArray(r,g,b,LastP) ;14=48cy
		;move.l	0(a2,d1.w),(a6)	;LCT(r,g,b,brite) -> savearray

		lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
		dbf	d3,loop_get_savearray
	bra.s all_done_end_save_colors

save_ham_colors:
	cmp.b	#32,D0
	bcc.s	2$
	andi.b  #$0f,D0
	move.b  D0,s_blue(a6)
		move.W	s_red-s_SIZEOF(a6),(a6) ;s_red;we KNOW we're aligned ok
		lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
		dbf	d3,loop_get_savearray
	bra.s all_done_end_save_colors

2$	cmp.b	#48,D0
	bcc.s	3$
	andi.b  #$0f,D0
	move.b  D0,(a6) ;red
		move.b  s_green-s_SIZEOF(a6),s_green(a6)	;21cy
		move.b  s_blue-s_SIZEOF(a6),s_blue(a6)		;21cy
		;move.L	-s_SIZEOF(a6),(a6)	;lastrgb->thisrgb	;30cy
	;move.b  D0,(a6) ;red
		lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
		dbf	d3,loop_get_savearray
	bra.s all_done_end_save_colors

3$	andi.b  #$0f,D0
	move.b  D0,s_green(a6)
		move.b  s_red-s_SIZEOF(a6),(a6)	;s_red;
		move.b  s_blue-s_SIZEOF(a6),s_blue(a6)
		;move.L	-s_SIZEOF(a6),(a6)	;lastrgb->thisrgb	;30cy
	;move.b  D0,s_green(a6)
		lea	s_SIZEOF(a6),a6 ;next record in SaveArray, make it current
		dbf	d3,loop_get_savearray
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

	;cmp.b	#3,EffectNumber_(BP)	;MAY23...fix rotate first time
	cmp.b	#4,EffectNumber_(BP)	;MAY23...fix rotate first time
	bcc	donegettingcolors 	;yes, warping, warp fills in rgb diff'

	lea	SaveArray_(BP),a6
	move.w	last_paste_x_(BP),d0 	;for "paste..[again]' ("x" on scr)
	sub.w	paste_offsetx_(BP),d0	;leftside of brush (off left of scr OK)
	bmi.s	leftcheck
	add.w	paste_width_(BP),d0
	cmp.w	#1024+RIGHTWIDTH,d0
	bcc.s	pastecancel

leftcheck:
	move.w	last_paste_x_(BP),d0 	;for "paste..[again]' ("x" on scr)
	sub.w	paste_offsetx_(BP),d0	;leftside of brush (off left of scr OK)
	bpl.s	pasteleftok
	neg.w	d0
	cmp.w	#LEFTWIDTH,d0	;max bump off leftside?
	bcs.s	plok_neg
pastecancel:
	lea	2(sp),sp	;STACK cleanup 1st/2nd time flag
	st	FlagDisplayBeep_(BP)	;BEEP! off left side too far (<160pixels)
	;bra	cancel_repaint
	bra	skipthis		;rts @ end of repaint_line subr
plok_neg:
	neg.w	d0
pasteleftok:

	mulS	#s_SIZEOF,d0
	add.L	d0,a6			;bup acct for anti-a brush 1/2 offset
	move.w	PasteBitMap_(BP),d0	;bm_BytesPerRow (1st field in struct)

	move.w  line_y_(BP),d1		;current working y on big pic
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)
	mulu	d0,d1	;bm_BytesPerRow(a6),d1	;offset to start of line in brush
	asl.w	#3,d0	;bm_BytesPerRow(a6)*8=#pixels in brush bitmap


	MOVEM.L	d0/a6,-(sp)		;starting savearray record, loop ctr
	lea	s_effectbyte(a6),a6
	xjsr	UnPlot_PSaveArray	;lineplot.o brush image -> savearray
	MOVEM.L	(sp)+,d3/a6		;starting savearray record, loop ctr

	lea	PasteBitMap_(BP),a3	;pull colors from BRUSH

	lea	s_Paintred(a6),a6
	subq.w	#1,d3			;pixelsperrow-1
	moveq	#0,d0			;x, leftedge in brush

		;MAY12'89
	move.w  line_y_(BP),d1		;current working y on big pic
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)

	bra	get_save_colors_haveY	;MAY12...was get_save_colors
;--------
rubcolors:
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


 ;=====set s_PaintFlag(SaveArray) = 0 (no paint) or 1 (paint here)
	;...by pulling bits from the 'brush stroke' bitmap

	;grab new mask//remask anyway for anti-alias text

	;STARTaLongLOOP A6,d0
	;lea	s_PaintFlag(a6),a6
	;addq.w	#1,d0	;dbf type looper, #longwords
	;add.w	d0,d0	;*2=#words (=16bits) (shorter code within loop)
	;subq.w	#1,d0	;still, a db' type loop index
	STARTaWordLOOP A6,d0
	lea	s_PaintFlag(a6),a6

	move.l	BB1Ptr_(BP),A0		;where FROM (brush bitplane)
	adda.l	linecol_offset_(BP),a0	;point to current line

setonebrushbit:	MACRO	;code size 10bytes
	roxl.W	#1,d1	;our databit -> eXtend bit (and carry bit, also)
	scs	(a6)	;true if brush bit, else zero (17cy vs. 21prev)
	lea	s_SIZEOF(a6),a6
  endm
set4bits:	MACRO	;code size 40 bytes
	setonebrushbit
	setonebrushbit
	setonebrushbit
	setonebrushbit
	endm

loop_setoolLword:
	move.W	(A0)+,d1 ;get 16bits worth of brushstroke
	set4bits	;code size 40 bytes here
	set4bits
	set4bits
	set4bits
	;june
	;move.W	(A0)+,d1 ;get 16bits worth of brushstroke
	;set4bits
	;set4bits
	;set4bits
	;set4bits

	dbf	D0,loop_setoolLword
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
loop_set_shading:
	lea	s_SIZEOF(a6),a6	;point to next savearray record
	tst.b	s_PaintFlag(a6)
	dbne	d3,loop_set_shading ;decrement and branch until 'ne' (while false)

	beq.s	endof_loopsetshade
	addq.w  #1,d4			;MaxBit+1
	move.w  d4,s_HorPixel(a6)	;current pixel #, left->rt, this line
	addq.w  #1,s_VerPixel(a6)	;curt pix#, top->bot, this 'column'
	dbf	d3,loop_set_shading
endof_loopsetshade:

;regshade:			;'regular' shading
	ADDQ.W	#1,d4		;maxbit var really is 1 wider...
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
	bne.s	done_pcolorfillin	;...then already have paint colors


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
	bcc.s	done_pcolorfillin	;...then already have paint colors


;dodisppaint:	;use 'displayed rgb #' as paint for these pixels

	STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
	lea	s_Paintred(a6),a6	;A6=> RED PAINT offset in record
	move.W	DisplayedRed_(BP),d5 ;(a6)		;paint red,green in s'array
	move.b	DisplayedBlue_(BP),d6 ;2(a6)	;s_Paintblue

		;may04'89....gross kludge but needed to fix bug...
		;colorize with black messes up so...
		;if {colorize (paint#11) AND paint=black}, THEN paint=white
	cmp.b	#11,PaintNumber_(BP)
	bne.s	pcolfillin_loop		;not colorize
	;MAY30late...;tst.b	d5			;red.b,green.b
	tst.W	d5			;red.b,green.b WORD...may30late
	bne.s	pcolfillin_loop		;not BLACK
	tst.b	d6			;blue.b
	bne.s	pcolfillin_loop		;not BLACK
	move.w	#$0f0f,d5		;red.b,gr.b=WHITE
	move.B	#$0f,d6			;blue.b=WHITE

pcolfillin_loop:	;set s_Paint(rgb)(a?) to be color 2b painted (quick now)
	tst.b	s_PaintFlag-s_Paintred(a6)
	beq.s	1$
	move.W	d5,(a6)  ;DisplayedRed_(BP),(a6)	;paint red,green in s'array
	move.b	d6,2(a6) ;DisplayedBlue_(BP),2(a6)	;s_Paintblue
	lea	s_SIZEOF(a6),a6
	dbf	d3,pcolfillin_loop
	bra.s	after_tp	 ;cant be transp if we're filling in...

1$	move.l	s_red-s_Paintred(a6),(a6)	;old value if no paint here...
	lea	s_SIZEOF(a6),a6
	dbf	d3,pcolfillin_loop
	bra.s	after_tp	 ;cant be transp if we're filling in...

done_pcolorfillin:

	moveq	#0,d0
	move.b	EffectNumber_(BP),d0
	beq.s	no_fx
	xjsr	DoEffect	;DoEffect.o
no_fx:
	;do "TRANSPARENCY" tranparent tranparency Transparecy
	tst.b	FlagSkipTransparency_(BP)
	bne.s	after_tp
		;normal 'rubthru' transparency
	STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
	move.W	Transpred_(BP),d5
	move.B	Transpblue_(BP),d6
transp_loop:
	cmp.W	s_Paintred(a6),d5	;d5=transparent red.b+green.b
	bne.s	no_tp_thisone
	cmp.B	s_Paintblue(a6),d6	;d6=transp blue
	bne.s	no_tp_thisone
	move.L	(a6),s_Paintred(a6)	;s_red(a6),s_Paintred(a6)	;set paint same as existing
no_tp_thisone:
	lea	s_SIZEOF(a6),a6
	dbf	d3,transp_loop
after_tp:


;range front/back fixer....MAY14
	movem.l	(16*4)(BP),d0/d1
	movem.l	d0/d1,-(sp)
	tst.B	ShadeOnOffNum_(BP)	;#1=hor, #2=ver, #3=both, #0=none
	bne.s	1$
	exg.l	d0,d1
	movem.l	d0/d1,(16*4)(BP)	;switch front/back color if no range
1$

	cmp.b	#3,EffectNumber_(BP)	;mirror?
	;beq	done_with_paint_code
	bcc	done_with_paint_code	;any effect?




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

	include "ds:paintcode.i"

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
	movem.l	(sp)+,d0/d1		;range paint fix
	movem.l	d0/d1,(16*4)(BP)
	rts	;repaint_line, early, no paintcode happen, no det'+plot

done_with_paint_code:



		;range front/back fixer....MAY14
	movem.l	(sp)+,d0/d1
	movem.l	d0/d1,(16*4)(BP)

		;genlock 'fixer upper'...MAY19...late
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




;may24;	move.l	LongColorTable_(BP),d0	;WE REALLY *SHOULD* 'getold' rgb
;may24;	clr.B	d0
;may24;	move.l	d0,Predold_(BP) ;left edge starting clrs


	STARTaLOOP A6,d0

		;MAY24
	move.l	-s_SIZEOF(a6),d1
	clr.B	d1
	move.l	d1,Predold_(BP)


	;MAY15;clr.w	pixel_count_(BP) ;how many to actually replot (incl clnups)
	move.w	d0,-(sp)		;loop counter
	beq.s	pick_plot		;may04'89
	move.l	-s_SIZEOF(a6),Predold_(BP)	;sup 'old' in case 1st pix' is plotd MAY04

pick_plot:
	tst.b	s_PlotFlag(a6)
	bne.s	gpdet			;skip redeterm' if no replot here
					;KNOW no need DETERMINE this one...
	;?;tst.b	s_SIZEOF+s_PlotFlag(a6)	;plotting (next) one, though?
	;?;beq.s	skipndet		;not det'g next one, count to end

	move.l	(a6),Predold_(BP)	;sets up 'old' for next guy's determine
	bra.s	skipndet		;get/go/pick determine for plot

gpdet:	;MAY15;addq.w	#1,pixel_count_(BP)	;got/pick this one, determine plot
	move.l	(a6),Pred_(BP) 		;(rgb).b args for Determine
	move.l	DetermineRtn_(BP),A0
	jsr	(A0)
	move.b  D0,s_LastPlot(a6)	;determ'd result, what we're gonna plot
skipndet:
	lea	s_SIZEOF(a6),a6		;next pixel record
	subq.w	#1,(sp)			;line_x_(BP)
	bcc.s	pick_plot

	lea	2(sp),sp	;dispose of counter from last loop

	STARTaLOOP A6,d0
	addq	#1,d0			;=#pixels to paint//plot

	move.l	linecol_offset_(BP),d1	;offset of image byte(lword)



	xjmp	LinePlot_SaveArray
skipthis:

	rts	;end of RePaint_Line subr





CHECKMASK:	MACRO	;(destroys d2/d3/d4)  (args d0=x d1=y a0=maskplane)
	move.w	d1,d4			;d4 gonna be address in bitplane
	mulu	PasteBitMap_(BP),d4	;y*#bytes per row in brush

	move.w	d0,d3	;d3=copy of x for BYTE
	asr.w	#3,d3	;x/8
	add.L	d3,d4	;upper bitsaD3 cleared
	moveq	#7,d2	;prep for...
	sub.w	d0,d2	;d2=bit # in byte (+junk >7, ignored in  bXXX.b opcode)
	btst	d2,0(a0,d4.L)
  ENDM

TextAntiAlias:	;converts 'lores' brush into paintcolors in savearray

	lea	SaveArray_(BP),a6
	move.w	last_paste_x_(BP),d0 	;for "paste..[again]' ("x" on scr)
	sub.w	paste_offsetx_(BP),d0	;leftside of brush (off left of scr OK)
	mulS	#s_SIZEOF,d0
	add.L	d0,a6			;bup acct for anti-a brush 1/2 offset
	lea	(a6),a4			;a4, dup, begins at same pt

		;a6 lined up for screen (as if anti-ali//smaller brush)
		;a4 lined up further left, as if NOT-anti-alias'd

	clr.w	-(sp)			;brush x
	move.w	PasteBitMap_(BP),d6	;bm_BytesPerRow (1st field in struct)
	asl.w	#2,d6			;*4=#pixels/2
	subq.w	#1,d6			;loop counter?
	moveq	#0,d3			;clear upper bitsaD3 for CHECKMASK macro
taaloop:			;"text anti-alias" loop
	sf	s_PaintFlag(a6)

	moveq	#0,d0
	move.w	(sp),d0			;x on stack
	moveq	#0,d1
	move.w	line_y_(BP),d1
	sub.w	first_line_y_(BP),d1
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)
	move.l	LoResMask_(BP),a0	;'unshrunk' bitplane

	move.l	(a6),d5			;d5=r.b,g.b,b.b,?.b OLD COLOR
	CHECKMASK 	;(args d0=x d1=y a0=maskplane),(destroys d2/d3/d4)
	beq.s	1$			;use old color or color from brush?
	move.l	s_Paintred(a4),d5	;2x as fast, new paint color
	st	s_PaintFlag(a6)
1$	and.l	#$0f0f0f00,d5

	lea	s_SIZEOF(a4),a4		;2x quicker, brush pixels
	addq.w	#1,(sp)	;brush x

	moveq	#0,d0
	move.w	(sp),d0			;x on stack
	moveq	#0,d1
	move.w	line_y_(BP),d1
	sub.w	first_line_y_(BP),d1	;y="line# in brush"
	add.w	paste_clipy_(BP),d1	;topside clip allowance (#lines off scr)
	move.l	LoResMask_(BP),a0
	CHECKMASK 	;(args d0=x d1=y a0=maskplane),(destroys d2/d3/d4)
	beq.s	2$

	;2nd one IS mask/brush pixel, check if first was
	tst.b	s_PaintFlag(a6)
	bne.s	18$			;yes, 1st AND 2nd pixels set
		;here, 1st NOT, 2nd IS
	add.l	s_Paintred(a4),d5	;=1x colors from brush
	add.l	s_Paintred(a4),d5	;=2x colors from brush
	add.l	s_Paintred(a4),d5	;=3x colors from brush
	asr.l	#2,d5		;=(first//bg + 3xsecond//paint)/4
	bra.s	4$		;go mask bits and resave this rgb

18$	add.l	s_Paintred(a4),d5	;=2x colors from brush
	st	s_PaintFlag(a6)
	bra.s	3$
2$
	;2nd one NOT mask/brush pixel, check if first was
	tst.b	s_PaintFlag(a6)
	beq.s	28$			;bra when 1st NOT mask, also
	move.l	d5,-(sp)
	add.l	d5,d5		;=2x 1st one
	add.l	(sp)+,d5	;=3x 1st one
	add.l	(a6),d5		;second/background color
	asr.l	#2,d5		;=(3xfirst//paint + second//bg)/4
	bra.s	4$		;go mask bits and resave this rgb
28$	add.l	(a6),d5			;s_red(a6) ;OLD COLOR "right here"
3$
	asr.l	#1,d5			;almost meaningless, double of bg or paint
4$	and.l	#$0f0f0f00,d5
	move.b	3+s_Paintred(a6),d5
	move.l	d5,s_Paintred(a6)	;"new" "antialiased" (ha!) paint


	lea	s_SIZEOF(a4),a4		;stepping 2x as fast, brush pixels
	addq.w	#1,(sp)	;brush x
	lea	s_SIZEOF(a6),a6		;savearray, next record

	dbf	d6,taaloop
	lea	2(sp),sp	;relieve stack (ahhh....) (loop counter...burp!)
	rts






ClearSaveArray:	;clears out the array
		;(so's file loading plots color zero on plot overruns)
	;imaginary pixels on left on right edge, too, "softening"

;	lea	PasteExtraLeft_(BP),a0	;very very(jeesh...) first record
;	moveq	#0,d0					;data to clear with
;	move.l	#(((LEFTWIDTH+1024+RIGHTWIDTH)*s_SIZEOF)/4)-1,d1	;loop counter
;csaloop	move.l	d0,(a0)+
;	dbf	d1,csaloop

	lea	PasteExtraLeft_(BP),a0	;very very(jeesh...) first record
	move.l	#(LEFTWIDTH+1024+RIGHTWIDTH)*s_SIZEOF,d0
	xjsr	ClearMemA0D0	;may01

		;set s_stfx_top/bot to '-1' 
	tst.b	FlagAAlias_(BP)
	beq.s	enda_csa
	;JUNE05;lea	s_stfx_bottom+PasteExtraLeft_(BP),a0	;very very(jeesh...) first record
	lea	s_stfx_top+PasteExtraLeft_(BP),a0	;top.word + bot.word JUNE05
	moveq	#-1,d0			;data to clear with
	move.l	#(LEFTWIDTH+1024+RIGHTWIDTH)-1,d1	;loop counter
csBloop	move.l	d0,(a0)			;top.word, bot.word
	lea	s_SIZEOF(a0),a0		;next record
	dbf	d1,csBloop
enda_csa
	rts

;deffont:	dc.b 'topaz.font'
;deffontlen	set *-deffont
;	cnop 0,2

InitScratch:
		;sup def font for bigpic
	lea	FontNameBuffer_(BP),a0
	lea	TextAttr_(BP),a1
	move.l	a0,(a1)+		;ta_Name()<-*fontnamebuffer
	move.w	#8,(a1)+		;ta_Size
	clr.b	(a1)			;ta_Style
	tst.b	(a0)		;already have a fontname?
	bne.s	hadfontname

	;lea	deffont(pc),a1
	;moveq	#deffontlen-1,d0
 XREF MyFontName	;startup.o constant ;dc.b 'topaz.font',0
	lea	MyFontName,a1	;abs reloc', yech
	moveq.l	#32-1,d0	;maxlen

fnloop:	move.b	(a1)+,(a0)+
	dbf	d0,fnloop
	clr.b	(a0)		;null term font name str (not needed?)
hadfontname:
	lea	BottomRowAscii_(BP),A0	;clear 'bottom overscan hires display'
	;moveq	#(80/4)-1,D0
	moveq	#(78/4)-1,D0	;really only clrs 76 bytes...APRIL27
aclr:	move.L	#'    ',(A0)+	;fill with BLANKS (have zeros//nulls)
	dbeq	D0,aclr		;no clear 81st, etc, leave zero/null at endstr

	move.w	#38,BrushNumber_(BP)	;little med circle
	;move.w	#31,BrushNumber_(BP)	;5x5 SQUARE BOX BRUSH
	;move.w	#22,BrushNumber_(BP)	;right slant7x7? (23=6x6,24=5x5,etc)
	;move.w	#21,BrushNumber_(BP)	;right slant10x10?
	;move.w	#6,BrushNumber_(BP)	;SINGLE DOT BRUSH

	clr.w	StretchGain_(BP)
	move.w	#-1,StdPot5
	move.w	#$7fff,d0
	move.w	d0,StretchHPot_(BP)	; horizontal blend of 2way
	move.w	d0,StretchVPot_(BP)	; vertical blencd of 2way

	move.b	#1,StretchOnOffNum_(BP) ;#1=hor||, #2=ver--, #3=both++, #0=none

	moveq	#15,D0			;WHITE PAINT DEFAULT RGB paint color
	move.b	D0,Pblue_(BP)
	move.b	D0,Paintblue_(BP)
	move.b	D0,Pred_(BP)
	move.b	D0,Pgreen_(BP)
	move.b	D0,Paintred_(BP)
	move.b	D0,Paintgreen_(BP)
	move.b	#6,PaintNumber_(BP)	;'shadow/background shading'
	
	move.b	#18,PenColor_(BP)	;palette color #16 COLOR=FOREGROUND

	move.l	sp,random_seed_(BP)	;set random seed to be our stack address

	lea	SinTab,a0		;YECH an absolute relocatable XREF
	move.l	a0,BlendCurvePtr_(BP)	;256 byte size entries, 1 table 2ways

	lea	DefaultColors(pc),A0
	lea	LongColorTable_(BP),a1

	movem.l	a2-a4,-(sp)		;STACK a2-a4 probably not needBsaved?
	lea	HiresColorTable_(BP),a2
	lea	HamToolColorTable_(BP),a3
	lea	BigPicColorTable_(BP),a4

	moveq	#19-1,d0	;6-1,D0	;#64-1,D0
setupcolors:
	move.l	(A0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	move.l	d1,(a3)+
	move.l	d1,(a4)+
	dbf	D0,setupcolors
	movem.l	(sp)+,a2-a4		;DE-STACK

	;Canceler.o  *changeable* load/save string for gadget AND requester
	;move.w	#'  ',OF_String_(BP)	;just two spaces
	move.l	#'Open',LS_String_(BP)
	move.l	#' Fai',(4+LS_String_)(BP)
	move.l	#('led'<<8),(8+LS_String_)(BP) ;ensure end with NULL

	move.b	#6,bmhd_nplanes_(BP)
	move.b	#1,bmhd_compression_(BP)

	st	FlagCDet_(BP)		;"activates" createdetermine subr
	st	FlagXLef_(BP)	;left/even lines
	st	FlagXRig_(BP)	;right/odd lines
	st	CurrentFrameNbr_(BP)	;showgads.o, "asks for new display"
	;;;leave 0 sup clrd ;st	FlagCapture_(BP)	;KLUDGE....s/b in main.cmd, etc?
	RTS

AOff:	;All Off...initialize flags, modes, etc
	;move.w	#(1<<8),TileX_(BP)	;tile factor of <1> for default
	;move.w	#(1<<8),TileY_(BP)
	move.w	#(1<<4),TileX_(BP)	;tile factor of <1> for default
	move.w	#(1<<4),TileY_(BP)

	move.b	#7,PaintNumber_(BP)	;"normal"/clear
	sf	FlagRub_(BP)
	st	FlagBrushColorMode_(BP)
	st	FlagDitherRandom_(BP)	;randomized dither ON
	st	FlagHStretching_(BP)	;Horizontal stretching ON
	st	FlagSkipTransparency_(BP) ;default OFF NOW ;cutpaste.o/repaint.o/menurtns.o
	st	FlagNeedGadRef_(BP)	;gets 'hires gadget refresh'
	st	FlagFilePalette_(BP)	;for '1st time load' march09'89
	;;;st	FlagCloseWB_(BP)	;for '1st time preference' march09'89

	sf	FlagVStretching_(BP)	;Vertical   stretching OFF
	sf	FlagHShading_(BP)	;Horizontal shading OFF
	sf	FlagVShading_(BP)	;Vertical   shading OFF
	sf	FlagBSmooth_(BP)	;smooth drawing OFF
	sf	FlagFlood_(BP)		;flood fill OFF

	;sf	FlagCirc_(BP)	;drawing circles
	;sf	FlagCurv_(BP)	;drawing curves
	;sf	FlagRect_(BP)	;drawing rectangular boxes
	;sf	FlagLine_(BP)	;drawing lines
	clr.l	FlagCirc_(BP)	;clear 4 "byte size" flags

	sf	FlagToolWindow_(BP)	;"we prefer NOT to see the toolwindow"
	sf	FlagDither_(BP)		;MATRIX dither OFF
	sf	FlagEffects_(BP)	;no effects
	sf	FlagStretch_(BP)	;...(no effects means no stretch, too)
	;move.w	#2,MaxTick_(BP)	;using '2', ALWAYS as minimum ticker
	move.w	#3,MaxTick_(BP)	;using '2', ALWAYS as minimum ticker

	moveq	#0,D0	;ZERO flag
	rts		;InitScratch,Aoff ended ok, alloc'd ok

	cnop 0,4 ;note:	we're still in code, so we s/b word aligned already
;MAY23
;DefaultColors:
;	;internal format:default palette if no file
;
;	dc.l	$00000000,$0f0f0f00,$02020200,$05050500
;	dc.l	$08080800,$0c0c0c00,$0d040a00,$0e020200
;	dc.l	$0a050400,$05030200,$0e090200,$07070100
;	dc.l	$0e0d0200,$01090100,$02050800,$03030f00
;
;	;dc.l	$03020600,$0f0f0400,$0f0f0f00	;colors 16,17,18 (18='current')
;	dc.l	$0e0d0200,$0f000000,$0f0e0d00	;colors 16,17,18 (18='current')
;		;^--1st    ^--2nd    ^-current
;		; range     range       color
;

DefaultColors:
	;internal format:default palette if no file

	dc.l	$00000000,$0F0F0F00,$05050500,$0A0A0A00
	dc.l	$08000800,$0F040A00,$0D000000,$06020000
	dc.l	$0F060000,$0F0A0800,$0F0F0000,$000F0300
	dc.l	$00060000,$000C0C00,$00060F00,$00000A00

	dc.l	$0e0d0200,$0f000000,$0f0e0d00	;colors 16,17,18 (18='current')
		;^--1st    ^--2nd    ^-current
		; range     range       color

MYBASEOFF	set	0	;base offset for xref defines


SByte:	MACRO	;name
	XDEF	\1_
\1_	equ	MYBASEOFF
MYBASEOFF	set	MYBASEOFF+1	;byte
	endm

SWord:	MACRO	;name
	XDEF	\1_
MYBASEOFF	set	((MYBASEOFF+1)/2)*2	;cnop 0,2
\1_	equ	MYBASEOFF
MYBASEOFF	set	MYBASEOFF+2	;word
	endm

SLong:	MACRO	;name
	XDEF	\1_
MYBASEOFF	set	((MYBASEOFF+3)/4)*4	;LONG ALIGN FOR 020's
\1_	equ	MYBASEOFF
MYBASEOFF	set	MYBASEOFF+4	;longword
	endm

SArray:	MACRO	;name,size in BYTES
	XDEF	\1_
MYBASEOFF	set	((MYBASEOFF+3)/4)*4	;long align ARRAYS for 020's
\1_	equ	MYBASEOFF
MYBASEOFF	set	4*((\2+3)/4)+MYBASEOFF	;longword roundup alloc
	endm

 SArray LongColorTable,(64*4) ;allow 64 entries ;COLOR 16=curt, 17=bkgrnd

	SByte Paintred	;r,g,b for color 2 default
	SByte Paintgreen
	SByte Paintblue
	SByte Paintjunk

	SByte BPaintred	;r,g,b for color background / mixer color
	SByte BPaintgreen
	SByte BPaintblue
	SByte BPaintvalu

	SByte DisplayedRed	;LONG word ALIGN! (at least word, please)
	SByte DisplayedGreen
	SByte DisplayedBlue
	SByte PenColor	;we start with color#2 active
	SWord BestPen_W	;for domask.i...quickplots
	SLong PenRtnA	;JUNE01
	SLong PenRtnB	;JUNE02

	SLong _WBenchArgName
	SLong _WBenchMsg
	SLong _WBenchArg
	SLong dosCmdLen
	SLong dosCmdBuf
	SLong our_task
	SLong startup_taskpri
	SLong current_dir
	SLong save_dir

	SLong DOSLibrary
	SLong ExecLibrary	;using this instead of '#4
	SLong GraphicsLibrary
	SLong IconLibrary
	SLong IntuitionLibrary
	SLong ConsoleBase	;GrabConsoleBase rtn in PrintRtns.o

	SLong Where_We_Came_From	;holds initial stack location
	SLong saveexecwindow		;JULY06

	SLong Initializing	;error103,nomemory ;0 = no, -1 = yes
	SLong BrushGadgetPtr

ShortandLong:	MACRO
	SWord \1
	SWord \1_W
	endm

	ShortandLong bytes_per_row
	ShortandLong bytes_row_less1
	ShortandLong words_row_less1
	ShortandLong BigPicWt
	ShortandLong pixels_row_less1
	SWord lwords_row_less1	;only need short, this is new

 SArray Zeros,(4*15) ;4bytes*15registers)
	; usage is: " movem.l	Zeros,D0-d7/A0-a6 "
	;enables 1 instr. (short CODE) clear of multiple registers

	SLong MsgPtr
	SLong MsgSeconds	;for double click timings...
	SLong MsgMicros
	SLong HiresIDCMP	;flag bits for message types, set in main.o
	;noneednomo';april27;SLong WindowIDCMP	;flag bits for message types, set in main.o
	SArray OnlyPort,MP_SIZE ;standard exec message port
	;no need ;SArray DontUseSystem,32	;APRIL16...msg port yuckkie?..not even/8?
	SLong WindowPtr		;your typical big picture window pointer
	SLong GWindowPtr	;"Gadgets" hires/menu screen
	SLong PaleGadPtr	;ptr to struct for 'palette request' gadgets
	SLong PrintGadPtr	;struct for printer "<- ## -> ok cancel" gads
	SLong SizerPtr		;struct for sizing gadgets
	SLong ToolWindowPtr
	SLong RastPortPtr	;RastPort for this window
	SLong WindowRastPort	;wd_RPort(WindowPtr)

	SLong XTScreenPtr
	SLong TScreenPtr
	SLong ScreenPtr
	SLong NewScreenPtr	;used for all, but usually for big pic (saved)
	SLong SkScreenPtr	;only by mousertns, for hires rgb#display
	SLong SkWindowPtr	;...ditto.

	SWord BigPicHt	;ScreenHeight

	SLong PaintRoutinePtr
	SLong PlaneSize ;number of bytes in a bitplane (8000 or 16000)

;the following values are set up as a long word
	SByte Pred	;values to plot, used by 'determine'
	SByte Pgreen
	SByte Pblue
	SByte Pjunk

 ;the following 5 bytes MUST be in this order
	SByte Predold	;actually seen values of pixel to left of one determine
	SByte Pgreenold
	SByte Pblueold
	SByte LastPlot	;Last plotted value (to the left)

	SByte Prederror	;difference (+/-) between 'determined' and wanted rgb
	SByte Pgreenerror
	SByte Pblueerror
	SByte Pjunkerror

	;insure the following values are set up at a long word
	SByte Transpred	;values to plot, used by 'determine'
	SByte Transpgreen
	SByte Transpblue
	SByte Transpjunk

	SLong DetermineRtn	;routine address, setup by InitDetermine()

	SByte FlagNeedGadRef	;need gadget refresh ;LONGWORD Aligned!
	SByte FlagRefProp	;need prop refresh
	SByte FlagRefHam	;need ham imagery refresh
	SByte FlagRefPtr	;need hires 'current brush' imagery

	;NOTE: flag circ,curv,rect,line must be LongWord aligned for drawb test
	SByte FlagCirc	;drawing circles
	SByte FlagCurv	;drawing curves
	SByte FlagRect	;drawing rectangular boxes
	SByte FlagLine	;drawing lines

	SByte FlagFlood		;floodfilling
	SByte FlagBSmooth	;connected brushes...no skipping

	SByte FlagNeedText	;need hires text display
	SByte FlagTextAct	;need text gadget activate

	SByte FlagCloseWB	;march09'89
	SByte FlagRedoLast	;lmarch09'89...tool.o, rehohires

	SByte MenuNumber
	SByte MenuItemNumber
	SByte MenuSubItemNumber
	SByte FlagGrayPointer ;april25....usecolormap only does hires gray loadrgb4

	SByte	FlagPrintRgb	;main.msg.i ref
	SByte	FlagPrintString	;main.msg.i ref
	SByte	FlagPrint1Value	;main.msg.i ref
	SByte	FlagPrintXY	;main.msg.i ref

	SByte FlagPrinting	;TRUE if "busy with printer"
	SByte FlagCapture	;print (capture) a-codes on stdout

	SLong TracePrintString	;adr for trace-out string print
	SLong PrintValue	;main.msg.i//gadgetrtns, trace out
	SLong linecol_offset	;offset to painting line, AND column

		;note: prev LONG forces long-align, MouseRtns.o usage
	SByte FlagRequest	;1="load palette/srhink/ok/cancel" "request" up
	SByte FlagSizer		;sizer gadgets displayed?
	SByte FlagOpen		;this,next together for test.W on FlagOpen
	SByte FlagSave

	SByte PrintCopies	;.BYTE size # copies (if not=0 then printing)
	SByte FlagPrintReq	;.BYTE set if "print req" displayed


	SByte FlagCDet		;"activates" createdetermine subr
	SByte FlagColorMap	;"activates" UseColorMap subr
	SByte FlagLine1stPt	;skip sup of 1st endpt in linedraw mode
	SByte FlagNew		;Project Menu Selections
	SByte FlagNeedHiresAct	;activate hires, mainloop, canceler.o ref
	SByte FlagNeedDirAct	;dir string gadget activate
	SByte FlagNeedMagnify
	SByte FlagNeedRepaint	;if he changes paint mode slider, continue
	SByte FlagNeedIntFix	;interlace fixzit, handle by msg code
	SByte FlagNeedMakeScr	;also handled by FixInterLace
	SByte FlagNeedShowPaste	;need another brush display
	SByte FlagNeedShowPal	;used with flagrefham
	;;;SByte FlagNeedScr	;need screen, mainloop calls openbigpic
	SByte FlagPaleMatch	;iffload.o, ComparePalette result, file=curt?
	SByte FlagRedrawPal	;used by/for openhamtools

	;;;SByte FlagDrag		;version 2 drag refers to bigpic dragging
	SByte FlagBrush 	;0=FILE loadsave	1=BRUSH loadsave
	SByte FlagBrushColorMode
	SByte FlagQuit
	SByte FlagText		;indicates 'text mode' for brush//cut subr's
	SByte FlagAgain 	;repaint on/off (1st or 'n'th time?)

	SByte FlagRub		;rubthru on/off global flag
	;MAY13;SByte FlagColorMode	;cutpaste.o/menuRtns
	SByte FlagSkipTransparency	;cutpaste.o/repaint.o/menurtns.o
	SByte FlagMagnify	;Bkgnd Menu Selections
	SByte FlagCheckBegMag	;may12'89
	SByte FlagCheckKillMag	;may11'89 LATE

	SByte FlagMagnifyStart	;=1, pointer is mag/glass, not yet mag'ing
	SByte FlagCutPaste	;=1 when cutting, carrying cutout/blit brush
	SByte FlagCut
	SByte FlagPick		;set when "button down on ham tools"
	SByte FlagDisplayBeep	;flags mainloop to flash hires (outta memory)
	SByte FlagAAlias	;same flag for stretching, text control
	SByte FlagEffects	;ANY effects at all? (stretch,mirror,etc)
	SByte FlagStretch	;set when 'brush warping' in effect
	SByte FlagColorZero	;set = ignore color zero
	;MAY13;SByte FlagPOnly		;set = palette colors only
	SByte FlagBitMapSaved	;set when UnDoBitMap is a "good clean clone"
	SByte FlagFilePalette	;0=use current pallette, 1=usenew from file

	SByte FlagSingleBit
	SByte PaintNumber

	;MAY12...not used?;SWord OSKillNest	;main.o; nest/unnest kill en/disable overscan
	SWord FlagRepainting ;why a WORD? ...dunno but it might bite if changed.
	SWord DispBrushNumber	;displayed brush # (pointers.o)
	SWord BrushNumber	;legal range 0..41 groups of 7=> -,|,\,/,Box,Circ
	SWord BrushSize	;0..6
	SWord BrushType	;0..6

	;rule#452: if circular stretching is set, regular stretching is also set
	;NOTE: WORD ALIGNED GROUPINGS FOLLOW
	SByte FlagHStretching	;Horizontal	stretching ON
	SByte FlagVStretching	;Vertical	stretching ON

	SByte FlagHShading	;Horizontal shading ON
	SByte FlagVShading	;Vertical	shading ON

	SByte FlagDither	;word align these two
	SByte FlagDitherRandom

	SByte FlagToolWindow ;set when we want to see menu&gadget screen
	SByte FlagLace
	SByte FlagLaceNEW	;for sizer (new screen in interlace?)
	SByte FlagWBench

	SWord LastCoordX	;...main.o tools.o showpallette.o(digits) gadgetrtns
	SWord LastCoordY

	SByte FlagPalette	;flag for palette load/save (not used?)
	SByte FlagPale		;palette gadgets
	SByte FlagCtrl		; slider gadgets
	SByte FlagCtrlText	;   text gadgets
	;SByte FlagSizer		;sizer gadgets displayed?

	SByte FlagLaceDefault	;MAY18....iffload, in case cant resize

	SByte FlagClip		;set when brush went of edge, for floodfill
	;;;SByte FlagHelp		;load alternate 'help' picture
	SByte FlagMenu		;set when intui' menu happening (main.msg)
	SByte FlagRemap		;set when need a remap
	SByte ShadeOnOffNum	;binary 0,1,2,3 for vert/hor on/offs
	SByte StretchOnOffNum	;binary 0,1,2,3 for vert/hor on/offs
	SByte LoadDepth	;iffload
	SByte FlagFirstLine	;used by anti-aliasing
	SByte FlagFont
	SByte FlagFontFirstTime	;used to 'cd fonts:' (showfreq.o)
	SByte FlagFoundKey	;main.key.i (only..scan keytable usage)
	SByte FlagHiBrush
	SByte FlagMaskOnly	;special drawing modes don't paint when set;JUNE88
	SByte FlagDotOnly	;like maskonly, for dots/brushes, circles/drawb
	SByte FlagCoord
	SByte FlagGadgetDown	;set/clrd by main.msg, used by apropointer
	SByte EffectNumber
	SByte FlagReSee
	SByte FlagWholeScreen
	SByte FlagFrbx		;routine ScreenArrange in GadgetRtns

	;JUNE05;SByte FlagForbid	;april18...in response to systembug?
	SWord FlagViewPage ;overscan 1 or 2
	SByte FlagXLef
	SByte FlagXRig
	SByte FlagXSpe
	;JUNE05;SByte MagnifyFactor_	;1=no mag, no use, 2,4,8 valid (domagnify.o)

		;the following 3 words are required for moveM's in do/drawbrush
	SWord MyDrawX	;our idea of where we are in current screen/brush pos
	SWord MyDrawY
	SWord BrushLineWidth_w

	SWord LastDrawX	;our idea of where we are in current screen/brush pos
	SWord LastDrawY

	SWord FlipWidth	;setup in BrushFx.o, used for 'rotate90's in doeffect.o
	SWord Pot0Temp	;THESE are temporary for sliders...
	SWord Pot1Temp
	;june22;SWord Pot2Temp
	;june22;SWord Pot3Temp
	SWord col_offset	;column offset
	SWord paint_width	;greatest paint width (strokebounds result)
	SWord halfpaint_width
	SWord v_extraleft	;leftside, for vert stretch MAY17
	SWord ppix_row_less1	;paint #pixels (groups of 32)
	SWord pwords_row_less1	;#longwords (-1) from 1st painted to last+3 JUNE
	SWord plwords_row_less1	;#longwords (-1) from 1st painted to last+3
	SLong SAStartRecord	;ADR OF 1st pixel's "record" inside savearray

	SLong RememberKey	;big daddie

	SLong EffectNamePtr	;warpname: real ascii ptr, frm menuitem ituitext
	SLong ExtraChipPtr	;main.o, memories.o, "extra" chip for openscreen
	SLong ModeNamePtr	;paintname:real ascii ptr, frm menuitem ituitext
	SLong KeyArrayPtr	;key/action codes (default.asm)
	SLong DescArrayPtr	;(x,y)(x,y) description (default.asm)
	SLong BlendCurvePtr	;256 byte size entries, 1 table 2ways (paintcode)

	SLong ActionCode	;psuedo ascii, code for 'what to do'

	SWord	DlvrLine	;line# on screen
	SWord	DlvrCount	;# of rgbs
	SLong	DlvrPtr		;array of count*6 words containing (r.w,g.w.b.w)

 SWord	MaxTick			;#vertb's between remagnifies
 SLong	RemagTick		;last 'tick time' we magnified (domagnify.o)
 SLong	RetextTick		;last 'tick time' we displayed text (showtxt.o)
 SLong  LastScrollTick		;last 'tick time' actually scrolled/checkcancel'd
 SLong	ShowPasteTick		;last 'tick time' we displayed text (showtxt.o)
 SLong	Ticker			;long size counter, decr 50x(pal) or 60x second
 SArray IntServer,IS_SIZE	;interrup server node struct (main.int.i,main.o)


define_bitmap:	MACRO	;name,#ofplanes{,name for bitplane adr table}
	SArray \1,bm_Planes	;bm_Planes=8, so lword align of array is ok	
	SArray \1_Planes,(8*4)	;8 long pointers
	endm

 ;define_bitmap ScreenBitMap	;BITMAPS MUST BE (blits.o) order'd scr/super/paste
 SArray ScreenBitMap,8		;bm_Planes
 SLong  ScreenBitMap_Planes	;1st bitplane adr
 SArray SBMPlane1,(4*7)		;table of 2nd..8th bitplane addrs

 define_bitmap UnDoBitMap
 define_bitmap PasteBitMap
 define_bitmap AltPasteBitMap	;other, 'swap' brush
 define_bitmap PasteMaskBitMap
PMBM_Planes_	equ	PasteMaskBitMap_Planes_
	xdef PMBM_Planes_

 define_bitmap CPUnDoBitMap,6
 define_bitmap SwapBitMap,6
 define_bitmap DoubleBitMap,6
 define_bitmap CusPtr_BitMap,1
 define_bitmap BB_BitMap,1
BB1Ptr_	equ	BB_BitMap_Planes_
	xdef	BB1Ptr_
 define_bitmap Spec2Way_BitMap,4 ;bgadrtns.o, bitmap struct for "grab image blit"

	SWord StartDrX		;x,y pair, MOUSE COORDS, center of circle
	SWord StartDrY
	SWord EndDrX		;x,y pair
	SWord EndDrY

	SWord BrushGrabX
	SWord BrushGrabY

	SLong LastM_Window

	SWord RStartDrX		;x,y pairs; SORTED FOR RECTANGLE
	SWord RStartDrY
	SWord REndDrX
	SWord REndDrY

	SWord DeadY	;dead brush, need to clear this y,ht in screenbitmap
	SWord DeadHt

	SWord NormalWidth	;workbench size, adjust for non-intlace lores
	SWord NormalHeight

	SWord NewSizeX		;managed by sizer.o routines
	SWord NewSizeY
	SWord DefaultX		;sizer...."revert" fields...
	SWord DefaultY		;...contain size of 'undo' or default

	SWord ElliXFact		;ellipse x factor (like "aspect")
	SWord ElliYFact
	SLong ElliXRadius	;ellipse "radius"
	SLong ElliYRadius	;ellipse "radius"
	SLong ElliRadiusSq	;**2,squared

	SLong CircRadius	;circle vars
	SLong CircRadiusSq	;**2,squared
	SLong line_offset	; number of bytes to start of this line
	SWord XAspect		;10=lores, 20=lores i'lace (never 5 medres)

	SWord first_x		;strokeb.o
	SWord last_x		;strokeb.o
	SWord BrushX_w		; "MyDrawX" being used/incremented
	SWord BrushWidth_Count
	SWord MaxBit
	SWord SaveMaxBit
	SLong fraction_long_red
	SLong fraction_long_green
	SLong fraction_long_blue

	SWord line_x
	SWord line_y

	SLong MagnifyAdrOffset ;DoMagnify.asm
	SWord MagnifyOffsetX
	SWord MagnifyOffsetY
	SWord MagXShift		;leftedge offset

	SLong random_seed
	SWord first_line_y
	SWord last_line_y
	SWord stXMidPoint	;Stretching vars
	SWord stYMidPoint
	SWord stRatioA
	SWord stRatioB
	SWord stretx_fac	;for gadget quick display
	SWord strety_fac
	SWord tempVknob		;stretching knob value
	SWord tempHknob
	SWord lineAE
	SLong lineAE2		;squared 
	ShortandLong lineAB	;int.frac
	SWord lineCF
	SWord lineBE
	SWord lineBF
	ShortandLong XIntercept
	ShortandLong YIntercept
	SWord Quadrant	;1,2,3,4...really only need a byte "~but~..."...
	SWord XMidPoint
	SWord fx_left
	SWord fx_right

	SLong AreaBufferPtr	;list of endpts (4bytes per...)
	SLong AreaBufferLen
	SLong AreaVectorPtr	;list of endpts (*5*bytes per...)
	SLong AreaVectorLen	;.long
	SLong AreaChunk		;ptr to alloc'd (9 bytes per...) REAL MEMORY
	SLong AreaChunkLen

	SLong TempGain	;stretching use, gain pot
	SWord TileX
	SWord TileY
	;SWord ThisAAliasX
	;SWord ThisAAliasY
	;SWord LastAAliasX
	;SWord LastAAliasY
	;june05
	SLong ThisAAliasX
	SLong ThisAAliasY
	SLong LastAAliasX
	SLong LastAAliasY

	SWord StretchGain
	SWord StretchGainAlt	;'alt', here, means the 'not' of stretchgain
	SWord StretchHPot	;clone value from horizontal blend of 2way
	SWord StretchVPot	;clone value from vertical blencd of 2way
	SWord Strleftblank	;#pixels leftside skip, stretch source bitmap

	SWord line_y1
	SWord line_y2
	SWord paste_x
	SWord paste_y
	SWord paste_width	
	SWord paste_height	
	SWord paste_leftblank	;#pixels before 1st masked pixel in a brush
	SWord paint_leftside	;ONLY USED BY REPAINT, sup by Paste
	SWord paste_offsetx	;subtract these from 'pointer' for brushtopleft
	SWord paste_offsety
	SWord altpaste_leftblank	;#pixels before 1st masked pixel in a brush
	SWord altpaste_offsetx	;subtract these from 'pointer' for brushtopleft
	SWord altpaste_offsety
	SWord altpaste_width
	SWord altpaste_height
	SWord paste_clipy	;#lines of top of scr

	SWord paste_shift	;when re-painting, starts@mod32, shift to 'real'
	SWord save_display_x	
	SWord save_display_y	
	SWord last_paste_x	
	SWord last_paste_y	
	;MAY15;SWord pixel_count	;maybe not wanted? (only in cutpaste now?)
	SWord ThisX
	SWord ThisY
	SWord ScrollSpeedX
	SWord ScrollSpeedY
	;JULY07;SWord HamPasteExtraLeft	;may11'89...see cut/cutpaste.o

	SByte FlagCutShading	;cutpaste.o only
	SByte CutFlagPaste	;cutpaste.o only

	SLong	LoResMask	;bitplane, mask for brush, normally paste-7th
	SLong	HiResMask	;hires/'realtime anti-alias" mask bitplane


 SArray PropSettings,((4*2)*4)	;4 entries per, 4 tables

; SArray HiresColorTable,(19*4)	;64
; SArray HamToolColorTable,(19*4)	;64
; SArray BigPicColorTable,(64*4)

 SArray HiresColorTable,(19*2)
 SArray HamToolColorTable,(19*2)
 SArray BigPicColorTable,(64*2)

 	;iconstuff
	SLong diskobject
	SLong brite_error
	SWord brite_meddk
	SWord brite_lite
	SWord brite_dark
 SArray brighthist,(16*4)

 SArray SwapBitMap_RP,rp_SIZEOF
 SArray CusPtr_BitMap_RP,rp_SIZEOF
 SArray	PasteRastPort,rp_SIZEOF
 SArray TextMask_RP,rp_SIZEOF
 SArray PrintRastPort,rp_SIZEOF		;PrintRtns.o, dummy rport for printer
 SArray ScreenBitMap_RP,rp_SIZEOF 	;"extra" used by DoMagnify
 SArray DoubleBitMap_RP,rp_SIZEOF 	;"extra" used by cutpaste

 SArray FillAreaInfo,ai_SIZEOF	;newflood/cutpaste
 SArray FillTmpRas,tr_SIZEOF

 SArray BottomRowAscii,84		;nice'nlong,80bytes+nullnullnullnull
 ;SWord OF_String			;dc.b '  '=two ascii spaces
 SArray LS_String,12	;dc.b 'Open Failed',0	LS_String MUST follow OF_String

	;Requesters.asm
 SArray DirnameBuffer,32+2 ;48
 SArray DirsaveBuffer,32+2 ;48	;last dir name displ'...for cmp w/ user input
 SArray	BigStringUnDo,80	;"doubles" as text string buffer
 SArray FilenameBuffer,32+2 ;70
 SArray ProgramNameBuffer,32+2 ;60
 SArray ListImage,20	;ig_SIZEOF ;image struct for ListGadget (filename prop)
 SArray HVShadingBUPImage,20	;ig_SIZEOF, image struct for 2way 'coverup'
 SArray HVStretchingBUPImage,20	;ig_SIZEOF, image struct for 2way 'coverup'
 SArray TextAttr,8
 SArray FontNameBuffer,32+2 ;60
	SLong TextFont	;current (if non-zero, needs to be closefont'd)
	SLong DiskFont	;current (if non-zero, needs to be remfont'd)
	SLong FontSeg	;ptr to loadseg'd font



	;repaint/alternate (for shading)
	SLong CenterAdjust_l

	SLong MScreenPtr	;magnify screen
	SLong MWindowPtr	;a 'big window' on magnify screen
	SLong MCBWindowPtr	;close box on magnify screen

	SLong MagnifyTablePtr	;2k table, expanded bytes (domagnify.o)
	SLong ShortMulTablePtr	;setup/managed in memories.o, used by paintcode
	SLong DetermineTablePtr
	SLong BriteTablePtr


 SArray MagRgbArray,(50*4) ;25 rgbs for lores, 50 for interlace magnify leftside

 SArray MyIODRPReq,iodrpr_SIZEOF ;printer io request
 SArray CONSOLEReq,iodrpr_SIZEOF ;console dev io requ for consolebase grab



 SArray BigNewScreen,32	;ns_SIZEOF	;main.o

; SArray TempNewWindow,64	;?only REALLY need 48 nogoodreasonnotrustcount?
;BigNewWindow_	equ	2+TempNewWindow_	;offshort SHORT WORD ALIGNED?
;	xdef BigNewWindow_
  SArray BigNewWindow,64	;APRIL11'89

;startof iffload vars

	SLong abort_fsave_stack
	SWord fsaving_height
	SWord savebytes_row
	SByte savesuccess
	SByte FlagError

	SLong FormDataPos
	SLong FormLength
	SLong ChunkName
	SLong ChunkLength
	SLong CAMG		;digipaint current/saves to file
	SLong FileCAMG		;always the last "read from file" value
	SByte FlagHamFile
	SByte FlagHires		;LATE JUNE 88 ....fixes lots, helps lots...

; fields used by ReadBody

	SLong ldlineoffset	;byte # for start of current line
	SWord pxnumber_w
	SWord ldline_w		;current line number
	SWord filebpr		;number of bytes per row in the file
	SWord filebpr_less1	;number of bytes per row in the file
	SByte mask_b		;ds.b 1 ;bit# in byte

	SLong PicFilePtr	;hp.gads, the entire file, in memory, (default.o)
	SWord GadSkipLines	;#lines in gadget picture file to skip
	SWord HiresDispLines	;showgads.o, #lines on hires
	SWord PicFileLines	;showgads.o, #lines on hires//file
	SByte PicFileDepth	;3 or 4 a must, since using color#s 1..7
	SByte CurrentFrameNbr	;so no redisplay of menu, autorequest bkgrnds

	SLong StdOut	;may01, shortens 'main' code...

  ;older(already ok in use)IFFLoad vars
	SLong FileHandle	;these 3 in this order, movem before dos call
	SLong FileBufferPtr
	SLong BufferLen

	SWord BufferCount

	SWord LoadPlane_pixels	;how many pixels we can handle (or want?)
	SLong LoadPlanesLen	;len of ALL
	SLong LoadPlane0Ptr
	;SLong HelpBufferPtr	;default.o use, help picture file
	;SLong HelpBufferLen

	SLong Buffer4	;FileRtns
 SArray FileColorTable,(64*4)	;used for holding rgb's from file if we dont
				;...change palette for displaying this picture
;endof iffload vars

;dirrtns vars
	SLong LastItemAddress	;gadgetrtns,dirrtns use for filename str's
	SLong DirNameLen	;main.cmd.i, really...
	SLong ProgNamePtr	;main.cmd.i, if from cli
	SWord ProgNameLen

	SLong ProgDir		;dir lock for 'resources' tool/program dir
	SLong ProgDelDir	;lock 'to be deleted'
	SLong ProgRbrKey	;remember struct for filenames/dirgadget
	SLong ProgEntCt		;only need/use byte?

	SLong FontDir		;dos lock
	SLong FontDelDir
	SLong FontRbrKey	;remember struct for filenames/dirgadget
	SLong FontEntCt		;only need/use byte?

	SLong BrushDir		;dos lock
	SLong BrushDelDir
	SLong BrushRbrKey	;remember struct for filenames/dirgadget
	SLong BrushEntCt	;only need/use byte?


	SLong	LineEndsPtr	;iff alloc'd, array of longword (x.w,y.w) pairs
	SWord	NLines
	SWord	CurtLineEnd	;starts at 2nd entry (always have at least 2)
	SLong	LinePlanePtr	;PlaneSize, copy of 'line' mask

	SLong DeleteDirLock
	SLong DirRememberKey
	SLong CurrentRemember
	SLong ScrollAmount
	SLong ScrollGadget

	SByte EntryCount
	SByte EntryNumber
	SByte NewEntryNumber
	SByte FlagDirRead

	SArray DirItem,(fib_SIZEOF+3)	;ds.l ((fib_SIZEOF+3)/4)

;endof dirrtns vars

;Blits.o vars
	SWord brush_x
	SWord brush_y
	SWord newblit_height
	SWord newblit_width

 ifnd TIMEVAL
 STRUCTURE TIMEVAL,0
 ULONG   TV_SECS
 ULONG   TV_MICRO
 LABEL   TV_SIZE
  endc

  ifnd InputEvent
 STRUCTURE  InputEvent,0
   APTR  ie_NextEvent
   UBYTE   ie_Class
   UBYTE   ie_SubClass
   UWORD   ie_Code
   UWORD   ie_Qualifier
   LABEL ie_EventAddress
   WORD    ie_X
   WORD    ie_Y
   STRUCT  ie_TimeStamp,TV_SIZE
   LABEL   ie_SIZEOF
 endc

 SArray KeyBuffer,8	;see main.key.i, gadgetrtns, for rawkeycvt (only use 4?)
 SArray FakeIE,ie_SIZEOF		;input event, main.key.i
 SArray TopOFile,TOF_SIZEOF		;for file saving
 SArray CurtBriteTable,(4*16)		;=64 bytes for cur't color brite levels


; BMHD save fields (Bit Map HeaDer), used for file load decoding

	SWord bmhd_rastwidth	ds.w	1
	SWord bmhd_rastheight	ds.w	1
	SWord bmhd_rastx	ds.w	1
	SWord bmhd_rasty	ds.w	1
	SByte bmhd_nplanes	ds.b	1
	SByte bmhd_masking	ds.b	1
	SByte bmhd_compression	ds.b	1
	SByte bmhd_pad1		ds.b	1
	SWord bmhd_tpcolor	ds.w	1
	SByte bmhd_xaspect	ds.b	1
	SByte bmhd_yaspect	ds.b	1
	SWord bmhd_pagewidth	ds.w	1
	SWord bmhd_pageheight	ds.w	1

bmhd_RECORD_	eQu	bmhd_rastwidth_		;NOTE:equ'd to 1st field
	xdef bmhd_RECORD_
bmhd_SIZEOF_	eQu	bmhd_pageheight_-bmhd_RECORD_+2	;NOTE:the "+2" for word
	xdef bmhd_SIZEOF_

 SArray FakeActionMsg,(MN_SIZE+80+(6*1024))	;fake msg buildt in main.key.i


	;BIG NOTE: "extra SAVEARRAY leftside" mostly "dontcare" when fileloading


	;imaginary pixels on left on right edge, too, "softening"

 SArray PasteExtraLeft,(LEFTWIDTH*s_SIZEOF)	;160 pixels * 34bytes = 5,440
	SArray SaveMinusOne,s_SIZEOF ;"extra" imaginary pixel leftedge

 SArray SaveArray,(1024*s_SIZEOF)	;be grandiose, MAX WIDTH 1024
	SArray SavePlusOne,s_SIZEOF ;"extra" imaginary pixel rightedge

 SArray PasteExtraRight,(RIGHTWIDTH*s_SIZEOF)
	;'pasteextra'left/right are extra pixel records because...
	;