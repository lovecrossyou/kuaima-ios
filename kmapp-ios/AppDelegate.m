//
//  AppDelegate.m
//  kmapp-ios
//
//  Created by 朱理哲 on 2018/12/8.
//  Copyright © 2018 com.huibei. All rights reserved.
//

#import "AppDelegate.h"
#import "ZWWebViewVC.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSObject+LBLaunchImage.h"
#import "LBLaunchImageAdView.h"



@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|UNAuthorizationOptionProvidesAppNotificationSettings;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    NSString* channel = @"App Store" ;
    NSString* appKey = @"70023135ee111faf1b9f90d3" ;
    NSString* advertisingId = nil ;
    BOOL isProduction = NO ;
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    
//    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    ZWWebViewVC *vc = [[ZWWebViewVC alloc]init];
//    _window.rootViewController = vc;
//    [_window makeKeyAndVisible];
    [self showLaunch];
    return YES;
}

#pragma mark - 启动页展示
-(void)showLaunch{
    __weak typeof(self) weakSelf = self;
    [NSObject makeLBLaunchImageAdView:^(LBLaunchImageAdView *imgAdView) {
        //设置广告的类型
        imgAdView.getLBlaunchImageAdViewType(LogoAdType);
        //设置本地启动图片
        //imgAdView.localAdImgName = @"qidong.gif";
        imgAdView.imgUrl = @"http://img.zcool.cn/community/01316b5854df84a8012060c8033d89.gif";
        //自定义跳过按钮
        imgAdView.skipBtn.backgroundColor = [UIColor blackColor];
        //各种点击事件的回调
        
        imgAdView.clickBlock = ^(clickType type){
            switch (type) {
                case clickAdType:{
                    NSLog(@"点击广告回调");
                    [weakSelf goMainPage];
                }
                    break;
                case skipAdType:
                    NSLog(@"点击跳过回调");
                    [weakSelf goMainPage];
                    break;
                case overtimeAdType:
                    NSLog(@"倒计时完成后的回调");
                    [weakSelf goMainPage];
                    break;
                default:
                    break;
            }
        };
        
    }];
}

#pragma mark - 进入主界面
-(void)goMainPage{
    ZWWebViewVC *vc = [[ZWWebViewVC alloc]init];
    self.window.rootViewController = vc ;
    [self.window makeKeyAndVisible];
}

#pragma mark - 极光注册
-(void)registeToJPush:(NSString*)alias{
    [JPUSHService setAlias:alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//        [SVProgressHUD showSuccessWithStatus:@"成功注册订单提醒!"];
    } seq:1];
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

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark- JPUSHRegisterDelegate

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required, For systems with less than or equal to iOS 6
    [JPUSHService handleRemoteNotification:userInfo];
}

@end
