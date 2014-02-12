//
//  PhotoGalleryViewController.m
//  photoshare
//
//  Created by ignis2 on 25/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "PhotoGalleryViewController.h"

#import "Base64.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "WebserviceController.h"
#import "EditPhotoViewController.h"
#import "SVProgressHUD.h"
#import "NavigationBar.h"
#import "EditPhotoDetailViewController.h"
#import "PhotoViewController.h"
#import "PhotoShareController.h"

@interface PhotoGalleryViewController ()
{
    SVProgressHUD *pro;
    CGRect frame; //frame for button
    NSNumber *selectedPhotoId;
}
@end

@implementation PhotoGalleryViewController
@synthesize isPublicFolder,selectedFolderIndex,folderName;
@synthesize library,collectionId,collectionOwnerId;
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
     manager=[ContentManager sharedManager];
    [manager storeData:@"NO" :@"isEditPhoto"];
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
    
    photoArray=[[NSMutableArray alloc] init];
     photoIdsArray=[[NSMutableArray alloc] init];
     photoInfoArray = [[NSMutableArray alloc] init];
    //editBtn
    editBtn = [[UIButton alloc] init];
    //get the user id from nsuserDefaults
    userid=[manager getData:@"user_id"];
    
    if([UIScreen mainScreen].bounds.size.height == 480)
    {
        collectionview.frame=CGRectMake(collectionview.frame.origin.x, collectionview.frame.origin.y, collectionview.frame.size.width, collectionview.frame.size.height);
    }
    else if([UIScreen mainScreen].bounds.size.height == 568)
    {
        collectionview.frame=CGRectMake(collectionview.frame.origin.x, collectionview.frame.origin.y, collectionview.frame.size.width, collectionview.frame.size.height + 85);
    }
    
    isPopFromPhotos=NO;
    isGetPhotoFromServer=NO;
    isGetPhotoIdFromServer=NO;
    isSaveDataOnServer=NO;
    [self getCollectionDetail];
    
    //set the add ,delete photo btn visibility
    if([self.folderName isEqualToString:@"Public"] || [self.folderName isEqualToString:@"public"])
    {
        
    }
    else
    {
        if(self.collectionOwnerId.integerValue==userid.integerValue)
        {
            addPhotoBtn.hidden=NO;
            deletePhotoBtn.hidden=NO;
            
        }
        else
        {
            deletePhotoBtn.hidden=YES;
            addPhotoBtn.hidden=YES;
        }
    }
    
    
}
    

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addCustomNavigationBar];
   
    
    
    isPopFromPhotos=NO;
    isGoToViewPhoto=NO;
    if (isCameraEditMode) {
        isCameraEditMode = false ;
        [NSTimer scheduledTimerWithTimeInterval:1.0f                                       target:self selector:@selector(openeditorcontrol)
            userInfo:nil repeats:NO];
        
    }
    if([[manager getData:@"istabcamera"] isEqualToString:@"YES"])
    {
        [manager storeData:@"NO" :@"istabcamera"];
        [self.navigationController popViewControllerAnimated:NO];
    }
    frameForShareBtn=sharePhotoBtn.frame;
    if([[manager getData:@"isEditPhotoInViewPhoto"] isEqualToString:@"YES"])
    {
        NSData *photo=[manager getData:@"photo"];
        UIImage *image=[UIImage imageWithData:photo];
        [photoArray addObject:image];
        [photoIdsArray addObject:[manager getData:@"photoId"]];
        NSMutableArray *photoinfoarray=[NSKeyedUnarchiver unarchiveObjectWithData:[[manager getData:@"photoInfoArray"] mutableCopy]];
        photoInfoArray=photoinfoarray;
        [collectionview reloadData];
        [manager storeData:@"NO" :@"isEditPhotoInViewPhoto"];
        //remove data from nsuser default
        [manager removeData:@"photo,photoId,isEditPhotoInViewPhoto"];//photo info array is use later
        
        
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
-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!isGoToViewPhoto&&!isCameraMode&&!isCameraEditMode&&!isMailSendMode)
    {
        isPopFromPhotos=YES;
    }
    
}
-(void)photoCaching
{
    
     NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    
     // Add an operation as a block to a queue
     [myQueue addOperationWithBlock: ^ {
     
     
     [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
     NSLog(@"thumbnail image download");
    
     
         NSString *filenameWithExtension ;//= [imageURL lastPathComponent];
     
         NSData * imageData ;//= [NSData dataWithContentsOfURL:imageURL];
     
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
     NSString *documentsPaths = [documentsPath stringByAppendingString:@"/schudioimages"];
     
     NSError *error = nil;
     if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPaths])
     [[NSFileManager defaultManager] createDirectoryAtPath:documentsPaths withIntermediateDirectories:NO attributes:nil error:&error];
     
     NSString *filePath = [documentsPaths stringByAppendingPathComponent:filenameWithExtension]; //Add the file name
     
     [imageData writeToFile:filePath atomically:YES];
     }];
     
     }];

    
}

-(void)removeProgressBar
{
    //[progressBarGestureView removeFromSuperview];
    [SVProgressHUD dismiss];
}
-(void)addProgressBar :(NSString *)message
{
    [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeBlack];
    
}

-(IBAction)addPhoto:(id)sender
{
    isAddPhotoMode=YES;
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"From Camera" otherButtonTitles:@"From Gallery ",@"From Camera Roll", nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
//action sheet delegate Method
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    photoLocationStr=@"";
    if(isAddPhotoMode)
    {
        if(photoArray.count==photoIdsArray.count)
        {
            [self callGetLocation];
            
            UIImagePickerController *imagePicker=[[UIImagePickerController alloc] init];
            imagePicker.delegate=self;
            isCameraMode=YES;
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
            else if(buttonIndex==2)//From Camera Roll
            {
                NSLog(@"gallery");
                @try {
                    
                    imagePicker.sourceType=UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                    [self presentViewController:imagePicker animated:YES completion:nil];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
            }
            else if(buttonIndex==3)//Cancel Button
            {
                NSLog(@"Cancel Button Click");
            }
            isPickerMode=YES;
            isAddPhotoMode=NO;

        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo is Loading" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
        }
    }
    if(isEditPhotoMode)
    {
        [self callGetLocation];
        if(buttonIndex==0)//Edit Photo
        {
            [self getImageFromServerForEdit:selectedEditImageIndex];
        }
        else if(buttonIndex==1)//Edit Detail
        {
            EditPhotoDetailViewController *editPhotoDetail=[[EditPhotoDetailViewController alloc] init];
            editPhotoDetail.photoId=[photoIdsArray objectAtIndex:selectedEditImageIndex];
            editPhotoDetail.collectionId=self.collectionId;
            editPhotoDetail.selectedIndex=selectedEditImageIndex;
            [self.navigationController pushViewController:editPhotoDetail animated:NO];
        }
        isEditPhotoMode=NO;
    }
    
}

//get PhotoId From Server
-(void)getPhotoIdFromServer
{
    isGetPhotoIdFromServer=YES;
    [self addProgressBar:@"Standby"];
    
    webServices.delegate=self;
    
    NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
    
    [webServices call:dicData controller:@"collection" method:@"get"];
}

//get Photo From Server
-(void)getPhotoFromServer :(int)photoIdIndex
{
   
    isGetPhotoFromServer=YES;
    NSDictionary *dicData;
    @try {
        if(photoIdsArray.count>0)
        {
            
            deleteImageCount=0;
            //callling First Time Webservice for Get image from server
            webServices.delegate=self;
            NSNumber *num = [NSNumber numberWithInt:1] ;
            selectedPhotoId = [photoIdsArray objectAtIndex:photoIdIndex];
            dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:photoIdIndex],@"get_image":num,@"collection_id":self.collectionId,@"image_resize":@"40"};
            
            [webServices call:dicData controller:@"photo" method:@"get"];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
    @finally {
        
    }

    
}
//fetch the collection detail from server for read write permission check
-(void)getCollectionDetail
{
    @try {
        
        isGetCollectionDetails=YES;
        webServices.delegate=self;
        
        NSDictionary *dicData=@{@"user_id":userid,@"collection_id":self.collectionId};
        
        [webServices call:dicData controller:@"collection" method:@"get"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)image
{
    isSaveDataOnServer=YES;
    
    [self addProgressBar:@"Photo is saving"];
    webServices=[[WebserviceController alloc] init];
    webServices.delegate=self;
    
    NSDictionary *dic = @{@"user_id":userid,@"photo_title":photoTitleStr,@"photo_description":photoDescriptionStr,@"photo_location":photoLocationStr,@"photo_tags":photoTagStr,@"photo_collections":self.collectionId};
    //store data
    // [webServices call:data controller:@"photo" method:@"store"];
    [webServices saveFileData:dic controller:@"photo" method:@"store" filePath:image] ;
}
//deletePhotoFromServer
-(void)deletePhotoFromServer :(NSNumber *)usrId photoId:(NSNumber *)photoId
{
    isDeleteMode=YES;
     webServices.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"photo_id":photoId};
    [webServices call:dicData controller:@"photo" method:@"delete"];
    
}

-(void)getImageFromServerForEdit :(int)selectedIndex
{
    isEditImageFromServer=YES;
    NSNumber *num = [NSNumber numberWithInt:1] ;
    webServices.delegate=self;
    NSDictionary *dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:selectedIndex],@"get_image":num,@"image_resize":@"400",@"collection_id":self.collectionId};
    
    [self addProgressBar:@"Photo is Loading"];
    
    
    [webServices call:dicData controller:@"photo" method:@"get"];
}
-(void) webserviceCallbackImage:(UIImage *)image
{
   
    [self removeProgressBar];
    //UIImageView *img = [[UIImageView alloc] initWithImage:image] ;
    //[self.view addSubview:img] ;
    if(isEditImageFromServer)
    {
        
        [self launchPhotoEditorWithImage:image highResolutionImage:image];
        isEditImageFromServer=NO;
    }
    else if(isGetPhotoFromServer)
    {
        //[self saveImageInDocumentDirectry:image index:photoArray.count];
        [photoArray addObject:image];
        
        int count=photoArray.count;
        NSLog(@"Photo Array Count is : %d",count);
        UIImageView *imgView=(UIImageView *)[collectionview viewWithTag:100+count];
        UIActivityIndicatorView *indicator=(UIActivityIndicatorView *)[collectionview viewWithTag:1100+count];
        [indicator removeFromSuperview];
        imgView.image=image;
        
        if(photoArray.count<photoIdsArray.count)
        {
            if(!isPopFromPhotos)
            {
                [self getPhotoFromServer:photoArray.count];
            }
        }
        else
        {
            isGetPhotoFromServer=NO;
        }
        //[collectionview reloadData];
    }

}
-(void)saveImageInDocumentDirectry:(UIImage *)img index:(NSInteger)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"yourFolder%@photoID_%@.png",folderName,[photoIdsArray objectAtIndex:index]]];
    UIImage *image = img; // imageView is my image from camera
    NSData *imgData = UIImagePNGRepresentation(image);
    [imgData writeToFile:savedImagePath atomically:NO];
    
}
-(UIImage *)getImageFromDocumentDirectory :(NSInteger)index
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"yourFolder%@photoID_%@.png",folderName,[photoIdsArray objectAtIndex:index]]];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
   
}
-(void)webserviceCallback:(NSDictionary *)data
{
    
    NSDictionary *outputData=[data objectForKey:@"output_data"];
   
    NSLog(@"outPutData is %@",outputData);
    
    int exitcode=[[data objectForKey:@"exit_code"] integerValue];
    
       // photoInfoArray = [[NSMutableArray alloc] init];
        if(isSaveDataOnServer)
        {
             [self removeProgressBar];
            if(exitcode==1)
            {
                [photoArray addObject:editedImage];
                [photoIdsArray addObject:[outputData objectForKey:@"image_id"]];
            
                
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
                
                [photoInfoArray addObject:dic];
                [collectionview reloadData];
                
            }
          isSaveDataOnServer=NO;
        
        }
        else if(isGetPhotoIdFromServer)
        {
             [self removeProgressBar];
            if(exitcode==1)
            {
                NSDictionary *collectionContent=[outputData objectForKey:@"collection_contents"];
                if(collectionContent.count>0)
                {
                        [photoIdsArray addObjectsFromArray:[collectionContent allKeys]];
                    
                        [photoInfoArray addObjectsFromArray:[collectionContent allValues]];
                        //store photo info array in nsuser default ARRAY IS store in data format
                        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:photoInfoArray];
                        [manager storeData:data:@"photoInfoArray"];
                    
                        NSLog(@"Photo info array %@",[NSKeyedUnarchiver unarchiveObjectWithData:[manager getData:@"photoInfoArray"]] );
                    
                    
                        [collectionview reloadData];
                   /* NSString *checkNotFirstTime=[manager getData:[NSString stringWithFormat:@"isNotFirstTimeIn%@",folderName]];
                    if([checkNotFirstTime isEqualToString:@"YES"])
                    {
                        for (int i=0; i<photoIdsArray.count; i++) {
                            if([self getImageFromDocumentDirectory:i]!=(id)nil)
                            {
                                [photoArray addObject:[self getImageFromDocumentDirectory:i]];
                            }
                            else
                            {
                                [self getPhotoFromServer:i];
                            }
                            
                        }
                        [collectionview reloadData];
                    }
                    else
                    {
                        [self getPhotoFromServer:0];
                        [manager storeData:@"YES" :[NSString stringWithFormat:@"isNotFirstTimeIn%@",folderName]];
                    }*/
                    [self getPhotoFromServer:0];
                    [manager storeData:@"YES" :[NSString stringWithFormat:@"isNotFirstTimeIn%@",folderName]];
                }
                else
                {
                    
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photos Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                    [alert show];
                }

            }
            isGetPhotoIdFromServer=NO;
            
        }
        else if (isGetCollectionDetails)
        {
            if(exitcode ==1)
            {
                @try {
                    NSDictionary *outputData=[data objectForKey:@"output_data"];
                    
                    @try {
                        
                        
                        NSString *writeUserIdStr=[[outputData objectForKey:@"collection_write_user_ids"] componentsJoinedByString:@","];
                        NSString *readUserIdStr=[[outputData objectForKey:@"collection_read_user_ids"] componentsJoinedByString:@","];
                        //store in nsuserDefault
                        NSArray *writePer=[outputData objectForKey:@"collection_write_user_ids"];
                        NSArray *readPer=[outputData objectForKey:@"collection_read_user_ids"];
                        isWritePermission=[writePer containsObject:userid];
                        isReadPermission=[readPer containsObject:userid];
                        if(isWritePermission)
                        {
                            addPhotoBtn.hidden=NO;
                        }
                        [manager storeData:writeUserIdStr :@"writeUserId"];
                        [manager storeData:readUserIdStr :@"readUserId"];
                        
                    }
                    @catch (NSException *exception) {
                        
                    }
                    @finally {
                        
                    }
                    
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                isGetCollectionDetails=NO;
                [self getPhotoIdFromServer];
                
            }
            
        }
}

-(IBAction)deletePhoto:(id)sender
{
   [editBtn removeFromSuperview];
    UIButton *btn=(UIButton *)sender;
    if(photoArray.count>0)
    {
        if(btn.selected==NO)
        {
            NSLog(@"Not selected");
            addPhotoBtn.hidden=YES;
            sharePhotoBtn.hidden=YES;
            isDeleteMode=YES;
        }
        else
        {
            [collectionview reloadData];
            //sort the index array in descending order
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            sortedArray = [selectedImagesIndex sortedArrayUsingDescriptors:sortDescriptors];
            if(sortedArray.count>0)
            {
                
                deleteImageCount=0;
                @try {
                    for(int i=0;i<sortedArray.count;i++)
                    {
                        [self deletePhotoFromServer:userid photoId:[photoIdsArray objectAtIndex:[[sortedArray objectAtIndex:i] integerValue]]];
                        [photoArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                        [photoIdsArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                        [photoInfoArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                    }
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:[NSString stringWithFormat:@"%d Photo deleted",sortedArray.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                    [alert show];
                    
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception.description);
                    
                }
                @finally {
                    
                }
                
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photo Selected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
            }
            [self resetButton];
        }
        
        btn.selected=!btn.selected;
        NSLog(@"Selected");
    }
    else
    {
        if(photoIdsArray.count>0)
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo is Loading" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photo Available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
            [alert show];
        }
        
    }
    
}

-(IBAction)sharePhoto:(id)sender
{
    
    [editBtn removeFromSuperview];
    //UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Sharing is Available for Single Photo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
    //[alert show];
    if(!isPublicFolder)
    {
        UIButton *btn=(UIButton *)sender;
        if(btn.selected==NO)
        {
            NSLog(@"Not selected");
            addPhotoBtn.hidden=YES;
            deletePhotoBtn.hidden=YES;
            frame = sharePhotoBtn.frame;
            sharePhotoBtn.frame=deletePhotoBtn.frame;
            isShareMode=YES;
        }
        else
        {
            [collectionview reloadData];
            //sort the index array in descending order
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO] ;
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            
            shareSortedArray = [selectedImagesIndex sortedArrayUsingDescriptors:sortDescriptors];
            NSLog(@"Selected");
            
            if(shareSortedArray.count > 0)
            {
                NSMutableArray *photoIdList = [[NSMutableArray alloc] init];
                [photoIdList removeAllObjects];
                for(int i=0;i<shareSortedArray.count;i++)
                {
                    [photoIdList addObject:[photoIdsArray objectAtIndex:[[shareSortedArray objectAtIndex:i] integerValue]]];
                }
                NSArray *userDetail = [[NSArray alloc] initWithObjects:userid,collectionId,@1, nil];
                
                PhotoShareController *photoShare = [[PhotoShareController alloc] init];
                
                photoShare.otherDetailArray = userDetail;
                photoShare.sharedImagesArray = photoIdList;
                
                [self.navigationController pushViewController:photoShare animated:YES];
            }
            else
            {
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photo Selected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                [alert show];
            }

            [self resetButton];
            sharePhotoBtn.frame =frame;
            
            
        }
        
        btn.selected=!btn.selected;
    }
}
//reset the button hidden no and previous frame
-(void)resetButton
{
    addPhotoBtn.hidden=NO;
    deletePhotoBtn.hidden=NO;
    sharePhotoBtn.hidden=NO;
    
    //sharePhotoBtn.frame=frameForShareBtn;
    isDeleteMode=NO;
    isShareMode=NO;
    
    [selectedImagesIndex removeAllObjects];
}

-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    //if editBtnIs in view
    [editBtn removeFromSuperview];
    [self resetButton];
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
        if(isDeleteMode)
        {
            if(cell.selected==NO)
            {
                if(photoArray.count>indexPath.row)
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
                    [manager showAlert:@"Warning" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
                }
                
            }
            else
            {
                UIImageView *checkBox=(UIImageView *)[cell viewWithTag:1001];
                [checkBox removeFromSuperview];
                [selectedImagesIndex removeObject:[NSNumber numberWithInteger:[indexPath row]]];
            }
        }
        else if(isShareMode)
        {
            if(cell.selected==NO)
            {
                if(photoArray.count>indexPath.row)
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
                    [manager showAlert:@"Warning" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
                }
                
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
            if(photoArray.count>indexPath.row)
            {
            [self viewPhoto:indexPath];
            }
            else
            {
                [manager showAlert:@"Warning" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
            }

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
        if(collectionOwnerId.integerValue==userid.integerValue)
        {
            if(photoArray.count>0&&!isDeleteMode&&!isShareMode)
            {
                
                editBtn.frame=CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+5, 60, 50);
                [editBtn setImage:[UIImage imageNamed:@"edit_btn.png"] forState:UIControlStateNormal];
                [editBtn addTarget:self action:@selector(editImage:) forControlEvents:UIControlEventTouchUpInside];
                [collectionview addSubview:editBtn];
            }
        }
        else
        {
            selectedEditImageIndex=indexPath.row;
            if(isWritePermission)
            {
                NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];

                if(photoUserId.integerValue==userid.integerValue)
                {
                    UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(edit:)];
                    UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deletePhoto:)];
                    
                    UIMenuController *menu = [UIMenuController sharedMenuController];
                    
                    [menu setMenuItems:[NSArray arrayWithObjects:edit,delete, nil]];
                    [menu setTargetRect:CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+50, cell.frame.size.width, cell.frame.size.height) inView:cell.superview];
                    [menu setMenuVisible:YES animated:YES];
                }
                else
                {
                    UIMenuItem *edit = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(edit:)];
                    UIMenuItem *reportAbuse = [[UIMenuItem alloc] initWithTitle:@"Report Abuse" action:@selector(reportAbuse:)];
                    
                    UIMenuController *menu = [UIMenuController sharedMenuController];
                    
                    [menu setMenuItems:[NSArray arrayWithObjects:edit, reportAbuse,nil]];
                    [menu setTargetRect:CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+50, cell.frame.size.width, cell.frame.size.height) inView:cell.superview];
                    [menu setMenuVisible:YES animated:YES];
                }
                
                NSLog(@"Write Permission");
            }
            else if (isReadPermission)
            {
               UIMenuItem *reportAbuse = [[UIMenuItem alloc] initWithTitle:@"Report Abuse" action:@selector(reportAbuse:)];
                
                UIMenuController *menu = [UIMenuController sharedMenuController];
                [menu setMenuItems:[NSArray arrayWithObjects:reportAbuse,nil]];
                [menu setTargetRect:CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+50, cell.frame.size.width, cell.frame.size.height) inView:cell.superview];
                [menu setMenuVisible:YES animated:YES];
                NSLog(@"Read Permission");
            }
        }
       
    }
}
- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if(isWritePermission)
    {
        NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
        
        if(photoUserId.integerValue==userid.integerValue)
        {
            if (action == @selector(edit:))
            {
                return YES;
            }
            if (action == @selector(delete:))
            {
                return YES;
            }
        }
        else
        {
            if (action == @selector(reportAbuse:))
            {
                return YES;
            }
            if (action == @selector(edit:))
            {
                return YES;
            }
        }
    }
    else if (isReadPermission)
    {
        if (action == @selector(reportAbuse:))
        {
            return YES;
        }
    }
    
    return NO;
   
}
//for UIMenu controller
- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)edit:(id)sender {
    photoLocationStr=@"";
    [self callGetLocation];
    NSNumber *photoUserId=[[photoInfoArray objectAtIndex:selectedEditImageIndex] objectForKey:@"collection_photo_user_id"];
    
    if(photoUserId.integerValue==userid.integerValue)
    {
        isEditPhotoMode=YES;
        UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo",@"Edit Properties", nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
    }
    else
    {
        [self getImageFromServerForEdit:selectedEditImageIndex];

    }
   	NSLog(@"Photo Edit");
}
//send mail
- (void)reportAbuse:(id)sender {
    
    isMailSendMode=YES;//for photo loading
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:@"reportabuse@123friday.com"]];
    [controller setSubject:@"Report Abuse"];
    
    NSString *body=[NSString stringWithFormat:@"Collection Owner Id :%@\nCollection Name:%@\nCollection Id:%@\nPhoto Id:%@",self.collectionOwnerId,self.folderName,self.collectionId,[photoIdsArray objectAtIndex:selectedEditImageIndex]];
    
    [controller setMessageBody:body isHTML:NO];
    /*
     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
     UIImage *ui = resultimg.image;
     pasteboard.image = ui;
     NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(ui)];
     [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@" "];
     */
    if (controller)
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
	NSLog(@"Cell was approved");
}
-(void)delete:(id)sender
{
    [self deletePhotoFromServer:userid photoId:[photoIdsArray objectAtIndex:selectedEditImageIndex]];
    [photoArray removeObjectAtIndex:selectedEditImageIndex];
    [photoIdsArray removeObjectAtIndex:selectedEditImageIndex];
    [photoInfoArray removeObjectAtIndex:selectedEditImageIndex];
    [collectionview reloadData];
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo Deleted" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
    [alert show];

}
//main delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    isMailSendMode=NO;
    
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
        [manager showAlert:@"Message" msg:@"Mail Successfully sent" cancelBtnTitle:@"Ok" otherBtn:Nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)viewPhoto :(NSIndexPath *)indexPath
{
    @try {
        PhotoViewController *viewPhoto=[[PhotoViewController alloc] init];
        viewPhoto.photoId=[photoIdsArray objectAtIndex:indexPath.row];
        viewPhoto.smallImage=[photoArray objectAtIndex:indexPath.row];
        viewPhoto.isViewPhoto=YES;
        viewPhoto.collectionId=self.collectionId;
        viewPhoto.collectionOwnerId=self.collectionOwnerId;
        viewPhoto.selectedIndex=indexPath.row;
        NSLog(@"Selected index is %d",indexPath.row);
        isGoToViewPhoto=YES;
        if(self.isPublicFolder)
        {
            viewPhoto.folderNameLocation=@"Public";
        }
        else
        {
            viewPhoto.folderNameLocation=[NSString stringWithFormat:@"Your folders, %@",self.folderName];
        }
        
        [self.navigationController pushViewController:viewPhoto animated:YES];

    }
    @catch (NSException *exception) {
        NSLog(@"Exception in View Photo :%@",exception.description);
    }
    @finally {
        
    }
    
}
-(void)editImage:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    CGPoint p=CGPointMake(btn.frame.origin.x, btn.frame.origin.y+20);
    NSIndexPath *indexPath=[collectionview indexPathForItemAtPoint:p];
    @try {
        //UIImage *image=  [photoArray objectAtIndex:[indexPath row]];
        //[self launchPhotoEditorWithImage:image highResolutionImage:image];
        isEditPhotoMode=YES;
        UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Add Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Edit Photo",@"Edit Properties", nil];
        [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
        
        selectedEditImageIndex=indexPath.row;
        
        //[self getImageFromServerForEdit:indexPath.row];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
        
    }
      //[self getImageFromServerForEdit:indexPath.row];
    //if editBtnIs in view
    [editBtn removeFromSuperview];
}

//imagePicker delegate Method
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    //set the asset url in String
    assetUrlOfImage=[NSString stringWithFormat:@"%@",assetURL];
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    if(isCameraMode)
    {
        isCameraEditMode=YES;
        isCameraMode=NO;
        pickImage=image;
        [self dismissViewControllerAnimated:NO completion:Nil];
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
        
        [self dismissViewControllerAnimated:NO completion:completion];
    }
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];


}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [photoIdsArray count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    
    imgView.tag=101+indexPath.row;
    imgView.layer.masksToBounds=YES;
    
    /*UIActivityIndicatorView *indeicator=[[UIActivityIndicatorView alloc] init];
    [indeicator startAnimating];
    indeicator.backgroundColor=[UIColor blackColor];
    */
    
    //indicatorV.image=[UIImage imageNamed:@"ajaxloader.gif"];
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
   
    @try {
        
        
        if(photoArray.count>indexPath.row)
        {
            UIImage *image=[photoArray objectAtIndex:indexPath.row];
            imgView.image=image;
        }
        else
        {
            
            UIActivityIndicatorView *activityIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [activityIndicator startAnimating];
            activityIndicator.tag=1101+indexPath.row;
            activityIndicator.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |                                        UIViewAutoresizingFlexibleRightMargin |                                        UIViewAutoresizingFlexibleTopMargin |                                        UIViewAutoresizingFlexibleBottomMargin);
            activityIndicator.center = CGPointMake(CGRectGetWidth(cell.bounds)/2, CGRectGetHeight(cell.bounds)/2);
            [cell.contentView addSubview:activityIndicator];
            
           /* UILabel *loading=[[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
            UIColor *btnBorderColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
            loading.textColor=btnBorderColor;
            loading.tag=1101+indexPath.row;
            loading.font=[UIFont fontWithName:@"verdana" size:9];
            loading.text=@"Loading....";
            [cell.contentView addSubview:loading];
            */

        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception Name : %@",exception.name);
        NSLog(@"Exception Description : %@",exception.description);
    }
    @finally {
        
            }
    
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
    imageData = UIImagePNGRepresentation(image);
    editedImage=image;
   
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
    
    //add image in collection Array
    
    [self addPhotoDescriptionView];
   //[self savePhotosOnServer:userid filepath:imageData];
    
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

-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    photoTitleStr=@"";
    photoDescriptionStr=@"";
    photoTagStr=@"";
    [self savePhotosOnServer:userid filepath:imageData];
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
        photoTitleStr=@"";
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
   
    [self savePhotosOnServer:userid filepath:imageData];
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
    button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [navnBar addSubview:button];
    if(self.isPublicFolder==YES)
    {
        UILabel *titleLabel = [[UILabel alloc] init ];
        titleLabel.text=@"Public Folder";
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.frame = CGRectMake(100.0, 47.0, 120.0, 30.0);
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        [navnBar addSubview:titleLabel];

    }
    else
    {
       
        UILabel *foldernamelabel=[[UILabel alloc] initWithFrame:CGRectMake(110.0, 55.0, 200.0, 18.0)];
        foldernamelabel.text=self.folderName;
        foldernamelabel.textAlignment=NSTextAlignmentRight;
        //[navnBar addSubview:iconbtn];
        [navnBar addSubview:foldernamelabel];
        
    }
    [[self view] bringSubviewToFront:navnBar];
    [[self view] addSubview:navnBar];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
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
