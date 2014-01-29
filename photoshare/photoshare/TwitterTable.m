//
//  TwitterTable.m
//  photoshare
//
//  Created by ignis3 on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "TwitterTable.h"
#import "SVProgressHUD.h"

@interface TwitterTable ()

@end

@implementation TwitterTable
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
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
