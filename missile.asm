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
include "missile.inc"
include "player.inc"
include "graphics.inc"
include "enemy.inc"


;=============================================================================
; CODE
;=============================================================================
CODESEG

PROC updateMissilePosition
    USES eax, ebx, ecx, edx

    mov ecx, [missileAmount]
    xor ebx, ebx
    @@missileLoop:
        mov eax, ebx ; calculate offset of array in eax
        mov edx, 8
        mul edx

        cmp [missilePosition+eax], 1000 ;check if missile is existing
        je @@noMissile
            call drawMissile, 0, [missilePosition+eax], [missilePosition+eax+4] ; color over existing missile
            mov edx, [missileSpeed]
            sub [missilePosition+eax+4], edx ; move in y direction
            ;out of bounds check
            add edx, 1
            cmp [missilePosition+eax+4], edx
            jg @@noOutOfBounds
                mov [missilePosition+eax],1000
                mov [missilePosition+eax],1000
                jmp @@noMissile
            @@noOutOfBounds:
            call drawMissile, 10, [missilePosition+eax], [missilePosition+eax+4]
        @@noMissile:
        inc ebx
        loop @@missileLoop

	ret
ENDP

PROC addMissile
    USES eax, ebx, ecx, edx

    mov ecx, [missileAmount]
    xor ebx, ebx
    @@availableMissileLoop:
        mov eax, ebx ; calculate offset of array in eax
        mov edx, 8
        mul edx

        cmp [missilePosition+eax], 1000 ;check if missile is already taken
        jne @@noAvailableMissile ; if no missile available exit loop
            mov edx, [playerPosition] ; set x postion of missile
            add edx, 3
            mov [missilePosition+eax], edx

            mov edx, PLAYERPOSY
            sub edx, [missileHeight]
            sub edx, 1
            mov [missilePosition+eax+4], edx ; set y position of missile

            ;call drawMissile, 10, [playerPosition], edx ; draw missile
            jmp @@endLoop
        @@noAvailableMissile:
        inc ebx
	    loop @@availableMissileLoop  
    @@endLoop:

    ret
ENDP

PROC checkHits
    USES eax, ebx, ecx, edx

    mov ecx, [missileAmount]
    xor ebx, ebx
    @@missileLoop:
        mov eax, ebx ; calculate offset of array in eax
        mov edx, 8
        mul edx

         ; registers free: ebx, edx
        cmp [missilePosition+eax], 1000 ;check if missile is existing
        je @@noMissile
             ; loop over enemies
            call checkEnemyHit, [missilePosition+eax], [missilePosition+eax+4], ebx
        @@noMissile:
        inc ebx
        loop @@missileLoop

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
    missileAmount dd 2
	missilePosition dd 1000, 1000, 1000, 1000 ;x, y
	missileSpeed dd 4 ;vy
	missileWidth dd 2
	missileHeight dd 5 ; Moet gedeeld worden door 1.2 tov de hoogte om een mooi vierkant te krijgen, dit komt doordat het 320x200 grid gestretched wordt naar 640x480 pixeles

    testString db "test", 10, 13, '$'
END 