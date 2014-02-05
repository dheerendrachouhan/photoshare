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

@implementation NavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //self.frame=CGRectMake(0, 20, 320, 80);
        self.backgroundColor=[UIColor whiteColor];
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
        totalEarningHeading.text=@"weekly earnings";
        totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:11];
        totalEarningHeading.textColor=[UIColor blackColor];
        
        totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(225, 27, 100, 20)];
        totalEarning.font=[UIFont fontWithName:@"verdana" size:18];
        
        totalEarning.tag = 1;
        totalEarning.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
        NSString *totalEarn=[@"£" stringByAppendingString:@"0.0"];
        
        totalEarning.text=totalEarn;
        totalEarning.textAlignment=NSTextAlignmentCenter;
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToEarningViewController)];
        [totalEarningView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer *tapGestureHome = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToHomeViewController)];
        [homeController addGestureRecognizer:tapGestureHome];
        
    }
    [self addSubview:topBlueLbl];
    [self addSubview:logoImg];
    [self addSubview:totalEarningView];
    [self addSubview:totalEarningHeading];
    [self addSubview:totalEarning];
    [self addSubview:homeController];
    
    ContentManager *objManager=[ContentManager sharedManager];
    NSDictionary *dic =objManager.loginDetailsDict ;
    
    NSLog(@"User id is %@",[dic objectForKey:@"user_id"]);
    
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
}
-(void)setTheTotalEarning
{
    //   totalEarning.text=totalEarn;
    //UILabel *lb = (UILabel *) [self viewWithTag:1];
    //  [lb removeFromSuperview] ;
}

@end