/* Find the value of the PS Variable FullName, the Font's actual name */
/* Arnie Cachelin Tue Mar 30 21:45:20 1993 */
/* Fri Apr  2 02:23:11 1993 */
#include <dos.h>
#include <exec/exec.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef PROTO_PASS
#include "PSFontName.p"
#endif

#include "PSFont.h"

struct PSFont MyPSF;

/* This prg searches for FullName, the variable FontName should also work for most fonts. */
/* Some fonts I tried (Helvetica-Oblique) had a space where a '-' should have been in FullName, */
/* but the FontName variable was right.  It may be necessary to replace ' ' with '-' in */
/* the name string */

int FileSize(char *file)
{
    BPTR	lock=NULL;
  __aligned struct FileInfoBlock  fib;

  if(lock=Lock(file,SHARED_LOCK))
    if(Examine(lock,&fib))
    {
      UnLock(lock);
      if(fib.fib_DirEntryType<0) // File, not dir
        return(fib.fib_Size);
    }
  if(lock) UnLock(lock);
  return(0);
}

int CharNumber(char *letter,char glyphs[255][CHAR_LEN+1],int pairs)
{ int i=0;
  while( i<pairs && (strncmp(letter,glyphs[i],CHAR_LEN)!=0) ) i++;
  return((i==pairs) ? 0:i);
}

int KernChars(struct PSFont *PSF,int glyf1,int glyf2)
{ int p=0,c=0;
  struct PSKernPair *Pairs;

  if(p=PSF->KernPairs)
    if(Pairs=PSF->pairs)
      while(c<p)
      {
        if( (Pairs[c]).g1==glyf1 )
          if( (Pairs[c]).g2==glyf2 )
            return( (Pairs[c]).dx );
        c++;
      }
  return(0);
}

int LoadMetric(char *file, struct PSFont *PSF)
{
  char  *fname=PSF->Name,buf[256]="", charname[CHAR_LEN+1]="",char2[CHAR_LEN+1]="";
  int lines=0,l=0,c,w,llx,lly,urx,ury;
  struct PSKernPair *Pairs;
  BPTR	fp;
  char (*Glyphs)[31];
 if(Glyphs=AllocMem(255*(CHAR_LEN+1),MEMF_CLEAR))
 {
 	if(fp=Open(file,MODE_OLDFILE))
  {
    while(FGets(fp,buf,255))
    {
     if(strnicmp(buf,"FontName",8)==0) strcpy(fname,&buf[9]);
     if(strnicmp(buf,"StartCharMetrics",16)==0)
     {
       lines=atol(&buf[17]);
       break;
     }
    }
    printf("%s %d\n",fname,lines);
    while(FGets(fp,buf,255) && l<lines)
    {
      if( sscanf(buf,"C %d ; WX %d ; N %s ; B %d %d %d %d ;",
         &c,&w,&charname[0],&llx,&lly,&urx,&ury) != 7) break;
      strncpy(Glyphs[c],charname,CHAR_LEN);
      PSF->llx[c]=llx; PSF->lly[c]=lly;
      PSF->urx[c]=urx; PSF->ury[c]=ury;
      PSF->w[c]=w;
      printf("C %d ; WX %d ; N %s ; B %d %d %d %d ; \n",
              c,PSF->w[c],Glyphs[c],PSF->llx[c],PSF->lly[c],PSF->urx[c],PSF->ury[c]);
      l++;
    }
    l=0; lines=0;
    while(FGets(fp,buf,255))
    {
     if(strnicmp(buf,"StartKernPairs",14)==0)
     {
       lines=atol(&buf[15]);
       break;
     }
    }
    if(lines)
      if(Pairs=AllocMem(sizeof(struct PSKernPair)*(lines+1),MEMF_CLEAR))
      {
        while(FGets(fp,buf,255) && l<lines)
        {
          if( sscanf(buf,"KPX %s %s %d",&charname[0],&char2[0],&w) != 3) break;
          Pairs[l].g1=CharNumber(charname,Glyphs,lines);
          Pairs[l].g2=CharNumber(char2,Glyphs,lines);
          Pairs[l].dx=w;
          printf(buf,"KPX %s %s %d\n",Glyphs[Pairs[l].g1],Glyphs[Pairs[l].g2],Pairs[l].dx);
          l++;
        }
        PSF->KernPairs=lines;
        PSF->pairs=Pairs;
      }
    Close(fp);
    FreeMem(Glyphs,255*(CHAR_LEN+1));
    return(1);
  }
  FreeMem(Glyphs,255*(CHAR_LEN+1));
 }
  return(0);
}

void FindFontName(char *file,char *fname)
{
	BPTR	fp;
  char *B4="/FontName ", End=' ';
  char *fbuf;  // FontName has no spaces
  int B4len=10, matches=0,c=0, i=0,fsiz;
  if(fsiz=FileSize(file))
    if(fbuf=(char *)AllocMem(fsiz,MEMF_CLEAR))
    {
     	if(fp=Open(file,MODE_OLDFILE))
      {
        if(Read(fp,fbuf,fsiz)>0)
        {
          while(i<fsiz)
          {
            if(fbuf[i++]==B4[matches]) matches++;
            else matches=0;
            if(matches==B4len)
              if(fbuf[i]=='(' || fbuf[i]=='/') break;
              else matches=0; // Found premature occurance of "FontName"
          }
          if( fbuf[i]=='(' )  End=')';
          i++;   // Discard '(' or '/' at front of name
          while(fbuf[i]!=End) fname[c++]=fbuf[i++];
        }
        Close(fp);
      }
      FreeMem(fbuf,fsiz);
    }
  return;
}

void FindFullName(char *file,char *fname)
{
	BPTR	fp;
  char *B4="/FullName ", End=')',*ch=fname;
  char *fbuf;
  int B4len=10, matches=0,c=0, i=0,fsiz;
  if(fsiz=FileSize(file))
    if(fbuf=(char *)AllocMem(fsiz,MEMF_CLEAR))
    {
     	if(fp=Open(file,MODE_OLDFILE))
      {
        if(Read(fp,fbuf,fsiz)>0)
        {
          while(i<fsiz && matches<B4len)
            if(fbuf[i++]==B4[matches]) matches++;
            else matches=0;
          if(matches==B4len)  // got a FullName!
          {
            if( fbuf[i]=='/' )  End=' ';  // No spaces allowed if defined with '/'
            i++;   // Discard '(' or '/' at front of name
            while(fbuf[i]!=End) fname[c++]=fbuf[i++];
          }
        }
        Close(fp);
      }
      FreeMem(fbuf,fsiz);
      if(End==')')  // If spaces may be embedded
        while(*ch)   // Replace them with '-'s
        {
          if(*ch==' ') *ch='-';
          ch++;
        }
    }
  return;
}


//*******************************************************************
// Find value of PS variable FullName -- Should be the Font's real name
void xxFindFullName(char *file,char *fname)
{
	BPTR	fp;
  char *B4="/FullName ", End=')', buf,*c=fname;
  int B4len=10, matches=0, i=0, maxread=8192;
 	if(fp=Open(file,MODE_OLDFILE))
  {
    while(matches<B4len && (i+=Read(fp,&buf,1L))>0 && i<maxread) // Check whole file byte by byte..
      if(buf==B4[matches]) matches++;          // Could get away with reading first 2K
      else matches=0;
    i=0;
    if(matches==B4len)
    {
      Read(fp,&buf,1L);  // Discard '(' or '/' at front of name
      if( buf=='/' )  End=' ';  // if FullName is delimited by /, it can't have spaces
      while(Read(fp,&buf,1L)>0)
      {
        if(buf==End) break;
        fname[i++]=buf;
      }
    }
    Close(fp);
    while(*c)
    {
      if(*c==' ') *c='-';
      c++;
    }
  }
  return;
}



//*******************************************************************
// Find value of PS variable FontName -- May be there if FullName search fails
// the actual name will either be  /name or (name), no spaces included (i assume)
void xxFindFontName(char *file,char *fname)
{
	BPTR	fp;
  char *B4="/FontName ", End=' ', buf;  // FontName has no spaces
  int B4len=10, matches=0, i=0,maxread=8192;
 	if(fp=Open(file,MODE_OLDFILE))
  {
    while(matches<B4len && (i+=Read(fp,&buf,1L))>0 && i<maxread) // Doing one char reads is weak
      if(buf==B4[matches]) matches++;
      else matches=0;
    Read(fp,&buf,1L);  // Discard '(' or '/' at front of name
    i=0;
    if( buf=='(' )  End=')';
    if(matches==B4len)
      while(Read(fp,&buf,1L)>0)
      {
        if(buf==End) break;
        fname[i++]=buf;
      }
    Close(fp);
  }
  return;
}

//*******************************************************************

BOOL IsPSFont(char *file)
{
	BPTR	fp;
  char *B4="%!PS-Adobe", buf[32]="";
  int count=12,ch=0, i=0, matches=2; // Require only "%!"
 	if(fp=Open(file,MODE_OLDFILE))
  {
    if (Read(fp,&buf,32L)>0)
      while(i<count && ch<matches )
        if(buf[i++]==B4[ch]) ch++;
        else ch=0;
    Close(fp);
  }
  return((BOOL) ((ch==matches) ? TRUE:FALSE) );
}

BOOL IsMacPSFont(char *file)
{
	BPTR	fp;
  char *B4="%!PS-Adobe", buf[385]="";
  int count=12,ch=0, i=0, matches=2; // Require only "%!"
 	if(fp=Open(file,MODE_OLDFILE))
  {
    Read(fp,&buf,384L);  // Throw away trash
    if (Read(fp,&buf,32L)>0)
      while(i<count && ch<matches )
        if(buf[i++]==B4[ch]) ch++;
        else ch=0;
    Close(fp);
  }
  return((BOOL) ((ch==matches) ? TRUE:FALSE) );
}

int ConvMacPSFont(char *file, char *outfile)   // Doesn't work...
{
	BPTR	fp,out;
  char buf[391]="";
  int count=12,i=0; // Require only "%!"
 	if(fp=Open(file,MODE_OLDFILE))
   	if(out=Open(outfile,MODE_NEWFILE))
    {
      Read(fp,&buf,390L);  // Throw away trash
      count=Read(fp,&buf,256L);
      while(count>0)
      { i+=count;
        Write(out,&buf,count);
        count=Read(fp,&buf,256L);
      }
      Close(out);
    }
  if(fp) Close(fp);
  return(i);
}

main(int argc, char ** argv)
{
  char font[102]="",full[102]="", filename[102];
  int l;
  if(argc<2)
  {
    printf("C'mon, how bout a file name douchebag\n");
    exit(10);
  }
  strcpy(filename,argv[1]);
  printf("File %s is %d bytes long.\n",argv[1],FileSize(argv[1]) );
  if(IsPSFont(argv[1]))
  {
    printf("It Looks like %s is a PS Font\n",argv[1]);
    l=strlen(filename);
    if(stricmp(&(filename[l-4]),".PFB")==0) // Replace .pfb in filename with .afm
    {
      strcpy(&(filename[l-4]),".AFM");
      if(FileSize(filename)) LoadMetric(filename,&MyPSF);
    }
    else  // No .PFB, try just appending .AFM on filename
    {
      strcat(filename,".AFM");
      if(FileSize(filename)) LoadMetric(filename,&MyPSF);
    }
  }
  else if(IsMacPSFont(argv[1]))
    printf("It Looks like %s is a MacBinary PS Font\n",argv[1]);
  else
  {
    printf("I'm sorry, %s is not a PS Font\n",argv[1]);
    exit(0);
  }
  FindFullName(argv[1],full);
  if(*full) printf("The Font has a FullName of '%s'\n",full);
  else printf("The Font has no FullName\n");

  FindFontName(argv[1],font);
  if(*font) printf("The Font has a FontName of '%s'\n",font);
  else printf("The Font has no FontName\n");
  l=KernChars(&MyPSF,'T','o');
  printf("Kern Time: \n\t Kern %c and %c with %d\n",'T','o',l);

  if (MyPSF.pairs && MyPSF.KernPairs)
    FreeMem(MyPSF.pairs,sizeof(struct PSKernPair)*(MyPSF.KernPairs+1));
  exit(0);
}
