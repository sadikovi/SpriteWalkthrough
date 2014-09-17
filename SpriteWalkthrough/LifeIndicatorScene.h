//
//  LifeIndicatorScene.h
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 17/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LifeIndicatorScene : SKSpriteNode

- (id)initWithMaxLifePoints:(int)maxLifePoints andStartLifePoints:(int)startLifePoints andVertical:(BOOL)isVertical;
- (void)increaseLifeBy:(int)points withAnimationCompletion:(void (^)())block;
- (void)decreaseLifeBy:(int)points withAnimationCompletion:(void (^)())block;
- (BOOL)isEmpty;

@end
