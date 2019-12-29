********************************************************************
* LUT8.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: LUT8.i,v 2.2 1994/10/06 16:10:29 pfrench Exp $
*
* $Log: LUT8.i,v $
*Revision 2.2  1994/10/06  16:10:29  pfrench
*Added loadcrouton function
*
*Revision 2.1  1994/10/04  20:29:12  pfrench
*Added hack to save LUTs as ChromaFX croutons
*
*Revision 2.0  1992/05/19  00:03:47  Hartford
**** empty log message ***
*
*
*********************************************************************

	PAGE
*************************************************************************
*									*
*	LUT8:								*
*									*
*	Contains the Global Code for LUT8 Module.			*
*									*
*	07.Feb 1990 Jamie Lisa Finch.					*
*									*
*************************************************************************
*
	XREF	LUT_DoRedHue
	XREF	LUT_SlideRedHue
	XREF	LUT_DoGreenSaturation
	XREF	LUT_SlideGreenSaturation
	XREF	LUT_DoBlueIntensity
	XREF	LUT_SlideBlueIntensity
	XREF	LUT_DoPosterization
	XREF	LUT_THIRDQUANTIZE
	XREF	LUT_THIRDQUANTIZELN
	XREF	LUT_STEPQUANTIZE
	XREF	LUT_STEPQUANTIZELN
	XREF	LUT_QUANTIZE
	XREF	LUT_QUANTIZELN
	XREF	LUT_QuadAverageQuantize
	XREF	LUT_DoQuadQuantize
	XREF	LUT_DoQuantize
	XREF	LUT_AverageQuantize
	XREF	LUT_CheckPoster
	XREF	LUT_SavePosterBuffer
	XREF	LUT_InitEBuf
	XREF	LUT_DoEditColors
	XREF	LUT_SendMap
	XREF	LUT_SendEdit
	XREF	LUT_DoEditCopy
	XREF	LUT_DoEditExchange
	XREF	LUT_DoMoveTBar
	XREF	LUT_DoButtonTBar
	XREF	LUT_SetPosterImage
	XREF	LUT_DoGridNumber
	XREF	LUT_DoSaveCrouton
	XREF	LUT_DoLoadCrouton
