//
//  KResponse.m
//  AFNRequestDemo
//
//  Created by tenghu on 2017/10/12.
//  Copyright © 2017年 tenghu. All rights reserved.
//

#import "KResponse.h"

@implementation KResponse

#pragma mark 服务器接口返回的状态码
- (NSNumber *)status {
    
    NSNumber *number = [NSNumber numberWithInteger:[_responseObject[@"status"] integerValue]];
    if ([number isEqual:[NSNull null]] || [number integerValue] == NSNotFound) {
        
        return @404;
    }
    
    return number;
}
#pragma mark 获取具体返回数据
- (id )dataInfo {
    return _responseObject[@"data"];
}
#pragma mark 服务器接口返回的错误信息
- (NSString *)error_msg {
    
    return _responseObject[@"error_msg"]?:@"请求失败，请重新尝试";
}

@end
