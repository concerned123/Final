//
//  ChatTableViewCell.h
//  Connect
//
//  Created by 胡凡 on 16/7/6.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *IDre = @"receiveCell";
static NSString *IDse = @"sendCell";

@interface ChatTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *reciveLabel;
@property(nonatomic,strong)EMMessage *message;


-(CGFloat)cellHeight;
@end
