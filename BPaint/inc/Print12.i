	xref BigPicRGB_
	xref SaveArray_
	xref ScreenBitMap_	;no really needed...
	xref ScreenBitMap_Planes_
	xref Predold_		;no really needed...

	;xjsr	SetPointerWait		;interrupt-able
	xjsr	SetAltPointerWait	;non-interrupt-able

	;FOR EACH LINE ON SCREEN....
	lea	BigPicRGB_(BP),a0	;...using STACK for line#s
	move.w	#0,-(sp)		;current line#
	move.w	2(a0),-(sp)		;#rows ON SCREEN

	move.l	#$B0bB0bD1,random_seed_(BP)	;for same dither every screen

next_line:
		;setup dither threshold for each record in 'savearray'
	movem.l	d0-d2/a0/a1/a6,-(sp)
	moveq	#0,d0
	move.w	6*4+2(sp),d1		;ldline_w_(BP),d1
	xjsr	GimmeDither	;d0/1=x/y.w returns a0=table, d0=constant

	lea	SaveArray_(BP),a6 ;use the save table as source
	;lea	s_DitherThresh(a6),a6	;use the save table as source
	lea	s_PlotFlag(a6),a6	;use the save table as source
	xref	bytes_row_less1_W_
	move.w	bytes_row_less1_W_(BP),d4

	addq	#1,d4	;=bytesperrow (to repaint)
	add.w	d4,d4	;=nybblesperrow
	subq	#1,d4	;db' type loop counter

rset_lwloop:
rset_addrbit:	MACRO	;codesize 20bytes
	;not for static...;nxtrandom d6		;MACRO, compute another random #
		;compute static dither
	move.B	(a0)+,d6	;dither from 'gimmedither'
	ASR.B	#2,d6		;only 4 bits of dither, now
	move.b	d7,(a6)+	;s_PlotFlag
	move.b	d6,(a6)	;june22;d6,s_DitherThresh-s_PlotFlag(a6)
	lea	(s_SIZEOF-1)(a6),a6	;june22;s_SIZEOF(a6),a6
	ENDM
rsnybble:	  MACRO
	rset_addrbit
	rset_addrbit
	rset_addrbit
	rset_addrbit
	ENDM

	rsnybble	;4bits
	dbf	d4,rset_lwloop
	;;;bra.s	enda_dithsup	;end of (none,matrix,random) dither setup

	movem.l	(sp)+,d0-d2/a0/a1/a6



	movem.l	d0-d2/a0/a1/a6,-(sp)
	xjsr	ScrollAndCheckCancel	;uses/dumps "scroll" mousemoves
	bne.s	777$		;cancel, or any message, kills "wholeham"
	xjsr	CheckIDCMP
777$	movem.l	(sp)+,d0-d2/a0/a1/a6
	;july021990;bne	abort_wholeham

	;fill in savearray with rgb colors
	lea	BigPicRGB_(BP),a1
	moveq	#0,d0
	move.w	(a1),d2			;#pixels to grab

	;move.w	2(a1),d1		;#rows in bitmap
	;sub.w	(sp),d1			;this row #

	lea	ScreenBitMap_(BP),a0
	move.w	2(a0),d1
	sub.w	(sp),d1			;d1=this row# (screen reference)

	lea	SaveArray_(BP),a0	;1st pixel's "record" inside savearray
	;xjsr GenGetRGB	;get pixel data from RGB arrays (ZERO flag if none)
	xjsr WhamGetRGB	;get pixel data from RGB arrays (ZERO flag if none)
	;;;from scratch...;;;sne	Flag24_(BP)	;...Flag24 is set at ReadBody, then set/reset after GetRGB
		;d0=pixel# (even multiple of 32)
		;d1=row#
		;d2=#pixels
		;a0=savearray


	;re-determine what to plot in ham mode
	lea	SaveArray_(BP),a6
	lea	ScreenBitMap_(BP),a0
	moveq	#0,d2
	move.w	(a0),d2		;bitmap width
	asl.w	#3,d2		;*8, bytes to pixels
	subq.w	#1,d2		;db' loop

	;;;STARTaLOOP A6,d2 ;d0
	xref	DetermineRtn_
	move.l	DetermineRtn_(BP),A4	;D2,A4 *not* used by DetermineRtn

	move.l	-s_SIZEOF(a6),d1
	xref	LongColorTable_
	MOVE.L	LongColorTable_(BP),d1	;color zero
	clr.B	d1
	move.l	d1,Predold_(BP)

det_loop:
		;REALLY WANT TO DITHER...
	;move.l	(a6),d0 ;s_red	;set up 'old' for next guy's determine
	;asR.l	#4,d0		;8bits down to 4
	;and.l	#$0f0f0f00,d0	;top bit strip (asr crawl down)
	;;move.l	d0,Predold_(BP)	;NOTE: messes up 'last plot', lost it long ago...
	;move.l	d0,Pred_(BP)	;old/existing rgb colors

LOWERDITHER set 3 ;cloned from scratch
	xref random_seed_
	xref Pred_
	xref Pgreen_
	xref Pblue_

;nxtrandom:	MACRO	;d-register,  (using d5 as subst for random_seed)
;	MOVE.W	random_seed_(BP),\1	;compute next random seed (longword)
;	LSR.W	#1,\1
;	BCC.s	norflip\@
;	EOR.W	#$B400,\1	;algo ref: Dr. Dobb's Nov86 pg 50,55
;norflip\@:
;	MOVE.W	\1,random_seed_(BP)
;		;JUNE
;	and.W	#$0f,\1		;bottom 4 bits
;	subq	#LOWERDITHER,\1
;	bcc.s	nxrok\@
;	moveq	#0,\1
;nxrok\@:
;		ENDM
;
;	nxtrandom d1
	moveq	#0,d1
	move.B	s_DitherThresh(a6),d1	;random ditherness

	moveq	#0,d0
	move.b	(a6),d0	;red
	add.B	d1,d0
	bcc.s	1$
	move.b	#$ff,d0
1$	asr.w	#4,d0
	move.b	d0,(a6)	;red	;need for saving into 12-bitplanes
	;no need, not ham;move.b	d0,Pred_(BP)

	move.b	1(a6),d0	;green
	add.B	d1,d0
	bcc.s	2$
	move.b	#$ff,d0
2$	asr.w	#4,d0
	move.b	d0,1(a6)	;green	;need for saving into 12-bitplanes
	;no need, not ham;move.b	d0,Pgreen_(BP)

	move.b	2(a6),d0	;blue
	add.B	d1,d0
	bcc.s	3$
	move.b	#$ff,d0
3$	asr.w	#4,d0
	move.b	d0,2(a6)	;blue	;need for saving into 12-bitplanes
	;no need, not ham;move.b	d0,Pblue_(BP)

;; xjsr DebugMe2
		;s_red,green,blue are 4 bit value....
		;...convert to .word of XXXrrrgggbbb
	;moveq	#0,d0
	;move.b	(a6),d0
	;asl.B	#4,d0
	;or.b	1(a6),d0	;'or' in green bits
	;asl.W	#4,d0
	;or.b	2(a6),d0	;'or' in blue bits....
	move.W	(a6),d0		;XXXXrrrrXXXXgggg
	asl.B	#4,d0		;XXXXrrrrggggXXXX
	or.B	2(a6),d0	;XXXXrrrrggggbbbb
	move.W	d0,(a6)		;our plot routine, below, understands this...

;; xjsr DebugMe3

 ifc 't','f' ;not using a ham-determine mode...

	jsr	(A4)			;Determine Routine
skipndet:
	move.b  D0,s_LastPlot(a6)	;determ'd result, what we're gonna plot
 endc ;not using a ham-determine mode...

	lea	s_SIZEOF(a6),a6		;next pixel record
	;subq.w	#1,(sp)			;line_x_(BP)
	;bcc.s	det_loop
	dbf	d2,det_loop


  	;plot pixels to screen....NO, PLOT INTO 12-BITPLANES....
	lea	ScreenBitMap_(BP),a0
	;move.l	Print12Ptr_(BP),a0	;*WANT*
	;lea	p12_bitmap(a0),a0

	;move.w	2(a0),d1
	movem.w	(a0),d0/d1		;bytes per row, row#
	sub.w	(sp),d1			;d1=this row# (screen reference)
	mulu	d0,d1			;d1=offset to current line on scr'
	asl.w	#3,d0			;bytes *8 --> pixels
	lea	SaveArray_(BP),a6

	;;;;;xjsr	LinePlot_SaveArray	;WANT lineplot_to_bitmap
	bsr	LinePlot_to_bitmap

	;NEXT LINE
	add.w	#1,2(sp)	;line#, current
	subq.w	#1,(sp)
	bne	next_line
	addq	#2,sp	;clup loop counter, #lines,stack
	addq	#2,sp	;clup line#

done_wholeham:

	BRA	enda_printinclude

*********************** 'dirty work'....filling in of image, etc.



 ; d2-d7 = byte data to actually go into bitplane (transformed)
 ; a0-a5 = bit plane addresses
 ;    a6 = ptr to byte data

plane0_data equr d2
plane1_data equr d3
plane2_data equr d4
plane3_data equr d5
plane4_data equr d6
plane5_data equr d7

plane0_ptr  equr a0
plane1_ptr  equr a1
plane2_ptr  equr a2
plane3_ptr  equr a3
plane4_ptr  equr a4
plane5_ptr  equr a5

***********************************************************************
rot_1_pixel:	macro	;uses "rox" codes to move 1 pixel to dregisters (30bytes code)
	;move.b (a6),d1	;data to go to screen
	MOVE.W	(A6),D1	;12 BIT RGB FOR BITMAP

	;AUG221990;lea s_SIZEOF(a6),a6 ; point to next pixel/byte in SaveArray
	roxr.w #1,d1		;->x source low bit  
	addx.w plane0_data,plane0_data	;x<- move to display register
	roxr.w #1,d1		;->x source low bit  
	addx.w plane1_data,plane1_data	;x<- move to display register
	roxr.w #1,d1		;->x source low bit  
	addx.w plane2_data,plane2_data	;x<- move to display register
	roxr.w #1,d1		;->x source low bit  
	addx.w plane3_data,plane3_data	;x<- move to display register
	roxr.w #1,d1		;->x source low bit  
	addx.w plane4_data,plane4_data	;x<- move to display register
	roxr.w #1,d1		;->x source low bit  
	addx.w plane5_data,plane5_data	;x<- move to display register

	MOVE.W	D1,(A6)		;resave shifted down....12 BIT RGB FOR BITMAP
	lea s_SIZEOF(a6),a6 ; point to next pixel/byte in SaveArray

  endm

rot_16_pixels_ns:	macro	;"_ns" means "no stack"...uses stack for ctr
	;move.w	#8,-(sp)	;saves cache...macro only ~66bytes
	moveq	#8-1,d0
rot16_ns_\@:
	rot_1_pixel
	rot_1_pixel
	;subq.w	#1,(sp)
	;bne.s	rot16_ns_\@
	dbf	d0,rot16_ns_\@

	;addq.L	#2,sp	;clup stack
 endm

quickplot_32:	macro
	;move.w	#8,-(sp)	;saves cache...macro only ~66bytes
	rot_16_pixels_ns	;loop thru SaveArray, building planeX_data registers
	;move.w=9,*2=18cycles  Vs. swap 4 +move.l=14 = 18cycles
	;HOWEVER the SWAP may be preferable on a '020
	;..or at least a machine with 32BIT WIDE RAM for the move.L
	swap plane0_data ;,(plane0_ptr)+
	swap plane1_data ;,(plane1_ptr)+
	swap plane2_data ;,(plane2_ptr)+
	swap plane3_data ;,(plane3_ptr)+
	swap plane4_data ;,(plane4_ptr)+
	swap plane5_data ;,(plane5_ptr)+

	;move.w	#8,(sp)	;saves cache...macro only ~66bytes
	rot_16_pixels_ns	;loop thru SaveArray, building planeX_data registers
	;addq.L	#2,sp	;clup stack
	move.l plane0_data,(plane0_ptr)+
	move.l plane1_data,(plane1_ptr)+
	move.l plane2_data,(plane2_ptr)+
	move.l plane3_data,(plane3_ptr)+
	move.l plane4_data,(plane4_ptr)+
	move.l plane5_data,(plane5_ptr)+

  endm


LinePlot_to_bitmap:
		;the way this works is we use a '6bit' plot routine, TWICE
		;...in order to get the 12 bits into the new bitmap
; xjsr DebugMe4
; xjsr DebugPrint12
	movem.l	d0-d7/a0-a6,-(sp)	;KLUDGEY,GROSS....
	;movem.l	a5/a6,-(sp)
	move.l	Print12Ptr_(BP),a5	;*WANT*
	lea	p12_bitmap(a5),a5
	lea	bm_Planes(a5),a5
	movem.l (a5),a0-a5		;6 bitplane addresses
	bsr	LinePlot_6bits
 	movem.l	(sp),d0-d7/a0-a6	;restore ALL args...(count, etc)
; xjsr DebugMe5

;;;;;;;;;;;;;;;;;;;; IFC 't','f' ;KLUDGEOUT...testing....WANT
	;movem.l	(sp),a5/a6
	move.l	Print12Ptr_(BP),a5	;*WANT*
	lea	p12_bitmap(a5),a5
	lea	bm_Planes+(4*6)(a5),a5
	movem.l (a5),a0-a5		;6 bitplane adr
	bsr	LinePlot_6bits
;;;;;;;;;;;;;;;;;;;;  ENDC ;KLUDGEOUT...testing....WANT

	;;;movem.l	(sp)+,a5/a6	;a5=bp
	movem.l	(sp)+,d0-d7/a0-a6		;KLUDGEY,GROSS....
; xjsr DebugMe6
	rts



LinePlot_6bits:
 movem.l BP/a6,-(sp)	;stackitbabyweneverletgoofourbasepageregister
;BOGUS...POINT AT 12BIT STUFF..; lea s_LastPlot(a6),a6 ; a6, when called, should point to start
	add.l	d1,plane0_ptr
	add.l	d1,plane1_ptr
	add.l	d1,plane2_ptr
	add.l	d1,plane3_ptr
	add.l	d1,plane4_ptr
	add.l	d1,plane5_ptr
; asr.w #5,d0 ; #pixels / 32 = number of words
; subq #1,d0  ; -1 for dbf type loop
	move.w	d0,-(sp)	;count, #pixels on stack
tryplot32:
	;;cmp.w	#(32*4),d0	;Do=ARG = #PIXELS TO PLOT
	;;cmp.w	#(32*2),d0	;Do=ARG = #PIXELS TO PLOT
	;cmp.w	#32,(sp)	;32 pixels per loop...
 
	;bcs	con_LPSA	;go copy 32 @ a time...

	quickplot_32	;believe me, this *is* optimized for all std combos
	;quickplot_32
	;;quickplot_32
	;;quickplot_32

	;sub.w	#(32*4),d0	;we just plotted 320 pixels...
	;sub.w	#(32*2),d0	;we just plotted 320 pixels...
	sub.w	#32,(sp)	;we just plotted 320 pixels...
	bne	tryplot32	;for wider screens...con_LPSA
	addq	#2,sp	;destack counter
 movem.l (sp)+,BP/a6	;Destackitbabyweneverletgoofourbasepageregister
	rts

enda_printinclude:
