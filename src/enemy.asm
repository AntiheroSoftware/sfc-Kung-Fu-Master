;
; Kung Fu Master ennemies control
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments
            .linecont

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "snes-sprite.inc"
            .include    "includes/hero.inc"
            .include    "includes/score.inc"

            .include 	"includes/enemyData.asm"

            ENEMY_MAIN_CODE = 1
			.include    "includes/enemy.inc"

            .import 	spriteCounter

            .export 	initEnemySprite
            .export 	reactEnemy
            .export 	hdmaInitTitle
            .export 	hdmaInitGame

			.export EnemyCurrentArrayIndexByte
			.export EnemyCurrentArrayIndexWord
			.export EnemyTempXOffsetHigh
            .export setEnemyOAM
            .export EnemyArrayAnimAddress
            .export EnemyArrayAnimFrameIndex
            .export EnemyArrayAnimFrameCounter
            .export EnemyArrayAnimJumpFramecounter
            .export EnemyArrayXOffset
            .export EnemyArrayOAMSlotOffset
            .export EnemyArrayFlag
            .export addEnemy
            .export animEnemy
            .export grabbingWalk
            .export grabbingWalk1
            .export grabbingWalk2
            .export highByte
            .export reactEnemyGrab
            .export enemyGrabFall
            .export clearEnemy

SPRITE_TILE_ZONE1_ADDR	= $3000
SPRITE_TILE_ZONE2_ADDR	= $4000
SPRITE_TILE_ZONE3_ADDR	= $5000
SPRITE_TILE_ZONE4_ADDR	= $6000

ENEMY_SPRITE_NUMBER = 13

.segment "ZEROPAGE"

EnemyCurrentAnimAddress:
	.res 2

EnemyCurrentArrayIndexByte:
	.res 2

EnemyCurrentArrayIndexWord:
	.res 2

.segment "BSS"

EnemyTempXOffsetHigh:
	.res 1

; *****************************************************************************
; *** Array of enemies definition *********************************************
; *****************************************************************************

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

EnemyArrayOAMSlotOffset:
	.res 2 * ENEMY_SPRITE_NUMBER

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
    sta EnemyArrayOAMSlotOffset,X

    sta EnemyArrayAnimAddress,Y
    sta EnemyArrayXOffset,Y
	iny
	sta EnemyArrayAnimAddress,Y
	sta EnemyArrayXOffset,Y

	lda #ENEMY_STATUS_MIRROR_FLAG
	sta EnemyArrayFlag,X

	inx
	iny
	bra initArrayLoop

endInitArrayLoop:

	lda #$00						; set enemy type
	ora #ENEMY_STATUS_TYPE_GRAB		; grab
	;ora #ENEMY_STATUS_MIRROR_FLAG	; in mirror mode
	ldx #$0000						; enemy slot ( 0 - 13 )
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
;*** flags (A)																***
;*** slot (X)													     		***
;******************************************************************************

.proc addEnemy
	pha
	phx
	phy
	php

	_EnemyDataIndexSetFromXIndex

	ldx EnemyCurrentArrayIndexByte
	ora #ENEMY_STATUS_ACTIVE_FLAG
	sta EnemyArrayFlag,X
	stz EnemyArrayAnimFrameIndex,X
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayAnimJumpFramecounter,X

	bit #ENEMY_STATUS_TYPE_GRAB
	beq check_knife

	ldx EnemyCurrentArrayIndexWord

	rep #$20
	.A16

	bit #ENEMY_STATUS_MIRROR_FLAG
	bne grab_mirror_init			; Mirror flag is set we init for mirror

grab_normal_init:

	lda #$ffe0
	sta EnemyArrayXOffset,X

	bra grab_end_init

grab_mirror_init:

	lda #$00ff
	sta EnemyArrayXOffset,X

grab_end_init:

	ldy EnemyCurrentArrayIndexByte
	tya
	asl
	asl
	asl								; index slot * 8
	asl
	asl 							; computed index slot * 4 cause each slot is taking 4 bytes
	sta EnemyArrayOAMSlotOffset,X	; set OAM slot offset

	lda #.LOWORD(grabbingWalk)
	sta EnemyArrayAnimAddress,X

	rep #$10
	sep #$20
	.A8
	.I16

	jmp check_end

check_knife:

check_end:

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** clearEnemy ***************************************************************
;******************************************************************************
;*** slot (X)													     		***
;******************************************************************************

.proc clearEnemy
	phy
	phx
	pha

	lda #$00
	sta EnemyArrayFlag,X

	ldy EnemyArrayOAMSlotOffset,X
	tyx

	ldy #$0000

clearLoop:
	cpy #$0008
	beq endClearLoop

	lda #$e0
	sta oamData+1,x                 ; V (Y) pos of the sprite

	inx
	inx
	inx
	inx

	iny

	bra clearLoop

endClearLoop:

	pla
	plx
	ply
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
;*** index of slot  (A register)                                            ***
;*** dataAddr   (X register)                                                ***
;******************************************************************************

.proc setEnemyOAM
    php

	txy								; save dataAddr

    rep #$20
	.A16

	and #$00ff
	asl								; index * 2
	tax								; set OAM offset table
	pha								; push/save index of slot

	lda EnemyArrayXOffset,X
	pha								; push/save XOffset

	phy								; push/save dataAddr

	ldy EnemyArrayOAMSlotOffset,X
	tyx

	lda #$0000						; reset accumulator

	rep #$10
	sep #$20
	.A8
	.I16

	ldy #$0000						; index in metaprite table

    lda #$00
	sta spriteCounter				; reset spriteCounter
	sta EnemyTempXOffsetHigh		; reset EnemyTempXOffsetHigh

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
    adc #$80
	pha

	_EnemyDataLDA EnemyArrayFlag		; check direction of enemy from EnemyArrayFlag
	and #ENEMY_STATUS_MIRROR_FLAG
	cmp #$00
	beq blockLoop					; jmp to correct blockLoop code (normal)
	jmp blockLoopMirror				; jmp to correct blockLoop code (mirror)

blockLoop:
	lda $02,s						; load blockNumber
	cmp #$00
	bne :+
	jmp endBlockLoop				; check all block are done
:	dec
	sta $02,s						; update counter

	iny

	lda $06,s						; check if high byte of X pos is greater than $00
	cmp #$00
	beq :+

	lda ($03,s),y					; load X pos for that
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	bcs :++							; check and branch if carry is set

	lda EnemyTempXOffsetHigh
	lsr
	ora #%10000000
	sta EnemyTempXOffsetHigh		; set high byte on for the sprite

	bra :+++

:	lda ($03,s),y					; load X pos for that
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	bcc :+							; check and branch if carry is clear

	lda ($03,s),y
	cmp #$f0						; allow metasprite offset of -15

	bcs :+							; if carry is set we are good
									; skip on carry clear

	iny								; skip this sprite cause of overflow
	iny
	bra blockLoop

:	lda EnemyTempXOffsetHigh
	lsr
	sta EnemyTempXOffsetHigh

:	lda $01,s
	sta oamData+1,x                 ; V (Y) pos of the sprite

	iny								; skip mirror xOffset
	iny
	lda ($03,s),y
	sta oamData+2,x                 ; Tile number

	lda #%00110011					; TODO comment this
	sta oamData+3,x                 ; no flip full priority palette 0 (8 global palette)

	inx
	inx
	inx
	inx

	inc	spriteCounter

	bra blockLoop

blockLoopMirror:
	lda $02,s						; load blockNumber
	cmp #$00
	beq endBlockLoop				; check all block are done
	dec
	sta $02,s						; update counter

	iny
	iny								; skip normal xOffset

	lda $06,s						; check if high byte of X pos is greater than $00
	cmp #$00
	beq :+

	lda ($03,s),y					; load X pos for that
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	bcs :++							; check and branch if carry is set

	lda EnemyTempXOffsetHigh
	lsr
	ora #%10000000
	sta EnemyTempXOffsetHigh		; set high byte on for the sprite

	bra :+++

:	lda ($03,s),y					; load X pos for that
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	bcc :+							; check and branch if carry is clear
									; sprite might be overflow
	lda ($03,s),y
	cmp #$f0						; allow metasprite offset of -15

	bcs :+							; if carry is set we are good
									; skip on carry clear

	iny								; skip this sprite cause of overflow
	bra blockLoopMirror

:	lda EnemyTempXOffsetHigh
	lsr
	sta EnemyTempXOffsetHigh

:	lda $01,s
	sta oamData+1,x                 ; V (Y) pos of the sprite

	iny
	lda ($03,s),y
	sta oamData+2,x                 ; Tile number

	lda #%01110011					; TODO comment this
	sta oamData+3,x                 ; no flip full priority palette 0 (8 global palette)

	inx
	inx
	inx
	inx

	inc	spriteCounter

	bra blockLoopMirror

endBlockLoop:

	iny
	pla
	pla

	jmp lineLoop

endLineLoop:

fillLoop:
    lda spriteCounter
    cmp #$08
    beq endFillLoop

    lda #$e0
    sta oamData+1,x                 ; V (Y) pos of the sprite

    lda EnemyTempXOffsetHigh
	lsr
	sta EnemyTempXOffsetHigh

    inx
    inx
    inx
    inx

    inc spriteCounter
    bra fillLoop

endFillLoop:

    plx								; push out old unused value of stack to get back index
	ply								; push out old unused value of stack to get back index

	plx								; restore index of slot

	lda EnemyTempXOffsetHigh
	and #$0f
	tay
	lda highByte,Y
	sta oamData + $200,X

	lda EnemyTempXOffsetHigh
	lsr
	lsr
	lsr
	lsr
	tay
	lda highByte,Y
	sta oamData + $201,X

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
	pha								; push index slot (0-13)

    lda EnemyArrayAnimFrameIndex,X
	tay
	iny

	rep #$20
	.A16

	lda (EnemyCurrentAnimAddress),Y	; dataAddr
	tax

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
;*** reactEnemy ***************************************************************
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

	_ResetHeroGrabFlag

reactLoop:
	cpx #ENEMY_SPRITE_NUMBER
	beq endReactLoop

	lda EnemyArrayFlag,X
	bit #ENEMY_STATUS_ACTIVE_FLAG
	beq skipReact

reactCheckGrab:
	bit #ENEMY_STATUS_TYPE_GRAB
	beq reactCheckKnife

	jsr reactEnemyGrab
	bra skipReact

reactCheckKnife:
	bit #ENEMY_STATUS_TYPE_KNIFE
	beq reactCheckMidget

	jsr reactEnemyKnife
	bra skipReact

reactCheckMidget:
	bit #ENEMY_STATUS_TYPE_KNIFE
	beq skipReact

	jsr reactEnemyMidget
	bra skipReact

skipReact:
	inx								; update indexes
	iny
	iny
	jmp reactLoop

endReactLoop:

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** reactEnemyGrab ***********************************************************
;******************************************************************************
;*** A contains enemyFlag                                                   ***
;******************************************************************************

.proc reactEnemyGrab
	pha
	phx
	phy
	php

	;*** check if we are grabbing (shake counter is not zero) ***
	;************************************************************

	and #ENEMY_STATUS_SHAKE_COUNT_MASK

	cmp #$00
	beq notGrabbing						; We are currently not grabbing so we continue

	cmp #$01
	beq branchToFall					; if shake count is decrement until 1
										; enemy is killed and will fall

	_SetHeroGrabFlag					; we grab the hero

	;*** enemy is grabbing the hero ***
	;**********************************

	pha									; save shake count
	_GetHeroShakingFlag					; check if hero is shaking
	cmp #HERO_STATUS_SHAKING_FLAG
	bne heroDontShake

heroShake:

	pla
	dec									; decrement shake count value
	_setEnemyShakingCounter

	_EnemyDataLDA EnemyArrayAnimFrameCounter
	cmp #$04							; check if enemy anim frame counter is equal to 4
	beq heroShakeContinue
	cmp #$08							; check if enemy anim frame counter is equal to 8
	beq heroShakeContinue

	bra heroNoEnergyLose

heroShakeContinue:

	lda #$01							; decrement hero energy
	jsr updateEnergyPlayer
	jsr setEnergyPlayer

	jmp end

heroDontShake:

	pla

	_EnemyDataLDA EnemyArrayAnimFrameCounter
	cmp #$04							; check if enemy anim frame counter is equal to 4
	beq heroDontShakeContinue
	cmp #$08							; check if enemy anim frame counter is equal to 8
	beq heroDontShakeContinue

	bra heroNoEnergyLose

heroDontShakeContinue:

	lda #$01							; decrement hero energy
	jsr updateEnergyPlayer
	jsr setEnergyPlayer

	jmp end

heroNoEnergyLose:
	jmp end

branchToFall:
	jmp fall

notGrabbing:

	lda EnemyArrayFlag,X

	rep #$20
	.A16

	bit #ENEMY_STATUS_MIRROR_FLAG
	bne mirrorMode

	;*******************
	;*** Normal mode ***
	;*******************

normalMode:
	lda heroXOffset
	and #$00ff
	sec
	sbc EnemyArrayXOffset,Y					; calculate distance between enemy and hero

	cmp #ENEMY_NORMAL_GRAB_DISTANCE_GRAB
	bne normalModeLiftArmCheck

	rep #$10
	sep #$20
	.A8
	.I16

	stz EnemyArrayAnimFrameIndex,X			; reset animation indexes and counter
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayAnimJumpFramecounter,X

	rep #$20
	.A16

	lda #.LOWORD(grabbingGrab)
	sta EnemyArrayAnimAddress,Y

	_ResetEnemyShakingCounter					; set shakingCounter in enemyFlag to init value

	bra end

normalModeLiftArmCheck:
	cmp #ENEMY_NORMAL_GRAB_DISTANCE_ARMS_UP		; check if we need to set arms up animation
	bpl normalModeGoRight

	lda #.LOWORD(grabbingArmUpWalk)				; we don't reset the animation indexes and counter
	sta EnemyArrayAnimAddress,Y					; so animation is fluid in the walk process

normalModeGoRight:
	lda EnemyArrayXOffset,Y						; go right
	inc
	sta EnemyArrayXOffset,Y						; increment enemy X Offset

	bra end

	;*******************
	;*** Mirror mode ***
	;*******************

mirrorMode:
	lda EnemyArrayXOffset,Y
	sec
	sbc heroXOffset
	and #$00ff									; calculate distance between enemy and hero

	cmp #ENEMY_MIRROR_GRAB_DISTANCE_GRAB
	bne mirrorModeLiftArmCheck

	rep #$10
	sep #$20
	.A8
	.I16

	stz EnemyArrayAnimFrameIndex,X				; reset animation indexes and counter
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayAnimJumpFramecounter,X

	rep #$20
	.A16

	lda #.LOWORD(grabbingGrab)
	sta EnemyArrayAnimAddress,Y

	_ResetEnemyShakingCounter					; set shakingCounter in enemyFlag

	bra end

mirrorModeLiftArmCheck:
	cmp #ENEMY_MIRROR_GRAB_DISTANCE_ARMS_UP		; check if we need to set arms up animation
	bpl mirrorModeGoLeft

	lda #.LOWORD(grabbingArmUpWalk)				; we don't reset the animation indexes and counter
	sta EnemyArrayAnimAddress,Y					; so animation is fluid in the walk process

mirrorModeGoLeft:
	lda EnemyArrayXOffset,Y						; go left
	dec
	sta EnemyArrayXOffset,Y						; decrement enemy X Offset

	bra end

fall:											; TODO do a real fall
	jsr enemyGrabFall

	rep #$10
	sep #$20
	.A8
	.I16

	bra skipAnim

end:
	rep #$10
	sep #$20
	.A8
	.I16

	txa											; slot to anim
	_EnemyDataIndexSetFromAccumulator
	jsr animEnemy

skipAnim:

	plp
	ply
	plx
	pla
	rts
.endproc

.proc enemyGrabFall
	jsr clearEnemy								; disable ennemy
	rts
.endproc

;******************************************************************************
;*** reactEnemyKnife **********************************************************
;******************************************************************************

.proc reactEnemyKnife
	pha
	phx
	phy
	php

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** reactEnemyMidget *********************************************************
;******************************************************************************


.proc reactEnemyMidget
	pha
	phx
	phy
	php

	plp
	ply
	plx
	pla
	rts
.endproc
