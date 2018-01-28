
;include 'dossys.ash'
;include tsrid.inc
include Macro.reg



.286
Model use16 tiny
SmallStack
Locals

STK_SIZE    EQU      1024*2  ;bytes - размер собственного статического стека

Group  MyCode  Code0, StkSeg, Code4

Segment  Code0  word public 'Code'
Assume   cs:MyCode, ds:MyCode

        Org 100h

start:
StartUpCode

        Jmp     install

enblGo          DB              0      ;флаг завершения инициализации резидента - устанавливается в 1 после её завершения и разрешает работу собственных обработчиков прерываний


HardErr PROC far
        Mov al,3
Int23_new:
        Iret

old24_o DW  ?
old24_s DW  ?
old23_o DW  ?
old23_s DW  ?

HardErr ENDP



PROC  New21h far                    ;Используется для запуска антивируса в случае замены дмска.
;Jmp     [cs:Old21h]
         ;Флаг замены проверяется после вызова старого обработчика и
        Cmp     cs:enblGo, 0      ;если надо запускается антивирус так как DOS находится в реентерабельном состоянии.
        Jz      @@leave             ;
        cmp     ax, 4B00h
        jz      @@enter
@@leave:
        Jmp     [cs:Old21h]

@@enter:
        int     3h
        pushf

        pusha
        push    ds
        push    bp
        push    es

        mov     ax, ds
        mov     cs:K_DS, ax

        mov     cs:K_DX, dx

        mov     ax, es
        mov     cs:K_ES, ax

        mov     cs:K_BX, bx


        Call Set23_24
        Call Set_PID

;jmp @@end_write

        mov     ax, 6C00h
        xor     cx, cx
        mov     bx, 1b
        mov     dx, 00010001b
        push    cs
        pop     ds
        mov     si, OFFSET cs:fpath
        Pushf
        Call DWORD PTR cs:[old21_o]
        jnc     @@ok_ent
	jmp	@@end_write

@@ok_ent:
        mov     cs:fHandl, ax

        mov     ax, 4202h
        mov     bx, cs:fHandl
        xor     cx, cx
        xor     dx, dx
	Pushf
        Call DWORD PTR cs:[old21_o]

        mov     ah, 40h
        mov     bx, cs:fHandl
        mov     cx, LEN_pp2
        push    cs
        pop     ds
        mov     dx, OFFSET cs:pp2
        Pushf
        Call    cs:[Old21h]

        mov     ah, 40h
        mov     bx, cs:fHandl        
        push    cs:K_DS	
        pop     ds
        mov     dx, cs:K_DX
	call	StrLen ;in: ds:dx out - cx
        Pushf
        Call    cs:[Old21h]

	mov     ah, 40h
        mov     bx, cs:fHandl        
        push    cs:K_ES
        pop     ds
        mov     di, cs:K_BX
	add	di, 2
	;mov	cx, 126
	push	dword ptr ds:[di]
	pop	dx
	pop	ds
	mov	di, dx
	mov	cl, [di]
	xor	ch, ch
	inc	dx
        Pushf
        Call    cs:[Old21h]

	mov     ah, 40h
        mov     bx, cs:fHandl
        mov     cx, LEN_pp2
        push    cs
        pop     ds
        mov     dx, OFFSET cs:pp2
        Pushf
        Call    cs:[Old21h]


@@closef:
        mov     ah, 3eh
        mov     bx, cs:fHandl
        Pushf
        Call    cs:[Old21h]

@@end_write:
        Call Reset23_24
        Call Reset_PID

        pop     es
        pop     bp
        pop     ds
        popa

        Pushf
        Call    cs:[Old21h]        ;вызов старого обработчика (Pushf нужен для эммуляции Int21h)

@@ex:
        Popf
        Ret     2                  ;возврат из прерывания без изменения флагов

;Old21h        DD  ?
LABEL  Old21h DWORD
old21_o  DW 0
old21_s  DW 0


fpath   DB 'e:\int21_4b.txt', 0, '$'
fHandl  DW 0
pp2     DB "  ", 13, 10, "  "
LEN_pp2 equ $ - pp2

K_DS    DW 0
K_DX    DW 0

K_ES    DW 0
K_BX    DW 0

ENDP New21h

StrLen PROC near ;in: ds:dx out - cx
	pushf
	push	es
	push	di
	push	ax

	push	ds
	pop	es
	mov	di, dx
	xor	al, al	
	cld

@@scan_str:
	scasb
	jnz	@@scan_str

	sub	di, dx
	mov	cx, di
	
	pop	ax
	pop	di
	pop	es
	popf

	ret

StrLen ENDP

Set_PID PROC near

        PushAll

        Mov ah,62h
        Pushf
        Call DWORD PTR cs:[old21_o]
        Mov cs:old_PID,bx
        Mov bx,cs
        Mov ah,50h
        Pushf
        Call DWORD PTR cs:[old21_o]

        PopAll
        Ret

old_PID DW  ?

Set_PID ENDP

Reset_PID PROC near

          PushAll

          Mov ah,50h
          Mov bx,cs:old_PID
          Pushf
          Call DWORD PTR cs:[old21_o]

          PopAll
          Ret

Reset_PID ENDP

Set23_24 PROC near

         PushAll

         Mov bx,cs
         Mov ds,bx

         Xor bx,bx
         Mov es,bx
         Mov bx,23h*4
         Cli
         Mov ax,es:[bx]
         Mov old23_o,ax
         Mov ax,es:[bx+2]
         Mov old23_s,ax
         Mov es:[bx+2],cs
         Lea ax,Int23_new
         Mov es:[bx],ax
         Mov bx,24h*4
         Mov ax,es:[bx]
         Mov old24_o,ax
         Mov ax,es:[bx+2]
         Mov old24_s,ax
         Mov es:[bx+2],cs
         Lea ax,HardErr
         Mov es:[bx],ax
         Sti

         PopAll

         Ret

Set23_24 ENDP

Reset23_24 PROC near

           PushAll

           Mov ax,cs:old23_o
           Mov dx,cs:old23_s

           Xor bx,bx
           Mov es,bx
           Mov bx,23h*4
           Cli
           Mov es:[bx],ax
           Mov es:[bx+2],dx
           Mov bx,24h*4
           Mov ax,cs:old24_o
           Mov dx,cs:old24_s
           Mov es:[bx],ax
           Mov es:[bx+2],dx
           Sti

           PopAll
           Ret

Reset23_24 ENDP


install:
        Push es
        Push ds

        Mov ax,3521h
        Int 21h
        Mov WORD PTR cs:old21_s,es
        Mov WORD PTR cs:old21_o,bx

        Mov ax,2521h
        Lea dx,New21h
        Int 21h

        pop     ds
        pop     es

        Mov BYTE PTR cs:enblGo, 1
        Lea dx, install
        Int 27h

ENDS  Code0

Segment  StkSeg  para public 'Code'
        myStk      DB  STK_SIZE  Dup('Stack')
ENDS StkSeg

Segment  Code4  word public 'Code'

File_length     DD              23832
File_CRC        DD              8BC6ABACh
end_start:

ENDS  Code4

        END

