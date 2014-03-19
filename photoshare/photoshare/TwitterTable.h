//
//  TwitterTable.h
//  photoshare
//
//  Created by ignis3 on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavigationBar.h"
@class ContentManager;
@interface TwitterTable : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    ContentManager *objManager;
    NavigationBar *navnBar;
    
}
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) NSArray *tweetUserName;
@end
