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
include "main.inc"
include "graphics.inc"
include "keys.inc"
include "debug.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

; Start up
PROC startUp
	call setVideoMode, 13h
	call fillBackground, 1

	ret
ENDP startUp

; Terminate the program.
PROC terminateProcess
	USES eax

	call setVideoMode, 03h
	mov	ax, 04C00h
	int 21h

	ret
ENDP terminateProcess

PROC main
	sti
	cld
	
	push ds
	pop	es

	call startUp

	call drawShip, 10, 100, 100 ; color, xpos, ypos



	looper:
	call isKeypressed
	; call printUnsignedInteger, [playerPossition]
	jmp looper
ENDP main

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG
	playerPossition dd 100, 100 ;x, y
;=============================================================================
; STACK
;=============================================================================
STACK 100h

END main
