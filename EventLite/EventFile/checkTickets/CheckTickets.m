//
//  CheckTickets.m
//  moshTickets
//
//  Created by 魔时网 on 14-2-10.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "CheckTickets.h"
#import "MoshTicketDatabase.h"
#import "ServerManger.h"
#import "AppDelegate.h"

@implementation CheckTickets

+ (void) checkTicket:(Ticket *)ticket
{
    if (!ticket) {
        return;
    }
    
    if ([ticket.t_state isEqualToString:ticketState_unUse]) {
        
        ticket.use_date = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        //1.更新数据库
        [[MoshTicketDatabase sharedInstance] updateTicket:ticket isPost:ticketUpdte_no];
        [[MoshTicketDatabase sharedInstance] updateTicket:ticket state:ticketState_isUsed useDate:ticket.use_date];
    
    
        //2.发消息
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_TICKET_USEDUPDATE object:nil userInfo:@{@"eid":ticket.eid,@"ticketID":ticket.t_id}];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_TICKET_SYNCUPDATE object:nil userInfo:@{@"eid":ticket.eid,@"ticketID":ticket.t_id}];
    
        //3.把ticket交给上传类
        [[ServerManger shareServerManger] updateTicket:ticket];
    
        //打印
        [CheckTickets printTicket:ticket];
    }
    
}

+ (void) cancheCheckTicket:(Ticket *)ticket
{
    //1.更新数据库
    [[MoshTicketDatabase sharedInstance] updateTicket:ticket isPost:ticketUpdte_no];
    [[MoshTicketDatabase sharedInstance] updateTicket:ticket state:ticketState_unUse useDate:@"0"];
    
    //    2.发消息
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_TICKET_UNUSEDUPDATE object:ticket];
    
    //    3.把ticket交给上传类
    
}

+ (void) printTicket:(Ticket *)ticket
{
    //打印
    BlueToothCenter *center = PROJECT_BLUETOOTHCENTER;
    [center printTicket:ticket];
}

@end
