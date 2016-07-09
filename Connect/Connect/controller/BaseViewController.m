//
//  BaseViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "BaseViewController.h"

#define Width [[UIScreen mainScreen]bounds].size.width
#define Height [[UIScreen mainScreen]bounds].size.height

@interface BaseViewController ()<UIScrollViewDelegate>
//  导航栏的segMentview
@property (nonatomic, strong) Segment * segmentContronller;
//  管理两个节目的scrollview
@property (nonatomic, strong) UIScrollView * homeScrollview;
//  记录当前的选中下表
@property (nonatomic, assign) NSInteger index;


@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self CreatUI];
}

-(void)addNavItemButtonWithLeft:(BOOL)isLeft  target:(id)target action:(SEL)action IsImageOrText:(BOOL)IsImage ImageNameOrText:(NSString *)name
{
    UIButton *button = [UIButton new];
    
    
    //是图片的时候
    if (IsImage)
    {
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];

    }
    //不是图片的时候
    else
    {
        button.frame = CGRectMake(0, 0, 60, 30);
        button.titleLabel.font = [UIFont systemFontOfSize: 13.0];
        [button setTitle:name forState:UIControlStateNormal];
        
    }
    //给按钮添加点击事件
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    if (isLeft) {
        [self.navigationItem setLeftBarButtonItem:item];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:item];
    }
    
}

//返回上个界面
-(void)backToLastController
{
    [self.navigationController popViewControllerAnimated:YES];
}

//创建界面的方法
-(void)CreatUI
{
    //子类实现
}

#pragma mark - 添加segment管理的两个界面
- (void)addSegmentWithController:(UIViewController *)controller1 WithTitle:(NSString *)title1 andController:(UIViewController *)controller2 WithTitle:(NSString *)title2 {
    
    _segmentContronller = [[Segment alloc] initWithItems:@[title1, title2]];
    _segmentContronller.frame = CGRectMake(100, 200, Width - 200, 40);
    _segmentContronller.selectedColor = [UIColor whiteColor];
    _segmentContronller.unselctedColor = _segmentContronller.selectedColor;
    _segmentContronller.selectedSegmentIndex = 0;
    [_segmentContronller addTarget:self action:@selector(buttonClick:)];
    self.navigationItem.titleView = _segmentContronller;
    
    //  创建scrollView
    _homeScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Width, Height - 44)];
    [self.view addSubview:_homeScrollview];
    //  属性
    _homeScrollview.contentSize = CGSizeMake(Width * 2, Height - 44);
    _homeScrollview.pagingEnabled = YES;
    _homeScrollview.bounces = NO;
    _homeScrollview.delegate = self;
    [self changeViewController:_segmentContronller.selectedSegmentIndex];
    
    controller1.view.frame = CGRectMake(0, 64, Width, Height - 64);
    controller2.view.frame = CGRectMake(Width, 64, Width, Height - 64);
    
    [_homeScrollview addSubview:controller1.view];
    [_homeScrollview addSubview:controller2.view];
}

#pragma mark - scrollView的协议方法
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int i = scrollView.contentOffset.x / Width;
    [UIView animateWithDuration:0.4 animations:^{
        [_segmentContronller changeIndex:i];
    }];
    _segmentContronller.selectedSegmentIndex = i;
    [self viewWillAppear:YES];
}

#pragma mark - 改变当前的视图控制器
- (void) changeViewController:(NSInteger)selectedSegmentIndex {
    _homeScrollview.contentOffset = CGPointMake(selectedSegmentIndex * Width, 0);
}

#pragma mark - segmentView的点击事件
- (void) buttonClick:(Segment *) segment {
    [UIView animateWithDuration:0.5 animations:^{
        _homeScrollview.contentOffset = CGPointMake(segment.selectedSegmentIndex * Width, 0);
    }];
}

@end
