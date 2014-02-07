//
//  HomeViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"

//for Aviary
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "AFPhotoEditorController.h"
#import "AFPhotoEditorCustomization.h"
#import "AFOpenGLManager.h"
#import "DataMapperController.h"
#import "AFPhotoEditorController+InAppPurchase.h"

#import <CoreLocation/CoreLocation.h>
@protocol homeDelagate <NSObject>

-(void)earningView;

@end
@class ContentManager;
@interface HomeViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,AFPhotoEditorControllerDelegate,WebserviceDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,CLLocationManagerDelegate,UITextViewDelegate>
{
    //get the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    IBOutlet UIButton *totalEarningBtn;
    IBOutlet UIImageView *profilePicImgView;
    IBOutlet UILabel *welcomeName;
    IBOutlet UILabel *photoCountLbl;
    
    UINavigationController *navController;
    
    UIImagePickerController *imagePicker;
    ContentManager *objManager;
    
    NSNumber *userid;
    WebserviceController *webservices;
    NSString *assetUrlOfImage;
    DataMapperController *dmc ;
    
    UIImage *pickImage;
    BOOL isCameraMode;
    BOOL isCameraEditMode;
    
    BOOL isPhotoSavingMode;
    BOOL isColletionCreateMode;
    
    NSNumber *publicCollectionId;
    
    NSMutableArray *collectionNameArray;
    NSMutableArray *collectionIdArray;
    
    NSNumber *selectedCollectionId;
    NSData *imgData;
    UIPickerView *categoryPickerView;
    UIToolbar *pickerToolbar;
    
    //fore new folder create when pick image
    UIView *backView1;
    UIView *backView2;
    UITextField *folderName;
    
    
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
@property(nonatomic,retain) id<homeDelagate>delegate;

//for Aviary
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;

-(IBAction)takePhoto:(id)sender;
-(IBAction)goToCommunity:(id)sender;
-(IBAction)goToPublicFolder:(id)sender;


@end
