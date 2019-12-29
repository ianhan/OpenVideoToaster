* WholeHam.asm   (..."I'm a soul man.")

	xdef	WholeHam		;redo's ham display, if possible
	xdef	WholeShrink ;Wshr ;whole screen shrink...go skinnier, interlace
	xdef	WholeExpand ;Wexp ;whole screen expand...go "zoom", non-interlace, superbitmap

	include "exec/types.i"
	include "ps:basestuff.i"
	include "ps:savergb.i"
	include "graphics/gfx.i"
	include "exec/libraries.i"	;for LIB_VERSION....22JAN92

	xref	FlagWholeHam_		;'main loop' handles this flag -> Wham.asm
	xref	SaveArray_
	xref 	BigPicRGB_
	xref ScreenBitMap_

	xref	FlagFrbx_		;set if need screen arrange
	xref	FlagToolWindow_		;set/cleared...toolbox (wanna be) shown?

	xref Pred_
	xref Predold_

WholeHam:	;redo's ham display, if possible
	tst.b	FlagWholeHam_(BP) 	;'main loop' handles this flag -> Wham.asm
	beq	end_wholeham
	lea	BigPicRGB_(BP),a0
	tst.l	bm_Planes(a0)
	beq	end_wholeham	;nope, can't do this if don't have rgb data


		;22JAN92...fix 1x mode problem, for 1.3OS, w/Tool screen bogus interlace
	;	;1.3 KLUDGE, should fix "bogus tools copper list"  21JAN92
	xref	TScreenPtr_
	move.l	IntuitionLibrary_(BP),a6
	cmp.W	#36,LIB_VERSION(a6)
	bcc.s	101$			;workbench 2.0 or newer?...if so, skip this
	move.l	TScreenPtr_(BP),d0
	beq.s	101$
	move.l	d0,a0
	xjsr	IntuScreenToFront	;IntuRtns.asm
	st	FlagFrbx_(BP)		;bummer.....asks for screenstofront, make ScreenArrange "work"
	xjsr	ScreenArrange		;gadgetrtns.asm
101$:	CALLIB	Intuition,RemakeDisplay

	xjsr	UnShowPaste	;31JAN92
	xjsr	FreeDouble	;31JAN92

		;july311990....don't replot if r,g,b buffers=black AND color 0=black
	xref HiresColorTable_
	cmp.w	#0,HiresColorTable_(BP)	;color=black?
	bne.s	continue_notblack

	lea	BigPicRGB_(BP),a0
	move.w	(a0),d0			;width
	mulu	2(a0),d0		;*height=size
	;subq.l	#1,d0			;db' type loop

	move.l	bm_Planes(a0),a1	;check out reds...all=black?
	bsr.s	checkblock
	bne.s	continue_notblack	
	move.l	4+bm_Planes(a0),a1	;check out greens...all=black?
	bsr.s	checkblock
	bne.s	continue_notblack	
	move.l	8+bm_Planes(a0),a1	;check out blues...all=black?
	bsr.s	checkblock
	bne.s	continue_notblack	
	bra	done_wholeham
checkblock:
	move.l	d0,d1	;loop counter
checknext:
	;tst.b	(a1)+	;THIS COULD BE SPED UP, DEFINITELY....
	;bne.s	foundone
	;subq.l	#1,d1
	;bne.s	checknext

		;AUG191990...(I got tired of waiting for this loop...)
	tst.L	(a1)+	;THIS COULD BE SPED UP, DEFINITELY....
	bne.s	foundone
	subq.l	#4,d1
	bgt.s	checknext
foundone:
	rts
continue_notblack:




	;-redisplay code-

;	;-comment out- test stuff...
;	;clear screen
;	lea	ScreenBitMap_(BP),a1
;	movem.w	(a1)+,d0/d1	;width,ht
;	mulu	d1,d0		;=planesize
;	addq	#4,a1		;skip flags, etc in bitmap struct
;		;a1<-6 bitplane addr
;	moveq	#6-1,d2		;db' loop
;loop:	move.l	(a1)+,d1
;	beq.s	enda_cplanes
;	move.l	d1,a0
;	xjsr	ClearMemA0D0
;	dbf	d2,loop
;enda_cplanes:

	;xjsr	SetPointerWait		;interrupt-able
	xjsr	SetAltPointerWait	;non-interrupt-able
	sf	FlagToolWindow_(BP)	;TOOLS hidden	;SEP131990
	st	FlagFrbx_(BP)		;ask for screen arrange	;SEP131990
	xjsr	ScreenArrange		;GadgetRtns.asm, hides toolbox	;SEP131990

	xjsr	ForceAmigaCopper	;26FEB92;

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
	;SEP131990;bne.s	777$		;cancel, or any message, kills "wholeham"
	;SEP131990;xjsr	CheckIDCMP

	;SEP131990;beq.s	777$			;ok, no cancel....
	beq.s	nocancel
	xjsr	CancelRemapRtn		;canceler.asm, returns zero flag...

777$	movem.l	(sp)+,d0-d2/a0/a1/a6
	;july021990;bne	abort_wholeham

	bne	abort_wholeham	;SEP131990...

		;ensure that hires gadgets are ok after requester...SEP131990
	movem.l	d0-d2/a0/a1/a6,-(sp)
	;xjsr	ReDoHires		;tool.code.i
	;xjsr	DisplayText		;ShowTxt.asm
	st	FlagFrbx_(BP)		;ask for screen arrange...SEP131990
	xjsr	ScreenArrange		;GadgetRtns.asm, hides toolbox	;SEP131990
	xjsr	SetAltPointerWait	;non-interrupt-able(!) - resets idcmp...
nocancel:
	movem.l	(sp)+,d0-d2/a0/a1/a6

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
	;no need;move.b	d0,(a6)	;red
	move.b	d0,Pred_(BP)

	move.b	1(a6),d0	;green
	add.B	d1,d0
	bcc.s	2$
	move.b	#$ff,d0
2$	asr.w	#4,d0
	;no need;move.b	d0,1(a6)	;green
	move.b	d0,Pgreen_(BP)

	move.b	2(a6),d0	;blue
	add.B	d1,d0
	bcc.s	3$
	move.b	#$ff,d0
3$	asr.w	#4,d0
	;no need;move.b	d0,2(a6)	;blue
	move.b	d0,Pblue_(BP)



	jsr	(A4)			;Determine Routine
skipndet:
	move.b  D0,s_LastPlot(a6)	;determ'd result, what we're gonna plot
	lea	s_SIZEOF(a6),a6		;next pixel record
	;subq.w	#1,(sp)			;line_x_(BP)
	;bcc.s	det_loop
	dbf	d2,det_loop


  	;plot pixels to screen
	lea	ScreenBitMap_(BP),a0
	;move.w	2(a0),d1
	movem.w	(a0),d0/d1		;bytes per row, row#
	sub.w	(sp),d1			;d1=this row# (screen reference)
	mulu	d0,d1			;d1=offset to current line on scr'
	asl.w	#3,d0			;bytes *8 --> pixels
	lea	SaveArray_(BP),a6

	xjsr	LinePlot_SaveArray

	;NEXT LINE
	add.w	#1,2(sp)	;line#, current
	subq.w	#1,(sp)
	bne	next_line
	addq	#2,sp	;clup loop counter, #lines,stack
	addq	#2,sp	;clup line#

done_wholeham:
	sf	FlagWholeHam_(BP)

	st	FlagToolWindow_(BP)	;TOOLS displayed	;SEP131990
	st	FlagFrbx_(BP)		;ask for screen arrange	;SEP131990

	;SEP201990;xjsr	SaveUnDo	;memories.asm, saves ham undo buffer SEP011990
	xjsr	ReallySaveUnDo	;memories.asm, saves ham undo buffer SEP201990
	xjsr	SaveUnDoRGB	;rgbrtns.asm   saves rgb undo buffer (to match ham) SEP011990

;SEP011990...label moved...;end_wholeham:

	xjsr	AproPointer	;no need to reset point if didn't set it...

	xref	FlagBitMapSaved_	;31JAN92
	sf	FlagBitMapSaved_(BP)	;force test to fail, copy to happen... 31JAN92
	xjsr	SaveUnDo	;31JAN92
	xjsr	SaveCPUnDo	;31JAN92

end_wholeham:
	RTS	;wholeham

abort_wholeham:
	;;addq	#2,sp	;clup stack
	;;sf	FlagWholeHam_(BP)

	st	FlagToolWindow_(BP)	;TOOLS displayed	;SEP131990
	st	FlagFrbx_(BP)		;ask for screen arrange	;SEP131990

	sf	FlagWholeHam_(BP)	;SEP131990
	addq	#2,sp	;clup loop counter, #lines,stack
	addq	#2,sp	;clup line#

	sf	FlagBitMapSaved_(BP)	;force test to fail, copy to happen... 31JAN92
	xjsr	SaveUnDo	;31JAN92
	xjsr	SaveCPUnDo	;31JAN92

	RTS	;wholeham


;-------------------------
SHRINKBYTE:	MACRO ;\1,\2     8 bit \1 becomes 4 bits in \2

	;roxl.B	#1,\1
	;roxl.B	#1,\2	;dis-regard upper bits...
	;roxl.B	#2,\1	;skip a bit...
	;roxl.B	#1,\2
	;roxl.B	#2,\1	;skip a bit...
	;roxl.B	#1,\2
	;roxl.B	#2,\1	;skip a bit...
	;roxl.B	#1,\2
		;JUNE061990.....mucho quicker to use 'addx'
	addx.B	\1,\1
	addx.B	\2,\2	;dis-regard upper bits...
	roxl.B	#2,\1	;skip a bit...
	addx.B	\2,\2
	roxl.B	#2,\1	;skip a bit...
	addx.B	\2,\2
	roxl.B	#2,\1	;skip a bit...
	addx.B	\2,\2
		ENDM

;-------------------------
WholeShrink: ;Wshr ;whole screen shrink...go skinnier, interlace
	;04FEB92;xjsr	HideToolWindow		;SEP011990

	lea	ScreenBitMap_(BP),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#6-1,d2		;#bitplanes
	movem.w	(a0),d0/d1	;screen width (BYTES per row) ,ht
	lea	bm_Planes(a0),a0	;point to 6 bitplane adr
shrinkloop:
	move.l	(a0)+,d3
	beq.s	bumnoplane

	movem.l	d0-d5/a0/a1,-(sp)
	bsr	shrinkplane ;d0=wt d1=ht D3=(CHIP) BITPLANE ADR
	movem.l	(sp)+,d0-d5/a0/a1

	dbf	d2,shrinkloop

	;doesn't help....21JAN92;CALLIB	Intuition,WBenchToFront

bumnoplane:
	rts

shrinkplane: ;d0=wt d1=ht D3=(CHIP) BITPLANE ADR
	move.l	d3,a0	;=source adr
	asr.w	#1,d0	;loop count constant, 1/2 # bytes
	subq.w	#1,d0	;inner loop counter (constant) is a db' loop thingie

	subq.w	#1,d1	;db' type loop, each line
shline_loop:
	move.l	a0,a1	;"next" line's dest, source are same at start of line
	move.w	d0,d2	;d2=db' loop counter
shpixels_loop:		;separately shrink 2 "source" bytes for 1 dest
	move.b	(a0)+,d3
	SHRINKBYTE d3,d4	;8bits, grab every other, use 4 bits
	move.b	(a0)+,d3
	SHRINKBYTE d3,d4
	move.b	d4,(a1)+

	dbf	d2,shpixels_loop
	dbf	d1,shline_loop

	rts

;-------------------------
expandBYTE:	MACRO ;\1,\2,\3     top 4 bits of  \1 becomes 8 bits in \2, \3 is TEMP

	rol.B	#1,\1	;clone top bit of \1 into 2 bits in \2
	scs	\3	;byte \3 becomes all-ones or all-zeros
	;roxl.B	#1,\3
	;roxl.W	#1,\2
	;roxl.B	#1,\3
	;roxl.W	#1,\2
		;june061990...much faster to use 'addx'
	addx.B	\3,\3
	addx.W	\2,\2
	addx.B	\3,\3
	addx.W	\2,\2


 	rol.B	#1,\1	;clone top bit of \1 into 2 bits in \2
	scs	\3	;byte \3 becomes all-ones or all-zeros
	;roxl.B	#1,\3
	;roxl.W	#1,\2
	;roxl.B	#1,\3
	;roxl.W	#1,\2

	addx.B	\3,\3
	addx.W	\2,\2
	addx.B	\3,\3
	addx.W	\2,\2

	rol.B	#1,\1	;clone top bit of \1 into 2 bits in \2
	scs	\3	;byte \3 becomes all-ones or all-zeros
	;roxl.B	#1,\3
	;roxl.W	#1,\2
	;roxl.B	#1,\3
	;roxl.W	#1,\2

	addx.B	\3,\3
	addx.W	\2,\2
	addx.B	\3,\3
	addx.W	\2,\2

	rol.B	#1,\1	;clone top bit of \1 into 2 bits in \2
	scs	\3	;byte \3 becomes all-ones or all-zeros
	;roxl.B	#1,\3
	;roxl.W	#1,\2
	;roxl.B	#1,\3
	;roxl.W	#1,\2

	addx.B	\3,\3
	addx.W	\2,\2
	addx.B	\3,\3
	addx.W	\2,\2

		ENDM

;-------------------------
WholeExpand: ;Wexp ;whole screen expand...go "zoom", non-interlace, superbitmap
	;04FEB92;xjsr	HideToolWindow		;SEP011990

	lea	ScreenBitMap_(BP),a0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#6-1,d2		;#bitplanes
	movem.w	(a0),d0/d1	;screen width (BYTES per row) ,ht

		;JULY191990
	cmp.w	#TOASTMAXWT/2,d0	;384*2=768.....using 736 max wt...
	bcs.s	1$
	move.w	#TOASTMAXWT/2,d0
1$
	lea	bm_Planes(a0),a0	;point to 6 bitplane adr
expandloop:
	move.l	(a0)+,d3
	beq.s	bumno_eplane

	movem.l	d0-d5/a0/a1,-(sp)
	bsr	expandplane ;d0=wt d1=ht D3=(CHIP) BITPLANE ADR
	movem.l	(sp)+,d0-d5/a0/a1

	dbf	d2,expandloop

bumno_eplane:
	rts

expandplane: ;d0=wt d1=ht D3=(CHIP) BITPLANE ADR
	;move.l	d3,a0	;=source adr
	move.l	d3,a1	;=dest adr
	move.l	a1,a0	;"next" line's source, dest are same at start of line
	asr.w	#1,d0	;loop count constant, 1/2 # bytes
	;;;subq.w	#1,d0	;inner loop counter (constant) is a db' loop thingie

	subq.w	#1,d1	;db' type loop, each line
expline_loop:
	add.L	d0,a0	;point to middle of line
	add.L	d0,a1	
	add.L	d0,a1	;point to END of line (dest)

	move.w	d0,d2	;d2=db' loop counter
	subq	#1,d2	;db' type loop
exppixels_loop:		;separately expand 2 "source" bytes for 1 dest
	move.b	-(a0),d3
	expandBYTE d3,d4,d5	;TOP 4 bits --> 8 bits in d4 (d5=temp)
	;;move.b	d4,-(a1)
	expandBYTE d3,d4,d5	;TOP(was bottom) 4 bits --> 8 bits in d4
	move.W	d4,-(a1)

	dbf	d2,exppixels_loop

	add.L	d0,a0	;d0=1/2 line width, skip line, go to next
	add.L	d0,a0
	add.L	d0,a1	;bump dest, too...
	add.L	d0,a1

	dbf	d1,expline_loop

	rts
