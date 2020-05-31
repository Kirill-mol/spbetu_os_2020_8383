CODE SEGMENT
	ASSUME CS:CODE, DS:NOTHING, SS:NOTHING, ES:NOTHING
	
MAIN PROC FAR
	push ax
	push dx
	push ds
	push di
	mov ax, cs
	mov ds, ax
	mov di, offset OVERLAY_SEGMENT
	add di, 21
	call WRD_TO_HEX
	mov DX, offset OVERLAY_SEGMENT
	call PRINT_STRING
	pop di
	pop ds
	pop dx
	pop ax
	retf
MAIN ENDP

PRINT_STRING PROC near
    push AX
    mov AH, 09h
    int 21h
    pop AX
    ret
PRINT_STRING ENDP
;----------------------------------------------
TETR_TO_HEX PROC near
   and AL, 0Fh
   cmp AL, 09
   jbe next
   add AL, 07
next:
   add AL, 30h
   ret
TETR_TO_HEX ENDP
;----------------------------------------------
BYTE_TO_HEX PROC near
   push CX
   mov AH, AL
   call TETR_TO_HEX
   xchg AL, AH
   mov CL, 4
   shr AL, CL
   call TETR_TO_HEX 
   pop CX 
   ret
BYTE_TO_HEX ENDP

WRD_TO_HEX PROC near
   push BX
   mov BH, AH
   call BYTE_TO_HEX
   mov [DI], AH
   dec DI
   mov [DI], AL
   dec DI
   mov AL, BH
   call BYTE_TO_HEX
   mov [DI], AH
   dec DI
   mov [DI], AL
   pop BX
   ret
WRD_TO_HEX ENDP
	
   OVERLAY_SEGMENT db "Overlay2 segment:        ", 13, 10, "$"

CODE ENDS
END MAIN