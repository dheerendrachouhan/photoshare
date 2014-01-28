//
//  EditProfileViewController.m
//  photoshare
//
//  Created by Dhiru on 28/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditProfileViewController.h"
#import "WebserviceController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

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
    
   
    float btnBorderWidth=2;
    float btnCornerRadius=8;
    img.layer.cornerRadius=btnCornerRadius;
    img.layer.borderWidth=btnBorderWidth;
    img.layer.borderColor=[[UIColor darkGrayColor] CGColor];
    
    img.layer.backgroundColor = [[UIColor grayColor] CGColor];
    
   img =  [img initWithImage:[UIImage imageNamed:@"checkbox.png"]];
    
    
    [self getDetails] ;
    
}


-(void) getDetails
{
    NSString *postStr = [NSString stringWithFormat:@""];

}


-(IBAction)changeProfileImg:(id)sender
{
    NSLog(@"change profile image clicked");
}

-(IBAction)saveProfile:(id)sender
{
    NSLog(@"save profile clicked");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
