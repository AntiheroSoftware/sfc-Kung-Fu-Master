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
;******************************************************************************

/*

cursorList:
	.word $004a
	.byte $4b
	.byte .BANKBYTE(_gameStartIntro)
	.word .LOWORD(_gameStartIntro)
	.byte $10
	.byte $08

	.word $004a
	.byte $5b
	.byte .BANKBYTE(_gameStartIntro)
	.word .LOWORD(_gameStartIntro)
	.byte $00
	.byte $10

	.word $004a
	.byte $6b
	.byte .BANKBYTE(_gameStartIntro)
	.word .LOWORD(_gameStartIntro)
	.byte $08
	.byte $00

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

	lda padFirstPushData1
	bit #PAD_START
	beq checkForDOWN

	ldx cursorListAddr
	lda $03,x
	sta cursorTarget+2
	lda $04,x
	sta cursorTarget
	lda $05,x
	sta cursorTarget+1

	lda #$01
	sta cursorTargetSet

	lda #$01				; continue event
	plp
	plx
	rtl

checkForDOWN:

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