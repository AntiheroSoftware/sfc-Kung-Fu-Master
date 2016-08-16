;
; Kung Fu Master ennemies control
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "snes-sprite.inc"

            .import 	spriteCounter

            .export 	initEnnemySprite

            .export setEnemyOAM
            .export ennemySprites

.include "includes/ennemyData.asm"

SPRITE_TILE_ZONE1_ADDR	= $3000
SPRITE_TILE_ZONE2_ADDR	= $4000
SPRITE_TILE_ZONE3_ADDR	= $5000
SPRITE_TILE_ZONE4_ADDR	= $6000

ENNEMY_SPRITE_NUMBER = 14

.struct ennemySprite
	AnimAddress 			.word
	AnimFrameIndex			.byte
	AnimFramecounter		.byte
	AnimJumpFramecounter	.byte
	XOffset					.word
	OAMSlot					.byte
	Flag					.byte
.endstruct

.segment "BSS"

ennemySprites:
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite
	.tag ennemySprite

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** initEnnemySprite ***********************************************************
;******************************************************************************
;*** init various stuff                                                     ***
;******************************************************************************

.proc initEnnemySprite
	php
	phb

	; load ennemy sprite palette
	CGRAMLoad ennemySpritePal, $90, $20

	VRAMLoad ennemySpriteBank1Tiles, SPRITE_TILE_ZONE1_ADDR, $2000
	VRAMLoad ennemySpriteBank2Tiles, SPRITE_TILE_ZONE2_ADDR, $2000
	VRAMLoad ennemySpriteBank3Tiles, SPRITE_TILE_ZONE3_ADDR, $2000
	VRAMLoad ennemySpriteBank4Tiles, SPRITE_TILE_ZONE4_ADDR, $2000

	lda #$08
	ldx #grabbingWalk1
	ldy #$0050
	jsr setEnemyOAM

	lda #$10
	ldx #grabbingWalk1
	ldy #$0030
	jsr setEnemyOAM

	lda #$18
	ldx #grabbingWalk1
	ldy #$0010
	jsr setEnemyOAM

	jsr hdmaInit

	plb
	plp
	rts
.endproc

;******************************************************************************
;*** hdmaInit *****************************************************************
;******************************************************************************
;*** TODO explain trick *******************************************************
;******************************************************************************

.proc hdmaInit
    pha
    phx
    php

    lda #$00                        ; 1 byte value hdma (count,byte)
    sta $4360
    lda #$01                        ; sprite N select
    sta $4361
    ldx #hdmaMem
    stx $4362
    lda #.BANKBYTE(hdmaMem)
    sta $4364
    lda #%01000000
    sta $420c                       ; enable hdma channel 0

    plp
    plx
    pla

    rts
.endproc

;******************************************************************************
;*** setOam ennemies with hdma trick ******************************************
;******************************************************************************
;*** offsetOAM  (A register)                                                ***
;*** dataAddr   (X register)                                                ***
;*** xPos       (Y register)                                                ***
;******************************************************************************

.proc setEnemyOAM
    php								; TODO change order and php last
    phy								; save xPos in the stack
    phx								; save dataAddr in the stack

    ldy #$0000						; index in metaprite table

    rep #$20
	.A16

	and #$00ff
	asl
	asl
	tax								; set OAM offset table

	rep #$10
	sep #$20
	.A8
	.I16

    lda #$00
	sta spriteCounter

lineLoop:							; loop for each line
    lda ($01,s),y					; load number block for this line
    cmp #$00
    bne continueLineLoop			; if no block it's the end
	jmp endLineLoop
continueLineLoop:
    pha								; save it to the stack

    iny								; load Y Pos for that line
    lda ($02,s),y					; save it to the stack
    clc
    ;adc heroYOffset				; TODO make a global for enemy Y offset
    adc #$78
	pha

	;jmp (heroBlockLoop)			; jmp to correct blockLoop code (mirror/normal)
	jmp blockLoop					; jmp to correct blockLoop code (mirror/normal)

blockLoop:
	lda $02,s						; load blockNumber
	cmp #$00
	beq endBlockLoop				; check all block are done
	dec
	sta $02,s						; update counter

	inc	spriteCounter

	iny
	lda ($03,s),y					; load X pos for that
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	lda $01,s
	sta oamData+1,x                 ; V (Y) pos of the sprite

	iny								; skip mirror xOffset
	iny
	lda ($03,s),y
	sta oamData+2,x                 ; Tile number

	lda #%00110011					; TODO rectify this
	sta oamData+3,x                 ; no flip full priority palette 0 (8 global palette)

	inx
	inx
	inx
	inx

	bra blockLoop

blockLoopMirror:
	lda $02,s						; load blockNumber
	cmp #$00
	beq endBlockLoop				; check all block are done
	dec
	sta $02,s						; update counter

	inc	spriteCounter

	iny								; skip non mirror xOffset
	iny
	lda ($03,s),y					; load X pos for that
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	lda $01,s
	sta oamData+1,x                 ; V (Y) pos of the sprite

	iny
	lda ($03,s),y
	sta oamData+2,x                 ; Tile number

	lda #%01110011					; TODO rectify this
	sta oamData+3,x                 ; no flip full priority palette 0 (8 global palette)

	inx
	inx
	inx
	inx

	bra blockLoopMirror

endBlockLoop:

	iny
	pla
	pla

	bra lineLoop

endLineLoop:

fillLoop:
    lda spriteCounter
    cmp #$08
    beq endFillLoop

    lda #$e0
    sta oamData+1,x                 ; V (Y) pos of the sprite

    inx
    inx
    inx
    inx

    inc spriteCounter
    bra fillLoop

endFillLoop:

	; TODO handle that correctly in function (NOT HARD CODED)
	; TODO fix index for those
	lda #%10101010
	sta oamData + $202
	sta oamData + $203
	sta oamData + $204
	sta oamData + $205
	sta oamData + $206
	sta oamData + $207

    plx
	ply
    plp
    rts
.endproc

/*
.proc grabbingAnim

    pha
    phx
    phy
    php

    ldx #$0000
    txa

    lda animFrameIndex
    tay
    lda animationFrameCounter
    cmp grabbingWalk,y              ; we did all frames for that index
    beq nextFrame
    cmp #$00                        ; first time we do that animation
    beq nextFrame

    inc
    sta animationFrameCounter
    bra endAnim

nextFrame:

    lda #$01
    sta animationFrameCounter

    lda animFrameIndex
    inc
    inc
    inc
    sta animFrameIndex
    tay
    lda grabbingWalk,y
    cmp #$00
    bne noLoop

    lda #$00
    sta animFrameIndex

noLoop:

    ldx #$00
    stx functionArg1                ; OAM index

    lda animFrameIndex
    tay
    iny
    ldx grabbingWalk,y
    stx functionArg2                ; metasprite definition

    lda #$60
    sta functionArg3                ; xPos
    jsr setOam

endAnim:

    plp
    ply
    plx
    pla

    rts

.endproc
*/

