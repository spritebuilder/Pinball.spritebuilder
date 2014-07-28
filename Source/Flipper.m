//
//  Flipper.m
//  Pinball
//
//  Created by Viktor on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Flipper.h"

@implementation Flipper

- (void) activate
{
    BOOL left = [self.name isEqualToString:@"flipperLeft"];
    
    self.physicsBody.elasticity = 2.0;
    
    float angle = 40;
    if (left) angle = -angle;
    
    [self stopAllActions];
    [self runAction:[CCActionRotateTo actionWithDuration:0.05 angle:angle]];
    
    [self scheduleOnce:@selector(resetElasticity) delay:0.1];
}

- (void) deactivate
{
    [self stopAllActions];
    [self runAction:[CCActionRotateTo actionWithDuration:0.1 angle:0]];
    
    self.physicsBody.elasticity = 0.1;
}

- (void) resetElasticity
{
    self.physicsBody.elasticity = 0.1;
}

@end
