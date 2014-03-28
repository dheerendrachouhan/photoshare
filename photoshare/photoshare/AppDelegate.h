//
//  AppDelegate.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import <FacebookSDK/FacebookSDK.h>
@class ContentManager;
@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,WebserviceDelegate>
{
    ContentManager *objManager;
    WebserviceController *webservices;
    DataMapperController *dmc;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic)UITabBarController *tbc;
@property (strong, nonatomic) UINavigationController *navControllerhome;
@property (strong, nonatomic) UINavigationController *navControllerearning;
@property (strong, nonatomic) UINavigationController *navControllercamera;
@property (strong, nonatomic) UINavigationController *navControllercommunity;
@property (strong, nonatomic) UINavigationController *navControlleraccount;
@property (strong, nonatomic) UINavigationController *photoGalNav;

//Device token for Push notification
@property (strong, nonatomic) NSString *token;
@property(nonatomic,assign)BOOL isGoToReferFriendController;
-(void)setDevieTokenOnServer:(NSString *)devToken userid:(NSString *)user_id;
@end
