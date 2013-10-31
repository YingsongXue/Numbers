//
//  EIPieChartViewController.h
//  EINumbers
//
//  Created by 亚南 on 13-10-31.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"

@interface EIPieChartViewController : UIViewController<PieChartDelegate>
{
    NSString *navTitle;
    NSMutableArray *dataArr;
}

@property (nonatomic,retain) NSString *navTitle;
@property (nonatomic,retain) NSMutableArray *dataArr;
@end
