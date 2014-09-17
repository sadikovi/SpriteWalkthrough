//
//  SpaceshipScene.m
//  SpriteWalkthrough
//
//  Created by Ivan Sadikov on 15/09/14.
//  Copyright (c) 2014 Ivan Sadikov. All rights reserved.
//

#import "SpaceshipScene.h"
#import "HelloScene.h"
#import "Asteroid.h"
#import "Spaceship.h"
#import "Laser.h"
#import "Item.h"
#import "ObjectCategory.h"
#import "LifeIndicatorScene.h"

@interface SpaceshipScene ()
@property BOOL contentCreated;
@property NSMutableArray *explosionTextures;
@property (nonatomic)  BOOL isGameover;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, strong) NSTimer *fireTimer;
@property int secondsLeft;
@property BOOL canFire;
@property LifeIndicatorScene *lifeBar;
@end

@implementation SpaceshipScene

// time to win
static int seconds = 60;

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.physicsWorld.contactDelegate = self;
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        // init explosion
        SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"EXPLOSION"];
        NSArray *textureNames = [explosionAtlas textureNames];
        self.explosionTextures = [NSMutableArray new];
        for (NSString *name in textureNames) {
            SKTexture *texture = [explosionAtlas textureNamed:name];
            [self.explosionTextures addObject:texture];
        }
        
        // game over
        self.isGameover = NO;
        // seconds left
        self.secondsLeft = seconds;
        
        // fire availability
        self.canFire = YES;
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
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    // add life bar
    self.lifeBar = [[LifeIndicatorScene alloc] initWithMaxLifePoints:3 andStartLifePoints:3 andVertical:NO];
    self.lifeBar.position = CGPointMake(120, 5);
    [self addChild:self.lifeBar];
    
    // add spaceship
    Spaceship *spaceship = [[Spaceship alloc] init];
    spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-150);
    spaceship.zPosition = -2;
    [self addChild:spaceship];
    
    // add timer
    SKLabelNode *node = [self newLabelNodeOnPosition:CGPointMake(40, 30)];
    [self addChild:node];
    
    SKAction *makeRocks = [SKAction sequence: @[
                                                [SKAction performSelector:@selector(addAsteroid) onTarget:self],
                                                [SKAction waitForDuration:2 withRange:0.15]
                                                ]];
    [self runAction: [SKAction repeatActionForever:makeRocks]];
    
    // init game timer
    // add timer for the countdown
    self.countdownTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateStateForTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.countdownTimer forMode:NSRunLoopCommonModes];
}

- (void)setIsGameover:(BOOL)isGameover {
    _isGameover = isGameover;
    if (_isGameover) {
        [self gameover];
    }
}

// game over method
- (void)gameover {
    // invalidate timers
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
    [self.fireTimer invalidate];
    self.fireTimer = nil;
    
    if (self.isGameover) {
        SKNode *spaceship = [self childNodeWithName:[Spaceship name]];
        [self explode:spaceship andCompletion:^ {
            [spaceship removeFromParent];
            
            [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(transitToMenu)
                                           userInfo:nil
                                            repeats:NO];
        }];
    } else {
        [self transitToMenu];
    }
}

- (void)transitToMenu {
    NSString *text = @"You win!";
    if (self.isGameover)
        text = @"You lose";
        
    SKScene *helloScese  = [[HelloScene alloc] initWithSize:self.size andTitle:text];
    SKTransition *doors = [SKTransition doorsCloseVerticalWithDuration:0.5];
    [self.view presentScene:helloScese transition:doors];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *first, *second;
    
    if (contact.bodyA.categoryBitMask != [ObjectCategory shipCategory] && contact.bodyA.categoryBitMask != [ObjectCategory laserCategory]) {
        first = contact.bodyB;
        second = contact.bodyA;
    } else {
        first = contact.bodyA;
        second = contact.bodyB;
    }
    
    if (first.categoryBitMask == [ObjectCategory asteroidCategory] && second.categoryBitMask == [ObjectCategory asteroidCategory]) {
        // they are both asteroids
    } else if (first.categoryBitMask == [ObjectCategory itemCategory] || second.categoryBitMask == [ObjectCategory itemCategory]) {
        // second is item
        Spaceship *ship;
        SKPhysicsBody *other;
        Laser *laser;
        Item *item;
        
        // find item
        if (first.categoryBitMask == [ObjectCategory itemCategory]) {
            item = (Item *)first.node;
            other = second;
        } else {
            item = (Item *)second.node;
            other = first;
        }
        
        // resolve other
        if (other.categoryBitMask == [ObjectCategory laserCategory]) {
            laser = (Laser *)other.node;
            SKAction *fadeIn = [SKAction fadeInWithDuration:0.1];
            SKAction *fadeOut = [SKAction fadeOutWithDuration:0.1];
            
            [laser removeFromParent];
            [item runAction:[SKAction repeatAction:[SKAction sequence:@[fadeOut, fadeIn]] count:3]
                     completion:^{
                         [item removeFromParent];
                     }];
        } else if (other.categoryBitMask == [ObjectCategory shipCategory]) {
            ship = (Spaceship *)other.node;
            [item removeFromParent];
            if (item.type == ItemTypeHealth) {
                [self.lifeBar increaseLifeBy:1 withAnimationCompletion:nil];
            } else if (item.type == ItemTypeNuclear) {
                [ship applyDamage:1];
                [self.lifeBar decreaseLifeBy:1 withAnimationCompletion:^{
                    if (self.lifeBar.isEmpty)
                        self.isGameover = YES;
                }];
            }
        }
    } else if ((first.categoryBitMask == [ObjectCategory asteroidCategory]) || (second.categoryBitMask == [ObjectCategory asteroidCategory])) {
        Asteroid *parent;
        SKPhysicsBody *other;
        if (first.categoryBitMask == [ObjectCategory asteroidCategory]) {
            parent = (Asteroid *)first.node;
            other = second;
        } else {
            parent = (Asteroid *)second.node;
            other = first;
        }
        
        [self explode:parent andCompletion:nil];
        
        if (other.categoryBitMask == [ObjectCategory laserCategory]) {
            SKAction *destroy = [SKAction fadeInWithDuration:0.1];
            if (first.categoryBitMask == [ObjectCategory laserCategory])
                [first.node removeFromParent];
                
            [parent runAction:destroy completion:^{
                if (parent.hasItem) {
                    [self addItemAtPosition:parent.position withType:parent.itemType];
                }
                
                [self createAsteroidChildren:parent.numberOfChildren onPosition:parent.position];
                [parent destroy];
            }];
        } else {
            // hit ship
            // one of them is ship and the other one is asteroid
            Spaceship *ship = (Spaceship *)other.node;
            [ship applyDamage:parent.damage];
            [self.lifeBar decreaseLifeBy:parent.damage withAnimationCompletion:^{
                if (self.lifeBar.isEmpty)
                    self.isGameover = YES;
            }];
            
            [parent destroy];
        }
    }
    
    
}

// Used to configure a ship explosion.
static const CGFloat shipChunkMinimumSpeed = 30;
static const CGFloat shipChunkMaximumSpeed = 70;


- (void)createAsteroidChildren:(int)children onPosition:(CGPoint)position {
    if (children > 0) {
        for (int i=0; i<children; i++) {
            Asteroid *asteroid = [[Asteroid alloc] initWithOriginality:NO];
            CGFloat angle = skRand(M_PI, M_PI*2);
            CGFloat speed = skRand(shipChunkMinimumSpeed, shipChunkMaximumSpeed);
            
            position = CGPointMake(skRand(position.x, position.x+5), skRand(position.y, position.y+5));
            
            asteroid.position = position;
            asteroid.physicsBody.velocity = CGVectorMake(cos(angle)*speed, sin(angle)*speed);
            
            SKAction *moveRock = [SKAction moveBy:asteroid.physicsBody.velocity duration:10];
            [asteroid runAction:moveRock];
            [self addChild:asteroid];
        }
    }
}

static inline CGFloat skRandf() {
    return rand() / (CGFloat)RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

// add asteroid
- (void)addAsteroid {
    Asteroid *asteroid = [[Asteroid alloc] initWithOriginality:YES];
    asteroid.position = CGPointMake(skRand(0, self.size.width), self.size.height-20);
    asteroid.zPosition = -1;
    CGMutablePathRef cgpath = CGPathCreateMutable();
    
    CGFloat xStart = skRand(0+asteroid.frame.size.width/2, self.view.bounds.size.width-asteroid.frame.size.width/2);
    CGFloat yStart = 50;
    CGFloat xEnd = skRand(0+asteroid.frame.size.width/2, self.view.bounds.size.width-asteroid.frame.size.width/2);
    CGFloat yEnd = self.view.bounds.size.height;
    
    int duration = (int)skRand(5, 10);
    
    CGPathMoveToPoint(cgpath, NULL, xEnd, yEnd);
    CGPathAddLineToPoint(cgpath, NULL, xStart, yStart);
    
    SKAction *moveRock = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:duration];
    SKAction *remove = [SKAction removeFromParent];
    [asteroid runAction:[SKAction sequence:@[moveRock, remove]]];
    
    CGPathRelease(cgpath);
    
    [self addChild:asteroid];
}

// add item
- (void)addItemAtPosition:(CGPoint)position withType:(ItemType) type {
    Item *item = [[Item alloc] initWithType:type];
    item.position = position;
    item.zRotation = 0.5;
    
    int duration = (int)skRand(5, 10);
    CGFloat xEnd = skRand(0+item.frame.size.width/2, self.view.bounds.size.width-item.frame.size.width/2);
    CGFloat yEnd = 0;
    
    CGMutablePathRef cgpath = CGPathCreateMutable();
    
    CGPathMoveToPoint(cgpath, NULL, position.x, position.y);
    CGPathAddLineToPoint(cgpath, NULL, xEnd, yEnd);
    
    SKAction *move = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:duration*0.5];
    SKAction *remove = [SKAction removeFromParent];
    [item runAction:[SKAction sequence:@[move, remove]]];
    
    CGPathRelease(cgpath);
    
    [self addChild:item];
}

- (void)explode:(SKNode *)node andCompletion:(void (^)())block {
    //add explosion
    SKSpriteNode *explosion = [SKSpriteNode spriteNodeWithTexture:[self.explosionTextures objectAtIndex:0]];
    explosion.zPosition = 1;
    explosion.scale = 0.4;
    explosion.position = node.position;
    
    [self addChild:explosion];
    
    SKAction *explosionAction = [SKAction animateWithTextures:self.explosionTextures timePerFrame:0.07];
    SKAction *remove = [SKAction removeFromParent];
    [explosion runAction:[SKAction sequence:@[explosionAction, remove]] completion:block];
}

-(void)didSimulatePhysics {
    [self enumerateChildNodesWithName:[Asteroid name] usingBlock: ^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0 || node.position.y > self.view.bounds.size.height || node.position.x < 0 || node.position.x > self.view.bounds.size.width) {
            [node removeFromParent];
        }
    }];
}
 
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKNode *spaceship = [self childNodeWithName:[Spaceship name]];
    if (spaceship != nil) {
        UITouch *touch = [touches anyObject];
        CGPoint positionInScene = [touch locationInNode:self];
        
        // calculate min and max boundaries
        CGFloat xmin = self.view.bounds.origin.x + spaceship.frame.size.width/2;
        CGFloat xmax = self.view.bounds.origin.x + self.view.bounds.size.width - spaceship.frame.size.width/2;
        
        // initial position to move
        CGFloat x = spaceship.position.x;
        CGFloat y = spaceship.position.y;
        
        // calculate x
        if (positionInScene.x > xmin && positionInScene.x < xmax) {
            x = positionInScene.x;
        } else if (positionInScene.x <= xmin) {
            x = xmin;
        } else if (positionInScene.x >= xmax) {
            x = xmax;
        }
        
        CGPoint actualPosition = CGPointMake(x, y);
        
        // Determine speed interval
        int speed = 1.5;
        
        // Create the actions
        SKAction * touchMove = [SKAction moveTo:actualPosition
                                         duration:speed];
        [spaceship runAction:touchMove];
        
        // add laser
        if (self.canFire) {
            CGPoint location = [spaceship position];
            Laser *laser = [[Laser alloc] init];
            
            laser.position = CGPointMake(location.x,location.y + spaceship.frame.size.height/2);
            laser.zPosition = 1;
            laser.scale = 0.8;
            
            SKAction *action = [SKAction moveToY:self.frame.size.height + laser.size.height duration: 2];
            SKAction *remove = [SKAction removeFromParent];
            
            [laser runAction:[SKAction sequence:@[action, remove]]];
            
            [self addChild:laser];
            self.canFire = NO;
            
            // init timer for fire
            self.fireTimer = [NSTimer timerWithTimeInterval:[Spaceship fireRate]
                                                     target:self
                                                   selector:@selector(updateFireAvailability:)
                                                   userInfo:nil
                                                    repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:self.fireTimer forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)updateFireAvailability:(NSTimer *)timer {
    self.canFire = YES;
}

// add timer label
- (SKLabelNode *)newLabelNodeOnPosition:(CGPoint)position {
    SKLabelNode *time = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    time.name = @"timer";
    time.fontSize = 18;
    time.position = position;
    time.text = [NSString stringWithFormat:@"Time: %d", self.secondsLeft--];
    return time;
}

- (void)updateStateForTimer:(NSTimer *)timer {
    SKLabelNode *node = (SKLabelNode *)[self childNodeWithName:@"timer"];
    node.text = [NSString stringWithFormat:@"Time: %d", self.secondsLeft];
    
    if (self.secondsLeft <= 0) {
        [self gameover];
    } else {
        self.secondsLeft--;
    }
}

@end
