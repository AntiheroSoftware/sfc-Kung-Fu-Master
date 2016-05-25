;
; Kung Fu Master her control
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "snes-sprite.inc"

            .export 	initHeroSprite

            .export 	setHeroOAM
            .export 	animHero
            .export 	animHeroEvent

            .export 	animFrameIndex
            .export		animationFrameCounter

            .export 	heroWalk
            .export 	heroWalk1
            .export 	heroWalk2
            .export 	heroWalk3
            .export 	heroWalk4
            .export 	transferHeroSpriteData
            .export 	KFM_Player_final_Tiles
            .export 	spriteCounter


SPRITE_DATA_BANK = $02

SPRITE_VRAM = $2000
SPRITE_LINE_SIZE = $0400

.segment "BANK2"

KFM_Player_final_Tiles:
	.incbin "../ressource/KFM_Player_final_sprite.pic"

KFM_Player_final_Pal:
	.incbin "../ressource/KFM_Player_final_sprite.clr"

;******************************************************************************
;*** Hero Sprite definition ***************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Adress in bank for tiles                                               ***
;*** Number of horizontal tiles                                             ***
;*** Y offset of the line                                                   ***
;*** X offset                                                               ***
;*** Tile Number                                                            ***
;******************************************************************************

heroStand:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles)
	.byte   $01, $80, $00, $00
	.byte   $02, $90, $00, $02, $0f, $04
	.byte   $02, $a0, $00, $06, $0f, $08
	.byte   $02, $b0, $00, $0a, $0f, $0c
	.byte	$00

heroWalk1: 							; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*1))
	.byte   $01, $80, $00, $00
	.byte   $02, $90, $00, $02, $0f, $04
	.byte   $01, $a0, $00, $06
	.byte   $02, $b0, $00, $08, $0f, $0a
	.byte	$00

heroWalk2:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*2))
	.byte   $01, $80, $00, $00
	.byte   $01, $90, $00, $02
	.byte   $01, $a0, $00, $04
	.byte   $01, $b0, $00, $06
	.byte	$00

heroWalk3:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*3))
	.byte   $01, $80, $00, $00
	.byte   $02, $90, $00, $02, $0f, $04
	.byte   $02, $a0, $00, $06, $0f, $08
	.byte   $02, $b0, $00, $0a, $0f, $0c
	.byte	$00

heroWalk4:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*4))
	.byte   $01, $80, $00, $00
	.byte   $01, $90, $00, $02
	.byte   $01, $a0, $00, $04
	.byte   $01, $b0, $00, $06
	.byte	$00

;******************************************************************************
;*** Animation frames *********************************************************
;******************************************************************************
;*** number of frames                                                       ***
;*** metasprite definition address                                          ***
;******************************************************************************

heroWalk:
	.byte $08
	.word .LOWORD(heroWalk1)
	.byte $08
	.word .LOWORD(heroWalk2)
	.byte $08
	.word .LOWORD(heroWalk3)
	.byte $08
	.word .LOWORD(heroWalk4)
	.byte $00

.segment "BSS"

spriteCounter:
	.res 1

animFrameIndex:
	.res 1

animationFrameCounter:
	.res 1

.segment "CODE"

.A8
.I16

.proc initHeroSprite
	php
	phb

	lda #SPRITE_DATA_BANK			; change data bank to sprite data bank
	pha
	plb

	ldx heroStand
	jsr transferHeroSpriteData

	CGRAMLoad KFM_Player_final_Pal, $80, $20

	ldx #.LOWORD(heroStand+2)
	ldy #$0040
	jsr setHeroOAM

	lda #$01
	sta $2101                       ; set sprite address

	jsr copyOAM

	lda #$00
	sta animFrameIndex
	sta animationFrameCounter

	plb								; restore data bank
	plp
	rts
.endproc

;******************************************************************************
;*** Transfer sprite data in VRAM *********************************************
;******************************************************************************
;*** X contains the address of src                                          ***
;******************************************************************************

.proc transferHeroSpriteData
	php
	phx

	rep #$10
	sep #$20
	.A8
	.I16

	setVMAINC $80
	setVMADD SPRITE_VRAM
	setDMAParam $01
	setDMABBus $18

	lda #SPRITE_DATA_BANK
	sta DMA_ABUS0B
	pla
	sta DMA_ABUS0L
	pla
	sta DMA_ABUS0H

	lda	#<SPRITE_LINE_SIZE
	sta	DMA_SIZE0L
	lda	#>SPRITE_LINE_SIZE
	sta DMA_SIZE0H

	startDMA $01

	plp
	rts
.endproc

;******************************************************************************
;*** setOAM hero **************************************************************
;******************************************************************************
;*** dataAddr   (X register)                                                ***
;*** xPos       (Y register)                                                ***
;******************************************************************************

.proc setHeroOAM
    php								; TODO change order and php last
    phy								; save xPos in the stack
    phx								; save dataAddr in the stack

    ldy #$0000						; index in metaprite table
    ldx #$0000						; OAM offset

    lda #$00
	sta spriteCounter

lineLoop:							; loop for each line
    lda ($01,s),y					; load number block for this line
    cmp #$00
    beq endLineLoop					; if no block it's the end
    pha								; save it to the stack

    iny								; load Y Pos for that line
    lda ($02,s),y					; save it to the stack
	pha

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

	iny
	lda ($03,s),y
	sta oamData+2,x                 ; Tile number

	lda #%00110000
	sta oamData+3,x                 ; no flip full priority palette 0 (8 global palette)

	inx
	inx
	inx
	inx

	bra blockLoop

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
	lda #%10101010
	sta oamData + $200
	sta oamData + $201

    plx
	ply
    plp
    rts
.endproc

;******************************************************************************
;*** anim hero **************************************************************
;******************************************************************************
;*** dataAddr   (X register)                                                ***
;*** xPos       (Y register)                                                ***
;******************************************************************************

.proc animHero

    pha
    phx
    phy
    php

    rep #$10
	sep #$20
	.A8
	.I16

    phb
	lda #SPRITE_DATA_BANK			; change data bank to sprite data bank
	pha
	plb

	rep #$20
	.A16

	ldx #$0000
	txa

	rep #$10
	sep #$20
	.A8
	.I16

    lda animFrameIndex
    tay
    lda animationFrameCounter
    cmp heroWalk,y              	; we did all frames for that index
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
    lda heroWalk,y
    cmp #$00
    bne noLoop

    lda #$00
    sta animFrameIndex

noLoop:

    lda animFrameIndex
	tay
	iny
	ldx heroWalk,y
	phx								; contains adress of tiles
	inx
	inx								; increment to go to tile definition
	ldy #$0060
	jsr setHeroOAM					; todo check why A is modified when returning

	rep #$20
	.A16

	ldy #$0000
	lda ($01,s),Y					; fucking load in in bad data bank
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	jsr transferHeroSpriteData		; TODO fix X adresses currently bullshit

	plx

endAnim:

	plb
    plp
    ply
    plx
    pla

    rts

.endproc

.proc animHeroEvent
	php

	jsr animHero

	lda #$01                        ; continue event value
	plp
	rtl
.endproc
