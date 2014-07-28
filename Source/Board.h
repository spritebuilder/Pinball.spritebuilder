//
//  Board.h
//  Pinball
//
//  Created by Viktor on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Bumper;

@interface Board : CCPhysicsNode <CCPhysicsCollisionDelegate>
{
    NSMutableSet* _hitTargets;
    
    CCSprite* _ball;
    CGPoint _ballInitialPos;
    
    CCSprite* _reflectionMap;
    
    NSArray* _bumpers;
    NSArray* _lights;
    
    Bumper* _jackpotBumper;
    
    CCNode* _endJackpot;
    BOOL _jackpotTaken;
    BOOL _jackpotEnabled;
}

@end
