*Scratch.asm this module also contains the basepage XDEFclarations

* hires//toaster mode repaint notes:
* all fields still refer to "lores" values....
* lores->hires pixel # conversion done "at last step//lowest level"
* only fix yet is to stretching stuff (how about rotate?)

 XDEF AOff		;turn OFF all 'modes', reset paint, no effects, etc
 XDEF ClearSaveArray	;clears out the 'per pixel data struct' array

 XDEF InitBitPlanes	;initializes rastports and bitmaps for bitplane buffers
 XDEF InitScratch

 XDEF GimmeDither	;call d0,1 = x.w,y.w  returns D0=y constant, a0=x table ptr
 XDEF ResetDither	;alloc 'random dither array's, reset pattern...
LOWERDITHER set 8 ;june2690; 4 ;5 works;3 doesnt work;10 works

 NOLIST
	Section code,CODE
_scratch:	;label for "basestuff.i"...prevents xref's


;	include "ram:mod.i"
	include "ps:basestuff.i"
	include "exec/types.i"
	include "ps:SaveRgb.i"
	include "ps:TopOFile.i"
	include "graphics/gfx.i"	;BitMap structure
	include "graphics/rastport.i"	;RastPort stuff
	include "exec/ports.i"		;for mp_size message port struct
	include "exec/interrupts.i"	;for is_size interrupt server
	include "devices/printer.i"	; for printer io req size
	include "libraries/dos.i"	;fib_ fileinfoblock struct for var
;;	include	"intuition/screens.i"

	include "commonrgb.i"		;2.0


 xref StdPot5
 xref SinTab

 LIST 

;	Section code,CODE
;_scratch:	;label for "digipaint.i"...prevents xref's

;;;;compiling with this lets DISASM show offsets...;;;TEST	ds.l	256*40	;40k


InitBitPlanes:
	xjsr	GraphicsWaitBlit	;play catch-up?
	lea	PasteBitMap_(BP),a0	;>6< bitplaner

	tst.l	bm_Planes(a0)		;bitplane(s) alloc'd?
	beq.s	nopastemap
	move.w	(a0),d1			;bm_BytesPerRow(a0),d1	;paste_width_(BP),d1
	beq.s	nopastemap
	asl.w	#3,d1			;#pixels=#bytes*(8bytesperpixel)
	moveq	#8,D0			;DEPTH
	moveq	#0,d2
	move.w	bm_Rows(a0),d2		;paste_height_(BP),d2
	beq.s	nopastemap
	movem.l	d1/d2,-(sp)		;STACK! width,height

	CALLIB	Graphics,InitBitMap

	movem.l	(sp)+,d1/d2		;width,ht
	moveq	#1,d0			;depth
	lea	PasteMaskBitMap_(BP),a0	;single bitplaner
	CALLIB	Graphics,InitBitMap

	lea	PasteRastPort_(BP),A0	;rastport for flooding
	lea	PasteMaskBitMap_(BP),a1
	bsr.s	inita_rport

nopastemap:

	lea	TextMask_RP_(BP),A0	;SYNONYM FOR 'RASTPORT of DRAWING MASK'
	lea	BB_BitMap_(BP),a1
	bsr.s	inita_rport		;single bitplane rport for brush
	move.l	4+bm_Planes(a1),d1	;d1=adr of tmpras for AREA fill (SECOND)
	move.w	bm_Rows(a1),d0
;?;;;	mulu	bm_BytesPerRow(BP),d0	;d1=planesize?
	mulu	(a1),d0 ;bm_BytesPerRow(BP),d0	;d1=planesize?

	lea	FillTmpRas_(BP),a1	;a1=tmpras
	move.l	a1,rp_TmpRas(A0)	;RASTPORT why? graphics paradigm sometimes weak
	move.l	a1,a0			;a0=filltmpras
	move.l	d1,a1			;a1=tmpras 2nd bitplane from brush mask bitmap
	CALLIB	Graphics,InitTmpRas


	lea	SwapBitMap_RP_(BP),A0	;rport for swap screen ("getold" usage)
	lea	SwapBitMap_(BP),a1
	;bsr.s	inita_rport
	;rts			;InitBitPlanes

inita_rport:		;CALL WITH a1=bitmap, A0=rastport
	movem.l	A0/a1,-(sp)
	move.l	A0,a1			;a1 is args for next syscall
	CALLIB	Graphics,InitRastPort	;sets fgpen=1, bg=0, aol=1

	movem.l	(sp),A0/a1
	move.l	a0,a1	;rastport arg
	moveq	#1,D0
	CALLIB	SAME,SetAPen

	movem.l	(sp)+,A0/a1
	move.l	a1,rp_BitMap(A0)	;shove A1=bitmap into A0 rastport struct
	move.b  #1,rp_FgPen(A0)
	move.b  #0,rp_BgPen(A0)
	move.b  #1,rp_AOLPen(A0)

	rts	;inita_rport


ClearSaveArray:	;clears out the array
		;(so's file loading plots color zero on plot overruns)
	;imaginary pixels on left on right edge, too, "softening"

	lea	PasteExtraLeft_(BP),a0	;very very(jeesh...) first record
	;04DEC91;move.l	#(LEFTWIDTH+MAXWIDTH+RIGHTWIDTH)*s_SIZEOF,d0
	move.l	#(384+MAXWIDTH+RIGHTWIDTH)*s_SIZEOF,d0
	xjsr	ClearMemA0D0

		;set s_stfx_top/bot to '-1' 
	tst.b	FlagAAlias_(BP)
	beq.s	enda_csa
	;JUNE05;lea	s_stfx_bottom+PasteExtraLeft_(BP),a0	;very very(jeesh...) first record
	lea	s_stfx_top+PasteExtraLeft_(BP),a0	;top.word + bot.word JUNE05
	moveq	#-1,d0			;data to clear with
	;04DEC91;move.l	#(LEFTWIDTH+MAXWIDTH+RIGHTWIDTH)-1,d1	;loop counter
	move.l	#(384+MAXWIDTH+RIGHTWIDTH)-1,d1	;loop counter
csBloop	move.l	d0,(a0)			;top.word, bot.word
	lea	s_SIZEOF(a0),a0		;next record
	dbf	d1,csBloop
enda_csa
	rts

;deffont:	dc.b 'topaz.font'
;deffontlen	set *-deffont
;	cnop 0,2

InitScratch:
	sf	FlagRexxReq_(BP)
	sf	FlagRexxSave_(BP)
	move.l	#0,RexxResult_(BP)
	move.l	#0,RexxResult1_(BP)
	move.w	#3,LastShadeMode_(a5)
	move.w	#$0000,LastShade0_(a5)
	move.w	#$FFFF,LastShade1_(a5)

		;sup def font for bigpic
	lea	FontNameBuffer_(BP),a0
	lea	TextAttr_(BP),a1
	move.l	a0,(a1)+		;ta_Name()<-*fontnamebuffer
	move.w	#8,(a1)+		;ta_Size
	clr.b	(a1)			;ta_Style
	tst.b	(a0)		;already have a fontname?
	bne.s	hadfontname

	;lea	deffont(pc),a1
	;moveq	#deffontlen-1,d0
 XREF MyFontName	;startup.o constant ;dc.b 'topaz.font',0
	lea	MyFontName,a1	;abs reloc', yech
	moveq.l	#32-1,d0	;maxlen

fnloop:	move.b	(a1)+,(a0)+
	dbf	d0,fnloop
	clr.b	(a0)		;null term font name str (not needed?)
hadfontname:
	lea	BottomRowAscii_(BP),A0	;clear 'bottom overscan hires display'
	;AUG081990;moveq	#(78/4)-1,D0	;really only clrs 76 bytes
	moveq	#(BOTROWLEN/4)-1,D0	;really only clrs 76 bytes
aclr:	move.L	#'    ',(A0)+	;fill with BLANKS (have zeros//nulls)
	dbeq	D0,aclr		;no clear 81st, etc, leave zero/null at endstr

	move.w	#38,BrushNumber_(BP)	;little med circle
	;move.w	#31,BrushNumber_(BP)	;5x5 SQUARE BOX BRUSH
	;move.w	#22,BrushNumber_(BP)	;right slant7x7? (23=6x6,24=5x5,etc)
	;move.w	#21,BrushNumber_(BP)	;right slant10x10?
	;move.w	#6,BrushNumber_(BP)	;SINGLE DOT BRUSH

	clr.w	StretchGain_(BP)
;	move.w	#-1,StdPot5
	move.w	#$7fff,d0
	move.w	d0,StretchHPot_(BP)	; horizontal blend of 2way
	move.w	d0,StretchVPot_(BP)	; vertical blencd of 2way

	move.b	#1,StretchOnOffNum_(BP) ;#1=hor||, #2=ver--, #3=both++, #0=none

	moveq	#15,D0			;WHITE PAINT DEFAULT RGB paint color
	move.b	D0,Pblue_(BP)
	move.b	D0,Paintblue_(BP)
	move.b	D0,Pred_(BP)
	move.b	D0,Pgreen_(BP)
	move.b	D0,Paintred_(BP)
	move.b	D0,Paintgreen_(BP)
	move.b	#6,PaintNumber_(BP)	;'shadow/background shading'
	move.b	#0,ModeNumber_(BP)	;normal mode	

	move.b	#18,PenColor_(BP)	;palette color #16 COLOR=FOREGROUND

	move.l	sp,random_seed_(BP)	;set random seed to be our stack address

	lea	SinTab,a0		;YECH an absolute relocatable XREF
	move.l	a0,BlendCurvePtr_(BP)	;256 byte size entries, 1 table 2ways

	lea	DefaultColors(pc),A0
	lea	LongColorTable_(BP),a1

	movem.l	a2-a4,-(sp)		;STACK a2-a4 probably not needBsaved?
	lea	HiresColorTable_(BP),a2
	lea	HamToolColorTable_(BP),a3
	lea	BigPicColorTable_(BP),a4

	moveq	#19-1,d0	;6-1,D0	;#64-1,D0
setupcolors:
	move.l	(A0)+,d1
	move.l	d1,(a1)+
	move.l	d1,(a2)+
	move.l	d1,(a3)+
	move.l	d1,(a4)+
	dbf	D0,setupcolors
	movem.l	(sp)+,a2-a4		;DE-STACK

	;Canceler.o  *changeable* load/save string for gadget AND requester
	;move.w	#'  ',OF_String_(BP)	;just two spaces
	move.l	#'Open',LS_String_(BP)
	move.l	#' Fai',(4+LS_String_)(BP)
	move.l	#('led'<<8),(8+LS_String_)(BP) ;ensure end with NULL

	move.b	#6,bmhd_nplanes_(BP)
	move.b	#1,bmhd_compression_(BP)

	st	FlagCDet_(BP)		;"activates" createdetermine subr
	st	FlagXLef_(BP)	;left/even lines
	st	FlagXRig_(BP)	;right/odd lines
	st	CurrentFrameNbr_(BP)	;showgads.o, "asks for new display"
	;;;leave 0 sup clrd ;st	FlagCapture_(BP)	;KLUDGE....s/b in main.cmd, etc?

	;;;no need....blows up anyway...bra	ResetDither	;allocate dither pattern array
	RTS

AOff:	;All Off...initialize flags, modes, etc
	;move.w	#(1<<8),TileX_(BP)	;tile factor of <1> for default
	;move.w	#(1<<8),TileY_(BP)
	move.w	#(1<<4),TileX_(BP)	;tile factor of <1> for default
	move.w	#(1<<4),TileY_(BP)

	moveq	#20,d0			;default ht = 20 or 40 if lace
	move.w	d0,AirWidth_(BP)	;#20,AirWidth_(BP)
	move.w	#10,AirHalfWidth_(BP)
	tst.b	FlagLace_(BP)
	beq.s	001$
	add.w	d0,d0			;ht=40 if lace
001$	move.w	d0,AirHeight_(BP)
	asr.w	#1,d0
	move.w	d0,AirHalfHeight_(BP)

	move.b	#7,PaintNumber_(BP)	;"normal"/clear
	move.b	#0,ModeNumber_(BP)	;""
	sf	FlagSwaped_(BP)
	sf	FlagRub_(BP)
	st	FlagBrushColorMode_(BP)
	st	FlagDitherRandom_(BP)	;randomized dither ON
	st	FlagHStretching_(BP)	;Horizontal stretching ON
	st	FlagSkipTransparency_(BP) ;default OFF NOW ;cutpaste.o/repaint.o/menurtns.o
	st	FlagNeedGadRef_(BP)	;gets 'hires gadget refresh'
	st	FlagFilePalette_(BP)	;for '1st time load'
;	sf	FlagSelClip_(BP)	;not clipselect now.
	sf	FlagProcClip_(BP)
	;;;st	FlagCloseWB_(BP)	;for '1st time preference'


*	xref	TCGadget01
*	lea 	TCGadget01,a0
*	xjsr	_InstallTCHook

	sf	FlagVStretching_(BP)	;Vertical   stretching OFF
	sf	FlagHShading_(BP)	;Horizontal shading OFF
	sf	FlagVShading_(BP)	;Vertical   shading OFF
	sf	FlagBSmooth_(BP)	;smooth drawing OFF
	sf	FlagFlood_(BP)		;flood fill OFF
*	sf	Global_Flood_(BP)	;trun global floodfill OFF
	
	;sf	FlagCirc_(BP)	;drawing circles
	;sf	FlagCurv_(BP)	;drawing curves
	;sf	FlagRect_(BP)	;drawing rectangular boxes
	;sf	FlagLine_(BP)	;drawing lines
	clr.l	FlagCirc_(BP)	;clear 4 "byte size" flags

	sf	FlagToolWindow_(BP)	;"we prefer NOT to see the toolwindow"
	sf	FlagDither_(BP)		;MATRIX dither OFF
	sf	FlagEffects_(BP)	;no effects
	sf	FlagStretch_(BP)	;...(no effects means no stretch, too)
	sf	FlagRotate_(BP)		;digipaint pi

		;digipaint pi
	sf	FlagSetAir_(BP)	;airbrush drawing mode flag, like flagcirc
	sf	FlagSetGrid_(BP)	;airbrush drawing mode flag, like flagcirc
	sf 	FlagCopyColor_(BP)	;make sure copy color is off



	;move.w	#2,MaxTick_(BP)	;using '2', ALWAYS as minimum ticker
	move.w	#3,MaxTick_(BP)	;using '2', ALWAYS as minimum ticker

	move.l	#'999'<<8,FrameNbrAscii_(BP)	;"ascii"
	move.l	#$09090900,FrameNbrBinary_(BP)	;digit-per-BYTE

*	move.b  FrameBufferBank_(BP),d0
*	xjsr	_SetFrameBufferBank	;force bank

	moveq	#0,D0	;ZERO flag
	rts		;InitScratch,Aoff ended ok, alloc'd ok




GimmeDither:	;CALL d0,1 = x.w,y.w  RETURNS D0=y constant, a0=x table ptr D1=trashed
	movem.l	d0-d7/a0/a1,-(sp)	;save d0=x
*
	move.w	d1,d0			;using "y" for seed
	add.w	d0,d0			;y*2
	;add.w	d1,d0			;y*3
	eor.w	d1,d0			;=(y*2) xor y

					;D0=random_seed_
	bsr	reset_dither_tables	;setup 2 1024 size tables full of random #s

	movem.l	(sp)+,d0-d7/a0/a1	;restores d0=x


	LEA	XRandomPtr_(BP),a0
	add.W	d0,a0			;return A0=point a "this x" in array
	;moveq	#0,d0
	;move.b	d1,d0			;result D0=yconstant is now valid in word size, too...
	RTS


Dmask	equr d0
Daconst	equr d1 ;algorythmic constant
Dseed	equr d2
Dcurt	equr d3
Dloop	equr d4
		;macro codesize 8bytes
nxtrandom:	MACRO	;d-register,  (using d5 as subst for random_seed)
	MOVE.W	Dseed,\1	;compute next random seed (longword)
	LSR.W	#1,\1
	BCC.s	norflip\@
	EOR.W	Daconst,\1	;#$B400,\1	;algo ref: Dr. Dobb's Nov86 pg 50,55
norflip\@:
	MOVE.W	\1,Dseed	;temp save random_seed_(BP)
	and.W	Dmask,\1	;i.b #$3f,d6		;.byte of randumbness
	subq.w	#LOWERDITHER,\1
	;sub.w	#LOWERDITHER,\1
	bcc.s	notneg\@
	moveq	#0,\1
notneg\@:
		ENDM



ResetDither:	;alloc 'random dither array's, reset pattern...

	MOVE.W	random_seed_(BP),d0

reset_dither_tables:		;setup 2 1024 size tables full of random #s
				;D0=random_seed_

	MOVE.W	d0,random_seed_(BP)

	move.w	#$3f,Dmask		;mask for requ'd random bits
	move.w	#$B400,Daconst	;algo ref: Dr. Dobb's Nov86 pg 50,55
	MOVE.W	random_seed_(BP),Dseed	;d5 is subst for random_seed in macro

	move.w	Dseed,Dloop	;loop counter
	and.w	#$01f,Dloop	;limit re-seed loop to max 32 iterations
reseedloop:
	nxtrandom Dcurt
	dbf	Dloop,reseedloop

	LEA	XRandomPtr_(BP),a0	;A0=xrandom table ptr, 1024 bytes
	;move.w	#1024-1,Dloop		;loop counter
	move.w	BigPicWt_W_(BP),Dloop	;max # pixels...
	ble	after_stufftable	;bummer, 0 or negative....
	asr.w	#3,Dloop		;/8 per loop
	subq	#1,Dloop		;db' type loop

xstuffloop:
stuff1:	macro
	nxtrandom Dcurt
	move.b	Dcurt,(a0)+
	endm
	stuff1
	stuff1
	stuff1
	stuff1

	stuff1
	stuff1
	stuff1
	stuff1

	dbf	Dloop,xstuffloop

	MOVE.W	Dseed,random_seed_(BP)

after_stufftable:
	RTS	;reset dither







	cnop 0,4 ;note:	we're still in code, so we s/b word aligned already
;MAY23
;DefaultColors:
;	;internal format:default palette if no file
;
;	dc.l	$00000000,$0f0f0f00,$02020200,$05050500
;	dc.l	$08080800,$0c0c0c00,$0d040a00,$0e020200
;	dc.l	$0a050400,$05030200,$0e090200,$07070100
;	dc.l	$0e0d0200,$01090100,$02050800,$03030f00
;
;	;dc.l	$03020600,$0f0f0400,$0f0f0f00	;colors 16,17,18 (18='current')
;	dc.l	$0e0d0200,$0f000000,$0f0e0d00	;colors 16,17,18 (18='current')
;		;^--1st    ^--2nd    ^-current
;		; range     range       color
;

 xdef DefaultColors
DefaultColors:
	;internal format:default palette if no file

	dc.l	$00000000,$0F0F0F00,$05050500,$0A0A0A00
	dc.l	$08000800,$0F040A00,$0D000000,$06020000
	dc.l	$0F060000,$0F0A0800,$0F0F0000,$000F0300
	dc.l	$00060000,$000C0C00,$00060F00,$00000A00

	dc.l	$0e0d0200,$0f000000,$0f0e0d00	;colors 16,17,18 (18='current')
		;^--1st    ^--2nd    ^-current
		; range     range       color


 xdef BlackAndWhites
BlackAndWhites:
	;internal format:default palette if no file

	dc.l	$00000000,$01010100,$02020200,$03030300
	dc.l	$04040400,$05050500,$06060600,$07070700
	dc.l	$08080800,$09090900,$0a0a0a00,$0b0b0b00
	dc.l	$0c0c0c00,$0d0d0d00,$0e0e0e00,$0f0f0f00


MYBASEOFF	set	0	;base offset for xref defines


SByte:	MACRO	;name
	XDEF	\1_
\1_	equ	MYBASEOFF
MYBASEOFF	set	MYBASEOFF+1	;byte
	endm

SWord:	MACRO	;name
	XDEF	\1_
MYBASEOFF	set	((MYBASEOFF+1)/2)*2	;cnop 0,2
\1_	equ	MYBASEOFF
MYBASEOFF	set	MYBASEOFF+2	;word
	endm

SLong:	MACRO	;name
	XDEF	\1_
MYBASEOFF	set	((MYBASEOFF+3)/4)*4	;LONG ALIGN FOR 020's
\1_	equ	MYBASEOFF
MYBASEOFF	set	MYBASEOFF+4	;longword
	endm

SArray:	MACRO	;name,size in BYTES
	XDEF	\1_
MYBASEOFF	set	((MYBASEOFF+3)/4)*4	;long align ARRAYS for 020's
\1_	equ	MYBASEOFF
MYBASEOFF	set	4*((\2+3)/4)+MYBASEOFF	;longword roundup alloc
	endm

 SArray LongColorTable,(64*4) ;allow 64 entries ;COLOR 16=curt, 17=bkgrnd

	SByte Paintred	;r,g,b for color 2 default
	SByte Paintgreen
	SByte Paintblue
	SByte Paintjunk

	SByte BPaintred	;r,g,b for color background / mixer color
	SByte BPaintgreen
	SByte BPaintblue
	SByte BPaintvalu

	SByte DisplayedRed	;LONG word ALIGN! (at least word, please)
	SByte DisplayedGreen
	SByte DisplayedBlue
	SByte PenColor	;we start with color#2 active
	SWord BestPen_W	;for domask.i...quickplots
	SLong PenRtnA	;JUNE01
	SLong PenRtnB	;JUNE02

	SLong _WBenchArgName
	SLong _WBenchMsg
	SLong _WBenchArg
	SLong dosCmdLen
	SLong dosCmdBuf
	SLong our_task
	SLong startup_taskpri
	SLong current_dir
	SLong save_dir

	SLong FlyerLibrary
	SLong RexxLibrary
	SLong DOSLibrary
	SLong ExecLibrary	;using this instead of '#4
	SLong GraphicsLibrary
	SLong IconLibrary
	SLong IntuitionLibrary
	SLong DiskFontLibrary
	SLong ConsoleBase	;GrabConsoleBase rtn in PrintRtns.o
	SLong RexxResult
	SLong RexxResult1

	SLong Where_We_Came_From	;holds initial stack location
	SLong saveexecwindow		;JULY06

	SLong Initializing	;error103,nomemory ;0 = no, -1 = yes
	SLong BrushGadgetPtr

ShortandLong:	MACRO
	SWord \1
	SWord \1_W
	endm

	ShortandLong bytes_per_row
	ShortandLong bytes_row_less1
	ShortandLong words_row_less1
	ShortandLong BigPicWt
	ShortandLong pixels_row_less1
	;TEMP,TEST WITHOUT, WHERE USED?;SWord lwords_row_less1	;only need short, this is new
	SWord temp_lwords_less1	;only need short, this is new 2.0 ONLY used by StrokeB.asm

 SArray Zeros,(4*15) ;4bytes*15registers)
	; usage is: " movem.l	Zeros,D0-d7/A0-a6 "
	;enables 1 instr. (short CODE) clear of multiple registers
	
	SLong MsgPtr
	SLong MsgSeconds	;for double click timings...
	SLong MsgMicros
	SLong HiresIDCMP	;flag bits for message types, set in main.o
	SArray OnlyPort,MP_SIZE ;standard exec message port
	SLong WindowPtr		;your typical big picture window pointer
	SLong GWindowPtr	;"Gadgets" hires/menu screen
	SLong PaleGadPtr	;ptr to struct for 'palette request' gadgets
	SLong PrintGadPtr	;struct for printer "<- ## -> ok cancel" gads
	SLong SizerPtr		;struct for sizing gadgets
	SLong ToolWindowPtr
	SLong RastPortPtr	;RastPort for this window
	SLong WindowRastPort	;wd_RPort(WindowPtr)

	SLong XTScreenPtr
	SLong TScreenPtr
	SLong ScreenPtr
	SLong NewScreenPtr	;used for all, but usually for big pic (saved)
	SLong SkScreenPtr	;only by mousertns, for hires rgb#display
	SLong SkWindowPtr	;...ditto.
	SLong RexxMsgRtnDelayed

	SWord BigPicHt	;ScreenHeight

	SLong LastGadAct	;last active gadget

	SLong PaintRoutinePtr
	SLong PlaneSize ;number of bytes in a bitplane (8000 or 16000)

;the following values are set up as a long word
	SByte Pred	;values to plot, used by 'determine'
	SByte Pgreen
	SByte Pblue
	SByte Pjunk

 ;the following 5 bytes MUST be in this order
	SByte Predold	;actually seen values of pixel to left of one determine
	SByte Pgreenold
	SByte Pblueold
	SByte LastPlot	;Last plotted value (to the left)

	SByte Prederror	;difference (+/-) between 'determined' and wanted rgb
	SByte Pgreenerror
	SByte Pblueerror
	SByte Pjunkerror

	;insure the following values are set up at a long word
	SByte Transpred	;values to plot, used by 'determine'
	SByte Transpgreen
	SByte Transpblue
	SByte Transpjunk

	SLong DetermineRtn	;routine address, setup by InitDetermine()

	SByte FlagNeedGadRef	;need gadget refresh ;LONGWORD Aligned!
	SByte FlagRefProp	;need prop refresh
	SByte FlagRefHam	;need ham imagery refresh
	SByte FlagRefPtr	;need hires 'current brush' imagery

	;NOTE: flag circ,curv,rect,line must be LongWord aligned for drawb test
	SByte FlagCirc	;drawing circles
	SByte FlagCurv	;drawing curves
	SByte FlagRect	;drawing rectangular boxes
	SByte FlagLine	;drawing lines

	SByte FlagFlood		;floodfilling
	SByte FlagBSmooth	;connected brushes...no skipping
	SByte Global_Flood	;Global floodfilling
	
	SByte FlagNeedText	;need hires text display
	SByte FlagTextAct	;need text gadget activate

	SByte FlagCloseWB
	SByte FlagRedoLast	;tool.o, rehohires

	SByte MenuNumber
	SByte MenuItemNumber
	SByte MenuSubItemNumber
	SByte FlagGrayPointer	;usecolormap only does hires gray loadrgb4

	SByte	FlagPrintRgb	;main.msg.i ref
	SByte	FlagPrintString	;main.msg.i ref
	SByte	FlagPrint1Value	;main.msg.i ref
	SByte	FlagPrintXY	;main.msg.i ref

	SByte	FlagSwaped
	SByte	FlagSlack1
	SByte	FlagSlack2
	SByte	FlagSlack3


	SByte FlagPrinting	;TRUE if "busy with printer"
	SByte FlagCapture	;print (capture) a-codes on stdout

	SLong TracePrintString	;adr for trace-out string print
	SLong PrintValue	;main.msg.i//gadgetrtns, trace out
	SLong linecol_offset	;offset to painting line, AND column

	SLong PalGadAct		;Palette slider got down msg but not up yet

		;note: prev LONG forces long-align, MouseRtns.o usage
	SByte FlagRequest	;1="load palette/srhink/ok/cancel" "request" up
	SByte FlagSizer		;sizer gadgets displayed?
	SByte FlagOpen		;this,next together for test.W on FlagOpen
	SByte FlagSave

	SByte PrintCopies	;.BYTE size # copies (if not=0 then printing)
	SByte FlagPrintReq	;.BYTE set if "print req" displayed


	SByte FlagCopyColor	;"activates" copy to user colors.
	SByte FlagCDet		;"activates" createdetermine subr
	SByte FlagColorMap	;"activates" UseColorMap subr
	SByte FlagLine1stPt	;skip sup of 1st endpt in linedraw mode
	SByte FlagNew		;Project Menu Selections
	SByte FlagNeedHiresAct	;activate hires, mainloop, canceler.o ref
	SByte FlagNeedDirAct	;dir string gadget activate
	SByte FlagNeedMagnify
	SByte FlagNeedRepaint	;if he changes paint mode slider, continue
	SByte FlagNeedIntFix	;interlace fixzit, handle by msg code
	SByte FlagNeedMakeScr	;also handled by FixInterLace
	SByte FlagNeedShowPaste	;need another brush display
	SByte FlagNeedShowPal	;used with flagrefham
	;;;SByte FlagNeedScr	;need screen, mainloop calls openbigpic
	SByte FlagPaleMatch	;iffload.o, ComparePalette result, file=curt?
	SByte FlagRedrawPal	;used by/for openhamtools

	;;;SByte FlagDrag		;version 2 drag refers to bigpic dragging
	SByte FlagBrush 	;0=FILE loadsave	1=BRUSH loadsave
	SByte FlagBrushColorMode
	SByte FlagQuit
	SByte FlagText		;indicates 'text mode' for brush//cut subr's
	SByte FlagAgain 	;repaint on/off (1st or 'n'th time?)


	SByte FlagRub		;rubthru on/off global flag
	SByte FlagSkipTransparency	;cutpaste.o/repaint.o/menurtns.o
	SByte FlagMagnify	;Bkgnd Menu Selections
	SByte FlagCheckBegMag
	SByte FlagCheckKillMag

	SByte FlagMagnifyStart	;=1, pointer is mag/glass, not yet mag'ing
	SByte FlagCutPaste	;=1 when cutting, carrying cutout/blit brush
	SByte FlagCut
	SByte FlagPick		;set when "button down on ham tools"
	SByte FlagDisplayBeep	;flags mainloop to flash hires (outta memory)
	SByte FlagAAlias	;same flag for stretching, text control
	SByte FlagEffects	;ANY effects at all? (stretch,mirror,etc)
	SByte FlagStretch	;set when 'brush warping' in effect
	SByte FlagColorZero	;set = ignore color zero
	SByte FlagBitMapSaved	;set when UnDoBitMap is a "good clean clone"
	SByte FlagFilePalette	;0=use current pallette, 1=usenew from file

	SByte FlagSingleBit
	SByte PaintNumber
	SByte ModeNumber	;Current mode number


	SWord FlagRepainting ;why a WORD? ...dunno but it might bite if changed.
	SWord DispBrushNumber	;displayed brush # (pointers.o)
	SWord BrushNumber	;legal range 0..41 groups of 7=> -,|,\,/,Box,Circ
	SWord BrushSize	;0..6
	SWord BrushType	;0..6

	;rule#452: if circular stretching is set, regular stretching is also set
	;NOTE: WORD ALIGNED GROUPINGS FOLLOW
	SByte FlagHStretching	;Horizontal	stretching ON
	SByte FlagVStretching	;Vertical	stretching ON

	SByte FlagHShading	;Horizontal shading ON
	SByte FlagVShading	;Vertical	shading ON

	SByte FlagDither	;word align these two
	SByte FlagDitherRandom

	SByte FlagToolWindow ;set when we want to see menu&gadget screen
	SByte FlagLace
	SByte FlagLaceNEW	;for sizer (new screen in interlace?)
	SByte FlagWBench

	SWord LastCoordX	;...main.o tools.o showpallette.o(digits) gadgetrtns
	SWord LastCoordY

	SByte FlagPalette	;flag for palette load/save (not used?)
	SByte FlagPale		;palette gadgets
	SByte FlagCtrl		;slider gadgets
	SByte FlagCtrlText	;text gadgets
	;SByte FlagSizer	;sizer gadgets displayed?

	SByte FlagProc		;This is the Image Processing screen
	SByte FlagOptions	;This is the option control screen
	SByte FlagDevicesOnly	;This is the option control screen
	SByte FlagDisk		;This is the disk IO panel


	SByte FlagLaceDefault	;iffload, in case cant resize

	SByte FlagClip		;set when brush went of edge, for floodfill
	;;;SByte FlagHelp		;load alternate 'help' picture
	SByte FlagMenu		;set when intui' menu happening (main.msg)
	SByte FlagRemap		;set when need a remap
	SByte ShadeOnOffNum	;binary 0,1,2,3 for vert/hor on/offs
	SByte StretchOnOffNum	;binary 0,1,2,3 for vert/hor on/offs
	SByte LoadDepth	;iffload
	SByte FlagFirstLine	;used by anti-aliasing
	SByte FlagFont
	SByte FlagFontFirstTime	;used to 'cd fonts:' (showfreq.o)
	SByte FlagFoundKey	;main.key.i (only..scan keytable usage)
	SByte FlagHiBrush
	SByte FlagMaskOnly	;special drawing modes don't paint when set;JUNE88
	SByte FlagDotOnly	;like maskonly, for dots/brushes, circles/drawb
	SByte FlagCoord
	SByte FlagGadgetDown	;set/clrd by main.msg, used by apropointer
	SByte EffectNumber
	SByte FlagReSee
	SByte FlagWholeScreen
	SByte FlagFrbx		;routine ScreenArrange in GadgetRtns
	SByte FlagRexxReq
	SByte FlagRexxSave	;is a rexx file operating?
	

	SWord FlagViewPage ;overscan 1 or 2
	SByte FlagXLef
	SByte FlagXRig
	SByte FlagXSpe
	SByte FlagSelClip		;Clip selection
	SByte FlagSelDestClip
	SByte FlagProcClip		;Want to process a clip
	SByte FlagField2loaded		;has field 2 just been loaded, if so load field 1 of next frame.


	SByte FlagAlphaFS		;Save alpha with framestore
	SByte FlagAlpha4		;Save 4bit Alpha alone
	SByte FlagAlpha8		;Save 8bit Alpha alone
	SByte FlagLoadAlpha		;Load Alpha image
	
	;JUNE05;SByte MagnifyFactor_	;1=no mag, no use, 2,4,8 valid (domagnify.o)

	SWord MSG_MouseX
	SWord MSG_MouseY

		;the following 3 words are required for moveM's in do/drawbrush
	SWord MyDrawX	;our idea of where we are in current screen/brush pos
	SWord MyDrawY
	SWord BrushLineWidth_w

	SWord LastDrawX	;our idea of where we are in current screen/brush pos
	SWord LastDrawY

	SWord FlipWidth	;setup in BrushFx.o, used for 'rotate90's in doeffect.o
	SWord Pot0Temp	;THESE are temporary for sliders...
	SWord Pot1Temp
	;june22;SWord Pot2Temp
	;june22;SWord Pot3Temp
	SWord col_offset	;column offset
	SWord paint_width	;greatest paint width (strokebounds result)
	SWord halfpaint_width
	SWord v_extraleft	;leftside, for vert stretch
	SWord ppix_row_less1	;paint #pixels (groups of 32)
	SWord pwords_row_less1	;#longwords (-1) from 1st painted to last+3 JUNE
	SWord plwords_row_less1	;#longwords (-1) from 1st painted to last+3
	SLong SAStartRecord	;ADR OF 1st pixel's "record" inside savearray

	SLong RememberKey	;big daddie

	SLong EffectNamePtr	;warpname: real ascii ptr, frm menuitem ituitext
	SLong ExtraChipPtr	;main.o, memories.o, "extra" chip for openscreen
	SLong ModeNamePtr	;paintname:real ascii ptr, frm menuitem ituitext
	SLong StencilNamePtr	;paintname
	SLong KeyArrayPtr	;key/action codes (default.asm)
	SLong DescArrayPtr	;(x,y)(x,y) description (default.asm)
	SLong BlendCurvePtr	;256 byte size entries, 1 table 2ways (paintcode)

	SLong ActionCode	;psuedo ascii, code for 'what to do'

	SLong InpStdIO		;Std_io_request for input events.DEH062994
	SLong InpDevPtr		;Input device pointer

	SWord	DlvrLine	;line# on screen
	SWord	DlvrCount	;# of rgbs
	SLong	DlvrPtr		;array of count*6 words containing (r.w,g.w.b.w)


 SWord	MaxTick			;#vertb's between remagnifies
 SLong	RemagTick		;last 'tick time' we magnified (domagnify.o)
 SLong	RetextTick		;last 'tick time' we displayed text (showtxt.o)
 SLong  LastScrollTick		;last 'tick time' actually scrolled/checkcancel'd
 SLong	ShowPasteTick		;last 'tick time' we displayed text (showtxt.o)
 SLong	Ticker			;long size counter, decr 50x(pal) or 60x second
 SArray IntServer,IS_SIZE	;interrup server node struct (main.int.i,main.o)


define_bitmap:	MACRO	;name,#ofplanes{,name for bitplane adr table}
	SArray \1,bm_Planes	;bm_Planes=8, so lword align of array is ok	
	SArray \1_Planes,(8*4)	;8 long pointers
	endm

 ;define_bitmap ScreenBitMap	;BITMAPS MUST BE (blits.o) order'd scr/super/paste
 SArray ScreenBitMap,8		;bm_Planes
 SLong  ScreenBitMap_Planes	;1st bitplane adr
 SArray SBMPlane1,(4*7)		;table of 2nd..8th bitplane addrs

 define_bitmap UnDoBitMap
 define_bitmap PasteBitMap
 SArray extraxxx,12
 define_bitmap AltPasteBitMap	;other, 'swap' brush
 SArray extraxxxx,12

 define_bitmap PasteMaskBitMap
PMBM_Planes_	equ	PasteMaskBitMap_Planes_
 SArray extraxxxxx,12
	xdef PMBM_Planes_

 define_bitmap CPUnDoBitMap,8
 define_bitmap SwapBitMap,8
 define_bitmap DoubleBitMap,8
 define_bitmap CusPtr_BitMap,1
 define_bitmap BB_BitMap,1
BB1Ptr_	equ	BB_BitMap_Planes_
	xdef	BB1Ptr_
 define_bitmap Spec2Way_BitMap,4 ;bgadrtns.o, bitmap struct for "grab image blit"

	SWord StartDrX		;x,y pair, MOUSE COORDS, center of circle
	SWord StartDrY
	SWord EndDrX		;x,y pair
	SWord EndDrY

	SWord BrushGrabX
	SWord BrushGrabY

	SLong LastM_Window

	SWord RStartDrX		;x,y pairs; SORTED FOR RECTANGLE
	SWord RStartDrY
	SWord REndDrX
	SWord REndDrY

	SWord DeadY	;dead brush, need to clear this y,ht in screenbitmap
	SWord DeadHt

	SWord NormalWidth	;workbench size, adjust for non-intlace lores
	SWord NormalHeight

	SWord NewSizeX		;managed by sizer.o routines
	SWord NewSizeY
	SWord DefaultX		;sizer...."revert" fields...
	SWord DefaultY		;...contain size of 'undo' or default

	SWord ElliXFact		;ellipse x factor (like "aspect")
	SWord ElliYFact
	SLong ElliXRadius	;ellipse "radius"
	SLong ElliYRadius	;ellipse "radius"
	SLong ElliRadiusSq	;**2,squared

	SLong CircRadius	;circle vars
	SLong CircRadiusSq	;**2,squared
	SLong line_offset	; number of bytes to start of this line
	SWord XAspect		;10=lores, 20=lores i'lace (never 5 medres)

	SWord first_x		;strokeb.o
	SWord last_x		;strokeb.o
	SWord BrushX_w		; "MyDrawX" being used/incremented
	SWord BrushWidth_Count
	SWord MaxBit
	SWord SaveMaxBit
	SLong fraction_long_red
	SLong fraction_long_green
	SLong fraction_long_blue

	SWord line_x
	SWord line_y

	SLong MagnifyAdrOffset ;DoMagnify.asm
	SWord MagnifyOffsetX
	SWord MagnifyOffsetY
	SWord MagXShift		;leftedge offset

	SLong random_seed
	SWord first_line_y
	SWord last_line_y
	SWord stXMidPoint	;Stretching vars
	SWord stYMidPoint
	SWord stRatioA
	SWord stRatioB
	SWord stretx_fac	;for gadget quick display
	SWord strety_fac
	SWord tempVknob		;stretching knob value
	SWord tempHknob
	SWord lineAE
	SLong lineAE2		;squared 
	ShortandLong lineAB	;int.frac
	SWord lineCF
	SWord lineBE
	SWord lineBF
	ShortandLong XIntercept
	ShortandLong YIntercept
	SWord Quadrant	;1,2,3,4...really only need a byte "~but~..."...
	SWord XMidPoint
	SWord fx_left
	SWord fx_right

	SLong AreaBufferPtr	;list of endpts (4bytes per...)
	SLong AreaBufferLen
	SLong AreaVectorPtr	;list of endpts (*5*bytes per...)
	SLong AreaVectorLen	;.long
	SLong AreaChunk		;ptr to alloc'd (9 bytes per...) REAL MEMORY
	SLong AreaChunkLen

	SLong TempGain	;stretching use, gain pot
	SWord TileX
	SWord TileY
	;SWord ThisAAliasX
	;SWord ThisAAliasY
	;SWord LastAAliasX
	;SWord LastAAliasY
	;june05
	SLong ThisAAliasX
	SLong ThisAAliasY
	SLong LastAAliasX
	SLong LastAAliasY

	SWord StretchGain
	SWord StretchGainAlt	;'alt', here, means the 'not' of stretchgain
	SWord StretchHPot	;clone value from horizontal blend of 2way
	SWord StretchVPot	;clone value from vertical blencd of 2way
	SWord Strleftblank	;#pixels leftside skip, stretch source bitmap

	SWord line_y1
	SWord line_y2
	SWord paste_x
	SWord paste_y
	SWord paste_width	
	SWord paste_height	
	SWord paste_leftblank	;#pixels before 1st masked pixel in a brush
	SWord paint_leftside	;ONLY USED BY REPAINT, sup by Paste
	SWord paste_offsetx	;subtract these from 'pointer' for brushtopleft
	SWord paste_offsety
	SWord altpaste_leftblank	;#pixels before 1st masked pixel in a brush
	SWord altpaste_offsetx	;subtract these from 'pointer' for brushtopleft
	SWord altpaste_offsety
	SWord altpaste_width
	SWord altpaste_height
	SWord paste_clipy	;#lines of top of scr

	SWord paste_shift	;when re-painting, starts@mod32, shift to 'real'
	SWord save_display_x	
	SWord save_display_y	
	SWord last_paste_x	
	SWord last_paste_y	
	SWord ThisX
	SWord ThisY
	SWord ScrollSpeedX
	SWord ScrollSpeedY

	SByte FlagCutShading	;cutpaste.o only
	SByte CutFlagPaste	;cutpaste.o only

	SLong	LoResMask	;bitplane, mask for brush, normally paste-7th
	SLong	HiResMask	;hires/'realtime anti-alias" mask bitplane

	SLong	CurrentPointer


 SArray PropSettings,((4*2)*4)	;4 entries per, 4 tables

; SArray HiresColorTable,(19*4)	;64
; SArray HamToolColorTable,(19*4)	;64
; SArray BigPicColorTable,(64*4)

; SArray HiresColorTable,(19*2)
 SArray HiresColorTable,(67*2)
 SArray HamToolColorTable,(19*2)
 SArray BigPicColorTable,(64*2)

 	;iconstuff
	SLong diskobject
	SLong brite_error
	SWord brite_meddk
	SWord brite_lite
	SWord brite_dark
 SArray brighthist,(16*4)

 SArray SwapBitMap_RP,rp_SIZEOF
 SArray CusPtr_BitMap_RP,rp_SIZEOF
 SArray	PasteRastPort,rp_SIZEOF
 SArray TextMask_RP,rp_SIZEOF
 SArray PrintRastPort,rp_SIZEOF		;PrintRtns.o, dummy rport for printer
 SArray ScreenBitMap_RP,rp_SIZEOF 	;"extra" used by DoMagnify
 SArray DoubleBitMap_RP,rp_SIZEOF 	;"extra" used by cutpaste

 SArray FillAreaInfo,ai_SIZEOF	;newflood/cutpaste
 SArray FillTmpRas,tr_SIZEOF

 ;AUG081990;SArray BottomRowAscii,84		;nice'nlong,80bytes+nullnullnullnull
 SArray BottomRowAscii,BOTROWLEN+4	;nice'nlong,80-plus-bytes+nullnullnullnull
 ;SWord OF_String			;dc.b '  '=two ascii spaces
 SArray LS_String,12	;dc.b 'Open Failed',0	LS_String MUST follow OF_String

	;Requesters.asm
       ;OLD field sizes/spacing on basepage MUST stay, for digiview4.0 compat'
 SArray OldDirnameBuffer,82+2 ;48
 SArray OldDirsaveBuffer,82+2 ;48	;last dir name displ'...for cmp w/ user input
 SArray	BigStringUnDo,80	;"doubles" as text string buffer
 SArray OldFilenameBuffer,82+2 ;70
 SArray OldProgramNameBuffer,82+2 ;60

 SArray ListImage,20	;ig_SIZEOF ;image struct for ListGadget (filename prop)
 SArray HVShadingBUPImage,20	;ig_SIZEOF, image struct for 2way 'coverup'
 SArray HVStretchingBUPImage,20	;ig_SIZEOF, image struct for 2way 'coverup'
 SArray TextAttr,8
 SArray FontNameBuffer,82+2 ;60
	SLong TextFont	;current (if non-zero, needs to be closefont'd)
	SLong DiskFont	;current (if non-zero, needs to be remfont'd)
	SLong FontSeg	;ptr to loadseg'd font



	;repaint/alternate (for shading)
	SLong CenterAdjust_l

	SLong MScreenPtr	;magnify screen
	SLong MWindowPtr	;a 'big window' on magnify screen
	SLong MCBWindowPtr	;close box on magnify screen

	SLong MagnifyTablePtr	;2k table, expanded bytes (domagnify.o)
	SLong ShortMulTablePtr	;setup/managed in memories.o, used by paintcode
	SLong DetermineTablePtr
	SLong BriteTablePtr


 SArray MagRgbArray,(50*4) ;25 rgbs for lores, 50 for interlace magnify leftside

 SArray MyIODRPReq,iodrpr_SIZEOF ;printer io request
 SArray CONSOLEReq,iodrpr_SIZEOF ;console dev io requ for consolebase grab



;; SArray BigNewScreen,32	;ns_SIZEOF	;main.o
 SArray BigNewScreen,32+4	;ns_SIZEOF	;main.o

 SArray SCREENTAGS,48		;SCREEN TAG LIST

; SArray TempNewWindow,64	;?only REALLY need 48 nogoodreasonnotrustcount?
;BigNewWindow_	equ	2+TempNewWindow_	;offshort SHORT WORD ALIGNED?
;	xdef BigNewWindow_
  SArray BigNewWindow,64

;startof iffload vars

	SLong abort_fsave_stack
	SWord fsaving_height
	SWord savebytes_row
	SByte savesuccess
	SByte FlagError

	SLong FormDataPos
	SLong FormLength
	SLong ChunkName
	SLong ChunkLength
	SLong CAMG		;digipaint current/saves to file
	SLong FileCAMG		;always the last "read from file" value
	SByte FlagHamFile
	SByte FlagHires		;LATE JUNE 88 ....fixes lots, helps lots...

; fields used by ReadBody

	SLong ldlineoffset	;byte # for start of current line
	SWord pxnumber_w
	SWord ldline_w		;current line number
	SWord filebpr		;number of bytes per row in the file
	SWord filebpr_less1	;number of bytes per row in the file
	SByte mask_b		;ds.b 1 ;bit# in byte

	SLong PicFilePtr	;hp.gads, the entire file, in memory, (default.o)
	SWord GadSkipLines	;#lines in gadget picture file to skip
	SWord HiresDispLines	;showgads.o, #lines on hires
	SWord PicFileLines	;showgads.o, #lines on hires//file
	SByte PicFileDepth	;3 or 4 a must, since using color#s 1..7
	SByte CurrentFrameNbr	;so no redisplay of menu, autorequest bkgrnds
	SLong CurrentRenderScreen	;This is used to pass a screen pointer
					;to the user interface rendering code

	SLong StdOut		;shortens 'main' code...

  ;older(already ok in use)IFFLoad vars
	SLong FileHandle	;these 3 in this order, movem before dos call
	SLong FileBufferPtr
	SLong BufferLen

	SLong BufferCount	;was word	

	SWord LoadPlane_pixels	;how many pixels we can handle (or want?)
	SLong LoadPlanesLen	;len of ALL
	SLong LoadPlane0Ptr
	;SLong HelpBufferPtr	;default.o use, help picture file
	;SLong HelpBufferLen

	SLong Buffer4	;FileRtns
 SArray FileColorTable,(64*4)	;used for holding rgb's from file if we dont
				;...change palette for displaying this picture
;endof iffload vars

;dirrtns vars
	SLong LastItemAddress	;gadgetrtns,dirrtns use for filename str's
	SLong DirNameLen	;main.cmd.i, really...
	SLong ProgNamePtr	;main.cmd.i, if from cli
	SWord ProgNameLen

	SLong ProgDir		;dir lock for 'resources' tool/program dir
	SLong ProgDelDir	;lock 'to be deleted'
	SLong ProgRbrKey	;remember struct for filenames/dirgadget
	SLong ProgEntCt		;only need/use byte?

	SLong FontDir		;dos lock
	SLong FontDelDir
	SLong FontRbrKey	;remember struct for filenames/dirgadget
	SLong FontEntCt		;only need/use byte?

	SLong BrushDir		;dos lock
	SLong BrushDelDir
	SLong BrushRbrKey	;remember struct for filenames/dirgadget
	SLong BrushEntCt	;only need/use byte?


	SLong	LineEndsPtr	;iff alloc'd, array of longword (x.w,y.w) pairs
	SWord	NLines
	SWord	CurtLineEnd	;starts at 2nd entry (always have at least 2)
	SLong	LinePlanePtr	;PlaneSize, copy of 'line' mask

	SLong DeleteDirLock
	SLong DirRememberKey
	SLong CurrentRemember
	SLong ScrollAmount
	SLong ScrollGadget

	SLong EntryCount

	SWord NewEntryNumber
	SWord EntryNumber

	SByte FlagDirRead
	SByte StencilFlag
	SByte PostScriptFont
	SByte AirBrushOn

	SByte PalleteNeedsRefresh	;if 0 palette screen will get a refresh
					;(this means the image from gadtools)

	SByte TransPortMode		;Temp flag

	SByte	StencilSign
	SByte	Pad1
	SByte	Pad2
	SByte	Pad3


	SArray DirItem,(fib_SIZEOF+3)	;ds.l ((fib_SIZEOF+3)/4)

;endof dirrtns vars

;Blits.o vars
	SWord brush_x
	SWord brush_y
	SWord newblit_height
	SWord newblit_width

 ifnd TIMEVAL
 STRUCTURE TIMEVAL,0
 ULONG   TV_SECS
 ULONG   TV_MICRO
 LABEL   TV_SIZE
  endc

  ifnd InputEvent
 STRUCTURE  InputEvent,0
   APTR  ie_NextEvent
   UBYTE   ie_Class
   UBYTE   ie_SubClass
   UWORD   ie_Code
   UWORD   ie_Qualifier
   LABEL ie_EventAddress
   WORD    ie_X
   WORD    ie_Y
   STRUCT  ie_TimeStamp,TV_SIZE
   LABEL   ie_SIZEOF
 endc

 SArray KeyBuffer,8	;see main.key.i, gadgetrtns, for rawkeycvt (only use 4?)
 SArray FakeIE,ie_SIZEOF		;input event, main.key.i
 SArray TopOFile,TOF_SIZEOF		;for file saving
 SArray CurtBriteTable,(4*16)		;=64 bytes for cur't color brite levels


; BMHD save fields (Bit Map HeaDer), used for file load decoding

	SWord bmhd_rastwidth	ds.w	1
	SWord bmhd_rastheight	ds.w	1
	SWord bmhd_rastx	ds.w	1
	SWord bmhd_rasty	ds.w	1
	SByte bmhd_nplanes	ds.b	1
	SByte bmhd_masking	ds.b	1
	SByte bmhd_compression	ds.b	1
	SByte bmhd_pad1		ds.b	1
	SWord bmhd_tpcolor	ds.w	1
	SByte bmhd_xaspect	ds.b	1
	SByte bmhd_yaspect	ds.b	1
	SWord bmhd_pagewidth	ds.w	1
	SWord bmhd_pageheight	ds.w	1

bmhd_RECORD_	eQu	bmhd_rastwidth_		;NOTE:equ'd to 1st field
	xdef bmhd_RECORD_
bmhd_SIZEOF_	eQu	bmhd_pageheight_-bmhd_RECORD_+2	;NOTE:the "+2" for word
	xdef bmhd_SIZEOF_

;DigiPaint PI
 SLong Print12Ptr	;ptr to struct, managed by Print12.asm, new on AUG221990
 SArray TwoXImage,20	;"2x" button's imagery....

		;composite stuff...
	define_bitmap CompChipBM,8 ;need 8 bitplanes...
	define_bitmap CompFastBM,8

define_RGBmap:	MACRO	;name,#ofplanes{,name for bitplane adr table}
	SArray \1,bm_Planes	;bm_Planes=8, so lword align of array is ok	
	; SArray \1_Planes,(3*4)	;ONLY 3 long pointers=red
	SLong	\1redptr	;bm_Planes...ptr to alloc'd buffer
	SLong	\1greenptr
	SLong	\1blueptr
	SArray	\1zeros,(4*4)	;AUG311990...needs zeros as 4th, etc ptr
	endm

	;;"regular" bitmap structure, but some of the fields have names
	;;define_RGBmap BigPicRGB ;"main" picture (Uses Data_ fields)
	;;not used;;SLong DataSize	;actual size...(including +4 lines)
	SWord DataWt	;wt, ht in pixels
BigPicRGB_	equ	DataWt_
	xdef BigPicRGB_		;start-of-bigpic "Standard" rgb bitmap
	SWord DataHt	;actual ht is +4
	SByte	flagsxxx
	SByte	PlanesXXX
	SWord	padXXXX
;	SArray bitmapfiller,bm_Planes-bm_Flags
		

	SLong Datared	;rgbrtns.asm...actual data has a 2 lines above/below
	SLong Datagreen	;...these addresses
	SLong Datablue
;	SArray Datazeros,(4*4)	;AUG31,1990....put at least one long here...probably not needed

	;from instinct.i STRUCT		PIC_ALPHA,bm_SIZEOF		;ALPHA
	SArray Alphabm,bm_SIZEOF

	;;"regular" bitmap structure, but some of the fields have names
	;;define_RGBmap UnDoRGB ;"main" picture (Uses Data_ fields)
	;;;not used;;;SLong UnDoSize	;actual size...(including +4 lines)
	SWord UnDoWt	;wt, ht in pixels
	xdef UnDoRGB_
UnDoRGB_	equ	UnDoWt_
	SWord UnDoHt	;actual ht is +4
	SArray Ubitmapfiller,bm_Planes-bm_Flags
	SLong UnDored	;rgbrtns.asm...actual data has a 2 lines above/below
	SLong UnDogreen	;...these addresses
	SLong UnDoblue		;BACKUP rgb buffers, for undo
	SArray UnDozeros,(4*4)	;AUG31,1990....put at least one long here...not needed?

	define_RGBmap SwapRGB		;"rub thru/swap screen"
	define_RGBmap PasteRGB		;"cutout/paste" brush
	define_RGBmap AltPasteRGB	;"swap/txmap" brush

	SLong CompTick		;last 'tick time' we displayed text (composite.o)
	SLong SolLineTable	;ptr to 1k of 'flag bytes'...ind need plot
	SLong SolWorkPtr	;ptr to a "savearray" struct

	ShortandLong CompScrWt	;wt, ht of composite "screen", bitmaps, really
	ShortandLong CompScrHt
	ShortandLong CompSize	;actual bitplane size

	SWord LastRepaintX	;setup after strokebounds call, (repaint)
	SWord LastRepaintY	;...used by rgbrtns, undorgb
	SWord LastRepaintWt
	SWord LastRepaintHt

	SWord CPlotWt		;composite.asm, plot width
	SByte CPlotLine_W	;composite.asm, current line#
	SByte CPlotLine_B	;composite.asm, current line#

	SWord CompFLine_W	;first line# to plot (composite screen)
	SWord CompLLine_W	;last line
	SLong CompLineOffset	;offset on composite screen, 1st/highest line

	SWord Paint8red		;WORD size, 8 bits valid (ShowTxt.asm, etc)
	SWord Paint8green	; if .word is negative, then invalid
	SWord Paint8blue	; if .word is positive, then valid

		;used by PenD_ and PenU_ rtns in MouseRtns.asm, JULY191990
	SWord Save8red		;WORD size, 8 bits valid (ShowTxt.asm, etc)
	SWord Save8green	; if .word is negative, then invalid
	SWord Save8blue	; if .word is positive, then valid

	SLong TempUCop	;copper.asm
	SLong CopperView

	SWord GridXMod
	SWord GridX1
	SWord GridYMod
	SWord GridY1

	SWord GStartX
	SWord GStartY

	SWord AAred	;anti-alias totals 8bits+4=12 bit colors
	SWord AAgreen
	SWord AAblue

	SByte FlagFillMode
	SByte FlagGridMode
	SByte FlagSetGrid	;on when 'pendown selecting grid coords'
	SByte FlagShamFile

	SByte FlagRotate	;really should be 'effect #?'
	SByte FlagDPID		;iffload, digipaint-type file

	SByte FlagAir		;airbrush drawing mode flag, like flagcirc
	SByte FlagSetAir	;airbrush drawing mode flag, like flagcirc

	SByte FlagDoAir		;handled by interrupt routine (main.int.i)
	SByte FlagAnim		;anim frame gadgets
	SByte FlagAlphapaint	;painting in alpha.
	SByte FlagLRpaint	;painting in LR.
	SByte FlagHave4b	;Have a Current 4 Bit fastRam alpha buffer	


	SByte Flag24		;used by scratch/repaint only
	SByte FlagClin		;curved lines....new drawing mode

	SByte FlagCutLoadBrush	;bleah....logical kludge, accessed in main loop, iffload.24.i
	SByte FlagToast		;applies only when allocating bitmaps
	SByte FlagToastGads	;applies only to gadgets (no dither, front/back box, etc)

	SByte FlagWorkHires	;set when 'savearray' is in hires format for repaint
	SByte FlagWholeHam	;"need" redo of ham display, whole screen, from rgb data

	SByte FlagSnap		;main.key.i, if set, keeps "hires" screen center'd
	SByte FlagToasterAlive	;called from toaster/switcher?
	SByte FlagToastCopList	;true when toaster coplist displayed
	SByte FlagCompositeFile	;iffload (and save...)

	SByte FlagKeep24	;don't delete 24 bit buffers from toaster/switcher
	SByte FrameBufferBank	;0 or 1

	SByte FlagCompFReq	;file requester...composite/framestore mode?
	SByte FlagQuitSuper	;gadgetrtns, main.toast.i
	SWord FlagViewComp	;view composite...

	SByte FlagBump32	;repaint.asm only, adjust leftedge by 32 pixels
	SByte FlagUpdateCG	;customgads.asm, set when need update
	SByte FlagScrollStopped
	SByte FlagShiftKey	;valid for mousemoves only...JULY131990
	SByte FlagAltKey	;valid for mousemoves only...AUG121990
	SByte FlagLButton	;valid for mousemoves only...AUG251990

	SByte FlagDelayBottom	;gadgetrtns, main.int.i, JULY181990
	SByte FlagCancel	;decodecomposite.asm....(only) JULY291990

	SByte FlagAlwaysRender	;main loop...AUG011990
	SByte FlagScrollLock	;main loop...AUG021990
	SByte FlagMemDisplay	;gadgetrtns.asm, showtxt.o  AUG091990
	SByte FlagFrameBlack	;iffload.composite, decode composite AUG151990
	SByte FlagFrameFirstTime ;used to 'cd framestore', ShowFReq.asm, AUG151990

	SByte FlagCantHaveLineMode	;great big guru/kludge fix SEP211990

	SWord ScrollBottom	;#lines across bottom...(main.key.i)

	SWord SAStartX		;'x' pixel number, SAStartRecord points here

	SWord AirWidth
	SWord AirHalfWidth
	SWord AirHeight
	SWord AirHalfHeight

	SWord RatioA	;repaint, 24bit, ratios for blending (12bit uses lut)
	SWord RatioB

	SWord YposRGB		;customgads.asm..."last" position, for rgb inc/dec
	SLong TickerStopped	;main.int.i
	SLong B2PTick		;bytes2planes ticker....ToastGlue.asm

	SLong   ToasterErrorCount	;mine, "private"
	SLong	ToasterMsgPtr	;hang onto select message, return when done
	SLong	ToasterCMD	;"FGC_Commnd..."
	SLong	ToastBase
	SLong	ToastScreenPtr	;toaster interface screenptr

	SLong	Bytes2PlanesRTN	;pointer to routine...
	SLong	DoBlockWriteRTN	;pointer to routine...
	SLong	RestoreCopperListRTN
	SLong	InstallAVERTN

	SArray	SliceColors,16*2	;main.toast.i, slicer screen mgt'

	SLong FirstScreen	;intuitionrtns.asm, global var replacement
	SLong ActiveWindow

	SLong CTBLPtr		;iffload.ctbl.i, digiview 4.0 file support
	SLong Temp24BitPlanes	;iffsave.24.i, unrolled bits
	SLong CTableEntry
	SLong FillTblPtr	;mousertns, fill-mode-colors

	SLong FileSize		;yech...temp for loading digipaint.(keys/gads)
	SLong NotFontDirLock	;showfreq/dirrtns

	SLong TempScreenPtr	;'slice' of bigpicture below hires/menu
	SLong Temp10Data	;ptr to top 10 lines

	SLong PrecompPtr	;alloc'd (& freed?) in ShowRot.asm
	SLong ShortArgsPtr
	SLong RayPtr

	SLong BrushEndsPtr	;showrot.asm, list of brush endpoints
	SLong RotEndsPtr
	SLong NbrBrushEnds	;only using '.word'

	SLong FrameNbrBinary	;frame store #,
	SLong FrameNbrAscii	;ascii rep' of frame store #

 define_bitmap ABitBitMap	;8 bitplanes this macro, 32 total
 SArray other24planes,(4*24)	;32-8=24 bitplanes

	SWord TiltX
	SWord TiltY
	SWord TiltZ

 define_bitmap HiresBitMap,6	;for hires screen's bitplanes (4)
 define_bitmap ToolBitMap,6	;for hires screen's bitplanes (6)

	;larger buffers for these fields, fixes problems with long file/dirnames
 SArray DirnameBuffer,82 ;32+2 ;48
 SArray DirsaveBuffer,82 ;32+2 ;48	;last dir name displ'...for cmp w/ user input
 ;;SArray ReDirnameBuffer,82		;digipaint pi...saved dir name (not/font use)
 SArray FilenameBuffer,82 ;32+2 ;70
 SArray ProgramNameBuffer,82 ;32+2 ;60
 

 SArray TextStringBuffer,82	;strlen=80

 SArray ModeName,32	;paintname:real ascii ptr, frm menuitem ituitext
 SArray	StencilName,32  ;Paintname for stencil mode.

 SArray OneLineBrushMask,MAXWIDTH/8 ;iffsave.24.i....brush mask saving
 SLong	ToastFSNamePtr		;ptr to ascii of frame store pathname
 SLong  ToastDirLock		;grabbed from toastbase, main.toast.i
 SLong  ToastChipPtr		;main.toast.i fills this was adr from toaster...
 SLong  ToastFASTPtr		;main.toast.i fills this was adr from toaster...
 ;12DEC91;SArray ToastChipMap,360*4	;map of "360K chip from toaster"
 SArray ToastChipMap,376*4	;map of "376K chip from toaster"
 ;SArray ToastFASTMap,512*4	;map of "512K fast from toaster" ;OCT'90
 ;SArray ToastFASTMap,562*4	;map of "512K fast from toaster" ;MAR91
 SArray ToastFASTMap,144*4	;map of "144K fast from toaster" ;03DEC91
 SLong	ToastFASTMemSize	;setup in ToastGlue, used in ToasterFAST.asm ;03DEC91

;AUG221990; SLong Print12Ptr	;ptr to struct, managed by Print12.asm, new on AUG221990

 SLong GlobalRGBPtr	;MAR91...handled in main.toast.i
 SLong RenderTiming	;MAY91
 SLong GrabFieldNbr	;0,1,2,3


 SWord LastShade0
 SWord LastShade1
 SWord LastShadeMode


 SWord Joy0previous	;AUG251991	;temp, stash of joy0dat
 SByte Joy0Y		;AUG251991
 SByte Joy0X		;AUG251991

	;vars for 'convert.asm' rgb->toaster code
 SLong VideoLineNumber	;these vars are accessed by "composite.o" encoding rtns
 SLong DisplayLineNumber
 SWord BoxCarI		;filter temporary
 SWord BoxCarQ		;filter temporary

 SLong Plane0 ;	ds.l 1	;points into Plane(4,5,6,7)...interleaved
 SLong Plane1 ;	ds.l 1
 SLong Plane2 ;	ds.l 1
 SLong Plane3 ;	ds.l 1
 
 SLong Plane4 ;	ds.l 1	;actually allocated
 SLong Plane5 ;	ds.l 1
 SLong Plane6 ;	ds.l 1
 SLong Plane7 ;	ds.l 1

	SLong	HandlerMemPtr		;18DEC91
	SLong	ThisActionCode		;02FEB92...main.msg.i, GadgetRtns.asm
	SLong	LastActionCode		;02FEB92...main.msg.i, GadgetRtns.asm

;;;; SLong	TickAmigaCopper	;NOV91, ToastGlue.asm
	SByte	FlagImageDir	;15NOV91;for '3d/image' setup, documented in gadgetrtns.asm
	SByte	FlagSaveCompressed	;26NOV91

	SByte	FlagNeedAutoMove	;18DEC91....input handler/mousemove generator/main loop

 SArray XRandomPtr,1024 ;maxwidth, 1 byte of 6 bit randomness per x
 SArray PictureInfo,PI_SIZEOF	;2.0

 SArray FakeActionMsg,(MN_SIZE+80+(6*MAXWIDTH))	;fake msg buildt in main.key.i


	;BIG NOTE: "extra SAVEARRAY leftside" mostly "dontcare" when fileloading


	;imaginary pixels on left on right edge, too, "softening"

;04DEC91; SArray PasteExtraLeft,(LEFTWIDTH*s_SIZEOF)	;160 pixels * 34bytes = 5,440
 SArray PasteExtraLeft,(384*s_SIZEOF)	;160 pixels * 34bytes = 5,440
	SArray SaveMinusOne,s_SIZEOF ;"extra" imaginary pixel leftedge

;NOV91, KLUDGEOUT; SArray SaveArray,(MAXWIDTH*s_SIZEOF)	;be grandiose, MAX WIDTH MAXWIDTH
 SArray SaveArray,(2048*s_SIZEOF)	;be grandiose, MAX WIDTH MAXWIDTH
	SArray SavePlusOne,s_SIZEOF ;"extra" imaginary pixel rightedge

 SArray PasteExtraRight,(RIGHTWIDTH*s_SIZEOF)
	;'pasteextra'left/right are extra pixel records because...
	;...unplot_psavearray unrolls 32 pixel@time
   SLong  scratch_end


	;AUG31 1991
 xdef _BaseSection ;xdef'd so startup.o can reach next segment for basepage
	section Scratch,BSS
_BaseSection:	ds.b scratch_end_
 END
