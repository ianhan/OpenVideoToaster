/*********************************************************************\
*
* $Subs.h$
*
* $Id: Subs.h,v 1.2 1995/08/15 16:35:12 Flick Exp $
*
* $Log: Subs.h,v $
*Revision 1.2  1995/08/15  16:35:12  Flick
*First release (4.05)
*
*Revision 1.1  1995/05/03  10:36:06  Flick
*Removed prototypes
*
*Revision 1.0  1995/05/02  11:02:35  Flick
*FirstCheckIn
*
*
* Copyright (c) 1995 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
\*********************************************************************/

#ifndef	INC_SUBS_H
#define	INC_SUBS_H

#ifndef	INC_AUDIO_H
#include "Audio.h"
#endif

struct FINDMACH {					// State machine for finding clip frame
	BOOL		fm_freeme;			// Free this structure back to pool when done?
	UBYTE		fm_error;			// Error code
	UBYTE		fm_sdrive;			// SCSI channel represented
	UBYTE		fm_state;			// State number
	UWORD		fm_addr;				// Address of data in DRAM
	ULONG		fm_dram;				// Allocated DRAM block
	ULONG		fm_tail;				// Block of clip's tail header
	UWORD		fm_blk;				// Which block in table
	UWORD		fm_entry;			// Which entry in block
	UWORD		fm_back;				// How far back from milestone
//	SCSIKEY	fm_skey;				// For SCSI queueing
	/* Stuff for shuttle/jog only */
	UWORD		fm_entries;			// Number of indexed frames in table
	ULONG		fm_limit;			// Number of fields max
	BOOL		fm_table;			// Entire table in DRAM?
	UBYTE		fm_audchan;			// Audio channel allocated
	UBYTE		fm_numaudchans;	// Number of audio channels for clip
	UBYTE		fm_monochan;		// Which mono chan (L/R)
	UBYTE		fm_machnum;			// Machine number to use
	UBYTE		fm_clipflags;		// ClipFlags for clip
	APTR		fm_workblk;			// Temporary work SRAM block
	/* Cheaters */
	ULONG		fm_next_frm;
	ULONG		fm_next_blk;
	ULONG		fm_prev_frm;
	ULONG		fm_prev_blk;
	ULONG		fm_same_frm;
	ULONG		fm_same_blk;
};


struct JogInfo {			/* Stuff for jog/shuttle */
	struct	FINDMACH	ji_finder;		// Frame-finder
	UBYTE		ji_nestcount;				// For folks who nest Jog open/close calls
	UBYTE		ji_channel;					// Channel used for open call
	BYTEBITS	ji_aflags;					// Copy of Action.flags on open
	UBYTE		ji_audchan;					// Audio channel allocated
	UBYTE		ji_numaudchans;			// Number of audio channels for clip
	UBYTE		ji_monochan;				// Which mono chan (L/R)
	UBYTE		ji_machnum;					// Machine number to use
	UBYTE		ji_clipflags;				// ClipFlags for clip
	ULONG		ji_fields;					// Total # fields in clip
	struct DSPevent	ji_dspup1,ji_dspup2;		// DSP volume up events
	struct DSPevent	ji_dspdn1,ji_dspdn2;		// DSP volume down events
};


#endif	/* INC_SUBS_H */
