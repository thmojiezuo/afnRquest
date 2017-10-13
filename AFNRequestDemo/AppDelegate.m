//
//  AppDelegate.m
//  AFNRequestDemo
//
//  Created by tenghu on 2017/10/12.
//  Copyright © 2017年 tenghu. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    __weak typeof(self)weakSelf = self;
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变时调用
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未知网络");
                [weakSelf updateInterfaceWithReachability:YES];
                break;
            }
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"没有网络");
                [weakSelf updateInterfaceWithReachability:NO];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"手机自带网络");
                [weakSelf updateInterfaceWithReachability:YES];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"WIFI");
                [weakSelf updateInterfaceWithReachability:YES];
                break;
            }
            default:{
                break;
            }
        }
    }];
    //开始监控
    [manager startMonitoring];
    
    return YES;
}

#pragma mark -检查网络状态

- (void)updateInterfaceWithReachability:(BOOL)reachability
{
    if (reachability == NO) { //没网
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"kNetWork"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"kNetWork"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
