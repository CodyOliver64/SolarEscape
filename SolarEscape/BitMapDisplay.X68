*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:  This file handles all screen drawing needed for the game.
*               It houses the necessary bitmaps, wrapper functions to assign attributes depending on whats being drawn,
*               and the main cropAndPrintBMP32 subroutine which prints based on the wrapper function setup.
*               The main game loop will call the player/object functions. 
*               Other wrapper functions will be called when needed directly during execution.
*-----------------------------------------------------------

IMAGE_WIDTH_OFFSET      EQU 18
IMAGE_HEIGHT_OFFSET     EQU 22
PIXEL_DATA_OFFSET       EQU 10
PEN_COLOR_TRAP_CODE     EQU 80
DRAW_PIXEL_TRAP_CODE    EQU 82

BG_CHUNK_DISPLAY_X      equ 25
BG_CHUNK_DISPLAY_Y      equ 4
BG_CHUNK_WIDTH          equ 45
BG_CHUNK_HEIGHT         equ 50
BG_CHUNK_START_X        equ 25
BG_CHUNK_START_Y        equ 4

PL_CHUNK_WIDTH          equ 60
PL_CHUNK_HEIGHT         equ 32
PL_CHUNK_START_X        equ 0
PL_CHUNK_START_Y        equ 0

COIN_CHUNK_WIDTH        equ 30
COIN_CHUNK_HEIGHT       equ 28
COIN_CHUNK_START_X      equ 0
COIN_CHUNK_START_Y      equ 0

ENEMY_CHUNK_WIDTH       equ 30
ENEMY_CHUNK_HEIGHT      equ 20
ENEMY_CHUNK_START_X     equ 0
ENEMY_CHUNK_START_Y     equ 0

LIVES_DISPLAY_X         equ 664
LIVES_DISPLAY_Y         equ 17
LIVES_CHUNK_WIDTH       equ 216
LIVES_CHUNK_HEIGHT      equ 56
LIVES_CHUNK_START_X     equ 0
LIVES_CHUNK_START_Y     equ 0

HEART_CROP_Y            equ 17
HEART_CROP_WIDTH       equ 73
HEART_CROP_HEIGHT       equ 56

        
reprintPlayer
        movem.l ALL_REG,-(sp)
       
        lea     chunkDisplayX,a1
        move.l  #SHIP_X_POSITION,(a1)
        
        lea     chunkDisplayY,a2
        move.l  d2,(a2)
        
        lea     chunkWidth,a3
        move.l  #PL_CHUNK_WIDTH,(a3)
                
        lea     chunkWidthLoop,a5
        move.l  #PL_CHUNK_WIDTH,(a5)
        
        lea     chunkHeight,a4
        move.l  #PL_CHUNK_HEIGHT,(a4)
        
        lea     chunkStartX,a6
        move.l  #PL_CHUNK_START_X,(a6)
        lea     chunkStartY,a6
        move.l  #PL_CHUNK_START_Y,(a6)
        
        lea     playerImage,a0
        
        jsr     cropAndPrintBMP32
        

        movem.l (sp)+,ALL_REG
        rts
        
*D1 = LeftXPos D2 = Upper Y Pos
reprintObject     
        movem.l ALL_REG,-(sp)
        
        lea     chunkDisplayX,a1
        move.l  d1,(a1)
        
        lea     chunkDisplayY,a2
        move.l  d2,(a2)
        
        lea     chunkWidth,a3
        move.l  #COIN_CHUNK_WIDTH,(a3)
                
        lea     chunkWidthLoop,a5
        move.l  #COIN_CHUNK_WIDTH,(a5)
        
        lea     chunkHeight,a4
        move.l  #COIN_CHUNK_HEIGHT,(a4)
        
        lea     chunkStartX,a6
        move.l  #COIN_CHUNK_START_X,(a6)
        lea     chunkStartY,a6
        move.l  #COIN_CHUNK_START_Y,(a6)
        
        
        jsr     cropAndPrintBMP32
        
        movem.l (sp)+,ALL_REG
        rts
        
reprintScoreBackground
        movem.l ALL_REG,-(sp)
        
        lea     chunkDisplayX,a1
        move.l  #BG_CHUNK_DISPLAY_X,(a1)
        
        lea     chunkDisplayY,a2
        move.l  #BG_CHUNK_DISPLAY_Y,(a2)
        
        lea     chunkWidth,a3
        move.l  #BG_CHUNK_WIDTH,(a3)
                
        lea     chunkWidthLoop,a5
        move.l  #BG_CHUNK_WIDTH,(a5)
        
        lea     chunkHeight,a4
        move.l  #BG_CHUNK_HEIGHT,(a4)
        
        lea     chunkStartX,a6
        move.l  #BG_CHUNK_START_X,(a6)
        lea     chunkStartY,a6
        move.l  #BG_CHUNK_START_Y,(a6)
        
        lea     borderImage,a0
        
        jsr     cropAndPrintBMP32
        

        movem.l (sp)+,ALL_REG
        rts


printBackground
        movem.l ALL_REG,-(sp)
        
        lea     chunkDisplayX,a1
        move.l  #0,(a1)
        
        lea     chunkDisplayY,a2
        move.l  #0,(a2)
        
        lea     chunkWidth,a3
        move.l  #OUTPUT_WIDTH,(a3)
                
        lea     chunkWidthLoop,a5
        move.l  #OUTPUT_WIDTH,(a5)
        
        lea     chunkHeight,a4
        move.l  #OUTPUT_FULL_HEIGHT,(a4)
        
        lea     chunkStartX,a6
        move.l  #0,(a6)
        lea     chunkStartY,a6
        move.l  #0,(a6)
        
        jsr     cropAndPrintBMP32
        

        movem.l (sp)+,ALL_REG
        rts
      
printInitLives
        movem.l ALL_REG,-(sp)
        
        lea     chunkDisplayX,a1
        move.l  #LIVES_DISPLAY_X,(a1)
        
        lea     chunkDisplayY,a2
        move.l  #LIVES_DISPLAY_Y,(a2)
        
        lea     chunkWidth,a3
        move.l  #LIVES_CHUNK_WIDTH,(a3)
                
        lea     chunkWidthLoop,a5
        move.l  #LIVES_CHUNK_WIDTH,(a5)
        
        lea     chunkHeight,a4
        move.l  #LIVES_CHUNK_HEIGHT,(a4)
        
        lea     chunkStartX,a6
        move.l  #LIVES_CHUNK_START_X,(a6)
        lea     chunkStartY,a6
        move.l  #LIVES_CHUNK_START_Y,(a6)
        
        lea     heartsImage,a0
        
        jsr     cropAndPrintBMP32



        movem.l (sp)+,ALL_REG
        rts
        
printUpdatedLives
        movem.l ALL_REG,-(sp)
        
        lea     heartCropX,a0

        lea     chunkDisplayX,a1
        move.l  (a0),(a1)
        
        lea     chunkDisplayY,a2
        move.l  #HEART_CROP_Y,(a2)
        
        lea     chunkWidth,a3
        move.l  #HEART_CROP_WIDTH,(a3)
                
        lea     chunkWidthLoop,a5
        move.l  #HEART_CROP_WIDTH,(a5)
        
        lea     chunkHeight,a4
        move.l  #HEART_CROP_HEIGHT,(a4)
        
        lea     chunkStartX,a6
        move.l  (a0),(a6)
        lea     chunkStartY,a6
        move.l  #HEART_CROP_Y,(a6)
        
        add.l  #HEART_CROP_WIDTH,(a0)
        
        lea     borderImage,a0
        
        jsr     cropAndPrintBMP32



        movem.l (sp)+,ALL_REG
        rts

cropAndPrintBMP32                    

* D7 = width, D6 = height, D3 = current width, D4 = current height, D5 = math stuff, D0-D2 = trap codes/screen pos
* A0 = current pixel pointer, A1 = chunkDisplayX, A2 = chunkDisplayY, A3 = chunkWidth, A4 = chunkHeight
* A5 = chunkWidthLoop, A6 = chunkStartX/Y
    
        *Initial Setup
        
        move.l #IMAGE_WIDTH_OFFSET,d0 *Get Width
        move.l (a0,d0),d7
        rol.w #8,d7
        swap d7
        rol.w #8,d7
        
        move.l #IMAGE_HEIGHT_OFFSET,d0 *Get Height
        move.l (a0,d0),d6
        rol.w #8,d6
        swap d6
        rol.w #8,d6
        
        move.l #PIXEL_DATA_OFFSET,d0 *Get pixel data offset
        move.l (a0,d0),d1
        rol.w #8,d1
        swap d1
        rol.w #8,d1
        add.l d1,a0


        *Screen Dimension Setup
        move.l  (a1),d3  *Set  X start position on output window
        
        move.l  (a2),d5  *Set  Y start position on output window
        add.l   (a4),d5
        move.l  d5,d4  

      
        
        *Move Pixel Pointer To Initial Position (width*4*[height - (chuckStartY+chuckHeight)])
        lea     chunkStartY,a6 *account for rows
        move.l  d6,d5
        sub.l   (a6),d5
        sub.l   (a4),d5
        mulu    #4,d5
        mulu    d7,d5
        
        lea     chunkStartX,a6 *account for columns
        clr.l   d1
        move.l  (a6),d1
        mulu    #4,d1
        add.l   d1,d5

        add.l   d5,a0    
           
*Loops through the row using input dimensions, coloring each pixel appropriately until the end of the row is reached     
widthLoop:
        clr.l d1
        
        move.b (a0)+,d1 *Set pixel pen color
        lsl.l #8,d1
        move.b (a0)+,d1
        lsl.l #8,d1
        move.b (a0)+,d1
        add #1,a0 *(This is to skip over the alpha value, this program does not utilize the alpha)
        
        move.l  #PEN_COLOR_TRAP_CODE, d0
        trap    #15

        
        move.l  #DRAW_PIXEL_TRAP_CODE,d0 * Color Pixel
        move.l  d3,d1
        move.l  d4,d2
        trap    #15
        
        addi.l  #1,d3 *increment current pixel on X and check if the row continues
        subi.l  #1,(a3) *a3 will serve as the width loop counter
        bne     widthLoop
        
*When the end of the row is reached, this loop will reset our screen position and adjust 
*our pixel data pointer until we've printed our final row in the crop
heightLoop:
        move.l  (a1),d3 * reset width
        move.l  (a5),(a3)
        
        clr.l   d5      *adjust pixel pointer
        move.l  d7,d5
        sub.l   (a5),d5
        mulu    #4,d5
        add.l   d5,a0
                

        subi.l  #1,d4 *decrement current pixel on Y and check if the column continues
        subi.l  #1,(a4) *a4 will serve as the height loop counter
        cmp.l   #1,(a4)
        bne     widthLoop
        
        rts

        
        
      
borderImage:
        INCBIN    "FireSky1.bmp" 
playerImage:
        INCBIN    "SpaceBoy.bmp"
coinImage:
        INCBIN    "CoinBoy.bmp"
enemyImage:
        INCBIN    "Fireboy2.bmp"
heartsImage:
        INCBIN    "Hearts.bmp"
titleImage:
        INCBIN    "TitleScreen1.bmp"



chunkStartX     ds.l 1
chunkStartY     ds.l 1
chunkWidth      ds.l 1
chunkWidthLoop  ds.l 1
chunkHeight     ds.l 1
chunkDisplayX   ds.l 1
chunkDisplayY   ds.l 1

heartCropX      dc.l 664








































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
