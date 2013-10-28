//
//  SUNButtonBoard.m
//  ButtonBoardTest
//
//  Created by 薛 迎松 on 13-8-28.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIQuickNavView.h"

#define POST_NOTIFICATION(name,obj) [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:name object:obj]];

#define TRY_TO_PERFORM(X) if ([_delegate respondsToSelector:@selector(X)]) {[_delegate X];}
NSString *const SUNButtonBoardWillOpenNotification = @"SUNButtonBoardWillOpenNotification";
NSString *const SUNButtonBoardDidOpenNotification = @"SUNButtonBoardDidOpenNotification";
NSString *const SUNButtonBoardWillCloseNotification = @"SUNButtonBoardWillCloseNotification";
NSString *const SUNButtonBoarDidCloseNotification = @"SUNButtonBoarDidCloseNotification";
NSString *const SUNButtonBoarButtonClickNotification = @"SUNButtonBoarButtonClickNotification";

static EIQuickNavView *__board = nil;

@interface EIBoardView : UIView
@property (nonatomic,assign)EIQuickNavView *navViewDelegate;
@end

@interface EIQuickNavView()
@property (nonatomic,assign) BOOL  movedWithKeyboard;
@property (nonatomic,retain) NSTimer *timer;

@property (nonatomic,retain)EIBoardView *boardView;
@property (nonatomic,retain)UIImageView *boardImageView;

@property (nonatomic,assign,getter = isOpening)BOOL opening;
@property (nonatomic,assign,getter = isAnimating) BOOL  animating;
@property (nonatomic,assign,getter = isShaking) BOOL shaking;
@property (nonatomic,assign) CGRect boardButtonRect;

@end

@implementation EIQuickNavView
@synthesize movedWithKeyboard = _movedWithKeyboard;
@synthesize timer = _timer;

@synthesize boardView = _boardView;
@synthesize boardImageView = _boardImageView;

@synthesize opening = _opening;
@synthesize animating = _animating;
@synthesize shaking = _shaking;
@synthesize boardButtonRect = _boardButtonRect;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_buttonArray release];
    [_buttonImageArray release];
    [_buttonTitleArray release];
    [_timer release];
    
    [_boardView release];
    [_boardImageView release];
    
    [super dealloc];
}

+ (EIQuickNavView *)defaultButtonBoard
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        __board = [[EIQuickNavView alloc] init];
    });
    return __board;
}

- (id)init{
    self = [super init];
    if (self) {
        
        self.autoPosition = YES;
        self.boardSize = 50;
        
        EIBoardView *boardView = [[EIBoardView alloc] initWithFrame:CGRectMake(0, 30, 50, 50)];
        boardView.navViewDelegate = self;
        boardView.backgroundColor = [UIColor clearColor];
        boardView.autoresizingMask = UIViewAutoresizingNone;
        boardView.layer.cornerRadius = 10;//设置圆角的大小
        boardView.layer.backgroundColor = [[UIColor blackColor] CGColor];
        boardView.alpha = 0.8f;//设置透明
        boardView.layer.masksToBounds = YES;
        [self.boardWindow addSubview:boardView];
        self.boardView = boardView;
        [boardView release];
        
        UIImageView *boardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        boardImageView.image = [UIImage imageNamed:@"40"];
        boardImageView.backgroundColor = [UIColor clearColor];
        [self.boardView addSubview:boardImageView];
        self.boardImageView = boardImageView;
        [boardImageView release];
        
        //增加手势点击手势和拖动手势
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHandle:)];
        [self.boardView addGestureRecognizer:gesture];
        gesture.delegate = self;
        [gesture release];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(homePanGestureHandle:)];
        [self.boardView addGestureRecognizer:panGesture];
        [panGesture release];
        
        _buttonArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self setBoardViewTrans];
    }
    return self;
}

#pragma mark Setter And Getter

- (UIWindow *)boardWindow
{
    return [[UIApplication sharedApplication] keyWindow];
}

- (CGRect)currentFrame
{
    return self.boardView.frame;
}

- (void)setBoardPosition:(CGPoint)point animate:(BOOL)animate{
    if (!self.isOpening)
    {
        if (animate)
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.boardView.center = point;
            }];
        }
        else
        {
            self.boardView.center = point;
        }
    }
}

- (void)setBoardViewTransTrue
{
    self.boardView.alpha = 0.5;
}

- (void)setBoardViewTrans
{
    if ([self.timer isValid])
    {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                  target:self
                                                selector:@selector(setBoardViewTransTrue)
                                                userInfo:nil
                                                 repeats:NO];
}

- (void)cancelTimer
{
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    _boardView.alpha = 0.8;
}


#pragma mark- gesture

- (int)directByPoint:(CGPoint)point{
    int dir = INT_MAX;
    int min = INT_MAX;
    if (abs(point.x - 0)<min) {
        min = abs(point.x - 0);
        dir = 3;
    }
    if (abs([[UIScreen mainScreen] bounds].size.width - point.x)<min) {
        min = abs([[UIScreen mainScreen] bounds].size.width - point.x);
        dir = 1;
    }
    if (abs(point.y - 0)<min) {
        min = abs(point.y - 0);
        dir = 0;
    }
    if (abs([[UIScreen mainScreen] bounds].size.height - point.y)<min) {
        min = abs([[UIScreen mainScreen] bounds].size.width - point.x);
        dir = 2;
    }
    
    return dir;
}
//适配位置所用的
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

//这个是给boardView的点击事件加的，只会在那里调用
- (void)tapGesHandle:(UITapGestureRecognizer *)gesture
{
    if (!self.isAnimating)
    {
        if (self.isOpening)
        {
            [self boardClose];
        }else
        {
            [self boardOpen];
        }
    }
}

//这个是背景window的点击事件手势
- (void)windowTaped:(UITapGestureRecognizer *)gesture
{
    if ( !self.isAnimating)
    {
        if (self.isOpening && !self.isShaking)
        {
            [self boardClose];
        }
        else if(self.isShaking)
        {
            self.shaking = NO;
            [self EndWobble];
        }
    }
}

//这个是打开之后的手势，所有只对打开之后有效
- (void)panGestureHandle:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(self.isOpening && self.isShaking)
    {
        UIView *piece = [gestureRecognizer view];
        [self.boardView bringSubviewToFront:piece];
        
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
            [gestureRecognizer state] == UIGestureRecognizerStateChanged ||
            [gestureRecognizer state] == UIGestureRecognizerStateEnded)
        {
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            CGPoint newPoint = CGPointMake([piece center].x + translation.x, [piece center].y + translation.y);
            
            [piece setCenter:newPoint];
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        }
        
        if([gestureRecognizer state] == UIGestureRecognizerStateEnded)
        {
//#warning This place still require to be finish,需要修改自动排序的算法在这里
            
            //还需要增加越界检测
            CGSize totalSize = self.boardView.bounds.size;
            CGSize pieceSize = piece.bounds.size;
            CGPoint orginCenter = piece.center;
            if(orginCenter.x<0)
            {
                piece.center = CGPointMake(pieceSize.width * .5f, orginCenter.y);
            }
            else if(orginCenter.x > totalSize.width)
            {
                piece.center = CGPointMake(totalSize.width - pieceSize.width * .5f, orginCenter.y);
            }
            
            if(orginCenter.y<0)
            {
                piece.center = CGPointMake(orginCenter.x, pieceSize.height * .5f);
            }
            else if(orginCenter.y > totalSize.height)
            {
                piece.center = CGPointMake(orginCenter.x, totalSize.height - pieceSize.height * .5f);
            }
        }
    }
}

//这个是关闭之后的才有效
- (void)homePanGestureHandle:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(!self.isOpening)
    {
        UIView *piece = self.boardView;
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
            [gestureRecognizer state] == UIGestureRecognizerStateChanged ||
            [gestureRecognizer state] == UIGestureRecognizerStateEnded)
        {
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            
            [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
        }
        
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            [self cancelTimer];
        }
        
        if([gestureRecognizer state] == UIGestureRecognizerStateEnded)
        {
            [self setBoardViewTrans];
            if (self.autoPosition)
            {
                int direction = INT16_MAX;
                direction = [self directByPoint:piece.center];
                
                CGRect frame = piece.frame;
                CGRect newRect;
                
                switch (direction) {
                    case 0:
                        newRect = CGRectMake(frame.origin.x,
                                             0,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                    case 1:
                        newRect = CGRectMake([[UIScreen mainScreen] bounds].size.width - frame.size.width,
                                             frame.origin.y,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                    case 2:
                        newRect = CGRectMake(frame.origin.x,
                                             [[UIScreen mainScreen] bounds].size.height - frame.size.height,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                    case 3:
                        newRect = CGRectMake(0,
                                             frame.origin.y,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                        
                    default:
                        break;
                }
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     piece.frame = newRect;
                                 }
                                 completion:^(BOOL finished){
                                     piece.frame = newRect;
                                 }];
                self.movedWithKeyboard = NO;
            }
        }
    }
}

- (void)LongPressGestureRecognizer:(UIGestureRecognizer *)gr
{
    if(!self.isShaking)
    {
        self.shaking = YES;
        
        if (gr.state == UIGestureRecognizerStateBegan)
        {
            [self BeginWobble];
        }
    }
}

-(void)TwoPressGestureRecognizer:(UIGestureRecognizer *)gr
{
    if(self.isShaking)
    {
        self.shaking = NO;
        
        [self EndWobble];
    }
}


#pragma mark- button

- (void)buttonAction:(UITapGestureRecognizer *)sender
{
    if(!self.isShaking && !self.isAnimating)
    {
        UIButton *button = (UIButton *)sender;
        //    UIView *view = (UIView *)sender.view;
        POST_NOTIFICATION(SUNButtonBoarButtonClickNotification, [NSNumber numberWithInt:button.tag-100])
        
        if ([self.delegate respondsToSelector:@selector(buttonBoardClickButtonAtIndex:)])
        {
            [self.delegate buttonBoardClickButtonAtIndex:button.tag-100];
        }
        
        [self boardClose];
    }
    else if(self.isShaking)
    {
        self.shaking = NO;
        [self EndWobble];
    }
}

#pragma mark- method

- (void)boardOpen{
    POST_NOTIFICATION(SUNButtonBoardWillOpenNotification,nil)
    TRY_TO_PERFORM(buttonBoardWillOpen)
    
    self.animating = YES;
    self.boardButtonRect = self.boardView.frame;
    
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         [self.boardView setFrame:CGRectMake(screenFrame.size.width/2-125,
                                                             screenFrame.size.height/2-100, 250 , 250)];
                         
                         self.boardImageView.hidden = YES;
                         
                         UITapGestureRecognizer *windowTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTaped:)];
                         [self.boardWindow addGestureRecognizer:windowTapGes];
                         [windowTapGes release];
                         
                         NSArray *imgNames = [[NSArray alloc]initWithObjects:@"download.png",@"block.png",@"bluetooth.png",@"file.png", nil];
                         NSArray *tabTitle = [[NSArray alloc]initWithObjects:@"download",@"block",@"bluetooth",@"file", nil];
                         
                         for (int i=0; i<4; i++) {
                             CGRect rect;
                             CGFloat heigth = (250 - 20) / 3;
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
                             
                             //设置每个tabView
                             UIView *tabView = [[UIView alloc] initWithFrame:rect];
                             tabView.tag = i + 100;
                             tabView.backgroundColor = [UIColor blueColor];
                             
                             //设置tabView的图标
                             UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
                             tabButton.frame = CGRectMake(20, 0, 30, 30);
                             [tabButton setBackgroundImage:[UIImage imageNamed:[imgNames objectAtIndex:i]] forState:UIControlStateNormal];
                             //                             [tabButton setTag:i + 100];
                             [tabButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                             [tabView addSubview:tabButton];
                             
                             //设置标题
                             UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 35, 60, 15)];
                             titleLabel.font = [UIFont systemFontOfSize:12];
                             titleLabel.textAlignment = NSTextAlignmentCenter;
                             titleLabel.textColor = [UIColor whiteColor];
                             titleLabel.backgroundColor = [UIColor clearColor];
                             titleLabel.text = [tabTitle objectAtIndex:i];
                             [tabView addSubview:titleLabel];
                             
                             UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressGestureRecognizer:)];
                             [tabView addGestureRecognizer:longGesture];
                             [longGesture release];
                             
                             UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandle:)];
                             [tabView addGestureRecognizer:panGesture];
                             [panGesture release];
                             
                             
                             UITapGestureRecognizer *tapGestureTel2 = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TwoPressGestureRecognizer:)]autorelease];
                             [tapGestureTel2 setNumberOfTapsRequired:2];
                             [tapGestureTel2 setNumberOfTouchesRequired:1];
                             [tabView addGestureRecognizer:tapGestureTel2];
                             
                             [self.boardView addSubview:tabView];
                             [_buttonArray addObject:tabView];
                             [tabView release];
                         }
                         
                         UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressGestureRecognizer:)];
                         [self.boardView addGestureRecognizer:longGesture];
                         [longGesture release];
                     }
                     completion:^(BOOL finished) {
                         POST_NOTIFICATION(SUNButtonBoardDidOpenNotification,nil)
                         TRY_TO_PERFORM(buttonBoardDidOpen)
                         self.animating = NO;
                         self.opening = YES;
                         [self cancelTimer];
                     }];
}


- (void)boardClose{
    POST_NOTIFICATION(SUNButtonBoardWillCloseNotification,nil)
    TRY_TO_PERFORM(buttonBoardWillClose)
    self.animating = YES;
    self.shaking = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.boardView.frame = self.boardButtonRect;
                     }
                     completion:^(BOOL finished) {
                         for (int i = 0; i<_buttonArray.count; i++){
                             UIView *tapView = [_buttonArray objectAtIndex:i];
                             [tapView removeFromSuperview];
                         }
                         [_buttonArray removeAllObjects];
                         POST_NOTIFICATION(SUNButtonBoarDidCloseNotification,nil)
                         TRY_TO_PERFORM(buttonBoardDidClose)
                         self.animating = NO;
                         self.opening = NO;
                         
                         [self.boardWindow removeGestureRecognizer:[self.boardWindow.gestureRecognizers lastObject]];
                         self.boardImageView.hidden = NO;
                         [self setBoardViewTrans];
                     }];
}


- (void)keyboardFrameWillChange:(NSNotification *)noti
{
    NSValue *value = [noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [value CGRectValue];
    float yPoint = rect.origin.y;
    
    CGRect currentFrame = [self currentFrame];
    CGRect newRect;
    
    if (yPoint == [[UIScreen mainScreen] bounds].size.height)
    {
        if (self.movedWithKeyboard)
        {
            newRect = CGRectMake(currentFrame.origin.x,
                                 yPoint - currentFrame.size.height,
                                 currentFrame.size.width,
                                 currentFrame.size.height);
            _movedWithKeyboard = NO;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.boardView.frame = newRect;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }else{
        if ([self currentFrame].origin.y > yPoint)
        {
            newRect = CGRectMake(currentFrame.origin.x,
                                 yPoint - currentFrame.size.height,
                                 currentFrame.size.width,
                                 currentFrame.size.height);
            _movedWithKeyboard = YES;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.boardView.frame = newRect;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    
}

-(void)BeginWobble
{
    for (UIView *view in self.boardView.subviews)
    {
        for (UIView *v in view.subviews)
        {
            if ([v isMemberOfClass:[UIImageView class]])
                [v setHidden:NO];
        }
    }
    
    NSAutoreleasePool* pool=[NSAutoreleasePool new];
    for (UIView *view in self.boardView.subviews)
    {
        srand([[NSDate date] timeIntervalSince1970]);
        float rand=(float)random();
        CFTimeInterval t=rand*0.0000000001;
        [UIView animateWithDuration:0.1 delay:t options:0  animations:^
         {
             view.transform=CGAffineTransformMakeRotation(-0.05);
         } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
              {
                  view.transform=CGAffineTransformMakeRotation(0.05);
              } completion:^(BOOL finished) {}];
         }];
    }
    [pool release];
}

-(void)EndWobble
{
    for (UIView *view in self.boardView.subviews)
    {
        for (UIView *v in view.subviews)
        {
            if ([v isMemberOfClass:[UIImageView class]])
                [v setHidden:YES];
        }
    }
    
    NSAutoreleasePool* pool=[NSAutoreleasePool new];
    for (UIView *view in self.boardView.subviews)
    {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             view.transform=CGAffineTransformIdentity;
             for (UIView *v in view.subviews)
             {
                 if ([v isMemberOfClass:[UIImageView class]])
                     [v setHidden:YES];
             }
         } completion:^(BOOL finished) {}];
    }
    [pool release];
}

@end

@implementation EIBoardView
@synthesize navViewDelegate = _navViewDelegate;

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitedView = [super hitTest:point withEvent:event];
    if(![self pointInside:point withEvent:event])
    {
        if([self.navViewDelegate isOpening])
        {
            return self;
        }
    }
    
    return hitedView;
}

@end
