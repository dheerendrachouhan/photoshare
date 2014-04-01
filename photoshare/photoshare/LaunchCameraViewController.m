//
//  LaunchCameraViewController.m
//  photoshare
//
//  Created by ignis2 on 03/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "LaunchCameraViewController.h"
#import "AppDelegate.h"

#import "SVProgressHUD.h"
#import "EditPhotoDetailViewController.h"
#import "AddEditFolderViewController.h"

@interface LaunchCameraViewController ()

@end

@implementation LaunchCameraViewController
@synthesize sessions,assetLibrary,pickerimage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"LaunchCameraViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"LaunchCameraViewController";
    }

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view method
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setUIForIOS6];
    @try {
        collectionIdArray=[[NSMutableArray alloc] init];
        collectionNameArray=[[NSMutableArray alloc] init];
        webservices=[[WebserviceController alloc] init];
        home=[[HomeViewController alloc] init];
        
        manager=[ContentManager sharedManager];
        dmc=[[DataMapperController alloc] init];
        NSDictionary *dic = [[dmc getUserDetails] mutableCopy];
        userid=[dic objectForKey:@"user_id"];
        [self showSelectFolderOption];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in Launch Camera: %@",exception.description);
    }
    [self addCustomNavigationBar];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    @try {
        if([[manager getData:@"reset_camera"] isEqualToString:@"YES"])
        {
            [self openAviaryEditor:self.pickerimage];
            [manager removeData:@"reset_camera"];
        }
        else
        {
            if([[manager getData:@"is_add_folder"] isEqualToString:@"YES"])
            {
                [manager storeData:@"NO" :@"is_add_folder"];
                @try {
                    NSNumber *newcolid=[manager getData:@"new_col_id"];
                    if(newcolid!=nil)
                    {
                        [self getCollectionInfoFromUserDefault];
                        NSInteger index=[collectionIdArray indexOfObject:[NSString stringWithFormat:@"%@",newcolid]];
                        [categoryPickerView reloadAllComponents];
                        [categoryPickerView selectRow:index inComponent:0 animated:NO];
                        titleLabe.text=[collectionNameArray objectAtIndex:index];
                        selectedCollectionId=[collectionIdArray objectAtIndex:index];
                    }
                    //Remove temp key from NSUserDefault
                    [manager removeData:@"is_add_folder,new_col_id"];
                }
                @catch (NSException *exception) {
                    
                }
            }
            else
            {
                if([[manager getData:@"isfromphotodetailcontroller"] isEqualToString:@"YES"])
                {
                    selectedCollectionId=@-1;
                    [self callGetLocation];
                    
                    photoTitleStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_title"];
                    photoDescriptionStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_description"];
                    photoTagStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_tags"];
                    
                    imgData=[manager getData:@"photo_data"];
                    imgView.image=[UIImage imageWithData:imgData];
                    //Remove temp key
                    [manager removeData:@"isfromphotodetailcontroller,photo_data,takephotodetail"];
                }
            }
        }
    }
    @catch (NSException *exception) {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUIForIOS6
{
    //Set for ios 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        categoryPickerView.frame=CGRectMake(categoryPickerView.frame.origin.x, categoryPickerView.frame.origin.y+50, categoryPickerView.frame.size.width, categoryPickerView.frame.size.height);
    }
    
}
#pragma mark - TextFeild Method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return  [textField resignFirstResponder];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - cameraLaunch Method
-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
}
-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
     [categoryPickerView reloadAllComponents];
    selectedCollectionId=@-1;
    @try {
        for (int i=0;i<collection.count+1; i++)
        {
            if(i==0)
            {
                [collectionIdArray addObject:@-1];
                [collectionNameArray addObject:@"Add New Folder"];
                
            }
            else
            {
                NSNumber *coluserId=[[collection objectAtIndex:i-1] objectForKey:@"collection_user_id"];
                if(coluserId.integerValue==userid.integerValue)
                {
                    //get the public collection id
                    if([[[collection objectAtIndex:i-1] objectForKey:@"collection_name"] isEqualToString:@"Public"]||[[[collection objectAtIndex:i-1] objectForKey:@"collection_name"] isEqualToString:@"public"])
                    {
                        publicCollectionId=[[collection objectAtIndex:i-1] objectForKey:@"collection_id"];
                        
                        [collectionIdArray addObject:publicCollectionId];
                        [collectionNameArray addObject:@"123 Public"];
                    }
                    else
                    {
                        [collectionIdArray addObject:[[collection objectAtIndex:i-1] objectForKey:@"collection_id"]];
                        [collectionNameArray addObject:[[collection objectAtIndex:i-1] objectForKey:@"collection_name"]];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exec is %@",exception.description);
    }
    [categoryPickerView reloadAllComponents];
    [categoryPickerView selectRow:0 inComponent:0 animated:NO];
}
-(void)openAviaryEditor:(UIImage *)image
{
    @try {
        [self getCollectionInfoFromUserDefault];
        imgView.image=nil;
        photoLocationStr=@"";
        imgView.image=image;
        pickImage=image;
        isCameraEditMode=YES;
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
        [NSTimer scheduledTimerWithTimeInterval:0.0f   target:self selector:@selector(openeditorcontrol) userInfo:nil  repeats:NO];
        [self dismissViewControllerAnimated:NO completion:Nil];
    }
    @catch (NSException *exception) {
        
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


//For Aviary Edit Photo

#pragma mark - Photo Editor Launch Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    
    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
}


#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    [SVProgressHUD dismiss];
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    photoEditor.view.frame=CGRectMake(0, 100, 320, 300);
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    if (highResImage) {
        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
    }
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
}

- (void) setupHighResContextForPhotoEditor:(AFPhotoEditorController *)photoEditor withImage:(UIImage *)highResImage
{
    // Capture a reference to the editor's session, which internally tracks user actions on a photo.
    __block AFPhotoEditorSession *session = [photoEditor session];
    
    // Add the session to our sessions array. We need to retain the session until all contexts we create from it are finished rendering.
    [[self sessions] addObject:session];
    
    // Create a context from the session with the high res image.
    AFPhotoEditorContext *context = [session createContextWithImage:highResImage];
    
    __block LaunchCameraViewController * blockSelf = self;
    
    [context render:^(UIImage *result) {
        if (result) {
            //UIImageWriteToSavedPhotosAlbum(result, nil, nil, NULL);
        }
        
        [[blockSelf sessions] removeObject:session];
        
        blockSelf = nil;
        session = nil;
        
    }];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    imgView.image=image;
    imgData=UIImagePNGRepresentation(image);
    isCameraEditMode=NO;
    [self resetTheView];
    [self goToPhotoDetailViewController];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self resetTheView];
    [self goToHomePage];
}
-(void)resetTheView
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
#pragma mark - Photo Editor Customization


- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}
#pragma mark - ALAssets Helper Methods

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = [representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}

#pragma mark - Private Helper Methods

- (BOOL) hasValidAPIKey
{
    NSString * key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Aviary-API-Key"];
    if (![key isEqualToString:@"c5c917dcef9d4377"]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You forgot to add your API key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

#pragma mark - webservice delegate method
-(void)webserviceCallback:(NSDictionary *)data
{
    [SVProgressHUD dismiss];
   
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if (isPhotoSavingMode)
    {
        if(exitCode.integerValue==1)
        {
            NSLog(@"Photo saving Suucees ");
        }
        else
        {
            NSLog(@"Photo saving Fail ");
            [manager showAlert:@"Message" msg:@"Photo Saving Failed" cancelBtnTitle:@"Ok" otherBtn:Nil];
            
        }
         [self removePickerView];
        isPhotoSavingMode=NO;
    }
    
}
#pragma mark - Show Select Folder Option
-(void)showSelectFolderOption
{
    @try {
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        imgView.backgroundColor=[UIColor blackColor];
        
        pickerToolbar=[[UIToolbar alloc] init];
        [self.view addSubview:pickerToolbar];
        //Add Gesture on Catagory Picker View
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapGestureRecognized:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        [categoryPickerView addGestureRecognizer:gestureRecognizer];
        
        categoryPickerView.backgroundColor=[UIColor whiteColor];
        [categoryPickerView setDataSource: self];
        [categoryPickerView setDelegate: self];
        categoryPickerView.showsSelectionIndicator = YES;
        
        if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)          pickerToolbar.frame=CGRectMake(0,self.view.frame.size.height-180, 320, 40);
        else
        {
            if([manager isiPad])
                pickerToolbar.frame=CGRectMake(0,self.view.frame.size.height-260, 320, 40);
            else
                pickerToolbar.frame=CGRectMake(0,self.view.frame.size.height-222, 320, 40);
        }
        
        pickerToolbar.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
        
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        titleLabe=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        titleLabe.text=@"Select Folder";
        titleLabe.textAlignment =NSTextAlignmentCenter;
        titleLabe.textColor=[UIColor whiteColor];
        titleLabe.backgroundColor=[UIColor clearColor];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(categoryCancelButtonPressed)];
        [barItems addObject:cancelBtn];
        
        UIBarButtonItem *toolBarTitle=[[UIBarButtonItem alloc]  initWithCustomView:titleLabe];
        [barItems addObject:flexSpace];
        [barItems addObject:toolBarTitle];
        [barItems addObject:flexSpace];
       
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(categoryDoneButtonPressed)];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
}

-(void)categoryDoneButtonPressed{
    if(selectedCollectionId.integerValue!=-1)
    {
         [self savePhotosOnServer:userid filepath:imgData];
    }
    else
    {
        //selectedCollectionId=[collectionIdArray objectAtIndex:0];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"No Folder Selected" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
        [alert show];
    }
    
}
-(void)removePickerView
{
    [self goToHomePage];
}
-(void)categoryCancelButtonPressed{
    [self removePickerView];
}
#pragma mark GoToPhotoDetailViewController
-(void)goToPhotoDetailViewController
{
    EditPhotoDetailViewController *editDetail;
    if([manager isiPad])
    {
        editDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        editDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController" bundle:[NSBundle mainBundle]];
    }
    editDetail.isLaunchCamera=YES;
    [manager storeData:imgData :@"photo_data"];
    [self.navigationController pushViewController:editDetail animated:NO];
}
#pragma mark - Picker view Delegate Method
- (void)pickerViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    if([categoryPickerView selectedRowInComponent:0]==0)
    {
        AddEditFolderViewController *addeditvc=[[AddEditFolderViewController alloc] init];
        addeditvc.isAddFolder=YES;
        addeditvc.isFromLaunchCamera=YES;
         [self.navigationController pushViewController:addeditvc animated:YES];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    if(row==0)
    {
        selectedCollectionId=@-1;
        titleLabe.text=@"Select Folder";
        AddEditFolderViewController *addeditvc=[[AddEditFolderViewController alloc] init];
        addeditvc.isAddFolder=YES;
        addeditvc.isFromLaunchCamera=YES;
        [self.navigationController pushViewController:addeditvc animated:YES];
    }
    else
    {
        selectedCollectionId=[collectionIdArray objectAtIndex:row];
        titleLabe.text=[collectionNameArray objectAtIndex:row];
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [collectionIdArray count];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [collectionNameArray objectAtIndex: row];
    
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *text = [collectionNameArray objectAtIndex: row];
    NSMutableAttributedString *as = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    mutParaStyle.alignment = NSTextAlignmentCenter;
    [as addAttribute:NSParagraphStyleAttributeName value:mutParaStyle range:NSMakeRange(0,[text length])];
    return as;
}
// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 320;
    
    return sectionWidth;
}
//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData
{
    [SVProgressHUD showWithStatus:@"Photo is saving" maskType:SVProgressHUDMaskTypeBlack];
    isPhotoSavingMode=YES;
    webservices.delegate=self;
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":selectedCollectionId};
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
}
#pragma mark - Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)goToHomePage
{
    isCameraEditMode=NO;
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    [manager storeData:@"YES" :@"istabcamera"];
    delgate.navControllerhome.viewControllers=[NSArray arrayWithObjects:home, nil];
        [delgate.tbc setSelectedIndex:0];
}
#pragma mark - Get The Current Location of user
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

//CLLocation manager Delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    // Reverse Geocoding for current user address
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            NSString *location = [NSString stringWithFormat:@"%@,%@,%@",  placemark.locality,placemark.administrativeArea,                                  placemark.country];
            photoLocationStr=location;
            NSLog(@"Current location is %@",location);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    [locationManager stopUpdatingLocation];
}

@end
