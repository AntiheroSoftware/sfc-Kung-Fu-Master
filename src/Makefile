include Makefile.inc

all:
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) main.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) level.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) score.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) hero.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) enemy.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) enemyStrategy.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) hit.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) font.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) cursor.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) events.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) game/play.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) screen/highScore.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) screen/title.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) screen/option.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) splash/common.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) splash/antihero.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) splash/irem.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) splash/letter.asm
	$(CC65_BIN)/ca65 -t none -I $(SFC_INC_PATH) snesgss.asm
	$(CC65_BIN)/ld65 -vm -m kungfumaster.map -o kungfumaster.sfc --cfg-path $(SFC_CFG_PATH) -C snes-fast-lorom256.cfg main.o level.o score.o hero.o enemy.o enemyStrategy.o hit.o snesgss.o font.o cursor.o events.o game/*.o splash/*.o screen/*.o $(SFC_LIB_PATH)/sfc.lib
	mv kungfumaster.sfc ..