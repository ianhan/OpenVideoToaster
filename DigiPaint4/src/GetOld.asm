* GetOld.asm 	 ; assumes A3 = BITMAP -or- bm_Planes

BP	equr	a5
   XDEF GetOld ; DESTROYS D0/D1/A0/A1 d0=x d1=y a3=rastport
   XDEF GetOldfromBitMap ; DESTROYS D0/D1/A0/A1 d0=x d1=y a3=bitmap
   XDEF QuickGetOldBM	;destroys d0-d4,a0-a2, d0,1=x,y A3=bm_Planes ptr

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

GetOld_END MACRO
   ;movem.l	(sp)+,d3/d4 ;/a2
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

******* Get P(red,green,blue)old and LastPlot at curt XY ****   
*  d0=x d1=y						*
*****************

OldPixel  EQUR d0

GetOld: ; ( d0=X, d1=Y)   ; DESTROYS D0/D1/D2/A0/A1/A3
	movem.l	d3/d4,-(sp)	;/a2,-(sp)
	move.l	4(a3),a3	;move.l	rp_BitMap(a3),a3
	lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's
	bsr.s	QuickGetOldBM	;bra.s	QuickGetOldBM	;alternate entrance
	movem.l	(sp)+,d3/d4 ;/a2
	rts
	cnop 0,4 ;longalign next rtn for '020s

GetOldfromBitMap: ; ( d0=X, d1=Y) a3=bitmap
	movem.l	d3/d4,-(sp)	;/a2,-(sp)
	lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's
	bsr.s	QuickGetOldBM	;bra.s	QuickGetOldBM	;alternate entrance
	movem.l	(sp)+,d3/d4 ;/a2
	rts
	cnop 0,4 ;longalign next rtn for '020s

QuickGetOldBM:	;d0,1 = x,y WATCH a3=BITPLANE PTRs
	move.W	d0,d3 ; X
	move.W	d1,d4 ; Y
	;lea	8(a3),a3	;A3 is constant here for ptr to 6 bitpl addr's
;QuickGetOldBM:
	movea.l	a3,a1 ; 6 bitplane addr's
	my_readpixel

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


