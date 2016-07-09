//
//  DTTableViewCell.m
//  IM
//
//  Created by 徐杨 on 16/7/6.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import "DTTableViewCell.h"

#import "VoicePlayTool.h"

#define screenSize [UIScreen mainScreen].bounds.size

static NSString *itemIdentifier = @"showImageCell";

@interface DTTableViewCell()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    BOOL hasImage;          //是否有图片
    int lines;              //UICollectionView的行数
    CGFloat width;          //每个item的宽度，高度和宽度一致
}

//存储图片的数组
@property (nonatomic,strong) NSMutableArray *imageArray;
//存储图片路径的数组
@property (nonatomic,strong) NSMutableArray *urlArray;

@end

@implementation DTTableViewCell

- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (NSMutableArray *)urlArray
{
    if (!_urlArray) {
        _urlArray = [NSMutableArray array];
    }
    return _urlArray;
}

//设置内容
- (void)setModel:(DTModel *)model
{
    //设置文本内容的最大宽度
    self.textContent.preferredMaxLayoutWidth = screenSize.width * 0.9;
    //先移除数组中的全部元素
    [_imageArray removeAllObjects];
    //设置头像
    self.headIcon.image = [UIImage imageNamed:@"chatListCellHead"];
    //设置用户名
    self.username.text = model.messageArray[0].from;
    //设置发送时间
    self.timestamp.text = [self dateStrFromCstampTime:[NSString stringWithFormat:@"%lld",model.messageArray[0].serverTime] withDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //设置文字内容和图片
    //先从消息队列中查找文字消息
    for (EMMessage *msg in model.messageArray) {
        EMMessageBody *msgBody = msg.body;
        //如果消息类型是文字消息
        if(msgBody.type == EMMessageBodyTypeText){
            //设置文字内容
            EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
            self.textContent.text = textBody.text;
            [self.textContent setNumberOfLines:0];
        }else if(msgBody.type == EMMessageBodyTypeImage){
            //图片
            EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
            //设置图片
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
            [imgView sd_setImageWithURL:[NSURL URLWithString:body.remotePath] placeholderImage:[UIImage imageNamed:@"weibo-movie_dianping_picture-icon"]];
            [self.imageArray addObject:imgView];
            [self.urlArray addObject:body.remotePath];
            //存在图片
            hasImage = YES;
        }else if(msgBody.type == EMMessageBodyTypeVoice){
            //语音
            // 音频sdk会自动下载
            EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
            //显示语音消息
            [self showVoiceWithDuration:body.duration];
        }
    }
    //如果存在图片，则设置collectionView
    if (hasImage) {
        //设置代理
        [self.collectionView setDelegate:self];
        [self.collectionView setDataSource:self];
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        [self.collectionView setScrollEnabled:NO];
        //注册item
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:itemIdentifier];
        [self.collectionView reloadData];
        //计算UICollectionView的行数
        if (self.imageArray.count%3 != 0) {
            lines = (int)self.imageArray.count/3 + 1;
        }else{
            lines = (int)self.imageArray.count/3;
        }
    }
    //设置分隔视图的颜色
    [self.splitView setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];

    //设置模型
    _model = model;
}

#pragma mark - 显示语音
- (void)showVoiceWithDuration:(NSInteger)aDuration
{
    NSMutableAttributedString *voiceAttr = [[NSMutableAttributedString alloc] init];
    
    //添加图片
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    [attach setBounds:CGRectMake(0, -3, 20, 20)];
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
    [voiceAttr appendAttributedString:imageAttr];
    //添加文字
    NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld'",aDuration] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [voiceAttr appendAttributedString:textAttr];
    
    //添加提示文字
    NSAttributedString *promptAttr = [[NSAttributedString alloc] initWithString:@"  [点击播放]"];
    [voiceAttr appendAttributedString:promptAttr];
    
    //设置富文本
    [self.textContent setAttributedText:voiceAttr];
    
    //添加轻点手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.textContent setUserInteractionEnabled:YES];
    [self.textContent addGestureRecognizer:tap];
}

#pragma mark - 轻点之后，播放语音
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    EMMessageBody *body = self.model.messageArray[0].body;
    if (body.type == EMMessageBodyTypeVoice) {
        EMVoiceMessageBody *voicebody = (EMVoiceMessageBody *)body;
        //播放音频
        VoicePlayTool *tool = [[VoicePlayTool alloc] init];
        //开始播放
        [tool playVoiceWithPath:voicebody.localPath onView:self.textContent andDuration:voicebody.duration];
    }
    
}

#pragma mark - 计算cell的高度
- (CGFloat)cellHeight
{
    //更新布局
    [self layoutIfNeeded];
    //计算CollectionView的高度
    //高度 = 总行数*width + (总行数-1)*5 + 2点上下边距
    CGFloat height = lines*width + (lines-1)*5 + 2;
    return 8 + 50 + 10 + self.textContent.bounds.size.height + 10 + height + 5 + 8;
}

#pragma mark - 设置列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark - 设置行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark - 设置item的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

#pragma mark - 设置每个item的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    //设置呈现图片的视图
    UIImageView *imageView = self.imageArray[indexPath.item];

    [imageView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    imageView.contentMode =  UIViewContentModeScaleAspectFill;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    imageView.clipsToBounds  = YES;
    
    [cell.contentView addSubview:imageView];
    
    return cell;
}

#pragma mark - 设置每个item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(width, width);
}

#pragma mark - 点击选中的item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //先判断是否有代理
    if ([self.delegate respondsToSelector:@selector(beginPickerImage:andUrlArray:andIndex:)]) {
        //调用代理方法
        [self.delegate beginPickerImage:self.imageArray andUrlArray:self.urlArray andIndex:(int)indexPath.item];
    }
    
}


#pragma mark - 将时间戳转换为标准时间
- (NSString *)dateStrFromCstampTime:(NSString *)timeStamp
                     withDateFormat:(NSString *)format{
    //@"1423189125874"
    NSString * timeStampString = timeStamp;
    NSTimeInterval _interval=[timeStampString doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:format];
    
    return [objDateformat stringFromDate: date];
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //默认不存在图片
    hasImage = NO;
    
    //UICollectionView距离cell边界两边都是8  = 16
    //每个cell的行和列的间距为5   3行3列  10
    //宽度 = (屏幕宽度 - 间距) / 3.0
    //高度 = 总行数*width + (总行数-1)*5
    //计算每个item的宽度
    width = (screenSize.width-26)/3.0;
}

@end
