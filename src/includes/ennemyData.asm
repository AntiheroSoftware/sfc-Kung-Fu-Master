.segment "BANK1"

ennemySpritePal:
    .incbin "../ressource/ennemies.clr"

.segment "BANK3"

ennemySpriteBank1Tiles:
    .incbin "../ressource/ennemies1.pic"

ennemySpriteBank2Tiles:
    .incbin "../ressource/ennemies2.pic"

ennemySpriteBank3Tiles:
    .incbin "../ressource/ennemies3.pic"

ennemySpriteBank4Tiles:
    .incbin "../ressource/ennemies4.pic"

.segment "RODATA"

hdmaMem:
	.byte $68,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

verticalOffsetTable:
	.byte $80, $90, $a0, $b0

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
	.word grabbingWalk1
	.byte $08
	.word grabbingWalk2
	.byte $08
	.word grabbingWalk1
	.byte $08
	.word grabbingWalk3
	.byte $00