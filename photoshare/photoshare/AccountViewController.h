//
//  AccountViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//** Phasepass and key store password is “123456”.

#import <UIKit/UIKit.h>
#import "DataMapperController.h"

@class ContentManager;
@interface AccountViewController : UIViewController
{
    IBOutlet UIImageView *profilePicImgView;
    IBOutlet UIImageView *settingBackgroundImage;
    DataMapperController *dmc;
    ContentManager *objManager;
}

-(IBAction)editProfile:(id)sender;
-(IBAction)userSecurity:(id)sender;
-(IBAction)referFriend:(id)sender ;
-(IBAction)logout:(id)sender ;
-(IBAction)termCondition:(id)sender;
@end
