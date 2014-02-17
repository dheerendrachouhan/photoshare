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
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        identifier = @"CustomCelliPad";
        cells = [tableView dequeueReusableCellWithIdentifier:identifier];
        if(cells==nil)
        {
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"CustomCelliPad" owner:self options:nil];
            cells=[nib objectAtIndex:0];
        }
        cells.name.text = [userNameArr objectAtIndex:indexPath.row];
        
        cells.joinStatus.text = [userActiveArr objectAtIndex:indexPath.row];
        cells.joinedDate.text = [userDateArr objectAtIndex:indexPath.row];
        cells.imageView.image = [UIImage imageNamed:@"icon-person.png"];
        return cells;
    }
    else
    {
        identifier=@"CustomCell";
        cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if(cell==nil)
        {
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
            cell=[nib objectAtIndex:0];
        }
        cell.name.text = [userNameArr objectAtIndex:indexPath.row];
        cell.name.font = [UIFont systemFontOfSize:12.0f];
        cell.joinStatus.text = [userActiveArr objectAtIndex:indexPath.row];
        cell.joinedDate.text = [userDateArr objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:@"icon-person.png"];
        return  cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
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
    
    
    if([ObjManager isiPad])
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 768, 135)];
        navTitle.frame = CGRectMake(290, 90, 250, 50);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, 100, 100.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
        navTitle.frame = CGRectMake(110, 50, 120, 40);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
