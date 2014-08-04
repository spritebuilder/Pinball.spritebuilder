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

// The Board class is where we handle most of the game logic. The startGame method is called by the MainScene to start the game. When the game is over, the MainScene's handleGameOver method is called. The board inherits from the CCPhysicsNode.

#import "Board.h"
#import "CCEffect.h"
#import "CCEffectReflection.h"
#import "Bumper.h"
#import "Light.h"
#import "MainScene.h"

#define SCROLL_DAMPENING 0.1
#define GRAVITY_FIXED -100
#define GRAVITY_ACCEL 100

#define NUM_BALLS 3
#define NUM_JACKPOT_LIGHTS 7

@implementation Board

#pragma mark Initialization

// The didLoadFromCCB method is called when a CCB file is loaded, and the game is ready to be run.
- (void) didLoadFromCCB
{
    // Setup default gravity in this scene
    self.gravity = ccp(0, -100);
    
    // Remember the initial position of the ball, so we can reset it
    _ballInitialPos = _ball.position;
    
    // Setup reflection effect on the ball
    CCEffectReflection* effect = [CCEffectReflection effectWithShininess:0.7 environment:_reflectionMap];
    effect.fresnelBias = 0.3;
    effect.fresnelPower = 0.5;
    
    _ball.normalMapSpriteFrame = [CCSpriteFrame frameWithImageNamed:@"Items/ball-normal.png"];
    _ball.effect = effect;
    
    // Create arrays game objects
    _bumpers = [self findChildrenOfClass:[Bumper class]];
    _lights = [self findChildrenOfClass:[Light class]];
    
    // Turn off all lights
    for (Light* light in _lights)
    {
        [light deactivate];
    }
    
    // Setup targets
    _hitTargets = [NSMutableSet set];
    
    // Setup sensors
    _endJackpot.physicsBody.sensor = YES;
    
    // Setup the collision delegate so we get callbacks for any collisions
    self.collisionDelegate = self;
    
    // Setup scoring
    self.mainScene.lblInfo.string = @"tap to play";
    self.mainScene.lblScore.string = @"0";
    
    // Setup accelerometer
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 1.0/60.0;
    
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 _accelerometerReading = ccp( accelerometerData.acceleration.y, -accelerometerData.acceleration.x);
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}

#pragma mark Game Loop

// The fixedUpdate method is called every frame in the game
- (void) fixedUpdate:(CCTime)delta
{
    // Update gravitation based on acceleromenter
    CGPoint accel = [self readAccelerometer];
    float xAccel = clampf(accel.x, -0.5, 0.5) * GRAVITY_ACCEL;
    self.gravity = ccp(xAccel * 2, GRAVITY_FIXED);
    
    // Center board relative ball
    float screenHeight = self.parent.contentSizeInPoints.height;
    
    float ballPosY = _ball.position.y;
    
    float minTarget = - (self.contentSizeInPoints.height - screenHeight);
    
    float targetY = -ballPosY + screenHeight/2;
    if (targetY > 0) targetY = 0;
    if (targetY < minTarget) targetY = minTarget;
    
    float oldPos = self.position.y;
    
    // Apply dampening to the scrolling of the view
    float posY = targetY * SCROLL_DAMPENING + oldPos * (1.0 - SCROLL_DAMPENING);
    
    self.position = ccp(0.5, posY);
    
    // Handle physics simulation in the super method
    [super fixedUpdate:delta];
    
    // Update the position of the balls shadow to match the ball
    _ballShadow.position = _ball.position;
    
    // Prevent ball physics body to fall asleep, even if it stays in the same position
    _ball.physicsBody.sleeping = NO;
}

#pragma mark Collison detection callbacks

// Collision between ball and bumper
- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball bumper:(Bumper *)bumper
{
    // Add score and flash the bumper
    [self addScore:[bumper.name intValue]];
    [bumper flash];
    
    return YES;
}

- (BOOL) ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA bumper:(CCNode *)nodeB
{
    // We up the restitution to ensure we will get a good direction vector (otherwise, if the impact is very small the direction will not be from the center of the bumper
    pair.restitution = 10;
    return YES;
}

- (void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball bumper:(Bumper *)bumper
{
    // Apply a random velocity (withing a specific range) to the ball after it hit the bumper
    CGPoint velocity = ball.physicsBody.velocity;
    ball.physicsBody.velocity = ccpMult(ccpNormalize(velocity),300 + CCRANDOM_0_1()*100);
}

// Collision between the ball and the bottom (basically, lose a life)
- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball bottom:(CCNode *)bumper
{
    if (_ballCount < NUM_BALLS)
    {
        // We still have balls left, launch a new one!
        [self launchBall];
        _ballCount ++;
        [self updateBallCount];
    }
    else
    {
        // It's game over :/
        [self gameOver];
    }
    
    return NO;
}

// Collision between ball and a target (the targets are used to spell JACKPOT)
- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball target:(CCNode *)target
{
    [self addScore:200];
    
    // Find the corresponding light and activate it
    Light* light = [self getLightNamed:[target.name stringByAppendingString:@"light"]];
    [light activate];
    
    // Keep a set of activated targets (so that we can count the number of lit targets easily)
    [_hitTargets addObject:target.name];
    
    // Spell JACKPOT
    [[self getLightNamed:@"jackpotSpellLight"] activateSubLights: _hitTargets.count];
    
    // If all targets are activated, enable the jackpot!
    if (_hitTargets.count == NUM_JACKPOT_LIGHTS)
    {
        [self enableJackpot];
    }
    
    return YES;
}

// Collision between ball and endJackpot area (this is a sensor located under the retractable jackpot bumper)
- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA endJackpot:(CCNode *)nodeB
{
    // If the jackpot is taken, end the jackpot sequence
    if (_jackpotTaken)
    {
        [self endJackpot];
    }
    return YES;
}

// Collision between ball and jackpot target
- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA jackpot:(CCNode *)nodeB
{
    [self takeJackpot];
    return YES;
}

#pragma mark Game Events

// Starts the game!
- (void) startGame
{
    // Reset score
    _score = 0;
    self.mainScene.lblScore.string = @"0";
    
    // Reset ball count
    _ballCount = 1;
    [self updateBallCount];
    
    // Launch ball and start game
    [self launchBall];
    _gameRunning = YES;
}

// Ends the game
- (void) gameOver
{
    self.mainScene.lblInfo.string = @"game over";
    
    [self.mainScene handleGameOver];
    _gameRunning = NO;
}

// Launches a new ball
- (void) launchBall
{
    // Set the ball to it's inital start position
    _ball.position = _ballInitialPos;
    
    // Set the balls speed to zero
    _ball.physicsBody.velocity = ccp(0,0);
    
    // Apply a force to launch the ball
    [_ball.physicsBody applyForce:ccp(0, 40000 + CCRANDOM_0_1()*20000)];
    
    // If the jackpot is enabled, disable it
    if (_jackpotEnabled)
    {
        [self endJackpot];
    }
}

// Enables the jackpot (when all targets are hit)
- (void) enableJackpot
{
    // Retract the jackpot bumper
    _jackpotBumper.visible = NO;
    _jackpotBumper.physicsBody.sensor = YES;
    _jackpotEnabled = YES;
    
    // Cycle the jackpot lights
    [[self getLightNamed:@"jackpotSpellLight"] cycle];
    [[self getLightNamed:@"jackpotLight"] cycle];
}

// Called when the jackpot target is hit
- (void) takeJackpot
{
    [self addScore:1000000];
    
    _jackpotTaken = YES;
    
    // Flash all the lights on the board!
    for (Light* light in _lights)
    {
        [light jackpotFlash];
    }
}

// End the jackpot
- (void) endJackpot
{
    // Re-add the jackpot bumper
    _jackpotBumper.visible = YES;
    _jackpotBumper.physicsBody.sensor = NO;
    _jackpotTaken = NO;
    _jackpotEnabled = NO;
    
    // Reset target lights and JACKPOT spelling
    [[self getLightNamed:@"jackpotSpellLight"] activateSubLights:0];
    [[self getLightNamed:@"jackpotSpellLight"] stopCycle];
    [[self getLightNamed:@"jackpotLight"] stopCycle];
    
    for (int i = 0; i < 7; i++)
    {
        [[self getLightNamed:[NSString stringWithFormat:@"target%dlight", i]] deactivate];
    }
    
    // Clear set of taken targets
    [_hitTargets removeAllObjects];
}

#pragma mark Score and Ball Count Labels

// Add score and update label
- (void) addScore:(int)score
{
    _score += score;
    self.mainScene.lblScore.string = [NSString stringWithFormat:@"%d", _score];
}

// Refresh the ball count label
- (void) updateBallCount
{
    self.mainScene.lblInfo.string = [NSString stringWithFormat:@"ball %d", _ballCount];
}

#pragma mark Helper Methods

// Return the main scene
- (MainScene*) mainScene
{
    return (MainScene*)self.parent;
}

// Retrieve the latest accelerometer reading
- (CGPoint) readAccelerometer
{
    return _accelerometerReading;
}

// Find a light by it's name
- (Light*) getLightNamed:(NSString*)name
{
    for (Light* light in _lights)
    {
        if ([light.name isEqualToString:name]) return light;
    }
    
    return NULL;
}

// Return all children of a specific class (used to create lists of lights and bumpers)
- (NSArray*) findChildrenOfClass:(Class)class
{
    NSMutableArray* nodes = [NSMutableArray array];
    [self addChildrenOfClass:class toArray:nodes forNode:self];
    return nodes;
}

- (void) addChildrenOfClass:(Class)class toArray:(NSMutableArray*)array forNode:(CCNode*)node
{
    for (CCNode* child in node.children)
    {
        if ([child isKindOfClass:class])
        {
            [array addObject:child];
        }
        
        [self addChildrenOfClass:class toArray:array forNode:child];
    }
}

@end
