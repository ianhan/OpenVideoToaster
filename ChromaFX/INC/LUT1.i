********************************************************************
* LUT1.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: LUT1.i,v 2.1 1994/10/04 20:28:59 pfrench Exp $
*
* $Log: LUT1.i,v $
*Revision 2.1  1994/10/04  20:28:59  pfrench
*Added hack to save LUTs as ChromaFX croutons
*
*Revision 2.0  1992/05/19  00:03:27  Hartford
**** empty log message ***
*
*
*********************************************************************

	PAGE
*************************************************************************
*									*
*	LUT Data:							*
*									*
*	Contains all the Global Data For LUT Mode.			*
*									*
*	07.Feb 1990 Jamie L. Finch.					*
*									*
*************************************************************************
*
	XREF	LUT_FirstFG
	XREF	LUT_ProgramKey1FG
	XREF	LUT_OkFG
	XREF	LUT_TAKEFG
	XREF	LUT_RestoreDefaultFG
	XREF	LUT_SaveCroutonFG
	XREF	LUT_Crouton1FG
	XREF	LUT_TopTBar_Img_PTRS
	XREF	LUT_BotTBar_Img_PTRS
	XREF	LUT_TBarFG
	XREF	LUT_TBar_Img_PTRS
	XREF	LUT_NUMBERARROWUPFG
	XREF	LUT_NUMBERARROWDOWNFG
	XREF	LUT_COMMENTBOXFG
	XREF	LUT_ScreenFG
	XREF	LUT_NormalFG
	XREF	LUT_SpreadFG
	XREF	LUT_BAWFG
	XREF	LUT_RHSliderFG
	XREF	LUT_GSSliderFG
	XREF	LUT_BISliderFG
	XREF	LUT_TransitionFG
	XREF	LUT_FilterFG
	XREF	LUT_CycleArrowFG
	XREF	LUT_CycleSFG
	XREF	LUT_CycleMFG
	XREF	LUT_UpperRangeArrowFG
	XREF	LUT_LowerRangeArrowFG
	XREF	LUT_UpDownArrowFG
	XREF	LUT_RGBBoxFG
	XREF	LUT_HSIBoxFG
	XREF	LUT_RGBHSITextFG
	XREF	LUT_BACKOFTOPSLIDERFG
	XREF	LUT_PosterizationFG
	XREF	LUT_FULLPOSTERFG
	XREF	LUT_NOPOSTERFG
	XREF	LUT_INT_SPREADFG
	XREF	LUT_INT_SPECTRUMFG
	XREF	LUT_INT_RIGHT_ROTATEFG
	XREF	LUT_INT_LEFT_ROTATEFG
	XREF	LUT_INT_POSTERFG
	XREF	LUT_EditColorsFG
*
*	Intuition Gadgets.
*
	XREF	LUT_COMMENTBOXSI
	XREF	LUT_REALSIG
	XREF	LUT_WHOLEBG
*
*	Dummy Crouton.
*
	XREF	LUT_DummyCrouton
