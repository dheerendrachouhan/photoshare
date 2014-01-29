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
#import "ContentManager.h"
#import "SVProgressHUD.h"

@interface EarningViewController ()

@end

@implementation EarningViewController
{
    NSNumber *userID;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    objManager = [ContentManager sharedManager];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userID = [objManager getData:@"user_id"];
    NSLog(@"Userid : %@",userID);
    
     [self.navigationItem setTitle:@"Finance"];
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    WebserviceController *wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    NSString *postStr = [NSString stringWithFormat:@"user_id=%@", userID];
    [wc call:postStr controller:@"user" method:@"getearningsdetails"] ;
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
}

-(void) webserviceCallback:(NSDictionary *)data
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
    pastPay.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
   
}

- (IBAction)financeCalculatorBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    FinanceCalculatorViewController *financeCalci = [[FinanceCalculatorViewController alloc] init];
    
    [self.navigationController pushViewController:financeCalci animated:YES];
    financeCalci.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

- (IBAction)inviteMoreFriendsBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    ReferFriendViewController *referFriend = [[ReferFriendViewController alloc] init];
    
    [self.navigationController pushViewController:referFriend animated:YES];
    referFriend.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

- (IBAction)yourReferrelBtn:(id)sender {
    self.navigationController.navigationBarHidden = NO;
    MyReferralViewController *mtReffVC = [[MyReferralViewController alloc] init];
    
    [self.navigationController pushViewController:mtReffVC animated:YES];
    mtReffVC.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
