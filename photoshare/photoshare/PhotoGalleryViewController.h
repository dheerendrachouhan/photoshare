//
//  PhotoGalleryViewController.h
//  photoshare
//
//  Created by ignis2 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WebserviceController.h"
@interface PhotoGalleryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,WebserviceDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UIButton *addPhotoBtn;
    IBOutlet UIButton *deletePhotoBtn;
    IBOutlet UIButton *sharePhotoBtn;
    IBOutlet UICollectionView *collectionview;
    WebserviceController *webServices;
    UIButton *editBtn;
    
    NSMutableArray *imgArray;
    NSMutableArray *selectedImagesIndex;
    NSString *refrenceUrlofImg;
    CGRect frameForShareBtn;
    
    int userID;
    
    BOOL isDeleteMode;
    BOOL isShareMode;
    
    BOOL isGetPhotoFromServer;
    BOOL isSaveDataOnServer;
}
@property(nonatomic,assign)BOOL isPublicFolder;
@property(nonatomic,assign)int selectedFolderIndex;
@property(nonatomic,retain)ALAssetsLibrary *library;
@property(nonatomic,retain)NSString *folderName;
-(IBAction)addPhoto:(id)sender;
-(IBAction)deletePhoto:(id)sender;
-(IBAction)sharePhoto:(id)sender;
@end
