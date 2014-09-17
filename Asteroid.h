//
//  Asteroid.h
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Item.h"

@interface Asteroid : SKSpriteNode

@property (readonly) BOOL isPiece;
@property (readonly) int numberOfChildren;
@property (readonly) int damage;
@property (readonly) BOOL hasItem;
@property (readonly) ItemType itemType;

+ (NSString *)name;
- (id)initWithOriginality:(BOOL)isPiece;
- (void)destroy;

@end
