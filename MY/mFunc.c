/*#include <string.h>
#include <alloc.h>
#include <conio.h>
#include <stdio.h>
#include <bios.h>*/

#include "DrvFunc.h"

void main( int argc, char *argv[] )
 {
   MBR mbr;
   int i;
   WORD track;
   char cc[ 10 ];
   //WORD sect;
   //PartitionEntry *pE;
   WORD wRes;

   memset( cc, 0, 10 );

   wRes = ExploreAndSelect( &mbr );
   //asm int 3h
   sprintf( cc, "Test" );
   sprintf( cc, "Test2" );
   //bDrive OR 0xFF
   //track = GET_TRACK(pE->rBeginSecCyl);
   //sect = GET_SEC(pE->rBeginSecCyl);
 }
