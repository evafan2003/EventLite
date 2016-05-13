//
//  NSString+Encryption.h
//  EventLite
//
//  Created by 魔时网 on 14-6-11.
//  Copyright (c) 2014年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *encryptKey = @"moshmosh";

@interface NSString (Encryption)

/**
 *  电话号码加密
 *
 *  @return
 */
- (NSString *) phoneNumberEncryption;
/**
 *  名称加密
 *
 *  @return 
 */
- (NSString *) nameEncryption;
/**
 *  身份证号加密
 *
 *  @return
 */
- (NSString *) idcardEncryption;
/**
 *  邮箱加密
 *
 *  @return 
 */
- (NSString *) emailEncryption;
/**
 *  DES加密
 *
 *  @param key 八位key
 *
 *  @return
 */
- (NSString *) encryptUseDESWithkey:(NSString *)key;
/**
 *  解密
 *
 *  @param key 八位key
 *
 *  @return
 */
- (NSString *) decryptUseDESWithkey:(NSString*)key;

//加密
- (NSString *) encrypt;

//解密
- (NSString *) decrypt;

@end
