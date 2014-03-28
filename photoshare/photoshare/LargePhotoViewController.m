//
//  LargePhotoViewController.m
//  photoshare
//
//  Created by ignis2 on 13/03/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "LargePhotoViewController.h"
#import "ContentManager.h"
@interface LargePhotoViewController ()

@end

@implementation LargePhotoViewController
@synthesize photoId,colId,imageLoaded,isFromPhotoViewC;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"LargePhotoViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"LargePhotoViewController";
    }
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
}
-(void)viewWillAppear:(BOOL)animated
{    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
    
     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    if(self.isFromPhotoViewC)
    {
        imgView.image=self.imageLoaded;
    }
    else
    {
        imgView.image=nil;
        activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator startAnimating];
        activityIndicator.tag=1100;
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
        activityIndicator.center = CGPointMake(CGRectGetWidth(imgView.bounds)/2, CGRectGetHeight(imgView.bounds)/2);
        [imgView addSubview:activityIndicator];
        [self getPhoto];
    }
   
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.tabBarController.tabBar.hidden=NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getPhoto
{
    //[SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    isGetOriginalPhotoFromServer=YES;
    NSString *resize=@"320";
    if ([manager isiPad])
    {
        resize=@"768";
    }
    [self getPhotoFromServer:resize];
}
-(void)getPhotoFromServer :(NSString *)resize
{
    
    NSDictionary *dicData;
    
    @try {
            webservices.delegate=self;
            NSNumber *num = [NSNumber numberWithInt:1] ;
            
            dicData = @{@"user_id":[manager getData:@"user_id"],@"photo_id":self.photoId,@"get_image":num,@"collection_id":self.colId,@"image_resize":resize};
            [webservices call:dicData controller:@"photo" method:@"get"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
}
-(void)webserviceCallbackImage:(UIImage *)image
{
    if(isGetOriginalPhotoFromServer)
    {
        [activityIndicator removeFromSuperview];
        imgView.image=image;
        isGetOriginalPhotoFromServer=NO;
    }
}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Call BAck In Large Image view %@",data);
}
-(IBAction)backBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.tabBarController.tabBar.hidden=NO;
}

@end
