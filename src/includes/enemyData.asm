.segment "BANK1"

enemySpritePal:
    .incbin "../ressource/enemyFull.clr"

.segment "BANK3"

enemySpriteFullTiles:
	.incbin "../ressource/enemyFull.pic"

enemySpriteBank1Tiles := enemySpriteFullTiles
enemySpriteBank2Tiles := enemySpriteFullTiles + $2000
enemySpriteBank3Tiles := enemySpriteFullTiles + $4000
enemySpriteBank4Tiles := enemySpriteFullTiles + $6000

.segment "RODATA"

hdmaMemTitle:
	.byte $68,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

hdmaMemGame:
	.byte $70,%00000001,$20,%00000001,$10,%00001001,$10,%00010001,$10,%00011001,$00

verticalOffsetTable:
	.byte $80, $90, $a0, $b0

.segment "BANK1"

highByte:
	.byte %10101010
	.byte %10101011
	.byte %10101110
	.byte %10101111
	.byte %10111010
	.byte %10111011
	.byte %10111110
	.byte %10111111
	.byte %11101010
	.byte %11101011
	.byte %11101110
	.byte %11101111
	.byte %11111010
	.byte %11111011
	.byte %11111110
	.byte %11111111

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
	.byte   $01, $10, $09, $08, $00
	.byte   $01, $20, $09, $09, $00
	.byte   $01, $30, $09, $09, $00
	.byte	$00

grabbingWalk2:						; 6 sprite blocks
	.byte   $01, $00, $09, $09, $00
	.byte   $01, $10, $08, $09, $02
	.byte   $02, $20, $02, $11, $02
	.byte 			  $11, $02, $04
	.byte   $02, $30, $02, $11, $02
	.byte 			  $11, $02, $04
	.byte	$00

grabbingWalk3:						; 6 sprite blocks
	.byte   $01, $00, $09, $09, $00
	.byte   $01, $10, $09, $08, $04
	.byte   $02, $20, $01, $10, $06
	.byte  			  $10, $01, $08
	.byte   $02, $30, $01, $10, $06
	.byte 			  $10, $01, $08
	.byte	$00

grabbingArmUpWalk1:					; 4 sprite blocks
	.byte   $01, $00, $09, $09, $02
	.byte   $01, $10, $09, $08, $08
	.byte   $01, $20, $09, $09, $0c
	.byte   $01, $30, $09, $09, $0e
	.byte	$00

grabbingArmUpWalk2:					; 5 sprite blocks
	.byte   $01, $00, $09, $09, $02
	.byte   $01, $10, $08, $09, $06
	.byte   $01, $20, $08, $09, $0a
	.byte   $02, $30, $02, $11, $0a
	.byte 			  $11, $02, $0c
	.byte	$00

grabbingArmUpWalk3:					; 5 sprite blocks
	.byte   $01, $00, $09, $09, $02	; right foot in front (normal mode)
	.byte   $01, $10, $09, $09, $0a ; left foot in front (mirror mode)
	.byte   $01, $20, $0c, $06, $20
	.byte   $02, $30, $03, $11, $20
	.byte 			  $12, $02, $22
	.byte	$00

grabbingGrab1:
	.byte   $01, $00, $09, $09, $04
	.byte   $02, $10, $09, $08, $0c
	.byte 			  $18, $f8, $0e
	.byte   $01, $20, $09, $09, $0e
	.byte   $01, $30, $09, $09, $24
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

grabbingArmUpWalk:
	.byte $08
	.word .LOWORD(grabbingArmUpWalk1)
	.byte $08
	.word .LOWORD(grabbingArmUpWalk2)
	.byte $08
	.word .LOWORD(grabbingArmUpWalk1)
	.byte $08
	.word .LOWORD(grabbingArmUpWalk3)
	.byte $00

grabbingGrab:
	.byte $01
	.word .LOWORD(grabbingGrab1)
	.byte $00