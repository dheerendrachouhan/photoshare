//
//  NavigationBar.h
//  photoshare
//
//  Created by ignis3 on 04/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataMapperController.h"

@class ContentManager;
@interface NavigationBar : UINavigationBar
{
    UILabel *topBlueLbl;
    UIImageView *logoImg;
    UIView *homeController;
    UIView *totalEarningView;
    UILabel *totalEarningHeading;
    UILabel *totalEarning;
    DataMapperController *dmc;
    ContentManager *objManager;
}

-(void)loadNav:(CGRect)naviFrame:(BOOL)orient;
-(void)goToEarningViewController;
-(void)setTheTotalEarning:(NSString *)earners;
-(void)goToHomeViewController;
@end
