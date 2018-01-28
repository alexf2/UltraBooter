#include <stdio.h>
#include <dos.h>

int main( int argc, char** argv )
 {
   unsigned char v1, v2;
   unsigned int ui;

   asm {
	mov	ah, 30h
	int	21h
	mov	v1, ah //minor
	mov	v2, al //major
	mov	ui, ax
   }

   printf( "Version is: %u.%u\n", (unsigned int)v2, (unsigned int)v1 );
   printf( "\tthe AX = %xh\n", ui );

   asm {
	mov	ax, 3305h
	int	21h
	mov	v1, dl
   }

   printf( "Boot drive: %c:\n", (char)(v1 + 'A' - 1) );

   printf( "Free BIOS memory in KB is: %u\n", *(int far*)MK_FP(0,0x413) );
 }
