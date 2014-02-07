//
//  EarningViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"

@class ContentManager;
@interface EarningViewController : UIViewController<WebserviceDelegate>
{
    IBOutlet UILabel *totalEarningLabel;
    IBOutlet UILabel *projectedEarninglabel;
    IBOutlet UILabel *peopleReferredLabel;
    DataMapperController *dmc;
    ContentManager *objManager;
}

@end
