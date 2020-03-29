%ifndef _MEMORY_H
%define _MEMORY_H

%define MEMORY_AVAILABLE 1
%define MEMORY_RESERVED 2
%define MEMORY_ACPI_RECLAIM 3
%define MEMORY_ACPI_NVS 4

%ifndef _MEMORY_BASE
	extern memcpy16, memcpy32, memcpy64
	extern memset_16
%endif

; type, addr
%macro far_read 2
	%if %[__BITS__] != 16
		%error Far read is not defined for %[__BITS__] bits
	%endif

	%ifidni %1, byte
		mov al, %1 [ds:%2]
	%elifidni %1, word
		mov ax, %1 [ds:%2]
	%else
		mov eax, %1 [ds:%2]
	%endif
%endmacro


; type, addr, value
%macro far_write 3
	%if %[__BITS__] != 16
		%error Far write is not defined for %[__BITS__] bits
	%endif

	mov %1 [ds:%2], %3

%endmacro

; dest, source, len
%macro memcpy 3
	%if %[__BITS__] == 16
		push dword %3
		push dword %2
		push dword %1
	
		call memcpy16
		add esp, 12
	%elif %[__BITS__] == 32
		push dword %3
		push dword %2
		push dword %1
		
		call memcpy32
		add esp, 12
	%else
		mov rdi, %1
		mov rsi, %2
		mov rdx, %3

		call memcpy64
	%endif
%endmacro

; dest, ch, len
%macro memset 3
	%if %[__BITS__] == 16
		
		push dword %3
		push word %2
		push dword %1

		call memset_16
		add esp, 10	

	%elif %[__BITS__] == 32

	%else

	%endif
%endmacro


%if %[__BITS__] == 16

;reg = count
%macro get_memory_map 0
	xor ebx, ebx

	extern MEMORY_MAP
	mov esi, MEMORY_MAP
	

%%loop:	
	mov edi, %%tmp_map
	mov eax, 0xE820
	mov edx, 0x534D4150 ; SMAP
	
	mov ecx, 20

	int 0x15
	jc %%end

	mov [%%tmp_map + 20], ecx
	
	push esi

	memcpy MEMORY_MAP, %%tmp_map, 24
	
	pop esi

	add esi, 24

	test ebx, ebx
	jnz %%loop
	
	jmp %%end

%%tmp_map: times 3 dq 0
%%end:

%endmacro
%endif
%endif
