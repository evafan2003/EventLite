//
//  HomeVC.m
//  EventLite
//
//  Created by 魔时网 on 15/1/27.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "HomeVC.h"
#import "HomeCell.h"
#import "AddEventVC.h"    
#import "AppDelegate.h"
#import "HMSegmentedControl.h"

static NSString *homeCellID = @"homeCell";

#define DAYTIME 86400
#define VALIDTIME   (DAYTIME*2)

const NSString *_ins_single = @"单活动验票";
const NSString *_ins_valid = @"多活动验票";
const NSString *_ins_invalid = @"已失效";



@interface HomeVC ()
{
    NSMutableArray *_event_invalid_array;
    NSMutableArray *_event_valid_array;
    Activity *_singleAct;
    NSInteger unupdate;
}
@property (strong, nonatomic) IBOutlet UIView *invalidHeaderView;
@property (strong, nonatomic) IBOutlet UIView *validHeaderView;
@property (strong, nonatomic) IBOutlet UIView *singleHeaderView;
@property (strong, nonatomic) IBOutlet UIView *BottomView;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIView *segmentControlView;
@property (weak, nonatomic) IBOutlet UIView *eventListView;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createBarWithLeftBarItem:MoshNavigationBarItemNone rightBarItem:MoshNavigationBarItemPrint title:NAVTITLE_EVENT_MANAGER];

    _event_invalid_array = [NSMutableArray new];
    _event_valid_array = [NSMutableArray new];
    self.type = MangerType_single;
    
    [self.eventListView addSubview:self.baseTableView];
    [self.baseTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HomeCell class]) bundle:nil] forCellReuseIdentifier:homeCellID];
    self.cellHeight = 115;
    self.baseTableView.frame = CGRectMake(0, 0,CGRectGetWidth( self.eventListView.frame), CGRectGetHeight(self.eventListView.frame));
    self.baseTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    [self.baseTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSDictionary *dic = @{@"_baseTableView":self.baseTableView};
//    NSString *vfv = @"V:|-0-[_baseTableView]-0-|";
//    NSString *vfh = @"H:|-0-[_baseTableView]-0-|";
//    [self.eventListView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfv options:0 metrics:nil views:dic]];
//    [self.eventListView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfh options:0 metrics:nil views:dic]];
    
    [self addEGORefreshOnTableView:self.baseTableView];
    [self createSegmentControl];
    
    [self downloadData];
    
    //消息监听
    [self addNotiObserver];
    
    self.addImageView.image = [GlobalConfig changeImage:self.addImageView.image color:[UIColor orangeColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//注册通知
- (void) addNotiObserver
{
    [NOTICENTER addObserver:self selector:@selector(downloadData) name:NOTI_EVENTUPDATE object:nil];
    [NOTICENTER addObserver:self selector:@selector(updateTotalTickets:) name:NOTI_TICKET_UPDATE object:nil];
    //更新已使用票数
    [NOTICENTER addObserver:self selector:@selector(updateUsedTickets:) name:NOTI_TICKET_USEDUPDATE object:nil];
    //更新未上传票数
    [NOTICENTER addObserver:self selector:@selector(updateUnSyncTIckets:) name:NOTI_TICKET_SYNCUPDATE object:nil];

}

- (void) createSegmentControl
{
    HMSegmentedControl *segmentedControl3 = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"单活动", @"多活动", @"已失效"]];
    [segmentedControl3 setFrame:CGRectMake(0,0, SCREENWIDTH, 30)];
    segmentedControl3.font = [UIFont systemFontOfSize:13];
    segmentedControl3.selectionIndicatorHeight = 2.0f;
    segmentedControl3.backgroundColor = RGB(243, 243, 243);
    segmentedControl3.textColor = [UIColor darkTextColor];
    segmentedControl3.selectedTextColor = [UIColor orangeColor];
    segmentedControl3.selectionIndicatorColor = [UIColor lightGrayColor];
    segmentedControl3.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentedControl3.selectedSegmentIndex = HMSegmentedControlNoSegment;
    segmentedControl3.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    segmentedControl3.shouldAnimateUserSelection = YES;
    segmentedControl3.selectedSegmentIndex = 0;
    [self.segmentControlView addSubview:segmentedControl3];
    
    segmentedControl3.indexChangeBlock = ^(NSInteger index){
        self.type = index;
        [self refreshTableView];
    };

}

//更新全部数据
- (void) downloadData
{
    NSArray *eventArray = [[MoshTicketDatabase sharedInstance] getAccuntList];
    
    if (eventArray.count > 0) {
        self.dataArray = (NSMutableArray *)eventArray;
        [self refreshDataArray];
    }
    else {
        [self presentLoginVC];
    }
}

- (void) refreshDataArray
{
    [_event_valid_array removeAllObjects];
    [_event_invalid_array removeAllObjects];
    _singleAct = nil;
    for (Activity *act in self.dataArray) {
        if ([self isActivityValid:act]) {
            if (act.type == MangerType_valid) {
                [_event_valid_array addObject:act];
            }
            else {
                _singleAct = act;
            }
        }
        else {
            [_event_invalid_array addObject:act];
        }
    }
    [self refreshTableView];
}


//更新总数
- (void) updateTotalTickets:(NSNotification *)sender
{
    NSDictionary *dic = [sender userInfo];
    NSString *eid = [GlobalConfig convertToString:dic[@"eid"]];
    for (Activity *model in self.dataArray) {
        if ([model.eid isEqualToString:eid]) {
            model.totalCount = [DATABASE_INSTANCE getTicketsCountWithEid:eid];
            break;
        }
    }
    [self refreshDataArray];
}
//更新使用过的
- (void) updateUsedTickets:(NSNotification *)sender
{
    NSDictionary *dic = [sender userInfo];
    NSString *eid = [GlobalConfig convertToString:dic[@"eid"]];
    for (Activity *model in self.dataArray) {
        if ([model.eid isEqualToString:eid]) {
            model.usedCount = [DATABASE_INSTANCE getTicketsCountWithEid:eid ticketState:ticketState_isUsed];
            break;
        }
    }
    [self refreshDataArray];
}
//更新同步的
- (void) updateUnSyncTIckets:(NSNotification *)sender
{
    for (Activity *model in self.dataArray) {
            model.unSyncCount = [DATABASE_INSTANCE getTicketsCountWithEid:model.eid synaState:ticketUpdte_no];
    }
    [self refreshDataArray];
}

//下拉刷新
- (void) refresh
{
    [self.headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.baseTableView];
    self.isLoading = NO;

    [self downloadData];
}

- (void) refreshTableView
{
    [self refreshHeaderView];
    [self refreshFooterView];
    [self.baseTableView reloadData];

}

- (void) refreshFooterView
{
    switch (self.type) {
        case MangerType_single:
        {
            if ([self getActivityListArray].count < 1) {
                self.baseTableView.tableFooterView = self.BottomView;
            }
            else {
                self.baseTableView.tableFooterView = nil;
            }
        }
            break;
        case MangerType_invalid:
            self.baseTableView.tableFooterView = nil;
            break;
        default:
            self.baseTableView.tableFooterView = self.BottomView;
            break;
    }
}

- (void) refreshHeaderView
{
    switch (self.type) {
        case MangerType_single:
        {
            self.baseTableView.tableHeaderView = self.singleHeaderView;
        }
            break;
        case MangerType_invalid:
            self.baseTableView.tableHeaderView = self.invalidHeaderView;
            break;
        default:
            self.baseTableView.tableHeaderView = self.validHeaderView;
            break;
    }
}

- (void) presentLoginVC
{
    [self.navigationController presentViewController:[ControllerFactory controllerWithName:@"LoginViewController" xib:YES] animated:YES completion:^{}];
}

//活动是否过期
- (BOOL) isActivityValid:(Activity *)act
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval curTime = [currentDate timeIntervalSince1970];
    
    return ((curTime - ([act.endDate floatValue]) > VALIDTIME)?NO:YES);
}


- (NSArray *) getActivityListArray
{
    switch (self.type) {
        case MangerType_single:
        {
            return ((_singleAct == nil)?@[]:@[_singleAct]);
            
        }
            break;
        case MangerType_valid:
            return _event_valid_array;
            break;
        case MangerType_invalid:
            return _event_invalid_array;
        default:
            return @[];
            break;
    }
}
#pragma mark - buttonAction -

- (void) navPrintClick
{
    BlueToothCenter *center = PROJECT_BLUETOOTHCENTER;
    [self.navigationController presentViewController:[center presentNavigationVC] animated:YES completion:^{}];
}

- (IBAction)addNewEvent:(id)sender {
    [self.navigationController pushViewController:[ControllerFactory controllerWithName:@"AddEventVC"] animated:YES];
}
- (IBAction)nextStep:(id)sender {
//    if (self.type == MangerType_invalid) {
//        [GlobalConfig showAlertViewWithMessage:@"活动已过期，无法验票" superView:nil];
//        return;
//    }
    BaseViewController *ctl = (BaseViewController *)[ControllerFactory controllerWithName:@"SelectTicketTypeVC" xib:YES];
    ctl.dataArray = (NSMutableArray *)[self getActivityListArray];
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark - tableViewDelegate -

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getActivityListArray].count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [HomeCell cellHeightWithModel:[self getActivityListArray][indexPath.row] index:indexPath.row];
    return height;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:homeCellID];
    [cell setValueForCell:[self getActivityListArray][indexPath.row] index:indexPath.row];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.type == MangerType_single) {
        [self nextStep:nil];
    }
}

@end
