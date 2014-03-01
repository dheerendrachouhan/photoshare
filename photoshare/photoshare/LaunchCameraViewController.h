//
//  LaunchCameraViewController.h
//  photoshare
//
//  Created by ignis2 on 03/02/14.
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
#import "NavigationBar.h"
#import <CoreLocation/CoreLocation.h>
@interface LaunchCameraViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WebserviceDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate,UITabBarDelegate,CLLocationManagerDelegate,UITextViewDelegate,UIPopoverControllerDelegate>
{
    //get the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionIdArray;
    
    NSNumber *publicCollectionId;
    NSNumber *selectedCollectionId;
    NSData *imgData;
    IBOutlet UIPickerView *categoryPickerView;
    UIToolbar *pickerToolbar;
    
     NSNumber *userid;
    DataMapperController *dmc;
    
    ContentManager *manager;
    
    WebserviceController *webservices;
    
    UIImage *pickImage;
    BOOL isCameraMode;
    BOOL isCameraEditMode;
    
    BOOL isPhotoSavingMode;
    BOOL isColletionCreateMode;
    BOOL isAddNewFolderMode;
    
    IBOutlet UIImageView *imgView;
    //fore new folder create when pick image
    UIView *backView1;
    UIView *backView2;
    UITextField *folderName;
    UIButton *addNewFolder;
    
    //for add photo Detail
    UIView *backViewPhotDetail;
    UITextField *photoTitleTF;
    UITextView *photoDescriptionTF;
    UITextField *phototagTF;
    
    NSString *photoTitleStr;
    NSString *photoDescriptionStr;
    NSString *photoTagStr;
    NSString *photoLocationStr; //userLoaction is save
    
    UIInterfaceOrientation orientation;
    
    UIView *addFolderView;
    
}

//for Aviary
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;

@property (nonatomic,assign)BOOL isFromHomePage;

//for popover
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, assign) BOOL shouldReleasePopover;

@end
