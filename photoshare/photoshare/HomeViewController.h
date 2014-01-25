//
//  HomeViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol homeDelagate <NSObject>

-(void)earningView;

@end
@interface HomeViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UINavigationBarDelegate>
{
    IBOutlet UIButton *totalEarningBtn;
    IBOutlet UIImageView *profilePicImgView;
    IBOutlet UILabel *welcomeName;
    IBOutlet UILabel *communityCountLbl;
    
    UINavigationController *navController;
    
    UIImagePickerController *imagePicker;
}
@property(nonatomic,retain) id<homeDelagate>delegate;
-(IBAction)goToTotalEarning:(id)sender;
-(IBAction)takePhoto:(id)sender;
-(IBAction)goToCommunity:(id)sender;
-(IBAction)goToPublicFolder:(id)sender;
-(IBAction)gotoPhotos:(id)sender;
-(void)earnigView;
@end
