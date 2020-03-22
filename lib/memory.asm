%define _MEMORY_BASE

%include "memory.h.asm"
global memcpy16, memcpy32, memcpy64
global memset_16

bits 16

section .lib


memset_16:
	mov ecx, [esp + 8]
	mov ax, [esp + 6]
	mov edi, [esp + 2]

.loop:
	far_write byte, edi, al
	
	inc edi
	dec ecx
	jnz .loop

	ret

memcpy16:
	; we need to do a far copy (far read/write)
	
	mov ecx, [esp + 10]
	mov esi, [esp + 6]
	mov edi, [esp + 2]

.loop:
	far_read byte, esi
	far_write byte, edi, al
	
	inc esi
	inc edi

	dec ecx
	jnz .loop

	ret

bits 32
memcpy32:
	
	mov ecx, [esp + 8]
	mov esi, [esp + 12]
	mov edi, [esp + 16]
	
	; 3 approaches
	; byte by byte (very slow)
	; dwords first, then word and a byte
	; SSE2
	
	mov eax, ecx

	; we check if the OS enables SSE
	%ifdef SSE
	
	; sse, bytes
	; each xmm register is 16 bytes, so we need to divide ecx by 16

	and eax, 0xf ; remainder
	shr ecx, 4 ; effectively divide by 16

	test esi, 0xf
	jz .src_possible
	
	test edi, 0xf
	jz .aligned_dest_loop
	
	jmp .unaligned_loop

.src_possible:
	test edi, 0xf
	jnz .aligned_src_loop
	
.aligned_loop:
	movaps xmm0, [esi]
	movaps [edi], xmm0
	
	add esi, 16
	add edi, 16
	dec ecx
	jnz .aligned_loop
	jmp .finish_bytes

.aligned_src_loop:
	movaps xmm0, [esi]
	movups [edi], xmm0

	add esi, 16
	add edi, 16
	dec ecx
	jnz .aligned_src_loop
	jmp .finish_bytes

.aligned_dest_loop:	
	movups xmm0, [esi]
	movaps [edi], xmm0
	
	add esi, 16
	add edi, 16
	dec ecx
	jnz .aligned_dest_loop
	
	jmp .finish_bytes

.unaligned_loop:
	movups xmm0, [esi]
	movups [edi], xmm0	

	add esi, 16
	add edi, 16
	dec ecx
	jnz .unaligned_loop

	%else
	
	%warning Not using SSE
	; dwords, word, byte
	
	and eax, 0x3 ; remainder
	shr ecx, 2 ; effectively divide by 4
	
	rep movsd

	%endif


.finish_bytes:
	mov ecx, eax
	rep movsb

	ret


bits 64
memcpy64:

	; rdi => dest
	; rsi => source
	; rdx => count
	
	mov rcx, rdx

	;mov eax, ecx
	; use SSE2 with no checks

	and rdx, 0xf ; remainder
	shr rcx, 4 ; effectively divide by 16

	test rsi, 0xf
	jz .src_possible
	
	test rdi, 0xf
	jz .aligned_dest_loop
	
	jmp .unaligned_loop

.src_possible:
	test rdi, 0xf
	jnz .aligned_src_loop
	
.aligned_loop:
	movaps xmm0, [rsi]
	movaps [rdi], xmm0
	
	add rsi, 16
	add rdi, 16
	dec rcx
	jnz .aligned_loop
	jmp .finish_bytes

.aligned_src_loop:
	movaps xmm0, [rsi]
	movups [rdi], xmm0

	add rsi, 16
	add rdi, 16
	dec rcx
	jnz .aligned_src_loop
	jmp .finish_bytes

.aligned_dest_loop:	
	movups xmm0, [rsi]
	movaps [rdi], xmm0
	
	add rsi, 16
	add rdi, 16
	dec rcx
	jnz .aligned_dest_loop
	
	jmp .finish_bytes

.unaligned_loop:
	movups xmm0, [rsi]
	movups [rdi], xmm0	

	add rsi, 16
	add rdi, 16
	dec rcx
	jnz .unaligned_loop

	ret

.finish_bytes:
	
	mov rcx, rdx
	rep movsb

	ret
