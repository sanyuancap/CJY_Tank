//
//  RandomTank.m
//  Tanks
//
//  Created by Ray Wenderlich on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RandomTank.h"
#import "HelloWorldLayer.h"

@implementation RandomTank

- (id)initWithLayer:(HelloWorldLayer *)layer type:(int)type hp:(int)hp {
    
    if ((self = [super initWithLayer:layer type:type hp:hp])) {
        [self schedule:@selector(move:) interval:0.5];
    }
    return self;
    
}

- (BOOL)shouldShoot {
    
    if (ccpDistance(self.position, _layer.tank.position) > 600) return NO;
    
    if (_timeSinceLastShot > _timeForNextShot) {        
        _timeSinceLastShot = 0;
        _timeForNextShot = (CCRANDOM_0_1() * 3) + 1;
        [self shootToward:_layer.tank.position];
        return YES;
    } else {
        return NO;
    }
}

// From http://playtechs.blogspot.com/2007/03/raytracing-on-grid.html
- (BOOL)clearPathFromTileCoord:(CGPoint)start toTileCoord:(CGPoint)end
{
    int dx = abs(end.x - start.x);
    int dy = abs(end.y - start.y);
    int x = start.x;
    int y = start.y;
    int n = 1 + dx + dy;
    int x_inc = (end.x > start.x) ? 1 : -1;
    int y_inc = (end.y > start.y) ? 1 : -1;
    int error = dx - dy;
    dx *= 2;
    dy *= 2;
    
    for (; n > 0; --n)
    {
        if ([_layer isWallAtTileCoord:ccp(x, y)]) return FALSE;
        
        if (error > 0)
        {
            x += x_inc;
            error -= dy;
        }
        else
        {
            y += y_inc;
            error += dx;
        }
    }
    
    return TRUE;
}

- (void)calcNextMove {
    
    BOOL moveOK = NO;
    CGPoint start = [_layer tileCoordForPosition:self.position];
    CGPoint end;
    
    while (!moveOK) {
        
        end = start;
        end.x += CCRANDOM_MINUS1_1() * ((arc4random() % 10) + 3);
        end.y += CCRANDOM_MINUS1_1() * ((arc4random() % 10) + 3);
        
        moveOK = [self clearPathFromTileCoord:start toTileCoord:end];    
    }    
    
    CGPoint moveToward = [_layer positionForTileCoord:end];
    
    self.moving = YES;
    [self moveToward:moveToward];    
    
}


- (void)move:(ccTime)dt {
    
    if (self.moving && arc4random() % 3 != 0) return;    
    [self calcNextMove];
    
}

@end
