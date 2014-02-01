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
}
@synthesize toolboxController,webViewReferral;

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
    //Segment Porstion Disable
    [toolboxController setEnabled:NO forSegmentAtIndex:1];
    [toolboxController setEnabled:NO forSegmentAtIndex:2];
    
    //allocate & initializing Array
    toolkitIDArr = [[NSMutableArray alloc] init];
    toolkitTitleArr = [[NSMutableArray alloc] init];
    toolkitVimeoIDArr = [[NSMutableArray alloc] init];
    toolkitEarningArr = [[NSMutableArray alloc] init];
    toolkitreferralsArr = [[NSMutableArray alloc] init];
    
    //
    segmentControllerIndexStr = @"";
    
    userID = [objManager getData:@"user_id"];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"Refer Friends"];
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    //Navigation Item to choose
    UIBarButtonItem *chooseButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(chooseView)];
    self.navigationItem.rightBarButtonItem = chooseButton;
    
    WebserviceController *wb = [[WebserviceController alloc] init];
    wb.delegate = self;
    //NSString *postStr = [NSString stringWithFormat:@"toolkit_id=1"] ;
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
            frame.origin.y = 142;
            frame.size.height = 220;
            webViewReferral.frame = frame;
        }
    }
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
    }
}
- (IBAction)toolbox_Controller:(id)sender {
    [SVProgressHUD showWithStatus:@"Fectching Video" maskType:SVProgressHUDMaskTypeBlack];
    if(toolboxController.selectedSegmentIndex == 0)
    {
        segmentControllerIndexStr = @"0";
       [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:0]]]]];
        [SVProgressHUD dismissWithSuccess:@"Video Loaded"];
    }
    else if (toolboxController.selectedSegmentIndex == 1)
    {
        segmentControllerIndexStr = @"1";
        [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:1]]]]];
        [SVProgressHUD dismissWithSuccess:@"video Loaded"];
    }
    else if(toolboxController.selectedSegmentIndex == 2)
    {
        segmentControllerIndexStr = @"2";
        [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:2]]]]];
        [SVProgressHUD dismissWithSuccess:@"Video Loaded"];
    }
}

-(void)loadData
{
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:0]]]]];
}

//WEbView Required Delegates
-(void)chooseView
{
    ReferralStageFourVC *rf4 = [[ReferralStageFourVC alloc] init];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navControllerearning pushViewController:rf4 animated:YES];
    delegate.navControllerearning.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
