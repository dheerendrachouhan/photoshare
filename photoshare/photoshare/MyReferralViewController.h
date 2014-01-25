//
//  MyReferralViewController.h
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyReferralViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *tableView;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
