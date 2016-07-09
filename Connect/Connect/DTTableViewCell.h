//
//  DTTableViewCell.h
//  IM
//
//  Created by 徐杨 on 16/7/6.
//  Copyright © 2016年 xuyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTModel.h"

@protocol ImageViewDelegate <NSObject>

- (void)beginPickerImage:(NSArray *)imageArray andUrlArray:(NSArray *)urlArray andIndex:(int)index;

@end

@interface DTTableViewCell : UITableViewCell
//头像
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
//用户名
@property (weak, nonatomic) IBOutlet UILabel *username;
//发布时间
@property (weak, nonatomic) IBOutlet UILabel *timestamp;
//内容
@property (weak, nonatomic) IBOutlet UILabel *textContent;
//图片显示
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//分隔视图
@property (weak, nonatomic) IBOutlet UIImageView *splitView;

//代理
@property (nonatomic) id<ImageViewDelegate> delegate;

@property (nonatomic,strong) DTModel *model;

- (CGFloat)cellHeight;

@end
