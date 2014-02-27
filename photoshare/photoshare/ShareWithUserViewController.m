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
@synthesize isEditFolder,isWriteUser,collectionId,collectionOwnerId;

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
    navnBar = [[NavigationBar alloc] init];
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
     userid=[manager getData:@"user_id"];
    [self addCustomNavigationBar];
    
    
    
    //set the disign of the button , View and Label
    UIColor *tfBackViewBorderColor=[UIColor lightGrayColor];
    float tfBackViewBorderWidth=2;
    float tfBackViewCornerRadius=5;
    
    shareSearchView.layer.borderWidth=tfBackViewBorderWidth;
    shareSearchView.layer.cornerRadius=tfBackViewCornerRadius;
    shareSearchView.layer.borderColor=tfBackViewBorderColor.CGColor;
    shareSearchView.layer.borderWidth=tfBackViewBorderWidth;
    shareSearchView.layer.cornerRadius=tfBackViewCornerRadius;
    shareSearchView.layer.borderColor=tfBackViewBorderColor.CGColor;
    
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
    searchView.layer.borderColor=[UIColor darkGrayColor].CGColor;
    searchView.layer.borderWidth=1;
    
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
            
            //check the type of sharing permission "Write Permission" or "Read Permission"
            if(self.isWriteUser)
            {
                [self getWriteSharingUserList];
            }
            else
            {
                [self getReadSharingUserList];
            }
        }
    
    
    
    //set textfeild delgate
    [searchUserTF setDelegate:self];
    
    //tap getsure on view for dismiss the keyboard
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
   
    [self.view endEditing:YES];
    //[searchView removeFromSuperview];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //set the contentsize
    [self checkOrientation];
    
    //contant manager Object
    manager = [ContentManager sharedManager];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
     [searchView removeFromSuperview];
    return [textField resignFirstResponder];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str=searchUserTF.text;
    if(str.length>0)
    {
        
        webservices.delegate=self;
        isSearchUserList=YES;
        NSDictionary *dicData=@{@"user_id":userid,@"target_username":str,@"target_user_emailaddress":@""};
        [webservices call:dicData controller:@"user" method:@"search"];
        
    }
    return YES;
}

-(void)checkOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            //scrollView.frame = CGRectMake(0.0f,100.0f,320.0f, 326.0f);
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,300);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            //scrollView.frame = CGRectMake(0.0f, 100.0f,320.0f, 420.0f);
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
            //scrollView.frame = CGRectMake(0.0f, 100.0f, 480.0f, 200.0f);
            scrollView.contentSize = CGSizeMake(self.view.frame.size.width,270);
            scrollView.scrollEnabled=YES;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            //scrollView.frame = CGRectMake(0.0f, 100.0f, 568.0f, 200.0f);
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
    [self addCustomNavigationBar];
    [self checkOrientation];
}
-(void)getWriteSharingUserList
{
    writeuseridarray=[[manager getData:@"writeUserId"] componentsSeparatedByString:@","];
    
    if(![[writeuseridarray objectAtIndex:0] isEqualToString:@""])
    {
        [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        isGetSharingWriteUserName=YES;
        webservices.delegate=self;
        for (int i=0; i<writeuseridarray.count; i++) {
            NSDictionary *dicdata=@{@"user_id":userid,@"target_user_id":[writeuseridarray objectAtIndex:i]};
            [webservices call:dicdata controller:@"user" method:@"get"];
        }
    }
    
}
-(void)getReadSharingUserList
{
    readuseridarray=[[manager getData:@"readUserId"] componentsSeparatedByString:@","];
    
   if(![[readuseridarray objectAtIndex:0] isEqualToString:@""])
    {
        [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        isGetSharingReadUserName=YES;
        webservices.delegate=self;
        for (int i=0; i<readuseridarray.count; i++) {
            NSDictionary *dicdata=@{@"user_id":userid,@"target_user_id":[readuseridarray objectAtIndex:i]};
            [webservices call:dicdata controller:@"user" method:@"get"];
        }
    }
}
//webservices call back
-(void)webserviceCallback:(NSDictionary *)data
{
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    [SVProgressHUD dismiss];
    if (isGetSharingWriteUserName)
    {
        if(exitCode==1)
        {
            NSArray *outPutData=[data objectForKey:@"output_data"];
            [sharingUserNameArray addObject:[[outPutData objectAtIndex:0] objectForKey:@"user_username"]];
            [sharingUserIdArray addObject:[[outPutData objectAtIndex:0] objectForKey:@"user_id"]];
            if(sharingUserNameArray.count==writeuseridarray.count)
            {
                isGetSharingWriteUserName=NO;
                [sharingUserListCollView reloadData];
            }
        }
    }
    else if (isGetSharingReadUserName)
    {
        if(exitCode==1)
        {
            NSArray *outPutData=[data objectForKey:@"output_data"];
            [sharingUserNameArray addObject:[[outPutData objectAtIndex:0] objectForKey:@"user_username"]];
            [sharingUserIdArray addObject:[[outPutData objectAtIndex:0] objectForKey:@"user_id"]];
            if(sharingUserNameArray.count==readuseridarray.count)
            {
                isGetSharingReadUserName=NO;
                [sharingUserListCollView reloadData];
            }
        }
    }
    else if (isSearchUserList)
    {        
        if(exitCode ==1)
        {
            for (UIView *view in [searchView subviews]) {
                [view removeFromSuperview];
            }

            NSArray *outPutData=[data objectForKey:@"output_data"];
            
            searchView.frame=CGRectMake(shareSearchView.frame.origin.x, shareSearchView.frame.origin.y+shareSearchView.frame.size.height, shareSearchView.frame.size.width, 30*outPutData.count);
            searchView.backgroundColor=[UIColor whiteColor];
            
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
                
                    searchList.frame=CGRectMake(0, 5+(i*25), shareSearchView.frame.size.width, 20);
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
-(void)shareWithUserBtnPress: (id)sender
{
    
    UIButton *btn=(UIButton *)sender;
    int index=btn.tag-1100;
    
    searchUserTF.text=[searchUserListResult objectAtIndex:index];
    selectedUserId=[searchUserIdResult objectAtIndex:index];
    selecteduserName=[searchUserListResult objectAtIndex:index];
    
    [searchView removeFromSuperview];
}

//colllection view delgate method
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
-(IBAction)addUserInSharing:(id)sender
{
    if(searchUserTF.text.length>0)
    {
        if([searchUserTF.text isEqualToString:selecteduserName])
        {
            if(selectedUserId.integerValue==userid.integerValue)
            {
                [manager showAlert:@"Message" msg:@"You can not share to yourself!" cancelBtnTitle:@"Ok" otherBtn:Nil];
                searchUserTF.text=@"";
            }
            else
            {
                if([sharingUserIdArray containsObject:selectedUserId])
                {
                    [manager showAlert:@"Message" msg:@"Already Share this User" cancelBtnTitle:@"Ok" otherBtn:Nil];
                    searchUserTF.text=@"";
                }
                else
                {
                    [sharingUserIdArray addObject:selectedUserId];
                    [sharingUserNameArray addObject:selecteduserName];
                    [sharingUserListCollView reloadData];
                    searchUserTF.text=@"";
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
}
-(IBAction)saveSharingUser:(id)sender
{
    NSString *useridstr=[sharingUserIdArray componentsJoinedByString:@","];;
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
    @finally {
        
    }
    
}
#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    
    UILabel *titleLabel = [[UILabel alloc] init ];
    titleLabel.text=@"Share with User";
    titleLabel.textAlignment=NSTextAlignmentCenter;
    if([manager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
        }
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 90.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
        titleLabel.frame=CGRectMake(self.view.center.x-75, NavBtnYPosForiPad, 200.0, NavBtnHeightForiPad);
        titleLabel.font =[UIFont systemFontOfSize:23.0f];
        
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            titleLabel.frame = CGRectMake(100.0, NavBtnYPosForiPhone, 150.0, NavBtnHeightForiPhone);
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                titleLabel.frame = CGRectMake(170.0, NavBtnYPosForiPhone, 150.0, NavBtnHeightForiPhone);
            }
            else
            {
                titleLabel.frame = CGRectMake(210.0, NavBtnYPosForiPhone, 150.0, NavBtnHeightForiPhone);
            }
        }
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
       
    }
    
    [navnBar addSubview:button];
    [navnBar addSubview:titleLabel];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
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
