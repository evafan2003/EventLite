//
//  WSEncryption.h
//  moshTickets
//
//  Created by 魔时网 on 14-5-30.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSEncryption : NSObject

/**
 *  DES加密
 *
 *  @param clearText 铭文
 *  @param key       密钥（64位）
 *
 *  @return 加密后的字符串
 */
+ (NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;

/**
 *  DES解密
 *
 *  @param cipherText 密码
 *  @param key        密钥（64位）
 *
 *  @return 解密后的字符串
 */
+ (NSString *) decryptUseDES:(NSString*)cipherText key:(NSString*)key;

@end
