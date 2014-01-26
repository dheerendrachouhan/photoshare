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
