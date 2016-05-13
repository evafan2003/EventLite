//
//  MoshTicketDatabase.m
//  MoshTicket
//
//  Created by evafan2003 on 12-6-27.
//  Copyright (c) 2012年 bbdtek. All rights reserved.
//

#import "MoshTicketDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Ticket.h"
#import "GlobalConfig.h"
#import "NSString+Encryption.h"
#import "TicketType.h"

static MoshTicketDatabase *moshTicketDatabase = nil;

@implementation MoshTicketDatabase

+(MoshTicketDatabase *) sharedInstance {
    
    if (!moshTicketDatabase) {
        
        moshTicketDatabase = [[MoshTicketDatabase alloc] init];
    }
    return moshTicketDatabase;
}

-(id) init {
    
    if (self = [super init]) {
        db = [FMDatabase databaseWithPath:[self getFilePath]];
        dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self getFilePath]];
        
        if (![db open]) {
			NSLog(@"Could not open db.");
			return nil;
		}
        
        [self createTable];
        
		if ([db hadError]) {
			NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			return nil;
		}
    }
    
    return self;
}


-(void) createTable {
    
    [db setShouldCacheStatements:YES];
    
    //票表
    [self createTicketsTable];
    
}


- (NSString *) getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
    
    MOSHLog(@"databaseAddress:%@",filePath);
    return filePath;
}

- (void) createTicketsTable
{
    //    t_state 票状态 对应1未使用，2已使用，3已过期，4已退票,5删除票
    //    ispost 是否同步服务器 0未同步 1已同步
    NSString *createTickets = [NSString stringWithFormat:@"create table  if not exists %@ (id  INTEGER PRIMARY KEY ASC,eid integer, ticket_id integer, t_id integer, t_password text, t_state integer, tel text, use_date integer, ispost integer, ticket_name text,email text, name text,idcard text,t_price text)",TABLE_TICKET];
    [dbQueue inDatabase:^(FMDatabase *database) {
        [database executeUpdate:createTickets];
    }];
    
    //增加订单id列
    [self addNewColumnIfNotExist:@"oid" valueType:@"integer"];
    
    //增加座位id列
    [self addNewColumnIfNotExist:@"seatinfo" valueType:@"text"];

    //增加备注列
    [self addNewColumnIfNotExist:@"remark" valueType:@"text"];
    
    [dbQueue inDatabase:^(FMDatabase *database) {
    //用票密码和活动名称创建唯一索引
        [database executeUpdate:[NSString stringWithFormat:@"create unique index if not exists t_status on %@ (eid,t_password)",TABLE_TICKET]];
        
        [database executeUpdate:[NSString stringWithFormat:@"create index if not exists password on %@ (t_password)",TABLE_TICKET]];
        
        [database executeUpdate:[NSString stringWithFormat:@"create index if not exists phone_number on %@ (tel)",TABLE_TICKET]];
    
    
        /*创建验票账户表accunt
         eid integer
         auth text
         password text
         title text
         */
        NSString *createAccunt = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (id  INTEGER PRIMARY KEY ASC,eid integer, password text, auth text, title text, start_date integer,end_date integer)",TABLE_AUTH];
        [database executeUpdate:createAccunt];
//        [database executeUpdate:[NSString stringWithFormat:@"create unique index auth on %@ (eid,auth,password)",TABLE_AUTH]];
        [database executeUpdate:@"drop index auth"];
        
        NSString *createTicketName = [NSString stringWithFormat:@"CREATE TABLE if not exists %@ (id  INTEGER PRIMARY KEY ASC,eid integer, tid integer, ticket_title text)",TABLE_NAME];
        [database executeUpdate:createTicketName];
        [database executeUpdate:[NSString stringWithFormat:@"create unique index if not exists t_name on %@ (eid,tid)",TABLE_NAME]];
    }];
    
        [self addNewColumnIfNotExist:@"type" valueType:@"integer" tableName:TABLE_AUTH];
    
//    CGFloat version = [GlobalConfig appVersion];
//    if (version < 1.3) {
//        [self deleteDataInTable:TABLE_AUTH];
//    }
    [self setUpNilType];
}

- (void) setUpNilType
{
    [dbQueue inDatabase:^(FMDatabase *database){
        NSString *sql = [NSString stringWithFormat:@"update table %@ set type = %d where type = ",TABLE_AUTH,1];
        [database executeUpdate:sql];
    }];
}

- (void) addNewColumnIfNotExist:(NSString *)column valueType:(NSString *)type tableName:(NSString *)tableName
{
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@ %@ default 1",tableName,column,type];
    [dbQueue inDatabase:^(FMDatabase *database) {
        [database executeUpdate:sql];
    }];
}

- (void) addNewColumnIfNotExist:(NSString *)column valueType:(NSString *)type
{
    [self addNewColumnIfNotExist:column valueType:type tableName:TABLE_TICKET];
}


- (void) dropTable:(NSString *)tableName
{
        [dbQueue inDatabase:^(FMDatabase *database) {
            [database executeUpdate:[NSString stringWithFormat:@"drop table if exists %@",tableName]];
        }];
}

//从表中取出该列中唯一不同的值
- (NSMutableArray *) selectDistinctColumn:(NSString *)columnName fromTable:(NSString *)tableName
{
    NSString *sql =[ NSString stringWithFormat:@"select distinct %@ from %@",columnName,tableName];
    FMResultSet *resultSet = [db executeQuery:sql];
    NSMutableArray *array = [NSMutableArray new];
    while ([resultSet next]) {
        [array addObject:[NSString stringWithFormat:@"%d",[resultSet intForColumnIndex:0]]];
    }
    [resultSet close];
    return array;
}


#pragma mark - tickets -

//插入票
-(void) insertTickets:(NSArray *)array {
    
    [dbQueue inDatabase:^(FMDatabase *database) {
        NSMutableString *value = [[NSMutableString alloc] init];
        for (Ticket *ticket in array) {
            
            [value appendString:[NSString stringWithFormat:@"(%ld,'%@','%@',%ld,'%@','%@',%ld,'%@',%ld,'%@',%ld,%ld,'%@',%ld,'%@','%@'),",(long)[ticket.eid integerValue],[ticket.email encrypt],[ticket.name encrypt],(long)[ticket.t_id integerValue],[ticket.t_password encrypt],ticket.t_price,(long)[ticket.t_state integerValue],[ticket.tel encrypt],[ticket.ticket_id integerValue],ticket.ticket_name,[ticket.use_date integerValue],[ticket.ispost integerValue],[ticket.idCard encrypt],[ticket.oid  integerValue],ticket.seatinfo,ticket.remark]];
            
            if ([array indexOfObject:ticket] %400 == 0 && [array indexOfObject:ticket] != 0) {
                [value deleteCharactersInRange:NSMakeRange(value.length - 1, 1)];
                //没有 插之
                NSString *sql = [NSString stringWithFormat:@"replace into %@(`eid`,`email`, `name`, `t_id`, `t_password`, `t_price`, `t_state`, `tel`, `ticket_id`, `ticket_name`, `use_date`, `ispost`,`idcard`,`oid`,`seatinfo`,`remark`) values%@",TABLE_TICKET,value];
                
                BOOL success = [database executeUpdate:sql];
                if (success) {
                    MOSHLog(@"插入成功");
                }
                else {
                    MOSHLog(@"插入失败");
                }
                value = [[NSMutableString alloc] init];
            }
            
        }
        if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:value]) {
            [value deleteCharactersInRange:NSMakeRange(value.length - 1, 1)];
            //没有 插之
            NSString *sql = [NSString stringWithFormat:@"replace into %@(`eid`,`email`, `name`, `t_id`, `t_password`, `t_price`, `t_state`, `tel`, `ticket_id`, `ticket_name`, `use_date`, `ispost`,`idcard`,`oid`,`seatinfo`,`remark`) values%@",TABLE_TICKET,value];
            
            BOOL success = [database executeUpdate:sql];
            if (success) {
                MOSHLog(@"插入成功");
            }
            else {
                MOSHLog(@"插入失败");
            }
            value = [[NSMutableString alloc] init];
        }
    }];
}


//取一张票（new）
-(Ticket *)getOneTicket:(NSString *)t_password eid:(NSString *)eid ticketID:(NSString *)ticketID{
    
    Ticket *ticket = nil;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where t_password = '%@'",TABLE_TICKET,[t_password encrypt]];
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:ticketID]) {
        [sql appendFormat:@" and ticket_id in (%@)",ticketID];
    }
    
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        ticket = [self ticketOfResultSet:resultSet];
    }
    [resultSet close];
    return ticket;
}

//搜索票(new)
-(NSMutableArray *) searchTicket:(NSString *)passwordOrTel eid:(NSString *)eid ticketID:(NSString *)ticketID{
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1",TABLE_TICKET];
    
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:ticketID]) {
        [sql appendFormat:@" and ticket_id in (%@)",ticketID];
    }
    
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:passwordOrTel]) {
        [sql appendFormat:@" and (t_password = '%@' or tel = '%@')",[passwordOrTel encrypt],[passwordOrTel encrypt]];

    }

    [sql appendString:@" and t_state in (1,2) order by use_date desc"];
    
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        Ticket *ticket = [self ticketOfResultSet:resultSet];
        [resultArray addObject:ticket];
        
    }
    [resultSet close];
    return resultArray;
    
}

//订单(new)
- (NSArray *) searchAllOrderTicketsWithEid:(NSString *)eid oid:(NSString *)oid ticketID:(NSString *)ticketID
{
    if (![GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:oid]) {
        return nil;
    }
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where oid = %@",TABLE_TICKET,oid];
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:ticketID]) {
        [sql appendFormat:@" and ticket_id in (%@)",ticketID];
    }
    
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        Ticket *ticket = [self ticketOfResultSet:resultSet];
        [resultArray addObject:ticket];
        
    }
    [resultSet close];
    return resultArray;
}

//取一个活动所有票数量(new)
-(int) getAllTicketCountByEid:(NSString *)eid status:(NSString *)status ticketID:(NSString *)ticketID
{
    
    int totalCount = 0;
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select count(*) from %@ where 1",TABLE_TICKET];
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:ticketID]) {
        [sql appendFormat:@" and ticket_id in (%@)",ticketID];
    }

    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:status]) {
        [sql appendFormat:@" and t_state in (%@)",status];
    }
    else {
        [sql appendFormat:@" and t_state in (1,2)"];
    }
    
    
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        totalCount = [resultSet intForColumnIndex:0];
    }
    [resultSet close];
    return totalCount;
}


//取某个状态的所有票(new)
-(NSMutableArray *) getAllTicketByEid:(NSString *)eid status:(NSString *)status ticketID:(NSString *)ticketID{
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1",TABLE_TICKET];
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:ticketID]) {
        [sql appendFormat:@" and ticket_id in (%@)",ticketID];
    }
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:status]) {
        [sql appendFormat:@" and t_state in (%@)",status];
    }
    else {
        [sql appendFormat:@" and t_state in (1,2)"];
    }
   
    [sql appendString:@"order by use_date desc"];
    
    FMResultSet *resultSet = [db executeQuery:sql];
    
    while ([resultSet next]) {
        Ticket *ticket = [self ticketOfResultSet:resultSet];
        [resultArray addObject:ticket];
    }
    [resultSet close];
    return resultArray;
    
}

//取未提交服务器的所有票
-(NSMutableArray *) getAllUnpostTicketsByEid:(NSString *)eid {
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where ispost = %@", TABLE_TICKET,ticketUpdte_no];
    FMResultSet *resultSet = [db executeQuery:sql];
    
    while ([resultSet next]) {
        Ticket *ticket = [self ticketOfResultSet:resultSet];
        [resultArray addObject:ticket];
    }
    [resultSet close];
    return resultArray;
    
}

//取未提交服务器的所有票
-(NSMutableArray *) getAllUnpostTickets:(NSString *)tableName {
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where ispost = %@",tableName,ticketUpdte_no];
    FMResultSet *resultSet = [db executeQuery:sql];
    
    while ([resultSet next]) {
        Ticket *ticket = [self ticketOfResultSet:resultSet];
        [resultArray addObject:ticket];
    }
    [resultSet close];
    return resultArray;
    
}




//删除
-(void) deleteOneTickt:(NSString *)t_id {

    [dbQueue inDatabase:^(FMDatabase *database) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where t_id =%@",TABLE_TICKET, t_id];
        [database executeUpdate:sql];
    }];
}

//全部删除
-(void) deleteAllTicketWitheid:(NSString *)eid {
    
    [dbQueue inDatabase:^(FMDatabase *database) {
      NSString *sql = [NSString stringWithFormat:@"delete from %@ where eid = %@", TABLE_TICKET,eid];
        [database executeUpdate:sql];
    }];
   
    
}

//大杀器！注意！
-(void) deleteAllTicket {
    
    [dbQueue inDatabase:^(FMDatabase *database) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ ",TABLE_TICKET];
         [database executeUpdate:sql];
    }];
    
}

-(void) deleteDataInTable:(NSString *)tablename {
    
    [dbQueue inDatabase:^(FMDatabase *database) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ ",tablename];
        [database executeUpdate:sql];
    }];
    
}

- (Ticket *) ticketOfResultSet:(FMResultSet *)resultSet
{
    Ticket *ticket = [[Ticket alloc] init];
    ticket.eid = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"eid"]];
    ticket.t_id = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"t_id"]];
    ticket.t_state = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"t_state"]];
    ticket.ticket_id = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"ticket_id"]];
    ticket.remark = [GlobalConfig convertToString:[resultSet stringForColumn:@"remark"]];
    ticket.seatinfo = [GlobalConfig convertToString:[resultSet stringForColumn:@"seatinfo"]];
    ticket.oid = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"oid"]];
    ticket.use_date = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"use_date"]];
    ticket.ispost = [NSString stringWithFormat:@"%d",[resultSet intForColumn:@"ispost"]];
    
    ticket.t_price = [GlobalConfig convertToString:[resultSet stringForColumn:@"t_price"]];
    ticket.ticket_name = [GlobalConfig convertToString:[resultSet stringForColumn:@"ticket_name"]];
    
    ticket.name = [[GlobalConfig convertToString:[resultSet stringForColumn:@"name"]] decrypt];
    ticket.t_password = [[GlobalConfig convertToString:[resultSet stringForColumn:@"t_password"]] decrypt];
    ticket.tel = [[GlobalConfig convertToString:[resultSet stringForColumn:@"tel"]] decrypt];
    ticket.idCard = [[GlobalConfig convertToString:[resultSet stringForColumn:@"idcard"]] decrypt];
    ticket.email = [[GlobalConfig convertToString:[resultSet stringForColumn:@"email"]] decrypt];

    return ticket;
}
//
////----------------------------------------------------------------------------------------------------

//验票(0.错误 1.未使用 2.已使用)
-(void) UpdateTikcet:(NSString *)t_id status:(NSString *)status {
    
    [dbQueue inDatabase:^(FMDatabase *database) {
        NSString *time = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
        if ([status intValue] == 1) {
            time = @"0";
        }
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set t_state = %@,use_date = %@ where t_id = %@", TABLE_TICKET,status,time, t_id];
         [database executeUpdate:sql];
    }];
}


-(void) updateTicket:(Ticket *)ticket state:(NSString *)state useDate:(NSString *)usedate{
    
    [dbQueue inDatabase:^(FMDatabase *database) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set t_state = %@, use_date = %@  where eid  = %@ and t_password = '%@'", TABLE_TICKET,state,usedate, ticket.eid,[ticket.t_password encrypt]];
        [database executeUpdate:sql];
    }];
}



- (void) updateTicket:(Ticket *)ticket isPost:(NSString *)ispost
{
     [dbQueue inDatabase:^(FMDatabase *database) {
         NSString *sql = [NSString stringWithFormat:@"update %@ set ispost = %@ where eid  = %@ and  t_password = '%@'", TABLE_TICKET,ispost, ticket.eid,[ticket.t_password encrypt]];
         [database executeUpdate:sql];
     }];
}


/**
 *  验票账户相关操作
 *
 */

//添加一个账户
- (BOOL) addAccunt:(NSString *)auth pass:(NSString *)pass title:(NSString *)title eid:(NSString *)eid startDate:(NSString *)startDate endDate:(NSString *)endDate type:(NSInteger)type{
    
    //如果有记录则不再插入
    NSString *sql = [NSString stringWithFormat:@"select auth from %@ where eid = %@ and type = %ld",TABLE_AUTH,eid,(long)type];
    FMResultSet *resultSet = [db executeQuery:sql];
    if ([resultSet next]) {
       
        sql = [NSString stringWithFormat:@"update %@ set `auth` = '%@',`password` = '%@',`title` = '%@',`start_date` = '%@',`end_date` = '%@' where eid = %@",TABLE_AUTH,auth,pass,title,startDate,endDate,eid];
        
    } else {
        sql = [NSString stringWithFormat:@"insert into %@(`eid`,`auth`,`password`,`title`,`start_date`,`end_date`,`type`) values('%@','%@','%@','%@','%@','%@',%ld)",TABLE_AUTH,eid,auth,pass,title,startDate,endDate,(long)type];
    }
    
    //无记录
//    NSString *sql = [NSString stringWithFormat:@"replace into %@(`eid`,`auth`,`password`,`title`,`start_date`,`end_date`) values('%@','%@','%@','%@',%@,%@)",TABLE_AUTH,eid,auth,pass,title,startDate,endDate];
//    NSString *sql = [NSString stringWithFormat:@"update %@ set `auth` = '%@',`password` = '%@',`title` = '%@',`start_date` = '%@',`end_date` = '%@' where eid = %@",TABLE_AUTH,auth,pass,title,startDate,endDate,eid];
    
    BOOL success = [db executeUpdate:sql];
    if (success) {
        MOSHLog(@"插入成功");
    }
    else {
        MOSHLog(@"插入失败");
    }
    [resultSet close];
    return success;
}


//删除账户级相关票数据
- (void) removeAccuntWhereEid:(NSString *)eid type:(NSInteger)type {

    [dbQueue inDatabase:^(FMDatabase *database) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where eid = %@ and type = %ld",TABLE_AUTH,eid,(long)type];
        [database executeUpdate:sql];
        
        sql = [NSString stringWithFormat:@"select count(*) from %@ where eid = %@",TABLE_AUTH,eid];
        FMResultSet *resultSet = [db executeQuery:sql];
        BOOL isDel = YES;
        while ([resultSet next]) {
            isDel = NO;
        }
        if (isDel) {
            sql = [NSString stringWithFormat:@"delete from %@ where eid = %@",TABLE_TICKET,eid];
            [database executeUpdate:sql];
            sql = [NSString stringWithFormat:@"delete from %@ where eid = %@",TABLE_NAME,eid];
            [database executeUpdate:sql];
        }
    }];
}


//获取账户列表
//    t_state 票状态 对应1未使用，已使用，3已过期，4已退票,5删除票
//    ispost 是否同步服务器 0未同步 1已同步
//@{@"eid":eid,@"title":@"标题",@"totalCount":@"123",@"usedCount":@"123",@"unSyncCount":@"123"}
- (NSMutableArray *) getAccuntList {
    
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = [NSString stringWithFormat:@"select eid, title, start_date, end_date,type from %@ order by id desc",TABLE_AUTH];

    NSString *totalCount = [NSString string];
    NSString *usedCount = [NSString string];
    NSString *unSyncCount = [NSString string];
    
    FMResultSet *rs = [db executeQuery:sql];
    
    while ([rs next]) {
        
        Activity *act = [[Activity alloc] init];
        
        act.eid = [rs stringForColumn:@"eid"];
        act.title = [rs stringForColumn:@"title"];
        act.startDate = [rs stringForColumn:@"start_date"];
        act.endDate = [rs stringForColumn:@"end_date"];
        act.type = [rs intForColumn:@"type"];
        
        //总数
        sql = [NSString stringWithFormat:@"select count(*) from %@ where eid = %@",TABLE_TICKET,act.eid];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            totalCount = [NSString stringWithFormat:@"%d",[resultSet intForColumnIndex:0]];
        }
        act.totalCount = totalCount;
       
        //已用数
        sql = [NSString stringWithFormat:@"select count(*) from %@ where t_state = 2 and eid = %@",TABLE_TICKET,act.eid];
        resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            usedCount = [NSString stringWithFormat:@"%d",[resultSet intForColumnIndex:0]];
        }
        act.usedCount = usedCount;
        
        //未同步
        sql = [NSString stringWithFormat:@"select count(*) from %@ where ispost = 0 and eid = %@",TABLE_TICKET,act.eid];
        resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            unSyncCount = [NSString stringWithFormat:@"%d",[resultSet intForColumnIndex:0]];

        }
        act.unSyncCount = unSyncCount;
        [arr addObject:act];
    }
    [rs close];
    return arr;
    
}




/**
 *  票种相关操作
 *
 */
//添加票种
- (void) addTicketNameWithEid:(NSString *)eid tickets:(NSMutableArray *)ticketArr {
    
    if (ticketArr.count <= 0) {
        return;
    }
    [dbQueue inDatabase:^(FMDatabase *database) {
        NSMutableString *value = [[NSMutableString alloc] init];
        
        for (TicketType *type in ticketArr ) {
            
            [value appendString:[NSString stringWithFormat:@"('%@','%@','%@'),",eid,type.tTypeID,type.tTypeName]];
            
            if ([ticketArr indexOfObject:type] %400 == 0 && [ticketArr indexOfObject:type] != 0) {
                [value deleteCharactersInRange:NSMakeRange(value.length - 1, 1)];

                NSString *sql = [NSString stringWithFormat:@"replace into %@(`eid`,`tid`, `ticket_title`) values%@",TABLE_NAME,value];
                BOOL success = [db executeUpdate:sql];
                if (success) {
                    MOSHLog(@"插入成功");
                    
                }
                else {
                    MOSHLog(@"插入失败");
                }
                value = [[NSMutableString alloc] init];
            }
            
        }
        
        if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:value]) {
            [value deleteCharactersInRange:NSMakeRange(value.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"replace into %@(`eid`,`tid`, `ticket_title`) values%@",TABLE_NAME,value];
            BOOL success = [db executeUpdate:sql];
            if (success) {
                MOSHLog(@"插入成功");
                
            }
            else {
                MOSHLog(@"插入失败");
            }
            value = [[NSMutableString alloc] init];
        }

    }];
    
}

//获取一个活动的所有票种
//@{@"tid":@"123",@"ticket_title":@"标题"}
- (NSMutableArray *) getTicketListWhereEid:(NSString *)eid eventTitle:(NSString *)title {
    
    NSString *sql = [NSString stringWithFormat:@"select tid,ticket_title from %@ where eid = %@",TABLE_NAME,eid];
    FMResultSet *resultSet = [db executeQuery:sql];

    NSMutableArray *array = [NSMutableArray array];
    
    while ([resultSet next]) {

        TicketType *tt = [[TicketType alloc] init];
        tt.tTypeID = [resultSet stringForColumn:@"tid"];
        tt.tTypeName = [resultSet stringForColumn:@"ticket_title"];
        tt.eventName = title;
        tt.eid = eid;
        [array addObject:tt];
    }
    [resultSet close];
    return array;
}


//取票总数
- (NSString *) getTicketsCountWithEid:(NSString *)eid {
    

    NSString *sql = [NSString stringWithFormat:@"select count(eid) from %@ where eid = %@",TABLE_TICKET,eid];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        return [rs stringForColumnIndex:0];
    }
    [rs close];
    return @"";
}

//根据票状态取票数
- (NSString *) getTicketsCountWithEid:(NSString *)eid ticketState:(NSString *)state {

    NSString *sql = [NSString stringWithFormat:@"select count(eid) from %@ where eid = %@ and t_state = %@",TABLE_TICKET,eid,state];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        return [rs stringForColumnIndex:0];
    }
    [rs close];
    return @"";
}

//根据同步状态取票数
- (NSString *) getTicketsCountWithEid:(NSString *)eid synaState:(NSString *)state {

    NSString *sql = [NSString stringWithFormat:@"select count(eid) from %@ where eid = %@ and ispost = %@",TABLE_TICKET,eid,state];
    FMResultSet *rs = [db executeQuery:sql];
    if ([rs next]) {
        return [rs stringForColumnIndex:0];
    }
    [rs close];
    return @"";
}

- (Activity *) getAccuntWithEid:(NSString *)eid {

    Activity *act = [[Activity alloc] init];
    NSString *sql = [NSString stringWithFormat:@"select eid, title, auth, password from %@ where eid = %@ ",TABLE_AUTH,eid];
    
    FMResultSet *re = [db executeQuery:sql];
    
    while ([re next]) {
        act.title = [re stringForColumn:@"title"];
        act.auth = [re stringForColumn:@"auth"];
        act.password = [re stringForColumn:@"password"];
        act.eid = [re stringForColumn:@"eid"];
    }
    [re close];
    return act;
}


- (NSString *) getTicketsCountWithTicketTypeID:(NSString *)tid ticketState:(NSString *)state {
    
    NSString *totalCount = @"0";
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select count(*) from %@ where 1",TABLE_TICKET];
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:tid]) {
        [sql appendFormat:@" and ticket_id in (%@)",tid];
    }
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:state]) {
        [sql appendFormat:@" and t_state in (%@)",state];
    }
    else {
        [sql appendFormat:@" and t_state in (1,2)"];
    }
    
    [sql appendString:@"order by use_date desc"];
    
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        totalCount = [NSString stringWithFormat:@"%d",[resultSet intForColumnIndex:0]];
    }
    [resultSet close];
    return totalCount;
}

- (NSString *) getEventWithTicketId:(NSString *)tid {
    
    return @"";
}


- (NSMutableArray *) searchTicketClass:(NSString *)keyWord eid:(NSString *)eid{
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    NSMutableString *sql = [NSMutableString stringWithFormat:@"select * from %@ where 1",TABLE_NAME];
    
    
    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:keyWord]) {
        [sql appendFormat:@" and ticket_title like '%%%@%%' and eid = %@",keyWord,eid];
    }
    
    FMResultSet *resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        
        TicketType *tt = [[TicketType alloc] init];
        tt.tTypeID = [resultSet stringForColumn:@"tid"];
        tt.tTypeName = [resultSet stringForColumn:@"ticket_title"];
        [resultArray addObject:tt];
    }

    [resultSet close];
    return resultArray;

}


- (void) dealloc
{
    [db close];
}

@end
