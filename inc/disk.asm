; Disk IO 16 bit library

struc DiskAddressPacket
	packet: resb 1
	reserved: resb 1
	transfer: resw 1
	buffer_offset: resw 1
	buffer_segment: resw 1
	start_lba_lo: resd 1
	start_lba_hi: resd 1
endstruc

; push_packet segment, offset, lba_hi, lba_lo, len
%macro push_packet 5 ; push in reverse so we can use esp as DAP
	push dword %3; lba_hi
	push dword %4 ;lba_lo
	push word %1 ; segment
	push word %2 ; offset
	push word %5 ; len
	push word 0x0010 ; packet + reserved
	mov esi, esp
%endmacro

%define pop_packet add esp, 0x10

disk_read_16:
	mov ax, 0x4200
	int 0x13
	ret

; disk read dest: segment, offset, lba, len .... DL = disk to read
; carry flag set on error

%macro disk_read 4
	push_packet %1, %2, 0, %3, %4 ; lba_hi is 0	
	call disk_read_16
	pop_packet
%endmacro
