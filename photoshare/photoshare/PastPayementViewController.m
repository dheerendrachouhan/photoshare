//
//  PastPayementViewController.m
//  photoshare
//
//  Created by ignis3 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PastPayementViewController.h"
#import "JXBarChartView.h"
#import "SVProgressHUD.h"
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
    //Add Navigation bar
    [self addCustomNavigationBar];
    textIndicators = [[NSMutableArray alloc] init];
    values = [[NSMutableArray alloc] init];
    
    WebserviceController *wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    NSDictionary *dictData = @{@"user_id":userID};
    [wc call:dictData controller:@"user" method:@"getearningsdetails"] ;
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    if([[UIScreen mainScreen] bounds].size.height == 568)
    {
        scrollView.frame = CGRectMake(0, 105, 320, 458);
    }
    else if([[UIScreen mainScreen] bounds].size.height == 480)
    {
        scrollView.frame = CGRectMake(0, 103, 320, 360);
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
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
            [f setNumberStyle:NSNumberFormatterNoStyle];
            NSString *str = [dict valueForKey:@"amount"];
            
            NSNumber * myNumber = [NSNumber numberWithInteger:[str integerValue]];
            
            
            [values addObject:myNumber];
            NSString *dateString = [dict valueForKey:@"when"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *dates = [dateFormatter dateFromString:dateString];
            
            [dateFormatter setDateFormat:@"dd MMM"];
            
            NSString *nowDaye = [dateFormatter stringFromDate:dates];
            [textIndicators addObject:nowDaye];
        }
      
        int highestNumber = 0;
        NSInteger numberIndex;
        for (NSNumber *theNumber in values)
        {
            int theno = [theNumber intValue];
            if (theno > highestNumber) {
                highestNumber = theno;
                numberIndex = [values indexOfObject:theNumber];
            }
        }
        int maximumArrayValue = highestNumber;
    
        CGRect frame;
        int point = 0;
        int bHeight = 0;
        int bMaxWidth = 0;
        //Initiating the frame of bar graph
        if([[UIScreen mainScreen] bounds].size.height == 568)
        {
            frame = CGRectMake(0, -20, 320, 458);
            point = 20;
            bHeight = 26;
            bMaxWidth = 150;
        }
        else if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            frame = CGRectMake(0, -20, 320, 360);
            point = 20;
            bHeight = 17;
            bMaxWidth = 150;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame = CGRectMake(0, -10, 768, 800);
            point = 40;
            bHeight = 50;
            bMaxWidth = 520;
        }
        
        
        JXBarChartView *barChartView = [[JXBarChartView alloc] initWithFrame:frame startPoint:CGPointMake(point, point) values:values maxValue:maximumArrayValue textIndicators:textIndicators textColor:[UIColor blackColor] barHeight:bHeight barMaxWidth:bMaxWidth gradient:nil];
        
        
        [scrollView addSubview:barChartView];
        [SVProgressHUD dismissWithSuccess:@"Loaded"];
    }
   [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(deviceOrientDetect) userInfo:nil repeats:NO];
    
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar= [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    UILabel *navTitle = [navnBar navBarTitleLabel:@"Past Payment"];
    
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Device Orientation
-(void)deviceOrientDetect
{
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
            scrollView.frame = CGRectMake(0.0f, 105.0f, 480.0f, 300.0f);
            scrollView.contentSize = CGSizeMake(480,400);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 568.0f, 320.0f);
            scrollView.contentSize = CGSizeMake(568,480);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 180.0f, 1024.0f, 768.0f);
            scrollView.contentSize = CGSizeMake(1024,900);
            scrollView.bounces = NO;
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 105, 320, 360);
            scrollView.contentSize = CGSizeMake(320,290);
            scrollView.bounces = NO;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0.0f, 101.0f, 320.0f, 415.0f);
            scrollView.contentSize = CGSizeMake(320,340);
            scrollView.bounces = NO;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0.0f, 185.0f, 768.0f, 800.0f);
            scrollView.contentSize = CGSizeMake(768,700);
            scrollView.bounces = NO;
        }
    }
    
    if(![objManager isiPad])
    {
        [self setUIForIOS6];
    }
}
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+50);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
