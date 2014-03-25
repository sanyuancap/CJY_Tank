//
//  HUDLayer.m
//  Tanks
//
//  Created by Ray Wenderlich on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

@implementation HUDLayer

- (id) init {
    
    if ((self = [super init])) {
        
        _hpLabel = [CCLabelBMFont labelWithString:@"HP: XXX" fntFile:@"TanksFont.fnt"];
        _hpLabel.position = ccp(430, 275);
        [self addChild:_hpLabel];

        CCSpriteBatchNode * batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
        [self addChild:batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        
        CCLabelBMFont * exitLabel = [CCLabelBMFont labelWithString:@"Exit:" fntFile:@"TanksFont.fnt"];
        exitLabel.position = ccp(420, 303);
        [self addChild:exitLabel];
        
        _arrow = [CCSprite spriteWithSpriteFrameName:@"arrow.png"];
        _arrow.scale = 0.50;
        _arrow.position = ccp(460, 300);
        [batchNode addChild:_arrow];
        
    }
    
    return self;
    
}

- (void)setHp:(int)hp {
    
    [_hpLabel setString:[NSString stringWithFormat:@"HP: %02d", hp]];
    
}

- (void)pointFrom:(CGPoint)from to:(CGPoint)to {
    
    CGFloat angle = ccpToAngle(ccpSub(to, from));
    _arrow.rotation = (-1 * CC_RADIANS_TO_DEGREES(angle));
    
}

@end
