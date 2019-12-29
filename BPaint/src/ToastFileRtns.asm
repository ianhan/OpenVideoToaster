* 2.0 ToasterPaint routine

	xdef	LoadToastFile	;displays it on a line by line basis,
				;with cancel option...
				;this is my substitue for LoadRGBPicture

	include "exec/types.i"
	include "graphics/gfx.i"
	include "commonrgb.i"	;newtek's include
	include "ps:basestuff.i"
	include "ps:savergb.i"


	xref BigPicRGB_
	xref PictureInfo_
	xref FilenameBuffer_

LoadToastFile:

	bsr	QUERYFILE
	TST.L	D0		;not documented...I though you only had to check for zero
	bne	errornoload	;doneload

	bsr	STARTLOADRGBPICTURE
	beq	errornoload

	;WANT?;-no-;bsr	LOADPICTUREDATA
	bsr	LineByLine		;calls LoadRGBLine
	bsr	STOPLOADRGBPICTURE

cleanup:
	bsr	CLOSEQUERY
doneload:
	moveq	#0,d0		;no error...
	RTS

errornoload:
	bsr.s	cleanup
	moveq	#-1,d0		;error from queryfile...
	RTS



;----------------------------------

	xref	LocalToastBase		;toastglue.o
CALLTB:	MACRO
	xref \1ADR		;RELOCATABLE, YECH!

	movem.l	a3/a5,-(sp)
	move.l	\1ADR,a3
	move.l	LocalToastBase,a5
	jsr	(a3)			;*** CRASH CITY ***
	movem.l	(sp)+,a3/a5
		ENDM

STARTLOADRGBPICTURE:
	xref DOSLibrary_
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	move.l	DOSLibrary_(BP),a6		;NOT DOCUMENTED...
	CALLTB	StartLoadRGBPicture
	RTS

QUERYFILE:
	lea	FilenameBuffer_(BP),a0	;picture struct
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	CALLTB	QueryFile
		;NOV91....only use switcher routines for framestore stuff
	tst.l	d0			;error code?
	bne.s	9$			;yep....else check PictureInfo structure
  ifc 't','f'
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	;tst.w	PI_COMPOSITEFLAG(a1)	;bit 8 means composite commonrgb.i
	;beq.s	9$
	cmp.w	#16,PI_Planes(a1)	;number of planes in 1 scan line
	beq.s	9$
  endc
  ifc 't','f'
		;assume ok, but really, only let "real" .fs. filenames thru

	bsr	checkFSname	;return EQ is ".fs." type, NE if invalid frame filename
	beq.s	9$
  endc
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	tst.l	PI_PLANETYPE(a1)	;if this is zero, cannot read file"
	bne.s	9$	
	moveq	#-4,d0		;setup an error code
9$:	tst.l	d0
	RTS

  ifc 't','f'

checkFSname:	;return EQ is ".fs." type, NE if invalid frame filename
	lea	FilenameBuffer_(BP),a1

	tst.b	(a1)		;check for "short" (or empty) filename
	beq.s	notfsname
	tst.b	1(a1)
	beq.s	notfsname
	tst.b	2(a1)
	beq.s	notfsname

	cmp.b	#'.',3(a1)
	bne.s	9$

	cmp.b	#'f',4(a1)
	beq.s	1$
	cmp.b	#'F',4(a1)
	bne.s	9$
1$
	cmp.b	#'s',5(a1)
	beq.s	3$
	cmp.b	#'S',5(a1)
	bne.s	9$
3$

	cmp.b	#'.',6(a1)
9$	RTS

notfsname:
	moveq	#-1,d0	;flag NE
	RTS		;checkfsname
  endc ;checkfsname


CLOSEQUERY:
	lea	PictureInfo_(BP),a0	;pictureinfo struct
	CALLTB	CloseQuery
	RTS

STOPLOADRGBPICTURE:
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	CALLTB	StopLoadRGBPicture
	RTS

  IFC 't','f'  ;;WANT?;
LOADPICTUREDATA:
	lea	BigPicRGB_(BP),a0	;picture struct
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	xref LoadPictureDataADR		;RELOCATABLE, YECH!
	move.l	LoadPictureDataADR,a3
	move.l	a5,-(sp)
	xref	LocalToastBase		;toastglue.o
	move.l	LocalToastBase,a5
	move.l	a5,a2			;SHOULD THIS BE A5 or A2?
	jsr	(a3)
	move.l	(sp)+,a5
	RTS
  ENDC
;----------------------------------


* WholeHam.asm   (..."I'm a soul man.")....stole code for toaster file load

	;;;xdef	WholeHam		;redo's ham display, if possible

	xref	FlagWholeHam_		;'main loop' handles this flag -> Wham.asm
	xref	SaveArray_
	xref 	BigPicRGB_
	xref ScreenBitMap_

	xref	FlagFrbx_		;set if need screen arrange
	xref	FlagToolWindow_		;set/cleared...toolbox (wanna be) shown?

	xref Pred_
	xref Predold_

;WholeHam:	;redo's ham display, if possible
LineByLine:	;redo's ham display, if possible
	;2.0;tst.b	FlagWholeHam_(BP) 	;'main loop' handles this flag -> Wham.asm
	;2.0;beq	end_wholeham
	lea	BigPicRGB_(BP),a0
	tst.l	bm_Planes(a0)
	beq	end_wholeham	;nope, can't do this if don't have rgb data

  IFC 't','f' ;....don't need this check/skip out...
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

  ENDC ;IFC 't','f' ;....don't need this check/skip out...



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

	xjsr	SetPointerWait		;interrupt-able
	;;;xjsr	SetAltPointerWait	;non-interrupt-able
	sf	FlagToolWindow_(BP)	;TOOLS hidden	;SEP131990
	st	FlagFrbx_(BP)		;ask for screen arrange	;SEP131990
	xjsr	ScreenArrange		;GadgetRtns.asm, hides toolbox	;SEP131990

	;FOR EACH LINE ON SCREEN....
	;;lea	BigPicRGB_(BP),a0	;...using STACK for line#s
	;;move.w	#0,-(sp)		;current line#
	;;move.w	2(a0),-(sp)		;#rows ON SCREEN
	move.w	#0,-(sp)		;current line#
	lea	PictureInfo_(BP),a0	;...using STACK for line#s
	move.l	PI_BMHEADER(a0),a0	;bitmap

	;NOV05'91;move.w	bym_Rows(a0),-(sp)	;#rows IN FILE
		;ensure only # of rows on screen are loaded
	XREF	BigPicHt_
	move.w	bym_Rows(a0),d0
	cmp.w	BigPicHt_(BP),d0
	bcs.s	123$
	move.w	BigPicHt_(BP),d0
123$	move.w	d0,-(sp)	;#rows IN FILE

	move.l	#$B0bB0bD1,random_seed_(BP)	;for same dither every screen

next_line:

;?;  IFC 't','f' ;WANT...2.0
		;LOAD ONE LINE FROM FILE (2.0)
	moveq	#0,d0
	move.w	2(sp),d0			;line#

	movem.l	d0-d7/a0-a6,-(sp)
	lea	BigPicRGB_(BP),a0	;picture struct
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	move.l	DOSLibrary_(BP),a6		;NOT DOCUMENTED...

	CALLTB	LoadRGBLine
	movem.l	(sp)+,d0-d7/a0-a6
;?;  ENDC

		;setup dither threshold for each record in 'savearray'
	movem.l	d0-d2/a0/a1/a6,-(sp)
		;FLAG LINE TO BE RENDERED, THEN DISPLAY HAM PREVIEW 03DEC91
		xref	SolLineTable_
		moveq	#0,d0
		move.w	6*4+2(sp),d0		;ldline_w_(BP),d1
		tst.l	SolLineTable_(BP)	;03DEC91
		beq.s	allnosolflag
		move.l	SolLineTable_(BP),a0
		sf	0(a0,d0.w)	;flag line with new rgb info
allnosolflag:
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
	;2.0;xjsr	CancelRemapRtn		;canceler.asm, returns zero flag... ***2.0, 'end file load?'
	xjsr	Canceler		;canceler.asm, cancel/continue?

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
	RTS	;wholeham

;-------------------
  
   END 

;------------------- dead code


	lea	PictureInfo_(BP),a0	;...grab #row from file's bmhd
	move.l	PI_BMHEADER(a0),a0
	move.w	bm_Rows(a0),-(sp)	;using STACK for line counter
	clr.w	-(sp)
eachrowloop:
		;LOAD ONE LINE FROM FILE
	moveq	#0,d0
	move.w	(sp),d0			;line#
	lea	BigPicRGB_(BP),a0	;picture struct
	lea	PictureInfo_(BP),a1	;pictureinfo struct
	xref LoadRGBLineADR		;RELOCATABLE, YECH!
	move.l	LoadRGBLineADR,a2
	jsr	(a2)

		;FLAG LINE TO BE RENDERED, THEN DISPLAY HAM PREVIEW
	xref	SolLineTable_
		moveq	#0,d0
		move.w	(sp),d0		;arg=line#
		tst.l	SolLineTable_(BP)	;DEC0391
		beq.s	allnosolflag
		move.l	SolLineTable_(BP),a0
		sf	0(a0,d0.w)	;flag line with new rgb info
allnosolflag:
		bsr	DisplayPreview

		;CHECK FOR CANCEL
		xjsr	ScrollAndCheckCancel	;canceler.asm
		bne.s	donerowloop

	addq	#1,(sp)
	move.w	(sp),d0
	cmp.w	2(sp),d0
	bcs	eachrowloop	; 'main loop'
donerowloop:
	addq.l	#4,sp		;remove loop counter, max iter count


;-----





DisplayPreview:	;d0=line#
	movem.l	d0-d7/a0-a6,-(sp)

		;GET RGB DATA INTO SAVEARRAY

		;DETERMINE WHAT TO PLOT IN HAM

		;ACTUALLY PLOT ON HAM/PREVIEW SCREEN
	xref	BigPicWt_
	move.l	BigPicWt_(BP),d0	;d0=#pixels
	lea	BigPicRGB_(BP),a0	;'picture' struct
	move.l	(sp),d1			;line#
	mulu	(a0),d1			;offset=bytes-per-row * line#
	xjsr	LinePlot_SaveArray	;lineplot.asm
		;    plots a ham line given:
		;     d0.l = number of pixels ( this is # of PIXELS, will be /32 for words)
		;     d1.w = plane offset start of line
		;     a6.l = ptr to "d0" number of bytes...indicate what to plot per pixel
		;     * destroys most registers


	movem.l	(sp)+,d0-d7/a0-a6
	RTS	;DisplayPreview
