/********************************************************************
* $sequence.c$
* $Id: sequence.c,v 2.136 1997/02/04 00:09:51 Holt Exp $
* $Log: sequence.c,v $
*Revision 2.136  1997/02/04  00:09:51  Holt
*turned off debugging.
*
*Revision 2.135  1996/11/20  16:09:34  Holt
*Fixed EditTo_FollowUp problem that was turning
*framestores and still into framestorestills.
*
*Revision 2.134  1996/11/18  18:42:43  Holt
*added more support for envelope key downloading.
*may have broken edit to music. seems to trash tags or somthing.
*
*Revision 2.133  1996/07/19  14:54:15  Holt
*finished up cfx.
*
*Revision 2.132  1996/07/15  18:30:11  Holt
*made many change to make cfx work in sequenceing.
*
*Revision 2.131  1996/06/26  10:30:12  Holt
*comment out defines for audio envelope struct
*they are defined in switcher/sinc/flyer.h
*
*Revision 2.130  1996/06/25  17:10:08  Holt
*made many changes to support audio envelopes
*
*Revision 2.129  1996/04/29  10:32:45  Holt
*fixed problem with fixupafter cutto(again!!!)
*
*Revision 2.128  1996/03/19  17:34:10  Holt
*now keeps extra len for all type of video
*
*Revision 2.127  1996/03/01  13:22:37  Holt
*fixed BExtra of an Effect causing audio to be off after an audio clip
*locked to the in point of the video after the effect.
*
*Revision 2.126  1995/12/26  18:18:23  Holt
*fixed cut to music so it will aline it points on colorframe boundrys.
*
*Revision 2.125  1995/12/20  15:34:04  Holt
*fixed problem with duration of flyer stills comming out 0.
*
*Revision 2.124  1995/11/27  16:53:34  Flick
*Added catch-all error for non-decoded sequencing errors
*
*Revision 2.123  1995/11/16  14:41:05  Flick
*Improved SCSI error trapping to be able to pinpoint the SCSI drive for
*missing drives and for incomplete transfers, too.
*
*Revision 2.122  1995/11/15  18:33:54  Flick
*Added trap/display for FERR_BADPARAM (4)
*
*Revision 2.121  1995/11/14  18:25:16  Flick
*Now traps/displays nice errors for Flyer SCSI errors 64 & 67
*
*Revision 2.120  1995/11/10  04:38:26  Flick
*Now uses Flyer's GetClrSeqError method to get drive # for SCSI problem error
*
*Revision 2.119  1995/11/09  17:53:46  Flick
*Added error message for 65 (bad status), including possible drive pinpointing
*
*Revision 2.118  1995/10/17  17:26:15  Flick
*Auto-trim overlapping with locked crouton now detects when cannot trim, fails to play
*
*Revision 2.117  1995/10/09  16:48:34  Flick
*Now passing FG to all GetEvent(), although as it turns out I don't need this (yet?)
*Fixed TimeBetweenFGs to know about Lost Croutons (CT_ERROR type)
*Sequencer tries to insert black for these, will warn user when playing that some exist.
*
*Revision 2.116  1995/10/06  16:13:59  Flick
*When unlocking croutons, now recalculates Current Time display too (as well as Project Time)
*
*Revision 2.115  1995/10/05  18:41:36  Flick
*2 new sequencing errors for A/B head problems
*Auto insert message more informative
*
*Revision 2.114  1995/10/02  15:30:30  Flick
*Sequences TakeFrames that are not 50%, support for StopOnErr option during sequencing
*Calculates Currrent & Project time correctly for FX that have non-overlapping A/B sources
*Supports Automatic audio ramping w/ effects
*Sequence processing is now abortable (puts up a requester now while processing)
*
*Revision 2.113  1995/09/28  10:19:10  Flick
*Now support TakeOffset tag in sequencing, removed crouton.lib hack, now navigates error croutons
*into view properly on "inserted black" and "croutons overlap" errors.
*
*Revision 2.112  1995/09/25  12:41:32  Flick
*Added seq error for playing video clip from non-video drive
*
*Revision 2.111  1995/09/19  12:18:38  Flick
*FX sequencing now supports A/BSourceLen tags
*
*Revision 2.110  1995/09/13  13:10:49  Flick
*Added GetPrevGadget for putting up prev source on preview
*Fixed bug when locking/unlocking multiple audio croutons from hotkeys
*
*Revision 2.109  1995/08/31  16:16:40  Flick
*Added error panel when Flyer detects a bad A/V head for a clip w/effect
*Also does cleanup if user wishes
*
*Revision 2.108  1995/08/28  16:41:31  Flick
*Reworked Audio Under split builder to support multiple inserts, optional hilite
*of both ends ensures we grab all video between
*
*Revision 2.107  1995/08/28  11:58:49  Flick
*Supports cuts-only under Scrolls/crawls/keys/overlays now! (Flyer stuff only)
*New Audio-Under generator, switcher collision detection error reporting
*
*Revision 2.106  1995/08/23  13:29:32  Flick
*Added CTRL-stop panic hook into Flyer reset as insurance policy for 4.05
*
*Revision 2.105  1995/08/18  17:17:10  Flick
*Oh yeah! Forgot that all tags reads are bypasses ES system now -- Much faster!
*
*Revision 2.104  1995/08/18  17:12:05  Flick
*Fixed sequencing of framestores/main w/FX just before play-from point
*Added support for Flyer sequencing error detection (crippled at this point)
*Added f'n to calc total sequence time (for the running time display)
*Added ability to unlock audio crouton from outside panel (figures rel inpoint)
*Editing2 now puts temporary lock symbol on audio croutons until done
*Play buttons now stop an Editing2 session if stop not already pressed
*Status message stays at top now throughout Editing2 session
*
*Revision 2.103  1995/08/16  10:50:46  Flick
*Smarter queueing of keys so that any start time should work
*No "ready to play" requester from ARexx PlayProject
*
*Revision 2.102  1995/08/09  18:07:14  Flick
*Added support for sequencing non-transitional/overlay effects (+looping)
*Fixed bug in TimeBetweenFGs: multiple scrawls/overlays in one clip -- was wrong
*
*Revision 2.101  1995/08/09  14:13:25  Flick
*Sequencing errors are now highlighted and then navigated into visible area
*Sequencer now supports key options to fade or pop in/out
*Fixed Stills bug in Flyer downloading code (was requesting >4 fields)
*
*Revision 2.100  1995/08/02  15:11:35  Flick
*Handle error when Flyer can't locate a clip (with nice error panel now)
*Added error detection for two video clips locked out of order
*Added busy pointer on Lock/Unlock function (not on "live" version)
*Fixed bug where "Processing..." stayed up after aborting a "fix this" req
*
*Revision 2.99  1995/07/28  16:34:59  Flick
*Fixed play-from on video to play from inpoint (not adjusted point) -- this
*effectively removes any transition on that inpoint.  Also fixed which Flyer
*channel is punched up on a play-from (logic was not quite right).
*
*Revision 2.98  1995/07/20  16:39:35  Flick
*Fixed bug - was not including trailing split audio in total program time
*Would get trimmed off if ran past end of last video in project
*
*Revision 2.97  1995/07/14  10:56:54  Flick
*Now does (optional) auto-fixup after editing to music/video
*
*Revision 2.96  1995/07/13  13:11:10  Flick
*HandleLockDown() now works, even if no CurFG (dropped crtn or select all)
*HandlePlay() aborts unless EditTop is of type EW_PROJECT
*Uses EditTop everywhere, rather than Edit (is sometimes bottom window)
*
*Revision 2.95  1995/07/07  19:25:15  Flick
*Editing foley to video uses TIMEMODE_RELINPT, no longer locks to PROG TIME
*Corrected wording on ready window when ready to edit to video (not music)
*Now navigates hilite +1 when starting editing to an audio/video clip
*
*Revision 2.94  1995/07/06  18:24:49  Flick
*Disabled debugging (oops!)
*
*Revision 2.93  1995/07/06  18:22:38  Flick
*Fixed potential redraw problem with multiple croutons w/ HandleLockDown()
*
*Revision 2.92  1995/07/05  14:59:16  Flick
*Editing to music working better, got editing foley to video working
*
*Revision 2.91  1995/06/28  18:11:52  Flick
*Improved play-from to get actual time of highlighted event (after build)
*Play-from a transition backs up 2 seconds if possible
*Improved error reporting (especially for A/B full and no audio drive)
*Cutting to Music finished and working quite well
*
*Revision 2.90  1995/06/26  17:19:46  Flick
*Overhauled Play-From, builds entire project then trims it down
*
*Revision 2.89  1995/06/20  23:48:24  Flick
*Total overhaul!  Separate Switcher/Flyer/Audio tracks, downloads Flyer & Audio
*tracks to Flyer to run in parallel.  Have lock-down and black insertion,
*double-punch keys, dangling effects, and "prog time" audio all working well.
*
*Revision 2.88  1995/04/28  09:31:18  pfrench
*Added Wait4RMB message so queued play works
*
*Revision 2.87  1995/04/21  14:10:03  Flick
*Fixed play audio bug (audlength), more HandlePlay() cleanup
*
*Revision 2.86  1995/04/21  02:05:34  Flick
*Fixed pre-Q audio alignment bug for "play from crouton".  Improved Flyer head
*error handling.  More improvements to HandlePlay() for ARexx
*
*Revision 2.85  1995/04/20  22:00:44  Flick
*Cleaned up event table allocation, removed 12 field audio minimum
*
*Revision 2.84  1995/04/20  17:49:37  Holt
**** empty log message ***
*
*Revision 2.83  1995/04/19  14:03:40  pfrench
*Fixed enforcer hits in strange create/play/drop/play seq
*
*Revision 2.82  1995/04/18  16:51:50  Flick
*Re-added SHIFT-TAB hotkey, fixed hit when using ARexx PROJ_PLAY
*
*Revision 2.81  1995/03/16  16:02:07  CACHELIN4000
*Support keys, attempt at ChromaFX
*
*Revision 2.80  1995/03/09  18:02:11  CACHELIN4000
*Remove RecFields check on flyerstills
*
*Revision 2.79  1995/02/23  15:20:56  CACHELIN4000
*Reverse logic in test of PART_PLAY button
*
*Revision 2.78  1995/02/19  18:19:06  Kell
*Support for putting up a Key, FlyerStills, ToasterMain, ChromaFX, ARexx, Stop, Delay vs StartTime
*
*Revision 2.77  1995/02/19  01:19:20  Kell
*Changed CT_FLYERSTILL to CT_STILL
*
*Revision 2.76  1995/02/18  23:49:01  Kell
*Support of FlyerStills in sequencing.
*
*Revision 2.75  1995/02/10  20:26:38  Kell
*Now sequencing checks to make sure clips have not been deleted or re-recored since the project was loaded/created.
*
*Revision 2.74  1995/02/09  21:36:50  Kell
*Scrolls now have a Tolerance value on wait4time().
*
*Revision 2.73  1995/02/09  20:44:57  Kell
**** empty log message ***
*
*Revision 2.72  1995/02/09  20:22:28  pfrench
*fixed redraw bug when sequence ends or is aborted.
*
*Revision 2.71  1995/02/09  19:47:00  pfrench
*removed references to flyerstill file type as croutonlib
*doesn't support it anywhere.
*
*Revision 2.70  1995/02/09  18:51:51  Kell
*Now reports errors from sequences that failed during run time.
*
*Revision 2.69  1995/02/09  09:33:19  Kell
*Added various new types of content.  Got Scrawls to sort of work.
*
*Revision 2.68  1995/02/06  14:41:30  pfrench
*Fixed tiny bug in determining play/continue ("=" vs. "==")
*
*Revision 2.67  1995/01/12  12:04:59  CACHELIN4000
*Add support for PLAY_PART button in HAndlePlay()
*
*Revision 2.66  1995/01/06  22:19:48  Kell
*Flyer preroll now 20 fields
*
*Revision 2.65  1995/01/06  22:12:13  Kell
*Don't require addional Flyer preroll if long FX loading is required.
*
*Revision 2.64  1995/01/06  21:23:59  Kell
**** empty log message ***
*
*Revision 2.63  1995/01/06  21:11:02  Kell
*Now hilites correct crouton before sequence errors are reported.
*
*Revision 2.62  1995/01/06  20:44:36  Kell
*Fixed bug involving preload time of 1st video event.
*
*Revision 2.61  1995/01/06  20:33:20  Kell
*Fixed Qing previous audio during sequence from any point.
*New error checking that forces minimum load/Q times for clips/frames/anims/ilbm/algos.
*
*Revision 2.60  1995/01/04  23:28:21  Kell
*Using signed integers for most things now, to avoid sign mistakes on unsigned numbers.
*
*Revision 2.59  1995/01/04  16:34:59  Kell
*Fixed missing Left Audio during seqencing bug.
*Now crops unused audio (beyond sequence end) before making heads.
*
*Revision 2.58  1994/12/31  10:22:09  Kell
**** empty log message ***
*
*Revision 2.57  1994/12/31  10:08:22  Kell
*Re-enabled the 20 field clip check.  Removed their short heads though.
*Now supports MATTE at end of flyerclips at end of Sequence only.
*Now can pre-Q audio that happens before sequence point.
*
*Revision 2.56  1994/12/31  06:35:53  Kell
**** empty log message ***
*
*Revision 2.55  1994/12/30  13:38:37  Kell
*New QuickSort.  Re-anabled heads on cuts only.
*
*Revision 2.54  1994/12/29  19:33:32  CACHELIN4000
*Add Wrapper f'n HandlePlay() for renamed SeqHandlePlay(), FirstFG is CurFG or NULL
*depending hwether full or partial sequence is desired (shift-Play)
*
*Revision 2.53  1994/12/28  18:01:16  Kell
*Now goes to Matte black at sequence start if necessary.
*Doesn't now recalculate SeqeunceVideoStartTime over and over and over.
*
*Revision 2.52  1994/12/27  22:35:38  Kell
*New split audio stuff calculations.  Works better in "Seq. from any point"
*
*Revision 2.51  1994/12/23  07:18:52  Kell
*Now aborts Flyer stuff before making any heads.
*
*Revision 2.50  1994/12/16  20:02:58  pfrench
*Had to rename function with same name as flyer lvo
*
*Revision 2.49  1994/12/06  18:59:53  Kell
*Removed 4 field head for cuts only.  Now video clips must be >= 20 fields long.
*
*Revision 2.48  1994/12/05  22:23:45  Kell
*Fixed Enforcer hit.
*
*Revision 2.47  1994/12/03  06:08:22  Kell
*Now supports Split Audio.  Has more than one event table.
*Also, some Event items are now stored as Tag items.
*
*Revision 2.46  1994/11/18  10:47:31  Kell
*Work on error messages.
*
*Revision 2.45  1994/11/11  14:37:28  pfrench
*Moved refreshedit call to after last fastgadget selection
*
*Revision 2.44  1994/11/10  17:04:20  pfrench
*Made for quicker highlighting of next crouton (proof)
*
*Revision 2.43  1994/11/09  20:11:57  Kell
*New sequence error messages, using the errors.c file.
*
*Revision 2.42  1994/11/09  14:50:09  Kell
**** empty log message ***
*
*Revision 2.41  1994/11/09  14:37:34  Kell
*Most ReportSequenceError messages disabled !!!!!!
*New stand alone audio stuff which uses it's own event table.
*Stuff to sort the audio event table.
*Now has fields in the event table to indicated crouton position.
*
*Revision 2.40  1994/11/04  16:33:18  Kell
*Added initial support for stand alone audio clips when sequencing.
*
*Revision 2.39  1994/11/04  03:08:12  Kell
*Beginnings of CT_AUDIO handling.
*
*Revision 2.38  1994/11/03  15:51:44  Kell
*Error checking on MakeClipHead.
*
*Revision 2.37  1994/11/02  05:37:23  Kell
*Fixed bugs with errors during Sequence analysis or during sequencing or abort showing more than one crouton hilited.  And it now does a select default before and after sequencing.
*
*Revision 2.36  1994/10/26  14:59:40  Kell
**** empty log message ***
*
*Revision 2.35  1994/10/23  16:32:01  CACHELIN4000
*Change line 438 over phone from skell....get rid of FXAdvance
*
*Revision 2.34  94/10/12  18:16:09  Kell
*Now doesn't make video heads unless same volume on both clips.
*
*Revision 2.33  1994/10/05  02:42:20  Kell
*Better Sequencing Debugs
*
*Revision 2.32  1994/09/29  15:39:28  Kell
*First time actually doing true A/B with heads.
*
*Revision 2.31  1994/09/28  18:50:47  Kell
*Some debugs added for sequencing.
*
*Revision 2.30  1994/09/25  16:40:45  Kell
*Changed ES_StopSeq to ES_Stop
*
*Revision 2.29  1994/09/23  19:35:59  Kell
*More work to Sequence generation code.
*
*Revision 2.28  1994/09/23  10:47:49  Kell
*More frame accurate.  Better error reporting.
*
*Revision 2.27  1994/09/22  05:08:12  Kell
*Reworked the Sequencing code that creates the event commands.
*
*Revision 2.26  1994/08/30  10:49:20  Kell
*Changed SendSwitcherReply calls to work with new ESParams structures.
*
*Revision 2.25  1994/08/27  15:56:56  CACHELIN4000
*Add HandleStop function for Project Stop Gadget
*
*Revision 2.24  94/08/26  21:49:10  Kell
*Removed working with some obsolete Flyer tag items
*
*Revision 2.23  1994/06/04  02:28:58  Kell
*Now using FGC_SELECT and FGC_TOMAIN (instead of SELECTQ / AUTO) when sequencing.
*
*Revision 2.22  94/03/29  18:48:30  Kell
*Sequencing fixed for NAB.
*
*Revision 2.21  94/03/20  04:00:41  CACHELIN4000
*Select Error crouton... see ChangeStatusList()
*
*Revision 2.20  94/03/19  13:16:02  Kell
*New sequences the new Control crouton type.
*
*Revision 2.19  94/03/19  09:10:49  Kell
**** empty log message ***
*
*Revision 2.18  94/03/18  18:08:17  Kell
*Now supports lenthening clips for duration of transitions
*
*Revision 2.17  94/03/18  09:26:53  Kell
*Better timing on DHD clips.
*
*Revision 2.16  94/03/18  04:44:47  Kell
*Renamed Flier to Flyer
*
*Revision 2.15  94/03/17  09:49:24  Kell
*Working logic for sequencing Frames and FX.
*
*Revision 2.14  94/03/16  17:36:32  Kell
**** empty log message ***
*
*Revision 2.13  94/03/16  16:56:17  Kell
**** empty log message ***
*
*Revision 2.11  94/03/16  14:19:37  Kell
*New code.  Total rewrite.
*
*Revision 2.10  94/03/16  11:49:55  Kell
**** empty log message ***
*
*Revision 2.9  94/03/16  11:48:19  Kell
**** empty log message ***
*
*Revision 2.7  94/03/16  11:38:44  Kell
**** empty log message ***
*
*Revision 2.6  94/03/15  22:17:40  Kell
**** empty log message ***
*
*Revision 2.5  94/03/13  07:48:56  Kell
**** empty log message ***
*
*Revision 2.4  94/03/11  09:32:28  Kell
**** empty log message ***
*
*Revision 2.3  94/03/05  21:03:53  CACHELIN4000
**** empty log message ***
*
*Revision 2.2  94/02/23  14:52:43  Kell
**** empty log message ***
*
*Revision 2.1  94/02/19  09:34:30  Kell
**** empty log message ***
*
*Revision 2.0  94/02/17  16:24:43  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  15:57:55  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  14:45:01  Kell
*FirstCheckIn
*
*
* Copyright (c)1993 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	12-7-93	Steve H		Created this file
*	12-7-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <edit.h>
#include <editwindow.h>
#include <project.h>
#include <gadgets.h>
#include <editswit.h>
#include <tags.h>
#include <project.h>
#include <crouton_all.h>
#include <seqerrors.h>
#include <flyerlib.h>
#include <flyer.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/diskfont.h>

#ifndef PROTO_PASS
#include <proto.h>
#endif

//#define SERDEBUG	1
#include <serialdebug.h>


/*** External functions ***/
//extern BOOL Wait4LRMB(void);	/* toastsupport.a */
extern BPTR __asm GetBootLock(register __a0 struct ToasterBase *);
extern VOID DisplayWaitSprite(VOID);
extern VOID DisplayNormalSprite(VOID);
extern VOID __asm FlyerChanOnMain(register __d0 UBYTE channel);
extern ULONG __asm TimeFGselect(register __a0 struct ExtFastGadget *);
extern void  __asm ReadySeq(register __a0 struct PlaySeqInfo *);
extern BOOL  __asm PlaySeq(register __a0 struct PlaySeqInfo *);
LONG __asm GetCurProgTime(void);
extern LONG ew_QuickSelect(struct EditWindow *Edit, LONG nodenum);
extern LONG ew_MultiSelect(struct EditWindow *Edit, LONG nodenum);
extern LONG ew_ForceRedraw(struct EditWindow *Edit, LONG nodenum);
extern void	Main2Blank();

#define	TM_TEMP_LOCKED		0x10000000			/* Marker for croutons just edited live */

//*** Definitions ****************************************************

//
// Because I can't do an FX immediately after a Take, and because some FX
// may need a ChangeIS(), or require other setup/load time, and because some
// FX need some cleanup time, I won't allow FX to be butted together.
// And even takes can only occur at 15 times/sec.
// I don't need to check for takes any faster, because we won't support
// video durations of < 4 fields.

#define FXPREROLLFUDGE 	   8	// For AlgoFX, (ANIMs & ILBMs require much more time!)
#define ANIMPREROLLFUDGE  90  // Used for ANIMFX, KeyedANIMs and VideoANIMs
#define ILBMPREROLLFUDGE  45	// Used by ILBMfx, Scrolls, Crawls
#define FRAMEPREROLLFUDGE 90	// Used by FrameStores, ChromaFX & Keyed Stills
#define RGBPREROLLFUDGE   120	// Used by Images
#define VIDEOPREROLLFUDGE 4	// Used for clips & flyerstills
#define CRFXPREROLLFUDGE	240	// Used by Chromafx croutons


#define SCRAWLKEYANIMTOLERANCE	4	//allow for some error on keyed things
#define AREXXTOLERANCE				8	//allow for some error on keyed things
#define CONTROLTOLERANCE			4	
#define CRFXTOLERANCE				32	

//*******************************************************************
// These constants represent the amount of internal delay required
// just to setup certain switcher events.  This is not including
// disk loading and other SELECT delays, but represent the lead time
// required for a TOMAIN, for example, to setup and go
#define	OVERLAY_SETUP		20			// Strange but true, needs 20 fields!
#define	KEY_SETUP			6

//*******************************************************************

#define ROUNDUPTOFRAME(n)		(((n)+3) & ~3)
#define ROUNDDOWNTOFRAME(n)	((n) & ~3)


//----- STRUCTURES FOR AUDIO ENVELOPES -----
// One AudEnv_Key
/* Defined in "switcher/sinc/flyer.h"
struct AEKey {
	ULONG	GoTime;
	ULONG	NumOfFlds;
	UWORD	Flags;
	UWORD VOL1;
	UWORD VOL2;
	WORD PAN1;
	WORD PAN2;
};


struct AudioEnv {
	UWORD	Flags;
	UWORD	 Keysused;
	struct AEKey AEKeys[16];
};
*/


//------------------------
struct Event {
	struct	MinNode	Node;			//
	struct	ExtFastGadget *FG;	//->the crouton, NULL if last Event
	WORD		FGCcommand;				//FGC_SELECT, FGC_QUEUE or FGC_TOMAIN
	WORD	 	CurrentPosition;		//Current Position within sequence
	LONG 		Time;						//On FGC_ToMain, this is the time this FGC
											//should occur, but on FGC_Selects its time
							 				//Qed items should occur.
											//On last Event = total time if last Event
	UWORD		TimeTolerance;			//How late can the event occur and still be OK
	LONG		StartField;				//1st field of Video or Audio (Not used by PlaySeq())
	LONG		Duration;				//Duration in fields
	LONG		AudStart;				//Audio start field
	LONG		AudLength;				//Audio duration in fields
	UBYTE		Flags1;
	UBYTE		Flags2;
	UBYTE		Channel;					//Used for Flyer video effects and takes
	UBYTE		pad;
	UWORD		AudAttack,AudDecay;	//Manual ramp rates
	LONG		extra;					//offset created by aextra,bextra
	struct 	AudioEnv AE;			//AudioEnv for Event.  //struct def in switcher/sinc/flyer.h
};

#define FLAGS1B_WAIT4TIME	0		/* Wait for a program time */
#define FLAGS1B_SETCHAN		1		/* Set preview channel before TAKE/AUTO */
#define FLAGS1B_WAIT4GPI	2		/* Unused */
#define FLAGS1B_LOOP			3		/* ??? */
#define FLAGS1B_DOTAKE		4		/* UNUSED??? */
#define FLAGS1B_LOOPTIME	5		/* Plant a stop time for looping effects */
#define FLAGS2B_MATTE		0		/* System-inserted matte */
#define FLAGS2B_FXIN			1		/* Video will transition in using FX */
#define FLAGS2B_SKIP			2		/* Process but do not play this crouton */
#define FLAGS2B_MISC			7		/* Misc flag for use during processing */

#define FLAGS1F_WAIT4TIME	(1<<FLAGS1B_WAIT4TIME)
#define FLAGS1F_SETCHAN		(1<<FLAGS1B_SETCHAN)
#define FLAGS1F_WAIT4GPI	(1<<FLAGS1B_WAIT4GPI)
#define FLAGS1F_LOOP			(1<<FLAGS1B_LOOP)
#define FLAGS1F_LOOPTIME	(1<<FLAGS1B_LOOPTIME)
#define FLAGS2F_MATTE		(1<<FLAGS2B_MATTE)
#define FLAGS2F_FXIN			(1<<FLAGS2B_FXIN)
#define FLAGS2F_SKIP			(1<<FLAGS2B_SKIP)
#define FLAGS2F_MISC			(1<<FLAGS2B_MISC)


// VideoEvents also include Transitions, Scrawls, SolidANIMs & KeyedANIMs,
// because these are mutually exclusive.  No new video sources are allowed
// while the transition/scrawls/allANIMs are occuring.
// They take over the machine.

// Also we're including non-transitional, don't take over the machine &
// may exist over takes e.g. ChromaFX

// Also we have Keyed frames.
// Cuts to somethings are allowed, though on tall keys it may not be
// possible to load a new still.



//--- Structure for communication to/from assembly sequence player ---------------------
struct PlaySeqInfo
{
//	struct Event *CurVideoEvent;
	struct Event *CurSwitcherEvent;
	ULONG	TimeAtSequenceEnd;

// returned values (you should clear these before the cmd is sent)
	struct ExtFastGadget *AbortedFG;	// Last FG that was processed
	struct Event	*ErrorEvent;		// Event that errored out
	ULONG				ErrorNum;
	STRPTR 			ErrorMsg;			//not usually used

	ULONG				FlyerError;			//Comes from Flyer sequencer
	ULONG				FlyerUserID;		//Passed back from Flyer sequencer
	ULONG				FlyerMoreInfo;		//More info about specific error
	UBYTE				StopOnError;		//Stop sequence on timing error
};


#define	TRACK_SWITCHER		0	// Switcher video, effects, and control
#define	TRACK_FLYVID		1	// Flyer video
#define	TRACK_AUDIO			2	// Flyer audio tracks

struct Track {
	struct List	EventList;
	UWORD	EventCount;
};

//------------------------
// The following are used to index into the CroutonCount structure
// and are used to define types of croutons.
#define CRTN_NONE			0	// marks no previous crouton (start of sequence)
#define CRTN_FLYVID		1  // main video output = CLIP, MAIN, FRAM, VIDA, RGBA, STIL These have video time.
#define CRTN_VIDEO		2  // main video output = CLIP, MAIN, FRAM, VIDA, RGBA, STIL These have video time.
#define CRTN_AUDIO		3  // audio event
#define CRTN_TRANS		4	// transitional effects ANIM/ILBM/ALGO (can only be followed by a video event)
#define CRTN_EFFECT		5  // non-transition effects that don't take over the machine, e.g. ChromaFX
#define CRTN_KEY			6  // overlayed video track for Keyed Frames, don't take over machine
#define CRTN_CRFX			7  // ChromaFX
#define CRTN_SCRAWL		8  // Keyed Things that take over the machine, SCROLL/CRAWL/KEYA
#define CRTN_AREXX		9
#define CRTN_CONTROL		10	// Sequence & Switcher control
#define CRTN_TAKES		11	// Implied takes
#define CRTN_OVERLAY		12	// non-transitional effects/overlays

#define EFFECT_TAKE		0	// marks previous effect as a take
#define EFFECT_TRANS		1	// marks previous effect as a transition

// Used to tabulate the number of various types of croutons in a project
//struct CroutonCount {
//	ULONG	Start;	// ignored for now
//	ULONG	FlyVid;	// main video output = CLIP, STIL - These have video time.
//	ULONG	Video;	// main video output = MAIN, FRAM, VIDA, RGBA - These have video time.
//	ULONG	Audio;	// audio event
//	ULONG	Trans;	// transitional effects ANIM/ILBM/ALGO (can only be followed by a video event)
//	ULONG	Effect;	// non-transition effects that don't take over the machine, e.g. ChromaFX
//	ULONG	Key;		// overlayed video track for Keyed Frames, don't take over machine
//	ULONG	CrFX;		// ChromaFX
//	ULONG	Scrawl;	// Keyed Things that take over the machine, SCROLL/CRAWL/KEYA
//	ULONG	ARexx;	// ARexx
//	ULONG	Control;	// Sequence & Switcher control
//	ULONG	Takes;	// Implied takes between 2 video croutons
//};


//--- Structure for sequencing control ---------------------
struct SeqVars {
//	struct EditWindow *Edit;
	struct EditWindow *EditTop;
	struct Track VideoTrack;			// Flyer video and stills
	struct Track AudioTrack;			// All Flyer audio
	struct Track SwitcherTrack;		// All other croutons
	struct ExtFastGadget	*ScanStart;	// First crouton to analyze for play
	ULONG	AuxError;
	struct ExtFastGadget	*FailFG;		// FG at which something failed (during download)
	LONG	StartTime;						// Program time of start of sequence
	LONG	EndTime;							// Program time of end
	WORD	InsMattes;						// Count of inserted black mattes
//	WORD	TrimToFits;						// Count of video trimmed to fit
	WORD	Pos;								// Crouton position as we process
	WORD	FlyChan;							// Flyer channel to use next (0,1)
	LONG	SeqTotalTime;					// Time of entire project
	LONG	SeqPlayTime;					// Time of portion to play
	BOOL	partial;							// Playing partial sequence
	BOOL	cut2music;						// Editing to music
	BOOL	waitplaystart;					// Put up "ready to play" requester?
	UBYTE	firstflychan;					// First channel coming from Flyer
//	LONG	EndOfEffect;
//	LONG	EndOfPrevEffect;
//	UWORD	PreviousEffect;
	ULONG	SwitcherBusyTil;				// Time to which switcher is taking over machine
	struct	Event	*LastSwitEvent;	// And the event, for more info (i.e. error messages)
	BOOL	CutUnder;						// Flyer doing a cut for Switcher when it's busy
	UWORD	LostCroutons;					// Number of lost croutons in project when built
	char	scratch[80];					// Used to build messages
};



//------------------------
/*** External Structures ***/

extern struct ExtFastGadget **PtrProject;
extern struct Library 	 *ToasterBase;
extern struct Library 	 *FlyerBase;
extern struct FastGadget *CurFG;				// Global - currently selected FG
extern struct FastGadget *SKellFG;			// ???
extern struct EditWindow *EditTop;
extern struct EditPrefs UserPrefs;		// User preferences live here

extern UBYTE *FlyerDrives[];
extern LONG FlyerDriveCount;

extern struct ESParams1 ESparams1;
extern struct ESParams2 ESparams2;
extern struct ESParams3 ESparams3;
extern struct ESParams5 ESparams5;

extern char **ErrMsgs[];
extern char ErrorDetails[];
extern char pstr[];			// Useful temp area for error msgs

extern ULONG	FlyerOpts;


/*** Global Data ***/

static struct ExtFastGadget *SeqStartFG=NULL;	// Start of "active" sequence
//static struct ExtFastGadget *FirstFG=NULL;		// Where to start sequence
BOOL	EditingLive = FALSE;					// Editing other events to a playing clip
BOOL	Editing2Video;							// Live foley or video edits to video clip
LONG	MasterVideoTime;						// Ref time when editing to video
LONG	MusicBaseTime;
LONG	ParentVideoTime;						// TimeBetweenFGs sets this for target child FG


char	E2Mproc_message[] = "Editing to music -- press ESC or STOP to end";
char	E2Vproc_message[] = "Editing to video -- press ESC or STOP to end";

/*** Prototypes ***/

//static LONG __regargs GetSimpleTagS(struct ExtFastGadget *FG, LONG tag);
//static ULONG __regargs GetSimpleTagU(struct ExtFastGadget *FG, LONG tag);
static LONG __regargs GetRefTime(LONG reftime, struct ExtFastGadget *FGlastVid,
	struct ExtFastGadget *FG);
static BOOL __regargs PutVolatileTag(struct ExtFastGadget *FG, LONG tag, LONG value);
static void HiliteNewFG(struct EditWindow *Edit, struct ExtFastGadget *FG, LONG fgpos, BOOL first);
static BOOL ReportSequenceError(struct SeqVars *sv, struct ExtFastGadget *FG,
	LONG fgpos, UWORD error, BOOL ignorable);
static void ReportSequenceDualError(struct SeqVars *sv, struct ExtFastGadget *FG1,
	LONG fgpos1, struct ExtFastGadget *FG2, LONG fgpos2, UWORD error);
static BOOL ReportSeqErrCore(struct SeqVars *sv, UWORD error, BOOL ignorable);
static BOOL SeqRequest(	struct SeqVars *sv, char **msg, int lines);
static BOOL HasAudio(struct ExtFastGadget *FG);
static BOOL IsVideoSource(struct ExtFastGadget *FG);
static BOOL IsSuperVideo(struct ExtFastGadget *fg);
static BOOL IsStop(struct ExtFastGadget *FG);
static BOOL IsWait(struct ExtFastGadget *FG);
static BOOL IsOverlay(struct ExtFastGadget *FG);
static struct ExtFastGadget *GetNextGadget(struct ExtFastGadget *FG);
static LONG TimeBetweenFGs(struct ExtFastGadget *StartFG, struct ExtFastGadget *EndFG);
//static LONG SequenceTotalTime(struct ExtFastGadget *fg);
static struct ExtFastGadget *StartingSequenceEvent(struct ExtFastGadget *hilitedFG);
//static struct ExtFastGadget *StartingVideoEvent(struct ExtFastGadget *firstFG);
static BOOL BuildSeq(struct SeqVars *sv, struct ExtFastGadget *buildFG);
static void PlayCurSeq(struct SeqVars *sv);
static UBYTE TrimToPlayWindow(struct SeqVars *sv, struct ExtFastGadget *firstFG);
static BOOL DoWarnings(struct SeqVars *sv);
static void DeleteEventsForFG(struct SeqVars *sv, struct ExtFastGadget *fg);
static BOOL HandleTransition(struct SeqVars *sv, LONG cuttime, struct Event *V1event,
	struct ExtFastGadget *FXFG, WORD FXpos, struct Event *V2event);
static BOOL MaybeInsertBlack(struct SeqVars *sv, struct Event *V1event, LONG time);
static struct Event *CreateBlack(struct SeqVars *sv, LONG time, WORD flychan);
static UBYTE AppendBlack(struct SeqVars *sv, LONG time, WORD flychan);
static void PrepareTrack(struct Track *track,UBYTE tracktype);
static void FreeTrack(struct Track *track);
#ifdef	SERDEBUG
static void ListTrack(struct Track *track, UBYTE tracktype);
#endif
static struct Event * GetEvent(struct ExtFastGadget *FG);
static void SortIntoTrack(struct Track *track, struct Event *newevent);
static void AppendToTrack(struct Track *track, struct Event *newevent);
static BYTE AppendSelect(struct Track *track, struct Event *newevent);
static void InsertSelect(struct Track *track, struct Event *newevent);
static struct Event * DoAudioCrouton(struct SeqVars *sv,	struct ExtFastGadget *fg, 
	LONG gotime,WORD croutonpos);
static ULONG DownLoadFlyerTrack(struct SeqVars *sv,struct Track *track,UBYTE tracktype,BOOL abortable);
static struct Event *FindFlyerEventFromID(struct SeqVars *sv, ULONG userID);
static UWORD	FXunderErrors(struct	Event	*event);
static BOOL DetectSwitcherCollision(struct SeqVars *sv, LONG time);
static UWORD	SwitCollisionErrors(struct	Event	*event, struct ExtFastGadget *FG2);


extern __asm ULONG GetLongValue(
	register __a0 struct ExtFastGadget *fg,
	register __d0 ULONG tag);


//=============================================================
// GetSimpleTagS
//		Read a tag's value (signed longs)
//=============================================================
//static LONG __regargs GetSimpleTagS(struct ExtFastGadget *FG, LONG tag)
//{
//	ESparams2.Data1=(LONG)FG;
//	ESparams2.Data2=0x80000000 | tag;
//
//	return((LONG)SendSwitcherReply(ES_GetValue,&ESparams2));

//	return((LONG)GetLongValue(FG,tag | 0x80000000));
//}


//=============================================================
// GetSimpleTagU
//		Read a tag's value (ULONG's)
//=============================================================
//static ULONG __regargs GetSimpleTagU(struct ExtFastGadget *FG, LONG tag)
//{
//	ESparams2.Data1=(LONG)FG;
//	ESparams2.Data2=0x80000000 | tag;
//
//	return((ULONG)SendSwitcherReply(ES_GetValue,&ESparams2));

////	return((ULONG)GetLongValue(FG,tag | 0x80000000));
//}

/*** Tag readers that return unsigned values ***/
#define	GetCroutonType(fg)		(GetLongValue(fg,TAG_CroutonType))
#define	GetTimeMode(fg)			(GetLongValue(fg,TAG_TimeMode))
#define	GetAudioOn(fg)				(GetLongValue(fg,TAG_AudioOn))
#define	GetAudioVolume1(fg)		(GetLongValue(fg,TAG_AudioVolume1))
#define	GetAudioVolume2(fg)		(GetLongValue(fg,TAG_AudioVolume2))
#define	GetAudioPan1(fg)			(GetLongValue(fg,TAG_AudioPan1))
#define	GetAudioPan2(fg)			(GetLongValue(fg,TAG_AudioPan2))
#define	GetAsrcLen(fg)				(GetLongValue(fg,TAG_ASourceLen))
#define	GetBsrcLen(fg)				(GetLongValue(fg,TAG_BSourceLen))
#define	GetTakeOffset(fg)			(GetLongValue(fg,TAG_TakeOffset))
#define	GetAudioFadeFlags(fg)	(GetLongValue(fg,TAG_AudioFadeFlags))

/*** Tag readers that return signed values ***/
#define	GetRecFields(fg)			((LONG)GetLongValue(fg,TAG_RecFields))
#define	GetNumFields(fg)			((LONG)GetLongValue(fg,TAG_NumFields))
#define	GetStartField(fg)			((LONG)GetLongValue(fg,TAG_ClipStartField))
#define	GetDuration(fg)			((LONG)GetLongValue(fg,TAG_Duration))
#define	GetDelay(fg)				((LONG)GetLongValue(fg,TAG_Delay))
#define	GetHoldFields(fg)			((LONG)GetLongValue(fg,TAG_HoldFields))
#define	GetAdjVideoStart(fg)		((LONG)GetLongValue(fg,TAG_AdjustedVideoStart))
#define	GetAdjVideoDuration(fg)	((LONG)GetLongValue(fg,TAG_AdjustedVideoDuration))
#define	GetFadeInDuration(fg)	((LONG)GetLongValue(fg,TAG_FadeInDuration))
#define	GetFadeOutDuration(fg)	((LONG)GetLongValue(fg,TAG_FadeOutDuration))
#define	GetFadeInVideo(fg)		((LONG)GetLongValue(fg,TAG_FadeInVideo))
#define	GetAudioStart(fg)			((LONG)GetLongValue(fg,TAG_AudioStart))
#define	GetAudioDuration(fg)		((LONG)GetLongValue(fg,TAG_AudioDuration))
#define	GetAudioAttack(fg)		((LONG)GetLongValue(fg,TAG_AudioAttack))
#define	GetAudioDecay(fg)			((LONG)GetLongValue(fg,TAG_AudioDecay))
#define	GetSpeed(fg)				((LONG)GetLongValue(fg,TAG_Speed))
#define	GetButtonLogic(fg)		((LONG)GetLongValue(fg,TAG_ButtonELHlogic))
#define	GetLoopFlag(fg)			((LONG)GetLongValue(fg,TAG_LoopAnims))


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#define	GetAudioEnv16(ev,fg)				((LONG)GetTable(fg,TAG_AudEnv16,&ev,324))


//=============================================================
//=============================================================
//struct FlyerVolumes * __regargs GetVolumeTable()
//{
//	ESparams1.Data1=0;
//	return((struct FlyerVolumes *)SendSwitcherReply(ES_BuildVolumeTable,&ESparams1));
//}


//=============================================================
// GetRefTime
//		Calculate start time for a relative (non-video) crouton
//=============================================================
static LONG __regargs GetRefTime(	LONG reftime,
												struct ExtFastGadget *FGlastVid,
												struct ExtFastGadget *FG)
{
	LONG delay,time;

	delay = GetDelay(FG);		// Default: ref from inpoint time

	switch (GetTimeMode(FG))
	{
		case TIMEMODE_RELCLIP:			// Reference to prev clip start
			if (FGlastVid)
				time = reftime + delay - GetStartField(FGlastVid);
			else
				time = reftime;			// Isn't a valid time, but at least prevents crash
			break;
		case TIMEMODE_RELINPT:			// Reference to prev clip in-point
			time = reftime + delay;
			//DUMPUDECL("reftime = ",reftime,"");
			//DUMPUDECL("  delay = ",delay,"\\");
			break;
		case TIMEMODE_ABSTIME:			// Reference to none -- absolute time
			time = delay;
			break;
	}
	return(time);
}


//=============================================================
// PutVolatileTag
//		Modify a tag value, and mark it as unsavable
//=============================================================
static BOOL __regargs PutVolatileTag(struct ExtFastGadget *FG, LONG tag, LONG value)
{
	BOOL	result;

	ESparams2.Data1 = ESparams3.Data1 = (LONG)FG;
	ESparams2.Data2 = ESparams3.Data2 = 0x80000000 | tag;
							ESparams3.Data3 = value;

	result = (BOOL)SendSwitcherReply(ES_PutValue,&ESparams3);
	SendSwitcherReply(ES_UnSavable,&ESparams2);
	return(result);
}


//=============================================================
// PutSavableTag
//		Modify a tag value, and mark it as savable
//=============================================================
static BOOL __regargs PutSavableTag(struct ExtFastGadget *FG, LONG tag, LONG value)
{
	BOOL	result;

	ESparams2.Data1 = ESparams3.Data1 = (LONG)FG;
	ESparams2.Data2 = ESparams3.Data2 = 0x80000000 | tag;
							ESparams3.Data3 = value;

	result = (BOOL)SendSwitcherReply(ES_PutValue,&ESparams3);
//	SendSwitcherReply(ES_UnSavable,&ESparams2);
	return(result);
}


#define	PutAdjVideoDuration(fg,val)	(PutVolatileTag(fg,TAG_AdjustedVideoDuration,val))
#define	PutAdjVideoStart(fg,val)		(PutVolatileTag(fg,TAG_AdjustedVideoStart,val))
#define	PutTimeMode(fg,val)				(PutSavableTag(fg,TAG_TimeMode,val))
#define	PutDelay(fg,val)					(PutSavableTag(fg,TAG_Delay,val))
#define	PutStartField(fg,val)			(PutSavableTag(fg,TAG_ClipStartField,val))
#define	PutDuration(fg,val)				(PutSavableTag(fg,TAG_Duration,val))
#define	PutAudioDuration(fg,val)		(PutSavableTag(fg,TAG_AudioDuration,val))
#define	PutAudioStart(fg,val)			(PutSavableTag(fg,TAG_AudioStart,val))
#define	PutAudioAttack(fg,val)			(PutSavableTag(fg,TAG_AudioAttack,val))
#define	PutAudioDecay(fg,val)			(PutSavableTag(fg,TAG_AudioDecay,val))



//=============================================================
// HiliteNewFG
//		Hilites the given FG (and brings it into view)
//		fgpos is negative if crouton number is unknown
//		Can support multiple hiliting
//=============================================================
static void HiliteNewFG(struct EditWindow *Edit,
								struct ExtFastGadget *FG,
								LONG fgpos,
								BOOL first)
{
	if (FG && (fgpos < 0))
		fgpos = GetProjNodeOrder(Edit,(struct FastGadget *)FG);

	if (!first)
	{
		Edit->ew_OptRender = TRUE;
		ew_MultiSelect(Edit,fgpos);			// Hilites crouton
	}
	else
	{
		ew_QuickSelect(Edit,fgpos);			// Hilites crouton

		ew_NavigateNodeNum(Edit,fgpos);		// Navigates to it so it's visible

		SendSwitcherReply(ES_SelectDefault,(SKellFG=NULL));
		CurFG=(struct FastGadget *)FG;

		Edit->ew_OptRender = FALSE;
	}

	UpdateAllDisplay();
}


//=============================================================
// ReportSequenceError
//		Hilite and bring into view specified crouton (or not if FG is NULL)
//		Then put up error requester with given text array
//		Returns TRUE if "ignorable" set and user clicks "OK"
//=============================================================
static BOOL ReportSequenceError(	struct SeqVars *sv,
											struct ExtFastGadget *FG,
											LONG fgpos,
											UWORD error,
											BOOL ignorable)
{
	BOOL	okay;

	// FG may be NULL of we don't want any hilited,
	// and fgpos might = -1 if we want the code to find the crouton
	HiliteNewFG(sv->EditTop,FG,fgpos,TRUE);

	okay = ReportSeqErrCore(sv,error,ignorable);

	return(okay);
}


//=============================================================
// ReportSequenceDualError
//		Hilite and bring into view two croutons
//		Then put up error requester with given text array
//=============================================================
static void ReportSequenceDualError(	struct SeqVars *sv,
													struct ExtFastGadget *FG1,
													LONG fgpos1,
													struct ExtFastGadget *FG2,
													LONG fgpos2,
													UWORD error)
{
	// FG's may be NULL if we don't want any hilited,
	// and fgpos might = -1 if we want the code to find the crouton
	HiliteNewFG(sv->EditTop,FG1,fgpos1,TRUE);		// Hilite 1st one
	HiliteNewFG(sv->EditTop,FG2,fgpos2,FALSE);	// Hilite 2nd one

	ReportSeqErrCore(sv,error,FALSE);
}


static BOOL ReportSeqErrCore(	struct SeqVars *sv,
										UWORD error,
										BOOL ignorable)
{
	BOOL	okay;

	//DUMPUDECL ("~~~~~~~~ ERROR ",error," ~~~~~~~~\\");

	// For "internal" errors, create detailed number info line
	if ((error == SEQERR_Internal) || (error == SEQERR_InternalFlyer))
		sprintf(ErrorDetails,"   Meditation Number %d",sv->AuxError);

	DisplayMessage(NULL);			// Remove any message at top of screen
//	DisplayRunningTime();
	DisplayNormalSprite();			// Remove busy pointer

	if (ignorable)
	{
		// Put up error message (OK, CANCEL)
		okay = ErrorMessageBoolRequest(sv->EditTop->Window,ErrMsgs[error-1]);	// Skip 0
		if (okay)
			DisplayWaitSprite();
	}
	else
	{
		// Put up error message (CONTINUE)
		ErrorMessageRequest(sv->EditTop->Window,ErrMsgs[error-1]);	// Skip 0 which is okay
		okay = FALSE;
	}

	SetRunningTime(-1L);		// Invalidate the total project time (display "???")

	return(okay);
}


//=============================================================
// SeqRequest
//		Put up boolean requester (OK/cancel)
//=============================================================
static BOOL SeqRequest(	struct SeqVars *sv, char **msg, int lines)
{
	BOOL	okay;
	char	*MPtr[7];
	int	i;

	// Make copy of string array, and NULL-terminate it
	for (i=0 ; i<lines ; i++)
	{
		MPtr[i] = *msg++;
	}
	MPtr[i] = NULL;

//	DisplayMessage(NULL);			// Remove any message at top of screen
//	DisplayRunningTime();
	DisplayNormalSprite();			// Remove busy pointer

	// Put up requester, check okay/cancel
//	okay = (BOOL)SimpleRequest(sv->EditTop->Window,msg,lines,REQ_OK_CANCEL | /* REQ_CENTER | */ REQ_H_CENTER,NULL);
	okay = ErrorMessageBoolRequest(sv->EditTop->Window,MPtr);
	if (okay)
		DisplayWaitSprite();

//	SetRunningTime(-1L);

	return(okay);
}



//=============================================================
// HasAudio
//		Returns TRUE if either audio channel of clip is
//		enabled and has a non-zero volume
//=============================================================
static BOOL HasAudio(struct ExtFastGadget *FG)
{
	ULONG	AudioOnBits;

	AudioOnBits = GetAudioOn(FG);

	//DUMPMSG("---------------------------");
	//DUMPSTR(FG->FileName);
	//DUMPMSG(" ");
	//DUMPHEXIL("AudioOnBits=",(LONG)AudioOnBits,"\\");
//	DUMPHEXIL("AUDF_Channel1Recorded=",(LONG)(AUDF_Channel1Recorded & AudioOnBits),"\\");
//	DUMPHEXIL("AUDF_Channel2Recorded=",(LONG)(AUDF_Channel2Recorded & AudioOnBits),"\\");
//	DUMPHEXIL("AUDF_Channel1Enabled=",(LONG)(AUDF_Channel1Enabled & AudioOnBits),"\\");
//	DUMPHEXIL("AUDF_Channel2Enabled=",(LONG)(AUDF_Channel2Enabled & AudioOnBits),"\\");
	//DUMPUDECL("Volume1=",(LONG)GetAudioVolume1(FG),"\\");
	//DUMPUDECL("Volume2=",(LONG)GetAudioVolume2(FG),"\\");
	//DUMPMSG("---------------------------");

	return((BOOL)
	(
		(
			(AUDF_Channel1Recorded & AudioOnBits) && (AUDF_Channel1Enabled & AudioOnBits) 
			&& GetAudioVolume1(FG)
		)
	|| (
			(AUDF_Channel2Recorded & AudioOnBits) && (AUDF_Channel2Enabled & AudioOnBits)
			&& GetAudioVolume2(FG)
		)
	));
}


//=============================================================
// IsVideoSource
//		Returns TRUE if the FG type is a video source crouton
//=============================================================
static BOOL IsVideoSource(struct ExtFastGadget *FG)
{
	ULONG objtype;

	objtype = FG->ObjectType;

	switch (objtype)
	{
		case CT_VIDEO:
		case CT_FRAMESTORE:
		case CT_IMAGE:
		case CT_VIDEOANIM:
		case CT_MAIN:
		case CT_STILL:
			return(TRUE);
		default:
			return(FALSE);
	}
}


//=============================================================
// IsSuperVideo
//		Returns TRUE if the FG type is a scroll/crawl/key/overlay
//=============================================================
static BOOL IsSuperVideo(struct ExtFastGadget *fg)
{
	ULONG objtype;
	BOOL	flag;

	if (fg)
		objtype = fg->ObjectType;
	else
		fg = 0;

	switch (objtype)
	{
		case CT_FXANIM:
		case CT_FXALGO:
		case CT_FXILBM:
			if (IsOverlay(fg))
				flag = TRUE;
			else
				flag = FALSE;
			break;
		case CT_SCROLL:
		case CT_CRAWL:
		case CT_KEY:
			flag = TRUE;
			break;
		default:
			flag = FALSE;
	}

	return(flag);
}


//=============================================================
// IsStop
//		Is this FG a stop/restart control crouton?
//=============================================================
static BOOL IsStop(struct ExtFastGadget *FG)
{
	ULONG	type;

	if (FG->ObjectType == CT_CONTROL)
	{
		type = GetCroutonType(FG);

		if ((type==CROUTONTYPE_STOP) || (type==CROUTONTYPE_RESTART))
			return(TRUE);
	}

	return(FALSE);
}


//=============================================================
// IsWait
//		Is this FG a wait control crouton?
//=============================================================
static BOOL IsWait(struct ExtFastGadget *FG)
{
	ULONG	type;

	if (FG->ObjectType == CT_CONTROL)
	{
		type = GetCroutonType(FG);

		if ((type==CROUTONTYPE_WAIT4GPI) || (type==CROUTONTYPE_WAIT4ANYKEY))
			return(TRUE);
	}

	return(FALSE);
}



//=============================================================
// IsOverlay
//		Is this FG a non-transitional effect/overlay?
//=============================================================
static BOOL IsOverlay(struct ExtFastGadget *FG)
{
	LONG	type,blogic;

	type = FG->ObjectType;

	if ((type == CT_FXILBM)
	||  (type == CT_FXANIM)
	||  (type == CT_FXALGO))		// Include this???
	{
		blogic = GetButtonLogic(FG);					// Get effects button logic

		if ((blogic == AFXT_Logic_EncoderAlpha)	// Graphic overlay
		||  (blogic == AFXT_Logic_TDEfx)				// Non-transitional effects
		||  (GetLoopFlag(FG)))							// Looping ILBM/ANIM
		{
			return(TRUE);									// ...all are considered overlays
		}
	}

	return(FALSE);
}


//=============================================================
// GetNextGadget
//		Get next FG in project, given the current FG
//=============================================================
static struct ExtFastGadget *GetNextGadget(struct ExtFastGadget *FG)
{
	struct ExtFastGadget *nextfg;

	nextfg = (struct ExtFastGadget *)FG->FG.NextGadget;

	if (nextfg)
	{
		if (IsStop(nextfg))			// If we hit a stop/restart, return NULL
			nextfg = NULL;

	}

	return(nextfg);
}

//=============================================================
// GetPrevGadget
//		Get previous FG in project, given the current FG
//=============================================================
struct ExtFastGadget *GetPrevGadget(struct ExtFastGadget *FG)
{
	struct ExtFastGadget *pfg,*nextfg;

	if (FG && PtrProject)
	{
		for (pfg= *PtrProject; pfg; pfg=nextfg)
		{
			nextfg = (struct ExtFastGadget *)pfg->FG.NextGadget;
			if (nextfg == FG)
				return(pfg);
		}
	}

	return(NULL);
}


//=============================================================
// TimeBetweenFGs
//		Find the total video between two FG's (from StartFG up to EndFG)
//		If EndFG=NULL, then it returns the total duration from StartFG to end
//=============================================================
static LONG TimeBetweenFGs(	struct ExtFastGadget *StartFG,
										struct ExtFastGadget *EndFG)
{
	struct ExtFastGadget *fg, *PrevVidFG;
	ULONG	timemode,objtype;
	LONG	vidtime,lastvidtime,abstime,maxtime,duration,maxend,start;

	PrevVidFG = NULL;

	lastvidtime = vidtime = maxtime = 0;

	for (fg=StartFG ; fg ; fg = GetNextGadget(fg))
	{
		timemode = GetTimeMode(fg);

		objtype = fg->ObjectType;
		//DUMPHEXIL("---------- Type ",objtype," ---------\\");

		if (objtype == CT_ERROR)
		{
			objtype = fg->LocalData;		// Pick out ACTUAL type from "lost crouton"
			//DUMPHEXIL("*** Actual type is ",objtype," ***\\");
		}

		//DUMPUDECL("   TimeMode ",timemode,"\\");

		/*** Get this crouton's correct start time ***/
		switch (objtype)
		{
			case CT_VIDEO:
			case CT_FRAMESTORE:
			case CT_STILL:
				// Is this crouton locked to a particular program time?
				if (timemode==TIMEMODE_ABSTIME)
				{
					abstime = GetDelay(fg);
// Always return locked time, even if previous guy is too long
//					if (abstime > vidtime)			// Skip time forward to locked crouton?
						vidtime = abstime;
				}
			case CT_MAIN:
			case CT_IMAGE:
			case CT_VIDEOANIM:
				start = vidtime;
				PrevVidFG = fg;
				break;

			case CT_AUDIO:
			case CT_FXCR:
			case CT_REXX:
			case CT_SCROLL:
			case CT_CRAWL:
			case CT_KEYEDANIM:
			case CT_KEY:
				start = GetRefTime(lastvidtime,PrevVidFG,fg);
				break;

			case CT_FXILBM:
			case CT_FXANIM:
			case CT_FXALGO:
				if (IsOverlay(fg))
					start = GetRefTime(lastvidtime,PrevVidFG,fg);
				else
				{
					LONG	takefld,fxlen,Alen,Blen;

//OLD WAY:	start = vidtime - GetNumFields(fg)/2;	// Improve when asym. FX supported!!!

					fxlen = GetNumFields(fg);					// Length of effect
					Alen = ((GetAsrcLen(fg) >>16) * fxlen + 0x8000) >>16;
					Blen = ((GetBsrcLen(fg) >>16) * fxlen + 0x8000) >>16;

					if ((Alen + Blen) >= fxlen)			// Sources overlap?
					{
						// Calculate offset into FX where take will be placed
						takefld = ((GetTakeOffset(fg) >>16) * fxlen + 0x8000) >>16;
					}
					else
						takefld = Alen;					// Time into FX at which A source will end

					start = vidtime - takefld;			// Calc time before end of previous clip
				}
				break;

			case CT_CONTROL:
				start = vidtime;
				//DUMPMSG	("***************** CONTROL *****************\n");
				break;

			default:
				start = 0;		//!!!
		}

		// Break here if on terminating crouton
		if (fg == EndFG)
		{
			// Keep this in case we want to relate the "target" crouton to its parent's time
			ParentVideoTime = lastvidtime;

			//DUMPUDECL("*** Final Time ",start,"\\");
			return(start);			// Start time of FG
		}

//		lastvidtime = vidtime;

		switch (objtype)
		{
			case CT_VIDEO:
			case CT_FRAMESTORE:
			case CT_STILL:
			case CT_MAIN:
			case CT_IMAGE:
				duration = GetDuration(fg);
				lastvidtime = vidtime;
				vidtime += duration;

				// Take back split audio into account for max running time
				if (HasAudio(fg))
				{
					maxend = start+GetAudioStart(fg)-GetStartField(fg)+GetAudioDuration(fg);
					if (maxend > maxtime)
						maxtime = maxend;
				}
				break;

			case CT_VIDEOANIM:
				duration = GetNumFields(fg);
				lastvidtime = vidtime;
				vidtime += duration;
				break;

			case CT_AUDIO:
				duration = GetAudioDuration(fg);
				break;

			case CT_FXCR:
				duration = GetDuration(fg);
				break;

			case CT_REXX:
				duration = 0;			// ???
				break;

			case CT_SCROLL:
			case CT_CRAWL:
			case CT_KEYEDANIM:
				duration = 0;			// Where is the length??
				break;

			case CT_KEY:
				duration = GetDuration(fg);
				break;

			case CT_FXILBM:
			case CT_FXANIM:
			case CT_FXALGO:
				if (IsOverlay(fg))
					duration = GetNumFields(fg);		// Or GetDuration(fg) ???
				else
				{
					LONG	fxlen,Alen,Blen;

					fxlen = GetNumFields(fg);				// Length of effect
					Alen = ((GetAsrcLen(fg) >>16) * fxlen + 0x8000) >>16;
					Blen = ((GetBsrcLen(fg) >>16) * fxlen + 0x8000) >>16;

					if ((Alen + Blen) >= fxlen)			// Sources overlap?
						duration = 0;							// Does not insert any video time
					else
						duration = fxlen-Alen-Blen;		// Inserts this much video time (from FX)

					vidtime += duration;						// CAN add video time!
				}
				break;
			
			case CT_CONTROL:
				duration = 0;
				//DUMPMSG	("-----------------  Control -----------------\n");
				break;

			default:
				duration = 0;
				break;
		}

		// Record latest event as total program time
		maxend = start+duration;
		if (maxend > maxtime)
			maxtime = maxend;

		//DUMPUDECL("   Start ",start,"   ");
		//DUMPUDECL("   Duration ",duration,"\\");
		//DUMPUDECL("   VidTime ",vidtime,"   ");
		//DUMPUDECL("   MaxTime ",maxtime,"\\");
	}

	// Falls to here if EndFG is NULL
	//DUMPUDECL("*** Final MaxTime ",maxtime,"\\");
	return(maxtime);		// Total program time
}


//=============================================================
// FindCroutonStartTime
//		Look thru the currently built project and attempt to
//		determine the exact start time of the given crouton
//=============================================================
static LONG FindCroutonStartTime(struct SeqVars *sv, struct ExtFastGadget *fg)
{
	struct Track	*track;
	struct Event	*event;
	ULONG objtype;
	LONG	time,adj;
	int	trktype;

	objtype = fg->ObjectType;

	adj = 0;

	switch (objtype)
	{
		case CT_AUDIO:
			track = &sv->AudioTrack;
			trktype = TRACK_AUDIO;
			break;

		case CT_VIDEO:
			adj = GetStartField(fg) - GetAdjVideoStart(fg);		// Makes a + adj


		case CT_STILL:
			track = &sv->VideoTrack;
			trktype = TRACK_FLYVID;

			break;

		case CT_FXANIM:
		case CT_FXILBM:
		case CT_FXALGO:
			if (IsOverlay(fg))
				adj = 0;					// Overlay effects (non-transitional)
			else							
				adj = -2*60;			// Extra 2 seconds before transition

		default:
			track = &sv->SwitcherTrack;
			trktype = TRACK_SWITCHER;
			break;
	}

	//DUMPUDECL ("Looking thru track ",trktype," for FG start time\\");

	time = 0;

	// Walk track list and look for this crouton
	for (event = (struct Event *)track->EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		if (event->FG == fg)
		{
			// Flyer audio/video tracks just have 1 select for each event, at the proper time
			if (trktype != TRACK_SWITCHER)
			{
				time = event->Time;
				break;
			}

			// For switcher events, collect up any of these, return last one
			if ((event->FGCcommand == FGC_SELECT) || (event->FGCcommand == FGC_TOMAIN))
				time = event->Time;
		}
	}

	//DUMPUDECL ("cliptime = ",time,"\\");
	//DUMPSDECL ("adj = ",adj,"\\");

	// Try to start early when requested
	if ((time + adj) >= 0)
		time += adj;
	else
		time = 0;

	//DUMPUDECL ("cliptime = ",time,"\\");

	return(time);
}

 
//=============================================================
// GetStartTimeInSequence()
//		Video Duration from start of sequence to current crouton.
//		This is used to calculate the time to put in the panel's CurrentTime indicator
//=============================================================
LONG GetStartTimeInSequence(struct FastGadget *FG)
{
//	struct ExtFastGadget	*first;

//	if (first=SeqStartFG)	//GLOBAL
	if (PtrProject && (*PtrProject))
		return(TimeBetweenFGs(*PtrProject, (struct ExtFastGadget *)FG));
	else
		return(NULL);
}

//=============================================================
// GetTotalSequenceTime()
//		Calculate duration of entire project
//		This is used to calculate the running time indicator
//=============================================================
LONG GetTotalSequenceTime(void)
{
	if (PtrProject && (*PtrProject))
		return(TimeBetweenFGs(*PtrProject, NULL));
	else
		return(NULL);
}


//=============================================================
// SequenceTotalTime
//		Duration from current crouton upto end of Sequence.
//		This is used to calculate the time to put in the ProgramTime indicator.
//=============================================================
//static LONG SequenceTotalTime(struct ExtFastGadget *fg)
//{
//	LONG	time;
//
//	time = TimeBetweenFGs(SeqStartFG,NULL) - TimeBetweenFGs(SeqStartFG,fg);
//
//	return(time);
//}


//=============================================================
// StartingSequenceEvent
//		Finds 1st previous event after any STOPs/LOOPs
//=============================================================
static struct ExtFastGadget *StartingSequenceEvent(struct ExtFastGadget *hilitedFG)
{
	struct ExtFastGadget *startFG, *fg, *initialFG=NULL;

	// Start from previous video event (if not currently on one)
	if (PtrProject && (initialFG = *PtrProject))
	{
		if (hilitedFG)
			startFG = hilitedFG;
		else
			startFG = initialFG;

		// Scan from start of project up to (but not including) start crouton
		for (fg=initialFG ; (fg && (fg!=startFG)) ; fg=(struct ExtFastGadget *)(fg->FG.NextGadget))
		{
			if (!initialFG)		// Keep 1st FG we find
				initialFG=fg;

			if (IsStop(fg))		// If we hit stop/reset, look for new 1st FG
				initialFG=NULL;
		}
	}
	return(initialFG);
}


//=============================================================
// StartingVideoEvent
//		Finds the most recent video event at or before the start crouton
//=============================================================
//static struct ExtFastGadget *StartingVideoEvent(struct ExtFastGadget *firstFG)
//{
//	struct ExtFastGadget *StartFG, *FG, *VidFG=NULL;
//
///*** Start from previous video event (if not currently on one) ***/
//	if (SeqStartFG)	//GLOBAL
//	{
//		if (firstFG)
//			StartFG=(struct ExtFastGadget *)firstFG;
//		else
//			StartFG = SeqStartFG;
//
//		FG = SeqStartFG;
//		while (FG && (FG!=StartFG))
//		{
//			if (IsVideoSource(FG))			// Remember 1st video FG
//				VidFG = FG;
//			else if (IsStop(FG))				// If stop/reset, look again for 1st FG
//				VidFG=NULL;
//
//			FG = (struct ExtFastGadget *)(FG->FG.NextGadget);
//		}
//
//		if (IsVideoSource(FG))
//			VidFG = FG;
//
//		return(VidFG);
//		return(StartFG);
//	}
//	return(NULL);
//}


//=============================================================
// BuildSeq
//		Analyze project and turn into a playable sequence
//		Does error checking as well
//=============================================================
static BOOL BuildSeq(	struct SeqVars *sv,
								struct ExtFastGadget *buildFG)
{
	struct Event *event;

	struct ExtFastGadget *FG, *PrevVidFG, *EffectFG;
	struct Event *PrevVidEvent=NULL, *CurVidEvent;	//*KeyKill
	LONG ProgTime, gotime, reftime,seltime,refdur;
	LONG EndOfVideo, fudge;
//	LONG vstartfld, audlength, astartfld;
	UWORD error, PreviousTrack=CRTN_NONE;
	WORD EffectPos;
//	BOOL	flag;
//	BOOL	takeneeded;
//	char *MPtr[3];
	BYTE	setchan;
	ULONG objtype,FGtype;

//	SetRunningTime(-1L);		// assume unable to calculate program time

	error = 0;			// No error yet
	sv->Pos = 0;
	sv->LostCroutons = 0;		// None found yet

	/*** If no sequence, just quit ***/
	if (!buildFG)
		return(FALSE);


//	/*** Locate the most recent video event at or before start crouton ***/
//	if (!(FG=StartingVideoEvent(buildFG)))
//	{
//		// Can't sequence, no previous video events
//		error = SEQERR_NeedsPrevVideo;
//		FG = (struct ExtFastGadget *)CurFG;
//		sv->Pos = -1;									// Find it for me
//		goto Failed;
//	}

	//DUMPMSG	("-------------- DoSeqPlay ----------------");

	DisplayMessage("Processing Sequence");
	DisplayWaitSprite();

//	// Do a take right at the beginning
//	if ((event = GetEvent(FG))==NULL)
//	{
//		error = SEQERR_OutOfMemory;
//		goto Failed;
//	}
//	event->FG = buildFG;
//	event->CurrentPosition = 0;
//	event->FGCcommand = FGC_TOMAIN;
//	event->Time = 0;
//	AppendToTrack(&sv->SwitcherTrack,event);		// Tack on end of track

	sv->FlyChan = 0;


//****************************************************************
//********* Q events that occured at or after Sequence point
//****************************************************************

	ProgTime = 0;
	PrevVidFG = NULL;

	// Signify that we'll need a take to start sequence, unless we get an effect
	EffectFG = NULL;
	EffectPos = -1;
//	takeneeded = TRUE;

	sv->LastSwitEvent = 0;			// No switcher events yet for collision checks

	for (FG=buildFG ; FG ; FG=GetNextGadget(FG))
	{
		//DUMPMSG("--------------------------------------");
		//DUMPUDECL("Crouton #",sv->Pos," = ");

		fudge = 0;					// None yet
		sv->CutUnder = FALSE;	// Unless special things happen, we won't be doing this

		FGtype = FG->ObjectType;
//Had tried substituting correct type in for processing, but works better skipping
//during processing too
//		if (FGtype == CT_ERROR)					// Sequencing with "lost crouton"s still present
//		{
//			FGtype = ((struct ExtFastGadget *)FG)->LocalData;	// Pick out REAL type
//			sv->LostCroutons++;					// Count these
//			//DUMPHEXIL("*** Actual type is ",FGtype," ***\\");
//		}

		switch(FGtype)
		{

// **
		case CT_FXCR:
			//DUMPMSG("ChromaFX CROUTON");

			//DUMPUDECL("**CRFX Durr: ",GetDuration(FG)," \\");

			// Funny, this only does a select, no TOMAIN, and it -of course- doesn't
			// have any remove
			//	DEH070596>This isn't funny at all it's just broken! 


			if (PreviousTrack==CRTN_NONE)
			{
				error = SEQERR_CrFXAtStart;	// Can't start with ChromaFX
				break;
			}

			if (PreviousTrack==CRTN_TRANS)
			{
				error = SEQERR_CrFXAfterEffect;	// ChromaFX can't follow Effects croutons
				break;
			}

			if (PrevVidEvent)
			{	
				reftime = PrevVidEvent->Time;
				refdur = PrevVidEvent->Duration;
			}
			else
			{
				reftime = 0;		// Meaningless, but at least consistent
				refdur = 0;

				if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
				{
					error = SEQERR_CrtnNeedsVideo;	// Needs video to ref to
					break;
				}
			}

			if(GetTimeMode(FG)==TIMEMODE_ABSTIME)
			{
				gotime = reftime;
			}
			else
			{	
				// Calculate when ChromaFX should start
				gotime = GetRefTime(reftime,PrevVidFG,FG);
				//DUMPUDECL("**CRFX: at ",gotime," \\");
			}

			if (DetectSwitcherCollision(sv,gotime))
			{
				error = SwitCollisionErrors(sv->LastSwitEvent,FG);
				break;
			}


			// Get event for SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}

			seltime = gotime - CRFXPREROLLFUDGE;		//this is realy just a test.
			
			if (seltime<0) seltime = 0;	//ho no!, it's really close to the start.

			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_SELECTQ;
			event->Time = seltime; 						
			if((seltime == 0)|(gotime == PrevVidEvent->Time))											//need to add more cond.			
			{	
				if(gotime != PrevVidEvent->Time)
				{
					event->FGCcommand = FGC_SELECT;
					InsertSelect(&sv->SwitcherTrack,event);

					if ((event = GetEvent(FG))==NULL)
					{
						error = SEQERR_OutOfMemory;
						break;
					}
					event->FG = FG;
					event->CurrentPosition = sv->Pos;
					event->FGCcommand = FGC_TOMAIN;
					event->Time = gotime; 						
					AppendToTrack(&sv->SwitcherTrack,event);			// Tack on end of track
				}
				else
				{
					event->FGCcommand = FGC_TOPRVW;
					InsertSelect(&sv->SwitcherTrack,event);
				}
			}
			else
			{
				event->FGCcommand = FGC_SELECT;
				AppendToTrack(&sv->SwitcherTrack,event);			// we'er loading 			
				// Get event for TOMAIN									// after the clip started
				if ((event = GetEvent(FG))==NULL)
				{
					error = SEQERR_OutOfMemory;
					break;
				}
				event->FG = FG;
				event->CurrentPosition = sv->Pos;
				event->FGCcommand = FGC_TOMAIN;
				event->Time = gotime; 									// when to come to main.
				event->TimeTolerance = CRFXTOLERANCE;				// allow for some error !!!
				AppendToTrack(&sv->SwitcherTrack,event);			// Tack on end of track
			}



			// Get event for REMOVEQ
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
//			event->FG = PrevVidEvent->FG;
//			event->CurrentPosition=PrevVidEvent->CurrentPosition;
////		event->FG = FG;
////		event->CurrentPosition=sv->Pos;
//			event->FGCcommand = FGC_TAKE;
//			event->Time = GetRefTime(reftime,PrevVidFG,FG);
//			//DUMPUDECL("**CRFX Take: at ",event->Time," \\");

			// Remove Key Event, this MUST have its time adjusted if another event
			// happens before it is due to end... AC
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_REMOVEQ;
			// Set default duration, though should be shortened if another event steps on it

			if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)			
				event->Time = GetRefTime(reftime,PrevVidFG,FG) + GetDuration(FG);
			else
				event->Time = refdur+gotime;
				
			event->TimeTolerance = CRFXTOLERANCE;				// allow for some error !!!

			//DUMPUDECL("**CRFX Durr: ",GetDuration(FG)," \\");

			event->extra = 0;		//no extra time yet	
			
			AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

			//DUMPUDECL("**CRFX Remove: at ",event->Time," \\");
//			KeyKill = event;	OBSOLETE

//			Keep these to detect switcher event overlaps (CRFX)
			sv->SwitcherBusyTil = event->Time;		// Time of REMOVE
			sv->LastSwitEvent = event;

//			PreviousFG = FG;
//			PreviousPos = sv->Pos;
			PreviousTrack = CRTN_KEY;
			break;

// **

//----------------------------------------------------------------------
		case CT_REXX:
			//DUMPMSG("ARexx CROUTON");

			if (PreviousTrack==CRTN_NONE)
			{
				error = SEQERR_ARexxAtStart;		// Can't start with Arexx
				break;
			}

			if (PreviousTrack==CRTN_TRANS)
			{
				error = SEQERR_ARexxAfterEffect;	// Arexx cannot follow Effects croutons
				break;
			}

			if (PrevVidEvent)
				reftime = PrevVidEvent->Time;
			else
			{
				reftime = 0;		// Meaningless, but at least consistent

				if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
				{
					error = SEQERR_CrtnNeedsVideo;	// Needs video to ref to
					break;
				}
			}

			// Get event for SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_SELECT;
			// ARexx will start at this time
			event->Time = GetRefTime(reftime,PrevVidFG,FG);
			event->TimeTolerance = AREXXTOLERANCE;		// Allow for some error !!!
			AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

//			PreviousFG = FG;
//			PreviousPos = sv->Pos;
			PreviousTrack = CRTN_AREXX;
			break;

//----------------------------------------------------------------------
		case CT_AUDIO:
			//DUMPMSG("AUDIO CROUTON");

			if (HasAudio(FG))		// Audio Volume might be zero
			{
				if (!FlyerBase)
				{
					error = SEQERR_AudioNeedsFlyer;	// Can't play audio without a Flyer
					break;
				}

//				if (PreviousTrack==CRTN_NONE)
//				{
//					error = SEQERR_AudioAtStart;		// Can't start with audio clip
//					break;
//				}

//				if (PreviousTrack==CRTN_TRANS)
//				{
//					error = SEQERR_AudioAfterEffect;	// Audio Clips cannot follow Effects
//					break;
//				}

				if (PrevVidEvent)
				{
					//DUMPMSG("ADD IN EXTRA");
					reftime = PrevVidEvent->Time+PrevVidEvent->extra;	//newDEH030196
//					reftime = PrevVidTime;
				}
				else
				{
					reftime = 0;		// Meaningless, but at least consistent

					if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
					{
						error = SEQERR_AudioNeedsVideo;	// Needs video to ref to
						break;
					}
				}

				// Calculate when the audio should start

				gotime = GetRefTime(reftime,PrevVidFG,FG);

				//DUMPUDECL("AudioStart = ",gotime,"\\");

				// Add to audio track
				event = DoAudioCrouton(
					sv,
					FG,				// FastGadget
					gotime,			// Desired start time
					sv->Pos				// Crouton position
				);

				if (event)
				{
					// Keep user's audio ramp rates
					event->AudAttack = GetAudioAttack(FG);
					event->AudDecay = GetAudioDecay(FG);
					if(GetAudioOn(FG)&AUDF_AudEnvEnabled)
						GetAudioEnv16(event->AE,FG);	//DEH Maybe put keep for AudEnv Here!
				}

//				if (event)
//				{
//					if (event->Time < PreviousEndOfEffect)
//					{
//						//Please put this clip after an earlier video event
///*?*/				error = SEQERR_AudioUnsorted;
//						break;
//					}

//***!! This check isn't really important unless we want to keep the croutons in order!
//					if (event->Time < PreviousAudioStartTime)
//					{
//						//Audio crouton should be moved earlier in the project
///*?*/				error = SEQERR_AudioUnsorted;
//						break;
//					}

//					PreviousAudioStartTime = event->Time;	// NOT CURRENTLY USED!
//				}

//				PreviousFG = FG;
//				PreviousPos = sv->Pos;
				PreviousTrack = CRTN_AUDIO;
			}

			break;

//----------------------------------------------------------------------
		case CT_SCROLL:
		case CT_CRAWL:
		case CT_KEYEDANIM:
			//DUMPMSG("SCROLL/CRAWL CROUTON");

			if (PreviousTrack==CRTN_NONE)
			{
				error = SEQERR_KeyAtStart;		// Can't start with a CG page
				break;
			}

			if (PreviousTrack==CRTN_TRANS)
			{
				error = SEQERR_KeyAfterEffect;	// CG pages cannot follow Effects croutons
				break;
			}

			if (PrevVidEvent)
				reftime = PrevVidEvent->Time;
			else
			{
				reftime = 0;		// Meaningless, but at least consistent

				if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
				{
					error = SEQERR_CrtnNeedsVideo;	// Needs video to ref to
					break;
				}
			}

			// Find desired scroll/crawl/keyanim start time
			gotime = GetRefTime(reftime,PrevVidFG,FG);

			//DUMPUDECL("RefTime = ",reftime," ");
			//DUMPUDECL("GoTime = ",gotime," \\");

			if (DetectSwitcherCollision(sv,gotime))
			{
				error = SwitCollisionErrors(sv->LastSwitEvent,FG);
				break;
			}

			// Get event for SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_SELECT;
			event->Time = 0;								//as soon as possible

//			// Wants a double-punch (take and scrawl at same time)?
//			// THIS DOESN'T WORK YET, AS FX CODE ONLY DOES A "TAKE" FOR FGC_TAKE,
//			// IT DOES NOT CHANGE SOURCES AND PUT UP THE EFFECT.  COULD WE ADD A
//			// NEW FGC THAT WOULD DO THIS (CAN'T BREAK THE WAY 'TAKE' WORKS)
//			if (gotime == reftime)
//			{
//				setchan = AppendSelect(&sv->SwitcherTrack,event);	// Replace TOMAIN w/scrawl TAKE
//				// If fails (due to ineligibility to replace a TAKE, maybe allow 2nd
//				// strategy below (insert SELECT) a chance???
//			}
//			else
			if (gotime < (reftime+ILBMPREROLLFUDGE))					// Not enough pre-load?
			{
				InsertSelect(&sv->SwitcherTrack,event);				// Do before TOMAIN
				setchan = -1;													// Not a double-punch
			}
			else
			{
				AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track
				setchan = -1;
			}

			// Get event for TAKE/TOMAIN
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->Duration = GetDuration(FG);			// Just used internally (not switcher)
			//DUMPUDECL("Scroll/Crawl duration = ",event->Duration," ");

			if (setchan >= 0)
			{
				event->Channel = setchan;
				event->Flags1 |= FLAGS1F_SETCHAN;
			}

			if (setchan >= 0)
				event->FGCcommand = FGC_TAKE;
			else
				event->FGCcommand = FGC_TOMAIN;

			event->TimeTolerance = SCRAWLKEYANIMTOLERANCE;		//allow for some error !!!
			// 1st field of scroll/crawl/key will start at this time
			event->Time = gotime;
			AppendToTrack(&sv->SwitcherTrack,event);			// Tack on end of track

//			Keep these to detect switcher event overlaps (Scrolls/crawls)
			sv->SwitcherBusyTil = event->Time + event->Duration + GetHoldFields(FG);
			sv->LastSwitEvent = event;

//			PreviousFG = FG;
//			PreviousPos=sv->Pos;
			PreviousTrack=CRTN_SCRAWL;

			break;

//----------------------------------------------------------------------
		case CT_KEY:

///*?*/	error = SEQERR_KeyedUnsorted;			// Keyed crouton in wrong order.  Move earlier in the project.
///*?*/	error = SEQERR_KeyedDuringEffect;	// Keyed crouton can't start until previous Effect has finshed.
///*?*/	error = SEQERR_KeyedTooSoon;			// Keyed crouton can't start before the clip.  Use a later start time.
///*?*/	error = SEQERR_KeyedStartBad;			// Keyed crouton can't start after the clip.  Use an earlier start time.
///*?*/	error = SEQERR_KeyedOverlapsKey;		// Keyed crouton can't start until previous Key has finished.

			//DUMPMSG("KEY CROUTON or CRFX");

			if (PreviousTrack==CRTN_NONE)
			{
				error = SEQERR_KeyedAtStart;	// Can't start with key
				break;
			}

			if (PreviousTrack==CRTN_TRANS)
			{
				error = SEQERR_KeyedAfterEffect;	// Key pages cannot follow effects
				break;
			}


			if (PrevVidEvent)
				reftime = PrevVidEvent->Time;
			else
			{
				reftime = 0;		// Meaningless, but at least consistent

				if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
				{
					error = SEQERR_CrtnNeedsVideo;	// Needs video to ref to
					break;
				}
			}

			// Find desired key start time
			gotime = GetRefTime(reftime,PrevVidFG,FG);

			//DUMPUDECL("RefTime = ",reftime," ");
			//DUMPUDECL("GoTime = ",gotime," \\");

			if (DetectSwitcherCollision(sv,gotime))
			{
				error = SwitCollisionErrors(sv->LastSwitEvent,FG);
				break;
			}

			// Get event for SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_SELECT;
			event->Time = 0;	//as soon as possible

			// If wants a fade-in with a start time of < 6f, coerce start time so will work
			if ((GetSpeed(FG) & 1) && (gotime < (reftime+KEY_SETUP)))
				gotime = reftime + KEY_SETUP;

			// Wants a double-punch (take and key at same time)?
			if (gotime == reftime)
				setchan = AppendSelect(&sv->SwitcherTrack,event);	// Replace TOMAIN w/Key TAKE
			else if (gotime < (reftime+FRAMEPREROLLFUDGE))			// Not enough pre-load?
			{
				InsertSelect(&sv->SwitcherTrack,event);				// Do before TOMAIN
				setchan = -1;													// Not a double-punch
			}
			else
			{
				AppendToTrack(&sv->SwitcherTrack,event);				// Tack on end of track
				setchan = -1;													// Not a double-punch
			}

			// Get event for TAKE/AUTO/TOMAIN
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			if (setchan >= 0)							// Special FGC for double-punch
			{
				event->Channel = setchan;
				event->Flags1 |= FLAGS1F_SETCHAN;
			}

			if (setchan >= 0)
				event->FGCcommand = FGC_TAKE;			// Take new source with key (no fade)
			else if (GetSpeed(FG) & 1) 	// && GetFadeInDuration(FG))
				event->FGCcommand = FGC_AUTO;
			else
				event->FGCcommand = FGC_TOMAIN;

			// 1st field of key will start at this time
			event->Time = gotime;
			event->Duration = GetDuration(FG);			// Just used internally (not switcher)
			AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

			//DUMPUDECL("**Key ToMain: at ",event->Time," \\");

			// Get event for REMOVE
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			// Remove Key Event, this MUST have its time reset, if another event happens
			// before it is due to end
			event->FG = FG;
			event->CurrentPosition = sv->Pos;

			if (GetSpeed(FG) & 2) 	// && GetFadeOutDuration(FG))
				event->FGCcommand = FGC_AUTO;
			else
				event->FGCcommand = FGC_REMOVE;		//Why not using this???
//				event->FGCcommand = FGC_AUTO;
			event->Time = GetRefTime(reftime,PrevVidFG,FG) + GetDuration(FG);
			AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

			//DUMPUDECL("**Key Remove: at ",event->Time," \\");

//			KeyKill = event;		OBSOLETE

//			Keep these to detect switcher event overlaps (Key -- is this required???)
			sv->SwitcherBusyTil = event->Time + event->Duration;
			sv->LastSwitEvent = event;

//			PreviousFG = FG;
//			PreviousPos = sv->Pos;
			PreviousTrack = CRTN_KEY;

			break;

//----------------------------------------------------------------------
// Transitional and non-transition+overlay effects
// Someday, might be nice to make new types for these other things
		case CT_FXANIM:
		case CT_FXILBM:
		case CT_FXALGO:

			if (!IsOverlay(FG))
			{
				//DUMPMSG("FX TRANSITION CROUTON");

//				takeneeded = FALSE;			// No implied TAKE on next video

// This error is bogus if it's a solid ANIM
//				if (!GetNextGadget(FG))
//				{
//					error = SEQERR_EffectAtEnd;	// Can't end sequence with an Effect.
//					break;
//				}

// This error is bogus if it's a solid ANIM
//				if (PreviousTrack==CRTN_NONE)
//				{
//					error = SEQERR_EffectAtStart;	// Can't start with an effect
//					break;
//				}

// FALL THRU
// 			case CT_VIDEOANIM:

				if (PreviousTrack==CRTN_TRANS)
				{
					error = SEQERR_EffectAfterEffect;	// Can't sequence two Effects in a row
					break;
				}

/*?*/			//	error = SEQERR_EffectDuringKeying;	// Effect not allowed during keying.

				EffectFG = FG;
				EffectPos = sv->Pos;

//				PreviousFG = FG;
//				PreviousPos = sv->Pos;
				PreviousTrack = CRTN_TRANS;  //**!! NOT REALLY IF VIDEOANIM
			}
			else
			{
				//DUMPMSG("EFFECT/OVERLAY CROUTON");

//				if (PreviousTrack==CRTN_NONE)
//				{
//					error = SEQERR_OverlayAtStart;	// Can't start with overlay
//					break;
//				}

				if (PreviousTrack==CRTN_TRANS)
				{
					error = SEQERR_OlayAfterEffect;	// Overlays cannot follow transitional effects
					break;
				}

				if (PrevVidEvent)
					reftime = PrevVidEvent->Time;
				else
				{
					reftime = 0;		// Meaningless, but at least consistent

					if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
					{
						error = SEQERR_CrtnNeedsVideo;	// Needs video to ref to
						break;
					}
				}

				// Find desired overlay start time
				gotime = GetRefTime(reftime,PrevVidFG,FG);

				//DUMPUDECL("RefTime = ",reftime," ");
				//DUMPUDECL("GoTime = ",gotime," \\");

				if (DetectSwitcherCollision(sv,gotime))
				{
					error = SwitCollisionErrors(sv->LastSwitEvent,FG);
					break;
				}

				/*** Determine worst-case load times for each ***/
				switch(FGtype)
				{
					case CT_FXILBM:
						fudge = ILBMPREROLLFUDGE;
						break;
					case CT_FXANIM:
						fudge = ANIMPREROLLFUDGE;
						break;
					case CT_FXALGO:
						fudge = FXPREROLLFUDGE;
						break;
					default:		// What other types fall to here???
						fudge = FXPREROLLFUDGE;
						break;
				}

				// Get event for SELECT
				if ((event = GetEvent(FG))==NULL)
				{
					error = SEQERR_OutOfMemory;
					break;
				}
				event->FG = FG;
				event->CurrentPosition = sv->Pos;
				event->FGCcommand = FGC_SELECT;
				event->Time = 0;	//as soon as possible

//				// Wants a double-punch (take and overlay at same time)?
//				// THIS DOESN'T WORK YET, AS FX CODE ONLY DOES A "TAKE" FOR FGC_TAKE,
//				// IT DOES NOT CHANGE SOURCES AND PUT UP THE EFFECT.  COULD WE ADD A
//				// NEW FGC THAT WOULD DO THIS (CAN'T BREAK THE WAY 'TAKE' WORKS)
//				if (gotime == reftime)
//				{
//					setchan = AppendSelect(&sv->SwitcherTrack,event);	// Replace TOMAIN w/Olay TAKE
//					// If fails (due to ineligibility to replace a TAKE, maybe allow 2nd
//					// strategy below (insert SELECT) a chance???
//				}
//				else
				if (gotime < (reftime+fudge))							// Not enough pre-load?
				{
					InsertSelect(&sv->SwitcherTrack,event);				// Do before TOMAIN
					setchan = -1;													// Not a double-punch
				}
				else
				{
					AppendToTrack(&sv->SwitcherTrack,event);				// Tack on end of track
					setchan = -1;													// Not a double-punch
				}

				/*** Check that we have enough setup time to do our tomain ***/
				if (gotime < (reftime+OVERLAY_SETUP))
				{
					error = SEQERR_OlayPreroll;	// Overlay needs more time
					break;
				}

				// Get event for TAKE/TOMAIN
				if ((event = GetEvent(FG))==NULL)
				{
					error = SEQERR_OutOfMemory;
					break;
				}
				event->FG = FG;
				event->CurrentPosition = sv->Pos;

				if (setchan >= 0)							// Special FGC for double-punch
				{
					event->Channel = setchan;
					event->Flags1 |= FLAGS1F_SETCHAN;
				}

				if (setchan >= 0)
					event->FGCcommand = FGC_TAKE;			// Take new source with overlay
				else
					event->FGCcommand = FGC_TOMAIN;		// Just bring overlay to main

//				event->FGCcommand = FGC_TOMAIN;
				event->Time = gotime;							// When to appear
				event->Duration = GetDuration(FG);			// How long to stay up
				event->Flags1 |= FLAGS1F_LOOPTIME;			// Stop after "duration"
				AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

				//DUMPUDECL("**Olay ToMain: at ",event->Time," \\");

//				Keep these to detect switcher event overlaps (overlays)
				sv->SwitcherBusyTil = event->Time + event->Duration;
				sv->LastSwitEvent = event;

				PreviousTrack = CRTN_OVERLAY;
			}
			break;


//----------------------------------------------------------------------
		case CT_VIDEO:
		case CT_STILL:

			//DUMPSTR("VIDEO OR FLYERSTILL CROUTON  ");
			//DUMPMSG((char *)FG->FileName);

			if (!FlyerBase)
			{
				// Can't play video clips without a Flyer
				error = SEQERR_VideoNeedsFlyer;
				break;
			}

			// If this is locked down, move to that time
			if (GetTimeMode(FG) == TIMEMODE_ABSTIME)
			{
				ProgTime = GetDelay(FG);

				// If previous video does not reach here, insert black
				if (PrevVidEvent)
				{
					if (!MaybeInsertBlack(sv,PrevVidEvent,ProgTime))
						goto Failed;
				}
			}

			// Get event for video SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}

			// Okay, if this clip/still is slated to start before a switcher scroll/crawl
			// will be finished, we must use the same Flyer channel as previous source,
			// so that it will look correct even though switcher cannot do a take.
			// For this to work requires that the previous source be a clip/still as well
			if (DetectSwitcherCollision(sv,ProgTime))
			{
				// Eligible for special cuts-under handling?
				if (PrevVidEvent)
					objtype = PrevVidEvent->FG->ObjectType;
				else
					objtype = 0;
				if ((objtype!=CT_VIDEO) && (objtype!=CT_STILL))		// Wrong previous type
				{
					error = SEQERR_OverlaysOverNonFlyer;
					if (PrevVidEvent)
						FG = PrevVidEvent->FG;
					break;
				}
				if (EffectFG)			// Cannot do effect under scroll/crawl
				{
					error = FXunderErrors(sv->LastSwitEvent);
					FG = EffectFG;
					sv->Pos = EffectPos;
					break;
				}

				//DUMPMSG("Cut under scroll/crawl!");
				sv->FlyChan = 1-sv->FlyChan;				// Reverse back to other channel
				sv->CutUnder = TRUE;							// Special case for this one guy
			}
			else
			{
				event->Flags1 = FLAGS1F_SETCHAN;	// Indicate we need FX to this to set chan
				// Assign alternating channels to each clip/still
			}

			event->Channel = sv->FlyChan;
			//DUMPUDECL("Assigned to channel ",sv->FlyChan,"\\");
			sv->FlyChan = 1-sv->FlyChan;

			if (FGtype == CT_VIDEO)
			{
				event->StartField = GetStartField(FG);
				PutAdjVideoStart(FG,event->StartField);

//				//DUMPUDECL	("Assume InPoint=",event->StartField,"\\");

				// Keep user's audio ramp rates (may or not be any audio)
				event->AudAttack = GetAudioAttack(FG);
				event->AudDecay = GetAudioDecay(FG);

				if(GetAudioOn(FG)&AUDF_AudEnvEnabled)
					GetAudioEnv16(event->AE,FG);		//DEHMaybe keep audio envelope data here too.
			}

			fudge = VIDEOPREROLLFUDGE;

//			FinalClip=event;		// UNUSED NOW

			// This assumes a Take to bring in this video.  If this actually transitions
			// in, then some values must be adjusted.

			goto VideoMerge;		// Continue with logic for FrameStores et.al.


		case CT_FRAMESTORE:
			// If this is locked down, move to that time
			if (GetTimeMode(FG) == TIMEMODE_ABSTIME)
			{
				ProgTime = GetDelay(FG);

				// If previous video does not reach here, insert black
				if (PrevVidEvent)
				{
					if (!MaybeInsertBlack(sv,PrevVidEvent,ProgTime))
						goto Failed;
				}
			}

		case CT_VIDEOANIM:		//**!! DOES THIS REALLY BELONG HERE????
		case CT_IMAGE:

			fudge = FRAMEPREROLLFUDGE;

		case CT_MAIN:

			//DUMPMSG("FRAMESTORE/VIDEOANIM/MAIN/IMAGE CROUTON");

//TAG_AdjustedVideoStart=event->StartField=0 for FRAMSTORE/VIDEOANIM/MAIN/IMAGE/FLYERSTILL croutons

			// Get event for SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}

			if (DetectSwitcherCollision(sv,ProgTime))
			{
				error = SwitCollisionErrors(sv->LastSwitEvent,FG);
				break;
			}

VideoMerge:

			// 1st field of video will start at this time (assuming Cut)
			event->Time = ProgTime;
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_SELECT;

//			CurVidFG = FG;

			// This assumed value can be altered later if there are video transitions
			event->Duration = GetDuration(FG);
			PutAdjVideoDuration(FG,event->Duration);

			if ((FGtype==CT_VIDEO) || (FGtype==CT_STILL))
				SortIntoTrack(&sv->VideoTrack,event);		// Flyer: Sort by time into track
			else
				AppendToTrack(&sv->SwitcherTrack,event);	// Switcher: Tack on end of track

			CurVidEvent = event;
			EndOfVideo = ProgTime + GetDuration(FG);  // Field after the video


//OBSOLETE!!!
//			// Can't do takes under keys, so kill key when next event comes up (AC)
//			if (PreviousTrack==CRTN_KEY)
//			{
//				//DUMPUDECL("Prev Key End: ",KeyKill->Time,"  ");
//				//DUMPUDECL("ProgTime: ",ProgTime,"  ");
//
//				if (KeyKill && KeyKill->Time > (ProgTime-fudge))
//				{
//					// Could this mess with event sort???
//					KeyKill->Time=ProgTime-fudge; // a little margin.. necessary???
//				}
//			}


/*~~~~~~~~~~~~~~~ Handle natural audio ~~~~~~~~~~~~~~~~~~~~~~~~~~*/

// This test should do a regular call to DoAudioCrouton() if the video portion was
// entirely clipped out

			if ((FGtype==CT_VIDEO) && (HasAudio(FG)))	// Has natural audio enabled?
			{
				// Just plug in natural audio parameters
				// Will trim to play window when downloaded to Flyer
				CurVidEvent->AudStart = GetAudioStart(FG);
				CurVidEvent->AudLength = GetAudioDuration(FG);

//				astartfld = GetAudioStart(FG);
//				audlength = GetAudioDuration(FG);
//				vstartfld = CurVidEvent->StartField;
//
//				// Calculate when the audio should start
//				gotime = CurVidEvent->Time + astartfld-vstartfld;
//
//				// Ensure natural audio does not fall outside sequencing time period
//				if ((gotime + audlength) <= sv->StartTime)		// No audio reaches start time?
//					audlength = 0;
//				else if (gotime >= sv->EndTime)					// No audio begins in time?
//					audlength = 0;
//				else
//				{
//					// If audio starts before start time, crop off front
//					if (gotime < sv->StartTime)
//					{
//						astartfld += sv->StartTime - gotime;		// crop audio to starttime
//						audlength -= sv->StartTime - gotime;		// shorten by same amount
//						gotime = sv->StartTime;						// Start immediately
//					}
//
//					// If audio extends past end of sequence, crop off rear
//					if ((gotime+audlength) > sv->EndTime)
//						audlength = sv->EndTime - gotime;
//				}
//
//				// Stash trimmed natural audio parameters
//				CurVidEvent->AudStart = astartfld;
//				CurVidEvent->AudLength = audlength;
			}


/*~~~~~~~~~~~~~~~ Prepare Transition/Cut ~~~~~~~~~~~~~~~~~~~~~~~~~*/

			if (!HandleTransition(
				sv,
				ProgTime,				// CutTime
				PrevVidEvent,			// V1
				EffectFG,				// FXFG (will be NULL for cut)
				EffectPos,				// FXpos (or -1 for cut)
				CurVidEvent))			// V2
					goto Failed;

/*~~~~~~~~~~~~~~~ Prepare Transition/Cut ~~~~~~~~~~~~~~~~~~~~~~~~~*/

//			if (FGtype==CT_VIDEO)					// Special tests for Flyer video
//			{
//This makes no sense, since clips should never have a length of 0
//				/*** Check for minimum Video clip length ***/
//				if (GetAdjVideoDuration(FG) < 4)
//				{
//					error = SEQERR_ShortVideo;		// Can't sequence clips this short
//					FG = FG;
//					break;
//				}
//			}


			//DUMPUDECL	("VIDEO time=",CurVidEvent->Time,"\\");
			//DUMPUDECL	("Assume duration=",GetAdjVideoDuration(FG),"\\");

			ProgTime = EndOfVideo;

			PrevVidEvent	= CurVidEvent;
			PrevVidFG		= FG;

//			PreviousFG		= FG;
//			PreviousPos		= sv->Pos;
			PreviousTrack	= CRTN_VIDEO;

			// Destroy knowledge of effect, implies we need a take if no effect appears
			EffectFG = NULL;
			EffectPos = -1;
//			takeneeded = TRUE;			// If no effect comes along, imply a TAKE

			break;

//----------
		case CT_CONTROL:
			//DUMPMSG("Control CROUTON");

			if (PreviousTrack==CRTN_TRANS)
			{
				error = SEQERR_ARexxAfterEffect;	// Arexx cannot follow Effects croutons
				break;
			}

			if (PrevVidEvent)
				reftime = PrevVidEvent->Time;
			else
			{
				reftime = 0;		// Meaningless, but at least consistent

				if (GetTimeMode(FG)!=TIMEMODE_ABSTIME)
				{
					error = SEQERR_CrtnNeedsVideo;	// Needs video to ref to
					break;
				}
			}

			// Get event for SELECT
			if ((event = GetEvent(FG))==NULL)
			{
				error = SEQERR_OutOfMemory;
				break;
			}
			event->FG = FG;
			event->CurrentPosition = sv->Pos;
			event->FGCcommand = FGC_SELECT;
			// ARexx will start at this time
			event->Time = GetRefTime(reftime,PrevVidFG,FG);
			event->TimeTolerance = CONTROLTOLERANCE;		// Allow for some error !!!
			AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

//			PreviousFG = FG;
//			PreviousPos = sv->Pos;
			PreviousTrack = CRTN_CONTROL;			


			break;

//----------
		case CT_ERROR:		// Playing a sequence with "lost croutons" still in it
			//DUMPMSG	("*** LOST ***");

			sv->LostCroutons++;					// Count these

			switch (((struct ExtFastGadget *)FG)->LocalData)
			{
			case CT_VIDEO:
			case CT_STILL:
			case CT_FRAMESTORE:
				// If this is locked down, move to that time
				if (GetTimeMode(FG) == TIMEMODE_ABSTIME)
					ProgTime = GetDelay(FG);

				ProgTime += GetDuration(FG);

				if (PrevVidEvent)
				{
					if (!MaybeInsertBlack(sv,PrevVidEvent,ProgTime))
						break;
				}

				break;
			default:
				// Do nothing???
				break;
			}
			break;

		default:
			//DUMPMSG("Unrecognized Crouton Type!");

			//	Don't recognize this content in a sequence.
			break;

		} // END OF SWITCH

		// If an error code was reported, stop analyzing
		if (error)
			break;

		sv->Pos++;
	} // FOR

	if (error)
		goto Failed;


//	/*** Warn user if sequencer inserted black anywhere ***/
//	if ((!error) && (sv->InsMattes > 0))
//	{
//		sprintf(sv->scratch," Warning!  Sequencer inserted black at %d place(s) ",sv->InsMattes);
//		MPtr[0] = sv->scratch;
//		MPtr[1] = " in this project due to locked video.";
//		MPtr[2] = " Select \"cancel\" to abort and highlight each";
//
//		// Put up warning requester, check proceed or cancel
//		if (!SeqRequest(sv,MPtr,3))
//		{
//			// User cancelled
//
//			flag = FALSE;
//
//			/*** Walk thru list of events and hilite each that caused black insertion ***/
//			for (event = (struct Event *)sv->VideoTrack.EventList.lh_Head
//			; event->Node.mln_Succ
//			; event = (struct Event *)event->Node.mln_Succ)
//			{
//				if ((FLAGS2F_MATTE & event->Flags2) && (event->CurrentPosition >= 0))
//				{
//					DUMPUDECL("Hiliting ",event->CurrentPosition,"\\");
//					// Hilite this crouton
//					if (!flag)
//					{
//						ew_QuickSelect(sv->EditTop,event->CurrentPosition);		// First one
//						flag = TRUE;
//					}
//					else
//						ew_MultiSelect(sv->EditTop,event->CurrentPosition);		// all others
//				}
//			}
//
//			if (flag)
//			{
//				sv->Edit->ew_OptRender = FALSE;
//				UpdateAllDisplay();
//			}
//
//			goto Failed;
//		}
//	}


	// Unless an error occurred, put final transition at end
	if (!error)
	{
		// Okay, if this final black is slated to start before a switcher scroll/crawl
		// will be finished, we must use the same Flyer channel as previous source,
		// so that it will look correct even though switcher cannot do a take.
		// For this to work requires that the previous source be a clip/still as well
		if (DetectSwitcherCollision(sv,ProgTime))
		{
			// Eligible for special cuts-under handling?
			if (PrevVidEvent)
				objtype = PrevVidEvent->FG->ObjectType;
			else
				objtype = 0;
			if ((objtype!=CT_VIDEO) && (objtype!=CT_STILL))		// Wrong previous type
			{
				error = SEQERR_OverlaysOverNonFlyer;
				if (PrevVidEvent)
					FG = PrevVidEvent->FG;
				goto Failed;
			}
			if (EffectFG)			// Cannot do effect under scroll/crawl
			{
				error = FXunderErrors(sv->LastSwitEvent);		// Error for switcher object type
				FG = EffectFG;
				sv->Pos = EffectPos;
				goto Failed;
			}
			objtype = sv->LastSwitEvent->FG->ObjectType;
			if ((objtype == CT_SCROLL) || (objtype == CT_CRAWL))
			{
				error = SEQERR_ScrawlPastEnd;
				FG = sv->LastSwitEvent->FG;
				sv->Pos = -1;		// Don't know
				goto Failed;
			}

			//DUMPMSG("Cut under key/overlay!");
			sv->FlyChan = 1-sv->FlyChan;				// Reverse back to other channel
			sv->CutUnder = TRUE;							// Special case for this one guy
		}
		else
			sv->CutUnder = FALSE;

		// Create a black event to cut/transition to
		event = CreateBlack(sv,ProgTime,sv->FlyChan);
		sv->InsMattes--;			// Don't count this as a black insertion

		if ((event) && (!sv->CutUnder))		// Switcher not a participant for cuts under
		{
			sv->FlyChan = 1-sv->FlyChan;					// Alternate channels

			if (!HandleTransition(
				sv,
				ProgTime,			// CutTime
				PrevVidEvent,			// V1
				EffectFG,				// FXFG (will be NULL for cut)
				EffectPos,				// FXpos (or -1 for cut)
				event))					// V2 (has no FG associated with it!)
			{
				goto Failed;
			}
		}
	}

	/*** Calculate total running time from start crouton to end ***/
	sv->SeqTotalTime = TimeBetweenFGs(SeqStartFG,NULL);

	/*** Make "wait" event to take us to the end of the total project ***/
	if (!error)
	{
		if ((event = GetEvent(FG))==NULL)
			error = SEQERR_OutOfMemory;
		else
		{
			event->FG = NULL;
			event->Flags1 = FLAGS1F_WAIT4TIME;		// Control event = wait for time
//			event->Time = ProgTime;						// Time = end of project
			event->Time = sv->SeqTotalTime;			// Time = end of project
			AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track
		}
	}

// Was coming to here first, but I moved it higher up
//	if (error)
//		goto Failed;

//	if (FinalClip)
//		FinalClip->Flags1 |= FLAGS1F_LASTEVENT;


#ifdef	SERDEBUG

	// Dump contents of each track

	ListTrack(&sv->SwitcherTrack,TRACK_SWITCHER);
	ListTrack(&sv->VideoTrack,TRACK_FLYVID);
	ListTrack(&sv->AudioTrack,TRACK_AUDIO);

	//DUMPMSG("******************************************");
#endif

	return(TRUE);					// Built sequence successfully


Failed:

	// If stopped due to some error, put up the requester now
	if ((error == SEQERR_SwitcherCollision) || (error == SEQERR_OverlaysOverNonFlyer))
		ReportSequenceDualError(sv,FG,sv->Pos,sv->LastSwitEvent->FG,-1,error);
	else if (error)
		ReportSequenceError(sv,FG,sv->Pos,error,FALSE);


	DisplayMessage(NULL);			// Remove any message at top of screen
	DisplayRunningTime();			// Put other info back up

	return(FALSE);
}


//=============================================================
// PlayCurSeq
//		Play the currently built sequence
//=============================================================
static void PlayCurSeq(	struct SeqVars *sv)
{
	struct PlaySeqInfo SeqInfo;
	struct ExtFastGadget *FG = NULL;
	char	*MPtr[2];
	UWORD error = 0;

	struct FlyerVolume	fv;
	struct ClipAction		act;

	/* MUST Be initialized to zeroes */
	memset(&act,0,sizeof(act));
	memset(&fv,0,sizeof(fv));


	// Select internal default effect (fade)
	SendSwitcherReply(ES_SelectDefault,NULL);

	// Put up matte black if showing a Flyer video output
	// This is no longer needed, as the sequence processing glitch is gone
//	Main2Blank();

	EditingLive = FALSE;

	// Send abort to Flyer to abort any clips that are playing
	SendSwitcherReply(ES_Stop,NULL);

//**********************************************************
//************** Start of post processing ******************
//**********************************************************

//*** No longer instruct Flyer about Head definition/creation, we let it do that now ***
//	sv->AuxError = SendSwitcherReply(ES_EndHeadList,NULL);
//	DUMPHEXIL("EndHeadList error=",sv->AuxError,"\\");
//	if(sv->AuxError == 9)		// Tie into FERR_NOAUDIOCHAN!
//	{
//		// Unable to create heads of strip audio
//		error = SEQERR_NoAudioDrive;
//		FG = (struct ExtFastGadget *)CurFG;
//		sv->Pos = -1;							// Find it for me
//		goto Abort;
//	}
//	else if (sv->AuxError)		// Will be FERR_FULL ($21) when full, handle any other non-0 as well!
//	{
//		// Unable to create heads of strip audio
//		error = SEQERR_ABrollFull;
//		FG = (struct ExtFastGadget *)CurFG;
//		sv->Pos = -1;					// Find it for me
//		goto Abort;
//	}

//	if (sv->AudioTrack.EventList)
//	{
//		sv->AudioTrack.EventPtr->FG = NULL;		// Put an end on it
//
#ifdef	SERDEBUG
//		DUMPMSG("---- Unsorted AudEvents ----");
//		for (sv->Pos=0 ; sv->Pos<sv->AudioTrack.EventCount ; sv->Pos++)
//		{
//			DUMPMEM("AudEvent",(UBYTE *)(sv->AudioTrack.EventList+sv->Pos),sizeof(struct Event));
//		}
//		DUMPMSG("**************************************");
#endif
//
//		// Sort events by time
//		SortEvents(sv->AudioTrack.EventList,(ULONG)sv->AudioTrack.EventCount);
//
//
#ifdef	SERDEBUG
//		DUMPMSG("---- Sorted AudEvents ----");
//		for (sv->Pos=0 ; sv->Pos<sv->AudioTrack.EventCount ; sv->Pos++)
//		{
//			DUMPMEM("AudEvent",(UBYTE *)(sv->AudioTrack.EventList+sv->Pos),sizeof(struct Event));
//		}
//		DUMPMSG("**************************************");
#endif
//	}

	// Download Flyer events to Flyer
	if (FlyerBase)
	{
		ClearFlyerStatus();		// Clear "done" flag and any errors

		sv->AuxError = NewSequence(0);				// Prepare Flyer for sequence download
		//DUMPUDECB("NewSeq err = ",sv->AuxError,"\\");
		if (sv->AuxError==FERR_OKAY)					// Can we proceed to download?
		{
			MPtr[0] = "Flyer is processing sequence...";
			OpenNoticeWindow(sv->EditTop->Window,MPtr,1,TRUE);
//			DisplayWaitSprite();

			//DUMPMSG("Downloading video track...");
			sv->AuxError = DownLoadFlyerTrack(sv,&sv->VideoTrack,TRACK_FLYVID,TRUE);	// Send video events
			if (sv->AuxError==FERR_OKAY)
			{
				//DUMPMSG("Downloading audio track...");
				sv->AuxError = DownLoadFlyerTrack(sv,&sv->AudioTrack,TRACK_AUDIO,TRUE);	// Send audio events
			}

			// Should we allow Flyer to process the sequence?
			if (sv->AuxError == FERR_OKAY)
			{
				act.Volume = &fv;
				act.ReturnTime = RT_IMMED;

				//DUMPSTR("Flyer is processing sequence...");
				sv->AuxError = EndSequenceNew(&act,1);		// Just BEGIN processing...
				//DUMPUDECL ("(start=",sv->AuxError,") ");
				if (sv->AuxError == FERR_OKAY)
				{
					//DUMPSTR("Waiting...");
					do
					{
						if (CheckNoticeCancel())				// If CANCEL button pressed...
						{
							//DUMPSTR("Aborting...");
							AbortAction(&act);					// ...abort processing
							//DUMPMSG("Aborted");
							sv->AuxError = FERR_ABORTED;
						}
						else
							sv->AuxError = CheckAction(&act);	// Still processing?
					} while (sv->AuxError == FERR_BUSY);			// Loop until done
				}
				//DUMPUDECB("done (",sv->AuxError,")\\");
			}
			else
				EndSequence(0,0);					// Abort download

//			DisplayNormalSprite();
			CloseNoticeWindow();
		}

		if (sv->AuxError == FERR_FULL)			// Can't move data necessary?
		{
			// Unable to create A/B video heads (or stripped audio)
			error = SEQERR_ABrollFull;
			FG = NULL;		// Highlight none
			goto Abort;
		}
		else if (sv->AuxError == FERR_NOAUDIOCHAN)	// Need audio drive to move data to?
		{
			// No audio drive for stripped/split audio
			error = SEQERR_NoAudioDrive;
			FG = NULL;		// Highlight none
			goto Abort;
		}
		else if (sv->AuxError == FERR_NO_BROLLDRIVE)	// Need B-roll drive to do FX?
		{
			// No video drive for overlapping video during FX
			error = SEQERR_NoBrollDrive;
			FG = NULL;		// Highlight none
			goto Abort;
		}
		else if (sv->AuxError == FERR_HEADFAILED)		// A/B head failure?
		{
			// A/B head failure
			error = SEQERR_ABfailure;
			FG = NULL;		// Highlight none
			goto Abort;
		}
		else if (sv->AuxError == FERR_OBJNOTFOUND)	// Clip not found?
		{
			// Could not find named clip
			error = SEQERR_FlyerClipMissing;
			FG = sv->FailFG;		// Highlight offender
			goto Abort;
		}
		else if (sv->AuxError == FERR_LISTCORRUPT)	// Head problem?
		{
			if (ReportSeqErrCore(sv,SYSERR_HeadsBad,TRUE))
			{
				DisplayMessage("Cleaning up A/V temps...");	// Let them know what's going on
				StartHeadList(0);			// Do nice, graceful cleanup of heads first
				EndHeadList(0,1);
				VoidCardHeads(0);			// Now get nasty and clean EVERYTHING up
				DisplayMessage(NULL);	// Remove any message at top of screen
			}
			error = 0;				// No other error to report (took care of it)
			goto Abort;
		}
		else if (sv->AuxError == FERR_DRIVEINCAPABLE)	// Video from slow drive?
		{
			// Can't play video from this drive
			error = SEQERR_NonVideoDrive;
			FG = sv->FailFG;		// Highlight offender
			goto Abort;
		}
		else if (sv->AuxError == FERR_BADPARAM)	// Bad clip parameter?
		{
			error = SEQERR_BadParam;
			FG = sv->FailFG;		// Highlight offender
			goto Abort;
		}
		else if ((sv->AuxError == FERR_SELTIMEOUT)	// Missing drive?
				|| (sv->AuxError == FERR_BADSTATUS)		// Some SCSI error?
				|| (sv->AuxError == FERR_INCOMPLETE))	// Transfer not completed?
		{
			UBYTE	done;
			ULONG	drive;

			switch (sv->AuxError)
			{
				case FERR_SELTIMEOUT:
					error = SYSERR_SCSItimeout;
					break;
				case FERR_BADSTATUS:
					error = SYSERR_SCSIproblem;
					break;
				case FERR_INCOMPLETE:
					error = SYSERR_SCSIincomp;
					break;
			}

			if (GetClrSeqError(0,0,&done,&drive,NULL) == sv->AuxError)
			{
				GetClrSeqError(0,1,NULL,NULL,NULL);					// Clear status
				sprintf(ErrorDetails,"   (Possibly related to drive F%c%d:)",'A'+(drive/8),drive%8);
			}
			else
				sprintf(ErrorDetails,"   (Unable to pinpoint the specific drive)");
			FG = NULL;		// Highlight none
			goto Abort;
		}
		else if (sv->AuxError == FERR_ABORTED)
		{
			error = 0;		// This is not an error
			goto Abort;		// But don't play sequence
		}
		else if (sv->AuxError != FERR_OKAY)
		{
			error = SEQERR_InternalFlyer;
			FG = sv->FailFG;		// Highlight offender
			goto Abort;
		}
	}


	// Show correct Flyer output (so FX from black to 1st video will work)
	if (sv->partial)
	{
		//DUMPUDECL ("Punched up first clip on ",sv->firstflychan,"\\");
		FlyerChanOnMain(sv->firstflychan);
	}
	else
	{
		//DUMPUDECL ("Punched up opposite of ",sv->firstflychan,"\\");
		FlyerChanOnMain(1-sv->firstflychan);
	}


	/*********************************************
	*** Prepare the SeqInfo structure for play ***
	*********************************************/

	// Clear all fields of this structure
	memset(&SeqInfo, 0, sizeof(struct PlaySeqInfo));

	// Stop on sequence timing error?
	SeqInfo.StopOnError = (UserPrefs.SeqFlags & SFF_STOPONERR)?1:0;

	SeqInfo.CurSwitcherEvent = (struct Event *)sv->SwitcherTrack.EventList.lh_Head;
	SeqInfo.TimeAtSequenceEnd = sv->SeqPlayTime;


	/*************************************************************
	*** If first switcher events are SELECTs, preroll them now ***
	*** Then put interface back up and wait for start          ***
	*************************************************************/

	if (((sv->SwitcherTrack.EventCount) && (SeqInfo.CurSwitcherEvent->FGCcommand == FGC_SELECT)) |
		((sv->SwitcherTrack.EventCount) && (SeqInfo.CurSwitcherEvent->FGCcommand == FGC_TOPRVW)))
	{
		//DUMPMSG("*** Before ES_StartSeq1 ***");
		SendSwitcherReply(ES_StartSeq,NULL);

		//DUMPMSG("*** ReadySeq ***");
		ReadySeq(&SeqInfo);			// Get ready to play (do 1st switcher select)

		//DUMPMSG("*** Before ES_Stop1 ***");
		SendSwitcherReply(ES_Stop,NULL);
		UpdateAllDisplay();
	}
	else
	{
		//DUMPMSG	("No pre-SELECT's required");
	}

	DisplayMessage(NULL);		// Remove message from strip
	DisplayRunningTime();		// Restore running time

	if (sv->waitplaystart)		// Wants us to put up requester to start play?
	{
		DisplayNormalSprite();
		if (!BoolRequest(sv->EditTop->Window,">>> The project is ready to play <<<"))
			goto Abort;
		DisplayWaitSprite();
	}

//	//DUMPMSG	("Play Sequence ...............");
//	//DUMPMEM("Sequence=",(UBYTE *)Sequence,VidTrack.TrackMemSize);


	// Get ready to start sequence.  This does some toaster setup and syncs
	// The toaster clock to the Flyer field clock.
	// Also sets bit 4 of TB_DisplayRenderMode (how intuitive!)
//	//DUMPMSG("Before ES_StartSeq2");
	SendSwitcherReply(ES_StartSeq,NULL);

	/* succ = */
		PlaySeq(&SeqInfo);		// Returns success flag

	//DUMPMSG(">>>>>>>>>>>>>>>>>>>> Done <<<<<<<<<<<<<<<<<<<<<");

//	//DUMPMSG("Before ES_Stop");
	SendSwitcherReply(ES_Stop,NULL);		//Clr bit 4 of TB_DisplayRenderMode


// some effects leave us with a bogus lock
#ifndef FINAL_CODE
	if (ToasterBase)
#endif
		CurrentDir(GetBootLock((struct ToasterBase *)ToasterBase));

//	//DUMPHEXIL("&SeqInfo=",(LONG)(&SeqInfo),"\\");

	if (SeqInfo.ErrorEvent)			// A local (Switcher) event failed?
	{
		// Does this if there was a Switcher timing error during the sequence.
		//DUMPHEXIL("ErrorEvent=",(LONG)(SeqInfo.ErrorEvent),"\\");
		//DUMPHEXIL("FG=",(LONG)(SeqInfo.ErrorEvent->FG),"\\");
		//DUMPHEXIL("ErrorMsg=",(LONG)(SeqInfo.ErrorMsg),"\\");

		switch(SeqInfo.ErrorNum)
		{
		case	1:
			// Queue error, time already passed.
			error = SEQERR_EventLate;
			FG = SeqInfo.ErrorEvent->FG;
			sv->Pos = -1;							// Find it for me (don't know)
			break;

		default:
			break;
		}
		// Goes to "Abort"
	}
	else if (SeqInfo.FlyerError)		// A Flyer event failed?
	{
		struct Event	*event;

		// Does this if there was an error during the sequence.
		switch (SeqInfo.FlyerError)
		{
		case FERR_CLIPLATE:
			error = SEQERR_FlyerLate;
			break;
		case FERR_DROPPEDFLDS:
			error = SEQERR_FlyerDropped;
			break;
		default:
			error = SEQERR_FlyerOther;
		}

		FG = NULL;

		// Turn UserID code sent to Flyer back into sequencer event ptr
		if (error != SEQERR_FlyerOther)
		{
			event = FindFlyerEventFromID(sv, SeqInfo.FlyerUserID);
			if (event)
				FG = event->FG;
		}

		sv->Pos = -1;							// Find it for me (don't know)
		// Goes to "Abort"
	}
	else
	{
		// If PlaySeq returned no FG (success or aborted before any processed)
		// then keep the same crouton hilited as when we started
		FG = SeqInfo.AbortedFG;		// Get FG for error/abort (or NULL)
		if (!FG)
			FG = (struct ExtFastGadget *)CurFG;

		HiliteNewFG(sv->EditTop,FG,-1,TRUE);	//Hilite initially selected or abort crouton
	}

Abort:

	// If stopped due to some error, put up the requester now
	if (error)
		ReportSequenceError(sv,FG,-1,error,FALSE);
}


//=============================================================
// EditToAllAudio
//		Interactive lock-down's to music (full sequence)
//=============================================================
static void EditToAllAudio(struct SeqVars *sv)
{
	struct PlaySeqInfo SeqInfo;

	EditingLive = FALSE;

	// Send abort to Flyer to abort any clips that are playing
	SendSwitcherReply(ES_Stop,NULL);

	// Download audio events to Flyer
	if (FlyerBase)
	{
		ClearFlyerStatus();		// Clear "done" flag and any errors

		sv->AuxError = NewSequence(0);				// Prepare Flyer for sequence download
		if (sv->AuxError==FERR_OKAY)					// Can we proceed to download?
		{
			//DUMPMSG("Downloading audio track...");
			sv->AuxError = DownLoadFlyerTrack(sv,&sv->AudioTrack,TRACK_AUDIO,FALSE);	// Send audio events

			// Should we allow Flyer to process the sequence?
			if (sv->AuxError == FERR_OKAY)
			{
				//DUMPSTR("Flyer is processing sequence...");
				sv->AuxError = EndSequence(0,1);				// Let Flyer grind on this for a while...
				//DUMPUDECB("done (",sv->AuxError,")\\");
			}
			else
				EndSequence(0,0);					// Abort download
		}

		if (sv->AuxError != FERR_OKAY)
		{
			ReportSequenceError(sv,NULL,-1,SEQERR_InternalFlyer,FALSE);
			return;
		}
	}


	FreeTrack(&sv->SwitcherTrack);			// Empty switcher list


	/*********************************************
	*** Prepare the SeqInfo structure for play ***
	*********************************************/

	// Clear all fields of this structure
	memset(&SeqInfo, 0, sizeof(struct PlaySeqInfo));

	SeqInfo.StopOnError = 0;		// No stopping

	SeqInfo.CurSwitcherEvent = (struct Event *)sv->SwitcherTrack.EventList.lh_Head;
	SeqInfo.TimeAtSequenceEnd = sv->SeqPlayTime;


	DisplayMessage(NULL);		// Remove message from strip
	DisplayRunningTime();		// Restore running time

	DisplayNormalSprite();
	if (!BoolRequest(sv->EditTop->Window,">>> Ready to edit to music <<<"))
		return;
	DisplayWaitSprite();

	DisplayMessage(E2Mproc_message);

	// Sync the Toaster/Flyer field clocks
//	SendSwitcherReply(ES_SyncClocks,NULL);		// WILL HAVE TO ADD THIS TO PECOMM.a

	// Start music and come right back (stash base time of the sequence)
	PlaySeq(&SeqInfo);		// Returns success flag


	//	DUMPMSG("Before ES_Stop");
//	SendSwitcherReply(ES_Stop,NULL);		//Clr bit 4 of TB_DisplayRenderMode

	//////////////// Return to interface gadgets and keys active //////////////
	// New lock-down hotkey (enabled when EditingLive == TRUE;
	// time = GetCurProgTime() + sv->StartTime;
	// Use absolute 'time' value
	//////////////////////////////////////////////////////////////////////////

	EditingLive = TRUE;
	Editing2Video = FALSE;

	MusicBaseTime = sv->StartTime;		// Offset to get us to real program time

	//DUMPUDECL ("MusicBaseTime(FULL) = ",MusicBaseTime,"\\");
}


//=============================================================
// EditToClip
//		Interactive lock-down's to music (one clip)
//=============================================================
static void EditToClip(struct SeqVars *sv, struct ExtFastGadget *fg)
{
//	struct PlaySeqInfo SeqInfo;

	//DUMPMSG("11111111  Cut2Music  111111111");

	EditingLive = FALSE;

	Editing2Video = (fg->ObjectType == CT_VIDEO)?TRUE:FALSE;

	// Send abort to Flyer to abort any clips that are playing
	SendSwitcherReply(ES_Stop,NULL);

//
//	SeqInfo.CurSwitcherEvent = (struct Event *)sv->SwitcherTrack.EventList.lh_Head;
//	SeqInfo.TimeAtSequenceEnd = sv->SeqPlayTime;
//
//
//	DisplayMessage(NULL);		// Remove message from strip
//	DisplayRunningTime();		// Restore running time
//
//	DisplayNormalSprite();

	if (!BoolRequest(sv->EditTop->Window,
		Editing2Video?">>> Ready to edit to video <<<":">>> Ready to edit to music <<<"))
	{
		return;
	}

	DisplayWaitSprite();
	DisplayMessage(Editing2Video ? E2Vproc_message : E2Mproc_message);

//	// Sync the Toaster/Flyer field clocks
//	SendSwitcherReply(ES_SyncClocks,NULL);		// WILL HAVE TO ADD THIS TO PECOMM.a

	if (Editing2Video)
	{
		MasterVideoTime = GetStartTimeInSequence((struct FastGadget *)fg);
		//DUMPUDECL ("MasterVidTime = ",MasterVideoTime,"\\");
	}

	// Just play the clip...
	ESparams1.Data1=(LONG)fg;
	SendSwitcherReply(ES_Auto,&ESparams1);


	//////////////// Return to interface gadgets and keys active //////////////
	// New lock-down hotkey (enabled when EditingLive == TRUE;
	// time = MusicBaseTime + GetCurProgTime()
	// Use absolute 'time' value
	//////////////////////////////////////////////////////////////////////////

	EditingLive = TRUE;

	NavigateRight(sv->EditTop,0);				// Jump to next crouton for them (aint I nice)

//	MusicBaseTime = sv->StartTime;		// Offset to get us to real program time
}


//=============================================================
// HandleLockDown
//		Lock/unlock crouton program time (also during cut2music)
//=============================================================
void HandleLockDown(struct EditWindow *Edit)
{
	struct ExtFastGadget *curfg,*fg;
	LONG	time;
	BOOL	lockem,redraw = FALSE;

	//DUMPMSG("LockDown");

	curfg=(struct ExtFastGadget *)CurFG;		// Hilited crouton (if any)
	if (!curfg)
	{
		curfg = FindFirstHilited(Edit);		// If none, pick first hilited as "curfg"
//		//DUMPHEXIL("FirstHilite=",(LONG)curfg,"\\");
	}

	if (curfg)							// Must have at least one crouton hilited, or we bail out
	{
		if (EditingLive)						// Always lock, and just this crouton (if possible)
		{
			//DUMPUDECL("MusicBaseTime = ",MusicBaseTime," ");
			//DUMPUDECL("CurProgTime = ",GetCurProgTime()," ");
			time = (((GetCurProgTime() + MusicBaseTime)/2)*2);	//Hack time even.DEH
			//DUMPUDECL("(time ",time,")\\");

			switch(curfg->ObjectType)
			{
			case CT_AUDIO:
				if (Editing2Video)
				{
					//DUMPMSG("Rel!");

					PutDelay(curfg,time-MasterVideoTime);		// Set relative start time
					PutTimeMode(curfg,TIMEMODE_RELINPT);		// Relative to video inpoint
//					curfg->SymbolFlags &= ~SYMF_LOCKED;
					curfg->SymbolFlags |= SYMF_LOCKED;		// Go ahead and show as locked
																		// (Will cleanup when done)
				}
				else
				{
					//DUMPMSG("Locked!");

					PutDelay(curfg,time);							// Set absolute start time
					PutTimeMode(curfg,TIMEMODE_ABSTIME);		// Lock video

					curfg->SymbolFlags |= SYMF_LOCKED;
				}
				redraw = TRUE;
				break;
			case CT_VIDEO:
			case CT_STILL:
			case CT_FRAMESTORE:
			case CT_VIDEOANIM:
			case CT_IMAGE:
			case CT_MAIN:
				//DUMPMSG("Locked!");

				PutDelay(curfg,time);							// Set absolute start time

				// Set lock as well as marker for our follow-up pass (we splice things up)
				PutTimeMode(curfg,TM_TEMP_LOCKED | TIMEMODE_ABSTIME);		// Lock video

				curfg->SymbolFlags |= SYMF_LOCKED;
				redraw = TRUE;
				break;
			}
			if (redraw)
				ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)curfg));
		}
		else	// else manually locking/unlocking
		{									// Lock/unlock (multiple) in project window

			// First, decide (based on last hilited) whether to lock or unlock all hilited
			if (GetTimeMode(curfg) == TIMEMODE_ABSTIME)
				lockem = FALSE;
			else
				lockem = TRUE;

			DisplayWaitSprite();

			// Since "next" pointer is first LONG of the FastGadget,
			// we just substitute the Address of the FG list head
			fg = (struct ExtFastGadget *)((struct Project *)Edit->Special)->PtrPtr;

			while (fg = (struct ExtFastGadget *)GetNextEditNode(Edit,(struct EditNode *)fg))
			{
				redraw = FALSE;

				if (fg->FG.FGDiff.FGNode.Status == EN_SELECTED)
				{
					switch(fg->ObjectType)
					{
					case CT_AUDIO:
						if (!lockem)		// Unlock (from ProgTime to InPoint)
						{
							ParentVideoTime = 0;		// In case this guys related to no one
							time = GetStartTimeInSequence((struct FastGadget *)fg);	// Current lock time

							PutDelay(fg,time-ParentVideoTime);		// Set relative start time
							PutTimeMode(fg,TIMEMODE_RELINPT);		// Relative to video inpoint
							fg->SymbolFlags &= ~SYMF_LOCKED;		// No longer locked
							redraw = TRUE;
							
							break;
						}

//						if (lockem)
//						{
//							time = GetStartTimeInSequence((struct FastGadget *)fg);	// Lock where it's at now
//							//DUMPUDECL("(locked at ",time,")\\");
//							PutDelay(fg,time);		// Set absolute start time
//							PutTimeMode(fg,TIMEMODE_ABSTIME);
//							fg->SymbolFlags |= SYMF_LOCKED;
//							redraw = TRUE;
//						}
//						break;



					case CT_STILL:
					case CT_VIDEO:
					case CT_FRAMESTORE:
					case CT_VIDEOANIM:
					case CT_IMAGE:
					case CT_MAIN:
						if (lockem)
						{
							//DUMPMSG("Locked!");
							time = GetStartTimeInSequence((struct FastGadget *)fg);	// Lock where it's at now
							//DUMPUDECL("(locked at ",time,")\\");
							PutDelay(fg,time);						// Set absolute start time
							PutTimeMode(fg,TIMEMODE_ABSTIME);		// Lock video

							fg->SymbolFlags |= SYMF_LOCKED;
							redraw = TRUE;
						}
						else
						{
							//DUMPMSG("Unlocked!");
							PutTimeMode(fg,TIMEMODE_RELCLIP);		// Unlock video
							fg->SymbolFlags &= ~SYMF_LOCKED;
							redraw = TRUE;
						}
						break;
					}
				}

				if (redraw)
					ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)fg));
			}
			DisplayNormalSprite();

			if (lockem == FALSE)				// When unlocking things, better...
			{
				CalcRunningTime();			// re-calculate sequence running time
				if (CurFG)
					CalcCurrentTime(CurFG);	// re-calculate time for the guy we're on
			}
		}
	}

}


//=============================================================
// EditTo_FollowUp
//		Optional cleanup work following editing to music or video
//=============================================================
static void EditTo_FollowUp(struct EditWindow *Edit)
{
	struct ExtFastGadget *fg,*lastvid=NULL;
	BOOL	okayed = FALSE,denied=FALSE;
	LONG	overlap,dur,maxdur;
	char *MPtr[3];
	ULONG	timemode;

	DisplayWaitSprite();

	//DUMPMSG("Fixing put seq?");

	// Since "next" pointer is first LONG of the FastGadget,
	// we just substitute the address of the FG list head
	fg = (struct ExtFastGadget *)((struct Project *)Edit->Special)->PtrPtr;

	while (fg = (struct ExtFastGadget *)GetNextEditNode(Edit,(struct EditNode *)fg))
	{
		//DUMPHEXIL("fg=",(LONG)fg,"\\");

		switch (fg->ObjectType)
		{
			case CT_AUDIO:
				// Look for audio croutons that artificially have the locked indicator lit.
				// This happens when editing audio to video: the lock appears even though
				// the time mode is really "in-point".  Now that we're done editing,
				// remove all the audio padlocks that aren't "real"
				if ((SYMF_LOCKED & fg->SymbolFlags)
				&&  (GetTimeMode(fg) != TIMEMODE_ABSTIME))
				{
					fg->SymbolFlags &= ~SYMF_LOCKED;
					ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)fg));
				}
				break;
	
			case CT_STILL:
			case CT_VIDEO:
			case CT_FRAMESTORE:
			case CT_VIDEOANIM:
			case CT_IMAGE:
			case CT_MAIN:
				timemode = GetTimeMode(fg);
				if (timemode & TM_TEMP_LOCKED)		// Just locked this one?
				{
					PutTimeMode(fg,timemode & ~TM_TEMP_LOCKED);		// Remove marker!!!

					if (!denied)		// If user denied us permission, still remove all markers
					{
						// Does previous video need fixed to line up with me?
						if (lastvid)
						{
							dur = GetDuration(lastvid);

							// Calc error (+ means overlap, - means a gap)
							overlap = (GetStartTimeInSequence((struct FastGadget *)lastvid) + dur)
								- GetDelay(fg);
						}
						else
							overlap = 0;

						if (overlap != 0)			// Problem with this one I'd like to fix?
						{
							// If we do not yet have permission to fix things, get it now
							if (!okayed)
							{
								MPtr[0] = "   Shall I fix the out-points necessary to";
								MPtr[1] = "   accommodate the croutons just edited?";
								MPtr[2] = NULL;
								okayed = ErrorMessageBoolRequest(Edit->Window,MPtr);
								if (!okayed)
									denied = TRUE;			// Skip further tests, but still remove markers
							}

							if (okayed)
							{
								//Okay, let's fix the previous video's outpoint to match (trim/extend)
								if (overlap < dur)			// Ensure we don't make a duration <= 0
								{
									//DUMPUDECL("Fixing video from ",dur,"");
									dur -= overlap;
							
									if ((fg->ObjectType==CT_STILL) || (fg->ObjectType==CT_FRAMESTORE))
										maxdur = 999000; //fix for fixup!							 	
									else	
									{
										maxdur = GetRecFields(lastvid) - GetStartField(lastvid);
										//DUMPUDECL(" using GetRecFields(lastvid) - GetStartField(lastvid) ",maxdur,"\\");
										//DUMPUDECL(" fg->ObjectType ",fg->ObjectType,"\\");
									}
									// Ya, right mr.M but with stills rec and start fields
									// are both 0 so then is maxdur!!! Realy it can be infinite.
									//	DEH122095	
									// DEH112096 - Really maxdur will be 0 or 4 in either case 
									//             it can be maxed out inf. it a still of fs.
									if (maxdur <= 4) maxdur=999000; //? is this close to inf.
									

									//DUMPUDECL(" GetRecFields ",GetRecFields(lastvid),"\\");
									//DUMPUDECL(" GetStartField ",GetStartField(lastvid),"\\");
									//DUMPUDECL(" Taking max dur into account ",maxdur,"\\");


									if (dur > maxdur)			// Keep outpoint legal
										dur = maxdur;
									PutDuration(lastvid,dur);
									//DUMPUDECL(" to ",dur,"\\");
								}

								// Maybe fix natural audio too (Flyer clips only)
								if ((lastvid->ObjectType==CT_VIDEO) && (HasAudio(lastvid)))
								{
									dur = GetAudioDuration(lastvid);

									// Calc error (+ means overlap, - means a gap)
									overlap =
										(GetStartTimeInSequence((struct FastGadget *)lastvid) + dur
										+ GetAudioStart(lastvid) - GetStartField(lastvid))
										- GetDelay(fg);
										// This next term accounts for difference in A/V start times

									if ((overlap > 0)			// Only trim audio, don't extend
									&& (overlap < dur))		// Ensure we don't make a duration <= 0
									{
										//DUMPUDECL("Fixing audio from ",dur,"");
										dur -= overlap;
										PutAudioDuration(lastvid,dur);
										//DUMPUDECL(" to ",dur,"\\");
									}
								}
							}
						}
					}
				}
				lastvid = fg;
				break;

			default:
				break;
		}
	}

	DisplayNormalSprite();			// Remove busy pointer
}


//=============================================================
// FindFirstHilited
//		Find first crouton (if any) in project that is hilited
//=============================================================
struct ExtFastGadget *FindFirstHilited(struct EditWindow *Edit)
{
	struct FastGadget *FG;

	if (Edit->Node.Type != EW_PROJECT)		// Only works in Project window
		return(NULL);

//	// Since "next" pointer is first LONG of the FastGadget,
//	// we just substitute the Address of the FG list head
//	fg = (struct ExtFastGadget *)((struct Project *)Edit->Special)->PtrPtr;

	FG = *((struct Project *)Edit->Special)->PtrPtr;

//	while (fg = (struct ExtFastGadget *)GetNextEditNode(Edit,(struct EditNode *)fg))
//	{
//		if (fg->FG.FGDiff.FGNode.Status == EN_SELECTED)
//			return(fg);
//	}

	while (FG)
	{
//		//DUMPHEXIL("FG=",(LONG)FG,"\\");
		if (FG->FGDiff.FGNode.Status == EN_SELECTED)
			return((struct ExtFastGadget *)FG);
		FG = FG->NextGadget;
	}

	return(NULL);
}


//=============================================================
// TrimToPlayWindow
//		Pare down switcher events to play only a portion of the total project
//=============================================================
static UBYTE TrimToPlayWindow(struct SeqVars *sv, struct ExtFastGadget *firstFG)
{
	struct Event	*event, *nextevent, *newevent;
	WORD		cmd;
	BOOL		killit,fromFX=FALSE;	//firstfg;
	LONG		trim;

	if ((firstFG->ObjectType==CT_FXANIM)
	||  (firstFG->ObjectType==CT_FXALGO)
	||  (firstFG->ObjectType==CT_FXILBM))
	{
		if (!IsOverlay(firstFG))
			fromFX = TRUE;									// Doing a play-from from an transition
	}
	//DUMPMSG("Trimming sequence...");

	// Walk video list and trim any unnecessary insblack flags
	for (event = (struct Event *)sv->VideoTrack.EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
//		//DUMPUDECL("t1=",event->Time," ");
//		//DUMPUDECL("t2=",sv->StartTime," ");
//		//DUMPUDECL("fl=",event->Flags2,"\\");

		// If starting right on a locked video crouton, remove black insertion before it
		if ((event->Time <= sv->StartTime) && (FLAGS2F_MATTE & event->Flags2))
		{
			event->Flags2 &= ~FLAGS2F_MATTE;
			sv->InsMattes--;			// Dec black insertion count

			//DUMPMSG("Trimmed black");
		}
	}

	// Free those out of window + any previous associated SELECTS
	// Adjust those that straddle window boundary (for types that we can do this)
	// For others, free them + prev assoc. SELECTS

//	firstfg = TRUE;

ReWalk:
	//DUMPMSG("re-walk...");

	// Walk switcher list
	for (event = (struct Event *)sv->SwitcherTrack.EventList.lh_Head
	; event->Node.mln_Succ
	; event = nextevent)
	{
		nextevent = (struct Event *)event->Node.mln_Succ;		// Get now, as we may free it

		if (FLAGS2F_MISC & event->Flags2)		// Already processed this one?
			continue;

//		// Only do this for first event in switcher track...
//		// If we start with a TOMAIN, destroy it and just punch up that channel pre-play
//		if (firstfg)
//		{
//			firstfg = FALSE;
//		}

		event->Flags2 |= FLAGS2F_MISC;			// Don't look at this one again

		//DUMPUDECL("t1=",event->Time," ");
		//DUMPUDECL("t2=",sv->StartTime," ");
		//DUMPUDECL("fl=",event->Flags2,"\\");

		if (event->Time < sv->StartTime)		// Need to maybe trim/delete?
		{ // At least partly (if not wholly) outside play window - crop or delete it
			trim = sv->StartTime - event->Time;

			killit = FALSE;

//			if (FLAGS2F_MATTE & event->Flags2)		// Matte black insertions
//			{
//				// Each Flyer channel starts out black, so we can always delete these,
//				// even if it appears we need a partial
//				killit = TRUE;
//				sv->InsMattes--;			// Dec black insertion count
//			}
//			else
			if (event->FG)							// All events except control events
			{
				cmd = event->FGCcommand;

				switch (event->FG->ObjectType)
				{
				case CT_FXCR:		// SELECT, REMOVE
					// Do all or none (if REMOVE is in play, will do a partial)

					if (cmd != FGC_SELECT)
						killit = TRUE;

					break;

				case CT_REXX:		// SELECT
					// Do all or none (test SELECT time in window!)

					killit = TRUE;

					break;

				case CT_SCROLL:
				case CT_CRAWL:
				case CT_KEYEDANIM:	// SELECT,  TAKE/TOMAIN
					// Do all or none

					if (cmd != FGC_SELECT)
						killit = TRUE;

					break;

				case CT_KEY:	// SELECT, TAKE/AUTO/TOMAIN, REMOVE/AUTO
					// Do all, partial, or none

					if (cmd != FGC_SELECT)
					{
						if ((event->Time + event->Duration) <= sv->StartTime)		// remove all?
							killit = TRUE;
						else
						{
							if (cmd != FGC_REMOVE)
							{
								event->Time += trim;
								event->Duration -= trim;	// Not used by switcher (FGC_REMOVE/AUTO)
							}
						}
					}

					break;

				case CT_FXANIM:
				case CT_FXILBM:
				case CT_FXALGO:	// SELECT, TOMAIN
					// Do all or none, whether they are transitional or non-trans

					if (cmd != FGC_SELECT)
						killit = TRUE;

					break;

				case CT_VIDEO:
				case CT_STILL:		// (Flyer SELECT) TAKE/TOMAIN
					// Do all, part, or none -- FGC's of this type always implies a cut
					// So advance cut to window start

					if ((event->Time + event->Duration) <= sv->StartTime)		// remove all?
						killit = TRUE;
					else
					{
						event->Time += trim;
						event->Duration -= trim;	// Sequencer use only
					}

					break;

				case CT_FRAMESTORE:
				case CT_VIDEOANIM:
				case CT_IMAGE:				// Cut: SELECT, TOMAIN
				case CT_MAIN:				// FX:  SELECT, fxSELECT, fxTOMAIN
					// partials

					if ((event->Time + event->Duration) <= sv->StartTime)		// remove all?
						killit = TRUE;
					else
					{
						if (fromFX)
						{
							if (FLAGS2F_FXIN & event->Flags2)
							{
								//	Insert a TOMAIN for crouton at window start time (assume FX will be deleted)
								//DUMPMSG("Inserting a cut for trimmed-out FX");

								// Get event for take's TAKE/TOMAIN
								if (newevent = GetEvent(event->FG))
								{
									newevent->FG = event->FG;
									newevent->CurrentPosition = event->CurrentPosition;										// If V1pos or V2pos
									newevent->FGCcommand = FGC_TOMAIN;
									newevent->Time = sv->StartTime;
									newevent->Duration = event->Duration - trim;
									newevent->Flags2 |= FLAGS2F_MISC;		// Don't trim this!

////								AppendToTrack(&sv->SwitcherTrack,newevent);	// Tack on end of track
									Insert(&sv->SwitcherTrack.EventList,
										(struct Node *)newevent,		// my new node to insert
										(struct Node *)event);			// AFTER this node
								}
							}
							else		// Cut to video, just move cut time to window
							{
								event->Time += trim;
								event->Duration -= trim;	// Sequencer use only
							}
						}
						else
							killit = TRUE;		// If play-from non-FX, no partials (doesn't work!)
					}

					break;
				}
			}

			if (killit)
			{
				// This remembers the Flyer channel punched up by the last switcher
				// event I remove.  I'll punch this up just prior to playing partial
				if (FLAGS1F_SETCHAN & event->Flags1)
				{
					sv->firstflychan = event->Channel;
					//DUMPUDECL("++++++++FFC = ",event->Channel,"++++++++\\");
				}

				// Kill all FGC's we can find associated with this crouton
				DeleteEventsForFG(sv,event->FG);

				goto ReWalk;
			}

		}
	}


	// Walk switcher list, adjust start times for partial play
	for (event = (struct Event *)sv->SwitcherTrack.EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		if (event->Time >= sv->StartTime)		// Completely inside play window?
			event->Time -= sv->StartTime;				// Adjust start time for partial play
	}

#ifdef	SERDEBUG
	//DUMPMSG("******** TRIMMED SWITCHER LIST ***************");

	ListTrack(&sv->SwitcherTrack,TRACK_SWITCHER);

	//DUMPMSG("******************************************");
#endif

	return(0);
}


//=============================================================
// DoWarnings
//		Warn user of any possible problems with sequence
//		(just before we play it)
//=============================================================
static BOOL DoWarnings(struct SeqVars *sv)
{
	struct Event *event;
	BOOL	litone;
	char *MPtr[3];


	/*** Warn user if sequencer detected missing (lost) croutons ***/
	if (sv->LostCroutons > 0)
	{
		sprintf(sv->scratch," Warning!  project contains %d \"lost\" crouton(s).  Project will",sv->LostCroutons);
		MPtr[0] = sv->scratch;
		MPtr[1] = " not play properly until they are replaced with good croutons.";
		MPtr[2] = " Select \"cancel\" to abort";

		// Put up warning requester, check proceed or cancel
		if (!SeqRequest(sv,MPtr,3))
		{
			// User cancelled
			return(FALSE);
		}
	}


	/*** Warn user if sequencer inserted black anywhere ***/
	if (sv->InsMattes > 0)
	{
		sprintf(sv->scratch," Warning!  Sequencer inserted black at %d place(s) ",sv->InsMattes);
		MPtr[0] = sv->scratch;
		MPtr[1] = " in this project due to locked video.";
		MPtr[2] = " Select \"cancel\" to abort and highlight each";

		// Put up warning requester, check proceed or cancel
		if (!SeqRequest(sv,MPtr,3))
		{
			// User cancelled

			litone = FALSE;

			/*** Walk thru list of events and hilite each that caused black insertion ***/
			for (event = (struct Event *)sv->VideoTrack.EventList.lh_Head
			; event->Node.mln_Succ
			; event = (struct Event *)event->Node.mln_Succ)
			{
				if ((FLAGS2F_MATTE & event->Flags2) && (event->CurrentPosition >= 0))
				{
					//DUMPUDECL("Hiliting ",event->CurrentPosition,"\\");
					// Hilite this crouton
					if (!litone)
					{
						ew_QuickSelect(sv->EditTop,event->CurrentPosition);		// First one
						ew_NavigateNodeNum(sv->EditTop,event->CurrentPosition);	// Navigates to it
						litone = TRUE;
					}
					else
						ew_MultiSelect(sv->EditTop,event->CurrentPosition);		// all others
				}
			}

			if (litone)
			{
				CurFG=NULL;		// We've really messed with hilites, so can't guarantee this
				sv->EditTop->ew_OptRender = FALSE;
				UpdateAllDisplay();
			}

			return(FALSE);
		}
	}


//	/*** Warn user if sequencer trimmed any video anywhere ***/
//	if (sv->TrimToFits > 0)
//	{
//		sprintf(sv->scratch," Warning!  Sequencer trimmed video at %d place(s) ",sv->TrimToFits);
//		MPtr[0] = sv->scratch;
//		MPtr[1] = " in this project due to locked video.";
////		MPtr[2] = " Select \"cancel\" to abort and highlight each";
//
//		// Put up warning requester, check proceed or cancel
//		if (!SeqRequest(sv,MPtr,2))
//		{
//			// User cancelled
//			return(FALSE);
//		}
//	}

	return(TRUE);
}


//=============================================================
// DeleteEventsForFG
//		Delete any events in switcher track that point to spec'd FG
//=============================================================
static void DeleteEventsForFG(struct SeqVars *sv, struct ExtFastGadget *fg)
{
	struct Event	*event, *nextevent;

	// Walk switcher list
	for (event = (struct Event *)sv->SwitcherTrack.EventList.lh_Head
	; event->Node.mln_Succ
	; event = nextevent)
	{
		nextevent = (struct Event *)event->Node.mln_Succ;		// Get now, as we may free it

		if (event->FG == fg)				// Kill this one?
		{
			Remove((struct Node *)event);					// Unlink from track
			FreeMem(event, sizeof(struct Event));		// Throw it away
		}
	}
}


//======================================================================
// HandleTransition -- do transition:
// 	video --> video
//		      --> video
// 	video -->      
//======================================================================
static BOOL HandleTransition(	struct SeqVars *sv,
										LONG cuttime,
										struct Event *V1event,			// May be NULL
										struct ExtFastGadget *FXFG,	// NULL for cut
										WORD	FXpos,
										struct Event *V2event)			// May be NULL
{
	static LONG EndOfEffect=0,EndOfPrevEffect;
	static UWORD PreviousEffect = EFFECT_TAKE;

	struct Event *event;
	struct ExtFastGadget	*V1FG,*V2FG;
	LONG	fxlen, takefld, fudge, V2end, temp, aextra=0, bextra=0;
	ULONG	error,alen,blen;
	UWORD fgc;
	WORD	V1pos,V2pos;
	BOOL	overlap;

	EndOfPrevEffect = EndOfEffect;

	V1FG = V2FG = NULL;
	V1pos = V2pos = -1;

	if (V1event)
	{
		V1FG = V1event->FG;
		V1pos = V1event->CurrentPosition;
	}

	if (V2event)
	{
		V2FG = V2event->FG;						// May be NULL for black at end of seq
		V2pos = V2event->CurrentPosition;
	}

	/***********************************/
	/*** Video/Transition/Video Code ***/
	/***********************************/

	if (FXFG)
	{
		// Need to prepare a transition, so do an AUTO  ( V1 --> V2 )
		// Must handle all three scenarios: // Black->Video, Video->Black, Video->Video


		// Get event for effect's SELECT
		if ((event = GetEvent(FXFG))==NULL)
		{
			ReportSequenceError(sv,FXFG,FXpos,SEQERR_OutOfMemory,FALSE);
			return(FALSE);
		}
		event->FG = FXFG;
		event->CurrentPosition = FXpos;
		event->FGCcommand = FGC_SELECT;
		event->Time = 0;								//as soon as possible
		AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track


		// Get event for effect's TOMAIN
		if ((event = GetEvent(FXFG))==NULL)
		{
			ReportSequenceError(sv,FXFG,FXpos,SEQERR_OutOfMemory,FALSE);
			return(FALSE);
		}
		event->FG = FXFG;
		event->CurrentPosition = FXpos;
		event->FGCcommand = FGC_TOMAIN;

		// If have V2 and it's Flyer video - set preview to Flyer output just before the AUTO
		if (V2event)
		{
			if (FLAGS1F_SETCHAN & V2event->Flags1)		// Needs us to set channel before trans?
			{
				event->Flags1 |= FLAGS1F_SETCHAN;
				event->Channel = V2event->Channel;		// Get channel assigned to it
			}
		}

		fxlen = GetNumFields(FXFG);					// Length of effect
		alen = blen = fxlen;								// Default is both sources for entire FX
		//DUMPSDECL("FX len=",fxlen,"\\");

		/*** Calculate AUTO time based on surrounding video presences ***/
		if (V1event && V2FG)			// V1 ---> V2
		{
			alen = GetAsrcLen(FXFG);
			blen = GetBsrcLen(FXFG);
//			/***** HACK! UNTIL CROUTONDEFS.a SETS THESE AS DEFAULTS!!!! *******/
//			if ((alen == 0) && (blen == 0))
//				alen = blen = 0xFFFFFFFF;
			//DUMPHEXIL("Alen=",alen," ");
			//DUMPHEXIL("Blen=",blen,"\\");

			alen = ((alen>>16) * fxlen + 0x8000) >>16;
			blen = ((blen>>16) * fxlen + 0x8000) >>16;

			//DUMPHEXIL("Aflds=",alen," ");
			//DUMPHEXIL("Bflds=",blen,"\\");

			if ((alen+blen) >= fxlen)			// Sources overlap?
			{
				//DUMPMSG("(overlap)");
				overlap = TRUE;

//				// Find offset into the effect to place the cut point
//				fxadvance = fxlen * (32767 - GetDelay(FXFG))/65534;		// SKell' old way
//				takefld = fxlen/2;													// Old default 50%

				takefld = ((GetTakeOffset(FXFG) >>16) * fxlen + 0x8000) >>16;


				//DUMPSDECL("Take@ ",takefld,"\\");

				// ***!!! This time is bogus if it's a solid ANIM because it isn't centered on
				// a cut!!! Solid ANIMs have video time!!!

				if (alen > takefld)
					aextra = alen-takefld;

				if ((fxlen-blen) < takefld)
					bextra = takefld - (fxlen-blen);

				event->Time = cuttime - takefld;		//Start early so cut point hits cuttime
			}
			else
			{
				//DUMPMSG("(non-overlap)");
				overlap = FALSE;

				// No aextra or bextra, have all we need!

				event->Time = cuttime - alen;		//Start early so A src ends on out point
				// Start V2 later, since there is some FX with no source showing
				V2event->Time += (fxlen-blen) - alen;
				cuttime = V2event->Time;			// All error checks below must know about this
			}
		}
		else if (V2FG)								/* Black --> V2 */
		{
			event->Time = cuttime;				//Start effect right at V2
		}
		else											/* V1 --> Black */
		{
			event->Time = cuttime-fxlen;		//Start effect so it ends with V1
		}

		AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

		//DUMPSDECL("Auto Effect at ",event->Time,"\\");


		/*** Check for sufficient FX/video load time ***/
		if (V1event)				// Unlimited load time if first thing in sequence
		{
			// Prevent this transition from occuring too close to previous takes/autos

			/* Allow time for this effect to load */
			switch (FXFG->ObjectType)
			{
				case	CT_FXILBM:
					fudge = ILBMPREROLLFUDGE;
					break;

				case	CT_FXANIM:
					fudge = ANIMPREROLLFUDGE;
					break;

				case	CT_FXALGO:
					fudge = FXPREROLLFUDGE;
					break;

				default:		// What other types fall to here???
					fudge = FXPREROLLFUDGE;
					break;
			}

			if (V2FG)						// Add in V2 load time if we have a V2
			{
				/* Also allow time for V2 to load/queue */
				switch (V2FG->ObjectType)
				{
					case	CT_FRAMESTORE:

// If any following ChromaFX (can't transition in VideoANIMs, Scrawls, Keys etc...)
// have a Delay of 0, then we need to add these load times also!! ****!!!

					case CT_KEY:
					case CT_FXILBM:
					case CT_FXCR:
						fudge += FRAMEPREROLLFUDGE;
						break;

					case CT_IMAGE:
						fudge += RGBPREROLLFUDGE;
						break;

					case CT_VIDEO:
					case CT_STILL:
						fudge += 0;		// Flyer runs in parallel, takes no Amiga time
						break;

					default:
						break;
				}
			}

			// Okay, we know the load time now.  Will it fit?
			if (event->Time < (EndOfPrevEffect + fudge))
			{
				//DUMPUDECL("Here's why: EndOfPrevFX=",EndOfPrevEffect," ");
				//DUMPUDECL("Fudge=",fudge," ");
				//DUMPUDECL("EventTime=",event->Time,"\\");

				if (PreviousEffect==EFFECT_TAKE)
					error = SEQERR_EffectStartsEarly;	// Effect starts too early
				else
					error = SEQERR_EffectNearEffect;		// Effect starts too soon after previous effect

				if (!ReportSequenceError(sv,FXFG,FXpos,error,TRUE))
					return(FALSE);
			}
		}

		EndOfEffect = event->Time + fxlen;		// Effect AUTO time + duration

//		Keep these to detect switcher event overlaps
		sv->SwitcherBusyTil = EndOfEffect;		// Effect takes over machine
		sv->LastSwitEvent = event;

		/*** Check if effect runs past end of V2 ***/
		if (V2event)
		{
			V2event->Flags2 |= FLAGS2F_FXIN;		// Will bring in with transition
			V2end = cuttime + GetDuration(V2FG);	// Field after the video
			if (EndOfEffect > V2end)
			{
				ReportSequenceError(sv,FXFG,FXpos,SEQERR_EffectEndsLate,FALSE);
				return(FALSE);
			}
		}

		/*** Adjust V1/V2 in/out points to provide overlap needed for effect to occur ***/
		if (V1event && V2FG)			// (Wont do this on black at end)
		{
			if (aextra>0)
			{
				aextra = ROUNDUPTOFRAME(aextra);
				//DUMPSDECL("Adding ",aextra," Aextra\\");

				// Flyer clips: Extend V1's audio outpoint (only if user enabled "auto ramp" and not split-audio)
				if (V1FG && (V1FG->ObjectType==CT_VIDEO)
				&& (GetAudioFadeFlags(V1FG) & AUDFADEF_AutoOut)
				&& ((V1event->StartField+V1event->Duration)==(V1event->AudStart+V1event->AudLength)))
				{
					V1event->AudLength += aextra;
					V1event->AudDecay = alen;			// Decay for entire A source period
				}

				// Extend V1's outpoint (round up to color frame)
				V1event->Duration = GetAdjVideoDuration(V1FG) + aextra;	//ROUNDUPTOFRAME(fxlen-fxadvance);
				PutAdjVideoDuration(V1FG, V1event->Duration);
				//DUMPUDECL("Previous duration changed to ",V1event->Duration,"\\");

				// For Flyer video clips, check to see if V1 had enough video to make overlap
				if (V1FG->ObjectType==CT_VIDEO)
				{
					//DUMPSDECL("Start@ ",V1event->StartField," ");
					//DUMPSDECL("AdjVdur=",GetAdjVideoDuration(V1FG)," ");
					//DUMPSDECL("RecFlds=",GetRecFields(V1FG),"\\");

					// Calculate how many fields short we are on trailing video
					temp = (V1event->StartField + GetAdjVideoDuration(V1FG)) - GetRecFields(V1FG);
					if (temp>0)
					{
						// Not enough trailing video. Effect ends after video
						sprintf(ErrorDetails,"   (Needs %d more frames)",temp/2);
						ReportSequenceError(sv,FXFG,FXpos,SEQERR_FXtrailingVideo,FALSE);
						return(FALSE);
					}
				}
			}

			if (bextra>0)
			{
				bextra = ROUNDUPTOFRAME(bextra);			// Do this for non-flyer video too?
				V2event->extra	= bextra;					// New added on 030196DEH
																	// keep extra on hand for audio lock

				//DUMPSDECL("Adding ",bextra," Bextra\\");

//				fxadvance = ROUNDUPTOFRAME(fxadvance);		// Do this for non-Flyer video too?

				//DUMPSDECL("V2sf ",V2event->StartField," ");
				//DUMPSDECL("V2ad ",V2event->AudStart,"\\");

				// Flyer clips: Extend V2's audio inpoint (if user enabled "auto ramp" and not split-audio)
				if ((V2FG->ObjectType==CT_VIDEO)
				&& (GetAudioFadeFlags(V2FG) & AUDFADEF_AutoIn)
				&& (V2event->StartField == V2event->AudStart))
				{
					V2event->AudStart -= bextra;
					V2event->AudLength += bextra;
					V2event->AudAttack = blen;			// Ramp up for entire B source period
					//DUMPMSG("Did it!");
				}

				// Flyer clips: extend V2's inpoint (round down to color frame)
				if (V2FG->ObjectType==CT_VIDEO)
				{
					V2event->StartField -= bextra;
					V2event->extra	= bextra;					// New added on 030196DEH
																		// keep extra on hand for audio lock
	
					PutAdjVideoStart(V2FG, V2event->StartField);

					//DUMPUDECL("InPoint changed to ",V2event->StartField,"\\");

					// Check to see if V2 had enough video to make overlap
					if ((V2event->StartField) < 0)
					{
						// Not enough leading video -- effect starts before video
						sprintf(ErrorDetails,"   (Needs %d more frames)",(-V2event->StartField)/2);
						ReportSequenceError(sv,FXFG,FXpos,SEQERR_FXleadingVideo,FALSE);
						return(FALSE);
					}
				}

				if (V2FG->ObjectType==CT_STILL)
				{
					/*** Used to make a head if V1FG->FileName & V2FG->FileName came from same drive ***/
				}

				// Start V2 earlier in sequence
				V2event->Time -= bextra;		// Could un-sort Flyer video events
				V2event->extra	= bextra;		// New added on 030196DEH
														// keep extra on hand for audio lock


				// Extend V2's duration because of the early start
				V2event->Duration = GetAdjVideoDuration(V2FG) + bextra;
				PutAdjVideoDuration(V2FG, V2event->Duration);
			}
		}
		else if (V1event && V2event)			// Make adjustments for video --> black
		{
			// Start V2 earlier in sequence
			V2event->Time -= fxlen;		// Could un-sort Flyer video events
		}

		PreviousEffect = EFFECT_TRANS;
	}

	/******************************/
	/*** Video/Video (Cut) Code ***/
	/******************************/
	else if (!sv->CutUnder)				// CutsUnder require no switcher participation
	{
		// Need to prepare a cut
		// Prevent this Take from occuring too close to previous takes/autos.
		// Allow time for this new video source to load and/or the Flyer to queue
		// Must handle all three scenarios: // Black->Video, Video->Black, Video->Video???


		// Check if V2 has sufficient load time (unlimited if no V1 -- at start of sequence)
		if (V1event && V2FG)
		{
			switch(V2FG->ObjectType)
			{
				case CT_FRAMESTORE:

				// If any following Scrolls, Crawls, KeyedANIMs, KeyedStills,
				// or ChromaFX have a Delay of 0, then we need to add these
				// load times also!! ****!!!
				case CT_FXILBM:
				case CT_FXCR:
				case CT_KEY:

					fudge = FRAMEPREROLLFUDGE;
					break;

				case CT_IMAGE:
					fudge = RGBPREROLLFUDGE;
					break;

				case CT_VIDEOANIM:
					fudge = ANIMPREROLLFUDGE;
					break;

				case CT_VIDEO:
				case CT_STILL:
					fudge = 0;				// Flyer runs in parallel to Amiga
					break;

				default:
					fudge = 0;
					break;
			}

			// Enough time to load V2?
			if (cuttime < (EndOfEffect+fudge))
			{
				// Not enough preroll time to start video
				if (!ReportSequenceError(sv,V2FG,-1,SEQERR_VideoPreroll,TRUE))
					return(FALSE);
			}
		}

//******************** DISABLE THIS CODE *****************
//// Sending out minimal 4 to 20 field Head
//// This code needs to also respect FlyerStills!
//		if ((V2FG->ObjectType==CT_VIDEO) && V1event &&
//			 (V1FG->ObjectType == CT_VIDEO) &&
//			 SameFlyerVolumes((char *)(V1FG->FileName),(char *)(V2FG->FileName)))
//		{
//			if((fxlen=GetAdjVideoDuration(V2FG))>20) fxlen=20;
//
//			vstartfld=V2event->StartField;
//			astartfld=audlength=0;
//
//			if(HasAudio(V2FG))
//			{
//				astartfld=vstartfld;
//				audlength=fxlen;
//			}
//
//			if(MakeClipHeadR((char *)V2FG->FileName, vstartfld, fxlen, astartfld, audlength))
//			{
///*?*/		error = SEQERR_CantMakeCut;	// Unable to do cut. Not enough Flyer space.
//				break;
//			}
//		}
//******************************************************

		// For rest of code, prefer V2 crouton, but use V1 if at end (no V2)
		if (V2FG == NULL)
		{
			V2FG = V1FG;
			V2pos = V1pos;
			fgc = FGC_TAKE;
		}
		else
			fgc = FGC_TOMAIN;

		// Get event for take's TAKE/TOMAIN
		if ((event = GetEvent(V2FG))==NULL)
		{
			// Hilite V2 crouton (unless at end, then hilite V1)
			ReportSequenceError(sv,V2FG,V2pos,SEQERR_OutOfMemory,FALSE);	// hilites V1 or V2
			return(FALSE);
		}
		event->FG = V2FG;															// Is V1FG or V2FG
		event->CurrentPosition = V2pos;										// If V1pos or V2pos
		event->FGCcommand = fgc;
		event->Time = cuttime;
		event->Duration = 0;

		// Setup preview to Flyer input just before the TAKE
		if (V2event)
		{
			event->Duration = V2event->Duration;		// For sequencing use

			if (FLAGS1F_SETCHAN & V2event->Flags1)		// Needs us to set channel before cut?
			{
				event->Flags1 |= FLAGS1F_SETCHAN;
				event->Channel = V2event->Channel;		// Get channel assigned to it
			}
		}

		AppendToTrack(&sv->SwitcherTrack,event);	// Tack on end of track

		//DUMPSDECL("Take VIDEO at ",event->Time,"\\");

		EndOfEffect = cuttime;
		PreviousEffect = EFFECT_TAKE;
	}

	return(TRUE);
}


//======================================================================
// MaybeInsertBlack -- Handle gaps between video
//======================================================================
static BOOL MaybeInsertBlack(struct SeqVars *sv,
										struct Event *V1event,			// May be NULL???
										LONG	time)
{
	struct ExtFastGadget	*V1FG;
	struct Event *event;
	LONG	endofprev,overlap;
	UWORD error;
	char *MPtr[3];
	BOOL	fixit;

	V1FG = (V1event ? V1event->FG : NULL);

	endofprev = V1event->Time + V1event->Duration;

	error = 0;

	// Need black inserted here?
	if (endofprev < time)
	{
		//DUMPMSG("Need to insert black here");

		if ((V1FG) && ((V1FG->ObjectType==CT_VIDEO) || (V1FG->ObjectType==CT_STILL)))
		{
			// Tack black onto end of previous clip (same channel)
			AppendBlack(sv,endofprev,1 - sv->FlyChan);
		}
		else
		{
			// Create a black still on next Flyer channel (switch next time)
			event = CreateBlack(sv,endofprev,sv->FlyChan);
			if (!event)
				error = SYSERR_CantCreateBlack;
			else
			{

				sv->FlyChan = 1 - sv->FlyChan;

				if (!HandleTransition(
					sv,
					endofprev,				// CutTime
					V1event,			// V1
//					(PreviousTrack==CRTN_TRANS) ? PreviousFG:NULL,	// FXFG (NULL for cut)
					NULL,
//					PreviousPos,			// FXpos
					-1,
					event))					// V2 (has no FG associated with it!)
				{
					return(FALSE);
				}
			}
		}
		if (error)
			ReportSequenceError(sv,V1FG,-1,error,FALSE);		// May/may not hilite a crouton

	}
	else if (V1event->Time > time)	// Video croutons out of order?
	{
		ReportSequenceError(sv,V1FG,V1event->CurrentPosition,SEQERR_OutOfOrder,FALSE);
		return(FALSE);		// Abort!
	}
	else if (endofprev > time)			// Need to trim previous event to fit?
	{
		overlap = endofprev - time;

		fixit = FALSE;

		if (V1FG)
		{
			ew_QuickSelect(sv->EditTop,V1event->CurrentPosition);			// Hilite offender
			ew_NavigateNodeNum(sv->EditTop,V1event->CurrentPosition);	// Navigates to it

//	Need these???
			sv->EditTop->ew_OptRender = FALSE;
			UpdateAllDisplay();
			CurFG=(struct FastGadget *)V1FG;			// Keep this current!

			MPtr[0] =           " This crouton overlaps the following locked video";
			sprintf(sv->scratch," by %d frames.  Select \"okay\" for me to fix this",overlap/2);
			MPtr[1] = sv->scratch;
//			MPtr[2] =           " or \"cancel\" to leave it alone";
			MPtr[2] =           " or \"cancel\" to abort";

			// Put up warning requester, check fix or not
			if (SeqRequest(sv,MPtr,3))
				fixit = TRUE;
			else
				return(FALSE);		// Abort!
		}

		V1event->Duration -= overlap;									// Fix this build
		if (fixit)
		{
			if (V1event->Duration > 0)
			{
				PutDuration(V1FG,V1event->Duration);					// Permanent fix
				PutAdjVideoDuration(V1FG,V1event->Duration);			// Permanent fix
			}
			else
			{
				// Fail to fix, fail to play!
				DisplayNormalSprite();
				ContinueRequest(sv->EditTop->Window,"Cannot trim clip enough to fix this overlap");
				return(FALSE);		// Abort!
			}
		}

		// Now check natural audio portion
		if ((V1FG) && (V1FG->ObjectType==CT_VIDEO) && (HasAudio(V1FG)))
		{
			endofprev = V1event->Time+V1event->AudStart-V1event->StartField+V1event->AudLength;
			overlap = endofprev - time;
			if (overlap > 0)
			{
				V1event->AudLength -= overlap;						// Fix this build
				if (fixit)
					PutAudioDuration(V1FG,V1event->AudLength);	// Permanent fix
			}
//	time - (V1event->Time + V1event->AudStart - V1event->StartField);
//
//	sv->TrimToFits++;										// Should we warn?

		}
	}

	return(TRUE);
}


//======================================================================
// CreateBlack -- Create black video still event
//======================================================================
static struct Event *CreateBlack(	struct SeqVars *sv,
												LONG	time,
												WORD	flychan)
{
	struct Event *event = NULL;

	if (FlyerBase)							// Have Flyer do black matte
	{
		// Get event for video SELECT
		if ((event = GetEvent(NULL))==NULL)
		{
			ReportSequenceError(sv,NULL,-1,SEQERR_OutOfMemory,FALSE);	// No crouton to hilite
			return(NULL);
		}

		//DUMPMSG("--- Creating Black ---");

		event->FG = NULL;								// No crouton!
		event->CurrentPosition = sv->Pos;		// Crouton near here to hilite
		event->FGCcommand = FGC_SELECT;
		event->Time = time;
		event->Duration = 0;							// Signify black matte
		event->StartField = 0;
		event->Channel = flychan;					// Channel to use
		event->Flags1 = FLAGS1F_SETCHAN;			// Flyer needs channels set
		event->Flags2 = FLAGS2F_MATTE;			// Seq created this

		SortIntoTrack(&sv->VideoTrack,event);		// Tack on end of Flyer video track
	}
	else
	{
		// Need to have toaster do black on non-Flyer systems!!!
	}

	sv->InsMattes++;			// Bump black insertion count

	return(event);
}


//======================================================================
// AppendBlack -- append black video to end of video event
//======================================================================
static UBYTE AppendBlack(	struct SeqVars *sv,
									LONG	time,
									WORD	flychan)
{
	struct Event	*event;

	event = CreateBlack(sv,time,flychan);
	if (event)
		return(SEQERR_Okay);
	else
		return(SYSERR_CantCreateBlack);
}


//======================================================================
// HandlePlay
//		Wrapper for DoSeqPlay() so that Shift will do play from any point
//======================================================================
struct EditWindow *HandlePlay(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
//	struct EditWindow *RetEdit;
	struct ExtFastGadget *firstFG;
	struct SeqVars sv;

	//DUMPMSG("---HandlePlay---");

	StopLiveEditing(TRUE);			// If still editing to music/video, wrap it up!

	if (EditTop->Node.Type != EW_PROJECT)
	{
		//DUMPMSG("Improper view to play seq");
		return(Edit);
	}

	// Setup SeqVars structure
	memset(&sv, 0, sizeof(struct SeqVars));
//	sv.Edit = Edit;
	sv.EditTop = EditTop;

//	//DUMPHEXIL("Edit=",(LONG)Edit,"  ");
//	//DUMPHEXIL("EditTop=",(LONG)EditTop,"\\");

	sv.cut2music = sv.partial = FALSE;			// Assume (normal) play entire sequence

	/* If no CurFG hilited, skip all this logic, just act like PLAY */
	/* ARexx "Play project" doesn't provide an IntuiMsg, so it acts like PLAY too */
	if (IntuiMsg)
	{
		sv.waitplaystart = TRUE;		// Not from ARexx, so wait for ENTER on "ready" panel

		//DUMPHEXIL("Qual = ",IntuiMsg->Qualifier,"\\");

		// SHIFT indicates "play-from"
		if (IntuiMsg->Qualifier&(IEQUALIFIER_LSHIFT|IEQUALIFIER_RSHIFT))
			sv.partial = TRUE;

		// ALT indicates "edit-to-music" (ALT+SHIFT for edit-to-music-from)
		if (IntuiMsg->Qualifier&(IEQUALIFIER_LALT|IEQUALIFIER_RALT))
			sv.cut2music = TRUE;

		// If clicked on a button (as opposed to hot-keys), override SHIFT key status
		if ((IntuiMsg->Class == IDCMP_GADGETUP) || (IntuiMsg->Class == IDCMP_GADGETDOWN))
		{
			//DUMPMSG("(Button)");

			if (((struct Gadget *)IntuiMsg->IAddress)->GadgetID == ID_PLAY_PART)
				sv.partial = TRUE;
			else
				sv.partial = FALSE;
		}
	}

	if (CurFG==NULL)			// If no crouton is highlited, do a full play anyway
		sv.partial = FALSE;

	//DUMPUDECB("Partial = ",sv.partial," ");
	//DUMPUDECB("Cut2Music = ",sv.cut2music,"\\");

	// Is this really necessary? Just trims off part of sequence before stop/reset croutons
	// If not, is equivalent to *PtrProject -- (SeqStartFG might be NULL if none)
	SeqStartFG = StartingSequenceEvent((struct ExtFastGadget *)CurFG);

	if (sv.partial)
		firstFG = (struct ExtFastGadget *)CurFG;
	else
		firstFG = SeqStartFG;

	//DUMPMSG("HandlePlay ---------------------------");
	//DUMPHEXIL("CurFG=",(LONG)CurFG,"\\");
	//DUMPHEXIL("SeqStartFG=",(LONG)SeqStartFG,"\\");
	//DUMPHEXIL("FirstFG=",(LONG)firstFG,"\\");


	Edit->ew_OptRender = TRUE;    // ???

//	// Calculate times to clip our play within (SeqStartFG = time 0)
//	if (sv.partial)
//		sv.StartTime = TimeBetweenFGs(SeqStartFG, firstFG);
//	else
//		sv.StartTime = 0;
//	sv.EndTime = 0x7FFFFFFF;		// Don't clip end times
//
//	//DUMPUDECL ("starttime = ",sv.StartTime,"\\");
//	//DUMPUDECL ("endtime = ",sv.EndTime,"\\");
//


//	/*** Calculate total running time from start crouton to end ***/
//	sv.SeqTotalTime = TimeBetweenFGs(SeqStartFG,NULL);
//	sv.SeqPlayTime = sv.SeqTotalTime - sv.StartTime;

	/*** Setup and clear all tracks ***/
	PrepareTrack(&sv.SwitcherTrack,TRACK_SWITCHER);  //doing NewList, ect.
	PrepareTrack(&sv.VideoTrack,TRACK_FLYVID);
	PrepareTrack(&sv.AudioTrack,TRACK_AUDIO);

	if (sv.partial && sv.cut2music)			// Cutting to music? (1 clip version)
	{
		MusicBaseTime = TimeBetweenFGs(SeqStartFG, firstFG);

		//DUMPUDECL ("MusicBaseTime(1) = ",MusicBaseTime,"\\");

		EditToClip(&sv, firstFG);
	}
	else if (BuildSeq(&sv,SeqStartFG))		// Build entire project
	{
		// Calculate times to clip our play within (SeqStartFG = time 0)
		if (sv.partial)
			sv.StartTime = FindCroutonStartTime(&sv, firstFG);
		else
			sv.StartTime = 0;
		sv.EndTime = 0x7FFFFFFF;		// Don't clip end times

		//DUMPUDECL ("starttime = ",sv.StartTime,"\\");
		//DUMPUDECL ("endtime = ",sv.EndTime,"\\");

		/*** Calculate actual running time to end ***/
		sv.SeqPlayTime = sv.SeqTotalTime - sv.StartTime;

		SetRunningTime(sv.SeqPlayTime);				// Put total time up (of part to play)

		if (sv.partial)
			TrimToPlayWindow(&sv,firstFG);			// Play-from stripping

		if (!sv.cut2music)
		{
			if (DoWarnings(&sv))
				PlayCurSeq(&sv);

			DisplayMessage(NULL);			// Remove any message at top of screen
		}
		else
		{
			EditToAllAudio(&sv);
		}
	}

	//DUMPMSG("Before FreeMems");

	FreeTrack(&sv.SwitcherTrack);
	FreeTrack(&sv.VideoTrack);
	FreeTrack(&sv.AudioTrack);

	//DUMPMSG("After FreeMems");

	DisplayNormalSprite();

	return(Edit);
}


////*******************************************************************
//BOOL DriveType(char *name1)
//{
////	UBYTE *OurFlyerDrives;
//
//	return(TRUE);
//}


//=============================================================
//=============================================================
struct EditWindow *HandleRewind(	struct EditWindow *Edit,
											struct IntuiMessage *IntuiMsg)
{
	return(Edit);
}

//=============================================================
//=============================================================
struct EditWindow *HandleStop(	struct EditWindow *Edit,
											struct IntuiMessage *IntuiMsg)
{
	WORD	qual;

	//DUMPMSG("HandleStop()");

	if (IntuiMsg)
		qual = IntuiMsg->Qualifier;
	else
		qual = 0;

	if (FlyerBase
	&& (qual & IEQUALIFIER_CONTROL)
	&& (qual & IEQUALIFIER_LSHIFT)
	&& (qual & IEQUALIFIER_LALT))
		RebootFlyer();
	else if (FlyerBase && (qual & IEQUALIFIER_CONTROL))
		ResetFlyer(0,1);		// A more serious reset
	else
	{
		//DUMPMSG("Before HandleStop() sends ES_Stop");
		SendSwitcherReply(ES_Stop,NULL);	//clr bit 4 of TB_DisplayRenderMode
		//DUMPMSG("  After HandleStop() sent ES_Stop");

		StopLiveEditing(FALSE);			// Handle wrap-up after editing to music/video
	}

	return(Edit);
}


void StopLiveEditing(BOOL dostop)
{
	if (EditingLive)
	{
		if (dostop)
			SendSwitcherReply(ES_Stop,NULL);	//clr bit 4 of TB_DisplayRenderMode

		EditTo_FollowUp(EditTop);		// Patch things up (optional)

		EditingLive = FALSE;

		DisplayMessage(NULL);			// Refresh access window
	}
}



//=============================================================
// PrepareTrack
//		Prepare track structure
//=============================================================
static void PrepareTrack(	struct Track *track,
									UBYTE tracktype)
{
	//DUMPUDECB("Preparing track type ",tracktype,"\\");

	track->EventCount = 0;

	NewList(&track->EventList);		// Clear list
}


//=============================================================
// FreeTrack
//		Free all resources associated with the specified track
//=============================================================
static void FreeTrack(struct Track *track)
{
	struct Event	*event;

	while (event = (struct Event *)RemHead(&track->EventList))
	{
		FreeMem(event, sizeof(struct Event));
	}

	track->EventCount = 0;
}


#ifdef	SERDEBUG

//=============================================================
// ListTrack
//		//DUMP contents of track (debugging only)
//=============================================================
static void ListTrack(struct Track *track, UBYTE tracktype)
{
	struct Event	*event;

	//DUMPMSG("******************************************");
	switch (tracktype)
	{
	case TRACK_SWITCHER:
		//DUMPMSG("Switcher Track ==============================");
		break;
	case TRACK_FLYVID:
		//DUMPMSG("Video Track ==============================");
		break;
	case TRACK_AUDIO:
		//DUMPMSG("Audio Track ==============================");
		break;
	}

	for (event = (struct Event *)track->EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		if (event->FG)
			DUMPUDECB("#",(UBYTE)(event->CurrentPosition)," ");
		else if (FLAGS1F_WAIT4TIME & event->Flags1)
			DUMPSTR("Wait ");
		else
			DUMPUDECB("Black>>> [",event->Channel,"] ");
//			//DUMPSTR("Black>>> ");

		//DUMPUDECW("t=",event->Time," ");

		if (event->FG)
		{
			switch (event->FGCcommand)
			{
				case FGC_TAKE:		DUMPSTR("TAKE");	break;
				case FGC_SELECT:	DUMPSTR("SEL ");	break;
				case FGC_TOMAIN:	DUMPSTR("TOMN");	break;
				case FGC_AUTO:		DUMPSTR("AUTO");	break;
				case FGC_REMOVE:	DUMPSTR("REMV");	break;
				case FGC_REMOVEQ:	DUMPSTR("REMQ");	break;
				case FGC_TOPRVW:	DUMPSTR("PRVW");	break;
				default:				DUMPSTR("????");	break;
			}
			if (FLAGS1F_SETCHAN & event->Flags1)
				DUMPUDECB(" (",event->Channel,") ");
			else if (tracktype==TRACK_FLYVID)
				DUMPUDECB(" [",event->Channel,"] ");
			else
				DUMPSTR("       ");

//			DUMPUDECB("FGC=",event->FGCcommand," ");
			DUMPUDECW("Fld=",(UWORD)(event->StartField)," ");
			DUMPUDECW("Dur=",(UWORD)(event->Duration)," ");
			DUMPSTR(event->FG->FileName);

			//if (tracktype == TRACK_FLYVID)
			//{
				DUMPMSG(" ");
				DUMPUDECW("AFld=",(UWORD)(event->AudStart)," ");
				DUMPUDECW("ADur=",(UWORD)(event->AudLength)," ");
				DUMPUDECW("Atk=",event->AudAttack," ");
				DUMPUDECW("Dcy=",event->AudDecay," ");
			//}
		}

//		if (FLAGS1F_SETCHAN & event->Flags1)
//			DUMPUDECB(" Chan=",event->Channel," ");

		if (FLAGS2F_SKIP & event->Flags2)
			DUMPSTR("(SKIP!) ");

		DUMPMSG(" ");
	}
}
#endif


//=============================================================
// GetEvent
//		Allocate an event structure
//=============================================================
static struct Event * GetEvent(struct ExtFastGadget *FG)
{
	struct Event *event;

	DUMPMSG("GetEvent");

	event = SafeAllocMem(sizeof(struct Event),MEMF_CLEAR);		// Try to allocate

	if (event)
	{
//Don't have to skip yet, because I don't process "lost" croutons now (will I ever??)
//		if (FG && (FG->ObjectType == CT_ERROR))		// This is for a "lost crouton"?
//			event->Flags2 |= FLAGS2F_SKIP;	// If so, do not actually play this
	}
	else		// Failed
	{
		DUMPMSG("No mem for event!");
	}

	return(event);
}


//=============================================================
// SortIntoTrack
//		Sort new event into track, based on start times
//=============================================================
static void SortIntoTrack(struct Track *track, struct Event *newevent)
{
	struct Event	*event,*prev;

	DUMPMSG("SortIntoTrack");

	prev = NULL;

	for (event = (struct Event *)track->EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		if (newevent->Time < event->Time)
			break;

		prev = event;
	}

	// Insert new event just after 'prev' that was found
	Insert(&track->EventList, (struct Node *)newevent, (struct Node *)prev);

	track->EventCount++;
}


//=============================================================
// AppendToTrack
//		Tack event onto end of track
//=============================================================
static void AppendToTrack(struct Track *track, struct Event *newevent)
{
	DUMPMSG("AppendToTrack");

	AddTail(&track->EventList, (struct Node *)newevent);

	track->EventCount++;
}


//=============================================================
// AppendSelect
//		Tack SELECT event onto end of track, with possible
//		insertion before previous last event
//=============================================================
static BYTE AppendSelect(struct Track *track, struct Event *newevent)
{
	struct Event	*event;
	BYTE	setchan=-1;

	DUMPMSG("AppendSelect");

//	AddTail(&track->EventList, (struct Node *)newevent);
//
//	track->EventCount++;

	event = (struct Event *)RemTail(&track->EventList);
	if (event)
	{
		// Must only replace a TOMAIN on a Flyer event
		if ((event->FGCcommand == FGC_TOMAIN) && (FLAGS1F_SETCHAN & event->Flags1))
		{
			track->EventCount--;				// Killed previous event
			setchan = event->Channel;		// Get channel to take to
			FreeMem(event, sizeof(struct Event));
		}
		else
		{
			// Oops! Add back in
			AddTail(&track->EventList, (struct Node *)event);
		}
	}

//	if (setchan >= 0)
//	{
//		newevent->Channel = setchan;
//		newevent->Flags1 |= FLAGS1F_SETCHAN;
//	}

	AppendToTrack(track,newevent);

	return(setchan);
}


//=============================================================
// InsertSelect
//		Insert  a SELECT event before the last event, if possible
//		The last event must qualify for this type of action
//=============================================================
static void InsertSelect(struct Track *track, struct Event *newevent)
{
	struct Event	*event;

	DUMPMSG("InsertSelect");

	event = (struct Event *)RemTail(&track->EventList);	// Remove specimen
	if (event)
	{
		// Must only insert before a TOMAIN on a Flyer event
		if ((event->FGCcommand == FGC_TOMAIN) && (FLAGS1F_SETCHAN & event->Flags1))
		{
			// Okay, it's removed (temporily only, as the event count is wrong)
		}
		else
		{
			// Oops! Add back in
			AddTail(&track->EventList, (struct Node *)event);
			event = NULL;						// (Don't add back in again later)
		}
	}

	AppendToTrack(track,newevent);		// Tack on our new one

	if (event)
		AddTail(&track->EventList, (struct Node *)event);	// Add prev tail back in, if removed
}


//=============================================================
// DoAudioCrouton
//		Process audio crouton into audio track
//=============================================================
static struct Event * DoAudioCrouton(	struct SeqVars *sv,
													struct ExtFastGadget *fg,
													LONG	gotime,
													WORD	croutonpos)
{
	struct Event *event;
	LONG	astartfld, audlength;

	DUMPMSG("DoAudioCrouton");

	event = NULL;

	astartfld = GetAudioStart(fg);
	audlength = GetAudioDuration(fg);

	// Any audio that we should play?
	if (audlength > 0)
	{
// Don't do this test. This lets them replace a clip.  If new one is too short, Flyer will
// complain on download and then we can put up an error
//		if(!(ci=DHD_ClipInfo((char *)fg->FileName)) || (ci->Fields != GetValue((struct FastGadget *)fg,TAG(RecFields))))
//		{
//			error = SEQERR_FlyerClipMissing;				// File not found!
//			break;
//		}

		event = GetEvent(fg);
		if (event)							// Allocation succeeded?
		{
			event->FG = fg;
			event->Time = gotime;		// When to roll
			event->StartField	= event->AudStart		= astartfld;		// First field to hear
			event->Duration	= event->AudLength	= audlength;		// Duration
			event->FGCcommand = FGC_SELECT;
			event->CurrentPosition = croutonpos;
			event->TimeTolerance = 0;					// Do it perfect!

			SortIntoTrack(&sv->AudioTrack,event);	// Sort by time into track
		}
		else
		{
		
			DUMPMSG("Out of space in audio track!");
			fg = fg;
		}
	}

	return(event);
}


//=============================================================
// DownLoadFlyer
//		Download Flyer track to Flyer sequencer
//		Also skips/trims events to desired play window
//=============================================================
static ULONG DownLoadFlyerTrack(	struct SeqVars *sv,
											struct Track *track,
											UBYTE tracktype,
											BOOL abortable)
{
	struct FlyerVolume volume;
	struct ClipAction	 action;
	struct Event	*event;
	struct ExtFastGadget *fg;
	ULONG	audiobits,err,userID;
	LONG	gotime,trim,len;
	BOOL	first;

	err = FERR_OKAY;

	first = TRUE;

	userID = (tracktype==TRACK_AUDIO)?0x8000:0;

	for (event = (struct Event *)track->EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		userID++;

		if (abortable)
		{
			if (CheckNoticeCancel())		// If CANCEL button pressed...
				return(FERR_ABORTED);
		}

		if (FLAGS2F_SKIP & event->Flags2)	// Skip a "lost crouton"?
			continue;

		fg = event->FG;
		if (fg)
		{
			// Note channel of first video event (used for playback preparation)
			if (first)
			{
				// Remember Flyer channel of first clip downloaded
				// Don't do this for partial (play-from), as logic
				// that trims Switcher list will figure this better
				if ((tracktype == TRACK_FLYVID) && (!sv->partial))
					sv->firstflychan = event->Channel;
				first = FALSE;
			}

			volume.Board = 0;
			volume.Flags = 0;			// Not FVF_USENUMS, since we don't know drive numbers !
			volume.SCSIdrive = 0;	// We let Flyer worry about silly things like drive #'s
			volume.Path = fg->FileName;		// Name of Flyer file

			// Clear all fields of this structure
			memset(&action, 0, sizeof(struct ClipAction));

			action.UserID = userID;			// Shows us who failed for sequencing errors
			action.GoClock = event->Time;			// Time to start
			action.Channel = event->Channel;		// Video channel (NC for audio at this time)

//			action.PermissFlags = /* CAPF_STEALOURVIDEO | */ CAPF_KILLOTHERVIDEO | CAPF_USEHEADS;

			action.Flags = 0;							// Default flags

			if (tracktype == TRACK_FLYVID)
			{
				action.Flags |= CAF_VIDEO;
//				action.Flags |= CAF_USEMATTE;
			}

			audiobits = GetAudioOn(fg);

			// Left audio active?
			if ((AUDF_Channel1Recorded & audiobits)
			&&  (AUDF_Channel1Enabled & audiobits)) 
			{
				action.Flags |= CAF_AUDIOL;
				action.VolSust1 = GetAudioVolume1(fg);
				action.AudioPan1 = GetAudioPan1(fg);
			}

			// Right audio active?
			if ((AUDF_Channel2Recorded & audiobits)
			&&  (AUDF_Channel2Enabled & audiobits)) 
			{
				action.Flags |= CAF_AUDIOR;
				action.VolSust2 = GetAudioVolume2(fg);
				action.AudioPan2 = GetAudioPan2(fg);
			}

			// Use audio envelope?
			if (AUDF_AudEnvEnabled & audiobits)
				action.Flags |= CAF_AUDENV;
         else
				action.Flags &= ~CAF_AUDENV;
             
   

			if (fg->ObjectType == CT_STILL)
			{
				action.VidStartField = 0;
				action.VidFieldCount = 4;
			}
			else
			{
				action.VidStartField = event->StartField;
				action.VidFieldCount = event->Duration;
			}
			action.AudStartField = event->AudStart;
			action.AudFieldCount = event->AudLength;

//			action.VolAttack = GetAudioAttack(fg);
//			action.VolDecay  = GetAudioDecay(fg);

			action.VolAttack = event->AudAttack;
			action.VolDecay  = event->AudDecay;

//~~~~~~~~~~~~~~~~~~ Trim to Play Window ~~~~~~~~~~~~~~~~~~~~~

			/**********************/
			/*** Audio Trimming ***/
			/**********************/
			if ((CAF_AUDIOL | CAF_AUDIOR) & action.Flags)
			{
				gotime = action.GoClock;

				// If video w/natural audio, get gotime of audio portion
				if (tracktype == TRACK_FLYVID)
					gotime += action.AudStartField-action.VidStartField;

				if ((gotime+action.AudFieldCount) <= sv->StartTime)		// Trim off all?
				{
					action.Flags &= ~(CAF_AUDIOL | CAF_AUDIOR);				// (no audio)
				}
				else if (gotime < sv->StartTime)									// Trim some?
				{
					trim = sv->StartTime - gotime;							// Amount to trim off

					action.AudStartField += trim;								// crop audio to starttime

					len = action.AudFieldCount;
					len -= trim;													// Shorten duration

					if (len <= 0)													// Trimmed away everything?
						action.Flags &= ~(CAF_AUDIOL | CAF_AUDIOR);		// (no audio)
					else
					{
						action.AudFieldCount = len;							// Save shortened

						if (tracktype == TRACK_AUDIO)
							action.GoClock = sv->StartTime;		// Audio: Start immediately
																			// Video: don't adjust start time

						// Adjust attack ramp for trimmed audio
						if (trim < action.VolAttack)				// Do partial ramp?
						{
#ifdef FLYER_PARTIAL_ATTACKS
							// We need audio envelope key frames for this to work!!!

							// Start volumes part way up ramp so we end at correct time
							action.VolStart1 = (action.VolSust1 * trim) / action.VolAttack;
							action.VolStart2 = (action.VolSust2 * trim) / action.VolAttack;
#endif

							action.VolAttack -= trim;			// Shorten ramp to end at correct time
						}
						else
						{
							action.VolAttack = 0;		// Trimmed all of ramp away
						}

						// Adjust VolDecay for trimmed audio
						if (len < action.VolDecay)				// Need to adjust decay ramp?
						{
							// Start volumes part way down ramp so we end at correct time
							action.VolSust1 = (action.VolSust1 * len) / action.VolDecay;
							action.VolSust2 = (action.VolSust2 * len) / action.VolDecay;
							action.VolDecay = len;
						}
					}
				}
			}


			/**********************/
			/*** Video Trimming ***/
			/**********************/
			if (CAF_VIDEO & action.Flags)
			{
				gotime = action.GoClock;

				if ((gotime+action.VidFieldCount) <= sv->StartTime)		// Trim off all?
				{
					action.Flags &= ~CAF_VIDEO;									// (no video)

					// In case natural audio does not get trimmed out, bump goclock to
					// be correct for audio-only handling (start time for audio)
					action.GoClock += (action.AudStartField - action.VidStartField);
				}
				else if (gotime < sv->StartTime)									// Trim some?
				{
					trim = sv->StartTime - gotime;								// Amount to trim off

					action.VidStartField += trim;								// crop video to starttime

					len = action.VidFieldCount;
					len -= trim;													// Shorten duration

					if (len <= 0)													// Trimmed away everything
						action.Flags &= ~CAF_VIDEO;							// (no video)
					else
					{
						action.VidFieldCount = len;							// Save shortened

						action.GoClock = sv->StartTime;						// Start immediately
					}
				}
			}


			// Now adjust start time for partial plays
			action.GoClock -= sv->StartTime;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			// I will probably not use these anymore, but just in case
			action.TotalAudStart  = action.AudStartField;
			action.TotalAudLength = action.AudFieldCount;

			action.Volume = &volume;			// Link together
			action.ReturnTime = RT_STOPPED;
 
			// If still has audio and/or video, download it.  Otherwise, skip it
			if ((CAF_VIDEO | CAF_AUDIOL | CAF_AUDIOR) & action.Flags)
			{
				err = AddSeqClip(&action);
				DUMPUDECL("audiobits ",audiobits," \\");
				
   			//? what about the audio on env bit?
				if ((event->AE.Flags & 1) && (audiobits&AUDF_AudEnvEnabled))  //replace the 1 with the flag value when it get codedDEH!
				{
					err = SendEnvs2Clip(&(event->AE),event);
					DUMPUDECL("SendEnvs2Clip error ",err," \\");//DEH Need to send the audio envelope here!
				}
			}
			else
				err = FERR_OKAY;
		}
		else		// No FG, so must be black still
		{
			volume.Board = 0;
			volume.Flags = 0;
			volume.SCSIdrive = 0;
			volume.Path = NULL;		// No clip, just black

			// Clear all fields of this structure
			memset(&action, 0, sizeof(struct ClipAction));

			action.GoClock = event->Time;			// Time to start

			action.Channel = event->Channel;		// Video channel (NC for audio at this time)

			action.Flags = 0;							// Default flags

			if (tracktype == TRACK_FLYVID)
				action.Flags |= CAF_VIDEO;

			action.VidStartField = event->StartField;
			action.VidFieldCount = event->Duration;

			action.Volume = &volume;			// Link together
			action.ReturnTime = RT_STOPPED;

			// If in trim window, go ahead and download it
			if (action.GoClock >= sv->StartTime)
			{
				action.GoClock -= sv->StartTime;		// Adjust start time for partial plays
				err = AddSeqClip(&action);
				//DEH Dont Need to send the Audio envelope here this is just black filler.
			}
			else
				err = FERR_OKAY;
		}

		if (err != FERR_OKAY)
		{
			DUMPUDECL("AddSeq error ",err," ");
			DUMPUDECL("on event ",event->CurrentPosition,"\\");
			sv->FailFG = fg;		// Might be of interest to caller (where we failed)
			break;
		}
	}

	return(err);
}


//============================================================
// Send Audio envelope keys to flyer. 
//  	calls flyer.library/AddAudEKey(AUDEKEY)
//============================================================
SendEnvs2Clip(struct AudioEnv *aude,struct Event *EnvEvent)
{
	int err;

	UWORD i;
	LONG	TOffset;
	struct AEKey      *Akey;
   struct AudioEnv   *AudEnv;



		
	if (AudEnv = AllocMem(sizeof(struct AudioEnv),MEMF_PUBLIC|MEMF_CLEAR))
	{

		
		memcpy(AudEnv,aude,sizeof(struct AudioEnv));

		TOffset = EnvEvent->Time - AudEnv->AEKeys[0].GoTime;		


		// Adjust for start time 
		for(i=0;(i<AudEnv->Keysused);i++)
		{

			DUMPUDECW("\\Key #          = ",i,"\\");
			DUMPUDECW("Current pos    = ",EnvEvent->CurrentPosition,"\\");
			DUMPUDECL("aude.GoTimeA   = ",AudEnv->AEKeys[i].GoTime,"\\");
			AudEnv->AEKeys[i].GoTime += TOffset;
			DUMPUDECL("aude.GoTimeB   = ",AudEnv->AEKeys[i].GoTime,"\\");
			DUMPUDECL("aude.NumOfFlds = ",AudEnv->AEKeys[i].NumOfFlds,"\\");
			DUMPUDECL("Time           = ",EnvEvent->Time,"\\");
			DUMPUDECL("AudStart       = ",EnvEvent->AudStart,"\\");
			DUMPUDECL("AudLength      = ",EnvEvent->AudLength,"\\");
			DUMPUDECL("StartField     = ",EnvEvent->StartField,"\\");
			DUMPUDECL("Duration       = ",EnvEvent->Duration,"\\");
			DUMPUDECL("Extra          = ",EnvEvent->extra,"\\");
			AudEnv->AEKeys[i].GoTime += EnvEvent->extra;
			DUMPUDECL("aude.GoTimeC   = ",AudEnv->AEKeys[i].GoTime,"\\ \\");


		}

		err=AddAudEnv(0,AudEnv);

		FreeMem(AudEnv,sizeof(struct AudioEnv));	

	}

	return(err);
}


//	DUMPUDECW("Keys used ",aude->Keysused,"\\");
//	DUMPUDECW("AEI->AEKeys[1].VOL1",aude->AEKeys[1].VOL1,"\\");
//	DUMPUDECW("AEI->AEKeys[2].VOL1",aude->AEKeys[2].VOL1,"\\");
//	if(aude->Keysused>0)
//		for(i=1;(i<=aude->Keysused);i++)
//		{
//			err = AddAudEKey(&(aude->AEKeys[i]));
//			if (err) break;
//   	}




//=============================================================
// FindFlyerEventFromID
//		De-reference a Flyer event from the "UserID" sent to
//		the Flyer during download
//=============================================================
static struct Event *FindFlyerEventFromID(struct SeqVars *sv, ULONG userID)
{
	struct Event	*event;
	struct Track	*track;
	ULONG	ID;


	track = &sv->VideoTrack;
	ID = 0;

	for (event = (struct Event *)track->EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		ID++;

		if (ID == userID)
			return(event);
	}

	track = &sv->AudioTrack;
	ID = 0x8000;

	for (event = (struct Event *)track->EventList.lh_Head
	; event->Node.mln_Succ
	; event = (struct Event *)event->Node.mln_Succ)
	{
		ID++;

		if (ID == userID)
			return(event);
	}

	return(NULL);
}


//*********** Error Help Subroutines **************//

static BOOL DetectSwitcherCollision(struct SeqVars *sv, LONG time)
{
	if ((sv->SwitcherBusyTil) && (time <= sv->SwitcherBusyTil))
		return(TRUE);
	else
		return(FALSE);
}

static UWORD	FXunderErrors(struct	Event	*event)
{
	ULONG obj=0;

	if ((event) && (event->FG))			// Pointers could be NULL, ya never know
		obj = event->FG->ObjectType;

	if (obj == CT_KEY)
		return(SEQERR_KeyOverEffect);
	if ((obj == CT_SCROLL) || (obj == CT_CRAWL))
		return(SEQERR_ScrawlOverEffect);
	else
		return(SEQERR_OlayOverEffect);
}

static UWORD	SwitCollisionErrors(struct	Event	*event, struct ExtFastGadget *FG2)
{
	struct	ExtFastGadget	*fg1 = NULL;

	if (event)
		fg1 = event->FG;								// Pointers could be NULL, ya never know

	if (IsSuperVideo(fg1))							// First event is a superimposed type?
	{
		if (IsVideoSource(FG2))						// 2nd event is framestore, main, etc.?
			return(SEQERR_OverlaysOverNonFlyer);
	}

	return(SEQERR_SwitcherCollision);		// General switcher collision error
}


//*********** Sequence Building Helper Subroutines **************//


//=============================================================
// HandleAudioUnder
//		Auto-make split audio and match frame on 2nd crouton
//=============================================================
void HandleAudioUnder(struct EditWindow *Edit)
{
	struct ExtFastGadget *fg,*fg1,*fg2;
	int	state,inserts,insertsbrkt;
	LONG	adur,match,temp,instime,instimebrkt;
	char	*msg;


	DUMPMSG("AudioInsert");

	fg1 = fg2 = NULL;
	state = 0;
	instime = instimebrkt = 0;
	inserts = insertsbrkt = 0;

	for (fg=*PtrProject ; fg && (state<3) ; fg = GetNextGadget(fg))
	{
		switch (state)
		{
			case 0:		// Look for (first) highlighted Flyer clip
				if (((struct FastGadget *)fg)->FGDiff.FGNode.Status == EN_SELECTED)
				{
					if (fg->ObjectType != CT_VIDEO)		// Only works on Flyer clips
						state = 9;								// If wrong type, stop! Do nil
					else
					{
						fg1 = fg;								// Have our starting crouton
						state++;									// Now count insert time
					}
				}
				break;
			case 1:		// Measure all inserts, watch for match crouton
				// Is this our end crouton?
				if((fg->ObjectType == CT_VIDEO)
				&& (stricmp(fg1->FileName, fg->FileName)==0))
				{
					fg2 = fg;		// Grab this FG for later

					// Make secondary copies to scan with
					insertsbrkt = inserts+1;						// Include this crouton
					instimebrkt = instime+GetDuration(fg);		// Include this crouton
					state++;			// Scan for 2nd hilite (optional)
				}
				else if (IsVideoSource(fg))
				{
					instime += GetDuration(fg);		// Add to insert total time
					inserts++;
				}
				break;
			case 2:		// Look for possible 2nd hilite
				if (((struct FastGadget *)fg)->FGDiff.FGNode.Status == EN_SELECTED)
				{
					// Is this a matching crouton?
					if((fg->ObjectType == CT_VIDEO)
					&& (stricmp(fg1->FileName, fg->FileName)==0))
					{
						fg2 = fg;		// Grab *THIS* FG for end crouton
						instime = instimebrkt;	// Use optional data we've been collecting
						inserts = insertsbrkt;
					}
// Let's go ahead and allow default to work, in case careless highlites exist downstream
//					else
//						fg2 = NULL;			// Highlight wrong, don't use default one either

					state++;			// Do it! (or not)
				}
				else if (IsVideoSource(fg))
				{
					instimebrkt += GetDuration(fg);		// Add to insert total time (optional)
					insertsbrkt++;
				}
		}
	}

	if (state==9)		// Found a highlite, but wrong type
		msg = "Error -- Only works on Flyer clips";
	if (fg1==NULL)
		msg = "Error -- No croutons highlighted";
	else if (fg2==NULL)
		msg = "Error -- Matching crouton not found";
	else if (inserts==0)
		msg = "Error -- No inserts found";
	else
	{
		// Calculate fg1's new audio duration
		adur = GetStartField(fg1)+GetDuration(fg1)+instime-GetAudioStart(fg1);

		// Calculate fg2's match field #
		match = GetAudioStart(fg1)+adur;

		if (match >= GetRecFields(fg2))		// Can't reach match crouton?
			msg = "Error -- Clip too short to perform operation";
		else
		{
			PutAudioDuration(fg1,adur);		// Stretch out fg1's audio under insert(s)

			PutAudioDecay(fg1,0);				// (seamless)
			PutAudioAttack(fg2,0);

     			// Adjust A/V durations to leave out-points untouched
			// Match could go beyond original outpoint, ensure we don't go negative!
			temp = GetStartField(fg2)+GetDuration(fg2)-match;
			PutDuration(fg2,(temp>0)?temp:4);

			temp = GetAudioStart(fg2)+GetAudioDuration(fg2)-match;
			PutAudioDuration(fg2,(temp>0)?temp:4);

			// Now set in-points to seam up audio perfectly
			PutStartField(fg2,match);			// Match frame fg2 (Audio & Video)
			PutAudioStart(fg2,match);

			CalcRunningTime();		// Re-calculate sequence total time & put up in access window

			sprintf(pstr,"Auto Insert performed -- %ld clip(s) inserted into %ls",inserts,fg1->FileName);
			msg = pstr;
		}
	}

	ContinueRequest(Edit->Window,msg);		// Show what happened
}


#if 0
// This is only needed if 'total' is 9 minutes +
ULONG Frac32toFields(ULONG total, ULONG frac32)
{
	ULONG	res;
	int	pre,post;

	for (pre=16,post=15,res=total;  post>=0;  pre++,post--,res>>=1)
	{
		if (res < 32768)
			break;
	}

	res = ((frac32>>pre) * total) >> post;

	res = (res+1)/2;		// Round up/down

	return(res);
}
#endif

// end of sequence.c
