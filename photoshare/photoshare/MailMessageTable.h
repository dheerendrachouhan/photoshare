//
//  MailMessageTable.h
//  photoshare
//
//  Created by ignis3 on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentManager;
@interface MailMessageTable : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    ContentManager *objManager;
}
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) NSMutableDictionary *contactDictionary;
@property (nonatomic, strong) NSString *filterType;
@end
