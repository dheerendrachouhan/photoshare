//
//  MyReferralViewController.m
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "MyReferralViewController.h"
#import "CustomCell.h"
#import "SVProgressHUD.h"
#import "NavigationBar.h"
#import "ContentManager.h"
#import "CustomCelliPad.h"

@interface MyReferralViewController ()
{
    CustomCell *cell;
    CustomCelliPad *cells;
    WebserviceController *webServiceHlpr;
    NSNumber *userID;
    NSMutableArray *userNameArr;
    NSMutableArray *userActiveArr;
    NSMutableArray *userDateArr;
    CGRect frame;
}
@end

@implementation MyReferralViewController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    ObjManager = [ContentManager sharedManager];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"MyReferralViewController_iPad" owner:self options:Nil];
    }
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
    
    dmc = [[DataMapperController alloc] init];
    
    
    userID = [NSNumber numberWithInteger:[[dmc getUserId]integerValue]];
  
    // Do any additional setup after loading the view from its nib.
    
    userNameArr = [[NSMutableArray alloc] init];
    userActiveArr = [[NSMutableArray alloc] init];
    userDateArr = [[NSMutableArray alloc] init];
    
    
    [self.navigationItem setTitle:@"My Referrals"];
    webServiceHlpr = [[WebserviceController alloc] init];
    webServiceHlpr.delegate = self;
    
    //NSString *postStr = [NSString stringWithFormat:@"user_id=%@",userID] ;
    NSDictionary *dictData = @{@"user_id":userID};
    [webServiceHlpr call:dictData controller:@"user" method:@"getearningsdetails"];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    
}

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"%@",data);
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    
    if(exitCode == 0){
        [SVProgressHUD dismissWithError:@"Failed to load data from Server"];
    } else if([data count] == 0){
        [SVProgressHUD dismissWithError:@"Failed to load data from Server"];
    }
    else {
        NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
        NSMutableDictionary *dOne = [outPutData valueForKey:@"user_referrals"];
        NSMutableDictionary *userSubScribeDict = [dOne valueForKey:@"subscribed"];
        NSMutableDictionary *userPendingDict = [dOne valueForKey:@"pending"];
        for(NSDictionary *val in userSubScribeDict)
        {
            NSLog(@"%@",val);
            [userNameArr addObject:[val valueForKey:@"user_realname"]];
            [userDateArr addObject:@""];
            NSString *activeState = [NSString stringWithFormat:@"%@",[val valueForKey:@"user_active"]];
            if([activeState isEqualToString:@"1"])
            {
                [userActiveArr addObject:@"joined"];
            }
        }
        for(NSDictionary *vall in userPendingDict)
        {
            NSLog(@"%@",vall);
            [userNameArr addObject:[vall valueForKey:@"emailaddress"]];
            NSString *stringDatePend = [vall valueForKey:@"since"];
           
            NSDateFormatter *fm = [[NSDateFormatter alloc] init];
            [fm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             NSDate *dates = [fm dateFromString:stringDatePend];
            [fm setDateFormat:@"dd MMMM yyyy"];
            NSString *nowDaye = [fm stringFromDate:dates];
            
            [userDateArr addObject:nowDaye];
            [userActiveArr addObject:@"pending"];
        }
        
        [SVProgressHUD dismissWithSuccess:@"Done"];
        [tableView reloadData];
        
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return userNameArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CustomCell";
    
    NSString * nib_name= @"CustomCell";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        nib_name = @"CustomCelliPad";
  
    }
        CustomCell *cell_obj = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell_obj==nil)
        {
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:nib_name owner:self options:nil];
            cell_obj=[nib objectAtIndex:0];
        }
    
    
        cell_obj.name.text = [userNameArr objectAtIndex:indexPath.row];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell_obj.name.font = [UIFont systemFontOfSize:12.0f];
        }
            
        cell_obj.joinStatus.text = [userActiveArr objectAtIndex:indexPath.row];
        cell_obj.joinedDate.text = [userDateArr objectAtIndex:indexPath.row];
        cell_obj.imageView.image = [UIImage imageNamed:@"icon-person.png"];
    return cell_obj;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
         return 130;
     }
    else
    {
        return 65;
    }
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    NavigationBar *navnBar = [[NavigationBar alloc] init];
    UILabel *navTitle = [[UILabel alloc] init];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(navBackButtonClick) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    
    if([ObjManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(290, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            navTitle.frame = CGRectMake(410, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
        }
        
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 100.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            navTitle.frame = CGRectMake(110, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.height ==480)
            {
                [navnBar loadNav:CGRectNull :true];
                navTitle.frame = CGRectMake(190, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
            }
            else if ([[UIScreen mainScreen] bounds].size.height ==568)
            {
                [navnBar loadNav:CGRectNull :true];
                navTitle.frame = CGRectMake(230, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
            }
        }
        
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    navTitle.text = @"My Referrals";
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:ObjManager.weeklyearningStr];
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
    frame = tableView.frame;
    
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            frame.size.width = 480;
            tableView.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 568;
            tableView.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
           frame.size.width = 320;
            tableView.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 320;
            tableView.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame.size.width = 768;
            tableView.frame = frame;
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
    frame = tableView.frame;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            frame.size.width = 480;
            tableView.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 568;
            tableView.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame.size.width = 1024;
            tableView.frame = frame;
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            frame.size.width = 320;
            tableView.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 320;
            tableView.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame.size.width = 768;
            tableView.frame = frame;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
