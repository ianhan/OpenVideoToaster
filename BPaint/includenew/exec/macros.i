	IFND	EXEC_MACROS_I
EXEC_MACROS_I	 SET	 1
**
**	$VER: macros.i 39.0 (15.10.91)
**	Includes Release 39.108
**
**	Handy macros for assembly language programmers.
**
** Modified 11-30-92 by Steve H for HiSoft assembler
**
**	(C) Copyright 1985-1992 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

		IFND	DEBUG_DETAIL
DEBUG_DETAIL	SET	0	;Detail level of debugging.  Zero for none.
		ENDC


JSRLIB		MACRO	;FunctionName
		XREF	_LVO\1
		jsr	_LVO\1(a6)
		ENDM

JMPLIB		MACRO	;FunctionName
		XREF	_LVO\1
		jmp	_LVO\1(a6)
		ENDM

BSRSELF	MACRO
		XREF	\1
		bsr	\1
		ENDM

BRASELF	MACRO
		XREF	\1
		bra	\1
		ENDM

BLINK		MACRO
		IFNE	DEBUG_DETAIL
		  bchg.b #1,$bfe001  ; Toggle the power LED
		ENDC
		ENDM

CLEAR		MACRO
		moveq.l #0,\1
		ENDM

CLEARA		MACRO
		suba.l	\1,\1	;Quick way to put zero in an address register
		ENDM

	ENDC	; EXEC_MACROS_I
