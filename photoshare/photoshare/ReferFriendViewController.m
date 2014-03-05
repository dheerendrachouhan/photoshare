//
//  ReferFriendViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "ReferFriendViewController.h"
#import "ReferralStageFourVC.h"
#import "SVProgressHUD.h"
#import "ContentManager.h"
#import "AppDelegate.h"
#import "NavigationBar.h"
#import "HomeViewController.h"
#import "CustomCells.h"

@interface ReferFriendViewController ()

@end

@implementation ReferFriendViewController
{
    NSNumber *userID;
    NSMutableArray *toolkitIDArr;
    NSMutableArray *toolkitTitleArr;
    NSMutableArray *toolkitVimeoIDArr;
    NSMutableArray *toolkitEarningArr;
    NSMutableArray *toolkitreferralsArr;
    NSString *segmentControllerIndexStr;
    NSMutableArray *toolKitNameArray;
    UICollectionViewFlowLayout *layout;
    CGRect pickerFrame;
}
@synthesize webViewReferral,toolKitReferralStr, mypicker;
@synthesize collectionView = _collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"ReferFriendViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"ReferFriendViewController";
    }
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
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ReferFriendViewController_iPad" owner:self options:nil];
    }
    
    //allocate & initializing Array
    toolkitIDArr = [[NSMutableArray alloc] init];
    toolkitTitleArr = [[NSMutableArray alloc] init];
    toolkitVimeoIDArr = [[NSMutableArray alloc] init];
    toolkitEarningArr = [[NSMutableArray alloc] init];
    toolkitreferralsArr = [[NSMutableArray alloc] init];
    toolKitNameArray = [[NSMutableArray alloc] init];
    //
    segmentControllerIndexStr = @"";
    
    userID = [objManager getData:@"user_id"];
    // Do any additional setup after loading the view from its nib.
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    WebserviceController *wb = [[WebserviceController alloc] init];
    wb.delegate = self;
    NSDictionary *dictData = @{@"user_id":userID};
    [wb call:dictData controller:@"toolkit" method:@"getall"] ;
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    
    //checking device height
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            //custumizing frame of webview for 3.5 inch
            CGRect frame = webViewReferral.frame;
            frame.origin.y = 55;
            frame.size.height = 180;
            webViewReferral.frame = frame;
            
            //cutomizing frame of uipicker
            CGRect framePick = mypicker.frame;
            framePick.origin.y = 210;
            mypicker.frame = framePick;
        }
    }
    
    toolKitReferralStr = @"";
    webViewReferral.scalesPageToFit = YES;
    webViewReferral.autoresizesSubviews = YES;
}


-(void) webserviceCallback:(NSDictionary *)data
{
    NSLog(@"login callback%@",data);
    int exitCode = [[data valueForKey:@"exit_code"] intValue];
    
    if(exitCode == 0)
    {
        [SVProgressHUD dismissWithError:@"loading Failed"];
    }
    else if([data count] == 0)
    {
        [SVProgressHUD dismissWithError:@"loading Failed"];
    }
    else
    {
        [SVProgressHUD dismissWithSuccess:@"Success"];
            NSMutableArray *outPutData=[data objectForKey:@"output_data"];
        
        toolkitIDArr = [outPutData valueForKey:@"toolkit_id"];
        toolkitTitleArr = [outPutData valueForKey:@"toolkit_title"];
        toolkitVimeoIDArr = [outPutData valueForKey:@"toolkit_vimeo_id"];
        toolkitEarningArr = [outPutData valueForKey:@"toolkit_earnings"];
        toolkitreferralsArr = [outPutData valueForKey:@"toolkit_referrals"];
        [self loadData];
        [mypicker reloadAllComponents];
    }
}

-(void)loadData
{
    webViewReferral.delegate = self;
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:0]]]]];
    toolKitReferralStr = [NSString stringWithFormat:@"http://www.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:0],[objManager getData:@"user_username"]];
    mypicker.layer.borderWidth = 1.0;
    mypicker.layer.borderColor = [UIColor blackColor].CGColor;
    
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component ==  0)
    {
        if(toolkitTitleArr.count > 0)
        {
            return toolkitTitleArr.count;
        }
        else
        {
            return 0;
        }
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
        return [toolkitTitleArr objectAtIndex:row];
    }
    else
    {
        return 0;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Video name: %@",[toolkitTitleArr objectAtIndex:row]);
    NSLog(@"%d",row);
    @try {
        [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:row]]]]];
        toolKitReferralStr = [NSString stringWithFormat:@"http://www.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:row],[objManager getData:@"user_username"]];
        
       /* WebserviceController *wb = [[WebserviceController alloc] init];
        wb.delegate = self;
        NSDictionary *dictData = @{@"toolkit_id":[toolkitIDArr objectAtIndex:row]};
        [wb call:dictData controller:@"toolkit" method:@"get"] ;
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];*/
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    

}

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label;
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 568, 50)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1024, 80)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:25];
    }
    // your frame, so picker gets "colored"
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@",[toolkitTitleArr objectAtIndex:row]];
    
    return label;
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        return 50.0;
    }
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        
        return 80.0;
    }
    else
    {
        return 0;
    }
}



//push to referral stage 4 view controller
-(void)chooseView
{
    ReferralStageFourVC *rf4 = [[ReferralStageFourVC alloc] init];
    
    rf4.toolkitLink = toolKitReferralStr;
    [self.navigationController pushViewController:rf4 animated:YES];
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
    [buttonLeft addTarget:self action:@selector(chooseView) forControlEvents:UIControlEventTouchDown];
    [buttonLeft setTitle:@"Next >" forState:UIControlStateNormal];
    
    if([objManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(280, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
            buttonLeft.frame = CGRectMake(670, NavBtnYPosForiPad, 100, NavBtnHeightForiPad);
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            navTitle.frame = CGRectMake(410, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
            buttonLeft.frame = CGRectMake(910, NavBtnYPosForiPad, 100, NavBtnHeightForiPad);
        }
        
        
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 100.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
        
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(110, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
            buttonLeft.frame = CGRectMake(260, NavBtnYPosForiPhone, 60, NavBtnHeightForiPhone);
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                [navnBar loadNav:CGRectNull :true];
                navTitle.frame = CGRectMake(190, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
                buttonLeft.frame = CGRectMake(420, NavBtnYPosForiPhone, 60, NavBtnHeightForiPhone);
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 568)
            {
                [navnBar loadNav:CGRectNull :true];
                navTitle.frame = CGRectMake(230, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
                buttonLeft.frame = CGRectMake(510, NavBtnYPosForiPhone, 60, NavBtnHeightForiPhone);
            }
        }
        
        
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    navTitle.text = @"Refer Friends";
    [navnBar addSubview:button];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:buttonLeft];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    delgate.isGoToReferFriendController=NO;
    
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
            scrollView.frame = CGRectMake(0, 72, 480, 300);
            scrollView.contentSize = CGSizeMake(480, 380);
            scrollView.bounces = NO;
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 440);
            scrollView.bounces = NO;
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
            
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 1024, 700);
            scrollView.contentSize = CGSizeMake(1024, 770);
            scrollView.bounces = NO;
            
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 300);
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 423);
            scrollView.contentSize = CGSizeMake(320, 300);
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
            
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 768, 780);
            scrollView.contentSize = CGSizeMake(768, 600);
            scrollView.bounces = NO;
            
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
            scrollView.frame = CGRectMake(0, 72, 480, 300);
            scrollView.contentSize = CGSizeMake(480, 380);
            scrollView.bounces = NO;
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 440);
            scrollView.bounces = NO;
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 1024, 700);
            scrollView.contentSize = CGSizeMake(1024, 770);
            scrollView.bounces = NO;
            
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 300);
            mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 423);
            scrollView.contentSize = CGSizeMake(320, 300);
           mypicker.transform = CGAffineTransformMakeScale(1.0, 0.7);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 768, 780);
            scrollView.contentSize = CGSizeMake(768, 600);
            scrollView.bounces = NO;
            
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
