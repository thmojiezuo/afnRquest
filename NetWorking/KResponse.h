//
//  KResponse.h
//  AFNRequestDemo
//
//  Created by tenghu on 2017/10/12.
//  Copyright © 2017年 tenghu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KResponse : NSObject

/**
 请求返回 responseObject
 */
@property(copy, nonatomic) id responseObject;

/**
 获取具体返回数据
 */
@property (copy, nonatomic) id dataInfo;

/**
 服务器接口返回的错误信息
 */
@property (copy ,nonatomic)NSString *error_msg;

/**
 服务器接口返回的状态码
 */
@property (strong, nonatomic) NSNumber *status;

/**
 AFNetworking返回错误信息
 */
@property(strong, nonatomic) NSError *error;

/**
 afn内部请求的状态码
 */
@property (assign ,nonatomic)NSInteger statusCode;

@end
