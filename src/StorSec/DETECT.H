#if !defined(_DETECT_H0_)
#define _DETECT_H0_

#include  "dtypes.h"

#define SEC_SIZE  512L

#define SIGN_ORIGIN    0x3E
#define SIGN_CONTENT  "(c)AlexCorp. 1999. Ultra Booter 1.0"

#define FNAME_FBOOT     "fboot.bin"
#define FNAME_SBOOT     "mfunc.bin"
#define FNAME_ORIGBOOT  "oboot.bin"

#define FNAME_SBOOT_SECTORS 14



#pragma pack( push )
#pragma pack( 1 )

#define GET_TRACK(sc) ( ((((WORD)(sc) >> 6)&3)<<8)  |  (((WORD)(sc) >> 8) & 0x3FF) )
#define GET_SEC(sc) ((sc) & 0x3F)

#define MAKE_CS(track, sec) ( ((((WORD)(track) >> 8)&3 | (((WORD)(track) << 2)&0x3FC)) << 6) | ((WORD)(sec)&0x3F))


//область форматированных параметров загрузочного сектора
typedef struct tag_BPB_ {
  BYTE abJmp[ 3 ];
  BYTE abOEM[ 8 ];
  WORD wSectSize;
  BYTE bClustSects;
  WORD wResSects;
  BYTE bFatCnt;
  WORD wRootEntries;
  WORD wTotSects;

  BYTE bMedia;
  WORD wFatSects;
  WORD wSecPerTrk;
  WORD wHeads;
  DWORD lHidSects;
  DWORD lBigTotSects;

  BYTE bDrvNo;
  BYTE res1;
  BYTE bExtBootSig;
  DWORD lSerNo;
  BYTE abVolLabel[ 11 ];
  BYTE abFileSysID[ 8 ];
 } BPB_;

 //Drive parameter block - возвращается функцией DOS Int 21h  ah=32h
typedef struct tag_DPB {
   BYTE bDrvNo;
   BYTE bUnitNo;
   WORD wSectSize;
   BYTE bClustMask;
   BYTE bClustShift;
   WORD wFirstFAT;
   BYTE bFatCnt;
   WORD wRootEntries;
   WORD wFirstData;
   WORD wHiClust;
   BYTE bFatSects;
   WORD wRootSec;
   DWORD pfrDevHdr;
   BYTE bMedia;
   BYTE bFirstAccess;
   DWORD pfrNextDPB;
   WORD wNextFree;
   WORD wFreeCnt;
 } DPB;

//Hard disk Parameter Table - возвращается Int 13h ah=8
typedef struct tag_DriveParams {
   WORD wMaxCyls;
   BYTE	bMaxHds;
   WORD wRWCyl;
   WORD wWPCyl;
   BYTE bECCLen;
   BYTE rOptFlags;

   BYTE bTimeOutStd;
   BYTE bTimeOutFmt;
   BYTE bTimeOutChk;
   DWORD dwRes;
 } DriveParams;

typedef struct tag_Placing {
   WORD	wDrv;
   WORD	wCyl, wSec, wHead;
   WORD wSecSize;
   BYTE bDeviceFlag; //	0 - Floppy
//	1 - HDD

 } Placing;

//заголовок нашего первичного загрузчика FBoot.asm
typedef struct tag_FBHdr {
  BYTE abAlign[ 0x3E ];

  BYTE abSign[ 35 ];

  BYTE bBootDevice;

  WORD wCylSec_SBoot;
  BYTE bHead_SBoot;
  BYTE bNSectors_SBoot;

  WORD wCylSec_OBoot;
  BYTE bHead_OBoot;
  BYTE bNSectors_OBoot;
 } FBHdr;



#pragma pack( pop )

BYTE IsHDDorFloppy( BYTE bDrv );
//RETURN:
//	0 - Floppy
//	1 - HDD

int DetectDevice( char* );
int DetectPhysPlace( BYTE iDrv, char* fName, WORD* pwSecSB, WORD* pwCylSB, WORD* pwHeadSB );
int DetectPlacing( /*[in]*/char*, /*[content out]*/Placing* pPl );
//RETURN:
//	-1 - system error
//	-2 - can't use this drive
//	 0 - OK

int CopyFileFromTo( char* pFrom, char* pTo );

#endif