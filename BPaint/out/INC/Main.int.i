;OnInt: enable a simple vertical blank interrupt that decrements a ticker
;OffInt: disables same

AirTicks	set 32 ;#ticks (1/2 second NTSC) between airbrush spatters

	xref FlagDoAir_		;handled by interrupt routine (main.int.i)
	xref FlagRepainting_
	xref TickerStopped_	;long
	xref FlagScrollStopped_

  include "intuition/intuitionbase.i"	;firstscreen field
	xref FirstScreen_

OnInt:
	lea	IntServer_(BP),a1	;int server node on *my* base page
	move.b	#NT_INTERRUPT,d0
	cmp.b	LN_TYPE(a1),d0		;use node type as 'flag' if on/off
	beq.s	intrts
	move.b	d0,LN_TYPE(a1)

	;move.b	#20,LN_PRI(a1)		;set priority of the server WANT HIGHER?
	;APRIL17...zero priority...default
	move.b	#2,LN_PRI(a1)	;set server pri=2 (relative, anyway)

	move.l	ProgNamePtr_(BP),LN_NAME(a1)	;nice to give names to nodes

	move.l	BP,IS_DATA(a1)		;server data ptr set to basepage area
	lea	IntServerCode(pc),a0	;set up pointer to the code
	move.l	a0,IS_CODE(a1)		;adr of code that actually runs
	;AUG311990;move.w	#(4-1),Ticker_(BP)	;init tick count
	move.L	#(4-1),Ticker_(BP)	;init tick count
	moveq	#INTB_VERTB,d0		;hooking into VBlank int
	JMPLIB	Exec,AddIntServer	;start it up
OffInt:
	lea	IntServer_(BP),a1
	move.b	#NT_INTERRUPT,d0
	cmp.b	LN_TYPE(a1),d0		;use node type as 'flag' if on/off
	bne.s	intrts			;must not be 'on' if not nodetype_int
	clr.b	LN_TYPE(A1)		;our 'flag' if on/off already
	moveq	#INTB_VERTB,d0		;server chain
	CALLIB	Exec,RemIntServer
intrts	rts	;offint

IntServerCode:	;server code, we loaded node so A1=DATAPTR (use A1 for BasePage)
	subq.L	#1,Ticker_(a1)

	xref FlagXSpe_
	tst.b	FlagXSpe_(a1)
	beq.s	doneeye
	or.b	#$80,$bfe201	;setup data direction register 'a'

	btst.b	#0,3+Ticker_(a1) ;left or right?
	bne.s	reye

	and.b	#$7f,$bfe001	;do "this" to periph' data reg. 'a'
	bra.s	doneeye
reye
	or.b	#$80,$bfe001	;...or do "this"
doneeye	


	;SIGNAL "awaken" when scrolling (mouse on edge of screen)
	;WO!!!!!!!!;SATURDAY MAY12'90;tst.L	ScrollSpeedX_(BP)	;scroll(x,w).w, moving screen?
	;14NOV91;tst.L	ScrollSpeedX_(A1)	;scroll(x,w).w, moving screen?
	;14NOV91;bne.s	8$			;yep....awaken, main.key.i does scroll

  IFC 'F','EXTRAS'
	;HANDLE AIRBRUSH
	;signal bit # is one in "main/only port"

	;;every (odd) tick, signal digipaint (Wake up call)
	;move.L	Ticker_(a1),d0
	;;;and.b	#4-1,d0 ;#~AirTicks,d0		;every 30 ticks/ 2times a second
	;and.b	#1,d0 ;#~AirTicks,d0		;every 30 ticks/ 2times a second
	;bne.s	9$

	xref FlagAir_
	tst.b	FlagAir_(a1)
	beq.s	9$

	tst.b	FlagNeedRepaint_(a1)	;'pen down'?
	beq.s	9$			;nope
	tst.b	FlagRepainting_(a1)
	bne.s	9$			;nope

		;calc d0=signal mask
	lea	OnlyPort_(a1),a0
	move.b	MP_SIGBIT(a0),d1
	moveq	#0,d0
	bset	d1,d0		;d0=mask of signal bits
;8$
	;st	FlagDoAir_(a1)		;asks 'mainloop' for a AIRBRUSH repeat
	move.B	#4,FlagDoAir_(a1)	;asks 'mainloop' for a AIRBRUSH repeat
8$
;;  ifc 't','f' ;TEST,KLUDGE,WANT....
	move.l	a1,-(sp)		;save a1=digipaint basepage
	move.l	ExecLibrary_(a1),a6	;$4,a6...dont access chip needlessly
	move.l	our_task_(a1),a1	;dumps BASEPAGE
	CALLIB	SAME,Signal		;signal digipaint...drawairbrush
	move.l	(sp)+,a1		;restore a1=digipaint basepage
;;  endc
9$
  ENDC ;AIRBRUSH EXTRAS

;  IFC 't','f' 	;JULY121990..."timer" for "scroll at bottom"


		;KEEP TRACK OF "screen in front"
	move.l	IntuitionLibrary_(a1),a0			;july13...grab real firstscreen...
	move.l	ib_FirstScreen(a0),FirstScreen_(a1)	;munge//GRAB REAL VALU


		;DO AUTO-SCROLL TIMING, HANDLE BOTTOM DELAY, TOO
	MOVEM.L	d2/d3,-(sp)
	move.l	ScreenPtr_(a1),d0
	beq	no_intmovestop		;no screen?
	move.l	d0,a0			;screenptr
	movem.W	sc_Width(a0),d0-d3	;wt,ht,y,x d2=Mouse*Y* d3=mouseX
	;AUG311990;tst.b	FlagToast_(BP)		;AUG261990....subtract 16 if in 1x mode...
	tst.b	FlagToast_(a1)		;AUG261990....subtract 16 if in 1x mode...
	beq.s	123$
	sub.w	#16,d0
123$

	subq	#1,d0		;d0=scr width -1 for right edge check

	subq	#1,d1		;adjust scr ht for compare
	cmp.w	d1,d2		;sc_Height(a0)

	bcs.s	no_intmovestop
;;intmovestop_maybe:
	;14NOV91;tst.w	ScrollSpeedY_(a1)	;already moving/scrolling?
	;14NOV91;bne.s	scroll_signal	;go wake up...;enda_intscroll		;if moving, keep moving...
	move.l	TickerStopped_(a1),d0
	beq.s	startup_tickerstopped	;1st time?

	sub.l	Ticker_(a1),d0
	bcc.s	1$
	neg.w	d0
1$	cmp.w	#MAXTICKTIME,d0	;ticks happen yet?
	bcc.s	no_intmovestop	;maxtick' or more ticks....re-enable scrolling
;;OCTOBER'90...delay a bit longer if on 'control//blend slider panel'
;;1$	;?;cmp.w	#4*MAXTICKTIME,d0	;ticks happen yet? (approx 1.5 seocnds)
;;	;?;bcc.s	no_intmovestop	;maxtick' or more ticks....re-enable scrolling
;;	tst.b	FlagCtrl_(BP)	;control sliders?
;;	;bne.s	111$		;yep...wait longer...
;;	bne.s	startup_tickerstopped	;yep...KILL BOTTOM SCROLLING ON CONTROL SLIDERS SCREEN
;;	cmp.w	#MAXTICKTIME,d0	;ticks happen yet?
;;	bcc.s	no_intmovestop	;maxtick' or more ticks....re-enable scrolling
;;;111$
;;

	tst.b	FlagDelayBottom_(a1)		;AUG081990(BP)
	beq.s	no_intmovestop			;didn't "ask" for the delay
	st	FlagScrollStopped_(a1)
	bra.s	enda_intscroll

startup_tickerstopped:
	xref	FlagDelayBottom_		;JULY181990
	tst.b	FlagDelayBottom_(a1)		;AUG081990(BP)
	beq.s	no_intmovestop			;didn't "ask" for the delay

	;tst.b	FlagToolWindow_(a1)
	;beq.s	no_intmovestop	;NO delay if no tools not in front
	move.l	FirstScreen_(a1),d0
	cmp.l	XTScreenPtr_(a1),d0	;hires tools
	beq.s	2$
	cmp.l	SkScreenPtr_(a1),d0	;rgb# display
	bne.s	no_intmovestop	;NO delay if tools -or- rgb#s not in front
2$
	move.l	Ticker_(a1),TickerStopped_(a1)
	st	FlagScrollStopped_(a1)
	bra.s	enda_intscroll

no_intmovestop:
	;clr.l	TickerStopped_(a1)
	sf	FlagScrollStopped_(a1)

scroll_signal:
  IFC 'T','F' ;NO NEED WITH NEW TPS SCROLLER (?) 16JAN92
		;signal paint to awaken....need to scroll (?)
		;but first, check that a paint screen is in front
	move.l	FirstScreen_(a1),d0
	cmp.l	XTScreenPtr_(a1),d0	;hires tools
	beq.s	1$
	cmp.l	SkScreenPtr_(a1),d0	;rgb# display
	beq.s	1$
	cmp.l	ScreenPtr_(a1),d0	;big picture
	beq.s	1$
	cmp.l	TScreenPtr_(a1),d0	;ham tools
	;beq.s	1$
	;bra.s	enda_intscroll
	bne.s	enda_intscroll
1$

		;calc d0=signal mask
	lea	OnlyPort_(a1),a0
	move.b	MP_SIGBIT(a0),d1
	moveq	#0,d0
	bset	d1,d0		;d0=mask of signal bits

	move.l	a1,-(sp)		;save a1=digipaint basepage
	move.l	ExecLibrary_(a1),a6	;$4,a6...dont access chip needlessly
	move.l	our_task_(a1),a1	;dumps BASEPAGE
	CALLIB	SAME,Signal		;signal digipaint...drawairbrush
	move.l	(sp)+,a1		;restore a1=digipaint basepage
  ENDC

enda_intscroll:

	move.w	Joy0Y_(a1),Joy0previous_(a1)	;setup for next time AUG251991

	MOVEM.L	(sp)+,d2/d3

;;  ENDC
	move.w	Joy0Y_(a1),Joy0previous_(a1)	;setup for next time	;AUG29
	move.w	_custom+joy0dat,Joy0Y_(a1)	;SETUP CURRENT	;AUG29

	moveq	#0,d0 ;non-0 term's servers, stops those of lower pri
	rts
