//
//  MainScene.h
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "CCNode.h"
#import "Board.h"

@interface MainScene : CCNode
{
    CCLabelTTF* _lblInfo;
    CCLabelTTF* _lblScore;
    
    CCButton* _playButton;
}

@property (nonatomic,strong) Board* board;

@property (nonatomic,readonly) CCLabelTTF* lblInfo;
@property (nonatomic,readonly) CCLabelTTF* lblScore;

- (void) handleGameOver;

@end
