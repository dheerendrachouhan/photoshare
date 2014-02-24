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
    
    // Do any additional setup after loading the view from its nib.
    [nameTextField setDelegate:self];
    [passwordTextField setDelegate:self];
    rememberFltr = NO;
    //add the border color in username and password textfield
    //temp Hidden
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
   
         //validate the user
    
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
     NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
    if(isGetLoginDetail)
    {
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
            //call the get collection detail method
            [self getSharingusersId];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
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
    dataFetchView=[[UIView alloc] initWithFrame:self.view.frame];
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

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
   
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
    
    EarningViewController *ea;
    if([manager isiPad])
    {
        ea= [[EarningViewController alloc] initWithNibName:@"EarningViewController_iPad" bundle:nil] ;
    }
    else
    {
        ea = [[EarningViewController alloc] initWithNibName:@"EarningViewController" bundle:nil] ;
    }
    
    CommunityViewController *com ;
    if([manager isiPad])
    {
        com = [[CommunityViewController alloc] initWithNibName:@"CommunityViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        com = [[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    AccountViewController *acc;
    if([manager isiPad])
    {
        acc = [[AccountViewController alloc] initWithNibName:@"AccountViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        acc = [[AccountViewController alloc] initWithNibName:@"AccountViewController" bundle:[NSBundle mainBundle]] ;
    }
    
    LaunchCameraViewController *lcam;
    
    if([manager isiPad])
    {
        lcam=[[LaunchCameraViewController alloc] initWithNibName:@"LaunchCameraViewController_iPad" bundle:[NSBundle mainBundle]];
        
    }
    else
    {
        lcam=[[LaunchCameraViewController alloc] initWithNibName:@"LaunchCameraViewController" bundle:[NSBundle mainBundle]];
    }
    //HomeViewController *hm=[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    
    HomeViewController *hm;
    if([manager isiPad])
    {
        hm= [[HomeViewController alloc] initWithNibName:@"HomeViewController_iPad" bundle:nil] ;
    }
    else
    {
        hm = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil] ;
    }
    
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
