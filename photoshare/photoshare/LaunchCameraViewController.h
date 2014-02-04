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
@interface LaunchCameraViewController : UIViewController<UIImagePickerControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,WebserviceDelegate,AFPhotoEditorControllerDelegate,UINavigationControllerDelegate>
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
    
    
}

//for Aviary
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray * sessions;
@end
