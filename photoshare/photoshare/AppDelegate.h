//
//  AppDelegate.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *nv;
@property (strong, nonatomic)UITabBarController *tbc;
@property (nonatomic, retain) UINavigationController *navControllerearning;
@property (nonatomic, retain) UINavigationController *navControllercommunity;

@end
