IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "main.inc"
include "globals.inc"
include "graphics.inc"
include "debug.inc"
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
PROC drawRectangle
	ARG @@fillColor:byte, @@xpos:dword, @@ypos:dword, @@Width:dword, @@Height:dword
	USES eax, edx, ecx, edi
	
	mov ecx, [@@Height]
	@@heighloop:
		mov eax, [@@ypos]	;/** Calculate the start position of the current line to draw
		sub eax, 1			; *
		add eax, ecx		; *
		mov edx, SCRWIDTH	; *
		mul edx				; *
		add eax, [@@xpos]	; *
		sub eax, 1			; *
		add eax, VMEMADR	; *
		mov edi, eax		; */
		push ecx			; Save outer loop
		mov ecx, [@@Width]
		mov al, [@@fillColor]
		rep stosb
		pop ecx				; Restore outer loop
	loop @@heighloop

	ret
ENDP drawRectangle

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



PROC drawShip
	ARG @@fillColor:byte, @@xpos:dword, @@ypos:dword
	USES eax, ebx, ecx, edx, ecx, edi
	
	xor ecx, ecx ; counter
	xor ebx, ebx ; line counter
	xor edx, edx ; element counter
	@@startLoop:
		cmp edx, [turretArrayLength]
		je @@endLoop
		cmp ecx, 8
		jne @@noNewLine
			inc ebx
			sub ecx, 8
		@@noNewLine:
		cmp [turretSprite+edx], 1
		jne @@noColour

			mov edi, 0A0000H
			mov eax, SCRWIDTH
			push edx
			add ebx, [@@ypos]
			mul ebx
			sub ebx, [@@ypos]
			pop edx
			add edi, eax

			add edi, ecx
			add edi, [@@xpos]

			mov al, [@@fillColor]
			mov [edi], al
		@@noColour:

		inc ecx
		inc edx
		jmp @@startLoop
	@@endLoop:


	ret
ENDP drawShip

PROC DisplayScore
	USES eax, ebx, ecx, edx

    mov ah, 2     	; set cursor position
	mov dh, 0     	; row in DH (00H is top)
	mov dl, 0     	; column in DL (00H is left)
	mov bh, 0		; page number in BH
	int 10h       	; raise interrupt

	mov eax, [score]	; eax holds input integer
	mov ebx, 10			; divider
	xor ecx, ecx		; counter for digit to be printed
	@@getNextDigit:
		inc ecx			; increase digit counter
		xor edx, edx
		div ebx			; divide by 10
		push dx			; store remainder on stack
		cmp ecx, 5
		jne @@getNextDigit
	
	; Write all digits to the standard output
	mov ah, 2h		; function for printing single characters
	
	@@printDigit:
		pop dx
		add dl, '0'		; add 30h => code for a digit in the ascii table
		int 21h			; print the digit to the screen
		loop @@printDigit	; until diit counter = 0
	ret
ENDP DisplayScore



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
	turretArrayLength dd 40
	turretSprite db 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0,	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	testString db "test $"

END 