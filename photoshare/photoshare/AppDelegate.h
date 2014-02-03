//
//  AppDelegate.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)UITabBarController *tbc;
@property (strong, nonatomic) UINavigationController *navControllerhome;
@property (strong, nonatomic) UINavigationController *navControllerearning;
@property (strong, nonatomic) UINavigationController *navControllerphoto;
@property (strong, nonatomic) UINavigationController *navControllercommunity;
@property (strong, nonatomic) UINavigationController *navControlleraccount;
@property (strong, nonatomic) UINavigationController *photoGalNav;

@end
