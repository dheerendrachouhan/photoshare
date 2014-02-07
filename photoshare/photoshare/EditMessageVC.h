//
//  EditMessageVC.h
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentManager;
@interface EditMessageVC : UIViewController<UITextViewDelegate>
{
    IBOutlet UIImageView *custumImageBackground;
    IBOutlet UITextView *textMessage;
    ContentManager *objManager;
}

@property (nonatomic, strong) NSString *edittedMessage;

@end
