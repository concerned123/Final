//
//  AudioPlay.h
//  Connect
//
//  Created by 胡凡 on 16/7/8.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlay : NSObject

+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLable receover:(BOOL)recevie;

@end
