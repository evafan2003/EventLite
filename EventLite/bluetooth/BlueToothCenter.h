//
//  BuleToothCenter.h
//  EventLite
//
//  Created by 魔时网 on 14/12/8.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSBlueToothManger.h"   
#import "BlueToothNavigationVC.h"
#import "BTHomeVC.h"
#import "Ticket.h"

@interface BlueToothCenter : NSObject<WSBlueToothMangerDelegate>

- (void) openBluetooth;

- (BlueToothNavigationVC *) presentNavigationVC;

- (void) printTicket:(Ticket *)ticket;

@end
