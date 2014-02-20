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

#import <CoreLocation/CoreLocation.h>

@interface PhotoViewController : UIViewController
<WebserviceDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate,UITextFieldDelegate,UITextViewDelegate,CLLocationManagerDelegate>
{
    
    //get the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
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
    
    BOOL isSavePhotoOnServer;
    
    UIImage *pickImage;
    BOOL isCameraMode;
    BOOL isCameraEditMode;
    
    BOOL isPhotoOwner;
    
    UIImage *originalImage;
    BOOL isoriginalImageGet;
    IBOutlet UIImageView *imageView;
    IBOutlet UISegmentedControl *segmentControl;
    IBOutlet UILabel *folderLocationShowLabel;
    IBOutlet UIButton *photoViewBtn;
    //for add photo Detail
    UIView *backViewPhotDetail;
    UITextField *photoTitleTF;
    UITextView *photoDescriptionTF;
    UITextField *phototagTF;
    
    NSString *photoTitleStr;
    NSString *photoDescriptionStr;
    NSString *photoTagStr;
    NSString *photoLocationStr; //userLoaction is save
}
- (IBAction)segmentSwitch:(id)sender;
- (IBAction)viewPhoto:(id)sender;
//for Aviary

@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,assign)NSNumber *collectionId;
@property(nonatomic,assign)NSNumber *collectionOwnerId;
@property(nonatomic,assign)NSNumber *photoOwnerId;
@property(nonatomic,assign)int selectedIndex;
@property(nonatomic,retain)UIImage *smallImage;
@property(nonatomic,retain)NSString *folderNameLocation;
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;
@property(nonatomic,assign)BOOL isViewPhoto;
@property(nonatomic,assign)BOOL isPublicFolder;
@property(nonatomic,assign)BOOL isOnlyReadPermission;

@end

