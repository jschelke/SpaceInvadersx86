IDEAL
P386
MODEL FLAT, C
ASSUME cs:_TEXT,ds:FLAT,es:FLAT,fs:FLAT,gs:FLAT

;=============================================================================
; INCLUDES
;=============================================================================
include "globals.inc"
include "main.inc"
include "debug.inc"
include "player.inc"
include "graphics.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

PROC updatePlayerPosition
	USES eax, ebx

	call drawRectangle, 0, [playerPosition], [playerPosition + 4], [characterWidth], [characterHeight]

	mov eax, [playerSpeed]
	or eax, [playerSpeed + 4]
	test eax, eax
	jz @@nomovement
		
		; call drawShip, 0, [playerPosition], [playerPosition + 4] ; make old position black

		; Move to the left
		mov eax, [playerSpeed]
		add [playerPosition], eax
		jns @@leftBorderSafe
			mov [playerPosition], 0
		@@leftBorderSafe:

		; Move to the right
		mov eax, SCRWIDTH
		sub eax, [characterWidth]
		cmp [playerPosition], eax
		jl @@rightBorderSafe
			mov [playerPosition], eax
		@@rightBorderSafe:

		; Move up
		mov eax, [playerSpeed + 4]
		add [playerPosition + 4], eax
		jns @@upperBorderSafe
			mov [playerPosition + 4], 0
		@@upperBorderSafe:

		; Move down
		mov eax, SCRHEIGHT
		sub eax, [characterHeight]
		cmp [playerPosition + 4], eax
		jl @@lowerBorderSafe
			mov [playerPosition + 4], eax
		@@lowerBorderSafe:


		
	@@nomovement:
	;call drawShip, 10, [playerPosition], [playerPosition + 4] ; color new position
	call drawSprite, 10, [playerPosition], [playerPosition + 4], offset turretSprite, [turretArrayLength], [turrentSpriteWidth]  ; color new position
	
	ret
ENDP

;=============================================================================
; Uninitialized DATA
;=============================================================================
UDATASEG

;=============================================================================
; DATA
;=============================================================================
DATASEG
	playerPosition dd 100, PLAYERPOSY ;x, y
	playerSpeed dd 0, 0 ;vx, vy
	playerMaxSpeed dd 4, -4
	characterWidth dd 9
	characterHeight dd 5 ; Moet gedeeld worden door 1.2 tov de hoogte om een mooi vierkant te krijgen, dit komt doordat het 320x200 grid gestretched wordt naar 640x480 pixeles

END 