//
//  ReferFriendViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "NavigationBar.h"
@class ContentManager;
@interface ReferFriendViewController : UIViewController <WebserviceDelegate,UIWebViewDelegate,UIWebViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    IBOutlet UIWebView *webViewReferral;
    ContentManager *objManager;
    NavigationBar *navnBar;
    IBOutlet UIScrollView *scrollView;
    int activeIndex;
}

@property (nonatomic, retain) IBOutlet UIWebView *webViewReferral;
@property (nonatomic, retain) NSString *toolKitReferralStr;
@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) IBOutlet UIPickerView *mypicker;

@end
