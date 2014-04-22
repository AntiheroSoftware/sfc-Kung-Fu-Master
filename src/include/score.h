#define SCORE_TOP		0
#define SCORE_PLAYER1	1
#define SCORE_PLAYER2	2

#define SCORE_PAL_ADJUST	0x1000

#define SCORE_MAP		0x0000
#define SCORE_MAP_SIZE	0x20*3*2
#define SCORE_TILE		0x1000

#define PLAYER_ENERGY_MAP	12
#define PLAYER_ENERGY		6+(32*1)
#define ENNEMY_ENERGY_MAP	34
#define ENNEMY_ENERGY		6+(32*2)

#define LIVE			0

#define LEVEL			17+(32*1)
#define MAP_LEVEL_ON	23
#define MAP_LEVEL_OFF	25

#define NUMBERS_WHITE	48
#define NUMBERS_CYAN	58
#define NUMBERS_RED		68

void initScore(void);
char scoreEvent(word counter);
void updateTime(word counter);
word getTime(void);
void updateScore(byte type, word score);
void updateLive(void);
void updateLevel(byte level);
char updateLevelEvent(word counter);
char getPlayerStatus(void);
void updatePlayerStatus(byte status);
byte getEnnemyStatus(void);
void updateEnnemyStatus(byte status);
word writeStringScore(char out[], byte bufferSize, byte x, byte y, byte tileOffset);
void scoreDisplay(void);
