*********************************************************************
* assembler.i
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
* $Id: assembler.i,v 2.1 1992/05/27 00:14:13 Kell Exp $
*
* $Log: assembler.i,v $
*Revision 2.1  1992/05/27  00:14:13  Kell
*took out some switcher related EQUs
*
*Revision 2.0  92/05/19  00:04:12  Hartford
**** empty log message ***
*
*
*********************************************************************
	IFND	ASSEMBLER_I
ASSEMBLER_I SET	1	

	INCDIR	'cfx:inc/','include.i:','tinc:'

	OPT	O+,OW1-,OW2-,OW3-,OW4-,OW5-

* O+ = enable optimise everything, else use O- for no optimising
* O1+ = enable short branch optimisation (O1- disables)
* O2+ = enable addressing optimisation (O2- disables)
* OW1- = disable short branch optim. warning message??
* OW2- = disable addressing optim. warning message??
* OW3- = disable warning message?
* OW4- = disable warning message?
* OW5- = disable warning message?


_AbsExecBase	equ	4

TRUE	equ	1	;for JRs sake
FALSE	equ	0	;for JRs sake
NULL	equ	0	;for JRs sake

* Macro for Jamie at Elan

STARTLIST	MACRO
;;	LIST
	ENDM

	ENDC	;ASSEMBER_I
