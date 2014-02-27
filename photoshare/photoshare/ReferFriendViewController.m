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
            frame.origin.y = 105;
            frame.size.height = 220;
            webViewReferral.frame = frame;
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
    }
}

-(void)loadData
{
    webViewReferral.delegate = self;
    [self.webViewReferral loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://player.vimeo.com/video/%@",[toolkitVimeoIDArr objectAtIndex:0]]]]];
    toolKitReferralStr = [NSString stringWithFormat:@"http://www.123friday.com/my123/live/toolkit/%@/%@",[toolkitIDArr objectAtIndex:0],[objManager getData:@"user_username"]];
    
    for(int i=1;i<=toolkitIDArr.count;i++)
    {
        NSString *toolName = [NSString stringWithFormat:@"Video %d",i];
        [toolKitNameArray addObject:toolName];
    }
    
    layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
        layout.itemSize = CGSizeMake(250.0f, 80.0f);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 768.0f, 100.0f) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
        _collectionView.layer.borderWidth = 0.5;
        _collectionView.layer.cornerRadius = 5;
        }
        else
        {
            layout.itemSize = CGSizeMake(250.0f, 80.0f);
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 1024.0f, 100.0f) collectionViewLayout:layout];
            _collectionView.backgroundColor = [UIColor whiteColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
            _collectionView.layer.borderWidth = 0.5;
            _collectionView.layer.cornerRadius = 5;
        }
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            layout.itemSize = CGSizeMake(100.0f, 40.0f);
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, 320.0f, 50.0f) collectionViewLayout:layout];
            _collectionView.backgroundColor = [UIColor whiteColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
            _collectionView.layer.borderWidth = 0.5;
            _collectionView.layer.cornerRadius = 5;
        }else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480.0f)
            {
                layout.itemSize = CGSizeMake(100.0f, 40.0f);
                _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, 480.0f, 50.0f) collectionViewLayout:layout];
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
                _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, 568.0f, 50.0f) collectionViewLayout:layout];
                _collectionView.backgroundColor = [UIColor whiteColor];
                _collectionView.dataSource = self;
                _collectionView.delegate = self;
                _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
                _collectionView.layer.borderWidth = 0.5;
                _collectionView.layer.cornerRadius = 5;
            }
        }
        
    }
    
    [scrollView addSubview:_collectionView];
    
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
            [self CollectionLayoutRotation];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 440);
            scrollView.bounces = NO;
            [self CollectionLayoutRotation];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 1024, 700);
            scrollView.contentSize = CGSizeMake(1024, 770);
            scrollView.bounces = NO;
            [self CollectionLayoutRotation];
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 300);
            [self CollectionLayoutRotation];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 423);
            scrollView.contentSize = CGSizeMake(320, 300);
            [self CollectionLayoutRotation];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 768, 780);
            scrollView.contentSize = CGSizeMake(768, 600);
            scrollView.bounces = NO;
            [self CollectionLayoutRotation];
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
            [self CollectionLayoutRotation];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 440);
            scrollView.bounces = NO;
            [self CollectionLayoutRotation];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 1024, 700);
            scrollView.contentSize = CGSizeMake(1024, 770);
            scrollView.bounces = NO;
            [self CollectionLayoutRotation];
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 300);
            [self CollectionLayoutRotation];
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 72, 320, 423);
            scrollView.contentSize = CGSizeMake(320, 300);
           [self CollectionLayoutRotation];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 161, 768, 780);
            scrollView.contentSize = CGSizeMake(768, 600);
            scrollView.bounces = NO;
            [self CollectionLayoutRotation];
        }
    }
}

-(void)CollectionLayoutRotation
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            layout.itemSize = CGSizeMake(250.0f, 80.0f);
            _collectionView.frame = CGRectMake(0.0f, 100.0f, 768.0f, 100.0f);
            _collectionView.backgroundColor = [UIColor whiteColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
            _collectionView.layer.borderWidth = 0.5;
            _collectionView.layer.cornerRadius = 5;
        }
        else
        {
            layout.itemSize = CGSizeMake(250.0f, 80.0f);
            _collectionView.frame = CGRectMake(0.0f, 100.0f, 1024.0f, 100.0f);
            _collectionView.backgroundColor = [UIColor whiteColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
            _collectionView.layer.borderWidth = 0.5;
            _collectionView.layer.cornerRadius = 5;
        }
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            layout.itemSize = CGSizeMake(100.0f, 40.0f);
            _collectionView.frame = CGRectMake(0.0f, 50.0f, 320.0f, 50.0f);
            _collectionView.backgroundColor = [UIColor whiteColor];
            _collectionView.dataSource = self;
            _collectionView.delegate = self;
            _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
            _collectionView.layer.borderWidth = 0.5;
            _collectionView.layer.cornerRadius = 5;
        }else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480.0f)
            {
                layout.itemSize = CGSizeMake(100.0f, 40.0f);
                _collectionView.frame = CGRectMake(0.0f, 50.0f, 480.0f, 50.0f);
                
                _collectionView.backgroundColor = [UIColor whiteColor];
                _collectionView.dataSource = self;
                _collectionView.delegate = self;
                _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
                _collectionView.layer.borderWidth = 0.5;
                _collectionView.layer.cornerRadius = 5;
            }
            else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
            {
                layout.itemSize = CGSizeMake(100.0f, 40.0f);
                _collectionView.frame = CGRectMake(0.0f, 50.0f, 568.0f, 50.0f);
                _collectionView.backgroundColor = [UIColor whiteColor];
                _collectionView.dataSource = self;
                _collectionView.delegate = self;
                _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
                _collectionView.layer.borderWidth = 0.5;
                _collectionView.layer.cornerRadius = 5;
            }
            
        }
        
    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
