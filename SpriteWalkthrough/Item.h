//
//  Item.h
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 17/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Spaceship.h"
#import "ObjectCategory.h"

enum {
    ItemTypeHealth,
    ItemTypeNuclear
} typedef ItemType;

@interface Item : SKSpriteNode
@property(readonly) ItemType type;

- (id)initWithType:(ItemType)type;
+ (NSString *)name;
+ (ItemType)randomType;

@end
