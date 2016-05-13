//
//  HTTPClient.m
//  moshTickets
//
//  Created by 魔时网 on 13-11-14.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import "HTTPClient.h"
#import "GlobalConfig.h"
#import "HomeVC.h"
#import "AppDelegate.h"     

#define LASTDATE    @"LastDate"

@implementation HTTPClient

+ (HTTPClient *) shareHTTPClient
{
    static HTTPClient *instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[HTTPClient alloc] init];
    });
    return instace;
}

- (id) init
{
    if (self = [super init]) {
        self.request = [ServerRequest serverRequest];
    }
    return self;
}

- (void) loginWithUserName:(NSString *)userName
                  password:(NSString *)password
                   success:(void (^)(id jsonData))success
                      fail:(void (^)(void))fail
{
    [_request beginRequestWithUrl:[NSString stringWithFormat:URL_LOGIN,userName,password]
                     isAppendHost:YES
                        isEncrypt:YES
                          success:success
                             fail:fail];
}

//下载票数据 （单一活动方法）
- (void) getAllTicketSuccess:(void (^)(NSMutableArray *tickets,Activity *act))success
                        fail:(void(^)(Activity *act))fail
{
    NSString *dateKey = [NSString stringWithFormat:@"ListDate%@",[GlobalConfig getObjectWithKey:USER_EID]];
    
    [_request beginRequestWithUrl:[NSString stringWithFormat:GET_ALL_LIST,[GlobalConfig getObjectWithKey:USER_USERNAME],[GlobalConfig getObjectWithKey:USER_PASSWORD],[[self getLastDownloadDateWithKey:dateKey] integerValue]]
                     isAppendHost:YES
                        isEncrypt:YES
                          success:^(id jsonData){
                              
        //下载成功组装数据
        if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:jsonData]) {
            NSString *eid = [GlobalConfig convertToString:jsonData[@"eid"]];
            NSArray *array = jsonData[@"list"];
             Activity *act = [self converToActivity:jsonData eid:eid];
            if ([array isKindOfClass:NSArrayClass]) {
                NSMutableArray *ticketsArray = [NSMutableArray array];
                for (NSDictionary *dic in array) {
                    Ticket *ticket = [Ticket ticket:dic eid:eid];
                    [ticketsArray addObject:ticket];
                }
                success(ticketsArray,act);
                
//                //记住时间
                [self saveLastDownloadDateWithKey:dateKey jsonData:jsonData];
            }
            else {
                 Activity *act = [self converToActivity:nil eid:eid];
                fail(act);
            }
        } else {
            Activity *act = [self converToActivity:nil eid:nil];
            fail(act);
        }
        
    } fail:^{
        Activity *act = [self converToActivity:nil eid:nil];
        fail(act);    }];
}

//转换成activityModel存入数组
- (Activity *) converToActivity:(NSDictionary *)dic eid:(NSString *)eid
{
    NSMutableDictionary *cacheDic = nil;
    Activity *act  = nil;
    if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:dic]) {
        cacheDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [cacheDic removeObjectForKey:@"list"];
    }

    if (![GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:eid]) {
        eid = [GlobalConfig getObjectWithKey:USER_EID];
    }
    
    NSDictionary *ticketsDic = [CacheHanding cacheWithDic:cacheDic path:[NSString stringWithFormat:CACHE_TICKETS,eid]];
    
    if (ticketsDic) {
        act = [Activity activity:ticketsDic];
    }
    else {
        [GlobalConfig showAlertViewWithMessage:ERROR_LOADINGFAIL superView:nil];
    }
    return act;
}

//上传本地验票结果
- (void) uploadTicketsWithDic:(NSDictionary *)dic
                       Sucess:(void (^)(NSString *str))sucess
                        fail:(void(^)(void))fail
{
    
    
    [_request postRequestWithUrl:[NSString stringWithFormat:UPLOAD,[GlobalConfig getObjectWithKey:USER_USERNAME],[GlobalConfig getObjectWithKey:USER_PASSWORD]]
                             dic:dic
                    isAppendHost:YES
                       isEncrypt:YES success:^(NSString *str){
                           sucess(str);
                       } fail:^{
                           fail();
                       }];
    
}

//得到最后一次加载时间
- (NSNumber *) getLastDownloadDateWithKey:(NSString *)key
{
    NSNumber *date = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (![date isKindOfClass:[NSNumber class]]) {
        date = @0;
    }
    return date;
}

//保存最后一次加载的时间
- (void) saveLastDownloadDateWithKey:(NSString *)dateKey jsonData:(id)jsonData
{
    NSNumber *number = [GlobalConfig convertToNumber:jsonData[@"time"]];
    [[NSUserDefaults standardUserDefaults] setObject:number forKey:dateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) removeLastDownloadDateWithEid:(NSString *)eid
{
    NSString *dateKey = [NSString stringWithFormat:@"%@%@",LASTDATE,[GlobalConfig convertToString:eid]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedLongLong:0] forKey:dateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];}

- (void) mainStatisticssuccess:(void (^)(UserInfo *info))success
                          fail:(void (^)(void))fail
{
    [_request beginRequestWithUrl:[NSString stringWithFormat:URL_USERINFO,[GlobalConfig getObjectWithKey:USER_USERNAME],[GlobalConfig getObjectWithKey:USER_PASSWORD]]
                     isAppendHost:YES
                        isEncrypt:YES
                          success:^(id json) {
                              if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:json]) {
                                  NSDictionary *dic = [CacheHanding parseDetailWithDic:json path:[NSString stringWithFormat:CACHE_MAINSTATISTICS,[GlobalConfig getObjectWithKey:USER_USERNAME]] key:JSONKEY];
                                  if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:dic]) {
                                      success([UserInfo userInfo:dic]);
                                  }
                                  else {
                                      NSDictionary *dic = [CacheHanding parseDetailWithDic:nil path:[NSString stringWithFormat:CACHE_MAINSTATISTICS,[GlobalConfig getObjectWithKey:USER_USERNAME]] key:JSONKEY];
                                      success([UserInfo userInfo:dic]);
                                      
                                  }
                                  
                              }
                              else {
                                  NSDictionary *dic = [CacheHanding parseDetailWithDic:nil path:[NSString stringWithFormat:CACHE_MAINSTATISTICS,[GlobalConfig getObjectWithKey:USER_USERNAME]] key:JSONKEY];
                                  success([UserInfo userInfo:dic]);
                              }
                              
                          }
                             fail:^{
                                 NSDictionary *dic = [CacheHanding parseDetailWithDic:nil path:[NSString stringWithFormat:CACHE_MAINSTATISTICS,[GlobalConfig getObjectWithKey:USER_USERNAME]] key:JSONKEY];
                                 success([UserInfo userInfo:dic]);
                             }];
}



//下载票数据（多活动）
- (void) getAllTicketsWithEid:(NSString *)eid
                     username:(NSString *)username
                     password:(NSString *)password
                      success:(void (^)(Activity *act))success
{
    NSString *dateKey = [NSString stringWithFormat:@"%@%@",LASTDATE,[GlobalConfig convertToString:eid]];
    
    [_request beginRequestWithUrl:[NSString stringWithFormat:GET_ALL_LIST,username,password,[[self getLastDownloadDateWithKey:dateKey] integerValue]]
                     isAppendHost:YES
                        isEncrypt:YES
                          success:^(id jsonData){
                              
                              //下载成功组装数据
                              if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:jsonData]) {
                                  
                                  HomeVC *homevc = Project_AppDelegate.homeVC;
                                  
                                    //活动并插入数据库
                                  Activity *act = [self converToActivity:jsonData eid:eid];
                                  [[MoshTicketDatabase sharedInstance] addAccunt:username pass:password title:act.title eid:act.eid startDate:act.startDate endDate:act.endDate type:homevc.type];
    
//                                  票种加入数据库
                                  [[MoshTicketDatabase sharedInstance] addTicketNameWithEid:eid tickets:act.tickedTypeArray];
                                  
                                  //加载票数据
                                    NSArray *array = jsonData[@"list"];
                                  if ([array isKindOfClass:NSArrayClass]) {
                                      NSMutableArray *ticketsArray = [NSMutableArray array];
                                      for (NSDictionary *dic in array) {
                                          Ticket *ticket = [Ticket ticket:dic eid:eid];
                                          [ticketsArray addObject:ticket];
                                      }
                                      [[MoshTicketDatabase sharedInstance] insertTickets:ticketsArray];
                                      
                                    //记住时间
                                      [self saveLastDownloadDateWithKey:dateKey jsonData:jsonData];
                                      
                                      success(act);
                                  }
                              }
                              else {
                              success(nil);
                              }
                          } fail:^{success(nil);}];
}




@end
