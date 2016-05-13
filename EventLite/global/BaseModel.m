//
//  BaseModel.m
//  moshTickets
//
//  Created by 魔时网 on 14-8-4.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "BaseModel.h"
#import "GlobalConfig.h"

@implementation BaseModel

- (id) initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        /**
         *  必须实现 - (void) setValue:(id)value forUndefinedKey:(NSString *)key 否则遇到没有的key就会crash
         *  如果dic中没有@property的值 则@property值为nil
         */
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

//dic中key在@property所有属性中找不到对应的属性时会调用
- (void) setValue:(id)value forUndefinedKey:(NSString *)key
{
    //如果不需要可不写内容 但是该方法不能省略
}

//将普通数组转换为model数组
+ (NSArray *) converToModelArray:(NSArray *)array
{
    NSMutableArray *dataArr = [NSMutableArray new];
    
    for (NSDictionary *dic in array) {
        if ([GlobalConfig isKindOfNSDictionaryClassAndCountGreaterThanZero:dic]) {
            BaseModel *model = [[self alloc] initWithDictionary:dic];
            [dataArr addObject:model];
        }
    }
    return dataArr;
}

@end
