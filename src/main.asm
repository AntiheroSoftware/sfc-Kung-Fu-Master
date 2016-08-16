;
; Kung Fu Master main
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"
            .include    "snes-sprite.inc"

            .include	"includes/base.inc"
            .include	"includes/hero.inc"
            .include	"includes/ennemy.inc"
            .include	"includes/level.inc"
            .include	"includes/score.inc"

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

            .export 	splashScreen

SPLASH_TILE_ADDR	= $0000
SPLASH_MAP_ADDR     = $1000

.segment "BANK1"

antiheroSplashTiles:
    .incbin "../ressource/splash.pic"

antiheroSplashMap:
    .incbin "../ressource/splash.map"

antiheroSplashPal:
    .incbin "../ressource/splash.clr"

iremSplashTiles:
    .incbin "../ressource/irem.pic"

iremSplashMap:
    .incbin "../ressource/irem.map"

iremSplashPal:
    .incbin "../ressource/irem.clr"

titleScreenTiles:
    .incbin "../ressource/titleScreen.pic"

titleScreenMap:
    .incbin "../ressource/titleScreen.map"

titleScreenPal:
    .incbin "../ressource/titleScreen.clr"

.segment "BSS"

CONTROL_VALUE_NONE				= $00
CONTROL_VALUE_ANTIHERO_SPLASH	= $01
CONTROL_VALUE_IREM_SPLASH 		= $02
CONTROL_VALUE_TITLE_SCREEN 		= $03
CONTROL_VALUE_GAME_START 		= $04

controlValue:
	.res 1

controlNextValue:
	.res 1

fadeOutValue:						; only used in splashScreen so can be reused
	.res 1

splashCounter:						; only used in splashScreen so can be reused
	.res 2

.segment "CODE"

.proc _main

    rep #$10
	sep #$20
	.A8
	.I16

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr initEvents
	jsr initPad

	lda #$01
	sta controlValue

	setINIDSP $0F   				; Enable screen full brightness

	lda #$81        				; Enable NMI + pad reading
	sta CPU_NMITIMEN

infiniteMainLoop:

	lda controlValue
	cmp #CONTROL_VALUE_NONE		; if controlValue is 0 we just wait
	bne checkForAntiheroSplash
	jmp waitForVBlank

checkForAntiheroSplash:

	cmp #CONTROL_VALUE_ANTIHERO_SPLASH
	beq antiheroSplash
	jmp checkForIremSplash

antiheroSplash:

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	setBG1SC SPLASH_MAP_ADDR, $00
	setBG12NBA SPLASH_TILE_ADDR, $0000

	VRAMLoad antiheroSplashTiles, SPLASH_TILE_ADDR, $0980
	VRAMLoad antiheroSplashMap, SPLASH_MAP_ADDR, $800
	CGRAMLoad antiheroSplashPal, $00, $20

	;lda $00
	;sta $2121

	lda #$01        ; setBGMODE(0, 0, 1);
	sta $2105

	lda #$01         ; enable main screen 1
	sta $212c

	lda #$00         ; disable all sub screen
	sta $212d

	jsr splashScreenInit

	lda #.BANKBYTE(splashScreen)
	ldx #.LOWORD(splashScreen)
	ldy #$0000
	jsr addEvent					; add splash event

	setINIDSP $00   				; Enable screen full darkness

	lda #$00
	sta controlValue
	lda #CONTROL_VALUE_IREM_SPLASH
	sta controlNextValue
	jmp waitForVBlank

checkForIremSplash:
	cmp #CONTROL_VALUE_IREM_SPLASH
	beq iremSplash
	jmp checkForTitleScreen

iremSplash:

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	setBG1SC SPLASH_MAP_ADDR, $00
	setBG12NBA SPLASH_TILE_ADDR, $0000

	VRAMLoad iremSplashTiles, SPLASH_TILE_ADDR, $0980
	VRAMLoad iremSplashMap, SPLASH_MAP_ADDR, $800
	CGRAMLoad iremSplashPal, $00, $20

	jsr splashScreenInit

	lda #.BANKBYTE(splashScreen)
	ldx #.LOWORD(splashScreen)
	ldy #$0000
	jsr addEvent					; add splash event

	setINIDSP $00   				; Enable screen full darkness

	lda #$00
	sta controlValue
	lda #CONTROL_VALUE_TITLE_SCREEN
	sta controlNextValue
	jmp waitForVBlank

checkForTitleScreen:

	cmp #CONTROL_VALUE_TITLE_SCREEN
	beq titleScreen
	jmp waitForVBlank

titleScreen:

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	setBG1SC SPLASH_MAP_ADDR, $00
	setBG12NBA SPLASH_TILE_ADDR, $0000

	VRAMLoad titleScreenTiles, SPLASH_TILE_ADDR, $14C0
	VRAMLoad titleScreenMap, SPLASH_MAP_ADDR, $800
	CGRAMLoad titleScreenPal, $00, $20

	lda #HERO_TITLE_SCREEN_Y_OFFSET
	jsr initHeroSprite
	jsr initEnnemySprite

	lda #$11         				; enable main screen 1 +sprite
	sta $212c

	; set the event that copy OAM data
	lda #.BANKBYTE(copyOAMEvent)
	ldx #.LOWORD(copyOAMEvent)
	ldy #$0000
	jsr addEvent

	; set the event that trasnfer hero tile data
	lda #.BANKBYTE(transferHeroSpriteDataEvent)
	ldx #.LOWORD(transferHeroSpriteDataEvent)
	ldy #$0001
	jsr addEvent

	setINIDSP $0f   				; Enable screen full darkness

	lda #CONTROL_VALUE_NONE
	sta controlValue
	lda #CONTROL_VALUE_GAME_START
	sta controlNextValue

infiniteLoop:

checkForGameStart:

	jsr checkPressStart

	lda controlValue
	cmp #CONTROL_VALUE_GAME_START
	beq gameStart

	ldx padPushData1
	jsr reactHero

	wai
	bra infiniteLoop

gameStart:

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr initEvents					; reset events

	jsr initLevel
	jsr initScore

	lda #HERO_GAME_SCREEN_Y_OFFSET
	jsr initHeroSprite

	; set the event that copy OAM data
	lda #.BANKBYTE(copyOAMEvent)
	ldx #.LOWORD(copyOAMEvent)
	ldy #EVENT_GAME_SCREEN_COPY_OAM
	jsr addEvent

	; set the event that trasnfer hero tile data
	lda #.BANKBYTE(transferHeroSpriteDataEvent)
	ldx #.LOWORD(transferHeroSpriteDataEvent)
	ldy #EVENT_GAME_SCREEN_TRANSFER_HERO_SPRITE_DATA
	jsr addEvent

	setINIDSP $0f   				; Enable screen full brightness

	lda #$81        				; Enable NMI + pad reading
	sta CPU_NMITIMEN

	lda #CONTROL_VALUE_NONE
	sta controlValue
	lda #CONTROL_VALUE_NONE
	sta controlNextValue

gameStartInfiniteLoop:

	ldx padPushData1
	jsr reactHero

	jsr updateTime

	wai
	bra gameStartInfiniteLoop

waitForVBlank:
	wai
	jmp infiniteMainLoop

.endproc

.proc checkPressStart

	pha
	php

	lda padPushData1
	bit #PAD_START
	beq exit

	lda controlNextValue
	sta controlValue

exit:

	plp
	pla
	rts

.endproc

.proc _IRQHandler
    rts
.endproc

.proc _NMIHandler
	jsr readPad1
	jsr processEvents
    rts
.endproc

.proc _preInit
    rts
.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.proc splashScreenInit
	php
	phx
	pha

	rep #$10
	sep #$20
	.A8
	.I16

	ldx #$0000
	stx splashCounter

	lda #$0f
	sta fadeOutValue

	pla
	plx
	plp
	rts

.endproc

.proc splashScreen
	php
	phx

	;tax 							; put A reg containing counter in X reg

	ldx splashCounter

	rep #$10
	sep #$20
	.A8
	.I16

	cpx #$0140
	bpl exit

	cpx #$0120
	bpl waitMore

	cpx #$0100
	bpl doFadeOut

	cpx #$0010
	bpl waitToFadeOut

	txa
	sta PPU_INIDSP
	bra continue

waitToFadeOut:

	lda padPushData1
	bit #PAD_START
	bne fadeOut						; check if START is pressed to fade out

	jmp continue

fadeOut:

	ldx #$0100
	stx splashCounter

doFadeOut:

	lda fadeOutValue
	sta PPU_INIDSP
	dec
	sta fadeOutValue
	cmp #$ff
	bne continue

waitMore:
	jmp continue

exit:
	lda controlNextValue
	sta controlValue

	lda #$00                        ; exit event value
	bra return

continue:
	lda #$01                        ; continue event value

	ldx splashCounter
	inx
	stx splashCounter

return:
	plx
	plp
	rtl
.endproc

.proc copyOAMEvent
    php

    rep #$10
    sep #$20
    .A8
    .I16

    jsr copyOAM
    lda #$01                        ; continue event value
    plp
    rtl
.endproc