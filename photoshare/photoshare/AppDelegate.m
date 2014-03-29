
//  AppDelegate.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.  22.67
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ReferFriendViewController.h"
#import "EarningViewController.h"
@implementation AppDelegate
@synthesize window,tbc,photoGalNav;
@synthesize navControlleraccount,navControllercommunity,navControllerearning,navControllerhome,navControllercamera;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    objManager = [ContentManager sharedManager];
    dmc=[[DataMapperController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    LoginViewController *lg = [[LoginViewController alloc] init];
    //FBLogin View Class
    [FBLoginView class];
    //Register for Push Notifications
    [self registerThepushNotification:application];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window.rootViewController = lg;
    [self.window makeKeyAndVisible];
    return YES;
}
-(void)registerThepushNotification:(UIApplication *)application
{
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
}
#pragma mark - UIApplication Push-Notifications
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    _token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"My token is: %@", _token);
}

//When Remote Notification is Received
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self receiveNotification:application userInfo:userInfo];
}
 -(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self receiveNotification:application userInfo:userInfo];
}
-(void)receiveNotification :(UIApplication *)application userInfo:(NSDictionary *)userInfo
{
    NSString *message=[[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    NSString *type=[userInfo objectForKey:@"type"];
    NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
    numberOfBadges -=1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
        if([type isEqualToString:@"video"])
        {
            if (application.applicationState==UIApplicationStateActive) {
                UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification !" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
                [notificationAlert setTag:101];
                [notificationAlert setDelegate:self];
                [notificationAlert show];
            }
            else if (application.applicationState==UIApplicationStateInactive || application.applicationState==UIApplicationStateBackground) {
                //[self.tbc setSelectedIndex:0];
                ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
                [self.navControllerhome pushViewController:rvc animated:YES];
            }
        }
        else if ([type isEqualToString:@"earn"])
        {
            if (application.applicationState==UIApplicationStateActive)
            {
                UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Notification !" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
                [notificationAlert setTag:102];
                [notificationAlert setDelegate:self];
                [notificationAlert show];
            }
            else if (application.applicationState==UIApplicationStateInactive || application.applicationState==UIApplicationStateBackground) {
                @try
                {
                    [self.tbc setSelectedIndex:1];
                }
                @catch (NSException *exception)
                {
                }
            }
        }
        else
        {
            if (application.applicationState==UIApplicationStateActive)
            {
                UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [notificationAlert show];
            }
        }
}
#pragma mark - UIAlert view delgate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
        numberOfBadges -=1;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
        if (buttonIndex == 1)
        {
            @try
            {
                //[self.tbc setSelectedIndex:0];
                ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
                [self.navControllerhome pushViewController:rvc animated:YES];
            }
            @catch (NSException *exception)
            {
                
            }
        }
    }
    else if (alertView.tag == 102) {
        EarningViewController *earnView=[[EarningViewController alloc] init];
        if (buttonIndex == 1)
        {
            @try
            {
                self.navControllerearning.viewControllers=[[NSArray alloc] initWithObjects:earnView, nil];
                [self.tbc setSelectedIndex:1];
            }
            @catch (NSException *exception)
            {
            }
        }
        else if (buttonIndex==0)
        {
            @try
            {
                [earnView getIncomeFromServer];
            }
             @catch (NSException *exception)
            {
                
            }
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error.description);
}

//Set Device token on the Server
-(void)setDevieTokenOnServer:(NSString *)devToken userid:(NSString *)user_id{
    webservices=[[WebserviceController alloc] init];
    webservices.delegate=self;
    NSDictionary *dic=@{@"user_id":user_id,@"device_token":devToken,@"platform":@"3"};    //Platfom 3-IOS and 4-Android
    NSString *controller=@"push";
    NSString *method=@"register_device";
    [webservices call:dic controller:controller method:method];
}
//Web service call back method
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Device_Token is Register On Server%@",data);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Crash" message:@"Your application is crash" delegate:Nil cancelButtonTitle:@"ok" otherButtonTitles:Nil, nil];
    [alert show];
}
#pragma mark - FaceBook AppCall
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Parse the incoming URL to look for a target_url parameter
                                      NSString *query = [url fragment];
                                      if (!query) {
                                          query = [url query];
                                      }
                                      NSDictionary *params = [self parseURLParams:query];
                                      // Check if target URL exists
                                      NSString *targetURLString = [params valueForKey:@"target_url"];
                                      if (targetURLString) {
                                          // Show the incoming link in an alert
                                          // Your code to direct the user to the appropriate flow within your app goes here
                                          [[[UIAlertView alloc] initWithTitle:@"Received link:"                                                                      message:targetURLString                                                                     delegate:self                                                            cancelButtonTitle:@"OK"                                                            otherButtonTitles:nil] show];
                                      }
                                  }];
    
    return urlWasHandled;
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

@end