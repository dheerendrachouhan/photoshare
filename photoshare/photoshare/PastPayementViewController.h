//
//  PastPayementViewController.h
//  photoshare
//
//  Created by ignis3 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"

@class ContentManager;
@interface PastPayementViewController : UIViewController <WebserviceDelegate>
{
    DataMapperController *dmc;
    ContentManager *objManager;
    IBOutlet UIScrollView *scrollView;
}
@end
