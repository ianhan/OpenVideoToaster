* TextStuff.asm

	xdef MakeTextBrush	;comes here after 'return' in text string gadg
	;FROM WHERE???;xdef EndFonts
	xdef SafeEndFonts	;for quitting purposes MAY30
	xdef UseNewFont		;ref'd in FileRtns (when load data/.font)


;	include "ram:mod.i"
	include "ps:basestuff.i"
	include "exec/types.i"
	include "graphics/rastport.i"
	include "graphics/text.i"
*	include "gadgets.i"
	include "intuition/intuition.i"

	include	"graphics/text.i"
	include	"lib/diskfont_lib.i"

	include	"lib/dos_lib.i"
	include	"libraries/dosextens.i"

	include	"ps:serialdebug.i"


;	xref	StdPot7
;	xref	StdPot8
;	xref	StdPot9
;	xref	StdPotA


xst	macro
	xref	\1
	st	\1(BP)	
	endm	

xsf	macro
	xref	\1
	sf	\1(BP)	
	endm	


	xref	TOutlinePSGadget

;;SERDEBUG	equ	1

	xref BigPicHt_
	xref BigPicWt_W_
	xref DirnameBuffer_
	xref EffectNumber_	;.byte size
	xref FilenameBuffer_
	xref FlagBitMapSaved_
	xref FlagCutPaste_
	xref FlagFillMode_		;digipaint pi
	xref FlagFlood_
	xref FlagNeedGadRef_
	xref FlagRub_
	xref FlagStretch_
	xref FlagText_
	xref FontNameBuffer_
	xref FontSeg_		;ptr to loadseg'd font
	xref ProgramNameBuffer_
	xref TextAttr_		;"regular" text attr struct, on basepage
	xref TextButtonGadget	;relocatable from tools, YECH!
	xref TextMask_RP_
	xref TextStringBuffer_	;string gadget ascii
	xref TextFont_	;current (if non-zero, needs to be closefont'd)
			;using TextFont_(BP) OpenDiskFont/CloseFont
	xref DiskFont_	;current (if non-zero, needs to be remfont'd)
			;using DiskFont_(BP) AddFont/RemFont
	xref DiskFontLibrary_
	xref DirnameBuffer_
	xref PostScriptFont_
	xref FlagBrush_
	xref ActionCode_

	xref MSPot7
	xref MSPot8
	xref MSPot9
	xref MSPot0A

	xdef AddString

;	XREF RotTextGadgetLI
;	XREF StrTextGadgetLI
;	XREF SheTextGadgetLI
;	XREF SizeTextGadgetLI



	ALLDUMPS
;	RDUMP

UseNewFont:	;ref'd in FileRtns (when load data/.font)
		;FileNameBuffer_ valid, fontdata for individual font

	bsr	SafeEndFonts		;June04, 'safe' version
	bne	unf_errout

	xjsr	SetAltPointerWait	;"non-interrupt"

 ifeq 0
	bsr	TestFontType
	tst.b	PostScriptFont_(a5)
	beq.s	1$

	bsr	BuildPath
	bra.s	exitloadfont

1$
 endc

 ifeq 1
		;build fontname "digipaint.font" (not needed 'till loaded ok)
	lea	ProgramNameBuffer_(BP),a1
	lea	FontNameBuffer_(BP),a2
	xjsr	copy_string_a1_to_a2	;dirrtns.o
	move.b	#'.',-1(a2)
	move.b	#'f',(a2)+
	move.b	#'o',(a2)+
	move.b	#'n',(a2)+
	move.b	#'t',(a2)+
	clr.b	(a2)
 endc

	lea	DirnameBuffer_(BP),a1
	lea	FontNameBuffer_(BP),a2
	xjsr	copy_string_a1_to_a2	;dirrtns.o
	move.b	#'.',-1(a2)
	move.b	#'f',(a2)+
	move.b	#'o',(a2)+
	move.b	#'n',(a2)+
	move.b	#'t',(a2)+
	clr.b	(a2)

	lea	FilenameBuffer_(BP),a0	;find size of font
	xjsr	cva2i

 ifeq 1
	lea	FilenameBuffer_(BP),a1
	move.l	a1,d1		;dos arg ind1
	CALLIB	DOS,LoadSeg
	move.l	d0,FontSeg_(BP)
	bne.s	gotsegfile
unf_errout:			;JUNE04
	xjsr	FontErrorRtn	;canceler.o (no file loaded)
	moveq	#-1,d0	;set NE flag
	rts

gotsegfile:
	sf	FilenameBuffer_(BP)	;clear out filename after ok load AUG271990
	move.l	d0,-(sp)
	xjsr EnsureBigExtraChip 	;memories.o, about 10k avail? JUNE16
	bne.s	okmemory
	move.l	(sp)+,d0
	bsr	EndFonts	;removes segfile
	bra	unf_errout

okmemory:
	move.l	(sp)+,d0


	add.l	d0,d0
	add.l	d0,d0	;bptr->aptr

	addq.l	#4,d0	;skip bptr to next segment
	addq.l	#4,d0	;skip code "move #100,d0  rts"

	ADD.L	#((4*13)+2),d0	;skip extra?

	move.l	d0,a1			;a1=tf_, text font struct (file data)
	tst.l	(a1)+			;ln_Succ, 0 in file?
	bne	notfont_err
	tst.l	(a1)+			;ln_Pred, 0 in file?
	bne	notfont_err
	cmp.b	#NT_FONT,(a1)		;was it a font file?
	bne	notfont_err

		;grab size from filedata//textfont struct (if possible)
	move.l	d0,a1			;a1=tf_, text font struct (file data)

	move.w	tf_YSize(a1),d0
	cmp.w	BigPicHt_(BP),d0
	bcc.s	fonttoo_tall

	btst	#6,tf_Style(a1)		;color font flag	;DECEMBER 1990
	bne.s	font_nocolorfont	;DECEMBER 1990

	move.b	tf_Flags(a1),d0
	and.b	#(64!32!2),d0	;64=designed,32=proportional,2=revpath
	move.b	d0,tf_Flags(a1)

	lea	FontNameBuffer_(BP),a0
	move.l	a0,LN_NAME(a1)	;force 'nameof font' 2b 'digipaint'
	clr.b	LN_PRI(a1)
	clr.l	MN_REPLYPORT(a1)	;text font struct=mn_size+etc
	move.l	a1,DiskFont_(BP)

	CALLIB	Graphics,AddFont	;<<<GURU HERE?

		;build TEXTATTR to match 'digipaint.font'
	move.l	DiskFont_(BP),a1
	lea	TextAttr_(BP),a0	; STRUCTURE  TextAttr,0
	move.l	LN_NAME(a1),ta_Name(a0)		;APTR     ta_Name
	move.w	tf_YSize(a1),ta_YSize(a0)	;UWORD    ta_YSize
	move.b	tf_Style(a1),ta_Style(a0)	;UBYTE    ta_Style
	move.b	tf_Flags(a1),ta_Flags(a0)

	CALLIB	SAME,OpenFont		;arg a0=textattr
 endc

	lea	FontNameBuffer_(BP),a1
	lea	SampleTextAtt,a0
	move.w	d0,ta_YSize(a0)
	move.l	a1,ta_Name(a0)
	move.l	DiskFontLibrary_(BP),a6
	jsr	_LVOOpenDiskFont(a6)

	move.l	d0,TextFont_(BP)	;needs to be "close"font'd
	beq.s	notfont_err
	xref	FlagOpen_
exitloadfont
	xjsr	EndFileRequ	;gadgetrtns.o

	moveq	#0,d1		;flag zero, worked ok
	rts

notfont_err:
	bsr.s	EndFonts		;unload segfile, etc
	xjsr	FontFileErrorRtn	;canceler.o, 'file not font.'
	moveq	#-1,d0
	rts
fonttoo_tall:
	bsr.s	EndFonts		;unloads segfile, etc
	xjsr	FontTallErrorRtn
	moveq	#-1,d0
	rts
;DECEMBER 1990
font_nocolorfont:
	bsr.s	EndFonts		;unloads segfile, etc
	xjsr	FontCFErrorRtn		;no color fonts, please
	moveq	#-1,d0
	rts
unf_errout:			;JUNE04
	xjsr	FontErrorRtn	;canceler.o (no file loaded)
	moveq	#-1,d0	;set NE flag
	rts



SafeEndFonts:	;ref'd in main.asm
	bsr.s	EndFonts	;returns zero flag if ok
	moveq	#0,d0
	rts			;endfonts

check_fontinuse:
		;MAY30
	lea	DiskFont_(BP),a0	;TextFont_(BP),a0
	move.l	(a0),d0
	beq.s	007$
	move.l	d0,a1
	move.W	tf_Accessors(a1),d0	;anyone else grabbit?
	beq.s	007$			;nobody's using it...
	subq.w	#1,d0			;count s/b 1, just 'us'
	beq.s	007$
	xref FlagQuit_
	sf	FlagQuit_(BP)
	moveq	#-1,d0		;ensure NE flag ('sf' clears it?)
007$
	rts

EndFonts:
	tst.l	TextFont_(BP)
	beq.s	eacTf

	xjsr	InitBitPlanes	;scratch.o,does initrastport, which clears font

	lea	TextFont_(BP),a0	;adr of basepage var
	move.l	(a0),d0			;*textfont
	beq.s	eacTf
	clr.l	(a0)			;clears basepage var
	move.l	d0,a1			;a1=textfont, for graphics lib
	CALLIB	Graphics,CloseFont	;OpenFont complement
eacTf:
 ifeq 1
	lea	DiskFont_(BP),a0	;TextFont_(BP),a0
	move.l	(a0),d0
	beq.s	earemf
	;MAY30;clr.l	(a0)	;clear so don't close it 2x
	move.l	d0,a1
checka:	tst.W	tf_Accessors(a1)	;anyone else grabbit?
	bne.s	bum_unload		;june14
	CALLIB	Graphics,RemFont	;AddFont complement
	clr.l	DiskFont_(BP)		;clear so don't remfont it 2x ;MAY30;
earemf:
	lea	FontSeg_(BP),a0
	move.l	(a0),d1
	beq.s	eacmf
	clr.l	(a0)		;probably not checked for, but indicate 'gone'
	CALLIB	DOS,UnLoadSeg	;removes file (d1=seg)
eacmf:

 endc
	rts

 ifeq 1
bum_unload:	;comes here when couldn't RemFont because...june14
		;someone else open'd it...net effect is to never free
		;...i.e., don't unloadseg, the in-use font...
	moveq	#0,d0
	move.l	d0,FontSeg_(BP)	;instead of unloading it, just 'forget it'
	move.l	d0,DiskFont_(BP) ;instead of 'remfont'ing it...
	rts
 endc

MakeTextBrush:	;ensure 'toggle-text-scr-gadget' is toggled off
	lea	TextButtonGadget,a0	;'a' for text gadget
	move.w	#~SELECTED,d0		;all except for the 'selected' bit
	and.w	gg_Flags(a0),d0
	cmp.w	gg_Flags(a0),d0		;any change (did we turn if off?)
	beq.s	1$
	move.w	d0,gg_Flags(a0)
	st	FlagNeedGadRef_(BP)	;signal for main loop gadget redisplay
1$
	tst.b	PostScriptFont_(a5)
	beq	MakeBrushFromBitmap

MakeBrushFromPs
	movem.l	d0-d5/a0-a3/a6,-(sp)
	DUMPMSG	<MakeBrushFromPS>
	bsr	BuildCommand
 ifeq	0
	lea	constring,a0
	move.l	a0,d1
 	move.l	#MODE_NEWFILE,D2
	CALLIB	DOS,Open
	move.l	d0,d4
	beq	bigdeal1
;;	lea	exstring,a0
 endc
	lea	CommandBuffer,a0
	DUMPMEM	<COMMAND>,0(A0),#200

	move.l	a0,d1
	moveq.l	#0,d2
	move.l	d4,d3
	CALLIB	SAME,Execute

* check for exestinse of file.
	movem.l	d0-d5/a0-a6,-(sp)
	move.l	#RFName,d1	
	move.l	#MODE_OLDFILE,d2
	CALLIB	SAME,Open	
	move.l	d0,d1
	beq	.notthere
	CALLIB	SAME,Close	
	movem.l	(sp)+,d0-d5/a0-a6

 ifeq 1
	lea	RFPath,a0
	move.l	a0,d1
	move.l	#ACCESS_READ,d2
	CALLIB	SAME,Lock
	move.l	d0,d1
	beq.s	2$
	CALLIB	SAME,CurrentDir
 endc
	
	lea	FilenameBuffer_(a5),a1
	lea	RFName,a0
	bsr	AddString

 ifeq 1
	xjsr	DoInlineAction
	dc.w	'Lo','br'
;;	xjsr	ReDoHires
	xjsr	ShowFReq
	xjsr	DoInlineAction
	dc.w	'Ok','ls'
 endc

 ifeq 0
;;	xjsr	UnShowAndFreeDouble


	xref	OKGadget_IntuiText
	move.l	#OKGadget_IntuiText,a0			;relocatable, from showfreq
	move.l	it_IText(a0),a0				;'Load/Save Brush/RGB/Frame'
	lea	4(a0),a0
	move.l	#' Bru',(a0)

	st	FlagBrush_(BP)
;	xst	FlagCutLoadBrush_			;testing030695
	st	FlagOpen_(BP)
	xref	Flag24_
	xref	FlagFont_
	xref	FlagCompFReq_
	sf	Flag24_(BP)
	sf	FlagFont_(BP)	
	sf	FlagCompFReq_(BP) 
	xjsr	File_Load
 endc
.notthere
2$
 ifeq 1
	move.l	d4,d1
	CALLIB	DOS,Close
 endc
	move.b	#0,FilenameBuffer_(a5)
bigdeal1
	movem.l	(sp)+,d0-d5/a0-a3/a6
	rts

MakeBrushFromBitmap
	lea	TextStringBuffer_(BP),A0	;A0=ascii string ptr

	move.l	A0,a2	;dupl text ptr	;build D0=len of string, using a2
	moveq	#-1,D0	;text len
	moveq	#80,d1	;maxlen(?)
lencloop:
	addq.L	#1,D0
	tst.b	(a2)+
	dbeq	d1,lencloop
	tst.b	D0		;D0=len
	beq	notext		;outta here if no string...

	movem.l	D0/A0,-(sp)		;len, ptr
	xjsr	EndCutPaste
	xjsr	ClearBrushMask		;clear out whole screen mask
	xjsr	ReallySaveUnDo		;memories.o (only copies if needed) AUG261990
	xjsr	SaveUnDoRGB		;june271990.....helps w/brush rgb colors

	xjsr	GraphicsWaitBlit	;wait for clear to happen
	movem.l	(sp)+,D0/A0		;D0=len, A0=ptr

	lea	TextMask_RP_(BP),a1	;a1=rastport

	MOVEM.L	D0/A0/a1,-(sp)	;STACK string ptr, len, rp
	BSR	SetFontAndStyle		;"my" subr
	bsr	ResetGadStyles
nodf:
	movem.l	(sp),D0/A0/a1		;deSTACK d0=nchars
	CALLIB	Graphics,TextLength	;result D0=width in pixels needed
	move.l	D0,d2			;d2=width


		;MAY14...system BUG: softstyle-italic not acctd in width

		;ITALIC?
	tst.l	DiskFont_(BP)
	beq.s	nowidth_adj

	move.l	#'Tbit',d0
	moveM.l	d2,-(sp)	;save temp width
	bsr	_FindGadget ;tool.o;arg D0=action code, rtns gadget in a0 AND d0, zero valid
	moveM.l	(sp)+,d2	;restore temp width, moveM doesnt blow flag
	beq.s	nowidth_adj
	move.w	#SELECTED,d1
	and.w	gg_Flags(a0),d1
	beq.s	nowidth_adj	;not selected, so's not italic

	move.l	DiskFont_(BP),a1	;it's valid, checked for ~5lines ago
	add.w	tf_XSize(a1),d2
nowidth_adj:

	;SUBQ.W	#3,d2			;JUNE02...width clup, start on pix#3
	ADDQ.W	#3,d2			;JUNE02...width clup, start on pix#3
	cmp.w	BigPicWt_W_(BP),d2	;picture/max size?
	bcs.s	2$			;ok, maxsize>this width
	subq.L	#1,(sp)	;stacked width	;decrement #characters
	beq.s	1$			;error? (#chars =zero?)
	movem.l	(sp),D0/A0 ;/a1		;deSTACK d0=nchars, a0=stringptr
	clr.b	0(a0,d0.l)		;set null at string end, re-terminate
	st	FlagNeedGadRef_(BP)	;show user what happened (redo gadgets)
		;june
	XREF TextStringInfo	;tool.stru.i,buffer in code space YUCKO! JUNE89
	lea	TextStringInfo,a0
	clr.w	12(a0)		;si_DispPos, 1st char displayed in str gadget
	bra.s	nodf			;try width func again with fewer chars
1$	move.l	#1,(sp)			;err....reset#chars
2$	movem.l	(sp)+,D0/A0/a1	;deSTACK d0=nchars, a0=strptr, a1=rport

	movem.l	D0/d2/A0/a1,-(sp)	;STACK nchars,npixels,ascii,rport

	move.l	rp_Font(a1),D0	;any font ptr?
	bne.s	sizeff		;size from font
	moveq	#10,d1
	bra.s	gotht
sizeff	move.l	D0,A0		;font
	moveq	#0,d1
	move.w	tf_YSize(A0),d1
gotht	;d1=bottom edge for text
	;moveq	#2,D0			;x, leftedge for text;JUNE02
	moveq	#3,D0			;x, leftedge for text
	;moveq	#4,D0			;x, leftedge for text;JUNE02

	move.l	d1,-(sp)		;bottomedge, ht of textfont
	moveq	#0,d1
	move.W	tf_Baseline(a0),d1	;bottomedge, BASELINE FOR TEXT
	CALLIB	Graphics,Move
	move.l	(sp)+,d3		;bottomedge
	movem.l	(sp),D0/d2/A0/a1	;nchars,npixels,rport,text=A0=notneed

	moveq	#0,d0		;leftedge (d2=r-edge=npixels,d3=b-right y)
	moveq	#0,d1		;topedge
	addq.w	#3,d2		;rightedge over, allows 3ham leftedge sup pixels
	CALLIB	SAME,RectFill

		;STACK/SAVE all "modes"...set up for "normal/minimal"
	move.b	FlagRub_(BP),d0
	sf	FlagRub_(BP)		;prevents repaint from "rubthru"
	move.b	FlagFlood_(BP),d1
	sf	FlagFlood_(BP)		;prevents repaint from flooding
	ASL.W	#8,d1			;digipaint pi...save new fill flag
	move.b	FlagFillMode_(BP),d1
	sf	FlagFillMode_(BP)
	move.B	EffectNumber_(BP),d2	;stack/save effect number

		;SEP111990...range paint is an effect....let it be...
	cmp.b	#7,EffectNumber_(BP)
	beq.s	011$
	clr.B	EffectNumber_(BP)	;'no effect' while painting brush
011$
	move.b	FlagStretch_(BP),d3
	sf	FlagStretch_(BP)
	movem.W	d0/d1/d2/d3,-(sp)	;STACK FLAGS

		;SEP111990...stack paint mode, too
	xref PaintNumber_
	move.b	PaintNumber_(BP),d0
	move.w	d0,-(sp)
	move.b	#7,PaintNumber_(BP)

	st	FlagText_(BP)		;SIGNALS 'repaint' for MAX blend
	xjsr	RePaint_Picture	;scratch.o ;'digipaint' the rectangle

		;SEP111990...de-stacking paint number, too
	move.w	(sp)+,d0
	move.B	d0,PaintNumber_(BP)

	movem.w	(sp)+,d0/d1/d2/d3	;DESTACK FLAGS
	move.B	d0,FlagRub_(BP)
	move.b	d1,FlagFillMode_(BP)
	ASR.W	#8,d1			;digipaint pi
	move.B	d1,FlagFlood_(BP)
	move.B	d2,EffectNumber_(BP)
	move.B	d3,FlagStretch_(BP)

	xjsr	ClearBrushMask		;clear out whole screen mask
	st	FlagBitMapSaved_(BP)	;want an undo

	movem.l	(sp)+,D0/d2/A0/a1	;STACK nchars,npixels,ascii,rport
debugtext:
	CALLIB	Graphics,Text
debugtextresult:
	xjsr	GraphicsWaitBlit	;wait for text->drawing mask
	st	FlagText_(BP)		;SIGNALS 'cut' for no flooding
	xjsr	CheckCancel	;july05...cancel'd while 'repainting' for brush?
	bne.s	skipcut		;yep,...continue with 'undo' of rectangle

	xjsr	CutLoadedBrush		;cutpaste.o AUG271990
	tst.l	PasteBitMap_Planes_(BP)	;AUG271990
	beq.s	987$
	xjsr	UnDo		;AUG271990
	xjsr	UnDoRGB		;on mo' time....AUG271990

987$:

skipcut:	;july05
	sf	FlagText_(BP)		;done cutting text, reset flag

	xref PasteBitMap_Planes_
	tst.l	PasteBitMap_Planes_(BP)	;may11'89
	bne.s	7$
	xjsr	UnDo	;removes 'block' from scr if no cut done..
	bra.s	notext
7$
	xref FlagAAlias_
	tst.b	FlagAAlias_(BP)
	beq.s	notext			;skip mask shrink rtn
	bsr.s	HiToLoMask ;compress brush mask by 'combining' words->bytes
notext:
	rts




HiLoWordByte: MACRO ;DEST,SRC,tmp,tmp,tmp
	moveq	#8-1,\3	;loop counter	(COULD un-roll)
hl\@:	rol.w	#1,\2	;source bit, set/clear carrybit
	scs	\4
	rol.w	#1,\2	;rotate source, again, 2nd bit to combine
	scs	\5
	or.b	\4,\5
	roXR.b	#1,\5	;result of 'or' in carry, now
	;roXL.b	#1,\1	;DEST bit set if either source bits set
	addx.b	\1,\1	;DEST bit set if either source bits set (equiv to roxl #1,...)
	dbf	\3,hl\@
	ENDM



HiToLoMask:	;compress brush mask by 'combining' words->bytes
	xjsr	AllocLoBrushMask	;memories.o
	beq.s	ea_hitolo		;no more chip? no can do?

	xref paste_offsetx_
	asr.w	paste_offsetx_(BP)	;leftside offset for brush display

	xref PasteBitMap_
	lea	PasteBitMap_(BP),a0	;custom/cutout brush bitmap
	move.L	bm_Planes+(8*4)(a0),a1	;mask (a1 "from")
	move.l	a1,a2			;mask (a2 "to")
	move.w	(a0),d5			;bytes per row
	asr.w	#1,d5			;d5=WORDS per row
	move.w	bm_Rows(a0),d6
	subq	#1,d6
shrink_row:

	move.w	d5,d7		;#words in row
	subq	#1,d7		;db' type loop
shrink_byte:
	move.w	(a1)+,d0	;source WORD (to shrink to byte)
	HiLoWordByte d1,d0,d2,d3,d4 ;d1=dest, d0=source, d2/3/4 temp
	move.B	d1,(a2)+
	dbf	d7,shrink_byte

	move.w	d5,d7		;#words in row
	subq	#1,d7		;db' type loop
clear_byte:			;this loops clears the 'right half' of mask
	clr.b	(a2)+
	dbf	d7,clear_byte

	dbf	d6,shrink_row
ea_hitolo:
	rts




SetFontAndStyle:			;"my" subr
	;may12;xjsr	InitBitPlanes		;MAY11(late eve...sup textm_rport)

	lea	TextMask_RP_(BP),a1	;a1=rastport
	move.l	TextFont_(BP),d0	;any diskfont around?
	beq.s	no2df
	move.l	d0,a0
	CALLIB	Graphics,SetFont
no2df:

	;move.l	(3*4)(sp),a1	;rport
	lea	TextMask_RP_(BP),a1	;a1=rastport
	CALLIB	Graphics,AskSoftStyle	;returns d0=mask
	;move.l	(3*4)(sp),a1	;rport
	lea	TextMask_RP_(BP),a1	;a1=rastport
	moveq	#0,d1		;d1=enable mask (italic TEST)
				;d0=valid types, d1=mask, a1=rport

		;BOLD?
	movem.l	d0/d1/a1,-(sp)	;d0=valid types, d1=mask, a1=rport
	move.l	#'Tbbo',d0
	bsr	_FindGadget ;tool.o;arg D0=action code, rtns gadget in a0 AND d0, zero valid
	movem.l	(sp)+,d0/d1/a1
	beq.s	nobold
	move.w	#SELECTED,d2	;d2=tempjunk
	and.w	gg_Flags(a0),d2
	beq.s	nobold
	or.b	#2,d1		;d1=enable mask
nobold:
		;UNDERLINE?
	movem.l	d0/d1/a1,-(sp)	;d0=valid types, d1=mask, a1=rport
	move.l	#'Tbun',d0
	bsr	_FindGadget ;tool.o;arg D0=action code, rtns gadget in a0 AND d0, zero valid
	movem.l	(sp)+,d0/d1/a1
	beq.s	nounderl
	move.w	#SELECTED,d2	;d2=tempjunk
	and.w	gg_Flags(a0),d2
	beq.s	nounderl
	or.b	#1,d1		;d1=enable mask (italic TEST)
nounderl:
		;ITALIC?
	movem.l	d0/d1/a1,-(sp)	;d0=valid types, d1=mask, a1=rport
	move.l	DiskFont_(BP),d0
	beq.s	8$		;nofont
	move.l	d0,a1
	move.w	tf_YSize(a1),d0
	;JULY05;cmp.w	#36,d0				;NO ITALICS IF HIGHER THAN 35
	cmp.w	#(28+1),d0				;NO ITALICS IF HIGHER THAN 35
	bcs.s	8$		;shorter than 36...go useit
	movem.l	(sp)+,d0/d1/a1
	bra.s	noitalic
8$
	move.l	#'Tbit',d0
	bsr	_FindGadget ;tool.o;arg D0=action code, rtns gadget in a0 AND d0, zero valid
	movem.l	(sp)+,d0/d1/a1
	beq.s	noitalic
	move.w	#SELECTED,d2	;d2=tempjunk
	and.w	gg_Flags(a0),d2
	beq.s	noitalic
	or.b	#4,d1		;d1=enable mask (italic TEST)
noitalic:

	;exg.l	d0,d1	;MAY10'89...now d0=desired, d1=avail (from asksoftstyle)
	move.l	d1,d0	;force only desired enable/avail bits...
	move.l	#$0ff,d1	;set all these little bits
debugsoft:
	move.w	d0,-(sp)	;"my" style bits
	CALLIB	Graphics,SetSoftStyle	;returns d0=newstyle
	move.w	(sp)+,d0
debugsoftresult:
;KLUDGE?;	bsr	ResetGadStyles
		;MAY13....sup TextAtr so's resetgadst knows what to do
	lea	TextAttr_(BP),a0	; STRUCTURE  TextAttr,0
	move.b	d0,ta_Style(a0)		;UBYTE    ta_Style


	RTS	;SetFontAndStyle




 xdef ResetGadStyles	;ref' in GadgetRtns
ResetGadStyles:	;change text buttons selected based on d0=newstyle

	;;;BSR	SetFontAndStyle		;"my" subr...MAY12

			;may10'89
	;lea	TextMask_RP_(BP),a1	;a1=rastport
	;CALLIB	Graphics,AskSoftStyle	;returns d0=mask

	lea	TextAttr_(BP),a0	; STRUCTURE  TextAttr,0
	moveq	#0,d0			;not needed?
	move.b	ta_Style(a0),d0		;current style sup

	move.W	d0,-(sp)		;STACK newstyle

		;ITALIC?
				;NO ITALICS IF HIGHER THAN 35
	move.l	DiskFont_(BP),d0
	beq.s	xnoitalic	;no font....no change gads...8$		;nofont
	move.l	d0,a1
	move.w	tf_YSize(a1),d0
	;JULY05;cmp.w	#36,d0
	cmp.w	#(28+1),d0				;NO ITALICS IF HIGHER THAN 35
	bcs.s	xnoitalic	;size ok...no fudge gadget;8$		;shorter than 36...go useit
	;moveq	#0,d0		;force ZERO flag
	bclr.b	#2,1(sp)	;clear out italic bit
	;bra.s	9$
8$
	move.l	#'Tbit',d0
	bsr.s	_FindGadget ;tool.o;arg D0=action code, rtns gadget in a0 AND d0, zero valid
9$	beq.s	xnoitalic
	moveq	#2,d1		;italic bit
	bsr.s	resetgad
xnoitalic:

	addq.L	#2,sp	;remove "newstyle" from stack
	RTS	;resetgadstyles

resetgad:
	btst.b	d1,(1+4)(sp)	;stacked d0 + return adr
	beq.s	clrselected

	move.w	gg_Flags(a0),d1
	or.w	#SELECTED,d1
	cmp.w	gg_Flags(a0),d1
	beq.s	9$
	st	FlagNeedGadRef_(BP)	;signal for main loop gadget redisplay
	move.w	d1,gg_Flags(a0)
9$	rts

clrselected:
	move.w	#~SELECTED,d1
	and.w	gg_Flags(a0),d1
	cmp.w	gg_Flags(a0),d1
	beq.s	9$
	st	FlagNeedGadRef_(BP)	;signal for main loop gadget redisplay
	move.w	d1,gg_Flags(a0)
9$	rts

_FindGadget:
	xjmp	FindGadget


TestFontType
	movem.l	d0-d1/a0-a1,-(sp)
	lea	FilenameBuffer_(BP),a0
	bsr	CheckForPostScript
	tst.l	d0
	seq	PostScriptFont_(a5)

	tst.b	PostScriptFont_(a5)
	bne	.ok

	bsr	CheckForPostScript2
	tst.l	d0
	seq	PostScriptFont_(a5)

	




.ok
;;	move.b	#1,PostScriptFont_(a5)
	movem.l	(sp)+,d0-d1/a0-a1
	rts


*****************************************************************************

SearchLength	equ	100		;must be < 128

CheckForPostScript:	;(filename)
			;    a0
	movem.l	d1-d5/a0-a1/a6,-(sp)
	moveq.l	#-1,d4			;error code

	lea 	-SearchLength(sp),sp

	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	CALLIB	DOS,Open
	move.l	d0,d5
	beq.s	.abort


	move.l	d0,d1		;file handle
	move.l	sp,d2		;buffer
	moveq.l	#SearchLength,d3		;length
	CALLIB	SAME,Read
	cmp.l	d0,d3
	bne.s	.errorclose

	move.l	sp,a0
	move.l	#SearchLength-(psstringe-psstring),d1
2$	move.l	a0,a2
	lea	psstring,a1
	move.l	#(psstringe-psstring)-1,d0
1$	cmp.b	(a2)+,(a1)+
	dbne	d0,1$
	beq.s	.gotmatch
	addq.l	#1,a0
	dbf	d1,2$
	bra.s	.errorclose			;no match was found
.gotmatch
	moveq.l	#0,d4

.errorclose
	move.l	d5,d1
	CALLIB	SAME,Close
.abort
	lea 	SearchLength(sp),sp
	move.l	d4,d0
	movem.l	(sp)+,d1-d5/a0-a1/a6
	move.l	d0,d0				;set z flag
	rts



CheckForPostScript2	;(filename)
			;    a0
	movem.l	d1-d5/a0-a1/a6,-(sp)
	moveq.l	#-1,d4			;error code

	lea 	-SearchLength(sp),sp

	move.l	a0,d1
	move.l	#MODE_OLDFILE,d2
	CALLIB	DOS,Open
	move.l	d0,d5
	beq.s	.abort2


	move.l	d0,d1		;file handle
	move.l	sp,d2		;buffer
	moveq.l	#SearchLength,d3		;length
	CALLIB	SAME,Read
	cmp.l	d0,d3
	bne.s	.errorclose2

	move.l	sp,a0
	move.l	#SearchLength-(psstringe2-psstring2),d1
2$	move.l	a0,a2
	lea	psstring2,a1
	move.l	#(psstringe2-psstring2)-1,d0
1$	cmp.b	(a2)+,(a1)+
	dbne	d0,1$
	beq.s	.gotmatch2
	addq.l	#1,a0
	dbf	d1,2$
	bra.s	.errorclose2			;no match was found
.gotmatch2
	moveq.l	#0,d4

.errorclose2
	move.l	d5,d1
	CALLIB	SAME,Close
.abort2
	lea 	SearchLength(sp),sp
	move.l	d4,d0
	movem.l	(sp)+,d1-d5/a0-a1/a6
	move.l	d0,d0				;set z flag
	rts


BuildPath
	movem.l	d0-d2/a0-a1/a6,-(sp)

	lea	SavePathBuffer,a0
	move.l	a0,d1
	move.l	#100,d2		;length
;;	CALLIB	DOS,GetCurrentDirName

	move.l	#200,d0		;length
	lea	SavePathBuffer,a0
	bsr	GetCurrentPath


;;	lea	SavePathBuffer,a1
;;	lea	Kludgepath,a0
;;	bsr	AddString


	lea	SavePathBuffer,a1
1$	tst.b	(a1)+
	bne.s	1$

	subq.l	#1,a1

	move.b	#'/',(a1)+
	lea	FilenameBuffer_(BP),a0
	bsr	AddString

	movem.l	(sp)+,d0-d2/a0-a1/a6
	rts


BuildCommand:
	movem.l	d0-d4/a0-a6,-(sp)
	lea	CommandBuffer,a1
*
	lea	CodeName,a0
	bsr	AddString
*
	lea	TextStringBuffer_(BP),a0	
	cmp.b	#' ',(a0)			;check for a blank in the first char	 
	bne	101$				;if there is, ignore it and put a b for blank!
	move.b	#' ',(a0)			;dont try to make empty brushes!!!!
101$	
	tst.b	(a0)				;check for a blank in the first char	 
	bne	108$				;if there is, ignore it and put a b for blank!
	move.b	#' ',(a0)			;dont try to make empty brushes!!!!
108$	

	bsr	AddString
*
	lea	EndQuote,a0
	bsr	AddString
*
	lea	SavePathBuffer,a0
	bsr	AddString
*	
	bsr	AddSizePram			;pass a1 outstring
*
	lea	EndStuff,a0
	bsr	AddString
*	
	bsr	AddStrechPram
*
	bsr	AddSkewPram
*
	bsr	AddRotatePram
*
	bsr	AddFladsPram
*
	move.l	#0,(a1)
	movem.l	(sp)+,d0-d4/a0-a6
	rts

AddSizePram:
Factor  set     32
	movem.l	d0-d4/a2-a5,-(sp)
	moveq	#0,d1	
	move.w	MSPot7,d1
	divu	#Factor,d1
	and.l	#$0000ffff,d1		
;	DUMPREG	<D1 = SIZE>	
*	move.w	#100,d1
	lea	workstr,a0	
	bsr	TS_ASC_Con
*
	lea	workstr,a0	
	bsr	AddString
	movem.l	(sp)+,d0-d4/a2-a5
	rts


AddStrechPram:
	movem.l	d0-d4/a2-a5,-(sp)
	moveq	#0,d1
	move.w	MSPot9,d1
	
	add.w	#16384,d1
	cmp.w	#16384,d1
	bcc	555$
	move.w	#16384,d0
	sub.w	d1,d0
	move.w	d0,d1	
	
555$
;	DUMPREG	<D1 = STRECH>	
*	move.w	#0,d1
	lea	workstr,a0	
	bsr	TS_ASC_Con
*
	lea	workstr,a0	
	bsr	AddString
	movem.l	(sp)+,d0-d4/a2-a5
	rts

AddSkewPram:
	movem.l	d0-d4/a2-a5,-(sp)
	move.w	MSPot8,d1
;	DUMPREG	<D1 = SKEW>
*	move.w	#0,d1
	lea	workstr,a0	
	bsr	TS_ASC_Con
*
	lea	workstr,a0	
	bsr	AddString
	movem.l	(sp)+,d0-d4/a2-a5
	rts

AddRotatePram:
	movem.l	d0-d4/a2-a5,-(sp)
	move.w	MSPot0A,d1

;	DUMPREG	<D1 = ROT>	
*	move.w	#0,d1
	lea	workstr,a0	
	bsr	TS_ASC_Con
*
	lea	workstr,a0	
	bsr	AddString
	movem.l	(sp)+,d0-d4/a2-a5
	rts


AddFladsPram:
	movem.l	d0-d4/a2-a5,-(sp)
	lea	TOutlinePSGadget,a0
	btst.b	#7,1+gg_Flags(a0)
	beq.s	NOOUTLINE
;	DUMPMSG	<OUTLINE IS ON>
	lea	outline_str,a0	
	bsr	AddString
NOOUTLINE:
	movem.l	(sp)+,d0-d4/a2-a5
	rts


;;PSText <Text> <font> <size> <file> [<stretch> <skew °> <rotate> <outline/S>]

;****** NC/TS_ASC_Con *****************************************
;
;   NAME
;	TS_ASC_Con -- Converts number to SH_ASCii string of digits.
;		
;   SYNOPSIS
;	string = SH_ASC_Con( number,deststring)
;	A0		     D1	    A0
;
;   FUNCTION
;	Converts word length number to null termanated string.
;
;   INPUTS
;	number		-  value equal to a four(or less) digit number.
;	deststring	-  pointer to a work space of a least 5 bytes. 
;
;   RESULT
;	string 		- non-null termanated SH_ASCii string.  	
;
;   EXAMPLE
;
;   NOTES
;	Distroys what was at address in A0
;	Doesn't check for overflow of number to convert. 		
;
;   BUGS
;	
;   SEE ALSO
;
;****************************************************************************
	XDEF	TS_ASC_Con
TS_ASC_Con:
	MOVEM.L	D0-D2/A0-A1,-(SP) 
	move.b	#' ',(a0)+	*leading space

	moveq	#0,d2
	AND.L	#$0000FFFF,D1	*Clear the hi-word remainder! 
*
	DIVU	#10000,D1	*Get place
	or.b	d1,d2	
	tst.w	d2
	beq	400$	
	ADD.B	#$30,D1		* Move to ASCII $ number
	MOVE.B	D1,(A0)+	* Pace in string
400$
	CLR.W	D1		* Clear out Quiotiont
	SWAP	D1		* Move remander to low word
*
	DIVU	#1000,D1	*Get place
	or.b	d1,d2
	tst.w	d2
	beq	500$	
	ADD.B	#$30,D1		* Move to ASCII $ number
	MOVE.B	D1,(A0)+	* Pace in string
500$
	CLR.W	D1		* Clear out Quiotiont
	SWAP	D1		* Move remander to low word
*
	DIVU	#100,D1		*Get place
	or.b	d1,d2
	tst.w	d2
	beq	600$
	ADD.B	#$30,D1		* Move to ASCII $ number
	MOVE.B	D1,(A0)+	* Pace in string
600$
	CLR.W	D1		* Clear out Quiotiont
	SWAP	D1		* Move remander to low word
*
	DIVU	#10,D1		*Get place
	or.b	d1,d2
	tst.w	d2
	beq	700$
	ADD.B	#$30,D1		* Move to ASCII $ number
	MOVE.B	D1,(A0)+	* Pace in string
700$
	CLR.W	D1		* Clear out Quiotiont
	SWAP	D1		* Move remander to low word
*
	ADD.B	#$30,D1		* Move to ASCII $ number
	MOVE.B	D1,(A0)+	* Pace in string

*	MOVE.B	#' ',(A0)+	* TRAILING SPACE

	MOVE.B	#$0,(A0)+	* Place null on end of string.
	MOVEM.L	(SP)+,D0-D2/A0-A1
	RTS




skewRange	equ	150
stretchRange	equ	20
 ifeq 1	
BuildCommand
	movem.l	d0-d1/a0-a3,-(sp)
	lea	CommandBuffer,a1

	lea	CodeName,a0
	bsr	AddString
	lea	TextStringBuffer_(BP),a0
	bsr	AddString
	lea	EndQuote,a0
	bsr	AddString
;;	lea	FilenameBuffer_(BP),a0
	lea	SavePathBuffer,a0
	bsr	AddString


	moveq.l	#0,d0
;	move.w	StdPot7,d0
;	divu.w	#$ffff/(400-10),d0
*****	move.l  SizeTextGadgetLI,d0 		;get size from int gad	
	bsr	Long2Word
	cmp.w	#10,d0
	bhi	305$				;skip if size is ok.			
;	add.w	#10,d0				;min size
	move.w	#10,d0				;min sixe
305$
	move.b	#' ',(a1)+
	bsr	InsertAscii

	lea	EndStuff,a0
	bsr	AddString


****	xref	StBuffStr
	move.b	#' ',(a1)+
*	lea	StBuffStr,a0
202$	move.b	(a0)+,(a1)+
	bne	202$
	lea	-1(a1),a1	

 ifeq 1
	move.b	#' ',(a1)+
	move.b	#'-',(a1)+
	move.b	#'.',(a1)+
	move.b	#'5',(a1)+
	move.b	#'5',(a1)+
	move.b	#'5',(a1)+
	move.b	#'5',(a1)+
	move.b	#'5',(a1)+
 endc
 ifeq 1
;stretch
	moveq.l	#0,d0
******	move.l	StrTextGadgetLI,d0		;get value from int gad
;	bsr	Long2Word

55$
	move.b	#' ',(a1)+
	bsr	InsertAsciifrac
 endc

	moveq.l	#0,d0
;	move.w	StdPotA,d0
******	move.l	SheTextGadgetLI,d0	
	bsr	Long2Word

;	divu.w	#$ffff/(skewRange),d0
;	sub.w	#(skewRange/2),d0
	move.b	#' ',(a1)+
	bsr	InsertAscii


	moveq.l	#0,d0
;	move.w	StdPot9,d0
******	move.l	RotTextGadgetLI,d0
	bsr	Long2Word

	cmp.l	#360,d0
	ble	307$
	move.l	#360,d0
307$

;	divu.w	#$ffff/(360),d0
	move.b	#' ',(a1)+
	bsr	InsertAscii	;rotate


	lea	TOutlinePSGadget,a0
	btst.b	#7,1+gg_Flags(a0)
	beq.s	3$
	move.b	#' ',(a1)+
	move.b	#'1',(a1)+
	clr.b	(a1)+
3$
	movem.l	(sp)+,d0-d1/a0-a3
	rts
 endc

Long2Word:
	tst.l	d0
	bpl	1$
	neg.l	d0
	neg.w	d0
1$	rts	


AddString
	movem.l	a0,-(sp)
1$	move.b	(a0)+,(a1)+
	bne.s	1$
	movem.l	(sp)+,a0
	subq.l	#1,a1		;backup to null
	rts

InsertAsciifrac
	move	d0,d1
;	divu	#100,d1
	moveq.l	#0,d0
	move.w	d1,d0
	bsr	InsertAscii
	move.b	#'.',(a1)+
	swap.w	d1
	move.w	d1,d0
	mulu.w	#100,d0
	bsr	InsertAscii
	rts
	




InsertAscii
	movem.l	d0-d3/a0,-(sp)

	tst.w	d0
	bpl.s	1$
	neg.w	d0
	move.b	#'-',(a1)+
1$

	lea	3(a1),a1
	moveq.l	#3-1,d3
2$	ext.l	d0
	divu.w	#10,d0
	move.l	d0,d1
	swap.w	d1
	add.b	#'0',d1
	move.b	d1,-(a1)
	dbf	d3,2$
	lea	3(a1),a1
	clr.b	(a1)

	movem.l	(sp)+,d0-d3/a0
	rts

*****************************************************************************
*	This function fills in a buffer with the current path
*****************************************************************************
GetCurrentPath:	;(buffer,buffersize)
		;  a0       d0

	movem.l	d0-d4/a0-a4,-(sp)
	move.l	sp,a2

	sub.w	#fib_SIZEOF,sp	;allocate long word alligned fib on
	move.l	sp,d1			;stack
	and.b	#-4,d1
	move.l	d1,sp

	move.l	a0,a3			;This where to put result
	move.l	a0,a4
	add.l	d0,a4			;build workregister starting at end
	move.b	#0,-(a4)		;of buffer
	move.b	#0,-(a4)

	move.l	4,a6
	sub.l	a1,a1
	CALLIB	Exec,FindTask
	move.l	d0,a0

	move.l	pr_CurrentDir(a0),d1
	CALLIB	DOS,DupLock
	move.l	d0,d4
	beq.s	5$			;error exit
	bra.s	888$

999$	cmp.l	a4,a3
	bcc.s	5$			;error exit
	move.b	#'/',-(a4)
888$	move.l	d4,d1
	move.l	sp,a0			;fib on stack
	move.l	a0,d2
	CALLIB	SAME,Examine
	tst.l	d0
	beq.s	5$

	move.l	d4,d1
	CALLIB	SAME,ParentDir

	move.l	d4,d1
	move.l	d0,d4
	CALLIB	SAME,UnLock

	tst.l	d4
	bne.s	3$
	move.b	#':',(a4)
3$
	lea	fib_FileName(sp),a0	;fib is on stack
	bsr	StLen
	sub.l	d0,a4
	cmp.l	a4,a3
	bcc.s	5$			;error exit

	move.l	a4,a1
	bra.s	2$
1$	move.b	(a0)+,(a1)+
2$	dbf	d0,1$

	tst.l	d4
	bne.s	999$

	move.l	a3,(a2)			;setup error return

4$	move.b	(a4)+,(a3)+		;move new string to front of buffer
	bne.s	4$

5$	move.l	a2,sp
	movem.l	(sp)+,d0-d4/a0-a4
	rts
StLen
	move.l	a0,-(sp)
	moveq.l	#-1,d0
1$	addq.l	#1,d0
	tst.b	(a0)+
	bne.s	1$
	move.l	(sp)+,a0
	rts


psstring	dc.b	'!PS-AdobeFont'
psstringe


psstring2	dc.b	'!FontType1'
psstringe2



SampleTextAtt	dc.l	n1
		dc.w	100
		dc.b	0,FPF_DISKFONT
n1		dc.b	'CGTimes.font',0


constring	dc.b	'nil:',0
;;exstring	dc.b	'C:PSText >nil: "Test" newwork:toaster/exe/toaster/toasterfonts/FontBankH-M/Henning'
;;		dc.b	' 100 ram:x100 1 0 75',0

workstr		dc.b	' 100',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


*CodeName	dc.b	'C:PSText >nil: "',0
CodeName	dc.b	'C:PSText "',0
EndQuote	dc.b	'" ',0
EndStuff	dc.b	' ram:x100',0

;;RFPath		dc.b	'ram:',0
;;RFName		dc.b	'x100',0

RFName		dc.b	'ram:x100',0
outline_str	dc.b	' OUTLINE',0




;;Kludgepath	dc.b	'newwork:toaster/exe/toaster/toasterfonts/FontBankH-M',0

SavePathBuffer	ds.b	200
CommandBuffer	ds.b	500

  END
