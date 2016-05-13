//
//  AppDelegate.h
//  EventLite
//
//  Created by 魔时网 on 14-3-17.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPClient.h"
#import "ServerManger.h"
#import "MoshTicketDatabase.h"
#import "BaseNavigationController.h"
#import "BlueToothCenter.h"
#import "HomeVC.h"  

#define Project_AppDelegate  ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#define   PROJECT_BLUETOOTHCENTER (Project_AppDelegate.center)

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HTTPClient *client;
@property (strong, nonatomic) ServerManger *manger;
@property (strong, nonatomic) MoshTicketDatabase *database;
@property (strong, nonatomic) BlueToothCenter   *center;
@property (strong, nonatomic) HomeVC        *homeVC;

@end
