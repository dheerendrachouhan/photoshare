//
//  PhotoViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "DataMapperController.h"
#import "WebserviceController.h"
//for Aviary
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"
#import "AFOpenGLManager.h"
#import "DataMapperController.h"

@interface PhotoViewController : UIViewController
<WebserviceDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionIdArray;
    
    NSNumber *selectedCollectionId;
    NSData *imgData;
    UIPickerView *categoryPickerView;
    UIToolbar *pickerToolbar;
    
    NSNumber *userid;
    DataMapperController *dmc;
    
    ContentManager *manager;
    
    WebserviceController *webservices;
    
    UIImage *pickImage;
    BOOL isCameraMode;
    BOOL isCameraEditMode;
    
    UIImage *originalImage;
    BOOL isoriginalImageGet;
    IBOutlet UIImageView *imageView;
    
    IBOutlet UILabel *folderLocationShowLabel;
    
}
- (IBAction)segmentSwitch:(id)sender;
//for Aviary

@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,assign)int selectedIndex;
@property(nonatomic,retain)UIImage *smallImage;
@property(nonatomic,retain)NSString *folderNameLocation;
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;
@property(nonatomic,assign)BOOL isViewPhoto;
@end

