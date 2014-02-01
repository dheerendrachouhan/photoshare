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
#import "ContentManager.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"


@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        objManager = [ContentManager sharedManager];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    LoginViewController *loginv = [[LoginViewController alloc] init] ;
    [self.navigationController presentViewController:loginv animated:NO completion:nil];
    webservices=[[WebserviceController alloc] init];
    
    
    
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
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isCameraEditMode) {
        isCameraEditMode = false ; 
        [NSTimer scheduledTimerWithTimeInterval:1.0f
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
    ContentManager *manager=[ContentManager sharedManager];
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
   
}

-(void)openeditorcontrol
{
[self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];

}
-(void)setContent
{
    profilePicImgView.image=[UIImage imageNamed:@"wall.jpg"];
}


-(IBAction)takePhoto:(id)sender
{
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
    PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
    photoGallery.isPublicFolder=YES;
    photoGallery.collectionId=@3;
    [self.navigationController pushViewController:photoGallery animated:YES];
    
}
-(IBAction)goToCommunity:(id)sender
{
    
    CommunityViewController *comm=[[CommunityViewController alloc] init];
    AppDelegate *delgate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self.navigationController pushViewController:comm animated:YES];
       
}


//imagePicker DelegateMethod
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    //set the asset url in String
    assetUrlOfImage=[NSString stringWithFormat:@"%@",assetURL];
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
   /* WebserviceController *webServices=[[WebserviceController alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,                                                         NSUserDomainMask, YES);
    
    
    NSString *name=[assetURL lastPathComponent];
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      name ];
    
    NSURL *filePath = [NSURL fileURLWithPath:path];
    webServices.delegate=self;
    NSNumber *userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    
    NSDictionary *dicData=@{@"user_id":userID,@"photo_title":@"",@"photo_description":assetURL,@"photo_collections":@""};
    [webServices saveFileData:dicData controller:@"photo" method:@"store" filePath:filePath];*/
    @try {
        if(isCameraMode)
        {
            isCameraEditMode=YES;
            pickImage=image;
            [self dismissViewControllerAnimated:YES completion:Nil];
            //[self launchPhotoEditorWithImage:image highResolutionImage:image];
            
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
            
            [self dismissViewControllerAnimated:YES completion:completion];
        }
        

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
    NSData *imgData=UIImagePNGRepresentation(image);
    
    [self savePhotosOnServer:userid filepath:imgData photoTitle:@"" photoDescription:@"" photoCollection:@"3"];
    [self dismissViewControllerAnimated:YES completion:nil];
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
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imgData photoTitle:(NSString *)photoTitle photoDescription:(NSString *)photoDescription photoCollection:(NSString *)photoCollection
{
    
    webservices.delegate=self;
    
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitle,@"photo_description":photoDescription, @"photo_collections":photoCollection};
    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webservices saveFileData:dic controller:@"photo" method:@"store" filePath:imgData] ;
}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Data %@",data);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
