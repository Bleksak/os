
; ACCESS BYTE

%define GDT_PRESENT (1 << 47)
%define GDT_RING(ring) (ring << 45)
%define GDT_CODE_SEGMENT (1 << 44)
%define GDT_DATA_SEGMENT (1 << 44)
%define GDT_EXECUTABLE (1 << 43)
%define GDT_SEGMENT_DOWN (1 << 42)
%define GDT_READABLE (1 << 41)
%define GDT_WRITABLE (1 << 41)
%define GDT_ACCESSED (1 << 40)

; FLAGS

%define GDT_LONG_MODE (1 << 53)
%define GDT_PROTECTED_MODE (1 << 54)
%define GDT_PAGE_GRANULARITY (1 << 55)

%define gdt(base, limit, flags) \
	( ( limit & 0xFFFF ) | (( base & 0xFFFFFF ) << 16) | ((( limit >> 16 ) & 0xF) << 48) | ((base >> 24) & 0xFF) | flags )

struc GDTR
	size: resw 1
	offset: resd 1
endstruc

;GDTR gdtr(size, offset)
%macro gdtr 2
istruc GDTR
	at size, dw %1
	at offset, dd %2
iend
%endmacro
	
