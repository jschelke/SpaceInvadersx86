;=============================================================================
; 80386
; 32-bit x86 assembly language
; TASM
;
; author:	Jeroen Schelkens, Pieter Partous
; date:		18/11/2018
; program:	Space invaders
;=============================================================================

IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "graphics.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

; Start up
PROC startUp
	call setVideoMode, 13h
	call fillBackground, 1
ENDP startUp

; Wait for a specific keystroke.
PROC waitForSpecificKeystroke
	@@tryagain:
		mov	ah, 00h
		int	16h
		cmp al, 27
	jne @@tryagain
	call terminateProcess

	ret
ENDP waitForSpecificKeystroke

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

	; call waitForSpecificKeystroke
	@@no_key_pressed:
	; mov ah, 01h;    function 01h(test key pressed )
	; int 16h;call keyboard BIOS
	; jz @@no_key_pressed;jump to some label if no key was pressed
	mov ah, 00h		;function 00h (get key from buffer)
	int 16h			;call keyboard BIOS
	cmp al, 27
	jne @@no_key_pressed
	
	call terminateProcess
ENDP main

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG

;=============================================================================
; STACK
;=============================================================================
STACK 100h

END main
