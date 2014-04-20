#include "data.h";
#include "event.h";
#include "ressource.h"
#include "PPURegisters.h"
#include "PPU.h"
#include "level.h"
#include "sprite.h"
#include "myEvents.h"
#include "ennemiesHandling.h"

char levelScrollUpdate;
word scrollValue;
word far *levelDMASrc;
word levelDMADst;
word levelDMASize;

int mapPosition;

void initLevel(void) {
	word i;
	static word far *map;

	i = HEX_C(LEVEL_MAP);

	setBG1SC((word) HEX_C(LEVEL_MAP), (byte) 0x01);
	setBG12NBA((word) HEX_C(LEVEL_TILE), (word) PPU_NO_VALUE);

	// Title screen transfer to VRAM
	VRAMLoadFromValue(level_pic, HEX_A(LEVEL_TILE), HEX_A(5000));

	// Copy first part of level
	map = level1_map+(0x380*5);
	VRAMLoadFromPtr(map, HEX_A(LEVEL_MAP), HEX_A(0700));
	map = level1_map+(0x380*6);
	VRAMLoadFromPtr(map, HEX_A(LEVEL_MAP_ALT), HEX_A(0700));
	CGRAMLoad(level_pal, HEX_A(00), HEX_A(40));

	setBGMODE(0, 0, 3);
	*(byte*) 0x212c = 0x13; // Plane 0 (bit one) , plane 1 (bit two) enable register and OBJ enable
	*(byte*) 0x212d = 0x00;	// All subPlane disable
}

void scrollLevelDMAInit(void) {
	levelDMASrc = 0;
	levelDMADst = 0;
	levelDMASize = 0;
}

char isScrollRightAllowed() {
	return (char) (mapPosition < (1792-512));
}

char isScrollLeftAllowed() {
	return (char) (mapPosition > (-256+32));
}

char isEnnemyComingFromLeftAllowed() {
	return (char)(mapPosition > -256 + 128);
}

char isEnnemyComingFromRightAllowed() {
	return (char) 1;
}
