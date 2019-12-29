/* $Panel.h$ - Stuff for Routines for Control Panels
* $Id: panel.h,v 2.55 1996/11/18 18:44:10 Holt Exp $
* $Log: panel.h,v $
*
*Revision TFOS 2000/05/01 Aarexx Aaron
*Rudimentary Comment Adjust.
*
*Revision 2.55  1996/11/18  18:44:10  Holt
*added more audio envelope support.
*
*Revision 2.54  1996/07/29  10:40:54  Holt
*added part of new audioenv panel.
*
*Revision 2.53  1995/10/02  15:04:59  Flick
*Added PLID_DESTPOPUP, new define FLY_VOL_MAX for *usable* Flyer volume name size
*
*Revision 2.52  1995/09/28  10:20:30  Flick
*Removed messy RAW_ key defines, now uses RawKeyCodes.h for std Amiga mappings
*
*Revision 2.51  1995/09/25  12:03:34  Flick
*Added some new PL_ flags, the long-needed HALF1 positioning (few support this yet) plus a new
*PLID system to pick out specific PLines within the panel (better than using PL_ flags!)
*
*Revision 2.50  1995/09/19  12:46:53  Flick
*New GB_ stuff for GenButtons, new Panel initializer structure
*
*Revision 2.49  1995/09/13  12:01:49  Flick
*Added stuff for fine control over PLine placement, structures for segmented
*audio meters and CutClipDisplay, other beautification
*
*Revision 2.48  1995/08/16  10:44:36  Flick
*New PL_xxx defines for shadow/phantom functions
*Added a partial RAWKEY_xxx list
*
*Revision 2.47  1995/07/27  18:09:28  Flick
*Added PL_GENBUTT so I can add some freaking buttons
*
*Revision 2.46  1995/06/20  23:43:16  Flick
*PL_ flags are now all in "1<<x" notation.  Protected them with ()'s  !!!
*
*Revision 2.45  1995/04/25  15:06:21  Flick
*Added ClipxLit flags in AudIndicator struct
*
*Revision 2.44  1995/03/07  16:13:12  CACHELIN4000
*New FASTDRIVE compression mode support, fastdrive bit in config
*
*Revision 2.43  1995/02/27  13:39:41  CACHELIN4000
*Add AudIndicatro struct to replace BarGraph, which fell out of favor.
*
*Revision 2.42  1995/02/24  11:11:38  CACHELIN4000
*Add TagMess structure
*
*Revision 2.41  1995/02/19  16:40:09  CACHELIN4000
**** empty log message ***
*
*Revision 2.40  1995/02/19  01:43:46  CACHELIN4000
**** empty log message ***
*
*Revision 2.39  1995/02/11  17:02:05  CACHELIN4000
*add PNL_NUMSLIDER type, notes on STRING width
*
*Revision 2.38  1995/02/01  17:56:11  CACHELIN4000
*add some defines, etc.
*
*Revision 2.37  1995/01/25  18:36:57  CACHELIN4000
*Add PNL_STEPSLIDER type
*
*Revision 2.36  1995/01/24  16:39:54  CACHELIN4000
*Add Comment, icon to NewClip struct, etc.
*
*Revision 2.35  1995/01/24  11:21:30  CACHELIN4000
**** empty log message ***
*
*Revision 2.34  1995/01/13  12:59:00  CACHELIN4000
*Add partner stuff to PanelLine struct,  PL_PARTNER and misc. flags
*
*Revision 2.33  1994/12/24  12:42:46  CACHELIN4000
*Note use of PropEnd for strings
*
*Revision 2.32  1994/12/04  22:14:24  CACHELIN4000
**** empty log message ***
*
*Revision 2.31  1994/12/03  18:34:07  CACHELIN4000
**** empty log message ***
*
*Revision 2.30  1994/12/03  14:50:28  CACHELIN4000
**** empty log message ***
*
*Revision 2.29  1994/12/03  13:42:26  CACHELIN4000
*duoooh!!
*
*Revision 2.28  1994/12/03  13:40:14  CACHELIN4000
*Add define for TUNE_QUICK, and PNL_CHECK panel type
*
*Revision 2.27  1994/11/30  23:25:17  CACHELIN4000
*add PL_SMREF flag
*
*Revision 2.26  1994/11/04  16:50:35  CACHELIN4000
*add PL_PLAY flag
*
*Revision 2.25  94/10/27  23:14:51  CACHELIN4000
*Fix notes on UserFun, add Window to PanelLine struct.
*
*Revision 2.24  94/10/25  08:10:57  Kell
*Added new flags to the RenderCallBack structure for Video FineTune.
*
*Revision 2.23  1994/10/11  21:41:21  CACHELIN4000
*PNL_DUOSLIDE, UserFun, etc.
*
*Revision 2.22  94/10/10  17:18:57  CACHELIN4000
*Add UserFunc(), UserObj to PanelLine structure...
*
*Revision 2.21  94/10/05  00:56:46  CACHELIN4000
*Add PNL_Button type, f'n in EZNUM
*
*Revision 2.20  94/09/27  17:18:19  CACHELIN4000
*Add f'n call to POPUP line Param2
*
*Revision 2.19  94/09/24  15:13:00  CACHELIN4000
**** empty log message ***
*
*Revision 2.18  94/09/22  17:49:58  CACHELIN4000
*Comment EZSlider changes
*
*Revision 2.17  94/09/20  23:40:59  CACHELIN4000
*Add PNL_SKIP type
*
*Revision 2.16  94/09/13  20:20:12  CACHELIN4000
*Move PNL_CROUTON FG to Param2, Audio bit defs, RCB struct change
*
*
*Revision 2.13  94/09/09  15:33:51  Kell
*Bit 30 of flags indicates if in FF/REW or Shuttle mode.
*
*Revision 2.12  1994/09/07  11:02:28  CACHELIN4000
*add some PNL_types for Flyer, etc.
*
*Revision 2.10  1994/09/05  20:16:46  Kell
*Added more fields to define Shuttle Speed.
*
*Revision 2.9  1994/09/05  18:01:51  Kell
*Added shuttle speed/direction information to the RenderCallBack struct.
*
*Revision 2.7  1994/09/02  08:26:04  Kell
*Put MouseX/Y fields into the RenderCallBack structure.
*
*Revision 2.5  94/08/30  17:22:36  CACHELIN4000
*Add PL_Flags, definitions
*
*Revision 2.0  94/04/20  17:35:10  CACHELIN4000
*FirstCheckIn
*
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*********************************************************************/

#define REG(x) register __##x
#define MAX(a,b) ((b>a) ? b:a)
#define MIN(a,b) ((b<a) ? b:a)
#define BOUND(x,l,u) MIN(MAX(x,l),u)
#define EVEN(x)  (x&0xFFFFFFFE)
#define DISABLE(g)	g->Flags |= GFLG_DISABLED
#define ENABLE(g)		g->Flags &= (~GFLG_DISABLED)
#define SELECT(g)		g->Flags |= GFLG_SELECTED
#define DESELECT(g)	g->Flags &= (~GFLG_SELECTED)
#define IEQUALIFIER_SHIFT (IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT)

#define Frms2Flds(x)			((x) << 1)
#define Flds2Frms(x)			((x) >> 1)
#define Fly4Flds2Frms(x)	(((x) >> 2) << 1)

#define FRAME_QUANT	2
#define STILL_QUANT 2
#define MIN_FIELD	0

//#define TEMP_CLIP_NAME "_._|~~x~~temp~~x~~|_._"
#define TEMP_CLIP_NAME "LastClipMade...Uncut"

#define COMMENT_MAX 80
#define STRING_ID 1002	// Magic Number
#define MAX_STRING_BUFFER	300
#define CLIP_NAME_MAX	42
#define CLIP_PATH_MAX	120
#define FLY_VOL_MAX		20
#define TEXT_BASE 9
#define LINE_HEIGHT (TEXT_HEIGHT+4)
#define LSP 12
#define PNL_WIDTH 264 // 238
#define PNL_X1 10
#define PNL_Y1 0
#define PNL_DIV 4
#define PNL_YADD 12
#define PTEXT_H 23
#define PTEXTLINE_H 30
#define PSLIDE_H PTEXT_H+16
#define PTEXT_YOFF 6
#define PTIME_W 181
#define PTIME_H 62
#define PTIME_POFF 32
#define PTIME_YOFF 15
#define PTIME_XOFF 80
#define PIN_H 40
#define PIN_YOFF 10
#define PCHOICE_H 54
#define PCHOICE_TOFF 6
#define PCHOICE_YOFF 24
#define MAX_PANEL_STR 32
#define PNL_MAX	20
#define PEZSLIDE_W	34
#define PTCSTRING_W 96
#define PLENSTRING_W 54
//#define PPOPUP_W 160
#define PPOPUP_W 140
#define PNUMSTRING_W 64
#define PANEL_TOP 44
#define PANEL_LENGTHX ((PNL_WIDTH<<1) - PNL_X1 - 92)

// Bits used by PLine->Flags value
#define PL_IN			(1<<0)
#define PL_OUT			(1<<1)
#define PL_DEL			(1<<2)
#define PL_LEN			(1<<3)
#define PL_AVAIL		(1<<4)
#define PL_FLYER		(1<<5)
#define PL_AUD1		(1<<6)
#define PL_AUD2		(1<<7)
#define PL_AUDIO		(PL_AUD1|PL_AUD2)
#define PL_CFRAME		(1<<8)	// Tells numbers to round(down) to even frame
#define PL_GENBUTT	(1<<9)	// General button, has a sub-ID
#define PL_DUAL		(1<<10)
#define PL_PLAY		(1<<11)
#define PL_SMREF		(1<<12)	// Smart Refresh window for requesters over panel
#define PL_PARTNER	(1<<13)	// Has a partner
#define PL_SHADOW		(1<<14)	// In and Out maintain relative separation
#define PL_SILENT		(1<<15)	// This line is a partner tag-along, dont send switcher
#define PL_PHANTOM	(1<<16)	// Hidden partner relationship
#define PL_FRAC32		(1<<17)	// 32-bit fractional value proportional to max
#define PL_ACTIVATE	(1<<18)	// Marks (string) gadget to activate on panel open
#define PL_HIDDEN		(1<<19)	// Not visible (at least until later)
#define PL_ENVELOPE	(1<<20)	// An Envelope Time or Value Gadget.




// CreateContCancel Tune bits for FineTune/QuickTune button
#define	TUNE_NONE			0
#define	TUNE_FINE			1
#define	TUNE_QUICK		2
#define	TUNE_PROC			4

// Bits used by TAG_AudioOn value
#define AUD_CH1_EXISTS		1
#define AUD_CH2_EXISTS		2
#define AUD_CH1_ENABLE		4
#define AUD_CH2_ENABLE		8
#define AUD_EXISTS			(AUD_CH1_EXISTS|AUD_CH2_EXISTS)
#define AUD_ENABLE			(AUD_CH1_ENABLE|AUD_CH2_ENABLE)
#define AUD_ENVELOPE			16


#define EZ_DELAY  3

enum {
	PNL_TEXT=1,				// Label is text, HeightAdj is user height if label==NULL, skip if label=""
	PNL_TIME,				// Param2=FXSpeed PLine to set to V
	PNL_IN_TYPE, PNL_OUT_TYPE,
	PNL_CHOICE4, PNL_CHOICE5,
	PNL_DIFF,				// DIFF is (*(Param) - *(Param2)) as a time field, PropEnd holds val, 
								// UserObj=1 for custom positioning via X,Y WORDs in Propstart
								// PropStart has position,G5 holds diff add-on, label should have space(s) on end
	PNL_TOGGLE,				// Param is bit mask, Param2, array of labels, PropEnd=#of toggles <=8
	PNL_FXSPEED,			// *Param is value, Param2 is array of 4(ULONG) field counts: S,M,F,V for FXTIME
								// PropStart=0(for FXTime update) or address of a PNL_TIME to update
	PNL_FXTIME,				// Like a DIFF, but attached to an FXSPEED
	PNL_STRING,				// String gadget Param=str ptr, PropEnd=max len, g5=optional gad width
	PNL_NUMBER,				// int gadget *Param=int , Propstart=min, propend=max
	PNL_POPUP,				// Param=names[], propstart=item, propend=max entries (NUM_VIEW)
								// UserFun = void __asm PopFunc(REG(a0) struct PanelLine *);
	PNL_CROUTON,			// good old 80x50 image.. param2=FG, param=comment, propend=commentbuf size
	PNL_SUBPANEL,			// param=f'n
	PNL_SLIDER,				// param=val, Propstart=min, propend=max
	PNL_DIVIDE,				// Just a line...
	PNL_VCR,					// VCR Controls w/ counter param=param2=counterval,
								// if param=NULL -> NO String gadget, just param2
	PNL_PLAY,				// Stop/Play buttons for FX, etc. Param is a time (LONG) to display
	PNL_EZTIME,				// Mini-Slider time gad. HH:MM:SS:FF SMPTE, Param2=FXSpeed PLine to set to V
	PNL_EZLEN,				// Mini-Slider time gad. Length in SS:FF
	PNL_EZNUM,				// Mini-Slider integer gad. UserFun=f'n
	PNL_FLYTIME,			// just like PNL_TIME, but Flyer-ready, G2 = Flyer frame offset
	PNL_EZSLIDER,			// Balance slider with centering button, param=overall volume
								//  param2 is end labels array,
	PNL_FLYSLIDER,			// Plain slider with flyer controls, G2 = Flyer frame offset
	PNL_SKIP,				// A way of ignoring irrelevant lines without chnaging param
	PNL_BUTTON,				// A Labeled button, calls UserFun()
	PNL_DUOSLIDE,			// Dual slider with in(*Param) and out(*Param2) values, G2=Flyer frame offset,
								// G1 is fake prop, G4 out string, G5, out prop(detached)
	PNL_CHECK,				// A single toggle button, Param=1/0, supports a long description
	PNL_STEPSLIDE,			// Slider with single-step buttons, optional
								// centering button (Param2!=NULL), which goes to *Param2
	PNL_NUMSLIDER			// Plain slider with number gadget...
};

enum {
	PPOS_JUST=0,		// Unused
	PPOS_LEFT,
	PPOS_CENTER,
	PPOS_RIGHT
};
#define	PPOS_JUSTMASK	0x03		/* Mask for justification code */
// Other flags in this field...
#define	PPOS_HALF1		0x20		/* Place in left half of wide panel */
#define	PPOS_HALF2		0x40		/* Place in right half of wide panel */
#define	PPOS_WIDER		0x80		/* Place in left, next one in right half of wide panel */

enum {
	PAN_CANCEL,
	PAN_CONTINUE,
	PAN_EXPERT,
	PAN_EASY,
	PAN_PROCESS,
	PAN_CUTUP,
	PAN_LOOP,
	PAN_RECORD,
	PAN_ENVL,
}; // Panel() return values

typedef BOOL (*PanHandler)(struct EditWindow *, struct FastGadget *);

//*******************************************************************
struct InitPanelLine {
	UBYTE	Type;
	UBYTE	Align;
	char	*Label;
	WORD	XAdj;
	WORD	HeightAdj;
};

struct PanelLine {
	UBYTE	Type;
	UBYTE	Align;
	char	*Label;
	WORD	XAdj;
	WORD	HeightAdj;
	LONG	*Param,*Param2;
	LONG	PropStart,PropEnd;
	WORD	(*Create)(UWORD,UWORD,struct PanelLine *,struct Gadget **);
	WORD	(*Draw)(UWORD,UWORD,struct PanelLine *,struct Window *);
	BOOL	(*Handle)(struct PanelLine *,struct  IntuiMessage *,struct Window *);
	void	(*Destroy)(struct PanelLine *);
	ULONG	__asm (*UserFun)(REG(a0)struct PanelLine *,REG(a1)struct IntuiMessage *,REG(a2)APTR Obj);
	APTR	UserObj;
	ULONG	Flags;  // determines which lines respond to hotkeys, send flyer commands
	struct Gadget *StrGadg,*PropGadg,*IncGadg,*DecGadg;
	struct Gadget *G1,*G2,*G3,*G4,*G5;
	struct Window	*Win;
	UWORD		NumParts;		// Number or 'partner' PanelLines in Partners array
	struct PanelLine *Partners; // Array of associated PanelLines
	ULONG		*Relation; // Array of flags to describe type of relationship with that partner
	ULONG	ShadowOffset;		// Used with PL_SHADOW
	UWORD	PLID;					// ID for specific line in a panel
};

#define PR_MIRROR		1      // Partner moves with, has same value as pline
#define PR_SHADOW		1<<1   // Partner moves other value by same amount as pline

enum {
	PLID_DROPIND=1,				// Dropped fields indicator
	PLID_DESTPOPUP,			// Destination drive
	PLID_USEAUDENV,
};

//*******************************************************************
// RenderCallBack->Flags bit definitions
#define DHD_PLAY_REV			(1<<31)  // initial shuttle direction (1=reverse)
#define DHD_SHUTTLE_MODE	(1<<30)  // clear if FF/REW Jog, set if Shuttle

#define DHD_INPOINT			(1<<29)	// set if moving inpoint
#define DHD_OUTPOINT			(1<<28)	// set if moving outpoint
#define DHD_VIDEOSLIDER		(1<<27)	// set if moving video slider
#define DHD_AUDIOSLIDER		(1<<26)  // set if moving audio slider

#define DHD_STR_UPDATE		(1<<17)
#define DHD_MOUSE_UPDATE	(1<<18)

struct RenderCallBack {
	void __asm (*RenderFn)(register __a0 APTR);
	struct FastGadget *FG;
	ULONG	Frame;
	ULONG	Min;
	ULONG	Max;
	ULONG	Flags;
	struct Window *win;
	struct PanelLine *pline;
	WORD	MouseY;		//initially same as sc_MouseY
	WORD	MouseX;		//initially same as sc_MouseX
	WORD	VelocityNumerator;
	UWORD	VelocityDenominator;
};

enum { STD_COMP_MODE, EXTD_COMP_MODE, AUDIO_COMP_MODE, 
		FASTSTD_COMP_MODE, FASTEXTD_COMP_MODE };

enum { AMODE_STEREO, AMODE_LEFT, AMODE_RIGHT, AMODE_NOAUDIO };
enum { TBC_BRT,TBC_CON,TBC_SAT,TBC_HUE,TBC_FAD,TBC_CPHZ,TBC_HPHZ,
			TBC_KEY,TBC_KEYM,TBC_ENC,TBC_INP,TBC_DEC,TBC_TRM};

// Modes for ES_CompressionMode; Low nibble is mode, high nibble is drive speed
#define COMP_STD		0x00
#define COMP_EXT		0x03
#define COMP_AUD		0x00 // doesn't matter here, this should set source
#define DRIVE_FAST	0x10
#define DRIVE_HOLOGRAPHIC	0x20
#define COMP_FSTD		COMP_STD|DRIVE_FAST
#define COMP_FEXT		COMP_EXT|DRIVE_FAST
#define COMP_FBIG		COMP_STD|DRIVE_HOLOGRAPHIC

#define TBCTERM_NUM	5
#define TBCSRC_NUM	4
#define TBCENCOD_NUM	4
#define TBCDECOD_NUM	3
#define TBCKEY_NUM	2
#define TBCKEYM_NUM	3
#define	PROPSCALE(v,l,h)	(( l + (v*(h-l))/MAXPOT ))
#define	AUDIO_BYTE	0xA2
#define MAX_AUD_FADE	750 // Max 1500 fields (Marty, Nov  3 1994)
#define	IS_AUDIO_DRIVE(FVI)		((FVI->Flags&FVIF_AUDIOREADY) && !(FVI->Flags&FVIF_VIDEOREADY))
#define	PAN_LEFT					-32768;
#define	PAN_RIGHT					32767;
#define HAS_LEFT(f)			((f&AUD_CH1_EXISTS) && !(f&AUD_CH2_EXISTS))
#define HAS_RIGHT(f)		(!(f&AUD_CH1_EXISTS) && (f&AUD_CH2_EXISTS))
#define HAS_STEREO(f)		((f&AUD_CH1_EXISTS) && (f&AUD_CH2_EXISTS))
#define HAS_ANYAUDIO(f)		(f&AUD_EXISTS)
#define IS_LEFT(f)			((f&AUD_CH1_ENABLE) && !(f&AUD_CH2_ENABLE))
#define IS_RIGHT(f)			(!(f&AUD_CH1_ENABLE) && (f&AUD_CH2_ENABLE))
#define IS_STEREO(f)		((f&AUD_CH1_ENABLE) && (f&AUD_CH2_ENABLE))
#define IS_ANYAUDIO(f)			(f&AUD_ENABLE)
#define IS_AUDENVELOPE(f)	(f&AUD_ENVELOPE)
#define SET_LEFT(f)			f = ( (f&(~AUD_CH2_ENABLE))|AUD_CH1_ENABLE )
#define SET_RIGHT(f)		f = ( (f&(~AUD_CH1_ENABLE))|AUD_CH2_ENABLE )
#define SET_STEREO(f)		f |= (AUD_CH1_ENABLE|AUD_CH2_ENABLE)
#define SET_NOAUDIO(f)	f &= ~AUD_ENABLE
#define SET_AUDENVELOPE(f)		f = (f|AUD_ENVELOPE)
#define SET_NOAUDENVELOPE(f)		f = (f&~AUD_ENVELOPE)


//#define SOURCE_INDEX_OFFSET	2 // This is the number of Flyer sources skipped
#define SOURCE_INDEX_OFFSET	0 // This is the number of Flyer sources skipped
															// in the popup/sources Array cause of no TBC
// #define AUDIO_ONLY_SOURCE		5-SOURCE_INDEX_OFFSET // Index of Audio Only popup element
                             // if CurFlySource == this, then flyer should get 0 as source
// #define IS_AUDIO_SOURCE(x) ((x)==AUDIO_ONLY_SOURCE)

#define CUTCLIP_PRESERVE		0
#define CUTCLIP_DESTROY			1

enum { CLIP_EMPTY,	CLIP_ACTIVE,	CLIP_LOCKED };

enum {
	PAL_BLACK,
	PAL_DGRAY,
	PAL_LGRAY,
	PAL_WHITE,
	PAL_LBLACK,
	PAL_DDGRAY,
	PAL_DYELLOW,
	PAL_LYELLOW,
// Those below may not complement/highlight correctly...
	PAL_LBROWN,
	PAL_DBROWN,
	PAL_RED,
	PAL_PINK,
	PAL_BLUE,
	PAL_CYAN,
	PAL_DGREEN,
	PAL_LGREEN
};


struct CutClipData {
	struct NewClip			*cl;			// Current sub-clip
	struct ClipDisplay	*ClipDisp;
	struct PanelLine		*TimePL;
	struct PanelLine		*StrPL;
	struct PanelLine		*LenPL;
	struct PanelLine		*FramePL;	// Icon frame slider PL
	struct PanelLine		*CommPL;
	struct RastPort		*RP;
	struct Window			*Window;
	ULONG						Tmin,Tmax;
	struct Gadget			*Frame;
	struct Gadget			*String;
	ULONG						clipnum;
	int						clipnumdigits;
};

struct NewClip	{
	struct MinNode	Node;
	ULONG	in;
	ULONG	out;
	ULONG	type;  // should be from CLIP enum
	ULONG	icon;
	char	*Name;
	char	*Comment;
	};

struct ClipDisplay {
	UWORD	X;
	UWORD	Y;
	UWORD	W;
	UWORD	H;
	ULONG	MinVal;
	ULONG	MaxVal;
	ULONG	Scale;   	// = (0xFFFF*W)/MaxVal
	struct RastPort *RP;
	struct MinList Clips;
	};


struct AEDKey	{
	struct MinNode	MN;
	ULONG	RealTime;		//Actual flyer field time value.
	ULONG	Time;				//Time in envelope display 
	UWORD	Value;			//Actual Value
	UWORD	Scaled_Time;	//Time scaled to 0-485	
	UWORD Scaled_Val;		//Actual Value scaled to fit envelope hight
	UBYTE	Act;				//Inactive,active,selected
	UBYTE Att;				//TimeLocked,Deleteable,
	};

// Att flags
#define TimeLocked	0x01;
#define Deleteable	0x02;
#define UnUsed			0x04;



struct AudEnvDisp {
	UWORD	X;
	UWORD	Y;
	UWORD	W;
	UWORD	H;
	ULONG InPoint;
	ULONG OutPoint;
	ULONG	FadeIn;
	ULONG	FadeOut;
	ULONG	MinVal;
	ULONG	MaxVal;
	ULONG SuperEnvWidth;
	ULONG HScale;						//keys per pixel or pixels per key.
	ULONG	VScale;						//vertical scaling factor.
	ULONG	KeyCount;					//number of keys in AEDKeys list.
	struct Gadget	 EnvDispGadget;
	struct Window	 *PWindow;
	struct AudioEnv *AETagTable;
	struct RastPort *RP;
	struct RastPort *DRP;
	struct BitMap	 *DBM;
	struct AEDKey	 *SELECTED_KEY;
	struct MinList  AEDKeys;
	};


enum	{
	AEDKey_Inact,	
	AEDKey_act,	
	AEDKey_sel	
};	
	
/*
struct EnvPLPtr {
	struct PanelLine *Title;	
	struct PanelLine *Divide;	
	struct PanelLine *Text;	
	struct PanelLine *Text2;	
	struct PanelLine *Action;	
	struct PanelLine *Time;	
	struct PanelLine *Volume;
	struct PanelLine *Text3;
	struct PanelLine *Divide2;
	struct PanelLine *Continue;
	struct PanelLine *Cancel;
	};
*/


struct BarGraph {
	UWORD	X;
	UWORD	Y;
	UWORD	W;
	UWORD	H;
	UWORD	Val;
	UWORD	MaxVal;
	ULONG	Scale;   	// = (0xFFFF*W)/MaxVal
	struct RastPort *RP;
	};

#define	NUMBARSEGS	3

struct SegBarGraph {
	struct RastPort *RP;
	UWORD	X,Y;
	UWORD	W,H;
	UWORD	Val;
	UWORD	MinVal[NUMBARSEGS];
	UWORD	MaxVal[NUMBARSEGS];
	ULONG	Scale;   	// = (0xFFFF*W)/MaxVal
	UWORD	ClipX,ClipY;
	UWORD	ClipW,ClipH;
	BOOL	ClipLit;
	UBYTE	ClipHoldTime;	// Clip light hold time
	UBYTE	DecaySlew;		// Decay slew rate
	UBYTE	pad;
	UBYTE	PeakHoldTime;	// Peak mark hold time
	UWORD	PeakValue;		// Peak value (pixel pos)
};

struct AudIndicator {
	UWORD	X;
	UWORD	Y;
	UWORD	W;
	UWORD	H;
	UWORD	MaxVal;
	UWORD	ClipX;
	BOOL	Clip1Lit;
	BOOL	Clip2Lit;
	UBYTE *Clip;
	struct RastPort *RP;
	};


struct	AudioSet {
	ULONG	Volume;			// 0-100
	ULONG	V1;					// 0-0xFFFF
	ULONG	V2;					// 0-0xFFFF
	UWORD	Balance;		// 0-0xFFFF
	UWORD	Mode;
	WORD	Pan1;
	WORD	Pan2;
	struct FastGadget *FG;
	ULONG	AudioOn;
};


struct TagMess {
	ULONG	tm_Tag;
	ULONG	*tm_Val;
	ULONG	tm_vSize;
	ULONG	tm_Flags;
	struct FastGadget *tm_FG;
};

enum {
	GB_CONTINUE=1,
	GB_CANCEL,
	GB_FINE_TUNE,
	GB_QUICK_TUNE,

	GB_PROCESS,
	GB_CUT,
	GB_REMOVE,
	GB_PREV,
	GB_NEXT,
	GB_REORG,
	GB_MAKECLIPS,
	GB_RECPANEL,
	GB_AUDIOENV,
};

// STATUS FOR ENVELOPE CONTROL
enum {
	KEY_DRAG=1,
	KEY_CREATE,
	KEY_DELETE
};

