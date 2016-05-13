//
//  OrderCell.m
//  EventLite
//
//  Created by 魔时网 on 14/12/19.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "OrderCell.h"
#import "Ticket.h"  
#import "CheckTickets.h"    

@implementation OrderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setValueForCell:(Ticket *)ticket
{
    if (![ticket isKindOfClass:[Ticket class]]) {
        return;
    }
    self.model = ticket;
    self.checkNumberLabel.text = ticket.t_password;
    if ([ticket.t_state isEqualToString:ticketState_unUse]) {
        self.checkButton.enabled = YES;
        [self.checkButton setTitle:@"验票" forState:UIControlStateNormal];
        self.checkButton.backgroundColor = [UIColor colorWithRed:0 green:169/255.0f blue:238/255.0f alpha:1];
    }
    else {
        self.checkButton.enabled = NO;
        [self.checkButton setTitle:@"已验票" forState:UIControlStateNormal];
        self.checkButton.backgroundColor = [UIColor lightGrayColor];
    }
}

- (IBAction)onClickCheckButton:(id)sender {
    
    [CheckTickets checkTicket:self.model];
    
    self.checkButton.enabled = NO;
    self.model.t_state = ticketState_isUsed;
    [self.checkButton setTitle:@"已验票" forState:UIControlStateNormal];
    self.checkButton.backgroundColor = [UIColor lightGrayColor];

}
@end
