//
//  BTHomeVC.m
//  EventLite
//
//  Created by 魔时网 on 14/12/8.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "BTHomeVC.h"
#import "Ticket.h"
#import "AppDelegate.h"     

static NSString *CellID =  @"scanCell";

@interface BTHomeVC ()
@property (weak, nonatomic) IBOutlet UIView *scanView;
@property (nonatomic, strong) WSBlueToothManger *manger;

@end

@implementation BTHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBarWithLeftBarItem:MoshNavigationBarItemBack rightBarItem:MoshNavigationBarItemNone title:@"打印机选项"];
    
    self.manger = [WSBlueToothManger shareBuleToothManger];
    
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:NOTI_PERIPHERALUPDATE object:nil];
    
}

- (void) navBackClick
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickprintTestButton:(id)sender {
    
    Ticket *tic = [Ticket new];
    tic.name = @"关少波";
    tic.tel = @"13911601321";
    tic.ticket_name = @"智慧营报名";
    tic.eventName = @"中国寺院数字智慧营";
    tic.t_password = @"1234567";
    
    BlueToothCenter *center = PROJECT_BLUETOOTHCENTER;
    [center printTicket:tic];
}
- (IBAction)onClickScanStartButton:(id)sender {
    
    [self.manger startScan];
    
}
- (IBAction)onClickScanStopButton:(id)sender {
    
    [self.manger stopScan];
}
- (IBAction)call:(id)sender {
     [GlobalConfig makeCall:@"4000630260"];
}

- (CGRect) returnBaseTableViewFrame
{
    return CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - NAVHEIGHT - CGRectGetHeight(self.scanView.frame));
}

- (UITableViewStyle) returnBaseTableViewStyle
{
    return UITableViewStyleGrouped;
}

- (void) reloadData
{
    [self.baseTableView reloadData];
}

- (void) showAlertView:(NSString *)alertText
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -40, 320, 40)];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    label.text = alertText;
    label.textColor = [UIColor whiteColor];
    [self.view addSubview:label];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = label.layer.frame;
        rect.origin.y = 0;
        label.layer.frame = rect;
    } completion:^(BOOL finish){
        [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2];
    }];
}


#pragma mark - uitableViewDelegate -
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [self tableView:tableView heightForHeaderInSection:section])];
    label.backgroundColor = [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1];
    label.text = @"周边设备列表";
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = BLACKCOLOR;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.manger.peripheralArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        
        UILabel *button = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - 80 - 20), (44 - 30)/2,80 , 30)];
        button.backgroundColor = [UIColor clearColor];
        button.tag = 101;
        button.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:button];
    }
    
    peripheralModel *model = self.manger.peripheralArray[indexPath.row];
    cell.textLabel.text = model.name;
    
    UILabel *label = (UILabel *)[cell viewWithTag:101];
    label.textColor = WHITECOLOR;
    if (label && model) {
        if (model.isConnectable) {
            label.backgroundColor = [UIColor greenColor];
            label.text = @"已连接";
        }
        else {
            label.backgroundColor = [UIColor redColor];
            label.text = @"未连接";
        }
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    peripheralModel *model = self.manger.peripheralArray[indexPath.row];
    [self.manger connectPeripheral:model options:nil];
}


@end
