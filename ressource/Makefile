all: ressource

ressource: splash irem titleScreen KFM_Player_final_sprite ennemies

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
KFM_Player_final_sprite: raw/KFM_Player_final_sprite.pcx
	wine ../tools/pcx2snes.exe -n -s16 -c16 -o16 raw/KFM_Player_final_sprite
	mv raw/KFM_Player_final_sprite.pic .
	mv raw/KFM_Player_final_sprite.clr .
ennemies: raw/ennemies*.pcx
	wine ../tools/pcx2snes.exe -n -s16 -c16 -o16 raw/ennemies1
	wine ../tools/pcx2snes.exe -n -s16 -c16 -o16 raw/ennemies2
	wine ../tools/pcx2snes.exe -n -s16 -c16 -o16 raw/ennemies3
	wine ../tools/pcx2snes.exe -n -s16 -c16 -o16 raw/ennemies4
	mv raw/ennemies*.pic .
	mv raw/ennemies1.clr ./ennemies.clr
	rm raw/ennemies*.clr

