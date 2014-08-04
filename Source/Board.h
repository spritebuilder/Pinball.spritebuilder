/*
 * SpriteBuilder: http://www.spritebuilder.com
 *
 * Copyright (c) 2014 Apportable
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@class Bumper;
@class MainScene;

@interface Board : CCPhysicsNode <CCPhysicsCollisionDelegate>
{
    // Keeps a set with the currently lit targets (to easily count them)
    NSMutableSet* _hitTargets;
    
    // A reference to the ball sprite and it's shadow
    CCSprite* _ball;
    CCSprite* _ballShadow;
    
    // The initial position of the ball
    CGPoint _ballInitialPos;
    
    // The image that is reflected in the ball
    CCSprite* _reflectionMap;
    
    // Lists of different game elements, for easy iteration
    NSArray* _bumpers;
    NSArray* _lights;
    
    // The jackpot bumper
    Bumper* _jackpotBumper;
    
    // Reference to the end jackpot sensor
    CCNode* _endJackpot;
    
    // Jackpot state
    BOOL _jackpotTaken;
    BOOL _jackpotEnabled;
    
    // Game state
    int _score;
    BOOL _gameRunning;
    int _ballCount;
    
    // Accelerometer helpers
    CMMotionManager* _motionManager;
    CGPoint _accelerometerReading;
}

@property (nonatomic,readonly) MainScene* mainScene;

// Called by MainScene to start the game
- (void) startGame;

@end
