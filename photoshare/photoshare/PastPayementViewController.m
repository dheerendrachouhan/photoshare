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
#import "SVProgressHUD.h"
#import "NavigationBar.h"

@interface PastPayementViewController ()

@end

@implementation PastPayementViewController
{
    NSNumber *userID;
    NSMutableArray *textIndicators;
    NSMutableArray *values;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    dmc = [[DataMapperController alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    NSLog(@"Userid : %@",userID);
    
    textIndicators = [[NSMutableArray alloc] init];
    values = [[NSMutableArray alloc] init];
    
    WebserviceController *wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    NSDictionary *dictData = @{@"user_id":userID};
    [wc call:dictData controller:@"user" method:@"getearningsdetails"] ;
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    
}

-(void) webserviceCallback:(NSDictionary *)data
{
    [SVProgressHUD dismissWithSuccess:@"Data Loaded"];
    NSLog(@"login callback%@",data);
    
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    //get the userId
    if([data count] == 0 || exitCode == 0)
    {
        [SVProgressHUD dismissWithError:@"Failed To load Data"];
    }
    else
    {
        NSMutableArray *outPutData=[[data objectForKey:@"output_data"] valueForKey:@"payment_record"];
        
        /*
        for(int i=0;i<[outPutData count];i++)
        {
            [textIndicators addObject:[outPutData valueForKey:@""]  ];
            [values addObject:[outPutData valueForKey:@"amount"]];
        }
        // Do any additional setup after loading the view from its nib.*/
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
            frame = CGRectMake(0, 90, 320, 458);
            point = 20;
            bHeight = 30;
        }
        else if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            frame = CGRectMake(0, 90, 320, 360);
            point = 20;
            bHeight = 20;
        }
    
        JXBarChartView *barChartView = [[JXBarChartView alloc] initWithFrame:frame startPoint:CGPointMake(point, point) values:values maxValue:maximumArrayValue textIndicators:textIndicators textColor:[UIColor blackColor] barHeight:bHeight barMaxWidth:150 gradient:nil];
    
        [self.view addSubview:barChartView];
        [SVProgressHUD dismissWithSuccess:@"Loaded"];
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
    button.frame = CGRectMake(0.0, 55, 70.0, 30.0);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(105, 50, 120, 40)];
    navTitle.font = [UIFont systemFontOfSize:18.0f];
    navTitle.text = @"Past Payment";
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
