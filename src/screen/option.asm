;
; Kung Fu Master option screen
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
            .include	"../includes/font.inc"
			.include	"../includes/cursor.inc"
			.include	"../includes/screen.inc"
			.include	"../includes/hero.inc"
			.include	"../includes/settings.inc"

            .export 	optionScreen
            .import 	titleScreenReload

            .import 	titleScreenTiles
            .import 	titleScreenMap
            .import 	titleScreenPal

            .export optionsString
            .export optionExitString
            .export updateDifficulty
            .export difficultyPtrList

OPTION_TILE_ADDR	= $0000
OPTION_MAP_ADDR     = $1000

.segment "RODATA"

;******************************************************************************
;*** structure of cursor data *************************************************
;******************************************************************************
;*** xpos			word													***
;*** ypos			byte													***
;*** dstBank		byte													***
;*** dstAddr		word													***
;*** previousOffset	byte													***
;*** nextOffset		byte													***
;******************************************************************************

optionCursorList:
	.word $0020
	.byte $53
	.byte .BANKBYTE(updateDifficulty)
	.word .LOWORD(updateDifficulty)
	.byte $20
	.byte $08

	.word $0020
	.byte $63
	.byte .BANKBYTE(updateLives)
	.word .LOWORD(updateLives)
	.byte $00
	.byte $10

	.word $0020
	.byte $73
	.byte .BANKBYTE(updateContinue)
	.word .LOWORD(updateContinue)
	.byte $08
	.byte $18

	.word $0020
	.byte $83
	.byte .BANKBYTE(updateSound)
	.word .LOWORD(updateSound)
	.byte $10
	.byte $20

	.word $0020
	.byte $93
	.byte .BANKBYTE(returnToTitleScreen)
	.word .LOWORD(returnToTitleScreen)
	.byte $18
	.byte $00

difficultyPtrList:
	.word .LOWORD(difficultyEasyString)
	.word .LOWORD(difficultyNormalString)
	.word .LOWORD(difficultyHardString)
	.word .LOWORD(difficultyMasterString)
	.word $0000

difficultyEasyString:
	.byte $02," EASY ",$00
difficultyNormalString:
	.byte $02,"NORMAL",$00
difficultyHardString:
	.byte $02," HARD ",$00
difficultyMasterString:
	.byte $02,"MASTER",$00

livesPtrList:
	.word .LOWORD(lives3String)
	.word .LOWORD(lives5String)
	.word .LOWORD(lives7String)
	.word $0000

lives3String:
	.byte $02,"3",$00
lives5String:
	.byte $02,"5",$00
lives7String:
	.byte $02,"7",$00

continuePtrList:
	.word .LOWORD(continue3String)
	.word .LOWORD(continue5String)
	.word .LOWORD(continue7String)
	.word $0000

continue3String:
	.byte $02,"3",$00
continue5String:
	.byte $02,"5",$00
continue7String:
	.byte $02,"7",$00

soundPtrList:
	.word .LOWORD(soundStereoString)
	.word .LOWORD(soundMonoString)
	.word $0000

soundStereoString:
	.byte $02,"STEREO",$00
soundMonoString:
	.byte $02," MONO ",$00

.segment "BSS"

.segment "CODE"

.A8
.I16

optionsString:
    .byte $01,"DIFFICULTY ",$02,"< NORMAL >",$01,$0a,$0a
    .byte $01,"LIVES      ",$02,"< 3 >",$01,$0a,$0a
    .byte $01,"CONTINUE   ",$02,"< 3 >",$01,$0a,$0a
    .byte $01,"SOUND      ",$02,"< STEREO >",$01,$0a,$0a
optionExitString:
    .byte $01,"EXIT",$00

.proc optionScreen

	jsr removeAllEvent

	setBG1SC OPTION_MAP_ADDR, $00
	setBG12NBA OPTION_TILE_ADDR, $0000

	;*** Font data loading ***
	;*************************

	lda #$01
	ldx #OPTION_MAP_ADDR
	ldy #$008d
	jsr initFont

	ldx #.LOWORD(screenBuffer)
	jsr initFontBuffer

	ldx #$000c
	ldy #$000a
	jsr setFontCursorPosition

	lda #$01
	ldx #$0009
	ldy #$0005
	jsr clearFontZone

	ldx #$0007
	ldy #$000b
	jsr setFontCursorPosition

	ldx #.LOWORD(optionsString)
	jsr writeFontString

	;*** End of font stuff ***
	;*************************

	lda #$11         				; enable main screen 1 +sprite
	sta $212c

	ldx #.LOWORD(optionCursorList)
	jsr initCursor

	; set the event that copy OAM data
	lda #.BANKBYTE(copyOAMEvent)
	ldx #.LOWORD(copyOAMEvent)
	ldy #$0000
	jsr addEvent

	; set the event that handle knife cursor
	lda #.BANKBYTE(cursorEvent)
	ldx #.LOWORD(cursorEvent)
	ldy #$0001
	jsr addEvent

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0002
	jsr addEvent

	; clear hero sprite
	jsr clearHeroSprite
	jsr OAMDataUpdated

infiniteLoop:

	lda cursorTargetSet
	cmp #$01
	bne skipToWait

jump:
	stz cursorTargetSet
	ldx #$0000
	jsr (cursorTarget,X)

skipToWait:
	wai
	bra infiniteLoop

.endproc

;******************************************************************************
;*** updateDifficulty *********************************************************
;******************************************************************************

.proc updateDifficulty
	pha
	phx
	phy
	php

	lda settingsDifficultyIndex
	; TODO currently next is the only implemented
	inc

	rep #$20
    .A16

    and #$00ff
    tax
    asl
    tay

    sep #$20
	.A8

	lda difficultyValueList,X
	cmp #$00
	bne store

	ldx #$0000
	ldy #$0000
	lda difficultyValueList,X

store:
	sta settingsDifficultyValue
	txa
	sta settingsDifficultyIndex

display:
	phy
	ldx #$0014
	ldy #$000b
	jsr setFontCursorPosition

	jsr disableSkipSpaces

	ply
	ldx difficultyPtrList,Y
	jsr writeFontString

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0002
	jsr addEvent

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** updateLives **************************************************************
;******************************************************************************

.proc updateLives
  	pha
  	phx
  	phy
  	php

  	lda settingsLivesIndex
  	; TODO currently next is the only implemented
  	inc

  	rep #$20
	  .A16

	  and #$00ff
	  tax
	  asl
	  tay

	  sep #$20
	.A8

	lda livesValueList,X
	cmp #$00
	bne store

	ldx #$0000
	ldy #$0000
	lda livesValueList,X

store:
	sta settingsLivesValue
	txa
	sta settingsLivesIndex

display:
	phy
	ldx #$0014
	ldy #$000d
	jsr setFontCursorPosition

	jsr disableSkipSpaces

	ply
	ldx livesPtrList,Y
	jsr writeFontString

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0002
	jsr addEvent

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** updateContinue ***********************************************************
;******************************************************************************

.proc updateContinue
	pha
	phx
	phy
	php

	lda settingsContinueIndex
	; TODO currently next is the only implemented
	inc

	rep #$20
	.A16

	and #$00ff
	tax
	asl
	tay

	sep #$20
	.A8

	lda continueValueList,X
	cmp #$00
	bne store

	ldx #$0000
	ldy #$0000
	lda continueValueList,X

store:
	sta settingsContinueValue
	txa
	sta settingsContinueIndex

display:
	phy
	ldx #$0014
	ldy #$000f
	jsr setFontCursorPosition

	jsr disableSkipSpaces

	ply
	ldx continuePtrList,Y
	jsr writeFontString

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0002
	jsr addEvent

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** updateSound **************************************************************
;******************************************************************************

.proc updateSound
  	pha
  	phx
  	phy
  	php

  	lda settingsSoundIndex
  	; TODO currently next is the only implemented
  	inc

  	rep #$20
	.A16

	and #$00ff
	tax
	asl
	tay

	sep #$20
	.A8

	lda soundValueList,X
	cmp #$00
	bne store

	ldx #$0000
	ldy #$0000
	lda soundValueList,X

store:
	sta settingsSoundValue
	txa
	sta settingsSoundIndex

display:
	phy
	ldx #$0014
	ldy #$0011
	jsr setFontCursorPosition

	jsr disableSkipSpaces

	ply
	ldx soundPtrList,Y
	jsr writeFontString

	; set the event that copy the buffer to VRAM only once
	lda #.BANKBYTE(copyFontBufferToVRAMOnceEvent)
	ldx #.LOWORD(copyFontBufferToVRAMOnceEvent)
	ldy #$0002
	jsr addEvent

	plp
	ply
	plx
	pla
	rts
.endproc

;******************************************************************************
;*** returnToTitleScreen ******************************************************
;******************************************************************************

.proc returnToTitleScreen
  pla ; remove return address from stack
  pla
  jmp titleScreenReload
.endproc
