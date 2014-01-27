//
//  MyReferralViewController.m
//  photoshare
//
//  Created by ignis3 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "MyReferralViewController.h"
#import "CustomCell.h"

@interface MyReferralViewController ()
{
    CustomCell *cell;
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
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"My Referrals"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CustomCell";
    cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil)
    {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
        cell=[nib objectAtIndex:0];
    }


    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
