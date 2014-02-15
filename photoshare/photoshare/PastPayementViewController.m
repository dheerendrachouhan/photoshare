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
#import "ContentManager.h"

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
    objManager = [ContentManager sharedManager];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([objManager isiPad])
    {
        [[NSBundle mainBundle] loadNibNamed:@"PastPayementViewController_iPad" owner:self options:nil];
    }
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
        
        for(NSDictionary *dict in outPutData)
        {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * myNumber = [f numberFromString:[dict valueForKey:@"amount"]];
            
            [values addObject:myNumber];
            NSString *dateString = [dict valueForKey:@"when"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *dates = [dateFormatter dateFromString:dateString];
            
            [dateFormatter setDateFormat:@"dd MMM"];
            
            NSString *nowDaye = [dateFormatter stringFromDate:dates];
            [textIndicators addObject:nowDaye];
        }
        // Do any additional setup after loading the view from its nib.*/
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
        int bMaxWidth = 0;
        //Initiating the frame of bar graph
        if([[UIScreen mainScreen] bounds].size.height == 568)
        {
            frame = CGRectMake(0, 90, 320, 458);
            point = 20;
            bHeight = 30;
            bMaxWidth = 150;
        }
        else if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            frame = CGRectMake(0, 90, 320, 360);
            point = 20;
            bHeight = 20;
            bMaxWidth = 150;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame = CGRectMake(0, 180, 768, 800);
            point = 40;
            bHeight = 60;
            bMaxWidth = 520;
        }
        
        JXBarChartView *barChartView = [[JXBarChartView alloc] initWithFrame:frame startPoint:CGPointMake(point, point) values:values maxValue:maximumArrayValue textIndicators:textIndicators textColor:[UIColor blackColor] barHeight:bHeight barMaxWidth:bMaxWidth gradient:nil];
    
        [self.view addSubview:barChartView];
         
        
        [SVProgressHUD dismissWithSuccess:@"Loaded"];
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
        navTitle.frame = CGRectMake(280, 118, 250, 50);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, 120, 100.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 75)];
        navTitle.frame = CGRectMake(110, 40, 150, 40);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    navTitle.text = @"Past Payment";
    [navnBar addSubview:navTitle];
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
