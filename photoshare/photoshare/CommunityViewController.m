//
//  CommunityViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "CommunityViewController.h"
#import "CollectionViewCell.h"
#import "HomeViewController.h"
#import "AddEditFolderViewController.h"
#import "PhotoGalleryViewController.h"
#import "JSONDictionary.h"
#import "SVProgressHUD.h"
#import "NavigationBar.h"

@interface CommunityViewController ()

@end

@implementation CommunityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    manager=[ContentManager sharedManager];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationItem.title = @"Community folders";
    self.navigationController.navigationBar.frame=CGRectMake(0, 70, 320,30);
    UINib *nib=[UINib nibWithNibName:@"CommunityCollectionCell" bundle:[NSBundle mainBundle]];
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
    //webservice
    webservices=[[WebserviceController alloc] init];
    //add the Tap gesture for collection view
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(tapHandle:)];
    [collectionview addGestureRecognizer:tapGesture];
    
    //add the LongPress gesture to the collection view
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPressGesture.minimumPressDuration=0.6;
    [collectionview addGestureRecognizer:longPressGesture];
    
    if([UIScreen mainScreen].bounds.size.height == 568)
    {
         collectionview.frame=CGRectMake(20, 100, 280, 365);
    }
    else if([UIScreen mainScreen].bounds.size.height == 480)
    {
        collectionview.frame=CGRectMake(20, 190, 280, collectionview.frame.size.height-70);
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //editBtn When Longpress on folder
    editBtn=[[UIButton alloc] init];
    
    
    //set title for navigation controller
    [self addCustomNavigationBar];
  
   
    //set Disk Space Progress
    float progressPercent=[[manager getData:@"disk_space"] floatValue];
    NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%.2f%@)",(progressPercent*100),@"%"];
    diskSpaceTitle.text=diskTitle;
    progressView.progress=progressPercent;
    
    //get the user ID from NSUSER Default
    userid=[manager getData:@"user_id"];
    //fetch collection info from serv er
    [self fetchCollectionInfoFromServer];
    //[self getCollectionInfoFromUserDefault];
    
    //[self fetchCollectionInfoFromServer];
    //[self getStorageFromServer];
}
-(void)getStorageFromServer
{
    @try {
        isGetStorage=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"storage" method:@"get"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
    }
    
}
//Fetch data From Server
-(void)fetchCollectionInfoFromServer
{
    @try {
        isGetTheCollectionListData=YES;
        webservices.delegate=self;
        [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"getlist"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}
-(void) webserviceCallback:(NSDictionary *)data
{
    NSLog(@"login callback%@",data);
    
    //validate the user
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    if(isGetStorage)
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
            
            NSLog(@"Get Storage %@",data);
            NSDictionary *dic=[outPutData objectAtIndex:0];
            NSNumber *availableStorage=[dic objectForKey:@"storage_available"];
            NSNumber *usedStorage=[dic objectForKey:@"storage_used"];
            //NSNumber *totalPhoto=[dic objectForKey:@"photo_total"];
            float availableSpaceInMB=(float)([availableStorage doubleValue]/(double)(1024*1024)) ;
            float usedSpaceInMB=(float)([usedStorage doubleValue]/(double)(1024*1024));
            
            //set the diskSpacePercentage
            float progressPercent=(float)(usedSpaceInMB/availableSpaceInMB);
            NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%.2f%@)",(progressPercent*100),@"%"];
            diskSpaceTitle.text=diskTitle;
            progressView.progress=progressPercent;
            //store in NSDefault
            [manager storeData:[NSNumber numberWithFloat:progressPercent] :@"disk_space"];
            isGetStorage=NO;
        }
  
    }
    else if(isGetTheCollectionListData)
    {
        [SVProgressHUD dismiss];
        //set collection List in NSDefault
        NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
        [manager storeData:outPutData :@"collection_data_list"];
        isGetTheCollectionListData=NO;
        [self getCollectionInfoFromUserDefault];
        [self getStorageFromServer];
        
    }
}

-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[[[NSUserDefaults standardUserDefaults] objectForKey:@"collection_data_list"] mutableCopy];
    
    collectionDefaultArray=[[NSMutableArray alloc] init];
    collectionIdArray=[[NSMutableArray alloc] init];
    collectionNameArray=[[NSMutableArray alloc] init];
    collectionSharedArray=[[NSMutableArray alloc] init];
    collectionSharingArray=[[NSMutableArray alloc] init];
    collectionUserIdArray=[[NSMutableArray alloc] init];
    
    for (int i=2;i<collection.count; i++)
    {
        [collectionDefaultArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_default"]];
        [collectionIdArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_id"]];
        [collectionNameArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_name"]];
        [collectionSharedArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_shared"]];
        [collectionSharingArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_sharing"]];
        [collectionUserIdArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_user_id"]];
    }
    [collectionview reloadData];
    //
    
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
    int index=indexPath.row-1;
    if(indexPath.row==0)
    {
        obj_Cell.folder_imgV.image=[UIImage imageNamed:@"add_folder.png"];
        obj_Cell.icon_img.hidden=YES;
        obj_Cell.folder_name.text=@"Add Folder";
       
    }
    else
    {
        /*int sharing=[[collectionSharingArray objectAtIndex:index] intValue];
        BOOL flag=false;
        if(![collectionSharedArray objectAtIndex:index])
        {
            flag=TRUE;
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder_lock.png"];
            obj_Cell.icon_img.hidden=NO;
            obj_Cell.icon_img.image=[UIImage imageNamed:@"private-icon.png"];
        }
              
        if(!flag)
        {
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
        }*/
        int shared=[[collectionSharedArray objectAtIndex:index] integerValue];
        if(shared==1)
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

        obj_Cell.folder_name.text=[collectionNameArray objectAtIndex:index];
        
    }
    return obj_Cell;
}
//tap gesture method
-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    //if editBtnIs in view
    [editBtn removeFromSuperview];

    
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        if(indexPath.row==0)
        {
            [self addFolder];
            NSLog(@"Add Folder selected index is %ld",(long)[indexPath row]);
        }
        else
        {
            int index=indexPath.row-1;
            PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
            photoGallery.isPublicFolder=NO;
            photoGallery.selectedFolderIndex=index;
            photoGallery.folderName=[collectionNameArray objectAtIndex:index];
            photoGallery.collectionId=[collectionIdArray objectAtIndex:index];
            
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
       
        if(indexPath.row!=0)
        {
            
            UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
            editBtn.frame=CGRectMake(cell.frame.origin.x+12, cell.frame.origin.y-10, 60, 50);
            [editBtn setImage:[UIImage imageNamed:@"edit_btn.png"] forState:UIControlStateNormal];
            [editBtn addTarget:self action:@selector(editFolder:) forControlEvents:UIControlEventTouchUpInside];
            
            [collectionview addSubview:editBtn];
            
          //[self editFolder:indexPath];
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
-(void)editFolder:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    CGPoint p=CGPointMake(btn.frame.origin.x, btn.frame.origin.y+20);
    NSIndexPath *indexPath=[collectionview indexPathForItemAtPoint:p];
    int index=indexPath.row-1;
    //if editBtnIs in view
    [editBtn removeFromSuperview];
    
    AddEditFolderViewController *aec = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController" bundle:nil] ;
    aec.isAddFolder=NO;
    aec.isEditFolder=YES;
    aec.setFolderName=[collectionNameArray objectAtIndex:index];
    aec.collectionId=[collectionIdArray objectAtIndex:index] ;
    aec.collectionShareWith=[collectionSharingArray objectAtIndex:index] ;
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
   // button.backgroundColor = [UIColor redColor];
    
    UILabel *titleLabel = [[UILabel alloc] init ];
    titleLabel.text=@"Your folders";
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(100.0, 47.0, 120.0, 30.0);
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [navnBar addSubview:titleLabel];
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
}

-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}



@end
