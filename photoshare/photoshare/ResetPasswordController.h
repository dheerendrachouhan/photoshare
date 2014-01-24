//
//  ResetPasswordController.h
//  photoshare
//
//  Created by ignis3 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *emailTextField;
    IBOutlet UIButton *resetpasswordBtn;
    IBOutlet UIButton *resetBtn;
    BOOL reserFlt;
}
@end
