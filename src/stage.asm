bits 16

section .checksum
db "OKBOOMER"

section .stage
jmp main

extern print_16

%include "console.h.asm"
%include "vga.h.asm"
%include "gdt.asm"

; A20 is enabled, unreal mode is enabled, now we need memory map
; DL still contains the boot drive

global main
main:
	clearscreen
	get_memory_map 
	get_vbe_information
	

	; We should create a long mode GDT now

	cli

set_up_page_tables:
    mov eax, p3_table
    or eax, 0b11 ; present + writable
    mov [p4_table], eax

    ; map first P3 entry to P2 table
    mov eax, p2_table
    or eax, 0b11 ; present + writable
    mov [p3_table], eax
    ; map each P2 entry to a huge 2MiB page
    mov ecx, 0         ; counter variable

.map_p2_table:
    ; map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
    mov eax, 0x200000  ; 2MiB
    mul ecx            ; start address of ecx-th page
    or eax, 0b10000011 ; present + writable + huge
    mov [p2_table + ecx * 8], eax ; map ecx-th entry

    inc ecx            ; increase counter
    cmp ecx, 512       ; if counter == 512, the whole P2 table is mapped
    jne .map_p2_table  ; else map the next entry

	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	mov eax, p4_table
	mov cr3, eax

	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	mov eax, cr0
	or eax, 0x80000001
	mov cr0, eax


	lgdt [gdt64.pointer]
	jmp gdt64.code:go64
cli
hlt

gdt64:
    dq 0 ; zero entry
.code: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; code segment
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

align 4096
p4_table:
    times 4096 db 0
p3_table:
    times 4096 db 0
p2_table:
    times 4096 db 0

	; We will make this a kernel

bits 64
go64:
	xor eax, eax

	mov ds, eax
	mov es, eax
	mov gs, eax
	mov fs, eax
	mov ss, eax

	
	
	jmp $
cli
hlt
