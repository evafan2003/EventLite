//
//  StatisticVC.m
//  EventLite
//
//  Created by 魔时网 on 15/1/31.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "StatisticVC.h"
#import "StatisticCell.h"
#import "TicketType.h"
#import "StatisticModel.h"

static NSString *statisticCellID = @"statisticCell";

@interface StatisticVC ()

@end



@implementation StatisticVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBarWithLeftBarItem:MoshNavigationBarItemBack rightBarItem:MoshNavigationBarItemNone title:NAVTITLE_STATISTIC];
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.baseTableView registerNib:[UINib nibWithNibName:NSStringFromClass([StatisticCell class]) bundle:nil] forCellReuseIdentifier:statisticCellID];
    [self downloadData];
    
    [self createHeaderView];
    
}


-(void)createHeaderView {
    
    UIView *view = [GlobalConfig createViewWithFrame:CGRectMake(0, 0, self.baseTableView.frame.size.width, 30)];
    view.backgroundColor = BLUECOLOR;
    
    UILabel *label = [GlobalConfig createLabelWithFrame:CGRectMake(7,0,165, view.frame.size.height) Text:@"票种" FontSize:14 textColor:WHITECOLOR];
    [view addSubview:label];
    
    UILabel *label1 = [GlobalConfig createLabelWithFrame:CGRectMake(176,0,69, view.frame.size.height) Text:@"已验数" FontSize:14 textColor:WHITECOLOR];
    [view addSubview:label1];
    
    UILabel *label2 = [GlobalConfig createLabelWithFrame:CGRectMake(249,0,69, view.frame.size.height) Text:@"总数" FontSize:14 textColor:WHITECOLOR];
    [view addSubview:label2];
    self.baseTableView.frame = CGRectMake(0, 30, SCREENWIDTH, SCREENHEIGHT-NAVHEIGHT-30);
    
    view.frame = CGRectMake(0, 0, SCREENWIDTH, 30);
    [self.view addSubview: view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadData
{
    NSString *tmpEid = nil;
    Activity *tmpAct = nil;
    for(TicketType *type in self.selectTypeArray) {
        
        StatisticModel *model = [StatisticModel new];
        model.typeID = type.tTypeID;
        model.typeName = type.tTypeName;
        model.usedCount = [DATABASE_INSTANCE getTicketsCountWithTicketTypeID:model.typeID ticketState:ticketState_isUsed];
        model.totalCount = [DATABASE_INSTANCE getTicketsCountWithTicketTypeID:model.typeID ticketState:nil];
        
        if (![tmpEid isEqualToString:type.eid]) {
            tmpEid = type.eid;
            Activity *act = [Activity new];
            tmpAct = act;
            act.eid = type.eid;
            act.title = type.eventName;
            act.tickedTypeArray = [NSMutableArray new];
            [act.tickedTypeArray addObject:model];
            [self.dataArray addObject:act];
        }
        else {
            [tmpAct.tickedTypeArray addObject:model];
        }

    }
    
    [self.baseTableView reloadData];
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Activity *act = self.dataArray[section];
    UILabel *label = [GlobalConfig createLabelWithFrame:CGRectMake(0, 0, self.baseTableView.frame.size.width, 30) Text:act.title FontSize:14 textColor:[UIColor darkTextColor]];
    label.backgroundColor = [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1];
    return label;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Activity *act = self.dataArray[indexPath.section];
    CGFloat height = [StatisticCell cellHeightWithModel:act.tickedTypeArray[indexPath.row]];
    return height;
}

#pragma mark - tableViewDelegate -
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatisticCell *cell = [tableView dequeueReusableCellWithIdentifier:statisticCellID];
    
    Activity *act = self.dataArray[indexPath.section];
    
    [cell setValueForCell:act.tickedTypeArray[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Activity *act = self.dataArray[section];
    
    return act.tickedTypeArray.count;
}

@end
