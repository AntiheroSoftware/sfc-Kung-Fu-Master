;
; Kung Fu Master font write
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
			.include	"includes/fontData.inc"


.segment "BSS"

cursorPos:
    .res    2

paletteNumber:
	.res 	1

fontMapPtr:
    .res    2

; TODO remove this and ref
debugMap:
	.res	2

.segment "CODE"

;******************************************************************************
;*** initFont *****************************************************************
;******************************************************************************
;*** A contains palette to use                                              ***
;*** X contains pointer to VRAM                                             ***
;******************************************************************************

.proc initFont
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

    stx fontMapPtr

    ldx #$0000
    stx cursorPos

    plp
    plx

    rts
.endproc

;******************************************************************************
;*** setFontCursorPosition ****************************************************
;******************************************************************************
;*** X contains X pos                                                       ***
;*** Y contains Y pos                                                       ***
;******************************************************************************

.proc setFontCursorPosition
    pha
    php

    rep #$30
    .A16
    .I16

    txa
    asl a
loopY:
    cpy #$00
    beq endY
    clc
    adc #$0040
    dey
    bra loopY
endY:
    sta cursorPos

    plp
    pla
    rts
.endproc

;******************************************************************************
;*** setFontCursorPositionNewLine *********************************************
;******************************************************************************
;*** No parameters                                                          ***
;******************************************************************************

.proc setFontCursorPositionNewLine
    pha
    php

    rep #$30
    .A16
    .I16

    lda cursorPos
    and #$FFC0      ; check for the right mask value
    adc #$40        ; check for the right add value
    sta cursorPos

    plp
    pla
    rts
.endproc

;******************************************************************************
;*** writeFontString **********************************************************
;******************************************************************************
;*** A (16 bit) contains string ptr                                         ***
;******************************************************************************

.proc writeFontString
    phx
    phy
    pha             ; save A
    php

    rep #$10        ; A -> 8 bit
    sep #$20        ; X, Y -> 16 bit
    .A8
    .I16

    ldx cursorPos   ; set X to cursorPos value
    ldy #$0000      ; set Y index to 0

loop:
    lda (2,s),y     ; load buffer into [Stack Indirect Indexed,Y]
    cmp #$00        ; check if value is 0 -> stop
    beq stop

    cmp #$0A        ; if value is \n adapt X to simulate new line and branch to loop
    bne notEndOfLine

endOfLine:
    stx cursorPos   ; store cursorPos in memory
    jsr setFontCursorPositionNewLine
    ldx cursorPos   ; reload updated cursorPos

notEndOfLine:

    cmp     #$61    ; toUpper A
    bcc     toUpperEnd
    cmp     #$7B
    bcs     toUpperEnd
    sbc     #$20
toUpperEnd:

    sbc #$1F        ; remove $20 from A
    sta debugMap,x  ; set A in debugMap with X index
    iny             ; increment Y
    inx             ; increment X by 2
    inx
    bra loop

stop:
    stx cursorPos   ; store cursorPos in memory

    plp             ; restore processor status from stack
    pla             ; get A from stack
    ply
    plx

    rts
.endproc