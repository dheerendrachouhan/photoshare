//
//  EditMessageVC.m
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditMessageVC.h"
#import "ReferralStageFourVC.h"

@interface EditMessageVC ()

@end

@implementation EditMessageVC
@synthesize edittedMessage;

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
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Choose" style:UIBarButtonItemStyleDone target:self action:@selector(doneBtnPressed:)];
    self.navigationItem.rightBarButtonItem = backButton;
    
    [self.navigationItem setTitle:@"Edit Message"];
    [textMessage setDelegate:self];
    textMessage.text = edittedMessage;
    custumImageBackground.layer.cornerRadius = 5;
}
- (IBAction)doneBtnPressed:(id)sender {
    ReferralStageFourVC *rf = (ReferralStageFourVC *)[self.navigationController.viewControllers objectAtIndex:2];
    rf.stringStr = [NSString stringWithFormat:@"%@", textMessage.text];
    [self.navigationController popToViewController:rf animated:YES];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
