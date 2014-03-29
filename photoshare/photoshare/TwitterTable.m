//
//  TwitterTable.m
//  photoshare
//
//  Created by ignis3 on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "TwitterTable.h"
#import "SVProgressHUD.h"
#import "ReferralStageFourVC.h"
#import "ContentManager.h"

@interface TwitterTable ()

@end

@implementation TwitterTable
{
    NSMutableArray *selectedUserArr;
    NSMutableArray *finalSelectArr;
    NSMutableString *StringTweet;
    CGRect frame;
}
@synthesize table;
@synthesize tweetUserName,tweetUserIDsArray,accountType,accountStore;
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
    
    twiiterListArr=[[NSMutableArray alloc] init];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [[NSBundle mainBundle] loadNibNamed:@"TwitterTable" owner:self options:nil];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"TwitterTable_iPad" owner:self options:nil];
    }
    [SVProgressHUD dismissWithSuccess:@"Loaded"];
    // Do any additional setup after loading the view from its nib.
    selectedUserArr = [[NSMutableArray alloc] init];
    finalSelectArr = [[NSMutableArray alloc] init];
    
    [self addCustomNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
    [self detectDeviceOrientation];
    [self performSelectorInBackground:@selector(getUserNameFromTwitter) withObject:nil];
    
}
-(void)getUserNameFromTwitter
{
    if(tweetUserIDsArray.count>0)
    {
        isPopFromSelf=NO;
        [self getFollowerNameFromID:[tweetUserIDsArray objectAtIndex:0]];
    }
}
- (void)doneBtnPressed:(id)sender {
    ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
    rf.twitterTweet = [NSString stringWithFormat:@"%@",StringTweet];
    [self.navigationController popToViewController:rf animated:YES];
    if(IS_OS_7_OR_LATER)
    {
        [SVProgressHUD showWithStatus:@"Composing" maskType:SVProgressHUDMaskTypeBlack];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tweetUserName count] == 0)
    {
        return 0;
    }
    else
    {
        return tweetUserName.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identitifier = @"demoTableViewIdentifier";
    UITableViewCell * cell = [table dequeueReusableCellWithIdentifier:identitifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identitifier];
        UIButton *checkBoxBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    
        checkBoxBtn.frame=CGRectMake(cell.frame.size.width-40,5, 20,20);
        checkBoxBtn.tag=1001;
        checkBoxBtn.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
        checkBoxBtn.layer.borderWidth=1;
        checkBoxBtn.layer.borderColor=BTN_BORDER_COLOR.CGColor;
        [checkBoxBtn setImage:[UIImage imageNamed:@"iconr3_uncheck.png"] forState:UIControlStateNormal];
        
        [checkBoxBtn setImage:[UIImage imageNamed:@"iconr3.png"] forState:UIControlStateSelected];
        [checkBoxBtn addTarget:self action:@selector(sameB:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:checkBoxBtn];
    }
    cell.textLabel.frame=CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width-45, cell.textLabel.frame.size.height);
    
    cell.textLabel.text = [tweetUserName objectAtIndex:indexPath.row];
    UIButton *checkBox = (UIButton *)[cell.contentView viewWithTag:1001];
    if([selectedUserArr containsObject:[tweetUserName objectAtIndex:indexPath.row]])
    {
        checkBox.selected=YES;
    }
    else
    {
        checkBox.selected=NO;
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

-(IBAction)sameB:(id)sender
{
    NSMutableString *tweetString = [[NSMutableString alloc] init];
    UIButton *btn = (UIButton *) sender;
    btn.selected = !btn.selected;
    BOOL valz = (BOOL)btn.selected;
    if(valz==1)
    {
        CGRect buttonFrameInTableView = [btn convertRect:btn.bounds toView:table];
        
        NSIndexPath *indexPath = [table indexPathForRowAtPoint:buttonFrameInTableView.origin];
        NSLog(@"%d",indexPath.row);
        [selectedUserArr addObject:[tweetUserName objectAtIndex:indexPath.row]];
        for(int i=0;i<[selectedUserArr count];i++)
        {
            if([tweetString length])
            {
                [tweetString appendString:@" , "];
            }
            [tweetString appendString:[selectedUserArr objectAtIndex:i]];
        }
        finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
        StringTweet = [NSMutableString stringWithString:tweetString];
    }
    else if(valz == 0)
    {
        tweetString = [NSMutableString stringWithString:@""];
        CGRect buttonFrameInTableView = [btn convertRect:btn.bounds toView:table];
        
        NSIndexPath *indexPath = [table indexPathForRowAtPoint:buttonFrameInTableView.origin];
        NSLog(@"%d",indexPath.row);
        [finalSelectArr removeAllObjects];
        for(NSString *match in selectedUserArr)
        {
            NSLog(@"%@",match);
            if([match isEqualToString:[tweetUserName objectAtIndex:indexPath.row]])
            {
                NSLog(@"Match Found");
            }
            else
            {
                if([tweetString length])
                {
                    [tweetString appendString:@" , "];
                }
                [tweetString appendFormat:@"%@",match];
                [finalSelectArr addObject:match];
            }
            
        }
        [selectedUserArr removeAllObjects];
        selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
        StringTweet = [NSMutableString stringWithString:tweetString];
    }
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button =[navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    UILabel *navTitle = [navnBar navBarTitleLabel:@"Pick Twitter Friends"];
    
    //Button for Next
    UIButton *doneBtn =[navnBar navBarRightButton:@"Done >"];
    [doneBtn addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    [navnBar addSubview:doneBtn];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
}
-(void)orient:(UIInterfaceOrientation)ott
{
    frame = table.frame;
    
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            frame.size.width = 480;
            table.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 568;
            table.frame = frame;
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
            table.frame = frame;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            frame.size.width = 320;
            table.frame = frame;
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            frame.size.width = 768;
            table.frame = frame;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma  mark - Twitter Get UserName

-(void)getFollowerNameFromID:(NSString *)ID{
    
    // Request access to the Twitter account
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                // Creating a request to get the info about a user on Twitter
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",ID] forKey:@"user_id"]];
                
                [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            isPopFromSelf=YES;
                            NSLog(@"Rate limit reached");
                            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Rate limit reached" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [alert show];
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            
                            NSError *error = nil;
                            
                            NSDictionary *friendsdata = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            NSLog(@"friendsdata value is %@", friendsdata);
                            
                            NSString *stt= [@"@" stringByAppendingString:[friendsdata objectForKey:@"screen_name"]];
                            
                            @try {
                                [twiiterListArr addObject:stt];
                                if(tweetUserIDsArray.count!=twiiterListArr.count)
                                {
                                    if(!isPopFromSelf)
                                    {
                                        tweetUserName=[twiiterListArr mutableCopy];
                                        // First figure out how many sections there are
                                        NSInteger lastSectionIndex = [table numberOfSections] - 1;
                                        
                                        // Then grab the number of rows in the last section
                                        NSInteger lastRowIndex =tweetUserName.count-1;
                                        
                                        // Now just construct the index path
                                        NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
                                        [table beginUpdates];
                                        [table insertRowsAtIndexPaths:[NSArray arrayWithObjects:pathToLastRow, nil] withRowAnimation:UITableViewRowAnimationNone];
                                        [table endUpdates];
                                        
                                        [self getFollowerNameFromID:[tweetUserIDsArray objectAtIndex:twiiterListArr.count]];
                                    }
                                    
                                }
                                
                                //[table reloadData];
                            }
                            @catch (NSException *exception) {
                                NSLog(@"Exception is %@",exception.description);
                            }
                            @finally {
                                
                            }
                        }
                    });
                }];
            }
    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    isPopFromSelf=YES;
}


@end
