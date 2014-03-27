//
//  LoginViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    nibNameOrNil=@"LoginViewControlleriPadMini";
    else  nibNameOrNil=@"LoginViewController";
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    dataFetchView=[[UIView alloc] initWithFrame:self.view.frame];
    [nameTextField setDelegate:self];
    [passwordTextField setDelegate:self];
    rememberFltr = NO;
    usrFlt = NO;
    pwsFlt = NO;
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    dmc = [[DataMapperController alloc] init] ;
    sharingIdArray=[[NSMutableArray alloc] init];
    collectionArrayWithSharing =[[NSMutableArray alloc] init];
    
    //Set Layout of the Login Page
    signinBtn.layer.cornerRadius = 6.0;
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
    
    //Check remember Feild
    NSString *rememberStr = [dmc getRemeberMe];
    if([rememberStr isEqualToString:@"YES"])rememberFltr = NO;
    else  rememberFltr = YES;
    [self rememberBtnTapped];
    NSDictionary *dict = [dmc getRememberFields];
    nameTextField.text = [dict valueForKey:@"username"];
    passwordTextField.text = [dict valueForKey:@"password"];
    [self registerForKeyboardNotifications];
    [self checkAutoLogin];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(deviceOrientDetect) userInfo:nil repeats:NO];
}
-(void)deviceOrientDetect
{
    [self orient:self.interfaceOrientation];
}
-(void)checkAutoLogin
{
    if([[manager getData:@"login"] isEqualToString:@"YES"])
    {
        [self setDeviceTokenOnServerIfUserLogin];
    }

}
-(void)setDeviceTokenOnServerIfUserLogin
{
    userid=(NSNumber *)[dmc getUserId];
    NSLog(@"User Id If User Login %@",userid);
    //set the device token on the server
    delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *devToken=delegate.token;
    
    if(devToken==NULL)
    {
        //for testing only
        /*if([manager isiPad])
        {
            devToken=@"786f9657d1743c08ea7c3151e3d5309d25f8d1dd85aa02977920345054711a55";
        }
        else
        {
            devToken=@"9f985a9492310454f9fb0afb95f27e10e93997013179c1ecdc072f3ee2d79bb5";
        } */
    }
    if(devToken!=NULL)
    {
        [delegate setDevieTokenOnServer:devToken userid:[NSString stringWithFormat:@"%@",userid]];
    }
    
    //display the DataFetchingProgress
    [self displayTheDataFetchingView];
    
    [self getSharingusersId];
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
-(void)networkError:(NSString *)alertmessage
{
    [collectionArrayWithSharing removeAllObjects];
    [sharingIdArray removeAllObjects];
    countSharing=0;
    [self removeDataFetchView];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:alertmessage delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    
}
//user sign in function
- (IBAction)userSignInBtn:(id)sender {
    [dmc removeAllData];
    //Without Validation
    [self tapHideKeyboard];
    
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
            [self setDeviceTokenOnServerIfUserLogin];
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
            ////////////////////////
            //get the collection sharing user id
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
                [self removeDataFetchView];
                
                [self loadData];
                
            }           
        }
        else
        {
            NSString *errorMessage=[data objectForKey:@"user_message"];
            if(errorMessage.length==0)
            {
                errorMessage=@"Network Error";
            }
            [self networkError:errorMessage];
        }
    }
}

-(void)displayTheDataFetchingView
{
    //set Fetching View
    dataFetchView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:dataFetchView];
    [SVProgressHUD showWithStatus:@"Data is Loading From Server" maskType:SVProgressHUDMaskTypeBlack];

}
-(void)removeDataFetchView
{
  
    [dataFetchView removeFromSuperview];
    [SVProgressHUD dismiss];
}

#pragma mark - Fetch collection info from server
-(void)getSharingusersId
{
    @try {
        [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        webservices=[[WebserviceController alloc] init];
        isGetSharingUserId=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"sharing"];
    }
    @catch (NSException *exception) {
        
    }
}
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
}

-(void)getIncomeFromServer
{
    [self resetAllBoolValue];
    isGetIcomeDetail=YES;
    webservices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid};
    [webservices call:dicData controller:@"referral" method:@"calculateincome"];
}

-(void)resetAllBoolValue
{
    isGetLoginDetail=NO;
    isGetTheCollectionListData=NO;
    isGetStorage=NO;
}
- (IBAction)forgotPasswordBtn:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://my.123friday.com/my123/account/forgotpassword"]];
}

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
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
        CGPoint scrollPoint;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                scrollPoint = CGPointMake(0.0, 250.0);
            }
            else
            {
                if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
                {
                    scrollPoint = CGPointMake(0.0, 150.0);
                }
                else
                {
                    scrollPoint = CGPointMake(0.0, 200.0);
                }
                
            }
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollPoint = CGPointMake(0.0, 250.0);
        }
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void)keyboardWillBeHidden:(NSNotification *)notification {
    [scrollView setContentOffset:CGPointZero animated:YES];
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
    hm=[[HomeViewController alloc] init];
    ea=[[EarningViewController alloc] init];
    lcam=[[LaunchCameraViewController alloc] init];
    com =[[CommunityViewController alloc] init];
    acc=[[AccountViewController alloc] init];
    
    delegate.navControllerhome = [[UINavigationController alloc] initWithRootViewController:hm];
    delegate.navControllerearning = [[UINavigationController alloc] initWithRootViewController:ea];
    delegate.navControllerphoto = [[UINavigationController alloc] initWithRootViewController:lcam];
    delegate.navControllercommunity = [[UINavigationController alloc] initWithRootViewController:com];
    delegate.navControlleraccount = [[UINavigationController alloc] initWithRootViewController:acc];
    
    UIImage *image1;
    UIImage *image2;
    UIImage *image3;
    UIImage *image4;
    UIImage *image5;
    
    image1=[UIImage imageNamed:@"home_tab.png"];
    image2=[UIImage imageNamed:@"earnings_tab.png"];
    image3=[UIImage imageNamed:@"photo_tab.png"];
    image4=[UIImage imageNamed:@"folder_tab.png"];
    image5=[UIImage imageNamed:@"cog_tab.png"];
    
    NSDictionary *textAttr=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], UITextAttributeTextColor,[NSValue valueWithUIOffset:UIOffsetMake(0,0)], UITextAttributeTextShadowOffset,[UIFont fontWithName:@"Verdana-Bold" size:10.0], UITextAttributeFont, nil];
    
    UITabBarItem *tabBarItem = [[UITabBarItem alloc]  initWithTitle:@"Home" image:image1 tag:1];
    [tabBarItem setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem2 = [[UITabBarItem alloc] initWithTitle:@"Money" image:image2 tag:2];
    [tabBarItem2 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem3 = [[UITabBarItem alloc] initWithTitle:@"Camera" image:image3 tag:3];
    [tabBarItem3 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem4 = [[UITabBarItem alloc] initWithTitle:@"Folders" image:image4 tag:4];
    [tabBarItem4 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    
    UITabBarItem *tabBarItem5 = [[UITabBarItem alloc] initWithTitle:@"Profile" image:image5 tag:5];
    [tabBarItem5 setTitleTextAttributes:textAttr forState:UIControlStateNormal];
    delegate.tbc = [[UITabBarController alloc] init] ;
 
    [delegate.navControllerhome setTabBarItem:tabBarItem];
    [delegate.navControllerearning setTabBarItem:tabBarItem2];
    [delegate.navControllerphoto setTabBarItem:tabBarItem3];
    [delegate.navControllercommunity setTabBarItem:tabBarItem4];
    [delegate.navControlleraccount setTabBarItem:tabBarItem5];
    
    [delegate.tbc setDelegate:self];
    delegate.tbc.viewControllers = [[NSArray alloc] initWithObjects:delegate.navControllerhome,delegate.navControllerearning,delegate.navControllerphoto, delegate.navControllercommunity, delegate.navControlleraccount, nil];
    [delegate.window setRootViewController:delegate.tbc];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    UITabBarItem *item = [tabBarController.tabBar selectedItem];
    NSLog(@"Selected item title : %d",item.tag);
    if(item.tag!=4)
    {
        delegate.navControllercommunity.viewControllers=[NSArray arrayWithObjects:com, nil];
        com.updateCollectionDetails=YES;
    }
    switch (item.tag) {
        case 1:
            delegate.navControllerhome.viewControllers=[[NSArray alloc] initWithObjects:hm,nil];
            break;
        case 2:
            delegate.navControllerearning.viewControllers=[[NSArray alloc] initWithObjects:ea,nil];
            break;
        case 3:
            lcam=nil;
            lcam=[[LaunchCameraViewController alloc] init];
            delegate.navControllerphoto.viewControllers=[[NSArray alloc] initWithObjects:lcam,nil];
            [manager storeData:@"YES" :@"reset_camera"];
            [manager removeData:@"is_add_folder,isfromphotodetailcontroller,istabcamera"];
            break;
        case 4:
            break;
        case 5:
            delegate.navControlleraccount.viewControllers=[[NSArray alloc] initWithObjects:acc,nil];
            break;
        default:
            break;
    }
}
#pragma mark - Device Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
}

@end
