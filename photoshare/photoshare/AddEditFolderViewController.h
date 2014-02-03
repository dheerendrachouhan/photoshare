//
//  AddFolderViewController.h
//  photoshare
//
//  Created by ignis2 on 24/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "ContentManager.h"

@interface AddEditFolderViewController : UIViewController<UITextFieldDelegate,UINavigationBarDelegate, UINavigationControllerDelegate,WebserviceDelegate,UIAlertViewDelegate>
{
    IBOutlet UILabel *headingLabel;
    IBOutlet UIView *folderNameView;
    IBOutlet UIView *shareForWritingWithView;
    IBOutlet UIView *shareForReadingWithView;
    IBOutlet UIButton *addButton;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UITextField *folderName;
    IBOutlet UITextField *shareForWritingWith ;
    IBOutlet UITextField *shareForReadingWith ;
    
    NSNumber *userid;
    ContentManager *manager;
    WebserviceController *webServices;
    NSNumber *newCollectionId;
    
    BOOL isAdd;
    BOOL isSave;
    BOOL isDelete;
    BOOL isSearchUserList;
    BOOL isShareForWritingWith;
    BOOL isShareForReadingWith;
    
    NSString *selectedWriteUser;
    NSString *selectetReadUser;
    
    NSString *selectedWriteUserId;
    NSString *selectetReadUserId;
    UIButton *searchList;
    NSNumber *shareWith;
   
    NSMutableArray *searchUserList;
    IBOutlet UIButton *privateShareBtn;
    IBOutlet UIButton *publicShareBtn;
}

@property(nonatomic,assign)BOOL isAddFolder;
@property(nonatomic,assign)BOOL isEditFolder;
@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,retain)NSString *setFolderName;
@property(nonatomic,assign)NSNumber *collectionShareWith;

-(IBAction)clearTextField:(id)sender;
-(IBAction)addFolder:(id)sender;
-(IBAction)saveFolder:(id)sender;
-(IBAction)deleteFolder:(id)sender;


-(IBAction)shareWithUser:(id)sender;
@end
