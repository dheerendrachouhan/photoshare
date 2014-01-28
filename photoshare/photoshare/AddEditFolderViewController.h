//
//  AddFolderViewController.h
//  photoshare
//
//  Created by ignis2 on 24/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
@interface AddEditFolderViewController : UIViewController<UITextFieldDelegate,UINavigationBarDelegate, UINavigationControllerDelegate,WebserviceDelegate>
{
    IBOutlet UILabel *headingLabel;
    IBOutlet UIView *folderNameView;
    IBOutlet UIView *shareWithUserView;
    IBOutlet UIButton *addButton;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UITextField *folderName;
    IBOutlet UITextField *shareWithUser;
    
    int userID;
    WebserviceController *webServices;
}

@property(nonatomic,assign)BOOL isAddFolder;
@property(nonatomic,assign)BOOL isEditFolder;
@property(nonatomic,assign)NSInteger collectionId;
@property(nonatomic,retain)NSString *setFolderName;

-(IBAction)clearTextField:(id)sender;
-(IBAction)addFolder:(id)sender;
-(IBAction)saveFolder:(id)sender;
-(IBAction)deleteFolder:(id)sender;
@end
