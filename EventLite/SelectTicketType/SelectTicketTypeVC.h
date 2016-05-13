//
//  SelectTicketTypeVC.h
//  EventLite
//
//  Created by 魔时网 on 15/1/30.
//  Copyright (c) 2015年 mosh. All rights reserved.
//

#import "BaseTableViewController.h"

@interface SelectTicketTypeVC : BaseTableViewController<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *ticketTypeSearchBar;

@end
