//
//  PhotoViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoShareController.h"
#import "EditPhotoDetailViewController.h"
#import "SVProgressHUD.h"
@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize smallImage,photoId,isViewPhoto,folderName,collectionId,selectedIndex,collectionOwnerId,isPublicFolder,photoOwnerId;
@synthesize  isOnlyReadPermission;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"PhotoViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"PhotoViewController";
    }

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    webservices=[[WebserviceController alloc] init];
    
    manager=[ContentManager sharedManager];
    dmc=[[DataMapperController alloc] init];
    largeImage=[[LargePhotoViewController alloc] init];
    NSDictionary *dic = [dmc getUserDetails] ;
    userid=[dic objectForKey:@"user_id"];
    //set UI for IOS 6
    [self setUIForIOS6];
    //Add Custom Navigation bar
    [self addCustomNavigationBar];
    [manager removeData:@"editphotodetails,phototitle"];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.layer.masksToBounds=YES;
    imageView.backgroundColor=[UIColor blackColor];
    if(self.isViewPhoto)
    {
        if(self.isPublicFolder)
        {
            folderLocationShowLabel.text=@"123 Public";
        }
        else
        {
            folderLocationShowLabel.text=[NSString stringWithFormat:@"Your Folders,%@",self.folderName];
        }   
        
        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator startAnimating];
        activityIndicator.tag=1100;
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
        activityIndicator.center = CGPointMake(CGRectGetWidth(imageView.bounds)/2, CGRectGetHeight(imageView.bounds)/2);
        [imageView addSubview:activityIndicator];
        
        if([self getImageFromDocumentDirectory:photoId.integerValue]!=(id)nil)
        {
            UIActivityIndicatorView *indeicator=(UIActivityIndicatorView *)[imageView viewWithTag:1100];
            [indeicator removeFromSuperview];
            imageView.image=[self getImageFromDocumentDirectory:photoId.integerValue];
            originalImage=[self getImageFromDocumentDirectory:photoId.integerValue];
            isoriginalImageGet=YES;
        }
        else
        {
            [self getImageFromServer];
        }
    }
    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage)];
    doubleTap.numberOfTapsRequired=2;
    [imageView addGestureRecognizer:doubleTap];
    
    
    //photoViewBtnBorderSet
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    photoViewBtn.layer.cornerRadius=5;
    if([manager isiPad])
    {
        photoViewBtn.layer.cornerRadius=10;
    }
    photoViewBtn.layer.borderColor=btnBorderColor.CGColor;
    photoViewBtn.layer.borderWidth=1;
    segmentControl.hidden=NO;
    photoViewBtn.hidden=YES;
    if(isOnlyReadPermission)
    {
        segmentControl.hidden=YES;
        photoViewBtn.hidden=NO;
    }
    //get photo info from nsuser default
    NSArray *photoDetail=[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]];
    photoTitleStr=[[photoDetail objectAtIndex:self.selectedIndex ] objectForKey:@"collection_photo_title"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    
    if([[manager getData:@"isfromphotodetailcontroller"] isEqualToString:@"YES"])
    {
        [self callGetLocation];
        
        photoTitleStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_title"];
        photoDescriptionStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_description"];
        photoTagStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_tags"];
        
        imgData=[manager getData:@"photo_data"];
        
        [self savePhotosOnServer:userid filepath:imgData];
        [manager removeData:@"isfromphotodetailcontroller,takephotodetail,photo_data"];
        photoTitleLBL.text=photoTitleStr;
    }
    else if ([[manager getData:@"editphotodetails"] isEqualToString:@"YES"])
    {
        @try {
            photoTitleStr=[manager getData:@"phototitle"];
            photoTitleLBL.text=photoTitleStr;
            [manager removeData:@"editphotodetails,phototitle"];
        }
        @catch (NSException *exception) {
            
        }
    }
    else
    {
        if (isCameraEditMode) {
            isCameraEditMode = false ;
            [NSTimer scheduledTimerWithTimeInterval:1.0f   target:self
                                           selector:@selector(openeditorcontrol)  userInfo:nil
                                            repeats:NO];
        }
        if([[manager getData:@"istabcamera"] isEqualToString:@"YES"])
        {
            [self.navigationController popViewControllerAnimated:NO];
        }
        photoTitleLBL.text=photoTitleStr;
    }
   //set the phototitle on navTitleLabel
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        imageView.frame=CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height+50);
        segmentControl.frame=CGRectMake(segmentControl.frame.origin.x, segmentControl.frame.origin.y+40, segmentControl.frame.size.width, segmentControl.frame.size.height);
        photoViewBtn.frame=CGRectMake(photoViewBtn.frame.origin.x, photoViewBtn.frame.origin.y+40, photoViewBtn.frame.size.width, photoViewBtn.frame.size.height);
        folderLocationShowLabel.frame=CGRectMake(folderLocationShowLabel.frame.origin.x, folderLocationShowLabel.frame.origin.y+45, folderLocationShowLabel.frame.size.width, folderLocationShowLabel.frame.size.height);
        folderLocationIndicator.frame=CGRectMake(folderLocationIndicator.frame.origin.x, folderLocationIndicator.frame.origin.y+45, folderLocationIndicator.frame.size.width, folderLocationIndicator.frame.size.height);
    }
}
#pragma mark - save and get image from Document directry
-(void)saveImageInDocumentDirectry:(UIImage *)img index:(NSInteger)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //Create Folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/123FridayImages"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    if(self.isPublicFolder)
    {
        dataPath = [dataPath stringByAppendingPathComponent:@"/PublicFolder"];
    }
    else
    {
        dataPath = [dataPath stringByAppendingPathComponent:@"/YourFolder"];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    if(!self.isPublicFolder)
    {
        dataPath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",self.folderName]];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    }
    NSString *savedImagePath = [dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_LargePhoto_%@.png",userid,self.photoId]];
    
    UIImage *image = img; // imageView is my image from camera
    NSData *imgD = UIImagePNGRepresentation(image);
    [imgD writeToFile:savedImagePath atomically:NO];
    
}
-(UIImage *)getImageFromDocumentDirectory :(NSInteger)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath;
    if(self.isPublicFolder)
    {
        getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/123FridayImages/PublicFolder/%@_LargePhoto_%@.png",userid,self.photoId]];
    }
    else
    {
        getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/123FridayImages/YourFolder/%@/%@_LargePhoto_%@.png",self.folderName,userid,self.photoId]];
    }
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
}

#pragma mark - IBAction methods
- (IBAction)viewPhoto:(id)sender
{
    if(isoriginalImageGet)
    {
        [self viewImage];
    }
    else
    {
        [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:nil];
    }
}
- (IBAction)segmentSwitch:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {//view image
        
        if(isoriginalImageGet)
        {
            [self viewImage];
        }
        else
        {
            [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:nil];
        }
    }
    else if (selectedSegment == 1) {//Edit image
        photoLocationStr=@"";
        [self callGetLocation];
        
        if(isoriginalImageGet)
        {
            if(self.photoOwnerId.integerValue==userid.integerValue)
            {
                isPhotoOwner=YES;
                UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Edit Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo",@"Edit Properties", nil];
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            }
            else
            {
                isPhotoOwner=NO;
                UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo", nil];
                [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            }
            
        }
        else
        {
            [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:nil];
        }
        
    }
    else if (selectedSegment == 2) {
        
        if(isoriginalImageGet)
        {
            [self shareImage:originalImage];
        }
        else
        {
            [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:nil];
        }        
    }
    segmentedControl.selectedSegmentIndex = -1;
}

#pragma mark - Text Feild delegate methods
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

#pragma mark - Fetch the photo from server
-(void)getImageFromServer
{
    NSNumber *num = [NSNumber numberWithInt:1] ;
    webservices.delegate=self;
    NSString *imageReSize=@"1000";
    if([manager isiPad])
    {
        imageReSize=@"2000";
    }
    
    NSDictionary *dicData = @{@"user_id":userid,@"photo_id":self.photoId,@"get_image":num,@"collection_id":self.collectionId,@"image_resize":imageReSize};
    
    [webservices call:dicData controller:@"photo" method:@"get"];
}
#pragma mark - Webservice Call Back Methods
-(void) webserviceCallbackImage:(UIImage *)image
{
    UIActivityIndicatorView *indeicator=(UIActivityIndicatorView *)[imageView viewWithTag:1100];
    [indeicator removeFromSuperview];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image=image;
    originalImage=image;
    isoriginalImageGet=YES;
    
    [self saveImageInDocumentDirectry:image index:self.photoId.integerValue];
}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Data %@",data);
    NSDictionary *outputData=[data objectForKey:@"output_data"];
    if(isSavePhotoOnServer)
    {
        [SVProgressHUD dismiss];
        int exitcode=[[data objectForKey:@"exit_code"] integerValue];
        if(exitcode==1)
        {
            //update the photo info  in nsuser default
            NSMutableArray *photoinfoarray=[NSKeyedUnarchiver unarchiveObjectWithData:[[manager getData:@"photoInfoArray"] mutableCopy]];
            
            NSDictionary *photoDetail=[photoinfoarray lastObject];
            
            NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
            [dic setObject:[photoDetail objectForKey:@"collection_photo_added_date"] forKey:@"collection_photo_added_date"];
            [dic setObject:photoDescriptionStr forKey:@"collection_photo_description"];
            [dic setObject:photoTitleStr forKey:@"collection_photo_title"];
            [dic setObject:[outputData objectForKey:@"image_id"] forKey:@"collection_photo_id"];
            [dic setObject:[photoDetail objectForKey:@"collection_photo_filesize"] forKey:@"collection_photo_filesize"];
            [dic setObject:userid forKey:@"collection_photo_user_id"];
            //update photo info array in nsuser default
            [photoinfoarray addObject:dic];
            
            NSData *data=[NSKeyedArchiver archivedDataWithRootObject:photoinfoarray];
            [manager storeData:data :@"photoInfoArray"];
            [manager storeData:@"YES" :@"isEditPhotoInViewPhoto"];
            [manager storeData:imgData :@"photo"];
            [manager storeData:[outputData objectForKey:@"image_id"] :@"photoId"];
            if(self.isPublicFolder)
            {
                //public img count for home page
                NSNumber *imgCout=[NSNumber numberWithInteger:photoinfoarray.count];
                [manager storeData:imgCout :@"publicImgIdArray"];
            }
            photoTitleLBL.text=photoTitleStr;
            imageView.image=pickImage;
            originalImage=pickImage;
        }
        else
        {
            NSLog(@"Photo saving failed");
            [manager showAlert:@"Message" msg:@"Photo Saving Failed" cancelBtnTitle:@"Ok" otherBtn:Nil];

        }
        isSavePhotoOnServer=NO;
    }
}



#pragma mark - open the aviary editor
-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
}

#pragma mark - View Image in full screen
-(void)viewImage
{
    largeImage.imageLoaded=originalImage;
    largeImage.isFromPhotoViewC=YES;
    [self.navigationController pushViewController:largeImage animated:YES];    
}


#pragma mark - Action Sheet delegate Methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)//Edit Photo
    {
        [self launchPhotoEditorWithImage:originalImage highResolutionImage:originalImage];
    }
    else if(buttonIndex==1)//Edit Detail
    {
        if(isPhotoOwner)
        {
            @try {
                EditPhotoDetailViewController *editPhotoDetail;
                if([manager isiPad])
                {
                    editPhotoDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController_iPad" bundle:[NSBundle mainBundle]];
                }
                else
                {
                    editPhotoDetail=[[EditPhotoDetailViewController alloc] initWithNibName:@"EditPhotoDetailViewController" bundle:[NSBundle mainBundle]];
                }
                editPhotoDetail.photoId=self.photoId;
                editPhotoDetail.collectionId=self.collectionId;
                editPhotoDetail.selectedIndex=self.selectedIndex;
                
                [self.navigationController pushViewController:editPhotoDetail animated:YES];
            }
            @catch (NSException *exception) {
                
            }
        }
    }
}
-(void)removveimageView
{
    [imgV removeFromSuperview];
    isViewLargeImageMode=NO;
    self.tabBarController.tabBar.hidden=NO;
    
}

-(void)shareImage:(UIImage *)imageToShare
{
    
    PhotoShareController *photoShare;
    if([manager isiPad])
    {
        photoShare = [[PhotoShareController alloc] initWithNibName:@"PhotoShareController_iPad" bundle:nil];
    }
    else{
        photoShare = [[PhotoShareController alloc] initWithNibName:@"PhotoShareController" bundle:nil];
    }
    
    photoShare.sharedImage = imageToShare;
    
    [self.navigationController pushViewController:photoShare animated:YES];
}
-(void)goToPhotoDetailViewControler
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
    editDetail.isPhotoAdd=YES;
    
    [manager storeData:imgData :@"photo_data"];
    
    [self.navigationController pushViewController:editDetail animated:NO];
}

//For Aviary Edit Photo
#pragma mark - Aviary methods
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
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
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
    
    __block PhotoViewController * blockSelf = self;
    
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
    pickImage=image;
    imgData=UIImagePNGRepresentation(image);
    [self dismissViewControllerAnimated:YES completion:nil];
   
    [self goToPhotoDetailViewControler];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
}
// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
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

- (BOOL) hasValidAPIKey
{
    NSString * key = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Aviary-API-Key"];
    if (![key isEqualToString:@"c1f4f0ae01276a21"]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You forgot to add your API key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

#pragma mark - save image on server
//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData
{
    webservices=[[WebserviceController alloc] init];
    webservices.delegate=self;
    isSavePhotoOnServer=YES;
    if(photoLocationStr==nil)
    {
        photoLocationStr=@"";
    }
    [SVProgressHUD showWithStatus:@"Photo is saving" maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":self.collectionId};
  
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
}



#pragma mark - Get the user current location
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
            
            photoLocationStr=location;
            
            NSLog(@"Current location is %@",location);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
    [locationManager stopUpdatingLocation];
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
    
    photoTitleLBL=[navnBar navBarTitleLabel:photoTitleStr];
    [navnBar addSubview:photoTitleLBL];
    [navnBar addSubview:button];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    
    [[self view] addSubview:navnBar];
    
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}



@end
