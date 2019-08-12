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
include "debug.inc"
include "enemy.inc"
include "missile.inc"


;=============================================================================
; CODE
;=============================================================================
CODESEG

PROC updateEnemyPosition
    USES eax, ebx, ecx, edx

    cmp [enemyMovementDirection], 1 ; check moevemeny direction
    je @@moveLeft
        ; move right
        mov ecx, [enemySpeed]
        add [enemyMovedX], ecx
        mov ecx, [enemyMovedX]
        cmp ecx, [enemyMovementRangeX] ;check if at end of movement
        jl @@notEndLeftMovement
            ; if at the end of the movement
            cmp [enemyDownMoveDone], 1
            je @@notEndLeftMovement
                mov ebx, 2
                mov [enemyDownMoveDone], 1
                mov [enemyMovementDirection], 1
                jmp @@stateFound
        @@notEndLeftMovement:
        mov [enemyDownMoveDone], 0
        mov ebx, 0
        jmp @@stateFound
    @@moveLeft:
    ; move left
    mov ecx, [enemySpeed]
    sub [enemyMovedX], ecx
    cmp [enemyMovedX], 0 ;check if at end of movement
    jg @@notEndRightMovement
        ; if at the end of the movement
        cmp [enemyDownMoveDone], 1
        je @@notEndRightMovement
            mov ebx, 2
            mov [enemyDownMoveDone], 1
            mov [enemyMovementDirection], 0
            jmp @@stateFound
    @@notEndRightMovement:
    mov [enemyDownMoveDone], 0
    mov ebx, 1
    jmp @@stateFound

    @@stateFound:
    mov [enemiesAlive], 0
    xor ecx, ecx ; current enemy position
    @@loopBegin:
        cmp ecx, [enemyAmount]
        je @@loopEnd
        
        cmp [enemyPositionX], 1000
        je @@noEnemy
            mov eax, 4
            mul ecx
            inc [enemiesAlive]
            call drawRectangle, 0, [enemyPositionX+eax], [enemyPositionY+eax], 13, 10

             ; start switch case for movement direction
            cmp ebx, 0 ; move right
            jne @@noRightMovement
                mov edx, [enemySpeed]
                add [enemyPositionX+eax], edx
                jmp @@endSwitchCase
            @@noRightMovement:

            cmp ebx, 1 ; move right
            jne @@noLeftMovement
                mov edx, [enemySpeed]
                sub [enemyPositionX+eax], edx
                jmp @@endSwitchCase
            @@noLeftMovement:

            cmp ebx, 2 ; move right
            jne @@noDownMovement
                mov edx, [enemySpacingY]
                add [enemyPositionY+eax], edx
                jmp @@endSwitchCase
            @@noDownMovement:

            @@endSwitchCase:
            
            call drawSprite, 10,[enemyPositionX+eax], [enemyPositionY+eax], offset enemySprite, [enemySpriteLength], [enemySpriteWidth] 
            ;call drawEnemy, 10, [enemyPositionX+eax], [enemyPositionY+eax]
        @@noEnemy:

        inc ecx
        jmp @@loopBegin
    @@loopEnd:
    cmp [enemiesAlive], 0
    ; jne @@gameStillRunning
    ;     ;if running this all enemies are dead
    ;     call fillBackground, 0
    ;     call DisplayScore
    ;     call enemyInitialization
	;     call addEnemies
    ; @@gameStillRunning:
	ret
ENDP

PROC addEnemies
    USES eax, ebx, ecx, edx

    
    xor ebx, ebx ; current collumn
    xor ecx, ecx ; current row
    xor edx, edx ; current enemy position
    
    @@loopBegin:
        cmp edx, [enemyAmount]
        je @@loopEnd
        cmp ebx, [enemyCollumnAmount] ; check if new row needs to be started
        jne @@noNewRow
            sub ebx, [enemyCollumnAmount]
            inc ecx
        @@noNewRow:
        ; calculate X position of enemy
        push edx
        mov eax, 4
        mul edx
        mov edx, eax

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
        call drawSprite, 10,[enemyPositionX+edx], [enemyPositionY+edx], offset enemySprite, [enemySpriteLength], [enemySpriteWidth] 
        
        pop edx
        inc edx
        inc ebx
        jmp @@loopBegin
    @@loopEnd:
    
    ret
ENDP


PROC checkEnemyHit
    ARG @@xpos:dword, @@ypos:dword, @@missileNumber:dword
    USES eax, ebx, ecx, edx

    xor ebx, ebx ; current enemy position
    @@loopBegin:
        cmp ebx, [enemyAmount]
        je @@loopEnd

        mov eax, 4
        mul ebx
        mov edx, [enemyPositionX+eax]
        cmp [@@xpos], edx
        jl @@noHit
            add edx, [enemyWidth]
            cmp [@@xpos], edx
            jg @@noHit
                ; hit is found in X
                mov edx, [enemyPositionY+eax]
                cmp [@@ypos], edx
                jg @@noHit
                    sub edx, [enemyHeight]
                    cmp [@@ypos], edx
                    jl @@noHit
                        ; hit is found in Y
                        ; remove enemy from game
                        call drawRectangle, 0, [enemyPositionX+eax], [enemyPositionY+eax], 13, 10
                        mov [enemyPositionX+eax], 1000
                        mov [enemyPositionY+eax], 1000

                        ;remove missile from game
                        mov eax, 8
                        mul [@@missileNumber]
                        call drawMissile, 0, [missilePosition+eax], [missilePosition+eax+4]
                        mov [missilePosition+eax], 1000
                        mov [missilePosition+eax+4], 1000

                        inc [score]
                        call DisplayScore

                        jmp @@loopEnd
        @@noHit:

        inc ebx
        jmp @@loopBegin
    @@loopEnd:
    
    ret
ENDP

PROC enemyInitialization
    USES eax, ebx, edx

    ;calculate X movement Range
    mov eax, [enemySpacingX]
    mov ebx, [enemyCollumnAmount]
    mul ebx
    add eax, [enemyOffsetX]
    add eax, [enemyOffsetX]
    mov ebx, SCRWIDTH
    sub ebx, eax
    mov [enemyMovementRangeX], ebx

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
    enemiesAlive dd 0
    enemyAmount dd 44
	enemyPositionX dd 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000 ;x, y
	enemyPositionY dd 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000
    
    enemyCollumnAmount dd 11 ; amount of enemies next to each other
    enemySpacingX dd 20 ; X spacing between every enemy
    enemySpacingY dd 16 ; Y spacing between every enemy

    enemyOffsetX dd 10 ; X offset from frame side
    enemyOffsetY dd 10 ; Y offset from frame side

	enemyWidth dd 10
	enemyHeight dd 8 ; Moet gedeeld worden door 1.2 tov de hoogte om een mooi vierkant te krijgen, dit komt doordat het 320x200 grid gestretched wordt naar 640x480 pixeles

    enemyMovementRangeX dd 0
    enemyMovedX dd 0
    enemyMovementDirection db 0
    enemyDownMoveDone db 0;
    enemySpeed dd 1

    testString db "test", 10, 13, '$'
END 