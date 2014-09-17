//
//  HelloScene.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "HelloScene.h"
#import "SpaceshipScene.h"

@interface HelloScene ()
@property BOOL contentCreated;
@property (nonatomic, strong) NSString *title;
@end

@implementation HelloScene

- (id)initWithSize:(CGSize)size andTitle:(NSString *)text {
    self = [super initWithSize:size];
    if (self) {
        self.title = text;
    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view {
    if (!self.contentCreated) {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

- (void)createSceneContents {
    self.backgroundColor = [SKColor blueColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild:[self newHelloNode]];
    [self addChild:[self descNodeOnPosition]];
}

- (SKLabelNode *)newHelloNode {
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    helloNode.text = (self.title == nil)?@"Galaxy Survivor" : self.title;
    helloNode.name = @"helloNode";
    helloNode.fontSize = 42;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    return helloNode;
}

- (SKLabelNode *)descNodeOnPosition {
    SKLabelNode *descNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    descNode.text = @"Tap to start";
    descNode.name = @"descNode";
    descNode.fontSize = 30;
    descNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame) - 100);
    return descNode;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene *spaceshipScene  = [[SpaceshipScene alloc] initWithSize:self.size];
    SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.5];
    [self.view presentScene:spaceshipScene transition:doors];
}

@end
