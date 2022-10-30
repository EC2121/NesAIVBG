.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014

.define JOYPAD1 $4016
.define JOYPAD2 $4017

.define SCROLL_X_BG $06
.define SCROLL_X $00
.define SCROLL_Y $05
.define buttons $01
.define OFFSET $02
.define I $03
.define LAST_INDEX_CURR_ROW $04

start:
    LDA #%10010000
    STA PPUCTRL
    LDA #%00011110
    STA PPUMASK
    
    ; load background palette
    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDA #$19
    STA PPUDATA
    LDA #$05
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$0F
    STA PPUDATA

;     load first sprite palette
    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$21
    STA PPUDATA
    LDA #$22
    STA PPUDATA
    LDA #$23
    STA PPUDATA
    LDA #$24
    STA PPUDATA

;     load second sprite palette
    LDA #$16
    STA PPUDATA
    LDA #$16
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$19
    STA PPUDATA

;   load background tiles

    LDA #$90
    STA SCROLL_X
    LDA #$90
    STA SCROLL_Y

    LDA #$1
    STA OAMADDR
    LDA #$77
    STA OAMDATA
    LDA #$2
    STA OAMADDR
    LDA #%00000001
    STA OAMDATA
    

    LDA #$20
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    
    LDA #$F
    STA LAST_INDEX_CURR_ROW
    JSR DRAWLOOP

    LDA #$24
    STA PPUADDR
    LDA #$00
    STA PPUADDR
    
    LDA #$F
    STA LAST_INDEX_CURR_ROW
    JSR DRAWLOOP
    
    JMP loop
    
    DRAWLOOP:
        LDA OFFSET
        STA PPUDATA
        INC OFFSET
        CMP LAST_INDEX_CURR_ROW
        BNE DRAWLOOP
        CMP #$FF
        BEQ END_DRAW_LOOP
        
        LDA #0
        STA I
        
        LDA LAST_INDEX_CURR_ROW
        ADC #$10
        STA LAST_INDEX_CURR_ROW
        SPACING:
            LDA #0
            STA PPUDATA
            INC I
            LDA I
            CMP #$10
            BEQ DRAWLOOP
            JMP SPACING
        END_DRAW_LOOP:
            RTS

loop:
    JMP loop

readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A 
    ROL buttons
    BCC joyloop
    RTS
   
nmi:
    PHA
    JSR readjoy
    PLA
    
    NMI_SCROLL:
    LDA SCROLL_X
    STA PPUSCROLL
    LDA #0
    STA PPUSCROLL
    
    LDA #3
    STA OAMADDR
    LDA SCROLL_X
    STA OAMDATA
    
    LDA #0
    STA OAMADDR
    LDA SCROLL_Y
    STA OAMDATA
    

    NMI_CHECK_DIRECTION:
        LDA buttons
        CMP #%00000001
        BEQ SCROLL_RIGHT
        CMP #%00000010
        BEQ SCROLL_LEFT
        CMP #%00000100
        BEQ SCROLL_UP
        CMP #%00001000
        BEQ SCROLL_DOWN
    NMI_END:
    RTI
    

SCROLL_UP:
    LDA SCROLL_Y
    CMP #$E7
    BEQ NMI_END
    INC SCROLL_Y
    RTI
SCROLL_DOWN:
    LDA SCROLL_Y
    CMP #0
    BEQ NMI_END
    DEC SCROLL_Y
    RTI
SCROLL_LEFT:
    LDA SCROLL_X
    CMP #0
    BEQ NMI_END
    DEC SCROLL_X
    RTI
SCROLL_RIGHT:
    LDA SCROLL_X
    CMP #$F7
    BEQ NMI_END
    INC SCROLL_X
    RTI


irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin mario0.chr
.incbin aiv256.chr