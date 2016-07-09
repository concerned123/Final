//
//  LoginViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/4.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *passWord;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


//注册
- (IBAction)Register:(id)sender
{
    NSString *userName = self.userName.text;
    NSString *passWord = self.passWord.text;
    
    if (userName.length ==0 ||passWord.length == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"账号和密码要写完！" preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
    //注册的按钮
    EMError *error = [[EMClient sharedClient] registerWithUsername:userName password:passWord];
    if (error==nil)
    {
        // 弹窗表示登录成功。
        //初始化提示框；
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"提交注册成功" preferredStyle:  UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        [self.userName resignFirstResponder];
        [self.passWord resignFirstResponder];
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    }
}


- (IBAction)Login:(id)sender
{
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
    
    
    NSString *userName = self.userName.text;
    NSString *passWord = self.passWord.text;
    
    if (userName.length ==0 ||passWord.length == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"施主您还是先注册吧！" preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //点击按钮的响应事件；
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
    }
    
    
    EMError *error = [[EMClient sharedClient] loginWithUsername:userName password:passWord];
    if (!error)
    {
       //打开自动登录
        [[EMClient sharedClient].options setIsAutoLogin:YES];
        
         //此时登录成功 跳转到主窗口
        self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController ;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder]; 
    return YES;
}

@end
