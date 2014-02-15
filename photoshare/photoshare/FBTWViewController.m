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
@synthesize successType;
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
    
    NavigationBar *navnBar;
    UILabel *navTitle = [[UILabel alloc] init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    
    
    if([objManager isiPad])
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 768, 160)];
        navTitle.frame = CGRectMake(320, 118, 250, 50);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, 120, 100.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
        navTitle.frame = CGRectMake(130, 50, 100, 40);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
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

@end
