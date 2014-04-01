//
//  ReferralStageFourVC.m
//  photoshare
//
//  Created by ignis3 on 27/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "ReferralStageFourVC.h"
#import "ContentManager.h"
#import "FBTWViewController.h"
#import "SVProgressHUD.h"
#import "TwitterTable.h"
#import "AppDelegate.h"
#import "MailMessageTable.h"
#import <FacebookSDK/FacebookSDK.h>
@interface ReferralStageFourVC ()


@end

@implementation ReferralStageFourVC
{
    NSString *userSelectedEmail;
    NSString *userSelectedPhone;
    NSMutableDictionary *firendDictionary;
    NSMutableArray *FBEmailID;
    NSMutableArray *twiiterListArr;
    NSArray *sttt;
    NSString *tweetFail;
    NSNumber *userID;
    NSMutableArray *contactSelectedArray;  //need to be removed
    NSMutableArray *contactNoSelectedArray; // need to be removed
    NSMutableDictionary *contactData;
    int totalCount;
    int countVar;
    int messagecount;
    int mailSent;
    BOOL grant;
    //For Twitter Account
    ACAccountStore *accountStore;
    ACAccountType *accountType;
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
    _emailContacts.delegate = self;
    _emailMessageBody.delegate = self;
    emailView.hidden = YES;
    emailView.layer.borderColor = [UIColor blackColor].CGColor;
    emailView.layer.borderWidth = 2.0f;
    mailSent = 0;
    messagecount = 0;
    grant = NO;
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
    //For twitter Accounts
    tweetFail =@"";
    accountStore = [[ACAccountStore alloc] init];
    accountType=[accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    twiiterListArr = [[NSMutableArray alloc] init];
    firendDictionary = [[NSMutableDictionary alloc] init]; //fabfriendDictionary
    FBEmailID = [[NSMutableArray alloc] init]; //storing email id of fb selected user
    contactSelectedArray = [[NSMutableArray alloc] init];
    contactNoSelectedArray = [[NSMutableArray alloc] init];
    setterEdit = NO;
    
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
    
        //Checking the screen size
    
    countVar =0;
    [userMessage setDelegate:self];
    
    [self addCustomNavigationBar];
    
    //Add TAp Gesture to the self view for End Editing
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.view addGestureRecognizer:tapGesture];
}
-(void)endEditing
{
    [self.view endEditing:YES];
    [self resetTheScrollviewContent];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];   
    
    if(twitterTweet.length != 0)
    {
        if([twitterTweet isEqualToString:@"(null)"])
        {
            twitterTweet=@"";
        }
        [SVProgressHUD dismissWithSuccess:@"Done"];
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[NSString stringWithFormat:@"%@ I’ve just joined 123friday this is my video, %@",twitterTweet,toolkitLink]];
            [tweetSheet addImage:[UIImage imageNamed:@"login-logo-log.png"]];
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
            
            [SVProgressHUD showWithStatus:@"Composing Message" maskType:SVProgressHUDMaskTypeBlack];
            [self performSelector:@selector(mailToFun) withObject:self afterDelay:0.0f];
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
    
    [self detectDeviceOrientation];
}
#pragma mark - TExtView Methods
//for text view
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    isUserMessageEditing=YES;
    [self setScrollviewContentForTextView];
}

-(void)setScrollviewContentForTextView
{
    if(UIDeviceOrientationIsPortrait(self.interfaceOrientation))
    {
        [scrollView setContentOffset:CGPointMake(0,100) animated:YES];
    }
    else
    {
        if([UIScreen mainScreen].bounds.size.height==480)
        {
            [scrollView setContentOffset:CGPointMake(0,150) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,250) animated:YES];
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.stringStr=userMessage.text;
     NSLog(@"User Message : %@",self.stringStr);
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self resetTheScrollviewContent];
        return NO;
    }
    
    return YES;
}
-(void)resetTheScrollviewContent
{
    [scrollView setContentOffset:CGPointMake(0,-15) animated:YES];
    self.stringStr=userMessage.text;
    if(self.stringStr.length==0)
    {
        [self hideTheUserMessageEditTextView];
    }
    NSLog(@"User Message : %@",self.stringStr);
    isUserMessageEditing=NO;
}
- (IBAction)editMsg_Btn:(id)sender {
    
    [self showTheUserMessageEditTextView];
    
}
-(void)showTheUserMessageEditTextView
{
    [userMessage becomeFirstResponder];
    editMessageTitleLbl.hidden=YES;
    editMessageBtn.hidden=YES;
    userMessage.hidden=NO;
}
-(void)hideTheUserMessageEditTextView
{
    [userMessage resignFirstResponder];
    editMessageTitleLbl.hidden=NO;
    editMessageBtn.hidden=NO;
    userMessage.text=@"";
    userMessage.hidden=YES;
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
    self.stringStr=userMessage.text;
     NSLog(@"User Message : %@",self.stringStr);
    mailFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    smsFilter = NO;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select email from Contacts", @"Manually enter email", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (IBAction)smsFilter_Btn:(id)sender {
    self.stringStr=userMessage.text;
    NSLog(@"User Message : %@",self.stringStr);
    smsFilter = YES;
    fbFilter = NO;
    twFilter = NO;
    mailFilter = NO;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Select from Contacts", @"Manually enter contact", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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
        [self mailToFun];
    }
    else if(smsFilter)
    {
        [self sendInAppSMS_referral];
    }
}


#pragma mark - FaceBook Methods
// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    // If the user is logged in, they can post to Facebook using API calls, so we show the buttons
    [_FacebookShareLinkWithAPICallsButton setHidden:NO];
    //[_StatusUpdateWithAPICallsButton setHidden:NO];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // If the user is NOT logged in, they can't post to Facebook using API calls, so we show the buttons
    [_FacebookShareLinkWithAPICallsButton setHidden:YES];
    //[_StatusUpdateWithAPICallsButton setHidden:YES];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

//FaceBook SDK Implemetation
- (IBAction)postTofacebook:(id)sender {

    // FALLBACK: publish just a link using the Feed dialog
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    params.link = [NSURL URLWithString:toolkitLink];
    params.name = @"I’ve just joined 123friday this is my video";
    params.caption = @"  ";
    params.description = @" ";
    params.picture=[NSURL URLWithString:@"http://my.123friday.com/img/logo.png"];
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params])
    {
        // Present share dialog
        [FBDialogs presentShareDialogWithLink:params.link name:params.name
         caption:params.caption description:params.description picture:params.picture clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error)
        {
         if(error)
         {
             // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"Error publishing story: %@", error.description);
         }
         else
         {
             // Success
             NSLog(@"result %@", results);
         }
        }];
    }
    else
    {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"I’ve just joined 123friday this is my video", @"name",@"  ", @"caption",@" ", @"description",toolkitLink, @"link",@"http://my.123friday.com/img/logo.png",@"picture",nil];
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params
    handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
    {
        if (error)
        {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors NSLog(@"Error publishing story: %@", error.description);
        }
        else
        {
            if (result == FBWebDialogResultDialogNotCompleted)
            {  // User canceled.
                NSLog(@"User cancelled.");
            }
            else
            {
                // Handle the publish feed callback
                NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                if (![urlParams valueForKey:@"post_id"])
                {
                    // User canceled.
                    UIAlertView *alC = [[UIAlertView alloc] initWithTitle:@"Facebook" message:@"Post Cancelled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alC show];
                    NSLog(@"User cancelled.");
                }
                else
                {
                    // User clicked the Share button
                    NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                    FBTWViewController *fb = [[FBTWViewController alloc] init];
                    fb.successType = @"fb";
                    [self.navigationController pushViewController:fb animated:YES];                    NSLog(@"result %@", result);
                }
            }
        }
    }];
    }
}
#pragma mark - Twitter Account Methods

//Twitter SDK Implemetation
- (IBAction)postToTwitter:(id)sender {
    self.stringStr=userMessage.text;
    [SVProgressHUD showWithStatus:@"Fetching Data" maskType:SVProgressHUDMaskTypeBlack];
    //Get Twitter Accounts
    [self getTwitterAccounts];
}
-(void)getTwitterAccounts {
    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        grant = granted;
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                NSLog(@"%@",twitterAccount.username);
                NSLog(@"%@",twitterAccount.identifier);
                [self performSelectorInBackground:@selector(getTwitterFriendsIDListForThisAccount:) withObject:twitterAccount.username];
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
-(void) getTwitterFriendsIDListForThisAccount:(NSString *)myAccount{
           if (grant) {
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
                            [twiiterListArr removeAllObjects];
                            /*for(int i=0;i<[sttt count];i++)
                            {
                                NSLog(@"data== %@ ID = %@",TWData, [sttt objectAtIndex:i]);
                                [self getFollowerNameFromID:[sttt objectAtIndex:i]];
                            }*/
                            
                            if(totalCount == 0)
                            {
                                [SVProgressHUD dismissWithError:@"No Twitter ID's Found"];
                                [objManager showAlert:@"Alert" msg:@"No Twitter ID Found or There are zero Follower in your Twitter account" cancelBtnTitle:@"Ok" otherBtn:nil];
                            }
                            [self goToTwittertable];
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
}

-(void)getFollowerNameFromID:(NSString *)ID{
    
    // Request access to the Twitter account
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
                            [SVProgressHUD dismissWithError:@"Rate limit reached"];
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
-(void)goToTwittertable
{
    TwitterTable *tw = [[TwitterTable alloc] init];
    tw.tweetUserIDsArray = [NSMutableArray arrayWithArray:sttt];
    tw.accountStore=accountStore;
    tw.accountType=accountType;
    [self.navigationController pushViewController:tw animated:NO];
    tw.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
    totalCount = 0;
    countVar = 0;
}

#pragma mark - Mail Functions
-(void)disMissProgress
{
    [SVProgressHUD dismissWithSuccess:@"Done"];
}


//Email from Contacts
-(void)mailToFun {
    
    self.stringStr=userMessage.text;
    [self composedMailMessage];
    referredValue = @"";
    // Email Subject
    NSString *emailTitle = @"Check This Out!";
    // Email Content
    NSString *message=self.stringStr;
    if(message==NULL || message.length==0)
    {
        message=@"";
    }
    else
    {
        message=[NSString stringWithFormat:@"%@.",message];
    }
    
    NSString *messageBody = [NSString stringWithFormat:@"%@ <a href=%@>I’ve just joined 123friday this is my video.</a>",message,toolkitLink]; // Change the message body to HTML
    // To address
    NSArray *toRecipents = [NSArray arrayWithArray:contactSelectedArray];
        
    MFMailComposeViewController *mfMail = [[MFMailComposeViewController alloc] init];
    mfMail.mailComposeDelegate = self;
    
    [mfMail setSubject:emailTitle];
    [mfMail setMessageBody:messageBody isHTML:YES];
    [mfMail setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [[self navigationController] presentViewController:mfMail animated:YES completion:nil];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
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
#pragma mark - Message Methods
-(void)sendInAppSMS_referral
{
    [self composedMailMessage];
    referredValue = @"";
    
    NSString *message=self.stringStr;
    if(message==NULL || message.length==0)
    {
        message=@"";
    }
    else
    {
        message=[NSString stringWithFormat:@"%@.",message];
    }
    
    NSString *msgBody=[NSString stringWithFormat:@"%@I’ve just joined 123friday this is my video, %@.",message,toolkitLink];
    msgBody = [msgBody stringByTrimmingCharactersInSet:                               [NSCharacterSet whitespaceCharacterSet]];
    
	if([MFMessageComposeViewController canSendText])
	{
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
		controller.body = msgBody;
        controller.recipients = contactNoSelectedArray;
        [[self navigationController] presentViewController:controller animated:NO completion:nil];
	}
    else
    {
        [objManager showAlert:@"Alert !" msg:@"Your device not support messaging or currently not configured to send messages." cancelBtnTitle:@"Ok" otherBtn:Nil];
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
            [self hideTheUserMessageEditTextView];
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



//dismiss models
-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

//API calling

 -(void)mailToServer
{
    [self hideTheUserMessageEditTextView];
    WebserviceController *wbh = [[WebserviceController alloc] init];
    wbh.delegate = self;
    NSArray *arr = [toolkitLink componentsSeparatedByString:@"/"];
    NSString *message=self.stringStr;
    if(message==NULL)
    {
        message=@"";
    }
    
    for(int sm=0;sm<contactSelectedArray.count;sm++)
    {
        NSDictionary *dictData = @{@"user_id":userID, @"email_addresses":[contactSelectedArray objectAtIndex:sm] ,@"message_title":message,@"toolkit_id":[arr objectAtIndex:6]};
        [wbh call:dictData controller:@"broadcast" method:@"sendmail"];
    }
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];

    UILabel *navTitle = [navnBar navBarTitleLabel:@"Refer Friends"];
    [navnBar addSubview:navTitle];
    [navnBar addSubview:button];

    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:objManager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)sendEmailView:(id)sender {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully referred your friends." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Refer more people", nil];
    [alert show];
    
    [self mailToServer];
    emailView.hidden = YES;
    referredValue = @"";
    referEmailStr = @"";
    _emailContacts.text = @"";
}
- (IBAction)cancelEmailView:(id)sender {
    _emailContacts.text = @"";
    
    [objManager showAlert:@"Cancelled" msg:@"Mail cancelled" cancelBtnTitle:@"Ok" otherBtn:nil];
    emailView.hidden = TRUE;
    referredValue = @"";
    referEmailStr = @"";
}

-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"WebService Data -- %@",data);
    mailSent++;
}
- (IBAction)addmoreBtn:(id)sender
{
    [self ContactSelectorMethod];
}


#pragma mark - Device Orientation
-(void)detectDeviceOrientation
{
    if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)){
        [self orient:self.interfaceOrientation];
    }else{
        [self orient:self.interfaceOrientation];
    }
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self orient:toInterfaceOrientation];
    if(isUserMessageEditing)
    {
        [self setScrollviewContentForTextView];
    }
}

-(void)orient:(UIInterfaceOrientation)ott
{
    if (ott == UIInterfaceOrientationLandscapeLeft ||
        ott == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 480, 320);
            scrollView.contentSize = CGSizeMake(480, 450);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 80, 480, 430);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 568, 300);
            scrollView.contentSize = CGSizeMake(568, 480);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 81, 568, 400);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 170, 1024, 900);
            scrollView.contentSize = CGSizeMake(1024, 1100);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(14, 20, 1000, 688);
        }
    }
    else if(ott == UIInterfaceOrientationPortrait || ott == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 320, 370);
            scrollView.contentSize = CGSizeMake(320, 280);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 20, 320, 330);
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.frame = CGRectMake(0, 80, 320, 568);
            scrollView.contentSize = CGSizeMake(320, 300);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(0, 81, 320, 390);
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            scrollView.frame = CGRectMake(0, 170, 768, 752);
            scrollView.contentSize = CGSizeMake(768, 500);
            scrollView.bounces = NO;
            emailView.frame = CGRectMake(14, 20, 734, 688);
        }
    }
    if(![objManager isiPad])
    {
        [self setUIForIOS6];
    }
}
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        scrollView.contentSize=CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height+70);
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
