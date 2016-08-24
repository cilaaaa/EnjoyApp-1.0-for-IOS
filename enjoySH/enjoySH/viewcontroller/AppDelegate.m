//
//  AppDelegate.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/3/31.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <MapKit/MapKit.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "ViewController.h"
#import "GDLocalizableController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocation *_currentLocation;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initLanguage];
    application.applicationIconBadgeNumber = 0;
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        //IOS8
        //创建UIUserNotificationSettings，并设置消息的显示类类型
        UIUserNotificationSettings *notiSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIRemoteNotificationTypeSound) categories:nil];
        [application registerUserNotificationSettings:notiSettings];
        
    } else{ // ios7
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert)];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initLocation) name:@"loadLocate" object:nil];
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [ShareSDK registerApp:@"7338fe7a0e20"];
    [self initializePlat];
    [self initTableList];
    SlideNavigationController *slidenavigationController = [[SlideNavigationController alloc]init];
    self.navController = slidenavigationController;
    ViewController *welcomeView = [[ViewController alloc]init];
    self.window.rootViewController = welcomeView;
    LeftMenuViewController *leftMenu = [[LeftMenuViewController alloc]init];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [[SlideNavigationController sharedInstance] pushViewController:welcomeView animated:YES];
    [self.window addSubview:self.navController.view];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)initLanguage{
    [GDLocalizableController bundle];
    [GDLocalizableController initUserLanguage];
    NSString *language = [GDLocalizableController userLanguage];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([language isEqualToString:@"zh-Hans"]) {
        [userdefault setObject:@"ch" forKey:@"languageFlag"];
        [GDLocalizableController setUserlanguage:CHINESE];
    }else{
        [userdefault setObject:@"en" forKey:@"languageFlag"];
        [GDLocalizableController setUserlanguage:ENGLISH];
    }
}

-(void)initLocation
{
    locationManager = [[CLLocationManager alloc] init];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if([[[UIDevice  currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [locationManager requestAlwaysAuthorization];
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways) {
            [userdefault setObject:@"1" forKey:@"locationflag"];
        }else{
            [userdefault setObject:@"0" forKey:@"locationflag"];
        }
        
    }
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways) {
        [userdefault setObject:@"1" forKey:@"locationflag"];
    }else{
        [userdefault setObject:@"0" forKey:@"locationflag"];
    }
    locationManager.delegate = self;
    locationManager.distanceFilter = 1000;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    CLLocation *nowLocation = [locations firstObject];
    [userdefault setDouble:nowLocation.coordinate.latitude forKey:@"lat"];
    [userdefault setDouble:nowLocation.coordinate.longitude forKey:@"lng"];
    [locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshLoc" object:nil];
}

- (void)initializePlat
{
    //初始化新浪
    [ShareSDK connectSinaWeiboWithAppKey:@"1388643844" appSecret:@"916c9a99a450929fa1cef8916ab666b7" redirectUri:@"http://www.enjoyshanghai.com" weiboSDKCls:[WeiboSDK class]];
    //微信好友
    [ShareSDK connectWeChatSessionWithAppId:@"wxc1887309c74a39f6" appSecret:@"0dfe00a1b718d87b767df7697516c5f9" wechatCls:[WXApi class]];
    //微信朋友圈
    [ShareSDK connectWeChatTimelineWithAppId:@"wxc1887309c74a39f6" appSecret:@"0dfe00a1b718d87b767df7697516c5f9" wechatCls:[WXApi class]];
    //连接QQ应用
    [ShareSDK connectQQWithQZoneAppKey:@"1104617520" qqApiInterfaceCls:[QQApiInterface class]
                 tencentOAuthCls:[TencentOAuth class]];
    //初始化Facebook,在https://developers.facebook.com上注册应用
    [ShareSDK connectFacebookWithAppKey:@"107704292745179"
                              appSecret:@"38053202e1a5fe26c80c753071f0b573"];
    /**---------------------------------------------------------**/
    //初始化Twitter,在https://dev.twitter.com上注册应用
    [ShareSDK connectTwitterWithConsumerKey:@"LRBM0H75rWrU9gNHvlEAA2aOy"
                             consumerSecret:@"gbeWsZvA9ELJSdoBzJ5oLKX0TU09UOwrzdGfo9Tg7DjyGuMe8G"
                                redirectUri:@"http://mob.com"];
    //连接邮件
    [ShareSDK connectMail];
    //连接短信
    [ShareSDK connectSMS];
}

//添加两个回调方法,return的必须要ShareSDK的方法
- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
                                                      NSLog(@"result = %@",resultDic);
                                                  }];
    }
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    NSLog(@"url%@",url);
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

-(void)initTableList{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if([db open]){
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS PersonList (UID INTEGER PRIMARY KEY,USERNAME TEXT,NAME TEXT,EMAIL TEXT,PHONE TEXT,MOBILE TEXT,CARDNUMBER TEXT,VALIDITY TEXT,CARDNAME TEXT,LOCALE TEXT,GENDER TEXT,BIRTHDAY TEXT,NATIONALITY TEXT,AVATARX2 TEXT)"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS FavoriteList (FID INTEGER PRIMARY KEY,CID INTEGER,UID INTEGER,ICONX2 TEXT,EXCERPT TEXT,NAME TEXT,SCORE REAL,PRICE TEXT)"];
        [db close];
    }
}

//静止旋转屏幕
-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return (UIInterfaceOrientationMaskPortrait);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken{
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSString *message = [[userInfo objectForKey:@"aps"]objectForKey:@"alert"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
