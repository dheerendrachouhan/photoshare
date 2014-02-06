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
{
    NSMutableArray *rowFirstArr;
    NSMutableArray *rowSecondArr;
    NSMutableArray *rowThirdArr;
}
@synthesize myPickerView;
@synthesize cutomView;
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
    
    cutomView.layer.borderWidth = 2;
    cutomView.layer.borderColor = [UIColor blackColor].CGColor;
    rowFirstArr = [[NSMutableArray alloc] init];
    rowSecondArr = [[NSMutableArray alloc] init];
    rowThirdArr = [[NSMutableArray alloc] init];
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
    
    for(int i=0;i<=100;i++)
    {
        [rowFirstArr addObject:[NSString stringWithFormat:@"%d",i]];
        [rowSecondArr addObject:[NSString stringWithFormat:@"%d",i]];
        [rowThirdArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    myPickerView.layer.borderColor = [UIColor blackColor].CGColor;
   
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
    
    amountCalculated.text = [NSString stringWithFormat:@"%d",totalGemCalculated];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return rowFirstArr.count;
    }
    else if(component == 1)
    {
        return rowSecondArr.count;
    }
    else
    {
        return rowThirdArr.count;
    }
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component==0)
    {
        return [rowFirstArr objectAtIndex:row];
    }
    else if (component == 1)
    {
        return [rowSecondArr objectAtIndex:row];
    }
    else
    {
        return [rowThirdArr objectAtIndex:row];
    }
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Let's print in the console what the user had chosen;
    if(component == 0)
    {
        NSLog(@"Row 1 Chosen item: %@", [rowFirstArr objectAtIndex:row]);
        firstGem.text  = [rowFirstArr objectAtIndex:row];
        [self calculateUserGem];
    }
    else if (component == 1)
    {
        NSLog(@"Row 2 Chosen item: %@", [rowSecondArr objectAtIndex:row]);
        secondGem.text = [rowSecondArr objectAtIndex:row];
        [self calculateUserGem];
    }
    else if (component == 2)
    {
        NSLog(@"Row 3 Chosen item: %@", [rowThirdArr objectAtIndex:row]);
        thirdGem.text = [rowThirdArr objectAtIndex:row];
        [self calculateUserGem];
    }
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)]; // your frame, so picker gets "colored"
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%d",row];
    
    return label;
}

- (IBAction)hideViewCustom:(id)sender {
    [self.cutomView setHidden:NO];
}

- (IBAction)hidetwoView:(id)sender {
    [self.cutomView setHidden:NO];
}
- (IBAction)hidethreeView:(id)sender {
    [self.cutomView setHidden:NO];
}
- (IBAction)hideFinalView:(id)sender {
    [self.cutomView setHidden:YES];
}

//Custom Navigation
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
