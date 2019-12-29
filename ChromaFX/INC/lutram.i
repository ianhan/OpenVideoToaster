********************************************************************
* LUTRam.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: lutram.i,v 2.2 1996/07/15 18:24:58 Holt Exp $
*
* $Log: lutram.i,v $
*Revision 2.2  1996/07/15  18:24:58  Holt
*made many changes to make luts work in sequenceing.
*
*Revision 2.1  1993/02/23  15:12:40  Finch
**** empty log message ***
*
*Revision 2.0  92/05/19  00:03:33  Hartford
**** empty log message ***
*
*
*********************************************************************

	PAGE
*************************************************************************
*									*
*	LUT Ram:							*
*									*
*	Contains all the Global Ram For LUT Mode.			*
*									*
*	07.Feb 1990 Jamie L. Finch.					*
*									*
*************************************************************************
*
	XREF	LUT_Base		; LUT Base Structure.
	XREF	LUT_Capture		; Capture Structure.
	XREF	LUT_CycleLine		; Current Position.
	XREF	LUT_CycleSpeed		; Current Speed.
	XREF	LUT_EffectLUTBase	; Switcher TBar Routine, LUT Pointer.
	XREF	LUT_EffectEfxBase	; Switcher TBar Routine, Effect Pointer.
	XREF	LUT_mainorprev		; Buss for effect to comeup on.
	XREF	LUT_BUSS		; Buss for effect to comeup on.
	
