//
//  PhotoGalleryViewController.h
//  photoshare
//
//  Created by ignis2 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoGalleryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UIButton *addPhotoBtn;
    IBOutlet UIButton *deletePhotoBtn;
    IBOutlet UIButton *sharePhotoBtn;
    IBOutlet UICollectionView *collectionview;
    NSMutableArray *imgArray;
    BOOL isDeleteMode;
}
@property(nonatomic,assign)BOOL isPublicFolder;
@property(nonatomic,assign)int selectedFolderIndex;
-(IBAction)addPhoto:(id)sender;
-(IBAction)deletePhoto:(id)sender;
-(IBAction)sharePhoto:(id)sender;
@end
