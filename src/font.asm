;
; Kung Fu Master font write
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
			.include	"includes/fontData.inc"

			.export 	initFont
			.export 	enableSkipSpaces
			.export 	disableSkipSpaces
			.export 	setFontCursorPosition
			.export 	writeFontString

			.export 	fontTiles

			;***********************
			;*** Palettes export ***
			;***********************

            .export 	letterGreyPal
            .export 	letterRedPal
            .export 	titleScreenWhitePal
            .export 	titleScreenYellowPal
            .export 	titleScreenWhiteRedPal
            .export 	gameMessagePal

			;***********************
			;*** Strings export ***
			;***********************

			.export 	letterIntroString
			.export 	titleScreenSelectString
            .export 	titleScreenCopyrightString
            .export 	readyString
            .export 	onePlayerFirstFloorString

            .export skipSpaces

.segment "BSS"

skipSpaces:
	.res 	1

baseCursorPosX:
	.res 	2

cursorPos:
    .res    2

fontMapHigh:
	.res 	1

fontMapPtr:
    .res    2

fontTileOffset:
	.res	1

.segment "CODE"

;******************************************************************************
;*** initFont *****************************************************************
;******************************************************************************
;*** A contains palette to use                                              ***
;*** X contains pointer to VRAM                                             ***
;*** Y contains font Tile Offset                                            ***
;******************************************************************************

.proc initFont
	pha
    phx
    php

    rep #$10
    sep #$20
    .A8
    .I16

	asl
    asl
    ora #%00100000
    sta fontMapHigh

    stx fontMapPtr

    sty fontTileOffset

    ldx #$0000
    stx cursorPos

    lda #$01
    sta skipSpaces

    plp
    plx
    pla

    rts
.endproc

;******************************************************************************
;*** enableSkipSpaces *********************************************************
;******************************************************************************
;*** No parameters        													***
;******************************************************************************

.proc enableSkipSpaces
	pha
	php

	rep #$10
	sep #$20
	.A8
	.I16

	lda #$01
	sta skipSpaces

	plp
	pla
	rts
.endproc

;******************************************************************************
;*** disableSkipSpaces *********************************************************
;******************************************************************************
;*** No parameters        													***
;******************************************************************************

.proc disableSkipSpaces
	pha
	php

	rep #$10
	sep #$20
	.A8
	.I16

	lda #$00
	sta skipSpaces

	plp
	pla
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
	stx baseCursorPosX
loopY:
    cpy #$00
    beq endY
    clc
    adc #$0020
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
    and #$FFE0      ; check for the right mask value
    clc
    adc #$20        ; check for the right add value
    adc baseCursorPosX
    sta cursorPos

    plp
    pla
    rts
.endproc

;******************************************************************************
;*** writeFontString **********************************************************
;******************************************************************************
;*** A (16 bit) contains string ptr                                         ***
;*** X Offset in tile data													***
;*** Y VRAM start adress to write											***
;******************************************************************************

.proc writeFontString
    phy
    pha             ; save A
    phx
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

    cmp #$08
    bcs checkEndOfLine

paletteChange:
	asl
	asl
	ora #%00100000
	sta fontMapHigh
	bra skip

checkEndOfLine:
    cmp #$0A        ; if value is \n adapt X to simulate new line and branch to loop
    bne notEndOfLine

endOfLine:
    stx cursorPos   ; store cursorPos in memory
    jsr setFontCursorPositionNewLine
    ldx cursorPos   ; reload updated cursorPos
    bra skip

notEndOfLine:

    cmp     #$61    ; toUpper A
    bcc     toUpperEnd
    cmp     #$7B
    bcs     toUpperEnd
    sbc     #$20
toUpperEnd:

    sbc #$1F        ; remove $20 from A

    cmp #$00		; skip space (might need to change)
	bne notSpace 	; or simply add a parameter to set

	lda skipSpaces
	cmp #$00
	bne next

notSpace:
	pha

	lda #$80
	sta $2115		; set incremental mode

	;*** calculate VRAM address

	rep #$30
	.A16
	.I16

	lda cursorPos
	clc
	adc fontMapPtr

	sta $2116

	rep #$10
    sep #$20
    .A8
    .I16

    pla
	clc
	adc fontTileOffset
    sta $2118

	lda fontMapHigh
	sta $2119

    iny             ; increment Y
	inx             ; increment X by 2
	stx	cursorPos

	bra loop

next:
	inx             ; increment X by 2
	stx	cursorPos

skip:
    iny             ; increment Y

    bra loop

stop:
    stx cursorPos   ; store cursorPos in memory

    plp             ; restore processor status from stack
    pla             ; get A from stack
    plx
    ply

    rts
.endproc