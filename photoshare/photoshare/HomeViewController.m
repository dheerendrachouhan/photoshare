//
//  HomeViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "CommunityViewController.h"
#import "PhotoGalleryViewController.h"
#import "CommonTopView.h"
#import "EarningViewController.h"
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
    
    //rounded the Community Count Label
    communityCountLbl.layer.cornerRadius=12;
    communityCountLbl.layer.borderWidth=2;
    communityCountLbl.layer.borderColor=[[UIColor whiteColor] CGColor];
    CommonTopView *topView=[[CommonTopView alloc] init];
    self.navigationController.navigationBar.translucent=NO;
    [self.navigationController.navigationBar addSubview:topView];
    self.navigationController.navigationBar.frame=CGRectMake(0, 20, 320, 70);
    
    [self setContent];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.frame=CGRectMake(0, 20, 320, 70);
    
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
    [self.navigationController pushViewController:photoGallery animated:YES];
    photoGallery.navigationController.navigationBar.frame=CGRectMake(0, 20, 320, 90);
    
}
-(IBAction)goToCommunity:(id)sender
{
    
    CommunityViewController *comm=[[CommunityViewController alloc] init];    
    [self.navigationController pushViewController:comm animated:YES];
     comm.navigationController.navigationBar.frame=CGRectMake(0, 20, 320, 90);
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
    //UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)earnigView
{
    EarningViewController *earningView=[[EarningViewController alloc] init];
    //HomeViewController *home=[[HomeViewController alloc] init];
    //[home.navigationController pushViewController:earningView animated:YES];
    [self.tabBarController setSelectedIndex:1];
}

@end
