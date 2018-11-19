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
include "player.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

; Start up
PROC startUp
	call setVideoMode, 13h
	call fillBackground, 0 ; Reset the canvas
	call drawShip, 10, [playerPossition], [playerPossition + 4] ; color, x, y

	call getTime
	add eax, [timePerTick]
	mov [nextTickTime], eax

	ret
ENDP startUp

; Terminate the program.
PROC terminateProcess
	USES eax

	call __keyb_uninstallKeyboardHandler
	call setVideoMode, 03h
	mov	ax, 04C00h
	int 21h

	ret
ENDP terminateProcess

; Get system time in 1/100th's of a second
PROC getTime
	ARG RETURNS eax
	USES ebx, ecx, edx

	mov ah, 2ch
	int 21h
	movzx ebx, dl
	mov eax, 100
	mul dh
	add ebx, eax
	mov eax, 6000
	movzx edx, cl
	mul edx
	add ebx, eax
	mov eax, 360000
	movzx edx, ch
	mul edx
	add eax, ebx

	ret
ENDP

PROC main
	sti
	cld
	
	push ds
	pop	es

	call __keyb_installKeyboardHandler

	call startUp

	@@mainloop:
		call getTime
		cmp [nextTickTime], eax
		jg @@skip
			add eax, [timePerTick]
			mov [nextTickTime], eax
			call updatePlayerPosition
		@@skip:
		
		call isKeypressed
	jmp @@mainloop
ENDP main

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG
	nextTickTime dd ? ; 1/100th seconds
;=============================================================================
; DATA
;=============================================================================
DATASEG
	timePerTick dd 5 ; 1/100th seconds
;=============================================================================
; STACK
;=============================================================================
STACK 100h

END main
