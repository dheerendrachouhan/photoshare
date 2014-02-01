//
//  PhotoGalleryViewController.m
//  photoshare
//
//  Created by ignis2 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PhotoGalleryViewController.h"
#import "ContentManager.h"
#import "Base64.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "WebserviceController.h"
#import "EditPhotoViewController.h"
#import "SVProgressHUD.h"
@interface PhotoGalleryViewController ()

@end

@implementation PhotoGalleryViewController
@synthesize isPublicFolder,selectedFolderIndex,folderName;
@synthesize library,collectionId,userID;
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
    
    //initialize the WebService Object
    webServices=[[WebserviceController alloc] init];
    
    selectedImagesIndex=[[NSMutableArray alloc] init];
    //initialize the assets Library
    library=[[ALAssetsLibrary alloc] init];
    
    //set the design of the button
    UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    float btnBorderWidth=2;
    float btnCornerRadius=8;
    addPhotoBtn.layer.cornerRadius=btnCornerRadius;
    addPhotoBtn.layer.borderWidth=btnBorderWidth;
    addPhotoBtn.layer.borderColor=btnBorderColor.CGColor;
    
    deletePhotoBtn.layer.cornerRadius=btnCornerRadius;
    deletePhotoBtn.layer.borderWidth=btnBorderWidth;
    deletePhotoBtn.layer.borderColor=btnBorderColor.CGColor;
    
    sharePhotoBtn.layer.cornerRadius=btnCornerRadius;
    sharePhotoBtn.layer.borderWidth=btnBorderWidth;
    sharePhotoBtn.layer.borderColor=btnBorderColor.CGColor;
    
    //collection view
    [collectionview registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    
    //tapGesture
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [collectionview addGestureRecognizer:tapGesture];
    
    //add the LongPress gesture to the collection view
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPressGesture.minimumPressDuration=0.6;
    [collectionview addGestureRecognizer:longPressGesture];
    
    
    //for Aviary
    // Allocate Asset Library
    ALAssetsLibrary * assetLibrary = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary];
    
    // Allocate Sessions Array
    NSMutableArray * sessions = [NSMutableArray new];
    [self setSessions:sessions];
    
    // Start the Aviary Editor OpenGL Load
    [AFOpenGLManager beginOpenGLLoad];
    
    //aviary End
    isAviaryMode=NO;
    photoArray=[[NSMutableArray alloc] init];
     photoIdsArray=[[NSMutableArray alloc] init];
   

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //initialize the photo Array
    
    //editBtn
    editBtn = [[UIButton alloc] init];    
    //get the user id from nsuserDefaults
    ContentManager *manager=[ContentManager sharedManager];
    userid=[manager getData:@"user_id"];
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.frame=CGRectMake(0, 70, 320,30);
    frameForShareBtn=sharePhotoBtn.frame;
    
    isGetPhotoFromServer=NO;
    isGetPhotoIdFromServer=NO;
    isSaveDataOnServer=NO;
    
    //set
    [self setDataForCollectionView];
    
    if(isAviaryMode==NO)
    {
         [self getPhotoIdFromServer];
    }
    
    
    
}
-(void)getDataFromNSUSerDefault
{
    photoAssetUrlArray=[[NSMutableArray alloc] init];
    NSMutableArray *photo_data=[[[NSUserDefaults standardUserDefaults] objectForKey:@"photo_data"] mutableCopy];
    
    for (int i=0;i<photo_data.count;i++)
    {
        NSDictionary *dic=[photo_data objectAtIndex:i];
        if([[dic objectForKey:@"collection_id"] isEqualToString:@"3"])
        {
        NSURL *url=[dic objectForKey:@"image_asset_url"];
        [photoAssetUrlArray addObject:url];
        }
    }
       // [photoAssetUrlArray addObject:[dic objectForKey:@"ImageAssetUrl"]];
    
}
-(void)setDataForCollectionView
{
    imgArray = [[NSMutableArray alloc] init];
    
    if(self.isPublicFolder==YES)
    {
        //set title
     self.navigationController.navigationBar.topItem.title=@"Public Folder";
    }
    else
    {
        //set Folder Name in Right Side of navigation bar
        NSString *folderNa=self.folderName;
        
      
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 25)];
        label.text=folderNa;
        //label.textAlignment=NSTextAlignmentRight;
        UIBarButtonItem *foldernameButton = [[UIBarButtonItem alloc] initWithCustomView:label] ;
        [foldernameButton setWidth:100];
        
        UIButton *iconbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        iconbtn.frame=CGRectMake(0, 0, 18, 18);
        [iconbtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        iconbtn.userInteractionEnabled=NO;
        UIBarButtonItem *editBtnIcon=[[UIBarButtonItem alloc]
                                  initWithCustomView:iconbtn] ;
        NSArray *itemArray=[[NSArray alloc] initWithObjects:foldernameButton,editBtnIcon,nil];
        self.navigationItem.rightBarButtonItems=itemArray;
        
    }
    
        
}

-(IBAction)addPhoto:(id)sender
{
    isNotFirstTime=YES;
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"From Camera" otherButtonTitles:@"From Gallery ", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
//action sheet delegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
    imagePicker.delegate=self;
    
    if(buttonIndex==0)  //From Camera
    {
        NSLog(@"camera");
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error" message:@"Camera is Not Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
            [alert show];
        }
    }
    else if(buttonIndex==1)//From Gallery
    {
        NSLog(@"gallery");
        imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex==2)//Cancel Button
    {
        NSLog(@"Cancel Button Click");
    }
}
-(void)resetAllBoolValue
{
    isGetPhotoFromServer=NO;
    isGetPhotoIdFromServer=NO;
    isSaveDataOnServer=NO;
    isEditImageFromServer=NO;
    isDeleteMode=NO;
   
}

//get PhotoId From Server
-(void)getPhotoIdFromServer
{
    [self resetAllBoolValue];
    isGetPhotoIdFromServer=YES;
    
    webServices.delegate=self;
   // NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_id=%d",[NSNumber numberWithInt:usrId],self.collectionId];
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
    
    [webServices call:dicData controller:@"collection" method:@"get"];
}
//get Photo From Server
-(void)getPhotoFromServer
{
    [self resetAllBoolValue];
        isGetPhotoFromServer=YES;
        if(photoIdsArray.count>0)
        {
            [SVProgressHUD showWithStatus:@"Photo is Loaded From Server" maskType:SVProgressHUDMaskTypeBlack];
            deleteImageCount=0;
            for (int i=0; i<photoIdsArray.count; i++) {
                webServices.delegate=self;
                NSNumber *num = [NSNumber numberWithInt:1] ;
                NSDictionary *dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:i],@"get_image":num,@"collection_id":self.collectionId,@"image_resize":@"0"};
                
                [webServices call:dicData controller:@"photo" method:@"get"];
               
            }
            
    }
}
//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imgData photoTitle:(NSString *)photoTitle photoDescription:(NSString *)photoDescription photoCollection:(NSString *)photoCollection
{
    [self resetAllBoolValue];
    isSaveDataOnServer=YES;
    isNotFirstTime=YES;
    
    webServices=[[WebserviceController alloc] init];
    
    webServices.delegate=self;
    [SVProgressHUD showWithStatus:@"Photo is Loaded From Server" maskType:SVProgressHUDMaskTypeBlack];
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitle,@"photo_description":photoDescription, @"photo_collections":photoCollection};
    //store data
   // [webServices call:data controller:@"photo" method:@"store"];
    [webServices saveFileData:dic controller:@"photo" method:@"store" filePath:imgData] ;
    
}
//deletePhotoFromServer
-(void)deletePhotoFromServer :(NSNumber *)usrId photoId:(NSNumber *)photoId
{
    [self resetAllBoolValue];
    isDeleteMode=YES;
     webServices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"photo_id":photoId};
    [webServices call:dicData controller:@"photo" method:@"delete"];
    
}

-(void)getImageFromServerForEdit :(int)selectedIndex
{
    [self resetAllBoolValue];
    isEditImageFromServer=YES;
    NSNumber *num = [NSNumber numberWithInt:1] ;
    webServices.delegate=self;
    NSDictionary *dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:selectedIndex],@"get_image":num,@"collection_id":self.collectionId};
    [SVProgressHUD showWithStatus:@"Image is Loaded" maskType:SVProgressHUDMaskTypeBlack];
    [webServices call:dicData controller:@"photo" method:@"get"];
}
-(void) webserviceCallbackImage:(UIImage *)image
{
    //UIImageView *img = [[UIImageView alloc] initWithImage:image] ;
    //[self.view addSubview:img] ;
    if(isEditImageFromServer)
    {
        [SVProgressHUD dismiss];
        [self launchPhotoEditorWithImage:image highResolutionImage:image];
        
    }
    else
    {
        [photoArray addObject:image];
        
        [SVProgressHUD dismiss];
        [collectionview reloadData];
    }
    
    

}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSDictionary *outputData=[data objectForKey:@"output_data"];
    
    NSLog(@"outPutData is %@",outputData);
    
    int exitcode=[[data objectForKey:@"exit_code"] integerValue];
    if(exitcode==1)
    {
       
       // photoInfoArray = [[NSMutableArray alloc] init];
        if(isGetPhotoIdFromServer)
        {
            
            
                NSDictionary *collectionContent=[outputData objectForKey:@"collection_contents"];
                if(collectionContent.count>0)
                {
                    
                    isGetPhotoIdFromServer=NO;
                    if(isNotFirstTime)
                    {
                        
                    }
                    else
                    {
                        
                        [photoIdsArray addObjectsFromArray:[collectionContent allKeys]];
                        [self getPhotoFromServer];
                    }
                    
                }
                else
                {
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photos Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                    [alert show];
                }
            
        }
        else if(isSaveDataOnServer)
        {
            
            isAviaryMode=NO;
            if(isNotFirstTime)
            {
                
                [photoIdsArray addObject:[outputData objectForKey:@"image_id"]];
                [SVProgressHUD dismiss];
            }
            else
            {
                [self getPhotoIdFromServer];
                [collectionview reloadData];
            }
           
        }
       
    }
    else
    {
        
    }
}
-(IBAction)deletePhoto:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.selected==NO)
    {
        NSLog(@"Not selected");
        addPhotoBtn.hidden=YES;
        sharePhotoBtn.hidden=YES;
        isDeleteMode=YES;
    }
    else
    {
        //sort the index array in descending order
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO] ;
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        
        sortedArray = [selectedImagesIndex sortedArrayUsingDescriptors:sortDescriptors];
        if(sortedArray.count>0)
        {
            //[SVProgressHUD showWithStatus:@"Please Wait Photo is Deleted " maskType:SVProgressHUDMaskTypeBlack];
            deleteImageCount=0;
            for(int i=0;i<sortedArray.count;i++)
            {
                [self deletePhotoFromServer:userid photoId:[photoIdsArray objectAtIndex:[[sortedArray objectAtIndex:i] integerValue]]];
                [photoArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                [photoIdsArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
            }
            [collectionview reloadData];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photo Selected" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
        }
         [self resetButton];
    }
    
        NSLog(@"Selected");
    
   
    btn.selected=!btn.selected;
}

-(IBAction)sharePhoto:(id)sender
{
    
    UIButton *btn=(UIButton *)sender;
    if(btn.selected==NO)
    {
        NSLog(@"Not selected");
        addPhotoBtn.hidden=YES;
        deletePhotoBtn.hidden=YES;
        sharePhotoBtn.frame=deletePhotoBtn.frame;
        isShareMode=YES;
    }
    else
    {
        NSLog(@"Selected");
        [self resetButton];

    }
    
    btn.selected=!btn.selected;

}
//reset the button hidden no and previous frame
-(void)resetButton
{
    addPhotoBtn.hidden=NO;
    deletePhotoBtn.hidden=NO;
    sharePhotoBtn.hidden=NO;
    
    sharePhotoBtn.frame=frameForShareBtn;
    isShareMode=NO;
    isDeleteMode=NO;
    
    [selectedImagesIndex removeAllObjects];
}

-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    //if editBtnIs in view
    [editBtn removeFromSuperview];
    
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
        if(isDeleteMode || isShareMode)
        {
            if(cell.selected==NO)
            {
                UIImageView *checkBoxImg=[[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width-25,15, 20, 20)];
                checkBoxImg.layer.masksToBounds=YES;
                checkBoxImg.image=[UIImage imageNamed:@"iconr3.png"];
                checkBoxImg.tag=1001;
                [cell.contentView addSubview:checkBoxImg];
                
                [selectedImagesIndex addObject:[NSNumber numberWithInteger:[indexPath row]]];
            }
            else
            {
                UIImageView *checkBox=(UIImageView *)[cell viewWithTag:1001];
                [checkBox removeFromSuperview];
                [selectedImagesIndex removeObject:[NSNumber numberWithInteger:[indexPath row]]];
            }
        }
        else  //view Image
        {
            [self viewPhoto:indexPath];
        }
        cell.selected=!cell.selected;
    }
}
-(void)longPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
        editBtn.frame=CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+5, 60, 50);
        [editBtn setImage:[UIImage imageNamed:@"edit_btn.png"] forState:UIControlStateNormal];
        [editBtn addTarget:self action:@selector(editImage:) forControlEvents:UIControlEventTouchUpInside];
        [collectionview addSubview:editBtn];
    }
}
-(void)viewPhoto :(NSIndexPath *)indexPath
{
    
}
-(void)editImage:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    CGPoint p=CGPointMake(btn.frame.origin.x, btn.frame.origin.y+20);
    NSIndexPath *indexPath=[collectionview indexPathForItemAtPoint:p];
  UIImage *image=  [photoArray objectAtIndex:[indexPath row]];
    [self launchPhotoEditorWithImage:image highResolutionImage:image];
    //[self getImageFromServerForEdit:indexPath.row];
    //if editBtnIs in view
    [editBtn removeFromSuperview];
}

//imagePicker delegate Method
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    //set the asset url in String
    assetUrlOfImage=[NSString stringWithFormat:@"%@",assetURL];
    
    isAviaryMode=YES;
    
    //UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    void(^completion)(void)  = ^(void){
        
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset){
                [self launchEditorWithAsset:asset];
            }
        } failureBlock:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's  photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }];
    };
    
    [self dismissViewControllerAnimated:YES completion:completion];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [photoArray count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imgView.layer.masksToBounds=YES;
    imgView.tag=100;
    
   
    
    [imgView setImage:[photoArray objectAtIndex:indexPath.row]];
    [cell.contentView addSubview:imgView];
    
    return cell;
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
    
    __block PhotoGalleryViewController * blockSelf = self;
    
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
    //[[self imagePreviewView] setImage:image];
    //[[self imagePreviewView] setContentMode:UIViewContentModeScaleAspectFit];
    //[self.assetLibrary saveImage:image toAlbum:@"Public" withCompletionBlock:^(NSError *error) {
       // if (error!=nil) {
           // NSLog(@"Big error: %@", [error description]);
       // }
   // }];
    NSData *imageData = UIImagePNGRepresentation(image);
    isAviaryMode=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    //add image in collection Array
    [photoArray addObject:image];
    [collectionview reloadData];
    [self savePhotosOnServer:userid filepath:imageData photoTitle:@"" photoDescription:@"" photoCollection:[NSString stringWithFormat:@"%@",self.collectionId]];
    
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
