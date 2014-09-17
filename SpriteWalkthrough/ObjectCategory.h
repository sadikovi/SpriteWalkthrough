//
//  ObjectCategory.h
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectCategory : NSObject

+ (uint32_t)shipCategory;
+ (uint32_t)asteroidCategory;
+ (uint32_t)laserCategory;
+ (uint32_t)itemCategory;

@end
