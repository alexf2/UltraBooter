.386p

;.model	tiny
smallstack

locals	


INT_TXT	segment para public use16 'CODE'

	ASSUME	cs:INT_TXT	;�ᯮ��㥬 ᬥ饭�� 0 �⭮�⥫쭮 ᥣ���� INT_TXT
				;⠪ ��� � Int13h �㤥� �ய�ᠭ ���� � �㫥�� ᬥ饭���

_NewInt13	PROC FAR

        push	dx
	cmp	dl, cs:_Drv1
	jz	@@L_Swap1
	cmp	dl, cs:_Drv2
	jz	@@L_Swap2

	pop	dx
	jmp	[cs:_OldInt13]

@@L_Swap1:	
	mov	dl, cs:_Drv2
	jmp	short @@L_Next
@@L_Swap2:	
	mov	dl, cs:_Drv1

@@L_Next:
	cmp	ah, 8h ;������� ��ࠬ���� ��᪠
	jz	@@L_KeepDX
	test	dl, 80h	;��࠭塞 DX ⮫쪮 ��� ���⪮�� ��᪠
	jz	@@L_RestoreDX
	cmp	ah, 15h ;������� ⨯ ���⪮�� ��᪠
	jz	@@L_KeepDX

@@L_RestoreDX:
	pushf		;����� Int
	call	[cs:_OldInt13]
	pop	dx	;DX �⠭������ ⠪��, ��� �� �� ������
	retf	2       ;䫠�� ������ ���� ⠪���, ��� ���� ���� Int13h
			;���⮬� ��࠭�� �������� Int 13h ॣ���� flags ����뢠����

@@L_KeepDX:
	pushf
	call	[cs:_OldInt13]
	add	sp, 2	;DX �� �������� ��室�묨 ����묨 ����� �� �㭪権 Int13h
	retf	2	;���⮬� ����⠭������� �� �ॡ����


_OldInt13	DD	?
_Drv1		DB	? ;�� ������
_Drv2		DB	? ;�� �� ������

_NewInt13	ENDP

_SIZE_NewInt13	DW	$ - _NewInt13



INT_TXT	ends

	PUBLIC	_NewInt13, _SIZE_NewInt13, _OldInt13, _Drv1, _Drv2

	end 
