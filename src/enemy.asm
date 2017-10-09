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

;*** Therorical enemy max is 7 due to 34 8x8 sprite limitation per line
;*** Max 6 grab enemy grab on screen
;*** Max 2 knife enemy on screen
;*** Max 2 midget enemy on screen

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

EnemyArrayOAMSlotOffset:
	.res 2 * ENEMY_SPRITE_NUMBER

EnemyArrayXOffset:
	.res 2 * ENEMY_SPRITE_NUMBER

EnemyArrayYOffset:
	.res 1
EnemyArrayAnimFrameIndex:
	.res 1
	.res 2 * ENEMY_SPRITE_NUMBER-1

EnemyArrayAnimFrameCounter:
	.res 1
EnemyArrayOffsetFramecounter:
	.res 1
	.res 2 * ENEMY_SPRITE_NUMBER-1

EnemyArrayFlag:
	.res 1
EnemyArrayDummy:
	.res 1
	.res 2 * ENEMY_SPRITE_NUMBER-1

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

	ldx #$0000						; index for enemy struct
	ldy #$0000						; counter for number of sprite

initArrayLoop:
	cpy #ENEMY_SPRITE_NUMBER
	beq endInitArrayLoop

	lda #ENEMY_STATUS_MIRROR_FLAG
	sta EnemyArrayFlag,X

    stz EnemyArrayAnimFrameIndex,X
    stz EnemyArrayAnimFrameCounter,X
    stz EnemyArrayOffsetFramecounter,X

	stz EnemyArrayOAMSlotOffset,X
    stz EnemyArrayAnimAddress,X
    stz EnemyArrayXOffset,X
	inx								; increment index of enemy struct to clear high byte
	stz EnemyArrayOAMSlotOffset,X
	stz EnemyArrayAnimAddress,X
	stz EnemyArrayXOffset,X

	inx
	iny
	bra initArrayLoop

endInitArrayLoop:

	;*** add an enemy for test ***
	;*****************************

	lda #$00						; set enemy type
	ora #ENEMY_STATUS_TYPE_GRAB		; grab
	;ora #ENEMY_STATUS_MIRROR_FLAG	; in mirror mode
	jsr findEmptySlotEnemy			; Load X with a free enemy slot ( 0 - 13 )
	jsr addEnemy

	;*** add a second enemy for test ***
	;***********************************

	jsr findEmptySlotEnemy
	jsr addEnemy

	;*** then clear it ***
	;*********************

	ldx #$0002
	jsr clearEnemy

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

	;*** TODO
	;*** check if we can simplify _EnemyDataIndexSetFromXIndex
	;*** seems to double init a lot of things with initEnemySprite
	;*****************************************************************

	_EnemyDataIndexSetFromXIndex

	ldx EnemyCurrentArrayIndexWord
	ora #ENEMY_STATUS_ACTIVE_FLAG
	sta EnemyArrayFlag,X
	stz EnemyArrayAnimFrameIndex,X
	stz EnemyArrayAnimFrameCounter,X
	stz EnemyArrayOffsetFramecounter,X

	bit #ENEMY_STATUS_TYPE_GRAB
	beq check_knife					; if it's not a grab enemy check for knife

	lda #$80						; set static Y offset for enemy
	sta EnemyArrayYOffset,X

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

	txa
	;asl							; removed cause X is not index slot but already *2
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
	pha
	php

	ldx #$0000
search:
	lda EnemyArrayFlag,X
	and #ENEMY_STATUS_ACTIVE_FLAG
	beq return
	cpx #(ENEMY_SPRITE_NUMBER-1)*2
	beq notFound
	inx
	inx
	bra search

notFound:
	ldx #$ffff
	bra exit

return:

	rep #$20
	.A16

	txa
	lsr
	tax

exit:

	plp
	pla
	rts
.endproc

;******************************************************************************
;*** clearEnemy ***************************************************************
;******************************************************************************
;*** Offset of enemy data (X register)							     		***
;******************************************************************************

.proc clearEnemy
	phy
	phx
	pha
	php

	rep #$10
	sep #$20
	.A8
	.I16

	lda #$00
	sta EnemyArrayFlag,X			; clear activity flag

	ldy EnemyArrayOAMSlotOffset,X
	tyx								; set OAM Offset for that sprite in X

	ldy #$0000

clearLoop:
	cpy #$0008
	beq endClearLoop

	lda #$e0
	sta oamData+1,X                 ; V (Y) pos of the sprite

	inx
	inx
	inx
	inx

	iny

	bra clearLoop

endClearLoop:

	plp
	pla
	plx
	ply
	rts
.endproc

;******************************************************************************
;*** setEnemyOAM ennemies with hdma trick *************************************
;******************************************************************************
;*** data Address of metasprite (X register)                                ***
;*** offset of enemy data       (Y register)                                ***
;******************************************************************************

.proc setEnemyOAM
    php

    rep #$20
	.A16

	phy								; push/save index of slot

	lda EnemyArrayXOffset,Y
	pha								; push/save XOffset

	phx								; push/save dataAddr

	ldx EnemyArrayOAMSlotOffset,Y

	lda #$0000						; reset accumulator

	rep #$10
	sep #$20
	.A8
	.I16

	ldy #$0000						; index in metaprite table

	stz spriteCounter				; reset spriteCounter
	stz EnemyTempXOffsetHigh		; reset EnemyTempXOffsetHigh

lineLoop:							; loop for each line
    lda ($01,s),Y					; load number block for this line
    and #ENEMY_MS_BLOCK_NUMBER_MASK
    cmp #$00
    bne continueLineLoop			; if no block it's the end

	jmp endLineLoop

continueLineLoop:
	lda ($01,s),Y					; load number block for this line + status
    pha								; save it to the stack

    iny								; load Y Pos for that line
    lda ($02,s),Y					; save it to the stack
    clc
    ;adc heroYOffset				; TODO make a global for enemy Y offset
    adc #$80
    clc
    adc EnemyCurrentYOffset

	cmp #$e0
	bcc :+							; if Y < 244 continue to handle the line


	pla
	and #ENEMY_MS_BLOCK_NUMBER_MASK ; get back number of block for this line
skipLineLoop:
	iny
	iny
	iny								; skip data for that line
	dec
	cmp #$00
	bne skipLineLoop

	iny								; goto next line index
	bra lineLoop

:
	pha

	phy								; save Y value

	rep #$20
	.A16

	lda $09,s						; get enemy offset value from stack
	tay								; ut it in Y register

	sep #$20
	.A8

	lda EnemyArrayFlag,Y			; check direction of enemy from EnemyArrayFlag

	ply								; restore Y value

	and #ENEMY_STATUS_MIRROR_FLAG
	cmp #$00
	beq blockLoop					; jmp to correct blockLoop code (normal)
	jmp blockLoopMirror				; jmp to correct blockLoop code (mirror)

	;*** normal mode blockLoop ***
	;*****************************

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

	lda ($03,s),Y					; load X pos for that
	sec
	sbc EnemyCurrentXOffset
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,X                   ; H (X) pos of the sprite

	bcs :++							; check and branch if carry is set

	lda EnemyTempXOffsetHigh
	lsr
	ora #%10000000
	sta EnemyTempXOffsetHigh		; set high byte on for the sprite

	bra :+++

:	lda ($03,s),Y					; load X pos for that
	sec
	sbc EnemyCurrentXOffset
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,X                   ; H (X) pos of the sprite

	bcc :+							; check and branch if carry is clear

	lda ($03,s),Y
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
	sta oamData+1,X                 ; V (Y) pos of the sprite

	iny								; skip mirror xOffset
	iny
	lda ($03,s),y
	sta oamData+2,X                 ; Tile number

	lda $02,s
	lsr
	lsr
	lsr
	lsr
	phy
	tay
	lda metaspriteStatusNormal,y
	ply

	sta oamData+3,X
	inx
	inx
	inx
	inx

	inc	spriteCounter

	bra blockLoop

	;*** mirror mode blockLoop ***
	;*****************************

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

	lda ($03,s),Y					; load X pos for that
	clc
	adc EnemyCurrentXOffset
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,X                   ; H (X) pos of the sprite

	bcs :++							; check and branch if carry is set

	lda EnemyTempXOffsetHigh
	lsr
	ora #%10000000
	sta EnemyTempXOffsetHigh		; set high byte on for the sprite

	bra :+++

:	lda ($03,s),Y					; load X pos for that
	clc
	adc EnemyCurrentXOffset
	clc
	adc $05,s                		; add saved Global X Pos
	sta oamData,X                   ; H (X) pos of the sprite

	bcc :+							; check and branch if carry is clear
									; sprite might be overflow
	lda ($03,s),Y
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
	sta oamData+1,X                 ; V (Y) pos of the sprite

	iny
	lda ($03,s),y
	sta oamData+2,X                 ; Tile number

	lda $02,s
	lsr
	lsr
	lsr
	lsr
	phy
	tay
	lda metaspriteStatusMirror,Y
	ply

	sta oamData+3,X
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
    bcs endFillLoop					; if a >= $08

    lda #$e0
    sta oamData+1,X                 ; V (Y) pos of the sprite

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

.export setEnemyOAM_lineLoop = setEnemyOAM::lineLoop
.export setEnemyOAM_skiplineLoop = setEnemyOAM::skipLineLoop
.export setEnemyOAM_fillLoop = setEnemyOAM::fillLoop

;******************************************************************************
;*** animEnemy ****************************************************************
;******************************************************************************
;*** X is offset of enemyData												***
;******************************************************************************

.proc animEnemy

    pha
    phx
    phy
    php

	ldy EnemyArrayAnimAddress,X
	sty EnemyCurrentAnimAddress			; set current anim address

	phb									; save data bank
	lda #ENEMY_DATA_BANK
	pha
	plb									; set 'enemy' data bank

    lda EnemyArrayAnimFrameIndex,X
    tay
    lda EnemyArrayAnimFrameCounter,X
    cmp #$00 							; first time we do that animation
    beq firstFrame

    dec
    cmp (EnemyCurrentAnimAddress),Y 	; we did all frames for that index
    beq nextFrame

    inc EnemyArrayAnimFrameCounter,X

    ;*** TODO
    ;*** check if xpos has changed or anim has changed ***
    ;*****************************************************

	bra noLoop							; force refresh if xPos or anim is changed
    ;bra endAnim

firstFrame:
	lda #$01							; init for first time we do that animation
	sta EnemyArrayAnimFrameCounter,X
	lda #$00
	sta EnemyArrayAnimFrameIndex,X
	bra nextFrameContinue

nextFrame:
    lda #$01
    sta EnemyArrayAnimFrameCounter,X	; reset anim frame counter

    lda EnemyArrayAnimFrameIndex,X
    inc									; skip address high
    inc									; skip address low
    inc									; skip counter
    sta EnemyArrayAnimFrameIndex,X		; update anim frame index

nextFrameContinue:
    tay
    lda (EnemyCurrentAnimAddress),Y
    cmp #$00
    bne noLoop

    lda #$00							; we are in a loop / reset the anim frame index
    sta EnemyArrayAnimFrameIndex,X

    ;*** TODO
    ;*** check if new frame is different than previous one in loop ***
    ;*****************************************************************

noLoop:

    lda EnemyArrayAnimFrameIndex,X
	tay
	iny									; skip counter

	rep #$20
	.A16

	lda (EnemyCurrentAnimAddress),Y		; data address
	txy									; offset in Y
	tax									; data address in X

	rep #$10
	sep #$20
	.A8
	.I16

    jsr setEnemyOAM

    jsr OAMDataUpdated

endAnim:

	plb								; restore data bank
    plp
    ply
    plx
    pla

    rts

.endproc

;******************************************************************************
;*** reactEnemy ***************************************************************
;******************************************************************************
;*** No parameters                                                          ***
;******************************************************************************

; check for collision ???
; update X offset
; stategy to make enemy appear (need reverse engenering of the arcade ???)

.proc reactEnemy
	pha
	phx
	phy
	php

	ldx #$0000						; index for enemy data structure
	ldy #$0000						; sprite counter

	_ResetHeroGrabFlag

reactLoop:
	cpy #ENEMY_SPRITE_NUMBER
	beq endReactLoop

	lda EnemyArrayFlag,X
	bit #ENEMY_STATUS_ACTIVE_FLAG
	beq skipReact

reactCheckGrab:
	bit #ENEMY_STATUS_TYPE_GRAB
	beq reactCheckKnife

	;sty EnemyCurrentArrayIndexByte
	;stx EnemyCurrentArrayIndexWord

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
	inx
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
;*** X contains enemy data struct index    									***
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

	lda EnemyArrayAnimFrameCounter,X
	cmp #$04							; check if enemy anim frame counter is equal to 4
	beq heroShakeContinue
	cmp #$08							; check if enemy anim frame counter is equal to 8
	beq heroShakeContinue

	bra heroNoEnergyLose

heroShakeContinue:

	lda #$01							; decrement hero energy
	jsr updateEnergyPlayer
	jsr setEnergyPlayer

	jmp end								; do the anim part to increment EnemyArrayAnimFrameCounter
	;jmp skipAnim

heroDontShake:

	pla

	lda EnemyArrayAnimFrameCounter,X
	cmp #$04							; check if enemy anim frame counter is equal to 4
	beq heroDontShakeContinue
	cmp #$08							; check if enemy anim frame counter is equal to 8
	beq heroDontShakeContinue

	bra heroNoEnergyLose

heroDontShakeContinue:

	lda #$01							; decrement hero energy
	jsr updateEnergyPlayer
	jsr setEnergyPlayer

	jmp end								; do the anim part to increment EnemyArrayAnimFrameCounter
	;jmp skipAnim

heroNoEnergyLose:
	jmp end								; do the anim part to increment EnemyArrayAnimFrameCounter
	;jmp skipAnim

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
	sbc EnemyArrayXOffset,X					; calculate distance between enemy and hero

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

	lda #.LOWORD(grabbingGrab)				; set grab animation
	sta EnemyArrayAnimAddress,X

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
	sta EnemyArrayAnimAddress,X					; so animation is fluid in the walk process

normalModeGoRight:
	lda scrollDirection
	and #$00ff
	cmp #LEVEL_SCROLL_NONE
	beq :+

	cmp #LEVEL_SCROLL_RIGHT
	beq :++

	lda EnemyArrayXOffset,X						; go right double speed
	inc
	inc
	sta EnemyArrayXOffset,X						; increment enemy X Offset
	bra :++

:	lda EnemyArrayXOffset,X						; go right
	inc
	sta EnemyArrayXOffset,X						; increment enemy X Offset

:	jmp end

	;*******************
	;*** Mirror mode ***
	;*******************

	.A8

mirrorMode:
	lda EnemyArrayXOffset,X
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
	sta EnemyArrayAnimAddress,X

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
	sta EnemyArrayAnimAddress,X					; so animation is fluid in the walk process

mirrorModeGoLeft:
	lda scrollDirection
	and #$00ff
	cmp #LEVEL_SCROLL_NONE
	beq :+

	cmp #LEVEL_SCROLL_LEFT
	beq :++

	lda EnemyArrayXOffset,X						; go left double speed
	dec
	dec
	sta EnemyArrayXOffset,X						; decrement enemy X Offset
	bra :++

:	lda EnemyArrayXOffset,X						; go left
	dec
	sta EnemyArrayXOffset,X						; decrement enemy X Offset

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
;*** A contains enemyFlag                                                   ***
;*** X contains enemy data struct index    									***
;******************************************************************************

.proc enemyGrabFall

	phb								; save current data bank
	pha								; save current enemy flag

	lda #ENEMY_DATA_BANK
	pha
	plb								; set data bank

	pla								; restore current enemy flag

	rep #$20
	.A16

	and #$0007
	asl
	tay

	lda EnemyArrayAnimAddress,X
	cmp enemyFallAnimAddress,Y
	beq :+

	lda enemyFallAnimAddress,Y
	sta EnemyArrayAnimAddress,X

	plb								; restore data bank

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

:	plb

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

	phb								; save current data bank
	lda #ENEMY_DATA_BANK
	pha
	plb								; set data bank

	lda EnemyArrayOffsetFramecounter,X

	phx
	tax
	lda enemyFallYOffset,X
	sta EnemyCurrentYOffset
	lda enemyFallXOffset,X
	sta EnemyCurrentXOffset
	plx

	plb								; restore data bank

	; TODO set enemy X offset

	txa											; slot to anim
	jsr animEnemy

	stz EnemyCurrentYOffset
	stz EnemyCurrentXOffset

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
