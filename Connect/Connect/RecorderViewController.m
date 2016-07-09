//
//  RecorderViewController.m
//  IM
//
//  Created by 徐杨 on 16/7/7.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import "RecorderViewController.h"

@interface RecorderViewController ()

{
    BOOL isPlay;        //是否可以播放
}

@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
//录音过程中的动画
@property (nonatomic,strong) UIImageView *recordAnimation;

//播放录音的动画
@property (nonatomic,strong) UIImageView *imgView;
@end

@implementation RecorderViewController

- (UIImageView *)recordAnimation
{
    if (!_recordAnimation) {
        _recordAnimation = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2.0, CGRectGetMinY(self.recordBtn.frame) - 120, 100, 100)];
        NSMutableArray *imagesArray = [NSMutableArray array];
        for (int i=0; i<16; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"VoiceSearchFeedback%03d",i+1]];
            [imagesArray addObject:image];
        }
        for (int i=16; i>0; i--) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"VoiceSearchFeedback%03d",i]];
            [imagesArray addObject:image];
        }
        [_recordAnimation setAnimationImages:imagesArray];
        [_recordAnimation setAnimationRepeatCount:0];
        [_recordAnimation setAnimationDuration:0.6f];
    }
    return _recordAnimation;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    isPlay = NO;
    //给文本添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.voiceLabel setUserInteractionEnabled:YES];
    [self.voiceLabel addGestureRecognizer:tap];
}

#pragma mark - 按钮录音按钮
- (IBAction)touchDown:(UIButton *)sender {
    //录音的文件名以时间命名
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音成功");
            //开始播放动画
            [self.view addSubview:self.recordAnimation];
            [self.recordAnimation startAnimating];
        }else{
            NSLog(@"开始录音失败");
        }
    }];
}

#pragma mark - 松开按钮，结束录音
- (IBAction)touchUp:(UIButton *)sender {
    //判断是否正在录音，如果正在录音，则停止录音
    if ([[EMCDDeviceManager sharedInstance] isRecording]) {
        NSLog(@"开始停止录音");
        [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            if (!error) {
                NSLog(@"录音成功");
                NSLog(@"%@",recordPath);
                NSLog(@"%li",aDuration);
                _recordFilePath = recordPath;
                _recordDuration = aDuration;
                //录音成功之后，才在页面显示语音
                [self showVoiceWithDuration:aDuration];
            }else{
                NSLog(@"录音失败");
            }
            //停止动画
            [self.recordAnimation stopAnimating];
            [self.recordAnimation removeFromSuperview];
            
        }];
    }
    
    
}

#pragma mark - 在按钮以外的地方，取消录音
- (IBAction)touchOut:(UIButton *)sender {
    //正在录音的情况下，才停止录音
    if ([[EMCDDeviceManager sharedInstance] isRecording]) {
        [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    }
    
    
}

#pragma mark - 显示语音
- (void)showVoiceWithDuration:(NSInteger)aDuration
{
    NSMutableAttributedString *voiceAttr = [[NSMutableAttributedString alloc] init];
    
    //添加图片
    NSTextAttachment *attach = [[NSTextAttachment alloc] init];
    attach.image = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    [attach setBounds:CGRectMake(0, -7, 30, 30)];
    NSAttributedString *imageAttr = [NSAttributedString attributedStringWithAttachment:attach];
    [voiceAttr appendAttributedString:imageAttr];
    //添加文字
    NSAttributedString *textAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld'",aDuration] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [voiceAttr appendAttributedString:textAttr];
    
    //添加提示文字
    NSAttributedString *promptAttr = [[NSAttributedString alloc] initWithString:@"  点击播放" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    [voiceAttr appendAttributedString:promptAttr];
    
    //设置富文本
    [self.voiceLabel setAttributedText:voiceAttr];
    //设置属性为可播放状态
    isPlay = YES;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        //创建一个动画
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_imgView setAnimationImages:@[[UIImage imageNamed:@"chat_receiver_audio_playing000"],[UIImage imageNamed:@"chat_receiver_audio_playing001"],[UIImage imageNamed:@"chat_receiver_audio_playing002"],[UIImage imageNamed:@"chat_receiver_audio_playing003"]]];
        [_imgView setAnimationDuration:0.7f];
    }
    return _imgView;
}

#pragma mark - 轻点手势
- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    if (isPlay) {
        if ([self.imgView isAnimating]) {
            //结束动画，把之前正在播放的动画移除
            [self.imgView stopAnimating];
            //从父视图中移除
            [self.imgView removeFromSuperview];
        }
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:_recordFilePath]) {
            //放到label上
            [self.voiceLabel addSubview:self.imgView];
            //开始动画
            [self.imgView startAnimating];
            
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:_recordFilePath completion:^(NSError *error) {
                NSLog(@"语音播放完成");
                //结束动画
                [self.imgView stopAnimating];
                //从父视图中移除
                [self.imgView removeFromSuperview];
            }];
        }else{
            NSLog(@"录音文件不存在");
        }
  
    }
    
}

@end
