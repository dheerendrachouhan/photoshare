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
@interface EditPhotoDetailViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField *photoTitletxt;
    IBOutlet UITextField *photoTagTxt;
    IBOutlet UITextField *photoDescriptionTxt;
    IBOutlet UITextField *photoLocationTxt;
    
    IBOutlet UILabel *headingLabel;
    IBOutlet UIButton *saveButton;
    
    NSNumber *userid;
    ContentManager *manager;
    WebserviceController *webservices;
    BOOL isPhotoDetailSaveOnServer;
}
-(IBAction)savePhotoDetail:(id)sender;

@property(nonatomic,retain)NSNumber *photoId;
@property(nonatomic,retain)NSNumber *collectionId;
@property(nonatomic,retain)NSDictionary *photoDetail;

@end
