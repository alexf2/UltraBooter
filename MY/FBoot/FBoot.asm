.386
.model use16 tiny

SmallStack
Locals

	CR      	equ 0Dh
	LF      	equ 0Ah

	FBOOT_SEG	equ 7C0h	

	FBOOT_STACK_TOP	equ 3FEh   ; размер стека = 1022 минус длина кода загр.
	SBOOT_STACK_TOP	equ 0FFFEh ; для вторичного загорузчика
				   ; установит стек на конец сегмента 64K			
	
	SBOOT_SEG	equ 800h ; 7C0h + 1024b
				 ; сюда будет загружен вторичный загрузчик


MCode	SEGMENT byte public use16 'code'
	ASSUME	cs:MCode, ds:MCode, es:MCode, gs:MCode

L_START:
	jmp		L_FBOOT

	ORG	3Eh 	;пропустить форматированную область загрузочного сектора (62b)
			;эта область заполняется инсталятором (stsec.exe) данными
			;считанными из исходной загр. записи

;<--------- начало блока параметров загрузчика--------- >
;прописываемые инсталятором (stsec.exe) параметры (всё, кроме сигнатуры)

ultraBootSign	DB '(c)AlexCorp. 1999. Ultra Booter 1.0' 
				      ;используется вторичным загрузчиком для 
				      ;определения устройства, на которое он прописан
				      ;и для поиска местоположения исходного
				      ;сохранённого загрузочного сектора

bootDevice	DB 	80h	      ;исп. вторичным загр. 

trackSect_SBoot	DW	0h	      ;положение вторичного загр.
head_SBoot	DB	0h
nSectors_SBoot	DB	0h

trackSect_OBoot	DW	0h	      ;положение исходного загр. сектора (исп-ся. вторичным загр.),
				      ;чтобы загрузить то, что было установлено до него
head_OBoot	DB	0h
nSectors_OBoot	DB	1h	      ;обычно = 1

;<--------- конец блока параметров загрузчика--------- >


msgWelcome		db	CR, LF, 'Starting Ultrabooter V1.0 (c)AlexCorp...', CR, LF
SIZE_msgWelcome		equ	$ - msgWelcome

msgOK		        db	'Secondary booter is loaded. Transfering control...', CR, LF
SIZE_msgOK		equ	$ - msgOK

msgError		db	CR,LF, 'I/O error.', CR, LF
			db	'Press any key to reboot.', CR, LF
SIZE_msgError		equ	$ - msgError



L_FBOOT:	
	mov	ax, FBOOT_SEG	;настройка сегментных регисторов
	mov	ds, ax
	mov	es, ax	

	cli			;настройка собственного стека
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
     	;int	10h	;очистка экрана

	mov	ah, 3	;получить текущую позицию курсора
	xor	bh, bh
	int	10h

	mov	ax, 1301h	;вывод строки
	mov	bx, 0002h
	mov	cx, SIZE_msgWelcome
	;xor	dx, dx
	mov	bp, OFFSET msgWelcome
        int	10h

	mov	ax, SBOOT_SEG	;загрузка параметров для Int13, чтобы
	mov	es, ax		;считать вторичный загрузчик
	xor	bx, bx
	mov	al, nSectors_SBoot
	mov	cx, trackSect_SBoot
	mov	dh, head_SBoot 
	mov	dl, bootDevice
	call	RedInto		;чтение вторичного загрузчика

	jc	@@L_CANT_BOOT	;переход при ошибке 

	mov	ah, 3	;получить текущую позицию курсора
	xor	bh, bh
	int	10h

	mov	ax, FBOOT_SEG
	mov	es, ax
	mov	ax, 1301h	;вывести строку текста
	mov	bx, 0002h
	mov	cx, SIZE_msgOK
	;mov	dx, 0100h
	mov	bp, OFFSET msgOK
        int	10h

	mov	ax, SBOOT_SEG	;настройка сегм. регистров для вторичного загр.
	mov	es, ax
	mov	ds, ax
	mov	gs, ax	

	cli
	mov	sp, SBOOT_STACK_TOP	;настройка стека вторичному загр.
	mov	ss, ax
	sti
	
        DB	0EAh 		;jmp в начало кода вторичного загрузчика
	DW	0h
	DW      SBOOT_SEG

@@L_CANT_BOOT:
	mov	ah, 3	;получить текущую позицию курсора
	xor	bh, bh
	int	10h

 	mov	ax, FBOOT_SEG
	mov	es, ax
	mov	ax, 1301h	;вывести строку текста
	mov	bx, 000Ch
	mov	cx, SIZE_msgError
	;mov	dx, 0200h
	mov	bp, OFFSET msgError	
        int	10h

	xor	ax, ax		;ожидание нажатия клавиши
	int	16h

	xor	ax, ax		;пишем в область данных BIOS причину
	mov	ds, ax		;перезагрузки (Ctrl+Alt+Del)
	mov	word PTR ds:[0472h], 1234h
	DB	0EAh		;jmp на точку рестарта системы
	DW	0h
	DW      0FFFFh

RedInto	PROC

	mov	ah, 02h		;чтение секторов
	push	ax		;три попытки
	int	13h
	jnc	@@L_OK

	xor	ah, ah		;сброс контроллеров (FDD и HDD)
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
	DW	0AA55h 		;сигнатура конца MBR

MCode ENDS

	END L_START
