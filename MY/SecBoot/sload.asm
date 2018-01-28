
.386p

;.model	tiny
;smallstack

locals	
;__C0__ = 1

	UNDERSCORE      EQU     1
	SEC_SIZE	EQU	512
	CR      	equ 0Dh
	LF      	equ 0Ah
	
	TMPBUF_SIZE	equ SEC_SIZE + 2

	ZOFF_TOTAL_MEM	equ	413h
	ZOFF_INT13	equ	4 * 13h
	
	

PubSym@ MACRO   Sym, Definition, sName
        IFNB    <sName>
        IFIDN   <sName>, <__PASCAL__>
NAMING      =       0
        ELSE
NAMING      =       UNDERSCORE
        ENDIF
        ENDIF
        IF      NAMING
        PUBLIC  _&Sym
_&Sym   Definition
Sym&@   equ     _&Sym
        ELSE
        PUBLIC  Sym
Sym     Definition
Sym&@   equ     Sym
        ENDIF
        ENDM



_TEXT	segment byte public use16 'CODE'
	ORG	0h
_TEXT	ends

DGROUP	group	_DATA,_BSS, _TEXT, INT_TXT
	assume	cs:DGROUP,ds:DGROUP

_DATA	segment word public use16 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends

_BSS	segment word public use16 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends

INT_TXT	segment para public use16 'CODE'
INT_TXT ends

_TEXT	segment byte public  use16 'CODE'
	assume	cs:_TEXT

	ORG	0h

_main	proc	near

	mov	dx, cs
	mov     cs:DGROUP@@, dx

	mov	ah, 3	;������� ⥪���� ������ �����
	xor	bh, bh
	int	10h
	
	mov	ax, 1301h	;�뢥�� ��ப� ⥪��
	mov	bx, 0002h
	mov	cx, SIZE_@@msgWelcome		
	mov	bp, OFFSET @@msgWelcome	
        int	10h

	xor	ax, ax		;�������� �����
	int	16h

	sub	sp, TMPBUF_SIZE	;�뤥���� ������ � �⥪� ��� ᥪ��
	mov	@@npTmpBuf, sp

	;lea	ax, @@tmpBuf
	mov	ax, @@npTmpBuf
	push	ax
	call	near ptr _ExploreAndSelect	;����� �㤥� ��࠭� � ��⠭�
	pop	cx                              ;� �⥪ ����㧮筠� ������
	mov	cx, ax
;int 3                                          ;
	jcxz	@@L_noSwap	
	call	MakeSwapDrives

@@L_noSwap:
	mov	si, @@npTmpBuf
	mov	ax, 7C0h
	mov	es, ax
	xor	di, di
	mov	cx, SEC_SIZE
	cld
	REPNZ	movsb		;��६����� ��⠭��� ����㧮��� ������ 
				;�� �⠭���⭮�� ��� BIOS �����

	add	sp, TMPBUF_SIZE

	mov	ds, ax
	cli
	mov	ss, ax
	mov	sp, 0FFFEh	;����ந�� �⥪ �㦮�� ��ࢨ筮�� �����稪�
	sti
	DB	0EAh		;jmp �� ��砫� ��ࢨ筮�� �����稪� (MBR ��� Boot sector)
	DW	0h
	DW      7C0h
	

;@@tmpBuf	DB SEC_SIZE + 2 Dup(?)
@@npTmpBuf	DW ?

@@msgWelcome	db	CR, LF, 'Welcome to Ultrabooter. Press any key to continue >_'
SIZE_@@msgWelcome	equ	$ - @@msgWelcome


_main	endp

;in: ch - 䨧��᪨� ����� ���ன�⢠ ��� ������
;cl - 䨧��᪨� ����� �������饣� ���ன�⢠
;�ਬ��. �������� B:(1) �� A:(0): cx = 0100h
MakeSwapDrives	proc near


	push	eax
	push	si di es gs cx

	xor	ax, ax
	mov	gs, ax

	mov	_Drv1, ch	;�ய���� ��ࠬ���� � ��� ��ࠡ��稪 Int13h
	mov	_Drv2, cl
	mov	eax, gs:[ZOFF_INT13]	;��������� ���� ��室���� ���. Int13h
	mov	_OldInt13, eax

	dec	word ptr gs:[ ZOFF_TOTAL_MEM ] ; 㬥����� ���� ����㯭�� ����� �� 1024 ����
	mov	ax, gs:[ ZOFF_TOTAL_MEM ]
	shl	ax, 6	;������� ᥣ���� ��१�ࢨ஢������ ���� �������� �����
			;�����_�_�� * 1024 / 16 = �����_�_�� * 64
			;㬭������ �� 64 �. ᤢ��� �� 6
	mov	es, ax
	
	mov	si,  OFFSET _TEXT:_NewInt13

	xor	di, di	;ᬥ饭�� �㤥� 0
	mov	cx, _SIZE_NewInt13
	cld
	REPNZ	movsb	;᪮��஢��� � ��१�ࢨ஢���� �������� ���� ��ࠡ��稪 Int13h

	cli
        mov	word ptr [gs:ZOFF_INT13], 0	;��⠭����� ���� ��ࠡ��稪 Int13h
	push	es
	pop	word ptr [gs:ZOFF_INT13 + 2]
	sti

	pop	cx gs es di si
	pop	eax
	retn

MakeSwapDrives	endp

_abort proc near
_abort endp

;__RealCvtVector proc near
;__RealCvtVector endp

PubSym@         DGROUP@, <dw    ?>, __PASCAL__
	
_TEXT	ends

_DATA	segment word public use16 'DATA'
s@	label	byte
_DATA	ends

_TEXT	segment byte public use16 'CODE'
	ORG	0h
_TEXT	ends

_CVTSEG         SEGMENT WORD PUBLIC 'DATA'
                ENDS
_SCNSEG         SEGMENT WORD PUBLIC 'DATA'
                ENDS



_CVTSEG         SEGMENT
PubSym@         _RealCvtVector, <label  word>,  __CDECL__
                ENDS

_SCNSEG         SEGMENT
PubSym@         _ScanTodVector,  <label word>,  __CDECL__
                ENDS


	PUBLIC	_abort	
	;PUBLIC	__RealCvtVector

	extrn	_ExploreAndSelect:near
	extrn	_NewInt13:far, _SIZE_NewInt13: WORD, _OldInt13: DWORD
	extrn	_Drv1: BYTE, _Drv2: BYTE
_s@	equ	s@

	end _main
