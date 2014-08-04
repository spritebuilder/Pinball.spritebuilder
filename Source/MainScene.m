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

#import "MainScene.h"

@implementation MainScene

// Called when the (invisible, full screen) play button is tapped
- (void) pressedPlay:(CCButton*)button
{
    // Hide the button so it cannot be tapped
    _playButton.visible = NO;
    
    // Start the game!
    [self.board startGame];
}

// Called by the board on game over
- (void) handleGameOver
{
    // Enable the play button after three seconds and display a blinking game over label
    [self scheduleOnce:@selector(enablePlayButton) delay:3];
    [self.lblInfo runAction:[CCActionBlink actionWithDuration:3 blinks:9]];
    
}

// Enables the play button
- (void) enablePlayButton
{
    _playButton.visible = YES;
    self.lblInfo.string = @"tap to play";
}

@end
