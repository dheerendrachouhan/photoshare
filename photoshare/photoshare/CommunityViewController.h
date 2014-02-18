//
//  CommunityViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "WebserviceController.h"
#import "DataMapperController.h"
@class CollectionViewCell;
@interface CommunityViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource, UINavigationControllerDelegate,WebserviceDelegate>
{
    IBOutlet UICollectionView *collectionview;
    UIButton *addFolderBtn;
    IBOutlet UIProgressView *progressView;
    IBOutlet UILabel *diskSpaceTitle;
    CollectionViewCell *obj_Cell;
  
    NSMutableArray *collectionArrayWithSharing;
    //collection Info Array
    NSMutableArray *collectionDefaultArray;
    NSMutableArray *collectionIdArray;
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionSharingArray;
    NSMutableArray *collectionSharedArray;
    NSMutableArray *collectionUserIdArray;
    
    WebserviceController *webservices;
        
    ContentManager *manager;
    DataMapperController *dmc;
    UIButton *editBtn;
    NSNumber *userid;

    UIActivityIndicatorView *indicator;
    BOOL isGetStorage;
    BOOL isGetCollectionInfo;
    BOOL isGetTheOwnCollectionListData;
    BOOL isGetTheSharingCollectionListData;
    int countSharing;
    //for sharing detail get
    BOOL isGetSharingUserId;
    NSMutableArray *sharingIdArray;
    
}
@property (nonatomic,assign)BOOL isInNavigation;

@end
