//
//  HomeCell.h
//  EventLite
//
//  Created by 魔时网 on 15/1/27.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"

@interface HomeCell : BaseCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *unSyncCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *badgeImage;
- (void) setValueForCell:(BaseModel *)model index:(NSInteger)index;
+ (CGFloat) cellHeightWithModel:(BaseModel *)model index:(NSInteger)index;

@end
