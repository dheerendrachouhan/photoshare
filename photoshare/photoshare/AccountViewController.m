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
#import "HomeViewController.h"
#import "ContentManager.h"
#import "WebserviceController.h"
@interface AccountViewController ()

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"AccountViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"AccountViewController";
    }
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
    [self addCustomNavigationBar];
    [self setUIForIOS6];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUIForIOS6
{
    //Set for ios 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        profilePicImgView.frame=CGRectMake(0, 40, profilePicImgView.frame.size.width, profilePicImgView.frame.size.height+40);
        settingMenuContainerView.frame=CGRectMake(0, settingMenuContainerView.frame.origin.y+50,settingMenuContainerView.frame.size.width, settingMenuContainerView.frame.size.height);
    }
}
#pragma mark - IBAction Methods
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
    [self logOutFromServer];
    [self goToLoginPageAfterLogout];
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

#pragma mark - Logout methods
//logout from server
-(void)logOutFromServer
{
    @try {
        WebserviceController *ws=[[WebserviceController alloc] init];
        NSDictionary *dicData=@{@"user_id":[objManager getData:@"user_id"]};
        [ws call:dicData controller:@"authentication" method:@"logout"];
        //logout_device -- 'user_id','device_token'
        AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        NSDictionary *dicData2=@{@"user_id":[objManager getData:@"user_id"],@"device_token":delgate.token};
        [ws call:dicData2 controller:@"PushController" method:@"logout_device"];
    }
    @catch (NSException *exception) {
        
    }
}

-(void)goToLoginPageAfterLogout
{
    [dmc removeAllData];//remove data from nsuser default
    
    LoginViewController *login=[[LoginViewController alloc] init];
    [self presentViewController:login animated:NO completion:nil] ;
}

#pragma mark -  Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    CGFloat navBarYPos;
    CGFloat navBarHeight;
    if(IS_OS_7_OR_LATER) navBarYPos=20;
    else navBarYPos=0;
    if([objManager isiPad]) navBarHeight=110;
    else navBarHeight=60;
    
    navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, navBarYPos, [UIScreen mainScreen].bounds.size.width, navBarHeight)];
    [navnBar loadNav];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}
@end
