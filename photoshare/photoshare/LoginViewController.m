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
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "SVProgressHUD.h"

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
 
    //initialize webservices Object
    webservices=[[WebserviceController alloc] init];
    
    manager=[ContentManager sharedManager];
    dmc = [[DataMapperController alloc] init] ;
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
        isGetLoginDetail=YES;
        webservices.delegate = self;
        NSDictionary *postdic = @{@"username":username, @"password":password} ;
        [webservices call:postdic controller:@"authentication" method:@"login"];
    }
    
}

-(void) webserviceCallback:(NSDictionary *)data
{
    NSLog(@"login callback%@",data);
   
         //validate the user
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if(exitCode.integerValue==1)
    {
        NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
        
        if(isGetLoginDetail)
        {
            //get the userId
            NSDictionary *dic=[outPutData objectAtIndex:0];
            //Setting values globally
            //ContentManager *objManager=[ContentManager sharedManager];
            //objManager.loginDetailsDict = dic;
            userid =[dic objectForKey:@"user_id"];
            [dmc setUserId:[NSString stringWithFormat:@"%@",userid]] ;
            
            [dmc setUserDetails:dic] ;
            
            //userid=[dic objectForKey:@"user_id"];
            
           // NSLog(@"User id is %@",[dic objectForKey:@"user_id"]);
            
            //store the UserId in NSUser Defaults
            //[manager storeData:userid :@"user_id"];
    
            
            NSLog(@"Successful Login");
            
            
            //is FirstTimeLogin
            [self ifFirstTimeLogin];     
           

        }
        else if(isGetTheCollectionListData)
        {
            //set collection List in NSDefault
            [manager storeData:outPutData :@"collection_data_list"];
            [self getStorageFromServer];
            
        }
        else if(isGetStorage)
        {
            
            NSLog(@"Get Storage %@",data);
            NSDictionary *dic=[outPutData objectAtIndex:0];
            NSNumber *availableStorage=[dic objectForKey:@"storage_available"];
            NSNumber *usedStorage=[dic objectForKey:@"storage_used"];
            //NSNumber *totalPhoto=[dic objectForKey:@"photo_total"];
            float availableSpaceInMB=(float)([availableStorage doubleValue]/(double)(1024*1024)) ;
            float usedSpaceInMB=(float)([usedStorage doubleValue]/(double)(1024*1024));
            
            //set the diskSpacePercentage
            float progressPercent=(float)(usedSpaceInMB/availableSpaceInMB);
            //store in NSDefault
            [manager storeData:[NSNumber numberWithFloat:progressPercent] :@"disk_space"];
            
            [self resetAllBoolValue];
            //remove fetchView and status bar
            [dataFetchView removeFromSuperview];
            [SVProgressHUD dismiss];
            [self dismissViewControllerAnimated:YES completion:nil] ;
        }
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//Is First Time Login Check if Yes Than Fetch Data From Server

-(void)ifFirstTimeLogin
{
    //check is Application is First Launch
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        //[self dismissViewControllerAnimated:YES completion:nil] ;
        NSLog(@"// app already launched");
    }
    else
    {
        
        //create the public and Private Album in device
        [self.library addAssetsGroupAlbumWithName:@"Public" resultBlock:nil failureBlock:nil];
        [self.library addAssetsGroupAlbumWithName:@"Private" resultBlock:nil failureBlock:nil];
        
        
        NSLog(@"// First time launched");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    //set Fetching View
    dataFetchView=[[UIView alloc] initWithFrame:self.view.frame];
    dataFetchView.backgroundColor=[UIColor whiteColor];
    [SVProgressHUD showWithStatus:@"Data is Loading From Server" maskType:SVProgressHUDMaskTypeBlack];
    
    //UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-100,self.view.center.y-20,200,20)];
    //label.text=@"Please wait data is fetchinf from server";

    //[dataFetchView addSubview:label];
    [self.view addSubview:dataFetchView];
    [self fetchCollectionInfoFromServer];
}
//Fetch data From Server
-(void)fetchCollectionInfoFromServer
{
    [self resetAllBoolValue];
    isGetTheCollectionListData=YES;
    webservices.delegate=self;
    
    NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":userid};
    [webservices call:dicData controller:@"collection" method:@"getlist"];
}
-(void)getStorageFromServer
{
    [self resetAllBoolValue];
    isGetStorage=YES;
    webservices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid};
    [webservices call:dicData controller:@"storage" method:@"get"];
}

//Reset all BooL Value
-(void)resetAllBoolValue
{
    isGetLoginDetail=NO;
    isGetTheCollectionListData=NO;
    isGetStorage=NO;
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
