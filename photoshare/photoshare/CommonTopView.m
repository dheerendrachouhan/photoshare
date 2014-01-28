//
//  CommonTopView.m
//  photoshare
//
//  Created by ignis2 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "CommonTopView.h"
#import "EarningViewController.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
@implementation CommonTopView


static CommonTopView *topView=nil;

+(CommonTopView *)sharedTopView
{
    if(topView==nil)
    {
        topView=[[CommonTopView alloc] init];
    }
    return topView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=CGRectMake(0, 20, 320, 50 );
        self.backgroundColor=[UIColor whiteColor];
        topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 8)];
        
        topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
        
        logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 14, 50, 30)];
        logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
        
        
        totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(220,20, 100, 50)];
        //totalEarningView.backgroundColor=[UIColor grayColor];
        totalEarningView.layer.cornerRadius=10;
        
        totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(225, 10, 100, 21)];
        totalEarningHeading.textAlignment=NSTextAlignmentCenter;
        totalEarningHeading.text=@"total earnings";
        totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:11];
        totalEarningHeading.textColor=[UIColor blackColor];
        
        totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(225, 27, 100, 20)];
        totalEarning.font=[UIFont fontWithName:@"verdana" size:18];
        
        totalEarning.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
        NSString *totalEarn=[@"£" stringByAppendingString:@"190.90"];
        
        totalEarning.text=totalEarn;
        totalEarning.textAlignment=NSTextAlignmentCenter;
        
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToEarningViewController)];
        [totalEarningView addGestureRecognizer:tapGesture];
    }
    [self addSubview:topBlueLbl];
    [self addSubview:logoImg];
    [self addSubview: totalEarningView];
    [self addSubview:totalEarningHeading];
    [self addSubview:totalEarning];
    
    return self;
}
-(void)goToEarningViewController
{
    NSLog(@"Earning");
 
    UITabBarController *tb = (UITabBarController *) self.window.rootViewController ;
    
    [tb setSelectedIndex:1] ;
 }
-(void)setTheTotalEarning:(NSString *)totalEarn
{
    totalEarning.text=totalEarn;
    
}

@end
