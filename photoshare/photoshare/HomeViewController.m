//
//  HomeViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "HomeViewController.h"
#import "CommonTopView.h"
#import "CommunityViewController.h"
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
    HomeViewController *home=[[HomeViewController alloc] init];
    navController =[[UINavigationController alloc] initWithRootViewController:home];
    //navController.view.frame=CGRectMake(0, 70, 320, 30);
   // navController.view.backgroundColor=[UIColor blackColor];
    //[self presentViewController:navController animated:YES completion:Nil];
    //self.title=@"Home";
    
    // Do any additional setup after loading the view from its nib.
    //rounded the Community Count Label
    communityCountLbl.layer.cornerRadius=12;
    communityCountLbl.layer.borderWidth=2;
    communityCountLbl.layer.borderColor=[[UIColor whiteColor] CGColor];
    CommonTopView *topView=[[CommonTopView alloc] init];
    [self.view addSubview:topView];
    [self setContent];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(IBAction)goToCommunity:(id)sender
{
   // CommunityViewController *comm=[[CommunityViewController alloc] init];
    
    
    [self.tabBarController setSelectedIndex:3];
    //[self presentViewController:comm animated:YES completion:nil];
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

@end
