	xref BestPen_W_		;calc'd in mousertns.o, rtn EndPick
	;xref MWindowPtr_
	xref our_task_
	xref PalDifTablePtr_

;SetMaskLine:
	;called as alternate to DoBrushLine (overwrites D0-d5,A0)
	;args are MyDrawX_,Y,BrushLineWidth_w

AWAliveMac:	MACRO
	move.l	our_task_(BP),a1	;ptr to our task(|process) structure
	cmp.b	#-1,LN_PRI(a1)		;BYTE LN_PRI in task struct
		ENDM

	MOVEM.L a1-a4,-(sp)	;save for (anonymous) caller?

	;NEW CLIPPING;args are MyDrawX_,Y,BrushLineWidth_w
	movem.w	MyDrawX_(BP),d0/d1/d2	;x,y,brushlinewidth
	tst.w	d0		;d0=x
	bpl.s	Mxlok
	add.w	d0,d2		;BrushLineWidth_w_(BP) ;reduce width
	bmi.s	Mclipleft
	bne.s	Mzerostart	
Mclipleft:
	tst.b	FlagFlood_(BP)
	beq	enda_setmaskline
	moveq	#1,d2	;BrushLineWidth_(BP)
Mzerostart:
	moveq	#0,d0	;MyDrawX_(BP)
Mxlok:

	;d0=x, d1=y d2=wt (left clipped ok, now)

	move.w	BigPicWt_W_(BP),d3	;rt edge + 1
	cmp.w	d3,d0			;starting x
	bcs.s	Mnotoffrt

	xref FlagFlood_
	tst.b	FlagFlood_(BP)
	beq	enda_setmaskline
	move.w	d3,d0			;set x,wt to rt edge if flooding
	subq	#1,d0
	moveq	#1,d2
Mnotoffrt:

	move.w	d0,d4	;left
	add.w	d2,d4	;+wt
	cmp.w	d3,d4	;wt/rt edge?
	bcs.s	Mallfitrt
	beq.s	Mallfitrt
	move.w	d3,d2	;width//rt edge+1
	sub.w	d0,d2	;-start x = new width
Mallfitrt:

	moveq	#0,d1
	move.w	MyDrawY_(BP),d1
	bpl.s	nocliptop		;top edge clip
	tst.b	FlagFlood_(BP)
	beq	enda_setmaskline
	moveq	#0,d1
nocliptop:

	cmp.w	BigPicHt_(BP),d1
	bcs.s	noclipbot		;bottom edge clip
	tst.b	FlagFlood_(BP)
	beq	enda_setmaskline
	move.w	BigPicHt_(BP),d1
	subq	#1,d1
noclipbot:

	mulu	UnDoBitMap_(BP),d1	;bm_bytesperrow

	move.l	BB1Ptr_(BP),A0	;brush bitmap
	lea	0(A0,d1.L),A0	;start of line (dupl for screen later)
	subq	#1,d2	;dbf type loop LOOP COUNER M_//or//MS_LOOP

	bmi	enda_setmaskline	;MAY18


	move.l	D0,d4	;x (for now, gonna builda bit#)
	asr.w	#3,d4	;x/8
	lea	0(A0,d4.L),A0	;into bitplane, now

	move.l	D0,d3	;x (for now, gonna builda bit#)
	moveq	#7,d5	;temp cycle saver
	and.W	d5,d3	;#7&x {=} mod(x,8)
	neg.b	d3
	add.b	d5,d3	;#7; d3 = bit number [ 7..0 ]

	;;june11...quicker by far?
	;xref FlagRepainting_
	;tst.b	FlagRepainting_(BP)
	;bne.s	setm_loop		;skip screen plot if repainting

	AWAliveMac
	bne.s	setscreentoo		;not=Z=alive, go set screen bits, too

setm_loop:
	bset	d3,(A0)	;brush bitmap pixel
	subq	#1,d3	;bitnumber countdown
	dbcs	d2,setm_loop	;test, branch?, decrement, branch?
	;bcc.s	enda_setmaskline	;done...when d2 flips
	bcc	enda_setmaskline	;done...when d2 flips
	moveq	#7,d3		;top bit# in a byte
	lea	1(A0),A0	;bitmap addr++ to next byte
	dbf	d2,setm_loop
	bra	enda_setmaskline

setscreentoo:
	;may25, not needed?;moveq	#0,d0
	move.w	BestPen_W_(BP),d0
		;MAY25
	;eori.B	#%01111,d0		;flip lower 4 bits
	;move.w	d0,BestPen_W_(BP)
	
	asl.w #5,d0   ; d0=d0*32 (plot routines are 26 bytes + 6 cnop's each)
	xref Plot_Routine_Start
	lea	Plot_Routine_Start,a6
	lea	0(a6,d0.w),a6

		;MAY31
	xref PenRtnA_
	xref PenRtnB_
	;LATEST;move.l	PenRtnB_(BP),PenRtnA_(BP)	;1st/next time switch
	tst.l	PenRtnA_(BP)		;very first time?
	bne.s	013$			;very first time?
	move.l	a6,PenRtnA_(BP)
	;move.l	a6,PenRtnB_(BP)
	bra.s	002$
013$
	move.l	a6,PenRtnB_(BP)
  ifc 't','f'
	tst.w	d2			;#endpoints...=1?
	;bne.s	002$			;nope...use same color
	beq.s	009$
	cmp.w	#1,d2	;short little brush line or rectangle or what?
	bcc.s	009$	;short one or two wide...2colors?
	cmp.w	#11,d2	;short little brush line or rectangle or what?
	bcs.s	002$	;short one...solid color, please

009$
  endc

	;JUNE02;tst.w	d2			;#endpoints...more than 1?
	;JUNE02;bne.s	003$			;yep...use same color...
		;JUNE02;
	cmp.w	#12-1,d2	;#endpts more than 12? (long horiz line//rect)
	bcc.s	100$		;yep, >12, use diff colors
	tst.w	d2
	bne.s	003$
100$:		;JUNE05
	xref FlagCirc_
	tst.L	FlagCirc_(BP)	;Long test 4 flags, circ,curv,rect,line
	beq.s	003$		;no special modes, use SAME pen


	cmp.l	PenRtnA_(BP),a6	;same color in pen#2?
	bne.s	003$
	move.w	BestPen_W_(BP),d0
	subq	#1,d0
	bcc.s	001$
	moveq	#15,d0
001$:	asl.w #5,d0   ; d0=d0*32 (plot routines are 26 bytes + 6 cnop's each)
	lea	Plot_Routine_Start,a6
	lea	0(a6,d0.w),a6
002$:	move.l	a6,PenRtnB_(BP)
003$
	;move.l	PenRtnB_(BP),a6
	;move.l	PenRtnA_(BP),PenRtnB_(BP)	;1st/next time switch
	;move.l	a6,PenRtnA_(BP)


		;a1-a4 dont change...
	lea	ScreenBitMap_Planes_(BP),a4
	movem.l	4(a4),a1-a4	;2nd,3rd,4th,5th bitplanes

setms_loop:
	bset	d3,(A0)	;brush bitmap pixel
	bne.s	09$

	move.l	PenRtnA_(BP),a6
	move.l	PenRtnB_(BP),PenRtnA_(BP)
	move.l	a6,PenRtnB_(BP)

	MOVEM.l	d1/d2/a0/a5,-(sp)
	add.l	d4,d1		;add offset into line, to line start
	move.W	d3,d2		;bit# for fastplot	

	;movem.l ScreenBitMap_Planes_(BP),a0-a5 ; get start addr.s of the 6 bitplanes
		;a1-a4 dont change...
	lea	ScreenBitMap_Planes_(BP),a0
	move.l	(5*4)(a0),a5	; last bitplane adr
	move.l	(a0),a0		; first bitplane adr
	jsr	(a6)		;plot_routine_start
	MOVEM.l	(sp)+,d1/d2/a0/a5
09$:
	subq	#1,d3	;bitnumber countdown
	dbcs	d2,setms_loop	;test, branch?, decrement, branch?
	bcc.s	enda_screento	;'cc' condition STILL based on 'd3'...NOTE!
	moveq	#7,d3		;top bit in a byte
	lea	1(A0),A0	;addr++
	ADDQ	#1,D4		;byte offset into line
  	dbf	d2,setms_loop
enda_screento:

enda_setmaskline:
	;rts	;overwrites D0-d5,A0


	MOVEM.L (sp)+,a1-a4	;'stack'ed at start of this include file
