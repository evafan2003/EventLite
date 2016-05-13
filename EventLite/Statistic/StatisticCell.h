//
//  StatisticCell.h
//  EventLite
//
//  Created by 魔时网 on 15/1/31.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"

@interface StatisticCell : BaseCell
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;

@end
