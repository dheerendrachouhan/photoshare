//
//  CommunityViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "CommunityViewController.h"
#import "ContentManager.h"
#import "CollectionViewCell.h"
#import "HomeViewController.h"
#import "AddEditFolderViewController.h"
#import "PhotoGalleryViewController.h"
#import "JSONDictionary.h"
#import "SVProgressHUD.h"
@interface CommunityViewController ()

@end

@implementation CommunityViewController



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
    //set title for navigation controller
  //  self.title=@"Community folders";
   
 
    //set navigationBar frame
    // Do any additional setup after loading the view from its nib.
    UINib *nib=[UINib nibWithNibName:@"CommunityCollectionCell" bundle:[NSBundle mainBundle]];
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
    
    //add the Tap gesture for collection view
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(tapHandle:)];
    [collectionview addGestureRecognizer:tapGesture];
    
    //add the LongPress gesture to the collection view
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPressGesture.minimumPressDuration=0.6;
    [collectionview addGestureRecognizer:longPressGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //set title for navigation controller
    self.navigationController.navigationBarHidden=NO;
    self.navigationController.navigationBar.frame=CGRectMake(0, 70, 320,30);
    self.navigationController.navigationBar.topItem.title=@"Community folders";
    
    webServices=[[WebserviceController alloc] init];
    //blueLabelImgFrame=CGRectMake(20, diskSpaceBlueLabel.frame.origin.y-64, 10,diskSpaceBlueLabel.frame.size.height );
    [self setTheDiskSpace];
    [self getTheCollectionInfoArrayFromServer];
}
//get Storage
-(void)getStorage
{
    isGetStorage=YES;
    webServices.delegate=self;
    ContentManager *manager=[ContentManager sharedManager];
    NSNumber *userId=[manager getData:@"user_id"];
    NSString *data=[NSString stringWithFormat:@"user_id=%d",[userId intValue]];
    [webServices call:data controller:@"storage" method:@"get"];
}
//get collection  info array from server
-(void)getTheCollectionInfoArrayFromServer
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    isGetCollectionInfo=YES;
    webServices.delegate=self;
    //get the user id from nsuserDefaults
    ContentManager *manager=[ContentManager sharedManager];
    NSNumber *userId=[manager getData:@"user_id"];
    
    NSString *data=[NSString stringWithFormat:@"user_id=%d&collection_user_id=%d",[userId intValue],[userId intValue]];
    
    [webServices call:data controller:@"collection" method:@"getlist"];
   
    
}
-(void)webserviceCallback:(NSDictionary *)data
{
    //NSLog(@"Call Back getList %@",data);
   
    
    NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
    if(isGetCollectionInfo)
    {
        collectionNameArray=[[NSMutableArray alloc] init];
        collectionIdArray=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in outPutData) {
            if(![[dic objectForKey:@"collection_name"] isEqualToString:@"Private"]&& ![[dic objectForKey:@"collection_name"] isEqualToString:@"Public"])
            {
                [collectionNameArray addObject:[dic objectForKey:@"collection_name"]];
                [collectionIdArray addObject:[dic objectForKey:@"collection_id"]];
                [collectionDefaultArray addObject:[dic objectForKey:@"collection_default"]];
                [collectionSharingArray addObject:[dic objectForKey:@"collection_sharing"]];
                [collectionSharedArray addObject:[dic objectForKey:@"collection_shared"]];
                
            }
            
        }
        isGetCollectionInfo=NO;
        [self getStorage];
    }
    else if(isGetStorage)
    {
        NSLog(@"Get Storage %@",data);
       // NSDictionary *dic=[outPutData objectAtIndex:0];
        //NSNumber *availableStorage=[dic objectForKey:@"storage_available"];
        //NSNumber *usedStorage=[dic objectForKey:@"storage_used"];
        //NSNumber *totalPhoto=[dic objectForKey:@"photo_total"];
        
        progressView.progress=0.2;
        isGetStorage=NO;
        [collectionview reloadData];
        [SVProgressHUD dismissWithSuccess:@"Data Loaded"];
    }
    
    // NSLog(@"Dic is %@",dic);
   
}


-(void)setTheDiskSpace
{
    //set up the diskspace progress
    NSInteger spacePerCentage=50;
    NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%li%@)",(long)spacePerCentage,@"%"];
    diskSpaceTitle.text=diskTitle;
   
}

//collection view delegate method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return [folderNameArray count]+noOfPagesInCollectionView;
    return [collectionNameArray count]+1;
}
-(CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CVCell";
    obj_Cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    obj_Cell.folder_imgV.hidden=NO;
    obj_Cell.folder_name.text = [NSString stringWithFormat:@"Folder %d",(int)[indexPath row]];
    if(indexPath.row+1==([collectionNameArray count]+1))
    {
        obj_Cell.folder_imgV.image=[UIImage imageNamed:@"add_folder.png"];
        obj_Cell.icon_img.hidden=YES;
        obj_Cell.folder_name.text=@"Add Folder";
       
    }
    else
    {
       
        int sharing=[[collectionSharingArray objectAtIndex:indexPath.row] intValue];
       
        if([collectionSharedArray objectAtIndex:indexPath.row])
        {
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
            obj_Cell.icon_img.hidden=NO;
            obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon.png"];
        }
        else
        {
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder_lock.png"];
            obj_Cell.icon_img.hidden=NO;
            obj_Cell.icon_img.image=[UIImage imageNamed:@"private-icon.png"];
        }
        if(sharing==1)
        {
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
            obj_Cell.icon_img.hidden=NO;
            obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon.png"];
        }
        else
        {
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
            obj_Cell.icon_img.hidden=YES;
        }
        obj_Cell.folder_name.text=[collectionNameArray objectAtIndex:indexPath.row];
        
        
    }
    return obj_Cell;
}
//tap gesture method
-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        if(([indexPath row]+1)==([collectionNameArray count]+1))
        {
            [self addFolder];
            NSLog(@"Add Folder selected index is %ld",(long)[indexPath row]);
        }
        else
        {
            PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
            photoGallery.isPublicFolder=NO;
            photoGallery.selectedFolderIndex=indexPath.row;
            photoGallery.folderName=[collectionNameArray objectAtIndex:[indexPath row]];
            
            [self.navigationController pushViewController:photoGallery animated:YES];
        }
        
    }
}
//longPress Gesture
-(void)longPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
       
        if(([indexPath row]+1)%12!=0 && ([indexPath row]+1)!=[collectionNameArray count]+noOfPagesInCollectionView)
        {
          [self editFolder:indexPath];
        }
    }
}

-(void)addFolder
{
 
    AddEditFolderViewController *aec1 = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController" bundle:nil] ;
       aec1.isAddFolder=YES;
    aec1.isEditFolder=NO;
    [self.navigationController pushViewController:aec1 animated:NO];
   
}
-(void)editFolder:(NSIndexPath *)indexPath
{
    AddEditFolderViewController *aec = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController" bundle:nil] ;
    aec.isAddFolder=NO;
    aec.isEditFolder=YES;
    aec.collectionId=([indexPath row]-indexPath.row/12);
    aec.setFolderName=[collectionNameArray objectAtIndex:[indexPath row]];
    aec.collectionId=[[collectionIdArray objectAtIndex:[indexPath row]] integerValue];
    
    CommunityViewController *cm = [[CommunityViewController alloc] init];
    HomeViewController *hm = [[HomeViewController alloc] init] ;
    [self.navigationController setViewControllers:[[NSArray alloc] initWithObjects:hm,cm,aec, nil]];
  
    [self.navigationController pushViewController:aec animated:NO];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
