/********************************************************************
* $Errors.c$
* $Id: errors.c,v 2.17 1995/08/02 15:09:50 Flick Exp $
* $Log: errors.c,v $
*Revision 2.17  1995/08/02  15:09:50  Flick
*Added 2 errors: FlyerClipMissing & OutOfOrder
*
*Revision 2.16  1995/06/28  18:09:50  Flick
*Re-added A/B roll and no audio drive errors
*Reworded FX leading/trailing errors and added #'s of frames!
*
*Revision 2.15  1995/06/26  17:13:08  Flick
*Added 'CantCreateBlack' error
*
*Revision 2.14  1995/06/20  23:39:18  Flick
*No longer accessed by address, but by index in ErrMsgs table.  Indices are
*mnemonic now (yeah) and are enumerated in seqerrors.h
*
*Revision 2.13  1995/04/21  01:45:03  Flick
*Added message to indicate missing audio drive.  Reworded most Flyer head-
*related messages to reflect true cause.  Other minor grammatical polish
*
*Revision 2.12  1995/02/19  18:21:04  Kell
**** empty log message ***
*
*Revision 2.11  1995/02/10  20:26:18  Kell
**** empty log message ***
*
*Revision 2.10  1995/02/09  18:51:09  Kell
**** empty log message ***
*
*Revision 2.9  1995/01/06  22:09:12  Kell
*Tweeked messages
*
*Revision 2.8  1995/01/06  20:48:06  Kell
**** empty log message ***
*
*Revision 2.7  1995/01/06  20:33:07  Kell
**** empty log message ***
*
*Revision 2.6  1994/12/27  22:37:42  Kell
*New error messages.
*
*Revision 2.5  1994/12/06  17:07:36  Kell
**** empty log message ***
*
*Revision 2.4  1994/12/03  06:02:17  Kell
**** empty log message ***
*
*Revision 2.3  1994/11/16  13:27:45  CACHELIN4000
*Add far to string declarations
*
*Revision 2.2  1994/11/15  15:12:50  Kell
*More error messages.  New novice user text.
*
*Revision 2.1  1994/11/14  15:21:54  CACHELIN4000
*add Negative Reinforcement mode, fix James' typos..
*
*Revision 2.0  1994/11/09  20:06:38  Kell
*FirstCheckIn
*
*
* Copyright (c)1994 NewTek, Inc.
* Confidental and Proprietary. All rights reserved. 
*
*********************************************************************/

//#define NEG_REINFORCE_USER
#ifdef NEG_REINFORCE_USER
static far char Problem_Discovered[] = {" Problem Discovered:"};
static far char Possible_Solution[] = {" Possible Solution:"};
static far char Possible_Solutions[] = {" Possible Solutions:"};
#else
static far char Problem_Discovered[] = {" Problem Discovered:"};
static far char Possible_Solution[] = {" Possible Solution:"};
static far char Possible_Solutions[] = {" Possible Solutions:"};
#endif

far char ErrorDetails[80] = " ";		// Error detail line built here


// This is how you put comments in this file. Use "//" at start of line.
// If you want to put a double quote in one of your messages, type \"
// instead of just " .

// Warning! Do not include Tabs in these messages.


/*
This is the approximate suggested length for lines in these error requesters:
"*******************************************************",
*/

static far char *Err_Internal[]={
 Problem_Discovered,
"   *** Sequencer Internal Error ***",
 ErrorDetails,
" ",
 Possible_Solution,
"   This error has not been anticipated. Please",
"   record the conditions that caused it on a",
"   Beta Report form and report it to NewTek.",
0};


static far char *Err_InternalFlyer[]={
 Problem_Discovered,
"   *** Flyer Internal Error ***",
 ErrorDetails,
" ",
 Possible_Solution,
"   This error has not been anticipated. Please",
"   record the conditions that caused it on a",
"   Beta Report form and report it to NewTek.",
0};


/************************* Resource Errors *************************/

static far char *Err_OutOfMemory[]={
 Problem_Discovered,
"   Not enough memory to play this sequence",
" ",
 Possible_Solutions,
"   1) Install more RAM on this system",
"   2) Split this project into smaller sequences",
0};


static far char *Err_OutOfFlyerMemory[]={
 Problem_Discovered,
"   Flyer sequencer out of memory",
" ",
 Possible_Solutions,
"   1) Split this project into smaller sequences",
"   2) Remove unnecessary split-audio or effects",
"      between clips",
0};


/************************* Effects Errors *************************/

//static far char *Err_EffectAtStart[]={
// Problem_Discovered,
//"   Sequence starts with an effect",
//" ",
// Possible_Solutions,
//"   1) Insert a video event in front of this effect",
//"   2) Remove the effect",
//"   3) Move it after a video event",
//0};


//static far char *Err_EffectAtEnd[]={
// Problem_Discovered,
//"   Sequence ends with an effect",
//" ",
// Possible_Solutions,
//"   1) Remove the highlighted effect",
//"   2) Place a video source event after it",
//0};


static far char *Err_EffectAfterEffect[]={
 Problem_Discovered,
"   Sequence contains two effects in a row",
" ",
 Possible_Solutions,
"   1) Remove one of the effects",
"   2) Insert a video event between them",
0};


static far char *Err_EffectStartsEarly[]={
 Problem_Discovered,
"   Effect starts too near the beginning of the",
"   previous video event",
" ",
 Possible_Solutions,
"   1) Shorten the length of the highlighted effect",
"   2) Lengthen the video event before it",
0};


static far char *Err_EffectNearEffect[]={
 Problem_Discovered,
"   Effect starts too near previous effect",
" ",
 Possible_Solutions,
"   1) Shorten the length of either effect",
"   2) Lengthen the video between them",
0};


static far char *Err_EffectEndsLate[]={
 Problem_Discovered,
"   Effect ends too late",
" ",
 Possible_Solutions,
"   1) Shorten the length of the highlighted effect",
"   2) Lengthen the video after it",
0};


static far char *Err_FXtrailingVideo[]={
 Problem_Discovered,
//"   Previous video ends before effect finishes",
"   Effect needs more trailing video from previous video crouton",
 ErrorDetails,
" ",
 Possible_Solutions,
"   1) Shorten the length of the highlighted effect",
"   2) Drag previous video's out point to the left to",
"      provide enough excess video for effect to occur",
0};


static far char *Err_FXleadingVideo[]={
 Problem_Discovered,
"   Effect needs more leading video from following video crouton",
 ErrorDetails,
" ",
 Possible_Solutions,
"   1) Shorten the length of the highlighted effect",
"   2) Drag the next video's in point to the right to",
"      provide enough excess video for effect to occur",
0};


static far char *Err_EffectDuringKeying[]={
 Problem_Discovered,
"   An effect is not allowed while keying",
" ",
 Possible_Solution,
"   Remove the effect. You must complete the key",
"   before you can use an effect",
0};


/************************* Keyed/CG Errors *************************/

static far char *Err_KeyedAtStart[]={
 Problem_Discovered,
"   Sequence starts with a keyed crouton",
" ",
 Possible_Solution,
"   Move this crouton so that it occurs later in",
"   the sequence",
0};

static far char *Err_KeyedUnsorted[]={
 Problem_Discovered,
"   A keyed crouton is in the incorrect order",
" ",
 Possible_Solution,
"   Rearrange the sequence so that the keyed crouton",
"   is in the correct location",
0};


static far char *Err_KeyedDuringEffect[]={
 Problem_Discovered,
"   Keyed crouton starts before prior effect finishes",
" ",
 Possible_Solutions,
"   1) Shorten the duration of the effect",
"   2) Lengthen the video event before the keyed crouton",
"      so that the effect and the key do not overlap",
0};


static far char *Err_KeyedTooSoon[]={
 Problem_Discovered,
"   Keyed crouton starts too soon (before the previous",
"   video event has started)",
" ",
 Possible_Solutions,
"   1) Set a later Start Time",
"   2) Lengthen the video event before it",
0};


static far char *Err_KeyedStartBad[]={
 Problem_Discovered,
"   Keyed crouton Start Time is not usable",
" ",
 Possible_Solution,
"   Use an earlier start time",
0};


static far char *Err_KeyedOverlapsKey[]={
 Problem_Discovered,
"   Keyed crouton Start Time overlaps previous key",
" ",
 Possible_Solution,
"   Change the Start Time so this key starts after",
"   the previous key has finished",
0};


static far char *Err_KeyedAfterEffect[]={
 Problem_Discovered,
"   Keyed crouton immediately follows an effect",
" ",
 Possible_Solution,
"   Insert a video event between the effect and the",
"   keyed crouton",
0};


/************************* Content Location Errors *************************/

static far char *Err_FrameOnFlyDrv[]={
 Problem_Discovered,
"   Can't sequence Framestores from a Flyer device",
" ",
 Possible_Solution,
"   Please copy the Framestore to a non-Flyer drive.",
"   Then use this new Framestore in this project.",
0};


static far char *Err_EffectsOnFlyDrv[]={
 Problem_Discovered,
"   Can't sequence Effects from a Flyer device",
" ",
 Possible_Solution,
"   Please copy the Effect to a non-Flyer drive.",
"   Then use this new Effect in this project.",
0};


static far char *Err_NonFlyerVideo[]={
 Problem_Discovered,
"   Can't sequence Clips from a non-Flyer Video device",
" ",
 Possible_Solution,
"   Please copy the Video Clip to a Flyer Video drive.",
"   Then use this new Clip in this project.",
0};


static far char *Err_NonFlyerAudio[]={
 Problem_Discovered,
"   Can't sequence Clips from a non-Flyer device",
" ",
 Possible_Solution,
"   Please copy the Audio Clip to a Flyer drive.",
"   Then use this new Clip in this project.",
0};


static far char *Err_FlyerClipMissing[]={
 Problem_Discovered,
"   Flyer clip not found",
" ",
 Possible_Solutions,
"   1) Restore the missing clip to its original location",
"   2) Replace or delete this crouton from the project",
0};


/************************* Video Errors *************************/

static far char *Err_NeedsPrevVideo[]={
 Problem_Discovered,
"   There are no previous video events",
" ",
 Possible_Solution,
"   Put some type of video event before this crouton",
0};


static far char *Err_VideoPreroll[]={
 Problem_Discovered,
"   Insufficient preroll time to start video event",
" ",
 Possible_Solution,
"   Lengthen the previous video event", 
0};


static far char *Err_VideoNeedsFlyer[]={
 Problem_Discovered,
"   Playback of video clips requires Flyer hardware",
" ",
 Possible_Solutions,
"   1) Check that the Flyer card is installed properly",
"   2) Buy a Flyer",
0};


static far char *Err_OutOfOrder[]={
 Problem_Discovered,
"   Video croutons out of order",
"   (Video starts after following video)",
" ",
 Possible_Solutions,
"   1) Adjust locked program time(s)",
"   2) Unlock their program times",
"   3) Swap their locations in the project",
0};


/************************* Audio Errors *************************/

static far char *Err_AudioNeedsFlyer[]={
 Problem_Discovered,
"   Playback of audio clips requires Flyer hardware",
" ",
 Possible_Solutions,
"   1) Check that the Flyer card is installed properly",
"   2) Buy a Flyer",
0};


static far char *Err_AudioNeedsVideo[]={
 Problem_Discovered,
"   This audio needs previous video to lock to",
" ",
 Possible_Solution,
"   1) Insert video before this audio crouton",
"   2) Set \"Lock to\" option to \"Prog Time\"",
0};


static far char *Err_OlayNeedsVideo[]={
 Problem_Discovered,
"   This crouton needs previous video to lock to",
" ",
 Possible_Solution,
"   Insert video before this crouton",
0};



/************************* Key Errors *************************/

static far char *Err_KeyAtStart[]={
 Problem_Discovered,
"   Sequence starts with a keying event",
" ",
 Possible_Solutions,
"   1) Insert a video event in front of this crouton",
"   2) Remove the crouton",
"   3) Move it after a video event",
0};


static far char *Err_KeyAfterEffect[]={
 Problem_Discovered,
"   A keying event is immediately after an effect",
" ",
 Possible_Solution,
"   Rearrange the position of this event so that it",
"   does not immediately follow an effect crouton",
0};


/************************* ARexx Errors *************************/

static far char *Err_ARexxAtStart[]={
 Problem_Discovered,
"   Sequence starts with an ARexx event",
" ",
 Possible_Solutions,
"   1) Insert a video event in front of this crouton",
"   2) Remove the crouton",
"   3) Move it after a video event",
0};


static far char *Err_ARexxAfterEffect[]={
 Problem_Discovered,
"   An ARexx event is immediately after an effect",
" ",
 Possible_Solution,
"   Rearrange the position of this event so that it",
"   does not lie right after an effect crouton",
0};


/************************* ChromaFX Errors *************************/

static far char *Err_CrFXAtStart[]={
 Problem_Discovered,
"   Sequence starts with a ChromaFX event",
" ",
 Possible_Solutions,
"   1) Insert a video event in front of this crouton",
"   2) Remove the crouton",
"   3) Move it after a video event",
0};


static far char *Err_CrFXAfterEffect[]={
 Problem_Discovered,
"   A ChromaFX event is immediately after an effect",
" ",
 Possible_Solution,
"   Rearrange the position of this event so that it",
"   does not lie right after an effect crouton",
0};



/************************* Timing Errors *************************/

static far char *Err_EventLate[]={
 Problem_Discovered,
"   Event failed to occur at the requested time",
" ",
 Possible_Solution,
"   Allow more time for data loading, or preroll.",
"   To do this, increase the time between this event",
"   and the previous events.  You may also need to",
"   increase the length of the previous video event.",
0};


/************************* Obsolete Errors *************************/

//static far char *Err_AudioAtStart[]={
// Problem_Discovered,
//"   Sequence starts with an audio clip",
//" ",
// Possible_Solutions,
//"   1) Insert a video event in front of the highlighted",
//"      audio clip",
//"   2) Remove the audio clip",
//"   3) Move it after a video event",
//0};


//static far char *Err_AudioAfterEffect[]={
// Problem_Discovered,
//"   An audio clip is immediately after an effect",
//" ",
// Possible_Solution,
//"   Rearrange the position of this clip so that it",
//"   does not lie right after an effect crouton",
//0};


//static far char *Err_AudioUnsorted[]={
// Problem_Discovered,
//"   An audio clip is in an invalid position",
//" ",
// Possible_Solution,
//"   Position the highlighted audio clip earlier",
//"   in the project sequence",
//0};


//static far char *Err_ClipMissing1[]={
// Problem_Discovered,
//"   Cannot copy A-B roll",
//" ",
// Possible_Solution,
//"   Clip is missing or has been changed",
////"    There is not enough room on the Flyer drive(s) to",
////"    perform A-B Roll. Please archive and/or remove",
////"    unused or unwanted footage to allow for playback.",
//0};


//static far char *Err_CantMoveAudio[]={
// Problem_Discovered,
//"   Unable to move this audio clip to an Audio Drive",
//" ",
// Possible_Solution,
//"   Clip is missing or has been changed",
////"    Connect an additonal audio drive to the Flyer,",
////"    or free up more space on an existing audio drive.",
//0};


//static far char *Err_CantMakeCut[]={
// Problem_Discovered,
//"   Unable to do this video Cut",
//" ",
// Possible_Solution,
//"   Clip is missing or has been changed",
////"    You need to free up some space one of your other",
////"    video drives.",
//0};


//static far char *Err_AudioLeadsVideo[]={
// Problem_Discovered,
//"   Audio can not start before any video events",
//" ",
// Possible_Solutions,
//"   1) Eliminate the leading audio on this video clip",
//"   2) Insert another video source before this one",
//0};


//static far char *Err_LeadAudio[]={
// Problem_Discovered,
//"   Can't put leading audio onto an audio drive",
//" ",
// Possible_Solution,
//"   Clip is missing or has been changed",
////"    Connect an additonal audio drive to the Flyer,",
////"    or free up more space on an existing audio drive.",
//0};


//static far char *Err_TrailAudio[]={
// Problem_Discovered,
//"   Can't put trailing audio onto an audio drive",
//" ",
// Possible_Solution,
//"   Clip is missing or has been changed",
////"    Connect an additonal audio drive to the Flyer,",
////"    or free up more space on an existing audio drive.",
//0};


//static far char *Err_ShortVideo[]={
// Problem_Discovered,
//"   This video clip is too short to sequence",
//" ",
// Possible_Solution,
//"   Adjust the clip's in or out points so its length",
//"   is at least 10 frames long",
//0};


//static far char *Err_ShortAudio[]={
// Problem_Discovered,
//"   This audio clip is too short to sequence",
//" ",
// Possible_Solution,
//"   Adjust the clip's in or out points so its length",
//"   is at least 6 frames long",
//0};


static far char *Err_ABrollFull[]={
 Problem_Discovered,
"   Unable to play sequence",
" ",
 Possible_Solution,
"   There is not enough room on the Flyer drive(s) to",
"   perform A-B Roll or to sequence Audio.",
"   Please archive and/or remove unused or unwanted",
"   footage to allow for playback.",
0};




static far char *Err_NoAudioDrive[]={
 Problem_Discovered,
"   No audio drive found",
" ",
 Possible_Solution,
"   An audio hard drive is needed in order to play",
"   audio clips and split audio tracks correctly.",
"   Add an audio drive onto the Flyer or remove the",
"   audio croutons or split audio.",
0};


/************************* System Errors *************************/

static far char *SysErr_CantCreateBlack[]={
"   Error creating black video fill",
0};



// Please include the name of the error message here.
far char **ErrMsgs[] = {
	Err_Internal,
	Err_InternalFlyer,
	Err_OutOfMemory,
	Err_OutOfFlyerMemory,
//	Err_EffectAtStart,
//	Err_EffectAtEnd,
	Err_EffectAfterEffect,
	Err_EffectStartsEarly,
	Err_EffectNearEffect,
	Err_EffectEndsLate,
	Err_FXtrailingVideo,
	Err_FXleadingVideo,
	Err_EffectDuringKeying,
	Err_KeyedAtStart,
	Err_KeyedUnsorted,
	Err_KeyedDuringEffect,
	Err_KeyedTooSoon,
	Err_KeyedStartBad,
	Err_KeyedOverlapsKey,
	Err_KeyedAfterEffect,
	Err_FrameOnFlyDrv,
	Err_EffectsOnFlyDrv,
	Err_NonFlyerVideo,
	Err_NonFlyerAudio,
	Err_NeedsPrevVideo,
	Err_VideoPreroll,
	Err_VideoNeedsFlyer,
	Err_AudioNeedsFlyer,
	Err_KeyAtStart,
	Err_KeyAfterEffect,
	Err_ARexxAtStart,
	Err_ARexxAfterEffect,
	Err_CrFXAtStart,
	Err_CrFXAfterEffect,
	Err_EventLate,
	Err_AudioNeedsVideo,
	Err_OlayNeedsVideo,
	Err_ABrollFull,
	Err_NoAudioDrive,
	Err_FlyerClipMissing,
	Err_OutOfOrder,

	SysErr_CantCreateBlack,

//	Err_AudioAtStart,
//	Err_AudioAfterEffect,
//	Err_AudioUnsorted,
//	Err_ClipMissing1,
//	Err_CantMoveAudio,
//	Err_CantMakeCut,
//	Err_AudioLeadsVideo,
//	Err_LeadAudio,
//	Err_TrailAudio,
//	Err_ShortVideo,
//	Err_ShortAudio,

	0
};
