//
//  EarningViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EarningViewController.h"
#import "PastPayementViewController.h"
#import "MyReferralViewController.h"
#import "FinanceCalculatorViewController.h"
#import "ReferFriendViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "NavigationBar.h"
#import "ContentManager.h"

@interface EarningViewController ()

@end

@implementation EarningViewController
{
    NSNumber *userID;
    NSString *service;
    BOOL checkAgain;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    dmc = [[DataMapperController alloc] init];
    objManager = [ContentManager sharedManager];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    NSLog(@"Userid : %@",userID);
    self.navigationController.navigationBarHidden = NO;
     [self.navigationItem setTitle:@"Finance"];
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    WebserviceController *wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    //NSString *postStr = [NSString stringWithFormat:@"user_id=%@", userID];
    NSDictionary *dictData = @{@"user_id":userID};
    [wc call:dictData controller:@"user" method:@"getearningsdetails"];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    checkAgain = YES;
    NSTimer *timerGo = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(deviceOrientDetect) userInfo:nil repeats:NO];
    
}

-(void)deviceOrientDetect
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}

-(void)orient:(UIInterfaceOrientation)ott
{
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 480.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(480,400);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 568.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(568,400);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 190.0f, 1024.0f, 768.0f);
            scrollView.contentSize = CGSizeMake(1024,1000);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 320.0f, 327.0f);
            scrollView.contentSize = CGSizeMake(320,257);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 320.0f, 415.0f);
            scrollView.contentSize = CGSizeMake(320,320);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 185.0f, 768.0f, 800.0f);
            scrollView.contentSize = CGSizeMake(768,700);
            scrollView.bounces = NO;
        }
    }
}

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"login callback%@",data);
    
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    //get the userId
    if([data count] == 0 || exitCode == 0)
    {
        [SVProgressHUD dismissWithError:@"Failed To load Data"];
    }
    else
    {
        NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
        NSString *peopleRefStr = [NSString stringWithFormat:@"%@",[outPutData valueForKey:@"total_referrals"]];
        //NSString *projectedEarnStr = [NSString stringWithFormat:@"%@",[outPutData valueForKey:@"projected_earnings"]];
        NSString *totalEarnStr = [NSString stringWithFormat:@"%@",[outPutData valueForKey:@"total_earnings"]];
    
        totalEarningLabel.text = [@"£" stringByAppendingString:totalEarnStr];
        peopleReferredLabel.text = peopleRefStr;
       // projectedEarninglabel.text = [@"£" stringByAppendingString:projectedEarnStr];
        [SVProgressHUD dismissWithSuccess:@"Success"];
    }
}

- (IBAction)viewPastPaymentsBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    PastPayementViewController *pastPay = [[PastPayementViewController alloc] init];
    
    [self.navigationController pushViewController:pastPay animated:YES];
   
}

- (IBAction)financeCalculatorBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    FinanceCalculatorViewController *financeCalci = [[FinanceCalculatorViewController alloc] init];
    
    [self.navigationController pushViewController:financeCalci animated:YES];
}

- (IBAction)inviteMoreFriendsBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    ReferFriendViewController *referFriend = [[ReferFriendViewController alloc] init];
    
    [self.navigationController pushViewController:referFriend animated:YES];
    
}

- (IBAction)yourReferrelBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    MyReferralViewController *mtReffVC = [[MyReferralViewController alloc] init];
    
    [self.navigationController pushViewController:mtReffVC animated:YES];
}

#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar=[[NavigationBar alloc] init];
    
    UILabel *navTitle = [[UILabel alloc] init];
    
    if([objManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(310, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
            
            navTitle.font = [UIFont systemFontOfSize:36.0f];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            navTitle.frame = CGRectMake(410, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
            
            navTitle.font = [UIFont systemFontOfSize:36.0f];
        }
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(115, NavBtnYPosForiPhone, 95, NavBtnHeightForiPhone);
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                navTitle.frame = CGRectMake(200, NavBtnYPosForiPhone, 95, NavBtnHeightForiPhone);
                [navnBar loadNav:CGRectNull :true];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 568)
            {
                navTitle.frame = CGRectMake(245, NavBtnYPosForiPhone, 95, NavBtnHeightForiPhone);
                [navnBar loadNav:CGRectNull :true];
            }
        }
        
        
        navTitle.font = [UIFont systemFontOfSize:18.0f];

    }
    
    navTitle.text = @"My Money";
    [navnBar addSubview:navTitle];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
    if(!checkAgain)
    {
        WebserviceController *wc = [[WebserviceController alloc] init] ;
        wc.delegate = self;
        //NSString *postStr = [NSString stringWithFormat:@"user_id=%@", userID];
        NSDictionary *dictData = @{@"user_id":userID};
        [wc call:dictData controller:@"user" method:@"getearningsdetails"];
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    }
    checkAgain = NO;
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self addCustomNavigationBar];
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 480.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(480,400);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 568.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(568,400);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 190.0f, 1024.0f, 768.0f);
            scrollView.contentSize = CGSizeMake(1024,1000);
            scrollView.bounces = NO;
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 320.0f, 327.0f);
            scrollView.contentSize = CGSizeMake(320,257);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 320.0f, 415.0f);
            scrollView.contentSize = CGSizeMake(320,320);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 185.0f, 768.0f, 800.0f);
            scrollView.contentSize = CGSizeMake(768,700);
            scrollView.bounces = NO;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
