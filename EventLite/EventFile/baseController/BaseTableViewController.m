//
//  BaseTableViewController.m
//  modelTest
//
//  Created by mosh on 13-10-21.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import "BaseTableViewController.h"
#import "GlobalConfig.h"


@interface BaseTableViewController ()
{
    EGORefreshTableHeaderView *_emptyHeader;
}
@end

@implementation BaseTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id) initWithData:(NSMutableArray *)array
{
    if (self = [super init]) {
        self.dataArray = array;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化
    self.cellHeight = 44;
    self.hasMore = YES;//如果有分页 将hasmore设为yes
    self.page = 1;
	
    //tableView
    [self createTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//私有方法 不需要写在.h文件中
#pragma privateAction
- (void) createTableView
{
    self.baseTableView = [[UITableView alloc] initWithFrame:[self returnBaseTableViewFrame] style:[self returnBaseTableViewStyle]];
    
    self.baseTableView.delegate = self;
    self.baseTableView.dataSource = self;
    self.baseTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.baseTableView.backgroundColor = [UIColor clearColor];
    self.baseTableView.backgroundView = nil;
    [self.view addSubview:self.baseTableView];
}


//受保护方法 继承类可用
#pragma protectAction

//改变tableview的frame
- (CGRect) returnBaseTableViewFrame
{
    return CGRectMake(POINT_X, POINT_Y, SCREENWIDTH, SCREENHEIGHT - STATEHEIGHT - NAVHEIGHT);
}
//改变tableView的类型
- (UITableViewStyle) returnBaseTableViewStyle
{
    return UITableViewStylePlain;
}

- (void) reloadWithData:(NSMutableArray *)array
{
    [self hideLoadingView];
    self.dataArray = [NSMutableArray new];
    [self.dataArray addObjectsFromArray:array];
    [self.baseTableView reloadData];
}

//列表加载完成
-(void)listFinishWithDataArray:(NSArray *)tmpArr emptyAlert:(NSString *)emptyAlert {
    
    if (tmpArr != nil) {
        if (tmpArr.count == 0 && self.page == 1) {
            
            [self reloadWithData:tmpArr];
            [GlobalConfig showAlertViewWithMessage:emptyAlert superView:self.view];
        }
        else {
            
            if (self.page == 1) {
                [self reloadWithData:tmpArr];
            }else {
                [self.dataArray addObjectsFromArray:tmpArr];
                [self.baseTableView reloadData];
            }
            if (tmpArr.count < 10) {
                self.hasMore = NO;
            } else {
                self.page++;
            }
//            if (self.request.isSuccess == NO) {
//                [GlobalConfig showAlertViewWithMessage:ERROR_LOADINGFAIL superView:self.view];
//            }
        }
    }else{
        self.hasMore = NO;
    }
    [self hideLoadingView];
    
    if (self.emptyView) {
        if (![GlobalConfig isKindOfNSArrayClassAndCountGreaterThanZero:self.dataArray]) {
            self.baseTableView.hidden = YES;
            self.emptyView.hidden = NO;
        }
        else {
            self.baseTableView.hidden = NO;
            self.emptyView.hidden = YES;
        }
    }
}



//加载更多
//color为nil代表不需要显示“加载更多“内容
- (void) downloadMore:(NSIndexPath *)indexPath textColor:(UIColor *)color
{
    if (indexPath.row == self.dataArray.count-1) {
        if (self.hasMore) {
            //显示加载更多
            if (color) {
                UILabel *label = [GlobalConfig createLabelWithFrame:CGRectMake(0, 0, self.baseTableView.frame.size.width,30) Text:LOADINGMORE FontSize:15 textColor:color];
                self.baseTableView.tableFooterView = label;
            }
            //加载数据
            [self downloadData];
        }
        else {
            self.baseTableView.tableFooterView = nil;
        }
    }
}



#pragma tableViewDataSouce
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
}

#pragma  tableViewDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//公共方法
#pragma publicAction
//添加下拉刷新
-(void)addEGORefreshOnTableView:(UITableView *)tableView{
    
    self.isLoading = NO;
    self.headerView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, tableView.frame.size.width, tableView.bounds.size.height)];
	self.headerView.delegate = self;
    self.headerView.backgroundColor = BACKGROUND;
	[tableView addSubview:self.headerView];
}

- (void) addEmptyViewWithAlertContent:(NSString *)content AlertImageName:(NSString *)name
{
    self.emptyView = [[EmptyView alloc] initWithFrame:self.baseTableView.frame];
    self.emptyView.contentSize = CGSizeMake(CGRectGetWidth(self.emptyView.frame), CGRectGetHeight(self.emptyView.frame) + 1);
    self.emptyView.delegate = self;
    [self.emptyView setAlertContent:content alertImageName:name];
    
    _emptyHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.emptyView.bounds.size.height, self.emptyView.frame.size.width, self.emptyView.bounds.size.height)];
	_emptyHeader.delegate = self;
    self.emptyView.hidden = YES;
    _emptyHeader.backgroundColor = BACKGROUND;
	[self.emptyView addSubview:_emptyHeader];
    [self.view addSubview:self.emptyView];
}

//创建搜索栏
- (void) createSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    self.searchBar.backgroundImage = [UIImage imageNamed:@"search_bar"];
    self.searchBar.backgroundColor = WHITECOLOR;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = PLACE_SEARCH;
    self.baseTableView.tableHeaderView = self.searchBar;
}

- (void)scrollToTopAnimated:(BOOL)animated {
    
    [self.baseTableView setContentOffset:CGPointMake(0,0) animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    if (self.baseTableView.contentOffset.y > 0) {
        [self.baseTableView setContentOffset:CGPointMake(0, self.baseTableView.contentSize.height -self.baseTableView.bounds.size.height) animated:animated];
    }
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.isLoading = YES;
	[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(refresh) userInfo:nil repeats:NO];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.isLoading; // should return if data source model is reloading
}


- (NSDate *) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //判断结束拖拽时的偏移量
    [self.headerView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //读取开始拖拽时的位置
    [self.headerView egoRefreshScrollViewDidScroll:scrollView];
}

- (void) refresh
{
    [self.headerView egoRefreshScrollViewDataSourceDidFinishedLoading:self.baseTableView];
    [_emptyHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.emptyView];
    [self showLoadingView];
    self.isLoading = NO;
   
    //加载内容
    self.page = 1;
    self.hasMore = YES;
    [self downloadData];
    
}

@end
