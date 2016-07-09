//
//  TabBarController.m
//  Connect
//
//  Created by 胡凡 on 16/7/1.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "TabBarController.h"
#import "ComNavController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatControllers];
    
    [self creatUI];
    
    
}

- (void)creatUI{
    
    //设置tabBar的背景
    //    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
    
    //设置navigationbar上的文字颜色
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    //设置tabBar上的文字选中颜色
    [self.tabBar setTintColor:[UIColor colorWithRed:146/255.0 green:214/155.0 blue:125/255.0 alpha:0.8]];
    
    
}

-(void)creatControllers
{
    
    //1.拿到plist文件
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Controller.plist" ofType:nil];
    
    //2.获取数组
    NSArray * plistArray = [NSArray arrayWithContentsOfFile:path];
    
    [plistArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString * className = obj[@"className"];
        
        NSString * selimageName = obj[@"selImage"];
        NSString * norimageName = obj[@"norImage"];
        
        NSString * title = obj[@"title"];
        
        //将类名转换成类，runTime的方法
        Class HFClass = NSClassFromString(className);
        //创建控制器对象
        UIViewController * controller = [[HFClass alloc] init];
        //设置tabBarItem
        controller.title = title;
        
        //添加到tabBarController中
        ComNavController * nav = [[ComNavController alloc] initWithRootViewController:controller];
        nav.tabBarItem.image = [[UIImage imageNamed:norimageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        nav.tabBarItem.selectedImage = [[UIImage imageNamed:selimageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self addChildViewController:nav];
        
    }];
}


@end
