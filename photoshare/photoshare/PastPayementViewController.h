//
//  PastPayementViewController.h
//  photoshare
//
//  Created by ignis3 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WebserviceController.h"

@class ContentManager;
@interface PastPayementViewController : UIViewController <WebserviceDelegate>
{
    ContentManager *objManager;
}
@end
