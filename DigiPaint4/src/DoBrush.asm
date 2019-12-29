* DoBrush.asm 	;INCLUDES ds:PaintCode.i.asm ds:DoBrushLine.1.asm
 NOLIST

	XDEF DoBrushLine
	XDEF DoBrushLine_Start	;1st time thru...
	XDEF InitBrushPaint	;april13'89...called by drawbrush

	include "ds:basestuff.i"
	include "exec/types.i"
	include "exec/nodes.i"	;LN_PRI  (dobrush.mask.i)
	include "ds:SaveRgb.i"
	include "windows.i"	;for hires brush (flaghibrush)

LCTareg equr a5	;same as basepage, usage is 'longcolortable' (WAS using a2)

	xref BB1Ptr_
	xref BigPicHt_
	xref BigPicWt_
	xref BigPicWt_W_
	xref BrushLineWidth_w_
	xref BrushWidth_Count_
	xref BrushX_w_		;"MyDrawX_(BP)" being used/incremented
	xref bytes_per_row_
	xref bytes_per_row_W_

	xref SwapBitMap_RP_
	xref SwapBitMap_Planes_	;for checking if 'really rub thru'
	xref DetermineRtn_
	xref DisplayedBlue_
	xref DisplayedGreen_
	xref DisplayedRed_
	xref FlagAAlias_
	xref FlagClip_		;set when brush went of edge, for floodfill
	xref FlagDither_	;needed by paintcode
	xref FlagHiBrush_	;for hires brush display (bgaddisp->drawb->here)
	xref FlagHShading_
	xref FlagVShading_
	;MAY23;xref FlagLace_
	xref FlagMaskOnly_
	xref FlagRub_
	xref FlagStretch_
	xref fx_left_
	xref fx_right_
	xref IntuitionLibrary_
	xref line_offset_	;number of bytes to start of this line
	xref line_y_
	;;;xref LongColorTable_	;Table of words repr. 16 color register shade values
	xref MyDrawX_		;starting point for 1 line brush draw
	xref MyDrawY_
	xref PaintNumber_	;used to test for SOLID
	xref Paintred_
	xref PaintRoutinePtr_
	xref PasteBitMap_RP_
	xref Pblueold_
	xref Pblue_
	xref Pgreenold_
	xref pixels_row_less1_W_
	xref Predold_
	xref Pred_
	xref random_seed_
	xref SaveArray_		;ds.b (32+4)*s_SIZEOF ;allow room for 32 pixels
	xref ScreenBitMap_Planes_
	xref UnDoBitMap_
	xref UnDoBitMap_Planes_
	xref WindowPtr_
	xref XMidPoint_
	xref YMidPoint_

colorxref	MACRO
	xref Paint\1_
	xref P\1_
	xref P\1old_
	xref fraction_long_\1_
   ENDM
	colorxref red
	colorxref green
	colorxref blue




InitBrushPaint:			;april13
	bsr	InitPaintRtn	;inside paintcode.i routine address
	bra	InitPaintPtr	;inside paintcode.i real-time prop stuff
	;rts



;note:bset/tst/clr...{dn,<ea>} is ALWAYs 4 cycles faster than {#n,<ea>}


	;(builds d0, given d1=offset,d2=bit#,A4=list of bitplane adr ptrs)
get_image_bit: MACRO	;bit# 
	move.l	(a4)+,a0
	btst	d2,0(a0,d1.L)
	beq.s	gsb_end\@ ;short branch, not taken is only 8 vs 10 cycles
	 ifle \1-2
		addq	#(1<<\1),d0	;4cycles?
	 endc
	 ifgt \1-2
		ori.b	#1<<\1,d0	;8cycles
	 endc
gsb_end\@:
	 ENDM

get_superb_pixel: MACRO	;uses d0 for	X
		;MAY18....need d2 for bitnumber (??)
	moveq	#7,d2
	sub.w	d0,d2	;last/bottom 3 bits of d2=correct bit#

		;may02'89...very important! flags are sup based on d0
	TST.W	d0	;MAY10'89.....flags were NOT sup on d0.WORD

		;may02'89...prevent "run off left edge" when cant find a color
	bpl.s	1$	;x ok?(horrors! ...another cycle-hoggin branch)
	moveq	#0,d0	;negative x? wha?...short out and use palette zero
	moveq	#0,d2	;bit# 0		;MAY18
	move.l	line_offset_(BP),d1	;MAY18
	bra.s	after_getpixel\@
1$
	move.l	d0,d1	;x
	asr.w	#3,d1	;x/8
	add.L	line_offset_(BP),d1	;offset +=	x / 8
;may18;	moveq	#7,d2
;may18;	sub.w	d0,d2	;last/bottom 3 bits of d2=correct bit#
	lea	 UnDoBitMap_Planes_(BP),a4
	moveq	#0,d0 ;n#%00111111,d0	;byte weir gonna build, partial to 1's
   get_image_bit 0
   get_image_bit 1
   get_image_bit 2
   get_image_bit 3
   get_image_bit 4
   get_image_bit 5
after_getpixel\@:
   ENDM	;get_superb_pixel

get_superb_quick:	MACRO	;'quick' means no leftedge/zero check MAY02'89
	tst.w	d0	;x neg?
	bpl.s	1$
	moveq	#0,d0	;palette zero
	moveq	#0,d2	;bit# 0		;MAY18
	move.l	line_offset_(BP),d1	;MAY18
	bra.s	after_Qgetpixel\@
1$

	moveq	#7,d2
	sub.w	d0,d2	;last/bottom 3 bits of d2=correct bit#
	move.l	d0,d1	;bit# = x
	asr.w	#3,d1	;x/8
	add.L	line_offset_(BP),d1	;offset +=	x / 8
	lea	 UnDoBitMap_Planes_(BP),a4
	moveq	#0,d0 ;n#%00111111,d0	;byte weir gonna build, partial to 1's
   get_image_bit 0
   get_image_bit 1
   get_image_bit 2
   get_image_bit 3
   get_image_bit 4
   get_image_bit 5
after_Qgetpixel\@:
   ENDM	;get_superb_quick

Get_Palette_Quick: MACRO	;color
	ifc '\1','red'
	move.b	0(LCTareg,OldPixel.w),(a6) ;s_red(a6)
        endc
	ifc '\1','green'
	move.b	1(LCTareg,OldPixel.w),s_green(a6)
        endc
	ifc '\1','blue'
	move.b	2(LCTareg,OldPixel.w),s_blue(a6)
        endc
   ENDM
Get_Palette: MACRO	;color
	andi.w	#15,OldPixel	;max of 16 registers
	add.b	OldPixel,OldPixel
	add.b	OldPixel,OldPixel	;*4 for long word mode addressing
        Get_Palette_Quick \1
   ENDM

OldPixel  EQUR d0


topedge_clip:
	st	FlagClip_(BP)
somerts:
	RTS

DoBrushLine_Start:
; xjsr DebugMe1
	tst.b	FlagHiBrush_(BP)
	bne.s	hibrush		;hires line only

	tst.b	FlagMaskOnly_(BP)
	bne.s	maskbrush

DoBrushLine:		;cycles, cycles, this is entrypoint for all
	tst.b	FlagHiBrush_(BP)
	beq.s	regbrush
hibrush:		;draw hires brush
	include "ds:DoBrush.hires.i"
	rts		;dobrushline,dobrushlinestart

regbrush:		;regular (nonhires) brush
	tst.b	FlagMaskOnly_(BP)
	beq	reallystart
maskbrush:
	include "ds:DoBrush.mask.i"
;;;;;; xref BestPen_W_
	RTS

reallystart:
		;APRIL13'89
	;bsr	InitPaintRtn	;inside paintcode.i
	;bsr	InitPaintPtr	;inside paintcode.i

	;NEW CLIPPING;args are MyDrawX_,Y,BrushLineWidth_w
	movem.w	MyDrawX_(BP),d0/d1/d2	;x,y,brushlinewidth
	tst.w	d0		;d0=x
	bpl.s	xlok
	add.w	d0,d2		;BrushLineWidth_w_(BP) ;reduce width
	bmi.s	clipleft
	bne.s	zerostart	
clipleft:
	tst.b	FlagFlood_(BP)
	beq	somerts
	moveq	#1,d2	;BrushLineWidth_(BP)
zerostart:
	moveq	#0,d0	;MyDrawX_(BP)
xlok:

	;d0=x, d1=y d2=wt (left clipped ok, now)

	move.w	BigPicWt_W_(BP),d3	;rt edge + 1
	cmp.w	d3,d0			;starting x
	bcs.s	notoffrt

	xref FlagFlood_
	tst.b	FlagFlood_(BP)
	beq	somerts
	move.w	d3,d0			;set x,wt to rt edge if flooding
	subq	#1,d0
	moveq	#1,d2
notoffrt:

	move.w	d0,d4	;left
	add.w	d2,d4	;+wt
	cmp.w	d3,d4	;wt/rt edge?
	bcs.s	allfitrt
	beq.s	allfitrt
	move.w	d3,d2	;width//rt edge+1
	sub.w	d0,d2	;-start x = new width
allfitrt:

; xjsr DebugMe2
	move.w	d2,BrushLineWidth_w_(BP)	;WIDTH re-adjusted
	move.w	d0,BrushX_w_(BP) ;'working' x

	tst.w	d1		;d1=mydraw y
	bmi	topedge_clip	;TOPEDGE CLIP
	cmp.w	BigPicHt_(BP),d1
	bcc	topedge_clip	;BOTEDGE CLIP

	;handles a brushline that  "runs into right side"
	move.w	d2,d0	;BrushLineWidth_w_(BP),d0
	addq.w	#4,d0	;allow for 3 cleanups and (1)beginning data tobe saved
	move.w	d0,BrushWidth_Count_(BP)

	move.w	d0,-(sp) ;BrushWidth_Count_(BP),-(sp)	;STACK NOW=width to workon

	;;;lea	LongColorTable_(BP),LCTareg
	lea	SaveArray_(BP),a6

	;Get this (x-1) Pixel's (r,g,b,lastplot) -> SaveArray_(BP)
	moveq	#0,d1
	move.w	MyDrawY_(BP),d1
	mulu	UnDoBitMap_(BP),d1	;bm_bytesperrow
	move.L	d1,line_offset_(BP)	;=offset in bitmap to curt line

	move.w	BrushX_w_(BP),d0
	asr.w	#3,d0			;x/8
	;;;; ONLY OFFSET TO LINE ;;;add.L	d1,d0			;line_offset_(BP),d0
	move.w	d0,s_PlaneAdr(a6)	;1st entry	;OFFSET WITHIN ROW
	moveq	#0,d0
	move.w	BrushX_w_(BP),d0	;WO!!!!!! BUG???? MAY04'89

	subq	#1,d0	;subtract 1 from byte, weir getting (rgbSaveArray_+s_LastPlot) of	X-1
	move.w	d0,BrushX_w_(BP)
	move.l	d0,d3		;"saved" x position for backtracking 1st time thru

	;For FIRST Pixel, get data from screen, for 2nd..go from superbitmap

	moveq	#0,d2		;MAY04'89....in case off leftedge, bitnum ok

	get_superb_pixel	;uses only d0,d2,a0  LEAVES A1 ALONE for table ptr

; xjsr DebugMe2

	move.b	d2,s_BitNumber(a6)	;"Mask"

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	IsColor	;>= 16? then it's a color

Get_Ham_All:	;get all ham modifiers
	move.b	OldPixel,d1
	add.b	OldPixel,OldPixel
	add.b	OldPixel,OldPixel
	move.l	0(LCTareg,OldPixel.w),(a6) ;s_red(a6)	;LCTareg=*LongColorTable
	move.b	d1,s_LastPlot(a6) 		;BUILD * SaveArray_(BP) *
	bra GetFirst_End

IsColor:	;find which color
	move.b	d0,s_LastPlot(a6)	;* BUILD SaveArray_(BP) *
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip off shade#, leave 2 bit color#
	subq.b	#2,d1
	bcs	Isblue	;color # 1
	bne	Isgreen	;color # 3	;(BRANCH COULD BE REDUNDANT)

***********************
*** 1st color found is red, look for blue & green *****
***********************

Isred:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,(a6) ;s_red(a6)	;save the actually seen value

redIsred:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel
	;Test_On_Screen	;set to palette # 0 if offscreen

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	redIsColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette green
        Get_Palette_Quick blue
	bra GetFirst_End
redIsColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	beq redIsred	;color # 2 (again)
	bcc redIsgreen	;color # 3	;(BRANCH COULD BE REDUNDANT)
 
*** found red 1st,then found blue, now look for green *******
redIsblue:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_blue(a6)	;save the actually seen value

redIsblueloop:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	redIsblueColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette green
	bra GetFirst_End
redIsblueColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bls redIsblueloop	;color #2 (again) or color #1
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_green(a6)	;save the actually seen value
	bra GetFirst_End

*** found red 1st,then found green, now look for blue *******
redIsgreen:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_green(a6)	;save the actually seen value

redIsgreenloop:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	redIsgreenColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette blue
	bra GetFirst_End
redIsgreenColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	beq redIsgreenloop	;color # 2 (again)
	bcs.s	redIsgreenGotblue	;color # 1
	bra redIsgreenloop	;color # 3	;(BRANCH COULD BE REDUNDANT)
redIsgreenGotblue:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_blue(a6)	;save the actually seen value
	bra GetFirst_End


***********************
*** 1st color found is green, look for red & blue *****
***********************

Isgreen:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_green(a6)	;save the actually seen value

greenIsgreen:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	greenIsColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette red
        Get_Palette_Quick blue
	bra GetFirst_End
greenIsColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bcs greenIsblue	;color # 1
	bne greenIsgreen	;color # 3	;(BRANCH COULD BE REDUNDANT)
 
*** found green 1st,then found red, now look for blue *******
greenIsred:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,(a6)	;s_red(a6)	;save the actually seen value

greenIsredloop:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	greenIsredColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette blue
	bra GetFirst_End
greenIsredColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bcc greenIsredloop	;color # 3 (green again)
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_blue(a6)	;save the actually seen value
	bra GetFirst_End

*** found green 1st,then found blue, now look for red *******
greenIsblue:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_blue(a6)	;save the actually seen value

greenIsblueloop:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	greenIsblueColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette red
	bra GetFirst_End
greenIsblueColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bne greenIsblueloop	;color # 3	;(BRANCH COULD BE REDUNDANT)
greenIsblueGotred:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,(a6) ;s_red(a6)	;save the actually seen value
	bra GetFirst_End




***********************
*** 1st color found is blue, look for red & green *****
***********************

Isblue:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_blue(a6)	;save the actually seen value

blueIsblue:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel
	;Test_On_Screen	;set to palette # 0 if offscreen

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	blueIsColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette green
        Get_Palette_Quick red
	bra GetFirst_End
blueIsColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bcs blueIsblue	;color # 1
	bne blueIsgreen	;color # 3	;(BRANCH COULD BE REDUNDANT)
 
*** found blue 1st,then found red, now look for green *******
blueIsred:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,(a6) ;s_red(a6)	;save the actually seen value

blueIsredloop:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	blueIsredColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette green
	bra GetFirst_End
blueIsredColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bls blueIsredloop	;color #2(again) or color #1
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_green(a6)	;save the actually seen value
	bra GetFirst_End

*** found blue 1st,then found green, now look for red *******
blueIsgreen:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,s_green(a6)	;save the actually seen value

blueIsgreenloop:	;Get last Pixel's 6 bit plotted current value
	subq.l	#1,d3	;X=X-1
	move.l	d3,d0	;X
        get_superb_pixel

	;if OLD pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	blueIsgreenColor	;>= 16? then it's a color
	;lea	LongColorTable_(BP),LCTareg	;table of 16 words representing RGB bits
        Get_Palette red
	bra.s	GetFirst_End
blueIsgreenColor:	;find which color
	move.b	d0,d1	;get pixel
	asr.b	#4,d1	;strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	bne blueIsgreenloop
blueIsgreenGotred:
	andi.b	#$F,d0	;strip of HAM color select, leave 4 bit shade
	move.b	d0,(a6) ;s_red(a6)	;save the actually seen value
	;;;	bra GetFirst_End







GetFirst_End:	;==========================================================
; xjsr DebugMe2

	;a6 -> SaveArray_(BP)
	;LCTareg -> LongColorTable_(BP)

	addq.w	#3,BrushWidth_Count_(BP)	;24apr88 allow for cleanups too
	;THIS loop gets pixel rgb values from backup/original/undo/UnDoBitMap

loop_get_savearray:
	move.l	(a6),s_SIZEOF(a6)	;copy SaveArray_(BP)(rgb) from current to next record
	lea	s_SIZEOF(a6),a6	;next record in SaveArray_(BP), make it current

	move.w	BrushX_w_(BP),d0
	addq.w	#2,d0		;increment-->next pixel +1 for rtedge test
	move.W	BigPicWt_W_(BP),-(sp)
	cmp.w	(sp)+,d0
	bcs.s	19$		;branch if this stroke fits on screen
	move.w	pixels_row_less1_W_(BP),d0
	ADDQ.W	#1,d0		;FEB 22'89 ....rt edge single pixel fix???
   19$:
	subq.w	#1,d0		;backout rightedge test
	move.w	d0,BrushX_w_(BP)	;BrushX_w_(BP) = BrushX_w_(BP) + 1
 ; get_superb_pixel
	moveq	#0,d2		;MAY04'89....in case off leftedge, bitnum ok
  get_superb_quick	;may02'89
	move.b	d0,s_LastPlot(a6)	;* BUILD SaveArray_(BP) * ( needed for restore3)
	SUB.L	line_offset_(BP),d1	;=offset WITHIN line
	move.w	d1,s_PlaneAdr(a6)	;* BUILD SaveArray_(BP) *
	move.b	d2,s_BitNumber(a6)	;* BUILD SaveArray_(BP) *

end_save_colors: MACRO	;---
	subq.w	#1,BrushWidth_Count_(BP)
	bne loop_get_savearray
   ENDM	;----

	cmpi.b	#16,d0
	bcc.s	save_ham_colors	;last is a color register
	move.l	d0,d1
	add.w	d1,d1
	add.w	d1,d1	;= col.reg. * 4 for index to LongColorTable_(BP)
	move.l	0(LCTareg,d1.w),(a6)	;copy (rgbj) from LCT into SaveArray_(BP)(r,g,b,LastP)
	move.b	d0,s_LastPlot(a6)
  end_save_colors
	bra.s	all_done_end_save_colors
save_ham_colors:

	;getoldrgb	;macro....get rgb fom 2ndlastplace in superbitmap
;;getoldrgb:	MACRO
	;movem.l	d0/d1/a0/a1/a3,-(sp)
	movem.l	d0/a3,-(sp)
	lea	UnDoBitMap_(BP),a3
	moveq	#0,d0
	move.w	BrushX_w_(BP),d0
	subq.w	#1,d0	;lastplace
	bcs.s	skipgetold
	moveq	#0,d1
	move.w	MyDrawY_(BP),d1
	xjsr	GetOldfromBitMap ; DESTROYS D0/D1/A0/A1 d0=x d1=y a3=bitmap
skipgetold:
	;movem.l	(sp)+,d0/d1/a0/a1/a3
	movem.l	(sp)+,d0/a3
	;;ENDM

	move.l	-s_SIZEOF(a6),(a6)	;copy OLD rgb into current rgb of SaveArray_(BP)
	move.b	d0,s_LastPlot(a6)
	cmp.b	#32,d0
	bcc.s	2$
	andi.b	#$0f,d0
	move.b	d0,s_blue(a6)
  end_save_colors
	bra.s	all_done_end_save_colors
2$	cmp.b	#48,d0
	bcc.s	3$
	andi.b	#$0f,d0
	move.b	d0,(a6) ;s_red(a6)
  end_save_colors
	bra.s	all_done_end_save_colors
3$	andi.b	#$0f,d0
	move.b	d0,s_green(a6)
  end_save_colors
all_done_end_save_colors:	;----

	;now weir done saveing BrushWidth + 4 pixels of info in SaveArray_(BP)


; xjsr DebugMe3

;THIS LOOP FLAGS OUR BRUSH PIXELS IN THE BRUSH SINGLE BITPLANE/BITMAP
;IT HAPPENS 'BRUSHWIDTH' TIMES

	lea	SaveArray_(BP),a6
	lea	s_SIZEOF(a6),a6	;point to first one (whisis2nd)
	move.l	BB1Ptr_(BP),a0	;bitmap we set bits in
	moveq	#0,d2		;clear upper bits, load Byte but use Word size
	move.w	BrushLineWidth_w_(BP),d3	;original width from caller rtn
	subq	#1,d3		;dbf loop counter

	bmi.s	skiploop	;MAY18

flagbrushbitloop:
	moveq	#0,d1
	move.w	s_PlaneAdr(a6),d1	;offset within line
	ADD.L	line_offset_(BP),d1	;=offset in bitmap to curt line

	move.b	s_BitNumber(a6),d2
	bset	d2,0(a0,d1.L)		;SET PIXEL IN BRUSH' SINGLE BITPLANE
	lea	s_SIZEOF(a6),a6		;point to SaveRGB for next one
	dbf	d3,flagbrushbitloop
skiploop:
; xjsr DebugMe4


;this loop calculates *painted* rgb values for 'brushwidth'
;...also calcs 'determine' for 3 cleanup pixels

	move.w	(sp),BrushWidth_Count_(BP) ;using STACKED width to workon

	lea	SaveArray_(BP),a6	;point to SaveRGB for this one
	move.l	(a6),Predold_(BP) ;s_red(a6),Predold_(BP)	;move our values to the system's values
	lea	s_SIZEOF(a6),a6	;point to SaveRGB for this one

	lea	-4(sp),sp	;allow room for a6:=SaveArray_(BP) ptr
plot_determine_pixels:	;----
	move.l	a6,(sp)

do_paint:
	moveq	#0,d2
	move.b	s_BitNumber(a6),d2
	moveq	#0,d1
	move.w	s_PlaneAdr(a6),d1	;offset within line
	ADD.L	line_offset_(BP),d1	;=offset in bitmap to curt line
	move.l	BB1Ptr_(BP),a0		;brush stroke bitplane
	btst	d2,0(a0,d1.L)		;point 'on' in 'brush bitmap'?
	bne.s	yes_do_paint

	;move.l	(a6),Predold_(BP)	;we already plotted, use these colors

	;;;;may02;moveq	#0,d0		;flag zero means no paintcode
	;bra	go_recalc	;already_plotted
go_recalc:
		;CALL DETERMINE for 'unpainted' cleanup pixel
	move.l	(a6),Pred_(BP)		;s_red(a6)...old colors
	move.l	DetermineRtn_(BP),a0
	jsr	(a0)
	move.b	d0,s_LastPlot(a6)	;save 6bits to plot (paletteor ham'mod)
	bra	diddeterm

yes_do_paint:

	tst.b	FlagRub_(BP)	;defined in Main, set in MenuRoutines
	bne.s	19$	

18$	move.b	DisplayedRed_(BP),s_Paintred(a6)
	move.b	DisplayedGreen_(BP),s_Paintgreen(a6)
	move.b	DisplayedBlue_(BP),s_Paintblue(a6)

	bra.s	end_of_rub_thru
19$
	tst.l	SwapBitMap_Planes_(BP)	;any swap/rubthru  picture?
	beq.s	18$			;nah...bum mode
	movem.l	d0/d1/a0/a1,-(sp)	;prob'ly not needed

	move.l	Predold_(BP),-(sp)
	moveq	#0,d0
	move.w	BrushX_w_(BP),d0	;current ending pixel	X location
	sub.w	BrushWidth_Count_(BP),d0	;where we are now (x)....(really.)
	subq	#3,d0

	move.w	BigPicWt_W_(BP),-(sp)
	cmp.w	(sp),d0		;compare "where we are" again "right side"
	bcs.s	1$
	move.w	(sp),d0		;use rightside pixel	;MAYBE WANT EXT.L?
	subq	#1,d0
1$:	lea	2(sp),sp

	moveq	#0,d1
	move.w	MyDrawY_(BP),d1	;y, of course
	lea	SwapBitMap_RP_(BP),a3	;assume (its gotta be) from main window
	xjsr	GetOld			;find the P(rgb)old at this point

	;move.l	Predold_(BP),Paintred_(BP)	;move P(rgbj)old -> Paint(rgb)
	move.w	Predold_(BP),s_Paintred(a6)
	move.b	Pblueold_(BP),s_Paintblue(a6)

	move.l	(sp)+,Predold_(BP)	;04/29/87;
	movem.l	(sp)+,d0/d1/a0/a1	;prob'ly not needed
end_of_rub_thru:
  LIST


	;NOTE: we didn't do any horizontal/vertical s_{Hor,Ver}Pixel cals

	include "ds:paintcode.i"	;PAINT CALCULATIONS

  NOLIST
		;CALL DETERMINE + SAVE 'BESTPEN' FOR QUICKDRAW
	move.l	(a6),Pred_(BP)
	move.l	DetermineRtn_(BP),a0
	jsr	(a0)
	move.b	d0,s_LastPlot(a6)	;save 6bits to plot (paletteor ham'mod)

	and.w	#$3f,d0	;6bit plot value
	cmp.b	#16,d0
	bcc.s	diddeterm		;only use palette colors for 'bestpen'
	move.w	d0,BestPen_W_(BP)	;for 'next' time inner loop
;	bra.s	diddeterm

diddeterm:
	lea	s_SIZEOF(a6),a6	;point to SaveRGB for next one
	subq.w	#1,BrushWidth_Count_(BP)
	bne plot_determine_pixels	;----
	lea	4(sp),sp		;unlink room for a6:=SaveArray_(BP) ptr

	lea	SaveArray_(BP),a6	;point to first one weir plot
	lea	s_SIZEOF+s_LastPlot(a6),a6	;point to first one weir plot

	move.w	(sp)+,d5 ;BrushWidth_Count_(BP)	;deSTACK width to workon
	subq	#1,d5			;DBF TYPE LOOP
	bmi.s	skipplot	;MAY18
	moveq	#0,d2

; xjsr DebugMe5

	move.l	BP,-(sp)		;STACK
	MOVE.L	line_offset_(BP),-(sp)	;STACK offset to start of "this" line
	movem.l	ScreenBitMap_Planes_(BP),a0-a5	;prepare for FastPlot
	;note: a6 -> s_LastPlot inside of SaveArray_(BP) SaveRgb structure
continue_plotting:	;-----
	moveq	#0,d0
	move.b	(a6),d0	;what to plot (s_LastPlot)
	moveq	#0,d1
	move.w	s_PlaneAdr-s_LastPlot(a6),d1	;byte # FROM START OF PLANE (s_PlaneAdr)
	;ADD.L	line_offset_(BP),d1
	ADD.L	(sp),d1
	move.b	s_BitNumber-s_LastPlot(a6),d2	;bit # in byte (S_BitNumber)
	xjsr	FastPlot_GotAdr		;22 jsr, 16 RTS, ~200 for routine
	lea	s_SIZEOF(a6),a6	;point to SaveRGB for next one (allow for 3skip)
	dbf	d5,continue_plotting	;---
	lea	4(sp),sp		;deSTACK, clup space for line_offset_
	move.l	(sp)+,BP		;deSTACK
skipplot:
;; xjsr DebugMe9

	;lea	(-s_LastPlot)(a6),a6	;correct our pointer for the next routine

  RTS	;dobrushline
 END
