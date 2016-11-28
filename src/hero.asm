;
; Kung Fu Master hero control
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "snes-sprite.inc"

            .include    "includes/base.inc"
            .include    "includes/level.inc"
            .include    "includes/score.inc"

			.include 	"includes/heroData.asm"

            			HERO_MAIN_CODE = 1
            .include    "includes/hero.inc"

            .export 	initHeroSprite
            .export 	transferHeroSpriteDataEvent
			.export 	reactHero
			.export		spriteCounter
			.export 	heroXOffset
			.export 	heroFlag

			.export setMirrorSpriteMode
			.export setNormalSpriteMode
			.export setShakingFlag
			.export fallHero
			.export setHeroOAM
			.export animHero
			.export clearHeroSprite

SPRITE_VRAM 		= $2000
SPRITE_LINE_SIZE 	= $0400

.segment "BSS"

spriteCounter:						; Temp Value used to count number of sprite used
	.res 1

animFrameIndex:						; Index of the current animation
	.res 1

animFrameCounter:				; Number of frame in animation
	.res 1

animationJumpFrameCounter:			; Number of total frame in jump animation
	.res 1

forceRefresh:
	.res 1

heroTransferAddr:					; Address of sprite Data to transfer
	.res 2

.segment "ZEROPAGE"

animInProgress:						; is there an animation in progress
	.res 1							; $01 simple animation in progress
									; $02 jump animation in progress
									
heroAnimAddr:						; address of the animation definition
	.res 2

heroYOffset:
	.res 1

heroXOffset:
	.res 2

heroHitOffset:
	.res 1

heroFlag:							; define status of actual position
	.res 1							; or what to expect next when we go further in animation

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** initHeroSprite ***********************************************************
;******************************************************************************
;*** init various stuff                                                     ***
;******************************************************************************
;*** A register contains heroYOffset                                        ***
;******************************************************************************

.proc initHeroSprite

	php
	phb
	pha

	jsr clearOAM

	lda #SPRITE_DATA_BANK			; change data bank to sprite data bank
	pha
	plb

	; init various variable
	lda #$00
	sta animFrameIndex
	sta animFrameCounter
	sta animationJumpFrameCounter
	sta animInProgress
	sta forceRefresh
	sta heroFlag

	pla
	sta heroYOffset

	lda #$70
	sta heroXOffset

	ldx #$0000
	stx heroTransferAddr

	ldx heroStand1
	jsr transferHeroSpriteData

	; load hero sprite palette
	CGRAMLoad KFM_Player_final_Pal, $80, $20

	jsr setMirrorSpriteMode

	lda #$01
	sta $2101                       ; set sprite address

	ldx #.LOWORD(heroStand)
	stx heroAnimAddr

	jsr animHero

	plb								; restore data bank
	plp
	rts

.endproc

;******************************************************************************
;*** clearHeroSprite **********************************************************
;******************************************************************************
;*** clear hero sprite                                                      ***
;******************************************************************************

.proc clearHeroSprite
	phy
	phx
	pha

	lda #$e0
	ldy #$0079
	ldx #$01E0

clearLoop:
	cpy #$0081
	beq endClearLoop

	sta oamData+1,x                 ; V (Y) pos of the sprite

	inx
	inx
	inx
	inx

	iny

	bra clearLoop

endClearLoop:

	jsr OAMDataUpdated				; for update of OAM

	pla
	plx
	ply
	rts
.endproc

;******************************************************************************
;*** setOAM hero **************************************************************
;******************************************************************************
;*** dataAddr   (X register)                                                ***
;*** xPos       (Y register)                                                ***
;******************************************************************************

.proc setHeroOAM
	pha
    php								; TODO change order and php last
    phy								; save xPos in the stack
    phx								; save dataAddr in the stack

    ldy #$0000						; index in metaprite table
    ldx #$01E0						; OAM offset

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
    lda ($02,s),y
    clc
    adc heroYOffset
	pha								; save it to the stack

	lda heroFlag
	bit #HERO_STATUS_MIRROR_FLAG
	bne blockLoopMirror				; jmp to correct blockLoop code (mirror/normal)

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
	adc heroXOffset                	; add saved Global X Pos
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
	adc heroXOffset                	; add saved Global X Pos
	sec
	sbc #$1e						; remove mirror offset
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

	lda #%10101010
	sta oamData + $21e
	sta oamData + $21f

    plx
	ply
    plp
    pla
    rts
.endproc

;******************************************************************************
;*** animHero *****************************************************************
;******************************************************************************
;*** heroAnimAddr                                                           ***
;*** heroXOffset                                                            ***
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
    lda animFrameCounter
    cmp #$00                        ; first time we do that animation
	beq firstFrame

    dec								; decrement to match count
    cmp (heroAnimAddr),y			; we did all frames for that index
    beq nextFrame

	inc animFrameCounter		; disable this to make it manual on testing

    lda forceRefresh
    cmp #$01
	beq forceRefreshReset

    jmp endAnim

firstFrame:
	lda #$01
    sta animFrameCounter
	lda #$00
	sta animFrameIndex
	bra nextFrameContinue

nextFrame:

    lda #$01
    sta animFrameCounter

    lda animFrameIndex
    inc
    inc
    inc
    sta animFrameIndex

nextFrameContinue:
    tay

    lda (heroAnimAddr),y			; check if we are in a no loop animation
	cmp #$ff
	bne :+

	lda #$00
	sta animFrameIndex
	sta animInProgress
	bra endAnim

:   lda (heroAnimAddr),y
    cmp #$00
    bne noLoop

    lda #$00
    sta animFrameIndex
    sta animInProgress
    bra noLoop

forceRefreshReset:
	lda #$00
	sta forceRefresh

noLoop:
    lda animFrameIndex
	tay
	iny

	rep #$20
	.A16

	lda (heroAnimAddr),y
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	phx								; contains adress of tiles

	inx
	inx								; increment to go to hit offset definition

	; calculate hit offset
	lda heroFlag
	bit HERO_STATUS_MIRROR_FLAG
	bne calculateMirrorHitOffset

calculateNormalHitOffset:
	lda $0000,X
	sta heroHitOffset
	bra :+

calculateMirrorHitOffset:
	inx
	lda $0000,X
	sta heroHitOffset
	bra :++

:	inx
:	inx								; increment offset to go to tiles definition
	ldy heroXOffset					; x Pos
	jsr setHeroOAM

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
	pha
	lda heroFlag
	ora #HERO_STATUS_MIRROR_FLAG
	sta heroFlag
	pla
	rts
.endproc

;*******************************************************************************
;*** setNormalSpriteMode *******************************************************
;*******************************************************************************
;*** set hero sprite in normal mode (face right)                             ***
;*******************************************************************************

.proc setNormalSpriteMode
	pha
	lda heroFlag
	and #<.BITNOT(HERO_STATUS_MIRROR_FLAG)
	sta heroFlag
	pla
	rts
.endproc

;*******************************************************************************
;*** reactHero *****************************************************************
;*******************************************************************************
;*** X contains pad like data                                                ***
;*******************************************************************************

; check that hero is not catched
; 	check if UP is pressed and not in a jump
; 	else check if we are on a jump
; 	else check if DOWN
; 		check if B (kick) -> HERO_DOWN_KICK
; 		else check if X (Punch) -> HERO_DOWN_PUNCH
;       else HERO_DOWN
;   else check if B (kick) -> HERO_KICK
;   else check if X (punch) -> HERO_PUNCH
;   else check if RIGHT -> HERO_WALK
;   else check if LEFT -> HERO_LEFT

; if hero is catched
; finish anim and only handle LEFT/RIGHT to get out

.proc reactHero
	phy
	phx
	pha
	phb

	lda #SPRITE_DATA_BANK			; change data bank to sprite data bank
	pha
	plb

	txa

	;*** Check energy of the enemy ***
	;*********************************

	lda energyPlayer
	cmp #$00
	bne :+
	jsr fallHero
	jmp endHeroPadCheck

:

	;*** Is hero grabbed by an enemy ***
	;***********************************

	_GetHeroGrabFlag
	cmp #$00
	beq checkAnimInProgress

	jsr setShakingFlag				; check if we are shaking and set heroFlag

	;*** Set the good mirror mode for hero sprite ***
	;************************************************

	_CheckHeroMirrorMode			; TODO fix bug with mirror mode and shaking

	ldx heroAnimAddr
	cpx #.LOWORD(heroGrabbed)		; check if current anim is already "heroGrabbed"
	beq :+

	ldx #.LOWORD(heroGrabbed)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter

:	jsr animHero
	jmp endHeroPadCheck

	;*** Is there an animation in progress ***
	;*****************************************

checkAnimInProgress:
	lda animInProgress
	bit #$01						; simple animation in progress
	beq :+
	
	; TODO put here check if we need to end animation earlier
	; TODO check if we are still down after a down animation
	; TODO check if DOWN was pressed while animation

	jsr animHero
	jmp endHeroPadCheck

:	bit #$02						; jump animation in progress
	beq :+

	ldx animationJumpFrameCounter	; set y offset for the jump
	inx
	stx animationJumpFrameCounter
	lda heroYOffset
	sec
	sbc heroJumpOffsetTable,x
	sta heroYOffset

	lda #$01
	sta forceRefresh

	jsr animHero
	jmp endHeroPadCheck
:

	;*** Set the good mirror mode for hero sprite ***
	;************************************************

	_CheckHeroMirrorMode

	;*** Check pad direction ***
	;***************************

	;*** UP ***
	;**********

	lda padFirstPushDataLow1
	bit #PAD_LOW_UP
	beq :++++

	lda padPushDataLow1				; check if it's a jum run
	bit #PAD_LOW_RIGHT				; TODO check why jump table isn't good
	bne :+							; TODO check for timings
	bit #PAD_LOW_LEFT
	beq :++

:	ldx #.LOWORD(heroJumpRun)
	bra :++

:	ldx #.LOWORD(heroJump)
:	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	stz animationJumpFrameCounter
	lda #$02						; jump animation in progress
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

:

	;*** DOWN ***
	;************

	lda padFirstPushDataLow1
	bit #PAD_LOW_DOWN
	beq :+

	ldx #.LOWORD(heroDownStand)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	jsr animHero
	jmp endHeroPadCheck

:   lda padPushDataLow1
	bit #PAD_LOW_DOWN
	beq :++

	;*** We are still down check for KICK or PUNCH ***
	;*************************************************

	lda padFirstPushDataLow1
	bit #PAD_LOW_B
	beq :+

	ldx #.LOWORD(heroDownKick)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

:	lda padFirstPushDataLow1
	bit #PAD_LOW_Y
	beq :+

	ldx #.LOWORD(heroDownPunch)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

	;*** DOWN release we stand up ***
	;********************************

:   lda padReleaseDataLow1
	bit #PAD_LOW_DOWN
	beq :+

	ldx #.LOWORD(heroStand)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	jsr animHero
	jmp endHeroPadCheck

:

	;*** KICK OR PUNCH ***
	;*********************

	lda padFirstPushDataLow1
	bit #PAD_LOW_B
	beq :+

	ldx #.LOWORD(heroStandKick)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

:	lda padFirstPushDataLow1
	bit #PAD_LOW_Y
	beq :+

	ldx #.LOWORD(heroStandPunch)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

	;*** LEFT or RIGHT ***
	;*********************

	lda padFirstPushDataLow1		; check it's first time that we push LEFT or RIGHT
	bit #PAD_LOW_RIGHT
	bne :+							; if we push RIGHT we set heroAnimAddr
	bit #PAD_LOW_LEFT
	beq :++							; if we don't push LEFT for the first time, we check for next test
									; if we push LEFT for the first time, execute next line
:	ldx #.LOWORD(heroWalk)			; set heroWalk address if it's first press
	stx heroAnimAddr

:	lda padPushDataLow1				; check if we push LEFT or RIGHT
	bit #PAD_LOW_RIGHT
	bne :+							; if we push RIGHT we call animHero
	bit #PAD_LOW_LEFT
	beq endHeroPadCheck				; if we don't push LEFT for the first time, we continue
									; if we push LEFT, execute next line

	; TODO need to check boundaries of hero and level
	; check heroXOffset
	lda #LEVEL_SCROLL_LEFT
	sta scrollDirection
	jsr scrollLevel
	bra :++

:	lda #LEVEL_SCROLL_RIGHT
	sta scrollDirection
	jsr scrollLevel

:	jsr animHero					; display next animation frame

endHeroPadCheck:

	plb
	pla
	plx
	ply
	rts
.endproc

;*******************************************************************************
;*** fallHero ******************************************************************
;*******************************************************************************
;*** No parameters                                                           ***
;*******************************************************************************

.proc fallHero
	pha
	phx
	phy
	phb

	rep #$20
	.A16

	lda #$0000

	rep #$10
	sep #$20
	.A8
	.I16

	ldy heroAnimAddr
	cpy #.LOWORD(heroFall)
	beq :+										; hero is already falling

	ldy #.LOWORD(heroFall)
	sty heroAnimAddr
	ldy #$0000
	stz animFrameIndex							; reset animation indexes and counter
	stz animFrameCounter
	stz animationJumpFrameCounter

:	lda animationJumpFrameCounter
	cmp #$1d
	bne :+

	jsr clearHeroSprite
	; TODO make hero loose life and restart level
	bra :+++										; clear hero sprite

:	inc
	sta animationJumpFrameCounter

	lda heroFlag
	bit #HERO_STATUS_MIRROR_FLAG
	bne mirrorMode				; jmp to correct blockLoop code (mirror/normal)

normalMode:
	lda animationJumpFrameCounter
	tax
	lda heroXOffset
	pha											; save original X Offset
	sec
	sbc heroFallXOffset,X
	sta heroXOffset
	bra :+

mirrorMode:
	lda animationJumpFrameCounter
	tax
	lda heroXOffset
	pha											; save original X Offset
	clc
	adc heroFallXOffset,X
	sta heroXOffset

:
	lda heroYOffset
	pha											; save original Y Offset
	clc
	adc heroFallYOffset,X
	sta heroYOffset

	lda #$01
	sta forceRefresh

	jsr animHero

	pla
	sta heroYOffset								; restore original Y Offset
	pla
	sta heroXOffset								; restore original X Offset

:

	plb
	ply
	plx
	pla
	rts
.endproc

;*******************************************************************************
;*** setShakingFlag ************************************************************
;*******************************************************************************
;*** No parameters                                                           ***
;*******************************************************************************

.proc setShakingFlag
	pha

	lda heroFlag
	and #<.BITNOT(HERO_STATUS_SHAKING_FLAG)
	sta heroFlag								; reset shaking flag

	bit #HERO_STATUS_MIRROR_FLAG
	bne checkMirror

checkNormal:

	bit #HERO_STATUS_LAST_SHAKE_DIRECTION_FLAG
	beq :+
	ora #HERO_STATUS_SHAKING_FLAG
	and #<.BITNOT(HERO_STATUS_LAST_SHAKE_DIRECTION_FLAG)
	sta heroFlag
:	bra endCheck

checkMirror:

	bit #HERO_STATUS_LAST_SHAKE_DIRECTION_FLAG
	bne :+
	ora #HERO_STATUS_SHAKING_FLAG
	ora #HERO_STATUS_LAST_SHAKE_DIRECTION_FLAG
	sta heroFlag
:	bra endCheck

endCheck:

	pla
	rts
.endproc
