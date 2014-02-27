//
//  UserSecurityViewController.m
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "UserSecurityViewController.h"
#import "WebserviceController.h"
#import "NavigationBar.h"
#import "ContentManager.h"

@interface UserSecurityViewController ()

@end

@implementation UserSecurityViewController
{
    NavigationBar *navnBar;
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
    // Do any additional setup after loading the view from its nib.
    
    [oldpass setDelegate:self] ;
    [newpass setDelegate:self] ;
    navnBar = [[NavigationBar alloc] init];
    wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    
    dmc = [[DataMapperController alloc] init] ;

    
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    
}
-(void)hideKeyboard :(UITapGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


-(IBAction)changepassword:(id)sender
{
    NSString *oldpassval = oldpass.text ;
    NSString *newpassval = newpass.text;
    
   // NSString *poststring = [NSString stringWithFormat:@"user_id=%@&user_password=%@&user_newpassword=%@", @"2", oldpassval, newpassval];
    
    NSString *userid = [dmc getUserId] ;
    NSDictionary *postdic = @{@"user_id":userid,@"user_password":oldpassval,@"user_newpassword":newpassval} ;

    
    [wc call:postdic controller:@"user" method:@"changepassword"];

    
    
}


-(void)webserviceCallback:(NSDictionary *)data
{
    
    NSLog(@"data--%@ ",data) ;
    
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }

- (IBAction)userCancelButton:(id)sender {
    
    
    UITextField *field = (UITextField *) [self.view viewWithTag:([sender tag] -10)];
    field.text = @"";
}

//Textfields functions
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    if([objManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
        }
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 90.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
        }
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        [self orient:self.interfaceOrientation];
    }
    else
    {
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
            scrollView.frame = CGRectMake(0, 60, 480, 250);
            scrollView.contentSize = CGSizeMake(480, 280);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 568, 250);
            scrollView.contentSize = CGSizeMake(568, 250);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 155, 1024, 400);
            scrollView.contentSize = CGSizeMake(1024, 500);
            scrollView.bounces = NO;
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 90, 320, 245);
            scrollView.contentSize = CGSizeMake(320, 160);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 90, 320, 270);
            scrollView.contentSize = CGSizeMake(320, 200);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 155, 768, 426);
            scrollView.contentSize = CGSizeMake(768, 250);
            scrollView.bounces = NO;
        }
    }
}


-(void)orient:(UIInterfaceOrientation)ott
{
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 480, 250);
            scrollView.contentSize = CGSizeMake(480, 280);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 60, 568, 250);
            scrollView.contentSize = CGSizeMake(568, 250);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 155, 1024, 400);
            scrollView.contentSize = CGSizeMake(1024, 500);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 90, 320, 245);
            scrollView.contentSize = CGSizeMake(320, 160);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 90, 320, 270);
            scrollView.contentSize = CGSizeMake(320, 200);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 155, 768, 426);
            scrollView.contentSize = CGSizeMake(768, 250);
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
