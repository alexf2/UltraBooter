	.386p
	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
	endif
	?debug	V 300h
	?debug	S "DRVFUNC.C"
	?debug	C E9B98E27280944525646554E432E43
	?debug	C E94019CA1819453A5C424F524C414E44435C494E434C5544455C44+
	?debug	C 4F532E48
	?debug	C E94019CA181B453A5C424F524C414E44435C494E434C5544455C5F+
	?debug	C 444546532E48
	?debug	C E94019CA181C453A5C424F524C414E44435C494E434C5544455C4D+
	?debug	C 454D4F52592E48
	?debug	C E94019CA1819453A5C424F524C414E44435C494E434C5544455C4D+
	?debug	C 454D2E48
	?debug	C E94019CA181B453A5C424F524C414E44435C494E434C5544455C5F+
	?debug	C 4E554C4C2E48
	?debug	C E94019CA181B453A5C424F524C414E44435C494E434C5544455C53+
	?debug	C 5444494F2E48
	?debug	C E94019CA181C453A5C424F524C414E44435C494E434C5544455C5F+
	?debug	C 4E46494C452E48
	?debug	C E94019CA181C453A5C424F524C414E44435C494E434C5544455C53+
	?debug	C 5452494E472E48
	?debug	C E97DA097270944525646554E432E48
	?debug	C E96B998B27084454595045532E48
	?debug	C E91AA297270847454E53454C2E48
	?debug	C E96B998B27084454595045532E48
	?debug	C E92E829A271053544F525345435C4445544543542E48
	?debug	C E96B998B27084454595045532E48
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
	db	128 dup (?)
_BSS	ends
_TEXT	segment byte public use16 'CODE'
	assume	cs:_TEXT
_GetTextDescr	proc	near
	push	bp
	mov	bp,sp
	cmp	byte ptr [bp+4],3
	ja	short @1@86
	mov	al,byte ptr [bp+4]
	mov	ah,0
	add	ax,65
	push	ax
	push	offset DGROUP:s@
	push	offset DGROUP:b@w+0
	call	near ptr _sprintf
	add	sp,6
	jmp	short @1@282
@1@86:
	cmp	byte ptr [bp+4],128
	jb	short @1@170
	cmp	byte ptr [bp+4],131
	ja	short @1@170
	mov	al,byte ptr [bp+4]
	mov	ah,0
	add	ax,-127
	push	ax
	push	offset DGROUP:s@+16
	push	offset DGROUP:b@w+0
	call	near ptr _sprintf
	add	sp,6
	jmp	short @1@282
@1@170:
	cmp	byte ptr [bp+4],255
	jne	short @1@226
	push	offset DGROUP:s@+29
	jmp	short @1@254
@1@226:
	push	offset DGROUP:s@+37
@1@254:
	push	offset DGROUP:b@w+0
	call	near ptr _sprintf
	add	sp,4
@1@282:
	mov	ax,offset DGROUP:b@w+0
	jmp	short @1@310
@1@310:
	pop	bp
	ret	
_GetTextDescr	endp
	assume	cs:_TEXT
_CheckMountedDrv	proc	near
	push	bp
	mov	bp,sp
	pushf	
	mov		ah, 15h  
	mov		dl, [bp+4]
	int		13h
	jc	short @2@310
	cmp		ah, 0
	setnz		al
	xor		ah, ah
	popf	
	jmp	short @2@366
@2@310:
	xor		ax, ax
	popf	
@2@366:
	pop	bp
	ret	
_CheckMountedDrv	endp
	assume	cs:_TEXT
_DetectDrives	proc	near
	enter	8,0
	mov	byte ptr [bp-1],0
	mov	dword ptr [bp-6],large 000400010h
	push	-1
	push	8
	push	word ptr [bp+4]
	call	near ptr _setmem
	add	sp,6
	les	bx,dword ptr [bp-6]
	mov	al,byte ptr es:[bx]
	and	ax,1
	or	ax,ax
	je	short @3@198
	mov	word ptr [bp-8],0
	jmp	short @3@170
@3@86:
	mov	al,byte ptr [bp-8]
	push	ax
	call	near ptr _CheckMountedDrv
	pop	cx
	cmp	al,1
	jne	short @3@142
	mov	al,byte ptr [bp-1]
	mov	ah,0
	mov	bx,word ptr [bp+4]
	add	bx,ax
	mov	al,byte ptr [bp-8]
	mov	byte ptr [bx],al
	inc	byte ptr [bp-1]
@3@142:
	inc	word ptr [bp-8]
@3@170:
	cmp	word ptr [bp-8],4
	jl	short @3@86
@3@198:
	mov	word ptr [bp-8],128
	jmp	short @3@310
@3@226:
	mov	al,byte ptr [bp-8]
	push	ax
	call	near ptr _CheckMountedDrv
	pop	cx
	cmp	al,1
	jne	short @3@282
	mov	al,byte ptr [bp-1]
	mov	ah,0
	mov	bx,word ptr [bp+4]
	add	bx,ax
	mov	al,byte ptr [bp-8]
	mov	byte ptr [bx],al
	inc	byte ptr [bp-1]
@3@282:
	inc	word ptr [bp-8]
@3@310:
	cmp	word ptr [bp-8],132
	jl	short @3@226
	leave	
	ret	
_DetectDrives	endp
	assume	cs:_TEXT
_InteractiveSelectDrv	proc	near
	enter	4,0
	push	offset DGROUP:s@+47
	push	word ptr [bp+6]
	call	near ptr _sprintf
	add	sp,4
	push	offset DGROUP:s@+76
	mov	ax,word ptr [bp+6]
	add	ax,80
	push	ax
	call	near ptr _sprintf
	add	sp,4
	mov	bx,word ptr [bp+6]
	mov	byte ptr [bx+1200],2
	mov	word ptr [bp-2],0
	mov	word ptr [bp-4],2
	jmp	short @4@226
@4@58:
	mov	bx,word ptr [bp+4]
	add	bx,word ptr [bp-2]
	cmp	byte ptr [bx],255
	je	short @4@198
	mov	bx,word ptr [bp+4]
	add	bx,word ptr [bp-2]
	cmp	byte ptr [bx],128
	jb	short @4@142
	mov	ax,offset DGROUP:s@+86
	jmp	short @4@170
@4@142:
	mov	ax,offset DGROUP:s@+90
@4@170:
	push	ax
	mov	bx,word ptr [bp+4]
	add	bx,word ptr [bp-2]
	mov	al,byte ptr [bx]
	push	ax
	call	near ptr _GetTextDescr
	pop	cx
	push	ax
	mov	ax,word ptr [bp-4]
	dec	ax
	push	ax
	push	offset DGROUP:s@+77
	mov	ax,word ptr [bp-4]
	imul	ax,ax,80
	mov	dx,word ptr [bp+6]
	add	dx,ax
	push	dx
	call	near ptr _sprintf
	add	sp,10
	inc	word ptr [bp-4]
@4@198:
	inc	word ptr [bp-2]
@4@226:
	cmp	word ptr [bp-2],8
	jl	short @4@58
	cmp	word ptr [bp-4],2
	jne	short @4@310
	mov	bx,word ptr [bp+6]
	mov	al,255
	mov	byte ptr [bx+1201],al
	mov	bx,word ptr [bp+6]
	mov	byte ptr [bx+1200],al
	jmp	short @4@338
@4@310:
	mov	bx,word ptr [bp+6]
	mov	byte ptr [bx+1200],2
	mov	al,byte ptr [bp-4]
	add	al,255
	mov	bx,word ptr [bp+6]
	mov	byte ptr [bx+1201],al
@4@338:
	push	word ptr [bp+6]
	call	near ptr _GenericInteractiveSelect
	pop	cx
	mov	ah,0
	mov	word ptr [bp-2],ax
	cmp	word ptr [bp-2],255
	jne	short @4@394
	mov	al,255
	jmp	short @4@422
@4@394:
	mov	bx,word ptr [bp+4]
	add	bx,word ptr [bp-2]
	mov	al,byte ptr [bx]
@4@422:
	jmp	short @4@450
@4@450:
	leave	
	ret	
_InteractiveSelectDrv	endp
	assume	cs:_TEXT
ReadMBRInto	proc	near
	enter	518,0
	push	si
	push	di
	mov	ax,word ptr [bp+8]
	shr	ax,8
	and	ax,3
	mov	dx,word ptr [bp+8]
	shl	dx,2
	and	dx,1020
	or	ax,dx
	shl	ax,6
	mov	dx,word ptr [bp+6]
	and	dx,63
	or	ax,dx
	mov	word ptr [bp-2],ax
	cmp	byte ptr [bp+4],128
	jb short	@@1
	jmp	@5@674
@@1:
	pushf	
	mov		ah, 16h 
	mov		dl, [bp+4]
	int		13h
	cmp		ah, 6
	jne	short @5@534
	mov		ah, 8 
	mov		dl, [bp+4]
	int		13h
	jc	short @5@618
	mov		[bp-4], cx
	mov	ax,word ptr [bp-4]
	shr	ax,6
	and	al,3
	shl	al,8
	mov	dx,word ptr [bp-4]
	shr	dx,8
	and	dl,255
	or	al,dl
	inc	al
	mov	byte ptr [bp-5],al
	mov	al,byte ptr [bp-4]
	and	al,63
	mov	byte ptr [bp-6],al
	mov		ah, 18h 
	mov		ch, [bp-5]
	mov		cl, [bp-6]
	mov		dl, [bp+4]
	int		13h
@5@534:
	popf	
	mov		bx, OFFSET L_ReadOK_ReadMBRInto
	jmp	 	bx
@5@618:
 	popf	
	mov	al,0
	jmp	@5@1710
@5@674:
	L_ReadOK_ReadMBRInto	:
	pushf	
	push		ds
	mov		cx, [bp-2]
	mov		ax, 0201h 
	mov		dl, [bp+4]
	mov		dh, [bp+10]
	push		cs
	pop		es
	lea		bx, [bp-518]
	int		13h
	jnc	short @5@1206
	mov		ax, 0201h
	int		13h
	jnc	short @5@1206
	mov		ax, 0201h
	int		13h
	mov		ax, 0 
	jc	short @5@1654
@5@1206:
	mov		ax, 1 
	push		ds
	pop		es
	push		cs
	pop		ds
	cmp		[bp+14], 0
	jne	short @5@1514
	lea		si, [bp-518]
	add		si, 446 
	mov		cx, 66 
	jmp	short @5@1570
@5@1514:
	lea		si, [bp-518]
	mov		cx, 512
@5@1570:
	mov		di, [bp+12]
	cld	
	REPE movsb	
@5@1654:
	pop		ds
	popf	
@5@1710:
	pop	di
	pop	si
	leave	
	ret	
ReadMBRInto	endp
	assume	cs:_TEXT
_ExploreDrive_OR_ExPart	proc	near
	enter	6,0
	cmp	word ptr [bp+6],0
	jne short	@@2
	jmp	@6@198
@@2:
	cmp	word ptr [bp+10],0
	jne	short @6@114
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	and	ax,63
	mov	word ptr [bp-2],ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	bx,word ptr [bp+6]
	mov	dx,word ptr [bx+2]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	mov	word ptr [bp-4],ax
	mov	bx,word ptr [bp+6]
	jmp	short @6@142
@6@114:
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	mov	bx,word ptr [bp+10]
	add	ax,word ptr [bx+2]
	and	ax,63
	mov	word ptr [bp-2],ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	mov	bx,word ptr [bp+10]
	add	ax,word ptr [bx+2]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	bx,word ptr [bp+6]
	mov	dx,word ptr [bx+2]
	mov	bx,word ptr [bp+10]
	add	dx,word ptr [bx+2]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	mov	word ptr [bp-4],ax
	mov	bx,word ptr [bp+10]
@6@142:
	mov	al,byte ptr [bx+1]
	mov	ah,0
	mov	word ptr [bp-6],ax
	jmp	short @6@226
@6@198:
	mov	word ptr [bp-2],1
	xor	ax,ax
	mov	word ptr [bp-6],ax
	mov	word ptr [bp-4],ax
@6@226:
	push	0
	push	word ptr [bp+8]
	push	word ptr [bp-6]
	push	word ptr [bp-4]
	push	word ptr [bp-2]
	mov	al,byte ptr [bp+4]
	push	ax
	call	near ptr ReadMBRInto
	add	sp,12
	jmp	short @6@254
@6@254:
	leave	
	ret	
_ExploreDrive_OR_ExPart	endp
_TEXT	ends
_BSS	segment word public use16 'BSS'
	db	80 dup (?)
_BSS	ends
_TEXT	segment byte public use16 'CODE'
	assume	cs:_TEXT
GetTextPresentationOfPart	proc	near
	enter	140,0
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+6]
	and	ax,63
	push	ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+6]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	bx,word ptr [bp+6]
	mov	dx,word ptr [bx+6]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	push	ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	and	ax,63
	push	ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	bx,word ptr [bp+6]
	mov	dx,word ptr [bx+2]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	push	ax
	mov	bx,word ptr [bp+6]
	cmp	byte ptr [bx],128
	jne	short @7@86
	mov	ax,offset DGROUP:s@+121
	jmp	short @7@114
@7@86:
	mov	ax,offset DGROUP:s@+131
@7@114:
	push	ax
	push	offset DGROUP:s@+91
	lea	ax,word ptr [bp-140]
	push	ax
	call	near ptr _sprintf
	add	sp,14
	push	word ptr [bp+4]
	push	offset DGROUP:s@+132
	lea	ax,word ptr [bp-10]
	push	ax
	call	near ptr _sprintf
	add	sp,6
	mov	bx,word ptr [bp+6]
	mov	al,byte ptr [bx+4]
	mov	ah,0
	mov	word ptr [bp-12],ax
	mov	cx,9
	mov	bx,offset @7@C514
@7@198:
	mov	ax,word ptr cs:[bx]
	cmp	ax,word ptr [bp-12]
	je	short @7@282
	add	bx,2
	loop	short @7@198
	jmp	@7@590
@7@282:
	jmp	word ptr cs:[bx+18]
@7@310:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+137
@7@338:
	push	offset DGROUP:b@w+128
	call	near ptr _sprintf
	add	sp,8
	jmp	@7@618
@7@366:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+154
	jmp	short @7@338
@7@394:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+171
	jmp	short @7@338
@7@422:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+188
	jmp	short @7@338
@7@450:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+208
	jmp	short @7@338
@7@478:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+225
	jmp	short @7@338
@7@506:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+242
	jmp	short @7@338
@7@534:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+259
	jmp	short @7@338
@7@562:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+276
	jmp	@7@338
@7@590:
	lea	ax,word ptr [bp-140]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	push	offset DGROUP:s@+293
	jmp	@7@338
@7@618:
	mov	ax,offset DGROUP:b@w+128
	jmp	short @7@646
@7@646:
	leave	
	ret	
GetTextPresentationOfPart	endp
@7@C514	label	word
	db	0
	db	0
	db	1
	db	0
	db	4
	db	0
	db	5
	db	0
	db	6
	db	0
	db	7
	db	0
	db	11
	db	0
	db	12
	db	0
	db	131
	db	0
	dw	@7@310
	dw	@7@366
	dw	@7@394
	dw	@7@422
	dw	@7@450
	dw	@7@478
	dw	@7@506
	dw	@7@534
	dw	@7@562
	assume	cs:_TEXT
GenerateTPOfMBR	proc	near
	push	bp
	mov	bp,sp
	cmp	byte ptr [bp+8],0
	je	short @8@86
	mov	ax,offset DGROUP:s@+337
	jmp	short @8@114
@8@86:
	mov	ax,offset DGROUP:s@+349
@8@114:
	push	ax
	push	offset DGROUP:s@+310
	push	word ptr [bp+4]
	call	near ptr _sprintf
	add	sp,6
	push	offset DGROUP:s@+365
	mov	ax,word ptr [bp+4]
	add	ax,80
	push	ax
	call	near ptr _sprintf
	add	sp,4
	push	word ptr [bp+6]
	push	1
	call	near ptr GetTextPresentationOfPart
	add	sp,4
	push	ax
	mov	ax,word ptr [bp+4]
	add	ax,160
	push	ax
	call	near ptr _sprintf
	add	sp,4
	mov	ax,word ptr [bp+6]
	add	ax,16
	push	ax
	push	2
	call	near ptr GetTextPresentationOfPart
	add	sp,4
	push	ax
	mov	ax,word ptr [bp+4]
	add	ax,240
	push	ax
	call	near ptr _sprintf
	add	sp,4
	mov	ax,word ptr [bp+6]
	add	ax,32
	push	ax
	push	3
	call	near ptr GetTextPresentationOfPart
	add	sp,4
	push	ax
	mov	ax,word ptr [bp+4]
	add	ax,320
	push	ax
	call	near ptr _sprintf
	add	sp,4
	mov	ax,word ptr [bp+6]
	add	ax,48
	push	ax
	push	4
	call	near ptr GetTextPresentationOfPart
	add	sp,4
	push	ax
	mov	ax,word ptr [bp+4]
	add	ax,400
	push	ax
	call	near ptr _sprintf
	add	sp,4
	mov	bx,word ptr [bp+4]
	mov	byte ptr [bx+1200],2
	mov	bx,word ptr [bp+4]
	mov	byte ptr [bx+1201],5
	pop	bp
	ret	
GenerateTPOfMBR	endp
	assume	cs:_TEXT
GetEntry	proc	near
	push	bp
	mov	bp,sp
	mov	al,byte ptr [bp+4]
	mov	ah,0
	mov	bx,ax
	cmp	bx,3
	ja	short @9@254
	shl	bx,1
	jmp	word ptr cs:@9@C290[bx]
@9@114:
	mov	ax,word ptr [bp+6]
@9@142:
	jmp	short @9@282
@9@170:
	mov	ax,word ptr [bp+6]
	add	ax,16
	jmp	short @9@142
@9@198:
	mov	ax,word ptr [bp+6]
	add	ax,32
	jmp	short @9@142
@9@226:
	mov	ax,word ptr [bp+6]
	add	ax,48
	jmp	short @9@142
@9@254:
	xor	ax,ax
	jmp	short @9@142
@9@282:
	pop	bp
	ret	
GetEntry	endp
@9@C290	label	word
	dw	@9@114
	dw	@9@170
	dw	@9@198
	dw	@9@226
	assume	cs:_TEXT
_InteractiveSelectPartition	proc	near
	enter	70,0
@10@30:
	push	66
	push	0
	lea	ax,word ptr [bp-70]
	push	ax
	call	near ptr _memset
	add	sp,6
	cmp	word ptr [bp+8],0
	je	short @10@142
	cmp	word ptr [bp+6],0
	je	short @10@142
	mov	bx,word ptr [bp+8]
	cmp	byte ptr [bx+4],5
	je	short @10@142
	mov	ax,word ptr [bp+6]
	jmp	short @10@170
@10@142:
	xor	ax,ax
@10@170:
	push	ax
	lea	ax,word ptr [bp-70]
	push	ax
	push	word ptr [bp+8]
	mov	al,byte ptr [bp+4]
	push	ax
	call	near ptr _ExploreDrive_OR_ExPart
	add	sp,8
	mov	byte ptr [bp-1],al
	mov	al,byte ptr [bp-1]
	mov	ah,0
	or	ax,ax
	jne	short @10@310
	push	12
	push	offset DGROUP:s@+366
@10@226:
	call	near ptr _ReportErr
	add	sp,4
@10@254:
	mov	al,255
@10@282:
	jmp	@10@954
@10@310:
	cmp	word ptr [bp-6],00000AA55h
	je	short @10@366
	push	12
	push	offset DGROUP:s@+380
	jmp	short @10@226
@10@366:
	cmp	word ptr [bp+8],0
	je	short @10@422
	mov	ax,1
	jmp	short @10@450
@10@422:
	xor	ax,ax
@10@450:
	push	ax
	lea	ax,word ptr [bp-70]
	push	ax
	push	word ptr [bp+12]
	call	near ptr GenerateTPOfMBR
	add	sp,6
	push	word ptr [bp+12]
	call	near ptr _GenericInteractiveSelect
	pop	cx
	mov	byte ptr [bp-1],al
	cmp	byte ptr [bp-1],255
	jne	short @10@506
	jmp	short @10@254
@10@506:
	mov	al,byte ptr [bp-1]
	mov	byte ptr [bp-2],al
	lea	ax,word ptr [bp-70]
	push	ax
	mov	al,byte ptr [bp-1]
	push	ax
	call	near ptr GetEntry
	add	sp,4
	mov	word ptr [bp-4],ax
	cmp	word ptr [bp-4],0
	jne	short @10@562
	push	12
	push	offset DGROUP:s@+418
	jmp	short @10@226
@10@562:
	mov	bx,word ptr [bp-4]
	mov	al,byte ptr [bx+4]
	push	ax
	call	near ptr _IsBootable
	pop	cx
	mov	byte ptr [bp-1],al
	mov	al,byte ptr [bp-1]
	mov	ah,0
	mov	bx,ax
	cmp	bx,3
	ja	short @10@898
	shl	bx,1
	jmp	word ptr cs:@10@C834[bx]
@10@674:
	push	15
	push	offset DGROUP:s@+433
@10@702:
	call	near ptr _ReportErr
	add	sp,4
	jmp	short @10@898
@10@730:
	cmp	word ptr [bp+6],0
	je	short @10@758
@10@758:
	push	66
	lea	ax,word ptr [bp-70]
	push	ax
	push	word ptr [bp+10]
	call	near ptr _memcpy
	add	sp,6
	mov	al,byte ptr [bp-2]
	jmp	@10@282
@10@786:
	push	word ptr [bp+12]
	push	word ptr [bp+10]
	push	word ptr [bp-4]
	push	word ptr [bp-4]
	mov	al,byte ptr [bp+4]
	push	ax
	call	near ptr _InteractiveSelectPartition
	add	sp,10
	mov	byte ptr [bp-1],al
	cmp	byte ptr [bp-1],255
	jne	short @10@842
	jmp	short @10@898
@10@842:
	mov	al,byte ptr [bp-1]
	jmp	@10@282
@10@870:
	push	15
	push	offset DGROUP:s@+457
	jmp	short @10@702
@10@898:
	jmp	@10@30
	jmp	@10@254
@10@954:
	leave	
	ret	
_InteractiveSelectPartition	endp
@10@C834	label	word
	dw	@10@674
	dw	@10@730
	dw	@10@786
	dw	@10@870
	assume	cs:_TEXT
_IsBootable	proc	near
	enter	2,0
	mov	al,byte ptr [bp+4]
	mov	ah,0
	mov	word ptr [bp-2],ax
	mov	cx,9
	mov	bx,offset @11@C306
@11@86:
	mov	ax,word ptr cs:[bx]
	cmp	ax,word ptr [bp-2]
	je	short @11@170
	add	bx,2
	loop	short @11@86
	jmp	short @11@310
@11@170:
	jmp	word ptr cs:[bx+18]
@11@198:
	mov	al,1
@11@226:
	jmp	short @11@338
@11@254:
	mov	al,0
	jmp	short @11@226
@11@282:
	mov	al,2
	jmp	short @11@226
@11@310:
	mov	al,3
	jmp	short @11@226
@11@338:
	leave	
	ret	
_IsBootable	endp
@11@C306	label	word
	db	0
	db	0
	db	1
	db	0
	db	4
	db	0
	db	5
	db	0
	db	6
	db	0
	db	7
	db	0
	db	11
	db	0
	db	12
	db	0
	db	131
	db	0
	dw	@11@254
	dw	@11@198
	dw	@11@198
	dw	@11@282
	dw	@11@198
	dw	@11@198
	dw	@11@198
	dw	@11@198
	dw	@11@198
	assume	cs:_TEXT
_IsFAT	proc	near
	push	bp
	mov	bp,sp
	mov	al,byte ptr [bp+4]
	mov	ah,0
	dec	ax
	mov	bx,ax
	cmp	bx,10
	ja	short @12@170
	shl	bx,1
	jmp	word ptr cs:@12@C242[bx]
@12@114:
	mov	al,1
@12@142:
	jmp	short @12@198
@12@170:
	mov	al,0
	jmp	short @12@142
@12@198:
	pop	bp
	ret	
_IsFAT	endp
@12@C242	label	word
	dw	@12@114
	dw	@12@170
	dw	@12@170
	dw	@12@114
	dw	@12@170
	dw	@12@114
	dw	@12@170
	dw	@12@170
	dw	@12@170
	dw	@12@170
	dw	@12@114
	assume	cs:_TEXT
_ExploreAndSelect	proc	near
	enter	1252,0
	mov	word ptr [bp-16],0
	pushf	
	mov		ax, 1003h 
	xor		bl, bl
	int		10h
	mov		ax, 300h 
	xor		bx, bx
	int		10h
	mov	        [bp-20], cx
	mov		ax, 100h  
	mov		cx, 2020h
	int		10h
	popf	
	lea	ax,word ptr [bp-10]
	push	ax
	call	near ptr _DetectDrives
	pop	cx
@13@422:
	lea	ax,word ptr [bp-1236]
	push	ax
	lea	ax,word ptr [bp-10]
	push	ax
	call	near ptr _InteractiveSelectDrv
	add	sp,4
	mov	byte ptr [bp-1],al
	cmp	byte ptr [bp-1],3
	jbe short	@@3
	jmp	@13@842
@@3:
	push	word ptr [bp+4]
	push	0
	mov	al,byte ptr [bp-1]
	push	ax
	call	near ptr _MakeFullMBROf
	add	sp,6
	mov	byte ptr [bp-2],al
	cmp	byte ptr [bp-2],0
	je	short @13@814
	cmp	byte ptr [bp-1],0
	je	short @13@562
	push	89
	push	offset DGROUP:s@+494
	call	near ptr _MkQuery
	add	sp,4
	or	al,al
	je	short @13@562
	mov	al,byte ptr [bp-1]
	mov	ah,0
	mov	word ptr [bp-16],ax
	jmp	short @13@590
@13@562:
	mov	ax,word ptr [bp+4]
	mov	word ptr [bp-22],ax
	mov	bx,word ptr [bp-22]
	mov	al,byte ptr [bp-1]
	mov	byte ptr [bx+36],al
@13@590:
	mov		ax, 1003h 
	mov		bl, 1
	int		10h
	mov		ax, 100h 
	mov		cx, [bp-20]
	int		10h
@13@758:
	mov	ax,word ptr [bp-16]
	jmp	@13@1822
	jmp	short @13@842
@13@814:
	push	12
	push	offset DGROUP:s@+517
	call	near ptr _ReportErr
	add	sp,4
	jmp	@13@1794
@13@842:
	cmp	byte ptr [bp-1],255
	jne	short @13@1206
	mov		ax, 1003h
	mov		bl, 1
	int		10h
	mov		ax, 100h
	mov		cx, [bp-20]
	int		10h
	xor		ax, ax
	mov		es, ax
	mov		word ptr es:[472h], 1234h  
	DB		0EAh			   
	DW		0h
	DW	   0FFFFh
@13@1206:
	lea	ax,word ptr [bp-1236]
	push	ax
	mov	ax,word ptr [bp+4]
	add	ax,446
	push	ax
	push	0
	push	0
	mov	al,byte ptr [bp-1]
	push	ax
	call	near ptr _InteractiveSelectPartition
	add	sp,10
	mov	byte ptr [bp-11],al
	cmp	byte ptr [bp-11],255
	jne short	@@4
	jmp	@13@1794
@@4:
	mov	al,byte ptr [bp-1]
	mov	byte ptr [bp-17],al
	mov	ax,word ptr [bp+4]
	add	ax,446
	push	ax
	mov	al,byte ptr [bp-11]
	push	ax
	call	near ptr GetEntry
	add	sp,4
	mov	word ptr [bp-14],ax
	push	16
	push	word ptr [bp-14]
	lea	ax,word ptr [bp-1252]
	push	ax
	call	near ptr _memcpy
	add	sp,6
	mov	ax,word ptr [bp-1250]
	and	ax,63
	movzx	eax,ax
	mov	dword ptr [bp-24],eax
	mov	ax,word ptr [bp-1250]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	dx,word ptr [bp-1250]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	movzx	eax,ax
	mov	dword ptr [bp-28],eax
	mov	al,byte ptr [bp-1251]
	mov	ah,0
	movsx	eax,ax
	mov	dword ptr [bp-32],eax
	push	word ptr [bp+4]
	push	word ptr [bp-14]
	mov	al,byte ptr [bp-1]
	push	ax
	call	near ptr _MakeFullMBROf
	add	sp,6
	mov	byte ptr [bp-2],al
	cmp	byte ptr [bp-2],0
	jne short	@@5
	jmp	@13@1766
@@5:
	mov	bx,word ptr [bp+4]
	cmp	word ptr [bx+510],00000AA55h
	je	short @13@1318
	push	12
	push	offset DGROUP:s@+543
	call	near ptr _ReportErr
	add	sp,4
	jmp	@13@1738
@13@1318:
	mov	al,byte ptr [bp-1248]
	push	ax
	call	near ptr _IsFAT
	pop	cx
	or	al,al
	je	short @13@1430
	cmp	dword ptr [bp-28],large 0
	je	short @13@1430
	push	89
	push	offset DGROUP:s@+595
	call	near ptr _MkQuery
	add	sp,4
	or	al,al
	je	short @13@1430
	mov	ax,word ptr [bp+4]
	mov	word ptr [bp-34],ax
	mov	bx,word ptr [bp-34]
	movzx	eax,word ptr [bx+26]
	mov	edx,dword ptr [bp-28]
	imul	edx,eax
	mov	bx,word ptr [bp-34]
	movzx	eax,word ptr [bx+24]
	imul	edx,eax
	mov	bx,word ptr [bp-34]
	movzx	eax,word ptr [bx+24]
	imul	eax,dword ptr [bp-32]
	add	edx,eax
	mov	eax,dword ptr [bp-24]
	dec	eax
	add	edx,eax
	mov	bx,word ptr [bp-34]
	mov	dword ptr [bx+28],edx
@13@1430:
	cmp	byte ptr [bp-17],128
	je	short @13@1514
	push	89
	push	offset DGROUP:s@+620
	call	near ptr _MkQuery
	add	sp,4
	or	al,al
	je	short @13@1514
	mov	al,byte ptr [bp-17]
	mov	ah,0
	mov	dx,-32768
	or	dx,ax
	mov	word ptr [bp-16],dx
	jmp	short @13@1542
@13@1514:
	mov	ax,word ptr [bp+4]
	mov	word ptr [bp-34],ax
	mov	bx,word ptr [bp-34]
	mov	al,byte ptr [bp-1]
	mov	byte ptr [bx+36],al
@13@1542:
	mov		ax, 1003h
	mov		bl, 1
	int		10h
	mov		ax, 100h
	mov		cx, [bp-20]
	int		10h
	jmp	@13@758
@13@1738:
	jmp	short @13@1794
@13@1766:
	push	12
	push	offset DGROUP:s@+643
	call	near ptr _ReportErr
	add	sp,4
@13@1794:
	jmp	@13@422
@13@1822:
	leave	
	ret	
_ExploreAndSelect	endp
_TEXT	ends
_DATA	segment word public use16 'DATA'
	dw	DGROUP:s@+669
_DATA	ends
_TEXT	segment byte public use16 'CODE'
	assume	cs:_TEXT
_MakeFullMBROf	proc	near
	enter	4,0
	cmp	word ptr [bp+6],0
	je	short @14@86
	push	1
	push	word ptr [bp+8]
	mov	bx,word ptr [bp+6]
	mov	al,byte ptr [bx+1]
	mov	ah,0
	push	ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	bx,word ptr [bp+6]
	mov	dx,word ptr [bx+2]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	push	ax
	mov	bx,word ptr [bp+6]
	mov	ax,word ptr [bx+2]
	and	ax,63
	push	ax
	jmp	short @14@114
@14@86:
	push	1
	push	word ptr [bp+8]
	push	0
	push	0
	push	1
@14@114:
	mov	al,byte ptr [bp+4]
	push	ax
	call	near ptr ReadMBRInto
	add	sp,12
	mov	byte ptr [bp-3],al
	mov	ax,word ptr [bp+8]
	mov	word ptr [bp-2],ax
	push	word ptr DGROUP:d@w+0
	call	near ptr _strlen
	pop	cx
	push	ax
	push	word ptr DGROUP:d@w+0
	mov	ax,word ptr [bp-2]
	add	ax,62
	push	ax
	call	near ptr _memcmp
	add	sp,6
	or	ax,ax
	jne	short @14@198
	push	1
	push	word ptr [bp+8]
	mov	bx,word ptr [bp-2]
	mov	al,byte ptr [bx+104]
	mov	ah,0
	push	ax
	mov	bx,word ptr [bp-2]
	mov	ax,word ptr [bx+102]
	shr	ax,6
	and	ax,3
	shl	ax,8
	mov	bx,word ptr [bp-2]
	mov	dx,word ptr [bx+102]
	shr	dx,8
	and	dx,1023
	or	ax,dx
	push	ax
	mov	bx,word ptr [bp-2]
	mov	ax,word ptr [bx+102]
	and	ax,63
	push	ax
	mov	al,byte ptr [bp+4]
	push	ax
	call	near ptr ReadMBRInto
	add	sp,12
	mov	byte ptr [bp-3],al
@14@198:
	mov	al,byte ptr [bp-3]
	jmp	short @14@226
@14@226:
	leave	
	ret	
_MakeFullMBROf	endp
	?debug	C E9
	?debug	C FA00000000
_TEXT	ends
_DATA	segment word public use16 'DATA'
s@	label	byte
	db	'Floppy disk %c:'
	db	0
	db	'Hard disk %d'
	db	0
	db	'<Empty>'
	db	0
	db	'<Unknown>'
	db	0
	db	'(ESC - reboot) Select device'
	db	0
	db	0
	db	'%d. %s%s'
	db	0
	db	'  '
	db	25
	db	0
	db	0
	db	' %9s %4u : %-2u - %-4u : %-2u'
	db	0
	db	' (Active)'
	db	0
	db	0
	db	'%d. '
	db	0
	db	'%sEmpty       %s'
	db	0
	db	'%sFAT 12      %s'
	db	0
	db	'%sFAT 16      %s'
	db	0
	db	'%sExtended DOS%s  '
	db	25
	db	0
	db	'%sLarge FAT 16%s'
	db	0
	db	'%sNTFS        %s'
	db	0
	db	'%sFAT 32      %s'
	db	0
	db	'%sFAT 32x     %s'
	db	0
	db	'%sLinux native%s'
	db	0
	db	'%s<UNKNOWN>   %s'
	db	0
	db	'(ESC - %s Select partition'
	db	0
	db	'up level '
	db	24
	db	')'
	db	0
	db	'select drive *)'
	db	0
	db	0
	db	'Can'
	db	39
	db	't explore'
	db	0
	db	'Incorrect signature (required 0xaa55)'
	db	0
	db	'Internal error'
	db	0
	db	'This partition is empty'
	db	0
	db	'This partition type is not supported'
	db	0
	db	'To swap drives (Y/N) ?'
	db	0
	db	'Read error of boot sector'
	db	0
	db	'This partition contains bad signatire (need 0aa55h)'
	db	0
	db	'To shift sectors (Y/N) ?'
	db	0
	db	'To swap drives (Y/N) ?'
	db	0
	db	'Read error of boot sector'
	db	0
	db	'(c)AlexCorp. 1999. Ultra Booter 1.0'
	db	0
_DATA	ends
_TEXT	segment byte public use16 'CODE'
_TEXT	ends
	public	_IsFAT
_GetEntry	equ	GetEntry
_GenerateTPOfMBR	equ	GenerateTPOfMBR
_GetTextPresentationOfPart	equ	GetTextPresentationOfPart
_ReadMBRInto	equ	ReadMBRInto
	public	_IsBootable
	public	_GetTextDescr
	public	_CheckMountedDrv
	public	_ExploreAndSelect
	public	_InteractiveSelectPartition
	public	_ExploreDrive_OR_ExPart
	public	_InteractiveSelectDrv
	public	_DetectDrives
	public	_MakeFullMBROf
	extrn	_MkQuery:near
	extrn	_ReportErr:near
	extrn	_GenericInteractiveSelect:near
	extrn	_strlen:near
	extrn	_sprintf:near
	extrn	_setmem:near
	extrn	_memset:near
	extrn	_memcpy:near
	extrn	_memcmp:near
_s@	equ	s@
	end
