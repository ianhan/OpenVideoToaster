*** DigiPaint 3.0 *** main.asm module
*** This program was written by Jamie Purdon (Cleveland, Ohio) for
*** NewTek (Topeka, Kansas) to market as an upgrade to DigiPaint.
*** This program's (this section and all modules on disk) code (ALL forms) is
***	Copyright © 1989  by  Jamie D. Purdon  (Cleveland, Ohio)
*** Versions delivered to NewTek and mass marketted are ALSO
***	Copyright © 1989  by  NewTek  (Topeka, Kansas)

	include "ram:mod.i"

NOTICE:	dc.b $0a,0,0,0 ;just lf ;$0d	;just lf,cr
NOTICELen	equ *-NOTICE


;;DEBUGGER 	set	1

 ifd paint2000
SERDEBUG	equ	1
 endc
 ifnd paint2000
SERDEBUG	equ	1
 endc

;;SaveTheBitMap	EQU	1

_LVOLoadRGB32		EQU	-882
HIPRI	set 2 ;1=workbench 2=better/best?
MINHT	set 20	;minimum picture ht

MAXWT	set 736	;768 ;MAR91 was 736 ;JULY051990;was 378
MAXHT	set 480

;MAXTICKTIME	set 60+20	;1.333 seconds
MAXTICKTIME	set 30		;.5 seconds

	xdef _main		;startup.o 'jsr's here
	xdef AutoMove		;moves the bigpicture based on mouse
	xdef CheckIDCMP		;returns zero//NULL if no mesg
	xdef CloseBigPic
	xdef CloseScreenRoutine
	xdef CloseWindowRoutine
	xdef CloseWindowAndScreen
	xdef cva2i ;a0=string, returns d0=#, a0 just past # (DESTROYS D1)
	xdef DoAction		;arg d0=action code
	xdef DoInlineAction	;arg longword inline before caller's rts
	xdef EndIDCMP	;turn off messages (only, don't close window etc)
	xdef ExecSetTaskPri	;argD0=new priority, returns d0=old pri BLOWS A0
	xdef FixInterLace	;iffload, after automove call, gadgetrtns//undo
	xdef KeyRoutine		;only called by 'CANCEL-CHECK-GLUE' code
	xdef key_rtn_dn
	xdef key_rtn_lt
	xdef key_rtn_rt
	xdef key_rtn_up
	xdef skey_rtn_dn
	xdef skey_rtn_lt
	xdef skey_rtn_rt
	xdef skey_rtn_up
	xdef OpenBigPic		;alloc's chip, opens 'bigpicture' screen
	xdef ResetIDCMP		;sets up normal idcmp message events
	xdef ReturnMessage	;EVERYONE goes thru HERE for idcmp "ReplyMsg"s
	xdef ScanIDCMP	;d1=i'class to look for, returns ZERO found, notequal for notfnd
	xdef ResetPriority
	xdef ForceDefaultPriority	;mousertns...force 'foregrnd'
	;xdef SetDefaultPriority	;setsit to zero, if not background
	xdef SetHigherPriority	;generally quicker, for long stuff (noone?)
	xdef SetLowerPriority	;checkcancel, canceler.o, uses this
*
	xref PalGadAct_
*	xref _custom	
	xref FlagCapture_
	xref FlagCtrlText_
	xref FlagPale_
	xref FlagCtrl_
	xref FlagCheckKillMag_
	xref FlagGadgetDown_
	xref FlagMagnify_
	xref FlagMagnifyStart_
	xref FlagMenu_		;set when intuit' has a menu, clr otherwise
	xref FlagNeedHiresAct_
	xref GWindowPtr_	;gadgets window
	xref LastItemAddress_	;dirrtns use for filename str's
	xref MWindowPtr_	;magnify /paint/ window
	xref MCBWindowPtr_	;magnify windowclose gadget // window
	xref PrintCopies_	;#copies left to print (if any)
	xref FlagLRpaint_
*
	xref GWindowPtr_	;gadgets window on HIRES screen
	xref MScreenPtr_	;magnify screen
	xref MWindowPtr_	;magnify window (blown up pic) on mag scr
	xref XTScreenPtr_
	xref ToolWindowPtr_	;ham palette
	xref TScreenPtr_	;tool screen 
	xref ScreenPtr_		;big picture's screen
	xref WindowPtr_		;big picture's
	xref ToolWindowPtr_	;gadgets window on ham tool screen
	xref SBMPlane1_
	xref ToolBitMap_
	xref ScreenBitMap_
	xref ScreenBitMap_Planes_
	xref BB_BitMap_
	xref BigNewScreen_
	xref SCREENTAGS_
	xref BigNewWindow_
	xref BigPicHt_
	xref BigPicWt_
	xref BigPicWt_W_
	xref bmhd_pageheight_
	xref bmhd_pagewidth_
	xref bmhd_rastheight_
	xref bmhd_rastwidth_
	xref bmhd_xaspect_
	xref bmhd_yaspect_
	xref bytes_per_row_
	xref bytes_row_less1_
	xref CAMG_
	xref CPUnDoBitMap_
	xref SwapBitMap_
	xref PasteBitMap_
	xref PasteMaskBitMap_
	xref UnDoBitMap_
	xref UnDoBitMap_Planes_
	xref UnDoRGB_
	xref FlagCopyColor_
*
	xref FlagRexxReq_
	xref PointerTo_data	;relocatable, yecht!
	xref ACTable		;gadgetrtns.o
	xref Paint8red_		;june301990
	xref Paint8green_	;june301990
	xref Paint8blue_	;june301990
	xref Datared_		;june301990
	xref UnDored_
*
	xref BigPicRGB_		  	;"regular" bitmap struct for rgb data
	xref CurrentFrameNbr_
	xref FlagKeep24_		;don't delete 24 bit buffers from toaster/switcher
	xref FlagQuitSuper_
	xref FlagToasterAlive_
	xref FlagWholeHam_
	xref ToasterMsgPtr_		;hang onto select message, return when done
	xref ToasterCMD_		;"FGC_Commnd..."
	xref ToasterErrorCount_
*
	xref IntServer_
	xref Ticker_
	xref ActionCode_
	xref DirNameLen_	;var. program name, 1st part is dirname
	xref dosCmdLen_		;scratch.o 2 longwords for len, adr
	xref FileHandle_
	xref FilenameBuffer_
	xref FirstScreen_
	xref FlagBitMapSaved_	;automove uses this to see if go slow
	xref FlagCutPaste_
	xref FlagDisplayBeep_
	xref FlagFrbx_
	xref FlagLace_
	xref FlagLaceNEW_
	xref FlagMagnifyStart_
	xref FlagNeedIntFix_	;interlace fixzit, handled by msg code
	xref FlagNeedMagnify_
	xref FlagNeedMakeScr_
	xref FlagNeedShowPaste_	;need 'new' brush display
	xref FlagNeedRepaint_
	xref FlagNeedText_	;if scrollvport get called, redisplay coords
	xref FlagNeedGadRef_	;need gadget refresh?
	xref FlagOpen_
	xref FlagPick_
	xref FlagQuit_
	xref FlagRedrawPal_	;used by/for openhamtools
	xref FlagRefHam_
	xref FlagRepainting_
	xref FlagSingleBit_	;indicates 'single bitplane undo' of cutpaste
	xref FlagSizer_
	xref Initializing_	;(103*$01000000) ;error103,nomemory ;0=no,-1=yes
	;2.0;xref lwords_row_less1_
	xref MsgPtr_
	xref NewSizeX_
	xref NewSizeY_
	xref NormalWidth_
	xref NormalHeight_
	xref OnlyPort_		;this is a STRUCT on the basepage
	xref OSKillNest_	;main.o;nest/unnest kill en/disable overscan
	xref our_task_
	xref pixels_row_less1_
	xref PlaneSize_		;number of bytes in a bitplane (8000 or 16000)
	xref ProgNameLen_	;word size
	xref ProgNamePtr_	;ptr to ascii, now (SCANNABLE FOR DIR)
	xref ProgramNameBuffer_	;<=60 bytes filled in by main.cmd.i (@ end)
	xref RastPortPtr_	;RastPort for this window
	xref RememberKey_
	xref saveexecwindow_	;JULY07
	xref startup_taskpri_
	xref TextAttr_
	xref Where_We_Came_From_
	;xref WindowIDCMP_
	xref words_row_less1_
	xref XAspect_
	xref Zeros_
	xref _WBenchArgName_
	xref FlagAlphapaint_
	xref FlagToastCopList_

	xref RexxResult_

	xref InpStdIO_
	xref InpDevPtr_
	
	xref MSG_MouseX_
	xref MSG_MouseY_
	

	include	"ps:serialdebug.i"
	include	"assembler.i"
	include	"ps:model.i"
	include "ps:basestuff.i"
;;	include "lotsa-includes.i"	
	include "intuition/intuition.i"
	include "intuition/intuitionbase.i"	;firstscreen field
	include	"exec/types.i"
	include "exec/memory.i" 		;needed for AllocMem requirements
	include "exec/ports.i"
	include "devices/input.i"
	include "libraries/dosextens.i" 	;for pr_{Process} structure
	include "graphics/gfxbase.i"
	include	"ps:minimalrex.i"
	include "xwork:include/exec/interrupts.i"
	include "xwork:include/hardware/intbits.i"
	include "xwork:include/hardware/custom.i"
	include	"ps:iff.i"
;	include	"ps:rexx/rxslib.i"			;ARexx



;	;INCLUDE "EXEC/LISTS.I"			;for paintinstinct.i
; STRUCTURE	MLH,0
;	APTR	MLH_HEAD
;	APTR	MLH_TAIL
;	APTR	MLH_TAILPRED
;	LABEL	MLH_SIZE
;
;	INCLUDE "PS:INSTINCT.I"	;TOASTER INCLUDE
;TOASTGLUE.asm...LateMay1990....is only "instinct" reference....


GWIDCMP   set MENUVERIFY!MENUPICK!MOUSEMOVE!GADGETDOWN!GADGETUP!RAWKEY
GWIDCMP	set GWIDCMP!MOUSEBUTTONS	;to handle 'brush sizer'

;;DEH030994 CHANGED TO WATCH FOR MOUSE UP AND DOWN MSGS
TOOLIDCMP set MOUSEBUTTONS!MOUSEMOVE!GADGETUP!GADGETDOWN

BPIDCMP   set MOUSEBUTTONS!MOUSEMOVE!RAWKEY	;ACTIVEWINDOW
	;note: see main.key.i for...
	;bigpic rawkeys only good when in 'special' modes, line,rect,etc

	;note: want(?) 'rawkeys' on hamtools so can 'close toolbox' for picking

*
;port=INITPORTE(),exec
;D0		   A6	;<<== returns	;z=error
INITPORTE:	MACRO
		moveq	#-1,D0
		CALLIB	Exec,AllocSignal  ;D0=return'd signal NUMBER
		tst.l	D0	;-1 indicates bad signal (neg/minus)
		bpl.s	cp_sigok
cp_nomemory:	moveq	#0,D0
		bra.s	end_initp		rts
cp_sigok:	move.b	D0,MP_SIGBIT(a2)
		move.b	#PA_SIGNAL,MP_FLAGS(a2)
		;move.b	#PA_IGNORE,MP_FLAGS(a2)	;dont take time to signal
		move.b	#NT_MSGPORT,LN_TYPE(a2)
		clr.b	LN_PRI(a2)	;port struct = lnode+portstuff+mlist
		move.l	our_task_(BP),MP_SIGTASK(a2) ;our_task setup in startup
		lea	MP_MSGLIST(a2),A0  ;Point to list header
		NEWLIST	A0		;Init new list macro
		move.l	a2,D0		;ensure non-zero return flag
end_initp:
	ENDM	;	rts


 xref StdOut_
PRTMSG:	MACRO ;areg-ptr-to-message,#len-of-msg
	move.l	\1,-(sp)	;adr of name
	CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	(sp)+,d2	;d2=original string arg
	move.l	D0,StdOut_(BP)
	move.l	D0,-(sp)	;save 'stdout' file handle
	beq.s	nofileh\@	;noprint if no stdout (run from wbench?)
	move.l	D0,d1		;d1=output file handle
	moveq.l	#\2,d3		;d2=length of string
	CALLIB	SAME,Write	;>>>print it
	move.l	(sp),d1		;d1=output file handle
	lea	NOTICE(pc),a2
	move.l	a2,d2		;d2='cr,lf,...'
	moveq.l	#1,d3	;#NOTICELen,d3	;d3=length of 'cr,lf...'
	CALLIB	SAME,Write	;>>>print it
nofileh\@:
	lea	4(sp),sp
	ENDM

;**** CODE START ****;
	cnop 0,4	;longword align so no-one comp-lains

;FlagToasterAlive is valid
;ToasterMsgPtr is null or valid
;if toastmsgptr <> 0, then message is valid
;we could have a SELECT or an UNLOAD pending...
StartQuitting:

	xjsr	SafeEndFonts		;textstuff.o...might clear quit flag
;	tst.b 	FlagQuit_(BP)		;start quitting AFTER msg queue empties
	bne	EventLoop		;restart if subr SafeEndFonts "not ok"

	bsr	EndIDCMP		;stop intui-msgs NOW
	bsr	SetDefaultPriority	;close @ "normal" speed
;	xjsr	CloseSkinny		;window, if any, for rgb # display
	xjsr	EndMagnify		;DOmagnify.o
	xjsr	RemoveXGadgets		;so cant gadget click while printer wait

	xjsr	Close_Load_File		;cancel fileSAVE iif/when quitting

Abort:
	xjsr	AbortPrint		;printrtns.o
	xjsr	EndPrint
	xjsr	EndPrintGads		;AUG221990....calls Free12bitprint
	xjsr	ForceToastCopper	;ToastGlue.asm...kill display ASAP...24JAN92
	bsr	CloseBigPic

;toaster/switcher restart....clear these too
	clr.L	LastM_Window_(BP)
	clr.L	FirstScreen_(BP)

	xjsr	FreePaste	;brush		;memories.o
	xjsr	FreeAltPaste	;swap brush	;memories.o
	xjsr	FreeUnDo		;get ridda the 'old' one

	cmp.l	#1,ToasterCMD_(BP)	;=#1=unload
	beq.s	free_allatonce		;july121990

	xjsr	FreeFillTbl	;mousertns.asm, 'table of colors' for flood fill, AUG301990
	xjsr	FreeSwap	;swap scr	;memories.o

;flag all lines as "to be rendered" AUG301990 unload, de-select, whatever...
	xref	SolLineTable_
	lea	SolLineTable_(BP),a0
	bsr	FreeOneVariable		;resets so "all lines are replotted" in composite

	;might want to save RGB buffers in-between runs...
	;xjsr	FreeRGB		;big picture	;rgbrtns
	;NOTE: need to "Freergb" because it could've come from ToasterChip...
	;NEWER NOTE: "allocrgb" forces "not from toaster chip"

	xref 	FlagKeep24_		;don't delete 24 bit buffers from toaster/switcher
	tst.b 	FlagKeep24_(BP)		;don't delete 24 bit buffers from toaster/switcher
	bne.s	24$
*
	xjsr	FreeRGB			;big picture	;rgbrtns
*
	xjsr	FreeUnDoRGB		;undo		;rgbrtns (hang onto undo, too)

24$	

free_allatonce:
	xjsr	FreeBUPImagery		;free chip used by BUP 2way slider imagery AUG301990
	xjsr	FreeTwoXImagery		;AUG301990
	xjsr	EndMenu			;gadgetrtns.o
	xjsr	CloseConsoleBase	;printrtns.o
	xjsr	DeleteDirsaveLock	;dirrtns.o;delete "parent"/old lock
	xjsr	DeleteNotFontDir	;dirrtns.o, digipaint pi
	xjsr	CleanupDirRemember	;dirtns.o, clear saved "dir" fib's
	xjsr	CleanupDiskObject	;iconstuff.o

Abort_nomem:
	xjsr	GoodByeHamTool		;ham palette
	tst.b	FlagToasterAlive_(BP)
	bne.s	nowbtoast
	CALLIB	Intuition,OpenWorkBench	;open it BEFORE closing all scrs
	xjsr	FreeUnDoRGB		;MAR91
	xjsr	FreeRGB			;MAR91

nowbtoast:
	xjsr	GoodByeToolWindows	;tool.o close hires and ham palette


;FORCE 'free-all/FreeRemember upon unload'
	tst.b	FlagToasterAlive_(BP)	;no toaster msg?...
	beq.s	freenotoast		;...free all, bye bye.
	cmp.l	#1,ToasterCMD_(BP)	;=#1=unload = last command msg?
	bne.s	dontfreeeverything
freenotoast:

;close default fonts (AFTER windows/screens closed)
	xjsr	CloseDefaultFont	;defaultfont.asm...JULY221990
	xjsr	FreeAllMemory		;memories.o, frees RememberKey list		;KLUGE OUT 103194DE ***!!!
*
	move.l	our_task_(BP),A0
	move.l	saveexecwindow_(BP),pr_WindowPtr(A0)	;MAY1990

dontfreeeverything:
	bsr	OffInt			;remove interrupt server
	tst.b	FlagToasterAlive_(BP) 	;no toaster msg?...
	beq.s	abort_toaster		;no toaster/switcher...no cmd
	cmp.l	#1,ToasterCMD_(BP)	;=#1=unload
	bne	waitonswitcher		;startup.asm does the toaster-replymsg

abort_toaster:
;default....
	move.l	startup_taskpri_(BP),D0
	bsr	ExecSetTaskPri

	bsr	CloseInputDev		;close the imput device.

	lea	OnlyPort_(BP),a1
	CALLIB	Exec,RemPort		;remove our 'only' message port
	lea	OnlyPort_(BP),a1

	moveq	#0,D0
	move.b	MP_SIGBIT(a1),D0
	CALLIB	SAME,FreeSignal		;a6=execbase


abort_portdone:
  IFD DEBUGGER
	xjsr	CloseDebug		;july081990
  ENDC

	move.l	Where_We_Came_From_(BP),a7	;fix stack back to entry point
	moveq	#0,d0			;SEP101990
	move.b  Initializing_(BP),D0	;system error code return (103nomem)
	rts				;for good.(whew!).(return to startup.)

ForcedPortName:	
	dc.b 'DigiPaint',0
	dcb.b 32-9,0			;use 32 as max port name len, if file-zapping
	cnop 0,2			;ensure that code is word-aligned

ForcedProgName:	
	dc.b 'ToasterPaint',0		;AUG141990
	dcb.b 32-12,0			;use 32 as max port name len, if file-zapping
	cnop 0,2			;ensure that code is word-aligned


*****************************************************************
*								*								*
*	_main							*
*								*
*****************************************************************
_main:	
	DUMPREG	<_main>
	move.l	a7,Where_We_Came_From_(BP)	;save our stack
	bsr	SetDefaultPriority	;main.o;returns old pri in D0 BLOWS A0/D0
	move.l	D0,startup_taskpri_(BP) ;restore original pri when done
	bsr	ExecSetTaskPri		;restore original pri "now", too
	move.b	#103,Initializing_(BP)	;error103,nomemory
	xjsr	InitScratch		;scratch.o

	lea	OnlyPort_(BP),a2
	INITPORTE			;sets A6:=execbase, gets signal, inits portA2
	beq	abort_portdone		;go and exit no port!
	lea	(a2),a1			;port (again, for adding)
	lea	ForcedPortName(pc),a0	;force PORT name 2b 'DigiPaint'
	move.l	A0,LN_NAME(a1)		;broadcast our port name now...
	CALLIB	SAME,AddPort		;"hey system, *here* I am!"

*	DUMPREG	<OpenInputDev>
	bsr	OpenInputDev

;FORCE setup only upon "load" or no-toaster
	move.l	ToasterMsgPtr_(BP),d0	;nasty, toaster msg there yet?
	beq.s	domaincmd		;toaster's not there, no message
	;move.l	d0,a0
	;move.l	MN_SIZE(a0),d0		;FBC_command...0=load, 1=unload, 2=select
	move.l	ToasterCMD_(BP),d0
	cmp.l	#1,d0			;=#1=unload?
	bne	nomaincmd		;setup only done once...?

domaincmd:
	DUMPREG	<domaincmd>
; process the (cli) command line:
; {dir:/}programname {-t}{-i}{-w h}{picturename}
; -t=trace -i=interlace w=x=widht h=y=height picturename=filename
; GRABs NORMAL INTERLACE VALUES for screen width/ht
	xref NormalWidth_	;workbench size, adjust for non-intlace lores
	xref NormalHeight_
	xref FlagWBench_
*
;force specific screen startup w/toaster-switcher
	tst.b	FlagToasterAlive_(BP)				
	beq.s	nottoaststart						
	move.w	#320,d3
	move.w	#200,d4			;actual ham screen width/ht
	DUMPMSG	<Not-nottoasterstart>
	bra.s	normnonlace		;.keys file get bitmap wt/ht ;;this way.
*
nottoaststart:
	DUMPMSG	<nottoaststart>
	move.l	GraphicsLibrary_(BP),a0
	move.w	gb_NormalDisplayColumns(a0),d3
	bne.s	col_ok			;boom boom proof pruf.
	move.w	#320,d3
col_ok:	cmp.w	#640,d3			;hm....hiRES?
	bcs.s	not_hr			;couldbe overscan, tho
	asr.w	#1,d3			;/2='lores'
*
not_hr:	move.w	gb_NormalDisplayRows(a0),d4
	;BRA.s	normnonlace		;july071990 real kludge, but ok for rgb now
*
	bne.s	row_ok			;boom boom proof pruf.
	move.w	#200,d4
row_ok:	cmpi.w	#400,d4
	bcs.s	normnonlace
	asr.w	#1,d4			;/2 for non interlace ht
*
normnonlace:
	DUMPMSG	<normnonlace>
	move.w	d3,NormalWidth_(BP)	;not longword corrected!
	move.w	d4,NormalHeight_(BP)	;not even# corrected!
*
	move.w	d3,bmhd_pagewidth_(BP)	;DEFAULTS FOR 'NEWSCREEN'
	move.w	d4,bmhd_pageheight_(BP)
*
	move.w	d3,NewSizeX_(BP)	;DEFAULTS FOR 'NEWSCREEN'
	move.w	d4,NewSizeY_(BP)
*
;parse dirname, program, -i, interp #s width, height, grab filename
	movem.l dosCmdLen_(BP),d0/a0 	;dosCmdBuf;original registers at startup
	tst.l	d0
	beq	do_wb_cmd		;br here! with switcher.
*
	movem.l	d0/a0,-(sp)		;name,len
	move.l	our_task_(BP),a1	;------ find command name:
	move.l  pr_CLI(a1),d0		;=bcpl ptr to a 'cli struct'
	add.l	d0,d0
	add.l	d0,d0			;bcpl pointer conversion
	move.l	d0,a0
	move.l	cli_CommandName(a0),d0	;'bstr'
	add.l	d0,d0	
	add.l	d0,d0			;bcpl pointer conversion
	move.l	d0,a0			;a0=ptr to LEN.b + command line
	moveq	#0,d0
	move.B	(a0)+,d0		;bstr's begin with length.B
	move.W	d0,ProgNameLen_(BP)	;fetched a byte, but our var is a word
	move.L	a0,ProgNamePtr_(BP)	;ptr to ascii, now (SCANNABLE FOR DIR)
	bsr	calcdirnamelen
	movem.l	(sp)+,d0/a0		;name,len
*
;look for '-i' (alone or with filename) option first
	cmpi.b	#2,d0			;cmdlen long enuff to specify the '-i' option?
	bcs.s	9$ ;no_interlace	;nope...not nuff letters typed
	cmpi.b	#'-',(a0)		;did they specify this option (first)?
	bne.s	9$ ;no_interlace	;no H&W NUMBERS EITHER		
	cmp.b	#'i',1(a0)		;2nd ascii data
	bne.s	notcmdi
	st	FlagLaceNEW_(BP)
	move.w	NewSizeY_(BP),d4 	;no special need for d4, what else avail?
	add.w	d4,d4
	move.w	d4,NewSizeY_(BP) 	;dbl'd for interlace
	move.w	bmhd_pageheight_(BP),d4	;no special need for d4, what else avail?
	add.w	d4,d4
	move.w	d4,bmhd_pageheight_(BP)	;dbl'd for interlace

	lea	2(a0),a0		;bump cmdline string ptr past '-i'
	subq	#2,d0			;adjust len, also
9$	movem.l d0/a0,dosCmdLen_(BP) 	;dosCmdBuf;original registers at startup
	bra	AFTER_cmdline		;a0=cmdline string ptr for filename, d0=len

calcdirnamelen:
	move.w	d0,d1			;prognamelen
	subq	#1,d1			;backup 1
clrdirname:
	move.b	0(a0,d1.w),d0		;character (go backwards) D1 is backptr offset
	cmp.b	#'/',d0
	beq.s	gotdirname	
	cmp.b	#':',d0
	beq.s	gotdirname
	dbf	d1,clrdirname		;d1 loop counter
	move.W	#-1,d1			;d1=-1	
gotdirname:
	addq.W	#1,d1
	move.W	d1,DirNameLen_(BP)	;*only* if from cli
	rts	;calcdirnamelen

notcmdi:	;'-' was first, but not '-i', get width,ht
	move.l	d0,-(sp) 	;STACK	;cmd line len
	move.l	a0,-(sp) 	;STACK	;a0 point @ 1st "-" (did find "-")
	lea	1(a0),a0	;bump past '-'
	bsr	cva2i		;convert ascii (a0) to integer (d0)
	tst.L	d0
	bmi.s	13$		;invalid 1st number, bummer, skip h AND w, too
	beq.s	13$		;same thing, 0 is an invalid - sick in bed.
	move.l	d0,d3		;WIDTH from command line - iszat whatchew said?
	bsr	cva2i
	tst.L	d0
	bmi.s	13$
	beq.s	13$
	move.l	d0,d4		;HEIGHT from command line

13$	move.l	a0,d0		;cmd line ADR (yea yea i know adr ina d-reg)
	sub.l	(sp)+,d0 	;deSTACK ;old cmd line adr (how much to subtract)
	neg.l	d0
	add.l	(sp)+,d0 	;deSTACK ;calc//adjust cmdline len (a0 already adjusted)
	bpl.s	17$
	moveq	#0,d0		;no mo' command line, all eaten up, yum.
17$				;look for '-' (after h,w digits)
	cmpi.b	#2,d0		;cmdlen long enuff to specify the '-i' option?
	bcs.s	19$		;ecmdl	;nope...not nuff letters typed
	move.b	(a0),d1		;1st ascii data
	cmpi.b	#'-',d1		;did they specify this option (first)?
	bne.s	19$		;ecmdl	;no_interlace	;no H&W NUMBERS EITHER		
	move.b	1(a0),d1	;2nd ascii data
	cmpi.b	#'i',d1		
	bne.s	19$		;ecmdl	;end with no interlace set
	st	FlagLaceNEW_(BP)
	lea	2(a0),a0	;bump cmd line ascii ptr, pos after '-i'
	subq	#2,d0		;len-2, '-i' offset len, too.
;ecmdl:	;used command line (call Al @ 555-1212 for better deal on used cmds)

	st	FlagLaceNEW_(BP)
	lea	2(a0),a0	;bump cmd line ascii ptr, pos after '-i'
	subq	#2,d0		;len-2, '-i' offset len, too.
19$	movem.l d0/a0,dosCmdLen_(BP) ;dosCmdBuf;original registers at startup
	lea	BigNewScreen_(BP),a2

	move.w	d3,NewSizeX_(BP) 	;actual (biggern'screen?) pic size
	move.w	d4,NewSizeY_(BP) 	;eventual 'BigPicHt' var

	cmp.w	bmhd_pagewidth_(BP),d3	;'just did' width vs. default
	bcc.s	defwt			;already set page is smaller, use it
	move.w	d3,bmhd_pagewidth_(BP)	;smaller wt than default
defwt:	cmp.w	bmhd_pageheight_(BP),d4
	bcc.s	defht
	move.w	d4,bmhd_pageheight_(BP)	;smaller ht than default
defht:

	bra	AFTER_cmdline

do_wb_cmd:

	st	FlagWBench_(BP)		;global, used by 'default.o'
*
;	movem.l	d0-d3/a0/a1/a6,-(sp)	Why?DEH5-25-94
;	xjsr	TestSetLace		;"FILETYPE=InterLace" and setup 'ProgDir_'
;	movem.l	(sp)+,d0-d3/a0/a1/a6
*

 ifeq	1	;not needed 5-25-94
	move.l	ProgNamePtr_(BP),d0
	beq.s	no_wb_name		;what? no program name from icon?
	move.l	d0,a1

	tst.w	ProgNameLen_(BP)
	bne.s	no_wb_name		;already have a length (reset name?)

	move.w	d2,-(sp)
	move.w	#60-1,d2		;loop ctr
	moveq	#0,d0			;len gonna build
findlen	move.b	(a1)+,d1
	beq.s	gotlen
	cmp.b	#' ',d1
	beq.s	gotlen
	cmp.b	#$0a,d1
	beq.s	gotlen
	cmp.b	#$0d,d1
	beq.s	gotlen
	addq	#1,d0			;"ok" char
	dbf	d2,findlen
gotlen:	move.w	d0,ProgNameLen_(BP)
	move.W	(sp)+,d2

	movem.l	d0-d4/a0-a3,-(sp)	;gross, too many, check/say/what?
	move.W	ProgNameLen_(BP),d0
	move.L	ProgNamePtr_(BP),a0
	bsr	calcdirnamelen
	movem.l	(sp)+,d0-d4/a0-a3	;gross, too many, check/say/what?
no_wb_name:

	tst.b	FlagLaceNEW_(BP)
	beq.s	no_interlace
	add.w	d4,d4			;double default for interlace
no_interlace:
	move.w	d4,bmhd_pageheight_(BP)

	lea	BigNewScreen_(BP),a2

	move.w	d3,NewSizeX_(BP)
	move.w	d4,NewSizeY_(BP)

	cmp.w	bmhd_pagewidth_(BP),d3	;'just did' width vs. default
	bcc.s	wdefwt			;already set page is smaller, use it
	move.w	d3,bmhd_pagewidth_(BP)	;smaller wt than default
wdefwt:	cmp.w	bmhd_pageheight_(BP),d4
	bcc.s	wdefht
	move.w	d4,bmhd_pageheight_(BP)	;smaller ht than default
wdefht:
  endc



AFTER_cmdline:
	DUMPMSG	<AFTER cmdline>

	move.l	ProgNamePtr_(BP),d0
	beq.s	nopname
	move.l	d0,a1			;pointer to program name
	move.w	DirNameLen_(BP),d0
	lea	0(a1,d0.w),a1		;skip name ptr past dir stuff
	lea	ProgramNameBuffer_(BP),a2  ;buffer's TRUE length is 32
	tst.b	FlagToasterAlive_(BP)	;switcher alive? startup set name already
	bne.s	nopname
	beq.s	gotusename		;AUG141990
	lea	ForcedProgName(pc),a1	;defined in Main.asm, AUG141990
gotusename:
	xjsr	copy_string_a1_to_a2 	;dirrtns; copy 60 null-term' bytes or less
nopname:
;ADJUST SCREEN SIZE from BMHD PAGE parms (reset our camg, too)
;setup d1=scrnwt, d2=scrnht
	move.w	bmhd_pagewidth_(BP),d1
	move.w	bmhd_pageheight_(BP),d2

	tst.b	FlagToasterAlive_(BP)	
	bne	Zgot_wh

 ifeq	1
	cmp.w	#(640-1),d1		;GOING LORES still had hires width?
	bcs.s	Zwdtok
	asr.w	#1,d1
Zwdtok:	tst.b	FlagLaceNEW_(BP)	;width ok, for lores width
	bne.s	Zlaceit
Ztloht:	cmp.w	#(400-1),d2		;pageht < 400? (non-ilace maxht)
	bcs.s	Zgot_wh			;yep..ok
	asr.w	#1,d2			;pageht/2
	bra.s	Ztloht			;keep /2 height until <400 for lores
Zlaceit:
	add.w	d2,d2			;interlace ht
Ztlacht:
	cmp.w	#(700-1),d2		;PAGEht < 700? max interlace
	bcs.s	Zgot_wh
	asr.w	#1,d2
	bra.s	Ztlacht			;keep /2 height until <400 for lores
 endc

Zgot_wh:
	move.w	d1,bmhd_pagewidth_(BP)	;re-adjust!!!
	move.w	d2,bmhd_pageheight_(BP)

	lea	BigPicWt_W_(BP),a0
	tst.w	(a0)
	bne.s	gotbpwt
	move.w	d1,(a0)
gotbpwt:
	lea	BigPicHt_(BP),a0
	tst.w	(a0)
	bne.s	gotbpht
	move.w	d2,(a0)
gotbpht:


 ifeq	1
;?;a0=ptr to filename (if any), d0=remaining len to copy
	moveq	#10,d5	;bmhd_xaspect_
	moveq	#11,d6	;bmhd_yaspect_
	tst.b	FlagLaceNEW_(BP)
	beq.s	nolaceasp
	add.w	d5,d5			;doubled x aspect for interlace
nolaceasp:
	move.B	d5,bmhd_xaspect_(BP)
	move.B	d6,bmhd_yaspect_(BP)

	movem.l dosCmdLen_(BP),d0/a0 	;dosCmdBuf;original registers at startup
;A0=ptr to filename (if any), D0=remaining len to copy
	lea	FilenameBuffer_(BP),a1
	tst.b	D0			;any arguments on command line (from CLI) ?
	ble.s	no_start_file		;jumps if no start file, or if from WorkBench
find_filename_char:			;accept ALL CHARACTERS AFTER THE FIRST BLANK
	move.b	(A0)+,D0
	beq.s	end_filename_copy
	cmpi.b	#' ',D0
	beq.s	find_filename_char	;skip the beginning space
	bra.s	fillfc
movefc:	move.b	(A0)+,D0 		;from command line
	beq.s	end_filename_copy
fillfc:	cmpi.b	#$0A,D0 	 	;=lf?
	beq.s	end_filename_copy
	cmpi.b	#$0D,D0 	 	;=cr?
	beq.s	end_filename_copy
	move.b	D0,(a1)+
	dbf D0,movefc
end_filename_copy:
1$	cmpi.b	#' ',-(a1)		;strip trailing blanks
	beq.s	1$			;backup until not space
	addq.l	#1,a1			;sk706 fix for Matt's Shell
	lea	FilenameBuffer_(BP),A0
	cmp.l	A0,a1			;ascii buffer get filled?
	beq.s	no_start_file		;nope...(use default defined in Requesters.asm)
	move.b	#0,(a1)  		;ends name with a NULL
 endc

no_start_file:
nomaincmd:

*******************************************************
* note, toaster copper lists only affected *here*...
*       only around select/unselect calls, also...
*******************************************************

BITPLANESIZE set MAXWT*MAXHT/8		;for checking of avail memory, "LOAD" message

	bra	donetoaststuff
	cnop 0,2

ToasterWait:	;load, unload, select
	DUMPMSG	<ToasterWait>
	bsr	ToasterReply		;return old message, if any
	move.l	ExecLibrary_(BP),a6	;Exec base cached in (fastmem) basepage JUNE
	moveq	#0,d0			;no m'class if empty port...
	lea	OnlyPort_(BP),a0
 	lea.l	MP_MSGLIST(a0),a1
 	cmpa.l	8(a1),a1
	bne.s	dogtm			;do a get msg (10cy bra vs 8cy nobra)
	CALLIB	SAME,WaitPort
	lea	OnlyPort_(BP),a0
dogtm:	CALLIB	SAME,GetMsg		;look for a message d0=null if no mesg.
	move.l	d0,ToasterMsgPtr_(BP)	;ptr to unknown type message
	beq.s	ToasterWait		;wha? no msg?
	move.l	d0,a0
	move.l	MN_SIZE(a0),d0		;FBC_command...0=load, 1=unload, 2=select
	DUMPREG	<a0, FBC_command...0=load, 1=unload, 2=select>	
	movem.l	d0/a0,-(sp)		;STACKing cmd, msgptr...not needed? JULY051990
;if this is a "LOAD" message, then grab just the dirlock
	move.l	d0,ToasterCMD_(BP)	;cmp.l	#0,d0	;"load" message?
	bne.s	8$
	move.l	8+MN_SIZE(a0),a1	;toasterbase
	xjsr	GlueLoad		;ToastGlue, call with a1=toastbase
;MAY91	xjsr	InitEncoding ;rgb2toast; ;called by toaster/switcher interface main.toast.i	;KLUDGEOUT,WANT...JULY141990;
	bra.s	NotSelectmsg
;if this is a "select" message, then grab the "chip memory"
8$:	cmp.l	#2,d0			;"select" message?
	bne.s	NotSelectmsg
	DUMPMSG	<load select>
*
	move.l	8+MN_SIZE(a0),a1	;toasterbase
	xjsr	GlueSelect		;ToastGlue, call with a1=toastbase
*
	xjsr	FreeSwapRGB		;RGBRtns.asm SEP121990....free'd upon select
*
	xjsr	ForceToastCopper	;ensure "toaster black screen"
*
;MAY91	xjsr	ResetEncoding		;resets encoding "line numbers", rgb2toast.A
*
	tst.b	FlagKeep24_(BP)		;don't delete 24 bit buffers from toaster/switcher
	beq.s	883$			;only "redo screen" if rgb buffer intact AND FLAG IS SET
*
	lea	BigPicRGB_(BP),a1 	;have rgb bitmap from last switcher-run?
	tst.l	bm_Planes(a1)
	beq.s	883$
	st	FlagWholeHam_(BP) 	;if so, ask for "whole ham re-do", mainloop
883$:
NotSelectmsg:
	movem.l	(sp)+,d0/a1		;destack a1=msg ptr
	RTS

ToasterReply:
	DUMPMSG	<ToasterReply>	
	lea	ToasterMsgPtr_(BP),a1
	move.l	(a1),d0
	beq	after_treply		;bummer, no saved msg to reply
	;clr.l	(a1)			;prevent 2x reply...
	move.l	d0,a1

	cmp.l	#2,MN_SIZE(a1)		;'SELECT msg'?
	bne	ea_tselect
	DUMPMSG	<select message processing>
	move.l	ToasterErrorCount_(BP),(12+MN_SIZE)(a1)
	clr.l	ToasterErrorCount_(BP)
	tst.B	FlagQuitSuper_(BP)	;Squt action code's flag....
	beq.s	no_unloadselect
	DUMPMSG	<SuperQuit Set>	
	move.l	#-1,(12+MN_SIZE)(a1)	;flag as error-switcher please send me an unload
no_unloadselect:

	xref	GlobalRGBPtr_		;MAR91...handled in main.toast.i
;MAR91....recopy "my" buffer back to global
	move.l	a1,-(sp)		;toaster msg ptr
	;xjsr	GlueOpenGlobalRGB	;toastglue.asm
	move.l	GlobalRGBPtr_(BP),d0
	beq.s	bumcopy
	move.l	d0,a0			;toaster's buffer
	lea	BigPicRGB_(BP),a1	;clone it into 'mine'
	move.w	#bm_Planes+12-1,d0
recopy_globals:
	move.b	(a1)+,(a0)+
	dbf	d0,recopy_globals
	move.l	GlobalRGBPtr_(BP),d0
	move.l	d0,a0
	;AUG301991;xjsr	GlueCloseGlobalRGB
bumcopy:
	move.l	(sp)+,a1		;toaster msg ptr

;KLUDGE july071990.....no force toaster copper...;
	DUMPMSG	<GLUEUNSELECT>
;	xjsr	GlueUnSelect		;toastglue
	xref	DirnameBuffer_
	sf	DirnameBuffer_(BP)	;*clear out dirname*...AUG291990...
	sf	FilenameBuffer_(BP)	;*clear out filename* so it
;	bra.s	83$		;..doesn't "re-load" upon "re-select"

	sf	FlagToast_(BP)	;hires mode *off* when return from switcher...SEP031990
;SEP121990;xjsr	SetupForExpand	;gadgetrtns.asm, turns 'off' 1x mode...SEP031990

;july011990....free backup imagery for 2 way sliders...
	move.l	a1,-(sp)
	xjsr	SetupForExpand		;gadgetrtns.asm, turns 'off' 1x mode...SEP121990
	neg.b	CurrentFrameNbr_(BP)	;helps freebup imagery to "always work"
	xjsr	FreeBUPImagery		;bgadrtns.asm
	xjsr	FreeTwoXImagery		;bgadrtns.asm
	neg.b	CurrentFrameNbr_(BP)	;helps freebup imagery to "always work"
	move.l	(sp)+,a1

ea_tselect:
	cmp.l	#1,MN_SIZE(a1)		;'UN-LOAD msg'?
	bne.s	ea_unloadreply
	move.l	a1,-(sp)

;MAY91	xjsr	CloseEncoding 		;rgb2toast; ;called by toaster/switcher interface main.toast.i
	xjsr	FreeUnDoRGB		;MAR91...note: this logically leaves 'RGB' buffer allocated
	xjsr	FreeSwapRGB		;RGBRtns.asm (2.0)...free'd upon unloading
	xjsr	GlueCloseGlobalRGB	;AUG301991
	move.l	(sp)+,a1
	bra	after_treply		;.only startup code replys to the unload
ea_unloadreply:

	tst.l	MN_SIZE(a1)		;'LOAD msg'?
	bne	do_treply

		;PRE-ALLOCATE RGB and RGB-UNDO buffers for 'big picture'
	movem.l	d0/d1/a0/a1,-(sp)
	xjsr	_Dflt_rx		;gadgetrtns.o, loads default pictures
;did the picture get loaded?...if not...bye! 
	xref PicFilePtr_		;hp.gads, the entire file, in memory
	tst.l	PicFilePtr_(BP)		;hp.gads, the entire file, in memory
	beq	abortload
	xjsr	AllocDetermineTable	;memories.asm;getitifwedonthave it
	beq	abortload
	xjsr	InitShortMulTable	;memories.o, shortmultable for paintcode
	beq	abortload

;july131990...hardcode area-buffers-allocation, main loop, never deletes now
	xjsr	AllocAreaStuff		;memories.asm, for flood-fill
	beq	abortload		;none?

	move.L	#MAXWT,d0		;default size
	move.w	#MAXHT,d1

	move.L	d0,BigPicWt_(BP)	;.long var  july051990
	move.w	d1,BigPicHt_(BP)	;only .word size var

	move.w	d0,NewSizeX_(BP)	;args for "openbigpic"
	move.w	d1,NewSizeY_(BP)
	sf	FlagLaceNEW_(BP)

	;xjsr	AllocRGB		;alloc arrays...d0=wt, d1=ht, ZERO flag for success
	;beq.s	abortload

	DUMPMSG	<Calling GlueOpenGlobalRGB>
	xjsr	GlueOpenGlobalRGB
	move.l	d0,GlobalRGBPtr_(BP)
*	beq	abortload
	beq	abortload
	st	FlagWholeHam_(BP) 	;asks for "whole ham re-do", mainloop
	move.l	d0,a0			;toaster's buffer
	lea	BigPicRGB_(BP),a1	;clone it into 'mine'
	move.w	#bm_Planes+12-1,d0

copy_globals:
	DUMPMSG	<copy_global>
	move.b	(a0)+,(a1)+
	dbf	d0,copy_globals

	;;xjsr	DebugMe
	DUMPMSG	<Calling AllocUnDoRGB>
	xjsr	AllocUnDoRGB		;rgbrtns.asm either get all three, or none at all...
	beq	abortload	


;the following #s are from memories.asm
min_chip	set	10*1024 ;12*1024
toolreq		set	(40*42*6)+(4*1024)
chipreq		set	min_chip+toolreq+BITPLANESIZE

	DUMPMSG	<Checking Avail memory>
	move.l	#MEMF_CHIP,d1
	CALLIB	Exec,AvailMem
	DUMPREG	<Memorycheckchip>
	cmp.l	#chipreq,d0 	;enuff chip for 1 bitplane+extra?
	bcs	abortload
	DUMPREG	<Memoryok>

	move.l	d0,-(sp)	;STACK chip mem avail
	move.l	#MEMF_FAST,d1
	CALLIB	Exec,AvailMem
	add.l	(sp)+,d0	;total of chip+fast
	cmp.l	#(6*BITPLANESIZE)+chipreq,d0 ;enuff FAST for ham undo - 6 bitplanes?
	bcs.s	abortload

	moveq	#0,d0		;error status 0 = "ok", for paintslice code
	tst.l	UnDored_(BP)
	bne	loadedok
abortload:
	DUMPMSG	<AbortLoad>
	;MAR91....check if FROM toaster...
	tst.l	GlobalRGBPtr_(BP)
	bne.s	1$		;skip 'FREERGB' if FROM toaster...
	xjsr	FreeRGB		;rgbrtns.asm
1$:	;;bsr	debugavail	;new meaning...june2690moveq	#-1,d0		;error flag
	xjsr	FreeUnDoRGB	;rgbrtns.asm
	;;bsr	debugavail	;new meaning...june2690moveq	#-1,d0		;error flag
;july131990,late;abortload:
	;AUG161990;moveq	#1,d0		;error flag, "no memory"
	;NOTE: TErrorCount value 0 = ok, 1 = nofonts, 2+ = nomemory
	moveq	#2,d0		;error flag, "no memory"
	DUMPREG	<Abortload d0,2=no memory, 1=no fonts, 0=ok>	
loadedok:
	DUMPMSG	<Loaded ok>	

	;move.l	ToasterErrorCount_(BP),(12+MN_SIZE)(a1)
	;clr.l	ToasterErrorCount_(BP)
	move.l	3*4(sp),a1		;temp, restore msg ptr...
	move.l	d0,(12+MN_SIZE)(a1)	;saving error status for switcher

	;;bsr	CloseBigPic
	;;xjsr	GoodByeToolWindows	;tool.o close hires and ham palette

	movem.l	(sp)+,d0/d1/a0/a1

do_treply:
	clr.l	ToasterMsgPtr_(BP)	;prevent 2x reply's
	JMPLIB	Exec,ReplyMsg
after_treply:
	rts

	;;;debuggers...
TErrorStuff:
	move.l	d0,ToasterErrorCount_(BP)
	RTS

TErrorNoMemory:
	;;;bset	#7,ToasterErrorCount_(BP)	;top bit makes it negative
	;;;RTS

TErrorInc:
	addq.l	#1,ToasterErrorCount_(BP)
	RTS

TErrorRunOk:
	;bclr	#7,ToasterErrorCount_(BP)	;make it positive..."ok"
	clr.l	ToasterErrorCount_(BP)		;0="ok"
	RTS

*****************************************************************
*								*
*								*
*								*
*								*
*****************************************************************
donetoaststuff:	;*must* be last line in "main.toast.i", 1st line bra's here.
;if NOT from switcher, load fonts
	tst.b	FlagToasterAlive_(BP)
	bne.s	waitonswitcher

;	DUMPMSG	<OpenDefaultFont>
	xjsr	OpenDefaultFont		;defaultfont.asm...JULY221990
	bne	Abort_nomem
*
*-> Go onward here!
waitonswitcher:
	DUMPMSG	<waitonswitcher>
	tst.b	FlagToasterAlive_(BP)	*
*	beq.s	notoastnow		*
	beq	notoastnow		*
*
	jsr	ToasterWait		;0=load, 1=unload, 2=select

	tst.l	d0
*	bne.s	notzeroload
	bne	notzeroload


;'LOAD' MESSAGE FROM SWITCHER
;toaster-mode only, load default pictures ASAP, before ToasterChip/SELECT usage...
	moveq	#0,d0
	BSR	TErrorStuff		0;setup error code
	xjsr	OpenDefaultFont		;defaultfont.asm...JULY221990
	bne	cant_find_fonts 	;mem
	bra	okfonts
	beq	okfonts

cant_find_fonts:
	move.l	#1,ToasterErrorCount_(BP)	;couldn't find font(s)
okfonts:
*	bra.s	waitonswitcher		;0=load.only "do" something at unload/select
	bra	waitonswitcher		;0=load.only "do" something at unload/select

notzeroload:
	cmp.l	#1,d0			;unload?
	bne.s	checkbumsel
	DUMPMSG	<Unload message, somehow>	

	st	FlagQuit_(BP)
	bsr	ToasterReply		;toaster waits until paint process dies
					;...before unloadseg'ing
	bra	StartQuitting		;abort_toaster	;die....Abort

checkbumsel:
	cmp.l	#2,d0			;=selected? (bummer...to soon...)
*	bne.s	waitonswitcher
	bne	waitonswitcher
	sf	FlagQuit_(BP)		;QUIT status was set "last time run"...
;hang onto select message
; 	jsr	ToasterReply		;main.toast.i
	st	Initializing_(BP)	;digipaint 'startup' conditions...
	xref	FlagCDet_		;calls for 'createdetermine' call
	st	FlagCDet_(BP) 		;NeedCreateDetermine_(BP);resets up palette...

notoastnow:
;disable system ("insert disk...")requesters...JULY06
	tst.l	saveexecwindow_(BP)
	bne.s	windowptrsaved
	move.l	our_task_(BP),A0	;startup.o
	move.l	pr_WindowPtr(A0),D0	;current/original err screen
	move.l	D0,saveexecwindow_(BP)	;...restore it later
	move.l	#-1,pr_WindowPtr(A0)	;no window now, auto-cancels

windowptrsaved:
	moveq	#0,d0			;july051990
	BSR	TErrorStuff		;setup error code
	BSR	TErrorNoMemory		;setup "unload me, slice!" in SELECT message
	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg

;	DUMPMSG	<BEFORE ForceToolWindow>
	xjsr	ForceToolWindow  	;first time open tool windows, disabled 'idcmp
;	DUMPMSG	<after ForceToolWindow>

	tst.l	GWindowPtr_(BP)		;hires gadget window get opened?
	beq	Abort_nomem
	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg

	CALLIB	Intuition,CloseWorkBench ;explicit call, here

	bsr	OnInt 			;adds vertb intserver, do after ProgNamePtr setup in main.cmd
	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg

	xjsr	AllocDetermineTable	;memories.asm;getitifwedonthave it
	beq	Abort_nomem

;	move.l	our_task_(BP),A0		;startup.o
;	move.l	pr_WindowPtr(A0),D0		;current/original err screen
;	move.l	D0,saveexecwindow_(BP)		;...restore it later
;	move.l	GWindowPtr_(BP),pr_WindowPtr(A0) ;hires screen for SYSTEM MSGS

	xjsr	InitShortMulTable	;memories.o, shortmultable for paintcode
	beq	Abort_nomem
	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg

	st	FlagNeedHiresAct_(BP)
	bsr	ReallyActivate		;only if not background...

	DUMPMSG	<BEFORE SetAltPointerWait>
; ifnd paint2000
	xjsr	SetAltPointerWait	;1st time//startup sup 'sleepycloud'
; endc
	DUMPMSG	<AFTER SetAltPointerWait>

	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg
	bsr	ResetIDCMP		;pointer? yea? idcmp too...
	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg

	xjsr	_Aoff_rx		;gadgetrtns.o

	BSR	TErrorInc		;d'bugger, incs error # for toaster/select msg
	tst.b	FlagToasterAlive_(BP)	;july071990....dont do this twice...
	bne.s	diddflt
	xjsr	_Dflt_rx		;gadgetrtns.o, loads default pictures
diddflt:
	BSR	TErrorInc		;#8;d'bugger, incs error # for toaster/select msg

;did the picture get loaded?...if not...bye! 
	xref PicFilePtr_		;hp.gads, the entire file, in memory
	tst.l	PicFilePtr_(BP)		;hp.gads, the entire file, in memory
	beq	StartQuitting

	BSR	TErrorInc		;#9;d'bugger, incs error # for toaster/select msg

	;	;DO "BOOT" STUFF BEFORE PICTURE LOAD...MAY'90
	;xjsr	CreateDetermine		;displays new palette, too
	;xjsr	BeginMenu		;'pmcl' a-code needs menu on hires
	;bsr	DoInlineAction
	;dc.w	'Pm'
	;dc.w	'cl'			;Paint Mode CLear
	;move.l	#'Boot',d0		;d0=LONG # (equiv 4 ascii) ('boot' code(s))
	;bsr	ZipKeyFileAction 	;main.key.i, reads keyfile for startup cond

	move.w	#MAXWT,BigPicWt_W_(BP)
	move.w	#MAXHT,BigPicHt_(BP)

	move.l	#'BOOT',d0		;d0=LONG # (equiv 4 ascii) ('boot' code(s))
	bsr	ZipKeyFileAction 	;main.key.i, reads keyfile for startup cond
	
;SEP101990.....non-standalone....
	tst.b	FlagToasterAlive_(BP)
	bne.s	notstandalone
	tst.b	FlagCapture_(BP)
	;beq	StartQuitting		;Abort_nomem
	bne.s	notstandalone		;ok to continue
	move.B	#218,Initializing_(BP)	;ERROR_DEVICE_NOT_MOUNTED	EQU	218
	bra	StartQuitting

notstandalone:
	BSR	TErrorInc		;#10;d'bugger, incs error # for toaster/select msg
	move.l	_WBenchArgName_(BP),d1
	beq.s	startupname		;no wbarg (ascii ptr)
	move.l	d1,a1
	lea	FilenameBuffer_(BP),a2
	xjsr	copy_string_a1_to_a2	;copy wbench's filename to gadget buffer
	
startupname:
	moveq	#0,d0			;move.l	#'Opsc',d0
	lea	FilenameBuffer_(BP),a0
	tst.b	(A0)			;ascii string? "have a filename"?
	sne	FlagOpen_(BP)		;yes/no set/clear "file open" status
	beq.s	1$			;HAVE filename?...if so, load it


*	DUMPMSG	<MAIN IS SETTING BUFFERBANK!> 
*	moveq	#0,d0
*	xjsr	_SetFrameBufferBank	;force bank to dv1 = 0
*
*	xjsr	ForceAmigaCopper 	;IntuitionRtns.asm, kill toaster's copper list...

	bsr	DoInlineAction	
	bra	1$
	dc.w	'Ok'
	dc.w	'ls'
1$:
	BSR	TErrorInc		;#11;d'bugger, incs error # for toaster/select msg


 ifeq	1
  IFD DEBUGGER	;basestuff.i
		;kludgey...comment out....debug tool
	bra.s	skipavail
	xdef debugavail
debugavail:
	xref debug_handle	;absolute ref, debugme.asm
	movem.l	d0-d4/a0-a6,-(sp)
	xjsr	OpenDebug	;debugme.asm
	move.l	debug_handle,d3
	bne.s	gotoutput
	CALLIB DOS,Output	;get file handle, already open
	move.l d0,d3		;get ready to write to it
gotoutput:
	beq.s	doneavail	;no handle (d3)
	lea	CmdString(pc),a0
	move.l	a0,d1		;d1=string to execute
	moveq	#0,d2		;d2=input
	;;;move.l	StdOut_(BP),d3	;d3=output
	CALLIB	DOS,Execute
	xjsr	GraphicsWaitBlit	;wait for cli to display (memories.asm)
doneavail:
	movem.l	(sp)+,d0-d4/a0-a6
	rts
CmdString:	dc.b	'Avail',0
	cnop	0,2
skipavail:
  ENDC ;ifd DEBUGGER
 endc



*** main loop ***;GRAND MAIN HIGHEST TOTAL UPPERMOST TOP BIGGEST LOOP START
	;"action"s have the highest "priority" in the digipaint paradigm
	;...handle all "waiting to be done" actions before any msgs
	;...btw:msgs usually just set up an 'action code'

restart_if_msg:	MACRO	;quick check, any msgs?, if so go get
	lea	OnlyPort_(BP),a0
 	lea	MP_MSGLIST(a0),a1
	cmpa.l	8(a1),a1
	bne	trymsg
	bsr	reloop_if_msg		
	ENDM

  IFD DEBUGGER
	xjsr	DebugMe	;kludge, of cours
  ENDC

	BSR	TErrorRunOk		;clear out "unload me" status
	bra.s	EventLoop
reloop_if_msg:	;bsr here...
	move.l	(sp)+,a6		;very temporary, pop subr rtn
	tst.l	ActionCode_(BP)		;restart if any routine left another
	bne.s	EventLoop		;...action code 2b done...SEP061990
	lea	OnlyPort_(BP),a0
 	lea	MP_MSGLIST(a0),a1
	cmpa.l	8(a1),a1
	bne.s	trymsg			;event loop
	jmp	(a6)			;"return from subr"
	
EventLoop:
;	DUMPMSG	<EventLoop>
;	move.l	#$fcfcfcfc,d0
	lea	ActionCode_(BP),a0
	move.l	(a0),d0			;do 'actions' until none indicated
	beq.s	trymsg			;no action, go do message
	moveq	#0,d1
	xref	ThisActionCode_		;02FEB92
	xref	LastActionCode_		;02FEB92
	cmp.l	#'Move',ThisActionCode_(BP)
	beq.s	1$			;skip 'move' action codes...
	move.l	ThisActionCode_(BP),LastActionCode_(BP)	;02FEB92...ref'd by GadgetRtns for 'Ccto' 2.0 bug
1$	move.l	(a0),ThisActionCode_(BP) ;02FEB92...ref'd by GadgetRtns for 'Ccto' 2.0 bug
	move.l	d1,(a0)			;clears ActionCode_(BP)
	bsr	DoAction


trymsg:
;	;bug fix to prevent "quitting" from hanging DigiView 
;	;...while DigiView is sending a picture
;	tst.b	FlagQuit_(BP)
;	beq.s	1$
;	clr.b	ProgramNameBuffer_(BP)	;port name = program name
;1$
	bsr	CheckIDCMP		;check msg port
	beq	nomsg

*** Preprocess MSG 030794/DEH for Palette Slider gadgets
	move.l	MsgPtr_(BP),a0		;get message address
	cmp.l	#MOUSEMOVE,im_Class(a0)
	beq	GotAMove

	cmp.l	#MOUSEMOVE,im_Class(a0)
	beq	.gadget
	cmp.l	#GADGETDOWN,im_Class(a0)	;ENFORCER HIT HERE!
	beq	.gadget
	cmp.l	#GADGETUP,im_Class(a0)
	beq	.gadget
	bra	IntActType

.gadget					
	move.l	im_IAddress(A0),A1  	;get gadget that initated msg
	cmp.l	#0,a1			;=0 on RMB!
	beq	CKIntAct		;just go on?	
	move.w	gg_GadgetID(A1),d0	;check gadgetID to see for match

	cmp.b	#$FC,d0			;check for gadgetID of pal sliders			
	bne	CKIntAct		;see if message is from a minislider 
	clr.l	MsgPtr_(BP)
	cmp.l	#0,PalGadAct_(BP)	;is a palette prop active?
	beq	BeginPalProp	
*	
	move.l	#0,PalGadAct_(BP)	;clear prop active case
	xjsr	NewMsg_Handler		;gadgetup case
	bra	nomsg	

CKIntAct:
	cmp.b	#$FD,d0
	bne	gotmsg
	clr.l	MsgPtr_(BP)
	xjsr	NewMsg_Handler
	bra	nomsg

BeginPalProp:
	move.l	gg_UserData(a1),PalGadAct_(BP)
	xjsr	NewMsg_Handler		;gadgetdown case
	bra	nomsg


notaProp:
	cmp.l	#0,PalGadAct_(BP)	;is a palette prop active?
	beq	gotmsg			;no, skip.	
	bra	nomsg			;done processing pal prop go on.

GotAMove:
	move.l	PalGadAct_(BP),a1	;get the current prop gad controls
	move.l	a1,d0			;is it 0?
	beq	gotmsg			;go on.
	jsr	(a1)			;process act gadget
	bra	gotmsg
	
IntActType:
* this is where interactive/realtime gadget may be processed someday.
*	bra	gotmsg


	
gotmsg:	bsr	Process_IDCMP_Mesg	;grand master msg handler
	bra	EventLoop		;RESTART MAIN LOOP
nomsg:
;;;;;;;;	bsr ReallyActivate	;activate hires (ifneeded) asap, helps w/Clbx AUG231990

	xref	FlagNeedAutoMove_	;18DEC91....input handler/mousemove generator/main loop
	lea	FlagNeedAutoMove_(BP),a0
	tst.b	(a0)			;flag set by input handler
	beq.s	no_handlermove
	sf	(a0)
	xjsr	AutoMouseMove
no_handlermove:


;		xjsr DebugPrint12	;prints 15 longwords of Print12Ptr_ structure ;KLUDGE, AUG221990
;aug011990;		;handle "always render" mode....AUG011990
;aug011990;	xref	SolLineTable_
;aug011990;	tst.l	SolLineTable_(BP)	;any lines to be rendered?
;aug011990;	beq.s	norender
;aug011990;	xref FlagAlwaysRender_
;aug011990;	tst.b	FlagAlwaysRender_(BP)
;aug011990;	beq.s	norender
;aug011990;	move.l	#'Vwco',ActionCode_(BP)	;view composite action code
;aug011990;	bra.s	EventLoop
;aug011990;norender:


  IFC 't','f' ;AUG161990
;handle 'auto-draw' of airbrush
	xref LastDrawX_
	xref LastDrawY_
	xref MyDrawX_
	xref MyDrawY_
	tst.b	FlagDoAir_(BP)
	beq.s	noairnow
	;sf	FlagDoAir_(BP)
	subq.B	#1,FlagDoAir_(BP)
	move.l	#'Move',ActionCode_(BP)	;"spatter"s another air-brush-drop
	move.w	LastDrawX_(BP),MyDrawX_(BP)	;..circctr, linest, rect1crnr
	move.w	LastDrawY_(BP),MyDrawY_(BP)
	bra.s	EventLoop
noairnow:
  ENDC ;AUG161990


;empty msg queue, start doing "slower" things
	tst.b	FlagQuit_(BP)	;start quitting AFTER msg queue empties
	beq.s	008$
	xjsr	SafeEndFonts	;textstuff.o...might clear quit flag
	bsr	CheckIDCMP		;check msg port
	bne.s	gotmsg			;re-loop
	bra	StartQuitting
008$
;open "bigpic" screen, but only "upon conditions"
	tst.l	ScreenPtr_(BP)		;big painting picture still there?
	bne.s	afterFORCEscreen	;not when already have a bigpic
	tst.b	FlagSizer_(BP)
	bne.s	afterFORCEscreen	;not when "screen sizer" active
	tst.W	FlagOpen_(BP)		;filerequester? (load/save/font/brush)
	bne.s	afterFORCEscreen	;not when file request "open"
;AUG281990;tst.w	FlagViewComp_(BP)
;AUG281990;bne.s	afterFORCEscreen	;not when file request "open"
	move.l	#'Opsc',ActionCode_(BP)	;if 'opsc' no go, then sups sizer mode
	bra	EventLoop
afterFORCEscreen:

	xjsr	CheckKillMagnify
	xjsr	CheckBegMagnify	;begin magnify
	xjsr	ReDoHires	;hires display, gadget update/refresh


  IFC 't','f' ;causes sizer to flash continously in 1x+continuous render modes
	;09DEC91...bugfix for brush sizer not displaying in continuous render mode
	xref	FlagAlwaysRender_	;09DEC91
	xref	FlagUpdateCG_		;09DEC91
	tst.b	FlagAlwaysRender_(BP)
	beq.s	notalways
	st	FlagUpdateCG_(BP)	;set when need update of brush sizer 08DEC91...FOR 1x mode?
	;movem.l	d0-d7/a0-a5,-(sp)
	;bsr	UpdateCustomGads	;main loop/gadget refresh for custom gadgets
	;movem.l	(sp)+,d0-d7/a0-a5
notalways:
  ENDC 


;INITIALIZING/STARTUP stuff
	tst.l	ScreenPtr_(BP)	;bigpic?
	beq	after_inittime	;bigpic not opened yet
	tst.b	Initializing_(BP)
	beq	after_inittime	;not sup time
	clr.b	Initializing_(BP)	;ALRIGHT!
	xjsr	SupBottomAscii ;showtxt.o ;rtns a0=already sup text bottom row
 	move.b	#$0a,32(a0)	;cr
	move.b	#$0a,60(a0)	;cr
	PRTMSG a0,81 		;version #, CopyRight to cli(if any) output

;DO "BOOT" STUFF BEFORE PICTURE LOAD...MAY'90
	xjsr	CreateDetermine		;displays new palette, too
	xjsr	BeginMenu	;'pmcl' a-code needs menu on hires
	bsr	DoInlineAction
	dc.w	'Pm'
	dc.w	'cl'		;Paint Mode CLear
	move.l	#'Boot',d0	;d0=LONG # (equiv 4 ascii) ('boot' code(s))
	bsr	ZipKeyFileAction ;main.key.i, reads keyfile for startup cond
	bra	EventLoop

after_inittime:
;;	DUMPREG	<OpenHamTools>
	xjsr	OpenHamTools	;reserve the memory (pmcl wants hamtools?)
	restart_if_msg
;ARRANGE SCREENS
;;	DUMPREG	<ScreenArrange>
	xjsr	ScreenArrange		;gadgetrtns.o (call b4 displaybeep)
	restart_if_msg

	tst.b	FlagToastCopList_(BP)
	beq	101$
	xjsr	ForceAmigaCopper ;IntuitionRtns.asm, kill toaster's copper list...
101$
	xjsr	AproPointer		;appropriate hires ptr bgadrtns.asm	
	xjsr	UpdateCustomGads	;customgads.asm, brush sizer 09DEC91	
	xjsr	FixPointer		;helps out 'customized brush'			
	restart_if_msg

;;	DUMPREG	<HiresColorsOnly>
	xjsr	HiresColorsOnly		;pointers.o, sup colors on hires
	restart_if_msg			;02FEB92
	xjsr	UseColorMap		;(pointers.o, for now)
	restart_if_msg


;	tst.b	FlagDisplayBeep_(BP)
;	beq.s	dontbeep
;	sf	FlagDisplayBeep_(BP)	;so dont happen 2x
;	suba.l	a0,a0		
;	CALLIB	Intuition,DisplayBeep
;	restart_if_msg
;dontbeep:
*	xjsr	IntuDisplayBeep	;intuitionrtns.asm

	bsr	ResetIDCMP	;change idcmp ONLY when no msgs (or new scr)
	bsr 	ReallyActivate	;activate hires (ifneeded) asap, helps w/Clbx

	restart_if_msg

;;	DUMPREG	<SupHamGads>

	xjsr	SupHamGads	;tool.code.i, add gadgets to hamtools
	restart_if_msg

	lea	FlagRedrawPal_(BP),a0
	tst.b	(a0)
	beq.s	easetc
	sf	(a0)

;;	DUMPREG	<RedrawPalette>
	xjsr	RedrawPalette	;tool.code.i,refreshes needed hamtool gads
	restart_if_msg

easetc:
;update rgb sliders on hamtools
	lea	FlagRefHam_(BP),a0
	tst.b	(a0)			;asking for new colormaps?
	beq.s	earefh			;...nope.
	;;;sf	(a0)			;clear flag so don't reset cmaps again
	sf	FlagRefHam_(BP)		;flag so dont happen 2x
;no old update palette	
	xjsr	UpdatePalette		;showpal.o, show rgb sliders, cbrites
;;	restart_if_msg
	xjsr	DoMinDisplayText	;showtxt.o, min'timered text
	restart_if_msg			;msg after showtxt? (sys uses 756bytes)

earefh:
	xjsr	DoShowPaste		;cutpaste.o, TIMERED shows cutout brush
;show magnify asap...in 'mintimered loop'..
	tst.l	PasteBitMap_Planes_(BP)	;carrying a brush?
	beq.s	379$
	xjsr	DoMagnify 		;min'timer'd...(this one's for draw/cut-ing)..."faster"

379$
	restart_if_msg
	move.b	FlagSingleBit_(BP),d0	;cutpaste/blits/only 1 bitplane up?
	or.b	FlagNeedShowPaste_(BP),d0 ;need 'new' brush display
	beq.s	oknosho
	xjsr	ReallyShowPaste		;NON timer'd brush display (c/b SLOW)

oknosho:
	xjsr	DoSpecialMode		;drawb.mode.i, (rectangle, circle, line, curve)
	xjsr	DoMinDisplayText 	;showtxt.o, minimum timered text
	xjsr	DoMinMagnify		;min'timer'd...(this one's for draw/cut-ing)
	restart_if_msg			;check for msg AFTER text, palette update

;;	DUMPREG	<REALLY DO MAG>
	xjsr	ReallyDoMagnify		;force magnify display
	xjsr	ReallyDisplayText	;force text display (clrs FlagNeedText)
	bsr	FixInterLace		;slow?
	restart_if_msg

	tst.b	FlagRefHam_(BP)		;openhamtool just happen?
	bne	EventLoop
	
;;	DUMPREG	<MAIN_SP>	
	
	xjsr	ShowPalette		;showpal.o, checks/clears FlagNeedShowPal
	restart_if_msg			;check for msg AFTER text, palette update

	bsr	ResetPriority		;(showpaste//blits?...coulda upped it)
	restart_if_msg

	;xref	FlagWholeHam_		;'main loop' handles this flag -> Wham.asm
	;lea	FlagWholeHam_(BP)
	xjsr	WholeHam		;redo's ham display, if possible

	xjsr	ViewPage		;viewpage.o, only does it if flag set
	bne.s	afterwait		;happen'd...restart (ViewPage contains a Wait)

	xref	FlagViewComp_		;view composite...
;;  IFC 't','f' ;KLUDGE,WANT,*NEED*
;display/update composite "view" (newcode)
	tst.l	FileHandle_(BP)		;*only* reason a file would be open,
	bne.s	96$ ;compositerender		;here, is when rendering->framestore file
	tst.W	FlagOpen_(BP)		;AUG241990...no rendering if in file requester
	bne.s	98$			;....eliminates 're-render' of whole screen
	lea	FlagViewComp_(BP),a0
	tst.w	(a0) ;FlagViewComp_(BP)	;view composite...
	beq.s	98$
;NOPE....ACTION CODE Shcf CLEARS THIS;clr.w	(a0) ;FlagViewComp_(BP)
96$:	;compositerender:
;AUG281990
	xref FlagPick_
	tst.b	FlagPick_(BP)
	bne.s	98$		;no rendering while picking a color...
	xjsr	CustomCopper	;copper.o
	bra.s	afterwait
98$
;;  ENDC

	tst.l	PasteBitMap_Planes_(BP)	;27JAN92
	beq.s	nodouble		;*always* free the doublebuffer 27JAN92
	move.l	our_task_(BP),a0 ;ptr to task(|process) structure
	tst.b	LN_PRI(a0)	;BYTE LN_PRI in task struct already?
	bpl.s	yesalive
nodouble:
	xjsr	FreeDouble	;kills//frees chipmem copy of picture
yesalive:
	xjsr	ActivateText	;only happens upon apro' conditions
	restart_if_msg		;june01,1990, switcher does weird things 2nd time run?
;handle "always render" mode....AUG011990
	xref FlagAlwaysRender_
	tst.b	FlagAlwaysRender_(BP)
	beq.s	norender
	xjsr	DetermineRender		;composite.asm
	beq.s	norender


  ifc 't','f' ;removed NOV91
;AUG281990
;ok, want to show toast/custom copper list....
;but "stall" in case the user is just moving the mouse, etc.
;ONE SECOND;move.w	#6-1,d2	;6 1/10s of a second to stall...
	move.w	#2-1,d2	;1/3 second stall....
97$	moveq	#10,d0	;dos arg is in ticks (1/60 or 1/50 of a second)
	moveq	#10,d1
	CALLIB	DOS,Delay
	restart_if_msg
	dbf	d2,97$
  endc 

	move.l	#'Vwco',ActionCode_(BP)	;view composite action code
	bra	EventLoop
norender:
;29JAN92;moveq	#-1,D0		;indicate signal set of all//any
;29JAN92;CALLIB	Exec,Wait

	moveq	#4-3,d0
	moveq	#4-3,d1
	CALLIB	DOS,Delay

	bsr	NoSignalAutoMove	;main.key.i ;only called after a "wait" in main loop

;	xref FlagDoAir_		;handled by interrupt routine (main.int.i)
;	tst.b	FlagDoAir_(BP)
;	beq.s	afterwait
;	sf	FlagDoAir_(BP)
;	move.l	#'Move',ActionCode_(BP)	;"spatter"s another air-brush-drop
;	xjsr	Move_entry	;MouseRtns.asm, "spatter" another drop
;	KLUDGE OUT;xjsr	DrawBrush	;DrawBrush.asm, "spatter" another drop


afterwait:
;;	DUMPREG	<afterwait>

	xref RemagTick_
	xref ShowPasteTick_
	xref RetextTick_
	move.l	Ticker_(BP),d0		;'clocktime'
	move.l	d0,RemagTick_(BP)	;reset 'clock's so
	move.l	d0,ShowPasteTick_(BP)	;...'natural' priority happens...
	move.l	d0,RetextTick_(BP)	;...can then call domintext b4 showpaste
	bra	EventLoop


   xdef ReallyActivate	;only xref'd by repaint/scratch.o
ReallyActivate:
;;	DUMPREG	<ReallyActivate>

	xjsr	AreWeAlive
	beq.s	noneedact			;no window, cant activate it

	lea	FlagNeedHiresAct_(BP),a0
	tst.b	(a0)
	beq.s	noneedact			;no window, cant activate it
	sf	(a0)				;clear flag, "doing" it

	move.l	LastM_Window_(BP),d0
	beq.s	001$
	cmp.l	GWindowPtr_(BP),d0		;already active ?
	beq.s	noneedact
001$
	move.l	GWindowPtr_(BP),D0
	beq.s	noneedact			;no window, cant activate it
;	move.l	d0,LastM_Window_(BP)		;kludgey but needed....(?)
	move.l	IntuitionLibrary_(BP),a6
	move.l	d0,a0				;a0=hires window
;	JMPLIB	SAME,ActivateWindow	
	xjmp	IntuActivateWindow		;IntuitionRtns.asm
noneedact:
	rts


do_flag_routine macro	;message class,external routine
	cmp.l	#\1,d0
	bne.s	dfr\@
	xjmp	\2
dfr\@:
	endm


do_Sflag_routine macro	;message class, SHORT jump to  routine
	cmp.l	#\1,d0
	bne.s	dfr\@
	bra	\2	;jmp	\2
dfr\@:
	endm



CheckIDCMP:	;returns a0=msgptr, d0=class, a6=ExecBase ZERO FLAG too
;compositepaint;tst.L	GWindowPtr_(BP)	;july05,1990....not truly needed?
;compositepaint;beq.s	ciRTS

	move.l	MsgPtr_(BP),d0
	bne.s	gotone		;'short bra' NOT taken 8 cy vs 10 for taken
	;move.l	$0004,a6	;Exec base
	move.l	ExecLibrary_(BP),a6	;Exec base cached in (fastmem) basepage JUNE
portck:	moveq	#0,d0		;no m'class if empty port...
	lea	OnlyPort_(BP),a0
 	lea.l	MP_MSGLIST(a0),a1
	cmpa.l	8(a1),a1
	bne.s	dogm		;do a get msg (10cy bra vs 8cy nobra)
ciRTS:	RTS 			;(zero) OR (notzero and)(A0=MsgPtr, D0=CLASS)


dogm:	CALLIB	SAME,GetMsg	;look for a message d0=null if no mesg.
	move.l	d0,MsgPtr_(BP)	;ptr to unknown type message
	beq.s	ciRTS		;no msg, get outta here

gotone:	move.l	d0,a0
	move.l	im_Class(a0),d0
	cmp.b	#NT_REPLYMSG,LN_TYPE(a0) ;=NT_REPLYMSG back from PRINTER?
	beq.s	hndprt		;handle print
	RTS

hndprt:	clr.l	MsgPtr_(BP)	;ensure we never return a mesg 2x
	xjsr	EndPrint	;printrtns.o ;a1=arg=*msgprtr END (1) PRINTOUT

	subq.B	#1,PrintCopies_(BP)	;just printed one, need more?
	ble.s	done_prt
	st	FlagNeedText_(BP)	;main loop...causes redisplay of text
	xjsr	InitPrint	;restart another "print to printer"
	bra.s	portck		;no saved msg, any new ones come in?

done_prt:
	move.l	#'Pcca',ActionCode_(BP)	;print / cancel now endzit
	RTS

ScanIDCMP:	;d1=i'class to look for, returns ZERO found, notequal for notfnd
	lea	OnlyPort_(BP),A0	;my port's on my base page, easy, quick.
	lea	MP_MSGLIST(A0),A0	;TOP of list
	cmp.l	8(A0),A0		;empty?
	bne.s	scnloop		;not empty, scannit
bumscn:	moveq	#-1,d0		;set Not Equal, "not found"
	RTS
scnloop	move.l	(A0),D0		;LN_SUCC(A0), next (this) message
	beq.s	bumscn		;...note:im_Class, in a rexxmsg, is an address
	move.l	D0,A0		;A0=ptr to intuimessage

	tst.l	(A0)		;last node on list?  AUG161990
	beq.s	bumscn		;done....no more nodesAUG161990

	move.l	LN_NAME(a0),d0
	beq.s	ckclass_a0	;noname on msg...assume a0=intuimsg ptr
	exg.l	a0,d0		;after exg, d0=msgptr, a0=nameptr

	cmp.b	#'R',(a0)+
	beq.s	ckremote
ckclass_d0:
	move.l	d0,a0		;a0=this (not intui-) msg
ckclass_a0:
	cmp.l	im_Class(A0),D1	;ASSUMing intuimsg, = scanfor type?
	bne.s	scnloop		;keep checking, 'till end of list
	RTS			;outta here with ZERO equal, found it

ckremote:
	cmp.b	#'E',(a0)+
	bne.s	ckclass_d0

	cmp.b	#'M',(a0)+
	bne.s	ckrexx
	cmp.b	#'O',(a0)
	bne.s	ckclass_d0

	move.l	d0,a0		;a0=this (not intui-) msg
	bra.s	scnloop		;restart scan at next msg after a0

ckrexx:
	cmp.b	#'X',(a0)+
	bne.s	ckclass_d0
	cmp.b	#'X',(a0)
	bne.s	ckclass_d0
	move.l	d0,a0		;a0=this (not intui-) msg
	bra.s	scnloop		;restart scan at next msg after a0

* following is the "grand master message handler"
 	xref	RexxResult1_
Process_IDCMP_Mesg:  	;already did "GetMesg", pointer is in MsgPtr
	move.l	MsgPtr_(BP),d0
	beq	ciRTS 		;just an RTS...anRTS, ;nothing to do...
	move.l	d0,a0		:a0= message ptr
	move.l	im_Class(a0),d0 :d0= message class
	clr.l	LastItemAddress_(BP)	;'last gadget pressed'=none

	move.l	LN_NAME(a0),d1	;node name on msg
	beq	notcmd		;(technicly not intuim' if no name)
	move.l	d1,a1
	cmp.b	#'R',(a1)+	;Allowed names: REMO{anything} and REXX[null]
	bne	notcmd
	cmp.b	#'E',(a1)+
	bne	notcmd
	cmp.b	#'X',(a1)+
	bne	ckremo	;notcmd
	cmp.b	#'X',(a1)+
	bne	notcmd
	tst.b	(a1)		;name ends with [null] ?
	bne	notcmd		;not proppa name
;NOV91	cmp.l	#RXCOMM,rxm_Action(a0)	;assuming rex-type, is it cmd sub-type?
;only the top byte contains 'rxcomm', the rest are flag bits NOV91
;cmp.b	#RXCOMM>>24,rxm_Action(a0)	;assuming rex-type, is it cmd sub-type? NOV91
;RXCOMM.l=$01xx 0000      xx=extra flag bits
	cmp.b	#$01,rxm_Action(a0)
	bne	notcmd		;not a 'command line'
;NO NEED?;tst.w	2+rxm_Action(a0)
;NO NEED?;bne.s	notcmd		;not a 'command line'

;handle message from port named 'REXX',0
	move.l	rxm_Args(a0),d1	;rexx arg string?
	beq	notcmd		;no ptr
	move.l	d1,a1
	move.l	(a1),d0		;the 1st 4 ascii
	move.l	a0,-(sp)	;save msg ptr
	DUMPMEM	<a0=message at start of DoAction>,(A0),#64
	bsr	DoAction	;returns d0=0 if ok, else same code if notfnd
	movea.l	(sp)+,a0	;(moveA doesnt affect ZERO)
	bne.s	didrxok		;ne if found, if found, AC gets clrd
	moveq	#20,d1		;rx fail code
	clr.l	rxm_Result2(a0)	;secondary code
	bra.s	didrx
didrxok	tst.l	RexxResult1_(BP)	;did I find anything to report in RC?
	beq	202$
	move.l	RexxResult1_(BP),rxm_Result1(a0)
	move.l	#0,RexxResult1_(BP)
	beq	notRexxReq
202$
	movem.l	d0-d4/a0-a6,-(sp)
	tst.l	RexxResult_(BP)				;Some things return ok but have no string to return 
	bne	353$					;make a string for them
	lea	OkString,a0	
	moveq	#3,d0					;length of OK0 string
	CALLIB	Rexx,CreateArgstring
	move.l	d0,RexxResult_(BP)			;'ok' code
	movem.l	(sp)+,d0-d4/a0-a6
353$
	moveq	#0,d1
	move.l	RexxResult_(BP),rxm_Result2(a0)		;secondary code
	move.l	#0,RexxResult_(BP)			;clean house
didrx:	move.l	d1,rxm_Result1(a0) ;primary result
	DUMPMSG	<REXXHERE>
	tst.b	FlagRexxReq_(BP)			;check to see if arexx filereq is active.
	beq	notRexxReq
	rts
notRexxReq:
	bra	ReturnMessage
	;RTS

ckremo:	;found 'r' 'e' look for 'm' 'o' (finish scanning name 'REMO')
	cmp.b	#'M',-1(a1)		;last char (we scanned past it...)
	bne.s	notcmd
	cmp.b	#'O',(a1)+
	bne.s	notcmd
	lea	(4+MN_SIZE)(a0),a1	;a1msg= exec msg + ('REMO') +cmd str

;a0=msgptr, a1=text msg ptr
	move.l	(a1),d0		;the 1st 4 ascii
	move.l	a0,-(SP)	;save action code, msg ptr
	bsr	DoAction	;returns d0=0 if ok, else same code if notfnd
	movea.l	(SP)+,a0	;(moveA doesnt affect ZERO)
	bne.s	didok ;cmd	;ne if found, if found, AC gets clrd
	move.l	#'FAIL',d1
	bra.s	didcmd
didok:	move.l	#'OK  ',d1	;ascii return code
didcmd:	move.l	d1,(4+MN_SIZE)(a0)	;change 1st 4chars of msg 2b OK/FAIL
	bra	ReturnMessage
	;RTS

notcmd:
	move.l	im_IDCMPWindow(a0),d2	;d2=window-of-msg (dobtn, domsmv)
	move.l	d2,LastM_Window_(BP)	;mainloop, activate,april15

;SEP171990....kill 'in progress line-mode-drawing'
;...if from hires...
	xref	LineEndsPtr_
	tst.l	LineEndsPtr_(BP)	;line drawing in progress?
	beq.s	notfromhires
	cmp.l	GWindowPtr_(BP),d2	;from hires? SEP171990
	bne.s	notfromhires
	movem.l	d0-d2/a0/a1,-(sp)
	xjsr	KillLineList	;drawb.mode.i
	xjsr	CopySuperScreen	;remove 'temporary' linedraw display
	sf	FlagNeedRepaint_(BP)
	movem.l	(sp)+,d0-d2/a0/a1
notfromhires

	;NOTE: it is up to EACH routine to call ReturnMessage
	do_flag_routine MOUSEMOVE,DoMouseMove	;$0010	;mousertns.o
	do_flag_routine MOUSEBUTTONS,DoButton	;$0008	;mousertns.o
;may14;	do_Sflag_routine ACTIVEWINDOW,DoActWin
	do_Sflag_routine GADGETUP,DoGadgets	;$0040	;gadgetrtns.o
	do_Sflag_routine GADGETDOWN,DoGadgets	;$0020
	do_Sflag_routine MENUPICK,DoMenuPick	;$0100
	;do_Sflag_routine DISKINSERTED,DoDiskInsert	;march31'89

	cmp.l	#RAWKEY,d0
	beq	KeyRoutine		;main.key.i

	cmp.l	#CLOSEWINDOW,d0	;from magnify, mcbwindow, sizer, etc
	bne.s	notmcb

;;	move.l	#'Endm',ActionCode_(BP)	;"END Magnify" action code
;	st	FlagCheckKillMag_(BP)	;may12'89
	move.l	#'Endm',ActionCode_(BP)	;"END Magnify" action code JULY03

	bra.s	ReturnMessage

notmcb:
	cmp.l	#MENUVERIFY,d0
	beq	DoMenuVerify

; unknown msg(=a0) class(=d0)
; if   SPECIAL MESSAGE bottom word=$ffff, topword="function number"
; then fill in message with nice stuff  GENERIC 'where are/am you/I?"

	cmpi.W	#$ffff,d0	;special case, top bits for (future) functions
	bne.s	ReturnMessage
	lea	UnDoBitMap_(BP),a1		;calc basepage adr, fastmem
	move.l	a1,im_IDCMPWindow(a0)		;APTR undo bitmap
	move.l	BP,im_SpecialLink(a0)		;APTR BasePage
	move.l	XTScreenPtr_(BP),im_IAddress(a0) ;APTR hires screen
	move.W	BigPicWt_W_(BP),im_MouseX(a0)	;WORD x bitmap wt
	move.W	BigPicHt_(BP),im_MouseY(a0)	;WORD y bitmap ht
	move.l	ScreenPtr_(BP),im_Seconds(a0)	;LONG bigpicscreen
	move.l	TScreenPtr_(BP),im_Micros(a0)	;LONG im_Micros

ReturnMessage:
	move.l	MsgPtr_(BP),d0	;current msg
	beq.s	endof_qrm	;no message waiting 2b returned
	lea	FakeActionMsg_(BP),a1
	clr.l	MsgPtr_(BP)	;clear out saved msg now
	cmp.l	d0,a1		;this msg=fake//key msg?
	beq.s	endof_qrm	;DONT return fake msg
	move.l	d0,a1		;msgptr to return
	JMPLIB	Exec,ReplyMsg	
endof_qrm:
	RTS


DoGadgets:	;Process GADGETDOWN and GADGETUP classes of messages
;A0=message ptr (note:NOT returned yet, return after "recognized")
;D0=im_Class field of this message ;must call ReturnMsg
	move.l	im_MouseX(a0),MSG_MouseX_(BP) 	;KEEP MOUSEXY HANDY!

	move.l	LastM_Window_(BP),d4
	beq.s	1$
	cmp.l	ToolWindowPtr_(BP),d4	;last msg from hamtools?
	bne.s	1$
	st	FlagNeedHiresAct_(BP)
1$
	cmp.l	#GADGETDOWN,d0
	seq	FlagGadgetDown_(BP)	;used by pointers...
	bne.s	dogadgup

;june12...
;dont set flaggadgetdown if just a slider...
	move.l	im_IAddress(a0),a1	;a1=*gadget
	cmp.w	#3,12(a1) ;#PROPGADGET,gg_Type(a1)	;'down' from a propgadget?
	bne.s	123$
	sf	FlagGadgetDown_(BP)	;clear/reset flag if from a propgad
123$
	move.b	FlagCtrlText_(BP),d0
	or.b	FlagPale_(BP),d0
	or.b	FlagCtrl_(BP),d0
	bne.s	009$
	tst.w	FlagOpen_(BP)		;open.b, save.b,  file req displayed?
	bne.s	009$
	move.l	a0,-(sp)		;STACK msgptr

;MAY16...special for brush sizer stuff
	tst.l	PasteBitMap_Planes_(BP)	;have a custom/cutout brush?
	beq.s	007$			;no....skip this
	move.l	(sp),a0
	move.l	im_IAddress(A0),D0	;pointer to Gadget from GADGETUP mesg.
	beq.s	enda_dogadgets		;d0=0=no gadget
	move.l	d0,a0			;gadget ptr from message
	move.l	gg_UserData(a0),d0	;4 byte action code
	beq.s	008$ ;enda_dogadgets		;d0=0=no action, return the gadget msg
	move.l	d0,d1
	and.l	#$ffffff00,d1		;check for 'Bsz?'
	cmp.l	#('Bsz'<<8),d1
	bne.s	008$
	move.l	d0,ActionCode_(BP)
	move.l	a0,LastItemAddress_(BP)	;dirrtns use for filename str's

	bsr	DoAction		;ggggrrrrross!..but oh well, ship the mother...
007$
;MAY90	xjsr	ClearBrushImagery	;bgadrtns.o, clears imagery on hires
	xjsr	UpdateBrszGads		 ;tool.code.i, deselect bszn gadgets
	st	FlagGadgetDown_(BP)	;used by pointers...NEEDED oh my....
008$
	move.l	(sp)+,a0		;deSTACK msgptr

009$
	bra	ReturnMessage


dogadgup:
	move.l	im_IAddress(A0),D0	;pointer to Gadget from GADGETUP mesg.
	beq.s	enda_dogadgets		;d0=0=no gadget
	move.l	d0,a0			;gadget ptr from message
	move.l	gg_UserData(a0),d0	;4 byte action code
	beq.s	enda_dogadgets		;d0=0=no action, return the gadget msg
	move.l	d0,ActionCode_(BP)
	move.l	a0,LastItemAddress_(BP)	;dirrtns use for filename str's
enda_dogadgets:
	bra	ReturnMessage



DoMenuPick:	;d0=#MENUPICK, a0=msgptr, SIMPLY setup ActionCode from MenuItem
		;SPLIT out menu#, item# from message info

	move.w	im_Code(a0),d0	;menu number code from IDCMP message
	cmpi.W	#$ffff,d0	;menunull code?
	beq.s	enda_dmp	;same as bra.s enda_domenupick

	move.l	im_IDCMPWindow(a0),d1	;window this (idcmp) msg came from
	beq.s	enda_dmp	;wha? no window, not an intuimsg?
	move.l	d1,a0
	move.l	wd_MenuStrip(a0),d1
	beq.s	enda_dmp	;wha? no menu on window
	move.l	d1,a0		;a0=menu struct ptr, D0=im_Code
	CALLIB	Intuition,ItemAddress
	tst.l	d0
	beq.s	enda_dmp	;wha? no item found, outta here
	move.l	d0,a0		;a0=menu_item_adr result from intuition

;	move.l	mi_SIZEOF(a0),ActionCode_(BP) ;grab code from END of mi struct

;JUNE121990...
;allow up to 6 action codes per menu item
	lea	mi_SIZEOF(a0),a0
	move.w	#6,-(sp)	;looop counter

maction_loop:
	tst.l	4(a0)		;next one a zero?
	beq.s	endmaction	;yep...logical "stack" of action code

	move.l	(a0)+,d0
	move.l	a0,-(sp)
	bsr	DoAction	;do action code d0
	move.l	(Sp)+,a0

	subq.w	#1,(sp)
	bne.s	maction_loop

endmaction:
	addq.w	#2,sp		;remove loop counter
	move.l	(a0),ActionCode_(BP)	;next/only/last action code

enda_dmp:				;end of 'do menu pick'
;JULY261990...restore white font after menus
;	move.l	WhiteFont,a0
;	move.l	XTScreenPtr_(BP),a1
;	lea	sc_RastPort(a1),a1
;	CALLIB	Graphics,SetFont
;;AUG091990;move.l	WhiteFont,a0
;;AUG091990;move.l	GWindowPtr_(BP),a1
;;AUG091990;move.l	wd_RPort(a1),a1
;;AUG091990;CALLIB	Graphics,SetFont

	st	FlagNeedGadRef_(BP)	;need 'new' hires display (gadgets-soon)
	sf	FlagMenu_(BP)	;intuition is "done with menu" display
	st	FlagFrbx_(BP)	;june13, gets screen re-arrange apro' time
	bra	ReturnMessage		;rtn MENUPICK AFTER scrn re-arrange june13

;29JAN92;	;do a "delay" to give intuition time to de-allocate memory (?) 29JAN92
;29JAN92;bsr	ReturnMessage		;rtn MENUPICK AFTER scrn re-arrange june13
;29JAN92;moveq	#4,d0
;29JAN92;moveq	#4,d1
;29JAN92;CALLIB	DOS,Delay
;29JAN92;xjsr	CleanupMemNoWb		;memories.asm

	;RTS

	xref FlagPrintReq_	;print requester?
	xref FlagPrinting_	;printing in progress status
	xref FlagLine_
	xref LineEndsPtr_
	xref FlagSizer_		;"screen sizer" requester?
	xref FlagRequest_

DoMenuVerify:
	sf	FlagNeedHiresAct_(BP)	;already active..no need now APRIL16
	cmp.w	#MENUCANCEL,im_Code(A0)	;pre-cancel'd? (like, stopped painting)
	beq	ReturnMessage		;pre-canceled...let it go

	tst.b	FlagPrintReq_(BP)	;printing?
	beq.s	printing_no
	tst.b	FlagPrinting_(BP)	;"really" running the printer (now?)
	bne	docancel_front
	move.l	#'Pcca',ActionCode_(BP)	;print cancel (just like cancel buttn)
	bra	docancel_front		;cancel menuverify, then print-action

printing_no:
;screen sizer?
	tst.b	FlagSizer_(BP)
	beq.s	sizing_no
	tst.l	ScreenPtr_(BP)		;have a 'bigpic?'
	beq.s	sizing_no		;allow menus in sizer (when no scr)
	move.l	#'Nsca',ActionCode_(BP)	;new size cancel (just like button)
	bra	docancel_front

sizing_no:
;palette/shrink request?
	tst.b	FlagRequest_(BP)	;"file-palette""hires""ok""cancel"
	beq.s	request_no
	bsr	docancel_front
	xjsr	EndPaleReq		;palereq.o
	xjsr	Close_Load_File

request_no:
;magnify scr sup?
	tst.l	MScreenPtr_(BP)
	beq.s	magmv_no 		;no mag screen?
	tst.b	FlagMagnifyStart_(BP)	;have mag screen, 'locked' yet?
	bne.s	magmv_no
	bsr	docancel_front		
	st	FlagCheckKillMag_(BP)
	rts

magmv_no:
;WAIT! want to verify, BUT, check for linemode stuff
	tst.b	FlagLine_(BP)		;line mode?
	beq.s	line_mv_end
	tst.l	LineEndsPtr_(BP)	;DRAWING lines, anyway?
	beq.s	line_mv_end

	bsr	docancel_front		;april21...was just docancel

	st	FlagNeedHiresAct_(BP)
	tst.b	FlagCutPaste_(BP)
	bne.s	5$
	xjmp	RePaint			;"draw lines"
5$	xjmp	CutorPaste
line_mv_end:


 ifeq 1
	;no need;;move.l	IntuitionLibrary_(BP),a6
	move.l	FirstScreen_(BP),d1	;ib_FirstScreen(a6),d1
	cmp.l	XTScreenPtr_(BP),d1	;hires screen in front?
	beq.s	wannav			;yea...menu if hires already in front
 endc



docancel_front:
	;;sf	FlagMenu_(BP)		;intuition is "done with menu" display SEP011990
	;;xjsr	EndFileRequ		;gadgetrtns.o...SEP011990...helps w/toolposnormal&slider screen bug

	DUMPMSG	<MOVE.W #MENUCANCEL,im_Code(A0)>	
	move.w	#MENUCANCEL,im_Code(A0)		;cancel, then do "front box"
	bsr	ReturnMessage			;return verify msg type asap
	bsr	DoInlineAction			;do as if user hit 'frontbox'
	;;;dc.w	'Cl'	;SEP011990....'closebox', not 'front box'...'Fr'
	dc.w	'Fr'
	dc.w	'bx'
	bra	SetDefaultPriority	;april26'89
	;RTS


wannav:
	st	FlagMenu_(BP)	;indicates "menu verified no menupick yet" MAY1990
;	xjsr	CloseSkinny	;mousertns.o, kills 'rgb' display (if any) MAY1990
	xjsr	EndFileRequ		;gadgetrtns.o
	xjsr	RemoveXGadgets	;APRIL12'89...elims grodiness on topline
	;MAY1990;xjsr	CloseSkinny	;mousertns.o, kills 'rgb' display (if any)
	bsr	_EnsureExtraChip
	bne.s	gotx_goforit

	xjsr	UnShowPaste	;JUNE05...helps with paste/undo/copy-to-swap
	;30JAN92;xjsr	FreeDouble	;kill double buffer (if any)
	bsr	_EnsureExtraChip
	bne.s	gotx_goforit
	xjsr	FreeDouble	;kill double buffer (if any)

	st	FlagCheckKillMag_(BP)

	xref FlagCloseWB_
	move.b	FlagCloseWB_(BP),d0	;close hamtools for menu
	move.w	d0,-(sp)
	st	FlagCloseWB_(BP)
	xjsr	CleanupMemory	;else just re-organize (maybe kill hamtools)
	move.w	(sp)+,d0
	move.B	d0,FlagCloseWB_(BP)


gotx_goforit:
	;JULY261990...place black font for menus
	;;AUG091990;xref BlackFont	;DefaultFont.asm
	;;AUG091990;xref WhiteFont	;DefaultFontWhite.asm
	;move.l	BlackFont,a0
	;move.l	XTScreenPtr_(BP),a1
	;lea	sc_RastPort(a1),a1
	;CALLIB	Graphics,SetFont
	;;AUG091990;move.l	BlackFont,a0
	;;AUG091990;move.l	GWindowPtr_(BP),a1
	;;AUG091990;move.l	wd_RPort(a1),a1
	;;AUG091990;CALLIB	Graphics,SetFont
	;MAY1990;st	FlagMenu_(BP)	;indicates "menu verified no menupick yet"
	;sup HiresForMenu
	moveq	#6,d0			;frame # "hires menu imagery"
	xjsr	ShowGadFrame		;showgads.o, 'frame' from gad'picture
;21JAN92...only show text on menu screen ONCE
	sf	FlagMenu_(BP)		;clear flag so next call shows "menu" stuff
	xjsr	ReallyDisplayText	;showtxt.o
	st	FlagMenu_(BP)		;really want this set
	xjsr	ForceSkipScroll	;repaint.asm, xdef'd for screenmoves....SEP171990
;;later, digipaint pi;xjsr	ReallyDisplayText	;do text BEFORE m-verify return





  IFC 't','f' ;digipaint pi....moving of menu screen
		;code correctly computes "ns_ new screen struct"
		; for a temporary "screen below hires"
		; it also moves the hires screen up/down (ok)
;	move.l	GWindowPtr_(BP),A0
;	move.l	wd_Pointer(A0),A0
;	lea	PointerTo_data,a1	;go pc relative, save on loading (not absolute)
;	cmpa.l	a1,A0		;"To" pointer-from-window ?
;	beq.s	mvRTS		;leave "copy color to" pointer sup
;	xjsr	ClearPointer	;...then does 'stacked' return msg
;mvRTS:
	;;bsr	SaveTopBar	;save 'top 10 lines' of picture
		;digipaint PI...
	;digipaint PI....SETUP 'dummy' screen for view-below-hires
	move.l	TempScreenPtr_(BP),d0
	bne	old_menudone		;HAVE a 'tempscreen'
	move.l	XTScreenPtr_(BP),A0
	moveq	#0,d0			;dummy 'screenptr' to get stacked
	moveq	#0,d1
	move.w	sc_MouseY(a0),d1	;mouse 'above' hires screen?
	bpl	old_menudone ;stacknewscreen		;no..."on" hires...no new window
	add.w	sc_TopEdge(a0),d1
hiresvert set 53	;#lines 'gap' for hires/menu screen ht
	add.w	#hiresvert,d1
	tst.b	FlagLace_(BP)	;interlace, now?
	beq.s	88$
	add.w	d1,d1		;double top offset
88$:
	cmp.w	#hiresvert,d1		;enough room at top for menu?
	bcc.s	89$
	move.w	#hiresvert,d1
89$
	cmp.w	BigPicHt_(BP),d1	;going 'below' a short screen?
	bcs.s	old_menudone		;yep...no 'temp screen'
	lea	BigNewScreen_(BP),A0	;A0=newscreen struct for 'big picture'
	move.w	d1,ns_TopEdge(a0)
showtitle	 EQU	$0010
temp_flags equ showtitle!CUSTOMSCREEN!CUSTOMBITMAP!SCREENQUIET
	move.w #SCREENBEHIND!temp_flags,ns_Type(A0)
	lea	ScreenBitMap_(BP),a1
	move.l	a1,ns_CustomBitMap(A0)
	move.l	ScreenPtr_(BP),a2	;bigpicture
	lea	sc_ViewPort(a2),a2
	move.l	vp_RasInfo(a2),a1	;a1=rasinfo
	move.w	BigPicHt_(BP),d1
	sub.w	ns_TopEdge(a0),d1
	sub.w	ri_RyOffset(a1),d1	;d1=current y offset
	bmi.s	stacknewscreen		;no screens with negative ht
	move.w	d1,ns_Height(a0)
	cmp.w	#11,d0
	bcc.s	stacknewscreen		;ht <11....don't bother
	move.l	a0,-(sp)
	bsr	SaveTopBar		;save 'top 10 lines' of picture
	move.l	(sp)+,a0
	moveq	#0,d0			;temp screenptr, null if invalid
	tst.l	Temp10Data_(BP)		;did save happen?	
	beq.s	stacknewscreen
	
;	DUMPMSG <Before open bigscreen>	
	CALLIB	Intuition,OpenScreen	
;	DUMPMSG	<After open bigscreen>
	

stacknewscreen:
	move.l	d0,TempScreenPtr_(BP)
	beq.s	nonewscreen
	bsr	RestoreTopBar		;put back 'saved data' from top of pic
	move.l	TempScreenPtr_(BP),a0	;new little screen
	lea	sc_ViewPort(a0),a0	;viewport struct inside screen struct
	xref    BigPicColorTable_
	lea	BigPicColorTable_(BP),a1
	moveq	#16,d0
		CALLIB	Graphics,LoadRGB4
	move.l	TempScreenPtr_(BP),a0
	moveq	#0,D0			;false argument
	CALLIB	Intuition,ShowTitle	;hides the Screen title bar
	;;bsr	RestoreTopBar		;put back 'saved data' from top of pic
	move.l	TempScreenPtr_(BP),a0
	;DONT TRACK THIS...;xjsr	IntuScreenToFront ;CALLIB	Intuition,ScreenToFront	;"show" it...without upper left corner glitch
	CALLIB	Intuition,ScreenToFront	;"show" it...without upper left corner glitch

	move.l	ScreenPtr_(BP),a2	;bigpicture
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	move.w	ri_RxOffset(a1),d2	;d2=current x offset (ends up in d0...)
	move.w	ri_RyOffset(a1),d1	;d1=current y offset

	move.l	TempScreenPtr_(BP),a2	;screen "under" menu/hires screen
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	move.w	d2,ri_RxOffset(a1)	;d2=current x offset (ends up in d0...)
	add.w	sc_TopEdge(a2),d1	;lower screen's data, offset this amt
	move.w	d1,ri_RyOffset(a1)	;d1=current y offset
	move.w	d2,d0			;x scroll
	CALLIB	Graphics,ScrollVPort
	bsr	RestoreTopBar		;put back 'saved data' from top of pic
nonewscreen:
	;	;sup HiresForMenu
	;moveq	#6,d0			;frame # "hires menu imagery"
	;xjsr	ShowGadFrame		;showgads.o, 'frame' from gad'picture
		;digipaint PI....move hires so menu is under the pointer
	move.l	XTScreenPtr_(BP),A0
	moveq	#0,d1
	move.w	sc_MouseY(a0),d1	;mouse 'above' screen?
	;bpl.s	5$
	bmi.s	4$
	pea	old_menudone(pc)	;finish old way...with returnmessage//wait
	bra.s	5$
4$	ext.l	d1
	moveq	#0,d0			;zero x move (illegal, anyway)
	movem.l	d0/d1/a0,-(sp)
*	CALLIB	Intuition,MoveScreen
	bsr.s	old_menudone		;finish old way...with returnmessage//wait
	moveq	#-1,D0		;indicate signal set of all//any
	CALLIB	Exec,Wait	;YETCH.....WAIT ON MENU EVENT???
	;;st	FlagNeedIntFix_(BP)	;calls for RethinkDisplay, apro time
	movem.l	(sp)+,d0/d1/a0
	neg.l	d1			;move hires/menu screen back down
*	CALLIB	Intuition,MoveScreen
5$
	rts
old_menudone:
   ENDC ;digipaint pi....moving of menu screen


	move.l	GWindowPtr_(BP),A0
	move.l	wd_Pointer(A0),A0
	lea	PointerTo_data,a1	;go pc relative, save on loading (not absolute)
	cmpa.l	a1,A0		;"To" pointer-from-window ?
	beq.s	mvRTS		;leave "copy color to" pointer sup
	
	tst.b	FlagCopyColor_(BP)
	bne	.copycolor
	xjsr	ClearPointer	;...then does 'stacked' return msg
.copycolor
mvRTS:
	;	;sup HiresForMenu
	;moveq	#6,d0			;frame # "hires menu imagery"
	;xjsr	ShowGadFrame		;showgads.o, 'frame' from gad'picture
;; test only	xjsr	ReallyDisplayText	;do text BEFORE m-verify return (digipaint pi)
	bra	ReturnMessage	;SENDBACK mv now, before alloc/frees? APRIL16
	;RTS			;stacked rtnmsg address, go do it DISPLAYS MENU

  IFC 'T','F'	;JULY141990...code never called...
	xref TempScreenPtr_	;'slice' of bigpicture below hires/menu
	xref Temp10Data_	;ptr to top 10 lines


SaveTopBar:		;save 'top 10 lines' of picture
	move.l	bytes_per_row_(BP),d0
	mulu	#11,d0			;* 11 rows
	move.l	d0,-(sp)
	mulu	#6,d0			;10 bitplanes

	xjsr	IntuitionAllocMain	;memories.o
	move.l	d0,Temp10Data_(BP)	;none?
	beq.s	save_end
	move.l	d0,a1
	lea	ScreenBitMap_Planes_(BP),a2
	moveq	#6-1,d1
savetop:
	move.l	(a2)+,a0	;from (screen bitplane) adr
	move.l	(sp),d0		;#bytes to copy
	xjsr	QUICKCopy 	;d0=count, a0=from adr a1=to adr (memories.asm)
	add.l	(sp),a1		;bump 'to' pointer
	dbf	d1,savetop
save_end:
	addq	#4,sp	;remove 'planesize' temp
	rts


RestoreTopBar:		;put back 'saved data' from top of pic
	move.l	bytes_per_row_(BP),d0
	mulu	#11,d0			;* 11 rows
	move.l	d0,-(sp)
	move.l	Temp10Data_(BP),d0	;none?
	beq.s	rest_end
	move.l	d0,a0
	lea	ScreenBitMap_Planes_(BP),a2
	moveq	#6-1,d1
resttop:
	move.l	(a2)+,a1	;to (screen bitplane) adr
	move.l	(sp),d0		;#bytes to copy
	xjsr	QUICKCopy 	;d0=count, a0=from adr a1=to adr (memories.asm)
	add.l	(sp),a0		;bump 'from' pointer
	dbf	d1,resttop
rest_end:
	addq	#4,sp	;remove 'planesize' temp
	rts
  ENDC	;JULY141990...code never called...


_EnsureExtraChip:
	DUMPREG	<_EnsureExtraChip>
	xjmp	EnsureExtraChip	;memories.o, rtns ZERO =ifnomem, not=ifok


ResetIDCMP:	;sets up "normal" idcmp message types
	move.l	IntuitionLibrary_(BP),a6	;sup for mod'idcmp call

	move.l	MCBWindowPtr_(BP),a0	;magnify closebox
	move.l	#CLOSEWINDOW,d0		;*only* code here
	bsr	call_modidcmp

	move.l	MWindowPtr_(BP),a0	;magnify painting window (11lines down)
	bsr.s	drawing_idcmp

	move.l	WindowPtr_(BP),a0
	bsr.s	drawing_idcmp

	move.l	ToolWindowPtr_(BP),a0	;ham palette/tools
	move.l	#TOOLIDCMP,d0
	bsr	call_modidcmp	;a0=*window d0=idcmp flags=message types desired

	move.l	GWindowPtr_(BP),a0	;hires gadgets window

		;SEP081990...if "alt snooze pointer", then no menustuff
	xref	AltPointerSnz_data	;SEP081990...for "reset idcmp"
	move.l	wd_Flags(a0),d1		;turn OFF 'rmbtrap' status
	and.l	#~RMBTRAP,d1		
	move.l	d1,wd_Flags(a0)
	move.l	#AltPointerSnz_data,a1
	cmp.l	wd_Pointer(a0),a1
	beq.s	66$

	move.l	#GWIDCMP,d0
	tst.b	Initializing_(BP)
	beq.s	77$ 			;call_modidcmp
66$:	and.l	#~MENUVERIFY,d0		;no 'verifies' if just starting
	move.l	wd_Flags(a0),d1		;turn ON 'rmbtrap' status
	or.l	#RMBTRAP,d1
	move.l	d1,wd_Flags(a0)
77$:
	tst.l	ScreenPtr_(BP)		;bigpic opened?
	beq.s	nomoves_hires ;ne.s	havescr ;call_modidcmp

	tst.W	FlagOpen_(BP)
	beq.s	call_modidcmp
nomoves_hires:				;else, rem m-moves if filereq, no scr
	and.l	#~MOUSEMOVE,d0		;no m'moves from anywhere if no scr
	bra.s	call_modidcmp

	xref FlagSetGrid_		;if setting up grid... DigiPaint PI

drawing_idcmp:
	move.l	#BPIDCMP,d0		;long idcmp codes
	tst.b	FlagPick_(BP)		;WANT moves if in pick mode
	bne.s	call_modidcmp
	tst.b	FlagSetGrid_(BP)	;WANT moves if setting up grid DigiPaint PI
	bne.s	call_modidcmp
	tst.l	PasteBitMap_Planes_(BP)
	beq.s	call_modidcmp
	tst.b	FlagMagnify_(BP)	;magnify alive?
	beq.s	21$
	tst.b	FlagMagnifyStart_(BP)	;magnify started?
	beq.s	call_modidcmp		;mag but not locked, do use moves
21$	and.l	#~MOUSEMOVE,d0		;no m'moves from anywhere if no scr

call_modidcmp:	;a0=*window d0=idcmp flags=message types desired
	cmp.l	#0,a0			;no window arg? bum call?
	beq.s	endi			;wa?!...no window bomb shelter
	tst.l	d0			;no msg types arg? bum call? DONT CLOSE
	beq.s	endi			;wa?!...no window bomb shelter
	lea	OnlyPort_(BP),a1	;"our" port
	cmp.l	wd_IDCMPFlags(a0),d0	;got port, current mtypes ok?
	beq.s	endi			;yep...our msg types already comin'
newi:	move.l	a1,wd_UserPort(a0)	;"our" port
	JMPLIB	SAME,ModifyIDCMP	;a6=IntuitionLibrary
endi:	RTS



DoInlineAction:	;calling code, next 4 bytes contain the action code
	move.l	(sp),a0
	move.l	(a0)+,d0	;action code
	move.l	a0,(sp)		;fixed return address


	;note:action code d0=0 'falls thru', hits zero at end of actable (ok)
DoAction:	;ARG D0=ACTION CODE, RESULT=D0=same if err(notfnt),=0 if ok

	tst.b	FlagCapture_(BP)
	beq	nocapture

	move.l	d0,-(sp)
	cmp.l	#'Move',d0
	bne.s	doprintact

	move.l	LastM_Window_(BP),d0	;'last message' window
	cmp.l	GWindowPtr_(BP),d0	;=hires?
	beq	skipprintact		;no brushstroke active, (stack clup)
	tst.b	FlagNeedRepaint_(BP)	;drawing started?
	beq	skipprintact
	tst.L	FlagCirc_(BP)	;special mode? (line circ curv rect)
	bne	skipprintact	;yep...skip mova

doprintact:	;stack.4 ='Xxxx' ascii action code
	move.l	StdOut_(BP),d1 ;CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	D1,-(sp)	;save 'stdout' file handle
	beq	doneprint		;noprint if no stdout (run from wbench?)

	lea	NOTICE(pc),a2
	move.l	a2,d2		;d2='cr,lf,...'
	moveq.l	#1,d3 ;#NOTICELen,d3	;d3=length of 'cr,lf...'
	bsr	_DosWrite	;CALLIB	DOS,Write	;>>>print it

	move.l	(sp),d1		;d1=output file handle
	lea	4(sp),a2	;adr of 4byte ascii action-code
	move.l	a2,d2		;d2=adr to print (a-code ascii)
	moveq.l	#4,d3		;d3=length of string
	bsr	_DosWrite	;CALLIB	SAME,Write	;>>>print it

	move.l	4(sp),d0	;actioncode
	cmp.l	#'Move',d0
	beq.s	wannaprint	;printxy
	clr.B	d0		;strip last char of a-code
	cmp.l	#('Pen'<<8),d0	;'Penu' 'Pend' 'Pena'
	bne.s	doneprint
wannaprint:
	st	FlagPrintXY_(BP)
doneprint:
	lea	4(sp),sp	;stacked filehandle for dos,write
skipprintact:
	move.l	(sp)+,d0	;stacked action code
nocapture:

	MOVE.L	#ACTable,a2	;A2=Action code table of (_Code_.L,OFFSET.W)
	move.l	a2,a1		;A1=same thing, but this ptr moves thru table
ckact:	move.l	(a1)+,d1
	beq.s	eadoac		;enda table, leave with ZERO flag=fail
	cmp.l	d1,d0		;check against code in table
	beq.s	fndact
	lea	2(a1),a1	;skip adr offset in table
	bra.s	ckact

fndact:	move.w	(a1),d1		;code offset in table (from start of table)
	beq.s	eadoac		; ;bum end of table (coder!)
	jsr	0(a2,d1.w)	;compute addr, call this rtn (a2=begtbl)

	tst.b	FlagCapture_(BP)
	beq	skip_argprint

	xref FlagPrintRgb_
	xref FlagPrintString_
	xref FlagPrint1Value_
	xref FlagPrintXY_

	lea	FlagPrintRgb_(BP),a0
	tst.b	(a0)
	beq.s	10$
	sf	(a0)
	bsr	printrgb
10$
	lea	FlagPrintString_(BP),a0
	tst.b	(a0)
	beq.s	20$
	sf	(a0)
	bsr	printstring
20$
	lea	FlagPrint1Value_(BP),a0
	tst.b	(a0)
	beq.s	30$
	sf	(a0)
	bsr	print1value
30$
	lea	FlagPrintXY_(BP),a0
	tst.b	(a0)
	beq.s	40$
	sf	(a0)
	bsr	printxy
40$
skip_argprint:
	moveq	#-1,d0		;gotit ok, set notZERO
eadoac:	RTS			;ZERO if fail, notZERO when ok


printcolor:	macro ;color
	xref Paint\1_
	clr.l	-(sp)		;temp, 4blanks
	lea	(sp),a0
	moveq	#0,d0
	move.B	Paint\1_(BP),d0
	tst.l	Datared_(BP)	;june301990
	beq.s	pc4bit\@
	move.W	Paint8\1_(BP),d0	;8 bit paint color...
pc4bit\@:
	move.b	#' ',(a0)+	;"always" preface ## with a blank
	;june301990;xjsr	binaryByte_to_decimal	;showtxt.o
	xjsr	binaryint_to_decimal	;showtxt.o, 3 places....
		;d0=# to convert, a0 pts to where to stuff, MOVES a0 Ptr
	move.l	4(sp),d1	;d1=output file handle
	lea	(sp),a0
	move.l	a0,d2		;d2=ptr to ascii (on stack)
	moveq.l	#4,d3		;d3=length of string
	;CALLIB	SAME,Write	;>>>print it
	bsr DosWriteGoodLen	;a6=dosbase, d1,2,3 sup for write
	lea	4(sp),sp	;remove ascii from stack
  endm

printstring:	;kludge...need code to output 'last string'
	move.l	StdOut_(BP),d1	;CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	D1,-(sp)	;save 'stdout' file handle
	beq.s	nopsfileh	;noprint if no stdout (run from wbench?)
	xjsr	grab_arg_a0
	beq.s	nopsfileh	;noprint if no stdout (run from wbench?)

		;determine d3=len of str
	moveq	#0,d3
	move.l	a0,a1		;string from msg
	moveq	#64-1,d4	;maxlen
detlenloop:
	addq	#1,d3		;len to print
	move.b	(a1)+,d2	;char to print
	cmp.b	#$0d+1,d2	;value<cr/lf/or-zero?
	dbcs	d4,detlenloop	;decr, branch until carry set

	move.l	a0,d2		;d2=ptr to ascii (on stack)
	;moveq.l	#6,d3		;d3=length of string
;	CALLIB	SAME,Write	;>>>print it
	bsr DosWriteGoodLen	;a6=dosbase, d1,2,3 sup for write
nopsfileh:
	lea	4(sp),sp	;remove ascii from stack
	rts


printrgb:
	bsr.s	reallyprintrgb
	move.l	#'Prgb',-(sp)
	tst.l	Datared_(BP)	;rgb mode?...june301990
	beq.s	001$
	move.l	#'8rgb',(sp)
001$
	move.l	StdOut_(BP),d1	;CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	D1,-(sp)	;save 'stdout' file handle
	beq	donergbprint		;noprint if no stdout (run from wbench?)

	lea	NOTICE(pc),a2
	move.l	a2,d2		;d2='cr,lf,...'
	moveq.l	#1,d3 ;#NOTICELen,d3	;d3=length of 'cr,lf...'
	bsr	_DosWrite	;CALLIB	DOS,Write	;>>>print it

	move.l	(sp),d1		;d1=output file handle
	lea	4(sp),a2	;adr of 4byte ascii action-code
	move.l	a2,d2		;d2=adr to print (a-code ascii)
	moveq.l	#4,d3		;d3=length of string
	bsr	_DosWrite	;CALLIB	SAME,Write	;>>>print it

donergbprint:
	lea	4(sp),sp	;stacked filehandle for dos,write
	move.l	(sp)+,d0	;stacked action code (dummy 'Prgb')

	;bsr.s	reallyprintrgb
	;rts

reallyprintrgb:	;just digits
	move.l	StdOut_(BP),d1	;CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	D1,-(sp)	;save 'stdout' file handle
	beq	norgbfileh	;noprint if no stdout (run from wbench?)

	printcolor red
	printcolor green
	printcolor blue

norgbfileh:
	;bra.s	doneprint
	addq.l	#4,sp	;delete output handle
	rts	;printrgb

printxy:
	move.l	StdOut_(BP),d1	;CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	D1,-(sp)	;save 'stdout' file handle
	beq	noxyfileh	;noprint if no stdout (run from wbench?)
	xref LastDrawX_
	move.l	#('  '<<16),-(sp)	;temp:blank blank null null
	move.l	#'    ',-(sp)		;temp, 4blanks
	lea	(sp),a0
	moveq	#0,d0
	move.w	LastDrawX_(BP),d0
	move.b	#' ',(a0)+	;sup w/blank
	xjsr	binaryWord_to_decimal
		;d0=# to convert, a0 pts to where to stuff, MOVES a0 Ptr
	move.l	8(sp),d1	;d1=output file handle
	lea	(sp),a0
	move.l	a0,d2		;d2=ptr to ascii (on stack)
	moveq.l	#6,d3		;d3=length of string
;	CALLIB	SAME,Write	;>>>print it
	bsr DosWriteGoodLen	;a6=dosbase, d1,2,3 sup for write
	lea	8(sp),sp	;remove ascii from stack

	xref LastDrawY_
	move.l	#('  '<<16),-(sp)	;temp:blank blank null null
	move.l	#'    ',-(sp)		;temp, 4blanks
	lea	(sp),a0
	moveq	#0,d0
	move.w	LastDrawY_(BP),d0
	move.b	#' ',(a0)+	;sup w/blank
	xjsr	binaryWord_to_decimal
;d0=# to convert, a0 pts to where to stuff, MOVES a0 Ptr
	move.l	8(sp),d1	;d1=output file handle
	lea	(sp),a0
	move.l	a0,d2		;d2=ptr to ascii (on stack)
	moveq.l	#6,d3		;d3=length of string
;	CALLIB	SAME,Write	;>>>print it
	bsr DosWriteGoodLen	;a6=dosbase, d1,2,3 sup for write
	lea	8(sp),sp	;remove ascii from stack
noxyfileh:
	addq.l	#4,sp	;filehandle
	rts



binaryWord_to_hexout:
	move.W	#' $',(a0)+
	move.w	d0,-(sp)
	asr.w	#8,d0
	bsr.s	byteout
	move.w	(sp)+,d0
byteout:
	move.w	d0,-(sp)
	asr.w	#4,d0
	bsr.s	nybout
	move.w	(sp)+,d0
nybout:
	and.w	#$f,d0
	cmp.w	#$a,d0
	bcs.s	1$
	;addq	#7,d0
	add.w	#$27,d0	;7 is shift to alpha, $20 is go to lowercase
1$	add.w	#$30,d0
	move.b	d0,(a0)+	;ascii 0..9 a..f
	rts



print1value:
	move.l	StdOut_(BP),d1	;CALLIB	DOS,Output	;get file handle, already open (cli window)
	move.l	D1,-(sp)	;save 'stdout' file handle
	beq	novfileh	;noprint if no stdout (run from wbench?)

	xref PrintValue_
	clr.l	-(sp)		;temp, 4blanks
	clr.l	-(sp)		;temp, 8blanks total
	lea	(sp),a0
	;moveq	#0,d0
	move.L	PrintValue_(BP),d0
		;d0=# to convert, a0 pts to where to stuff, MOVES a0 Ptr
	bsr	binaryWord_to_hexout
	move.l	8(sp),d1	;d1=output file handle
	lea	(sp),a0
	move.l	a0,d2		;d2=ptr to ascii (on stack)
	moveq.l	#8,d3		;d3=length of string
	;CALLIB	SAME,Write	;>>>print it
	bsr.s	DosWriteGoodLen	;a6=dosbase, d1,2,3 sup for write
	lea	8(sp),sp	;remove ascii from stack
novfileh
	addq.l	#4,sp	;delete output handle
	rts	;print1value



DosWriteGoodLen:	;a6=dosbase, d1,2,3 sup for write
	move.l	d2,a0	;a0=stringptr
	moveq	#0,d0	;d0=new len
	move.w	d3,d4	;d4=counter, specified (max) len
	;skipping this correct 'max' end conditiion...subq	#1,d4



goodlenloop:
	addq.w	#1,d0		;d0='real' new len
	tst.b	(a0)+
	dbeq	d4,goodlenloop
	subq.w	#1,d0
	beq.s	nolenwrite
	move.l	d0,d3		;re-specified new len, d1,d2 still same
	;;;JMPLIB	SAME,Write	;>>>print it
_DosWrite:
	JMPLIB	DOS,Write	;>>>print it
nolenwrite:
	rts


EndIDCMP:	;turns off messages (only, doesn't close windows, etc)
	CALLIB	Exec,Forbid			;no msgs while sup
	move.l	IntuitionLibrary_(BP),a6	;sup for mod'idcmp call

	move.l	MCBWindowPtr_(BP),a0	;magnify closebox
	bsr.s	close_1_idcmp

	move.l	MWindowPtr_(BP),a0	;magnify painting window (11lines down)
	bsr.s	close_1_idcmp

	move.l	WindowPtr_(BP),a0
	bsr.s	close_1_idcmp

	move.l	GWindowPtr_(BP),a0	;hires gadgets window
	bsr.s	close_1_idcmp	;a0=*window d0=idcmp flags=message types desired

;closeToolIDCMP:
	move.l	ToolWindowPtr_(BP),a0	;ham palette/tools
	bsr.s	close_1_idcmp
	JMPLIB	Exec,Permit

close_1_idcmp:	;a0=window
	cmp.l	#0,a0			;no window arg? bum call?
	beq.s	endc1l			;wa?!...no window bomb shelter
	tst.l	wd_UserPort(a0)		;port in window?
	beq.s	endc1l			;no port, ok... (no idcmp msgs)
	tst.l	wd_IDCMPFlags(a0)	;got port, any msgs enabled?
	beq.s	endc1l			;no msg types...no need to 'modidcmp'
	moveq	#0,d0			;'none' message types
	;move.l	d0,wd_IDCMPFlags(a0)	; ->current (intuition does this)
	move.l	d0,wd_UserPort(a0)	;"no" port now
	JMPLIB	SAME,ModifyIDCMP
endc1l:	RTS
*****************************************************************************
** end of "ps:main.msg.i"
*****************************************************************************


*****************************************************************************
**
**	include "ps:main.key.i"	;RawKeyRoutine (AutoMove too)
*****************************************************************************
 xdef ZipKeyFileAction
	xref FakeIE_	;ie_sizeof	;fake input event for rawkeyconvert
	xref FakeActionMsg_
	xref FlagBrush_
	xref FlagCirc_
	xref FlagColorZero_
	xref FlagDither_
	xref FlagPOnly_
	xref FlagTextAct_
	xref KeyArrayPtr_
 	xref KeyBuffer_ ;,(4)	;result buffer for rawkeyconvert
	xref PasteBitMap_Planes_	;ptr to 7 brush bitplanes (6ham+mask)
	xref ScrollSpeedX_
	xref ScrollSpeedY_
;26NOV91;ASCIIRECORD	set 20 ;actually, this#+4 ...ex: "abcd xxxx yyyy"
ASCIIRECORD	set 80 ;actually, this#+4 ...ex: "abcd xxxx yyyy"
	;^^^^^ same as in default.asm  
KeyRoutine:	; a0=message pointer
	PEA	ReturnMessage(pc)	;go here when done with whatever
;MAY22 late....so magnify move, etc shows new coords
	st	FlagNeedText_(BP)	;indicate new coords on hires display

  ifc 't','f' ;JUNE
;APRIL23
;if rawkey from bigpic (drawing), then only works in 'special'
	move.l	im_IDCMPWindow(a0),d0
	beq.s	1$
	cmp.l	WindowPtr_(BP),d0	;window on big drawing screen
	bne.s	1$			;...continue when key from bigpic
	tst.l	FlagCirc_(BP)	;.b (circ,line,curv,rect)
	;bne.s	1$
	;bra	rawk_rts
	beq	rawk_rts
1$:	;not from bigpic (or special)
  endc

	move.W	im_Code(a0),d0	;keycode
	btst	#IECODEB_UP_PREFIX,d0	;keyUP or keyDOWN? ;EQU 7 value is $80
	bne	rawk_rts		;keyUP, g'way. (only do on downs)

	lea	FakeIE_(BP),a1
	movem.l	a0/a1,-(sp)	;a0=msgptr, a1=fake/new input event
	xjsr	GrabConsoleBase	;printrtns.o, a6=base for console, now
	movem.l	(sp)+,a0/a1	;moveM no effect on Z flag
	beq	rawk_rts	;boom no console wha?

	move.B	#1,ie_Class(a1)	;#IECLASS_RAWKEY,ie_Class(a1)
	move.w	im_Code(a0),ie_Code(a1)
	move.w	im_Qualifier(a0),ie_Qualifier(a1)
	move.l	im_IAddress(a0),ie_EventAddress(a1) ;handles euro deadkeys

	move.l	a1,a0			;FakeIE
	lea	KeyBuffer_(BP),a1	;where to put the 'real' ascii
	clr.l	(a1)			;clear so we can see if any came back

	;move.l	#(80-1),d0	;;NO CARE?;moveq	#0,d0
	;move.l	#(80-1),d1	;BUFFER LEN as per mortimer, devices, pg208
	;BUGFIXapril24
	move.l	#(8-1),d0	;;NO CARE?;moveq	#0,d0
	move.l	#(8-1),d1	;BUFFER LEN as per mortimer, devices, pg208

	suba.l	a2,a2		;use default (setmap'd) keymap

;RawKeyConvert(events,buff,len,keyMap)(A0/A1,D1/A2); 48 0xFFD0 -0x0030
	jsr	-$30(a6)	;fills KeyBuffer_(BP)

;needitit to kill fake msg;lea	4(sp),sp	;dispose of stacked call to return msg
	bsr	ReturnMessage	;this clears msgptr, RETURN RAWKEY MSG

;LOOKUP IN KEYARRAY...
	move.l	KeyBuffer_(BP),d0	;FIRST 4 CONVERTED KEY(s)
	;beq.s	rawk_rts		;no keycodes (after rawkeyconv')?
	beq	rawk_rts		;no keycodes (after rawkeyconv')?

ZipKeyFileAction:	;d0=LONG # (equiv 4 ascii) ('boot' code(s))
	xref FlagFoundKey_
	sf	FlagFoundKey_(BP)

;JUNE..if drawing or repainting, only allow arrow keys, escape
;$9b A Ksup ARROW KEYS
;$9b B Ksdn
;$9b C Ksrt
;$9b D Kslt
;$1b  Clbx   ESCAPE KEY = CLOSEBOX ON TOOL SCREENS
	tst.b	FlagNeedRepaint_(BP)
	;beq.s	notdrawing
	bne.s	001$
	xref	FlagRepainting_
	tst.b	FlagRepainting_(BP)	;dospecial completes shape if this flag
	beq.s	notdrawing
001$:	cmp.l	#$1b000000,d0	;escape key?
	beq.s	003$		;yep, do it
	cmp.l	#(($9b<<8)!'A')<<16,d0
	bcs.s	009$
	cmp.l	#(($9b<<8)!'E')<<16,d0
	bcc.s	009$
003$	bsr.s	notdrawing	;go handle as per normal (lup in table)
009$	sf	FlagTextAct_(BP) ;disable hires//activate(text)gadget
	rts

notdrawing:
;if in frame-store file requester, special-case '0'-'9' keycodes...
	xref FlagCompFReq_
	xref FrameNbrBinary_
	xref FrameNbrAscii_
					;d0=NNx0x0x0     NN='0'-'9' ascii
	tst.b	FlagCompFReq_(BP)
	beq.s	notin_framestore
	tst.W	FlagOpen_(BP)
	beq.s	notin_framestore
	cmp.l	#$0d<<24,d0		;  [enter] or [return] key?
	beq.s	handlecarreturn
	cmp.l	#$0a<<24,d0		;  ctrl+shift+return key?
	bne.s	notareturnkey

handlecarreturn:
	move.l	#'Okls',ActionCode_(BP)
	bra.s	notin_framestore	;handle/return "normally"...

notareturnkey:				;*** commented out for 4.0Thu Oct 13 15:06:21 1994
*	cmp.l	#'0'<<24,d0		;  NNx0x0x0     NN=00-09
*	bcs.s	notin_framestore	; not a digit, '0'..'9'
*	cmp.l	#('9'+1)<<24,d0		;  NNx0x0x0     NN=00-09
*	bcc.s	notin_framestore	; not a digit, '0'..'9'

*	sub.l	#'0'<<24,d0		;  NNx0x0x0     NN=00-09
*	rol.L	#8,d0			;  x0x0x0NN
*	and.l	#$0ff,d0		;  000000nn insurance.....
*	or.L	FrameNbrBinary_(BP),d0	;  x1x2x3nn
*	rol.L	#8,d0			;  x2x3nn??
*	clr.B	d0			;  x2x3nn00 ;bottom "digit" always zero
*	move.l	d0,FrameNbrBinary_(BP)
*	add.l	#'000'<<8,d0
*	move.l	d0,FrameNbrAscii_(BP)
*	xjsr	MatchFrameName		;match frame# to frame name, SAVEFRAME.asm
*	st	FlagNeedText_(BP)	;next time around, setup frame #
	bra.s	rawk_rts			;no lup array, numeric digitis, framestore

		;NOTE: need arexx framestore digit stuff...
notin_framestore:
	move.l	KeyArrayPtr_(BP),d1
	beq.s	rawk_rts			;no lup array
	move.l	d1,a0			;A0=TABLE of keycodes, d0.l=code2find
	;st	FlagTextAct_(BP) 	;"press'g any NON-key" activates textgadget

scanktab:			;a0 steps thru table, looking for d0 match
	move.L	(a0),d1		;table code
	beq.s	rawk_done ;rts	;outta here...enda table
	cmp.L	d1,d0		;our code = in table code ?
	bne.s	keeplookn
	;sf	FlagTextAct_(BP) ;found keycode so reset activate request
	movem.l	d0/a0,-(sp)	;code to find, current entry ptr
	st	FlagFoundKey_(BP)
	bsr.s	fndkc		;perform one action subr=>(rtnmsg?)=>rts
	movem.l	(sp)+,d0/a0	;...come back here & finish scanning...

keeplookn:
	lea	(4+ASCIIRECORD)(a0),a0	;next entry in keytable
	bra.s	scanktab

fndkc:	;"found key code", build a fake 'msgptr' setup based on found code
	lea	4(a0),a1		;A1=start of text (inside keyarray)
	lea	FakeActionMsg_(BP),a2	;A2=msg ptr

	MOVE.L	A1,-(SP)		;text ptr, string for msg
	MOVE.L	A2,-(SP)		;msg ptr (fake)
	move.l	a2,MsgPtr_(BP)		;watch FAKEOUT 'global' msgptr
	lea	MN_SIZE(a2),a0		;A0=end of a2 msg
	move.l	a0,LN_NAME(A2)		;setup a 'name' as...
	move.l	a0,a2			;A2=enda msg ptr, fill with name
	move.l	#'REMO',(a2)+
	xjsr	copy_string_a1_to_a2	;fillup fake msg from keyarray text
	MOVEM.L	(sp)+,a0/a1	;a0=fakemsgptr, a1=text msg ptr

	move.l	(a1),d0		;the 1st 4 ascii
	bra	DoAction	;returns notZERO if ok
	;rts

rawk_done:
	tst.b	FlagFoundKey_(BP)
	bne.s	rawk_rts
	st	FlagTextAct_(BP)	;couldnt find the keycode....

rawk_rts:
		;BugFix June01 1990 re: J McCormick comment on BIX...
		;...need to force/keep the console device closed
		;...else open count on the console.devices goes up and up
		;I don't know why this call wasn't in the original...
		;...it was coded, just not called...
	xjmp CloseConsoleBase	;printrtns.o, being nice & closing when really done
	;rts	;rawkey

reset_scroll_values:		;14NOV91
	move.w	_custom+joy0dat,Joy0Y_(BP)	;SETUP CURRENT	;AUG29
	move.w	Joy0Y_(BP),Joy0previous_(BP)	;setup for next time	;AUG29
	rts

key_rtn_lt: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.l	TickerStopped_(BP)	;july121990...re-enable STOP/WAIT for bottom
	clr.W	ScrollSpeedY_(BP)	;JUNE02
	;AUG29;move.B	Joy0Y_(BP),Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	;nov91;move.w	#$0001,Joy0previous_(BP)
	move.w	#$0002,Joy0previous_(BP)	;nov91
	move.w	#$0000,Joy0Y_(BP)
	;14NOV91;tst.w	ScrollSpeedX_(BP)
	;14NOV91;bmi	upcheck_speed
	;14NOV91;move.w	#-1,ScrollSpeedX_(BP)
	clr.w	ScrollSpeedX_(BP)	;14NOV91
	;AUG2591;bra	enda_cukr
	bra	upcheck_speed


;SHIFTED KEY
skey_rtn_lt: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.l	TickerStopped_(BP)	;july121990...re-enable STOP/WAIT for bottom

	clr.W	ScrollSpeedY_(BP)	;JUNE02
	;AUG29;move.B	Joy0Y_(BP),Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	move.w	#$0040,Joy0previous_(BP)
	move.w	#$0000,Joy0Y_(BP)
	tst.w	ScrollSpeedX_(BP)
	bmi	upcheck_speed
	move.w	#-1,ScrollSpeedX_(BP)
	;AUG2591;bra	enda_cukr
	bra	upcheck_speed

key_rtn_rt: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.l	TickerStopped_(BP)	;july121990...re-enable STOP/WAIT for bottom

	clr.W	ScrollSpeedY_(BP)	;JUNE02
	;AUG29;move.B	Joy0Y_(BP),Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	move.w	#$0000,Joy0previous_(BP)
	;nov91;move.w	#$0001,Joy0Y_(BP)
	move.w	#$0002,Joy0Y_(BP)
	;14NOV91;tst.w	ScrollSpeedX_(BP)
	;14NOV91;beq.s	1$	;sorry, zero tests as 'pl'
	;14NOV91;;;bpl.s	upcheck_speed
	;14NOV91;bpl	upcheck_speed
1$	;14NOV91;move.w	#1,ScrollSpeedX_(BP)
	clr.w	ScrollSpeedX_(BP)	;14NOV91
	;AUG2591;bra	enda_cukr
	bra	upcheck_speed

;SHIFTED KEY
skey_rtn_rt: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.l	TickerStopped_(BP)	;july121990...re-enable STOP/WAIT for bottom

	clr.W	ScrollSpeedY_(BP)	;JUNE02
	;AUG29;move.B	Joy0Y_(BP),Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	move.w	#$0000,Joy0previous_(BP)
	move.w	#$0040,Joy0Y_(BP)
	tst.w	ScrollSpeedX_(BP)
	beq.s	1$	;sorry, zero tests as 'pl'
	;;bpl.s	upcheck_speed
	bpl	upcheck_speed
1$	move.w	#1,ScrollSpeedX_(BP)
	;AUG2591;bra	enda_cukr
	bra	upcheck_speed

mouse_key_rtn_dn: ;a0,a1 already setup for scrollvport a2=screen use 
	tst.w	ScrollSpeedY_(BP)
	beq.s	1$	;sorry, zero tests as 'pl'
	bpl	upcheck_speed
1$
	xref FlagDelayBottom_
	tst.b	FlagDelayBottom_(BP)
	beq.s	enda_stopwait

	tst.b	FlagScrollStopped_(BP)
	bne.s	99$			;already stopped, let interrupt rtn clear this...

	move.l	FirstScreen_(BP),d0
	cmp.l	XTScreenPtr_(BP),d0
	;bne.s	enda_stopwait	;NO delay if no tools not in front
	beq.s	2$		;do this....
	xref	SkScreenPtr_	;little screen for rgb # display
	cmp.l	SkScreenPtr_(BP),d0
	bne.s	enda_stopwait	;NO delay if tools, or rgb#s, not in "front"
2$
	move.l	TickerStopped_(BP),d0	;1st time...(?)
	beq.s	stopwait
	sub.l	Ticker_(BP),d0
	bcc.s	10$
	neg.w	d0
10$	cmp.w	#MAXTICKTIME,d0	;50 ticks happen yet?
	bcc.s	enda_stopwait	;50 or more ticks....re-enable scrolling
	;st	FlagScrollStopped_(a1)
	;bra.s	enda_stopwait
99$	RTS


stopwait:
	;AUG311990;move.l	Ticker_(a1),TickerStopped_(a1)
	;AUG311990;st	FlagScrollStopped_(a1)
	move.l	Ticker_(BP),TickerStopped_(BP)
	st	FlagScrollStopped_(BP)
	;bra.s	enda_int
	RTS
enda_stopwait:


key_rtn_dn: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.W	ScrollSpeedX_(BP)	;JUNE02
	;AUG29;move.B	Joy0X_(BP),1+Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	move.w	#$0000,Joy0previous_(BP)
	;NOV91;move.w	#$0100,Joy0Y_(BP)
	move.w	#$0200,Joy0Y_(BP)	;NOV91
	;14NOV91;tst.w	ScrollSpeedY_(BP)
	;14NOV91;beq.s	1$	;sorry, zero tests as 'pl'
	;14NOV91;bpl.s	upcheck_speed
1$:	;july121990...handle "delay" time on bottom of screen b4 scroll

	;14NOV91;move.w	#1,ScrollSpeedY_(BP)	;GO EVEN INCR
	clr.w	ScrollSpeedY_(BP)	;14NOV91
	;AUG2591;bra	enda_cukr
	bra	upcheck_speed

;SHIFTED KEY
skey_rtn_dn: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.W	ScrollSpeedX_(BP)	;JUNE02
	;AUG29;move.B	Joy0X_(BP),1+Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	move.w	#$0000,Joy0previous_(BP)
	move.w	#$4000,Joy0Y_(BP)
	tst.w	ScrollSpeedY_(BP)
	beq.s	1$	;sorry, zero tests as 'pl'
	bpl.s	upcheck_speed
1$:	;july121990...handle "delay" time on bottom of screen b4 scroll

	move.w	#1,ScrollSpeedY_(BP)	;GO EVEN INCR
;AUG2591;bra	enda_cukr
	bra.s	upcheck_speed


key_rtn_up: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.l	TickerStopped_(BP)	;july121990...re-enable STOP/WAIT for bottom

	clr.W	ScrollSpeedX_(BP)	;JUNE02
	;AUG29;move.B	Joy0X_(BP),1+Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	;NOV91;move.w	#$0100,Joy0previous_(BP)
	move.w	#$0200,Joy0previous_(BP)	;nov91
	move.w	#$0000,Joy0Y_(BP)
	;14NOV91;tst.w	ScrollSpeedY_(BP)
	;14NOV91;bmi.s	upcheck_speed
	;14NOV91;move.w	#-1,ScrollSpeedY_(BP)	;use even increments
	;AUG2591;bra	enda_cukr
	clr.w	ScrollSpeedY_(BP)	;14NOV91
	bra.s	upcheck_speed



;SHIFTED KEY
skey_rtn_up: ;a0,a1 already setup for scrollvport a2=screen use 
	pea	reset_scroll_values
	clr.l	TickerStopped_(BP)	;july121990...re-enable STOP/WAIT for bottom

	clr.W	ScrollSpeedX_(BP)	;JUNE02
	;AUG29;move.B	Joy0X_(BP),1+Joy0previous_(BP)	;AUG2591, clears mouse hardware variable
	move.w	#$4000,Joy0previous_(BP)
	move.w	#$0000,Joy0Y_(BP)
	tst.w	ScrollSpeedY_(BP)
	bmi.s	upcheck_speed
	move.w	#-1,ScrollSpeedY_(BP)	;use even increments
	;AUG2591;bra	enda_cukr
	bra.s	upcheck_speed


spd_hdl:	;increment 'speed' (a0=ptr) (called by upcheck_speed)
	move.w	(a0),d0		;current 'speed'
	beq.s	9$	;not moving, no speed here
	smi	d1
	ext.w	d1
	add.w	d1,d1	;(-1,0) -> (-2,0)
	addq.w	#1,d1	;-> (-1,1)
	add.w	d1,d0	;add '-1' or '+1' to speed
	MOVE.w	d0,(a0)
9$	rts	;spd_hndl


upcheck_speed:	;come here when we've changed the scroll speed
   IFC 't','f' ;AUG251991....new mouse scroll speed....no accelleration here.
	lea	ScrollSpeedX_(BP),a0
	bsr.s	spd_hdl		;increment 'speed' (a0=ptr)
	lea	ScrollSpeedY_(BP),a0
	bsr.s	spd_hdl		;increment 'speed' (a0=ptr)
   ENDC

;AUG251991
;'new' scrolling method....interogate the mouse hardware
	xref Joy0previous_	;.word	;temp, stash of joy0dat
	xref Joy0Y_		;.byte
	xref Joy0X_		;.byte

	;move.w	_custom+joy0dat,d0
	clr.W	ScrollSpeedX_(BP)	;kill auto-scroll...;AUG29
	clr.W	ScrollSpeedY_(BP)	;AUG29

	move.w	Joy0Y_(BP),d0		;could have been altered
	cmp.w	Joy0previous_(BP),d0
	beq	mouse_is_still
	move.w	d0,Joy0Y_(BP)	;save X.byte X.byte
	
;Joy0previous = last position
;Joy0Y,X      = curt position  d0.byte=x
;handle X
	sub.B	1+Joy0previous_(BP),d0
	;;;ADDQ.B	#1,d0			;NOV91...-1/2 now becomes a zero
	CMP.B	#-1,D0			;NOV91
	beq.s	no_x_movement		;NOV91
	ASR.B	#1,d0			;NOV91...using 1/2 increments?
	beq.s	no_x_movement
	ext.W	d0
	bmi.s	ck_neg_overflo
	cmp.w	#127,d0
	bcs.s	done_ck_overflo
	neg.w	d0
	add.w	#255,d0
	bra.s	done_ck_overflo
ck_neg_overflo:
	neg.w	d0
	cmp.w	#127,d0
	bcs.s	done_ck_neg
	neg.w	d0
	add.w	#255,d0
done_ck_neg:
	neg.w	d0

done_ck_overflo:
	move.w	d0,ScrollSpeedX_(BP)	;reset the scrolling speed

  ifc 't','f'
;NOV91....don't bump along edges....only go in one direction
	bsr	CheckForKeyboard	;keyboard scrolling ought to work
	beq.s	no_x_movement
	move.l	ScreenPtr_(BP),a0
	beq.s	no_x_movement
	bmi.s	x_negative
;x_positive:
	tst.w	sc_MouseX(a0)
	beq.s	dont_move_x
	bra.s	no_x_movement
x_negative:
	tst.w	sc_MouseX(a0)
	beq.s	no_x_movement
dont_move_x:
	clr.w	ScrollSpeedX_(BP)
  endc

no_x_movement:
;handle Y
	move.B	Joy0Y_(BP),d0		;current y
	sub.B	Joy0previous_(BP),d0
	;;;ADDQ.B	#1,d0			;NOV91...-1/2 now becomes a zero
	CMP.B	#-1,D0			;NOV91
	beq.s	no_y_movement		;NOV91	beq.s	no_y_movement
	ASR.B	#1,d0			;NOV91...using 1/2 increments?
	ext.W	d0
	bmi.s	yck_neg_overflo
	cmp.w	#127,d0
	bcs.s	ydone_ck_overflo
	neg.w	d0
	add.w	#255,d0
	bra.s	ydone_ck_overflo
yck_neg_overflo:
	neg.w	d0
	cmp.w	#127,d0
	bcs.s	ydone_ck_neg
	neg.w	d0
	add.w	#255,d0
ydone_ck_neg:
	neg.w	d0

ydone_ck_overflo:
	move.w	d0,ScrollSpeedY_(BP)	;reset the scrolling speed

  ifc 't','f'
;NOV91....don't bump along edges....only go in one direction
	bsr	CheckForKeyboard	;keyboard scrolling ought to work
	beq.s	no_y_movement
	move.l	ScreenPtr_(BP),a0
	beq.s	no_y_movement
	bmi.s	y_negative
;y_positive:
	tst.w	sc_MouseY(a0)
	beq.s	dont_move_y
	bra.s	no_y_movement
y_negative:
	tst.w	sc_MouseY(a0)
	beq.s	no_y_movement
dont_move_y:
	clr.w	ScrollSpeedY_(BP)
  endc

no_y_movement:

;AUG29;move.w	Joy0Y_(BP),Joy0previous_(BP)	;setup for next time
mouse_is_still:
 XDEF enda_cukr ;for mousertns, scrolling w/shift key
enda_cukr:	;end of clean up key routine
	clr.w	ScrollBottom_(BP)		;SEP201990...keep it valid...
	move.l	ScreenPtr_(BP),d1	;d1='real' screenptr
	beq	skipscroll		;...no screen

;AUG261990....fudge 'bigpicwt' if in 1x
;	tst.b	FlagToast_(BP)
;	beq.s	123$
;	sub.w	#16,BigPicWt_(BP)	;re:problem with non-even /32 size... (736/2)
;123$
;MAR91;			;SEP071990....fudge 'bigpicwt' if in 1x
;MAR91;	tst.b	FlagToast_(BP)
;MAR91;	beq.s	123$
;MAR91;	sub.L	#16,BigPicWt_(BP)	;re:problem with non-even /32 size... (736/2)
;MAR91;123$

	move.l	d1,a2			;a2=screen
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	move.w	ri_RxOffset(a1),d2	;d2=current x offset (ends up in d0...)
	move.w	ri_RyOffset(a1),d1	;d1=current y offset
	add.w	ScrollSpeedX_(BP),d2	;d2=current x offset (try to go 1 more)
	bpl.s	1$
	moveq	#0,d2
	clr.w	ScrollSpeedX_(BP)
;AUG291991..SHIFTED SCROLL OK;bra.s	nochangeinx	;LATEST?;	;negative? no go off left of screen
1$:
	move.w	d2,d0			;d0 = temp for checking right edge
	add.w	sc_Width(a2),d0
	ext.l	d0	;and.l	#$0ffff,d0

;MAR91...hardcoded 'right side edge...'
	tst.b	FlagToast_(BP)
	beq.s	100$
	cmp.l	#752/2,d0			;MAR91;BigPicWt_(BP),d0
	beq.s	2$			;exact bump of rt side at new position
	bcs.s	2$
;AUG291991;move.l			#752/2,d0 ;MAR91;BigPicWt_(BP),d0
	sub.l	#752/2,d0
	sub.l	d0,d2
	move.l	#752/2,d0
	bra.s	101$

100$:
	cmp.l	#752,d0			;MAR91;BigPicWt_(BP),d0
	beq.s	2$			;exact bump of rt side at new position
	bcs.s	2$
;AUG291991;move.l	#752,d0		;MAR91;BigPicWt_(BP),d0
	sub.l	#752,d0
	neg.l	d0
	add.w	d0,d2
	move.l	#752,d0
101$:	subq	#1,d0
	clr.w	ScrollSpeedX_(BP)
;AUG291991..SHIFTED SCROLL OK;bra.s	nochangeinx	;LATEST?;	;negative? no go off left of screen
2$
	sub.w	ri_RxOffset(a1),d2	;d2=new x offset change
	move.w	d2,d0			;d0=parm for scroll rtn
	bra.s	donewithx
nochangeinx:				;already at edge, "nowhere to go. I got.."
	moveq	#0,d0
donewithx:				;d0=x scroll amt

;;AUG261990....De-fudge 'bigpicwt' if in 1x
;;AUG261990....fudge 'bigpicwt' if in 1x
;	tst.b	FlagToast_(BP)
;	beq.s	123$
;	add.w	#16,BigPicWt_(BP)	;re:problem with non-even /32 size... (736/2)
;123$
;MAR91;			;SEP071990....fudge 'bigpicwt' if in 1x
;MAR91;	tst.b	FlagToast_(BP)
;MAR91;	beq.s	123$
;MAR91;	add.L	#16,BigPicWt_(BP)	;re:problem with non-even /32 size... (736/2)
;MAR91;123$

	add.w	ScrollSpeedY_(BP),d1	;d1=current y offset
	tst.w	d1
;AUG291991;bmi.s	nochangeiny	;negative? no go off top of screen
	bpl.s	123$
	moveq	#0,d1			;bump top of screen
123$

	add.w	sc_Height(a2),d1	;SCREEN (viewport) ht

	xref	FlagToolWindow_
	xref 	ScrollBottom_		;#lines across bottom...(main.key.i)

;calc//allow for 'scroll up above bottom'
	movem.l	d0/a0,-(sp)
	tst.W	FlagOpen_(BP)		;file/brush/font open/save mode?
	bne.s	nobottom

;SEP201990;clr.w	ScrollBottom_(BP)
	move.l	TScreenPtr_(BP),d0	;ham tools tools screen opened?
	beq.s	nobottom
	move.l	d0,a0
	move.w	sc_TopEdge(a0),d0
	cmp.w	BigPicHt_(BP),d0
	bcc.s	nobottom		;'bigpic' is very short/above hires

	;move.w	sc_TopEdge(a0),d0	; typical 160+
	;subq.w	#3,d0			; fudge...accounts for intuit's 2 lines

;SEP071990;	move.w	NormalHeight_(BP),d0
;SEP071990;	sub.w	#42+5,d0
;SEP071990;	neg.w	d0
;SEP071990;	add.w	NormalHeight_(BP),d0	; typical 200+...result=#lines for bottom

;calc # of lines "below bottom" that we can scroll with
	move.w	sc_TopEdge(a0),d0	;lo-res line#s SEP071990...
	;add.w	#3,d0			;fudge for 2 copper lines, etc.
	sub.w	#3,d0			;fudge for 2 copper lines, etc.
	neg.w	d0			;SEP071990
	add.w	NormalHeight_(BP),d0	;SEP071990

	tst.b	FlagLace_(BP)
	beq.s	nobottom
	add.w	d0,d0

nobottom:
	;LATEMAY1990;tst.b	FlagToolWindow_(BP)	;'tools visible'?
	;LATEMAY1990;bne.s	002$
	;LATEMAY1990;lock out "Scroll above tools" when bigpic in front
	move.l	FirstScreen_(BP),-(sp)
	move.l	ScreenPtr_(BP),a0	;bigpicture
	cmp.l	(sp)+,a0	;...in front = firstscreen?
	bne.s	002$		;nope...ok, else...
	moveq	#0,d0		;lock out "Scroll above tools" when bigpic in front
002$
	move.w	d0,ScrollBottom_(BP)
	movem.l	(sp)+,d0/a0


	SUB.W	ScrollBottom_(BP),d1	;#BOTTOMLINES,d1
	and.l	#$0ffff,d1
	cmp.W	BigPicHt_(BP),d1	;PICTURE (page) ht
	beq.s	1$			;new pos exactly shows last line
	;AUG291991;bcc.s	nochangeiny		;at edge, "nowhere to go. I got.."
	bcs.s	123$
	move.w	BigPicHt_(BP),d1	;???AUG291991
123$

1$	sub.w	ri_RyOffset(a1),d1	;d1=new y offset change
	sub.w	sc_Height(a2),d1
	ADD.W	ScrollBottom_(BP),d1	;#BOTTOMLINES,d1
	bra.s	donewithy
nochangeiny:			;at edge, "nowhere to go. I got.."
	moveq	#0,d1
donewithy:	
;d0/d1 are POSITIVE numbers...representing shift to right/down
	add.w	d0,ri_RxOffset(a1)	;current x offset (ends up in d0...)
	add.w	d1,ri_RyOffset(a1)	;current y offset
	neg.W	d0
	neg.W	d1

	tst.W	d0
	bne.s	dosc
	tst.W	d1
	beq.s	skipscroll
dosc:
	;may03
	;movem.l	d0/d1/a0/a1,-(sp)
	;xjsr	UnShowPaste		;remove custom brush
	;movem.l	(sp)+,d0/d1/a0/a1

	ext.L	d0	;may90
	ext.L	d1	;may90

	CALLIB	Graphics,ScrollVPort
	st	FlagNeedText_(BP)	;indicate new coords on hires display
	st	FlagNeedMagnify_(BP)
	st	FlagNeedMakeScr_(BP)	;need MakeScreen (showpaste could, too)
	st	FlagNeedIntFix_(BP)	;need RethinkDisplay

;;;  xjsr DebugMe2 ;AUG301990
	xjsr	UnShowPaste		;remove custom brush, AFTER scroll MAY03
;JUNE29;xjsr	GlueChip		;memories.o, june12...scrollvport alloc's
skipscroll:	;done scrolling (from automove), clear speed now...
	rts



  ifc 't','f'
CheckForKeyboard:	;keyboard scrolling ought to work...NOV91
  ifc 't','f'
	cmp.l	#'Ksrt',ActionCode_(BP)	; Action Ksrt ;key_rtn_rt
	beq.s	9$
	cmp.l	#'Kslt',ActionCode_(BP)	; Action Kslt ;key_rtn_lt
	beq.s	9$
	cmp.l	#'Ksup',ActionCode_(BP)	; Action Ksup ;key_rtn_up
	beq.s	9$
	cmp.l	#'Ksdn',ActionCode_(BP)	; Action Ksdn ;key_rtn_dn
	;beq.s	9$
  endc
	move.l	d0,-(sp)
	moveq	#0,d0	;KLUDGE, TEST FOR FLAG EQUAL
	moveM.l	(sp)+,d0

9$	rts	;returns EQ if keyboard action code, NE elsewise
  endc


FixInterLace:	;help out intuition, as needed... (DESTROYS d0/d1/a0/a1/a6)
	move.l	IntuitionLibrary_(BP),a6
	lea	FlagNeedMakeScr_(BP),a0
	tst.b	(a0)
	beq.s	7$		;no need to MakeScreen
	sf	(a0)		;clr flag, no do this 2x unneeded
	move.l	ScreenPtr_(BP),d0	;big pic
	beq.s	7$		;no big screen open
	move.l	d0,a0

  ifc 't','f'
;'latest'....setlace 'active' button, now
	moveq	#0,d0
	;lea	sc_ViewModes(a0),a1
	lea	sc_ViewPort+vp_Modes(a0),a1
	move.w	(a1),d0			;sc_ViewModes(a0),d0
	move.w	#V_LACE,d1
	and.w	d1,d0
	tst.b	FlagLace_(BP)
	beq.s	68$
	or.w	d1,d0	;#V_LACE
	move.w	d0,(a1)			;d0,sc_ViewModes(a0)
	move.L	d0,CAMG_(BP)		;also need vport struct update????
68$
  endc

	CALLIB	SAME,MakeScreen	;construct new copper stuff for vp
	st	FlagNeedIntFix_(BP)	;need rethink if did a makescr'
7$:
	lea	FlagNeedIntFix_(BP),a0	;interlace fixzit, handled by msg code
	tst.b	(a0)
	beq.s	eafi		;ok...need no fix
	sf	(a0)		;reset flag, prevent 2x inarow
;JMPLIB	SAME,RethinkDisplay	;mrgcop and loadview
;since scrollvport, makescr, rethink "do" allocmem... june12...afternoon...
;JUNE29;xjsr	GlueChip	;memories.o
;JUNE29;JMPLIB	Intuition,RethinkDisplay
	JMPLIB	SAME,RethinkDisplay	;mrgcop and loadview ;june29
eafi:	rts


;;		;OCTOBER'90
;;		;...force to 'not scroll' when prop gadgets
;;		;...(blend sliders) are in use...
;;TestPropInUse:
;;	;return NOT EQUAL if a prop gadget is selected (in use)
;;	;return EQUAL if no prop gadget in use...
;;	;trashes a0/d0
;;
;;	move.l	GWindowPtr_(BP),d0
;;	beq.s	noprop_inuse
;;	move.l	d0,a0
;;	move.l	wd_FirstGadget(a0),d0
;;	bra.s	testgadget
;;proploop:
;;	move.l	(a0),d0		;gg_NextGadget
;;testgadget:
;;	beq.s	noprop_inuse
;;	cmp.w	#PROPGADGET,gg_GadgetType(a0)
;;	bne.s	proploop
;;	move.w	#SELECTED,d0
;;	and.w	gg_Flags(a0),d0
;;	beq.s	proploop		;not selected
;;;prop_inuse:
;;;	moveq	#-1,d0
;;noprop_inuse:
;;	RTS



AutoMove: ;*THIS* is what moves the screen around, sets FlagNeedIntFix if moved
;;	move.w	_custom+joy0dat,Joy0Y_(BP)	;SETUP CURRENT	;AUG29
;;	bsr.s	TestPropInUse		;OCTOBER'90
;;			;...force to 'not scroll' when prop gadgets
;;			;...(blend sliders) are in use...
;;	bne	no_automove		;no move if prop in use
;june061990;	tst.W	FlagOpen_(BP)		;file requester status, load-or-save?
;june061990;	bne.s	NoSignalAutoMove	;ignore timer if loading a file

	tst.W	FlagOpen_(BP)		;file requester status, load-or-save?
	bne.s	NoSignalAutoMove	;ignore timer if loading a file
		;message waiting?
	xref our_task_
	move.l	our_task_(BP),a0
	tst.l	TC_SIGRECVD(a0)		;ANY signal waiting? (even supervis'r?)
	beq	no_automove		;no scroll if no signal

NoSignalAutoMove:			;only called after a "wait" in main loop
;KLUDGEOUT;RTS		;12DEC91...KILLS TOASTERPAINT SCROLLING...
	tst.b	FlagMenu_(BP)
	bne	no_automove		;menu displayed...no move scr
	move.l	MScreenPtr_(BP),d0	;magnify scr?
	beq.s	1$			;nope.
	move.L	d0,a0
	tst.w	sc_MouseY(a0)
	bmi.s	1$			;"above" mag scr, continue bigpic?
	;no need;move.l	IntuitionLibrary_(BP),a6
	cmp.l	FirstScreen_(BP),a0	;ib_FirstScreen(a6),a0	;magnify screen in front?
	beq	no_automove		;or, "could" automove the magnify scr
1$

;19DEC91;	;auto-scrolling 'locked out'?
;19DEC91;xref	FlagScrollLock_	
;19DEC91;tst.b	FlagScrollLock_(BP)
;19DEC91;bne	no_automove		;locked (like, for a graphics tablet)
;19DEC91;....DISABLE old style scrolling (?)

	bsr	SnapScroll	;20DEC91....re-enable 1xmode snap scrolling
	BRA	no_automove ;19DEC91;		;locked (like, for a graphics tablet)

	xref FlagShiftKey_	;"scrolling" with shift key? AUG111990
	tst.b	FlagShiftKey_(BP)	;"scrolling" with shift key? AUG111990
	bne	no_automove		;locked (like, for a graphics tablet)

	move.l	ScreenPtr_(BP),d0
	beq	no_automove		;no screen?
	move.l	d0,a0			;screenptr
	movem.W	sc_Width(a0),d0-d3	;wt,ht,y,x d2=Mouse*Y* d3=mouseX

	subq	#1,d0			;d0=scr width -1 for right edge check
	subq	#1,d1			;adjust scr ht for compare

	tst.w	d3			;sc_MouseX(a0)
	beq.s	auto_maybe		;mouse at left edge
	cmp.w	d0,d3			;sc_Width(a0)
	bcc.s	auto_maybe		;mouse at right edge of SCREEN WIDTH

	tst.w	d2			;sc_MouseY(a0)
	beq.s	auto_maybe		;mouse on top of screen?

;OCTOBER1990....don't allow auto-scrolling on bottom...(?)
	tst.b	FlagCtrl_(BP)
	beq.s	119$
;NOVEMBER1990;	tst.b	FlagToolWindow_(BP)	;tools (even being) shown?
;NOVEMBER1990;	beq.s	119$		;sliders not shown, anyway, continue
	moveM.l	d0,-(sp)
	move.l	FirstScreen_(BP),d0
	cmp.l	XTScreenPtr_(BP),d0
	moveM.l (sp)+,d0
	bne.s	119$		;sliders not shown, anyway, continue

;DECEMBER 1990...no scrolling if prop gadget in use
	movem.l	a0,-(sp)
	move.l	GWindowPtr_(BP),a0
	xjsr	TestPropGad
	movem.l	(sp)+,a0
	;bNE.s	119$		;slider in use
	beq.s	119$		;slider NOT in use, continue


 IFC 'T','F' ;KLUDGEOUT,WANT
	cmp.w	#280,d3		;mouse_x to left side of warp amt slider?
	bcs.s	119$		;yep...ok to auto-move
	xref 	FlagStretch_
	tst.b	FlagStretch_(BP)	;if in TxMap mode...
	bne.s	117$			;then already checked left-of-sliders
	cmp.w	#453,d3		;mouse_x to left side of ctr blend slider?
	bcs.s	119$		;yep...ok to auto-move
117$	tst.b	FlagToolWindow_(BP)	;tools (even being) shown?
	;beq.s	119$
	;bra.s	no_automove
	;bne	no_automove	;sliders shown, no auto-move...
	;bne.s	kill_speed	;sliders shown, no auto-move...
	beq.s	119$		;sliders not shown, anyway, continue
 ENDC ;KLUDGEOUT,WANT


	clr.w	ScrollSpeedX_(BP)
	clr.w	ScrollSpeedY_(BP)
	bra	no_automove
119$:
	cmp.w	d1,d2		;sc_Height(a0)
	;bcs	no_automove	;not @ bottom, endame
	;bcs	kill_speed	;not @ bottom, endame MAY90
	bcc.s	auto_maybe
kill_speed:			;LATEMAY1990...SNAP MODE....LOCK SCREEN IN CENTER
	bsr	SnapScroll
	clr.w	ScrollSpeedX_(BP)
	clr.w	ScrollSpeedY_(BP)

auto_maybe:
	PEA	AfterScroll(pc)	;COME BACK WHEN MOVE


;REALLY WANT?;  IFC 't','f' ;MAY1990....no timer...signal to wake up?
	xref LastScrollTick_
;JUNE061990;	tst.W	FlagOpen_(BP)	;load/save?
;JUNE061990;	bne.s	skip_timer_check

;skip scrolling if disabled by interrupt routine...JULY121990
	tst.b	FlagScrollStopped_(BP)	;setup by int' routine in main.int.i
	Bne.s	skip_timered_scroll	;"wait" for about a second (?)
	move.l	d0,-(sp)
	move.l	Ticker_(BP),d0
	;subq.l	#1,d0			;wait for 2 ticks...(1 actually)
	sub.l	LastScrollTick_(BP),d0	;last 'tick time' we magnified
	moveM.l	(sp)+,d0		;moveM doesn't affect flag
	;Bcs.s	skip_timered_scroll	;just don't scroll twice on same 'tick'
	Beq.s	skip_timered_scroll	;just don't scroll twice on same 'tick'
skip_timer_check:
	move.l	Ticker_(BP),LastScrollTick_(BP)	;save 'clocktime' ONLY PLACE (?)
;REALLY WANT?;  ENDC


;?:move.w	_custom+joy0dat,Joy0Y_(BP)	;SETUP CURRENT	;AUG25
;;;; IFC 't','f'	;AUG251991....eliminate old style 'autoscroll'
;handle the autoscroll by 1 pixel when mouse on edge of screen
	tst.w	d3	;mouseX
	beq	upcheck_speed	;AUG29;key_rtn_lt
	cmp.w	d0,d3 	;adjust sc_Width(a0)
	bcc	upcheck_speed	;AUG29;key_rtn_rt

	tst.w	d2	;mouseY
	beq	upcheck_speed	;AUG29;key_rtn_up
	cmp.w	d1,d2	;already adjusted ht,mousey
	;bcc	key_rtn_dn
	bcc	upcheck_speed	;AUG29;mouse_key_rtn_dn



;;;;;  ENDC	;AUG251991....eliminate old style 'autoscroll'
;;;;		;AUG2591....jump into scroll handling code, no autoscroll, though
;;;;	tst.w	d3	;mouseX
;;;;	beq	upcheck_speed
;;;;	cmp.w	d0,d3 	;adjust sc_Width(a0)
;;;;	bcc	upcheck_speed
;;;;
;;;;	tst.w	d2	;mouseY
;;;;	beq	upcheck_speed
;;;;	cmp.w	d1,d2	;already adjusted ht,mousey
;;;;	;bcc	key_rtn_dn
;;;;	bcc	upcheck_speed

skip_timered_scroll:
	lea	4(sp),sp	;kill 'afterscroll' PEA'd rtnadr
	bra.s	no_automove

AfterScroll:
	tst.b	FlagRepainting_(BP)
	bne.s	no_automove	;move but no draw when repainting
	tst.W	FlagOpen_(BP)	;also does a 'tst.b FlagSave_(BP)'
	bne.s	no_automove	;move but no draw when save/load

	tst.b	FlagNeedRepaint_(BP)
	beq.s	no_automove	;go clear scroll speed, WHEN DRAWING STARTED
	tst.L	FlagCirc_(BP)	;Long test 4 flags, circ,curv,rect,line
	bne.s	no_automove	;special mode? if so then no autodraw

	tst.b	FlagCutPaste_(BP)
	beq.s	1$			;always ok if not cutpaste
	tst.l	PasteBitMap_Planes_(BP)	;carrying a brush?
	bne.s	no_automove		;no auto draw (ALLOWS when cutting)
1$:
	xref	LastM_Window_		;mousertns, set/clears this
	move.L	LastM_Window_(BP),d0
	beq.s	no_automove		;no prev window, ever?
	cmp.l	GWindowPtr_(BP),d0	;last "move" from hires (not bigpic/mag)?
	beq.s	no_automove		;yep...dont slow down

	clr.w	ScrollSpeedX_(BP)
	clr.w	ScrollSpeedY_(BP)
	xjmp	AutoMouseMove	;mousertns.o (clears ScrollSpeed(x,y) apropo')
no_automove:
	rts


;----------------------------------------
	xdef UpperLeftScroll	;viewpage calls this
UpperLeftScroll:		;"unscroll" screen
	xref FlagSnap_
	xref FlagToast_


	MOVEM.L	d0-d3/a0/a1/a2/a6,-(sp)

	;tst.b	FlagSnap_(BP)	;snap mode on?
	;beq.s	no_snap
	;tst.b	FlagToast_(BP)	;toaster mode on, too?
	;beq.s	no_snap
	;tst.b	FlagNeedRepaint_(BP)
	;bne.s	no_snap		;drawing-in-progress, don't snap...

	move.w	#0,d0		;OVERSCAN LEFTEDGE, desired position
	move.w	#0,d1		;OVERSCAN TOPEDGE...NTSC SIZE 768x480
;view is shifted inside ViewPage...
	bra.s	continue_snap

	move.l	ScreenPtr_(BP),d1	;d1='real' screenptr
	;definitely valid;beq	skipscroll		;...no screen
	move.l	d1,a2			;a2=screen
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	sub.w	ri_RxOffset(a1),d0	;...current position, correct

;----------------------------------------
	xdef SnapScroll		;scratch.asm//repaint calls this
SnapScroll:
	xref FlagSnap_
	xref FlagToast_

	MOVEM.L	d0-d3/a0/a1/a2/a6,-(sp)
	tst.b	FlagToast_(BP)	;toaster mode on, too?
	beq	no_snap
	tst.b	FlagNeedRepaint_(BP)
	bne	no_snap		;drawing-in-progress, don't snap...



 IFC 't','f' ;MAR91...no need...1x mode is "ok"...
;AUG271990.....ensure right edge 16 pixels not
;shown in 1x (FlagToast) mode....
	move.l	ScreenPtr_(BP),a2	;a2='real' screenptr
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
	cmp.w	#48+1,ri_RxOffset(a1)
	bcs.s	onex_ok
	move.w	#48,d0	;...current position, correct
	move.w	ri_RyOffset(a1),d1	;...current position, correct (ok)
	tst.b	FlagSnap_(BP)	;snap mode on?
	bne.s	onex_ok
	bra.s	snapright
onex_ok:
  ENDC	;MAR91


	tst.b	FlagSnap_(BP)	;snap mode on?
	beq	no_snap
;	move.w	#32,d0		;OVERSCAN LEFTEDGE, desired position
	move.w	#16+(16/2),d0	;OVERSCAN LEFTEDGE, desired position AUG261990
	move.w	#40,d1		;OVERSCAN TOPEDGE...NTSC SIZE 768x480
continue_snap:
	move.l	ScreenPtr_(BP),a2	;a2='real' screenptr
;20DEC91...no snap if mouse in 'scroll border' of screen
	movem.w	d0/d1,-(sp)
	move.w	sc_MouseX(a2),d0
	cmp.w	#16+1,d0
	bcs.s	skipscrollsnap
	cmp.w	#320-16-1,d0
	bcc.s	skipscrollsnap
	move.w	sc_MouseY(a2),d0
	cmp.w	#16+1,d0
	bcs.s	skipscrollsnap
	cmp.w	#400-16-1,d0
	bcc.s	skipscrollsnap
	bra.s	doscrollsnap
skipscrollsnap:
	movem.w	(sp)+,d0/d1
	bra.s	no_snap
doscrollsnap:
	movem.w	(sp)+,d0/d1
	lea	sc_ViewPort(a2),a0	;a0=viewport
	move.l	vp_RasInfo(a0),a1	;a1=rasinfo
snapright:
	sub.w	ri_RxOffset(a1),d0	;...current position, correct
	sub.w	ri_RyOffset(a1),d1	;...current position, correct

;;	bsr	donewithy	;scroll/snap
;;donewithy:	
;;		
	add.w	d0,ri_RxOffset(a1)	;current x offset (ends up in d0...)
	add.w	d1,ri_RyOffset(a1)	;current y offset
	neg.W	d0
	neg.W	d1

	tst.W	d0
	bne.s	dosnap
	tst.W	d1
	beq.s	no_snap	;skipscroll
dosnap:
	ext.L	d0	;may90
	ext.L	d1	;may90

	CALLIB	Graphics,ScrollVPort

	clr.w	ScrollSpeedX_(BP)	;AUG2591
	clr.w	ScrollSpeedY_(BP)	;AUG2591

	st	FlagNeedText_(BP)	;indicate new coords on hires display
	st	FlagNeedMagnify_(BP)
;WANT?	st	FlagNeedMakeScr_(BP)	;need MakeScreen (showpaste could, too)
	st	FlagNeedIntFix_(BP)	;need RethinkDisplay

	xjsr	UnShowPaste		;remove custom brush, AFTER scroll MAY03
;JUNE29'89;xjsr	GlueChip		;memories.o, june12...scrollvport alloc's
no_snap:
	MOVEM.L	(sp)+,d0-d3/a0/a1/a2/a6
	rts
*****************************************************************************
** end of "ps:main.key.i"
*****************************************************************************

*****************************************************************************
**	include "ps:main.int.i"	;interrupt server (decrements "Ticker_(BP)")
*****************************************************************************
;OnInt: enable a simple vertical blank interrupt that decrements a ticker
;OffInt: disables same

AirTicks	set	32	;32 ;#ticks (1/2 second NTSC) between airbrush spatters

	xref FlagDoAir_		;handled by interrupt routine (main.int.i)
	xref FlagRepainting_
	xref TickerStopped_	;long
	xref FlagScrollStopped_
	xref FirstScreen_

OnInt:
	lea	IntServer_(BP),a1	;int server node on *my* base page
	move.b	#NT_INTERRUPT,d0
	cmp.b	LN_TYPE(a1),d0		;use node type as 'flag' if on/off
	beq.s	intrts
	move.b	d0,LN_TYPE(a1)

	;move.b	#20,LN_PRI(a1)		;set priority of the server WANT HIGHER?
;APRIL17...zero priority...default

	move.b	#2,LN_PRI(a1)		;set server pri=2 (relative, anyway)
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
;;;and.b	#4-1,d0 ;#~AirTicks,d0	;every 30 ticks/ 2times a second
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
	bset	d1,d0			;d0=mask of signal bits
;8$
	;st	FlagDoAir_(a1)		;asks 'mainloop' for a AIRBRUSH repeat
	move.B	#4,FlagDoAir_(a1)	;asks 'mainloop' for a AIRBRUSH repeat
8$
;;  ifc 't','f' ;TEST,KLUDGE,WANT....
	move.l	a1,-(sp)		;save a1=digipaint basepage
	move.l	ExecLibrary_(a1),a6	;$4,a6...dont access chip needlessly
	move.l	our_task_(a1),a1	;BLOWS BASEPAGE
	CALLIB	SAME,Signal		;signal digipaint...drawairbrush
	move.l	(sp)+,a1		;restore a1=digipaint basepage
;;  endc
9$
  ENDC ;AIRBRUSH EXTRAS




;KEEP TRACK OF "screen in front"
	move.l	IntuitionLibrary_(a1),a0		;july13...grab real firstscreen...
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
	subq	#1,d0			;d0=scr width -1 for right edge check

	subq	#1,d1			;adjust scr ht for compare
	cmp.w	d1,d2			;sc_Height(a0)

	bcs.s	no_intmovestop

	move.l	TickerStopped_(a1),d0
	beq.s	startup_tickerstopped	;1st time?

	sub.l	Ticker_(a1),d0
	bcc.s	1$
	neg.w	d0
1$	cmp.w	#MAXTICKTIME,d0		;ticks happen yet?
	bcc.s	no_intmovestop		;maxtick' or more ticks....re-enable scrolling

	tst.b	FlagDelayBottom_(a1)	;AUG081990(BP)
	beq.s	no_intmovestop		;didn't "ask" for the delay
	st	FlagScrollStopped_(a1)
	bra.s	enda_intscroll

startup_tickerstopped:
	xref	FlagDelayBottom_	;JULY181990
	tst.b	FlagDelayBottom_(a1)	;AUG081990(BP)
	beq.s	no_intmovestop		;didn't "ask" for the delay

	;tst.b	FlagToolWindow_(a1)
	;beq.s	no_intmovestop		;NO delay if no tools not in front
	move.l	FirstScreen_(a1),d0
	cmp.l	XTScreenPtr_(a1),d0	;hires tools
	beq.s	2$
	cmp.l	SkScreenPtr_(a1),d0	;rgb# display
	bne.s	no_intmovestop		;NO delay if tools -or- rgb#s not in front
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
	bset	d1,d0			;d0=mask of signal bits
	move.l	a1,-(sp)		;save a1=digipaint basepage
	move.l	ExecLibrary_(a1),a6	;$4,a6...dont access chip needlessly
	move.l	our_task_(a1),a1	;BLOWS BASEPAGE
	CALLIB	SAME,Signal		;signal digipaint...drawairbrush
	move.l	(sp)+,a1		;restore a1=digipaint basepage
  ENDC


enda_intscroll:
	move.w	Joy0Y_(a1),Joy0previous_(a1)	;setup for next time AUG251991
	MOVEM.L	(sp)+,d2/d3
	move.w	Joy0Y_(a1),Joy0previous_(a1)	;setup for next time	;AUG29
	move.w	_custom+joy0dat,Joy0Y_(a1)	;SETUP CURRENT	;AUG29
	moveq	#0,d0 ;non-0 term's servers, stops those of lower pri
	rts

*****************************************************************************
**      endof "ps:main.int.i" 
*****************************************************************************

	;;;include "ps:main.level6.i"
	;#1=OK=wbench,#3=SEEMS TO WORK,#4=Rexx,#5=trackdisk,console.device

SetHigherPriority:	
	xjsr	AreWeAlive
	beq.s	prirts		;background....

ForceHigherPriority:
	moveq	#HIPRI,D0
	bra.s	ExecSetTaskPri

SetLowerPriority:
	moveq	#-1,D0
	bra.s	ExecSetTaskPri

ResetPriority:	;set to default if 'foreground', nochg if bkgnd
	move.l	our_task_(BP),a1	;ptr to our task(|process) structure
	cmp.b	#HIPRI,LN_PRI(a1)	;BYTE LN_PRI in task struct already?
	beq.s	SetDefaultPriority	;at highest?, then 'go normal'

;no need;move.l	IntuitionLibrary_(BP),a1
;	move.l	ib_FirstScreen(a1),d0
;	move.l	ib_ActiveWindow(a6),d0	;hires already active?
	move.l	FirstScreen_(BP),d0	;managed by IntuitionRtns.asm ;ib_FirstScreen(a1),d0
	beq.s	prirts	;wha?
;	cmp.l	XTScreenPtr_(BP),d0	;hires screen in front?
	cmp.l	GWindowPtr_(BP),d0
	beq.s	SetDefaultPriority	;yup...come alive
prirts:	rts


ForceDefaultPriority:			;xdef'd for mousertns
SetDefaultPriority:	
	moveq	#1,D0			;we FORCE this
ExecSetTaskPri:	;D0=new desired priority, returns OLD pri in D0, blows A0/D0
	move.l	our_task_(BP),a0	;ptr to our task(|process) structure
	cmp.b	LN_PRI(a0),D0		;BYTE LN_PRI in task struct already?
*	beq.s	aatpri			;already at priority, dont_call_exec
	movem.l	d1/a1/A6,-(sp)
	move.l	a0,a1			;our_task_(BP),a1;ptr to our task(|process) structure
*	DUMPREG	<TASKPRI CHANGEBEG>	
	CALLIB	Exec,SetTaskPri
*	DUMPREG	<TASKPRI CHANGEEND>	

	movem.l	(sp)+,d1/a1/A6
aatpri:	rts


	;ConVertAscii2Integer:
	;-skips digits after decimal point
	;-no negative #s, result must be WORD size....64k-1
cva2i:	;a0=point to string, returns d0=#, a0 advanced just past # (DESTROYS D1)
	;"suitably" commented out to 1) NOT ALLOW NEGATIVE, 2) MAX=64K-1(?)
	move.l	d3,-(sp)
	moveq	#0,d0		;d0=result to build, start with zero
	moveq	#0,d1		;clear upper bytes
	moveq	#10,d3		;assume BASE 10


cva_findstart:
	move.b	(a0)+,d1	;get characters from start
	beq	bodyDone
	cmp.b	#$0a,d1
	beq	err_cvaout
	cmp.b	#'.',d1		;DOT endzittoo
	beq	skipfrac	;bodyDone	;boom
	; cmpi.b	#'0',d1
	; beq.s	cva_findstart	;chuck initial zeros
	cmpi.b	#' ',d1
	beq.s	cva_findstart	;chuck initial blanks
	cmpi.b	#'x',d1		;check for hex forms
	beq.s	initialHex
	cmpi.b	#'$',d1	
	beq.s	initialHex
	bra.s	cva_ck1st
initialHex:
	move.w	#16,d3		;show base of 16, preserving minus


bodyStr:
	move.b	(a0)+,d1	;get next character
bodyConvert:
	beq	bodyDone	;null @ end of string?
	cmp.b	#' ',d1		;blank endzittoo
	beq	bodyDone
	cmp.b	#'/',d1		;slash is a delimiter, too
	beq	bodyDone
	cmp.b	#'.',d1		;DOT endzittoo
	beq.s	skipfrac	;bodyDone
cva_ck1st:
	cmp.b	#$0d,d1		;cr?
	beq	bodyDone
	cmp.b	#$0a,d1		;lf?
	beq	bodyDone
	cmp.b	#$09,d1		;tab?
	beq.s	bodyDone
				;prob'ly have a valid digit, shift accum
	mulu	d3,d0		;result=result*base
	cmpi.b	#'0',d1
	blt.s	badChar
	cmpi.b	#'9',d1
	bgt.s	perhapsHex
	subi.b	#'0',d1
	add.W	d1,d0		;binary value now, accum.
	bra.s	bodyStr		;go get another char

perhapsHex:
	cmp.w	#16,d3		;working in hex (base 16) now?
	bne.s	badChar
	cmpi.b	#'A',d1
	blt.s	badChar
	cmpi.b	#'F',d1
	bgt.s	perhapsLCHex
	subi.b	#'A'-10,d1
	add.w	d1,d0
	bra.s	bodyStr

perhapsLCHex:
	cmpi.b	#'a',d1
	blt.s	badChar
	cmpi.b	#'f',d1
	bgt.s	badChar
	subi.b	#'a'-10,d1
	add.w	d1,d0		;binary, accum.
	bra.s	bodyStr

badChar:
	tst.l	d0		;if we already have a #...
	bne.s	enda_cva2i	;... end on non-# char

err_cvaout:
	moveq	#-1,d0		;else flag error as minus
	bra.s	enda_cva2i

skipfrac:			;done scanning, found a 'dot'...skip fract digits
	move.b	(a0)+,d1
	beq.s	bodyDone	;null @ end of string?
	cmp.b	#' ',d1		;blank endzittoo
	beq.s	bodyDone
	cmp.b	#'.',d1		;DOT endzittoo
	beq.s	skipfrac	;bodyDone
	cmp.b	#$0d,d1		;cr?
	beq.s	bodyDone
	cmp.b	#$0a,d1		;lf?
	beq.s	bodyDone
	cmp.b	#$09,d1		;tab?
	beq.s	bodyDone
	cmp.b	#'/',d1		;slash ok too
	;beq.s	bodyDone
	bne.s	skipfrac
bodyDone:
enda_cva2i:
	move.l	(sp)+,d3
	tst.l	d0	;be nice, test for minus after subr call for errchk
	rts	;cva2i


;note: for TABLE BELOW, UnDoBitMap FAST MEM WANTED alloc'd 1st
;note: ...this should help when you say 'fastmemfirst','digipaint'
;DEPTH,BasePageADDRESS,type#0=CHIP,#1=FAST,#-1=NONE(listend),#-2=NONE
BitMap_Data:
 ifd paintAA
	dc.w 8,ScreenBitMap_,0		;visible work screen  ;
	dc.w 2,BB_BitMap_,0		;drawing mask SECOND BITPLANE IS TMPRAS
	dc.w 8,CPUnDoBitMap_,-1 	;6 plane brush picture (NOT ALLOCATED)
	dc.w 8,SwapBitMap_,-1		;alternate (NOT ALLOCATED)
	dc.w -1				;-1 indicates "END OF LIST"
  endc
 ifd paint2000
	dc.w 6,ScreenBitMap_,0		;visible work screen  
	dc.w 2,BB_BitMap_,0		;drawing mask SECOND BITPLANE IS TMPRAS
	dc.w 6,CPUnDoBitMap_,-1 	;6 plane brush picture (NOT ALLOCATED)
	dc.w 6,SwapBitMap_,-1		;alternate (NOT ALLOCATED)
	dc.w -1				;-1 indicates "END OF LIST"
 endc

OpenBigPic:	;opens screen & window as per scratch var specs MESSES ALOT W/a4
		;args are: NewSizeX_(BP),NewSizeY_(BP),FlagLaceNEW_(BP),
;prevent 'cli startup' with ODD # lines...mustbe EVEN
	lea	NewSizeY_(BP),a0
	move.w	(a0),d0
	addq.w	#1,d0
	and.w	#~1,d0			;remove bottom ("odd") bit
	move.w	d0,(a0)			;NewSizeY


;ensure 32<=x<=1024,   y<=1024
	move.w	#1024,d1
	cmp.w	d1,d0			;y max?
	bcs.s	10$
	move.w	d1,d0 ;(a0)		;ymax=1024
10$	moveq	#MINHT,d2		;min y
	cmp.w	d2,d0
	bcc.s	11$
	move.w	d2,d0
11$	move.w	d0,(a0)			;newsizeY

	lea	NewSizeX_(BP),a0
	move.w	(a0),d0
	add.w	#64-1,d0		;round up, even longwords...
	and.w	#~(64-1),d0
	;moveq	#32,d2
	;cmp.w	d2,d0			;<32?
	;bcc.s	2$
	;move.w	d2,d0			;x=32
2$
	cmp.w	d1,d0			;<1024?
	bcs.s	3$
	move.w	d1,d0
3$	move.w	d0,(a0)			;newsizeX
	

;ask "delete swap screen?"
;	tst.b	FlagToasterAlive_(BP)
;	bne.s	onoswap
	tst.l	Datared_(BP)		;rgb mode? ....JULY191990
	bne.s	onoswap			;then don't delete the swap 
	lea	SwapBitMap_(BP),a0
	tst.l	bm_Planes(a0)
	beq.s	onoswap
	move.w	(a0),d0			;bm_BytesPerRow(a0),d0
	asl.w	#3,d0			;=pixels per row
	cmp.w	NewSizeX_(BP),d0
	bne.s	askdel
	move.w	bm_Rows(a0),d0
	cmp.w	NewSizeY_(BP),d0
	beq.s	onoswap
askdel:	xjsr	AskDelSwapRtn
	bne.s	godelswap		;ok...go delete swap (continue like norm)
;else, user said "no! cancel size chg...no delete swap"
	tst.L	ScreenPtr_(BP)		;ok, then, HAVE a screen?
	bne	obp_sup_end		;openbigpic, setup end.....all set now?
;...simply sup NEWSIZE x,y to be same as swap
	lea	SwapBitMap_(BP),a0
	move.w	(a0),d0			;bm_BytesPerRow(a0)
	asl.w	#3,d0			;=pixels per row
	move.w	d0,NewSizeX_(BP)
	move.w	bm_Rows(a0),NewSizeY_(BP)
	bra.s	onoswap

;delete swap screen since it's a different ht/wt than new
godelswap:
	xjsr	FreeSwap
onoswap:
	bsr	CloseBigPic		;closes screen, kill chip bitmap+2brush bitplanes
	xjsr	ByeByeWorkBench		;memories.o
	xjsr	CleanupMemNoWb		;cleans up, but doesnt force flag closewb

	tst.l	FileHandle_(BP)		;file open?
	bne.s	5$			;yes file open...else sup bmhd_xaspect
	moveq	#10,d0			;lores aspect
	tst.b	FlagLaceNEW_(BP)
	beq.s	3$
	add.w	d0,d0			;hires aspect (=20)
3$	move.w	d0,bmhd_xaspect_(BP)

5$	move.b	FlagLaceNEW_(BP),FlagLace_(BP)
	moveq	#0,D0			;global vars from BMHD_rastwidth/height
	move.w	NewSizeX_(BP),d0	;bmhd_rastwidth_(BP),D0
	add.w	#$1f,D0			;round up to longword
	and.w	#~$1f,D0
	move.l	D0,BigPicWt_(BP)
	subq.l	#1,D0
	move.l	D0,pixels_row_less1_(BP)

	asr.w	#3,D0			;/8 converts pixels to bytes
	move.l	D0,bytes_row_less1_(BP)	;#bytes -1 for 'dbxx' loops
;2.0;	move.w	d0,d1
;2.0;	asr.w	#2,d1
;2.0;	move.w	d1,lwords_row_less1_(BP) ;#longwords  -1 for 'dbxx' loops

	addq.l	#1,D0
	move.l	D0,bytes_per_row_(BP)
	move.l	D0,d1			;used INAMOMENT for planesize calc
	asr.w	#1,D0			;/2 converts BYTEsperrow to WORDsperrow
	subq.w	#1,D0
	move.l	D0,words_row_less1_(BP)

	move.w	NewSizeY_(BP),d2	;bmhd_rastheight_(BP),d2
	move.w	d2,BigPicHt_(BP)	;global BITMAP HT really RASTHEIGHT
	mulu	d2,d1			;* bytes_per_row
	move.l	d1,PlaneSize_(BP)	;used "everywhere"

;INTERPRET BMHD X ASPECT -->> turn on interlace?
	sf	FlagLace_(BP)
	moveq	#0,d0
	tst.b	FlagLaceNEW_(BP)
	bne.s	saylace
	moveq	#10,d1			;build aspect ratio in d1, d0=work
	move.B	bmhd_xaspect_(BP),d0	;5,10,20
	beq.s	golores			;ZERO aspect?
	cmp.b	#5,d0
	bne.s	nhires
golores	moveq	#10,d0			;hires goes to lores ham FOR MY SCREENS
nhires:	cmp.b	#20,d0
	bne.s	nhamlace
saylace	moveq	#20,d1
	st	FlagLaceNEW_(BP)
nhamlace:
	move.W	d1,XAspect_(BP)

;ensure SCREEN(not bitmap) not bigger than 'normal' (booo....)
	move.L	BigPicWt_(BP),d1	;'desired width' (elim page junk?)
	move.w	BigPicHt_(BP),d2
	move.w	NormalWidth_(BP),d3
	move.w	NormalHeight_(BP),d4
	tst.b	FlagLaceNEW_(BP)
	beq.s	1$
	add.w	d4,d4
1$	cmp.w	#600,d4
	bcs.s	2$
	asr.w	#1,d4			;=ht/2
	and.w	#$7fff,d4		;top bit rolls down a zero if loop here
	bra.s	1$
2$
	cmp.w	d3,d1			;normal width,desired width
	bcs.s	5$			;normal>desired, ok to use smaller (?) yes
	move.w	d3,d1			;d3<=d1, use 'normal' width
5$
	cmp.w	d4,d2			;normal ht, desired ht
	bcs.s	6$			;branch when d4>d2
	move.w	d4,d2			;d4<=d2, use 'normal' (not bitmap, which is taller) ht
6$
	move.w	d1,bmhd_pagewidth_(BP)	;re-save bmhd 'page' fields after adj'
	move.w	d2,bmhd_pageheight_(BP)
	move.L	#V_HAM,d3		;lores screen mode
	tst.b	FlagLaceNEW_(BP)	
	beq.s	101$
	or.w	#V_LACE,d3		;modes + I'LACE
101$:
 IFD paint2000
	or.w	#V_LACE,d3	
 ENDC
 IFD paintAA
	or.w	#V_HIRES!V_LACE,d3	;test force hires lace for AA Computer;
 ENDC
	lea	BigNewScreen_(BP),A0	;A0=newscreen struct for 'big picture'
	clr.w	ns_TopEdge(a0)		;digipaint pi

 IFD paint2000
	move.w	#752,ns_Width(a0)	; test for aa	
	move.w	#480,ns_Height(a0)	; test for aa
	move.w	#-20,ns_TopEdge(a0)	; test for aa
	move.w	#0,ns_LeftEdge(a0)	; test for aa

;	lea	SCREENTAGS_(BP),a1
;	move.l	a1,ns_SIZEOF(a0)	;setup tag list
   
;	move.l	#SA_Overscan,(a1)+
;;	move.l	#3,(a1)+		;overscan mode ;;MODO-TEMP
;	move.l	#OSCAN_VIDEO,(a1)+	;overscan mode
;	clr.l	(a1)			;mark end of taglist
 ENDC
 IFD paintAA
	move.w	d1,ns_Width(a0)
	move.w	d2,ns_Height(a0)
	move.w	#752,ns_Width(a0)	; test for aa	
	move.w	#480,ns_Height(a0)	; test for aa
	move.w	#-60,ns_TopEdge(a0)	; test for aa
	move.w	#0,ns_LeftEdge(a0)	; test for aa

	lea	SCREENTAGS_(BP),a1
	move.l	a1,ns_SIZEOF(a0)	;setup tag list
   
	move.l	#SA_Overscan,(a1)+
;;	move.l	#3,(a1)+		;overscan mode ;;MODO-TEMP
	move.l	#OSCAN_VIDEO,(a1)+	;overscan mode
	clr.l	(a1)			;mark end of taglist
 ENDC




dcx	equ	-10
dcy	equ	-10

;	move.l	#SA_AutoScroll,(a1)+
;	move.l	#1,(a1)+
;	move.l	#SA_DClip,(a1)+
;	lea	8(a1),a2
;	move.l	a2,(a1)+
;	clr.l	(a1)+				;mark end of taglist
;	move.l	#((0+dcx)<<16)!(0+dcy),(a1)+	;xmin,ymin
;	move.l	#((200+dcx)<<16)!(50+dcy),(a1)+	;xmax,ymax

 ifd aa_paint
	move.w	d3,ns_ViewModes(a0)		;zap NewScreen struct MODO-TEMP
 endc

;	move.L	d3,CAMG_(BP)
;	move.b	FlagLaceNEW_(BP),FlagLace_(BP)

;initialize & alloc 'primary' bitmaps/planes
	lea	BitMap_Data(pc),a3  		;A3 := data table for init function

init_one_map:
	movem.l	Zeros_(BP),D0/d1/d2
	move.w	(a3)+,D0		;number of bitplanes -or- endoflist
	bmi	end_ibm			;end of list (-1), leave w/notzeroflag
	moveq	#0,d1			;d1 using LONG MODE ensures bp offset ok
	move.w	(a3)+,d1		;address-base-offset
	cmp.w	#BB_BitMap_,d1		;drawing mask,2bitplane, initbitmap with 1
	bne.s	1$
	subq.w	#1,d0			;reduce bitplane count for InitBitMap purposes
1$
	lea	0(BP,d1.L),A0		;A0 bitmap struct Graphics Arg
	lea	bm_Planes(A0),a2	;A2 BitMap -> bm_Planes{table.of.addrs}
	tst.l	(a2)			;ALREADY have bitplane(s)?
	bne	end_this_bitmap		;...skip if already alive

	move.L	BigPicWt_(BP),d1	;"working bitmap" size
	moveq	#0,d2
	move.W	BigPicHt_(BP),d2	;bmhd_rastheight_(BP),d2
	CALLIB	Graphics,InitBitMap

	cmpi.w	#-1,(a3)		;our "type"
	beq	end_this_bitmap  	;-1 from table means "init only"

;a2="pointer to table of bitplane addresses" a3=input/build spec
	move.w	-4(a3),d3		;# planes (1st entry eachrecordintable)
 ifnd paint2000
	subq.w	#1,d3			;for dbf loop (# WAS used by initbitmap)
 endc
alloc_planes:
	move.l	PlaneSize_(BP),D0	;type zero is "normal" bitmap dimensions
	cmpi.w	#1,(a3)			;alloc type from table
	bne.s	gchip
	xjsr	IntuitionAllocMain	;memories.o;fast prefer'd else chip
	bra.s	gmem
gchip:	xjsr	IntuitionAllocChipJunk	;memories.o;preserves reg d1
gmem:	beq	end_ibm			;no mem? stop init of all remaining
	move.l	D0,(a2)+		;extra lines display cut/paste stuff
	move.l	d0,a0			;address to clear
	xjsr	ClearPlaneA0		;strokeB.o, clearzit
	dbf	d3,alloc_planes
 ifd paint2000
*	move.l	-4(a2),(a2)
*	move.l	d0,8(a2)
	
*	MOVE.L	(A2),d0
*	MOVE.L	-28(A2),(a2)
*	MOVE.L	D0,-28(A2)

*	MOVE.L	-4(A2),d0
*	MOVE.L	-24(A2),-4(a2)
*	MOVE.L	D0,-24(A2)

	DUMPMEM <ALLOCATED BITMAP-BIG>,-bm_SIZEOF(A2),#128
 endc	


end_this_bitmap:
	lea	2(a3),a3		;skip planesize, prep re-loop next bitmap
	bra	init_one_map

end_ibm:				;"end of init'g bitmaps from table" ZERO/minus flag set
	beq	bummout			;couldn't get required bitmaps
	xjsr	AllocUnDo		;1st time?
	beq	bummout
	xjsr	EnsureExtraChip		;yeas, this chops up chip on a lowmem
	beq	bummout			;after "all the above"...notnuff chip for system

justopenscreen:
	xjsr	InitBitPlanes		;Scratch.o;inits rastports, too  
9$
	lea	BigNewScreen_(BP),A0	;A0=NEWSCREEN STRUCT FOR OPENBIGSCREEN
 ifd paint2000
	move.w	#6,ns_Depth(A0)		;width, ht already setup earlier?
 endc
 ifd paintAA	
	move.w	#8,ns_Depth(A0)		;width, ht already setup earlier?
 endc
 
	move.b	#1,ns_BlockPen(A0)

sctype set CUSTOMSCREEN!CUSTOMBITMAP!SCREENQUIET ;26FEB92; !SCREENBEHIND

	move.w	#sctype,ns_Type(A0)	;SEP131990;
 ifd paint2000
	move.w	#sctype,ns_Type(A0)	;SEP131990;
 endc
 ifd paintAA
	or.w	#$1000,ns_Type(a0)	;test for AA NS_EXTENDED
 endc
	lea	TextAttr_(BP),a1	;fontname, ht, style
	move.l	a1,ns_Font(A0)
	lea	ProgramNameBuffer_(BP),a1
	move.l	a1,ns_DefaultTitle(A0)
	lea	ScreenBitMap_(BP),a1
	move.l	a1,ns_CustomBitMap(A0)
	DUMPMEM	<BIGDEAL>,(A1),#64
	CALLIB	Intuition,OpenScreen
	DUMPREG	<BIGERDEAL>
	move.l	D0,ScreenPtr_(BP)	;save pointer to new screen
	beq	bummout			;no screen?

 	xref 	FlagColorMap_
	st	FlagColorMap_(BP)

;july051990...kills size change...but...
	tst.l	Datared_(BP)		;rgb buffers, already?
	bne.s	123$			;bugfix...july171990...;beq.s	123$
	movem.w	Zeros_(BP),d0/d1
	movem.w	NewSizeX_(BP),d0/d1
	xjsr	AllocRGB
	beq	bummout			;no rgb buffer(s)?
	xjsr	AllocUnDoRGB		;JULY131990
	beq	bummout			;no undo-rgb buffer(s)?

123$:	
;do asap(?), elim "workbench blue"
	xjsr	HiresColorsOnly		;pointers.o, sup colors on hires
	xjsr	UseColorMap		;(pointers.o, for now)

	move.l	ScreenPtr_(BP),A2	;bigpic
	move.l	A2,A0			;ScreenPtr
	moveq	#0,D0			;false argument
	CALLIB	Intuition,ShowTitle	;hides the Screen title bar

;open WINDOW on bigpic screen
mywinf	equ	BORDERLESS!REPORTMOUSE!NOCAREREFRESH!RMBTRAP
	lea	BigNewWindow_(BP),A0		;STRUCTURE NewWindow
	move.l	ScreenPtr_(BP),A2		;bigpic
	move.b	#1,nw_DetailPen(A0)		;textpen for system requests
	move.w	sc_Width(a2),nw_Width(A0)	;A2 still=screenptr
	move.w	sc_Height(a2),nw_Height(A0)
	move.l	a2,nw_Screen(A0)
	move.w	#CUSTOMSCREEN,nw_Type(A0)
	move.L	#mywinf,nw_Flags(A0)
	CALLIB	SAME,OpenWindow
	move.l	D0,WindowPtr_(BP)	;pointer to newly opened window
	beq	bummout			;Abort with ZERO set, not everyone alive
	move.l	D0,A0
	bsr	AdjustWinMsgQue	;2.0....APR91
	tst.b	Initializing_(BP)
	bne.s	getnewu
	lea	UnDoBitMap_(BP),a0	;a0=from normal undo (fastramifpossible)
	lea	ScreenBitMap_(BP),a1	;a1=to visible screen
	xjsr	Crit			;copy odd/diff shaped undo -> screen
	xjsr	FreeUnDo		;get ridda the 'old' one
	xjsr	FreeUnDoRGB		;if any...LATEMAY1990
getnewu:
	sf	FlagBitMapSaved_(BP)	;forces saveundo to work
	xjsr	SaveUnDo		;allocs undo bitmap as neede

;openbigpic, setup end.....bra's here from 'delete swap?'
obp_sup_end:	
	tst.l	UnDoBitMap_Planes_(BP)	;normal undo alloc'd?(fastramifpossible)
	beq.s	bummout			;no undo->go closebigpic

	xref FlagToolWindow_
	st	FlagToolWindow_(BP)
	st	FlagFrbx_(BP)		;ask for screen arrange
	st	FlagColorMap_(BP)
	moveq	#-1,d0			;set 'ne' flag, "ok" ending, did/had pic
	rts

bummout:				;bummount-bigpic didnt open
	bsr.s	skipundosave 		;fixes BUG with sizer "losing picture" JULY01
	st	FlagToolWindow_(BP)
	st	FlagFrbx_(BP)		;ask for screen arrange
	moveq	#0,d0			;returns flagset for didnt/couldnt open screen
zzrts:	rts


;2.0....APR91	;a0=window ptr
AdjustWinMsgQue:	
	movem.l	d0/d1/a0/a1/a6,-(sp)
	move.l	IntuitionLibrary_(BP),a6
	cmp.W	#36,LIB_VERSION(a6)
	bcs.s	9$			;workbench 2.0 or newer?
	moveq	#30,d0			;30 extra messages...(assume 1/2 second for 68000 copy)
	jsr	$FFFFfe0e(a6)		;SetMouseQueue...intuition 2.0
9$	movem.l	(sp)+,d0/d1/a0/a1/a6
	RTS


;note: does not delete "undobitmap"
CloseBigPic:			
*	bsr	CloseAlphaScreen	
***!!1	xjsr	ForceToastCopper	;JULY13,1990.....moved *here* 29JAN92
	xjsr	SafeEndFonts		;JULY03 kludgy but needed ?...fixes mem loss?
	xjsr	GoodByeHamTool		;close hamtools
	tst.l	ScreenPtr_(BP)		;screen open'd?
	beq	cbp_freedata		;no scr?
	xjsr	UnShowPaste		;remove brush from screen
	xjsr	FreeDouble		;double bitmap (if any)
	xjsr	CopyScreenSuper		;visible//chip -> undo//fastifpossible
	xjsr	FreeDouble		;chip ram double buffer (when "chip rich")
	xjsr	FreeCPUnDo		;'extra' copy used while showing brush

skipundosave:
;help prevent the leading cause of screen loss...
	tst.l	UnDoBitMap_Planes_(BP)	;normal undo alloc'd?(fastramifpossible)
	bne.s	okhaveundo
	xref DefaultX_			;sizer vars...."restore" undo?
	xref DefaultY_
	moveq	#0,d0
	moveq	#0,d1
	movem.W	DefaultX_(BP),d0/d1
	move.L	d0,BigPicWt_(BP)
	move.w	d1,BigPicHt_(BP)
	mulu	d0,d1
	move.l	d1,PlaneSize_(BP)	;used "everywhere"
	beq.s	okhaveundo		;oops? bomb-pruf?
	xjsr	AllocUnDo
	tst.l	UnDoBitMap_Planes_(BP)	;normal undo alloc'd?(fastramifpossible)
	beq.s	okhaveundo		;really, didn't get the ram, no copy
	lea	ScreenBitMap_(BP),a0	;a0=FROM visible screen
	lea	UnDoBitMap_(BP),a1	;a1=TO normal undo (fastramifpossible)
	xjsr	Crit			;copy odd/diff shaped undo -> screen
	xjsr	InitSizer		;since HAD NO UNDO, came from sizer(?)

okhaveundo:
	lea	WindowPtr_(BP),A0	;point to variable on basepage
	lea	ScreenPtr_(BP),A1	;big picture (if any)
	DUMPMSG	<BEFORE CLOSE WINDOW>
	bsr	CloseWindowAndScreen
	DUMPMSG	<AFTER CLOSE WINDOW>


cbp_freedata:
	lea	ScreenBitMap_(BP),a3	;FREE SCREEN (CHIP) BITPLANE MEMORY
	lea	bm_Planes(a3),a3

 ifd paint2000
	moveq	#6-1,d3
 endc
 ifd paintAA 
	moveq	#8-1,d3			;d3=loopcounter,a3=>bitplane addrs
 endc

freescreen:				;freeonevar ok to call if vardata=0
	lea	(a3),A0			;address of bitplane data
	bsr.s	free1v
	lea	4(a3),a3		;pointer to next plane ptrin bitmap struct
	dbf	d3,freescreen

	lea	BB_BitMap_(BP),A0	;drawing mask
	lea	bm_Planes(A0),A0	;a0=points "right at variable" to free
	bsr.s	free1v			;free var (a0=adr), rtns a0 same
	addq.l	#4,a0			;2nd bitplane, 'tmpras' usage

;A0=Address of variable to free, RETURNS a0 unmolested
free1v:			
	xjmp	FreeOneVariable		;memories.o, frees from remember list

CloseWindowRoutine:
	move.l	(A0),D0
	beq	eawini			;no window, outta here
	clr.l	(A0)			;clear var windowptr_(bp)
	move.l	D0,A0
	xjsr	ReturnMessages		;a0=windowptr  (destroys d0/d1/a1)
;scans the 'input message list' and ReplyMsg's all
;the msgs for window a0 (for use just before CloseWindow)
	clr.l	wd_UserPort(A0)		;NEVER let intwit delete *my* port....
	DUMPMSG	<BEFORE CLOSE WINDOWX>
	CALLIB	Intuition,CloseWindow
	DUMPMSG	<AFTER CLOSE WINDOWX>
	xjmp	GraphicsWaitBlit	;wait! for closewindow's blit...
eawini:	rts

		
;a0=window variable a1=screen variable
;doesn't really closewindow, lets closescreen do it
CloseWindowAndScreen:	
  IFC 't','f' ;kludge, want...
	move.l	(A1),D0			;no screen pointed to, anyway?
	beq.s	after_scr2back
	movem.l	a0/a1,-(sp)
	move.l	d0,a0			;a0=screenptr for ->back
	xjsr	IntuScreenToBack	;CALLIB	Intuition,ScreenToBack
	movem.l	(sp)+,a0/a1
after_scr2back:
  ENDC
	move.l	a1,-(sp)
	bsr	CloseWindowRoutine
	move.l	(sp)+,a0

;A0=address of screen var
CloseScreenRoutine:	
	move.l	(A0),D0			;no screen pointed to, anyway?
	beq	zzrts
	clr.l	(A0)			;clear'd var. sez "it's gone now"
	move.l	D0,A0			;A0=screenptr
 xref FirstScreen_
	cmp.l	FirstScreen_(BP),a0	;AUG161990...helps with "whoo" + filerequester bug?
	bne.s	99$
	;clr.l	FirstScreen_(BP)
	move.l	(a0),FirstScreen_(BP)	;point to "next" screen
99$:
	DUMPMSG	<BEFORE CLOSE SCREEN>
	JMPLIB	Intuition,CloseScreen

;	rts


;****** TPaint.main/OpenInputDev ******************************************
;
;   NAME
;	OpenInputDev -- 
;
;   SYNOPSIS
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
OpenInputDev: 
	movem.l	d1-d4/a0-a6,-(sp)
	lea	OnlyPort_(BP),a0	;message port
	move.l	#IOSTD_SIZE,d0		;size of IO struct
	CALLIB	Exec,CreateIORequest	;remember to DeleteIORequest
	move.l	d0,InpStdIO_(BP)	;store the io-struct address
	beq	1$			;if no io-struct address

*	DUMPREG	<AFTER CREATEIOREQUEST>

	lea	InpName,a0		;devName
	moveq	#0,d0			;unitNumber
	move.l	InpStdIO_(BP),a1	;iORequest
	moveq	#0,d1			;flags
	CALLIB	Exec,OpenDevice
*	DUMPREG	<AFTER OPEN DEVICE>
1$
	movem.l	(sp)+,d1-d4/a0-a6
	rts	



;****** TPaint.main/CloseInputDev ******************************************
;
;   NAME
;	CloseInputDev -- 
;
;   SYNOPSIS
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
CloseInputDev: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	move.l	InpStdIO_(BP),a1	;iORequest
	CALLIB	Exec,CloseDevice
*	DUMPREG	<CloseDevice>
*	
	move.l	InpStdIO_(BP),a0	;iORequest
	CALLIB	Exec,DeleteIORequest
*	DUMPREG	<DeleteIORequest>
*
	movem.l	(sp)+,d1-d4/a0-a6
	rts	


;****** TPaint.main/BumpMouse ******************************************
;
;   NAME
;	BumpMouse -- 
;
;   SYNOPSIS
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	BumpMouse
BumpMouse: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	lea	MPM_EVENT,a0
	move.l	InpStdIO_(BP),a1
	lea	MOUSE_HERE,a2	
*
	move.w	#IND_WRITEEVENT,IO_COMMAND(a1)
	move.b	#0,IO_FLAGS(a1)
	move.l	#ie_SIZEOF,IO_LENGTH(a1)	
	move.l	a0,IO_DATA(a1)
*
	move.l	#0,ie_NextEvent(a0)
	move.l	a2,ie_EventAddress(a0)
	move.b	#IECLASS_NEWPOINTERPOS,ie_Class(a0)
	move.b	#IESUBCLASS_PIXEL,ie_SubClass(a0)
	move.w	#IECODE_NOBUTTON,ie_Code(a0)
	move.w	#0,ie_Qualifier(a0)
*
	move.l	TScreenPtr_(BP),iepp_Screen(a2)
	move.l	d1,iepp_PositionX(a2)
;	move.w	#50,iepp_PositionX(a2)
;	move.w	#50,iepp_PositionY(a2)
*
	CALLIB	Exec,DoIO
*
*	DUMPREG	<DONE DID IO!>
*
	movem.l	(sp)+,d1-d4/a0-a6
	rts	



;****** TPaint.main/OpenAlphaScreen ******************************************
;
;   NAME
;	OpenAlphaScreen -- 
;
;   SYNOPSIS
;	OpenAlphaScreen
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	OpenAlphaScreen
AlphaDepth	equ	4	
OpenAlphaScreen: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	move.l	AS_Ptr,d0
	beq	2$
	bsr	CloseAlphaScreen	
	bra	3$
2$
	move.l	ScreenPtr_(BP),a1		GetBitmap address
	lea	sc_RastPort(a1),a1
	move.l	rp_BitMap(a1),a1
	lea	bm_Planes(a1),a1		index planes 
*
	lea	AlphaBM2,a2			alpha bitmap
	lea	bm_Planes(a2),a2
	
	move.l	4*4(a1),0*4(a2)
	move.l	5*4(a1),1*4(a2)
	move.l	6*4(a1),2*4(a2)
	move.l	7*4(a1),3*4(a2)
	move.l	0*4(a1),4*4(a2)
	move.l	1*4(a1),5*4(a2)
	move.l	2*4(a1),6*4(a2)
	move.l	3*4(a1),7*4(a2)
*
	lea	AlphaBM,a2			alpha bitmap
	lea	bm_Planes(a2),a2


 ifeq	0	
	moveq	#8-1,d0				
1$
	move.l	(a1)+,(a2)+			copy plane addresses
	dbf	d0,1$	
*
 endc
	lea	AlphaScreen,a0
	CALLIB	Intuition,OpenScreen
	move.l	d0,AS_Ptr
	DUMPREG	<ALPHA SCREEN OPEN!?>
*
	lea	AlphaWindow,a0
	CALLIB	Intuition,OpenWindow
	move.l	d0,AlphaW
*
	move.l	d0,a0
	lea	OnlyPort_(BP),A1
	MOVE.L	A1,wd_UserPort(A0)
	DUMPREG	<Alpha window messages a1 window a0>
*

	MOVE.L	#MOUSEMOVE!MOUSEBUTTONS,D0	
	CALLIB	Intuition,ModifyIDCMP
*
	bsr	LoadAP16		;BuildCM256
	st	FlagAlphapaint_(BP)
	xjsr	SetAlphaBank
	
	bsr.s	SwapPtrs
3$
	movem.l	(sp)+,d1-d4/a0-a6
	rts	


SwapPtrs:
	move.l	WindowPtr_(BP),d0
	move.l	AlphaW,WindowPtr_(BP)
	move.l	d0,AlphaW
*
	move.l	ScreenPtr_(BP),d0
	move.l	AS_Ptr,ScreenPtr_(BP)
	move.l	d0,AS_Ptr
	rts



;****** TPaint.main/CloseAlphaScreen ******************************************
;
;   NAME
;	CloseAlphaScreen -- 
;
;   SYNOPSIS
;	CloseAlphaScreen
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	CloseAlphaScreen
CloseAlphaScreen: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	tst.b	FlagAlphapaint_(BP)
	beq	1$	
	bsr.s	SwapPtrs
	sf	FlagAlphapaint_(BP)
	move.l	AlphaW,d0
	beq	2$
	move.l	d0,a0
	clr.l	wd_UserPort(a0)		;Keep port safe
	CALLIB	Intuition,CloseWindow
*	
2$
	move.l	AS_Ptr,d0
	beq	1$
	move.l	d0,a0
	CALLIB	Intuition,CloseScreen
*
	move.l	#0,AS_Ptr
	movem.l	(sp)+,d1-d4/a0-a6
1$
	rts	



	xref	Alphabm_
	xdef	SaveAlpha8bm
SaveAlpha8bm:
	movem.l	d0-d4/a0-a6,-(sp)
*
	move.l	#752,d0			;width
	move.l	#480,d1			;height
	move.l	#8,d2			;depth
	moveq	#0,d3			;flags
	sub.l	a0,a0			;friend_bitmap
	bsr	AllocBitMap
	move.l	d0,(sp)
	beq	20$	
*	
	move.l	d0,a2
	lea	bm_Planes(a2),a2
	lea	BigPicRGB_+bm_Planes(BP),a3
	DUMPMEM	<BigPicRGB>,-bm_Planes(A3),#64
	move.w	#480-1,d3	
	move.l	(a3),a0			;red byte plane
	move.l	a2,a1			;output planes
	moveq	#0,d0			;start at top of screen
	move.l	#47,d1			;752 pixels
10$
	xjsr	Bytes2Planes
	lea	752(a0),a0		;width of RGB BitMap
	add.l	#94,d0			;width of screen BitMap
	dbf	d3,10$			
* open iff lib and write file	
	moveq	#0,d0
	lea	ifflibname,a1
	CALLIB	Exec,OpenLibrary
	tst.l	d0
	beq	.notopen
	move.l	d0,d6
	move.l	(sp),A1			;bitmap
	MOVE.L	D6,A6
	lea	BitMapFile,A0		filename
*	lea	Cmaptst,a2		colortable

*	sub.l	a2,a2			
	moveq	#1,d0			flags compressed
	CALLIB	SAME,IFFL_SaveBitMap	
	move.l	d6,a1
	CALLIB	Exec,CloseLibrary
.notopen
*
	move.l	(sp),a0
	DUMPMEM	<8bit alpha BM>,(A0),#64

 ifeq	0
	lea	Alphabm_(BP),a1
	move.l	(sp),a0
	move.w	#bm_SIZEOF-1,d0
1$	move.b	(a0)+,(a1)+
	dbf	d0,1$
 endc	
*	bsr	FreeBitMap
20$
	movem.l	(sp)+,d0-d4/a0-a6
	rts	


**** Initilises and Allocates the bitmap for the Alpha Loader 
	xdef	AllocateAlphaPlanes
AllocateAlphaPlanes:
	DUMPMSG	<Im gona alocate those planes!>
	movem.l	d0-d7/a0-a4,-(sp)
*
	lea	Alphabm_(BP),a1
	move.w	#94,bm_BytesPerRow(a1)		*INIT BYTES PER ROW
	move.w	#480,bm_Rows(a1)		*INIT HEIGHT
	move.b	#4,bm_Depth(a1)			*INIT DEPTH
	move.b	#0,bm_Flags(a1)			*INIT 
	move.w	#0,bm_Pad(a1)			*INIT	
	lea	bm_Planes(A1),a1		*add offset to plane pointer
	moveq	#3,d2
1$	move.l	#752,d0				*init Width
	move.l	#480,d1				*init Height
	BSR	AllocRaster			*
	move.l	d0,(a1)+
	dbf	d2,1$	

	lea	Alphabm_(BP),a1
	DUMPMEM	<>,(A0),#64	
*
*	bsr	GetAlphaTestImage
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	
 

**** Frees the Alpha planes 
	xdef	FreeAlphaPlanes
FreeAlphaPlanes:
	movem.l	d0-d7/a0-a4,-(sp)
	lea	Alphabm_(BP),a1
	move.w	#94,bm_BytesPerRow(a1)		*INIT BYTES PER ROW
	move.w	#480,bm_Rows(a1)		*INIT HEIGHT
	move.b	#4,bm_Depth(a1)			*INIT DEPTH
	move.b	#0,bm_Flags(a1)			*INIT 
	move.w	#0,bm_Pad(a1)			*INIT	
	lea	bm_Planes(A1),a1		*add offset to plane pointer
	moveq	#3,d2
1$	move.l	#752,d0				*init Width
	move.l	#480,d1				*init Height
	move.l	(a1),a0				*plane	ptr
	BSR	FreeRaster			*
	move.l	#0,(a1)+			*clear plane ptr
	dbf	d2,1$	
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	



**** Copy image to alpha planes 
	xdef	Copy2AlphaPlanes
Copy2AlphaPlanes:
	movem.l	d0-d7/a0-a4,-(sp)
	lea	Alphabm_(BP),a1
	lea	bm_Planes(a1),a4
	lea	AlphaBM,a1
	lea	bm_Planes(a1),a3
	DUMPMEM	<ALPHABM>,(A1),#64
	move.w	#4-1,d2			# of planes	
3$	move.l	#480-1,d1		line count
	move.l	(a3)+,a0		from plane
	move.l	(a4)+,a1		to plane
	DUMPREG	<processing plane>	
2$	move.l	#94-1,d0		byte count
1$	move.b	(a0)+,(a1)+
	dbf	d0,1$			pixel	
	lea	2(a0),a0		modulo
	dbf	d1,2$			Row
	dbf	d2,3$			plane
	movem.l	(sp)+,d0-d7/a0-a4
	rts	


	xdef	GetAlphaTestImage
GetAlphaTestImage:
	movem.l	d0-d7/a0-a4,-(sp)
	DUMPMSG	<loading test image>	
	moveq	#0,d0
	lea	ifflibname,a1
	CALLIB	Exec,OpenLibrary
	DUMPREG	<After open ifflib>	
	tst.l	d0
	beq	.notopen
	move.l	d0,a6
	DUMPMSG	<IFFLib open>
*	
	lea	AlpahTImg,a0
	DUMPMEM	<Filename>,(A0),#64
*	move.l	#IFFL_MODE_READ,d0
	moveq	#0,d0			;read=0
	CALLIB	SAME,IFFL_OpenIFF	
	DUMPREG	<After open iff>
*
	move.l	d0,d5
	beq	.TestLoadPanic
	DUMPREG	<Test image open>
*
	move.l	d5,a1
	lea	Alphabm_(BP),A0					;bitmap
	DUMPMEM	<alpha bitmap>,(A1),#64
	CALLIB	SAME,IFFL_DecodePic
	DUMPREG	<Alpha test image Loaded OK?>	
*
	move.l	d5,a1
	CALLIB	SAME,IFFL_CloseIFF
.TestLoadPanic
	move.l	a6,a1
	CALLIB	Exec,CloseLibrary
.notopen
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	



AlphaSave	equ	1
 ifd AlphaSave
	XDEF	AlphaSaveBM
AlphaSaveBM:
	movem.l	d0-d7/a0-a4,-(sp)
	moveq	#0,d0
	lea	ifflibname,a1
	CALLIB	Exec,OpenLibrary
	tst.l	d0
	beq	.notopen
	move.l	d0,d6
	
	lea	Alphabm_(BP),A1		;bitmap
	DUMPMEM	<alpha bitmap>,(A1),#64
*	bra	.skpsave

	MOVE.L	D6,A6
	lea	BitMapFile,A0		filename
	lea	AlphaCM16,a2		colortable
*	sub.l	a2,a2			
	moveq	#1,d0			flags compressed
*
	moveq	#0,d1
	moveq	#0,d2
	move.l	#94,d3
	move.l	#480,d4
*
	CALLIB	SAME,IFFL_SaveClip	
*
.skpsave		
	move.l	d6,a1
	CALLIB	Exec,CloseLibrary
.notopen
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	
 endc

	XDEF	SaveAlphaTestBM
SaveAlphaTestBM:
	movem.l	d0-d7/a0-a4,-(sp)
	moveq	#0,d0
	lea	ifflibname,a1
	CALLIB	Exec,OpenLibrary
	tst.l	d0
	beq	.notopen
	move.l	d0,d6
	
	lea	Alphabm_(BP),A1		;bitmap
	MOVE.L	D6,A6
	lea	BitMapFile,A0		filename
	lea	AlphaCM16,a2		colortable
	moveq	#1,d0			flags compressed
	CALLIB	SAME,IFFL_SaveBitMap	
*
.skpsave		
	move.l	d6,a1
	CALLIB	Exec,CloseLibrary
.notopen
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	





**********************************************************************
*	bitmap=AllocBitMap(sizex,sizey,depth, flags, friend_bitmap)
*		           d0    d1    d2     d3       a0
**********************************************************************
AllocBitMap:
	MOVEM.L	D0-D6/A0-A6,-(A7)
	MOVE.L	#0,(BP)
*	
	MOVE.W	D0,D5				*Width
	MOVE.W	D1,D6				*Height
*
	MOVE.L	#bm_SIZEOF+4*24,d0	
	MOVE.L	#MEMF_PUBLIC!MEMF_CLEAR,D1
	CALLIB	Exec,AllocMem
	TST.L	D0
	BEQ	2$
	MOVE.L	D0,A4				*BM STRUCT BASE ADDRESS
	MOVE.L	D0,(A7)				*RETURN STRUCT
*
	MOVE.B	D2,bm_Depth(A4)			*INIT DEPTH
	MOVEQ	#0,D4				*INIT COUNTER FOR PLANES
	MOVE.B	D2,D4				*	
	MOVE.W	D6,bm_Rows(A4)			*INIT HEIGHT
	MOVE.B	#0,bm_Flags(A4)			*INIT 
	MOVE.W	#0,bm_Pad(A4)			*INIT
	MOVE.W	D5,D0
	ASR.W	#3,D0				*CALC BYTES PER ROW
	MOVE.W	D0,bm_BytesPerRow(A4)		*INIT BYTES PER ROW
	LEA	bm_Planes(A4),A4		*OFFSET TO PLANES	
	BRA	1$
10$
	MOVE.W	D5,D0				*W
	MOVE.W	D6,D1				*H
*	MOVE.L	GFXBase,a6			*
*	CALLIB	Exec,AllocRaster		*
	BSR	AllocRaster			*
	MOVE.L	D0,(A4)+			*STORE BITPLANE ADDRESS
	TST.L	D0				*
	BEQ	3$
1$	DBF	D4,10$				*LOOP UNTIL
2$
	MOVEM.L	(A7)+,D0-D6/A0-A6
	RTS

* NO MEMORY PARTWAY THROUGH ALLOCATION *
3$	MOVE.L	(SP),A0
	BSR	FreeBitMap
	MOVE.L	#0,(SP)
	MOVEM.L	(A7)+,D0-D6/A0-A6
	RTS

***************************************************************************************
*	FreeBitMap(bm)
*	           a0
***************************************************************************************
FreeBitMap:
	MOVEM.L	D0-D6/A0-A6,-(A7)
	MOVE.L	a0,A4
	MOVE.L	a0,D4
*
	MOVEQ	#0,D2
*	MOVE.B	bm_Depth(A4),D2
	MOVE.B	#25,D2
*
	MOVE.W	bm_Rows(A4),D6
	MOVE.W	bm_BytesPerRow(A4),D5
	ASL	#3,D5
*
	LEA	bm_Planes(A4),A4		*OFFSET TO PLANES
	LEA	4*25(A4),A4			*OFFSET TO END OF PLANES+1	
	BRA	1$
10$
*	MOVE.L	GFXBase,a6
	MOVE.W	D6,D1
	MOVE.W	D5,D0
	MOVE.L	-(A4),D3
	BEQ	1$
	MOVE.L	D3,A0
*	XSYS	FreeRaster			*FreeRaster( p(A0), width(D0), height(D1))
	BSR	FreeRaster
1$	DBF	D2,10$				*LOOP UNTIL
	MOVE.L	D4,A1
	MOVE.L	#bm_SIZEOF+4*24,D0
	CALLIB	Exec,FreeMem
	MOVEM.L	(A7)+,D0-D6/A0-A6
	RTS

***********************************************************************************************************
* d0 - width(d0),height(d1)	
***********************************************************************************************************
AllocRaster:
	MOVEM.L	D0-D6/A0-A6,-(A7)
	AND.L	#$0000FFFF,D0
	AND.L	#$0000FFFF,D1
	ASR	#3,D0
	MULU	D1,D0
	AND.L	#$0000FFFF,D0
	MOVE.L	#MEMF_FAST,D1
*	MOVE.L	#MEMF_CHIP,D1
	CALLIB	Exec,AllocMem	
	MOVE.L	D0,(SP)	
	MOVEM.L	(A7)+,D0-D6/A0-A6
	RTS

***********************************************************************************************************
* ptr(a0),width(d0),height(d1)
***********************************************************************************************************
FreeRaster:
	MOVEM.L	D0-D6/A0-A6,-(A7)
	AND.L	#$0000FFFF,D0
	AND.L	#$0000FFFF,D1
	ASR	#3,D0
	MULU	D1,D0
	AND.L	#$0000FFFF,D0  
	MOVE.L	A0,A1		;free base page memory
	CALLIB	Exec,FreeMem
	MOVEM.L	(A7)+,D0-D6/A0-A6
	RTS


 ifeq	1
AlphaSave	equ	1
 ifd AlphaSave
	XDEF	AlphaSaveBM
AlphaSaveBM:
	movem.l	d0-d7/a0-a4,-(sp)
	moveq	#0,d0
	lea	ifflibname,a1
	CALLIB	Exec,OpenLibrary
	tst.l	d0
	beq	.notopen
	move.l	d0,d6
	
	lea	AlphaBM,A1		;bitmap
	DUMPMEM	<alpha bitmap>,(A1),#64
*	bra	.skpsave

	MOVE.L	D6,A6
	lea	BitMapFile,A0		filename
	lea	AlphaCM16,a2		colortable
*	sub.l	a2,a2			
	moveq	#1,d0			flags compressed
*
	CALLIB	SAME,IFFL_SaveBitMap	
*
.skpsave		
	move.l	d6,a1
	CALLIB	Exec,CloseLibrary
.notopen
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	
 endc
 endc


 ifd SaveTheBitMap
	XDEF	SaveBM
SaveBM:
	movem.l	d0-d7/a0-a4,-(sp)
	moveq	#0,d0
	lea	ifflibname,a1
	CALLIB	Exec,OpenLibrary
	tst.l	d0
	beq	.notopen
	move.l	d0,d6
	
	lea	AlphaBM,A1		;bitmap

	MOVE.L	D6,A6
	lea	BitMapFile,A0		filename
*	lea	cmap,a2			colortable
	sub.l	a2,a2			
	moveq	#1,d0			flags compressed
*
	CALLIB	SAME,IFFL_SaveBitMap	
*		
	move.l	d6,a1
	CALLIB	Exec,CloseLibrary
.notopen
	movem.l	(sp)+,d0-d7/a0-a4
	RTS	
 endc



;****** TPaint.main/UpdateAlphaLine ******************************************
;
;   NAME
;	UpdateAlpaLine -- Copys 1 line of Red byteplane to 8 planes of AlphaBM.
;
;   SYNOPSIS
;	UpdateAlphaLine(linenumber);
;			d0	
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	UpdateAlphaLine
UpdateAlphaLine: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	lea	AlphaBM2,a2
	lea	bm_Planes(a2),a2
*
	lea	BigPicRGB_+bm_Planes(BP),a3
*	
	move.w	#480-1,d3	
	move.l	(a3),a0			;red byte plane
	move.l	a2,a1			;output planes
	moveq	#0,d0			;start at top of screen
	move.l	#47,d1			;752 pixels
10$
	xjsr	Bytes2Planes
	lea	752(a0),a0		;width of RGB BitMap
	add.l	#96,d0			;width of screen BitMap
	dbf	d3,10$			
*	
	movem.l	(sp)+,d1-d4/a0-a6
	rts	



	xdef	sayplot
sayplot:
	DUMPREG	<SAYPLOT>
	rts	


;****** TPaint.main/UpdateAlphaScreen ******************************************
;
;   NAME
;	UpdateAlpaScreen -- Copys Red byteplane into the 8 planes of AlphaBM.
;
;   SYNOPSIS
;	UpdateAlphaScreen
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	UpdateAlphaScreen
UpdateAlphaScreen: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	lea	AlphaBM2,a2
	lea	bm_Planes(a2),a2
*
	lea	BigPicRGB_+bm_Planes(BP),a3
*	
	move.w	#480-1,d3	
	move.l	(a3),a0			;red byte plane
	move.l	a2,a1			;output planes
	moveq	#0,d0			;start at top of screen
	move.l	#47,d1			;752 pixels
10$
	xjsr	Bytes2Planes
	lea	752(a0),a0		;width of RGB BitMap
	add.l	#96,d0			;width of screen BitMap
	dbf	d3,10$			
*	
	movem.l	(sp)+,d1-d4/a0-a6
	rts	

 ifeq	1
;****** TPaint.main/BuildCM256 ******************************************
;
;   NAME
;	BuildCM256 -- 
;
;   SYNOPSIS
;	BuildCM256
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	BuildCM256
BuildCM256: 
	movem.l	d0-d4/a0-a6,-(sp)
*
	move.l	#MEMF_FAST,D1
	move.l	#256*4*3+50,d0
	CALLIB	Exec,AllocMem
	tst.l	d0
	beq	.totalpanic
	move.l	d0,d6			;colormap addr
*
	move.l	d6,a3			;colormap addr
	move.w	#256,(a3)+		;Number of colors 
	move.w	#0,(a3)+		;Color to start at
*
	moveq	#0,d0			;counter
10$
	move.l	#$ffffffff,(a3)		;RED
	move.b	d0,(a3)
*
	bset.b	#1,(a3)			;set up alpha bit
	btst	#4,d0
	bne	21$		
	bclr.b	#1,(a3)
21$	
	lea	4(a3),a3
*
	move.l	#$ffffffff,(a3)		;GREEN
	move.b	d0,(a3)
	bset.b	#1,(a3)
	btst	#5,d0
	bne	22$
	bclr.b	#1,(a3)
22$
	lea	4(a3),a3
*
	move.l	#$ffffffff,(a3)		;BLUE
	move.b	d0,(a3)
	bset.b	#0,(a3)
	btst	#6,d0
	bne	23$
	bclr.b	#0,(a3)	
23$
	bset.b	#1,(a3)
	btst	#7,d0
	bne	24$
	bclr.b	#1,(a3)	
24$
	lea	4(a3),a3
*
	addq	#1,d0			;next color
30$
	cmp.w	#256,d0
	blt	10$
*
	move.l	#0,(a3)
	move.l	AS_Ptr,a0
	lea	sc_ViewPort(a0),a0
	move.l	d6,a1			;colormap addr
*	CALLIB	Graphics,LoadRGB32	
*
	move.l	d6,a1			;colormap addr
	move.l	#256*3*4+50,d0
	CALLIB	Exec,FreeMem
.totalpanic	
	movem.l	(sp)+,d0-d4/a0-a6
	rts	
 endc

;****** TPaint.main/LoadAP16 ******************************************
;
;   NAME
;	LoadAP16 -- 
;
;   SYNOPSIS
;	LoadAP16
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	LoadAP16
LoadAP16:
	movem.l	d0-d4/a0-a6,-(sp)
	move.l	AS_Ptr,a0
	lea	sc_ViewPort(a0),a0		;get vp address
	moveq	#16,d0
*	lea	Alphatest,a1			;just gray palette
	lea	AlphaCM16,a1			;alpha color palette
*
	CALLIB	Graphics,LoadRGB4	
	movem.l	(sp)+,d0-d4/a0-a6
	rts	



;****** TPaint.main/OpenLRScreen ******************************************
;
;   NAME
;	OpenLRScreen -- 
;
;   SYNOPSIS
;	OpenLRScreen
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	OpenLRScreen
OpenLRScreen: 
	movem.l	d1-d4/a0-a6,-(sp)
*
	move.l	LR_Ptr,d0
	beq	2$
	bsr	CloseLRScreen	
	bra	3$
2$
	move.l	ScreenPtr_(BP),a1		GetBitmap address
	lea	sc_RastPort(a1),a1
	move.l	rp_BitMap(a1),a1
	lea	bm_Planes(a1),a1		index planes 
*
	lea	LRBM,a2				alpha bitmap
	lea	bm_Planes(a2),a2

 ifeq	0	
	moveq	#8-1,d0				
1$
	move.l	(a1)+,(a2)+			copy plane addresses
	dbf	d0,1$	
*
 endc
	lea	LRScreen,a0
	CALLIB	Intuition,OpenScreen
	move.l	d0,LR_Ptr
*	DUMPREG	<LR SCREEN OPEN!?>
*
	lea	LRWindow,a0
	CALLIB	Intuition,OpenWindow
	move.l	d0,LRW
*
	move.l	d0,a0
	lea	OnlyPort_(BP),A1
	MOVE.L	A1,wd_UserPort(A0)
*	DUMPREG	<LR window messages a1 window a0>
*

	MOVE.L	#MOUSEMOVE!MOUSEBUTTONS,D0	
	CALLIB	Intuition,ModifyIDCMP
*
	st	FlagLRpaint_(BP)
	
	bsr	SwapPtrsLR
3$
	movem.l	(sp)+,d1-d4/a0-a6
	rts	


SwapPtrsLR:
	move.l	WindowPtr_(BP),d0
	move.l	LRW,WindowPtr_(BP)
	move.l	d0,LRW
*
	move.l	ScreenPtr_(BP),d0
	move.l	LR_Ptr,ScreenPtr_(BP)
	move.l	d0,LR_Ptr
	rts



;****** TPaint.main/CloseLRScreen ******************************************
;
;   NAME
;	CloseLRScreen -- 
;
;   SYNOPSIS
;	CloseLRScreen
;
;   FUNCTION
;
;   INPUTS
;
;   RESULT
;
;   EXAMPLE
;
;   NOTES
;
;   BUGS
;
;   SEE ALSO
;
;****************************************************************************      
	XDEF	CloseLRScreen
CloseLRScreen: 
	movem.l	d1-d4/a0-a6,-(sp)
*	
	bsr	SwapPtrsLR
	sf	FlagLRpaint_(BP)
	move.l	LRW,d0
	beq	2$
	move.l	d0,a0
	clr.l	wd_UserPort(a0)		;Keep port safe
	CALLIB	Intuition,CloseWindow
*	
2$
	move.l	LR_Ptr,d0
	beq	1$
	move.l	d0,a0
	CALLIB	Intuition,CloseScreen
*
	move.l	#0,LR_Ptr
	movem.l	(sp)+,d1-d4/a0-a6
1$
	rts	


	ALLDUMPS

	xdef	AlphaBM
	
AlphaW:	dc.l	0

AlphaScreen:
	dc.w	-72,-46,752,480		;WORDs sc_LeftEdge,top,wt,ht
	dc.w	AlphaDepth			;Depth 
	DC.B 	4			;DetailPen color / gadgets and text in title bar
 	DC.B 	0			;BlockPen  // Bar color
	dc.w	V_HIRES!V_LACE		;ViewModes
	dc.w	CUSTOMSCREEN!SCREENQUIET!CUSTOMBITMAP ;,ns_Type(A0)
	dc.l	0	 		;Font
	dc.l	0,0,AlphaBM		;screentitle,gadgets,custombitmap


AlphaBM:
	dc.w	96	;bm_BytesPerRow
	dc.w	480	;bm_Rows
	dc.b	0	;bm_Flags
	dc.b	AlphaDepth ;bm_Depth
	dc.w	0	;bm_Pad
	dc.l	0	;bm_Planes,8*4 1
	dc.l	0	;2
	dc.l	0	;3
	dc.l	0	;4	
	dc.l	0	;5
	dc.l	0	;6
	dc.l	0	;7
	dc.l	0	;8



	xdef	AlphaBM2
AlphaBM2:
	dc.w	96	;bm_BytesPerRow
	dc.w	480	;bm_Rows
	dc.b	0	;bm_Flags
	dc.b	AlphaDepth ;bm_Depth
	dc.w	0	;bm_Pad
	dc.l	0	;bm_Planes,8*4 1
	dc.l	0	;2
	dc.l	0	;3
	dc.l	0	;4	
	dc.l	0	;5
	dc.l	0	;6
	dc.l	0	;7
	dc.l	0	;8



AlphaWindow:		;
	dc.w 0		;LeftEdge 0
	dc.w 0		;TopEdge
	dc.w 752	;Width
	dc.w 480	;Height
	dc.b 4		;DetailPen 2=blck
	dc.b 1		;BlockPen 1=ltgray
	dc.l 0		;IDCMP flags
ALWIN	SET	BORDERLESS!GIMMEZEROZERO!REPORTMOUSE!NOCAREREFRESH!RMBTRAP
ALWIN2	SET	ALWIN!SIMPLE_REFRESH
	dc.l ALWIN2	  
	dc.l 0		;FirstGadget
	dc.l 0 		;CheckMark	
	dc.l 0		;*Title
AS_Ptr:	dc.l 0		;*Screen
	dc.l 0		;*BitMap
	dc.w 20		;MinWidth
	dc.w 20		;MinHeight
	dc.w 800	;MaxWidth
	dc.w 800	;MaxHeight 
	dc.w CUSTOMSCREEN	;Screen Type



AlphaCM16:	;    red grn blue
	dc.w	%0000000000000000		;0
	dc.w	%0000001000000000		;1
	dc.w	%0000000000100000		;2
	dc.w	%0000001000100000		;3
	dc.w	%0000010001000101		;4
	dc.w	%0000011001000101		;5
	dc.w	%0000010001100101		;6
	dc.w	%0000011001100101		;7
	dc.w	%0000100010001010		;8
	dc.w	%0000101010001010		;9
	dc.w	%0000100010101010		;10
	dc.w	%0000101010101010		;11
	dc.w	%0000110011001111		;12
	dc.w	%0000111011001111		;13
	dc.w	%0000110011101111		;14
	dc.w	%0000111011101111		;15

Alphatest:	
	dc.w	$0000
	dc.w	$0111
	dc.w	$0222
	dc.w	$0333
	dc.w	$0444
	dc.w	$0555
	dc.w	$0666
	dc.w	$0777
	dc.w	$0888
	dc.w	$0999
	dc.w	$0aaa
	dc.w	$0bbb
	dc.w	$0ccc
	dc.w	$0ddd
	dc.w	$0eee
	dc.w	$0fff
	
 ifeq 1
Cmaptst:
	dc.l	$FFFFFF00
	dc.l	$00000000
	dc.l	$FEFEFE00
	dc.l	$FDFDFD00
	dc.l	$FCFCFC00
	dc.l	$FBFBFB00
	dc.l	$FAFAFA00
	dc.l	$F9F9F900
	dc.l	$F8F8F800
	dc.l	$F7F7F700
	dc.l	$F6F6F600
	dc.l	$F5F5F500
	dc.l	$F4F4F400
	dc.l	$F3F3F300
	dc.l	$2F2F2F00
	dc.l	$1F1F1F00
	dc.l	$0F0F0F00
	dc.l	$FEFEFE00
	dc.l	$EEEEEE00
	dc.l	$DEDEDE00
	dc.l	$CECECE00
	dc.l	$BEBEBE00
	dc.l	$AEAEAE00
	dc.l	$9E9E9E00
	dc.l	$8E8E8E00
	dc.l	$7E7E7E00
	dc.l	$6E6E6E00
	dc.l	$5E5E5E00
	dc.l	$4E4E4E00
	dc.l	$3E3E3E00
	dc.l	$2E2E2E00
	dc.l	$1E1E1E00
	dc.l	$0E0E0D00
	dc.l	$FDFDFD00
	dc.l	$EDEDED00
	dc.l	$DDDDDD00
	dc.l	$CDCDCD00
	dc.l	$BDBDBD00
	dc.l	$ADADAD00
	dc.l	$9D9D9D00
	dc.l	$8D8D8D00
	dc.l	$7D7D7D00
	dc.l	$6D6D6D00
	dc.l	$5D5D5D00
	dc.l	$4D4D4D00
	dc.l	$3D3D3D00
	dc.l	$2D2D2D00
	dc.l	$1D1D1D00
	dc.l	$0D0D0D00
	dc.l	$FCFCFC00
	dc.l	$ECECEC00
	dc.l	$DCDCDC00
	dc.l	$CCCCCC00
	dc.l	$BCBCBC00
	dc.l	$ACACAC00
	dc.l	$9C9C9C00
	dc.l	$8C8C8C00
	dc.l	$7C7C7C00
	dc.l	$6C6C6C00
	dc.l	$5C5C5C00
	dc.l	$4C4C4C00
	dc.l	$3C3C3C00
	dc.l	$2C2C2C00
	dc.l	$1C1C1C00
	dc.l	$0C0C0B00
	dc.l	$FBFBFB00
	dc.l	$EBEBEB00
	dc.l	$DBDBDB00
	dc.l	$CBCBCB00
	dc.l	$BBBBBB00
	dc.l	$ABABAB00
	dc.l	$9B9B9B00
	dc.l	$8B8B8B00
	dc.l	$7B7B7B00
	dc.l	$6B6B6B00
	dc.l	$5B5B5B00
	dc.l	$4B4B4B00
	dc.l	$3B3B3B00
	dc.l	$2B2B2B00
	dc.l	$1B1B1B00
	dc.l	$0B0B0A00
	dc.l	$FAFAFA00
	dc.l	$EAEAEA00
	dc.l	$DADADA00
	dc.l	$CACACA00
	dc.l	$BABABA00
	dc.l	$AAAAAA00
	dc.l	$9A9A9A00
	dc.l	$8A8A8A00
	dc.l	$7A7A7A00
	dc.l	$6A6A6A00
	dc.l	$5A5A5A00
	dc.l	$4A4A4A00
	dc.l	$3A3A3A00
	dc.l	$2A2A2A00
	dc.l	$1A1A1A00
	dc.l	$0A0A0900
	dc.l	$F9F9F900
	dc.l	$E9E9E900
	dc.l	$D9D9D900
	dc.l	$C9C9C900
	dc.l	$B9B9B900
	dc.l	$A9A9A900
	dc.l	$99999900
	dc.l	$89898900
	dc.l	$79797900
	dc.l	$69696900
	dc.l	$59595900
	dc.l	$49494900
	dc.l	$39393900
	dc.l	$29292900
	dc.l	$19191900
	dc.l	$09090800
	dc.l	$F8F8F800
	dc.l	$E8E8E800
	dc.l	$D8D8D800
	dc.l	$C8C8C800
	dc.l	$B8B8B800
	dc.l	$A8A8A800
	dc.l	$98989800
	dc.l	$88888800
	dc.l	$78787800
	dc.l	$68686800
	dc.l	$58585800
	dc.l	$48484800
	dc.l	$3B3B3B00
	dc.l	$2B2B2B00
	dc.l	$1B1B1B00
	dc.l	$0B0B0B00
	dc.l	$FAFAFA00
	dc.l	$EAEAEA00
	dc.l	$DADADA00
	dc.l	$CACACA00
	dc.l	$BABABA00
	dc.l	$AAAAAA00
	dc.l	$9A9A9A00
	dc.l	$8A8A8A00
	dc.l	$7A7A7A00
	dc.l	$6A6A6A00
	dc.l	$5A5A5A00
	dc.l	$4A4A4A00
	dc.l	$3A3A3A00
	dc.l	$2A2A2A00
	dc.l	$1A1A1A00
	dc.l	$0A0A0A00
	dc.l	$F9F9F900
	dc.l	$E9E9E900
	dc.l	$D9D9D900
	dc.l	$C9C9C900
	dc.l	$B9B9B900
	dc.l	$A9A9A900
	dc.l	$99999900
	dc.l	$89898900
	dc.l	$79797900
	dc.l	$69696900
	dc.l	$59595900
	dc.l	$49494900
	dc.l	$39393900
	dc.l	$29292900
	dc.l	$19191900
	dc.l	$09090800
	dc.l	$F8F8F800
	dc.l	$E8E8E800
	dc.l	$D8D8D800
	dc.l	$C8C8C800
	dc.l	$B8B8B800
	dc.l	$A8A8A800
	dc.l	$98989800
	dc.l	$88888800
	dc.l	$78787800
	dc.l	$68686800
	dc.l	$58585800
	dc.l	$48484800
	dc.l	$38383800
	dc.l	$28282800
	dc.l	$18181800
	dc.l	$08080800
	dc.l	$F7F7F700
	dc.l	$E7E7E700
	dc.l	$D7D7D700
	dc.l	$C7C7C700
	dc.l	$B7B7B700
	dc.l	$A7A7A700
	dc.l	$97979700
	dc.l	$87878700
	dc.l	$77777700
	dc.l	$67676700
	dc.l	$57575700
	dc.l	$47474700
	dc.l	$37373700
	dc.l	$27272700
	dc.l	$17171700
	dc.l	$07070600
	dc.l	$F6F6F600
	dc.l	$E6E6E600
	dc.l	$D6D6D600
	dc.l	$C6C6C600
	dc.l	$B6B6B600
	dc.l	$A6A6A600
	dc.l	$96969600
	dc.l	$86868600
	dc.l	$76767600
	dc.l	$66666600
	dc.l	$56565600
	dc.l	$46464600
	dc.l	$36363600
	dc.l	$26262600
	dc.l	$16161600
	dc.l	$06060500
	dc.l	$F5F5F500
	dc.l	$E5E5E500
	dc.l	$D5D5D500
	dc.l	$C5C5C500
	dc.l	$B5B5B500
	dc.l	$A5A5A500
	dc.l	$95959500
	dc.l	$85858500
	dc.l	$75757500
	dc.l	$65656500
	dc.l	$55555500
	dc.l	$45454500
	dc.l	$35353500
	dc.l	$25252500
	dc.l	$15151500
	dc.l	$05050500
	dc.l	$F4F4F400
	dc.l	$E4E4E400
	dc.l	$D4D4D400
	dc.l	$C4C4C400
	dc.l	$B4B4B400
	dc.l	$A4A4A400
	dc.l	$94949400
	dc.l	$84848400
	dc.l	$74747400
	dc.l	$64646400
	dc.l	$54545400
	dc.l	$44444400
	dc.l	$34343400
	dc.l	$24242400
	dc.l	$14141400
	dc.l	$04040300
	dc.l	$F3F3F300
	dc.l	$E3E3E300
	dc.l	$D3D3D300
	dc.l	$C3C3C300
	dc.l	$B3B3B300
	dc.l	$A3A3A300
	dc.l	$93939300
	dc.l	$83838300
	dc.l	$73737300
	dc.l	$63636300
	dc.l	$53535300
	dc.l	$43434300
	dc.l	$33333300
	dc.l	$23232300
	dc.l	$13131300
	dc.l	$03030200
	dc.l	$F2F2F200
	dc.l	$E2E2E200
	dc.l	$D2D2D200
	dc.l	$C2C2C200
	dc.l	$B2B2B200
	dc.l	$A2A2A200
	dc.l	$92929200
	dc.l	$82828200
	dc.l	$72727200
	dc.l	$62626200
	dc.l	$52525200
	dc.l	$42424200
	dc.l	$32323200
	dc.l	$22222200
	dc.l	$12121200
	dc.l	$02020100
	dc.l	$F1F1F100
	dc.l	$E1E1E100
	dc.l	$D1D1D100
	dc.l	$C1C1C100
	dc.l	$B1B1B100
	dc.l	$A1A1A100
	dc.l	$91919100
	dc.l	$81818100
	dc.l	$71717100
	dc.l	$61616100
	dc.l	$51515100
	dc.l	$41414100
	dc.l	$31313100
	dc.l	$21212100
	dc.l	$11111100
	dc.l	$01010000
	dc.l	$F0F0F000
	dc.l	$E0E0E000
	dc.l	$D0D0D000
	dc.l	$C0C0C000
	dc.l	$B0B0B000
	dc.l	$A0A0A000
	dc.l	$90909000
	dc.l	$80808000
	dc.l	$70707000
	dc.l	$60606000
	dc.l	$50505000
	dc.l	$40404000
	dc.l	$30303000
	dc.l	$20202000
	dc.l	$10101000
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
	dc.l	$ffffff00
 endc

LRScreen:
	dc.w	-31,-15,352,220		;-72,-46,752,480 ;WORDs sc_LeftEdge,top,wt,ht
	dc.w	8			;Depth 
	DC.B 	4			;DetailPen color / gadgets and text in title bar
 	DC.B 	0			;BlockPen  // Bar color
	dc.w	V_HAM			;;V_HIRES!V_LACE		;ViewModes
	dc.w	CUSTOMSCREEN!SCREENQUIET!CUSTOMBITMAP ;,ns_Type(A0)
	dc.l	0	 		;Font
	dc.l	0,0,LRBM		;screentitle,gadgets,custombitmap


LRBM:
	dc.w	96	;bm_BytesPerRow
	dc.w	480	;bm_Rows
	dc.b	0	;bm_Flags
	dc.b	8	;bm_Depth
	dc.w	0	;bm_Pad
	dc.l	0	;bm_Planes,8*4 1
	dc.l	0	;2
	dc.l	0	;3
	dc.l	0	;4	
	dc.l	0	;5
	dc.l	0	;6
	dc.l	0	;7
	dc.l	0	;8



LRW	dc.l	0


LRWindow:		;
	dc.w 0		;LeftEdge 0
	dc.w 0		;TopEdge
	dc.w 352	;Width
	dc.w 220	;Height
	dc.b 4		;DetailPen 2=blck
	dc.b 1		;BlockPen 1=ltgray
	dc.l 0		;IDCMP flags
LRWIN	SET	BORDERLESS!GIMMEZEROZERO!REPORTMOUSE!NOCAREREFRESH!RMBTRAP
LRWIN2	SET	ALWIN!SIMPLE_REFRESH
	dc.l ALWIN2	  
	dc.l 0		;FirstGadget
	dc.l 0 		;CheckMark	
	dc.l 0		;*Title
LR_Ptr:	dc.l 0		;*Screen
	dc.l 0		;*BitMap
	dc.w 20		;MinWidth
	dc.w 20		;MinHeight
	dc.w 800	;MaxWidth
	dc.w 800	;MaxHeight 
	dc.w CUSTOMSCREEN	;Screen Type

	dc.b	0
AlpahTImg:	dc.b	'dos1:AlphaImage',0,0,0,0

MOUSEPUSHER:
	DC.L	0
***
	dc.l	'JAMI'!$80818283
	dc.l	'E PU'!$84858687
	dc.l	'RDON'!$88898A8B
	dc.l	' Not'!$8C8D8E8F
***
InpName
	dc.b 	'input.device',0
OkString
	dc.b	'OK',0

; ifd SaveTheBitMap
ifflibname:
	dc.b	'iff.library',0	

BitMapFile:
	dc.b	'ram:mask.iff',0
; endc


	DC.L	0
MPM_EVENT:
	DCB.B	ie_SIZEOF	

MOUSE_HERE:
	DCB.B	IEPointerPixel_SIZEOF


   END

