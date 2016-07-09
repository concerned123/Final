//
//  AppDelegate.m
//  Connect
//
//  Created by 胡凡 on 16/7/1.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[UINavigationBar appearance]setBarTintColor:[UIColor colorWithRed:146/255.0 green:214/155.0 blue:125/255.0 alpha:0.8]];
    //[[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    
    //1111.registerSDKWithAppKey: 注册的AppKey，详细见下面注释。
    //apnsCertName: 推送证书名（不需要加后缀），详细见下面注释。
    //初始化并且隐藏日
    EMOptions *options = [EMOptions optionsWithAppkey:@"xuyang767660732#lslt"];
    
    options.apnsCertName = @"hufan";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    if([EMClient sharedClient].options.isAutoLogin)
    {
    self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController ;
    }
    
    return YES;
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}




- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
