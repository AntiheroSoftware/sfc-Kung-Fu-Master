typedef struct OBJECTData {
	signed char HPos;
	byte VPos;
	byte nameLow;
	byte nameHigh:1;
	byte color:3;
	byte priority:2;
	byte HFlip:1;
	byte VFlip:1;
} OBJECTData;

typedef struct OBJECTProp {
	//byte size:1;	// Size Large/Small
	//byte HPos:1;	// H-Position MSB
	byte properties;
} OBJECTProp;

typedef struct OAMData {
	OBJECTData data[0x80];
	//OBJECTProp prop[0x80];
	OBJECTProp prop[0x20];
} OAMData;

typedef struct heroPreparedSpriteData {
	byte		spriteNum;
	word		spriteOffsetInRom;
	byte		frameDisplayTime;
	byte		frameForActionRepeat;
	OBJECTData	data[8];
	OBJECTData	dataMirror[8];
} heroPreparedSpriteData;

extern OAMData spriteData;

extern void initOAM(void);
extern void OAMLoad(void);
extern void OAMPartialLoad(byte objectNum);
extern void OAMFullLoad(void);
extern void loadSpriteToVRAM(word far *src, word vramDst, word horBlocks, word verBlocks);
extern void load8x8SpriteToVRAM(word far *src, word vramDst);
extern void load16x16SpriteToVRAM(word far *src, word vramDst);
extern void load32x32SpriteToVRAM(word far *src, word vramDst);
extern void load32x64SpriteToVRAM(word far *src, word vramDst);
extern word spriteOffset(byte x, byte y);
extern word spriteOffsetVRAM(byte x, byte y);
