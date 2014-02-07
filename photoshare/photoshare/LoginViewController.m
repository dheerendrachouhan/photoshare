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
#import "AppDelegate.h"
#import "LaunchCameraViewController.h"
#import "ContentManager.h"
@interface LoginViewController ()

@end

@implementation LoginViewController
{
    AppDelegate *delegate;
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
    [nameTextField setDelegate:self];
    [passwordTextField setDelegate:self];
    rememberFltr = NO;
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
    
    loginBackgroundImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
    [loginBackgroundImage addGestureRecognizer:singleFingerTap];
    //initialize webservices Object
    webservices=[[WebserviceController alloc] init];
    
    manager=[ContentManager sharedManager];
    dmc = [[DataMapperController alloc] init] ;
    
    NSString *rememberStr = [dmc getRemeberMe];
    if([rememberStr isEqualToString:@"YES"])
    {
        rememberFltr = NO;
        [self rememberBtnTapped];
        NSDictionary *dict = [dmc getRememberFields];
        nameTextField.text = [dict valueForKey:@"username"];
        passwordTextField.text = [dict valueForKey:@"password"];
    }
    else
    {
        rememberFltr = YES;
        [self rememberBtnTapped];
        NSDictionary *dict = [dmc getRememberFields];
        nameTextField.text = [dict valueForKey:@"username"];
        passwordTextField.text = [dict valueForKey:@"password"];
    }
}

//user sign in function
- (IBAction)userSignInBtn:(id)sender {
    
    //Without Validation
    [self tapHideKeyboard];
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
        if(rememberFltr)
        {
            [dmc setRememberMe:@"YES"];
            NSDictionary *loginFields = @{@"username":nameTextField.text,@"password":passwordTextField.text};
            [dmc setRememberFields:loginFields];
        }
        else
        {
            [dmc setRememberMe:@"NO"];
            NSDictionary *loginFields = @{@"username":@"",@"password":@""};
            [dmc setRememberFields:loginFields];
        }
        
        if(isGetLoginDetail)
        {
            //get the userId
            NSDictionary *dic=[outPutData objectAtIndex:0];
            //Setting values globally
            //ContentManager *objManager=[ContentManager sharedManager];
            //objManager.loginDetailsDict = dic;
            userid =[dic objectForKey:@"user_id"];
            [dmc setUserId:[NSString stringWithFormat:@"%@",userid]] ;
            [dmc setUserName:[NSString stringWithFormat:@"%@",[dic objectForKey:@"user_username"]]];
            
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
            float availableSpaceInMB=0.0f;
            float usedSpaceInMB=0.0f;
            availableSpaceInMB=(float)([availableStorage doubleValue]/(double)(1024*1024)) ;
            usedSpaceInMB=(float)([usedStorage doubleValue]/(double)(1024*1024));
            
            //set the diskSpacePercentage
            float progressPercent=0.0f;
            progressPercent=(float)(usedSpaceInMB/availableSpaceInMB);
            //store in NSDefault
            [manager storeData:[NSNumber numberWithFloat:progressPercent] :@"disk_space"];
            
            [self getIncomeFromServer];
        }
        else if(isGetIcomeDetail)
        {
            [self resetAllBoolValue];
            
            NSLog(@"Get Storage %@",data);
            NSNumber *dict = [outPutData valueForKey:@"total_expected_income"];
            
            objManager.weeklyearningStr = [NSString stringWithFormat:@"%@",dict];
            NSLog(@"%@",objManager.weeklyearningStr);
            //remove fetchView and status bar
            [dataFetchView removeFromSuperview];
            [SVProgressHUD dismiss];
            //[self dismissViewControllerAnimated:YES completion:nil];
            [self loadData];
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
-(void)getIncomeFromServer
{
    [self resetAllBoolValue];
    isGetIcomeDetail=YES;
    webservices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid};
    [webservices call:dicData controller:@"referral" method:@"calculateincome"];
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.123friday.com/my123/account/forgotpassword"]];
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

//RememberMe Function
- (IBAction)rememberBtnTapped{
    if(!rememberFltr)
    {
        [rememberMeBtn setImage:[UIImage imageNamed:@"iconr3.png"] forState:UIControlStateNormal];
        rememberFltr = YES;
    }
    else
    {
        [rememberMeBtn setImage:[UIImage imageNamed:@"iconr3_uncheck.png"] forState:UIControlStateNormal];
        rememberFltr = NO;
    }
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

-(void)tapHideKeyboard
{
    [nameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)loadData
{
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    EarningViewController *ea = [[EarningViewController alloc] initWithNibName:@"EarningViewController" bundle:nil] ;
    
    CommunityViewController *com = [[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:nil] ;
    
    AccountViewController *acc = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:nil] ;
    
     LaunchCameraViewController *lcam=[[LaunchCameraViewController alloc] init];
    
    HomeViewController *hm = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil] ;
    
    CommonTopView *topView=[[CommonTopView alloc] init];
    
    ReferFriendViewController *referFriend = [[ReferFriendViewController alloc] init];
    
    delegate.navControllerhome = [[UINavigationController alloc] initWithRootViewController:hm];
   // delegate.navControllerhome.navigationBar.translucent=NO;
    
    
    delegate.navControllerearning = [[UINavigationController alloc] initWithRootViewController:ea];
   // delegate.navControllerearning.navigationBar.translucent=NO;
    
    delegate.navControllerphoto = [[UINavigationController alloc] initWithRootViewController:lcam];
    
    delegate.navControllercommunity = [[UINavigationController alloc] initWithRootViewController:com];
   // delegate.navControllercommunity.navigationBar.translucent=NO;
    
    delegate.navControlleraccount = [[UINavigationController alloc] initWithRootViewController:acc];
    //delegate.navControlleraccount.navigationBar.translucent=NO;
    
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc]  initWithTitle:@"Home" image:[UIImage imageNamed:@"homelogo.png"] tag:1];
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"Finance" image:[UIImage imageNamed:@"earnings-icon.png"] tag:2];
    UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"photo-icon.png"] tag:3];
    UITabBarItem *tabBarItem4 = [[UITabBarItem alloc] initWithTitle:@"Folder" image:[UIImage imageNamed:@"folder-icon-bottom.png"] tag:4];
    UITabBarItem *tabBarItem5 = [[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"cog-item.png"] tag:5];
    
    delegate.tbc = [[UITabBarController alloc] init] ;
    
    //navigation controllers
    
    [delegate.navControllerhome setTabBarItem:tabBarItem];
    [delegate.navControllerearning setTabBarItem:tabBarItem2];
    [delegate.navControllerphoto setTabBarItem:tabBarItem3];
    [delegate.navControllercommunity setTabBarItem:tabBarItem4];
    [delegate.navControlleraccount setTabBarItem:tabBarItem5];
    
    [delegate.tbc setDelegate:self];
    delegate.tbc.viewControllers = [[NSArray alloc] initWithObjects:delegate.navControllerhome,delegate.navControllerearning,delegate.navControllerphoto, delegate.navControllercommunity, delegate.navControlleraccount, nil];
    
    
  //  [delegate.tbc.view addSubview:topView];
    [self.view addSubview:delegate.tbc.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
