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
#import "EditPhotoDetailViewController.h"

@interface NoStatusBarImagePickerController : UIImagePickerController
@end

@implementation NoStatusBarImagePickerController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

@end

@interface LaunchCameraViewController ()

@end

@implementation LaunchCameraViewController
@synthesize isFromHomePage,sessions,assetLibrary;

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
    
    imgView.contentMode=UIViewContentModeScaleAspectFit;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    if([[manager getData:@"isfromphotodetailcontroller"] isEqualToString:@"yes"])
    {
        selectedCollectionId=@0;
        [self callGetLocation];
        
        photoTitleStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_title"];
        photoDescriptionStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_description"];
        photoTagStr=[[manager getData:@"takephotodetail"] objectForKey:@"photo_tags"];
        
        imgData=[manager getData:@"photo_data"];
        
        [manager storeData:@"no" :@"isfromphotodetailcontroller"];
       [manager storeData:@"" :@"takephotodetail"];
        [manager storeData:@"" :@"photo_data"];
    }
    else
    {
        
        [self getCollectionInfoFromUserDefault];
        [self addCustomNavigationBar];
        
        if(!isCameraMode)
        {
            photoLocationStr=@"";
            [self callGetLocation];
            //imagePicker
            UIImagePickerController *picker=[[UIImagePickerController alloc] init];
            picker.delegate=self;
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                
                picker.sourceType=UIImagePickerControllerSourceTypeCamera;
                isCameraMode=YES;
                
                
            }
            else
            {
                picker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            
            [picker childViewControllerForStatusBarHidden];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                [self presentViewController:picker animated:YES completion:nil];
            }else{
                [self presentViewControllerInPopover:picker];
            }
        }

    }
    
}
- (void) presentViewControllerInPopover:(UIViewController *)controller
{
    //CGRect sourceRect = [[self choosePhotoButton] frame];
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popover setDelegate:self];
    [self setPopover:popover];
    [self setShouldReleasePopover:YES];
    
    CGRect popoverFrame=CGRectMake(50, 400,444, 50);
    [self.popover presentPopoverFromRect:CGRectMake(270, 200, 500, 300) inView:self.view               permittedArrowDirections:0  animated:YES];
}
- (void) dismissPopoverWithCompletion:(void(^)(void))completion
{
    [[self popover] dismissPopoverAnimated:YES];
    [self setPopover:nil];
    
    NSTimeInterval delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        completion();
    });
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([self shouldReleasePopover]){
        [self setPopover:nil];
    }
    [self setShouldReleasePopover:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    isCameraMode=NO;
    
}
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


-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
    
}


-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
    @try {
        for (int i=0;i<collection.count+1; i++)
        {
            if(i==0)
            {
                [collectionIdArray addObject:@0];
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
                    }
                    [collectionIdArray addObject:[[collection objectAtIndex:i-1] objectForKey:@"collection_id"]];
                    [collectionNameArray addObject:[[collection objectAtIndex:i-1] objectForKey:@"collection_name"]];
                    
                }
                
            }
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exec is %@",exception.description);
    }
    @finally {
        
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
    isCameraMode=NO;
    [self dismissViewControllerAnimated:YES completion:nil];
     [self goToHomePage];
    
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    imgView.image=image;
    pickImage=image;
    isCameraEditMode=YES;
    @try {
        if (isCameraEditMode) {
            isCameraEditMode = false ;
            [NSTimer scheduledTimerWithTimeInterval:1.0f   target:self selector:@selector(openeditorcontrol) userInfo:nil  repeats:NO];
            
        }
            
            [self dismissViewControllerAnimated:NO completion:Nil];
        
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
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


-(void)webserviceCallback:(NSDictionary *)data
{
    [SVProgressHUD dismiss];
    
    NSLog(@"Data %@",data);
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if(isColletionCreateMode)
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutData=[data objectForKey:@"output_data"];
            selectedCollectionId= [[outPutData objectAtIndex:0] objectForKey:@"collection_id"];//New created collection id
            isColletionCreateMode=NO;
            //upade collection info in  nsUser Default
            NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];
            NSMutableDictionary *newCol=[[NSMutableDictionary alloc] init];
            [newCol setObject:@0 forKey:@"collection_default"];
            [newCol setObject:selectedCollectionId forKey:@"collection_id"];
            [newCol setObject:folderName.text forKey:@"collection_name"];
            [newCol setObject:@0 forKey:@"collection_shared"];
            [newCol setObject:@0 forKey:@"collection_sharing"];
            [newCol setObject:userid forKey:@"collection_user_id"];
            
            [collection addObject:newCol];
            [manager storeData:collection :@"collection_data_list"];

            [self categoryDoneButtonPressed];//For save the photo
        }
    }
    else if (isPhotoSavingMode)
    {
        if(exitCode.integerValue==1)
        {
            if(selectedCollectionId.integerValue==publicCollectionId.integerValue)
            {
                //for public imgarray count lbl for home page
                NSNumber *imgCout=[manager getData:@"publicImgIdArray"];
                int i=imgCout.integerValue+1;
                [manager storeData:[NSNumber numberWithInt:i] :@"publicImgIdArray"];
            }
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


-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"select tabbar");
}

//Picker view for select folder option
//Picker view for select folder option
-(void)showSelectFolderOption
{
    @try {
        backView1=[[UIView alloc] initWithFrame:self.view.frame];
        //categoryPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-180, self.view.frame.size.width,120)];
        categoryPickerView.backgroundColor=[UIColor whiteColor];
        [categoryPickerView setDataSource: self];
        [categoryPickerView setDelegate: self];
        categoryPickerView.showsSelectionIndicator = YES;
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapGestureRecognized:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        
        [categoryPickerView addGestureRecognizer:gestureRecognizer];
        
        if([manager isiPad])
        {
            pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-260, 320, 40)];
        }
        else
        {
            pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height-218, 320, 40)];
        }
        
        pickerToolbar.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleWidth;
        
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
        //add folder button
        UIBarButtonItem *addFolder=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewFolderView)];
        
        [barItems addObject:flexSpace];
        //[barItems addObject:addFolder];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(categoryDoneButtonPressed)];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
        /* //add new folder buton on picker ivew
         addNewFolder=[UIButton buttonWithType:UIButtonTypeRoundedRect];
         [addNewFolder setTitle:@"Add New Folder" forState:UIControlStateNormal];
         addNewFolder.frame=CGRectMake(10, categoryPickerView.frame.origin.y, 150, 30);
         addNewFolder.layer.borderWidth=1;
         addNewFolder.layer.borderColor=[UIColor blueColor].CGColor;
         [addNewFolder addTarget:self action:@selector(addNewFolderView) forControlEvents:UIControlEventTouchUpInside];
         
         */
        
        [self.view addSubview:backView1];
        [self.view addSubview:pickerToolbar];
        [self.view addSubview:categoryPickerView];
        
         //[self addPhotoDescriptionView];
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
    
    [self goToPhotoDetailViewControoler];
}
-(void)goToPhotoDetailViewControoler
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
    editDetail.isFromLaunchCamera=YES;
    
    [manager storeData:imgData :@"photo_data"];
    
    [self.navigationController pushViewController:editDetail animated:NO];
}
- (void)pickerViewTapGestureRecognized:(UITapGestureRecognizer*)gestureRecognizer
{
    //CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view.superview];
    
    //CGRect frame = categoryPickerView.frame;
    //CGRect selectorFrame = CGRectInset( frame, 0.0, categoryPickerView.bounds.size.height * 0.85 / 2.0 );
    
    NSLog( @"Selected Row: %i", [categoryPickerView selectedRowInComponent:0] );
    if([categoryPickerView selectedRowInComponent:0]==0)
    {
        [self addNewFolderView];
    }
}
-(void)addPhotoDescriptionView
{
    float textFieldBorderWidth=0.3;
    if([manager isiPad])
    {
        textFieldBorderWidth=0.8f;
    }
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
    photoTitleTF.layer.borderWidth=textFieldBorderWidth;
    photoTitleTF.backgroundColor=[UIColor whiteColor];
    [photoTitleTF setDelegate:self];
    
    UILabel *description=[[UILabel alloc] initWithFrame:CGRectMake(20, 110, 80, 30)];
    description.text=@"Description";
    description.textColor=lblTextColor;
    description.font=[UIFont fontWithName:@"Verdana" size:13];
    
    photoDescriptionTF=[[UITextView alloc] initWithFrame:CGRectMake(100, 110, 140, 70)];
    photoDescriptionTF.layer.borderWidth=textFieldBorderWidth;
    photoDescriptionTF.backgroundColor=[UIColor whiteColor];
    [photoDescriptionTF setDelegate:self];
    
    
    UILabel *tag=[[UILabel alloc] initWithFrame:CGRectMake(20, 200, 80, 30)];
    tag.text=@"Tag";
    tag.textColor=lblTextColor;
    tag.font=[UIFont fontWithName:@"Verdana" size:13];
    
    phototagTF=[[UITextField alloc] initWithFrame:CGRectMake(100, 200, 140, 30)];
    phototagTF.layer.borderWidth=textFieldBorderWidth;
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
    [self.view endEditing:YES];
}
-(void)addNewFolderView
{
    float textFieldBorderWidth=0.3;
    if([manager isiPad])
    {
        textFieldBorderWidth=0.8f;
    }
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    UIColor *btnTextColor=[UIColor colorWithRed:0.094 green:0.427 blue:0.933 alpha:1];
    backView2=[[UIView alloc] initWithFrame:self.view.frame];
    
    backView2.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    backView2.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    
    UIView *addFolderView=[[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-100, self.view.center.y-120, 200, 160)];
    addFolderView.layer.borderWidth=1;
    addFolderView.layer.borderColor=[UIColor blackColor].CGColor;
    addFolderView.layer.cornerRadius=8;
    addFolderView.backgroundColor=[UIColor whiteColor];
    
    
    addFolderView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    UILabel *headLbl=[[UILabel alloc] initWithFrame:CGRectMake(30, 10, 150, 30)];
    headLbl.text=@"Add New Folder";
    headLbl.layer.cornerRadius=5;
    headLbl.textAlignment=NSTextAlignmentCenter;
    headLbl.textColor=btnTextColor;
    //headLbl.backgroundColor=[UIColor darkGrayColor];
    folderName=[[UITextField alloc] initWithFrame:CGRectMake(15, 60, 170, 30)];
    folderName.layer.borderColor=[UIColor grayColor].CGColor;
    folderName.layer.borderWidth=textFieldBorderWidth;
    
    folderName.backgroundColor=[UIColor whiteColor];
    [folderName setDelegate:self];
    
    UIButton *cancelButton=[[UIButton alloc] initWithFrame:CGRectMake(15, 100, 65, 30)];
    
    //cancelButton.backgroundColor=btnBorderColor;
    cancelButton.layer.cornerRadius=5;
    cancelButton.layer.borderColor=btnBorderColor.CGColor;
    cancelButton.layer.borderWidth=1;
    
    cancelButton.titleLabel.font=[UIFont fontWithName:@"Verdana" size:13];
    [cancelButton setTitleColor:btnTextColor forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(removeBackView2) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addButton=[[UIButton alloc] initWithFrame:CGRectMake(90, 100, 95, 30)];
    
    //addButton.backgroundColor=btnBorderColor;
    addButton.layer.cornerRadius=5;
    addButton.layer.borderColor=btnBorderColor.CGColor;
    addButton.layer.borderWidth=1;
    
    addButton.titleLabel.font=[UIFont fontWithName:@"Verdana" size:13];
    [addButton setTitleColor:btnTextColor forState:UIControlStateNormal];
    
    
    [addButton setTitle:@"Add Folder" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(createNewFolder) forControlEvents:UIControlEventTouchUpInside];
    [addFolderView addSubview:headLbl];
    [addFolderView addSubview:folderName];
    [addFolderView addSubview:cancelButton];
    [addFolderView addSubview:addButton];
    
    [backView2 addSubview:addFolderView];
    [self.view addSubview:backView2];
}
-(void)removebackViewPhotDetail
{
    photoTitleStr=@"Untitle";
    photoDescriptionStr=@"";
    photoTagStr=@"";
    [backViewPhotDetail removeFromSuperview];
}
-(void)removeBackView2
{
    [backView2 removeFromSuperview];
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
    [backViewPhotDetail removeFromSuperview];
}


-(void)createNewFolder
{
    if(folderName.text.length>0)
    {
        [self addCollectionInfoInServer:folderName.text  writeUserIds:@"" readUserIds:@""];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Enter Folder Name" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}
//store collection info in server
-(void)addCollectionInfoInServer:(NSString *)collectionName writeUserIds:(NSString *)writeUserIds readUserIds:(NSString *)readUserIds
{
    isColletionCreateMode=YES;
    
    webservices.delegate=self;
    
    NSDictionary *dicData=@{@"user_id":userid,@"collection_name":collectionName,@"collection_sharing":@"0",@"collection_write_user_ids":writeUserIds,@"collection_read_user_ids":readUserIds};
    @try {
        [webservices call:dicData controller:@"collection" method:@"store"];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imageData
{
    
    [SVProgressHUD showWithStatus:@"Photo is saving" maskType:SVProgressHUDMaskTypeBlack];
    isPhotoSavingMode=YES;
    
    webservices.delegate=self;
    
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":selectedCollectionId};
    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
    NSLog(@"%@",[collectionIdArray objectAtIndex:row]);
    if(row!=0)
    {
        selectedCollectionId=[collectionIdArray objectAtIndex:row];
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

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 320;
    
    return sectionWidth;
}

-(void)categoryDoneButtonPressed{
    NSLog(@"selected index is %@",selectedCollectionId);
    if(selectedCollectionId==nil)
    {
        selectedCollectionId=[collectionIdArray objectAtIndex:0];
    }
    
    [self savePhotosOnServer:userid filepath:imgData];
    
    
}
-(void)removePickerView
{
    [categoryPickerView removeFromSuperview];
    [pickerToolbar removeFromSuperview];
    [backView1 removeFromSuperview];
    [backView2 removeFromSuperview];
    [addNewFolder removeFromSuperview];
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
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];
    
    if([manager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :false];
        }
    }
    else
    {
        //code for iphone navigation
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :false];
        }
    }
    
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)goToHomePage
{
    if(isFromHomePage)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        [manager storeData:@"YES" :@"istabcamera"];
        [delgate.tbc setSelectedIndex:0];
    }
   
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
