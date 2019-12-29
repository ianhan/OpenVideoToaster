********************************************************************
* LUTEqu.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: LUTEqu.i,v 2.7 1993/05/11 15:53:43 Finch2 Exp $
*
* $Log: LUTEqu.i,v $
*Revision 2.7  1993/05/11  15:53:43  Finch2
**** empty log message ***
*
*Revision 2.6  93/05/05  10:30:37  Finch2
**** empty log message ***
*
*Revision 2.5  93/05/04  17:27:51  Finch2
**** empty log message ***
*
*Revision 2.2  93/03/19  15:45:26  Kell
*NUMQUADS now 192 vs old 184. New EQU NUMQUADSDATA is 184.
*
*********************************************************************
	PAGE
*************************************************************************
*									*
*	LUTEqu:								*
*									*
*	Contains the Global Definitions for the LUT Procedure.		*
*									*
*	08.Mar 1990 Jamie L. Finch.					*
*									*
*************************************************************************
*
TBCF_Enable	EQU	0		; Toaster Base Enable Flag.
TBARSLIDESIZE	EQU	86		; Number of Units In TBar - 2.
*
*	Prior to 19-Mar-93 NUMQUADS=184, and NUMQUADSDATA didn't exist.
*
NUMQUADSDATA	EQU	184		; Number of 280ns Pixels.
					; This is the width of the data to
					; generate and write, though it
					; will be on a wider BM
NUMQUADS	EQU	192		; Number of 280ns Pixels / row of BM
*
*	Number Text Position.
*
NUMBERTEXT_X	EQU	72		; Number Text x Position.
NUMBERTEXT_Y	EQU	56		; Number Text y Position.
*
GRIDTEXT_Y	EQU	86		; Grid Text y  Position.
GRIDTEXT_X1	EQU	320		; Grid Text x1 Position.
GRIDTEXT_X2	EQU	GRIDTEXT_X1+48	; Grid Text x2 Position.
GRIDTEXT_X3	EQU	GRIDTEXT_X2+48	; Grid Text x3 Position.
GRIDTEXT_X4	EQU	GRIDTEXT_X3+48	; Grid Text x4 Position.
*
*	Window Flags.
*
LUT_IDCMP_FLAGS	EQU GADGETDOWN!MOUSEBUTTONS!RMBTRAP!RAWKEY!DISKINSERTED!DISKREMOVED
LUT_PickLeft	EQU	64		; Pick Area Left Edge.
*
LUT_EditBufSz	EQU	96		; Number of Colors In Buffer.
LUT_EditBufLn	EQU	LUT_EditBufSz*3	; Number of Bytes  In Buffer.
*
LUT_EditMarkBWd	EQU	2*(LUT_EditBufSz+4) ; Width of One Line In Bytes.
LUT_EditMarkHi	EQU	8		; Number of Lines High.
LUT_EditMarkLn	EQU	LUT_EditMarkBWd*LUT_EditMarkHi
*
*	Color Definitions.
*
LUT_PhaseMask	EQU	$A5		; Video Phase Mask $96 | $A5.
LUT_PhaseAdd	EQU	$01		; Video Phase Add  $00 | $01.
IREBlack  EQU	071			; IRE  Black Level.
YIQBlack  EQU	IREBlack<<16		; 0YIQ Black.
YIQWhite  EQU	200<<16			; 0YIQ White.
QUADBlack EQU	(IREBlack<<24)!(IREBlack<<16)!(IREBlack<<8)!IREBlack ;Quad Black
*
*	LUT Structure Constants.
*
LUT_CheckConst	EQU	('L'<<24)!('U'<<16)!('T'<<8)!1 ; LUT Check Value.
*
*	Display Mode Flags.
*
LUTM_SMF	EQU	$03		; SMF   Mask.
LUTM_CYCLE	EQU	$0C		; Cycle Mask.
LUTF_TRANSITION	EQU	5		; 1 = Transition, 0 = Filter.
LUTF_FULLPOSTER	EQU	6		; No / Full Poster Flag.
LUTF_BWVIDEO	EQU	7		; BW / Color Video Flag.
*
*	LUT Flags Structure.
*
LUTF_MapChange	EQU	0		; 0 = No Change,    1 = Change.
LUTF_SendDVE0	EQU	1		; 0 = Don't Set,    1 = Send to DVE0.
LUTF_GridAssign	EQU	2		; 0 = Was Not Just, 1 = Just Assigned.
*
*	LUT Base Structure.
*
LUT_CheckVal	EQU	0		; ( 4 ) LUT Check Value.
LUT_PosterPos	EQU	LUT_CheckVal+4	; ( 1 ) Posterization Position 0 to 255.
LUT_InterPos	EQU	LUT_PosterPos+1	; ( 1 ) Interplate Position 0 to 6.
LUT_DisplayMode	EQU	LUT_InterPos+1	; ( 1 ) Display Mode, SMF, TBar, Line.
LUT_Flags	EQU	LUT_DisplayMode+1 ;(1 ) Flags.
LUT_LocalTBar	EQU	LUT_Flags+1	; ( 2 ) Current TBar Position.
LUT_PAD		EQU	LUT_LocalTBar+2	; ( 14 ) Future Expansion.
LUT_Comment	EQU	LUT_PAD+14	; ( 16 ) Comment.
LUT_EditBufTop	EQU	LUT_Comment+16	; ( LUT_EditBufLn ) Edit Buffer Top.
LUT_EditBufBot	EQU	LUT_EditBufTop+LUT_EditBufLn ; ( LUT_EditBufLn ) Bottom.
LUT_EditBufPost	EQU	LUT_EditBufBot+LUT_EditBufLn ; ( LUT_EditBufLn ) Poster.
LUT_Sizeof	EQU	LUT_EditBufPost+LUT_EditBufLn ;Sizeof LUT Crouton Data.
*
*	LUT Ram Work Area.
*
LTR_FramePtr	EQU	LUT_Sizeof	; ( 4 ) Frame File Pointer.
LTR_DisplayMode	EQU	LTR_FramePtr+4	; ( 1 ) Temp Display Mode.
LTR_PAD		EQU	LTR_DisplayMode+1 ; ( 3 ) PAD.
LTR_Sizeof	EQU	LTR_PAD+3	; Sizeof LTR Frame Pointer Data.
*
*	LTE Flags Structure.
*
LTEF_EditChange	EQU	0		; 0 = No Change,	1 = Change.
LTEF_DVE0Pure	EQU	1		; 0 = Send to DVE0,	1 = Don't Send.
LTEF_DataLoaded	EQU	2		; 0 = Data Not Loaded,	1 = Loaded.
*
*	LUT Extension or Edit Structure.
*
LTE_EfBase	EQU	LTR_Sizeof	; ( 4 ) Effects Library Base.
LTE_EditRGB	EQU	LTE_EfBase+4	; ( 4 ) Edit RGB Value.
LTE_EditHSI	EQU	LTE_EditRGB+4	; ( 4 ) Edit HSI Value.
LTE_PresentLUT	EQU	LTE_EditHSI+4	; ( 4 ) Pointer to Present Edit LUT.
LTE_EditColor	EQU	LTE_PresentLUT+4 ;( 1 ) Edit Color.
LTE_Flags	EQU	LTE_EditColor+1	; ( 1 ) Flags.
LTE_RandomNu	EQU	LTE_Flags+1	; ( 2 ) Random Number Generator.
LTE_PAD		EQU	LTE_RandomNu+2	; ( 2 ) PAD.
LTE_PrvwSec	EQU	LTE_PAD+2	; ( 2 ) Prvw DAC Values.
LTE_LULPtr	EQU	LTE_PrvwSec+2	; ( 4 ) Pointer to Head of LUL Struct.
LTE_GridCrouton	EQU	LTE_LULPtr+4	; ( 4 ) Grid Crouton Assign Array.
LTE_EditMark	EQU	LTE_GridCrouton+4 ;( LUT_EditMarkLn ) Image.
LTE_Sizeof	EQU	LTE_EditMark+LUT_EditMarkLn  ; Sizeof LUT Base Struct.
*
*	LSU Startup Structure Constants.
*
LSU_CheckConst	EQU	('L'<<24)!('U'<<16)!('T'<<8)!0 ; LSU Check Value.
LSU_RamANDMask	EQU	7		; LSU Ram Pointer Mask.
*
*	LSU Startup Structure.
*
LSU_CheckVal	EQU	0		; ( 4 ) L U T NULL
LSU_RamPointer	EQU	LSU_CheckVal+4	; ( 4 ) Address of LUT Structure.
LSU_FGPointer	EQU	LSU_RamPointer+4 ;( 4 ) Address of Fast Gadget.
LSU_Sizeof	EQU	LSU_FGPointer+4	; Size of LSU Structure.
*
*	LUT Grid Structure Constants.
*
LSG_CheckConst	EQU	('L'<<24)!('U'<<16)!('T'<<8)!2 ; LSG Check Value.
LSG_RamANDMask	EQU	7		; LSG Ram Pointer Mask.
*
*	LSG Structure.
*
LSG_GridNumber	EQU	0		; ( 2 ) Grid Number Value.
LSG_PAD		EQU	LSG_GridNumber+2 ;( 6 ) Current Crouton Number.
LSG_Sizeof	EQU	LSG_PAD+6	; Size of LSG Structure.
*
*	Library Vector Offsets.
*
_LVOLUT_GridEffect	EQU	-6	; Executes Crouton's Grid Effect.
*
*	LUT Link Structure.
*
LUL_Next	EQU	0		; ( 4 ) Pointer to Next In List.
LUL_LUT		EQU	LUL_Next+4	; ( LUT_Sizeof ) Value of LUT Struct.
LUL_Sizeof	EQU	LUL_LUT+LTR_Sizeof ; Size of LUT Link Structure.
*
*	File Error Message Numbers.
*
LUT_NoError		EQU	0
LUT_ListError		EQU	1
LUT_DirError		EQU	2
LUT_OpenError		EQU	3
LUT_ReadError		EQU	4
LUT_WriteError		EQU	5
LUT_ReadCroutonError	EQU	6
LUT_WriteCroutonError	EQU	7
