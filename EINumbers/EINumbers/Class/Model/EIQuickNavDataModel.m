//
//  EIQuickNavDataModel.m
//  EINumbers
//
//  Created by 薛 迎松 on 13-10-27.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIQuickNavDataModel.h"

#define kQuickNavKey @"QuickNavKey"
#define kQuickNavFilePath @"EIQuickNavPosition.plist"
#define kQuickNavPosKey @"NavPos"
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
    if([array count] >=4 && [array count] <=6)
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
- (CGFloat)boardWidthOfNumbers:(NSUInteger)index
{
    switch (index)
    {
        case 4:
            return 250.0f;
            break;
        case 5:
            return 280.0f;
            break;
        case 6:
            return 280.0f;
            break;
        default:
            return 250.0f;
            break;
    }
}

- (CGRect )posOfBaseForNumbers:(NSUInteger)index total:(CGSize)totalSize
{
    CGFloat width = [self boardWidthOfNumbers:index];
    return CGRectMake(totalSize.width * .5f - width * .5f,
                      totalSize.height * .5f -100,
                      width,
                      width);
}

- (NSArray *)posArrayOfNumbers:(NSUInteger)index
{
    switch (index)
    {
        case 4:
            return [self posOfNumberFour];
            break;
        case 5:
            return [self posOfNumberFive];
            break;
        case 6:
            return [self posOfNumberSix];
            break;
        default:
            return [self posOfNumberFour];
            break;
    }
}

- (NSArray *)posOfNumberSix
{
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:6];
    CGFloat boradWidth = [self boardWidthOfNumbers:6];
    for (int i=0; i<6; i++)
    {
        CGRect rect;
        CGFloat width = boradWidth / 4;
        CGFloat height = boradWidth / 3;
        CGFloat dValue = (height - width) *.5f;
        rect.size.width = width - 10;
        rect.size.height = width - 10;
        switch (i) {
            case 0:
                rect.origin.x = width + 5;
                rect.origin.y = 5;
                break;
            case 1:
                rect.origin.x = (width * 2) + 5;
                rect.origin.y = 5;
                break;
            case 2:
                rect.origin.x = (width * 3) + 5;
                rect.origin.y = height + 5 + dValue;
                break;
            case 3:
                rect.origin.x = (width * 2) + 5;
                rect.origin.y = (height * 2) + 5;
                break;
            case 4:
                rect.origin.x = width + 5;
                rect.origin.y = (height * 2) + 5;
                break;
            case 5:
                rect.origin.x = 5;
                rect.origin.y = height + 5 + dValue;
                break;
        }
        [resultArr addObject:[NSValue valueWithCGRect:rect]];
    }
    return resultArr;
}

- (NSArray *)posOfNumberFive
{
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:5];
    CGFloat boradWidth = [self boardWidthOfNumbers:5];
    for (int i=0; i<5; i++)
    {
        CGRect rect;
        CGFloat width = boradWidth / 3;
        CGFloat halfWidth = width * .5f;
        rect.size.width = width - 10;
        rect.size.height = width - 10;
        switch (i) {
            case 0:
                rect.origin.x = width + 5;
                rect.origin.y = 5;
                break;
            case 1:
                rect.origin.x = (width * 2) + 5;
                rect.origin.y = width + 5;
                break;
            case 2:
                rect.origin.x = width + halfWidth + 5;
                rect.origin.y = (width * 2) + 5;
                break;
            case 3:
                rect.origin.x = halfWidth + 5;
                rect.origin.y = (width * 2) + 5;
                break;
            case 4:
                rect.origin.x = 5;
                rect.origin.y = width + 5;
                break;
        }
        [resultArr addObject:[NSValue valueWithCGRect:rect]];
    }
    return resultArr;
}

- (NSArray *)posOfNumberFour
{
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:4];
    CGFloat boradWidth = [self boardWidthOfNumbers:4];
    for (int i=0; i<4; i++)
    {
//        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        CGRect rect;
        CGFloat heigth = (boradWidth - 20) / 3;
        rect.size.width = heigth;
        rect.size.height = heigth;
        switch (i)
        {
            case 0:
                rect.origin.x = 10 + heigth;
                rect.origin.y = 40-30;
                break;
            case 1:
                rect.origin.x = 10 + heigth * 2;
                rect.origin.y = 10 + heigth;
                break;
            case 2:
                rect.origin.x = 10 + heigth;
                rect.origin.y = 10 + heigth * 2;
                break;
            case 3:
                rect.origin.x = 40-30;
                rect.origin.y = 10 + heigth;
                break;
        }
//        [dict setValue:[NSValue valueWithCGRect:rect] forKey:kButtonRect];
//        [dict setValue:[NSString stringWithFormat:@"%i",i] forKey:kButtonIndex];
        [resultArr addObject:[NSValue valueWithCGRect:rect]];
//        [dict release];
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
