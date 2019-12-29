* NewFlood.asm
	;XDEF Contour
	XDEF DoFlood

	XDEF DoColorFlood	;new, digipaint pi

	xref FlagDisplayBeep_

	include "exec/types.i"
	include "ps:basestuff.i"
	include "ps:SaveRgb.i"
	include "graphics/gfx.i"
	include "graphics/rastport.i"
	include	"ps:serialdebug.i"

	xref	FlagFillMode_
	xref	FillTblPtr_
	xref	TextMask_RP_
	xref	BB_BitMap_
	xref	BB_BitMap_Planes_	;alternate name is 'BB1Ptr'
	xref	UnDoBitMap_
	xref	ppix_row_less1_
	xref	bytes_per_row_
	xref	bytes_per_row_W_
	xref	SAStartRecord_	;1st pixel's "record" inside savearray
	xref	SaveArray_
	xref	BigPicHt_
	xref	linecol_offset_
	;;xref	col_offset_
	xref	LongColorTable_	;zero, beginning of basepage
	xref	Predold_
	xref	MyDrawX_
	xref	MyDrawY_

;;SERDEBUG	equ	1
	ALLDUMPS




	xdef helpdebug1
helpdebug1:
	DUMPREG <helpdebug1>		
	rts



DoColorFlood:	;new, digipaint pi
		;set brush bitplane to 'flood fill area'

	DUMPMSG	<in DoColorFlood>

	;DigiPaint Pi...do "fill mode colors"
	tst.b	FlagFillMode_(BP)
	beq	after_fm
	tst.l	FillTblPtr_(BP)
	beq	after_fm
	DUMPMSG	<Still in DoColorFlood001m>
	;;;no need;;;xjsr	SetEntireScreenMask	;memories.o, whole screen mask

	xjsr	ClearBrushMask		;Clear out Brush/Repaint mask (StrokeB.asm) SEP021990

		;now, selectively 'unmask' based on colors
		;...steal loop from Scratch (temp)

		;GET R-G-B COLORS
		;setup/define needed variables for 'stolen' loop
	lea	SaveArray_(BP),a6
	move.l	a6,SAStartRecord_(BP)	;1st pixel's "record" inside savearray

	move.w	bytes_per_row_W_(BP),d0
	asl.w	#3,d0			;#bytes*8=#pixels
	subq	#1,d0
	move.w	d0,ppix_row_less1_(BP)

	;LOOP DE-PLOT a ham line into SaveArray given:
	;clr.W	-(sp)		;STACK!!! used in next 'flagged twice' loop

		;"for each row"
	;clr.l	linecol_offset_(BP)
	;move.w	BigPicHt_(BP),-(sp)
		;"for each row"
	clr.l	linecol_offset_(BP)
	move.w	BigPicHt_(BP),d0
	sub.w	MyDrawY_(BP),d0
	move.W	d0,-(sp)	;loop counter MyDrawY'th row to bottom...
	;;subq.l	#1,d0
	;;bcs.s	for_uprow
	move.l	bytes_per_row_(BP),d0
	mulu	MyDrawY_(BP),d0
	move.l	d0,linecol_offset_(BP)	;offset to MyDrawY-1'th line


for_eachrow:

	move.l	linecol_offset_(BP),d1
	bsr	GetLineOfColors		;fills savearray with rgb values


		;PACK/BUILD UP THE MASK BITPLANE, based on plotflag
	;STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one
	asr.w	#3,d3			;bytes per row
	move.l	BB_BitMap_Planes_(BP),a1	;"real" mask
	add.l	linecol_offset_(BP),a1		;current row
	move.l	FillTblPtr_(BP),a0	;'rgb' table of "colors to fill"
	moveq	#0,d1	;flag for 'any mask bits in line'?
packm_loop:
pack1:	MACRO		;macro for unrolled loop
	move.W	(a6),d5			;=0000rrrr 0000gggg
	asl.B	#4,d5			;=0000rrrr gggg0000
	or.b	s_blue(a6),d5		;=0000rrrr ggggbbbb

	tst.b	0(a0,d5.w)	;is current pixel's color in fill-table?
	sne	d2		;this sets/clears d2.byte
	roxr.W	#1,d2		;.word saves (temp) result in top byte, too
	;roxl.b	#1,d0
	addx.b	d0,d0

	lea	s_SIZEOF(a6),a6
	ENDM	;pack1

	pack1
	pack1
	pack1
	pack1

	pack1
	pack1
	pack1
	pack1
		;note: (d2 && $ff00) not= 0 if any pixels set//marked
	or.w	d2,d1		;save top byte of flag word...any marked?
	move.b	d0,(a1)+	;new mask byte
	dbf	d3,packm_loop
		;note: (d1 && $ff00) not= 0 if any pixels set//marked
	tst.w	d1	;any bits get flagged in this line?
	beq.s	done_dn

;nextrow:
	xjsr	ScrollAndCheckCancel	;canceler.o
	beq.s	nocancel
	addq.w	#2,sp			;stack clup, aborting
	bra	after_fm
nocancel:
	move.l	bytes_per_row_(BP),d0
	add.l	d0,linecol_offset_(BP)
	subq.w	#1,(sp)
	bne	for_eachrow
done_dn:
	addq	#2,sp

;SECOND 'PASS' ASCENDING UP SCREEN FROM MYDRAWY
*********************************************************************
		;GET R-G-B COLORS
		;setup/define needed variables for 'stolen' loop
	lea	SaveArray_(BP),a6
	move.l	a6,SAStartRecord_(BP)	;1st pixel's "record" inside savearray

	move.w	bytes_per_row_W_(BP),d0
	asl.w	#3,d0			;#bytes*8=#pixels
	subq	#1,d0
	move.w	d0,ppix_row_less1_(BP)

	;LOOP DE-PLOT a ham line into SaveArray given:
	;clr.W	-(sp)		;STACK!!! used in next 'flagged twice' loop

		;"for each row"
	clr.l	linecol_offset_(BP)
	;move.w	BigPicHt_(BP),-(sp)
	move.w	MyDrawY_(BP),d0
	move.w	d0,-(sp)	;loop counter
	subq.l	#1,d0
	bcs.s	for_uprow
	move.l	bytes_per_row_(BP),d3
	mulu	d3,d0
	move.l	d0,linecol_offset_(BP)	;offset to MyDrawY-1'th line
for_uprow:

	move.l	linecol_offset_(BP),d1
	bsr	GetLineOfColors		;fills savearray with rgb values

		;PACK/BUILD UP THE MASK BITPLANE, based on plotflag
	;STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one
	asr.w	#3,d3			;bytes per row
	move.l	BB_BitMap_Planes_(BP),a1	;"real" mask
	add.l	linecol_offset_(BP),a1		;current row
	move.l	FillTblPtr_(BP),a0	;'rgb' table of "colors to fill"
	moveq	#0,d1	;flag for 'any mask bits in line'?
packup_loop:
	pack1
	pack1
	pack1
	pack1

	pack1
	pack1
	pack1
	pack1
		;note: (d2 && $ff00) not= 0 if any pixels set//marked
	or.w	d2,d1		;save top byte of flag word...any marked?
	move.b	d0,(a1)+	;new mask byte
	dbf	d3,packup_loop
		;note: (d1 && $ff00) not= 0 if any pixels set//marked

	tst.w	d1	;any bits get flagged in this line?
	beq.s	done_up
;nextrow:
	xjsr	ScrollAndCheckCancel	;canceler.o
	beq.s	noupcancel
	addq.w	#2,sp			;stack clup, aborting
	bra	after_fm
noupcancel:
	move.l	bytes_per_row_(BP),d0
	sub.l	d0,linecol_offset_(BP)
	bmi.s	done_up	;easier, softer way?
	subq.w	#1,(sp)
	bne	for_uprow
done_up:
	addq	#2,sp
******************************************************************

	move.l	PlaneSize_(BP),d0  	;(already set to handle "full video")
	lea	BB_BitMap_Planes_(BP),a0
	move.l	4(a0),a0		;clear out the tmpras
	xjsr	ClearMemA0D0		;strokeb.asm


		;call graphics library for 'flooding'
	;lea	BB_BitMap_(BP),a1
	;move.b	#2,bm_Depth(a1)		;un-fudge in a moment
	;lea	TextMask_RP_(BP),A1	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	;clr.l	rp_TmpRas(a1)		;blow tmpras...
	;moveq	#3,d0			;set both bitplanes
	;CALLIB	Graphics,SetAPen


	xjsr	SetAltPointerWait	;"wait cloud" WITHOUT "Zzz"

	lea	TextMask_RP_(BP),A1	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	;;moveq	#3,d0			;set both bitplanes
	;;move.b	d0,rp_Mask(a1)
	;;move.b	d0,rp_AOLPen(a1)	;not needed...(?)
	moveq	#0,d0
	moveq	#0,d1
	movem.w	MyDrawX_(BP),d0/d1
	moveq	#1,d2			;fill mode, color area at x,y gets filled
	DUMPMSG	<FLOOD!!>
	CALLIB	Graphics,Flood

	xjsr	SetPointerWait		;"wait cloud" WITH "Zzz"

	xjsr	GraphicsWaitBlit	;memories.o
	;lea	BB_BitMap_(BP),a1
	;move.b	#1,bm_Depth(a1)		;un-fudge in a moment
	xjsr	InitBitPlanes		;scratch...just want pen#1->textmask_rp

 ifc 't','f'
	lea	BB_BitMap_Planes_(BP),a1
	movem.l	(a1),d0/d1
	exg.l	d0,d1		;switch 'filled' bitplane with 'real' one
	movem.l	d0/d1,(a1)
 endc

		;'AND' together the 2 brush bitplanes...create final mask
	xref PlaneSize_
	movem.l	BB_BitMap_Planes_(BP),a0/a1	;"real" mask, tmp bitplane
	move.l	PlaneSize_(BP),d3	;Paint PIXels per row, minus one
	asr.l	#2,d3		;gonna 'and' longwords together
	subq	#1,d3
andm_loop:
	move.L	(a0),d0
	and.L	(a1)+,d0
	move.L	d0,(a0)+		;new mask (longword) byte

	dbf	d3,andm_loop
	swap	d3
	subq.w	#1,d3
	bcs.s	after_fm	;64K chunks done?
	swap	d3
	bra.s	andm_loop

after_fm:
	rts



GetLineOfColors:	;fills savearray with rgb values
			;d1=offset in bitmap to line
	;STARTaLOOP A6,d0
	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d0	;Paint PIXels per row, minus one

	addq.w	#1,d0			;=#pixels
	lea	s_LastPlot(a6),a6
	xjsr	UnPlot_SaveArray	;get image bits into savearray

	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one DBF'er
	lea	UnDoBitMap_(BP),a3	;pull colors from undo APRIL02'89
	;;move.w	col_offset_(BP),d0	;image offset, on current line to bit
	;;asl.w	#3,d0			;='x'
	moveq	#0,d0

get_save_colors:
		;get rgb for 1st pixel (wether painted or not)
	;;move.w	line_y_(BP),d1
	move.w	BigPicHt_(BP),d1	;line#
	sub.w	(sp),d1

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
	;xjsr	QuickGetOldBM		;d0,1 = x,y WATCH a3=BITPLANE PTRs
	move.l	-8(a3),a3		;bitmap ptr
	xjsr	GetOldfromBitMap	;find the P(rgb)old at this point

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
	RTS	;GetLineOfColors








* fills Table with endpoints (suitable for amiga AreaDraw)
* that follow that contour of the bitmap.
* x,y are a starting point on left side of contour.
* algo'rythm from Jan'87 Byte magazine, page 148.
* 7 0 1
* 6 x 2  'x' being current position, # indicates var S (direction)
* 5 4 3

SrcDirXYtable:	;used to convert 's'(direction) to x.word,y.word offsets
	dc.w	-1,0  ;#lines y dir, x dir
	dc.w	-1,1
	dc.w	 0,1  ;2
	dc.w	 1,1  ;3
	dc.w	 1,0  ;4
	dc.w	 1,-1 ;5
	dc.w	 0,-1 ;6
	dc.w	-1,-1 ;7

* REPEAT
*  tries=0
*  REPEAT
*   found=TRUE
*   IF the pix(s-1)=1
*      current=pix(s-1)
*      s=s-2                 ;direction flip by '2' units BUGGY BYTE LISTING
*   ELSE
*      IF pix(s)=1
*         current=pix(s)
*      ELSE
*         IF pix(s+1)=1
*               current=pix(s+1)
*            ELSE
*               s=s+3
*               tries=tries+1
*               found=FALSE
*  UNTIL (found=TRUE) or (tries=3)
* UNTIL (found=FALSE) or (current=starting)

SrcDir	equr d1
Tries	equr d2
Found	equr d3
CurX	equr d4
CurY	equr d5
StartX	equr d6
StartY	equr d7

A_Ends	equr a1	;arg, ptr to data array of (x.word,y.word) to build
A_BitPl equr a2
A_Temp	equr a3
A_Table	equr a4


* #entries = Contour (BitMap, startX, startY, Table-of-endpts ,#entries)
* d0       =          a0      d0      d1      a1               d2
Contour:
	movem.l	d1-d7/a1-a4,-(sp)
	move.w	d2,-(sp)	;arg, #entries in A_Table
	move.w	#1,-(sp)	;STACK used for #entries found (initial point)

	move.w	d0,StartX	;equr d6
	move.w	d1,StartY	;equr d7
	move.w	StartX,CurX
	move.w	StartY,CurY

	;move.l	a1,A_Ends	;table of (x.word,y.word)

	move.l	bm_Planes(a0),A_BitPl
	lea	SrcDirXYtable(pc),A_Table	;x.word,y.word OFFsets
	move.w	CurX,(A_Ends)+			;SAVE start endpoint in table
	move.w	CurY,(A_Ends)+
	;moveq	#3,SrcDir	;init Search Direction=3-->step right,down
	moveq	#2,SrcDir	;init Search Direction=2-->step right

crepeat1:			; REPEAT
	moveq	#0,Tries	;  tries=0
crepeat2:			;  REPEAT
	moveq	#-1,Found	;   found=TRUE
				;   IF the pix(s-1)=1
				;      current=pix(s-1)
				;      s=s-2 ;direction flip by '2' units
	subq.w	#1,SrcDir	;setup for pix(s-1)
	bsr.s	TestPixel	;current+SrcDir pixel set? (verify Sdir<>neg)
	beq.s	else1		;no,
	bsr.s	SetCurrent	;" current=pix(s-1) " (subr could CLEAR 'found')
	subq.w	#1,SrcDir	;-2, really, since already did -1
	bpl.s	rptend2	;endif1
	addq.w	#8,SrcDir
	bra.s	rptend2	;endif1
else1:				;   ELSE
	addq.w	#1,SrcDir	;backout last update to 'SrcDir'
				;      IF pix(s)=1
				;         current=pix(s)
	bsr.s	testPixS	;test pixel at CurX+SrcDir, CurY+SrcDir (ensure SrcDir 0..8)
	beq.s	else2
	bsr.s	SetCurrent	; (subr could CLEAR 'found')
	bra.s	rptend2	;;endif1
else2:				;      ELSE
				;      IF pix(s+1)=1
				;            current=pix(s+1)
	addq.w	#1,SrcDir
	bsr.s	testPixS	;test pixel at CurX+SrcDir, CurY+SrcDir (ensure SrcDir 0..8)
	beq.s	else3
	bsr.s	SetCurrent	;" current=pix(s+1) " (subr could CLEAR 'found')
	subq.w	#1,SrcDir	;backout change to search direction
	bra.s	rptend2	;endif1	;dont change SrcDir
else3:				;         ELSE
				;            s=s+3
	addq.w	#2,SrcDir	;really +3, since last check upped it
	cmp.w	#8,SrcDir
	bcs.s	1$
	subq.w	#8,SrcDir
1$	addq.w	#1,Tries	;tries=tries+1
	moveq	#0,Found	;found=FALSE

;endif1	tst.b	Found		;  UNTIL (found=TRUE) or (tries=3)
;	bne.s	rptend2
	cmp.b	#3,Tries
	bcs.s	crepeat2
rptend2:
	tst.b	Found		; UNTIL (found=FALSE) or (current=starting)
	beq.s	rptend1
	cmp.w	CurX,StartX	;curt = start?
	bne.s	crepeat1
	cmp.w	CurY,StartY
	bne.s	crepeat1
rptend1:
	move.w	(sp)+,d0	;#entries created "current entry#"
	lea	2(sp),sp	;#entries in table (temp)
	movem.l	(sp)+,d1-d7/a1-a4

  RTS

SetCurrent:		;subr, clears 'found' flag if end of table//maxentries
	;stack (0.long)=rtnadr,(4.w)=current entry#,(6.w)=max#entries
	move.w	4(sp),d0	;current entry #
	cmp.w	6(sp),d0	;max #entries in table
	bcs.s	1$		;bra when new entry "fits" in table
	st	FlagDisplayBeep_(a5)	;a5=basepage
	moveq	#0,Found	;funky-out flag, so routine fails
	rts
1$
	addq.w	#1,d0		;entry#
	move.w	d0,4(sp)	;save new (incremented) item#

		;makes 'current' be current"+"SrcDirection
	move.w	SrcDir,d0	;temp
	add.w	d0,d0
	add.w	d0,d0
	lea	0(A_Table,d0.w),A_Temp	;point at curt direct' offsets
	add.w	(A_Temp)+,CurY		;"new" y, offset from table
	add.w	(A_Temp),CurX
	move.w	CurX,(A_Ends)+	;SAVE endpoint in table
	move.w	CurY,(A_Ends)+
	RTS

TestPixel:		;subr like next, also checks/fixes negative SrcDir
		;test pixel at CurX+SrcDir, CurY+SrcDir (ensure SrcDir 0..8)
	bpl.s	testsok	;just did a 'subq #1,SrcDir' before call ;testPixS
	addq.w	#8,SrcDir
	bra.s	testsok

testPixS:	;test pixel at CurX+SrcDir, CurY+SrcDir (ensure SrcDir 0..8)
	cmp.w	#8,SrcDir
	bcs.s	testsok
	subq.w	#8,SrcDir

testsok:
	movem.l	CurX/CurY,-(sp)
	move.w	SrcDir,d0	;temp
	add.w	d0,d0
	add.w	d0,d0
	lea	0(A_Table,d0.w),A_Temp	;point at curt direct' offsets

	add.w	(A_Temp)+,CurY	;"new" y, offset from table
	bmi.s	tperr		;neg? off of bitmap, flag notset
	cmp.w	bm_Rows(a0),CurY ;off bottom?
	bcc.s	tperr		;yep, outta here if off bottom

	add.w	(A_Temp),CurX
	bmi.s	tperr		;off leftside of bitmap?
	move.w	(a0),d0	;bm_BytesPerRow(a0),d0
	asl.w	#3,d0		;=#pixels per row
	cmp.w	d0,CurX
	bcc.s	tperr		;yep, outta here if off right side

	mulu	(a0),CurY ;bm_BytesPerRow(a0),CurY		;y*rowsize
	moveq	#0,d0		;clear upper word
	move.w	CurX,d0		;save original x
	asr.w	#3,CurX		;x/8
	add.L	CurX,CurY	;.l for addressing
	andi.w	#7,d0		;original "x"
	neg.w	d0
	addq.w	#7,d0		;d0 = bit number [ 7..0 ]
	btst	d0,0(A_BitPl,CurY.L)

	;bra.s	tpok		;outta here
	movem.l	(sp)+,CurX/CurY
	RTS

tperr:	moveq	#0,d0		;setup ZERO (notset) flag
tpok:	movem.l	(sp)+,CurX/CurY
	RTS



*************************************
* handle flood filling in bigpic-sized single bitplane drawing mask

	;include "exec/types.i"
	;digipaint pi;include "ds:basestuff.i"
	include "graphics/rastport.i"

	xref FillAreaInfo_	;areainfo struct
	xref AreaChunkLen_	;#endpoints
	xref AreaBufferPtr_	;list of endpts (4bytes per...)
	xref AreaBufferLen_	;.long
	xref AreaVectorPtr_	;list of endpts (*5*bytes per...)
	xref AreaVectorLen_	;.long
	xref FillTmpRas_	;,tr_SIZEOF

	xref TextMask_RP_
	xref BB_BitMap_
	xref PlaneSize_	;single bitplane size

DoFlood:
	DUMPMSG	<DoFlood>
	lea	FlagDisplayBeep_(BP),a0
	move.b	(a0),d0
	move.w	d0,-(sp)		;STACK current display status
	sf	(a0)		;flagdisplaybeep
	xjsr	SetAltPointerWait
	xjsr	UseColorMap	;(pointers.o, for now) does the 'loadrgb4's
	bsr.s	reallydoflood
	lea	FlagDisplayBeep_(BP),a0
	tst.b	(a0)		;error? (no memory for flood vectors?)
	beq.s	9$		;ok, man!
	sf	(a0)		;flagdisplaybeep
	xjsr	CleanupMemory
	bsr.s	reallydoflood
	lea	FlagDisplayBeep_(BP),a0
	tst.b	(a0)		;error? (no memory for flood vectors?)
	beq.s	9$		;ok, man!
	sf	(a0)		;flagdisplaybeep
	xjsr	FreeCPUnDo
	xjsr	CleanupMemory
	bsr.s	reallydoflood
9$:
	move.w	(sp)+,d0		;destack/restore displaybeep
	lea	FlagDisplayBeep_(BP),a0
	or.b	(a0),d0			;"or" in value from subr, too
	move.b	d0,(a0)
	rts

reallydoflood:
	DUMPMSG	<Really do flood>
	xjsr	InitBitPlanes	;scratch.o, tmpras new?
  	xjsr	AllocAreaStuff		;memories.o

		;NOTE: "area" stuff uses 8th bitplane of brush as tmpras
	lea	FillAreaInfo_(BP),a0	;a0=areainfo struct
	move.l	AreaVectorPtr_(BP),a1	;a1=list of endpts (*5*bytes per...)
	move.l	AreaChunkLen_(BP),d0	;#endpoints
	beq	enda_flood ;doneflood
	CALLIB	Graphics,InitArea


* #entries = Contour (BitMap, x, y, Table ,len)
* d0       =          a0      d0 d1 a1     d2
* d0 = 1 if no entries...

	move.l	AreaBufferPtr_(BP),d0	;endpoint list, table of xy's
	beq	enda_flood ;doneflood
	move.l	d0,a1		;a1=table of (x.w,y.w)
	move.l	AreaBufferLen_(BP),d2
	beq	enda_flood ;doneflood

	;asr.L	#4,d2		;d2=buffersize/4bytesper=#endpts
	asr.L	#2,d2		;d2=buffersize/4bytesper=#endpts MAY18 re:steveS.

	subq.l	#3,d2		;d2=max entry #
	bcs	enda_flood ;doneflood

	lea	BB_BitMap_(BP),a0

		;determine d0=starting x, d1=starting y
	movem.l	d2/d3/a1,-(sp)

	move.w	bm_Rows(a0),d2
	mulu	(a0),d2 ;bm_BytesPerRow(a0),d2	;=total bytes in bitplane
	MOVE.L	d2,-(sp)		;STACK usage, total #bytes in plane
	subq.L	#1,d2			;db' type loop
	move.l	bm_Planes(a0),a1	;ptr to data
findfirst:
	tst.b	(a1)+
	bne.s	foundfirst
	subq.L	#1,d2		;.long counter	march28'89
	bcc.s	findfirst


	MOVE.L	(sp)+,d2		;d2=byte#bummout, try from beginning
	movem.l	(sp)+,d2/d3/a1		;clear stack to get outta this subr
	bra	enda_flood		;nothing set in bitmap

foundfirst:	;d2='byte# from end'
	ADDQ.L	#1,d2		;re-offset, since WAS using a 'dbf' type loop
	sub.l	(sp)+,d2	;de-STACK size of bitplane in bytes
	neg.l	d2		;d2="byte # from beginning"
	divu	(a0),d2 ;bm_BytesPerRow(a0),d2
	moveq	#0,d1
	move.w	d2,d1	;d1=STARTING 'y' in brush bitmap
	swap	d2
	asl.w	#3,d2
	moveq	#0,d0
	move.w	d2,d0	;d0=STARTING 'x' in brush bitmap (to nearest byte)

	moveq	#7,d2		;bit#
	move.b	-1(a1),d3	;LAST BYTE CHECKED
findbit:
	btst	d2,d3
	bne.s	foundbit
	dbf	d2,findbit
	moveq	#7,d2	;not found (oohhhh....errrOR will ROBinSON)
foundbit:
	neg.w	d2
	addq.w	#7,d2
	add.w	d2,d0	;d0=STARTING X (adjusted, correct now)

	movem.l	(sp)+,d2/d3/a1

	bsr	Contour	;hanging in here?

* #entries = Contour (BitMap, startX, startY, Table-of-endpts ,#entries)
* d0       =          a0      d0      d1      a1               d2

	tst.b	FlagDisplayBeep_(BP)	;did it complete? (or overrun table...)
	bne	abort_flood

	move.w	d0,d2		;loop var
	beq	abort_flood	;enda_flood	;doneflood	;no endpts?
	subq	#1,d2		;db' type loop
	beq	abort_flood	;enda_flood	;doneflood	;no endpts?
	subq	#1,d2		;- 1st endpt count
	beq	abort_flood	;enda_flood	;2 endpoints? no flood...

  MOVE.L	d2,-(sp)	;loop counter, #endpts


	lea	TextMask_RP_(BP),A3	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	lea	FillAreaInfo_(BP),a0	;a0=areainfo struct
	move.l	a0,rp_AreaInfo(A3)	;RPORT why? graphics paradigm sometimes weak
	move.l	a3,a1 ;TextMask_RP_(BP),A1	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
 	move.l	AreaBufferPtr_(BP),a2	;A2=endpoint list (filled by Contour)
	move.w	(a2)+,d0		;starting/first x
	move.w	(a2)+,d1		;1st y
	CALLIB	Graphics,AreaMove
  MOVE.L	(sp)+,d2	;loop counter, #endpts

adrawloop:
	move.l	a3,a1 ;TextMask_RP_(BP),A1	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	CALLIB	SAME,AreaDraw
	dbf	d2,adrawloop

	move.l	a3,a1 ;TextMask_RP_(BP),A1 ;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	CALLIB	SAME,AreaEnd
	DUMPREG <after AreaEnd>
doneflood:
	xjsr	GraphicsWaitBlit
	bra.s	enda_flood

abort_flood:
	DUMPMSG	<abort flood>
	st	FlagDisplayBeep_(BP)	;"flash"es... mainloop will do it

enda_flood:
	DUMPREG	<enda_flood>
	xjsr	FreeAreaStuff
	xjmp	SetPointerWait	;did set it to 'alt' just before flooding
	;RTS

  END


  IFC 't','f' ;combined into next loop
		;LOOP, SET/CLEAR PLOTFLAG IF COLOR MATCHES FLOOD-COLOR-LIST
	;STARTaLOOP A6,d3	;d3 for pixel counter, a6 for savearray
	move.l	SAStartRecord_(BP),a6	;1st pixel's "record" inside savearray
	move.w	ppix_row_less1_(BP),d3	;Paint PIXels per row, minus one

	move.l	FillTblPtr_(BP),a0
film_loop:
	move.W	(a6),d5			;=0000rrrr 0000gggg
	asl.B	#4,d5			;=0000rrrr gggg0000
	or.b	s_blue(a6),d5		;=0000rrrr ggggbbbb

	tst.b	0(a0,d5.w)
	sne	s_PaintFlag(a6)

	lea	s_SIZEOF(a6),a6
	dbf	d3,film_loop
  ENDC

