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
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //editBtn
    editBtn = [[UIButton alloc] init];    
    //get the user id from nsuserDefaults
    ContentManager *manager=[ContentManager sharedManager];
    userId=[manager getData:@"user_id"];
    
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.frame=CGRectMake(0, 70, 320,30);
    frameForShareBtn=sharePhotoBtn.frame;
    
    isGetPhotoFromServer=NO;
    isGetPhotoIdFromServer=NO;
    isSaveDataOnServer=NO;
    
    [self getDataFromNSUSerDefault];
    
    //[self getPhotoIdFromServer:self.userID];
    
}
-(void)getDataFromNSUSerDefault
{
    photoAssetUrlArray=[[NSMutableArray alloc] init];
    NSMutableArray *collection=[[[NSUserDefaults standardUserDefaults] objectForKey:@"Collection"] mutableCopy];
    NSMutableDictionary *collectionInfo=[[collection objectAtIndex:0] mutableCopy];
    NSMutableArray *collectionData=[[collectionInfo objectForKey:@"Collection_Data"] mutableCopy];
    for (int i=1;i<collectionData.count;i++)
    {
        NSDictionary *dic=[collectionData objectAtIndex:i];
        NSURL *url=[dic objectForKey:@"ImageAssetUrl"];
        [photoAssetUrlArray addObject:url];
    }
       // [photoAssetUrlArray addObject:[dic objectForKey:@"ImageAssetUrl"]];
   
    
}
-(void)setDataForCollectionView
{
    ContentManager *contentManagerObj=[ContentManager sharedManager];
    [Base64 initialize];
    imgArray = [[NSMutableArray alloc] init];
    NSArray *base64images=[[NSArray alloc] init];
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    if(self.isPublicFolder==YES)
    {
        //set title
     self.navigationController.navigationBar.topItem.title=@"Public Folder";
        if([contentManagerObj getData:@"publicImgArray"]==nil)
        {
            [contentManagerObj storeData:imgArray :@"publicImgArray"];
        }
        base64images =[contentManagerObj getData:@"publicImgArray"];

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
        
        
        if([contentManagerObj getData:@"dictionaryOfYourImgArray"]==nil)
        {
            [contentManagerObj storeData:dic :@"dictionaryOfYourImgArray"];
        }
        dic=[[contentManagerObj getData:@"dictionaryOfYourImgArray"] mutableCopy];
        if([[contentManagerObj getData:@"dictionaryOfYourImgArray"] objectForKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]]==nil)
        {
            
            [dic setObject:imgArray forKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]];
            [contentManagerObj storeData:dic :@"dictionaryOfYourImgArray"];
        }
        
        base64images =[[contentManagerObj getData:@"dictionaryOfYourImgArray"] objectForKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]];
    }
        for (int i=0; i<[base64images count]; i++) {
        NSString *base64string=[base64images objectAtIndex:i];
        NSData *imgData=[Base64 decode:base64string];
        UIImage *img=[UIImage imageWithData:imgData];
        [imgArray addObject:img];
    }
}

-(IBAction)addPhoto:(id)sender
{
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
//imagePicker delegate Method
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    refrenceUrlofImg=[info objectForKey:UIImagePickerControllerReferenceURL];
     NSLog(@"Refrence  is %@ ",refrenceUrlofImg);
    if(isPublicFolder)
    {
        [self.library saveImage:image toAlbum:@"Public Folder" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];

    }
    else
    {
        [self.library saveImage:image toAlbum:@"Private Folder" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
        }];

    }
    NSData *imgData=UIImagePNGRepresentation(image);
    [Base64 initialize];
    NSString *base64string=[Base64 encode:imgData];
    
    [self savePhotosOnServer:self.userID base64ImageString:imgData photoTitle:@"Image" photoDescription:@"" photoCollection:@""];
   
    /*ContentManager *manager=[ContentManager sharedManager];
    NSMutableArray *base64images=[[NSMutableArray alloc] init];
    if(isPublicFolder)
    {
        base64images=[[manager getData:@"publicImgArray"]   mutableCopy];
        [base64images addObject:base64string];
        [manager storeData:base64images :@"publicImgArray"];
    }
    else
    {
        NSMutableDictionary *dic=[[manager getData:@"dictionaryOfYourImgArray"]   mutableCopy];
        base64images=[[dic objectForKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]] mutableCopy];
        [base64images addObject:base64string];
        [dic setObject:base64images forKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]];
        [manager storeData:dic :@"dictionaryOfYourImgArray"];
    }
    [imgArray addObject:image];
    [collectionview reloadData];*/
    
}

//get PhotoId From Server
-(void)getPhotoIdFromServer: (int)usrId
{
    isGetPhotoIdFromServer=YES;
    
    webServices.delegate=self;
    NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_id=%d",usrId,self.collectionId];
    NSDictionary *dicData=@{@"user_id":[NSNumber numberWithInt:usrId],@"collection_id":[NSNumber numberWithInt:self.collectionId]};
    
    [webServices call:data controller:@"collection" method:@"get"];
}
//get Photo From Server
-(void)getPhotoFromServer: (int)usrId
{
    if(photoIdsArray.count!=0)
    {
    isGetPhotoFromServer=YES;
    
    webServices.delegate=self;
    NSString *data=[NSString stringWithFormat:@"user_id=%d&photo_id=%d&collection_id=%d&get_image=%d&image_resize=%d",usrId,[[photoIdsArray objectAtIndex:0] integerValue],self.collectionId,1,0];
    [webServices call:data controller:@"photo" method:@"get"];
    }
}
//save Photo on Server Photo With Detaill
-(void)savePhotosOnServer :(int)usrId base64ImageString:(NSData *)base64ImageString photoTitle:(NSString *)photoTitle photoDescription:(NSString *)photoDescription photoCollection:(NSString *)photoCollection
{
    isSaveDataOnServer=YES;
    
    webServices.delegate=self;
    NSString *data=[NSString stringWithFormat:@"user_id=%d&file=%@&photo_title=%@&photo_description=%@&photo_collections=%@",usrId,base64ImageString,photoTitle,photoDescription,photoCollection];
    //store data
    [webServices call:data controller:@"photo" method:@"store"];
    
}
//deletePhotoFromServer
-(void)deletePhotoFromServer :(int)usrId photoId:(int)photoId
{
    
}
-(void)webserviceCallback:(NSDictionary *)data
{
    NSDictionary *outputData=[data objectForKey:@"output_data"];
    
    NSLog(@"outPutData is %@",outputData);
    
    int exitcode=[[data objectForKey:@"exit_code"] integerValue];
    if(exitcode==1)
    {
        if(isGetPhotoIdFromServer)
        {
            photoIdsArray=[[NSMutableArray alloc] init];
            NSArray *collectionContent=[outputData objectForKey:@"collection_contents"];
            
            for (NSNumber *pId in collectionContent) {
                [photoIdsArray addObject:pId];
            }
            isGetPhotoIdFromServer=NO;
            [self getPhotoFromServer:userID];
        }
        else if(isGetPhotoFromServer)
        {
            NSLog(@"");
        }
        else if(isSaveDataOnServer)
        {
            
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
        ContentManager *manager=[ContentManager sharedManager];
         NSMutableArray *base64images=[[NSMutableArray alloc] init];
        //sort the index array in descending order
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO] ;
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray;
        sortedArray = [selectedImagesIndex sortedArrayUsingDescriptors:sortDescriptors];
        if(isPublicFolder)
        {
            base64images=[[manager getData:@"publicImgArray"] mutableCopy];
            
            for (int i=0; i<sortedArray.count; i++) {
                
                [base64images removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                
                [imgArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                
            }
            [manager storeData:base64images :@"publicImgArray"];
        }
        else
        {
            
            NSMutableDictionary *dic=[[manager getData:@"dictionaryOfYourImgArray"]   mutableCopy];
            base64images=[[dic objectForKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]] mutableCopy];
            
            for (int i=0; i<sortedArray.count; i++) {
                
                [base64images removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                
                [imgArray removeObjectAtIndex:[[sortedArray objectAtIndex:i] integerValue]];
                
            }
            [dic setObject:base64images forKey:[NSString stringWithFormat:@"Folder_%d",selectedFolderIndex]];
            [manager storeData:dic :@"dictionaryOfYourImgArray"];

            
        }
        
        [collectionview reloadData];
        NSLog(@"Successfull delete");
        
        [self resetButton];
        NSLog(@"Selected");
    }
    
   
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
        editBtn.frame=CGRectMake(cell.frame.origin.x+20, cell.frame.origin.y+20, 60, 50);
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
    
    //go to editPhoto Controller
    EditPhotoViewController *editPhoto=[[EditPhotoViewController alloc] init];
    [self.navigationController pushViewController:editPhoto animated:YES];
    
    //if editBtnIs in view
    [editBtn removeFromSuperview];
}



-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imgView.layer.masksToBounds=YES;
    imgView.tag=100;
    
    NSURL *url=(NSURL *)[photoAssetUrlArray objectAtIndex:2];
    
    __block UIImage *returnValue = nil;
    
    [self.library assetForURL:url resultBlock:^(ALAsset *asset) {
        returnValue = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
    } failureBlock:^(NSError *error) {
        NSLog(@"error : %@", error);
    }];
    
    
    //[imgView setImage:returnValue];
    [cell.contentView addSubview:imgView];
    
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
