//
//  WSBlueToothManger.h
//  Test_bluetoothPrint
//
//  Created by 魔时网 on 14/11/26.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "peripheralModel.h" 

@protocol WSBlueToothMangerDelegate;

@interface WSBlueToothManger : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, assign) id<WSBlueToothMangerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray    *peripheralArray;//扫描到的外设
@property (nonatomic, strong) CBPeripheral      *connectPeripheral;//当前连接的外设
@property (nonatomic, assign) NSTimeInterval    overTime;

/*
 单例
 */
+ (WSBlueToothManger *) shareBuleToothManger;

/*  开始扫描外设
 *  @see wsBlueToothdidDiscoverPeripheral:
 */
- (void) startScan;
- (void) stopScan;

/*
 * 连接外设
 * @see wsblueToothPeripheralConnectFinish:error:
 */
- (void) connectPeripheral:(peripheralModel *)model options:(NSDictionary *)dic;

/*
 * 断开外设连接
 * @see wsBlueToothdidDisconnectPeripheral:error
 */
- (void) cancleConnectPeripheral;
- (void) cancleConnectPeripheral:(peripheralModel *)model;


- (void) writeValue:(NSData *)data;

- (void) writeString:(NSString *)string;

- (void) writeImageValue:(NSData *)data;

@end

@protocol WSBlueToothMangerDelegate<NSObject>

//蓝牙状态变更
- (void) wsBlueToothStateUpdate:(CBCentralManagerState)state;

//发现外设
- (void) wsBlueToothdidDiscoverPeripheral:(peripheralModel *)model;

//外设连接成功
- (void) wsblueToothPeripheralConnectFinish:(BOOL)success error:(NSError *)error;

//外设断开连接
- (void) wsBlueToothdidDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;

@end
