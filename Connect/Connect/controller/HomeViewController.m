//
//  HomeViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/5.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "HomeViewController.h"
#import "FriendViewController.h"
#import "FriendGroupViewController.h"
#import "addFriendViewController.h"



#import "Segment.h"



@interface HomeViewController ()<UIScrollViewDelegate,ToNext,EMChatManagerDelegate>

/**
 *  基础滚动视图
 */
@property(strong,nonatomic)UIScrollView *homeScrollView;


/**
 *  联系人
 */
@property(strong,nonatomic)FriendViewController *Friend;
/**
 *  群组
 */
@property(strong,nonatomic)FriendGroupViewController *FriendsGroup;

/**
 *  选择的下标
 */
@property(nonatomic,assign)NSInteger index;
@end

@implementation HomeViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNavItemButtonWithLeft:NO target:self action:@selector(addButton:) IsImageOrText:NO ImageNameOrText:@"添加好友"];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addSegmentWithController:self.Friend WithTitle:@"好友" andController:self.FriendsGroup WithTitle:@"圈子"];
    
    
    
}

#pragma mark 添加好友的按钮
-(void)addButton:(UIButton *)button
{
    //story方式跳转
     addFriendViewController *controller = [UIStoryboard storyboardWithName:@"addFriend" bundle:nil].instantiateInitialViewController ;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark ChatManager 代理方法。
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    //当网络无连接的得失
    if (connectionState == EMConnectionDisconnected) {
        NSLog(@"无网络连接");
        self.title =@"连接中..";
    }
    else
    {
        NSLog(@"网络连接成功....");
    }
}

-(void)willAutoReconnect
{
    NSLog(@"自动重新连接");
    
    
    
}
-(void)didAutoReconnectFinishedWithError:(NSError *)error
{
    if (!error) {
        NSLog(@"自动重新连接成功");
        
        self.title = @"聊天";
    }
    else
    {
        NSLog(@"自动重新连接失败");
    }
    
    
}



-(FriendViewController *)Friend
{
    if (!_Friend) {
        _Friend = [FriendViewController new];
        _Friend.delegate =self;
    }
    return _Friend;
}

-(FriendGroupViewController *)FriendsGroup
{
    if (!_FriendsGroup) {
        _FriendsGroup = [FriendGroupViewController new];
        
    }
    return _FriendsGroup;
}

-(void)tureToNextViewController:(BaseViewController *)controller
{
    [self.navigationController pushViewController:controller animated:YES];
}
@end
