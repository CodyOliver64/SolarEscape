*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:  The subroutines defined in this file will handle all collisions detection of Solar Escape.
*               It will check all game object for collision with the player, update score/health, play sound effects, and determine if the player
*               has won or lost. 
*-----------------------------------------------------------


OUT_BOUNDS_TOP_Y        equ 120
OUT_BOUNDS_BOTTOM_Y     equ 680

RIGHT_X_PLAYER_BOUND    equ 160
LEFT_X_PLAYER_BOUND     equ 80

RESET_PLAYER_POS        equ 300
RESET_PLAYER_VELOCITY   equ -7

MAX_POINTS              equ 30



*A0 = Top Y Table, A1 = Left X Table, A2 = Object Active Table, A3 = Current Player Y Pos
*D7 = Object Type, D6 = Enemy Loop Counter, D5 = Coin Loop Counter, D0 = Object Active Flag, D3 = Left X, D1 = Top Y

*Loops through all 6 game objects loading their variables and checking if they are active. 
*If so it will then check that object for collision with the player.
detectCollision                     
        movem.l ALL_REG,-(sp)
        
        lea     currentPlayerY,a3       *set object properties
        move.l  (a3),d4
        lea     topYTable,a0
        lea     leftXTable,a1
        lea     objActiveTable,a2
        move.l  #0,d7                   *set object type (0 = coin, 1 = enemy)
        
        move.l  #2,d5                   *set loop counters to coins-1 & enemies
        move.l  #3,d6

checkCollisionLoop:
        move.l  (a2)+,d0
        move.l  (a1)+,d3
        move.l  (a0)+,d1
        
        cmpi    #0,d0                   *skip detection if coin is inactive
        beq     skipCheck  
        jsr     checkObject

skipCheck:
        subi    #1,d5                   *loop through coins
        bpl     checkCollisionLoop
        
        move.l  #1,d7                   *set object type
        
        subi    #1,d6                   *loop through enemies
        bpl     checkCollisionLoop
        
        movem.l (sp)+,ALL_REG
        rts



*Checks the collision box around the player, handling collision on contact with object based on the object type (coin/enemy)

*A0 = Coin Y Pos, A1 = Coin X Pos, A2 = Coin Active, A3 = Current Player Y Pos
*D6 = Right Collision Bound, D5 = Left Collision Bound, D4 = currentPlayerY, D3 = Upper Collision Bound
*D2 = Lower Collision Bound, D1 = currentCoinY, D7 = Object Type
checkObject
        movem.l ALL_REG,-(sp)
        
        move.l  #RIGHT_X_PLAYER_BOUND,d6
        move.l  #LEFT_X_PLAYER_BOUND,d5
        
        cmp     d6,d3                   *check if object is within RIGHT side of collision box
        bmi     rightXBoundsMatch
        
        movem.l (sp)+,ALL_REG
        rts
rightXBoundsMatch:
        cmp     d5,d3                   *check if object is within LEFT side of collision box
        bpl     leftXBoundsMatch
        
        movem.l (sp)+,ALL_REG
        rts
leftXBoundsMatch:              
        move.l  d4,d3                   *check if object is within TOP side of collision box
        subi.l  #SHIP_HEIGHT,d3
        cmp     d3,d1
        bpl     upperYBoundsMatch
        
        movem.l (sp)+,ALL_REG
        rts        
upperYBoundsMatch:
        move.l  d4,d2                   *check if object is within BOTTOM of collision box
        addi.l  #SHIP_HEIGHT,d2
        cmp     d2,d1
        bmi     collisionFound
        
        movem.l (sp)+,ALL_REG
        rts

collisionFound:
        cmp.l   #1,d7                   *checks if collision is with enemy or coin
        beq     handleEnemyCollision
        
handleCoinCollision:
        moveq   #PLAY_SINGLE_SOUND_COMMAND,d0   *play coin sound
        lea     coinSound,a1
        trap    #15
        
        move.l  #0,(-4,a2)                      *set object inactive
        
        lea     currentScore1,a6                *update score & reprint score
        addi.l  #1,(a6)
        jsr     reprintScoreBackground 
        jsr     updateSevenSegment
        
        addi.l  #1,rawScore                     *update total score and check if player won
        move.l  #MAX_POINTS,d0        
        cmp.l   rawScore,d0
        beq     playerWon
        
        addi.l  #1,speedInterval                *increase object speed every two coins collected
        move.l  speedThreshold,d0
        cmp.l   speedInterval,d0
        bne     noSpeedIncrease
        addi.l  #2,speedOffset
        move.l  #0,speedInterval      
noSpeedIncrease:
        movem.l (sp)+,ALL_REG
        rts  
    
handleEnemyCollision:
        moveq   #PLAY_SINGLE_SOUND_COMMAND,d0   *play crash sound
        lea     crashSound,a1
        trap    #15

        move.l  #0,(-4,a2)                      *set object inactive
            
        jsr     damagePlayer

        movem.l (sp)+,ALL_REG
        rts
           

*Detects if the player has flown too high or too low, damaging them and reseting their position with an initial jump
detectPlayerOutOfBounds
        movem.l ALL_REG,-(sp)
        
        move.l  #OUT_BOUNDS_TOP_Y,d4
        move.l  #OUT_BOUNDS_BOTTOM_Y,d5
        
        cmp.l   d2,d4                           *check if too high
        bpl     playerTooFar
        
        cmp.l   d2,d5                           *check if too low
        bmi     playerTooFar
        
        movem.l (sp)+,ALL_REG
        rts

playerTooFar:      
        moveq   #PLAY_SINGLE_SOUND_COMMAND,d0   *play crash sound
        lea     crashSound,a1
        trap    #15

        jsr     damagePlayer                    
 
        movem.l (sp)+,ALL_REG
        move.l  #RESET_PLAYER_POS,d2            *reset player position
        moveq   #RESET_PLAYER_VELOCITY,d7
        rts
            
*update and reprint current lives, checking if player has died
damagePlayer
        lea     currentLives,a6
        subi.l  #1,(a6)
        jsr     printUpdatedLives
        cmp.l   #1,(a6)
        bmi     playerDead
        rts     
playerDead:
        jsr     gameOver
playerWon:
        jsr     youWin

      
coinSound   dc.b 'CoinSound.wav',0
crashSound  dc.b 'CrashSound1.wav',0
loopMusic   dc.b 'Mercury.wav',0


currentScore1   dc.l 0   
currentScore2   dc.l 0
rawScore        dc.l 0

currentLives    dc.l 3       


































































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
