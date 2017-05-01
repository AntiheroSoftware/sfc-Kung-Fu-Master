all: ressource

ressource: splash irem titleScreen letterHandBlank KFM_Player_final_sprite spriteFull score font

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
spriteFull: raw/spriteFull.png
	../../Tools/SuperFamiconv/bin/superfamiconv -i raw/spriteFull.png -p spriteFull.clr -t spriteFull.pic --no-discard --tile-width 16 --tile-height 16 -v
score: raw/score.pcx
	../../Tools/pcx2snes/pcx2snes -n -s8 -c16 -o16 raw/score
	mv raw/score.pic .
	mv raw/score.clr ./score.clr
font: raw/font.pcx
	../../Tools/pcx2snes/pcx2snes -n -s8 -c16 -o16 raw/font
	mv raw/font.pic .
	mv raw/font.clr ./font.clr

