//
//  ReferralStageFourVC.h
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Social/Social.h>
#import "WebserviceController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "DataMapperController.h"
#import "NavigationBar.h"

@class ContentManager;
@interface ReferralStageFourVC : UIViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, WebserviceDelegate, UITabBarControllerDelegate, UIActionSheetDelegate,UITextViewDelegate>
{
    IBOutlet UIButton *facebookBtn;
    IBOutlet UIButton *twitterBtn;
    IBOutlet UIButton *emailBt;
    IBOutlet UIButton *sendSMSBtn;
    IBOutlet UIImageView *customImage;
    
    //For Edit User MEssage
    IBOutlet UILabel *editMessageTitleLbl;
    IBOutlet UITextView *userMessage;
    IBOutlet UIButton *editMessageBtn;
    IBOutlet UIScrollView *scrollView;
    BOOL setterEdit;
    BOOL fbFilter,twFilter,mailFilter,smsFilter;
    
    BOOL isUserMessageEditing;
    DataMapperController *dmc;
    ContentManager *objManager;
    NavigationBar *navnBar ;
    IBOutlet UIView *emailView;
}

@property (weak, nonatomic) IBOutlet UITextView *emailContacts;
@property (weak, nonatomic) IBOutlet UITextView *emailMessageBody;
@property (strong, nonatomic) IBOutlet UIButton *FacebookShareLinkWithAPICallsButton;
@property (nonatomic, strong) NSString *stringStr;
@property (nonatomic, strong) NSString *twitterTweet;
@property (nonatomic, strong) NSString *toolkitLink;
@property (nonatomic, strong) NSString *referEmailStr;
@property (nonatomic, strong) NSString *referPhoneStr;
@property (nonatomic, strong) NSString *referredValue;

@end
