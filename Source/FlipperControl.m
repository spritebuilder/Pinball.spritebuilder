//
//  TouchControl.m
//  Pinball
//
//  Created by Viktor on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "FlipperControl.h"
#import "Board.h"
#import "Flipper.h"
#import "MainScene.h"

@implementation FlipperControl

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.userInteractionEnabled = YES;
    self.exclusiveTouch = NO;
    
    return self;
}

- (void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[self flipper] activate];
}

- (void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[self flipper] deactivate];
}

- (Flipper*) flipper
{
    MainScene* main = (MainScene*) self.parent;
    Board* board = main.board;
    
    return (Flipper*)[board getChildByName:self.name recursively:YES];
}

@end
