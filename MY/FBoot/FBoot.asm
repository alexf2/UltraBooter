.386
.model use16 tiny

SmallStack
Locals

	CR      	equ 0Dh
	LF      	equ 0Ah

	FBOOT_SEG	equ 7C0h	

	FBOOT_STACK_TOP	equ 3FEh   ; ࠧ��� �⥪� = 1022 ����� ����� ���� ����.
	SBOOT_STACK_TOP	equ 0FFFEh ; ��� ���筮�� ������稪�
				   ; ��⠭���� �⥪ �� ����� ᥣ���� 64K			
	
	SBOOT_SEG	equ 800h ; 7C0h + 1024b
				 ; � �㤥� ����㦥� ����� �����稪


MCode	SEGMENT byte public use16 'code'
	ASSUME	cs:MCode, ds:MCode, es:MCode, gs:MCode

L_START:
	jmp		L_FBOOT

	ORG	3Eh 	;�ய����� �ଠ�஢����� ������� ����㧮筮�� ᥪ�� (62b)
			;�� ������� ���������� ���⠫��஬ (stsec.exe) ����묨
			;��⠭�묨 �� ��室��� ����. �����

;<--------- ��砫� ����� ��ࠬ��஢ �����稪�--------- >
;�ய��뢠��� ���⠫��஬ (stsec.exe) ��ࠬ���� (���, �஬� ᨣ������)

ultraBootSign	DB '(c)AlexCorp. 1999. Ultra Booter 1.0' 
				      ;�ᯮ������ ����� �����稪�� ��� 
				      ;��।������ ���ன�⢠, �� ���஥ �� �ய�ᠭ
				      ;� ��� ���᪠ ���⮯�������� ��室����
				      ;��࠭񭭮�� ����㧮筮�� ᥪ��

bootDevice	DB 	80h	      ;��. ����� ����. 

trackSect_SBoot	DW	0h	      ;��������� ���筮�� ����.
head_SBoot	DB	0h
nSectors_SBoot	DB	0h

trackSect_OBoot	DW	0h	      ;��������� ��室���� ����. ᥪ�� (��-��. ����� ����.),
				      ;�⮡� ����㧨�� �, �� �뫮 ��⠭������ �� ����
head_OBoot	DB	0h
nSectors_OBoot	DB	1h	      ;���筮 = 1

;<--------- ����� ����� ��ࠬ��஢ �����稪�--------- >


msgWelcome		db	CR, LF, 'Starting Ultrabooter V1.0 (c)AlexCorp...', CR, LF
SIZE_msgWelcome		equ	$ - msgWelcome

msgOK		        db	'Secondary booter is loaded. Transfering control...', CR, LF
SIZE_msgOK		equ	$ - msgOK

msgError		db	CR,LF, 'I/O error.', CR, LF
			db	'Press any key to reboot.', CR, LF
SIZE_msgError		equ	$ - msgError



L_FBOOT:	
	mov	ax, FBOOT_SEG	;����ன�� ᥣ������ ॣ���஢
	mov	ds, ax
	mov	es, ax	

	cli			;����ன�� ᮡ�⢥����� �⥪�
	mov	sp, FBOOT_STACK_TOP
	mov	ss, ax
	sti

	;mov 	cx, 40h
     	;mov     gs, cx
     	;xor 	cx, cx

     	;mov	dl, byte ptr gs:[4Ah] ;number columns
     	;dec	dl
     	;mov	dh, byte ptr gs:[84h] ;number rows
     	;mov	bh, 7h
     	;mov	ax, 600h ;clear window
     	;int	10h	;���⪠ �࠭�

	mov	ah, 3	;������� ⥪���� ������ �����
	xor	bh, bh
	int	10h

	mov	ax, 1301h	;�뢮� ��ப�
	mov	bx, 0002h
	mov	cx, SIZE_msgWelcome
	;xor	dx, dx
	mov	bp, OFFSET msgWelcome
        int	10h

	mov	ax, SBOOT_SEG	;����㧪� ��ࠬ��஢ ��� Int13, �⮡�
	mov	es, ax		;����� ����� �����稪
	xor	bx, bx
	mov	al, nSectors_SBoot
	mov	cx, trackSect_SBoot
	mov	dh, head_SBoot 
	mov	dl, bootDevice
	call	RedInto		;�⥭�� ���筮�� �����稪�

	jc	@@L_CANT_BOOT	;���室 �� �訡�� 

	mov	ah, 3	;������� ⥪���� ������ �����
	xor	bh, bh
	int	10h

	mov	ax, FBOOT_SEG
	mov	es, ax
	mov	ax, 1301h	;�뢥�� ��ப� ⥪��
	mov	bx, 0002h
	mov	cx, SIZE_msgOK
	;mov	dx, 0100h
	mov	bp, OFFSET msgOK
        int	10h

	mov	ax, SBOOT_SEG	;����ன�� ᥣ�. ॣ���஢ ��� ���筮�� ����.
	mov	es, ax
	mov	ds, ax
	mov	gs, ax	

	cli
	mov	sp, SBOOT_STACK_TOP	;����ன�� �⥪� ���筮�� ����.
	mov	ss, ax
	sti
	
        DB	0EAh 		;jmp � ��砫� ���� ���筮�� �����稪�
	DW	0h
	DW      SBOOT_SEG

@@L_CANT_BOOT:
	mov	ah, 3	;������� ⥪���� ������ �����
	xor	bh, bh
	int	10h

 	mov	ax, FBOOT_SEG
	mov	es, ax
	mov	ax, 1301h	;�뢥�� ��ப� ⥪��
	mov	bx, 000Ch
	mov	cx, SIZE_msgError
	;mov	dx, 0200h
	mov	bp, OFFSET msgError	
        int	10h

	xor	ax, ax		;�������� ������ ������
	int	16h

	xor	ax, ax		;��襬 � ������� ������ BIOS ��稭�
	mov	ds, ax		;��१���㧪� (Ctrl+Alt+Del)
	mov	word PTR ds:[0472h], 1234h
	DB	0EAh		;jmp �� ��� ����� ��⥬�
	DW	0h
	DW      0FFFFh

RedInto	PROC

	mov	ah, 02h		;�⥭�� ᥪ�஢
	push	ax		;�� ����⪨
	int	13h
	jnc	@@L_OK

	xor	ah, ah		;��� ����஫��஢ (FDD � HDD)
	int	13h

	pop	ax
	push	ax
	int	13h
	jnc	@@L_OK

	xor	ah, ah		
	int	13h

	pop	ax
	push	ax
	int	13h	

@@L_OK:
	pop	ax
	retn

RedInto	ENDP

	ORG	1FEh	
	DW	0AA55h 		;ᨣ����� ���� MBR

MCode ENDS

	END L_START
