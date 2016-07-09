//
//  ChatTableViewCell.m
//  Connect
//
//  Created by 胡凡 on 16/7/6.
//  Copyright © 2016年 胡凡. All rights reserved.
//
//pull 版本
#import "ChatTableViewCell.h"
#import "AudioPlay.h"

@implementation ChatTableViewCell

-(void)awakeFromNib
{
    //初始化的工作
    //给label 添加敲击手势
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(messageLabelTap:)];
    [self.reciveLabel addGestureRecognizer:tag];
}
#pragma mark 点击label 的方法
-(void)messageLabelTap:(UITapGestureRecognizer *)recognizer
{
    //运行用户交互，当前类型是语音才开始播放
    //获取消息体
    id body =self.message.body;
    
    
    if ([body isKindOfClass:[EMVoiceMessageBody class]])
    {
        //现在才可以开始播放
        BOOL receiver = [self.reuseIdentifier isEqualToString:IDre];
        [AudioPlay playWithMessage:self.message msgLabel:self.reciveLabel receover:receiver];
    }
    
}


-(void)setMessage:(EMMessage *)message
{
    _message  = message;
    //获取消息体
    id body =message.body;
    
    
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody= body;
        
        self.reciveLabel.text = textBody.text;
    }
    
    else if([body isKindOfClass:[EMVoiceMessageBody class]])
    {
    
        self.reciveLabel.attributedText = [self voiceAtt];
    }
    else if([body isKindOfClass:[EMImageMessageBody class]])
    {
        
        [self showImage];
    }
    
    else
    {
        self.reciveLabel.text = @" 未知的类型";
    }
    
    
}

#pragma mark 显示图片

-(void)showImage
{
    //cell 添加imageView;,并且设置尺寸
    printf("图片");
    EMImageMessageBody *imageBody= (EMImageMessageBody *)self.message.body;
    //CGRect thunbnailFrm =(CGRect){0, 0, imageBody.thumbnailSize};
    CGRect thunbnailFrm =(CGRect){0, 0, imageBody.thumbnailSize.width,imageBody.thumbnailSize.width};
    
    NSTextAttachment *imgAttc = [[NSTextAttachment alloc]init];
    imgAttc.bounds = thunbnailFrm;
    
    NSAttributedString *imageAtt = [NSAttributedString attributedStringWithAttachment:imgAttc];
    self.reciveLabel.attributedText= imageAtt;
    self.reciveLabel.backgroundColor = [UIColor yellowColor];
    
    
    UIImageView *ChatImageView = [[UIImageView alloc]init];
    ChatImageView.backgroundColor = [UIColor redColor];
    [self.reciveLabel addSubview:ChatImageView];
    
    
    ChatImageView.frame = thunbnailFrm;
}

#pragma mark 返回语音的富文本

-(NSAttributedString *)voiceAtt
{
    
    NSMutableAttributedString *voiceAttM = [NSMutableAttributedString new];
    //接收方，图片 +文字
    if ([self.reuseIdentifier isEqualToString:IDre])
    {
        //1接受方的图片
        UIImage *receImage = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        //2创建图片的附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc]init];
        imgAttachment.image = receImage;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        
        //3创建图片富文本
        
        NSAttributedString *imaAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        //语音富文本
        [voiceAttM appendAttributedString:imaAtt];
        
        //时间的富文本
        
        //获取时间
        EMVoiceMessageBody *voiceBody =(EMVoiceMessageBody *)self.message.body;
        NSInteger duration = voiceBody.duration;
        
        NSString *timestr = [NSString stringWithFormat:@"%ld ' ",(long)duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc]initWithString:timestr];
        [voiceAttM appendAttributedString:timeAtt];
        
        //发送方。反之
        
    }
    //发送方。反之
    else
    {
        //2.1时间的富文本
        
        //获取时间
        EMVoiceMessageBody *voiceBody =(EMVoiceMessageBody *)self.message.body;
        NSInteger duration = voiceBody.duration;
        
        NSString *timestr = [NSString stringWithFormat:@"%ld '  ",(long)duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc]initWithString:timestr];
        [voiceAttM appendAttributedString:timeAtt];
        
        
        
        //2.2接受方的图片
        UIImage *receImage = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        //2创建图片的附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc]init];
        imgAttachment.image = receImage;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        
        //3创建图片富文本
        
        NSAttributedString *imaAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        //语音富文本
        [voiceAttM appendAttributedString:imaAtt];
        
        
        
    }
    return [voiceAttM copy];
}


-(CGFloat)cellHeight
{
    //重新布局子控件
    [self layoutIfNeeded];
    return 5+10+self.reciveLabel.bounds.size.height +10+5;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
