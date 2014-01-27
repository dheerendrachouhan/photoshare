//
//  CommunityViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CollectionViewCell;
@interface CommunityViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource, UINavigationControllerDelegate>
{
    IBOutlet UICollectionView *collectionview;
    UIButton *addFolderBtn;
    IBOutlet UILabel *diskSpaceTitle;
    IBOutlet UILabel *diskSpaceBlueLabel;
        
    CollectionViewCell *obj_Cell;
    NSMutableArray *folderNameArray;
    int noOfPagesInCollectionView;
    CGRect blueLabelImgFrame;
}

@end
