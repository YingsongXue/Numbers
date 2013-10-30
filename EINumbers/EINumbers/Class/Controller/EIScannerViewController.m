//
//  EIScannerViewController.m
//  QR code
//
//  Created by 亚南 on 13-10-26.
//  Copyright (c) 2013年 斌. All rights reserved.
//

#import "EIScannerViewController.h"
#import "UIView+MDCShineEffect.h"

@interface EIScannerViewController ()

@end

@implementation EIScannerViewController

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
    self.wantsFullScreenLayout = NO;
    [self.scanner setSymbology: ZBAR_I25
     
                        config: ZBAR_CFG_ENABLE
     
                            to: 0];
    
    //隐藏底部控制按钮
    
    self.showsZBarControls = NO;
    
    //设置自己定义的界面
    
    [self setOverlayPickerView];
	// Do any additional setup after loading the view.
}

- (void)setOverlayPickerView
{
    //清除原有控件
    
    for (UIView *temp in [self.view subviews]) {
        
        for (UIButton *button in [temp subviews]) {
            
            if ([button isKindOfClass:[UIButton class]]) {
                
                [button removeFromSuperview];
                
            }
            
        }
        
        for (UIToolbar *toolbar in [temp subviews]) {
            
            if ([toolbar isKindOfClass:[UIToolbar class]]) {
                
                [toolbar setHidden:YES];
                
                [toolbar removeFromSuperview];
                
            }
            
        }
        
    }
    CGFloat baseAlpha = 0.5f;
    //画中间的基准线
    /*
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(40, 220, 240, 1)];
    
    line.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:line];
    
    [line release];
     */
    
    UIView *camView = [[UIView alloc] initWithFrame:CGRectMake(20, 80, CGRectGetWidth(self.view.frame) - 40, 280)];
    camView.layer.borderWidth = 1;
    camView.layer.borderColor = [UIColor whiteColor].CGColor;
    camView.layer.masksToBounds = YES;
    camView.backgroundColor = [UIColor clearColor];
    [camView shineWithRepeatCount:HUGE_VALF];
    [self.view addSubview:camView];
    [camView release];
    
    //最上部view
    
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    upView.alpha = baseAlpha;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    //用于说明的label
    
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame=CGRectMake(15, 20, 290, 50);
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
//    labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    labIntroudction.text = @"Put the code image into rectangular box";
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(labIntroudction.frame))];
    lineView.backgroundColor = [UIColor whiteColor];
    [lineView addSubview:labIntroudction];
    [lineView release];
    [upView addSubview:labIntroudction];
    [labIntroudction release];
    [upView release];
    //左侧的view
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 20, 280)];
    leftView.alpha = baseAlpha;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    [leftView release];
    
    //右侧的view
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(300, 80, 20, 280)];
    rightView.alpha = baseAlpha;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    [rightView release];
    
    //底部view
    
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, 360, 320, 120)];
    downView.alpha = baseAlpha;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    [downView release];
    
    //用于取消操作的button
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.alpha = 1;
    [cancelButton setFrame:CGRectMake(20, self.view.frame.size.height - 63, 280, 40)];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancelButton];
}

- (void)dismissOverlayView:(id)sender
{
    [self dismissModalViewControllerAnimated: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
