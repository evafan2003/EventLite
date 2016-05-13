//
//  CheckBarCodeViewController.m
//  moshTickets
//
//  Created by 魔时网 on 14-3-10.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "CheckBarCodeViewController.h"
#import "MoshTicketDatabase.h"  
#import "CheckTickets.h"
#import "NSString+Encryption.h"
#import "OrderView.h"

static  CGFloat barCodeTableViewHeight = 380.0f;

@interface CheckBarCodeViewController ()

@end

@implementation CheckBarCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = CLEARCOLOR;
    UIButton *button = [GlobalConfig createButtonWithFrame:CGRectMake(107, 40, 106, 38) ImageName:@"blue" Title:@"验票" Target:self Action:@selector(barCodeScanPressed:)];
    [button setBackgroundImage:[UIImage imageNamed:@"bluePressed"] forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    [self createBarCodeTableView];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createBarCodeTableView
{
    if (!self.barCodeTableView) {
        self.barCodeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,SCREENHEIGHT, SCREENWIDTH, barCodeTableViewHeight) style:UITableViewStylePlain];
        self.barCodeTableView.dataSource = self;
        self.barCodeTableView.delegate = self;
        self.barCodeTableView.separatorStyle = UITableViewCellSelectionStyleNone;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
        
        UIButton *button = [GlobalConfig createButtonWithFrame:CGRectMake(107,50 - 38, 106, 38) ImageName:@"blue" Title:@"继续验票" Target:self Action:@selector(continueCheckTicket)];
        [button setBackgroundImage:[UIImage imageNamed:@"bluePressed"] forState:UIControlStateHighlighted   ];
        [view addSubview:button];
        self.barCodeTableView.tableFooterView = view;
        self.barCodeTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20)];
        [[UIApplication sharedApplication].keyWindow addSubview:self.barCodeTableView];
    }
}

- (void) checkTicketWithPassword:(NSString *)password
{
    NSString *ticketID = [self getDatabaseTicketID:self.selectList];

   self.ticket = [[MoshTicketDatabase sharedInstance] getOneTicket:password eid:self.eid ticketID:ticketID];

    
    if (!self.ticket) {
        self.ticket = [[Ticket alloc] init];
        self.ticket.t_state = ticketState_unExist;
    }
    
    [self.barCodeTableView reloadData];
    [self showBarTableView];
    
    if ([self.ticket.t_state isEqualToString:ticketState_unUse]) {
        [CheckTickets checkTicket:self.ticket];
    }
    
#warning 订单验票 未验证 暂不开放
//    if (self.ticket) {
//        NSArray *orderArray = [[MoshTicketDatabase  sharedInstance] searchAllOrderTicketsWithEid:self.ticket.eid oid:self.ticket.oid ticketID:ticketID];
//        if (orderArray.count > 1) {
//            [OrderView showOrderViewWithTIcketsArray:orderArray];
//        }
//    }
}

- (void) showBarTableView
{
    if (self.barCodeTableView.frame.origin.y >= SCREENHEIGHT) {
        [UIView animateWithDuration:0.5 animations:^{
            self.barCodeTableView.frame = CGRectMake(0, SCREENHEIGHT - barCodeTableViewHeight, SCREENWIDTH, barCodeTableViewHeight);
        }];
    }
}

- (void) hiddenBarTableView
{
    if (self.barCodeTableView.frame.origin.y <= SCREENHEIGHT - barCodeTableViewHeight) {
        [UIView animateWithDuration:0.5 animations:^{
            self.barCodeTableView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, barCodeTableViewHeight);
        }];
    }
}

- (void) continueCheckTicket
{
    [self hiddenBarTableView];
    self.isChecking = NO;
}

#pragma -mark
#pragma TableView DataSource

#pragma  mark - buttonClick -
//条码扫描
- (void)barCodeScanPressed:(id)sender {
    
    _scannerController = [[BarCodeScannerViewController alloc] initWithNibName:@"BarCodeScannerViewController" bundle:nil];
    _scannerController.barCodeScannerDelegate = self;
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:_scannerController];
    [self presentViewController:navController animated:YES completion:^{}];
}

#pragma -marks
#pragma BarCodeScannerViewControllerDelegate
//条码扫描结果搜索
- (void) ProcessBarCodeScannerResult:(BarCodeScannerViewController *)sender withInfo: (NSDictionary*) info {
    UIImage *image = [info objectForKey: UIImagePickerControllerOriginalImage];
	
    if (self.isChecking) {
        return;
    }
    self.isChecking = YES;
    [_scannerController playBeep];
    id <NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *sym = nil;
    for(sym in results)
        break;
    assert(sym);
    assert(image);
    if(!sym || !image) {
        return;
    }
    
    [self checkTicketWithPassword:sym.data];
    
}

- (void) barCodeScannerViewControllerDismissModelViewController
{
    self.isChecking = NO;
    [self hiddenBarTableView];

}


#pragma -mark
#pragma TableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //正常验票
    if (indexPath.section == 0) {
        
        static NSString *CellIdentifier = @"cell1";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:22];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
        if (indexPath.row == 0) {
            
            if ([self.ticket.t_state isEqualToString:ticketState_unExist]) {
                
                //无效
                cell.textLabel.text = @"该票不存在 ×";
                cell.textLabel.textColor = [UIColor redColor];
                
            }else if ([self.ticket.t_state isEqualToString:ticketState_unUse]) {
                //正确
                cell.textLabel.text = @"￼验票通过 √";
                cell.textLabel.textColor = [UIColor greenColor];
                
            } else {
                //过期
                cell.textLabel.textColor = [UIColor orangeColor];
                cell.textLabel.text = @"该票已使用";
            }
            
        }
        return cell;
        
    } else {
        
        static NSString *CellIdentifier = @"cell2";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = [UIColor grayColor];
            
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor grayColor];
            
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if ([self.ticket.t_state isEqualToString:ticketState_unExist]) {
            
            //无效
            cell.textLabel.text = @"      ";
            cell.detailTextLabel.text = @"该验票码错误";
            
        }
        else  {
            //有效
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"票种：";
                    cell.detailTextLabel.text = ([self.ticket.ticket_name isEqualToString:@""]) ? @"暂无" : self.ticket.ticket_name;
                    break;
                case 1:
                    cell.textLabel.text = @"密码：";
                    cell.detailTextLabel.text = ([self.ticket.t_password isEqualToString:@""]) ? @"暂无" : self.ticket.t_password;
                    break;
                case 2:
                    cell.textLabel.text = @"价格：";
                    cell.detailTextLabel.text = ([self.ticket.t_price isEqualToString:@""]) ? @"暂无" : self.ticket.t_price;
                    break;
                case 3:
                    cell.textLabel.text = @"手机：";
                    cell.detailTextLabel.text = ([self.ticket.tel isEqualToString:@""]) ? @"暂无" : [self.ticket.tel phoneNumberEncryption];
                    break;
                case 4:
                    cell.textLabel.text = @"邮箱：";
                    cell.detailTextLabel.text = ([self.ticket.email isEqualToString:@""]) ? @"暂无" : [self.ticket.email emailEncryption];
                    
                    break;
                case 5:
                    cell.textLabel.text = @"姓名：";
                    cell.detailTextLabel.text = ([self.ticket.name isEqualToString:@""]) ? @"暂无" : [self.ticket.name nameEncryption];
                    break;
                case 6:
                    cell.textLabel.text = @"身份证号：";
                    cell.detailTextLabel.text = ([self.ticket.idCard isEqualToString:@""]) ? @"暂无" : self.ticket.idCard;
                    break;
                case 7:
                {
                    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.ticket.seatinfo]) {
                        cell.textLabel.text = @"座位：";
                        cell.detailTextLabel.text = self.ticket.seatinfo;
                    } else if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.ticket.remark]) {
                        cell.textLabel.text = @"备注：";
                        cell.detailTextLabel.text = self.ticket.remark;
                    } else {
                        cell.textLabel.text = @"使用时间：";
                        cell.detailTextLabel.text =[GlobalConfig dateFormater:self.ticket.use_date format:DATEFORMAT_05];
                    }
                    break;
                }
                case 8:
                {
                    if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.ticket.seatinfo]) {
                        cell.textLabel.text = @"备注：";
                        cell.detailTextLabel.text = self.ticket.remark;
                    } else {
                        cell.textLabel.text = @"使用时间：";
                        cell.detailTextLabel.text =[GlobalConfig dateFormater:self.ticket.use_date format:DATEFORMAT_05];
                    }
                }
                case 9:
                {
                    cell.textLabel.text = @"使用时间：";
                    cell.detailTextLabel.text =[GlobalConfig dateFormater:self.ticket.use_date format:DATEFORMAT_05];
                    break;
                }
                default:
                    break;
            }
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  (indexPath.section == 0)?34:30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.ticket == nil) {
        return 0;
        
    } else {
        
        if (section == 0) {
            return 1;
            
        } else {
            
            if ([self.ticket.t_state isEqualToString:ticketState_unExist]) {
                return 1;
            } else {
                NSInteger number = 7;
                if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.ticket.seatinfo]) {
                    number += 1;
                }
                if ([GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:self.ticket.remark]) {
                    number += 1;
                }
                if ([self.ticket.t_state isEqualToString:ticketState_isUsed]){
                    number += 1;
                }
                return number;
            }
        }
    }
}



@end
