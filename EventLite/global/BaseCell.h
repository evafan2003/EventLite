//
//  BaseCell.h
//  CoolProject
//
//  Created by wuzhensong on 14-7-6.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"

@interface BaseCell : UITableViewCell
@property (nonatomic ,strong) BaseModel *model;

- (void) setValueForCell:(BaseModel *)model;

+ (CGFloat) cellHeightWithModel:(BaseModel *)model;

@end
