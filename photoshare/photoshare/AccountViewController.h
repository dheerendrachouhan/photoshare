//
//  AccountViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataMapperController.h"

@interface AccountViewController : UIViewController
{
    IBOutlet UIImageView *profilePicImgView;
    IBOutlet UIImageView *settingBackgroundImage;
    DataMapperController *dmc;
}

-(IBAction)editProfile:(id)sender;
-(IBAction)userSecurity:(id)sender;
-(IBAction)referFriend:(id)sender ;
-(IBAction)logout:(id)sender ;
-(IBAction)termCondition:(id)sender;
@end
