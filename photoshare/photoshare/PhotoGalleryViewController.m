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
@interface PhotoGalleryViewController ()

@end

@implementation PhotoGalleryViewController
@synthesize isPublicFolder,selectedFolderIndex;
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
    // Do any additional setup after loading the view from its nib.
    
    
    
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
    
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [collectionview addGestureRecognizer:tapGesture];
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
        self.title=@"Public Folder";
        if([contentManagerObj getData:@"publicImgArray"]==nil)
        {
            [contentManagerObj storeData:imgArray :@"publicImgArray"];
        }
        base64images =[contentManagerObj getData:@"publicImgArray"];

    }
    else
    {
        //set Folder Name in Right Side of navigation bar
        NSString *folderName=[[contentManagerObj getData:@"FolderArray"] objectAtIndex:self.selectedFolderIndex];
        UIBarButtonItem *foldernameButton = [[UIBarButtonItem alloc] initWithTitle:folderName  style:UIBarButtonItemStylePlain target:self action:nil];
        foldernameButton.tintColor=[UIColor blackColor];
        self.navigationItem.rightBarButtonItem = foldernameButton;
        
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setDataForCollectionView];
    [collectionview reloadData];
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
    NSData *imgData=UIImagePNGRepresentation(image);
    [Base64 initialize];
    NSString *base64string=[Base64 encode:imgData];
    ContentManager *manager=[ContentManager sharedManager];
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
    [collectionview reloadData];
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
    }
    else
    {
        [self resetButton];
        NSLog(@"Selected");
    }
    
    btn.selected=!btn.selected;

}
-(void)resetButton
{
    addPhotoBtn.hidden=NO;
    deletePhotoBtn.hidden=NO;
    sharePhotoBtn.hidden=NO;
    addPhotoBtn.frame=CGRectMake(5, 417, 100, 30);
    deletePhotoBtn.frame=CGRectMake(110, 417, 100, 30);
    sharePhotoBtn.frame=CGRectMake(215, 417, 100, 30);
}
-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        UICollectionViewCell *cell=[collectionview dequeueReusableCellWithReuseIdentifier:@"CVCell" forIndexPath:indexPath];
        UIButton *checkBtn=[[UIButton alloc] initWithFrame:cell.frame];
        checkBtn.layer.borderWidth=1;
        checkBtn.layer.borderColor=[UIColor greenColor].CGColor;
       
        cell.hidden=YES;
        
    }
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [imgArray count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    imgView.layer.masksToBounds=YES;
    imgView.tag=100;
    [imgView setImage:[imgArray objectAtIndex:[indexPath row]]];
    [cell.contentView addSubview:imgView];
    
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
