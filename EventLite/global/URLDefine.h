//
//  URLDefine.h
//  modelTest
//
//  Created by mosh on 13-10-29.
//  Copyright (c) 2013年 mosh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JSONKEY_RES     @"res"
#define JSONKEY_KEY     @"key"
#define JSONFEEDBACK    @"feedback"

/*
 网址
 */
#define SERVERHOST              @"www.mosh.cn" //servermanger检测网络状态使用
//#define MOSHHOST              @"http://192.168.1.200:30206/apieventuseiphone/" //host
#define MOSHHOST                @"http://e.mosh.cn/apieventuseiphone/"

#define URL_LOGIN               @"login?authkey=%@&secret=%@"  //登录

//获取所有票信息
#define GET_ALL_LIST            @"list?authkey=%@&secret=%@&time=%d"
//验票
#define VALIDATE                @"validate?ticket_id=%@&password=%@&eid=%@&uid=%@"4
//上传(post方式data,eid,uid)
#define UPLOAD                  @"state?authkey=%@&secret=%@"

#define URL_USERINFO                  @"overview?authkey=%@&secret=%@"

/*
 缓存地址
 */
#define CACHE_TICKETS           @"cacheTickets%@"

//加密
#define DESKEY                      @"d51da0e7ae40b437"
#define LOGINHOST                   @"http://api.mosh.cn/moshevent/"

/*
 第三方登录使用
 本地保存 格式如下
 { USER_KEYSINA:{USER_THIRDACCESSTOKEN:@"",USER_THIRDUSERID:@"",USER_THIRDEXPDATE;@""},
 USER_KEYQQ:
 {USER_THIRDACCESSTOKEN:@"",USER_THIRDUSERID:@"",USER_THIRDEXPDATE;@""}}
 */
#define USER_THIRDINFO              @"userThirdLogin"//第三方登录信息
#define USER_KEYSINA                @"userSina"//第三方登录信息内字典key
#define USER_KEYRENREN              @"userRenren"
#define USER_KEYDOUBAN              @"userDouban"
#define USER_KEYQQ                  @"userQQ"
#define USER_KEYTAOBAO              @"userTaobao"
#define USER_KEYTENCENT             @"userTencent"
#define USER_THIRDACCESSTOKEN       @"userAccessToken"//第三方token
#define USER_THIRDUSERID            @"userthirdUserId"//第三方id
#define USER_THIRDEXPDATE           @"userExpiresDate"//有效期  过期时间 = 授权时间 + 有效期
#define USER_THIRDAUTHDATE          @"userAuthdate" //授权时间
#define USER_THIRDNICKNAME          @"userNickName" // 用户昵称
#define USER_USERID                 @"userId"       //用户id
#define USER_USERNAME               @"userName"     //用户名
#define USER_PASSWORD               @"userPassword" //密码
#define USER_PHONE                  @"userPhone"    //手机号
#define USER_EMAIL                  @"userEmail"    //邮箱
#define USER_CITY                   @"userCity"     //城市
#define USER_IMAGE                  @"userImage"    //头像
#define USER_BINDING                @"userBinding"  //绑定
#define USER_GENDER                 @"userGender"   //性别
#define CITYNAME                    @"CityName"     //gps城市名称
#define CITYID                      @"CityId"       //gps城市代码

#define USER_EID                    @"userEid"



@interface URLDefine : NSObject

@end
