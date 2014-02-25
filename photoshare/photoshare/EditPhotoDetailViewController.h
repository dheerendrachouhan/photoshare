//
//  EditPhotoDetailViewController.h
//  photoshare
//
//  Created by ignis2 on 06/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "ContentManager.h"
#import <CoreLocation/CoreLocation.h>

@interface EditPhotoDetailViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate,WebserviceDelegate,UIScrollViewDelegate>
{
    //get the userf location
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    IBOutlet UITextField *photoTitletxt;
   
    IBOutlet UITextView *photoDescriptionTxt;
    IBOutlet UITextField *photoTag;
    
    IBOutlet UILabel *headingLabel;
    IBOutlet UIButton *saveButton;
    IBOutlet UIScrollView *scrollView;
    
    NSNumber *userid;
    ContentManager *manager;
    WebserviceController *webservices;
    BOOL isPhotoDetailSaveOnServer;
    
    NSString *photoLocationString;
    
    //check orientation
    UIInterfaceOrientation orientation;
}
-(IBAction)savePhotoDetail:(id)sender;


@property(nonatomic,assign)BOOL isFromLaunchCamera;
@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,retain)NSNumber *collectionId;
@property(nonatomic,assign)int selectedIndex;

@end
