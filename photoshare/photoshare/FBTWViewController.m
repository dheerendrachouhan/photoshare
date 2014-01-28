//
//  FBTWViewController.m
//  photoshare
//
//  Created by ignis3 on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "FBTWViewController.h"

@interface FBTWViewController ()

@end

@implementation FBTWViewController
@synthesize successType;
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
    if([successType isEqualToString:@"fb"])
    {
        scocialType.image = [UIImage imageNamed:@"facebook.png"];
    }
    else if([successType isEqualToString:@"tw"])
    {
        scocialType.image = [UIImage imageNamed:@"twitter.png"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
