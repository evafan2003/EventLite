//
//  CheckSearchViewController.m
//  moshTickets
//
//  Created by 魔时网 on 14-3-10.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "CheckSearchViewController.h"
#import "MoshTicketDatabase.h"
#import "TicketDetailViewController.h"
#import "WSNumberKeyBoard.h"    

@interface CheckSearchViewController ()

@end

@implementation CheckSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.baseTableView.frame = CGRectMake(0, self.tableHeaderView.frame.size.height, SCREENWIDTH,SCREENHEIGHT - NAVHEIGHT - 38 - self.tableHeaderView.frame.size.height);
    MOSHLog(@"%f,%f",self.view.frame.size.height,self.view.frame.origin.y);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTicket];
    self.view.backgroundColor = CLEARCOLOR;
    self.baseTableView.backgroundColor = CLEARCOLOR;
    
    [self.view addSubview:self.tableHeaderView];
//    _mySearchBar.inputAccessoryView = [UIView new];
    
    NSArray *searchBarSubViews = [[self.mySearchBar.subviews objectAtIndex:0] subviews];
    for(int i =0; i<[searchBarSubViews count]; i++) {
        if([[searchBarSubViews objectAtIndex:i] isKindOfClass:[UITextField class]])
        {
            UITextField* search=(UITextField*)[searchBarSubViews objectAtIndex:i];
            search.inputView = [[WSNumberKeyBoard alloc] initWithControlTextField:search ReturnButtonName:nil andClickBlock:^(UITextField *textField) {
                [self doneButton];
                
            }];

        }
    }
    [self.mySearchBar reloadInputViews];

     //注册通知-刷新票列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTicket) name:NOTI_TICKET_LIST_REFRESH object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//加载票列表
-(void)loadTicket {

    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *ticketID = [self getDatabaseTicketID:self.selectList];
        
        self.ticketList = [[MoshTicketDatabase sharedInstance] searchTicket:[GlobalConfig convertToString:self.mySearchBar.text] eid:self.eid ticketID:ticketID];
        [self.baseTableView reloadData];

    });

}

- (void) viewResignFirstRespinder
{
    [self.mySearchBar resignFirstResponder];
}


#pragma -mark
#pragma TableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
        static NSString *theCell = @"cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:theCell];
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:theCell];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor grayColor];
            
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            cell.contentView.backgroundColor = CLEARCOLOR;
            cell.backgroundColor = CLEARCOLOR;
            
            
            UILabel *midLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 120, 35)];
            midLabel.font = [UIFont systemFontOfSize:14];
            midLabel.textColor = [UIColor grayColor];
            midLabel.backgroundColor = [UIColor clearColor];
            midLabel.tag = 27;
            [cell.contentView addSubview:midLabel];
        }
        
        Ticket *theTicket = [self.ticketList objectAtIndex:indexPath.row];
        UILabel *midLabel = (UILabel *)[cell.contentView viewWithTag:27];
        
        cell.textLabel.text = theTicket.t_password;
        
        if ([theTicket.use_date isEqualToString:@""] || [theTicket.use_date isEqualToString:@"0"]) {
            
            midLabel.text = nil;
        } else {
            midLabel.text = [NSString stringWithFormat:@"  %@",[GlobalConfig dateFormater:theTicket.use_date format:DATEFORMAT_05]];
            
        }
        
        int status = [theTicket.t_state intValue];
        if (status == 1) {
            //未使用
            cell.detailTextLabel.text = @"该票未使用";
            
        } else if (status == 2) {
            //已使用
            cell.detailTextLabel.text = @"该票已使用";
            
        } else {
            //过期
            cell.detailTextLabel.text = @"该票已过期";
        }
        
        return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
        return 35;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ticketList.count;
}

#pragma mark
#pragma UITableViewController Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

        TicketDetailViewController *viewController = [[TicketDetailViewController alloc] initWithNibName:@"TicketDetailViewController" bundle:nil];
        viewController.ticket = [self.ticketList objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewController animated:YES];
    
}

-(void) doneButton {
    
    [self.mySearchBar resignFirstResponder];
    
    NSString *ticketID = [self getDatabaseTicketID:self.selectList];
    
    self.ticketList = [[MoshTicketDatabase sharedInstance] searchTicket:self.mySearchBar.text eid:self.eid ticketID:ticketID];
    [self.baseTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
