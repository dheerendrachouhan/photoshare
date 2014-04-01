//
//  EditPhotoDetailViewController.m
//  photoshare
//
//  Created by ignis2 on 06/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditPhotoDetailViewController.h"
#import "NavigationBar.h"
#import "LaunchCameraViewController.h"
@interface EditPhotoDetailViewController ()

@end

@implementation EditPhotoDetailViewController
@synthesize photoId,collectionId,selectedIndex,isPhotoAdd,isLaunchCamera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"EditPhotoDetailViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"EditPhotoDetailViewController";
    }

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    manager=[ContentManager sharedManager];
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //initialize the WebService Object
    userid =[manager getData:@"user_id"];
    //Add Custom NAvigation bar
    [self addCustomNavigationBar];
    //set text fielddelegate
    [photoTitletxt setDelegate:self];
    [photoDescriptionTxt setDelegate:self];
    [photoTag setDelegate:self];
    
    photoDescriptionTxt.layer.borderWidth=0.3;
    if([manager isiPad])
    {
        photoDescriptionTxt.layer.borderWidth=0.8;
    }
    [self setUIForIOS6];
    photoDescriptionTxt.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
    
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    saveButton.layer.cornerRadius=4;
    saveButton.layer.borderColor=btnBorderColor.CGColor;
    saveButton.layer.borderWidth=1;
    cancelButton.layer.cornerRadius=4;
    cancelButton.layer.borderColor=btnBorderColor.CGColor;
    cancelButton.layer.borderWidth=1;
    cancelButton.hidden=YES;
    if(!self.isPhotoAdd && !self.isLaunchCamera)
    {
        @try {
            NSArray *photoDetail=[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]];
            photoTitletxt.text=[[photoDetail  objectAtIndex:self.selectedIndex] objectForKey:@"collection_photo_title"];
            photoDescriptionTxt.text=[[photoDetail  objectAtIndex:self.selectedIndex] objectForKey:@"collection_photo_description"];
        }
        @catch (NSException *exception) {
            
        }
    }
    if(isLaunchCamera || isPhotoAdd)
    {
        cancelButton.hidden=NO;
    }
    
   
    //tap getsure on view for dismiss the keyboard
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self checkOrientation];
    
    photoLocationString=@"";
     [navnBar setTheTotalEarning:manager.weeklyearningStr];
    [self callGetLocation];
    
}

-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        photoDescriptionTxt.layer.borderWidth=1;
    }
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    [self.view endEditing:YES];
}
// called when textField start editting.
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([manager isiPad])
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textField.center.y-70) animated:NO];
        }
    }
    else
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,textField.center.y-30) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textField.center.y-30) animated:NO];
        }
    }
    
}
//for text view
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if([manager isiPad])
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textView.center.y-80) animated:NO];
        }
    }
    else
    {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake(0,textView.center.y-30) animated:NO];
        }
    }
}

// called when click on the retun button.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textField resignFirstResponder];
        return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}
-(void)checkOrientation
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,270);
            scrollView.scrollEnabled=NO;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,270);
            scrollView.scrollEnabled=NO;
        }
    }
    else {
        if([[UIScreen mainScreen] bounds].size.height == 480.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,240);
            scrollView.scrollEnabled=YES;
        }
        else if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,240);
            scrollView.scrollEnabled=YES;
        }
        else if ([manager isiPad])
        {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,500);
            scrollView.scrollEnabled=YES;
        }
    }
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self checkOrientation];
}
-(void)savePhotoDetailOnServer
{
    NSString *photodes;
    NSString *photoTitle;
    NSString *photoTagstr;;
    @try {
        photodes=photoDescriptionTxt.text;
        
        photoTitle=photoTitletxt.text;
        photoTagstr=photoTag.text;
    }
    @catch (NSException *exception) {
        
    }
    
    if(photodes.length==0) photodes=@"";
    if(photoTitle.length==0) photoTitle=@"Untitled";
    if(photoTagstr.length==0) photoTagstr=@"";
    
    if(self.isPhotoAdd || isLaunchCamera)
    {
        NSDictionary *photoDetail=@{@"photo_title":photoTitle,@"photo_description":photodes,@"photo_tags":photoTagstr};
        manager=[ContentManager sharedManager];
       [manager storeData:@"YES" :@"isfromphotodetailcontroller"];
        [manager storeData:photoDetail :@"takephotodetail"];
    }
    else
    {
        isPhotoDetailSaveOnServer=YES;
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
            
            NSDictionary *dicData=@{@"user_id":userid,@"photo_id":self.photoId,@"photo_title":photoTitle,@"photo_description":photodes,@"photo_location":photoLocationString,@"photo_tags":photoTag.text,@"photo_collections":self.collectionId};
            [manager storeData:@"YES" :@"editphotodetails"];
            [manager storeData:photoTitle :@"phototitle"];
            
            webservices=[[WebserviceController alloc] init];
            webservices.delegate=self;
            [webservices call:dicData controller:@"photo" method:@"change"];
        }
        @catch (NSException *exception) {
            
        }      
    }
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)webserviceCallback:(NSDictionary *)data
{
    
}
-(IBAction)savePhotoDetail:(id)sender
{
    @try {
        [self savePhotoDetailOnServer];
    }
    @catch (NSException *exception) {
        
    }
}
-(IBAction)cancelPhotoDetail:(id)sender
{
    @try {
        photoTitletxt.text=@"";
        photoDescriptionTxt.text=@"";
        photoTag.text=@"";
        [self savePhotoDetailOnServer];
    }
    @catch (NSException *exception) {
    }
}
#pragma mark - Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *titleLabel=[navnBar navBarTitleLabel:@"Photo Details"];
    if(!self.isLaunchCamera && !self.isPhotoAdd)
    {
         [navnBar addSubview:button];
    }
    [navnBar addSubview:titleLabel];
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
