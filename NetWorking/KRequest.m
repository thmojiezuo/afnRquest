//
//  KRequest.m
//  AFNRequestDemo
//
//  Created by tenghu on 2017/10/12.
//  Copyright © 2017年 tenghu. All rights reserved.
//

#import "KRequest.h"
#import <AFNetworking.h>
#import <AFNetworkActivityIndicatorManager.h>
#import "BaseApiAddress.h"
#import "NSString+Additions.h"

@interface KRequest ()
{
    UIView *_bg;
    NSProgress *_pro;
    UIView *_netBgView; //网络
    
}
@property (strong, nonatomic) AFHTTPSessionManager *manager;

/**
 请求地址(前半段)
 */
@property (copy, nonatomic) NSString *requestBaseUrl;
/**
 请求地址(后半段)
 */
@property (copy, nonatomic) NSString *requestApiUrl;
/**
 请求参数
 */
@property (strong, nonatomic) NSDictionary *requestParame;
/**
 请求方式
 */
@property (assign, nonatomic) KRequestMethod requestMethod;
/**
 上传图片进度
 */
@property (copy, nonatomic) void(^updateProgressBock)(CGFloat progress);
/**
 上传图片名字
 */
@property (copy, nonatomic) NSString *updateImageName;
/**
 上传图片data
 */
@property (strong, nonatomic) NSData *updateData;

@end


@implementation KRequest

static KRequest *_kRequest;
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_kRequest == nil) {
            _kRequest = [super allocWithZone:zone];
            
            [_kRequest initPrivate];
        }
    });
    return _kRequest;
}
- (void)initPrivate {
   
    _requestBaseUrl = kBaseUrl;
    _requestMethod = KRequestMethodPost; //这里先默认为POST
    _manager = [AFHTTPSessionManager manager];
    _manager.requestSerializer.timeoutInterval = 10;
    //        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",nil];
    //注：在Afn内部也需要添加  @"text/html",@"text/plain"，直接搜索找到
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
   
}

// 为了严谨，也要重写copyWithZone 和 mutableCopyWithZone
-(id)copyWithZone:(NSZone *)zone
{
    return _kRequest;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _kRequest;
}
#pragma mark -创建单例
+ (KRequest *)sharedRequest {
   
    return [[self alloc]init];
}
#pragma mark - 检查网络，并屏蔽一些接口
- (void)testNetwork:(NSDictionary *)dict{
    
    
    NSString *net = [[NSUserDefaults standardUserDefaults]  objectForKey:@"kNetWork"];
    if ([net integerValue] == 0) {
        
        if (dict.count > 0 ) {
            NSArray *actionA = @[@"homepage_api"];
            if ([dict.allKeys containsObject:@"action"] && [actionA containsObject:dict[@"action"]]) {
                return;
            }
        }
        
        if (_netBgView) {
            
        }else{
            _netBgView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, SCREEN_WIDTH, 20)];
            _netBgView.backgroundColor = [UIColor blackColor];
            UILabel *messageLab = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, SCREEN_WIDTH-55 ,20 )];
            messageLab.text = @"无法连接到网络，请稍后再试...";
            messageLab.textColor = [UIColor whiteColor];
            messageLab.font = [UIFont systemFontOfSize:12];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 3, 14, 14)];
            imageView.image = [UIImage imageNamed:@"warning"];
            [_netBgView addSubview:messageLab];
            [_netBgView addSubview:imageView];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            [window addSubview:_netBgView];
            window.windowLevel = UIWindowLevelAlert;
            __weak typeof(self)weakSelf = self;
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = _netBgView.frame;
                frame.origin.y = 0;
                _netBgView.frame = frame;
            } completion:^(BOOL finished) {
                [weakSelf performSelector:@selector(dismissNetView) withObject:nil afterDelay:1.5];
            }];
            
        }
        return;
    }else{
        if (_netBgView) {
            [_netBgView removeFromSuperview];
            _netBgView = nil;
        }
        
    }
    
}
- (void)dismissNetView{
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _netBgView.frame;
        frame.origin.y = -20;
        _netBgView.frame = frame;
    } completion:^(BOOL finished) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.windowLevel = UIWindowLevelNormal;
        [_netBgView removeFromSuperview];
        _netBgView = nil;
    }];
}

#pragma mark 服务器验证
+ (NSString *)auth {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSString *auth = [dateString stringByAppendingString:kBaseAuth];
    return [auth MD5];
    
}

#pragma mark 拼接url
- (NSString *)requestUrlString {
    
    if ([_requestApiUrl hasPrefix:@"http"]) {
        return _requestApiUrl;
    }
    return [NSString stringWithFormat:@"%@%@",_requestBaseUrl,_requestApiUrl];
}
#pragma mark 便利构造的公共方法
- (void)requestWithCompletionBlockWithSuccess:(void (^)(KResponse *))result {
    
    [self requestMethodWithSuccess:^(NSURLSessionDataTask *task, id responseObject)
     {
         
         NSLog(@"【request_responseObject】=%@",responseObject);
         KResponse *response = [[KResponse alloc] init];
         response.responseObject = responseObject;
         response.error = nil;
         
         result(response);
         
     } failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         
         NSLog(@"【request_error】=%@ ==%@",error,task.response);
         /*注意:这里要强转下*/
         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)task.response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         
         KResponse *response = [[KResponse alloc] init];
         response.error = error;
         response.statusCode = responseStatusCode;
         result(response);
     }];
    
}
- (void)requestMethodWithSuccess:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask * task, NSError * error))failure {
    
    NSString *net = [[NSUserDefaults standardUserDefaults]  objectForKey:@"kNetWork"];
    if ([net integerValue] == 0) {
        failure(nil,[NSError errorWithDomain:@"网络连接失败" code:-1 userInfo:nil]);
        return;
    }
    
    NSString *URLString = [self requestUrlString];
    
    NSLog(@"【URL】%@",URLString);
    NSLog(@"【parame】%@",_requestParame);
    
    switch (_requestMethod) {
        case KRequestMethodGet:{
            //            [_manager GET:URLString parameters:_requestParame success:success failure:failure];
            [_manager GET:URLString parameters:_requestParame progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:success failure:failure];
            
            break;
        }
        case KRequestMethodPost:{
            //            [_manager POST:URLString parameters:_requestParame success:success failure:failure];
            [_manager POST:URLString parameters:_requestParame progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:success failure:failure];
            break;
        }
        case KRequestMethodHead:{
            [_manager HEAD:URLString parameters:_requestParame success:^(NSURLSessionDataTask * task) {
                success(task,nil);
            } failure:failure];
            break;
        }
        case KRequestMethodPut:{
            [_manager PUT:URLString parameters:_requestParame success:success failure:failure];
            break;
        }
        case KRequestMethodDelete:{
            [_manager DELETE:URLString parameters:_requestParame success:success failure:failure];
            break;
        }
        case KRequestMethodPatch:{
            [_manager PATCH:URLString parameters:_requestParame success:success failure:failure];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - 上传单张图片
- (void)updateImageWithSuccess:(void (^)(KResponse *))result {
    
    NSString *URLString = [self requestUrlString];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",self.updateImageName];
    
    NSLog(@"【URL】%@",URLString);
    NSLog(@"【parame】%@",_requestParame);
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 30;
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:_requestParame constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:self.updateData name:self.updateImageName fileName:fileName mimeType:@"image/jpeg"];
    } error:nil];
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    AFHTTPResponseSerializer *responseSerializer = sessionManager.responseSerializer;
    responseSerializer.acceptableContentTypes= [NSSet setWithObject:@"text/html"];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask = [sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
//        [uploadProgress removeObserver:self forKeyPath:@"fractionCompleted"];
//        if (self.updateProgressBock) {
//            [uploadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
//        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        KResponse *res = [[KResponse alloc] init];
        NSLog(@"上传图片 Error: %@", error);
        NSLog(@"上传图片 responseObject =%@", responseObject);
        
        if (responseObject) {
            res.responseObject =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            NSLog(@"res = %@",res.responseObject);
        }
        res.error = error;
        NSLog(@"msg =%@",res.error_msg);
        
        if (res.error.description.length> 0 || ![res.status isEqualToNumber:@1]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }
        result(res);
    }];
    [uploadTask resume];
}
#pragma mark - 上传多张
- (void)updateImages:(NSArray <UIImage *>*)images withImageName:(NSArray *)names withSuccess:(void (^)(KResponse *))result{
    
    NSString *URLString = [self requestUrlString];
    NSLog(@"【URL】%@",URLString);
    NSLog(@"【parame】%@",_requestParame);
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    requestSerializer.timeoutInterval = 30;
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:URLString parameters:_requestParame constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [names enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             NSString *fileName = [NSString stringWithFormat:@"%@.jpg",obj];
             NSData *imageData = UIImageJPEGRepresentation(images[idx], 0.8);
             NSLog(@"图片大小=== %ld",[imageData length]/1024);
             
             [formData appendPartWithFileData:imageData name:obj fileName:fileName mimeType:@"image/jpeg"];
         }];
        
    } error:nil];
    
    AFURLSessionManager *sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFHTTPResponseSerializer *responseSerializer = sessionManager.responseSerializer;
    responseSerializer.acceptableContentTypes= [NSSet setWithObject:@"text/html"];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask = [sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //        [uploadProgress removeObserver:self forKeyPath:@"fractionCompleted"];
        //        if (self.updateProgressBock) {
        //            [uploadProgress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        //        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        KResponse *res = [[KResponse alloc] init];
        NSLog(@"上传多张图片 Error: %@", error);
        NSLog(@"上传多张图片 responseObject =%@", responseObject);
        
        if (responseObject) {
            res.responseObject =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            NSString *s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSLog(@"s===%@",s);
            NSLog(@"上传多张图片解析 =%@", res.responseObject);
        }
        res.error = error;
        NSLog(@"msg =%@",res.error_msg);
        result(res);
    }];
    [uploadTask resume];
    
}

#pragma mark - base64上传图片
- (void)requestbaseWithCompletionBlockWithSuccess:(void (^)(KResponse *))result {
    
    _bg = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bg.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    _bg.tag = 600;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_bg];
    //无小圆点、同动画时间
    UIProgressView *pv = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    pv.frame = CGRectMake(10, 100, 300, 2.5);
    pv.layer.cornerRadius = 2.5 / 2.0;
    pv.layer.masksToBounds = YES;
    pv.transform = CGAffineTransformScale(pv.transform, 1, 10);
    pv.backgroundColor = [UIColor redColor];
    [_bg addSubview:pv];
    
    KRequest *request = [KRequest sharedRequest];
    request.updateProgressBock = ^(CGFloat a) {
        NSLog(@"aaaaaaa =%f",a);
        dispatch_async(dispatch_get_main_queue(), ^{
            [pv setProgress:a animated:YES];
        });
        
    };
    __weak typeof(self)weakSelf = self;
    [self requestbaseMethodWithSuccess:^(NSURLSessionDataTask *task, id responseObject)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf performSelector:@selector(dissMissProgress) withObject:nil afterDelay:0.1];
         });
         NSLog(@"【request_responseObject】=%@",responseObject);
         KResponse *response = [[KResponse alloc] init];
         response.responseObject = responseObject;
         response.error = nil;
         result(response);
         
     } failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             
             [_bg removeFromSuperview];
             [_pro removeObserver:self forKeyPath:@"fractionCompleted"];
             _pro = nil;
         });
         NSLog(@"【request_error】=%@ ==%@",error,task.response);
         /*注意:这里要强转下*/
         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)task.response;
         NSInteger responseStatusCode = [httpResponse statusCode];
        
         KResponse *response = [[KResponse alloc] init];
         response.error = error;
         response.statusCode = responseStatusCode;
         result(response);
     }];
}
- (void)requestbaseMethodWithSuccess:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask * task, NSError * error))failure {
    
    NSString *net = [[NSUserDefaults standardUserDefaults]  objectForKey:@"kNetWork"];
    if ([net integerValue] == 0) {
        failure(nil,[NSError errorWithDomain:@"网络连接失败" code:-1 userInfo:nil]);
        return;
    }
  
    NSString *URLString = [self requestUrlString];
    
    NSLog(@"【URL】%@",URLString);
  //  NSLog(@"【parame】%@",_requestParame);   base64文件太长，打印很费时间
    
    [_manager POST:URLString parameters:_requestParame progress:^(NSProgress * _Nonnull uploadProgress) {
        if (self.updateProgressBock) {
            _pro = uploadProgress;
            [_pro addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:NULL];
        }
    } success:success failure:failure];
    
}
#pragma mark -base64 不带进度条
- (void)requestbaseNopressWithCompletionBlockWithSuccess:(void (^)(KResponse *))result {
    [self requestNoprogressbaseMethodWithSuccess:^(NSURLSessionDataTask *task, id responseObject)
     {
         NSLog(@"【request_responseObject】=%@",responseObject);
         KResponse *response = [[KResponse alloc] init];
         response.responseObject = responseObject;
         response.error = nil;
         result(response);
         
     } failure:^(NSURLSessionDataTask *task, NSError *error)
     {
         NSLog(@"【request_error】=%@ ==%@",error,task.response);
         /*注意:这里要强转下*/
         NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)task.response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         
         KResponse *response = [[KResponse alloc] init];
         response.error = error;
         response.statusCode = responseStatusCode;
         result(response);
     }];

}
- (void)requestNoprogressbaseMethodWithSuccess:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask * task, NSError * error))failure {
    
    NSString *net = [[NSUserDefaults standardUserDefaults]  objectForKey:@"kNetWork"];
    if ([net integerValue] == 0) {
        failure(nil,[NSError errorWithDomain:@"网络连接失败" code:-1 userInfo:nil]);
        return;
    }
   
    NSString *URLString = [self requestUrlString];
    NSLog(@"【URL】%@",URLString);
    //  NSLog(@"【parame】%@",_requestParame);   base64文件太长，打印很费时间
    
    [_manager POST:URLString parameters:_requestParame progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:success failure:failure];
    
}

#pragma mark 监听上传进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    __weak typeof(self)weakSelf = self;
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (progress.fractionCompleted > 0.999) {
                [weakSelf performSelector:@selector(dissMissProgress) withObject:nil afterDelay:0.5];
                
            }
        });
        
        self.updateProgressBock(progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)dissMissProgress{
    if (_bg && _pro) {
        [_bg removeFromSuperview];
        [_pro removeObserver:self forKeyPath:@"fractionCompleted"];
        _pro = nil;
    }
    
}
#pragma mark - get请求 加密 支持全地址
+ (void)get:(NSString *)url withParame:(NSDictionary *)parame withComplete:(void(^)(KResponse *responseObj))result{
    
    NSMutableDictionary *authParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    [authParame setObject:[self auth] forKey:@"auth"];
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = authParame;
    request.requestMethod = KRequestMethodGet;
    [request requestWithCompletionBlockWithSuccess:result];
  
}
#pragma mark - post请求  加密 支持全地址
+ (void)post:(NSString *)url withParame:(NSDictionary *)parame withComplete:(void(^)(KResponse *responseObj))result{
    
    NSMutableDictionary *authParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    [authParame setObject:[self auth] forKey:@"auth"];
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = authParame;
    request.requestMethod = KRequestMethodPost;
    [request requestWithCompletionBlockWithSuccess:result];
}
#pragma mark - post请求  不加密 支持全地址
+ (void)postSingle:(NSString *)url withParame:(NSDictionary *)parame withComplete:(void(^)(KResponse *responseObj))result{
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = parame;
    request.requestMethod = KRequestMethodPost;
    [request requestWithCompletionBlockWithSuccess:result];
}
#pragma mark -上传单张图片，文件的形式，不带进度条 加密
+ (void)updateImage:(NSString *)url  withParame:(NSDictionary *)parame WithImageData:(NSData *)data withImageName:(NSString *)imageName withProgress:(void(^)(CGFloat progress))progressK withComplete:(void (^)(KResponse *))result{
    
    NSMutableDictionary *authParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    [authParame setObject:[self auth] forKey:@"auth"];
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = authParame;
    request.updateImageName = imageName;
    request.updateProgressBock = progressK;
    request.updateData = data;
    [request updateImageWithSuccess:result];    
}
#pragma mark - 上传多张图片，文件的形式，带进度条 加密
+ (void)updateImage:(NSString *)url withParame:(NSDictionary *)parame WithImageName:(NSArray *)names
         withImages:(NSArray <UIImage *>*)images withComplete:(void (^)(KResponse * ))result{
    
    NSMutableDictionary *authParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    [authParame setObject:[self auth] forKey:@"auth"];
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = authParame;
    request.updateProgressBock = ^(CGFloat a) {
        NSLog(@"Progress ==%f",a);
        
    };
    [request updateImages:images withImageName:names withSuccess:result];
}
#pragma mark - post上传图片，base64的形式，带有进度条 加密
+ (void)updateImageBase64:(NSString *)url withParame:(NSDictionary *)parame withComplete:(void(^)(KResponse *))result{
    
    NSMutableDictionary *authParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    [authParame setObject:[self auth] forKey:@"auth"];
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = authParame;
    [request requestbaseWithCompletionBlockWithSuccess:result];
    
}
#pragma mark - post上传图片，base64的形式，带有进度条 不加密
+ (void)updateImageBase64KSingle:(NSString *)url withParame:(NSDictionary *)parame withComplete:(void(^)(KResponse *responseObj))result{
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = parame;
    [request requestbaseWithCompletionBlockWithSuccess:result];
}
 #pragma mark -post上传图片，base64的形式，不带进度条，加密
+ (void)updateImageBase64noProgress:(NSString *)url withParame:(NSDictionary *)parame
                       withComplete:(void(^)(KResponse *responseObj))result{
    
    NSMutableDictionary *authParame = [[NSMutableDictionary alloc] initWithDictionary:parame];
    [authParame setObject:[self auth] forKey:@"auth"];
    
    KRequest *request = [KRequest sharedRequest];
    [request testNetwork:parame];
    request.requestApiUrl = url;
    request.requestParame = authParame;
    [request requestbaseNopressWithCompletionBlockWithSuccess:result];
    
}

@end
