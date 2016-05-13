//
//  OrderView.h
//  EventLite
//
//  Created by 魔时网 on 14/12/19.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderView : UIView<UITableViewDataSource,UITableViewDelegate>

+ (void) showOrderViewWithTIcketsArray:(NSArray *)ticketsArray;
@property (weak, nonatomic) IBOutlet UIView *testView;

@end
