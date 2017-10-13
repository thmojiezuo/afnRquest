//
//  KRequest.h
//  AFNRequestDemo
//
//  Created by tenghu on 2017/10/12.
//  Copyright © 2017年 tenghu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KResponse.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , KRequestMethod) {
    
    KRequestMethodGet,
    KRequestMethodPost,
    KRequestMethodHead,
    KRequestMethodPut,
    KRequestMethodDelete,
    KRequestMethodPatch
};

@interface KRequest : NSObject



+ (KRequest *)sharedRequest;

/**
 get方法请求 加密
 */
+ (void)get:(NSString *)url
        withParame:(NSDictionary *)parame
      withComplete:(void(^)(KResponse *responseObj))result;

/**
 post方法请求  加密
 */
+ (void)post:(NSString *)url
         withParame:(NSDictionary *)parame
       withComplete:(void(^)(KResponse *responseObj))result;

/**
 post方法请求  不加密
 */
+ (void)postSingle:(NSString *)url
          withParame:(NSDictionary *)parame
        withComplete:(void(^)(KResponse *responseObj))result;

/**
 上传单张图片，文件的形式，不带进度条 加密
 */
+ (void)updateImage:(NSString *)url
         withParame:(NSDictionary *)parame
      WithImageData:(NSData *)data
      withImageName:(NSString *)imageName
       withProgress:(void(^)(CGFloat progress))progressK
       withComplete:(void (^)(KResponse *))result;

/**
 上传多张图片，文件的形式，不带进度条 加密
 */
+ (void)updateImage:(NSString *)url
         withParame:(NSDictionary *)parame
      WithImageName:(NSArray *)names
         withImages:(NSArray <UIImage *>*)images
       withComplete:(void (^)(KResponse * ))result;

/**
 上传多张图片，文件的形式，带进度条 加密
 */
+ (void)updateImageProgress:(NSString *)url
         withParame:(NSDictionary *)parame
      WithImageName:(NSArray *)names
         withImages:(NSArray<UIImage *> *)images
       withComplete:(void (^)(KResponse *))result;

/**
 上传图片，base64的形式，带有进度条 加密
 */
+ (void)updateImageBase64:(NSString *)url
               withParame:(NSDictionary *)parame
             withComplete:(void(^)(KResponse *))result;

/**
 上传图片，base64的形式，带进度条，不加密
 */
+ (void)updateImageBase64KSingle:(NSString *)url
         withParame:(NSDictionary *)parame
       withComplete:(void(^)(KResponse *responseObj))result;
/**
 上传图片，base64的形式，不带进度条，加密
 */
+ (void)updateImageBase64noProgress:(NSString *)url
         withParame:(NSDictionary *)parame
       withComplete:(void(^)(KResponse *responseObj))result;

@end
