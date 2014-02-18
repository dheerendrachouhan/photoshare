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

@class ContentManager;
@interface ReferFriendViewController : UIViewController <WebserviceDelegate,UIWebViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    IBOutlet UIWebView *webViewReferral;
    ContentManager *objManager;
}
-(void)openHomeController;
@property (nonatomic, retain) IBOutlet UIWebView *webViewReferral;
@property (nonatomic, retain) NSString *toolKitReferralStr;
@property (nonatomic, retain) UICollectionView *collectionView;

@end
