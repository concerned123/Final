//
//  ChatSenceViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/5.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "ChatSenceViewController.h"
#import "ChatTableViewCell.h"
#import <EMChatManagerDelegate.h>

@interface ChatSenceViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,EMChatManagerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

/**
 *  底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewButtonConstraint;

/**
 *  数据源
 */
@property(nonatomic,strong)NSMutableArray *dataSources;

@property(nonatomic,strong)ChatTableViewCell *chatCellTool;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


//输入框
@property (weak, nonatomic) IBOutlet UITextView *textView;

//tool高度的约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolConstraint;

@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

- (IBAction)addbutton:(id)sender;
@end

@implementation ChatSenceViewController

-(NSMutableArray *)dataSources
{
    if (!_dataSources) {
        _dataSources = [NSMutableArray new];
    }
    return _dataSources;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.commetID;
    
    //初始化数据,加载本地数据库聊天记录
    [self loadlocalRecords];
  
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
  
    
    //给计算高度的cell对象赋值
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:IDre];
    
    
    
    // Do any additional setup after loading the view.
    
    self.tabBarController.tabBar.hidden = YES;
    
    //监听键盘的弹出，更改约束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //监听键盘的收齐 时候会调用的方法。
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardClose:) name:UIKeyboardWillHideNotification object:nil];
    
    [self scrollToBtton];
    
}

-(void)loadlocalRecords
{
    EMConversation *conversations=[[EMClient sharedClient].chatManager getConversation:self.commetID type:EMConversationTypeChat createIfNotExist:YES];
    
    //加载与当前聊天用户所有的聊天记录
    NSArray *message = [conversations loadMoreMessagesContain:nil before:-1 limit:-1 from:nil direction:EMMessageSearchDirectionUp];
    
  
    //添加到数据源
    [self.dataSources addObjectsFromArray:message];
    
}

-(void)keyBoardClose:(NSNotification *)center
{
    self.inputViewButtonConstraint.constant=0;
}

#pragma mark 键盘弹出
-(void)keyboardShow:(NSNotification *)niti
{
    //获取键盘的高度
   CGRect Frame =[niti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = Frame.size.height;
    
    self.inputViewButtonConstraint.constant=height;
    [self scrollToBtton];
}


-(void)dealloc
{
    //移除通知。
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 聊天tab数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSources.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    //现获取消息
    EMMessage *message = self.dataSources[indexPath.row];
    ChatTableViewCell *cell = nil;
    
    //from to
    if ([message.from isEqualToString:self.commetID]) {
        //当发送方等于好友的id 的时候
        cell = [tableView dequeueReusableCellWithIdentifier:IDre];
    }
    else
    {
         cell = [tableView dequeueReusableCellWithIdentifier:IDse];
    }
    
    cell.message = message;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取消息的模型
    EMMessage *message = self.dataSources[indexPath.row];
    
    self.chatCellTool.message = message;
   
    return [self.chatCellTool cellHeight];
}

#pragma  mark 输入框的代理

-(void)textViewDidChange:(UITextView *)textView
{
    //1.监听文字的改变计算textView调整整个输入工具条的高度
    CGFloat textHeight = 0;
    CGFloat MinHeight = 33;//最小的高度
    CGFloat MaxHeight =70;
    
    //内容的大小。
    CGFloat contantHeight  = textView.contentSize.height;
    if (contantHeight<MinHeight)
    {
        
        textHeight = MinHeight;
    }else if(contantHeight>MaxHeight)
    {
        textHeight = MaxHeight;
    }
    else
    {
        textHeight = contantHeight;
    }
    
    self.toolConstraint.constant = 6+7+textHeight;
    //监听send,判断最后一个字符是否是换行字符
    if ([textView.text hasSuffix:@"\n"]) {
        [self sendMessage:textView.text];
        //发送后清空
        textView.text =nil;
        self.toolConstraint.constant = 47;
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange]; 
}

#pragma mark 发送文本
-(void)sendMessage:(NSString*)str
{
    NSLog(@"剪之前%@",str);
    str = [str substringToIndex:(str.length-1)];
   
    NSLog(@"剪之后%@",str);
    //创建消息体
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:str];
    
    //拿到当前本身的对象。
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc]initWithConversationID:@"" from:from to:self.commetID body:body ext:nil];
    message.chatType = EMChatTypeChat;
    
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        printf("发送成功\n");
    }];
    
    //把消息添加到数据源
    [self.dataSources addObject:message];
    [self.tableView reloadData];
    
    //设置消息滚动显示
    [self scrollToBtton];
}

#pragma mark 发送语音
-(void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration
{
    //构造语音的消息体
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:recordPath displayName:@"[语音消息]"];
    
    body.duration = (int)duration;
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.commetID from:from to:self.commetID body:body ext:nil];
    message.chatType = EMChatTypeChat;
    
    //消息体设置完成后发送
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            printf("语音发送成功\n");
        }
        
    }];
    //把消息添加到数据源
    [self.dataSources addObject:message];
    [self.tableView reloadData];
    
    //设置消息滚动显示
    [self scrollToBtton];
}

-(void)scrollToBtton
{
    //1.获取最后一行
    if (self.dataSources.count==0) {
        return;
    }
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSources.count-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark 接受消息回复
-(void)didReceiveMessages:(NSArray *)aMessages
{
    EMMessage *message = aMessages[0];
    
    //把接收的消息添加到数据源
    
    //过滤消息
    if ([message.from isEqualToString:self.commetID]) {
        [self.dataSources addObjectsFromArray:aMessages];
        [self.tableView reloadData];
        [self scrollToBtton];
    }

    
}

#pragma mark 按钮的点击事件
- (IBAction)voidceBtn:(id)sender
{
    
    //显示录音的按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    
}

#pragma mark 点中开始录音

- (IBAction)beginRecordAction:(id)sender
{
    
    int x = arc4random()%100000;
    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
    NSString *fimeName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance]asyncStartRecordingWithFileName:fimeName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音");
            //[self.view addshu]
        }
        
    }];
}

#pragma mark手指松开结束录音

- (IBAction)endRecordAction:(id)sender
{
    [[EMCDDeviceManager sharedInstance]asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"录音完成");
            NSLog(@"%@",recordPath);
            
            //发送语音服务器
            [self sendVoice:recordPath duration:aDuration];
        }
    }];
}

#pragma mark离开按钮区域

- (IBAction)cancelRecordAction:(id)sender
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

#pragma mark 点击添加按钮
- (IBAction)addbutton:(id)sender
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate =self;
    
    [self presentViewController:imagePicker animated:YES completion:^{
        //
    }];

}
@end
