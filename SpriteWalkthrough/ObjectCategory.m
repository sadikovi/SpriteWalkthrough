//
//  ObjectCategory.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "ObjectCategory.h"

@implementation ObjectCategory

static const uint32_t laserCategory         =  0x1 << 0;
static const uint32_t asteroidCategory      =  0x1 << 1;
static const uint32_t shipCategory          =  0x1 << 2;
static const uint32_t itemCategory          =  0x1 << 4;


+ (uint32_t)shipCategory {
    return shipCategory;
}

+ (uint32_t)asteroidCategory {
    return asteroidCategory;
}

+ (uint32_t)laserCategory {
    return laserCategory;
}

+ (uint32_t)itemCategory {
    return itemCategory;
}


@end
