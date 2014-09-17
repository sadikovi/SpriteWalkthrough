//
//  LifeIndicator.h
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 17/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface LifeIndicator : NSObject

- (id)initWithMaxLifePoints:(int)maxLifePoints andStartLifePoints:(int)startLifePoints;
- (BOOL)increaseLifeBy:(int)points;
- (BOOL)decreaseLifeBy:(int)points;
- (BOOL)isEmpty;
- (int)getMaxLifePoints;
- (int)getCurrentLifePoints;

@end
