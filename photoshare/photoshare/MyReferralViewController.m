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
    [self addCustomNavigationBar];
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
    
    
    NSDictionary *dictData = @{@"user_id":userID};
    [webServiceHlpr call:dictData controller:@"user" method:@"getearningsdetails"];
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    tableView.autoresizesSubviews = UIViewAutoresizingFlexibleWidth;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:ObjManager.weeklyearningStr];
    [self detectDeviceOrientation];
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
        if(userNameArr.count == 0)
        {
            [ObjManager showAlert:@"Message" msg:@"Zero referrals" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(userActiveArr.count == 0)
    {
        return 0;
    }
    else
    {
        return userNameArr.count;
    }
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
    cell_obj.selectionStyle=UITableViewCellSelectionStyleNone;
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
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"<Back"];
    [button addTarget:self action:@selector(navBackButtonClick) forControlEvents:UIControlEventTouchDown];
    UILabel *navTitle = [navnBar navBarTitleLabel:@"My Referrals"];
  
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:ObjManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

#pragma mark - Device Orientation
-(void)detectDeviceOrientation
{
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
    [self orient:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
