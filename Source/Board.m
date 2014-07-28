//
//  Board.m
//  Pinball
//
//  Created by Viktor on 7/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Board.h"
#import "CCEffect.h"
#import "CCEffectReflection.h"
#import "Bumper.h"
#import "Light.h"

#define SCROLL_DAMPENING 0.1

@implementation Board

- (void) didLoadFromCCB
{
    self.userInteractionEnabled = YES;
    
    self.gravity = ccp(0, -100);
    
    _ballInitialPos = _ball.position;
    
    // Setup reflection effect on the ball
    CCEffectReflection* effect = [CCEffectReflection effectWithEnvironment:_reflectionMap normalMap:NULL];
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
    
    [self launchBall];
}

- (void) fixedUpdate:(CCTime)delta
{
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
    [self launchBall];
    
    return NO;
}

- (BOOL) ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair ball:(CCNode *)ball target:(CCNode *)target
{
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

- (Light*) getLightNamed:(NSString*)name
{
    for (Light* light in _lights)
    {
        if ([light.name isEqualToString:name]) return light;
    }
    
    return NULL;
}


@end
