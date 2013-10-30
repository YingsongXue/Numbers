//
//  EIAddQuickNavViewController.m
//  EINumbers
//
//  Created by 薛 迎松 on 13-10-30.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIAddQuickNavViewController.h"
#import "EIQuickNavDataModel.h"

@interface EIAddQuickNavViewController ()

@end

@implementation EIAddQuickNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(100,200, 80, 44)];
    button.tag = 1000;
    [button setTitle:@"New way" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(endAddNewButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)endAddNewButton
{
    [self.view removeFromSuperview];
}

@end
