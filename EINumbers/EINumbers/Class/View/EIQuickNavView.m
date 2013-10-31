//
//  SUNButtonBoard.m
//  ButtonBoardTest
//
//  Created by 薛 迎松 on 13-8-28.
//  Copyright (c) 2013年 薛 迎松. All rights reserved.
//

#import "EIQuickNavView.h"
#import "EIQuickNavDataModel.h"

#define POST_NOTIFICATION(name,obj) [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:name object:obj]];

#define TRY_TO_PERFORM(X) if ([_delegate respondsToSelector:@selector(X)]) {[_delegate X];}

#define kSepValue 2
#define kEraseButtonTag 4
#define kClickButtonTag 3
#define kLabelTag 2

NSString *const SUNButtonBoardWillOpenNotification = @"SUNButtonBoardWillOpenNotification";
NSString *const SUNButtonBoardDidOpenNotification = @"SUNButtonBoardDidOpenNotification";
NSString *const SUNButtonBoardWillCloseNotification = @"SUNButtonBoardWillCloseNotification";
NSString *const SUNButtonBoarDidCloseNotification = @"SUNButtonBoarDidCloseNotification";
NSString *const SUNButtonBoarButtonClickNotification = @"SUNButtonBoarButtonClickNotification";

static EIQuickNavView *__board = nil;

#pragma mark Public Method
float intersec(float a,float b)
{
    return b>a?b-a:0;
}

float intersection(CGRect r1,CGRect r2)
{
    float xs = MAX(r1.origin.x, r2.origin.x);
    float xe = MIN(r1.origin.x + r1.size.width, r2.origin.x + r2.size.width);
    float x = intersec(xs, xe);
    float ys = MAX(r1.origin.y, r2.origin.y);
    float ye = MIN(r1.origin.y + r1.size.height, r2.origin.y + r2.size.height);
    float y = intersec(ys, ye);
//    NSLog(@"%f:%f:%f;%f:%f:%f",xs,xe,x,ys,ye,y);
    return x*y;
}

float intersectionPercert(CGRect r1,CGRect r2)
{
    float section = intersection(r1, r2);
    return section / (r1.size.width * r1.size.height);
}

CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt)
{
    const CGFloat fx = pt.x;
    const CGFloat fy = pt.y;
    const CGFloat fcos = cos(angle);
    const CGFloat fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
}

@interface EIBoardView : UIView
@property (nonatomic,assign)EIQuickNavView *navViewDelegate;
@end

@interface EIAddButtonItem : NSObject
@property (nonatomic,retain)NSString *picture;
@property (nonatomic,assign,getter = isSelected)BOOL selected;
@end

@implementation EIAddButtonItem

@synthesize picture = _picture;
@synthesize selected = _selected;
- (BOOL)isSelected
{
    return _selected;
}

@end

@interface EIQuickNavView()
    <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,assign) BOOL  movedWithKeyboard;
@property (nonatomic,retain) NSTimer *timer;
@property (nonatomic,retain) NSArray *posArray;
@property (nonatomic,retain) NSMutableArray *userArray;
@property (nonatomic,retain)EIBoardView *boardView;
@property (nonatomic,retain)UIImageView *boardImageView;
@property (nonatomic,retain) UIView *addBgView;
@property (nonatomic,retain) NSMutableArray *addPictureArray;

@property (nonatomic,retain) UIGestureRecognizer *tapGesture;
@property (nonatomic,retain) UIGestureRecognizer *panGesture;

@property (nonatomic,assign,getter = isOpening)BOOL opening;
@property (nonatomic,assign,getter = isAnimating) BOOL  animating;
@property (nonatomic,assign,getter = isShaking) BOOL shaking;
@property (nonatomic,assign,getter = isAdding) BOOL adding;
@property (nonatomic,assign) CGRect boardButtonRect;
@property (nonatomic,assign) CGPoint orginalPoint;

@end

@implementation EIQuickNavView
@synthesize movedWithKeyboard = _movedWithKeyboard;
@synthesize timer = _timer;
@synthesize posArray = _posArray;
@synthesize boardView = _boardView;
@synthesize boardImageView = _boardImageView;
@synthesize addBgView = _addBgView;
@synthesize addPictureArray = _addPictureArray;

@synthesize tapGesture = _tapGesture;
@synthesize panGesture = _panGesture;

@synthesize opening = _opening;
@synthesize animating = _animating;
@synthesize shaking = _shaking;
@synthesize boardButtonRect = _boardButtonRect;
@synthesize orginalPoint = _orginalPoint;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_buttonArray release];
    [_buttonImageArray release];
    [_buttonTitleArray release];
    [_timer release];
    
    [_boardView release];
    [_boardImageView release];
    [_addBgView release];
    [_addPictureArray release];
    
    [_tapGesture release];
    [_panGesture release];
    
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
        
        EIBoardView *boardView = [[EIBoardView alloc] initWithFrame:CGRectMake(kSepValue, 30, 60, 60)];
        boardView.navViewDelegate = self;
        [self.boardWindow addSubview:boardView];
        self.boardView = boardView;
        [self initialBoardView];
        [boardView release];
        
        UIImageView *boardImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        boardImageView.image = [UIImage imageNamed:@"40"];
        boardImageView.backgroundColor = [UIColor clearColor];
        [self.boardView addSubview:boardImageView];
        self.boardImageView = boardImageView;
        [boardImageView release];
        
        _buttonArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [self setBoardViewTrans];
    }
    return self;
}

#pragma mark Setter And Getter
- (void)initialBoardView
{
    self.boardView.backgroundColor = [UIColor clearColor];
    self.boardView.autoresizingMask = UIViewAutoresizingNone;
    self.boardView.layer.cornerRadius = 10;//设置圆角的大小
    self.boardView.layer.backgroundColor = [[UIColor blackColor] CGColor];
    self.boardView.alpha = 0.8f;//设置透明
    self.boardView.layer.masksToBounds = YES;
    
    //增加手势点击手势和拖动手势
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesHandle:)];
    [self.boardView addGestureRecognizer:gesture];
    gesture.delegate = self;
    self.tapGesture = gesture;
    [gesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(homePanGestureHandle:)];
    [self.boardView addGestureRecognizer:panGesture];
    self.panGesture = panGesture;
    [panGesture release];
}

- (void)cleanBoardView
{
    self.boardView.backgroundColor = [UIColor clearColor];
    self.boardView.autoresizingMask = UIViewAutoresizingNone;
    self.boardView.layer.cornerRadius = 0;//设置圆角的大小
    self.boardView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    self.boardView.alpha = 1.0f;//设置透明
    self.boardView.layer.masksToBounds = NO;
    
    [self.boardView removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
    [self.boardView removeGestureRecognizer:self.panGesture];
    self.panGesture = nil;
}

- (void)initialAddBgView
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    [self removeAllViews];
    
    self.boardView.frame = frame;
    
    UIView *view = [[UIView alloc] initWithFrame:self.boardView.frame];
    self.addBgView = view;
    [self.boardView addSubview:view];
    [view release];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.boardView.frame style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor grayColor];
    [self.addBgView addSubview:tableView];
    [tableView release];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:CGRectMake(frame.size.width * 0.5f,frame.size.height - 50, 80, 44)];
    button.tag = 1000;
    [button setTitle:@"New way" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(endAddNewButton) forControlEvents:UIControlEventTouchUpInside];
    [self.addBgView addSubview:button];
    
    [self cleanBoardView];
}

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
    [UIView animateWithDuration:0.2 animations:^{
        self.boardView.alpha = 0.3;
    }];
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
    [UIView animateWithDuration:0.2 animations:^{
        self.boardView.alpha = 0.8;
    }];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.addPictureArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.textLabel.numberOfLines = 2;
        cell.backgroundColor = [UIColor  clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:19];
    }
    
    EIAddButtonItem *item = [self.addPictureArray objectAtIndex:[indexPath row]];
    cell.imageView.image = [UIImage imageNamed:item.picture];
    cell.textLabel.text = item.picture;
    if(item.isSelected)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int count = 0;
    for (int i = 0; i < [self.addPictureArray count]; i++)
    {
        EIAddButtonItem *item = [self.addPictureArray objectAtIndex:i];
        if(item.isSelected)
        {
            count++;
        }
    }
    EIAddButtonItem *item = [self.addPictureArray objectAtIndex:[indexPath row]];
    if((count <8 && !item.isSelected) ||
       (count > 4 && item.isSelected))
    {
        item.selected = !item.isSelected;
    }
    [tableView reloadData];
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
//        min = abs([[UIScreen mainScreen] bounds].size.width - point.x);
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
        if(self.isAdding)
        {
            return;
        }
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
        if(self.isAdding)
        {
            return;
        }
        if (self.isOpening && !self.isShaking)
        {
            [self boardClose];
        }
        else if(self.isShaking)
        {
            [self endEdit];
        }
    }
}

//这个是打开之后的手势，所有只对打开之后有效
- (void)panGestureHandle:(UIPanGestureRecognizer *)gestureRecognizer
{
    if(self.isAdding)
    {
        return;
    }
    if(self.isOpening && self.isShaking)
    {
        UIView *piece = [gestureRecognizer view];
        [self.boardView bringSubviewToFront:piece];
        
        [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
        
        if([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            [self shaking:piece isShake:NO];
            UIView *button = [piece viewWithTag:kClickButtonTag];
            CGRect frame = button.frame;
            button.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width * 1.4, frame.size.height * 1.4);
        }
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
            [gestureRecognizer state] == UIGestureRecognizerStateChanged ||
            [gestureRecognizer state] == UIGestureRecognizerStateEnded)
        {
            CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
            CGPoint newPoint = CGPointMake([piece center].x + translation.x, [piece center].y + translation.y);
            
            [piece setCenter:newPoint];
            [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
            
            CGRect cRect = piece.frame;
            int currentIndex = (int)[_buttonArray indexOfObject:piece];//(int)piece.tag - 100;
            int intersectIndex = -1;
            int total = (int)[self.userArray count];
            for (int i = 0; i < [self.posArray count]; i++)
            {
                CGRect rect = [[self.posArray objectAtIndex:i] CGRectValue];
                if(intersectionPercert(rect,cRect)>0.4)
                {
                    if(i != currentIndex)
                    {
                        intersectIndex = i;
                        int sub = 0;
                        int add = 0;
                        if(currentIndex > intersectIndex)
                        {
                            sub = currentIndex - intersectIndex;
                            add = intersectIndex + total - currentIndex;
                        }
                        else
                        {
                            add = intersectIndex - currentIndex;
                            sub = currentIndex + total - intersectIndex;
                        }
                        __block NSMutableArray *weakUserArray = self.userArray;
                        __block NSMutableArray *weakButtonArray = _buttonArray;
                        __block NSArray *weakPosArray = self.posArray;
                        [UIView animateWithDuration:0.3 animations:^{
                            if(add < sub)
                            {
                                for (int i = currentIndex; i != intersectIndex; i=(i+1)%total)
                                {
                                    
                                    [weakUserArray exchangeObjectAtIndex:i withObjectAtIndex:(i+1)%total];
                                    [weakButtonArray exchangeObjectAtIndex:i withObjectAtIndex:(i+1)%total];
                                    UIView *view = [weakButtonArray objectAtIndex:i];
                                    view.frame = [[weakPosArray objectAtIndex:i] CGRectValue];
                                }
                            }
                            else
                            {
                                for (int i = currentIndex; i != intersectIndex; )
                                {
                                    int next = i>0?(i-1):(total-1);
                                    [weakUserArray exchangeObjectAtIndex:i withObjectAtIndex:next];
                                    [weakButtonArray exchangeObjectAtIndex:i withObjectAtIndex:next];
                                    UIView *view = [weakButtonArray objectAtIndex:i];
                                    view.frame = [[weakPosArray objectAtIndex:i] CGRectValue];
                                    
                                    i = next;
                                }
                            }
                        }];

                    }
                }
            }
        }
        
        if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
           [gestureRecognizer state] == UIGestureRecognizerStateCancelled)
        {
            [self shaking:piece isShake:YES];
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
            
            [UIView animateWithDuration:0.3 animations:^{
                [self resizeFrame];
            }];
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
                                             kSepValue,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                    case 1:
                        newRect = CGRectMake([[UIScreen mainScreen] bounds].size.width - frame.size.width-kSepValue,
                                             frame.origin.y,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                    case 2:
                        newRect = CGRectMake(frame.origin.x,
                                             [[UIScreen mainScreen] bounds].size.height - frame.size.height-kSepValue,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                    case 3:
                        newRect = CGRectMake(kSepValue,
                                             frame.origin.y,
                                             frame.size.width,
                                             frame.size.height);
                        break;
                        
                    default:
                        break;
                }
                
                [UIView animateWithDuration:0.2
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
//    CGRect f = [gr view].frame;
//    NSLog(@"{[%f,%f],[%f,%f]}",f.origin.x,f.origin.y,f.size.width,f.size.height);
//    CGPoint translation = [gr translationInView:[[gr view] superview]];
//    
//    CGPoint newPoint = CGPointMake([ center].x + translation.x, [piece center].y + translation.y);
    
    if(!self.isShaking)
    {
        self.shaking = YES;
        
        if (gr.state == UIGestureRecognizerStateBegan)
        {
            [self startEdit];
        }
    }
}

-(void)TwoPressGestureRecognizer:(UIGestureRecognizer *)gr
{
    if(self.isShaking && !self.isAdding)
    {
        [self endEdit];
    }
}


#pragma mark- button

- (void)buttonAction:(UIButton *)sender
{
    if(self.isAdding)
    {
        return;
    }
    if(!self.isShaking && !self.isAnimating)
    {
        UIView *view = [sender superview];
        int num = (int)[_buttonArray indexOfObject:view];
        POST_NOTIFICATION(SUNButtonBoarButtonClickNotification, [NSNumber numberWithInt:num])
        NSLog(@"%d",num);
        if ([self.delegate respondsToSelector:@selector(buttonBoardClickButtonAtIndex:)])
        {
            [self.delegate buttonBoardClickButtonAtIndex:num];
        }
        
        [self boardClose];
    }
    else if(self.isShaking)
    {
        [self endEdit];
    }
}

- (void)removeMe:(UIButton *)button
{
    if(self.isAdding)
    {
        return;
    }
    if([self.userArray count]>4)
    {
        NSUInteger index = [_buttonArray indexOfObject:[button superview] ];
        [self.userArray removeObjectAtIndex:index];
        [[EIQuickNavDataModel sharedInstance] setUserNav:self.userArray];
        __block id weakSelf = self;
        __block NSMutableArray *weakButtonArray = _buttonArray;
        __block UIView *view = [_buttonArray objectAtIndex:index];
        [UIView animateWithDuration:0.4 animations:^{
            [view setFrame:CGRectZero];
            [view removeFromSuperview];
            [weakButtonArray removeObject:view];
            [weakSelf resizeFrame];
        } completion:^(BOOL finished){
            [weakSelf resizeFrame];
        }];
    }
    
    if([self.userArray count]<=4)
    {
        [self setEraseHidden:YES];
    }
}

- (void)addNewButton:(id)sender
{
    self.adding = YES;
    
    NSArray *pictureArray = [[EIQuickNavDataModel sharedInstance] pictureArray];
    NSInteger count = [pictureArray count];
    self.addPictureArray = [NSMutableArray arrayWithCapacity:count];
    for (int i= 0; i <count;i++)
    {
        EIAddButtonItem *item = [[EIAddButtonItem alloc] init];
        item.picture = [NSString stringWithString:[pictureArray objectAtIndex:i]];
        item.selected = NO;
        for (int j =0; j < [self.userArray count]; j++)
        {
            int s = [[self.userArray objectAtIndex:j] intValue];
            if(s == i)
            {
                item.selected = YES;
            }
        }
        
        [self.addPictureArray addObject:item];
        [item release];
    }
    
    [self initialAddBgView];
    [self.boardWindow removeGestureRecognizer:[self.boardWindow.gestureRecognizers lastObject]];
    [self endEdit];
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGPoint center = self.addBgView.center;
    self.addBgView.center = CGPointMake(center.x, center.y+frame.size.height);
    __block EIQuickNavView *weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.addBgView.center = center;
    }];
}

- (void)endAddNewButton
{
    if(self.isAdding)
    {
        int count = (int)[self.addPictureArray count];
        NSMutableArray *arr = [NSMutableArray array];
        for (int i= 0; i <count;i++)
        {
            EIAddButtonItem *item = [self.addPictureArray objectAtIndex:i];
            if(item.isSelected)
            {
                [arr addObject:[NSNumber numberWithInt:i]];
            }
        }
        [[EIQuickNavDataModel sharedInstance] setUserNav:arr];
        
        UITapGestureRecognizer *windowTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTaped:)];
        [self.boardWindow addGestureRecognizer:windowTapGes];
        [windowTapGes release];
        
        __block EIQuickNavView *weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf.addBgView removeFromSuperview];
            weakSelf.addBgView = nil;
            weakSelf.adding = NO;
            [weakSelf initialBoardView];
            [weakSelf resizeSubView];
            [weakSelf resizeFrame];
        }];
        [self startEdit];
    }
}

#pragma mark- method
- (void)resizeFrame
{
    EIQuickNavDataModel *model = [EIQuickNavDataModel sharedInstance];
    self.userArray = [NSMutableArray arrayWithArray:[model userNav]];
    NSUInteger total = [self.userArray count];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    NSArray *rectArray = [model posArrayOfNumbers:total];
    self.posArray = [NSArray arrayWithArray:rectArray];
    
    CGRect boardViewFrame = [model posOfBaseForNumbers:total total:size];
    
    UIView *addButtonView = [self.boardView viewWithTag:99];
    addButtonView.frame = CGRectMake((boardViewFrame.size.width-44) * .5f, (boardViewFrame.size.height-44) * .5f, 44, 44);
    
    for (int i =0; i < total; i++)
    {
        CGRect rect = [[rectArray objectAtIndex:i] CGRectValue];
        UIView *view = (UIView *)[_buttonArray objectAtIndex:i];
        view.alpha = 1.0f;
        [view setFrame:rect];
        
        UIButton *tabButton = (UIButton *)[view viewWithTag:kClickButtonTag];
        tabButton.frame = CGRectMake(12.5, 0, view.bounds.size.width-25, view.bounds.size.height - 25);//view.bounds;//CGRectMake((rect.size.width -30)* .5f, (rect.size.height - 30) * .5f, 30, 30);
        
        UIButton *label = (UIButton *)[view viewWithTag:kLabelTag];
        label.frame = CGRectMake(0, view.bounds.size.height-25, view.bounds.size.width, 25);
        
        UIButton *eraseButton = (UIButton *)[view viewWithTag:kEraseButtonTag];
        eraseButton.frame = CGRectMake((rect.size.width-44+16), -16, 44, 44);
    }
    self.boardView.frame = boardViewFrame;
}

- (void)resizeSubView
{
    [self removeAllViews];
    
    EIQuickNavDataModel *model = [EIQuickNavDataModel sharedInstance];
    self.userArray = [NSMutableArray arrayWithArray:[model userNav]];
    
    NSUInteger total = [self.userArray count];
    
    NSArray *rectArray = [model posArrayOfNumbers:total];
    self.posArray = [NSMutableArray arrayWithArray:rectArray];
    
    NSArray *pictureArray = [model pictureArray];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setImage:[UIImage imageNamed:@"add.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(addNewButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 99;
    button.hidden = YES;
    [self.boardView addSubview:button];
    
    for (int i =0; i < total; i++)
    {
        NSUInteger userIndex = [[self.userArray objectAtIndex:i] unsignedIntegerValue];
        NSString *imageName = [pictureArray objectAtIndex:userIndex];
        //设置每个tabView
        UIView *tabView = [[UIView alloc] initWithFrame:CGRectZero];
        tabView.alpha = 0.0;
        
        //设置tabView的图标
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.tag = kClickButtonTag;
        [tabButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [tabButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [tabView addSubview:tabButton];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = kLabelTag;
        label.text = [imageName substringToIndex:[imageName length] -4];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [tabView addSubview:label];
        [label release];
        
        UIButton *eraseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [eraseButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        eraseButton.tag = kEraseButtonTag;
        eraseButton.hidden = YES;
        [eraseButton addTarget:self action:@selector(removeMe:) forControlEvents:UIControlEventTouchUpInside];
        [tabView addSubview:eraseButton];
        
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
}

- (void)removeAllViews
{
    NSArray *viewArr = self.boardView.subviews;
    for (UIView *view in viewArr)
    {
        if(view != self.boardImageView)
        {
            [view removeFromSuperview];
        }
    }
    [_buttonArray removeAllObjects];
}

- (void)startEdit
{
    self.shaking = YES;
    [self BeginWobble];
    EIQuickNavDataModel *model = [EIQuickNavDataModel sharedInstance];
    NSArray *user = [model userNav];
    self.userArray = [NSMutableArray arrayWithArray:user];
    [[self.boardView viewWithTag:99] setHidden:NO];
    if([self.userArray count]>4)
    {
        [self setEraseHidden:NO];
    }
    else
    {
        [self setEraseHidden:YES];
    }
}

- (void)endEdit
{
    self.shaking = NO;
    [self EndWobble];
    EIQuickNavDataModel *model = [EIQuickNavDataModel sharedInstance];
    [model setUserNav:self.userArray];
    [self setEraseHidden:YES];
     [[self.boardView viewWithTag:99] setHidden:YES];
}

- (void)setEraseHidden:(BOOL)isHidden
{
    for (UIView *view in _buttonArray) {
        UIButton *button = (UIButton *)[view viewWithTag:kEraseButtonTag];
        button.hidden = isHidden;
    }
}

- (void)boardOpen{
    POST_NOTIFICATION(SUNButtonBoardWillOpenNotification,nil)
    TRY_TO_PERFORM(buttonBoardWillOpen)
    
    self.animating = YES;
    self.boardButtonRect = self.boardView.frame;
    [self resizeSubView];

    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self resizeFrame];

                         self.boardImageView.hidden = YES;
                         
                         UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongPressGestureRecognizer:)];
                         [self.boardView addGestureRecognizer:longGesture];
                         [longGesture release];
                         
                         UITapGestureRecognizer *windowTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(windowTaped:)];
                         [self.boardWindow addGestureRecognizer:windowTapGes];
                         [windowTapGes release];
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
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.boardView.frame = self.boardButtonRect;
                     }
                     completion:^(BOOL finished) {
                         for (int i = 0; i<_buttonArray.count; i++){
                             UIView *tapView = [_buttonArray objectAtIndex:i];
                             [tapView removeFromSuperview];
                         }
                         [_buttonArray removeAllObjects];
                         [[self.boardView viewWithTag:99] removeFromSuperview];
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

- (void)shaking:(UIView *)view isShake:(BOOL)isShake
{
    [[view viewWithTag:kEraseButtonTag] setHidden:!isShake];
    if(isShake)
    {
        srand([[NSDate date] timeIntervalSince1970]);
        float rand=(float)random();
        CFTimeInterval t=rand*0.0000000001;
        [UIView animateWithDuration:0.1 delay:t options:0  animations:^
         {
             view.transform = CGAffineTransformMakeRotationAt(-0.05, CGPointMake(0.5, 0.5));
         } completion:^(BOOL finished)
         {
             [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
              {
                  view.transform = CGAffineTransformMakeRotationAt(0.05, CGPointMake(0.5, 0.5));
              } completion:^(BOOL finished) {}];
         }];
    }
    else
    {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             view.transform=CGAffineTransformIdentity;
             
         } completion:^(BOOL finished) {}];
    }
}

-(void)BeginWobble
{
    NSAutoreleasePool* pool=[NSAutoreleasePool new];
    for (UIView *view in _buttonArray)
    {
        [self shaking:view isShake:YES];
    }
    [pool release];
}

-(void)EndWobble
{
    NSAutoreleasePool* pool=[NSAutoreleasePool new];
    for (UIView *view in _buttonArray)
    {
        [self shaking:view isShake:NO];
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
        if([self.navViewDelegate isOpening] &&
           ![self.navViewDelegate isAdding])
        {
            return self;
        }
    }
    
    return hitedView;
}

@end
