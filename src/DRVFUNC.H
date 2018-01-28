#if !defined(_DRV_FUNC_)
#define _DRV_FUNC_

#include "dtypes.h"
#include "GenSel.h"

#pragma pack(push)
#pragma pack(1)

#define N_DRIVES_MAX 8
//поддерживаются 4 гибких и 4 жёстких диска

#define N_MBRENTRYS 4
//число элементов в таблице разделов HDD

#define BOOTER_SIZE 446
//длина загрузчика MBR


typedef struct tag_EquipmentWord
 {
   WORD b0Floppy:1;
   WORD b0NP:1;
   WORD b2_3RAM:2;
   WORD b4_5IAVMode:2;
   WORD b6_7TotalFDD:2;
   WORD b8DMA:1;
   WORD b9_11RS232:3;
   WORD b12Game:1;
   WORD b13Serial:1;
   WORD b14_15Printers:2;
 } EquipmentWord;


typedef struct tag_PartitionEntry
 {
   BYTE bBootFlag; // 0 - not active, 80h - active
   BYTE bBeginHead;

   WORD rBeginSecCyl;

   BYTE bFileSysCode; // 00h - unk
		      // 01h - FAT 12
		      // 04h - FAT 16
		      // 05h - Extended DOS
		      // 06h - Large FAT 16 > 32
		      // 07h - NTFS
		      // 0x0B - FAT 32	
   BYTE bEndHead;
   //WORD bEndSecCyl;

   WORD rEndSecCyl;

   DWORD lBeginAbsSec;
   DWORD lTotalSects;
 } PartitionEntry;


 //relSec = (CylNo * SecsPerTrack * Heads) +
 //  (HeadNo * SecsPerTrack) +
 //  (SecNo - 1);

typedef struct tag_MBRDscr
 {
   PartitionEntry part1;
   PartitionEntry part2;
   PartitionEntry part3;
   PartitionEntry part4;
   WORD wPrtnTblSig; //need 0xaa55 for MBR
 } MBRDscr;

typedef struct tag_MBR
 {
   BYTE abBootCode[ BOOTER_SIZE ];
   MBRDscr dscr;
 } MBR;

//#if !defined(_DRVF_IMPL_)

BYTE MakeFullMBROf( /*[in]*/BYTE bDrv, /*[in]*/PartitionEntry* pE, /*[content out]*/MBR* pMBR );

void DetectDrives( /*[content out]*/BYTE ucCfg[N_DRIVES_MAX]  );

BYTE InteractiveSelectDrv( /*[in]*/BYTE ucCfg[N_DRIVES_MAX], /*[in]*/CSBufer* );
//Each byte is:
//	0-3 	- floppy disk
//	80h-83h - hard disk
//	FFh 	- empty slot

//RETURN: index of selected in array
//No ESC accept

BYTE ExploreDrive_OR_ExPart( /*[in]*/BYTE ucDrv, /*[in]*/PartitionEntry* pEntry, /*[content out]*/MBRDscr* pmbdInfo, /*[in]*/ PartitionEntry* );
//RETURN: 1 - OK, 0 - failed
//ucDrv:
//	0-3 	- floppy disk
//	80h-83h - hard disk

BYTE InteractiveSelectPartition(
	/*[in]*/BYTE bDrv,
	/*[in]*/ PartitionEntry* peParent,
	/*[in]*/ PartitionEntry* peToExplore,
	/*[content out]*/MBRDscr* pmbdExplored,
	/*[in]*/CSBufer* );

//RETURN: index of selected entry in pmbdCurr
//	  OR 0xFF - ESC

WORD ExploreAndSelect( /*[content out]*/ MBR * pMBR );
//RETURN:
//	0-3 	- floppy disk
//	80h-83h - hard disk

BYTE CheckMountedDrv( /*[in]*/BYTE bDrv );
//RETURN:
//	0 - no
//      1 - Yes
//bDrv:
//	0-3 	- floppy disk
//	80h-83h - hard disk

//#endif //#if !defined(_DRVF_IMPL_)

char* GetTextDescr(  /*[in]*/BYTE bDrive );

BYTE IsBootable(  /*[in]*/BYTE bFl );
//RETURN:
//	0 - no (empty)
//      1 - Yes
//	2 - extended
//	3 - <UNKNOWN>


#pragma pack(pop)

#endif
