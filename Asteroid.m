//
//  Asteroid.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "Asteroid.h"
#import "ObjectCategory.h"

@interface Asteroid ()
@property BOOL isOriginal;
@property int numChildren;
@property BOOL hasItem;
@property ItemType itemType;
@end

@implementation Asteroid

static NSString *image = @"asteroid.png";
static int damage = 1;

+ (NSString *)name {
    return @"asteroid";
}

- (id)initWithOriginality:(BOOL)isPiece {
    self = [super initWithImageNamed:image];
    if (self) {
        self.name = [Asteroid name];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width/2];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = [ObjectCategory asteroidCategory];
        self.physicsBody.contactTestBitMask = [ObjectCategory shipCategory] | [ObjectCategory laserCategory] | [ObjectCategory asteroidCategory];
        self.physicsBody.collisionBitMask = 0;
        self.isOriginal = isPiece;
        
        if (self.isOriginal) {
            self.xScale = 0.25;
            self.yScale = 0.25;
            self.numChildren = arc4random() % 3;
        } else {
            self.xScale = 0.15;
            self.yScale = 0.15;
            self.numChildren = 0;
        }
        
        if ((arc4random() % 2) == 1 && self.isOriginal) {
            self.hasItem = YES;
            self.itemType = [Item randomType];
        } else {
            self.hasItem = NO;
            self.itemType = -1;
        }
    }
    
    return self;
}

- (void)destroy {
    [self removeFromParent];
}

- (BOOL)isPiece {
    return self.isOriginal;
}

- (int)numberOfChildren {
    return self.numChildren;
}

- (int)damage {
    return damage;
}

@end
