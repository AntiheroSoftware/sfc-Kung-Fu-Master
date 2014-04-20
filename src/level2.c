#include "data.h";
#include "event.h";
#include "ressource.h"
#include "PPURegisters.h"
#include "ppu.h"
#include "level.h"
#include "sprite.h"
#include "myEvents.h"
#include "ennemiesHandling.h"

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
