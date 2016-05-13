//
//  TicketCheckViewController.m
//  MoshTicket
//
//  Created by evafan2003 on 12-6-15.
//  Copyright (c) 2012年 bbdtek. All rights reserved.
//

#import "TicketCheckViewController.h"
#import "GlobalConfig.h"
#import "MoshTicketDatabase.h"  
#import "StatisticVC.h" 

#define SEGMENT_TAG 20

@interface TicketCheckViewController ()

@end

@implementation TicketCheckViewController

//验票页面
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createBarWithLeftBarItem:MoshNavigationBarItemBack rightBarItem:MoshNavigationBarItemNone title:NAVTITLE_CHECK];
    [self createBarWithName:@"统计" navBarType:NavBarType_right titleColor:WHITECOLOR action:@selector(onClickStatistic)];
    
    [self loadTicket];

    //注册通知-更新票数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTicket) name:NOTI_TICKET_USEDUPDATE object:nil];

    [self initSubViews];
     [self createChildrenControllers];
    [self segmentClickedAtIndex:0 onCurrentCell:YES from:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubViews {
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,320.0f, 38.0f)];
    topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab"]];
    
    //段选择器
    PLSegmentView *segmentView = [[PLSegmentView alloc] initWithFrame:CGRectMake(0.0f, -6.0f, 320.0f, 38.0f)];
    segmentView.delegate = self;
    segmentView.segmentType = segmentTypeDefault;
    NSArray *textShow = [NSArray arrayWithObjects:@"电子票检票",@"二维码检票",@"手机号查询", nil];
    [segmentView setupCellsByTextShow:textShow offset:CGSizeMake(107.0f, 0.0f)];
    segmentView.selectedIndex = 0;
    segmentView.tag = SEGMENT_TAG;
    [topView addSubview:segmentView];
    [self.view addSubview:topView];
    
}

- (void) createChildrenControllers
{
    _checkSearchCtl = (CheckSearchViewController *)[CheckSearchViewController viewControllerWithNib];
    _checkSearchCtl.eid = self.eid;
    _checkSearchCtl.selectList = self.selectList;
    _checkSearchCtl.view.frame = CGRectMake(0, 38, SCREENWIDTH, SCREENHEIGHT - 38);
    [self.view addSubview:_checkSearchCtl.view];
    [self addChildViewController:_checkSearchCtl];
    
    _checkBarCodeCtl =(CheckBarCodeViewController *) [CheckBarCodeViewController viewControllerWithNib];
    _checkBarCodeCtl.eid = self.eid;
    _checkBarCodeCtl.selectList = self.selectList;
        _checkBarCodeCtl.view.frame = CGRectMake(0, 38, SCREENWIDTH, SCREENHEIGHT  - 38);

    [self.view addSubview:_checkBarCodeCtl.view];
    [self addChildViewController:_checkBarCodeCtl];
    
    _checkPasswordCtl = (CHeckPasswordViewController *)[CHeckPasswordViewController viewControllerWithNib];
    _checkPasswordCtl.eid = self.eid;
    _checkPasswordCtl.selectList = self.selectList;
        _checkPasswordCtl.view.frame = CGRectMake(0, 38, SCREENWIDTH, SCREENHEIGHT  - 38);

    [self.view addSubview:_checkPasswordCtl.view];
    [self addChildViewController:_checkPasswordCtl];
}



//更新标题票数
-(void)loadTicket {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *ticketID = [self getDatabaseTicketID:self.selectList];
        
        int usedCount = [[MoshTicketDatabase sharedInstance] getAllTicketCountByEid:self.eid status:ticketState_isUsed ticketID:ticketID];
        int totalCount = [[MoshTicketDatabase sharedInstance] getAllTicketCountByEid:self.eid status:nil ticketID:ticketID];

            self.title = [NSString stringWithFormat:@"已检%i张/总%i张",usedCount,totalCount];
        
    });
}

- (void) onClickStatistic
{
    StatisticVC *ctl = [[StatisticVC alloc] init];
    ctl.selectTypeArray = self.selectList;
    [self.navigationController pushViewController:ctl animated:YES];
}

#pragma mark -
#pragma mark PLSegmentView delegate

- (void)segmentClickedAtIndex:(int)index onCurrentCell:(BOOL)isCurrent from:(id)sender
{
    if (index==2) {
        //注册通知-刷新票列表
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_TICKET_LIST_REFRESH object:nil];

    }
    NSArray *array = @[_checkPasswordCtl,_checkBarCodeCtl,_checkSearchCtl];
    for (UIViewController *ctl in array) {
        if ([array indexOfObject:ctl] == index) {
                ctl.view.hidden = NO;
        }
        else {
            ctl.view.hidden = YES;
        }
    }

    [_checkPasswordCtl viewResignFirstRespinder];
    [_checkSearchCtl viewResignFirstRespinder];
}


@end
