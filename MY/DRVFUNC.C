#include <dos.h>
#include <memory.h>
#include <stdio.h>
#include <string.h>
//#define _DRVF_IMPL_
#include "DrvFunc.h"

#include "StorSec\detect.h"



char* GetTextDescr(  /*[in]*/BYTE bDrive )
 {
   static cBuf[ 64 ];

   if( bDrive >=0 && bDrive <= 3 )
     sprintf( cBuf, "Floppy disk %c:", 'A' + bDrive );
   else if( bDrive >=0x80 && bDrive <= 0x83 )
     sprintf( cBuf, "Hard disk %d", (int)(bDrive - 0x7F) );
   else if( bDrive == 0xFF )
     sprintf( cBuf, "<Empty>" );
   else
     sprintf( cBuf, "<Unknown>" );

   return cBuf;
 }

BYTE CheckMountedDrv( /*[in]*/BYTE bDrv )
 {
   asm {
     pushf
     mov	ah, 15h  //проверка установленности устройчтва
     mov	dl, bDrv
     int	13h
     jc		L_ERR_CheckMountedDrv
     cmp	ah, 0
     setnz	al
     xor	ah, ah
     popf
     jmp	L_RET_CheckMountedDrv
   };

L_ERR_CheckMountedDrv:
  asm {
     xor	ax, ax
     popf
   };
L_RET_CheckMountedDrv:
 }

void DetectDrives( BYTE ucCfg[N_DRIVES_MAX] )
 {
   BYTE bIdx = 0;
   EquipmentWord far *pEq = (EquipmentWord far *)MK_FP( 0x40, 0x10 );
   int c;

   setmem( ucCfg, N_DRIVES_MAX, 0xFF );


   if( pEq->b0Floppy )
    {
      for( c = 0; c < 4; ++c )
	if( CheckMountedDrv(c) == 1 )
	   ucCfg[ bIdx++ ] = c;
    }

   for( c = 0x80; c < 0x84; ++c )
    if( CheckMountedDrv(c) == 1 )
      ucCfg[ bIdx++ ] = c;

   //if( CheckMountedDrv(0x80) ) ucCfg[ bIdx++ ] = 0x80;
   //if( CheckMountedDrv(0x81) ) ucCfg[ bIdx++ ] = 0x81;
 }

BYTE InteractiveSelectDrv( BYTE ucCfg[N_DRIVES_MAX], /*[in]*/CSBufer* pCsb )
//Each byte is:
//	0-3 	- floppy disk
//	80h-83h - hard disk
//	FFh 	- empty slot

//RETURN: index of selected in array
//No ESC accept
 {
   int i, iStr;

   sprintf( pCsb->bData[0], "(ESC - reboot) Select device" );
   sprintf( pCsb->bData[1], "" );

   pCsb->bSelSta = 2;

   for( i = 0, iStr = 2; N_DRIVES_MAX > i; ++i )
     if( ucCfg[i] != 0xFF )
      {
	sprintf( pCsb->bData[iStr], "%d. %s%s", iStr - 1, GetTextDescr(ucCfg[i]),
	  ucCfg[i] >= 0x80 ? "  \x19":"" );
	++iStr;
      }

   if( iStr == 2 )
     pCsb->bSelSta = pCsb->bSelEnd = 0xFF;
   else pCsb->bSelSta = 2, pCsb->bSelEnd = iStr - 1;

   i = GenericInteractiveSelect( pCsb );
   return i == 0xFF ? 0xFF:ucCfg[ i ];
 }

//В зависимости от флага bFlFullMBR эта процедура возвращает в pmbd весь
//сектор или только таблицу разделов MBR

static BYTE ReadMBRInto( BYTE bDrv, WORD wSector, WORD wTrack, WORD wHead, /*[content out]*/MBRDscr* pmbd, BYTE bFlFullMBR )
//ret: 1 - OK, 0 - error
 {
   WORD wIn13CS = MAKE_CS( wTrack, wSector );
   WORD wTmp;
   BYTE bMaxNumberTrack, bSectorsPerTrack;
   BYTE abSector[ SEC_SIZE ];

   if( bDrv < 0x80 ) //floppy
    {
      //проверить смену диска, если надо, перечитать параметры
      asm {
	pushf

	mov	ah, 16h //проверить смену диска
	mov	dl, bDrv
	int	13h
	cmp	ah, 6
	jnz	L_NotCh_ReadMBRInto

	mov	ah, 8 //получить параметры диска
	mov	dl, bDrv
	int	13h
	jc	L_CantGetParams_ReadMBRInto

	mov	wTmp, cx
      }

    bMaxNumberTrack  = GET_TRACK(wTmp) + 1;
    bSectorsPerTrack = GET_SEC(wTmp);

    asm {
	mov	ah, 18h //установить параметры дисковода
	mov	ch, bMaxNumberTrack
	mov	cl, bSectorsPerTrack
	mov	dl, bDrv
	int	13h
    }


L_NotCh_ReadMBRInto:
    asm {
	popf
	mov	bx, OFFSET L_ReadOK_ReadMBRInto
	jmp 	bx
      }

L_CantGetParams_ReadMBRInto:
	asm popf
	return 0;
  }//if( bDrv < 0x80 )

   asm {
L_ReadOK_ReadMBRInto:
      pushf
      push	ds

      mov	cx, wIn13CS

      mov	ax, 0201h //read 1 sector
      mov	dl, bDrv
      mov	dh, wHead
      push	cs
      pop	es
      lea	bx, abSector

      int	13h

      jnc       L_OK_ReadMBRInto

      mov	ax, 0201h
      int	13h
      jnc       L_OK_ReadMBRInto

      mov	ax, 0201h
      int	13h
      mov	ax, 0 //установить код возврата
      jc	L_ERR_ReadMBRInto
   }

L_OK_ReadMBRInto:
  asm {
      mov	ax, 1 //установить код возврата

      push	ds
      pop	es
      push	cs
      pop	ds
      cmp	bFlFullMBR, 0
      jnz	L_FullMBR_ReadMBRInto
      lea	si, abSector
      add	si, 446 //пропустить область загрузчика
      mov	cx, 66 //длина 4-х записей MBR + 2 байта сигнатуры
      jmp       L_Movsb_ReadMBRInto
    }

L_FullMBR_ReadMBRInto:
   asm {
      lea	si, abSector
      mov	cx, 512
    }

L_Movsb_ReadMBRInto:
   asm {
      mov	di, pmbd
      cld
      REPE movsb
   }

L_ERR_ReadMBRInto:
  asm {
      pop	ds
      popf
    }
 }

BYTE ExploreDrive_OR_ExPart( /*[in]*/BYTE ucDrv, /*[in]*/PartitionEntry* pEntry, /*[content out]*/MBRDscr* pmbdInfo,  /*[in]*/ PartitionEntry* pmbdParent )
//RETURN: 1 - OK, 0 - failed
//ucDrv:
//	0-3 	- floppy disk
//	80h-83h - hard disk
 {
   WORD wSector, wTrack, wHead;

   /*PartitionEntry2 pp2;
   int c;
   if( pEntry )
    {
      memcpy( &pp2, pEntry, sizeof(PartitionEntry2) );
      c = 1;
    }*/

   if( pEntry )
    {
      if( !pmbdParent )
	wSector = GET_SEC(pEntry->rBeginSecCyl),
	wTrack = GET_TRACK(pEntry->rBeginSecCyl),
	wHead = pEntry->bBeginHead;
      else //если это логический диск Extended part., то параметры относительные
	wSector = GET_SEC(pEntry->rBeginSecCyl + pmbdParent->rBeginSecCyl),
	wTrack = GET_TRACK(pEntry->rBeginSecCyl + pmbdParent->rBeginSecCyl),
	wHead = pmbdParent->bBeginHead;
    }
   else
     wSector = 1, wTrack = wHead = 0;

   return ReadMBRInto( ucDrv, wSector, wTrack, wHead, pmbdInfo, 0 );
 }


static char* GetTextPresentationOfPart( int iNum, PartitionEntry* pE )
 {
   static char cBuf[ 80 ];
   char cPref[ 10 ];
   char pPostf[128];// = pE->bBootFlag == 0x80 ? " (Active)":"";

   sprintf( pPostf, " %9s %4u : %-2u - %-4u : %-2u",
     pE->bBootFlag == 0x80 ? " (Active)":"",

     GET_TRACK(pE->rBeginSecCyl),
     GET_SEC(pE->rBeginSecCyl),

     GET_TRACK(pE->rEndSecCyl),
     GET_SEC(pE->rEndSecCyl) );


   sprintf( cPref, "%d. ", iNum );

   switch( pE->bFileSysCode )
    {
      case 0:
	sprintf( cBuf, "%sEmpty       %s", cPref, pPostf );
	break;
      case 1:
	sprintf( cBuf, "%sFAT 12      %s", cPref, pPostf );
	break;
      case 4:
	sprintf( cBuf, "%sFAT 16      %s", cPref, pPostf );
	break;
      case 5:
	sprintf( cBuf, "%sExtended DOS%s  \x19", cPref, pPostf );
	break;
      case 6:
	sprintf( cBuf, "%sLarge FAT 16%s", cPref, pPostf );
	break;
      case 7:
	sprintf( cBuf, "%sNTFS        %s", cPref, pPostf );
	break;

      case 0x0B:
	sprintf( cBuf, "%sFAT 32      %s", cPref, pPostf );
	break;
      case 0x0C:
	sprintf( cBuf, "%sFAT 32x     %s", cPref, pPostf );
	break;

      case 0x83:
	sprintf( cBuf, "%sLinux native%s", cPref, pPostf );
	break;

      default:
	sprintf( cBuf, "%s<UNKNOWN>   %s", cPref, pPostf );
	break;
    }
   return cBuf;
 }

static void GenerateTPOfMBR( /*[content out]*/CSBufer* pCsb, MBRDscr* pMbdscr, BYTE bParent )
 {
   sprintf( pCsb->bData[0], "(ESC - %s Select partition", bParent ? "up level \x18)":"select drive *)" );
   sprintf( pCsb->bData[1], "" );

   sprintf( pCsb->bData[2], GetTextPresentationOfPart(1, &pMbdscr->part1) );
   sprintf( pCsb->bData[3], GetTextPresentationOfPart(2, &pMbdscr->part2) );
   sprintf( pCsb->bData[4], GetTextPresentationOfPart(3, &pMbdscr->part3) );
   sprintf( pCsb->bData[5], GetTextPresentationOfPart(4, &pMbdscr->part4) );

   pCsb->bSelSta = 2;
   pCsb->bSelEnd = 5;
 }

static PartitionEntry* GetEntry( BYTE bIdx, MBRDscr* pMbr )
 {
   switch( bIdx )
    {
      case 0:
	return &pMbr->part1;
      case 1:
	return &pMbr->part2;
      case 2:
	return &pMbr->part3;
      case 3:
	return &pMbr->part4;
      default:
	return NULL;
    }
 }

BYTE InteractiveSelectPartition(
  /*[in]*/BYTE bDrv,
  /*[in]*/ PartitionEntry* peParent,
  /*[in]*/ PartitionEntry* peToExplore,
  /*[content out]*/MBRDscr* pmbdExplored,
  /*[in]*/CSBufer* pCsb )
//RETURN: index of selected entry in pmbdCurr
//	  OR 0xFF - ESC
 {
   MBRDscr mbdscr;
   BYTE bRes, bResKeep;
   PartitionEntry* peSelected;

   while( 1 )
    {
      memset( &mbdscr, 0, sizeof(MBRDscr) );

      bRes = ExploreDrive_OR_ExPart( bDrv, peToExplore,  &mbdscr,
	peToExplore && peParent && peToExplore->bFileSysCode != 5 ? peParent:NULL );

      if( !bRes )
       {
	 ReportErr( "Can't explore", 0xC );
	 return 0xFF;
       }

      if( mbdscr.wPrtnTblSig != 0xaa55 )
	{
	//asm int 3h
	  ReportErr( "Incorrect signature (required 0xaa55)", 0xC );
	  return 0xFF;
	}

      GenerateTPOfMBR( pCsb, &mbdscr, peToExplore != NULL );
      bRes = GenericInteractiveSelect( pCsb );
      if( bRes == 0xFF ) return 0xFF;

      bResKeep = bRes;
      peSelected = GetEntry( bRes, &mbdscr );
      if( !peSelected )
       {
	 ReportErr( "Internal error", 0xC );
	 return 0xFF;
       }

       bRes = IsBootable( peSelected->bFileSysCode );
       switch( bRes )
	{
	  case 0: //empty
	    ReportErr( "This partition is empty", 0xF );
	    //return 0xFF;
	    break;
	  case 1: //Yes
	    if( peParent )
	     {
	       //peSelected->rBeginSecCyl += peParent->rBeginSecCyl;
	       //peSelected->rBeginSecCyl_Cyl += peParent->rBeginSecCyl_Cyl;
	       //peSelected->bBeginHead += peParent->bBeginHead;
	     }
	    memcpy( pmbdExplored, &mbdscr, sizeof(MBRDscr) );
	    return bResKeep;
	  case 2: //Extended
	    bRes = InteractiveSelectPartition( bDrv,
	      peSelected, peSelected, pmbdExplored, pCsb );
	    if( bRes == 0xFF ) break;
	    return bRes;

	  case 3: //<UNKNOWN>
	    ReportErr( "This partition type is not supported", 0xF );
	    //return 0xFF;
	    break;
	}
      }//while

   return 0xFF;
 }

BYTE IsBootable( BYTE bFl )
 {
 //RETURN:
//	0 - no (empty)
//      1 - Yes
//	2 - extended
//	3 - <UNKNOWN>

   switch( bFl )
    {
      case 1: case 4: case 6: case 7: case 0xB: case 0xC: case 0x83:
	return 1;
      case 0:
	return 0;
      case 5:
	return 2;
      default:
	return 3;
    }
 }

BYTE IsFAT( BYTE bCode )
 {
   switch( bCode )
    {
      case 1:
      case 4:
      case 6:
      case 0xB:
	return 1;

      default:
	return 0;
    }
 }

WORD ExploreAndSelect( MBR * pMBR )
 {
   CSBufer csbBuf;

   BYTE bRes, bRes2;
   BYTE ucCfg[ N_DRIVES_MAX ];
   BYTE bIndex;
   PartitionEntry *pSelEnt;
   PartitionEntry peSel;
   WORD wRetCode = 0;
   BYTE bRes2Key;

   WORD wKeyCsrShape;
   //WORD wKeyCsrPos;
   //int i;
   //MBRDscr ppp;

   asm {
     pushf
     mov	ax, 1003h //отключить blink
     xor	bl, bl
     int	10h

     mov	ax, 300h //получить координаты и форму курсора
     xor	bx, bx
     int	10h
     mov        wKeyCsrShape, cx
     //mov	wKeyCsrPos, dx

     mov	ax, 100h  //отключить курсор
     mov	cx, 2020h
     int	10h

     popf
   }

   DetectDrives( ucCfg );


   while( 1 )
    {
      bRes = InteractiveSelectDrv( ucCfg, &csbBuf );
      if( bRes <= 3 )
       {
	 bRes2 = MakeFullMBROf( bRes, NULL, pMBR );
	 if( bRes2 )
	  {
	    if( bRes != 0 &&
		MkQuery("To swap drives (Y/N) ?", 'Y')
	      )
	      wRetCode = bRes;
	    else
	     {
	       BPB_ *pBoot = (BPB_*)pMBR;
	       pBoot->bDrvNo = bRes; //исправить в загрузочной записи физический
	     }                      //номер устройства
	    asm {
	       mov	ax, 1003h //включить blink
	       mov	bl, 1
	       int	10h

	       mov	ax, 100h //включить курсор
	       mov	cx, wKeyCsrShape
	       int	10h
	     }
	    return wRetCode;
	  }
	 else
	  {
	    ReportErr( "Read error of boot sector", 0xC );
	    continue;
	  }
       }
      if( bRes == 0xFF )
       {
	 asm {
	   mov	ax, 1003h
	   mov	bl, 1
	   int	10h

	   mov	ax, 100h
	   mov	cx, wKeyCsrShape
	   int	10h

	   xor	ax, ax
	   mov	es, ax
	   mov	word ptr es:[472h], 1234h  //причина перезагрузки Ctrl+Alt+Del
	   DB	0EAh			   //переход на код перезагрузки
	   DW	0h
	   DW   0FFFFh
	 };
       }


      //ExploreDrive( ucCfg[bRes], mbrArr );
      bIndex = InteractiveSelectPartition( bRes, NULL, NULL, &pMBR->dscr, &csbBuf );

      if( bIndex != 0xFF )
       {
	 DWORD dwBSec, dwBCyl, dwHead;

	 bRes2Key = bRes;
	 pSelEnt = GetEntry( bIndex, &pMBR->dscr );
	 memcpy( &peSel, pSelEnt, sizeof(PartitionEntry) );

	 dwBSec = GET_SEC( peSel.rBeginSecCyl );
	 dwBCyl = GET_TRACK( peSel.rBeginSecCyl );
	 dwHead = peSel.bBeginHead;

	 bRes2 = MakeFullMBROf( bRes, pSelEnt, pMBR );
	 if( bRes2 )
	  {
	    if( pMBR->dscr.wPrtnTblSig != 0xaa55 )
	      ReportErr( "This partition contains bad signatire (need 0aa55h)", 0xC );
	    else
	     {
	       if( IsFAT(peSel.bFileSysCode) && dwBCyl != 0 &&
		  MkQuery("To shift sectors (Y/N) ?", 'Y') )
		{
		  //если загрузка MS DOS с логического диска жёсткого диска,
		  //отличного от C:, то модифицируем число скрытых секторов
		  //так, чтобы оно компенсировало смещение раздела относительно
		  //начала физического диска, и загрузчик DOS мог правильно
		  //считать корневой каталог логического диска
		  BPB_ *pBoot = (BPB_*)pMBR;
		  pBoot->lHidSects = dwBCyl * (DWORD)pBoot->wHeads * (DWORD)pBoot->wSecPerTrk +
		  (DWORD)pBoot->wSecPerTrk * dwHead +
		  (dwBSec - 1);
		}

	       if( bRes2Key != 0x80 &&
		  MkQuery("To swap drives (Y/N) ?", 'Y')
		)
		 wRetCode = (0x80 << 8) | bRes2Key; //если загрузка с
						    //первого раздела дополнительного
						    //жёсткого диска - меняем его местами с 80h
		 else
		  {
		    BPB_ *pBoot = (BPB_*)pMBR;
		    pBoot->bDrvNo = bRes; //исправить в загрузочной записи физический
		  }                      //номер устройства


	       asm {
		  mov	ax, 1003h
		  mov	bl, 1
		  int	10h

		  mov	ax, 100h
		  mov	cx, wKeyCsrShape
		  int	10h
		}
	       return wRetCode;
	     }
	  }
	 else ReportErr( "Read error of boot sector", 0xC );
       }
    }
 }

BYTE MakeFullMBROf( /*[in]*/BYTE bDrv, /*[in]*/PartitionEntry* pE, /*[content out]*/MBR* pMBR )
 {
   static char* cSign = SIGN_CONTENT;
   FBHdr *pHdr;

   BYTE bRes;
   if( pE )
     bRes = ReadMBRInto( bDrv, GET_SEC(pE->rBeginSecCyl), GET_TRACK(pE->rBeginSecCyl),
       pE->bBeginHead, pMBR, 1 );
   else
     bRes = ReadMBRInto( bDrv, 1, 0, 0, pMBR, 1 );

//если был считан собственный первичный загрузчик, считать сохранённый старый загр.
   pHdr = (FBHdr*)pMBR;
   if( !memcmp(pHdr->abSign, cSign, strlen(cSign)) )
     bRes = ReadMBRInto( bDrv,
       GET_SEC(pHdr->wCylSec_OBoot),
       GET_TRACK(pHdr->wCylSec_OBoot),
       pHdr->bHead_OBoot, pMBR, 1 );


   return bRes;
 }
