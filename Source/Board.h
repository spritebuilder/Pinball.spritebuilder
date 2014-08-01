//
//  Board.h
//  Pinball
//
//  Created by Viktor on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class Bumper;
@class MainScene;

@interface Board : CCPhysicsNode <CCPhysicsCollisionDelegate>
{
    NSMutableSet* _hitTargets;
    
    CCSprite* _ball;
    CCSprite* _ballShadow;
    CGPoint _ballInitialPos;
    
    CCSprite* _reflectionMap;
    
    NSArray* _bumpers;
    NSArray* _lights;
    
    Bumper* _jackpotBumper;
    
    CCNode* _endJackpot;
    BOOL _jackpotTaken;
    BOOL _jackpotEnabled;
    
    int _score;
    BOOL _gameRunning;
    int _ballCount;
    
    CMMotionManager* _motionManager;
    CGPoint _accelerometerReading;
}

@property (nonatomic,readonly) MainScene* mainScene;

- (void) startGame;

@end
