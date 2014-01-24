//
//  CommonTopView.h
//  photoshare
//
//  Created by ignis2 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonTopView : UIView
{
    UILabel *topBlueLbl;
    UIImageView *logoImg;
    
    UIView *totalEarningView;
    UILabel *totalEarningHeading;
    UILabel *totalEarning;
}
-(void)goToEarningViewController;
+(CommonTopView *)sharedTopView;
@end
