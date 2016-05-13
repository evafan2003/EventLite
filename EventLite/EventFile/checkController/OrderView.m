//
//  OrderView.m
//  EventLite
//
//  Created by 魔时网 on 14/12/19.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "OrderView.h"
#import "OrderCell.h"   
#import "CheckTickets.h"    
#import "AnimaitonManger.h" 

static NSInteger BtnTag_allcheck = 101;
//static NSInteger BtnTag_cancle = 102;

@interface OrderView()

@property (nonatomic, strong) NSArray *TicketsArray;
@property (nonatomic, strong) UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *listView;
- (IBAction)onClickButton:(id)sender;

@end;

@implementation OrderView

- (id) initWithFrame:(CGRect)frame ticketsList:(NSArray *)listArray
{
    if (self =[ super init]) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
        self.frame = frame;
        self.testView.layer.cornerRadius = 10;
        self.testView.layer.shadowRadius = 3;
        self.testView.layer.shadowColor = BLACKCOLOR.CGColor;
        self.testView.layer.shadowOpacity = 0.5;
        self.testView.layer.shadowOffset = CGSizeMake(0, 3);
        
        self.TicketsArray = listArray;
        [self createListTableView];
    }
    return self;
}

- (void) createListTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.listView.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = CLEARCOLOR;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.listView addSubview:_tableView];
}

- (IBAction)onClickButton:(UIButton *)sender {
    if (sender.tag == BtnTag_allcheck) {
        [self check];
    }
    else {
        [self cancle];
    }
}

- (void) cancle
{
    [self hidden];
}

- (void) check
{
    for(Ticket *ticket in self.TicketsArray) {
        if ([ticket.t_state isEqualToString:ticketState_unUse]) {
            ticket.t_state = ticketState_isUsed;
            [CheckTickets checkTicket:ticket];
        }
    }
    [self.tableView reloadData];
}

- (void) show
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.center = window.center;
    
//    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    basic.fromValue = [NSNumber numberWithFloat:1.0];
//    basic.toValue = [NSNumber numberWithFloat:1.2];
//    basic.duration = 0.3;
//    [self.layer addAnimation:basic forKey:@""];
    
    [AnimaitonManger exChangeOut:self.testView dur:0.5];
}

- (void) hidden
{
    [self  removeFromSuperview];
}

+ (void) showOrderViewWithTIcketsArray:(NSArray *)ticketsArray
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    OrderView *view = [[OrderView alloc] initWithFrame:window.bounds ticketsList:ticketsArray];
    [window addSubview:view];
    [view show];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidden];
}

#pragma mark - tableViewDelegate -
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.TicketsArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"orderCell";
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([OrderCell class]) owner:nil options:nil] objectAtIndex:0];
    }
    
    [cell setValueForCell:self.TicketsArray[indexPath.row]];
    return cell;
}

@end
