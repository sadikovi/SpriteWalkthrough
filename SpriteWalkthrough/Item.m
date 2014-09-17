//
//  Item.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 17/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "Item.h"

@interface Item()
@property ItemType itemType;
@end

@implementation Item

- (id)initWithType:(ItemType)type {
    NSString *image;
    if (type == ItemTypeHealth) {
        image = @"item-health.png";
        self.itemType = ItemTypeHealth;
    } else if (type == ItemTypeNuclear) {
        image = @"item-nuclear.png";
        self.itemType = ItemTypeNuclear;
    } else {
        image = @"item-unknown.png";
        self.itemType = [Item randomType];
    }
    
    self = [super initWithImageNamed:image];
    if (self) {
        // apply settings
        self.name = [Item name];
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.frame.size.width/2];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = [ObjectCategory itemCategory];
        self.physicsBody.contactTestBitMask = [ObjectCategory shipCategory] | [ObjectCategory laserCategory];
        self.physicsBody.collisionBitMask = 0;
        
        self.xScale = 0.8;
        self.yScale = 0.8;
    }
    
    return self;
}

- (ItemType)type {
    return self.itemType;
}

+ (ItemType)randomType {
    int random = arc4random() % 2;
    ItemType type;
    switch (random) {
        case 0:
            type = ItemTypeHealth;
            break;
        case 1:
            type = ItemTypeNuclear;
            break;
        default:
            type = ItemTypeHealth;
            break;
    }
    
    return type;
}

+ (NSString *)name {
    return @"item";
}

@end
