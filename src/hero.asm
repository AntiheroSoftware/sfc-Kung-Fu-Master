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

            .import 	playGame
            .import 	gameHeroDie

            .export 	initHeroSprite
            .export 	clearHeroSprite
            .export 	transferHeroSpriteDataEvent
			.export 	reactHero
			.export		spriteCounter
			.export 	heroXOffset
			.export 	heroFlag
			.export 	heroHitOffset
			.export 	heroHitZone
			.export 	heroHitType

			.export setMirrorSpriteMode
			.export setNormalSpriteMode
			.export setShakingFlag
			.export fallHero
			.export setHeroOAM
			.export animHero
			.export clearHeroSprite
			.export heroDownKick2
			.export heroStandKick2
			.export heroDownPunch1
			.export heroDownPunch3
			.export animInProgress
			.export heroAnimInterruptCounter
			.export heroTransferAddr

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

heroAnimInterruptCounter:			; number of frames after wich animation can be interrupted
	.res 1							; if a new button have been pressed

heroYOffset:
	.res 1

heroXOffset:
	.res 2

heroHitOffset:
	.res 1

heroHitZone:
	.res 1

heroHitType:
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

	lda #%00100000
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

	lda #%01100000
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
;*** No register are used													***
;*** This function use heroAnimAddr, animFrameCounter, animFrameIndex		***
;*** and some more                                                          ***
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

	ldx #$0000						; clear high byte of A register
	txa

	rep #$10
	sep #$20
	.A8
	.I16

    lda animFrameIndex
    tay								; set index for getting animation frames (counter/address) into Y register

    lda animFrameCounter
    cmp #$00                        ; first time we do that animation
	beq firstFrame

    dec								; decrement to match count
    cmp (heroAnimAddr),y			; we did all frames for that index
    beq nextFrame

	inc animFrameCounter			; <DEBUG> disable this to make it manual on testing
	lda heroAnimInterruptCounter	; load and update "AnimInterruptCounter"
	dec
	cmp #$ff						; if value is greater than 0 we don't touch it
	bne :+
	lda #$00						; else we force to 0
:	sta heroAnimInterruptCounter	; store the new value

    lda forceRefresh
    cmp #$01						; check if forceResfresh is needed
	beq forceRefreshReset			; skip to force refresh

    jmp endAnim						; we are all done here, we can exit the fonction

firstFrame:

	;*** setup frame counter and index for the beginning of the animation
	;***********************************************************************

	ldy #$0000
	lda (heroAnimAddr),Y			; get and set the counter where we will be able
	sta heroAnimInterruptCounter	; to interrupt the animation

	lda #$01
    sta animFrameCounter
	lda #$01						; set to 1 so we skip "AnimInterruptCounter" info
	sta animFrameIndex
	bra nextFrameContinue			; continue to to handle the frame

nextFrame:

    lda #$01
    sta animFrameCounter			; reset frame counter to 1

    lda animFrameIndex				; load frame index
    inc								; skip counter
    inc								; skip high byte of frame address
    inc								; skip low byte of frame address
    sta animFrameIndex				; store new frame index

nextFrameContinue:

    tay								; set index for getting animation frames into Y register

    lda (heroAnimAddr),y			; check if we are in a no loop animation
	cmp #$ff
	bne :+

	lda #$01						; we are at the end of the animation
	sta animFrameIndex				; we reset the counter
	lda #$00
	sta animInProgress
	bra endAnim						; we exit the animation

:   lda (heroAnimAddr),y
    cmp #$00
    bne noLoop

    lda #$01						; we are in a loop
    sta animFrameIndex				; reset the index
    lda #$00
    sta animInProgress
    bra noLoop						; ... and continue

forceRefreshReset:
	lda #$00
	sta forceRefresh				; reset force refresh

noLoop:
    lda animFrameIndex
	tay
	iny

	rep #$20
	.A16

	lda (heroAnimAddr),y			; get adress of the frame to display
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	phx								; contains adress of tiles TODO check if really usefull

	inx
	inx								; increment to go to hit offset definition

	lda $820000,X
	and #$c0
	clc
	rol
	rol
	rol
	sta heroHitZone

	lda $820000,X
	and #$3f
	sta heroHitType

	inx

	;*** calculate hit offset
	;***************************

	lda heroFlag
	bit HERO_STATUS_MIRROR_FLAG
	bne calculateMirrorHitOffset

calculateNormalHitOffset:
	lda $820000,X
	sta heroHitOffset
	bra :+

calculateMirrorHitOffset:
	inx
	lda $820000,X
	sta heroHitOffset
	bra :++

:	inx
:	inx								; increment offset to go to tiles definition
	ldy heroXOffset					; Y register contains heroXOffset
	jsr setHeroOAM

	jsr OAMDataUpdated

	rep #$20
	.A16

	ldy #$0000
	lda ($01,s),y					; get adress of tile data for the frame to display
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
	cmp #$00						; check if player energy is 0
	bne heroStillHaveEnergy
	jsr fallHero					; if so we make it fall
	jmp endHeroPadCheck				; nothing else to do we skip pad check

heroStillHaveEnergy:

	;*** Is hero grabbed by an enemy ***
	;***********************************

	_GetHeroGrabFlag
	cmp #$00						; check if hero is grabbed
	beq heroIsNotGrabbed

	jsr setShakingFlag				; check if we are shaking and set heroFlag

	;*** Set the good mirror mode for hero sprite ***
	;************************************************

	_CheckHeroMirrorMode			; TODO fix bug with mirror mode and shaking

	ldx heroAnimAddr
	cpx #.LOWORD(heroGrabbed)		; check if current anim is already "heroGrabbed"
	beq :+

	ldx #.LOWORD(heroGrabbed)		; set "heroGrabbed" animation
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter

:	jsr animHero
	jmp endHeroPadCheck

heroIsNotGrabbed:

	;*** Is there an animation in progress ***
	;*****************************************

	lda animInProgress
	bit #$01						; simple animation in progress
	beq :+							; go check if it's a an other type of animation

	;*** Check if DOWN is first pressed if it's the case we
	;*** clear down first pressed so it can be triggered when
	;*** animation is over
	;************************************************************

	lda padFirstPushDataLow1
	bit #PAD_LOW_DOWN				; check if DOWN button is pressed
	beq skipCheckDownPressed		; if DOWN is not pressed we continue

	lda padPushDataLow1				; we leave first push DOWN button
	and #%11111011					; but reset push data so it can
	sta padPushDataLow1				; trigger first push DOWN later

skipCheckDownPressed:

	;*** Check if DOWN is released if it's the case we
	;*** clear down released so it can be triggered when
	;*** animation is over
	;************************************************************

	lda padReleaseDataLow1
	bit #PAD_LOW_DOWN				; check if DOWN button is released
	beq skipCheckDownReleased		; if DOWN is not released we continue

	lda padPushDataLow1				; make like if DOWN was still pressed
	ora #%00000100					; so it can be released later
	sta padPushDataLow1

skipCheckDownReleased:

	;*** if LEFT or RIGHT are pressed during an animation
	;*** we and even if it's not the first time we act
	;*** like as if it was the first time
	;*******************************************************

	lda padPushDataLow1
	and #%00000011
	ora padFirstPushDataLow1
	sta padFirstPushDataLow1

	;*** Check if kick or punch are currently in a good frame
	;*** to trigger a new animation
	;**********************************************************

	lda heroAnimInterruptCounter	; check if we can interrupt the animation
	cmp #$00						; in case a new buttun is pressed
	bne skipCheckInterrupt

checkInterruptKickButtonPressed:
	lda padFirstPushDataLow1
	bit #PAD_LOW_B					; check if B button is pressed (B is for Kick)
	beq checkInterruptPunchButtonPressed

	bra checkPadDirection			; Go check with new animation we can trigger

checkInterruptPunchButtonPressed:
	lda padFirstPushDataLow1
	bit #PAD_LOW_Y					; check if Y button is pressed (Y is for Punch)
	beq skipCheckInterrupt

	bra checkPadDirection			; Go check with new animation we can trigger

skipCheckInterrupt:

	jsr animHero
	jmp endHeroPadCheck

:	bit #$02						; jump animation in progress
	beq checkPadDirection

;	bit #$04						; jump run animation in progress
;	beq checkPadDirection

	xba
	lda #$00						; clear high byte of A register
	xba

	lda animationJumpFrameCounter	; set y offset for the jump
	inc
	sta animationJumpFrameCounter
	tax

	lda heroYOffset
	pha								; save heroYOffset

	sec
	sbc heroJumpOffsetTable,x		; TODO use right jumprun table if needed
	sta heroYOffset

	lda #$01
	sta forceRefresh

	jsr animHero

	pla								; restore heroYOffset
	sta heroYOffset

	jmp endHeroPadCheck

checkPadDirection:

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
	bit #PAD_LOW_RIGHT
	bne :+
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


checkIfDownRelease:

	;*** DOWN release we stand up
	;*******************************

    lda padReleaseDataLow1
	bit #PAD_LOW_DOWN
	beq checkIfDownFirstTime

	bit #(PAD_LOW_B | PAD_LOW_Y)
	bne checkIfKickOrPunch

	ldx #.LOWORD(heroStand)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	jsr animHero
	jmp endHeroPadCheck

checkIfDownFirstTime:

	;*** DOWN first time
	;**********************

	lda padFirstPushDataLow1		; Check if DOWN is pressed for the first time
	bit #PAD_LOW_DOWN
	beq checkIfStillDown

	;*** check if KICK or PUNCH is pressed too
	;********************************************

	bit #(PAD_LOW_B | PAD_LOW_Y)
	bne checkIfDownKickOrPunch

	;*** no action, we just stand down
	;************************************

	ldx #.LOWORD(heroDownStand)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	jsr animHero
	jmp endHeroPadCheck

checkIfStillDown:

    lda padPushDataLow1				; Check if is DOWN is still pressed
	bit #PAD_LOW_DOWN
	beq checkIfKickOrPunch

checkIfDownKickOrPunch:

	;*** We are still down check for KICK or PUNCH ***
	;*************************************************

checkIfDownKick:

	lda padFirstPushDataLow1
	bit #PAD_LOW_B
	beq checkIfDownPunch

	ldx #.LOWORD(heroDownKick)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

checkIfDownPunch:

 	lda padFirstPushDataLow1
	bit #PAD_LOW_Y
	beq downCheckFinished

	ldx #.LOWORD(heroDownPunch)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

downCheckFinished:
	jmp endHeroPadCheck

checkIfKickOrPunch:

	;*** KICK OR PUNCH
	;********************

checkIfKick:

	lda padFirstPushDataLow1
	bit #PAD_LOW_B
	beq checkIfPunch

	ldx #.LOWORD(heroStandKick)
	stx heroAnimAddr
	stz animFrameIndex
	stz animFrameCounter
	lda #$01
	sta animInProgress
	jsr animHero
	jmp endHeroPadCheck

checkIfPunch:

	lda padFirstPushDataLow1
	bit #PAD_LOW_Y
	beq checkIfLeftOrRight

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

checkIfLeftOrRight:

	ldx #.LOWORD(heroWalk)			; set heroWalk address if it's first press
	stx heroAnimAddr

	lda padPushDataLow1				; check if we push LEFT or RIGHT
	bit #PAD_LOW_RIGHT
	bne levelScrollRight			; if we push RIGHT we call animHero
	bit #PAD_LOW_LEFT
	beq levelNoScroll				; if we don't push LEFT, we continue
									; if we push LEFT, execute next line

levelScrollLeft:

	;*** TODO need to check boundaries of hero and level
	;*** check heroXOffset
	;******************************************************

	lda #LEVEL_SCROLL_LEFT
	sta scrollDirection
	jsr scrollLevel
	bra animate

levelScrollRight:

	lda #LEVEL_SCROLL_RIGHT
	sta scrollDirection
	jsr scrollLevel

animate:

	jsr animHero					; display next animation frame
	bra endHeroPadCheck

levelNoScroll:

	lda #LEVEL_SCROLL_NONE
	sta scrollDirection

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

	xba								; clear high byte of A register
	lda #$00
	xba

	ldy heroAnimAddr
	cpy #.LOWORD(heroFall)
	beq :+							; hero is already falling

	ldy #.LOWORD(heroFall)
	sty heroAnimAddr
	ldy #$0000
	stz animFrameIndex				; reset animation indexes and counter
	stz animFrameCounter
	stz animationJumpFrameCounter

:	lda animationJumpFrameCounter
	cmp #$1d
	bne :+

	jsr clearHeroSprite				; clear hero sprite
	lda livesCounter
	dec
	jsr setLiveCounter				; update live counter

	; We state to the main loop that the hero is dead
	lda #$01
	sta gameHeroDie

	bra :+++

:	inc
	sta animationJumpFrameCounter

	lda heroFlag
	bit #HERO_STATUS_MIRROR_FLAG
	bne mirrorMode					; jmp to correct blockLoop code (mirror/normal)

normalMode:
	lda animationJumpFrameCounter
	tax
	lda heroXOffset
	pha								; save original X Offset
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
