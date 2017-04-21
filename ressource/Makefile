all: ressource

ressource: splash irem titleScreen letterHandBlank KFM_Player_final_sprite spriteFull score font letterGreyPalette letterRedPalette

splash: raw/splash.pcx
	wine ../tools/pcx2snes.exe -screen -s8 -c16 -o16 raw/splash
	mv raw/splash.pic .
	mv raw/splash.map .
	mv raw/splash.clr .
irem: raw/irem.pcx
	wine ../tools/pcx2snes.exe -screen -s8 -c16 -o16 raw/irem
	mv raw/irem.pic .
	mv raw/irem.map .
	mv raw/irem.clr .
titleScreen: raw/titleScreen.pcx
	wine ../tools/pcx2snes.exe -screen -s8 -c16 -o16 raw/titleScreen
	mv raw/titleScreen.pic .
	mv raw/titleScreen.map .
	mv raw/titleScreen.clr .
letterHandBlank: raw/letterHandBlank.pcx
	wine ../tools/pcx2snes.exe -screen -s8 -c16 -o16 raw/letterHandBlank
	mv raw/letterHandBlank.pic .
	mv raw/letterHandBlank.map .
	mv raw/letterHandBlank.clr .
KFM_Player_final_sprite: raw/KFM_Player_final_sprite.pcx
	wine ../tools/pcx2snes.exe -n -s16 -c16 -o16 raw/KFM_Player_final_sprite
	mv raw/KFM_Player_final_sprite.pic .
	mv raw/KFM_Player_final_sprite.clr .
spriteFull: raw/spriteFull.pcx
	../../Tools/pcx2snes/pcx2snes -n -r -s16 -c16 -o32 raw/spriteFull
	mv raw/spriteFull.pic .
	mv raw/spriteFull.clr ./spriteFull.clr
score: raw/score.pcx
	../../Tools/pcx2snes/pcx2snes -n -s8 -c16 -o16 raw/score
	mv raw/score.pic .
	mv raw/score.clr ./score.clr
font: raw/font.pcx
	../../Tools/pcx2snes/pcx2snes -n -s8 -c16 -o16 raw/font
	mv raw/font.pic .
	mv raw/font.clr ./font.clr
letterGreyPalette: raw/letterGreyPalette.pcx
	../../Tools/pcx2snes/pcx2snes -s8 -c16 -o16 raw/letterGreyPalette
	rm raw/letterGreyPalette.pic
	mv raw/letterGreyPalette.clr ./letterGreyPalette.clr
letterRedPalette: raw/letterRedPalette.pcx
	../../Tools/pcx2snes/pcx2snes -s8 -c16 -o16 raw/letterRedPalette
	rm raw/letterRedPalette.pic
	mv raw/letterRedPalette.clr ./letterRedPalette.clr

