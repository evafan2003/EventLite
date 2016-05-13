//
//  UserInfoViewController.m
//  moshTickets
//
//  Created by 魔时网 on 14-2-18.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "UserInfoViewController.h"
#import "ControllerFactory.h"
#import "UserInfoCell.h"
#import "MoshTicketDatabase.h"

static CGFloat cellHeight = 70;
//static CGFloat LabelSpace = 5;

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 -(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createBarWithLeftBarItem:MoshNavigationBarItemUserExited rightBarItem:MoshNavigationBarItemRefresh title:NAVTITLE_USERINFO];
    self.navigationItem.hidesBackButton = YES;
    NSArray *array = @[@{@"image":@"user_info2",@"title":@"订单数"},
                       @{@"image":@"user_info3",@"title":@"售票数"},
                       @{@"image":@"user_info5",@"title":@"已验票数"},
                       @{@"image":@"user_info4",@"title":@"销售额"},];
    self.dataArray = [NSMutableArray arrayWithArray:array];
    self.baseTableView.tableHeaderView = self.headView;
    self.baseTableView.tableFooterView = self.footView;
    [self downloadData];
    
//    //当有新票时更新总票数信息
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTicketLabel) name:NOTI_TICKET_USEDUPDATE object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//更新票总数label
-(void) changeTicketLabel {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
//        int usedCount = [[MoshTicketDatabase sharedInstance] getAllTicketCountByEid:self.act.eid status:ticketState_isUsed ticketID:nil];
//        int totalCount = [[MoshTicketDatabase sharedInstance] getAllTicketCountByEid:self.act.eid status:nil ticketID:nil];
        
        
    });
    
}

- (void) navUserExitClick
{
    [GlobalConfig deleteUserInfo];
     [GlobalConfig push:YES viewController:[ControllerFactory loginInViewController] withNavigationCotroller:self.navigationController animationType:1 subType:1 Duration:DURATION];
}

- (void) downloadData
{
    //加载
    [self showLoadingView];
    
    [[HTTPClient shareHTTPClient] mainStatisticssuccess:^(UserInfo *info) {
                                              [self hideLoadingView];
                                              self.userInfo = info;
                                              [self reloadData];
                                              [self.baseTableView reloadData];
                                          } fail:^{
                                              [self hideLoadingView];
                                              
                                              [GlobalConfig showAlertViewWithMessage:ERROR_LOADINGFAIL superView:self.view];
                                          }];
    
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.dataArray[indexPath.row];

    static NSString *cellId = @"userCell";
    UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([UserInfoCell class]) owner:self options:nil] objectAtIndex:0];
    }
    cell.image.image = [UIImage imageNamed:dic[@"image"]];
    cell.title.text = dic[@"title"];
    
    if (self.userInfo) {
        switch (indexPath.row) {
            case 2:
                cell.number.text = [NSString stringWithFormat:@"%@/张",[GlobalConfig convertToString:@"0" withObject:self.userInfo.checkNumber]];
                break;
            case 0:
                cell.number.text = [NSString stringWithFormat:@"%@/单",[GlobalConfig convertToString:@"0" withObject:self.userInfo.peopleNumber]];
                break;
            case 1:
                cell.number.text = [NSString stringWithFormat:@"%@/张",[GlobalConfig convertToString:@"0" withObject:self.userInfo.saleNumber]];
                break;
            default:
                break;
        }
        if (indexPath.row == 3) {
            
            for (int i = 0;i< self.userInfo.totalPrice.count;i++) {
                if (i == 0) {
                    cell.number.text = self.userInfo.totalPrice[i];
                }
                else {
                    UILabel *label = [GlobalConfig createLabelWithFrame:CGRectOffset(cell.number.frame, 0, cell.number.frame.size.height * i) Text:self.userInfo.totalPrice[i] FontSize:17 textColor:[UIColor colorWithRed:37/255.0 green:169/255.0 blue:224/255.0 alpha:1]];
                    label.font = [UIFont boldSystemFontOfSize:17];
                    label.textAlignment = NSTextAlignmentRight;
                    [cell addSubview:label];
                }
                
            }
        }
    }
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == (self.dataArray.count - 1)) {
        return cellHeight + 30 * (self.userInfo.totalPrice.count - 1);
    }
    return cellHeight;
}

//- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self activityListButtonPress:nil];
//}


- (void) reloadData
{
    if (self.userInfo) {
        self.username.text = [NSString stringWithFormat:@"账号：%@",self.userInfo.username];
        
        if (![self.userInfo.actNumber isEqualToString:@"0"]) {
            self.alertLabel.hidden = YES;
        }
    }
}

-(void) navRefreshClick
{
    [self downloadData];
}



- (IBAction)activityListButtonPress:(id)sender {
    
//    [self.navigationController pushViewController:[ControllerFactory controllerWithCheckTIckets] animated:YES];
}

@end
