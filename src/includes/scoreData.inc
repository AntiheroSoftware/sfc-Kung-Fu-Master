.segment "BANK4"

scoreTiles:
	.incbin "../ressource/score.pic"

scoreMap:
	.incbin "../ressource/score.map"
	.repeat $740
		.byte $00
	.endrepeat

scorePal:
	.incbin "../ressource/score.pal"