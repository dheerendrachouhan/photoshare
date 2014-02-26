//
//  FBTWViewController.h
//  photoshare
//
//  Created by ignis3 on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentManager;
@interface FBTWViewController : UIViewController
{
    IBOutlet UIImageView *scocialType;
    ContentManager *objManager;
}
@property (nonatomic, strong) NSString *successType;
@property (nonatomic, strong) IBOutlet UILabel *success;

@end
