LEVEL_TILE_ADDR	    = $0000
LEVEL_MAP_ADDR      = $1800
LEVEL_BANK			= $84

.segment "BANK4"

levelTiles:
    .incbin "../ressource/level.pic"

levelMap:
    .incbin "../ressource/level.map"

levelMapInitial := levelMap+($0700*6)-$38
levelMapRestart := levelMap+($0700*1)
levelMapStart   := levelMap
levelMapEnd     := levelMap+($0700*7)

levelPal:
    .incbin "../ressource/level0.pal"
    .incbin "../ressource/level1.pal"
    .incbin "../ressource/level2.pal"
    .incbin "../ressource/level3.pal"
    .incbin "../ressource/level4.pal"
    .incbin "../ressource/level5.pal"