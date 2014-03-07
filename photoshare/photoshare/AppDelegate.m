
//  AppDelegate.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.  22.67
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ReferFriendViewController.h"
@implementation AppDelegate
@synthesize window,tbc,photoGalNav;
@synthesize navControlleraccount,navControllercommunity,navControllerearning,navControllerhome,navControllerphoto;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    objManager = [ContentManager sharedManager];
    dmc=[[DataMapperController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginViewController *lg = [[LoginViewController alloc] init];
    if([objManager isiPad])
    {
        lg= [[LoginViewController alloc] initWithNibName:@"LoginViewControlleriPadMini" bundle:nil] ;
    }
    else
    {
        lg = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil] ;
    }
    // Register for Push Notifications
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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}
-(void)deregisterThepushNotification
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
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
    //NSLog(@"userInfo-- %@",userInfo);
    NSString *message=[[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    if([dmc getUserId])
    {
        if(([message rangeOfString:@"Video"].location != NSNotFound) || ([message rangeOfString:@"Upgrade"].location != NSNotFound))
        {
            [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
            if (application.applicationState==UIApplicationStateActive) {
                UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
                [notificationAlert setTag:101];
                [notificationAlert setDelegate:self];
                [notificationAlert show];
            }
            else if (application.applicationState==UIApplicationStateInactive || application.applicationState==UIApplicationStateBackground) {
                //Open the invite Friend view controller
                ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
                [self.navControllerhome pushViewController:rvc animated:YES];
            }
        }
        else
        {
            [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
            if (application.applicationState==UIApplicationStateActive) {
                UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [notificationAlert show];
            }
        }
    }
}
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //NSLog(@"userInfo-- %@",userInfo);
    NSString *message=[[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    if([dmc getUserId])
     {
    if(([message rangeOfString:@"Video"].location != NSNotFound) || ([message rangeOfString:@"Upgrade"].location != NSNotFound))
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
        if (application.applicationState==UIApplicationStateActive) {
            UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:message delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"View", nil];
            [notificationAlert setTag:101];
            [notificationAlert setDelegate:self];
            [notificationAlert show];
        }
        else if (application.applicationState==UIApplicationStateInactive || application.applicationState==UIApplicationStateBackground) {
            //Open the invite Friend view controller
            ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
            [self.navControllerhome pushViewController:rvc animated:YES];
        }
    }
    else
    {
        [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
        if (application.applicationState==UIApplicationStateActive) {
            UIAlertView * notificationAlert = [[UIAlertView alloc] initWithTitle:@"Alert !" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [notificationAlert show];
        }
    }
    }

}

#pragma mark - UIAlert view delgate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        if (buttonIndex == 1) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            ReferFriendViewController *rvc=[[ReferFriendViewController alloc] init];
            [self.navControllerhome pushViewController:rvc animated:YES];
        }
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error.description);
}

//Set device  token on the server
-(void)setDevieTokenOnServer:(NSString *)devToken userid:(NSString *)user_id{
    webservices=[[WebserviceController alloc] init];
    webservices.delegate=self;
    NSDictionary *dic=@{@"user_id":user_id,@"device_token":devToken,@"platform":@"3"};    //Platfom 3-IOS and 4-Android
    NSString *controller=@"PushController";
    NSString *method=@"registerDevice";
    [webservices call:dic controller:controller method:method];
}
//Web service call back method
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Device Token is Register On Server%@",data);
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
   
}
@end