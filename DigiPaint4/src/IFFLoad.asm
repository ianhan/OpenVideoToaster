* IFFLoad.asm

	XDEF IFF_Load
	;XDEF InterpCAMG
	XDEF ComparePalettes	;returns zero flag, current/file palette the same?
	XDEF Continue_Load	;"after" flagrequest

	xref QuickDetermine	;Determine.o
	;;xref UseColorMap	;GadgetRoutines.o
	;;xref Cut		;cutpaste.o

MAXHAMWIDTH set 320+64	;2 long words over still c/b ham

	include "ds:basestuff.i"
	include "lotsa-includes.i"
	include "libraries/dos.i"
	include "graphics/gfx.i"	;BitMap structure
	include "graphics/rastport.i"	;RastPort stuff
	include "windows.i"
	include "screens.i"
	include "graphics/view.i"	;for CAMG interp
	include "ds:SaveRGB.i"

	xref BB1Ptr_
	xref bytes_per_row_
	xref bytes_row_less1_W_
	xref CAMG_
	xref DetermineRtn_
	xref FileCAMG_	;ONLY from file valu
	xref FileHandle_
	xref FlagBitMapSaved_		;memories.o, keeps track of 'undo'
	xref FlagBrush_
	xref FlagDither_
	xref FlagFilePalette_
	xref FlagHires_
	xref FlagLace_
	xref FlagNeedIntFix_	;did a scroll happen?
	xref FlagPalette_
	xref FlagRemap_ ;handle remap like a load, but no read of file
	xref FlagText_
	xref fraction_long_red_
	xref LoadDepth_
	xref LongColorTable_	;Ptr_
	xref Pblue_
	xref Pgreen_
	xref BigPicWt_W_
	xref BigPicWt_
	xref OnlyPort_
	xref PlaneSize_
	xref Predold_
	xref Pred_
	xref random_seed_
	xref SaveArray_
	xref ScreenBitMap_Planes_
	xref UnDoBitMap_Planes_
	xref BigPicHt_
	xref ScreenPtr_

;	Color Palette Selection Per Pixel based on FlagFilePalette_(BP).
;
;	"load color table" snippet:
;		load from CMAP from file into FileColorTable_(BP)
;		if using palette from file ( FlagFilePalette_(BP)=1 )
;		then move FileColorTable_(BP) -> LongColorTable
;			move LongColorTable -> hardware (usemap)
;
;	always use LongColorTable for Determining what to plot,
;	it represents the currently active color table as a list
;	of 32(really, up to 64) long words (only 16 are EVER valid)
;
;	FileColorTable_(BP) is a list of 32(really, 64) long words representing the
;	palette from the file.  Note that this is adjusted after
;	reading...the file contains 8 bit values, we only use 4 bits
;	per color.

RoundUp: macro	;register/variable  (rounds register DOWN to an even number)
	addq.l	#1,\1	;NOV/DECEMBER 1990
	and.b	#~1,\1	;8 cycles total
	endm

myread_stub:
	move.l	BufferLen_(BP),d3	;Read wants # of bytes in d3
	move.l	FileHandle_(BP),d1
	move.l	FileBufferPtr_(BP),a4	;dos preserves WORKING BUFFER PTR A4
	move.l	a4,d2			;dos arg

	CALLIB	DOS,Read	;returns count#read in d0 (max buffer is 63K)
	move.l	d0,d1	;DOS RESULT (exec settaskpri preserves d1)

	move.w	d1,BufferCount_(BP)	;12 cy (this goes to 0, NO CHANGE LEN)
	bne.s	readok
	move.w	#1,BufferCount_(BP)	;funny way, handle bumping end-of-file
readok:	rts

ReadOneByte_main: macro ;-----
		;ASSUMES A6 = DOS LIBRARY BASE ADDRESS
		;HAS SOLE USE OF A4 for pointer into FileBufferPtr_(BP)
	subq.w	#1,BufferCount_(BP)	;17 cy
	bne.s	have_data\@
	bsr	myread_stub	;ok waste time//save space since calling dos
have_data\@:
	endm

ReadOneByte_a3: macro	;reads byte into (a3)+ ;---
	ReadOneByte_main
	move.b	(a4)+,(a3)+
	endm
ReadOneByte_d0: macro	;reads byte into d0 ;-----
	ReadOneByte_main
	move.b	(a4)+,d0
	endm

Nliteral	equr d5	;current count bytes to literally copy
Nduplicate	equr d6	;current count times to duplicate Datadup bytes
Datadup		equr d7	;current byte being duplicated
	
Uncompress_next_byte: macro ;register,label for 'dbf' instr. to endit
			;may NOT use d3,d4
	tst.b	Nduplicate	;non zero means we are duplicating
	beq.s	check_literal\@
	subq.w	#1,Nduplicate
	move.b	Datadup,(a3)+
	dbf	\1,\2
	bra.s	end_Uncompress\@
check_literal\@:
	tst.b	Nliteral	;literally use next 'n' bytes
	beq.s	get_uncomp_case\@	;get next code
	subq	#1,Nliteral
	ReadOneByte_a3
	dbf	\1,\2
	bra.s	end_Uncompress\@	;we WANT short but it wont fit yet
get_uncomp_case\@:
	ReadOneByte_d0
	bmi.s	start_duplicate\@
	cmpi.b	#-128,d0	;value of -128 is a noop
	beq.s	get_uncomp_case\@
;start_literal
	move.b	d0,Nliteral
	ReadOneByte_a3
	dbf	\1,\2
	bra.s	end_Uncompress\@
start_duplicate\@:
	neg.b	d0
	move.b	d0,Nduplicate
	ReadOneByte_d0
	move.b	d0,Datadup
	move.b	d0,(a3)+
	dbf	\1,\2
end_Uncompress\@:
	endm ;-----
			
ComputeOnePixel: macro  ;-----;A3=ptr to "filecolortable"
	move.b	s_Paintred(a6),d0
	and.W	#%00111111,d0	;strip mask (7th) bit, clean up word too

	tst.b	FlagHamFile_(BP)	;if we are loading a ham file...
	beq.S	not_a_ham_file\@
	;we are plotting a ham file, using an existing palette
		cmpi.b	#16,d0	;is our byte a ham modifier?
		BCS.S	not_a_ham_file\@	;palette color, anyway
		cmpi.b	#32,d0		;d0=HAM MODIFIER
		bcc.s	_not_\@_blue
		andi.b	#$0F,d0
		move.b	d0,Pblue_(BP)
		bra.s	quickdet_\@
_not_\@_blue:	cmpi.b	#48,d0
		bcc.s	_not_\@_red
		andi.b	#$0F,d0
		move.b	d0,Pred_(BP)
		bra.s	quickdet_\@
_not_\@_red:	andi.b	#$0F,d0
		move.b	d0,Pgreen_(BP)
		bra.s	quickdet_\@
not_a_ham_file\@:	;treat halfbrite (6 bitplanes) as requiring a 64 color
			;color map, s/b consistent with the ibm pc2 and 'gif'
		add.w	d0,d0		;=*2 palette #
		add.w	d0,d0		;=*4
		move.l	0(a3,d0.w),Pred_(BP)	;(rgbj)  that we want to plot
quickdet_\@:
	jsr	(a4)	;DetermineRtn ;return d0=6bit plotvalu and P(rgb)old
	endm	;ComputeOnePixel

ThresholdTable:	;gosh it's big...;----
	dc.b	00,08,53,61,02,10,55,63
	dc.b	16,24,37,45,18,26,39,47
	dc.b	49,57,04,12,51,59,06,14
	dc.b	33,41,20,28,35,43,22,30
	dc.b	03,11,54,62,01,09,52,60
	dc.b	19,27,38,46,17,25,36,44
	dc.b	50,58,07,15,48,56,05,13
	dc.b	34,42,23,31,32,40,21,29
; ThresholdTableEnd:		;----

InterpCAMG:
	sf	FlagHamFile_(BP) ;no camg? assume non-ham JUNE24, fix mansion.32color bug
	move.l	CAMG_(BP),d0
	beq.s	none_interp
	move.l	#V_HAM,d1	;hambit?
	and.l	d0,d1		;test for ham bit in chunk
	sne	FlagHamFile_(BP)

	tst.b	FlagBrush_(BP)	;MAY04
	beq.s	3$
	sf	FlagHires_(BP)	;if brush load, then no hires-shrink
	bra.s	9$
3$
	move.l	#V_HIRES,d1	;hiresbit?
	and.l	d0,d1		;test for hires bit in chunk
	sne	FlagHires_(BP)	;HIRES USED FOR DOUBLE'ING LINES->HAM ASPECT
	move.l	#V_LACE,d1	;view lace bit?
	and.l	d0,d1		;test for hires bit in chunk
  ;?;may04;?;	sne	FlagLace_(BP)
	xref FlagLaceNEW_
	sne	FlagLaceNEW_(BP)	;feb27'89 (set file's lace status)

	move.l	#V_HAM,d0	;rebuild a new camg
	tst.b	FlagLace_(BP)
	beq.s	8$
	or.l	#V_LACE,d0
8$	move.L	d0,CAMG_(BP)
9$	rts

none_interp:	;DELUXE PAINT is noTORious for no CAMG chunk
	move.b	bmhd_nplanes_(BP),d0
	cmp.b	#5,d0
	bcc.s	wldnt_behires
	move.w	bmhd_pagewidth_(BP),d0
	beq.s	1$
	cmp.w	#MAXHAMWIDTH+1,d0
	bcs.s	wldnt_behires	;probably not
	bra.s	2$
1$	move.w	bmhd_rastwidth_(BP),d0
	cmp.w	#MAXHAMWIDTH+1,d0
	bcs.s	wldnt_behires	;probably not
2$	st	FlagHires_(BP)	;"with fingers crossed" guessed it was hires?
	ORI.L	#V_HIRES,FileCAMG_(BP)	;"force this thing" to say "hires"	
wldnt_behires:
	rts

;===================

IFF_Load:	;load file named "FileHandle_(BP)" (already opened)
	; into WindowPtr window
	; this routine is called from File_Load,
	; which takes care of opening and closing the
	; file for us (all registers already saved, no need to bother)
	;a4	used by ReadOneByte as pointer into FileBufferPtr_(BP)

	sf	FlagPaleMatch_(BP)	;ASSUME NO MATCHING PALETTE?
	xjsr	ClearSaveArray
	tst.b	FlagRemap_(BP)
	beq.s	1$
	st	FlagHamFile_(BP)	;JULY05...fixes remap 2x problem?
	move.L	BigPicWt_(BP),d0	;remap, fake out a file same as picture
	move.w	d0,bmhd_rastwidth_(BP)
	move.w	BigPicHt_(BP),bmhd_rastheight_(BP)
	move.b	#6,bmhd_nplanes_(BP)
	move.l	#(16*3),d0	;len of colortableChunkLength_(BP),d0
	;bra	getfileAndshowit	;regular file load, grab buffer
	bra	skipfileButshowit	;remap_entry here<=
1$

;may21;
;may21;	;ALWAYS close ham tool
;may21;	xref FlagCloseWB_	;may07'89
;may21;	tst.b	FlagCloseWB_(BP)	;lomem situ?
;may21;	beq.s	2$			;nope
;may21;	xjsr	GoodByeHamTool	;remove ham screen (free up chip)
;may21;2$

	xjsr	GrabLoadPlane0		;memories.o ;does an alloc' if needed
	beq	Clup_EndLoad		;no buffer?

	move.w	#1,BufferCount_(BP)	;effectively clears it
	move.l	#(8*64),d0 ;size to allow for top of file, bigger for odd chunks
	move.l	d0,BufferLen_(BP)
	xjsr	GrabFileBuffer		;memories.o ;does the alloc'
	beq	NoMemory_Out	;Clup_EndLoad		;no buffer?

	sf	FlagError_(BP)		;err flag for FindChunk,Fread,SkipRead

	bsr	FindILBMForm 		;find form ILBM,get Form(Length,DataPos)
	tst.b	FlagError_(BP)		;err status set in FRead and SkipRead
	bne	Clup_EndLoad		;no open file?

	bsr	FindBMHDChunk
	bne	Clup_EndLoad

	clr.l	CAMG_(BP)	;setclear FLAGS ham, lace (, hires)
	move.l	#'CAMG',d0
	bsr	FindChunk	;set variable ChunkLength_(BP)
	tst.b	FlagError_(BP)
	bne.s	no_readcamg
	bsr	ReadLong	;get the one long word of data
	move.l	d0,FileCAMG_(BP)	;set//clear FLAGS ham, lace (, hires)
	move.l	d0,CAMG_(BP)	;set//clear FLAGS ham, lace (, hires)
no_readcamg:
	bsr	InterpCAMG	;looks at bmhd if no cmap

	;Find and read the file's palette('cmap') (if any)
	move.l	#'CMAP',d0
	jsr	FindChunk		;set variable ChunkLength_(BP)
	tst.b	FlagError_(BP)
	bne	end_of_reading_cmap	;no cmap? well, we'll live...
	move.l	ChunkLength_(BP),d0
	cmp.l	#(3*64),d0
	bcs.s	1$
	move.l	#3*64,d0
1$
	bsr	FRead	;read color table from file into FileBufferPtr_(BP)

		;uncompress FileBufferPtr_(BP) into FileColorTable_(BP)
	lea	FileColorTable_(BP),a0 ;fill here if using existing palette
	move.l	FileBufferPtr_(BP),a1	 ;(96) CMAP data just read
	move.l	ChunkLength_(BP),d0	;FRead result
	cmp.w	#64*3,d0	;max #colors able to handle (halfbrite=6bitpl)
	bcs.s	08$
	move.w	#64*3,d0
08$
	divu	#3,d0	;3 bytes per color register
	;cmp.w	#64,d0	;we COULD get 64 pallettes...(halfbrite//non-HAM)
	cmp.w	#32,d0	;we COULD get 64 pallettes...(halfbrite//non-HAM)
	bcs.s	09$
	;move.w	#64,d0	;max size color table we handle
	move.w	#32,d0	;max size color table we handle
09$	subq	#1,d0	;for dbf type loop...
	bcs.s	no_colortable	;wha?
build_color_table_loop:
	move.b	(a1)+,d2	;RED data from file = DAC value << 4
	asr.b	#4,d2	; shift right 4x for actual use
	andi.b	#$0F,d2  
	move.b	d2,(a0)+	;install this word of rgb info into color table

	asr.b	#1,d2		  ;MAY23...halfbrite support
	move.b	d2,((4*32)-1)(a0) ;MAY23...halfbrite support

	move.b	(a1)+,d2	;GREEN data from file = DAC value << 4
	asr.b	#4,d2	; shift right 4x for actual use
	andi.b	#$0F,d2  
	move.b	d2,(a0)+	;install this word of rgb info into color table

	asr.b	#1,d2		  ;MAY23...halfbrite support
	move.b	d2,((4*32)-1)(a0) ;MAY23...halfbrite support

	move.b	(a1)+,d2	;BLUE data from file = DAC value << 4
	asr.b	#4,d2	; shift right 4x for actual use
	andi.b	#$0F,d2  
	move.b	d2,(a0)+	;install this word of rgb info into color table

	asr.b	#1,d2		  ;MAY23...halfbrite support
	move.b	d2,((4*32)-1)(a0) ;MAY23...halfbrite support

	move.b	#0,(a0)+	;add 1, skip the don't care byte in LongColorTable

;MAY23		;MAY23 halfbrite fixer-upper
;		;...dlxpaintIII saves non-half-brite colors in cmap
;		;...fix by shifting (1) if in h-brite range
;	cmp.l	#(64*3),ChunkLength_(BP)	;FRead result
;	bcs.s	not_hbrite
;	cmp.w	#32,d0		;1st or 2nd half of color set?
;	bcc.s	not_hbrite
;shifthb:	macro	;a0-offset
;	move.b	\1(a0),d2	;a0 pts to color table in-process-building
;	asr.b	#1,d2
;	move.b	d2,\1(a0)
;		endm
;	shifthb	-4
;	shifthb	-3
;	shifthb	-2
;
;not_hbrite:
	dbf d0,build_color_table_loop
no_colortable:


	;ALWAYS close ham tool ;MAY21....(moved "here")
	xref FlagCloseWB_	;may07'89
	tst.b	FlagCloseWB_(BP)	;lomem situ?
	beq.s	2$			;nope
	xjsr	GoodByeHamTool	;remove ham screen (free up chip)
2$


		;if a brush load, ALWAYS use EXISTING palette
	tst.b	FlagBrush_(BP)
	beq.s	notabrush
	sf	FlagFilePalette_(BP)	;force 'use existing'/zerovalue if brush
	bra.s	Continue_Load		;branch when brush, zero/current flag
notabrush:
		;NEED a palette, anyway? If so, don't ask palette question.
	tst.l	ScreenPtr_(BP)		;have a bigpic
	bne.s	ask_palquest		;yes...ask question
	tst.l	UnDoBitMap_Planes_(BP)	;have an UNDO?
	bne.s	ask_palquest		;yes...ask question
	;tst.l	DetermineTablePtr_(BP)	;HAVE a palette? (did a createdetermine?0
	;bne.s	ask_palquest		;yes...ask question

	st	FlagFilePalette_(BP)	;force 'from file'
	bra.s	usepal_fromfile

ask_palquest:
	bsr	ComparePalettes 	;current/file palette the same?
	bne.s	reallyask		;palettes dont match, ask question
	move.l	#V_HIRES,d0
	and.l	FileCAMG_(BP),d0	;if hires file?...
	beq	end_of_reading_cmap	;... ask question "shrink hires?"
reallyask:
	xjmp	PaletteRequest		;"palette from file" "hires" "ok" "cancel"
		;...setus up gadgets, then back to 'main loop'...


Continue_Load:	;"after" flagrequest
	xref FlagOpen_
	tst.l	FileHandle_(BP)
	beq	Clup_EndLoad	;alternate//error ending point for iffload
	tst.B	FlagOpen_(BP)	;sup for 'opening' file?
	beq	Clup_EndLoad	;alternate//error ending point for iffload

	tst.b	FlagFilePalette_(BP)	;if using the file's palette,
	beq	end_of_reading_cmap	;no...not using the file's palette

usepal_fromfile:

	lea	FileColorTable_(BP),a0
	lea	LongColorTable_(BP),a1	;move.l	LongColorTablePtr_(BP),a1
	tst.b	FlagHamFile_(BP)	;ham file?
	bne.s	ham_copy_colortable	;yep...ham...use its palette
	cmp.b	#5,bmhd_nplanes_(BP)		;< 32 colors?
	bcs.s	just_copy_colortable	;yep...fewer'n 32

	;32 palettes in file...choose 16 colors from file like so...
	;	color 0 ALWAYS LEAVE ALONE (black?...or whatever...)
	;	color 1 ALWAYS LEAVE ALONE (white?...or whatever...)
	;	color 2 choose medium/dark
	;	color 3 choose medium/light
	;	colors 4-15: choose every other color from palette
	;original palette # 31,25,23,19,17,15,11,9,7,5,3,2,29,13
	;new palette #	15,14,13,12,11,10, 9,8,7,6,5,4, 3,2,
	move.l	31*4(a0),15*4(a1)
	move.l	25*4(a0),14*4(a1)
	move.l	23*4(a0),13*4(a1)
	move.l	19*4(a0),12*4(a1)
	move.l	17*4(a0),11*4(a1)
	move.l	15*4(a0),10*4(a1)
	move.l	11*4(a0),09*4(a1)
	move.l	09*4(a0),08*4(a1)
	move.l	07*4(a0),07*4(a1)
	move.l	05*4(a0),06*4(a1)
	move.l	03*4(a0),05*4(a1)
	move.l	02*4(a0),04*4(a1)
	move.l	29*4(a0),03*4(a1)
	move.l	13*4(a0),02*4(a1)
	bra.s	end_of_colortable
ham_copy_colortable:	;we got a ham file colors, so...
	moveq	#1,d0
	moveq	#0,d1
	move.b	bmhd_nplanes_(BP),d1
	asl.b	d1,d0	;# colors
	cmpi.b	#16,d0
	bcs.s	go_copy_table
	moveq.l	#16,d0
	bra.s	go_copy_table
just_copy_colortable:	;we had < 32 colors, so...
	moveq	#1,d0
	moveq	#0,d1
	move.b	bmhd_nplanes_(BP),d1
	asl.b	d1,d0	;# colors
	cmpi.b	#4,d0	;4 color file, using palette from file?
	bne.s	1$	;nope
	bsr	Compute4To16	;build 16 palette colors from 4 in file
	bra.s	end_of_colortable
   1$:	cmpi.b	#2,d0	;2 color file, using palette from file?
	bne.s	2$	;nope
	bsr	Compute2To16	;build 16 palette colors from 4 in file
	bra.s	end_of_colortable
   2$:	cmpi.b	#8,d0	;8 color file, using palette from file?
	bne.s	go_copy_table	;nope...just take the 16 colors?
	bsr	Compute8To16	;build 16 palette colors from 4 in file
	bra.s	end_of_colortable
go_copy_table:
	subq.b	#1,d0	;dbf type loop...
	cmpi.b	#15,d0	;only copying colors 2..15 if weird #colors, like 3 or 7
	bcc.s	move_fct_lct	;>= 16 colors total, copy them all
	lea	8(a1),a1	;ensures if <16 colors, we don't destroy 0,1

move_fct_lct:
	move.l	(a0)+,(a1)+	;strait copy color table
	dbf d0,move_fct_lct
end_of_colortable:

	;xref DetermineTablePtr_
	;lea	DetermineTablePtr_(BP),a0
	;xjsr	FreeOneVariable	;forces OpenBigPic redo colormap, redetermine
	xref FlagCDet_
	st	FlagCDet_(BP)	;'ask' for create determine to happen
end_of_reading_cmap:

	lea	FileBufferPtr_(BP),a0	;'free' the little buffer
	xjsr	FreeOneVariable
	;lea	LoadPlane0Ptr_(BP),a0	;april30
	;xjsr	FreeOneVariable

	tst.w	bmhd_rastheight_(BP)	;testing this 1st skips 0 ht body
	beq	gotscreen
	tst.b	FlagBrush_(BP)	;loading a brush? (dont chg scr size...)
	;may04;bne	gotscreen
	beq.s	1$
	sf	FlagHires_(BP)	;dont shrink brushes
	bra	gotscreen
1$
		;d0=wt,d1=ht from 'bmhd' (non-zero, now)

	xref NewSizeX_
	xref NewSizeY_
	move.w	bmhd_rastwidth_(BP),d0
	move.w	bmhd_rastheight_(BP),d1

	;may04;cmp.w	BigPicWt_W_(BP),d0
		;MAY03'89

	tst.b	FlagHires_(BP)	;shrinking?
	beq.s	noshrinktest
	asr.w	#1,d0
	add.w	#31,d0
	and.w	#~31,d0	;round up, even 32 widths
noshrinktest:

	cmp.w	BigPicWt_W_(BP),d0	;may04;
	bne.s	chgsize
	cmp.w	BigPicHt_(BP),d1
	;MAY23;beq.s	gotscreen
		;MAY23 late
		;rule: if x,y of screen same as file, use interlace from file
	bne.s	chgsize
	move.b	FlagLace_(BP),d0	;current interlace
	cmp.b	FlagLaceNEW_(BP),d0
	bne.s	yea_open
	bra.s	gotscreen

chgsize:
	tst.l	ScreenPtr_(BP)		;have a bigpic
	beq.s	yea_open		;no scr, so go open it
	xjsr	ScreenFormatRtn	;canceler.o, "change scr format" "requester"
	beq.s	gotscreen		;"keep" current screen
yea_open:
	move.w	bmhd_rastwidth_(BP),d0
	tst.b	FlagHires_(BP)	;shrinking?
	beq.s	noshrinkinput	;NewSizeX_(BP)
	asr.w	#1,d0
	add.w	#31,d0
	and.w	#~31,d0	;round up, even 32 widths
noshrinkinput:
	move.w	d0,NewSizeX_(BP)
	move.w	bmhd_rastheight_(BP),NewSizeY_(BP)

	;APRIL30;xjsr	CheckCancel	;canceler.o, funct here=just dump mouse moves
reallyopen:	;MAY16

	;	;MAY18....elim problem w/lomen, cant do size chg, etc
	;xref DefaultX_
	;xref DefaultY_
	;move.w	BigPicWt_W_(BP),DefaultX_(BP)
	;move.w	BigPicHt_(BP),DefaultY_(BP)


		;may18
	xref FlagLaceDefault_
	move.b	FlagLace_(BP),FlagLaceDefault_(BP)	;'other'
	;xref FlagNeedShowPal_
	;st	FlagNeedShowPal_(BP)	;causes color bar display (?)

	xjsr	OpenBigPic		;main.o;get screen (new size)
	bne.s	gotscreen

	move.b	FlagLaceDefault_(BP),FlagLace_(BP)	;MAY23

	xjsr	GoodByeHamTool		;MAY18...causes 're-open', mainloop
	;tst.b	FlagFilePalette_(BP)	;if using the file's palette,
	;seq	FlagCDet_(BP)
	PEA	CreateDetermine		;later, do this (might set alt-wait-pointer)

	;MAY18late
	;xref ScreenTooBigRtn		;"not enuff chip ram"
	;PEA	ScreenTooBigRtn		;"not enuff chip ram" (after buffer del)
	;sf	FlagOpen_(BP)		;clears "file open"//requester disp status
	;bra	Clup_EndLoad		;close file, etc
	;;rts				;iffload
	bra	NoMemory_Out

gotscreen:
	tst.l	ScreenPtr_(BP)	;MAY16
	beq.s	reallyopen


	;april30'89;xjsr	CheckCancel	;canceler.o, funct here=just dump mouse moves
	;MAY23;move.b	FlagLaceDefault_(BP),FlagLace_(BP)	;'other' MAY18
	xjsr	ResetIDCMP	;need idcmp on bigpic

;may21;		;MAY21
;may21;	xjsr	GrabExtraChip		;memories.o MAY21....
;may21;	bne.s	123$
;may21;	move.l	#1024,BufferLen_(BP)		;if no extra chip, use min buffer
;may21;123$:


	xjsr	GrabFileBuffer		;memories.o ;does the alloc' (if any avail)
	beq	Clup_EndLoad		;no buffer?
	xjsr	SetPointerWait		;'regular' waitpointer (sez 'iup-able')
	xjsr	HideToolWindow		;hide tools BEFORE scanning file (again)

	xjsr	ResetPriority		;main.o, '0' for dos (if not background)

	bsr	FindBMHDChunk		;RE-read bmhd_"fields" since open messed
	bne	Clup_EndLoad		;no go, flag error set
	tst.w	bmhd_rastheight_(BP)	;testing this 1st skips 0 ht body
	beq	Clup_EndLoad		;end_of_reading_lines

	move.l	#'BODY',d0		;use prev buffer again, amoment
	bsr	FindChunk		;set variable ChunkLength_(BP)
	tst.b	FlagError_(BP)		;error stat sup in FRead and SkipRead
	;JULY10;bne	Clup_EndLoad
		;july 10...ok if no body... (help w/startup...)
	beq.s	654$
	sf	FlagError_(BP)		;CLEAR error stat sup in FRead and SkipRead
	sf	FlagOpen_(BP)		;clears "file open"//requester disp status
	bra	Clup_EndLoad

654$

	lea	FileBufferPtr_(BP),a0	;'free' the little buffer
	xjsr	FreeOneVariable

	move.l	ChunkLength_(BP),BufferLen_(BP)	;new (desired) length
	beq	Clup_EndLoad		;wha? empty body chunk (bad iff, bad.)
	move.w	#1,BufferCount_(BP)	;effectively clears it

	;xjsr	GrabLoadPlane0		;memories.o ;does an alloc' if needed
	;beq	Clup_EndLoad		;no buffer? ...april27

;july01;		;MAY21
;july01;	xjsr	GrabExtraChip		;memories.o MAY21....
;july01;	bne.s	123$
;july01;	move.l	#1024,BufferLen_(BP)		;if no extra chip, use min buffer
;july01;123$:

	tst.b	FlagBrush_(BP)		;loading a brush?
	beq.s	getfileAndshowit
	xjsr	GrabFileBuffer		;memories.o ;does the alloc' (if any avail)
	beq.s	Clup_EndLoad		;no buffer?
	xjsr	AllocAndSaveCPUnDo	;march19'89
	xjsr	CopyScreenSuper
	xjsr	ClearBrushMask		;strokeb.o; Clear Brushstroke mask
	bra.s	skipfileButshowit	;already did GrabFileBuffer

getfileAndshowit:
	xjsr	GrabFileBuffer		;memories.o ;does the alloc'
	beq.s	Clup_EndLoad		;no buffer?
skipfileButshowit:			;remap_entry here<=
	;april30;xjsr	EnsureExtraChip		;has 'net' effect of de-alloc extra
	xjsr	UseColorMap		;does 'loadrgb4' on bigpic may01'eve
	xjsr	CreateDetermine		;(might set alt-wait-pointer)
	xjsr	SetPointerWait		;'regular' waitpointer (sez 'iup-able')
	xjsr	ResetPriority		;main.o, '0' for dos (if not background)
	bsr	ReadBody		;Ok, do line-by-line fill in screen
	tst.b	FlagOpen_(BP)	;happen?//finish ok?
	bne.s	Clup_EndLoad	;not finish ok....dont close file req
	bsr.s	Clup_EndLoad

		;may04'89
	tst.b	FlagBrush_(BP)
	beq.s	9$

	xjsr	EndFileRequ	;may06'89
	;;;;;;;xjsr	CheckCancel	;MAY04...dump mousemoves

;not needed?;	xjsr	InitCutPaste	;MAY06
	st	FlagText_(BP)	;stops 'cut' from flooding
	xjmp	CutLoadedBrush	;cutpaste.o, may06

	;xjsr	DoInlineAction
	;dc.w	'Sc'
	;dc.w	'is'
	;xjsr	DoInlineAction
	;dc.w	'Re'
	;dc.w	'do'
	;rts


9$
	xjmp	EndFileRequ		;gadgetrtns.o (ok-noeffect if remap)

NoMemory_Out:
	xref ScreenTooBigRtn		;"not enuff chip ram"
	PEA	ScreenTooBigRtn		;"not enuff chip ram" (after buffer del)
	sf	FlagOpen_(BP)		;clears "file open"//requester disp status
	;JULY10;bra	Clup_EndLoad		;close file, etc

Clup_EndLoad:	;alternate//error ending point for iffload
	;april30;xjsr	EnsureExtraChip		;de-alloc extra (incase nofilebuff)
	move.w	BigPicHt_(BP),bmhd_rastheight_(BP)  ;'SIZER' fix...next time
	move.w	BigPicWt_W_(BP),bmhd_rastwidth_(BP) ;...newsize=current
	sf	FlagHires_(BP)		;again, a fix for sizer
	;MAY23;move.b	FlagLaceDefault_(BP),FlagLace_(BP)	;'other' MAY18

	xjsr	ResetSizer		;only needed to reset FlagLaceNEW MAY08'89
	xjmp	Close_Load_File		;filertns.o, KILLS REMAP FLAG
	;rts


FindBMHDChunk:			;returns NE if error, EQ if ok
	move.l	#'BMHD',d0
	bsr.s	FindChunk		;set variable ChunkLength_(BP)
	tst.b	FlagError_(BP)	;error status set in FRead and SkipRead
	bne.s	9$	;Clup_EndLoad

	move.l	FileHandle_(BP),d1	;fill in bmhd_RECORD_ from file
	lea	bmhd_RECORD_(BP),a0	;calculate ADDRESS ON BASEPAGE
	move.l	a0,d2

	move.l	ChunkLength_(BP),d3	;#bmhd_SIZEOF ;# of bytes in d3

	move.L	#bmhd_SIZEOF_,d0
	cmp.w	d0,d3
	bcs.s	3$
	move.L	d0,d3	;enforce max len, dont overrun basepage vars
3$	CALLIB DOS,Read
	moveq	#0,d1	;sup flag ZERO, leave d0=#bytes read (dos result)
9$	rts

;===================
FRead:	;reads D0 bytes
	move.l	d0,d3		;ados-Read wants # of bytes in d3
	move.l	FileHandle_(BP),d1
	move.l	FileBufferPtr_(BP),d2
	CALLIB DOS,Read
	tst.l	d0		;d0=actual length read
	bne.s	read_ok		;note: "junping around" set-flag allows
	st	FlagError_(BP)	;...an error to 'propagate'---desired!
read_ok:
	rts


ReadLong:	;Reads 4 bytes, 1 long word, returns data in D0 (also errstat)
	moveq	#4,d0
	bsr.s	FRead
	move.l	FileBufferPtr_(BP),a0
	move.l	(a0),d0			;the 4 bytes we just read
	rts

;======================
FindChunk: ;finds chunk name d0 (d0=4 ascii chars) IN CURRENT FORM
	;sets variable ChunkLength_(BP) = d0
	;leaves filepointer (for another read) just before chunk data

	move.l	d0,ChunkName_(BP)
	sf	FlagError_(BP)

	;seek to beginning of current Form
	move.l	FileHandle_(BP),d1
	move.l	FormDataPos_(BP),d2	;position after "FORM" "formlength"
	move.l	#OFFSET_BEGINNING,d3
	CALLIB DOS,Seek

top_of_seek_chunk:	;see if this is chunk we are lookin for
	tst.b	FlagError_(BP)
	bne.s	find_chunk_error
	bsr	ReadLong	;get d0=4 byte long word at current position
	cmp.l	ChunkName_(BP),d0
	bne.s	skip_chunk
	bsr.s	ReadLong	;this is our chunk's length
	move.l	d0,ChunkLength_(BP)
	rts	;end of seeking, found nirvana

skip_chunk:	;each chunk must be padded to be an even # bytes long
	bsr.s	ReadLong	;get d0 = number of bytes to skip
	RoundUp	d0		;make sure d0 is an even number
	bsr.s	SkipRead	;Skip 'em
	bra.s	top_of_seek_chunk	;takes us to top of next chunk

find_chunk_error: ;
	rts

SkipRead:	;Skips d0 bytes in file
	move.l	FileHandle_(BP),d1
	move.l	d0,d2	;position / number of bytes
	move.l	#OFFSET_CURRENT,d3
	CALLIB DOS,Seek
	cmp.l	#-1,d0	;error?
	bne.s	skipread_ok
	st	FlagError_(BP)
skipread_ok
	rts

;======================
FindILBMForm:  ;finds form d0 (d0=4 ascii chars) seeking from current pos
	;sets variables FormLength_(BP), FormDataPos_(BP)
	;leaves filepointer (for another read) just BEFORE chunk data
	;...and AFTER the form name

	;seek to beginning of current File
	move.l	FileHandle_(BP),d1
	move.l	#0,d2	;position zero
	move.l	#OFFSET_BEGINNING,d3
	CALLIB DOS,Seek
	tst.l	d0	;file position
	bne	find_form_error

top_of_seek_form:	;see if this is form we are lookin for
	tst.b	FlagError_(BP)
	bne.s	find_form_error
	bsr	ReadLong	;get d0=4 byte long word at current position
	cmp.l	#'FORM',d0
	bne.s	skip_form
	bsr	ReadLong
	move.l	d0,FormLength_(BP)
	bsr	ReadLong

	cmpi.l	#'ANIM',d0	;we go INSIDE the anim form
	beq.s	top_of_seek_form ;;06/25;; go >inside this form, look for ilbm
	;...data should look like: FORM nnnn ANIM FORM nnnn ILBM .. (?BMHD nnnn)

	cmpi.l	#'ILBM',d0	;ah ha! here it is!
	bne.s	skip_to_next_form ;;adjust ptr past end of current form

;found_formilbm:
	;this is our form, set FormDataPos_(BP)=after formid, set FormLength_(BP) += -4
	move.l	FileHandle_(BP),d1
	move.l	#0,d2	;get current position
	move.l	#OFFSET_CURRENT,d3
	CALLIB DOS,Seek
	move.l	d0,FormDataPos_(BP)
	move.l	FormLength_(BP),d0
	sub.l	#4,d0
	move.l	d0,FormLength_(BP)
	rts	;end of seeking, found our form

skip_to_next_form:	;pointer now after form name "FORMhhhhNNNN"^
	move.l	FileHandle_(BP),d1
	move.l	#-8,d2	;backup 8 positions
	move.l	#OFFSET_CURRENT,d3
	CALLIB DOS,Seek
skip_form:	;each form must be padded to be an even # bytes long
	bsr ReadLong	;get d0 = number of bytes to skip
	RoundUp d0	;make sure d0 is an even number
	bsr SkipRead	;Skip 'em
	bra top_of_seek_form	;takes us to top of next form

find_form_error:
	rts


read_comp_plane: macro	;plane# -----
  ifne \1	;if not plane zero...
	cmp.b	#\1+1,LoadDepth_(BP) ;#bitplanes to be loaded
	bcs	end_read_compr_planeS
  endc
	moveq	#0,Nliteral	;init for Uncompress_next_byte
	moveq	#0,Nduplicate
	moveq	#0,Datadup
	move.W	filebpr_less1_(BP),d4	;number of bytes to readLESS1
	move.l	LoadPlane0Ptr_(BP),a3	;1st time adr
   ifne \1
	lea	(\1*128)(a3),a3	;n'th load plane
   endc
read_compr_byte\@:
	Uncompress_next_byte d4,read_compr_byte\@ ;next byte to (a3)+
	endm	;read_comp_plane

read_notc_plane: macro	;plane#
   ifne \1				;if not plane zero...
	cmp.b	#\1+1,LoadDepth_(BP)	;are there this many planes in the file?
	bcs.s	end_read_plane\@	;nope
   endc
	move.l	LoadPlane0Ptr_(BP),a3
   ifne \1
	lea	(\1*128)(a3),a3
   endc
	move.W	filebpr_(BP),-(SP)	;using STACK for loopctr (rucb\@)
rucb\@:
	ReadOneByte_a3		;reads byte into (a3)+
	subq.W	#1,(sp)
	bne.s	rucb\@
	lea	2(sp),sp	;clup stack
end_read_plane\@:
	endm	;read_notc_plane ----


ReadBody:	;read (buffered) file 'body' and display on screen

;;  xjsr DebugMe1
	sf	FlagBitMapSaved_(BP)	;set 'undo' status (not saved)
	clr.w	ldline_w_(BP)
	clr.L	ldlineoffset_(BP)

		;handle remap MAY23
	move.l	BigPicWt_(BP),d0
	tst.b	FlagRemap_(BP)
	bne.s	12$

	moveq	#0,d0
	move.w	bmhd_rastwidth_(BP),d0
12$:			;MAY23....for remap
	add.w	#15,d0		;round up
	asr.w	#4,d0		;/16 = #words of bits on a scan line
	add.w	d0,d0		;*2=number of bytes of bits on a scan line
	move.W	d0,filebpr_(BP)
	subq	#1,d0
	move.W	d0,filebpr_less1_(BP)

	xjsr	InitBitNumSA ;scratch.o; SaveArray, inits s_BitNumber fields
	move.b	bmhd_nplanes_(BP),LoadDepth_(BP) ;read_one_comp_...wants this
	beq	end_of_reading_lines	;JULY10...help w/"0" bitplanes in bmhd

	move.b	bmhd_masking_(BP),d0
	beq.s	read_a_line		;get going, no mask plane
	cmp.b	#1,d0			;"hasmaskplane" type?
	bne.s	read_a_line		;get going, no mask plane
		;if d0=2="hastranspcolor" THEN should 'build a mask'
	cmp.b	#7,LoadDepth_(BP)	;'old' digipaint brush?
	beq.s	read_a_line		;yep, mask accounted for
	addq.B	#1,LoadDepth_(BP)	;else count mask as another 'read' plane



read_a_line:	;top of the 'main' loop, executing "here" at beginning of line
		;CHECK FOR CANCEL before 'main' read...(after createdetermine)
	;works to here...;BRA	end_of_reading_lines	;KLUDGE....make it this far? readbody blows up...

;;  xjsr DebugMe2


	xjsr	ScrollAndCheckCancel	;returns EQ/NE, a0=msgptr d0=im_Class
	beq.s	skip_cancel_request	;not= means either button was pressed
	xjsr	Canceler 		;canceler.o,  cancel/continue REQUESTER
	bne	end_of_reading_lines
;;  xjsr DebugMe3
	xjsr	HideToolWindow		;re-hide toolbox after requester
;;  xjsr DebugMe4

skip_cancel_request:

	;...fill in SaveArray records with the appro' dither thresh values
	tst.B	FlagHires_(BP)		;'shrinking'? need dither?
	beq.s	endof_dithersetup	;no 'new' dither to do
	tst.W	FlagDither_(BP)		;this checks for random flag, too
	beq.s	endof_dithersetup	;no 'new' dither to do
	tst.B	FlagDither_(BP)
	beq.s	dosetupr
			;SETUP DITHER FROM MATRIX
		;movem.l	d4/a0/a1/a6,-(sp)	;SssssSTACK
	move.w	ldline_w_(BP),d4
	andi.w	#7,d4		;use line # mod 8
	asl.w	#3,d4		;*8
	lea	ThresholdTable(pc),a0
	lea	0(a0,d4.w),a0	;reset to this 'start of a line of 8 byte values'
	move.l	a0,a1		;re-setup threshold ptr
	lea	SaveArray_(BP),a6 ;use the save table as source
	lea	s_DitherThresh(a6),a6 ;use the save table as source
	move.w	bytes_row_less1_W_(BP),d4
tdbyte:	moveq	#8-1,d5		;db' type # bitsinabyte
tdbit:
	move.B  (a1)+,(a6)	;byte from table, into savearray thresh'
	lea	s_SIZEOF(a6),a6

	dbf	d5,tdbit
	move.l	a0,a1	;re-setup threshold ptr
	dbf	d4,tdbyte
		;movem.l	(sp)+,d4/a0/a1/a6	;De-SssssSTACK

	bra.s	endof_dithersetup	;no 'new' dither to do
dosetupr:	;SETUP DITHER 'RANDOMLY'
		;movem.l	d4/a0/a1/a6,-(sp)	;SssssSTACK
	move.w	ldline_w_(BP),d4
	lea	SaveArray_(BP),a6 ;use the save table as source
	lea	s_DitherThresh(a6),a6 ;use the save table as source
	move.w	bytes_row_less1_W_(BP),d4
rbyte:	moveq	#8-1,d5		;db' type # bitsinabyte
rbit:
	MOVE.W	random_seed_(BP),D0	;compute next random seed (longword)
	LSR.W	#1,D0
	BCC.s	109$	;norflip\@
	EOR.W	#$B400,D0	;algo ref: Dr. Dobb's Nov86 pg 50,55
109$:	;norflip\@:
	MOVE.W	D0,random_seed_(BP)
	and.b	#$3f,d0
	move.b	d0,(a6)	;new 'random' dither threshold
	lea	s_SIZEOF(a6),a6

	dbf	d5,rbit
	move.l	a0,a1	;re-setup threshold ptr
	dbf	d4,rbyte
		;movem.l	(sp)+,d4/a0/a1/a6	;De-SssssSTACK

endof_dithersetup:

	;dither fix

	;LOOP to *fix* DITHER THRESHOLDS
	;...fill in SaveArray records with the appro' dither thresh values
	;NEED TO ZERO OUT DITHER?;tst.W	FlagDither_(BP)	;either dither?
	;NEED TO ZERO OUT DITHER?;beq	endof_ditherfix

	;re-enabled june28
	move.w	bytes_row_less1_W_(BP),d4
	;addq.w	#1,d4	;=bytes per row   april30
	;asr.w	#1,d4	;=words per row   april30
	;subq.w	#1,d4	;=words per row-1 april30

	;june28;xref lwords_row_less1_	;WORD size field
	;june28;move.w	lwords_row_less1_(BP),d4	;MAY03'89 use LONG words
	
	lea	SaveArray_(BP),a6 ;use the save table as source
	lea	s_DitherThresh(a6),a6

fix_dithbit:	MACRO
	move.B  (a6),d0
	SUBQ.B	#3,d0	;flip dither since subtracting
	bcc.s	okdnneg\@
	moveq	#0,d0	;neg.b	d0
okdnneg\@:
	move.b	d0,(a6)	;dither value.b FROM table INTO savearray
	lea	s_SIZEOF(a6),a6
	ENDM
fixdbyte:	MACRO
	fix_dithbit
	fix_dithbit
	fix_dithbit
	fix_dithbit

	fix_dithbit
	fix_dithbit
	fix_dithbit
	fix_dithbit
	ENDM

fdithlw:
	;fixdbyte
	;fixdbyte
	;fixdbyte

	fixdbyte
	dbf	d4,fdithlw

endof_ditherfix:
	;;;BRA	end_of_reading_lines	;KLUDGE....make it this far? readbody blows up...


		;COPY SCREEN HAM LINE to SaveArray rgb'type fields
		;...this is both for remap'ing AND keeping rightedge ok
		;(not needed if bigpicwt=loadpicwt)
	move.l	d0,-(sp)		;stack width in pixels
	move.L	BigPicWt_(BP),d0

		tst.b	FlagRemap_(BP)
		;may01...only unplot if not remapping...no picture kleanup...
		;bne.s	noskipunp
		;cmp.w	bmhd_rastwidth_(BP),d0
		;bcs.s	skipunp		;loadpic is wider
		beq.s	skipunp		;loadpic is same width (else skinnier)
noskipunp:
	;MAY23
	;MOVEM.L d1-d7/a0-a4,-(sp)	;YUCK
	;move.L	ldlineoffset_(BP),d1
	;lea	SaveArray_(BP),a6
	;;;;;no no no...may01;lea	s_Paintred(a6),a6
	;xjsr	UnPlot_ScreenArray	;lineplot.o
	;MOVEM.L	(sp)+,d1-d7/a0-a4	;deYUCK

		;MAY23...dupl loop...sup paint red, too
	MOVEM.L d1-d7/a0-a4,-(sp)	;YUCK
	move.L	ldlineoffset_(BP),d1
	lea	SaveArray_(BP),a6
	lea	s_Paintred(a6),a6
	xjsr	UnPlot_ScreenArray	;lineplot.o
	MOVEM.L	(sp)+,d1-d7/a0-a4	;deYUCK

skipunp:
	move.l	(sp)+,d0		;#pixels

;    de-plots a ham line into SaveArray given:
;     d0.l = number of pixels ( this is # of PIXELS, will be /32 for words)
;     d1.w = plane offset start of line
;     a6   = ptr to a 'savearray' struct
;  basicly, it just fills bytes into memory, at s_SIZEOF addr's apart



	tst.b	FlagRemap_(BP)
	bne	done_reading_planes

not_hiresread:
	tst.b	bmhd_compression_(BP)
	bne	read_comp_planes
;read_uncomp_planes:
	read_notc_plane 0
	read_notc_plane 1
	read_notc_plane 2
	read_notc_plane 3
	read_notc_plane 4
	read_notc_plane 5
	read_notc_plane 6		;(mask plane,if any)
	bra	rotate_load_planes	; done_reading_planes
read_comp_planes:
	read_comp_plane 0
	read_comp_plane 1
	read_comp_plane 2
	read_comp_plane 3
	read_comp_plane 4
	read_comp_plane 5
	read_comp_plane 6		;(mask plane,if any)

end_read_compr_planeS:

rotate_load_planes:	;load PLANES -> palette#.b in savearray records
	;only using a6,a0 'a-regs' - these s/b free for here (er, 'now')
		;;movem.L	d0-d7,-(sp)	;d4,d5,d6 (7?) used by unpacker a4, too
	lea	SaveArray_(BP),a6	;s_red = 0 offset
	lea	s_Paintred(a6),a6	;'pen color' palette# here TEMPORARY
	move.l	LoadPlane0Ptr_(BP),a0	;plane 0 (others (1024/8)=128 bytes @)
	move.W	filebpr_(BP),-(sp)	;# of BYTEs in a row from file in d3
rota8:
	;WO!;move.b	(6*128)(a0),d6	;SEVENTH plane for mask
	move.b	(5*128)(a0),d5
	move.b	(4*128)(a0),d4	;note: unused bitplanes are always zero'd (?)
	move.b	(3*128)(a0),d3	;MAYBE BUG clear loadplanes @ start
	move.b	(2*128)(a0),d2
	move.b	(1*128)(a0),d1
	move.b	(a0)+,d0	;FIRST bitplane (only one, sometimes)

rotd067:	macro	;rotate d0-d5 into d7
	moveq	#0,d7	;clears top (after rotate) bit
	;WO!;roxl.b	#1,d6
	;WO!;roxl.b	#1,d7
	roxl.b	#1,d5
	roxl.b	#1,d7
	roxl.b	#1,d4
	roxl.b	#1,d7
	roxl.b	#1,d3
	roxl.b	#1,d7
	roxl.b	#1,d2
	roxl.b	#1,d7
	roxl.b	#1,d1
	roxl.b	#1,d7
	roxl.b	#1,d0
	roxl.b	#1,d7
	move.b	d7,(a6)		;s_Paintred, current record
	lea	s_SIZEOF(a6),a6	;next record
	endm	;rotd067	;rotate d0-d6 into d7

	rotd067			;1st; rotates d0-d6 into d7 -> s_Paintred
	rotd067			;2
	rotd067
	rotd067
	rotd067
	rotd067
	rotd067			;7th
	rotd067			;8th entry/ new recor
	subq.w	#1,(sp)
	bne	rota8
	lea	2(sp),sp	;rota8 loop counter

		;;movem.L	(sp)+,d0-d7


done_reading_planes:
	MOVE.L	a4,-(sp)	;file input buffer ptr (gonna be determinertn)
	move.l	DetermineRtn_(BP),a4	;...a4 also used again, before re-loop

	;if we got a brush, WE REALLY WANNA STRIP MASK OR SOMETHING (Above)
	;if this is a 7 plane thingie,
	;...so copy plane6 (the 7th) ->brush bitmap  (BB1Ptr_(BP)->single stroke)
	tst.b	FlagBrush_(BP)		;if we got a brush,
	beq.s	gotmask			;not loading a brush (pic)...have mask
	cmp.b	#7,LoadDepth_(BP)	;bmhd_nplanes_(BP)
	bne.s	gotmask			;if this is a 7 plane thingie,
	move.l	LoadPlane0Ptr_(BP),a0
	lea	(6*128)(a0),a0		;lea	plane6_(BP),a0

	move.L	ldlineoffset_(BP),d1
	move.l	BB1Ptr_(BP),a1		;regular screen size mask
	lea	0(a1,d1.L),a1
	;move.W	filebpr_(BP),d0		;file 'bytes per row'
	move.W	filebpr_less1_(BP),d0	;file 'bytes per row'
copmask	move.b	(a0)+,(a1)+
	dbf	d0,copmask
gotmask:
	lea	FileColorTable_(BP),a3	;used HERE & by ComputeOnePixel
	move.l	(a3),Pred_(BP)		;colors the FILE THINKS is at left edge
	lea	LongColorTable_(BP),a0

	;MAY01;move.l	(a0),Predold_(BP)	;colors ACTUALLY SEEN at screen left edge
	move.l	(a0),d3
	clr.B	d3
	move.l	d3,Predold_(BP)	;colors ACTUALLY SEEN at screen left edge

	lea	SaveArray_(BP),a6
	moveq	#0,d3			;for each pixel on a line...
	tst.b	FlagBrush_(BP)
	bne	do_plot_brush_pixel	;**** SEP. RTNS FROM BRUSH,PIC

	move.w	bmhd_rastwidth_(BP),-(sp)	;STACKing loop counter
do_plot_pixel:
	ComputeOnePixel			;s_Paint(rgb)=> Pred_

	move.l	Predold_(BP),(a6)	;save "Real" r.b,g.b,b.b,lastplot.b
	;move.b	d0,s_LastPlot(a6)
	lea	s_SIZEOF(a6),a6		;next record in SaveArray
	subq.w	#1,(sp)
	bne.s	do_plot_pixel

	lea	2(sp),sp		;DESTACK loop counter


		;DO HIRES SHRINKER...
	tst.b	FlagHires_(BP)	;ODD #'d lines get 'doubled' if source=HIRES
	beq.s	nopicloadshrink
	bsr	CompressHires		;SHRINKS IT hires-->ham pixel widths

		;THEN RECOMPUTE WHAT TO PLOT
	lea	SaveArray_(BP),a6
	moveq	#0,d3			;for each pixel on a line...
	move.w	bmhd_rastwidth_(BP),d0
	asr.w	#1,d0
	move.w	d0,-(sp)	;STACK LOOP COUNTER,compute plot 6bit pixels
do_plot_hipixel:
	move.w	s_Paintred(a6),Pred_(BP)	;red, green to compute//plot
	move.b	s_Paintblue(a6),Pblue_(BP)	;blue to plot/compute
	jsr	(a4)	;DetermineRtn ;return d0=6bit plotvalu and P(rgb)old
	move.b	d0,s_LastPlot(a6)
	lea	s_SIZEOF(a6),a6	;next record in SaveArray
	subq.w	#1,(sp)
	bne.s	do_plot_hipixel
	lea	2(sp),sp	;DESTACK loop counter

nopicloadshrink:

	bra	end_of_plotpixels


do_plot_brush_pixel:	;*** BRUSH *****
	move.w	d3,pxnumber_w_(BP)	;pixel#=bit#
	ComputeOnePixel	;Pixel_number_w=Pixel# d3=byte#_in_line
		cmp.b	#7,LoadDepth_(BP) ;bmhd_nplanes_(BP)	;ok we have a mask, is it in the 7th plane?
		beq.s	nosetmask	;...yes, we already have our mask

		move.l	a0,-(sp)	;STACK
		move.w	d0,-(sp)	;STACK
		cmp.b	#2,bmhd_masking_(BP)	;if bmhd_masking of 2 = transp color
		bne.s	setup_mask_bits

	;TRANSPARENT COLOR MASK BUILD
		move.l	BB1Ptr_(BP),a0	;brush bitmap
		moveq	#7,d0
		moveq	#0,d1		;clear upper word (adr use inamoment)
		move.w	pxnumber_w_(BP),d1
		sub.w	d1,d0		;d0=pixel#
		asr.w	#3,d1		;x/8=byte addr off
		add.l	ldlineoffset_(BP),d1	;d0=bit#, d1=bitplane offset

		move.W	bmhd_tpcolor_(BP),d2
	;xref LastPlot_
		cmp.b	s_Paintred(a6),d2 ;LastPlot_(BP),d2 ;color//pixel = transp?
		bne.s	set_a_mask_bit
		bra.s	no_mask_bit


setup_mask_bits:	;regular masking (no mask bitplane)
		move.l	BB1Ptr_(BP),a0	;brush bitmap
		moveq	#7,d0
		moveq	#0,d1		;clear upper word (adr use inamoment)
		move.w	pxnumber_w_(BP),d1
		sub.w	d1,d0		;d0=pixel#
		asr.w	#3,d1		;x/8=byte addr off
		add.l	ldlineoffset_(BP),d1

	xref FlagSkipTransparency_
	xref Transpred_
	xref Transpgreen_
	xref Transpblue_
		tst.b	FlagSkipTransparency_(BP)
		bne.s	set_a_mask_bit	;no transp, alway sup mask

			;build mask bits, P(rgb) set, d0=lastplot
		;tst.b	1(sp)	;palette #0? ("6bitpixl to plot" saved on stack)
		;beq.s	no_mask_bit
		move.b	Pred_(BP),d2		;check r,g,b for black 0,0,0
		cmp.b	Transpred_(BP),d2
		bne.s	set_a_mask_bit
		move.b	Pgreen_(BP),d2
		cmp.b	Transpgreen_(BP),d2
		bne.s	set_a_mask_bit
		move.b	Pblue_(BP),d2
		cmp.b	Transpblue_(BP),d2
		beq.s	no_mask_bit	;black (r=0,g=0,b=0)
			;ok, set the mask bit
set_a_mask_bit:	bset	d0,0(a0,d1.L)	;set bit indicating not transparent
		bra.s	after_mask_set
no_mask_bit:	bclr	d0,0(a0,d1.L)	;set bit indicating not transparent
after_mask_set:
		move.w	(sp)+,d0
		move.l	(sp)+,a0	;STACK
nosetmask:
		move.l	Pred_(BP),(a6)+  ;Pred_(BP),(a6)	;save rgb for this pixel...in case we wanna do?
		move.b	d0,-1(a6)	;d0,s_LastPlot(a6)
		;;;noneed;;;move.w	d1,(a6)+	;d1,s_PlaneAdr(a6)  MAY06....WORD???
		;;;lea	(s_SIZEOF-6)(a6),a6
		lea	(s_SIZEOF-4)(a6),a6
	;;moveq	#0,d3 
	move.w	pxnumber_w_(BP),d3
	addq #1,d3
	cmp.w	bmhd_rastwidth_(BP),d3
	bcs do_plot_brush_pixel

end_of_plotpixels:	;**** CONTINUE BOTH ********
		;copy SaveArray to output window
	move.w	filebpr_(BP),d0		;lineplot WANTS/EXPECTS groups of 32...
	addq.w	#3,d0	;round up bytes per row to 'even' longwords
	and.w	#~3,d0
	asl.w	#3,d0	;<<3=*8 bytes to pixels

	tst.b	FlagHires_(BP)
	beq.s	1$
	asr.w	#1,d0			;1/2 width if hires shrunk
;may01;	bra.s	2$			;APRIL03'89....dont over-run shrunk
;APRIL03'89;1$	add.w	#(8*4),d0		;one lword wider (clup existing image)
1$
;may01;	add.w	#(8*4),d0		;one lword wider (clup existing image)
;may01;2$
	cmp.w	BigPicWt_W_(BP),d0	;our (smaller?) rastwidth
	bcs.s	picfits			;on current screen
	move.w	BigPicWt_W_(BP),d0	;our (smaller!) rastwidth
picfits:

	move.L	ldlineoffset_(BP),d1	;d1.w= plane offset this start of line
	lea	SaveArray_(BP),a6	;a6.l= ptr to SaveRGB structure

	movem.l	d0-d7/a0-a6,-(sp)	;ug
	xjsr	LinePlot_SaveArray
	movem.l	(sp)+,d0-d7/a0-a6

  MOVE.L	(sp)+,a4	;file input buffer ptr (WAS determinertn)

	move.L	bytes_per_row_(BP),d1	;this is declared as a LONG
	add.L	ldlineoffset_(BP),d1
	move.L	d1,ldlineoffset_(BP)	;saved incr'd y offset into plane

	move.w	ldline_w_(BP),d0
	addq	#1,d0
	move.w	d0,ldline_w_(BP)	;d0=new,'next' line#

	cmp.w	BigPicHt_(BP),d0
	bcc.s	normal_done		;if d0<=ht, outta here
	cmp.w	bmhd_rastheight_(BP),d0
	bcs read_a_line
normal_done:			;note: if "cancel"d, then keeps filereq status
	sf	FlagOpen_(BP)	;clears "file open"//requester disp status

	;xjmp	EndFileRequ	;gadgetrtns.o (ok if remap) clear f-open status
end_of_reading_lines:
	rts ;--- ReadBody -----


CompressHires:		;hires-->ham pixel widths
	include "ds:iffload.shrink.i"
	rts		;CompressHires

	include	"ds:iffload.i"	;Compute4To16,2To16
	rts

ComparePalettes:	;returns zero flag, current/file palette the same?
	lea	FileColorTable_(BP),a0
	lea	LongColorTable_(BP),a1	;move.l	LongColorTablePtr_(BP),a1
	moveq	#(16-1),d0
cpalloop:
	move.l	(a1)+,d1	;long ,g,b,brite
	clr.B	d1		;strip brite

	move.L	(a0)+,d2	;file's color+brite
	clr.B	d2		;strip brite

	cmp.l	d1,d2
	bne.s	9$
	dbf	d0,cpalloop

	moveq	#0,d0		;flag zero, now (palettes match)
9$
	xref FlagPaleMatch_	;iffload.o, ComparePalette result, file=curt?
	seq	FlagPaleMatch_(BP)
	rts

	xref FileBufferPtr_	;GENERAL PURPOSE FILE BUFFER
	xref BufferLen_		;ds.l	it's length
	xref BufferCount_	;ds.w	it's current count//ptr
	xref LoadPlane0Ptr_	;SLong
	xref FileColorTable_ 	;(64*4)	;used for holding rgb's from file

	xref FlagError_		;ds.b	1	;=-1 if error
	xref FlagHamFile_	;ds.b	1	;0 if not, -1 if HAM file
	xref FormDataPos_	;ds.l	1
	xref FormLength_	;ds.l	1
	xref ChunkName_		;ds.l	1
	xref ChunkLength_	;ds.l	1

; fields used by ReadBody

	xref ldline_w_		;current line number
	xref ldlineoffset_	;byte # for start of current line

	xref filebpr_		;number of bytes per row in the file
	xref filebpr_less1_	;number of bytes per row in the file

	xref pxnumber_w_	;ds.w 1
	xref mask_b_	;ds.b 1 ;bit# in byte

; BMHD save fields (Bit Map HeaDer)
	xref bmhd_RECORD_
	xref bmhd_rastwidth_
	xref bmhd_rastheight_
	xref bmhd_nplanes_
	xref bmhd_masking_
	xref bmhd_compression_
	xref bmhd_tpcolor_
	xref bmhd_xaspect_
	xref bmhd_yaspect_
	xref bmhd_pagewidth_
	xref bmhd_pageheight_
	xref bmhd_SIZEOF_	;size of bmhd area


	END

