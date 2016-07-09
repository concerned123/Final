//
//  BaseViewController.h
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController



/**
 *  创建导航栏的按钮，选择左右，并且指定icon 或者基本文字

 *  @param isLeft  真或假
 *  @param target   target
 *  @param action  添加事件
 *  @param IsImage 是否是图片或者文字
 *  @param name    他们的名字
 */
-(void)addNavItemButtonWithLeft:(BOOL)isLeft  target:(id)target action:(SEL)action IsImageOrText:(BOOL)IsImage ImageNameOrText:(NSString *)name;

/**
 *  顶级父类的创建界面的多态函数
 */
-(void)CreatUI;

/**
 *  放回上一个界面
 */
-(void)backToLastController;


//  添加segment管理的两个界面
- (void)addSegmentWithController:(UIViewController *)controller1
                       WithTitle:(NSString *)title1
                   andController:(UIViewController *)controller2
                       WithTitle:(NSString *)title2;
@end
