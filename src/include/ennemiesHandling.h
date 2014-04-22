extern char ennemyScrollUpdate;
extern ennemyData *ennemies;

void ennemyInit(void);
void enableEnnemy(ennemyData myEnnemy);
void disableEnnemy(ennemyData myEnnemy);
void ennemySpriteControl(word counter);
ennemyData *ennemyCreate(heroPreparedSpriteData *spriteSequence, byte spriteFrameStart, sword HPos, word VPos);
ennemyData *ennemyAdd(heroPreparedSpriteData *spriteSequence, byte spriteFrameStart, sword HPos, word VPos);
word ennemyCount(ennemyData *ennemyElement);
void ennemyRemove(ennemyData *ennemyElement);

// DATA
extern heroPreparedSpriteData ennemySpriteDataWalkSequence[4];
extern heroPreparedSpriteData ennemySpriteDataArmsUpSequence[4];
