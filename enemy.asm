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
include "enemy.inc"
include "graphics.inc"

;=============================================================================
; CODE
;=============================================================================
CODESEG

PROC updateEnemyPosition
    USES eax, ebx, ecx, edx

    ; mov ecx, [missileAmount]
    ; xor ebx, ebx
    ; @@missileLoop:
    ;     mov eax, ebx ; calculate offset of array in eax
    ;     mov edx, 8
    ;     mul edx

    ;     cmp [missilePosition+eax], 1000 ;check if missile is existing
    ;     je @@noMissile
    ;         call drawMissile, 0, [missilePosition+eax], [missilePosition+eax+4] ; color over existing missile
    ;         mov edx, [missileSpeed]
    ;         sub [missilePosition+eax+4], edx ; move in y direction
    ;         ;out of bounds check
    ;         add edx, 1
    ;         cmp [missilePosition+eax+4], edx
    ;         jg @@noOutOfBounds
    ;             mov [missilePosition+eax],1000
    ;             mov [missilePosition+eax],1000
    ;             jmp @@noMissile
    ;         @@noOutOfBounds:
    ;         call drawMissile, 10, [missilePosition+eax], [missilePosition+eax+4]
    ;     @@noMissile:
    ;     inc ebx
    ;     loop @@missileLoop

	ret
ENDP

PROC addEnemies
    USES eax, ebx, ecx, edx

    
    xor ebx, ebx ; current collumn
    xor ecx, ecx ; current row
    xor edx, edx ; current enemy position
    
    @@loopBegin:
        mov eax, [enemyAmount]
        cmp edx, eax
        je @@loopEnd
        cmp ebx, [enemyCollumnAmount] ; check if new row needs to be started
        jne @@noNewRow
            sub ebx, [enemyCollumnAmount]
            inc ecx
        @@noNewRow:
        ; calculate X position of enemy
        mov eax, ebx
        push edx
        mul [enemySpacingX]
        pop edx
        add eax, [enemyOffsetX]
        mov [enemyPositionX+edx], eax
        ; calculate Y position of enemy
        mov eax, ecx
        push edx
        mul [enemySpacingY]
        pop edx
        add eax, [enemyOffsetY]
        mov [enemyPositionY+edx], eax
        ; draw enemy
        call drawEnemy, 10, [enemyPositionX+edx], [enemyPositionY+edx]

        inc edx
        inc ebx
        jmp @@loopBegin
    @@loopEnd:
    
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
    enemyAmount dd 55
	enemyPositionX dd 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000 ;x, y
	enemyPositionY dd 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000, 1000, 1000, 1000, 1000, 10000 ;x, y
	
    enemyCollumnAmount dd 11 ; amount of enemies next to each other
    enemySpacingX dd 20 ; X spacing between every enemy
    enemySpacingY dd 20 ; Y spacing between every enemy

    enemyOffsetX dd 10 ; X offset drom frame side
    enemyOffsetY dd 10 ; Y offset drom frame side

	enemyWidth dd 10
	enemyHeight dd 10 ; Moet gedeeld worden door 1.2 tov de hoogte om een mooi vierkant te krijgen, dit komt doordat het 320x200 grid gestretched wordt naar 640x480 pixeles

    testString db "test", 10, 13, '$'
END 