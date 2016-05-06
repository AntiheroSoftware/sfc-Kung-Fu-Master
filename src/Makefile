include Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) main.asm
	$(CC65_BIN)/ld65 -vm -m kungfumaster.map -o kungfumaster.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom128.cfg main.o $(SFC_LIB_PATH)/sfc.lib