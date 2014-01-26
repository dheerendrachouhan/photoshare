//
//  FinanceCalculatorViewController.m
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "FinanceCalculatorViewController.h"

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
    
    int totalGemCalculated = (first*10) + (second*5) +(third*2);
    amountCalculated.text = [NSString stringWithFormat:@"%d",totalGemCalculated];
}
//FisrGem Up Button
- (IBAction)fGemUp_Btn:(id)sender {
    int first = [firstGem.text intValue];
    
    if(first >=0)
    {
        first++;
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
        thirdGem.text = [NSString stringWithFormat:@"%d",third];
        [self calculateUserGem];
    }
    if(third==0)
    {
        thirdGem.text = @"00";
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
