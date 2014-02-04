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
   
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    searchList=[[UIButton alloc] init];
    
    //contant manager Object
    manager = [ContentManager sharedManager];
    webServices=[[WebserviceController alloc] init];
    
    
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
//search user for share With option
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==1102&&textField.text.length>=2) {
        NSLog(@"Text is %@",textField.text);
        isSearchUserList=YES;
        isShareForReadingWith=NO;
        isShareForWritingWith=YES;
        
        webServices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid,@"target_username":textField.text,@"target_user_emailaddress":@""};
        [webServices call:dicData controller:@"user" method:@"search"];
    }
    else if (textField.tag==1103&&textField.text.length>=2) {
        NSLog(@"Text is %@",textField.text);
        isSearchUserList=YES;
        isShareForWritingWith=NO;
        isShareForReadingWith=YES;
        
        webServices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid,@"target_username":textField.text,@"target_user_emailaddress":@""};
        [webServices call:dicData controller:@"user" method:@"search"];
    }
    return YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self addCustomNavigationBar];
    
    //get the user id from nsuserDefaults
    userid=[manager getData:@"user_id"];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
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
        [shareForWritingWith becomeFirstResponder];
    }
    else if(btn.tag==103)
    {
        shareForReadingWith.text=@"";
        [shareForReadingWith becomeFirstResponder];
    }
}

-(UIAlertView *)alertView
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
    return alert;
}

//Btn Action
-(IBAction)addFolder:(id)sender
{
    [self addCollectionInfoInServer:folderName.text sharing:shareWith writeUserIds:selectedWriteUserId readUserIds:selectetReadUserId];
}

-(IBAction)saveFolder:(id)sender
{
    [self editCollectionInfoInServer:self.collectionId collectionName:folderName.text sharing:shareWith writeUserIds:selectedWriteUserId readUserIds:selectetReadUserId];

}
-(IBAction)deleteFolder:(id)sender
{
    [self deleteCollectionInfoInServer];
    
}

-(IBAction)shareWithUser:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag==0)
    {
        [privateShareBtn setImage:[UIImage imageNamed:@"radio_selected.png"] forState:UIControlStateNormal];
        [publicShareBtn setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
        NSLog(@"");
        shareWith=@0;
    }
    else if(btn.tag==1)
    {
        [privateShareBtn setImage:[UIImage imageNamed:@"radio.png"] forState:UIControlStateNormal];
        [publicShareBtn setImage:[UIImage imageNamed:@"radio_selected.png"] forState:UIControlStateNormal];
        shareWith=@1;
    }
   
}

//reset all Bool Value
-(void)resetAllBOOLValue
{
    isAdd=NO;
    isSave=NO;
    isDelete=NO;
}



//store collection info in server
-(void)addCollectionInfoInServer:(NSString *)collectionName sharing:(NSNumber *)sharing writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
    [self resetAllBOOLValue];
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
    [self resetAllBOOLValue];
    isSave=YES;
    if(writeUserIds==Nil)
    {
        writeUserIds=@"";
    }
    if(readUserIds==Nil)
    {
        readUserIds=@"";
    }
    webServices.delegate=self;
    
    //edit data
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":collecId,@"collection_name":collectionName,@"collection_sharing":@"0",@"collection_write_user_ids":writeUserIds,@"collection_read_user_ids":readUserIds};
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
    [self resetAllBOOLValue];
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
    
    
    if(exitCode ==1)
    {
        if (isSearchUserList)
        {
            
            NSArray *outPutData=[data objectForKey:@"output_data"];
            for (int i=0; i<outPutData.count; i++) {
                [[outPutData objectAtIndex:i] objectForKey:@"user_username"];
                NSLog(@"search user List %@", [[outPutData objectAtIndex:i] objectForKey:@"user_username"]);
                if (isShareForWritingWith) {
                    selectedWriteUser=[[outPutData objectAtIndex:i] objectForKey:@"user_username"];
                    selectedWriteUserId=[[outPutData objectAtIndex:i] objectForKey:@"user_id"];
                    [searchList removeFromSuperview];
                    searchList.frame=CGRectMake(shareForWritingWithView.frame.origin.x, shareForWritingWithView.frame.origin.y+35*(i+1), shareForWritingWithView.frame.size.width, 25);
                    [searchList addTarget:self action:@selector(selctUserList:) forControlEvents:UIControlEventTouchUpInside];
                    [searchList setTitle:[NSString stringWithFormat:@"%@ (%@)",[[outPutData objectAtIndex:i] objectForKey:@"user_username"],[[outPutData objectAtIndex:i] objectForKey:@"user_realname"]] forState:UIControlStateNormal];
                    [searchList setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    searchList.layer.borderColor=[UIColor grayColor].CGColor;
                    searchList.layer.borderWidth=1;
    
                    [self.view addSubview:searchList];
                   
                    
                }
                else if(isShareForReadingWith)
                {
                    
                    selectetReadUser=[[outPutData objectAtIndex:i] objectForKey:@"user_username"];
                    selectetReadUserId=[[outPutData objectAtIndex:i] objectForKey:@"user_id"];
                    searchList.frame=CGRectMake(shareForReadingWithView.frame.origin.x, shareForReadingWithView.frame.origin.y+35*(i+1), shareForReadingWithView.frame.size.width, 25);
                    [searchList addTarget:self action:@selector(selctUserList:) forControlEvents:UIControlEventTouchUpInside];
                    [searchList setTitle:[NSString stringWithFormat:@"%@ (%@)",[[outPutData objectAtIndex:i] objectForKey:@"user_username"],[[outPutData objectAtIndex:i] objectForKey:@"user_realname"]] forState:UIControlStateNormal];
                    [searchList setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    searchList.layer.borderColor=[UIColor grayColor].CGColor;
                    searchList.layer.borderWidth=1;
                    [self.view addSubview:searchList];
                    
                   
                }
                
                
            }
            isSearchUserList=NO;
        }
        else
        {
            if(isAdd)
            {
                NSMutableArray *outPutData=[data objectForKey:@"output_data"];
                newCollectionId= [[outPutData objectAtIndex:0] objectForKey:@"collection_id"];
            }
            
            [self updateCollectionInfoInNSUserDefault];
            
            UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"Message" message:[data objectForKey:@"user_message"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alertView show];
        }
    }
    
    else
    {
        if(!isSearchUserList)
        {
             [manager showAlert:@"Message" msg:[data objectForKey:@"user_message"] cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
       
    }
    
}
-(void)selctUserList: (id)sender
{
   
    //UIButton *btn=(UIButton *)sender;
    if(isShareForReadingWith)
    {

        shareForReadingWith.text=selectetReadUser;
        isShareForReadingWith=NO;
    }
    else if (isShareForWritingWith)
    {
        shareForWritingWith.text=selectedWriteUser;
         isShareForWritingWith=NO;
    }
     [searchList removeFromSuperview];
}

//Update Collection info in NSUSerDefault
-(void)updateCollectionInfoInNSUserDefault
{
    NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];;
    
    if(isAdd)
    {
        NSMutableDictionary *newCollection=[[NSMutableDictionary alloc] init];
        
        [newCollection setValue:@0 forKey:@"collection_default"];
        [newCollection setValue:newCollectionId forKey:@"collection_id"];
        [newCollection setValue:folderName.text forKey:@"collection_name"];
        [newCollection setValue:@0 forKey:@"collection_shared"];
        [newCollection setValue:shareWith forKey:@"collection_sharing"];
        [newCollection setValue:userid forKey:@"collection_user_id"];
        
        ///[collection addObject:newCollection];
        @try {
             [collection insertObject:newCollection atIndex:2];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception name %@",exception.description);
        }
        @finally {
            
        }
       
        [manager storeData:collection :@"collection_data_list"];
       
        
    }
    else if(isSave||isDelete)
    {
        @try {
            int editColId=0;
            for (int i=2;i<collection.count; i++)
            {
                
                NSNumber *colId=[[collection objectAtIndex:i] objectForKey:@"collection_id"];
                if(colId==self.collectionId)
                {
                    editColId=i;
                    break;
                }
                
            }
            NSMutableDictionary *newCollection=[[NSMutableDictionary alloc] init];
            
            [newCollection setValue:@0 forKey:@"collection_default"];
            [newCollection setValue:self.collectionId forKey:@"collection_id"];
            [newCollection setValue:folderName.text forKey:@"collection_name"];
            [newCollection setValue:@0 forKey:@"collection_shared"];
            [newCollection setValue:shareWith forKey:@"collection_sharing"];
            [newCollection setValue:userid forKey:@"collection_user_id"];
            if(isSave)
            {
                [collection replaceObjectAtIndex:editColId withObject:newCollection];
            }
            else if (isDelete)
            {
                [collection removeObjectAtIndex:editColId];
            }
            
            [manager storeData:collection :@"collection_data_list"];
        }
        @catch (NSException *exception) {
            NSLog(@"exception is %@",exception.description);
        }
        @finally {
            
        }
        
    }
    
}
//alert Delegate Method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if(buttonIndex==0)
   {
       [self.navigationController popViewControllerAnimated:YES];
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
