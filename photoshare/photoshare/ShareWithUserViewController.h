//
//  ShareWithUserViewController.h
//  photoshare
//
//  Created by ignis2 on 10/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "WebserviceController.h"
@interface ShareWithUserViewController : UIViewController<WebserviceDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate>
{
    IBOutlet UITextField *searchUserTF;
    IBOutlet UIButton *userAddButton;
    IBOutlet UIButton *saveBtn;
    IBOutlet UICollectionView *sharingUserListCollView;
    IBOutlet UIView *shareSearchView;
    ContentManager *manager;
    WebserviceController *webservices;
    
    NSNumber *userid;
    
    BOOL isGetSharingWriteUserName;
    BOOL isGetSharingReadUserName;
    BOOL isGetCollectionDetails;
    BOOL isSearchUserList;
    BOOL isShareForWritingWith;
    BOOL isShareForReadingWith;

    NSNumber *selectedUserId;
    NSString *selecteduserName;
    
   
    NSMutableArray *searchUserListResult;
    NSMutableArray *searchUserIdResult;
    UIButton *searchList;
    NSNumber *shareWith;
    
    NSMutableDictionary *collectionDetail;
    NSMutableArray *searchUserList;
    
    NSArray *writeuseridarray;
    NSArray *readuseridarray;
    NSMutableArray *sharingUserNameArray;
    NSMutableArray *sharingUserIdArray;
    
    UIView *searchView;

}
@property(nonatomic,assign)BOOL isEditFolder;
@property(nonatomic,assign)BOOL isWriteUser;
@property(nonatomic,assign)NSNumber *collectionId;
-(IBAction)addUserInSharing:(id)sender;
-(IBAction)saveSharingUser:(id)sender;
@end
