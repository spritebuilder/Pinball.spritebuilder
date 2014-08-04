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

#import "Light.h"

@implementation Light

- (void) didLoadFromCCB
{
    _onSprites = self.children;
}

- (void) deactivate
{
    for (CCSprite* onSprite in _onSprites)
    {
        [onSprite stopAllActions];
        onSprite.opacity = 0;
    }
    
    _isOn = NO;
}

- (void) flash
{
    if (_isOn) return;
    
    for (CCSprite* onSprite in _onSprites)
    {
        [onSprite stopAllActions];
        onSprite.opacity = 0;
        
        CCActionFadeOut* fadeOut = [CCActionFadeOut actionWithDuration:0.5];
        fadeOut.tag = 1;
        [onSprite runAction:fadeOut];
    }
}

- (void) activate
{
    _isOn = YES;
    
    for (CCSprite* onSprite in _onSprites)
    {
        [onSprite stopAllActions];
        onSprite.opacity = 1;
    }
}

- (void) activateSubLights:(int)num
{
    int i = 0;
    
    for (CCSprite* onSprite in _onSprites)
    {
        [onSprite stopAllActions];
        
        if (i < num)
        {
            onSprite.opacity = 0.5;
        }
        else
        {
            onSprite.opacity = 0;
        }
        
        i++;
    }
    
    _subLights = num;
}

- (void) fixedUpdate:(CCTime)delta
{
    if (_jackpotFlash)
    {
        for (CCSprite* onSprite in _onSprites)
        {
            if ((_flashFrame % 20) < 10)
            {
                onSprite.opacity = CCRANDOM_0_1()* 0.15 + 0.5;
            }
            else
            {
                onSprite.opacity = CCRANDOM_0_1()* 0.1;
            }
        }
        
        if (_flashFrame > 90)
        {
            _jackpotFlash = NO;
        }
        
        _flashFrame++;
    }
    else if (_cycling)
    {
        if (_frame % 10 == 0)
        {
            _cycleLight = (_cycleLight + 1) % _onSprites.count;
        }
        
        int i = 0;
        for (CCSprite* onSprite in _onSprites)
        {
            if (i == _cycleLight)
            {
                onSprite.opacity = CCRANDOM_0_1()* 0.15 + 0.5;
            }
            else
            {
                onSprite.opacity = CCRANDOM_0_1()* 0.1;
            }
            
            i++;
        }
        
        _frame++;
    }
    else if (_isOn)
    {
        for (CCSprite* onSprite in _onSprites)
        {
            onSprite.opacity = CCRANDOM_0_1()* 0.3 + 0.5;
        }
    }
    else if (_subLights > 0)
    {
        int i = 0;
        for (CCSprite* onSprite in _onSprites)
        {
            [onSprite stopAllActions];
            
            if (i < _subLights)
            {
                onSprite.opacity = CCRANDOM_0_1()* 0.15 + 0.5;
            }
            else
            {
                onSprite.opacity = 0;
            }
            
            i++;
        }
    }
    else
    {
        for (CCSprite* onSprite in _onSprites)
        {
            if ([onSprite getActionByTag:1] == NULL)
            {
                onSprite.opacity = CCRANDOM_0_1()* 0.1;
            }
        }
    }
}

- (void) cycle
{
    _cycling = YES;
    _frame = 1;
    _cycleLight = 0;
}

- (void) stopCycle
{
    _cycling = NO;
}

- (void) jackpotFlash
{
    _jackpotFlash = YES;
    _flashFrame = 0;
}

@end
