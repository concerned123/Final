//
//  Segment.m
//  Connect
//
//  Created by 胡凡 on 16/7/5.
//  Copyright © 2016年 胡凡. All rights reserved.
//
/**
 *  自定义的segment
 *
 *
 */
#import "Segment.h"

#define Width [[UIScreen mainScreen]bounds].size.width
#define Height [[UIScreen mainScreen]bounds].size.height
#define Tag_Value 100

@interface Segment (){
    UIView * _slider;
    id _target;
    SEL _action;
}

//  存放传入的items
@property (nonatomic, strong) NSMutableArray * items;

@end

@implementation Segment

- (NSMutableArray *)items {
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (instancetype)initWithItems:(NSArray *)items {
    if (self = [super init]) {
        //  初始化所有的属性
        [self myinit];
        _items = [items mutableCopy];
    }
    return self;
}
- (void) myinit {
    //_items = [NSMutableArray array];
    _unselctedColor = [UIColor blackColor];
    _selectedColor = [UIColor redColor];
    
    //  添加滑块
    _slider = [[UIView alloc] init];
    [self addSubview:_slider];
}

- (void) creatButton {
    //  根据传入的items的个数来创建对应的button
    for (int i = 0; i < self.items.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:self.items[i] forState:UIControlStateNormal];
        //  设置颜色
        [button setTitleColor:_unselctedColor forState:UIControlStateNormal];
        [button setTitleColor:_selectedColor forState:UIControlStateSelected];
        
        //  设置位置
        CGFloat buttonX = i * self.frame.size.width / self.items.count;
        CGFloat buttonY = 0;
        CGFloat buttonW = self.frame.size.width / self.items.count;
        CGFloat buttonH = self.frame.size.height;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        //  添加button点击事件
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchDown];
        button.tag = i + Tag_Value;
        button.titleLabel.font = [UIFont systemFontOfSize:17.0];
        if (_selectedSegmentIndex == i) {
            button.selected = YES;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        }
        [self addSubview:button];
    }
}

- (void)layoutSubviews {
    [self creatButton];
    
    CGFloat sliderW = self.frame.size.width / self.items.count;
    CGFloat sliderH = 3;
    CGFloat sliderX = self.selectedSegmentIndex * sliderW;
    CGFloat sliderY = self.frame.size.height - sliderH;
    _slider.frame = CGRectMake(sliderX, sliderY, sliderW, sliderH);
    _slider.backgroundColor = [UIColor yellowColor];
    
}

- (void) buttonClick:(UIButton *)button {
    
    UIButton * btn = (UIButton *)[self viewWithTag:_selectedSegmentIndex + Tag_Value];
    btn.selected = NO;
    btn.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.3 animations:^{
        btn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    }];
    btn.titleLabel.font = [UIFont systemFontOfSize:17.0];
    _selectedSegmentIndex = button.tag - Tag_Value;
    
    
    button.selected = YES;
    
    button.userInteractionEnabled = NO;
    //  改变滑块的位置
    [UIView animateWithDuration:0.3 animations:^{
        _slider.frame = CGRectMake(button.frame.origin.x, _slider.frame.origin.y, _slider.frame.size.width, _slider.frame.size.height);
        //  对应的字放大
        button.titleLabel.font = [UIFont systemFontOfSize:20];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    }];
    
    //  实现点击的方法
    if ([_target respondsToSelector:_action]) {
        [_target performSelector:_action withObject:self];
    }
}
- (void)changeIndex:(NSInteger)index {
    UIButton * button = (UIButton *)[self viewWithTag:index + Tag_Value];
    [self buttonClick:button];
}

//  点击事件
- (void) addTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}


@end
