//
//  HelloWorldLayer.h
//  CJY_Tank
//
//  Created by ChengJY on 14-3-17.
//  Copyright ChengJY 2014年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class Tank;
@class HUDLayer;

typedef enum {
    kEndReasonWin,
    kEndReasonLose
} EndReason;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCTMXTiledMap * _tileMap;
    CCTMXLayer * _bgLayer;
    NSMutableArray * _enemyTanks;
    CCParticleSystemQuad * _explosion;
    CCParticleSystemQuad * _explosion2;
    BOOL _gameOver;
    CCSprite * _exit;
    HUDLayer * _hudLayer;
}

+(CCScene *) scene;
- (id)initWithHUDLayer:(HUDLayer *)hudLayer;
- (float)tileMapHeight;
- (float)tileMapWidth;
- (BOOL)isValidPosition:(CGPoint)position;
- (BOOL)isValidTileCoord:(CGPoint)tileCoord;
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord;
- (void)setViewpointCenter:(CGPoint) position;
- (BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer;
- (BOOL)isProp:(NSString*)prop atPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer;
- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord;
- (BOOL)isWallAtPosition:(CGPoint)position;
- (BOOL)isWallAtRect:(CGRect)rect;

@property (strong) Tank * tank;
@property (strong) CCSpriteBatchNode * batchNode;



@end
