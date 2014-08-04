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

#import "Flipper.h"

@implementation Flipper

// Activate the flipper
- (void) activate
{
    // Figure out if it's the left or right flipper
    BOOL left = [self.name isEqualToString:@"flipperLeft"];
    
    // Up the elasticity of the flipper physics body to make it more bouncy when activated (this is to simulate the flipper moving at a faster speed that it actually is)
    self.physicsBody.elasticity = 2.0;
    
    // Calculate the destination angle based on if it's the left or right flipper
    float angle = 40;
    if (left) angle = -angle;
    
    // Animate the flipper
    [self stopAllActions];
    [self runAction:[CCActionRotateTo actionWithDuration:0.05 angle:angle]];
    
    // Reset the elasticiy as soon as the flipper is at it's top position
    [self scheduleOnce:@selector(resetElasticity) delay:0.1];
}

// Deactivate the flipper
- (void) deactivate
{
    // Return flipper to it's original position
    [self stopAllActions];
    [self runAction:[CCActionRotateTo actionWithDuration:0.1 angle:0]];
    
    // Reset elasticity
    self.physicsBody.elasticity = 0.1;
}

- (void) resetElasticity
{
    self.physicsBody.elasticity = 0.1;
}

@end
