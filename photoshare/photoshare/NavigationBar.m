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
#import "EarningViewController.h"


@implementation NavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        dmc = [[DataMapperController alloc] init];
        objManager = [ContentManager sharedManager];
        if(IS_OS_7_OR_LATER) navBarYPos=20;
        else navBarYPos=0;
        if(frame.size.width==0 || frame.size.height==0)
        {
            if([objManager isiPad])
                self.frame=CGRectMake(0, navBarYPos, MAIN_SCREEN_WIDTH, 160);
            else
                self.frame=CGRectMake(0, navBarYPos, MAIN_SCREEN_WIDTH,80);
        }
        
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [self setTintColor:[UIColor whiteColor]];
        [self setBackgroundColor:[UIColor whiteColor]];
        //set blank label for remove the extar line in ios 6
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH,self.frame.size.height)];
        label.backgroundColor=[UIColor whiteColor];
        label.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        [self addSubview:label];
        [self setTheSizeOfTheNavItem];
    }
    return self;
}
-(void)setTheSizeOfTheNavItem
{
    if([objManager isiPad])
    {
        topBlueLblHeight=16;
        topBlueLblYpos=0;
        
        homeLogoWidth=100;
        homeLogoHeight=50;
        homeLogoYpos=20;
        
        EarningLblWidth=240;
        EarningLblHeight=60;
        EarningLblYpos=20;
        
        EarningHeadingFontSize=20;
        EarningFontSize=36;
    }
    else
    {
        topBlueLblHeight=8;
        topBlueLblYpos=0;
        
        homeLogoWidth=50;
        homeLogoHeight=30;
        homeLogoYpos=10;
        
        EarningLblWidth=120;
        EarningLblHeight=30;
        EarningLblYpos=10;
        
        EarningHeadingFontSize=9;
        EarningFontSize=18;
    }
}
-(UIButton *)navBarLeftButton :(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
    /*[button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];*/
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:BTN_FONT_COLOR forState:UIControlStateNormal];
    
    
    if([objManager isiPad])
    {
        button.frame = NAVLEFT_BTN_FRAME_IPAD;
        button.titleLabel.font = [UIFont systemFontOfSize:30.0f];
    }
    else
    {
        button.frame=NAVLEFT_BTN_FRAME_IPHONE;
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    return button;


}
-(UILabel *)navBarTitleLabel :(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init ];
    titleLabel.text=title;
    titleLabel.textAlignment=NSTextAlignmentCenter;
    if([objManager isiPad])
    {
        titleLabel.frame = NAVTITLE_LABEL_FRAME_IPAD;
        titleLabel.font = [UIFont systemFontOfSize:30.0f];
    }
    else
    {
        titleLabel.frame=NAVTITLE_LABEL_FRAME_IPHONE;
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    //Set Auto Resize
    titleLabel.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    return titleLabel;
}

-(UIButton *)navBarRightButton :(NSString *)title
{
    UIButton *searchBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.contentHorizontalAlignment=NSTextAlignmentRight;
    [searchBtn setTitleColor:BTN_FONT_COLOR forState:UIControlStateNormal];
    //[searchBtn addTarget:self action:@selector(searchViewOpen) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitle:title forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    if([objManager isiPad])
    {
        searchBtn.frame=NAVRIGHT_BTN_FRAME_IPAD;
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:30.0f];
    }
    else
    {
        searchBtn.frame=NAVRIGHT_BTN_FRAME_IPHONE;
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];

    }
    //Set Auto Resize
    searchBtn.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    return searchBtn;
}
-(void)loadNav
{
    UITapGestureRecognizer *tapGesture;
    UITapGestureRecognizer *tapGestureHome;
    //Top Blue Label
    topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, topBlueLblYpos, MAIN_SCREEN_WIDTH, topBlueLblHeight)];
    topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
    topBlueLbl.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    //Home Logo
    logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, homeLogoYpos, homeLogoWidth, homeLogoHeight)];
    logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
    
    homeController = [[UIView alloc] initWithFrame:CGRectMake(7, homeLogoYpos, homeLogoWidth, homeLogoHeight)];
    homeController.layer.cornerRadius = 3;
    
    //Earning view
    totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-EarningLblWidth,EarningLblYpos, EarningLblWidth, EarningLblHeight)];
    totalEarningView.layer.cornerRadius=10;
    
    totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-EarningLblWidth, EarningLblYpos, EarningLblWidth, EarningLblHeight/2)];
    totalEarningHeading.textAlignment=NSTextAlignmentCenter;
    totalEarningHeading.text=@"This Week's Earnings";
    totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:EarningHeadingFontSize];
    totalEarningHeading.textColor=[UIColor blackColor];
    
    totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH-EarningLblWidth, EarningLblYpos+(EarningLblHeight/2), EarningLblWidth, EarningLblHeight/2)];
    totalEarning.font=[UIFont fontWithName:@"verdana" size:EarningFontSize];
    totalEarning.tag = 1;
    totalEarning.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    NSString *totalEarn=[@"£" stringByAppendingString:@"0"];
    totalEarning.text=totalEarn;
    totalEarning.textAlignment=NSTextAlignmentCenter;
    
    tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToEarningViewController)];
    [totalEarningView addGestureRecognizer:tapGesture];
    tapGestureHome = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToHomeViewController)];
    [homeController addGestureRecognizer:tapGestureHome];
   
    totalEarningHeading.backgroundColor=[UIColor clearColor];
    totalEarning.backgroundColor=[UIColor clearColor];
    
    //Set the auto resize
    totalEarningView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    totalEarningHeading.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    totalEarning.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    [self addSubview:topBlueLbl];
    [self addSubview:logoImg];
    [self addSubview:totalEarningView];
    [self addSubview:totalEarningHeading];
    [self addSubview:totalEarning];
    [self addSubview:homeController]; 
}
-(void)goToEarningViewController
{
    NSLog(@"Earning");
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    EarningViewController *evc=[[EarningViewController alloc] init];
    delegate.navControllerearning.viewControllers=[[NSArray alloc] initWithObjects:evc, nil];
    [delegate.tbc setSelectedIndex:1];
}

-(void)goToHomeViewController
{
    NSLog(@"Home VC");
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    HomeViewController *hvc=[[HomeViewController alloc] init];
    
    delegate.navControllerhome.viewControllers=[[NSArray alloc] initWithObjects:hvc, nil];
    
    [delegate.tbc setSelectedIndex:0];
    
}
-(void)setTheTotalEarning:(NSString *)earners
{
    totalEarning.text= [@"£" stringByAppendingString:earners];
    
}

/*
 
 -(void)loadNav:(CGRect)navFrame :(BOOL)orient
 {
 if(IS_OS_7_OR_LATER)
 {
 navBarYPos=20;
 }
 else
 {
 navBarYPos=0;
 }
 if([objManager isiPad])
 {
 if(orient)
 {
 if(CGRectIsNull(navFrame))
 {
 self.frame=CGRectMake(0, navBarYPos, 1024, 160);
 }
 else
 {
 self.frame = navFrame;
 }
 }
 else
 {
 if(CGRectIsNull(navFrame))
 {
 self.frame=CGRectMake(0, navBarYPos, 768, 160);
 }
 else
 {
 self.frame = navFrame;
 }
 }
 }
 else
 {
 if(orient)
 {
 if(CGRectIsNull(navFrame))
 {
 if([[UIScreen mainScreen] bounds].size.height == 480)
 {
 self.frame=CGRectMake(0, navBarYPos, 480, 80);
 }
 else if([[UIScreen mainScreen] bounds].size.height == 568)
 {
 self.frame=CGRectMake(0, navBarYPos, 568, 80);
 }
 
 }
 else
 {
 self.frame = navFrame;
 }
 }
 else
 {
 if(CGRectIsNull(navFrame))
 {
 self.frame=CGRectMake(0, navBarYPos, 320, 80);
 }
 else
 {
 self.frame = navFrame;
 }
 }
 
 }
 
 [self setTintColor:[UIColor whiteColor]];
 UITapGestureRecognizer *tapGesture;
 UITapGestureRecognizer *tapGestureHome;
 
 self.backgroundColor=[UIColor whiteColor];
 if([objManager isiPad])
 {
 if(orient)
 {
 topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, 16)];
 
 topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
 
 logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 30, 100, 50)];
 logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
 
 homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 30, 102, 51)];
 homeController.layer.cornerRadius = 3;
 
 totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(780,30, 200, 60)];
 
 totalEarningView.layer.cornerRadius=10;
 
 totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(780, 30, 230, 31)];
 totalEarningHeading.textAlignment=NSTextAlignmentCenter;
 
 totalEarningHeading.text=@"This Week's Earnings";
 totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:20];
 totalEarningHeading.textColor=[UIColor blackColor];
 
 totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(810, 60, 180, 30)];
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
 topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.frame.size.width, 16)];
 
 topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
 
 logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 30, 100, 50)];
 logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
 
 homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 30, 102, 51)];
 homeController.layer.cornerRadius = 3;
 
 totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(530,30, 200, 60)];
 
 totalEarningView.layer.cornerRadius=10;
 
 totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(530, 30, 230, 31)];
 totalEarningHeading.textAlignment=NSTextAlignmentCenter;
 totalEarningHeading.text=@"This Week's Earnings";
 totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:20];
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
 
 }
 else
 {
 if(orient)
 {
 if([[UIScreen mainScreen] bounds].size.height == 480)
 {
 topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 8)];
 
 topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
 
 logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 14, 50, 30)];
 logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
 
 homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 13, 55, 35)];
 homeController.layer.cornerRadius = 3;
 
 totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(365,20, 100, 30)];
 
 totalEarningView.layer.cornerRadius=10;
 
 totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(368, 10, 100, 21)];
 totalEarningHeading.textAlignment=NSTextAlignmentCenter;
 totalEarningHeading.text=@"This Week's Earnings";
 totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:9];
 totalEarningHeading.textColor=[UIColor blackColor];
 
 totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(368, 27, 100, 20)];
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
 else if([[UIScreen mainScreen] bounds].size.height == 568)
 {
 topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 8)];
 
 topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
 
 logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 14, 50, 30)];
 logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
 
 homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 13, 55, 35)];
 homeController.layer.cornerRadius = 3;
 
 totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(460,20, 100, 30)];
 
 totalEarningView.layer.cornerRadius=10;
 
 totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(460, 10, 100, 21)];
 totalEarningHeading.textAlignment=NSTextAlignmentCenter;
 totalEarningHeading.text=@"This Week's Earnings";
 totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:9];
 totalEarningHeading.textColor=[UIColor blackColor];
 
 totalEarning=[[UILabel alloc] initWithFrame:CGRectMake(460, 27, 100, 20)];
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
 else
 {
 topBlueLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 8)];
 
 topBlueLbl.backgroundColor=[UIColor colorWithRed:0.102 green:0.522 blue:0.773 alpha:1];
 
 logoImg=[[UIImageView alloc] initWithFrame:CGRectMake(7, 14, 50, 30)];
 logoImg.image=[UIImage imageNamed:@"123-mobile-logo.png"];
 
 homeController = [[UIView alloc] initWithFrame:CGRectMake(7, 13, 55, 35)];
 homeController.layer.cornerRadius = 3;
 
 totalEarningView=[[UIView alloc] initWithFrame:CGRectMake(215,20, 100, 30)];
 
 totalEarningView.layer.cornerRadius=10;
 
 totalEarningHeading=[[UILabel alloc] initWithFrame:CGRectMake(218, 10, 100, 21)];
 totalEarningHeading.textAlignment=NSTextAlignmentCenter;
 totalEarningHeading.text=@"This Week's Earnings";
 totalEarningHeading.font=[UIFont fontWithName:@"verdana" size:9];
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
 totalEarningHeading.backgroundColor=[UIColor clearColor];
 totalEarning.backgroundColor=[UIColor clearColor];
 [self addSubview:topBlueLbl];
 [self addSubview:logoImg];
 [self addSubview:totalEarningView];
 [self addSubview:totalEarningHeading];
 [self addSubview:totalEarning];
 [self addSubview:homeController];
 
 NSDictionary *dic =objManager.loginDetailsDict ;
 NSLog(@"Dictionary : %@",dic);
 }
 

 */

@end
