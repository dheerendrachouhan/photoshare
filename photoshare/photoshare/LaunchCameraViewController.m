//
//  LaunchCameraViewController.m
//  photoshare
//
//  Created by ignis2 on 03/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "LaunchCameraViewController.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SVProgressHUD.h"
@interface LaunchCameraViewController ()

@end

@implementation LaunchCameraViewController

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
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [self getCollectionInfoFromUserDefault];
    [self addCustomNavigationBar];
    if (isCameraEditMode) {
        isCameraEditMode = false ;
        [NSTimer scheduledTimerWithTimeInterval:1.0f
        target:self selector:@selector(openeditorcontrol)
      userInfo:nil  repeats:NO];
        
    }
    else
    {
        if(!isCameraMode)
        {
            //imagePicker
            UIImagePickerController *picker=[[UIImagePickerController alloc] init];
            picker.delegate=self;
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
               
                picker.sourceType=UIImagePickerControllerSourceTypeCamera;
            }
            else
            {
                picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            }
            [self presentViewController:picker animated:YES completion:nil];
            isCameraMode=YES;
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    isCameraMode=NO;
    
}
-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
    
}

-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];
    
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
    
    for (int i=0;i<collection.count; i++)
    {
        
        [collectionIdArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_id"]];
        [collectionNameArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_name"]];
        
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//imagePicker DelegateMethod
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   [self goToHomePage];
    isCameraMode=NO;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
   UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    imgView.layer.masksToBounds=YES;
    imgView.image=image;
    @try {
        isCameraMode=NO;
        isCameraEditMode=YES;
            [self dismissViewControllerAnimated:YES completion:nil];
       
        pickImage=image;
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [self dismissViewControllerAnimated:YES completion:Nil];
    }
    
    
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
    [self showSelectFolderOption];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self goToHomePage];
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
    if (![key isEqualToString:@"c5c917dcef9d4377"]) {
        [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You forgot to add your API key!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}


//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData photoTitle:(NSString *)photoTitle photoDescription:(NSString *)photoDescription photoCollection:(NSString *)photoCollection
{
    [SVProgressHUD showWithStatus:@"Photo is saving" maskType:SVProgressHUDMaskTypeBlack];
    webservices.delegate=self;
    
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitle,@"photo_description":photoDescription, @"photo_collections":photoCollection};
    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
    
}
-(void)webserviceCallback:(NSDictionary *)data
{
    [self removePickerView];
    [SVProgressHUD dismiss];
    
    NSLog(@"Data %@",data);
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if(exitCode.integerValue==1)
    {
        NSLog(@"Photo saving Suucees ");
    }
    else
    {
        NSLog(@"Photo saving Fail ");
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo saving Fail" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }

}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"select tabbar");
}

//Picker view for select folder option
-(void)showSelectFolderOption
{
    @try {
        
        categoryPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-180, 320,120)];
        categoryPickerView.backgroundColor=[UIColor whiteColor];
        [categoryPickerView setDataSource: self];
        [categoryPickerView setDelegate: self];
        categoryPickerView.showsSelectionIndicator = YES;
        
        pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-220, 320, 40)];
        pickerToolbar.barStyle = UIBarStyleBlackOpaque;
        [pickerToolbar sizeToFit];
        
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UILabel *titleLabe=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        titleLabe.text=@"Select Folder";
        titleLabe.textAlignment =NSTextAlignmentCenter;
        titleLabe.textColor=[UIColor whiteColor];
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
        
        [self.view addSubview:pickerToolbar];
        [self.view addSubview:categoryPickerView];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    NSLog(@"%@",[collectionIdArray objectAtIndex:row]);
    selectedCollectionId=[collectionIdArray objectAtIndex:row];
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

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 320;
    
    return sectionWidth;
}

-(void)categoryDoneButtonPressed{
    
    [self savePhotosOnServer:userid filepath:imgData photoTitle:@"" photoDescription:@"" photoCollection:[NSString stringWithFormat:@"%@",selectedCollectionId]];
    
}
-(void)removePickerView
{
    [categoryPickerView removeFromSuperview];
    [pickerToolbar removeFromSuperview];
    [self goToHomePage];
}
-(void)categoryCancelButtonPressed{
    
    [self removePickerView];
    
}
#pragma Mark
#pragma Add Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    
    [[self view] addSubview:navnBar];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)goToHomePage
{
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //UITabBarController *tb = (UITabBarController *) self.window.rootViewController ;
    HomeViewController *homeViewController=[[HomeViewController alloc] init];
    [delgate.tbc setSelectedIndex:0];
}
@end
