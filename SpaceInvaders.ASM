; -------------------------------------------------------------------
; 80386
; 32-bit x86 assembly language
; TASM
;
; author:	Stijn Bettens, David Blinder
; date:		25/09/2017
; program:	Hello World!
; -------------------------------------------------------------------

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

; -------------------------------------------------------------------
; CODE
; -------------------------------------------------------------------
CODESEG

;process startup sequence
PROC startUp
	call setVideoMode,13h ; start video modus
	call fillBackground, 15 ; make background black
	ret
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

; Terminate process
PROC terminateProcess
	USES eax
	call setVideoMode, 03h ; close Video Mode
	mov	ax,04C00h
	int 21h
	ret
ENDP terminateProcess


PROC main
     sti            ; set The Interrupt Flag => enable interrupts
     cld            ; clear The Direction Flag

	call startUp ; start the startup sequence


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
; DATA
; -------------------------------------------------------------------
DATASEG
	msg	db "Hello World!", 13, 10, '$'

; -------------------------------------------------------------------
; STACK
; -------------------------------------------------------------------
STACK 100h

END start
