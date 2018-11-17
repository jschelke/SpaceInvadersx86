; -------------------------------------------------------------------
; 80386
; 32-bit x86 assembly language
; TASM
;
; author:	David Blinder, Stijn Bettens
; date:		23/10/2018
; program:	Video mode 13h
; -------------------------------------------------------------------

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

; compile-time constants (with macros)
VMEMADR EQU 0A0000h	; video memory address
SCRWIDTH EQU 320	; screen witdth
SCRHEIGHT EQU 200	; screen height

; -------------------------------------------------------------------
CODESEG

; Start up
PROC startUp
	call setVideoMode,13h
	call fillBackground, 0
ENDP startUp

; Set the video mode
PROC setVideoMode
	ARG @@Mode:byte
	mov ah, 0
	mov al, [@@Mode]
	int 10h
	
	ret
ENDP setVideoMode



; Fill the background (for mode 13h)
PROC fillBackground
ARG @@fillColor:byte
	USES eax,ebx, edi
	mov edi,VMEMADR
	mov ecx, SCRWIDTH*SCRHEIGHT
	mov al,[@@fillColor]
	rep stosb
	
	ret
ENDP fillBackground

; Draw the main ship
PROC drawShip
	mov al,[@@fillColor]
	colcount:
	inc cx
	int 10h
	cmp cx, 30
	JNE colcount

	mov cx, 10  ; reset to start of col
	inc dx      ;next row
	cmp dx, 30
	JNE colcount
	ret
ENDP drawShip

; Terminate the program.
PROC terminateProcess
	USES eax
	call setVideoMode, 03h
	mov	ax,04C00h
	int 21h
	ret
ENDP terminateProcess

PROC main
	sti
	cld
	
	push ds
	pop	es

	call startUp

	call drawShip

	
	@@no_key_pressed:
	mov ah, 01h;    function 01h(test key pressed )
	int 16h;call keyboard BIOS
	jz @@no_key_pressed;jump to some label if no key was pressed
	mov ah, 00h;function 00h (get key from buffer)
	int 16h;    c a l l   keyboard   BIOS
	; (replace by) call	waitForSpecificKeystroke, 001Bh ; keycode for ESC
	cmp al, 27
	jne @@no_key_pressed
	
	call terminateProcess
ENDP main

; -------------------------------------------------------------------
DATASEG
	palette		db 768 dup (?)
; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END main
