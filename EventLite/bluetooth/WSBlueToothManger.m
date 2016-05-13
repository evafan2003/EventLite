//
//  WSBlueToothManger.m
//  Test_bluetoothPrint
//
//  Created by 魔时网 on 14/11/26.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#define SERVICE_WRITE_UUID  @"18F0"
#define CHARATERISTIC_WRITE_UUID @"2AF1"

#import "WSBlueToothManger.h"


@interface WSBlueToothManger()

@property (nonatomic, strong) CBCentralManager  *cbCentManager;
@property (nonatomic, strong) CBCharacteristic  *writeChacterisric;

@end

@implementation WSBlueToothManger

+ (WSBlueToothManger *) shareBuleToothManger
{
    static WSBlueToothManger *instace;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instace = [[WSBlueToothManger alloc] init];
    });
    return instace;
}

- (id) init
{
    if (self = [super init]) {
        self.cbCentManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        self.peripheralArray = [NSMutableArray new];
    }
    return self;
}

//扫描周围的蓝牙
- (void) startScan
{
    [self.cbCentManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    
}

- (void) stopScan
{
    [self.cbCentManager stopScan];
}

- (void) connectPeripheral:(peripheralModel *)model options:(NSDictionary *)dic
{
    if ([model isKindOfClass:[peripheralModel class]] && ([self.peripheralArray indexOfObject:model] != NSNotFound)) {
        [self.cbCentManager connectPeripheral:model.peripheral options:dic];
    }
}

- (void) cancleConnectPeripheral
{
    if (self.connectPeripheral.state !=CBPeripheralStateConnected) {
        [self.cbCentManager cancelPeripheralConnection:self.connectPeripheral];
    }
}

- (void) cancleConnectPeripheral:(peripheralModel *)model
{
    if (model.peripheral.state !=CBPeripheralStateConnected) {
        [self.cbCentManager cancelPeripheralConnection:model.peripheral];
    }
}

- (void) writeString:(NSString *)string
{
    if (string.length > 0) {
        
        NSData * data = [string dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        if (self.writeChacterisric) {
//            NSLog(@"打印开始");
                [self.connectPeripheral writeValue:data forCharacteristic:self.writeChacterisric type:CBCharacteristicWriteWithoutResponse];
                
//            NSLog(@"打印内容 %@",data);
        }

    }
}

- (void) writeValue:(NSData *)data
{
    if (self.writeChacterisric) {
        
        NSLog(@"打印开始");
        
        NSInteger len = [data length];
        NSRange range;
        range.length = 0;
        range.location = 0;
        
        while (range.location < len) {
            if (len - range.location > 20) {
                range.length = 20;
            }else{
                range.length = len - range.location;
            }
            NSData *sendData = [data subdataWithRange:range];
        
            [self.connectPeripheral writeValue:sendData forCharacteristic:self.writeChacterisric type:CBCharacteristicWriteWithoutResponse];
            
            NSLog(@"打印内容 %@",sendData);
            
             range.location += range.length;
        }
    }
    
}

- (void) writeImageValue:(NSData *)data
{
    if (self.writeChacterisric) {
        
        static int bytewidth = 72;
        
        NSLog(@"打印开始");
        
        NSInteger len = [data length];
        NSRange range;
        range.length = 0;
        range.location = 0;
        
        while (range.location < len) {
            if (len - range.location > bytewidth) {
                range.length = bytewidth;
            }else{
                range.length = len - range.location;
            }
            NSData *sendData = [data subdataWithRange:range];
             NSMutableData *imData = [NSMutableData dataWithData:sendData];
            while (sendData.length < bytewidth) {
                int o = 0;
                [imData appendBytes:&o length:sizeof(o)];
            }
            
            unsigned int c = 0x0048101F;
//             [self.connectPeripheral writeValue:[NSData dataWithBytes:&c length:sizeof(c)] forCharacteristic:self.writeChacterisric type:CBCharacteristicWriteWithoutResponse];
            
//            unsigned int a = 0x1F;
//            
//            NSMutableData *mutaData = [NSMutableData dataWithBytes:&a length:sizeof(a)];
//            unsigned int b = 0x10;
//            [mutaData appendBytes:&b length:sizeof(b)];
//            
//            unsigned int c = 0x48;
//            [mutaData appendBytes:&c length:sizeof(c)];
//            
//            unsigned int d = 0x00;
//            [mutaData appendBytes:&d length:sizeof(d)];
            
            NSMutableData *mutaData = [NSMutableData dataWithBytes:&c length:sizeof(c)];
            [mutaData appendData:imData];
            
            [self.connectPeripheral writeValue:mutaData forCharacteristic:self.writeChacterisric type:CBCharacteristicWriteWithoutResponse];
            
            NSLog(@"打印内容 %@",mutaData);
            usleep(20000);
            
            range.location += range.length;
        }
    }
    
}

- (void) writeValue:(NSData *)data characteristic:(CBCharacteristic *)characteristic
{
    [self.connectPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (void) addNewPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI
{
    peripheralModel *model = [peripheralModel new];
    model.peripheral = peripheral;
    model.name = peripheral.name;
    model.identifier = peripheral.identifier;
    [self.peripheralArray addObject:model];
    
    if ([self.delegate respondsToSelector:@selector(wsBlueToothdidDiscoverPeripheral:)]) {
        [self.delegate wsBlueToothdidDiscoverPeripheral:model];
    }
    
//    int rssi = abs([RSSI intValue]);
//    CGFloat ci = (rssi - 49) / (10 * 4.);
//    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",peripheral.name,pow(10,ci)];
//    NSLog(@"距离：%@",length);
//    NSLog(@"发现外设 %@ at %@", peripheral.name, RSSI);

    
}

#pragma mark - CBCentalMangerDelegate -
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self.delegate respondsToSelector:@selector(wsBlueToothStateUpdate:)]) {
        [self.delegate wsBlueToothStateUpdate:central.state];
    }
}


- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // 过滤信号强度范围
    //    if (RSSI.integerValue > -15) {
    //        return;
    //    }
    //    if (RSSI.integerValue < -35) {
    //        return;
    //    }
    for (int i = 0;i< self.peripheralArray.count;i++){
        peripheralModel *model = self.peripheralArray[i];
        if ([model.identifier isEqual:peripheral.identifier]){
            break;
        }
        if (i == (self.peripheralArray.count - 1)) {
            [self addNewPeripheral:peripheral RSSI:RSSI];
        }
    }
    
    if (self.peripheralArray.count == 0) {
        [self addNewPeripheral:peripheral RSSI:RSSI];
    }
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"%@ 外设连接成功",peripheral.name);
    [self stopScan];
    NSLog(@"停止扫描");
    
    self.connectPeripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    for(peripheralModel *model in self.peripheralArray) {
        if ([model.identifier isEqual:peripheral.identifier]) {
            model.isConnectable = YES;
            break;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(wsblueToothPeripheralConnectFinish:error:)]) {
        [self.delegate wsblueToothPeripheralConnectFinish:YES error:nil];
    }
    
    [peripheral discoverServices:nil];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@ 外设连接失败,原因 :%@",peripheral.name,error.description);
    
    self.connectPeripheral = nil;
    
    if ([self.delegate respondsToSelector:@selector(wsblueToothPeripheralConnectFinish:error:)]) {
        [self.delegate wsblueToothPeripheralConnectFinish:NO error:error];
    }
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@断开连接",peripheral.name);
    
    for(peripheralModel *model in self.peripheralArray) {
        if ([model.identifier isEqual:peripheral.identifier]) {
            model.isConnectable = NO;
            break;
        }
    }
    
    self.connectPeripheral = nil;
    
    if ([self.delegate respondsToSelector:@selector(wsBlueToothdidDisconnectPeripheral:error:)]) {
        [self.delegate wsBlueToothdidDisconnectPeripheral:peripheral error:error];
    }
}

#pragma mark - peripheralDelegate -
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"发现服务失败");
        return;
    }
    
    for (CBService *s in peripheral.services) {
        NSLog(@"----------服务uuid:%@",s.UUID);
        
        if ([s.UUID isEqual:[CBUUID UUIDWithString:SERVICE_WRITE_UUID]]) {
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"发现特征失败");
        return;
    }
    
    
    for (CBCharacteristic *charateristic in service.characteristics) {
        
        [peripheral readValueForCharacteristic:charateristic];
        [peripheral setNotifyValue:YES forCharacteristic:charateristic];
        
        if ([charateristic.UUID isEqual:[CBUUID UUIDWithString:CHARATERISTIC_WRITE_UUID]]) {
            NSLog(@"服务uuid:%@,特征uuid:%@",service.UUID,charateristic.UUID);
            self.writeChacterisric = charateristic;
        }
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"%@",error);
    }
    else {
        NSLog(@"write data %@",characteristic.value);
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
}


@end
