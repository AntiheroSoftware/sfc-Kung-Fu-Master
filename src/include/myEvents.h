typedef struct ennemy {
	byte					enabled;
	byte					catchedPower;
	heroPreparedSpriteData	*spriteSequence;
	byte					spriteFrame;
	word					spriteFrameCounter;
	word					catchFrameCounter;
	sword					spriteHScroll;
	word					spriteVScroll;
	struct ennemy			*previousEnnemy;
	struct ennemy			*nextEnnemy;
} ennemyData;

typedef struct hero {
	heroPreparedSpriteData	*spriteSequence;	//*currentHeroSpriteData;
	byte					spriteFrame;		// static in fonction heroSpriteControl
	word					spriteFrameCounter; //currentHeroSpriteDataFrame;
	word					heroSpriteHScroll;
	word					heroSpriteVScroll;
	byte					status;
	byte					getOutCatch;
} heroData;

#define HERO_STATUS_NORMAL	0
#define HERO_STATUS_CATCHED	1

#define HERO_ENERGY_LOSS_CATCHED	4

#define MAX_LEFT_SCREEN		100
#define MAX_RIGHT_SCREEN	180

#define DIRECTION_NONE		0
#define DIRECTION_LEFT		1
#define DIRECTION_RIGHT		2
#define DIRECTION_DOWN		3
#define DIRECTION_UP		4

#define HIT_NONE			0
#define HIT_PUNCH			1
#define HIT_KICK			2

extern heroData hero;

extern char oncePerVBlank;

extern OAMData spriteData;

extern heroPreparedSpriteData heroSpriteDataStandSequence[1];
extern heroPreparedSpriteData heroSpriteDataWalkSequence[6];
extern heroPreparedSpriteData heroSpriteDataStandDownSequence[1];
extern heroPreparedSpriteData heroSpriteDataJumpSequence[5];
extern heroPreparedSpriteData heroSpriteDataPunchSequence[3];
extern heroPreparedSpriteData heroSpriteDataPunchDownSequence[3];
extern heroPreparedSpriteData heroSpriteDataKickSequence[3];
extern heroPreparedSpriteData heroSpriteDataKickDownSequence[2];
extern heroPreparedSpriteData heroSpriteDataKickUpSequence[5];

extern byte heroSpriteDataJumpSequenceOffset[28];

char fadeOut(word counter);
char fadeIn(word counter);
char mosaicOut(word counter);
char mosaicIn(word counter);
char NMIReadPad(word counter);
char oncePerVBlankReset(word counter);
char scrollLeft(word counter);

/*
extern heroPreparedSpriteData heroSpriteDataStandSequence[1];
extern heroPreparedSpriteData heroSpriteDataWalkSequence[6];
extern heroPreparedSpriteData heroSpriteDataStandDownSequence[1];
extern heroPreparedSpriteData heroSpriteDataJumpSequence[3];
extern heroPreparedSpriteData heroSpriteDataPunchSequence[3];
extern heroPreparedSpriteData heroSpriteDataPunchDownSequence[3];
extern heroPreparedSpriteData heroSpriteDataKickSequence[3];
extern heroPreparedSpriteData heroSpriteDataKickDownSequence[3];
extern heroPreparedSpriteData heroSpriteDataKickUpSequence[3];
*/

// myCharacterEvents
void heroSpriteControl(word counter);
char spriteTableUpdate(word counter);
void clearAOMTable(byte spriteTableoffset, byte size);
void copyPreparedSpriteDataToVRAM(heroPreparedSpriteData *data, byte frame, word far *spritePtr, word VRAMOffset);
void copyPreparedSpriteDataToAOMTable(heroPreparedSpriteData *data, byte frame, byte mirror,
									  byte spriteTableoffset, word spriteHOffset, word spriteVOffset);
