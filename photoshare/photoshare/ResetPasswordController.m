//
//  ResetPasswordController.m
//  photoshare
//
//  Created by ignis3 on 23/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "ResetPasswordController.h"
#import "LoginViewController.h"

@interface ResetPasswordController ()

@end

@implementation ResetPasswordController

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
	// Do any additional setup after loading the view.
    [emailTextField setDelegate:self];
    resetpasswordBtn.layer.cornerRadius = 8.0;
    resetpasswordBtn.layer.borderWidth = 1.0;
    reserFlt = NO;
    
    resetpasswordBtn.layer.borderColor = [UIColor colorWithRed:0.118 green:0.494 blue:1 alpha:1].CGColor;
    
}


- (IBAction)resetBtnFunction:(id)sender {
    emailTextField.text = @"";
    reserFlt = NO;
    [resetBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
}


//perform function on reset button pressed
- (IBAction)resetpwdFunct:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField.tag ==1)
    {
        reserFlt = NO;
    }
    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if(textField.tag == 1)
    {
        if([emailTextField.text length] > 0)
        {
            reserFlt =YES;
            [resetBtn setImage:[UIImage imageNamed:@"cancel_red.png"] forState:UIControlStateNormal];
        }
        else if([emailTextField.text length] == 0 )
        {
            reserFlt =NO;
            [resetBtn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
