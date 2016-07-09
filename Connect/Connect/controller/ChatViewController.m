//
//  ChatViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)CreatUI
{
    //
    [self addNavItemButtonWithLeft:YES target:self action:@selector(button:) IsImageOrText:NO ImageNameOrText:@"hufan"];
}

-(void)button:(UIButton *)btn
{
    NSLog(@"按钮点击");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
