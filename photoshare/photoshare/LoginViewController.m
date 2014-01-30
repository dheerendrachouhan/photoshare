//
//  LoginViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "CommunityViewController.h"
#import "EarningViewController.h"
#import "ReferFriendViewController.h"
#import "AccountViewController.h"
#import "PhotoViewController.h"
#import "ResetPasswordController.h"
#import "CommonTopView.h"
#import "WebserviceController.h"
#import "ContentManager.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

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
    nameTextField.text = @"cliffrichard";
    passwordTextField.text = @"spaceman99";
    // Do any additional setup after loading the view from its nib.
    [nameTextField setDelegate:self];
    [passwordTextField setDelegate:self];
    //add the border color in username and password textfield
    //temp Hidden
   // loginBackgroundImage.hidden=YES;
    
    signinBtn.layer.cornerRadius = 6.0;
    usrFlt = NO;
    pwsFlt = NO;
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 10)];
    [nameTextField setLeftViewMode:UITextFieldViewModeAlways];
    [nameTextField setLeftView:spacerView];
    UIView *spacerViews = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 10)];
    [passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    [passwordTextField setLeftView:spacerViews];
    
}

//user sign in function
- (IBAction)userSignInBtn:(id)sender {
    
    //Without Validation
    //[self dismissViewControllerAnimated:YES completion:nil] ;
    
    NSString *username = [nameTextField text];
    NSString *password = [passwordTextField text];
    if(nameTextField.text.length==0||passwordTextField.text.length==0)
    {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter UserName and Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if([nameTextField.text length] > 0 || [passwordTextField.text length] > 0)
    {
        WebserviceController *wc = [[WebserviceController alloc] init] ;
        wc.delegate = self;
        NSString *postStr = [NSString stringWithFormat:@"username=%@&password=%@", username, password] ;
        [wc call:postStr controller:@"authentication" method:@"login"] ;
    }
}

-(void) webserviceCallback:(NSDictionary *)data
{
    NSLog(@"login callback%@",data);
    
    
   
         //validate the user
    if([[data objectForKey:@"user_message"] isEqualToString:@"Login Successful"])
        {
            //get the userId
            NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
            NSDictionary *dic=[outPutData objectAtIndex:0];
            //Setting values globally
            ContentManager *objManager=[ContentManager sharedManager];
            objManager.loginDetailsDict = dic;
            
            //Setting the TopView
            CommonTopView *topView=[CommonTopView sharedTopView];
            //[topView setTheTotalEarning:[NSString stringWithFormat:@"%@",[objManager.loginDetailsDict objectForKey:@"total_earnings"]]];
            ///
            
            NSNumber *userid=[dic objectForKey:@"user_id"];
            
            NSLog(@"User id is %@",[dic objectForKey:@"user_id"]);
            
            //store the UserId in NSUser Defaults
            ContentManager *manager=[ContentManager sharedManager];
            [manager storeData:userid :@"user_id"];      
            
            [self dismissViewControllerAnimated:YES completion:nil] ;
            NSLog(@"Successful Login");
            
        }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)ifFirstTimeLogin
{
    //check is Application is First Launch
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        NSLog(@"// app already launched");
    }
    else
    {
        NSLog(@"// First time launched");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

//forgot password function
- (IBAction)forgotPasswordBtn:(id)sender {
    ResetPasswordController *resetpwd = [[ResetPasswordController alloc] init];
    [self presentViewController:resetpwd animated:YES completion:nil];
}


//Textfields functions
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(textField.tag == 1)
    {
        usrFlt =NO;
    }
    else if(textField.tag ==2)
    {
        pwsFlt = NO;
    }
    return YES;
}

- (IBAction)userCancelButton:(id)sender {
    if(usrFlt)
    {
        nameTextField.text = @"";
        usrFlt = NO;
        [namecancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)passwordCancelBtn:(id)sender {
    passwordTextField.text = @"";
    pwsFlt = NO;
    [passwordcancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.tag ==1) {
        if([nameTextField.text length] > 0)
        {
            usrFlt =YES;
            [namecancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        }
        else if([nameTextField.text length] == 0 )
        {
            usrFlt =NO;
            [namecancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        }
    }
    else if(textField.tag ==2)
    {
        if([passwordTextField.text length] > 0)
        {
            pwsFlt = YES;
            [passwordcancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        }
        else if([passwordTextField.text length] == 0)
        {
            pwsFlt = NO;
            [passwordcancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        }
    }
    return YES;
}

//keyboard hide and show on textfields
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint buttonOrigin = signinBtn.frame.origin;
    CGFloat buttonHeight = signinBtn.frame.size.height;
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [scrollView setContentOffset:CGPointZero animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self deregisterFromKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
