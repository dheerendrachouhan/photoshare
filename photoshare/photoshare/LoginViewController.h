//
//  LoginViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WebserviceController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ContentManager.h"
#import "DataMapperController.h"
#import <MessageUI/MessageUI.h>

@class ContentManager;
@interface LoginViewController : UIViewController <UITextFieldDelegate, WebserviceDelegate,UITabBarControllerDelegate,MFMailComposeViewControllerDelegate>
{
    IBOutlet UIImageView *loginBackgroundImage;
    IBOutlet UIImageView *loginLogoImage;
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet UIButton *signinBtn;
    IBOutlet UIScrollView *scrollView;
    BOOL usrFlt, pwsFlt;
    IBOutlet UIButton *namecancelBtn;
    IBOutlet UIButton *passwordcancelBtn;
    IBOutlet UIButton *rememberMeBtn;
    BOOL rememberFltr;
    
    NSNumber *userid;
    
    UIView *dataFetchView;
    WebserviceController *webservices;
    ContentManager *manager;
    
    BOOL isGetTheCollectionListData;
    BOOL isGetLoginDetail;
    BOOL isGetStorage;
    DataMapperController *dmc;
    ContentManager *objManager;
}
@property(nonatomic,retain)ALAssetsLibrary *library;
- (IBAction)rememberBtnTapped;
@end
