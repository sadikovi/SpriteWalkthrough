//
//  Spaceship.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "Spaceship.h"

@interface Spaceship ()
@property int currentLives;
@end

@implementation Spaceship

static int maxLives = 3;
static float fireRate = 0.5;
static NSString *image = @"spaceship.png";
static NSString *name = @"spaceship";

- (id)init {
    self = [super initWithImageNamed:image];
    if (self) {
        // This is a bounding shape that approximates the rocket.
        CGFloat offsetX = self.frame.size.width * self.anchorPoint.x;
        CGFloat offsetY = self.frame.size.height * self.anchorPoint.y;
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 15 - offsetX, 32 - offsetY);
        CGPathAddLineToPoint(path, NULL, - offsetX, 9 - offsetY);
        CGPathAddLineToPoint(path, NULL, 32 - offsetX, 8 - offsetY);
        
        CGPathCloseSubpath(path);
        
        self.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path];
        CGPathRelease(path);
        
        self.color = [SKColor blueColor];
        //self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.categoryBitMask = [ObjectCategory shipCategory];
        self.physicsBody.contactTestBitMask = [ObjectCategory asteroidCategory];
        self.physicsBody.collisionBitMask = 0;
        self.name = name;
        
        SKSpriteNode *light1 = [self newLight];
        light1.position = CGPointMake(-9.0, -31.0);
        [self addChild:light1];
        
        SKSpriteNode *light2 = [self newLight];
        light2.position = CGPointMake(10.0, -31.0);
        [self addChild:light2];
        
        // set lives to 3
        self.currentLives = 3;
    }
    
    return self;
}

- (SKSpriteNode *)newLight {
    SKSpriteNode *light = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship_fire.png"];
    SKAction *blink = [SKAction sequence:@[
                                           [SKAction scaleYTo:0.8 duration:0.25],
                                           [SKAction scaleYTo:1.0 duration:0.5]]];
    SKAction *blinkForever = [SKAction repeatActionForever:blink];
    [light runAction: blinkForever];
    
    return light;
}

+ (NSString *)name {
    return name;
}

- (void)applyDamage:(int)damage {
    if (self.currentLives >= maxLives && damage < 0)
        return;
    
    if (self.currentLives <= 0 && damage > 0)
        return;
    
    self.currentLives -= damage;
}

+ (int)getMaxLives {
    return maxLives;
}

- (int)getLives {
    return self.currentLives;
}

+ (float)fireRate {
    return fireRate;
}

@end
