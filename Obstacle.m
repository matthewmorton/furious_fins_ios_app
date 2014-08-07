//
//  Obstacle.m
//  FuriousFinsv1
//
//  Created by Matthew Morton on 2/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Obstacle.h"
@implementation Obstacle {
    CCNode *_topCoral;
    CCNode *_bottomCoral;
}
#define ARC4RANDOM_MAX      0x100000000
// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPositionTopCoral = 198.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPositionBottomCoral = 520.f;
// distance between top and bottom rock
static const CGFloat coralDistance = 122.f;
// calculate the end of the range of top rock
static const CGFloat maximumYPositionTopCoral = maximumYPositionBottomCoral - coralDistance;
- (void)setupRandomPosition {
    // value between 0.f and 1.f
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maximumYPositionTopCoral - minimumYPositionTopCoral;
    _topCoral.position = ccp(_topCoral.position.x, minimumYPositionTopCoral + (random * range));
    _bottomCoral.position = ccp(_bottomCoral.position.x, _topCoral.position.y + coralDistance);
}
//Add the collision detection
- (void)didLoadFromCCB {
    _topCoral.physicsBody.collisionType = @"level";
    _topCoral.physicsBody.sensor = TRUE;
    _bottomCoral.physicsBody.collisionType = @"level";
    _bottomCoral.physicsBody.sensor = TRUE;
}
@end