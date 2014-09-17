//
//  Laser.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "Laser.h"

@implementation Laser

static NSString *image = @"laser.png";
static NSString *name = @"laser";

- (id)init {
    self = [super initWithImageNamed:image];
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = [ObjectCategory laserCategory];
        self.physicsBody.contactTestBitMask = [ObjectCategory asteroidCategory] | [ObjectCategory itemCategory];
        self.physicsBody.collisionBitMask = 0;
        self.name = name;
    }
    
    return self;
}


@end
