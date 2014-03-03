
//  AppDelegate.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@implementation AppDelegate
@synthesize window,tbc,photoGalNav;
@synthesize navControlleraccount,navControllercommunity,navControllerearning,navControllerhome,navControllerphoto;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    objManager = [ContentManager sharedManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds] ] ;
    
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
    //[self setDevieTokenOnServer:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"userInfo-- %@",userInfo);
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Notification Alert" message:@"Notification is Received" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:Nil, nil];
    [alert show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error.description);
}
/*-(void)setDevieTokenOnServer:(NSString *)devToken:(NSString *)user_id{
    WebServiceHelper *newsArcticleHlpr = [[WebServiceHelper alloc] init];
    
    [newsArcticleHlpr setDelegate:self];
    [newsArcticleHlpr setMethodResult:@""];
    [newsArcticleHlpr setMethodParameters:[[NSMutableDictionary alloc] init]];
    //user_id = [NSString stringWithFormat:@"%@",user_id];
    
    [newsArcticleHlpr setMethodName:[NSString stringWithFormat:@"registerDeviceVerTwo"]];
    [newsArcticleHlpr.MethodParameters setObject:[@"" stringByAppendingFormat:@"%@",devToken] forKey:@"token"];
    [newsArcticleHlpr.MethodParameters setObject:[@"" stringByAppendingFormat:@"%@",user_id] forKey:@"user_id"];
    
    [newsArcticleHlpr setMethodResult:@""];
    [newsArcticleHlpr setMethodType:@"POST"];
    [newsArcticleHlpr setCurrentCall:@"termsLNA"];
    
    [newsArcticleHlpr initiateConnection];
    
}*/

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
    notification.alertBody = @"Yoy have Notifications ";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
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
