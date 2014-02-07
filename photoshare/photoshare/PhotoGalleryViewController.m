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
#import "PhotoShareController.h";

@interface PhotoGalleryViewController ()
{
    SVProgressHUD *pro;
    CGRect frame; //frame for button
    NSNumber *selectedPhotoId;
}
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
     manager=[ContentManager sharedManager];
    
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
    
    [self getPhotoIdFromServer];
    

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
    
    frameForShareBtn=sharePhotoBtn.frame;
    
}

-(void)openeditorcontrol
{
    [self launchPhotoEditorWithImage:pickImage highResolutionImage:pickImage];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!isGoToViewPhoto&&!isCameraMode&&!isCameraEditMode)
    {
        isPopFromPhotos=YES;
    }
    
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
    if(isAddPhotoMode)
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
                isCameraMode=YES;
                
                isPhotoPickMode=YES;
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
    if(isEditPhotoMode)
    {
        if(buttonIndex==0)//Edit Photo
        {
            [self getImageFromServerForEdit:selectedEditImageIndex];
        }
        else if(buttonIndex==1)//Edit Detail
        {
            EditPhotoDetailViewController *editPhotoDetail=[[EditPhotoDetailViewController alloc] init];
            editPhotoDetail.photoId=[photoIdsArray objectAtIndex:selectedEditImageIndex];
            editPhotoDetail.collectionId=self.collectionId;
            editPhotoDetail.photoDetail=[photoInfoArray objectAtIndex:selectedEditImageIndex];
            [self.navigationController pushViewController:editPhotoDetail animated:YES];
        }
        isEditPhotoMode=NO;
    }
    
}
-(void)resetAllBoolValue
{
    isGetPhotoFromServer=NO;
    isGetPhotoIdFromServer=NO;
    isSaveDataOnServer=NO;
    isEditImageFromServer=NO;
    
   
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
    @try {
        if(photoIdsArray.count>0)
        {
            
            deleteImageCount=0;
            //callling First Time Webservice for Get image from server
            webServices.delegate=self;
            NSNumber *num = [NSNumber numberWithInt:1] ;
            selectedPhotoId = [photoIdsArray objectAtIndex:photoIdIndex];
            NSDictionary *dicData = @{@"user_id":userid,@"photo_id":[photoIdsArray objectAtIndex:photoIdIndex],@"get_image":num,@"collection_id":self.collectionId,@"image_resize":@"80"};
            
            [webServices call:dicData controller:@"photo" method:@"get"];
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
    @finally {
        
    }

    
}
//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(NSNumber *)usrId filepath:(NSData *)imgData photoTitle:(NSString *)photoTitle photoDescription:(NSString *)photoDescription photoCollection:(NSString *)photoCollection
{
   
    isSaveDataOnServer=YES;
    
    webServices=[[WebserviceController alloc] init];
    
    webServices.delegate=self;
    
    [self addProgressBar:@"Standby"];
    
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
-(void)webserviceCallback:(NSDictionary *)data
{
     [self removeProgressBar];
    NSDictionary *outputData=[data objectForKey:@"output_data"];
   
    NSLog(@"outPutData is %@",outputData);
    
    int exitcode=[[data objectForKey:@"exit_code"] integerValue];
    
       // photoInfoArray = [[NSMutableArray alloc] init];
        if(isSaveDataOnServer)
        {
            if(exitcode==1)
            {
                [photoIdsArray addObject:[outputData objectForKey:@"image_id"]];
            
                [collectionview reloadData];
            }
          isSaveDataOnServer=NO;
        
        }
        else if(isGetPhotoIdFromServer)
        {
            if(exitcode==1)
            {
                NSDictionary *collectionContent=[outputData objectForKey:@"collection_contents"];
                if(collectionContent.count>0)
                {
                        [photoIdsArray addObjectsFromArray:[collectionContent allKeys]];
                    
                        [photoInfoArray addObjectsFromArray:[collectionContent allValues]];
                    
                        [collectionview reloadData];
                        
                        [self getPhotoFromServer:0];
                    
                }
                else
                {
                    
                    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"No Photos Available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:Nil, nil];
                    [alert show];
                }

            }
            isGetPhotoIdFromServer=NO;
            
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
                
                NSArray *userDetail = [[NSArray alloc] initWithObjects:userid,collectionId,@1, nil];
                PhotoShareController *photoShare = [[PhotoShareController alloc] init];
                
                photoShare.otherDetailArray = userDetail;
                photoShare.sharedImagesArray = shareSortedArray;
                
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
        if(photoArray.count>0&&!isDeleteMode&&!isShareMode)
        {
            UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
            editBtn.frame=CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+5, 60, 50);
            [editBtn setImage:[UIImage imageNamed:@"edit_btn.png"] forState:UIControlStateNormal];
            [editBtn addTarget:self action:@selector(editImage:) forControlEvents:UIControlEventTouchUpInside];
            [collectionview addSubview:editBtn];
        }
       
    }
}
-(void)viewPhoto :(NSIndexPath *)indexPath
{
    @try {
        PhotoViewController *viewPhoto=[[PhotoViewController alloc] init];
        viewPhoto.photoId=[photoIdsArray objectAtIndex:indexPath.row];
        viewPhoto.smallImage=[photoArray objectAtIndex:indexPath.row];
        viewPhoto.isViewPhoto=YES;
        viewPhoto.collectionId=self.collectionId;
        viewPhoto.photoDetail=[photoInfoArray objectAtIndex:indexPath.row] ;
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
    isAviaryMode=YES;
    
    if(isCameraMode)
    {
        isCameraEditMode=YES;
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
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissModals];
    
    //add image in collection Array
    [photoArray addObject:image];
   [self savePhotosOnServer:userid filepath:imageData photoTitle:@"" photoDescription:@"" photoCollection:[NSString stringWithFormat:@"%@",self.collectionId]];
    
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

-(void)dismissModals
{
    [self dismissViewControllerAnimated:NO completion:nil];
    //self.navigationController.navigationBar.frame=CGRectMake(0, 15, 320, 90);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        /*UIButton *iconbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        iconbtn.frame=CGRectMake(200.0, 55.0, 18.0, 18.0);
        [iconbtn setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
        iconbtn.userInteractionEnabled=NO;*/
        UILabel *foldernamelabel=[[UILabel alloc] initWithFrame:CGRectMake(220.0, 55.0, 100.0, 18.0)];
        foldernamelabel.text=self.folderName;
        
        //[navnBar addSubview:iconbtn];
        [navnBar addSubview:foldernamelabel];
        
    }
    [[self view] bringSubviewToFront:navnBar];
    [[self view] addSubview:navnBar];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
