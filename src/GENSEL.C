#include <dos.h>
#include <string.h>
#include "GenSel.h"
#include <stdio.h>

/*typedef struct tag_CSBufer
 {
   BYTE bData[ SBUF_HEIGHT_MAX ][ SBUF_WIDTH_MAX ];
   BYTE bSelSta; //first selectable
   BYTE bSelEnd; //last selectable
 } CSBufer;*/

void PrepareScreen( void )
 {
   asm {
     pushf
     push	bp

     //int	3
     mov 	cx, 40h
     mov        gs, cx
     xor 	cx, cx

     mov	dl, byte ptr gs:[4Ah] //number columns
     dec	dl
     mov	dh, byte ptr gs:[84h] //number rows
     mov	bh, 7h
     mov	ax, 600h //clear window
     int	10h

     mov	bh, 1Eh //br.yellow on blue at top
     mov	dh, 0
     mov	ax, 600h
     int	10h

     mov	dh, byte ptr gs:[84h]
     mov	ch, dh
     mov	ax, 600h
     int	10h  //br.yellow on blue at bottom

     mov	ax, 200h //set cursor at caption
     xor	bh, bh
     xor	dx, dx
     int	10h

     ;mov	ah, 0ah //print =====
     ;mov	al, 205
     mov	ax, 0ACDh
     xor	bh, bh
     movzx	cx, byte ptr gs:[4Ah]
     int	10h

     xor	dx, dx
     mov	dl, 2
     mov	bl, 1Fh
     push	cs
     pop	es
     lea	bp, cs:sAlex
     mov	cx, LEN_sAlex
     mov	ax, 1300h
     int	10h

     mov	ax, 200h //set cursor at bottom
     mov	dl, 0
     mov	dh, byte ptr gs:[84h]
     int	10h

     ;mov	ah, 0ah //print ======
     ;mov	al, 205
     mov	ax, 0ACDh
     movzx	cx, byte ptr gs:[4Ah]
     int	10h

     mov	dh, byte ptr gs:[84h]
     mov	dl, byte ptr gs:[4Ah]
     sub	dl, LEN_sUB + 2
     //mov	bl, 1Fh
     lea	bp, cs:sUB
     mov	cx, LEN_sUB
     mov	ax, 1300h
     int	10h

     pop	bp
     popf
     jmp	L_EXIT_PrepareScreen

//STA_sAlex = $
sAlex  db ' ', 196, 196, 205, 205, '(c)AlexCorp.  1999', 205, 205, 196, 196, ' '
LEN_sAlex = $ - sAlex

//STA_sUB = $
sUB  db ' ', 196, 196, 205, 205, 'Ultra booter V1.0', 205, 205, 196, 196, ' '
LEN_sUB = $ - sUB

   }
L_EXIT_PrepareScreen:
 }

static BYTE ShowEmpty( CSBufer* pcsb )
 {
   OutStr( "No drives accessible", -1, 0xC, -1 );

   return 0xFF;
 }

void OutStr( char* pSTr, int iY, BYTE bAttr, int iLeft )
 {
   BYTE far* p;
   int iLen = strlen( pSTr );

   if( iLeft == -1 )
    {
      p = MK_FP( 0x40, 0x4A );
      iLeft = ((int)*p - iLen) / 2;
    }
   if( iY == -1 )
    {
      p = MK_FP( 0x40, 0x84 );
      iY = ((int)*p + 1) / 2;
    }

    asm {
      pushf
      push	bp

      mov	ax, 1300h
      xor	bh, bh
      mov	bl, bAttr
      mov	cx, iLen
      mov	dh, iY
      mov	dl, iLeft
      push	ds
      pop	es
      mov	bp, pSTr
      int	10h

      pop	bp
      popf
    }
 }

void SetScrAttribs( BYTE bY, BYTE bLeft, BYTE bRight, BYTE bAttr )
 {
   WORD far* p = MK_FP( 0x40, 0x63 );
   WORD bVideoSeg = *p == 0x3D4 ? 0xB800:0xB000;
   BYTE far* p2  = MK_FP( 0x40, 0x4A );
   BYTE far* pVio = MK_FP( bVideoSeg, 2 * (WORD)bY * (WORD)*p2 + (WORD)bLeft * 2 );
   int i = bRight - bLeft;

   for( ++pVio; i >= 0; --i, pVio += 2 )
     *pVio = bAttr;
 }

BYTE GenericInteractiveSelect( CSBufer* pcsb )
 {
   int i;
   int iMaxLen = 0, iTmp;
   BYTE bTopScr, bBottomScr, bCurrScr, bNextScr, bRight;
   BYTE bKeyCode, bFlNotBrk;

   BYTE far* p = MK_FP( 0x40, 0x4A );
   BYTE bLeft, bTop;

   if( pcsb->bSelSta == 0xFF ) return ShowEmpty( pcsb );
   PrepareScreen();

   for( i = 0; i <= pcsb->bSelEnd; ++i )
    {
      iTmp = strlen( pcsb->bData[i] );
      if( iTmp > iMaxLen ) iMaxLen = iTmp;
    }

    bLeft = ((int)*p - iMaxLen) / 2;

    p = MK_FP( 0x40, 0x84 );
    bTop = (*p - pcsb->bSelEnd) / 2;

    for( i = 0; i < pcsb->bSelSta; ++i, ++bTop )
      OutStr( pcsb->bData[i], bTop, 0xF, -1 );

    bNextScr = bCurrScr = bTopScr = bTop;

    for( i = pcsb->bSelSta; i <= pcsb->bSelEnd; ++i, ++bTop )
      OutStr( pcsb->bData[i], bTop, 0xA, bLeft );

    bBottomScr = bTop - 1;
    bRight = bLeft + iMaxLen + 1;
    if( bLeft > 1 ) --bLeft;

    while( 1 )
     {
       SetScrAttribs( bCurrScr, bLeft, bRight, 0xA );
       SetScrAttribs( bNextScr, bLeft, bRight, 0x9F );
       bCurrScr = bNextScr;

       bFlNotBrk = 1;
       do {
	 asm {
	  pushf
	  push	ax
	  xor	ax, ax
	  int	16h
	  test	al, al
	  jz	MAH_GenericInteractiveSelect
	  mov	bKeyCode, al
	  jmp	EX_GenericInteractiveSelect
	 }

MAH_GenericInteractiveSelect:
	asm {
	  mov	bKeyCode, ah
	}

EX_GenericInteractiveSelect:
	asm {
	  pop	ax
	  popf
	 }

	switch( bKeyCode )
	 {
	   case 0x48: case 0x4b: //up
	     if( bCurrScr > bTopScr )
	       bNextScr = bCurrScr - 1;
	     else bNextScr = bBottomScr;
	     bFlNotBrk = 0;
	     break;

	   case 0x50: case 0x4d: //down
	     if( bCurrScr < bBottomScr )
	       bNextScr = bCurrScr + 1;
	     else bNextScr = bTopScr;
	     bFlNotBrk = 0;
	     break;

	   case 0xD: //enter
	     return bCurrScr - bTopScr;

	   case 0x1b: //esc
	     return 0xFF;
	 }
       } while ( bFlNotBrk );
     }
 }

void ReportErr( char* pStr, BYTE bAttr )
 {
   int iLen = strlen( pStr );

   BYTE far* p = MK_FP( 0x40, 0x4A );
   BYTE bLeft = ((int)*p - iLen) / 2;
   BYTE bTop;

   p = MK_FP( 0x40, 0x84 );
   bTop = ((int)*p + 1) / 2;

   asm {
     pushf
     push	bp
     //int	3
     mov 	cx, 40h
     mov        gs, cx
     xor 	cx, cx

     mov	dl, byte ptr gs:[4Ah] //number columns
     dec	dl
     mov	dh, byte ptr gs:[84h] //number rows
     mov	bh, 7h
     ;xor	al, al
     ;mov	ah, 6h //clear window
     mov	ax, 600h
     int	10h

     xor	bh, bh
     mov	bl, bAttr //red on black
     mov 	cx, iLen
     mov	dh, bTop
     mov	dl, bLeft
     push	ds
     pop	es
     mov	ax, pStr
     mov	bp, ax
     mov	ax, 1300h
     int	10h

     xor	ax, ax
     int	16h

     pop	bp
     popf
   }
 }

BYTE MkQuery( char* psPrompt, char cY )
 {
   BYTE bCode;

   OutStr( psPrompt, -1, 0xC, -1 );

   asm {
      xor	ax, ax
      int	16h
      mov	bCode, al
   }

   return (toupper(bCode) == cY);
 }
