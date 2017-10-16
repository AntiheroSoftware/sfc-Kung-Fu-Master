;
; Kung Fu Master settings
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"

            .export 	initSettings
            .export 	settingsDifficultyIndex
            .export 	settingsLivesIndex
            .export 	settingsContinueIndex
            .export 	settingsSoundIndex
            .export 	settingsDifficultyValue
			.export 	settingsLivesValue
			.export 	settingsContinueValue
			.export 	settingsSoundValue
			.export 	difficultyValueList
			.export 	livesValueList
			.export 	continueValueList
			.export 	soundValueList

SETTINGS_DIFFICULTY_DEFAULT_INDEX 	= $01
SETTINGS_LIVES_DEFAULT_INDEX 		= $00
SETTINGS_CONTINUE_DEFAULT_INDEX 	= $00
SETTINGS_SOUND_DEFAULT_INDEX 		= $00

.segment "RODATA"

difficultyValueList:
	.byte $01
	.byte $02
	.byte $03
	.byte $04
	.byte $00

livesValueList:
	.byte $03
	.byte $05
	.byte $07
	.byte $00

continueValueList:
	.byte $03
	.byte $05
	.byte $07
	.byte $00

soundValueList:
	.byte $01
	.byte $02
	.byte $00

.segment "BSS"

settingsDifficultyIndex:
	.res 1

settingsDifficultyValue:
	.res 1

settingsLivesIndex:
	.res 1

settingsLivesValue:
	.res 1

settingsContinueIndex:
	.res 1

settingsContinueValue:
	.res 1

settingsSoundIndex:
	.res 1

settingsSoundValue:
	.res 1

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** initSettings *************************************************************
;******************************************************************************

.proc initSettings
	pha
	phx
	php

	sep     #$30    				; X,Y,A are 8 bit numbers
	.A8
	.I8

	ldx #SETTINGS_DIFFICULTY_DEFAULT_INDEX
	stx settingsDifficultyIndex
	lda difficultyValueList,X
	sta settingsDifficultyValue

	ldx #SETTINGS_LIVES_DEFAULT_INDEX
	stx settingsLivesIndex
	lda livesValueList,X
	sta settingsLivesValue

	ldx #SETTINGS_CONTINUE_DEFAULT_INDEX
	stx settingsContinueIndex
	lda continueValueList,X
	sta settingsContinueValue

	ldx #SETTINGS_SOUND_DEFAULT_INDEX
	stx settingsSoundIndex
	lda soundValueList,X
	sta settingsSoundValue

	plp
	plx
	pla
	rts
.endproc

.A8
.I16