//
//  MyReferralViewController.h
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"

@class ContentManager;
@interface MyReferralViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,WebserviceDelegate>
{
    IBOutlet UITableView *tableView;
    ContentManager *objManager;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
