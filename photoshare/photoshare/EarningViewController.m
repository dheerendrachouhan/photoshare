//
//  EarningViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EarningViewController.h"
#import "PastPayementViewController.h"

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
    
}


- (IBAction)viewPastPaymentsBtn:(id)sender {
    PastPayementViewController *ppVC = [[PastPayementViewController alloc] init];
    [self presentViewController:ppVC animated:YES completion:nil];
    
}

- (IBAction)financeCalculatorBtn:(id)sender {
}

- (IBAction)inviteMoreFriendsBtn:(id)sender {
}

- (IBAction)yourReferrelBtn:(id)sender {
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
