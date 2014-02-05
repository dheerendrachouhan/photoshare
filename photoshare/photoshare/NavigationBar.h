//
//  NavigationBar.h
//  photoshare
//
//  Created by ignis3 on 04/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataMapperController.h"

@interface NavigationBar : UINavigationBar
{
    UILabel *topBlueLbl;
    UIImageView *logoImg;
    UIView *homeController;
    UIView *totalEarningView;
    UILabel *totalEarningHeading;
    UILabel *totalEarning;
    DataMapperController *dmc;
}
-(void)goToEarningViewController;
-(void)setTheTotalEarning;
-(void)goToHomeViewController;
@end
