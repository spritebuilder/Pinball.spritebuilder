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

#import "Board.h"
#import "CCEffect.h"
#import "CCEffectReflection.h"
#import "Bumper.h"
#import "Light.h"
#import "MainScene.h"

#define SCROLL_DAMPENING 0.1
#define GRAVITY_FIXED -100
#define GRAVITY_ACCEL 100

@implementation Board

- (void) didLoadFromCCB
{
    self.userInteractionEnabled = YES;
    
    self.gravity = ccp(0, -100);
    
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
    
    float posY = targetY * SCROLL_DAMPENING + oldPos * (1.0 - SCROLL_DAMPENING);
    
    self.position = ccp(0.5, posY);
    
    [super fixedUpdate:delta];
    
    _ballShadow.position = _ball.position;
}

- (void) launchBall
{
    _ball.position = _ballInitialPos;
    _ball.physicsBody.velocity = ccp(0,0);
    [_ball.physicsBody applyForce:ccp(0, 40000 + CCRANDOM_0_1()*20000)];
    
    if (_jackpotEnabled)
    {
        [self endJackpot];
    }
}

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

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball bumper:(Bumper *)bumper
{
    [self addScore:[bumper.name intValue]];
    [bumper flash];
    
    return YES;
}


- (BOOL) ccPhysicsCollisionPreSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA bumper:(CCNode *)nodeB
{
    pair.restitution = 10;
    return YES;
}

- (void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball bumper:(Bumper *)bumper
{
    CGPoint velocity = ball.physicsBody.velocity;
    ball.physicsBody.velocity = ccpMult(ccpNormalize(velocity),300 + CCRANDOM_0_1()*100);
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball bottom:(CCNode *)bumper
{
    if (_ballCount < 3)
    {
        [self launchBall];
        _ballCount ++;
        [self updateBallCount];
    }
    else
    {
        [self gameOver];
    }
    
    return NO;
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball target:(CCNode *)target
{
    [self addScore:200];
    
    Light* light = [self getLightNamed:[target.name stringByAppendingString:@"light"]];
    
    [light activate];
    
    [_hitTargets addObject:target.name];
    [[self getLightNamed:@"jackpotSpellLight"] activateSubLights: _hitTargets.count];
    
    if (_hitTargets.count == 7)
    {
        [self enableJackpot];
    }
    
    return YES;
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA endJackpot:(CCNode *)nodeB
{
    if (_jackpotTaken)
    {
        [self endJackpot];
    }
    return YES;
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)nodeA jackpot:(CCNode *)nodeB
{
    [self takeJackpot];
    return YES;
}

- (void) enableJackpot
{
    _jackpotBumper.visible = NO;
    _jackpotBumper.physicsBody.sensor = YES;
    _jackpotEnabled = YES;
    
    [[self getLightNamed:@"jackpotSpellLight"] cycle];
    [[self getLightNamed:@"jackpotLight"] cycle];
}

- (void) takeJackpot
{
    [self addScore:1000000];
    
    _jackpotTaken = YES;
    
    for (Light* light in _lights)
    {
        [light jackpotFlash];
    }
}

- (void) endJackpot
{
    _jackpotBumper.visible = YES;
    _jackpotBumper.physicsBody.sensor = NO;
    _jackpotTaken = NO;
    _jackpotEnabled = NO;
    
    [[self getLightNamed:@"jackpotSpellLight"] activateSubLights:0];
    [[self getLightNamed:@"jackpotSpellLight"] stopCycle];
    [[self getLightNamed:@"jackpotLight"] stopCycle];
    
    for (int i = 0; i < 7; i++)
    {
        [[self getLightNamed:[NSString stringWithFormat:@"target%dlight", i]] deactivate];
    }
    
    [_hitTargets removeAllObjects];
    
}

- (void) addScore:(int)score
{
    _score += score;
    self.mainScene.lblScore.string = [NSString stringWithFormat:@"%d", _score];
}

- (void) updateBallCount
{
    self.mainScene.lblInfo.string = [NSString stringWithFormat:@"ball %d", _ballCount];
}

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

- (void) gameOver
{
    self.mainScene.lblInfo.string = @"game over";
    
    [self.mainScene handleGameOver];
    _gameRunning = NO;
}

- (Light*) getLightNamed:(NSString*)name
{
    for (Light* light in _lights)
    {
        if ([light.name isEqualToString:name]) return light;
    }
    
    return NULL;
}

- (MainScene*) mainScene
{
    return (MainScene*)self.parent;
}

- (CGPoint) readAccelerometer
{
    return _accelerometerReading;
}

@end
