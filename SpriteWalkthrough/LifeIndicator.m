//
//  LifeIndicator.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 17/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "LifeIndicator.h"

@interface LifeIndicator ()
@property (nonatomic) int maxLifePoints;
@property (nonatomic)  int currentLifePoints;
@end

@implementation LifeIndicator

- (id)initWithMaxLifePoints:(int)maxLifePoints andStartLifePoints:(int)startLifePoints {
    self = [super init];
    if (self) {
        self.maxLifePoints = maxLifePoints;
        self.currentLifePoints = startLifePoints;
    }
    
    return self;
}

- (void)setCurrentLifePoints:(int)currentLifePoints {
    _currentLifePoints = currentLifePoints;
    if (_currentLifePoints < 0)
        _currentLifePoints = 0;
    if (_currentLifePoints > self.maxLifePoints)
        _currentLifePoints = self.maxLifePoints;
}

- (BOOL)increaseLifeBy:(int)points {
    if (points > 0) {
        self.currentLifePoints += points;
        return YES;
    }
    
    return NO;
}

- (BOOL)decreaseLifeBy:(int)points {
    if (points > 0) {
        self.currentLifePoints -= points;
        return YES;
    }
    
    return NO;
}

- (BOOL)isEmpty {
    return (self.currentLifePoints == 0);
}

- (int)getMaxLifePoints {
    return self.maxLifePoints;
}

- (int)getCurrentLifePoints {
    return self.currentLifePoints;
}

@end
