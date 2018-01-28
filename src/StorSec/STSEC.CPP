#include <dos.h>
#include <sys\stat.h>
#include <bios.h>
#include <conio.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <mem.h>
#include <string.h>
#include <io.h>
#include <fcntl.h>
#include  <dir.h>

#include  "dtypes.h"
#include  "detect.h"


/*struct tag_Placing {
   BYTE	bDrv;
   WORD	bCyl, bSec, bHead;
 } Placing;

int DetectPlacing(char* pFilePatch, WORD* pTrack, WORD* pSec, WORD* pHead, WORD* pDrv )
*/

char cMode = 0;
char cCurrPatch[ _MAX_PATH + 1 ];
char* cDistributeFiles[] =
 {
   FNAME_FBOOT, //первичный загрузчик
   FNAME_SBOOT, //вторичный загрузчик
   0
 };

char* cSysFiles[] =
 {
   FNAME_ORIGBOOT, //исходный загрузчик (сохранённый загр. сектор)
   0
 };

void Welcome();
char* ParseParams( /*[out]*/Placing*, WORD* piDrv, WORD* piTrack, WORD* piSec, WORD* piHead, WORD* piCountOfSec, char* pcOutFile, int argc, char **argv );
int AcceptParamsS( WORD iDrv, WORD iTrack, WORD iSec, WORD iHead, WORD iCountOfSec, char* cOutFile );
int AcceptParamsI( /*[in]*/Placing*, char* cOutFile );
int AcceptParamsU( /*[in]*/Placing*, char* cOutFile );
void DetectStartupPatch( char*, char* );

int DoS( WORD iDrv, WORD iTrack, WORD iSec, WORD iHead, WORD iCountOfSec, char* cOutFile );
int DoI( /*[in]*/Placing*, char* cCurrP, char* cOutFile );
int DoU( /*[in]*/Placing*, char* cCurrP, char* cOutFile );

void AddLastSlash( char* );

char* ParseS( WORD* piDrv, WORD* piTrack, WORD* piSec, WORD* piHead, WORD* piCountOfSec, char* pcOutFile, int argc, char **argv );
char* ParseI( /*[out]*/Placing*, char* pcOutFile, int argc, char **argv );

int CheckMyFiles( char*, char** );
int IsInstalled( /*[in]*/Placing* );


int CopyFileFromTo( char* pFrom, char* pTo );

int main( int argc, char *argv[] )
 {
   WORD iDrv, iTrack, iSec, iHead, iCountOfSec;
   char cOutFile[ _MAX_PATH + 1 ];
   char *pRes;
   Placing placing;

   DetectStartupPatch( argv[0], cCurrPatch );

   Welcome();
   pRes = ParseParams( &placing, &iDrv, &iTrack, &iSec, &iHead, &iCountOfSec, cOutFile, argc, argv );
   if( pRes )
    {
      printf( "Bad param: %s\n\n"
	"Usage:\n"
	"\t\tstsec.com /s drive track sec head count_OF_sec \"outFile\"\n"
	"Where:\n"
	"\t\tdrive:  	0 - 3 OR 128 - 131\n"
	"\t\ttrack:  	0 - 1023\n"
	"\t\tsec:    	1 - 63\n"
	"\t\thead:   	0 - 255\n\n"
	"Example:\n"
	"\t\tstsec.com /s 0x80 0 1 0 1 \"e:\\bsec.bin\"\n\n"
	"----- OR\n"
	"\t\tstsec.com /i patch_to_install\n\n"
	"----- OR\n"
	"\t\tstsec.com /u patch_from_uninstall\n", pRes );

      return -1;
    }

   switch( cMode )
    {
      case 'S': //store sectors
	if( !AcceptParamsS(iDrv, iTrack, iSec, iHead, iCountOfSec, cOutFile) ) return 0;
	return DoS( iDrv, iTrack, iSec, iHead, iCountOfSec, cOutFile );
      case 'I': //install
	if( !AcceptParamsI(&placing, cOutFile) ) return 0;
	return DoI( &placing, cCurrPatch, cOutFile );
      case 'U': //uninstall
	if( !AcceptParamsU(&placing, cOutFile) ) return 0;
	return DoU( &placing, cCurrPatch, cOutFile );
      default:
	return -2;
    }

 }

void Welcome()
 {
   printf( "\n(c)AlexCorp. 1999. Ultrabooter install\n\n" );
 }

char* ParseParams( Placing* pPl, WORD* piDrv, WORD* piTrack, WORD* piSec, WORD* piHead, WORD* piCountOfSec, char* pcOutFile, int argc, char **argv )
 {
   if( argc < 2 )
     return "Bad number of parameters";

   if( *argv[1] != '/' || strlen(argv[1]) !=2 )
     return "Bad format of first param";

   switch( toupper(argv[1][1]) )
    {
      case 'S':
	cMode = 'S';
	return ParseS( piDrv, piTrack, piSec, piHead, piCountOfSec, pcOutFile, argc, argv );

      case 'I':
	cMode = 'I';
	return ParseI( pPl, pcOutFile, argc, argv );

      case 'U':
	cMode = 'U';
	//return ParseU();
	return ParseI( pPl, pcOutFile, argc, argv );

      default:
	return "Not allowed key: none of /i , /s, /u";
    }
 }

int AcceptParamsS( WORD iDrv, WORD iTrack, WORD iSec, WORD iHead, WORD iCountOfSec, char* cOutFile )
 {
   printf( "The parameters are:\n"
	   "\tdrive:\t\t%xh\n"
	   "\ttrack:\t\t%u\n"
	   "\tsector:\t\t%u\n"
	   "\thead:\t\t%u\n"
	   "\tcount:\t\t%u\n"
	   "\tfile name:\t\t%s\n\n"
	   "It is correct (Y/N) ?>",
	iDrv, iTrack, iSec, iHead, iCountOfSec, cOutFile );
   int c = getch();
   if( c == 'Y' || c == 'y' ) return 1;
   return 0;
 }


char* ParseS( WORD* piDrv, WORD* piTrack, WORD* piSec, WORD* piHead, WORD* piCountOfSec, char* pcOutFile, int argc, char **argv )
 {
   if( argc != 8 )
     return "Bad number of parameters: need 7";

   if( sscanf(argv[2], "%u", piDrv) != 1 || !(*piDrv >= 0 && *piDrv <= 3 || *piDrv >= 0x80 && *piDrv <= 0x83) )
     return "Incorrect 'drive'";

   if( sscanf(argv[3], "%u", piTrack) != 1 || !(*piTrack >= 0 && *piTrack <= 1023) )
     return "Incorrect 'track'";

   if( sscanf(argv[4], "%u", piSec) != 1 || !(*piSec >= 1 && *piSec <= 63) )
     return "Incorrect 'sector'";

   if( sscanf(argv[5], "%u", piHead) != 1 || !(*piHead >= 0 && *piHead <= 255) )
     return "Incorrect 'head'";

   if( sscanf(argv[6], "%u", piCountOfSec) != 1 || !(*piCountOfSec > 0) )
     return "Incorrect 'count of sectors'";

   if( sscanf(argv[7], "%s", pcOutFile) != 1 || strlen(pcOutFile) == 0 )
     return "Incorrect 'out file name'";

   return NULL;
 }

char* ParseI( Placing* pPl, char* pcOutFile, int argc, char **argv )
 {
   if( argc != 3 )
     return "Bad number of parameters: need 2";

    char cDrive[ MAXDRIVE ], cDir[ MAXDIR ],
	 cName[ MAXFILE ], cExt[ MAXEXT ];

    _splitpath( argv[2], cDrive, cDir, cName, cExt );

    if( strlen(cExt) || strlen(cName) || !strlen(cDrive) )
      return  "Bad patch: specify disk 'C:' or patch 'C:\\dir\\'";

    _makepath( pcOutFile, cDrive, cDir, "", "" );
    AddLastSlash( pcOutFile );


    int iRes = DetectPlacing( pcOutFile, pPl );

    if( iRes == -1 )
      return "System error";
    else if( iRes == -2 )
      return "Can't use this drive";

    return NULL;
 }

int AcceptParamsI( Placing* pPl, char* cOutFile )
 {
   printf( "The parameters are:\n"
	   "\tdrive:\t\t%xh\n"
	   "\tcyl:\t\t%xh\n"
	   "\tsec:\t\t%xh\n"
	   "\thead:\t\t%xh\n"
	   "\tpatch to install:\t%s\n"
	   "It is correct (Y/N) ?>",
	   pPl->wDrv, pPl->wCyl, pPl->wSec, pPl->wHead, cOutFile );
   int c = getch();
   if( c == 'Y' || c == 'y' ) return 1;
   return 0;
 }
int AcceptParamsU( Placing* pPl, char* cOutFile )
 {
   printf( "The parameters are:\n"
	   "\tdrive:\t\t%xh\n"
	   "\tcyl:\t\t%xh\n"
	   "\tsec:\t\t%xh\n"
	   "\thead:\t\t%xh\n"
	   "\tpatch to uninstall:\t%s\n"
	   "It is correct (Y/N) ?>",
	   pPl->wDrv, pPl->wCyl, pPl->wSec, pPl->wHead, cOutFile );
   int c = getch();
   if( c == 'Y' || c == 'y' ) return 1;
   return 0;
 }
void DetectStartupPatch( char* pArg, char* cP )
 {
   char cDrive[ MAXDRIVE ], cDir[ MAXDIR ],
	 cName[ MAXFILE ], cExt[ MAXEXT ];

    _splitpath( pArg, cDrive, cDir, cName, cExt );
    _makepath( cP, cDrive, cDir, "", "" );
    AddLastSlash( cP );
 }

int DoS( WORD iDrv, WORD iTrack, WORD iSec, WORD iHead, WORD iCountOfSec, char* cOutFile )
 {
   DWORD ulTS = SEC_SIZE * (DWORD)iCountOfSec;

   char *pBuf = (char*)calloc( ulTS, 1 );
   if( !pBuf )
    {
      printf( "No memory\n" );
      return -1;
    }
    //iDrv = 0x80, iHead = 0, iTrack = 0, iSec = 1, iCountOfSec = 2;
   WORD uiR = biosdisk(_DISK_READ, iDrv, iHead, iTrack, iSec, iCountOfSec, pBuf);
   if( (uiR&0xFF00) )
    {
      free( pBuf );
      printf( "Read error\n" );
      return -1;
    }

   int hFile = open( cOutFile, O_RDWR|O_CREAT|O_TRUNC|O_BINARY, S_IREAD|S_IWRITE );
   if( hFile == -1 )
    {
      free( pBuf );
      printf( "Can't open: %s\n", cOutFile );
      return -1;
    }
   if( write( hFile, pBuf, ulTS ) != ulTS )
    {
      free( pBuf );
      close( hFile );
      printf( "Storing is unsuccessful\n" );
      return -1;
    }

   free( pBuf );
   close( hFile );
   printf( "\nStoring is OK\n" );

   return 0;
 }

int DoI( Placing* pPl, char* cCurrP, char* cOutFile )
 {
    printf( "\n" );
    if( !CheckMyFiles(cCurrP, cDistributeFiles) ) return -1;
    long iRes = IsInstalled( pPl );
    if( iRes == -1 ) return -1;
    if( iRes )
     {
       printf( "The Ultrabooter is already installed on device: %xh\n",
	 (int)pPl->wDrv );
       return -2;
     }

    char cSBName[ _MAX_PATH + 1 ];
    strcpy( cSBName, cCurrP );
    strcat( cSBName, FNAME_SBOOT );

    size_t szSB =  FNAME_SBOOT_SECTORS * SEC_SIZE;
	       //kkkkkkkkkkk
    char *pBuf = (char*)calloc( szSB, 1 );

    WORD uiR = biosdisk( _DISK_READ, pPl->wDrv, 0, 0, 1, 1, pBuf );
    if( (uiR&0xFF00) )
     {
       free( pBuf );
       printf( "Read error of boot sector\n" );
       return -1;
     }

    uiR = biosdisk( _DISK_WRITE, pPl->wDrv, pPl->wHead, pPl->wCyl, pPl->wSec, 1, pBuf );
    if( (uiR&0xFF00) )
     {
       free( pBuf );
       printf( "Store error of boot sector\n" );
       return -1;
     }

    printf( "Store of boot sector OK\n" );
    int hFile = open( cSBName, O_RDONLY|O_BINARY );
    if( hFile == -1 )
     {
       free( pBuf );
       printf( "Can't read '%s'\n", cSBName );
       return -1;
     }

    long lPos = lseek( hFile, 0, SEEK_END );
    if( lPos == -1 )
    {
      free( pBuf );
      close( hFile );
      printf( "Can't seek: %s\n", cSBName );
      return 0;
    }
    lseek( hFile, 0, SEEK_SET );

    iRes = read( hFile, pBuf, lPos );
    if( iRes != lPos )
     {
       close( hFile );
       free( pBuf );
       printf( "Can't read: %s\n", cSBName );
       return -1;
     }
   close( hFile );

    uiR = biosdisk( _DISK_WRITE,
      pPl->wDrv,
      pPl->wHead,
      pPl->wCyl,
      pPl->wSec + 1,
      FNAME_SBOOT_SECTORS,
      pBuf );

    if( (uiR&0xFF00) )
     {
       free( pBuf );
       printf( "Can't write secondary booter\n" );
       return -1;
     }

    uiR = biosdisk( _DISK_READ, pPl->wDrv, 0, 0, 1, 1, pBuf );
    if( (uiR&0xFF00) )
     {
       free( pBuf );
       printf( "Read error of boot sector\n" );
       return -1;
     }

    strcpy( cSBName, cCurrP );
    strcat( cSBName, FNAME_FBOOT );
    hFile = open( cSBName, O_RDONLY|O_BINARY );
    if( hFile == -1 )
     {
       free( pBuf );
       printf( "Can't read '%s'\n", cSBName );
       return -1;
     }

    char cBufFB[ SEC_SIZE ];
    iRes = read( hFile, cBufFB, SEC_SIZE );
    close( hFile );
    if( iRes != SEC_SIZE )
     {
       free( pBuf );
       printf( "Can't read: %s\n", cSBName );
       return -1;
     }


    memcpy( cBufFB + 3, pBuf + 3, 59 ); //скопировать область параметров
    memcpy( cBufFB + 0x1BE, pBuf + 0x1BE, 64 ); //скопировать таблицу разделов

    free( pBuf );


    FBHdr *pHdr = (FBHdr*)cBufFB;
    pHdr->bBootDevice =  pPl->wDrv;

    pHdr->wCylSec_SBoot = MAKE_CS( pPl->wCyl, pPl->wSec + 1 );
    pHdr->bHead_SBoot = pPl->wHead;
    pHdr->bNSectors_SBoot = FNAME_SBOOT_SECTORS;

    pHdr->wCylSec_OBoot = MAKE_CS( pPl->wCyl, pPl->wSec );
    pHdr->bHead_OBoot = pPl->wHead;
    pHdr->bNSectors_OBoot = 1;

    uiR = biosdisk( _DISK_WRITE, pPl->wDrv, 0, 0, 1, 1, cBufFB );
    if( (uiR&0xFF00) )
     {
       printf( "Error of writing of new boot sector\n" );
       return -1;
     }

    return 0;
 }


int DoU( Placing* pPl, char* cCurrP, char* cOutFile )
 {
    printf( "\n" );
    //if( !CheckMyFiles(cOutFile, cSysFiles) ) return -1;
    int iRes = IsInstalled( pPl );
    if( iRes == -1 ) return -1;
    if( !iRes )
     {
       printf( "Ultrabooter is not installed on device: %xh\n",
	 (int)pPl->wDrv );
       return -2;
     }

    char cBuf[ SEC_SIZE + 2 ];

    WORD uiR = biosdisk( _DISK_READ,
      pPl->wDrv,
      pPl->wHead,
      pPl->wCyl,
      pPl->wSec, 1, cBuf );

    if( (uiR&0xFF00) )
     {
       printf( "Read error of stored boot sector\n" );
       return -1;
     }

    uiR = biosdisk( _DISK_WRITE,
      pPl->wDrv,
      0,
      0,
      1, 1, cBuf );

    if( (uiR&0xFF00) )
     {
       printf( "Write error of boot sector\n" );
       return -1;
     }

    return 0;
 }

void AddLastSlash( char* pC )
 {
   size_t sz = strlen( pC );
   if( sz == 0 ) return;
   if( pC[sz - 1] != '\\' )
     strcat( pC, "\\" );
 }

int CheckMyFiles( char* pP, char** pWhat )
 {
   char cTName[ _MAX_PATH + 1 ];
   strcpy( cTName, pP );
   char *pLast = cTName + strlen( cTName );
   for( int i = 0; pWhat[ i ]; ++i )
     {
       strcpy( pLast, pWhat[ i ] );
       if( open(cTName, O_RDONLY|O_BINARY) == -1 )
	{
	  printf( "Missing file: '%s'\n", cTName );
	  return 0;
	}
     }

   return 1;
 }

int IsInstalled( Placing* pPl )
 {
    WORD wNSect = 1;
    size_t sz = (size_t)wNSect * SEC_SIZE;

    char *pBuf = (char*)calloc( sz, 1 );
    WORD uiR = biosdisk(_DISK_READ, pPl->wDrv, 0, 0, 1, wNSect, pBuf );

    if( (uiR&0xFF00) )
     {
       free( pBuf );
       printf( "Can't check installed: read error\n" );
       return -1;
     }
   FBHdr *pHdr = (FBHdr*)pBuf;
   int iCmp = memcmp( pHdr->abSign, SIGN_CONTENT, strlen(SIGN_CONTENT) );
   free( pBuf );
   return iCmp == 0 ? 1:0;
 }
