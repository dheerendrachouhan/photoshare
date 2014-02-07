//
//  GetUserLocation.h
//  photoshare
//
//  Created by ignis2 on 07/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol LocationManagerDelegate <NSObject>

-(void)getLocation :(NSString *)currentLocation;

@end
@interface GetUserLocation : UIViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
-(void)callGetLocation;
@property(nonatomic,retain) id<LocationManagerDelegate> delegate;
@end
