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
    
   wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    
    dmc = [[DataMapperController alloc] init] ;
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
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    if([objManager isiPad])
    {
        button.frame = CGRectMake(0.0, 105.0, 90.0, 40.0);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
    }
    else
    {
        button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
