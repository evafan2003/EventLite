//
//  TicketType.m
//  moshTickets
//
//  Created by 魔时网 on 14-2-19.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "TicketType.h"
#import "GlobalConfig.h"

@implementation TicketType

+ (TicketType *) ticketType:(NSDictionary *)dic
{
    TicketType *t = [[TicketType alloc]  init];
    t.tTypeID = [GlobalConfig convertToString:dic[@"tid"]];
    t.tTypeName = [GlobalConfig convertToString:dic[@"ticket_name"]];
    t.number = [GlobalConfig convertToString:dic[@"ticket_num"]];
    t.eventName = [GlobalConfig convertToString:dic[@"event"]];
    return t;
}

@end
