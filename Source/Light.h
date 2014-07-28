//
//  Light.h
//  Pinball
//
//  Created by Viktor on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Light : CCSprite
{
    NSArray* _onSprites;
    
    BOOL _jackpotFlash;
    BOOL _cycling;
    BOOL _isOn;
    int _subLights;
    
    long _frame;
    long _flashFrame;
    int _cycleLight;
}

- (void) didLoadFromCCB;

- (void) activate;

- (void) deactivate;

- (void) flash;

- (void) activateSubLights:(int)num;

- (void) cycle;

- (void) stopCycle;

- (void) jackpotFlash;

@end
