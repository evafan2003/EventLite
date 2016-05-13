//
//  periperalModel.h
//  Test_bluetoothPrint
//
//  Created by 魔时网 on 14/11/24.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface peripheralModel : NSObject

@property (strong,nonatomic)CBPeripheral* peripheral;

@property (strong,nonatomic)NSUUID  * identifier;
@property (strong,nonatomic)NSString* name;
@property (strong,nonatomic)NSString* state;
@property (assign,nonatomic)BOOL    isConnectable;
//advertisement
@property (strong,nonatomic)NSString* channel;
@property (strong,nonatomic)NSString* localName;

@property (strong,nonatomic)NSString* manufactureData;
@property (strong,nonatomic)NSString* serviceUUIDS;
@property (strong,nonatomic)NSString* serviceNameKey;
//rssi
@property (strong,nonatomic)NSNumber *RSSI;

@end
