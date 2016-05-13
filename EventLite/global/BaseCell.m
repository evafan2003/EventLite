//
//  BaseCell.m
//  CoolProject
//
//  Created by wuzhensong on 14-7-6.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setValueForCell:(BaseModel*)model
{

}

+ (CGFloat) cellHeightWithModel:(BaseModel *)model
{
    return 0;
}

@end
