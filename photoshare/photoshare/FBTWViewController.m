//
//  FBTWViewController.m
//  photoshare
//
//  Created by ignis3 on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "FBTWViewController.h"
#import "NavigationBar.h"
#import "ContentManager.h"

@interface FBTWViewController ()

@end

@implementation FBTWViewController
@synthesize successType,success;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    objManager = [ContentManager sharedManager];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"FBTWViewController_iPad" owner:self options:nil];
    }
    
    // Do any additional setup after loading the view from its nib.
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
           // scocialType.frame = CGRectMake(120, 179, 80, 80);
           // success.frame = CGRectMake(124, 273, 77, 21);
        }
        else
        {
           // scocialType.frame = CGRectMake(250, 293, 248, 295);
          //  success.frame = CGRectMake(250, 588, 248, 34);
        }
    }
    else
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //scocialType.frame = CGRectMake(226, 94, 111, 116);
           // success.frame = CGRectMake(246, 218, 77, 21);
        }
        else
        {
          //  scocialType.frame = CGRectMake(383, 243, 248, 238);
           // success.frame = CGRectMake(420, 526, 248, 34);
        }
    }
    
    if([successType isEqualToString:@"fb"])
    {
        scocialType.image = [UIImage imageNamed:@"facebook.png"];
    }
    else if([successType isEqualToString:@"tw"])
    {
        scocialType.image = [UIImage imageNamed:@"twitter.png"];
    }
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];
    UILabel *navTitle = [[UILabel alloc] init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    
    
    if([objManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
        }
        navTitle.frame = CGRectMake(320, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 100.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
        }
        navTitle.frame = CGRectMake(130, NavBtnYPosForiPhone, 100, NavBtnHeightForiPhone);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }

    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self addCustomNavigationBar];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
           // scocialType.frame = CGRectMake(226, 94, 111, 116);
           // success.frame = CGRectMake(246, 218, 77, 21);
        }
        else
        {
         //   scocialType.frame = CGRectMake(383, 243, 248, 238);
         //   success.frame = CGRectMake(420, 526, 248, 34);
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
           // scocialType.frame = CGRectMake(120, 179, 80, 80);
           // success.frame = CGRectMake(124, 273, 77, 21);
        }
        else
        {
          //  scocialType.frame = CGRectMake(250, 293, 248, 295);
           // success.frame = CGRectMake(250, 588, 248, 34);
        }
    }
}

@end
