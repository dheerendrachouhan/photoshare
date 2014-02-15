//
//  PhotoViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PhotoViewController.h"
#import "NavigationBar.h"
#import "PhotoShareController.h"
#import "EditPhotoDetailViewController.h"
#import "SVProgressHUD.h"
@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize smallImage,photoId,isViewPhoto,folderNameLocation,collectionId,selectedIndex,collectionOwnerId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    collectionIdArray=[[NSMutableArray alloc] init];
    collectionNameArray=[[NSMutableArray alloc] init];
    webservices=[[WebserviceController alloc] init];
    
    manager=[ContentManager sharedManager];
    dmc=[[DataMapperController alloc] init];
    NSDictionary *dic = [dmc getUserDetails] ;
    userid=[dic objectForKey:@"user_id"];
    
    
    imageView.layer.masksToBounds=YES;
    if(self.isViewPhoto)
    {
        folderLocationShowLabel.text=self.folderNameLocation;
        imageView.image=self.smallImage;
        [self getImageFromServer];
        UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator startAnimating];
        activityIndicator.tag=1100;
        activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
        activityIndicator.center = CGPointMake(CGRectGetWidth(imageView.bounds)/2, CGRectGetHeight(imageView.bounds)/2);
        [imageView addSubview:activityIndicator];
    }
    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewImage)];
    doubleTap.numberOfTapsRequired=2;
    [imageView addGestureRecognizer:doubleTap];
    

    if(self.collectionOwnerId.integerValue==userid.integerValue)
    {
        segmentControl.hidden=NO;
    }
    else
    {
        segmentControl.hidden=YES;
    }
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
-(void)getImageFromServer
{
    NSNumber *num = [NSNumber numberWithInt:1] ;
    webservices.delegate=self;
    NSDictionary *dicData = @{@"user_id":userid,@"photo_id":self.photoId,@"get_image":num,@"collection_id":self.collectionId,@"image_resize":@"500"};
    
    [webservices call:dicData controller:@"photo" method:@"get"];
}
-(void) webserviceCallbackImage:(UIImage *)image
{
    UIActivityIndicatorView *indeicator=(UIActivityIndicatorView *)[imageView viewWithTag:1100];
    [indeicator removeFromSuperview];
    imageView.image=image;
    originalImage=image;
    isoriginalImageGet=YES;
}
-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];
    
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
    
    for (int i=1;i<collection.count; i++)
    {
        
        [collectionIdArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_id"]];
        [collectionNameArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_name"]];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getCollectionInfoFromUserDefault];
    [self addCustomNavigationBar];
    if (isCameraEditMode) {
        isCameraEditMode = false ;
        [NSTimer scheduledTimerWithTimeInterval:1.0f
                                         target:self
                                       selector:@selector(openeditorcontrol)
                                       userInfo:nil
                                        repeats:NO];
    }
    if([[manager getData:@"istabcamera"] isEqualToString:@"YES"])
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
    
}
-(void)viewImage
{
    UIImageView *imgV=[[UIImageView alloc ] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-40)];
    imgV.tag=10000;
    imgV.userInteractionEnabled=YES;
    imgV.layer.masksToBounds=YES;
    imgV.image=originalImage;
    
    UITapGestureRecognizer *doubleTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removveimageView)];
    doubleTap.numberOfTapsRequired=2;
    [imgV addGestureRecognizer:doubleTap];
    [self.view addSubview:imgV];
}
- (IBAction)segmentSwitch:(id)sender {
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
            UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo",@"Edit Properties", nil];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
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
//action sheet delegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)//Edit Photo
    {
        [self launchPhotoEditorWithImage:originalImage highResolutionImage:originalImage];
    }
    else if(buttonIndex==1)//Edit Detail
    {
        @try {
            EditPhotoDetailViewController *editPhotoDetail=[[EditPhotoDetailViewController alloc] init];
            editPhotoDetail.photoId=self.photoId;
            editPhotoDetail.collectionId=self.collectionId;
            editPhotoDetail.selectedIndex=self.selectedIndex;
            
            [self.navigationController pushViewController:editPhotoDetail animated:YES];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
       
    }
}
-(void)removveimageView
{
    UIImageView *imgVi=(UIImageView *)[self.view viewWithTag:10000];
    [imgVi removeFromSuperview];
}

-(void)shareImage:(UIImage *)imageToShare
{
    //UIImage *shareImg = imageToShare;
    PhotoShareController *photoShare = [[PhotoShareController alloc] init];
    photoShare.sharedImage = imageToShare;
    
    [self.navigationController pushViewController:photoShare animated:YES];
    /*
     PhotoShareView
     */
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
     imageView.image=pickImage;
    originalImage=pickImage;
    
     imgData=UIImagePNGRepresentation(image);
    [self dismissViewControllerAnimated:YES completion:nil];
    [self addPhotoDescriptionView];
    //[manager showAlert:@"Message" msg:@"Photo Edit success" cancelBtnTitle:@"Ok" otherBtn:nil];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    if (![key isEqualToString:@"c1f4f0ae01276a21"]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You forgot to add your API key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}


//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData
{
    webservices=[[WebserviceController alloc] init];
    webservices.delegate=self;
    isSavePhotoOnServer=YES;
    [SVProgressHUD showWithStatus:@"Photo is saving" maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":self.collectionId};    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
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

            
        }
        isSavePhotoOnServer=NO;
        
    }

}

//fro add photo details
-(void)addPhotoDescriptionView
{
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    UIColor *btnTextColor=[UIColor colorWithRed:0.094 green:0.427 blue:0.933 alpha:1];
    UIColor *lblTextColor=[UIColor blackColor];
    backViewPhotDetail=[[UIView alloc] initWithFrame:self.view.frame];
    backViewPhotDetail.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    UIView *addPhotoDescriptionView=[[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-130, self.view.center.y-210, 260, 300)];
    addPhotoDescriptionView.layer.borderWidth=1;
    addPhotoDescriptionView.layer.borderColor=[UIColor blackColor].CGColor;
    addPhotoDescriptionView.layer.cornerRadius=8;
    addPhotoDescriptionView.backgroundColor=[UIColor whiteColor];
    //tap getsure on view for dismiss the keyboard
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [addPhotoDescriptionView addGestureRecognizer:tapper];
    
    UILabel *headLbl=[[UILabel alloc] initWithFrame:CGRectMake(40, 10, addPhotoDescriptionView.frame.size.width-80, 30)];
    headLbl.text=@"Add Photo Details";
    headLbl.layer.cornerRadius=5;
    headLbl.textAlignment=NSTextAlignmentCenter;
    headLbl.textColor=lblTextColor;
    //headLbl.backgroundColor=[UIColor darkGrayColor];
    
    
    //add label for photo title and photo description
    UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(20, 60, 80, 30)];
    title.text=@"Title";
    title.textColor=lblTextColor;
    title.font=[UIFont fontWithName:@"Verdana" size:13];
    
    photoTitleTF=[[UITextField alloc] initWithFrame:CGRectMake(100, 60, 140, 30)];
    photoTitleTF.layer.borderWidth=0.3;
    photoTitleTF.backgroundColor=[UIColor whiteColor];
    [photoTitleTF setDelegate:self];
    
    UILabel *description=[[UILabel alloc] initWithFrame:CGRectMake(20, 110, 80, 30)];
    description.text=@"Description";
    description.textColor=lblTextColor;
    description.font=[UIFont fontWithName:@"Verdana" size:13];
    
    photoDescriptionTF=[[UITextView alloc] initWithFrame:CGRectMake(100, 110, 140, 70)];
    photoDescriptionTF.layer.borderWidth=0.3;
    photoDescriptionTF.backgroundColor=[UIColor whiteColor];
    [photoDescriptionTF setDelegate:self];
    
    
    UILabel *tag=[[UILabel alloc] initWithFrame:CGRectMake(20, 200, 80, 30)];
    tag.text=@"Tag";
    tag.textColor=lblTextColor;
    tag.font=[UIFont fontWithName:@"Verdana" size:13];
    
    phototagTF=[[UITextField alloc] initWithFrame:CGRectMake(100, 200, 140, 30)];
    phototagTF.layer.borderWidth=0.3;
    phototagTF.backgroundColor=[UIColor whiteColor];
    [phototagTF setDelegate:self];
    
    UIButton *cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(100, 250, 65, 30)];
    
    //cancelButton.backgroundColor=btnBorderColor;
    cancelButton.layer.cornerRadius=5;
    cancelButton.layer.borderColor=btnBorderColor.CGColor;
    cancelButton.layer.borderWidth=1;
    
    cancelButton.titleLabel.font=[UIFont fontWithName:@"Verdana" size:13];
    [cancelButton setTitleColor:btnTextColor forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(removebackViewPhotDetail) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *save=[[UIButton alloc] initWithFrame:CGRectMake(170, 250, 70, 30)];
    
    //addButton.backgroundColor=btnBorderColor;
    save.layer.cornerRadius=5;
    save.layer.borderColor=btnBorderColor.CGColor;
    save.layer.borderWidth=1;
    
    save.titleLabel.font=[UIFont fontWithName:@"Verdana" size:13];
    [save setTitleColor:btnTextColor forState:UIControlStateNormal];
    
    
    [save setTitle:@"Save" forState:UIControlStateNormal];
    [save addTarget:self action:@selector(savePhotoDetail) forControlEvents:UIControlEventTouchUpInside];
    [addPhotoDescriptionView addSubview:headLbl];
    [addPhotoDescriptionView addSubview:title];
    [addPhotoDescriptionView addSubview:description];
    [addPhotoDescriptionView addSubview:tag];
    [addPhotoDescriptionView addSubview:photoTitleTF];
    [addPhotoDescriptionView addSubview:photoDescriptionTF];
    [addPhotoDescriptionView addSubview:phototagTF];
    [addPhotoDescriptionView addSubview:cancelButton];
    [addPhotoDescriptionView addSubview:save];
    
    [backViewPhotDetail addSubview:addPhotoDescriptionView];
    [self.view addSubview:backViewPhotDetail];
    
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    //[self.view endEditing:YES];
}
-(void)removebackViewPhotDetail
{
    photoTitleStr=@"Untitle";
    photoDescriptionStr=@"";
    photoTagStr=@"";
    [self savePhotosOnServer:userid filepath:imgData];
    [backViewPhotDetail removeFromSuperview];
}

-(void)savePhotoDetail
{
    if(photoTitleTF.text.length>0)
    {
        photoTitleStr=photoTitleTF.text;
    }
    else
    {
        photoTitleStr=@"Untitle";
    }
    if(photoDescriptionTF.text.length>0)
    {
        photoDescriptionStr=photoDescriptionTF.text;
    }
    else
    {
        photoDescriptionStr=@"";
    }
    if(phototagTF.text.length>0)
    {
        photoTagStr=phototagTF.text;
    }
    else
    {
        photoTagStr=@"";
    }
    
    [self savePhotosOnServer:userid filepath:imgData];
    [backViewPhotDetail removeFromSuperview];
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
   
    
    UILabel *photoTitleLBL=[[UILabel alloc] init];
    //get photo info from nsuser default
    NSArray *photoDetail=[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]];
    photoTitleLBL.text=[[photoDetail objectAtIndex:self.selectedIndex ] objectForKey:@"collection_photo_title"];
    photoTitleLBL.textAlignment=NSTextAlignmentCenter;
    
    if([manager isiPad])
    {
        button.frame = CGRectMake(0.0, 105.0, 90.0, 40.0);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
        photoTitleLBL.frame=CGRectMake(self.view.center.x-75, 105.0, 150.0, 40.0);
        photoTitleLBL.font = [UIFont systemFontOfSize:23.0f];
        
    }
    else
    {
        button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        photoTitleLBL.frame=CGRectMake(60, 50, 200, 30);
        photoTitleLBL.font = [UIFont systemFontOfSize:17.0f];
    }
    
    
    [navnBar addSubview:photoTitleLBL];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];

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
            
            photoLocationStr=location;
            
            
            NSLog(@"Current location is %@",location);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
    [locationManager stopUpdatingLocation];
}

@end
