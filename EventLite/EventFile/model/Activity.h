//
//  Activity.h
//  moshTickets
//
//  Created by 魔时网 on 13-11-18.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketType.h"
#import "BaseModel.h"
@interface Activity : BaseModel

@property (nonatomic, strong) NSString *eid;
@property (nonatomic, strong) NSString *imageUrl;//图片url
@property (nonatomic, strong) NSString *title;//标题
@property (nonatomic, strong) NSString *startDate;//开始时间
@property (nonatomic, strong) NSString *endDate;//结束时间
@property (nonatomic, strong) NSString *status;//状态
@property (nonatomic, strong) NSString *oid;//订单
@property (nonatomic, strong) NSString *address;//地址
@property (nonatomic, strong) NSString *auth;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *totalCount;
@property (nonatomic, strong) NSString *usedCount;
@property (nonatomic, strong) NSString *unSyncCount;
@property (nonatomic, assign) NSInteger type;//0单活动，1多活动

@property (nonatomic, strong) NSMutableArray   *tickedTypeArray;//票种

+ (Activity *) activity:(NSDictionary *)dic;


@end
