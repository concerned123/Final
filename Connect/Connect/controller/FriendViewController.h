//
//  FriendViewController.h
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "BaseViewController.h"

@protocol ToNext <NSObject>

-(void)tureToNextViewController:(BaseViewController *)controller;

@end

@interface FriendViewController : BaseViewController

@property(nonatomic,weak)id<ToNext>delegate;

@end
