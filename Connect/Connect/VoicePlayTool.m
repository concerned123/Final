//
//  VoicePlayTool.m
//  IM
//
//  Created by 徐杨 on 16/7/7.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import "VoicePlayTool.h"

@interface VoicePlayTool()
{
    NSString *voicePath;        //文件播放路径
    UILabel *voiceView;              //播放文本
    NSInteger voiceDuration;        //音频时长
}

//播放录音的动画
@property (nonatomic,strong) UIImageView *imgView;

@end

@implementation VoicePlayTool

static VoicePlayTool *singleTool;

- (instancetype)init
{
    if (!singleTool) {
        self = [super init];
        singleTool = self;
    }
    return singleTool;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        //创建一个动画
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [_imgView setAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing000"],[UIImage imageNamed:@"chat_receiver_audio_playing001"],[UIImage imageNamed:@"chat_receiver_audio_playing002"],[UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
        [_imgView setAnimationDuration:0.7f];
    }
    return _imgView;
}

- (void)playVoiceWithPath:(NSString *)path onView:(UILabel *)view andDuration:(NSInteger)duration
{
        //如果正在播放，就停止之前的播放，开始现在的播放
        if ([self.imgView isAnimating]) {
            [self stopPlaying:voiceView duration:voiceDuration];
        }
        [self startPlaying:view duration:duration path:path];
}

#pragma mark - 停止播放
- (void)stopPlaying:(UILabel *)view duration:(NSInteger)duration
{
    //重新设置富文本
    [view setAttributedText:[self getAttributeString:duration isPlaying:NO]];
    //停止动画
    [self.imgView stopAnimating];
    //从视图中移除
    [self.imgView removeFromSuperview];
    //停止播放
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    NSLog(@"已停止播放");
}

#pragma mark - 开始播放
- (void)startPlaying:(UILabel *)view duration:(NSInteger)duration  path:(NSString *)path
{
    //先判断文件是否存在
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        //设置当前音频播放路径
        voicePath = path;
        //设置当前音频播放label
        voiceView = view;
        //设置音频时长
        voiceDuration = duration;
        //开始动画效果
        [view setAttributedText:[self getAttributeString:duration isPlaying:YES]];
        [view addSubview:self.imgView];
        CGPoint center = self.imgView.center;
        center.y = view.bounds.size.height/2.0;
        [self.imgView setCenter:center];
        [self.imgView startAnimating];
        //开始播放
        [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
            NSLog(@"语音播放完成");
            //重新设置富文本
            [view setAttributedText:[self getAttributeString:duration isPlaying:NO]];
            //停止动画
            [self.imgView stopAnimating];
            //从视图中移除
            [self.imgView removeFromSuperview];
        }];
    }else{
        NSLog(@"文件不存在");
    }
}

- (NSAttributedString *)getAttributeString:(NSInteger)aDuration isPlaying:(BOOL)isPlaying
{
    NSMutableAttributedString *voiceAttr = [[NSMutableAttributedString alloc] init];
    
    //添加图片
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    if (!isPlaying) {
        //如果不在播放时，才开始显示图片
        attach.image = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    }
    [attach setBounds:CGRectMake(0, -5, 20, 20)];
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
    [voiceAttr appendAttributedString:imageAttr];
    //添加文字
    NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld'",aDuration] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [voiceAttr appendAttributedString:textAttr];
    
    //添加提示文字
    NSAttributedString *promptAttr = [[NSAttributedString alloc] initWithString:@"  [点击播放]"];
    [voiceAttr appendAttributedString:promptAttr];
    
    return voiceAttr;
}

@end
