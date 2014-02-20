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
#import "AppDelegate.h"
#import "NavigationBar.h"
#import "MailMessageTable.h"

@interface ReferralStageFourVC ()

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
    NSNumber *userID;
    NSMutableArray *contactSelectedArray;  //need to be removed
    NSMutableArray *contactNoSelectedArray; // need to be removed
    NSMutableDictionary *contactData;
    int messagecount;
    int mailSent;
}
@synthesize stringStr,twitterTweet,toolkitLink;
@synthesize referEmailStr,referPhoneStr,referredValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    dmc = [[DataMapperController alloc] init];
    objManager = [ContentManager sharedManager];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ReferralStageFourVC_iPad" owner:self options:nil];
    }
    mailSent = 0;
    messagecount = 0;
    grant = NO;
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    tweetFail =@"";
    _accountStore = [[ACAccountStore alloc] init];
    twiiterListArr = [[NSMutableArray alloc] init];
    firendDictionary = [[NSMutableDictionary alloc] init]; //fabfriendDictionary
    FBEmailID = [[NSMutableArray alloc] init]; //storing email id of fb selected user
    contactSelectedArray = [[NSMutableArray alloc] init];
    contactNoSelectedArray = [[NSMutableArray alloc] init];
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
        userMessage.text = @"Hey, I've been using 123 Friday to share photos and earn money want to join me?";
    }
    else
    {
        userMessage.text = stringStr;
    }
    
    //Checking the screen size
    
    countVar =0;
}


- (IBAction)editMsg_Btn:(id)sender {
    EditMessageVC *edMSG = [[EditMessageVC alloc] init];
    edMSG.edittedMessage = userMessage.text;
    [self.navigationController pushViewController:edMSG animated:YES];
    
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
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select Email-Id from Contacts", @"Manually input Email", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}

- (IBAction)smsFilter_Btn:(id)sender {
    smsFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select from Contacts", @"Manually enter contact", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self ContactSelectorMethod];
            break;
        case 1:
            [self actionsheetCheeker];
            break;
        case 2:
            NSLog(@"Cancelled");
            break;
    }
}

-(void)actionsheetCheeker
{
    if(mailFilter)
    {
        [self mailTo];
    }
    else if(smsFilter)
    {
        [self sendInAppSMS_referral];
    }
}

//FaceBook SDK Implemetation
- (IBAction)postTofacebook:(id)sender {

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        UIAlertView *alC = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Post Cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        FBTWViewController *fb = [[FBTWViewController alloc] init];
        fb.successType = @"fb";
        
        [controller setInitialText:[NSString stringWithFormat:@"Take a look 123 Friday %@",toolkitLink]];
        
        [controller addImage:[UIImage imageNamed:@"123-mobile-logo.png"]];
        
        [controller setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    [alC show];
                    [self dismissModals];
                    break;
                case SLComposeViewControllerResultDone:
                    [self.navigationController pushViewController:fb animated:YES];
                    break;
                    
                default:
                    break;
            }
        }];
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook not Found" message:@"Your Facebook account in not configured. Please Configure your facebook account from settings." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getTwitterAccounts {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //Check if user Exists
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    
    for (ACAccount *account in accountsArray ) {
        NSLog(@"Account name: %@", account.username);
    }
    NSLog(@"Accounts array: %d", accountsArray.count);
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        grant = granted;
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.identifier);
                [self getTwitterFriendsIDListForThisAccount:twitterAccount.username];
                [SVProgressHUD showWithStatus:@"Fetching Data" maskType:SVProgressHUDMaskTypeBlack];
            }
        }
    }];
    
    if([accountsArray count] == 0)
    {
        [self disMissProgress];
        UIAlertView *twAl = [[UIAlertView alloc] initWithTitle:@"Twitter Account Not Found/ Twitter Account not Granted" message:@"Please sign-in your twitter account from your ios setting and run the app again. Grant permission to access this app. If twitter table loaded ignore this message." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [twAl show];
    }

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
                            if(totalCount == 0)
                            {
                                [SVProgressHUD dismissWithError:@"No Twitter ID's Found"];
                                [objManager showAlert:@"Alert" msg:@"No Twitter ID Found or There are zero Follower in your Twitter account" cancelBtnTitle:@"Ok" otherBtn:nil];
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
    
    [self composedMailMessage];
    referredValue = @"";
    // Email Subject
    NSString *emailTitle = @"Join 123 Friday";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat:@"%@ <a href=\"%@\">Join Now</a>",userMessage.text,toolkitLink]; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithArray:contactSelectedArray];
        
    MFMailComposeViewController *mfMail = [[MFMailComposeViewController alloc] init];
    mfMail.mailComposeDelegate = self;
    
    [mfMail setSubject:emailTitle];
    [mfMail setMessageBody:messageBody isHTML:YES];
    [mfMail setToRecipients:toRecipents];
    
     //stop loader
    
    // Present mail view controller on screen
    [[self navigationController] presentViewController:mfMail animated:YES completion:nil];
    
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
    
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [objManager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        case MFMailComposeResultSaved:
            [objManager showAlert:@"Saved" msg:@"You mail is saved in draft" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        case MFMailComposeResultSent:
            [alert show];
            [self mailToServer];
            break;
        case MFMailComposeResultFailed:
            [objManager showAlert:@"Mail sent failure" msg:[error localizedDescription] cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactSelectedArray removeAllObjects];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissModals];
}

//Message to user
-(void)sendInAppSMS_referral
{
    [self composedMailMessage];
    referredValue = @"";
    
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = [NSString stringWithFormat:@"%@ %@",userMessage.text,toolkitLink];
        controller.recipients = contactNoSelectedArray;
        controller.messageComposeDelegate = self;
        [[self navigationController] presentViewController:controller animated:NO completion:nil];
	}
    
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
	switch (result) {
		case MessageComposeResultCancelled:
			[objManager showAlert:@"Cancelled" msg:@"Message Composed Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactNoSelectedArray removeAllObjects];
			break;
		case MessageComposeResultFailed:
			[objManager showAlert:@"Failed" msg:@"Something went wrong!! Please try again" cancelBtnTitle:@"Ok" otherBtn:nil];
            [contactNoSelectedArray removeAllObjects];
            userSelectedPhone = @"";
            break;
		case MessageComposeResultSent:
                [alert show];
                [contactNoSelectedArray removeAllObjects];
			break;
		default:
			break;
	}
    
	[self dismissModals];
}

-(void)composedMailMessage
{
    [SVProgressHUD dismissWithSuccess:@"Composed"];
}


-(void)ContactSelectorMethod
{
    CFErrorRef error = NULL;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (granted)
            {
                [self loadContacts];
            }
    });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        [self loadContacts];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"You have denied to load contact for this app" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
       
        [alert show];
    }
}

-(void)loadContacts
{
    CFErrorRef error = NULL;
    
    contactData = [[NSMutableDictionary alloc] init];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil)
    {
        NSLog(@"Succesful.");
        
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString
                                   *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString
                                   *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            if(firstName.length == 0)
            {
                firstName = @"";
            }
            else if(lastName.length == 0)
            {
                lastName = @"";
            }
            NSString *fullName = [NSString stringWithFormat:@"%@ %@",
                                  firstName, lastName];
            if(fullName.length<=1)
            {
                fullName=@"";
            }
            NSLog(@"Full Name: %@",fullName);
            
            NSString *concatStr = @"";
            //email
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSUInteger j = 0;
            for (j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                if(concatStr.length == 0)
                {
                    concatStr = email;
                }
                else
                {
                    concatStr = [NSString stringWithFormat:@"%@,%@",concatStr,email];
                }
            }
            
            NSString *concatStr2 = @"";
            
            ABMutableMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            NSUInteger k = 0;
            for(k = 0;k< ABMultiValueGetCount(phones); k++)
            {
                NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phones, k);
                if(concatStr2.length == 0)
                {
                    concatStr2 = phone;
                }
                else
                {
                    concatStr2 = [NSString stringWithFormat:@"%@ , %@",concatStr2,phone];
                }
            }
            
            //NSdictionary add
            NSDictionary *dict = @{@"name":fullName,@"email":concatStr,@"phone":concatStr2};
            
            [contactData setObject:dict forKey:[NSString stringWithFormat:@"%d",i]];
        }
    }
    CFRelease(addressBook);
    
    //forwarding to controller
    if(mailFilter)
    {
        MailMessageTable *mmVC;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable_iPad" bundle:nil];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable" bundle:nil];
        }
        mmVC.contactDictionary = contactData;
        mmVC.filterType = @"Refer Mail";
        
        [self.navigationController pushViewController:mmVC animated:YES];
       /// [contactData removeAllObjects];
    }
    else if (smsFilter)
    {
        
        MailMessageTable *mmVC;
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable_iPad" bundle:nil];
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            mmVC = [[MailMessageTable alloc] initWithNibName:@"MailMessageTable" bundle:nil];
        }
        mmVC.contactDictionary = contactData;
        mmVC.filterType = @"Refer Text";
        
        [self.navigationController pushViewController:mmVC animated:YES];
        //[contactData removeAllObjects];
    }
}

//alertView
-(void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%li",(long)buttonIndex);
    NSLog(@"The %@ button was tapped.", [alert buttonTitleAtIndex:buttonIndex]);
    if(buttonIndex == 1)
    {
        if(mailFilter)
        {
            [self ContactSelectorMethod];
        }
        else if(smsFilter)
        {
            [self ContactSelectorMethod];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
    
    if([self.stringStr length]==0)
    {
        userMessage.text = @"Hey, I've been using 123 Friday to share photos and earn money want to join me?";
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
            [tweetSheet setInitialText:[NSString  stringWithFormat:@"%@ Join 123 Friday %@",twitterTweet,toolkitLink]];
            [tweetSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
                
                FBTWViewController *tw = [[FBTWViewController alloc] init];
                tw.successType = @"tw";
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        [objManager showAlert:@"Cancelled" msg:@"Tweet Cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
                        [self dismissModals];
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

    if([referredValue isEqualToString:@"Refer Mail"])
    {
        userSelectedEmail = referEmailStr;
        NSArray *arr = [referEmailStr componentsSeparatedByString:@","];
        contactSelectedArray = [NSMutableArray arrayWithArray:arr];
        mailFilter = YES;
        NSString *objFirst = [arr objectAtIndex:0];
        if(objFirst.length == 0)
        {
            [objManager showAlert:@"No Contact" msg:@"No contact available to mail" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Composing Mail" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(mailTo) withObject:self afterDelay:3.0];
        }
    }
    else if ([referredValue isEqualToString:@"Refer Text"])
    {
        userSelectedPhone = referPhoneStr;
        NSArray *arr = [referPhoneStr componentsSeparatedByString:@", "];
        contactNoSelectedArray = [NSMutableArray arrayWithArray:arr];
        smsFilter = YES;
        NSString *objFirst = [arr objectAtIndex:0];
        if(objFirst.length == 0)
        {
            [objManager showAlert:@"No Contact" msg:@"No contact available for text" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Composing Message" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(sendInAppSMS_referral) withObject:self afterDelay:5.0f];
        }
    }

}


//dismiss models
-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

//API calling
-(void)mailToServer
{
    if(contactSelectedArray.count !=0)
    {
        WebserviceController *wbh = [[WebserviceController alloc] init];
        wbh.delegate = self;
        for(int s=0;s<contactSelectedArray.count;s++)
        {
            NSDictionary *dictData = @{@"user_id":userID, @"email_addresses":[contactSelectedArray objectAtIndex:s]};
            [wbh call:dictData controller:@"referral" method:@"store"]  ;
        }
        [SVProgressHUD showWithStatus:@"Sending Mail" maskType:SVProgressHUDMaskTypeBlack];
    }
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    UILabel *navTitle = [[UILabel alloc] init];
    if([objManager isiPad])
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 768, 150)];
        navTitle.frame = CGRectMake(280, NavBtnYPosForiPad, 250, NavBtnHeightForiPad);
        navTitle.font = [UIFont systemFontOfSize:36.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 100.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:29.0f];
    }
    else
    {
        navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 75)];
        navTitle.frame = CGRectMake(110, NavBtnYPosForiPhone, 120, NavBtnHeightForiPhone);
        navTitle.font = [UIFont systemFontOfSize:18.0f];
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    
    navTitle.text = @"Refer Friends";
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];

    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"WebService Data -- %@",data);
    NSNumber *numb = [data objectForKey:@"exit_code"];
    mailSent++;
    if(contactSelectedArray.count == mailSent)
    {
        if([numb integerValue]==0)
        {
            [SVProgressHUD dismissWithSuccess:@"Emailaddress is not a valid email address"];
            mailSent = 0;
        }
        else
        {
            [SVProgressHUD dismissWithSuccess:@"Mail sent"];
            mailSent = 0;
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
