//
//  ZoomPhotoViewController.m
//  photoshare
//
//  Created by ignis2 on 28/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "ZoomPhotoViewController.h"

@interface ZoomPhotoViewController ()

@end

@implementation ZoomPhotoViewController
@synthesize imgView,image,scrollViewForImage;
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
    // Do any additional setup after loading the view from its nib.
    imgView.image=image;
    
    UITapGestureRecognizer *doubleTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToBack:)];
    doubleTapGesture.numberOfTapsRequired=2;
    [self.view addGestureRecognizer:doubleTapGesture];
    
    imgView.frame = scrollViewForImage.bounds;
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    scrollViewForImage.contentSize = CGSizeMake(imgView.frame.size.width, imgView.frame.size.height);
    scrollViewForImage.maximumZoomScale = 4.0;
    scrollViewForImage.minimumZoomScale = 1.0;
    scrollViewForImage.delegate = self;
}
-(void)goToBack: (UITapGestureRecognizer *)gesture
{
    [self.navigationController popViewControllerAnimated:NO];
}


-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imgView;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
