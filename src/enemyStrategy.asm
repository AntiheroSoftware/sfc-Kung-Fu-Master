;
; Kung Fu Master ennemies strategy to appear on screen
;
; by lintbe/AntiheroSoftware <jfdusar@gmail.com>
;

            .setcpu     "65816"
            .feature	c_comments
            .linecont

			.include    "includes/enemy.inc"


            ENEMY_STRATEGY_MAIN_CODE = 1
			.include    "includes/enemyStrategy.inc"

            .export 	enemyStrategyInit
            .export 	enemyStrategyGrab

            .export enemyStrategyGrabTable
            .export enemyStrategyGrabTableSize

ENEMY_GRAB_INTERVAL = 50

.segment "ZEROPAGE"

.segment "BSS"

enemyStrategyGrabTableIndex:
	.res 2

enemyStrategyGrabTableCounter:
	.res 2

.segment "RODATA"

enemyStrategyGrabTable:
	.word $0050
	.byte ENEMY_STATUS_TYPE_GRAB
	.word $0080
	.byte ENEMY_STATUS_TYPE_GRAB
	.word $0050
	.byte ENEMY_STATUS_TYPE_GRAB
	.word $0150
	.byte ENEMY_STATUS_TYPE_GRAB
	.word $0030
	.byte ENEMY_STATUS_TYPE_GRAB

	;.word $0010
	;.byte ENEMY_STATUS_TYPE_GRAB
	;.word $0015
	;.byte ENEMY_STATUS_TYPE_GRAB
	;.word $0005
	;.byte ENEMY_STATUS_TYPE_GRAB
	;.word $0010
	;.byte ENEMY_STATUS_TYPE_GRAB
	;.word $0005
	;.byte ENEMY_STATUS_TYPE_GRAB

enemyStrategyGrabTableEnd:

enemyStrategyGrabTableSize:
	.word enemyStrategyGrabTableEnd - enemyStrategyGrabTable

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** enemyStrategyInit ********************************************************
;******************************************************************************
;***                     				    					     		***
;******************************************************************************

.proc enemyStrategyInit
	php
	phx
	phy

	ldx #$0000
	stx enemyStrategyGrabTableIndex

	ldy enemyStrategyGrabTable,X
	sty enemyStrategyGrabTableCounter

	ply
	plx
	plp
	rts
.endproc

;******************************************************************************
;*** enemyStrategyGrab ********************************************************
;******************************************************************************
;*** Register A contains value to decrement                    		   		***
;******************************************************************************

; counter decrement is based on frame + scrolling left
; Warning : this is only for left ... need to do the same for right

; TODO implement boundaries for left / right
; TODO rename function and make a call for left and right

.proc enemyStrategyGrab
	php
	pha
	phx
	phy

	ldy enemyStrategyGrabTableCounter
	cpy #$0000
	bne decrement

	ldx enemyStrategyGrabTableIndex
	lda enemyStrategyGrabTable+2,X

	;lda #$00						; set enemy type
	;ora #ENEMY_STATUS_TYPE_GRAB	; grab
	;ora #ENEMY_STATUS_MIRROR_FLAG	; in mirror mode
	jsr findEmptySlotEnemy			; Load X with a free enemy slot ( 0 - 13 )

	cpx #$ffff						; no slot found
	beq skip

	jsr addEnemy

skip:

	ldx enemyStrategyGrabTableIndex
	inx
	inx
	inx
	cpx enemyStrategyGrabTableSize
	bne nextTableIndex

	ldx #$0000

nextTableIndex:

	stx enemyStrategyGrabTableIndex
	ldy enemyStrategyGrabTable,X
	sty enemyStrategyGrabTableCounter

decrement:

	;ldx enemyStrategyGrabTableCounter	; TODO get decrement value from A
	dey
	sty enemyStrategyGrabTableCounter

end:

	ply
	plx
	pla
	plp
	rts
.endproc