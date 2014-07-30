//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void) pressedPlay:(CCButton*)button
{
    _playButton.visible = NO;
    
    [self.board startGame];
}

- (void) handleGameOver
{
    [self scheduleOnce:@selector(enablePlayButton) delay:3];
    
    [self.lblInfo runAction:[CCActionBlink actionWithDuration:3 blinks:9]];
    
}

- (void) enablePlayButton
{
    _playButton.visible = YES;
    self.lblInfo.string = @"tap to play";
}

@end
