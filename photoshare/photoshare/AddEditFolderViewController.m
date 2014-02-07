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
    
    manager = [ContentManager sharedManager];
   
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //initialize the photo is array
    photoIdArray=[[NSMutableArray alloc] init];
    
    //contant manager Object
    
    webServices=[[WebserviceController alloc] init];
    
    //initialize the search view and button
    searchList=[[UIButton alloc] init];

    searchView=[[UIView alloc] init];
    searchView.layer.borderColor=[UIColor darkGrayColor].CGColor;
    searchView.layer.borderWidth=1;
    
   
    
    //initialize the search user list array
    searchUserList=[[NSMutableArray alloc] init];
    //set the disign of the button , View and Label
    UIColor *tfBackViewBorderColor=[UIColor lightGrayColor];
    float tfBackViewBorderWidth=2;
    float tfBackViewCornerRadius=5;
    
    folderNameView.layer.borderWidth=tfBackViewBorderWidth;
    folderNameView.layer.cornerRadius=tfBackViewCornerRadius;
    folderNameView.layer.borderColor=tfBackViewBorderColor.CGColor;
    
    shareForReadingWithView.layer.borderWidth=tfBackViewBorderWidth;
    shareForReadingWithView.layer.cornerRadius=tfBackViewCornerRadius;
    shareForReadingWithView.layer.borderColor=tfBackViewBorderColor.CGColor;
    shareForWritingWithView.layer.borderWidth=tfBackViewBorderWidth;
    shareForWritingWithView.layer.cornerRadius=tfBackViewCornerRadius;
    shareForWritingWithView.layer.borderColor=tfBackViewBorderColor.CGColor;
    
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
        if([self.collectionShareWith intValue]==0)
        {
            [privateShareBtn setImage:[UIImage imageNamed:@"radio_selected.png"] forState:UIControlStateNormal];
            [publicShareBtn setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
            shareWith=@0;
        }
        else if ([self.collectionShareWith intValue]==1)
        {
            [privateShareBtn setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
            [publicShareBtn setImage:[UIImage imageNamed:@"radio_selected.png"] forState:UIControlStateNormal];
            shareWith=@1;
        }
      // [self getCollectionDetail];
        
        [self getPhotoIdFromServer];
     
    }
    else if(isAddFolder)
    {
        headingLabel.text=@"New Folder";
        addButton.hidden=NO;
        saveButton.hidden=YES;
        deleteButton.hidden=YES;
        [privateShareBtn setImage:[UIImage imageNamed:@"radio_selected.png"] forState:UIControlStateNormal];
        [publicShareBtn setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
        shareWith=@0;
    }
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self addCustomNavigationBar];
    
    //get the user id from nsuserDefaults
    
    
}
-(void)getCollectionDetail
{
    webServices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
    [webServices call:dicData controller:@"collection" method:@"get"];
    
}
//get PhotoId From Server
-(void)getPhotoIdFromServer
{
    @try {
        isGetPhotoIdFromServer=YES;
        
        webServices.delegate=self;
        // NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_id=%d",[NSNumber numberWithInt:usrId],self.collectionId];
        NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
        
        [webServices call:dicData controller:@"collection" method:@"get"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

//search user for share With option
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [searchView removeFromSuperview];
    
    
    
    if (textField.tag==1102&&textField.text.length>=2) {
        isSearchUserList=YES;
        NSLog(@"Text is %@",textField.text);
        selectedWriteUserId=@"";
        isShareForWritingWith=YES;
    }
    else if (textField.tag==1103&&textField.text.length>=2) {
        isSearchUserList=YES;
        NSLog(@"Text is %@",textField.text);
        selectetReadUserId=@"";
        isShareForReadingWith=YES;
    }
    if(isShareForReadingWith||isShareForWritingWith)
    {
        @try {
            webServices.delegate=self;
            NSDictionary *dicData=@{@"user_id":userid,@"target_username":textField.text,@"target_user_emailaddress":@""};
            [webServices call:dicData controller:@"user" method:@"search"];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Exception is %@",exception.description);
        }
        @finally {
            
        }
    }
    
    
    return YES;
}

//set ccrollview content in center
// called when textField start editting.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
    if(textField.tag==1102)
    {
        [scrollView setContentOffset:CGPointMake(0,shareForWritingWithView.center.y-60) animated:YES];
    }
    else if(textField.tag==1103)
    {
        [scrollView setContentOffset:CGPointMake(0,shareForReadingWithView.center.y-60) animated:YES];
    }
}

// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [searchView removeFromSuperview];
    
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        if(textField.tag==1102)
        {
            [scrollView setContentOffset:CGPointMake(0,shareForWritingWithView.center.y-60) animated:YES];
        }
        else if(textField.tag==1103)
        {
            [scrollView setContentOffset:CGPointMake(0,shareForReadingWithView.center.y-60) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        [nextResponder becomeFirstResponder];
    } else {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
    }
    
    return NO;
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
    else if(btn.tag==102)
    {
        shareForWritingWith.text=@"";
        selectedWriteUserId=@"";
        [shareForWritingWith becomeFirstResponder];
    }
    else if(btn.tag==103)
    {
        shareForReadingWith.text=@"";
        selectetReadUserId=@"";
        [shareForReadingWith becomeFirstResponder];
    }
}


//Btn Action
-(IBAction)addFolder:(id)sender
{
    @try {
        [self addCollectionInfoInServer:folderName.text sharing:shareWith writeUserIds:selectedWriteUserId readUserIds:selectetReadUserId];
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
        
            [self editCollectionInfoInServer:self.collectionId collectionName:folderName.text sharing:shareWith writeUserIds:selectedWriteUserId readUserIds:selectetReadUserId];
        
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
    
        if(isGetPhotoIdFromServer)
        {
            if(exitCode ==1)
            {
            @try {
                NSDictionary *outputData=[data objectForKey:@"output_data"];
                NSDictionary *collectionContent=[outputData objectForKey:@"collection_contents"];
                if(collectionContent.count>0)
                {
                    [photoIdArray addObjectsFromArray:[collectionContent allKeys]];
                }
                

            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
         }
        isGetPhotoIdFromServer=NO;
        }
        else if (isSearchUserList)
        {
            if(exitCode ==1)
            {
                [searchView removeFromSuperview];
                NSArray *outPutData=[data objectForKey:@"output_data"];
                for (int i=0; i<outPutData.count; i++) {
                    [[outPutData objectAtIndex:i] objectForKey:@"user_username"];
                    NSLog(@"search user List %@", [[outPutData objectAtIndex:i] objectForKey:@"user_username"]);
                    
                    NSString *resultName=[NSString stringWithFormat:@"%@ (%@)",[[outPutData objectAtIndex:i] objectForKey:@"user_username"],[[outPutData objectAtIndex:i] objectForKey:@"user_realname"]];
                    
                    if (isShareForWritingWith)
                    {
                        searchView.frame=CGRectMake(shareForWritingWithView.frame.origin.x, shareForWritingWithView.frame.origin.y+35, shareForWritingWithView.frame.size.width, 30);
                        selectedWriteUser=resultName;
                        selectedWriteUserId=[[outPutData objectAtIndex:i] objectForKey:@"user_id"];
                        
                        searchList.frame=CGRectMake(0, 5, shareForWritingWithView.frame.size.width, 20);
                        searchList.tag=1110;
                        [searchList.titleLabel setFont:[UIFont fontWithName:@"verdana" size:13]];
                        searchList.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
                        [searchList addTarget:self action:@selector(selctUserList:) forControlEvents:UIControlEventTouchUpInside];
                        [searchList setTitle:resultName forState:UIControlStateNormal];
                        [searchList setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        
                        [searchView addSubview:searchList];
                        [scrollView addSubview:searchView];
                    }
                    else if(isShareForReadingWith)
                    {
                        searchView.frame=CGRectMake(shareForReadingWithView.frame.origin.x, shareForReadingWithView.frame.origin.y+35, shareForReadingWithView.frame.size.width, 30);
                        selectetReadUser=resultName;
                        selectetReadUserId=[[outPutData objectAtIndex:i] objectForKey:@"user_id"];
                        
                        searchList.frame=CGRectMake(0, 5, shareForReadingWithView.frame.size.width, 20);
                        searchList.tag=1111;
                        [searchList.titleLabel setFont:[UIFont fontWithName:@"verdana" size:13]];
                        searchList.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;                    [searchList addTarget:self action:@selector(selctUserList:) forControlEvents:UIControlEventTouchUpInside];
                        [searchList setTitle:resultName forState:UIControlStateNormal];
                        [searchList setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                        
                        [searchView addSubview:searchList];
                        [scrollView addSubview:searchView];
                       
                    }
                }
            }
            isShareForWritingWith=NO;
            isShareForReadingWith=NO;
            isSearchUserList=NO;
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
-(void)selctUserList: (id)sender
{
   
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==1110)
    {
        shareForWritingWith.text=selectedWriteUser;
    }
    else if (btn.tag==1111)
    {
        shareForReadingWith.text=selectetReadUser;
    }
     [searchView removeFromSuperview];
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
