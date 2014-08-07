//
//  Goal.m
//  FuriousFinsv1
//
//  Created by Matthew Morton on 2/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end
