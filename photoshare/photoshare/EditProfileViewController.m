//
//  EditProfileViewController.m
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditProfileViewController.h"
#import "WebserviceController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

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
    // Do any additional setup after loading the view from its nib.
  
    wc = [[WebserviceController alloc] init];
    wc.delegate = self;
    
    [name setDelegate:self] ;
    [email setDelegate:self] ;
    
    [self getDetails] ;
    
    
   

}


-(void) getDetails
{
    
    calltype = @"getdetails";
     NSString *poststring = [NSString stringWithFormat:@"user_id=%@&target_user_id=%@", @"2",@"2"];
    
    [wc call:poststring controller:@"user" method:@"get"];
    
   // NSString *postStr = [NSString stringWithFormat:@""];

}



-(IBAction)saveProfile:(id)sender
{
    NSString *nameval = name.text ;
    NSString *emailval = email.text;
   
    calltype = @"saveprofile";
    NSString *poststring = [NSString stringWithFormat:@"user_id=%@&user_realname=%@&user_emailaddress=%@", @"2", nameval, emailval];
  
    
    [wc call:poststring controller:@"user" method:@"change"];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
