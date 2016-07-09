//
//  FriendViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "FriendViewController.h"
#import "ChatSenceViewController.h"
#import "FriendsterViewController.h"

@interface FriendViewController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate>

@property (nonatomic, strong) UITableView * tabView;
//  数据源
@property (nonatomic, strong) NSArray * buddyList;

@end

@implementation FriendViewController

-(NSArray *)buddyList
{
    if (!_buddyList) {
        _buddyList = [NSArray new];
    }
    return _buddyList;
}

 - (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = NO;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    EMError *error = nil;
    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    if (error) {
        printf("出现请求的错误\n");
        NSLog(@"错误是:%@",error.errorDescription);
    }
    
    //监听好友是否添加成功
    //移除好友回调
    [[EMClient sharedClient].contactManager removeDelegate:self];
}

-(void)CreatUI
{
    self.tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Width, Height) style:UITableViewStylePlain];
    self.tabView.delegate =self;
    self.tabView.dataSource =self;
    self.tabView.backgroundColor = [UIColor redColor];
    self.tabView.rowHeight = 50;
    //添加刷新
    //[self addMJRefreshHead];
    //[self addMJRefreshFoot];
    
    
    [self.view addSubview:_tabView];
}

#pragma mark 添加刷新

- (void) addMJRefreshHead {
    
    self.tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        //重新获取数据
       // [self reloadBuddy];
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage
{
    //当收到用户添加完成后，更新数据源
    [self reloadBuddy];
    [self.tabView reloadData];
    
    
}

#pragma mark 请求数据
-(void)reloadBuddy
{
    EMError *error = nil;
    self.buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    
         [self.tabView.mj_header endRefreshing];
    
   
    
}


#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    printf("好友的个数是:%lu",(unsigned long)self.buddyList.count);
    return self.buddyList.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"BuddyCell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:1 reuseIdentifier:ID];
    
    
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead@2x"];
    
    cell.textLabel.text = self.buddyList[indexPath.row];
    
    
    return cell;
}

-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        printf("执行\n");
        EMError *error = nil;
        self.buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        [self.tabView reloadData];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatSenceViewController *controller = [UIStoryboard storyboardWithName:@"ChatSence" bundle:nil].instantiateInitialViewController ;
    //FriendsterViewController *second = [FriendsterViewController new];
    
    controller.commetID = self.buddyList[indexPath.row];
    
    
    [self.delegate tureToNextViewController:controller];
}
@end
