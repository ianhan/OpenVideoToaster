* Canceler.asm
; main loop note//reference....ResetIDCMP s/b BEFORE redohires


	XDEF AreWeAlive		;rtns EQU=NOtactive NOTeq=YESalive
	XDEF AskDelSwapRtn	;delete swap screen for size change?
	XDEF CheckCancel	;lookat mesg list for menuverify/mousebuttons
	XDEF ScrollAndCheckCancel	;returns EQ/NE, a0=msgptr d0=im_Class
	;;XDEF QuitPainting	;removes brushstroke, activates hires

	XDEF Canceler		;returns D0, 0=continue	1=CANCEL
	XDEF DirNotFoundRtn	;displays a requester
	XDEF FileNotFoundRtn	;displays a requester
	XDEF FontErrorRtn	;displays a requester
	XDEF FontFileErrorRtn	;displays a requester
	XDEF FontTallErrorRtn
	XDEF OperFailedRtn	;displays operation failed requester
	XDEF PicFileErrorRtn	;displays a requester
	XDEF PrinterErrRtn	;"can't open printer.device"
	XDEF ReallyQuitRtn	;"Ok to Quit?"
	;XDEF RotTallErrorRtn	;"Rotate...result too tall."
	XDEF ScreenFormatRtn	;"change screen format?"
	XDEF ScreenTooBigRtn	;"new size too big"

MyFrontPen	set 3	;same as hires screen's defaults
MyBackPen	set 1	;14

	include "ds:basestuff.i"
	include "exec/types.i"
	include "exec/ports.i"	;needed for messages.i
	include "messages.i"
	include "windows.i"
	include "devices/inputevent.i"

	xref DirnameBuffer_
	xref FilenameBuffer_
	xref FlagBitMapSaved_
	xref FlagNeedIntFix_
	xref FlagNeedText_	;when called from repaint, coord disp
	xref FlagRepainting_
	xref FontNameBuffer_
	xref GWindowPtr_	;hires toolbox
	xref Initializing_
	xref LS_String_		;"Open Failed"
	xref OnlyPort_
	xref our_task_
	xref ScrollSpeedX_

AWAliveMac:	MACRO
	move.l	our_task_(BP),a1	;ptr to our task(|process) structure
	cmp.b	#-1,LN_PRI(a1)		;BYTE LN_PRI in task struct
		ENDM

AreWeAlive:	;jsr here, then say "beq deadlabel" or "bne alivelabel"
	AWAliveMac
dumbrts	rts				;Zequal means we're slow and not active


REMOVEMSG:	MACRO	;cloned from exec/lists
	MOVE.L	(A1),A0
	MOVE.L	LN_PRED(A1),A1
	MOVE.L	A0,(A1)
	MOVE.L	A1,LN_PRED(A0)
	ENDM

	xref LastScrollTick_		;last 'tick time' actually scrolled/checkcancel'd
	xref MaxTick_
	xref Ticker_

ScrollAndCheckCancel:	;returns EQ/NE, a0=msgptr d0=im_Class
  ifc 't','f' ;march14'89
	;note:m'moves stay ON always, if no moves, then NO SCROLL...
	lea	OnlyPort_(BP),A0
	lea	MP_MSGLIST(A0),A0	;TOP of list
	cmp.l	8(A0),A0		;empty list?
	beq	end_check ;continue_repaint	;end_check;yep...no messages
  endc
	move.l	LastScrollTick_(BP),d0	;last 'tick time' we magnified
	sub.l	Ticker_(BP),d0
	bcc.s	1$
	neg.l	d0
1$	;cmp.W	MaxTick_(BP),d0	
	;cmp.w	#6,d0		;10fpsntsc, 8fpspal
	cmp.w	#12,d0		;5fpsntsc, 4.?fpspal
	bcc.s	ReallySACC	;maxcount' or more ticks have gone by
	moveq	#0,d0		;no msgs...no scroll fake out
	rts

ReallySACC: ;"really" do scroll-and-check-cancel
	move.l	Ticker_(BP),LastScrollTick_(BP)	;reset ticker b4 'unshow's
	MOVEM.L	d2-d7/a1-a4/a6,-(sp)
	xjsr	AutoMove		;main.key.i
	tst.b	FlagNeedIntFix_(BP)	;did a scroll happen?
	beq.s	didntsc
scrolling:
	sf	FlagNeedIntFix_(BP)	;did a scroll happen?
	xjsr	AutoMove
	tst.b	FlagNeedIntFix_(BP)	;did a scroll happen?
	beq.s	donesc
	bsr.s	CheckCancel
	beq.s	scrolling
donesc:	st	FlagNeedIntFix_(BP)	;force a fix, since it scrolled
	xjsr	FixInterLace
	clr.L	ScrollSpeedX_(BP)	;x.w, y.w too
didntsc:				;didnt scroll
	bsr.s	CheckCancel
	MOVEM.L	(sp)+,d2-d7/a1-a4/a6
	rts

	xref FlagOpen_	;open.b, save.b
	xref PasteBitMap_Planes_
MenuDown	equ $69
MenuUp		equ $69!$80
SelectUp	equ $68!$80	;these codes basicly come from
SelectDown 	equ $68		;....devices/inputevent.i

move_die:				;kill this mousemove, A0=msg ptr
	st	FlagNeedText_(BP)	;when called from repaint, coord disp
msg_die:
	move.l	A0,-(sp)		;STACK save msgptr
	move.l	A0,a1
	REMOVEMSG			;'getmsg' of 'not first in list'
	move.l	(sp)+,a1		;deSTACK mousemove or inactwin msgptr
	CALLIB	Exec,ReplyMsg		;rtnmsg AFTER goslo (msgs signal/awake)

CheckCancel: ;rtns ZEROflag -or- d0=intui'class(spacebar,menuver,mousebut)
			;only uses registers d0/a0
		;MAY22......cant cancel an 'effect'
	xref EffectNumber_
	cmp.b	#3,EffectNumber_(BP)
	bcs.s	1$
	tst.b	PasteBitMap_Planes_(BP)	;MAY23....yes, CAN cancel screen fx
	beq.s	1$
	moveq	#0,d0
	rts
1$




	moveq	#0,d0			;null msg class, in case no msgs
	lea	OnlyPort_(BP),A0	;my port's on my base page, easy, quick.
	lea	MP_MSGLIST(A0),A0	;TOP of list
	cmp.l	8(A0),A0		;empty
	beq	end_check		;yep...no messages

check_cancel_loop:
	move.l	(A0),D0			;LN_SUCC(A0), next (this) message
	beq	end_check		;outta here, zero flag set
	move.l	D0,A0			;A0=ptr to intuimessage

	;MAY28
	xref LastM_Window_
	move.l	im_IDCMPWindow(a0),d0
	beq.s	01$		;wha?
	move.l	d0,LastM_Window_(BP)
01$

	move.l	im_Class(A0),D0		;D0=class, ASSUMing intuimsg
	cmp.l	#MOUSEMOVE,D0		;waiting to be recvd?
	beq.s	move_die	;kill m'moves here, since we're "Check4Cancel"
	;cmp.l	#DISKINSERTED,D0
	;beq.s	msg_die			;disk-i's get killed
	cmp.l	#ACTIVEWINDOW,D0	;...as do active window msgs
	beq.s	msg_die
	cmp.l	#MENUVERIFY,D0
	beq.s	menu_stop		;menuverifys get canceled 'in place'

	cmp.l	#MOUSEBUTTONS,D0	;is the message type...
	bne.s	msbut_not
	move.W	im_Code(a0),d0		;keycode=$40=raw code for spacebar?
	cmp.w	#SelectUp,d0	;filter OUT select-UPs
	beq.s	skipthis

  IFC 't','f' ;may14.....left button DOES cancel a PASTE operation
;;  ifc 't','f'	;march19'89
			;dont cancel when SelectDown and 'carrying a brush'
	tst.l	PasteBitMap_Planes_(BP)	;carrying a brush?
	beq.s	nobrushnow
	tst.W	FlagOpen_(BP)
	bne.s	nobrushnow		;but do lookat selectdowns when filereq
	cmp.w	#SelectDown,d0		;filter OUT select-Downs

	bne.s	nobrushnow
	xref FlagRepainting_
	tst.b	FlagRepainting_(BP)
	bne.s	skipthis		;allows "click click click" to paste3x
nobrushnow:
;;  endc
  ENDC
	cmp.w	#MenuUp,d0	;filter OUT menu-UPs, too
	beq.s	skipthis
	;april24;move.l	im_Class(A0),D0		;D0=class, ASSUMing intuimsg (restore)
	bra.s	endme_gotmsg		;will set flag to nonzero with TST.L D0
skipthis:
	move.l	im_Class(A0),D0		;D0=class, ASSUMing intuimsg (restore)

msbut_not:

	cmp.l	#RAWKEY,D0		;waiting to be recvd?
	bne.s	rawkey_not ;check_cancel_loop	;keep checking, 'till end of list
	move.W	im_Code(a0),d0		;keycode=$40=raw code for spacebar?
	cmp.b	#($40!$80),d0	;space bar UP? ($80="up" bit)
	beq.s	endme_gotmsg	;yea...scram out with cancel (not=) code
rawkey_not:

	cmp.l	#CLOSEWINDOW,D0		;from magnify (only)
	beq.s	endme_gotmsg	;yea...scram out with cancel (not=) code

	bra	check_cancel_loop	;keep checking, 'till end of list

menu_stop:
	move.w	#MENUCANCEL,im_Code(A0)	;cancel first verify we see
	;bra.s	end_check
	rts	;dont do 'priority' since if menuverify...alreay window active?
endme_gotmsg:				;A0=msgptr,D0=im_Class.Long
	;tst.l	D0	;return ZERO flag=nomsgs, NOTEQUAL means gottamsg

	;APRIL30...should not need this...
	;	;fixes...'popcli' while repaint (cuz hipri) ...april 26
	;move.l	a0,-(sp)
	;xjsr	ResetPriority	;default 0 if fast, in case rawkey/inactive
	;move.l	(sp)+,a0

	move.l	im_Class(A0),D0		;D0=class, ASSUMing intuimsg (restore)
end_check:		;zero flag =nomsgs, not= means "gotta cancel-type msg"
	rts





Canceler:	;"cancel or continue?" autorequest
	movem.l	d0-d7/a0-a4,-(sp)
	bsr.s	1$
	sne	d0		;sup zero flag for stacking
	ext.w	d0
	ext.l	d0		;=0 or =-1  ...8-)
;may22;	move.l	d0,-(sp)
;may22;	xjsr	ResetIDCMP
;may22;	move.l	(sp)+,d0	;set/clr zero flag

	;reinstated JULY04...allows multiple cancel/continue setups
	move.l	d0,-(sp)
	xjsr	ResetIDCMP
	move.l	(sp)+,d0	;set/clr zero flag


	movem.l	(sp)+,d0-d7/a0-a4
	rts
1$

	movem.l	d1-d7/A0-a6,-(sp)
	xjsr	ReturnMessage	;return cancel msg, menuverify, space, etc

	lea	FilenameBuffer_(BP),A0	;window title
	suba.l	a1,a1			;no message line in autorequester
	lea	CAN_Pos_String(pc),a2	;"continue?"
	lea	CAN_Neg_String(pc),a3	;"cancel?"
	bra	do_requester

DirNotFoundRtn:
	movem.l	d1-d7/A0-a6,-(sp)
	lea	DirnameBuffer_(BP),A0	;window title
	lea	DNF_String(pc),a1	;"dir not found"
	bra	std_onebutton

OperFailedRtn:			
	movem.l	d1-d7/A0-a6,-(sp)		
	lea	FilenameBuffer_(BP),A0	;window title
	;lea	OF_String_(BP),a1	;load/save failed string	
	lea	LS_String_(BP),a1	;load/save failed string	
	bra	std_onebutton

FontErrorRtn:
	movem.l	d1-d7/A0-a6,-(sp)

	lea	FontNameBuffer_(BP),a1
	move.l	a1,a2
	xjsr	copy_string_a1_to_a2	;build 'ruby',0  JUST MOVE A2 to end
	move.b	#' ',-1(a2)		;      'ruby '
	lea	FilenameBuffer_(BP),a1	;      'ruby 8',0
	xjsr	copy_string_a1_to_a2	;(null terminates, leaves a2+)


	lea	FontNameBuffer_(BP),A0	;window title
	lea	FontNF_String(pc),a1	;"font error?"
	bra	std_onebutton

PicFileErrorRtn:
	movem.l	d1-d7/A0-a6,-(sp)
	lea	FilenameBuffer_(BP),a0
	lea	PicFile_String(pc),a1	;"file not font"
	bra	std_onebutton

FontFileErrorRtn:
	movem.l	d1-d7/A0-a6,-(sp)
	lea	FilenameBuffer_(BP),a0
	lea	FontFile_String(pc),a1	;"file not font"
	bra	std_onebutton

FontTallErrorRtn:
	movem.l	d1-d7/A0-a6,-(sp)
	lea	FilenameBuffer_(BP),a0
	lea	FontTall_String(pc),a1	;"font too tall."
	bra	std_onebutton

;june20;	xdef FontInUseErrorRtn	;MAY30
;june20;FontInUseErrorRtn:
;june20;	movem.l	d1-d7/A0-a6,-(sp)
;june20;	;lea	FilenameBuffer_(BP),a0
;june20;	lea	FontNameBuffer_(BP),A0	;window title
;june20;	lea	FontInUse_String(pc),a1	;"old font still in use."
;june20;	bra	std_onebutton

PrinterErrRtn:
	movem.l	d1-d7/A0-a6,-(sp)
	;lea	PrintErr_String(pc),a0	;"printer"
	;lea	PrintErr2_String(pc),a1	;"Cannot open printer.device"
	;WORKBENCH 2.0, DECEMBER 1990
	lea	PrintErr2_String(pc),a0	;"Cannot open printer.device"
	suba.l	a1,a1

	bra	std_onebutton

;RotTallErrorRtn:
;	movem.l	d1-d7/A0-a6,-(sp)
;	lea	Rotate_String(pc),a0	;"Rotate"
;	lea	RotTall_String(pc),a1	;"Result too tall."
;	bra.s	std_onebutton


ScreenFormatRtn:
	tst.b	Initializing_(BP)	;are we just starting?
	beq.s	1$	;rts_label	;no...continue
	;;;moveq	#0,d0			;yes, init'g, sup zero return flag tho
	rts				;..iffload->openbigpic->ok sizes?
1$
	movem.l	d1-d7/A0-a6,-(sp)	

	xjsr	FileSizeStringer	;showtxt.o, returns a0=string name+size
	lea	SF_String(pc),a1	;' change scr format?
	lea	SF_Pos_String(pc),a2	;' yes - ok '
	lea	SF_Neg_String(pc),a3	;' no - keep same',0

	bra	do_requester

AskDelSwapRtn:
	tst.b	Initializing_(BP)	;are we just starting?
	beq.s	1$	;rts_label	;no...continue
	;;;moveq	#0,d0			;yes, init'g, sup zero return flag tho
	rts				;..iffload->openbigpic->ok sizes?
1$
	movem.l	d1-d7/A0-a6,-(sp)	

	xjsr	FileSizeStringer	;showtxt.o, returns a0=string name+size
	lea	SD_String(pc),a1	;'delete swap?'
	lea	SD_Pos_String(pc),a2	;' yes - ok continue size chg'
	lea	SD_Neg_String(pc),a3	;' no - cancel size change'

	bra	do_requester

ReallyQuitRtn:
	movem.l	d1-d7/A0-a6,-(sp)	

	;xjsr	FileSizeStringer	;showtxt.o, returns a0=string name+size
	lea	Qu_String(pc),a1		;' change scr format?
	lea	Qu_Pos_String(pc),a2	;' yes '
	lea	Qu_Neg_String(pc),a3	;' no ',0

	bra	do_requester


ScreenTooBigRtn:
	tst.b	Initializing_(BP)	;are we just starting?
	beq.s	1$	;rts_label	;no...continue
	moveq	#0,d0			;yes, init'g, sup zero return flag tho
	rts				;..iffload->openbigpic->ok sizes?
1$
	movem.l	d1-d7/A0-a6,-(sp)	

	xjsr	FileSizeStringer	;showtxt.o, returns a0=string name+size

	lea	FilenameBuffer_(BP),A0	;window title
	lea	STB_String(pc),a1	;no enuff memory
	bra	std_onebutton

FileNotFoundRtn:
	tst.b	Initializing_(BP)	;are we just starting?
	bne	rts_label		;yes...get outta here...no "file not fnd"
	movem.l	d1-d7/A0-a6,-(sp)
	lea	FilenameBuffer_(BP),A0	;window title
	lea	FNF_String(pc),a1	;"file not found"
std_onebutton:
	suba.l	a2,a2			;no "positive" button
	lea	OK_String(pc),a3	;"ok"

do_requester:

	move.l	GWindowPtr_(BP),a4
	move.l	a0,wd_Title(a4)
	move.l	a4,a0	;a0=window, a1,a2,a3 set to text,postext,negtext

	cmp.l	#0,a1
	;FEB91;beq.s	nomaintext
	bne.s	havemaintext
	lea	DumbNullString(pc),a1
havemaintext:


	move.l	a1,StringPtr	;store "ptrs to ascii" in intuitext structs
	lea CAN_IntuiText(pc),a1
	move.w	#13,4(a1)	;it_LeftEdge put "no button text" on left
	cmp.l	#0,a2		;leftside button too?
	beq.s	nomaintext
	move.w	#114+(10*8),4(a1) ;it_LeftEdge when 2 buttons + text

nomaintext
	cmp.l	#0,a2
	beq.s	nopostext
	move.l	a2,Pos_StringPtr
	lea	Pos_IntuiText(pc),a2
nopostext:
	cmp.l	#0,a3
	beq.s	nonegtext
	move.l	a3,Neg_StringPtr
	lea	Neg_IntuiText(pc),a3
nonegtext:

	xjsr	CustomRequest

	movem.l	(sp)+,d1-d7/A0-a6
rts_label:
	rts

DumbNullString: dc.b ' ',0 ;FEB91

	cnop 0,4	;long word align
CAN_IntuiText:	EQU *
	dc.b	MyFrontPen	;Front Pen shade = item number
	dc.b	MyBackPen	;Back Pen shade
	dc.b	1	;JAM2	;Drawmode
	dc.b	0	;system junk
	dc.w	5	;left edge
	dc.w	7+1	;top edge
	dc.l	0	;APTR  textfont
StringPtr dc.l	0	;CAN_String
	dc.l	0	;APTR NextText

Pos_IntuiText:	 EQU *
	dc.b	MyFrontPen	;Front Pen shade = item number
	dc.b	MyBackPen	;Back Pen shade
	dc.b	1	;JAM2	;Drawmode
	dc.b	0	;system junk
	dc.w	5	;left edge
	dc.w	3	;top edge
	dc.l	0	;APTR  textfont
Pos_StringPtr dc.l	CAN_Pos_String
	dc.l	0	;APTR NextText

Neg_IntuiText:	 EQU *
	dc.b	MyFrontPen	;Front Pen shade = item number
	dc.b	MyBackPen	;Back Pen shade
	dc.b	1	;JAM2	;Drawmode
	dc.b	0	;system junk
	dc.w	5	;left edge
	dc.w	3	;top edge
	dc.l	0	;APTR  textfont
Neg_StringPtr dc.l	CAN_Neg_String
	dc.l	0	;APTR NextText

;july06;DNF_String:	dc.b	' Dir not found. ',0
DNF_String:	dc.b	' Dir not found. (Disk in drive?)',0
FNF_String:	dc.b	' File not found.',0
;may07;FontNF_String:	dc.b	'  Font error?   ',0
FontNF_String:	dc.b	' Font (no memory?) error. ',0
FontFile_String: dc.b	' File not font. ',0
PicFile_String: dc.b	' File not picture. ',0
FontTall_String: dc.b	' Font too tall. ',0
;june20;FontInUse_String: dc.b	' Font still in use. ',0	;MAY30
;DECEMBER1990;PrintErr_String	dc.b	'Printer',0
PrintErr2_String dc.b	'Cannot open printer.device',0
;Rotate_String:	dc.b	' Rotate',0
;RotTall_String:	dc.b	' Result too tall. ',0
OK_String:	dc.b	'                 OK               ',0
CAN_Pos_String: dc.b	'             Cancel           ',0
CAN_Neg_String: dc.b	'            Continue          ',0
;SF_String:	dc.b	'    Change picture size?   ',0
SF_String:	dc.b	'    Change screen size?    ',0 ;per robert b
SF_Pos_String:	dc.b	'  OK, use NEW size.  ',0
SF_Neg_String:	dc.b	'  NO, keep SAME size. ',0
SD_String:	dc.b	'     Delete swap screen? ',0
SD_Pos_String:	dc.b	' OK, do size change. ',0
SD_Neg_String:	dc.b	' CANCEL size change. ',0

Qu_String:	dc.b	'           Quit?           ',0
Qu_Pos_String:	dc.b	'           Quit.           ',0
Qu_Neg_String: dc.b	'            Continue          ',0

STB_String:	dc.b	' Not enough (chip?) memory. ',0


  END
