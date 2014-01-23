//
//  CommunityViewController.h
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommunityViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>
{
    IBOutlet UICollectionView *collectionview;
    UIButton *addFolderBtn;
    IBOutlet UILabel *diskSpaceTitle;
    IBOutlet UILabel *diskSpaceBlueLabel;

}
-(IBAction)backToView:(id)sender;
@end
