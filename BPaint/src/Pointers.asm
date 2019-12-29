* Pointers.asm
KLUDGEOUT MACRO
 ;;; RTS
     ENDM

 xref CurrentPointer_
 xdef HiresPtrHires	;really, just clears the hires ptr (used for menus)

 xdef AproPointer
 xdef ClearPointer	;removes all custom pointers (*ONLY* call for menuver's)
 xdef InvisiblePointer	;used for 'viewpage' function (only)
 xdef ResetPointer	;make pointer be whatever it's supposed to be
 xdef FixPointer	;helps out 'customized brush'
 xdef SetAltPointerWait	;SNOOZE image...saw it in an amigan....
 xdef SetPointerPick	;"real" pickpointer, when picking active,msertns.o
 xdef SetPointerPickWhat	;"picking" pointer after 'pick' button,gdtrtns.o
 xdef SetPointerWait	;SNOOZE image...saw it in an amigan....
 xdef SetPointerTo	;'copy color to' ptr sup
 
 xdef PointerCut_data	;used gadgetroutines to see if have scissors
 xdef PointerMagnify_data ;used gadgetroutines 2see if have mag'glass
 xdef PointerPickWhat_data	;used gadgetroutines, pickgadgetrtn
 xdef PointerTo_data	;used colorboxroutine to see if copying color

 xdef PointerPick_data		;used by Composite.o ONLY, for "check to display"
 xdef PointerPickOnly_data	;used by ....(ditto)

	include "ps:basestuff.i"
	include "lotsa-includes.i"	;needed for screens.i
	include "screens.i"		;sc_ViewPort
	include "windows.i"
	;;include "intuition/intuitionbase.i"	;ib_firtscreen,activewindow

	xref BrushGadgetPtr_
	xref BrushNumber_
	xref BrushSize_
	xref BrushType_
	xref DispBrushNumber_	;displayed brush #
	xref FlagBitMapSaved_
	xref FirstScreen_
	xref FlagCtrl_
	xref FlagCtrlText_
	xref FlagCutPaste_
	xref FlagGadgetDown_	;set/clrd by main.msg, used by apropointer
	xref FlagGrayPointer_ ;april25....usecolormap only does hires gray loadrgb4
	xref FlagMagnify_
	xref FlagMagnifyStart_
	xref FlagMenu_		;set when intuit' has a menu, clr otherwise
	xref FlagNeedGadRef_	;'end brush sizer' by setting this
	xref FlagNeedRepaint_
	xref FlagOpen_
	xref FlagPale_
	xref FlagPick_
	xref GWindowPtr_
	xref HamToolColorTable_
	xref HiresColorTable_
	xref MScreenPtr_
	xref MWindowPtr_
	xref Paintblue_
	xref Paintgreen_
	xref Paintred_
	xref PasteBitMap_Planes_
	xref ScreenPtr_
	xref SkScreenPtr_
	xref ToolWindowPtr_
	xref TScreenPtr_
	xref WindowPtr_
	xref XTScreenPtr_

	xref LongColorTable_
	xref BigPicColorTable_


	xref CusPtr_BitMap_
	xref CusPtr_BitMap_Planes_
	xref CusPtr_BitMap_RP_

	xdef SupCusPtr		;setup custom pointer//brush imagery
SupCusPtr:
		;april25...already done?
	lea	CusPtr_Pointer,a1
	cmp.l	CusPtr_BitMap_Planes_(BP),a1
	beq.s	eaSupCus

	moveq	#1,D0		;DEPTH 1 for rastport, treat as"2" for sprite
	moveq	#32,d1		;wt of 32 (longword) for bit
	moveq	#32,d2		;ht
	lea	CusPtr_BitMap_(BP),a0
	CALLIB	Graphics,InitBitMap

	lea	CusPtr_Pointer,a1
	move.l	a1,CusPtr_BitMap_Planes_(BP)

	lea	CusPtr_BitMap_RP_(BP),a0
	lea	CusPtr_BitMap_(BP),a1

;inita_rport:		;CALL WITH a1=bitmap, A0=rastport
	movem.l	A0/a1,-(sp)
	move.l	A0,a1			;a1 is args for next syscall
	CALLIB Graphics,InitRastPort	;sets fgpen=1, bg=0, aol=1

	movem.l	(sp),A0/a1
	move.l	a0,a1	;rastport arg
	moveq	#1,D0
	CALLIB	SAME,SetAPen

	movem.l	(sp)+,A0/a1
	move.l	a1,rp_BitMap(A0)	;shove A1=bitmap into A0 rastport struct
	move.b  #1,rp_FgPen(A0)
	move.b  #0,rp_BgPen(A0)
	move.b  #1,rp_AOLPen(A0)

	;april25..tried but no effect?
	;xref FillTmpRas_	;glommed from text/fill bup scratch.o ref'
	;lea	FillTmpRas_(BP),a1	;a1=tmpras
	;move.l	a1,rp_TmpRas(A0)	;RASTPORT why? graphics paradigm sometimes weak
eaSupCus:
	rts			;SupCusPtr

SetPointerMagnify:
	bsr GrayPointer	;make pointer color be gray
	moveq	#11,d0	;height 
	moveq	#12,d1	;width
	moveq	#-3,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	PointerMagnify_data,a1
	move.l	a1,CurrentPointer_(BP)

	movem.l	d0-d3/a1,-(sp)		;STACK
	move.l	WindowPtr_(BP),a0	;bigpicture
	bsr	intuition_setpointer
	movem.l	(sp)+,d0-d3/a1		;deSTACK

	move.l	GWindowPtr_(BP),a0
	bra	intuition_setpointer
	;rts

SetCutCrossHair:
	;move.l	WindowPtr_(BP),a0
	lea	CutCrossHair_Pointer,a1
	moveq	#14,d0	;height 
	moveq	#16,d1	;width
	moveq	#-8,d2	;xoffset//hotspot
	moveq	#-7,d3	;yoffset

	move.l	GWindowPtr_(BP),a0	;cutcrosshair, hires
	bra	intuition_setpointer
	;rts

	XDEF SetPointerCut		;ref' by InitCutPaste may05'89
SetPointerCut:
	tst.l	PasteBitMap_Planes_(BP)	;already have a brush?
	bne.s	SetCutCrossHair		;already allocated

	moveq	#11,d0	;height 
	moveq	#16,d1	;width
	moveq	#-10,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset

	lea	PointerCut_data,a1
	move.l	a1,CurrentPointer_(BP)
	move.l	GWindowPtr_(BP),a0
	bsr	intuition_setpointer
	bra	GrayPointer	;make pointer color be 'gray'
	;rts

set_crosshair:	;sets it on window in A0

	cmp.l	WindowPtr_(BP),a0	;bigpicture?
	bne.s	7$
		;otherwise we setup a blank pointer on bigpic (when it's active)
	moveq	#6+2,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	Blank_Pointer,a1
	bra	intuition_setpointer
	;rts

7$:	lea	GenericCrossHair_Pointer,a1
	moveq	#14,d0	;height 
	moveq	#16,d1	;width
	moveq	#-8,d2	;xoffset//hotspot
	moveq	#-7,d3	;yoffset
	bra	intuition_setpointer
	;rts


InvisiblePointer:
  KLUDGEOUT
	move.l	GWindowPtr_(BP),a0
	moveq	#6+2,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	Invis_Pointer,a1
	bra	intuition_setpointer


ClearPointer:
  KLUDGEOUT
	move.l	WindowPtr_(BP),d0	;set/clr zero flag
	beq.s	1$		;no window
	move.l	d0,a0
	bsr.s	set_crosshair	;sets it on window in A0
1$
	move.l	ToolWindowPtr_(BP),a0
	bsr.s	intu_clrptr

	move.l	GWindowPtr_(BP),a0	;hires
	;bsr.s	intu_clrptr
	;RTS

EB_intu_clrptr:				;'end' brush sizer? may01
 IFC 't','f' ;june291990
	tst.b	FlagGadgetDown_(BP)	;set/clrd by main.msg
	beq.s	intu_clrptr
	sf	FlagGadgetDown_(BP)	;set/clrd by main.msg
	st	FlagNeedGadRef_(BP)	;clearzout/resets brush size imagery
  ENDC
intu_clrptr:
	cmp.l	#0,a0
	beq.s	9$
	tst.l	wd_Pointer(a0)
	beq.s	9$
	JMPLIB	Intuition,ClearPointer
9$	rts

FixPointer:	;helps out 'customized brush' ONLY CALLED BY MAIN
  KLUDGEOUT

	move.l	GWindowPtr_(BP),d0
	beq.s	end_fixp
	move.l	d0,a0			;hires window
	lea	CusPtr_Pointer,a1	;'std brush'
	cmp.l	wd_Pointer(a0),a1
	bne.s	end_fixp		;no 'fix' needed

	move.w	BrushNumber_(BP),d0
	cmp.w	DispBrushNumber_(BP),d0	;displayed brush #
	beq.s	end_fixp		;already 'got it'

	;no need;move.l	IntuitionLibrary_(BP),a6
 IFC 't','f' ;june291990
	move.l	XTScreenPtr_(BP),d0	;hires screen
	cmp.l	FirstScreen_(BP),d0 ;ib_FirstScreen(a6),d0	;...in front?
	bne.s	8$			;no? definitely reset to curt brush

	tst.w	wd_MouseY(a0)	;hires window
	bpl.s	end_fixp	;mouse "on" hires screen, no re-do (keep curt)
 ENDC

8$	movem.l	a0/a1,-(sp)
	xjsr	BGadDisplay	;redo pointer imagery (CUSTOMIZE HERE)
	move.w	BrushNumber_(BP),DispBrushNumber_(BP) ;displayed brush #
	st	FlagGrayPointer_(BP) ;usecolormap only does hires gray loadrgb4
	movem.l	(sp)+,a0/a1

	moveq	#20-2,d0 ;height 
	moveq	#16,d1	;width
	moveq	#-1-4-1,d2	;xoffset//hotspot
	moveq	#-3-4+1,d3	;yoffset
really_setpointer:
	cmp.l	#0,a0
	beq.s	end_fixp
	bra	intuition_setpointer	;MAY07'89;JMPLIB	Intuition,SetPointer
end_fixp	rts

SetPointerPickWhat:
  KLUDGEOUT
	moveq	#15-6,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	PointerPickWhat_data,a1
	move.l	a1,CurrentPointer_(BP)

	movem.l	d0-d3/a1,-(sp)
	move.l	GWindowPtr_(BP),a0 	;regular/text gadgets
	bsr	intuition_setpointer
	movem.l	(sp),d0-d3/a1
	move.l	WindowPtr_(BP),a0	;bigpicture toolbox
	bsr	intuition_setpointer
	movem.l	(sp)+,d0-d3/a1

	move.l	ToolWindowPtr_(BP),a0	;ham toolbox
	bsr	intuition_setpointer
	rts

SetPointerPick:
  KLUDGEOUT
	moveq	#15-6,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	PointerPick_data,a1
	move.l	a1,CurrentPointer_(BP)

	movem.l	d0-d3/a1,-(sp)
	move.l	GWindowPtr_(BP),a0 	;regular/text gadgets
	bsr	intuition_setpointer
	movem.l	(sp),d0-d3/a1
	move.l	WindowPtr_(BP),a0	;bigpicture toolbox
	bsr	intuition_setpointer
	movem.l	(sp)+,d0-d3/a1

	move.l	ToolWindowPtr_(BP),a0	;ham toolbox
	bra	intuition_setpointer
	;rts


	XDEF HiresColorsOnly
HiresColorsOnly:
	lea	FlagGrayPointer_(BP),a0	;ref by graypointer, mainloop
	tst.b	(a0)
	beq.s	nohirescolors
	sf	(a0)
	tst.b	FlagColorMap_(BP)
	bne.s	nohirescolors		;outta here if gonna do 'real thing'

	moveq	#0,d0
	move.b	Paintred_(BP),d0	;$xxxR
	asl.b	#4,d0			;$xxRx
	or.b	Paintgreen_(BP),d0	;$xxRG add in green bits
	asl.w	#4,d0			;$xRGx
	or.b	Paintblue_(BP),d0	;$xRGB add in blue bits

	move.l	XTScreenPtr_(BP),a0
	lea	HiresColorTable_(BP),a1	;ONLY CHANGE SPRITE WHITE ON HIRES(?)
	;lea	BigPicColorTable_(BP),a2	;TO bigpic 
	;move.w	(a2),(a1)		;force HIRES COLOR ZERO = hampalette 0
	move.w	BigPicColorTable_(BP),(a1) ;hamcolor zero->hires zero

		;color zero is "workbench blue-ish" when "no screen"
	tst.l	ScreenPtr_(BP)	;bigpic
	bne.s	50$		;gotabigpic
	move.w	#$05a,(a1)	;color zero= r0 g5 b10
50$:	;gotabigpic:

	;JULY251990;move.w 	d0,(15*2)(a1)		;paint color=>color 15, BRUSH & TextGads
	move.w 	d0,(17*2)(a1)		;force new color into #17,whichisthe18th
	move.w 	d0,(18*2)(a1)		;force new color into #18,whichisthe19th
	;move.w	#$0fff,(19*2)(a1)	;bright white sprite?
	or.w	#$0333,d0	;"jack bright colors up"
	cmp.w	#$0fff,d0	;color=white(bright)?
	bne.s	87$
	move.w	#$0aaa,d0	;gray-ish
	bra.s	88$
87$	move.w	#$0fff,d0	;definite white
88$	move.w	d0,(19*2)(a1)	;bright white sprite?

	bsr	Isl_LoadRGB
	move.l	SkScreenPtr_(BP),a0	;MiniScreen for digits? (using hires ct)
	bra	Isl_LoadRGB	;hires colormap, via loadrgb4
nohirescolors:
	rts	;hirescolorsonly


	XDEF NegHiresColors	;for AutoRequest....AUG091990
NegHiresColors:

	sf	FlagColorMap_(BP)	;asks main loop for color reset...

	move.l	XTScreenPtr_(BP),a0
	;lea	HiresColorTable_(BP),a1	;ONLY CHANGE SPRITE WHITE ON HIRES(?)
	lea	NegativeColorTable,a1

	bra	Isl_LoadRGB	;Graphics call stub, a0=Screen, a1=cm, preserves a1 (a2 ok also)
	;rts




	XDEF UseColorMap	;moves LongColorTable.L=>ColorTable.W=>Hardware
UseColorMap:	;moves LongColorTable into ColorTable into Hardware
		;clear 'hires only' flag, doing every screen's colors
	xref FlagColorMap_	;april26, alright, ALREADY declared
	tst.b	FlagColorMap_(BP)
	beq.s	nohirescolors	;just an rts, quick out
	sf	FlagColorMap_(BP)

	sf	FlagGrayPointer_(BP)	;ref by graypointer, mainloop
	movem.l	D0/d1/d2/A0/a1/a2,-(sp)

	;MOVE LongColorTable(.L entries) into ColorTable(.W entries)
	;ALSO ENSURES 4th byte of each longword entry is a ZERO//NULL
	;move LongColorTable into ColorTable
	;LongColorTable fmt = 32 * longword (red.b,green.b,blue.b,dontcare.b)
	;   ColorTable fmt = 32 *     word (dontcare.n,red.n,green.n,blue.n)

	lea	LongColorTable_(BP),A0	;A0=FROM .L a1,a2 = destination adrs
	lea	BigPicColorTable_(BP),a2	;TO bigpic 
	lea	HamToolColorTable_(BP),a1
	move.l	#(16-1),d1	 	;ERROR if<16 entries in colortable?
MCTloop:
	move.b	(A0),D0		;get red.b
	andi.b	#$0F,D0
	move.b	D0,(A0)+ 	;ensure upper bits not set
	move.b	D0,(a1)+	;save (dontcare.n,red.n)
	move.b	D0,(a2)+ ;CLONED;entry to second table (a2//a1)

	move.b	(A0),D0		;get green.b
	andi.b	#$0F,D0
	move.b	D0,(A0)+ 	;ensure upper bits not set
	asl.b	#4,D0		;set green to be the top 4 bits

	move.b	(A0),d2		;get blue.n
	andi.b	#$0F,d2
	move.b	d2,(A0)+ 	;ensure upper bits not set
	or.b	d2,D0		;add in blue
	move.b	D0,(a1)+	;save (green.n,blue.n)
	move.b	D0,(a2)+ ;CLONED;entry to second table (a2//a1)

	;;;clr.b	(A0)+		;clear the dont care (4th) byte
	LEA	1(A0),A0	;preserve/skip VALUE BYTE (4th in LongClrTbl)
   dbf d1,MCTloop

	;move sprite color data	into color # 17
	lea	2(a1),a1	;was pointing to color 16, move to 17
	lea	2(a2),a2 ;CLONED;entry to second table (a2//a1)

	move.b	Paintred_(BP),D0
	andi.b	#$0F,D0
	move.b	D0,(a1)+
	move.b	D0,(a2)+ ;CLONED;entry to second table (a2//a1)

	move.b	Paintgreen_(BP),D0
	asl.b	#4,D0
	andi.b	#$F0,D0
	or.b	Paintblue_(BP),D0
	move.b	D0,(a1)+
	move.b	D0,(a2)+ ;CLONED;entry to second table (a2//a1)

	movem.l	(sp)+,D0/d1/d2/A0/a1/a2	;saves all but a6...any? necessary?


	move.l	ScreenPtr_(BP),a0	;bigpic screenptr
	lea	BigPicColorTable_(BP),a1
	bsr	Isl_LoadRGB
	xref	FlagNeedMakeScr_	;02FEB92...helps w/2.0 sprite colors, causes remakedisplay
	st	FlagNeedMakeScr_(BP)	;02FEB92...helps w/2.0 sprite colors, causes remakedisplay

	moveq	#0,d0
	move.b	Paintred_(BP),d0	;$xxxR
	asl.b	#4,d0			;$xxRx
	or.b	Paintgreen_(BP),d0	;$xxRG add in green bits
	asl.w	#4,d0			;$xRGx
	or.b	Paintblue_(BP),d0	;$xRGB add in blue bits

	move.w	d0,-(sp)		;STACK  d0=color#rgbinaword

	move.l	MScreenPtr_(BP),a0
	lea	HamToolColorTable_(BP),a1	;use mine...
	move.w 	d0,(17*2)(a1)		;force new color into #17,whichisthe18th
	move.w	#$0fff,(19*2)(a1)	;bright white sprite?
	bsr.s	Isl_LoadRGB

	move.w	(sp),d0	;retrieve rgb color for sprite
	move.l	TScreenPtr_(BP),a0	;ham tools
	lea	HamToolColorTable_(BP),a1	;use mine...
	move.w 	d0,(17*2)(a1)		;force new color into #17,whichisthe18th
	move.w	#$0fff,(19*2)(a1)	;bright white sprite?


	movem.l	d0-d1/a0-a1,-(sp)
	lea	HiresColorTable_(BP),a0		;ONLY CHANGE SPRITE WHITE ON HIRES(?)
	move.w	#15,d0
13$	
	move.w	(a0)+,(a1)+			;copy color table
	dbf	d0,13$
	movem.l	(sp)+,d0-d1/a0-a1


	move.l	TScreenPtr_(BP),a0	;ham tools
	lea	(a1),a2			;next time,HamToolColorTable_(BP),a2
	bsr.s	Isl_LoadRGB

	move.w	(sp)+,d0		;retrieve rgb color for sprite

	move.l	XTScreenPtr_(BP),a0
	lea	HiresColorTable_(BP),a1	;ONLY CHANGE SPRITE WHITE ON HIRES(?)
	move.w	(a2),(a1)		;force HIRES COLOR ZERO = hampalette 0


		;color zero is "workbench blue-ish" when "no screen"
	tst.l	ScreenPtr_(BP)	;bigpic
	bne.s	50$		;gotabigpic
	move.w	#$05a,(a1)	;color zero= r0 g5 b10
50$:	;gotabigpic:


	;JULY251990;move.w 	d0,(15*2)(a1)		;paint color=>color 15, BRUSH & TextGads
	move.w 	d0,(17*2)(a1)		;force new color into #17,whichisthe18th
	move.w 	d0,(18*2)(a1)		;force new color into #18,whichisthe19th
	;move.w	#$0fff,(19*2)(a1)	;bright white sprite?
	or.w	#$0333,d0	;"jack bright colors up"
	cmp.w	#$0fff,d0	;color=white(bright)?
	bne.s	87$
	move.w	#$0aaa,d0	;gray-ish
	bra.s	88$
87$	move.w	#$0fff,d0	;definite white
88$	move.w	d0,(19*2)(a1)	;bright white sprite?

	bsr.s	Isl_LoadRGB		;preserves a1=colortableptr

	move.l	SkScreenPtr_(BP),a0	;MiniScreen for digits? (using hires ct)
	bsr.s	Isl_LoadRGB
	rts

Isl_LoadRGB:	;Graphics call stub, a0=Screen, a1=cm, preserves a1 (a2 ok also)


	cmp.l	#0,a0
	beq.s	9$	;bum screenptr arg?
	lea	sc_ViewPort(a0),a0	;viewport struct inside screen struct
	move.l	a1,-(sp)	;save color map for next time

		;june22...set hardware sprites, for color picking
		;26JAN92...setup 2.0 version sprite colors....		
	;;;move.l	SkScreenPtr_(BP),d0
	;;;cmp.l	FirstScreen_(BP),d0 ;ib_FirstScreen(a6),d0	;little hires rgb #s in front?
	;;;beq.s	7$ ;contnorm
		;26JAN92...don't stuff hardware if toaster copper list up...
	xref	FlagToastCopList_
	tst.b	FlagToastCopList_(BP)	;true when toaster coplist displayed
	bne.s	7$		
	move.l	SkScreenPtr_(BP),d0
	cmp.l	FirstScreen_(BP),d0 ;ib_FirstScreen(a6),d0	;little hires rgb #s in front?
	beq.s	7$ ;contnorm

	move.w	(17*2)(a1),$dff000+$1a2	;color17, -> color register hardware
7$:	;contnorm:


	moveq	#20,d0	;number of entries, ensure we get 'sprite white' too
	CALLIB	Graphics,LoadRGB4	
	move.l	(sp)+,a1	;colortable
9$	rts

GrayPointer:
	move.w	#$0777,d0	;make pointer be gray #7 (12)
	lea	HiresColorTable_(BP),a1	;'global' usage, hires scr
	move.w 	d0,(17*2)(a1)	;force new color into #17,whichisthe18th
	move.w	d0,(19*2)(a1)	;#$0fff,(19*2)(a1);bright white sprite?

  ifc 't','f' ;march20'89
	bsr.s	Isl_LoadRGB		;preserves a1=colortable ptr
	move.l	SkScreenPtr_(BP),d0	;MiniScreen for digits?
	beq.s	noskscr2
	move.l	d0,a0
	bra.s	Isl_LoadRGB
noskscr2:
  endc
	st	FlagGrayPointer_(BP) ;usecolormap only does hires gray loadrgb4

	rts

SetPointerTo:
  KLUDGEOUT
	moveq	#6+9-6,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	PointerTo_data,a1
	move.l	a1,CurrentPointer_(BP)

	movem.l	d0-d3/a1,-(sp)
	move.l	GWindowPtr_(BP),a0	;regular/text gadgets
	bsr.s	intuition_setpointer
	movem.l	(sp),d0-d3/a1
	move.l	ToolWindowPtr_(BP),a0	;ham toolbox
	bsr.s	intuition_setpointer
	movem.l	(sp)+,d0-d3/a1
	move.l	WindowPtr_(BP),a0

intuition_setpointer:
	cmp.l	#0,a0		;window not opened?
	beq.s	anrts

		;MAY10'89
	lea	CusPtr_Pointer,a2	;'std brush'
	cmp.l	a1,a2
	beq.s	reallysetp

	cmp.l	wd_Pointer(a0),a1
	beq.s	anrts		;pointer already set to this one
reallysetp:
	JMPLIB	Intuition,SetPointer
anrts:	rts

	xref FlagRequest_
	xref PrintCopies_
	xref FlagSave_
	xref FlagSizer_
	xref FlagPrinting_

AproPointer:	;appropriate hires ptr
  KLUDGEOUT

	tst.b	FlagPrinting_(BP)
	bne	SetPointerWait

	;move.l	ToolWindowPtr_(BP),a0	;elim 'wait' for hamtools APRIL13
	;bsr	intu_clrptr

	move.b	FlagOpen_(BP),d0
	or.b	FlagSave_(BP),d0
	or.b	FlagRequest_(BP),d0
	or.b	PrintCopies_(BP),d0
	or.b	FlagSizer_(BP),d0
	bne	HiresPtrHires		;yep, set pointer for 'hires'

	suba.l	a1,a1	;a1=0//null for apro'

	move.l	GWindowPtr_(BP),d0	;hires window
	beq.s	anrts			;enda_apro, no hires window
	move.l	wd_Pointer(a1,d0.L),d0	;a1=null, d0=hiresmouseptr

skipifptr:	macro
	cmp.l	#\1,d0
	beq.s	anrts
	endm

	skipifptr PointerTo_data	;dont change ptr if any of these

	tst.b	FlagMagnify_(BP)
	beq.s	notmagging
	skipifptr PointerMagnify_data
notmagging
	skipifptr PointerCut_data

	tst.b	FlagPick_(BP)
	bne	SetPointerPick

	xref FlagNeedRepaint_		;may02..
	tst.b	FlagNeedRepaint_(BP)
	beq.s	19$	;e	12$	;ClearPointer		;.s	killpickptr

	xref FlagSetGrid_		;DigiPaint PI
	tst.b	FlagSetGrid_(BP)	;DigiPaint PI
	bne.s	19$

	tst.l	PasteBitMap_Planes_(BP)	;really have a brush?
	beq	ClearPointer
19$
	skipifptr PointerPickWhat_data	;MAY02 note: *this* causes problems?
;;killpickptr:				;may02

	;no need;move.l	IntuitionLibrary_(BP),a6 ;check out 'front screens'
	move.l	FirstScreen_(BP),d1 ;ib_FirstScreen(a6),d1	;D1, watch, SCREENnptr in d-reg
	beq.s	okok			;wha? no intu->1stscr?
	cmp.l	XTScreenPtr_(BP),d1	;hires screen
	beq.s	okok
	cmp.l	TScreenPtr_(BP),d1	;hamtool screen
	beq.s	okok
	cmp.l	ScreenPtr_(BP),d1	;bigpic screen in front
	beq	HiresPtrHires		;mouseimage for 'bigpicture'
	cmp.l	MScreenPtr_(BP),d1	;magnify screen
	beq.s	HiresPtrHires		;mouseimage for 'bigpicture' on magnify

	tst.w	sc_MouseY(a1,d1.L)	;d1=ib_FirstScreen, a1=0=null
	;june291990;bmi.s	okok			;"above" front screen
	bpl.s	mouseonhires
	cmp.w	#-1,sc_MouseY(a1,d1.L)
	beq.s	mouseonhires
	cmp.w	#-2,sc_MouseY(a1,d1.L)
	beq.s	mouseonhires
	cmp.w	#-3,sc_MouseY(a1,d1.L)
	beq.s	mouseonhires
	bra.s	okok		;on some other window
mouseonhires:

	move.l	GWindowPtr_(BP),d0
	beq	anrts			;enda_apro
	move.l	d0,a0
	bra	intu_clrptr

okok:	;one of "our" screens in front

	move.l	MScreenPtr_(BP),d0
	beq.s	trymain			;no magnify scr
	tst.w	sc_MouseY(a1,d0.L)
	bpl.s	HiresPtrHires		;mouseimage for 'bigpicture'
trymain:
	move.l	XTScreenPtr_(BP),d0	;hires tools/menu
	beq.s	tryhtool		;no scr?
	tst.w	sc_MouseY(a1,d0.L)
	bpl.s	HiresPtrHires
tryhtool:
	move.l	TScreenPtr_(BP),d0	;ham tools
	beq.s	trybig			;no scr?
	tst.w	sc_MouseY(a1,d0.L)
	bpl.s	HiresPtrHamTool
trybig:
	tst.l	ScreenPtr_(BP)		;bigpic
	beq.s	HiresPtrHires		;no big screen, use hires ptr
	bra.s	HiresPtrHires		;mouseimage for 'bigpicture'
enda_apro:
	rts

HiresPtrHamTool:
	moveq	#6+2,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	PointerPickOnly_data,a1
	move.l	a1,CurrentPointer_(BP)

	move.l	GWindowPtr_(BP),a0 	;regular/text gadgets
	bra	intuition_setpointer
	;rts

ResetPointer:	;make pointer be "whatever it's supposed to be"
  KLUDGEOUT
	xref	FlagNeedHiresAct_
	st	FlagNeedHiresAct_(BP)

HiresPtrHires:
  KLUDGEOUT
		;may04'89...ensure hamtool pointer is 'cleared'
	move.l	ToolWindowPtr_(BP),a0
	bsr	intu_clrptr


	tst.b	FlagMagnify_(BP)
	beq.s	nomag_glass
	tst.b	FlagMagnifyStart_(BP) 
	beq	SetPointerMagnify 
nomag_glass:
	tst.b	FlagPick_(BP)
	bne	SetPointerPick	 

	tst.b	FlagSetGrid_(BP)	;DigiPaint PI
	bne.s	1$
	tst.b	FlagCutPaste_(BP)	 
	bne	SetPointerCut
1$
	move.l	GWindowPtr_(BP),d0 	;regular/text gadgets
	beq	enda_hr
	move.l	d0,a0
	tst.b	FlagMenu_(BP)		;menu displayed/verified?
	bne	intu_clrptr
	tst.b	FlagSizer_(BP)
	bne	intu_clrptr
	tst.W	FlagOpen_(BP)	;open.b, save.b
	bne	intu_clrptr	;clear if requester

	tst.b	FlagSetGrid_(BP)	;DigiPaint PI
	bne.s	nocutout_brush

	tst.b	FlagCutPaste_(BP)
	beq.s	nocutout_brush
	tst.l	PasteBitMap_Planes_(BP)	;carrying a brush?
	bne	intu_clrptr
nocutout_brush:
	;tst.b	FlagMenu_(BP)
	;bne	intu_clrptr	;clear if menu displayed

	;no need;move.l	IntuitionLibrary_(BP),a6 ;check out 'front screens'
	move.l	FirstScreen_(BP),d1 ;ib_FirstScreen(a6),d1	;D1, watch, SCREENnptr in d-reg
	cmp.l	ScreenPtr_(BP),d1	;bigpic in front?
	beq	set_cusptr		;sets 'custom' on window in A0

	move.w	wd_MouseY(a0),d1
	bmi	EB_set_cusptr	;"above" hires, set custom brush
	;AUG051990;cmp.w	#15+1,d1
	cmp.w	#(15+1)*2,d1
	bcc	EB_intu_clrptr	;"below" 1st line of tools on hires

	tst.b	FlagCtrl_(BP)
	bne	intu_clrptr	;clear if slider tools
	tst.b	FlagCtrlText_(BP)
	bne	intu_clrptr	;clear if text tools
	tst.b	FlagPale_(BP)
	bne	intu_clrptr	;clear if palette tools

	move.w	wd_MouseX(a0),d0
	;SEP101990;cmp.w	#332-1,d0
	;SEP101990;bcs	EB_intu_clrptr	;"left" of brush size/shape tools
	;SEP101990;cmp.w	#416,d0
	;SEP101990;bcc	EB_set_cusptr	;"right of" hires, set custom brush

	;SEP101990;
	cmp.w	#352,d0
	bcs	EB_intu_clrptr	;"left" of brush size/shape tools
	bra	EB_set_cusptr	;"right of" hires, set custom brush
		;note:"Dead" code after here...SEP101990

		;redo "pointer over brush gadgets"
  IFC 't','f' ;june291990
	tst.W	FlagOpen_(BP)	;open.b, save.b, load/save requester alive?
	bne.s	filereq_open
	tst.b	FlagGadgetDown_(BP)	;set/clrd by main.msg
	beq	set_cusptr	;standard brush (if any)
	;MAY90;movem.l	d0/a0,-(sp)
	;MAY90;xjsr	ClearBrushImagery
	;MAY90;xjsr	GraphicsWaitBlit
	;MAY90;movem.l	(sp)+,d0/a0
filereq_open:
  ENDC ;june291990
calcBrushNumber:	MACRO
	move.w	BrushType_(BP),d1
	subq	#1,d1
	bcc.s	cbn1\@
	moveq	#6,d1			;brush rtn #6 is single dot
	bra.s	cbn2\@			;type '0' (dotb) forces size, too
cbn1\@	mulu	#7,d1
	add.w	BrushSize_(BP),d1	;0..6
cbn2\@	move.w	d1,BrushNumber_(BP)	;0..41
	ENDM

	move.l	a0,-(sp)
	move.w	BrushNumber_(BP),d2
	move.w	BrushSize_(BP),d3
	move.w	BrushType_(BP),d4
	movem.w	d2/d3/d4,-(sp)	;save curt brush info


	;332 leftedge of sizes, each 12 wide
	;. 460,27, 490,27 ,520, 550, 580, 610
ifleftof:	macro ;hiresedge,number,size/type
	cmp.w	#\1,d0
	bcc.s	iflo\@
	move.w	#\2,Brush\3_(BP)	;BrushSize_ or BrushType_
	bra	got_size_type
iflo\@:
	endm

  IFC 't','f' ;june291990
	ifleftof 332+12,0,Size	;LARGEST
	ifleftof 344+12,1,Size
	ifleftof 356+12,2,Size
	ifleftof 368+12,3,Size
	ifleftof 380+12,4,Size
	ifleftof 392+12,5,Size
	ifleftof 404+12,6,Size	;SMALLEST

	ifleftof 430+30,0,Type
	ifleftof 460+30,1,Type
	ifleftof 490+30,2,Type
	ifleftof 520+30,3,Type
	ifleftof 550+30,4,Type
	ifleftof 580+30,5,Type
	;ifleftof 610+30,6,Type	;macro "saved" from expansion
	cmp.w	#610+30,d0
	bcs.s	got_size_type
	move.w	#6,BrushType_(BP)
  ENDC ;june291990
got_size_type:
	calcBrushNumber

	;MAY90;xjsr	BGadDisplay	;redo pointer imagery (CUSTOMIZE HERE)
	xjsr	BGadDisplay	;redo pointer imagery (CUSTOMIZE HERE) june291990

	move.w	BrushNumber_(BP),DispBrushNumber_(BP) ;displayed brush #

	movem.w	(sp)+,d2/d3/d4	;restore current brush info

	move.l	(sp)+,a0

		;force pointer, re-call intuition

	move.w	BrushNumber_(BP),d0
	cmp.w	#6,d0			;single dot?
	bne.s	1$
	lea	GenericCrossHair_Pointer,a1	;single dot gets 'crosshair'
	moveq	#14,d0	;height 
	moveq	#16,d1	;width
	moveq	#-8,d2	;xoffset//hotspot
	moveq	#-7,d3	;yoffset
	bra.s	2$
1$
	lea	CusPtr_Pointer,a1
	moveq	#20-2,d0 ;height 
	moveq	#16,d1	;width
	moveq	#-6,d2	;xoffset//hotspot
	moveq	#-6,d3	;yoffset
2$	bra	really_setpointer
	;rts

EB_set_cusptr:				;end brush sizer? may01
 IFC 't','f' ;june291990
	tst.b	FlagGadgetDown_(BP)	;set/clrd by main.msg
	beq.s	set_cusptr
	sf	FlagGadgetDown_(BP)	;set/clrd by main.msg
	st	FlagNeedGadRef_(BP)	;clearzout/resets brush size imagery
 ENDC
set_cusptr:	;sets it on window in A0
	move.w	BrushNumber_(BP),d0
	cmp.w	#6,d0			;single dot?
	bne.s	1$
	lea	GenericCrossHair_Pointer,a1	;single dot gets 'crosshair'
	moveq	#14,d0	;height 
	moveq	#16,d1	;width
	moveq	#-8,d2	;xoffset//hotspot
	moveq	#-7,d3	;yoffset
	bra.s	2$
1$
	lea	CusPtr_Pointer,a1
	moveq	#20-2,d0 ;height 
	moveq	#16,d1	;width
	moveq	#-4+1-4,d2	;xoffset//hotspot
	moveq	#-6-4,d3	;yoffset
	lea	CusPtr_Pointer,a1

2$	bra	intuition_setpointer
	;rts

enda_hr:
	rts

EndOf_AltPtr:		;SEP081990....
	xref	MsgPtr_
	xref	FlagRepainting_		;SEP111990
	xref	FlagNeedRepaint_	;SEP121990
	xref	FlagOpen_		;SEP121990
	tst.l	MsgPtr_(BP)	;already HAVE a msg?
	bne.s	9$
	xjsr	ScrollAndCheckCancel	;canceler.asm, dumps moves...SEP121990
	bne.s	9$		;no right mouse button "off" - wanna cancel
	tst.b	FlagRepainting_(BP)	;SEP111990
	bne.s	9$		;don't turn off "right button cancel" if repainting...
	tst.b	FlagNeedRepaint_(BP)	;SEP121990
	bne.s	9$		;also not if need repaint
	;tst.W	FlagOpen_(BP)	;loading or saving?	;SEP121990
	tst.b	FlagOpen_(BP)	;file loading?	;SEP121990
	bne.s	9$
	xjsr	CheckIDCMP	;main.msg.i....is a msg waiting?
	bne.s	9$
	xjmp	ResetIDCMP	;turns OFF menu verify (main.msg.i)
9$	rts

	xdef SetDiskPointerWait	;pointers.o, non-it' "disk-wait" APRIL29
SetDiskPointerWait:	;pointers.o, non-it' "disk-wait" APRIL29

SetAltPointerWait:	;alt for create determine...only non-interruptable?
  KLUDGEOUT

	pea	EndOf_AltPtr(pc)	;SEP081990
	move.l	WindowPtr_(BP),a0	;big picture

		;(DUPLICATE CODE....swiped from 'setcrosshair')
	moveq	#6+2,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	Blank_Pointer,a1

	bsr	intuition_setpointer
	lea	AltPointerSnz_data,a1	;'alternate' wait image (revrs'd colors)
	bra.s	cont_pw

SetPointerWait:
  KLUDGEOUT
		;MAY22
	xref EffectNumber_
	cmp.b	#3,EffectNumber_(BP)	;flip/rotates?
	bcc	SetAltPointerWait	;can't cancel these....

	move.l	WindowPtr_(BP),a0	;big picture

		;(DUPLICATE CODE....swiped from 'setcrosshair')
	moveq	#6+2,d0	;height 
	moveq	#16,d1	;width
	moveq	#-1,d2	;xoffset//hotspot
	moveq	#-3,d3	;yoffset
	lea	Blank_Pointer,a1

	bsr	intuition_setpointer
	lea	PointerSnz_data,a1	;'regular' wait ptr for hires
cont_pw:	;"continue pointer wait" code...altpointer entry

	moveq	#23,d0	;height 
	moveq	#16,d1	;width
	moveq	#-7,d2	;xoffset//hotspot
	moveq	#-8,d3	;yoffset
	move.l	GWindowPtr_(BP),a0	;put wait ptr on hires
	bsr	intuition_setpointer

	lea	PointerSnz_data,a1	;'regular' wait ptr for hires
	moveq	#23,d0	;height 
	moveq	#16,d1	;width
	moveq	#-7,d2	;xoffset//hotspot
	moveq	#-8,d3	;yoffset
	move.l	ToolWindowPtr_(BP),a0	;put 'regular' wait ptr on hamtools
	bsr	intuition_setpointer

	st	FlagNeedHiresAct_(BP)
	bra	GrayPointer		;make pointer color be gray
	;rts


 section data,DATA	;we need chip ram only for image data

NegativeColorTable: ;this color table WORKS/LOOKS OK for standalone & switcher...
	dc.w $0000 ;$0666
	dc.w $0aaa
	dc.w $0aaa ;$0fff
	dc.w $0666 ;$0fff ;$0000
	;SEP061990;dcb.w	(12+4),$0
	dcb.w	12,$0888	;gray for pointer...SEP061990
	dc.w $0777		;sprite colors...
	dc.w $0fff
	dc.w $0777
	dc.w $0fff

PointerSnz_data:	;the 'EURO' look
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w %0000011000000000,%0000011000000000
	dc.w %0000111101000000,%0000111101000000
	dc.w %0011111111100000,%0011111111100000
	dc.w %0011111111100000,%0011111111100000

	dc.w %0111111111100000,%0111111111100000
	dc.w %0110000111110000,%0111111111110000
	dc.w %0111101111111000,%0111111111111000
	dc.w %1111011111111000,%1111111111111000

	dc.w %0110000111111100,%0111111111111100
	dc.w %0111111100001100,%0111111111111100
	dc.w %0011111111011110,%0011111111111110
	dc.w %0111111110111100,%0111111111111100

	dc.w %0011111100001100,%0011111111111100
	dc.w %0001111111111000,%0001111111111000
	dc.w %0000011111110000,%0000011111110000
	dc.w %0000000111000000,%0000000111000000

	dc.w %0000011100000000,%0000011100000000
	dc.w %0000111111000000,%0000111111000000
	dc.w %0000011010000000,%0000011010000000
	dc.w %0000000000000000,%0000000000000000

	dc.w %0000000011000000,%0000000011000000
	dc.w %0000000011100000,%0000000011100000
	dc.w %0000000001000000,%0000000001000000

	dc.w 0,0
	dc.w 0,0	;need these also???	


 XDEF AltPointerSnz_data	;SEP081990...for "reset idcmp"
AltPointerSnz_data:	;simply the "complement" of the normal wait ptr
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w %0000011000000000,%0000011000000000
	dc.w %0000111101000000,%0000111101000000
	dc.w %0011111111100000,%0011111111100000
	dc.w %0011111111100000,%0011111111100000

	dc.w %0111111111100000,%0111111111100000
	dc.w %0111111111110000,%0111111111110000
	dc.w %0111111111111000,%0111111111111000
	dc.w %1111111111111000,%1111111111111000

	dc.w %0111111111111100,%0111111111111100
	dc.w %0111111111111100,%0111111111111100
	dc.w %0011111111111110,%0011111111111110
	dc.w %0111111111111100,%0111111111111100

	dc.w %0011111111111100,%0011111111111100
	dc.w %0001111111111000,%0001111111111000
	dc.w %0000011111110000,%0000011111110000
	dc.w %0000000111000000,%0000000111000000

	dc.w %0000011100000000,%0000011100000000
	dc.w %0000111111000000,%0000111111000000
	dc.w %0000011010000000,%0000011010000000
	dc.w %0000000000000000,%0000000000000000

	dc.w %0000000011000000,%0000000011000000
	dc.w %0000000011100000,%0000000011100000
	dc.w %0000000001000000,%0000000001000000

	dc.w 0,0
	dc.w 0,0	;need these also???	


;	dc.w 0,0	;2 null words, position&control
;	;     0123456789abcdef  0123456789abcdef
;
;	dc.w %0000111100000000,%0000111100000000
;	dc.w %0001000011100000,%0001111111100000
;	dc.w %0100000000010000,%0111111111110000
;	dc.w %0100000000010000,%0111111111110000

   ifc 't','f'
	dc.w %1000000000010000,%1111111111110000
	dc.w %1001111000001000,%1111111111111000
	dc.w %1000010000000100,%1111111111111100
	dc.w %1000100000000100,%1111111111111100

	;dc.w %1001111000000010,%1111111111111110
	;dc.w %1000000011110010,%1111111111111110
	;dc.w %0100000000100001,%0111111111111111
	;dc.w %1000000001000010,%1111111111111110
	dc.w %1001111000000010,%1111111111111110
	dc.w %1000000000000010,%1111111111111110
	dc.w %0100000000000001,%0111111111111111
	dc.w %1000000000000010,%1111111111111110

	;dc.w %0100000011110010,%0111111111111110
	dc.w %0100000000000010,%0111111111111110
	dc.w %0010000000000100,%0011111111111100
	dc.w %0000100000001000,%0000111111111000
	dc.w %0000001000100000,%0000001111100000
   endc

;	dc.w %0100000000100000,%0111111111100000
;	dc.w %0100000000010000,%0111111111110000
;	dc.w %0100111111001000,%0111111111111000
;	dc.w %1001100001101000,%1111111111111000
;
;	dc.w %0100011011000100,%0111111111111100
;	dc.w %0100110110000100,%0111111111111100
;	dc.w %0010100001100010,%0011111111111110
;	dc.w %0101111111000100,%0111111111111100
;
;	dc.w %0010000000000100,%0011111111111100
;	dc.w %0001000000001000,%0001111111111000
;	dc.w %0000010000010000,%0000011111110000
;	dc.w %0000000101000000,%0000000111000000
;
;
;	dc.w %0000110000000000,%0000111110000000
;	dc.w %0001000000100000,%0001111111100000
;	dc.w %0000100001000000,%0000111111000000
;	dc.w %0000000000000000,%0000000110000000
;
;	dc.w %0000000100100000,%0000000111100000
;	dc.w %0000000100010000,%0000000111110000
;	dc.w %0000000010100000,%0000000011100000
;
;	dc.w 0,0
;	dc.w 0,0	;need these also???	

PointerPick_data:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w %0001100000000000,%0000000000000000
	dc.w %0011111111111110,%0000000000000000
	dc.w %0111111111111111,%0000000000000000
	dc.w %1111111111111111,%1000000000000000
	dc.w %0111111111111111,%0000000000000000
	dc.w %0011111111111110,%0000000000000000
	dc.w %0001100000000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000
	dc.w 0,0
	;dc.w %1110010000010000,%1111010000010000
	;dc.w %1001000011010110,%1111101011011110
	;dc.w %1001010100011000,%1101110111111111
	;dc.w %1110010100010100,%1111011110011100
	;dc.w %1000010011010010,%1100011111111111
	;dc.w %0000000000000000,%0100001001101011
	dc.w 0,0
	dc.w 0,0	;need these also???	

PointerPickWhat_data:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w %0001100000000000,%0000000000000000
	dc.w %0011111111111110,%0000000000000000
	dc.w %0111111111111111,%0000000000000000
	dc.w %1111111111111111,%1000000000000000
	dc.w %0111111111111111,%0000000000000000
	dc.w %0011111111111110,%0000000000000000
	dc.w %0001100000000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000
	dc.w 0,0
	;dc.w %1110010000010000,%1111010000010000
	;dc.w %1001000011010110,%1111101011011110
	;dc.w %1001010100011000,%1101110111111111
	;dc.w %1110010100010100,%1111011110011100
	;dc.w %1000010011010010,%1100011111111111
	;dc.w %0000000000000000,%0100001001101011
	dc.w 0,0
	dc.w 0,0	;need these also???	

PointerPickOnly_data:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w %0001100000000000,%0000000000000000
	dc.w %0011111111111110,%0000000000000000
	dc.w %0111111111111111,%0000000000000000
	dc.w %1111111111111111,%1000000000000000
	dc.w %0111111111111111,%0000000000000000
	dc.w %0011111111111110,%0000000000000000
	dc.w %0001100000000000,%0000000000000000

	dc.w %0000000000000000,%0000000000000000
	dc.w 0,0
	dc.w 0,0	;need these also???	


PointerTo_data:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w %0001100000001110,%0000000000001110
	dc.w %0011101111011011,%0000000000011011
	dc.w %0111011111000011,%0000000000000011
	dc.w %1110111111000110,%1000000000000110
	dc.w %0111011111001100,%0000000000001100
	dc.w %0011101111001100,%0000000000001100
	dc.w %0001100000000000,%0000000000000000
	dc.w %0000000000001100,%0000000000001100
	dc.w 0,0
	;dc.w %1111110001110000,%1111110001111000
	;dc.w %0010000010001000,%0111111011111100
	;dc.w %0010000010001000,%0011000011001100
	;dc.w %0010000010001000,%0011000011001100
	;dc.w %0010000001110000,%0011000011111100
	;dc.w %0000000000000000,%0001000001111000
	;dc.w 0,0
	dc.w 0,0
	dc.w 0,0	;need these also???	

PointerMagnify_data:
	dc.w 0,0	;2 null words, position&control
	dc.w %0011110000000000,%0000000000000000
	dc.w %0100001000000000,%0011110000000000
	dc.w %1000000100000000,%0000001000000000
	dc.w %1001000100000000,%0001001000000000
	dc.w %1000000100000000,%0000001000000000
	dc.w %1000000100000000,%0000001000000000
	dc.w %0100001100000000,%1000000000000000
	dc.w %0011111110000000,%0100000000000000
	dc.w %0000000111000000,%0011111000000000
	dc.w %0000000011100000,%0000000100000000
	dc.w %0000000001100000,%0000000010000000
	dc.w 0,0
	dc.w 0,0	;need these also???	


PointerCut_data:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef
	dc.w %0111000000001000,%0000000000000000
	dc.w %1000100000010000,%0000000000100000
	dc.w %1000100000100000,%0000000001000000
	dc.w %1000100001000000,%0000000011000000
	dc.w %0111011011000000,%0000000100111110
	dc.w %0000010101111111,%0000001000000000
	dc.w %0011111000000000,%0000000000000000
	dc.w %0100010000000000,%0000000000000000
	dc.w %0100010000000000,%0000000000000000
	dc.w %0100010000000000,%0000000000000000
	dc.w %0011100000000000,%0000000000000000
	dc.w 0,0
	dc.w 0,0	;need these also???	

GenericCrossHair_Pointer:
	dc.w 0,0	;2 null words, position&control
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000	;dc.w %0000000100000000,%0000000000000000
	dc.w %0000000110000000,%0000001100000000
	dc.w %0000010000000000,%0000000001000000
	;MAY31;dc.w %1110010001001110,%0000010001000000	;dc.w %1111110001111110,%0000010001000000
	dc.w %1110010101001110,%0000010101000000	;dc.w %1111110001111110,%0000010001000000
	dc.w %0000000001000000,%0000010000000000
	dc.w %0000001100000000,%0000000110000000
	dc.w %0000000000000000,%0000000000000000	;dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w 0,0
	dc.w 0,0	;need these also???	

CutCrossHair_Pointer:
	dc.w 0,0	;2 null words, position&control
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000100000000
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000
	dc.w %1110000000001110,%0010000000001000
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000000000000,%0000000000000000
	dc.w %0000000100000000,%0000000100000000
	dc.w %0000000100000000,%0000000000000000
	dc.w %0000000100000000,%0000000000000000
	dc.w 0,0
	dc.w 0,0	;need these also???	

Blank_Pointer:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w %1000000000000000,%1000000000000000
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0	;need these also???	
Invis_Pointer:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0	;need these also???	



 xdef CusPtr_Pointer
CusPtr_Pointer:
	dc.w 0,0	;2 null words, position&control
	;     0123456789abcdef  0123456789abcdef

	dc.w 0,0 ;$5a5a,0
	dc.w 0,0 ;$a5a5,0
	dc.w 0,$4000 ;$5a5a,$4000	;"hotspot" in 2nd bit
	dc.w 0,0 ;$a5a5,0
	dc.w 0,0 ;$5a5a,0
	dc.w 0,0 ;$a5a5,0
	dc.w 0,0 ;$5a5a,0
	dc.w 0,0 ;$a5a5,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0	;need these also???	

	dc.w 0,0	;these extra for "new" taller brushes
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0


	dc.w 0,0	;12 additional lines for "steve's big circle brushes"
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0
	dc.w 0,0

	;no need....;dcb.b 256,0

 END
