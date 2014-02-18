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
#import "AppDelegate.h"
#import "LoginViewController.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "NavigationBar.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

#import "LaunchCameraViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
{
    NSString *servicesStr;
    NSNumber *userID;
    NavigationBar *navnBar;
}
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
    //LoginViewController *loginv = [[LoginViewController alloc] init] ;
    //[self.navigationController presentViewController:loginv animated:NO completion:nil];
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
   
    
    //rounded the Community Count Label
    photoCountLbl.layer.cornerRadius=12;
    photoCountLbl.layer.borderWidth=2;
    photoCountLbl.layer.borderColor=[[UIColor whiteColor] CGColor];
    
    
    
    dmc = [[DataMapperController alloc] init];
    
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
    
   UIView *vi = [self.tabBarController.view viewWithTag:11];
    
   UILabel *lbl = (UILabel *)[vi viewWithTag:1] ;
    
    NSDictionary *dic = [dmc getUserDetails] ;
    NSNumber *total = [dic objectForKey:@"total_earnings"] ;
    lbl.text = [NSString  stringWithFormat:@"£%@", total];
    userid=[dic objectForKey:@"user_id"];
    welcomeName.text=[dic objectForKey:@"user_realname"];
    self.navigationController.navigationBarHidden=YES;
    
    NSArray *publicImgArray=[manager getData:@"publicImgArray"];
    if([publicImgArray count]==0)
    {
        photoCountLbl.hidden=YES;
    }
    else
    {
        photoCountLbl.hidden=NO;
        photoCountLbl.text=[NSString stringWithFormat:@"%lu",(unsigned long)[publicImgArray count]];        
    }
    
}
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


-(IBAction)takePhoto:(id)sender
{
    
    LaunchCameraViewController *lcam;
    if([manager isiPad])
    {
        lcam=[[LaunchCameraViewController alloc] initWithNibName:@"LaunchCameraViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        lcam=[[LaunchCameraViewController alloc] initWithNibName:@"LaunchCameraViewController" bundle:[NSBundle mainBundle]];

    }
    lcam.isFromHomePage=YES;
    [self.navigationController pushViewController:lcam animated:YES];

}
-(IBAction)goToPublicFolder:(id)sender
{
    PhotoGalleryViewController *photoGallery;
    if([manager isiPad])
    {
        photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
    }
    //get the collection  info from nsuser default
    [self getCollectionInfoFromUserDefault];
    
    photoGallery.isPublicFolder=YES;
    photoGallery.collectionId=publicCollectionId;
    photoGallery.folderName=@"Public";
    photoGallery.selectedFolderIndex=folderIndex;
    photoGallery.collectionOwnerId=colOwnerId;
    [self.navigationController pushViewController:photoGallery animated:YES];
    
}
-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];
   
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

-(IBAction)goToCommunity:(id)sender
{
    
    //CommunityViewController *comm=[[CommunityViewController alloc] init];
    CommunityViewController *comm;
    if([manager isiPad])
    {
        comm=[[CommunityViewController alloc] initWithNibName:@"CommunityViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        comm=[[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:[NSBundle mainBundle]];
    }
    //AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    comm.isInNavigation=YES;
    [self.navigationController pushViewController:comm animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

-(void)webserviceCallback:(NSDictionary *)data
{
    
    NSLog(@"Data %@",data);
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

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    //for home page view controller navBar
    if([manager isiPad])
    {
        navnBar.frame=CGRectMake(0, 20, self.view.frame.size.width, 110);
    }
    else
    {
        navnBar.frame=CGRectMake(0, 20, 320, 60);
    }
    
    [[self view] addSubview:navnBar];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

