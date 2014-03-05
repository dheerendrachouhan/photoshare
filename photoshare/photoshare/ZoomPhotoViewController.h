//
//  ZoomPhotoViewController.h
//  photoshare
//
//  Created by ignis2 on 28/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomPhotoViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
   
}
@property (nonatomic,retain) IBOutlet UIImageView *imgView;
@property (nonatomic,retain) IBOutlet UIScrollView *scrollViewForImage;
@property(nonatomic,retain)UIImage *image;
@end
