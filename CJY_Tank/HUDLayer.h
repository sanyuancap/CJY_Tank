//
//  HUDLayer.h
//  Tanks
//
//  Created by Ray Wenderlich on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface HUDLayer : CCLayer {
    CCLabelBMFont * _hpLabel;  
    CCSprite * _arrow;
}

- (void)setHp:(int)hp;
- (void)pointFrom:(CGPoint)from to:(CGPoint)to;

@end
