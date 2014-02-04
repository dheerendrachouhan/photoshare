//
//  NavigationBar.h
//  photoshare
//
//  Created by ignis3 on 04/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBar : UINavigationBar
{
    UILabel *topBlueLbl;
    UIImageView *logoImg;
    UIView *homeController;
    UIView *totalEarningView;
    UILabel *totalEarningHeading;
    UILabel *totalEarning;
}
-(void)goToEarningViewController;
-(void)setTheTotalEarning;
-(void)goToHomeViewController;
@end
