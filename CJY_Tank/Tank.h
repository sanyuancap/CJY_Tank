//
//  Tank.h
//  Tanks
//
//  Created by Ray Wenderlich on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
@class HelloWorldLayer;

@interface Tank : CCSprite {
    int _type;
    HelloWorldLayer * _layer;
    CGPoint _targetPosition;
    CGPoint _shootVector;
    double _timeSinceLastShot;
    CCSprite * _turret;
}

@property (assign) BOOL moving;
@property (assign) BOOL shooting;
@property (assign) int hp;

- (id)initWithLayer:(HelloWorldLayer *)layer type:(int)type hp:(int)hp;
- (void)moveToward:(CGPoint)targetPosition;
- (void)shootToward:(CGPoint)targetPosition;
- (void)shootNow;

@end
