//
//  SearchPhotoViewController.h
//  photoshare
//
//  Created by ignis2 on 13/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"
#import "WebserviceController.h"

@interface SearchPhotoViewController : UIViewController<UISearchBarDelegate,WebserviceDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
{
    IBOutlet UISearchBar *searchBarForPhoto;
    IBOutlet UICollectionView *collectionViewForPhoto;
    
    WebserviceController *webservice;
    ContentManager *manager;
    NSNumber *userid;
    NSString *searchString;
    
    int photoCount;
    NSArray *searchResultArray;
    NSMutableArray *photoArray;
    NSMutableArray *photDetailArray;
    BOOL isSearchPhoto;
    BOOL isGetPhotoFromServer;
    BOOL isGetOriginalPhotoFromServer;
    
    BOOL isPopFromSearchPhoto;
    
    UIImageView *imgView1;
}

@end
