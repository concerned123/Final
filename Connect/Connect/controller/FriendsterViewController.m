//
//  FriendsterViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "FriendsterViewController.h"

#import "DTTableViewCell.h"
#import "DTModel.h"
//图片浏览器
#import "JLPhoto.h"
#import "JLPhotoBrowser.h"

#import "ContentViewController.h"

static NSString *identifier = @"DTCell";

@interface FriendsterViewController ()<UITableViewDelegate,UITableViewDataSource,ImageViewDelegate,UINavigationControllerDelegate>
{
    UITableView *friendTable;       //朋友圈的tableview
    DTTableViewCell *cellTool;      //cell的计算行高的工具对象
}

//数据源
@property (nonatomic,strong) NSMutableArray<DTModel *> *dataSource;

@end

@implementation FriendsterViewController

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        //初始化一个数组
        _dataSource = [NSMutableArray array];
        //根据会话id获取会话消息
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:@"朋友圈消息" type:EMConversationTypeChat createIfNotExist:NO];
        if (!conversation) {
            NSArray<EMConversation *> *conversations = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
            for (EMConversation *sa in conversations) {
                if ([sa.conversationId isEqualToString:@"朋友圈消息"]) {
                    conversation = sa;
                    NSLog(@"从内存中获取会话");
                }
            }
        }else{
            NSLog(@"从服务器获取会话");
        }
        
        /**
         *   *  从数据库获取包含指定内容的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果aLimit是负数，则获取所有符合条件的消息
         *
         *  @param aKeywords    搜索关键字，如果为空则忽略
         *  @param aTimestamp   参考时间戳
         *  @param aLimit       获取的条数
         *  @param aSender      消息发送方，如果为空则忽略
         *  @param aDirection   消息搜索方向
         */
        //定义一个临时数组接收消息
        NSArray<EMMessage *> *messageList = [conversation loadMoreMessagesContain:nil before:-1 limit:-1 from:nil direction:EMMessageSearchDirectionUp];
        
        //判断消息是否为空
        if (messageList.count>0) {
            //获取消息的uuid唯一标识
            NSString *uuid = messageList[0].ext[@"uuid"];
            //定义一个模型
            DTModel *model = [[DTModel alloc] init];
            model.messageArray = [NSMutableArray array];
            //添加model到数据源
            [_dataSource addObject:model];
            for (EMMessage *msg in messageList) {
                if ([msg.ext[@"uuid"] isEqualToString:uuid]) {
                    [model.messageArray addObject:msg];
                }else{
                    //重新设置uuid
                    uuid = msg.ext[@"uuid"];
                    //如果uuid不相同，则重新定义一个模型
                    model = [[DTModel alloc] init];
                    model.messageArray = [NSMutableArray array];
                    [model.messageArray addObject:msg];
                    //添加model到数据源，只有重新定义了model，才会添加到数组
                    [_dataSource addObject:model];
                }
                
            }
        }
        //给数组排序
        [_dataSource sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            DTModel *msg1 = obj1;DTModel *msg2 = obj2;
            NSString *time1 = [NSString stringWithFormat:@"%lld",msg1.messageArray[0].serverTime];
            NSString *time2 = [NSString stringWithFormat:@"%lld",msg2.messageArray[0].serverTime];
            return [time2 compare:time1];
        }];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    BOOL flag = [[EMClient sharedClient].chatManager deleteConversation:@"朋友圈消息" deleteMessages:YES];
    //
    //    if (flag) {
    //        NSLog(@"删除会话成功");
    //    }else{
    //        NSLog(@"删除会话失败");
    //    }
    
    friendTable = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
    [friendTable setDelegate:self];
    [friendTable setDataSource:self];
    [friendTable setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    [friendTable setAllowsSelection:NO];
    [self.view addSubview:friendTable];
    
    //注册一个cell
    [friendTable registerNib:[UINib nibWithNibName:@"DTTableViewCell" bundle:nil] forCellReuseIdentifier:identifier];
    
    //复用一个cell
    cellTool = [friendTable dequeueReusableCellWithIdentifier:identifier];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(speech)];
}

#pragma mark - 发表动态页面
- (void)speech
{
    ContentViewController *contentVC = [[UIStoryboard storyboardWithName:@"speechBoard" bundle:nil] instantiateInitialViewController];
    
    [self.navigationController pushViewController:contentVC animated:YES];
}

#pragma mark - 返回tableview的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

#pragma mark - 设置每个cell的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //设置内容
    cell.model = self.dataSource[indexPath.row];
    //设置代理
    cell.delegate = self;
    
    return cell;
}

#pragma mark - 设置行高
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cellTool.model = self.dataSource[indexPath.row];
    
    return [cellTool cellHeight];
}

#pragma mark - 代理方法
- (void)beginPickerImage:(NSArray *)imageArray andUrlArray:(NSArray *)urlArray andIndex:(int)index
{
    //打开图片浏览器的三方类
    NSMutableArray *photos = [NSMutableArray array];
    for (int i=0; i<imageArray.count; i++) {
        JLPhoto *photo = [[JLPhoto alloc] init];
        photo.sourceImageView = imageArray[i];
        photo.bigImgUrl = urlArray[i];
        photo.tag = i;
        [photos addObject:photo];
    }
    JLPhotoBrowser *photoBrowser = [[JLPhotoBrowser alloc] init];
    photoBrowser.photos = photos;
    photoBrowser.currentIndex = index;
    [photoBrowser show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
