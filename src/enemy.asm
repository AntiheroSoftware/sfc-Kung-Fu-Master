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

            .export 	initEnemySprite
            .export 	reactEnemy
            .export 	hdmaInitTitle
            .export 	hdmaInitGame

            .export setEnemyOAM
            .export EnemyArrayAnimAddress
            .export EnemyArrayAnimFrameIndex
            .export EnemyArrayAnimFrameCounter
            .export EnemyArrayAnimJumpFramecounter
            .export EnemyArrayXOffset
            .export EnemyArrayOAMSlot
            .export EnemyArrayFlag
            .export addEnemy
            .export animEnemy
            .export grabbingWalk
            .export grabbingWalk1
            .export grabbingWalk2

.include "includes/enemyData.asm"

SPRITE_TILE_ZONE1_ADDR	= $3000
SPRITE_TILE_ZONE2_ADDR	= $4000
SPRITE_TILE_ZONE3_ADDR	= $5000
SPRITE_TILE_ZONE4_ADDR	= $6000

ENEMY_SPRITE_NUMBER = 14

.segment "ZEROPAGE"

EnemyCurrentAnimAddress:
	.res 2

EnemyCurrentXOffset:
	.res 2

.segment "BSS"

EnemyArrayAnimAddress:
 	.res 2 * ENEMY_SPRITE_NUMBER

EnemyArrayAnimFrameIndex:
	.res 1 * ENEMY_SPRITE_NUMBER

EnemyArrayAnimFrameCounter:
	.res 1 * ENEMY_SPRITE_NUMBER

EnemyArrayAnimJumpFramecounter:
	.res 1 * ENEMY_SPRITE_NUMBER

EnemyArrayXOffset:
	.res 2 * ENEMY_SPRITE_NUMBER

EnemyArrayOAMSlot:
	.res 1 * ENEMY_SPRITE_NUMBER

EnemyArrayFlag:
	.res 1 * ENEMY_SPRITE_NUMBER

.segment "CODE"

.A8
.I16

; TODO test with 14 enemies walking
; TODO implement mirroring of enemies depending on direction

;******************************************************************************
;*** initEnemySprite **********************************************************
;******************************************************************************
;*** init various stuff                                                     ***
;******************************************************************************

.proc initEnemySprite
	pha
	phx
	phy
	php
	phb

	; load enemy sprite palette
	CGRAMLoad enemySpritePal, $90, $20

	VRAMLoad enemySpriteBank1Tiles, SPRITE_TILE_ZONE1_ADDR, $2000
	VRAMLoad enemySpriteBank2Tiles, SPRITE_TILE_ZONE2_ADDR, $2000
	VRAMLoad enemySpriteBank3Tiles, SPRITE_TILE_ZONE3_ADDR, $2000
	VRAMLoad enemySpriteBank4Tiles, SPRITE_TILE_ZONE4_ADDR, $2000

	lda #$00
	ldx #$0000
	ldy #$0000

initArrayLoop:
	cpx #ENEMY_SPRITE_NUMBER
	beq endInitArrayLoop

    sta EnemyArrayAnimFrameIndex,X
    sta EnemyArrayAnimFrameCounter,X
    sta EnemyArrayAnimJumpFramecounter,X
    sta EnemyArrayOAMSlot,X
    sta EnemyArrayFlag,X

    sta EnemyArrayAnimAddress,Y
    sta EnemyArrayXOffset,Y
	iny
	sta EnemyArrayAnimAddress,Y
	sta EnemyArrayXOffset,Y

	inx
	iny
	bra initArrayLoop

endInitArrayLoop:

	lda #$00
	ldx #.LOWORD(grabbingWalk)
	jsr addEnemy

	plb
	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** addEnemy *****************************************************************
;******************************************************************************
;*** slot (A)																***
;*** animAddr (X)															***
;******************************************************************************

.proc addEnemy
	pha
	phx
	phy
	php

	txy								; keep anim address in Y

	rep #$20
	.A16

	and #$00ff
	tax								; put index of slot in X register
	phx								; save X (index slot)
	asl								; index slot * 2
	tax
	tya								; transfer saved anim adress in a

	sta EnemyArrayAnimAddress,X		; store anim address
	stz EnemyArrayXOffset,X			; reset X Offset

	plx								; get back index slot

	rep #$10
	sep #$20
	.A8
	.I16

	stz EnemyArrayAnimFrameIndex,X
	stz EnemyArrayAnimFrameCounter,X

	lda #$00
	ora #ENEMY_STATUS_ACTIVE_FLAG
	sta EnemyArrayFlag,X

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** hdmaInitTitle ************************************************************
;******************************************************************************
;*** TODO explain trick *******************************************************
;******************************************************************************

.proc hdmaInitTitle
    pha
    phx
    php

    lda #$00                        ; 1 byte value hdma (count,byte)
    sta $4360
    lda #$01                        ; sprite N select
    sta $4361
    ldx #hdmaMemTitle
    stx $4362
    lda #.BANKBYTE(hdmaMemTitle)
    sta $4364
    lda #%01000000
    sta $420c                       ; enable hdma channel 0

    plp
    plx
    pla

    rts
.endproc

;******************************************************************************
;*** hdmaInitGame *************************************************************
;******************************************************************************
;*** TODO explain trick *******************************************************
;******************************************************************************

.proc hdmaInitGame
    pha
    phx
    php

    lda #$00                        ; 1 byte value hdma (count,byte)
    sta $4360
    lda #$01                        ; sprite N select
    sta $4361
    ldx #hdmaMemGame
    stx $4362
    lda #.BANKBYTE(hdmaMemGame)
    sta $4364
    lda #%01000000
    sta $420c                       ; enable hdma channel 0

    plp
    plx
    pla

    rts
.endproc

;******************************************************************************
;*** setEnemyOAM ennemies with hdma trick *************************************
;******************************************************************************
;*** offsetOAM  (A register)                                                ***
;*** dataAddr   (X register)                                                ***
;*** xPos       (Y register)                                                ***
;******************************************************************************

.proc setEnemyOAM
    php
    phy								; save xPos in the stack
    phx								; save dataAddr in the stack

    ldy #$0000						; index in metaprite table

    rep #$20
	.A16

	and #$00ff
	asl								; TODO why do we need to * 4 ???
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

	; TODO check direction of enemy
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

;******************************************************************************
;*** animEnemy ****************************************************************
;******************************************************************************
;*** index of slot  (A register)                                            ***
;******************************************************************************

.proc animEnemy

    pha
    phx
    phy
    php

    rep #$20
	.A16

	and #$00ff
	tax								; save index of slot
	asl								; index of slot * 2
	tay
	lda EnemyArrayAnimAddress,Y
	sta EnemyCurrentAnimAddress		; set current anim address

	lda EnemyArrayXOffset,Y
	sta EnemyCurrentXOffset

	lda #$0000

	rep #$10
	sep #$20
	.A8
	.I16

	phb
	lda #ENEMY_DATA_BANK
	pha
	plb

    lda EnemyArrayAnimFrameIndex,X
    tay
    lda EnemyArrayAnimFrameCounter,X
    cmp #$00 						; first time we do that animation
    beq firstFrame

    dec
    cmp (EnemyCurrentAnimAddress),Y ; we did all frames for that index
    beq nextFrame

    inc EnemyArrayAnimFrameCounter,X
    bra noLoop						; TODO check if better way to do this
    								; force refresh if xPos or anim is changed
;    bra endAnim

firstFrame:
	lda #$01
	sta EnemyArrayAnimFrameCounter,X
	lda #$00
	sta EnemyArrayAnimFrameIndex,X
	bra nextFrameContinue

nextFrame:

    lda #$01
    sta EnemyArrayAnimFrameCounter,X

    lda EnemyArrayAnimFrameIndex,X
    inc
    inc
    inc
    sta EnemyArrayAnimFrameIndex,X

nextFrameContinue:
    tay
    lda (EnemyCurrentAnimAddress),y
    cmp #$00
    bne noLoop

    lda #$00
    sta EnemyArrayAnimFrameIndex,X

noLoop:

	txa
	asl
	asl
	asl								; index slot * 8
	clc
	adc #$08						; computed index slot + 8
	pha

    lda EnemyArrayAnimFrameIndex,X
	tay
	iny

	rep #$20
	.A16

	lda (EnemyCurrentAnimAddress),Y	; dataAddr
	tax

	lda EnemyCurrentXOffset			; set xPos
	tay

	rep #$10
	sep #$20
	.A8
	.I16

	pla

    jsr setEnemyOAM

    jsr OAMDataUpdated

endAnim:

	plb
    plp
    ply
    plx
    pla

    rts

.endproc

;******************************************************************************
;*** reactEnemy ****************************************************************
;******************************************************************************
;*** index of slot  (A register)                                            ***
;******************************************************************************

; check for collision ???
; update X offset
; stategy to make enemy appear (need reverse engenering of the arcade ???)

.proc reactEnemy
	pha
	phx
	phy
	php

	ldx #$0000
	ldy #$0000

reactLoop:
	cpx #ENEMY_SPRITE_NUMBER
	beq endReactLoop

	lda EnemyArrayFlag,X
	and ENEMY_STATUS_ACTIVE_FLAG
	beq skipReact

	rep #$20
	.A16

	ldy #$0000
	lda EnemyArrayXOffset,Y			; TODO do it wisely
	inc								; increment xPos
	sta EnemyArrayXOffset,Y

	rep #$10
	sep #$20
	.A8
	.I16

	txa								; slot to anim
	jsr animEnemy

skipReact:
	inx								; update indexes
	iny
	iny
	bra reactLoop

endReactLoop:

	plp
	ply
	plx
	pla
	rts
.endproc

