bits 16

%ifndef _CONSOLE_H
%define _CONSOLE_H

%include "memory.h.asm"

%ifndef _CONSOLE_BASE
	extern print_16
%endif

%define COLOR_BLACK 0x0
%define COLOR_BLUE 0x1
%define COLOR_GREEN 0x2
%define COLOR_CYAN 0x3
%define COLOR_RED 0x4
%define COLOR_MAGENTA 0x5
%define COLOR_BROWN 0x6
%define COLOR_GRAY 0x7
%define COLOR_DARK_GRAY 0x8
%define COLOR_LIGHT_BLUE 0x9
%define COLOR_LIGHT_GREEN 0xA
%define COLOR_LIGHT_CYAN 0xB
%define COLOR_LIGHT_RED 0xC
%define COLOR_LIGHT_MAGENTA 0xD
%define COLOR_YELLOW 0xE
%define COLOR_WHITE 0xF

%define CONSOLE_WIDTH 80
%define CONSOLE_HEIGHT 25

%define CONSOLE_BASE 0xB8000
%define CONSOLE_PRINT_BASE (CONSOLE_BASE + 2 * (CONSOLE_WIDTH * (CONSOLE_HEIGHT - 1)))

%define MAKE_COLOR(background, text) ( (text) | ((background) << 4))

%macro puts 1-*

	mov esi, %%str
	call print_16

	%%str: db %{1 : -1}, 0
%endmacro

%macro putsln 1-*
	mov esi, %%str
	push word %%after

	%if %[__BITS__] == 16
		jmp print_16
	%elif %[__BITS__] == 32
		jmp print_32
	%else
		jmp print_64
	%endif

	%%str: db %{1 : -1}, 10, 0
	%%after:
%endmacro

%macro clearscreen 0
	memset CONSOLE_BASE, 0, CONSOLE_WIDTH * CONSOLE_HEIGHT * 2
%endmacro

%endif
