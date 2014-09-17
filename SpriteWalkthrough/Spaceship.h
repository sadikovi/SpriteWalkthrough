//
//  Spaceship.h
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "ObjectCategory.h"

@interface Spaceship : SKSpriteNode

+ (NSString *)name;
- (int)getLives;
+ (int)getMaxLives;
- (void)applyDamage:(int) damage;
+ (float)fireRate;
@end
