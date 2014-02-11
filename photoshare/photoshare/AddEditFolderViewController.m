//
//  AddFolderViewController.m
//  photoshare
//
//  Created by ignis2 on 24/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AddEditFolderViewController.h"
#import "CommonTopView.h"
#import "CommunityViewController.h"
#import "NavigationBar.h"
#import "SVProgressHUD.h"
#import "ShareWithUserViewController.h"
@interface AddEditFolderViewController ()

@end

@implementation AddEditFolderViewController

@synthesize isAddFolder,isEditFolder,collectionId,setFolderName,collectionShareWith;
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
    
    //initialize the photo is array
    photoIdArray=[[NSMutableArray alloc] init];
    collectionDetail=[[NSMutableDictionary alloc] init];
    
    //contant manager Object
     manager = [ContentManager sharedManager];
    webServices=[[WebserviceController alloc] init];
    
    
    //set the disign of the button , View and Label
    UIColor *tfBackViewBorderColor=[UIColor lightGrayColor];
    float tfBackViewBorderWidth=2;
    float tfBackViewCornerRadius=5;
    
    folderNameView.layer.borderWidth=tfBackViewBorderWidth;
    folderNameView.layer.cornerRadius=tfBackViewCornerRadius;
    folderNameView.layer.borderColor=tfBackViewBorderColor.CGColor;

    
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
    
    if(self.isEditFolder)
    {
        headingLabel.text=@"Edit Folder";
        addButton.hidden=YES;
        saveButton.hidden=NO;
        deleteButton.hidden=NO;
        NSLog(@"Share With %@",self.collectionShareWith);
        folderName.text=self.setFolderName;
        
        [self getCollectionDetail];
     
    }
    else if(isAddFolder)
    {
        headingLabel.text=@"New Folder";
        addButton.hidden=NO;
        saveButton.hidden=YES;
        deleteButton.hidden=YES;
        
    }
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self addCustomNavigationBar];
    
    //get the user id from nsuserDefaults
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
//get PhotoId From Server
-(void)getCollectionDetail
{
    @try {
        
        isGetCollectionDetails=YES;
        webServices.delegate=self;
        [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        
        NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
        
        [webServices call:dicData controller:@"collection" method:@"get"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}



//clear the text of textField
-(void)clearTextField:(id)sender
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
    [self.navigationController pushViewController:sharewith animated:NO];
}
-(IBAction)shareForReadingWith:(id)sender
{
    ShareWithUserViewController *sharewith=[[ShareWithUserViewController alloc] init];
    sharewith.isWriteUser=NO;
    sharewith.collectionId=self.collectionId;
    sharewith.isEditFolder=self.isEditFolder;
    [self.navigationController pushViewController:sharewith animated:NO];
}
//Btn Action
-(IBAction)addFolder:(id)sender
{
    @try {
        [self addCollectionInfoInServer:folderName.text sharing:@0 writeUserIds:[manager getData:@"writeUserId"] readUserIds:[manager getData:@"readuserId"]];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
    
}

-(IBAction)saveFolder:(id)sender
{
    @try {
        
            [self editCollectionInfoInServer:self.collectionId collectionName:folderName.text sharing:@0 writeUserIds:[manager getData:@"writeUserId"] readUserIds:[manager getData:@"readUserId"]];
        
    }
    @catch (NSException *exception) {
         NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
    
}
-(IBAction)deleteFolder:(id)sender
{
    isDeletePhotoMode=YES;
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Are you sure you want to delete this folder and all of its contents?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [alert show];
    
}


//store collection info in server
-(void)addCollectionInfoInServer:(NSString *)collectionName sharing:(NSNumber *)sharing writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
   
    isAdd=YES;
    
    webServices.delegate=self;
   if(writeUserIds==Nil)
   {
       writeUserIds=@"";
   }
    if(readUserIds==Nil)
    {
        readUserIds=@"";
    }
     NSDictionary *dicData=@{@"user_id":userid,@"collection_name":collectionName,@"collection_sharing":@"0",@"collection_write_user_ids":writeUserIds,@"collection_read_user_ids":readUserIds};
    @try {
        [webServices call:dicData controller:@"collection" method:@"store"];

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
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
  
    webServices.delegate=self;
    
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
        [webServices call:dicData controller:@"collection" method:@"change"];

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}
-(void)deleteCollectionInfoInServer
{
    
    isDelete=YES;
    
    webServices.delegate=self;
    //delete data
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
    [webServices call:dicData controller:@"collection" method:@"delete"];
    
}

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
                        
                        [photoIdArray addObjectsFromArray:[collectionContent allKeys]];
                        NSString *writeUserIdStr=[[collectionDetail objectForKey:@"collection_write_user_ids"] componentsJoinedByString:@","];
                        NSString *readUserIdStr=[[collectionDetail objectForKey:@"collection_read_user_ids"] componentsJoinedByString:@","];
                        //store in nsuserDefault
                        [manager storeData:writeUserIdStr :@"writeUserId"];
                        [manager storeData:readUserIdStr :@"readUserId"];
                    }
                    @catch (NSException *exception) {
                        
                    }
                    @finally {
                        
                    }
                
                }
                @catch (NSException *exception) {
                
                }
                @finally {
                    
                }
                isGetCollectionDetails=NO;
                [SVProgressHUD dismiss];
            }

        }
        else if(isAdd||isSave||isDelete)
        {
            if(exitCode ==1)
            {
                UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alertView show];
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
    
}


-(void)deletePhotoFromServer
{
    @try {
        for (int i=0; i<photoIdArray.count; i++) {
            
            NSDictionary *dicData=@{@"user_id":userid,@"photo_id":[photoIdArray objectAtIndex:i]};
            [webServices call:dicData controller:@"photo" method:@"delete"];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
    
}
//alert Delegate Method
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
            @finally {
                
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
            [self.navigationController popViewControllerAnimated:YES];
        }

    }
    
}
#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
    // navnBar.backgroundColor = [UIColor redColor];
    [navnBar addSubview:button];
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
