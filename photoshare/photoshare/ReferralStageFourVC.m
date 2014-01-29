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
}
@synthesize stringStr;
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
    edMSG.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
    
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
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
    
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
    [self dismissModalViewControllerAnimated:YES];
    [self performSelector:@selector(mailTo) withObject:self afterDelay:1.0f];
    
}
- (void)facebookViewControllerCancelWasPressed:(id)sender {
    //[self fillTextBoxAndDismiss:@"<Cancelled>"];
    [objManager showAlert:@"Cancelled" msg:@"Friend selection process cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
    [self dismissModalViewControllerAnimated:YES];
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
    }];

}

-(void)getTwitterFriendsForAccount:(ACAccount*)account {
    // In this case I am creating a dictionary for the account
    // Add the account screen name
    NSLog(@"user-- %@",account.username);
    [self fetchTimelineForUser:account.username];
}

- (BOOL)userHasAccessToTwitter

{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
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
                            
                            NSString *stt= [friendsdata objectForKey:@"screen_name"];
                            
                            [twiiterListArr addObject:stt];
                            
                            //                            //  resultFollowersNameList = [[NSArray alloc]init];
                            //                            resultFollowersNameList = [friendsdata valueForKey:@"name"];
                            //                            NSLog(@"resultNameList value is %@", resultFollowersNameList);
                            
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
                            
                            
                            NSArray *sttt = [(NSDictionary *)TWData objectForKey:@"ids"];
                            
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

- (void)fetchTimelineForUser:(NSString *)username

{
    
    NSMutableDictionary *accountDictionary = [NSMutableDictionary mutableCopy];

    //  Step 0: Check that the user has local Twitter accounts
    
    if ([self userHasAccessToTwitter]) {
        
        
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        
        ACAccountType *twitterAccountType =
        
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         
         ACAccountTypeIdentifierTwitter];
        
        
        
        [self.accountStore
         
         requestAccessToAccountsWithType:twitterAccountType
         
         options:NULL
         
         completion:^(BOOL granted, NSError *error) {
             
             if (granted) {
                 
                 //  Step 2:  Create a request
                 
                 NSArray *twitterAccounts =
                 
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/friends/ids.json"];
                 
                 NSDictionary *params = @{@"screen_name" : username,
                                          
                                          @"include_rts" : @"0",
                                          
                                          @"trim_user" : @"1",
                                          
                                          @"count" : @"1"};
                 
                 SLRequest *request =
                 
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                  
                                    requestMethod:SLRequestMethodGET
                  
                                              URL:url
                  
                                       parameters:params];
                 
                 
                 
                 //  Attach an account to the request
                 
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 
                 
                 //  Step 3:  Execute the request
                 
                 [request performRequestWithHandler:
                  
                  ^(NSData *responseData,
                    
                    NSHTTPURLResponse *urlResponse,
                    
                    NSError *error) {
                      
                      
                      
                      if (responseData) {
                          
                          if (urlResponse.statusCode >= 200 &&
                              
                              urlResponse.statusCode < 300) {
                              
                              
                              NSError *jsonError;
                              
                              NSDictionary *timelineData =
                              
                              [NSJSONSerialization
                               
                               JSONObjectWithData:responseData
                               
                               options:NSJSONReadingAllowFragments error:&jsonError];
                              
                              if (timelineData) {
                                  
                                  NSLog(@"Timeline Response: %@\n", timelineData);
                                  
                                  [accountDictionary setObject:[timelineData objectForKey:@"ids"] forKey:@"friends_ids"];
                                  NSLog(@"%@", accountDictionary);
                                  
                              }
                              
                              else {
                                  
                                  // Our JSON deserialization went awry
                                  
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                                  
                              }
                              
                          }
                          
                          else {
                              
                              // The server did not respond ... were we rate-limited?
                              
                              NSLog(@"The response status code is %d",
                                    
                                    urlResponse.statusCode);
                              
                          }
                          
                      }
                      
                  }];
                 
             }
             
             else {
                 
                 // Access was not granted, or an error occurred
                 
                 NSLog(@"%@", [error localizedDescription]);
                 
             }
             
         }];
        
    }
    
}

//Twitter SDK Implemetation
- (IBAction)postToTwitter:(id)sender {
    [SVProgressHUD showWithStatus:@"Fetching Data" maskType:SVProgressHUDMaskTypeBlack];
    [self getTwitterAccounts];
    
    
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
        
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
     //stop loader
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
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
        else if(FBEmailID.count != 0)
        {
            [self targetForAction:@selector(postTofacebook:) withSender:nil];
            //setting the Email Nil
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
