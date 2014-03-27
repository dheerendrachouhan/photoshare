//
//  FinanceCalculatorViewController.m
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "FinanceCalculatorViewController.h"
#import "ContentManager.h"

@interface FinanceCalculatorViewController ()

@end

@implementation FinanceCalculatorViewController
{
    NSMutableArray *rowFirstArr;
    NSMutableArray *rowSecondArr;
    NSMutableArray *rowThirdArr;
    NSString *setCurrenyStr;
    int first;
    int second;
    int third;
}
@synthesize myPickerView;
@synthesize cutomView;
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
   
    
    cutomView.layer.borderWidth = 2;
    cutomView.layer.borderColor = [UIColor blackColor].CGColor;
    rowFirstArr = [[NSMutableArray alloc] init];
    rowSecondArr = [[NSMutableArray alloc] init];
    rowThirdArr = [[NSMutableArray alloc] init];
    first=second=third = 0;
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
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"financeCalculator3VC_iPad" owner:self options:nil];
        myPickerView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);

    }
    
    [segmentControl setEnabled:NO forSegmentAtIndex:0];
    [segmentControl setEnabled:NO forSegmentAtIndex:2];
    
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
        setCurrenyStr = @"£";
        [self calculateUserGem];
    }
    [self calculateUserGem];
    
    for(int i=0;i<1000;i++)
    {
        [rowFirstArr addObject:[NSString stringWithFormat:@"%d",i]];
        [rowSecondArr addObject:[NSString stringWithFormat:@"%d",i]];
        [rowThirdArr addObject:[NSString stringWithFormat:@"%d",i]];
    }
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    myPickerView.layer.borderColor = [UIColor blackColor].CGColor;
    
    //Add Custom Navigation bar
    [self addCustomNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
    [self deviceOrientationDetect];
    
}

//Segment Controll
-(IBAction)segmentedControlIndexChanged {
    if(segmentControl.selectedSegmentIndex==0)
    {
        setCurrenyStr = @"$";
        [self calculateUserGem];
    }
    if(segmentControl.selectedSegmentIndex==1)
    {
        setCurrenyStr = @"£";
        [self calculateUserGem];
    }
    if(segmentControl.selectedSegmentIndex==2)
    {
        setCurrenyStr = @"€";
        [self calculateUserGem];
    }
}

//Function to calculate the gem
-(void)calculateUserGem
{
    
    int totalGemCalculated = (first*1) + (first*second) +(first*second*third);
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            if(totalGemCalculated >=999000)
            {
                amountCalculated.font = [UIFont systemFontOfSize:29.0f];
            }
            else if(totalGemCalculated <999000)
            {
                amountCalculated.font = [UIFont systemFontOfSize:33.0f];
            }
        }
        else if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            
        }
    }
    
    NSString *converted = [NSString stringWithFormat:@"%d",totalGemCalculated];
    NSLog(@"count String %d",converted.length);
    NSString *countedStr = @"";
    int a = totalGemCalculated;
    int b = 0;
    int count = 0;
    for(int u=0;u<converted.length;u++)
    {
        b = a %10;
        a = a/10;
        
        if(count == 3)
        {
            countedStr = [NSString stringWithFormat:@"%d,%@",b,countedStr];
            count=0;
        }
        else
        {
            countedStr = [NSString stringWithFormat:@"%d%@",b,countedStr];
        }
        count++;
    }
    
    amountCalculated.text =[setCurrenyStr stringByAppendingString:countedStr];
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
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        return 30.0;
    }
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        return 60.0;
    }
    else
    {
        return 0;
    }
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
        first  = [[rowFirstArr objectAtIndex:row] integerValue];
        [self calculateUserGem];
    }
    else if (component == 1)
    {
        NSLog(@"Row 2 Chosen item: %@", [rowSecondArr objectAtIndex:row]);
        second = [[rowSecondArr objectAtIndex:row] integerValue];
        [self calculateUserGem];
    }
    else if (component == 2)
    {
        NSLog(@"Row 3 Chosen item: %@", [rowThirdArr objectAtIndex:row]);
        third = [[rowThirdArr objectAtIndex:row] integerValue];
        [self calculateUserGem];
    }
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {

        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 58)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    }
    // your frame, so picker gets "colored"
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    
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

#pragma  mark - Add Custom Navigation bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *navTitle = [navnBar navBarTitleLabel:@"Money Calculator"];
    
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark - Device Orientation
-(void)deviceOrientationDetect
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
}
-(void)orient:(UIInterfaceOrientation)ott
{
    
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 480, 300);
            scrollView.contentSize = CGSizeMake(480, 400);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 568, 400);
            scrollView.contentSize = CGSizeMake(568, 560);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 173, 1024, 710);
            scrollView.contentSize = CGSizeMake(1024, 800);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 345);
            scrollView.contentSize = CGSizeMake(320, 260);
            scrollView.bounces = NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 433);
            scrollView.contentSize = CGSizeMake(320, 360);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 173, 768, 710);
            scrollView.contentSize = CGSizeMake(768, 600);
            scrollView.bounces = NO;
        }
    }
    [self setUIForIOS6];
}
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+90);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
