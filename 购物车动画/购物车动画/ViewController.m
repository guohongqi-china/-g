//
//  ViewController.m
//  购物车动画
//
//  Created by MacBook on 16/10/20.
//  Copyright © 2016年 MacBook. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "ViewController.h"
typedef void (^animationFinisnBlock)(BOOL finish);

@interface ViewController ()<UIScrollViewDelegate,CAAnimationDelegate>


@property (nonatomic, strong) UIButton *addBt;/** <#注释#> */
@property (nonatomic, strong) UIImageView *shopCar;/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *anmationArr;/** <#注释#> */
@property (nonatomic, strong) NSMutableArray *anmationBigArr;/** <#注释#> */
@property (nonatomic, strong) UIScrollView * scrollView;/** <#注释#> */
@property (copy , nonatomic) animationFinisnBlock animationFinisnBlock;

@property (nonatomic, strong) UIImageView *animationView;/** <#注释#> */


@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    _anmationArr = [NSMutableArray array];
    _anmationBigArr = [NSMutableArray array];
    
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(0, 2*kScreenHeight);
    [self.view addSubview:_scrollView];
    
    _addBt = [[UIButton alloc]initWithFrame:CGRectMake(40, 300, 80, 80)];
    [_addBt setBackgroundImage:[UIImage imageNamed:@"1430113902_tmGaoZLs.jpg"] forState:(UIControlStateNormal)];
    [_addBt addTarget:self action:@selector(sender:) forControlEvents:(UIControlEventTouchUpInside)];
    [_scrollView addSubview:_addBt];
    
    _shopCar = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenWidth - 150, kScreenHeight - 150, 50, 50)];
    _shopCar.image = [UIImage imageNamed:@"shopCart_r"];
    [self.view addSubview:_shopCar];
    
    _animationView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 100, 80, 80)];
    _animationView.image = [UIImage imageNamed:@"1430113902_tmGaoZLs.jpg"];
    [_scrollView addSubview:_animationView];
    
    

}

- (void)sender:(UIButton *)sender{
    [self addProducsAnimation:_animationView];
}

- (void)addProducsAnimation:(UIImageView *)imageView{
    
    //转换坐标系，
    CGRect newFrame = [imageView convertRect:imageView.bounds toView:self.view];
    
    //给图层做动画
    CALayer *transitionLayer = [CALayer layer];
    transitionLayer.frame = newFrame;
    transitionLayer.contents = imageView.layer.contents;
    transitionLayer.contentsGravity = kCAGravityResizeAspectFill;
    [self.view.layer addSublayer:transitionLayer];
    [_anmationArr addObject:transitionLayer];
    

    //路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:transitionLayer.position];
    [path addQuadCurveToPoint:_shopCar.layer.position controlPoint:CGPointMake(kScreenWidth/2, transitionLayer.position.y-80)];
    
    //关键帧动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    
    //旋转动画
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.removedOnCompletion = YES;
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:12];
    rotateAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //3D缩放动画
//    CABasicAnimation *transformAnimation = [[CABasicAnimation alloc]init];
//    transformAnimation.keyPath = @"transform";
//    transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DScale(CATransform3DIdentity, 0.2, 0.2, 1)];
    
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    transformAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    transformAnimation.toValue = [NSNumber numberWithFloat:0.3];
    transformAnimation.repeatCount = 1;
    transformAnimation.duration = pathAnimation.duration;
    

    
    CAAnimationGroup *groupAnimation = [[CAAnimationGroup alloc]init];
    groupAnimation.animations = @[pathAnimation,rotateAnimation,transformAnimation];
    groupAnimation.duration = 0.8;
    groupAnimation.delegate = self;

    [transitionLayer addAnimation:groupAnimation forKey:nil];
    
}

-(void)startAnimationandView:(UIView *)view andRect:(CGRect)rect andFinisnRect:(CGPoint)finishPoint andFinishBlock:(animationFinisnBlock)completion
{
    //图层
   CALayer *_layer = [CALayer layer];
    _layer.contents = view.layer.contents;
    _layer.contentsGravity = kCAGravityResizeAspectFill;
    rect.size.width = 60;
    rect.size.height = 60;   //重置图层尺寸
    _layer.bounds = rect;
    _layer.cornerRadius = rect.size.width/2;
    _layer.masksToBounds = YES;          //圆角

    [self.view.layer addSublayer:_layer];
    
    _layer.position = CGPointMake(rect.origin.x+view.frame.size.width/2, CGRectGetMidY(rect)); //a 点
    // 路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_layer.position];
    [path addQuadCurveToPoint:finishPoint controlPoint:CGPointMake(kScreenWidth/2, rect.origin.y-80)];
    //关键帧动画
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    //
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.removedOnCompletion = YES;
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:12];
    rotateAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[pathAnimation,rotateAnimation];
    groups.duration = 1.2f;
    groups.removedOnCompletion=NO;
    groups.fillMode=kCAFillModeForwards;
    groups.delegate = self;
    [_layer addAnimation:groups forKey:@"group"];
    if (completion) {
        _animationFinisnBlock = completion;
    }
}

- (void)animationDidStart:(CAAnimation *)anim{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect parentFrame = [_addBt convertRect:_addBt.bounds toView:[UIApplication sharedApplication].keyWindow];
    NSLog(@"%f",parentFrame.origin.y);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
