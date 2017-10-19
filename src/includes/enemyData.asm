.segment "BANK1"

enemySpritePal:
    .incbin "../ressource/spriteFull.clr"

spriteBaseTiles:
	.incbin "../ressource/spriteFull.pic", $0000, $2000

.segment "BANK3"

enemySpriteFullTiles:
	.incbin "../ressource/spriteFull.pic", $2000

enemySpriteBank1Tiles := enemySpriteFullTiles
enemySpriteBank2Tiles := enemySpriteFullTiles + $2000
enemySpriteBank3Tiles := enemySpriteFullTiles + $4000
enemySpriteBank4Tiles := enemySpriteFullTiles + $6000

.segment "RODATA"

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

metaspriteStatusNormal:
	.byte %00100011
	.byte %00100101
	.byte %00100111
	.byte %00101001
	.byte %10100011
	.byte %10100101
	.byte %10100111
	.byte %10101001
	.byte %00100010
	.byte %00100100
	.byte %00100110
	.byte %00101000
	.byte %10100010
	.byte %10100100
	.byte %10100110
	.byte %10101000

metaspriteStatusMirror:
	.byte %01100011
	.byte %01100101
	.byte %01100111
	.byte %01101001
	.byte %11100011
	.byte %11100101
	.byte %11100111
	.byte %11101001
	.byte %01100010
	.byte %01100100
	.byte %01100110
	.byte %01101000
	.byte %11100010
	.byte %11100100
	.byte %11100110
	.byte %11101000

enemyFallYOffset:
	.byte 0, 0, 1, 1, 2
	.byte 4, 5, 6, 7, 8, 9, 10, 12
	.byte 15, 17, 19, 22, 24, 27, 29, 32, 35, 39, 42, 46, 50, 54, 58, 63, 67

enemyFallXOffset:
	.byte 1, 2, 3, 4, 5
	.byte 6, 7, 8, 9, 10, 11, 12, 13
	.byte 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30

enemyFallAnimAddress:
	.word .LOWORD(grabbingHitHighFall)
	.word .LOWORD(grabbingShakeFall)
	.word .LOWORD(grabbingHitMidFall)
	.word .LOWORD(grabbingHitLowFall)

;******************************************************************************
;*** Sprite definition ********************************************************
;******************************************************************************

;******************************************************************************
;*** Metasprites **************************************************************
;******************************************************************************
;*** Number of horizontal tiles + STATUS bits                               ***
;*** Y offset of the line                                                   ***
;*** X offset                                                               ***
;*** X offset Mirror                                                        ***
;*** Tile Number                                                            ***
;******************************************************************************

grabbingWalk1:						; 4 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $00
	.byte	$00

grabbingWalk2:						; 6 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $08, $09, $02
	.byte   ENEMY_MS_GRAB_PAL + $02, $20, $02, $11, $02
	.byte 			  					  $11, $02, $04
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $02, $11, $02
	.byte 			  					  $11, $02, $04
	.byte	$00

grabbingWalk3:						; 6 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $00
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $04
	.byte   ENEMY_MS_GRAB_PAL + $02, $20, $01, $10, $06
	.byte  			  					  $10, $01, $08
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $01, $10, $06
	.byte 			  					  $10, $01, $08
	.byte	$00

grabbingArmUpWalk1:					; 4 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $02
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $08
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $0c
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $24
	.byte	$00

grabbingArmUpWalk2:					; 5 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $02
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $08, $09, $06
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $08, $09, $0a
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $02, $11, $0a
	.byte 			  					  $11, $02, $0c
	.byte	$00

grabbingArmUpWalk3:					; 5 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $02	; right foot in front (normal mode)
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $09, $0a ; left foot in front (mirror mode)
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $0c, $06, $20
	.byte   ENEMY_MS_GRAB_PAL + $02, $30, $03, $11, $20
	.byte 			  					  $12, $02, $22
	.byte	$00

grabbingGrab1:						; 5 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $e0
	.byte   ENEMY_MS_GRAB_PAL + $02, $10, $09, $08, $e2
	.byte 			  					  $18, $f8, $e4
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $e0
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $e2
	.byte	$00

grabbingHitHigh1:					; 4 sprite blocks + hit sprite
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $09, $09, $e6
	.byte   ENEMY_MS_GRAB_PAL + $01, $05, $0e, $04, $0e	; hit sprite
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $e8
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $0b, $06, $e6
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $13, $fe, $e4
	.byte	$00

grabbingHitMid1:					; 5 sprite blocks + hit sprite
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $0f, $03, $ea
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $09, $ee
	.byte   ENEMY_MS_GRAB_PAL + $01, $15, $10, $02, $0e	; hit sprite
	.byte   ENEMY_MS_GRAB_PAL + $02, $20, $09, $09, $c0
	.byte 			  					  $18, $f9, $c2
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $0d, $05, $ec
	.byte	$00

grabbingHitLow1:					; 4 sprite blocks + hit sprite
	.byte   ENEMY_MS_GRAB_PAL + $01, $00, $0e, $03, $ea
	.byte   ENEMY_MS_GRAB_PAL + $01, $10, $09, $08, $ec
	.byte   ENEMY_MS_GRAB_PAL + $01, $20, $09, $09, $ea
	.byte   ENEMY_MS_GRAB_PAL + $01, $30, $09, $09, $e8
	.byte   ENEMY_MS_GRAB_PAL + $01, $34, $13, $ff, $0e	; hit sprite
	.byte	$00

grabbingFall1:						; 7 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $01, $0b, $00, $10, $e0
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $02, $1b, $00, $10, $e2
	.byte 			  					  				   $10, $00, $e4
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $02, $2b, $00, $10, $e6
	.byte 			  					  				   $10, $00, $e8
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $01, $32, $17, $f9, $ea
	.byte 	$00

grabbingFall2:						; 8 sprite blocks
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $02, $10, $00, $20, $ec
	.byte												   $10, $10, $ee
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $02, $20, $00, $20, $c0
	.byte 			  					  				   $10, $10, $c2
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $01, $23, $20, $00, $c4
	.byte   ENEMY_MS_GRAB_PAL + ENEMY_MS_UZONE + $03, $30, $00, $20, $c6
	.byte 			  					  				   $10, $10, $c8
	.byte 			  					  				   $20, $00, $ca
	.byte 	$00

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
	.byte $08								; value is 8 cause we use frame counter to lose energy counter
	.word .LOWORD(grabbingGrab1)
	.byte $00

grabbingShakeFall:
	.byte $05
	.word .LOWORD(grabbingGrab1)
	.byte $08
	.word .LOWORD(grabbingFall1)
	.byte $11
	.word .LOWORD(grabbingFall2)
	.byte $00

grabbingHitHighFall:
	.byte $05
	.word .LOWORD(grabbingHitHigh1)
	.byte $08
	.word .LOWORD(grabbingFall1)
	.byte $11
	.word .LOWORD(grabbingFall2)
	.byte $00

grabbingHitMidFall:
	.byte $05
	.word .LOWORD(grabbingHitMid1)
	.byte $08
	.word .LOWORD(grabbingFall1)
	.byte $11
	.word .LOWORD(grabbingFall2)
	.byte $00

grabbingHitLowFall:
	.byte $05
	.word .LOWORD(grabbingHitLow1)
	.byte $08
	.word .LOWORD(grabbingFall1)
	.byte $11
	.word .LOWORD(grabbingFall2)
	.byte $00