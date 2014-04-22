#define LEVEL_SCROLL_RIGHT	1
#define LEVEL_SCROLL_LEFT	2

#define LEVEL_MAP		2000
#define LEVEL_MAP_ALT	2400
#define LEVEL_TILE		3000

extern char levelScrollUpdate;
extern word scrollValue;
extern word far *levelDMASrc;
extern word levelDMADst;
extern word levelDMASize;

extern int mapPosition;

void initLevel(void);
void scrollLevelDMAInit(void);
char isScrollRightAllowed(void);
char isScrollLeftAllowed(void);
char isEnnemyComingFromLeftAllowed(void);
char isEnnemyComingFromRightAllowed(void);
char scrollLevel(word counter);
char scrollLevelEvent(word counter);
void setScrollUpdate(char scrollValue);
