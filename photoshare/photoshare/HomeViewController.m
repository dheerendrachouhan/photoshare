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
#import "CommonTopView.h"
#import "EarningViewController.h"
#import "WebserviceController.h"
#import "LoginViewController.h"
@interface HomeViewController ()

@end

@implementation HomeViewController

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
    
    
    LoginViewController *loginv = [[LoginViewController alloc] init] ;
    [self.navigationController presentViewController:loginv animated:NO completion:nil];
    
    
    //rounded the Community Count Label
    photoCountLbl.layer.cornerRadius=12;
    photoCountLbl.layer.borderWidth=2;
    photoCountLbl.layer.borderColor=[[UIColor whiteColor] CGColor];
    
    
    [self setContent];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.frame=CGRectMake(0, 20, 320, 70);
    ContentManager *manager=[ContentManager sharedManager];
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
-(void)setContent
{
    profilePicImgView.image=[UIImage imageNamed:@"wall.jpg"];
}

-(IBAction)goToTotalEarning:(id)sender
{
   
}
-(IBAction)takePhoto:(id)sender
{
    if(imagePicker==nil)
    {
        imagePicker=[[UIImagePickerController alloc] init];
        imagePicker.delegate=self;
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(IBAction)goToPublicFolder:(id)sender
{
    PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
    photoGallery.isPublicFolder=YES;
    [self.navigationController pushViewController:photoGallery animated:YES];
     
    
}
-(IBAction)goToCommunity:(id)sender
{
    
    CommunityViewController *comm=[[CommunityViewController alloc] init];
    
    [self.navigationController pushViewController:comm animated:YES];
    
}
-(IBAction)gotoPhotos:(id)sender
{
    
}


//imagePicker DelegateMethod
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)earnigView
{
    NSLog(@" earning view call --") ;
    EarningViewController *earningView=[[EarningViewController alloc] init];
    //HomeViewController *home=[[HomeViewController alloc] init];
    //[home.navigationController pushViewController:earningView animated:YES];
    PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
  //  [self.navigationController pushViewController:photoGallery animated:YES];

    [self presentViewController:photoGallery animated:NO completion:nil];
    //[self.tabBarController setSelectedIndex:1];
}

@end
