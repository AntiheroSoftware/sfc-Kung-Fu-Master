;
; Kung Fu Master high score
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
			.include    "snes-pad.inc"
            .include    "snes-sprite.inc"

            .export 	initCursor
            .export 	cursorEvent
            .export 	cursorTarget
            .export 	cursorTargetSet

CURSOR_OAM_OFFSET = 119*4
CURSOR_OAM_OFFSET_2 = $21d

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
;*** padMask		word													***
;******************************************************************************

/*

cursorList:
	.word $004a
	.byte $4b
	.byte .BANKBYTE(_gameStartIntro)
	.word .LOWORD(_gameStartIntro)
	.byte $14
	.byte $0a
	.word PAD_START

	.word $004a
	.byte $5b
	.byte .BANKBYTE(_gameStartIntro)
	.word .LOWORD(_gameStartIntro)
	.byte $00
	.byte $14
	.word PAD_START

	.word $004a
	.byte $6b
	.byte .BANKBYTE(_gameStartIntro)
	.word .LOWORD(_gameStartIntro)
	.byte $0a
	.byte $00
	.word PAD_START

*/

.segment "BSS"

cursorListBaseAddr:
	.res 	2

cursorListAddr:
	.res 	2

cursorTarget:
	.res	3

cursorTargetSet:
	.res	1

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** initCursor ***************************************************************
;******************************************************************************
;*** X contains address to pos and actions									***
;******************************************************************************

.proc initCursor
	pha
	php

	lda #$00
	sta cursorTargetSet
	sta cursorTarget
	sta cursorTarget+1
	sta cursorTarget+2

	stx cursorListBaseAddr
	stx cursorListAddr

	lda $0000,x
	sta oamData+CURSOR_OAM_OFFSET

	lda $0002,x
	sta oamData+CURSOR_OAM_OFFSET+1

	lda #$4a
	sta oamData+CURSOR_OAM_OFFSET+2

	lda #$32
	sta oamData+CURSOR_OAM_OFFSET+3

	lda #%10000000
	sta oamData+CURSOR_OAM_OFFSET_2

	jsr OAMDataUpdated

	plp
	pla
	rts
.endproc

;******************************************************************************
;*** cursorEvent **************************************************************
;******************************************************************************
;*** No parameters															***
;******************************************************************************

.proc cursorEvent
	phx
	php

	rep #$20
	.A16

	ldx cursorListAddr
	lda padFirstPushData1
	bit $08,X
	beq checkForDOWN

	sep #$20
	.A8

cursorActivated:
	;ldx cursorListAddr
	lda $03,X
	sta cursorTarget+2
	lda $04,X
	sta cursorTarget
	lda $05,X
	sta cursorTarget+1

	lda #$01
	sta cursorTargetSet

	lda #$01				; continue event
	plp
	plx
	rtl

checkForDOWN:

	sep #$20
	.A8

	lda padFirstPushData1
	bit #PAD_DOWN
	beq checkForUP

	ldx cursorListAddr
	lda $07,x

	bra update

checkForUP:

	bit #PAD_UP
	beq exit

	ldx cursorListAddr
	lda $06,x

update:
	rep #$20
	.A16

	and #$00ff
	clc
	adc cursorListBaseAddr
	sta cursorListAddr
	tax

	rep #$10
	sep #$20
	.A8
	.I16

	lda $0000,x
	sta oamData+CURSOR_OAM_OFFSET

	lda $0002,x
	sta oamData+CURSOR_OAM_OFFSET+1

	jsr OAMDataUpdated

exit:
	lda #$01

	plp
	plx
	rtl
.endproc