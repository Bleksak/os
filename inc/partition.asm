struc Partition
	flags: 			resb 1
	signature: 		resb 1
	start_hi: 		resw 1
	system_id: 		resb 1
	signature_2: 	resb 1
	len_hi: 		resw 1
	start_lo: 		resd 1
	len_lo: 		resd 1
endstruc

;struct Partition partition(bootable, start, len);
%macro partition 3
istruc Partition
	at flags, 		db (%1),
	at start_hi, 	dw ((%2) >> 32),
	at len_hi, 		dw ((%3) >> 32),
	at start_lo, 	dd ((%2) & 0xFFFFFFFF),
	at len_lo, 		dd ((%3) & 0xFFFFFFFF),
iend
%endmacro

global partition, Partition
