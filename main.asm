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
include "missile.inc"
include "player.inc"
include "enemy.inc"


;=============================================================================
; CODE
;=============================================================================
CODESEG

; Start up
PROC startUp
	call setVideoMode, 13h
	call fillBackground, 0 ; Reset the canvas

	call resetMissiles
	call drawSprite, 10, [playerPosition], [playerPosition + 4], offset turretSprite, [turretArrayLength], [turrentSpriteWidth]  ; color new position
	call enemyInitialization
	call addEnemies
	call DisplayScore, 0, 0

	mov cx, 0fh
	mov dx, 4240h
	mov ah, 86h
	int 15h

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

PROC gameOver
	call showGameOver
	@@waitforkey:
		cmp [__keyb_keyboardState + 01h], 1 ; ESC
		jne @@notPressedESC ; skip if not pressed
			call terminateProcess
		@@notPressedESC:

		cmp [__keyb_keyboardState + 39h], 1 ; space
		jne @@notPressedSpace
			jmp @@loopbreak
		@@notPressedSpace:

		jmp @@waitforkey
	@@loopbreak:
	mov [score], 0
	call startUp
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
			
			call updateEnemyPosition
			call updatePlayerPosition
			call updateMissilePosition
			call DisplayScore, 0, 0
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
	score dd 0
;=============================================================================
; STACK
;=============================================================================
STACK 100h

END main
