********************************************************************
* keylogic.a
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: keylogic.a,v 2.71 1995/10/10 18:29:56 Holt Exp Holt $
*
* $Log: keylogic.a,v $
*Revision 2.71  1995/10/10  18:29:56  Holt
*added call to SWIT_UpdateFrameSaveButtons so freeze/live buttons would update.
*
*Revision 2.70  1995/10/03  10:24:59  Holt
*added code to help positionable effects work
*
*Revision 2.69  1995/08/09  12:21:08  Holt
**** empty log message ***
*
*Revision 2.68  1995/04/20  17:47:28  Holt
*may have fixed key fades
*
*Revision 2.67  1995/03/15  13:04:29  Holt
*KEY PAGES SHOULD NOW WORK IN MOST CASES
*
*Revision 2.66  1995/03/14  16:47:00  Holt
*fixed the Key re-appear problem, it was easy!
*
*Revision 2.65  1995/03/04  14:07:42  CACHELIN4000
*Try SelectStdFx in KillAlphaKey (not successful)
*
*Revision 2.64  1995/03/04  13:02:44  CACHELIN4000
*Track Key problem through KillAlphaKey f'n below into ReDoDisplay (i think)
*
*Revision 2.63  1995/02/21  20:16:37  Kell
**** empty log message ***
*
*Revision 2.62  1995/02/20  05:03:22  Kell
*Some attepts to prevent Keys from re-appearing after TBar drags to bottom or Autos.
*
*Revision 2.61  1995/02/18  05:40:57  Kell
*New logics for LUT or Mono.
*
*Revision 2.60  1995/02/17  16:34:39  Kell
*Now checks AACHIP bit in TB_Flags2 instead of conditional assembly
*
*Revision 2.59  1995/02/17  15:43:53  Kell
**** empty log message ***
*
*Revision 2.58  1995/02/16  20:54:51  Kell
*Basic PE FGC handlers can now deal with removing a AlphaBM key.
*Various calls to KillAlphaBM.  Mods to DoTake and DoTakeNoKey to support DIB and DIBGR keyed graphics.  Now does an updatedisplay on FX select.
*
*Revision 2.57  1995/02/03  16:24:59  Kell
*Put in DBSCRAWLS condition assembly for testing Scrawls via TAKE.
*
*Revision 2.56  1995/01/31  10:24:42  Kell
**** empty log message ***
*
*Revision 2.55  1994/12/23  03:35:33  Kell
*New debugs
*
*Revision 2.54  1994/12/15  17:43:45  Kell
*Now ServeAVE_AVEI restores TB_CopListIntreq to default.
*Also, ALWAYS turns on SOFTINT if not already on!!!
*
*Revision 2.53  1994/12/06  07:14:08  Kell
*PeLoadTags now calls ApplyTags2Lists function.
*
*Revision 2.52  1994/11/23  16:40:54  Kell
*PEunsavable handler added.
*
*Revision 2.51  1994/11/18  09:41:30  Kell
*PESelect will always be successful.
*
*Revision 2.50  1994/11/17  17:18:25  Kell
*FGC_Load can no longer fail on non-anims.
*
*Revision 2.49  1994/11/02  11:24:26  Kell
**** empty log message ***
*
*Revision 2.48  1994/10/05  05:51:54  Kell
*Better debugs
*
*Revision 2.47  1994/09/27  04:41:12  Kell
*Changed macros & functions that used Matt to Matte. And now using SetMatteColor instead of old RestoreMattColor.
*
*Revision 2.46  1994/09/08  19:22:48  Kell
*New FGC_UpdateTag/TagInfo commands supported in ProcessEffect.
*
*Revision 2.45  1994/07/27  19:28:58  Kell
**** empty log message ***
*
*Revision 2.44  1994/06/04  03:53:15  Kell
*New ChangeISlace function to support time critical interlaced BM installs
*
*Revision 2.43  94/05/27  17:19:05  Kell
*Removed ToPrvwCommand call from select handler.
*
*Revision 2.42  94/05/24  22:01:54  Kell
*KillTransTriMarks..., PEselect..., PEremove... "Q" and "K" versions eliminated.
*PEselectAuto removed.  Now Editor handles re-select.
*ChangeIS now honors Wait4Time to wait for a particular field time.
*
*Revision 2.41  94/03/31  13:14:19  Kell
*Fixes to prevent ServeAVEI from showing garbaged interfaces during sequencing.
*
*Revision 2.40  94/03/19  00:37:18  Kell
*Fixed some effects control panels
*
*Revision 2.39  94/03/18  09:19:53  Kell
*Avoids AVEI during sequencing
*
*Revision 2.38  94/03/16  10:50:29  Kell
**** empty log message ***
*
*Revision 2.37  94/03/15  14:18:14  Kell
**** empty log message ***
*
*Revision 2.36  94/03/08  06:12:52  Kell
**** empty log message ***
*
*Revision 2.35  94/03/06  16:50:05  Kell
**** empty log message ***
*
*Revision 2.34  94/02/17  12:33:33  Kell
**** empty log message ***
*
*Revision 2.33  94/02/07  15:58:17  Kell
*Various changes to support the new 4.0 croutons & projects.
*Added new tag list handling routines.
*
*Revision 2.32  93/12/09  02:43:09  Turcotte
*Removed Auto on second Select
*
*Revision 2.31  93/11/16  02:04:16  Kell
**** empty log message ***
*
*Revision 2.30  93/11/06  08:42:40  Kell
*Fixed to work with EF_EffectsLogic, EF_EffectsTable, EF_TimeVariables and EF_VariableResults no longer being embedded within EFXBase.
*
*Revision 2.29  93/10/29  03:48:24  Kell
*Algorithmic Positionable FX no call TB functions for mouse button
*states vs looking at hardware.
*
*Revision 2.28  93/10/28  00:00:06  Kell
**** empty log message ***
*
*Revision 2.27  93/09/02  20:24:25  Kell
**** empty log message ***
*
*Revision 2.26  93/06/19  10:34:51  Kell
*Fixes to prevent flashes when clicking Freeze/live mid-transition
*
*Revision 2.25  93/06/08  19:48:11  Kell
**** empty log message ***
*
*Revision 2.24  93/06/08  06:59:48  Kell
*Ttime now called EF_PreProcessDuring routine if supplied.
*
*Revision 2.23  93/06/05  07:46:38  Kell
*New IsMatteShown() routine.
*
*Revision 2.22  93/05/29  04:18:48  Kell
**** empty log message ***
*
*Revision 2.21  93/05/28  21:17:59  Kell
*Only border effects will allow border rendering on MTSliceCode.
*
*Revision 2.20  93/05/27  04:31:05  Kell
*New SomeInterruptsOn/Off now used by Positionable effects.
*
*Revision 2.19  93/05/25  02:22:50  Kell
*Now 3.0 ANIMS deals with source changes while midtransition.
*
*Revision 2.18  93/05/14  01:03:22  Kell
**** empty log message ***
*
*Revision 2.17  93/05/13  20:19:02  Kell
**** empty log message ***
*
*Revision 2.16  93/05/08  15:04:05  Kell
*The Forbids/Permits and SoftspriteOff/Ons were removed around the
*TBar, AUTO, and UNAUTO handler calls.
*
*Revision 2.15  93/05/06  03:13:19  Kell
*Now calls StuffFCount when SMFV are clicked on.
*
*Revision 2.14  93/05/06  02:18:12  Kell
**** empty log message ***
*
*Revision 2.13  93/05/06  01:57:33  Kell
*FGC_FCOUNT
*mode not supports variable speeds.
*
*Revision 2.12  93/05/05  20:31:53  Kell
*Now uses TB_StashCount instead of a local field in Keylogic.a
*
*Revision 2.11  93/05/05  02:10:50  Kell
*Now uses EF_OldTBarTime instead of EF_OldTBar to check for new stage.
*
*Revision 2.10  93/05/01  02:24:51  Kell
*Put in SoftSpriteOff/On & Forbid/Permit around AUTO/UNAUTO/TBAR FGC processing.
*
*Revision 2.9  93/04/27  21:46:44  Kell
*Now looks at TBarTime instead of TValSec after TBar moves to see if
*at top or bottom of tbar.  Fakes hires tbar in ProcessDuring.
*
*Revision 2.8  93/04/18  07:13:02  Kell
**** empty log message ***
*
*Revision 2.7  93/04/17  16:26:56  Kell
*Now handles EFFLAGS1_TEMORARYSPRITE1 flag.
*
*Revision 2.6  93/04/17  04:15:35  Kell
*Now restores NOPAIRS, USERON, PVMUTE & Matte color after effects.
*
*Revision 2.5  93/04/14  13:43:33  Kell
*New ServerAVE_AVEI routine that honors the EFFLAGS1_DISPLAYTRASHED flag.
*Now sets MATTE and clears AM/BM/IS WIPE bits after transitions.
*
*Revision 2.4  93/04/07  17:17:26  Kell
*No keylogic's MakeLive looks at EF_CurrentEffectsTable vs the hardcoded one.
*
*Revision 2.3  93/04/07  08:50:44  Kell
*The new "non-absolute address" version of EffectsKeysELH is handled.
*Effects logic now use a UWORD value for time vs the old TBar 0-511.
*
*Revision 2.2  93/03/06  00:38:40  Kell
*Now do a SoftSpriteOff when doing InterruptsOff to prevent infinit hangs
*
*Revision 2.1  93/02/11  16:37:02  Kell
**** empty log message ***
*
*Revision 2.0  92/05/18  21:16:58  Hartford
**** empty log message ***
*
*********************************************************************
****************************************************************
* -- Routines that handle button logic during transitions.
*
* By  S.R. Kell,     NewTek Inc.     May 1990
****************************************************************
	include	'assembler.i'
        include	'exec/types.i'
	include	'hardware/custom.i'
	include 'hardware/intbits.i'

	include 'instinct.i'
	include 'eflib.i'
	include 'macros.i'
	include 'vtdebug.i'
	include 'rect.i'
	include 'keylogic.i'
	include 'custom.i'
	include	'serialdebug.i'

;-----------------------------------------------------------

SERDEBUG	set	1
	ALLDUMPS


;DBPX	SET	1 	;DEBUG POSITIONABLE EFFECTS
;;DBML	SET	1	;Debug MakeLive
;;DBPE	 SET	1	;Debug ProcessEffect
;;DBPETAGS SET  1	;Debug ProcessEffect Tag commands

 	IFD	SERDEBUG
;;DBSCRAWLS	set	1	;define if testing CG via TAKE button
	ENDC

;;KILLKEYHACK	set	1	;resets keying to CD on FX Auto

;-----------------------------------------------------------
;;	OPT	O1-	;disable short banch optimization complaints

	XCODE	oooo_oo_o_O,XXXX_oo_o_O,oooo_oo_X_O,XXXX_oo_X_O	
	XCODE	oooo_FF_o_O,XXXX_FF_o_O,oooo_FF_X_O,XXXX_FF_X_O	
	XCODE	oooo_fF_o_O,XXXX_fF_o_O,oooo_fF_X_O,XXXX_fF_X_O	
	XCODE	oooo_Fo_o_O,oooo_oF_o_O,xxxx_FF_x_O	
	XCODE	XXXX_dd_X_A_O,oooo_dd_X_A_O,XXXX_dd_o_A_O	
	XCODE	XXXX_dd_X_P_O,oooo_dd_X_P_O,XXXX_dd_o_P_O
	XCODE	XXXX_dd_X_N_O,oooo_dd_X_N_O,XXXX_dd_o_N_O
	XCODE	XXXX_DD_X_O,oooo_DD_X_O,XXXX_DD_o_O     

	XCODE	oooo_oo_o_M,XXXX_oo_o_M,oooo_oo_X_M,XXXX_oo_X_M	
	XCODE	oooo_FF_o_M,XXXX_FF_o_M,oooo_FF_X_M,XXXX_FF_X_M	
	XCODE	oooo_fF_o_M,XXXX_fF_o_M,oooo_fF_X_M,XXXX_fF_X_M	
	XCODE	oooo_Fo_o_M,oooo_oF_o_M,xxxx_FF_x_M	
	XCODE	XXXX_dd_X_A_M,oooo_dd_X_A_M,XXXX_dd_o_A_M	
	XCODE	XXXX_dd_X_P_M,oooo_dd_X_P_M,XXXX_dd_o_P_M	
	XCODE	XXXX_dd_X_N_M,oooo_dd_X_N_M,XXXX_dd_o_N_M
	XCODE	XXXX_DD_X_M,oooo_DD_X_M,XXXX_DD_o_M     

	XCODE	oooo_oo_o_P,XXXX_oo_o_P,oooo_oo_X_P,XXXX_oo_X_P	
	XCODE	oooo_FF_o_P,XXXX_FF_o_P,oooo_FF_X_P,XXXX_FF_X_P	
	XCODE	oooo_fF_o_P,XXXX_fF_o_P,oooo_fF_X_P,XXXX_fF_X_P	
	XCODE	oooo_Fo_o_P,oooo_oF_o_P	
	XCODE	XXXX_dd_X_A_P,oooo_dd_X_A_P,XXXX_dd_o_A_P	
	XCODE	XXXX_dd_X_N_P,oooo_dd_X_N_P,XXXX_dd_o_N_P
	XCODE	XXXX_DD_X_P,oooo_DD_X_P,XXXX_DD_o_P     

	XCODE	ProcessEffect,ProcessDuring,ProcessPosition,ChangeIS
	XCODE	IsMatteShown,ChangeISlace

	XCODE 	PEtbar,DoOLaySwap,DoMainSwap,DoPrvwSwap
	XCODE	DoStageLogic,GetFrom,ProcessTake,ProcessUnTake
	XCODE	ProcessTakeUnTake,PEobutton,PEmbutton,PEpbutton
	XCODE	ProcessFreezeThaw,ProcessFreezeButton
	XCODE	CookFreezeThaw,CookFreezeButton
	XCODE	StashStates,ChangeClips,GetLutBus
	XCODE	DoTake,DoTakeNoKey
	XCODE	ProcessLUToff	;not currently used by anyone outside

	XREF	ShiftedKey

	SECTION	,DATA

PEtbl	dc.l	PEload
	dc.l	PEunload
	dc.l	PEselect
	dc.l	PEremove
	dc.l	PEauto
	dc.l	PEtbar
	dc.l	PEframecount
	dc.l	PEgenfg
	dc.l	PEselectq
	dc.l	PEremoveq
	dc.l	PEnumval
	dc.l	PEselectk
	dc.l	PEupdate
	dc.l	PErawkey
	dc.l	PEtake
	dc.l	PEfreeze
	dc.l	PEobutton
	dc.l	PEmbutton
	dc.l	PEpbutton
	dc.l	PEclip
	dc.l	PEfload
	dc.l	PEfsave
	dc.l	PEmousexy
	dc.l	PEbg
	dc.l	PEborder
	dc.l	PEunauto
	dc.l	PEstdefx

	dc.l	PEputvalue
	dc.l	PEgetvalue
	dc.l	PEloadtags
	dc.l	PEsavetags

	dc.l	PEpanel
	dc.l	PEnext
	dc.l	PEtomain
	dc.l	PEtoprvw

	dc.l	PEtaginfo
	dc.l	PEupdatetag
	dc.l	PEunsavable

PEtblSIZE	SET	((*-PEtbl)/4)-1

Old0RG	dc.l	0
Old0BI	dc.l	0
Old2RG	dc.l	0
Old2BI	dc.l	0
OldLKA	dc.w	0
OldLKB	dc.w 	0

pad0    dc.b	0	;not currently used
pad1	dc.b	0	;not currently used

LutBus	dc.b	0

Flags1	dc.b	0
FLAGS1_SKIPTAKE	set	0

buttonstate dc.w 0	;stash which of LMB/RBM is used with TBar

	CNOP	0,4

****************************************************************
	SECTION	,CODE

	IFD	CRAP
****************************************************************
* Each of these functions contain a5->TB	
oooo_oo_o_O	
XXXX_oo_o_O	
oooo_oo_X_O	;matte for sure	
XXXX_oo_X_O	

oooo_FF_o_O	
XXXX_FF_o_O	;FF = either freeze bank
oooo_FF_X_O	
XXXX_FF_X_O	

oooo_fF_o_O	;f = lock out if this row controls LUT	
XXXX_fF_o_O
oooo_fF_X_O	
XXXX_fF_X_O	

xxxx_FF_x_O	;would prefer oooo_FF_oo but can live with XXXX_FF_XX
		;If the prefered is not immediately possible it flags LINP
		;This allows frozen TDEs to do wipes.

oooo_Fo_o_O	;hard coded for DV1
oooo_oF_o_O	;hard coded for DV2

XXXX_dd_X_A_O	;any = can steal live DV from any row	
oooo_dd_X_A_O	;dd = optional live DV
XXXX_dd_o_A_O	
XXXX_dd_X_P_O	;P = can only steal live DV from PRVW
oooo_dd_X_P_O	
XXXX_dd_o_P_O	
XXXX_dd_X_N_O	;none = can't steal live DV from any other row	
oooo_dd_X_N_O	
XXXX_dd_o_N_O	

XXXX_DD_X_O	;DD = manditory live DV, even if not selected! Always steals.
oooo_DD_X_O
XXXX_DD_o_O     

;--------
oooo_oo_o_M	
XXXX_oo_o_M	
oooo_oo_X_M	;matte for sure	
XXXX_oo_X_M	

oooo_FF_o_M	
XXXX_FF_o_M	;FF = either freeze bank
oooo_FF_X_M	
XXXX_FF_X_M	

oooo_fF_o_M	;f = lock out if this row controls LUT	
XXXX_fF_o_M
oooo_fF_X_M	
XXXX_fF_X_M	

xxxx_FF_x_M	;would prefer oooo_FF_oo but can live with XXXX_FF_XX
		;If the prefered is not immediately possible it flags LINP
		;This allows frozen TDEs to do wipes.

oooo_Fo_o_M	;hard coded for DV1
oooo_oF_o_M	;hard coded for DV2

XXXX_dd_X_A_M	;any = can steal live DV from any row	
oooo_dd_X_A_M	;dd = optional live DV
XXXX_dd_o_A_M	
XXXX_dd_X_P_M	;P = can only steal live DV from PRVW
oooo_dd_X_P_M	
XXXX_dd_o_P_M	
XXXX_dd_X_N_M	;none = can't steal live DV from any other row	
oooo_dd_X_N_M	
XXXX_dd_o_N_M	

XXXX_DD_X_M	;DD = manditory live DV, even if not selected! Always steals.
oooo_DD_X_M
XXXX_DD_o_M     

;--------
oooo_oo_o_P	
XXXX_oo_o_P	
oooo_oo_X_P	;matte for sure	
XXXX_oo_X_P	

oooo_FF_o_P	
XXXX_FF_o_P	;FF = either freeze bank
oooo_FF_X_P	
XXXX_FF_X_P	

oooo_fF_o_P	;f = lock out if this row controls LUT	
XXXX_fF_o_P
oooo_fF_X_P	
XXXX_fF_X_P	

oooo_Fo_o_P	;hard coded for DV1
oooo_oF_o_P	;hard coded for DV2

XXXX_dd_X_A_P	;any = can steal live DV from any row	
oooo_dd_X_A_P	;dd = optional live DV
XXXX_dd_o_A_P	
XXXX_dd_X_N_P ;none = can't steal live DV from any other row	
oooo_dd_X_N_P	
XXXX_dd_o_N_P	

XXXX_DD_X_P	;DD = manditory live DV, even if not selected! Always steals.
oooo_DD_X_P
XXXX_DD_o_P       

	ENDC	;CRAP
**********************************************************************
* We will always assume legal button combinations.  Such as, the DV
* buttons will honor the state of the Freeze button, and live DV will
* always exist with some other analog button.  Only one Analog button
* or one frozen DV may be selected at a time.  I am allowing a blank
* row as being legal (it is on the OLay row).
* These routines trash D0 !!
**********************************************************************

oooo_oo_o_O	clr.w	TB_OLaySec(a5)	
		rts

;--------------------------------------
XXXX_oo_o_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_OLayPri,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut, only if save had encoder		
10$		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		

;--------------------------------------
oooo_oo_X_O	PUT.w	#M_ENCODER,TB_OLaySec
		PUT.w	#M_ENCODER,TB_OLaySave
		rts	

;--------------------------------------
XXXX_oo_X_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will absolutely have some analog
10$		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		

;--------------------------------------
oooo_FF_o_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w (M_VIDEO!M_ENCODER),d0
		bne.s	10$	;if jmp assume frozen (live shouldn't happen)
		GET.w	TB_OLayFroze,d0
		bra.s	20$
10$		PUT.w	d0,TB_OLayFroze
20$		PUT.w	d0,TB_OLaySec
		rts		

;--------------------------------------
XXXX_FF_o_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_OLayFroze,d0
		PUT.w	d0,TB_OLaySec
		rts
10$		PUT.w	d0,TB_OLaySec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_OLaySave
		rts
15$		PUT.w	d0,TB_OLayFroze
20$		rts		

;--------------------------------------
oooo_FF_X_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		GET.w	TB_OLayFroze,d0
		PUT.w	d0,TB_OLaySec
		rts
10$		PUT.w	d0,TB_OLaySec
		btst	#B_ENCODER,d0
		bne.s	15$
		PUT.w	d0,TB_OLayFroze
		rts
15$		PUT.w	d0,TB_OLaySave
20$		rts		

;--------------------------------------
XXXX_FF_X_O	GET.w	TB_OLaySec,d0
		bne.s	5$
		GET.w	TB_OLayPri,d0
		bne.s	5$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will have something
5$		PUT.w	d0,TB_OLaySec
		ISANALOGINUSE	d0
		beq.s	8$
		PUT.w	d0,TB_OLaySave
		rts
8$		PUT.w	d0,TB_OLayFroze
10$		rts

;--------------------------------------
oooo_fF_o_O	tst.b	TB_LutBus(a5)
		bne.s	5$
		GET.w	TB_OLaySec,d0
		BITCLEAR.w (M_VIDEO!M_ENCODER),d0
		bne.s	10$	;if jmp assume frozen (live shouldn't happen)
		GET.w	TB_OLayFroze,d0
		bra.s	20$
5$		move.w	#M_DV1,d0	;lut mode
10$		PUT.w	d0,TB_OLayFroze
20$		PUT.w	d0,TB_OLaySec
		rts		

;--------------------------------------
XXXX_fF_o_O	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_OLaySec,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_OLayFroze,d0
		PUT.w	d0,TB_OLaySec
		rts

*Lut mode
5$		GET.w	TB_OLaySec,d0
		BITCLEAR.w (M_DV0!M_ENCODER),d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w (M_DV0!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_DV1,d0

10$		PUT.w	d0,TB_OLaySec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_OLaySave
		rts
15$		PUT.w	d0,TB_OLayFroze
20$		rts		

;--------------------------------------
oooo_fF_X_O	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_OLaySec,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		GET.w	TB_OLayFroze,d0
		PUT.w	d0,TB_OLaySec
		rts

*Lut mode
5$		GET.w	TB_OLaySec,d0
		BITCLEAR.w (M_VIDEO!M_DV0),d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w (M_VIDEO!M_DV0),d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		move.w	#M_DV1,d0

10$		PUT.w	d0,TB_OLaySec
		btst	#B_ENCODER,d0
		bne.s	15$
		PUT.w	d0,TB_OLayFroze
		rts
15$		PUT.w	d0,TB_OLaySave
20$		rts		

;--------------------------------------
XXXX_fF_X_O	tst.b	TB_LutBus(a5)
		beq.s	5$

*Lut mode	
		GET.w	TB_OLaySec,d0
		BITCLEAR.w M_DV0,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_DV0,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		move.w	#M_DV1,d0
		bra.s	10$

5$		GET.w	TB_OLaySec,d0
		bne.s	10$
		GET.w	TB_OLayPri,d0
		bne.s	10$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will have something
10$		PUT.w	d0,TB_OLaySec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_OLaySave
		rts
15$		PUT.w	d0,TB_OLayFroze
		rts

;--------------------------------------
xxxx_FF_x_O	GET.w	TB_OLaySec,d0
		bne.s	5$
		GET.w	TB_OLayPri,d0
		bne.s	5$
		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will have something
5$		PUT.w	d0,TB_OLaySec
		ISANALOGINUSE	d0
		beq.s	8$
		PUT.w	d0,TB_OLaySave
		move.w	#1,EF_NotDigital(a4)
		rts
8$		PUT.w	d0,TB_OLayFroze
		rts

;--------------------------------------
oooo_Fo_o_O	PUT.w	#M_DV0,TB_OLaySec
		PUT.w	#M_DV0,TB_OLayFroze
		rts

;--------------------------------------
oooo_oF_o_O	PUT.w	#M_DV1,TB_OLaySec
		PUT.w	#M_DV1,TB_OLayFroze
		rts

;--------------------------------------
XXXX_dd_X_A_O	GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	10$
		
		PUT.w	d0,TB_OLaySave	;dve in use
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		rts

10$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		

;--------------------------------------
oooo_dd_X_A_O	GET.w	TB_OLaySec,d0
		BITPUT_I	(M_VIDEO!M_ENCODER),M_ENCODER,d0		
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		ISDVEINUSE	d0
		beq.s	10$

		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
10$		rts

;--------------------------------------
XXXX_dd_o_A_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_OLayPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	200$

		move.w	(sp)+,d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		

200$		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave	;dve in use
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		rts

;--------------------------------------
XXXX_dd_X_P_O	GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	20$
		
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	10$
		
		GET.w	TB_OLaySec,d0		
		TURNLIVEDVEOFF	d0
		bra.s	20$
		
10$		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		GET.w	TB_OLaySec,d0
		bra.s	100$

20$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		

;--------------------------------------
oooo_dd_X_P_O	GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	90$

		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		move.w	#(M_DVE!M_ENCODER),d0
		bra.s	100$
	
90$		move.w	#M_ENCODER,d0
100$		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		
;--------------------------------------
XXXX_dd_o_P_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_OLayPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	20$
	
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	20$

		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave	;dve in use
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		rts

20$		move.w	(sp)+,d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		
		rts		
	
;--------------------------------------
XXXX_dd_X_N_O	GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	20$

		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	10$
		
		GET.w	TB_PrvwSec,d0		
		ISDVEINUSE	d0
		bne.s	10$
		
		GET.w	TB_OLaySec,d0
		bra.s	200$
		
10$		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		bra.s	100$

20$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_OLayPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_OLaySec
200$		PUT.w	d0,TB_OLaySave
		rts		

;--------------------------------------
oooo_dd_X_N_O	GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	90$

		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		move.w	#(M_DVE!M_ENCODER),d0
		bra.s	100$
	
90$		move.w	#M_ENCODER,d0
100$		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		
	
;--------------------------------------
XXXX_dd_o_N_O	GET.w	TB_OLaySec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_OLayPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	20$
	
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	20$

		GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		bne.s	20$

		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave	;dve in use
		rts

20$		move.w	(sp)+,d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		
		rts		
		
;--------------------------------------
XXXX_DD_X_O	GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		
		GET.w	TB_OLaySec,d0
		bne.s	100$

		GET.w	TB_OLayPri,d0
		bne.s	100$

		GET.w	TB_OLaySave,d0

100$		TURNLIVEDVEON	d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		
	
;--------------------------------------
oooo_DD_X_O	GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec

		move.w	#(M_DVE!M_ENCODER),d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave
		rts		

;--------------------------------------
XXXX_DD_o_O	GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec

		GET.w	TB_OLaySec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_OLayPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_OLaySave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		TURNLIVEDVEON	d0
		PUT.w	d0,TB_OLaySec
		PUT.w	d0,TB_OLaySave	;dve in use
		rts
   
;--------------------------------------
oooo_oo_o_M	clr.w	TB_MainSec(a5)	
		rts
	
;--------------------------------------
XXXX_oo_o_M	GET.w	TB_MainSec,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_MainPri,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut, only if save had encoder		
10$		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		
	
;--------------------------------------
oooo_oo_X_M	PUT.w	#M_ENCODER,TB_MainSec
		PUT.w	#M_ENCODER,TB_MainSave
		rts	
	
;--------------------------------------
XXXX_oo_X_M	GET.w	TB_MainSec,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		GET.w	TB_MainPri,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will absolutely have some analog
10$		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		
	
;--------------------------------------
oooo_FF_o_M	GET.w	TB_MainSec,d0
		BITCLEAR.w (M_VIDEO!M_ENCODER),d0
		bne.s	10$	;if jmp assume frozen (live shouldn't happen)
		GET.w	TB_MainFroze,d0
		bra.s	20$
10$		PUT.w	d0,TB_MainFroze
20$		PUT.w	d0,TB_MainSec
		rts		
	
;--------------------------------------
XXXX_FF_o_M	GET.w	TB_MainSec,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_MainFroze,d0
		PUT.w	d0,TB_MainSec
		rts
10$		PUT.w	d0,TB_MainSec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_MainSave
		rts
15$		PUT.w	d0,TB_MainFroze
20$		rts		
	
;--------------------------------------
oooo_FF_X_M	GET.w	TB_MainSec,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		GET.w	TB_MainFroze,d0
		PUT.w	d0,TB_MainSec
		rts
10$		PUT.w	d0,TB_MainSec
		btst	#B_ENCODER,d0
		bne.s	15$
		PUT.w	d0,TB_MainFroze
		rts
15$		PUT.w	d0,TB_MainSave
20$		rts		

;--------------------------------------
XXXX_FF_X_M	GET.w	TB_MainSec,d0
		bne.s	5$
		GET.w	TB_MainPri,d0
		bne.s	5$
		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will have something
5$		PUT.w	d0,TB_MainSec
		ISANALOGINUSE	d0
		beq.s	8$
		PUT.w	d0,TB_MainSave
		rts
8$		PUT.w	d0,TB_MainFroze
10$		rts
	
;--------------------------------------
oooo_fF_o_M	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_MainSec,d0
		BITCLEAR.w (M_VIDEO!M_ENCODER),d0
		bne.s	10$	;if jmp assume frozen (live shouldn't happen)
		GET.w	TB_MainFroze,d0
		bra.s	20$
5$		move.w	#M_DV1,d0	;lut mode
10$		PUT.w	d0,TB_MainFroze
20$		PUT.w	d0,TB_MainSec
		rts		
	
;--------------------------------------
XXXX_fF_o_M	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_MainSec,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_MainFroze,d0
		PUT.w	d0,TB_MainSec
		rts

*Lut mode
5$		GET.w	TB_MainSec,d0
		BITCLEAR.w (M_DV0!M_ENCODER),d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w (M_DV0!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_DV1,d0

10$		PUT.w	d0,TB_MainSec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_MainSave
		rts
15$		PUT.w	d0,TB_MainFroze
20$		rts		
	
;--------------------------------------
oooo_fF_X_M	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_MainSec,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		GET.w	TB_MainFroze,d0
		PUT.w	d0,TB_MainSec
		rts
*Lut mode
5$		GET.w	TB_MainSec,d0
		BITCLEAR.w (M_VIDEO!M_DV0),d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w (M_VIDEO!M_DV0),d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		move.w	#M_DV1,d0

10$		PUT.w	d0,TB_MainSec
		btst	#B_ENCODER,d0
		bne.s	15$
		PUT.w	d0,TB_MainFroze
		rts
15$		PUT.w	d0,TB_MainSave
20$		rts		

;--------------------------------------
XXXX_fF_X_M	tst.b	TB_LutBus(a5)
		beq.s	5$

*Lut mode	
		GET.w	TB_MainSec,d0
		BITCLEAR.w M_DV0,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_MainPri,d0
		BITCLEAR.w M_DV0,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		move.w	#M_DV1,d0
		bra.s	10$

5$		GET.w	TB_MainSec,d0
		bne.s	10$
		GET.w	TB_MainPri,d0
		bne.s	10$
		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will have something
10$		PUT.w	d0,TB_MainSec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_MainSave
		rts
15$		PUT.w	d0,TB_MainFroze
		rts
	
;--------------------------------------
xxxx_FF_x_M	GET.w	TB_MainSec,d0
		bne.s	5$
		GET.w	TB_MainPri,d0
		bne.s	5$
		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will have something
5$		PUT.w	d0,TB_MainSec
		ISANALOGINUSE	d0
		beq.s	8$
		PUT.w	d0,TB_MainSave
		move.w	#1,EF_NotDigital(a4)
		rts
8$		PUT.w	d0,TB_MainFroze
		rts
	
;--------------------------------------
oooo_Fo_o_M	PUT.w	#M_DV0,TB_MainSec
		PUT.w	#M_DV0,TB_MainFroze
		rts
	
;--------------------------------------
oooo_oF_o_M	PUT.w	#M_DV1,TB_MainSec
		PUT.w	#M_DV1,TB_MainFroze
		rts
;--------------------------------------
XXXX_dd_X_A_M	GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	10$
		
		PUT.w	d0,TB_MainSave	;dve in use
		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		rts

10$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_MainPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		

;--------------------------------------
oooo_dd_X_A_M	GET.w	TB_MainSec,d0
		BITPUT_I	(M_VIDEO!M_ENCODER),M_ENCODER,d0		
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		ISDVEINUSE	d0
		beq.s	10$

		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
10$		rts

;--------------------------------------
XXXX_dd_o_A_M	GET.w	TB_MainSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_MainPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_MainSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	200$

		move.w	(sp)+,d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		

200$		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave	;dve in use
		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		rts

;--------------------------------------
XXXX_dd_X_P_M	GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	20$
		
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		beq.s	10$
		
		GET.w	TB_MainSec,d0		
		TURNLIVEDVEOFF	d0
		bra.s	20$
		
10$		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		GET.w	TB_MainSec,d0
		bra.s	100$

20$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_MainPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		

;--------------------------------------
oooo_dd_X_P_M	GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	90$

		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		move.w	#(M_DVE!M_ENCODER),d0
		bra.s	100$
	
90$		move.w	#M_ENCODER,d0
100$		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		
;--------------------------------------
XXXX_dd_o_P_M	GET.w	TB_MainSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_MainPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_MainSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	20$
	
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	20$

		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave	;dve in use
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		rts

20$		move.w	(sp)+,d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		
		rts		
	
;--------------------------------------
XXXX_dd_X_N_M	GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	20$

		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	10$
		
		GET.w	TB_PrvwSec,d0		
		ISDVEINUSE	d0
		bne.s	10$
		
		GET.w	TB_MainSec,d0
		bra.s	200$
		
10$		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		bra.s	100$

20$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_MainPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_MainSave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_MainSec
200$		PUT.w	d0,TB_MainSave
		rts		

;--------------------------------------
oooo_dd_X_N_M	GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	90$

		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		move.w	#(M_DVE!M_ENCODER),d0
		bra.s	100$
	
90$		move.w	#M_ENCODER,d0
100$		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		
	
;--------------------------------------
XXXX_dd_o_N_M	GET.w	TB_MainSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_MainPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_MainSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		beq.s	20$
	
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	20$

		GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		bne.s	20$

		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave	;dve in use
		rts

20$		move.w	(sp)+,d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		
		rts		
		
;--------------------------------------
XXXX_DD_X_M	GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec
		
		GET.w	TB_MainSec,d0
		bne.s	100$

		GET.w	TB_MainPri,d0
		bne.s	100$

		GET.w	TB_MainSave,d0

100$		TURNLIVEDVEON	d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		
	
;--------------------------------------
oooo_DD_X_M	GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec

		move.w	#(M_DVE!M_ENCODER),d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave
		rts		

;--------------------------------------
XXXX_DD_o_M	GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		
		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_PrvwSec

		GET.w	TB_MainSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_MainPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_MainSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		TURNLIVEDVEON	d0
		PUT.w	d0,TB_MainSec
		PUT.w	d0,TB_MainSave	;dve in use
		rts
   
;--------------------------------------
oooo_oo_o_P	clr.w	TB_PrvwSec(a5)	
		rts

;--------------------------------------
XXXX_oo_o_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut, only if save had encoder		
10$		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		

;--------------------------------------
oooo_oo_X_P	PUT.w	#M_ENCODER,TB_PrvwSec
		PUT.w	#M_ENCODER,TB_PrvwSave
		rts	

;--------------------------------------
XXXX_oo_X_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w M_DVE,d0	;will absolutely have some analog
10$		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		

;--------------------------------------
oooo_FF_o_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w (M_VIDEO!M_ENCODER),d0
		bne.s	10$	;if jmp assume frozen (live shouldn't happen)
		GET.w	TB_PrvwFroze,d0
		bra.s	20$
10$		PUT.w	d0,TB_PrvwFroze
20$		PUT.w	d0,TB_PrvwSec
		rts		

;--------------------------------------
XXXX_FF_o_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_PrvwFroze,d0
		PUT.w	d0,TB_PrvwSec
		rts
10$		PUT.w	d0,TB_PrvwSec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_PrvwSave
		rts
15$		PUT.w	d0,TB_PrvwFroze
20$		rts		

;--------------------------------------
oooo_FF_X_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		GET.w	TB_PrvwFroze,d0
		PUT.w	d0,TB_PrvwSec
		rts
10$		PUT.w	d0,TB_PrvwSec
		btst	#B_ENCODER,d0
		bne.s	15$
		PUT.w	d0,TB_PrvwFroze
		rts
15$		PUT.w	d0,TB_PrvwSave
20$		rts		

;--------------------------------------
XXXX_FF_X_P	GET.w	TB_PrvwSec,d0
		bne.s	5$
		GET.w	TB_PrvwPri,d0
		bne.s	5$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w M_DVE,d0	;will have something
5$		PUT.w	d0,TB_PrvwSec
		ISANALOGINUSE	d0
		beq.s	8$
		PUT.w	d0,TB_PrvwSave
		rts
8$		PUT.w	d0,TB_PrvwFroze
10$		rts

;--------------------------------------
oooo_fF_o_P	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_PrvwSec,d0
		BITCLEAR.w (M_VIDEO!M_ENCODER),d0
		bne.s	10$	;if jmp assume frozen (live shouldn't happen)
		GET.w	TB_PrvwFroze,d0
		bra.s	20$
5$		move.w	#M_DV1,d0	;lut mode
10$		PUT.w	d0,TB_PrvwFroze
20$		PUT.w	d0,TB_PrvwSec
		rts		

;--------------------------------------
XXXX_fF_o_P	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_PrvwSec,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_ENCODER,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_PrvwFroze,d0
		PUT.w	d0,TB_PrvwSec
		rts

*Lut mode
5$		GET.w	TB_PrvwSec,d0
		BITCLEAR.w (M_DV0!M_ENCODER),d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w (M_DV0!M_ENCODER),d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_DV1,d0

10$		PUT.w	d0,TB_PrvwSec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_PrvwSave
		rts
15$		PUT.w	d0,TB_PrvwFroze
20$		rts		

;--------------------------------------
oooo_fF_X_P	tst.b	TB_LutBus(a5)
		bne.s	5$

		GET.w	TB_PrvwSec,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_VIDEO,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		GET.w	TB_PrvwFroze,d0
		PUT.w	d0,TB_PrvwSec
		rts

*Lut mode
5$		GET.w	TB_PrvwSec,d0
		BITCLEAR.w (M_VIDEO!M_DV0),d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w (M_VIDEO!M_DV0),d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w (M_VIDEO!M_DVE),d0
		bne.s	10$
		move.w	#M_DV1,d0

10$		PUT.w	d0,TB_PrvwSec
		btst	#B_ENCODER,d0
		bne.s	15$
		PUT.w	d0,TB_PrvwFroze
		rts
15$		PUT.w	d0,TB_PrvwSave
20$		rts		

;--------------------------------------
XXXX_fF_X_P	tst.b	TB_LutBus(a5)
		beq.s	5$

*Lut mode	
		GET.w	TB_PrvwSec,d0
		BITCLEAR.w M_DV0,d0
		bne.s	10$	;if jmp assume live can't happen
		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_DV0,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w M_DVE,d0
		bne.s	10$
		move.w	#M_DV1,d0
		bra.s	10$

5$		GET.w	TB_PrvwSec,d0
		bne.s	10$
		GET.w	TB_PrvwPri,d0
		bne.s	10$
		GET.w	TB_PrvwSave,d0
		BITCLEAR.w M_DVE,d0	;will have something
10$		PUT.w	d0,TB_PrvwSec
		ISANALOGINUSE	d0
		beq.s	15$
		PUT.w	d0,TB_PrvwSave
		rts
15$		PUT.w	d0,TB_PrvwFroze
		rts

;--------------------------------------
oooo_Fo_o_P	PUT.w	#M_DV0,TB_PrvwSec
		PUT.w	#M_DV0,TB_PrvwFroze
		rts

;--------------------------------------
oooo_oF_o_P	PUT.w	#M_DV1,TB_PrvwSec
		PUT.w	#M_DV1,TB_PrvwFroze
		rts

;--------------------------------------
XXXX_dd_X_A_P	GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		beq.s	10$
		
		PUT.w	d0,TB_PrvwSave	;dve in use
		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		rts

10$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_PrvwSave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		

;--------------------------------------
oooo_dd_X_A_P	GET.w	TB_PrvwSec,d0
		BITPUT_I	(M_VIDEO!M_ENCODER),M_ENCODER,d0		
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		ISDVEINUSE	d0
		beq.s	10$

		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
10$		rts

;--------------------------------------
XXXX_dd_o_A_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_PrvwPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_PrvwSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		bne.s	200$

		move.w	(sp)+,d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		

200$		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave	;dve in use
		GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		rts

;--------------------------------------
XXXX_dd_X_N_P	GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		beq.s	20$

		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	10$
		
		GET.w	TB_MainSec,d0		
		ISDVEINUSE	d0
		bne.s	10$
		
		GET.w	TB_PrvwSec,d0
		bra.s	200$
		
10$		GET.w	TB_PrvwSec,d0
		TURNLIVEDVEOFF	d0
		bra.s	100$

20$		tst.w	d0	;dve not in use
		bne.s	100$

		GET.w	TB_PrvwPri,d0
		BITCLEAR.w M_DVE,d0	;will have something
		tst.w	d0
		bne.s	100$

		GET.w	TB_PrvwSave,d0
		BITCLEAR.w M_DVE,d0	;will have something

100$		PUT.w	d0,TB_PrvwSec
200$		PUT.w	d0,TB_PrvwSave
		rts		

;--------------------------------------
oooo_dd_X_N_P	GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		beq.s	90$

		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	90$
		
		move.w	#(M_DVE!M_ENCODER),d0
		bra.s	100$
	
90$		move.w	#M_ENCODER,d0
100$		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		
	
;--------------------------------------
XXXX_dd_o_N_P	GET.w	TB_PrvwSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_PrvwPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_PrvwSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		move.w	d0,-(sp)
		GET.w	TB_PrvwSec,d0
		ISDVEINUSE	d0
		beq.s	20$
	
		GET.w	TB_OLaySec,d0
		ISDVEINUSE	d0
		bne.s	20$

		GET.w	TB_MainSec,d0
		ISDVEINUSE	d0
		bne.s	20$

		move.w	(sp)+,d0
		TURNLIVEDVEON	d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave	;dve in use
		rts

20$		move.w	(sp)+,d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		
		rts		
		
;--------------------------------------
XXXX_DD_X_P	GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec
		
		GET.w	TB_PrvwSec,d0
		bne.s	100$

		GET.w	TB_PrvwPri,d0
		bne.s	100$

		GET.w	TB_PrvwSave,d0

100$		TURNLIVEDVEON	d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		
	
;--------------------------------------
oooo_DD_X_P	GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec

		move.w	#(M_DVE!M_ENCODER),d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave
		rts		

;--------------------------------------
XXXX_DD_o_P	GET.w	TB_OLaySec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_OLaySec
		
		GET.w	TB_MainSec,d0
		TURNLIVEDVEOFF	d0
		PUT.w	d0,TB_MainSec

		GET.w	TB_PrvwSec,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$		

		GET.w	TB_PrvwPri,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$

		GET.w	TB_PrvwSave,d0
		BITCLEAR.w	(M_DVE!M_ENCODER),d0
		bne.s	10$
		move.w	#M_VIDEO1,d0	;CopOut

10$		TURNLIVEDVEON	d0
		PUT.w	d0,TB_PrvwSec
		PUT.w	d0,TB_PrvwSave	;dve in use
		rts

****************************************************************
* d0=FGcommand, a0->logicTbl, a1->TBar/AutoHandler a2->data, a3->FG, a4->EFXlib, a5->TB

ProcessEffect:
	movem.l	d0-d7/a0-a6,-(sp)

	DEBUGREG	DBPE,<ProcessEffect:d0-pecmd>

	cmpi.w	#PEtblSIZE,d0
	bhi.s	10$

	lea	PEtbl,a6
	add.w	d0,d0
	add.w	d0,d0
	movea.l	0(a6,d0.w),a6	;->command
	jsr	(a6)
10$	movem.l	(sp)+,d0-d7/a0-a6
	rts

PEgenfg
PEnumval	;need Still Load/Save calls
PEupdate
PErawkey
PEunload
PEmousexy
PEbg
PEborder
PEstdefx

PEpanel
PEnext
PEtomain
PEtoprvw
	DEBUGMSG DBPE,<PEunknown command:>

	rts

*---------------------------------------------------------------
PEload:
	DEBUGMSG DBPE,<PEload:>

	XJSR	StuffFCount	;a3->FG
	XJSR	StuffNumFrames	;bogus for ANIMS, so they never call this.
	PUT.w	#0,TB_ErrFlag	;No errors were allowed.
	rts

PEframecount:
	DEBUGMSG DBPE,<PEframecount:>

	XJSR	StuffFCount	;a3->FG  (DON'T CURRENTLY UPDATE TB_NumFramesVariable ***!!!**)	
	
* This will copy 0 to NumFramesVariable for ANIMs
	movea.l	a3,a0
	move.l	#TAGID_VariableFCount,d0
	XJSR	AreWeFast
	bne.s	5$			; If 68020/68030/68040, Default Speed.
	move.l	#TAGID_VariableFCount68000,d0
5$	CALLTL	GetLongValue

	addq.w	#1,d0			;round up to nearest frame
	lsr.w	#1,d0
	PUT.w	d0,TB_NumFramesVariable

	move.l	d0,d1
	move.l	#TAGID_NumFramesVariable,d0
	JUMPTL	PutLongValue


*---------------------------------------------------------------
PEselect:
PEselectk:
PEselectq:
	DEBUGHEXI.l DBPE,<PEselect/k/q: FG=>,a3,<\>

	movea.l	a3,a0			;->FG used by DoHiLiteSelectQ
	cmp.l	TB_EfxFG(a5),a0		;
	beq	20$			;Jump if already selected.

5$	move.w	#1,EF_TakeFlag(a4)		;assume take of previous EFX
	btst.b	#TRIMARK_BIT,FG_Flags1(a3)	;is it trimarked?
	bne.s	8$
	cmpa.l	EF_TriMarkedEFX(a4),a3
	bne.s	10$

* Clicked on TriMarked crouton or the FX thats working with TriMarked ones.
8$	clr.w	EF_TakeFlag(a4)		;Don't take previous crouton
	CALLTL	DoHiLiteSelect		;Used to call DoHiLiteSelectQ or DoHiLiteSelectK for FGC_SelectQ or FGC_SelectK
	move.w	#1,EF_TakeFlag(a4)	;(probably done by remove) assume take of previous EFX
	tst.w	d0
	beq	20$			;return if already Selected

	PUT.w	EF_OldTBarTime(a4),TB_TBarTime
	PUT.w	EF_OldTBar(a4),TB_TValSec
	bge	18$
	clr.w	TB_TValSec(a5)
	clr.w	TB_TBarTime(a5)
	bra	18$

* normal take (clicked on a new crouton, might be a new Fade)
10$	GET.l	TB_EfxFG,d2

	move.l	EF_TriMarkedEFX(a4),d0
	beq	12$

;;	DEBUGHEXI.l DBPE,<PEselectq TB_EfxFG=>,d0,<\>
	PUT.l	d0,TB_EfxFG

12$	CALLTL	DoHiLiteSelect		;Used to call DoHiLiteSelectQ or DoHiLiteSelectK for FGC_SelectQ or FGC_SelectK
	move.w	#1,EF_TakeFlag(a4)	;(probably done by remove) assume take of previous EFX
	tst.w	d0
	bne	13$

;Already selected, so restore back to our original TB_EfxFG
;;	DEBUGHEXI.l DBPE,<PEselectq2 TB_EfxFG=>,d2,<\>
	PUT.l	d2,TB_EfxFG
	bra.s	20$

13$	bsr	KillTransTriMarks
	movea.l	EF_EffectsTable(a4),a0
	move.l	a0,EF_CurrentEffectsTable(a4)

18$	XJSR	StuffFCount	;a3->FG
	XJSR	StuffNumFrames	;bogus for ANIMS

* Added the UpdateDisplay because Editor Croutons don't go through the
* old MBDispatch stuff that would have done the update.
20$	XJSR	UpdateDisplay		; else do a selective update
	clr.w	TB_ErrFlag(a5)	;No error ever encountered during Select
	rts

*---------------------------------------------------------------
PEremove:
PEremoveq:
	DEBUGHEXI.l DBPE,<PEremove/q: FG=>,a3,<\>

	tst.w	EF_TakeFlag(a4)
	bgt.s	10$			;1=Take this crouton

* -1= Don't take this crouton, but don't TriMark it.
*  0= Don't take this crouton, and TriMark it.
*  1= Take this crouton

	move.l	a3,EF_TriMarkedEFX(a4)
	tst.w	EF_TakeFlag(a4)
	bmi.s	20$
	bset.b	#TRIMARK_BIT,FG_Flags1(a3)	;mark old effect
	bra.s	20$

10$	clr.l	EF_TriMarkedEFX(a4)
	bclr.b	#TRIMARK_BIT,FG_Flags1(a3)

	PUT.w	EF_OldTBarTime(a4),TB_TBarTime
	PUT.w	EF_OldTBar(a4),TB_TValSec
	bge.s	9$

	clr.w	TB_TValSec(a5)
	clr.w	TB_TBarTime(a5)
	bra.s	5$	
9$	bsr	DoTake			;not too quiet!!!!

5$	bsr	FixBorder
20$	move.w	#1,EF_TakeFlag(a4)		;assume take of previous EFX

* Effects that use DVE borders will set this bit after their SELECT
	bclr.b	#EFFECTBORDERCOLOR_BIT,TB_Flags2(a5)	  ;Can't use DVE border color
	move.l	a3,a0
	JUMPTL	DoHiLiteRemove	;Used to jump to DoHiLiteRemoveQ for FGC_RemoveQ

*---------------------------------------------------------------
* a5->TB
KillTransTriMarks
	movem.l	d0-d1/a0-a1/a4,-(sp)

	GET.l	TB_EFXbase,a4

	move.l	EF_TriMarkedEFX(a4),d0
	beq.s	10$
	clr.l	EF_TriMarkedEFX(a4)
	move.l	d0,a0
	bclr.b	#TRIMARK_BIT,FG_Flags1(a0)

10$	move.l	EF_TriMarkedLUT(a4),d0
	beq.s	15$
	GET.l	TB_EfxFG,EF_TriMarkedEFX(a4)

	move.l	d0,a0
	CALLTL	DoHiLiteRemove	;used to be DoHiLiteRemoveQ

15$	move.l	EF_TriMarkedFade(a4),d0
	beq.s	18$
	move.l	d0,a0
	bclr.b	#TRIMARK_BIT,FG_Flags1(a0)
	CALLTL	DoHiLiteRemove	;used to be DoHiLiteRemoveQ
	clr.w	EF_TValFade(a4)
	clr.l	EF_TriMarkedFade(a4)

	DEA.l	TB_VTSetUp,a0
	ELHGET_CD	a0,d0
	cmpi.w	#VTI_CD_SHOWB,d0
	beq.s	18$
	ELHPUT_CD_I	a0,VTI_CD_SHOWB	
	XJSR	ServeELH

18$	move.w	#-1,EF_OldTBar(a4)  ;don't clear until other effects have been removed
	move.w	#-1,EF_OldStage(a4)

	movem.l	(sp)+,d0-d1/a0-a1/a4
	rts
	
*---------------------------------------------------------------
PEfload:
	DEBUGMSG DBPE,<PEfload:>

;;	CALLTL	LUToff
;;	tst.w	EF_OldTBar(a4)
;;	blt.s	10$
;;	bsr	ProcessTake
;;	CALLTL	InstallAVEIdoELH	
;;	bsr	DoTake

10$	GET.w	TB_MainSec,d0
	ISLIVEDVEON	d0
	beq.s	15$
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_MainSec

15$	GET.w	TB_OLaySec,d0
	ISLIVEDVEON	d0
	beq.s	20$
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_OLaySec

20$	CALLTL	NoTransFreeze

;;	PUT.w	#VIDEOTYPE_FREEZE4,TB_VideoFlagSec
;;	CALLTL	CookAndServeFreeze

;;	 bsr	FlashFreezeThaw
	CALLTL	SetLoadBank

	GET.w	TB_OLaySec,d0
	move.w	d0,-(sp)		;save OLay
	cmp.w	TB_PrvwSec(a5),d0
	beq.s	24$

	tst.w	ShiftedKey
	beq.s	25$
	XCALL	ExitShiftedKey
	
24$	clr.w	TB_OLaySec(a5)	;don't allow keying during load
	
25$	CALLTL	CookMain
	GET.w	TB_PrvwSec,-(sp)
	PUT.w	#M_ENCODER,TB_PrvwSec	;set to black ??????
	CALLTL	CookAndServePrvw

	CALLTL	ProcessLoadButton
	PUT.w	(sp)+,TB_PrvwSec
	CALLTL	CookPrvw

	PUT.w	(sp)+,TB_OLaySec	;restore overlay
	JUMPTL	CookAndServeOLay
	
*---------------------------------------------------------------
PEfsave:
	DEBUGMSG DBPE,<PEfsave:>

;;	CALLTL	LUToff
;;	tst.w	EF_OldTBar(a4)
;;	blt.s	10$
;;	bsr	ProcessTake
;;	CALLTL	InstallAVEIdoELH
;;	bsr	DoTake

* Most of this stuff involving MainSec and OLaySec is probably not important
* since we must show MATTE during grabbing anyway.

10$	GET.w	TB_MainSec,d0
	ISLIVEDVEON	d0
	beq.s	15$
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_MainSec

15$	GET.w	TB_OLaySec,d0
	ISLIVEDVEON	d0
	beq.s	20$
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_OLaySec

20$	CALLTL	KillAlphaKey
	CALLTL	NoTransFreeze

;;	PUT.w	#VIDEOTYPE_FREEZE4,TB_VideoFlagSec
;;	CALLTL	CookAndServeFreeze  ;was CookFreeze pre 1-9-92

;;	 bsr	FlashFreezeThaw
	CALLTL	SetSaveBank

	GET.w	TB_OLaySec,d0
	move.l	d0,-(sp)		;save OLay
	cmp.w	TB_PrvwSec(a5),d0
	beq.s	24$

	tst.w	ShiftedKey
	beq.s	25$
	XCALL	ExitShiftedKey
24$	clr.w	TB_OLaySec(a5)	;don't allow keying during load

25$ ;;	CALLTL	CookMain
    ;;	CALLTL	CookAndServePrvw	;used this pre 1-9-92
	
	CALLTL	CookAndServeMain

	moveq.l	#0,d0
	CALLTL	NewProcessSaveButton
	move.l	(sp)+,d0
	PUT.w	d0,TB_OLaySec
	JUMPTL	CookAndServeOLay

*---------------------------------------------------------------
PEfreeze:
	DEBUGMSG DBPE,<PEfreeze:>

	tst.w	EF_OldTBar(a4)
	blt	10$

	GET.w	TB_VideoFlagSec,d0
	BITSETTEST.l	EKE_LIVE,EKE_flags(a0),d1
	beq.s	2$	
	move.w	#VIDEOTYPE_LIVE,d0
	bra.s	4$

2$	BITSETTEST.l	EKE_FROZE,EKE_flags(a0),d1
	beq.s	4$
	move.w	#VIDEOTYPE_FREEZE4,d0

4$	PUT.w	d0,TB_VideoFlagSec
	cmpi.w	#VIDEOTYPE_LIVE,d0
	bne	5$

* Going to live
* LINP may be set/clear if TSE or TDE transition
	CALLTL	KillAlphaKey
	bsr	ProcessLUToff
	bsr	ProcessFreezeButton
	bsr	ProcessDuring

* if DVEs are to be shown, flood DVs with live DVE source 1st
	GET.w	TB_OLaySec,d0
	ISLIVEDVEON	d0
	beq.s	110$
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_OLaySec
	bsr	300$
	TURNLIVEDVEON	d0
	PUT.w	d0,TB_OLaySec
	bra	190$

110$	GET.w	TB_MainSec,d0
	ISLIVEDVEON	d0
	beq.s	120$
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_MainSec
	bsr	300$
	TURNLIVEDVEON	d0
	PUT.w	d0,TB_MainSec
	bra	190$

120$	GET.w	TB_PrvwSec,d0
	ISLIVEDVEON	d0
	beq	200$		;jump if no rows have live DVE (just analog)
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_PrvwSec
	bsr	300$
	TURNLIVEDVEON	d0
	PUT.w	d0,TB_PrvwSec
	bra.s	190$

* Going to froze4 (froze8?)
5$	GET.w	TB_OLaySec,d0
	ISDVEINUSE	d0
	bne.s	8$

	GET.w	TB_MainSec,d0
	ISDVEINUSE	d0
	bne.s	8$

	GET.w	TB_PrvwSec,d0
	ISDVEINUSE	d0
	bne.s	8$

	move.l	a0,-(sp)
	DEA.l	TB_VTSetUp,a0
	CALLTL	Mask2IS
	ELHPUT_IS_R	a0,d0
	movea.l	(sp)+,a0

* assume it was live and only analog is shown, so flood both banks
* with Prvw source
	CALLTL	InterruptsOff
	move.l	a0,-(sp)
	lea.l	elh2(pc),a0		;->VTSetUp destroyed
	CALLTL	SendELHList2Toaster
	move.l	(sp)+,a0		;used by ProcessDuring
	moveq	#7,d0
7$	CALLTL	Wait4Top		;flood both banks with
	dbra	d0,7$
	CALLTL	InterruptsOn

8$	bsr	ProcessFreezeButton
190$ ;;	bsr	ProcessDuring
	bsr	updatemidtrans

200$	XJSR	ServeFreeze
	bra.s	20$

10$	CALLTL	CookAndServeFreeze
20$ ;;	 bra	FlashFreezeThaw		;a0->logic
	rts

* flood banks just prior to going to live DVE
300$	move.l	d0,-(sp)

;;	bsr	ProcessDuring
	bsr	updatemidtrans

	CALLTL	InterruptsOff
	XJSR	ServeFreeze	;goto live

	moveq	#7,d0
307$	CALLTL	Wait4Top
	dbra	d0,307$
	CALLTL	InterruptsOn
	move.l	(sp)+,d0
	rts

PEclip:
	DEBUGMSG DBPE,<PEclip:>

	tst.w	EF_OldTBar(a4)
	blt	10$

	GET.w	TB_KeyModeSec,d0
	cmp.w	TB_KeyModePri(a5),d0
	beq.s	3$
	BITSETTEST.l	EKE_LOCKKEY,EKE_flags(a0),d0
	beq.s	4$
	move.w	TB_KeyModePri(a5),TB_KeyModeSec(a5)  ;don't allow change
	rts

* probably changed clip, cause KeyMode didn't change
3$	BITSETTEST.l	EKE_LOCKCLIP,EKE_flags(a0),d0
	beq.s	4$
	move.w	TB_ClipAPri(a5),TB_ClipASec(a5)  ;don't allow change
	rts

4$	GET.w	TB_TValSec,-(sp)
	GET.w	TB_TBarTime,-(sp)

	PUT.w	EF_OldTBarTime(a4),TB_TBarTime
	PUT.w	EF_OldTBar(a4),TB_TValSec ;Effects TBar (not Fade In/Out)
	bsr	ProcessDuring

	PUT.w	(sp)+,TB_TBarTime
	PUT.w	(sp)+,TB_TValSec

	GET.w	TB_KeyModeSec,d0
	cmp.w	TB_KeyModePri(a5),d0
	bne.s	8$
	XJMP	ServeELH

*------------	
* Changed KeyMode
* NOTE!!! This currently flashes WIPE effects, because it assumes the WIPE
* needs to be remade, just like a DVE, though it really doesn't.

*!!!! Isn't there a better way ????????? i.e. with Freeze, matte etc.
8$	move.l	a2,-(sp)
	DEA.l	TB_VTSetUp,a2

* LINP may be set/clear if TSE or TDE transition
	moveq	#1,d0
	ELHTEST_LINP	a2
	bne.s	887$
	moveq	#0,d0

	ELHCLEAR_LINP	a2
	ELHTEST_LUT	a2
	bne.s	887$

	ELHSET_LINP	a2

	bset.b	#(VTB_LINP)-8,Old0RG+2	;trick ChangeClip, trick ChangeIS

887$	move.w	d0,-(sp)

88$	ELHGET_CD	a2,d0
	move.w	d0,-(sp)	 ;stash CD
	ELHGET_CDS	a2,d0
	move.w	d0,-(sp)	 ;stash CDS

	cmpi.w	#VTI_CDS_CD,d0		;was fade
	beq.s	889$

	ELHPUT_CDS_I	a2,VTI_CDS_CD	;Amiga supplied the key
	ELHPUT_CD_I	a2,VTI_CD_SHOWA
	ELHSET_NOKEYSHIFT	a2

	ELHSET_NOKEYINVERT	a2
	cmpi.w	#VTI_CDS_LUMKEY,d0
	bne.s	889$
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	889$			;jump if keying on black
	ELHCLEAR_NOKEYINVERT	a2
	
* Can I use ServerELH here ?????????????????????
889$	XJSR	ServeAVEI  ;going to distroy current nulls (may be in GEOMETRY mode)
	
	move.w	(sp)+,d0
	ELHPUT_CDS_R	a2,d0
	move.w	(sp)+,d0
	ELHPUT_CD_R	a2,d0
	
	ELHCLEAR_LINP	a2
	move.w	(sp)+,d0	
	beq.s	886$

	ELHSET_LINP	a2	

886$	movea.l	(sp)+,a2

	bclr.b	#0,TB_CycleFlags(a5)
	moveq	#FIELDREDO,d1

;;	GET.w	TB_TValSec,d0
;;	move.w	EF_OldTBar(a4),d0	;Effects TBar (not Fade In/Out)
;;	PUT.w	d0,TB_TValSec

	GET.w	TB_TValSec,-(sp)
	GET.w	TB_TBarTime,-(sp)

	PUT.w	EF_OldTBarTime(a4),TB_TBarTime
	move.w	EF_OldTBar(a4),d0
	PUT.w	d0,TB_TValSec
	jsr	(a1)		;install new display

	PUT.w	(sp)+,TB_TBarTime
	PUT.w	(sp)+,TB_TValSec

	bset.b	#0,TB_CycleFlags(a5)
	rts

10$	CALLTL	KillAlphaKey		;don't confuse other croutons if they
					;want to lumkey, while Key was up.
	JUMPTL	CookAndServeClipA

****************************************************
* TB_TagID=tag item ID (ignores CTRL WORD)
* TB_TagData->destination tag data
* TB_TagSize=destination tag size 
*
* Result=stashes ->TB_TagData with croutons tag lists value
* If the source/destination sizes don't agree, the operation fails.
* If source item didn't exist, TB_ErrFlag = -1
PEgetvalue:
	DEBUGMSG DBPETAGS,<PEgetvalue:>

	PUT.w	#-1,TB_ErrFlag			;assume error

	move.l	FGS_TagLists(a3),d0	;offset
	beq	666$			;no TagLists offset
	lea	0(a3,d0.l),a0		;search link lists

	DEBUGMSG DBPETAGS,<PEgetvalue Got a valid TagList>

	GET.l	TB_TagID,d0
	GET.l	TB_TagSize,d1	;destination size

	CALLTL	SearchLists4TagGetID
	tst.l	d0
	beq	666$
	clr.w	TB_ErrFlag(a5)

	DEBUGMSG DBPETAGS,<PEgetvalue found a source tag item>

	movea.l	d0,a0		;->source TAG
	GET.l	TB_TagData,a1	;->destination DATA	
	move.l	d1,d0		;destination size

	DEBUGREG DBPETAGS,<Before MoveTag2Value>,<\>	

	CALLTL	MoveTag2Value

666$	rts

*-------------------------------------
* TB_TagID=tag item ID (ignores CTRL WORD)
* TB_TagData->source tag data
* TB_TagSize=source tag size 
*
* Result=stashes TB_TagData into croutons tag lists
* If destination didn't exist, TB_ErrFlag = -1
* If the source/destination sizes don't agree, the destination is "NULLed".
*
* If there's a chance you are putting a NEW tag item. Then you should use
* the FGC_UPDATETAG command.  Though, this will create lots of Tag list
* nodes if you are putting many individual tags items.  In which case, you
* should consider one single FGC_LOADTAGS command instead.
PEputvalue:
	DEBUGMSG DBPETAGS,<PEputvalue:>

* The follow lines could be replaced with a FGC_TagInfoCommand
	PUT.w	#-1,TB_ErrFlag			;assume error

	move.l	FGS_TagLists(a3),d0	;offset
	beq	666$			;no TagLists offset

	lea	0(a3,d0.l),a0		;search link lists

	GET.l	TB_TagID,d0		;TagCTRL+TagID	
	GET.l	TB_TagSize,d1		;Source size
	CALLTL	SearchLists4TagPutID
	tst.l	d0
	beq	666$
	clr.w	TB_ErrFlag(a5)

	DEBUGMSG DBPETAGS,<PEputvalue found a dest tag item>

	movea.l	d0,a0		;->Destination TAG
	GET.l	TB_TagData,a1	;->Source DATA	
	move.l	d1,d0		;Source size
	CALLTL	MoveValue2Tag

666$	rts


*-------------------------------------
* TB_TagID=tag item ID (ignores CTRL WORD)
*
* returns TB_TagData->tag data (LONG or TABLE)
*         TB_TagSize=source tag size (4 or some WORD table size)
PEtaginfo
	clr.w	TB_ErrFlag(a5)		;no errors possible
	clr.l	TB_TagData(a5)		;assume can't find
	clr.l	TB_TagSize(a5)

	move.l	FGS_TagLists(a3),d0	;offset
	beq	666$			;no TagLists offset
	lea	0(a3,d0.l),a0		;search link lists

	GET.l	TB_TagID,d0		;TagCTRL+TagID	
	moveq.l	#0,d1			;Any size is OK (not supplying d2=mode)
	CALLTL	SearchLists4TagID	;WARNING ABOUT NULLING!!!!!
	tst.l	d0
	beq	666$
	
	DEBUGMSG DBPETAGS,<found a dest tag item>
	
	tst.l	TB_TagID(a5)
	bmi.s	10$			;jump if LONG tag

* STRUCT item
	movea.l	d0,a0
	PUT.l	TAG_EXTDATASIZE(a0),TB_TagSize		;assume long
	addq.l	#TAG_EXTDATA,d0
	bra.s	555$
	
* LONG item
10$	PUT.l	#4,TB_TagSize		;assume long
	addq.l	#TAG_DATA,d0

555$	PUT.l	d0,TB_TagData
666$	rts

*-------------------------------------
* TB_TagID=tag item ID (ignores CTRL WORD, except for LONG/TABLE flag)
* TB_TagData->source tag data
* TB_TagSize=source tag size 
*
* Result=stashes TB_TagData into croutons tag lists
*
* This will create lots of Tag list nodes if you are updating many
* individual new tags or new sized tag items.  In which case, you
* should consider one single FGC_LOADTAGS command instead.

PEupdatetag
	GET.l	TB_TagID,d0		;TagCTRL+TagID	
	GET.l	TB_TagSize,d1		;Source size
	GET.l	TB_TagData,a1
	movea.l	a3,a0
	JUMPTL	AddValue2FGtags		;Uses FGC_LoadTags (recursive!)


*-------------------------------------
* TB_TagID=tag item ID (ignores CTRL WORD)
* Marks this Tag Item so that it won't be saved in projects.
* This may be used when you want to temporarily use a Tag item.

PEunsavable
	movea.l	a3,a0
	GET.l	TB_TagID,d0
	moveq.l	#0,d1			;Any size is OK (not supplying d2=mode)
	CALLTL	SearchLists4TagID	;WARNING ABOUT NULLING!!!!!
	tst.l	d0
	beq.s	666$
	movea.l	d0,a0
	bclr.b	#TAGCTRL_UNSAVED-8,(a0)
666$	rts

*-------------------------------------
* TB_Tags = source tag list.
* Result = Source list is applied to the croutons Tag Lists.
* This applies a tag list to tag lists
* If the source/destination sizes don't agree, the destination is "NULLed".
* After first pass, all "New" items in the source are marked as such.
* The 2nd pass adds these "New" items to the destination linked lists
* as a new node.

PEloadtags:
	DEBUGMSG DBPE,<PEloadtags:>

	move.l	FGS_TagLists(a3),d0	;offset
	beq	666$			;no TagLists offset
	lea	0(a3,d0.l),a1		;destination link lists
	GET.l	TB_Tags,a0

;;	DEBUGMSG DBPE,<before ApplyTags2Lists>

	XJSR	ApplyTags2Lists	

****!!!!!****  not handling errors!!!!!
666$	rts



*---------
* I used this before I added the ApplyTags2Lists() function on 12-6-94
	IFD	CRAP

	move.l	FGS_TagLists(a3),d0	;offset
	beq	666$			;no TagLists offset
	lea	0(a3,d0.l),a2		;destination link lists

	GET.l	TB_Tags,a1
10$	moveq.l	#4,d1		;assume Tag size of 4
	movea.l	a1,a6
	move.l	(a1)+,d0	;TagCTRL+TagID
	beq	200$		;done with source tags
	bset.b	#TAGCTRL_NEW-8,(a6)	;assume this is a new item
	bmi.s	20$		;jump if standard LONG tag data
	move.l	(a1)+,d1	;size

20$	movea.l	a2,a0		;destination link lists

* If IDs match, but lengths differ, the PUT destination item is NULLed!!
	CALLTL	SearchLists4TagPutID
	beq	100$			;can't find tag item

****!!!!*** If it can't find a Tag value, it should then search for
****!!!!*** NULLed items that have the correct size.  So they can be
****!!!!*** used instead of putting the item into a new node.

	bclr.b	#TAGCTRL_NEW-8,(a6)	;its an old item

	DEBUGMSG DBPETAGS,<Found TagID in crouton>

	movea.l	d0,a0		
	move.l	d1,d0		;source size
	CALLTL	MoveValue2Tag

100$	adda.l	d1,a1		;do next tag
	bra	10$	

* Finished with 1st pass.  Now check for NEW items.
200$	GET.l	TB_Tags,a0	;->source tag list
	XJSR	GetSizeOfNewItems

	DEBUGUDEC.l DBPETAGS,<SizeOfNewItems to add=>,d0,<\>

	tst.l	d0
	beq.s	666$
				;d0=size of total items
				;a0->source tag list
	movea.l	a2,a1		;->destination linked lists
	XJSR	AddNewItems2Lists

****!!!!!****  not handling errors!!!!!

666$	rts


	ENDC


*-------------------------------------

* Result = TB_Tags->croutons Tag Lists.
PEsavetags:
	DEBUGMSG DBPE,<PEsavetags:>

	clr.l	TB_Tags(a5)		;assume no tags to save

	move.l	FGS_TagLists(a3),d0	;offset
	beq.s	666$			;no TagLists offset
	add.l	a3,d0			;search link lists
	PUT.l	d0,TB_Tags

666$	rts	

****************************************************

PEobutton:
	DEBUGMSG DBPE,<PEobutton:>

	tst.w	EF_OldTBar(a4)
	bpl	updatemidtransELH

	CALLTL	KillAlphaKey		;don't confuse other croutons if they
					;want to lumkey, while Key was up.

	DUMPMSG	<Before CookAndServeOLay>
	JUMPTL	CookAndServeOLay
	
PEmbutton:
	DEBUGMSG DBPE,<PEmbutton:>

	tst.w	EF_OldTBar(a4)
	bpl.s	updatemidtransELH
	JUMPTL	CookAndServeMain

PEpbutton:
	DEBUGMSG DBPE,<PEpbutton:>

	tst.w	EF_OldTBar(a4)
	bpl.s	updatemidtransELH
	JUMPTL	CookAndServePrvw

*------------
updatemidtransELH
	bsr	updatemidtrans

***!! For some unknown reason, sending out headers on an ILBM fx when
***!! mid-transition doesn't work (e.g. get garbage on Columns! FX).
***!! Most of the ILBM FX are latch fx anyway, and we can't change those
***!! sources by clicking on buses, so this probably isn't a big lose.
***!! Softedge ILBM circle wipes were losing some of the bits of their key!
	move.l	EF_FieldReinstall(a4),d1
	bne.s	5$	

	XJMP	ServeELH
5$	rts

*------------
updatemidtrans
	DEA.l	TB_VTSetUp,a6
	ELHTEST_AMWIPE	a6
	bne.s	3$

	ELHTEST_BMWIPE	a6
	bne.s	3$

	ELHTEST_ISWIPE	a6
	beq.s	4$

* Latching is in effect, so don't allow changes in Overlay, Main
3$	PUT.w	TB_MainPri(a5),TB_MainSec
	PUT.w	TB_OLayPri(a5),TB_OLaySec

4$	bsr	ProcessDuring

;;	moveq	#ELHREDO,d1
;;	GET.w	TB_TValSec,d0
;;	jsr	(a1)		;install new display


* ILBM FX will just return to the updatemidtrans caller. w/o any coplist
* install or sending any ELHs.
	move.l	EF_FieldReinstall(a4),d1
	beq.s	5$	
	move.l	d1,a6
	jmp	(a6)

* ANIM FX may modify the header bits after the above call to ProcessDuring
* Though this call will not send out any headers.
5$	move.l	EF_OverrideProcessDuring(a4),d1
	beq.s	6$	
	move.l	d1,a6
	jsr	(a6)

6$ ;;	XJMP	ServeELH
	rts

*------------

	IFD	DBSCRAWLS
cgnamecrawl:	
	dc.b	'nd3:Krawl',0
cgnamescroll:	
	dc.b	'nd3:SKroll',0
	CNOP	0,4
	ENDC

* a3->FG
PEtake:

	IFD	DBSCRAWLS
	movem.l	d0-d7/a0-a6,-(sp)
	DUMPMSG	<CG TEST LMB=Scroll, RMB=Crawl ****************>
	WAIT4LMBUP
	WAIT4RMBUP
	
10$	ISLMBUP
	beq.s	20$

	ISRMBUP
	bne.s	10$

	lea	cgnamecrawl(pc),a0
	XJSR	_TestMPcrawl
	bra.s	30$

20$	lea	cgnamescroll(pc),a0
	XJSR	_TestMPscroll

30$ 	DUMPSDEC.l	<cg test returned=>,d0,<\>	
	movem.l	(sp)+,d0-d7/a0-a6
	rts
	ENDC


petakestart:
	DEBUGMSG DBPE,<PEtake:>

	btst.b	#FLAGS1_SKIPTAKE,Flags1
	beq.s	5$
	bclr.b	#FLAGS1_SKIPTAKE,Flags1
	rts

5$	tst.w	EF_OldTBar(a4)
	blt.s	10$

	clr.w	TB_TValSec(a5)		;move tbar to top
	clr.w	TB_TBarTime(a5)
	move.w	#-1,EF_OldTBar(a4)
	move.w	#-1,EF_OldStage(a4)

* standard kind of keying
	DEA.l	TB_VTSetUp,a0
	ELHPUT_CDS_I		a0,VTI_CDS_CD
	ELHPUT_CD_I		a0,VTI_CD_SHOWB
	ELHSET_NOKEYINVERT 	a0
	ELHSET_NOKEYSHIFT	a0
	ELHSET_MATTE	a0	
	ELHCLEAR_AMWIPE	a0
	ELHCLEAR_BMWIPE	a0
	ELHCLEAR_ISWIPE	a0
	ELHSET_NOPAIRS	a0

	tst.w	TB_UserOn(a5)
	beq.s	8$
	ELHSET_USERON	a0
	ELHSET_PVMUTE	a0
	bra.s	10$
8$	ELHCLEAR_USERON	a0
	ELHCLEAR_PVMUTE	a0

10$ 	CALLTL	CookTake	;will clear overlay row
	bra	ServeAVE_AVEI

PEunauto:
	DEBUGMSG DBPE,<PEunauto:>

	move.l	EF_TimeStop(a4),d0
	bge.s	4$
	clr.l	EF_TimeStop(a4)
	neg.l	d0
	lsr.l	#7,d0
	PUT.w	d0,TB_TValSec
	bra	PEtbar

4$	tst.w	EF_OldTBar(a4)
	blt.s	10$

	bsr	MakeLive
	moveq	#1,d0		;unauto

* d0=auto/unauto, a0->logicTbl, a1->TBar/AutoHandler a2->data, a3->FG, d1=mode
* a4->EFXlib, a5->TB

;;	GET.l	TB_SYSBase,a6	; keep SoftSprite
;;	CALLROM	Forbid		; for the duration of the effect
;;	CALLTL	SoftSpriteOff	;incase theres any FG rendering within AUTO handler

	bclr.b	#0,TB_CycleFlags(a5)
	jsr	(a1)
	bset.b	#0,TB_CycleFlags(a5)
	bsr	ProcessUnTake	;a0->LogicTable
	bsr	ServeAVE_AVEI

;;	CALLTL	SoftSpriteOn
;;	JUMPROM	Permit

10$	rts

PEauto:
	DEBUGMSG DBPE,<PEauto:>

*** HACK TO GET OUT OF CG KEYING MODE
	IFD	KILLKEYHACK
	movem.l	d0-d7/a0-a6,-(sp)

	GET.w	TB_OLaySec,d0
	DUMPHEXI.w	<at auto OLay=>,d0,<\>


	DEA.l	TB_VTSetUp,a0
	ELHGET_AM	a0,d0
	ELHPUT_BM_R	a0,d0
	ELHPUT_CDS_I	a0,VTI_CDS_CD
	ELHPUT_CD_I	a0,VTI_CD_SHOWB
	CALLTL SendELH2Toaster

	CALLTL	InstallAVE
	CALLTL	ReDoDisplay

	CALLTL	ResetAVEI
	CALLTL	InstallAVEI
	movem.l	(sp)+,d0-d7/a0-a6
	rts

	ENDC
***
	move.l	EF_TimeStop(a4),d0
	bge.s	4$

	clr.l	EF_TimeStop(a4)
	neg.l	d0
	lsr.l	#7,d0
	PUT.w	d0,TB_TValSec
	bra	PEtbar

4$	bsr	MakeLive
	moveq	#0,d0		;auto 
;;	DUMPMSG	<NOT PETBAR>
* d0=auto/unauto, a0->logicTbl, a1->TBar/AutoHandler a2->data, a3->FG, d1=mode
* a4->EFXlib, a5->TB

;;	GET.l	TB_SYSBase,a6	; keep SoftSprite
;;	CALLROM	Forbid		; for the duration of the effect
;;	CALLTL	SoftSpriteOff	;incase theres any FG rendering within AUTO handler

	bclr.b	#0,TB_CycleFlags(a5)
;;	DUMPMSG	<JSR TO (A1)>	
	jsr	(a1)			;JUMPING TO TBAR/AUTO HANDLER
;;	DUMPMSG	<RETURNING FROM TO (A1)>	
	bset.b	#0,TB_CycleFlags(a5)

	tst.l	EF_TimeStop(a4)
	beq.s	10$
	clr.l	EF_TimeStop(a4)
	bra.s	20$

10$	bsr	ProcessTake	;a0->logictable
	bsr	ServeAVE_AVEI

20$
;;	CALLTL	SoftSpriteOn ;if on stop frame & anim make sure you've ImageryOff()ed
;;	JUMPROM	Permit
;;	DUMPMSG	<PEAUTO: DONE!>	
	rts

PEtbar:
	DEBUGMSG DBPE,<PEtbar:>

	bsr	MakeLive

* d1=display/mode, a0->logicTbl, a1->TBar/AutoHandler a2->data, a3->FG,
* a4->EFXlib, a5->TB

;;	GET.l	TB_SYSBase,a6	; keep SoftSprite
;;	CALLROM	Forbid		; for the duration of the effect
;;	CALLTL	SoftSpriteOff	;incase theres any FG rendering within AUTO handler

	btst.b	#EFFLAGS1_NODOTBAR,EF_Flags1(a4)
	beq.s	5$

*---------------
* Used by VT4000 ANIMs
	moveq	#0,d0		;not unauto (same as auto)
	bclr.b	#0,TB_CycleFlags(a5)
	jsr	(a1)
	
;;	move.w	#FIELDLAST,d1  ;redo last with interface up ????
;;	jsr	(a1)
	bset.b	#0,TB_CycleFlags(a5)
	bclr.b	#EFFLAGS1_NODOTBAR,EF_Flags1(a4)
	bra.s	8$

*---------------
5$	movea.l	a1,a6		;TBarHandler
	movea.l	a0,a1		;logicTbl
	
	lea	Ttime(pc),a0
;;	GET.w	TB_TValSec,d0

	cmpi.w	#FIELDFIRST,d1
	bne.s	6$
	bclr.b	#0,TB_CycleFlags(a5)
	jsr	(a0) 	;;Setup first frame before interrupts go off
	bset.b	#0,TB_CycleFlags(a5)

6$	CALLTL	InterruptsOff

* d1=display/mode, a0->Ttime, a1->logicTbl a2->data, a3->FG,
* a4->EFXlib, a5->TB, a6->TBarHandler
	
;;	jsr	(a0)
	
	CALLTL	DoTBar		;do additional fields

	move.w	#FIELDLAST,d1  ;redo last with interface up ????

	bclr.b	#0,TB_CycleFlags(a5)
	jsr	(a0)
	bset.b	#0,TB_CycleFlags(a5)
	CALLTL	InterruptsOn

	movea.l	a1,a0		;->LogicTable

*---
8$	GET.w	TB_TBarTime,d0		;assume we have hires time
	move.w	d0,d1
	lsr.w	#7,d1
	cmp.w	TB_TValSec(a5),d1	;look at lores time
	beq.s	9$			;jump if hires time is probably ok
	
* Fake HIRES Tbar position
	GET.w	TB_TValSec,d0		;use lores time
	cmpi.w	#TValMax,d0
	bne.s	33$
	move.w	#TBarTimeMax,d0
	bra.s	34$
33$	lsl.w	#7,d0
34$	PUT.w	d0,TB_TBarTime		;convert to hires time

9$	tst.w	d0
	beq.s	20$
	cmpi.w	#TBarTimeMax,d0
	bne.s	40$

* TBar all the way down
	DUMPMSG	<DOING A ProcessTake BECAUSE TBAR IS ALL THE WAY DOWN>	

	bsr	ProcessTake	;a0->LogicTable
	bra.s	25$

* TBar all the way up
20$	bsr	ProcessUnTake	;a0->LogicTable
25$	bsr	ServeAVE_AVEI

40$
;;	GET.l	TB_SYSBase,a6
;;	CALLTL	SoftSpriteOn	;if still within anim make sure you've ImageryOff()ed!!!!
;;	JUMPROM	Permit

	rts

;------------
* d0=time, d1=display/mode, a0->Ttime, a1->logicTbl a2->data, a3->FG,
* a4->EFXlib, a5->TB, a6->TBarHandler
* D1=FIRST, DURING, LAST
Ttime	movem.l	d0/a0,-(sp)
	movea.l	a1,a0

	tst.l	EF_PreProcessDuring(a4)
	beq.s	10$

	move.l	a6,-(sp)
	movea.l	EF_PreProcessDuring(a4),a6

	jsr	(a6)
	movea.l	(sp)+,a6

10$
	bsr	ProcessDuring
	or.l	d0,d1	;use ProcessDurings do ELH flag = FIELDDOELH or FIELDNOELH
	movem.l	(sp)+,d0/a0

	jsr	(a6)
	moveq	#FIELDDURING,d1	;assume during
	rts

;------------------------------------------------------------
* The guts of this routine can only happen if not mid-transition, but
* you could be LumKeying.
MakeLive 
	DEBUGMSG	DBML,<MakeLive>

	moveq	#FIELDDURING,d1	;assume during
	tst.w	EF_OldTBar(a4)
	bge	666$
	moveq	#FIELDFIRST,d1

	DEBUGMSG	DBML,<FIELDFIRST>

	GET.w	TB_TValSec,d0
	move.l	d0,-(sp)	;save tbar

	GET.w	TB_TValPri,d0
	bne.s	30$
	PUT.w	#0,TB_TValSec	;force 1st use of TBar to be at position 0
	clr.w	TB_TBarTime(a5)

30$	XCALL	ExitShiftedKey

	DEBUGMSG	DBML,<After ExitShiftedKey>

	bsr	StashStates

	DEBUGMSG	DBML,<After StashStates>

	move.l	a2,d0
	beq	10$
	move.l	(a2),d0
	beq	10$
	add.l	a2,d0		;using new offset instead of abs. ptr
	movem.l	a0/a1,-(sp)
	movea.l	d0,a0
	move.l	EF_CurrentEffectsTable(a4),a1

*	If you need to use your own ->effectstable, vs the internal
*	Algorithmic Effect EF_EffectsTable pointed to by EFXbase, then you
*	need to stuff your pointer into EF_CurrentEffectsTable before FG_AUTO,
*	FG_UNAUTO, or FG_TBAR commands.  It is best to do it right after
*	a successful FG_SELECT (making sure you really were selected).

	DEBUGMSG	DBML,<Before InitDynamic>

	CALLEF	InitDynamic
	movem.l	(sp)+,a0/a1	

	DEBUGMSG	DBML,<After InitDynamic>

10$	BITSETTEST.l	EKE_NOKEY,EKE_flags(a0),d0
	beq	12$
	tst.w	TB_KeyModeSec(a5)
	bge	12$

	DEBUGMSG	DBML,<before bclr>

	bclr.b	#B_KeyEnable-8,TB_KeyModeSec(a5)	;turn keying off
;;	bsr	UpdateClipMode

	DEBUGMSG	DBML,<Keying Turned Off>

12$	DEBUGMSG	DBML,<test liveifanalogs>

	BITSETTEST.l	EKE_LIVEIFANALOGS,EKE_flags(a0),d0
	beq	1$	

	DEBUGMSG	DBML,<tested liveifanalogs>

	cmp.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)
	beq	1$

	DEBUGMSG	DBML,<tested videotypelive>

	GET.w	TB_MainSec,d0
	ISDVEINUSE	d0
	bne	1$
	GET.w	TB_PrvwSec,d0
	ISDVEINUSE	d0
	bne	1$
	GET.w	TB_OLaySec,d0
	ISDVEINUSE	d0
	bne	1$

* will force it to LIVE
15$	DEBUGMSG	DBML,<Before LUToff, forcing to LIVE DVE>

	CALLTL	KillAlphaKey
	CALLTL	LUToff			;not within a transition (will send headers)
	move.w	#VIDEOTYPE_LIVE,d0
	bra	4$

* You would never have the EKE_FROZE/LIVE FLASH flags with the
* EKE_LIVE/FREEZE flags!

1$	DEBUGMSG	DBML,<No force to live dve>

	BITSETTEST.l	EKE_LIVE,EKE_flags(a0),d0
	bne	15$	

2$	BITSETTEST.l	EKE_FROZE,EKE_flags(a0),d0
	beq	5$
	move.w	#VIDEOTYPE_FREEZE4,d0

4$	cmp.w	TB_VideoFlagSec(a5),d0
	beq	5$			;jump if no change
	PUT.w	d0,TB_VideoFlagSec

	DEBUGMSG	DBML,<FreezeLive changed so ProcessFreezeThaw>

	bsr	ProcessFreezeThaw	;was ProcessFreezeButton pre 1-9-92
	XJSR	ServeFreeze	

	CALLTL	Wait4Top	;grabs analog source into DVs before DVE efx
	CALLTL	Wait4Top
	CALLTL	Wait4Top	

5$	DEBUGMSG	DBML,<End of MakeLive>

	move.l	(sp)+,d0
	PUT.w	d0,TB_TValSec	;restore tbar

666$	rts	;d1 = displaymode (FIRST/DURING)

;------------
* This could be called while mid-transition (ie wipe) when LIVE is turned on
* a3->FG
ProcessLUToff:	
	movem.l	d0-d1/a0-a2,-(sp)

	DEA.l	TB_VTSetUp,a0
	ELHTEST_LUT	a0
	beq	10$

* If coming out of LUT & going live. Make sure DV1 isn't shown before
* going live.
	cmpi.b	#M_LUTBUS_OLAY,TB_LutBus(a5)
	beq.s	72$
	GET.w	TB_OLaySec,d0
	cmpi.w	#M_DV1,d0
	bne.s	70$
	GET.w	TB_OLaySave,d0
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_OLaySec
	bra.s	70$

72$	cmpi.b	#M_LUTBUS_MAIN,TB_LutBus(a5)
	beq.s	74$
	GET.w	TB_MainSec,d0
	cmpi.w	#M_DV1,d0
	bne.s	70$
	GET.w	TB_MainSave,d0
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_MainSec
	bra.s	70$

74$	cmpi.b	#M_LUTBUS_PRVW,TB_LutBus(a5)
	beq.s	70$
	GET.w	TB_PrvwSec,d0
	cmpi.w	#M_DV1,d0
	bne.s	70$
	GET.w	TB_PrvwSave,d0
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_PrvwSec

70$	ELHCLEAR_LUT	a0
	ELHSET_LINP	a0	* LINP may be set/clear if TSE or TDE transition
	PUT.b	#M_LUTBUS_NONE,TB_LutBus
	PUT.l	#0,TB_ColorCycle	;what if someone else is using this??

	move.l	EF_TriMarkedLUT(a4),d0
	beq.s	5$
	clr.l	EF_TriMarkedLUT(a4)
	move.l	d0,a0
	bclr.b	#TRIMARK_BIT,FG_Flags1(a0)
	CALLTL	DoHiLiteRemove

5$	cmpa.l	EF_TriMarkedEFX(a4),a3
	bne.s	10$
	clr.l	EF_TriMarkedEFX(a4)	
	bclr.b	#TRIMARK_BIT,FG_Flags1(a3)

10$	movem.l	(sp)+,d0-d1/a0-a2
	rts

;----------
* a4->EF
ServeAVE_AVEI
	move.l	d0,-(sp)

	PUT.w	#INTF_SETCLR!INTF_COPER,TB_CopListIntreq

	btst.b	#EFFLAGS1_TEMPORARYSPRITE1,EF_Flags1(a4)
	beq.s	5$
	clr.l	TB_CurrentSprite1(a5)
	bclr.b	#EFFLAGS1_TEMPORARYSPRITE1,EF_Flags1(a4)

5$	btst.b	#EFFLAGS1_DISPLAYTRASHED,EF_Flags1(a4)
	beq.s	20$	
	bclr.b	#EFFLAGS1_DISPLAYTRASHED,EF_Flags1(a4)
	XJSR	ServeELH	;take it out of any weird modes
	CALLTL	InstallAVE
	CALLTL	ImageryOn

	btst.b	#4,TB_DisplayRenderMode(a5)
	bne.s	20$			;jump if sequencing

	CALLTL	ReDoDisplay
	CALLTL	InstallAVEI
	bra.s	30$

20$	XJSR	ServeAVEI  ;going to distroy current nulls (may be in GEOMETRY mode)

30$	btst.b	#EFFLAGS1_MATTETRASHED,EF_Flags1(a4)
	beq.s	100$
	bclr.b	#EFFLAGS1_MATTETRASHED,EF_Flags1(a4)
	move.w	EF_SavedMatte(a4),d0

;;	andi.w	#$8fff,d0	;clear flags
	CALLTL	SetMatteColor

100$	move.w	_custom+intenar,d0
	btst	#INTB_SOFTINT,d0
	bne.s	110$					 ;jump if it is already on
	move.w	#INTF_SOFTINT,_custom+intreq 		 ;clear it out
	move.w	#INTF_SETCLR!INTF_SOFTINT,_custom+intena ;enable soft interrupts

110$	move.l	(sp)+,d0
	rts

;----------
	IFD	CRAP	;Un/FlashFreezeThaw

; a0->logic
FlashFreezeThaw	movem.l	d0-d1,-(sp)
	GET.w	TB_VideoFlagSec,d0
	BITSETTEST.l	EKE_FROZEFLASH,EKE_flags(a0),d1
	beq.s	74$	

	cmpi.w	#VIDEOTYPE_LIVE,d0
	beq.s	70$
	CALLTL	FlashVideoOn

	bra.s	78$
70$	CALLTL	FlashVideoOff
	bra.s	78$

74$	BITSETTEST.l	EKE_LIVEFLASH,EKE_flags(a0),d1
	beq.s	78$	

	cmpi.w	#VIDEOTYPE_LIVE,d0
	beq.s	76$
	CALLTL	FlashVideoOff
	bra.s	78$
76$	CALLTL	FlashVideoOn
78$	movem.l	(sp)+,d0-d1
	rts

;----------
; a0->logic
UnFlashFreezeThaw	movem.l	d0-d1,-(sp)
	GET.w	TB_VideoFlagSec,d0
	BITSETTEST.l	EKE_FROZEFLASH,EKE_flags(a0),d1
	beq.s	74$	

	cmpi.w	#VIDEOTYPE_LIVE,d0
	beq.s	78$
	bra.s	75$

74$	BITSETTEST.l	EKE_LIVEFLASH,EKE_flags(a0),d1
	beq.s	78$	

	cmpi.w	#VIDEOTYPE_LIVE,d0
	bne.s	78$
75$	CALLTL	FlashVideoOff

78$	movem.l	(sp)+,d0-d1
	rts

	ENDC	;Un/FlashFreezeThaw

;----------
FixBorder
	tst.w	EF_BorderState(a4)
	bne.s	10$
	rts

10$	CALLTL	InstallAVEI	;was ave
	move.w	d0,-(sp)
	GET.w	TB_MainSave,d0	;get most recent analog
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_MainSec
	CALLTL	ShortOutFader	;need lut off ????
	moveq	#3,d0			;both banks
	CALLTL	RestoreBorderAVEI	;was RestoreBorderColor
	move.w	(sp)+,d0
	clr.w	EF_BorderState(a4)

;;	CALLTL	ReDoDisplay
;;	JUMPTL	InstallAVEI
	rts

***************************************************************
* a0->logicTbl, a1->TBarHandler, a2->data, a3->FG, a4->EFXlib, a5->TB
*
ProcessPosition:
	DUMPMSG	<ProcessPosition>	
	DEBUGMSG	DBPX,<ProcessPosition:>
	tst.w	EF_OldTBar(a4)
	bge	ProcessEffect
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	MakeLive	;returns d1=display/mode (FIRST/DURING)
	DEBUGMSG	DBPX,<AFTER MAKELIVE>
* d1=display/mode, a0->logicTbl, a1->TBar/AutoHandler a2->data, a3->FG,
* a4->EFXlib, a5->TB

* initialize to full centered, full screen.
;	DUMPMSG	<init to full screen>
	movea.l	a1,a6		;TBarHandler
	movea.l	a0,a1		;logicTbl

 ifeq	0
	
	moveq	#0,d0
	move.w	12(a2),d0	;SXSIZE
;	DUMPMEM	<effectdata>,(A2),#64
	swap	d0
	move.l	a2,a0
	adda.l	24(a2),a0	;->SXSIZE	
	move.l	d0,(a0)		;sizex
	move.l	d0,60(a2)
	
	neg.l	d0
	move.l	a2,a0
	adda.l	28(a2),a0		
	move.l	d0,(a0)		;sizexd
	move.l	d0,64(a2)

	moveq	#0,d0
	move.w	14(a2),d0	;SYSIZE
	swap	d0
	move.l	a2,a0
	adda.l	40(a2),a0	;->SYSIZE	
	move.l	d0,(a0)		;sizey
	move.l	d0,76(a2)
	
	neg.l	d0
	move.l	a2,a0
	adda.l	44(a2),a0		
	move.l	d0,(a0)		;sizeyd
	move.l	d0,80(a2)

	moveq	#0,d0
	move.l	a2,a0
	adda.l	16(a2),a0	;posx
	move.l	d0,(a0)
	move.l	d0,52(a2)

	move.l	a2,a0
	adda.l	20(a2),a0
	move.l	d0,(a0)		;posxd
	move.l	d0,56(a2)

	move.l	a2,a0
	adda.l	32(a2),a0
	move.l	d0,(a0)		;posy
	move.l	d0,68(a2)

	move.l	a2,a0
	adda.l	36(a2),a0
	move.l	d0,(a0)		;posyd
	move.l	d0,72(a2)

	clr.l	48(a2)		;TimeStop
 endc	
	
*----
	CALLTL	SoftSpriteOff	;incase theres any FG rendering within TBar handler
	XCALL	SomeInterruptsOff

	bclr.b	#0,TB_CycleFlags(a5)
	GET.w	TB_ButtonFlag,buttonstate ;stash it

* sizing ------

10$
	lea	Ttime(pc),a0

* d1=display/mode, a0->Ttime, a1->logicTbl a2->data, a3->FG,
* a4->EFXlib, a5->TB, a6->TBarHandler
	DEBUGMSG	DBPX,<BEFORE DoTBar>
	CALLTL	DoTBar	;do initial sizing

*----
	tst.l	4(a2)		;modes for reverse
	beq.s	12$

* DEF/WEF _REVERSE
	tst.w	d0
	bne	15$

	
* TBar all the way up or midtrans (on effect)
	pea	ProcessUnTake(pc)
	bra.s	20$

12$	cmpi.w	#TValMax,d0
	bne	15$

* TBar all the way down or midtrans (off effect)
	pea	ProcessTake(pc)
	
* Done with positioning (Take/UnTake routine on Stack!!)
20$	GET.w	TB_TValSec,d0
	move.w	#FIELDLAST,d1  ;redo last with interface up ????
	jsr	(a0)
	PUT.w	buttonstate,TB_ButtonFlag	;restore
	bset.b	#0,TB_CycleFlags(a5)
	XCALL	SomeInterruptsOn
	CALLTL	SoftSpriteOn
	
	DEBUGMSG	DBPX,<BEFORE ADJUSTPATH>
	bsr	adjustpath

	movea.l	a1,a0		;->LogicTable
	move.l	(sp)+,a1	;ProcessTake or UnTake()
	jsr	(a1)
	CALLTL	InstallAVEIdoELH
	bra	666$

	DEBUGMSG	DBPX,<AT TBAR NOT ALL THE WAY DOWN>
	

* TBar not all the way down

15$	move.l	a2,a0
	adda.l	16(a2),a0
	move.w	(a0),d0		;whole posx
	add.w	12(a2),d0	;+SXSIZE

	swap	d0	
	move.l	a2,a0
	adda.l	32(a2),a0
	move.w	(a0),d0		;whole posy
	add.w	14(a2),d0	;+SYSIZE

	move.w	12(a2),d1
	swap	d1
	move.w	14(a2),d1
	add.l	d1,d1
	move.w	10(a2),d2	;accel
	
	move.l	a1,-(sp)	;save ->logicTbl
	lea	positionxy(pc),a0
	lea	abortpositioning(pc),a1

;a0->"Tbar" render code
;a1->abort functions	
;d0=initialXY
;d1=limitsXY
;d2=accel

	DEBUGMSG	DBPX,<BEFORE DoMouseXY>
	CALLTL	DoMouseXY
	DEBUGMSG	DBPX,<After DoMouseXY>
	

	lea	Ttime(pc),a0
	movea.l	(sp)+,a1	;->logicTbl
	moveq	#FIELDDURING,d1

	PUT.w	#-1,TB_ButtonFlag	;assume RMB is pressed		
	cmpi.w	#4,d0		;RMB
	beq	10$		;go do more sizing

	cmpi.w	#1,d0
	bne.s	90$		;jump if not LMB

	CALLTL	Wait4LMBup	;avoid reselecting the TBar
	
	pea	ProcessTake(pc)
	tst.l	4(a2)		;modes for reverse
	beq	20$
	addq.w	#4,sp
	pea	ProcessUnTake(pc)
	bra	20$
	
90$	move.w	d0,d1		;abort mode
	bsr.s	adjustpath
	move.l	d0,48(a2)	;TimeStop

	cmpi.w	#3,d1		;Return
	bne.s	100$		;assume AUTO

	neg.l	48(a2)		;Indicate a Inset Take on Auto
	GET.w	TB_TValSec,d0
	move.w	#FIELDLAST,d1   ;redo last with interface up ????
	jsr	(a0)
	bset.b	#FLAGS1_SKIPTAKE,Flags1

* Assume Auto
100$	PUT.w	buttonstate,TB_ButtonFlag	;restore
	bset.b	#0,TB_CycleFlags(a5)
	XCALL	SomeInterruptsOn
	CALLTL	SoftSpriteOn

666$	movem.l	(sp)+,d0-d7/a0-a6
	rts

*-----------
* returns time stop position, and updates TValSec
adjustpath
	movem.l	d1-d7/a0-a6,-(sp)
	move.l	a2,a0
	adda.l	32(a2),a0
	move.w	(a0),-(sp)	;posy
	move.l	a2,a0
	adda.l	16(a2),a0
	move.w	(a0),-(sp)	;posx

	moveq	#0,d0
	GET.w	TB_TValSec,d0
	tst.l	4(a2)		;reverse mode? DEF/WEF _REVERSE
	beq.s	18$
	neg.w	d0
	add.w	#TValMax,d0

18$	swap	d0
	divu	#TValMax,d0	
	bvc.s	19$

* it was time $10000 = shrunk on screen
	move.l	a2,a0
	adda.l	16(a2),a0	;posx
	move.l	a2,a1
	adda.l	20(a2),a1	;posxd
	move.l	(a0),(a1)
	move.l	52(a2),56(a2)
	clr.l	(a0)
	clr.l	52(a2)

	move.l	a2,a0
	adda.l	32(a2),a0	;posy
	move.l	a2,a1
	adda.l	36(a2),a1	;posyd
	move.l	(a0),(a1)
	move.l	68(a2),72(a2)
	clr.l	(a0)
	clr.l	68(a2)
	move.l	#$10000,d0	;never probably used
	bra	 100$

19$	move.w	d0,d2		;stash tbar time

	moveq	#0,d1
	move.w	(sp),d1		;x1
	bpl.s	20$
	neg.w	d1
20$	swap	d1
	divu	12(a2),d1	;SXSIZE
	bvc.s	21$
	moveq	#-1,d1

21$	cmp.w	d0,d1
	bls.s	22$		;jump if mostly sizing
	move.w	d1,d0		;its mostly X positioning

22$	moveq	#0,d1
	move.w	2(sp),d1	;y1
	bpl.s	23$
	neg.w	d1
23$	swap	d1
	divu	14(a2),d1	;SYSIZE
	bvc.s	24$
	moveq	#-1,d1

24$	cmp.w	d0,d1
	bls.s	25$
	move.w	d1,d0		;its mostly Y positioning

* d0 = time $0000-$ffff of what is most, sizing, X positioning, or Y posit.
25$	tst.w	d0
	beq	99$		;key frame = full screen

* scale X positioning
	moveq	#0,d1
	move.w	(sp),d1		;x1
	bpl.s	26$
	neg.w	d1
26$	swap	d1
	divu	d0,d1
	tst.w	(sp)		;x1
	bpl.s	27$
	neg.w	d1
27$	swap	d1
	clr.w	d1

	move.l	a2,a0		;get effect base ptr
	adda.l	20(a2),a0	;add in offset to data
	move.l	d1,(a0)		;posxd
	move.l	d1,56(a2)

	move.l	a2,a0		;get effect base ptr
	adda.l	16(a2),a0	;add offset to effect data
	clr.l	(a0)		;posx
	clr.l	52(a2)	

* scale Y positioning
	moveq	#0,d1
	move.w	2(sp),d1	;y1
	bpl.s	36$
	neg.w	d1
36$	swap	d1
	divu	d0,d1
	tst.w	2(sp)		;y1
	bpl.s	37$
	neg.w	d1
37$	swap	d1
	clr.w	d1

	move.l	a2,a0		;get effect base ptr
	adda.l	36(a2),a0	;add offset to effect data
	
	move.l	d1,(a0)		;posyd
	move.l	d1,72(a2)


	move.l	a2,a0		;get effect base ptr
	adda.l	32(a2),a0	;add offset to effect data
	clr.l	(a0)		;posy
	clr.l	68(a2)	

* scale X sizing
40$	move.w	12(a2),d1	;SXSIZE
	mulu	d2,d1		;*size fraction
	divu	d0,d1
	neg.w	d1
	swap	d1
	clr.w	d1

	move.l	a2,a0		;get effect base ptr
	adda.l	28(a2),a0	;add offset to effect data

	move.l	d1,(a0)		;sizexd
	move.l	d1,64(a2)

* scale Y sizing
	move.w	14(a2),d1	;SYSIZE
	mulu	d2,d1		;*size fraction
	divu	d0,d1
	neg.w	d1
	swap	d1
	clr.w	d1

	move.l	a2,a0		;get base effect ptr
	adda.l	44(a2),a0	;add offset to effect data

	move.l	d1,(a0)		;sizeyd
	move.l	d1,80(a2)

99$	andi.l	#$ffff,d0	;TimeStop, clear upper word for fun
	
	tst.l	4(a2)		;DEF/WEF _REVERSE	
	beq.s	101$
	neg.l	d0
	add.l	#$10000,d0

101$	move.l	d0,d1
	lsr.l	#7,d1
	PUT.w	d1,TB_TValSec	

100$	addq.w	#4,sp
	movem.l	(sp)+,d1-d7/a0-a6
	rts

*--------
* d0 = xy
positionxy	
;	DUMPMEM	<TABLE_Equations>,(A2),#94
;	DEBUGMSG	DBPX,<positionxy>
	sub.w	14(a2),d0	;-SYSIZE

	move.l	a2,a0		;a2 is effect ptr
	adda.l	32(a2),a0	;add offset to effect data

	move.w	d0,(a0)		;posy
	move.w	d0,68(a2)
;	DUMPREG	<posy - d0>
;	DUMPMEM	<posy>,(A0),#16

	swap	d0
	sub.w	12(a2),d0	;-SXSIZE

	move.l	a2,a0 		;a2 is effect ptr
	adda.l	16(a2),a0	;add offset to effect data
	
	move.w	d0,(a0)		;posx
	move.w	d0,52(a2)
;	DUMPREG	<posx - d0>
;	DUMPMEM	<posx>,(A0),#16

	GET.w	TB_TValSec,d0
	moveq	#FIELDDURING,d1
;	DEBUGREG	DBPX,<Should be doing redraw.>
	jmp	(a6)
	
*--------
* returns d0=0 if nothing, 1 if LMB down, 2=spacebar, 3=return, 4=RMB down
abortpositioning:
	movem.l	d1/a0-a1,-(sp)

;;	moveq	#1,d0	;assume LMB = auto no stop mode
;;	ISLMBUP
;;	beq.s	100$

	CALLTL	IsLMBdown
	tst.w	d0
	bne.s	100$	;jump if LMB down, = auto no stop mode

	lea	-16(sp),sp
	movea.l	sp,a0
	CALLTL	GetKbdState
	move.b	8(sp),d1	;spacebar
	lea	16(sp),sp
	
	moveq	#2,d0	;assume SpaceBar = auto - auto mode
	btst	#0,d1
	bne.s	100$

	moveq	#3,d0	;assume Return = inset - auto mode
	btst	#4,d1
	bne.s	100$

;;	moveq	#4,d0	;assume RMB = now do sizeing
;;	ISRMBUP
;;	beq.s	100$	
;;	moveq	#0,d0	;no abort	

	CALLTL	IsRMBdown
	tst.w	d0
	beq.s	100$	;jump if RMB up, no abort
	moveq	#4,d0	;assume RMB = now do sizeing

100$	movem.l	(sp)+,d1/a0-a1
	rts

**********************************************************
* Save HDR0, HDR2, HDR68, HDR69
* TB_StashCount = 0 if no stash
StashStates:
	movem.l	d0/a0,-(sp)
	DEA.l	TB_VTSetUp,a0

	btst.b	#0,TB_StashCount(a5)
	bne.s	100$
	bset.b	#0,TB_StashCount(a5)
	
	move.l	VTSU_RG+SURG_EH0R(a0),Old0RG
	move.l	VTSU_BI+SUBI_EH0B(a0),Old0BI
	move.l	VTSU_RG+SURG_EH2R(a0),Old2RG
	move.l	VTSU_BI+SUBI_EH2B(a0),Old2BI

100$	btst.b	#1,TB_StashCount(a5)
	bne.s	666$
	bset.b	#1,TB_StashCount(a5)

	ELHGET_LKA	a0,d0
	move.w	d0,OldLKA
	ELHGET_LKB	a0,d0
	move.w	d0,OldLKB

666$	movem.l	(sp)+,d0/a0
	rts

********************************************************************
* BOOL IsMatteShown(a0 -> ButtLog, a4->EFXLib, a5->TB)
* Returns TRUE if Matte is shown at beginning or end of effect.
* This is used to prevent changing Matte on Latch FX before transitions.

IsMatteShown:
	movem.l	d1-d2/a0-a1,-(sp)

	moveq	#1,d0		;assume matte used
	
	GET.w	TB_OLaySec,d2
	btst	#B_ENCODER,d2
	bne	666$

	GET.w	TB_MainSec,d2
	btst	#B_ENCODER,d2
	bne	666$

	moveq	#-1,d1
	lea	EKE_TBar1(a0),a1
5$	addq.w	#1,d1
	move.w	(a1)+,d0
	cmp.w	#TBarTimeMax,d0
	bne.s	5$

* d1 = number of stages - 1	

	moveq	#0,d0
	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)	;Pri ???
	beq.s	10$
	moveq	#4,d0

10$	tst.w	TB_KeyModeSec(a5)
	bpl.s	20$		;jump if keying is off
	addq.w	#8,d0

20$	move.l	EKE_KeysTbl(a0,d0.w),d0
	lea	0(a0,d0.l),a1		;->logic table
	lea	TTSK_Stage1(a1),a0

* a0 -> first stage, d1 = # of stages -1 
* Store initial states
	move.b	TB_LutBus(a5),d2
	move.w	d2,-(sp)
	move.w	TB_PrvwSec(a5),-(sp)
	move.w	TB_MainSec(a5),-(sp)
	move.w	TB_OLaySec(a5),-(sp)

100$	move.b	TB_LutBus(a5),LutBus	;initialize to current lutbus
	move.w	TB_PrvwSec(a5),-(sp)
	move.w	TB_MainSec(a5),-(sp)
	move.w	TB_OLaySec(a5),-(sp)

	move.b	TSK_OLaySrcDown(a0),d0
	bsr	DoOLaySwap
	move.b	TSK_MainSrcDown(a0),d0
	bsr	DoMainSwap
	move.b	TSK_PrvwSrcDown(a0),d0
	bsr	DoPrvwSwap

	move.b	LutBus,TB_LutBus(a5)	;may be a new lutbus
	bsr	DoStageLogic
	
	lea	TSK_SIZEOF(a0),a0	;->next stage
	adda.w	#6,sp
	dbra	d1,100$

* Do take after last stage
	lea	TTSK_Take(a1),a0

	move.w	TB_PrvwSec(a5),-(sp)
	move.w	TB_MainSec(a5),-(sp)
	move.w	TB_OLaySec(a5),-(sp)

;Swap rows if necessary, or FromHell
	move.b	TB_LutBus(a5),LutBus	;initialize to current lutbus
	move.b	FTK_OLaySrc(a0),d0
	bsr	DoOLaySwap
	move.b	FTK_MainSrc(a0),d0
	bsr	DoMainSwap
	move.b	FTK_PrvwSrc(a0),d0
	bsr	DoPrvwSwap
	move.b	LutBus,TB_LutBus(a5)	;may be a new lutbus

	addq.w	#6,sp

;Correct any errors in button logic
	move.w	FTK_OLayLogic(a0),d0
	jsr	0(a4,d0.w)	
	move.w	FTK_MainLogic(a0),d0
	jsr	0(a4,d0.w)	
	move.w	FTK_PrvwLogic(a0),d0
	jsr	0(a4,d0.w)

	moveq	#1,d0		;assume matte shown
	GET.w	TB_OLaySec,d2
	btst	#B_ENCODER,d2
	bne.s	999$

	GET.w	TB_MainSec,d2
	btst	#B_ENCODER,d2
	bne.s	999$

	moveq	#0,d0		;Matte not shown

999$	move.w	(sp)+,TB_OLaySec(a5)
	move.w	(sp)+,TB_MainSec(a5)
	move.w	(sp)+,TB_PrvwSec(a5)
	move.w	(sp)+,d2
	move.b	d2,TB_LutBus(a5)

666$	movem.l	(sp)+,d1-d2/a0-a1
	rts

**********************************************************
* d0=doelhflag ProcessDuring(a0 -> tables of logic, a4->EFXLib, a5->TB)		
* d0=0 if don't bother to do elh write.
* d0=1 if do elh write = new stage or some button clicked on.

ProcessDuring:
	DUMPMSG	<ProcessDuring>
	movem.l	d1/a0-a3,-(sp)
	DEA.l	TB_VTSetUp,a3
	
* stash all the registers associated with the IS, LKA, and LKB headers
* Used by the ChangeIS and ChangeClips routine.

	bsr	StashStates

	moveq	#0,d0
	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)	;Pri ???
	beq.s	10$
	moveq	#4,d0

10$	tst.w	TB_KeyModeSec(a5)
	bpl.s	20$		;jump if keying is off
	addq.w	#8,d0

20$	move.l	EKE_ELHTbl(a0,d0.w),d1
	lea	0(a0,d1.l),a1
	move.l	EKE_KeysTbl(a0,d0.w),d1
	lea	0(a0,d1.l),a2		;->logic table

	lea	EKE_TBar1(a0),a0
	lea	TTSE_Stage1(a1),a1
	lea	TTSK_Stage1(a2),a2

* Some old code may not be using the TB_TBarTime field, so we'll fake
* it by looking at TB_TValSec.
	GET.w	TB_TBarTime,d0		;assume we have hires time
	move.w	d0,d1
	lsr.w	#7,d1
	cmp.w	TB_TValSec(a5),d1	;look at lores time
	beq.s	25$			;jump if hires time is probably ok

* Fake HIRES Tbar position
	GET.w	TB_TValSec,d0		;use lores time
	cmpi.w	#TValMax,d0
	bne.s	23$
	move.w	#TBarTimeMax,d0
	bra.s	24$
23$	lsl.w	#7,d0
24$	PUT.w	d0,TB_TBarTime		;convert to hires time

25$	moveq	#0,d1
30$	cmp.w	(a0)+,d0		;is it <= to bottom of stage
	bls.s	40$
	lea	TSE_SIZEOF(a1),a1
	lea	TSK_SIZEOF(a2),a2
	addq.w	#1,d1	;stage counter
	bra.s	30$

;found the correct stage
40$	movea.l	a2,a0
	move.b	TB_LutBus(a5),LutBus	;initialize to current lutbus
	move.w	TB_PrvwSec(a5),-(sp)
	move.w	TB_MainSec(a5),-(sp)
	move.w	TB_OLaySec(a5),-(sp)
	move.w	EF_OldStage(a4),d0
	move.w	d1,EF_OldStage(a4)

	cmp.w	d1,d0
	bge.s	45$

;movement downward to new stage
	clr.w	EF_NotDigital(a4)	;let botton logic determine NotDigial
	move.b	TSK_OLaySrcDown(a0),d0
	bsr	DoOLaySwap
	move.b	TSK_MainSrcDown(a0),d0
	bsr	DoMainSwap
	move.b	TSK_PrvwSrcDown(a0),d0
	bra	60$

45$	beq.s	50$
;movement upward to new stage
	clr.w	EF_NotDigital(a4)	;let botton logic determine NotDigial
	move.b	TSK_OLaySrcUp(a0),d0
	bsr	DoOLaySwap
	move.b	TSK_MainSrcUp(a0),d0
	bsr	DoMainSwap
	move.b	TSK_PrvwSrcUp(a0),d0
	bra.s	60$

;same stage as before
50$ ;;	tst.w	EF_OldTBar(a4)
    ;;	blt.s	75$		;jump if still at top, shouldn't happen!!!

;;	GET.w	TB_TValSec,d0
;;	cmp.w	EF_OldTBar(a4),d0
;;	beq.s	75$		;jump if not a tbar/auto move
;;	move.w	d0,EF_OldTBar(a4)
;;	GET.w	TB_TBarTime,EF_OldTBarTime(a4)

	GET.w	TB_TBarTime,d0
	DUMPREG	<before call to 75>
	cmp.w	EF_OldTBarTime(a4),d0
	beq.s	75$				;jump if not a tbar/auto move
	move.w	d0,EF_OldTBarTime(a4)
	GET.w	TB_TValSec,EF_OldTBar(a4)	;was a TBar/auto move, but not to a new stage

	moveq	#FIELDNOELH,d1			;signal not to do ELH write
	bra	90$

;new stage, was a TBar/auto move
60$	bsr	DoPrvwSwap
	move.b	LutBus,TB_LutBus(a5)	;may be a new lutbus
	GET.w	TB_TBarTime,EF_OldTBarTime(a4)
	GET.w	TB_TValSec,EF_OldTBar(a4)

	DUMPMSG	<didnot branch to 75>
* This gets executed if its a new stage or if a row, clip, or freeze was
* clicked on.
75$	moveq	#FIELDDOELH,d1		;signal to do ELH write
	DUMPMSG	<Calling DoStageLogic>
	bsr	DoStageLogic		

	DUMPMSG	<After DoStageLogic>
	move.b	TSE_AM(a1),d0
	bsr	GetFrom	
	bmi.s	52$

	DUMPMSG	<Before Mask2AM>
	CALLTL	Mask2AM
	ELHPUT_AM_R	a3,d0

52$	move.b	TSE_BM(a1),d0
	bsr	GetFrom	
	bmi.s	54$
	CALLTL	Mask2BM
	ELHPUT_BM_R	a3,d0

54$	move.b	TSE_PV(a1),d0
	bsr	GetFrom	
	bmi.s	56$
	CALLTL	Mask2PV
	ELHPUT_PV_R	a3,d0

56$	move.b	TSE_IS(a1),d0
	bsr	GetFrom	
	bmi.s	58$
	CALLTL	Mask2IS
	ELHPUT_IS_R	a3,d0

;;	bsr	ChangeIS	

58$	move.b	TSE_LK(a1),d0
	bsr	GetFrom	
	bmi.s	59$
	CALLTL	Mask2LK
	ELHPUT_LK_R	a3,d0

59$	moveq	#0,d0
	move.b	TSE_CDS(a1),d0
	bmi	599$		;jump if CurrentCDS

	ELHPUT_CDS_R	a3,d0

*----------
599$	btst.b	#EFFLAGS1_LOCKCLIP_BIT,EF_Flags1(a4)
	bne.s	90$	;89$ ????

	GET.w	TB_ClipASec,d0
	beq.s	90$			;jump if min clip = foreground

	cmpi.w	#ClipAMax,d0
	beq.s	90$			;jump if max clip = background

	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	230$			;jump if keying on black

* Keying on white
	neg.w	d0
	add.w	#ClipAMax,d0

* Keying on black
230$	subq.w	#1,d0
	ELHPUT_LKA_R	a3,d0

	ELHGET_CDS	a3,d0
	cmpi.w	#VTI_CDS_LUMKEY,d0
	bne.s	90$			;jump if not lum keying
	
* Some effects aren't using Lumkey even though the scissors are on
;;	tst.w	TB_KeyModeSec(a5)
;;	bpl.s	90$			;jump if not lum keying
	ELHSET_NOKEYINVERT	a3
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	89$			;jump if keying on black
	ELHCLEAR_NOKEYINVERT	a3

* Actually, we don't have any lut effects that can lumkey during the effect
89$	ELHSET_NOKEYSHIFT	a3	;assume standard key
	cmpi.b	#M_LUTBUS_OLAY,TB_LutBus(a5)
	bne.s	90$
	ELHCLEAR_NOKEYSHIFT	a3
*----------

90$	GET.w	TB_OLaySec,d0
	bne.s	95$
	GET.w	TB_MainFroze,d0	;some effects don't use olay row
	bra.s	96$
95$	GET.w	TB_OLayFroze,d0	;set OBR for Digital effects
96$	cmpi.w	#M_DV0,d0
	beq.s	100$

	ELHTEST_LUT	a3
	bne.s	100$
	
	ELHCLEAR_OBR	a3
	bra.s	110$
100$	ELHSET_OBR	a3
110$	addq.w	#6,sp
	move.l	d1,d0	;elh signal = FIELDDOELH or FIELDNOELH
	DUMPMSG	<Process position Done.>
	movem.l	(sp)+,d1/a0-a3
	rts

;---------------------------------
DoOLaySwap:   ;if FromHell, will do nothing
	cmpi.b	#FromMain,d0
	bne.s	110$
	PUT.w	6(sp),TB_OLaySec
	cmpi.b	#M_LUTBUS_MAIN,TB_LutBus(a5)
	beq.s	112$
	rts
110$	cmpi.b	#FromPrvw,d0
	bne.s	115$
	PUT.w	8(sp),TB_OLaySec
	cmpi.b	#M_LUTBUS_PRVW,TB_LutBus(a5)
	bne.s	115$
112$	move.b	#M_LUTBUS_OLAY,LutBus
115$	rts

	IFD	CRAP
115$	cmpi.b	#FromOLayBMainW,d0
	bne.s	120$
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	190$			;jump if key on black
	PUT.w	6(sp),TB_OLaySec
	rts
120$	cmpi.b	#FromOLayWMainB,d0
	bne.s	190$
	tst.b	TB_KeyModeSec+1(a5)
	bpl.s	190$			;jump if key on white
	PUT.w	6(sp),TB_OLaySec
190$	rts
	ENDC

;---------------------------------
DoMainSwap:   ;if FromHell, will do nothing
	cmpi.b	#FromOLay,d0
	bne.s	210$
	PUT.w	4(sp),TB_MainSec
	cmpi.b	#M_LUTBUS_OLAY,TB_LutBus(a5)
	beq.s	212$
	rts
210$	cmpi.b	#FromPrvw,d0
	bne.s	215$
	PUT.w	8(sp),TB_MainSec
	cmpi.b	#M_LUTBUS_PRVW,TB_LutBus(a5)
	bne.s	215$
212$	move.b	#M_LUTBUS_MAIN,LutBus
215$	rts

	IFD	CRAP
215$	cmpi.b	#FromOLayBMainW,d0
	bne.s	220$
	tst.b	TB_KeyModeSec+1(a5)
	bpl.s	290$			;jump if key on white
	PUT.w	4(sp),TB_MainSec
	rts
220$	cmpi.b	#FromOLayWMainB,d0
	bne.s	290$
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	290$			;jump if key on black
	PUT.w	4(sp),TB_MainSec
290$	rts
	ENDC

;---------------------------------
DoPrvwSwap:   ;if FromHell, will do nothing
	cmpi.b	#FromOLay,d0
	bne.s	310$
	PUT.w	4(sp),TB_PrvwSec
	cmpi.b	#M_LUTBUS_OLAY,TB_LutBus(a5)
	beq.s	312$
	rts
310$	cmpi.b	#FromMain,d0
	bne.s	315$
	PUT.w	6(sp),TB_PrvwSec
	cmpi.b	#M_LUTBUS_MAIN,TB_LutBus(a5)
	bne.s	315$
312$	move.b	#M_LUTBUS_PRVW,LutBus
315$	rts

	IFD	CRAP
315$	cmpi.b	#FromOLayBMainW,d0
	bne.s	320$
	tst.b	TB_KeyModeSec+1(a5)
	bpl.s	317$			;jump if key on white
	PUT.w	4(sp),TB_PrvwSec
	rts
317$	PUT.w	6(sp),TB_PrvwSec
	rts
320$	cmpi.b	#FromOLayWMainB,d0
	bne.s	390$
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	330$			;jump if key on black
	PUT.w	4(sp),TB_PrvwSec
	rts
330$	PUT.w	6(sp),TB_PrvwSec
390$	rts
	ENDC

;-------------------------
DoStageLogic:
	DUMPMSG	<DoStageLogic>	
	move.w	TSK_OLayLogic(a0),d0
	jsr	0(a4,d0.w)
	DUMPMSG	<Olaylogic Done.>	
	move.w	TSK_MainLogic(a0),d0
	jsr	0(a4,d0.w)
	DUMPMSG	<MainLogic Done.>	
	move.w	TSK_PrvwLogic(a0),d0
	jsr	0(a4,d0.w)
	DUMPMSG	<PrvwLogic Done.>	
	rts
	
;-----------------------------------------------
* Says where MUX inputs come from, Minus flag set if from Hell
GetFrom:
	cmpi.b	#FromOLay,d0
	bne.s	100$
	GET.w	TB_OLaySec,d0
	rts

100$	cmpi.b	#FromMain,d0
	bne.s	110$
	GET.w	TB_MainSec,d0
	rts

110$	cmpi.b	#FromPrvw,d0
	bne.s	115$
	GET.w	TB_PrvwSec,d0
	rts

115$	cmpi.b	#FromOLayBMainW,d0
	bne.s	120$
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	117$			;jump if key on black
	GET.w	TB_MainSec,d0
	rts
117$	GET.w	TB_OLaySec,d0
	rts

120$	cmpi.b	#FromOLayWMainB,d0
	bne.s	140$
	tst.b	TB_KeyModeSec+1(a5)
	bpl.s	130$			;jump if key on white
	GET.w	TB_MainSec,d0
	rts
130$	GET.w	TB_OLaySec,d0
	rts

140$	cmpi.b	#FromLiveDVE,d0
	bne.s	150$
	GET.w	TB_OLaySec,d0
	ISLIVEDVEON	d0
	bne.s	145$
	GET.w	TB_MainSec,d0
	ISLIVEDVEON	d0
	bne.s	145$
	GET.w	TB_PrvwSec,d0
	ISLIVEDVEON	d0
	beq	666$
145$	tst.w	d0
	rts

150$
	  IFD	CRAP	;-------------------
	cmpi.b	#FromDAC0BMainW,d0
	bne.s	160$
	tst.b	TB_KeyModeSec+1(a5)
	bmi.s	157$			;jump if key on black
	GET.w	TB_MainSec,d0
	rts
157$	move.w	#M_DV0,d0
	rts

160$	cmpi.b	#FromDAC0WMainB,d0
	bne.s	400$
	tst.b	TB_KeyModeSec+1(a5)
	bpl.s	167$			;jump if key on white
	GET.w	TB_MainSec,d0
	rts
167$	move.w	#M_DV0,d0
	rts
	  ENDC		;-------------------

	cmpi.b	#FromLutHell,d0		;used for LUT LK
	bne.s	160$
	tst.b	TB_LutBus(a5)
	beq	666$		;jump if from Hell
	bra	GetLutBus	;always do LK even if color lut

160$	cmpi.b	#FromLutMonoHell,d0	;used for LUT IS
	bne.s	170$
	tst.b	TB_LutBus(a5)
	beq	666$		;jump if from Hell
	bsr	GetLutBus	;assume color LUT
	cmpi.b	#LUTMODE_BW,TB_LutMode(a5)
	beq.s	163$		
	cmpi.w	#M_DV1,d0
	bne.s	164$
163$	move.w	#M_MONO,d0	;use MONO if BW LUT, or DV1 source
164$	tst.w	d0
	rts

170$	cmpi.b	#FromDAC0OLay,d0
	bne.s	180$
	move.w	#M_DV0,d0	;assume LUT
	cmpi.b	#M_LUTBUS_OLAY,TB_LutBus(a5)
	beq	1000$
	GET.w	TB_OLaySec,d0
	rts
	
180$	cmpi.b	#FromDAC0Main,d0
	bne.s	190$
	move.w	#M_DV0,d0	;assume LUT
	cmpi.b	#M_LUTBUS_MAIN,TB_LutBus(a5)
	beq	1000$
	GET.w	TB_MainSec,d0
	rts

190$	cmpi.b	#FromDAC0Prvw,d0
	bne.s	270$
	move.w	#M_DV0,d0	;assume LUT
	cmpi.b	#M_LUTBUS_PRVW,TB_LutBus(a5)
	beq	1000$
	GET.w	TB_PrvwSec,d0
	rts


270$	cmpi.b	#FromDAC0OLayMono,d0
	bne.s	280$
	move.w	#M_DV0,d0	;assume LUT
	cmpi.b	#M_LUTBUS_OLAY,TB_LutBus(a5)
	beq	1000$
	move.w	#M_MONO,d0
	rts
	
280$	cmpi.b	#FromDAC0MainMono,d0
	bne.s	290$
	move.w	#M_DV0,d0	;assume LUT
	cmpi.b	#M_LUTBUS_MAIN,TB_LutBus(a5)
	beq	1000$
	move.w	#M_MONO,d0
	rts

290$	cmpi.b	#FromDAC0PrvwMono,d0
	bne.s	400$
	move.w	#M_DV0,d0	;assume LUT
	cmpi.b	#M_LUTBUS_PRVW,TB_LutBus(a5)
	beq	1000$
	move.w	#M_MONO,d0
	rts


* Constants
400$	cmpi.b	#FromVID1,d0
	bne.s	410$
	move.w	#M_VIDEO1,d0
	rts
410$	cmpi.b	#FromVID2,d0
	bne.s	420$
	move.w	#M_VIDEO2,d0
	rts
420$	cmpi.b	#FromVID3,d0
	bne.s	430$
	move.w	#M_VIDEO3,d0
	rts
430$	cmpi.b	#FromVID4,d0
	bne.s	440$
	move.w	#M_VIDEO4,d0
	rts
440$	cmpi.b	#FromMAINOUT,d0
	bne.s	450$
	move.w	#M_MAIN,d0
	rts
450$	cmpi.b	#FromDAC0,d0
	bne.s	460$
	move.w	#M_DV0,d0
	rts
460$	cmpi.b	#FromDAC1,d0
	bne.s	470$
	move.w	#M_DV1,d0
	rts
470$	cmpi.b	#FromENCODER,d0
	bne.s	480$
	move.w	#M_ENCODER,d0
	rts
480$	cmpi.b	#FromMONO,d0
	bne.s	490$
	move.w	#M_MONO,d0
	rts
490$	cmpi.b	#FromEXT,d0
	bne.s	666$
	move.w	#M_EXTER,d0
	rts

666$	moveq	#-1,d0	;no values to get!
1000$	rts

*-----------------------------------
* assume LutBus != 0
GetLutBus
	GET.b	TB_LutBus,d0
	cmpi.b	#M_LUTBUS_OLAY,d0
	beq.s	10$
	cmpi.b	#M_LUTBUS_MAIN,d0
	beq.s	20$

*default
	GET.w	TB_PrvwSec,d0
	rts

10$	GET.w	TB_OLaySec,d0
	rts

20$	GET.w	TB_MainSec,d0
	rts

**********************************************************
* a0 -> tables of logic, a4->EFXLib		
* Since the ELHs aren't send out, calls to ProcessTake are usually
* followed with SendELH2Toaster(), InstallAVEdoELH(), InstallAVEIdoELH() etc.

ProcessTake:
;	DUMPMSG	<ProcessTake>
	tst.w	EF_OldTBar(a4)
	blt.s	10$		;jump if start of effect, avoids doubletake
	move.w	d0,-(sp)
	moveq	#1,d0		;=take
	bsr.s	ProcessTakeUnTake
	clr.w	TB_TValSec(a5)
	clr.w	TB_TBarTime(a5)
	move.w	(sp)+,d0
10$	rts

**********************************************************
* a0 -> tables of logic, a4->EFXLib		
* Since the ELHs aren't send out, calls to ProcessUnTake are usually
* followed with SendELH2Toaster(), InstallAVEdoELH(), InstallAVEIdoELH() etc.

ProcessUnTake:
	DUMPMSG	<ProcessUnTake>
	tst.w	EF_OldTBar(a4)
	blt.s	10$		;jump if start of effect, avoids doubletake
	move.w	d0,-(sp)
	moveq	#0,d0		;=untake
	bsr.s	ProcessTakeUnTake
	clr.w	TB_TValSec(a5)
	clr.w	TB_TBarTime(a5)
	move.w	(sp)+,d0
10$	rts

**********************************************************
* d0=TTSK_Take/TTSK_UnTake offset, a0 -> tables of logic, a4->EFXLib		

ProcessTakeUnTake:
	movem.l	d0-d2/a0-a1,-(sp)
	DUMPMSG	<ProcessTakeUnTake>
	bsr	StashStates		
	bsr	KillTransTriMarks

	move.w	#-1,EF_OldTBar(a4)
	move.w	#-1,EF_OldStage(a4)

	moveq	#0,d1
	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)	;Pri ???
	beq.s	10$
	moveq	#4,d1

10$	tst.w	TB_KeyModeSec(a5)
	bpl.s	20$		;jump if keying is off
	addq.w	#8,d1

20$	move.l	EKE_ELHTbl(a0,d1.w),d2
	lea	0(a0,d2.l),a1
	move.l	EKE_KeysTbl(a0,d1.w),d2
	lea	0(a0,d2.l),a0	;->logic table
	
	tst.w	d0
	bne	22$
;UnTake
	DUMPMSG	<UnTake>

	lea	TTSK_UnTake(a0),a0
	lea	TTSE_UnTake(a1),a1
	bra	25$
;Take
22$	DUMPMSG	<Take>

	lea	TTSK_Take(a0),a0
	lea	TTSE_Take(a1),a1

25$	DUMPHEXI.w	<OLay before Swap=>,TB_OLaySec(a5),<\>

	move.w	TB_PrvwSec(a5),-(sp)
	move.w	TB_MainSec(a5),-(sp)
	move.w	TB_OLaySec(a5),-(sp)

;Swap rows if necessary, or FromHell
	move.b	TB_LutBus(a5),LutBus	;initialize to current lutbus
	move.b	FTK_OLaySrc(a0),d0
	bsr	DoOLaySwap
	move.b	FTK_MainSrc(a0),d0
	bsr	DoMainSwap
	move.b	FTK_PrvwSrc(a0),d0
	bsr	DoPrvwSwap
	move.b	LutBus,TB_LutBus(a5)	;may be a new lutbus

	addq.w	#6,sp

	DUMPHEXI.w	<OLay after Swap =>,TB_OLaySec(a5),<\>

;Correct any errors in button logic

	DUMPMSG	<TOTAL Panic!>	

 IFEQ 0	
	move.w	FTK_OLayLogic(a0),d0
	jsr	0(a4,d0.w)	
 ENDC
	move.w	FTK_MainLogic(a0),d0
	jsr	0(a4,d0.w)	
	move.w	FTK_PrvwLogic(a0),d0
	jsr	0(a4,d0.w)


	DUMPHEXI.w	<OLay after Button Logic Fix=>,TB_OLaySec(a5),<\>

;standard state of the non-transition machine = CD or LUMKEY
	DEA.l	TB_VTSetUp,a0
	ELHGET_CDS	a0,d0

	DUMPHEXI.w	<CDS=>,d0,<\>

	cmpi.w	#VTI_CDS_LUMKEY,d0
	beq	30$		;jump if LUMKEY is on

	DUMPMSG	<CD=SHOWB>

	ELHPUT_CD_I	a0,VTI_CD_SHOWB  ;Assume Key or Main always on BM side

***!! THIS ALLOWS US TO LEAVE UP A DIB OR DIBGR KEY
***!! BEFORE FEB-20-95 (JUST BEFORE SKELL LEFT) THIS CODE WAS PUT IN.
***!! IF SOME FX SHOULDN'T LEAVE UP A KEY ON TBAR ALL THE WAY UP/DOWN
***!! THEN THEY HAVE THE WRONG TAKE/UNTAKE ELH VTI_CDS.

***!! I'M DOING AN ADDITIONAL CHECK TO MAKE SURE
***!! THESE BRANCHES ONLY CAN OCCUR IF TB_CurrentAlphaBM != 0.
***!! REMOVE THIS CHECK IF YOU WANT THIS KEY LEFT UP ABILITY WITH STANDARD FX
	tst.l	TB_CurrentAlphaBM(a5)
	beq.s	28$
	tst.w	TB_OLaySec(a5)
	beq.s	28$		

	DUMPMSG	<CHECK FOR DIB or DIBGR>	

	cmpi.w	#VTI_CDS_DIB,d0
	beq.s	30$		;jump if AlphaBM DIB is on
	cmpi.w	#VTI_CDS_DIBGR,d0
	beq.s	30$		;jump if AlphaBM DIBGR is on

28$	DUMPMSG	<CDS=CD>

	ELHPUT_CDS_I	a0,VTI_CDS_CD
	ELHSET_NOKEYINVERT	a0
	ELHSET_NOKEYSHIFT	a0

30$	ELHSET_MATTE	a0	
	ELHCLEAR_AMWIPE	a0
	ELHCLEAR_BMWIPE	a0
	ELHCLEAR_ISWIPE	a0

	ELHSET_NOPAIRS	a0

	tst.w	TB_UserOn(a5)
	beq.s	26$
	ELHSET_USERON	a0
	ELHSET_PVMUTE	a0
	bra.s	300$
26$	ELHCLEAR_USERON	a0
	ELHCLEAR_PVMUTE	a0

300$	DUMPHEXI.l <TB_CurrentAlphaBM>,TB_CurrentAlphaBM(a5),<\>

;;	tst.l	TB_CurrentAlphaBM(a5)
;;	beq.s	400$
;;	tst.w	TB_OLaySec(a5)
;;	beq.s	666$
***!!! just need new avei

400$	DUMPMSG	<before cookmain>
	CALLTL	CookMain

* No headers are sent out!!
;;	CALLTL	InstallAVEIdoELH	
;;	GET.w	TB_MainSec,d0
;;	CALLTL	ShortOutFader	;will SET LINP/LINR and set BPLCON0 to 1

666$	movem.l	(sp)+,d0-d2/a0-a1
	rts

;--------------------------------
* This routine only fixes the DV buttons to refect LIVE/FROZEN, you may
* need to call ProcessDuring to actually decide the button logic needed.
* Multiple LIVE DVE's can occur.  ProcessDuring will need to take a pick.
* Call ProcessFreezeButton if you always want frozen Prvw set to a frozen bank

ProcessFreezeThaw
	DUMPMSG	<ProcessFreezeThaw>	
	move.l	d0,-(sp)
	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)
	bne	100$		;jump if froze
	

	move.l	a1,-(sp)		;fix for freeze panel 
	lea	LIVE_FG,a1
	move.w	#$ffff,FG_HiLiteMask(a1)
	lea	FL_FG,a1
	clr.w	FG_HiLiteMask(a1)	; else denote live
	XJSR	SWIT_UpdateFrameSaveButtons
	move.l	(sp)+,a1



;live
	GET.w	TB_OLaySec,d0	
	ISFROZENDVEON	d0
	beq.s	10$
	GET.w	TB_OLaySave,d0
	TURNLIVEDVEON	d0
	PUT.w	d0,TB_OLaySec

10$	GET.w	TB_MainSec,d0	
	ISFROZENDVEON	d0
	beq.s	20$
	GET.w	TB_MainSave,d0
	TURNLIVEDVEON	d0
	PUT.w	d0,TB_MainSec

20$	GET.w	TB_PrvwSec,d0	
	ISFROZENDVEON	d0
	beq.s	130$
	GET.w	TB_PrvwSave,d0
	TURNLIVEDVEON	d0
	PUT.w	d0,TB_PrvwSec
	bra.s	130$

;frozen assume 4 field !!
100$	

;	move.l	a1,-(sp)		;fix for freeze panel 
;	lea	LIVE_FG,a1
;	clr.w	FG_HiLiteMask(a1)	; else denote live
;	lea	FL_FG,a1
;	move.w	#$ffff,FG_HiLiteMask(a1)
;	move.l	(sp)+,a1

	

	GET.w	TB_OLaySec,d0	
	ISLIVEDVEON	d0
	beq.s	110$
	move.w	TB_OLayFroze(a5),TB_OLaySec(a5)

110$	GET.w	TB_MainSec,d0	
	ISLIVEDVEON	d0
	beq.s	120$
	move.w	TB_MainFroze(a5),TB_MainSec(a5)

120$	GET.w	TB_PrvwSec,d0	
	ISLIVEDVEON	d0
	beq.s	130$
	move.w	TB_PrvwFroze(a5),TB_PrvwSec(a5)

130$	move.l	(sp)+,d0
	rts

;--------------------------------
* This routine only fixes the DV buttons to refect LIVE/FROZEN, you may
* need to call ProcessDuring to actually decide the button logic needed.
* Multiple LIVE DVE's can occur.  ProcessDuring will need to take a pick.
* Call ProcessFreezeThaw if you don't always want frozen Prvw set to a frozen bank

	xref	LIVE_FG,FL_FG

ProcessFreezeButton
	DUMPMSG	<ProcessFreezeButton>
	movem.l	d0/a1,-(sp)
	bsr	ProcessFreezeThaw
	
	
	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)
	beq.s	100$		;jump if live
	move.w	TB_PrvwFroze(a5),TB_PrvwSec(a5)
;	lea	LIVE_FG,a1
;	clr.w	FG_HiLiteMask(a1)	; else denote live
;	lea	FL_FG,a1
;	move.w	#$ffff,FG_HiLiteMask(a1)
	bra	110$
100$	
;	lea	LIVE_FG,a1
;	move.w	#$ffff,FG_HiLiteMask(a1)
;	lea	FL_FG,a1
;	clr.w	FG_HiLiteMask(a1)	; else denote live
	
110$
	movem.l	(sp)+,d0/a1
	rts

;--------------------------------
* Call CookFreezeThaw if you always want frozen Prvw set to a frozen bank
* You may want to do a StashStates sometime before this.

CookFreezeThaw
	DUMPMSG	<CookFreezeThaw>
	move.l	d0,-(sp)
	bsr	ProcessFreezeThaw

	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)
	bne.s	666$		;jump if froze
	bsr.s	CookLive

666$	move.l	(sp)+,d0
	rts

;--------------------------------
* Call CookFreezeLive if you don't always want frozen Prvw set to a frozen bank
* You may want do a StashStates sometime before this.

CookFreezeButton
	move.l	d0,-(sp)
	bsr	ProcessFreezeButton

	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)
	bne.s	666$		;jump if froze
	bsr.s	CookLive

666$	move.l	(sp)+,d0
	rts

;--------------------------------
* Picks out only one LIVE DVE - assumes nothing is frozen, that we're live
* This usually follows ProcessFreezeThaw or ProcessFreezeButton
* Sets up IS for the current LIVE DVE if there is one
* You may want to do a StashStates sometime before this.
CookLive:
	movem.l	d0/a0,-(sp)

	bsr	StashStates

	DEA.l	TB_VTSetUp,a0

	GET.w	TB_OLaySec,d0
	ISLIVEDVEON	d0
	beq.s	100$
	CALLTL	Mask2IS
	ELHPUT_IS_R	a0,d0
	
	GET.w	TB_MainSec,d0
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_MainSec

50$	GET.w	TB_PrvwSec,d0
	TURNLIVEDVEOFF	d0
	PUT.w	d0,TB_PrvwSec
	bra.s	666$

100$	GET.w	TB_MainSec,d0
	ISLIVEDVEON	d0
	beq.s	200$
	CALLTL	Mask2IS
	ELHPUT_IS_R	a0,d0
	bra.s	50$	

200$	GET.w	TB_PrvwSec,d0
	ISLIVEDVEON	d0
	beq.s	666$
	CALLTL	Mask2IS
	ELHPUT_IS_R	a0,d0

666$	movem.l	(sp)+,d0/a0
	rts


*******************************************************************
* ChangeIS(a5->TB,waitfields-1)
*
* Waitfields	= 2 if non-trailsOW
*		= 6 if trailsOW 1st field (non-if filling bank with matte 1st)
*		= don't call if trailsOW not 1st field 
* If IS needs to be changed, this will take some (4 typically?) fields.
* This assumes the values that were stashed at the beginning of
* ProcessDuring = the current hardware (which may not = the
* current ELH stuff.
* For Effects on writing, do not call this routine if mid-trans.  It won't be necessary!
* You must have interrupts turned off when you call this routine,
* for the timing to be correct.

d0ptr set	(4*4)
ChangeIS:
	movem.l	d0-d3/a0,-(sp)	;SEE BELOW
	moveq	#0,d1		;no interlace restrictions
	bra.s	changeisentry	;jumps below!!!

* ChangeISlace(a5->TB,waitfields-1,interlaceflag)
* Call this instead of ChangeIS if the next field has the required
* interlace (Fields I/III or II/IV).  If the frameflop doesn't
* matter on the Install or ELHsend, then use ChangeIS instead.
ChangeISlace:
	movem.l	d0-d3/a0,-(sp)	;SEE ABOVE
	moveq	#1,d1		;interlace restrictions

changeisentry:
	GET.b	TB_StashCount,d2
	btst	#0,d2
	beq	100$	;jump if no fresh stash available

	cmpi.w	#VIDEOTYPE_LIVE,TB_VideoFlagSec(a5)	;Pri ???
	bne	100$

	DEA.l	TB_VTSetUp,a0
	ELHGET_IS	a0,d0	;requested IS

;stash requested IS and assoc. regs
	move.l	VTSU_RG+SURG_EH2R(a0),-(sp)

;move in old registers
	move.l	Old2RG,VTSU_RG+SURG_EH2R(a0)

	ELHGET_IS	a0,d3	;old IS
	cmp.w	d0,d3
	beq.s	40$		;jump if no change is required

	ELHPUT_IS_R	a0,d0	;new IS

* We mess with EH0 because SendELHList2Toaster always sends EH0
	move.l	VTSU_BI+SUBI_EH2B(a0),-(sp)
	move.l	VTSU_RG+SURG_EH0R(a0),-(sp)
	move.l	VTSU_BI+SUBI_EH0B(a0),-(sp)
	move.l	Old2BI,VTSU_BI+SUBI_EH2B(a0)
	move.l	Old0RG,VTSU_RG+SURG_EH0R(a0)
	move.l	Old0BI,VTSU_BI+SUBI_EH0B(a0)

	move.l	d0ptr(sp),d0
	addq.l	#3,d0
	neg.l	d0
	CALLTL	Wait4Time	;d1=laceflag

* May abort early! Check WAITABORT_BIT after ChangeIS is called

	lea	elh2(pc),a0
	CALLTL	SendELHList2Toaster

	move.l	d0ptr(sp),d0	;waitfields !
30$ 	CALLTL	Wait4Top	
	dbra	d0,30$

* restore requested IS and assoc. regs 
	DEA.l	TB_VTSetUp,a0
	move.l	(sp)+,VTSU_BI+SUBI_EH0B(a0)
	move.l	(sp)+,VTSU_RG+SURG_EH0R(a0)
	move.l	(sp)+,VTSU_BI+SUBI_EH2B(a0)
	move.l	(sp)+,VTSU_RG+SURG_EH2R(a0)
	bra.s	110$

40$	move.l	(sp)+,VTSU_RG+SURG_EH2R(a0)
100$	moveq	#-1,d0		;wait to field before 1st field of effect
	CALLTL	Wait4Time	;d1=laceflag

* May abort early! Check WAITABORT_BIT after ChangeIS is called


110$	bclr.l	#0,d2
	PUT.b	d2,TB_StashCount


666$	movem.l	(sp)+,d0-d3/a0
	rts

elh2	dc.b	EH2,EHEND

	CNOP	0,2

*******************************************************************
* ChangeClips(a5->TB)
* If LKA or LKB need to be drastically changed, this will take 1 field.
* This assumes the values that were stashed at the beginning of
* ProcessDuring = the current hardware (which may not = the
* current ELH stuff.  You must have interrupts turned off when you call
* this routine, for the timing to be correct.

CLIPMAXCHANGE	set	32	;=256/8

ChangeClips:
	movem.l	d0-d1/a0,-(sp)
	GET.b	TB_StashCount,d1
	btst	#1,d1
	beq	100$	;jump if no fresh stash available

	DEA.l	TB_VTSetUp,a0
	ELHGET_LKA	a0,d0	;requested LKA
	sub.w	OldLKA,d0
	bpl.s	10$
	neg.w	d0
	
10$	cmpi.w	#CLIPMAXCHANGE,d0
	bgt.s	20$

	ELHGET_LKB	a0,d0	;requested LKA
	sub.w	OldLKB,d0
	bpl.s	15$
	neg.w	d0
15$	cmpi.w	#CLIPMAXCHANGE,d0
	ble.s	90$

* Clip was changed too much, so wait at a field
* We mess with EH0 because SendELHList2Toaster always sends EH0
20$	move.l	VTSU_RG+SURG_EH0R(a0),-(sp)
	move.l	VTSU_BI+SUBI_EH0B(a0),-(sp)
	move.l	Old0RG,VTSU_RG+SURG_EH0R(a0)
	move.l	Old0BI,VTSU_BI+SUBI_EH0B(a0)

	lea	elhclips(pc),a0
	CALLTL	SendELHList2Toaster

	CALLTL	Wait4Top	

* restore EH0 
	DEA.l	TB_VTSetUp,a0
	move.l	(sp)+,VTSU_BI+SUBI_EH0B(a0)
	move.l	(sp)+,VTSU_RG+SURG_EH0R(a0)

90$	bclr.l	#1,d1
	PUT.b	d1,TB_StashCount

100$	movem.l	(sp)+,d0-d1/a0
	rts

elhclips	dc.b	EH68,EH69,EHEND

	CNOP	0,2


***************************************
	IFD	CRAP	;I was never able to get this to work!!!!

* UpdateClipMode(a5->TB)
UpdateClipMode:
	movem.l	d0-d1/a0-a1/a6,-(sp)
	GET.w	TB_KeyModePri,d0
	cmp.w	TB_KeyModeSec(a5),d0
	beq.s	20$

	GET.l	TB_SYSBase,a6
	CALLROM	Forbid		
	CALLTL	SoftSpriteOff	

	DEA	TB_ClipFGL,a0
	moveq	#CLIPMODEID,d0
	CALLTL	IndexFastG

	beq.s	10$
	move.l	d0,a0
	move.l	FG_Function(a0),d0
	beq.s	10$
	move.l	d0,a1
	move.l	#FGC_UPDATE,d0
	move.l	a5,-(sp)
	movem.l	d0/a0/a5,-(sp)
	jsr	(a1)
	movem.l	(sp)+,d0/a0/a5
	movea.l	(sp)+,a5
	GET.l	TB_Window,a1
	moveq	#1,d0
	moveq	#0,d1
	CALLTL	DrawFastGList

10$	move.w	TB_KeyModeSec(a5),TB_KeyModePri(a5)

	CALLTL	SoftSpriteOn
	GET.l	TB_SYSBase,a6
	CALLROM	Permit

20$	movem.l	(sp)+,d0-d1/a0-a1/a6
	rts
	
	ENDC

*******************************************************************
* This is used before loading Framestores or Keyed Stills if there
* is a FULL screen (not 400) key being displayed.
* The key is dumped because we need that space for writing to the Toaster.
* I'm also making this called by code that normally needs to CancelCG.

* Assume if there's an alpha key, that AVEI is up.

	XDEF	KillAlphaKey
KillAlphaKey	
	DUMPMSG	<In KillAlphaKey>	
	movem.l	d0/a0,-(sp)
	move.l	TB_CurrentAlphaBM(a5),d0	;USED BELOW
	beq	10$

	CALLTL	SendELH2Toaster	;If the key has gone away already by MainOLayClip
				;SetAMandBM then lets send it out before
				;the following.

	CALLTL	ResetAVEI	;this will prevent recursion,
				;since DoTakeNoKey also calls KillAlphaKey !!!!

	DUMPHEXI.w	<OLay 8=>,TB_OLaySec(a5),<\>
	

*
** Fix for Keys re-appearing after TBar drags to bottom or Autos
** skell Get real, it wasnt that hard..   
	TST.W 	TB_OLaySec(a5)
	BEQ	808$
	
	CALLTL	DoTakeNoKey
808$
*
** END OF TEST
*
	DUMPHEXI.w	<OLay 9=>,TB_OLaySec(a5),<\>

	btst	#AVEI_BIT,TB_Flags(a5)	;probably set
	beq	10$		;planes won't be trashed on Non-AA machine

	btst.b	#AACHIPS_BIT,TB_Flags2(a5)
	beq.s	5$	;jump if on non AA machine

	movea.l	d0,a0
	cmpi.b	#2,bm_Depth(a0)	;get current key depth to see if it trashed AVEI
	bls.s	5$

;**!++ Just after that OLay9 print, the key pops back on.  I have determined
; that it happens somehwere in fastgadgets.a/ReDoDisplay called below.

	CALLTL	ReDoDisplay	;Will tell Editor new depth, key probably trashed upper planes of AA AVEI

5$	CALLTL	InstallAVEIdoELH	;Everything is back to normal

;*+ Try getting rid of key by setting fx to std effects
	CALLTL	SelectStdEfx


10$	movem.l	(sp)+,d0/a0
	DUMPMSG	<leaving KillAlphaKey>	
	rts

****************************************************************
* WARNING!! THIS FUNCTION JUMPS INTO THE NEXT ONE
DoTakeNoKey
	movem.l	d0-d7/a0-a6,-(sp)	;save all regs for sake of FGC cmd


	tst.w	TB_TValSec(a5)
	bne	dotake10

	GET.l	TB_EFXbase,d0
	beq	5$

	move.l	d0,a0
	tst.w	EF_OldTBar(a0)
	bge	dotake10

5$	tst.w	TB_OLaySec(a5)
	beq	dotake666
	bra.s	dotake10

****************************************************************
* Pre 12-26-91 this just did a FGC_TAKE which would take Prvw.
* Now it Takes what was on Main, getting out of any keying / transitions
* with the exception of Non-Transition LumKey.
* LUT mode is unaffected.  All buttons and correct ELH are sent.
* WARNING!! THE ABOVE FUNCTION JUMPS INTO THIS ONE

DoTake:		;a5->TB
	movem.l	d0-d7/a0-a6,-(sp)	;save all regs for sake of FGC cmd

	tst.w	TB_TValSec(a5)
	bne.s	dotake10

	GET.l	TB_EFXbase,d0
	beq.s	dotake5

	move.l	d0,a0
	tst.w	EF_OldTBar(a0)
	bge.s	dotake10

dotake5:
	DEA.l	TB_VTSetUp,a0
	ELHGET_CDS	a0,d0
	cmpi.w	#VTI_CDS_LUMKEY,d0
	beq	dotake666

	tst.l	TB_CurrentAlphaBM(a5)	;Don't kill Alpha Keys
	bne	dotake666

	tst.w	TB_OLaySec(a5)
	beq	dotake666

dotake10:
	DUMPHEXI.w	<OLay 10=>,TB_OLaySec(a5),<\>

	XCALL	ExitShiftedKey


	DUMPHEXI.w	<OLay 11=>,TB_OLaySec(a5),<\>

	DUMPMSG	<Calling KillAlphaKey, from DoTake>
	CALLTL	KillAlphaKey

	GET.l	TB_EfxFG,d0
	beq.s	15$

	move.l	d0,a0
	move.l	FG_Function(a0),d0
	bne	18$

* No EFX crouton, so do the best we can. Probably never called. 
* If this is called much, it should be enhanced.
15$	clr.w	TB_OLaySec(a5)
	clr.w	TB_TValSec(a5)
	clr.w	TB_TBarTime(a5)

	DUMPHEXI.w	<OLay 12=>,TB_OLaySec(a5),<\>

	CALLTL	CookMain
	DUMPMSG	<DoTake doing cookmain and serve br dt666>
	XJSR	ServeELH
	bra	dotake666

* Trick into taking the source which is on Main
18$
	DUMPHEXI.w	<OLay 13=>,TB_OLaySec(a5),<\>

	GET.w	TB_MainSec,d1
	PUT.w	TB_PrvwSec(a5),TB_MainSec
	PUT.w	d1,TB_PrvwSec

* try to keep Program and Prvw different after take
	GET.w	TB_PrvwSec,d1
	cmp.w	TB_MainSec(a5),d1
	bne.s	19$
	tst.w	TB_OLaySec(a5)
	beq.s	19$
	GET.w	TB_OLaySec,d1
	PUT.w	d1,TB_MainSec
	
19$
	DUMPHEXI.w	<OLay 14=>,TB_OLaySec(a5),<\>

	cmpi.b	#M_LUTBUS_MAIN,TB_LutBus(a5)
	bne.s	20$
	PUT.b	#M_LUTBUS_PRVW,TB_LutBus
	bra.s	30$

20$	cmpi.b	#M_LUTBUS_PRVW,TB_LutBus(a5)
	bne.s	30$
	PUT.b	#M_LUTBUS_MAIN,TB_LutBus

30$	movem.l	a0/a5,-(sp)
	move.l	#FGC_TAKE,-(sp)
	move.l	d0,a0

	DUMPHEXI.w	<OLay 15=>,TB_OLaySec(a5),<\>

	jsr	(a0)			;Take Program
	lea	12(sp),sp		;Send it out! & puts up AVEI (???)

dotake666:

	DUMPHEXI.w	<OLay 16=>,TB_OLaySec(a5),<\>

	movem.l	(sp)+,d0-d7/a0-a6
	rts
	
***************************************

	END
