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
            .export 	enemyStrategy

            .export enemyStrategyLeftTable
            .export enemyStrategyLeftTableSize

ENEMY_GRAB_INTERVAL = 50

.segment "ZEROPAGE"

.segment "BSS"

enemyStrategyLeftTableIndex:
	.res 2

enemyStrategyLeftTableCounter:
	.res 2

.segment "RODATA"

enemyStrategyLeftTable:

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

	;*** For Testing purpose ***
	;***************************

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

enemyStrategyLeftTableEnd:

enemyStrategyLeftTableSize:
	.word enemyStrategyLeftTableEnd - enemyStrategyLeftTable

.segment "CODE"

.A8
.I16

;******************************************************************************
;*** enemyStrategyInit ********************************************************
;******************************************************************************
;*** No parameters         				    					     		***
;******************************************************************************

.proc enemyStrategyInit
	php
	phx
	phy

	ldx #$0000
	stx enemyStrategyLeftTableIndex

	ldy enemyStrategyLeftTable,X
	sty enemyStrategyLeftTableCounter

	ply
	plx
	plp
	rts
.endproc

;******************************************************************************
;*** enemyStrategy ************************************************************
;******************************************************************************
;*** Register A contains value to decrement                    		   		***
;******************************************************************************

.proc enemyStrategy
	jsr enemyStrategyLeft
	jsr enemyStrategyRight
	rts
.endproc

; counter decrement is based on frame + scrolling left
; Warning : this is only for left ... need to do the same for right

; TODO implement boundaries for left / right

;******************************************************************************
;*** enemyStrategyLeft ********************************************************
;******************************************************************************
;*** Register A contains value to decrement                    		   		***
;******************************************************************************

.proc enemyStrategyLeft
	php
	pha
	phx
	phy

	ldy enemyStrategyLeftTableCounter
	cpy #$0000
	bne decrement

	jsr findEmptySlotEnemy			; Load X with a free enemy slot ( 0 - 13 )

	cpx #$ffff						; no slot found
	beq skip

	ldx enemyStrategyLeftTableIndex
	lda enemyStrategyLeftTable+2,X
	jsr addEnemy

skip:

	ldx enemyStrategyLeftTableIndex
	inx
	inx
	inx
	cpx enemyStrategyLeftTableSize
	bne nextTableIndex

	ldx #$0000

nextTableIndex:

	stx enemyStrategyLeftTableIndex
	ldy enemyStrategyLeftTable,X
	sty enemyStrategyLeftTableCounter

decrement:

	dey									; TODO get decrement value from A
	sty enemyStrategyLeftTableCounter

end:

	ply
	plx
	pla
	plp
	rts
.endproc

;******************************************************************************
;*** enemyStrategyRight *******************************************************
;******************************************************************************
;*** Register A contains value to decrement                    		   		***
;******************************************************************************

.proc enemyStrategyRight
	rts
.endproc