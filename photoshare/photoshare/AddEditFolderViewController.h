//
//  AddFolderViewController.h
//  photoshare
//
//  Created by ignis2 on 24/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEditFolderViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UILabel *headingLabel;
    IBOutlet UIView *folderNameView;
    IBOutlet UIView *shareWithUserView;
    IBOutlet UIButton *addButton;
    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *deleteButton;
    IBOutlet UITextField *folderName;
    IBOutlet UITextField *shareWithUser;
    
}

@property(nonatomic,assign)BOOL isAddFolder;
@property(nonatomic,assign)BOOL isEditFolder;
@property(nonatomic,assign)int folderIndex;

-(IBAction)clearTextField:(id)sender;
-(IBAction)addFolder:(id)sender;
-(IBAction)saveFolder:(id)sender;
-(IBAction)deleteFolder:(id)sender;
@end
