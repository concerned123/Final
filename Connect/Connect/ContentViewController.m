//
//  ContentViewController.m
//  IM
//
//  Created by 徐杨 on 16/7/5.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import "ContentViewController.h"
//录音的控制器类
#import "RecorderViewController.h"

#define imageH 80//定义的图片的高度
#define ConversationID  @"朋友圈消息"
//哪一种类型的动态
typedef enum {
    Record,
    TextAndPicture
}ShareContent;

@interface ContentViewController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate>
{
    BOOL isShow; //判断表情菜单是否是显示状态
    UIPageControl *pageControl;     //分页控制器
    UIScrollView *scroll;           //表情滚动视图
    UICollectionViewFlowLayout *layout; //自动布局的layout
    RecorderViewController *recorder;       //录音控制器类
    
    ShareContent type;  //动态类型
    
    UISegmentedControl *seg;    //导航栏顶部的segment
    
    MBProgressHUD *hud;         //消息进度条类
    CGFloat progress;           //动态发表的进度
    CGFloat part;               //分进度
}

@property (nonatomic,strong)UIView *faceMenu;//表情菜单视图

//表情数组
@property (nonatomic,strong) NSMutableArray *faceArray;

//文本框
@property (weak, nonatomic) IBOutlet UITextView *textView;
//文本框高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeight;

//表情
@property (weak, nonatomic) IBOutlet UIButton *face;
//图片
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//图片高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionHeight;


//保存collectionView图片的数组
@property (nonatomic,strong) NSMutableArray *imagesArray;

@end

@implementation ContentViewController

#pragma mark - 表情数组懒加载
- (NSMutableArray *)faceArray
{
    if (!_faceArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmojisList" ofType:@"plist"];
        NSDictionary *tempDic = [NSDictionary dictionaryWithContentsOfFile:path];
        _faceArray = tempDic[@"People"];
    }
    return _faceArray;
}

#pragma mark - 表情菜单视图懒加载
- (UIView *)faceMenu
{
    if (!_faceMenu) {
        _faceMenu = [[UIView alloc] initWithFrame:CGRectMake(0, screenSize.height+250, screenSize.width, 250)];
        [self.view addSubview:_faceMenu];
        //设置UIScrollView的固定高度
        CGFloat scrollHeight = 150;
        //顶部减去50 底部减去50
        //scroll大小 = screenSize.width * scrollHeight
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, screenSize.width, scrollHeight)];
        //计算表情页数，每页20个
        int pages = (int)self.faceArray.count/20 + ((self.faceArray.count%20>0)?1:0);
        //设置scrollView的属性
        [scroll setContentSize:CGSizeMake(screenSize.width*pages, scrollHeight)];
        [scroll setContentOffset:CGPointZero];
        //定义按钮的单位大小
        int unit = 30;
        //计算列间隙
        CGFloat lineSpace = (screenSize.width-unit*7) / 8.0;
        //计算行间隙
        CGFloat rowSpace = (scrollHeight - unit*3) / 2.0;
        int maxY = 6;
        //每个按钮大小为15*15   3行7列
        for (int m=0; m<pages; m++) {
            for (int i=0; i<3; i++) {
                for (int j=0; j<7; j++) {
                    int count = 20*m + ((m>0)?-1:0);
                    UIButton *btn;
                    if ((count+i*7+j) == self.faceArray.count) {
                        //设置一个清除的按钮faceDelete
                        btn = [[UIButton alloc] initWithFrame:CGRectMake((m*screenSize.width)+j*unit+((j+1)*lineSpace), i*unit + (i*rowSpace), unit, unit)];
                        
                        [btn setImage:[UIImage imageNamed:@"faceDelete"] forState:(UIControlStateNormal)];
                        [scroll addSubview:btn];
                        //把下一个if判断的条件改变
                        maxY = 100;
                        //给按钮添加删除事件
                        [btn addTarget:self action:@selector(deleteFace:) forControlEvents:(UIControlEventTouchUpInside)];
                    }else if ((i==2 && j==maxY)) {
                        //设置一个清除的按钮faceDelete
                        btn = [[UIButton alloc] initWithFrame:CGRectMake((m*screenSize.width)+j*unit+((j+1)*lineSpace), i*unit + (i*rowSpace), unit, unit)];
                        [btn setImage:[UIImage imageNamed:@"faceDelete"] forState:(UIControlStateNormal)];
                        [scroll addSubview:btn];
                        //给按钮添加删除事件
                        [btn addTarget:self action:@selector(deleteFace:) forControlEvents:(UIControlEventTouchUpInside)];
                    }else if((count+i*7+j)< self.faceArray.count){
                        btn = [[UIButton alloc] initWithFrame:CGRectMake((m*screenSize.width)+j*unit+((j+1)*lineSpace), i*unit + (i*rowSpace), unit, unit)];
                        [btn setTitle:self.faceArray[count+i*7+j] forState:(UIControlStateNormal)];
                        [scroll addSubview:btn];
                        //给按钮添加点击事件
                        [btn addTarget:self action:@selector(selectFace:) forControlEvents:(UIControlEventTouchUpInside)];
                    }
                    //设置表情的tag值
                    btn.tag = count+i*7+j;
                }
            }
        }
        scroll.pagingEnabled = YES;
        scroll.delegate = self;
        scroll.showsHorizontalScrollIndicator = NO;
        //设置一个分页视图
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 215, screenSize.width, 20)];
        [pageControl setNumberOfPages:pages];
        [pageControl setCurrentPage:0];
        [pageControl setPageIndicatorTintColor:[UIColor lightGrayColor]];
        [pageControl setCurrentPageIndicatorTintColor:[UIColor blackColor]];
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:(UIControlEventValueChanged)];
        [_faceMenu addSubview:pageControl];
        [_faceMenu addSubview:scroll];
        [_faceMenu setBackgroundColor:[UIColor whiteColor]];
        
    }
    return _faceMenu;
}

#pragma mark - 保存collectionview图片数组的懒加载方法
- (NSMutableArray *)imagesArray
{
    if (!_imagesArray) {
        _imagesArray = [NSMutableArray array];
        [_imagesArray addObject:[UIImage imageNamed:@"group_participant_add"]];
    }
    return _imagesArray;
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    //动态类型默认为文字和图片
    type = TextAndPicture;
    //让UITextView的光标顶格显示
    self.automaticallyAdjustsScrollViewInsets = NO;
    //表情菜单默认隐藏
    isShow = NO;
    //设置文本的默认字体大小为17号字体
    [self.textView setFont:[UIFont systemFontOfSize:17]];
    [self.textView setDelegate:self];
    
    //设置collectionview
    layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    //注册一个cell
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"contentCell"];
    
    //初始化录音控制器类
    recorder = [[UIStoryboard storyboardWithName:@"RecordStoryboard" bundle:nil] instantiateInitialViewController];
    
    //添加键盘监听事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //设置顶部的segment点击事件
    seg = [[UISegmentedControl alloc] initWithItems:@[@"文字",@"语音"]];
    [seg setFrame:CGRectMake(0, 0, SCALE(150), SCALE(30))];
    [seg setSelectedSegmentIndex:0];
    [seg addTarget:self action:@selector(segmentChangeView:) forControlEvents:(UIControlEventValueChanged)];

    self.navigationItem.titleView = seg;
    
    UIButton *speechBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [speechBtn setFrame:CGRectMake(0, 0, 60, 60)];
    [speechBtn setTitle:@"发表" forState:(UIControlStateNormal)];
    [speechBtn addTarget:self action:@selector(sendToFriend:) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:speechBtn];
}

#pragma mark - 键盘即将出现时的监听事件
- (void)kbWillShow:(NSNotification *)noti
{
    if (isShow) {
        //如果表情菜单处于打开状态，则关闭表情菜单
        [self triggerFaceMenu:NO];
    }
}

#pragma mark - 发表按钮
- (void)sendToFriend:(UIBarButtonItem *)sender {
    //获取一个唯一标识uuid
    /**
     *  生成uuid的方法
     */
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    NSString *uuidValue = [NSString stringWithFormat:@"%@", uuidStr];
    NSLog(@"uuid = %@",uuidValue);
    //从服务器获取好友列表，发表动态的时候，给每个好友发送一次
    EMError *error = nil;
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    if (!error) {
        NSLog(@"获取好友列表成功");
        //初始化总进度和分进度
        progress = 0.0;
        part = 0.0;
        //判断当前发表动态的类型
        if (type == TextAndPicture) {
            if (self.textView.text.length>0) {
                //计算(单个好友)发送总消息数 一点文字 + 图片总数 - 预设图片一张
                int total = 1 + (int)self.imagesArray.count-1 ;
                //计算总好友发送消息数
                total *= userlist.count;
                //计算分进度
                part = 1.0 / total;
                [self determinateExampleWithView:self.view Block:^{
                    //发送文字和图片动态
                    [self sendTextAndPictureMessage:uuidValue friend:userlist];
                }];
            }else{
                NSLog(@"不能发表空内容");
            }
        }else{
            if (recorder.recordFilePath) {
                part = 1.0f;
                //发送语音动态
                [self determinateExampleWithView:recorder.view Block:^{
                    [self sendRecordMessage:uuidValue friend:userlist];
                }];
            }else{
                NSLog(@"语音消息为空");
            }
        }
    }else{
        NSLog(@"获取好友列表失败。。。");
    }
    
}

#pragma mark - 使用进度条管理消息发送进度
- (void)determinateExampleWithView:(UIView *)view Block:(void(^)(void))finishBlock{
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // 设置提示框显示模式
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = NSLocalizedString(@"正在发表...", @"HUD loading title");
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        // 开始发表内容，并且更新进度条.
        finishBlock();
    });
}


#pragma mark - 发送文字和图片动态
- (void)sendTextAndPictureMessage:(NSString *)uuidValue friend:(NSArray *)userList
{
    //获取属性文字
    NSAttributedString *attri = [[NSAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    //给每个好友发送一次
    for (NSString *username in userList) {
        //发送文字消息
        [self sendTextMessageTo:username message:attri.string uuid:@{@"uuid":uuidValue}];
        //发送图片消息
        for (int i=0; i<self.imagesArray.count-1; i++) {
            [self sendImageMessageTo:username image:self.imagesArray[i] uuid:@{@"uuid":uuidValue}];
        }
    }
}

#pragma mark - 发送录音动态
- (void)sendRecordMessage:(NSString *)uuidValue friend:(NSArray *)userList
{
    EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithLocalPath:recorder.recordFilePath displayName:@"[语音消息]"];
    body.duration = (int)recorder.recordDuration;
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    for (NSString *username in userList) {
        // 生成message
        EMMessage *message = [[EMMessage alloc] initWithConversationID:@"朋友圈消息" from:from to:username body:body ext:@{@"uuid":uuidValue}];
        message.chatType = EMChatTypeChat;// 设置为单聊消息
        
        //发送消息
        [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress += part;
                    [MBProgressHUD HUDForView:recorder.view].progress = progress;
                    //语音消息发送成功
                    [self finishVoiceMessage];
                });
            }else{
                NSLog(@"语音消息发送失败");
            }
        }];
    }
}

#pragma mark - 语音消息发送完成
- (void)finishVoiceMessage
{
    [recorder.voiceLabel setAttributedText:nil];
    [hud hideAnimated:YES];
    NSLog(@"语音消息发送完成");
}

#pragma mark - 发送一条文字消息
- (void)sendTextMessageTo:(NSString *)username message:(NSString *)msg uuid:(NSDictionary *)ext
{
    //构造一条文字消息
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:msg];
    NSString *from = [[EMClient sharedClient] currentUsername];
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:ConversationID from:from to:username body:body ext:ext];
    message.chatType = EMChatTypeChat;// 设置为单聊消息

    //发送消息
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress += part;
                NSLog(@"发表一条文字消息，当前进度为=%f",progress);
                [MBProgressHUD HUDForView:self.view].progress = progress;
                //判断是否完成
                if (progress == 1.0f) {
                    [self finishSpeech];
                }
            });
        }else{
            NSLog(@"文字消息发送失败");
        }
    }];
}

#pragma mark - 发送一张图片
- (void)sendImageMessageTo:(NSString *)username image:(UIImage *)image uuid:(NSDictionary *)ext
{
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:UIImagePNGRepresentation(image) displayName:@"image.png"];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    EMMessage *message = [[EMMessage alloc] initWithConversationID:ConversationID from:from to:username body:body ext:ext];

    message.chatType = EMChatTypeChat;// 设置为单聊消息
    
    //发送消息
    [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress += part;
                NSLog(@"发表一条图片消息，当前进度为=%f",progress);
                [MBProgressHUD HUDForView:self.view].progress = progress;
                //判断是否完成
                if (progress == 1.0f) {
                    [self finishSpeech];
                }
            });
        }else{
            NSLog(@"图片消息发送失败");
        }
        
    }];
}

#pragma mark - 完成发表之后清空数据
- (void)finishSpeech
{
    NSLog(@"文字和图片消息完成发送");
    //清空文字消息
    [self.textView setAttributedText:nil];
    //清空图片
    UIImage *firstImage = [self.imagesArray lastObject];
    [self.imagesArray removeAllObjects];
    [self.imagesArray addObject:firstImage];
    [self.collectionView reloadData];
    [hud hideAnimated:YES];
}

#pragma mark - 输入文字时，判断是否需要修改文本框的内容
- (void)textViewDidChange:(UITextView *)textView
{
    //最小高度
    CGFloat minHeight = 110;
    //最大高度
    CGFloat maxHeight = 200;
    CGFloat currentHeight = textView.contentSize.height;
    if (currentHeight<=minHeight) {
        currentHeight = minHeight;
    }else if(currentHeight >= maxHeight){
        currentHeight = maxHeight;
    }
    self.textHeight.constant = currentHeight;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 选择表情时，触发的事件
- (void)selectFace:(UIButton *)btn
{
    //获取textview中原有的属性字符串
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];

    //封装表情的属性字符串
    NSAttributedString *faceAttr = [[NSAttributedString alloc] initWithString:self.faceArray[btn.tag] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]}];
    
    [attr appendAttributedString:faceAttr];
    
    [self.textView setAttributedText:attr];
}

#pragma mark - 删除表情的事件
- (void)deleteFace:(UIButton *)btn
{
    //获取textview中原有的属性字符串
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    if (self.textView.attributedText.string.length>0) {
        [attr deleteCharactersInRange:NSMakeRange(self.textView.attributedText.length-1, 1)];
    }
    //重新设置富文本
    [self.textView setAttributedText:attr];
}

#pragma mark - 点击表情按钮，弹出表情菜单
- (IBAction)clickFace:(UIButton *)sender {
    //收起键盘
    [self.view endEditing:YES];
    if (isShow) {
        isShow = NO;
        [UIView animateWithDuration:0.25f animations:^{
            [self.faceMenu setFrame:CGRectMake(0, screenSize.height+250, screenSize.width, 250)];
        }];
    }else{
        isShow = YES;
        [UIView animateWithDuration:0.25f animations:^{
            [self.faceMenu setFrame:CGRectMake(0, screenSize.height-250, screenSize.width, 250)];
        }];
    }
}

#pragma mark - 打开或关闭表情按钮
- (void)triggerFaceMenu:(BOOL)trigger
{
    if (trigger) {
        isShow = YES;
        [UIView animateWithDuration:0.25f animations:^{
            [self.faceMenu setFrame:CGRectMake(0, screenSize.height-250, screenSize.width, 250)];
        }];
    }else{
        isShow = NO;
        [UIView animateWithDuration:0.25f animations:^{
            [self.faceMenu setFrame:CGRectMake(0, screenSize.height+250, screenSize.width, 250)];
        }];
    }
}

#pragma mark - 停止减速时，调用方法，改变页数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //计算当前偏移量
    int index = scrollView.contentOffset.x / screenSize.width;
    [pageControl setCurrentPage:index];
}

#pragma mark - 通过分页控制器，修改偏移页
- (void)changePage:(UIPageControl *)control
{
    [scroll setContentOffset:CGPointMake(control.currentPage*screenSize.width, 0) animated:YES];
}

#pragma mark - --------------------------
#pragma mark - 设置collectionview的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imagesArray.count;
}

#pragma mark - 设置collectionview的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"contentCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imagesArray[indexPath.item]];
    imageView.contentMode =  UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    imageView.clipsToBounds  = YES;
    
    [cell setBackgroundView:imageView];
    
    return cell;
}

#pragma mark - 设置每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(imageH, imageH);
}

#pragma mark - 选中cell时
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.imagesArray.count-1) {
        if (self.imagesArray.count>=10) {
            NSLog(@"最多只能添加9张图片");
        }else{
            //如果点击的是最后一张图片，则打开相册
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            //打开相册
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
}

#pragma mark - 相册的照片选中之后的回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    [self.imagesArray insertObject:image atIndex:0];
    //设置高度约束
    if (self.imagesArray.count%3 != 0) {
        int rows = (int)(self.imagesArray.count/3)+1;
        self.collectionHeight.constant = rows*imageH + rows*10;
    }
    //刷新collectionView
    [self.collectionView reloadData];
    //关闭相册
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 顶部的segment切换视图
- (void)segmentChangeView:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        //发表类型改为录音文件
        type = Record;
        [self.view addSubview:recorder.view];
    }else{
        //发表类型改为文字和图片
        type = TextAndPicture;
        [recorder.view removeFromSuperview];
    }
}



#pragma mark - 点击屏幕任意位置收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //关闭小键盘
    [self.view endEditing:YES];
    //如果表情菜单处于打开状态，则关闭菜单
    if (isShow) {
        [self triggerFaceMenu:NO];
    }
}

@end
