//
//  TMailMessageTable.m
//  photoshare
//
//  Created by ignis3 on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "MailMessageTable.h"
#import "SVProgressHUD.h"
#import "ReferralStageFourVC.h" //for text and mail composition
#import "PhotoShareController.h" //for text and mail composition
#import "NavigationBar.h"
#import "ContentManager.h"
#import "SVProgressHUD.h"

@interface MailMessageTable ()

@end

@implementation MailMessageTable
{
    NSMutableArray *contactName;
    NSMutableArray *contactEmail;
    NSMutableArray *contactPhone;
    NSMutableArray *selectedUserArr;
    NSMutableArray *finalSelectArr;
    NSMutableString *StringTweet;
    NSMutableArray *arSelectedRows;
    NSTimer *timer;
    BOOL check;
    
}
@synthesize table;
@synthesize contactDictionary,filterType;

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
    // Do any additional setup after loading the view from its nib.
    check = YES;
    checkBoxBtn_Arr = [[NSMutableArray alloc] init];
    arSelectedRows = [[NSMutableArray alloc] init];
    contactName = [[NSMutableArray alloc] init];
    contactEmail = [[NSMutableArray alloc] init];
    contactPhone = [[NSMutableArray alloc] init];
    selectedUserArr = [[NSMutableArray alloc] init];
    finalSelectArr = [[NSMutableArray alloc] init];
    [SVProgressHUD showWithStatus:@"Loading Contacts" maskType:SVProgressHUDMaskTypeBlack];
    //This function is for Referral Portion
    if([filterType isEqualToString:@"Refer Mail"])
    {
        if(contactDictionary.count >0)
        {
            for(int i=0;i<contactDictionary.count;i++)
            {
                NSDictionary *demo = [contactDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                NSArray *splitEmail = [[demo objectForKey:@"email"] componentsSeparatedByString:@","];
                
                for(int j=0;j<splitEmail.count;j++)
                {
                    NSString *test =[NSString stringWithFormat:@"%@",[splitEmail objectAtIndex:j]];
                    if(test.length != 0)
                    {
                        [contactName addObject:[demo objectForKey:@"name"]];
                        [contactEmail addObject:[splitEmail objectAtIndex:j]];
                    }
                }
            }
        }
    }
    else if([filterType isEqualToString:@"Refer Text"])
    {
        if(contactDictionary.count >0)
        {
            for(int i=0;i<contactDictionary.count;i++)
            {
                NSDictionary *demo = [contactDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                
                NSArray *splitPhone = [[demo objectForKey:@"phone"] componentsSeparatedByString:@","];
                
                for(int j=0;j<splitPhone.count;j++)
                {
                    NSString *test =[NSString stringWithFormat:@"%@",[splitPhone objectAtIndex:j]];
                    if(test.length != 0)
                    {
                        [contactName addObject:[demo objectForKey:@"name"]];
                        [contactPhone addObject:[splitPhone objectAtIndex:j]];
                    }
                }
            }
        }
    }
    
    
    //This Section is for Sharing the Photo
    if([filterType isEqualToString:@"Share Mail"])
    {
        if(contactDictionary.count >0)
        {
            for(int i=0;i<contactDictionary.count;i++)
            {
                NSDictionary *demo = [contactDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                NSArray *splitEmail = [[demo objectForKey:@"email"] componentsSeparatedByString:@","];
                
                for(int j=0;j<splitEmail.count;j++)
                {
                    NSString *test =[NSString stringWithFormat:@"%@",[splitEmail objectAtIndex:j]];
                    if(test.length != 0)
                    {
                        [contactName addObject:[demo objectForKey:@"name"]];
                        [contactEmail addObject:[splitEmail objectAtIndex:j]];
                    }
                }
            }
        }
    }
    else if([filterType isEqualToString:@"Share Text"])
    {
        if(contactDictionary.count >0)
        {
            for(int i=0;i<contactDictionary.count;i++)
            {
                NSDictionary *demo = [contactDictionary objectForKey:[NSString stringWithFormat:@"%d",i]];
                
                
                NSArray *splitPhone = [[demo objectForKey:@"phone"] componentsSeparatedByString:@","];
                
                for(int j=0;j<splitPhone.count;j++)
                {
                    NSString *test =[NSString stringWithFormat:@"%@",[splitPhone objectAtIndex:j]];
                    if(test.length != 0)
                    {
                        [contactName addObject:[demo objectForKey:@"name"]];
                        [contactPhone addObject:[splitPhone objectAtIndex:j]];
                    }
                }
            }
        }
    }
    [SVProgressHUD dismissWithSuccess:@"Contacts Loaded"];

}

- (IBAction)doneBtnPressed:(id)sender {
    if([filterType isEqualToString:@"Refer Mail"])
    {
        ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
        rf.referEmailStr = StringTweet;
        rf.referredValue = @"Refer Mail";
        [self.navigationController popToViewController:rf animated:YES];
    }
    else if([filterType isEqualToString:@"Refer Text"])
    {
        ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
        rf.referPhoneStr = StringTweet;
        rf.referredValue = @"Refer Text";
        [self.navigationController popToViewController:rf animated:YES];
    }
    else if([filterType isEqualToString:@"Share Mail"])
    {
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:3];
            psVC.shareEmailStr = StringTweet;
            psVC.shareValue = @"Share Mail";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:2];
            psVC.shareEmailStr = StringTweet;
            psVC.shareValue = @"Share Mail";
            [self.navigationController popToViewController:psVC animated:YES];

        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:4];
            psVC.shareEmailStr = StringTweet;
            psVC.shareValue = @"Share Mail";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
    }
    else if([filterType isEqualToString:@"Share Text"])
    {
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:3];
            psVC.sharePhoneStr = StringTweet;
            psVC.shareValue = @"Share Text";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:2];
            psVC.sharePhoneStr = StringTweet;
            psVC.shareValue = @"Share Text";
            [self.navigationController popToViewController:psVC animated:YES];
            
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
        
        @try {
            PhotoShareController *psVC = (PhotoShareController *)[self.navigationController.viewControllers objectAtIndex:4];
            psVC.sharePhoneStr = StringTweet;
            psVC.shareValue = @"Share Text";
            [self.navigationController popToViewController:psVC animated:YES];
        }
        @catch (NSException *exception) {
            NSLog( @"NSException caught" );
            NSLog( @"Name: %@", exception.name);
            NSLog( @"Reason: %@", exception.reason );
        }
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([contactName count] == 0)
    {
        return 0;
    }
    else
    {
        return contactName.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identitifier = @"demoTableViewIdentifier";
    UITableViewCell * cell = [table dequeueReusableCellWithIdentifier:identitifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identitifier];
    }
    
    
    if([filterType isEqualToString:@"Refer Mail"])
    {
        cell.textLabel.text = [contactName objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [contactEmail objectAtIndex:indexPath.row];
        
        if([arSelectedRows containsObject:indexPath])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [checkBoxBtn_Arr addObject:indexPath];
        
    }
    else if([filterType isEqualToString:@"Refer Text"])
    {
        cell.textLabel.text = [contactName objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [contactPhone objectAtIndex:indexPath.row];
        
        if([arSelectedRows containsObject:indexPath])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [checkBoxBtn_Arr addObject:indexPath];
    }
    else if([filterType isEqualToString:@"Share Mail"])
    {
        cell.textLabel.text = [contactName objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [contactEmail objectAtIndex:indexPath.row];
        
        if([arSelectedRows containsObject:indexPath])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [checkBoxBtn_Arr addObject:indexPath];
    }
    else if([filterType isEqualToString:@"Share Text"])
    {
        cell.textLabel.text = [contactName objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [contactPhone objectAtIndex:indexPath.row];
        
        if([arSelectedRows containsObject:indexPath])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [checkBoxBtn_Arr addObject:indexPath];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([filterType isEqualToString:@"Refer Mail"])
    {
        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
        NSMutableString *tweetString = [[NSMutableString alloc] init];
    
        if(cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedUserArr addObject:[contactEmail objectAtIndex:indexPath.row]];
            for(int i=0;i<[selectedUserArr count];i++)
            {
                if([tweetString length])
                {
                    [tweetString appendString:@", "];
                }
                [tweetString appendString:[selectedUserArr objectAtIndex:i]];
            }
            finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        
            tweetString = [NSMutableString stringWithString:@""];
            [finalSelectArr removeAllObjects];
            for(NSString *match in selectedUserArr)
            {
                NSLog(@"%@",match);
                if([match isEqualToString:[contactEmail objectAtIndex:indexPath.row]])
                {
                    NSLog(@"Match Found");
                }
                else
                {
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendFormat:@"%@",match];
                    [finalSelectArr addObject:match];
                }
            
            }
            [selectedUserArr removeAllObjects];
            selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows removeObject:indexPath];
        }
    }
    else if([filterType isEqualToString:@"Refer Text"])
    {
        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
        NSMutableString *tweetString = [[NSMutableString alloc] init];
        
        if(cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedUserArr addObject:[contactPhone objectAtIndex:indexPath.row]];
            for(int i=0;i<[selectedUserArr count];i++)
            {
                if([tweetString length])
                {
                    [tweetString appendString:@", "];
                }
                [tweetString appendString:[selectedUserArr objectAtIndex:i]];
            }
            finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            tweetString = [NSMutableString stringWithString:@""];
            [finalSelectArr removeAllObjects];
            for(NSString *match in selectedUserArr)
            {
                NSLog(@"%@",match);
                if([match isEqualToString:[contactPhone objectAtIndex:indexPath.row]])
                {
                    NSLog(@"Match Found");
                }
                else
                {
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendFormat:@"%@",match];
                    [finalSelectArr addObject:match];
                }
                
            }
            [selectedUserArr removeAllObjects];
            selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows removeObject:indexPath];
        }
    }
    else if([filterType isEqualToString:@"Share Mail"])
    {
        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
        NSMutableString *tweetString = [[NSMutableString alloc] init];
        
        if(cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedUserArr addObject:[contactEmail objectAtIndex:indexPath.row]];
            for(int i=0;i<[selectedUserArr count];i++)
            {
                if([tweetString length])
                {
                    [tweetString appendString:@", "];
                }
                [tweetString appendString:[selectedUserArr objectAtIndex:i]];
            }
            finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            tweetString = [NSMutableString stringWithString:@""];
            [finalSelectArr removeAllObjects];
            for(NSString *match in selectedUserArr)
            {
                NSLog(@"%@",match);
                if([match isEqualToString:[contactEmail objectAtIndex:indexPath.row]])
                {
                    NSLog(@"Match Found");
                }
                else
                {
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendFormat:@"%@",match];
                    [finalSelectArr addObject:match];
                }
                
            }
            [selectedUserArr removeAllObjects];
            selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows removeObject:indexPath];
        }
    }
    else if([filterType isEqualToString:@"Share Text"])
    {
        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
        NSMutableString *tweetString = [[NSMutableString alloc] init];
        
        if(cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedUserArr addObject:[contactPhone objectAtIndex:indexPath.row]];
            for(int i=0;i<[selectedUserArr count];i++)
            {
                if([tweetString length])
                {
                    [tweetString appendString:@", "];
                }
                [tweetString appendString:[selectedUserArr objectAtIndex:i]];
            }
            finalSelectArr = [NSMutableArray arrayWithArray:selectedUserArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows addObject:indexPath];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            tweetString = [NSMutableString stringWithString:@""];
            [finalSelectArr removeAllObjects];
            for(NSString *match in selectedUserArr)
            {
                NSLog(@"%@",match);
                if([match isEqualToString:[contactPhone objectAtIndex:indexPath.row]])
                {
                    NSLog(@"Match Found");
                }
                else
                {
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendFormat:@"%@",match];
                    [finalSelectArr addObject:match];
                }
                
            }
            [selectedUserArr removeAllObjects];
            selectedUserArr = [NSMutableArray arrayWithArray:finalSelectArr];
            StringTweet = [NSMutableString stringWithString:tweetString];
            [arSelectedRows removeObject:indexPath];
        }
    }
}


//Testing Area

- (IBAction)selectAllbtn:(id)sender {
    
    NSMutableString *tweetString = [[NSMutableString alloc] init];
    
    if([filterType isEqualToString:@"Refer Mail"])
    {
        if(check)
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryCheckmark];
                    [arSelectedRows addObject:[NSIndexPath indexPathForRow:r inSection:s]];
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendString:[contactEmail objectAtIndex:r]];
                    [selectedUserArr addObject:[contactEmail objectAtIndex:r]];
                }
                StringTweet = [NSMutableString stringWithString:tweetString];
                
            }
            check = NO;
        }
        else
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryNone];
                    [arSelectedRows removeObject:[NSIndexPath indexPathForRow:r inSection:s]];
                }
            }
            StringTweet = nil;
            check = YES;
            [selectedUserArr removeLastObject];
        }
    }
    
    else if([filterType isEqualToString:@"Refer Text"])
    {
        if(check)
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryCheckmark];
                    [arSelectedRows addObject:[NSIndexPath indexPathForRow:r inSection:s]];
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendString:[contactPhone objectAtIndex:r]];
                    [selectedUserArr addObject:[contactPhone objectAtIndex:r]];
                }
                
            }
            check = NO;
        }
        else
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryNone];
                    [arSelectedRows removeObject:[NSIndexPath indexPathForRow:r inSection:s]];
                }
            }
            StringTweet = nil;
            check = YES;
            [selectedUserArr removeLastObject];
        }
    }
    else if([filterType isEqualToString:@"Share Mail"])
    {
        if(check)
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryCheckmark];
                    [arSelectedRows addObject:[NSIndexPath indexPathForRow:r inSection:s]];
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendString:[contactEmail objectAtIndex:r]];
                    [selectedUserArr addObject:[contactEmail objectAtIndex:r]];
                }
                StringTweet = [NSMutableString stringWithString:tweetString];
            }
            check = NO;
        }
        else
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryNone];
                    [arSelectedRows removeObject:[NSIndexPath indexPathForRow:r inSection:s]];
                }
            }
            StringTweet = nil;
            check = YES;
            [selectedUserArr removeLastObject];
        }
    }
    else if([filterType isEqualToString:@"Share Text"])
    {
        if(check)
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryCheckmark];
                    [arSelectedRows addObject:[NSIndexPath indexPathForRow:r inSection:s]];
                    if([tweetString length])
                    {
                        [tweetString appendString:@", "];
                    }
                    [tweetString appendString:[contactPhone objectAtIndex:r]];
                    [selectedUserArr addObject:[contactPhone objectAtIndex:r]];
                }
                StringTweet = [NSMutableString stringWithString:tweetString];
            }
            check = NO;
        }
        else
        {
            for (NSInteger s = 0; s < self.table.numberOfSections; s++)
            {
                for (NSInteger r = 0; r < [self.table numberOfRowsInSection:s]; r++)
                {
                    [[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]] setAccessoryType:UITableViewCellAccessoryNone];
                    [arSelectedRows removeObject:[NSIndexPath indexPathForRow:r inSection:s]];
                }
            }
            StringTweet = nil;
            check = YES;
            [selectedUserArr removeLastObject];
        }
    }
}

// testing area Finished

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 50, 70.0, 30.0);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    UILabel *navTitle = [[UILabel alloc] initWithFrame:CGRectMake(120, 50, 80, 40)];
    navTitle.font = [UIFont systemFontOfSize:17.0f];
    navTitle.text = @"Contacts";
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];
    
    
    //Button for Next
    UIButton *buttonLeft = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonLeft addTarget:self action:@selector(doneBtnPressed:) forControlEvents:UIControlEventTouchDown];
    [buttonLeft setTitle:@"Done >" forState:UIControlStateNormal];
    buttonLeft.frame = CGRectMake(240, 50, 90, 30.0);
    buttonLeft.titleLabel.font = [UIFont systemFontOfSize:17.0f];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
