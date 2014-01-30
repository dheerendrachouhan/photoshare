//
//  ReferFriendViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"

@class ContentManager;
@interface ReferFriendViewController : UIViewController <WebserviceDelegate>
{
    IBOutlet UISegmentedControl *toolboxController;
    IBOutlet UIWebView *webViewReferral;
    ContentManager *objManager;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *toolboxController;
@property (nonatomic, retain) IBOutlet UIWebView *webViewReferral;

@end
