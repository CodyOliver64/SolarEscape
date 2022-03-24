*-----------------------------------------------------------
* Title      :  Solar Escape
* Written by :  Cody Oliver
* Date       :  10/18/2021
* Description:  Welcome to the game, Solar Escape!

*               This file contains the main game loops as well as functions that handle player movement,
*               screen output and game setup.

*               This main file will include four other files that handle specific functioanlity within the
*               game loop (descriptions included in those files). 
*               Included in the zipped file is the source code required as well as the art assets.
*               ---------------------------------------------------------------------------------------------
                   
*               Run the SolarEscape main file to play. 
*               Use the SPACE key to thrust. 
*-----------------------------------------------------------
            

START   ORG     $1000


ALL_REG         REG     D0-D7/A0-A6

**************Trap Codes****************************
SET_PEN_COLOR_COMMAND           equ     80
SET_TEXT_COLOR_COMMAND          equ     21
SET_FILL_COLOR_COMMAND          equ     81
DRAW_SQUARE_COMMAND             equ     87
INPUT_COMMAND                   equ     19
DRAWING_MODE_COMMAND	        equ	    92
DOUBLE_BUFFERED_COMMAND	        equ	    17
REPAINT_SCREEN_COMMAND	        equ	    94
SET_OUTPUT_RESOLUTION_COMMAND   equ     33
DISPLAY_TEXT_COMMAND            equ     95
PLAY_SINGLE_SOUND_COMMAND       equ     73


**************Screen Values****************************
OUTPUT_WIDTH                    equ     900
OUTPUT_FULL_HEIGHT              equ     850
PLAY_AREA_TOP                   equ     100
PLAY_AREA_BOTTOM                equ     760
PLAY_AREA_LEFT                  equ     0
PLAY_AREA_RIGHT                 equ     900

WHITE			                equ	$00FFFFFF
BLACK                           equ $FFFFFFFF
RED                             equ $FF
GREEN                           equ $00FF00

**************Player Values****************************
JUMP_KEY                        equ $20
RESET_KEY                       equ 'F'
VELOCITY_AFTER_JUMP             equ -20     *two fractional bit represesentation of -5.25
SHIP_WIDTH		                equ	20
SHIP_HEIGHT		                equ	20
SHIP_START_Y_POSITION	        equ	300
SHIP_X_POSITION	                equ	100
SHIP_START_VELOCITY		        equ	30      *two fractional bit represesentation of 7.5

SHIP_X_POSITION	                equ	100
GRAVITY                         equ 10      *two fractional bit represesentation of 2.5



gameSetup:              
        jsr     setScreenParameters
        jsr     initTitleScreen
        jsr     initPlayerStart
        jsr     initRandomSeed
        jsr     updateSevenSegment *display initial score




*D2 = Player Y Pos, D6 = Acceleration Due to Gravity, D7 = Velocity, A6 = currentPlayerY
gameLoop:                         
        jsr     clearPlayArea  
        jsr     detectCollision
        jsr     detectPlayerOutOfBounds
        jsr     applyPlayerVelocity
        jsr     updateObjects
        jsr     getUserInput
        jsr     reprintPlayer
        jsr     drawObjects
        jsr     switchBuffer
        
        bra     gameLoop
        

*-----------------------------------------------------------
*                   GRAVITY/MOVEMENT
*-----------------------------------------------------------
applyPlayerVelocity
       
        add.l   d6,d7                   *update velocity based on gravity
        move.l  d7,cummulativeVelocity  *FIXED POINT MATH
        asr.l   #2,d7
        add.l   d7,d2                   *update player position based on current velocity
        move.l  d2,(a6)
        move.l  cummulativeVelocity,d7
        
        rts
getUserInput
        move.l  #JUMP_KEY,d1
        move.b  #INPUT_COMMAND,d0
        trap    #15
        andi.l  #$FF,d1
        bne     handleJump
        
        move.l  #0,d1       *reset jump flag when jump key is released
        trap    #15
        andi.l  #JUMP_KEY,d1
        bne     resetFlag
        
        rts
handleJump:
        cmp.l   #1,jumpFlag
        bmi     noJump
        
        move.l  #VELOCITY_AFTER_JUMP<<2,d7   *FIXED POINT MATH (set jump velocity)
        move.l  #VELOCITY_AFTER_JUMP<<2,cummulativeVelocity
        
        move.l  #0,jumpFlag     *limit jump until key is released
        rts
noJump:
        rts
resetFlag:
        move.l  #1,jumpFlag
        rts	

*-----------------------------------------------------------
*                   SCREEN/SETUP 
*-----------------------------------------------------------	    
clearPlayArea
        movem.l ALL_REG,-(sp)
        
        move.l	#BLACK,d1 
	    move.b	#SET_PEN_COLOR_COMMAND,d0
	    trap	#15
	    move.b	#SET_FILL_COLOR_COMMAND,d0
	    trap	#15
	    move.l  #PLAY_AREA_LEFT,d1
	    move.l  #PLAY_AREA_TOP,d2
	    move.l  #PLAY_AREA_RIGHT,d3
	    move.l  #PLAY_AREA_BOTTOM,d4
	    move.l  #DRAW_SQUARE_COMMAND,d0
	    trap    #15

        movem.l (sp)+,ALL_REG
        rts
	    
switchBuffer
	    move.b  #REPAINT_SCREEN_COMMAND,d0
      	TRAP    #15
	    rts
	    
setScreenParameters
        move.b	#DRAWING_MODE_COMMAND,d0 *set double buffered mode
      	move.b	#DOUBLE_BUFFERED_COMMAND,d1
      	trap	#15
      	
      	move.b  #SET_OUTPUT_RESOLUTION_COMMAND,d0 *set output window resolution
        move.l  #OUTPUT_WIDTH,d1
        swap.w  d1                             
        move.w  #OUTPUT_FULL_HEIGHT,d1
        TRAP    #15 
        
        rts
        
initPlayArea
        jsr     clearPlayArea
        jsr     displayLoadMessage

        lea     borderImage,a0
        jsr     printBackground *print initial screen
        jsr     printInitLives
        
        rts
        
initTitleScreen
        jsr     displayLoadMessage

        lea     titleImage,a0
        jsr     printBackground
        
        jsr     switchBuffer
        
        lea     loopMusic,a1 *loop background music
        moveq   #74,d0
        move.l  #0,d1
        trap    #15
        moveq   #77,d0
        move.l  #1,d2
        trap    #15
waitForStartLoop:
        move.l  #JUMP_KEY,d1
        move.b  #INPUT_COMMAND,d0
        trap    #15
        andi.l  #$FF,d1
        beq     waitForStartLoop 
        jsr     initPlayArea
              
        
initPlayerStart
        move.l	#SHIP_START_Y_POSITION,d2 *set Y position
        lea     currentPlayerY,a6        
        move.l	#GRAVITY,d6
        move.l	#SHIP_START_VELOCITY,d7
        
        rts

displayLoadMessage
        move.l	#WHITE,d1 
        clr.l   d2 
	    move.b	#SET_TEXT_COLOR_COMMAND,d0
	    trap	#15
        move.l  #DISPLAY_TEXT_COMMAND,d0
       	move.l  #400,d1
       	move.l  #350,d2
        lea     stringLoading,a1     
        trap    #15
        jsr     switchBuffer
        
initRandomSeed
        lea     RANDOMVAL,a0    *set time based seed
        move.l	#8,d0
	    trap	#15
	    ori.l	#$75000000,d1   *fill upper empty bit
	    move.l	d1,(a0)
        
        rts
       
gameOver     	
       	jsr     clearPlayArea
       	
       	move.l	#RED,d1    *display you lose message
        clr.l   d2 
	    move.b	#SET_TEXT_COLOR_COMMAND,d0
	    trap	#15
        move.l  #DISPLAY_TEXT_COMMAND,d0
       	move.l  #305,d1
       	move.l  #350,d2
        lea     stringYouLose,a1     
        trap    #15

        jsr     switchBuffer
        jsr     userResetGame
        
youWin     	
       	jsr     clearPlayArea
       	
       	move.l	#GREEN,d1    *display you win message
        clr.l   d2 
	    move.b	#SET_TEXT_COLOR_COMMAND,d0
	    trap	#15
        move.l  #DISPLAY_TEXT_COMMAND,d0
       	move.l  #305,d1
       	move.l  #350,d2
        lea     stringYouWin,a1     
        trap    #15

        jsr     switchBuffer
        jsr     userResetGame
        
userResetGame
        move.l  #RESET_KEY,d1
        move.b  #INPUT_COMMAND,d0
        trap    #15
        andi.l  #$FF,d1
        bne     resetGameStats
        bra     userResetGame
        
resetGameStats:
        move.l  #0,currentScore1    *reset score
        move.l  #0,currentScore2
        move.l  #0,rawScore
        
        move.l  #5,speedOffset      *reset speed range
        move.l  #0,speedInterval
        
        move.l  #664,heartCropX     *reset lives
        move.l  #3,currentLives
        
        jsr     resetObjectStats    *reset all enemies/objects
        
        jsr     initPlayArea        *reset screen
        jsr     initPlayerStart
        
        jsr     updateSevenSegment
        
        jsr     gameLoop



currentPlayerY      ds.l 1
cummulativeVelocity ds.l 1
jumpFlag            dc.l 1

stringYouLose       dc.b    'You Lose! Press F To Try Again!',0
stringYouWin        dc.b    'You WIN! Press F To Play Again!',0

stringLoading       dc.b    'Loading...',0

    SIMHALT



getFiles:  
    INCLUDE SpawnObject.X68
    INCLUDE DetectCollision.X68
    INCLUDE SevenSegLED.X68
    INCLUDE BitMapDisplay.X68

    END    START











































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
