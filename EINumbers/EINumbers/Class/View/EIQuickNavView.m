//
//  SUNButtonBoard.m
//  ButtonBoardTest
//
//  Created by 孙 化育 on 13-8-28.
//  Copyright (c) 2013年 孙 化育. All rights reserved.
//

#import "EIQuickNavView.h"

#define POST_NOTIFICATION(X) [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:X object:nil]];

#define TRY_TO_PERFORM(X) if ([_delegate respondsToSelector:@selector(X)]) {[_delegate X];}

static EIQuickNavView *__board = nil;

NSString *const SUNButtonBoardWillOpenNotification = @"SUNButtonBoardWillOpenNotification";

NSString *const SUNButtonBoardDidOpenNotification = @"SUNButtonBoardDidOpenNotification";

NSString *const SUNButtonBoardWillCloseNotification = @"SUNButtonBoardWillCloseNotification";

NSString *const SUNButtonBoarDidCloseNotification = @"SUNButtonBoarDidCloseNotification";

NSString *const SUNButtonBoarButtonClickNotification = @"SUNButtonBoarButtonClickNotification";

@interface EIQuickNavView()

@property (nonatomic,assign) BOOL  animating;
@property (nonatomic,assign) BOOL  movedWithKeyboard;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,assign) BOOL  isTrans;
@property (nonatomic,assign) BOOL m_bTransform;

@end


@implementation EIQuickNavView
@synthesize running = _running;
@synthesize animating = _animating;
@synthesize movedWithKeyboard = _movedWithKeyboard;
@synthesize timer = _timer;
@synthesize isTrans = _isTrans;
@synthesize m_bTransform = _m_bTransform;

- (void)dealloc{
    self.buttonImageArray = nil;
    self.buttonTitleArray = nil;
    [_buttonArray release];
    [_timer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

+ (EIQuickNavView *)defaultButtonBoard{
    
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
        _boardSize = 50;
        _boardWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 30, 50, 50)];
        _boardWindow.backgroundColor = [UIColor clearColor];
        _boardWindow.windowLevel = 3000;
        _boardWindow.clipsToBounds = NO;
        
        [_boardWindow makeKeyAndVisible];
        _boardWindow.hidden = YES;
        
        _boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _boardView.backgroundColor = [UIColor clearColor];
        _boardView.selfBoard = self;
        _boardView.backgroundImageView.frame = CGRectMake(0, 0, 50, 50);
        _boardView.backgroundImageView.image = [UIImage imageNamed:@"40"];
        _boardView.backgroundImageView.backgroundColor = [UIColor clearColor];
        _boardView.autoresizingMask = UIViewAutoresizingNone;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHundel:)];
        [_boardView addGestureRecognizer:gesture];
        gesture.delegate = self;
        [gesture release];
        
        UILongPressGestureRecognizer *lpgr = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressGestureRecognizer:)] autorelease];
        [_boardView addGestureRecognizer:lpgr];
        
        UITapGestureRecognizer *tapGestureTel2 = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TwoPressGestureRecognizer:)]autorelease];
        [tapGestureTel2 setNumberOfTapsRequired:2];
        [tapGestureTel2 setNumberOfTouchesRequired:1];
        [_boardView addGestureRecognizer:tapGestureTel2];
        
        _boardView.userInteractionEnabled = YES;
        [_boardWindow addSubview:_boardView];
        [_boardView release];
        
        _buttonArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self setBoardViewTrans];
    }
    return self;
}

- (void)startRunning{
    if (_running) {
        return;
    }
    _boardWindow.hidden = NO;
    _running = YES;
}

- (void)stopRunning{
    if (!_running) {
        return;
    }
    
    _boardWindow.hidden = YES;
    _running = NO;
}

- (void)setBoardImage:(UIImage *)boardImage{
    _boardView.backgroundImageView.image = boardImage;
}

- (UIImage *)boardImage{
    return _boardView.backgroundImageView.image;
}

- (void)setBoardSize:(float)boardSize{
    if (_isOpen) {
        return;
    }
    _boardSize = boardSize;
    _boardWindow.frame = CGRectMake(_boardWindow.frame.origin.x,
                                    _boardWindow.frame.origin.y,
                                    boardSize,
                                    boardSize);
    _boardView.frame = CGRectMake(_boardView.frame.origin.x,
                                  _boardView.frame.origin.y,
                                  boardSize,
                                  boardSize);
}

- (CGRect)currentFrame{
    if (_isOpen) {
        return _boardView.frame;
    }else{
        return _boardWindow.frame;
    }
    
}

- (void)setBoardPosition:(CGPoint)point animate:(BOOL)animate{
    if (_isOpen) {
        return;
    }
    if (animate) {
        [UIView animateWithDuration:0.3 animations:^{
            _boardWindow.center = point;
        }];
    }else{
        _boardWindow.center = point;
    }
}


#pragma mark- gesture
- (void)tapGesHundel:(UITapGestureRecognizer *)gesture{
    if (_animating) {
        return;
    }
    if (!_isOpen) {
        [self boardOpen];
    }else{
        [self boardClose];
    }
}

- (void)windowTaped:(UITapGestureRecognizer *)gesture{
    if (_animating) {
        return;
    }else{
        
    }
    
    if (_isOpen) {
        [self boardClose];
    }
}


#pragma mark- button

- (void)buttonAction:(UITapGestureRecognizer *)sender
{
    
    UIView *view = (UIView *)sender.view;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:SUNButtonBoarButtonClickNotification object:[NSNumber numberWithInt:view.tag-100]]];
    
    if ([_delegate respondsToSelector:@selector(buttonBoardClickButtonAtIndex:)]){
        [_delegate buttonBoardClickButtonAtIndex:view.tag-100];
    }
    
    
    [self boardClose];
}

#pragma mark- method

- (void)boardOpen{
    POST_NOTIFICATION(SUNButtonBoardWillOpenNotification)
    TRY_TO_PERFORM(buttonBoardWillOpen)
    _animating = YES;
    _boardRect = _boardWindow.frame;
    _boardWindow.frame = [[UIScreen mainScreen] bounds];
    _boardView.frame = _boardRect;
    
    //    int direction = [_boardView directByPoint:_boardView.center];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [_boardView setFrame:CGRectMake(_boardWindow.frame.size.width/2-125, _boardWindow.frame.size.height/2-100, 250 , 250)];
                         
                         //view 设置半透明 圆角样式
                         _boardView.layer.cornerRadius = 10;//设置圆角的大小
                         _boardView.layer.backgroundColor = [[UIColor blackColor] CGColor];
                         _boardView.alpha = 0.8f;//设置透明
                         _boardView.layer.masksToBounds = YES;
                         _boardView.backgroundImageView.image = nil;
                         [_boardView removeGestureRecognizer:[[_boardView gestureRecognizers] lastObject]];
                         
                         UITapGestureRecognizer *windowTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTaped:)];
                         [_boardWindow addGestureRecognizer:windowTapGes];
                         
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
                             tabView.backgroundColor = [UIColor clearColor];
                             
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
                             titleLabel.textAlignment = UITextAlignmentCenter;
                             titleLabel.textColor = [UIColor whiteColor];
                             titleLabel.backgroundColor = [UIColor clearColor];
                             titleLabel.text = [tabTitle objectAtIndex:i];
                             [tabView addSubview:titleLabel];
                             
                             UITapGestureRecognizer *tapAciton = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
                             tapAciton.numberOfTapsRequired = 1;
                             [tabView addGestureRecognizer:tapAciton];
                             
                             [windowTapGes requireGestureRecognizerToFail:tapAciton];
                             
                             [tapAciton release];
                             
                             [_boardView addSubview:tabView];
                             [_buttonArray addObject:tabView];
                             [tabView release];
                         }
                         [windowTapGes release];
                     }
                     completion:^(BOOL finished) {
                         POST_NOTIFICATION(SUNButtonBoardDidOpenNotification)
                         TRY_TO_PERFORM(buttonBoardDidOpen)
                         _animating = NO;
                         _isOpen = YES;
                         [self cancelTimer];
                     }];
}


- (void)boardClose{
    POST_NOTIFICATION(SUNButtonBoardWillCloseNotification)
    TRY_TO_PERFORM(buttonBoardWillClose)
    _animating = YES;
    [UIView animateWithDuration:0.3
                     animations:^{
                         _boardWindow.frame = _boardRect;
                         _boardView.frame = CGRectMake(0, 0, _boardSize, _boardSize);
                     }
                     completion:^(BOOL finished) {
                         for (int i = 0; i<_buttonArray.count; i++){
                             UIView *tapView = [_buttonArray objectAtIndex:i];
                             [tapView removeFromSuperview];
                         }
                         [_buttonArray removeAllObjects];
                         POST_NOTIFICATION(SUNButtonBoarDidCloseNotification)
                         TRY_TO_PERFORM(buttonBoardDidClose)
                         _animating = NO;
                         _isOpen = NO;
                         
                         [_boardWindow removeGestureRecognizer:[[_boardWindow gestureRecognizers] lastObject]];
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHundel:)];
                         [_boardView addGestureRecognizer:gesture];
                         gesture.delegate = self;
                         [gesture release];
                         
                         _boardView.backgroundImageView.image = [UIImage imageNamed:@"40"];
                         [self setBoardViewTrans];
                     }];
}


- (void)keyboardFrameWillChange:(NSNotification *)noti{
    NSValue *value = [noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [value CGRectValue];
    float yPoint = rect.origin.y;
    
    CGRect newRect;
    
    if (yPoint == [[UIScreen mainScreen] bounds].size.height) {
        if (_movedWithKeyboard) {
            newRect = CGRectMake(_boardWindow.frame.origin.x,
                                 yPoint - _boardWindow.frame.size.height,
                                 _boardWindow.frame.size.width,
                                 _boardWindow.frame.size.height);
            _movedWithKeyboard = NO;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _boardWindow.frame = newRect;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }else{
        if (_boardWindow.frame.origin.y > yPoint) {
            newRect = CGRectMake(_boardWindow.frame.origin.x,
                                 yPoint - _boardWindow.frame.size.height,
                                 _boardWindow.frame.size.width,
                                 _boardWindow.frame.size.height);
            _movedWithKeyboard = YES;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 _boardWindow.frame = newRect;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    
}

- (void)setBoardViewTransTrue
{
    _boardView.alpha = 0.5;
}

- (void)setBoardViewTrans
{
    //    [self performSelector:@selector(setBoardViewTransTrue) withObject:nil afterDelay:5];
    if ([self.timer isValid]) {
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

- (void)LongPressGestureRecognizer:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        if (_m_bTransform)
            return;
        
        for (UIView *view in _boardView.subviews)
        {
            view.userInteractionEnabled = YES;
            for (UIView *v in view.subviews)
            {
                if ([v isMemberOfClass:[UIImageView class]])
                    [v setHidden:NO];
            }
        }
        _m_bTransform = YES;
        [self BeginWobble];
    }
}

-(void)TwoPressGestureRecognizer:(UIGestureRecognizer *)gr
{
    if(_m_bTransform==NO)
        return;
    
    for (UIView *view in _boardView.subviews)
    {
        view.userInteractionEnabled = NO;
        for (UIView *v in view.subviews)
        {
            if ([v isMemberOfClass:[UIImageView class]])
                [v setHidden:YES];
        }
    }
    _m_bTransform = NO;
    [self EndWobble];
}

-(void)BeginWobble
{
    NSAutoreleasePool* pool=[NSAutoreleasePool new];
    for (UIView *view in _boardView.subviews)
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
    NSAutoreleasePool* pool=[NSAutoreleasePool new];
    for (UIView *view in _boardView.subviews)
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

//-------------------------------------------------------------------------//

@interface BoardView ()

@property (nonatomic,retain) NSTimer *timer;

@end

@implementation BoardView
@synthesize timer = _timer;


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundImageView = [[UIImageView alloc] init];
        [self addSubview:_backgroundImageView];
    }
    
    return self;
}

- (void)dealloc{
    self.backgroundImageView = nil;
    [_timer release];
    [super dealloc];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _backgroundImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_selfBoard.animating) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    _beginPoint = [touch locationInView:self.window];
    _selfBeginCenter = self.center;
    [self cancelTimer];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [self cancelTimer];
    if (_selfBoard.animating) {
        return;
    }
    if (_selfBoard.isOpen) {
        return;
    }
    _moving = YES;
    UITapGestureRecognizer *ges = [self.gestureRecognizers lastObject];
    ges.enabled = NO;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.window];
    self.center = CGPointMake(_selfBeginCenter.x+(point.x - _beginPoint.x),
                              _selfBeginCenter.y+(point.y - _beginPoint.y));
    
    UITouch *previousTouch = [touches anyObject];
    CGPoint previousPoint = [previousTouch previousLocationInView:self.window];
    
    _direction = NSNotFound;
    int velocity = [self velocityByPoint:point andPoint:previousPoint];
    if (abs(velocity) > 15) {
        int velocityX = point.x - previousPoint.x;
        int velocityY = point.y - previousPoint.y;
        if (abs(velocityX) > abs(velocityY)) {
            if (velocity>0) {
                _direction = 1;
            }else{
                _direction = 3;
            }
        }else{
            if (velocity>0) {
                _direction = 2;
            }else{
                _direction = 0;
            }
        }
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_moving) {
        _moving = NO;
        UITapGestureRecognizer *ges = [self.gestureRecognizers lastObject];
        ges.enabled = YES;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.window];
        self.window.center = CGPointMake(self.window.center.x + (point.x - _beginPoint.x),
                                         self.window.center.y + (point.y - _beginPoint.y));
        self.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
        
        
        if (self.selfBoard.autoPosition) {
            int direction = INT16_MAX;
            
            
            if (_direction != NSNotFound) {
                direction = _direction;
            }else{
                direction = [self directByPoint:self.window.center];
            }
            
            
            
            CGRect newRect;
            
            switch (direction) {
                case 0:
                    newRect = CGRectMake(self.window.frame.origin.x,
                                         0,
                                         self.window.frame.size.width,
                                         self.window.frame.size.height);
                    break;
                case 1:
                    newRect = CGRectMake([[UIScreen mainScreen] bounds].size.width - self.window.frame.size.width,
                                         self.window.frame.origin.y,
                                         self.window.frame.size.width,
                                         self.window.frame.size.height);
                    break;
                case 2:
                    newRect = CGRectMake(self.window.frame.origin.x,
                                         [[UIScreen mainScreen] bounds].size.height - self.window.frame.size.height,
                                         self.window.frame.size.width,
                                         self.window.frame.size.height);
                    break;
                case 3:
                    newRect = CGRectMake(0,
                                         self.window.frame.origin.y,
                                         self.window.frame.size.width,
                                         self.window.frame.size.height);
                    break;
                    
                default:
                    break;
            }
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.window.frame = newRect;
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
            self.selfBoard.movedWithKeyboard = NO;
            [self setBoardViewTrans];
        }
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_moving) {
        _moving = NO;
        UITapGestureRecognizer *ges = [self.gestureRecognizers lastObject];
        ges.enabled = YES;
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.window];
        self.window.center = CGPointMake(self.window.center.x + (point.x - _beginPoint.x),
                                         self.window.center.y + (point.y - _beginPoint.y));
        self.frame = CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    }
}

- (void)setBoardViewTransTrue
{
    self.alpha = 0.5;
}

- (void)setBoardViewTrans
{
    //    [self performSelector:@selector(setBoardViewTransTrue) withObject:nil afterDelay:5];
    if ([self.timer isValid]) {
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
    self.alpha = 0.8;
}

#pragma mark- tool

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


- (int)velocityByPoint:(CGPoint)point1 andPoint:(CGPoint)point2{
    int velocityX = point1.x - point2.x;
    int velocityY = point1.y - point2.y;
    
    if (abs(velocityX) > abs(velocityY)) {
        return velocityX;
    }else{
        return velocityY;
    }
}


@end











