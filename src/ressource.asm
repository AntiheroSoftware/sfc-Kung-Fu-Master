ressource	.section

	XDEF __title_map
__title_map:
	INSERT ressource/kungfu.map

	XDEF __title_pic
__title_pic:
	INSERT ressource/kungfu.pic
	
	XDEF __title_pal	
__title_pal:
	INSERT ressource/kungfu.clr

	XDEF __debugFont_pic
__debugFont_pic
	INSERT ressource/debugFont.pic

	XDEF __debugFont_pal
__debugFont_pal
	INSERT ressource/debugFont.clr
	
	XDEF __sprite_pal	
__sprite_pal:
	INSERT ressource/sprite.clr
	
	XDEF __ennemies_pal	
__ennemies_pal:
	INSERT ressource/ennemies.clr
	
.ends

spriteRessource	.section

	XDEF __sprite_pic
__sprite_pic:
	INSERT ressource/sprite.pic

.ends

spriteRessource2	.section

	XDEF __ennemies_pic
__ennemies_pic:
	INSERT ressource/ennemies.pic
	
.ends

levelRessource	.section
	
	XDEF __level_pic
__level_pic
	INSERT ressource/level1.map.pic

	XDEF __level_pal
__level_pal
	INSERT ressource/level1.map.clr
	
.ends

levelMapRessource	.section
	
	XDEF __level1_map
__level1_map
	INSERT ressource/level1.map

.ends

scoreRessource	.section
	
	XDEF __score_pic
__score_pic
	INSERT ressource/score.map.pic
	
	XDEF __score_pal
__score_pal
	INSERT ressource/score.map.clr

; MAP is created with palette offset 2
; so color are copied at 0x40
	
	XDEF __score_map
__score_map
	INSERT ressource/score.map

.ends
