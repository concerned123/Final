//
//  addFriendViewController.m
//  Connect
//
//  Created by 胡凡 on 16/7/5.
//  Copyright © 2016年 胡凡. All rights reserved.
//

#import "addFriendViewController.h"

@interface addFriendViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation addFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//好友的添加按钮
- (IBAction)addBuddy:(UIButton *)sender
{
    //验证用户名是否是空
    if(self.textField.text.length==0)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"对不起" message:@"输入为空" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *Action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:Action];
        [self presentViewController:alertController animated:true completion:nil];
    }
    
    else{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"朋友" message:@"请表明身份" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
       
        printf("按钮点击\n");
        
        [self buttonAdd:alertController.textFields.firstObject.text];
        
     
        
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
      
        textField.placeholder = @"说说您的请求";
    }];
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:addAction];
    
    [self presentViewController:alertController animated:true completion:nil];
    }
    
}


-(void)buttonAdd:(NSString *)str;
{
    
    EMError *error = [[EMClient sharedClient].contactManager addContact:self.textField.text message:str];
    if (!error) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"恭喜" message:@"请求发送成功" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *Action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:Action];
        
        [self presentViewController:alertController animated:true completion:nil];
    }else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"对不起" message:@"请求发送失败" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *Action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:Action];
        [self presentViewController:alertController animated:true completion:nil];
    }
    
}

-(void)buttonCancle
{
    //取消按按钮
}

#pragma mark 输入框代理
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    [self.textField resignFirstResponder];
    return YES;
    
}

@end
