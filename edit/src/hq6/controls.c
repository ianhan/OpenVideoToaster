/********************************************************************
* $controls.c$ - The control panels
* $Id: controls.c,v 2.6 1997/04/18 17:08:05 Holt Exp Holt $
* $Log: controls.c,v $
*Revision 2.6  1997/04/18  17:08:05  Holt
*fixed some small bugs.
*
*Revision 2.5  1997/04/01  10:42:52  Holt
*commented out 5.0 code for 4.2
*
*Revision 2.4  1997/02/07  00:02:03  Holt
*def out audio env/hq6 references.
*
*Revision 2.3  1997/02/03  23:48:52  Holt
*put a switch on the audioenv button on the video and audio panels
*
*Revision 2.2  1996/11/19  11:02:32  Holt
**** empty log message ***
*
*Revision 2.1  1996/11/18  20:10:45  Holt
*Awhile after a big messup in the RCS controls.c returns to the editor
*
*Revision 2.0  1996/11/18  20:08:35  Holt
 *
 * Revision 1.52  1996/07/29  10:26:29  Holt
 * 
 * added part of the audioenv panel
 *
 * Revision 1.51  1996/07/19  14:51:52  Holt
 * finished up cfx.
 *
 * Revision 1.50  1996/07/15  18:29:06  Holt
 * made changes to add the env button
 * and make cfx work in sequenceing.
 *
 * Revision 1.49  1996/06/26  10:29:13  Holt
 * comment out defines for audio env struct
 * they are defined in switcher/sinc/flyer.h
 *
 * Revision 1.48  1996/06/25  17:07:04  Holt
 * made many changes to test audio envelopes
 *
 * Revision 1.47  1996/01/15  15:11:51  Holt
 * fixed audio pantle problems
 *
 * Revision 1.46  1995/11/21  15:11:25  Flick
 * Drive info panel now reports correct values for devices with non-512 blk size
 *
 * Revision 1.45  1995/11/03  15:08:20  Flick
 * Audio popup now refers to channels 1/2 instead of L/R
 *
 * Revision 1.44  1995/10/28  02:00:21  Flick
 * Clear PlayFG at 'PanelOpen', not when entering Panel handler code
 *
 * Revision 1.43  1995/10/17  16:47:39  Flick
 * Added "-LENGTH_ADJUST" to Flyer sliders that were allowing illegal max points
 * These included ARexx(single), Cut&Proc dual slider and icon slider
 *
 * Revision 1.42  1995/10/12  16:31:59  Flick
 * Fixed audio silence on audio panels (both) and video fine tune (PL_FLYER)
 * Made arrow keys work when using ARexx jog/shuttle (dual) on audio clip
 *
 * Revision 1.41  1995/10/10  00:33:16  Flick
 * Changed DoNumReqPanel to return BOOL (not int value), accepts int *valinout
 *
 * Revision 1.40  1995/10/09  16:41:17  Flick
 * Removed unnecessary usage of popup.h
 * Spruced up (previously unused) Lost Crouton control panel
 *
 * Revision 1.39  1995/10/06  15:46:12  Flick
 * Added DoFlyJogReqPanel for ARexx jog/shuttling of clips
 * Now gives nice message if no temp clip and user goes into cut raw clip, drop back into record
 * After doing a ReOrg from drive info panel, now successfully closes and reopens drive panel
 * Deleted a lot of commented out old crusty code
 *
 * Revision 1.38  1995/10/05  18:35:40  Flick
 * Doesn't refresh views after going into cutting panel and not doing anything (cancel/record)
 *
 * Revision 1.37  1995/10/05  03:42:12  Flick
 * Removed extraneous PLI_USER from setup panel
 *
 * Revision 1.36  1995/10/03  18:14:26  Flick
 * Options panel expanded to support individual flags hooked to user level popup
 * New option "prefer fine tune", takes function once on CapsLock
 * Made all panels handle this option & PanelMode tag consistent!
 *
 * Revision 1.35  1995/10/02  15:55:15  Flick
 * Formalized FlyerDrives strings handling a bit
 * Added Options panel, moved StopOnDrop option into here out of Setup panel
 * Added Auto w/FX audio fades into video fine tune panel
 * Made record panel for switcher view less hacky
 * Added ProcessCrouton() to cut/process clips directly from a grazer window
 *
 * Revision 1.34  1995/09/28  10:05:01  Flick
 * QuickTune now supports partnered dragging, "Dropped" put on Rec panel in all situations now
 * Removal of some of the old "un-PNL_SKIP" code
 *
 * Revision 1.33  1995/09/25  12:10:56  Flick
 * Added fade speed to keys panel, Added "dropped" line to record panel
 * Improved FX expert panel & added takept, added quick tune panel
 *
 * Revision 1.32  1995/09/19  12:44:24  Flick
 * Added specific Continue/Cancel buttons to panels, since hard-coded ones are gone
 * Now use EasyPanelPL/ExpertPanelPL structures for all panels, w/ initializers used to set them
 * up before use.  Moved most panel-exiting buttons to bottom row, moved quick/fine tune buttons
 * to upper-right, moved duration time between boxes of duoslider and added same for audio duo.
 *
 * Revision 1.31  1995/09/13  12:10:45  Flick
 * Changes for cutclip/process panels: entry buttons on all A/V panels, prev/next
 * buttons, popup for "include", ripped cutting code out of record panel so can
 * be entered from anywhere.  New (correct) panel for control croutons.  Added
 * Reorg button to drive info panel.  ARexx buttons requester.  Displays last
 * frame of previous video on preview when A/V panel opens.
 *
 * Revision 1.30  1995/08/18  16:57:00  Flick
 * Now clears current time before all panels, and update running time after
 * Reworked drive info panel (from grazer) to show largest free/if reorged (MB)
 *
 * Revision 1.29  1995/08/16  15:48:21  Flick
 * Fixed bug in time field of grazer clipinfo panel: would not skip properly if
 * opened for dirs,FX,keys,stills,etc (anything w/o Flyer time) -- made garbage
 *
 * Revision 1.28  1995/08/16  11:01:44  Flick
 * Added time field in grazer clip panel
 * Reworded free space/frag space presentation/wording in drive info panel
 *
 * Revision 1.27  1995/08/09  18:10:36  Flick
 * So many cool things, I can't remember them all.  Here's a few:
 * Added HQ5 button in setup panel, total rework of FX panels.  Added new panel
 * for overlays.  Fixed numerous reported bugs, including flyer clip panel using
 * stale gadget data.
 *
 * Revision 1.26  1995/07/27  18:16:05  Flick
 * Added DriveInfoPanel
 * Added DELETE button to MarkClipsPL-related panels
 *
 * Revision 1.25  1995/07/13  15:13:31  Flick
 * Fixed TweakPanel to restore properly on CANCEL, also now sends USE values
 * when tweaking, then sends SAVE's on a CONTINUE (this is easier on Flyer NOVRAM).
 *
 * Revision 1.24  1995/07/13  13:06:15  Flick
 * HandleAudioOnOff() now works, even if no CurFG (dropped crtn or select all)
 * Improved DoInfoPanel: now displays rename errors, re-opens panel to try again
 *
 * Revision 1.23  1995/07/13  10:56:55  Holt
 * made change so VIDA AND KEYA use effect panel
 *
 * Revision 1.22  1995/07/06  18:20:10  Flick
 * Added support for audio symbol in corner of project croutons
 * Made ILBMFX use the correct control panel (finally!)
 *
 * Revision 1.21  1995/07/05  14:52:05  Flick
 * Improved "LOCKED" symbol code, added f'n to turn audio on/off outside
 * control panel
 *
 * Revision 1.20  1995/06/27  18:27:38  Flick
 * Removed lock to PROG TIME option for all but audio croutons
 *
 * Revision 1.19  1995/06/27  13:46:48  Flick
 * Added Drop Frame Stop button on setup panel
 * Flyer keeps (saves) this new class of options
 *
 * Revision 1.18  1995/06/20  23:25:21  Flick
 * Major cleanup - removed all hard-coded PLine indices, installed system of
 * enum PLI_ and XPLI_ tables which make these panels much easier to modify
 * without bugs and makes the code *MUCH* more readable
 *
 * Revision 1.17  1995/04/28  10:54:51  pfrench
 * Now refreshes directories after cutting clips
 *
 * Revision 1.16  1995/04/27  14:28:11  Flick
 * Lotsa cleanup on scrolls/crawls panels - fixed speeds/durations and un-crippled
 *
 * Revision 1.15  1995/04/21  17:15:29  Flick
 * High Quality V renamed to High Quality 5, sheesh!
 *
 * Revision 1.14  1995/04/21  16:02:42  Flick
 * Renamed *Standard mode to High Quality V, removed *Extended mode
 *
 * Revision 1.13  1995/04/21  02:03:19  Flick
 * Fixed duration conversion bugs in scrolls & FXILBMs
 *
 * Revision 1.12  1995/04/20  17:45:43  Flick
 * Fixed bad "Lock To" gadgets for Keys, Scrolls, FXILBMs
 *
 * Revision 1.11  1995/04/18  12:43:37  pfrench
 * Fixed Lock-to option for audio clips
 *
 * Revision 1.10  1995/03/29  17:20:59  CACHELIN4000
 * Fix TimeMode bug (CheckTag()) in audio panel
 *
 * Revision 1.9  1995/03/16  14:27:26  CACHELIN4000
 * Fix CRFX panel
 *
 * Revision 1.8  1995/03/10  18:00:56  CACHELIN4000
 * Make sure FG pointer is valid for PanelOpen/PanelClose call in NewClipPanel
 *
 * Revision 1.7  1995/03/10  10:58:07  CACHELIN4000
 * fix initial compmode on record panel available space
 *
 * Revision 1.6  1995/03/09  18:06:10  CACHELIN4000
 * Eliminate pesky expert mode on video source panels
 *
 * Revision 1.5  1995/03/08  13:08:43  CACHELIN4000
 * add Process button to Clips panel when no audio is present
 *
 * Revision 1.4  1995/03/07  16:11:59  CACHELIN4000
 * New FASTDRIVE compression mode support, compression mode indirection, fastdrive bit in config
 *
 * Revision 1.3  1995/03/06  11:25:52  CACHELIN4000
 * Fix ordering on ChromaFX cycles popup...
 *
 * Revision 1.2  1995/03/03  11:44:30  CACHELIN4000
 * Remove XP panels form FX, etc.
 *
 * Revision 1.1  1995/03/01  09:53:12  CACHELIN4000
 * Initial revision
 *
*Revision 2.147  1995/02/27  09:33:53  CACHELIN4000
**** empty log message ***
*
*Revision 2.146  1995/02/24  16:14:12  pfrench
*Color names for yellow/cyan transposed
*
*Revision 2.145  1995/02/24  11:48:35  CACHELIN4000
*Fix stuff, add RT to CFX panel, start time/time mode order swap
*
*Revision 2.144  1995/02/22  10:32:07  CACHELIN4000
**** empty log message ***
*
*Revision 2.143  1995/02/21  12:19:54  CACHELIN4000
*Add TimeMode popup to Audio panel
*
*Revision 2.142  1995/02/20  12:28:13  CACHELIN4000
**** empty log message ***
*
*Revision 2.141  1995/02/19  16:41:44  CACHELIN4000
*Separate out PanData.c, PanFunctions.c to  make things link
*
*Revision 2.140  1995/02/19  11:35:29  pfrench
*One more attempt at getting the data to a far section
*
*Revision 2.139  1995/02/19  11:27:06  pfrench
*Cannot have static items that are FAR
*
*Revision 2.138  1995/02/19  01:03:41  CACHELIN4000
**** empty log message ***
*
*Revision 2.137  1995/02/14  10:46:12  CACHELIN4000
**** empty log message ***
*
*Revision 2.136  1995/02/14  10:27:50  CACHELIN4000
*Add Rec Gain controls to RawRec, strip audio/video to Mark Clip
*
*Revision 2.135  1995/02/13  14:38:09  CACHELIN4000
**** empty log message ***
*
*Revision 2.134  1995/02/11  17:52:59  CACHELIN4000
*Add SMPTE, audio record level support
*
*Revision 2.133  1995/02/10  15:27:46  Kell
*ES_RecordSource now doesn't have record audio volume parameters.
*
*Revision 2.132  1995/02/01  17:54:31  CACHELIN4000
*Add Process button, fix cutting room jump from record panel
*
*Revision 2.131  1995/01/25  18:34:57  CACHELIN4000
*Change TBC controls to scaled STEPSLIDE lines
*
*Revision 2.130  1995/01/24  18:05:37  CACHELIN4000
**** empty log message ***
*
*Revision 2.129  1995/01/24  16:50:04  CACHELIN4000
*Re-enable TBC inputs
*
*Revision 2.128  1995/01/24  11:19:50  CACHELIN4000
*TBC panels, some cutting room additions
*
*Revision 2.127  1995/01/13  14:23:30  CACHELIN4000
*Add Partner stuff to video control panel, DHD_Jog,Jump and Shuttle
*Put in Play buttons/crouton button, fix CTRL_Play() to ahndel SWITCHER_MODE,
*Add none to Audio channels again, add audio toggle to EZ video again,  etc.
*
*Revision 2.126  1995/01/12  12:03:52  CACHELIN4000
*Framestore duration EZLEN-> EZTIME
*
*Revision 2.125  1995/01/06  22:16:54  CACHELIN4000
*All Tables ARE even length now!
*
*Revision 2.124  1995/01/05  17:54:15  CACHELIN4000
*Fix available time swap between Extended and Std. modes
*
*Revision 2.123  1995/01/04  23:40:23  CACHELIN4000
*Fix Matte color bugs in DoFXAnimPanel()
*
*Revision 2.122  1995/01/04  17:36:29  CACHELIN4000
*Quantize Audio sliders on Color Frame (add PL_CFRAME flag)
*
*Revision 2.121  1995/01/04  11:02:25  CACHELIN4000
**** empty log message ***
*
*Revision 2.120  1994/12/31  02:05:06  CACHELIN4000
*Fix AUDIO_ONLY avail time again, standardize Source setting, CurFlySource
*
*Revision 2.119  1994/12/30  21:22:20  CACHELIN4000
*Fixed audio duration
*
*Revision 2.118  1994/12/30  13:09:58  CACHELIN4000
*Add Audio only calc to BlocksToFrames(), CTRL_SetSource(), etc.
*
*Revision 2.117  1994/12/28  17:48:48  CACHELIN4000
*add 1 b4 rounding down rcb->frame in DHD_Jog()
*
*Revision 2.116  1994/12/24  12:33:41  CACHELIN4000
*fix bug with AUDIO_ONLY_SOURCE vs CurFlySource (add 1)
*
*Revision 2.115  1994/12/23  17:45:10  CACHELIN4000
*change LENGTH_ADJUST to 0 so short clips have correct out points.. i hope
*
*Revision 2.114  1994/12/23  15:01:55  CACHELIN4000
*Make GetTable() requests use 256byte buffer, instead of 255...
*
*Revision 2.113  1994/12/23  11:36:30  CACHELIN4000
*Use PropEnd for string limits
*
*Revision 2.112  1994/12/23  10:08:47  CACHELIN4000
*Add AUDIO_ONLY_SOURCE define, fix DHD_SetupRecord 'bug' for audio only initialization.
*
*Revision 2.111  1994/12/22  21:57:59  CACHELIN4000
*fixes to Rexx panel
*
*Revision 2.110  1994/12/21  17:33:10  CACHELIN4000
*add recordclip(), fix CTRL_Play, add play line to clip panel
*
*Revision 2.109  1994/12/16  21:02:36  CACHELIN4000
*Add RecordClip Function
*
*Revision 2.108  1994/12/15  16:42:59  CACHELIN4000
**** empty log message ***
*
*Revision 2.107  1994/12/09  16:42:17  CACHELIN4000
*Use AUD_ENABLE flags for channels popup
*
*Revision 2.106  1994/12/08  16:08:38  CACHELIN4000
*Reorganize Audio, video control panels (Yet Again), fix Streeo pan oversight
*Add Start Time to Rexx panel, etc.
*
*Revision 2.105  1994/12/07  23:14:31  CACHELIN4000
*Add Channels popup to XPVidClip, change volume num to slider (Sorry James, SKell said Tim siad to do it)
*
*Revision 2.104  1994/12/07  00:12:22  CACHELIN4000
*Add SortFLyerDrives(), Audio drive tweaks and various cosmetics
*
*Revision 2.103  1994/12/05  20:06:38  CACHELIN4000
*Use global CurCompMode for retain compression settings
*
*Revision 2.102  1994/12/05  19:21:30  CACHELIN4000
*Add Quality popup to record panel.
*
*Revision 2.100  1994/12/03  18:36:24  CACHELIN4000
*Add PanelMode tag check, quicktune gadgets, diff text placement
*
*Revision 2.99  1994/11/18  18:31:19  Kell
*Changed Tag Synchronous to Asynchronous
*
*Revision 2.98  1994/11/18  16:51:52  CACHELIN4000
*Add RexxPanel tags..
*
*Revision 2.97  1994/11/16  15:13:23  CACHELIN4000
*Fix I/O point swap bug, add Rexx panel, make things far static to help linker (?)
*
*Revision 2.96  1994/11/15  21:41:24  CACHELIN4000
*Fix initial clip length bug
*
*Revision 2.95  1994/11/10  00:31:47  CACHELIN4000
*Remove FlyerIn, FlyerY/C sources from popup..
*
*Revision 2.94  1994/11/10  00:10:47  CACHELIN4000
*Implement Audio source channels popup, CTRL_SetPan
*
*Revision 2.93  1994/11/09  18:50:38  CACHELIN4000
*Fix New Audio Balance/Volume system... i hope
*
*Revision 2.92  94/11/09  15:33:40  CACHELIN4000
*More messing around.
*
*Revision 2.90  94/11/04  17:19:15  CACHELIN4000
*Remove Rename from fileinfo, fix audio panel, etc.
*
*Revision 2.89  94/11/04  00:31:17  CACHELIN4000
**** empty log message ***
*
*Revision 2.88  94/11/03  23:11:36  CACHELIN4000
*CTRL_Play(), remove record tracks toggle, fix CTRL_SetSource, etc.
*
*Revision 2.87  94/11/03  11:08:07  CACHELIN4000
*Limit Coarse tweak to 0-9, not 0-15
*
*Revision 2.86  94/11/02  20:23:11  CACHELIN4000
*fix Balance/Volume setting, lack of render after DHD_Jog message,
*monaural audio clip support with Pan, even volumes losing 1
*
*Revision 2.85  94/11/01  18:57:35  CACHELIN4000
*Backup Tweak values..
*
*Revision 2.84  94/10/31  17:22:17  CACHELIN4000
*Re-Do Tweak panel, etc.
*
*Revision 2.83  94/10/28  16:52:01  CACHELIN4000
*Add Pedestal preset to Tweak
*
*Revision 2.82  94/10/28  15:25:40  CACHELIN4000
*fix reversed Hack array
*
*Revision 2.81  94/10/28  11:57:26  CACHELIN4000
*Fix Audio Fade bug.
*
*Revision 2.80  94/10/27  23:45:14  CACHELIN4000
*Buffer Tweak panel, re-do VidClip controls to meet new spec, add CTRL_SetBalance
*change PLine User-Function names to start with CTRL_ not DHD_
*
*Revision 2.79  94/10/25  20:01:18  CACHELIN4000
*extend Tweak panel, check flyerbase before finding drives...
*
*Revision 2.78  94/10/25  18:08:29  CACHELIN4000
*Fix Tweak panel to get flyer volumes
*
*Revision 2.77  94/10/24  17:20:32  CACHELIN4000
*Insert MiniPanel call, fix inpoint/outpoint calculations
*
*Revision 2.76  94/10/24  12:21:50  CACHELIN4000
*Update grazer after rename, etc.
*
*Revision 2.75  94/10/21  23:21:52  CACHELIN4000
*Connect SetupPanel to new messages, structure
*
*Revision 2.74  94/10/20  11:53:44  CACHELIN4000
*Switch to new PLine->UserFun for function calls, add setup panel
*
*Revision 2.73  94/10/14  13:39:08  CACHELIN4000
*Add CheckFlyerDrives() to sort Audio drives and add 0xA2 as 1st byte of name
*
*Revision 2.71  94/10/12  17:34:59  CACHELIN4000
*Use DuoSLider for VideoXP, Audio, AudioXP panels
*
*Revision 2.70  94/10/11  21:40:06  CACHELIN4000
*DuoSlide for ClipPL
*
*Revision 2.69  94/10/07  11:36:39  CACHELIN4000
*Fix HAck,RecTest f'ns
*
*Revision 2.66  1994/10/06  23:04:57  CACHELIN4000
*Fix ANIMFX panels
*
*Revision 2.65  94/10/06  19:15:37  CACHELIN4000
*Matte/Border awareness in DoANIMFXPanel() .. left ghost
*
*Revision 2.64  94/10/06  09:30:39  CACHELIN4000
*Audio Duration ->RecFields.. bug fix
*
*Revision 2.63  94/10/06  01:02:19  CACHELIN4000
*Fix RecTest for A/B channel, DHD_Shuttle not updating I/O point bug
*
*Revision 2.62  94/10/05  23:34:05  Kell
*Fix Rec_Test stuff (AC)
*
*Revision 2.61  1994/10/05  16:29:07  CACHELIN4000
*Open all Panels on multi-select...
*
*Revision 2.60  94/10/05  05:31:30  Kell
*Fixed the Get/Put Table comment stuff.
*
*Revision 2.59  1994/10/05  02:40:14  Kell
*PutTable now does correct ES_PutTable command.
*
*Revision 2.58  1994/10/05  01:06:35  CACHELIN4000
*Diff add-ons, ES_Hack, DoTweakPanel, TweakPL, etc.
*
*Revision 2.57  94/10/04  18:13:53  CACHELIN4000
*Remember Drive, Source, Tracks and Name between record panel invocations
*
*Revision 2.53  94/10/03  18:49:52  CACHELIN4000
*Don't make icon for Audio clips, Update dir after record, XPClip volume=0 if audio off
*un-reverse audio volume channel setting
*
*Revision 2.51  94/10/02  00:03:19  CACHELIN4000
*Bullet-proof Clip control panel against missing tags.
*
*Revision 2.49  94/10/01  14:52:16  Kell
*Fixed bugs related to saving / loading comments.
*
*Revision 2.48  1994/10/01  13:00:35  Kell
*Now saves center icon of recorded clip.
*DHD_FlyerClipInfo for getting length of recorded clip, etc.
*
*Revision 2.47  1994/10/01  01:03:29  Kell
*Added DHD_MakeClipIcon. Currently puts up Wait sprite when making icon.
*
*Revision 2.46  1994/09/30  21:36:52  CACHELIN4000
*assure even frame numbers in aduio, video panels
*
*Revision 2.45  94/09/30  13:17:47  pfrench
*Removed doallnewdir from doinfopanel because the grazer
*was traversing the list of selected files.
*
*Revision 2.44  1994/09/30  11:28:57  CACHELIN4000
*Audio InPoints set on EZ Clip Adjust
*
*Revision 2.40  94/09/28  23:42:13  CACHELIN4000
*Add DHD_Reorganize(), rearrange record panel again
*
*Revision 2.38  94/09/28  14:46:52  CACHELIN4000
*BlocksToFrames added
*
*Revision 2.37  94/09/28  11:31:49  CACHELIN4000
*add BuildFlyerList()
*to NewClipPanel
*
*Revision 2.34  94/09/27  18:05:24  CACHELIN4000
*Bag crashy FreeCrouton in DHD_InitRecord
*
*Revision 2.33  94/09/27  17:19:58  CACHELIN4000
*Add POPUP f'ns (SetSource, SetDrive), tweak DHD_ functions for record panel,
*add Drive popup to record panel, FlyerDriveInfo query
*
*Revision 2.32  94/09/25  16:34:27  Kell
*Changes ES_StopSeq to ES_Stop
*
*Revision 2.30  94/09/23  10:33:05  CACHELIN4000
*Record Panel, CutCLip Panel work.
*
*Revision 2.28  94/09/20  23:33:17  CACHELIN4000
*FX Tags work, TAGNames added for EZ debuggery
*
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*********************************************************************/

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/sghooks.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfxbase.h>
#include <graphics/text.h>

#include <edit.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <time.h>
#include <editwindow.h>
#include <project.h>
#include <gadgets.h>
#include <prophelp.h>
#include <grazer.h>
#include <editswit.h>
#include <crouton_all.h>
#include <request.h>
#include <tags.h>
#include <panel.h>
#include <filelist.h>
#include <flyerlib.h>
#include <flyer.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/diskfont.h>

#ifndef PROTO_PASS
#include <proto.h>
#else
#include "edit:proto/Pline.p"
#include "edit:proto/PanFunctions.p"
#include "edit:proto/PanData.p"
#endif


//#define INCAUDENV		1		//undefining this turns off the envelope button. 
#define SERDEBUG	1
#include <serialdebug.h>

#define	TESTING_ONLY	0

#define LENGTH_ADJUST		2

#define CFAR __far

#define CSTATIC

/* Definded in "switcher/sinc/flyer.h"
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
	struct AEKey AEKey[16];
};
*/


/* External Stuff */

extern struct PanelLine *CurPLine,*Start,*LastTime,*temp;
extern struct Gadget *FirstG,*Down,*EZGad,*In,*Out,*Del,*Len;
extern LONG	InOrOut,ft,Adder;
extern ULONG	Ticks,WinFlags,GadInd;
extern struct FastGadget *CurFG,*SKellFG;
extern char TempCh[],TempC2[],*DTNames[],*QTNames[],ClipName[],ClipName2[],ClipPath[];
extern UBYTE *TempMem;
extern ULONG CRuDTypes[];
extern struct MsgPort *SwitPort;
extern struct EditWindow *EditTop,*EditBottom;
extern struct Library *FlyerBase;
extern struct EditPrefs UserPrefs;		// User preferences live here

extern struct ESParams1 ESparams1;
extern struct ESParams2 ESparams2;
extern struct ESParams3 ESparams3;
extern struct ESParams4 ESparams4;
extern struct ESParams5 ESparams5;

extern CFAR struct PanelLine EasyPanel_PL[];
extern CFAR struct PanelLine ExpertPanel_PL[];
extern CFAR struct PanelLine OtherPanel_PL[];

extern CFAR struct InitPanelLine ReqString_IPL[];
extern CFAR struct InitPanelLine ReqNum_IPL[];
extern CFAR struct InitPanelLine ReqTime_IPL[];
extern CFAR struct InitPanelLine ReqTell_IPL[];
extern CFAR struct InitPanelLine ReqButtons_IPL[];
extern CFAR struct InitPanelLine ReqFlyJog_IPL[];
extern CFAR struct InitPanelLine Setup_IPL[];
extern CFAR struct InitPanelLine Options_IPL[];
extern CFAR struct InitPanelLine Tweak_IPL[];
extern CFAR struct InitPanelLine TBC_IPL[];
extern CFAR struct InitPanelLine XPTBC_IPL[];
extern CFAR struct InitPanelLine Error_IPL[];
extern CFAR struct InitPanelLine RawRec_IPL[];
extern CFAR struct InitPanelLine ProcClip_IPL[];
extern CFAR struct InitPanelLine CutClip_IPL[];
extern CFAR struct InitPanelLine FileInfo_IPL[];
extern CFAR struct InitPanelLine DriveInfo_IPL[];
extern CFAR struct InitPanelLine Rexx_IPL[];
extern CFAR struct InitPanelLine Frame_IPL[];
extern CFAR struct InitPanelLine LumaKey_IPL[];
extern CFAR struct InitPanelLine Trails_IPL[];
extern CFAR struct InitPanelLine CFX_IPL[];
extern CFAR struct InitPanelLine Main_IPL[];
//extern CFAR struct InitPanelLine XPMain_IPL[];
extern CFAR struct InitPanelLine Ctrl_IPL[];
extern CFAR struct InitPanelLine AlgoFX_IPL[];
extern CFAR struct InitPanelLine XPAlgoFX_IPL[];
extern CFAR struct InitPanelLine OlayFX_IPL[];
extern CFAR struct InitPanelLine TransFX_IPL[];
extern CFAR struct InitPanelLine XPTransFX_IPL[];
extern CFAR struct InitPanelLine Clip_IPL[];
extern CFAR struct InitPanelLine XPClip_IPL[];
extern CFAR struct InitPanelLine AudClip_IPL[];
extern CFAR struct InitPanelLine XPAudClip_IPL[];
extern CFAR struct InitPanelLine Key_IPL[];
//extern CFAR struct InitPanelLine XPKey_IPL[];
extern CFAR struct InitPanelLine Crawl_IPL[];
extern CFAR struct InitPanelLine Scroll_IPL[];
extern CFAR struct InitPanelLine Quick_IPL[];

extern CFAR struct InitPanelLine Env_IPL[];


#if TESTING_ONLY
extern CFAR struct PanelLine XPTest_PL[];
#endif

struct PanelLine *EasyPanelPL = EasyPanel_PL;
struct PanelLine *ExpertPanelPL = ExpertPanel_PL;
struct PanelLine *OtherPanelPL = OtherPanel_PL;




#define SWITCHER_MODE	( (!EditBottom) && (!EditTop || (EditTop->Height!=TOP_LARGE)) )
#define EDITOR_MODE		(!SWITCHER_MODE)

/*** Static Prototypes ***/
static BOOL DoTBCPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoTweakPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoRexxPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoFXPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoFXtransPanel(struct EditWindow *Edit, struct FastGadget *FG);
//static BOOL DoFXtransVarPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoFXOverlayPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoFXCRPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoAUDIOPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoVIDEOPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoCONTROLPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoMainPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoFRAMESTOREPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoKEYPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoCRAWLPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoSCROLLPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoNewClipPanel(struct EditWindow *Edit, struct FastGadget *FG);
static BOOL DoProcClipPanel(struct EditWindow *Edit, struct FastGadget *FG);
static UWORD DoCuttingPanel(struct EditWindow *Edit, struct FastGadget *FG, BOOL fromrec, char *name);
static BOOL DoERRORPanel(struct EditWindow *Edit, struct FastGadget *FG);
#if TESTING_ONLY
static BOOL DoTestPanel(struct EditWindow *Edit, struct FastGadget *FG);
#endif
static void FmtBlocks2Size(char *Dest,char *Label, ULONG Blocks);
static BOOL ProcCrtnPanel(struct FastGadget *FG, BOOL destructive);

static BOOL DoEnvPanel(struct EditWindow *Edit,
							  struct FastGadget *FG,LONG Time_In,LONG Time_Out,
							  LONG FadeIn,LONG FadeOut,  
							  struct AudioEnv *aev);


struct	AudioSet	CurAudioSet={0,0,0};
struct FlyAudCtrl AudCtrl = {0,0,0,0,0,0,8,8,128,0,128,0,0,0,0,0,0,0,0,0};
struct FastGadget *PlayFG=NULL;
far static UBYTE CommentBuf[COMMENT_MAX+1];	//The Get/PutTable commands need an EVEN length!!!!!

CFAR CSTATIC char Size[20],Name[MAX_STRING_BUFFER]="Clip.0",Dir[MAX_STRING_BUFFER];
ULONG CurFlyDrive=0,CurFlySource=2,CurFlyTracks=1,CurCompMode=0;
ULONG	FlyerOpts;
//BOOL 	GlobalFastDrives=0;
VOID DisplayWaitSprite(VOID);
VOID DisplayNormalSprite(VOID);
#define TWEAK_CHANNELS	3  // 4 when Record_B becomes real again
CFAR struct Hack
		HackA={HKF_PLAY_A,-29,1,14,7,0,0,60},*Hack=&HackA,
		HackB={HKF_PLAY_B,-29,2,2,7,0,0,60},
		HackC={HKF_RECORD_A|HKF_TESTREC,20,3,0,3,0,0,0},
		HackD={HKF_RECORD_B|HKF_TESTREC,20,2,6,3,0,0,0},
		*Hacks[]={&HackA,&HackB,&HackC,&HackD},
		BakHackA={HKF_PLAY_A,-29,1,14,7,0,0,60},
		BakHackB={HKF_PLAY_B,-29,2,2,7,0,0,60},
		BakHackC={HKF_RECORD_A|HKF_TESTREC,20,3,0,3,0,0,0},
		BakHackD={HKF_RECORD_B|HKF_TESTREC,20,2,6,3,0,0,0},
		*BakHacks[]={&BakHackA,&BakHackB,&BakHackC,&BakHackD};

struct SystemPrefs Config={0,0,0,0};
struct TBCctrl		TBC_dat,TBC_bak;
char	*global_CurVolumeName;				// Current Flyer volume name (used for ReOrg)

#define QUAL_NUM_STD		3 		// number of entires in Qual array
#define QUAL_NUM_HQ5		4 		// number of entires in Qual array
#define QUAL_NUM_HQ6		5 		// number of entires in Qual array
#define DEF_QUALITY	0 	// default quality
#define COLOR_NUM	10		// number of entries in Colors array
#define DEF_COLOR	2			// default color = Red
#define SCROLL_NUM  2
#define DEF_SCROLL 0
#define CRAWL_NUM	3
#define PNL_NUM	15
#define FLY_SRC_NUM	7



LONG PanType=PAN_EASY,FlyerDriveCount=0;

UBYTE
	FDrive[(21+1)*FLY_VOL_MAX+2],	// Room for 21 drives, extra line beyond, and a NULL entry

	*FlyerDrives[]={
		&FDrive[ 0*FLY_VOL_MAX],
		&FDrive[ 1*FLY_VOL_MAX],
		&FDrive[ 2*FLY_VOL_MAX],
		&FDrive[ 3*FLY_VOL_MAX],
		&FDrive[ 4*FLY_VOL_MAX],
		&FDrive[ 5*FLY_VOL_MAX],
		&FDrive[ 6*FLY_VOL_MAX],
		&FDrive[ 7*FLY_VOL_MAX],
		&FDrive[ 8*FLY_VOL_MAX],
		&FDrive[ 9*FLY_VOL_MAX],
		&FDrive[10*FLY_VOL_MAX],
		&FDrive[11*FLY_VOL_MAX],
		&FDrive[12*FLY_VOL_MAX],
		&FDrive[13*FLY_VOL_MAX],
		&FDrive[14*FLY_VOL_MAX],
		&FDrive[15*FLY_VOL_MAX],
		&FDrive[16*FLY_VOL_MAX],
		&FDrive[17*FLY_VOL_MAX],
		&FDrive[18*FLY_VOL_MAX],
		&FDrive[19*FLY_VOL_MAX],
		&FDrive[20*FLY_VOL_MAX],
		&FDrive[21*FLY_VOL_MAX],	// Extra line for me to use
		&FDrive[22*FLY_VOL_MAX]		// Blank (NULL placed after highest drive found)
	};

CFAR UBYTE
//	*TimeModes[] = {"Audio In","Delay",""},
	*TimeModes[] = {"Clip","In Point","Prog Time",""},
	*CfxTimeModes[] = {"Clip","In Point","Entire Clip",""},
	*EnvGadgetModes[] = {" Key Drag ","Key Create","Key Delete",""};



#if TESTING_ONLY
CFAR UBYTE *Pnls[] = { "ANIM","ILBM","ALGO","CHROMAFX","VIDEO","AUDIO","CONTROL",
		"PROJECT","FRAMESTORE","KEY","SCROLL","CRAWL","ERROR","RAWREC","SETUP","TWEAK",""};
#endif

CFAR UBYTE
	*FlyDrives[]={"-NONE-","Test2:"},
	*Colors[] = {"Black","White","Red","Green","Blue","Yellow","Magenta","Cyan","Snow","Special",""},
//	*ScrollCtrls[] = {"Scroll Once","Scroll Hold"},
//	*CrawlCtrls[] = {"Crawl Once","Crawl Repeat","Crawl Hold"},
	*Quals[] = {"Standard Play","Extended Play","Audio Only","High Quality 5","High Quality 6",""},
	QualMode[] = {COMP_STD,COMP_EXT,COMP_AUD,COMP_FSTD,COMP_FBIG},	// Removed COMP_FEXT
	*CutTracks[] = {"Video  ","Audio  ",""},
//	*Tracks[] = {" Record Audio ",""},
//	*Sources[] = {"Input 1","Input 2","Main Out","Audio Only",""},
	*Sources[] = {"Flyer In","Flyer Y/C","Input 1","Input 2","Input 3","Input 4","Main Out",""},
// This array translated the popup index, CurFlySource, to actual flyer values.
	SrcInd[] = {
		FLYS_VideoSource_NTSC,
		FLYS_VideoSource_SVHS,
		FLYS_VideoSource_VID1,
		FLYS_VideoSource_VID2,
		FLYS_VideoSource_VID3,
		FLYS_VideoSource_VID4,
		FLYS_VideoSource_Main},

	*Tweaks[] ={ "Play A","Play B","Record","Record B","Rec. Test"},
//	*Channels[] ={ "Stereo (L+R)", "Left Only" , "Right Only", "None"},
	*Channels[] ={ "Ch 1+2 (Stereo)", "Ch 1 (Mono)" , "Ch 2 (Mono)", "None"},
//	*Inputs[] ={ "1  ","2  ","3  ","4  "},
	*Inputs[] ={ "4  ","3  ","2  ","1  "},
	*CFX_CModes[] ={ "Chroma","Chroma Strip"},
	*CFX_DModes[] ={ "Filter","Transition"},
	*CFX_Cycles[] ={ "None "," Up  ","Down  ","Bounce "},
	*FlyInputs[] ={ "Input 3  ","Input 4  "},
	*TBCSources[] = {"Composite"," Y/C ","Main Out","Fader",""},
	*TBCTerm[] = {"Comp. ","Gen. ","TBC ","AFade","BFade",""},
	*TBCDecoder[] = {"Mono. In","AGC","Chroma AGC",""},
	*TBCEncoder[] = {"Bypass","Bars","Kill Color","Freeze",""},
	*TBCKeyer[] = {"Fader Out","Channel B",""},
	*TBCKeyModes[] = {"Fader","2 Level","4 Level",""},
	TBC_KeyMode[] = {0,TBCKF_MODE0,TBCKF_MODE0|TBCKF_MODE1},
	*GPImodes[] ={ "Off" , "Pulse Front", "Pulse Back"},
	*UserTypes[] ={ "Novice","Super Genius"},
	*CGONOFFTypes[] ={ "Keys Fade","Keys Cut"};


far char RexxArgs[COMMENT_MAX+1],*Waits[]={"Wait for Return  ",""};
far UBYTE 	TBC_Input[] = {TBCIN_COMP,TBCIN_YC,TBCIN_TMAIN,TBCIN_FADER};

#ifdef PROTO_PASS
	PanHandler	PanHandlers[50];
#else
CFAR PanHandler	PanHandlers[] = {
  DoFXPanel,							// CR_FXANIM
  DoFXPanel,							// CR_FXILBM	(Was DoFXOverlayPanel)
  DoFXPanel,							// CR_FXALGO
  DoFXCRPanel,							// CR_FXCR
  DoVIDEOPanel,						// CR_VIDEO
  DoAUDIOPanel,						// CR_AUDIO
  DoCONTROLPanel,						// CR_CONTROL
  NULL,									// CR_PROJECT
  DoFRAMESTOREPanel,					// CR_FRAMESTORE
  DoKEYPanel,							// CR_KEY
  DoSCROLLPanel,						// CR_SCROLL
  DoCRAWLPanel,						// CR_CRAWL
  DoFXPanel,  							// CR_VIDEOANIM,		// Was DoFRAMESTOREPanel (DH)
  DoFXPanel,							// CR_KEYEDANIM,		// Was DoKEYPanel (DH)
  DoMainPanel,							// CR_MAIN,
  DoFRAMESTOREPanel,					// CR_STILL,
  DoERRORPanel,						// CR_ERROR
  NULL,									// CR_CGBOOK
  NULL,									// CR_IMAGE
  NULL,									// CR_LWSCENE
  NULL,									// CR_LWOBJ
  NULL,									// CR_LWSURF
  NULL,									// CR_LWMOT
  NULL,									// CR_LWENV
  NULL,									// CR_FONT
  NULL,									// CR_EPS
  DoRexxPanel,							// CR_REXX
  NULL,									// CR_TEXT
  NULL,									// CR_UNKNOWN

											// What about these internal Grazer types?
											// CR_FLOPPY
											// CR_DRIVE
											// CR_CDROM
											// CR_FLYER
											// CR_DIR

  DoNewClipPanel,
  DoSetupPanel,
  DoTweakPanel,
  NULL
};
#endif



//*******************************************************************
struct EditWindow *HandleNewClip(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	DoNewClipPanel(Edit,NULL);
	//DUMPMSG(" ...NewClip Handled.");
	return(Edit);
}

//*******************************************************************
BOOL DoStrReqPanel(char *Title, char *buff, int buffsize)
{
	enum {				// PL indices for ReqStringPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_STRING,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	InitPanelLines(EasyPanelPL,ReqString_IPL);		// Copy basic init data into panel

	EasyPanelPL[PLI_TITLE].Label = Title;

	EasyPanelPL[PLI_STRING].Param = (LONG *)buff;
	EasyPanelPL[PLI_STRING].PropEnd = (LONG)buffsize-1;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	if(PAN_CANCEL==MiniPanel(NULL,EasyPanelPL,TUNE_NONE))
		return(FALSE);

	return(TRUE);
}

//*******************************************************************
BOOL DoNumReqPanel(char *Title, int *num, int min, int max)
{
	enum {				// PL indices for ReqNumPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_NUMBER,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	struct PanelLine	*pl;

	InitPanelLines(EasyPanelPL,ReqNum_IPL);		// Copy basic init data into panel

	EasyPanelPL[PLI_TITLE].Label = Title;

	pl = &EasyPanelPL[PLI_NUMBER];
	pl->Param = (LONG *)num;			// Pass caller's ptr to an int
	pl->PropStart = min;
	pl->PropEnd = max;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	if(PAN_CANCEL==MiniPanel(NULL,EasyPanelPL,TUNE_NONE))
		return(FALSE);

	return(TRUE);
}


//*******************************************************************
BOOL DoTimeReqPanel(char *Title, char *timecode)
{
	enum {				// PL indices for ReqTimePL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_TIME,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	ULONG t;
	struct PanelLine	*pl;

	DUMPMSG("DoTimeReqPanel \n");

		

	InitPanelLines(EasyPanelPL,ReqTime_IPL);		// Copy basic init data into panel

	TimeToLong(timecode,&t);
	EasyPanelPL[PLI_TITLE].Label = Title;

	pl = &EasyPanelPL[PLI_TIME];
	pl->Param = (LONG *)&t;
	pl->PropStart = 0;
	pl->PropEnd = 65535<<4; // Big!

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	if(PAN_CANCEL==MiniPanel(NULL,EasyPanelPL,TUNE_NONE))
		return(FALSE);

	LongToTime(&t,timecode);

	return(TRUE);
}


//*******************************************************************
BOOL DoFlyJogReqPanel(char *Title, char *Name, char *intime, char *outtime)
{
	enum {				// PL indices for ReqFlyJogPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_NAME,
		PLI_SINGLE,
		PLI_DUAL,
		PLI_LENGTH,
		PLI_MAKEWIDW,		// Just makes panel wide
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL
	};

	LONG	clipfrms,t_In,t_Out,smpte=0,type,start,dur;
	BOOL	dual,succ=FALSE;
	struct PanelLine	*pl;
	struct FastGadget *FG = NULL;
	struct SMPTEinfo si;


	DUMPMSG("DoFlyJogReqPanel");


	if (Flyer_ClipInfo(Name) == NULL)		// If file cant be found, don't open panel
		return(FALSE);

	if (outtime)			// Wants in & out times (dual slider?)
		dual=TRUE;
	else
		dual=FALSE;

	if (FG = AllocProj(Name))					// Now counterfeit a FG that I can use to jog
	{
		// Only works on video and audio clips
		type = ((struct ExtFastGadget *)FG)->ObjectType;
		if ((type == CT_VIDEO) || (type == CT_AUDIO))
		{
			CurFG = FG;		// Must do this so Switcher gets tags okay, but I don't know why

			// Open panel (BeginFindField)
			ESparams1.Data1=(LONG)FG;
			SendSwitcherReply(ES_PanelOpen,&ESparams1);		// Opening panel, prepare to jog

			//~~~~~ Can pretend we're a normal panel now ~~~~~~~~~~~~~~~~~~~~~~~
			clipfrms = Flds2Frms(GetValue(FG,TAG(RecFields)));  	// Clip frame length
			if(clipfrms<2)
				clipfrms=4;
			//DUMPUDECL("Clip length is ",clipfrms," frames\\");

			if(GetTable(FG,TAG_SMPTEtime,(UBYTE *)&si,sizeof(struct SMPTEinfo)))
			{
				smpte = EVEN(SMPTEToLong(&si));
				//DUMPUDECB("SMPTE Start: ",si.SMPTEhours,":");
				//DUMPUDECB("",si.SMPTEminutes,":");
				//DUMPUDECB("",si.SMPTEseconds,":");
				//DUMPUDECB("",si.SMPTEframes,"  = ");
				//DUMPUDECL(" ",smpte," frames \\");
			}

			start = GetValue(FG,TAG(ClipStartField));
			dur	= GetValue(FG,TAG(Duration));
			if (dur==0)
				dur = clipfrms - start;
			t_In  = Fly4Flds2Frms(start) + smpte;			// In Frame
			t_Out = Fly4Flds2Frms(start+dur-4) + smpte;  // Out Frame
			if(t_In > t_Out)
				t_Out = t_In+2;

			InitPanelLines(EasyPanelPL,ReqFlyJog_IPL);		// Copy basic init data into panel

			EasyPanelPL[PLI_TITLE].Label = Title;
			EasyPanelPL[PLI_NAME].Label = Name;

			pl = &EasyPanelPL[PLI_SINGLE];		// Setup single slider (if wants 1 knob)
			if (dual)
				pl->Type = PNL_SKIP;
			else
			{
				t_In=clipfrms/2 + smpte;
				pl->Param = &t_In;
				pl->PropStart = smpte;
				pl->PropEnd = clipfrms + smpte - LENGTH_ADJUST;
				pl->Flags = PL_IN | PL_FLYER | PL_CFRAME | PL_AUDIO;
			}

			pl = &EasyPanelPL[PLI_DUAL];			// Setup dual slider (if wants 2 knobs)
			if (dual)
			{
				pl->Param = &t_In;
				pl->Param2 = &t_Out;
				pl->PropStart = smpte;
				pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
				pl->Flags = PL_IN | PL_DUAL | PL_FLYER | PL_CFRAME | PL_AUDIO;
			}
			else
				pl->Type = PNL_SKIP;

			pl = &EasyPanelPL[PLI_LENGTH];
			if (dual)
			{
				pl->Param = &t_Out;  // Diff
				pl->Param2 = &t_In;
				pl->G5 = (struct Gadget *)2; // Diff add-on
//				pl->Flags = PL_LEN;
			}
			else
				pl->Type = PNL_SKIP;


			MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
			MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

			succ = (FlyPanel(EditTop,EasyPanelPL,TUNE_NONE) == PAN_CONTINUE);

			if (succ)
			{
				if (intime)
					sprintf(intime,"%ld",t_In - smpte);
				if (outtime)
					sprintf(outtime,"%ld",t_Out - smpte + 2);
			}

			//~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			// Close panel (EndFindField)
			ESparams1.Data1=(LONG)FG;
			SendSwitcherReply(ES_PanelClose,&ESparams1);

			CurFG = NULL;
		}
		FreeProjectNode(FG);						// Free our counterfeit back up
	}

	return(succ);
}

//*******************************************************************
BOOL DoTellReqPanel(char *Title, char *line1, char *line2, char *line3)
{
	enum {				// PL indices for ReqTellPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_TEXT1,
		PLI_TEXT2,
		PLI_TEXT3,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	InitPanelLines(EasyPanelPL,ReqTell_IPL);		// Copy basic init data into panel

	EasyPanelPL[PLI_TITLE].Label = Title;
	EasyPanelPL[PLI_TEXT1].Label = line1;
	EasyPanelPL[PLI_TEXT2].Label = line2;
	EasyPanelPL[PLI_TEXT3].Label = line3;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	if(PAN_CANCEL==MiniPanel(NULL,EasyPanelPL,TUNE_NONE))
		return(FALSE);

	return(TRUE);
}


//*******************************************************************
BOOL DoButtonsReqPanel(char *Title, UBYTE count, char *labels[], UBYTE states[])
{
	enum {				// PL indices for ReqButtonsPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_BTN1,
		PLI_BTN2,
		PLI_BTN3,
		PLI_BTN4,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	struct PanelLine	*pl;
	int	i;

	InitPanelLines(EasyPanelPL,ReqButtons_IPL);		// Copy basic init data into panel

	EasyPanelPL[PLI_TITLE].Label = Title;

	for (i=0; i<4 ;i++)
	{
		pl = &EasyPanelPL[PLI_BTN1+i];

		if (i<count)
		{
//			pl->Type = PNL_CHECK;
			pl->Label = labels[i];
			pl->Param = (LONG *)states[i];
			pl->Align = (count==1)?PPOS_CENTER:PPOS_RIGHT;
		}
		else
			pl->Type = PNL_SKIP;
	}

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	if(PAN_CANCEL==MiniPanel(NULL,EasyPanelPL,TUNE_NONE))
		return(FALSE);

	for (i=0; i<count ;i++)
	{
		pl = &EasyPanelPL[PLI_BTN1+i];
		states[i] = (UBYTE)pl->Param;
	}

	return(TRUE);
}



//*******************************************************************
// This panel should also offer a way to save settings,
// then load them on the fly in the sequence.
static BOOL DoTBCPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for TBCPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_HORIZ,
		PLI_PHASE,
		PLI_HUE,
		PLI_BRIGHT,
		PLI_SAT,
		PLI_CONT,
		PLI_FADER,
		PLI_INPUT,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	enum {				// PL indices for XPTBCPL[]
		XPLI_TITLE,
		XPLI_DIVIDE1,
		XPLI_INPUT,
		XPLI_KEYMODE,
		XPLI_FADER,
		XPLI_DIVIDE2,
		XPLI_TERM,
		XPLI_DIVIDE3,
		XPLI_KEYER,
		XPLI_DIVIDE4,
		XPLI_ENCODER,
		XPLI_DIVIDE5,
		XPLI_DECODER,
		XPLI_PAD1,
		XPLI_DIVIDE6,
		XPLI_CONTINUE,
		XPLI_CANCEL,
	};

	LONG bri,con,sat,hue,cphas,hphas,fade,KeyM,
		dbri=0,dcon=63,dsat=63,dhue=0,dcphas=0x3FF,dhphas=870,dfade=127,
		term=0,dec=0,enc=0,key=0,type=PanType;
	struct PanelLine	*pl;

	ESparams2.Data1 =(LONG) HACK_TBCO;
	ESparams2.Data2 =(LONG) &TBC_dat;
	SendSwitcherReply(ES_Hack,&ESparams2);

	ESparams2.Data1 =(LONG) HACK_TBCR;
	ESparams2.Data2 =(LONG) &TBC_dat;
	SendSwitcherReply(ES_Hack,&ESparams2);

	bri = TBC_dat.Bright;
	con = TBC_dat.Contrast;
	sat = TBC_dat.Sat;
	hue = TBC_dat.Hue;
	cphas=TBC_dat.Phase;
	hphas=TBC_dat.HorAdj;
	fade = TBC_dat.Fader;

	key=0;
	if(TBC_dat.KeyerFlags&TBCKF_KEYONB)	key|=1<<1;
	if(TBC_dat.KeyerFlags&TBCKF_FADEROUT)	key|=1;
	KeyM=0;
	if(TBC_dat.KeyerFlags&TBCKF_MODE0)
		if(TBC_dat.KeyerFlags&TBCKF_MODE1)
			KeyM=2;
		else
			KeyM=1;

	term=0;
	if(TBC_dat.Term&TBCTF_FADERB)	term|=1<<4;
	if(TBC_dat.Term&TBCTF_FADERA)	term|=1<<3;
	if(TBC_dat.Term&TBCTF_OUT)		term|=1<<2;
	if(TBC_dat.Term&TBCTF_GENIN)	term|=1<<1;
	if(TBC_dat.Term&TBCTF_COMPIN)	term|=1;
	dec=0;
	if(TBC_dat.DecFlags&TBCDF_CHROMAAGC)	dec|=1<<2;
	if(TBC_dat.DecFlags&TBCDF_AGC)				dec|=1<<1;
	if(TBC_dat.DecFlags&TBCDF_MONOCHROME)	dec|=1;
	enc=0;
	if(TBC_dat.EncFlags&TBCEF_KILLCOLOR)	enc|=1<<2;
	if(TBC_dat.EncFlags&TBCEF_BARS)				enc|=1<<1;
	if(TBC_dat.Flags&TBCGF_BYPASS)				enc|=1;
	if(TBC_dat.Flags&TBCGF_FREEZE)				enc|=1<<3;

	CopyMem(&TBC_dat,&TBC_bak,sizeof(struct TBCctrl));

	InitPanelLines(EasyPanelPL,TBC_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_HORIZ];
	pl->Param		= &hphas;
	pl->Param2		= &dhphas;
	pl->PropStart	= 0;
	pl->PropEnd		= 909;
	pl->UserObj		= (APTR) TBC_HPHZ;
	pl->UserFun		= CTRL_TBCSet;

	pl = &EasyPanelPL[PLI_PHASE];
	pl->Param		= &cphas;
	pl->Param2		= &dcphas;
	pl->PropStart	= 0;
	pl->PropEnd		= 0x7FF;
	pl->UserObj		= (APTR) TBC_CPHZ;
	pl->UserFun		= CTRL_TBCSet;

	pl = &EasyPanelPL[PLI_HUE];
	pl->Param		= &hue;
	pl->Param2		= &dhue;
	pl->PropStart	= -64;
	pl->PropEnd		= 63;
	pl->UserObj		= (APTR) TBC_HUE;
	pl->UserFun		= CTRL_TBCSet;

	pl = &EasyPanelPL[PLI_BRIGHT];
	pl->Param		= &bri;
	pl->Param2		= &dbri;
	pl->PropStart	= -64;
	pl->PropEnd		= 63;
	pl->UserObj		= (APTR) TBC_BRT;
	pl->UserFun		= CTRL_TBCSet;

	dsat=63;
	pl = &EasyPanelPL[PLI_SAT];
	pl->Param		= &sat;
	pl->Param2		= &dsat;
	pl->PropStart	= 0;
	pl->PropEnd		= 127;
	pl->UserObj		= (APTR) TBC_SAT;
	pl->UserFun		= CTRL_TBCSet;

	dcon=63;
	pl = &EasyPanelPL[PLI_CONT];
	pl->Param		= &con;
	pl->Param2		= &dcon;
	pl->PropStart	= 0;
	pl->PropEnd		= 127;
	pl->UserObj		= (APTR) TBC_CON;
	pl->UserFun		= CTRL_TBCSet;

	pl = &EasyPanelPL[PLI_FADER];
	pl->Param		= &fade;
	pl->Param2		= &dfade;
	pl->PropStart	= 0;
	pl->PropEnd		= 255;
	pl->UserObj		= (APTR) TBC_FAD;
	pl->UserFun		= CTRL_TBCSet;

	pl = &EasyPanelPL[PLI_INPUT];
	pl->Param		= (long *)TBCSources;
	pl->PropStart	= TBC_Input[TBC_dat.InputSel];
	pl->PropEnd		= TBCSRC_NUM;
	pl->UserObj		= (APTR) TBC_INP;
	pl->UserFun		= CTRL_TBCSet;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	InitPanelLines(ExpertPanelPL,XPTBC_IPL);		// Copy basic init data into panel

	pl = &ExpertPanelPL[XPLI_INPUT];
	pl->Param		= (long *)TBCSources;
	pl->PropStart	= TBC_Input[TBC_dat.InputSel];
	pl->PropEnd		= TBCSRC_NUM;
	pl->UserObj		= (APTR) TBC_INP;
	pl->UserFun		= CTRL_TBCSet;

	pl = &ExpertPanelPL[XPLI_KEYMODE];
	pl->Param		= (long *)TBCKeyModes;
	pl->PropStart	= KeyM;
	pl->PropEnd		= TBCKEYM_NUM;
	pl->UserObj		= (APTR) TBC_KEYM;
	pl->UserFun		= CTRL_TBCSet;

	pl = &ExpertPanelPL[XPLI_FADER];
	pl->Param		= &fade;
	pl->Param2		= &dfade;
	pl->PropStart	= 0;
	pl->PropEnd		= 255;
	pl->UserObj		= (APTR) TBC_FAD;
	pl->UserFun		= CTRL_TBCSet;

	pl = &ExpertPanelPL[XPLI_TERM];
	pl->Param		= (ULONG *)term;
	pl->Param2		= (long *)TBCTerm;
	pl->PropStart	= 0;
	pl->PropEnd		= TBCTERM_NUM;
	pl->UserObj		= (APTR) TBC_TRM;
	pl->UserFun		= CTRL_TBCSet;

	pl = &ExpertPanelPL[XPLI_KEYER];
	pl->Param		= (ULONG *)key;
	pl->Param2		= (long *)TBCKeyer;
	pl->PropStart	= 0;
	pl->PropEnd		= TBCKEY_NUM;
	pl->UserObj		= (APTR) TBC_KEY;
	pl->UserFun		= CTRL_TBCSet;

	pl = &ExpertPanelPL[XPLI_ENCODER];
	pl->Param		= (ULONG *)enc;
	pl->Param2		= (long *)TBCEncoder;
	pl->PropStart	= 0;
	pl->PropEnd		= TBCENCOD_NUM;
	pl->UserObj		= (APTR) TBC_ENC;
	pl->UserFun		= CTRL_TBCSet;

	pl = &ExpertPanelPL[XPLI_DECODER];
	pl->Param		= (ULONG *)dec;
	pl->Param2		= (long *)TBCDecoder;
	pl->PropStart	= 0;
	pl->PropEnd		= TBCDECOD_NUM;
	pl->UserObj		= (APTR) TBC_DEC;
	pl->UserFun		= CTRL_TBCSet;

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);

	while(type > PAN_CONTINUE)
	{
		switch(type)
		{
			case PAN_EXPERT:
				type = MiniPanel(Edit,EasyPanelPL,TUNE_QUICK);
				EasyPanelPL[PLI_INPUT].PropStart	=TBC_Input[TBC_dat.InputSel];
				break;
			case PAN_EASY:
				type = MiniPanel(Edit,ExpertPanelPL,TUNE_FINE);
				ExpertPanelPL[XPLI_INPUT].PropStart	=TBC_Input[TBC_dat.InputSel];
				break;
		}
	}

	if(type==PAN_CANCEL)
	{
		CopyMem(&TBC_bak,&TBC_dat,sizeof(struct TBCctrl));
		ESparams2.Data1 =(LONG) HACK_TBCW;
		ESparams2.Data2 =(LONG) &TBC_dat;
		SendSwitcherReply(ES_Hack,&ESparams2);
		ESparams2.Data1 =(LONG) HACK_TBCC;
		ESparams2.Data2 =(LONG) &TBC_dat;
		SendSwitcherReply(ES_Hack,&ESparams2);
		return(FALSE);
	}
	ESparams1.Data1=(LONG)&Config;
	SendSwitcherReply(ES_SavePrefs,&ESparams1);

	ESparams2.Data1 =(LONG) HACK_TBCC;
	ESparams2.Data2 =(LONG) &TBC_dat;
	SendSwitcherReply(ES_Hack,&ESparams2);

	return(TRUE);
}


//*******************************************************************
static BOOL DoTweakPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for TweakPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_MODE,
		PLI_POSITION,
		PLI_CLOCK,
		PLI_COARSE,
		PLI_FINE,
//		PLI_PEDESTAL,
//		PLI_TOGGLE,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

//	char *sh[]={"Shift",""};
	int i,type;
	struct PanelLine	*pl;

	if(FlyerDriveCount==0) BuildFlyerList();

	// Ask Flyer for current tweek settings, put in each Hack struct
	// Also keep a copy in Bakhacks[], in case user CANCEL's
	for(i=0;i<TWEAK_CHANNELS;i++)
	{
		Hack=Hacks[i];
		Hack->hk_Flags |= HKF_READCALIB;
		ESparams2.Data1 =(LONG) HACK_TWEAK;
		ESparams2.Data2 =(LONG) Hack;  // Hack ptr
		SendSwitcherReply(ES_Hack,&ESparams2);
		Hack->hk_Flags &= ~HKF_READCALIB;
		CopyMem(Hack,BakHacks[i],sizeof(struct Hack));
	}

	InitPanelLines(EasyPanelPL,Tweak_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_MODE];
	pl->Param = (long *)Tweaks;// Popup
	pl->UserFun = CTRL_RecTest;// Popup f'n
	pl->PropStart=0;
	Hack=Hacks[pl->PropStart];
	pl->UserObj=(APTR)Hack;
	pl->PropEnd=TWEAK_CHANNELS;

	pl = &EasyPanelPL[PLI_POSITION];
	pl->Param = &(Hack->hk_Position) ;// EZ_NUM
	pl->UserFun = CTRL_Hack;
	pl->UserObj = (APTR)Hack;
	pl->PropStart=-910;
	pl->PropEnd=910;

	pl = &EasyPanelPL[PLI_CLOCK];
	pl->Param		=&(Hack->hk_Clock) ;	// EZ_NUM
	pl->UserFun		=CTRL_Hack;
	pl->UserObj		=(APTR)Hack;
	pl->PropStart	=0;
	pl->PropEnd		=3;

	pl = &EasyPanelPL[PLI_COARSE];
	pl->Param		=&(Hack->hk_Coarse) ;	// EZ_NUM
	pl->UserFun		=CTRL_Hack;
	pl->UserObj		=(APTR)Hack;
	pl->PropStart	=0;
	pl->PropEnd		=9;

	pl = &EasyPanelPL[PLI_FINE];
	pl->Param		=&(Hack->hk_Fine) ;	// EZ_NUM
	pl->UserFun		=CTRL_Hack;
	pl->UserObj		=(APTR)Hack;
	pl->PropStart	=0;
	pl->PropEnd		=7;

//	pl = &EasyPanelPL[PLI_PEDESTAL];
//	pl->Param		= &(Hack->hk_Pedestal) ;	// EZ_NUM
//	pl->UserFun		=CTRL_Hack;
//	pl->UserObj		=(APTR)Hack;
//	pl->PropStart	=0;
//	pl->PropEnd		=255;

//	pl = &EasyPanelPL[PLI_TOGGLE];
//	pl->Param=(long *)Hack->hk_Shift;
//	pl->Param2=(long *)sh;
//	pl->PropEnd=1;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	type=MiniPanel(Edit,EasyPanelPL,TUNE_NONE);
	if(type==PAN_CANCEL)
	{
		//DUMPMSG("Restoring");

		// Restore Flyer tweek channels to original settings on panel entry
		for(i=0;i<TWEAK_CHANNELS;i++)
		{
			Hack=Hacks[i];
			CopyMem(BakHacks[i],Hack,sizeof(struct Hack));
			ESparams2.Data1 =(LONG) HACK_TWEAK;
			ESparams2.Data2 =(LONG) Hack;  // Hack ptr
			SendSwitcherReply(ES_Hack,&ESparams2);
		}
	}
	else
	{
		//DUMPMSG("Saving");

		// Write latest tweek values once more, with instruction to save to Flyer's NOVRAM
		for(i=0;i<TWEAK_CHANNELS;i++)
		{
			Hack=Hacks[i];
			Hack->hk_Flags |= HKF_SAVE;				// Save these
			ESparams2.Data1 =(LONG) HACK_TWEAK;
			ESparams2.Data2 =(LONG) Hack;  // Hack ptr
			SendSwitcherReply(ES_Hack,&ESparams2);
			Hack->hk_Flags &= ~HKF_SAVE;				// Save these
		}
	}
	DHD_InitPlay("",0);
	return(TRUE);
}


//*******************************************************************
BOOL DoSetupPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for SetupPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_CTRLMON,
		PLI_DIVIDE2,
		PLI_TERM,
		PLI_DIVIDE3,
		PLI_GPI,
		PLI_FLYOUT,
		PLI_ENHQ5,
		PLI_ENHQ6,
		PLI_PAD1,
		PLI_DIVIDE4,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG	I=0,M=0,T=0xF,trig=0,type=PanType,oM;
	LONG	HQ5,HQ5was,HQ6,HQ6was;
	struct PanelLine	*pl;

	//DUMPMSG("Enter Setup Panel");

	ESparams1.Data1=(LONG)&Config;
	SendSwitcherReply(ES_GetPrefs,&ESparams1);
	//DUMPHEXIL(" Got Prefs ",(LONG)&Config,"\\");
	M=(Config.Flags1&(1<<spB_PrvwOLay)) ? 1:0 ;
	oM=M;
	if(Config.Flags1&(1<<spB_FlyerVID3))
		I |= 1;
	if(Config.Flags1&(1<<spB_FlyerVID4))
		I |= 2;

	T=(UBYTE) Config.Termination;
	trig=(UBYTE) Config.GPI;

	if (FlyerBase)
		FlyerOptions(0,0,&FlyerOpts);		// Get Flyer options flags
	else
		FlyerOpts = 0;

	HQ5was = HQ5 = (FlyerOpts & FLYOPTF_NOT_HQ5)?0:1;		// Inverted flag!	
	HQ6was = HQ6 = (FlyerOpts & FLYOPTF_NOT_HQ6)?0:1;		// Inverted flag!   



// No need to save this any longer, as we have a visible button now
//	if(!GlobalFastDrives)
//		GlobalFastDrives = (Config.Flags1&(1<<spB_FastDrive)) ? TRUE:FALSE;
//	else
//		Config.Flags1 |= (1<<spB_FastDrive);

	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		InitPanelLines(EasyPanelPL,Setup_IPL);		// Copy basic init data into panel

		pl = &EasyPanelPL[PLI_CTRLMON];
		pl->Param	=(LONG *)&M;
		pl->UserFun	=CTRL_SetFace;
		pl->Flags	=PL_SMREF; // requester with interface change

		pl = &EasyPanelPL[PLI_TERM];
		pl->Param	=(LONG *)T;
		pl->Param2	=(LONG *)Inputs;
		pl->PropEnd	=4;
		pl->UserFun	=CTRL_SetTermination;

		pl = &EasyPanelPL[PLI_GPI];
		pl->Param		=(LONG *)GPImodes;
		pl->PropStart	=trig;
		pl->PropEnd		=3;
		pl->UserFun		=CTRL_SetGPI;

		pl = &EasyPanelPL[PLI_FLYOUT];
		pl->Param	= (LONG *)I;
		pl->Param2	=(LONG *)FlyInputs;
		pl->PropEnd	=2;
		pl->UserFun	=CTRL_SetFlyOut;
		if	(!FlyerBase)
			pl->Type	=PNL_SKIP;

		pl = &EasyPanelPL[PLI_ENHQ5];
		pl->Param	= (LONG *)HQ5;
		pl->UserFun	= CTRL_SetHQ5;
		if	(!FlyerBase)
			pl->Type	=PNL_SKIP;


		pl = &EasyPanelPL[PLI_ENHQ6];
		pl->Param	= (LONG *)HQ6;
		pl->UserFun	= CTRL_SetHQ6;
		if	(!FlyerBase)
			pl->Type	=PNL_SKIP;


		MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
		MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

		type = MiniPanel(Edit,EasyPanelPL,TUNE_NONE);
	}

	if(type==PAN_CONTINUE)
	{
		Config.GPI = (UBYTE) EasyPanelPL[PLI_GPI].PropStart;
		if((LONG)EasyPanelPL[PLI_FLYOUT].Param&1)
			Config.Flags1 |= (1<<spB_FlyerVID3);
		else Config.Flags1 &= ~(1<<spB_FlyerVID3);
		if((LONG)EasyPanelPL[PLI_FLYOUT].Param&2)
			Config.Flags1 |= (1<<spB_FlyerVID4);
		else Config.Flags1 &= ~(1<<spB_FlyerVID4);
		Config.Termination=(UBYTE)EasyPanelPL[PLI_TERM].Param;

		ESparams1.Data1=(LONG)&Config;
		SendSwitcherReply(ES_SetPrefs,&ESparams1);
		SendSwitcherReply(ES_SavePrefs,&ESparams1);

		HQ5 = (LONG)EasyPanelPL[PLI_ENHQ5].Param;
		HQ6 = (LONG)EasyPanelPL[PLI_ENHQ6].Param;
		if (FlyerBase)				// && (HQ5 != HQ5was))
		{
			if (HQ6)
			{
				HQ5=1;
				FlyerOpts &= ~FLYOPTF_NOT_HQ5;	// Enable
				FlyerOpts &= ~FLYOPTF_NOT_HQ6;	// Enable	
			}
			else
				FlyerOpts |= FLYOPTF_NOT_HQ6; 	// Disable
				
			if	(HQ5) 
				FlyerOpts &= ~FLYOPTF_NOT_HQ5;	// Enable
			else
				FlyerOpts |= FLYOPTF_NOT_HQ5;		// Disable--need a warning message here!
						
			FlyerOptions(0,1,&FlyerOpts);			// Set new options (and save)
		}	
			
		return(TRUE);
	}
	else
	{
		Config.Termination = (UBYTE)T;
		Config.Flags1 = (UBYTE) ( oM!=0 ? (1<<spB_PrvwOLay):0);
		if(I!=(Config.Flags1>>1)&0x3)
		{
			if(I&1) Config.Flags1 |= (1<<spB_FlyerVID3);
			else Config.Flags1 &= ~(1<<spB_FlyerVID3);
			if(I&2) Config.Flags1 |= (1<<spB_FlyerVID4);
			else Config.Flags1 &= ~(1<<spB_FlyerVID4);
		}

		ESparams1.Data1=(LONG)&Config;
		SendSwitcherReply(ES_SetPrefs,&ESparams1);
		return(TRUE);
	}

	return(FALSE);
}


//*******************************************************************
BOOL DoOptionsPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for OptionsPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_USER,
		PLI_DFDET,
		PLI_FAILDET,
		PLI_FINEPNLS,
		PLI_CGON,
		PLI_CGOFF,
		PLI_PAD,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG	user,userwas,type=PanType;
	LONG	DFdetect,DFwas,faildetect,failwas,finepanels,finewas;
	UBYTE	CGOfftype=1,CGOntype=1,CGOfftypewas=1,CGOntypewas=1;
	struct PanelLine	*pl;
	BOOL	resave = FALSE;

	//DUMPMSG("Enter Options Panel");

	user = userwas = UserPrefs.UserLevel;
	failwas = faildetect = (UserPrefs.SeqFlags & SFF_STOPONERR)?1:0;
	finewas = finepanels = (UserPrefs.EditFlags & EFF_EXPPANELS)?1:0;

	CGOfftype = CGOfftypewas = UserPrefs.CGKeyFlagsOff;
	CGOntype = CGOntypewas = UserPrefs.CGKeyFlagsOn;
	

	if (FlyerBase)
		FlyerOptions(0,0,&FlyerOpts);		// Get Flyer options flags
	else
		FlyerOpts = 0;
	DFwas = DFdetect = (FlyerOpts & FLYOPTF_DropFramDet)?1:0;

	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		InitPanelLines(EasyPanelPL,Options_IPL);		// Copy basic init data into panel

		pl = &EasyPanelPL[PLI_USER];
		pl->Param		=(LONG *)UserTypes;
		pl->PropStart	=user;
		pl->PropEnd		=2;

		pl = &EasyPanelPL[PLI_DFDET];
		pl->Param = (LONG *)DFdetect;
		if	(!FlyerBase)
			pl->Type =PNL_SKIP;

		pl = &EasyPanelPL[PLI_FAILDET];
		pl->Param = (LONG *)faildetect;
		if	(!FlyerBase)
			pl->Type =PNL_SKIP;

		pl = &EasyPanelPL[PLI_FINEPNLS];
		pl->Param = (LONG *)finepanels;

		pl = &EasyPanelPL[PLI_CGON];
		pl->Param		=(LONG *)CGONOFFTypes;
		pl->PropStart	= CGOntype;
		pl->PropEnd		=2;

		pl = &EasyPanelPL[PLI_CGOFF];
		pl->Param		=(LONG *)CGONOFFTypes;
		pl->PropStart	= CGOfftype;
		pl->PropEnd		=2;

		MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
		MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

		type = MiniPanel(Edit,EasyPanelPL,TUNE_NONE);
	}

	if(type==PAN_CONTINUE)
	{
		user = EasyPanelPL[PLI_USER].PropStart;
		if (user != userwas)
		{
			UserPrefs.UserLevel = user;
			switch (user)
			{
				case USRLVL_IDIOT:
					UserPrefs.WarnFlags = WARNFLAGS_IDIOT;			// All warnings
					break;
				case USRLVL_GENIUS:
					UserPrefs.WarnFlags = WARNFLAGS_GENIUS;		// No warnings
					break;
			}
			resave = TRUE;
		}


//if CG key on/off flags       
//changed update the UserPrefs

		CGOntype = EasyPanelPL[PLI_CGON].PropStart;		
		if (CGOntype != CGOntypewas)							
		{
			UserPrefs.CGKeyFlagsOn = CGOntype;
			resave = TRUE;
		}

		CGOfftype = EasyPanelPL[PLI_CGOFF].PropStart;
		if (CGOfftype != CGOfftypewas)
		{
			UserPrefs.CGKeyFlagsOff = CGOfftype;
			resave = TRUE;
		}




		faildetect = (LONG)EasyPanelPL[PLI_FAILDET].Param;
		if (faildetect != failwas)
		{
			if (faildetect)
				UserPrefs.SeqFlags |= SFF_STOPONERR;
			else
				UserPrefs.SeqFlags &= ~SFF_STOPONERR;
			resave = TRUE;
		}

		finepanels = (LONG)EasyPanelPL[PLI_FINEPNLS].Param;
		if (finepanels != finewas)
		{
			if (finepanels)
				UserPrefs.EditFlags |= EFF_EXPPANELS;
			else
				UserPrefs.EditFlags &= ~EFF_EXPPANELS;
			resave = TRUE;
		}

		if (resave)
			SavePrefsData(&UserPrefs);		// Save back out


		/*** Options saved on Flyer card ***/

		DFdetect = (LONG)EasyPanelPL[PLI_DFDET].Param;
		if ((FlyerBase) && (DFdetect != DFwas))
		{
			if (DFdetect)
				FlyerOpts |= FLYOPTF_DropFramDet;
			else
				FlyerOpts &= ~FLYOPTF_DropFramDet;

			FlyerOptions(0,1,&FlyerOpts);			// Set new options (and save)
		}

		return(TRUE);
	}
	else
	{
	}

	return(FALSE);
}


//*******************************************************************
static BOOL DoRexxPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for RexxPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_PARAMS,
		PLI_TOGGLE,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	ULONG DLay,B,TM=0;
	struct PanelLine	*pl;

	InitPanelLines(EasyPanelPL,Rexx_IPL);		// Copy basic init data into panel

	*RexxArgs=0;
	if(FG)
	{
		DLay = B = Flds2Frms(GetValue(FG,TAG(Delay)));
		TM=GetValue(FG,TAG(TimeMode));
		GetTable(FG,TAG_CommandLine,RexxArgs,COMMENT_MAX);
	}
	PutValue(FG,TAG(Asynchronous),0);
	EasyPanelPL[PLI_TOGGLE].Type = PNL_SKIP;

	pl = &EasyPanelPL[PLI_PARAMS];
	pl->Param = (LONG *)RexxArgs;
	pl->PropEnd = COMMENT_MAX;
	pl->PropStart = 0; // this changes when string does
	pl->G5 = (struct Gadget *)250; // Custom string width

	pl = &EasyPanelPL[PLI_LOCKTO];
	pl->Param = (LONG *)TimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 2;

	pl = &EasyPanelPL[PLI_TIME];
	pl->Param = &DLay;
	pl->PropStart = 0;
	pl->PropEnd = 600;
	pl->Flags = PL_DEL;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	if(PAN_CANCEL==MiniPanel(Edit,EasyPanelPL,TUNE_NONE))
		return(FALSE);
	if(EasyPanelPL[PLI_PARAMS].PropStart)
		PutTable(FG,TAG_CommandLine,RexxArgs,COMMENT_MAX);
	if(DLay!=B)
		PutValue(FG,TAG(Delay),Frms2Flds(DLay));
	if(EasyPanelPL[PLI_LOCKTO].PropStart!=TM)
		PutValue(FG,TAG(TimeMode),EasyPanelPL[PLI_LOCKTO].PropStart);
	return(TRUE);
}

UBYTE SMF2FCM[] = {3,0,1,2};  // convert between wacky FCountMode and gadget
UBYTE FCM2SMF[] = {1,2,3,0};  // S,M,F,V -> 3,0,1,2 .. FCM2SMF[SMF2FCM[x]] == x

// Max time that can be shown HH:MM:SS:FF (account for dropped frames)
#define BIG_MAX			(100*60*60*30 -2*(6000-600) -1)
#define BIG_MAX_DELAY	BIG_MAX
#define MAX_DURATION 60000   // !!! arbitrary Duration Limit


// All effects panels begin here (and are dispatched)
// CT_FXANIM, CT_FXILBM, CT_FXALGO, CT_VIDEOANIM, CT_KEYEDANIM
//*******************************************************************
static BOOL DoFXPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	LONG blogic;

	//DUMPMSG("*DoFXpanel*");

	if(FG)
	{
		blogic = GetValue(FG,TAG(ButtonELHlogic));
		//DUMPHEXIL("ButtLog=",blogic,"\\");

		if ((blogic == AFXT_Logic_EncoderAlpha)	// Graphic overlay
		||  (blogic == AFXT_Logic_TDEfx)				// Non-transitional effects
		||  (GetValue(FG,TAG(LoopAnims))))			// Looping ILBM/ANIM
			return(DoFXOverlayPanel(Edit,FG));		// ...all use this control panel code

		return(DoFXtransPanel(Edit,FG));				// Normal Anims/Algos
	}
	return(FALSE);
}


// All transitional effects
static BOOL DoFXtransPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for TransFXPL[]
		PLI_CROUTON,
		PLI_TUNE,
		PLI_LABEL,
		PLI_PAD2,
		PLI_DIVIDE1,
		PLI_SPEED,
		PLI_FIXLEN,
		PLI_VARLEN,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	enum {				// PL indices for XPTransFXPL[]
		XPLI_CROUTON,
		XPLI_TUNE,
		XPLI_LABEL,
		XPLI_PAD2,
		XPLI_DIVIDE1,
		XPLI_SPEED,
		XPLI_FIXLEN,
		XPLI_VARLEN,
		XPLI_TAKEPT,
		XPLI_ASRCLEN,
		XPLI_BSRCLEN,
		XPLI_COLOR,
//		XPLI_STARTKEY,
		XPLI_DIVIDE2,
		XPLI_CONTINUE,
		XPLI_CANCEL,
	};

	char Label[MAX_PANEL_STR];
	LONG fcnts[4]={45,30,15,9};
	LONG zero=0,smfv=2,type=PanType,speed=1,fcount, color=0,pmode=0;	//fxlen;
	LONG var=0,maxlen=300;
	BOOL Matte=FALSE,Border=FALSE;
	struct PanelLine	*pl;
	ULONG	asrclen=0,bsrclen=0,asrcfrac,bsrcfrac,takefrac,takept;
	ULONG	alen_hold=0,blen_hold=0,take_hold=0;

	if(FG)
	{
		strcpy(Label,"Transition: ");				// Algorithmic transitional effect
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);

		speed = GetValue(FG,TAG(FCountMode));
		speed &= 0x00000003;			// 3,0,1,2 == S,M,F,V

	 	fcnts[0]=GetValue(FG,TAG(NumFramesSlow));
		fcnts[1]=GetValue(FG,TAG(NumFramesMedium));
		fcnts[2]=GetValue(FG,TAG(NumFramesFast));
		fcnts[3]=GetValue(FG,TAG(NumFramesVariable));
		var = fcnts[3];		// Do we allow variable durations?

		pmode = GetValue(FG,TAG(PanelMode));
		if (pmode==1)	type = PAN_EXPERT;

		if( (GetValue(FG,TAG(ForceDefaultMatte))==0) && (color=GetValue(FG,TAG(MatteColor))) )
		{
			color -= 1; // map 1-9 to 0-8 , or -1 -> -2 for CustomColor
			if(color>8) color=8;
			Matte=TRUE;
		}
		else if( GetValue(FG,TAG(AlgoFXborder)) && (color=GetValue(FG,TAG(BorderColor))) )
		{
			color -= 1; // map 1-8 to 0-7 , or -1 -> -2 for CustomColor
			if(color>7) color=7;
			Border=TRUE;
		}
		if (var)
			maxlen = Flds2Frms(GetValue(FG,TAG(MaxDuration)));
	}

	smfv = FCM2SMF[speed];		// smfv=gadget button SMFV=0123
	fcount = fcnts[smfv];

	InitPanelLines(EasyPanelPL,TransFX_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_CROUTON];
	pl->Label = Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap

	EasyPanelPL[PLI_LABEL].Label =""; // Label;

	pl = &EasyPanelPL[PLI_SPEED];
	pl->Param  = &smfv;					// SMFV choice
	pl->Param2 = fcnts;					// Array of field counts
	pl->PropStart =0 ;	// PLine (time) to update, 0 for FXTIME
	if (var)
		pl->PropStart =(LONG)&EasyPanelPL[PLI_VARLEN];	// PLine (time) to update

	pl = &EasyPanelPL[PLI_FIXLEN];
	if (var)
		pl->Type = PNL_SKIP;
	else
	{
		pl->Param = &fcount;	// Time slider
		pl->Param2 = &zero;
	}

	pl = &EasyPanelPL[PLI_VARLEN];
	if (var)
	{
		pl->Param = &fcount;			// Time slider
//		pl->Param2 = (LONG *)&EasyPanelPL[PLI_SPEED];	// FXSpeed gadg to set to V
		pl->PropStart = 1;
		pl->PropEnd = maxlen;	// (maxlen>=330 ? maxlen:330);
		pl->Flags = PL_LEN;
		pl->Partners = &EasyPanelPL[PLI_SPEED];	// FXSpeed gadg to set to V
	}
	else pl->Type = PNL_SKIP;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);
	pl = &EasyPanelPL[PLI_TUNE];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_FINE_TUNE;		// General button code for "fine tune"
	pl->Flags = PL_GENBUTT;

// ~~*~~*~~*~~| This fence separates the XP from the EZ, it doesn't do much but they feel better |~~~*~~~*~~~|

	InitPanelLines(ExpertPanelPL,XPTransFX_IPL);		// Copy basic init data into panel

	pl = &ExpertPanelPL[XPLI_CROUTON];
	pl->Label =Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap

	ExpertPanelPL[XPLI_LABEL].Label = ""; //Label;

	pl = &ExpertPanelPL[XPLI_SPEED];
	pl->Param =&smfv;						// SMFV choice
	pl->Param2 =fcnts;						// Array of field counts
	if (var)
		pl->PropStart =(LONG)&ExpertPanelPL[XPLI_VARLEN];	// PLine (time) to update
	else
		pl->PropStart =0;			// PLine (time) to update, 0 for FXTIME
	pl->Partners = &(ExpertPanelPL[XPLI_ASRCLEN]);		// Speed changes propagate on

	pl = &ExpertPanelPL[XPLI_FIXLEN];
	if (var)
		pl->Type = PNL_SKIP;
	else
	{
		pl->Param = &fcount;	// Time slider
		pl->Param2 = &zero;
	}

	pl = &ExpertPanelPL[XPLI_VARLEN];
	if (var)
	{
		pl->Param = &fcount;			// Time slider
//		pl->Param2 = (LONG *)&ExpertPanelPL[XPLI_SPEED];	// FXSpeed gadg to set to V
		pl->PropStart = 1;
		pl->PropEnd = maxlen;	// (maxlen>=330 ? maxlen:330);
		pl->Flags = PL_LEN;
		pl->Partners = &ExpertPanelPL[XPLI_SPEED];	// FXSpeed gadg to set to V
//		pl->Partners = &(ExpertPanelPL[XPLI_ASRCLEN]);		// Speed changes propagate on
	}
	else pl->Type = PNL_SKIP;

	pl = &ExpertPanelPL[XPLI_COLOR];
	if (Matte)
	{
		pl->Param = (long *)Colors;		// POPUP
		pl->PropEnd = COLOR_NUM - 1; // don't include "Special"
		pl->PropStart = color<0 ? 0 : color;
		if((GetValue(FG,TAG(CustomMatteColor))!=0))
		{
			pl->PropEnd = COLOR_NUM;
			pl->PropStart = color<0 ? (COLOR_NUM - 1) : color;
		}
	}
	else if (Border)
	{
		pl->Param = (long *)Colors;		// POPUP
		pl->PropEnd = COLOR_NUM - 2; // don't include "Special"
		pl->PropStart = color<0 ? 0 : color;
		if((GetValue(FG,TAG(CustomBorderColor))!=0))
		{
			pl->PropEnd = COLOR_NUM -1 ; // should swap ptrs for "Snow" and Special" here
			pl->PropStart = color<0 ? (COLOR_NUM - 2) : color;
		}
	}
	else
		pl->Type = PNL_SKIP;

	takefrac = GetValue(FG,TAG(TakeOffset));
	/***** HACK! UNTIL CROUTONDEFS.a SETS THIS AS DEFAULTS!!!! *******/
//	if (takefrac == 0)
//		takefrac = 0x80000000;		// 50%
	take_hold = takefrac;
	pl = &ExpertPanelPL[XPLI_TAKEPT];
	pl->Param = &takept;
	pl->Param2 = &takefrac;
	pl->PropStart = 1;
	pl->PropEnd = fcount;
	pl->Flags = PL_FRAC32;

	asrcfrac = GetValue(FG,TAG(ASourceLen));
	bsrcfrac = GetValue(FG,TAG(BSourceLen));
//	/***** HACK! UNTIL CROUTONDEFS.a SETS THESE AS DEFAULTS!!!! *******/
//	if ((asrcfrac == 0) && (bsrcfrac == 0))
//		asrcfrac = bsrcfrac = 0xFFFFFFFF;

	alen_hold = asrcfrac;
//	asrclen = ((asrcfrac>>16) * fcount + 0x8000) >>16;
	pl = &ExpertPanelPL[XPLI_ASRCLEN];
	pl->Param = &asrclen;
	pl->Param2 = &asrcfrac;
	pl->PropStart = 1;
	pl->PropEnd = fcount;
	pl->Flags = PL_FRAC32;
	pl->Partners = &(ExpertPanelPL[XPLI_BSRCLEN]);		// Speed changes propagate on

	blen_hold = bsrcfrac;
//	bsrclen = ((bsrcfrac>>16) * fcount + 0x8000) >>16;
	pl = &ExpertPanelPL[XPLI_BSRCLEN];
	pl->Param = &bsrclen;
	pl->Param2 = &bsrcfrac;
	pl->PropStart = 1;
	pl->PropEnd = fcount;
	pl->Flags = PL_FRAC32;
	pl->Partners = &(ExpertPanelPL[XPLI_TAKEPT]);		// Speed changes propagate on

//	pl = &ExpertPanelPL[XPLI_STARTKEY];
//	pl->Param = &D;	// Start Time slider
//	pl->PropStart = 1;
//	pl->PropEnd = maxlen;	// (maxlen>=330 ? maxlen:330);

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);
	pl = &ExpertPanelPL[XPLI_TUNE];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_QUICK_TUNE;	// General button code for "quick tune"
	pl->Flags = PL_GENBUTT;

	while(type > PAN_CONTINUE)
	{
		switch(type)
		{
			case PAN_EXPERT:
				pmode=1;
				type = MiniPanel(Edit,ExpertPanelPL,TUNE_QUICK);
				break;
			case PAN_EASY:
				pmode=0;
				type = MiniPanel(Edit,EasyPanelPL,TUNE_FINE);
				break;
		}
	}

	if(type==PAN_CONTINUE)
	{
		if(Matte && (color!= ExpertPanelPL[XPLI_COLOR].PropStart))
		{
			PutValue(FG,TAG(MatteColor), (ExpertPanelPL[XPLI_COLOR].PropStart < COLOR_NUM -1) ? ExpertPanelPL[XPLI_COLOR].PropStart+1 : -1 );
			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_BG;
			SendSwitcherReply(ES_FGcommand,&ESparams2);
		}
		else if( Border && (color!= ExpertPanelPL[XPLI_COLOR].PropStart))
		{
			PutValue(FG,TAG(BorderColor), (ExpertPanelPL[XPLI_COLOR].PropStart < COLOR_NUM -2) ? ExpertPanelPL[XPLI_COLOR].PropStart+1 : -1 );
			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_BORDER;
			SendSwitcherReply(ES_FGcommand,&ESparams2);
		}

		if(smfv != FCM2SMF[speed])
		{
			PutValue(FG,TAG(FCountMode),SMF2FCM[smfv]); // SMF2FCM[3]=2 = variable
			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_FCOUNT;
			SendSwitcherReply(ES_FGcommand,&ESparams2);
		}
		if((smfv==3) && (var))
		{
			PutValue(FG,TAG(VariableFCount),Frms2Flds(fcount));   // Frames -> Fields
			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_FCOUNT;
			SendSwitcherReply(ES_FGcommand,&ESparams2);
		}

		if (alen_hold != asrcfrac)
		{
//			fxlen = Flds2Frms(GetValue(FG,TAG(NumFields)));
//			DUMPUDECL("New len=",fxlen,"\\");
//			DUMPHEXIL("Frac32 was=",asrcfrac,"\\");
//			asrcfrac = ((asrclen<<16)/fxlen)<<16;
			//DUMPHEXIL("Frac32=",asrcfrac,"\\");
			PutValue(FG,TAG(ASourceLen),asrcfrac);
		}
		if (blen_hold != bsrcfrac)
		{
//			fxlen = Flds2Frms(GetValue(FG,TAG(NumFields)));
//			bsrcfrac = ((bsrclen<<16)/fxlen)<<16;
			PutValue(FG,TAG(BSourceLen),bsrcfrac);
		}
		if (take_hold != takefrac)
		{
//			fxlen = Flds2Frms(GetValue(FG,TAG(NumFields)));
//			takefrac = ((takept<<16)/fxlen)<<16;
			PutValue(FG,TAG(TakeOffset),takefrac);
		}

		PutValue(FG,TAG(PanelMode),pmode);  // ...just following orders
		return(TRUE);
	}
	return(FALSE);
}




//=============================================================
// HandleMultiCroutons
//=============================================================
void HandleMultiCroutonsSp(struct EditWindow *Edit,LONG NewSp)
{
	struct ExtFastGadget *curfg,*fg;
	LONG	time,fcount,speed=1;
	BOOL	lockem,redraw = FALSE;
	LONG	fcnts[4]={45,30,15,9};


	curfg=(struct ExtFastGadget *)CurFG;		// Hilited crouton (if any)
	if (!curfg)
	{
		curfg = FindFirstHilited(Edit);		// If none, pick first hilited as "curfg"
	}

	if (curfg)							// Must have at least one crouton hilited, or we bail out
	{
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
				case CT_FXANIM:
				case CT_FXILBM:
				case CT_FXALGO:
				case CT_FXCR:

					speed = GetValue(fg,TAG(FCountMode)) & 3;		// 3,0,1,2 == S,M,F,V
					fcnts[3]=GetValue(fg,TAG(NumFramesSlow));
					fcnts[0]=GetValue(fg,TAG(NumFramesMedium));
					fcnts[1]=GetValue(fg,TAG(NumFramesFast));

					if(fcnts[NewSp]!=0)
					{	 
						PutValue(fg,TAG(FCountMode),NewSp); // SMF2FCM[3]=2 = variable
						ESparams2.Data1=(LONG)fg;
						ESparams2.Data2=FGC_FCOUNT;
						SendSwitcherReply(ES_FGcommand,&ESparams2);
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



// Looping/Non-looping graphic overlays (also used for non-trans FX)
static BOOL DoFXOverlayPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for OlayFXPL[]
		PLI_CROUTON,
		PLI_DIVIDE1,
		PLI_SPEED,
		PLI_FXLEN,
		PLI_COLOR,
		PLI_DIVIDE2,
		PLI_LENGTH,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_DIVIDE3,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG DurWas=0,Dly=12,DlyWas,type=PAN_EASY,Dur=69,TM,TMwas,blogic,Color=0;
	LONG smfv=0,speed=1,fxlen=0,dummy;
	LONG fcnts[4] = {45,30,15,9};
	BOOL Matte=FALSE,loops=FALSE,refresh=FALSE;
	char Label[MAX_PANEL_STR];
	struct PanelLine	*pl;

	//DUMPMSG("*** OVERLAY PANEL ***");

	CommentBuf[0]=0;
	if(FG)
	{
		blogic = GetValue(FG,TAG(ButtonELHlogic));

		if (GetValue(FG,TAG(LoopAnims)))
			loops = TRUE;

		if (blogic == AFXT_Logic_TDEfx)
			strcpy(Label,"Effect: ");				// Non-transitional effect
		else if (loops)
			strcpy(Label,"Looping Overlay: ");	// Looping graphic overlay
		else
			strcpy(Label,"Graphic Overlay: ");	// One-time graphic overlay

		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		Dur = DurWas = Flds2Frms(GetValue(FG,TAG(Duration)));
		//DUMPUDECL("Looped duration=",Dur," frames\\");
//		if (loops && (Dur==0))		// Don't allow "forever's" in a sequence
//		{
//			Dur=300;
//			PutValue(FG,TAG(Duration),Frms2Flds(Dur));
//		}
		Dly = DlyWas = Flds2Frms(GetValue(FG,TAG(Delay)));
		TM = TMwas = GetValue(FG,TAG(TimeMode));
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		// Can this guy take a user matte color?
		if ( (GetValue(FG,TAG(ForceDefaultMatte))==0) && (Color=GetValue(FG,TAG(MatteColor))) )
		{
			Color--;		// map 1-9 to 0-8 , or -1 -> -2 for CustomColor
			if (Color>8) Color=8;		// Prevent values above "Snow"
			Matte=TRUE;						// Can present this popup
			//DUMPMSG("Matte");
		}

		speed = GetValue(FG,TAG(FCountMode)) & 3;		// 3,0,1,2 == S,M,F,V
		smfv=FCM2SMF[speed];									// 0,1,2,3 == S,M,F,V
		fcnts[0]=GetValue(FG,TAG(NumFramesSlow));
		//DUMPUDECL("Slow=",fcnts[0]," ");
		fcnts[1]=GetValue(FG,TAG(NumFramesMedium));
		//DUMPUDECL("Med=",fcnts[1]," ");
		fcnts[2]=GetValue(FG,TAG(NumFramesFast));
		//DUMPUDECL("Fast=",fcnts[2]," \\");
		fcnts[3]=0;

		//DUMPUDECL("FSlow=",GetValue(FG,TAG(SlowFCount))," ");
		//DUMPUDECL("FMed=",GetValue(FG,TAG(MedFCount))," ");
		//DUMPUDECL("FFast=",GetValue(FG,TAG(FastFCount)),"\\");
	}
	fxlen = fcnts[FCM2SMF[speed]];


	InitPanelLines(EasyPanelPL,OlayFX_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_CROUTON];
	pl->Label = Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX;

	pl = &EasyPanelPL[PLI_LENGTH];		// This value only for looping types
	if (loops)
	{
//		pl->Type = PNL_EZTIME;
		pl->Param = &Dur;
		pl->PropStart = 1;
		pl->PropEnd = BIG_MAX;
		pl->Flags = PL_LEN;			// So "LEN" hotkey can find/activate this
	}
	else
		pl->Type = PNL_SKIP;

	pl = &EasyPanelPL[PLI_LOCKTO];
	pl->Param = (LONG *)TimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 2;

	pl = &EasyPanelPL[PLI_TIME];
	pl->Param = &Dly;
	pl->PropStart = 1;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_DEL;				// So "DEL" hotkey can find/activate this

	pl = &EasyPanelPL[PLI_SPEED];
	pl->Param  = &smfv;					// SMFV choice
	pl->Param2 = fcnts;					// Array of field counts
	pl->PropStart = NULL;				// PLine (time) to update

	dummy = 0;
	pl = &EasyPanelPL[PLI_FXLEN];
	if (loops)
		pl->Label = "Loop Time  ";		// For looping ones
	else
		pl->Label = "     Length  ";	// For others

	pl->Param = &fxlen;					// FX time
	pl->Param2 = &dummy;
	pl->PropEnd = -1;

	pl = &EasyPanelPL[PLI_COLOR];			// Only if matte color is selectable
	if (Matte)
	{
		pl->Type = PNL_POPUP;
		pl->Param = (long *)Colors;		// POPUP
		pl->PropEnd = COLOR_NUM - 1;		// don't include "Special"
		pl->PropStart = Color<0 ? 0 : Color;
		if((GetValue(FG,TAG(CustomMatteColor))!=0))
		{
			pl->PropEnd = COLOR_NUM;
			pl->PropStart = Color<0 ? (COLOR_NUM - 1) : Color;
		}
	}
	else
		pl->Type = PNL_SKIP;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	//DUMPMSG("MiniPanel");

	type = MiniPanel(Edit, EasyPanelPL,TUNE_NONE);

	//DUMPUDECL("Back w/",type," \\");

	if (type==PAN_CONTINUE)
	{
		if( (EasyPanelPL[PLI_CROUTON].PropStart) )
			PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		if ((loops) && (Dur != DurWas))
		{
			//DUMPUDECL("New looped duration=",Dur," frames\\");
			PutValue(FG,TAG(Duration),Frms2Flds(Dur));
			refresh = TRUE;
		}

		TM = EasyPanelPL[PLI_LOCKTO].PropStart;
		if(TM != TMwas)
			PutValue(FG,TAG(TimeMode),TM);

		if(Dly != DlyWas)
			PutValue(FG,TAG(Delay),Frms2Flds(Dly));

		if (smfv != FCM2SMF[speed])
		{
			PutValue(FG,TAG(FCountMode),SMF2FCM[smfv]);
			if (!loops)
			{
				//DUMPUDECL("Fixed Length=",fxlen," frames\\");
				PutValue(FG,TAG(Duration),Frms2Flds(fxlen));
			}
			refresh = TRUE;
		}

		if (refresh)
		{
			//DUMPMSG("---REFRESH---");
			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_FCOUNT;
			SendSwitcherReply(ES_FGcommand,&ESparams2);	// Updates selected FG
		}

		if(Matte && (Color != EasyPanelPL[PLI_COLOR].PropStart))
		{
			Color = EasyPanelPL[PLI_COLOR].PropStart;
			if (Color < COLOR_NUM-1)
				Color++;
			else
				Color = -1;		// Special custom color
			PutValue(FG,TAG(MatteColor), Color);

			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_BG;				// Notice! I changed matte color
			SendSwitcherReply(ES_FGcommand,&ESparams2);	// Updates selected FG
		}

		return(TRUE);
	}
	return(FALSE);
}


// CT_FXCR
static BOOL DoFXCRPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for CFXPL[]
		PLI_CROUTON,
		PLI_LABEL,
		PLI_DIVIDE1,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_LENGTH,
		PLI_SPEED,
		PLI_CYCLES,
		PLI_POSITION,
		PLI_MODES,
		PLI_OPTIONS,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG TBar=0,TBarb=0,B=2,type=PanType,Speed=1,S,SP[4]={45,30,15,9},
		D=0, Cmod=0,Dmod=0, Cyc=0, TM,TMb;
//	LONG t_In = 300;
	char Label[MAX_PANEL_STR]="ChromaFX: ";
	struct PanelLine	*pl;
	struct TagMess	tagTBar={TAG(TBarPosition),NULL,4,0},
		tagDmod={TAG(DataMode),NULL,4,0},
		tagCmod={TAG(ColorMode),NULL,4,0},
		tagCyc={TAG(CycleMode),NULL,4,0};

	InitPanelLines(EasyPanelPL,CFX_IPL);		// Copy basic init data into panel

	if(FG)
	{

		SP[3]=0; //Flds2Frms(GetValue(FG,TAG(NumFramesVariable)));
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);

		Speed=GetValue(FG,TAG(FCountMode));

		Speed&=0x00000003; // 3,0,1,2 == S,M,F,V
		B=FCM2SMF[Speed];	 // B=gadget button SMFV=0123
	 	SP[0]=1; //Flds2Frms(GetValue(FG,TAG(NumFramesSlow)));
		SP[1]=1; //Flds2Frms(GetValue(FG,TAG(NumFramesMedium)));
		SP[2]=1; //Flds2Frms(GetValue(FG,TAG(NumFramesFast)));


		D = Flds2Frms(GetValue(FG,TAG(Delay)));
		//DUMPUDECL("Delay= ",D," \\");

		Cyc=GetValue(FG,TAG(CycleMode));
		//DUMPUDECL("Delay= ",Cyc," \\");

		Cmod=GetValue(FG,TAG(ColorMode));
		//DUMPUDECL("ColorMode= ",Cmod," \\");

		Dmod=GetValue(FG,TAG(DataMode));
		//DUMPUDECL("DataMode= ",Dmod," \\");

		TM=(TMb=GetValue(FG,TAG(TimeMode)));
		//DUMPUDECL("TimeMode= ",TM," \\");

		TBar=(TBarb=GetValue(FG,TAG(TBarPosition)));
		//DUMPUDECL("TBarPos= ",TBar," \\");

		S = Flds2Frms(GetValue(FG,TAG(Duration)));
		//DUMPUDECL("Duration= ",S," \\");

		//if(S==0) S=60;

	}

	pl = &EasyPanelPL[PLI_CROUTON];
	pl->Label =Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap

	EasyPanelPL[PLI_LABEL].Label =""; // Label;

	pl = &EasyPanelPL[PLI_LOCKTO];
	pl->Param = (LONG *)CfxTimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 3;

	pl = &EasyPanelPL[PLI_TIME];
	pl->Param = &D;	// Start Time slider
	pl->PropStart = 1;
	pl->PropEnd =  BIG_MAX;
	pl->Flags = PL_DEL;

	pl = &EasyPanelPL[PLI_LENGTH];
	pl->Param = &S;	// Time slider
	pl->PropStart = 1;
	pl->PropEnd = MAX_DURATION;
	pl->Flags = PL_LEN;

	pl = &EasyPanelPL[PLI_SPEED];
	pl->Param =&B;						// SMFV choice
	pl->Param2 =SP;						// Array of field counts

	pl = &EasyPanelPL[PLI_CYCLES];
	pl->Param		= (long *)CFX_Cycles;		// POPUP
	pl->PropEnd		= 4;
	pl->PropStart	= Cyc;
	pl->UserFun		= CTRL_SetTag;
	tagCyc.tm_Val	= (ULONG *)&EasyPanelPL[PLI_CYCLES].PropStart;
	tagCyc.tm_FG	= FG;
	pl->UserObj		= (APTR)&tagCyc;

	pl = &EasyPanelPL[PLI_POSITION];
	pl->Param = &TBar;	// Start Time slider
	pl->PropStart = 1;
	pl->PropEnd = 511;
	pl->UserFun = CTRL_SetTag;
	tagTBar.tm_Val = (ULONG *)EasyPanelPL[PLI_POSITION].Param;
	tagTBar.tm_FG = FG;
	pl->UserObj = (APTR)&tagTBar;

	pl = &EasyPanelPL[PLI_MODES];
	pl->Param = (long *)CFX_CModes;		// POPUP
	pl->PropEnd = 2;
	pl->PropStart = Cmod;
	pl->UserFun = CTRL_SetTag;
	tagCmod.tm_Val = (ULONG *)&EasyPanelPL[PLI_MODES].PropStart;
	tagCmod.tm_FG = FG;
	pl->UserObj = (APTR)&tagCmod;

	pl = &EasyPanelPL[PLI_OPTIONS];
	pl->Param = (long *)CFX_DModes;		// POPUP
	pl->PropEnd = 2;
	pl->PropStart = Dmod;
	pl->UserFun = CTRL_SetTag;
	tagDmod.tm_Val = (ULONG *)&EasyPanelPL[PLI_OPTIONS].PropStart;
	tagDmod.tm_FG = FG;
	pl->UserObj = (APTR)&tagDmod;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	while(type > PAN_CONTINUE)
	{
		switch(type)
		{
			case PAN_EXPERT:
			case PAN_EASY:
				type = MiniPanel(Edit,EasyPanelPL,TUNE_NONE);
				break;
		}
	}
	TM=EasyPanelPL[PLI_LOCKTO].PropStart;
	if(type==PAN_CONTINUE)
	{
		if(B!=FCM2SMF[Speed])
			PutValue(FG,TAG(FCountMode),SMF2FCM[B]); // SMF2FCM[3]=2 = variable
		if(EasyPanelPL[PLI_CYCLES].PropStart != Cyc)
			PutValue(FG,TAG(CycleMode),EasyPanelPL[PLI_CYCLES].PropStart);
		if(EasyPanelPL[PLI_MODES].PropStart != Cmod)
			PutValue(FG,TAG(ColorMode),EasyPanelPL[PLI_MODES].PropStart);
		if(EasyPanelPL[PLI_OPTIONS].PropStart != Dmod)
			PutValue(FG,TAG(DataMode),EasyPanelPL[PLI_OPTIONS].PropStart);
		if(TBar!=TBarb)
			PutValue(FG,TAG(TBarPosition),TBar); 
		PutValue(FG,TAG(Delay),Frms2Flds(D));
	
		PutValue(FG,TAG(Duration),Frms2Flds(S));
		//DUMPUDECL("Duration= ",Flds2Frms(GetValue(FG,TAG(Duration)))," \\");
	

		if(TMb != TM)
			PutValue(FG,TAG(TimeMode),TM);

		ESparams2.Data1=(LONG)FG;
		ESparams2.Data2=FGC_FCOUNT;
		SendSwitcherReply(ES_FGcommand,&ESparams2);
		return(TRUE);
	}
	else
	{
		PutValue(FG,TAG(CycleMode),Cyc);
		PutValue(FG,TAG(ColorMode),Cmod);
		PutValue(FG,TAG(DataMode),Dmod);
		PutValue(FG,TAG(TBarPosition),TBarb);
	}
	return(FALSE);
}


// CT_AUDIO
static BOOL DoAUDIOPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for AudClipPL[]
		PLI_CROUTON,
		PLI_TUNE,
		PLI_ENV,
		PLI_PADLOCK,
		PLI_PLAY,
		PLI_DIVIDE1,
		PLI_INOUT,
		PLI_LENGTH,
		PLI_PAD1,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_PROCCLIP,
		PLI_CUTCLIP,
		PLI_CANCEL,
	};

	enum {				// PL indices for XPAudClipPL[]
		XPLI_CROUTON,
		XPLI_TUNE,
		XPLI_ENV,
		XPLI_PADLOCK,
		XPLI_PLAY,
		XPLI_DIVIDE1,
		XPLI_INOUT,
		XPLI_LENGTH,
		XPLI_PAD1,
		XPLI_LOCKTO,
		XPLI_TIME,
		XPLI_VOLUME,
		XPLI_BALANCE,
		XPLI_PAD2,
		XPLI_FADEIN,
		XPLI_FADEOUT,
		XPLI_AUDCHANS,
		XPLI_DIVIDE2,
		XPLI_CONTINUE,
		XPLI_PROCCLIP,
		XPLI_CUTCLIP,
		XPLI_CANCEL,
	};

	struct SaveParams {			// Save parameters here during panel
		LONG	AudIn;
		LONG	AudOut;
		LONG	StartTime;
		LONG	AudStartField;
		LONG	AudDuration;
		LONG	Attack;
		LONG	Decay;
		LONG	Volume1;
		LONG	Volume2;
	} SP;

	LONG FadeIn=0,FadeOut=0,V=0,P=0,V1=0xFFC0,V2=0xFFC0,A=800,B,TM,TMb=0,
	t_In,t_Out,type=PanType,Time,S=0,AudioOn=1,pmode=0,smpte=0;
	UWORD	i;
	char Label[MAX_PANEL_STR]="", *pan[]={"L","R"};
	struct SMPTEinfo	si;

#ifdef INCAUDENV
	struct AudioEnv 	ae,AudioEnvelope,Save_AudioEnvelope;
#else 
	
#endif

	struct PanelLine	*pl;
	
	//DUMPMSG("DoAUDIOPanel");

	// What are these kludges?
	SP.AudIn = t_In  = 36;
	SP.AudOut = t_Out = 69;
	SP.StartTime = 0;
	SP.AudStartField = 0;

	CommentBuf[0]=0;
	if(FG)
	{
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
// This is a constant value
		Time = A = Fly4Flds2Frms(GetValue(FG,TAG(RecFields)));
		if(A<2) Time=A=4;

// Stash original values
		SP.StartTime = GetValue(FG,TAG(Delay));
		SP.AudStartField = GetValue(FG,TAG(AudioStart));
		if(!(SP.AudDuration = GetValue(FG,TAG(AudioDuration)) )) SP.AudDuration=A-SP.AudStartField;
		SP.Attack = GetValue(FG,TAG(AudioAttack));
		SP.Decay = GetValue(FG,TAG(AudioDecay));
		SP.Volume1 = V1 = GetValue(FG,TAG(AudioVolume1));
		SP.Volume2 = V2 = GetValue(FG,TAG(AudioVolume2));

// Getting audio envelope tag 		
#ifdef INCAUDENV
		GetTable(FG,TAG_AudEnv16,&AudioEnvelope,sizeof(AudioEnvelope));
		memcpy(&Save_AudioEnvelope,&AudioEnvelope,sizeof(AudioEnvelope));
		DUMPUDECW("AudioEnvelope.Keysused = ",AudioEnvelope.Keysused,"\\");
#endif

		pmode = GetValue(FG,TAG(PanelMode));
		if(pmode==1) type=PAN_EXPERT;
		TM=(TMb=GetValue(FG,TAG(TimeMode)));
		if(GetTable(FG,TAG_SMPTEtime,(UBYTE *)&si,sizeof(struct SMPTEinfo)))
		{
			smpte = EVEN(SMPTEToLong(&si));
//			smpte = SMPTEToLong(&si);
			//DUMPUDECB("SMPTE Start: ",si.SMPTEhours,":");
			//DUMPUDECB("",si.SMPTEminutes,":");
			//DUMPUDECB("",si.SMPTEseconds,":");
			//DUMPUDECB("",si.SMPTEframes,"  = ");
			//DUMPUDECL(" ",smpte," frames \\");
		}

		AudioOn = GetValue(FG,TAG(AudioOn));
		//DUMPUDECL("Audio on ",AudioOn,"\\");
			

// These are values that are modified by the panel
		SP.AudIn = t_In = Fly4Flds2Frms(SP.AudStartField) + smpte;			 // In Frame
		SP.AudOut = t_Out = Fly4Flds2Frms(SP.AudStartField+SP.AudDuration-4) + smpte;  // Out Frame
		FadeIn = Flds2Frms(SP.Attack);
		FadeOut= Flds2Frms(SP.Decay);
		S = Flds2Frms(SP.StartTime);
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		CurAudioSet.AudioOn=AudioOn;
		if( HAS_STEREO(AudioOn) && IS_STEREO(AudioOn) )
		{
			CurAudioSet.Mode=AMODE_STEREO;
			CurAudioSet.Pan1 = PAN_LEFT;
			CurAudioSet.Pan2 = PAN_RIGHT;
			PutValue(FG,TAG(AudioPan1),CurAudioSet.Pan1);
			PutValue(FG,TAG(AudioPan2),CurAudioSet.Pan2);
		}
		else if( HAS_LEFT(AudioOn) || IS_LEFT(AudioOn) )
		{
			CurAudioSet.Mode=AMODE_LEFT;
			//CurAudioSet.Pan1 = 0;
			CurAudioSet.Pan1 = GetValue(FG,TAG(AudioPan1));
			//DUMPMSG("WHY IS THIS BEING SET TO 0?");
			//PutValue(FG,TAG(AudioPan1),CurAudioSet.Pan1);
		}
		else if( HAS_RIGHT(AudioOn) || IS_RIGHT(AudioOn) )
		{
			CurAudioSet.Mode=AMODE_RIGHT;
			//CurAudioSet.Pan2 = 0;
			CurAudioSet.Pan2 = GetValue(FG,TAG(AudioPan2));
			//DUMPMSG("WHY IS THIS BEING SET TO 0?");
			//PutValue(FG,TAG(AudioPan2),CurAudioSet.Pan2);
		}
//		else Haven't dealt with pathologic situations
	}
	else strncat(Label,"Canned Laughter",MAX_PANEL_STR);

	//DUMPHEXIW("Old Balance: ",CurAudioSet.Balance,"\\");

	CurAudioSet.FG = FG;
	CurAudioSet.V1 = V1;
	CurAudioSet.V2 = V2;

	P=GetBalance(&CurAudioSet);
	V=GetVolume(&CurAudioSet);

	//DUMPHEXIW("New Balance: ",CurAudioSet.Balance,"\\");

	InitPanelLines(EasyPanelPL,AudClip_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_CROUTON];
	pl->Label = Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX;
//	pl->UserFun=CTRL_Play;
//	pl->UserObj=(APTR)FG;
//	pl->Flags=PL_PLAY;

	pl = &EasyPanelPL[PLI_PLAY];
	pl->UserFun=CTRL_Play;
	pl->UserObj=(APTR)FG;
	pl->Flags=PL_PLAY;

	pl = &EasyPanelPL[PLI_LENGTH];
	pl->Param =  &t_Out;
	pl->Param2 = &t_In;
	pl->G5 =(struct Gadget *) 2; // diff add-on...
//	pl->PropStart = PANEL_LENGTHX<<16;
//	pl->PropStart += 12 + PIN_YOFF;
//	pl->UserObj = (APTR)1;

	pl = &EasyPanelPL[PLI_INOUT];
	pl->Param = &t_In;
	pl->Param2 = &t_Out;
	pl->PropStart = smpte;
	pl->PropEnd = smpte + A - LENGTH_ADJUST;  // Min length= 1 colorframe
	pl->Flags = PL_IN | PL_AUD1 | PL_DUAL | PL_CFRAME | PL_FLYER;

	pl = &EasyPanelPL[PLI_LOCKTO];
	pl->Param = (LONG *)TimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 3;		// Also gets PROG TIME!

	pl = &EasyPanelPL[PLI_TIME];
	pl->Param = &S;
	pl->PropStart = 0;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_DEL;

	pl = &EasyPanelPL[PLI_PROCCLIP];
	pl->Param =(LONG *)GB_PROCESS;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	pl = &EasyPanelPL[PLI_CUTCLIP];
	pl->Param =(LONG *)GB_CUT;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);
	pl = &EasyPanelPL[PLI_TUNE];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_FINE_TUNE;		// General button code for "fine tune"
	pl->Flags = PL_GENBUTT;

	pl = &EasyPanelPL[PLI_ENV];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_AUDIOENV;		// General button code for "fine tune"
	pl->Flags = PL_GENBUTT;


	//if we are not includeing audio env panels then make button type skip.(4.2)
#ifndef INCAUDENV
	pl->Type=PNL_SKIP;
#endif


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//

	InitPanelLines(ExpertPanelPL,XPAudClip_IPL);		// Copy basic init data into panel

	pl = &ExpertPanelPL[XPLI_CROUTON];
	pl->Label = Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX;
//	pl->UserFun=CTRL_Play;
//	pl->UserObj=(APTR)FG;
//	pl->Flags=PL_PLAY;

	pl = &ExpertPanelPL[XPLI_PLAY];
	pl->UserFun=CTRL_Play;
	pl->UserObj=(APTR)FG;
	pl->Flags=PL_PLAY;

	pl = &ExpertPanelPL[XPLI_LENGTH];
	pl->Param = &t_Out;
	pl->Param2 = &t_In;
	pl->G5 =(struct Gadget *) 2; // diff add-on...
//	pl->PropStart = PANEL_LENGTHX<<16;
//	pl->PropStart += 12 + PIN_YOFF;
//	pl->UserObj = (APTR)1; // Flag for custom DIFF positioning

	pl = &ExpertPanelPL[XPLI_INOUT];
	pl->Param = &t_In;
	pl->Param2 = &t_Out;
	pl->PropStart = smpte;
	pl->PropEnd = smpte + A - LENGTH_ADJUST;
	pl->Flags = PL_IN | PL_AUD1 | PL_DUAL | PL_CFRAME | PL_FLYER;

	pl = &ExpertPanelPL[XPLI_LOCKTO];
	pl->Param = (LONG *)TimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 3;

	pl = &ExpertPanelPL[XPLI_TIME];
	pl->Param = &S;
	pl->PropStart = 0;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_DEL;

	pl = &ExpertPanelPL[XPLI_VOLUME];
	pl->Param = &CurAudioSet.Volume;
//	pl->Param2 = (LONG *)&(ExpertPanelPL[XPLI_AUDCHANS]); // Balance PL
	pl->PropStart = 0;
	pl->PropEnd = 100;
	pl->Flags = PL_AUD1|PL_AUD2;
	pl->UserFun=CTRL_SetVolume;
	pl->UserObj=(APTR)&CurAudioSet;

	pl = &ExpertPanelPL[XPLI_BALANCE];
//	pl->Param =&CurAudioSet.Volume;  // !!! Unnecessary in CTRL_SetBalance???
	pl->Param2 = (long *) pan;
//	pl->PropStart = CurAudioSet.Balance;
	B=CurAudioSet.Balance;
	pl->Param = &B;  // Should move initial value to Param
	pl->UserFun= CTRL_SetBalance;
	pl->UserObj=(APTR)&CurAudioSet;

	pl = &ExpertPanelPL[XPLI_FADEIN];
	pl->Param = &FadeIn;
	pl->PropStart = 0;
	pl->PropEnd = MAX_AUD_FADE;
	pl->Flags = PL_AUD1;  // means Attack on EZLen types

	pl = &ExpertPanelPL[XPLI_FADEOUT];
	pl->Param = &FadeOut;
	pl->PropStart = 0;
	pl->PropEnd = MAX_AUD_FADE;
	pl->Flags = PL_AUD2;  // means Decay on EZLen types

	pl = &ExpertPanelPL[XPLI_AUDCHANS];
	pl->Param = (LONG *)Channels;
	pl->PropStart = CurAudioSet.Mode;
	pl->PropEnd = 3;
	pl->UserFun=CTRL_SetPan;
	pl->UserObj=(APTR)&CurAudioSet;

	pl = &ExpertPanelPL[XPLI_PROCCLIP];
	pl->Param =(LONG *)GB_PROCESS;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	pl = &ExpertPanelPL[XPLI_CUTCLIP];
	pl->Param =(LONG *)GB_CUT;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);
	pl = &ExpertPanelPL[XPLI_TUNE];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_QUICK_TUNE;	// General button code for "quick tune"
	pl->Flags = PL_GENBUTT;


	pl = &ExpertPanelPL[XPLI_ENV];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_AUDIOENV;		// General button code for "fine tune"
	pl->Flags = PL_GENBUTT;
	

	//if we are not includeing audio env panels then make button type skip.(4.2)
#ifndef INCAUDENV
	pl->Type=PNL_SKIP;
#endif


	while(type > PAN_CONTINUE)
	{
		//DUMPUDECL("B4 Type:	",type,"	");
		//DUMPUDECL("PanelMode: ",pmode,"\\ ");
		switch(type)
		{
			case PAN_EXPERT:
				pmode=1;
				pl = &ExpertPanelPL[XPLI_LOCKTO];
				pl->PropStart = TM;
				type = FlyPanel(Edit,ExpertPanelPL,TUNE_QUICK);
				TM = pl->PropStart;
				break;
			case PAN_EASY:
				pmode=0;
				pl = &EasyPanelPL[PLI_LOCKTO];
				pl->PropStart = TM;
				type = FlyPanel(Edit,EasyPanelPL,TUNE_FINE);
				TM = pl->PropStart;
				break;
			case PAN_PROCESS:
				DoProcClipPanel(Edit,FG);
				type=PAN_CANCEL;
				break;
			case PAN_CUTUP:
				DoCuttingPanel(Edit,FG,FALSE,NULL);		// (Lookup FG name)
				type=PAN_CANCEL;
				break;
#ifdef INCAUDENV
			case PAN_ENVL:
				ValidEnvTag(&AudioEnvelope,t_In,t_Out,0);	
				DoEnvPanel(Edit,FG,t_In,t_Out,FadeOut,FadeIn,&AudioEnvelope);
				if (pmode==1)
					type=PAN_EXPERT;
				else
					type=PAN_EASY;
				break;
#endif
		}
		//DUMPUDECL("After Type:	",type,"	");
		//DUMPUDECL("PanelMode: ",pmode,"\\ ");
	}

	if(type==PAN_CONTINUE) // Set non-real-time adjusted values
	{
		if(t_In!=SP.AudIn)
		{
			PutValue(FG,TAG(AudioStart),Frms2Flds(t_In-smpte));
		 	PutValue(FG,TAG(AudioDuration),Frms2Flds(t_Out+2-t_In));
		}
		else if(t_Out!=SP.AudOut)
		{
		 	PutValue(FG,TAG(AudioDuration),Frms2Flds(t_Out+2-t_In));
		}
		if(TMb != TM)
		{
			PutValue(FG,TAG(TimeMode),TM);
			if (TM == TIMEMODE_ABSTIME)
				((struct ExtFastGadget *)FG)->SymbolFlags |= SYMF_LOCKED;
			else
				((struct ExtFastGadget *)FG)->SymbolFlags &= ~SYMF_LOCKED;
			ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)FG));
		}
		if( Flds2Frms(SP.StartTime) != S )
			PutValue(FG,TAG(Delay),Frms2Flds(S));
		if( Flds2Frms(SP.Attack) != FadeIn )
			PutValue(FG,TAG(AudioAttack),Frms2Flds(FadeIn));
		if( Flds2Frms(SP.Decay) != FadeOut )
			PutValue(FG,TAG(AudioDecay),Frms2Flds(FadeOut));
		if( (EasyPanelPL[PLI_CROUTON].PropStart) || (ExpertPanelPL[XPLI_CROUTON].PropStart) )

		PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
		PutValue(FG,TAG(PanelMode),pmode);  // ...just following orders


		//DUMPHEXIW("ae-before ",(WORD)ae.Flags,"\\");
		//DUMPHEXIL ("Switcher Reply ",GetTable(FG,TAG_AudEnv16,&ae,sizeof(ae)),"\\");
		//DUMPHEXIW("ae-after ",(WORD)ae.Flags,"\\");

/*
		for(i=1;i<=AudioEnvelope.Keysused;i++)
		{
			DUMPUDECW("Key Number ",i,"\\");
			DUMPUDECL("Flags      ",AudioEnvelope.AEKeys[i].Flags,"\\");
			DUMPUDECL("GoTime     ",AudioEnvelope.AEKeys[i].GoTime,"\\");
			DUMPUDECL("NumOfFlds  ",AudioEnvelope.AEKeys[i].NumOfFlds,"\\");
			DUMPUDECW("Vol1       ",AudioEnvelope.AEKeys[i].VOL1,"\\");
			DUMPUDECW("Vol2       ",AudioEnvelope.AEKeys[i].VOL2,"\\");
		
		}

		DUMPUDECW("CP-Keys used ",ae.Keysused,"\\");
*/


//****** Rember to pass audio settings on

		AudioOn = GetValue(FG,TAG(AudioOn));

//********************************




#ifdef	INCAUDENV
		ValidEnvTag(&AudioEnvelope,t_In,t_Out,0);	
		PutTable(FG,TAG_AudEnv16,&AudioEnvelope,sizeof(AudioEnvelope));
		DUMPHEXIW("Keysused ",(WORD)AudioEnvelope.Keysused,"\\");
		//now update the audio on tags.
		AudioOn = GetValue(FG,TAG(AudioOn));

		if(AudioEnvelope.Flags)
		{
			AudioOn |= AUDF_AudEnvEnabled;
		}
		else
		{
			AudioOn &= ~AUDF_AudEnvEnabled;
		}
#endif
		

		PutValue(FG,TAG(AudioOn),AudioOn);
		return(TRUE);
	}
	else if(type==PAN_CANCEL)  // reset real-time adjusted values to old values
	{
		PutValue(FG,TAG(Delay),				SP.StartTime);
		PutValue(FG,TAG(AudioStart),		SP.AudStartField);
		PutValue(FG,TAG(AudioDuration),	SP.AudDuration);
		PutValue(FG,TAG(AudioAttack),		SP.Attack);
		PutValue(FG,TAG(AudioDecay),		SP.Decay);
		PutValue(FG,TAG(AudioVolume1),	SP.Volume1);
		PutValue(FG,TAG(AudioVolume2),	SP.Volume2);

		PutValue(FG,TAG(AudioOn),AudioOn);
		ESparams1.Data1 =(LONG) FG;
		SendSwitcherReply(ES_ChangeAudio,&ESparams1);
	}
	return(FALSE);
}


// CT_VIDEO
static BOOL DoVIDEOPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for ClipPL[]
//		PLI_TITLE,
		PLI_CROUTON,
		PLI_TUNE,
		PLI_ENV,
		PLI_PAD1,
		PLI_LOCKON,
		PLI_LOCKTIME,

		PLI_PLAY,
//		PLI_LENGTH,

		PLI_DIVIDE1,
		PLI_VIDINOUT,
		PLI_LENGTH,

//		PLI_USEENV,
		PLI_AUDON,

		PLI_DIVIDE3,
		PLI_CONTINUE,
		PLI_PROCCLIP,
		PLI_CUTCLIP,
		PLI_CANCEL,
	};

	enum {				// PL indices for XPClipPL[]
//		XPLI_TITLE,
		XPLI_CROUTON,
		XPLI_TUNE,
		XPLI_ENV,
		XPLI_PAD1,
		XPLI_LOCKON,
		XPLI_LOCKTIME,
		XPLI_PLAY,
//		XPLI_LENGTH,
		XPLI_DIVIDE1,
		XPLI_VIDINOUT,
		XPLI_LENGTH,
		XPLI_PAD2,
		XPLI_AUDIODIVIDE,
		XPLI_AUDINOUT,
		XPLI_AUDLEN,
		XPLI_VOLUME,
		XPLI_BALANCE,
		XPLI_MOVE1,
		XPLI_FADEIN,
		XPLI_AUTOIN,
		XPLI_FADEOUT,
		XPLI_AUTOOUT,
		XPLI_AUDCHANS,
//		XPLI_USEENV,
		XPLI_DIVIDE3,
		XPLI_CONTINUE,
		XPLI_PROCCLIP,
		XPLI_CUTCLIP,
		XPLI_CANCEL,
	};

	struct SaveParams {			// Save parameters here during panel
		LONG	VidIn;
		LONG	VidOut;
		LONG	VidFadeTime;		//???
		LONG	VidStartField;
		LONG	VidDuration;
		LONG	AudStartField;
		LONG	AudDuration;
		LONG	AudIn;
		LONG	AudOut;
		LONG	Volume1;
		LONG	Volume2;
		LONG	Attack;
		LONG	Decay;
		LONG	LockOn;
		LONG	LockTime;
		LONG	AutoIn;
		LONG	AutoOut;
	} SP;

	LONG BBBB,Vol=0,PPPP,vol1=0xFFFF,vol2=0x8000,AudioOn=1;
	LONG t_In,t_Out,A_In,A_Out,AudFadeIn=0,AudFadeOut=0;
	LONG type=PanType,pmode=0,Relate=0,smpte=0,clipfrms=800,locktime,lockon;
	LONG autoin,autoout,useenv=0;

	char Label[MAX_PANEL_STR]="";
	char *pan[]={"L","R"};
	char *aud[]={"Play Audio "};
//	char *lock[]={"Lock "};
	BOOL Jam_On=TRUE;
	struct PanelLine *pl;	//apl;
	struct SMPTEinfo si;
//	struct ExtFastGadget *pfg;
	struct AudioEnv 	ae,AudioEnvelope,Save_AudioEnvelope;

	InitPanelLines(EasyPanelPL,Clip_IPL);			// Copy basic init data into panel
	InitPanelLines(ExpertPanelPL,XPClip_IPL);		// Copy basic init data into panel

	// What are these kludges?
	SP.VidIn  = t_In  = 36;
	SP.VidOut = t_Out = 69;
	SP.VidFadeTime = 0;
	SP.VidStartField = 36;

	CommentBuf[0]=0;

	if(FG)
	{
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
// This is a constant value
		clipfrms = Flds2Frms(GetValue(FG,TAG(RecFields)));  // Clip Frame Length (in frames)
		if (clipfrms<2)
			clipfrms=4;
// Stash original values
		SP.VidStartField = GetValue(FG,TAG(ClipStartField));
		if( !(SP.VidDuration = GetValue(FG,TAG(Duration))) )
			SP.VidDuration = clipfrms - SP.VidStartField;
		SP.AudStartField= GetValue(FG,TAG(AudioStart));
		if( !(SP.AudDuration= GetValue(FG,TAG(AudioDuration))) )
			SP.AudDuration = clipfrms - SP.AudStartField;
		SP.Volume1  = vol1 = GetValue(FG,TAG(AudioVolume1));
		SP.Volume2 = vol2 = GetValue(FG,TAG(AudioVolume2));
		SP.Attack = GetValue(FG,TAG(AudioAttack));
		SP.Decay = GetValue(FG,TAG(AudioDecay));
		autoin = SP.AutoIn = (GetValue(FG,TAG(AudioFadeFlags)) & AUDFADEF_AutoIn) ? 1:0;
		autoout = SP.AutoOut = (GetValue(FG,TAG(AudioFadeFlags)) & AUDFADEF_AutoOut) ? 1:0;
		SP.LockOn = lockon = (GetValue(FG,TAG(TimeMode))==TIMEMODE_ABSTIME)?1:0;
		SP.LockTime = Flds2Frms(GetValue(FG,TAG(Delay)));
		if (lockon)
			locktime = SP.LockTime;
		else
			locktime = Flds2Frms(GetStartTimeInSequence(FG));	// Find time in current sequence

// Getting audio envelope tag 		

#ifdef INCAUDENV
		GetTable(FG,TAG_AudEnv16,&AudioEnvelope,sizeof(AudioEnvelope));
		memcpy(&Save_AudioEnvelope,&AudioEnvelope,sizeof(AudioEnvelope));
		DUMPUDECW("AudioEnvelope.Keysused = ",AudioEnvelope.Keysused,"\\");
#endif

		AudioOn = GetValue(FG,TAG(AudioOn));
		pmode = GetValue(FG,TAG(PanelMode));
		if (pmode==1)
			type=PAN_EXPERT;

		if(GetTable(FG,TAG_SMPTEtime,(UBYTE *)&si,sizeof(struct SMPTEinfo)))
		{
//			smpte = SMPTEToLong(&si);
			smpte = EVEN(SMPTEToLong(&si));
			//DUMPUDECB("SMPTE Start: ",si.SMPTEhours,":");
			//DUMPUDECB("",si.SMPTEminutes,":");
			//DUMPUDECB("",si.SMPTEseconds,":");
			//DUMPUDECB("",si.SMPTEframes,"  = ");
			//DUMPUDECL(" ",smpte," frames \\");
		}

// These are values that are modified by the panel
		SP.VidIn = t_In  = Fly4Flds2Frms(SP.VidStartField) + smpte;			 // In Frame
		SP.VidOut = t_Out = Fly4Flds2Frms(SP.VidStartField+SP.VidDuration-4) + smpte;  // Out Frame
		if(t_In > t_Out)
			t_Out = t_In+2;
//		SP.VidFadeTime = BBBB =((GetValue(FG,TAG(FadeInVideo)) !=0) ? 0:1); // FadeIn flag
		SP.AudIn = A_In  = Fly4Flds2Frms(SP.AudStartField)  + smpte;
		SP.AudOut= A_Out = Fly4Flds2Frms(SP.AudStartField+SP.AudDuration-4) + smpte;
		AudFadeIn = Flds2Frms(SP.Attack);
		AudFadeOut= Flds2Frms(SP.Decay);
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		CurAudioSet.AudioOn=AudioOn;
		if( HAS_STEREO(AudioOn) && IS_STEREO(AudioOn) )
		{
			CurAudioSet.Mode=AMODE_STEREO;
			CurAudioSet.Pan1 = PAN_LEFT;
			CurAudioSet.Pan2 = PAN_RIGHT;
			PutValue(FG,TAG(AudioPan1),CurAudioSet.Pan1);
			PutValue(FG, TAG(AudioPan2),CurAudioSet.Pan2);
		}
		else if( HAS_LEFT(AudioOn) || IS_LEFT(AudioOn) )
		{
			CurAudioSet.Mode=AMODE_LEFT;
			//CurAudioSet.Pan1 = 0;
			CurAudioSet.Pan1 = GetValue(FG,TAG(AudioPan1));
			//DUMPMSG("WHY IS THIS BEING SET TO 0?");
			//PutValue(FG,TAG(AudioPan1),CurAudioSet.Pan1);
		}
		else if( HAS_RIGHT(AudioOn) || IS_RIGHT(AudioOn) )
		{
			CurAudioSet.Mode=AMODE_RIGHT;
			//CurAudioSet.Pan2 = 0;
			CurAudioSet.Pan2 = GetValue(FG,TAG(AudioPan2));
			//DUMPMSG("WHY IS THIS BEING SET TO 0?");
			//PutValue(FG,TAG(AudioPan2),CurAudioSet.Pan2);
		}
		else if( !IS_ANYAUDIO(AudioOn) )
		{
			CurAudioSet.Mode= AMODE_NOAUDIO;
		}
	}
	else
	{
		strncat(Label,"Kiki's Shower",MAX_PANEL_STR);
		strcpy(CommentBuf,"No Comment At This Time");
	}

	//DUMPHEXIW("Old Balance: ",CurAudioSet.Balance,"\\");
	CurAudioSet.FG = FG;
	CurAudioSet.V1 = vol1;
	CurAudioSet.V2 = vol2;
	PPPP=GetBalance(&CurAudioSet);
	Vol=GetVolume(&CurAudioSet);
	//DUMPHEXIW("New Balance: ",CurAudioSet.Balance,"\\");

//	EasyPanelPL[PLI_TITLE].Label = "";

	pl = &EasyPanelPL[PLI_CROUTON];
	pl->Label = Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX ;		// max string length
	pl->PropStart=0;						// Gets set to non-zero if comment is changed...
//	pl->UserFun=CTRL_Play;
//	pl->UserObj=(APTR)FG;


//	pl = &EasyPanelPL[PLI_USEENV];
//	pl->Param = (LONG *)useenv;


	pl = &EasyPanelPL[PLI_PLAY];
	pl->UserFun=CTRL_Play;
	pl->UserObj=(APTR)FG;
	pl->Flags=PL_PLAY;

	pl = &EasyPanelPL[PLI_LENGTH];
	pl->Param = &t_Out;					// out point
	pl->Param2 = &t_In;					// in point
	pl->G5 = (struct Gadget *)2;		// diff add-on (?????)
//	pl->PropStart = PANEL_LENGTHX<<16;
//	pl->PropStart += 12 + PIN_YOFF;
//	pl->UserObj = (APTR) 1;				// Flag for custom DIFF positioning

	pl = &EasyPanelPL[PLI_LOCKON];
	pl->Param = (LONG *)lockon;
//	pl->Param2 = (LONG *)lock;
//	pl->PropEnd = 1;					// Number of toggles
//	pl->UserFun=CTRL_SetAudio;
//	pl->UserObj=(APTR)&CurAudioSet;

	pl = &EasyPanelPL[PLI_LOCKTIME];
	pl->Param = &locktime;
	pl->PropStart = 0;
	pl->PropEnd = BIG_MAX_DELAY;
	pl->Flags = PL_DEL;

	pl = &EasyPanelPL[PLI_VIDINOUT];
	pl->Param = &t_In;
	pl->Param2 = &t_Out;
	pl->PropStart = smpte;
	pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
	pl->Flags = PL_IN | PL_DUAL | PL_FLYER | PL_CFRAME;

	if(HAS_ANYAUDIO(AudioOn))
	{
		// Indicates to connect to the audio sliders!!!
		pl->Flags |= PL_PHANTOM;
	}

	DUMPUDECL("Initial outpt = ",t_Out,"  ");
	DUMPUDECL("Max = ",pl->PropEnd,"\\");


	if(!HAS_ANYAUDIO(AudioOn))
	{
		type=PAN_EASY;
		EasyPanelPL[PLI_AUDON].Type=PNL_SKIP;		// Don't include audio buttons
//		EasyPanelPL[PLI_USEENV].Type=PNL_SKIP;
		EasyPanelPL[PLI_ENV].Type=PNL_SKIP;

		

//		pl = &ExpertPanelPL[XPLI_CUTCLIP];
///		pl->Flags = PL_AVAIL;
//		pl->Param =(LONG *)GB_PROCESS;
//		pl->Flags = PL_GENBUTT;

//		CopyMem(&EasyPanelPL[PLI_AUDON],&apl,sizeof(struct PanelLine));
//		CopyMem(&ExpertPanelPL[XPLI_PROCCLIP],&EasyPanelPL[PLI_AUDON],sizeof(struct PanelLine));
	}
	else
	{
		pl = &EasyPanelPL[PLI_AUDON];
		pl->Type=PNL_TOGGLE;					// Include audio button
		pl->Param =(LONG *) (IS_ANYAUDIO(AudioOn) ? 1:0);
		pl->Param2 = (LONG *)aud;
		pl->PropEnd = 1;
		pl->UserFun=CTRL_SetAudio;
		pl->UserObj=(APTR)&CurAudioSet;
	}

	pl = &EasyPanelPL[PLI_PROCCLIP];
	pl->Param =(LONG *)GB_PROCESS;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	pl = &EasyPanelPL[PLI_CUTCLIP];
	pl->Param =(LONG *)GB_CUT;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);
	pl = &EasyPanelPL[PLI_TUNE];
	if(!HAS_ANYAUDIO(AudioOn))
		pl->Type = PNL_SKIP;
	else
	{
//		pl->Type = PNL_BUTTON;
		pl->PropStart = 1;						// Want colored hilite
		pl->Param =(LONG *)GB_FINE_TUNE;		// General button code for "fine tune"
		pl->Flags = PL_GENBUTT;
	}

	pl = &EasyPanelPL[PLI_ENV];
	if(!HAS_ANYAUDIO(AudioOn))
		pl->Type = PNL_SKIP;
	else
	{
		pl->PropStart = 1;						// Want colored hilite
		pl->Param =(LONG *)GB_AUDIOENV;		// General button code for "fine tune"
		pl->Flags = PL_GENBUTT;
	}

	//if we are not includeing audio env panels then make button type skip.(4.2)
#ifndef INCAUDENV
	pl->Type=PNL_SKIP;
#endif


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//	ExpertPanelPL[XPLI_TITLE].Label = "";		//Panel title

	pl = &ExpertPanelPL[XPLI_CROUTON];
	pl->Label = Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL); // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX ; // max string length
	pl->PropStart=0;				// Gets set to non-zero if comment is changed...
//	pl->UserFun=CTRL_Play;
//	pl->UserObj=(APTR)FG;

//	pl = &ExpertPanelPL[PLI_USEENV];
//	pl->Param = (LONG *)useenv;

	pl = &ExpertPanelPL[XPLI_PLAY];
	pl->UserFun=CTRL_Play;
	pl->UserObj=(APTR)FG;
	pl->Flags=PL_PLAY;

	pl = &ExpertPanelPL[XPLI_LENGTH];
	pl->Param = &t_Out;
	pl->Param2 = &t_In;
	pl->G5 = (struct Gadget *)2; // diff
//	pl->PropStart = PANEL_LENGTHX<<16;
//	pl->PropStart += 12 + PIN_YOFF;
//	pl->UserObj = (APTR)1; // Flag for custom DIFF positioning

	pl = &ExpertPanelPL[XPLI_LOCKON];
	pl->Param = (LONG *)lockon;
//	pl->Param2 = (LONG *)lock;
//	pl->PropEnd = 1;					// Number of toggles
//	pl->UserFun=CTRL_SetAudio;
//	pl->UserObj=(APTR)&CurAudioSet;

	pl = &ExpertPanelPL[XPLI_LOCKTIME];
	pl->Param = &locktime;
	pl->PropStart = 0;
	pl->PropEnd = BIG_MAX_DELAY;
	pl->Flags = PL_DEL;

	pl = &ExpertPanelPL[XPLI_VIDINOUT];
	pl->Param = &t_In;
	pl->Param2 = &t_Out;
	pl->PropStart = smpte;
	pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
	pl->Flags = PL_IN | PL_DUAL | PL_FLYER | PL_CFRAME;
	pl->NumParts=0;

	if(!HAS_ANYAUDIO(AudioOn))
	{
		ExpertPanelPL[XPLI_AUDIODIVIDE].Type = 0;
	}
	else
	{
		pl = &ExpertPanelPL[XPLI_AUDINOUT];
		pl->Param = &A_In;
		pl->Param2 = &A_Out;
		pl->PropStart = smpte;
		pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
		pl->Flags = PL_AUDIO | PL_IN | PL_CFRAME | PL_DUAL | PL_FLYER;
//		pl->UserFun=CTRL_DumpPLine;
		pl->Partners=&(ExpertPanelPL[XPLI_VIDINOUT]);			// Relate video sliders to us

		pl = &ExpertPanelPL[XPLI_AUDLEN];
		pl->Param = &A_Out;
		pl->Param2 = &A_In;
		pl->G5 = (struct Gadget *)2; // diff

		pl = &ExpertPanelPL[XPLI_VIDINOUT];
		pl->NumParts=1;				// Connect audio slider to video slider
		Relate = PR_MIRROR;
		pl->Relation=&Relate;
		pl->Partners=&(ExpertPanelPL[XPLI_AUDINOUT]);

		pl = &ExpertPanelPL[XPLI_VOLUME];
		pl->Param = &CurAudioSet.Volume;
//		pl->Param2 = (LONG *)&(ExpertPanelPL[XPLI_BALANCE]); // Balance PL
		pl->PropStart = 0;
		pl->PropEnd = 100;
		pl->Flags =  PL_AUD1|PL_AUD2;
		pl->UserFun=CTRL_SetVolume;
		pl->UserObj=(APTR)&CurAudioSet;

		pl = &ExpertPanelPL[XPLI_BALANCE];
//		pl->Param = &CurAudioSet.Volume; // Overall volume control for "Balance"
		pl->Param2 = (LONG *)pan;
//		pl->PropStart = CurAudioSet.Balance;
		BBBB=CurAudioSet.Balance;
		pl->Param = &BBBB;
		pl->UserFun= CTRL_SetBalance;
		pl->UserObj=(APTR)&CurAudioSet;

		pl = &ExpertPanelPL[XPLI_FADEIN];
		pl->Param = &AudFadeIn;
		pl->PropStart = 0;
		pl->PropEnd = MAX_AUD_FADE;
		pl->Flags = PL_AUD1;  // means Attack on EZLen types

		pl = &ExpertPanelPL[XPLI_AUTOIN];
		pl->Param = (LONG *)autoin;

		pl = &ExpertPanelPL[XPLI_FADEOUT];
		pl->Param = &AudFadeOut;
		pl->PropStart = 0;
		pl->PropEnd = MAX_AUD_FADE;
		pl->Flags = PL_AUD2;  // means Decay on EZLen types

		pl = &ExpertPanelPL[XPLI_AUTOOUT];
		pl->Param = (LONG *)autoout;

		pl = &ExpertPanelPL[XPLI_AUDCHANS];
		pl->Param = (LONG *)Channels;
		pl->PropStart = CurAudioSet.Mode;
		pl->PropEnd = 4;
		pl->UserFun=CTRL_SetPan;
		pl->UserObj=(APTR)&CurAudioSet;
	}
//	ExpertPanelPL[XPLI_PROCCLIP].Flags =  PL_AVAIL;
	pl = &ExpertPanelPL[XPLI_PROCCLIP];
	pl->Param =(LONG *)GB_PROCESS;
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

//	ExpertPanelPL[XPLI_CUTCLIP].Flags =  PL_AVAIL;
	pl = &ExpertPanelPL[XPLI_CUTCLIP];
	pl->Param =(LONG *)GB_CUT;				// Cut
	pl->Flags = PL_GENBUTT;
	pl->PropStart = 1;						// Want colored hilite

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);
	pl = &ExpertPanelPL[XPLI_TUNE];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_QUICK_TUNE;	// General button code for "quick tune"
	pl->Flags = PL_GENBUTT;
	
	pl = &ExpertPanelPL[XPLI_ENV];
	pl->PropStart = 1;						// Want colored hilite
	pl->Param =(LONG *)GB_AUDIOENV;	// General button code for "quick tune"
	pl->Flags = PL_GENBUTT;

	//if we are not includeing audio env panels then make button type skip.(4.2)
#ifndef INCAUDENV
	pl->Type=PNL_SKIP;
#endif

	// Put up last frame of previous crouton on preview (if a Flyer clip/still)
	PutUpPrevLastFrame(FG);

	while(type > PAN_CONTINUE)
	{
		switch(type)
		{
			case PAN_EASY:
				if(!HAS_ANYAUDIO(AudioOn))
				{
					type = FlyPanel(Edit,EasyPanelPL,TUNE_NONE);
//					CopyMem(&apl,&EasyPanelPL[PLI_AUDON],sizeof(struct PanelLine));
				}
				else {
					EasyPanelPL[PLI_AUDON].Param =(LONG *) (IS_ANYAUDIO(CurAudioSet.AudioOn) ? 1:0);
					type = FlyPanel(Edit,EasyPanelPL,TUNE_FINE);
					pmode=0;
				}

				if(t_In != SP.VidIn)  // Audio should match Video on easy panel
				{
					A_In = t_In;
					SetAudioInPoint(FG,Frms2Flds(A_In-smpte),Frms2Flds(A_Out-smpte));
				}
				if(t_Out != SP.VidOut)
				{
					A_Out = t_Out;
					SetAudioOutPoint(FG,Frms2Flds(A_In-smpte),Frms2Flds(A_Out-smpte));
				}
				break;
			case PAN_EXPERT:
				pmode=1;
				ExpertPanelPL[XPLI_AUDCHANS].PropStart = ( IS_ANYAUDIO(CurAudioSet.AudioOn) ? CurAudioSet.Mode:AMODE_NOAUDIO );
				type = FlyPanel(Edit,ExpertPanelPL,TUNE_QUICK);
				break;
			case PAN_PROCESS:
				DoProcClipPanel(Edit,FG);
				type=PAN_CANCEL;
				break;
			case PAN_CUTUP:
				DoCuttingPanel(Edit,FG,FALSE,NULL);		// (Lookup FG name)
				type=PAN_CANCEL;
				break;
#ifdef INCAUDENV
			case PAN_ENVL:
				ValidEnvTag(&AudioEnvelope,A_In,A_Out,0);	
				DoEnvPanel(Edit,FG,A_In,A_Out,AudFadeIn,AudFadeOut,&AudioEnvelope);
				if (pmode==1)
					type=PAN_EXPERT;
				else
					type=PAN_EASY;
				break;
#endif 
		}
	}

	if(!(AudioOn&AUD_EXISTS))
		ExpertPanelPL[XPLI_AUDIODIVIDE].Type = PNL_DIVIDE;


	if(type==PAN_CONTINUE)
	{
		if(AudFadeIn != Flds2Frms(SP.Attack))
			PutValue(FG,TAG(AudioAttack),	Frms2Flds(AudFadeIn));
		if(AudFadeOut!= Flds2Frms(SP.Decay))
			PutValue(FG,TAG(AudioDecay), Frms2Flds(AudFadeOut));

		autoin = (LONG)ExpertPanelPL[XPLI_AUTOIN].Param;
		autoout = (LONG)ExpertPanelPL[XPLI_AUTOOUT].Param;
		if ((autoin != SP.AutoIn) || (autoout != SP.AutoOut))
			PutValue(FG,TAG(AudioFadeFlags),	(autoin?AUDFADEF_AutoIn:0) | (autoout?AUDFADEF_AutoOut:0));

		pl = &EasyPanelPL[PLI_LOCKON];
		if ((LONG)pl->Param == SP.LockOn)
			pl = &ExpertPanelPL[XPLI_LOCKON];

		lockon = (LONG)pl->Param;
		if (lockon != SP.LockOn)
		{
			DUMPUDECL("Lock flag: ",lockon,"\\");
			if (lockon)
			{
				PutValue(FG,TAG(TimeMode), TIMEMODE_ABSTIME);
				((struct ExtFastGadget *)FG)->SymbolFlags |= SYMF_LOCKED;
			}
			else
			{
				PutValue(FG,TAG(TimeMode), TIMEMODE_RELCLIP);
				((struct ExtFastGadget *)FG)->SymbolFlags &= ~SYMF_LOCKED;
			}
			ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)FG));
		}
		if(locktime != SP.LockTime)
		{
			DUMPUDECL("Time: ",Frms2Flds(locktime)," fields\\");
			PutValue(FG,TAG(Delay), Frms2Flds(locktime));		// Convert back to fields
		}

		// Comment changed?
		if( (ExpertPanelPL[XPLI_CROUTON].PropStart) || (EasyPanelPL[PLI_CROUTON].PropStart) )
			PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
		PutValue(FG,TAG(PanelMode),pmode);  // ...just following orders
		
#ifdef INCAUDENV
		ValidEnvTag(&AudioEnvelope,A_In,A_Out,0);	
		PutTable(FG,TAG_AudEnv16,&AudioEnvelope,sizeof(AudioEnvelope));
#endif

		//PutValue(FG,TAG(AudioOn),AudioOn);

		AudioOn = GetValue(FG,TAG(AudioOn));
		if (
			((AudioOn&AUDF_Channel1Recorded)&&(AudioOn&AUDF_Channel1Enabled))
		|| ((AudioOn&AUDF_Channel2Recorded)&&(AudioOn&AUDF_Channel2Enabled))
		)
			((struct ExtFastGadget *)FG)->SymbolFlags |= SYMF_AUDIO;		// Audio is on
		else
			((struct ExtFastGadget *)FG)->SymbolFlags &= ~SYMF_AUDIO;	// Audio is off
		ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)FG));


#ifdef INCAUDENV
		if(AudioEnvelope.Flags)
		{	
			AudioOn |= AUDF_AudEnvEnabled;
		}
		else
		{
			AudioOn &= ~AUDF_AudEnvEnabled;
		}
#endif	

		PutValue(FG,TAG(AudioOn),AudioOn);
	}
	else  // The Jog/Shuttle may have affected these values, so we restore them!!
	{
		PutValue(FG,TAG(FadeInVideo),		SP.VidFadeTime^1);
		PutValue(FG,TAG(ClipStartField),	SP.VidStartField);
		PutValue(FG,TAG(Duration),			SP.VidDuration);
		PutValue(FG,TAG(AudioAttack),		SP.Attack);
		PutValue(FG,TAG(AudioDecay),		SP.Decay);
		PutValue(FG,TAG(AudioStart),		SP.AudStartField);
		PutValue(FG,TAG(AudioDuration),	SP.AudDuration);
		PutValue(FG,TAG(AudioVolume1),	SP.Volume1);
		PutValue(FG,TAG(AudioVolume2),	SP.Volume2);
		PutValue(FG,TAG(AudioOn),			AudioOn);
		Jam_On=FALSE;											// Do not continue with other croutons
		ESparams1.Data1 =(LONG) FG;
		SendSwitcherReply(ES_ChangeAudio,&ESparams1);
	}
	//Main2Blank();
	return(Jam_On);
}


BOOL QuickVIDEOPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
enum {
	PLI_VIDIN,
	PLI_VIDOUT,
	PLI_AUDIN,
	PLI_AUDOUT
};

	struct SaveParams {			// Save parameters here during panel
		LONG	VidStartField;
		LONG	VidDuration;
		LONG	AudStartField;
		LONG	AudDuration;
	} SP;

	LONG	clipfrms=4,audon=0;
	struct SMPTEinfo si;
	struct PanelLine *pl;
	LONG Vin,Vout,Ain,Aout;
	LONG smpte=0,type;
	BOOL Jam_On=TRUE;
	BOOL vidclip;

//	if (FG==NULL)
//	{
		FG = (struct FastGadget *)FindFirstHilited(EditTop);		// If none, pick first hilited
		DUMPHEXIL("FirstHilite=",(LONG)FG,"\\");
//	}

	if (FG==NULL)			// Must operate on something!
		return(FALSE);

	// Only works on video and audio clips
	if (((struct ExtFastGadget *)FG)->ObjectType == CT_VIDEO)
		vidclip = TRUE;
	else if (((struct ExtFastGadget *)FG)->ObjectType == CT_AUDIO)
		vidclip = FALSE;
	else
		return(FALSE);

	CurFG=FG;
	ESparams1.Data1=(LONG)FG;
	SendSwitcherReply(ES_PanelOpen,&ESparams1);		// Opening panel, prepare to jog

	if (vidclip)
		PutUpPrevLastFrame(FG);		// Put up last frame of prev source on preview

	clipfrms = Flds2Frms(GetValue(FG,TAG(RecFields)));  // Clip Frame Length (in frames)
	if (clipfrms<2)
		clipfrms=4;

	// Stash original values
	SP.VidStartField = GetValue(FG,TAG(ClipStartField));
	if( !(SP.VidDuration = GetValue(FG,TAG(Duration))) )
		SP.VidDuration = clipfrms - SP.VidStartField;
	SP.AudStartField= GetValue(FG,TAG(AudioStart));
	if( !(SP.AudDuration= GetValue(FG,TAG(AudioDuration))) )
		SP.AudDuration = clipfrms - SP.AudStartField;

	audon = GetValue(FG,TAG(AudioOn));

	if(GetTable(FG,TAG_SMPTEtime,(UBYTE *)&si,sizeof(struct SMPTEinfo)))
	{
		smpte = EVEN(SMPTEToLong(&si));
		DUMPUDECB("SMPTE Start: ",si.SMPTEhours,":");
		DUMPUDECB("",si.SMPTEminutes,":");
		DUMPUDECB("",si.SMPTEseconds,":");
		DUMPUDECB("",si.SMPTEframes,"  = ");
		DUMPUDECL(" ",smpte," frames \\");
	}

	// These are values that are modified by the panel
	Vin  = Fly4Flds2Frms(SP.VidStartField) + smpte;			 // In Frame
	Vout = Fly4Flds2Frms(SP.VidStartField+SP.VidDuration-4) + smpte;  // Out Frame
	if(Vin > Vout)
		Vout = Vin+2;
	Ain  = Fly4Flds2Frms(SP.AudStartField)  + smpte;
	Aout = Fly4Flds2Frms(SP.AudStartField+SP.AudDuration-4) + smpte;

	InitPanelLines(EasyPanelPL,Quick_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_VIDIN];
	if (!vidclip)
		pl->Type = PNL_SKIP;
	else
	{
		pl->Param = &Vin;
		pl->PropStart = smpte;
		pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
		pl->Flags = PL_IN | PL_FLYER | PL_CFRAME;
		pl->G2 = 0;
		pl->Param2 = (LONG *)&EasyPanelPL[PLI_VIDOUT];	// Can shadow this value
		pl->Partners = &EasyPanelPL[PLI_AUDIN];		// Can attach to this value
	}

	pl = &EasyPanelPL[PLI_VIDOUT];
	if (!vidclip)
		pl->Type = PNL_SKIP;
	else
	{
		pl->Param = &Vout;
		pl->PropStart = smpte;
		pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
		pl->Flags = PL_OUT | PL_FLYER | PL_CFRAME;
		pl->G2 = 0;
		pl->Param2 = (LONG *)&EasyPanelPL[PLI_VIDIN];	// Can shadow this value
		pl->Partners = &EasyPanelPL[PLI_AUDOUT];		// Can attach to this value
	}

	pl = &EasyPanelPL[PLI_AUDIN];
	if(vidclip && (!IS_ANYAUDIO(audon)))
		pl->Type = PNL_SKIP;
	else
	{
		pl->Param = &Ain;
		pl->PropStart = smpte;
		pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
		pl->Flags = PL_IN | PL_AUDIO | PL_FLYER | PL_CFRAME;
		pl->G2 = 0;
		pl->Param2 = (LONG *)&EasyPanelPL[PLI_AUDOUT];	// Can shadow this value
		pl->Partners = &EasyPanelPL[PLI_VIDIN];		// Can attach to this value
	}

	pl = &EasyPanelPL[PLI_AUDOUT];
	if(vidclip && (!IS_ANYAUDIO(audon)))
		pl->Type = PNL_SKIP;
	else
	{
		pl->Param = &Aout;
		pl->PropStart = smpte;
		pl->PropEnd = smpte + clipfrms - LENGTH_ADJUST;
		pl->Flags = PL_OUT | PL_AUDIO | PL_FLYER | PL_CFRAME;
		pl->G2 = 0;
		pl->Param2 = (LONG *)&EasyPanelPL[PLI_AUDIN];	// Can shadow this value
		pl->Partners = &EasyPanelPL[PLI_VIDOUT];		// Can attach to this value
	}

//	DisplayMessage(NULL);					// Remove any message still up

	type = QuickPanel(Edit,EasyPanelPL,FG,smpte);
	if(type==PAN_CONTINUE)
	{
		// Do anything special if kept???
	}
	else  // The Jog/Shuttle may have affected these values, so we restore them!!
	{
		PutValue(FG,TAG(ClipStartField),	SP.VidStartField);
		PutValue(FG,TAG(Duration),			SP.VidDuration);
		PutValue(FG,TAG(AudioStart),		SP.AudStartField);
		PutValue(FG,TAG(AudioDuration),	SP.AudDuration);
	}

	ESparams1.Data1=(LONG)FG;
	SendSwitcherReply(ES_PanelClose,&ESparams1);

	CalcRunningTime();		// Re-calculate sequence total time

	DisplayMessage(NULL);	// Redraw all "normal" accesswindow items

	return(Jam_On);
}


// CT_CONTROL
static BOOL DoCONTROLPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for CtrlPL[]
		PLI_TITLE,
		PLI_NAME,
		PLI_DIVIDE1,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG type=PAN_EASY;
	char Label[MAX_PANEL_STR]="";
//	struct PanelLine	*pl;

	InitPanelLines(EasyPanelPL,Ctrl_IPL);		// Copy basic init data into panel

	if(FG)
	{
		strncpy(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
	}
	EasyPanelPL[PLI_NAME].Label = Label;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	type = MiniPanel(Edit,EasyPanelPL,TUNE_NONE);

	if(type==PAN_CONTINUE)
		return(TRUE);

	return(FALSE);
}


// CT_MAIN
static BOOL DoMainPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for MainPL[]
		PLI_TITLE,
		PLI_NAME,
		PLI_DIVIDE1,
		PLI_LENGTH,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

#if 0
	enum {				// PL indices for XPMainPL[]
		XPLI_TITLE,
		XPLI_NAME,
		XPLI_DIVIDE1,
		XPLI_LENGTH,
		XPLI_DIVIDE2,
		XPLI_CONTINUE,
		XPLI_CANCEL,
	};
#endif

	LONG A=0,B=1,t_In=1800,t_Out=1,type=PAN_EASY,Time=84;
	char Label[MAX_PANEL_STR]="";
	struct PanelLine	*pl;

	if(FG)
	{
		strncpy(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		Time = Flds2Frms(GetValue(FG,TAG(Duration)));		// Fields-->Frames
		t_In = Flds2Frms(GetValue(FG,TAG(MaxDuration)));
		A=Time;
		B=GetValue(FG,TAG(FadeInVideo));
		B=((B!=0) ? 0:1);
		t_Out=B;
	}

	InitPanelLines(EasyPanelPL,Main_IPL);		// Copy basic init data into panel

	EasyPanelPL[PLI_NAME].Label =Label;

	pl = &EasyPanelPL[PLI_LENGTH];
	pl->Param = &Time;	// Time slider
	pl->PropStart = 1;
	pl->PropEnd = (t_In>=900 ? t_In:1800);
	pl->Flags = PL_LEN;

	EasyPanelPL[PLI_DIVIDE2].Param = &B;		//???

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

#if 0
	InitPanelLines(ExpertPanelPL,XPMain_IPL);		// Copy basic init data into panel

	ExpertPanelPL[XPLI_NAME].Label =Label;

	pl = &ExpertPanelPL[XPLI_LENGTH];
	pl->Param = &Time;	// Time slider
	pl->PropStart = 1;
	pl->PropEnd = (t_In>=900 ? t_In:1800);
	pl->Flags = PL_LEN;

	ExpertPanelPL[XPLI_DIVIDE2].Param = &B;	//???

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);
#endif

	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		type = MiniPanel(Edit,EasyPanelPL,TUNE_NONE);
	}

	if(type==PAN_CONTINUE)
	{
		if(A!=Time)
			PutValue(FG,TAG(Duration),Frms2Flds(Time));    // Frames -> Fields
		if(B!=t_Out) PutValue(FG,TAG(FadeInVideo),B^1);
		return(TRUE);
	}
	return(FALSE);
}


// CT_FRAMESTORE
static BOOL DoFRAMESTOREPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for FramePL[]
		PLI_CROUTON,
		PLI_LOCKON,
		PLI_LOCKTIME,
		PLI_DIVIDE1,
		PLI_LENGTH,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG A=69,t_In=100,type=PanType,Time=80;
	LONG lockon,lockonwas,locktime,locktimewas;
	char Label[MAX_PANEL_STR];
	struct PanelLine	*pl;

	InitPanelLines(EasyPanelPL,Frame_IPL);		// Copy basic init data into panel

//	char *lock[]={"Lock "};

	CommentBuf[0]=0;

	if(FG)
	{
		if (((struct ExtFastGadget *)FG)->ObjectType == CT_STILL)
			strcpy(Label,"Still: ");
		else
			strcpy(Label,"Framestore: ");
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		Time = Flds2Frms(GetValue(FG,TAG(Duration)));	// Fields-->Frames
		if(Time==0)
		{
			Time=600;
			PutValue(FG,TAG(Duration),Frms2Flds(Time));
		}
		t_In = Flds2Frms(GetValue(FG,TAG(MaxDuration)));
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		lockonwas = lockon = (GetValue(FG,TAG(TimeMode))==TIMEMODE_ABSTIME)?1:0;
		locktimewas = Flds2Frms(GetValue(FG,TAG(Delay)));
		if (lockon)
			locktime = locktimewas;
		else
			locktime = Flds2Frms(GetStartTimeInSequence(FG));	// Find time in current sequence

		A=Time;
	}
	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		pl = &EasyPanelPL[PLI_CROUTON];
		pl->Label =Label;
		pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
		pl->Param = (long *)CommentBuf;
		pl->PropEnd = COMMENT_MAX;

		pl = &EasyPanelPL[PLI_LOCKON];
		pl->Param = (LONG *)lockon;
//		pl->Param2 = (LONG *)lock;

		pl = &EasyPanelPL[PLI_LOCKTIME];
		pl->Param = &locktime;
		pl->PropStart = 0;
		pl->PropEnd = BIG_MAX_DELAY;
		pl->Flags = PL_DEL;

		pl = &EasyPanelPL[PLI_LENGTH];
		pl->Param = &Time;	// Time slider
		pl->PropStart = 1;
		pl->PropEnd = (t_In>=1800 ? t_In:60000);
		pl->Flags = PL_LEN ; // | PL_CFRAME;

		MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
		MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

		type = MiniPanel(Edit, EasyPanelPL,TUNE_NONE);
	}
	if(type==PAN_CONTINUE)
	{
		if(A!=Time)
			PutValue(FG,TAG(Duration),Frms2Flds(Time));    // Frames -> Fields
		if(EasyPanelPL[PLI_CROUTON].PropStart)
			PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
		lockon = (LONG)EasyPanelPL[PLI_LOCKON].Param;
		if (lockon != lockonwas)
		{
			if (lockon)
			{
				PutValue(FG,TAG(TimeMode), TIMEMODE_ABSTIME);
				((struct ExtFastGadget *)FG)->SymbolFlags |= SYMF_LOCKED;
			}
			else
			{
				PutValue(FG,TAG(TimeMode), TIMEMODE_RELCLIP);
				((struct ExtFastGadget *)FG)->SymbolFlags &= ~SYMF_LOCKED;
			}
			ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)FG));
		}
		if (locktime != locktimewas)
			PutValue(FG,TAG(Delay), Frms2Flds(locktime));		// Convert back to fields

		return(TRUE);
	}
	return(FALSE);
}


// CT_KEY
static BOOL DoKEYPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for KeyPL[]
		PLI_CROUTON,
		PLI_DIVIDE1,
		PLI_LENGTH,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_DIVIDE2,
		PLI_FADES,
		PLI_PAD,
		PLI_FADESPEED,
		PLI_FADELENGTH,
		PLI_DIVIDE3,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

#if 0
	enum {				// PL indices for XPKeyPL[]
		XPLI_CROUTON,
		XPLI_DIVIDE1,
		XPLI_LENGTH,
		XPLI_LOCKTO,
		XPLI_TIME,
		XPLI_DIVIDE2,
		XPLI_FADEIN,
		XPLI_FADEOUT,
		XPLI_DIVIDE3,
		XPLI_CONTINUE,
		XPLI_CANCEL,
	};
#endif

	static char *FadeMsgs[] = {"In  ","Out  ",""};

	LONG was_Time=0,was_DLay=2,was_In,was_Out,type=PanType,Time=69,DLay=12,pmode=0,TM,TMb,fades,fadeswas;
	LONG FadeIn=1,FadeOut=1,zero=0,fcount;		// Medium fade
	char Label[MAX_PANEL_STR]="Key Page: ";
	struct PanelLine	*pl;
	LONG smfv=0,fcnts[4] = {45,30,15,0};		// Preset fade speeds


	CommentBuf[0]=0;
	if(FG)
	{
		DUMPHEXIL("FG TagList ",(((struct ExtFastGadget *)FG)->TagLists),"\\");
		DUMPHEXIL("FG type    ",((struct ExtFastGadget *)FG)->ObjectType,"\\");
		
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		Time = was_Time = Flds2Frms(GetValue(FG,TAG(Duration)));
		DLay = was_DLay = Flds2Frms(GetValue(FG,TAG(Delay)));
		TM = TMb = GetValue(FG,TAG(TimeMode));
		fadeswas = fades = GetValue(FG,TAG(Speed)); // bit0 =fade in, bit1=fade out
		FadeIn = Flds2Frms(GetValue(FG,TAG(FadeInDuration)));
//		FadeOut= Flds2Frms(GetValue(FG,TAG(FadeOutDuration)));
		FadeOut= FadeIn;

		for (smfv=0; smfv<3; smfv++)			// Get SMF index back from duration
		{
			if (fcnts[smfv] <= FadeIn)
				break;
		}
		if (smfv > 2)		// If shorter than Fast, must use Fast
			smfv = 2;

//		if(!(fades&1)) FadeIn=0;
//		if(!(fades&2)) FadeOut=0;
//		FadeIn = FadeOut = GetValue(FG,TAG(FCountMode));		//0,1,2
		was_In = FadeIn;
		was_Out = FadeOut;
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
		pmode = GetValue(FG,TAG(PanelMode));
		if (pmode==1)	type = PAN_EXPERT;
	}

	fcount = fcnts[smfv];							// Current fade duration

	InitPanelLines(EasyPanelPL,Key_IPL);		// Copy basic init data into panel

	pl = &EasyPanelPL[PLI_CROUTON];
	pl->Label =Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX;

	pl = &EasyPanelPL[PLI_LENGTH];
	pl->Param = &Time;
	pl->PropStart = 1;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_LEN;

	pl = &EasyPanelPL[PLI_LOCKTO];
	pl->Param = (LONG *)TimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 2;

	pl = &EasyPanelPL[PLI_TIME];
	pl->Param = &DLay;
	pl->PropStart = 1;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_DEL;

	pl = &EasyPanelPL[PLI_FADES];
	pl->Param = (long *)fades;
	pl->PropEnd = 2;
	pl->Param2 =(long *)FadeMsgs;

//---
	pl = &EasyPanelPL[PLI_FADESPEED];
	pl->Param  = &smfv;					// SMF(V) choice
	pl->Param2 = fcnts;					// Array of field counts
	pl->PropStart =0;						// PLine (time) to update, 0 for FXTIME

	pl = &EasyPanelPL[PLI_FADELENGTH];
	pl->Param = &fcount;	// Time slider
	pl->Param2 = &zero;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#if 0
	InitPanelLines(ExpertPanelPL,XPKey_IPL);		// Copy basic init data into panel

	pl = &ExpertPanelPL[XPLI_CROUTON];
	pl->Label =Label;
	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
	pl->Param = (long *)CommentBuf;
	pl->PropEnd = COMMENT_MAX;

	pl = &ExpertPanelPL[XPLI_LENGTH];
	pl->Param = &Time;
	pl->PropStart = 1;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_LEN;

	pl = &ExpertPanelPL[XPLI_LOCKTO];
	pl->Param = (LONG *)TimeModes;
	pl->PropStart = TM;
	pl->PropEnd = 2;

	pl = &ExpertPanelPL[XPLI_TIME];
	pl->Param = &DLay;
	pl->PropStart = 1;
	pl->PropEnd = BIG_MAX;
	pl->Flags = PL_DEL;

	pl = &ExpertPanelPL[XPLI_FADEIN];
	pl->Param = &smfv;
	pl->PropStart = 1;
//	pl->PropEnd = A;
	pl->Flags = PL_IN;

	pl = &ExpertPanelPL[XPLI_FADEOUT];
	pl->Param = &FadeOut;
	pl->PropStart = 1;
//	pl->PropEnd = A;
	pl->Flags = PL_OUT;

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);
#endif

	while(type > PAN_CONTINUE)
	{
		switch(type)
		{
			case PAN_EXPERT:
#if 0
				pmode=1;
				pl = &ExpertPanelPL[XPLI_LOCKTO];
				pl->PropStart = TM;
				type = MiniPanel(Edit, ExpertPanelPL,TUNE_QUICK);
				TM = pl->PropStart;
				break;
#endif
			case PAN_EASY:
				pmode=0;
				pl = &EasyPanelPL[PLI_LOCKTO];
				pl->PropStart = TM;
//				type = MiniPanel(Edit, EasyPanelPL,TUNE_FINE);
				type = MiniPanel(Edit, EasyPanelPL,TUNE_NONE);
				TM = pl->PropStart;
				break;
		}
	}


	if(type==PAN_CONTINUE)
	{
		fades = (LONG)EasyPanelPL[PLI_FADES].Param;

		if(Time != was_Time)
		{
			PutValue(FG,TAG(Duration),Frms2Flds(Time));
			ESparams2.Data1=(LONG)FG;
			ESparams2.Data2=FGC_FCOUNT;
			SendSwitcherReply(ES_FGcommand,&ESparams2);
		}

		if(DLay != was_DLay)
			PutValue(FG,TAG(Delay),Frms2Flds(DLay));

		FadeIn = FadeOut = fcnts[smfv];				// Final fade duration

		if(FadeIn != was_In)
		{
//			fades|=1;
			PutValue(FG,TAG(FadeInDuration),Frms2Flds(FadeIn));
//			PutValue(FG,TAG(FCountMode),FadeIn);
		}

//		if(FadeOut != was_Out)
//		{
//			fades|=2;
//			PutValue(FG,TAG(FadeOutDuration),Frms2Flds(FadeOut));
//		}

		if(fades != fadeswas)
			PutValue(FG,TAG(Speed),fades);
		if ((EasyPanelPL[PLI_CROUTON].PropStart)
/*		|| (ExpertPanelPL[XPLI_CROUTON].PropStart) */
		)
			PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
		PutValue(FG,TAG(PanelMode),pmode);  // ...just following orders
		if(TMb != TM)
			PutValue(FG,TAG(TimeMode),TM);

		return(TRUE);
	}
	return(FALSE);
}


int ScrollSpeed2Index[]={0,0,1,0,2,0,3,0,4};	// Converts speed to index (0-4)
int ScrollIndex2Speed[]={0,2,4,6,8};			// Converts index (0-4) to speed

//int SCSpeed[]={1,2,4,6,8}; //  lines/field (WRONG!)
int CRSpeed[]={2,4,8,16};  //  pixs/field
#define PAGE_SCROLL		0
#define PAGE_CRAWL		1
// Fix field count for page based on new speed
static int NewDuration(int Dur, int OldSpeed, int NewSpeed, UBYTE PType)
{
	int n=0,dist;

	if(OldSpeed==NewSpeed) return(Dur);
	if(PType==PAGE_SCROLL)
	{
		if(OldSpeed)
			dist= Dur*ScrollIndex2Speed[OldSpeed];
		else
			dist = Dur/2;

		if(NewSpeed)
			n=dist/ScrollIndex2Speed[NewSpeed];
		else
			n=dist*2; // Slowest = 1/2 line/field
	}
	else if(PType==PAGE_CRAWL)
	{
		dist=CRSpeed[OldSpeed]*Dur;
		n=dist/CRSpeed[NewSpeed];
	}
//	DUMPSDECL("Duration: Old ",Dur,"   ");
//	DUMPSDECL("          New ",n,"\\");
//	DUMPSDECL("Speed:    Old ",OldSpeed,"   ");
//	DUMPSDECL("          New ",NewSpeed,"\\");
	return(n);
}


// CT_CRAWL
static BOOL DoCRAWLPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for CrawlPL[]
		PLI_CROUTON,
		PLI_DIVIDE1,
//		PLI_PAD1,
//		PLI_PAD2,
		PLI_SPEED,
		PLI_LENGTH,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG dummy,durwas=0;
	LONG type=PanType,spd=1,SpeedWas=spd,DLay=84,DLayWas=DLay,TMwas=0,TM=0;
	LONG SPdur[5]={120,90,60,30,0};
	int	i;
	char Label[MAX_PANEL_STR]="CG Crawl: ";
	struct PanelLine	*pl;

	CommentBuf[0]=0;
	if(FG)
	{
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		SpeedWas = spd = GetValue(FG,TAG(Speed));
		SPdur[spd] = durwas = Flds2Frms(GetValue(FG,TAG(Duration)));	// Convert to frames
		DLayWas = DLay = Flds2Frms(GetValue(FG,TAG(Delay)));
		TMwas = TM = GetValue(FG,TAG(TimeMode));
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
	}

// Extrapolate durations for other speeds
	for (i=0;i<4;i++) {
		SPdur[i] = NewDuration(durwas,spd,i,PAGE_CRAWL);
		DUMPHEXIL("SPdur=",(LONG)SPdur[i],"\\");
	}

	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		InitPanelLines(EasyPanelPL,Crawl_IPL);		// Copy basic init data into panel

		pl = &EasyPanelPL[PLI_CROUTON];
		pl->Label =Label;
		pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
		pl->Param = (long *)CommentBuf;
		pl->PropEnd = COMMENT_MAX;

		pl = &EasyPanelPL[PLI_SPEED];
		pl->Param = &spd;
		pl->Param2 = SPdur;
		pl->PropStart = 0;

		dummy = 0;
		pl = &EasyPanelPL[PLI_LENGTH];
		pl->Param = &durwas;
		pl->Param2 = &dummy;
		pl->PropEnd = -1;

		pl = &EasyPanelPL[PLI_LOCKTO];
		pl->Param = (long *)TimeModes;		// POPUP
		pl->PropStart = TM;
		pl->PropEnd = 2;

		pl = &EasyPanelPL[PLI_TIME];
		pl->Param = &DLay;
		pl->PropStart = 1;
		pl->PropEnd = BIG_MAX;
		pl->Flags = PL_DEL;

		MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
		MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

		type = MiniPanel(Edit, EasyPanelPL,TUNE_NONE);
	}
	if( FG && (type==PAN_CONTINUE) )
	{
		if(SpeedWas!=spd)
		{
			PutValue(FG,TAG(Speed),spd);
			PutValue(FG,TAG(Duration),Frms2Flds(SPdur[spd]));		// Convert back to fields
		}
		if(DLayWas!=DLay) PutValue(FG,TAG(Delay),Frms2Flds(DLay));

		TM = EasyPanelPL[PLI_LOCKTO].PropStart;
		if(TM!=TMwas)
			PutValue(FG,TAG(TimeMode),TM);

		if(EasyPanelPL[PLI_CROUTON].PropStart)
			PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		return(TRUE);
	}
	return(FALSE);
}


// CT_SCROLL
static BOOL DoSCROLLPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for ScrollPL[]
		PLI_CROUTON,
		PLI_DIVIDE1,
//		PLI_PAD1,
//		PLI_PAD2,
		PLI_SPEED,
		PLI_LENGTH,
		PLI_LOCKTO,
		PLI_TIME,
		PLI_HOLD,
//		PLI_FADE,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG dummy,durwas;
	LONG type=PanType,spd=1,SpeedWas=spd,DLay=84,DLayWas=DLay,Time=120,TimeWas=120;
//	LONG F=0,Fb=0;
	LONG TM=0,TMwas=0;
	LONG SPdur[5]={120,90,60,30,15};
	int	i;
	char Label[MAX_PANEL_STR]="CG Scroll: ";
	struct PanelLine	*pl;

	CommentBuf[0]=0;

	if(FG)
	{
		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		SpeedWas = spd = ScrollSpeed2Index[GetValue(FG,TAG(Speed))];
		SPdur[spd] = durwas = Flds2Frms(GetValue(FG,TAG(Duration)));	// Convert to frames
		DLayWas = DLay = Flds2Frms(GetValue(FG,TAG(Delay)));
		TimeWas = Time = Flds2Frms(GetValue(FG,TAG(HoldFields)));		// JMF added F2F
//		F = Fb = GetValue(FG,TAG(FadeOutDuration)));
		TMwas = TM = GetValue(FG,TAG(TimeMode));
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
	}

// Extrapolate durations for other speeds
	for (i=0;i<5;i++) {
		SPdur[i] = NewDuration(durwas,spd,i,PAGE_SCROLL);
		DUMPHEXIL("SPdur=",(LONG)SPdur[i],"\\");
	}

	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		InitPanelLines(EasyPanelPL,Scroll_IPL);		// Copy basic init data into panel

		pl = &EasyPanelPL[PLI_CROUTON];
		pl->Label =Label;
		pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
		pl->Param = (long *)CommentBuf;
		pl->PropEnd = COMMENT_MAX;

		pl = &EasyPanelPL[PLI_SPEED];
		pl->Param = &spd;
		pl->Param2 = SPdur;
		pl->PropStart = 0;

		dummy = 0;
		pl = &EasyPanelPL[PLI_LENGTH];
		pl->Param = &durwas;
		pl->Param2 = &dummy;
		pl->PropEnd = -1;

		pl = &EasyPanelPL[PLI_LOCKTO];
//		pl->Param = (long *)ScrollCtrls;		// POPUP
//		pl->PropStart = DEF_SCROLL;
//		pl->PropEnd = SCROLL_NUM;
		pl->Param = (LONG *)TimeModes;
		pl->PropStart = TM;
		pl->PropEnd = 2;

		pl = &EasyPanelPL[PLI_TIME];
		pl->Param = &DLay;
		pl->PropStart = 1;
		pl->PropEnd = BIG_MAX_DELAY;
		pl->Flags = PL_DEL;

		pl = &EasyPanelPL[PLI_HOLD];
		pl->Param = &Time;
		pl->PropStart = 1;
		pl->PropEnd = BIG_MAX_DELAY;
		pl->Flags = PL_LEN;


//		pl = &EasyPanelPL[PLI_FADE];
//		pl->Param = &F;
//		pl->PropStart = 1;
//		pl->PropEnd = BIG_MAX_DELAY;

		MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
		MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

		type = MiniPanel(Edit, EasyPanelPL,TUNE_NONE);
	}
	if( FG && (type==PAN_CONTINUE) )
	{
		if(SpeedWas!=spd)
		{
			PutValue(FG,TAG(Speed),ScrollIndex2Speed[spd]);
			PutValue(FG,TAG(Duration),Frms2Flds(SPdur[spd]));	// Convert back to fields
		}
		if(DLayWas!=DLay) PutValue(FG,TAG(Delay),Frms2Flds(DLay));
		if(TimeWas!=Time) PutValue(FG,TAG(HoldFields),Frms2Flds(Time));	// JMF added F2F
//		if(F!=Fb) PutValue(FG,TAG(FadeOutDuration),Fb);

		TM = EasyPanelPL[PLI_LOCKTO].PropStart;
		if(TM != TMwas)
			PutValue(FG,TAG(TimeMode),TM);

		if(EasyPanelPL[PLI_CROUTON].PropStart)
			PutTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		return(TRUE);
	}
	return(FALSE);
}


static BOOL DoNewClipPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for RawRecPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_PAD1,
		PLI_DRIVE,
		PLI_QUAL,
		PLI_DIVIDE2,
		PLI_AVAILTIME,
		PLI_REORGTIME,
		PLI_REORGBTN,
		PLI_DIVIDE3,
		PLI_DROPPED,
		PLI_LENGTH,
		PLI_SOURCE,
		PLI_LGAIN,
		PLI_RGAIN,
		PLI_PAD2,
		PLI_DIVIDE4,
//		PLI_CONTINUE,
		PLI_MAKECLIPS,
		PLI_CANCEL,
	};

	LONG type,B=6660,C=B<<1,Zero=0,T=0,LG=8,RG=8,NG=8,STOP=0;
	LONG DroppedFlds=0;
//	LONG F=0,Spot=0,smpte=0;
	struct FlyerVolInfo *FVI=NULL;
	char *FlyDrive;
//	struct SMPTEinfo	si;
	struct PanelLine	*pl;
	BOOL	TinyVer=FALSE;

	// Need to know if "StopOnDropFrame" option is on
	if (FlyerBase)
		FlyerOptions(0,0,&FlyerOpts);		// Get Flyer options flags
	else
		FlyerOpts = 0;

	if (SWITCHER_MODE)
		TinyVer = TRUE;

	CommentBuf[0]=0;

	type = PAN_RECORD;

	if(FlyerBase)
	{
		if(FlyerDriveCount==0) BuildFlyerList();
		if(FlyerDriveCount && (FVI=GetFlyerInfo(FlyerDrives[CurFlyDrive])))
		{
			B=BlocksToFrames(FVI->Largest,CurCompMode);
			C=BlocksToFrames(FVI->Optimized,CurCompMode);
			if(B>C) C=B; // Don't let optimized be smaller!!!
		}
	}
	DUMPMSG("Welcome to the New Clip Panel");

	LG=GetRecGain();
	RG=(LG&0x00FF);
	LG=(LG&0xFF00)>>8;

	while(!STOP)
	{
		switch(type)
		{
		case PAN_RECORD:					// Raw record panel
		case PAN_EASY:
			InitPanelLines(EasyPanelPL,RawRec_IPL);		// Copy basic init data into panel

			if (TinyVer)
				EasyPanelPL[PLI_PAD1].Type = PNL_SKIP;		// Omit for short panel

			if(FlyerDriveCount)
			{
				// Setup drives popup
				pl = &EasyPanelPL[PLI_DRIVE];
				pl->Param = (long *)FlyerDrives;
				pl->PropStart = CurFlyDrive;
				pl->PropEnd = FlyerDriveCount;
				pl->UserFun = CTRL_SetDrive;
				pl->G4 = (struct Gadget *)B;
				pl->G5 = (struct Gadget *)C;
				pl->Flags = PL_FLYER|PL_PARTNER;
				pl->Partners = &(EasyPanelPL[PLI_QUAL]); // Mode->Audio Only popup
			}
			else
			{
				// Drives popup if no drives
				pl = &EasyPanelPL[PLI_DRIVE];
				pl->Param = (long *)FlyDrives;
//				FlyDrives[0][0]=AUDIO_BYTE;
				pl->PropStart = 0;
				pl->PropEnd = 1;
				pl->Param2 = NULL;
				pl->G4 = (struct Gadget *)B;
				pl->G5 = (struct Gadget *)C;
				pl->Flags = PL_FLYER;
			}

			if (FlyerBase)
				FlyerOptions(0,0,&FlyerOpts);		// Get Flyer options flags
			else
				FlyerOpts = 0;

			// Setup quality popup
			pl = &EasyPanelPL[PLI_QUAL];
			pl->Param = (long *)Quals;
			pl->PropStart = CurCompMode;
			pl->PropEnd = (FLYOPTF_NOT_HQ5 & FlyerOpts) ? QUAL_NUM_STD : QUAL_NUM_HQ5; 
			//pl->PropEnd = (FLYOPTF_NOT_HQ5 & FlyerOpts) ? QUAL_NUM_STD : QUAL_NUM_HQ6; 
			pl->UserFun = CTRL_SetCompression;
			pl->UserObj = (APTR)&EasyPanelPL[PLI_DRIVE]; // PLine with Max and opt sizes

			if (TinyVer)
				EasyPanelPL[PLI_DIVIDE2].Type = PNL_SKIP;	// Omit for short panel

			pl = &EasyPanelPL[PLI_AVAILTIME];
			pl->Param = (LONG *)&(EasyPanelPL[PLI_DRIVE].G4);  // Diff
			pl->Param2 = &Zero;

			pl = &EasyPanelPL[PLI_REORGTIME];
			if (TinyVer)
				pl->Type = PNL_SKIP;						// Omit on short panel
			else
			{
				pl->Param = (LONG *)&(EasyPanelPL[PLI_DRIVE].G5);  // Diff
				pl->Param2 = &Zero;
				pl->Flags = PL_AVAIL;
			}

			pl = &EasyPanelPL[PLI_REORGBTN];
			if (TinyVer)
				pl->Type = PNL_SKIP;						// Omit reorg button
			else
			{
				pl->Param =(LONG *)GB_REORG;			// General button code for ReOrg
				pl->Flags = PL_SMREF | PL_GENBUTT;	// Need smart refresh for reorg requester
//				global_CurVolumeName = VolName;		// Use this w/ ReOrg button
			}

			if (TinyVer)
				EasyPanelPL[PLI_DIVIDE3].Type = PNL_SKIP;	// Omit for short panel

			pl = &EasyPanelPL[PLI_DROPPED];
//			if (FlyerOpts & FLYOPTF_DropFramDet)
//				pl->Type = PNL_SKIP;			// Will stop on drop, so no
//			else
			{
				pl->Param = &DroppedFlds;     // Diff
				pl->Param2 = &Zero;
				pl->PLID = PLID_DROPIND;
//				pl->Flags = PL_HIDDEN;
			}

			pl = &EasyPanelPL[PLI_LENGTH];
			pl->Param = &T;     // Diff
			pl->Param2 = &Zero;
			pl->Flags = PL_LEN;

			pl = &EasyPanelPL[PLI_SOURCE];
			pl->Param = (long *)Sources;		// POPUP
			pl->UserFun = CTRL_SetSource;
			pl->UserObj = (APTR)&EasyPanelPL[PLI_DRIVE]; // PLine with Max and opt sizes
			pl->PropStart = CurFlySource;
			pl->PropEnd = FLY_SRC_NUM; // 4; //6; (Audio Only moved...)
			pl->Flags = PL_AUDIO;

			pl = &EasyPanelPL[PLI_LGAIN];
			if (TinyVer)
				pl->Type = PNL_SKIP;						// Omit on short panel
			else
			{
				pl->Param = (long *)&LG;
				pl->Param2 = (long *)&NG;
				pl->PropStart = 0;
				pl->PropEnd = 15;
				pl->UserFun = CTRL_SetRecGain;
				pl->UserObj = &AudCtrl;
				pl->Flags = PL_IN; // Flag so CTRL_function can set Left vs Right
			}

			pl = &EasyPanelPL[PLI_RGAIN];
			if (TinyVer)
				pl->Type = PNL_SKIP;						// Omit on short panel
			else
			{
				pl->Param = (long *)&RG;
				pl->Param2 = (long *)&NG;
				pl->PropStart = 0;
				pl->PropEnd = 15;
				pl->UserFun = CTRL_SetRecGain;
				pl->UserObj = &AudCtrl;
			}

//			EasyPanelPL[PLI_PAD2].HeightAdj = 26+8+PNL_DIV;  // Spacer

//			MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
			MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);
			pl = &EasyPanelPL[PLI_MAKECLIPS];
			pl->PropStart = 1;					// Want colored hilite
			pl->Param =(LONG *)GB_CUT;			// General button code for "go to cutting room"
			pl->Flags = PL_GENBUTT;

			type = NewClipPanel(Edit);
			break;
		case PAN_CONTINUE:
			STOP=1;
			break;
		case PAN_CUTUP:

			FlyDrive = FlyerDrives[CurFlyDrive];
			if(*FlyDrive==AUDIO_BYTE)
				FlyDrive+=2; // Skip speaker symbol char and space
			strncpy(Name,FlyDrive,CLIP_PATH_MAX);
			strncat(Name,TEMP_CLIP_NAME,CLIP_PATH_MAX);

			if (Flyer_ClipInfo(Name) == NULL)
			{
				ContinueRequest(Edit->Window,"No raw clip recorded yet");
				type = PAN_RECORD;		// Return to record panel
				break;
			}

			if(FlyerBase)
			{
				ESparams2.Data1=(LONG)Name;
				ESparams2.Data2=(LONG)1;

				if( !(FG=(struct FastGadget *)SendSwitcherReply(ES_LoadCrouton,&ESparams2)) )
				{
					DUMPSTR("Load Failed On ");
					DUMPMSG(Name);
					STOP=TRUE;
					break;
				}
				else
				{
					CurFG = FG;
				}
			}

// The NewClip panel never gets a Panel Open, so don't do this!!!!
//			SendSwitcherReply(ES_PanelClose,&ESparams1);


			ESparams1.Data1=(LONG)FG;
			DUMPHEXIL("PanelOpen: FG = ",(LONG)FG,"\\");
			SendSwitcherReply(ES_PanelOpen,&ESparams1);

			type = DoCuttingPanel(Edit,FG,TRUE,Name);		// Use "LastClipMade...Uncut" name

			ESparams1.Data1=(LONG)FG;
			DUMPHEXIL("PanelClose: FG = ",(LONG)FG,"\\");
			SendSwitcherReply(ES_PanelClose,&ESparams1);
			break;
		case PAN_CANCEL:
		default:
			STOP=2;
			break;
		}
	}

	if (EditTop)
		DoAllNewDir(EditTop);

	if (EditBottom)
		DoAllNewDir(EditBottom);

	if (STOP==1)
		return(TRUE);
	else
		return(FALSE);
}

static BOOL DoProcClipPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for ProcClipPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_CLIPNAME,
		PLI_COMMENT,
		PLI_DESTDRV,
		PLI_INOUT,
		PLI_LENGTH,
		PLI_BAR,
		PLI_DEL,
		PLI_PREV,
		PLI_NEXT,
		PLI_ICONPT,
		PLI_DIVIDE2,
		PLI_INCLUDE,		
		PLI_PAD3,
		PLI_DIVIDE3,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	LONG type=PAN_EASY,B,Z,F=0,T=0,STOP=0, smpte=0;
// LONG Spot=0;
	char Label[MAX_PANEL_STR]="";
	struct SMPTEinfo si;
	struct PanelLine *pl;

	if(FlyerDriveCount==0) BuildFlyerList();		// Establish Flyer drive list

	InitPanelLines(EasyPanelPL,ProcClip_IPL);		// Copy basic init data into panel

	if(FG)
	{
//		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		sprintf(Label,"Process Clip \"%s\"",FilePart( ((struct ExtFastGadget *)FG)->FileName));

		T = Flds2Frms(GetValue(FG,TAG(RecFields)));  // Clip Frame Length
		if(T<2) T=4;
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
		if(GetTable(FG,TAG_SMPTEtime,(UBYTE *)&si,sizeof(struct SMPTEinfo)))
		{
			smpte = EVEN(SMPTEToLong(&si));
			DUMPUDECB("SMPTE Start: ",si.SMPTEhours,":");
			DUMPUDECB("",si.SMPTEminutes,":");
			DUMPUDECB("",si.SMPTEseconds,":");
			DUMPUDECB("",si.SMPTEframes,"  = ");
			DUMPUDECL(" ",smpte," frames \\");
		}
	}
	B=smpte+T;
	Z=smpte;

	while(!STOP)
	{
		switch(type)
		{
		case PAN_CONTINUE:
			STOP=1;
			break;
		case PAN_EASY:
		case PAN_EXPERT:
			EasyPanelPL[PLI_TITLE].Label= Label;		//Process Clip "xxxx"

			pl = &EasyPanelPL[PLI_CLIPNAME];
			pl->Param = (long *)"zzz";  // Name String
//			pl->PropEnd = CLIP_NAME_MAX;
			pl->PropEnd=29;		//Must allow for .i and be Amiga-legal!! (was MAX_STRING_BUFFER)
			pl->G5 = (struct Gadget *)200; // Custom string width
			pl->Flags = PL_DEL;

			// Setup drives/same popup
			pl = &EasyPanelPL[PLI_DESTDRV];
			pl->Param = (long *)FlyerDrives;
			pl->PropStart = FlyerDriveCount;
			pl->PropEnd = FlyerDriveCount+1;		// Include all drives + "same"
			pl->PLID = PLID_DESTPOPUP;
			strcpy(FlyerDrives[FlyerDriveCount],"Same as Original");

			pl = &EasyPanelPL[PLI_LENGTH];
			pl->Param = &B;  // Diff
			pl->Param2 = &Z;
			pl->G5 = (struct Gadget *)2; // Diff
			pl->Flags = PL_LEN;

			pl = &EasyPanelPL[PLI_COMMENT];
			pl->Param = (long *)CommentBuf;  // Name String
			pl->PropEnd = COMMENT_MAX;
			pl->G5 = (struct Gadget *)300; // string gad width
			pl->Flags = PL_AVAIL;

			pl = &EasyPanelPL[PLI_INOUT];
			pl->Param = &Z;
			pl->Param2 = &B;
			pl->PropStart = smpte;
			pl->PropEnd = T+ smpte - LENGTH_ADJUST;
			pl->Flags = PL_IN | PL_DUAL | PL_FLYER | PL_CFRAME;

			EasyPanelPL[PLI_BAR].HeightAdj = 32; // Gap for bar

			pl = &EasyPanelPL[PLI_DEL];
			pl->Param =(LONG *)GB_REMOVE;
			pl->Flags = PL_GENBUTT;

			pl = &EasyPanelPL[PLI_PREV];
			pl->Param =(LONG *)GB_PREV;
			pl->Flags = PL_GENBUTT;

			pl = &EasyPanelPL[PLI_NEXT];
			pl->Param =(LONG *)GB_NEXT;
			pl->Flags = PL_GENBUTT;
			pl->PropEnd = 2;							// Always use size 2 button (medium)

			F=T/2 + smpte;
			pl = &EasyPanelPL[PLI_ICONPT];
			if (((struct ExtFastGadget *)FG)->ObjectType == CT_AUDIO)
				pl->Type = PNL_SKIP;
			else
			{
				pl->Param = &F;
				pl->PropStart = smpte;
				pl->PropEnd = T + smpte - LENGTH_ADJUST;
				pl->Flags = PL_IN | PL_FLYER | PL_CFRAME | PL_AUDIO;
			}

			pl = &EasyPanelPL[PLI_DIVIDE2];
			if (((struct ExtFastGadget *)FG)->ObjectType != CT_AUDIO)
				pl->Type = PNL_SKIP;

			pl = &EasyPanelPL[PLI_INCLUDE];
			pl->Flags = PL_PLAY;
// CutClipPanel() will figure all this stuff out
//			pl->Param = (long *)Spot;
//			pl->PropEnd = 2;
//			pl->Param2 =(long *)CutTracks;

			MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
			MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

			type = CutClipPanel(Edit,FG,EasyPanelPL,FALSE,NULL);		// Invoke non-destructively
			break;
		case PAN_CANCEL:
		default:
			STOP=2;
			break;
		}
	}
	DUMPHEXIL("Gonna DoAllNewDir() FG = ",(LONG)FG,"\\");

	if (EditTop)
		DoAllNewDir(EditTop);

	if (EditBottom)
		DoAllNewDir(EditBottom);

	if(STOP==1)
		return(TRUE);
	else
		return(FALSE);
}

static UWORD DoCuttingPanel(

	struct EditWindow *Edit,
	struct FastGadget *FG,
	BOOL fromrec,
	char *cutname)
{
	enum {				// PL indices for CutClipPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_CLIPNAME,
		PLI_COMMENT,
		PLI_INOUT,
		PLI_LENGTH,
		PLI_BAR,
		PLI_DEL,
		PLI_PREV,
		PLI_NEXT,
		PLI_ICONPT,
		PLI_DIVIDE2,
		PLI_INCLUDE,
		PLI_PAD3,
		PLI_DIVIDE3,
		PLI_CONTINUE,
		PLI_RECPANEL,
		PLI_CANCEL,
	};

	LONG type=PAN_EXPERT,B,Z,F=0,T=0,STOP=0, smpte=0;
//	LONG Spot=0;
	char Label[MAX_PANEL_STR]="";
	struct SMPTEinfo si;
	struct PanelLine *pl;

	InitPanelLines(EasyPanelPL,CutClip_IPL);		// Copy basic init data into panel

	if(FG)
	{
//		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR-1);
		if (cutname)
			strcpy(Label,"Cut Raw Clip");
		else
			sprintf(Label,"Cut Clip \"%s\"",FilePart( ((struct ExtFastGadget *)FG)->FileName));

		T = Flds2Frms(GetValue(FG,TAG(RecFields)));  // Clip Frame Length
		if(T<2) T=4;

		// This will get nothing if temp clip was just recorded
		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);

		if(GetTable(FG,TAG_SMPTEtime,(UBYTE *)&si,sizeof(struct SMPTEinfo)))
		{
			smpte = EVEN(SMPTEToLong(&si));
			DUMPUDECB("SMPTE Start: ",si.SMPTEhours,":");
			DUMPUDECB("",si.SMPTEminutes,":");
			DUMPUDECB("",si.SMPTEseconds,":");
			DUMPUDECB("",si.SMPTEframes,"  = ");
			DUMPUDECL(" ",smpte," frames \\");
		}
	}

	B=smpte+T;
	Z=smpte;

//-------------
	EasyPanelPL[PLI_TITLE].Label= Label;	//"Cut Clip";

	pl = &EasyPanelPL[PLI_CLIPNAME];
	pl->Param = (long *)"zzz";		// Initial name string
//	pl->PropEnd = CLIP_NAME_MAX;
	pl->PropEnd=29;		//Must allow for .i and be Amiga-legal!! (was MAX_STRING_BUFFER)
	pl->G5 = (struct Gadget *)200; // Custom string width
	pl->Flags = PL_DEL;

	pl = &EasyPanelPL[PLI_LENGTH];
	pl->Param = &B;  // Diff
	pl->Param2 = &Z;
	pl->G5 = (struct Gadget *)2; // Diff
	pl->Flags = PL_LEN;

	pl = &EasyPanelPL[PLI_COMMENT];
	pl->Param = (long *)CommentBuf;  // Name String
	pl->PropEnd = COMMENT_MAX;
	pl->G5 = (struct Gadget *)300; // string gad width
	pl->Flags = PL_AVAIL;

	pl = &EasyPanelPL[PLI_INOUT];
	pl->Param = &Z;
	pl->Param2 = &B;
	pl->PropStart = smpte;
	pl->PropEnd = T+ smpte - LENGTH_ADJUST;
	pl->Flags = PL_IN | PL_DUAL | PL_FLYER | PL_CFRAME;

	EasyPanelPL[PLI_BAR].HeightAdj = 32; // Gap for bar

	pl = &EasyPanelPL[PLI_DEL];
	pl->Param =(LONG *)GB_REMOVE;
	pl->Flags = PL_GENBUTT;

	pl = &EasyPanelPL[PLI_PREV];
	pl->Param =(LONG *)GB_PREV;
	pl->Flags = PL_GENBUTT;

	pl = &EasyPanelPL[PLI_NEXT];
	pl->Param =(LONG *)GB_NEXT;
	pl->Flags = PL_GENBUTT;
	pl->PropEnd = 2;							// Always use size 2 button (medium)

	F=T/2 + smpte;
	pl = &EasyPanelPL[PLI_ICONPT];
	if (((struct ExtFastGadget *)FG)->ObjectType == CT_AUDIO)
		pl->Type = PNL_SKIP;
	else
	{
//		pl->Type = PNL_FLYTIME;
		pl->Param = &F;
		pl->PropStart = smpte;
		pl->PropEnd = T + smpte - LENGTH_ADJUST;
		pl->Flags = PL_IN | PL_FLYER | PL_CFRAME | PL_AUDIO;
	}

	pl = &EasyPanelPL[PLI_DIVIDE2];
	if (((struct ExtFastGadget *)FG)->ObjectType != CT_AUDIO)
		pl->Type = PNL_SKIP;

	pl = &EasyPanelPL[PLI_INCLUDE];
	pl->Flags = PL_PLAY;
//	pl->Param = (long *)Spot;
//	pl->PropEnd = 2;
//	pl->Param2 =(long *)CutTracks;

	MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

	pl = &EasyPanelPL[PLI_RECPANEL];
	DUMPUDECL("fromrec=",(LONG)fromrec,"\\");
	if(fromrec)										// If came from record panel, button back
	{
		pl->PropStart = 1;						// Want colored hilite
		pl->Param =(LONG *)GB_RECPANEL;		// General button code for "Rec Panel"
		pl->Flags = PL_GENBUTT;
	}
	else
		pl->Type = PNL_SKIP;


	while(!STOP)
	{
		switch(type)
		{
			case PAN_CONTINUE:
				STOP=1;
				break;
			case PAN_RECORD:			// Want to go back to record panel
				if (fromrec)
					STOP=2;				// Only if came from there originally
				break;
			case PAN_EXPERT:
				type = CutClipPanel(Edit,FG,EasyPanelPL,TRUE,cutname);		// Invoke destructively
				break;
			case PAN_CANCEL:
			default:
				STOP=2;
				break;
		}
	}
	DUMPHEXIL("Gonna DoAllNewDir() FG = ",(LONG)FG,"\\");

	if (STOP != 2)			// Don't redo view if cancelled/failed or going back to record
	{
		if (EditTop)
			DoAllNewDir(EditTop);

		if (EditBottom)
			DoAllNewDir(EditBottom);
	}

//	if(STOP==1) return(TRUE);
//	else return(FALSE);

	return((UWORD)type);
}

// CT_ERROR
static BOOL DoERRORPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for ErrorPL[]
		PLI_CROUTON,
		PLI_DIVIDE1,
		PLI_TYPE,
		PLI_NAME,
		PLI_BIRTH,
		PLI_GOWIDE,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	char Label[MAX_PANEL_STR+20];
	struct PanelLine *pl;
	LONG type=PAN_EASY;
	int	len;

	CommentBuf[0]=0;

	InitPanelLines(EasyPanelPL,Error_IPL);		// Copy basic init data into panel

	if(FG)
	{
		strcpy(Label,"Name: ");
//		strncat(Label,FilePart( ((struct ExtFastGadget *)FG)->FileName),MAX_PANEL_STR+20-1);
		strncat(Label,((struct ExtFastGadget *)FG)->FileName,MAX_PANEL_STR+20-1);

		GetTable(FG,TAG_CommentList,CommentBuf,COMMENT_MAX);
//		strcpy(CommentBuf,"No Comment At This Time");

		strcpy(ClipPath,"Original Location: ");
		len = strlen(ClipPath);
		GetTable(FG,TAG_OriginalLocation,&ClipPath[len],CLIP_PATH_MAX-1-len);

		sprintf(TempC2,"Crouton Type: %ls",
			DTNames[CroutonIndex(((struct ExtFastGadget *)FG)->LocalData)]);
	}

	if( (type==PAN_EASY) || (type==PAN_EXPERT) )
	{
		pl = &EasyPanelPL[PLI_CROUTON];
		pl->Label = "Lost Crouton";
	// No bitmap, let default for CR_ERROR show
	//	pl->Param2 = (FG ? (long *)FG->Data:(long *)NULL) ; // icon bitmap
		pl->Param = (long *)CommentBuf;
		pl->PropEnd = COMMENT_MAX ;		// max string length
		pl->PropStart=0;						// Gets set to non-zero if comment is changed...

		EasyPanelPL[PLI_TYPE].Label = TempC2;
		EasyPanelPL[PLI_NAME].Label = Label;
		EasyPanelPL[PLI_BIRTH].Label = ClipPath;

		MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
		MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

		type = MiniPanel(Edit, EasyPanelPL,TUNE_NONE);
	}
	if(type==PAN_CONTINUE)
	{
		return(TRUE);
	}
	return(FALSE);
}

#if TESTING_ONLY
static BOOL DoTestPanel(struct EditWindow *Edit, struct FastGadget *FG)
{
	enum {				// PL indices for XPTestPL[]
		XPLI_TITLE,
		XPLI_DIVIDE1,
		XPLI_STRING,
		XPLI_POPUP,
		XPLI_NUMBER,
		XPLI_PLAY,
		XPLI_DIVIDE2,
		XPLI_CONTINUE,
		XPLI_CANCEL,
	};

	char Mystr[50]="Aboud's"; //,*ts="Test" ,*LR[]={"L","R"};
	long	D=98,T=450,type=PAN_EXPERT;
	BOOL Jam_On=TRUE;
	PanHandler	PanelFun; 

	FG=NULL;

	InitPanelLines(ExpertPanelPL,XPTest_IPL);		// Copy basic init data into panel

	ExpertPanelPL[XPLI_STRING].Param = (long *)Mystr;	// STRING
	ExpertPanelPL[XPLI_STRING].PropEnd = 50;

	ExpertPanelPL[XPLI_POPUP].Param = (long *)Pnls;		// POPUP
	ExpertPanelPL[XPLI_POPUP].PropStart = 6;
	ExpertPanelPL[XPLI_POPUP].PropEnd = PNL_NUM;

	ExpertPanelPL[XPLI_NUMBER].Param = (long *)&D;			// NUMBER
	ExpertPanelPL[XPLI_NUMBER].PropStart = 0;  // min
	ExpertPanelPL[XPLI_NUMBER].PropEnd = 100;  // max

	ExpertPanelPL[XPLI_PLAY].Param = (long *)&T;			// PLAY
	ExpertPanelPL[XPLI_PLAY].UserFun = CTRL_Play;

	MakeStdContinue(&ExpertPanelPL[XPLI_CONTINUE]);
	MakeStdCancel(&ExpertPanelPL[XPLI_CANCEL]);

	while(Jam_On)
	{
		type = MiniPanel(Edit, ExpertPanelPL,TUNE_NONE);
		if(type == PAN_CANCEL) Jam_On=FALSE;
		if(ExpertPanelPL[XPLI_PLAY].Param)
		{
			if( (PanelFun=PanHandlers[ExpertPanelPL[XPLI_POPUP].PropStart]) )  // check type for validity 1st!!!
				Jam_On = PanelFun(Edit,FG);
		}
	}
	return(Jam_On);
}
#endif


UWORD __asm DoInfoPanel(
	REG(a0) char *Path,
	REG(a1) char *File,
	REG(a2) struct EditWindow *Edit,
	REG(d0) UWORD type )
{
	enum {				// PL indices for FileInfoPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_NAME,
		PLI_TYPE,
		PLI_COMP,
		PLI_COMMENT,
		PLI_TIME,
		PLI_SIZE,
		PLI_DATE,
		PLI_ATTRIB,
		PLI_PROT,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	char *MPtr[5],*c,ClipTime[20]; // ,num[5];
	struct FileInfoBlock *fib;
	struct FlyerVolume FlyVol;
	struct ClipInfo		clip;
	struct PanelLine	*pl;
	BPTR L;
	UWORD result =0;
	WORD i=1;
	ULONG	sz,dec,frms;
	BOOL	retry;
	UWORD	Qtype = 0;

	InitPanelLines(EasyPanelPL,FileInfo_IPL);		// Copy basic init data into panel

	do {
		retry = FALSE;
	
//		if(type<=GT_EFFECT) i=0;
//		else  type-=GT_EFFECT;
		if(type<=CR_FXANIM) i=0;
//		if(!SwitPort)
//			DoTBCPanel(Edit,NULL);

		if (L = Lock(Path,ACCESS_READ))
		{
			if (fib = SafeAllocMem(sizeof(struct FileInfoBlock),MEMF_CLEAR))
			{
				if (Examine(L,fib))
				{
					strncpy(Name,fib->fib_FileName,MAX_STRING_BUFFER-1);
					pl = &EasyPanelPL[PLI_NAME];
					pl->Param=(LONG *)Name;
					pl->PropEnd=29;		//Must allow for .i and be Amiga-legal!! (was MAX_STRING_BUFFER)
					pl->G5 = (struct Gadget *)150; // Custom string width
					pl->Flags = PL_ACTIVATE;			// Activate this initially

					EasyPanelPL[PLI_TYPE].Label = DTNames[type];


					EasyPanelPL[PLI_COMMENT].Label = fib->fib_Comment;
					EasyPanelPL[PLI_TIME].Label = "";
//					EasyPanelPL[PLI_TIME].Type = PNL_SKIP;
					if (fib->fib_DirEntryType > 0)
					{
						EasyPanelPL[PLI_TYPE].Label = "";
						strcpy(Size,"Directory");
					}
					else
					{

						if ((type == CR_VIDEO) || (type == CR_AUDIO))
						{
// These are deduced for us by flyer.library based on the volume part in the "Path"
//							FlyVol.Board = 0;
//							FlyVol.SCSIdrive = drive;
							FlyVol.Flags = 0;
							FlyVol.Path = Path;

//							DUMPSTR("Info on '");
//							DUMPSTR(Path);
//							DUMPMSG("'");

							clip.len = sizeof(struct ClipInfo);		// IMPORTANT!
							if (GetClipInfo(&FlyVol,&clip) == FERR_OKAY)
							{
// Use this info for video clips???
//	if (clip.Flags & CIF_HASAUDIO)
//		printf("audio -- %ld channel(s)",clip.NumAudChans);

								EasyPanelPL[PLI_COMP].Type = PNL_TEXT;		// Don't skip it

								if (type == CR_VIDEO) 
									if (clip.VideoGrade == VG_HQ6)
										Qtype = 3;					
									else	
										if (clip.VideoGrade == VG_HQ5)
											Qtype = 2;					
										else 
											Qtype = 1;					
								else
								{	
									Qtype = 0;					
									EasyPanelPL[PLI_COMP].Type = PNL_SKIP;		// skip it
								}		
								EasyPanelPL[PLI_COMP].Label = QTNames[Qtype];

								strcpy(ClipTime,"Time ");
								frms = Flds2Frms(clip.Fields);
								LongToTime(&frms,&ClipTime[5]);
								EasyPanelPL[PLI_TIME].Label = ClipTime;
//								EasyPanelPL[PLI_TIME].Type = PNL_TEXT;		// Don't skip it
							}
						}

						sz=fib->fib_Size;
						if( fib->fib_Size < 0)
							sz=(ULONG)((fib->fib_Size&0x7FFFFFFF) + 0x80000000);
						dec=sz;
						if( (sz>>20)>=10 ) // greater than 10M
						{
							sz >>= 20;
							dec = (dec<<12)>>(12+18);
							if(dec)
								sprintf(Size, "Size %d.%d Mb",sz,dec);
							else
								sprintf(Size, "Size %d Mb",sz);
						}
						else if( (sz>>10)>=50 ) // greater than 50K
						{
							sz >>= 10;
							dec = (dec<<22)>>(22+8);
							if(dec)
								sprintf(Size, "Size %d.%d Kb",sz,dec);
							else
								sprintf(Size, "Size %d Kb",sz);
						}
						else
							sprintf(Size, "Size %d bytes",fib->fib_Size);
					}
					EasyPanelPL[PLI_SIZE].Label = Size;

// getft() does NOT return GMT as documented!  It does a Lock/Examine to get a fib_Date,
// Converts Days/Mins/Ticks from 1978 to seconds from 1970, and returns that
// All the information I have shows that fib_Date is in local time.  So we were running
// local time thru localtime(), which did an incorrect translation from GMT to local.
// I substituted gmtime() which does no such translation, and the dates are correct now
//	OLD-->		if (((ft=getft(Path)) != -1) && (strftime(TempCh,60,"%a, %b %d, %Y %I:%M %p",localtime(&ft))))
					if (((ft=getft(Path)) != -1) && (strftime(TempCh,60,"%a, %b %d, %Y %I:%M %p",gmtime(&ft))))
						EasyPanelPL[PLI_DATE].Label =TempCh;

					EasyPanelPL[PLI_ATTRIB].Label = "";
					EasyPanelPL[PLI_PROT].Label = ""; // date...

					MakeStdContinue(&EasyPanelPL[PLI_CONTINUE]);
					MakeStdCancel(&EasyPanelPL[PLI_CANCEL]);

					if( result=(MiniPanel(Edit,EasyPanelPL,TUNE_NONE) ? 1:0) )
					{
						if(strnicmp(Name,fib->fib_FileName,MAX_STRING_BUFFER) )	// Rename desired?
						{
							strncpy(Dir,Path,MAX_STRING_BUFFER);
							c=FilePart(Dir);
							*c=0;
									MPtr[0] = "Renaming";
									MPtr[1] = Path;
									MPtr[2] = " To ";
									MPtr[3] = Dir;
									MPtr[4] = Name;
							strncat(Dir,Name,119);
							if(SimpleRequest(Edit->Window,MPtr,4,REQ_CENTER|REQ_H_CENTER|REQ_OK_CANCEL,NULL))
							{
								result += (Rename(Path,Dir) ? 1:0);
								if (result != 2)			// Failed to rename?
								{
									MPtr[0] = "Unable to rename";
									MPtr[1] = Path;
									MPtr[2] = " To ";
									MPtr[3] = Dir;
									MPtr[4] = IoErrToText(IoErr());
									SimpleRequest(Edit->Window,MPtr,5,REQ_CENTER|REQ_H_CENTER,NULL);
									retry = TRUE;		// Reopen panel to try again
								}
								else
								{
									DUMPSTR("Rename ");
									DUMPSTR(Path);
									DUMPSTR(" To ");
									DUMPMSG(Dir);
									strncpy(Name,Path,119);
									strncat(Name,".i",119);
									strncat(Dir,".i",119);
									Rename(Name,Dir);
									strncat(Name,"nfo",119);
									strncat(Dir,"nfo",119);
									Rename(Name,Dir);
								}
							}
						}
					}
					*Name=0;
				}
				FreeMem(fib,sizeof(struct FileInfoBlock));
			}
			UnLock(L);
		}
	} while (retry);		// Try again, rename failed

	return(result);
}


UWORD DoDriveInfoPanel(char *VolName,struct EditWindow *Edit)
{
	enum {				// PL indices for DriveInfoPL[]
		PLI_TITLE,
		PLI_DIVIDE1,
		PLI_NAME,
		PLI_TYPE,
		PLI_SIZE,
		PLI_FREE,
		PLI_DIVIDE2,
		PLI_LARGEST,
		PLI_REORG,
		PLI_REORGBTN,
		PLI_DIVIDE3,
		PLI_CONTINUE
	};

	struct FlyerVolume FlyVol;
	struct FlyerVolInfo	FVI;
	struct InfoData	*id;
	struct PanelLine	*pl;
	ULONG	sizeblks,freeblks,fragblks,pctfree;
	UWORD pnl = PAN_EASY;
	UBYTE err;
	BPTR	lock;
	char TempC3[30];
	enum DRIVETYPE {VOLBAD,UNFORMATTED,NONFLYER,FLYVID,FLYAUD,FLYMISC} type;

	static char *DrvTypeNames[] = {
		"Bad","Unformatted","Non-Flyer Drive","Flyer Video","Flyer Audio","Flyer Other"
	};

	do
	{
		InitPanelLines(EasyPanelPL,DriveInfo_IPL);		// Copy basic init data into panel

// 	These are deduced for us by flyer.library based on the volume part in the "Path"
//		FlyVol.Board = 0;
//		FlyVol.SCSIdrive = drive;
		FlyVol.Flags = 0;
		FlyVol.Path = VolName;

		FVI.len = sizeof(struct FlyerVolInfo);		// IMPORTANT!
		err = FlyerDriveInfo(&FlyVol,&FVI);		// Try to get info on Flyer drive
		if (err==FERR_VOLNOTFOUND)				// Must not be a Flyer drive
		{
			type = VOLBAD;			// Default, if anything goes wrong

			// Attempt to get info on non-Flyer drive
			lock = Lock(VolName,ACCESS_READ);
			if (lock)
			{
				id = (struct InfoData *) SafeAllocMem(sizeof(struct InfoData),MEMF_PUBLIC|MEMF_CLEAR);
				if (id)
				{
					if (Info(lock,id))
					{
						type = NONFLYER;

						sizeblks = id->id_NumBlocks;
						freeblks = sizeblks - id->id_NumBlocksUsed;

						// Normalize to 512 bytes/blk for bigger block sizes
						while (id->id_BytesPerBlock > 512)
						{
							sizeblks <<= 1;
							freeblks <<= 1;
							id->id_BytesPerBlock >>= 1;
						}
					}
					FreeMem((char *)id,sizeof(struct InfoData));
				}
				UnLock(lock);
			}
		}
		else
		{
			if (err)								// Is a Flyer drive, but a problem arose
				type = VOLBAD;
			else if (FVI.Ident != 0x524f4f54)
				type = UNFORMATTED;
			else if (FVI.Flags & FVIF_VIDEOREADY)
				type = FLYVID;
			else if (FVI.Flags & FVIF_AUDIOREADY)
				type = FLYAUD;
			else
				type = FLYMISC;

			sizeblks = FVI.Blocks;
			freeblks = FVI.BlksFree;
			fragblks = FVI.FragBlks;
		}

		EasyPanelPL[PLI_NAME].Label=VolName;
		EasyPanelPL[PLI_TYPE].Label=DrvTypeNames[type];

		EasyPanelPL[PLI_SIZE].Label=NULL;
		EasyPanelPL[PLI_FREE].Label=NULL;
		EasyPanelPL[PLI_DIVIDE2].Type=PNL_SKIP;		// Not usually here
		EasyPanelPL[PLI_LARGEST].Label=NULL;
		EasyPanelPL[PLI_REORG].Label=NULL;
		EasyPanelPL[PLI_REORGBTN].Type=PNL_SKIP;		// Not usually here

		if ((type!=VOLBAD) && (type!=UNFORMATTED))
		{
			FmtBlocks2Size(Size,"Size", sizeblks);
			EasyPanelPL[PLI_SIZE].Label=Size;

//			temp = ((sizeblks-freeblks)*100)/sizeblks;		// % used
			pctfree = (freeblks*100)/sizeblks;						// % free
			if (pctfree>100) pctfree=100;			// Avoid looking insane
			sprintf(TempCh,"%ld%% Free",pctfree);
			EasyPanelPL[PLI_FREE].Label=TempCh;

			if (type != NONFLYER)
			{
				EasyPanelPL[PLI_DIVIDE2].Type=PNL_DIVIDE;		// Put line in

				FmtBlocks2Size(TempC2,"Largest Free", FVI.Largest);
				EasyPanelPL[PLI_LARGEST].Label=TempC2;

				FmtBlocks2Size(TempC3,"Upon ReOrg", FVI.Optimized);
				EasyPanelPL[PLI_REORG].Label=TempC3;

				pl = &EasyPanelPL[PLI_REORGBTN];		// Okay, allow re-org
				pl->Type = PNL_BUTTON;
				pl->Param =(LONG *)GB_REORG;			// General button code for ReOrg
				pl->Flags = PL_SMREF | PL_GENBUTT;	// Need smart refresh for reorg requester
				global_CurVolumeName = VolName;		// Use this w/ ReOrg button
			}
		}

		pl = &EasyPanelPL[PLI_CONTINUE];
		pl->Type = PNL_BUTTON;
		MakeStdContinue(pl);

		pnl = MiniPanel(Edit,EasyPanelPL,TUNE_NONE);
	} while (pnl > PAN_CONTINUE);

	global_CurVolumeName = NULL;

	return(pnl);
}



//*******************************************************************
static BOOL DoEnvPanel(struct EditWindow *Edit,
							  struct FastGadget *FG,
							  LONG Time_In,LONG Time_Out,
							  LONG FadeIn,LONG FadeOut,
							  struct AudioEnv *AETagTable)
{
	enum {				// PL indices using new other panel(OtherPanelPL)  
		PLI_TITLE,
		PLI_DIVIDE,
		PLI_TEXT,
		PLI_TEXT2,

		PLI_ACTION,
		PLI_TIME,
		PLI_VOLUME,

		PLI_TEXT3,	
		PLI_USEENV,

		PLI_TEXT4,
		PLI_DIVIDE2,
		PLI_CONTINUE,
		PLI_CANCEL,
	};

	int i,type;
	struct PanelLine	*pl;
	LONG S=0,Vol=0,useenv=0;


	useenv=AETagTable->Flags;

	DUMPHEXIL("Time_In  ",(LONG)Time_In,"\\");
	DUMPHEXIL("Time_Out ",(LONG)Time_Out,"\\");
	DUMPHEXIL("FadeIn   ",(LONG)FadeIn,"\\");
	DUMPHEXIL("FadeOut  ",(LONG)FadeOut,"\\");


	InitPanelLines(OtherPanelPL,Env_IPL);		// Copy basic init data into panel

	pl = &OtherPanelPL[PLI_ACTION];
	pl->Param =(LONG *)EnvGadgetModes;
	pl->PropStart = 0;						// Want colored hilite
	pl->PropEnd = 3;


	pl = &OtherPanelPL[PLI_TIME];
	pl->Param = &S;
	pl->PropStart = 0;
	pl->PropEnd = 0xFFFFFF;
	pl->Flags = PL_ENVELOPE;


	pl = &OtherPanelPL[PLI_VOLUME];
	pl->Param = &Vol;
	pl->PropStart = 0;
	pl->PropEnd = 100;
	pl->Flags = PL_ENVELOPE;


	pl = &OtherPanelPL[PLI_USEENV];
	pl->Param = (LONG *)useenv;
	pl->PLID	= PLID_USEAUDENV;

	MakeStdContinue(&OtherPanelPL[PLI_CONTINUE]);
	MakeStdCancel(&OtherPanelPL[PLI_CANCEL]);

	type = AudEnvPanel(Edit,OtherPanelPL,
							 Time_In,Time_Out,
							 FadeIn,FadeOut,AETagTable);

	if(type==PAN_CANCEL)
	{
		DUMPMSG("Restoring");
	}
	else
	{
		DUMPMSG("Saving");
	}
	return(TRUE);
}



static void FmtBlocks2Size(char *Dest,char *Label, ULONG Blocks)
{
	#define	BLKSPERKILOBYTE	1024/512
	#define	BLKSPERMEGABYTE	1024*2
	#define	BLKSPERGIGABYTE	1024*1024*2

	ULONG	size,sz10;

	size = Blocks;

	if (size >= (10*BLKSPERGIGABYTE))					// greater than 10G?
		sprintf(Dest, "%ls %d Gb",Label,size>>21);
	else if (size >= (BLKSPERGIGABYTE))					// greater than 1G?
	{
		sz10 = size / (BLKSPERGIGABYTE/10);
		sprintf(Dest, "%ls %d.%d Gb",Label,sz10/10,sz10%10);
	}
	else if (size >= (10*BLKSPERMEGABYTE))					// greater than 10M?
		sprintf(Dest, "%ls %d Mb",Label,size>>11);
	else if (size >= (BLKSPERMEGABYTE))				// greater than 1M?
	{
		sz10 = size / (BLKSPERMEGABYTE/10);
		sprintf(Dest, "%ls %d.%d Mb",Label,sz10/10,sz10%10);
	}
	else
		sprintf(Dest, "%ls %d Kb",Label,size>>1);
}


ULONG CroutonIndex(ULONG Type)
{
	ULONG i;
	DUMPHEXIL(" Looking for Type: ",(LONG)Type," \\");
	for(i=CR_FXANIM; i<= CR_UNKNOWN; i++)
	{
		DUMPUDECL("CRuDTypes[ ",(LONG)i," ] =");
		DUMPHEXIL(" ",(LONG)CRuDTypes[i]," \\");
		if(Type == CRuDTypes[i]) return(i);
	}
	DUMPUDECL("Didn't find it... ",(LONG)i,"\\ ");
	return(CR_UNKNOWN);
}

#define VALID_CTYPE(t)		((t<=CR_UNKNOWN)&&(t>=CR_FXANIM))
//#define VALID_CTYPE(t)		((t<=CR_ERROR)&&(t>=CR_FXANIM))
//*******************************************************************
// Could really be called DoFGPanel
struct EditWindow *HandlePanel(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	ULONG type,indx;
	struct FastGadget *FG,*Next;
	BOOL DontStop=TRUE;
	PanHandler	PanelFun;

	FG = *(((struct Project *)Edit->Special)->PtrPtr);

	if( FlyerBase && (IntuiMsg->Qualifier&IEQUALIFIER_CONTROL) && (IntuiMsg->Qualifier&IEQUALIFIER_LSHIFT) )
	{
		DoTweakPanel(Edit,FG);
		return(Edit);
	}
//	else if( FlyerBase && (IntuiMsg->Qualifier&IEQUALIFIER_CONTROL) && (IntuiMsg->Qualifier&IEQUALIFIER_LALT) )
	else if( (IntuiMsg->Qualifier&IEQUALIFIER_CONTROL) && (IntuiMsg->Qualifier&IEQUALIFIER_LALT) )
	{
		DoTBCPanel(Edit,FG);
		return(Edit);
	}

	while (FG && DontStop)
	{
		Next = FG->NextGadget;
		if (FG->FGDiff.FGNode.Status == EN_SELECTED)
		{
			type=((struct ExtFastGadget *)FG)->ObjectType;
			indx = CroutonIndex(type);
			DUMPSTR(DTNames[indx]);
			DUMPHEXIL(" has type ",type,"  ");
			if(VALID_CTYPE(indx))
			{
				SetCurrentTime(-1);			// Lose this, too hard to track

				DUMPUDECL(" Valid type",indx,"\\");
				CurFG=FG;
				ESparams1.Data1=(LONG)FG;
				DUMPHEXIL("PanelOpen: FG = ",(LONG)FG,"\\");
				SendSwitcherReply(ES_PanelOpen,&ESparams1);
				PlayFG=NULL;
//				if(IntuiMsg->Qualifier & IEQUALIFIER_CAPSLOCK)
				if (EFF_EXPPANELS & UserPrefs.EditFlags)			// Prefer expert panels?
					PanType=PAN_EXPERT;
				else
					PanType=PAN_EASY;
				if( (PanelFun=PanHandlers[indx]) )
					DontStop = PanelFun(Edit,FG);
				ESparams1.Data1=(LONG)FG;
				DUMPHEXIL("PanelClose: FG = ",(LONG)FG,"\\");
				SendSwitcherReply(ES_PanelClose,&ESparams1);

				CalcRunningTime();		// Re-calculate sequence total time
			}
		}
		FG = Next;
	}
	return(Edit);
}


//=============================================================
// HandleAudioOnOff
//		Turn crouton's audio on/off outside of control panel
//=============================================================
void HandleAudioOnOff(struct EditWindow *Edit)
{
	struct ExtFastGadget *curfg,*fg;
	int	newstate;
	LONG	audio;
	BOOL	redraw;

	DUMPMSG("Audio On/Off");

	curfg = (struct ExtFastGadget *)CurFG;			// Hilited crouton (if any)
	if (!curfg)
	{
		curfg = FindFirstHilited(Edit);		// If none, pick first hilited as "curfg"
		DUMPHEXIL("FirstHilite=",(LONG)curfg,"\\");
	}

	if (curfg)									// Must have a crouton hilited, or we bail out
	{
		// First, decide (based on last hilited) whether to turn on or off all hilited
		audio = GetValue((struct FastGadget *)curfg,TAG(AudioOn));
		if (
			((audio&AUDF_Channel1Recorded)&&(audio&AUDF_Channel1Enabled))
		|| ((audio&AUDF_Channel2Recorded)&&(audio&AUDF_Channel2Enabled))
		)
			newstate = 0;
		else
			newstate = 1;

		// Since "next" pointer is first LONG of the FastGadget,
		// we just substitute the Address of the FG list head
		fg = (struct ExtFastGadget *)((struct Project *)Edit->Special)->PtrPtr;

		// Do operation for all croutons selected (of the proper type)
		while (fg = (struct ExtFastGadget *)GetNextEditNode(Edit,(struct EditNode *)fg))
		{
			redraw = FALSE;

			if (fg->FG.FGDiff.FGNode.Status == EN_SELECTED)
			{
				switch(fg->ObjectType)
				{
				case CT_VIDEO:
					audio = GetValue((struct FastGadget *)fg,TAG(AudioOn));

					if (newstate)		// Turn audio on?
					{
						DUMPMSG("audio on");

						if (audio & AUDF_Channel1Recorded)
						{
							audio |= AUDF_Channel1Enabled;
							fg->SymbolFlags |= SYMF_AUDIO;		// Audio is on
							redraw = TRUE;
						}
						if (audio & AUDF_Channel2Recorded)
						{
							audio |= AUDF_Channel2Enabled;
							fg->SymbolFlags |= SYMF_AUDIO;		// Audio is on
							redraw = TRUE;
						}
					}
					else
					{
						DUMPMSG("audio off");
						audio &= ~(AUDF_Channel1Enabled | AUDF_Channel2Enabled);

						fg->SymbolFlags &= ~SYMF_AUDIO;		// Audio is off
						redraw = TRUE;
					}
					if (redraw)
						PutValue((struct FastGadget *)fg,TAG(AudioOn),audio);
					break;
				}
			}

			if (redraw)
				ew_ForceRedraw(Edit,GetProjNodeOrder(Edit,(struct FastGadget *)fg));
		}
	}
}


void ProcessCrouton(struct EditWindow *Edit, BOOL destructive)
{
	struct SmartString *Path,*Item;
	struct EditNode *Node,*Next;
	struct FastGadget *FG = NULL,*NextFG;
	struct EditWindow *srcwin = NULL;
	BOOL	shoveon = TRUE;

	// Find which window (if any) has croutons that are highlighted
	if (CheckNodeStatus(EditTop,EN_SELECTED))
		srcwin = EditTop;
	else if (EditBottom)
	{
		if (CheckNodeStatus(EditBottom,EN_SELECTED))
			srcwin = EditBottom;
	}

	if (srcwin == NULL)
		return;


	if (srcwin->Node.Type == EW_GRAZER)				// Need to make a fake project FG?
	{
		DUMPSTR("In grazer window");

		// Scan thru grazer FG's, looking for highlighted ones
		Node = (struct EditNode *)srcwin->Special->pEditList->lh_Head;
		while (shoveon && (Next=(struct EditNode *)Node->Node.MinNode.mln_Succ))
		{
			if (Node->Status==EN_SELECTED)
			{
				DUMPSTR("Found one selected");

				if (((struct GrazerNode *)Node)->DOSClass==EN_FILE)		// Only for files!
				{
					DUMPSTR("Is a file");

					Path = ((struct Grazer *)srcwin->Special)->Path;
					if ((Item = DuplicateSmartString(Path)) && AppendToPath(Node->Node.Name,Item))
					{
						if (FG = AllocProj(GetCString(Item)))
						{
							DUMPHEXIL("Made fake FG = ",(LONG)FG,"\\");

							DUMPUDECL("Vdur=",GetValue(FG,TAG(Duration)),"\\");
							DUMPUDECL("Avol1=",GetValue(FG,TAG(AudioVolume1)),"\\");
							DUMPUDECL("Avol2=",GetValue(FG,TAG(AudioVolume2)),"\\");

							shoveon = ProcCrtnPanel(FG,destructive);
							shoveon = FALSE;	// May alter grazer list and remove other selects anyway

							FreeProjectNode(FG);			// Free it back up
						}
					}

					if (Item) FreeSmartString(Item);
				}
			}
			Node = Next;
		}
	}
	else if (srcwin->Node.Type == EW_PROJECT)			// Already loaded?
	{
		DUMPSTR("In project window");

		FG = *((struct Project *)Edit->Special)->PtrPtr;
		while (FG && shoveon)
		{
			NextFG = FG->NextGadget;
			if (FG->FGDiff.FGNode.Status == EN_SELECTED)
			{
				shoveon = ProcCrtnPanel(FG,destructive);
				shoveon = FALSE;	// May alter grazer list and remove other selects anyway
			}
			FG = NextFG;
		}
	}
}


static BOOL ProcCrtnPanel(struct FastGadget *FG, BOOL destructive)
{
	BOOL	shoveon = FALSE;
	LONG	type;

	DUMPSTR("ProcCrtnPanel...");

	if (FG)
	{
		// Only works on video and audio clips
		type = ((struct ExtFastGadget *)FG)->ObjectType;
		if ((type == CT_VIDEO) || (type == CT_AUDIO))
		{
			CurFG = FG;		// Must do this so Switcher gets tags okay, but I don't know why

			DUMPSTR("Cutting panel...");

			ESparams1.Data1=(LONG)FG;
			SendSwitcherReply(ES_PanelOpen,&ESparams1);		// Opening panel, prepare to jog

			if (destructive)
				shoveon = DoCuttingPanel(EditTop,FG,FALSE,NULL);		// (Lookup FG name)
			else
				shoveon = DoProcClipPanel(EditTop,FG);	// Returns TRUE if continued, FALSE if cancelled

			ESparams1.Data1=(LONG)FG;
			SendSwitcherReply(ES_PanelClose,&ESparams1);

			CurFG = NULL;
		}
	}

	return(shoveon);
}
