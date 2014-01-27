//
//  EditProfileViewController.h
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController
{

    IBOutlet UITextField *name ;
    IBOutlet UITextField *surname;
    IBOutlet UIImage *img ;
    IBOutlet UIButton *changeimg ;
    IBOutlet UIButton *save;
    
}



-(IBAction)changeProfileImg:(id)sender ;
-(IBAction)saveProfile:(id)sender ;



@end
