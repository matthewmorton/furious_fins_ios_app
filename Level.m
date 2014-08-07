//
//  Level.m
//  FuriousFinsv1
//
//  Created by Matthew Morton on 2/11/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Level.h" 
#import "Obstacle.h"
#import "Goal.h"

static const CGFloat scrollSpeed = 80.f;
static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 260.f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderScore,
    DrawingOrderCoral,
    DrawingOrderGround,
    DrawingOrderFish
};

@implementation Level
{
    CCPhysicsNode* _physicsNode;
    CCSprite *_fish;
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    NSTimeInterval _sinceTouch;
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    
    CGFloat _scrollSpeed;
    
}

//
- (void)didLoadFromCCB {
    _scrollSpeed = 280.f;
    self.userInteractionEnabled = TRUE;//for touch handling
    
    _grounds = @[_ground1, _ground2];
    
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    // set this class as delegate
    _physicsNode.CollisionDelegate = self;
    // set collision type
    _fish.physicsBody.collisionType = @"hero";
    _fish.zOrder = DrawingOrderFish;
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
}

// apply constant right movement to main _fish and the _physicsNode plus ground and spawning of obstacles
- (void)update:(CCTime)delta {
    
    float yVelocity = clampf(_fish.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _fish.physicsBody.velocity = ccp(_scrollSpeed, yVelocity);
    
    _sinceTouch += delta;
    
    _fish.rotation = clampf(_fish.rotation, -30.f, 30.f);
    
    if (_fish.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_fish.physicsBody.angularVelocity, -2.f, 1.f);
        _fish.physicsBody.angularVelocity = angularVelocity;
    }
    
    if ((_sinceTouch > 0.5f)) {
        [_fish.physicsBody applyAngularImpulse:-4000.f*delta];
    }
    
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    NSMutableArray *offScreenObstacles = nil;
    
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
    
}

//Monitor the touch on screen
- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [_fish.physicsBody applyImpulse:ccp(0, 200.f)];
        [_fish.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }
}

//Adding in the obstacles
- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [obstacle setupRandomPosition];
    obstacle.zOrder = DrawingOrderCoral;
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
}

//Game over function
- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _fish.rotation = 90.f;
        _fish.physicsBody.allowsRotation = FALSE;
        [_fish stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}
//Collision detection pair on hero and level --  goes to game over
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    [self gameOver];
    return TRUE;
}
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    [goal removeFromParent];
    
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    _scoreLabel.zOrder = DrawingOrderScore;
    
    return TRUE;
}

@end
