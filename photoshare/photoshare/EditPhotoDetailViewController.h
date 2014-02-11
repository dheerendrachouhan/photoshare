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

@interface EditPhotoDetailViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,CLLocationManagerDelegate>
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
    
    NSNumber *userid;
    ContentManager *manager;
    WebserviceController *webservices;
    BOOL isPhotoDetailSaveOnServer;
    
    NSString *photoLocationString;
}
-(IBAction)savePhotoDetail:(id)sender;

@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,retain)NSNumber *collectionId;
@property(nonatomic,assign)int selectedIndex;

@end
