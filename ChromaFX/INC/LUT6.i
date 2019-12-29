********************************************************************
* LUT6.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: LUT6.i,v 2.2 1994/10/06 18:36:07 pfrench Exp $
*
* $Log: LUT6.i,v $
*Revision 2.2  1994/10/06  18:36:07  pfrench
*Added drawafterchanging global
*
*Revision 2.1  1993/02/23  14:20:08  Finch
*Removed FindGridCrouton
*
*Revision 2.0  92/05/19  00:03:56  Hartford
*
*********************************************************************

	PAGE
*************************************************************************
*									*
*	LUT6:								*
*									*
*	Contains the Global Code for LUT6 Module.			*
*									*
*	19.April 1990 Jamie Lisa Finch.					*
*									*
*************************************************************************
*
	XREF	LUT_MakeEditMark
	XREF	LUT_MakeEditLine
	XREF	LUT_DrawEditMark
	XREF	LUT_DoStep
	XREF	LUT_DoKeySwitchVideo
	XREF	LUT_DoKeySwitchVideoTb
	XREF	LUT_FindLUTData
	XREF	LUT_CountLULData
	XREF	LUT_SwitchLULData
	XREF	LUT_NumbericKeyPadEntry
	XREF	LUT_DoStringGadget
	XREF	LUT_PrintNumberText
	XREF	LUT_PrintNumber
	XREF	LUT_DoRestoreDefault
	XREF	LUT_DrawAfterChanging
