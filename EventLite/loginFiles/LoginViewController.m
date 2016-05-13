//
//  LoginViewController.m
//  moshTicket
//
//  Created by 魔时网 on 13-11-12.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import "LoginViewController.h"
#import "ControllerFactory.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //创建导航按钮
    [self createBarWithLeftBarItem:MoshNavigationBarItemNone rightBarItem:MoshNavigationBarItemNone title:NAVTITLE_LOGIN];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {

    if (![GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.userName.text Alert:ERROR_USERNAME]) {
        return;
    }
    if (![GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.password.text Alert:ERROR_PASSWORD]) {
        return;
    }
    
    [self showLoadingView];
    [[HTTPClient shareHTTPClient] loginWithUserName:self.userName.text
                                           password:self.password.text
                                            success:^(id json){
//                                                [self hideLoadingView];
                                                
                                                [self requestSuccess:json];
                                               
    }
                                               fail:^{
                                                   
                                                   [self hideLoadingView];
                                                   [GlobalConfig showAlertViewWithMessage:ERROR superView:self.view];
    }];
}


- (IBAction)urlButtonPress:(id)sender {
    [self.navigationController pushViewController:[ControllerFactory webViewControllerWithTitle:NAVTITLE_ACTIVITYLIST Url:@"http://www.evente.cn"] animated:YES];
}

- (IBAction)getUsernameAndPassword:(id)sender {
    [self presentViewController:[ControllerFactory loginHelpViewController] animated:YES completion:^{}];
}

- (IBAction)phoneButtonPress:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"拨打电话" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"400-063-0260" otherButtonTitles:nil];
    [sheet showInView:self.view];
}

- (void) requestSuccess:(id)json
{
    if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:json]) {
        NSString *eid = json[JSONKEY_KEY];
        if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:eid] && ![eid isEqualToString:@"n"]) {
            //加载票数据
            [GlobalConfig saveUserInfoWithEid:eid userName:self.userName.text passWord:self.password.text];
            [self requestTicketsWithEid:eid];
            
        }
        else {
            [self hideLoadingView];
            [GlobalConfig showAlertViewWithMessage:ERROR_LOGINFAIL superView:self.view];
        }
    }
    else {
        [self hideLoadingView];
        [GlobalConfig showAlertViewWithMessage:ERROR_LOGINFAIL superView:self.view];
    }
}

- (void) requestTicketsWithEid:(NSString *)eid
{
    
    self.loadingView.labelText = @"下载票数据...";
    [[HTTPClient shareHTTPClient] getAllTicketsWithEid:eid username:self.userName.text password:self.password.text success:^(Activity *act){
        if (!act) {
            [self hideLoadingView];
            [GlobalConfig showAlertViewWithMessage:@"下载票数据错误，请重新添加" superView:self.view];
        }
        else {
            NOTICENTER_POST(NOTI_EVENTUPDATE);
            [self dismissViewControllerAnimated:YES completion:^{[self hideLoadingView];}];
        }
    }];
    
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userName resignFirstResponder];
    [self.password resignFirstResponder];
}

#pragma mark uitextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userName) {
        [self.userName resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (textField == self.password) {
        [self.password resignFirstResponder];
        [self login:nil];
    }
    return YES;
}

#pragma mark actionSheetDelegate -
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [GlobalConfig makeCall:@"4000630260"];
    }
}

@end
