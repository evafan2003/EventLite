//
//  TicketType.h
//  moshTickets
//
//  Created by 魔时网 on 14-2-19.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TicketType : NSObject

@property (nonatomic, strong) NSString *tTypeID;
@property (nonatomic, strong) NSString *tTypeName;
@property (nonatomic, strong) NSString *number;
@property (nonatomic ,strong) NSString *price;

@property (nonatomic ,strong) NSString *eventName;
@property (nonatomic ,strong) NSString *eid;
+ (TicketType *) ticketType:(NSDictionary *)dic;

@end
