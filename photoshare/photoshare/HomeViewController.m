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
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"HomeViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"HomeViewController";
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - ViewController methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTheGlobalObject];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
     photoCountLbl.hidden=YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
   
    //for launch camera
    [manager storeData:@"NO" :@"istabcamera"];
    [self setTheUSerDetails];
    //set the
    [self.tabBarController setSelectedIndex:0];
    
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
  
    CommunityViewController *comm=[[CommunityViewController alloc] init];
   
    delegate.navControllercommunity.viewControllers =[[NSArray alloc] initWithObjects:comm, nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Rounded the Count label of the show no of images is Public folder
-(void)setTheUIForCountLabel
{
    photoCountLbl.layer.cornerRadius=12;
    photoCountLbl.layer.borderWidth=2;
    if([manager isiPad])
    {
        photoCountLbl.layer.cornerRadius=18;
    }
    
    photoCountLbl.layer.borderColor=[[UIColor whiteColor] CGColor];
}
-(void)initializeTheGlobalObject
{
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    dmc = [[DataMapperController alloc] init];
    userid = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
}
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
    ReferFriendViewController *lcam=[[ReferFriendViewController alloc] init];
    [self.navigationController pushViewController:lcam animated:YES];
}

//Go to the Public folder
-(IBAction)goToPublicFolder:(id)sender
{
    //get the collection  info from NSUser Default default
    [self getCollectionInfoFromUserDefault];
    PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] init];
    photoGallery.isPublicFolder=YES;
    photoGallery.collectionId=publicCollectionId;
    photoGallery.folderName=@"Public";
    photoGallery.selectedFolderIndex=folderIndex;
    photoGallery.collectionOwnerId=colOwnerId;
    [self.navigationController pushViewController:photoGallery animated:YES];
}
-(IBAction)goToCommunity:(id)sender
{
    CommunityViewController *comm=[[CommunityViewController alloc] init];
    comm.isInNavigation=YES;
    [self.tabBarController setSelectedIndex:3];
    
    self.navigationController.navigationBarHidden = NO;
}
#pragma mark - get The value from NSUser Default Method
//Get the collection info from nsuser Default
-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    @try {
        for (int i=0;i<collection.count; i++)
        {
                NSNumber *coluserId=[[collection objectAtIndex:i] objectForKey:@"collection_user_id"];
                
                if([[[collection objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"Public"]||[[[collection objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"public"])
                {
                    publicCollectionId=[[collection objectAtIndex:i] objectForKey:@"collection_id"];
                    colOwnerId=coluserId;
                    folderIndex=i;
                    break;
                }
            }
    }
    @catch (NSException *exception) {
        NSLog(@"Exec is %@",exception.description);
    }
    @finally {
        
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
    
    navnBar = [[NavigationBar alloc] init];
    //For Home page Navigaigation bar
    if([manager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
            [navnBar loadNav:CGRectMake(0, 20, self.view.frame.size.width, 110) :false];
        
        }else{
            [navnBar loadNav:CGRectMake(0, 20, self.view.frame.size.width, 110) :true];
        }
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectMake(0, 20, 320, 60) :false];
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                [navnBar loadNav:CGRectMake(0, 20, 480, 60) :true];
            }
            else if([[UIScreen mainScreen] bounds].size.height == 568)
            {
                [navnBar loadNav:CGRectMake(0, 20, 568, 60) :true];
            }
        }
    }
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}
#pragma mark - Device Orientatiom method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self addCustomNavigationBar];
}


@end

