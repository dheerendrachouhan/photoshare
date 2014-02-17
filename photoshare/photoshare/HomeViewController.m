//
//  HomeViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "HomeViewController.h"
#import "ContentManager.h"
#import "AppDelegate.h"
#import "CommunityViewController.h"
#import "PhotoGalleryViewController.h"
#import "CommonTopView.h"
#import "EarningViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "NavigationBar.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
{
    NSString *servicesStr;
    NSNumber *userID;
    NavigationBar *navnBar;
}
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
    //LoginViewController *loginv = [[LoginViewController alloc] init] ;
    //[self.navigationController presentViewController:loginv animated:NO completion:nil];
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    //initialize the collectionId and name array
    collectionIdArray=[[NSMutableArray alloc] init];
    collectionNameArray=[[NSMutableArray alloc] init];
    
    //rounded the Community Count Label
    photoCountLbl.layer.cornerRadius=12;
    photoCountLbl.layer.borderWidth=2;
    photoCountLbl.layer.borderColor=[[UIColor whiteColor] CGColor];
    
    
    [self setContent];
    
    //for Aviary
    // Allocate Asset Library
    ALAssetsLibrary * assetLibrary = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary];
    
    // Allocate Sessions Array
    NSMutableArray * sessions = [NSMutableArray new];
    [self setSessions:sessions];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
     dmc = [[DataMapperController alloc] init];
    
    userID = [NSNumber numberWithInteger:[[dmc getUserId] integerValue]];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
    if (isCameraEditMode) {
        isCameraEditMode = false ; 
        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                         target:self
                                       selector:@selector(openeditorcontrol)
                                       userInfo:nil
                                        repeats:NO];        
        
    }
   UIView *vi = [self.tabBarController.view viewWithTag:11];
    
   UILabel *lbl = (UILabel *)[vi viewWithTag:1] ;
    
    NSDictionary *dic = [dmc getUserDetails] ;
    NSNumber *total = [dic objectForKey:@"total_earnings"] ;
    lbl.text = [NSString  stringWithFormat:@"£%@", total];
    userid=[dic objectForKey:@"user_id"];
    welcomeName.text=[dic objectForKey:@"user_realname"];
    self.navigationController.navigationBarHidden=YES;
    
    NSArray *publicImgArray=[manager getData:@"publicImgArray"];
    if([publicImgArray count]==0)
    {
        photoCountLbl.hidden=YES;
    }
    else
    {
        photoCountLbl.hidden=NO;
        photoCountLbl.text=[NSString stringWithFormat:@"%lu",(unsigned long)[publicImgArray count]];        
    }
    selectedCollectionId=Nil;
    
    //set the collectionid and name in array from nsdefault
    [self getCollectionInfoFromUserDefault];    
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
-(void)setContent
{
    profilePicImgView.image=[UIImage imageNamed:@"homepage.jpg"];
}
-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[[manager getData:@"collection_data_list"] mutableCopy];
    
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
                    [collectionIdArray addObject:[[collection objectAtIndex:i-1] objectForKey:@"collection_id"]];
                    [collectionNameArray addObject:[[collection objectAtIndex:i-1] objectForKey:@"collection_name"]];
                    
                }
                if([[[collection objectAtIndex:i-1] objectForKey:@"collection_name"] isEqualToString:@"Public"]||[[[collection objectAtIndex:i-1] objectForKey:@"collection_name"] isEqualToString:@"public"])
                {
                    publicCollectionId=[[collection objectAtIndex:i-1] objectForKey:@"collection_id"];
                    colOwnerId=coluserId;
                    folderIndex=i-1;
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

-(void)getLocation:(NSString *)currentLocation
{
    NSLog(@"Currebt loca is %@",currentLocation);
}
-(IBAction)takePhoto:(id)sender
{
    photoLocationStr=@"";
    [self callGetLocation];
    
    if(imagePicker==nil)
    {
        imagePicker=[[UIImagePickerController alloc] init];
        imagePicker.delegate=self;
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        isCameraMode=YES;
        imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    else
    {
        isCameraMode=NO;
        imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(IBAction)goToPublicFolder:(id)sender
{
    PhotoGalleryViewController *photoGallery;
    if([manager isiPad])
    {
        photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
    }
    photoGallery.isPublicFolder=YES;
    photoGallery.collectionId=publicCollectionId;
    photoGallery.folderName=@"Public";
    photoGallery.selectedFolderIndex=folderIndex;
    photoGallery.collectionOwnerId=colOwnerId;
    [self.navigationController pushViewController:photoGallery animated:YES];
    
}
-(IBAction)goToCommunity:(id)sender
{
    
    //CommunityViewController *comm=[[CommunityViewController alloc] init];
    CommunityViewController *comm;
    if([manager isiPad])
    {
        comm=[[CommunityViewController alloc] initWithNibName:@"CommunityViewController_iPad" bundle:[NSBundle mainBundle]];

    }
    else
    {
        comm=[[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:[NSBundle mainBundle]];
    }
    //AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    comm.isInNavigation=YES;
    [self.navigationController pushViewController:comm animated:YES];
    self.navigationController.navigationBarHidden = NO;
       
}


//imagePicker DelegateMethod
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    //set the asset url in String
    assetUrlOfImage=[NSString stringWithFormat:@"%@",assetURL];
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
      @try {
        if(isCameraMode)
        {
            isCameraEditMode=YES;
            pickImage=image;
            [self dismissViewControllerAnimated:NO completion:Nil];
            
            
        }
        else
        {
            void(^completion)(void)  = ^(void){
                
                [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    if (asset){
                        [self launchEditorWithAsset:asset];
                    }
                } failureBlock:^(NSError *error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }];
            };
            
            [self dismissViewControllerAnimated:NO completion:completion];
        }
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
    [[AFPhotoEditorController inAppPurchaseManager] startObservingTransactions]; 
    [AFPhotoEditorCustomization enableInAppPurchases:YES];
    
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
    
    __block HomeViewController * blockSelf = self;
    
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
    
    [SVProgressHUD dismiss];
    imgData=UIImagePNGRepresentation(image);
    [self dismissViewControllerAnimated:NO completion:nil];
     [self showSelectFolderOption];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
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

- (NSString *)inAppPurchaseManager:(id<AFInAppPurchaseManager>)manager productIdentifierForProduct:(AFPhotoEditorProduct *)product
{
    NSString *internalID = [product internalProductIdentifier];
    if ([internalID isEqualToString:kAFProductEffectsGrunge]) {
        return @"<Your Grunge Identifier>";
    }
    if ([internalID isEqualToString:kAFProductEffectsNostalgia]) {
        return @"<Your Nostalgia Identifier>";
    }
    if ([internalID isEqualToString:kAFProductEffectsViewfinder]) {
        return @"<Your Viewfinder Identifier>";
    }
    return nil;
}


//Picker view for select folder option
-(void)showSelectFolderOption
{
    @try {
         backView1=[[UIView alloc] initWithFrame:self.view.frame];
        categoryPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-180, self.view.frame.size.width,120)];
        categoryPickerView.backgroundColor=[UIColor whiteColor];
        [categoryPickerView setDataSource: self];
        [categoryPickerView setDelegate: self];
        categoryPickerView.showsSelectionIndicator = YES;
        UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapGestureRecognized:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        
        [categoryPickerView addGestureRecognizer:gestureRecognizer];
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
        //add folder button
        UIBarButtonItem *addFolder=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewFolderView)];
        
        [barItems addObject:flexSpace];
        //[barItems addObject:addFolder];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(categoryDoneButtonPressed)];
        [barItems addObject:doneBtn];
        
        [pickerToolbar setItems:barItems animated:YES];
      
       
        [self.view addSubview:backView1];
        [self.view addSubview:pickerToolbar];
        [self.view addSubview:categoryPickerView];
        
        
        [self addPhotoDescriptionView];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
   
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
    [self.view endEditing:YES];
}
-(void)addNewFolderView
{
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    UIColor *btnTextColor=[UIColor colorWithRed:0.094 green:0.427 blue:0.933 alpha:1];
    backView2=[[UIView alloc] initWithFrame:self.view.frame];
    backView2.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
   
    UIView *addFolderView=[[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-100, self.view.center.y-80, 200, 160)];
    addFolderView.layer.borderWidth=1;
    addFolderView.layer.borderColor=[UIColor blackColor].CGColor;
    addFolderView.layer.cornerRadius=8;
    addFolderView.backgroundColor=[UIColor whiteColor];
    
    UILabel *headLbl=[[UILabel alloc] initWithFrame:CGRectMake(30, 10, 150, 30)];
    headLbl.text=@"Add New Folder";
    headLbl.layer.cornerRadius=5;
    headLbl.textAlignment=NSTextAlignmentCenter;
    headLbl.textColor=btnTextColor;
    //headLbl.backgroundColor=[UIColor darkGrayColor];
    folderName=[[UITextField alloc] initWithFrame:CGRectMake(15, 60, 170, 30)];
    folderName.layer.borderWidth=0.3;
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
    
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":[NSString stringWithFormat:@"%@",selectedCollectionId]};
    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imageData] ;
}
-(void)webserviceCallback:(NSDictionary *)data
{
    
    NSLog(@"Data %@",data);
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if([servicesStr isEqualToString:@"two"])
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutDatas =[data objectForKey:@"output_data"];
            NSString *strEarning = [NSString stringWithFormat:@"%@",[outPutDatas valueForKey:@"total_expected_income"]];
            [navnBar setTheTotalEarning:strEarning];
            servicesStr = @"";
        }
    }
    else
    {
        
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
                NSLog(@"Photo saving Suucees ");
            }
            else
            {
                NSLog(@"Photo saving Fail ");
                
                
            }
            isPhotoSavingMode=NO;
            [self removePickerView];
            [SVProgressHUD dismiss];
            
        }
        
        
    }
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    
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
    
}
-(void)categoryCancelButtonPressed{
    
    [self removePickerView];
}

-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    //for home page view controller navBar
    if([manager isiPad])
    {
        navnBar.frame=CGRectMake(0, 20, self.view.frame.size.width, 110);
    }
    else
    {
        navnBar.frame=CGRectMake(0, 20, 320, 60);
    }
    
    [[self view] addSubview:navnBar];
}

-(void)loadData
{
    WebserviceController *wc = [[WebserviceController alloc] init] ;
    wc.delegate = self;
    //NSString *postStr = [NSString stringWithFormat:@"user_id=%@", userID];
    NSDictionary *dictData = @{@"user_id":userID};
    [wc call:dictData controller:@"referral" method:@"calculateincome"];
    servicesStr = @"two";
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

