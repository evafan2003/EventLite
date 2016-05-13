//
//  HomeCell.m
//  EventLite
//
//  Created by 魔时网 on 15/1/27.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "HomeCell.h"
#import "Activity.h"
#import "MBProgressHUD.h"
#import "ServerManger.h"    

static NSString *act_end = @"badge_end";
static NSString *act_display = @"badge_ing";
static NSString *act_unstart = @"badge_unstart";

@implementation HomeCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setValueForCell:(BaseModel *)model index:(NSInteger)index
{
    Activity *item = (Activity *)model;
    self.model = model;
    self.titleLabel.text = [NSString stringWithFormat:@"活动%ld：%@",(long)(index+1),item.title];
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@张",item.totalCount];
    self.usedCountLabel.text = [NSString stringWithFormat:@"%@张",item.usedCount];
    self.unSyncCountLabel.text = [NSString stringWithFormat:@"%@张",item.unSyncCount];
    [self changeBadgeImageAtindex:index];
}

+ (CGFloat) cellHeightWithModel:(BaseModel *)model index:(NSInteger)index
{
    static HomeCell *cell = nil;
    if (cell == nil) {
        cell = (HomeCell *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    }
    [cell setValueForCell:model index:index];
    [cell layoutIfNeeded];
    
    return CGRectGetMaxY(cell.titleLabel.frame) + 111;
}

//更改cell背景色
- (void) changeBadgeImageAtindex:(NSInteger)index
{
     Activity *act = (Activity *)self.model;
    
    //当前时间大于开始时间
    if ([GlobalConfig dateCompareWithCurrentDate:act.startDate] == NSOrderedAscending) {
        //大于结束时间 已结束
        if ([GlobalConfig dateCompareWithCurrentDate:act.endDate] == NSOrderedAscending) {
            self.badgeImage.image = [UIImage imageNamed:act_end];
        }
        else {//进行中
            self.badgeImage.image = [UIImage imageNamed:act_display];
        }
    }
    else {//未开始
        self.badgeImage.image = [UIImage imageNamed:act_unstart];
    }
}


//刷新
- (IBAction)onClickRefresh:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
    Activity *item = (Activity *)self.model;
    Activity *act = [DATABASE_INSTANCE getAccuntWithEid:item.eid];
    [[HTTPClient shareHTTPClient] getAllTicketsWithEid:act.eid username:act.auth password:act.password success:^(Activity *act) {
        [MBProgressHUD hideAllHUDsForView:self.superview animated:YES];
        if (!act) {
            [GlobalConfig showAlertViewWithMessage:@"更新失败" superView:nil];
        }
        else {
            [NOTICENTER postNotificationName:NOTI_EVENTUPDATE object:nil userInfo:@{@"eid":item.eid}];
        }
    }];
}

- (IBAction)onClickSync:(id)sender {
    
    Activity *item = (Activity *)self.model;
    NSArray *array = [DATABASE_INSTANCE getAllUnpostTicketsByEid:item.eid];
    if (array.count > 0) {
        [GlobalConfig showAlertViewWithMessage:@"正在上传中..." superView:nil];
        [[ServerManger shareServerManger] updateTickets:array];
    }
    else {
        [GlobalConfig showAlertViewWithMessage:@"验票数据已全部上传" superView:nil];
    }
    
}

- (IBAction)onClickDelete:(id)sender {
    
    RIButtonItem *cancle = [RIButtonItem itemWithTitle:@"取消"];
    RIButtonItem *confirm = [RIButtonItem itemWithTitle:@"确认删除"];
    [confirm setAction:^{
        Activity *item = (Activity *)self.model;
        [DATABASE_INSTANCE removeAccuntWhereEid:item.eid type:item.type];
        [HTTPClient removeLastDownloadDateWithEid:item.eid];
        NOTICENTER_POST(NOTI_EVENTUPDATE);
    }];
    
    [[[UIAlertView alloc] initWithTitle:@"确认删除验票数据？" message:@"请确认未上传票数为0张" cancelButtonItem:cancle otherButtonItems:confirm, nil] show];
    
    
}



@end
