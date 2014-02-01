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

//for Aviary
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"
#import "AFOpenGLManager.h"

@interface PhotoGalleryViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,AFPhotoEditorControllerDelegate,WebserviceDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
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
    
    NSNumber *userid;
    NSArray *sortedArray;
    NSMutableArray *photoIdsArray;
    NSMutableArray *photoArray;
    NSMutableArray *photoInfoArray;
    
    BOOL isDeleteMode;
    BOOL isShareMode;
    
    BOOL isGetPhotoIdFromServer;
    BOOL isGetPhotoFromServer;
    BOOL isSaveDataOnServer;
    
    BOOL isEditImageFromServer;
    BOOL isNotFirstTime;
    BOOL isAviaryMode;
    int deleteImageCount;
    
    BOOL isPopFromPhotos;
    
    NSString *assetUrlOfImage;
    
    UIActivityIndicatorView *indicator;
    
    NSMutableArray *photoAssetUrlArray;
}
@property(nonatomic,assign)BOOL isPublicFolder;
@property(nonatomic,assign)int selectedFolderIndex;

@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,assign)int userID;

@property(nonatomic,retain)ALAssetsLibrary *library;
@property(nonatomic,retain)NSString *folderName;

//for Aviary
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;

-(IBAction)addPhoto:(id)sender;
-(IBAction)deletePhoto:(id)sender;
-(IBAction)sharePhoto:(id)sender;
@end
