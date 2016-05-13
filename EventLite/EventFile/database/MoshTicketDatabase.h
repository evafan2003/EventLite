//
//  MoshTicketDatabase.h
//  MoshTicket
//
//  Created by evafan2003 on 12-6-27.
//  Copyright (c) 2012年 bbdtek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ticket.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "Activity.h"

#define DB_NAME @"Ticket.db"
#define TABLE_TICKET @"tickets"
#define TABLE_MEMBER @"members"

#define TABLE_AUTH @"accunt"
#define TABLE_NAME @"ticket_name"

#define OLD_TICKET @"ticket"

#define DATABASE_INSTANCE [MoshTicketDatabase sharedInstance]


@interface MoshTicketDatabase : NSObject {

    FMDatabase *db;
    FMDatabaseQueue *dbQueue;
     
}

+ (MoshTicketDatabase *)sharedInstance;

/**
 *  删除表
 *
 *  @param tableName 表名
 */
- (void) dropTable:(NSString *)tableName;


/**
 *  从表中取出该列中唯一不同的值
 *
 *  @param columnName 列名
 *  @param tableName  表名
 */
- (NSMutableArray *) selectDistinctColumn:(NSString *)columnName fromTable:(NSString *)tableName;





/**
 *  验票账户相关操作
 *
 *  @param columnName 列名
 */

//添加一个账户
- (BOOL) addAccunt:(NSString *)auth pass:(NSString *)pass title:(NSString *)title eid:(NSString *)eid startDate:(NSString *)startDate endDate:(NSString *)endDate type:(NSInteger)type;


//删除账户及相关票数据
- (void) removeAccuntWhereEid:(NSString *)eid type:(NSInteger)type;

//获取账户列表
//@{@"eid":eid,@"title":@"标题",@"totalCount":@"123",@"usedCount":@"123",@"unSyncCount":@"123"}
- (NSMutableArray *) getAccuntList;


/**
 *  票种相关操作
 * ticketType
 *wosha
 */
//添加票种
- (void) addTicketNameWithEid:(NSString *)eid tickets:(NSMutableArray *)ticketArr;

//取单一账户所有票种
//@{@"tid":@"123",@"ticket_title":@"标题"}
- (NSMutableArray *) getTicketListWhereEid:(NSString *)eid eventTitle:(NSString *)title;


//票操作-------------------------------------------------------------------------------------------

//插入数据库
-(void) insertTickets:(NSArray *)array;

//查找一条票
-(Ticket *)getOneTicket:(NSString *)t_password eid:(NSString *)eid ticketID:(NSString *)ticketID;

//取票数量
-(int) getAllTicketCountByEid:(NSString *)eid status:(NSString *)status ticketID:(NSString *)ticketID;

//取一个活动某些票种的所有票
-(NSMutableArray *) getAllTicketByEid:(NSString *)eid status:(NSString *)status ticketID:(NSString *)ticketID;

//取一个订单所有票
- (NSArray *) searchAllOrderTicketsWithEid:(NSString *)eid oid:(NSString *)oid ticketID:(NSString *)ticketID;

//取未提交服务器的所有票
-(NSMutableArray *) getAllUnpostTickets:(NSString *)tableName;
-(NSMutableArray *) getAllUnpostTicketsByEid:(NSString *)eid;

//搜票
-(NSMutableArray *) searchTicket:(NSString *)passwordOrTel eid:(NSString *)eid ticketID:(NSString *)ticketID;

//删除
-(void) deleteOneTickt:(NSString *)t_id;
-(void) deleteAllTicketWitheid:(NSString *)eid;
//大杀器！注意！
-(void) deleteAllTicket;

//需增加或修改
- (NSString *) getTicketsCountWithEid:(NSString *)eid;
- (NSString *) getTicketsCountWithEid:(NSString *)eid ticketState:(NSString *)state;
- (NSString *) getTicketsCountWithEid:(NSString *)eid synaState:(NSString *)state;
- (Activity *) getAccuntWithEid:(NSString *)eid;
- (NSString *) getTicketsCountWithTicketTypeID:(NSString *)tid ticketState:(NSString *)state;
- (NSString *) getEventWithTicketId:(NSString *)tid;


/*
 更改票信息
 state 票状态
 ispost 是否同步
 usedate 使用日期
 */
-(void) updateTicket:(Ticket *)ticket state:(NSString *)state useDate:(NSString *)usedate;

- (void) updateTicket:(Ticket *)ticket isPost:(NSString *)ispost;

//验票(0.未使用 1.待上传 2.已使用)
-(void) UpdateTikcet:(NSString *)t_id status:(NSString *)status;


/*
 票种搜素
 keyword
 */
- (NSMutableArray *) searchTicketClass:(NSString *)keyWord eid:(NSString *)eid;
@end
