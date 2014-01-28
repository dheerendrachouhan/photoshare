//
//  ReferralStageFourVC.m
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "ReferralStageFourVC.h"
#import "EditMessageVC.h"
#import "ContentManager.h"
#import "FBTWViewController.h"

@interface ReferralStageFourVC ()

@end

@implementation ReferralStageFourVC
{
    NSString *userSelectedEmail;
    NSString *userSelectedPhone;
}
@synthesize stringStr;

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
    objManager = [ContentManager sharedManager];
    setterEdit = NO;
    [userMessage setEditable:NO];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setTitle:@"Refer Friends"];
    //Navigation Back Title
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    customImage.layer.cornerRadius = 5;
    
    //Filter
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    
    //hide done button
    
    if([stringStr length]==0)
    {
        userMessage.text = @"Hey I've been using 123 Friday to share photo and earn  money want to join me?";
    }
    else
    {
        userMessage.text = stringStr;
    }
    
    //Checking the screen size
    if([[UIScreen mainScreen] bounds].size.height == 480)
    {
        scrollView.contentSize =CGSizeMake(320,  self.view.frame.size.height);
        scrollView.autoresizingMask= UIViewAutoresizingFlexibleHeight;
        
    }

}


- (IBAction)editMsg_Btn:(id)sender {
    EditMessageVC *edMSG = [[EditMessageVC alloc] init];
    edMSG.edittedMessage = userMessage.text;
    [self.navigationController pushViewController:edMSG animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.stringStr length]==0)
    {
        userMessage.text = @"Hey I've been using 123 Friday to share photo and earn  money want to join me?";
    }
    else
    {
        userMessage.text = self.stringStr;
    }
}

//Filter Reference.
- (IBAction)fbFilter_Btn:(id)sender {
    fbFilter = YES;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
}

- (IBAction)twFilter_Btn:(id)sender {
    twFilter = YES;
    fbFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
}

- (IBAction)emailFilter_Btn:(id)sender {
    mailFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    smsFilter = NO;
    //[self mailTo];
    [self showContactListPicker];
}

- (IBAction)smsFilter_Btn:(id)sender {
    smsFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
}

//Social Message Sending
- (IBAction)postTofacebook:(id)sender {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *facebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [facebook setInitialText:userMessage.text];
        [facebook setCompletionHandler:^(SLComposeViewControllerResult result) {
            FBTWViewController *fb = [[FBTWViewController alloc] init];
            fb.successType = @"fb";
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [objManager showAlert:@"Cancelled" :@"Post Cancelled" :@"Ok" :nil];
                    break;
                case SLComposeViewControllerResultDone:
                    [self.navigationController pushViewController:fb animated:YES];
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:facebook animated:YES completion:Nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't post right now, make sure your device has an internet connection and you have at least one Facebook account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }

}

- (IBAction)postToTwitter:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:userMessage.text];
        [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            FBTWViewController *tw = [[FBTWViewController alloc] init];
            tw.successType = @"tw";
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [objManager showAlert:@"Cancelled" :@"Tweet Cancelled" :@"Ok" :nil];
                    break;
                case SLComposeViewControllerResultDone:
                    [self.navigationController pushViewController:tw animated:YES];
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
    }
}

//Email from Contacts
-(void) mailTo {

    // Email Subject
    NSString *emailTitle = @"Join 123 Friday";
    // Email Content
    NSString *messageBody = userMessage.text; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:userSelectedEmail];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:YES];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully refferd your friends" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [objManager showAlert:@"Cancelled" :@"Mail cancelled" :@"Ok" :nil];
            break;
        case MFMailComposeResultSaved:
            [objManager showAlert:@"Saved" :@"You mail is saved in draft" :@"Ok" :nil];
            break;
        case MFMailComposeResultSent:
            [alert show];
            
            break;
        case MFMailComposeResultFailed:
            [objManager showAlert:@"Mail sent failure" :[error localizedDescription]:@"Ok" :nil];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//Message to user
-(void)sendInAppSMS
{
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = userMessage.text;
		controller.recipients = [NSArray arrayWithObject:userSelectedPhone];
		controller.messageComposeDelegate = self;
		[self presentModalViewController:controller animated:YES];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully refferd your friends" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
	switch (result) {
		case MessageComposeResultCancelled:
			[objManager showAlert:@"Cancelled" :@"Message Composed Cancelled" :@"Ok" :nil];
			break;
		case MessageComposeResultFailed:
			[objManager showAlert:@"Failed" :@"Something went wrong!! Please try again" :@"Ok" :nil];
            break;
		case MessageComposeResultSent:
            [alert show];
			break;
		default:
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}

//Contact List
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self displayPerson:person];
    [self dismissModalViewControllerAnimated:YES];
    
    
    if(mailFilter)
    {
        if([userSelectedEmail length]==0)
        {
            [objManager showAlert:@"No Email" :@"No Email Found" :@"Ok" :nil];
        }
        else {
            [self mailTo];
        }
    }
    else if(smsFilter)
    {
        if([userSelectedPhone length]==0)
        {
            [objManager showAlert:@"No Phone" :@"Phone no not found" :@"Ok" :nil];
        }
        else {
            [self sendInAppSMS];
        }
    }
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

//Setting the contact List for Email
- (void)displayPerson:(ABRecordRef)person
{
    NSString *emailID = nil;
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    if(ABMultiValueGetCount(emails) >0)
    {
        emailID = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, 0);
         userSelectedEmail = emailID;
    } else {
         userSelectedEmail = emailID;
    }
    CFRelease(emails);
    NSLog(@"%@",userSelectedEmail);
   
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        userSelectedPhone = phone;
    } else {
        userSelectedPhone = phone;
    }
    CFRelease(phoneNumbers);
    NSLog(@"%@",userSelectedPhone);
    
}

-(void)showContactListPicker
{
    ABPeoplePickerNavigationController *picker =
    [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;

    [self presentModalViewController:picker animated:YES];
}

//alertView
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li",(long)buttonIndex);
    NSLog(@"The %@ button was tapped.", [alert buttonTitleAtIndex:buttonIndex]);
    if(buttonIndex == 1)
    {
        [self showContactListPicker];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
