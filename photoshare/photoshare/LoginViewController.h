//
//  LoginViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate,UINavigationControllerDelegate>
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
}

@end
