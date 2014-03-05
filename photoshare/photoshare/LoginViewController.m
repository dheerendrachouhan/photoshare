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
    
    manager=[ContentManager sharedManager];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    dataFetchView=[[UIView alloc] initWithFrame:self.view.frame];
    // Do any additional setup after loading the view from its nib.
    [nameTextField setDelegate:self];
    [passwordTextField setDelegate:self];
    rememberFltr = NO;
    //add the border color in username and password textfield
   
   // loginBackgroundImage.hidden=YES;
    
    //initialize the sharing IdArray
    sharingIdArray=[[NSMutableArray alloc] init];
    collectionArrayWithSharing =[[NSMutableArray alloc] init];

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
    
    //[self directLogin];
}


-(void)deviceOrientDetect
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}

-(void)orient:(UIInterfaceOrientation)ott
{
    //set the fetchview frame
    float width= self.view.frame.size.width;
    float height= self.view.frame.size.height;
    
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        dataFetchView.frame=CGRectMake(0, 0, height,width);
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(480,480);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 568.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(568,480);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f);
            loginBackgroundImage.frame = CGRectMake(0.0f,0.0f, 1024.0f, 900.0f);
            scrollView.contentSize = CGSizeMake(1024,900);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        dataFetchView.frame=CGRectMake(0, 0, width,height);
        
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
            scrollView.contentSize = CGSizeMake(320,480);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 568.0f);
            scrollView.contentSize = CGSizeMake(320,456);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 768.0f, 1024.0f);
            loginBackgroundImage.frame = CGRectMake(0.0f,0.0f, 768.0f, 1024.0f);
            scrollView.contentSize = CGSizeMake(768,1024);
            scrollView.bounces = NO;
        }
    }
}
//if network error found
-(void)networkError
{
    [collectionArrayWithSharing removeAllObjects];
    [sharingIdArray removeAllObjects];
    countSharing=0;
    [self removeDataFetchView];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Network Error" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    
}
-(void)directLogin
{
    [dmc removeAllData];//remove data from nsuser default
    
    
    //Without Validation
    [self tapHideKeyboard];
    //[self dismissViewControllerAnimated:YES completion:nil] ;
    
    NSString *username = @"ottf-user-4";
    NSString *password = @"spaceman99";
    if(nameTextField.text.length==0||passwordTextField.text.length==0)
    {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter UserName and Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if([nameTextField.text length] > 0 || [passwordTextField.text length] > 0)
    {
        isGetLoginDetail=YES;
        webservices.delegate = self;
        
        [SVProgressHUD showWithStatus:@"Login" maskType:SVProgressHUDMaskTypeBlack];
        
        NSDictionary *postdic = @{@"username":username, @"password":password} ;
        [webservices call:postdic controller:@"authentication" method:@"login"];
    }

}
//user sign in function
- (IBAction)userSignInBtn:(id)sender {
    
    
    [dmc removeAllData];//remove data from nsuser default
    
    
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
        
        [SVProgressHUD showWithStatus:@"Login" maskType:SVProgressHUDMaskTypeBlack];
        
        NSDictionary *postdic = @{@"username":username, @"password":password} ;
        [webservices call:postdic controller:@"authentication" method:@"login"];
    }
    
}

-(void) webserviceCallback:(NSDictionary *)data
{
   
    //validate the user
    
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
     NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
   
    if(isGetLoginDetail)
    {
        [SVProgressHUD dismiss];
        if(exitCode.integerValue==1)
        {
            //get the userId
            NSDictionary *dic=[outPutData objectAtIndex:0];
            userid =[dic objectForKey:@"user_id"];
            
            //store user details in nsuser default
            [dmc setUserId:[NSString stringWithFormat:@"%@",userid]] ;
            [dmc setUserName:[NSString stringWithFormat:@"%@",[dic objectForKey:@"user_username"]]];
            [dmc setUserDetails:dic] ;
            
            NSLog(@"Successful Login");
            
            isGetLoginDetail=NO;
            //display the DataFetchingProgress
            [self displayTheDataFetchingView];
            
            [self getSharingusersId];
            //set the device token on the server
            delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *devToken=delegate.token;
            
            //set device token for testing
            //IPhone Device Token
            //_token=@"786f9657d1743c08ea7c3151e3d5309d25f8d1dd85aa02977920345054711a55";
            //IPAD Device Token
            if(devToken==NULL || devToken.length==0)
            {
                devToken=@"9f985a9492310454f9fb0afb95f27e10e93997013179c1ecdc072f3ee2d79bb5";
            }

            
            
            [delegate setDevieTokenOnServer:devToken userid:[NSString stringWithFormat:@"%@",userid]];
        }
        else
        {
            NSString *errorMessage=[data objectForKey:@"user_message"];
            if(errorMessage.length==0)
            {
                errorMessage=@"Network Error";
            }
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    else
    {
        if(exitCode.integerValue==1)
        {
            
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
            ////////////////////////get the collection sharing user id
            if(isGetSharingUserId)
            {
                    NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
                    for (int i=0; i<outPutData.count; i++)
                    {
                        @try {
                            [sharingIdArray addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_id"]];
                        }
                        @catch (NSException *exception) {
                            
                        }
                        @finally {
                            
                        }
                    }
                
                isGetSharingUserId=NO;
                [self fetchOwnCollectionInfoFromServer];
                
            }
            
            else if(isGetTheOwnCollectionListData)
            {
                [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]];
                
                isGetTheOwnCollectionListData=NO;
                
                if(sharingIdArray.count>0)
                {
                    [self fetchSharingCollectionInfoFromServer];
                }
                else
                {
                    //save collectioon detail in nsuser default
                    [dmc setCollectionDataList:collectionArrayWithSharing];
                    
                    [self getIncomeFromServer];
                }
                
            }
            else if (isGetTheSharingCollectionListData)
            {
                [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]];
                countSharing++;
                if(countSharing==sharingIdArray.count)
                {
                    
                    //save collectioon detail in nsuser default
                    [dmc setCollectionDataList:collectionArrayWithSharing];
                    
                    isGetTheSharingCollectionListData=NO;
                    
                    [self getIncomeFromServer];
                }
            }
            
            else if(isGetIcomeDetail)
            {
                [self resetAllBoolValue];
                
                NSNumber *dict = [outPutData valueForKey:@"total_expected_income"];
                
                manager.weeklyearningStr = [NSString stringWithFormat:@"%@",dict];
                
                isGetIcomeDetail=NO;
                [self getTheNoOfImagesInPublicFolderFromServer];
            }
            else if (isGetTheNoOfImagesInPublicFolder)
            {
                NSDictionary *outputData=[data objectForKey:@"output_data"];
                NSDictionary *collectionContent=[outputData objectForKey:@"collection_contents"];
                NSNumber *imgCout=[NSNumber numberWithInteger:collectionContent.count];
                [manager storeData:imgCout :@"publicImgIdArray"];
                
                
                isGetTheNoOfImagesInPublicFolder=NO;
                [self removeDataFetchView];
                
                [self loadData];
            }
        }
        else
        {
            [self networkError];
        }
    }
}


//Is First Time Login Check if Yes Than Fetch Data From Server

-(void)ifFirstTimeLogin
{
    //check is Application is First Launch
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        //[self dismissViewControllerAnimated:YES completion:nil] ;
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
}
//for fetching data from server add Loading view
-(void)displayTheDataFetchingView
{
    //set Fetching View
    dataFetchView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:dataFetchView];
    [SVProgressHUD showWithStatus:@"Data is Loading From Server" maskType:SVProgressHUDMaskTypeBlack];

}
-(void)removeDataFetchView
{
    //remove fetchView and status bar
    [dataFetchView removeFromSuperview];
    [SVProgressHUD dismiss];
}

//Fetch collection info From Server
-(void)getSharingusersId
{
    @try {
        
        isGetSharingUserId=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"sharing"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
//Fetch data From Server
-(void)fetchOwnCollectionInfoFromServer
{
    @try {
        isGetTheOwnCollectionListData=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"getlist"];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}
-(void)fetchSharingCollectionInfoFromServer
{
    @try {
        if(sharingIdArray.count>0)
        {
            countSharing=0;
            for (int i=0; i<sharingIdArray.count; i++) {
                isGetTheSharingCollectionListData=YES;
                webservices.delegate=self;
                NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":[sharingIdArray objectAtIndex:i]};
                [webservices call:dicData controller:@"collection" method:@"getlist"];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void)getStorageFromServer
{
    [self resetAllBoolValue];
    isGetStorage=YES;
    webservices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid};
    [webservices call:dicData controller:@"storage" method:@"get"];
}
-(void)getTheNoOfImagesInPublicFolderFromServer
{
    @try {
        NSNumber *publicCollectionId;
        NSMutableArray *collection=[dmc getCollectionDataList];
        for (int i=0;i<collection.count; i++)
        {
            if([[[collection objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"Public"]||[[[collection objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"public"])
            {
                publicCollectionId=[[collection objectAtIndex:i] objectForKey:@"collection_id"];
                break;
            }
        }
        
        
        isGetTheNoOfImagesInPublicFolder=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid,@"collection_id":publicCollectionId};
        [webservices call:dicData controller:@"collection" method:@"get"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
//---------------------------
//---------------------------
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
    
        nameTextField.text = @"";
        usrFlt = NO;
        [namecancelBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];

    
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
    //CGFloat buttonHeight = signinBtn.frame.size.height;
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        CGPoint scrollPoint;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                scrollPoint = CGPointMake(0.0, 300.0);
            }
            else
            {
                if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
                {
                    scrollPoint = CGPointMake(0.0, 200.0);
                }
                else
                {
                    scrollPoint = CGPointMake(0.0, 260.0);
                }
                
            }
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollPoint = CGPointMake(0.0, 300.0);
        }
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [scrollView setContentOffset:CGPointZero animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSTimer *timerGo = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(deviceOrientDetect) userInfo:nil repeats:NO];
    
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
    
    EarningViewController *ea;
    if([manager isiPad])
    {
        ea= [[EarningViewController alloc] initWithNibName:@"EarningViewController_iPad" bundle:nil] ;
    }
    else
    {
        ea = [[EarningViewController alloc] initWithNibName:@"EarningViewController" bundle:nil] ;
    }
    
    CommunityViewController *com =[[CommunityViewController alloc] init];
    
    AccountViewController *acc;
    if([manager isiPad])
    {
        acc = [[AccountViewController alloc] initWithNibName:@"AccountViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        acc = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    LaunchCameraViewController *lcam=[[LaunchCameraViewController alloc] init];
    
    HomeViewController *hm=[[HomeViewController alloc] init];
    
    delegate.navControllerhome = [[UINavigationController alloc] initWithRootViewController:hm];
   // delegate.navControllerhome.navigationBar.translucent=NO;
    
    delegate.navControllerearning = [[UINavigationController alloc] initWithRootViewController:ea];
   // delegate.navControllerearning.navigationBar.translucent=NO;
    
    delegate.navControllerphoto = [[UINavigationController alloc] initWithRootViewController:lcam];
    
    delegate.navControllercommunity = [[UINavigationController alloc] initWithRootViewController:com];
   // delegate.navControllercommunity.navigationBar.translucent=NO;
    
    delegate.navControlleraccount = [[UINavigationController alloc] initWithRootViewController:acc];
    //delegate.navControlleraccount.navigationBar.translucent=NO;
    
    
    NSDictionary *textAttr=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0,0)], UITextAttributeTextShadowOffset,[UIFont fontWithName:@"Verdana-Bold" size:10.0], UITextAttributeFont, nil];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc]  initWithTitle:@"Home" image:[UIImage imageNamed:@"homelogo.png"] tag:1];
    [tabBarItem setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"Money" image:[UIImage imageNamed:@"earnings-icon.png"] tag:2];
    [tabBarItem2 setTitleTextAttributes:textAttr forState:UIControlStateNormal];

    UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"Camera" image:[UIImage imageNamed:@"photo-icon.png"] tag:3];
    [tabBarItem3 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem4 = [[UITabBarItem alloc] initWithTitle:@"Folders" image:[UIImage imageNamed:@"folder-icon-bottom.png"] tag:4];
    [tabBarItem4 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem5 = [[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"cog-item.png"] tag:5];
    [tabBarItem5 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    delegate.tbc = [[UITabBarController alloc] init] ;
  
    //navigation controllers
    
    [delegate.navControllerhome setTabBarItem:tabBarItem];
    [delegate.navControllerearning setTabBarItem:tabBarItem2];
    [delegate.navControllerphoto setTabBarItem:tabBarItem3];
    [delegate.navControllercommunity setTabBarItem:tabBarItem4];
    [delegate.navControlleraccount setTabBarItem:tabBarItem5];
    
    [delegate.tbc setDelegate:self];
    delegate.tbc.viewControllers = [[NSArray alloc] initWithObjects:delegate.navControllerhome,delegate.navControllerearning,delegate.navControllerphoto, delegate.navControllercommunity, delegate.navControlleraccount, nil];
    
    [delegate.window setRootViewController:delegate.tbc];
    
  //  [delegate.tbc.view addSubview:topView];
   // [self.view addSubview:delegate.tbc.view];
}

#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [nameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    float width= self.view.frame.size.width;
    float height= self.view.frame.size.height;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        dataFetchView.frame=CGRectMake(0, 0, height,width);
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(480,480);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 568.0f, 320.0f);
            
            scrollView.contentSize = CGSizeMake(568,480);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f);
            loginBackgroundImage.frame = CGRectMake(0.0f,0.0f, 1024.0f, 900.0f);
            scrollView.contentSize = CGSizeMake(1024,900);
            scrollView.bounces = NO;
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        dataFetchView.frame=CGRectMake(0, 0,width, height);
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
            scrollView.contentSize = CGSizeMake(320,480);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 568.0f);
            scrollView.contentSize = CGSizeMake(320,456);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 0.0f, 768.0f, 1024.0f);
            loginBackgroundImage.frame = CGRectMake(0.0f,0.0f, 768.0f, 1024.0f);
            scrollView.contentSize = CGSizeMake(768,1024);
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
