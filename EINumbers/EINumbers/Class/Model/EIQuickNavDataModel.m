//
//  EIQuickNavDataModel.m
//  EINumbers
//
//  Created by 薛 迎松 on 13-10-27.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIQuickNavDataModel.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define boardWitdh 295.0f
#define boardSize CGSizeMake(84, 84)

#define kQuickNavKey @"QuickNavKey"
#define kQuickNavFilePath @"EIQuickNavPosition.plist"
#define kQUickNavListKey @"NavList"
#define kQuickNavDefaultKey @"NavDefault"

NSString *const kButtonRect = @"kButtonRect";
NSString *const kButtonIndex = @"kButtonIndex";

static EIQuickNavDataModel *_sharedInstace = nil;

@interface EIQuickNavDataModel()

@property (nonatomic, retain) NSDictionary *dictionary;

@end

@implementation EIQuickNavDataModel
@synthesize dictionary = _dictionary;

#pragma mark Picture Array
- (NSArray *)pictureArray
{
    return [self.dictionary objectForKey:kQUickNavListKey];
}

#pragma mark User Default setting
- (void)setUserNav:(NSArray *)array
{
    if([array count] >=4 && [array count] <=8)
    {
        [[NSUserDefaults standardUserDefaults] setObject:array  forKey:kQuickNavKey];
    }
}

- (NSArray *)defaultNav
{
    return [self.dictionary objectForKey:kQuickNavDefaultKey];
}

- (NSArray *)userNav
{
    NSArray *userNav = [[NSUserDefaults standardUserDefaults] objectForKey:kQuickNavKey];
    if([userNav count])
    {
        return userNav;
    }
    else
    {
        return [self defaultNav];
    }
}

#pragma mark Get Position Information

- (CGRect )posOfBaseForNumbers:(NSUInteger)index total:(CGSize)totalSize
{
    CGFloat width = boardWitdh;
    return CGRectMake(totalSize.width * .5f - width * .5f,
                      totalSize.height * .5f - width * .5f,
                      width,
                      width);
}

- (NSArray *)posArrayOfNumbers:(NSUInteger)index
{
    switch (index)
    {
        case 4:
        case 5:
        case 6:
            return [self posOfNumber:index];
            break;
        case 7:
        case 8:
            return [self posOfNumberEight:index];
            break;
        default:
            return [self posOfNumber:4];
            break;
    }
}

- (NSArray *)posOfNumber:(NSUInteger)index
{
    if(index >= 4 &&
       index<= 6)
    {
        NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:6];
        CGFloat boardWidth = boardWitdh;
        
        float startDegree = 0.0;
        switch (index) {
            case 4:
            case 5:
                startDegree = 90;
                break;
            case 6:
                startDegree = 60;
                break;
            default:
                break;
        }
        
        CGSize size = boardSize;
        CGPoint center = CGPointMake(boardWidth * .5f, boardWidth * .5f);
        float radius = boardWidth * .5f * 0.65f;
        float increase = DEGREES_TO_RADIANS(360/index);
        float base = DEGREES_TO_RADIANS(startDegree);
        
        for (int i=0; i<index; i++)
        {
            CGRect rect;
            rect.size = size;
            float degree = base - i * increase;
            rect.origin.x = center.x + radius * cosf(degree) - rect.size.width * .5f;
            rect.origin.y = center.y - radius * sin(degree) - rect.size.height * .5f;
            
            [resultArr addObject:[NSValue valueWithCGRect:rect]];
        }
        return resultArr;
    }
    return nil;
}

- (NSArray *)posOfNumberEight:(NSInteger)index
{
    if(index != 7 && index != 8)
    {
        return nil;
    }
    
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:index];
    CGFloat boardWidth = boardWitdh;
    
    CGSize size = boardSize;
    CGPoint center = CGPointMake(boardWidth * .5f, boardWidth * .5f);
    float radius1 = boardWidth * .5f * 0.65f;
    float radius2 = radius1 * 1.414;
    float increase = DEGREES_TO_RADIANS(360/4);
    float base1 = DEGREES_TO_RADIANS(90);
    float base2 = DEGREES_TO_RADIANS(45);
    
    for (int i=0; i<8; i++)
    {
        if(i == 3 && index == 7)
        {
            continue;
        }
        float base = base2;
        float radius = radius2;
        if(i%2 == 0)
        {
            base = base1;
            radius = radius1;
        }
        
        CGRect rect;
        rect.size = size;
        float degree = base - (i/2) * increase;
        rect.origin.x = center.x + radius * cosf(degree) - rect.size.width * .5f;
        rect.origin.y = center.y - radius * sin(degree) - rect.size.height * .5f;
        
        [resultArr addObject:[NSValue valueWithCGRect:rect]];
    }
    return resultArr;
}

#pragma mark LifeCycle

- (void)dealloc
{
    [_dictionary release];
    
    [super dealloc];
}
- (id)init
{
    @synchronized(self)
    {
        if(self = [super init])
        {
            NSString *filePath  = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kQuickNavFilePath];
            self.dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
        }
        return self;
    }
}

+ (id)sharedInstance
{
    @synchronized(self)
    {
        if(nil == _sharedInstace)
        {
            _sharedInstace = [[self alloc] init];
        }
    }
    return _sharedInstace;
}

+ (id) allocWithZone:(NSZone *)zone //第三步：重写allocWithZone方法
{
    @synchronized (self)
    {
        if (nil == _sharedInstace)
        {
            _sharedInstace = [super allocWithZone:zone];
        }
    }
    return _sharedInstace;
}

- (id) copyWithZone:(NSZone *)zone //第四步
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger) retainCount
{
    return SIZE_MAX;
}

- (oneway void) release
{
    
}

- (id) autorelease
{
    return self;
}

@end
