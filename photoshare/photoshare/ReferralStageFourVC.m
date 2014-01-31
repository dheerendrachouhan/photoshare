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
#import "SVProgressHUD.h"
#import "TwitterTable.h"

@interface ReferralStageFourVC ()

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation ReferralStageFourVC
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
}
@synthesize stringStr,twitterTweet;
@synthesize friendPickerController = _friendPickerController;

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
    
    tweetFail =@"";
    _accountStore = [[ACAccountStore alloc] init];
    twiiterListArr = [[NSMutableArray alloc] init];
    firendDictionary = [[NSMutableDictionary alloc] init]; //fabfriendDictionary
    FBEmailID = [[NSMutableArray alloc] init]; //storing email id of fb selected user
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
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if ([[UIScreen mainScreen] bounds].size.height == 568)
        {
            [[NSBundle mainBundle] loadNibNamed:@"ReferralStageFourVC" owner:self options:nil];
        }
        else if([[UIScreen mainScreen] bounds].size.height == 480)
        {
            [[NSBundle mainBundle] loadNibNamed:@"ReferrelStageFourVC3" owner:self options:nil];
        }
    }

    countVar =0;
}


- (IBAction)editMsg_Btn:(id)sender {
    EditMessageVC *edMSG = [[EditMessageVC alloc] init];
    edMSG.edittedMessage = userMessage.text;
    [self.navigationController pushViewController:edMSG animated:YES];
    edMSG.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
    
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
- (IBAction)postTofacebook:(id)sender {
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen)
    {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:Nil allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
         {
            if (error)
            {
                [objManager showAlert:@"Error" msg:error.localizedDescription cancelBtnTitle:@"Ok" otherBtn:nil];
            } else if (session.isOpen)
            {
                [self postTofacebook:sender];
            }
        }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self.navigationController pushViewController:self.friendPickerController animated:YES];
    self.friendPickerController.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 85);
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    // we pick up the users from the selection, and create a string that we use to update the text view
    // at the bottom of the display; note that self.selection is a property inherited from our base class
    
    [SVProgressHUD showWithStatus:@"Composing Mail" maskType:SVProgressHUDMaskTypeBlack];
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSString *text = user.id;
        
        //inserting user id in graph api to pull username
        NSString *urlStrings = [NSString stringWithFormat:@"http://graph.facebook.com/%@?fields=username",text];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStrings] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
        [request setHTTPMethod: @"GET"];
        NSError *requestError;
        NSURLResponse *urlResponse = nil;
        NSData *response1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
        NSDictionary *jsonObject=[NSJSONSerialization JSONObjectWithData:response1 options:NSJSONReadingMutableLeaves error:nil];
        
        if(![jsonObject objectForKey:@"username"])
        {
            NSLog(@"username found null!");
        }
        else
        {
            NSString *fbMsgLink = [NSString stringWithFormat:@"%@@facebook.com",[jsonObject objectForKey:@"username"]];
            NSLog(@"fb user link : %@",fbMsgLink);
            //adding the fb msg links to array
            [FBEmailID addObject:fbMsgLink];
            
        }
    }
    [SVProgressHUD dismissWithSuccess:@"Done"];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    //[self fillTextBoxAndDismiss:@"<Cancelled>"];
    [objManager showAlert:@"Cancelled" msg:@"Friend selection process cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getTwitterAccounts {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.identifier);
                [self getTwitterFriendsIDListForThisAccount:twitterAccount.username];
            }
        }
        if(!granted){
            [self disMissProgress];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twiiter not Found" message:@"Your Tweeter account in not configured. Please Configure your twitter account from settings." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            tweetFail = @"Failed";
            [alert show];
        }
    }];

}

-(void) getFollowerNameFromID:(NSString *)ID{
    
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                // Creating a request to get the info about a user on Twitter
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",ID] forKey:@"user_id"]];
                
                [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            
                            NSError *error = nil;
                            
                            NSDictionary *friendsdata = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            NSLog(@"friendsdata value is %@", friendsdata);
                            
                            NSString *stt= [@"@" stringByAppendingString:[friendsdata objectForKey:@"screen_name"]];
                            
                            [twiiterListArr addObject:stt];
                            
                           
                            if(totalCount > countVar)
                            {
                                countVar++;
                            }
                        }
                        
                        if(totalCount == countVar)
                        {
                            [self disMissProgress];
                            TwitterTable *tw = [[TwitterTable alloc] init];
                            tw.tweetUserName = [NSMutableArray arrayWithArray:twiiterListArr];
                            [self.navigationController pushViewController:tw animated:NO];
                            tw.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
                            totalCount = 0;
                            countVar = 0;
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

-(void) getTwitterFriendsIDListForThisAccount:(NSString *)myAccount{
    
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
            
                // Creating a request to get the info about a user on Twitter
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1/friends/ids.json"] parameters:[NSDictionary dictionaryWithObject:myAccount forKey:@"screen_name"]];
                
                [twitterInfoRequest setAccount:twitterAccount];
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                            
                            sttt = [(NSDictionary *)TWData objectForKey:@"ids"];
                            totalCount =[sttt count];
                            
                            for(int i=0;i<[sttt count];i++)
                            {
                                NSLog(@"data== %@ ID = %@",TWData, [sttt objectAtIndex:i]);
                                [self getFollowerNameFromID:[sttt objectAtIndex:i]];
                            }
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}



//Twitter SDK Implemetation
- (IBAction)postToTwitter:(id)sender {
    [SVProgressHUD showWithStatus:@"Fetching Data" maskType:SVProgressHUDMaskTypeBlack];
    [self getTwitterAccounts];
}

-(void)disMissProgress
{
    [SVProgressHUD dismissWithSuccess:@"Done"];
}

//Email from Contacts
-(void)mailTo {
    
    // Email Subject
    NSString *emailTitle = @"Join 123 Friday";
    // Email Content
    NSString *messageBody = userMessage.text; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [[NSArray alloc] init];
    if(userSelectedEmail.length !=0)
    {
        toRecipents = [NSArray arrayWithObject:userSelectedEmail];
    }
    else if(FBEmailID.count!=0)
    {
        toRecipents = [NSArray arrayWithArray:FBEmailID];
    }
        
    MFMailComposeViewController *mfMail = [[MFMailComposeViewController alloc] init];
    mfMail.mailComposeDelegate = self;
    [mfMail setSubject:emailTitle];
    [mfMail setMessageBody:messageBody isHTML:NO];
    [mfMail setToRecipients:toRecipents];
    
     //stop loader
    
    // Present mail view controller on screen
    [self presentModalViewController:mfMail animated:YES];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully refferd your friends" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [objManager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            break;
        case MFMailComposeResultSaved:
            [objManager showAlert:@"Saved" msg:@"You mail is saved in draft" cancelBtnTitle:@"Ok" otherBtn:nil];
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
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [FBEmailID removeAllObjects];
    
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
    [self presentModalViewController:picker animated:YES];
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
    
    if(twitterTweet.length != 0)
    {
        [SVProgressHUD dismissWithSuccess:@"Done"];
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[NSString  stringWithFormat:@"%@ %@",twitterTweet,userMessage.text]];
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                
                FBTWViewController *tw = [[FBTWViewController alloc] init];
                tw.successType = @"tw";
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        [objManager showAlert:@"Cancelled" msg:@"Tweet Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
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
        twitterTweet = @"";
    }
}

//dismiss models
-(void)dismissModals
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
