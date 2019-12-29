* Returns 8 bit values in d0= (red.b, green.b, blue.b, lastplot.b)

* GetOld.asm 	 ; assumes A3 = BITMAP -or- bm_Planes

BP	equr	a5
   XDEF GetOld ; DESTROYS D0/D1/A0/A1 d0=x d1=y a3=rastport
   XDEF GetOldfromBitMap ; DESTROYS D0/D1/A0/A1 d0=x d1=y a3=bitmap
 ;;  XDEF QuickGetOldBM	;destroys d0-d4,a0-a2, d0,1=x,y A3=bm_Planes ptr

;NOTE: using a5 for longcolortable (=1st var)
LCTareg	equr	a5

 ;;  xref LongColorTable_ ; table of words repr. 16 color register shade values
   xref Predold_
   xref Pgreenold_
   xref Pblueold_
   xref LastPlot_

   INCLUDE "exec/types.i"
   include "graphics/gfx.i"
   INCLUDE "windows.i"
;   INCLUDE "BETAxrefs_macros.i"

get_screen_bit: MACRO		;bit# (builds d0, gives d1=offset,d2=bit#)
	move.l	(a1)+,a0	;next start of bitplane address
	;APRIL06'89;btst	d2,0(a0,d1.w)
	btst	d2,0(a0,d1.L)
	beq.s	gsb_end\@
 ifle \1-2
	addq	#(1<<\1),d0
 endc
 ifgt \1-2
	ori.b	#1<<\1,d0	;bset #\1,d0
 endc
gsb_end\@:
   ENDM

my_readpixel:	MACRO	;(d0=x, d1=y, a1=bm_Planes table,  leaves d0=6bits)
	;move.w	d0,d2	;save original x	; 4
	;neg.w	d2
	;addq.w	#7,d2	;d2 = bit number [ 7..0 ]
	moveq	#7,d2
	sub.w	d0,d2	;d2=bitnumber "+ dontcarebits" for btst opcode

	;THIS IS 'mul by var' because could be from hamtools or bigpic
	;COULD BE SPED UP?->timestableptr reference for bigpic,or times_table_40
	mulu	bm_BytesPerRow-bm_Planes(a3),d1	;y*rowsize

	asr.w	#3,d0	;x/8
	;APRIL06'89;add.w	d0,d1

		;may02'89...prevent "run off left edge" when cant find a color
	bpl.s	1$	;x ok?(horrors! ...another cycle-hoggin branch)
	moveq	#0,d0	;negative x? wha?...short out and use palette zero
	bra.s	after_getpixel\@
1$

	swap	d0
	clr.w	d0
	swap	d0	;12cy vs 16cy for andi.l #$0000ffff
	add.L	d0,d1

	;?NOT NEEDED, BTST INSTR ONLY LOOKS AT BOTTOM BITS?;andi.w	#7,d2	;original "x"

	moveq	#0,d0	;assume zeros to start (we setup ones)
	get_screen_bit 0	;,-8000
	get_screen_bit 1	;,0
	get_screen_bit 2	;,8000
	get_screen_bit 3	;,16000
	get_screen_bit 4	;,24000
	get_screen_bit 5	;,32000
after_getpixel\@:
 endm ;my_readpixel

readpix_setup:	MACRO	;AUG261990
	;move.w	d0,d2	;save original x	; 4
	;neg.w	d2
	;addq.w	#7,d2	;d2 = bit number [ 7..0 ]
	moveq	#7,d2
	sub.w	d0,d2	;d2=bitnumber "+ dontcarebits" for btst opcode

	;THIS IS 'mul by var' because could be from hamtools or bigpic
	;COULD BE SPED UP?->timestableptr reference for bigpic,or times_table_40
	mulu	bm_BytesPerRow-bm_Planes(a3),d1	;y*rowsize

	asr.w	#3,d0	;x/8
	;APRIL06'89;add.w	d0,d1

		;may02'89...prevent "run off left edge" when cant find a color
	bpl.s	1$	;x ok?(horrors! ... another cycle-hoggin branch)
	moveq	#0,d0	;negative x? wha?...short out and use palette zero
	bra.s	after_setup\@
1$

	swap	d0
	clr.w	d0
	swap	d0	;12cy vs 16cy for andi.l #$0000ffff
	add.L	d0,d1

	;?NOT NEEDED, BTST INSTR ONLY LOOKS AT BOTTOM BITS?;andi.w	#7,d2	;original "x"
after_setup\@:
	moveq	#0,d0	;assume zeros to start (we setup ones)
	ENDM

GetOld_END MACRO
   ;movem.l	(sp)+,d3/d4 ;/a2

		;return 8 bit values in d0/d1/d2
	;moveq	#0,d0
	;move.b	Predold_(BP),d0
	;asl.b	#4,d0
	;moveq	#0,d1
	;move.b	Pgreenold_(BP),d1
	;asl.b	#4,d1
	;moveq	#0,d2
	;move.b	Pblueold_(BP),d2
	;asl.b	#4,d2

	move.l	Predold_(BP),d0
	sf	d0		;clr.b d0 MAY1990
	asl.l	#4,d0		;make leftside colors be 8 bits...
	move.l	d0,-(sp)	;temp, shifted 8 bit values, check for 240

	cmp.b	#$f0,(sp)
	bcs.s	goered\@
	move.b	#$ff,(sp)
goered\@:
	cmp.b	#$f0,1(sp)
	bcs.s	goegreen\@
	move.b	#$ff,1(sp)
goegreen\@:
	cmp.b	#$f0,2(sp)
	bcs.s	goeblue\@
	move.b	#$ff,2(sp)
goeblue\@:
	move.l	(sp)+,d0	;restore fixed 8 bit values...

	;june25'90....
	;	;convert 4 bit to an 8 bit value....
 	;xref Paintred_
 	;xref Paint8red_
	;move.l	Paintred_(BP),-(sp) 
	;move.l	Paint8red_(BP),-(sp) 
	;move.l	Predold_(BP),Paintred_(BP)
	;xref	Paint4to8Bit		;mousertns.asm
	;jsr	Paint4to8Bit		;mousertns.asm
	;move.l	Paint8red_(BP),d0	;convert 8 bit values....
	;move.l	(sp)+,Paint8red_(BP)
	;move.l	(sp)+,Paintred_(BP)

	move.B	LastPlot_(BP),d0

   rts
	cnop 0,4 ;longalign next rtn for '020s
   ENDM

Get_Palette_Quick MACRO ; color
	IFC '\1','red'
	move.b	0(LCTareg,OldPixel.w),Predold_(BP)
	ENDC
	IFC '\1','green'
	move.b	1(LCTareg,OldPixel.w),Pgreenold_(BP)
	ENDC
	IFC '\1','blue'
	move.b	2(LCTareg,OldPixel.w),Pblueold_(BP)
	ENDC
   ENDM

Get_Palette MACRO ; color
   andi.W	#15,OldPixel   ; max of 16 registers
   add.b	OldPixel,OldPixel
   add.b	OldPixel,OldPixel
   Get_Palette_Quick \1
   ENDM

	xref Datared_		;rgb red buffer ptr for big pictur

	xref ScreenBitMap_Planes_
	xref UnDoBitMap_Planes_
	xref AltPasteBitMap_Planes_
	xref PasteBitMap_Planes_
	xref SwapBitMap_Planes_

	xref BigPicRGB_		;24 bit bitmap, 3 "bitplanes" for rgb buffers
	xref AltPasteRGB_
	xref PasteRGB_
	xref SwapRGB_
	xref UnDoRGB_

******* Get P(red,green,blue)old and LastPlot at curt XY ****   
*  d0=x d1=y						*
*****************

OldPixel  EQUR d0

GetOld: ; ( d0=X, d1=Y, A3=RASTPORT )   ; DESTROYS D0/D1/D2/A0/A1/A3
	move.l	4(a3),a3	;move.l	rp_BitMap(a3),a3

GetOldfromBitMap: ; ( d0=X, d1=Y A3=BITMAP )
	movem.l	d3/d4,-(sp)	;/a2,-(sp)
	lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's
	bsr.s	QuickGetOldplanes	;bra.s	QuickGetOldBM	;alternate entrance
	movem.l	(sp)+,d3/d4 ;/a2
	rts
	cnop 0,4 ;longalign next rtn for '020s

 xdef GetOldRGBBitMap ; ( d0=X, d1=Y A3=BITMAP ) ;DECEMBER 1990...RGB ONLY
GetOldRGBBitMap: ; ( d0=X, d1=Y A3=BITMAP )
	movem.l	d3/d4,-(sp)	;/a2,-(sp)
	lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's
	bsr.s	QuickGetRGB	;bra.s	QuickGetOldBM	;alternate entrance
	movem.l	(sp)+,d3/d4 ;/a2
	rts
	cnop 0,4 ;longalign next rtn for '020s

QuickGetOldplanes: ;d0,1 = x,y WATCH a3=BITPLANE PTRs (bm_Planes in a bm_ struct)

;?;	tst.l	Datared_(BP)	;24 bit mode? does bigpic have rgb buffers?
;?;	beq	oldway		;nope, do "old" way, just from ham bitmap

		;LATEMAY1990
	movea.l	a3,a1	; 6 bitplane addr's
	subq	#2,sp	;leave room on stack for "lastplot"

;		;AUG261990....ignore '6 bit' ham lookup, if repainting...
;		;....should work ok...
;	xref FlagRepainting_
;	tst.b	FlagRepainting_(BP)
;	beq.s	get_6bit
;	CLR.W	12(sp)	;readpix_setup
;	bra.s	no_6bit
;get_6bit:


;		;AUG271990....help out 'narrow' brushes, right edge, anti-aliasing...
;	move.W	d0,-(sp)
;	asr.w	#3,d0
;	cmp.w	bm_BytesPerRow-bm_Planes(a3),d0	;'x/8' within a row?
;	bcs.s	001$
;	move.w	bm_BytesPerRow-bm_Planes(a3),d0
;	subq.w	#1,d0
;	;moveq	#0,d2	;'last bit//pixel' on a line
;	move.w	d0,(sp)
;001$	move.w	(sp)+,d0

	movem.l	d0/d1/d2,-(sp)
	my_readpixel
	move.W	d0,12(sp)	;LEAVE 8 bit "lastplot" on stack (as a .word)
	movem.l	(sp)+,d0/d1/d2
;;no_6bit:
	bra.s	no_6bit

	;DECEMBER1990
QuickGetRGB:	;d0,1 = x,y WATCH a3=BITPLANE PTRs (bm_Planes in a bm_ struct)
		;LATEMAY1990
	movea.l	a3,a1	; 6 bitplane addr's
	;subq	#2,sp	;leave room on stack for "lastplot"
	;
	;;movem.l	d0/d1/d2,-(sp)
	;;my_readpixel
	;;move.W	d0,12(sp)	;LEAVE 8 bit "lastplot" on stack (as a .word)
	;;movem.l	(sp)+,d0/d1/d2
	clr.w	-(sp)

no_6bit:
		;MAR91...rearranged for quicker txmapping...
		;priority order is ...
		;swap brush(txmap), screen, brush, swap screen, undo...
		;note: this should speed up txmapping, txmap+antialiasing
	lea	AltPasteBitMap_Planes_(BP),a1
	;cmp.l	a1,a3		;"from" big picture (-or- undo)?
	move.l	(a1),a1		;1st bitplane ptr
	cmp.l	(a3),a1		;1st bitplanes "match"?
	bne.s	4$		;nope...(do "old" way)
	lea	AltPasteRGB_(BP),a0
	bra.s	get24
4$
	lea	ScreenBitMap_Planes_(BP),a1
	;cmp.l	a1,a3		;"from" big picture?
	move.l	(a1),a1		;1st bitplane ptr
	cmp.l	(a3),a1		;1st bitplanes "match"?
	bne.s	1$		;nope...(do "old" way)
	lea	BigPicRGB_(BP),a0
	bra.s	get24
1$
	lea	PasteBitMap_Planes_(BP),a1
	;cmp.l	a1,a3		;"from" big picture (-or- undo)?
	move.l	(a1),a1		;1st bitplane ptr
	cmp.l	(a3),a1		;1st bitplanes "match"?
	bne.s	3$		;nope...(do "old" way)
	lea	PasteRGB_(BP),a0
	bra.s	get24
3$
	lea	SwapBitMap_Planes_(BP),a1
	;cmp.l	a1,a3		;"from" big picture (-or- undo)?
	move.l	(a1),a1		;1st bitplane ptr
	cmp.l	(a3),a1		;1st bitplanes "match"?
	bne.s	5$		;nope...(do "old" way)
	lea	SwapRGB_(BP),a0
	bra.s	get24
5$
	lea	UnDoBitMap_Planes_(BP),a1
	;cmp.l	a1,a3		;"from" big picture (-or- undo)?
	move.l	(a1),a1		;1st bitplane ptr
	cmp.l	(a3),a1		;1st bitplanes "match"?
;	bne.s	2$		;nope...(do "old" way)
;	lea	UnDoRGB_(BP),a0
;	bra.s	get24
;2$
;
;	bra.s	oldway
;MAR91
	bne.s	oldway
	lea	UnDoRGB_(BP),a0

get24:

	tst.l	bm_Planes(a0)
	beq.s	oldway

	xref	GrabB_RGB ;BrushRGBRtns.asm
	jsr	GrabB_RGB ;BrushRGBRtns.asm, get 8 bit colors from RGB bitmap

	;move.b	d0,Predold_(BP)
	;move.b	d1,Pgreenold_(BP)
	;move.b	d2,Pblueold_(BP)
	;
	;	;MAY1990
	;move.W	(SP)+,d0	;previously 'gotten' 6bit ham pixel
	;move.B	d0,LastPlot_(BP)

	asl.W	#8,d0		;red<<byte
	move.B	d1,d0		;red.b, green.b
	swap	d0		;upper word...
	move.w	d2,d0		;x.b,blue.b
	;WRONG!;just say NO to bugs...;asl.W	#8,d2		;blue<<byte
	asl.W	#8,d0		;blue<<byte
	OR.W	(SP)+,d0	;previously 'gotten' 6bit ham pixel.byte

	;move.L	Predold_(BP),d0	;d0=24bit color
	move.l	d0,d1
	asr.l	#4,d1		;8bits>>4 = 4 bit values
	and.l	#$0f0f0f00,d1
	;or.B	LastPlot_(BP),d1	;latemay1990
	move.B	d0,d1		;"bottom byte" = 6bit ham value
	move.l	d1,Predold_(BP)	;4 bit values in "old" (8 bit values in d0)
				;d0= (8bitred, 8bitgr, 8bitblu, 6bithampixel)
	rts

oldway:
	;;;lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's
	move.W	d0,d3 ; X
	move.W	d1,d4 ; Y
	;lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's

;QuickGetOldBM:
	;movea.l	a3,a1 ; 6 bitplane addr's
	;my_readpixel
	move.w	#$00ff,d0
	and.w	(SP)+,d0	;previously 'gotten' 6bit ham pixel

getold_oldstart:

   ; if old pixel is a register number, go use it
	;;; beq.s	Get_Ham_All ; pixel value=color register 0
	cmp.b	#16,OldPixel
	bcc.s	IsColor ; >= 16? then it's a color

;Get_Ham_All: ; get all ham modifiers
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	move.b	OldPixel,d1
	add.b	OldPixel,OldPixel
	add.b	OldPixel,OldPixel

	;move.l	0(LCTareg,OldPixel.w),Predold_(BP) ; get P(rgb)old	;30cy
	;move.b	d1,LastPlot_(BP)					;12cy

	move.L	0(LCTareg,OldPixel.w),OldPixel	;get P(rgb)old APRIL13	;18
	move.B	d1,OldPixel						;4
	move.L	OldPixel,Predold_(BP)					;16

	GetOld_END

IsColor: ; find which color
	move.b	d0,LastPlot_(BP) ; 1st time around, save LastPlot pixel value
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;; beq Isred   ; color # 2
	bcs Isblue  ; color # 1
	bne Isgreen ; color # 3 ; (BRANCH COULD BE REDUNDANT)

***********************
******* 1st color found is red, look for blue & green *************
***********************

Isred:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Predold_(BP) ; save the actually seen value

redIsred: ; Get last Pixel's 6 bit plotted current value
	;subq.l	#1,d3 ; X=X-1
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ; Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	redIsColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette green
	Get_Palette_Quick blue
	GetOld_END
redIsColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	beq redIsred   ; color # 2 (again)
	;;; bcs redIsblue  ; color # 1
	bcc redIsgreen ; color # 3 ; (BRANCH COULD BE REDUNDANT)
 
******* found red 1st,then found blue, now look for green ***********
redIsblue:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Pblueold_(BP) ; save the actually seen value

redIsblueloop: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	redIsblueColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette green
	GetOld_END
redIsblueColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;   beq.s	redIsblueloop   ; color # 2 (again)
	;;   bcs.s	redIsblueloop   ; color # 1
	BLS	redIsblueloop   ; color #2 (again) or color #1
	;;   bra	redIsgreen ; color # 3 ; (BRANCH COULD BE REDUNDANT)
	andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
	move.b	d0,Pgreenold_(BP) ; save the actually seen value
	GetOld_END

******* found red 1st,then found green, now look for blue ***********
redIsgreen:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Pgreenold_(BP) ; save the actually seen value

redIsgreenloop: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	redIsgreenColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette blue
	GetOld_END
redIsgreenColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	BEQ	redIsgreenloop	; color # 2 (again)
	bcs.s	redIsgreenGotblue ; color # 1
	BRA	redIsgreenloop ; color # 3 ; (BRANCH COULD BE REDUNDANT)
redIsgreenGotblue:
	andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
	move.b	d0,Pblueold_(BP) ; save the actually seen value
	GetOld_END


***********************
******* 1st color found is green, look for red & blue *************
***********************

Isgreen:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Pgreenold_(BP) ; save the actually seen value

greenIsgreen: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	greenIsColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette red
	Get_Palette_Quick blue
	GetOld_END
greenIsColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;; beq greenIsred   ; color # 2 (red)
	bcs greenIsblue  ; color # 1
	bne greenIsgreen ; color # 3 ; (BRANCH COULD BE REDUNDANT)
 
******* found green 1st,then found red, now look for blue ***********
greenIsred:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Predold_(BP) ; save the actually seen value

greenIsredloop: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	greenIsredColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette blue
	GetOld_END
greenIsredColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	; beq greenIsredloop   ; color # 2 (red again)
	BCC	greenIsredloop   ; color # 3 (green again)
	andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
	move.b	d0,Pblueold_(BP) ; save the actually seen value
	GetOld_END

******* found green 1st,then found blue, now look for red ***********
greenIsblue:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Pblueold_(BP) ; save the actually seen value

greenIsblueloop: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	greenIsblueColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette red
	GetOld_END
greenIsblueColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;  beq greenIsblueGotred  ; color # 2 (red)
	;;  bcs greenIsblueloop ; color # 1 (blue)
	;;  bne.s	greenIsblueloop ; color # 3 ; (BRANCH COULD BE REDUNDANT)
	BNE	greenIsblueloop ; color # 3 ; (BRANCH COULD BE REDUNDANT)
greenIsblueGotred:
	andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
	move.b	d0,Predold_(BP) ; save the actually seen value
	GetOld_END




***********************
******* 1st color found is blue, look for red & green *************
***********************

Isblue:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Pblueold_(BP) ; save the actually seen value

blueIsblue: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	blueIsColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette green
	Get_Palette_Quick red
	GetOld_END
blueIsColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;; beq blueIsred   ; color # 2 (red)
	bcs blueIsblue  ; color # 1
	bne blueIsgreen ; color # 3 ; (BRANCH COULD BE REDUNDANT)
 
******* found blue 1st,then found red, now look for green ***********
blueIsred:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Predold_(BP) ; save the actually seen value

blueIsredloop: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	blueIsredColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette green
	GetOld_END
blueIsredColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;	beq.s	blueIsredloop   ; color # 2 (again)
	;;	bcs.s	blueIsredloop   ; color # 1
	;;	bls.s	blueIsredloop   ; color #2(again) or color #1
	BLS	blueIsredloop   ; color #2(again) or color #1
	;	bra	blueIsgreen ; color # 3 ; (BRANCH COULD BE REDUNDANT)
	andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
	move.b	d0,Pgreenold_(BP) ; save the actually seen value
	GetOld_END

******* found blue 1st,then found green, now look for red ***********
blueIsgreen:
   andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
   move.b	d0,Pgreenold_(BP) ; save the actually seen value

blueIsgreenloop: ; Get last Pixel's 6 bit plotted current value
	subq.W	#1,d3 ; X=X-1
	;move.l	d3,d0 ; X
	;move.l	d4,d1 ;Y
	move.W	d3,d0 ; X
	move.W	d4,d1 ; Y
	movea.l	a3,a1   ; RastPort for current window
	my_readpixel

   ; if old pixel is a register number, go use it
	cmp.b	#16,OldPixel
	bcc.s	blueIsgreenColor ; >= 16? then it's a color
	;;;;lea LongColorTable_(BP),a2 ; table of 16 words representing RGB bits
	Get_Palette red
	GetOld_END
blueIsgreenColor: ; find which color
	move.b	d0,d1  ; get pixel
	asr.b	#4,d1   ; strip of shade#, leave 2 bit color#
	subq.b	#2,d1
	;;  beq blueIsgreenGotred  ; color # 2 (red)
	;;;;  bcs blueIsgreenloop ; color # 1 (blue)
	;;  bra.s	blueIsgreenloop ; color # 3 ; (BRANCH COULD BE REDUNDANT)
	BNE	blueIsgreenloop
blueIsgreenGotred:
	andi.b	#$F,d0	; strip of HAM color select, leave 4 bit shade
	move.b	d0,Predold_(BP) ; save the actually seen value
	GetOld_END

   END	;end of GetOld.asm


