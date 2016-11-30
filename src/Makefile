include Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) main.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) level.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) score.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) hero.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) enemy.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) state.asm
	@$(MAKE) -C stateBlocks $@
	$(CC65_BIN)/ld65 -vm -m kungfumaster.map -o kungfumaster.sfc --cfg-path $(SFC_CFG_PATH) -C snes-lorom256.cfg main.o level.o score.o hero.o enemy.o state.o $(SFC_LIB_PATH)/sfc.lib stateBlocks/allStates.lib
