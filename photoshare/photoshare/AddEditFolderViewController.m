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

@synthesize isAddFolder,isEditFolder,folderIndex;
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
        ContentManager *contantManagerObj=[ContentManager sharedManager];
        folderName.text=[[contantManagerObj getData:@"FolderArray"] objectAtIndex:self.folderIndex];
        
    }
    else if(isAddFolder)
    {
        headingLabel.text=@"New Folder";
        addButton.hidden=NO;
        saveButton.hidden=YES;
        deleteButton.hidden=YES;
    }
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
    [self storeCollectionInfoInServer:folderName.text sharing:1 writeUserIds:@"1,2" readUserIds:@"1,3"];
    
    
    /*UIAlertView *alert=[self alertView];
    
    ContentManager *contentManagerObj=[ContentManager sharedManager];
    NSMutableArray *folderArray=[[NSMutableArray alloc] init];
    //folderArray=[[contentManagerObj getData:@"FolderArray"] mutableCopy];

    
    if([folderArray containsObject:@"folderName.text"])
    {
       alert.message=@"Folder Already Available";
    }
    else
    {
        [folderArray addObject:folderName.text];
        NSLog(@"Folder Array %@",folderArray);
        [contentManagerObj storeData:folderArray :@"FolderArray"];
        NSLog(@"Folder Array %@",[contentManagerObj getData:@"FolderArray"]);
        alert.message=@"Successfully Added";
    }
    folderName.text=@"";
    shareWithUser.text=@"";
    
    [alert show];*/
}
-(IBAction)saveFolder:(id)sender
{
    ContentManager *contentManagerObj=[ContentManager sharedManager];
    NSMutableArray *folderArray=[[NSMutableArray alloc] init];
    folderArray=[[contentManagerObj getData:@"FolderArray"] mutableCopy];
    [folderArray replaceObjectAtIndex:self.folderIndex withObject:folderName.text];
    [contentManagerObj storeData:folderArray :@"FolderArray"];
    
    UIAlertView *alert=[self alertView];
    alert.message=@"Folder Save Successfully";
     [alert show];
}
-(IBAction)deleteFolder:(id)sender
{
    ContentManager *contentManagerObj=[ContentManager sharedManager];
    NSMutableArray *folderArray=[[NSMutableArray alloc] init];
    folderArray=[[contentManagerObj getData:@"FolderArray"] mutableCopy];
    [folderArray removeObjectAtIndex:self.folderIndex];
    [contentManagerObj storeData:folderArray :@"FolderArray"];
    
    UIAlertView *alert=[self alertView];
    alert.message=@"Folder Deleted";
     [alert show];
}
//alert delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0&&[alertView.message isEqualToString:@"Successfully Added"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(buttonIndex==0&&[alertView.message isEqualToString:@"Folder Deleted"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(buttonIndex==0&&[alertView.message isEqualToString:@"Folder Save Successfully"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//store collection info in server
-(void)storeCollectionInfoInServer:(NSString *)collectionName sharing:(int)sharing writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
    WebserviceController *webService=[[WebserviceController alloc] init];
    webService.delegate=self;
    //get the user id from nsuserDefaults
    ContentManager *manager=[ContentManager sharedManager];
    NSNumber *userId=[manager getData:@"user_id"];
    //store data
    NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_name=%@&collection_sharing=%d&collection_write_user_ids=%@&collection_read_user_ids=%@",[userId intValue],collectionName,sharing,writeUserIds,readUserIds];
    
    [webService call:data controller:@"collection" method:@"store"];
    
}
//call back Method
-(void)webserviceCallback:(NSString *)data
{
    NSLog(@"Collection return %@",data);
    NSDictionary *JSON =
    [NSJSONSerialization JSONObjectWithData: [data dataUsingEncoding:NSUTF8StringEncoding]                                    options: NSJSONReadingMutableContainers error: Nil];
    
    ContentManager *manager=[ContentManager sharedManager];
    if([[JSON objectForKey:@"user_message"] isEqualToString:@"Collection Created."])
    {
        [manager showAlert:@"New Folder" msg:@"Successfully Added" cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
    else
    {
        [manager showAlert:@"New Folder" msg:@"You already have a Folder with that name." cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
