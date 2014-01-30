//
//  UserSecurityViewController.m
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "UserSecurityViewController.h"
#import "WebserviceController.h"
@interface UserSecurityViewController ()

@end

@implementation UserSecurityViewController

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
    
    [oldpass setDelegate:self] ;
    [newpass setDelegate:self] ;
    
   wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    
    
}


-(IBAction)changepassword:(id)sender
{
    NSString *oldpassval = oldpass.text ;
    NSString *newpassval = newpass.text;
    
   // NSString *poststring = [NSString stringWithFormat:@"user_id=%@&user_password=%@&user_newpassword=%@", @"2", oldpassval, newpassval];
    
    NSDictionary *postdic = @{@"user_id":@"2",@"user_password":oldpassval,@"user_newpassword":newpassval} ;

    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
