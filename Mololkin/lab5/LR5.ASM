CODE SEGMENT
    ASSUME CS:CODE, DS:DATA, SS:ASTACK, ES:NOTHING

ROUT PROC FAR
    jmp START_ROUT
    SYMBOL db 0
	INTER_ID dw 7373h
    KEEP_AX dw 0
    KEEP_SS dw 0
    KEEP_SP dw 0
	KEEP_IP dw 0
	KEEP_CS dw 0
	KEEP_PSP dw 0
    ROUT_STACK dw 128 DUP(0)

START_ROUT:        
    mov KEEP_SS, ss
    mov KEEP_SP, sp
    mov KEEP_AX, ax
    mov ax, seg ROUT_STACK
    mov ss, ax
    mov ax, offset ROUT_STACK
	add ax, 256 
	mov sp, ax

    push ax
    push bx
    push ds
    push dx
    push si
    push cx
    push es

    in al, 60h
    cmp al, 02h
    je ONE
    cmp al, 03h
    je TWO
    cmp al, 04h
    je THREE
    pushf
    call DWORD PTR CS:KEEP_IP
    jmp END_ROUT

ONE:
    mov cl, '!'
    jmp CHOOSEN_BUTTON
TWO:
    mov cl, '@'
    jmp CHOOSEN_BUTTON
THREE:
    mov cl, '#'

CHOOSEN_BUTTON:
    in al, 61h
    mov ah, al
    or al, 80h
    out 61h, al
    xchg al, al
    out 61h, al
    mov al, 20h
    out 20h, al

PRINT_SYMB:
	mov ah, 05h
	mov ch, 00h
	int 16h
	or al, al
	jz END_ROUT

    mov ax, 0040h
    mov es, ax
    mov ax, es
    mov es:[1ch], ax
    jmp PRINT_SYMB

END_ROUT:
    pop es
    pop cx
    pop si
    pop dx
    pop ds
    pop bx
    pop ax
    mov sp, KEEP_SP
    mov ax, KEEP_SS
    mov ss, ax
    mov ax, KEEP_AX
    mov al, 20h
    out 20h, al
    IRET
    ret
ROUT ENDP
ROUT_END:

START_OR_STOP_INTER PROC
    push ax
    push bx
    push si
    push es
	mov ax, KEEP_PSP
	mov es, ax
	cmp byte ptr es:[82h], '/'
	jne IS_LOAD
	cmp byte ptr es:[83h], 'u'
	jne IS_LOAD
	cmp byte ptr es:[84h], 'n'
    jne IS_LOAD
    mov IS_UN_FLAG, 1
    
IS_LOAD:
    mov ah, 35h
    mov al, 09h
    int 21h
    mov si, offset INTER_ID 
    sub si, offset ROUT
    mov ax, es:[bx+si]
    cmp ax, 7373h
    jne NOT_LOAD
    cmp IS_UN_FLAG, 1
    jne LOAD_AGAIN
    call STOP_INTER
    jmp END_SS

LOAD_AGAIN:
    mov dx, offset TRY_LOAD_AGAIN
    call PRINT_STRING
    jmp END_SS

NOT_LOAD:
    cmp IS_UN_FLAG, 1
    jne BEGIN_ROUT
    mov dx, offset TRY_TO_STOP
    call PRINT_STRING
    jmp END_SS

BEGIN_ROUT:
    call LOAD_INTER

END_SS:

    pop es
    pop si
    pop bx
    pop ax
    ret
START_OR_STOP_INTER ENDP

LOAD_INTER PROC
    push ax
	push bx
	push cx
	push dx
	push ds
	push es
	
	mov ah, 35h
	mov al, 09h
	int 21h
	mov KEEP_CS, es
	mov KEEP_IP, bx
	push ds
	mov dx, offset ROUT
	mov ax, SEG ROUT	
	mov ds, ax
	mov ah, 25h
	mov al, 09h
	int 21h
	pop ds
	mov dx, offset ROUT_END
	add dx, 10Fh
	mov cl, 4h
	shr dx, cl
	inc dx
	xor ax, ax
	mov ah, 31h
	int 21h
	
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax
	ret
LOAD_INTER ENDP

STOP_INTER PROC
    CLI
 	push ax
 	push bx
 	push dx
 	push ds
 	push es
 	push si
	
	mov ah, 35h
	mov al, 09h
	int 21h
	mov si, offset KEEP_IP
	sub si, offset ROUT
	mov dx, es:[bx + si]
	mov ax, es:[bx + si + 2]
	push ds
	mov ds, ax
	mov ah, 25h
	mov al, 09h
	int 21h
	pop ds
	mov ax, es:[bx + si + 4]
	mov es, ax
	push es
	mov ax, es:[2Ch]
	mov es, ax
	mov ah, 49h
	int 21h
	pop es
	mov ah, 49h
 	int 21h
	
	pop si
 	pop es
 	pop ds
 	pop dx
 	pop bx
 	pop ax
 	STI
	ret
STOP_INTER ENDP

PRINT_STRING PROC near
    push AX
    mov ah, 09h
	int 21h
    pop AX
    ret
PRINT_STRING ENDP

MAIN PROC
    push ds
    xor ax, ax
    push ax
    mov ax, DATA
    mov ds, ax
    mov KEEP_PSP, es
    call START_OR_STOP_INTER
    xor al, al
	mov ah, 4Ch
	int 21h
MAIN ENDP

CODE ENDS

ASTACK SEGMENT STACK
    dw 128 DUP(0)
ASTACK ENDS

DATA SEGMENT
    IS_UN_FLAG db 0
    TRY_TO_STOP db "Trying to stop not loaded interruption$"
    TRY_LOAD_AGAIN db "Trying to load interruption again$"
DATA ENDS
END MAIN