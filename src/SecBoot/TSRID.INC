MACRO GetVector prer,oldisr
	mov	ax,3500h + prer
	int	21h
	mov	word ptr cs:oldisr,bx
	mov	word ptr cs:oldisr+2,es
endm

MACRO SetVector prer,newisr
	mov	ax,2500h + prer
	push	cs
	pop	ds
	mov	dx,offset cs:newisr
	int	21h
endm

MACRO DO_9_Exit
	in	al,61h
	mov	ah,al
	or	al,80h
	out	61h,al
	xchg	ah,al
	out	61h,al
	mov	al,20h
	IFDEF   CM1910
        out     0c0h,al
	ELSE
	out	20h,al
	ENDIF
endm

MACRO ReDirectVector prer
        GetVector prer,Old&prer
        SetVector prer,New&prer
endm

MACRO UnRedirectVector  prer
	lds	dx,cs:Old&prer
	mov	ax,2500h+prer
	int	21h
Endm

MACRO Keep    	Met
        mov     dx,offset Met
        int     27h
endm

MACRO GetCritFlag  flag
        mov     ah,34h
        int     21h             ; Get es:bx Reenter flag
        mov     word ptr cs:flag,bx
        mov     word ptr cs:flag+2,es

endm

MACRO CALL_FAR
	db	9ah
endm

MACRO JMP_FAR
	db	0eah
endm

MACRO Free_Env
	mov	es,[cs:2ch]
	mov	ah,49h
	int	21h
endm

MACRO  PushAll

	Pusha
	Push 	ds es

endm

MACRO  PopAll	

	Pop  	es ds
	Popa

endm

