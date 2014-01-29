//
//  ReferralStageFourVC.h
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Social/Social.h>
#import "WebserviceController.h"
#import <FacebookSDK/FacebookSDK.h>

@class ContentManager;
@interface ReferralStageFourVC : UIViewController<MFMailComposeViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate,MFMessageComposeViewControllerDelegate,FBFriendPickerDelegate>
{
    IBOutlet UIButton *facebookBtn;
    IBOutlet UIButton *twitterBtn;
    IBOutlet UIButton *emailBt;
    IBOutlet UIButton *sendSMSBtn;
    IBOutlet UIImageView *customImage;
    IBOutlet UITextView *userMessage;
    IBOutlet UIButton *editMessageBtn;
    IBOutlet UIScrollView *scrollView;
    BOOL setterEdit;
    BOOL fbFilter,twFilter,mailFilter,smsFilter;
    ContentManager *objManager;
}

@property (nonatomic, strong) NSString *stringStr;

@end
