//
//  ControllerFactory.h
//  moshTicket
//
//  Created by 魔时网 on 13-11-13.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalConfig.h"
#import "HTTPClient.h"

#import "LoginViewController.h"
#import "BaseNavigationController.h"
#import "WebViewController.h"
#import "LoginHelpViewController.h"
#import "UserInfoViewController.h"

@interface ControllerFactory : NSObject

//登录成功 进入活动列表
//+(UIViewController *) controllerWithLoginSuccess;

//登录页面的Controller
+ (UIViewController *) loginInViewController;

//获取用户名和密码页面的Controller
+ (UIViewController *) loginHelpViewController;

//网页
+ (UIViewController *) webViewControllerWithTitle:(NSString *)title Url:(NSString *)url;

+ (UIViewController *) controllerWithName:(NSString *)name;
+ (UIViewController *) controllerWithName:(NSString *)name xib:(BOOL)xib;
@end
