all: ressource

ressource: splash irem titleScreen

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
