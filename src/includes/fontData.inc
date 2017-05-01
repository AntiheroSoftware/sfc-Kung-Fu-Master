.segment "BANK4"

fontTiles:
	.incbin "../ressource/font.pic"

fontPal:
	.incbin "../ressource/font.clr"

letterGreyPal:
    .incbin "../ressource/letterGreyPalette.clr"

letterRedPal:
    .incbin "../ressource/letterRedPalette.clr"

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