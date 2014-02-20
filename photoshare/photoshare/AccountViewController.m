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
#import "ContentManager.h"

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
    objManager = [ContentManager sharedManager];
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

    EditProfileViewController *ep;
    if([objManager isiPad])
    {
        ep = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        ep = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    [self.navigationController pushViewController:ep animated:YES] ;
    ep.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}
-(IBAction)userSecurity:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    UserSecurityViewController *us;
    if([objManager isiPad])
    {
        us = [[UserSecurityViewController alloc] initWithNibName:@"UserSecurityViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else{
        us = [[UserSecurityViewController alloc] initWithNibName:@"UserSecurityViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    [self.navigationController pushViewController:us animated:YES] ;
    us.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);

}
-(IBAction)referFriend:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    ReferFriendViewController *rf;
    if([objManager isiPad])
    {
        rf = [[ReferFriendViewController alloc] initWithNibName:@"ReferFriendViewController_iPad" bundle:[NSBundle mainBundle]] ;

    }
    else
    {
        rf = [[ReferFriendViewController alloc] initWithNibName:@"ReferFriendViewController" bundle:[NSBundle mainBundle]] ;
    }
    [self.navigationController pushViewController:rf animated:YES] ;
rf.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
    
}
-(IBAction)logout:(id)sender
{
    [dmc removeAllData];//remove data from nsuser default
    
    LoginViewController *login;
    if([objManager isiPad])
    {
        login= [[LoginViewController alloc] initWithNibName:@"LoginViewControlleriPadMini" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        login= [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:[NSBundle mainBundle]] ;
    }
    [self presentViewController:login animated:NO completion:nil] ;

}
-(IBAction)termCondition:(id)sender
{
    self.navigationController.navigationBarHidden = NO;

    TermConditionViewController *tc;
    if([objManager isiPad])
    {
        tc = [[TermConditionViewController alloc] initWithNibName:@"TermConditionViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        tc = [[TermConditionViewController alloc] initWithNibName:@"TermConditionViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    [self.navigationController pushViewController:tc animated:YES] ;
tc.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];
    if([objManager isiPad])
    {
        navnBar.frame=CGRectMake(0, 20, self.view.frame.size.width, 110);
    }
    else
    {
        navnBar.frame=CGRectMake(0, 20, 320, 48);
    }
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
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
