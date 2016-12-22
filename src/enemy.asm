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
            .include    "includes/level.inc"
            .include    "includes/base.inc"
            .include    "includes/hit.inc"

            .include 	"includes/enemyData.asm"

            ENEMY_MAIN_CODE = 1
			.include    "includes/enemy.inc"

            .import 	spriteCounter

            .export 	initEnemySprite
            .export 	reactEnemy
            .export 	addEnemy
            .export 	findEmptySlotEnemy
            .export     EnemyCurrentXOffset
			.export     EnemyCurrentYOffset
			.export 	EnemyArrayXOffset
			.export 	EnemyArrayYOffset

			.export EnemyCurrentArrayIndexByte
			.export EnemyCurrentArrayIndexWord
			.export EnemyTempXOffsetHigh
            .export setEnemyOAM
            .export EnemyArrayAnimAddress
            .export EnemyArrayAnimFrameIndex
            .export EnemyArrayAnimFrameCounter
            .export EnemyArrayOffsetFramecounter
            .export EnemyArrayXOffset
            .export EnemyArrayOAMSlotOffset
            .export EnemyArrayFlag
            .export addEnemy
            .export animEnemy
            .export grabbingWalk
            .export grabbingWalk1
            .export grabbingWalk2
            .export grabbingGrab
            .export grabbingShakeFall
            .export grabbingHitHighFall
            .export grabbingHitMidFall
            .export grabbingHitLowFall
            .export grabbingFall1
            .export highByte
            .export reactEnemyGrab
            .export enemyGrabFall
            .export clearEnemy
            .export enemyFallYOffset
            .export enemyFallAnimAddress


SPRITE_TILE_BASE_ADDR = $2000

SPRITE_TILE_ZONE1_ADDR	= $3000
SPRITE_TILE_ZONE2_ADDR	= $4000
SPRITE_TILE_ZONE3_ADDR	= $5000
SPRITE_TILE_ZONE4_ADDR	= $6000

ENEMY_SPRITE_NUMBER = 14

.segment "ZEROPAGE"

EnemyCurrentAnimAddress:
	.res 2

EnemyCurrentArrayIndexByte:
	.res 2

EnemyCurrentArrayIndexWord:
	.res 2

EnemyCurrentYOffset:
	.res 1

EnemyCurrentXOffset:
	.res 1

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

EnemyArrayOffsetFramecounter:
	.res 1 * ENEMY_SPRITE_NUMBER

EnemyArrayYOffset:
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
	CGRAMLoad enemySpritePal, $90, $40

	VRAMLoad spriteBaseTiles, SPRITE_TILE_BASE_ADDR, $2000

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
    sta EnemyArrayOffsetFramecounter,X
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
	jsr findEmptySlotEnemy			; Load X with a free enemy slot ( 0 - 13 )
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

	stz EnemyCurrentYOffset
	stz EnemyCurrentXOffset

	_EnemyDataIndexSetFromXIndex

	ldx EnemyCurrentArrayIndexByte
	ora #ENEMY_STATUS_ACTIVE_FLAG
	sta EnemyArrayFlag,X
	stz EnemyArrayAnimFrameIndex,X
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayOffsetFramecounter,X

	bit #ENEMY_STATUS_TYPE_GRAB
	beq check_knife

	ldy EnemyCurrentArrayIndexByte
	lda #$80						; set static Y offset for enemy
	sta EnemyArrayYOffset,Y

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
;*** findEmptySlotEnemy *******************************************************
;******************************************************************************
;*** return free slot (X)				    					     		***
;******************************************************************************

.proc findEmptySlotEnemy
	php
	pha

	ldx #$0000
search:
	lda EnemyArrayFlag,X
	and #ENEMY_STATUS_ACTIVE_FLAG
	beq return
	cpx #ENEMY_SPRITE_NUMBER-1
	beq notFound
	inx
	bra search

notFound:
	ldx #$ffff

return:

	pla
	plp
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

	ldx EnemyCurrentArrayIndexWord
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
    and #ENEMY_MS_BLOCK_NUMBER_MASK
    cmp #$00
    bne continueLineLoop			; if no block it's the end
	jmp endLineLoop
continueLineLoop:
	lda ($01,s),y					; load number block for this line + status
    pha								; save it to the stack

    iny								; load Y Pos for that line
    lda ($02,s),y					; save it to the stack
    clc
    ;adc heroYOffset				; TODO make a global for enemy Y offset
    adc #$80
    clc
    adc EnemyCurrentYOffset

	cmp #$e0
	bcc :+

	pla
skipLineLoop:
	iny
	iny
	iny
	iny
	dec
	cmp #$00
	bne skipLineLoop

	bra lineLoop

:
	pha

	_EnemyDataLDA EnemyArrayFlag		; check direction of enemy from EnemyArrayFlag
	and #ENEMY_STATUS_MIRROR_FLAG
	cmp #$00
	beq blockLoop					; jmp to correct blockLoop code (normal)
	jmp blockLoopMirror				; jmp to correct blockLoop code (mirror)

blockLoop:
	lda $02,s						; load blockNumber
	bit #ENEMY_MS_BLOCK_NUMBER_MASK
	bne :+
	jmp endBlockLoop				; check all block are done
:	dec
	sta $02,s						; update counter

	iny

	lda $06,s						; check if high byte of X pos is greater than $00
	cmp #$00
	beq :+

	lda ($03,s),y					; load X pos for that
	sec
	sbc EnemyCurrentXOffset
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
	sec
	sbc EnemyCurrentXOffset
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	bcc :+							; check and branch if carry is clear

	lda ($03,s),y
	sec
	sbc EnemyCurrentXOffset
	cmp #$e0						; allow metasprite offset of -31

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

	lda $02,s
	lsr
	lsr
	lsr
	lsr
	phy
	tay
	lda metaspriteStatusNormal,y
	ply

	sta oamData+3,x
	inx
	inx
	inx
	inx

	inc	spriteCounter

	bra blockLoop

blockLoopMirror:
	lda $02,s						; load blockNumber
	bit #ENEMY_MS_BLOCK_NUMBER_MASK
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
	adc EnemyCurrentXOffset
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
	adc EnemyCurrentXOffset
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,x                   ; H (X) pos of the sprite

	bcc :+							; check and branch if carry is clear
									; sprite might be overflow
	lda ($03,s),y
	clc
	adc EnemyCurrentXOffset
	cmp #$e0						; allow metasprite offset of -31

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

	lda $02,s
	lsr
	lsr
	lsr
	lsr
	phy
	tay
	lda metaspriteStatusMirror,y
	ply

	sta oamData+3,x
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

	xba
	lda	#$00
	xba								; reset high byte of A

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

	stx EnemyCurrentArrayIndexByte
	sty EnemyCurrentArrayIndexWord

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
	bra reactLoop

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
;*** X contains enemy index	for byte ???									***
;*** Y contains enemy index for word ???									***
;******************************************************************************

.proc reactEnemyGrab
	pha
	phx
	phy
	php

	pha									; save enemyFlag
	and #ENEMY_STATUS_HIT_MASK
	cmp #ENEMY_STATUS_HIT_MASK			; check if enemy is hit
	bne :+

	pla									; restore full enemyFlag
	jsr enemyGrabFall
	jmp skipAnim

	;*** check if we are grabbing (shake counter is not zero) ***
	;************************************************************

:	pla									; restore full enemyFlag

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

	bit #ENEMY_STATUS_MIRROR_FLAG
	bne mirrorMode

	;*******************
	;*** Normal mode ***
	;*******************

normalMode:
	lda heroXOffset
	sec
	sbc EnemyArrayXOffset,Y					; calculate distance between enemy and hero

	;*** Check for hit ***
	;*********************

	pha 									; save calculated enemy offset

	lda heroHitOffset
	cmp #$0000
	beq :+									; if hit Offset is 0 don't check for hit

	pla
	pha										; set back calculated enemy offset and keep it in stack

	sec
	sbc heroHitOffset
	bpl :+									; if difference is positive -> continue

	pla

	lda EnemyArrayFlag,X
	ora #ENEMY_STATUS_HIT_MASK
	ora heroHitZone
	sta EnemyArrayFlag,X					; set hit high flag
	jmp fall								; else fall

:	pla										; restore calculated enemy offset

	cmp #ENEMY_NORMAL_GRAB_DISTANCE_GRAB
	bcs normalModeLiftArmCheck				; >=

	stz EnemyArrayAnimFrameIndex,X			; reset animation indexes and counter
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayOffsetFramecounter,X

	rep #$20
	.A16

	lda #.LOWORD(grabbingGrab)
	sta EnemyArrayAnimAddress,Y

	rep #$10
	sep #$20
	.A8
	.I16

	_ResetEnemyShakingCounter					; set shakingCounter in enemyFlag to init value

	jmp end

normalModeLiftArmCheck:
	rep #$20
	.A16
	cmp #ENEMY_NORMAL_GRAB_DISTANCE_ARMS_UP		; check if we need to set arms up animation
	bpl normalModeGoRight

	lda #.LOWORD(grabbingArmUpWalk)				; we don't reset the animation indexes and counter
	sta EnemyArrayAnimAddress,Y					; so animation is fluid in the walk process

normalModeGoRight:
	lda scrollDirection
	and #$00ff
	cmp #LEVEL_SCROLL_NONE
	beq :+

	cmp #LEVEL_SCROLL_RIGHT
	beq :++

	lda EnemyArrayXOffset,Y						; go right double speed
	inc
	inc
	sta EnemyArrayXOffset,Y						; increment enemy X Offset
	bra :++

:	lda EnemyArrayXOffset,Y						; go right
	inc
	sta EnemyArrayXOffset,Y						; increment enemy X Offset

:	jmp end

	;*******************
	;*** Mirror mode ***
	;*******************

	.A8

mirrorMode:
	lda EnemyArrayXOffset,Y
	sec
	sbc heroXOffset
	;and #$ff									; calculate distance between enemy and hero

	;*** Check for hit ***
	;*********************

	pha 									; save calculated enemy offset

	lda heroHitOffset
	cmp #$0000
	beq :+									; if hit Offset is 0 don't check for hit

	pla
	pha										; set back calculated enemy offset and keep it in stack

	sec
	sbc heroHitOffset
	bpl :+									; if difference is positive -> continue

	pla

	lda EnemyArrayFlag,X
	ora #ENEMY_STATUS_HIT_MASK
	ora heroHitZone
	sta EnemyArrayFlag,X					; set hit high flag
	jmp fall								; else fall

:	pla

	cmp #ENEMY_MIRROR_GRAB_DISTANCE_GRAB
	bne mirrorModeLiftArmCheck

	stz EnemyArrayAnimFrameIndex,X				; reset animation indexes and counter
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayOffsetFramecounter,X

	rep #$20
	.A16

	lda #.LOWORD(grabbingGrab)
	sta EnemyArrayAnimAddress,Y

	rep #$10
	sep #$20
	.A8
	.I16

	_ResetEnemyShakingCounter					; set shakingCounter in enemyFlag

	bra end

mirrorModeLiftArmCheck:
	rep #$20
	.A16
	cmp #ENEMY_MIRROR_GRAB_DISTANCE_ARMS_UP		; check if we need to set arms up animation
	bpl mirrorModeGoLeft

	lda #.LOWORD(grabbingArmUpWalk)				; we don't reset the animation indexes and counter
	sta EnemyArrayAnimAddress,Y					; so animation is fluid in the walk process

mirrorModeGoLeft:
	lda scrollDirection
	and #$00ff
	cmp #LEVEL_SCROLL_NONE
	beq :+

	cmp #LEVEL_SCROLL_LEFT
	beq :++

	lda EnemyArrayXOffset,Y						; go left double speed
	dec
	dec
	sta EnemyArrayXOffset,Y						; decrement enemy X Offset
	bra :++

:	lda EnemyArrayXOffset,Y						; go left
	dec
	sta EnemyArrayXOffset,Y						; decrement enemy X Offset

:	bra end

fall:

	jsr enemyGrabFall
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

;******************************************************************************
;*** enemyGrabFall ************************************************************
;******************************************************************************

.proc enemyGrabFall
;	pha
;	phx
;	phy
;	php

	phb
	pha

	lda #ENEMY_DATA_BANK
	pha
	plb

	pla

	rep #$20
	.A16

	and #$0007
	phx
	asl
	tax

	lda EnemyArrayAnimAddress,Y
	cmp enemyFallAnimAddress,X
	beq :+

	lda enemyFallAnimAddress,X
	sta EnemyArrayAnimAddress,Y

	plx
	plb

	lda #$0000
	rep #$10
	sep #$20
	.A8
	.I16
	stz EnemyArrayAnimFrameIndex,X				; reset animation indexes and counter
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayOffsetFramecounter,X

	lda EnemyArrayFlag,X
	jsr hitAdd

	bra :++

:	plx
	plb

	.A16
	lda #$0000
	rep #$10
	sep #$20
	.A8
	.I16
:	lda EnemyArrayOffsetFramecounter,X
	cmp #$1d
	bne :+

	jsr clearEnemy
	jsr OAMDataUpdated
	rts
:
	inc
	sta EnemyArrayOffsetFramecounter,X

	phb
	lda #ENEMY_DATA_BANK
	pha
	plb

	lda EnemyArrayOffsetFramecounter,X

	phx
	tax
	lda enemyFallYOffset,X
	sta EnemyCurrentYOffset
	lda enemyFallXOffset,X
	sta EnemyCurrentXOffset
	plx

	plb

	; TODO set enemy X offset

	txa											; slot to anim
	_EnemyDataIndexSetFromAccumulator
	jsr animEnemy

	stz EnemyCurrentYOffset
	stz EnemyCurrentXOffset

;	plp
;	ply
;	plx
;	pla

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
