//
//  EIQuickNavDataModel.h
//  EINumbers
//
//  Created by 薛 迎松 on 13-10-27.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const kButtonRect;
FOUNDATION_EXTERN NSString *const kButtonIndex;

@interface EIQuickNavDataModel : NSObject

//图片的列表
//文字的列表可以作为一个数组返回给用户
- (NSArray *)pictureArray;
//用户配置的信息，应该是一个数组
- (void)setUserNav:(NSArray *)array;

- (NSArray *)defaultNav;

- (NSArray *)userNav;

//获取坐标位置，如果没有改变的话，建议使用原来的就可以，这个不会变的
- (CGRect )posOfBaseForNumbers:(NSUInteger)index total:(CGSize)totalSize;
- (NSArray *)posArrayOfNumbers:(NSUInteger)index;

+ (id)sharedInstance;

@end
