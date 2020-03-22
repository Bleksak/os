%define _CONSOLE_BASE

%include "console.h.asm"
%include "memory.h.asm"

bits 16

section .lib

%define USE_VGA

global print_16

newline:
	push ax
	push esi

	memcpy CONSOLE_BASE, CONSOLE_BASE + CONSOLE_WIDTH * 2, 2 * CONSOLE_WIDTH * (CONSOLE_HEIGHT - 1)
	
	memset CONSOLE_PRINT_BASE, 0, CONSOLE_WIDTH * 2

	mov edi, CONSOLE_PRINT_BASE
	
	pop esi
	pop ax
	ret

putch_16:
	;ax => character
	;edi => position
	
	cmp al, 0xA ; 0xA = '\n'
	je newline ; tall call optimalization
	
	cmp edi, CONSOLE_PRINT_BASE + CONSOLE_WIDTH * 2
	jb .print
	
	call newline

.print:
	
	far_write word, edi, ax

	add edi, 2
.done:
	ret ; TODO: we can optimize this ret to jmp print_16.loop


print_16:
%ifdef USE_VGA
	mov edi, dword [.x]	
	shl edi, 1

	add edi, CONSOLE_PRINT_BASE

	mov ah, 0xf

.loop:
	lodsb
	or al, al
	jz .done
	
	push .loop
	jmp putch_16
.done:	
	sub edi, CONSOLE_PRINT_BASE
	shr edi, 1

	mov [.x], edi
	ret
	.x dd 0
%else
	%warning Using INT 0x10 to print, you should probably use VGA (define USE_VGA)
	mov ah, 0xE
.loop:
	lodsb
	or al, al
	jz .done
	
	int 0x10
	jmp .loop
.done:
	ret
%endif


bits 32

print_32:
	
