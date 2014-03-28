//
//  HomeViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "HomeViewController.h"
#import "ContentManager.h"
#import "AppDelegate.h"
#import "CommunityViewController.h"
#import "PhotoGalleryViewController.h"
#import "EarningViewController.h"
#import "LoginViewController.h"
#import "ReferFriendViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "NavigationBar.h"

#import "SVProgressHUD.h"
#import "ReferFriendViewController.h"
#import "LaunchCameraViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
{
    NSString *servicesStr;
    NavigationBar *navnBar;
    CommunityViewController *com;
    PhotoGalleryViewController *photoGallery;
    ReferFriendViewController *lcam;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
        nibNameOrNil=@"HomeViewController_iPad";
    else
        nibNameOrNil=@"HomeViewController";
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
    }
    return self;
}
#pragma mark - ViewController methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTheGlobalObject];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    //Update the Total Earning
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    [self setThePublicCollectionInfo];
    //For Launch Camera View
    [manager storeData:@"NO" :@"istabcamera"];
    [manager removeData:@"isfromphotodetailcontroller,is_add_folder,reset_camera"];
    [self setTheUSerDetails];
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    delegate.navControllercommunity.viewControllers=[[NSArray alloc] initWithObjects:com,nil];
    //Set the tabbar index of Home Page
    [self.tabBarController setSelectedIndex:0];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
-(void)setUIForIOS6
{
    //Set for ios 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        profilePicImgView.frame=CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height);
        folderIconViewContainer.frame=CGRectMake(0, folderIconViewContainer.frame.origin.y+40,self.view.frame.size.width, folderIconViewContainer.frame.size.height);
    }
}
//Initialize the AllGlobal Objects
-(void)initializeTheGlobalObject
{
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    com =[[CommunityViewController alloc] init];
    lcam=[[ReferFriendViewController alloc] init];
    dmc = [[DataMapperController alloc] init];
    userid = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
}
//Set the User Details
-(void)setTheUSerDetails
{
    UIView *vi = [self.tabBarController.view viewWithTag:11];
    UILabel *lbl = (UILabel *)[vi viewWithTag:1] ;
    NSDictionary *dic = [dmc getUserDetails] ;
    NSNumber *total = [dic objectForKey:@"total_earnings"] ;
    lbl.text = [NSString  stringWithFormat:@"£%@", total];
    welcomeName.text=[dic objectForKey:@"user_realname"];
    self.navigationController.navigationBarHidden=YES;
}

#pragma mark - text feild method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return  [textField resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - IBAction method
-(IBAction)goToReferFriend:(id)sender
{
    [self.navigationController pushViewController:lcam animated:YES];
}

//Go to the Public folder
-(IBAction)goToPublicFolder:(id)sender
{
    photoGallery=nil;
    photoGallery=[[PhotoGalleryViewController alloc] init];
    //get the collection  info from NSUser Default default
    photoGallery.isPublicFolder=YES;
    photoGallery.collectionId=publicCollectionId;
    photoGallery.folderName=@"Public";
    photoGallery.selectedFolderIndex=folderIndex;
    photoGallery.collectionOwnerId=colOwnerId;
    [self.navigationController pushViewController:photoGallery animated:YES];
}
//Go to  the Community View Controller
-(IBAction)goToCommunity:(id)sender
{
    CommunityViewController *comm=[[CommunityViewController alloc] init];
    comm.isInNavigation=YES;
    [self.tabBarController setSelectedIndex:3];
}
#pragma mark - get The value from NSUser Default Method
//Get the collection info from nsuser Default
-(void)setThePublicCollectionInfo
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    @try {
        __block NSDictionary *dict=nil;
        [collection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dict=(NSDictionary *)obj;
            NSString *colName=[dict objectForKey:@"collection_name"];
            if([colName isEqualToString:@"public"] || [colName isEqualToString:@"Public"])
            {
                *stop=YES;
            }
        }];
        //Set the global variable values
        colOwnerId=[dict objectForKey:@"collection_user_id"];
        publicCollectionId=[dict objectForKey:@"collection_id"];
        folderIndex=[collection indexOfObject:dict];
        [manager storeData:publicCollectionId :@"public_collection_id"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exec in HomeView Controller%@",exception.description);
    }
}
#pragma mark - webservice call back method
//Web service call back method
-(void)webserviceCallback:(NSDictionary *)data
{
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if([servicesStr isEqualToString:@"two"])
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutDatas =[data objectForKey:@"output_data"];
            NSString *strEarning = [NSString stringWithFormat:@"%@",[outPutDatas valueForKey:@"total_expected_income"]];
            [navnBar setTheTotalEarning:strEarning];
            servicesStr = @"";
        }
    }
}

#pragma mark - Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    //For Home page Navigaigation bar
    CGFloat navBarYPos;
    CGFloat navBarHeight;
    if(IS_OS_7_OR_LATER) navBarYPos=20;
    else navBarYPos=0;
    if([manager isiPad]) navBarHeight=110;
    else navBarHeight=60;
    
    navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, navBarYPos, [UIScreen mainScreen].bounds.size.width, navBarHeight)];
    
    [navnBar loadNav];
    [[self view] addSubview:navnBar];
}

@end

