IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "graphics.inc"
include "player.inc"
include "missile.inc"
include "enemy.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

; Set the video mode
PROC setVideoMode
	ARG @@Mode:byte
	USES eax

	mov ah, 0
	mov al, [@@Mode]
	int 10h
	
	ret
ENDP setVideoMode

; Fill the background (for mode 13h)
PROC fillBackground
    ARG @@fillColor:byte
	USES eax, ecx, edi

	mov edi, VMEMADR
	mov ecx, SCRWIDTH*SCRHEIGHT
	mov al, [@@fillColor]
	rep stosb
	
	ret
ENDP fillBackground

; Draw the main ship
PROC drawShip
	ARG @@fillColor:byte, @@xpos:dword, @@ypos:dword
	USES eax, edx, ecx, edi
	
	mov ecx, [characterHeight]
	@@heighloop:
		mov eax, [@@ypos]	;/** Calculate the start position of the current line to draw
		add eax, ecx		; *
		mov edx, SCRWIDTH	; *
		mul edx				; *
		add eax, [@@xpos]	; *
		add eax, VMEMADR	; *
		mov edi, eax		; */
		push ecx			; Save outer loop
		mov ecx, [characterWidth]
		mov al, [@@fillColor]
		rep stosb
		pop ecx				; Restore outer loop
	loop @@heighloop

	ret
ENDP drawShip

PROC drawMissile
	ARG @@fillColor_m:byte, @@xpos_m:dword, @@ypos_m:dword
	USES eax, edx, ecx, edi
	
	mov ecx, [missileHeight]
	@@heightloop:
		mov eax, [@@ypos_m]	;/** Calculate the start position of the current line to draw
		add eax, ecx		; *
		mov edx, SCRWIDTH	; *
		mul edx				; *
		add eax, [@@xpos_m]	; *
		add eax, VMEMADR	; *
		mov edi, eax		; */
		push ecx			; Save outer loop
		mov ecx, [missileWidth]
		mov al, [@@fillColor_m]
		rep stosb
		pop ecx				; Restore outer loop
	loop @@heightloop

	ret
ENDP drawMissile

; Draw the enemy
PROC drawEnemy
	ARG @@fillColor:byte, @@xposE:dword, @@yposE:dword
	USES eax, edx, ecx, edi
	
	mov ecx, [enemyHeight]
	@@heightloopE:
		mov eax, [@@yposE]	;/** Calculate the start position of the current line to draw
		add eax, ecx		; *
		mov edx, SCRWIDTH	; *
		mul edx				; *
		add eax, [@@xposE]	; *
		add eax, VMEMADR	; *
		mov edi, eax		; */
		push ecx			; Save outer loop
		mov ecx, [enemyWidth]
		mov al, [@@fillColor]
		rep stosb
		pop ecx				; Restore outer loop
	loop @@heightloopE

	ret
ENDP drawEnemy



; PROC drawTurret
; 	ARG @@xpos:dword, @@ypos:dword
; 	USES eax, edx, ecx, edi
	

; 		ARG @@arrlen:dword
; 	USES eax, ebx, ecx, edx
	
; 	mov eax, [@@arrlen]
; 	mov ecx, [eax]
; 	xor edx, edx
	
; 	startLoop:
; 		call printUnsignedInteger, [turret + 4*edx]
; 		inc edx
; 	loop startLoop

; 	ret
; ENDP drawTurret

; PROC drawTurret
; 	ARG @@xpos:dword, @@ypos:dword
; 	USES eax, edx, ecx, edi
	

; 		ARG @@arrlen:dword
; 	USES eax, ebx, ecx, edx
	
; 	mov ebx, 12 ; width of turret
	
; 	xor edx, edx
; 	xor eax, eax
; 	xor ecx, ecx

; 	mov edx, [offset turretArrayLength] ; length array
; 	startrow: 
; 		mov ecx, ebx ; collumn count
; 		startcollumn:
; 			mov edi, 0A0000H
; 			add edi, 320*
; 			mov al , [turret + 4*edx]

			
; 			dec ecx
; 			dec edx

; 			cmp ecx, 0
; 			jg startcollumn
; 			cmp edx , 0
; 			jg startrow
; 		loop startLoop

; 	ret
; ENDP drawTurret

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG
	turretArrayLength dd 48
	turret dd 15, 15, 15, 14, 14, 15, 15, 15, 15, 14, 14, 14, 14, 15, 15, 14, 14, 14, 14, 14, 14, 15, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14


END 