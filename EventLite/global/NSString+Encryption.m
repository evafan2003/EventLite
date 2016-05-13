//
//  NSString+Encryption.m
//  EventLite
//
//  Created by 魔时网 on 14-6-11.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import "NSString+Encryption.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonCrypto.h>
#import "GlobalConfig.h"

@implementation NSString (Encryption)

- (NSString *) phoneNumberEncryption
{
    NSMutableString *str = [NSMutableString stringWithString:self];
    if (str.length == 11) {
        [str replaceCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    return str;
}

- (NSString *) nameEncryption
{
    NSMutableString *str = [NSMutableString stringWithString:self];

    if (str.length > 0) {
        NSMutableString *rep = [NSMutableString new];
        for (int i = 0;i < (str.length - 1);i++) {
            [rep appendString:@"*"];
        }
        [str replaceCharactersInRange:NSMakeRange(1, (str.length - 1)) withString:rep];
    }
    return str;
}

- (NSString *) idcardEncryption
{
    NSMutableString *str = [NSMutableString stringWithString:self];
    if (str.length == 18) {
        [str replaceCharactersInRange:NSMakeRange(6, 8) withString:@"********"];
    }
    return str;
}

- (NSString *) emailEncryption
{
    NSMutableString *str = [NSMutableString stringWithString:self];
    if ([GlobalConfig isValidateEmail:str]) {
        NSRange range = [str rangeOfString:@"@"];
        [str replaceCharactersInRange:NSMakeRange(0, range.location) withString:@"***"];
    }
    return str;
}

//加密用(DES方式)
- (NSString *) encryptUseDESWithkey:(NSString *)key
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    size_t numBytesEncrypted = 0;
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写
    dataOutAvailable = ([data length] + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,//  加密/解密
                                          kCCAlgorithmDES,//  加密根据哪个标准（des，3des，aes。。。。）
                                          kCCOptionECBMode | kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                                          [key UTF8String],//密钥    加密和解密的密钥必须一致
                                          kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
                                          nil, //  可选的初始矢量
                                          [data bytes],// 数据的存储单元
                                          [data length],// 数据的大小
                                          (void *)dataOut,// 用于返回数据
                                          dataOutAvailable,
                                          &numBytesEncrypted);
    
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:dataOut length:(NSUInteger)numBytesEncrypted];
        plainText = [[NSString alloc] initWithData:[GTMBase64 encodeData:dataTemp] encoding:NSUTF8StringEncoding];
    }else{
        NSLog(@"DES加密失败");
    }
    return [GlobalConfig isKindOfNSStringClassAndLenthGreaterThanZero:plainText]?plainText:@"";
}

//解密
- (NSString *) decryptUseDESWithkey:(NSString*)key
{
    NSData* cipherData = [GTMBase64 decodeString:self];
    
    size_t numBytesDecrypted = 0;
    size_t dataOutAvailable = 0; //size_t  是操作符sizeof返回的结果类型
    uint8_t *dataOut = NULL; //可以理解位type/typedef 的缩写
    dataOutAvailable = ([cipherData length] + kCCBlockSizeDES) & ~(kCCBlockSizeDES - 1);
    dataOut = malloc( dataOutAvailable * sizeof(uint8_t));
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,//  加密/解密
                                          kCCAlgorithmDES,//  加密根据哪个标准（des，3des，aes。。。。）
                                          kCCOptionECBMode | kCCOptionPKCS7Padding,//  选项分组密码算法(des:对每块分组加一次密  3DES：对每块分组加三个不同的密)
                                          [key UTF8String],//密钥    加密和解密的密钥必须一致
                                          kCCKeySizeDES,//   DES 密钥的大小（kCCKeySizeDES=8）
                                          nil, //  可选的初始矢量
                                          [cipherData bytes],// 数据的存储单元
                                          [cipherData length],// 数据的大小
                                          (void *)dataOut,// 用于返回数据
                                          dataOutAvailable,
                                          &numBytesDecrypted);
    
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:dataOut length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

//加密
- (NSString *) encrypt
{
    return [self encryptUseDESWithkey:encryptKey];
}

//解密
- (NSString *) decrypt
{
    return [self decryptUseDESWithkey:encryptKey];
}


@end
