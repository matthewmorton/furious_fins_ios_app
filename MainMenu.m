//
//  MainMenu.m
//  FuriousFinsv1
//
//  Created by Matthew Morton on 2/20/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainMenu.h"

@implementation MainMenu
{
    CCButton *_playButton;
}
- (void)Playgame {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

@end
