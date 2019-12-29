*********************************************************************
*
* flyerscsi.device - Attaches Amiga SCSI applications to Flyer SCSI bus
*
* $Id: SCSIDev.asm,v 1.3 1995/12/20 16:41:28 pfrench Exp $
*
* $Log: SCSIDev.asm,v $
*Revision 1.3  1995/12/20  16:41:28  pfrench
*Only modified debugging a little bit
*
*Revision 1.2  1995/11/06  14:37:34  Flick
*Added just a bit more debugging (direct data ptr)
*
*Revision 1.1  1995/09/06  12:55:40  Flick
*Now waits to talk to flyer until I see it's fully up
*Rev bumped to 1.3 (shipped with 4.06b)
*
*Revision 1.0  1995/05/05  15:52:36  Flick
*FirstCheckIn
*
*
* Copyright (c) 1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
* 09/02/94	Marty	Created
*********************************************************************
* This device allows any application on the Amiga which can work
* with standard SCSI devices to use similar devices on one of the
* Flyer's SCSI channels
*
* -- 1.1 --
* 01-13-95	Now remaps unit numbers from Amiga style to Flyer style
*
* -- 1.2 --
* 02-08-95	Kill's a unit's task when all openers are gone
*
*********************************************************************

	include "exec/types.i"
	include "exec/initializers.i"
	include "exec/resident.i"
	include "exec/io.i"
	include "exec/ables.i"
	include "exec/errors.i"
	include "exec/tasks.i"
	include "exec/memory.i"
	include "devices/scsidisk.i"

;	include "assembler.i"
	include "asmsupp.i"
;	include "macros.i"
	include "serialdebug.i"
	include "flyscsi.i"
	include "flyerlib.i"
	include "flyer.i"

	INT_ABLES			;Macro from exec/ables.i

SERDEBUG	equ	0

	IFNE	SERDEBUG
*DEBUGINIT	equ	1
*DEBUGCMD	equ	1
DEBUGDIRECT	equ	1
*DEBUGVERBOSE	equ	1
*DEBUGGEN	equ	1
*DEBUGIFACE	equ	1
*DEBUGTASK	equ	1
	ENDC


************************************************************************
*
*       Standard Program Entry Point
*
************************************************************************

;----- Do nothing when executed
FirstAddress:
	moveq	#-1,d0
	rts

;-------------------------------------------------------------------------
;A romtag structure.  After the device is brought in from disk, the
;disk image will be scanned for this structure to discover magic constants
;(such as where to start running me from...)
;-------------------------------------------------------------------------

MyOwnTag:			;STRUCTURE RT,0
	DC.W	RTC_MATCHWORD	;UWORD RT_MATCHWORD	(Magic cookie)
	DC.L	MyOwnTag	;APTR  RT_MATCHTAG	(Back pointer)
	DC.L	EndCode		;APTR  RT_ENDSKIP	(To end of this hunk)
	DC.B	RTF_AUTOINIT	;UBYTE RT_FLAGS		(magic-see "Init:")
	DC.B	MYVERSION	;UBYTE RT_VERSION
	DC.B	NT_DEVICE	;UBYTE RT_TYPE		(must be correct)
	DC.B	MYPRI		;BYTE  RT_PRI
	DC.L	TheDevName	;APTR  RT_NAME		(exec name)
	DC.L	IDstring	;APTR  RT_IDSTRING	(text string)
	DC.L	Init		;APTR  RT_INIT
				;LABEL RT_SIZE

;----- Release version/revision number
MYVERSION:	EQU	1
MYREVISION:	EQU	3

;----- This is the name that the device will have
TheDevName:	DC.B   'flyerscsi.device',0

Copyright:	dc.b	'Copyright © 1995 NewTek, Inc.',0
WhoDoedIt:	dc.b	'Written by Marty Flickinger',0

;----- An identifier to help in supporting the device
;----- Format is 'name version.revision (dd.dd.yy)',LF,CR,NULL
RevString:	dc.b	'$VER: '
IDstring:	dc.b	'flyerscsi.device 1.30 (06.09.95)',10,13,0

FlyerLibName	dc.b	'flyer.library',0

;----- Force word alignment
	CNOP	0,2

;----- The romtag specified that we were "RTF_AUTOINIT".  This means that
;----- the RT_INIT structure member points to one of these tables
Init:	dc.l	FlyScsiDev_Sizeof	;data space size
	dc.l	FuncTable		;pointer to function initializers
	dc.l	DataTable		;pointer to data initializers
	dc.l	InitRoutine		;routine to run



FuncTable:
	;------ standard system routines
	dc.l	Open
	dc.l	Close
	dc.l	Expunge
	dc.l	Null		;Reserved for future use!

	;------ my device definitions
	dc.l	BeginIO
	dc.l	AbortIO

	;------ custom extended functions
;	dc.l	FunctionA
;	dc.l	FunctionB

	;------ function table end marker
	dc.l	-1


;----- The data table initializes static data structures. The format
;----- is specified in exec/InitStruct routine's manual pages.  The
;----- INITBYTE/INITWORD/INITLONG macros are found in the file
;----- "exec/initializers.i".  The first argument is the offset from
;----- the device base for this byte/word/long.  The second argument
;----- is the value to put in that cell.  The table is null terminated
DataTable:
	INITBYTE	LN_TYPE,NT_DEVICE
	INITLONG	LN_NAME,TheDevName
	INITBYTE	LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD	LIB_VERSION,MYVERSION
	INITWORD	LIB_REVISION,MYREVISION
	INITLONG	LIB_IDSTRING,IDstring
	dc.l		0			;Terminate list


;------- InitRoutine -------------------------------------------------------
;FOR RTF_AUTOINIT:
;  This routine gets called after the device has been allocated.
;  The device pointer is in D0.  The AmigaDOS segment list is in a0.
;  If it returns the device pointer, then the device will be linked
;  into the device list.  If it returns NULL, then the device
;  will be unloaded.
;
;This call is single-threaded by exec; please read the description for
;"Open" below.
;
;a0:My SegList
;(a3 -- Points to temporary RAM)
;(a4 -- Expansion library base)
;a5:FlyBase (device pointer)
;a6:ExecBase
;----------------------------------------------------------------------
InitRoutine:
;----- Get the device pointer into a convenient A register
	movem.l	d1-d7/a0-a5,-(sp)	;Preserve ALL modified registers
	move.l	d0,a5

	IFD	DEBUGINIT
	DUMPMSG <Init called>
	ENDC

;----- Save a pointer to exec
	move.l	a6,fly_ExecBase(a5)	;faster access than move.l 4,a6

;----- Save pointer to our loaded code (the SegList)
	move.l	a0,fly_SegList(a5)

.okay
	move.l	a5,d0			;Return device ptr to install
.exit
	movem.l	(sp)+,d1-d7/a0-a5
	rts


;------- Open --------------------------------------------------------------
;Here begins the system interface commands.  When the user calls
;OpenDevice/CloseDevice/RemDevice, this eventually gets translated
;into a call to the following routines (Open/Close/Expunge).
;Exec has already put our device pointer in a6 for us.
;
;IMPORTANT:
;These calls are guaranteed to be single-threaded; only one task
;will execute your Open/Close/Expunge at a time.
;
;For Kickstart V33/34, the single-threading method involves "Forbid".
;There is a good chance this will change.  Anything inside your
;Open/Close/Expunge that causes a direct or indirect Wait() will break
;the Forbid().  If the Forbid() is broken, some other task might
;manage to enter your Open/Close/Expunge code at the same time.
;Take care!
;
;Since exec has turned off task switching while in these routines
;(via Forbid/Permit), we should not take too long in them.
;
;Open sets the IO_ERROR field on an error.  If it was successfull,
;we should also set up the IO_UNIT and LN_TYPE fields.
;exec takes care of setting up IO_DEVICE.
;
;Subtle point: any AllocMem() call can cause a call to this device's
;expunge vector.  If LIB_OPENCNT is zero, the device might get expunged.
;For this reason, we fake an extra opener for the duration of the 'open'
;call until we're done.
;
;d0:Unit number
;d1:Open flags
;a1:IO request
;a6:FlyBase
;----------------------------------------------------------------------------
Open:
	movem.l	d2/a2-a4,-(sp)

	addq.w	#1,LIB_OPENCNT(a6)	;Fake an opener for duration of call

	IFD	DEBUGINIT
	DUMPMSG <Open: called>
	ENDC

	move.l	a1,a2	;save the iob

	IFD	DEBUGINIT
	 move.l	d0,-(sp)
	 sub.l	a1,a1
	 LINKSYS FindTask,fly_ExecBase(a6)
	 DUMPHEXI.L <Calling task is >,d0,<\>
	 move.l	(sp)+,d0
	ENDC

;----- Convert Amiga-style unit numbering to Flyer-style

	IFD	DEBUGINIT
	DUMPHEXI.W <Amiga unit = >,d0,<\>
	ENDC

	divu	#100,d0			;Separate board # from ID #
	move.w	d0,d2			;Get board # into d2
	clr.w	d0
	swap	d0			;d0.l = LUN/ID
	divu	#10,d0
	swap	d0			;d0.w = ID
	lsl.w	#3,d2			;Flyer unit = board * 8
	add.w	d0,d2			;  + ID

	IFD	DEBUGINIT
	DUMPHEXI.W <Flyer unit = >,d2,<\>
	ENDC

;----- See if the unit number is in range
	cmp.w	#NUM_DRIVES,d2
	bcc	.range_error		;unit number out of range

	CLEAR	d0
	move.w	d2,d0
	lsl.l	#2,d0
	lea.l	fly_Units(a6,d0.l),a4	;Get ptr to entry in unit table
	move.l	(a4),d0			;This unit already up?
	bne.s	.unitOK

;----- Try to bring up the new unit
	bsr	InitUnit		;a3:scratch d2:unitnum a6:FlyBase
	move.l	d0,(a4)			;Save in device's unit ptr table
	tst.l	d0			;Successfully initialized?
	beq.s	.error

.unitOK
	move.l	d0,a3			;unit pointer in a3
	move.l	d0,IO_UNIT(a2)		;Fill in unit pointer of IOrequest

;----- Mark us as having another opener
	addq.w	#1,LIB_OPENCNT(a6)
	addq.w	#1,fsu_OpenCnt(a3)

;----- Prevent delayed expunges
	bclr	#FLYB_DELEXP,fly_Flags(a6)

;------ IMPORTANT: Mark IORequest as "complete"
	move.b	#NT_REPLYMSG,LN_TYPE(a2)

	IFD	DEBUGIFACE
	DUMPMSG <Open: Okay>
	ENDC

	CLEAR	d0
	bra.s	.exit			;A-OK

.range_error
.error
	IFD	DEBUGIFACE
	DUMPMSG <Open: failed>
	ENDC

	moveq	#IOERR_OPENFAIL,d0
	move.l	d0,IO_DEVICE(a2)	;IMPORTANT: trash IO_DEVICE on open failure
.exit
	move.b	d0,IO_ERROR(a2)
	subq.w	#1,LIB_OPENCNT(a6)	;** End of expunge protection
	movem.l	(sp)+,d2/a2-a4
	rts


;------- Close --------------------------------------------------------------
;There are two different things that might be returned from the Close
;routine.  If the device wishes to be unloaded, then Close must return
;the segment list (as given to Init).  Otherwise close MUST return NULL.
;
;a1:IO request
;a6:FlyBase
;----------------------------------------------------------------------------
Close:
	movem.l	d1/a2-a3,-(sp)

	move.l	a1,a2
	move.l	IO_UNIT(a2),d0		;Get unit ptr
	beq	.IORinvalid		;Not a valid IOrequest,
	move.l	d0,a3

	IFD	DEBUGIFACE
	DUMPMSG <Close: called>
	ENDC

;----- IMPORTANT: make sure the IORequest is not used again
;----- with a -1 in IO_DEVICE, any BeginIO() attempt will
;----- immediatly halt (which is better than a subtle corruption
;----- that will lead to hard-to-trace crashes!!
	moveq.l	#-1,d0
	move.l	d0,IO_UNIT(a2)		;We're closed...
	move.l	d0,IO_DEVICE(a2)	;customers not welcome at this IORequest!!

;----- Mark us as having one fewer opener
	subq.w	#1,fsu_OpenCnt(a3)
	bne	.unitstillopen

;----- If all openers of unit are gone, kill unit's task
	IFD	DEBUGINIT
	DUMPHEXI.L <Going to kill unit >,a3,<\>
	ENDC

;----- Erase unit ptr in device table
	moveq	#0,d0
	move.b	fsu_UnitNum(a3),d0
	lsl.l	#2,d0
	clr.l	fly_Units(a6,d0.l)	;Clear entry in unit table

	bset	#FSUB_SUICIDE,fsu_UnitFlags(a3)	;Tell task to die!
	move.l	#QUEUESIGFLAG,d0
	lea.l	fsu_Task(a3),a1
	LINKSYS Signal,fly_ExecBase(a6)	;Wake unit up if asleep
.unitstillopen

.IORinvalid
	subq.w	#1,LIB_OPENCNT(a6)

;----- See if there is anyone left with us open
	bne.s	.exit

;----- See if we have a delayed expunge pending
	btst	#FLYB_DELEXP,fly_Flags(a6)
	beq.s	.exit

;----- Do the expunge
	bsr	Expunge			;Returns original SegList
	bra.s	.didexp

.exit
	CLEAR	d0			;Don't de-alloc me!
.didexp
	movem.l	(sp)+,d1/a2-a3
	rts				;MUST return either zero or the SegList!!!


;------- Expunge -----------------------------------------------------------
;Expunge is called by the memory allocator when the system is low on
;memory (or when somebody RemDevice()'s us).
;
;There are two different things that might be returned from the Expunge
;routine.  If the device is no longer open then Expunge may return the
;segment list (as given to Init).  Otherwise Expunge may set the
;delayed expunge flag and return NULL.
;
;One other important note: because Expunge is called from the memory
;allocator, it may NEVER Wait() or otherwise take long time to complete.
;
;a6:FlyBase
;--------------------------------------------------------------------------
Expunge:
	movem.l	d1/d2/d7/a3-a4,-(sp)	;Save ALL modified registers

	IFD	DEBUGINIT
	DUMPMSG <Expunge: called>
	ENDC

;----- See if anyone has us open
	tst.w	LIB_OPENCNT(a6)
	beq	.vacated

;----- It is still open.  set the delayed expunge flag
	bset	#FLYB_DELEXP,fly_Flags(a6)
	CLEAR	d0			;Can't do it just now
	bra.s	.exit

.vacated
;----- Give suicide instruction to all active units
	moveq.l	#NUM_DRIVES-1,d7	;Number of times to do this loop
	lea.l	fly_Units(a6),a4
.loop
	move.l	(a4),d0			;Get Unit ptr
	clr.l	(a4)+
	tst.l	d0
	beq.s	.none_here

	move.l	d0,a3
	bset	#FSUB_SUICIDE,fsu_UnitFlags(a3)	;Tell task to die!
	move.l	#QUEUESIGFLAG,d0
	lea.l	fsu_Task(a3),a1
	LINKSYS Signal,fly_ExecBase(a6)	;Wake unit up if asleep

.none_here
	dbf	d7,.loop		;Kill all

;----- Go ahead and get rid of this device.  Store our seglist in d2
	move.l	fly_SegList(a6),d2

;----- Unlink from device list
	move.l	a6,a1
	REMOVE				;Remove node a1 from its list

;
;Put any device specific closings here...
;

;----- Free our memory (must calculate from LIB_POSSIZE & LIB_NEGSIZE)
	move.l	a6,a1		;FlyBase
	CLEAR	d0
	move.w	LIB_NEGSIZE(a6),d0
	suba.l	d0,a1		;Calculate base of functions
	add.w	LIB_POSSIZE(a6),d0	;Calculate size of functions + data area
	LINKSYS	FreeMem,fly_ExecBase(a6)

;----- Return our SegList
	move.l	d2,d0

.exit
	movem.l	(sp)+,d1/d2/d7/a3-a4
	rts



;------- Null ---------------------------------------------------------------
Null:
	IFD	DEBUGINIT
	DUMPMSG <Null: called>
	ENDC

	CLEAR	d0
	rts		;The "Null" function MUST return NULL.



;------- Custom ------------------------------------------------------------
;
;Two "do nothing" device-specific functions
;
;FunctionA:
;	add.l	d1,d0	;Add
;	rts
;FunctionB:
;	add.l	d0,d0	;Double
;	rts
;---------------------------------------------------------------------------


MemListDecl:
	ds.b	LN_SIZE			;Reserve space for node
	dc.w	2			;2 entries
	dc.l	MEMF_PUBLIC!MEMF_CLEAR	;Big unit structure
	dc.l	FlyUnit_Sizeof
	dc.l	MEMF_CLEAR		;Stack
	dc.l	MYPROCSTACKSIZE


;------- InitUnit ----------------------------------------------------------
;Allocates and initializes a unit structure
;
;d1 = OpenFlags (not used here)
;d2 = Unit number.b (Flyer style)
;a2 = IOrequest (not used here)
;a3 = (UnitPtr)
;a4 = (MemList)
;a6 = FlyBase
;---------------------------------------------------------------------------
InitUnit:
	movem.l	d1-d4/a1-a4,-(sp)

	IFD	DEBUGINIT
	DUMPMSG <InitUnit called>
	ENDC

;----- Allocate unit structure & stack
	lea.l	MemListDecl(pc),a0
	LINKSYS	AllocEntry,fly_ExecBase(a6) ;Allocate structure & stack
	btst.l	#31,d0			;(Top bit set if any failures)
	bne	.error			;Failed?
	move.l	d0,a4			;Keep MemList
	move.l	ML_ME+ME_ADDR(a4),a3	;Get Unit Ptr out of MemList
	move.l	ML_ME+ME_SIZE+ME_ADDR(a4),d0	;Get Stack Ptr from MemList
	move.l	d0,fsu_Stack(a3)	;Store stack location

	move.l	a6,fsu_Device(a3)	;initialize device pointer
	move.l	fly_ExecBase(a6),fsu_ExecBase(a3)	;Copy AbsExecBase

	move.b	d2,fsu_UnitNum(a3)	;Keep my Flyer unit number

;----- Set default debugging flags (all)
	moveq.l #-1,d0
	move.w	d0,fsu_DebugFlags(a3)

;----- Start up the unit task.  We do a trick here --
;----- we set its message port to PA_IGNORE until the new
;----- task is running.  It will activate it when it is
;----- ready to process messages.  We can't go to sleep
;----- here -- Exec's OpenDevice has done a Forbid() for us.

;----- Initialize the unit's message port list
	lea	fsu_Q(a3),a0

	move.b	#QUEUESIGBIT,d0
	move.b	d0,MP_SIGBIT(a0)	;Set signal bit (HARD CODED!!)

	lea.l	fsu_Task(a3),a1
	move.l	a1,MP_SIGTASK(a0)	;Task to signal
	move.b	#PA_IGNORE,MP_FLAGS(a0)	;Ignore messages for now
	move.b	#NT_MSGPORT,LN_TYPE(a0)	;Making a message port

	lea.l	MP_MSGLIST(a0),a0	;Initialize list to empty
	NEWLIST	a0


;----- Initialize the stack information
	move.l	fsu_Stack(a3),a0		;Low end of stack
	move.l	a0,fsu_Task+TC_SPLOWER(a3)
	lea	MYPROCSTACKSIZE(a0),a0		;High end of stack
	move.l	a0,fsu_Task+TC_SPUPPER(a3)
	move.l	a3,-(a0)			;Push unit ptr on task stack
	move.l	a0,fsu_Task+TC_SPREG(a3)

;----- Setup MemEntry list
	lea.l	fsu_Task+TC_MEMENTRY(a3),a0
	NEWLIST	a0				;Init MemEntry list
	lea.l	fsu_Task+TC_MEMENTRY(a3),a0
	move.l	a4,a1
	ADDHEAD					;Add my MemEntry to list

;----- Init task node
	lea.l	TheDevName(pc),a0
	move.l	a0,fsu_Task+LN_NAME(a3)		;Task name = my (device) name
	move.b	#NT_TASK,fsu_Task+LN_TYPE(a3)	;I'm a task
	move.b	#TASKPRI,fsu_Task+LN_PRI(a3)	;Set priority

	IFD	DEBUGIFACE
	DUMPMSG <About to add task>
	ENDC

;----- Startup the task
	move.l	a3,-(sp)		;Preserve Unit Ptr
	lea	fsu_Task(a3),a1
	lea	Task_Begin(pc),a2
	lea	-1,a3			;generate address error
					;if task ever "returns" (we RemTask()
					;to get rid of it...)
	CLEAR	d0
	LINKSYS	AddTask,fly_ExecBase(a6)
	move.l	(sp)+,a3		;restore Unit Ptr

	IFD	DEBUGIFACE
	DUMPMSG <InitUnit: ok>
	ENDC

;----- Mark us as ready to go
	move.l	a3,d0		;Return unit ptr
	bra.s	.exit

.backout
	move.l	a4,a0
	LINKSYS	FreeEntry,fly_ExecBase(a6) ;Free unit structure & stack
.error
	CLEAR	d0
.exit
	movem.l	(sp)+,d1-d4/a1-a4
	rts



;------- BeginIO -----------------------------------------------------------
;Starts all incoming IO.  The IO is either queued up for the unit task or
;processed immediately.
;
;BeginIO often is given the responsibility of making devices single
;threaded... so two tasks sending commands at the same time don't cause
;a problem.  Once this has been done, the command is dispatched via
;Dispatch.
;
;There are many ways to do the threading.  This example uses the
;UNITB_ACTIVE bit.  Be sure this is good enough for your device before
;using!  Any method is ok.  If immediate access can not be obtained, the
;request is queued for later processing.
;
;Some IO requests do not need single threading, these can be performed
;immediately.
;
;IMPORTANT:
;  The exec WaitIO() function uses the IORequest node type (LN_TYPE)
;  as a flag.	If set to NT_MESSAGE, it assumes the request is
;  still pending and will wait.  If set to NT_REPLYMSG, it assumes the
;  request is finished.  It's the responsibility of the device driver
;  to set the node type to NT_MESSAGE before returning to the user.
;
;a1:IO request
;a6:FlyBase
;--------------------------------------------------------------------------
BeginIO:
	movem.l	d1/a0/a3-a4,-(sp)

	IFD	DEBUGIFACE
	 DUMPHEXI.L <BeginIO  iob:>,a1,<\>
	 DUMPHEXI.W <         cmd:>,IO_COMMAND(a1),<\>
	 DUMPHEXI.L <        data:>,IO_DATA(a1),<\>
	 DUMPHEXI.L <        offs:>,IO_OFFSET(a1),<\>
	 DUMPHEXI.L <         len:>,IO_LENGTH(a1),<\>
	 DUMPHEXI.B <       flags:>,IO_FLAGS(a1),<\>
	ENDC

	move.b	#NT_MESSAGE,LN_TYPE(a1) ;So WaitIO() is guaranteed to work

	CLEAR	d0
	move.w	IO_COMMAND(a1),d0
	move.l	IO_UNIT(a1),a3		;Get Unit Ptr

;----- Do a range check & make sure ETD_XXX type requests are rejected
	cmp.w	#FLYDEV_END,d0		;Is command in range?
	bhi	No_cmd			;no, reject it

	lea.l	CommandFlags(pc),a0	;Get command flag list
	lsl.w	#1,d0			;(x2)
	move.w	0(a0,d0.w),d1		;Get flags for this command

	DISABLE	a0			;<-- Ick, nasty stuff, but needed here.
	btst	#CB_IMMEDIATE,d1	;Is this an immediate command?
	bne	Immediate

;----- To perform this command, we will have to call the flyer.library.  Queue
;----- the command to the unit's task & let it take care of it.
;----- For our caller's info, we clear the quick flag (he'll need to Wait()
;----- for the command completion.
.queue_msg
	lea.l	fsu_Q(a3),a4

	bclr	#IOB_QUICK,IO_FLAGS(a1)	;We did NOT complete this quickly
	ENABLE	a0

	IFD	DEBUGIFACE
	DUMPMSG <QUEUE!>
	ENDC

	IFD	DEBUGIFACE
	 DUMPHEXI.L <PutMsg:      Port=>,a4,<\>
	 DUMPHEXI.L <PutMsg:   Message=>,a1,<\>
	 DUMPHEXI.L <PutMsg: ReplyPort=>,MN_REPLYPORT(a1),<\>
	ENDC

	move.l	a4,a0
	LINKSYS	PutMsg,fly_ExecBase(a6)	;Port=a0, Message=a1

;----- Return to caller before completing
	bra.s	Exit

Immediate:
;----- This command can be done immediately.  Do it on the schedule of the
;----- calling process.

	ENABLE	a0

	IFD	DEBUGIFACE
	DUMPMSG <IMMEDIATE!>
	ENDC

	bsr	Dispatch	;Do the command live
	bra.s	Reply

No_cmd
	move.b	#IOERR_NOCMD,IO_ERROR(a1)
Reply
	bsr	TermIO
Exit
	IFD	DEBUGIFACE
	DUMPMSG <BeginIO_End>
	ENDC

	CLEAR	d0		;Kludge for klutz programmers watching d0
	move.b	IO_ERROR(a1),d0	;for error codes!

	movem.l	(sp)+,d1/a0/a3-a4
	rts



;------- AbortIO -----------------------------------------------------------
;Here is the section to handle aborting commands
;
;AbortIO() is a REQUEST to "hurry up" processing of an IORequest.
;If the IORequest was already complete, nothing happens (if an IORequest
;is quick or LN_TYPE=NT_REPLYMSG, the IORequest is complete).
;The message must be replied with ReplyMsg(), as normal.
;
;a1:IO request
;a6:FlyBase
;---------------------------------------------------------------------------
AbortIO:
	move.l	a3,-(sp)

	move.l	IO_UNIT(a1),d0		;Get Unit Ptr
	beq	Dontabort		;If not valid, just ignore
	move.l	d0,a3

	CLEAR	d0
	move.w	IO_COMMAND(a1),d0
	lea.l	CommandFlags(pc),a0	;Get command flag list
	lsl.w	#1,d0			;(x2)
	move.w	0(a0,d0.w),d1		;Get flags for this command

	DISABLE	a0			;<-- Ick, nasty stuff, but needed here.

	btst	#CB_IMMEDIATE,d1	;Command always done immediately?
	bne	Dontabort

	cmp.b	#NT_REPLYMSG,LN_TYPE(a1) ;Command already sent back?
	beq	Dontabort

	cmpa.l	fsu_iobDoing(a3),a1	;Is this iob currently happening?
	beq.s	Live_one

;----- This request has not yet been picked up by the task for processing
;----- Let's politely remove it, mark it as aborted and send it back
	move.l	a1,-(sp)
	REMOVE				;Remove node a1 from its list
	move.l	(sp)+,a1

	move.b	#IOERR_ABORTED,IO_ERROR(a1)	;Show what happened

	ENABLE	a0

					;(a1:message)
	LINKSYS ReplyMsg,fly_ExecBase(a6)	;Reply message back to sender

	IFD	DEBUGIFACE
	DUMPMSG <Quietly aborted>
	ENDC

	CLEAR	d0			;"Aborted"
	bra.s	abort_exit

Live_one
;----- This request is currently operating! Try to stop whatever is
;----- happening before we send it back early.

;***
;*** Send abort to Flyer
;*** Wait for it to come back
;***

	move.b	#IOERR_ABORTED,IO_ERROR(a1)	;Better stop soon
	ENABLE	a0
	CLEAR	d0				;"Aborted"
	bra.s	abort_exit

Dontabort
	ENABLE	a0
	moveq.l	#-1,d0			;Sorry, can't abort
abort_exit
	move.l	(sp)+,a3
	rts


;------- Dispatch --------------------------------------------------------
;Actually dispatches an IO request.  It might be called from the task,
;or directly from BeginIO (thus on the caller's schedule)
;
;Bounds checking has already been done on the I/O Request.
;
;a1 = IOrequest
;a3 = UnitPtr
;a6 = FlyBase
;-------------------------------------------------------------------------
Dispatch:
	IFD	DEBUGIFACE
	 DUMPHEXI.W <Dispatch Cmd:>,IO_COMMAND(a1),<\>
	 DUMPHEXI.L <         Ptr:>,a1,<\>
	ENDC

	CLEAR	d0
	move.l	d0,IO_ACTUAL(a1)	;Initial actual = 0

	IFD	DEBUGIFACE
	DUMPHEXI.L <-SENT (>,a1,<)-\>
	ENDC

	CLEAR	d0
	move.b	d0,IO_ERROR(a1)	;No error so far

	move.b	IO_COMMAND+1(a1),d0 ;Look only at low byte
	lsl.w	#1,d0		;Multiply by 2 to get table offset
	lea.l	CommandTable(pc),a0	;Get dispatch table for FlyerScsi functions
	move.w	0(a0,d0.w),d0	;Get offset for function
	lea.l	YYZ,a0		;This is the base from which all offsets refer
	adda.l	d0,a0		;Merge to make real absolute call address
	CLEAR	d0		;Default return code
	jsr	(a0)		;a1:iob   a3:UnitPtr  a6:FlyBase

	move.b	d0,IO_ERROR(a1)	;Save error code
	rts


;------- TermIO ------------------------------------------------------------
;Sends the IO request back to the user.  If 'Quick' bit is set, just returns
;
;a1:IO request
;a6:FlyBase
;---------------------------------------------------------------------------
TermIO:
	IFD	DEBUGIFACE
	 DUMPHEXI.B <TermIO   error:>,IO_ERROR(a1),<\>
	ENDC

;----- If the quick bit is still set then we don't need to reply msg --
;----- just return to the user.

	btst	#IOB_QUICK,IO_FLAGS(a1)
	bne	.exit

	IFD	DEBUGIFACE
	 DUMPHEXI.L <(ReplyMsg)      Unit=>,IO_UNIT(a1),<\>
	 DUMPHEXI.L <(ReplyMsg) ReplyPort=>,MN_REPLYPORT(a1),<\>
	ENDC

;----- (ReplyMsg sets the LN_TYPE to NT_REPLYMSG)
	LINKSYS ReplyMsg,fly_ExecBase(a6)	;a1-message

.exit
	rts



*****************************************************************************
*
* Here begins the device functions
*
*----------------------------------------------------------------------------
*
* NOTE: the "extended" commands (ETD_READ/ETD_WRITE) have bit 15 set!
* We deliberately refuse to operate on such commands.  However a driver
* that supports removable media may want to implement this.
*
*****************************************************************************

;------- CommandTable -------------------------------------------------------
;CommandTable is used to look up the address of a routine that will
;implement the device command
;----------------------------------------------------------------------------
CommandTable:
	dc.w	Fly_Invalid-YYZ		;0	CMD_INVALID
	dc.w	Fly_Reset-YYZ		;1	CMD_RESET
	dc.w	Fly_Read-YYZ		;2	CMD_READ
	dc.w	Fly_Write-YYZ		;3	CMD_WRITE
	dc.w	Fly_Update-YYZ		;4	CMD_UPDATE
	dc.w	Fly_Clear-YYZ		;5	CMD_CLEAR
	dc.w	Fly_Stop-YYZ		;6	CMD_STOP
	dc.w	Fly_Start-YYZ		;7	CMD_START
	dc.w	Fly_Flush-YYZ		;8	CMD_FLUSH
	dc.w	Fly_Motor-YYZ		;9
	dc.w	Fly_Seek-YYZ		;A
	dc.w	Fly_Format-YYZ		;B
	dc.w	Fly_Remove-YYZ		;C
	dc.w	Fly_Invalid-YYZ		;D
	dc.w	Fly_Invalid-YYZ		;E
	dc.w	Fly_Invalid-YYZ		;F
	dc.w	Fly_Invalid-YYZ		;10
	dc.w	Fly_Invalid-YYZ		;11
	dc.w	Fly_Invalid-YYZ		;12
	dc.w	Fly_Invalid-YYZ		;13
	dc.w	Fly_Invalid-YYZ		;14
	dc.w	Fly_Invalid-YYZ		;15
	dc.w	Fly_Invalid-YYZ		;16
	dc.w	Fly_Invalid-YYZ		;17
	dc.w	Fly_Invalid-YYZ		;18
	dc.w	Fly_Invalid-YYZ		;19
	dc.w	Fly_Invalid-YYZ		;1A
	dc.w	Fly_Invalid-YYZ		;1B
	dc.w	Fly_Direct-YYZ		;1C
cmdtable_end:

;------- CommandFlags -----------------------------------------------------
;Flags outlining special behavior of each supported command
;--------------------------------------------------------------------------
CommandFlags:
	dc.w	CF_IMMEDIATE			;0	(NULL)
	dc.w	CF_IMMEDIATE			;1	(Reset)
	dc.w	CF_REGQUEUE			;2	Read
	dc.w	CF_IMMEDIATE			;3	(Write)
	dc.w	CF_IMMEDIATE			;4	(Update)
	dc.w	CF_IMMEDIATE			;5	(Clear)
	dc.w	CF_IMMEDIATE			;6	Stop
	dc.w	CF_IMMEDIATE			;7	Start
	dc.w	CF_IMMEDIATE			;8	Flush
	dc.w	CF_IMMEDIATE			;9	(Motor)
	dc.w	CF_REGQUEUE			;10	Seek
	dc.w	CF_IMMEDIATE			;11	(Format)
	dc.w	CF_IMMEDIATE			;12	(Remove)
	dc.w	0				;13
	dc.w	0				;14
	dc.w	0				;15
	dc.w	0				;16
	dc.w	0				;17
	dc.w	0				;18
	dc.w	0				;19
	dc.w	0				;20
	dc.w	0				;21
	dc.w	0				;22
	dc.w	0				;23
	dc.w	0				;24
	dc.w	0				;25
	dc.w	0				;26
	dc.w	0				;27
	dc.w	CF_REGQUEUE			;28	Direct
	CNOP	0,2


*****************************************************************************
* Here begins the functions that implement the device commands
*
* All functions are called with:
* a1:Pointer to the IO request
* a3:UnitPtr
* a6:FlyBase
*****************************************************************************

YYZ:		;This is the base of my functions!

***** Unused commands
Unused:
Fly_Write:
Fly_Format:
Fly_Remove:
Fly_Invalid:
	move.b	#IOERR_NOCMD,d0
	rts

***** Unimplemented commands (someday...)
Fly_Read:				;Read data sector(s)
;	CALLC	Reader,a1,IO_OFFSET(a1),IO_LENGTH(a1),IO_DATA(a1)
	move.b	#IOERR_NOCMD,d0
	rts

Fly_Seek:				;Seek to spec'd sector
;	CALLC	Seeker,IO_OFFSET(a1)
	move.b	#IOERR_NOCMD,d0
	rts



;----- Update and Clear are internal buffering commands.  Update forces all
;----- IO out to its final resting spot, and does not return until this is
;----- totally done.  This doesn't apply to me right now, so simply return "Ok"
;-----
;----- Clear invalidates all internal buffers.  Since this device
;----- has no internal buffers, these commands do not apply.
Fly_Update:
Fly_Clear:
Fly_Reset:		;Do nothing (nothing reasonable to do)
Fly_Motor:		;Do nothing
	rts


;----- The Stop command stops all future IO requests from being
;----- processed until a Start command is received.  Stop is not stackable
Fly_Stop:				;Stop task unit
	IFD	DEBUGCMD
	DUMPMSG <MyStop: called>
	ENDC

	bset	#FSUB_UNITSTOPPED,fsu_UnitFlags(a3)
	CLEAR	d0
	rts

Fly_Start:				;Re-start task unit
	IFD	DEBUGCMD
	DUMPMSG <Start: called>
	ENDC

	bsr	InternalStart
	CLEAR	d0
	rts


Fly_Flush:				;Flush all pending queued requests
	IFD	DEBUGCMD
	DUMPMSG <Flush: called>
	ENDC

	bsr	SubFlush
	CLEAR	d0
	rts


Fly_Direct:				;This is the big one!!!
	movem.l	a0-a2/d1-d2,-(sp)

	tst.l	fsu_FlyerBase(a3)	;Flyer library open?
	beq	.noflyer

**** Until we see Flyer come alive, keep watching for it, return error until it happens
	btst	#FSUB_FLYERUP,fsu_UnitFlags(a3)		;Do we know Flyer to be up?
	bne.s	.isup
	CLEAR	d0
	LINKSYS FlyerRunning,fsu_FlyerBase(a3)		;Flyer fully up yet?
	tst.l	d0
	beq.s	.isupnow
	move.l	IO_DATA(a1),a0			;Ptr to SCSICmd structure
	move.b	#2,scsi_Status(a0)		;Simulate SCSI bad status
	moveq.l	#HFERR_SelTimeout,d0		;"Not ready yet"
	bra	.newerror
.isupnow
	bset	#FSUB_FLYERUP,fsu_UnitFlags(a3)		;Don't repeat test over and over
.isup

	move.l	IO_UNIT(a1),a0		;Unit ptr
	move.b	fsu_UnitNum(a0),d1	;Unit number (Flyer drive #)
	move.l	IO_DATA(a1),a0		;Ptr to SCSICmd structure


;	move.l	scsi_Command(a0),a2	; Get CDB
;	moveq	#$28,d2			; looking for READ (10) CDB
;	cmp.b	(a2),d2			; SCSI READ(10) COMMAND
;	bne	.not_readhack
;
;	move.b	7(a2),d2		; Get MSB of number of blocks
;	swap.w	d2			; move it out to high byte
;	move.b	8(a2),d2		; Get LSB of number of blocks
;	lsl.l	#8,d2			; convert blocks to bytes (* 512)
;	lsl.l	#1,d2			; convert blocks to bytes (* 512)
;	move.l	d2,scsi_Length(a0)	; Override this LENGTH

.not_readhack

	IFD	DEBUGDIRECT
	move.l	scsi_Command(a0),a2
	DUMPHEXI.L <Direct CDB (>,0(a2),<)\>
	DUMPHEXI.L <           (>,4(a2),<)\>
	DUMPHEXI.L <           (>,8(a2),<)\>
	ENDC

	IFD	DEBUGDIRECT
	move.l	scsi_Data(a0),a2
	DUMPHEXI.L <Data ptr=>,a2,<\>
	move.l	scsi_Length(a0),a2
	DUMPHEXI.L <Data len=>,a2,<\>
	move.l	scsi_Actual(a0),a2
	DUMPHEXI.L <Actual  =>,a2,<\>
	ENDC

	move.l	IO_LENGTH(a1),d2	;Length of SCSICmd structure
	CLEAR	d0			;Board 0

	LINKSYS FlyerSCSIdirect,fsu_FlyerBase(a3)

	move.l	d0,d1

	IFD	DEBUGDIRECT
	move.l	scsi_Actual(a0),a2
	DUMPHEXI.L <Actual r=>,a2,<\>
	ENDC

	moveq.l	#HFERR_SelTimeout,d0
	cmp.b	#FERR_SELTIMEOUT,d1	;Timeout?
	beq.s	.newerror
	moveq.l	#HFERR_BadStatus,d0
	cmp.b	#FERR_BADSTATUS,d1	;Bad status?
	beq.s	.newerror
	move.l	d1,d0			;Otherwise, just pass on flyer error!
.newerror

	IFD	DEBUGDIRECT
	tst.b	d0
	beq	.noerrorcode
	DUMPHEXI.B <Error code >,d0,<!!!\>
.noerrorcode
	ENDC

.noflyer
	movem.l	(sp)+,a0-a2/d1-d2
	rts




;------- InternalStart ----------------------------------------------------
;This baby restarts a stopped device unit
;
;a3:UnitPtr
;a6:FlyBase
;--------------------------------------------------------------------------
InternalStart:
	move.l	a1,-(sp)

;----- Turn processing back on
	bclr	#FSUB_UNITSTOPPED,fsu_UnitFlags(a3)

;----- Kick the task to start it moving
	move.l	#QUEUESIGFLAG,d0		;Check for both types
	lea.l	fsu_Task(a3),a1
	LINKSYS Signal,fly_ExecBase(a6)
	move.l	(sp)+,a1
	rts


;------- SubFlush ---------------------------------------------------------
;Pulls I/O requests off both queues and sends them back.
;We must be careful not to destroy work in progress, and also
;that we do not let some IO requests slip by.
;
;Some funny magic goes on with the UNITSTOPPED bit in here.  Stop is
;defined as not being reentrant.  We therefore save the old state
;of the bit and then restore it later.  This keeps us from
;needing to DISABLE in flush.	It also fails miserably if someone
;does a start in the middle of a flush. (A semaphore might help...)
;
;a3:UnitPtr
;a6:FlyBase
;--------------------------------------------------------------------------
SubFlush:
	movem.l	d2/a1,-(sp)

	bset	#FSUB_UNITSTOPPED,fsu_UnitFlags(a3)
	sne	d2			;Keep old state of "stopped" bit

.loop
	lea.l	fsu_Q(a3),a0
	LINKSYS	GetMsg,fly_ExecBase(a6)	;Steal messages from task's port
	tst.l	d0
	beq.s	.exit
	move.l	d0,a1
	move.b	#IOERR_ABORTED,IO_ERROR(a1)
	LINKSYS	ReplyMsg,fly_ExecBase(a6)
	bra.s	.loop

.exit
	move.l	d2,d0
	movem.l	(sp)+,d2/a1

	tst.b	d0		;Check old state of "stopped" bit
	bne.s	.wasstopped

	bsr	InternalStart	;a3:UnitPtr  a6:FlyBase
.wasstopped
	rts



*****************************************************************************
* Here begins the unit task routine
*
* A Task is provided so that queued requests may be processed at
* a later time.  This works best with the Flyer's shared SRAM interface
*
* Register Usage
* ==============
* a6 -- FlyBase pointer
* a4 -- task (NOT process) pointer
* a3 -- UnitPtr
*****************************************************************************

Task_Begin:
;----- Grab the argument passed down from our parent
	move.l	4(sp),a3		;Get unit pointer
	move.l	fsu_Device(a3),a6	;Get device pointer

	IFD	DEBUGTASK
	 move.l	4,a0
	 DUMPHEXI.L <++Task:Device=>,a6,<\>
	 DUMPHEXI.L <++Task:  Task=>,$114(a0),<\>
	ENDC


;----- Allocate signals I'll be using (just to be above-board)
	moveq	#FIRSTSIGBIT,d7
.AllocAllSigs
	move.l	d7,d0
	LINKSYS	AllocSignal,fsu_ExecBase(a3)
	addq.l	#1,d7
	cmp.b	#LASTSIGBIT,d7
	bls.s	.AllocAllSigs

;----- Open flyer.library for me to talk to
	lea.l	FlyerLibName(pc),a1
	CLEAR	d0
	LINKSYS	OpenLibrary,fsu_ExecBase(a3)
	move.l	d0,fsu_FlyerBase(a3)

;----- Activate crippled message port -- we're ready for action
	move.b	#PA_SIGNAL,fsu_Q+MP_FLAGS(a3)

;----- OK, kids, we are done with initialization.  We now can start the main
;----- loop of the driver.  It goes like this.  Because we had the port
;----- marked PA_IGNORE for a while (in InitUnit) we jump to the getmsg code
;----- on entry.  (The first message will probably be posted BEFORE our task
;----- gets a chance to run)

	bra	.entrypoint



.mainloop
	btst	#FSUB_SUICIDE,fsu_UnitFlags(a3)	;Should we shut down?
	bne	Suicide

;----- Main loop -- wait for a new message
	IFD	DEBUGTASK
	DUMPMSG <++Sleep>	;Wait for msg
	ENDC

	move.l	#QUEUESIGFLAG,d0
	LINKSYS Wait,fsu_ExecBase(a3)

	IFD	DEBUGTASK
	DUMPMSG <++Wakeup>
	ENDC

	btst	#FSUB_SUICIDE,fsu_UnitFlags(a3)	;Should we shut down?
	bne	Suicide

.entrypoint
;----- See if we are stopped
	btst	#FSUB_UNITSTOPPED,fsu_UnitFlags(a3)
	bne	.mainloop	;device is stopped, ignore messages

;----- Get the next request
.nextmessage
	lea.l	fsu_Q(a3),a0
	LINKSYS GetMsg,fsu_ExecBase(a3)	;Try to pull next from regular Queue

	tst.l	d0
	beq	.mainloop		;No message?

	IFD	DEBUGTASK
	DUMPMSG <++Got Q Msg>
	ENDC

;----- Do this request
	move.l	d0,fsu_iobDoing(a3)	;Show which is happening
	move.l	d0,a1
	bsr	Dispatch
	bsr	TermIO
	clr.l	fsu_iobDoing(a3)	;Finished
	bra	.nextmessage


;------- SuicideRoutine ---------------------------------------------------
;This de-allocates everything & removes myself as a task
;
;a3 = UnitPtr
;DO NOT USE a6 (FlyBase) -- THE DEVICE COULD BE GONE
;--------------------------------------------------------------------------
Suicide
	IFD	DEBUGTASK
	DUMPMSG <++Suicide!>
	ENDC

;----- Close flyer.library
	move.l	fsu_FlyerBase(a3),d0
	beq.s	.nolib
	move.l	d0,a1
	LINKSYS	CloseLibrary,fsu_ExecBase(a3)
.nolib

;----- We don't have to worry about removing any outstanding messages from
;----- the queues, because the parent device will not instruct us to die
;----- unless all openers are gone.

;----- Since we allocated the Unit structure (including TCB) & stack using
;----- AllocEntry and linked it into our TC_MEMENTRY list, everything will
;----- be freed automatically as we go down...

	sub.l	a1,a1			;"myself"
	LINKSYS RemTask,fsu_ExecBase(a3)
	rts



_LEDon:
	move.l	#$BFE001,a0
	bclr	#1,(a0)
	rts

_LEDoff:
	move.l	#$BFE001,a0
	bset	#1,(a0)
	rts


	IFNE	SERDEBUG
	HXDUMP
;	HDUMP
	ENDC

;----------------------------------------------------------------------------
;EndCode is a marker that shows the end of my code.  Make sure it does not
;span hunks, and is not before the rom tag!
;----------------------------------------------------------------------------
EndCode:
	END

