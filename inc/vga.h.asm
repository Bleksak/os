%ifndef _VGA_H
%define _VGA_H

%ifndef _VGA_BASE
	
%endif



%macro get_vbe_information 0
	extern VBE_INFORMATION
	%if %[__BITS__] == 16
		
		mov ax, 0x4f00
		mov di, VBE_INFORMATION
		mov [di], dword 0x32454256
		int 0x10
	
	%else
	
	%endif
	
%endmacro


%endif
