//
//  LifeIndicatorScene.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 17/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "LifeIndicatorScene.h"
#import "LifeIndicator.h"

@interface LifeIndicatorScene ()
@property (nonatomic, strong) LifeIndicator *indicator;
@property (nonatomic, strong) NSMutableArray *lifeNodes;
@property BOOL isVertical;

enum {
    LifeStateOn,
    LifeStateOff
} typedef LifeState;

@end

@implementation LifeIndicatorScene

#define LIFE_ICON               @"life.png"
#define LIFE_ICON_WIDTH         60
#define LIFE_ICON_HEIGHT        60
#define LIFE_BETWEEN_WIDTH      LIFE_ICON_WIDTH + 30
#define LIFE_BETWEEN_HEIGHT     LIFE_ICON_HEIGHT + 30
#define OFFSET                  5

- (id)initWithMaxLifePoints:(int)maxLifePoints andStartLifePoints:(int)startLifePoints andVertical:(BOOL)isVertical {
    self = [super init];
    if (self) {
        self.indicator = [[LifeIndicator alloc] initWithMaxLifePoints:maxLifePoints andStartLifePoints:startLifePoints];
        self.isVertical = isVertical;
        self.lifeNodes = [NSMutableArray array];
        
        // calculate width and height
        CGFloat width = (self.isVertical) ? LIFE_ICON_WIDTH + 2*OFFSET : 2*OFFSET + LIFE_ICON_WIDTH + (maxLifePoints-1)*LIFE_BETWEEN_WIDTH;
        CGFloat height = (!self.isVertical) ? LIFE_ICON_HEIGHT + 2*OFFSET : 2*OFFSET + LIFE_ICON_HEIGHT + (maxLifePoints-1)*LIFE_BETWEEN_HEIGHT;
        self.size = CGSizeMake(width, height);
        
        [self addLifeNodesToScene:self andArray:self.lifeNodes];
    }
    
    return self;
}

- (SKSpriteNode *)newLifeNodeOnPosition:(CGPoint)position {
    SKSpriteNode *lifeNode = [SKSpriteNode spriteNodeWithImageNamed:LIFE_ICON];
    lifeNode.position = position;
    lifeNode.xScale = 0.6;
    lifeNode.yScale = 0.6;
    lifeNode.physicsBody.dynamic = NO;
    lifeNode.name = @"lifenode";
    
    return lifeNode;
}

- (void)addLifeNodesToScene:(LifeIndicatorScene *)scene andArray:(NSMutableArray *)nodes {
    if (scene == nil)
        return;
    
    for (int i=1; i<=[scene.indicator getMaxLifePoints]; i++) {
        CGPoint position;
        if (!self.isVertical)
            position = CGPointMake(OFFSET + LIFE_ICON_WIDTH/2.0 + LIFE_BETWEEN_WIDTH*(i-1), OFFSET + LIFE_ICON_HEIGHT/2.0);
        else
            position = CGPointMake(OFFSET + LIFE_ICON_WIDTH/2.0, OFFSET + LIFE_ICON_HEIGHT/2.0 + LIFE_BETWEEN_HEIGHT*(i-1));
        
        SKSpriteNode *lifeNode = [self newLifeNodeOnPosition:position];
        lifeNode.name = [NSString stringWithFormat:@"lifenode%d", i];
        [nodes addObject:lifeNode];
        [self addChild:lifeNode];
        
        if (i <= [self.indicator getCurrentLifePoints])
            [self node:lifeNode changeState:LifeStateOn withAnimation:NO withCompletion:nil];
        else
            [self node:lifeNode changeState:LifeStateOff withAnimation:NO withCompletion:nil];
    }
}

- (void)increaseLifeBy:(int)points withAnimationCompletion:(void (^)())block {
    int pointsBefore = [self.indicator getCurrentLifePoints]-1;
    [self.indicator increaseLifeBy:points];
    int pointsAfter = [self.indicator getCurrentLifePoints]-1;
    
    for (int i=pointsBefore+1; i<=pointsAfter; i++) {
        SKSpriteNode *node = (SKSpriteNode *)[self.lifeNodes objectAtIndex:i];
        [self node:node changeState:LifeStateOn withAnimation:YES withCompletion:block];
    }
}

- (void)decreaseLifeBy:(int)points withAnimationCompletion:(void (^)())block {
    int pointsBefore = [self.indicator getCurrentLifePoints]-1;
    [self.indicator decreaseLifeBy:points];
    int pointsAfter = [self.indicator getCurrentLifePoints]-1;
    
    for (int i=pointsBefore; i>pointsAfter; i--) {
        SKSpriteNode *node = (SKSpriteNode *)[self.lifeNodes objectAtIndex:i];
        [self node:node changeState:LifeStateOff withAnimation:YES withCompletion:block];
    }
}

- (BOOL)isEmpty {
    return [self.indicator isEmpty];
}

- (void)node:(SKSpriteNode *)node changeState:(LifeState)state withAnimation:(BOOL)animate withCompletion:(void (^)())block {
    if (node == nil)
        return;
    
    CGFloat alpha;
    if (state == LifeStateOn) {
        alpha = 1.0;
    } else {
        alpha = 0.4;
    }
    
    if (animate) {
        SKAction *fadeIn = [SKAction fadeInWithDuration:0.1];
        SKAction *fadeOut = [SKAction fadeOutWithDuration:0.1];
        
        [node runAction:[SKAction repeatAction:[SKAction sequence:@[fadeOut, fadeIn]] count:3]
             completion:^{
                 [node runAction:[SKAction fadeAlphaTo:alpha duration:0.0] completion:block];
             }];
    } else {
        [node runAction:[SKAction fadeAlphaTo:alpha duration:0.0] completion:block];
    }
}

@end
