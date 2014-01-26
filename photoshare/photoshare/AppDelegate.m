//
//  AppDelegate.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ReferFriendViewController.h"
#import "EarningViewController.h"
#import "CommunityViewController.h"
#import "AccountViewController.h"
#import "PhotoViewController.h"
#import "HomeViewController.h"
#import "CommonTopView.h"
@implementation AppDelegate
@synthesize window,nv,tbc;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds] ] ;
  
    
    EarningViewController *ea = [[EarningViewController alloc] initWithNibName:@"EarningViewController" bundle:nil] ;

    CommunityViewController *com = [[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:nil] ;

    AccountViewController *acc = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] ;
    
    PhotoViewController *ph = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:nil] ;
    
    HomeViewController *hm = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil] ;

    CommonTopView *topView=[[CommonTopView alloc] init];
    
    
    UINavigationController* navControllerhome = [[UINavigationController alloc] initWithRootViewController:hm];
    
    navControllerhome.navigationBar.translucent=NO;
  //  [navControllerhome.view addSubview:topView];
  //  navControllerhome.navigationBar.frame=CGRectMake(0, 20, 320, 70);
 
    UINavigationController* navControllerearning = [[UINavigationController alloc] initWithRootViewController:ea];
   // CommonTopView *topView1=[[CommonTopView alloc] init];
    
   // CGRect tmpFram = navControllerhome.navigationBar.frame;
    //tmpFram.origin.y += 300;
  //  navControllerhome.navigationBar.frame = tmpFram;
    
    //navControllerearning.navigationBar.frame = CGRectMake(0.0, 200, 320.0, 100);

   navControllerearning.navigationBar.translucent=NO;
 //   [navControllerearning.view addSubview:topView1];
 //   navControllerearning.navigationBar.frame=CGRectMake(0, 10, 320, 200);
    UINavigationController* navControllerphoto = [[UINavigationController alloc] initWithRootViewController:ph];
    
    UINavigationController* navControllercommunity = [[UINavigationController alloc] initWithRootViewController:com];
   // CommonTopView *topView2=[[CommonTopView alloc] init];
    navControllercommunity.navigationBar.translucent=NO;
  //  [navControllercommunity.view addSubview:topView2];
  //  navControllercommunity.navigationBar.frame=CGRectMake(0, 20, 320, 70);
    
    
    UINavigationController* navControlleraccount = [[UINavigationController alloc] initWithRootViewController:acc];
  //  CommonTopView *topView3=[[CommonTopView alloc] init];
   navControlleraccount.navigationBar.translucent=NO;
  //  [navControlleraccount.view addSubview:topView3];
 //   navControlleraccount.navigationBar.frame=CGRectMake(0, 20, 320, 70);
    
   // UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:rf] ;
    
    //self.nv.navigationBar.barStyle = UIBarStyleBlackTranslucent ;
 
    UITabBarItem *tabBarItem = [[UITabBarItem alloc]  initWithTitle:@"" image:[UIImage  imageNamed:@"community-iconX30.png"] tag:1];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"earnings-iconX30.png"] tag:2];
    UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"icon-takephotoX30.png"] tag:3];
    UITabBarItem *tabBarItem4 = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"folder-icon-bottomX30.png"] tag:4];
    UITabBarItem *tabBarItem5 = [[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"cog-itemX30.png"] tag:5];
    
    
    self.tbc = [[UITabBarController alloc] init] ;
    
   //navigation controllers
    
    [navControllerhome setTabBarItem:tabBarItem];
    [navControllerearning setTabBarItem:tabBarItem2];
    [navControllerphoto setTabBarItem:tabBarItem3];
    [navControllercommunity setTabBarItem:tabBarItem4];
    [navControlleraccount setTabBarItem:tabBarItem5];
    
    tbc.viewControllers = [[NSArray alloc] initWithObjects:navControllerhome, navControllerearning,navControllerphoto, navControllercommunity, navControlleraccount, nil];
    
    
    topView.frame = CGRectMake(0, 5, 320, 30) ;
    [tbc.view addSubview:topView];
    
    
     
    
    self.window.rootViewController = tbc ;
    
    [self.window makeKeyAndVisible];
    
    
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
