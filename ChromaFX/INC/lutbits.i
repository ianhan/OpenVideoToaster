********************************************************************
* LUTBits.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: lutbits.i,v 2.3 1994/10/06 15:56:15 pfrench Exp $
*
* $Log: lutbits.i,v $
*Revision 2.3  1994/10/06  15:56:15  pfrench
*added load effect button
*
*Revision 2.2  1994/10/05  16:19:35  pfrench
*Added bitplanes for save effect
*
*Revision 2.1  1993/05/04  16:50:33  Finch2
*Added ChromaFx Bitmap.
*
*
*********************************************************************
	PAGE
*************************************************************************
*									*
*	LUT Bits:							*
*									*
*	Contains the Global LUT Bit Maps for the Fast Gadgets.		*
*									*
*	12.Feb 1990 Jamie L. Finch.					*
*									*
*************************************************************************
*
	XREF	LUT_LOADEFFECT_BT		; Load effect button
	XREF	LUT_SAVEEFFECT_BT		; Save effect button
	XREF	LUT_COMMENTBOX_BT		; Comment Box.
	XREF	LUT_NOCYCLEARROW_BT		; No    Cycle Arrow.
	XREF	LUT_LEFTCYCLEARROW_BT		; Left  Cycle Arrow.
	XREF	LUT_RIGHTCYCLEARROW_BT		; Right Cycle Arrow.
	XREF	LUT_BOTHCYCLEARROW_BT		; Both  Cycle Arrow.
	XREF	LUT_FULLPOSTER_BT		; Full Poster.
	XREF	LUT_NOPOSTER_BT			; No   Poster.
	XREF	LUT_TOPSLIDER_BT		; Top Slider.
	XREF	LUT_TAKE_BT			; Take.
	XREF	LUT_INT_SPREAD_BT		; Int Spread.
	XREF	LUT_INT_SPECTRUM_BT		; Int Spectrum.
	XREF	LUT_INT_RIGHT_ROTATE_BT		; Int Right Rotate.
	XREF	LUT_INT_LEFT_ROTATE_BT		; Int Left  Rotate.
	XREF	LUT_INT_RIGHT_NUKE_BT		; Int Right Nuke.
	XREF	LUT_INT_LEFT_NUKE_BT		; Int Left  Nuke.
	XREF	LUT_INT_POSTER_BT		; Int Poster.
	XREF	LUT_RGBTEXT_BT			; RGB Text.
	XREF	LUT_HSITEXT_BT			; HSI Text.
	XREF	LUT_RGBBOX_BT			; RGB Box.
	XREF	LUT_HSIBOX_BT			; HSI Box.
	XREF	LUT_LEFTARROW_BT		; Left  Arrow.
	XREF	LUT_ERASEARROW_BT		; Erase Arrow.
	XREF	LUT_UPDOWNARROWS_BT		; UpDown Arrows.
	XREF	LUT_BAW_BT			; Black & White.
	XREF	LUT_COLOR_BT			; Color.
	XREF	LUT_NORMAL_BT			; Normal.
	XREF	LUT_NEGATIVE_BT			; Negative.
	XREF	LUT_RANDOM_BT			; Random.
	XREF	LUT_SNOW_BT			; Snow.
	XREF	LUT_SPREAD_BT			; Spread.
	XREF	LUT_SPECTRUM_BT			; Spectrum.
	XREF	LUT_COPY_BT			; Copy.
	XREF	LUT_EXCHANGE_BT			; Exchange.
	XREF	LUT_SBox_BT			; S Box.
	XREF	LUT_MBox_BT			; M Box.
	XREF	LUT_FBox_BT			; F Box.
	XREF	LUT_TRANSITION_BT		; Transition.
	XREF	LUT_FILTER_BT			; Filter.
	XREF	LUT_OK_BT			; Ok.
	XREF	LUT_SLIDER0_BT			; Slider 0 Position.
	XREF	LUT_SLIDER1_BT			; Slider 1 Position.
	XREF	LUT_SLIDER2_BT			; Slider 2 Position.
	XREF	LUT_SLIDER3_BT			; Slider 3 Position.
	XREF	LUT_SLIDER4_BT			; Slider 4 Position.
	XREF	LUT_SLIDER5_BT			; Slider 5 Position.
	XREF	LUT_SLIDER6_BT			; Slider 6 Position.
	XREF	LUT_SLIDER7_BT			; Slider 7 Position.
	XREF	LUT_SLIDER8_BT			; Slider 8 Position.
	XREF	LUT_SLIDER9_BT			; Slider 9 Position.
	XREF	LUT_SLIDERA_BT			; Slider A Position.
	XREF	LUT_SLIDERB_BT			; Slider B Position.
	XREF	LUT_SLIDERC_BT			; Slider C Position.
	XREF	LUT_SLIDERD_BT			; Slider D Position.
	XREF	LUT_SLIDERE_BT			; Slider E Position.
	XREF	LUT_SLIDERF_BT			; Slider F Position.
	XREF	LUT_EDITBACKGROUNDSLIDER_BT	; Behind RGB Sliders.
	XREF	LUT_EDITPICKAREA_BT		; Edit Pick Area.
	XREF	LUT_EDITBOTTOMAREA_BT		; Interpilation Area.
	XREF	LUT_FourCroutonBoxes_BT		; 4 Crouton Boxes.
	XREF	LUT_RestoreDefault_BT		; Restore Default.
	XREF	LUT_Crouton1_BT			; Crouton 1.
	XREF	LUT_Crouton2_BT			; Crouton 2.
	XREF	LUT_Crouton3_BT			; Crouton 3.
	XREF	LUT_Crouton4_BT			; Crouton 4.
	XREF	LUT_PROGRAMKEY1_BT		; Program Key 1.
	XREF	LUT_PROGRAMKEY2_BT		; Program Key 2.
	XREF	LUT_PROGRAMKEY3_BT		; Program Key 3.
	XREF	LUT_PROGRAMKEY4_BT		; Program Key 4.
	XREF	LUT_PROGRAM_BT			; Program.
	XREF	LUT_CHROMAFX_BT			; ChromaFx-----
