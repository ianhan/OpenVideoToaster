* DoEffect.asm	;stretching, pixelize, blur, mirror-flipx, rotate+/-90
	;0 (none)
	;1 Sizing (strecth)
	;2 Blur (add up/avg pixels in "mod x,y (sliders)" groupings
	;3 Mirror (flip left/right ONLY)
	;4 Rotate PLUS
	;5 Rotate MINUS
	;6 '3d perspective'
	;7 RANGE PAINT ... digipaint pi, this is an "effect", now...
	;8 Blur2

  xdef DoEffect
  xdef AntiAlias

	include "ram:mod.i"
	include "ps:basestuff.i"
	include "exec/types.i"
	include "ps:savergb.i"
	include "graphics/gfx.i"
	include "gadgets.i"

	xref ClipLeftLo_	;line#s where brushstroke was ENTIRELY clipped
	xref ClipLeftHi_	;...used by DoBrush.o and DoEffect.o(flooding)
	xref ClipRightLo_	;...cleared by rtn ClearBrushMask in StrokeB.o
	xref ClipRightHi_

	xref AltPasteBitMap_
	xref altpaste_leftblank_
	xref altpaste_width_
	xref BB_BitMap_
	xref FlagAAlias_,FlagDither_,FlagFlood_,FlagRub_
	xref FlagHStretching_,FlagVStretching_
	xref FlagMaskOnly_	;USED TO TELL ANTI-ALIAS SUBR TO IGNORE MASK
	xref FlipWidth_	;setup in BrushFx.o, used for 'rotate90's in doeffect.o
	xref LastAAliasX_,LastAAliasY_
	xref lineAE_,lineBE_
	xref lineBF_,lineCF_
	xref line_y_	;CAREFUL! This is really an internal var to RePaint
	xref paste_height_	;paint pi
	xref paste_leftblank_
	xref paste_width_
	xref MaxBit_
	xref PasteBitMap_
	xref ppix_row_less1_	;#pixels to paint (scan, actually)
	xref Predold_
	xref Quadrant_
	xref SAStartRecord_	;1st pixel's "record" inside savearray
	xref SaveArray_
	xref StretchHPot_,StretchVPot_
	xref StretchGain_
	xref Strleftblank_	;#pixels leftside skip, stretch source bitmap
	xref stXMidPoint_,stYMidPoint_
	xref UnDoBitMap_
	xref SwapBitMap_
	xref TextMask_RP_
	xref ThisAAliasX_,ThisAAliasY_
	xref ThisX_,ThisY_
	xref TileX_,TileY_
	xref XAspect_
	xref XIntercept_,YIntercept_

	xref first_line_y_
	xref line_y_		;LINE_Y_ represents current working y
	xref last_line_y_
	;xref FlatY_

	xref BB1Ptr_		;brush mask
	xref PasteBitMap_Planes_
	xref linecol_offset_	;offset to savearray start pixel in bitmap

;NOTE: re: savergb.i use s_stfx_top s_stfx_bottom as left, right old x,y <<5

;Quadrant	equr	d5
PixelsPerRow	equr	d6
Dtemp		equr	d7

times11:	MACRO	;register (lo word valid, top word clear)
	move.l	\1,Dtemp	; 4
	asl.l	#3,Dtemp	;14cy *8
	add.l	\1,Dtemp	; 8   *9
	add.l	\1,\1		; 8   *2
	add.l	Dtemp,\1	; 8   =*11 total cy=54 vs 78 for mulu #11,\1
				;54-12=42cy vs 78 original
		ENDM

divide: MACRO	;\3=\1 / \2	; destroys Dtemp  (could use d2,d5 no need?)
	move.w	\2,Dtemp	;"divided by" qty
	;NOV90;beq.s	errsethi\@
	beq.s	errsetzero\@	;NOV90
	BPL.S	DVP1\@
	NEG.W	Dtemp
DVP1\@:
	moveq	#0,\3
	move.w	\1,\3	;result
	BPL.S	DVP2\@
	NEG.W	\3
DVP2\@:	swap	\3		;256*256

	divU	Dtemp,\3
	bvc.s	eamd\@		;overflow cleared means divided ok
errsethi\@:
	;NOV90;move.w	#$7fff,\3	;*RIGHTSIDE BUG* ? NOV90
	moveq	#-1,\3	;rightside bug fixed? NOV90
	bra.s	eamd\@		;NOV90
errsetzero\@:	;NOV90
	moveq	#0,\3
eamd\@:

	ENDM	;divide

CHECKSETUP:	MACRO	;(args d0=x d1=y a3=bm_planes)
	move.w	d1,d4	;copy of Y for working byte address
	mulu	bm_BytesPerRow-bm_Planes(a3),d4	;y*rowsize
	moveq	#0,d3	;clear upper word
	move.w	d0,d3	;d3=copy of x for BYTE
	asr.w	#3,d3	;x/8
	add.L	d3,d4
	moveq	#7,d2	;prep for...
	sub.w	d0,d2	;d2=bit # in byte (+junk >7, ignored in  bXXX.b opcode)
  ENDM

CHECKMASK:	MACRO	;(destroys d2/d3/d4/a0)  (args d0=x d1=y a3=bm_planes)
	CHECKSETUP
	move.l	(8*4)(a3),d3	;7th (mask) bitplane
	move.l	(10*4)(a3),d3	;9th (mask) bitplane
	bne.s	ckmsk\@		;yep, check this mask bitplane
	moveq	#-1,d3		;sets 'ne' 'notZERO' flag
	bra.s	eack\@		;no mask plane? work as if mask bit set
ckmsk\@:
	move.l	d3,a0
;SEP201990;eack\@:
	btst	d2,0(a0,d4.L)
eack\@:
  ENDM



STARTaLOOP:	MACRO
	move.l	SAStartRecord_(BP),\1	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),\2
	ENDM

DoEffect:	;D0 = EFFECT NUMBER(ARG for this subr)
	cmpi.b	#1,D0
	beq.s	dostretch
	cmpi.b	#2,D0
	beq	doblur
	cmpi.b	#3,D0
	beq	domirror
	cmpi.b	#4,D0
	beq	dorotateplus
	cmpi.b	#5,D0
	beq	dorotateminus
	;cmpi.b	#6,D0
	;beq	doperspectivepaint
	;cmpi.b	#7,D0
	;beq	dorangepaint	;inside of paintcode.i ...

	cmpi.b	#8,D0	;blur 2 effect #
	beq	doblur2 ;;	;KLUDGE...old code still work???;;;doblur2

	rts	;bra	Endof_Effects

dostretch:	;SHAPING/WARPING ETC
		;Determine SOURCE bitmap (set a4 ptr) for stretching...
	moveq	#0,PixelsPerRow		;register equate
	move.L	#-1,LastAAliasX_(BP)	;flag last a-a coord negative=1st time
	move.L	#-1,LastAAliasY_(BP)	; = last x,y ("leftside" of us...)

	st FlagMaskOnly_(BP)	;SET when "nomask" (assume "no mask")

	tst.b	FlagRub_(BP)		;force use of rub screen when on
	beq.s	str_notrub
	lea	SwapBitMap_(BP),a4	;alternate/swap screens bitmap's rastport
	clr.w	Strleftblank_(BP)	;no leftside on swap scre
	tst.l	bm_Planes(a4)		;do we have an 'brush'?
	bne.s	str_usebitmap	;str_gotsource
str_notrub:
	sf	 FlagMaskOnly_(BP)	;SET when "nomask" (assume "no mask")

	lea	AltPasteBitMap_(BP),a4	;swap brush, just use it if there...
	move.w	altpaste_width_(BP),PixelsPerRow
	;beq.s	str_useundo		;undo screen is source if not alt
	beq.s	str_nalt
	move.w	altpaste_leftblank_(BP),Strleftblank_(BP)
	tst.l	bm_Planes(a4)		;have an alternate?
	bne.s	str_gotsource
str_nalt:
	lea	PasteBitMap_(BP),a4	;custom brush, just use it if there...
	move.w	paste_leftblank_(BP),Strleftblank_(BP)
	move.w	paste_width_(BP),PixelsPerRow
	beq.s	str_useundo		;undo screen is source if not alt
	tst.l	bm_Planes(a4)		;do we have an 'brush'?
	bne.s	str_gotsource

str_useundo:
	st	FlagMaskOnly_(BP)	;SET when "nomask" (assume "no mask")
	lea	UnDoBitMap_(BP),a4	;otherwise use 'undo' of current screen
	clr.w	Strleftblank_(BP)	;(oops, nobody ELSE clears this) JUNE24
str_usebitmap:
	move.w	(a4),PixelsPerRow ;bm_BytesPerRow(a4),PixelsPerRow	;=PixelsPerRow/8

		;MAR91...limit to 752 width
	cmp.w	#752+1,PixelsPerRow
	bcs.s	1$
	move.w	#752,PixelsPerRow
1$:

	asl.W	#3,PixelsPerRow		;=pixels per row (really, without >>3)
str_gotsource:	;"PixelsPerRow" (register equate) valid

		;compute x,y midpoints  "midpoint" = "1st pixel# on 2nd half"
	asl.W	#4,PixelsPerRow 	;14cy; all calcs done <<4 when possible
	move.W	PixelsPerRow,d3
	mulu	StretchHPot_(BP),d3	;midpoint = int.frac = center*MaxBit
	swap	d3			;HEY! ! ! really NEED A LongXLong mul?
	move.w	d3,stXMidPoint_(BP)	;midpoint in terms of source image (<<4)

	move.w	bm_Rows(a4),d3
	asl.W	#4,d3
	mulu	StretchVPot_(BP),d3	;midpoint adjusted by stretch hv pot
	swap	d3			; Vertical Knob Ctr (i.e., point 'B')
	move.w	d3,stYMidPoint_(BP)	;valu stored is <<4

	clr.L	LastAAliasX_(BP)	;1st time sup these values(?)
	clr.L	LastAAliasY_(BP)

	tst.b	FlagHStretching_(BP)
	beq.s	justvert
	tst.b	FlagVStretching_(BP)
	bne.s	twoway
	xjsr	HStretching
	sf	FlagMaskOnly_(BP)
	bra	Endof_Effects
justvert
	tst.b	FlagVStretching_(BP)
	beq.s	noway
	xjsr	VStretch ;VStretching
	sf	FlagMaskOnly_(BP)
	bra	Endof_Effects
noway:				;"never noway"...always h, or v, or both
twoway:

	STARTaLOOP a6,d1
	addq.w	#1,d1		;=#pixels per row// #pixels to scan
	move.w	d1,-(SP)	;STACK, shaping LOOP counter


Shaping_LOOP:
	tst.b	s_PaintFlag(a6)		;check if "this" pixel 2b painted?
	bne.s	shapethisone
	lea	s_SIZEOF(a6),a6		;CAREFUL! this is hand code to
	subq.w	#1,(sp)	;loop		;...resemble end of shaping loop
	bne.s	Shaping_LOOP
	bra	endof_Shaping_LOOP
shapethisone:

	move.w	#2+2,Quadrant_(BP)	;starting quadrant#  = bottom+rightside

	;COMPUTE 'RUN' = lineAE, quadrant=2 topside OR q=4 bottomside
	move.w	s_HorPixel(a6),Dtemp	;pixel#2Bpainted, not nec' # from left
	mulu	PixelsPerRow,Dtemp

;	xref FlagToast_			;AUG261990
;	tst.b	FlagToast_(BP)		;AUG261990
;	beq.s	123$			;ok...not in 1x mode...
;	add.w	Dtemp,Dtemp		;maxbit is "1/2 value" in 1x mode AUG261990
;123$
	divu	MaxBit_(BP),Dtemp		;/"#pixels 2 paint this row" (#p>=1)
	move.w	Dtemp,ThisX_(BP)		;=x in source bitmap,before stretch<<4
	sub.w	stXMidPoint_(BP),Dtemp 	;remember, xmidpt = '1st pt on 2ndhalf"
	move.w	Dtemp,lineAE_(BP)		;SIGNED VALUE in source bitmap <<4
	bge.s	21$			;rightside?
	;neg.w	Dtemp			;...keep it positive for squaring
	move.w	#1+2,Quadrant_(BP)	;quadrant# = leftside
21$:
	;COMPUTE 'RISE' = d1 = line BE
	move.w	s_VerPixel(a6),d1	;this y little terms, pixl#2Bpainted
	;add.w	d1,d1				;this*2		;OCTOBER1990
	;add.w	s_VerPixel-s_SIZEOF(a6),d1	;+last one	;OCTOBER1990
	;add.w	s_VerPixel+s_SIZEOF(a6),d1	;+next one	;OCTOBER1990

	ASL.w	#4,d1			;<<4 scaleit
	;;ASL.w	#4-2,d1			;<<4 scaleit (-2 OCTOBER90)
	mulu	bm_Rows(a4),d1
	move.w	s_MaxVerPixel(a6),Dtemp	;dtemp=max#pixels this column
	bne.s	ok2div
	moveq	#0,d1
	bra.s	donediv
ok2div	divu	Dtemp,d1	;d1=(this_y * ht_stretchbm / max#lines) <<4
donediv:

yedge:	move.w	d1,ThisY_(BP)		;this y before str in source bitmap <<4
	sub.w	stYMidPoint_(BP),d1	;<<4
	move.w	d1,lineBE_(BP) 		;SIGNED value <<4,len of vert littleline
	bge.s	31$
	sub.w	#2,Quadrant_(BP)	;quadrant....indicate TOPside (1-->3, 2-->4)
31$

;'Rise'=lineAE, 'Run'=lineBE Quadrant.1..4 
;                           +---------+--------+
;Quadrant 1 top   or left   |  1.     |        |
;Quadrant 2 top   or right  |         |  2.    |
;                           +---------B--------+
;Quadrant 3 bot   or left   |  3.     |        |  
;Quadrant 4 bot   or right  |         |  4.    |
;                           +---------+--------+
;separate quad rtns for lineCF,lineBF (outside rt triangle sides)

	;Quadrant 1 top   or left   |  1.     |        |
	cmpi.w	#1,Quadrant_(BP)	;D0=xintercept<<4
	bne.s	not_q1

	move.w	stXMidPoint_(BP),lineCF_(BP)		;<<4
	move.w	stYMidPoint_(BP),lineBF_(BP)		;<<4
	bra.s	endof_detquad

not_q1:	;Quadrant 2 top   or right  |         |  2.    |
	cmpi.w	#2,Quadrant_(BP)
	bne.s	not_q2
	move.w	PixelsPerRow,d4
	sub.w	stXMidPoint_(BP),d4
	move.w	d4,lineCF_(BP)		;<<4

	move.w	stYMidPoint_(BP),lineBF_(BP)		;<<4
	bra.s	endof_detquad

not_q2:	;Quadrant 3 bot   or left   |  3.     |        |  
	cmpi.w	#3,Quadrant_(BP)
	bne.s	not_q3
	move.w	stXMidPoint_(BP),lineCF_(BP)		;<<4

	move.w	bm_Rows(a4),d2	;source bitmap, #rows
	asl.w	#4,d2
	sub.w	stYMidPoint_(BP),d2
	move.w	d2,lineBF_(BP)	;<<4
	bra.s	endof_detquad

not_q3:	;Quadrant 4 bot   or right  |         |  4.    |
	move.w	PixelsPerRow,d4
	sub.w	stXMidPoint_(BP),d4 ;<<4
	move.w	d4,lineCF_(BP) ;<<4

	move.w	bm_Rows(a4),d2	;source bitmap, #rows
	asl.w	#4,d2
	sub.w	stYMidPoint_(BP),d2
	move.w	d2,lineBF_(BP)	;<<4
	;bra.s	endof_detquad

endof_detquad:	;after 'splitting up' per quadrant, all threads join here

	divide lineAE_(BP),lineCF_(BP),d0	;d0=lineAE/lineCF
	divide lineBE_(BP),lineBF_(BP),d1	;d1=lineBE/lineBF

	move.w	StretchGain_(BP),d4	;D4=CURVE RATIO FROM SLIDER
	beq.s	skipvc			;skip both h,v if no 'gain'
	moveq	#-1,d2
	eor.w	d4,d2			;D2=other half of '.ffff' fraction

	;tst.b	FlagHStretching_(BP)
	;beq.s	skiphc

	move.w	D0,d3	;our curve,16 bit 'ratio' line AB to CB
	mulu	d3,d3	;extreme curve, then we interpolate on d4 ;d1
	swap	d3	;SQUARED

	mulu	d2,D0	;amt of other, original, non-curve
	mulu	d4,d3 	;amt of curve
	add.l	d3,D0	;D0=TOTAL of weighted strtline + weighted curve
	swap	D0	;result now in bottom word of D0
;skiphc:
	;tst.b	FlagVStretching_(BP)
	;beq.s	skipvc
	;tst.w	d4 	;d4=StretchGain_(BP)=curve ratio from slider
	;beq.s	skipvc
	move.w	d1,d3 	;our curve,16 bit 'ratio' line AB to CB
	mulu	d3,d3	;extreme curve, then we interpolate on d4 ;d1
	swap	d3	;SQUARED

	mulu	d2,d1 	;amt of other, original, non-curve
	mulu	d4,d3 	;amt of curve
	add.l	d3,d1 	;D1=TOTAL of weighted strtline + weighted curve
	swap	d1	;result now in bottom word of D1
skipvc:

	;macro setup late october'90...fixes 'edge conditions...'
ENSUREPOSITIVE:	MACRO ;\1=register, flags set for .word size result
	bpl.s	ENS\@
	moveq	#0,\1
ENS\@:
		ENDM	



	;D0,D1 now are 16 bit 'ratios' representing distance from center
	;..knob in units of $0000..$ffff where $ffff is the maximum
	;..distance (distance to edge) along this vector

	cmpi.w	#2,Quadrant_(BP)
	bhi.s	ckqd3		;each quadrant routine ends with
	beq.s	ckqd2		;... d1=y ratio, d0=x ratio

	;QUADRANT 1: x leftside, y topside
	mulu	lineBF_(BP),d1
	add.L	#$07ffFF,d1		;round up, before negate, AUG301990 (<<4.long)
	neg.L	d1
	swap	d1
	add.w	stYMidPoint_(BP),d1
	ENSUREPOSITIVE D1		;OCTOBER'90

	mulu	lineCF_(BP),D0
	add.L	#$07ffFF,d0		;round up, before negate, AUG301990 (<<4.long)
	neg.L	D0
	swap	D0
	add.w	stXMidPoint_(BP),D0	;'a' again re-adjusted horiz
	ENSUREPOSITIVE D0		;OCTOBER'90
	bra.s	endof_quadstuff

ckqd2: 	;QUADRANT 2: x rightside, y topside
	mulu	lineBF_(BP),d1
	add.L	#$07ffFF,d1		;round up, before negate, AUG301990 (<<4.long)
	neg.L	d1
	swap	d1
	add.w	stYMidPoint_(BP),d1
	ENSUREPOSITIVE D1		;OCTOBER'90

	mulu	lineCF_(BP),D0
	swap	D0
	add.w	stXMidPoint_(BP),D0	;'a' again re-adjusted horiz
	ENSUREPOSITIVE D0		;OCTOBER'90
	bra.s	endof_quadstuff

ckqd3:	cmpi.w	#3,Quadrant_(BP)
	bne.s	ckqd4

	;QUADRANT 3: x leftside, y bottomside
	mulu	lineBF_(BP),d1
	swap	d1
	add.w	stYMidPoint_(BP),d1
	ENSUREPOSITIVE D1		;OCTOBER'90

	mulu	lineCF_(BP),D0
	add.L	#$07ffFF,d0		;round up, before negate, AUG301990 (<<4.long)
	neg.l	D0
	swap	D0
	add.w	stXMidPoint_(BP),D0	;'a' again re-adjusted horiz
	ENSUREPOSITIVE D0		;OCTOBER'90
	bra.s	endof_quadstuff

ckqd4:	;QUADRANT 4: x rightside, y bottomside
	mulu	lineBF_(BP),d1
	swap	d1
	add.w	stYMidPoint_(BP),d1
	ENSUREPOSITIVE D1		;OCTOBER'90

	mulu	lineCF_(BP),D0
	swap	D0
	add.w	stXMidPoint_(BP),D0	;'a' again re-adjusted horiz
	ENSUREPOSITIVE D0		;OCTOBER'90
	;bra.s	endof_quadstuff

endof_quadstuff: ;D0,d1 .w = x,y POSITIVE BUT <<4 (ZERO,NEG flags sup for d0)

	;TILE factors, how many 'repeats', TileX,Y stored as <<8
	mulu	TileX_(BP),D0	;resulting x,y are <<12 since x<<4 and Tile<<8
	mulu	TileY_(BP),d1

  ifc 't','f' ;JUNE04
	;NORMALIZE x,y (de-shift) since gonna lookup innabitmap
	roL.l	#4,D0	;does same as "ror.l #12,D0" ...eg >>12
	ADD.L	#$7fFF,d0	;round up x
	swap	D0		;d0='real' x in source bitmap

	roL.l	#4,d1		;...same rounding//shifting to y
	ADD.L	#$7fFF,d1
	swap	d1		;d1='real' y in source
  endc
	;;add.l	#$07f,d0	;round up bottom 8 bits
	;roR.l	#8,d0
	;;add.l	#$07f,d1	;round up bottom 8 bits
	;roR.l	#8,d1
	;june05late
	moveq	#8,d2
	roR.L	d2,D0	;d0>>8
	roR.L	d2,d1	;d1>>8


	tst.b	FlagAAlias_(BP)
	beq.s	endof_aalias
	bsr	AntiAlias	;anti-alias is a subr, not to be nice 
				;...but so not needlessly clobber '020 cache
	bra.s	gotold

endof_aalias:			;D0,1 .W = x,y

  ifc 't','f'	;JUNE04
	;CLIP on source boundaries
	move.w	bm_Rows(a4),d2
ckmul_y:			;ensure x is (modulo screenheight)
	cmp.w	d2,d1		;bm_Rows(a4),d1
	bcs.s	ckmul_xS
	sub.w	d2,d1		;bm_Rows(a4),d1
	bra.s	ckmul_y
ckmul_xS
	move.w	PixelsPerRow,d2	;HEY PPixelsPPerRRow is <<4
	asr.w	#4,d2		;ok, this is page/brush bitmap width
ckmul_x:			;ensure x is (modulo screenwidth)
	cmp.w	d2,D0		;PixelsPerRow (de-shifted)
	bcs.s	muldx_ok
	sub.w	d2,D0
	bra.s	ckmul_x
muldx_ok:
  endc

  IFC 't','f' ;NOVEMBER1990...no rounding...
		;June05
	roL.l	#8,d0
	add.l	#$07f,d0	;round up bottom 8 bits
	roR.l	#8,d0
	roL.l	#8,d1
	add.l	#$07f,d1	;round up bottom 8 bits
	roR.l	#8,d1
  ENDC ;IFC 't','f' ;NOVEMBER1990...no rounding...

	;CLIP on source boundaries
	move.l	#$00ffFFff,d2	;integer, mask for removing uppermost bits
	and.l	d2,d0	; (X) remove (rotated) 8 fractional bits
	and.l	d2,d1	; (Y) remove (rotated) 8 fractional bits
	moveq	#0,d2
	move.w	bm_Rows(a4),d2
ckmul_y:			;ensure x is (modulo screenheight)
	cmp.L	d2,d1		;bm_Rows(a4),d1
	bcs.s	ckmul_xS
	sub.L	d2,d1		;bm_Rows(a4),d1
	bra.s	ckmul_y
ckmul_xS
	move.w	PixelsPerRow,d2	;HEY PPixelsPPerRRow is <<4
	asr.w	#4,d2		;ok, this is page/brush bitmap width
ckmul_x:			;ensure x is (modulo screenwidth)
	cmp.L	d2,D0		;PixelsPerRow (de-shifted)
	bcs.s	muldx_ok
	sub.L	d2,D0
	bra.s	ckmul_x
muldx_ok:


	lea	8(a4),a3	;A3 is "pointer to 6 bitplane addrs" (a4=bitmap)
	add.w	Strleftblank_(BP),d0	;adjust X for source leftside
	CHECKMASK
	bne.s	reallylup	;have a mask bit set (or no mask plane)?
	move.l	s_red(a6),d2	;old, existing value (8bits/color)
	move.l	d2,Predold_(BP)
	bra.s	gotold
reallylup:
	;xjsr	QuickGetOldBM	;find the P(rgb)old at this point
	move.l	a4,a3		;bitmap ptr
	xjsr	GetOldfromBitMap	;find the P(rgb)old at this point

	;move.l	Predold_(BP),d2
	;ASL.L	#4,d2		;4bits<<4...8bit colors
	move.l	d0,d2	;april...getold returns 8 bit value in d0
gotold:
	move.B	s_effectbyte(a6),d2	;? preserve lastplot 6bit valu
	move.l	d2,s_Paintred(a6)	;move word&byte instead of long
	lea	s_SIZEOF(a6),a6
	subq.w	#1,(sp)		;loop index on stack ('long' time ago)
	bne	Shaping_LOOP
endof_Shaping_LOOP:

	lea	2(sp),sp	;loop counter...remove it
	sf	FlagMaskOnly_(BP)
	bra	Endof_Effects



***** subr for dostretch
aadither:	MACRO
	and.L	d3,d2	;#$00ff,d2	;8bit # only
	add.w	d2,d2
	add.w	d2,d2	;<<2, now 10bits (4int + 6frac)
	ADD.W	#60,d2	;dither UP (FIX for antia-alias getting too DARK)
	SUB.W	d4,d2	;dither thresh (per pixel)
	bpl.s	aad\@	;not 0 (or negative)
	moveq	#0,d2
	bra.s	aaz\@	;10cy
aad\@:	asr.w	#6,d2	;18cy (6+2n) remove fract bits
		;"sorry but do we need this?" "hu"  (Fri feb17'89@newtek)
	cmp.b	#16,d2
	bcs.s	aaz\@
	moveq	#15,d2
aaz\@:
	ENDM

AntiAlias:
	move.l	PixelsPerRow,-(sp)	;pixels per row equr'd d6
	moveq	#-1,d6			;set 'last used' values to 'illegal'
	move.L	d6,ThisAAliasX_(BP)
	move.L	d6,ThisAAliasY_(BP)

		;'roundup' to match non-anti routine (?) LATEST

	;JUNE05...only using s_stfx_top as .LONG (declared as word + "fx_bot")
	;NOTE: again,using s_stfx_top s_stfx_bottom as left, right old x,y <<5
	ROL.L	#5,D0	;retrieve just 5 fract bits (HAVE 8) THIS X
	ROL.L	#5,d1	;retrieve just 5 fract bits (HAVE 8) this y

		;JUNE05
	move.l	#$1FffFFff,d6	;integer, mask for removing 3 uppermost bits
	and.l	d6,d0	; (X) remove (rotated) 8 fractional bits
	and.l	d6,d1	; (Y) remove (rotated) 8 fractional bits

	;june05
	;moveq	#0,d6		;4cy
	;not.W	d6		;4cy=8cy total, D0=$0000ffff
	;and.l	d6,D0		;8 cy
	;and.l	d6,d1		;8 cy (NOTE: swap,clr.w,swap=12cyc total, too.)
	;moveq	#0,d5
	;moveq	#0,d6
	move.L	LastAAliasX_(BP),d5 ;<<5
	move.L	LastAAliasY_(BP),d6 ;<<5 ;d5,d6 = last x,y ("leftside" of us...)

	; D0,d1 = new/current x,y
	move.L	D0,LastAAliasX_(BP)	;save these for next guy...
	move.L	d1,LastAAliasY_(BP)	;...they'll represent "leftside"

	; use s_stfx_(top,bottom)(a6) as pixel "aboveside" us
	tst.b	s_dummy(a6)	;flag clr'd by scratch.o/repaint/clearsavearray
	bne.s	notfirst
	st	s_dummy(a6)	;flag for 1sttime anti-alias
use_newpt:
	;move.w	d1,d6		;use same Y valu on 1st line
	move.L	d1,d6		;use same Y valu on 1st line JUNE05
	bra.s	allcont
notfirst:
	;move.w	s_stfx_bottom(a6),d6	;ONLY GRAB ABOVESIDE y (use leftside x)
	move.L	s_stfx_top(a6),d6	;ONLY GRAB ABOVESIDE y (use leftside x)
	;bpl.s	allcont			;feb27'89....tiling+antialiasing anomaly JUNE05
	;;move.w	d1,d6			;if it was "-1", then use cur't y
	;move.L	d1,d6		;use same Y valu on 1st line JUNE05
	;june05
	bmi.s	use_newpt	:june05
allcont
	;move.w	D0,s_stfx_top(a6)	;save current for next row's "aboveside"
	;move.w	d1,s_stfx_bottom(a6)	;NOTE: only using 'y' fer now?
	move.L	d1,s_stfx_top(a6)	;ONLY SAVING "last y" as .LONG

	;tst.w	d5	;lastx, flagged as 'minus' in main loop
	tst.L	d5	;lastx, flagged as 'minus' in main loop
	bpl.s	doinga
	move.l	d1,d6	;lasty = thisy
	move.l	d0,d5	;ditto for x
doinga:
	;;exg.l	d5,d0	;AUG311990
	;;exg.l	d6,d1	;....go the 'other way'....

		;old x,y averaged with current...AUG311990
	add.l	d0,d5
	asr.l	#1,d5	;>>1, 1/2 distance (1 pixel, total)
	add.l	d1,d6
	asr.l	#1,d6

	sub.L	d6,d1 	;this(d0,d1)-last(d5,d6) leaves diff(d0,d1)
	sub.L	d5,D0

	;add.l	d0,d0	;diff*2, cross through current...AUG311990
	;add.l	d1,d1
	;add.l	d0,d0	;diff*4, cross through current...AUG311990 (???)
	;add.l	d1,d1
		;diff=diff*3, lines up ok, then...(?)...AUG311990
	movem.l	d0/d1,-(sp)
	add.l	d0,d0
	add.l	(sp)+,d0
	add.l	d1,d1
	add.l	(sp)+,d1

	;	;AUG301990...clean up 'down right shift' because of a-alias coords
	;	;a-alias 'center' s/b on this//current pixel,
	;	;...the following code corrects for this (?)
	;movem.l	d0/d1,-(sp)	;yech, but want 'original' values...
	;asr.L	#1,d0	;diffs/2, for 1/2 the total distance
	;asr.L	#1,d1
	;add.L	d0,d5	;adj starting x (old//last value) so we end up on current
	;add.L	d1,d6	;adj starting y, also...
	;movem.l	(sp)+,d0/d1	;yech, but want 'original' (non-halved) values...

	clr.L	-(sp)		;ALLOC stack room for 'rgb' total
			;note: not using stack, using alternate basepage-field
	xref AAred_
	xref AAgreen_
	xref AAblue_
	moveq	#0,d7
	move.w	d7,AAred_(BP)
	move.w	d7,AAgreen_(BP)
	move.w	d7,AAblue_(BP)

	move.L	d1,-(sp)	;STACK diff
	move.L	D0,-(sp)	;STACK diff 0,2=diffx,y 4,6=lastx,y 8.l=rgb
	rol.l	#4,d5		;<<4 for a total of 9
	rol.l	#4,d6		;...save diff, working #s are *16
	moveq	#16-1,d7	;dbf loop
aalias_loop:
	add.L	(sp),d5		;incr x note: incr 1st, so we end
	add.L	4(sp),d6	;incr y ...on our 'current' x,y
	move.l	d5,D0		;curt x <<9
	move.l	d6,d1		;curt y <<9

	;asr.L	#5,D0	;D0,d1 shifted total of 9>>
	;asr.L	#5,d1	;note:these are really 'long's
	;asr.L	#4,D0	;...cant get around 2shifts (?) per reg
	;asr.L	#4,d1	;...because want "asr quality" of shifting sign bits
	;JUNE05
	moveq	#9,d2
	asr.L	d2,D0	;D0,d1 shifted total of 9>>
	asr.L	d2,d1	;note:these are really 'long's

	;D0,D1 = x,y Get Old now
	lea	ThisAAliasX_(BP),A0	;"varptr"
	lea	ThisAAliasY_(BP),a1
	cmp.L	(A0),D0			;same X as last time did 'gotold'?
	bne.s	getoagain		;nope, get another
	cmp.L	(a1),d1			;same Y as last time did 'gotold'?
	;beq.s	hadold			;yep....skipit now, we had same X, too.
	beq.s	uselast			;yep....skipit now, we had same X, too.
getoagain:
	move.L	D0,(A0)	;ThisAAliasX_(BP)
	move.L	d1,(a1)	;ThisAAliasY_(BP)


	;CLIP on source boundaries
	divu	bm_Rows(a4),d1	;/maxrow+1
	clr.w	d1
	swap	d1
	move.L	12(sp),d2	;pix per row
	asr.w	#4,d2		;un-shift it
	divu 	d2,d0		;/max col+1
	clr.w	d0
	swap	d0		;use remainder after division


	lea	8(a4),a3	;A3 is "pointer to 6 bitplane addrs" 

	add.w	Strleftblank_(BP),d0	;adjust X for source leftside
	tst.b	FlagMaskOnly_(BP)	;SET when "nomask"
	bne.s	reallyAlup
	CHECKMASK ;OK TO USE D3,D4 for TEMPORARIES?
	bne.s	reallyAlup	;have a mask bit set (or no mask plane)?
	move.l	s_red(a6),d2

	ASR.L	#4,d2		;march'90...using 4 bit (not 8 bit backgd?)
	AND.L	#$0f0f0f00,d2
	move.B	s_red+3(a6),d2	;restore "lastplot" (?)

	move.l	d2,Predold_(BP)		;old, existing value

	move.l	s_red(a6),d2	;8 bits per color, again

	bra.s	gotAold

uselast:
	move.l	8(sp),d2	;temp....red.BYTE,gr.b,blu.b, misc.b
	bra.s	gotAold

reallyAlup:
	;xjsr	QuickGetOldBM	;find the P(rgb)old at this point (saves d5,6,7)
	move.l	a4,a3		;bitmap ptr
	;DECEMBER1990;xjsr	GetOldfromBitMap	;find the P(rgb)old at this point
	xjsr	GetOldRGBBitMap	;find the P(rgb)old at this point DECEMBER1990
;hadold:
	;move.l	Predold_(BP),d2	;"result" of getold "readpixelrgb"
	;asl.l	#4,d2		;8 bit colors
	move.l	d0,d2	;april...getold returns 8 bit value in d0
gotAold:
	;clr.B	d2		;d2.L = 4bitred.byte 4g.b 4b.b 0.b
	;add.L	d2,8(sp)	;'save up' total of "rgb"s

	move.l	d2,8(sp)	;temp....red.BYTE,gr.b,blu.b, misc.b
	moveq	#0,d2

	;move.b	0+8(sp),d2
	;SWAP	d2		;red to upper word...add.W	d2,AAred_(BP)
	;move.b	1+8(sp),d2
	;;add.W	d2,AAgreen_(BP)
	;add.L	d2,AAred_(BP)
	;move.b	2+8(sp),d2
	;add.W	d2,AAblue_(BP)
	;JUNE02,1990
	move.b	0+8(sp),d2
	add.W	d2,AAred_(BP)	
	move.b	1+8(sp),d2
	add.W	d2,AAgreen_(BP)	
	move.b	2+8(sp),d2
	add.W	d2,AAblue_(BP)	

	dbf	d7,aalias_loop

	lea	8(sp),sp	;kill our 2 long vars, increments

	tst.W	FlagDither_(BP)	;either dither?
	bne.s	doditheraa
	move.l	(sp)+,d2	;rgb * 16 (INVALID...want AA(rgb)_(BP)
	;;not for 24bit paint
	;;asr.l	#4,d2		;/16=rgb+
	;;and.l	#$0f0f0f00,d2	;cleanitup first
	bra.s	endof_dither
doditheraa:

	;d5 ok to use, not used again 'till after shaping_loop gets underway
	;d3 also ok, gets blown by 'getold' call
	moveq	#1,d5	;temporary constant for 'aadither' macro
	swap	d5	;...value is #$00010000
	moveq	#0,d3	;another temporary constant for 'aadither' macro
	not.B	d3	;move.w	#$00ff,d3

  IFC 't','f' ;not for 24bit paint no mo'...save "detail"
	moveq	#0,d4
	move.b	s_DitherThresh(a6),d4
	moveq	#0,d2
	move.b	(sp),d2		;red
	aadither
	move.b	d2,(sp)

	move.b	1(sp),d2	;green
	aadither
	move.b	d2,1(sp)

	move.b	2(sp),d2	;blue
	aadither
	move.b	d2,2(sp)
  ENDC
	move.l	(sp)+,d2	;rgb 'dithered down'

endof_dither:
	move.l	(sp)+,PixelsPerRow	;pixels per row equr'd d6

	move.w	AAred_(BP),d2
	asr.w	#4,d2
	move.w	d2,AAred_(BP)	;now 8 bits, was 12

	move.w	AAgreen_(BP),d2
	asr.w	#4,d2
	move.w	d2,AAgreen_(BP)	;now 8 bits, was 12

	move.w	AAblue_(BP),d2
	asr.w	#4,d2
	move.w	d2,AAblue_(BP)	;now 8 bits, was 12

	move.W	AAred_(BP),d2
	asl.W	#8,d2
	add.W	AAgreen_(BP),d2	;red.byte, green.byte
	swap	d2
	move.w	AAblue_(BP),d2
	asl.W	#8,d2		;red.b, gr.b, blu.b, misc0.b

	RTS	;AntiAlias





;***************
flipbyte:	macro	;\1,\2
	addx.b	\1,\1
	roxr.b	#1,\2
	addx.b	\1,\1
	roxr.b	#1,\2
	addx.b	\1,\1
	roxr.b	#1,\2
	addx.b	\1,\1
	roxr.b	#1,\2

	addx.b	\1,\1
	roxr.b	#1,\2
	addx.b	\1,\1
	roxr.b	#1,\2
	addx.b	\1,\1
	roxr.b	#1,\2
	addx.b	\1,\1
	roxr.b	#1,\2
  endm	;flipbyte	

domirror:
	;FLIP LEFT<->RIGHT CURRENT (BIGPIC) *MASK* LINE
	move.l	BB1Ptr_(BP),a1		;where FROM (brush bitplane)
	;adda.l	linecol_offset_(BP),a1	;point to current line

				;feb27'89
	move.w	line_y_(BP),d0		;this y
	xref ScreenBitMap_
	mulu	ScreenBitMap_(BP),d0	;*bytes per row
	adda.l	d0,a1			;"point" to current row in brush

	move.w	PasteBitMap_(BP),d0	;'pixels per row'
	bne.s	1$
	move.w	ppix_row_less1_(BP),d0
	addq.w	#1,d0
	asr.w	#3,d0	;pixels/8=#bytes to flip
1$

	move.l	a1,a6	;compute ending pixel+1 address
	add.w	d0,a6
	subq	#1,d0	;db' type loop
flipmask:	;a1=srcbyte a6+1=dest byte d0=#BYTES (=pixels/8) to flip
	move.b	(a1),d1
	flipbyte d1,d2		;d1 into d2 flipped
	move.b	-(a6),d1	;grab 2nd byte
	move.b	d2,(a6)		;save flipped 1st byte at 2nd's position
	flipbyte d1,d2
	move.b	d2,(a1)+	;save flipped 2nd @ 1st pos.
	subq	#1,d0
	dbf	d0,flipmask

		;flip screen or brush - horizontal -
	xref FlagToast_
  IFC 't','f' ;...no need, same flip loop for both scr and brush (?)
	tst.l	PasteBitMap_Planes_(BP)	;HAVE a brush?
	bne.s	dobrush_flip
	lea	SaveArray_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d0
	xref BigPicWt_W_
	move.w	BigPicWt_W_(BP),d0
	tst.b	FlagToast_(BP)
	beq.s	010$
	add.w	d0,d0		;"hires" width...
010$
	subq	#1,d0			;db' type loop

	move.w	D0,d1		;=#pixels-1
	mulu	#s_SIZEOF,d1	;size of each record in savearray (a6)
	lea	0(a6,d1.l),A0	;backward scan ptr:begin @last savearray record

scrflip_loop:	;scan all pixel records, copy to "opposite scan" fields
	move.l	(a6),s_Paintred(A0)	;1st one RIGHT to Left
	st	s_PaintFlag(a0)
	st	s_PlotFlag(a0)

	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray
	lea	-s_SIZEOF(a0),a0	;a0 backwards savearray
	dbf	d0,scrflip_loop
	bra	Endof_Effects
dobrush_flip:
  ENDC

	;FLIP LEFT<->RIGHT CURRENT  RGB (SAVEARRAY) LINE
	;STARTaLOOP A6,D0	;D0 for pixel counter, a6 for savearray
	lea	SaveArray_(BP),a6	;1st pixel's "record" inside savearray

	move.w	ppix_row_less1_(BP),d0
	tst.l	PasteBitMap_Planes_(BP)	;brush flip?
	beq.s	1$

	move.w	PasteBitMap_(BP),d0	;bytes per row to flip
	asl.w	#3,d0		;*8=#pixels
	tst.b	FlagToast_(BP)
	beq.s	010$
	add.w	d0,d0		;"hires" width...
010$
	subq.w	#1,d0
1$
	move.w	D0,d1		;=#pixels-1
	mulu	#s_SIZEOF,d1	;size of each record in savearray (a6)
	lea	0(a6,d1.l),A0	;backward scan ptr:begin @last savearray record

	;note: scratch should probably copy s_(rgb)(a6) --> s_Paint(rgb)(a6)
	;...for screen flips...

mxfloop:
	move.l	s_Paintred(a6),d1	;'paint'/brush colors
	move.l	s_Paintred(a0),d2

	tst.l	PasteBitMap_Planes_(BP)	;screen or brush?
	bne.s	flipbr
	move.l	(a6),d1	;rgb from 'background'
	move.l	(a0),d2
flipbr

	;move.l	d1,(a0)
	move.l	d1,s_Paintred(a0)
	st	s_PaintFlag(a0)
	st	s_PlotFlag(a0)

	;move.l	d2,(a6)
	move.l	d2,s_Paintred(a6)
	st	s_PaintFlag(a6)
	st	s_PlotFlag(a6)

	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray
	lea	-s_SIZEOF(a0),a0	;a0 backwards savearray
	SUBQ.W	#2,D0			;db'loop ctr ACCTs FOR (2) just swapped
	bcc.s	mxfloop
	bra	Endof_Effects

smoothcolor:	MACRO	;color_offset(0,1,2), dreg ;COMPUTE 16=9me+5left+2right
	moveq	#0,D1	;D1=TEMP
	move.b	\1(a6),D1	;  this 4 bit (not red)

		;using '1-2-1' for blurring...
	move.w	D1,\2			;current
	add.w	\2,\2
	;move.b	-s_SIZEOF+\1(a6),D1	;temp, leftside 8 bitter
	move.b	-s_SIZEOF+\1(a6),D1	;temp, leftside 8 bitter PAINT COLOR
	add.W	D1,\2			
	;BLUR BUG FIX, NO CREEP RIGHT, AUG011990;move.b	-s_SIZEOF+\1(a6),D1	
	;move.b	s_SIZEOF+\1(a6),D1	
	move.b	s_SIZEOF+\1(a6),D1	;PAINT COLOR
	add.W	D1,\2			
	asr.w	#2,\2			;/4='1'

		;why?....decrement color to be plotted...AUG011990
	cmp.W	#$0ff,\2	;...unless it's maximum brite
	beq.s	smc_max\@
	subq.b	#1,\2
	bcc.s	smc_max\@
	moveq	#0,\2
smc_max\@:

  ENDM	;smoothcolor;color offset, dreg


smoothcolor2:	MACRO	;color_offset(0,1,2), dreg ;COMPUTE 16=9me+5left+2right
	moveq	#0,D1	;D1=TEMP
	move.b	\1(a6),D1	;  this 4 bit (not red)

	;no...;	;using '1-2-1' for blurring...
		;using '5-6-5' for blurring...
	mulu	#6,d1	;KLUDGE,SPEEDUP
	move.w	D1,\2			;current
	;no...;add.w	\2,\2
	;move.b	-s_SIZEOF+\1(a6),D1	;temp, leftside 8 bitter
	moveq	#0,d1
	move.b	-s_SIZEOF+\1(a6),D1	;temp, leftside 8 bitter PAINT COLOR
	mulu	#5,d1	;KLUDGE,SPEEDUP
	add.W	D1,\2			
	;BLUR BUG FIX, NO CREEP RIGHT, AUG011990;move.b	-s_SIZEOF+\1(a6),D1	
	;move.b	s_SIZEOF+\1(a6),D1	
	moveq	#0,d1
	move.b	s_SIZEOF+\1(a6),D1	;PAINT COLOR
	mulu	#5,d1	;KLUDGE,SPEEDUP
	add.W	D1,\2			
	;no...;asr.w	#2,\2			;/4='1'
	asr.w	#4,\2

		;why?....decrement color to be plotted...AUG011990
	cmp.W	#$0ff,\2	;...unless it's maximum brite
	beq.s	smc2_max\@
	subq.b	#1,\2
	bcc.s	smc2_max\@
	moveq	#0,\2
smc2_max\@:

  ENDM	;smoothcolor;color offset, dreg

doblur:
	STARTaLOOP A6,D0	;D0 for pixel counter, a6 for savearray

	;JULY141990....grab "aboveside" and "belowside" pixel rgb values...

	xref col_offset_
	xref line_y_

	move.w	col_offset_(BP),d3
	asl.w	#3,d3			;=starting pixel#
	move.w	line_y_(BP),d4		;=current line

blurem:				;this loop "smears" vertically
;?;	tst.b	s_PaintFlag(a6)		;check if "this" pixel 2b painted?
;?;	beq	noblurhere		;AUG011990

	movem.L	d0-d4,-(sp)
	move.w	d3,d0		;d0=x
	move.w	d4,d1		;d1=y
	SUBQ	#1,d1		;...y-1
	bcc.s	1$
	moveq	#0,d1
;;;1$	lea	ScreenBitMap_(BP),a3
1$	lea	UnDoBitMap_(BP),a3

  IFD DEBUGGER
	movem.l	d0/a0,-(sp)
	move.l	d1,a0
	xjsr	debug_print_a0d0
	xjsr	debugCRLF
	move.w	d4,d0
	xjsr	debug_print_longword
	xjsr	debugCRLF
	movem.l	(sp)+,d0/a0
  ENDC
	xjsr	GetOldfromBitMap	;getold.asm

	;;move.b	3(a6),d0	;don't change 4th byte in record
	;;move.l	d0,(a6)	;CHANGE THIS....IMAGE SHOULD MOVE "DOWN"

;;  IFC 't','f' ;WANT,KLUDGEOUT,JULY181990
	move.l	d0,-(sp)	;STACK 1st/aboveside 8 bit color
	move.w	d3,d0		;d0=x
	move.w	d4,d1		;d1=y
	ADDQ	#1,d1		;...y+1
	xref BigPicWt_W_
	cmp.w	BigPicWt_W_(BP),d1
	bcs.s	12$
	move.w	BigPicWt_W_(BP),d1
	subq	#1,d1
12$
	lea	ScreenBitMap_(BP),a3
	xjsr	GetOldfromBitMap	;getold.asm
	move.L	d0,-(sp)

	moveq	#0,d1
	moveq	#0,d0
	move.b	(a6),d0	;this red
	add.W	d0,d0	;...*2
	move.b	(sp),d1	;belowside red
	add.w	d1,d0
	move.b	4(sp),d1
	add.w	d1,d0
	asr.w	#2,d0
	;move.b	d0,(a6)		;restave "vertical smoothed red"
	move.b	d0,s_LastPlot(a6) ;s_Paintred(a6)		;restave "vertical smoothed red"

	moveq	#0,d0
	move.b	1(a6),d0	
	add.W	d0,d0	
	move.b	1(sp),d1	
	add.w	d1,d0
	move.b	1+4(sp),d1
	add.w	d1,d0
	asr.w	#2,d0
	;move.b	d0,1(a6)	
	move.b	d0,s_effectbyte(a6)	;s_Paintgreen(a6)	

	moveq	#0,d0
	move.b	2(a6),d0	
	add.W	d0,d0	
	move.b	2(sp),d1	
	add.w	d1,d0
	move.b	2+4(sp),d1
	add.w	d1,d0
	asr.w	#2,d0
	;move.b	d0,2(a6)	
	move.b	d0,s_dummy(a6)	;s_Paintblue(a6)	


	addq.l	#8,sp		;remove (stacked) 2 long word temporaries

;;  ENDC
	movem.L	(sp)+,d0-d4
;?;noblurhere:
	addq.w	#1,d3		;x=x+1
	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray
	dbf	d0,blurem

	STARTaLOOP A6,D0	;D0 for pixel counter, a6 for savearray

		;don't mess up 1st, last pixels
	subq	#2,d0		;reduce loop count (1 for 1st, 1 for last)
	;;move.b	(a6),s_LastPlot(a6) 	;s_Paintred(a6)
	;;move.b	1(a6),s_effectbyte(a6)	;s_Paintgreen(a6)
	;;move.b	2(a6),s_dummybyte(a6)	;s_Paintblue(a6)
	;?;move.b	(a6),s_Paintred(a6)
	;?;move.b	1(a6),s_Paintgreen(a6)
	;?;move.b	2(a6),s_Paintblue(a6)
	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray

smoothem:			;this loops "smears sideways"
	;NOTE: using s_LastPlot for blurred red
	;            s_effectbyte for blurred green
	;            s_dummy for blurred blue
	tst.b	s_PaintFlag(a6)		;check if "this" pixel 2b painted?
	beq	skip_blur		;AUG021990

	smoothcolor s_LastPlot,d2
	move.b	d2,s_Paintred(a6)
	smoothcolor s_effectbyte,d2
	move.b	d2,s_Paintgreen(a6)
	smoothcolor s_dummy,d2
	move.b	d2,s_Paintblue(a6)
	bra.s	did_blur
skip_blur:
	move.b	(a6),s_Paintred(a6)
	move.b	1(a6),s_Paintgreen(a6)
	move.b	2(a6),s_Paintblue(a6)
did_blur:
	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray
	dbf	d0,smoothem

	;?;move.b	(a6),s_Paintred(a6)	;fixup LAST record, for plotting...
	;?;move.b	1(a6),s_Paintgreen(a6)
	;?:move.b	2(a6),s_Paintblue(a6)

	bra	Endof_Effects

dorotateplus:	;BRUSH EFFECT CODE...ROTATE 1 (horizontal result) LINE

	lea	PasteBitMap_(BP),a4	;custom brush
	tst.l	bm_Planes(a4)
	bne.s	1$
	lea	UnDoBitMap_(BP),a4	;'undo' picture if no brush
1$
	move.w	line_y_(BP),d0		;this y
	sub.w	first_line_y_(BP),d0	;d0=line# in source bitmap

	;digipaint pi....don't do aspect ratio...
	;;'grab x' is same for each pixel on line, = (y  *  11/xaspect)
	;mulu	#(11<<1),d0	;*11, <<1 for rounding
	;divu	XAspect_(BP),d0	;d0='grab x'<<1
	;asr.W	#1,d0		;>>1 to normalize after "rounding"
	ext.l	d0
	add.w	paste_leftblank_(BP),d0
	movem.l	d0/a4,-(sp)	;STACK 'grab x', 'source bitmap'

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	lea	(2*s_SIZEOF)(a6),a6	;third record, always, allows 3supcolors
	move.w	FlipWidth_(BP),PixelsPerRow
rotplus:
		;'grab y' = (backwardsX  *  xaspect/11)
	move.w	PixelsPerRow,d1	;pprow=backwards, anyway, since dbf loop
	;digipaint pi....don't do aspect ratio...
	;mulu	XAspect_(BP),d1
	;divu	#11,d1
	ext.l	d1		;D1='grab y'

	movem.l	(sp),d0/a4	;d0=grab x   a4=source bitmap ptr
	lea	8(a4),a3	;A3= "pointer to 6 bitplane addrs"
	st	s_effectbyte(a6)
	CHECKMASK
	sne	s_effectbyte(a6)	;set if mask, clear if no mask

	;xjsr	QuickGetOldBM		;get rgb values by scanning bitmap
	move.l	a4,a3		;bitmap ptr
	xjsr	GetOldfromBitMap	;find the P(rgb)old at this point

	;move.l	Predold_(BP),d2
	;;move.B	s_effectbyte(a6),d2	;? preserve lastplot 6bit valu
	;;move.l	d2,s_Paintred(a6)	;save (r.b,g.b,b.b,mask.b)
	;move.l	d2,(a6) ;s_red(a6)	;save (r.b,g.b,b.b,mask.b)
	;JUNE02,1990...get 'correct' color
	move.L	d0,(a6)	;8 bit colors, now, + "lastplot"
	move.b	3+s_Paintred(a6),d0	;s_effectbyte....save mask valu...
	move.L	d0,s_Paintred(a6)
	st	s_PaintFlag(a6)
	;?;st	s_PlotFlag(a6)	;AUG091990...;

		;SETUP NEW (rotated) MASK BIT
	moveq	#0,d0			;calc x,y in
	move.w	FlipWidth_(BP),d0
	sub.w	PixelsPerRow,d0		;d0=x in 'real' brush mask
	ADDQ.w	#2,d0			;leftside offset of 3, always, for sup
	move.l	BB1Ptr_(BP),a0		;brush bitplane
	adda.l	linecol_offset_(BP),a0	;a0 points to current line
	move.B	s_BitNumber(a6),d2	;bit#s always in savearray (nice!)
	asr.w	#3,d0		;d0=bytenumber

	tst.b	s_effectbyte(a6)	;was mask set in original?
	bne.s	setnewmask
clearnewmask:
	bclr	d2,0(a0,d0.w)		;clear mask bit in regular 1bitplaner
	bra.s	after_newmask
setnewmask:
	bset	d2,0(a0,d0.w)
after_newmask:
	lea	s_SIZEOF(a6),a6		;point to next pixel's record
	dbf	PixelsPerRow,rotplus

	movem.l	(sp)+,d0/a4

	bra	dup_1st_three	;end of effect, copy 3rd color to 1st 3
	;bra	Endof_Effects

dorotateminus:

;  xjsr DebugMe10
	lea	PasteBitMap_(BP),a4	;custom brush
	tst.l	bm_Planes(a4)
	bne.s	1$
	lea	UnDoBitMap_(BP),a4	;'undo' picture if no brush
;  xjsr DebugMe11
1$
;  xjsr DebugMe12
	;'grab x' is same for each pixel on line, = (y  *  11/xaspect)
	move.w	last_line_y_(BP),d0
	sub.w	line_y_(BP),d0	;'this' y reversed
	;digipaint pi....don't do aspect ratio...
	;mulu	#(11<<1),d0	;*11, <<1 for rounding
	;divu	XAspect_(BP),d0	;d0='grab x'<<1
	;asr.W	#1,d0		;>>1 to normalize after "rounding"
	ext.l	d0
	add.w	paste_leftblank_(BP),d0
	movem.l	d0/a4,-(sp)	;STACK 'grab x', 'source bitmap'

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	lea	(2*s_SIZEOF)(a6),a6	;third record, always, allows 3supcolors
	move.w	FlipWidth_(BP),PixelsPerRow
rotminus:
		;'grab y' = (REALX  *  xaspect/11)
	move.w	FlipWidth_(BP),d1
	sub.w	PixelsPerRow,d1
	;digipaint pi....don't do aspect ratio...
	;mulu	XAspect_(BP),d1
	;divu	#11,d1
	ext.l	d1		;D1='grab y'


	movem.l	(sp),d0/a4		;d0=grab x   a4=source bitmap ptr
	lea	8(a4),a3		;A3= "pointer to 6 bitplane addrs"
	st	s_effectbyte(a6)
	CHECKMASK
	sne	s_effectbyte(a6)	;set if mask, clear if no mask
;;  xjsr DebugMeTool

	;xjsr	QuickGetOldBM		;get rgb values by scanning bitmap
	move.l	a4,a3		;bitmap ptr
	xjsr	GetOldfromBitMap	;find the P(rgb)old at this point

	;move.l	Predold_(BP),d2
	;;move.B	s_effectbyte(a6),d2	;? preserve lastplot 6bit valu
	;;move.l	d2,s_Paintred(a6)	;save (r.b,g.b,b.b,mask.b)
	;move.l	d2,(a6) ;s_red(a6)	;save (r.b,g.b,b.b,mask.b)
	move.l	d0,(a6)	;s_red(a6) AUG061990
	move.b	3+s_Paintred(a6),d0	;s_effectbyte....save mask valu...
	move.L	d0,s_Paintred(a6)
	st	s_PaintFlag(a6)
	;?;st	s_PlotFlag(a6)	;AUG091990...;

		;SETUP NEW (rotated) MASK BIT
	moveq	#0,d0			;calc x,y in
	move.w	FlipWidth_(BP),d0
	sub.w	PixelsPerRow,d0		;d0=x in 'real' brush mask
	ADDQ.w	#2,d0			;leftside offset of 3, always, for sup
	move.l	BB1Ptr_(BP),a0		;brush bitplane
	adda.l	linecol_offset_(BP),a0	;a0 points to current line
	move.B	s_BitNumber(a6),d2	;bit#s always in savearray (nice!)
	asr.w	#3,d0			;d0=bytenumber

	tst.b	s_effectbyte(a6)
	bne.s	Msetnewmask
	bclr	d2,0(a0,d0.w)
	bra.s	Mafter_newmask
Msetnewmask:
	bset	d2,0(a0,d0.w)
Mafter_newmask:
	lea	s_SIZEOF(a6),a6
	dbf	PixelsPerRow,rotminus

	movem.l	(sp)+,d0/a4

dup_1st_three:	;called from 'rotate-plus' ends here, too
		;GRAB red, green,blue,xtrabyte from THIRD(1st) record

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.l	2*s_SIZEOF+s_red(a6),d0	;3rd pixel's paintcolors
	move.l	d0,s_red(a6)		;reset 1,2,3rd "colors to paint"
	move.l	d0,s_SIZEOF+s_red(a6)
	st	s_PaintFlag(a6)
	st	s_SIZEOF+s_PaintFlag(a6)
	st	2*s_SIZEOF+s_PaintFlag(a6)

	bra	Endof_Effects


doblur2:	;AUGUST051990

	STARTaLOOP A6,D0	;D0 for pixel counter, a6 for savearray

	;JULY141990....grab "aboveside" and "belowside" pixel rgb values...

	xref col_offset_
	xref line_y_

	move.w	col_offset_(BP),d3
	asl.w	#3,d3			;=starting pixel#
	move.w	line_y_(BP),d4		;=current line

blurem2:			;this loop "smears" vertically
;?;	tst.b	s_PaintFlag(a6)		;check if "this" pixel 2b painted?
;?;	beq	noblurhere		;AUG011990

	movem.L	d0-d4,-(sp)
	move.w	d3,d0		;d0=x
	move.w	d4,d1		;d1=y
	SUBQ	#1,d1		;...y-1
	bcc.s	1$
	moveq	#0,d1
;;;1$	lea	ScreenBitMap_(BP),a3
1$	lea	UnDoBitMap_(BP),a3

  IFD DEBUGGER
	movem.l	d0/a0,-(sp)
	move.l	d1,a0
	xjsr	debug_print_a0d0
	xjsr	debugCRLF
	move.w	d4,d0
	xjsr	debug_print_longword
	xjsr	debugCRLF
	movem.l	(sp)+,d0/a0
  ENDC
	xjsr	GetOldfromBitMap	;getold.asm

	;;move.b	3(a6),d0	;don't change 4th byte in record
	;;move.l	d0,(a6)	;CHANGE THIS....IMAGE SHOULD MOVE "DOWN"

;;  IFC 't','f' ;WANT,KLUDGEOUT,JULY181990
	move.l	d0,-(sp)	;STACK 1st/aboveside 8 bit color
	move.w	d3,d0		;d0=x
	move.w	d4,d1		;d1=y
	ADDQ	#1,d1		;...y+1
	xref BigPicWt_W_
	cmp.w	BigPicWt_W_(BP),d1
	bcs.s	12$
	move.w	BigPicWt_W_(BP),d1
	subq	#1,d1
12$
	lea	ScreenBitMap_(BP),a3
	xjsr	GetOldfromBitMap	;getold.asm
	move.L	d0,-(sp)

	moveq	#0,d1
	moveq	#0,d0
	move.b	(a6),d0	;this red
	mulu	#6,d0	;add.W	d0,d0	;...*2
	move.b	(sp),d1	;belowside red
	mulu	#5,d1	;add.w	d1,d0
	add.w	d1,d0
	moveq	#0,d1
	move.b	4(sp),d1
	mulu	#5,d1
	add.w	d1,d0
	asr.w	#4,d0	;#2,d0
	;move.b	d0,(a6)		;restave "vertical smoothed red"
	move.b	d0,s_LastPlot(a6) ;s_Paintred(a6)		;restave "vertical smoothed red"

	moveq	#0,d0
	move.b	1(a6),d0	
	mulu	#6,d0	;add.W	d0,d0	
	moveq	#0,d1
	move.b	1(sp),d1	
	mulu	#5,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	1+4(sp),d1
	mulu	#5,d1
	add.w	d1,d0
	asr.w	#4,d0	;#2,d0
	;move.b	d0,1(a6)	
	move.b	d0,s_effectbyte(a6)	;s_Paintgreen(a6)	

	moveq	#0,d0
	move.b	2(a6),d0	
	mulu	#6,d0	;add.W	d0,d0	
	moveq	#0,d1
	move.b	2(sp),d1	
	mulu	#5,d1
	add.w	d1,d0
	moveq	#0,d1
	move.b	2+4(sp),d1
	mulu	#5,d1
	add.w	d1,d0
	asr.w	#4,d0	;#2,d0
	;move.b	d0,2(a6)	
	move.b	d0,s_dummy(a6)	;s_Paintblue(a6)	


	addq.l	#8,sp		;remove (stacked) 2 long word temporaries

;;  ENDC
	movem.L	(sp)+,d0-d4
;?;noblurhere:
	addq.w	#1,d3		;x=x+1
	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray
	dbf	d0,blurem2

	STARTaLOOP A6,D0	;D0 for pixel counter, a6 for savearray

		;don't mess up 1st, last pixels
	subq	#2,d0		;reduce loop count (1 for 1st, 1 for last)
	;;move.b	(a6),s_LastPlot(a6) 	;s_Paintred(a6)
	;;move.b	1(a6),s_effectbyte(a6)	;s_Paintgreen(a6)
	;;move.b	2(a6),s_dummybyte(a6)	;s_Paintblue(a6)
	;?;move.b	(a6),s_Paintred(a6)
	;?;move.b	1(a6),s_Paintgreen(a6)
	;?;move.b	2(a6),s_Paintblue(a6)
	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray

smoothem2:			;this loops "smears sideways"
	;NOTE: using s_LastPlot for blurred red
	;            s_effectbyte for blurred green
	;            s_dummy for blurred blue
	tst.b	s_PaintFlag(a6)		;check if "this" pixel 2b painted?
	beq	skip_blur2		;AUG021990

	smoothcolor2 s_LastPlot,d2
	move.b	d2,s_Paintred(a6)
	smoothcolor2 s_effectbyte,d2
	move.b	d2,s_Paintgreen(a6)
	smoothcolor2 s_dummy,d2
	move.b	d2,s_Paintblue(a6)
	bra.s	did_blur2
skip_blur2:
	move.b	(a6),s_Paintred(a6)
	move.b	1(a6),s_Paintgreen(a6)
	move.b	2(a6),s_Paintblue(a6)
did_blur2:
	lea	s_SIZEOF(a6),a6		;a6 FORWARDS in savearray
	dbf	d0,smoothem2

	;?;move.b	(a6),s_Paintred(a6)	;fixup LAST record, for plotting...
	;?;move.b	1(a6),s_Paintgreen(a6)
	;?:move.b	2(a6),s_Paintblue(a6)

	;bra	Endof_Effects

Endof_Effects:

	rts





   END
