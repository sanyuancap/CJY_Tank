//
//  HelloWorldLayer.m
//  CJY_Tank
//
//  Created by ChengJY on 14-3-17.
//  Copyright ChengJY 2014年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "Tank.h"
#import "SimpleAudioEngine.h"
#import "RandomTank.h"
#import "HUDLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize batchNode = _batchNode;
@synthesize tank = _tank;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    HUDLayer * hud = [HUDLayer node];
    [scene addChild:hud z:1];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [[HelloWorldLayer alloc] initWithHUDLayer:hud];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (float)tileMapHeight {
    return _tileMap.mapSize.height * _tileMap.tileSize.height;
}

- (float)tileMapWidth {
    return _tileMap.mapSize.width * _tileMap.tileSize.width;
}

- (BOOL)isValidPosition:(CGPoint)position {
    if (position.x < 0 ||
        position.y < 0 ||
        position.x > [self tileMapWidth] ||
        position.y > [self tileMapHeight]) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (BOOL)isValidTileCoord:(CGPoint)tileCoord {
    if (tileCoord.x < 0 ||
        tileCoord.y < 0 ||
        tileCoord.x >= _tileMap.mapSize.width ||
        tileCoord.y >= _tileMap.mapSize.height) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    
    if (![self isValidPosition:position]) return ccp(-1,-1);
    
    int x = position.x / _tileMap.tileSize.width;
    int y = ([self tileMapHeight] - position.y) / _tileMap.tileSize.height;
    
    return ccp(x, y);
}

- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    
    int x = (tileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width/2;
    int y = [self tileMapHeight] - (tileCoord.y * _tileMap.tileSize.height) - _tileMap.tileSize.height/2;
    return ccp(x, y);
    
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2 / self.scale);
    int y = MAX(position.y, winSize.height / 2 / self.scale);
    x = MIN(x, [self tileMapWidth] - winSize.width / 2 / self.scale);
    y = MIN(y, [self tileMapHeight] - winSize.height/ 2 / self.scale);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    
    _tileMap.position = viewPoint;
    
}

-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer {
    if (![self isValidTileCoord:tileCoord]) return NO;
    int gid = [layer tileGIDAt:tileCoord];
    NSDictionary * properties = [_tileMap propertiesForGID:gid];
    if (properties == nil) return NO;
    return [properties objectForKey:prop] != nil;
}

-(BOOL)isProp:(NSString*)prop atPosition:(CGPoint)position forLayer:(CCTMXLayer *)layer {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    return [self isProp:prop atTileCoord:tileCoord forLayer:layer];
}

- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord {
    return [self isProp:@"Wall" atTileCoord:tileCoord forLayer:_bgLayer];
}

- (BOOL)isWallAtPosition:(CGPoint)position {
    CGPoint tileCoord = [self tileCoordForPosition:position];
    if (![self isValidPosition:tileCoord]) return TRUE;
    return [self isWallAtTileCoord:tileCoord];
}

- (BOOL)isWallAtRect:(CGRect)rect {
    CGPoint lowerLeft = ccp(rect.origin.x, rect.origin.y);
    CGPoint upperLeft = ccp(rect.origin.x, rect.origin.y+rect.size.height);
    CGPoint lowerRight = ccp(rect.origin.x+rect.size.width, rect.origin.y);
    CGPoint upperRight = ccp(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    return ([self isWallAtPosition:lowerLeft] || [self isWallAtPosition:upperLeft] ||
            [self isWallAtPosition:lowerRight] || [self isWallAtPosition:upperRight]);
}

-(id) initWithHUDLayer:(HUDLayer *)hudLayer
{
	if( (self=[super init])) {
		
        _hudLayer = hudLayer;
        
        _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"tanks.tmx"];
        [self addChild:_tileMap];
        
        _bgLayer = [_tileMap layerNamed:@"Background"];
        
        CGPoint spawnTileCoord = ccp(4,4);
        CGPoint spawnPos = [self positionForTileCoord:spawnTileCoord];
        [self setViewpointCenter:spawnPos];
        
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
        [_tileMap addChild:_batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        
        self.tank = [[Tank alloc] initWithLayer:self type:1 hp:5];
        self.tank.position = spawnPos;
        [_batchNode addChild:self.tank];
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgMusic.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explode1.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank1Shoot.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"tank2Shoot.wav"];
        
        _enemyTanks = [NSMutableArray array];
        int NUM_ENEMY_TANKS = 50;
        for (int i = 0; i < NUM_ENEMY_TANKS; ++i) {
            
            RandomTank * enemy = [[RandomTank alloc] initWithLayer:self type:2 hp:2];
            CGPoint randSpot;
            BOOL inWall = YES;
            
            while (inWall) {
                randSpot.x = CCRANDOM_0_1() * [self tileMapWidth];
                randSpot.y = CCRANDOM_0_1() * [self tileMapHeight];
                inWall = [self isWallAtPosition:randSpot];
            }
            
            enemy.position = randSpot;
            [_batchNode addChild:enemy];
            [_enemyTanks addObject:enemy];
            
        }
        
        _explosion = [CCParticleSystemQuad particleWithFile:@"explosion.plist"];
        [_explosion stopSystem];
        [_tileMap addChild:_explosion z:1];
        
        _explosion2 = [CCParticleSystemQuad particleWithFile:@"explosion2.plist"];
        [_explosion2 stopSystem];
        [_tileMap addChild:_explosion2 z:1];
        
        _exit = [CCSprite spriteWithSpriteFrameName:@"exit.png"];
        CGPoint exitTileCoord = ccp(98, 98);
        CGPoint exitTilePos = [self positionForTileCoord:exitTileCoord];
        _exit.position = exitTilePos;
        [_batchNode addChild:_exit];
        
        self.scale = 0.5;
        
        [_hudLayer setHp:self.tank.hp];
        
    }
    return self;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver) return;
    
    UITouch * touch = [touches anyObject];
    CGPoint mapLocation = [_tileMap convertTouchToNodeSpace:touch];
    
    self.tank.shooting = YES;
    [self.tank shootToward:mapLocation];
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver) return;
    
    UITouch * touch = [touches anyObject];
    CGPoint mapLocation = [_tileMap convertTouchToNodeSpace:touch];
    
    self.tank.shooting = YES;
    [self.tank shootToward:mapLocation];
    
}

- (void)restartTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}

- (void)endScene:(EndReason)endReason {
    
    if (_gameOver) return;
    _gameOver = true;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (endReason == kEndReasonWin) {
        message = @"You win!";
    } else if (endReason == kEndReasonLose) {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"TanksFont.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"TanksFont.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.7);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"TanksFont.fnt"];
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"TanksFont.fnt"];
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.3);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:4.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:4.0]];
    
}


- (void)update:(ccTime)dt {
    
    if (_gameOver) return;
    
    [_hudLayer pointFrom:_tank.position to:_exit.position];
    
    if (CGRectIntersectsRect(_exit.boundingBox, _tank.boundingBox)) {
        [self endScene:kEndReasonWin];
    }
    
    NSMutableArray * childrenToRemove = [NSMutableArray array];
    for (CCSprite * sprite in self.batchNode.children) {
        if (sprite.tag != 0) { // bullet
            if ([self isWallAtPosition:sprite.position]) {
                [childrenToRemove addObject:sprite];
                continue;
            }
            if (sprite.tag == 1) { // hero bullet
                for (int j = _enemyTanks.count - 1; j >= 0; j--) {
                    Tank *enemy = [_enemyTanks objectAtIndex:j];
                    if (CGRectIntersectsRect(sprite.boundingBox, enemy.boundingBox)) {
                        
                        [childrenToRemove addObject:sprite];
                        enemy.hp--;
                        if (enemy.hp <= 0) {
                            [[SimpleAudioEngine sharedEngine] playEffect:@"explode3.wav"];
                            _explosion.position = enemy.position;
                            [_explosion resetSystem];
                            [_enemyTanks removeObject:enemy];
                            [childrenToRemove addObject:enemy];
                        } else {
                            [[SimpleAudioEngine sharedEngine] playEffect:@"explode2.wav"];
                        }
                    }
                }
            }
            if (sprite.tag == 2) { // enemy bullet
                if (CGRectIntersectsRect(sprite.boundingBox, self.tank.boundingBox)) {
                    [childrenToRemove addObject:sprite];
                    self.tank.hp--;
                    [_hudLayer setHp:self.tank.hp];
                    
                    if (self.tank.hp <= 0) {
                        [[SimpleAudioEngine sharedEngine] playEffect:@"explode2.wav"];
                        _explosion.position = self.tank.position;
                        [_explosion resetSystem];
                        [self endScene:kEndReasonLose];
                    } else {
                        _explosion2.position = self.tank.position;
                        [_explosion2 resetSystem];
                        [[SimpleAudioEngine sharedEngine] playEffect:@"explode1.wav"];
                    }
                }
            }
        }
    }
    for (CCSprite * child in childrenToRemove) {
        [child removeFromParentAndCleanup:YES];
    }
    
    [self setViewpointCenter:self.tank.position];
    
}

- (void)onEnterTransitionDidFinish {
    
    self.isAccelerometerEnabled = YES;
    
}

- (void)accelerometer:(UIAccelerometer *)accelerometer
        didAccelerate:(UIAcceleration *)acceleration {
    
    if (_gameOver) return;
    
#define kFilteringFactor 0.75
    static UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    
    rollingX = (acceleration.x * kFilteringFactor) +
    (rollingX * (1.0 - kFilteringFactor));
    rollingY = (acceleration.y * kFilteringFactor) +
    (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (acceleration.z * kFilteringFactor) +
    (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = rollingX;
    float accelY = rollingY;
    float accelZ = rollingZ;
    
    CGPoint moveTo = _tank.position;
    if (accelX > 0.5) {
        moveTo.y -= 300;
    } else if (accelX < 0.4) {
        moveTo.y += 300;
    }
    if (accelY < -0.1) {
        moveTo.x -= 300;
    } else if (accelY > 0.1) {
        moveTo.x += 300;
    }
    _tank.moving = YES;
    [_tank moveToward:moveTo];
    
    //NSLog(@"accelX: %f, accelY: %f", accelX, accelY);
    
}

// on "dealloc" you need to release all your retained objects
@end
