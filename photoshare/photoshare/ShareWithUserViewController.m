//
//  ShareWithUserViewController.m
//  photoshare
//
//  Created by ignis2 on 10/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "ShareWithUserViewController.h"
#import "NavigationBar.h"
#import "SVProgressHUD.h"

@interface ShareWithUserViewController ()

@end

@implementation ShareWithUserViewController
{
    NavigationBar *navnBar;
}
@synthesize isEditFolder,isWriteUser,collectionId,collectionOwnerId, collectionUserDetails;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"ShareWithUserViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"ShareWithUserViewController";
    }

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
     userid=[manager getData:@"user_id"];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    //set the disign of the button , View and Label
    /*UIColor *tfBackViewBorderColor=[UIColor lightGrayColor];
    float tfBackViewBorderWidth=2;
    float tfBackViewCornerRadius=5;
    
    shareSearchView.layer.borderWidth=tfBackViewBorderWidth;
    shareSearchView.layer.cornerRadius=tfBackViewCornerRadius;
   shareSearchView.layer.borderColor=tfBackViewBorderColor.CGColor;
    */
    sharingUserListCollView.layer.borderColor=[UIColor darkGrayColor].CGColor;
    sharingUserListCollView.layer.borderWidth=1;
    
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    float btnBorderWidth=2;
    float btnCornerRadius=8;
    saveBtn.layer.cornerRadius=btnCornerRadius;
    saveBtn.layer.borderWidth=btnBorderWidth;
    saveBtn.layer.borderColor=btnBorderColor.CGColor;
    //initialize the search view and button
    
    searchView=[[UIView alloc] init];
    searchView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    searchView.layer.borderWidth=1.0;
    
    searchUserListResult=[[NSMutableArray alloc] init];
    searchUserIdResult=[[NSMutableArray alloc] init];
    
    sharingUserNameArray=[[NSMutableArray alloc] init];
    sharingUserIdArray=[[NSMutableArray alloc] init];
    // Do any additional setup after loading the view from its nib.
    
    //collection view
    [sharingUserListCollView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    NSLog(@"Is edit %d",self.isEditFolder);
    
    shareSearchView.hidden=NO;
    saveBtn.hidden=NO;
    sharingUserListCollView.userInteractionEnabled=YES;
    
        //check the type of folder mode either "New Folder" or "Edit Folder"
        if(self.isEditFolder)
        {
            if(self.collectionOwnerId.integerValue!=userid.integerValue)
            {
                shareSearchView.hidden=YES;
                saveBtn.hidden=YES;
                sharingUserListCollView.userInteractionEnabled=NO;
            }
            
            
        }
   
    //check the type of sharing permission "Write Permission" or "Read Permission"
    if(self.isWriteUser)
    {
        [self getWriteSharingUserList];
    }
    else
    {
        [self getReadSharingUserList];
    }
    
    //tap getsure on view for dismiss the keyboard
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //set the contentsize
    [self checkOrientation];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    //contant manager Object
    manager = [ContentManager sharedManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUIForIOS6
{
    
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        [[searchBarForUserSearch.subviews objectAtIndex:0] removeFromSuperview];
        scrollView.frame=CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height+60);
    }
    
    
}
#pragma mark - End View Editing
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    
    [self.view endEditing:YES];
    //[searchView removeFromSuperview];
}

#pragma mark - Search Bar Delegate Method
//search bar Delegate Method
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSString *str=searchBar.text;
    if(str.length>2)
    {
        webservices.delegate=self;
        isSearchUserList=YES;
        NSDictionary *dicData=@{@"user_id":userid,@"target_username":str,@"target_user_emailaddress":@""};
        [webservices call:dicData controller:@"user" method:@"search"];
    }
    else
    {
        [searchView removeFromSuperview];
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar.text isEqualToString:@""]) {
        [searchView removeFromSuperview];
    }
}
#pragma mark - Device Orientation
-(void)checkOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {

            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,300);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
    
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,300);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([manager isiPad])
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,500);
            scrollView.scrollEnabled=NO;
           
        }
    }
    else {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,270);
            scrollView.scrollEnabled=YES;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,270);
            scrollView.scrollEnabled=YES;
        }
        else if ([manager isiPad])
        {
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,500);
            scrollView.scrollEnabled=YES;
        }
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
       [self checkOrientation];
}

#pragma mark - Set the data in Array for UICollectionView
-(void)getWriteSharingUserList
{
    NSArray *writeuseridarray=[[manager getData:@"writeUserId"] componentsSeparatedByString:@","];
    
    if(![[writeuseridarray objectAtIndex:0] isEqualToString:@""])
    {
        for (int i=0; i<writeuseridarray.count; i++) {
            if(![[writeuseridarray objectAtIndex:i] isEqualToString:@"0"])
            {
                NSLog(@"Collection user details %@",self.collectionUserDetails);
            NSDictionary *userDetail=[self.collectionUserDetails objectForKey:[writeuseridarray objectAtIndex:i]];
                if(userDetail==nil)
                {
                    userDetail=[[manager getData:@"temp_user_details"] objectForKey:[writeuseridarray objectAtIndex:i]];
                }
            [sharingUserNameArray addObject:[userDetail objectForKey:@"user_username"]];
            [sharingUserIdArray addObject:[userDetail objectForKey:@"user_id"]];
            }
        }
    }
}
-(void)getReadSharingUserList
{
    NSArray *readuseridarray=[[manager getData:@"readUserId"] componentsSeparatedByString:@","];
    
   if(![[readuseridarray objectAtIndex:0] isEqualToString:@""])
    {
        for (int i=0; i<readuseridarray.count; i++) {
            if(![[readuseridarray objectAtIndex:i] isEqualToString:@"0"])
            {
                NSDictionary *userDetail=[self.collectionUserDetails objectForKey:[readuseridarray objectAtIndex:i]];
                if(userDetail==nil)
                {
                    userDetail=[[manager getData:@"temp_user_details"] objectForKey:[readuseridarray objectAtIndex:i]];
                }
                [sharingUserNameArray addObject:[userDetail objectForKey:@"user_username"]];
                [sharingUserIdArray addObject:[userDetail objectForKey:@"user_id"]];
            }
            
            
        }
    }
}
#pragma mark - Webservices call back Methods
-(void)webserviceCallback:(NSDictionary *)data
{
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    [SVProgressHUD dismiss];
    
    if (isSearchUserList)
    {        
        if(exitCode ==1)
        {
            for (UIView *view in [searchView subviews]) {
                [view removeFromSuperview];
            }

            NSArray *outPutData=[data objectForKey:@"output_data"];
            
            searchView.frame=CGRectMake(shareSearchView.frame.origin.x-5, shareSearchView.frame.origin.y+shareSearchView.frame.size.height, shareSearchView.frame.size.width+10, 25*outPutData.count);
            searchView.backgroundColor=[UIColor whiteColor];
            searchView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
            
            //remove all objects
            [searchUserIdResult removeAllObjects];
            [searchUserListResult removeAllObjects];
            
            for (int i=0; i<outPutData.count; i++) {
                [[outPutData objectAtIndex:i] objectForKey:@"user_username"];
                NSLog(@"search user List %@", [[outPutData objectAtIndex:i] objectForKey:@"user_username"]);
                
                NSString *resultName=[NSString stringWithFormat:@"%@ (%@)",[[outPutData objectAtIndex:i] objectForKey:@"user_username"],[[outPutData objectAtIndex:i] objectForKey:@"user_realname"]];
                [searchUserListResult addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_username"]];
                [searchUserIdResult addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_id"]];
                searchList=[[UIButton alloc] init];
                
                    searchList.frame=CGRectMake(5, i*25, shareSearchView.frame.size.width-10, 20);
                    searchList.tag=1100+i;
                
                if([manager isiPad])
                {
                     [searchList.titleLabel setFont:[UIFont fontWithName:@"verdana" size:17]];
                }
                else
                {
                    [searchList.titleLabel setFont:[UIFont fontWithName:@"verdana" size:13]];
                }
                    searchList.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
                    [searchList addTarget:self action:@selector(shareWithUserBtnPress:) forControlEvents:UIControlEventTouchUpInside];
                    [searchList setTitle:resultName forState:UIControlStateNormal];
                    [searchList setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    
                    [searchView addSubview:searchList];
                    [scrollView addSubview:searchView];
                }
        }
        else
        {
            [searchView removeFromSuperview];
        }
        isShareForWritingWith=NO;
        isShareForReadingWith=NO;
        isSearchUserList=NO;
    }
}

#pragma mark - set the search user
-(void)shareWithUserBtnPress: (id)sender
{
    
    UIButton *btn=(UIButton *)sender;
    int index=btn.tag-1100;
    
    searchBarForUserSearch.text=[searchUserListResult objectAtIndex:index];
    selectedUserId=[searchUserIdResult objectAtIndex:index];
    selecteduserName=[searchUserListResult objectAtIndex:index];
    
    [searchView removeFromSuperview];
}
#pragma mark - IBAction methods
-(IBAction)saveSharingUser:(id)sender
{
    NSString *useridstr=[sharingUserIdArray componentsJoinedByString:@","];
    NSMutableDictionary *tempuserDetails=[[NSMutableDictionary alloc] init];
    for (int i=0; i<sharingUserIdArray.count;i++) {
       
        [tempuserDetails setObject:[NSDictionary dictionaryWithObjectsAndKeys:[sharingUserIdArray objectAtIndex:i],@"user_id",[sharingUserNameArray objectAtIndex:i],@"user_username", nil] forKey:[sharingUserIdArray objectAtIndex:i]];
         
    }
    [manager storeData:tempuserDetails :@"temp_user_details"];
    if(isWriteUser)
    {
        [manager storeData:useridstr :@"writeUserId"];
    }
    else
    {
        [manager storeData:useridstr :@"readUserId"];
    }
    
    NSString *useridstr2=[manager getData:@"readUserId"];
    useridstr2=[manager getData:@"writeUserId"];
    
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(IBAction)addUserInSharing:(id)sender
{
    if(searchBarForUserSearch.text.length>0)
    {
        if([searchUserListResult containsObject:searchBarForUserSearch.text])
        {
            int index=[searchUserListResult indexOfObject:searchBarForUserSearch.text];
            if(index!=-1)
            {
                selectedUserId=[searchUserIdResult objectAtIndex:index];
                selecteduserName=[searchUserListResult objectAtIndex:index];
            }
        }
        
        if([searchBarForUserSearch.text isEqualToString:selecteduserName])
        {
            if(selectedUserId.integerValue==userid.integerValue)
            {
                [manager showAlert:@"Message" msg:@"You can not share to yourself!" cancelBtnTitle:@"Ok" otherBtn:Nil];
                searchBarForUserSearch.text=@"";
            }
            else
            {
                if([sharingUserIdArray containsObject:selectedUserId])
                {
                [manager showAlert:@"Message" msg:@"Already Share this User" cancelBtnTitle:@"Ok" otherBtn:Nil];
                    searchBarForUserSearch.text=@"";
                }
                else
                {
                    [sharingUserIdArray addObject:selectedUserId];
                    [sharingUserNameArray addObject:selecteduserName];
                    [sharingUserListCollView reloadData];
                    searchBarForUserSearch.text=@"";
                }
            }
            
        }
        else
        {
            [manager showAlert:@"Message" msg:@"Enter correct User Name" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
    }
    else
    {
        [manager showAlert:@"Message" msg:@"Enter User Name" cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
    
    [searchView removeFromSuperview];
}

#pragma mark - UICollectionView delegate Method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return sharingUserNameArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    UILabel *username=[[UILabel alloc] initWithFrame:CGRectMake(0, 5, cell.frame.size.width-10, cell.frame.size.height-5)];
    username.lineBreakMode=NSLineBreakByWordWrapping;
    username.textColor=[UIColor blackColor];
    username.layer.cornerRadius=5;
    username.layer.borderWidth=1;
    username.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    username.textAlignment=NSTextAlignmentCenter;
    username.font=[UIFont fontWithName:@"verdana" size:13];
    username.text=[sharingUserNameArray objectAtIndex:indexPath.row];
    
    
     [cell.contentView addSubview:username];

    //user remove button (cross button)
    if(self.isEditFolder)
    {
        if(self.collectionOwnerId.integerValue==userid.integerValue)
        {
            UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width-15, 0, 15, 15)];
            btn.tag=indexPath.row;
            [btn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(removeShareUser:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn];
        }
    }
    else
    {
        UIButton *btn=[[UIButton alloc] initWithFrame:CGRectMake(cell.frame.size.width-15, 0, 15, 15)];
        btn.tag=indexPath.row;
        [btn setImage:[UIImage imageNamed:@"cancel_btn.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(removeShareUser:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
    }
    return cell;
}

#pragma mark - Remove the share user
-(void)removeShareUser :(id)sender
{
    UIButton *btn=(UIButton *)sender;
   
    @try {
        [sharingUserNameArray removeObjectAtIndex:btn.tag];
        [sharingUserIdArray removeObjectAtIndex:btn.tag];
        [sharingUserListCollView reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Execption is %@",exception.description);
    }
}
#pragma mark - Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button =[navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *titleLabel =[navnBar navBarTitleLabel:@"Share with User"];
    
    [navnBar addSubview:button];
    [navnBar addSubview:titleLabel];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
