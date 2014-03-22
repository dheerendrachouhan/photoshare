//
//  AddFolderViewController.m
//  photoshare
//
//  Created by ignis2 on 24/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AddEditFolderViewController.h"
#import "CommunityViewController.h"
#import "SVProgressHUD.h"
#import "ShareWithUserViewController.h"
@interface AddEditFolderViewController ()

@end

@implementation AddEditFolderViewController


@synthesize isAddFolder,isEditFolder,collectionId,setFolderName,collectionOwnerId,isFromLaunchCamera;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"AddEditFolderViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"AddEditFolderViewController";
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
    
    // Do any additional setup after loading the view from its nib.
    
    //initialize the photo is array
    photoIdArray=[[NSMutableArray alloc] init];
    collectionDetail=[[NSMutableDictionary alloc] init];
    
    //contant manager Object
     manager = [ContentManager sharedManager];
    webservices=[[WebserviceController alloc] init];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    //set the write user
    [manager storeData:@"" :@"writeUserId"];
    [manager storeData:@"" :@"readUserId"];
    
    //set the delgate of text field
    [folderName setDelegate:self];
    
    //set the disign of the button , View and Label
    UIColor *tfBackViewBorderColor=[UIColor lightGrayColor];
    float tfBackViewBorderWidth=2;
    float tfBackViewCornerRadius=5;
    
    folderNameView.layer.borderWidth=tfBackViewBorderWidth;
    folderNameView.layer.cornerRadius=tfBackViewCornerRadius;
    folderNameView.layer.borderColor=tfBackViewBorderColor.CGColor;

    //initialize the array
    sharingIdArray=[[NSMutableArray alloc] init];
    collectionArrayWithSharing=[[NSMutableArray alloc] init];
    
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    float btnBorderWidth=2;
    float btnCornerRadius=8;
    saveButton.layer.cornerRadius=btnCornerRadius;
    saveButton.layer.borderWidth=btnBorderWidth;
    saveButton.layer.borderColor=btnBorderColor.CGColor;
    
    deleteButton.layer.cornerRadius=btnCornerRadius;
    deleteButton.layer.borderWidth=btnBorderWidth;
    deleteButton.layer.borderColor=btnBorderColor.CGColor;
    
    addButton.layer.cornerRadius=btnCornerRadius;
    addButton.layer.borderWidth=btnBorderWidth;
    addButton.layer.borderColor=btnBorderColor.CGColor;
    
    //drop down setting
    userid=[manager getData:@"user_id"];
    shareForReadingWithBtn.hidden=NO;
    shareForWritingWithBtn.hidden=NO;
    if(self.isEditFolder)
    {
        crossBtnForTF.hidden=NO;
        addButton.hidden=YES;
        saveButton.hidden=NO;
        deleteButton.hidden=NO;
        folderName.enabled=YES;
        folderNameView.userInteractionEnabled=YES;

        folderName.text=self.setFolderName;
        collectionOwnerNameLbl.text=@"";
        [self getCollectionDetail];
       
        if(self.collectionOwnerId.integerValue != userid.integerValue)
        {
            crossBtnForTF.hidden=YES;
            addButton.hidden=YES;
            saveButton.hidden=YES;
            deleteButton.hidden=YES;
            folderName.enabled=NO;
            folderNameView.userInteractionEnabled=NO;
        }
        if([self.setFolderName isEqualToString:@"Private"] || [self.setFolderName isEqualToString:@"private"])
        {
            crossBtnForTF.hidden=YES;
            addButton.hidden=YES;
            saveButton.hidden=YES;
            deleteButton.hidden=YES;
            folderName.enabled=NO;
            folderNameView.userInteractionEnabled=NO;
            shareForReadingWithBtn.hidden=YES;
            shareForWritingWithBtn.hidden=YES;
        }
     
    }
    else if(self.isAddFolder)
    {
        crossBtnForTF.hidden=NO;
        addButton.hidden=NO;
        saveButton.hidden=YES;
        deleteButton.hidden=YES;
        folderName.enabled=YES;
        folderNameView.userInteractionEnabled=YES;
        NSDictionary *dic = [manager getData:@"user_details"];
        collectionOwnerNameLbl.text=[dic objectForKey:@"user_realname"];
    }
    

    
    //tap getsure on view for dismiss the keyboard
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self checkOrientation];
    
    //contant manager Object
    manager = [ContentManager sharedManager];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
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
        scrollView.frame=CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height+60);
    }
}
#pragma mark - End View Editing
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    //reset the text field
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self.view endEditing:YES];
}

#pragma mark - Device Orientation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self checkOrientation];
}
-(void)checkOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,323);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,323);
            scrollView.scrollEnabled=NO;
        }
    }
    else {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,300);
            scrollView.scrollEnabled=YES;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,300);
            scrollView.scrollEnabled=YES;
        }
    }
}

#pragma  mark - Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
       [scrollView setContentOffset:CGPointMake(0,folderNameView.center.y-30) animated:YES];
    }
    else
    {
       [scrollView setContentOffset:CGPointMake(0,folderNameView.center.y-30) animated:NO];
    }
}
//called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBAction Methods
-(IBAction)clearTextField:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==101)
    {
        folderName.text=@"";
        [folderName becomeFirstResponder];
    }
    
}

-(IBAction)shareForWritingWith:(id)sender
{
    ShareWithUserViewController *sharewith=[[ShareWithUserViewController alloc] init];
    
    sharewith.isWriteUser=YES;
    sharewith.collectionId=self.collectionId;
    sharewith.isEditFolder=self.isEditFolder;
    sharewith.collectionOwnerId=self.collectionOwnerId;
    sharewith.collectionUserDetails=collectionUsersDetail;
    [self.navigationController pushViewController:sharewith animated:NO];
}
-(IBAction)shareForReadingWith:(id)sender
{
    ShareWithUserViewController *sharewith=[[ShareWithUserViewController alloc] init];
        sharewith.isWriteUser=NO;
    sharewith.collectionId=self.collectionId;
    sharewith.isEditFolder=self.isEditFolder;
    sharewith.collectionOwnerId=self.collectionOwnerId;
    sharewith.collectionUserDetails=collectionUsersDetail;
    [self.navigationController pushViewController:sharewith animated:NO];
}
//Btn Action
-(IBAction)addFolder:(id)sender
{
    if(folderName.text.length==0)
    {
        [self alertForFolderNameText];
    }
    else
    {
        @try {
            [self addCollectionInfoInServer:folderName.text sharing:@0 writeUserIds:[manager getData:@"writeUserId"] readUserIds:[manager getData:@"readUserId"]];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception is %@",exception.description);
        }
        
    }
}

-(IBAction)saveFolder:(id)sender
{
    if(folderName.text.length==0)
    {
        [self alertForFolderNameText];
    }
    else
    {
        @try {
            [self editCollectionInfoInServer:self.collectionId collectionName:folderName.text sharing:@0 writeUserIds:[manager getData:@"writeUserId"] readUserIds:[manager getData:@"readUserId"]];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Exception is %@",exception.description);
        }
       

    }
}
-(IBAction)deleteFolder:(id)sender
{
    isDeletePhotoMode=YES;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Are you sure you want to delete this folder and all of its contents?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
}

-(void)alertForFolderNameText
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert !" message:@"Folder name cannot be blank" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}
#pragma mark - Fetch and store the data on the server
//get the collection detail from server
-(void)getCollectionDetail
{
    @try {
        
        isGetCollectionDetails=YES;
        webservices.delegate=self;
        [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        
        NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
        
        [webservices call:dicData controller:@"collection" method:@"get"];
    }
    @catch (NSException *exception) {
        
    }
}
//store collection info in server
-(void)addCollectionInfoInServer:(NSString *)collectionName sharing:(NSNumber *)sharing writeUserIds:(NSString *)writeUserI readUserIds:(NSString *)readUserI
{
   
    isAdd=YES;
    
    webservices.delegate=self;
   if(writeUserI==Nil)
   {
       writeUserI=@"";
   }
    if(readUserI==Nil)
    {
        readUserI=@"";
    }
     NSDictionary *dicData=@{@"user_id":userid,@"collection_name":collectionName,@"collection_sharing":@"0",@"collection_write_user_ids":writeUserI,@"collection_read_user_ids":readUserI};
    @try {
        [webservices call:dicData controller:@"collection" method:@"store"];

    }
    @catch (NSException *exception) {
        
    }
}
-(void)editCollectionInfoInServer:(NSNumber *)collecId collectionName:(NSString *)collectionName sharing:(NSNumber *)sharing writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
    isSave=YES;
  
    if (writeUserIds == nil) {
    writeUserIds=@"";
    }
    
    if(readUserIds == nil)
    readUserIds=@"";
  
    webservices.delegate=self;
    
    //edit data
    NSDictionary *dicData;
    if([folderName.text isEqualToString:self.setFolderName])
    {
        dicData=@{@"user_id":userid,@"collection_id":collecId,@"collection_sharing":@"",@"collection_write_user_ids":writeUserIds,@"collection_read_user_ids":readUserIds};
    }
    else
    {
        dicData=@{@"user_id":userid,@"collection_id":collecId,@"collection_name":collectionName,@"collection_sharing":@"0",@"collection_write_user_ids":writeUserIds,@"collection_read_user_ids":readUserIds};
    }
    
    @try {
        [webservices call:dicData controller:@"collection" method:@"change"];
    }
    @catch (NSException *exception) {
        
    }
}
-(void)deleteCollectionInfoInServer
{
    isDelete=YES;
    webservices.delegate=self;
    //delete data
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
    [webservices call:dicData controller:@"collection" method:@"delete"];
}
-(void)getTheCollectionOwnerName
{
    NSDictionary *dicData=@{@"user_id":userid,@"target_user_id":self.collectionOwnerId,@"target_username":@""};
    webservices.delegate=self;
    isGetCollectionOwnername=YES;
    [webservices call:dicData controller:@"user" method:@"get"];
    
}
-(void)deletePhotoFromServer
{
    // Get the Documents directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    // Delete the file using NSFileManager
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:[documentsDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/123FridayImages/YourFolder/%@",self.setFolderName]] error:nil])
    {
        NSLog(@"Delete Success");
    }
    else
    {
        NSLog(@"Delete Fail");
    }
    
    
    
    @try {
        for (int i=0; i<photoIdArray.count; i++) {
            
            NSDictionary *dicData=@{@"user_id":userid,@"photo_id":[photoIdArray objectAtIndex:i]};
            [webservices call:dicData controller:@"photo" method:@"delete"];
        }
    }
    @catch (NSException *exception) {
        
    }
}
-(void)getSharingusersId
{
    @try {
        
        isGetSharingUserId=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"sharing"];
    }
    @catch (NSException *exception) {
        
    }
}
//Fetch data From Server
-(void)fetchOwnCollectionInfoFromServer
{
    @try {
        isGetTheOwnCollectionListData=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"getlist"];
        
    }
    @catch (NSException *exception) {
        
    }
}
-(void)fetchSharingCollectionInfoFromServer
{
    @try {
        if(sharingIdArray.count>0)
        {
            countSharing=0;
            for (int i=0; i<sharingIdArray.count; i++) {
                isGetTheSharingCollectionListData=YES;
                webservices.delegate=self;
                NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":[sharingIdArray objectAtIndex:i]};
                [webservices call:dicData controller:@"collection" method:@"getlist"];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - Webservice Call Back Method
//call back Method
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Collection return %@",data);
    NSLog(@"exit  %@",[data objectForKey:@"exit_code"]);
    
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    
        if (isGetCollectionDetails)
        {
            if(exitCode ==1)
            {
                @try {
                    NSDictionary *outputData=[data objectForKey:@"output_data"];
                    NSDictionary *collectionContent=[[outputData objectForKey:@"collection_contents"] mutableCopy];

                    collectionDetail=[outputData mutableCopy];
                    
                    @try {
                      if(collectionContent.count!=0)
                      {
                          [photoIdArray addObjectsFromArray:[collectionContent allKeys]];
                      }
                        collectionUsersDetail=[collectionDetail objectForKey:@"collection_user_details"];
                        
                        NSString *writeUserIdStr=[[collectionDetail objectForKey:@"collection_write_user_ids"] componentsJoinedByString:@","];
                        NSString *readUserIdStr=[[collectionDetail objectForKey:@"collection_read_user_ids"] componentsJoinedByString:@","];
                        //store in nsuserDefault
                        [manager storeData:writeUserIdStr :@"writeUserId"];
                        [manager storeData:readUserIdStr :@"readUserId"];
                        
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
                @catch (NSException *exception) {
                
                }
                isGetCollectionDetails=NO;
                [self getTheCollectionOwnerName];
            }
            else
            {
                [SVProgressHUD dismiss];
                [manager showAlert:@"Error" msg:@"Network Error" cancelBtnTitle:@"Ok" otherBtn:Nil];
            }

        }
    else if (isGetCollectionOwnername)
    {
        if(exitCode==1)
        {
            NSArray *outputData=[data objectForKey:@"output_data"];
            collectionOwnerName=[[outputData objectAtIndex:0] objectForKey:@"user_realname"];
            collectionOwnerNameLbl.text=collectionOwnerName;
            [SVProgressHUD dismiss];
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        isGetCollectionOwnername=NO;
    }
    
    else if(isAdd||isSave||isDelete)
    {
        if(exitCode ==1)
        {
            if(isAdd)
            {               
                
                newCollectionId=[[[data objectForKey:@"output_data"] objectAtIndex:0] objectForKey:@"collection_id"];
            }
            if(isDelete)
            {
                isDeleteAllPhoto=YES;
            }
            //[self updateCollectionDetailInNsUserDefault];
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
            user_message=[data objectForKey:@"user_message"];
            [self getSharingusersId];//for update the collection detail in nsuser default
        }
        else
        {
            [manager showAlert:@"Message" msg:[data objectForKey:@"user_message"] cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        //reset
        isAdd=NO;
        isSave=NO;
        isDelete=NO;

    }
    else if(isGetSharingUserId)
    {
        if(exitCode==1)
        {
            NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
            [sharingIdArray removeAllObjects];
            for (int i=0; i<outPutData.count; i++)
            {
                @try {
                    [sharingIdArray addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_id"]];
                }
                @catch (NSException *exception) {
                    
                }                
            }
        }
        isGetSharingUserId=NO;
        [self fetchOwnCollectionInfoFromServer];
        
    }
    else if(isGetTheOwnCollectionListData)
    {
        [collectionArrayWithSharing removeAllObjects];
        if(exitCode==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]] ;
            //nsuser default
            
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        isGetTheOwnCollectionListData=NO;
        if(sharingIdArray.count>0)
        {
            [self fetchSharingCollectionInfoFromServer];
        }
        else
        {
            [SVProgressHUD dismiss];
            if(collectionArrayWithSharing.count>0)
            {
                if(isDeleteAllPhoto)
                {
                    [self deletePhotoFromServer];
                    isDeleteAllPhoto=NO;
                }
                
                 [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
            }
            else
            {
                [self updateCollectionDetailInNsUserDefault];
            }
           
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:user_message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alertView show];
        }
        
    }
    else if (isGetTheSharingCollectionListData)
    {
        if(exitCode==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]] ;
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        countSharing++;
        if(countSharing==sharingIdArray.count)
        {
             [SVProgressHUD dismiss];
            if(collectionArrayWithSharing.count>0)
            {
                if(isDeleteAllPhoto)
                {
                    [self deletePhotoFromServer];
                    isDeleteAllPhoto=NO;
                }
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
            }
            else
            {
                [self updateCollectionDetailInNsUserDefault];
            }
           
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:user_message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alertView show];
        }
    }
}

#pragma mark - Update cache data (NSUser default)
-(void)updateCollectionDetailInNsUserDefault
{
    NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];
    
    NSString *writeUserIds=[manager getData:@"writeUserId"];
    NSString *readUserIds=[manager getData:@"readUserId"];
    NSNumber *shared=@0;
    if(writeUserIds.length>0||readUserIds.length>0)
    {
        shared=@1;
    }
    
    if(isAdd)
    {
        NSMutableDictionary *newCol=[[NSMutableDictionary alloc] init];
        [newCol setObject:@0 forKey:@"collection_default"];
        [newCol setObject:newCollectionId forKey:@"collection_id"];
        [newCol setObject:folderName.text forKey:@"collection_name"];
        [newCol setObject:shared forKey:@"collection_shared"];
        [newCol setObject:@0 forKey:@"collection_sharing"];
        [newCol setObject:userid forKey:@"collection_user_id"];
        
        [collection addObject:newCol];
        [manager storeData:collection :@"collection_data_list"];
    }
    else if (isSave)
    {
        NSMutableDictionary *newCol=[[NSMutableDictionary alloc] init];
        [newCol setObject:@0 forKey:@"collection_default"];
        [newCol setObject:self.collectionId forKey:@"collection_id"];
        [newCol setObject:folderName.text forKey:@"collection_name"];
        [newCol setObject:shared forKey:@"collection_shared"];
        [newCol setObject:@0 forKey:@"collection_sharing"];
        [newCol setObject:userid forKey:@"collection_user_id"];
        
        for (int i=0; i<collection.count; i++) {
            NSNumber *colId=[[collection objectAtIndex:i] objectForKey:@"collection_id"];
            if(colId.integerValue==self.collectionId.integerValue)
            {
                [collection replaceObjectAtIndex:i withObject:newCol];
                [manager storeData:collection :@"collection_data_list"];
                break;
            }
        }
    }
    else if (isDelete)
    {
        
        for (int i=0; i<collection.count; i++) {
            
            NSNumber *colId=[[collection objectAtIndex:i] objectForKey:@"collection_id"];
            if(colId.integerValue==self.collectionId.integerValue)
            {
                [collection removeObjectAtIndex:i];
                [manager storeData:collection :@"collection_data_list"];
                break;
            }
        }
    }
    //reset
    isAdd=NO;
    isSave=NO;
    isDelete=NO;
}

#pragma mark - UIAlert View Delegate Methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(isDeletePhotoMode)
    {
        if(buttonIndex!=[alertView cancelButtonIndex])
        {
            isDeletePhotoMode=NO;
            
            @try {
                [self deleteCollectionInfoInServer];
               
            }
            @catch (NSException *exception) {
                NSLog(@"Exception is %@",exception.description);
            }
            
        }
        else
        {
             isDeletePhotoMode=NO;
        }
    }
    else
    {
        if(buttonIndex==0)
        {
            
            [self navBackButtonClick];
        }

    }
}
#pragma mark - LaunchCamera SetDetection
-(void)checkIfIsFromLaunchCamera
{
    if(self.isFromLaunchCamera)
    {
        [manager storeData:@"YES" :@"is_add_folder"];
        [manager storeData:newCollectionId :@"new_col_id"];
    }
}
#pragma mark -Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button =[navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *titleLbl;
    titleLbl.textAlignment=NSTextAlignmentCenter;
    
    if(self.isEditFolder)
    {
        titleLbl=[navnBar navBarTitleLabel:@"Edit Folder"];
    }
    else if (self.isAddFolder)
    {
        titleLbl=[navnBar navBarTitleLabel:@"New Folder"];
    }
    
    
    [navnBar addSubview:titleLbl];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [self checkIfIsFromLaunchCamera];
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
