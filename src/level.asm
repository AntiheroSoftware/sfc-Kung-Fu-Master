;
; Kung Fu Master level control
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"

            .include	"includes/base.inc"
            .include	"includes/score.inc"
            ;.include	"includes/scoreDefine.inc"

            .export		initLevel
            .export 	scrollInitEvent
            .export		scrollLevel
            .export 	scrollValue
            .export		scrollDirection
            .export 	levelLeftEdgeVisible
            .export 	levelRightEdgeVisible

            .export VRAMLineLeft
            .export VRAMLineRight

.include "includes/levelData.asm"

.segment "CODE"

.A8
.I16

.proc initLevel

	pha
	phx
	phy
	php

	sep #$20
	.A8

    setBG1SC LEVEL_MAP_ADDR, $01
	setBG2SC SCORE_MAP_ADDR, $00
	setBG12NBA LEVEL_TILE_ADDR, SCORE_TILE_ADDR

    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $22E0                 ; load tiles
    VRAMLoad levelTiles, LEVEL_TILE_ADDR, $0027                 ; load tiles
    CGRAMLoad levelPal, $00, $C0                                ; load 5 palettes

	ldx #$001f
	ldy #.LOWORD(levelMapInitial)

loop:
	jsr displayLevelLine

	cpx #$003f
	beq stopLoop

	rep #$20
	.A16

	inx
	tya
	clc
	adc #$0038
	tay

	sep #$20
	.A8

	bra loop

stopLoop:

	sep #$20
	.A8

    lda #$01                        ; set BG mode 1
    sta $2105

    lda #$13                        ; Plane 0 (bit one) + Plane 1 (bit 2) + Sprite enable register
	sta $212c

	; 4 pixel scroll down for score BG
	lda #$fb
	sta $2110
	stz $2110

    lda #$00                        ; All subPlane disable
    sta $212d

    jsr scrollInitEvent

    lda #.BANKBYTE(scrollEvent)
    ldx #.LOWORD(scrollEvent)
    ldy #EVENT_GAME_SCREEN_LEVEL
    jsr addEvent

    plp
    ply
    plx
    pla
    rts

.endproc

;*******************************************************************************
;*** scrollLevel ***************************************************************
;*******************************************************************************
;*** Scroll level plane 1 pixel left or right                                ***
;*******************************************************************************

.proc scrollLevel

	pha
	phx
	phy
	php

	stz levelLeftEdgeVisible					; reset edge visibility variable
	stz levelRightEdgeVisible

	ldx scrollValue
	cpx #$fb00						; check scroll left boundaries
    bne :+
    inc levelLeftEdgeVisible
:	cpx #$0100						; check scroll right boundaries
	bne :+
	inc levelRightEdgeVisible
:
	lda scrollDirection
	cmp #LEVEL_SCROLL_RIGHT
	beq scrollRight
	cmp #LEVEL_SCROLL_LEFT
	beq scrollLeft

	jmp noScroll

scrollLeft:

	cpx #$fb00						; check scroll left boundaries
	beq :+							; exit scroll level routine

	dex 			                ; decrement scrollValue
	stx scrollValue
	txa
	and #%00000111
	cmp #%00000000
	bne scrollValueSet

	lda #$01
	sta doUpdate

	lda VRAMLineLeft
	dec
	and #$3f
	sta VRAMLineLeft
	sta VRAMLine
	dec VRAMLineRight

	rep #$20
	.A16

	lda MAPOffsetLeft
	sec
	sbc #$38
	sta MAPOffsetLeft
	sta MAPOffset

	lda MAPOffsetRight
	sec
	sbc #$38
	sta MAPOffsetRight

	bra scrollValueSet

	sep #$20
	.A8

:	bra scrollValueSet

scrollRight:

	cpx #$0100						; check scroll right boundaries
	beq scrollValueSet

	inx  			                ; increment scrollValue
	stx scrollValue
	txa
	and #%00000111
	cmp #%00000001
	bne scrollValueSet

	lda #$01
	sta doUpdate

	lda VRAMLineRight
	inc
	and #$3f
	sta VRAMLineRight
	sta VRAMLine
	inc VRAMLineLeft

	rep #$20
	.A16

	lda MAPOffsetRight
	clc
	adc #$38
	sta MAPOffsetRight
	sta MAPOffset

	lda MAPOffsetLeft
	clc
	adc #$38
	sta MAPOffsetLeft

	bra scrollValueSet

scrollValueSet:

	sep #$20
	.A8

noScroll:

	plp
	ply
	plx
	pla
	rts

.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.segment "BSS"

VRAMLine:
	.res 2

VRAMLineLeft:
	.res 2

VRAMLineRight:
	.res 2

MAPOffset:
	.res 2

MAPOffsetLeft:
	.res 2

MAPOffsetRight:
	.res 2

scrollValue:
    .res    2

scrollDirection:
    .res    1

doUpdate:
	.res 1

levelRightEdgeVisible:
	.res 1

levelLeftEdgeVisible:
	.res 1

.segment "RODATA"

VRAMOffset:
	.word $1800, $1801, $1802, $1803, $1804, $1805, $1806, $1807
	.word $1808, $1809, $180a, $180b, $180c, $180d, $180e, $180f
	.word $1810, $1811, $1812, $1813, $1814, $1815, $1816, $1817
	.word $1818, $1819, $181a, $181b, $181c, $181d, $181e, $181f
	.word $1c00, $1c01, $1c02, $1c03, $1c04, $1c05, $1c06, $1c07
	.word $1c08, $1c09, $1c0a, $1c0b, $1c0c, $1c0d, $1c0e, $1c0f
	.word $1c10, $1c11, $1c12, $1c13, $1c14, $1c15, $1c16, $1c17
	.word $1c18, $1c19, $1c1a, $1c1b, $1c1c, $1c1d, $1c1e, $1c1f
	.word $1800

.segment "CODE"

.proc scrollInitEvent
    pha
    phx
    php

    lda #$ff                        ; init Y scroll
    sta $210e
    stz $210e

    ldx #$001f
    stx VRAMLine
    stx VRAMLineLeft
    ldx #$0000
    stx VRAMLineRight

	ldx #.LOWORD(levelMapInitial)
	stx MAPOffset
	stx MAPOffsetLeft
	ldx #.LOWORD(levelMapInitialEnd)
	stx MAPOffsetRight

	ldx #$0100                      ; init scrollValue
	stx scrollValue

    lda #LEVEL_SCROLL_NONE         	; init scrollDirection (init with NONE)
    sta scrollDirection
    jsr scrollLevel

    lda #$01
    sta doUpdate

    plp
    plx
    pla
    rts
.endproc

;*******************************************************************************
;*** scrollEvent ***************************************************************
;*******************************************************************************
;*** Set scroll offset and DMA new data if needed                           ***
;*******************************************************************************

.proc scrollEvent

    phx
    phy
    php

    tax                             ; put A reg containing counter in X reg

    rep #$10
    sep #$20
    .A8
    .I16

    lda doUpdate
    cmp #$00
    beq noDMA

    ldx VRAMLine
	ldy MAPOffset
	jsr displayLevelLine

	lda #$00
	sta doUpdate

noDMA:
    lda scrollValue
    sta $210d
    lda scrollValue+1
    sta $210d

    lda #$01                        ; continue event value

    plp
    ply
    plx

    rtl
.endproc

;*******************************************************************************
;*** displayLevelLine **********************************************************
;*******************************************************************************
;*** X contains VRAM address to update                                        ***
;*** Y contains MAP offset                                                   ***
;*******************************************************************************

.proc displayLevelLine
	pha
	phx
	phy
	php

	rep #$20
	.A16

	txa
	asl
	tax

	sep #$20
	.A8

	lda #$81
	sta PPU_VMAINC

	phy
	ldy VRAMOffset,x

	sty PPU_VMADDL
	ply

	lda #$01
	sta DMA_PARAM0

	lda #$18
	sta DMA_BBUS0

	sty DMA_ABUS0L

	lda #LEVEL_BANK
	sta DMA_ABUS0B

	lda	#$38						; size of transfer is #$38
	sta	DMA_SIZE0L
	lda	#$00
	sta DMA_SIZE0H

	lda	#%00000001					; enable DMA 0
	sta	CPU_MDMAEN

	plp
	ply
	plx
	pla
	rts
.endproc