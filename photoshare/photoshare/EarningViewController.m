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

@interface EarningViewController ()

@end

@implementation EarningViewController
{
    NSNumber *userID;
    NSString *service;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    dmc = [[DataMapperController alloc] init];
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
        NSString *projectedEarnStr = [NSString stringWithFormat:@"%@",[outPutData valueForKey:@"projected_earnings"]];
        NSString *totalEarnStr = [NSString stringWithFormat:@"%@",[outPutData valueForKey:@"total_earnings"]];
    
        totalEarningLabel.text = [@"£" stringByAppendingString:totalEarnStr];
        peopleReferredLabel.text = peopleRefStr;
        projectedEarninglabel.text = [@"£" stringByAppendingString:projectedEarnStr];
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
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 90)];
    
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(130, 50, 80, 40)];
    navTitle.font = [UIFont systemFontOfSize:18.0f];
    navTitle.text = @"Finance";
    [navnBar addSubview:navTitle];
    
    [[self view] addSubview:navnBar];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
