//
//  FinanceCalculatorViewController.m
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "FinanceCalculatorViewController.h"
#import "NavigationBar.h"

@interface FinanceCalculatorViewController ()

@end

@implementation FinanceCalculatorViewController

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
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            [[NSBundle mainBundle] loadNibNamed:@"FinanceCalculatorViewController" owner:self options:nil];
        }
        else if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            [[NSBundle mainBundle] loadNibNamed:@"financeCalculator3VC" owner:self options:nil];
        }
    }
     [self.navigationItem setTitle:@"Calculator"];
	// Do any additional setup after loading the view.
    border1.layer.borderColor = [UIColor colorWithRed:0.039 green:0.451 blue:1 alpha:1].CGColor;
    border1.layer.borderWidth = 2.0f;
    border2.layer.borderColor = [UIColor colorWithRed:0.039 green:0.451 blue:1 alpha:1].CGColor;
    border2.layer.borderWidth = 2.0f;
    border3.layer.borderColor = [UIColor colorWithRed:0.039 green:0.451 blue:1 alpha:1].CGColor;
    border3.layer.borderWidth = 2.0f;
    
    //initial set the gems value zero
    firstGem.text = @"00";
    secondGem.text = @"00";
    thirdGem.text = @"00";
    segmentControl.selectedSegmentIndex = 1;
    if(segmentControl.selectedSegmentIndex == 1)
    {
        currencySetter.text = @"£";
    }
    [self calculateUserGem];
}

//Segment Controll
-(IBAction)segmentedControlIndexChanged {
    if(segmentControl.selectedSegmentIndex==0)
    {
        currencySetter.text = @"$";
    }
    if(segmentControl.selectedSegmentIndex==1)
    {
        currencySetter.text = @"£";
    }
    if(segmentControl.selectedSegmentIndex==2)
    {
        currencySetter.text = @"€";
    }
}

//Function to calculate the gem
-(void)calculateUserGem
{
    int first = [firstGem.text intValue];
    int second = [secondGem.text intValue];
    int third = [thirdGem.text intValue];
    
    int totalGemCalculated = (first*1) + (first*second) +(first*second*third);
    
    if(totalGemCalculated >= 1000000)
    {
        {
            if ([[UIScreen mainScreen] bounds].size.height == 568)
            {
                amountCalculated.font = [UIFont systemFontOfSize:26.0f];
            }
        }
    }
    amountCalculated.text = [NSString stringWithFormat:@"%d",totalGemCalculated];
}
//FisrGem Up Button
- (IBAction)fGemUp_Btn:(id)sender {
    int first = [firstGem.text intValue];
    
    if(first >=0)
    {
        first++;
        if(first >= 1000)
        {
            firstGem.font = [UIFont systemFontOfSize:33.0f];
        }
        firstGem.text = [NSString stringWithFormat:@"%d",first];
        [self calculateUserGem];
    }
}
//firstGem Down Button
- (IBAction)fGemDown_Btn:(id)sender {
    int first = [firstGem.text intValue];
    if(first <= 0)
    {
        firstGem.text = [NSString stringWithFormat:@"%d",first];
    }
    else {
        first--;
        if(first < 1000)
        {
            firstGem.font = [UIFont systemFontOfSize:47.0f];
        }
        firstGem.text = [NSString stringWithFormat:@"%d",first];
        [self calculateUserGem];
    }
    if(first==0)
    {
        firstGem.text = @"00";
    }
}

//SecondGem Up And Down Button
- (IBAction)sGemUp_btn:(id)sender {
    int second = [secondGem.text intValue];
    
    if(second >=0)
    {
        second++;
        if(second >= 1000)
        {
            secondGem.font = [UIFont systemFontOfSize:33.0f];
        }
        secondGem.text = [NSString stringWithFormat:@"%d",second];
        [self calculateUserGem];
    }
}
- (IBAction)sGemDown_btn:(id)sender {
    int second = [secondGem.text intValue];
    if(second <= 0)
    {
        secondGem.text = [NSString stringWithFormat:@"%d",second];
    }
    else {
        second--;
        if(second < 1000)
        {
            secondGem.font = [UIFont systemFontOfSize:47.0f];
        }
        secondGem.text = [NSString stringWithFormat:@"%d",second];
        [self calculateUserGem];
    }
    if(second==0)
    {
        secondGem.text = @"00";
    }
}

//thirdGem Up And Down Button
- (IBAction)tGemUp_btn:(id)sender {
    int third = [thirdGem.text intValue];
    
    if(third >=0)
    {
        third++;
        if(third >= 1000)
        {
            thirdGem.font = [UIFont systemFontOfSize:33.0f];
        }
        thirdGem.text = [NSString stringWithFormat:@"%d",third];
        [self calculateUserGem];
    }
}
- (IBAction)tGemDown_btn:(id)sender {
    int third = [thirdGem.text intValue];
    if(third <= 0)
    {
        thirdGem.text = [NSString stringWithFormat:@"%d",third];
    }
    else {
        third--;
        if(third < 1000)
        {
            thirdGem.font = [UIFont systemFontOfSize:47.0f];
        }
        thirdGem.text = [NSString stringWithFormat:@"%d",third];
        [self calculateUserGem];
    }
    if(third==0)
    {
        thirdGem.text = @"00";
    }

}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(120, 50, 120, 40)];
    navTitle.font = [UIFont systemFontOfSize:18.0f];
    navTitle.text = @"Calculator";
    [navnBar addSubview:navTitle];
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
