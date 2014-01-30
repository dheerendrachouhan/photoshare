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

@interface TwitterTable ()

@end

@implementation TwitterTable
{
    NSMutableArray *selectedUserArr;
    NSMutableArray *finalSelectArr;
    NSMutableString *StringTweet;
}
@synthesize table;
@synthesize tweetUserName;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SVProgressHUD dismissWithSuccess:@"Loaded"];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"Pick Twetter Friends"];
    selectedUserArr = [[NSMutableArray alloc] init];
    finalSelectArr = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed:)];
    self.navigationItem.rightBarButtonItem = backButton;
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
    
    checkBox.Frame = CGRectMake(250.0f, 10.0f, 25.0f, 25.0f);
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
