/********************************************************************
* NewBook.c
*
* Copyright 1993 NewTek, Inc.
* Confidental and Proprietary. All rights reserved.
*
*	3-20-93	Steve H		Created
*	9-8-93	Steve H		Last Update
* Mon Nov  8 17:46:19 1993
*********************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <stdio.h>
#include <math.h>
#include <string.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>

#include <book.h>
#include <toastfont.h>
#include <cgerror.h>
#include <NewSupport.h>
#include <commonrgb.h>
#include <newfunction.h>
#include <MovePage.h>
#include <tags.h>

#ifndef PROTO_PASS
#include "protos.h"
#else
#include "crlib:libinc/crouton_all.h"
#endif

#define ANY_HEIGHT 65535
#define CROUTONLIB	1

extern struct RenderData *RD;
extern char DefFileName[], FontsPath[], BrushPath[], FontMemMsg[],UnableLoadBrush[],
	FontOpenLib[], FontOpen2[],UnableLoadFont[],PreRenderMsg[],PageCmdsMsg[],
	PrepareNoticeMsg[],Prepare2Msg[],OutMemoryMsg[],Def2File[],OldFontPath[];

extern BOOL IDCMPSaved;
extern ULONG PSFontFlags;
extern char PSMess[];
extern ULONG  CRuDTop,CRuDBot,crudTAGSIZE,CRuDHEAD;    // in Book.a

// uses R->ByteStrip->Planes[0]
#define BUFF_SIZE 90000
#define LIN_SIZ 160
UBYTE LineBuf[LIN_SIZ];
VOID WaitButton(VOID);

/*
Book format on disk
-------------------
"ToasterBookFile4"
"FONT"
UWORD ID,StrLen,Height,
ULONG Flags
"BRSH"
UWORD ID,StrLen
"DRAW"
UWORD ID,StrLen,Height,struct Draw
"PAGE"
UWORD Number
UBYTE	Size?
	BYTE[Size] BkgName ... not yet
"LINE"
UWORD NumberText
	UWORD Ascii
	BYTE Kerning
	UBYTE Attr?
		struct Attributes
struct CGLine(from TotalHeight on)
"END!"
*/

#define BK_HEAD_SIZE 16
#define OLD_BOOK_VERSION '1'
#define BOOK_VERSION '3'
#define NEW_BOOK_VERSION '4'
#define TYPE_SIZE 4

// make sure valid with book.h!
#define PAGE_SIZE 12

char BookHead[] = "ToasterBookFile";

#define MAKE_ID(a,b,c,d) ((ULONG)(a)<<24L|(ULONG)(b)<<16L|(c)<<8|(d))
#define ID_FORM		  0x464F524D  // FORM MAKE_ID('F','O','R','M')
#define ID_BOOK		  0x424F4F4B  // BOOK MAKE_ID('B','O','O','K')
#define ID_CRuD		  0x43725544  // CrUD MAKE_ID('C','r','U','D')
#define ID_FONT		  0x464F4E54  // FONT MAKE_ID('F','O','N','T')
#define ID_BRUSH	  0x42525348  // BRSH MAKE_ID('B','R','S','H')
#define ID_PAGE		  0x50414745  // PAGE MAKE_ID('P','A','G','E')
#define ID_LINE		  0x4C494E45  // LINE MAKE_ID('L','I','N','E')
#define ID_DRAW		  0x44524157  // DRAW MAKE_ID('D','R','A','W')
#define ID_END		  0x454E4421  // END! MAKE_ID('E','N','D','!')
#define ID_TAGS		  0x54414753  // TAGS
#define ID_HEAD		  0x48454144  // HEAD
#define ID_PUSS		  0x50555353  // PUSS
#define KEYF	0x4B455946
#define FRAM	0x4652414D
#define SCRO	0x5343524F  // SCRO
#define CRAW	0x43524157  // CRAW
#define TAGS	0x54414753  // TAGS
#define TYPE	0x54595045  // TYPE
#define LIBS	0x4C494253  // LIBS

#define TAGID_Duration		TAG_Duration
#define TAGID_Speed		TAG_Speed
#define TAGID_Delay		TAG_Delay
#define TAGID_HoldFields		TAG_HoldFields
#define TAGID_FadeOutDuration		TAG_FadeOutDuration
#define TAGID_Page		TAG_Page
#define TAGID_PAGE		TAG_Page
#define OLDTAGID_PAGE	0x10000069
#define TAG_DONE	NULL
#define OLD_TRANSP_DROP 3
#define OLD_TRANSP_CAST 4
#define OLD_TRANSP_ALPHA 64

#define DEFAULT_FONTS 1
#define FONT_ZERO_HEIGHT 10
char DefFontName[DEFAULT_FONTS][40] = {
	"CommonThin.10"
//,	"SimpleFuture.36",
//	"SimpleThin.36"
};
char FailFontName[MAX_PATH];

// old seperator sizes
UWORD SepWidth[] = { 620,620,320,320 },
	  SepHeight[] = { 4,8,4,8 };

char Prompt[MAX_FILE+30] = "Select replacement for ",
	MsgFind[] = "Unable to load ",
	MsgFont[] = "font",
	MsgBrush[] = "brush",
	MsgReplace[] = "Would you like to replace it with another ",
	GenericMsg1[MAX_PATH+30],
	GenericMsg2[MAX_FILE+30];

#define PROMPT_APPEND 23



struct PageCrUD {
	ULONG	FORM;		// FORM
	ULONG	fSize;	// FORMSize
	ULONG	CrUD;		// CrUD
	ULONG	Type;		// TYPE
	ULONG	cSize;	// 8
	ULONG	CType;		// CRAW,SCRO,FRAM,FKEY
	ULONG	CTypeEnd;		// NULL
	ULONG	Tag_LIBS;		// LIBS
	ULONG	lSize;	// 0x18
	ULONG	lOff;		// 0xFFFFFCD0
	UWORD	lHuh;		// 0x0010
	UBYTE	lName[18]; // "effects.library"
	ULONG	Tag_TAGS;		// TAGS
	ULONG	tSize;	//  size + 4(for tags end)
	ULONG	DurTag; // TAG_Duration
	ULONG	Duration;
	ULONG	SpeedTag; // TAG_Speed
	ULONG	Speed;
//	ULONG	DelTag; // TAG_Delay
//	ULONG	Delay;
	ULONG	HoldTag; // TAG_HoldFields
	ULONG	Hold;
	ULONG	FadeTag; // TAG_FadeOutDuration
	ULONG	Fade;
	ULONG	PageTag; // TAG_Page
	ULONG	PageSize;	// 4
};

struct PageCrUD MyCrUD = { ID_FORM,0,ID_CRuD,TYPE,8,FRAM,0,
		LIBS,0x18,0xFFFFFCD0,0x0010,"effects.library",
		TAGS,8+8 /* +8 */ +8+8+8+4, // tags+end, add data size
		TAGID_Duration,180,
		TAGID_Speed,0,
//		TAGID_Delay,0,
		TAGID_HoldFields,0,
		TAGID_FadeOutDuration,0,
		TAGID_Page,0
		};


// Version number of last book when loaded from disk
// (used by EUC routines to convert text_Ascii to new word form)
UBYTE LastLoadVer;

//*******************************************************************
VOID __asm FreeBook(
	register __a0 struct CGBook *Book)
{
	WORD A;
	struct CGPage *Page;

	if (Book) {
		Page = &Book->Page[0];
		for (A=0; A < PAGES_PER_BOOK; A++) {
			FreeAllLines(Page);
			Page++;
		}
		FreeDataList(&Book->DataList);
		FreeMem(Book,sizeof(struct CGBook));
	}
}

// Position File to read at beginning of Book data
BOOL	JumpIntoCRuD(struct BufferLock *LB)
{
	ULONG		Buff[8]={0,0,0,0,0,0,0,0};

	BufferSeek( LB, 0, OFFSET_BEGINNING );
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,12)) return(FALSE);
	if(Buff[0]!=ID_FORM) return(FALSE);
	while(Buff[2]!=ID_CRuD)
	{
/* 		DumpHexiL("Chunk: ",Buff[0],"  { ");
		DumpStr((UBYTE *)Buff);
		DumpUDecL(" }  Size: ",Buff[1],"  ");
		DumpHexiL("Type: ",Buff[2],"   ");
		DumpMsg((UBYTE *)&(Buff[2]));
*/
		BufferSeek( LB, Buff[1]-4, OFFSET_CURRENT );		// Skip chunk
		if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,12)) return(FALSE);// Get Next
	}
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,8)) return(FALSE);
  while(Buff[0] != ID_TAGS)
	{
/*
		DumpHexiL("Tag: ",Buff[0],"  { ");
		DumpStr((UBYTE *)Buff);
		DumpUDecL(" }  Size: ",Buff[1],"   \\ ");
*/
		BufferSeek( LB, Buff[1], OFFSET_CURRENT );		// Skip chunk
		if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,8)) return(FALSE);// Get Next
	}
/*
	DumpHexiL("Found Tag: ",Buff[0],"  { ");
	DumpStr((UBYTE *)Buff);
	DumpUDecL(" }  Size: ",Buff[1],"   \\ ");
*/
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,8)) return(FALSE);// Get Next
	while((Buff[0] != TAGID_PAGE) && (Buff[0] != OLDTAGID_PAGE) )
	{
//		DumpHexiL("TAG: ",Buff[0]," ");
//		DumpUDecL(" Value: ",Buff[1],"   \\ ");
		if(!(Buff[0]&0x80000000)) // Table not tag
			BufferSeek( LB, Buff[1], OFFSET_CURRENT );		// Skip Table
		if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Buff,8)) return(FALSE);// Get Next
	}
//	DumpHexiL("Got TAG: ",Buff[0]," ");
//	DumpUDecL(" Value: ",Buff[1],"   \\ ");
	return(TRUE);
}


//#define JAMES_VERSION

//*******************************************************************
// Loads both new and old book formats
//
struct CGBook *__asm LoadNewBook(
	register __a0 char *FileName)
{
	struct CGBook *Book = NULL;
	ULONG Err = CG_ERROR_FIND_BOOK;
	struct RenderData *R;
	struct BufferLock *LB;
	UBYTE *Buff;
	UBYTE Version;
	ULONG Type,NumLines; //,Debug=0;
	UWORD ID,Size,Height,A = PAGES_PER_BOOK+1; // set invalid to start
	struct LineData *Data;
	struct CGLine *Line;
	struct CGPage *Page;
	BOOL HeadOK;

	R = RD;
	PSFontFlags=0;
	Buff = (UBYTE *)R->ByteStrip->Planes[0];
	if (!(LB = BufferOpen(FileName,MODE_OLDFILE,BUFF_SIZE,R->ByteStrip->Planes[1]))) goto Exit;
	if (!LB->File) goto ErrExit;
	Err = CG_ERROR_LOAD_BOOK;
	if (BufferRead(LB,Buff,BK_HEAD_SIZE) != CR_ERR_NONE) goto ErrExit;
  Type=*((ULONG *)Buff);
  if(Type==ID_FORM)
  {
		if(!JumpIntoCRuD(LB)) goto ErrExit;
  	if (CR_ERR_NONE != BufferRead(LB,Buff,BK_HEAD_SIZE)) goto ErrExit;
  }
	Version = Buff[BK_HEAD_SIZE-1];
	if ((Version != OLD_BOOK_VERSION) && (Version != BOOK_VERSION)
    && (Version != NEW_BOOK_VERSION))
		goto ErrExit;
	LastLoadVer = Version;
	Buff[BK_HEAD_SIZE-1] = 0; // terminate string before version
	if (!(StringCompare(Buff,BookHead))) goto ErrExit;
	if (!(Book = InitEmptyBook())) goto ErrExit;
	if (!InitRenderFonts(Book)) goto ErrExit;
//	if (!AddBox(Book)) goto ErrExit;

	do {
		if (CR_ERR_NONE != BufferRead(LB,Buff,TYPE_SIZE)) goto ErrExit;
		Type = *(ULONG *)Buff;
		HeadOK = FALSE;
		switch (Type) {

		case ID_FONT:
		case ID_DRAW:
		case ID_BRUSH:
			if (CR_ERR_NONE != BufferRead(LB,Buff,4)) {
				//Debug = 1;
				goto ErrExit;
			}
			ID = *(UWORD *)&Buff[0];
			Size = *(UWORD *)&Buff[2];

			if ((Type == ID_DRAW) || ( (Type == ID_FONT) &&
        ( (Version == BOOK_VERSION) || (Version == NEW_BOOK_VERSION) )) )
      {
				if (CR_ERR_NONE != BufferRead(LB,Buff,2))
        {
					//Debug = 2;
					goto ErrExit;
				}
				Height = *(UWORD *)&Buff[0];
				if (Height > MAX_FONT_HEIGHT) {
					CGRequest("Too High!!!");
					//Debug = 3;
					goto ErrExit;
				}
			} else Height = ANY_HEIGHT;

			if (!(Data = AllocLineDataGivenID(&Book->DataList,ID))) {
				//Debug = 4;
				goto ErrExit;
			}
			if (Type == ID_BRUSH) Data->Type = LINE_BRUSH;
			else if (Type == ID_FONT) {
				Data->Type = LINE_TEXT;
				Data->Height = Height;
#ifndef JAMES_VERSION
				if(Version == NEW_BOOK_VERSION)
				{
					if (CR_ERR_NONE != BufferRead(LB,Buff,4)) goto ErrExit;
					PSFontFlags = *(ULONG *)&Buff[0];
				}
#endif
			} else if (Type == ID_DRAW) {
				Data->Type = LINE_DRAW;
				Data->Height = Height;
				if(!(Data->Data = SafeAllocMem(sizeof(struct DrawData),MEMF_CLEAR)))
					goto ErrExit;  // Does this get freed with FreeBook() ??  !!!!
				if (BufferRead(LB,(UBYTE *)Data->Data,sizeof(struct DrawData)) != CR_ERR_NONE)
					goto ErrExit;
				((struct DrawData *)(Data->Data))->Type=DRAW_TYPE_TEXT;
				((struct DrawData *)(Data->Data))->Alfa.BytesPerRow=0;
				((struct DrawData *)(Data->Data))->Alfa.Rows=0;
				((struct DrawData *)(Data->Data))->Alfa.Depth=0;
				((struct DrawData *)(Data->Data))->Alfa.Planes[0]=0;
				((struct DrawData *)(Data->Data))->Alfa.Planes[1]=0;
			}
			if (CR_ERR_NONE != BufferRead(LB,Buff,Size)) {
				//Debug = 5;
				goto ErrExit;
			}
			Buff[Size] = 0;
			BuildFileName(Data,Buff); // Copy Buff into Data->Filename
			BuildSortName(Data,0);
			InsertData(&Book->DataList,Data);
			goto TypeOK;

		case ID_PAGE:
			if (CR_ERR_NONE != BufferRead(LB,Buff,2)) {
				//Debug = 6;
				goto ErrExit;
			}
			A = *(UWORD *)&Buff[0];
			NumLines = 0;

			if (A > (PAGES_PER_BOOK-1)) {
				//Debug = 7;
				goto ErrExit;
			}
			Page = &Book->Page[A];
			if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)&Page->Type,PAGE_SIZE)) {
				//Debug = 8;
				goto ErrExit;
			}
			if (Version == OLD_BOOK_VERSION) {
				Page->TopBackground.Alpha = ALPHA_OPAQUE;
				Page->BottomBackground.Alpha = ALPHA_OPAQUE;
			}
			goto TypeOK;

		case ID_LINE:
			if (A > (PAGES_PER_BOOK-1)) {
				//Debug = 9;
				goto ErrExit; // must have valid page
			}
			if (!(Line = AllocAddLine(Page))) {
				//Debug = 10;
				goto ErrExit;
			}
			if (CR_ERR_NONE != BufferRead(LB,Buff,2)) {
				//Debug = 11;
				goto ErrExit;
			}
			Size = *(UWORD *)&Buff[0]; // number chars
			NumLines++;
			if (NumLines >= 384)
				Line->XOffset = 0;

			if (Version == OLD_BOOK_VERSION) {
				if (!ReadOldLine(Line,LB,Size,Page)) {
					//Debug = 12;
					goto ErrExit;
				}
			} else if (Version == BOOK_VERSION) {
				if (!ReadNotSoNewLine(Line,LB,Size)) {
					//Debug = 13;
					goto ErrExit;
				}
			} else if (!ReadNewLine(Line,LB,Size)) goto ErrExit;
			if (Line->XOffset > PAGE_WIDTH) Line->XOffset = 0;

		case ID_END:
		TypeOK:
			HeadOK = TRUE;
			break;

		}
		if (!HeadOK) {
			//Debug = 14;
			goto ErrExit;
		}
	} while (Type != ID_END);

// pack all crawl page line structures if old book
	Page = &Book->Page[0];
	if (Version == OLD_BOOK_VERSION) {
		for (A = 0; A < PAGES_PER_BOOK; A++) {
			if (Page->Type == PAGE_CRAWL)
				PackCrawlPage(Page);
			Page++;
		}
	}

	Err = NULL;	// success

ErrExit:
		BufferClose(LB);
Exit:
	if (Err) {
		if (Book) {
			FreeBook(Book);
			Book = NULL;
		}
		R->LastError = Err;
	}
	return(Book);
}

//*******************************************************************
BOOL __regargs ReadNewLine(
	struct CGLine *Line,
	struct BufferLock *LB,
	UWORD NumChars)
{
	ULONG A;
	UBYTE *Buff;
	struct TextInfo *Text;

	Buff = (UBYTE *)RD->ByteStrip->Planes[0];

	Text = &Line->Text[0];
	if (!NumChars) { // should never happen
		if (!(Text->Attr = AllocAttrib(&RD->DefaultAttr))) return(FALSE);
	} else

// read TextInfos
	for (A = 0; A < NumChars; A++) {
		if (CR_ERR_NONE != BufferRead(LB,Buff,4)) return(FALSE);
		Text->Ascii = *(UWORD *)&Buff[0];
		Text->Kerning = Buff[2];
		if (Buff[3]) {
			if (!(Text->Attr = AllocAttrib(NULL))) return(FALSE);
			if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)Text->Attr,sizeof(struct Attributes)))
				return(FALSE);
		}
		Text++;
	}

// read CGLine
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)&Line->TotalHeight,LINE_ATTR_SIZE))
		return(FALSE);

	return(TRUE);
}


//*******************************************************************
BOOL __regargs ReadNotSoNewLine(
	struct CGLine *Line,
	struct BufferLock *LB,
	UWORD NumChars)
{
	ULONG A;
	UBYTE *Buff;
	struct TextInfo *Text;
  struct Attributes3  *tmpattr;

	Buff = (UBYTE *)RD->ByteStrip->Planes[0];

	Text = &Line->Text[0];
	if (!NumChars) { // should never happen
		if (!(Text->Attr = AllocAttrib(&RD->DefaultAttr))) return(FALSE);
	} else

// read TextInfos
	for (A = 0; A < NumChars; A++) {
		if (CR_ERR_NONE != BufferRead(LB,Buff,4)) return(FALSE);
		Text->Ascii = *(UWORD *)&Buff[0];
		Text->Kerning = Buff[2];
		if (Buff[3]) {
			if (!(tmpattr = (struct Attributes3 *)AllocAttrib(NULL))) return(FALSE);
			if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)tmpattr,sizeof(struct Attributes3)))
			{
				FreeAttrib((struct Attributes *)tmpattr);
				return(FALSE);
			}
			if (!(Text->Attr = AllocOldAttrib(tmpattr)))
			{
				FreeAttrib((struct Attributes *)tmpattr);
				return(FALSE);
			}
			FreeAttrib((struct Attributes *)tmpattr);
		}
		Text++;
	}

// read CGLine
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)&Line->TotalHeight,LINE_ATTR_SIZE))
		return(FALSE);

	return(TRUE);
}

//*******************************************************************
BOOL __regargs ReadOldLine(
	struct CGLine *Line,
	struct BufferLock *LB,
	UWORD NumChars,
	struct CGPage *Page)
{
	struct CGLine2 *OldLine;
	UWORD A;
	struct TextInfo2 *TI2;
	UBYTE *Buff;
	struct TextInfo *Text;
	struct Attributes *Attr;

	Buff = (UBYTE *)RD->ByteStrip->Planes[0];
	OldLine = (struct CGLine2 *)Buff;

// read TextInfos
	TI2 = (struct TextInfo2 *)Buff;
	Text = &Line->Text[0];
	for (A = 0; A < NumChars; A++) {
		if (CR_ERR_NONE != BufferRead(LB,Buff,sizeof(struct TextInfo2)))
			return(FALSE);
		Text->Ascii = TI2->Ascii;
		Text->Kerning = TI2->Kerning;
		Text++;
	}

// read CGLine
	if (CR_ERR_NONE != BufferRead(LB,(UBYTE *)&OldLine->FaceColor,LINE2_ATTR_SIZE))
		return(FALSE);
	Line->TotalHeight = OldLine->TotalHeight;
	Line->Baseline = OldLine->Baseline;
	Line->XOffset = OldLine->XOffset;
	Line->YOffset = OldLine->YOffset;
	Line->Type = LINE_TEXT;
	Line->JustifyMode = OldLine->JustifyMode;
	if (A = OldLine->Seperator) {
		Line->Type = LINE_BOX;
		Line->FaceWidth = SepWidth[A-1];
		Line->FaceHeight = SepHeight[A-1];
		Line->Text[0].Ascii = 32; // one char faked for attr
	}

// read Text->[0].Attr
	if ((Page->Type != PAGE_CRAWL) || (NodesThisList(&Page->LineList) < 2)) {
		if (!(Attr = AllocAttrib(NULL))) return(FALSE);
		Line->Text[0].Attr = Attr;
		ConvertOldColor(&OldLine->FaceColor,&Attr->FaceColor);
		ConvertOldColor(&OldLine->ShadowColor,&Attr->ShadowColor);
		ConvertOldColor(&OldLine->OutlineColor,&Attr->OutlineColor);
		if (OldLine->RenderFont != 65535)
			Attr->ID = (OldLine->RenderFont >> 2);
		else
			Attr->ID = 0;
		if (OldLine->Seperator)
			Attr->ID = ID_BOX;
		Attr->ShadowLength = OldLine->ShadowLength;
		Attr->ShadowType = OldLine->ShadowType;
		if (OldLine->ShadowType > SHADOW_CAST) {
			Attr->ShadowType = OldLine->ShadowType - 2;
			Attr->ShadowColor.Alpha = OLD_TRANSP_ALPHA;
		}
		Attr->OutlineType = (OldLine->OutlineType >> 3); // convert to 0,1,..

	// somehow shadow direction meaning got switched
		Attr->ShadowDirection = OldLine->ShadowDirection + 4;
		if (Attr->ShadowDirection > 7) Attr->ShadowDirection -= 8;

		Attr->ShadowPriority = OldLine->ShadowPriority;
		Attr->SpecialFill=FILL_OLD;
		Attr->GradColor=Attr->FaceColor;
		Attr->OGradColor=Attr->OutlineColor;
	}
	return(TRUE);
}

//*******************************************************************
VOID __regargs ConvertOldColor(
	struct OldColor *Old,
	struct TrueColor *New)
{
	if (Old->Mono) {
		New->Red = Old->Red;
		New->Green = Old->Red;
		New->Blue = Old->Red;
	} else {
		New->Red = Old->Red;
		New->Green = Old->Green;
		New->Blue = Old->Blue;
	}
	New->Alpha = ALPHA_OPAQUE;
}

//*******************************************************************
struct CGLine *__asm AllocAddLine(
	register __a1 struct CGPage *Page)
{
	struct CGLine *Line;

	if (Line = SafeAllocMem(sizeof(struct CGLine),MEMF_CLEAR)) {
		AddTail((struct List *)&Page->LineList,(struct Node *)Line);
	}
	return(Line);
}

//*******************************************************************
// keeps fonts in old book for new book
//
struct CGBook *__asm DoLoadBook(
	register __a0 char *FileName,
	register __a1 struct CGBook *OldBook)
{
	struct CGBook *NewBook;
	struct RenderData *R;
	struct LineData *Data,*Next,*Got;
	UWORD A;
	struct CGLine *Line,*NextLine;
	struct CGPage *Page;
	char *Mess[2];

	R = RD;
	if (NewBook = LoadNewBook(FileName)) {
		if (OldBook) { // keep any fonts that have the same filename
			Data = (struct LineData *)NewBook->DataList.mlh_Head;
			while (Next = (struct LineData *)Data->Node.mln_Succ) {
			if ((Got=GetDataFromFileName(&OldBook->DataList,Data->FileName,
					Data->Height))
				&& (Got->Type == Data->Type)) {
				Data->Data = Got->Data;
				Got->Data = NULL; // so not freed with book
				if (Data->Type == LINE_TEXT) // if EUC, dump list
					FreeEUCList((struct ToasterFont *)Data->Data);
			}
			Data = Next;
			}
		}
		NewCurrentBook(NewBook); // for LoadRenderFonts()
		R->AdditionalError = NULL;
		if (!LoadRenderFonts(NewBook)) { // only failure is loading font 0
			Mess[0] = UnableLoadFont;
			A = 1;
			if (R->AdditionalError) {
				Mess[1] = R->AdditionalError;
				A = 2;
			}
			CGMultiRequest(Mess,A,REQ_H_CENTER|REQ_CENTER);
			R->LastError = CG_ERROR_LOAD_FONT;
			FreeBook(NewBook);
			NewBook = NULL;
			R->CurrentBook = NULL;
		} else {

// for some reason, old books crawl pages have incorrect totalheights
		Page = &NewBook->Page[0];
		for (A = 0; A < PAGES_PER_BOOK; A++) {

// also,if just loaded old book, convert EUC lines to new word text_ascii format
			if (LastLoadVer == OLD_BOOK_VERSION) {
				ConvertOldEUC(Page);

	// also, fix shadow direction problems
				if (Page->Type == PAGE_SCROLL) {
				Line = (struct CGLine *)Page->LineList.mlh_Head;
				while (NextLine = (struct CGLine *)Line->Node.mln_Succ) {
					R->CurrentPage = Page; // for UpdateLineHeight()
					UpdateLineHeight(Line);
					Line = NextLine;
				}
				}
			}

			if (Page->Type == PAGE_CRAWL)
			{
				if ((Line = (struct CGLine *)Page->LineList.mlh_Head) &&
					(Line->Node.mln_Succ)) {
					R->CurrentPage = Page;
					UpdateLineHeight(Line);
				}
			}
			else if (Page->Type == PAGE_EMPTY)  // fix new bug w/ empty pages
				Page->Type =  PAGE_STATIC;
			Page++;
		}
		PreRenderBook(NewBook);
		R->PageNumber = 0;
		R->UpdatePage = 1;
		NewCurrentPage();
		}
		}

FreeOld:
	if (OldBook) FreeBook(OldBook);
	if (R->StatusMessage == OutMemoryMsg) CGRequest(R->StatusMessage);
	return(NewBook);
}

//*******************************************************************
// (Old books have already been packed to be new LINE_LENGTH on
// all lines except the last one)
//
VOID __asm ConvertOldEUC(
	register __a0 struct CGPage *Page)
{
	struct TextInfo *SrcText,*DestText,*NextText;
	struct CGLine *Line,*Next,*SrcLine,*DestLine;
	UWORD L,SrcA,DestA;

// PAGE_CRAWLs had 2byte codes split between lines
	if (Page->Type == PAGE_CRAWL) {
	DestLine = SrcLine = (struct CGLine *)Page->LineList.mlh_Head;
	DestText = SrcText = &SrcLine->Text[0];
	SrcA = DestA = 0;
	while (SrcText->Ascii) {
	if (SrcText->Ascii >= 0x80) {
		DestText->Kerning = SrcText->Kerning;

	// tricky case - when split across line structures
		if (SrcA == LINE_LENGTH-1) {
			Next = (struct CGLine *)SrcLine->Node.mln_Succ;
			if (!Next->Node.mln_Succ) return; // goto Done; // should never happen
			NextText = &Next->Text[0];
			DestText->Ascii = (SrcText->Ascii << 8) | NextText->Ascii;
			SrcLine = Next;
			SrcText = &Next->Text[0];
			SrcA = 0;

		} else
			DestText->Ascii = (SrcText->Ascii << 8) | ((SrcText+1)->Ascii);

	} else {
		DestText->Ascii = SrcText->Ascii;
		DestText->Kerning = SrcText->Kerning;
	}

	SrcText++;
	SrcA++;
	if (SrcA == LINE_LENGTH) {
		SrcLine = (struct CGLine *)SrcLine->Node.mln_Succ;
		if (!SrcLine->Node.mln_Succ) return; // goto Done;
		SrcText = &SrcLine->Text[0];
		SrcA = 0;
	}

	DestText++;
	DestA++;
	if (DestA == LINE_LENGTH) {
		DestLine = (struct CGLine *)DestLine->Node.mln_Succ;
		DestText = &DestLine->Text[0];
		DestA = 0;
	}
	}

// non-PAGE_CRAWLs
	} else {
	Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ) {
		if (GetFontType(Line->Text[0].Attr->ID) == FONT_TYPE_EUC) {
		DestText = SrcText = &Line->Text[0];
		L = 0;
		while ((SrcText->Ascii) && (L < LINE_LENGTH)) {
			if (SrcText->Ascii >= 0x80) {
				DestText->Ascii = (SrcText->Ascii << 8) | ((SrcText+1)->Ascii);
				SrcText++;
				L++;
			} else *DestText = *SrcText;
			SrcText++;
			DestText++;
			L++;
			}
		}
		Line = Next;
	}
	}
// Done: ;
}

//*******************************************************************
VOID __asm NewCurrentBook(
	register __a0 struct CGBook *Book)
{
	struct RenderData *R;

	R = RD;
	R->CurrentBook = Book;
	R->PageNumber = 0;
	NewCurrentPage(); // calls NewCurrentLine
}

/*******************************************************************
* BOOL LoadRenderFonts
*
*	If unable to load any font in the book, it replaces it with
*	(first font in default book). Additional unloaded
*	fonts result in the book being changed so that these lines point
*	to this font as well. Note none of the fonts in the book might
*	be available, yet book loading will still succeed.
*
* Upon Exit:
*	returns TRUE if book loadable, FALSE if not
*	updates gb_LastError,gb_AdditionalError if any font not loaded
*	d0-d1/a0-a1 trashed
********************************************************************/
BOOL __asm LoadRenderFonts(
	register __a0 struct CGBook *Book)
{
	struct LineData *Data,*Next,*Same,*DTData;
	struct ToasterFont *DTF;
	struct RenderData *R;
	char *C;

	R = RD;
	R->DefaultAttr.ID = 0;
	R->LastDefaultFont = 0;
	R->DefaultLine.Type = LINE_TEXT;
	ClearReplaceFlag(Book);

// load font 0 first so ReplaceID() can find it if needed
	if (!(Data = GetDataGivenBook(&Book->DataList,0)))
		return(FALSE); // all books need a font 0

// force font 0 to be default font, force it to be new path
	BuildFileName(Data,&DefFontName[0][0]);

//		DumpHexiL("LoadRenderFonts: Data =",(ULONG)Data," Name:  ");
//		DumpMsg(Data->FileName);

	if (!(Data->Data = LoadToasterFont(Data->FileName,FONT_ZERO_HEIGHT,
			FONT_TYPE_FILTER_CHROMA))) {
		strcpy(FailFontName,Data->FileName);
		R->LastError = CG_ERROR_LOAD_FONT;
		R->AdditionalError = FailFontName;
		return(FALSE);  // failing default font is fatal
	} else {
		Data->Height = FONT_ZERO_HEIGHT;
	}

	Data = (struct LineData *)Book->DataList.mlh_Head;
	while (Next = (struct LineData *)Data->Node.mln_Succ)
	{
		if ((!Data->Data) && (Data->Type != LINE_BOX))
		{
TryAgain:
			if (Data->Type == LINE_TEXT)
			{
				CheckOldFonts(Data);
				if (Data->Data = LoadToasterFont(Data->FileName,Data->Height,(PSFontFlags ? FONT_TYPE_PSCOMP:0) ))
					Data->Height = ((struct ToasterFont *)Data->Data)->TextBM.Rows;
			}
			else if (Data->Type == LINE_BRUSH)
			{
				Data->Data = LoadBrush(Data->FileName);
			}
			else if (Data->Type == LINE_DRAW)
			{
				if(!GetDataFromFileName(&Book->DataList,Data->FileName,ANY_HEIGHT))
				{
					if( !(DTF=LoadToasterFont(Data->FileName,40,0)) )
					{
						if(Data->Data) // replace with box..
						{
							ReplaceID(Book,Data->ID,ID_BOX,TRUE);  // fix all attr.s on new page
							RemFreeLineData(Data);
							Data->Data = NULL;
						}
					}
					else // Loaded a new font.. add to list
					{
						if (!(DTData = AllocLineData(&Book->DataList)))
						{
							DTData->Height = DTF->TextBM.Rows;;
							DTData->Data = DTF;
//							DumpStr("Loading Font for DRAW only:");
							BuildFileName(DTData,Data->FileName);
//							DumpMsg(DTData->FileName);
//							InsertData(&Book->DataList,DTData);
							AddSortDataList(&Book->DataList,DTData);
						}
					}
				}
				if(Data->Data) ReFillDraw(Data);
			}
// this line never happens, since Data->Data is filled...
			if (!Data->Data)
			{
				MarkBookID(Book,Data->ID); // something's going to change
				C = ReplaceData(Data); // sets Data->Height
				R->LastError = NULL;
				R->AdditionalError = NULL;	// no longer want cgslicecode
											// dealing with load errs
				if (C)
				{
					Data->FileName[0] = 0;
					if (Same=GetDataFromFileName(&Book->DataList,C,Data->Height))
					{
						if (Data->Type != Same->Type) goto Fail;
						ReplaceID(Book,Data->ID,Same->ID,FALSE);
						RemFreeLineData(Data);
						goto DoNext;
					}
					BuildFileName(Data,C);
					goto TryAgain;
				}
			Fail:
				if (Data->Type == LINE_BRUSH)
				{ // replace brush with box
					ReplaceID(Book,Data->ID,ID_BOX,TRUE);  // fix all attr.s on new page
					RemFreeLineData(Data);
				}
				else
				{
					ReplaceID(Book,Data->ID,0,FALSE); // else replace w/default
					RemFreeLineData(Data);
				}
			}
			else
			{
				ReadFileSize(Data);
			}
		}
DoNext:
		if (Data->Type == LINE_DRAW) ReFillDraw(Data);
		Data = Next;
	}
	if ((Data = GetData(DEFAULT_FONTS-1)) && (Data->Type == LINE_TEXT)) {
		R->DefaultAttr.ID = R->LastDefaultFont = DEFAULT_FONTS-1;
		R->DefaultLine.Type = LINE_TEXT;
	}
	UpdateReplaceBook(Book);
	BuildDisplayNames(&Book->DataList);
	return(TRUE);
}

//*******************************************************************
// assumes book DataList is empty, but NEWLISTed
// (attribute routines required RD->CurrentBook)
//
BOOL __asm InitRenderFonts(
	register __a0 struct CGBook *Book)
{
	UWORD A;
	struct LineData *Data;

	for (A=0; A < DEFAULT_FONTS; A++) {
		if (!(Data = AllocLineData(&Book->DataList))) return(FALSE);
		Data->Height = ANY_HEIGHT;
//		Data->ID = A;
		BuildFileName(Data,&DefFontName[A][0]);
		InsertData(&Book->DataList,Data);
	}
	if (!AddBox(Book)) return(FALSE);
	return(TRUE);
}

//*******************************************************************
BOOL __asm SaveBook(
	register __a0 char *FileName,
	register __a1 struct CGBook *Book)
{
	struct BufferLock *LB;
	struct RenderData *R;
	BOOL Success;
	ULONG Err = CG_ERROR_SAVE_BOOK;
	UBYTE *Buff;
	struct LineData *Data,*Next;
	struct CGLine *Line,*NLine;
	struct CGPage *Page;
	UWORD A,B,C,D;
	struct TextInfo *Text;

	R = RD;
	Buff = (UBYTE *)R->ByteStrip->Planes[0];
	if (!(LB = BufferOpen(FileName,MODE_NEWFILE,BUFF_SIZE,R->ByteStrip->Planes[1])))
		goto Exit;
	if (!LB->File) goto Exit;
	strcpy(Buff,BookHead);
	Buff[BK_HEAD_SIZE-1] = NEW_BOOK_VERSION;
	if (CR_ERR_NONE != BufferWrite(LB,Buff,BK_HEAD_SIZE)) goto Exit;

// save all font and brush names used in book
	Data = (struct LineData *)Book->DataList.mlh_Head;
	while (Next = (struct LineData *)Data->Node.mln_Succ)
	{
		if (Data->Type != LINE_BOX)
		{
			if (Data->Type == LINE_TEXT) *(ULONG *)Buff = (ULONG)ID_FONT;
 			else if (Data->Type == LINE_DRAW) *(ULONG *)Buff = (ULONG)ID_DRAW;
			else *(ULONG *)Buff = (ULONG)ID_BRUSH;
			if (Data->FileName && (A  = (UWORD)strlen(Data->FileName)))
			{
				*(UWORD *)&Buff[4] = Data->ID;
				*(UWORD *)&Buff[6] = A;
				if (CR_ERR_NONE != BufferWrite(LB,Buff,8)) goto Exit;
				if ( (Data->Type == LINE_TEXT) || (Data->Type == LINE_DRAW) )
				{
					*(UWORD *)Buff = Data->Height;
					if (CR_ERR_NONE != BufferWrite(LB,Buff,2)) goto Exit;
				}
				if(Data->Type == LINE_TEXT)
					if (CR_ERR_NONE != BufferWrite(LB,(UBYTE *)&PSFontFlags,4)) goto Exit;
				if (Data->Type == LINE_DRAW) // Should probably clear out bitmap !!!
				  if (CR_ERR_NONE != BufferWrite(LB,Data->Data,sizeof(struct DrawData))) goto Exit;
				if (CR_ERR_NONE != BufferWrite(LB,Data->FileName,A)) goto Exit;
			}
		}
		Data = Next;
	}

// save all non-trivial pages
	Page = &Book->Page[0];
	for (A = 0; A < PAGES_PER_BOOK; A++) {
		if ((Page->Type) && (B = NodesThisList(&Page->LineList))){
			Line = (struct CGLine *)Page->LineList.mlh_Head;
			if ((B > 1) || (Line->Text[0].Ascii)) {
			*(ULONG *)Buff = (ULONG)ID_PAGE;
			*(UWORD *)&Buff[4] = A;
			if (CR_ERR_NONE != BufferWrite(LB,Buff,6)) goto Exit;
			if (CR_ERR_NONE != BufferWrite(LB,&Page->Type,PAGE_SIZE)) goto Exit;
			while (NLine = (struct CGLine *)Line->Node.mln_Succ) {
				B = LineLength(Line);
				if (B < 1) B = 1; // always include Text[0].Attr
				*(ULONG *)Buff = (ULONG)ID_LINE;
				*(UWORD *)&Buff[4] = B; // #chars
				if (CR_ERR_NONE != BufferWrite(LB,Buff,6)) goto Exit;
				Text = &Line->Text[0];
				for (C = 0; C < B; C++) {
					*(UWORD *)Buff = Text->Ascii;
					Buff[2] = Text->Kerning;
					if (!Text->Attr) {
						Buff[3] = 0;
						D = 4;
					} else {
						Buff[3] = 1;
						D = 4 + sizeof(struct Attributes);
						CopyMem(Text->Attr,&Buff[4],sizeof
							(struct Attributes));
					}
					if (CR_ERR_NONE != BufferWrite(LB,Buff,D)) goto Exit;
					Text++;
				}
				if (CR_ERR_NONE != BufferWrite(LB,(UBYTE *)&Line->TotalHeight,LINE_ATTR_SIZE))
					goto Exit;
				Line = NLine;
			}
		}
		}
		Page++;
	}

// save end marker
	*(ULONG *)Buff = (ULONG)ID_END;
	if (CR_ERR_NONE != BufferWrite(LB,Buff,4)) goto Exit;

	Err = NULL;	// success
Exit:
	if (LB) BufferClose(LB);
	if (Err) {
		R->LastError = Err;
		Success = FALSE;
	} else
		Success = TRUE;
	return(Success);
}

//*******************************************************************
BOOL __asm SavePage(
	register __a0 char *FileName,
	register __a1 struct CGBook *Book,
	register __d0 UWORD PageNum)
{
//	struct LockBuffer *LB;
	struct BufferLock *LB;
	struct RenderData *R;
	ULONG Err = CG_ERROR_SAVE_BOOK;
	UBYTE *Buff;
	struct LineData *Data,*Next;
	struct CGLine *Line,*NLine;
	struct CGPage *Page;
	UWORD A,B,C,D;
	struct TextInfo *Text;

	if (PageNum < PAGES_PER_BOOK)
  {
  	Page = &Book->Page[PageNum];
		if ( (Page->Type) && (B = NodesThisList(&Page->LineList)) )
		{
			R = RD;
			Buff = (UBYTE *)R->ByteStrip->Planes[0];
			if (!(LB = BufferOpen(FileName,MODE_NEWFILE,BUFF_SIZE,
				R->ByteStrip->Planes[1]))) goto Exit;
			if (!LB->File) goto Exit;
			strcpy(Buff,BookHead);
			Buff[BK_HEAD_SIZE-1] = NEW_BOOK_VERSION;
			if (CR_ERR_NONE != BufferWrite(LB,Buff,BK_HEAD_SIZE)) goto Exit;

			// save all font and brush names used in Page
			Data = (struct LineData *)Book->DataList.mlh_Head;
			while (Next = (struct LineData *)Data->Node.mln_Succ)
			{
				if (Data->Type != LINE_BOX)
					if (DataInPage(Page,Data->ID))
					{
						if (Data->Type == LINE_TEXT) *(ULONG *)Buff = (ULONG)ID_FONT;
						else if (Data->Type == LINE_DRAW) *(ULONG *)Buff = (ULONG)ID_DRAW;
						else *(ULONG *)Buff = (ULONG)ID_BRUSH;
						if (Data->FileName && (A  = (UWORD)strlen(Data->FileName)))
						{
						  *(UWORD *)&Buff[4] = Data->ID;
							*(UWORD *)&Buff[6] = A;
							if (CR_ERR_NONE != BufferWrite(LB,Buff,8)) goto Exit;
							if ((Data->Type == LINE_TEXT) || (Data->Type == LINE_DRAW))
							{
								*(UWORD *)Buff = Data->Height;
							  if (CR_ERR_NONE != BufferWrite(LB,Buff,2)) goto Exit;
							}
							if(Data->Type == LINE_TEXT)
								if (CR_ERR_NONE != BufferWrite(LB,(UBYTE *)&PSFontFlags,4)) goto Exit;
							if (Data->Type == LINE_DRAW)
							  if (CR_ERR_NONE != BufferWrite(LB,Data->Data,sizeof(struct DrawData))) goto Exit;
							if (CR_ERR_NONE != BufferWrite(LB,Data->FileName,A)) goto Exit;
			 			}
				  }
				Data = Next;
			}

			      // save  page
			Line = (struct CGLine *)Page->LineList.mlh_Head;
			if ((B > 1) || (Line->Text[0].Ascii))
      {
			  *(ULONG *)Buff = (ULONG)ID_PAGE;
  			*(UWORD *)&Buff[4] = A;
				if (CR_ERR_NONE != BufferWrite(LB,Buff,6)) goto Exit;
				if (CR_ERR_NONE != BufferWrite(LB,&Page->Type,PAGE_SIZE)) goto Exit;
				while (NLine = (struct CGLine *)Line->Node.mln_Succ)
				{
					B = LineLength(Line);
					if (B < 1) B = 1; // always include Text[0].Attr
					*(ULONG *)Buff = (ULONG)ID_LINE;
					*(UWORD *)&Buff[4] = B; // #chars
					if (CR_ERR_NONE != BufferWrite(LB,Buff,6)) goto Exit;
					Text = &Line->Text[0];
					for (C = 0; C < B; C++)
					{
					  *(UWORD *)Buff = Text->Ascii;
  					Buff[2] = Text->Kerning;
	  				if (!Text->Attr) {
		  				Buff[3] = 0;
			  			D = 4;
				  	} else {
					  	Buff[3] = 1;
						  D = 4 + sizeof(struct Attributes);
  						CopyMem(Text->Attr,&Buff[4],sizeof
	  						(struct Attributes));
		  			}
			  		if (CR_ERR_NONE != BufferWrite(LB,Buff,D)) goto Exit;
				    Text++;
  				}
	  			if (CR_ERR_NONE != BufferWrite(LB,(UBYTE *)&Line->TotalHeight,LINE_ATTR_SIZE))
		  			goto Exit;
			  	Line = NLine;
  			}
		  }
		// save end marker
			*(ULONG *)Buff = (ULONG)ID_END;
			if (CR_ERR_NONE != BufferWrite(LB,Buff,4)) goto Exit;
			Err = NULL;	// success
		}
	}


Exit:
	if (LB) {
		if (!BufferClose(LB)) Err = CG_ERROR_SAVE_BOOK;
	}
	if (Err)
  {
		R->LastError = Err;
    return(FALSE);
	} else  return(TRUE);
}

BOOL __asm DumpFile(register __a0 char *FileName,register __a1 UBYTE *Buff,register __d0 ULONG Siz)
{
	struct BufferLock *LB;
	BOOL	ret=FALSE;
	if( (LB = BufferOpen(FileName,MODE_READWRITE,BUFF_SIZE,RD->ByteStrip->Planes[1]))
			&& (LB->File) )
	{
		BufferSeek(LB,0,OFFSET_END);
		if (BufferWrite(LB,Buff,Siz)) ret=TRUE;
	}
	if (LB) BufferClose(LB);
	return(ret);
}

ULONG __asm RAMCRuDx(register __a1 UBYTE *Buff,register __d0 ULONG Siz,register __d1 ULONG Type)
{
	ULONG	*chk,csiz,s,p,fs;

	csiz = (ULONG)&crudTAGSIZE - (ULONG)&CRuDTop + 4;
	CopyMem(&CRuDTop,Buff,csiz); // copy in whatever SKell makes with macros in tags.i
	p = WriteRAMPage((UBYTE *)&(Buff[csiz]),RD->CurrentBook,RD->PageNumber,Siz - csiz);
	s=csiz + p;

	chk= (ULONG *)Buff;  // chk[0]='FORM'
//	DumpHex("CRuD:",chk,64);
	chk[1] += p;  // IFF chunk size (already has empty size)
//	DumpHexiL("Page Size: ",p,"\\");
//	DumpHex("CRuD:",chk,64);
	fs = chk[1];  // FORM size
	if(Type) chk[5] = Type;  // chk[2]='CRuD',chk[3,4]='TYPE'size(=0)

	chk = (ULONG *)&(Buff[(ULONG)&crudTAGSIZE - 8 - (ULONG)&CRuDTop]);
	chk[0] += p; // new size of TAGS chunk, just before TAGID_Page (chk[1])
	chk[2] = p; // Size of BOOK tag data

	chk = &crudTAGSIZE;
	csiz = (ULONG)&CRuDHEAD - (ULONG)&crudTAGSIZE;
	CopyMem(&(chk[1]),&(Buff[s]),csiz);
	csiz+=s;
	if(csiz&1) csiz++;
//	DumpHexiL("CrUD Size: ",csiz,"\\");
	return(csiz);
}

ULONG __asm RAMCRuD(register __a1 UBYTE *Buff,register __d0 ULONG Siz,register __d1 ULONG Type)
{
	ULONG	*end,csiz,p;
	struct PageCrUD *crud;

	csiz=sizeof(struct PageCrUD);
	CopyMem(&MyCrUD,Buff,csiz);
	crud=(struct PageCrUD *)Buff;
	p = WriteRAMPage((UBYTE *)&(Buff[csiz]),RD->CurrentBook,RD->PageNumber,Siz - csiz);
	crud->PageSize = p;
	crud->fSize = csiz + p - 4;
	crud->tSize += p ;
	if(Type) crud->CType = Type;
	end = (ULONG *)&(Buff[csiz+p]);
	*end=TAG_DONE;
	return(csiz + p+4);
}


#define ADD_BUFF(buf,typ,val)		{*(typ *)buf = val; buf += sizeof(typ);}

//*******************************************************************
ULONG __asm WriteRAMPage(
	register __a0 UBYTE *RAMBuff,
	register __a1 struct CGBook *Book,
	register __d0 UWORD PageNum,
	register __d1 ULONG BuffSize )
{
	struct RenderData *R;
	ULONG Err = CG_ERROR_SAVE_BOOK, Siz;
	struct LineData *Data,*Next;
	struct CGLine *Line,*NLine;
	struct CGPage *Page;
	struct TextInfo *Text;
	UWORD A,B,C;
	UBYTE *Buff,*BuffEnd;

	if (PageNum < PAGES_PER_BOOK)
	{
		Page = &Book->Page[PageNum];
		if ( (Page->Type) && (B = NodesThisList(&Page->LineList)) )
		{
			R = RD;
			Buff = RAMBuff;
			BuffEnd =&(Buff[BuffSize]);
			Siz=stccpy(Buff,BookHead,100);
			Buff[Siz-1] = NEW_BOOK_VERSION;
			Buff+=Siz;
			// save all font and brush names used in Page
			Data = (struct LineData *)Book->DataList.mlh_Head;
			while( (Next = (struct LineData *)Data->Node.mln_Succ)
						&& !(Err=(BOOL)(Buff-RAMBuff+80 >= BuffSize)) ) // Safety First!!
			{
				if (Data->Type != LINE_BOX)
					if (DataInPage(Page,Data->ID))
					{
						if (Data->Type == LINE_TEXT) ADD_BUFF(Buff,ULONG,ID_FONT)
						else if (Data->Type == LINE_DRAW) ADD_BUFF(Buff,ULONG,ID_DRAW)
						else ADD_BUFF(Buff,ULONG,ID_BRUSH)
						if (Data->FileName && (A  = (UWORD)strlen(Data->FileName)))
						{
							ADD_BUFF(Buff,UWORD,Data->ID);
							ADD_BUFF(Buff,UWORD,A);
							if ((Data->Type == LINE_TEXT) || (Data->Type == LINE_DRAW))
							{
								ADD_BUFF(Buff,UWORD,Data->Height);
							}
							if(Data->Type == LINE_TEXT)
								ADD_BUFF(Buff,ULONG,PSFontFlags);
							if (Data->Type == LINE_DRAW)
							{
								CopyMem(Data->Data,Buff,sizeof(struct DrawData));
								Buff += sizeof(struct DrawData);
							}
							strcpy(Buff,Data->FileName);
							Buff+=A;
						}
					}
				Data = Next;
			}
// save  page
			Line = (struct CGLine *)Page->LineList.mlh_Head;
			if ((B > 1) || (Line->Text[0].Ascii))
			{
				ADD_BUFF(Buff,ULONG,ID_PAGE)
				ADD_BUFF(Buff,UWORD,PageNum);
				CopyMem(&Page->Type,Buff,PAGE_SIZE);
				Buff+=PAGE_SIZE;
				while( (NLine = (struct CGLine *)Line->Node.mln_Succ)
						&& !(Err=(BOOL)(Buff-RAMBuff+80 >= BuffSize)) ) // Safety First!!
				{
					B = LineLength(Line);
					if (B < 1) B = 1; // always include Text[0].Attr
					ADD_BUFF(Buff,ULONG,ID_LINE);
					ADD_BUFF(Buff,UWORD,B); // #chars
					Text = &Line->Text[0];
					for (C = 0; (C < B) && (Buff<(BuffEnd-20)) ; C++)
					{
						ADD_BUFF(Buff,UWORD,Text->Ascii);
						*Buff++ = Text->Kerning;
						if (!Text->Attr) {
							*Buff++ = 0;
						} else {
							*Buff++ = 1;
							CopyMem(Text->Attr,Buff,sizeof(struct Attributes));
							Buff += sizeof(struct Attributes);
						}
						Text++;
					}
					CopyMem(&Line->TotalHeight,Buff,LINE_ATTR_SIZE);
					Buff+=LINE_ATTR_SIZE;
					Line = NLine;
				}            
			}
		// save end marker
			ADD_BUFF(Buff,ULONG,ID_END);
			Err = NULL;	// success
		}
	}
	if (Err)
	{
		R->LastError = CG_ERROR_SAVE_BOOK;
		return(0);
	}
	Err = (Buff-RAMBuff);
	if(Err&1)  // Always return even number of bytes!
	{
		*Buff++=0;
		Err++;
	}
	return(Err);
}

BOOL	AppendIcon(char *name, char *iconname)
{
	BPTR fil,icon;
	BOOL  ret=FALSE,done=FALSE;
	int siz;
	UBYTE	*Buff=RD->ByteStrip->Planes[1];

	if(fil = Open(name,MODE_READWRITE))
	{
		if(icon = Open(iconname,MODE_OLDFILE))
		{
			Seek(fil,0,OFFSET_END);
			while(!done)
			{
				siz = Read(icon,Buff,BUFF_SIZE);
				if(siz<BUFF_SIZE) done=TRUE;
				if (siz == Write(fil,Buff,siz)) ret=TRUE;
				else ret=FALSE;
			}
			Close(icon);
		}
		Close(fil);
	}
	return(ret);
}

#define PSPLANE_SIZE	128000 // 1280x800 bits

BOOL	SaveCrouton(char *name)
{
	UWORD A;
	ULONG	s,Type = FRAM,t;
	struct MovePage	*MP;
	struct PageCrUD *crud;
	char icon[120];

	if(!*name) return(FALSE);
	A = RD->CurrentPage->Type;
	DisplayWaitSprite();
	strncpy(icon,name,117);
	strncat(icon,".i",117);

	switch(A) {
		case PAGE_STATIC:
			Type=KEYF;
		case PAGE_BUFFER:
			DoRenderDisk(name);
			DisplayWaitSprite();
			s=RAMCRuD(RD->PSRenderPlane,PSPLANE_SIZE,Type);
//			DumpHexiL("Next CrUD Size: ",s,"\\");
//			s = WriteRAMPage((UBYTE *)RD->PSRenderPlane,RD->CurrentBook,RD->PageNumber,PSPLANE_SIZE);
			RenderIcon(RD->CurrentPage,icon,RD->PSRenderPlane,s);
			AppendIcon(name, icon);
			break;

		case PAGE_SCROLL:
			Type=SCRO;
		case PAGE_CRAWL:
			if(Type!=SCRO)	Type=CRAW;
			if(MP=InitMovePage(RD->CurrentPage))
			{
				FillGlyphList(MP);
				t=MPDuration(MP,A);
//				DumpUDecL("Page duration: ",t," fields ");
//				DumpUDecL(" (",t/60," Sec.s) \\ ");
				s=RAMCRuD(RD->PSRenderPlane,PSPLANE_SIZE,Type);
				crud = (struct PageCrUD *)RD->PSRenderPlane;
				crud->Duration = t;
				crud->Speed = MP->Speed;
				if (RD->CurrentPage->PlaybackMode == PLAY_FREEZE)
					crud->Hold = 60;	// Default freeze time
				else
					crud->Hold = 0;		// Scroll thru once
				RenderIcon(RD->CurrentPage,icon,RD->PSRenderPlane,s);
				SaveMovePage(name,MP);
				FreeMovePage(MP);
				AppendIcon(name, icon);
			}
		break;
	}
	UpdateMessage();
	DisplayNormalSprite();
	return (TRUE);
}

//*******************************************************************
// Load a page in at current page number, or first available
// keeps fonts in old book for new book
// returns number of pages loaded
int __asm LoadPage(register __a0 char *FileName)
{
	struct RenderData *R;
	struct CGBook *NewBook,*OldBook=RD->CurrentBook;
	struct LineData *Data,*Next,*Got,*tmp;
	struct MinList *SrcList,*DstList;
	struct CGLine *Line;
//	struct ToasterFont *DTF;
	UWORD A,B,C=0;
	struct Node *node,*nextnode;
	struct CGPage *Page,*NewPage;

	R = RD;
	DisplayWaitSprite();
	NewUpdateMessage(FileName);

	if (NewBook = LoadNewBook(FileName))
	{
#ifdef DEBUG
	CheckBook(NewBook);
#endif
		if (OldBook) // Like this would ever be 0
		{
			NewCurrentBook(NewBook); // for ReplaceID(), LoadRenderFonts()
			Data = (struct LineData *)NewBook->DataList.mlh_Head;
			// Re-Arrange IDs so Old,New lists are compatible,
			while (Next = (struct LineData *)Data->Node.mln_Succ)
			{
				if(Data->Type!=LINE_BOX)
				{
					if( (Got=GetDataFromFileName(&OldBook->DataList,Data->FileName,Data->Height))
						 && (Got->Type == Data->Type) ) // This data already in book.. replace IDs
					{
						if(Data->ID != Got->ID) // same file, same ID ==> just copy data ptr
						{
							if(tmp=GetDataGivenBook(&NewBook->DataList,Got->ID))
							{ 			// existing ID used in newbook..
								A=GetNewID(&OldBook->DataList,&NewBook->DataList);
								ReplaceID(NewBook,Got->ID,A,FALSE);  // fix all attr.s on new page
								tmp->ID=A;
							}
							ReplaceID(NewBook,Data->ID,Got->ID,FALSE);
							Data->ID = Got->ID;
						}
						Data->Data = Got->Data; // set new Data->Data so LoadRenderfonts won't re-load
					}
					else  // New Data not in old book, make compat.
					{
						if( GetDataGivenBook(&OldBook->DataList,Data->ID) )
						{  // This ID in currentbook already
							A=GetNewID(&OldBook->DataList,&NewBook->DataList);
							ReplaceID(NewBook,Data->ID,A,FALSE);  // fix all attr.s on new page
							Data->ID = A;
						}
					}
				}
			  Data = Next;
			} // Now NewBook DataList is ready for LoadRenderFonts
			R->AdditionalError = NULL;
			LoadRenderFonts(NewBook);  // only failure is loading font 0
			NewCurrentBook(OldBook); // for LoadRenderFonts()

// Move NewBook data over to oldbook list...
			Data = (struct LineData *)NewBook->DataList.mlh_Head;
			while (Next = (struct LineData *)Data->Node.mln_Succ)
			{
				if(Data->Type!=LINE_BOX)
				{
					if( (Got=GetDataFromFileName(&OldBook->DataList,Data->FileName,Data->Height))
						 && (Got->Type == Data->Type) ) // This data already in book.. replace IDs
					{
						Data->Data = NULL;  // same as Oldlist data
						RemFreeLineData(Data);
					}
					else {
						Remove((struct Node *)&Data->Node);
						InsertData(&OldBook->DataList,Data);  // sort alpha above box
					}
				}
				Data = Next;
			}
		}  // Now all fonts Loaded, All IDs OK in NewBook, NewDatalist empty
		BuildDisplayNames(&OldBook->DataList);

#ifdef DEBUG
	CheckBook(NewBook);
#endif


// Move NewBook's non-empty Pages into OldBook's next empty pages
		Page = &NewBook->Page[0];
		B=R->PageNumber;
		for (A=0; A < PAGES_PER_BOOK; A++,Page++)
		{
			if ( !TrivialPage(Page) )         // FindEmptyPage, copy pagemem, free pagemem, not linelist
			{
				NewPage=&OldBook->Page[B];  // Start at current page
				while( !TrivialPage(NewPage) && (B<PAGES_PER_BOOK) )
				{  // get to next empty
					B++;
					NewPage++;
				}
				if(B<PAGES_PER_BOOK)
				{
					SrcList = &(Page->LineList);
					DstList = &(NewPage->LineList);
					node=(struct Node *)(DstList->mlh_Head);
					if(node->ln_Succ) RemFreeLine((struct CGLine *)node,NewPage);
//					NewList((struct List *)DstList);  // !!! MEM LEAK: Free this line?
					for(node=(struct Node *)(SrcList->mlh_Head),nextnode=node; nextnode=nextnode->ln_Succ; node=nextnode)
					{
						Line=(struct CGLine *)node;
						Line->Rendered = FALSE;
#ifdef DEBUG
						if(Line->Type==LINE_TEXT)
						{
							GetLineText(Line,LineBuf,LIN_SIZ);
							DumpMsg(LineBuf);
						}
						else if(Line->Type==LINE_BRUSH)
						{
							DumpMsg("BRUSH");
						}
						else if(Line->Type==LINE_BOX)
						{
							DumpMsg("BOX");
						}
						else if(Line->Type==LINE_DRAW)
						{
							DumpMsg("DRAW");
						}
						else
						{
							DumpUDecB("Bad Line Type!",Line->Type," \\");
							Line->Type=LINE_TEXT; // SHould check for brush types??
						}
#endif
						if(Line->Type>=LINE_NON_EXISTANT) // Weird bug somewhere else (ReplaceID)
							Line->Type=LINE_TEXT;  // !!! Fixed here w/ this fugly kludge
						Remove(node);
						AddTail((struct List *)DstList,node);
					}
					CopyMem(&(Page->Type),&(NewPage->Type),sizeof(struct CGPage) - sizeof(struct MinList) );
					C++;
					R->PageNumber=B;
					R->CurrentPage = NewPage;
				}
			}
		}
	 	FreeMem(NewBook,sizeof(struct CGBook));
		R->UpdatePage = UPDATE_PAGE_NEW;
		NewCurrentPage();
	}
	DisplayNormalSprite();
	NewUpdateMessage(PageCmdsMsg);
	return(C);
}

void CheckLines(struct CGPage *Page)
{
	struct MinList *DstList=&(Page->LineList);
	struct CGLine *Line;
	struct Node *node,*nextnode;
	UBYTE i=0;
	for(node=(struct Node *)(DstList->mlh_Head),nextnode=node; nextnode=nextnode->ln_Succ; node=nextnode)
	{
		Line=(struct CGLine *)node;
		DumpUDecB("Line # ",i++,":	");
		if(Line->Type==LINE_TEXT)
		{
			GetLineText(Line,LineBuf,LIN_SIZ);
			DumpMsg(LineBuf);
		}
		else if(Line->Type==LINE_BRUSH)
		{
			DumpMsg("BRUSH");
		}
		else if(Line->Type==LINE_BOX)
		{
			DumpMsg("BOX");
		}
		else if(Line->Type==LINE_DRAW)
		{
			DumpMsg("DRAW");
		}
		else
		{
			DumpUDecB("Bad Line Type! ",Line->Type," \\");
		}
	}
}

void CheckBook(struct CGBook *Book)
{
	UBYTE A;
	struct CGPage *Page = &Book->Page[0];

	for (A=0; A < PAGES_PER_BOOK; A++,Page++)
	{
		DumpUDecB("	Page # ",A,":	\\");
		CheckLines(Page);
	}
}

//*******************************************************************
char *ReplaceData(
	struct LineData *Data)
{
	char *Message[2],*C;
	struct RenderData *R;
	UWORD Type,H;

	R = RD;
	Message[0] = GenericMsg1;
	Message[1] = GenericMsg2;

	if (R->LastError == CG_ERROR_OPEN_LIBRARY) 
	{
		strcpy(GenericMsg1,FontOpenLib);
		if (R->AdditionalError) strcat(GenericMsg1,R->AdditionalError);
		strcat(GenericMsg1,FontOpen2);
	} else if (R->LastError == CG_ERROR_ANY_MEMORY)
		strcpy(GenericMsg1,FontMemMsg);
	else
		strcpy(GenericMsg1,MsgFind);

	if( (Data->Type == LINE_TEXT)||(Data->Type == LINE_TEXT) ) C = MsgFont;
	else C = MsgBrush;
	if (Data->FileName) strcat(GenericMsg1,Data->FileName);
	strcpy(GenericMsg2,MsgReplace);
	strcat(GenericMsg2,C);
	strcat(GenericMsg2,"?");

	if (!CGMultiRequest(Message,2,REQ_H_CENTER|REQ_OK_CANCEL|REQ_CENTER))
		return(NULL);

	Prompt[PROMPT_APPEND] = 0;
	if (Data->FileName)
		strcpy(&Prompt[PROMPT_APPEND],GetJustFile(Data->FileName));
	DefFileName[0] = 0;
	ChangeDataDir(Data);
	C = BrushPath;
	if (Data->Type == LINE_TEXT) C = FontsPath;
	if (C = FileRequest(Prompt,DefFileName,C))
	{
		Type = GetFontDiskType(C);
		H = DEFAULT_OUTLINE_HEIGHT;
		if (Data->Height != ANY_HEIGHT) H = Data->Height;
		Data->Height = ANY_HEIGHT;
		if ((Type == FONT_TYPE_BULLET) || (Type == FONT_TYPE_PS)) 
		{
			if (H = PromptFontHeight(C,H)) Data->Height = H;
		}
	}
	R->UpdateInterface = TRUE;
	return(C);
}

//*******************************************************************
VOID __asm ChangeDataDir(
	register __a0 struct LineData *Data)
{
	struct RenderData *R;

	R = RD;
	if (Data) {
		switch (Data->Type) {
		case LINE_TEXT:
			CurrentDir(R->FontLock);
			break;
		case LINE_BRUSH:
		case LINE_DRAW:
			CurrentDir(R->ToasterRoot);
		}
	}
}

//*******************************************************************
// pre-render fonts which need it
// recalculate brush dimensions (in case brush size changed since book save)
//
BOOL __asm PreRenderPage(
	register __a0 struct CGPage *Page,
	register __a1 struct Window *NoticeW)
{
	struct CGLine *Line,*Next;
	UWORD C,L;
	struct Attributes *Attr;
	struct TextInfo *Text;
	BOOL PreRender,Success = TRUE;
	struct LineData *Data;
	struct ToasterFont *Font;
	struct KenByteMap *BM;
	char *S;
	struct RenderData *R;

	R = RD;
	if (R->MenuBarWindow) {
		DisplayWaitSprite();
		S = R->StatusMessage;
		NewUpdateMessage(PreRenderMsg);
		R->StatusMessage = S;
		R->UpdateInterface = TRUE;
	}
	Line = (struct CGLine *)Page->LineList.mlh_Head;
	PreRender = FALSE;
	while (Next = (struct CGLine *)Line->Node.mln_Succ) {
		Text = &Line->Text[0];
		if (Line->Type == LINE_BRUSH) {
			Data = GetData(Text->Attr->ID);
			BM = &((struct Picture *)Data->Data)->RGB;
			R->CurrentPage = Page;
			SetBoxSize(Page,Line,BM->BytesPerRow,BM->Rows);

		} else if (Line->Type == LINE_TEXT) {
		L = TextInfoLength(Text);
		for (C=0; C < L; C++) {
			if (Text->Attr) {
				Attr = Text->Attr;
				PreRender = FALSE;
				if ((Data = GetData(Attr->ID)) && (Data->Type == LINE_TEXT))
					if (Font=(struct ToasterFont *)Data->Data)
						PreRender = Font->PreRender;
			}
			if ((PreRender) && (Font->GetCharAlpha)) {
			if (Font->GetCharAlpha(Font,NULL,Text->Ascii) < CHAR_INFO_NOT_IN_FONT){
				Success = FALSE;
				goto Exit;
			}
			if (NoticeW && (CheckNoticeCancel(NoticeW))) {
				Success = FALSE;
				goto Exit;
			}
			}
			Text++;
		}
		}
		Line = Next;
	}
Exit:
	if (R->MenuBarWindow) DisplayNormalSprite();
	return(Success);
}

//*******************************************************************
BOOL  __asm DataInPage(
	register __a0 struct CGPage *Page,
  register __d0 UWORD ID)
{
	struct CGLine *Line,*Next;
	UWORD C,L;
	struct Attributes *Attr;
	struct TextInfo *Text;
	struct LineData *Data,*Got;

  Line = (struct CGLine *)Page->LineList.mlh_Head;
	while (Next = (struct CGLine *)Line->Node.mln_Succ)
  {
		Text = &Line->Text[0];
		if(Line->Type == LINE_BRUSH)
    {
			if( Text->Attr->ID == ID ) return(TRUE);
		}
		else if(Line->Type == LINE_DRAW)
    {
			if( Text->Attr->ID == ID ) return(TRUE);
			else
			{		// Include fonts for DRAW lines
				Data=GetData(ID);
				Got=GetDataFromFileName(&(RD->CurrentBook->DataList),Data->FileName,ANY_HEIGHT);
				if(Data==Got) return(TRUE);
			}
		}
    else if (Line->Type == LINE_TEXT)
    {
			L = TextInfoLength(Text);
			for (C=0; C < L; C++,Text++)
				if (Attr =Text->Attr)
					if ( Attr->ID == ID )  return(TRUE);
		}
		Line = Next;
	}
	return(FALSE);
}

//*******************************************************************
BOOL __regargs PreRenderBook(
	struct CGBook *Book)
{
	struct CGPage *Page;
	UWORD A;
	BOOL Success = FALSE;
	struct Window *Window;
	char *Mess[2];
	struct RenderData *R;
	// char Buff[30];

	R = RD;
	Mess[0] = PrepareNoticeMsg;
	Mess[1] = Prepare2Msg;
	Window = OpenNoticeWindow(Mess,2,TRUE);
	Page = &Book->Page[0];
	for (A = 0; A < PAGES_PER_BOOK; A++) {
		if (Window) {
			stcu_d(&Prepare2Msg[16],A);
			UpdateNotice(Window,Prepare2Msg,1);
		}
		R->PageNumber = A;
		NewCurrentPage();
		if (!R->PageBuffered)
			if (!PreRenderPage(Page,Window)) {
/*
				strcpy(Buff,"PageErr");
				stci_d(&Buff[7],A);
				Mess[0] = Buff;
				Mess[1] = PSMess;
				CGMultiRequest(Mess,2,REQ_H_CENTER|REQ_CENTER);
*/
				goto Exit;
			}
		Page++;
	}
	Success = TRUE;
Exit:
	if (Window) CloseNoticeWindow(Window);
	return(Success);
}

//*******************************************************************
BOOL __regargs ReadFileSize(
	struct LineData *Data)
{
	BOOL Success = FALSE;
	BPTR L;
	struct FileInfoBlock *FIB;

	if ((Data->Type == LINE_TEXT) || (Data->Type == LINE_BRUSH)) {
		ChangeDataDir(Data);
		if (FIB = AllocDosObject(DOS_FIB,NULL)) {
			if (L = Lock(Data->FileName,MODE_OLDFILE)) {
				if (Examine(L,FIB)) {
					Data->DiskSize = FIB->fib_Size;
					Success = TRUE;
				}
				UnLock(L);
			}
			FreeDosObject(DOS_FIB,FIB);
		}
	}
	return(Success);
}

//*******************************************************************
// clears flag in preparation for calls to ReplaceID()
//
VOID __regargs ClearReplaceFlag(
	struct CGBook *Book)
{
	struct CGPage *Page;
	struct CGLine *Line,*Next;
	UWORD A;

	Page = &Book->Page[0];
	for (A = 0; A < PAGES_PER_BOOK; A++) {
		Line = (struct CGLine *)Page->LineList.mlh_Head;
		while (Next = (struct CGLine *)Line->Node.mln_Succ) {
			Line->Rendered = FALSE;
			Line = Next;
		}
		Page++;
	}
}

//*******************************************************************
// marks Rendered=TRUE for all instances of ID
//
VOID __regargs MarkBookID(
	struct CGBook *Book,
	UWORD ID)
{
	struct CGPage *Page;
	struct CGLine *Line,*Next;
	UWORD A,B,L;
	struct Attributes *Attr;
	BOOL ThisLine;
	struct TextInfo *Text;

	Page = &Book->Page[0];
	for (A = 0; A < PAGES_PER_BOOK; A++) {
		Line = (struct CGLine *)Page->LineList.mlh_Head;
		while (Next = (struct CGLine *)Line->Node.mln_Succ) {
			Text = &Line->Text[0];
			L = TextInfoLength(Text);
			if (L < 1) L = 1;
			ThisLine = FALSE;
			for (B = 0; B < L; B++) {
				if ((Attr = Text->Attr) && (Attr->ID == ID)) ThisLine = TRUE;
				Text++;
			}
			if (ThisLine) Line->Rendered = TRUE;
			Line = Next;
		}
		Page++;
	}
}

//*******************************************************************
// After everything loaded, check all lines to see if need update
//
VOID __regargs UpdateReplaceBook(
	struct CGBook *Book)
{
	struct CGPage *Page;
	struct CGLine *Line,*Next;
	UWORD A;

	Page = &Book->Page[0];
	for (A = 0; A < PAGES_PER_BOOK; A++) {
		Line = (struct CGLine *)Page->LineList.mlh_Head;
		while (Next = (struct CGLine *)Line->Node.mln_Succ) {
			if (Line->Rendered) {
				SetupNonText(Line);
				UpdateLineHeight(Line);
				JustifyThisLine(Line);
				Line->Rendered = FALSE;
			}
			Line = Next;
		}
		Page++;
	}
}

//*******************************************************************
// If unable to Lock() FileName, try adding "OldFonts/" to beginning
//
VOID __regargs CheckOldFonts(
	struct LineData *Data)
{
	BPTR L;

	CurrentDir(RD->FontLock);
	if (L = Lock(Data->FileName,ACCESS_READ)) {
		UnLock(L);
	} else {
		if (!strchr(Data->FileName,'/')) { // if no directories already in it
			strcpy(Def2File,OldFontPath);
			strcat(Def2File,Data->FileName);
			if (L = Lock(Def2File,ACCESS_READ)) {
				UnLock(L);
				strcpy(Data->FileName,Def2File);
			}
		}
	}
}

// end of NewBook.c
