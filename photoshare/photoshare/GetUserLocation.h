//
//  GetUserLocation.h
//  photoshare
//
//  Created by ignis2 on 07/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol GetUserLocationDelegate<NSObject>

-(void)CallBackLocation :(NSString *)currentLocation;

@end
@interface GetUserLocation : UIViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
-(void)callGetLocation;
@property(nonatomic,retain) id<GetUserLocationDelegate> delegate;
@end
