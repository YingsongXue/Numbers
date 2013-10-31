//
//  EIMainViewController.m
//  EINumbers
//
//  Created by 薛 迎松 on 13-10-26.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIMainViewController.h"
#import "EIPieChartViewController.h"

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
    [button addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)next:(id)sender
{
    EIPieChartViewController *pie = [[EIPieChartViewController alloc] init];
    
    [self.navigationController pushViewController:pie animated:YES];
    [pie release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
