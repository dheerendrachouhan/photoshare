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
#import "ContentManager.h"

@interface AddEditFolderViewController ()

@end

@implementation AddEditFolderViewController

@synthesize isAddFolder,isEditFolder,collectionId,setFolderName;
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
    
    
    //set the disign of the button , View and Label
    UIColor *tfBackViewBorderColor=[UIColor lightGrayColor];
    float tfBackViewBorderWidth=2;
    float tfBackViewCornerRadius=5;
    
    folderNameView.layer.borderWidth=tfBackViewBorderWidth;
    folderNameView.layer.cornerRadius=tfBackViewCornerRadius;
    folderNameView.layer.borderColor=tfBackViewBorderColor.CGColor;
    
    shareWithUserView.layer.borderWidth=tfBackViewBorderWidth;
    shareWithUserView.layer.cornerRadius=tfBackViewCornerRadius;
    shareWithUserView.layer.borderColor=tfBackViewBorderColor.CGColor;
    
    
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
    
    
    if(self.isEditFolder)
    {
        headingLabel.text=@"Edit Folder";
        addButton.hidden=YES;
        saveButton.hidden=NO;
        deleteButton.hidden=NO;
        
        folderName.text=self.setFolderName;
        
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
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.frame=CGRectMake(0, 70, 320,30);
    
     webServices=[[WebserviceController alloc] init];
    
    //get the user id from nsuserDefaults
    ContentManager *manager=[ContentManager sharedManager];
    userID=[[manager getData:@"user_id"] intValue];
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
        shareWithUser.text=@"";
        [shareWithUser becomeFirstResponder];
    }
}
-(UIAlertView *)alertView
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
    return alert;
}
-(IBAction)addFolder:(id)sender
{
    [self addCollectionInfoInServer:folderName.text sharing:1 writeUserIds:[NSString stringWithFormat:@"%d",userID] readUserIds:@""];
    
   
}

-(IBAction)saveFolder:(id)sender
{
   
    [self editCollectionInfoInServer:self.collectionId collectionName:folderName.text sharing:0 writeUserIds:[NSString stringWithFormat:@"%d",userID] readUserIds:@""];
}
-(IBAction)deleteFolder:(id)sender
{
    [self deleteCollectionInfoInServer:userID collecId:self.collectionId];
}

//store collection info in server
-(void)addCollectionInfoInServer:(NSString *)collectionName sharing:(int)sharing writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
   
    webServices.delegate=self;
    
    //store data
    NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_name=%@&collection_sharing=%d&collection_write_user_ids=%@&collection_read_user_ids=%@",userID,collectionName,sharing,writeUserIds,readUserIds];
    
    [webServices call:data controller:@"collection" method:@"store"];
    
}
-(void)editCollectionInfoInServer:(int)collecId collectionName:(NSString *)collectionName sharing:(int)sharing writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
   
    webServices.delegate=self;
    
    //edit data
    NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_id=%d&collection_name=%@&collection_sharing=%d&collection_write_user_ids=%@&collection_read_user_ids=%@",userID,collecId,collectionName,sharing,writeUserIds,readUserIds];
    
    [webServices call:data controller:@"collection" method:@"change"];
    
}
-(void)deleteCollectionInfoInServer:(int)userid collecId:(int)collecId
{
    webServices.delegate=self;
    
    //delete data
    NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_id=%d",userID,collecId];
    
    [webServices call:data controller:@"collection" method:@"delete"];
    
}
//call back Method
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Collection return %@",data);
   
    
    ContentManager *manager=[ContentManager sharedManager];
    NSLog(@"exit  %@",[data objectForKey:@"exit_code"]);
    int exitCode=[[data objectForKey:@"exit_code"] intValue];
    if(exitCode ==1)
    {
        [manager showAlert:@"Message" msg:[data objectForKey:@"user_message"] cancelBtnTitle:@"Ok" otherBtn:Nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    else
    {
        [manager showAlert:@"Message" msg:[data objectForKey:@"user_message"] cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
