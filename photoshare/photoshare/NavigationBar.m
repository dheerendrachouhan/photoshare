//
//  NavigationBar.m
//  photoshare
//
//  Created by ignis3 on 04/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "NavigationBar.h"
#import "ContentManager.h"
#import "AppDelegate.h"
#import "HomeViewController.h"

@implementation NavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        dmc = [[DataMapperController alloc] init];
        objManager = [ContentManager sharedManager];
        
        
        UITapGestureRecognizer *tapGesture;
        UITapGestureRecognizer *tapGestureHome;
        //self.frame=CGRectMake(0, 20, 320, 80);
        self.backgroundColor=[UIColor whiteColor];
        if([objManager isiPad])
        {
            topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, 16)];
            
            topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
            
            logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 30, 100, 50)];
            logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
            
            homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 30, 102, 51)];
            homeController.layer.cornerRadius = 3;
            
            totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(560,30, 200, 60)];
            //totalEarningView.backgroundColor=[UIColor grayColor];
            totalEarningView.layer.cornerRadius=10;
            
            totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(570, 30, 200, 31)];
            totalEarningHeading.textAlignment=NSTextAlignmentCenter;
            totalEarningHeading.text=@"Weekly Earnings";
            totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:22];
            totalEarningHeading.textColor=[UIColor blackColor];
            
            totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(570, 60, 180, 30)];
            totalEarning.font=[UIFont fontWithName:@"verdana" size:36];
            
            totalEarning.tag = 1;
            totalEarning.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
            NSString *totalEarn=[@"£" stringByAppendingString:@"0"];
            
            totalEarning.text=totalEarn;
            totalEarning.textAlignment=NSTextAlignmentCenter;
            
            tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToEarningViewController)];
            [totalEarningView addGestureRecognizer:tapGesture];
            
            tapGestureHome = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToHomeViewController)];
            [homeController addGestureRecognizer:tapGestureHome];
        }
        else
        {
        
        topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 8)];
        
        topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
        
        logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 14, 50, 30)];
        logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
        
        homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 13, 55, 35)];
        homeController.layer.cornerRadius = 3;
        
        totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(220,20, 100, 50)];
        //totalEarningView.backgroundColor=[UIColor grayColor];
        totalEarningView.layer.cornerRadius=10;
        
        totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(225, 10, 95, 21)];
        totalEarningHeading.textAlignment=NSTextAlignmentCenter;
        totalEarningHeading.text=@"Weekly Earnings";
        totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:11];
        totalEarningHeading.textColor=[UIColor blackColor];
        
        totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(225, 27, 100, 20)];
        totalEarning.font=[UIFont fontWithName:@"verdana" size:18];
        
        totalEarning.tag = 1;
        totalEarning.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
        NSString *totalEarn=[@"£" stringByAppendingString:@"0"];
        
        totalEarning.text=totalEarn;
        totalEarning.textAlignment=NSTextAlignmentCenter;
        
        tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToEarningViewController)];
        [totalEarningView addGestureRecognizer:tapGesture];
        
        tapGestureHome = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToHomeViewController)];
        [homeController addGestureRecognizer:tapGestureHome];
        }
        
    }
    [self addSubview:topBlueLbl];
    [self addSubview:logoImg];
    [self addSubview:totalEarningView];
    [self addSubview:totalEarningHeading];
    [self addSubview:totalEarning];
    [self addSubview:homeController];
    
    ContentManager *objManager=[ContentManager sharedManager];
    NSDictionary *dic =objManager.loginDetailsDict ;
    
   
    
    return self;
}

-(void)goToEarningViewController
{
    NSLog(@"Earning");
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate.tbc setSelectedIndex:1];
}

-(void)goToHomeViewController
{
   
    NSLog(@"Home VC");
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [delegate.tbc setSelectedIndex:0];
    /*
    ReferFriendViewController *referFriend = [[ReferFriendViewController alloc] init];
    [delegate.tbc setSelectedIndex:0 openHomeController];*/
    /*
    [dmc sethomeIndex];*/
}
-(void)setTheTotalEarning:(NSString *)earners
{
    totalEarning.text= [@"£" stringByAppendingString:earners];
    //UILabel *lb = (UILabel *) [self viewWithTag:1];
    //  [lb removeFromSuperview] ;
}

@end
