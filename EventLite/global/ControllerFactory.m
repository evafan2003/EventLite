//
//  ControllerFactory.m
//  moshTicket
//
//  Created by 魔时网 on 13-11-13.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import "ControllerFactory.h"

@implementation ControllerFactory

+ (UIViewController *) loginInViewController
{
    return [LoginViewController viewControllerWithNib];
}                                                                                           

+ (UIViewController *) loginHelpViewController
{
    return [LoginHelpViewController viewControllerWithNib];
}

//+(UIViewController *) controllerWithLoginSuccess
//{
//    return [UserInfoViewController viewControllerWithNib];
//}

+ (UIViewController *) webViewControllerWithTitle:(NSString *)title Url:(NSString *)url
{
    return [[WebViewController  alloc] initWithTitle:title URL:[NSURL URLWithString:url]];
}

+ (UIViewController *) controllerWithName:(NSString *)name xib:(BOOL)xib
{
    return [[NSClassFromString(name) alloc] initWithNibName:xib?name:nil bundle:nil];
}

+ (UIViewController *) controllerWithName:(NSString *)name
{
    return [ControllerFactory controllerWithName:name xib:NO];
}
@end
