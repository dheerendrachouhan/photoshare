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

@interface ReferFriendViewController ()

@end

@implementation ReferFriendViewController
{
    NSNumber *userID;
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
    NSString *postStr = [NSString stringWithFormat:@"toolkit_id=1"] ;
    [wb call:postStr controller:@"toolkit" method:@"get"] ;
    
    //webView By Refferral
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL  URLWithString:@"http://www.youtube.com/watch?v=XaoROWDPPZc&list=UUFfuK45zBZxhq0m1bxYP-Zw&feature=share&index=1"]]];

}

-(void) webserviceCallback:(NSDictionary *)data
{
    NSLog(@"login callback%@",data);
    int exitCode = [[data valueForKey:@"exit_code"] intValue];
    
    if(exitCode == 0)
    {
    
    }
    else if([data count] == 0)
    {
    
    }
    else
    {
        NSMutableArray *outPutData=[data objectForKey:@"output_data"];
    }
}
- (IBAction)toolbox_Controller:(id)sender {
    if(toolboxController.selectedSegmentIndex == 0)
    {
        [toolboxController setEnabled:YES forSegmentAtIndex:0];
    }
    else if (toolboxController.selectedSegmentIndex == 1)
    {
    
    }
    else if(toolboxController.selectedSegmentIndex == 2)
    {
    
    }
}

-(void)chooseView
{
    ReferralStageFourVC *rf4 = [[ReferralStageFourVC alloc] init];
    [self.navigationController pushViewController:rf4 animated:YES];
    rf4.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
