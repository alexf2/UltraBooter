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

#include <stdio.h>
#include <process.h>
#include <dos.h>

#include "detect.h"

BYTE IsHDDorFloppy( BYTE bDrv )
//RETURN:
//	0 - Floppy
//	1 - HDD
 {
   if( bDrv >= 0 && bDrv <= 3 ) return 0;
   return 1;
 }


int DetectPlacing( /*[in]*/char* pFilePatch, /*[content out]*/Placing* pPl )
//RETURN:
//	-1 - system error
//	-2 - too small trcak
//	 0 - OK
 {
   WORD wDOSDrv = toupper(pFilePatch[ 0 ]) - 'A';

   DPB far* pDPB = NULL;

   asm {
      pushf
      push	ds

      mov	ah, 32h //������� Drive Parameter Block
      mov	dl, wDOSDrv
      inc	dl
      int	21h
      cmp	al, 0FFh
      jz	L_BPBErr_DetectPlacing

      mov	word ptr pDPB, bx
      mov	word ptr pDPB + 2, ds
    }
L_BPBErr_DetectPlacing:
   asm {
      pop	ds
      popf
   }

   if( !pDPB ) return -1;

   pPl->wSecSize = pDPB->wSectSize;

   WORD wNSecs, wBufSize;
   if( pPl->wSecSize == 256 )
     wNSecs = 2, wBufSize = 512;
   else
     wNSecs = 1, wBufSize = pPl->wSecSize;

   BYTE* pSector = (BYTE*)malloc( wBufSize );
   if( !pSector ) return -1;
   if( absread(wDOSDrv, wNSecs, 0, pSector) )
    {
      free( pSector );
      return -1;
    }

   BPB_ *p = (BPB_*)pSector;


//��ࠢ��� ��� ���ன�⢠ ��� ������� ��᪠ (⠪ ��� � ����㧮筮� ����� ������� ��᪠ �ᥣ�� DrvNo=0)
   BYTE bTmp;
   if( p->bDrvNo == 0 && wDOSDrv !=0 )
     bTmp = pPl->wDrv = wDOSDrv;
   else
     bTmp = pPl->wDrv = p->bDrvNo;


   //DriveParams far* pDP;
   WORD wCS;

   asm {
      pushf
      push	es

      mov	ah, 8h	//������� ��ࠬ���� ��᪠
      mov	dl, bTmp
      int	13h
      jc        L_ErrGetPD_DetectPlacing
      mov       wCS, cx	//max �᫮ ᥪ�஢ � 樫���஢ � �ଠ� Int13h
      jmp       L_OK_GetPD_DetectPlacing
   }
L_ErrGetPD_DetectPlacing:
    asm {
      mov       wCS, 0
    }

L_OK_GetPD_DetectPlacing:
    asm {
      pop	es
      popf
    }

   if( !wCS ) { free( pSector ); return -1; }

//� ��砥 ������� ��᪠ ��� ࠧ��饭�� �롨ࠥ� �������� 樫����
//� ��砥 ���⪮�� - ᢮������ ���� �� ��஦�� �ࠧ� �� ����㧮�� ᥪ�஬
//
   if( p->wSecPerTrk * p->wHeads < FNAME_SBOOT_SECTORS + 1 )
    {
      //�� 墠⠥� ������ 樫���� ��� ࠧ��饭�� �����稪� � ��ண� ᥪ��
      //���室 樫���� ��� ������� ��᪠ �� ��ࠡ��뢠��
      free( pSector );
      return -2;
    }

   if( (pPl->bDeviceFlag = IsHDDorFloppy(pPl->wDrv)) == 0 )
    {
      pPl->wCyl = GET_TRACK(wCS) + 1;
      pPl->wSec = 1;
      pPl->wHead = 0;
    }
   else //HDD
    {
      if( p->lHidSects < FNAME_SBOOT_SECTORS + 2 )
       {
	  //�᫮ ������ ᥪ�஢ �� �⠭���⭮� �ଠ�஢���� ��⠭���������� ��� ���⪮�� ��᪠
	 //� �᫮ ᥪ�஢ �� ��஦��, ⠪ ��� � 0,0,1 (��� MBR) �� �⮬
	 //१�ࢨ����� ��� ��஦��, � ࠧ��� ��稭����� � ������� 1
	 //��� �ॡ����, �⮡� �ଠ�஢���� �뫮 �⠭�����
	 free( pSector );
	 return -2;
       }
      pPl->wCyl = 0;
      pPl->wSec = 2; //������� �ࠧ� �� MBR
      pPl->wHead = 0;
    }

   free( pSector );
   return 0;
 }


int DetectDevice( char* pFilePatch )
 {
   WORD wDOSDrv = toupper(pFilePatch[ 0 ]) - 'A';
   BYTE bSector[ SEC_SIZE + 2 ];
   if( absread(wDOSDrv, 1, 0, bSector) )
     return -1;

   BPB_ *p = (BPB_*)bSector;
   return p->bDrvNo;
 }

//�� ��楤�� �� �ᯮ������ � ������ ॠ����樨
//����⪠ ��।����� 䨧. ��������� 䠩�� �� ��� ����� � DOS 7.10
int DetectPhysPlace( BYTE iDrv, char* fName, WORD* pwSecSB, WORD* pwCylSB, WORD* pwHeadSB )
 {
   WORD wDOSDrv = toupper(fName[ 0 ]) - 'A' + 1;

   BYTE bSector[ SEC_SIZE + 2 ];
   if( absread(wDOSDrv - 1, 1, 0, bSector) )
     return 0;
   BPB_ *p = (BPB_*)bSector;

   int hFile = open( fName, O_RDONLY|O_BINARY );
   if( hFile == -1 ) return 0;
   DWORD dwCluster;

   asm {
	pushf
	push	es

	mov	ax, 1220h //GET JOB FILE TABLE ENTRY
	mov	bx, hFile
	int	2Fh

	movzx	bx, byte ptr es:[di]
	mov	ax, 1216h //GET ADDRESS OF SYSTEM FILE TABLE ENTRY
	int	2Fh

	mov	ax, 3000h
	int	21h
	cmp	ax, 0A07h //Win95 OSR2: OsVer = 7.10
	jae     OSR2_DetectPhysPlace

	movzx   eax, word ptr es:[di + 0bh]
	mov     dwCluster, eax

	jmp   	OSR2_EndDetect
      }
OSR2_DetectPhysPlace:
    asm {
	mov   	eax, dword ptr es:[di + 2bh]
	mov     dwCluster, eax
   }
OSR2_EndDetect:
     asm {
	pop	es
	popf
   }

    close( hFile );

    DPB far* pDPB;
    asm {
      pushf
      push	ds

      mov	ax, 3200h
      mov	dx, wDOSDrv
      int	21h

      mov	word ptr pDPB, bx
      mov	word ptr pDPB + 2, ds

      pop 	ds
      popf
    }

    WORD wRootSects = (pDPB->wRootEntries * 32) / pDPB->wSectSize;
    WORD wFirstData = p->wResSects + (p->wFatSects * pDPB->bFatCnt) + wRootSects;
    DWORD dwAbsSect = wFirstData + ((dwCluster - 2) * p->bClustSects);
 }


 int CopyFileFromTo( char* pFrom, char* pTo )
 {
   int hFile = open( pFrom, O_RDONLY|O_BINARY );
   if( hFile == -1 )
    {
      printf( "Can't open: %s\n", pFrom );
      return 0;
    }
   long lPos = lseek( hFile, 0, SEEK_END );
   if( lPos == -1 )
    {
      close( hFile );
      printf( "Can't seek: %s\n", pFrom );
      return 0;
    }

   char *pBuf = (char*)calloc( lPos, 1 );
   if( !pBuf )
    {
      close( hFile );
      printf( "No memory for copy of: %s\n", pFrom );
      return 0;
    }

   lseek( hFile, 0, SEEK_SET );
   int iRes = read( hFile, pBuf, lPos );
   if( iRes != lPos )
    {
      close( hFile );
      free( pBuf );
      printf( "Can't read: %s\n", pFrom );
      return 0;
    }

   close( hFile );

   hFile = open( pTo, O_WRONLY|O_CREAT|O_TRUNC|O_BINARY, S_IREAD|S_IWRITE );
   if( hFile == -1 )
    {
      free( pBuf );
      printf( "Can't create: %s\n", pTo );
      return 0;
    }

   if( write(hFile, pBuf, lPos) != lPos )
    {
      free( pBuf );
      close( hFile );
      printf( "Can't write: %s\n", pTo );
      return 0;
    }

   free( pBuf );
   close( hFile );

   return 1;
 }
