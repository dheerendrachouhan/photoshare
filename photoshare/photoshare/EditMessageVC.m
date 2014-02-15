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
    
    NavigationBar *navnBar;
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
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 768, 150)];
        navTitle.frame = CGRectMake(280, 100, 250, 50);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, 120, 100.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
        buttonLeft.frame = CGRectMake(620, 120, 140, 30.0);
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
        navTitle.frame = CGRectMake(110, 50, 120, 40);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        buttonLeft.frame = CGRectMake(240, 50, 80, 30.0);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
