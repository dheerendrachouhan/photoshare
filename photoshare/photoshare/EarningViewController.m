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

@interface EarningViewController ()

@end

@implementation EarningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [self.navigationItem setTitle:@"Finance"];
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}



- (IBAction)viewPastPaymentsBtn:(id)sender {
    PastPayementViewController *pastPay = [[PastPayementViewController alloc] init];
    
    [self.navigationController pushViewController:pastPay animated:YES];
    self.navigationController.navigationBar.frame=CGRectMake(0, 0, 320, 90);
   
}

- (IBAction)financeCalculatorBtn:(id)sender {
    FinanceCalculatorViewController *financeCalci = [[FinanceCalculatorViewController alloc] init];
    
    [self.navigationController pushViewController:financeCalci animated:YES];
    self.navigationController.navigationBar.frame=CGRectMake(0, 0, 320, 90);
}

- (IBAction)inviteMoreFriendsBtn:(id)sender {
    ReferFriendViewController *referFriend = [[ReferFriendViewController alloc] init];
    
    [self.navigationController pushViewController:referFriend animated:YES];
    self.navigationController.navigationBar.frame=CGRectMake(0, 0, 320, 90);
}

- (IBAction)yourReferrelBtn:(id)sender {
    MyReferralViewController *mtReffVC = [[MyReferralViewController alloc] init];
    
    [self.navigationController pushViewController:mtReffVC animated:YES];
    self.navigationController.navigationBar.frame=CGRectMake(0, 0, 320, 90);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
