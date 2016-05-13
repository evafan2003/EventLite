//
//  AppDelegate.m
//  EventLite
//
//  Created by 魔时网 on 14-3-17.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "AppDelegate.h"
#import "ControllerFactory.h"

static NSString *dropTableKey = @"dropTable";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    //设置stateBar的字体颜色为亮色 前提在 infoplist 中 Set UIViewControllerBasedStatusBarAppearance to NO.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.client = [HTTPClient shareHTTPClient];
    self.center = [BlueToothCenter new];
    self.manger = [ServerManger shareServerManger];
    self.database = [MoshTicketDatabase sharedInstance];
    [_manger startNetNoti];
    [self updateWithServer];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:dropTableKey]) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self dropTableAtFirstLaunch];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:dropTableKey];
        });
    }
    self.homeVC = (HomeVC *)[ControllerFactory controllerWithName:@"HomeVC"];
        self.window.rootViewController = [[BaseNavigationController alloc] initWithRootViewController:self.homeVC];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    return YES;
}

//提交已验票数据
- (void) updateWithServer
{
    NSArray *array = [[MoshTicketDatabase sharedInstance] getAllUnpostTickets:TABLE_TICKET];
    if ([GlobalConfig isKindOfNSArrayClassAndCountGreaterThanZero:array]) {
        [[ServerManger shareServerManger] updateTickets:array];
    }
}

- (void) dropTableAtFirstLaunch
{
    NSArray *array = [[MoshTicketDatabase sharedInstance] getAllUnpostTickets:OLD_TICKET];
    if ([GlobalConfig isKindOfNSArrayClassAndCountGreaterThanZero:array]) {
        [[ServerManger shareServerManger] updateTickets:array];
    }
    
    static NSString *listData = @"ListDate";
    NSArray *eidArr = [[MoshTicketDatabase sharedInstance] selectDistinctColumn:@"eid" fromTable:OLD_TICKET];
    for (NSString *eid in eidArr) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[listData stringByAppendingString:eid]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[MoshTicketDatabase sharedInstance] dropTable:OLD_TICKET];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
