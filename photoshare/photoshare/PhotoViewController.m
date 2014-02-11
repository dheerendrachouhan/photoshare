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

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize smallImage,photoId,isViewPhoto,folderNameLocation,collectionId,selectedIndex;
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
    //imagePicker
    /*
     
     "collection_photo_description" = dfsdf;
     "collection_photo_filesize" = 1343866;
     "collection_photo_id" = 412;
     "collection_photo_title" = dsfasfd;
     
     */
    
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
    UIImageView *imgV=[[UIImageView alloc ] initWithFrame:self.view.frame];
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
    
    imgData=UIImagePNGRepresentation(image);
    [self dismissViewControllerAnimated:YES completion:nil];
    [self savePhotosOnServer:userid filepath:imgData photoTitle:@"" photoDescription:@"" photoCollection:[NSString stringWithFormat:@"%@",self.collectionId]];
    [manager showAlert:@"Message" msg:@"Photo Edit success" cancelBtnTitle:@"Ok" otherBtn:nil];
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
    NSArray * toolOrder = @[kAFEffects];
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
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData photoTitle:(NSString *)photoTitl photoDescription:(NSString *)photoDescription photoCollection:(NSString *)photoCollection
{
    
    webservices.delegate=self;
    
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitl,@"photo_description":photoDescription, @"photo_collections":photoCollection};
    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Data %@",data);
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
    button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
    // navnBar.backgroundColor = [UIColor redColor];
    
    UILabel *photoTitleLBL=[[UILabel alloc] initWithFrame:CGRectMake(60, 50, 200, 30)];
    //get photo info from nsuser default
    NSArray *photoDetail=[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]];
    photoTitleLBL.text=[[photoDetail objectAtIndex:self.selectedIndex ] objectForKey:@"collection_photo_title"];
    
   
    
    photoTitleLBL.textAlignment=NSTextAlignmentCenter;
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

@end
