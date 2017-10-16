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
            .include	"includes/enemy.inc"
            .include	"includes/enemyStrategy.inc"
            .include	"includes/level.inc"
            .include	"includes/score.inc"
            .include	"includes/hit.inc"
            .include	"includes/snesgss.inc"
            .include	"includes/font.inc"
            .include	"includes/highScore.inc"
            .include	"includes/cursor.inc"
            .include	"includes/settings.inc"

            .forceimport	__STARTUP__

            .export     _main
            .export     _IRQHandler
            .export     _NMIHandler
            .export     _preInit

            .import 	antiheroSplash

            .import 	spriteTrickIRQVTimer
            .import 	spriteTrickIRQValue
            .importzp 	spriteTrickIndex

MAIN_DATA_BANK = $00

.segment "CODE"

.proc _main

    rep #$10
	sep #$20
	.A8
	.I16

	setINIDSP $80   				; Enable forced VBlank during DMA transfer

	jsr initEvents
	jsr initPad

	;**************************************************************************
	;*** SNESGSS music play ***************************************************
	;**************************************************************************

	jsl gss_init
	jsl gss_setStereo				; buggy if called when in fastrom mode
	lda #$00
	jsl gss_playTrack

	;**************************************************************************
	;*** Settings init ********************************************************
	;**************************************************************************
	jsr initSettings

	;*** Enable fastrom after music set ***
	;**************************************

	lda #$01
    sta $420d

	setINIDSP $0F   				; Enable screen full brightness

	lda #$81        				; Enable NMI + pad reading
	sta CPU_NMITIMEN

	jmp antiheroSplash

.endproc

;*** Old debugging traces ***
;****************************

; .export 	_gameStart = _main::gameStart
; .export 	_checkForGameStart = _main::checkForGameStart
; .export 	_checkForTitleScreen = _main::checkForTitleScreen
;.export 	_gameStartIntro = _main::gameStartIntro
;.export 	_jump = _main::jump

.proc _IRQHandler
	pha
	phx
	php
	phb

	rep #$10
	sep #$20
	.A8
	.I16

	lda #MAIN_DATA_BANK
	pha
	plb

	lda $4211           ; clear interrupt flag

	ldx spriteTrickIndex
	lda spriteTrickIRQValue,X
	sta $2101

	inx
	cpx #$04
	bne :+

	ldx #$0000

:	stx spriteTrickIndex
	lda spriteTrickIRQVTimer,X
	sta $4209

	plb
	plp
	plx
	pla
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