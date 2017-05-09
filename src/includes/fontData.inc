.segment "BANK4"

fontTiles:
	.incbin "../ressource/font.pic"

fontPal:
	.incbin "../ressource/font.clr"

letterGreyPal:
    .incbin "../ressource/letterGreyPalette.clr"

letterRedPal:
    .incbin "../ressource/letterRedPalette.clr"

titleScreenWhitePal:
    .incbin "../ressource/titleScreenWhitePalette.clr"

titleScreenYellowPal:
    .incbin "../ressource/titleScreenYellowPalette.clr"

titleScreenWhiteRedPal:
    .incbin "../ressource/titleScreenWhiteRedPalette.clr"

fontWhiteRedBlackPal:
    .incbin "../ressource/fontWhiteRedBlackPalette.clr"

fontRedBlackBlackPal:
	.incbin "../ressource/fontRedBlackBlackPalette.clr"

fontCyanBlackBlackPal:
	.incbin "../ressource/fontCyanBlackBlackPalette.clr"

gameMessagePal:
    .incbin "../ressource/gameMessagePalette.clr"

.segment "CODE"

letterIntroString:
	.byte $01," YOUR LOVE ",$02,"SILVIA",$01,$0a,$0a
	.byte " IS IN CUSTODY NOW.",$0a,$0a
	.byte "IF YOU WANT TO SAVE",$0a,$0a
	.byte " YOUR DEAR ",$02,"SILVIA'S",$0a,$0a
	.byte "  LIFE",$01,", COME TO",$0a,$0a
	.byte " THE DEVIL'S TEMPLE",$0a,$0a
	.byte " AT ONCE.",$0a,$0a
	.byte "5 SONS OF THE DEVIL",$0a,$0a
	.byte " WILL ENTERTAIN YOU.",$00

titleScreenSelectString:
    .byte $02,"1", $01, " PLAYER",$0a,$0a
    .byte $02,"2", $01, " PLAYERS",$0a,$0a
    .byte "OPTIONS",$00

titleScreenCopyrightString:
    .byte $02,"  @ 1984", $03," IREM CORP.",$0a,$0a
    .byte $02,"@ 2017", $03," ANTIHERO SOFT.",$00

readyString:
	.byte $07, " READY ",$0a
	.byte      "       ",$00

onePlayerFirstFloorString:
	.byte $07, "                  ",$0a
	.byte      " 1-PLAYER 1-FLOOR ",$0a
    .byte      "                  ",$00

gamePausedString:
	.byte $07, "             ",$0a
	.byte      " GAME PAUSED ",$0a
	.byte      "             ",$00