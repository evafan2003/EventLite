//
//  OrderCell.h
//  EventLite
//
//  Created by 魔时网 on 14/12/19.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ticket.h"  

@interface OrderCell : UITableViewCell

@property (strong, nonatomic) Ticket *model;
@property (weak, nonatomic) IBOutlet UILabel *checkNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

- (IBAction)onClickCheckButton:(id)sender;
- (void) setValueForCell:(Ticket *)ticket;
@end
