//
//  AddFolderViewController.m
//  photoshare
//
//  Created by ignis2 on 24/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "AddEditFolderViewController.h"
#import "CommonTopView.h"
@interface AddEditFolderViewController ()

@end

@implementation AddEditFolderViewController

@synthesize isAddFolder,isEditFolder;
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
    
    //add Commpn top view
    CommonTopView *topView=[[CommonTopView alloc] init];
    [self.view addSubview:topView];
    
    
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
-(IBAction)addFolder:(id)sender
{
    
}
-(IBAction)saveFolder:(id)sender
{
    
}
-(IBAction)deleteFolder:(id)sender
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
