//
//  HTTPClient.h
//  moshTickets
//
//  Created by 魔时网 on 13-11-14.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerRequest.h"   
#import "CacheHanding.h"
#import "UIImageView+AFNetworking.h"

#import "Activity.h"
#import "Ticket.h"
#import "UserInfo.h"    

@interface HTTPClient : NSObject

@property (nonatomic, strong) ServerRequest *request;

/*
 单例
 */
+ (HTTPClient *) shareHTTPClient;

/*
 登录
 name 用化名
 password 密码
 */
- (void) loginWithUserName:(NSString *)userName
                  password:(NSString *)password
                   success:(void (^)(id jsonData))success
                      fail:(void (^)(void))fail;
//下载票数据(单活动)
- (void) getAllTicketSuccess:(void (^)(NSMutableArray *tickets,Activity *act))success
                        fail:(void(^)(Activity *act))fail;

/*
 上传本地验票结果
 */

- (void) uploadTicketsWithDic:(NSDictionary *)dic
                    Sucess:(void (^)(NSString *str))sucess
                         fail:(void(^)(void))fail;

/*
 账号概览
 */
- (void) mainStatisticssuccess:(void (^)(UserInfo *info))success
                          fail:(void (^)(void))fail;

//下载票数据（多活动）
- (void) getAllTicketsWithEid:(NSString *)eid
                     username:(NSString *)username
                     password:(NSString *)password
                      success:(void (^)(Activity *act))success;

+ (void) removeLastDownloadDateWithEid:(NSString *)eid;

@end