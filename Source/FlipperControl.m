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
