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
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return  [textField resignFirstResponder];
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
    isPhotoSavingMode=YES;
    
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
    if(isColletionCreateMode)
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutData=[data objectForKey:@"output_data"];
            selectedCollectionId= [[outPutData objectAtIndex:0] objectForKey:@"collection_id"];//New created collection id
            isColletionCreateMode=NO;
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
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo saving Fail" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
        }
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
        //add folder button
        UIBarButtonItem *addFolder=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewFolderView)];
        
        [barItems addObject:flexSpace];
        [barItems addObject:addFolder];
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
        //[self.view addSubview:addNewFolder];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
    
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
    folderName.layer.borderWidth=1;
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
-(void)removeBackView2
{
    [backView2 removeFromSuperview];
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
    NSLog(@"selected index is %@",selectedCollectionId);
    if(selectedCollectionId==nil)
    {
        selectedCollectionId=[collectionIdArray objectAtIndex:0];
    }
    
    [self savePhotosOnServer:userid filepath:imgData photoTitle:@"" photoDescription:@"" photoCollection:[NSString stringWithFormat:@"%@",selectedCollectionId]];
    
    
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
    
    NavigationBar *navnBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 20, 320, 80)];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
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
