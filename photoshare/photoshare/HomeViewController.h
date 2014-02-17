//
//  HomeViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebserviceController.h"
#import "DataMapperController.h"
#import "ContentManager.h"

@protocol homeDelagate <NSObject>

-(void)earningView;

@end
@class ContentManager;
@interface HomeViewController : UIViewController<WebserviceDelegate>
{
    
    IBOutlet UIButton *totalEarningBtn;
    IBOutlet UIImageView *profilePicImgView;
    IBOutlet UILabel *welcomeName;
    IBOutlet UILabel *photoCountLbl;
    
    UINavigationController *navController;
    
    NSNumber *publicCollectionId;
    NSNumber *colOwnerId;
    int folderIndex;
    
    ContentManager *manager;    
    NSNumber *userid;
    WebserviceController *webservices;
    DataMapperController *dmc ;
    
}
@property(nonatomic,retain) id<homeDelagate>delegate;

-(IBAction)takePhoto:(id)sender;
-(IBAction)goToCommunity:(id)sender;
-(IBAction)goToPublicFolder:(id)sender;


@end
