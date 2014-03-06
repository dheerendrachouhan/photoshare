
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
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //----------
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window.rootViewController = lg;
    [self.window makeKeyAndVisible];
    
    
    return YES;
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
    NSDictionary *dic=@{@"user_id":user_id,@"device_token":devToken,@"platform":@"4"};
    NSString *controller=@"PushController";
    NSString *method=@"registerDevice";
    [webservices call:dic controller:controller method:method];
}
//Web service call back method
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Push Notification Device Token is Register On Server%@",data);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    }

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
}
@end