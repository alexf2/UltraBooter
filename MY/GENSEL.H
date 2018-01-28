#if !defined(_GNERIC_INTERACTIVE_SELECT_)
#define _GNERIC_INTERACTIVE_SELECT_

#include "dtypes.h"

#define SBUF_WIDTH_MAX 80
#define SBUF_HEIGHT_MAX 15

typedef struct tag_CSBufer
 {
   BYTE bData[ SBUF_HEIGHT_MAX ][ SBUF_WIDTH_MAX ];
   BYTE bSelSta; //first selectable
   BYTE bSelEnd; //last selectable
//typical:
//	0 - (bSelSta-1):   Header
//	bSelSta - bSelEnd: Selectable
//
 } CSBufer;
//extern CSBufer csBuf;

void PrepareScreen( void );

BYTE GenericInteractiveSelect( CSBufer* );
void ReportErr( char*, BYTE );
void OutStr( char* pSTr, int iY, BYTE bAttr, int iLeft );
void SetScrAttribs( BYTE bY, BYTE bLeft, BYTE bRight, BYTE bAttr );

BYTE MkQuery( char* psPrompt, char cY );

#endif
