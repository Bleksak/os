bits 16

; u64 gdt(base, limit, flags)

section .boot

jmp boot

%include "disk.asm"
; In first stage we enable A20, enter unreal mode and load stage2

global boot
boot:
	cli
	xor ax, ax
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov sp, 0x7c00
	
	jmp 0:.flush
.flush:
	sti

	;enable a20
	in al, 0x92
	test al, 2
	jnz .done
	and al, 0xFE
	out 0x92, al
	
.done:
	mov ax, 0x2401
	int 0x15

	; A20 is surely active here (on newer systems, we don't support old crap)

	; Now we enable unreal mode
	
	cli
	
	push ds
	push es
	push fs
	push gs
	push ss	

	lgdt [descriptor]
	
	mov eax, cr0
	or al, 1
	mov cr0, eax

	mov bx, 0x08
	mov ds, bx
	
	and al, 0xFE
	mov cr0, eax
	
	pop ss
	pop gs
	pop fs
	pop es
	pop ds

	sti

	; Now we load stage 2
	
	extern STAGE_LOAD_ADDR, STAGE_LOAD_SEGMENT, STAGE_LOAD_OFFSET, STAGE_SIZE

	disk_read STAGE_LOAD_SEGMENT, STAGE_LOAD_OFFSET, 1, STAGE_SIZE
	jc read_error
	
	extern CHECKSUM_ADDRESS

	mov si, stage_checksum
	mov di,	CHECKSUM_ADDRESS
	mov cx, 8
	rep cmpsb

	
	jnz checksum_error
	
	; jump to stage 2

	extern STAGE_CODE_ADDR
	jmp STAGE_CODE_ADDR

checksum_error:
	mov si, .err	
	jmp panic
	.err: db "Second stage checksum is invalid", 0

read_error:
	mov si, .err
	jmp panic
	.err: db "Failed to read disk",0
	

panic:
	mov ah, 0xE
.loop:
	lodsb
	or al, al
	jz .done

	int 0x10
	jmp .loop

.done:
	cli
	hlt

%include "gdt.asm"

GDT: 
	.null: dq 0
	.data: dq gdt(0, 0xFFFFFFFF, GDT_PRESENT | GDT_RING(0) | GDT_DATA_SEGMENT | GDT_WRITABLE | GDT_PROTECTED_MODE | GDT_PAGE_GRANULARITY)
	.end:
descriptor:
	gdtr GDT.end - GDT - 1, GDT

stage_checksum: db "OKBOOMER"

times 446 - ($-$$) db 0

global PT1, PT2, PT3, PT4

%include "partition.asm"

PT1: partition 1, 0, 0
PT2: partition 0, 0, 0
PT3: partition 0, 0, 0
PT4: partition 0, 0, 0

dw 0xAA55
