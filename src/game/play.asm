;
; Kung Fu Master play game
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-pad.inc"
			.include    "snes-event.inc"
			.include    "snes-sprite.inc"

			.include	"../includes/base.inc"
			.include	"../includes/events.inc"
			.include	"../includes/hero.inc"
			.include	"../includes/enemy.inc"
			.include	"../includes/enemyStrategy.inc"
			.include	"../includes/level.inc"
			.include	"../includes/score.inc"
			.include	"../includes/hit.inc"
			.include	"../includes/font.inc"

			.export 	playGame
			.export 	spriteTrickIRQVTimer
			.export 	spriteTrickIRQValue
			.export 	spriteTrickIndex

.segment "BSS"

gamePaused:
	.res 1

gamePausedUpdated:
	.res 1

.segment "ZEROPAGE"

spriteTrickIndex:
	.res 2

.segment "RODATA"

spriteTrickIRQVTimer:
	.byte $00, $90, $a0, $b0

spriteTrickIRQValue:
	.byte %00000001
	.byte %00001001
	.byte %00010001
	.byte %00011001

.segment "CODE"

.A8
.I16

.proc playGame

	setINIDSP $80   				; Enable forced VBlank during DMA transfer
	stz CPU_NMITIMEN				; Disable NMI and pad reading

	lda #$00
	sta gamePaused					; init game pause values
	sta gamePausedUpdated

	jsr initEvents					; reset events

	jsr initLevel
	jsr initScore

	;*** Font data loading ***
	;*************************

	VRAMLoad fontTiles, $7590, $0800
	CGRAMLoad gameMessagePal, $70, $20

	lda #$07
	ldx #$7C00 						; todo put reference from an include SCORE_MAP_ADDR
	ldy #$0059
	jsr initFont

	jsr disableSkipSpaces

;	ldx #$0007
;	ldy #$000b
;	jsr setFontCursorPosition

;	ldx #.LOWORD(onePlayerFirstFloorString)
;	jsr writeFontString

;	ldx #$000c
;	ldy #$000e
;	jsr setFontCursorPosition

;	ldx #.LOWORD(readyString)
;	jsr writeFontString

;	ldx #$000c
;	ldy #$000e
;	jsr setFontCursorPosition

;	lda #$00
;	ldx #$0007
;	ldy #$0002
;	jsr clearFontZone

	;*** End of font stuff ***
	;*************************

	lda #HERO_GAME_SCREEN_Y_OFFSET
	jsr initHeroSprite
	jsr initEnemySprite
	jsr hitInit
	jsr enemyStrategyInit

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

	; set the event that display game paused message
	lda #.BANKBYTE(gamePauseMessageEvent)
	ldx #.LOWORD(gamePauseMessageEvent)
	ldy #EVENT_GAME_SCREEN_PAUSE_MESSAGE
	jsr addEvent

	ldx #$00FF						; IRQ init
	sta $4207
	ldx #$0000
	sta $4209

	ldx #$0000
	stx spriteTrickIndex			; end of IRQ init

	lda #$B1        				; Enable NMI + IRQ + pad reading
	sta CPU_NMITIMEN

	wai 							; Wait at least one NMI interrupt before setting full brightness

	setINIDSP $0f   				; Enable screen full brightness

gameStartInfiniteLoop:

	lda padFirstPushData1
	bit #PAD_START
	beq noStartPressed

	lda gamePaused
	eor #$01
	sta gamePaused

	lda #$01
	sta gamePausedUpdated

noStartPressed:

	lda gamePaused
	cmp #$01						; check if game paused
	bne gameStartContinue

	wai
	wai
	wai
	wai
	wai								; Wait for 4 IRQ and NMI to happen

	bra gameStartInfiniteLoop

gameStartContinue:

	jsr updateTime

	ldx padPushData1
	jsr reactHero

	jsr reactEnemy

	jsr hitProcess

	jsr enemyStrategyGrab

	wai
	wai
	wai
	wai
	wai								; Wait for 4 IRQ and NMI to happen

	bra gameStartInfiniteLoop

.endproc

;******************************************************************************
;*** Events *******************************************************************
;******************************************************************************

.proc gameStartMessageEvent

.endproc

.proc gamePauseMessageEvent
	php

	lda gamePausedUpdated
	cmp #$01
	bne noUpdate

	lda #$00
	sta gamePausedUpdated

	lda gamePaused
	cmp #$01
	bne removeGamePausedMessage

displayGamePausedMessage:

	ldx #$0009
	ldy #$000b
	jsr setFontCursorPosition

	ldx #.LOWORD(gamePausedString)
	jsr writeFontString

	bra noUpdate

removeGamePausedMessage:

	ldx #$0009
	ldy #$000b
	jsr setFontCursorPosition

	lda #$00
	ldx #$000d
	ldy #$0003
	jsr clearFontZone

noUpdate:
	lda #$01                        ; continue event value

	plp
	rtl
.endproc