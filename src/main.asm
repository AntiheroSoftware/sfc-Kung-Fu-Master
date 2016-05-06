;
; Kung Fu Master main
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .include    "snes.inc"
            .include    "snes-pad.inc"
            .include    "snes-event.inc"

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

            .export 	splashScreen

SPLASH_TILE_ADDR	= $1000
SPLASH_MAP_ADDR     = $0000

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

controlValue:
	.res 1

controlNextValue:
	.res 1

fadeOutValue:
	.res 1

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

	lda #$80        				; Enable NMI
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

	lda $00
	sta $2121

	lda #$01        ; setBGMODE(0, 0, 1);
	sta $2105

	lda #$01         ; enable main screen 1
	sta $212c

	lda #$00         ; disable all sub screen
	sta $212d

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

	setINIDSP $0f   				; Enable screen full darkness

	lda #CONTROL_VALUE_NONE
	sta controlValue
	lda #CONTROL_VALUE_NONE
	sta controlNextValue
	jmp waitForVBlank

waitForVBlank:
	wai
	jmp infiniteMainLoop

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

.proc splashScreen
	php
	phx

	tax 							; put A reg containing counter in X reg

	rep #$10
	sep #$20
	.A8
	.I16

	cpx #$0010
	bpl waitToFadeOut

	txa
	sta PPU_INIDSP
	bra continue

waitToFadeOut:

	cpx #$0100
	bpl fadeOut						; wait time is over -> fade out

	lda padPushData1
	bit #PAD_START
	bne fadeOut						; check if START is pressed to fade out

	jmp continue

fadeOut:

	cpx #$0100
	bne doFadeOut

	lda #$0f
	sta fadeOutValue

doFadeOut:

	lda fadeOutValue
	sta PPU_INIDSP
	dec
	sta fadeOutValue
	cmp #$ff
	bne continue

exit:
	lda controlNextValue
	sta controlValue

	lda #$00                        ; exit event value
	bra return

continue:
	lda #$01                        ; continue event value

return:
	plx
	plp
	rtl
.endproc