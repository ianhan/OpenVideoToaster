********************************************************************
* LUT2.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: LUT2.i,v 2.0 1992/05/19 00:04:04 Hartford Exp $
*
* $Log: LUT2.i,v $
*Revision 2.0  1992/05/19  00:04:04  Hartford
**** empty log message ***
*
*
*********************************************************************

	PAGE
*************************************************************************
*									*
*	LUT2:								*
*									*
*	Contains the Global Code for LUT2 Module.			*
*									*
*	08.Mar 1990 Jamie Lisa Finch.					*
*									*
*************************************************************************
*
	XREF	RGBHSI			; Convert RGB to HSI.
	XREF	HSIRGB			; Convert HSI to RGB.
	XREF	RGBYIQ			; Convert RGB to YIQ.
	XREF	YIQQUAD			; Convert YIQ to QUAD.
	XREF	FillLong		; Fill a Long Word Aligned Area of Mem.
	XREF	MoveLong		; Move a Long Word Aligned Area of Mem.
	XREF	CompQUAD		; Complements QUAD Values.
	XREF	RotateLong		; Rotate Long Data.
	XREF	NukeLong		; Nuke   Long Data.
	XREF	UDIV32			; Unsigned Divide By 32.
	XREF	RUBINTOASC		; Right Justified, Unsigned, Binary to A
	XREF	ASCINT			; Converts ASCII to Integer.
