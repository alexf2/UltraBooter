.386p

;.model	tiny
smallstack

locals	


INT_TXT	segment para public use16 'CODE'

	ASSUME	cs:INT_TXT	;используем смещение 0 относительно сегмента INT_TXT
				;так как в Int13h будет прописан адрес с нулевым смещением

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
	cmp	ah, 8h ;получить параметры диска
	jz	@@L_KeepDX
	test	dl, 80h	;сохраняем DX только для жёсткого диска
	jz	@@L_RestoreDX
	cmp	ah, 15h ;получить тип жесткого диска
	jz	@@L_KeepDX

@@L_RestoreDX:
	pushf		;эмуляция Int
	call	[cs:_OldInt13]
	pop	dx	;DX становится таким, как был до обмена
	retf	2       ;флаги должны быть такими, как вернул старый Int13h
			;поэтому сохранённый командой Int 13h регистр flags выбрасывается

@@L_KeepDX:
	pushf
	call	[cs:_OldInt13]
	add	sp, 2	;DX был заполнен выходными данными одной из функций Int13h
	retf	2	;поэтому восстановление не требуется


_OldInt13	DD	?
_Drv1		DB	? ;что менять
_Drv2		DB	? ;на что менять

_NewInt13	ENDP

_SIZE_NewInt13	DW	$ - _NewInt13



INT_TXT	ends

	PUBLIC	_NewInt13, _SIZE_NewInt13, _OldInt13, _Drv1, _Drv2

	end 
