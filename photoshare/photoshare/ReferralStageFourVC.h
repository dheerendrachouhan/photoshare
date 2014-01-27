//
//  ReferralStageFourVC.h
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReferralStageFourVC : UIViewController
{
    IBOutlet UIButton *facebookBtn;
    IBOutlet UIButton *twitterBtn;
    IBOutlet UIButton *emailBt;
    IBOutlet UIButton *sendSMSBtn;
    IBOutlet UIImageView *customImage;
    IBOutlet UITextView *userMessage;
    IBOutlet UIButton *editMessageBtn;
    IBOutlet UIButton *sendMessageBtn;
    IBOutlet UIScrollView *scrollView;
    BOOL setterEdit;
}

@property (nonatomic, strong) NSString *stringStr;

@end
