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
}
@synthesize webViewReferral,toolKitReferralStr;
@synthesize collectionView = _collectionView;

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
            frame.origin.y = 200;
            frame.size.height = 220;
            webViewReferral.frame = frame;
        }
    }
    
    toolKitReferralStr = @"";
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

-(void)loadData
{
    webViewReferral.delegate = self;
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:0]]]]];
    toolKitReferralStr = [NSString stringWithFormat:@"http://www.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:0],[objManager getData:@"user_username"]];
    
    //
    for(int i=1;i<=toolkitIDArr.count;i++)
    {
        NSString *toolName = [NSString stringWithFormat:@"Toolbox %d",i];
        [toolKitNameArray addObject:toolName];
    }
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        layout.itemSize = CGSizeMake(250.0f, 80.0f);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 260.0f, 768.0f, 100.0f) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
        _collectionView.layer.borderWidth = 0.5;
        _collectionView.layer.cornerRadius = 5;

    }
    else
    {
        layout.itemSize = CGSizeMake(100.0f, 40.0f);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 145.0f, 320.0f, 50.0f) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
        _collectionView.layer.borderWidth = 0.5;
        _collectionView.layer.cornerRadius = 5;
    }
    
    
    
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[CustomCells class] forCellWithReuseIdentifier:@"CustomCells"];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [toolKitNameArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CustomCells";
    
    CustomCells *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.mylabel.text = [toolKitNameArray objectAtIndex:indexPath.row];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
    NSLog(@"%@",[toolKitNameArray objectAtIndex:indexPath.row]);
    
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:indexPath.row]]]]];
    toolKitReferralStr = [NSString stringWithFormat:@"http://www.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:indexPath.row],[objManager getData:@"user_username"]];
    
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.center;
    NSLog(@"%@",NSStringFromCGPoint(point));
    
    NSIndexPath *inde = [self.collectionView indexPathForItemAtPoint:point];
    int index = inde.row;
    
    NSLog(@"%i",index);
    
}

//WEbView Required Delegates
-(void)chooseView
{
    ReferralStageFourVC *rf4 = [[ReferralStageFourVC alloc] init];
    
    rf4.toolkitLink = toolKitReferralStr;
    [self.navigationController pushViewController:rf4 animated:YES];
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar;
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
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 768, 150)];
        navTitle.frame = CGRectMake(280, 100, 250, 50);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, 120, 100.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
        buttonLeft.frame = CGRectMake(670, 120, 100, 30.0);
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
        navTitle.frame = CGRectMake(110, 50, 120, 40);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        buttonLeft.frame = CGRectMake(260, 50, 60, 30.0);
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
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
}

-(void)openHomeController
{
    HomeViewController *hm =[[HomeViewController alloc] init];
    [self.navigationController pushViewController:hm animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
