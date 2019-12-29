* Memories.asm 

		;july01
min_chip	set	10*1024 ;12*1024
toolreq		set	(40*42*6)+(4*1024)
chipreq		set	min_chip+toolreq

BIGMAXBUFFER	set (63*1024)
MAXBUFFER	set BIGMAXBUFFER ;ok...code works with big buffer
;BIGEXTRA	set 10*1024	 ;wants this much extra b4 hamtools display
;BIGEXTRA	set 13*1024	 ;wants this much extra b4 hamtools display MAY19
BIGEXTRA	set min_chip ;toolreq ;july01;(11*1024)+512  ;wants this much extra b4 hamtools display JUNE16 (10+13)/2 Kbytes

MINBUFF		set 100	;100 bytes, minimum file buffer

	include "ds:basestuff.i"
	include "exec/types.i"
	include	"exec/memory.i" ;needed for AllocMem/AllocRemeber requirements
	include "graphics/gfx.i"	;bitmap struct

	xdef AllocAreaStuff,FreeAreaStuff
	xdef AllocCPUnDo,FreeCPUnDo
	xdef AllocDouble,FreeDouble
	xdef AllocLoBrushMask	;allocs/copies LoResMask_ bitplane
	;june20;xdef AllocBrushMaskClone	;alloc/creates clone of brush mask, returns in d0 and a0
	xdef AllocPasteMaskClone	;copy of brush mask bitplane (rtn'd in d0/a0)
	xdef AllocDetermineTable
	xdef AllocPaste,FreePaste
	xdef AllocSwap,FreeSwap
	xdef AllocUnDo,FreeUnDo
		;AltPasteChip, AltPasteFast
	xdef CleanupMemory	;clears out unused drivers, etc.
	xdef CopyPic		;copies ScreenBitMap to SwapBitMap (rubthru/swap)
	xdef CopySuperDouble	;copy UnDoBitMap to Doublebitmap
	xdef CopySuperScreen	;copy UnDoBitMap to Screenbitmap
	xdef CopyScreenSuper	;copy Screen->superbitmap (filertns, only)
	xdef DoubleUndo		;d5=#bytes to copy, d1=offset to first line
	xdef EnsureExtraChip	;march22'89, alloc/de-alloc, flag rtn
	xdef FreeAllMemory	;frees all memories.o managed memory (abort/end)
	xdef FreeLoResMask	;remove 'anti-alias' mask (textstuff.o ref')
	xdef FreeOneRemember	;call with d0=ptr to memory
	xdef FreeOneVariable	;call with a0=ptr to variable
	xdef GlueChip
	xdef GrabBigFileBuffer	;BIGmaxbuffer
;july01;	xdef GrabExtraChip	;used by main.o OpenBigPic to grab some chipmem
	xdef GrabFileBuffer	;does an alloc' if needed; iffload.o
	xdef GrabLoadPlane0	;does an alloc' if needed; iffload.o
	xdef GraphicsWaitBlit
	xdef IndicatedUndo	;d1=first y line, d5=#lines
	xdef IndSingleUndo	;d1=first y line, d5=#lines single bitplane
	xdef InitShortMulTable
	xdef IntuitionAllocAnyCleared 	;alloc any type, but cleared fer sure
	xdef IntuitionAllocChip	;used in main.o for bitmaps
	xdef IntuitionAllocMain
	;;xdef IntuitionFreeRemember	;main.o, at end, when really done.
	xdef MarkedUnDo			;used by special drawmodes for quick undo
	xdef MergeCut			;sets mask, rubthru, calls repaint
	xdef PartialUnDo		;copy UnDoBitMap  to screenbitmap
	xdef QUICKCopy		;d0=count, a0/a1 = addresses
	xdef QUICKSwap		;d0=count, a0/a1 = addresses
	xdef RestoreCPUnDo ;xdef CopyCPUnDoSuper ;copy cpundo to UnDoBitMap
	xdef SaveCPUnDo
	xdef SaveUnDo
	xdef SetEntireScreenMask
	xdef SwapSwap			;alternate/rubthru screen swap
	xdef UnDo 

	xdef SwapAltPaste
	xdef FreeAltPaste

	xref AltPasteBitMap_		;other, 'swap' brush
	xref AltPasteBitMap_Planes_	;other, 'swap' brush

	xref BB_BitMap_	;'regular' brush (whole picture size)
	xref BB1Ptr_
	xref BigPicHt_		;#rows in a std screen/bitmap
	xref BigPicWt_		;#pixels in a std row   (lword)
	xref BriteTablePtr_
	xref BufferLen_		;iffload.o
	xref bytes_per_row_		;#bytes in a std row   (lword)
	xref CPUnDoBitMap_		;cut/paste undo
	xref CPUnDoBitMap_Planes_	;cut/paste undo
	xref SwapBitMap_
	xref SwapBitMap_Planes_	;alternate/swap screen
	xref DetermineTablePtr_
	xref DoubleBitMap_
	xref DoubleBitMap_Planes_
	xref ExtraChipPtr_
	xref FileBufferPtr_	;iffload.o
	xref FlagBitMapSaved_	;byte =-1 if UnDoBitMap saved but not restored
	xref FlagCDet_		;"really" need create determine?
	xref FlagCloseWB_
	xref FlagCutPaste_	;cutpaste mode on?
	xref FlagDisplayBeep_
	xref FlagNeedGadRef_
	xref FlagNeedMagnify_
	xref FlagNeedShowPaste_
	xref FlagQuit_
	xref FlagReSee_
	xref FlagRub_
	xref LoadPlane0Ptr_	 ;SLong
	xref LoadPlanesLen_	 ;SLong len of ALL
	xref LoadPlane_pixels_	 ;SWordhow many pixels we can handle (or want?)
	xref LoResMask_
	xref PasteBitMap_		;brush image
	xref PasteBitMap_Planes_	;brush image
	xref paste_height_		;#rows in PasteBitMap
	xref paste_width_		;#cols in PasteBitMap
	xref paste_leftblank_	;#pixels before 1st masked pixel in a brush
	xref paste_offsetx_
	xref paste_offsety_
	xref altpaste_leftblank_	;#pixels before 1st masked pixel in a brush
	xref altpaste_offsetx_
	xref altpaste_offsety_
	xref altpaste_width_
	xref altpaste_height_
	xref PlaneSize_			;#bytes in a std plane (lword)
	xref PMBM_Planes_		;Paste Mask Bit Map _Plane adr var
	xref RememberKey_
	xref ShortMulTablePtr_
	xref ScreenBitMap_		;big picture, viewable screen
	xref ScreenBitMap_Planes_	;big picture, viewable screen
	xref ScreenPtr_
	xref UnDoBitMap_		;backup pic ("superbitmap") of screen
	xref UnDoBitMap_Planes_	;backup pic ("superbitmap") of screen
	xref Zeros_

	xref	AreaBufferPtr_		;list of endpts (4bytes per...)
	xref	AreaBufferLen_
	xref	AreaChunkLen_	;#endpts, really
	xref	AreaVectorPtr_	;list of endpts (*5*bytes per...)
	xref	AreaVectorLen_	;.long

FreeAreaStuff:
	clr.l	AreaChunkLen_(BP)	;march24'89...really, #of endpts
	clr.l	AreaBufferLen_(BP)
	lea	AreaBufferPtr_(BP),a0
	bsr.s	9$			;free it, shorter opcode
	clr.l	AreaVectorLen_(BP)
	lea	AreaVectorPtr_(BP),a0
9$	bra	FreeOneVariable
	;RTS


AllocAreaStuff:
	bsr.s	FreeAreaStuff
	bsr.s	reallyallocarea
	beq.s	8$
	rts
8$:
	bsr.s	FreeAreaStuff
	bsr	CleanupMemory
	;bra.s	reallyallocarea
	;rts

reallyallocarea:
	movem.l	d1/a0-a2/a6,-(sp)

	lea	AreaChunkLen_(BP),a2	;march24'89...really, #of endpts
	;move.l	#(9*31000),d0	;31k endpts (.word ctr later)
	;move.l	#(9*5000),d0	;5k endpts (.word ctr later) (45k)
	;move.l	#(9*7000),d0	;5k endpts (.word ctr later) (=~63k)
	move.l	#7000,d0	;7k endpts (.word ctr later) (=~63k)

	move.l	d0,(a2)		;save requested len
tryallocarea:

	;(a2)=d0=#endpts, get d0=chipmemptr, d1=fastmemptr
	clr.L	-(sp)		;fast adr ;...STACK
	clr.L	-(sp)		;chip adr
	asl.L	#2,d0		;*4 for fast alloc
	bsr	IntuitionAllocMain	;any really, but fast prefer'd
	move.l	d0,4(sp)	;STACK usage offset 4 FASTMEM
	move.l	(a2),d0		;#endpts
	asl.L	#2,d0		;*4
	add.l	(a2),d0		;*5 for chip (graphics area fill requ'ment)
	bsr	IntuitionAllocChip
	move.l	d0,(sp)		;STACK usage offset 0 CHIPMEM
	beq.s	delboth
chkfast:			;have chip...have fast too?
	tst.l	4(sp)		;fastmem adr
	bne.s	gotboth
delboth:			;nope
	lea	(sp),a0		;temp var for chipmem adr
	bsr	FreeOneVariable
	lea	4(sp),a0	;temp var for fastmem adr
	bsr	FreeOneVariable
gotboth:
	movem.l	(sp)+,d0/d1
			;(a2).l=#endpts, d0=chipmemptr, d1=fastmemptr
	tst.l	d0		;adr zero is invalid (both valid or both dead)
	bne.s	gotit_gab	;subr returns flagZERO
	move.l	(a2),d0		;current requested #pts
	asr.l	#1,d0		;half it
	move.l	d0,(a2)		;save requested #pts...need for ending calcs
	bne.s	tryallocarea	;...and try again
gotit_gab:
	move.l	d1,AreaBufferPtr_(BP)	;fastmem pref....contour endpts
	move.l	d0,AreaVectorPtr_(BP)	;chipmem

	move.l	(a2),d0	;#endpts
	asl.l	#2,d0
	move.l	d0,AreaBufferLen_(BP)	;*4bytes per entry
	add.l	(a2),d0			;+1 "=" *5
	move.l	d1,AreaVectorLen_(BP)	;*5bytes per entry (chipmem/graphics)

	movem.l	(sp)+,d1/a0-a2/a6

	tst.l	AreaBufferPtr_(BP)	;return zero or NE (note:->a_reg no flag fx)
	rts




GrabBigFileBuffer:	;"big" buffer for default picture...
	lea	FileBufferPtr_(BP),a0	;address of...
	bsr	FreeOneVariable

	movem.l	d1/a0-a2/a6,-(sp)
	move.l	#BIGMAXBUFFER,d0
	move.l	d0,BufferLen_(BP)	;save requested len
	;bsr	IntuitionAllocMain	;AnyCleared
	bsr	IntuitionAllocAnyCleared
	movem.l	(sp)+,d1/a0-a2/a6	;a0=filebufferptr_

	move.l	d0,(a0)		;address (any?...sets/clears zero flag)
	move.l	d0,a0		;return zero or NE
	rts



	;MAY16...replace actual alloc's with calls to availmem


 xdef EnsureLittleExtraChip 	;ensure 'extra' chipmem avail, returns ZERO flag
EnsureLittleExtraChip:		;ensure 'extra' chipmem avail, returns ZERO flag
				;only ref'd by ShowFReq...may07'89
				;also ref'd by Do/InitMagnify May15
	;move.l	#4096,d0
	;move.l	#(6*1024),d0	;6k only allows magnify 1x on a 512k PAL
	move.l	#(5*1024),d0
	;bsr.s	CheckAvailChip
	;rts

 xdef CheckAvailChip	;june29...domagnify uses this too
CheckAvailChip:	;'local' subr, d0=size want to 'ensure'
	move.l	d0,-(sp)
		move.l	#MEMF_CHIP,d1
		CALLIB	Exec,AvailMem
	cmp.l	(sp)+,d0
	scc	d0	;only 'sets' a byte
	ext.w	d0	;sets zero/not zero flag (not= if ok)
	rts

	;MAY16 late....
 xdef EnsureLotsaExtraChip 	;ensure 'extra' chipmem avail, returns ZERO flag
EnsureLotsaExtraChip:		;ensure 'extra' chipmem avail, returns ZERO flag

	;move.l	#30*1024,d0	;for initmagnify...
	;move.l	#26*1024,d0	;for initmagnify... (16Kmin mag, 10K hamtool)


	move.l	#chipreq,d0	;june30



		;account for existance of hamtools ;june14
	xref ToolWindowPtr_
	tst.l	ToolWindowPtr_(BP)	;window on ham tool screen
	beq.s	1$
	;june30;sub.l	#10*1024,d0	;reduce requ'd free mem amt, since tools open
	sub.l	#toolreq,d0	;10*1024,d0	;reduce requ'd free mem amt, since tools open
1$


	bra.s	CheckAvailChip
	;rts


 xdef EnsureBigExtraChip 	;ensure 'extra' chipmem avail, returns ZERO flag
EnsureBigExtraChip:		;ensure 'extra' chipmem avail, returns ZERO flag

	;move.l	#20480,d0
	move.l	#chipreq,d0
		;account for existance of hamtools ;june14
	xref ToolWindowPtr_
	tst.l	ToolWindowPtr_(BP)	;window on ham tool screen
	beq.s	1$
	;sub.l	#10*1024,d0	;reduce requ'd free mem amt, since tools open
	sub.l	#toolreq,d0	;reduce requ'd free mem amt, since tools open
1$
	bra.s	CheckAvailChip
	;rts



EnsureExtraChip:		;ensure 'extra' chipmem avail, returns ZERO flag

	move.l	#BIGEXTRA,d0		;amt of chipk to 'reserve' for system
	bra.s	CheckAvailChip
	;rts

  ifc 't','f' ;JULY02
GrabExtraChip:	;used by main.o OpenBigPic to grab some chipmem
	lea	ExtraChipPtr_(BP),a0	;address of...
	bsr	FreeOneVariable		;returns a0 still valid (var ptr)

	movem.l	d1/a0-a2/a6,-(sp)	;note: a0 = filebufferptr var adr
	move.l	#BIGEXTRA,d0		;amt of chipk to 'reserve' for system
	bsr	IntuitionAllocChipJunk
	move.l	d0,ExtraChipPtr_(BP)	;returns zero flag
	movem.l	(sp)+,d1/a0-a2/a6
	rts
  
GrabLittleExtraChip:	;may18late...used by 'grab file buffer'
	lea	ExtraChipPtr_(BP),a0	;address of...
	bsr	FreeOneVariable		;returns a0 still valid (var ptr)

	movem.l	d1/a0-a2/a6,-(sp)	;note: a0 = filebufferptr var adr
	;move.l	#5*1024,d0 ;#BIGEXTRA,d0		;amt of chipk to 'reserve' for system
	;move.l	#7*1024,d0 ;#BIGEXTRA,d0 ;amt of chipk to 'reserve' for system MAY19
	;move.l	#3*1024,d0 ;#BIGEXTRA,d0 ;amt of chipk to 'reserve' for system MAY19
	move.l	#8*1024,d0 ;#BIGEXTRA,d0 ;amt of chipk to 'reserve' for system MAY19
	bsr	IntuitionAllocChipJunk
	move.l	d0,ExtraChipPtr_(BP)	;returns zero flag
	movem.l	(sp)+,d1/a0-a2/a6
	rts
  ENDC ;JULY02

GrabFileBuffer:	;does an alloc' if needed; iffload.o
	lea	FileBufferPtr_(BP),a0	;address of...
	bsr	FreeOneVariable		;returns a0 still valid (var ptr)

;MAY20
;	xref FlagSave_		;may19, late
;	tst.b	FlagSave_(BP)
;	bne.s	15$
;
;		;MAY19...blow directory if lowmem situ'
;	bsr	EnsureExtraChip
;	bne.s	1$
;	tst.b	FlagCloseWB_(BP)	;"close wbench and hamtools" mode?
;	beq.s	1$
;	xjsr	CleanupDirRemember
;1$
;
;	;bsr	GrabExtraChip		;10k file 'cancel/continue' requester
;	bsr	GrabLittleExtraChip	;6k file 'cancel/continue' requester
;	beq.s	ea_gbf
;15$
	lea	FileBufferPtr_(BP),a0	;address of...
	movem.l	d1/a0-a2/a6,-(sp)	;note: a0 = filebufferptr var adr

	;MAY21
	move.l	#MEMF_FAST!MEMF_LARGEST,d1
	CALLIB	Exec,AvailMem	;rtns d0=largest avail
	tst.l	d0		;any fastmem?
	bne.s	006$
	move.l	#MEMF_CHIP!MEMF_LARGEST,d1
	CALLIB	Exec,AvailMem	;rtns d0=largest avail
006$	move.l	#MAXBUFFER,d1	;63k+4
	cmp.l	d1,d0
	bcc.s	007$	;largest is bigger than 63K
	asr.l	#1,d0	;largest/2
	move.l	d0,d1	;largest
007$

	;;;may21;;;move.l	#MAXBUFFER,d1	;63k+4
	lea	BufferLen_(BP),a2
	move.l	(a2),d0	;current//requested size
	bne.s	3$
2$	move.l	d1,d0	;63k+4	;set largest
	subq.l	#4,d0
3$	cmp.l	d1,d0		;(d0=len requested)<=63k?
	bcc.s	2$		;nope...set max
4$	move.l	d0,(a2)		;save requested len

	bsr	IntuitionAllocAnyCleared ;need CLEARED for linemode endptbuffer
	bne.s	gotit_gfb	;subr returns flagZERO
	move.l	(a2),d0		;current requested len
	asr.l	#1,d0		;half it

	beq.s	gotit_gfb	;no memory	;APRIL11'89
	cmp.l	#MINBUFF,d0		;arbitrary, minimum buff size?
	beq.s	gotit_gfb	;no memory	;APRIL11'89

	;bne.s	4$		;...and try again
	bra.s	4$		;...and try again
gotit_gfb:
		;MAY18late
	move.l	d0,-(sp)		;just alloc'd file buffer
	lea	ExtraChipPtr_(BP),a0	;address of...
	bsr.s	FreeOneVariable		;returns a0 still valid (var ptr)

	;movem.l	(sp)+,d1/a0-a2/a6
	movem.l	(sp)+,d0/d1/a0-a2/a6

	move.l	d0,(a0)		;address (any?...sets/clears zero flag)
	move.l	d0,a0		;return zero or NE
ea_gbf:
	rts

GrabLoadPlane0:	;does an alloc' if needed; iffload.o, ->a0...
	lea	LoadPlane0Ptr_(BP),a0	;address of...
	move.l	(a0),d0			;any?
	bne.s	endof_glp		;already gotit
	move.l	#1024,d0	;how many bytes (enuff for 1024 pixels)
	bsr.s	IntuitionAllocAnyCleared
	move.l	d0,(a0)		;address (any?...sets/clears zero flag)
endof_glp:
	move.l	d0,a0		;doesn't change flags, rtns 0 or NE
	rts

  ifnd Remember
 STRUCTURE Remember,0
	 APTR rm_NextRemember
	 LONG rm_RememberSize
	 APTR rm_Memory
 LABEL	 rm_SIZEOF
  endc


FreeOneVariable:	;A0=Address of variable to free, RETURNS a0 unmolested
	move.l	(a0),d0	;address of memory to free
	clr.l	(a0)	;(say it's gone...)

FreeOneRemember:	;D0=Address of memory to free, RETURNS a0 unmolested
	tst.l	d0			;address to free mem?
	beq.s	finalend_f1r		;none...get outta here
	movem.l	d0/a0/a1/a6,-(sp)	;BLOWS d1

	lea	RememberKey_(BP),a0	;remember list, look for mem chunk
f1restart:
	move.l	a0,a1			;a1=save prev for de-linking
	move.l	(a0),d1			;d1=rm_NextRemember
	beq.s	endof_f1r		;nothing in list (why?...)
	move.l	d1,a0			;a0=next/current
	cmp.l	rm_Memory(a0),d0	;this chunk aptr to our memry?
	bne.s	f1restart		;nope...reloop till endalist
f1gotm:	;move.l	rm_NextRemember(a0),rm_NextRemember(a1) ;prev<==NEXT after me
	move.l	(a0),(a1) ;prev<==NEXT after me	;de-link me...ao=me, a1=prev

		;free this 'remember' struct  & its memory chunk
	clr.l	(a0)		;rm_NextRemember(a0) ;points to nOOne, now.
	move.l	a0,-(sp)	;temp pointer to a remember struct
	lea	(sp),a0		;"pointer to a remember pointer"...
	bsr	IntuitionFreeRemember
	lea.l	4(sp),sp

endof_f1r:
	movem.l	(sp)+,d0/a0/a1/a6
finalend_f1r:
	rts


	xdef IntuitionAllocChipJunk	;"junk"=not-cleared!
IntuitionAllocChipJunk:
		movem.l	d1/a0/a1/a6,-(sp)
		move.l	#MEMF_CHIP,d1
		bra.s	main_subentry

IntuitionAllocMain:
	move.l	d0,-(sp)
	bsr.s	tryfast
	moveM.l	(sp)+,d1	;memsize, moveM opcode leaves Zflag alone
	bne.s	gotit		;get memory? (test still valid from subr)
	move.l	d1,d0		;restate original size spec, try 'slowmem' now

		movem.l	d1/a0/a1/a6,-(sp)
		moveq	#0,d1		;"any" type spec
		bra.s	main_subentry

tryfast:	movem.l	d1/a0/a1/a6,-(sp)
		move.l	#MEMF_FAST,d1	;just fast (NOT cleared)
		bra.s	main_subentry

tryfastc:	movem.l	d1/a0/a1/a6,-(sp)
		move.l	#MEMF_FAST!MEMF_CLEAR,d1
		bra.s	main_subentry

IntuitionAllocAnyCleared: 	;alloc any type, but cleared fer sure
	move.l	d0,-(sp)
	bsr.s	tryfastc
	moveM.l	(sp)+,d1	;memsize, moveM opcode leaves Zflag alone
	bne.s	gotit		;get memory? (test still valid from subr)
	move.l	d1,d0		;restate original size spec, try 'slowmem' now

IntuitionAllocChip:
		movem.l	d1/a0/a1/a6,-(sp)
		move.l	#MEMF_CHIP!MEMF_CLEAR,d1 ;*chip* gets cleared
main_subentry:
		or.w	#MEMF_PUBLIC,d1		;enables clear of chipmem(?)
		lea	RememberKey_(BP),a0

		CALLIB	Intuition,AllocRemember
		movem.l	(sp)+,d1/a0/a1/a6
		tst.l	d0	;return zero flag, alloc failed?
gotit:		rts		;'rts' for memory alloc subrs
;--
FreeAllMemory		;frees all memories.o managed memory (abort/end)
	xjsr	CleanupDirRemember ;dirrtns.o ;delete remembered filenames/dir
	lea	RememberKey_(BP),A0

IntuitionFreeRemember:	moveq	#-1,d0 ;TRUE
			JMPLIB	Intuition,FreeRemember


GraphicsWaitBlit:	;RETURNS A6 = GraphicsBase
	movem.l	d0/d1/a0/a1,-(sp)
	CALLIB	Graphics,WaitBlit
	;trust it now?;CALLIB	SAME,WaitBlit		;dont trust it, try again...
	;CALLIB	SAME,WaitBlit		;dont trust it, try again...
	movem.l	(sp)+,d0/d1/a0/a1
	rts

MemRegList	reg	d0-d3/a0-a2/a6	;general purp. register list

AllocDetermineTable:
	lea	DetermineTablePtr_(BP),a0
	move.l	(a0),d0
	bne.s	got_pdt
	st	FlagCDet_(BP)		;flags openbigpic/mainloop/iffload

	;move.l	#((16*1024)+4096),d0	;paldif table PLUS brite table
	;move.l	#(16*1024),d0		;8kpaldif table APRIL10'89
	;move.l	#(8*1024)+8,d0		;8kpaldif table APRIL10'89
	;move.l	#(16*1024),d0		;ONLY WANT 8K!!!!!

	move.l	#(8*1024),d0		;only need 8kpaldif table APRIL10'89
	bsr	IntuitionAllocMain
	move.l	d0,(a0)	;DetermineTablePtr_(BP)
	;beq.s	got_pdt	;boom! no table alloc'd
got_pdt:
	rts


InitShortMulTable:
	lea	ShortMulTablePtr_(BP),a2
	tst.l	(a2)
	bne.s	enda_ism	;already have a table
	move.l	#((16*256)+4096),d0	;table of BYTES (4k total)
	bsr	IntuitionAllocMain ;memories.o, cleared mem alloc
	move.l	d0,(a2)		;ShortMulTablePtr_(BP)
	beq.s	enda_ism	;die, no table

	move.l	d0,a0		;table starting adr, where we fill w/BYTES
	move.w	#(256-1),d4	;256-1 little tables (zero, 1st table empty)
	moveq	#0,d3		;'table number' (2nd one, really)
smloop:	moveq	#(16-1),d2	;16 entries each 'little' table
	moveq	#0,d1		;current total, new total each lil' table
lsmloop	add.W	d3,d1		;d1=total+current table number
	move.w	d1,d0		;copy total
	asr.w	#4,d0		;strip lower 4 bits, only saving 8 of 12
	move.B	d0,(a0)+	;save a 8 bit value (we know >>4)
	dbf	d2,lsmloop 	;little table
	addq	#1,d3		;'table number' number (incrementor)
	dbf	d4,smloop	;256 little tables (of 16 entries each)


		;fill in briteness lup
	movem.l	d0-d5/a0-a4,-(sp)
	move.l	(a2),d0			;shrotmul table just alloc/init'd
	add.l	#((16*256)+4096),d0	;pt just past end of 2nd table
	move.l	d0,a0
	moveq	#(16-1),d0	;'red'
rpdlp:
	moveq	#(16-1),d1	;BLUE   'rrrBBBggg' for lup of brites
bpdlp:
	move.w	d0,d3	;temp highest
	cmp.w	d1,d3
	bcc.s	1$
	move.w	d1,d3	;newtemp highest
1$
	moveq	#(16-1),d2	;green; d3=temp highest
gpdlp:	move.w	d3,d4	;temp to fill
	cmp.b	d2,d4
	bcc.s	1$
	move.w	d2,d4
1$	asl.b	#4,d4	;<<4...shift integer to upper nybble, clear fract bits
	move.b	d4,-(a0) ;BRIGHTNESS NOW always has 4 zero'd fraction bits...

	dbf	d2,gpdlp
	dbf	d1,bpdlp
	dbf	d0,rpdlp
	move.L	a0,BriteTablePtr_(BP)

	movem.l	(sp)+,d0-d5/a0-a4
	;tst.l	d0	;not needed?
	;tst.l	d1		;SET NOT ZERO FLAG!
	moveq	#-1,d0	;set not-zero!

enda_ism:			;if aborting, zero is set by inital test
	rts	;initshortmultable


PasteToFast:	;force swap brush into FAST memory (for BEFORE brush swap)
	movem.l	MemRegList,-(sp)
	move.l	a4,-(sp)		;extra a-reg used...

	;outta here if no fast mem to copy to, anyway....JUNE28
	move.l	#MEMF_FAST!MEMF_LARGEST,d1
	CALLIB	Exec,AvailMem		;rtns d0=largest avail
	tst.l	d0			;any fastmem?
	beq.s	abort_pastetofast	;no fastmem?

	;lea	AltPasteBitMap_(BP),a4	;bm_ struct
	lea	PasteBitMap_(BP),a4	;bm_ struct
	lea	bm_Planes(a4),a2
	moveq	#(7-1),d3		;6 ham bitplanes, 7th for mask
Paste_tofastplane:
	move.w	(a4),d0 ;bm_BytesPerRow(a4),d0	;d0=#bytes (not pixels)
	mulu	bm_Rows(a4),d0		;'real' planesize for AltPaste bitmap
	bsr	IntuitionAllocMain	;tries for fastmemfirst, d0=alloc'd adr
	beq.s	abort_pastetofast	;no mem?

	;move.l	d0,-(sp)	;new fast memory
	clr.l	-(sp)		;STACK new bitplane adr
	move.l	d0,a1		;a1=to new bitplane
	;move.l	d0,a0		;a0=newbitplane (temp, in case have to free)
	tst.l	(a2)		;old bitplane
	beq.s	Pfreenp_fast	;....none, oops, free new paste chip
	move.l	a1,(sp)		;save (on stack) new bitplane adr
	move.l	(a2),a0		;a0=from bitplane adr

	MOVE.W	(a4),d0	;bm_BytesPerRow(a4),d0
	mulu	bm_Rows(a4),d0
	bsr	QUICKCopy	;d0=count, a0=from address a1=to adr
	move.l	(a2),d0		;d0=old bitplane
	;lea	(a2),a0		;a0=adr of var
Pfreenp_fast:
	bsr	FreeOneRemember ;Variable	;Remember ;A0=Address of memory to free
	move.l	(sp)+,(a2)+	;new alloc'd bitplane into/replacement adr
	dbeq	d3,Paste_tofastplane	;dont loop if no alloc

abort_pastetofast:	;...8th first, cutPaste.o switches 7th
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList

	rts

PasteToChip:	;force swap brush into CHIP memory (for AFTER brush swap)
	movem.l	MemRegList,-(sp)
	move.l	a4,-(sp)		;extra a-reg used...
	;lea	AltPasteBitMap_(BP),a4	;bm_ struct
	lea	PasteBitMap_(BP),a4	;bm_ struct
	lea	bm_Planes(a4),a2
	moveq	#(7-1),d3		;6 ham bitplanes, 7th for mask
Paste_tochipplane:
	move.w	(a4),d0	;bm_BytesPerRow(a4),d0	;d0=#bytes (not pixels)
	mulu	bm_Rows(a4),d0		;'real' planesize for AltPaste bitmap
	bsr	IntuitionAllocChipJunk	;address of new memory in d0 NOT CLR'D
	beq.s	abort_pastetochip	;no mem?

	clr.l	-(sp)		;STACK new bitplane adr
	move.l	d0,a1		;a1=to new bitplane
	tst.l	(a2)		;old bitplane
	beq.s	Pfreenp_chip	;....none, oops, free new paste chip
	move.l	a1,(sp)		;save (on stack) new bitplane adr
	move.l	(a2),a0		;a0=from bitplane adr

	MOVE.W	(a4),d0	;bm_BytesPerRow(a4),d0
	mulu	bm_Rows(a4),d0
	bsr	QUICKCopy	;d0=count, a0=from address a1=to adr
	move.l	(a2),d0		;d0=old bitplane
Pfreenp_chip:
	bsr	FreeOneRemember ;Variable	;Remember ;A0=Address of memory to free
	move.l	(sp)+,(a2)+	;new alloc'd bitplane into/replacement adr
	dbeq	d3,Paste_tochipplane	;dont loop if no alloc

	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList
	rts

abort_pastetochip:	;...8th first, cutPaste.o switches 7th
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList
	xjmp	EndCutPaste		;removes brush
	;rts

AltPasteChip:	;force swap brush into CHIP memory (for brush bitmap swap)
	movem.l	MemRegList,-(sp)
	move.l	a4,-(sp)		;extra a-reg used...
	lea	AltPasteBitMap_(BP),a4	;bm_ struct
	lea	bm_Planes(a4),a2
	moveq	#(7-1),d3		;6 ham bitplanes, 7th for mask
AltPaste_Chipplane:
	move.w	(a4),d0	;bm_BytesPerRow(a4),d0	;d0=#bytes (not pixels)
	mulu	bm_Rows(a4),d0		;'real' planesize for AltPaste bitmap
	bsr	IntuitionAllocChipJunk	;address of new memory in d0 NOT CLR'D
	beq.s	abort_AltPasteChip	;no mem?

	clr.l	-(sp)		;STACK new bitplane adr
	move.l	d0,a1		;a1=to new bitplane
	tst.l	(a2)		;old bitplane
	beq.s	freenp_chip	;....none, oops, free new paste chip
	move.l	a1,(sp)		;save (on stack) new bitplane adr
	move.l	(a2),a0		;a0=from bitplane adr

	MOVE.W	(a4),d0	;bm_BytesPerRow(a4),d0
	mulu	bm_Rows(a4),d0
	bsr	QUICKCopy	;d0=count, a0=from address a1=to adr
	move.l	(a2),d0		;d0=old bitplane
	;lea	(a2),a0		;a0=adr of var
freenp_chip:
	bsr	FreeOneRemember ;Variable	;Remember ;A0=Address of memory to free
	move.l	(sp)+,(a2)+	;new alloc'd bitplane into/replacement adr
	dbeq	d3,AltPaste_Chipplane	;dont loop if no alloc

abort_AltPasteChip:	;...8th first, cutPaste.o switches 7th
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList

	rts

  ifc 't','f'
AltPasteFast:	;force swap brush into FAST memory (for normal stretching)
	movem.l	MemRegList,-(sp)
	move.l	a4,-(sp)		;extra a-reg used...
	lea	AltPasteBitMap_(BP),a4	;bm_ struct
	lea	bm_Planes(a4),a2
	moveq	#(7-1),d3		;7th for mask, 8th for work/flood
AltPaste_Fastplane:
	move.w	(a4),d0	;bm_BytesPerRow(a4),d0	;d0=#bytes (not pixels)
	mulu	bm_Rows(a4),d0		;'real' planesize for AltPaste bitmap
	bsr	IntuitionAllocMain	;address of FAST memory in d0 NOT CLR'D
	beq.s	abort_AltPasteFast	;no mem?

	move.l	d0,-(sp)	;new chip memory
	move.l	d0,a1		;a1=to new bitplane
	move.l	(a2),a0		;a0=from old bitplane
	MOVE.W	(a4),d0	;bm_BytesPerRow(a4),d0
	mulu	bm_Rows(a4),d0
	bsr	QUICKCopy	;d0=count, a0=from address a1=to adr
	lea	(a2),a0		;a0=adr of var
	bsr	FreeOneVariable	;Remember	;D0=Address of memory to free
	move.l	(sp)+,(a2)+	;new alloc'd bitplane into/replacement adr

	dbf	d3,AltPaste_Fastplane
abort_AltPasteFast:	;...8th first, cutPaste.o switches 7th
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList

	rts
  endc

AllocAltPaste: ;allocate a bitmap for the "new" cutout brush
	movem.l	MemRegList,-(sp)
	bsr.s	FreeAltPaste		;remove (possibly wrong sized) bitmap
	bsr.s	really_allocAltPaste		;try to allocate bitmap
	tst.l	AltPasteBitMap_Planes_(BP)	;did we get it?
	bne.s	1$
	bsr	ErrorCleanup		;not 'nuff memory, reorganize it
	bsr.s	really_allocAltPaste	;no...try to allocate bitmap
	tst.l	AltPasteBitMap_Planes_(BP)	;did we get it?
	bne.s	1$
	st	FlagDisplayBeep_(BP)
	moveq	#0,d0			;set ZERO, no alloc
1$
	st	FlagNeedGadRef_(BP)	;tells main->redohires->redomenu

		;MAY19
	bsr	EnsureExtraChip
	bne.s	08$
	st	FlagDisplayBeep_(BP)
	bsr.s	FreeAltPaste
	moveq	#0,d0			;zero, no alloc, no extra chip
08$

	movem.l	(sp)+,MemRegList
9$	rts

really_allocAltPaste:
	movem.l	MemRegList,-(sp)
	move.l	a4,-(sp)		;extra a-reg used...
	lea	AltPasteBitMap_(BP),a4	;bm_ struct
	lea	bm_Planes(a4),a2
	moveq	#(7-1),d3		;7th for mask, 8th for work/flood
alloc_AltPaste_plane:
	move.l	a0,-(sp)		;stack usage for temp
	lea	PasteBitMap_(BP),a0	;"real" (current) brush
	move.w	bm_Rows(a0),bm_Rows(a4)	;paste->altpaste detail copy
	move.w	(a0),d0	;bm_BytesPerRow(a0),d0	;d0=#bytes (not pixels)
	move.l	(sp)+,a0		;(should avail a-reg?)

	MOVE.W	d0,(a4) ;bm_BytesPerRow(a4)	;stuff/fill bitmap struct for initbitp
	mulu	bm_Rows(a4),d0		;'real' planesize for AltPaste bitmap

	bsr	IntuitionAllocMain	;any memory type, (fast first)

	move.l	d0,(a2)+
	beq.s	abort_allocAltPaste	;no mem?
	dbf	d3,alloc_AltPaste_plane
					;...8th first, cutPaste.o switches 7th
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList
	rts

abort_allocAltPaste:
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList

FreeAltPaste:
	st	FlagNeedGadRef_(BP)	;tells main->redohires->redomenu
	lea	AltPasteBitMap_(BP),a0	;swap brush (stretch source)
	bra	freebitmap
	;rts

EndaSwapAltPaste:
	sf	FlagBitMapSaved_(BP)	;flag bitmap not saved
	rts

SwapAltPaste:	;exchange brush, 'other' brush (stretch source)
	PEA	EndaSwapAltPaste(pc)	;go "here" when done

		;april10'89
	xjsr	UnShowPaste
	bsr	FreeDouble		;temp chip, double buffer
	st	FlagNeedShowPaste_(BP)	;MAY19

	;;;;;;;;;;;;;;;;;;bsr	GraphicsWaitBlit	;wait????MAY19
	bsr	FreeLoResMask		;removes "anti-aliasness"
	tst.l	PasteBitMap_Planes_(BP)
	bne.s	haveabrush		;bra when currently carrying a brush

		;NO BRUSH, but asked for a swap, RETRIEVE/CLONE alt->"real"
	tst.l	AltPasteBitMap_Planes_(BP)	;HAVE an alternate?
	beq	easap			;no brush, no alt brush, -> no alloc

	PEA	CopyScreenSuper
	PEA	AllocAndSaveCPUnDo	;does super->cpundo
	bsr	FreeCPUnDo

	bsr	AltPasteChip		;force swap brush into CHIP memory
	bsr.s	swapptrs		;copy altpaste bitmap data->paste
	tst.l	PasteBitMap_Planes_(BP)
	sne	FlagCutPaste_(BP)	;go into cutpaste mode (if HAVE brush)
	bra	PasteToAltCopy		;ensure still have altpaste

haveabrush:
	tst.l	AltPasteBitMap_Planes_(BP)

	;beq	PasteToAltCopy		;no alternate bitmap yet, go create it
		;MAY19
	bne.s	10$
	bsr	PasteToAltCopy		;create altbrush (clone it)
	tst.l	AltPasteBitMap_Planes_(BP)	;is there now an altbrush?
	beq	easap			;no alt brush...end "swap" rtn
10$					;then come back and do swap

	bsr	PasteToFast
	bsr	AltPasteChip		;force swap brush into CHIP memory
	;APRIL10'89 noneed?;PEA	PasteToChip(pc)		;after swap, ensure brush->'chip' memory
swapptrs:				;else swap ptrs alt<->real
	lea	PasteBitMap_(BP),a0
	lea	AltPasteBitMap_(BP),a1
	tst.l	bm_Planes(a1)
	bne.s	yeaswap
	tst.l	bm_Planes(a0)
	beq.s	easap			;no 'real' brush anymore EITHER
yeaswap:
	MOVE.L	(6*4)+bm_Planes(a1),PMBM_Planes_(BP) ;grab/swap mask plane, too
		;7th bitplane ptr, altpaste bitmap

	move.w	paste_width_(BP),d0
	move.w	altpaste_width_(BP),paste_width_(BP)
	move.w	d0,altpaste_width_(BP)

	move.w	paste_height_(BP),d0
	move.w	altpaste_height_(BP),paste_height_(BP)
	move.w	d0,altpaste_height_(BP)

	move.w	paste_offsetx_(BP),d0
	move.w	altpaste_offsetx_(BP),paste_offsetx_(BP)
	move.w	d0,altpaste_offsetx_(BP)

	move.w	paste_offsety_(BP),d0
	move.w	altpaste_offsety_(BP),paste_offsety_(BP)
	move.w	d0,altpaste_offsety_(BP)

	move.w	paste_leftblank_(BP),d0
	move.w	altpaste_leftblank_(BP),paste_leftblank_(BP)
	move.w	d0,altpaste_leftblank_(BP)

	moveq	#bm_Planes+(8*4)-1,d0	;#bytes in a bitmap struct
swapaploop:
	move.b	(a0),d1		;1st->temp
	move.b	(a1),(a0)+	;2nd->first
	move.b	d1,(a1)+	;temp->2nd
	dbf	d0,swapaploop

	xjmp	InitBitPlanes	;resynch/size new paste stuff
easap	rts

PasteToAltCopy: ;copy current brush bitplane imagery  to 'swap'//alt brush
	bsr	AllocAltPaste		;ensure have a bitmap
	tst.l	AltPasteBitMap_Planes_(BP)
	beq.s	noclone

	move.w	paste_width_(BP),altpaste_width_(BP)
	move.w	paste_height_(BP),altpaste_height_(BP)
	move.w	paste_offsetx_(BP),altpaste_offsetx_(BP)
	move.w	paste_offsety_(BP),altpaste_offsety_(BP)
	move.w	paste_leftblank_(BP),altpaste_leftblank_(BP)

	movem.l	d0-d1/a0-a3,-(sp)
	lea	PasteBitMap_(BP),a0	;"from" bitmap, visible screenbitmap
	lea	AltPasteBitMap_(BP),a1	;"to" bitmap, 'regular' undo

	lea	(7*4)+bm_Planes(a0),a2	;from bitplanes
	lea	(7*4)+bm_Planes(a1),a3	;to   bitplanes
	move.W	bm_Rows(a0),d0		;=#rows//#lines current brush
	mulu	(a0),d0	;bm_BytesPerRow(a0),d0	;=planesize for a brush
	moveq	#7-1,d1			;7 bitplanes per brush
	bra	coppa_loop	;(continue like all the other "bitmap copies")
noclone:
	rts


AllocDouble: ;allocate a bitmap for the "new" doublebitmap bitmap
	tst.l	DoubleBitMap_Planes_(BP) ;memory alloc'd?
	bne.s	9$			;had it already
	bsr.s	really_allocDouble	;no...try to allocate bitmap
	tst.l	DoubleBitMap_Planes_(BP) ;did we get it?
	;NO WANT RE-organize?;NEED?;march16'89;beq	ErrorCleanup		;not 'nuff memory, reorganize it anyway
9$	rts

DblRegList	reg	d0-d3/a0-a2/a4/a6	;general purp. register list

really_allocDouble:
	movem.l	DblRegList,-(sp)
	lea	DoubleBitMap_(BP),a4	;bitmap struct
	lea	bm_Planes(a4),a2	;table of bitplane ptr adrs
	moveq	#(6-1),d3		;7th for mask, 8th for work/flood
alloc_Double_plane:
	move.l	PlaneSize_(BP),d0
	bsr	IntuitionAllocChipJunk	;address of new memory in d0
	move.l	d0,(a2)+
	beq.s	abort_allocDouble	;no mem?
	dbf	d3,alloc_Double_plane
	movem.l	(sp)+,DblRegList
	rts

abort_allocDouble:
	movem.l	(sp)+,DblRegList

FreeDouble:
	lea	DoubleBitMap_(BP),a0
	bra	freebitmap
	;rts



FreeLoResMask:
	tst.l	PasteBitMap_Planes_(BP)	;HAVE a cutout brush?
	beq.s	killm			;no...just delete loresmask

	;	;june19...helps w/flip effects
	;tst.l	LoResMask_(BP)		;other, lo-res (good) mask?
	;beq.s	ea_flrm			;no lores mask, anyway
	;bsr	GraphicsWaitBlit	;unshow?


	;june20
	;lea	PasteBitMap_Planes_(BP),a2
	;lea	(6*4)(a2),a2		;point to address of mask
	;move.l	(a2),d0		;existing, "hires"d mask

	move.l	LoResMask_(BP),d1	;other, lo-res (good) mask
	beq.s	ea_flrm			;no lores mask, anyway

	;move.l	d1,(a2)			;restore real good mask
	;move.l	d0,LoResMask_(BP)	;hires mask ptr, gonna delete it
	;june20...inserted followin "copy"
	move.l	d1,a0			;copy FROM address (lores mask)
	lea	PasteBitMap_(BP),a1
	move.w	(a1),d0			;bm_bytesperrow
	mulu	bm_Rows(a1),d0		;bpr*#rows=#bytes to copy
	move.l	(6*4)+bm_Planes(a1),a1	;TO 7th (mask) bitplane of brush
	bsr	QUICKCopy


	ASL.W	paste_offsetx_(BP)	;DOUBLE LEFTSIDE/BRUSH CENTER'ING
killm:	lea	LoResMask_(BP),a0	;remove
	bra	FreeOneVariable
ea_flrm	rts

AllocLoBrushMask:		;allocs/copies LoResMask_ bitplane
	lea	LoResMask_(BP),a0
	bsr	FreeOneVariable
	bsr.s	AllocPasteMaskClone		;copy of brush mask bitplane
	move.l	d0,LoResMask_(BP)	;adr or zero
	rts

AllocPasteMaskClone:	;alloc/creates clone of brush mask, returns in d0 and a0
	lea	PasteBitMap_(BP),a0
	move.w	(a0),d0			;bm_bytesperrow
	mulu	bm_Rows(a0),d0
	beq.s	9$			;no init'd bitmap for cutout brush?
	;JUNE20;bsr	IntuitionAllocChipJunk	;march10'89...why wait for blit clear?
	bsr	IntuitionAllocMain	;'loresmask' in fastmem (if possible)
	beq.s	9$			;no alloc'd mask?
	move.l	d0,a1			;copy TO address (new lores mask)
	lea	PasteBitMap_(BP),a0
	move.w	(a0),d0			;bm_bytesperrow
	mulu	bm_Rows(a0),d0		;=#bytes to copy
	move.l	(6*4)+bm_Planes(a0),a0	;FROM 7th (mask) bitplane of brush
	bsr	QUICKCopy
	;moveq	#-1,d0	;set flag NOT EQUAL
	move.l	a1,d0	;new bitplane adr (sets NE flag)
	move.l	d0,a0	;be nice'n rtn in a0 too?
9$	rts


  ifc 't','f' ;june20
AllocBrushMaskClone:	;alloc/creates clone of brush mask, returns in d0 and a0
	lea	BB_BitMap_(BP),a0	;'regular' brush (whole picture size)
	move.w	(a0),d0			;bm_bytesperrow
	mulu	bm_Rows(a0),d0
	beq.s	9$			;no init'd bitmap for cutout brush?
	bsr	IntuitionAllocChipJunk	;march10'89...why wait for blit clear?
	beq.s	9$			;no alloc'd mask?
	move.l	d0,a1			;copy TO address (new lores mask)
	lea	BB_BitMap_(BP),a0
	move.w	(a0),d0			;bm_bytesperrow
	mulu	bm_Rows(a0),d0		;=#bytes to copy
	move.l	(6*4)+bm_Planes(a0),a0	;FROM 7th (mask) bitplane of brush
	bsr	QUICKCopy
	;moveq	#-1,d0	;set flag NOT EQUAL
	move.l	a1,d0	;new bitplane adr (sets NE flag)
	move.l	d0,a0	;be nice'n rtn in a0 too?
9$	rts

  endc

AllocPaste: ;allocate a bitmap for the "new" cutout brush
	movem.l	MemRegList,-(sp)
	bsr	FreePaste		;remove (possibly wrong sized) bitmap
	bsr.s	really_allocpaste	;no...try to allocate bitmap
	tst.l	PasteBitMap_Planes_(BP)	;did we get it?
	bne.s	1$ ;3$
	bsr	CleanupMemory
	bsr.s	really_allocpaste	;no...try to allocate bitmap
	tst.l	PasteBitMap_Planes_(BP)	;did we get it?
	beq.s	2$
1$
	bsr	EnsureExtraChip
	bne.s	3$			;ok ok HAVE nuff chipmem
2$
	bsr.s	FreePaste
	;bsr	BeepErrorCleanup		;not 'nuff memory, reorganize it
	st	FlagDisplayBeep_(BP)
3$
	movem.l	(sp)+,MemRegList
	rts

really_allocpaste:
	movem.l	MemRegList,-(sp)
	move.l	a4,-(sp)		;extra a-reg used...
	;lea	PasteBitMap_Planes_(BP),a2 ;table of addresses
	lea	PasteBitMap_(BP),a4	;bm_ struct
	lea	bm_Planes(a4),a2
	moveq	#(7-1),d3		;7th for mask
alloc_paste_plane:
	move.w	paste_width_(BP),d0
	xref paste_leftblank_		;JULY07
	add.w	paste_leftblank_(BP),d0	;account for leftside sup hammods...JULY07

	add.w	#31,d0			;round up to even 32 widths
	;add.w	#(31+3),d0;round up to even 32 widths, +3 for leftedge allow
	and.w	#~31,d0
	asr.w	#3,d0			;/8 pixels per byte
	MOVE.W	d0,(a4) ;bm_BytesPerRow(a4)	;stuff/fill bitmap struct for initbitp
	move.w	paste_height_(BP),bm_Rows(a4)	;ditto (scratch.o, initbitpl')
	mulu	paste_height_(BP),d0	;'real' planesize for paste bitmap
	bsr	IntuitionAllocChipJunk	;d0=result memory NOT CLR'D (quicker)
	move.l	d0,(a2)+
	beq.s	abort_allocpaste	;no mem?
	dbf	d3,alloc_paste_plane
	MOVE.L	-4(a2),PMBM_Planes_(BP) ;paste mask plane, using LAST
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList
	rts

abort_allocpaste:
	move.l	(sp)+,a4
	movem.l	(sp)+,MemRegList

FreePaste:
	;HEY!;TUESDAYMARCH28'89;bsr	UnShowPaste
	xjsr	UnShowPaste
	bsr	FreeDouble		;temp chip (never directly seen) bitmap
	bsr	FreeLoResMask		;removes "other mask" MAY19
	clr.l	PMBM_Planes_(BP)	;Paste Mask Bit Map
	lea	PasteBitMap_(BP),a0
	;bsr.s	freebitmap
	;rts

freebitmap:
	;movem.l	MemRegList,-(sp)
	movem.l	d0/d3/a0/a2,-(sp)
	lea	bm_Planes(a0),a2	;a2=ptr to 6 or 7 bitplane addresses
	moveq	#7-1,d3		;d3=loopcounter
freeaplane:			;note:freeonevar is ok to call if vardata=0
	lea	(a2),A0		;"address of bitplane data"
	move.l	(A0),D0		;mem gonna free
	beq.s	abort_freemap
	bsr	FreeOneVariable	;memories.o, frees from remember list
	lea	4(a2),a2	;pointer to next bitplane adr in bitmap struct
	dbf	d3,freeaplane
abort_freemap:
	;movem.l	(sp)+,MemRegList
	moveq	#0,d0			;sets ZERO flag for subr return status
	movem.l	(sp)+,d0/d3/a0/a2
	rts	;freebitmap

;--
	xdef AllocAndSaveCPUnDo
AllocAndSaveCPUnDo:
	tst.l	CPUnDoBitMap_Planes_(BP)
	bne.s	9$
	bsr.s	AllocCPUnDo
	bra	SaveCPUnDo
9$:	rts

AllocCPUnDo:
	tst.l	CPUnDoBitMap_Planes_(BP)
	bne.s	done_acpundo
	bsr.s	really_acpundo
	tst.l	CPUnDoBitMap_Planes_(BP)
	bne.s	1$
	bsr	CleanupMemory
	bsr.s	really_acpundo	;no...try to allocate bitmap
	tst.l	CPUnDoBitMap_Planes_(BP)
	beq.s	2$
1$
  ifc 't','f' ;MAY16 late
	bsr	GrabExtraChip
	beq.s	2$
	lea	ExtraChipPtr_(BP),a0	;address of...
	bsr	FreeOneVariable		;returns a0 still valid (var ptr)
	bra.s	3$
2$
  endc
	bsr	EnsureExtraChip
	bne.s	3$
2$	bsr.s	FreeCPUnDo
	st	FlagDisplayBeep_(BP)
3$

done_acpundo:
	rts	;AllocCPUnDo

really_acpundo:
	movem.l	MemRegList,-(sp)

	;allocate a bitmap for the undoing cutpaste (may fail)
	lea	CPUnDoBitMap_Planes_(BP),a2	;table of addresses
	moveq	#6-1,d3 ;# planes
alloc_CPUnDo_plane:
	move.l	PlaneSize_(BP),d0
	bsr	IntuitionAllocMain		;FAST first, if any
	move.l	d0,(a2)+
	beq.s	abort_allocCPUnDo ;couldn't get required memory...go make an abortion
	dbf	d3,alloc_CPUnDo_plane
have_CPUnDobitmap:
	movem.l	(sp)+,MemRegList
noway_cpundo:
	rts

abort_allocCPUnDo:
	movem.l	(sp)+,MemRegList

FreeCPUnDo:	;free up extra bitmap memory for "undoing" when cut/pasting
	lea	CPUnDoBitMap_(BP),a0
	bra	freebitmap
	;rts

;--
AllocUnDo:	;allocate a bitmap for "always needed for painting" undo
	tst.l	UnDoBitMap_Planes_(BP)
	bne.s	9$	;have_UnDobitmap
	bsr.s	reallyallocundo
	bne.s	9$
	bsr	CleanupMemory
	bra.s	reallyallocundo
9$	rts

reallyallocundo:
	sf	FlagBitMapSaved_(BP)
	movem.l	MemRegList,-(sp)

	lea	UnDoBitMap_(BP),a0	;table of addresses
	lea	bm_Planes(a0),a2	;a2=table of addrs for alloc'ing
	moveq	#6,d0			;depth
	move.L	BigPicWt_(BP),d1	;var is a .Long
	moveq	#0,d2
	move.w	BigPicHt_(BP),d2	;var is a .Word
	CALLIB	Graphics,InitBitMap

	moveq	#6-1,d3 ;# planes
alloc_UnDo_plane:
	move.l	PlaneSize_(BP),d0
	bsr	IntuitionAllocMain		;FAST first, if any
	move.l	d0,(a2)+
	beq.s	abort_allocUnDo ;couldn't get required memory...go make an abortion

	move.l	d0,a0	;address to clear
	xjsr	ClearPlaneA0	;strokeB.o, clearzit

	dbf	d3,alloc_UnDo_plane
	moveq	#-1,d0	;flag success, alloc'd ok	
	movem.l	(sp)+,MemRegList
have_UnDobitmap:
	rts

abort_allocUnDo:

	movem.l	(sp)+,MemRegList

FreeUnDo:	;free up extra bitmap memory for "undoing" when cut/pasting
	lea	UnDoBitMap_(BP),a0
	bsr	freebitmap
	sf	FlagBitMapSaved_(BP)
	moveq	#0,d0	;flag zero, err in case from alloc undo call
	rts

ErrorCleanup:
	;xjsr	CleanupDirRemember	;dirroutines.o
CleanupMemory:		;clears out unused drivers, etc. ONLY CLEANS CHIP
	;if "no fast memory", then set the "no wbench//chipmem" flag...june28
	xref Initializing_		;APRIL29
	tst.B	Initializing_(BP)	;startup time?
	bne.s	noforcewb		;yep...dont close hamtools
	tst.L	ScreenPtr_(BP)		;bigpic?
	beq.s	noforcewb		;no screen...dont force wb closed
	move.l	#MEMF_FAST!MEMF_LARGEST,d1
	CALLIB	Exec,AvailMem	;rtns d0=largest avail
	tst.l	d0		;any fastmem?
	bne.s	noforcewb
	st	FlagCloseWB_(BP)
noforcewb:

 xdef CleanupMemNoWb		;cleans up, but doesnt force flag closewb JUNE28
CleanupMemNoWb:		;cleans up, but doesnt force flag closewb JUNE28
	lea	ExtraChipPtr_(BP),a0	;address of "extra system guarantee.."
	bsr	FreeOneVariable		;returns a0 still valid (var ptr)
	xjsr	UnShowPaste
	bsr	FreeDouble

	;april30;xref Initializing_		;APRIL29
	;april30;tst.B	Initializing_(BP)	;startup time?
	;april30;bne.s	GlueChip		;yep...dont close hamtools



	tst.b	FlagCloseWB_(BP)	;"close wbench and hamtools" mode?
	beq.s	GlueChip
	xjsr	GoodByeHamTool		;alloc'd after wbench?
	;MAY12;CALLIB	Intuition,CloseWorkBench

GlueChip:
	; allocate a lotta memory, this will fail BUT it will deallocate
	; things like unused device drivers so we free up as much as possible
	;june28;move.l	#7*1024*1024,d0	;1 meg = max chip in german/or/westcher 500's?
	;june28;bra	IntuitionAllocChipJunk	;march10'89...why wait for blit clear?
	rts

	XDEF ByeByeWorkBench
ByeByeWorkBench:		;may 12, separate...so not called always

	tst.b	FlagCloseWB_(BP)	;"close wbench and hamtools" mode?
	beq.s	9$ ;GlueChip
	xjsr	GoodByeHamTool		;alloc'd after wbench?

	CALLIB	Intuition,CloseWorkBench
	move.l	d0,-(sp)			;closewb result

;may13;	moveq	#4,d1	;4/50s of a second	;MAY13
;may13;	CALLIB	DOS,Delay


	bsr.s	CleanupMemory		;GlueChip
	move.l	(sp)+,d0		;closewb result
9$	rts

;--

AllocSwap:	;allocate a bitmap for the CutWindow, if needed
	tst.l	SwapBitMap_Planes_(BP)
	bne.s	9$			;we already have an alternate, go use it

	bsr.s	really_AllocSwap	;...try to allocate bitmap
	tst.l	SwapBitMap_Planes_(BP)	;did we get it?
	bne.s	8$			;yes...

	bsr	CleanupMemory
	bsr.s	really_AllocSwap		;...try to allocate bitmap
	tst.l	SwapBitMap_Planes_(BP)	;did we get it?
	bne.s	8$	;yes...

	bsr	FreeCPUnDo		;any extra undo bitmap lay'n round?
	bsr	CleanupMemory
	bsr.s	really_AllocSwap	;try once more to allocate it
	tst.l	SwapBitMap_Planes_(BP)	;did we get it?
	bne.s	8$		
	st	FlagDisplayBeep_(BP)
8$:	st	FlagNeedGadRef_(BP)	;tells main->redohires->redomenu
	bsr	EnsureExtraChip		;APRIL10'89;GrabExtraChip
	bne.s	85$
	bsr.s	FreeSwap		;not nuff chip left over
85$:
	tst.l	SwapBitMap_Planes_(BP)
9$:	rts

really_AllocSwap:
	movem.l	MemRegList,-(sp)
	lea	SwapBitMap_Planes_(BP),a2	;table of addresses
	moveq	#6-1,d3 		;# planes
alloc_planes:
	move.l	PlaneSize_(BP),d0
	bsr	IntuitionAllocAnyCleared ;alloc any type, but cleared fer sure
	move.l	d0,(a2)+
	beq.s	abort_AllocSwap 	;no mem?...go make an abortion
	dbf	d3,alloc_planes
	st	FlagNeedGadRef_(BP)	;tells main->redohires->redomenu
	bsr	EnsureExtraChip		;APRIL10'89;GrabExtraChip
	bne.s	okextra_swap
	bsr.s	FreeSwap
okextra_swap
	movem.l	(sp)+,MemRegList
	rts

abort_AllocSwap:
	movem.l	(sp)+,MemRegList
	;bra.s	FreeSwap	;alloc of swap failed, delete any bitplanes
	;rts

FreeSwap:
	st	FlagNeedGadRef_(BP)	;tells main->redohires->redomenu
	lea	SwapBitMap_(BP),a0
	bra	freebitmap
   ;rts


MergeCut:
	tst.l	SwapBitMap_Planes_(BP)	;swap screen exist?
	beq.s	9$
	bsr.s	SetEntireScreenMask

	move.b	FlagRub_(BP),d0
	move.w	d0,-(sp)		;save rub-thru status
	st	FlagRub_(BP)		;force "rub thru" mode for repaint/again
	xjsr	Again	;scratch.o	;this is where we repaint
	move.w	(sp)+,d0		;watch here..Word off stack, Byte next
	move.b	d0,FlagRub_(BP)		;restore rub-thru status (byte)
9$	rts

SetEntireScreenMask:	;BIG BUG FIX! was using word, now need LONG planesize..
	;movem.l	d2/d3/d4/a2/a3,-(sp)
	movem.l	d0-d5/a2/a3,-(sp)	;d0,d1,d3,d5 used for fill
	move.l	PlaneSize_(BP),d2	;number of bytes in plane
	move.l	BB1Ptr_(BP),a3
	lea	0(a3,d2.L),a3	;point just past end of mask

	move.l	d2,-(SP)	;LONG STACKIT
	asr.L	#4,d2		;/16 (16 bytes clear per loop)
	subq.W	#1,d2
	bcs.s	no_16chunks
	moveq	#-1,d0
	moveq	#-1,d1
	moveq	#-1,d3
	moveq	#-1,d5
   20$:	movem.l	d0/d1/d3/d5,-(a3)
	dbf	d2,20$
no_16chunks:
	move.w	2(sp),d2	;planesize (lword) from stack (s/b <16)
	and.W	#$000f,d2	;enforce <16
	subq.W	#1,d2		;db' type loop
	bcs.s	even_16	;even boundary, no more to copy
	moveq	#-1,d3
   20$:	move.B	d3,-(a3)
	dbf	d2,20$
even_16:
	lea	4(sp),sp	;TEMPER, saved planesize, counterjunk
	movem.l	(sp)+,d0-d5/a2/a3
	;movem.l	(sp)+,d2/d3/d4/a2/a3
	rts

UnDo:	st	FlagNeedMagnify_(BP)
	sf	FlagBitMapSaved_(BP)	;saveundo clears this, ok for cutp, too

		;REMOVE BLITBRUSH from visible screen
	tst.l	PasteBitMap_Planes_(BP) ;cutpaste?
	beq.s	1$
	PEA	CopyScreenSuper	;later visiblescreen->super
1$

	xjsr	UnShowPaste	;cutpaste.o, removes brush from screen
	bsr	FreeDouble	;removes double bitmap (if any)
	PEA	SaveCPUnDo(pc)	;cutpaste's undo when done LATER super->cpundo
	bsr	RestoreCPUnDo	;...NOW cpundo->super

		;"undo for non-cutpaste mode"
	bsr	AllocDouble
	beq.s	SwapSuperScreen	;didnt get double, do 'old' swap
	bsr	CopySuperDouble	;super  -> double
	xjsr	MoveDoubleFront	;swap screen<->doublebitmap (cutpaste.o)
	bsr	CopyDoubleSuper ;old screenimage->super
	bra	FreeDouble
	;rts	;undo:

SwapSuperScreen:	;swap screenbitmap with UnDoBitMap (normal undo)
	movem.l	d0-d3/a0-a3,-(sp)
	lea	UnDoBitMap_(BP),a2	;FROM normal quickundo backup
	lea	ScreenBitMap_(BP),a3	;TO Screen Backup
	bra.s	swap_entry2

SwapScreenCPUnDo:	;swap screenbitmap with cpundo
	tst.l	CPUnDoBitMap_Planes_(BP)
	beq	abort_SwapCPUnDo	;this label is in the next routine...

	movem.l	d0-d3/a0-a3,-(sp)
	lea	ScreenBitMap_(BP),a2	;FROM Screen Backup
	lea	CPUnDoBitMap_(BP),a3	;TO "speshul" cutpaste UnDo
	bra.s	swap_entry2

SwapSwap:	;swaps alternate(SwapBitMap) with screen(screenbitmap)
	xjsr	UnShowPaste
	bsr	FreeDouble		;temp chip (never directly seen) bitmap
	bsr	CopyScreenSuper		;JUNE05...fixes paste/undo/swap bug xtra undo
	bsr	CopySuperCPUnDo		;JUNE05...helps, too (?)
	bsr	AllocSwap		;create (blank) swap if none
	beq	abort_SwapCPUnDo	

	PEA	CopySuperCPUnDo(pc)	;when done swapping, screen->super->cpsuperu
	PEA	AllocCPUnDo(pc)		;only alloc's if needed
	PEA	CopyScreenSuper(pc)
	movem.l	d0-d3/a0-a3,-(sp)
	lea	SwapBitMap_(BP),a2	;from alternate
	lea	ScreenBitMap_(BP),a3	;to visible
	;bra.s	swap_entry2			

swap_entry2:			
	lea	(6*4)+bm_Planes(a2),a2	;from bitmap
	lea	(6*4)+bm_Planes(a3),a3	;to   bitmap
	movem.l	a2/a3/BP,-(sp)	;STACK BITMAP STRUCT PTRS TO ADRS +basepage=a5

	move.l	PlaneSize_(BP),d2 	;init total #bytes_per_plane to swap
	;move.l	#(5*240),d0		;#bytes swap each time (30 320pix lines)
	;move.l	#(10*240),d0		;#bytes swap each time (60 320pix lines)
	move.l	#(5*240),d0		;#bytes swap each time (30 320pix lines)
split_swap:			;do all planes, a number of times
	sub.l	d0,d2			;total - #to copy
	bcs.s	enda_spsw

	moveq	#6-1,d1	;MAX #planes, counter (already did hambitplanes)
  1$:	move.l	-(a2),d3
	beq.s	2$ ;endof_Xscu
	move.l	d3,a0		;from: actual bitplane data address
	add.l	d2,a0		;plane offset, swapping from bottom up
	move.l	-(a3),d3
	beq.s	2$ ;endof_Xscu
	move.l	d3,a1		;to:  ...ditto...
	add.l	d2,a1		;plane offset, now

	bsr.s	QUICKSwap	;subr preserves ALL regs

	dbf	d1,1$
 2$:	movem.l	(sp),a2/a3/BP

	bra.s	split_swap	;endof_Xscu
enda_spsw:	;end split swap...copied all (or too many?)
	add.l	d0,d2		;reoffset, amt wanted to swap
	beq.s	endof_Xscu
	move.l	d2,d0		;spec. remaing swap (after rpted -8*240's)
	bra.s	split_swap	;continue, last swap now, tests will fall thru
endof_Xscu:
	lea	12(sp),sp	;a2/a3/a5;;bitmap struct ptrs, free up stack

	movem.l	(sp)+,d0-d3/a0-a3	;we definitely destroy d4-d7,a4,a6
	rts

	xdef SwapSuperCPUnDo
SwapSuperCPUnDo:	;swap  UnDoBitMap <=> CPUnDoBitMap
			;non-screen swap, quicker, whole bitplanes at a time
	tst.l	CPUnDoBitMap_Planes_(BP)
	beq.s	abort_SwapCPUnDo

	movem.l	d0-d3/a0-a3,-(sp)
	lea	UnDoBitMap_(BP),a3	;TO regular UnDo/SuperBitMap
	lea	CPUnDoBitMap_(BP),a2	;FROM "speshul" cutpaste UnDo

	lea	bm_Planes(a2),a2	;from bitmap
	lea	bm_Planes(a3),a3	;to   bitmap
	move.l	PlaneSize_(BP),d0	;init # bytes_per_plane -> lwords_per_plane
	moveq	#6-1,d1		;MAX #planes, counter (already did hambitplanes)
  1$:	move.l	(a2)+,d3
	beq.s	endof_scu
	move.l	d3,a0		;from: actual bitplane data address
	move.l	(a3)+,d3
	beq.s	endof_scu
	move.l	d3,a1		;to:  ...ditto...
	bsr.s	QUICKSwap	;this fast SWAP preserves ALL regs
	dbf	d1,1$
endof_scu:
	movem.l	(sp)+,d0-d3/a0-a3
abort_SwapCPUnDo:
	rts


****

swap24:	macro
	movem.l	(a0)+,d1-d6		;12+8n	60cy
	movem.l	(a1)+,d7/a2-a6
	movem.l	d7/a2-a6,-24(a0)	;16+8n	64cy
	movem.l	d1-d6,-24(a1)		;total is 244 cycles to exchg 24 bytes
	endm

swap120:	macro
	swap24
	swap24
	swap24
	swap24
	swap24
    endm

QUICKSwap:	;d0=count, a0/a1 = addresses MUST call with #>120 2b exg'd !!!
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.s	QUICKestSwap	;not xdef'd, this subr
	movem.l	(sp)+,d0-d7/a0-a6
	rts	;QUICKSwap

QUICKestSwap:	;no stack/ save anything (have fun!)
	sub.L	#120,d0
	bcs.s	qs_do24
swap120loop:
	swap120
	sub.L	#120,d0
	bcc.s	swap120loop
qs_do24:
	add.L	#120,d0
	beq.s	endof_swappa
	sub.W	#24,d0
	bcs.s	qs_do1
swap24loop:
	swap24
	sub.W	#24,d0
	bcc.s	swap24loop
qs_do1:
	add.W	#24,d0
	beq.s	endof_swappa
	asr.w	#2,d0	;/4
	subq	#1,d0	;#4,d0	;fix loop end test
	bcs.s	endof_swappa

swap1:	move.L	(a0),d2
	move.L	(a1),d3
	move.L	d3,(a0)+
	move.L	d2,(a1)+
	dbf	d0,swap1

endof_swappa:
	rts


;****
		
CopyPic: ;copy picture to alternate, allocating SwapBitMap if needed
		;JUNE05
	xjsr	UnShowPaste
	bsr	FreeDouble		;temp chip (never directly seen) bitmap

	tst.l	SwapBitMap_Planes_(BP)
	bne.s	2$		;we already have an alternate, go use it
	bsr	AllocSwap	;allocates a bitmap for the CutWindow, if needed
	beq.s	3$		;abort, can't allocate the memory

2$:	movem.l	d0-d1/a0-a3,-(sp)
	lea	ScreenBitMap_(BP),a0	;"from" visible screen
	lea	SwapBitMap_(BP),a1	;"to" fastmem swap screen
	bra	finish_undo_blit	;re-use code from "saveundo"
3$:
	rts ;CopyPic  

CopySuperScreen:	;copy UnDoBitMap to Screenbitmap ONLY USED BY BLITS.o
	;blit what is in superbitmap back onto screen/Undo
		;next line MUY IMPORTANTE
		;refer to showpaste.asm routines show/unshowpaste
	clr.b	FlagReSee_(BP)	 	;clear means brush not on screen

	movem.l	d0-d3/a0-a3,-(sp)
	lea	UnDoBitMap_(BP),a2	;"from" fastmem 'clean' undo
	lea	ScreenBitMap_(BP),a3	;"to" visible screen
	lea	(6*4)+bm_Planes(a2),a2	;bitplane ptrs
	lea	(6*4)+bm_Planes(a3),a3
	movem.l	a2/a3/BP,-(sp)	;STACK BITMAP STRUCT PTRS TO ADRS +basepage=a5

	move.l	PlaneSize_(BP),d2 	;init total #bytes_per_plane to swap
	;move.l	#(8*480),d0		;#bytes to COPY each time
	move.l	#(8*384),d0		;#bytes to COPY each time
split_copy:			;do all planes, a number of times
	sub.l	d0,d2			;total - #to copy
	bcs.s	enda_spcopy
	moveq	#6-1,d1	;MAX #planes, counter (already did hambitplanes)

  1$:	move.l	-(a2),d3
	beq.s	2$ ;endof_Xscopy
	move.l	d3,a0		;from: actual bitplane data address
	add.l	d2,a0		;plane offset, swapping from bottom up
	move.l	-(a3),d3
	beq.s	2$ ;endof_Xscopy
	move.l	d3,a1		;to:  ...ditto...
	add.l	d2,a1		;plane offset, now
	bsr	QUICKCopy	;this fast COPY preserves ALL regs
	dbf	d1,1$

 2$:	movem.l	(sp),a2/a3/BP
	bra.s	split_copy	;endof_Xscopy

enda_spcopy:	;end split copy...copied all
	add.l	d0,d2		;reoffset, amt wanted to swap, leave d2=adroffs
	beq.s	endof_Xscopy
	move.l	d2,d0		;spec. remaing swap (after rpted -8*240's)
	bra.s	split_copy	;continue, last swap now, tests will fall thru
endof_Xscopy:
	lea	12(sp),sp	;a2/a3/a5;;bitmap struct ptrs, free up stack

	movem.l	(sp)+,d0-d3/a0-a3	;we definitely destroy d4-d7,a4,a6
	rts


;--
SaveCPUnDo:	;save an undo layer while cut/pasting (SuperBitMap => CPUnDo)
	lea	UnDoBitMap_(BP),a0
	lea	CPUnDoBitMap_(BP),a1
	tst.l	bm_Planes(a0)
	beq.s	ccp_rts
	tst.l	bm_Planes(a1)
	beq.s	ccp_rts
	movem.l	d0-d1/a0-a3,-(sp)
	bra.s	cpfinis

RestoreCPUnDo:	;restore saved undo layer (CPUnDoBitMap => UnDoBitMap)
	lea	CPUnDoBitMap_(BP),a0	;FROM UnDo
	lea	UnDoBitMap_(BP),a1	;TO Screen Backup
	tst.l	bm_Planes(a0)
	beq.s	ccp_rts
	tst.l	bm_Planes(a1)
	beq.s	ccp_rts
	sf	FlagBitMapSaved_(BP)	;UNDO status updated.(?)..
	movem.l	d0-d1/a0-a3,-(sp)
cpfinis
	bra	finish_undo_blit
ccp_rts	rts


	XDEF ReallySaveUnDo ;late, mousertns use ONLY once (dobuttondown/draw)
ReallySaveUnDo:
	sf	FlagBitMapSaved_(BP)	;force test to fail, copy to happen...

SaveUnDo:	;ent'd here from mousertns.o, drawbrush starting
	;tst.l	ScreenBitMap_Planes_(BP)	;screen open'd?
	tst.l	ScreenPtr_(BP)		;big picture open'd?
	beq.s	su_rts			;SaveUnDo's "rts"
	bsr	AllocUnDo	;allocate a bitmap for the undoing cutpaste (may fail)

		;late late fixup on '1st paste's undo
	tst.l	PasteBitMap_Planes_(BP)	;cutpaste? (i.e., have a brush?)
	beq.s	1$			;not 'carrying a brush'
	xjsr	UnShowPaste
	bsr	FreeDouble		;temp chip (never directly seen) bitmap
	bsr	AllocCPUnDo		;have a brush, ensure 'undo' bitmap
	tst.l	CPUnDoBitMap_Planes_(BP)	;HAVE cutpaste undo?
	bne.s	2$				;no...go save/create it
1$
	tst.b	FlagBitMapSaved_(BP)	;already saved/copied?
	bne.s	su_rts			;SaveUnDo's "rts"

	tst.l	UnDoBitMap_Planes_(BP)
	beq.s	su_rts			;no 'undo' bitmap to save TO?
2$	st	FlagBitMapSaved_(BP)

	bsr.s	CopyScreenSuper
	bra.s	CopySuperCPUnDo
su_rts:	rts	;boom (no undo bitmap?)

 xdef CopySuperCPUnDo ;cutpaste.o ref'
CopySuperCPUnDo:
	movem.l	d0-d1/a0-a3,-(sp)
	lea	UnDoBitMap_(BP),a0	;"from" bitmap, regular undo/screenok
	lea	CPUnDoBitMap_(BP),a1	;"real" undo for cutpaste
	bra.s	finish_undo_blit	;'copy' type routine

CopySuperDouble:	;copy UnDoBitMap(clean undo) to doublebitmap
	movem.l	d0-d1/a0-a3,-(sp)
	lea	UnDoBitMap_(BP),a0	;"from" bitmap, 'regular' undo
	lea	DoubleBitMap_(BP),a1
	bra.s	finish_undo_blit	;'copy' type routine (non-visible data)

CopyDoubleSuper:
	movem.l	d0-d1/a0-a3,-(sp)
	lea	DoubleBitMap_(BP),a0
	lea	UnDoBitMap_(BP),a1	;"to" bitmap, 'regular' undo
	bra.s	finish_undo_blit	;'copy' type routine (non-visible data)

 xdef CopyScreenCPUnDo	;copy Screenbitmap to UnDoBitMap
CopyScreenCPUnDo:	;copy Screenbitmap to UnDoBitMap
	movem.l	d0-d1/a0-a3,-(sp)
	lea	ScreenBitMap_(BP),a0	;"from" bitmap, visible screenbitmap
	lea	CPUnDoBitMap_(BP),a1	;"to" bitmap, 'regular' undo
	bra.s	finish_undo_blit	;'copy' type routine (non-visible data)

CopyScreenSuper:	;copy Screenbitmap to UnDoBitMap
	movem.l	d0-d1/a0-a3,-(sp)
	lea	ScreenBitMap_(BP),a0	;"from" bitmap, visible screenbitmap
	lea	UnDoBitMap_(BP),a1	;"to" bitmap, 'regular' undo

finish_undo_blit:
	lea	(6*4)+bm_Planes(a0),a2	;from bitmap
	lea	(6*4)+bm_Planes(a1),a3	;to   bitmap
	move.l	PlaneSize_(BP),d0	;init # bytes_per_plane -> lwords_per_plane
	moveq	#6-1,d1
coppa_loop:			;ENTRY POINT, 'bra'd here from PasteToAltCopy
	move.l	-(a2),d3	;bitplane ptr from bitmap struct
	beq.s	endof_saveundo
	move.l	d3,a0		;from: actual bitplane data address
	move.l	-(a3),d3	;ano' bitplane ptr
	beq.s	endof_saveundo
	move.l	d3,a1		;to:actual address
	bsr	QUICKCopy	;.s QUICKCopy ;this fast COPY preserves ALL regs
	dbf	d1,coppa_loop
endof_saveundo:
	movem.l	(sp)+,d0-d1/a0-a3
	rts	;SaveUnDo

****
PartialUnDo:	;d0=lineoffset a5=Base	;clears from lineoffset to end
	movem.l	d0-d2/a0-a3,-(sp)
	move.l	(sp),d0	;offset
	sf	FlagBitMapSaved_(BP)	;byte =-1 if UnDoBitMap is saved but not restored
	lea	UnDoBitMap_(BP),a0		;"from" bitmap
	lea	ScreenBitMap_(BP),a1		;"to" bitmap

	lea	(6*4)+bm_Planes(a0),a2	;from bitmap
	lea	(6*4)+bm_Planes(a1),a3	;to   bitmap

	;init counter # bytes_per_plane to move
	neg.L	d0
	add.L	PlaneSize_(BP),d0
	beq.s	skippitall	;bullet proof
	bmi.s	skippitall	;rocket proof
	moveq	#6-1,d2		;MAX #planes, loop counter
uncoppa_loop:
	move.l	-(a2),d3	;from: actual bitplane data address
	beq.s	skippitall	;done, no bitplane
	move.l	d3,a0
	move.l	-(a3),d3	;to:  ...ditto...
	beq.s	skippitall	;done, no bitplane
	move.l	d3,a1
	adda.l	(sp),a0		;d0=count=(planesize-offset)
	adda.l	(sp),a1		;(sp)=stackedd0=offset
	; bsr.s	QUICKCopy	;preserves ALL registers
	bsr	QUICKCopy	;preserves ALL registers
	dbf	d2,uncoppa_loop
skippitall:
	movem.l	(sp)+,d0-d2/a0-a3
an_rts:
	rts

****

****
DoubleUndo:	;d1=first y line, d5=#lines
	lea	DoubleBitMap_(BP),a1	;"to" chipmem doublebuff
	bra.s	dbl_entry

MarkedUnDo:	; undo "only those lines marked in the brushbitmap"
	xjsr	QuickStrokeBounds	;CALC d1=ymin d3=ymax d5=height
	bmi.s	an_rts			;get outta here, nothing marked
	bra.s	IndicatedUndo


IndSingleUndo:	;d1=first y line, d5=#lines
	lea	ScreenBitMap_(BP),a1	;"to" bitmap
	lea	UnDoBitMap_(BP),a0	;"from" bitmap
	move.l	bytes_per_row_(BP),d0
	mulu	d0,d1		;lineoffset to first line
	mulu	d5,d0		;#bytes to copy = #lines*length_of_line
	beq.s	an_rts

	movem.l	d0/d1,-(sp)	;-d2/a0-a3,-(sp)
					;d0(sp)=#bytes d1,4(sp)=offset_start

	lea	(1*4)+bm_Planes(a0),a2	;from bitmap
	lea	(1*4)+bm_Planes(a1),a3	;to   bitmap
	moveq	#(1-1),d2		;MAX #planes, loop counter
	bra.s	muncoppa_loop


IndicatedUndo:	;d1=first y line, d5=#lines
	lea	ScreenBitMap_(BP),a1	;"to" bitmap
dbl_entry:
	lea	UnDoBitMap_(BP),a0	;"from" bitmap
	move.l	bytes_per_row_(BP),d0
	mulu	d0,d1		;lineoffset to first line
	mulu	d5,d0		;#bytes to copy = #lines*length_of_line
	beq.s	an_rts

	movem.l	d0/d1,-(sp)	;-d2/a0-a3,-(sp)
					;d0(sp)=#bytes d1,4(sp)=offset_start

	lea	(6*4)+bm_Planes(a0),a2	;from bitmap
	lea	(6*4)+bm_Planes(a1),a3	;to   bitmap
	moveq	#(6-1),d2		;MAX #planes, loop counter
muncoppa_loop:
	move.l	-(a2),d3	;from: actual bitplane data address
	beq.s	mskipitall	;done, no bitplane
	add.l	4(sp),d3	;offset to this line
	move.l	d3,a0

	move.l	-(a3),d3	;to:  ...ditto...
	beq.s	mskipitall	;done, no bitplane
	add.l	4(sp),d3	;offset to this line
	move.l	d3,a1

	bsr.s	QUICKCopy	;preserves ALL registers
	dbf	d2,muncoppa_loop
mskipitall:
	movem.l	(sp)+,d0/d1	;d0-d2/a0-a3
	moveq	#0,d0	;ZERO=success
	rts

copy48:	macro	;(preserves d0)
	movem.l	(a0)+,d1-d7/a2-a6 ;12+8n 12+96   108 cy       12long/48 bytes
	movem.l	d1-d7/a2-a6,(a1)	;108
	lea	48(a1),a1		;8 = 248 cycles to move 48 bytes?
	endm

copy48o:	macro	;\1=offset for a1
	movem.l	(a0)+,d1-d7/a2-a6 	;108cy 4 bytes
	movem.l	d1-d7/a2-a6,\1(a1)	;112cy 6 bytes
	endm

copy384:	macro ;384 bytes, 8*48apiece (preserves d0)
	;copy48
	movem.l	(a0)+,d1-d7/a2-a6 ;12+8n=108 cy   12long/48 bytes
	movem.l	d1-d7/a2-a6,(a1)  ;12+8n=108 cy
	copy48o (1*48)		  ;16+8n=112cy+108=220cy total
	copy48o (2*48)
	copy48o (3*48)

	copy48o (4*48)
	copy48o (5*48)
	copy48o (6*48)
	copy48o (7*48)		;so far...1540+108+108+8=1764 cycles
	lea	384(a1),a1	;...to move 384 bytes (roughly 11cycles/word)
    endm

QUICKCopy:	;d0=count, a0=from address a1=to adr
	movem.l	d0-d7/a0-a6,-(sp)

	cmp.L	#48+1,d0
	bcs.s	qclast

	move.l	#384,-(sp)
	bra.s	qccklp
copyfirstloop:
	copy384	;70+8+4= 92codebytes ('020 cache consideration)
qccklp:
	sub.L	(sp),d0		;14cy (macro preserve'd d0)
	bcc.s	copyfirstloop
	add.L	(sp)+,d0
qclast
	sub.W	#48,d0
	bcs.s	qc_finalones
copy48loop:
	copy48			;macro preserves d0, bumps a0,a1
	sub.W	#48,d0
	bcc.s	copy48loop	;!BLEAH THIS GOES OVER?
qc_finalones:
	add.W	#48,d0
	asr.w	#2,d0	;/4
	subq.w	#1,d0	;#4,d0	;fix loop end test
	bcs.s	endof_copy	;else copy d0+1 long words
copy1:	move.L	(a0)+,(a1)+
	dbf	d0,copy1
endof_copy:
	movem.l	(sp)+,d0-d7/a0-a6
	rts


 END 
