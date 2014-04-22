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

char scrollLevel(word counter) {
	static byte alreadyUpdated;
	word position;

	if(counter == 0) {
		scrollValue = 256;
		mapPosition = 1792 - 512;
		alreadyUpdated = 0;
		scrollLevelDMAInit();
	}

	if(levelScrollUpdate == LEVEL_SCROLL_LEFT) {
		if(!isScrollLeftAllowed()) return EVENT_CONTINUE;
		scrollValue--;
		mapPosition--;
	} else if(levelScrollUpdate == LEVEL_SCROLL_RIGHT) {
		if(!isScrollRightAllowed()) return EVENT_CONTINUE;
		scrollValue++;
		mapPosition++;
	}

	if(mapPosition % 256 == 0 && alreadyUpdated == 0) {
		// check wich part of screen we need to update
		position = (mapPosition / 256);
		if(levelScrollUpdate == LEVEL_SCROLL_RIGHT) {
			position += 2;
		}
		if(position != 7) {
			if(position % 2 != 0) {
				levelDMASrc = level1_map+(0x380*(position));
				levelDMADst = LEVEL_MAP;
				levelDMASize = 0x700;
				scrollValue = 256;
			} else {
				levelDMASrc = level1_map+(0x380*(position));
				levelDMADst = LEVEL_MAP+0x400;
				levelDMASize = 0x700;
				scrollValue = 0;
			}
			alreadyUpdated = 1;
		}
	} else {
		position = (mapPosition / 256);
		if(mapPosition % 256 != 0) {
			alreadyUpdated = 0;
		}
		scrollLevelDMAInit();
	}

	levelScrollUpdate = 0;

	return EVENT_CONTINUE;
}

char scrollLevelEvent(word counter) {

	if(counter == 0) {
		*(byte*) 0x210e = (byte) -1;
		*(byte*) 0x210e = (byte) 0;
	}

	if(levelDMASize != 0) {
		VRAMLoadFromPtr(levelDMASrc, levelDMADst, levelDMASize);
		setINIDSP(0, 0xf);
		scrollLevelDMAInit();
	}

	*(byte*) 0x210d = (byte) scrollValue;
	*(byte*) 0x210d = (byte) (scrollValue>>8);

	return EVENT_CONTINUE;
}

void setScrollUpdate(char scrollValue) {
	levelScrollUpdate = scrollValue;
	ennemyScrollUpdate = scrollValue;
}
