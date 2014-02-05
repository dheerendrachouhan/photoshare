//
//  AccountViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AccountViewController.h"
#import "EditProfileViewController.h"
#import "UserSecurityViewController.h"
#import "TermConditionViewController.h"
#import "ReferFriendViewController.h"
#import "LoginViewController.h"
#import "NavigationBar.h"
#import "HomeViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

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
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)editProfile:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    EditProfileViewController *ep = [[EditProfileViewController alloc] init] ;
    
    [self.navigationController pushViewController:ep animated:YES] ;
    ep.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}
-(IBAction)userSecurity:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    UserSecurityViewController *us = [[UserSecurityViewController alloc] init] ;
    
    [self.navigationController pushViewController:us animated:YES] ;
    us.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);

}
-(IBAction)referFriend:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    ReferFriendViewController *rf = [[ReferFriendViewController alloc] init] ;
    
    [self.navigationController pushViewController:rf animated:YES] ;
rf.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
    
}
-(IBAction)logout:(id)sender
{
    LoginViewController *login = [[LoginViewController alloc] init] ;
    
    [self.navigationController presentViewController:login animated:NO completion:nil] ;


}
-(IBAction)termCondition:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    TermConditionViewController *tc = [[TermConditionViewController alloc] init] ;
    
    [self.navigationController pushViewController:tc animated:YES] ;
tc.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 48)];
    
    [[self view] addSubview:navnBar];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
   /*
    if([dmc gethomeIndex])
    {
        HomeViewController *hm =[[HomeViewController alloc] init];
        [self presentViewController:hm animated:NO completion:nil];
        [dmc resetHomeIndex];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
