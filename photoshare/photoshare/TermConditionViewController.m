//
//  TermConditionViewController.m
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "TermConditionViewController.h"
#import "NavigationBar.h"

@interface TermConditionViewController ()

@end

@implementation TermConditionViewController

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
    
  [webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"term" ofType:@"html"]isDirectory:NO]]];
    
    //  [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
    if([[UIScreen mainScreen] bounds].size.height == 480)
    {
        CGRect frame = webview.frame;
        frame.origin.y = 126;
        frame.size.height = 290;
        webview.frame = frame;
    }
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 70)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 40, 70.0, 40.0);
    button.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
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
