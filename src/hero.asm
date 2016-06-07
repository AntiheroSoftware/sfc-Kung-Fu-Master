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
            .export 	transferHeroSpriteDataEvent
			.export 	reactHero

SPRITE_DATA_BANK 	= $02
SPRITE_VRAM 		= $2000
SPRITE_LINE_SIZE 	= $0400

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
;*** X offset Mirror                                                        ***
;*** Tile Number                                                            ***
;******************************************************************************

heroStand1:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles)
	.byte   $01, $00, $0c, $1b, $00
	.byte   $02, $10, $0c, $1b, $02, $1b, $0c, $04
	.byte   $02, $20, $0c, $1b, $06, $1b, $0c, $08
	.byte   $02, $30, $0c, $1b, $0a, $1b, $0c, $0c
	.byte	$00

heroWalk1: 							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*1))
	.byte   $01, $00, $11, $05, $00
	.byte   $02, $10, $01, $15, $02, $10, $05, $04
	.byte   $02, $20, $03, $13, $06, $13, $03, $08
	.byte   $02, $30, $03, $13, $0a, $13, $03, $0c
	.byte	$00

heroWalk2:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*2))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroWalk3:							; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*3))
	.byte   $01, $00, $10, $06, $00
	.byte   $02, $10, $00, $16, $02, $0f, $06, $04
	.byte   $02, $20, $00, $16, $06, $0f, $06, $08
	.byte   $02, $30, $00, $16, $0a, $0f, $06, $0c
	.byte	$00

heroWalk4:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*4))
	.byte   $01, $00, $0b, $0c, $00
	.byte   $01, $10, $0b, $0c, $02
	.byte   $01, $20, $0b, $0c, $04
	.byte   $01, $30, $0b, $0c, $06
	.byte	$00

heroDownStand1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*5))
	.byte   $01, $10, $00, $00, $00
	.byte   $01, $20, $00, $00, $02
	.byte   $02, $30, $00, $0f, $04, $0f, $00, $06
	.byte	$00

heroDownKick1:						; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*6))
	.byte   $01, $10, $00, $00, $00
	.byte   $02, $20, $00, $0f, $02, $0f, $00, $04
	.byte   $02, $30, $00, $0f, $06, $0f, $00, $08
	.byte	$00

heroDownKick2:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*7))
	.byte   $01, $10, $00, $00, $00
	.byte   $02, $20, $00, $0f, $02, $0f, $00, $04
	.byte   $04, $30, $00, $0f, $06, $0f, $00, $08, $1e, $0f, $0a, $2d, $00, $0c
	.byte	$00

heroDownPunch1:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*8))
	.byte   $02, $10, $00, $00, $00, $0f, $00, $02
	.byte   $02, $20, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $30, $00, $0f, $08, $0f, $00, $0a
	.byte	$00

heroDownPunch2:						; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*9))
	.byte   $01, $10, $00, $00, $00
	.byte   $02, $20, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $30, $00, $0f, $08, $0f, $00, $0a
	.byte	$00

heroDownPunch3:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*10))
	.byte   $02, $10, $00, $00, $00, $0f, $00, $02
	.byte   $02, $20, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $30, $00, $0f, $08, $0f, $00, $0a
	.byte	$00

heroStandKick1:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*11))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $20, $00, $0f, $08, $0f, $00, $0a
	.byte   $01, $30, $00, $0f, $0c
	.byte	$00

heroStandKick2:						; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*12))
	.byte   $02, $00, $00, $0f, $00, $1e, $00, $02
	.byte   $03, $10, $00, $1e, $04, $0f, $0f, $06, $1e, $00, $0a
	.byte   $01, $20, $00, $0f, $08
	.byte   $01, $30, $00, $0f, $0c
	.byte	$00

heroStandPunch1:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*13))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $01, $30, $00, $0f, $08
	.byte   $02, $20, $00, $0f, $0a, $0f, $00, $0c
	.byte	$00

heroStandPunch2:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*14))
	.byte   $01, $00, $00, $0f, $00
	.byte   $01, $10, $00, $0f, $04
	.byte   $01, $30, $00, $0f, $08
	.byte   $02, $20, $00, $0f, $0a, $0f, $00, $0c
	.byte	$00

heroStandPunch3:					; 7 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*15))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $01, $20, $00, $0f, $08
	.byte   $02, $30, $00, $0f, $0a, $0f, $00, $0c
	.byte	$00

heroJump1:							; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*16))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroJump2:							; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*17))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte   $01, $40, $09, $0d, $08
	.byte	$00

heroJumpKick1:						; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*18))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $20, $00, $0f, $08, $0f, $00, $0a
	.byte   $01, $30, $00, $0f, $0c
	.byte   $01, $40, $00, $0f, $0e
	.byte	$00

heroJump3:							; 5 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*19))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte   $01, $40, $09, $0d, $08
	.byte	$00

heroJumpRun1:						; 6 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*20))
	.byte   $01, $00, $00, $00, $00
	.byte   $02, $10, $00, $0f, $02, $0f, $00, $04
	.byte   $02, $20, $00, $0f, $06, $0f, $00, $08
	.byte   $01, $40, $00, $00, $0c
	.byte	$00

heroJumpRun2:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*21))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroHitLow1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*22))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroHitHigh1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*23))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroGrabbed1:						; 4 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*24))
	.byte   $01, $00, $0a, $0c, $00
	.byte   $01, $10, $09, $0d, $02
	.byte   $01, $20, $09, $0d, $04
	.byte   $01, $30, $09, $0d, $06
	.byte	$00

heroFall1:							; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*25))
	.byte   $02, $00, $00, $0f, $00, $0f, $00, $02
	.byte   $02, $10, $00, $0f, $04, $0f, $00, $06
	.byte   $02, $20, $00, $0f, $08, $0f, $00, $0a
	.byte   $02, $30, $00, $0f, $0c, $0f, $00, $0e

heroFall2:							; 8 sprite blocks
	.word	.LOWORD(KFM_Player_final_Tiles+($400*26))
	.byte   $02, $00, $00, $0f, $00, $1e, $00, $02
	.byte   $03, $10, $00, $1e, $04, $0f, $0f, $06, $1e, $00, $0a
	.byte   $03, $20, $00, $1e, $0c, $0f, $0f, $0e, $1e, $00, $10
	.byte	$00

;******************************************************************************
;*** Animation frames *********************************************************
;******************************************************************************
;*** number of frames                                                       ***
;*** metasprite definition address                                          ***
;******************************************************************************

heroStand:
	.byte $00
	.word .LOWORD(heroStand1)
	.byte $00

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

heroDownStand:
	.byte $00
	.word .LOWORD(heroDownStand1)

heroDownKick:
	.byte $08
	.word .LOWORD(heroDownKick1)
	.byte $08
	.word .LOWORD(heroDownKick2)
	.byte $08
	.word .LOWORD(heroDownKick1)
	.byte $00

heroDownPunch:
	.byte $08
	.word .LOWORD(heroDownPunch1)
	.byte $08
	.word .LOWORD(heroDownPunch2)
	.byte $08
	.word .LOWORD(heroDownPunch3)
	.byte $08
	.word .LOWORD(heroDownPunch2)
	.byte $00

heroStandKick:
	.byte $08
	.word .LOWORD(heroStandKick1)
	.byte $08
	.word .LOWORD(heroStandKick2)
	.byte $08
	.word .LOWORD(heroStandKick1)
	.byte $00

heroStandPunch:
	.byte $08
	.word .LOWORD(heroStandPunch1)
	.byte $08
	.word .LOWORD(heroStandPunch2)
	.byte $08
	.word .LOWORD(heroStandPunch3)
	.byte $08
	.word .LOWORD(heroStandPunch2)
	.byte $00

.segment "BSS"

spriteCounter:
	.res 1

animFrameIndex:
	.res 1

animationFrameCounter:
	.res 1

heroTransferAddr:
	.res 2

heroBlockLoop:
	.res 2

.segment "ZEROPAGE"

animAddr:
	.res 2

heroYOffset:
	.res 1

heroXOffset:
	.res 2

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** initHeroSprite ***********************************************************
;******************************************************************************
;*** init various stuff                                                     ***
;******************************************************************************

.proc initHeroSprite
	php
	phb

	lda #SPRITE_DATA_BANK			; change data bank to sprite data bank
	pha
	plb

	; init various variable
	lda #$00
	sta animFrameIndex
	sta animationFrameCounter

	lda #$78
	sta heroYOffset

	lda #$70
	sta heroXOffset

	ldx #$0000
	stx heroTransferAddr

	ldx heroStand1
	jsr transferHeroSpriteData

	; load hero sprite palette
	CGRAMLoad KFM_Player_final_Pal, $80, $20

	jsr setNormalSpriteMode

	;ldx #.LOWORD(heroStand1+2)
	;ldy #$0040
	;jsr setHeroOAM

	lda #$01
	sta $2101                       ; set sprite address

	;jsr copyOAM

	ldx #.LOWORD(heroStand)
	stx animAddr

	jsr animHero

	plb								; restore data bank
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
    bne continueLineLoop			; if no block it's the end
	jmp endLineLoop
continueLineLoop:
    pha								; save it to the stack

    iny								; load Y Pos for that line
    lda ($02,s),y					; save it to the stack
    adc heroYOffset
	pha

	jmp (heroBlockLoop)				; jmp to correct blockLoop code (mirror/normal)

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

	lda #%00110000
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

	lda #%01110000
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
    cmp (animAddr),y              	; we did all frames for that index
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
    lda (animAddr),y
    cmp #$00
    bne noLoop

    lda #$00
    sta animFrameIndex

noLoop:

    lda animFrameIndex
	tay
	iny

	rep #$20
	.A16

	lda (animAddr),y
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	phx								; contains adress of tiles
	inx
	inx								; increment to go to tile definition
	ldy heroXOffset					; x Pos
	jsr setHeroOAM					; todo check why A is modified when returning

	jsr OAMDataUpdated

	rep #$20
	.A16

	ldy #$0000
	lda ($01,s),y
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	stx heroTransferAddr			; store address to transfer hero tiles (we do it during VBlank)

	plx

endAnim:

	plb
    plp
    ply
    plx
    pla

    rts

.endproc

;*******************************************************************************
;*** transferHeroSpriteDataEvent ***********************************************
;*******************************************************************************
;*** Event that trigger the DMA transfer of sprite tile data                 ***
;*******************************************************************************

.proc transferHeroSpriteDataEvent
	php

	ldx heroTransferAddr			; check if we have an address
	beq noTransfer					; if address is #$0000 we skip transfer

	jsr transferHeroSpriteData

	ldx #$0000						; reset address if we transfered something
	stx heroTransferAddr

noTransfer:

	lda #$01                        ; continue event value
	plp
	rtl
.endproc

;******************************************************************************
;*** Transfer sprite data in VRAM *********************************************
;******************************************************************************
;*** X contains the address of src                                          ***
;******************************************************************************

.proc transferHeroSpriteData
	php

	ldx heroTransferAddr
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

;*******************************************************************************
;*** setMirrorSpriteMode *******************************************************
;*******************************************************************************
;*** set hero sprite in mirror mode (face left)                              ***
;*******************************************************************************

.proc setMirrorSpriteMode
	phx
	ldx #setHeroOAM::blockLoopMirror
	stx heroBlockLoop
	ply
	rts
.endproc

;*******************************************************************************
;*** setNormalSpriteMode *******************************************************
;*******************************************************************************
;*** set hero sprite in normal mode (face right)                             ***
;*******************************************************************************

.proc setNormalSpriteMode
	phx
	ldx #setHeroOAM::blockLoop
	stx heroBlockLoop
	ply
	rts
.endproc

;*******************************************************************************
;*** reactHero *****************************************************************
;*******************************************************************************
;*** X contains pad like data                                                ***
;*******************************************************************************

.proc reactHero
	phy
	pha
	phb

	txa
checkPadLeft:
	lda padPushData1
	bit #PAD_LEFT
	beq checkPadRight
	jsr setMirrorSpriteMode
	bra checkPadEnd
checkPadRight:
	lda padPushData1
	bit #PAD_RIGHT
	beq checkPadEnd
	jsr setNormalSpriteMode
checkPadEnd:

;***********************************************
; TODO remove later, only for debugging purpose
;***********************************************
;	lda padReleaseData1
;	bit #PAD_UP
;	beq testNext
;	inc animationFrameCounter
;testNext:
;	lda padReleaseData1
;	bit #PAD_DOWN
;	beq testEnd
;	dec animationFrameCounter
;testEnd:

	jsr animHero

	plb
	pla
	ply
	rts
.endproc
