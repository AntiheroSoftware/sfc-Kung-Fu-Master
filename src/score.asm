;
; Kung Fu Master score control
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments

            .include    "snes.inc"
            .include    "snes-event.inc"

            .include	"includes/base.inc"
            .include	"includes/scoreDefine.inc"
            .include	"includes/scoreData.inc"

            .export 	initScore
            .export 	updateTime

			.export doUpdateScore
            .export scoreEvent
            .export scoreMapData
            .export timeCounter
            .export scorePlayer1
            .export updateScorePlayer1
            .export updateScoreTop
            .export setEnergyPlayer
            .export writeNumberToScoreMap

.segment "BSS"

scoreMapData:
	.res 192

doUpdateScore:
	.res 1

actualLevel:
	.res 1

scorePlayer1:
	.res 3

scorePlayer2:
	.res 3

scoreTop:
	.res 3

energyPlayer:
	.res 1

energyEnnemy:
	.res 1

timeCounter:
	.res 2

livesCounter:
	.res 1

dragonCounter:
	.res 1

.segment "CODE"

.A8
.I16

;*******************************************************************************
;*** initScore *****************************************************************
;*******************************************************************************
;*** Init every variable for score background                                ***
;*******************************************************************************

.proc initScore

	pha
	phx
	php

	lda #$01
	sta actualLevel

	lda #$00
	ldx #$0000
	stx scorePlayer1
	sta scorePlayer1+2
	stx scorePlayer2
	sta scorePlayer2+2

	lda #$40
	sta energyPlayer
	sta energyEnnemy

	ldx #$2000
	stx timeCounter

	lda #$02
	sta livesCounter

	lda #$00
	sta dragonCounter

	phb								; save data bank

	lda #SCORE_DATA_BANK			; switch data bank
	pha
	plb

	ldx #$0000						; init scoreMapData
loopCopyScoreMap:
	lda scoreMap,x
	sta scoreMapData,x
	inx
	cpx #$00c0
	bne loopCopyScoreMap

	plb								; restore data bank

	VRAMLoad scoreTiles, SCORE_TILE_ADDR, $0c00
	VRAMLoad scoreMapData, SCORE_MAP_ADDR, $c0
	CGRAMLoad scorePal, $60, $20

	lda #$00
	sta doUpdateScore

	ldx #$8520
	lda #$04
	jsr updateScoreTop

	lda #.BANKBYTE(scoreEvent)		; start score event
	ldx #.LOWORD(scoreEvent)
	ldy #EVENT_GAME_SCREEN_SCORE
	jsr addEvent

	ldx #$1200
	jsr updateScorePlayer1
	jsr updateScorePlayer2

	plp
	plx
	pla
	rts

.endproc

;******************************************************************************
;*** score functions **********************************************************
;******************************************************************************

;******************************************************************************
;*** updateScorePlayer1 *******************************************************
;******************************************************************************
;*** X contains score to add                                                ***
;******************************************************************************

.proc updateScorePlayer1

	phy
	phx
	pha
	php

	sed								; Switch to decimal mode
	clc

	rep #$20
	.A16

	txa
	adc scorePlayer1
	sta scorePlayer1

	sep #$20
	.A8

	lda scorePlayer1+2
	adc #$00
	sta scorePlayer1+2

	cld								; Back to binary mode

	lda #$06
	ldx #.LOWORD(scorePlayer1+2)
	ldy #SCORE_PLAYER1_OFFSET_POSITION						; offset /position
	jsr writeNumberToScoreMap

	lda #$01
	sta doUpdateScore

	plp
	pla
	plx
	ply
	rts

.endproc

;******************************************************************************
;*** updateScorePlayer2 *******************************************************
;******************************************************************************
;*** X contains score to add                                                ***
;******************************************************************************

.proc updateScorePlayer2

	phy
	phx
	pha
	php

	sed								; Switch to decimal mode
	clc

	rep #$20
	.A16

	txa
	adc scorePlayer2
	sta scorePlayer2

	sep #$20
	.A8

	lda scorePlayer2+2
	adc #$00
	sta scorePlayer2+2

	cld								; Back to binary mode

	lda #$06
	ldx #.LOWORD(scorePlayer2+2)
	ldy #SCORE_PLAYER2_OFFSET_POSITION						; offset /position
	jsr writeNumberToScoreMap

	lda #$01
	sta doUpdateScore

	plp
	pla
	plx
	ply
	rts

.endproc

;******************************************************************************
;*** updateScoreTop ***********************************************************
;******************************************************************************
;*** A contains score high byte                                             ***
;*** X contains score low word                                              ***
;******************************************************************************

.proc updateScoreTop

	phy
	phx
	pha
	php

	stx scoreTop
	sta scoreTop+2

	lda #$06						; number of digits to write
	ldx #.LOWORD(scoreTop+2)		; where value is stored
	ldy #SCORE_TOP_OFFSET_POSITION	; offset /position
	jsr writeNumberToScoreMap

	lda #$01
	sta doUpdateScore

	plp
	pla
	plx
	ply
	rts

.endproc

;******************************************************************************
;*** energy functions *********************************************************
;******************************************************************************

;******************************************************************************
;*** setEnergyPlayer functions ************************************************
;******************************************************************************
;*** A contains new energy value (0 - 64)                                   ***
;******************************************************************************

.proc setEnergyPlayer

	phx
	phy
	php

	sta energyPlayer

	pha								; save a

	lsr
	lsr
	lsr								; divide value by 8

	ldx #$0000						; map offset TODO set correct start value
	ldy #$0000						; counter

loopFull:							; full energy bar tile
	cmp #$00
	beq realValue

	pha
	lda #$08						; TODO use correct tile
	sta scoreMapData,x
	pla

	inx
	iny
	dec
	bra loopFull

realValue:

	pla								; restore initial value

	cpy #$0008
	beq end

	and #%00000111					; mask to get only last 3 bits
	clc
	adc #$ee						; add offset TODO set correct offset

	sta scoreMapData,x
	inx
	iny

loopEmpty:

	cpy #$0008
	beq end

	lda #$00						; TODO use correct tile
	sta scoreMapData,x
	inx
	iny

	bra loopEmpty

end:

	lda #$01
	sta doUpdateScore

	plp
	ply
	plx
	rts

.endproc

;******************************************************************************
;*** setEnergyEnnemy functions ************************************************
;******************************************************************************
;*** A contains new energy value (0 - 64)                                   ***
;******************************************************************************

.proc setEnergyEnnemy

	phx
	phy
	php

	sta energyEnnemy

	pha								; save a

	lsr
	lsr
	lsr								; divide value by 8

	ldx #$0000						; map offset TODO set correct start value
	ldy #$0000						; counter

loopFull:							; full energy bar tile
	cmp #$00
	beq realValue

	pha
	lda #$08						; TODO use correct tile
	sta scoreMapData,x
	pla

	inx
	iny
	dec
	bra loopFull

realValue:

	pla								; restore initial value

	cpy #$0008
	beq end

	and #%00000111					; mask to get only last 3 bits
	clc
	adc #$ee						; add offset TODO set correct offset

	sta scoreMapData,x
	inx
	iny

loopEmpty:

	cpy #$0008
	beq end

	lda #$00						; TODO use correct tile
	sta scoreMapData,x
	inx
	iny

	bra loopEmpty

end:

	lda #$01
	sta doUpdateScore

	plp
	ply
	plx
	rts

.endproc

;******************************************************************************
;*** timeCounter functions ****************************************************
;******************************************************************************

.proc updateTime

	phy
	phx
	pha
	php

	lda #$00
	jsr getEventCounter

	txa
	and #%00000111
	bne end

	rep #$20
	.A16

	sed								; Switch to decimal mode
	lda timeCounter
	sec
	sbc #$01
	sta timeCounter

	cld								; Back to binary mode

	sep #$20
	.A8

	lda #$04
	ldx #.LOWORD(timeCounter+1)
	ldy #SCORE_TIME_OFFSET_POSITION
	jsr writeNumberToScoreMap

	lda #$01
	sta doUpdateScore

end:

	plp
	pla
	plx
	ply
	rts

.endproc

;*******************************************************************************
;*** Lives *********************************************************************
;*******************************************************************************

.proc setLiveCounter

	phx
	phy
	php



	plp
	ply
	plx
	rts

.endproc

;*******************************************************************************
;*** Dragon ********************************************************************
;*******************************************************************************

;*******************************************************************************
;*** Events ********************************************************************
;*******************************************************************************

.proc scoreEvent

	php

	lda doUpdateScore				; check if update flag is on
	cmp #$00
	beq noUpdate

	; DMA scoreMapData to VRAM
	VRAMLoad scoreMapData, SCORE_MAP_ADDR, $c0

	lda #$00						; reset update flag
	sta doUpdateScore

noUpdate:

	lda #$01						; continue event

	plp
	rtl

.endproc

;*******************************************************************************
;*** Utils *********************************************************************
;*******************************************************************************

.segment "BSS"

bufferPosition:
	.res 1

bufferOffset:
	.res 1

.segment "CODE"

;*******************************************************************************
;*** writeNumberToScoreMap *****************************************************
;*******************************************************************************
;*** A -> number of digit to print (byte)                                    ***
;*** X -> address (word)                                                     ***
;*** Y -> offset (byte) / position (byte)                                    ***
;*******************************************************************************

.proc writeNumberToScoreMap

	php

	sty bufferPosition				; fill temp variable with position and offset
									; Y register is not needed after that

loop:
	pha 							; preverse digit number counter
	lda $0000,x

	lsr
	lsr
	lsr
	lsr
	clc
	adc bufferOffset

	phx

	sep     #$10    ; X,Y are 8 bit numbers
	.I8

	ldx bufferPosition
	sta scoreMapData,x
	inx
	inx
	stx bufferPosition

	rep     #$10    ; X,Y are 16 bit numbers
	.I16

	plx

	pla
	dec
	cmp #$00
	beq end

	pha
	lda $0000,x

	and #%00001111					; first digit
	clc
	adc bufferOffset

	phx

	sep     #$10    ; X,Y are 8 bit numbers
	.I8

	ldx bufferPosition
	sta scoreMapData,x
	inx
	inx
	stx bufferPosition

	rep     #$10    ; X,Y are 16 bit numbers
	.I16

	plx

	pla
	dec
	beq end

	dex
	bra loop

end:

	plp
	rts

.endproc