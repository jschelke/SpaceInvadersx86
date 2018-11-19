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

	mov eax, [playerSpeed]
	or eax, [playerSpeed + 4]
	test eax, eax
	jz @@nomovement
		call drawShip, 0, [playerPossition], [playerPossition + 4] ; make old position black

		; Move to the left
		mov eax, [playerSpeed]
		add [playerPossition], eax
		jns @@leftBorderSafe
			mov [playerPossition], 0
		@@leftBorderSafe:

		; Move to the right
		mov eax, SCRWIDTH
		sub eax, [characterWidth]
		cmp [playerPossition], eax
		jl @@rightBorderSafe
			mov [playerPossition], eax
		@@rightBorderSafe:

		; Move up
		mov eax, [playerSpeed + 4]
		add [playerPossition + 4], eax
		jns @@upperBorderSafe
			mov [playerPossition + 4], 0
		@@upperBorderSafe:

		; Move down
		mov eax, SCRHEIGHT
		sub eax, [characterHeight]
		cmp [playerPossition + 4], eax
		jl @@lowerBorderSafe
			mov [playerPossition + 4], eax
		@@lowerBorderSafe:


		call drawShip, 10, [playerPossition], [playerPossition + 4] ; color new position
	@@nomovement:

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
	playerPossition dd 100, 100 ;x, y
	playerSpeed dd 0, 0 ;vx, vy
	playerMaxSpeed dd 4, -4
	characterWidth dd 30
	characterHeight dd 25 ; Moet gedeeld worden door 1.2 tov de hoogte om een mooi vierkant te krijgen, dit komt doordat het 320x200 grid gestretched wordt naar 640x480 pixeles

END 