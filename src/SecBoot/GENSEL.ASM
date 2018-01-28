	.386p
	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
	endif
	?debug	V 300h
	?debug	S "GENSEL.C"
	?debug	C E9D0A297270847454E53454C2E43
	?debug	C E94019CA1819453A5C424F524C414E44435C494E434C5544455C44+
	?debug	C 4F532E48
	?debug	C E94019CA181B453A5C424F524C414E44435C494E434C5544455C5F+
	?debug	C 444546532E48
	?debug	C E94019CA181C453A5C424F524C414E44435C494E434C5544455C53+
	?debug	C 5452494E472E48
	?debug	C E94019CA181B453A5C424F524C414E44435C494E434C5544455C5F+
	?debug	C 4E554C4C2E48
	?debug	C E91AA297270847454E53454C2E48
	?debug	C E96B998B27084454595045532E48
	?debug	C E94019CA181B453A5C424F524C414E44435C494E434C5544455C53+
	?debug	C 5444494F2E48
	?debug	C E94019CA181C453A5C424F524C414E44435C494E434C5544455C5F+
	?debug	C 4E46494C452E48
_TEXT	segment byte public use16 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public use16 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public use16 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_TEXT	segment byte public use16 'CODE'
	assume	cs:_TEXT
_PrepareScreen	proc	near
	push	bp
	mov	bp,sp
	pushf	
	push		bp
	mov	 	cx, 40h
	mov	        gs, cx
	xor	 	cx, cx
	mov		dl, byte ptr gs:[4Ah] 
	dec		dl
	mov		dh, byte ptr gs:[84h] 
	mov		bh, 7h
	mov		ax, 600h 
	int		10h
	mov		bh, 1Eh 
	mov		dh, 0
	mov		ax, 600h
	int		10h
	mov		dh, byte ptr gs:[84h]
	mov		ch, dh
	mov		ax, 600h
	int		10h  
	mov		ax, 200h 
	xor		bh, bh
	xor		dx, dx
	int		10h
	;	mov	ah, 0ah 
	;	mov	al, 205
	mov		ax, 0ACDh
	xor		bh, bh
	movzx		cx, byte ptr gs:[4Ah]
	int		10h
	xor		dx, dx
	mov		dl, 2
	mov		bl, 1Fh
	push		cs
	pop		es
	lea		bp, cs:sAlex
	mov		cx, LEN_sAlex
	mov		ax, 1300h
	int		10h
	mov		ax, 200h 
	mov		dl, 0
	mov		dh, byte ptr gs:[84h]
	int		10h
	;	mov	ah, 0ah 
	;	mov	al, 205
	mov		ax, 0ACDh
	movzx		cx, byte ptr gs:[4Ah]
	int		10h
	mov		dh, byte ptr gs:[84h]
	mov		dl, byte ptr gs:[4Ah]
	sub		dl, LEN_sUB + 2
	lea		bp, cs:sUB
	mov		cx, LEN_sUB
	mov		ax, 1300h
	int		10h
	pop		bp
	popf	
	jmp	short @1@1738
	sAlex	  db ' ', 196, 196, 205, 205, '(c)AlexCorp.  1999', 205, 205, 196, 196, ' '
	LEN_sAlex	 = $ - sAlex
	sUB	  db ' ', 196, 196, 205, 205, 'Ultra booter V1.0', 205, 205, 196, 196, ' '
	LEN_sUB	 = $ - sUB
@1@1738:
	pop	bp
	ret	
_PrepareScreen	endp
	assume	cs:_TEXT
ShowEmpty	proc	near
	push	bp
	mov	bp,sp
	push	-1
	push	12
	push	-1
	push	offset DGROUP:s@
	call	near ptr _OutStr
	add	sp,8
	mov	al,255
	jmp	short @2@58
@2@58:
	pop	bp
	ret	
ShowEmpty	endp
	assume	cs:_TEXT
_OutStr	proc	near
	enter	6,0
	push	word ptr [bp+4]
	call	near ptr _strlen
	pop	cx
	mov	word ptr [bp-6],ax
	cmp	word ptr [bp+10],-1
	jne	short @3@86
	mov	dword ptr [bp-4],large 00040004Ah
	les	bx,dword ptr [bp-4]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	sub	ax,word ptr [bp-6]
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	word ptr [bp+10],ax
@3@86:
	cmp	word ptr [bp+6],-1
	jne	short @3@142
	mov	dword ptr [bp-4],large 000400084h
	les	bx,dword ptr [bp-4]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	inc	ax
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	word ptr [bp+6],ax
@3@142:
	pushf	
	push		bp
	mov		ax, 1300h
	xor		bh, bh
	mov		bl, [bp+8]
	mov		cx, [bp-6]
	mov		dh, [bp+6]
	mov		dl, [bp+10]
	push		ds
	pop		es
	mov		bp, [bp+4]
	int		10h
	pop		bp
	popf	
	leave	
	ret	
_OutStr	endp
	assume	cs:_TEXT
_SetScrAttribs	proc	near
	enter	16,0
	mov	dword ptr [bp-4],large 000400063h
	les	bx,dword ptr [bp-4]
	cmp	word ptr es:[bx],980
	jne	short @4@86
	mov	ax,00000B800h
	jmp	short @4@114
@4@86:
	mov	ax,00000B000h
@4@114:
	mov	word ptr [bp-6],ax
	mov	dword ptr [bp-10],large 00040004Ah
	mov	al,byte ptr [bp+4]
	mov	ah,0
	shl	ax,1
	les	bx,dword ptr [bp-10]
	mov	dl,byte ptr es:[bx]
	mov	dh,0
	imul	dx
	mov	dl,byte ptr [bp+6]
	mov	dh,0
	shl	dx,1
	add	ax,dx
	mov	dx,word ptr [bp-6]
	mov	word ptr [bp-12],dx
	mov	word ptr [bp-14],ax
	mov	al,byte ptr [bp+8]
	mov	ah,0
	mov	dl,byte ptr [bp+6]
	mov	dh,0
	sub	ax,dx
	mov	word ptr [bp-16],ax
	inc	word ptr [bp-14]
	jmp	short @4@198
@4@142:
	les	bx,dword ptr [bp-14]
	mov	al,byte ptr [bp+10]
	mov	byte ptr es:[bx],al
	dec	word ptr [bp-16]
	add	word ptr [bp-14],2
@4@198:
	cmp	word ptr [bp-16],0
	jge	short @4@142
	leave	
	ret	
_SetScrAttribs	endp
	assume	cs:_TEXT
_GenericInteractiveSelect	proc	near
	enter	22,0
	mov	word ptr [bp-4],0
	mov	dword ptr [bp-18],large 00040004Ah
	mov	bx,word ptr [bp+4]
	cmp	byte ptr [bx+1200],255
	jne	short @5@114
	push	word ptr [bp+4]
	call	near ptr ShowEmpty
	pop	cx
@5@86:
	jmp	@5@1430
@5@114:
	call	near ptr _PrepareScreen
	mov	word ptr [bp-2],0
	jmp	short @5@226
@5@142:
	mov	ax,word ptr [bp-2]
	imul	ax,ax,80
	mov	dx,word ptr [bp+4]
	add	dx,ax
	push	dx
	call	near ptr _strlen
	pop	cx
	mov	word ptr [bp-6],ax
	mov	ax,word ptr [bp-6]
	cmp	ax,word ptr [bp-4]
	jle	short @5@198
	mov	ax,word ptr [bp-6]
	mov	word ptr [bp-4],ax
@5@198:
	inc	word ptr [bp-2]
@5@226:
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr [bx+1201]
	mov	ah,0
	cmp	ax,word ptr [bp-2]
	jge	short @5@142
	les	bx,dword ptr [bp-18]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	sub	ax,word ptr [bp-4]
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	byte ptr [bp-19],al
	mov	dword ptr [bp-18],large 000400084h
	les	bx,dword ptr [bp-18]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	mov	bx,word ptr [bp+4]
	mov	dl,byte ptr [bx+1201]
	mov	dh,0
	sub	ax,dx
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	byte ptr [bp-20],al
	mov	word ptr [bp-2],0
	jmp	short @5@338
@5@282:
	push	-1
	push	15
	mov	al,byte ptr [bp-20]
	mov	ah,0
	push	ax
	mov	ax,word ptr [bp-2]
	imul	ax,ax,80
	mov	dx,word ptr [bp+4]
	add	dx,ax
	push	dx
	call	near ptr _OutStr
	add	sp,8
	inc	word ptr [bp-2]
	mov	al,byte ptr [bp-20]
	inc	al
	mov	byte ptr [bp-20],al
@5@338:
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr [bx+1200]
	mov	ah,0
	cmp	ax,word ptr [bp-2]
	jg	short @5@282
	mov	al,byte ptr [bp-20]
	mov	byte ptr [bp-7],al
	mov	byte ptr [bp-9],al
	mov	byte ptr [bp-10],al
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr [bx+1200]
	mov	ah,0
	mov	word ptr [bp-2],ax
	jmp	short @5@450
@5@394:
	mov	al,byte ptr [bp-19]
	mov	ah,0
	push	ax
	push	10
	mov	al,byte ptr [bp-20]
	mov	ah,0
	push	ax
	mov	ax,word ptr [bp-2]
	imul	ax,ax,80
	mov	dx,word ptr [bp+4]
	add	dx,ax
	push	dx
	call	near ptr _OutStr
	add	sp,8
	inc	word ptr [bp-2]
	mov	al,byte ptr [bp-20]
	inc	al
	mov	byte ptr [bp-20],al
@5@450:
	mov	bx,word ptr [bp+4]
	mov	al,byte ptr [bx+1201]
	mov	ah,0
	cmp	ax,word ptr [bp-2]
	jge	short @5@394
	mov	al,byte ptr [bp-20]
	add	al,255
	mov	byte ptr [bp-8],al
	mov	al,byte ptr [bp-19]
	add	al,byte ptr [bp-4]
	inc	al
	mov	byte ptr [bp-11],al
	cmp	byte ptr [bp-19],1
	jbe	short @5@534
	mov	al,byte ptr [bp-19]
	add	al,255
	mov	byte ptr [bp-19],al
@5@534:
	push	10
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,byte ptr [bp-19]
	push	ax
	mov	al,byte ptr [bp-9]
	push	ax
	call	near ptr _SetScrAttribs
	add	sp,8
	push	159
	mov	al,byte ptr [bp-11]
	push	ax
	mov	al,byte ptr [bp-19]
	push	ax
	mov	al,byte ptr [bp-10]
	push	ax
	call	near ptr _SetScrAttribs
	add	sp,8
	mov	al,byte ptr [bp-10]
	mov	byte ptr [bp-9],al
	mov	byte ptr [bp-13],1
@5@562:
	pushf	
	push		ax
	xor		ax, ax
	int		16h
	test		al, al
	je	short @5@786
	mov		[bp-12], al
	jmp	short @5@814
@5@786:
	mov		[bp-12], ah
@5@814:
	pop		ax
	popf	
	mov	al,byte ptr [bp-12]
	mov	ah,0
	mov	word ptr [bp-22],ax
	mov	cx,6
	mov	bx,offset @5@C1282
@5@926:
	mov	ax,word ptr cs:[bx]
	cmp	ax,word ptr [bp-22]
	je	short @5@1010
	add	bx,2
	loop	short @5@926
	jmp	short @5@1374
@5@1010:
	jmp	word ptr cs:[bx+12]
@5@1038:
	mov	al,byte ptr [bp-9]
	cmp	al,byte ptr [bp-7]
	jbe	short @5@1094
	mov	al,byte ptr [bp-9]
	add	al,255
	jmp	short @5@1122
@5@1094:
	mov	al,byte ptr [bp-8]
@5@1122:
	mov	byte ptr [bp-10],al
@5@1150:
	mov	byte ptr [bp-13],0
	jmp	short @5@1374
@5@1178:
	mov	al,byte ptr [bp-9]
	cmp	al,byte ptr [bp-8]
	jae	short @5@1234
	mov	al,byte ptr [bp-9]
	inc	al
	jmp	short @5@1262
@5@1234:
	mov	al,byte ptr [bp-7]
@5@1262:
	mov	byte ptr [bp-10],al
	jmp	short @5@1150
@5@1318:
	mov	al,byte ptr [bp-9]
	sub	al,byte ptr [bp-7]
	jmp	@5@86
@5@1346:
	mov	al,255
	jmp	@5@86
@5@1374:
	cmp	byte ptr [bp-13],0
	je short	@@0
	jmp	@5@562
@@0:
	jmp	@5@534
@5@1430:
	leave	
	ret	
_GenericInteractiveSelect	endp
@5@C1282	label	word
	db	13
	db	0
	db	27
	db	0
	db	72
	db	0
	db	75
	db	0
	db	77
	db	0
	db	80
	db	0
	dw	@5@1318
	dw	@5@1346
	dw	@5@1038
	dw	@5@1038
	dw	@5@1178
	dw	@5@1178
	assume	cs:_TEXT
_ReportErr	proc	near
	enter	8,0
	push	word ptr [bp+4]
	call	near ptr _strlen
	pop	cx
	mov	word ptr [bp-2],ax
	mov	dword ptr [bp-6],large 00040004Ah
	les	bx,dword ptr [bp-6]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	sub	ax,word ptr [bp-2]
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	byte ptr [bp-7],al
	mov	dword ptr [bp-6],large 000400084h
	les	bx,dword ptr [bp-6]
	mov	al,byte ptr es:[bx]
	mov	ah,0
	inc	ax
	cwd	
	sub	ax,dx
	sar	ax,1
	mov	byte ptr [bp-8],al
	pushf	
	push		bp
	mov	 	cx, 40h
	mov	        gs, cx
	xor	 	cx, cx
	mov		dl, byte ptr gs:[4Ah] 
	dec		dl
	mov		dh, byte ptr gs:[84h] 
	mov		bh, 7h
	;	xor	al, al
	;	mov	ah, 6h 
	mov		ax, 600h
	int		10h
	xor		bh, bh
	mov		bl, [bp+6] 
	mov	 	cx, [bp-2]
	mov		dh, [bp-8]
	mov		dl, [bp-7]
	push		ds
	pop		es
	mov		ax, [bp+4]
	mov		bp, ax
	mov		ax, 1300h
	int		10h
	xor		ax, ax
	int		16h
	pop		bp
	popf	
	leave	
	ret	
_ReportErr	endp
	assume	cs:_TEXT
_MkQuery	proc	near
	enter	2,0
	push	-1
	push	12
	push	-1
	push	word ptr [bp+4]
	call	near ptr _OutStr
	add	sp,8
	xor		ax, ax
	int		16h
	mov		[bp-1], al
	mov	al,byte ptr [bp-1]
	mov	ah,0
	push	ax
	call	near ptr _toupper
	pop	cx
	push	ax
	mov	al,byte ptr [bp+6]
	cbw	
	pop	dx
	cmp	dx,ax
	jne	short @7@198
	mov	ax,1
	jmp	short @7@226
@7@198:
	xor	ax,ax
@7@226:
	jmp	short @7@254
@7@254:
	leave	
	ret	
_MkQuery	endp
	?debug	C E9
	?debug	C FA00000000
_TEXT	ends
_DATA	segment word public use16 'DATA'
s@	label	byte
	db	'No drives accessible'
	db	0
_DATA	ends
_TEXT	segment byte public use16 'CODE'
_TEXT	ends
	extrn	_toupper:near
_ShowEmpty	equ	ShowEmpty
	public	_MkQuery
	public	_SetScrAttribs
	public	_OutStr
	public	_ReportErr
	public	_GenericInteractiveSelect
	public	_PrepareScreen
	extrn	_strlen:near
_s@	equ	s@
	end
