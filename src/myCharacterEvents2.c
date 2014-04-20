#include "data.h";
#include "pad.h";
#include "event.h";
#include "ressource.h";
#include "debug.h";
#include "PPU.h";
#include "PPURegisters.h"
#include "sprite.h"
#include "level.h";
#include "myEvents.h";

#include <string.h>

extern padStatus pad1;
extern OAMData spriteData;

void clearAOMTable(byte spriteTableoffset, byte size) {
	word		i;
	OBJECTData	*currentSpriteData;
	OBJECTProp	*currentSpriteProp;

	// init with base address
	currentSpriteData = (OBJECTData*) &spriteData.data;
	currentSpriteProp = (OBJECTProp*) &spriteData.prop;
	// set to current frame
	for(i=0; i<spriteTableoffset; i++) {
		currentSpriteData ++;
	}
	for(i=0; i<(spriteTableoffset>>2); i++) {
		currentSpriteProp ++;
	}

	for(i=0; i<size; i++) {
		currentSpriteData->HPos = 0;
		currentSpriteData->VPos = 224;
		currentSpriteData ++;
	}

	// TODO this is for a size of 8 !!!
	currentSpriteProp->properties = 0xaa;	// 4 Sprites setup
	currentSpriteProp++;
	currentSpriteProp->properties = 0xaa;
}

char spriteTableUpdate(word counter) {

	static heroPreparedSpriteData *previousHeroData;
	static byte previousHeroFrame;

	if(!isEnabledEvent()) {
		return EVENT_CONTINUE;
	}

	if(counter == 0) {
		previousHeroData = 0;
		previousHeroFrame = 0xff;
	}

	// Handling Hero data
	if(previousHeroData != hero.spriteSequence || previousHeroFrame != hero.spriteFrameCounter) {
		copyPreparedSpriteDataToVRAM(hero.spriteSequence, (byte) hero.spriteFrameCounter, sprite_pic, 0);
		previousHeroData = hero.spriteSequence;
		previousHeroFrame = hero.spriteFrameCounter;
	}

	// Handling Ennemies data
	if(counter == 0) {
		//copyPreparedSpriteDataToVRAM(ennemySpriteDataWalkSequence, (byte) 0, ennemies_pic, 0x0800);
		VRAMLoadFromValue(ennemies_pic, HEX_A(6800), HEX_A(1000));
	}

	OAMFullLoad();
	return EVENT_CONTINUE;
}
