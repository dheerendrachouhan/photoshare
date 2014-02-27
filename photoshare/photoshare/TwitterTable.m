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
#import "NavigationBar.h"
#import "ContentManager.h"

@interface TwitterTable ()

@end

@implementation TwitterTable
{
    NSMutableArray *selectedUserArr;
    NSMutableArray *finalSelectArr;
    NSMutableString *StringTweet;
    CGRect frame;
    NavigationBar *navnBar;
}
@synthesize table;
@synthesize tweetUserName;
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
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [[NSBundle mainBundle] loadNibNamed:@"TwitterTable" owner:self options:nil];
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"TwitterTable_iPad" owner:self options:nil];
    }
    navnBar = [[NavigationBar alloc] init];
    [SVProgressHUD dismissWithSuccess:@"Loaded"];
    // Do any additional setup after loading the view from its nib.
    selectedUserArr = [[NSMutableArray alloc] init];
    finalSelectArr = [[NSMutableArray alloc] init];
}

- (IBAction)doneBtnPressed:(id)sender {
    ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
    rf.twitterTweet = [NSString stringWithFormat:@"%@",StringTweet];
    [self.navigationController popToViewController:rf animated:YES];
    [SVProgressHUD showWithStatus:@"Composing" maskType:SVProgressHUDMaskTypeBlack];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identitifier];
    }
    cell.textLabel.text = [tweetUserName objectAtIndex:indexPath.row];
    
    UIButton *checkBox = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        checkBox.Frame = CGRectMake(250.0f, 10.0f, 25.0f, 25.0f);
    }
    else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        checkBox.Frame = CGRectMake(700.0f, 10.0f, 25.0f, 25.0f);
    }
    
    [checkBox setImage:[UIImage imageNamed:@"iconr3_uncheck.png"] forState:UIControlStateNormal];
    
    [checkBox setImage:[UIImage imageNamed:@"iconr3.png"] forState:UIControlStateSelected];
    
    [cell addSubview:checkBox];
    
    [checkBox addTarget:self action:@selector(sameB:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    UILabel *navTitle = [[UILabel alloc] init];
    
    //Button for Next
    UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonLeft addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonLeft setTitle:@"Done >" forState:UIControlStateNormal];
    if([objManager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
             navTitle.frame = CGRectMake(220, NavBtnYPosForiPad, 320, NavBtnHeightForiPad);
            buttonLeft.frame = CGRectMake(620, NavBtnYPosForiPad, 140, NavBtnHeightForiPad);
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            navTitle.frame = CGRectMake(360, NavBtnYPosForiPad, 320, NavBtnHeightForiPad);
            buttonLeft.frame = CGRectMake(900, NavBtnYPosForiPad, 140, NavBtnHeightForiPad);
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
             navTitle.frame = CGRectMake(80, NavBtnYPosForiPhone, 170, NavBtnHeightForiPhone);
            buttonLeft.frame = CGRectMake(240, NavBtnYPosForiPhone, 80, NavBtnHeightForiPhone);
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            if([[UIScreen mainScreen] bounds].size.height ==480)
            {
                 navTitle.frame = CGRectMake(160, NavBtnYPosForiPhone, 170, NavBtnHeightForiPhone);
                buttonLeft.frame = CGRectMake(400, NavBtnYPosForiPhone, 80, NavBtnHeightForiPhone);
            }
            else
            {
                 navTitle.frame = CGRectMake(200, NavBtnYPosForiPhone, 170, NavBtnHeightForiPhone);
                buttonLeft.frame = CGRectMake(490, NavBtnYPosForiPhone, 80, NavBtnHeightForiPhone);
            }
        }
        
       
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        buttonLeft.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    navTitle.text = @"Pick Twitter Firends";
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self addCustomNavigationBar];
    frame = table.frame;
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
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
            frame.size.width = 1024;
            table.frame = frame;
        }
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
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

@end
