//
//  EIPieChartViewController.m
//  EINumbers
//
//  Created by 亚南 on 13-10-31.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIPieChartViewController.h"
#import "PieChartView.h"

#define PIE_HEIGHT 280

@interface EIPieChartViewController ()
@property (nonatomic,retain) NSMutableArray *valueArray;
@property (nonatomic,retain) NSMutableArray *colorArray;
@property (nonatomic,retain) NSMutableArray *valueArray2;
@property (nonatomic,retain) NSMutableArray *colorArray2;
@property (nonatomic,retain) PieChartView *pieChartView;
@property (nonatomic,retain) UIView *pieContainer;
@property (nonatomic)BOOL inOut;
@property (nonatomic,retain) UILabel *selLabel;
@end

@implementation EIPieChartViewController
@synthesize navTitle = _navTitle;
@synthesize dataArr = _dataArr;

- (void)dealloc
{
    [_valueArray release];
    [_colorArray release];
    [_valueArray2 release];
    [_colorArray2 release];
    [_pieContainer release];
    [_selLabel release];
    [_navTitle release];
    [_dataArr release];
    [super dealloc];
}

- (void)dataInit
{
    if ([self.dataArr count] > 0) {
        //初始化数据
    }
    else {
        self.valueArray = [[[NSMutableArray alloc] initWithObjects:
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:2],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:3],
                           [NSNumber numberWithInt:4],
                           nil]autorelease];
        self.valueArray2 = [[[NSMutableArray alloc] initWithObjects:
                            [NSNumber numberWithInt:3],
                            [NSNumber numberWithInt:2],
                            [NSNumber numberWithInt:2],
                            nil]autorelease];
        
        self.colorArray = [NSMutableArray arrayWithObjects:
                           [UIColor colorWithHue:((0/8)%20)/20.0+0.02 saturation:(0%8+3)/10.0 brightness:91/100.0 alpha:1],
                           [UIColor colorWithHue:((1/8)%20)/20.0+0.02 saturation:(1%8+3)/10.0 brightness:91/100.0 alpha:1],
                           [UIColor colorWithHue:((2/8)%20)/20.0+0.02 saturation:(2%8+3)/10.0 brightness:91/100.0 alpha:1],
                           [UIColor colorWithHue:((3/8)%20)/20.0+0.02 saturation:(3%8+3)/10.0 brightness:91/100.0 alpha:1],
                           [UIColor colorWithHue:((4/8)%20)/20.0+0.02 saturation:(4%8+3)/10.0 brightness:91/100.0 alpha:1],
                           [UIColor colorWithHue:((5/8)%20)/20.0+0.02 saturation:(5%8+3)/10.0 brightness:91/100.0 alpha:1],
                           nil];
        self.colorArray2 = [[[NSMutableArray alloc] initWithObjects:
                            [UIColor purpleColor],
                            [UIColor orangeColor],
                            [UIColor magentaColor],
                            nil]autorelease];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inOut = YES;
    
    [self dataInit];
    
    //add shadow img
    CGRect pieFrame = CGRectMake((self.view.frame.size.width - PIE_HEIGHT) / 2, 80-0, PIE_HEIGHT, PIE_HEIGHT);
    
    UIImage *shadowImg = [UIImage imageNamed:@"shadow.png"];
    UIImageView *shadowImgView = [[[UIImageView alloc]initWithImage:shadowImg] autorelease];
    shadowImgView.frame = CGRectMake(0, pieFrame.origin.y + PIE_HEIGHT*0.92, shadowImg.size.width/2, shadowImg.size.height/2);
    [self.view addSubview:shadowImgView];
    
    self.pieContainer = [[[UIView alloc]initWithFrame:pieFrame]autorelease];
    self.pieChartView = [[[PieChartView alloc]initWithFrame:self.pieContainer.bounds withValue:self.valueArray withColor:self.colorArray] autorelease];
    self.pieChartView.delegate = self;
    [self.pieContainer addSubview:self.pieChartView];
    [self.pieChartView setAmountText:@"-2456.0"];
    [self.view addSubview:self.pieContainer];
    
    //add selected view
    UIImageView *selView = [[[UIImageView alloc]init]autorelease];
    selView.image = [UIImage imageNamed:@"select.png"];
    selView.frame = CGRectMake((self.view.frame.size.width - selView.image.size.width/2)/2, self.pieContainer.frame.origin.y + self.pieContainer.frame.size.height, selView.image.size.width/2, selView.image.size.height/2);
    [self.view addSubview:selView];
    
    self.selLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 24, selView.image.size.width/2, 21)]autorelease];
    self.selLabel.backgroundColor = [UIColor clearColor];
    self.selLabel.textAlignment = NSTextAlignmentCenter;
    self.selLabel.font = [UIFont systemFontOfSize:17];
    self.selLabel.textColor = [UIColor whiteColor];
    [selView addSubview:self.selLabel];
    [self.pieChartView setTitleText:@"支出总计"];
    self.title = @"对账单";
    self.view.backgroundColor = [self colorFromHexRGB:@"f3f3f3"];
}

- (UIColor *) colorFromHexRGB:(NSString *) inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

- (void)selectedFinish:(PieChartView *)pieChartView index:(NSInteger)index percent:(float)per
{
    self.selLabel.text = [NSString stringWithFormat:@"%2.2f%@",per*100,@"%"];
}

- (void)onCenterClick:(PieChartView *)pieChartView
{
    self.inOut = !self.inOut;
    self.pieChartView.delegate = nil;
    [self.pieChartView removeFromSuperview];
    self.pieChartView = [[[PieChartView alloc]initWithFrame:self.pieContainer.bounds withValue:self.inOut?self.valueArray:self.valueArray2 withColor:self.inOut?self.colorArray:self.colorArray2] autorelease];
    self.pieChartView.delegate = self;
    [self.pieContainer addSubview:self.pieChartView];
    [self.pieChartView reloadChart];
    
    if (self.inOut) {
        [self.pieChartView setTitleText:@"支出总计"];
        [self.pieChartView setAmountText:@"-2456.0"];
        
    }else{
        [self.pieChartView setTitleText:@"收入总计"];
        [self.pieChartView setAmountText:@"+567.23"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.pieChartView reloadChart];
}

@end
