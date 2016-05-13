//
//  BaseModel.h
//  moshTickets
//
//  Created by 魔时网 on 14-8-4.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

- (id) initWithDictionary:(NSDictionary *)dic;


//将普通数组转换为model数组
+ (NSArray *) converToModelArray:(NSArray *)array;

@end
