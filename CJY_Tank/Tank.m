//
//  Tank.m
//  Tanks
//
//  Created by Ray Wenderlich on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "Tank.h"
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

@implementation Tank
@synthesize moving = _moving;
@synthesize hp = _hp;
@synthesize shooting = _shooting;

- (id)initWithLayer:(HelloWorldLayer *)layer type:(int)type hp:(int)hp {
    
    NSString *spriteFrameName = [NSString stringWithFormat:@"tank%d_base.png", type];    
    if ((self = [super initWithSpriteFrameName:spriteFrameName])) {
        _layer = layer;
        _type = type;
        self.hp = hp;     
        [self scheduleUpdateWithPriority:-1];
        
        NSString *turretName = [NSString stringWithFormat:@"tank%d_turret.png", type];
        _turret = [CCSprite spriteWithSpriteFrameName:turretName];
        _turret.anchorPoint = ccp(0.5, 0.25);
        _turret.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
        [self addChild:_turret];
        
    }
    return self;
}

- (void)moveToward:(CGPoint)targetPosition {    
    _targetPosition = targetPosition;                    
}

- (void)calcNextMove {
    
}

- (void)updateMove:(ccTime)dt {
    
    if (!self.moving) return;
    
    CGPoint offset = ccpSub(_targetPosition, self.position);
    float MIN_OFFSET = 10;
    if (ccpLength(offset) < MIN_OFFSET) return;
    
    CGPoint targetVector = ccpNormalize(offset);    
    float POINTS_PER_SECOND = 150;
    CGPoint targetPerSecond = ccpMult(targetVector, POINTS_PER_SECOND);
    CGPoint actualTarget = ccpAdd(self.position, ccpMult(targetPerSecond, dt));
    
    CGPoint oldPosition = self.position;
    self.position = actualTarget;  

    if ([_layer isWallAtRect:[self boundingBox]]) {
        self.position = oldPosition;
        [self calcNextMove];
    }    
    
}

- (void)shootToward:(CGPoint)targetPosition {
    
    CGPoint offset = ccpSub(targetPosition, self.position);
    float MIN_OFFSET = 10;
    if (ccpLength(offset) < MIN_OFFSET) return;
    
    _shootVector = ccpNormalize(offset);

}

- (void)shootNow {
    CGFloat angle = ccpToAngle(_shootVector);
    _turret.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle)) + 90;
    
    float mapMax = MAX([_layer tileMapWidth], [_layer tileMapHeight]);
    CGPoint actualVector = ccpMult(_shootVector, mapMax);  
    
    float POINTS_PER_SECOND = 300;
    float duration = mapMax / POINTS_PER_SECOND;
    
    NSString * shootSound = [NSString stringWithFormat:@"tank%dShoot.wav", _type];
    [[SimpleAudioEngine sharedEngine] playEffect:shootSound];
    
    NSString *bulletName = [NSString stringWithFormat:@"tank%d_bullet.png", _type];
    CCSprite * bullet = [CCSprite spriteWithSpriteFrameName:bulletName];
    bullet.tag = _type;
    bullet.position = ccpAdd(self.position, ccpMult(_shootVector, _turret.contentSize.height));        
    CCMoveBy * move = [CCMoveBy actionWithDuration:duration position:actualVector];
    CCCallBlockN * call = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    [bullet runAction:[CCSequence actions:move, call, nil]];
    [_layer.batchNode addChild:bullet];
}

- (BOOL)shouldShoot {
    
    if (!self.shooting) return NO;    
    
    double SECS_BETWEEN_SHOTS = 0.25;
    if (_timeSinceLastShot > SECS_BETWEEN_SHOTS) {        
        _timeSinceLastShot = 0;
        return YES;        
    } else {
        return NO;
    }
}

- (void)updateShoot:(ccTime)dt {
    
    _timeSinceLastShot += dt;
    if ([self shouldShoot]) {       
        [self shootNow];        
    }
    
}

- (void)update:(ccTime)dt {    
    [self updateMove:dt];      
    [self updateShoot:dt];
}


@end