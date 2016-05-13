//
//  SelectTicketTypeVC.m
//  EventLite
//
//  Created by 魔时网 on 15/1/30.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "SelectTicketTypeVC.h"
#import "TicketCheckViewController.h"
#import "WSNumberKeyBoard.h"    

@interface SelectTicketTypeVC ()
{
    NSMutableArray *_stateArray;
    NSMutableArray *_selectTypeArray;
}

@property (weak, nonatomic) IBOutlet UIView *eventListView;
@property (assign, nonatomic) BOOL  isSelctAll;

@end

@implementation SelectTicketTypeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBarWithLeftBarItem:MoshNavigationBarItemBack rightBarItem:MoshNavigationBarItemNone title:NAVTITLE_SELECT_TICKE_TTYPE];
    [self createBarWithName:BUTTON_ALLSELECT navBarType:NavBarType_right titleColor:WHITECOLOR action:@selector(selectAll)];
    self.isSelctAll = NO;
    [self updateLeftButton];
    
    _selectTypeArray = [NSMutableArray array];
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.eventListView addSubview:self.baseTableView];
    [self.baseTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *dic = @{@"_baseTableView":self.baseTableView};
    NSString *vfv = @"V:|-0-[_baseTableView]-0-|";
    NSString *vfh = @"H:|-0-[_baseTableView]-0-|";
    [self.eventListView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfv options:0 metrics:nil views:dic]];
    [self.eventListView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vfh options:0 metrics:nil views:dic]];

    
    [self downloadData];
    
    self.ticketTypeSearchBar.keyboardType = UIKeyboardTypeAlphabet;
    
//    NSArray *searchBarSubViews = [[self.ticketTypeSearchBar.subviews objectAtIndex:0] subviews];
//    for(int i =0; i<[searchBarSubViews count]; i++) {
//        if([[searchBarSubViews objectAtIndex:i] isKindOfClass:[UITextField class]])
//        {
//            UITextField* search=(UITextField*)[searchBarSubViews objectAtIndex:i];
//            search.inputView = [[WSNumberKeyBoard alloc] initWithControlTextField:search ReturnButtonName:nil andClickBlock:^(UITextField *textField) {
//                [self doneButton];
//                
//            }];
//            
//        }
//    }
//    [self.ticketTypeSearchBar reloadInputViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) downloadData
{
    [self showLoadingView];
    
    for(Activity *act in self.dataArray) {
        act.tickedTypeArray = [DATABASE_INSTANCE getTicketListWhereEid:act.eid eventTitle:act.title];
    }
    [self hideLoadingView];
    [self.baseTableView reloadData];
}

- (IBAction)nextStep:(id)sender {

    if (_selectTypeArray.count < 1) {
        
        [GlobalConfig alert:CONFIG_LOSE_TICKET];
        
    } else {
        
        TicketCheckViewController *viewController = [[TicketCheckViewController alloc] init];
        viewController.title = @"验票";
        viewController.selectList = _selectTypeArray;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
}

-(void)selectAll {
    
    if (self.isSelctAll) {
        self.isSelctAll = NO;
        [_selectTypeArray removeAllObjects];
    }
    else {
        self.isSelctAll = YES;
        [_selectTypeArray removeAllObjects];
        
        for (Activity  *act in self.dataArray) {
            if (act.tickedTypeArray.count > 0) {
                [_selectTypeArray addObjectsFromArray:act.tickedTypeArray];
            }
        }
    }
    [self updateLeftButton];
    [self.baseTableView reloadData];
}

- (void) updateLeftButton
{
    NSString *title = BUTTON_ALLSELECT;
    if (self.isSelctAll) {
        title = BUTTON_ALLDEL;
    }
        self.navigationItem.rightBarButtonItem.title = title;
}



#pragma mark - Table view data source -

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Activity *act = self.dataArray[section];
    return act.tickedTypeArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Activity *act = self.dataArray[section];
    UILabel *label = [GlobalConfig createLabelWithFrame:CGRectMake(0, 0, self.baseTableView.frame.size.width, 30) Text:[NSString stringWithFormat:@"活动%d：%@",section+1,act.title] FontSize:14 textColor:[UIColor darkTextColor]];
    label.backgroundColor = [UIColor colorWithRed:243/255.0f green:240/255.0f blue:243/255.0f alpha:1];

    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Activity *act = self.dataArray[indexPath.section];
    TicketType *tType = act.tickedTypeArray[indexPath.row];
    
    
    cell.textLabel.text = tType.tTypeName;
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.accessoryType = UITableViewCellSelectionStyleNone;
    
    
    for (TicketType *t in _selectTypeArray) {
        
        if ([t.tTypeID isEqualToString:tType.tTypeID]) {
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Activity *act = self.dataArray[indexPath.section];
    TicketType *tType = act.tickedTypeArray[indexPath.row];
    
    BOOL insert = NO;
    
    for (TicketType *ticket in _selectTypeArray) {
        
        
        if ([ticket.tTypeID isEqualToString:tType.tTypeID]) {
            //
            insert = YES;
        }
    }
    
    if (insert) {
        
        [_selectTypeArray removeObject:tType];
        
    } else {
        
        [_selectTypeArray addObject:tType];
    }
    
    [self.baseTableView reloadData];
    
//    [self updateLeftButton];
}


-(void) doneButton {
    
    [self.ticketTypeSearchBar resignFirstResponder];
    
//    NSString *ticketID = [self getDatabaseTicketID:self.selectList];
    
    NSMutableArray *tempArr = [NSMutableArray arrayWithCapacity:0];
    
    for (Activity *act in self.dataArray) {

        act.tickedTypeArray = [[MoshTicketDatabase sharedInstance] searchTicketClass:self.ticketTypeSearchBar.text eid:act.eid];
        [tempArr addObject:act];
    }
    
    self.dataArray = tempArr;
    
    [self.baseTableView reloadData];
//    [self.baseTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self doneButton];
}
@end
