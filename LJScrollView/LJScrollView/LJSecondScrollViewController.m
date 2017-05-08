//
//  LJSecondScrollViewController.m
//  LJDemo
//
//  Created by lj on 2017/5/5.
//  Copyright © 2017年 LJ. All rights reserved.
//

#import "LJSecondScrollViewController.h"
#import "LJDynamicItem.h"

#define maxOffsetY 150



/*f(x, d, c) = (x * d * c) / (d + c * x)
 where,
 x – distance from the edge
 c – constant (UIScrollView uses 0.55)
 d – dimension, either width or height*/

static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}

@interface LJSecondScrollViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate> {
    CGFloat width;
    CGFloat height;
    CGFloat currentScorllY;
    
    UIView *toolView;
    
    CGPoint mainPosition;
    NSMutableArray *tableArray;
    
    BOOL isVertical;//是否是垂直
}

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UITableView *subTableView;
@property (nonatomic, strong) UIScrollView *subScrollView;


//弹性和惯性动画
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, strong) LJDynamicItem *dynamicItem;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;
@end

@implementation LJSecondScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
   
    [self.view addSubview:self.mainScrollView];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, maxOffsetY + 44)];
    view.backgroundColor = [UIColor redColor];
    [self.mainScrollView addSubview:view];
    
    [self.mainScrollView addSubview:self.subScrollView];
    self.mainScrollView.contentSize = CGSizeMake(width, maxOffsetY + self.subScrollView.frame.size.height);
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.animator.delegate = self;
    self.dynamicItem = [[LJDynamicItem alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, width, height - 64)];
        _mainScrollView.delegate = self;
        _mainScrollView.scrollEnabled = NO;
        
        //记录下mainScrollView的锚点在父视图中的位置
        mainPosition = self.mainScrollView.layer.position;
    }
    return _mainScrollView;
}

- (UIScrollView *)subScrollView {
    if (_subScrollView == nil) {
        _subScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, maxOffsetY + 44, width, height - 64)];
        _subScrollView.contentSize = CGSizeMake(width * 3, _subScrollView.frame.size.height);
        _subScrollView.pagingEnabled = YES;
        _subScrollView.scrollEnabled = YES;
        _subScrollView.delegate = self;
        tableArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(i * width, 0, width, _subScrollView.frame.size.height)];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.scrollEnabled = NO;
            [_subScrollView addSubview:tableView];
            [tableArray addObject:tableView];
        }
        self.subTableView = tableArray.firstObject;
    }
    return _subScrollView;
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 26;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCellID"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",(long)indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.subScrollView) {
        CGFloat a = self.subScrollView.contentOffset.x/self.subScrollView.frame.size.width;
        self.subTableView = [tableArray objectAtIndex:a];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGFloat currentY = [recognizer translationInView:self.view].y;
        CGFloat currentX = [recognizer translationInView:self.view].x;
        
        if (currentY == 0.0) {
            return YES;
        } else {
            if (fabs(currentX)/currentY >= 5.0) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            currentScorllY = self.mainScrollView.contentOffset.y;
            CGFloat currentY = [recognizer translationInView:self.view].y;
            CGFloat currentX = [recognizer translationInView:self.view].x;
            
            if (currentY == 0.0) {
                isVertical = NO;
            } else {
                if (fabs(currentX)/currentY >= 5.0) {
                    isVertical = NO;
                } else {
                    isVertical = YES;
                }
            }
            [self.animator removeAllBehaviors];
            break;
        case UIGestureRecognizerStateChanged:
        {
            //locationInView:获取到的是手指点击屏幕实时的坐标点；
            //translationInView：获取到的是手指移动后，在相对坐标中的偏移量
            
            if (isVertical) {
                //往上滑为负数，往下滑为正数
                CGFloat currentY = [recognizer translationInView:self.view].y;
                [self controlScrollForVertical:currentY AndState:UIGestureRecognizerStateChanged];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            if (isVertical) {
                self.dynamicItem.center = self.view.bounds.origin;
                //velocity是在手势结束的时候获取的竖直方向的手势速度
                CGPoint velocity = [recognizer velocityInView:self.view];
                UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
                [inertialBehavior addLinearVelocity:CGPointMake(0, velocity.y) forItem:self.dynamicItem];
            
            
                // 通过尝试取2.0比较像系统的效果
                inertialBehavior.resistance = 2.0;
                __block CGPoint lastCenter = CGPointZero;
                __weak typeof(self) weakSelf = self;
                inertialBehavior.action = ^{
                    if (isVertical) {
                        //得到每次移动的距离
                        CGFloat currentY = weakSelf.dynamicItem.center.y - lastCenter.y;
                        [weakSelf controlScrollForVertical:currentY AndState:UIGestureRecognizerStateEnded];
                    }
                    lastCenter = weakSelf.dynamicItem.center;
                };
                [self.animator addBehavior:inertialBehavior];
                self.decelerationBehavior = inertialBehavior;
            }
        }
            break;
        default:
            break;
    }
    //保证每次只是移动的距离，不是从头一直移动的距离
    [recognizer setTranslation:CGPointZero inView:self.view];
}

//控制上下滚动的方法
- (void)controlScrollForVertical:(CGFloat)detal AndState:(UIGestureRecognizerState)state {
    //判断是主ScrollView滚动还是子ScrollView滚动,detal为手指移动的距离
    if (self.mainScrollView.contentOffset.y >= maxOffsetY) {
        CGFloat offsetY = self.subTableView.contentOffset.y - detal;
        if (offsetY < 0) {
            //当子ScrollView的contentOffset小于0之后就不再移动子ScrollView，而要移动主ScrollView
            offsetY = 0;
            self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.frame.origin.x, self.mainScrollView.contentOffset.y - detal);
        } else if (offsetY > (self.subTableView.contentSize.height - self.subTableView.frame.size.height)) {
            //当子ScrollView的contentOffset大于contentSize.height时
            offsetY = self.subTableView.contentSize.height - self.subTableView.frame.size.height;
//            offsetY = self.subTableView.contentOffset.y - rubberBandDistance(detal, height);
            CGRect frame = self.mainScrollView.frame;
            frame.origin.y += rubberBandDistance(detal, height);
            self.mainScrollView.frame = frame;
        }
        self.subTableView.contentOffset = CGPointMake(0, offsetY);
    } else {
        CGFloat mainOffsetY = self.mainScrollView.contentOffset.y - detal;
        if (mainOffsetY < 0) {
            //滚到顶部之后继续往上滚动需要乘以一个小于1的系数
            mainOffsetY = 0;
//            mainOffsetY = self.mainScrollView.contentOffset.y - rubberBandDistance(detal, height);
            CGRect frame = self.mainScrollView.frame;
            frame.origin.y += rubberBandDistance(detal, height);
            self.mainScrollView.frame = frame;
        } else if (mainOffsetY > maxOffsetY) {
            mainOffsetY = maxOffsetY;
        }
        self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.frame.origin.x, mainOffsetY);
        
        if (mainOffsetY == 0) {
            for (UITableView *tableView in tableArray) {
                tableView.contentOffset = CGPointMake(0, 0);
            }
        }
    }
    
    BOOL outsideFrame = self.mainScrollView.frame.origin.y > 64 || self.mainScrollView.frame.origin.y < 64;
    if (outsideFrame &&
        (self.decelerationBehavior && !self.springBehavior)) {

        CGPoint target = mainPosition;
        
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.mainScrollView attachedToAnchor:target];
        springBehavior.length = 0;
        springBehavior.damping = 1;
        springBehavior.frequency = 2;
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
    }
}



@end
