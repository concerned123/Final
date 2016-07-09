//
//  DTModel.h
//  IM
//
//  Created by 徐杨 on 16/7/6.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTModel : NSObject

//消息队列
@property (nonatomic,strong) NSMutableArray<EMMessage *> *messageArray;

@end
