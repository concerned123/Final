//
//  RecorderViewController.h
//  IM
//
//  Created by 徐杨 on 16/7/7.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecorderViewController : UIViewController

/**
 *录音地址
 */
@property (nonatomic,strong) NSString *recordFilePath;
/**
 *  录音时间
 */
@property (nonatomic) NSInteger recordDuration;

//显示语音的label
@property (nonatomic,strong) IBOutlet UILabel *voiceLabel;

@end
