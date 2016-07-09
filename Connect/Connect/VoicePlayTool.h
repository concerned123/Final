//
//  VoicePlayTool.h
//  IM
//
//  Created by 徐杨 on 16/7/7.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoicePlayTool : NSObject


- (void)playVoiceWithPath:(NSString *)path onView:(UILabel *)view andDuration:(NSInteger)duration;

@end
