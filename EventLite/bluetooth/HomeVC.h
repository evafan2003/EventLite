//
//  HomeVC.h
//  EventLite
//
//  Created by 魔时网 on 15/1/27.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "BaseTableViewController.h"

typedef NS_ENUM(NSInteger, MangerType)
{
    MangerType_single = 0,
    MangerType_valid,
    MangerType_invalid,
};

@interface HomeVC : BaseTableViewController

@property (assign, nonatomic) MangerType type;

@end