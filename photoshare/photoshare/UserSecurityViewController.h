//
//  UserSecurityViewController.h
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"

@class ContentManager;
@interface UserSecurityViewController : UIViewController <WebserviceDelegate, UITextFieldDelegate>
{
   IBOutlet UITextField *oldpass ;
   IBOutlet UITextField *newpass ;
    WebserviceController *wc ;
    DataMapperController *dmc ;
    ContentManager *objManager;
}


-(IBAction)changepassword:(id)sender ;
- (IBAction)userCancelButton:(id)sender ;



@end
