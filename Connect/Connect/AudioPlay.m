//
//  AudioPlay.m
//  Connect
//
//  Created by 胡凡 on 16/7/8.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "AudioPlay.h"

static UIImageView *annimationImageView;

@implementation AudioPlay

+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLable receover:(BOOL)recevie
{
    //当进入的时候直接移除动画
    
    [annimationImageView stopAnimating];
    [annimationImageView removeFromSuperview];
    //播放语音
   EMVoiceMessageBody *voiceBody =(EMVoiceMessageBody *)msg.body;
    NSString *path  = voiceBody.localPath;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:path]) {
        path = voiceBody.remotePath;
    }
    
    [[EMCDDeviceManager sharedInstance]asyncPlayingWithPath:path completion:^(NSError *error) {
        [annimationImageView stopAnimating];
        [annimationImageView removeFromSuperview];
        NSLog(@"语音播放完毕");
    }];
    
    //添加ImageVIew
    UIImageView *imageView = [[UIImageView alloc]init];
    
    [msgLable addSubview:imageView];
    
    //添加动画的图片
    //判断是否是接受方的图片
    if(recevie)
    {
    imageView.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                  [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                  [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                  [UIImage imageNamed:@"chat_receiver_audio_playing003"]];
        imageView.frame = CGRectMake(0, 0, 30, 30);
    }
    else
    {
        imageView.animationImages = @[[UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                      [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                      [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                      [UIImage imageNamed:@"chat_sender_audio_playing_003"]];
        imageView.frame = CGRectMake(msgLable.bounds.size.width-30, 0, 30, 30);
    }
    
    imageView.animationDuration =1;
    annimationImageView = imageView;
    [imageView startAnimating];
}

@end
