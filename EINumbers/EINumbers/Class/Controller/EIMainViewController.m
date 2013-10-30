//
//  EIMainViewController.m
//  EINumbers
//
//  Created by 薛 迎松 on 13-10-26.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIMainViewController.h"

@interface EIMainViewController ()

@end

@implementation EIMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Test Me" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(100, 100, 60, 44)];
    [button setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (void)buttonInit
{
    NSMutableArray *buttonRectArr = [NSMutableArray array];
    CGFloat boradWidth = 250;
    if ([_buttonArray count] == 4) {
        
        for (int i=0; i<4; i++) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            CGRect rect;
            CGFloat heigth = (boradWidth - 20) / 3;
            rect.size.width = heigth;
            rect.size.height = heigth;
            switch (i) {
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
            [dict setValue:[NSValue valueWithCGRect:rect] forKey:@"ButtonRect"];
            [dict setValue:[NSString stringWithFormat:@"%i",i] forKey:@"ButtonIndex"];
            [buttonRectArr addObject:dict];
            [dict release];
        }
    }
    else if ([_buttonArray count] == 5) {
        boradWidth = 280;
        for (int i=0; i<6; i++) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
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
                    rect.origin.y = 5;
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
            [dict setValue:[NSValue valueWithCGRect:rect] forKey:@"ButtonRect"];
            [dict setValue:[NSString stringWithFormat:@"%i",i] forKey:@"ButtonIndex"];
            [buttonRectArr addObject:dict];
            [dict release];
        }
        [_boardView setFrame:CGRectMake((_boardWindow.frame.size.width * .5f) - (boradWidth * .5f), _boardWindow.frame.size.height/2-100, boradWidth , boradWidth)];
    }
    else if ([_buttonArray count] == 6) {
        boradWidth = 280;
        for (int i=0; i<6; i++) {
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
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
            [dict setValue:[NSValue valueWithCGRect:rect] forKey:@"ButtonRect"];
            [dict setValue:[NSString stringWithFormat:@"%i",i] forKey:@"ButtonIndex"];
            [buttonRectArr addObject:dict];
            [dict release];
        }
        [_boardView setFrame:CGRectMake((_boardWindow.frame.size.width * .5f) - (boradWidth * .5f), _boardWindow.frame.size.height/2-100, boradWidth , boradWidth)];
        NSLog(@"%@",buttonRectArr);
    }
}
*/
@end
