include Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) main.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) level.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) hero.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) ennemy.asm
	$(CC65_BIN)/ld65 -vm -m kungfumaster.map -o kungfumaster.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom256.cfg main.o level.o hero.o ennemy.o $(SFC_LIB_PATH)/sfc.lib