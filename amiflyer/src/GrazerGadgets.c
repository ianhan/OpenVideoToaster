/********************************************************************
* $grazergadgets.c - EditWindow for looking at AmigaDOS hierarchy$
* $Id: GrazerGadgets.c,v 2.26 1995/10/09 16:38:40 Flick Exp $
* $Log: GrazerGadgets.c,v $
*Revision 2.26  1995/10/09  16:38:40  Flick
*Finds popup.h in new home
*
*Revision 2.25  1995/08/09  17:53:31  Flick
*Had to add arg for new NiceCopy()
*
*Revision 2.24  1995/07/27  18:13:33  Flick
*Added "from drive:?" wording to GrazerDelete warning (and cleaned up code)
*Fixed stuck-hilite in GrazerNewFolder
*
*Revision 2.23  1995/07/13  16:57:23  Flick
*Made text more severe for delete files requester
*
*Revision 2.22  1995/06/01  11:38:00  pfrench
*Duplicate now will engage fast flyer copy on flyer drives
*
*Revision 2.21  1994/12/30  21:05:33  pfrench
*Now correctly redraws new folders in files/files mode
*
*Revision 2.20  1994/12/19  22:38:25  pfrench
*Modified for now shared-code proof.library.
*
*Revision 2.19  1994/11/11  11:54:33  pfrench
*Got Select All working correctly
*
*Revision 2.18  1994/09/27  16:23:17  pfrench
*Removed all calls to FreeDirCache as it is being
*handled automatically now.
*
*Revision 2.17  1994/09/20  22:49:37  pfrench
*Modified to work with dircache (Editwindow has ptr to list now)
*
*Revision 2.16  1994/08/30  10:41:05  Kell
*Changed SendSwitcherReply calls to work with new ESParams structures.
*
*Revision 2.15  1994/08/11  16:55:03  pfrench
*Disabled (temporarily, at least). Projects saving from
*within the grazer's path string gadget.
*
*Revision 2.14  1994/07/31  14:43:36  pfrench
*HandlePath() now supports creating files with the grazer.
*
*Revision 2.13  1994/06/07  10:17:42  CACHELIN4000
**** empty log message ***
*
*Revision 2.12  94/03/19  00:05:00  CACHELIN4000
**** empty log message ***
*
*Revision 2.11  94/03/17  09:53:31  Kell
**** empty log message ***
*
*Revision 2.10  94/03/16  18:13:16  CACHELIN4000
**** empty log message ***
*
*Revision 2.9  94/03/16  17:30:14  CACHELIN4000
*Fix Project Saving ??
*
*Revision 2.8  94/03/15  16:12:51  Kell
**** empty log message ***
*
*Revision 2.7  94/03/14  21:57:12  CACHELIN4000
**** empty log message ***
*
*Revision 2.6  94/03/14  00:30:52  CACHELIN4000
**** empty log message ***
*
*Revision 2.5  94/03/13  07:51:39  Kell
**** empty log message ***
*
*Revision 2.4  94/03/11  09:32:18  Kell
**** empty log message ***
*
*Revision 2.3  94/03/02  21:06:04  CACHELIN4000
**** empty log message ***
*
*Revision 2.2  94/02/23  14:52:36  Kell
**** empty log message ***
*
*Revision 2.1  94/02/19  09:34:21  Kell
**** empty log message ***
*
*Revision 2.0  94/02/17  16:24:15  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  15:57:20  Kell
*FirstCheckIn
*
*Revision 2.0  94/02/17  14:44:33  Kell
*FirstCheckIn
*
*
* Copyright (c)1992 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	12-17-92	Steve H		Convert to use SmartStrings
*	10-12-93	Steve H		Last Update
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>
#include <crouton_all.h>

#include <editwindow.h>
#include <grazer.h>
#include <gadgets.h>
#include <filelist.h>
#include <doshelp.h>
#include <request.h>
#include <popup.h>
#include <editswit.h>

#ifndef PROOF_LIB_H
#include <proof_lib.h>
#endif

#include <croutongrid.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/diskfont.h>

#ifndef PROTO_PASS
#include <grazer.p>
#include <grazergadgets.p>
#include <grid.p>
#include <drag.p>
#include <doshelp.p>
#include <graphichelp.p>
#include <gadgethelp.p>
#include <editwindow.p>
#include <project.p>
#include <dircache.p>
#include <ToastSupport.p>
#endif
#ifdef PROTO_PASS
VOID DrawBG();
#endif

//#define SERDEBUG	1
#include <serialdebug.h>

#define MAX_FILE 30
char TempCh[80],TempC2[80];

extern struct Library *ProofBase;
extern struct st_PopupRender PopUp;
extern struct Gadget Gadget1;
extern WORD RootLeft,RootTop;
extern UBYTE *ProjectName;
extern struct EditWindow *EditTop;
extern LONG GrazerCopyMode;

extern struct ESParams2 ESparams2;

VOID DisplayWaitSprite(VOID);
VOID DisplayNormalSprite(VOID);

/****** GrazerGadgets/GrazerParent **********************************
*
*   NAME
*	GrazerParent
*
*   SYNOPSIS
*	struct EditWindow *GrazerParent(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
struct EditWindow *GrazerParent(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct SmartString *Path;

	Path = ((struct Grazer *)Edit->Special)->Path;
	if (!FindParent(Path,0)) EraseSmartString(Path);
	DoAllNewDir(Edit);
	return(Edit);
}

/****** GrazerGadgets/GrazerRoot **********************************
*
*   NAME
*	GrazerRoot
*
*   SYNOPSIS
*	struct EditWindow *GrazerRoot(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
#define NUM_TYPE 3
char Root1[] = "Volumes",Root2[] = "Devices",Root3[] = "Assigns",
	*RootNames[] = { Root1,Root2,Root3 };
// #define NUM_TYPE 2
// char Root1[] = "Volumes",Root2[] = "Assigns",
//	*RootNames[] = { Root1,Root2 };

// AAR -- frzl
char *NameFcn2(void *frzl, int Entries)
{
	if (Entries < 0) Entries = 0;
	else if (Entries > (NUM_TYPE-1)) Entries = NUM_TYPE-1;
	return(RootNames[Entries]);
}

//*******************************************************************
// update gadget to reflect new RootMode
VOID RedrawRootMode(struct EditWindow *Edit)
{
	struct Gadget *Gadget;
	WORD Mode;

	Mode = ((struct Grazer *)Edit->Special)->RootMode;
	if (!(Gadget = FindGadget(Edit->Gadgets,ID_ROOT_DEV)))
		if (!(Gadget = FindGadget(Edit->Gadgets,ID_ROOT_VOL)))
			Gadget = FindGadget(Edit->Gadgets,ID_ROOT_ASS);

	if (Gadget && ((Gadget->GadgetID-ID_ROOT_VOL) == Mode)) return;
	if (Gadget) {
		RemoveGadget(Edit->Window,Gadget);
		FreeGadget(Gadget);
	}
	Gadget = FindGadget(&Gadget1,Mode+ID_ROOT_VOL);
	if (Gadget = AllocOneGadget(Gadget)) {
		Gadget->LeftEdge = RootLeft;
		Gadget->TopEdge = RootTop;
		if (Edit->Window) {
			AddGadget(Edit->Window,Gadget,(UWORD)~0);
			RefreshGList(Gadget,Edit->Window,NULL,1);
		} else {
			Gadget->NextGadget = Edit->Gadgets->NextGadget;
			Edit->Gadgets->NextGadget = Gadget;
		}
	}
}

//*********************************************************************
struct EditWindow *GrazerRoot(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct SmartString *Path;

	Path = ((struct Grazer *)Edit->Special)->Path;
	EraseSmartString(Path);
	DoAllNewDir(Edit);
	return(Edit);
}

//*********************************************************************
struct EditWindow *GrazerChooseRoot(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	PopUpID ID;
	struct Gadget *Gadget;
	WORD A,X,Y;
	struct Grazer *Grazer;
	ULONG L;

	Grazer = (struct Grazer *)Edit->Special;
	PUCDefaultRender(&PopUp);
	PopUp.drawBG = (DrawBGFunc *)DrawBG;
	Gadget = FindGadget(Edit->Gadgets,ID_CHOOSE_ROOT);
	X = Gadget->LeftEdge + (Gadget->Width >> 1);
	Y = Gadget->TopEdge + (Gadget->Height >> 1);
	ID = PUCCreate((NameFunc *)NameFcn2,NULL,&PopUp);
	PUCSetNumItems(ID,NUM_TYPE);
	PUCSetCurItem(ID,Grazer->RootMode);

	Edit->Window->Flags |= WFLG_REPORTMOUSE;
	A = PUCActivate(ID,Edit->Window,X,Y,IntuiMsg->MouseX,IntuiMsg->MouseY);
	Edit->Window->Flags &= ~WFLG_REPORTMOUSE;
	PUCDestroy(ID);

	if (A >= 0) {
		if (A != Grazer->RootMode) {
			Grazer->RootMode = A;
			L = Grazer->ValidAttributes;
			L = L & (~(VALID_DEVICES|VALID_VOLUMES|VALID_ASSIGNS));
			switch(A) {
			case 0:
				L |= VALID_VOLUMES;
			break;
			case 1:
				L |= VALID_DEVICES;
			break;
			case 2:
				L |= VALID_ASSIGNS;
			break;
			}
			Grazer->ValidAttributes = L;
			RedrawRootMode(Edit);
			GrazerRoot(Edit,IntuiMsg); // show new root Mode
		}
	}
	return(Edit);
}

//*********************************************************************
struct SmartNode *__regargs SearchSmartNodeName(
	struct SmartNode *Node,
	char *Search)
{
	struct SmartNode *Next;

	if (Node) {
	while (Next = (struct SmartNode *)Node->MinNode.mln_Succ) {
		if (stricmp(Search,GetCString(Node->Name)) == 0) return(Node);
		Node = Next;
	}
	}
	return(Node);
}

/****** GrazerGadgets/GrazerNewFolder *******************************
*
*   NAME
*	GrazerNewFolder
*
*   SYNOPSIS
*	struct EditWindow *GrazerNewFolder(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*	Creates a new folder in the current folder
*
*********************************************************************
*/
//*********************************************************************
// creates "FirstPart XX" where XX is first unused number in Path (dir)
// returns NULL if can't allocate SmartString or Lock() FileName
struct SmartString *CreateFileName(struct SmartString *Path,char *FirstPart)
{
	struct SmartString *New=NULL;
	UWORD A = 1;
	char Num[12];
	BPTR OldDir,NewDir,L;

	if (Path && FirstPart && (NewDir = Lock(GetCString(Path),ACCESS_READ))) {
		OldDir = CurrentDir(NewDir);
		while (A < 1000) {
		if ((New = AllocSmartString(FirstPart,NULL)) &&
			(stcu_d(Num,A)) &&
			(AppendCSmartString(Num,New))) {
			if (L = Lock(GetCString(New),ACCESS_READ)) {
				UnLock(L);
				A++;
			} else { // success
				goto Exit;
			}
		}
		if (New) {
			FreeSmartString(New);
			New = NULL;
		}
		}
Exit:
		CurrentDir(OldDir);
		UnLock(NewDir);
	}
	return(New);
}

//*********************************************************************
// returns fully qualified pathname or NULL
struct SmartString *PromptFileName(struct SmartString *Path,
	char *FirstPart,char *FirstPrompt,struct Window *Window)
{
	struct SmartString *File,*Full=NULL;
	char *MPtr[1],*CPath,*CFile;

	CPath = GetCString(Path);
	if ((!CPath) || (!CPath[0])) return(NULL); // this should never happen
	if (File = CreateFileName(Path,FirstPart)) {
		MPtr[0] = FirstPrompt;
		CFile = &TempCh[0];
		strcpy(CFile,GetCString(File));
		if (SimpleRequest(Window,MPtr,1,
			REQ_STRING|REQ_CENTER|REQ_H_CENTER|REQ_OK_CANCEL,CFile)) {

// build full thing
			if ((!(Full = DuplicateSmartString(Path))) ||
				(!(AppendCToPath(CFile,Full)))) {
				ContinueRequest(Window,IoErrToText(ERROR_NO_FREE_STORE));
				if (Full) {
					FreeSmartString(Full);
					Full = NULL;
				}
			}
		}
		FreeSmartString(File);
	}
	return(Full);
}

//*********************************************************************
struct EditWindow *GrazerNewFolder(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	BPTR NewLock = NULL;
	char *MPtr[2];
	struct SmartString *Path,*NewDir = NULL;
	LONG Err = NULL;
//	struct EditNode *Node;

	Path = ((struct Grazer *)Edit->Special)->Path;
	if (NewDir = PromptFileName(Path,"Folder ","Enter name of new folder.",Edit->Window))
	{
		NewLock = CreateDir(GetCString(NewDir));
		if (NewLock)
		{
			UnLock(NewLock);
			DeselectOtherEdit(Edit);
			DoAllNewDir(Edit);
			CheckOtherSame(Edit);

//Took this out, as the highlite would get stuck until we reentered the dir
//			Node = (struct EditNode *)	SearchSmartNodeName((struct SmartNode *)
//				Edit->Special->pEditList->lh_Head,&TempCh[0]);
//			if (Node) ChangeStatusNode(Edit,Node,EN_SELECTED);
		}
		else
			Err = IoErr();
		FreeSmartString(NewDir);
	}
	if (Err)
	{
		MPtr[0] = "Unable to create folder.";
		MPtr[1] = IoErrToText(IoErr());
		SimpleRequest(Edit->Window,MPtr,2,
			REQ_CENTER|REQ_H_CENTER,NULL);
	}
	return(Edit);
}

//*********************************************************************
struct EditWindow *HandleNewProject(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	char *MPtr[2];
	struct SmartString *Path,*NewDir = NULL;
	struct EditNode *Node;
	LONG Err=NULL;

	Path = ((struct Grazer *)Edit->Special)->Path;
	if (NewDir = PromptFileName(Path,"Project ","Enter name of new project.",
		Edit->Window)) {
		strcpy(ProjectName,GetCString(NewDir));
		DUMPSTR("Before HandleNewProject() sends ES_NewProject with ");
		DUMPMSG(ProjectName);
		ESparams2.Data1=0;
		ESparams2.Data2=(LONG)ProjectName;
		Err=SendSwitcherReply(ES_NewProject,&ESparams2); // proj. ##, name
		DUMPMSG("  After HandleNewProject() sent ES_NewProject");
		FreeSmartString(NewDir);
		if (EditTop->Node.Type == EW_PROJECT) InitSetupProject(EditTop);

		DoAllNewDir(Edit);
		CheckOtherSame(Edit);
		DeselectOtherEdit(Edit);
		Node = (struct EditNode *)
			SearchSmartNodeName((struct SmartNode *)
			Edit->Special->pEditList->lh_Head,&TempCh[0]);
		if (Node) ChangeStatusNode(Edit,Node,EN_SELECTED);
	}
	if (Err) {
		MPtr[0] = "Unable to create project.";
		MPtr[1] = IoErrToText(Err);
		SimpleRequest(Edit->Window,MPtr,2,
			REQ_CENTER|REQ_H_CENTER,NULL);
	}
	return(Edit);
}

/****** GrazerGadgets/GrazerDelete **********************************
*
*   NAME
*	GrazerDelete
*
*   SYNOPSIS
*	struct EditWindow *GrazerDelete(struct EditWindow *Edit)
*
*   FUNCTION
*	Deletes any selected files or directories
*
*********************************************************************
*/
BOOL GrazerDelete(struct EditWindow *Edit)
{
	struct SmartString *Path,*Item=NULL;
	struct GrazerNode *Node,*Next;
	WORD Dirs=0,Files=0;
	struct SmartString *FirstDir=NULL,*FirstFile=NULL;
	char *MPtr[3],*Ch;
	BOOL NormSprite = TRUE;

	Path = ((struct Grazer *)Edit->Special)->Path;

// count # of dir,files to be deleted
	Node = (struct GrazerNode *)Edit->Special->pEditList->lh_Head;
	while (Next = (struct GrazerNode *)Node->EditNode.Node.MinNode.mln_Succ) {
		if (Node->EditNode.Status == EN_SELECTED) {
			switch (Node->DOSClass) {
			case EN_DIRECTORY:
				if (!Dirs) FirstDir = Node->EditNode.Node.Name;
				Dirs++;
				break;
			case EN_FILE:
				if (!Files) FirstFile = Node->EditNode.Node.Name;
				Files++;
				break;
			default:
				MPtr[0] = "Unable to delete";
				MPtr[1] = GetCString(Node->EditNode.Node.Name);
				MPtr[2] = "Only files and folders can be deleted.";
				SimpleRequest(Edit->Window,MPtr,3,
					REQ_CENTER|REQ_H_CENTER,NULL);
				goto Exit;
			}
		}
		Node = Next;
	}

// if anything to delete, warn user

// Are you sure you want to delete
// 00 files, 00 folders (and their contents)?
	if (Dirs || Files)
	{
		MPtr[0] = "WARNING: Are you sure you want to delete";
		Ch = TempCh;

// if just one thing, print its name
		if (((Dirs==1) && (!Files)) || ((Files==1) && (!Dirs)))
		{
			if (Files)
				strcpy(Ch,GetCString(FirstFile));
			else
			{
				strcpy(Ch,GetCString(FirstDir));
				strcat(Ch," (and its contents)");
			}
		} else
		{
// else just print number/type of items
			if (Files)
			{
				stci_d(Ch,Files);
				if (Files > 1)
					strcat(Ch," files");
				else
					strcat(Ch," file");
				Ch = TempCh + strlen(TempCh);
			}
			if (Dirs)
			{
				if (Files)
				{
					strcat(Ch,", ");
					Ch += 2;
				}
				stci_d(Ch,Dirs);
				if (Dirs > 1)
					strcat(Ch," folders (and their contents)");
				else
					strcat(Ch," folder (and its contents)");
			}
		}
//		strcat(Ch,"?");
		MPtr[1] = TempCh;

		Ch = TempC2;
		strcpy(Ch,"from ");
		strcat(Ch,GetCString(Path));
		strcat(Ch,"?");
		MPtr[2] = TempC2;

		if (SimpleRequest(Edit->Window,MPtr,3,REQ_OK_CANCEL|REQ_CENTER|REQ_H_CENTER,NULL))
		{
			if (Dirs || (Files > 10))
			{
				NormSprite = FALSE;
				DisplayWaitSprite();
			}

// go through list until all items accounted for
			Node = (struct GrazerNode *)Edit->Special->pEditList->lh_Head;
			while (Next = (struct GrazerNode *)Node->EditNode.Node.MinNode.mln_Succ)
			{
				if (Node->EditNode.Status == EN_SELECTED)
				{
					if ((Item=DuplicateSmartString(Path))
					&&	(AppendToPath(Node->EditNode.Node.Name,Item)))
					{
// if directory, try to delete all its contents first
						if (Node->DOSClass == EN_DIRECTORY)
						{
							if (!DeleteDirectory(Item)) goto DErr;
						}

// now delete file/directory
						if ((Node->DOSClass == EN_DIRECTORY)
						||	(Node->DOSClass == EN_FILE))
						{
							if (!CrDeleteFile(GetCString(Item)))
							{
DErr:
								if (!NormSprite)
								{
									NormSprite = TRUE;
									DisplayNormalSprite();
								}
								strcpy(TempCh,"Unable to delete ");
								strcat(TempCh,GetCString(Item));
								MPtr[0] = TempCh;
								MPtr[1] = IoErrToText(IoErr());
								SimpleRequest(Edit->Window,MPtr,2,
									REQ_CENTER|REQ_H_CENTER,NULL);
								break;
							}
						}
					}
					if (Item)
					{
						FreeSmartString(Item);
						Item = NULL;
					}
				}
				Node = Next;
			}

			DoAllNewDir(Edit);
			CheckOtherSame(Edit);

			if (Item)	 // if err condition
			{
				FreeSmartString(Item);
				Item = NULL;
			}
		}
	}

Exit:
	if (!NormSprite) {
		NormSprite = TRUE;
		DisplayNormalSprite();
	}
	return(FALSE);

}

/****** GrazerGadgets/GrazerDuplicate **********************************
*
*   NAME
*	GrazerDuplicate
*
*   SYNOPSIS
*	struct EditWindow *GrazerDuplicate(struct EditWindow *Edit)
*
*   FUNCTION
*	Duplicates any selected files or directories
*
*********************************************************************
*/
BOOL GrazerDuplicate(struct EditWindow *Edit)
{
	struct GrazerNode *Node,*Next;
	char *MPtr[3],*CSrc,*DC;
	struct SmartString *Src=NULL,*Dest=NULL,*SrcName,*Path;
	LONG Err,Count=0;
	BOOL Update = FALSE,Started = FALSE;

	Path = ((struct Grazer *)Edit->Special)->Path;

	{
		BPTR	lock;

		if ( lock = Lock( GetCString(Path),ACCESS_READ) )
		{
			struct InfoData	*id;

			if ( id = AllocMem( sizeof(struct InfoData),MEMF_PUBLIC|MEMF_CLEAR) )
			{
				if ( Info(lock,id) )
				{
					if ( !(strncmp( (char *)&id->id_DiskType,"FLY",3)) )
					{
						/* Duplicate on flyer file system drive */
						GrazerCopyMode = 2;
					}
				}

				FreeMem(id,sizeof(*id));
			}

			UnLock(lock);
		}
	}

// count # of items
	Node = (struct GrazerNode *)Edit->Special->pEditList->lh_Head;
	while (Next = (struct GrazerNode *)Node->EditNode.Node.MinNode.mln_Succ) {
		if (Node->EditNode.Status == EN_SELECTED) Count++;
		Node = Next;
	}

// for all selected items, allow user to enter new name
	Node = (struct GrazerNode *)Edit->Special->pEditList->lh_Head;
	while (Next = (struct GrazerNode *)Node->EditNode.Node.MinNode.mln_Succ) {
		if (Node->EditNode.Status == EN_SELECTED) {
			SrcName = Node->EditNode.Node.Name;
			CSrc = GetCString(SrcName);

// cannot duplicate devices or folders
		if ((Node->DOSClass != EN_FILE) && (Node->DOSClass != EN_DIRECTORY)) {
			MPtr[0] = "Unable to duplicate";
			MPtr[1] = CSrc;
			MPtr[2] = "Only files and folders can be duplicated.";
			SimpleRequest(Edit->Window,MPtr,3,
				REQ_CENTER|REQ_H_CENTER,NULL);
			break;

		} else {
			MPtr[0] = TempCh;
			strcpy(TempCh,"Enter name for copy of ");
			strcat(TempCh,CSrc);
			strcpy(TempC2,CSrc);
			if (!stcpm(TempC2,"Copy",&DC)) strcat(TempC2,"Copy");
			if (SimpleRequest(Edit->Window,MPtr,1,
				REQ_STRING|REQ_CENTER|REQ_H_CENTER|REQ_OK_CANCEL,TempC2)) {

			if ((Src=DuplicateSmartString(Path)) &&
				(AppendToPath(SrcName,Src)) &&
				(Dest=DuplicateSmartString(Path)) &&
				(AppendCToPath(TempC2,Dest))) {

				Update = TRUE;
				if (!Started) {
					Started = TRUE;
					if ((Count > 1) || (FileOrDirectory(Src)!=A_FILE)
						|| (FileSize(GetCString(Src))) > 50000)
						StartNiceCopy(Edit->Window,TRUE,TRUE);
					else
						StartNiceCopy(Edit->Window,FALSE,TRUE);
				}

				// Copy file and its .i/.info file
				if (Err = NiceCopy(GetCString(Src),GetCString(Dest),TempC2,TRUE))
				{
					if (Err < ERROR_USER_ABORT) {
					MPtr[0] = "Unable to create";
					MPtr[1] = GetCString(Dest);
					MPtr[2] = IoErrToText(Err);
					SimpleRequest(Edit->Window,MPtr,3,
						REQ_CENTER|REQ_H_CENTER,NULL);
					}
					break;
				}

			}
			if (Src) {
				FreeSmartString(Src);
				Src = NULL;
			}
			if (Dest) {
				FreeSmartString(Dest);
				Dest = NULL;
			}

// if ever cancel, exit (forget about any remaining selected items)
			} else break;
		}
		}
		Node = Next;
	}

	/* Clear copymode to default (just in case) */
	GrazerCopyMode = 0;

	if (Src) {
		FreeSmartString(Src);
		Src = NULL;
	}
	if (Dest) {
		FreeSmartString(Dest);
		Dest = NULL;
	}
	if (Update)
	{
		DoAllNewDir(Edit);
		CheckOtherSame(Edit);
	}
	if (Started) EndNiceCopy();
	return(FALSE);
}

/****** Grazer/HandleRename ************************************
*
*   NAME
*	HandleRename
*
*   SYNOPSIS
*	struct EditWindow *HandleRename(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*
*
*********************************************************************
*/
struct EditWindow *HandleRename(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct GrazerNode *Node,*Next;
	char *MPtr[3],*CSrc;
	struct SmartString *Src=NULL,*Dest=NULL,*SrcName,*Path;
	LONG Err,L;
	BOOL Update = FALSE,Label,Success;

	Path = ((struct Grazer *)Edit->Special)->Path;
// for all selected items, allow user to enter new name
	Node = (struct GrazerNode *)Edit->Special->pEditList->lh_Head;
	while (Next = (struct GrazerNode *)Node->EditNode.Node.MinNode.mln_Succ) {
		if (Node->EditNode.Status == EN_SELECTED) {
			SrcName = Node->EditNode.Node.Name;
			CSrc = GetCString(SrcName);

// cannot rename devices or folders
		if ((Node->DOSClass != EN_FILE) && (Node->DOSClass != EN_DIRECTORY) &&
			(Node->DOSClass != EN_VOLUME)) {
			MPtr[0] = "Unable to rename";
			MPtr[1] = CSrc;
			MPtr[2] = "Only files, folders and volumes can be renamed.";
			SimpleRequest(Edit->Window,MPtr,3,
				REQ_CENTER|REQ_H_CENTER,NULL);
			break;

		} else {
			Label = TRUE;
			if ((Node->DOSClass == EN_FILE) || (Node->DOSClass == EN_DIRECTORY))
				Label = FALSE;

			MPtr[0] = TempCh;
			strcpy(TempCh,"Enter new name for ");
			strcat(TempCh,CSrc);
			strcpy(TempC2,CSrc);
			if (SimpleRequest(Edit->Window,MPtr,1,
				REQ_STRING|REQ_CENTER|REQ_H_CENTER|REQ_OK_CANCEL,TempC2)) {

		// max AmigaDOS len
				if (strlen(TempC2) > MAX_FILE) TempC2[MAX_FILE] = 0;
		// do not include ":" in volume names
				L = strlen(TempC2);
				if (TempC2[L-1] == ':') TempC2[L-1] = 0;

			if ((Src=DuplicateSmartString(Path)) &&
				(AppendToPath(SrcName,Src)) &&
				(Dest=DuplicateSmartString(Path)) &&
				(AppendCToPath(TempC2,Dest))) {

				if (Label)
					Success = Relabel(GetCString(Src),GetCString(Dest));
				else
					Success = Rename(GetCString(Src),GetCString(Dest));
				if (!Success) {
					Err = IoErr();
					MPtr[0] = "Unable to rename";
					MPtr[1] = GetCString(Src);
					MPtr[2] = IoErrToText(Err);
					SimpleRequest(Edit->Window,MPtr,3,
						REQ_CENTER|REQ_H_CENTER,NULL);
				}
        else
        {
          Update = TRUE;
  				if (Label)
            if( AppendCSmartString(".i",Src) && AppendCSmartString(".i",Dest) )
            {
              Rename(GetCString(Src),GetCString(Dest));
              if( AppendCSmartString("nfo",Src) && AppendCSmartString("nfo",Dest) )
                Rename(GetCString(Src),GetCString(Dest));
            }
        }
			}
			if (Src) {
				FreeSmartString(Src);
				Src = NULL;
			}
			if (Dest) {
				FreeSmartString(Dest);
				Dest = NULL;
			}

// if ever cancel, exit (forget about any remaining selected items)
			} else break;
		}
		}
		Node = Next;
	}

	if (Src) {
		FreeSmartString(Src);
		Src = NULL;
	}
	if (Dest) {
		FreeSmartString(Dest);
		Dest = NULL;
	}
	if (Update) {
		DoAllNewDir(Edit);
		CheckOtherSame(Edit);
	}
	return(Edit);
}

/****** Grazer/HandlePath ************************************
*
*   NAME
*	HandlePath
*
*   SYNOPSIS
*	struct EditWindow *HandlePath(struct EditWindow *Edit,
*		struct IntuiMessage *IntuiMsg)
*
*   FUNCTION
*	Goes from SI->Buffer to Grazer->Path
*
*********************************************************************
*/
struct EditWindow *HandlePath(struct EditWindow *Edit,struct IntuiMessage *IntuiMsg)
{
	struct Gadget *Gadget;
	struct Grazer *Grazer;

	Gadget = FindGadget(Edit->Gadgets,ID_PATH);
	Grazer = (struct Grazer *)Edit->Special;
	EraseSmartString(Grazer->Path);
	AppendCSmartString(((struct StringInfo *)Gadget->SpecialInfo)->Buffer,
		Grazer->Path);
	DoAllNewDir(Edit);
	return(Edit);
}

/****** GrazerGadgets/GrazerAll **********************************
*
*   NAME
*	GrazerAll
*
*   SYNOPSIS
*	BOOL GrazerAll(struct EditWindow *Edit)
*
*   FUNCTION
*
*
*********************************************************************
*/
BOOL GrazerAll(struct EditWindow *Edit)
{
	if ( Edit->ew_cg )
	{
		ob_DoMethod( Edit->ew_cg,CRGRIDM_SelectCrouton,
			CROUTONNUM_ALL,GRIDSELECT_NORMAL,CROUTONSELECT_SELECTED);

		Edit->ew_OptRender = TRUE;
		Edit->RedrawSelect = TRUE;
		Edit->DisplayGrid = TRUE;
	}
	else
	{
		ChangeStatusList(Edit,EN_NOT_STATUS,EN_SELECTED);
	}
	return(TRUE);
}

// end of grazergadgets.c
