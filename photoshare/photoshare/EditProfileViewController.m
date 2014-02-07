//
//  EditProfileViewController.m
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditProfileViewController.h"
#import "WebserviceController.h"
#import "NavigationBar.h"
#import "ContentManager.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

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
  
    wc = [[WebserviceController alloc] init];
    wc.delegate = self;
    
    [name setDelegate:self] ;
    [email setDelegate:self] ;
    
    
    dmc  = [[DataMapperController alloc] init] ;
    
    [self getDetails] ;
    
    
   

}


-(void) getDetails
{
    
    calltype = @"getdetails";
    
    NSString *userid =[dmc getUserId] ;
    NSDictionary *dic = @{@"user_id":userid,@"target_user_id":userid};
    [wc call:dic controller:@"user" method:@"get"];

}



-(IBAction)saveProfile:(id)sender
{
    NSString *nameval = name.text ;
    NSString *emailval = email.text;
   
    calltype = @"saveprofile";
   
     NSString *userid =[dmc getUserId] ;
     NSDictionary *dic = @{@"user_id":userid,@"user_realname":nameval,@"user_emailaddress":emailval};
    
    [wc call:dic controller:@"user" method:@"change"];
    
    NSLog(@"save profile clicked");
}

-(void)webserviceCallback:(NSDictionary *)data
{
    
    NSLog(@"data--%@ ",data) ;
   if([calltype isEqualToString:@"getdetails"] )
   {
    name.text = [[[data valueForKey:@"output_data"] objectAtIndex:0] valueForKey:@"user_realname"] ;
    email.text = [[[data valueForKey:@"output_data"] objectAtIndex:0] valueForKey:@"user_emailaddress"];
       
   }
    if([calltype isEqualToString:@"saveprofile"])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    
    }
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
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 70)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 40, 70.0, 40.0);
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [navnBar addSubview:button];
    
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
