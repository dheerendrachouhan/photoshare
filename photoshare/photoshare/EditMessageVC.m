//
//  EditMessageVC.m
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditMessageVC.h"
#import "ReferralStageFourVC.h"
#import "NavigationBar.h"
#import "ContentManager.h"

@interface EditMessageVC ()

@end

@implementation EditMessageVC
@synthesize edittedMessage;

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
    // Do any additional setup after loading the view from its nib.
    //Navigation Back Title
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"EditMessageVCiPad" owner:self options:nil];
    }
    
    [textMessage setDelegate:self];
    textMessage.text = edittedMessage;
    custumImageBackground.layer.cornerRadius = 5;
}
- (IBAction)doneBtnPressed:(id)sender {
    ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
    rf.stringStr = [NSString stringWithFormat:@"%@", textMessage.text];
    [self.navigationController popToViewController:rf animated:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    UILabel *navTitle = [[UILabel alloc] init];
    
    

    //Button for Next
    UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonLeft addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonLeft setTitle:@"Choose >" forState:UIControlStateNormal];
    
    if([objManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(280, 120, 250, 50);
            buttonLeft.frame = CGRectMake(620, 110, 140, 30.0);
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            navTitle.frame = CGRectMake(400, 110, 250, 50);
            buttonLeft.frame = CGRectMake(870, 120, 140, 30.0);
        }
        
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, 120, 100.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
        
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(110, 50, 120, 40);
            buttonLeft.frame = CGRectMake(240, 50, 80, 30.0);
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                [navnBar loadNav:CGRectNull :true];
                navTitle.frame = CGRectMake(190, 50, 120, 40);
                buttonLeft.frame = CGRectMake(400, 50, 80, 30.0);
            }
            else if([[UIScreen mainScreen] bounds].size.height ==568)
            {
                [navnBar loadNav:CGRectNull :true];
                navTitle.frame = CGRectMake(230, 45, 120, 40);
                buttonLeft.frame = CGRectMake(488, 50, 80, 30.0);
            }
        }
        
        
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    
    navTitle.text = @"Edit Message";
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    [navnBar addSubview:buttonLeft];
    
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
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}

-(void)orient:(UIInterfaceOrientation)ott
{
    
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 480, 300);
            scrollView.contentSize = CGSizeMake(480,350);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 568, 300);
            scrollView.contentSize = CGSizeMake(568,350);
            
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
            
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 320, 300);
            scrollView.contentSize = CGSizeMake(320,260);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 320, 300);
            scrollView.contentSize = CGSizeMake(320,220);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
            
        }
    }
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
        
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 480, 300);
            scrollView.contentSize = CGSizeMake(480,350);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 568, 300);
            scrollView.contentSize = CGSizeMake(568,350);
            
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
            
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 320, 300);
            scrollView.contentSize = CGSizeMake(320,260);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.bounces = NO;
            scrollView.frame = CGRectMake(0, 80, 320, 300);
            scrollView.contentSize = CGSizeMake(320,220);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
            
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
