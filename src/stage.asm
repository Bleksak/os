bits 16

section .checksum
db "OKBOOMER"

section .stage
jmp main

extern print_16

%include "console.h.asm"

; A20 is enabled, unreal mode is enabled, now we need memory map
; DL still contains the boot drive

global main
main:
	clearscreen
	
	putsln "Hello from 2nd stage!", 10, "This is fun!"
	putsln "This is a very long string, you should probably print this in your terminal every day ! (To have a good day of course)"
	
cli
hlt
