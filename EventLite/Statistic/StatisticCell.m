//
//  StatisticCell.m
//  EventLite
//
//  Created by 魔时网 on 15/1/31.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "StatisticCell.h"
#import "StatisticModel.h"  

@implementation StatisticCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setValueForCell:(BaseModel *)model
{
    StatisticModel *item = (StatisticModel *)model;
    self.model = model;
    self.typeLabel.text = item.typeName;
    self.totalCountLabel.text = item.totalCount;
    self.usedCountLabel.text = item.usedCount;
}

+ (CGFloat) cellHeightWithModel:(BaseModel *)model
{
    static StatisticCell *cell = nil;
    if (cell == nil) {
        cell = (StatisticCell *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    }
    [cell setValueForCell:model];
    [cell layoutIfNeeded];
    
    return CGRectGetMaxY(cell.typeLabel.frame);
}


@end
