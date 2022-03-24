*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:  This file manages the Seven Segment LED display that is used to show the player score. It has its own draw function
*               specific to the locations stored in memory that represent where each segment should be drawn for both the first
*               and second digit. To maintain a quick gameloop, the positions are stored in memory rather than being calculated
*               at runtime. The algorithm uses a mask table to determine which segments are active based on the digit displayed.
*-----------------------------------------------------------


PEN_WIDTH       equ 4
PEN_WIDTH_CODE  equ 93
DRAW_LINE_CODE  equ 84


*A0 = Segment Mask Table/Score 1, A1 = Segment Coord Table/Score2
*D6 = Loop Counter, D1 = Current Digit, D0 = Table Offset
updateSevenSegment                     
        movem.l ALL_REG,-(sp)
        
        lea     currentScore1,a0
        lea     currentScore2,a1
        move.l  (a0),d0
        
        cmpi    #10,d0           *check if first digit goes over 9, reset first digit and increment second
        bne     updateFirstDigit
        move.l  #0,(a0)
        move.l  (a0),d0
        add.l   #1,(a1)
        
updateFirstDigit:
        lea     segmentMaskTable,a0
        lea     segmentCoordTable2,a1
        clr     d1
        move.b  (a0,d0),d1
        move.l  #0,d6               *set counter
        jsr     checkSegmentActive
updateSecondDigit:
        lea     currentScore2,a0
        move.l  (a0),d0
        lea     segmentMaskTable,a0
        lea     segmentCoordTable1,a1
        clr     d1
        move.b  (a0,d0),d1
        move.l  #0,d6               *set counter
        jsr     checkSegmentActive

        movem.l (sp)+,ALL_REG
        rts    

checkSegmentActive        
        move.l  d1,d2
        andi.b  #1,d2
        beq     nextSegment
        jsr     drawSegment
nextSegment:
        lsr.b   #1,d1
        addi.l  #1,d6
        cmp.l   #7,d6  *loop through all 7 possible segments
        blt     checkSegmentActive
        rts

drawSegment
        movem.l ALL_REG,-(sp)
        
        move.l  d6,d5
        mulu    #8,d5
        add.l   d5,a1
        
        move.l	#WHITE,d1 
	    move.b	#SET_PEN_COLOR_COMMAND,d0
	    trap	#15

        move.l  #PEN_WIDTH_CODE,d0
        move.l  #PEN_WIDTH,d1
        trap    #15
        
        move.l  #DRAW_LINE_CODE,d0
        move.w  (a1)+,d1
        move.w  (a1)+,d2
        move.w  (a1)+,d3
        move.w  (a1)+,d4
        trap    #15
        
        
        movem.l (sp)+,ALL_REG
        rts

               


segmentMaskTable:
zeroMask    dc.b $3F
oneMask     dc.b $6
twoMask     dc.b $5B
threeMask   dc.b $4F
fourMask    dc.b $66
fiveMask    dc.b $6D
sixMask     dc.b $7D
sevenMask   dc.b $7
eightMask   dc.b $7F
nineMask    dc.b $6F

segmentCoordTable1:
a_X1_1  dc.w 30
a_Y1_1  dc.w 20
a_X2_1  dc.w 45
a_Y2_1  dc.w 20

b_X1_1  dc.w 45
b_Y1_1  dc.w 20
b_X2_1  dc.w 45
b_Y2_1  dc.w 35

c_X1_1  dc.w 45
c_Y1_1  dc.w 35
c_X2_1  dc.w 45
c_Y2_1  dc.w 50

d_X1_1  dc.w 30
d_Y1_1  dc.w 50
d_X2_1  dc.w 45
d_Y2_1  dc.w 50

e_X1_1  dc.w 30
e_Y1_1  dc.w 35
e_X2_1  dc.w 30
e_Y2_1  dc.w 50

f_X1_1  dc.w 30
f_Y1_1  dc.w 20
f_X2_1  dc.w 30
f_Y2_1  dc.w 35

g_X1_1  dc.w 30
g_Y1_1  dc.w 35
g_X2_1  dc.w 45
g_Y2_1  dc.w 35

segmentCoordTable2:
a_X1_2  dc.w 50
a_Y1_2  dc.w 20
a_X2_2  dc.w 65
a_Y2_2  dc.w 20

b_X1_2  dc.w 65
b_Y1_2  dc.w 20
b_X2_2  dc.w 65
b_Y2_2  dc.w 35

c_X1_2  dc.w 65
c_Y1_2  dc.w 35
c_X2_2  dc.w 65
c_Y2_2  dc.w 50

d_X1_2  dc.w 50
d_Y1_2  dc.w 50
d_X2_2  dc.w 65
d_Y2_2  dc.w 50

e_X1_2  dc.w 50
e_Y1_2  dc.w 35
e_X2_2  dc.w 50
e_Y2_2  dc.w 50

f_X1_2  dc.w 50
f_Y1_2  dc.w 20
f_X2_2  dc.w 50
f_Y2_2  dc.w 35

g_X1_2  dc.w 50
g_Y1_2  dc.w 35
g_X2_2  dc.w 65
g_Y2_2  dc.w 35


































*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
