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

heroData hero;

void copyPreparedSpriteDataToVRAM(heroPreparedSpriteData *data, byte frame, word far *spritePtr, word VRAMOffset) {

	word					i;
	heroPreparedSpriteData	*myData;

	// init with base address
	myData = data;
	// set to current frame
	for(i=0; i<frame; i++) {
		myData++;
	}

	load32x64SpriteToVRAM(	spritePtr + myData->spriteOffsetInRom, 0x6000 + VRAMOffset);
}

void copyPreparedSpriteDataToAOMTable(heroPreparedSpriteData *data, byte frame, byte mirror,
									  byte spriteTableoffset, word spriteHOffset, word spriteVOffset) {

	word					i, counter;
	int						position;
	byte					propTemp, propTempCount;
	heroPreparedSpriteData	*myData;
	OBJECTData				*myObjectData;
	OBJECTData				*currentSpriteData;
	OBJECTProp				*currentSpriteProp;

	// init with base address
	myData = data;
	// set to current frame
	for(i=0; i<frame; i++) {
		myData++;
	}

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

	counter = myData->spriteNum;

	// init start of the data array
	// we assume we always starts at 0 index
	if(!mirror)
		myObjectData = (OBJECTData*) &(myData->data);
	else
		myObjectData = (OBJECTData*) &(myData->dataMirror);

	propTemp = 0;
	propTempCount = 1;
	currentSpriteProp->properties = 0;

	for(i=0; i<counter; i++) {
		// Clean next batch of properties for the next 4 sprites
		if(propTempCount == 5) {
			//currentSpriteProp->properties = 0xaa;
			currentSpriteProp++;
			currentSpriteProp->properties = 0;
			propTempCount = 1;
		}

		currentSpriteData->VPos = myObjectData->VPos + spriteVOffset;
		position = ((word) myObjectData->HPos) + spriteHOffset;
		// TODO handle negative H offsets
		if(position < 0) {
			currentSpriteData->HPos = (byte) position & 0xff;
			// set H-POS bit High in prop
			propTemp = 0x01 << ((propTempCount-1)*2);
			currentSpriteProp->properties |= propTemp;
		} else if(position > 0xff) {
			currentSpriteData->VPos = 224;
		} else {
			currentSpriteData->HPos = (byte) position;
		}
		currentSpriteData->nameLow = myObjectData->nameLow;
		currentSpriteData->priority = myObjectData->priority;
		currentSpriteData->color = myObjectData->color;
		currentSpriteData->VFlip = myObjectData->VFlip;
		currentSpriteData->HFlip = myObjectData->HFlip;

		// update myObjectData Adress
		myObjectData++;
		currentSpriteData ++;

		// set LARGE Sprite property + HPOS High
		propTemp = 0x02 << ((propTempCount-1)*2);
		currentSpriteProp->properties |= propTemp;

		propTempCount++;
	}

	for(; i<8; i++) {
		currentSpriteData->VPos = 224;
		// update myObjectData Adress
		myObjectData++;
		currentSpriteData ++;
	}

	// set big sprite for 8 sprites
	//currentSpriteProp->properties = 0xaa;	// 4 Sprites setup
	//currentSpriteProp++;
	//currentSpriteProp->properties = 0xaa;
}

