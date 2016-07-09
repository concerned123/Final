//
//  Segment.h
//  Connect
//
//  Created by 胡凡 on 16/7/5.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Segment : UIView
//  未选中时的颜色
@property (nonatomic, strong) UIColor * unselctedColor;
//  选中时的颜色
@property (nonatomic, strong) UIColor * selectedColor;
//  选择的下标
@property (nonatomic, assign) NSInteger selectedSegmentIndex;

- (instancetype) initWithItems:(NSArray *)items;


//  添加点击事件
- (void) addTarget:(id)target
            action:(SEL)action;

- (void) changeIndex:(NSInteger)index;

@end
