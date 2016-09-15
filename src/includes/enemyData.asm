ENEMY_DATA_BANK = $01

ENEMY_STATUS_ACTIVE_FLAG 	= %00000001
ENEMY_STATUS_MIROR_FLAG 	= %00000010

.segment "BANK1"

enemySpritePal:
    .incbin "../ressource/ennemies.clr"

.segment "BANK3"

enemySpriteBank1Tiles:
    .incbin "../ressource/ennemies1.pic"

enemySpriteBank2Tiles:
    .incbin "../ressource/ennemies2.pic"

enemySpriteBank3Tiles:
    .incbin "../ressource/ennemies3.pic"

enemySpriteBank4Tiles:
    .incbin "../ressource/ennemies4.pic"

.segment "RODATA"

hdmaMemTitle:
	.byte $68,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

hdmaMemGame:
	.byte $68,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

verticalOffsetTable:
	.byte $80, $90, $a0, $b0

.segment "BANK1"

;******************************************************************************
;*** Sprite definition ********************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Number of horizontal tiles                                             ***
;*** Y offset of the line                                                   ***
;*** X offset                                                               ***
;*** X offset Mirror                                                        ***
;*** Tile Number                                                            ***
;******************************************************************************

grabbingWalk1:						; 4 sprite blocks
	.byte   $01, $00, $09, $09, $00
	.byte   $01, $10, $09, $09, $00
	.byte   $01, $20, $09, $09, $00
	.byte   $01, $30, $09, $09, $00
	.byte	$00

grabbingWalk2:						; 6 sprite blocks
	.byte   $01, $00, $09, $09, $00
	.byte   $01, $10, $08, $08, $02
	.byte   $02, $20, $02, $02, $02, $11, $11, $04
	.byte   $02, $30, $02, $02, $02, $11, $11, $04
	.byte	$00

grabbingWalk3:						; 6 sprite blocks
	.byte   $01, $00, $09, $09, $00
	.byte   $01, $10, $09, $09, $04
	.byte   $02, $20, $01, $01, $06, $10, $10, $08
	.byte   $02, $30, $01, $01, $06, $10,  $10,$08
	.byte	$00

;******************************************************************************
;*** Animation frames *********************************************************
;******************************************************************************
;*** number of frames                                                       ***
;*** metasprite definition address                                          ***
;******************************************************************************

grabbingWalk:
	.byte $08
	.word .LOWORD(grabbingWalk1)
	.byte $08
	.word .LOWORD(grabbingWalk2)
	.byte $08
	.word .LOWORD(grabbingWalk1)
	.byte $08
	.word .LOWORD(grabbingWalk3)
	.byte $00