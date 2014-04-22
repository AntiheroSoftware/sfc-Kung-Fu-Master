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

// This function should not be called during VBlank leaving the small
// VBLank time frame for doing way more usefull things.
void heroSpriteControl(word counter) {

	static word currentFrame;
	static byte frameCounter;
	static byte frameNumber;
	static word direction;
	static word hit;
	static word internalJumpFrame;
	static byte mirror;
	static word baseVScroll;

	word modified;
	byte catchedStatus;

	modified = 0;
	catchedStatus = (hero.status == HERO_STATUS_CATCHED);

	// Init routine on first event call
	if(counter == 0) {
		// first call to function -> init setup
		hero.heroSpriteHScroll = 0x76;
		hero.heroSpriteVScroll = 0x80;
		hero.status = 0;
		hero.getOutCatch = 0;
		currentFrame = 0;
		frameCounter = 0;
		direction = DIRECTION_LEFT;
		hit = HIT_NONE;
		internalJumpFrame = 0;
		mirror = 0;
		baseVScroll = 0;

		// need to setup everything on the fisrt time
		modified++;
	}

	if(pad1.left) {
		if(mirror != 0) {
			mirror = 0;
			modified++;
		}
	} else if(pad1.right) {
		if(mirror != 1) {
			mirror = 1;
			modified++;
		}
	}

	if(hit == HIT_NONE) {
		// Hero cannot do action except trying to throw away the enemies.
		// The energy lost is handled by the ennemies.
		// We must also finish the moves we were doing

		if(pad1.up && internalJumpFrame == 0 && !catchedStatus) {
			// jump
			direction = DIRECTION_UP;
			hero.spriteSequence = heroSpriteDataJumpSequence;
			hero.spriteFrameCounter = 0;
			currentFrame = 1;
			internalJumpFrame = 1;
			frameCounter = 0;
			frameNumber = 5;
			baseVScroll = hero.heroSpriteVScroll;
		} else if(internalJumpFrame != 0) {
			frameCounter++;
			internalJumpFrame++;
			modified++;

			// We can only press kick button on frame 2
			if(pad1.B && (currentFrame-1) == 2) {
				// kick
				hero.spriteSequence = heroSpriteDataKickUpSequence;
			}

			if(frameCounter >= hero.spriteSequence[hero.spriteFrameCounter].frameDisplayTime) {
				frameCounter = 0;
				currentFrame++;
				hero.spriteFrameCounter = currentFrame - 1;
				modified++;

				if(currentFrame > frameNumber) {
					// Jump sequence is over
					hit = HIT_NONE;
					currentFrame = 0;
					internalJumpFrame = 0;

					direction = DIRECTION_NONE;
					hero.spriteSequence = heroSpriteDataStandSequence;
					hero.spriteFrameCounter = 0;
					modified++;
				}
			}

			hero.heroSpriteVScroll = baseVScroll - heroSpriteDataJumpSequenceOffset[internalJumpFrame-1];

			if(internalJumpFrame == 0) {
				internalJumpFrame = 0;
				frameCounter = 0;
				hero.heroSpriteVScroll = 0x80;
				direction = DIRECTION_NONE;
				hero.spriteSequence = heroSpriteDataStandSequence;
				hero.spriteFrameCounter = 0;
				modified++;
			}

		} else if(pad1.down && !catchedStatus) {
			if(direction != DIRECTION_DOWN) {
				direction = DIRECTION_DOWN;
				modified++;
			}
			if(pad1.B) {
				// kick down
				hit = HIT_KICK;
				hero.spriteSequence = heroSpriteDataKickDownSequence;
				hero.spriteFrameCounter = 0;
				currentFrame = 1;
				frameCounter = 0;
				frameNumber = 2;
				modified++;
			} else if(pad1.X) {
				// punch down
				hit = HIT_PUNCH;
				hero.spriteSequence = heroSpriteDataPunchDownSequence;
				hero.spriteFrameCounter = 0;
				currentFrame = 1;
				frameCounter = 0;
				frameNumber = 2;
				modified++;
			} else {
				// just down ...
				hero.spriteSequence = heroSpriteDataStandDownSequence;
				hero.spriteFrameCounter = 0;
			}
		} else if(pad1.B && !catchedStatus) {
			// kick
			hit = HIT_KICK;
			hero.spriteSequence = heroSpriteDataKickSequence;
			hero.spriteFrameCounter = 0;
			currentFrame = 1;
			frameCounter = 0;
			frameNumber = 3;
			modified++;
		} else if(pad1.X && !catchedStatus) {
			// punch
			hit = HIT_PUNCH;
			hero.spriteSequence = heroSpriteDataPunchSequence;
			hero.spriteFrameCounter = 0;
			currentFrame = 1;
			frameCounter = 0;
			frameNumber = 2;
			modified++;
		} else if(pad1.left) {
			// TODO modified on sprite scroll is not acceptable
			// due to the fact it copies the whole table
			if(!catchedStatus) {
				hero.heroSpriteHScroll--;
			}
			if(hero.heroSpriteHScroll < MAX_LEFT_SCREEN) {
				if(isScrollLeftAllowed()) {
					setScrollUpdate((char) LEVEL_SCROLL_LEFT);
				}
				hero.heroSpriteHScroll = MAX_LEFT_SCREEN;
			}
			modified++;
			if(direction != DIRECTION_LEFT || catchedStatus) {
				if(catchedStatus && direction == DIRECTION_RIGHT) {
					hero.getOutCatch = 1;
				}
				direction = DIRECTION_LEFT;
				hero.spriteSequence = heroSpriteDataWalkSequence;
				hero.spriteFrameCounter = 0;
				currentFrame = 1;
				frameCounter = 0;
				modified++;
			} else {
				frameCounter++;
				if((frameCounter % 0x08) == 0) {
					currentFrame++;
					if(currentFrame > 4) {
						currentFrame = 1;
					}
					hero.spriteFrameCounter = currentFrame - 1;
					modified++;
				}
			}
		} else if(pad1.right) {
			// TODO modified on sprite scroll is not acceptable
			// du to the fact it copies the whole table
			if(!catchedStatus) {
				hero.heroSpriteHScroll++;
			}
			if(hero.heroSpriteHScroll > MAX_RIGHT_SCREEN) {
				if(isScrollRightAllowed()) {
					setScrollUpdate((char) LEVEL_SCROLL_RIGHT);
				}
				hero.heroSpriteHScroll = MAX_RIGHT_SCREEN;
			}
			modified++;
			if(direction != DIRECTION_RIGHT || catchedStatus) {
				if(catchedStatus && direction == DIRECTION_LEFT) {
					hero.getOutCatch = 1;
				}
				direction = DIRECTION_RIGHT;
				hero.spriteSequence = heroSpriteDataWalkSequence;
				hero.spriteFrameCounter = 0;
				currentFrame = 1;
				frameCounter = 0;
				modified++;
			} else {
				frameCounter++;
				if((frameCounter % 0x08) == 0) {
					currentFrame++;
					if(currentFrame > 4) {
						currentFrame = 1;
					}
					hero.spriteFrameCounter = currentFrame - 1;
					modified++;
				}
			}
		} else {
			if(direction != DIRECTION_NONE && !catchedStatus) {
				direction = DIRECTION_NONE;
				hero.spriteSequence = heroSpriteDataStandSequence;
				hero.spriteFrameCounter = 0;
				modified++;
			}
		}
	}

	if(hit != HIT_NONE && modified == 0) {
		// Continue hit sequence
		frameCounter++;

		// Check if we allow new action
		if(hero.spriteSequence[hero.spriteFrameCounter].frameForActionRepeat != 0
			&& frameCounter >= hero.spriteSequence[hero.spriteFrameCounter].frameForActionRepeat) {
			if((hit == HIT_KICK && pad1.B) || (hit == HIT_PUNCH && pad1.X)) {
				frameCounter = 0;
				currentFrame--;
				hero.spriteFrameCounter = currentFrame - 1;
				modified++;
			}
		}

		// Check if we go to next frame
		if(frameCounter == hero.spriteSequence[hero.spriteFrameCounter].frameDisplayTime) {
			frameCounter = 0;
			currentFrame++;
			hero.spriteFrameCounter = currentFrame - 1;
			modified++;

			if(currentFrame > frameNumber) {
				// Hit sequence is over
				hit = HIT_NONE;
				currentFrame = 0;

				// TODO stand sequence after a hit is not acceptable
				// need to save state before kick or punch
				if(direction != DIRECTION_DOWN) {
					direction = DIRECTION_NONE;
					hero.spriteSequence = heroSpriteDataStandSequence;
				} else {
					hero.spriteSequence = heroSpriteDataStandDownSequence;
				}

				hero.spriteFrameCounter = 0;
				modified++;
			}
		}
	}

	if(modified) {
		copyPreparedSpriteDataToAOMTable(	hero.spriteSequence, (byte) hero.spriteFrameCounter, mirror,
											(byte) 0, hero.heroSpriteHScroll, hero.heroSpriteVScroll);
	}
}