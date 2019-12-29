*********************************************************************
* vthand.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: vthand.i,v 2.9 93/05/08 19:03:26 Kell Exp $
*
* $Log:	vthand.i,v $
*Revision 2.9  93/05/08  19:03:26  Kell
**** empty log message ***
*
*Revision 2.8  93/04/17  08:08:01  Kell
**** empty log message ***
*
*Revision 2.7  93/04/03  11:11:59  Kell
*Changed COPINITDONE from line 8 to line 12.
*
*Revision 2.6  93/03/25  06:23:56  Kell
*SuperSimpleBitMap structure defined and added to EFB_
*
*Revision 2.5  93/03/18  15:14:16  Kell
*ECD_stucture is now NULL.  Move SMALLWRITEBUFFER to top of ChipMem
*
*Revision 2.4  93/03/11  17:06:52  Kell
*Removed WarpPresets but instead now have 6 planes used by ReadScanLine and ReadScatter.
*
*Revision 2.3  93/02/13  14:30:53  Kell
*Docs on ULONG color values
*
*Revision 2.2  92/12/17  17:57:12  Kell
*Changed BPLCON0_DEPTHx equates for A2000/A4000 BPLCON0 fixes
*
*Revision 2.1  92/11/12  19:21:39  Kell
*Added ViewModes to the SetUpSimpleBMCopList structure.
*
*Revision 2.0  92/05/18  21:24:50  Hartford
**** empty log message ***
*
*********************************************************************
* Include stuff used by Skells VideoToasterHandler
* Fri. 13, Oct 1989      NewTek, Inc.
******************************************************

	IFND	VTHAND_I
VTHAND_I	SET	1

;;ROWZEROODD	SET  1		;row 0 is considered odd


* used by FreezeThaw Routine
CERB_OFF EQU	0
ABSE_OFF EQU	1

* use this in TB_VideoFlagPri (Sec) 
VIDEOTYPE_LIVE		EQU	0
VIDEOTYPE_FREEZE4	EQU	((1<<ABSE_OFF)!(1<<CERB_OFF))
VIDEOTYPE_FREEZE8	EQU	(1<<CERB_OFF)
VIDEOTYPE_MIXED		EQU	(1<<ABSE_OFF)

* used to set TB_BPLCON0
BPLCON0_NOCHANGE EQU	0	;used to lock out softsprite BPLCON0 stuff

NEWDENISE EQU	%000001		;new value for bplcon3

BPLCON0_DEPTH0	EQU	%1000000000000000	
BPLCON0_DEPTH1	EQU	%1001000000000000
BPLCON0_DEPTH2	EQU	%1010000000000000
BPLCON0_DEPTH3	EQU	%1011000000000000
BPLCON0_DEPTH4	EQU	%1100000000000000
BPLCON0_DEPTH5	EQU	%1101000000000000
BPLCON0_DEPTH6	EQU	%1110000000000000
BPLCON0_DEPTH7	EQU	%1111000000000000
BPLCON0_DEPTH8	EQU	%1000000000010000

*************************************************
SPRITE0CTRL241	EQU	$152d0603
SPRITE1CTRL241	EQU	$152d0683
*************************************************

SPRITEHEIGHT	EQU 241		;#of rows in a standard toaster sprite
SPRITESIZEOF	EQU 241*4+8	;#bytes for a standard toaster sprite
SPRITEBUFFSIZE	EQU 244		;#bytes in sprite byte buffer (mult of 4)
BITMAPBUFFSIZE	EQU 184		;#bytes in a byte BM buffer (mult of 4)
BYTE2BMLUTSIZE  EQU 65536	;#bytes in one of the two Byte2BM Luts
BMBYTESPERROW	EQU 96		;#bytes in one BitMap row, ie ScaleX bm

* This used to be 8 before version 2.0 and before AA coplists
COPINITDONE	EQU 12		;No coplatch and Sprite0/1 ptrs will be 
				;altered by coplist at this line and beyond.

* Bytes2Sprite1 Type, used to make sprite non-transparent, by turning BLUE on.
* Used by Bytes2Sprite1()
B2SNORM	 EQU	0	
B2SELH	 EQU	$F0000000
B2S12BIT EQU	$FF000000	
B2S16BIT EQU	$FFF00000

* LW_Nibble values, used by DoLineWrite()
;;WNIBL	EQU	%00	;currently not available
WNIBH	EQU	%00
WNIBNN	EQU	%01
WNIBHL	EQU	%10	;for 8 bit writes, use this.

* Saved in TB_CurrentInstallField 
FIELDI		EQU	%0001
FIELDI_II	EQU	%0011
FIELDI_III	EQU	%0101
FIELDANY	EQU	%0000
FIELDITHRUIV	EQU	%1111

	IFD	CRAP	;with new elh stuff, this isn't necessary.
*********************************************************
* Sprite1ToELH Type, used to make sprite non-transparent, by turning BLUE on.
* Used by Sprite1ToELH()
S2ENORM	 EQU	$0F000000	
S2E8BIT  EQU	$0FF00000	
S2E12BIT EQU	$0FFF0000
	ENDC

************************************************************
* Used to get a current pointer from a DoubleBuffer structure
* Normally, this returns a pointer to something that can now be altered
* ie. a CopperList that is not currently being displayed.
GETCURRENT	MACRO	;addressreg->DoubleBuffer
	adda.w	(\1),\1        ;add 0 or 4 
	movea.l	DB_Data(\1),\1 
	ENDM

************************************************************
* Used to get a current pointer from a DoubleBuffer structure
* Normally, this returns a pointer to something that can now be altered
* ie. a CopperList that is not currently being displayed.
GETCURRENTANDFLIP	MACRO	;addressreg->DoubleBuffer
	move.l	\1,-(sp)
	GETCURRENT	\1
	move.l	\1,-(sp)
 	movea.l	4(sp),\1
	FLIPCURRENT	\1
	movea.l	(sp),\1
	addq.w	#8,sp
	ENDM

************************************************************
* Used to get a current pointer from a DoubleBuffer structure
* Normally, this returns a pointer to something that can not be altered
* ie. a CopperList that is currently being displayed.
GETNONCURRENT	MACRO	;addressreg->DoubleBuffer
	move.w	d0,-(sp)
	move.w	(\1),d0
	eori.w	#4,d0
	movea.l	DB_Data(\1,d0.w),\1
	move.w	(sp)+,d0 
	ENDM

************************************************************
* Compliment a "current" value
FLIPCURRENT	MACRO	;address reg that ->current WORD location
		bchg.b	#2,1(\1) ;0 or 4, where \1 = 1(a0) or (a0)->lsb
		ENDM

************************************************************
* Compliment a "current" value
FLIPCURRENTM	MACRO	;address that contains current WORD location
		 IFND \1
		   XREF \1
	         ENDC
		bchg.b	#2,\1+1  ;0 or 4
		ENDM

************************************************************
SETSPRITEVSTART_R  MACRO	;address reg ->sprite, data reg with value
	move.b	\2,(\1)
	ENDM

SETSPRITEVSTART_I  MACRO	;address reg ->sprite, immediate value
	move.b	#\2,(\1)
	ENDM

************************************************************
* Use this with Clear/Set/Not ELH routines, and FillSprite
* before you call those routines, to create a value.
ELHValue MACRO	;green,  red, reg to hold value (usually d1 logic, d0 fill)
	move.l	#(((\2)<<24)!((\1)<<8)),\3
	ENDM

********************************************************
	STRUCTURE	DoubleBuffer,0
	  WORD		DB_Current	;this will alway be 1st field
	  WORD		pad		;long word align ????
	 LABEL	       DB_Data
	  APTR		DB_DataA
	  APTR		DB_DataB
	LABEL	DB_SIZEOF

********************************************************
* Used to keep track of 4 entry point in a 4 field copperlist.
* Used by InstallFieldIthruIV
	STRUCTURE	FourFieldTBL,0
	  LONG	 FFTBL_Latch
	 LABEL	FFTBL_Tbl
	  LONG   FFTBL_I
	  LONG 	 FFTBL_II
	  LONG   FFTBL_III
	  LONG   FFTBL_IV
	LABEL	FFTBL_SIZEOF

********************************************************
	STRUCTURE	SetUpDVE,0
;Double Buffered Stuff
		APTR	SUDVE_DBSprite0E ;entry sprites, 1st field
		APTR	SUDVE_DBSprite1E
		APTR	SUDVE_DBSprite0R ;repeat sprites, any future fields
		APTR	SUDVE_DBSprite1R

		APTR	SUDVE_DBCopLists
		APTR	SUDVE_DBPlanePtrs  ;WORD **PlanePtrs[]
*currently, each set only contains 2 plane pointers (non-XY effects).
*And for DVECopList1, I only have 2 sets; effect lines, null lines.

		APTR	SUDVE_Scroll	;array of horiz. scroll amounts
		APTR	SUDVE_BitMapList ;UWORD array,
* = the elements to use in the above array of geometry planes.
		APTR	SUDVE_CompBitMapList
* Same as a BitMapList, but in a compressed format.

		APTR	SUDVE_Spr0Tbl ;->table of SPR0 instruction offsets

	LABEL	SUDVE_SIZEOF

********************************************************
	STRUCTURE	SetUpAVE,0
;Double Buffered Stuff
		APTR	SUAVE_DBSprite0E ;entry sprites, 1st field
		APTR	SUAVE_DBSprite1E
		APTR	SUAVE_DBSprite0R ;repeat sprites, any future fields
		APTR	SUAVE_DBSprite1R
		APTR	SUAVE_DBCopLists
		APTR	SUAVE_Spr0Tbl ;->table of SPR0 instruction offsets
	LABEL	SUAVE_SIZEOF

********************************************************
	STRUCTURE	SetUpSBM,0
		APTR	SUSBM_DBCopLists
		APTR	SUSBM_SprTbl ;->table of SPR0/SPR1 instruction offsets

* The remaining stuff is usually filled out once per effect/operation
		APTR	SUSBM_DBSprite0E ;entry sprites, 1st field
		APTR	SUSBM_DBSprite1E
		APTR	SUSBM_DBSprite0R ;repeat sprites, any future fields
		APTR	SUSBM_DBSprite1R
		STRUCT	SUSBM_DBPlanes,DB_SIZEOF

* On non AA chip machines the ColorMap is a table of RGB UWORDS.
* On AA chip machines the ColorMap is a table of ULONGS, each with the
* following nibbles: 0 RH GH BH 0 RL GL BL, which I call a "Hardware" Color.
* If you have a ULONG representing a "Software" color of the
* format 0 0 RH RL GH GL BH BL, it may be converted into a "Hardware" Color
* by CALLTL Soft2HardColor(color).

		APTR	SUSBM_ColorMap
		WORD	SUSBM_Depth	;0-4
		WORD	SUSBM_BMwidth	
		WORD	SUSBM_CRTwidth	;display width, may not = BM width
					;=768, 752, 736, 384, or 368
		WORD	SUSBM_Modulo
		UWORD	SUSBM_ViewModes	;V_HAM & V_EXTRA_HALFBRITE
	LABEL	SUSBM_SIZEOF

*********************************************************
* Setup Super Simple BitMap CopList.
* This is used by the SetupSSBM routine.

	STRUCTURE	SetUpSSBM,0			
	   APTR	SSBM_BitMap
	   APTR	SSBM_ColorTable	  ;LONGs on AA, WORDS on nonAA machines
	   APTR	SSBM_Sprite1	  ;may be NULL
	   APTR	SSBM_ELHList	  ;may be NULL 
	   WORD	SSBM_SourceX	  ;140/70ns pixel X offset into BM
	   WORD	SSBM_SourceY	  ;pixel Y offset into BM

* On non-AA machines the SourceWidth/Height are ignored.  Bitmap data will
* be shown throughout the entire DestinationWidth/Height!
	   WORD	SSBM_SourceWidth  ;rectangles 140/70ns pixel width may be < BM width, may be cropped by Display
	   WORD	SSBM_SourceHeight ;rectangle height may be < BM height, may be cropped by Display

* On non-AA machines the DestinationX/Y should be zero!
	   WORD	SSBM_DestinationX 	;35ns AA or 140ns nonAA pixel X offset into overscan display
	   WORD	SSBM_DestinationY 	;pixel Y offset into overscan display
	   WORD	SSBM_DestinationWidth   ;display 140/70ns pixel width (usually 384 or 768)
	   WORD	SSBM_DestinationHeight  ;display height (usually 241)
	   WORD	SSBM_Modulo		;used to skip over rows on 2 field data	
	   WORD	SSBM_ViewModes		;HIRES, HAM, etc.
	LABEL	SSBM_SIZEOF

*********************************************************
* Used as a Compressed BitMap List, as used by DVE1 effects.
	STRUCTURE	DVE1CompBmList,0
	  BYTE	DVE1CBML_TopBM		;0
	  UBYTE DVE1CBML_TopRows	;0-241
	  BYTE	DVE1CBML_MiddleBM	;1
	  UBYTE DVE1CBML_MiddleRows	;0-241
	  BYTE	DVE1CBML_BottomBM	;0
	  UBYTE DVE1CBML_BottomRows	;0-241
	  BYTE  DVE1CBML_terminator	;-1
	  BYTE  DVE1CBML_pad		;0
	LABEL	DVE1CBML_SIZEOF

*********************************************************
* Used as a Compressed BitMap List, as used by Wipe1 effects.
	STRUCTURE	Wipe1CompBmList,0
	  WORD	Wipe1CBML_TopBM		;0/1
	  UWORD Wipe1CBML_TopRows	;0-482
	  WORD  Wipe1CBML_MiddleBM	;2
	  UWORD Wipe1CBML_MiddleRows	;0-482
	  WORD	Wipe1CBML_BottomBM	;0/1
	  UWORD Wipe1CBML_BottomRows	;0-482
	  WORD  Wipe1CBML_terminator	;-1
	LABEL	Wipe1CBML_SIZEOF

	IFD CRAP ;-----------------------------------
* KEEP THIS STRUCTURE, AROUND EVEN THOUGH I MAY NOT USE IT
*********************************************************
* This structure is used to keep track of double buffered
* data areas.  Any pointers that are not double buffered, should
* have both pointers pointing to the same place.  
* The Current WORDs = 0 or 4, and indicate which data is usable.

	STRUCTURE	FieldData,0
	 LABEL	FD_Sprite0
	  APTR		FD_Sprite0A
	  APTR		FD_Sprite0B
	  WORD		FD_CurrentSprite0

	 LABEL	FD_Sprite1
	  APTR		FD_Sprite1A
	  APTR		FD_Sprite1B
	  WORD		FD_CurrentSprite1
	 
	 LABEL	FD_CopList
	  APTR		FD_CopListA
	  APTR		FD_CopListB
	  WORD		FD_CurrentCopList

;This could point to an array of plane pointers, or
;to an array of ptrs to arrays of plane ptrs????
;e.g. *WORD[], or *(*WORD[])[]  
	 
         LABEL  FD_Planes
	  APTR		FD_PlanesA
	  APTR		FD_PlanesB
	  WORD		FD_CurrentPlanes
	LABEL	FD_SIZEOF
   ENDC ;--------------------------------------

*********************************************************
* Used by DoBlockWrite routine
	STRUCTURE	BlockWrite,0
* -> DoubleBuffer structures
	  APTR		BLW_DBSprites0	
	  APTR		BLW_DBSprites1
	  APTR		BLW_DBCopLists	;FieldWriteCopLists
	LABEL	BLW_SIZEOF

*********************************************************
* Used by DoLineWrite routines
	STRUCTURE	LineWrite,0
	  APTR		LW_Lines
	  APTR		LW_BuffY

* -> DoubleBuffer structures
	  APTR		LW_DBSprites0	
	  APTR		LW_DBSprites1
	  APTR		LW_DBCopLists	;FieldWriteCopLists
	  APTR		LW_DBPlanes	;may not actually be double buffered

	  APTR		LW_AfterCopList
	  UBYTE		LW_ActiveSync
	  UBYTE		LW_Field
	  UBYTE		LW_Bank
	  UBYTE		LW_Nibble	;uses WNIB flags
	LABEL	LW_SIZEOF

**********************************************
* Used by FieldWrite routines
	STRUCTURE	FieldWrite,0
	  APTR		FW_Sprite0
	  APTR		FW_Sprite1
	  APTR		FW_CopList
	  APTR		FW_Planes

	  APTR		FW_AfterCopList
	  WORD		FW_PixelsWide	;0 if SAWrite
	  UBYTE		FW_ActiveSync	;Active/sync/zipper, 0=active
	  UBYTE		FW_pad
	LABEL	FW_SIZEOF

**********************************************
* There is a buffer of this size used by WriteYIQBlockAVEI, and SendBytes2ToasterAVEI
* It is at the Top of chip memory, at the end of the FrameLoading buffer.
SMALLWRITEBUFFERSIZE	EQU ((768/8)*4*4*4) ;6144 bytes

**********************************************
	STRUCTURE	EffectsChipData,0
* SpriteData

		IFD	DYNAMICSPRITES
	  STRUCT	ECD_Sprite0Live,SPRITESIZEOF
	  STRUCT	ECD_Sprite0Freeze,SPRITESIZEOF
	  STRUCT	ECD_Sprite1Linear,SPRITESIZEOF	;used by Read

;;	  STRUCT	ECD_DVESprite0A,SPRITESIZEOF
;;	  STRUCT	ECD_DVESprite0B,SPRITESIZEOF

	  STRUCT	ECD_DVESprite1A,SPRITESIZEOF
	  STRUCT	ECD_DVESprite1B,SPRITESIZEOF

	  STRUCT	ECD_VTSprite0A,SPRITESIZEOF
	  STRUCT	ECD_VTSprite0B,SPRITESIZEOF

	  STRUCT	ECD_VTSprite1A,SPRITESIZEOF
	  STRUCT	ECD_VTSprite1B,SPRITESIZEOF

	  STRUCT	ECD_ELHSprite0A,SPRITESIZEOF
	  STRUCT	ECD_ELHSprite0B,SPRITESIZEOF

	  STRUCT	ECD_ELHSprite1A,SPRITESIZEOF
	  STRUCT	ECD_ELHSprite1B,SPRITESIZEOF

	  STRUCT	ECD_SpriteNull,8
		ENDC

* The following buffer is used by WriteYIQBlockAVEI, and SendBytes2ToasterAVEI
* I moved this to the Top of chip memory, at the end of the FrameLoading buffer.
;;;	  STRUCT	ECD_SMALLWRITEBUFFER,(768/8)*4*4*4 ;6144 bytes

	LABEL	ECD_SIZEOF

*************************************************************
	STRUCTURE	EffectsSpriteData,0
* SpriteData
	  STRUCT	ESD_Sprite0LiveA,SPRITESIZEOF
	  STRUCT	ESD_Sprite0LiveB,SPRITESIZEOF
	  STRUCT	ESD_Sprite0FreezeA,SPRITESIZEOF
	  STRUCT	ESD_Sprite0FreezeB,SPRITESIZEOF

;;	  STRUCT	ESD_DVESprite0A,SPRITESIZEOF
;;	  STRUCT	ESD_DVESprite0B,SPRITESIZEOF

	  STRUCT	ESD_DVESprite1A,SPRITESIZEOF
	  STRUCT	ESD_DVESprite1B,SPRITESIZEOF

	  STRUCT	ESD_VTSprite0A,SPRITESIZEOF
	  STRUCT	ESD_VTSprite0B,SPRITESIZEOF

	  STRUCT	ESD_VTSprite1A,SPRITESIZEOF
	  STRUCT	ESD_VTSprite1B,SPRITESIZEOF

	  STRUCT	ESD_ELHSprite0A,SPRITESIZEOF
	  STRUCT	ESD_ELHSprite0B,SPRITESIZEOF

	  STRUCT	ESD_ELHSprite1A,SPRITESIZEOF
	  STRUCT	ESD_ELHSprite1B,SPRITESIZEOF

	  STRUCT	ESD_SpriteNull,8
	  STRUCT	ESD_Sprite1Linear,SPRITESIZEOF	;used by Read
	LABEL	ESD_SIZEOF
*************************************************

	STRUCTURE	EffectsFastData,0	  
*GeometryByteBuffers
	  STRUCT	EFD_BuffX,BITMAPBUFFSIZE*2  ;big enough for pairs
	  STRUCT	EFD_BuffY,SPRITEBUFFSIZE

*Buffers you may use for any temporary use (e.g. storing encoded byte data)
	  STRUCT	EFD_BuffA,768*2	
	  STRUCT	EFD_BuffB,768*2	

*Bytes2BmLUT
	   LABEL  EFD_Bytes2BmLUT
	 STRUCT		EFD_Bytes2BmLUTL,BYTE2BMLUTSIZE
	 STRUCT		EFD_Bytes2BmLUTH,BYTE2BMLUTSIZE
	LABEL	EFD_SIZEOF

**************************************************

	STRUCTURE	EffectsBase,0

	  APTR		EFB_CHIPDataMem		;what effects use, dynamic
	  APTR		EFB_FASTDataMem		;what effects use, dynamic
	  APTR		EFB_SpriteData		;CHIP Section, static

* Double Buffered Stuff

;;* Sprites used by Line Writing, (and someday DVE maybe)
;;	  STRUCT	EFB_DVESprites0,DB_SIZEOF

* Both AVE and DVE use the DVESprites1
	  STRUCT	EFB_DVESprites1,DB_SIZEOF

* General purpose trashable Sprites
	  STRUCT	EFB_VTSprites0,DB_SIZEOF
	  STRUCT	EFB_VTSprites1,DB_SIZEOF

* Sprites used by ELH dumps
	  STRUCT	EFB_ELHSprites0,DB_SIZEOF
	  STRUCT	EFB_ELHSprites1,DB_SIZEOF

* Constant Sprites used by DVE & AVE
	  STRUCT	EFB_Sprite0Live,DB_SIZEOF
	  STRUCT	EFB_Sprite0Freeze,DB_SIZEOF
	  STRUCT	EFB_NullSprites,DB_SIZEOF	;only DBered for consistency

	  STRUCT	EFB_DVE1CopLists,DB_SIZEOF
	  STRUCT	EFB_DVE2CopLists,DB_SIZEOF
	  STRUCT	EFB_DVEI1CopLists,DB_SIZEOF
	  STRUCT	EFB_WipeI1CopLists,DB_SIZEOF
	  STRUCT	EFB_FieldWriteCopLists,DB_SIZEOF
	  STRUCT	EFB_AVECopLists,DB_SIZEOF	;DBed for LUTeffects
	  STRUCT	EFB_AVEICopLists,DB_SIZEOF	;DBed for LUTeffects
	  STRUCT	EFB_SafeWriteCopLists,DB_SIZEOF
	  STRUCT	EFB_SimpleBMCopLists,DB_SIZEOF
	  STRUCT	EFB_TwoFICopLists,DB_SIZEOF	;DBed for LUTeffects

	  STRUCT	EFB_LWPlanes,DB_SIZEOF   ;used by LineWrites	  

	  STRUCT	EFB_TempDB1,DB_SIZEOF	;spare DB (used by InstallSSBM)
	  STRUCT	EFB_TempDB2,DB_SIZEOF	;spare DB (not currently used)
*----------	 
	  STRUCT	EFB_BlockWrite,BLW_SIZEOF
	  STRUCT	EFB_LineWrite,LW_SIZEOF	 
	  STRUCT	EFB_FieldWrite,FW_SIZEOF  ;This is used by DoLineWrite, DoBlockWrite and Frame Loading routines 

	  STRUCT	EFB_SetUpDVE,SUDVE_SIZEOF	
	  STRUCT	EFB_SetUpDVEI,SUDVE_SIZEOF
	  STRUCT	EFB_SetUpDVE2,SUDVE_SIZEOF	
	  STRUCT	EFB_SetUpWipeI,SUDVE_SIZEOF
	  STRUCT	EFB_SetUpAVE,SUAVE_SIZEOF
	  STRUCT	EFB_SetUpAVEI,SUAVE_SIZEOF	
	  STRUCT	EFB_SetUpSBM,SUSBM_SIZEOF	
	  STRUCT	EFB_SetUp2FI,SUAVE_SIZEOF	
	  STRUCT	EFB_SSBM,SSBM_SIZEOF	

	  STRUCT	EFB_DVE1CompBmList,DVE1CBML_SIZEOF
	  STRUCT	EFB_Wipe1CompBmList,Wipe1CBML_SIZEOF

	LABEL	EFB_Bytes2BmLUT
	  APTR		EFB_Bytes2BmLUTL	
	  APTR		EFB_Bytes2BmLUTH	

	  APTR		EFB_BuffX
	  APTR		EFB_BuffY
	  APTR		EFB_BuffA
	  APTR		EFB_BuffB
	
	  APTR		EFB_CurrentCopperList	;put this in TB !!!!!
	  BYTE		EFB_CurrentInstallField	;put this in TB !!!!!
	  STRUCT	EFB_pad,3	

;--------	
* DVE stuff
* Since effects are double buffered, here are two sets of BMs, A and B
	  STRUCT	EFB_DVEPlanes,DB_SIZEOF  ;->EFB_BMPlanesA/B

* Pointers to set A BMs
	LABEL EFB_BMPlanesA
	  APTR		EFB_Planes0A	;-> BM0's 2 (4) planes, set A (preset 2), Null row
	  APTR		EFB_Planes1A	;-> BM1's 2 (4) planes, set A (preset 3), Geometry row
*	etc. for more complicated effects, BM2, BM3 ......
	
* Pointers to set B BMs
	LABEL EFB_BMPlanesB
	  APTR		EFB_Planes0B	;-> BM0's 2 (4) planes, set B (preset 2), Null row
	  APTR		EFB_Planes1B	;-> BM1's 2 (4) planes, set B (preset 3), Geometry row
*	etc. for more complicated effects, BM2, BM3 ......
	
* DVE Effects use two (or four) planes for horizontal control.  They are indicated by
* L or H.  Effects usually need a Null row and a Geometry row, indicated by
* BM0 or BM1.  Fancy effects, e.g. Perspective tumbles, would require more
* BMs.  All effects are double buffers, indicated by A or B
* These planes are used by DVE effects.
	 LABEL	EFB_BM0PlanesA
	  APTR		EFB_BM0PlaneLA	;->an actual bit plane
	  APTR		EFB_BM0PlaneHA
	  APTR		EFB_BM0PlaneL2A	;->an actual bit plane
	  APTR		EFB_BM0PlaneH2A
	 LABEL	EFB_BM1PlanesA
 	  APTR		EFB_BM1PlaneLA
	  APTR		EFB_BM1PlaneHA
 	  APTR		EFB_BM1PlaneL2A
	  APTR		EFB_BM1PlaneH2A
	 LABEL	EFB_BM0PlanesB
	  APTR		EFB_BM0PlaneLB
	  APTR		EFB_BM0PlaneHB
	  APTR		EFB_BM0PlaneL2B
	  APTR		EFB_BM0PlaneH2B
	 LABEL	EFB_BM1PlanesB
	  APTR		EFB_BM1PlaneLB
	  APTR		EFB_BM1PlaneHB
	  APTR		EFB_BM1PlaneL2B
	  APTR		EFB_BM1PlaneH2B

*---------------------
* Wipe Stuff
* Since effects are double buffered, here are two sets of BMs, A and B
	  STRUCT	EFB_WipePlanes,DB_SIZEOF  ;->EFB_BMPlanesA/B

* Pointers to set A BMs
	LABEL EFB_BMWipe1A
	  APTR		EFB_Wipe0A	;-> BM0's  planes, set A (preset 2), Null row
	  APTR		EFB_Wipe1A	;-> BM1's  planes, set A (preset 3), Geometry row
	  APTR		EFB_Wipe2A	;-> BM2's  planes, set A (preset 3), Geometry row
*	etc. for more complicated effects, BM2, BM3 ......
	
* Pointers to set B BMs
	LABEL EFB_BMWipe1B
	  APTR		EFB_Wipe0B	;-> BM0's  planes, set B (preset 2), Null row
	  APTR		EFB_Wipe1B	;-> BM1's  planes, set B (preset 3), Geometry row
	  APTR		EFB_Wipe2B	;-> BM2's  planes, set B (preset 3), Geometry row
*	etc. for more complicated effects, BM2, BM3 ......

* These planes are used by Wipe effects.
	 LABEL	EFB_BM0Wipe1A
	  APTR		EFB_BM0Wipe1LA	;->an actual bit plane
	 LABEL	EFB_BM1Wipe1A
	  APTR		EFB_BM1Wipe1LA
	 LABEL	EFB_BM2Wipe1A
	  APTR		EFB_BM2Wipe1LA	;->an actual bit plane

	 LABEL	EFB_BM0Wipe1B
	  APTR		EFB_BM0Wipe1LB	;$ffff... plane(s)
	 LABEL	EFB_BM1Wipe1B
	  APTR		EFB_BM1Wipe1LB	;$0000... plane(s) 
	 LABEL	EFB_BM2Wipe1B
	  APTR		EFB_BM2Wipe1LB  ;effect plane(s)


	IFD	NEEDWARPPRESETS
* I Killed the WarpPresets because they are only useful in algrithmically
* generated warps / perspective flips, and we probably will never attempt
* to do this, now that Anims are used so heavily.

;----------------------------------------
* 512 4 plane DVE presets - room for ReadScanLine, ReadScatter presets.
* NOTE: It is weak to include this in TB, these tables should be in the
* fastmem chunk????!!!!!  Also, since all of the upper words of each pointer
* is the same for a given plane, this is wasteful.  The table shouldn't
* really be necessary since these addresses can easily be calculated.
* Also these are just blanks, so it wastes program code space!!!!!!!

	  STRUCT	EFB_WarpPresets,512*4	
	  STRUCT	EFB_WarpPlanes,512*4*4	

* where A, B, C, D = start of 4 memory planes where each plane
* is within a 64K block of memory. W = bytesprerow = 96
* arranged as	BM0L			at A
*	     	BM0H			at B
*		BM0L2	;for pairs	at C
*		BM0H2	;for pairs	at D
*
*		BM1L			at A+W
*		BM1H			at B+W
*		BM1L2	;for pairs	at C+W
*		BM1H2	;for pairs	at D+W
*
*		 .......
*
*		BM255L			at A+255*W
*		BM255H			at B+255*W
*		BM255L2	;for pairs	at C+255*W
*		BM255H2	;for pairs	at D+255*W

	ENDC	;IFD NEEDWARPPRESETS

* Currently These Planes are 768x216 pixels in size.  They are used
* by the ReadScanLine routine.
	
	 LABEL	EFB_ReadPlanesA
	  APTR		EFB_ReadPlane0A
	  APTR		EFB_ReadPlane1A 

* A ptr to ReadPlane1A - 2 is stashed in EFB_CHIPDataMem, which is the
* bottom of my chip chunk usage.

* These readscatter BMs are only one scan line high!!
* Used by ReadScatter at startup time for AutoHue
	 LABEL	EFB_ReadPlanesB
	  APTR		EFB_ReadPlane0B	
	  APTR		EFB_ReadPlane1B

* Used by ReadScatter at startup time for AutoHue
	 LABEL	EFB_ReadPlanesC
	  APTR		EFB_ReadPlane0C
	  APTR		EFB_ReadPlane1C

	LABEL	EFB_SIZEOF	

READPLANESIZE	EQU	((768/8)*216)	;20736 bytes

	ENDC	;VTHAND_I
