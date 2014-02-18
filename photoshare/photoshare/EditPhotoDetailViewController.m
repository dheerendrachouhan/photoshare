//
//  EditPhotoDetailViewController.m
//  photoshare
//
//  Created by ignis2 on 06/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditPhotoDetailViewController.h"
#import "NavigationBar.h"
#import "PhotoViewController.h"

@interface EditPhotoDetailViewController ()

@end

@implementation EditPhotoDetailViewController
@synthesize photoId,collectionId,selectedIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    manager=[ContentManager sharedManager];
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    photoLocationString=@"";
    [self addCustomNavigationBar];
    [self callGetLocation];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //initialize the WebService Object
    webservices=[[WebserviceController alloc] init];
    
    
    userid =[manager getData:@"user_id"];
    
    //set text fielddelegate
    [photoTitletxt setDelegate:self];
    [photoDescriptionTxt setDelegate:self];
    [photoTag setDelegate:self];
    
    photoDescriptionTxt.layer.borderWidth=0.3;
    if([manager isiPad])
    {
        photoDescriptionTxt.layer.borderWidth=0.8;
    }
    photoDescriptionTxt.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    saveButton.layer.cornerRadius=4;
    saveButton.layer.borderColor=btnBorderColor.CGColor;
    saveButton.layer.borderWidth=1;
    
    
    
    @try {
         NSArray *photoDetail=[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]];
        photoTitletxt.text=[[photoDetail  objectAtIndex:self.selectedIndex] objectForKey:@"collection_photo_title"];
        photoDescriptionTxt.text=[[photoDetail  objectAtIndex:self.selectedIndex] objectForKey:@"collection_photo_description"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   
    //tap getsure on view for dismiss the keyboard
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
-(void)savePhotoDetailOnServer
{
    isPhotoDetailSaveOnServer=YES;
    
    //savePhotoDetailONTempArray
    
    /*
     "collection_photo_added_date" = "2014-02-06 22:59:43";
     "collection_photo_description" = "no dec";
     "collection_photo_filesize" = 1360015;
     "collection_photo_id" = 439;
     "collection_photo_title" = "my photo";
     "collection_photo_user_id" = 11;     */
   
    
    NSString *photodes=photoDescriptionTxt.text;
   
    NSString *photoTitle=photoTitletxt.text;
    if(photodes.length==0)
    {
       photodes=@"";
    }
    if(photoTitle.length==0)
    {
        photoTitle=@"";
    }
    @try {
        
        NSMutableArray *photoinfoarray=[NSKeyedUnarchiver unarchiveObjectWithData:[[manager getData:@"photoInfoArray"] mutableCopy]];
        
        NSDictionary *photoDetail=[photoinfoarray objectAtIndex:self.selectedIndex];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:[photoDetail objectForKey:@"collection_photo_added_date"] forKey:@"collection_photo_added_date"];
        [dic setObject:photodes forKey:@"collection_photo_description"];
        [dic setObject:photoTitle forKey:@"collection_photo_title"];
        [dic setObject:self.photoId forKey:@"collection_photo_id"];
        [dic setObject:[photoDetail objectForKey:@"collection_photo_filesize"] forKey:@"collection_photo_filesize"];
        [dic setObject:userid forKey:@"collection_photo_user_id"];
        //update photo info array in nsuser default
        [photoinfoarray replaceObjectAtIndex:self.selectedIndex withObject:dic];
        
        NSData *data=[NSKeyedArchiver archivedDataWithRootObject:photoinfoarray];
        [manager storeData:data :@"photoInfoArray"];
     
        
        NSDictionary *dicData=@{@"user_id":userid,@"photo_id":self.photoId,@"photo_title":photoTitletxt.text,@"photo_description":photoDescriptionTxt.text,@"photo_location":photoLocationString,@"photo_tags":photoTag.text,@"photo_collections":self.collectionId};
        
        [webservices call:dicData controller:@"photo" method:@"change"];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   }

-(IBAction)savePhotoDetail:(id)sender
{
    [self savePhotoDetailOnServer];
    
}
#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    if([manager isiPad])
    {
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 90.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
    }
    else
    {
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }

    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//get the user location
-(void)callGetLocation
{
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    [self getLocation];
}
-(void)getLocation
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            /*NSString *location = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@", placemark.subThoroughfare, placemark.thoroughfare,
             placemark.postalCode, placemark.locality,
             placemark.administrativeArea,
             placemark.country];*/
            NSString *location = [NSString stringWithFormat:@"%@,%@,%@",  placemark.locality,placemark.administrativeArea,                                  placemark.country];
            
            photoLocationString=location;
            
            
            NSLog(@"Current location is %@",location);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
    [locationManager stopUpdatingLocation];
}

@end
