//
//  PastPayementViewController.m
//  photoshare
//
//  Created by ignis3 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PastPayementViewController.h"
#import "JXBarChartView.h"
#import "CommonTopView.h"

@interface PastPayementViewController ()

@end

@implementation PastPayementViewController

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
    
    
    [self.navigationItem setTitle:@"Past Payment"];
    
    // Do any additional setup after loading the view from its nib.
    NSMutableArray *textIndicators = [[NSMutableArray alloc] initWithObjects:@"Date 1", @"Date 2", @"Date 3", @"Date 4", @"Date 5",@"Date 6",@"Date 7",@"Date 8", nil];
    NSMutableArray *values = [[NSMutableArray alloc] initWithObjects:@20, @5, @10, @150, @7, @4, @1, @12,  nil];
    //find highest no from array
    NSNumber *highestNumber;
    NSInteger numberIndex;
    for (NSNumber *theNumber in values)
    {
        if (theNumber > highestNumber) {
            highestNumber = theNumber;
            numberIndex = [values indexOfObject:theNumber];
        }
    }
    int maximumArrayValue = highestNumber.intValue;
    
    CGRect frame;
    int point = 0;
    int bHeight = 0;
    //Initiating the frame of bar graph
    if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        frame = CGRectMake(0, 20, 320, 458);
        point = 20;
        bHeight = 30;
    }
    else if([[UIScreen mainScreen] bounds].size.height == 480)
    {
        frame = CGRectMake(0, 25, 320, 370);
        point = 20;
        bHeight = 20;
    }
    
    JXBarChartView *barChartView = [[JXBarChartView alloc] initWithFrame:frame startPoint:CGPointMake(point, point) values:values maxValue:maximumArrayValue textIndicators:textIndicators textColor:[UIColor blackColor] barHeight:bHeight barMaxWidth:150 gradient:nil];
    
    [self.view addSubview:barChartView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
