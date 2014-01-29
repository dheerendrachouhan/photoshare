//
//  CommunityViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
@class CollectionViewCell;
@interface CommunityViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource, UINavigationControllerDelegate,WebserviceDelegate>
{
    IBOutlet UICollectionView *collectionview;
    UIButton *addFolderBtn;
    IBOutlet UIProgressView *progressView;
    IBOutlet UILabel *diskSpaceTitle;
    CollectionViewCell *obj_Cell;
    
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionIdArray;
    NSMutableArray *collectionDefaultArray;
    NSMutableArray *collectionSharingArray;
    NSMutableArray *collectionSharedArray;
    
    
    int noOfPagesInCollectionView;
    WebserviceController *webServices;
    
    UIButton *editBtn;
    int userID;

    UIActivityIndicatorView *indicator;
    BOOL isGetStorage;
    BOOL isGetCollectionInfo;
}

@end
