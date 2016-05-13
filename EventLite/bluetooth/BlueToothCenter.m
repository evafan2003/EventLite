//
//  BuleToothCenter.m
//  EventLite
//
//  Created by 魔时网 on 14/12/8.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "BlueToothCenter.h"
#import "GlobalConfig.h"

@interface BlueToothCenter()

@property (nonatomic, strong) WSBlueToothManger *manger;

@end

@implementation BlueToothCenter

- (id) init
{
    if (self = [super init]) {

    }
    
    return self;
}

- (void) openBluetooth
{
    [self initalizeData];
}

- (void) initalizeData
{
    self.manger = [WSBlueToothManger shareBuleToothManger];
    self.manger.delegate = self;
}

- (BlueToothNavigationVC *) presentNavigationVC
{
    BTHomeVC *ctl = [BTHomeVC new];
    BlueToothNavigationVC *nav = [[BlueToothNavigationVC alloc] initWithRootViewController:ctl];
    [self openBluetooth];
    return nav;
}

- (void) printTicket:(Ticket *)ticket
{
    if (self.manger.connectPeripheral) {
        
        static NSInteger i;
        if (i == 0) {
            NSMutableString *str = [NSMutableString new];
            NSData * theData = [NSData data];
            //发送指令 ASCII 16*16
            [str appendFormat:@"%c",0x1B];
            [str appendFormat:@"%c",0x4D];
            [str appendFormat:@"%c",0x01];
            theData = [str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
            [self.manger writeValue:theData];
            
            //发送指令 二倍
            str = [NSMutableString new];
            [str appendFormat:@"%c",0x1D];
            [str appendFormat:@"%c",0x21];
            [str appendFormat:@"%c",0x11];
            theData = [str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
            [self.manger writeValue:theData];
            
            //发送指令 居中
            str = [NSMutableString new];
            [str appendFormat:@"%c",0x1B];
            [str appendFormat:@"%c",0x61];
            [str appendFormat:@"%c",0x01];
            theData = [str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
            [self.manger writeValue:theData];
            
            i++;
        }
        
//
        [self.manger writeString:[NSString stringWithFormat:@"%@\n\n",ticket.name]];              //姓名
        
        [self.manger writeString:[NSString stringWithFormat:@"%@\n\n",ticket.ticket_name]];      //票种
        [self.manger writeString:[NSString stringWithFormat:@"%@\n\n\n\n\n\n\n\n\n",ticket.tel]];         //联系电话
        
    }
}


#pragma mark - wsbluetoothMangerDelegate -

- (void) wsBlueToothStateUpdate:(CBCentralManagerState)state
{
    NSString *text = @"";
    
    switch (state) {
        case CBCentralManagerStatePoweredOff:
            text = @"蓝牙未打开";
            break;
        case CBCentralManagerStatePoweredOn:
            text = @"蓝牙已打开";
            break;
        case CBCentralManagerStateResetting:
            text = @"蓝牙重置";
            break;
        case CBCentralManagerStateUnauthorized:
            text = @"该应用未被授权";
            break;
        case CBCentralManagerStateUnsupported:
            text = @"该设备不支持蓝牙";
            break;
        default:
            text = @"蓝牙状态未知";
            break;
    }
    [GlobalConfig showAlertViewWithMessage:text superView:nil];
}


- (void) wsBlueToothdidDiscoverPeripheral:(peripheralModel *)model
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_PERIPHERALUPDATE object:nil];
}

- (void) wsblueToothPeripheralConnectFinish:(BOOL)success error:(NSError *)error
{
    [self.manger stopScan];
    
    if (success ) {
        [GlobalConfig showAlertViewWithMessage:@"连接成功" superView:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_PERIPHERALUPDATE object:nil];
    }
    else {
        [GlobalConfig showAlertViewWithMessage:[NSString stringWithFormat:@"连接失败%@",error] superView:nil];
    }
}

- (void) wsBlueToothdidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_PERIPHERALUPDATE object:nil];
    [GlobalConfig alert:@"蓝牙连接断开"];
}

- (void) dealloc
{
    [self.manger stopScan];
    [self.manger cancleConnectPeripheral];
}




@end
