********************************************************************
* LUTB.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: LUTB.i,v 2.0 1992/05/19 00:03:10 Hartford Exp $
*
* $Log: LUTB.i,v $
*Revision 2.0  1992/05/19  00:03:10  Hartford
**** empty log message ***
*
*Revision 2.0  92/05/19  00:01:35  Hartford
**** empty log message ***
*
*
*********************************************************************

	PAGE
*************************************************************************
*									*
*	LUTB:								*
*									*
*	Contains the Global Code for LUTB Module.			*
*									*
*	29.Aug 1990 Jamie Lisa Finch.					*
*									*
*************************************************************************
*
	XREF	LUT_SMF_Speeds
	XREF	LUT_CycleModeOn
	XREF	LUT_CycleModeOffSwitcher
	XREF	LUT_CycleModeOffEditor
	XREF	LUT_BuildTranSprite
	XREF	LUT_BuildFilterSprite
	XREF	LUT_ForwardCycleRoutine
	XREF	LUT_EditCycleForward
	XREF	LUT_BackwardCycleRoutine
	XREF	LUT_EditCycleBackward
	XREF	LUT_BothCycleRoutine
	XREF	LUT_EditCycleBoth
	XREF	LUT_GridCycleForward
	XREF	LUT_GridCycleBackward
	XREF	LUT_GridCycleBoth
	XREF	LUT_CheckUpDateMapCrouton
	XREF	LUT_SendSpriteToToaster
	XREF	LUT_DisableLUT
	XREF	LUT_RemoveDVE0
	XREF	LUT_LinearRamp
	XREF	LUT_CheckLinear
	XREF	LUT_DrawRenderMessage
	XREF	LUT_PresetMessage
	XREF	LUT_SwitcherPreset1
	XREF	LUT_SwitcherPreset2
	XREF	LUT_SwitcherPreset3
	XREF	LUT_SwitcherPreset4
