//
//  PhotoShareController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PhotoShareController.h"
#import "NavigationBar.h"
#import "ContentManager.h"
#import "SVProgressHUD.h"

@interface PhotoShareController ()

@end

@implementation PhotoShareController
{
    NSString *userSelectedEmail;
    NSString *userSelectedPhone;
    NSMutableDictionary *firendDictionary;
    NSMutableArray *FBEmailID;
    NSMutableArray *twiiterListArr;
    int totalCount;
    int countVar;
    NSArray *sttt;
    NSString *tweetFail;
    BOOL grant;
    NSNumber *userID;
    WebserviceController *webSwevice;
    NSMutableArray *ImageCollection;
    NSString *messageStr;
    int imageCount;
    int imageLoaded;
    BOOL webServiceStart;
}
@synthesize sharedImage, sharedImagesArray, otherDetailArray;

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
    imageView.image = sharedImage;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
	grant = NO;
    
    messageStr= [NSString stringWithFormat:@"http://www.123friday.com/my123/live/toolkit/1/%@",[objManager getData:@"user_username"]];
    
    ImageCollection = [[NSMutableArray alloc] init];
    
    if(sharedImage== nil || sharedImage == NULL)
    {
        if (sharedImagesArray.count > 0)
        {
            webSwevice = [[WebserviceController alloc] init];
            webSwevice.delegate = self;
            imageCount = sharedImagesArray.count;
            imageLoaded = 0;
            for(int u=0;u<sharedImagesArray.count;u++)
            {
                NSDictionary *dicData = @{@"user_id":[otherDetailArray objectAtIndex:0],@"photo_id":[sharedImagesArray objectAtIndex:u],@"get_image":[otherDetailArray objectAtIndex:2],@"collection_id":[otherDetailArray objectAtIndex:1],@"image_resize":@"500"};
        
                [webSwevice call:dicData controller:@"photo" method:@"get"];
            }
            webServiceStart = YES;
            
        }
        else if(sharedImagesArray.count == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No photo to share" message:@"No photos are there to shared." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        
            [alert show];
        }
    }
    if(webServiceStart)
    {
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Attaching 1 of %d photos",imageCount] maskType:SVProgressHUDMaskTypeBlack];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
}


//This function is not used here
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"%@",data);
}
//////

//Protocol for getting images....
-(void)webserviceCallbackImage:(UIImage *)image
{
    [ImageCollection addObject:image];
    [SVProgressHUD dismissWithSuccess:@"Attached"];
    imageView.image = image;
    imageLoaded++;
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Attaching %d of %d photos",imageLoaded+1,imageCount] maskType:SVProgressHUDMaskTypeBlack];
    if(imageCount == imageLoaded)
    {
        [SVProgressHUD dismissWithSuccess:@"Photos Attached"];
        webServiceStart = NO;
    }
}

//Filter Reference.
- (IBAction)fbFilter_Btn:(id)sender {
    fbFilter = YES;
    twFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    [self postTofacebook];
}

- (IBAction)twFilter_Btn:(id)sender {
    twFilter = YES;
    fbFilter = NO;
    mailFilter = NO;
    smsFilter = NO;
    [self postToTwitter];
}

- (IBAction)emailFilter_Btn:(id)sender {
    mailFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    smsFilter = NO;
    [self showContactListPicker];
}

- (IBAction)smsFilter_Btn:(id)sender {
    smsFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    [self showContactListPicker];
}

//FaceBook SDK Implemetation
- (void)postTofacebook{
    
    [SVProgressHUD showWithStatus:@"Fetching Facebook Account" maskType:SVProgressHUDMaskTypeBlack];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        [SVProgressHUD dismissWithSuccess:@"Done"];
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:[NSString stringWithFormat:@"Take a look 123 Friday %@",messageStr]];
        
        if(sharedImage != NULL || sharedImage != nil)
        {
            [controller addImage:sharedImage];
        }
        if(sharedImagesArray.count > 0)
        {
            for(int i=0;i<sharedImagesArray.count;i++)
            {
                [controller addImage:[ImageCollection objectAtIndex:i]];
            }
        }
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [objManager showAlert:@"Post Cancelled" msg:@"Share photo on facebook cancelled." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    [self dismissModals];
                    break;
                case SLComposeViewControllerResultDone:
                    [objManager showAlert:@"Post Cancelled" msg:@"Your photo has been shared successfully." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        [SVProgressHUD dismissWithError:@"No Facebook Account Found"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook not Found" message:@"Your Facebook account in not configured. Please Configure your facebook account from settings." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}




//Twitter SDK Implemetation
- (void)postToTwitter {
    [SVProgressHUD showWithStatus:@"Fetching Twitter Account" maskType:SVProgressHUDMaskTypeBlack];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        [SVProgressHUD dismissWithSuccess:@"Done"];
        
        SLComposeViewController *tweetsheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [tweetsheet setInitialText:[NSString stringWithFormat:@"Join 123 Friday %@",messageStr]];
        
        if(sharedImage != NULL || sharedImage != nil)
        {
            [tweetsheet addImage:sharedImage];
        }
        if(sharedImagesArray.count > 0)
        {
            for(int j=0;j<sharedImagesArray.count;j++)
            {
                [tweetsheet addImage:[ImageCollection objectAtIndex:j]];
            }
        }
        [tweetsheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [objManager showAlert:@"Tweet Cancelled" msg:@"Share photo on facebook cancelled." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    [self dismissModals];
                    break;
                case SLComposeViewControllerResultDone:
                    [objManager showAlert:@"Tweet Succuessfully" msg:@"Your photo has been shared successfully." cancelBtnTitle:@"Ok" otherBtn:Nil];
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:tweetsheet animated:YES completion:Nil];
        
    }
    else{
        [SVProgressHUD dismissWithError:@"No Twitter Account Found"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter not Found" message:@"Your Twitter account in not configured. Please Configure your twitter account from settings." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//Email from Contacts
-(void)mailTo {
    
    // Email Subject
    NSString *emailTitle = @"Join 123 Friday";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"<a href=\"%@\">Join Now</a>",messageStr]; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:userSelectedEmail];
    
    MFMailComposeViewController *mfMail = [[MFMailComposeViewController alloc] init];
    mfMail.mailComposeDelegate = self;
    if(sharedImagesArray.count>0)
    {
        for(int k=0;k<sharedImagesArray.count;k++)
        {
            NSData *data = UIImagePNGRepresentation([ImageCollection objectAtIndex:k]);
            [mfMail addAttachmentData:data mimeType:@"image/png" fileName:[NSString stringWithFormat:@"Photo%d",k]];
        }
    }
    else
    {
        NSData *data = UIImagePNGRepresentation(sharedImage);
        [mfMail addAttachmentData:data mimeType:@"image/png" fileName:@""];
    }
    [mfMail setSubject:emailTitle];
    [mfMail setMessageBody:messageBody isHTML:YES];
    [mfMail setToRecipients:toRecipents];
    
    //stop loader
    
    // Present mail view controller on screen
    [self presentViewController:mfMail animated:YES completion:nil];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo has been shared successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [objManager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            break;
        case MFMailComposeResultSaved:
            [objManager showAlert:@"Saved" msg:@"You mail is saved in draft" cancelBtnTitle:@"Ok" otherBtn:nil];
            [self sendToServer];
            break;
        case MFMailComposeResultSent:
            [alert show];
            break;
        case MFMailComposeResultFailed:
            [objManager showAlert:@"Mail sent failure" msg:[error localizedDescription] cancelBtnTitle:@"Ok" otherBtn:nil];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissModals];
}

//Message to user
-(void)sendInAppSMS
{
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = [@"Join 123 Friday, " stringByAppendingString:messageStr];
		controller.recipients = [NSArray arrayWithObject:userSelectedPhone];
        
        if (sharedImagesArray.count > 0) {
            for(int l=0;l<sharedImagesArray.count;l++)
            {
                NSData *data = UIImagePNGRepresentation([ImageCollection objectAtIndex:l]);
                [controller addAttachmentData:data typeIdentifier:(NSString *)kUTTypePNG filename:[NSString stringWithFormat:@"image%d.png",l]];
            }
        }
        else
        {
            NSData *data = UIImagePNGRepresentation(sharedImage);
            [controller addAttachmentData:data typeIdentifier:(NSString *)kUTTypePNG filename:@"image.png"];
		}
        
        controller.messageComposeDelegate = self;
		[self presentViewController:controller animated:YES completion:nil];
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo has been shared successfully." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
	switch (result) {
		case MessageComposeResultCancelled:
			[objManager showAlert:@"Cancelled" msg:@"Message Composed Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
			break;
		case MessageComposeResultFailed:
			[objManager showAlert:@"Failed" msg:@"Something went wrong!! Please try again" cancelBtnTitle:@"Ok" otherBtn:nil];
            break;
		case MessageComposeResultSent:
            [alert show];
			break;
		default:
			break;
	}
    
	[self dismissModals];
}

//Contact List
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModals];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self displayPerson:person];
    [self dismissModals];
    
    
    if(mailFilter)
    {
        if([userSelectedEmail length]==0)
        {
            [objManager showAlert:@"NO Email" msg:@"No Email Found" cancelBtnTitle:@"Ok" otherBtn:nil];
        }
        else {
            [self mailTo];
        }
    }
    else if(smsFilter)
    {
        if([userSelectedPhone length]==0)
        {
            [objManager showAlert:@"No Phone" msg:@"Phone no not found" cancelBtnTitle:@"Ok" otherBtn:nil];
        }
        else {
            [self sendInAppSMS];
        }
    }
    return YES;
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
    
    [self presentViewController:picker animated:YES completion:nil];
}

//alertView
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li",(long)buttonIndex);
    NSLog(@"The %@ button was tapped.", [alert buttonTitleAtIndex:buttonIndex]);
    if(buttonIndex == 1)
    {
        if((userSelectedEmail.length != 0) || (userSelectedPhone.length != 0))
        {
            [self showContactListPicker];
        }
    }
}

//dismiss models
-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 78)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
    // navnBar.backgroundColor = [UIColor redColor];
    
    UILabel *photoTitleLBL=[[UILabel alloc] initWithFrame:CGRectMake(85, 50, 150, 30)];
    photoTitleLBL.text=@"Share Your Photo";
    photoTitleLBL.textAlignment=NSTextAlignmentCenter;
    [navnBar addSubview:photoTitleLBL];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];

}

-(void)sendToServer
{
    webSwevice = [[WebserviceController alloc] init];
    webSwevice.delegate = self;
    for(int u=0;u<sharedImagesArray.count;u++)
    {
        NSDictionary *dictData = @{@"user_id":[otherDetailArray objectAtIndex:0],@"email_addresses":@"",@"message_title":@"Join 123 Friday",@"collection_id":[otherDetailArray objectAtIndex:1],@"photo_id":[sharedImagesArray objectAtIndex:u]};
    
        [webSwevice call:dictData controller:@"broadcast" method:@"endphotoemail"];
    }
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
