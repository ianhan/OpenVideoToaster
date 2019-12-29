* NewFlood.asm
	;XDEF Contour
	XDEF DoFlood

	xref FlagDisplayBeep_

* fills Table with endpoints (suitable for amiga AreaDraw)
* that follow that contour of the bitmap.
* x,y are a starting point on left side of contour.
* algo'rythm from Jan'87 Byte magazine, page 148.
* 7 0 1
* 6 x 2  'x' being current position, # indicates var S (direction)
* 5 4 3
	include "exec/types.i"
	include "graphics/gfx.i"
	include "graphics/rastport.i"

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
	include "ds:basestuff.i"
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
	btst.b	d2,d3
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

doneflood:
	xjsr	GraphicsWaitBlit
	bra.s	enda_flood

abort_flood:
	st	FlagDisplayBeep_(BP)	;"flash"es... mainloop will do it

enda_flood:
	xjsr	FreeAreaStuff
	xjmp	SetPointerWait	;did set it to 'alt' just before flooding
	;RTS

  END


