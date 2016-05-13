//
//  StatisticModel.h
//  EventLite
//
//  Created by 魔时网 on 15/1/31.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "BaseModel.h"

@interface StatisticModel : BaseModel

@property (nonatomic,strong) NSString *typeID;
@property (nonatomic,strong) NSString *typeName;
@property (nonatomic,strong) NSString *usedCount;
@property (nonatomic,strong) NSString *totalCount;

@end
