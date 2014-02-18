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
#import "SearchPhotoViewController.h"

@interface CommunityViewController ()

@end

@implementation CommunityViewController
@synthesize isInNavigation;
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
     manager=[ContentManager sharedManager];
    [manager storeData:@"" :@"writeUserId"];
    [manager storeData:@"" :@"readUserId"];
    
    //webservice
    webservices=[[WebserviceController alloc] init];
    dmc=[[DataMapperController alloc] init];
    //get the user ID from NSUSER Default
    userid=[manager getData:@"user_id"];

    
    
    self.navigationItem.title = @"Community folders";
    self.navigationController.navigationBar.frame=CGRectMake(0, 70, 320,30);
    //UINib *nib=[UINib nibWithNibName:@"CommunityCollectionCell" bundle:[NSBundle mainBundle]];
    
    UINib *nib;
    if([manager isiPad])
    {
        nib=[UINib nibWithNibName:@"CommunityCollectionCell_iPad" bundle:[NSBundle mainBundle]];
    }
    else
    {
        nib=[UINib nibWithNibName:@"CommunityCollectionCell" bundle:[NSBundle mainBundle]];
    }
    
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
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
        collectionview.frame=CGRectMake(20, 190, 280, collectionview.frame.size.height-76);
    }
    
    
    //editBtn When Longpress on folder
    editBtn=[[UIButton alloc] init];
    
    //initialize the array
    sharingIdArray=[[NSMutableArray alloc] init];
    collectionArrayWithSharing=[[NSMutableArray alloc] init];
    collectionDefaultArray=[[NSMutableArray alloc] init];
    collectionIdArray=[[NSMutableArray alloc] init];
    collectionNameArray=[[NSMutableArray alloc] init];
    collectionSharedArray=[[NSMutableArray alloc] init];
    collectionSharingArray=[[NSMutableArray alloc] init];
    collectionUserIdArray=[[NSMutableArray alloc] init];
    
    //update the collection info in nsuser default from server
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    //get DiskSpace from server
    [self getStorageFromServer];
    
    
    //set title for navigation controller
    [self addCustomNavigationBar];
  
    [self getCollectionInfoFromUserDefault];
    
}
-(void)getCollectionInfoFromUserDefault
{
    NSMutableArray *collection=[dmc getCollectionDataList];
    [collectionDefaultArray removeAllObjects];
    [collectionIdArray removeAllObjects];
    [collectionNameArray removeAllObjects];
    [collectionSharedArray removeAllObjects];
    [collectionSharingArray removeAllObjects];
    [collectionUserIdArray removeAllObjects];
    
    for (int i=0;i<collection.count; i++)
    {
        @try {
            if(![[[collection objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"Public"]&& ![[[collection objectAtIndex:i] objectForKey:@"collection_name"] isEqualToString:@"public"])
            {
                [collectionDefaultArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_default"]];
                [collectionIdArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_id"]];
                [collectionNameArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_name"]];
                [collectionSharedArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_shared"]];
                [collectionSharingArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_sharing"]];
                [collectionUserIdArray addObject:[[collection objectAtIndex:i] objectForKey:@"collection_user_id"]];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Execption is %@",exception.description);
        }
        @finally {
            
        }
        
    }
    [collectionview reloadData];
    //
    
}

-(void)getStorageFromServer
{
    @try {
        //[SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];

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
-(void)getSharingusersId
{
    @try {
        isGetSharingUserId=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"collection" method:@"sharing"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}
//Fetch data From Server
-(void)fetchOwnCollectionInfoFromServer
{
    @try {
        isGetTheOwnCollectionListData=YES;
            webservices.delegate=self;
            NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":userid};
            [webservices call:dicData controller:@"collection" method:@"getlist"];
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}
-(void)fetchSharingCollectionInfoFromServer
{
    @try {
        if(sharingIdArray.count>0)
        {
            countSharing=0;
            for (int i=0; i<sharingIdArray.count; i++) {
                isGetTheSharingCollectionListData=YES;
                webservices.delegate=self;
                NSDictionary *dicData=@{@"user_id":userid,@"collection_user_id":[sharingIdArray objectAtIndex:i]};
                [webservices call:dicData controller:@"collection" method:@"getlist"];
            }
        }
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
            @try {
                NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
                
                NSLog(@"Get Storage %@",data);
                NSDictionary *dic=[outPutData objectAtIndex:0];
                NSNumber *availableStorage=[dic objectForKey:@"storage_available"];
                NSNumber *usedStorage=[dic objectForKey:@"storage_used"];
                if(availableStorage==(id)NULL)
                {
                    availableStorage=@0;
                }
                if(usedStorage==(id)NULL)
                {
                    usedStorage=@0;
                }
                //NSNumber *totalPhoto=[dic objectForKey:@"photo_total"];
                float availableSpaceInMB=(float)([availableStorage doubleValue]/(double)(1024*1024)) ;
                float usedSpaceInMB=(float)([usedStorage doubleValue]/(double)(1024*1024));
                
                //set the diskSpacePercentage
                float progressPercent=(float)(usedSpaceInMB/availableSpaceInMB);
                NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%.2f%@)",(progressPercent*100),@"%"];
                diskSpaceTitle.text=diskTitle;
                progressView.progress=progressPercent;
                
                isGetStorage=NO;
                
                //[self getSharingusersId];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        }
        
    }

    else if(isGetSharingUserId)
    {
        if(exitCode.integerValue==1)
        {
            NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
            [sharingIdArray removeAllObjects];
            for (int i=0; i<outPutData.count; i++)
            {
                @try {
                    [sharingIdArray addObject:[[outPutData objectAtIndex:i] objectForKey:@"user_id"]];
                }
                @catch (NSException *exception) {
                    
                }
                @finally {
                    
                }
                
            }
            
        }
        isGetSharingUserId=NO;
        [self fetchOwnCollectionInfoFromServer];
        
    }
    else if(isGetTheOwnCollectionListData)
    {
        [collectionArrayWithSharing removeAllObjects];
        if(exitCode.integerValue==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]] ;
            //nsuser default
            
        }
        isGetTheOwnCollectionListData=NO;
        if(sharingIdArray.count>0)
        {
            [self fetchSharingCollectionInfoFromServer];
        }
        else
        {
            
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
        }
        
    }
    else if (isGetTheSharingCollectionListData)
    {
        if(exitCode.integerValue==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]] ;
        }
        countSharing++;
        if(countSharing==sharingIdArray.count)
        {
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
        }
    }
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
    obj_Cell.folder_imgV.layer.masksToBounds=YES;
    obj_Cell.icon_img.layer.masksToBounds=YES;
    @try {
        int index=indexPath.row-1;
        if(indexPath.row==0)
        {
            obj_Cell.folder_imgV.image=[UIImage imageNamed:@"add_folder.png"];
            obj_Cell.icon_img.hidden=YES;
            obj_Cell.folder_name.text=@"Add Folder";
            
        }
        else
        {
           
            int shared=[[collectionSharedArray objectAtIndex:index] intValue];
            //int sharing=[[collectionSharingArray objectAtIndex:index] intValue];
            //BOOL flag=FALSE;
            
                 /*if(sharing==1)
                 {
                     obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
                     obj_Cell.icon_img.hidden=NO;
                     obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon.png"];
                      flag=TRUE;                        }
                 else
                 {
                     
                     obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
                     obj_Cell.icon_img.hidden=YES;
                 }
            
             if(!flag && shared==1)
             {
                 obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
                 obj_Cell.icon_img.hidden=NO;
                 obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon3.png"];

             }*/
            
            
            int colOwnerId=[[collectionUserIdArray objectAtIndex:index] integerValue];
            
            if(userid.integerValue==colOwnerId)
            {
                if(shared==1)
                {
                    obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
                    obj_Cell.icon_img.hidden=NO;
                    obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon3.png"];
                    
                }
                else
                {
                    
                    obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
                    obj_Cell.icon_img.hidden=YES;
                }
                
            }
            else
            {
                obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
                obj_Cell.icon_img.hidden=NO;
                obj_Cell.icon_img.image=[UIImage imageNamed:@"shared-icon.png"];
            }

            obj_Cell.folder_name.text=[collectionNameArray objectAtIndex:index];
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
    @finally {
        
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
            @try {
                int index=indexPath.row-1;
                PhotoGalleryViewController *photoGallery;
                if([manager isiPad])
                {
                    photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController_iPad" bundle:[NSBundle mainBundle]];
                }
                else
                {
                    photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
                }
                photoGallery.isPublicFolder=NO;
                photoGallery.selectedFolderIndex=index;
                photoGallery.folderName=[collectionNameArray objectAtIndex:index];
                photoGallery.collectionId=[collectionIdArray objectAtIndex:index];
                photoGallery.collectionOwnerId=[collectionUserIdArray objectAtIndex:index];
                
                [self.navigationController pushViewController:photoGallery animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception is %@",exception.description);
            }
            @finally {
                
            }
            
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
    AddEditFolderViewController *aec1;
    if([manager isiPad])
    {
        aec1 = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController_iPad" bundle:[NSBundle mainBundle]] ;
    }
    else
    {
        aec1 = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController" bundle:[NSBundle mainBundle]] ;
    }
    
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
    @try {
        AddEditFolderViewController *aec;
        if([manager isiPad])
        {
            aec = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController_iPad" bundle:[NSBundle mainBundle]] ;
        }
        else
        {
            aec = [[AddEditFolderViewController alloc] initWithNibName:@"AddEditFolderViewController" bundle:[NSBundle mainBundle]] ;
        }

        
        aec.isAddFolder=NO;
        aec.isEditFolder=YES;
        aec.setFolderName=[collectionNameArray objectAtIndex:index];
        aec.collectionId=[collectionIdArray objectAtIndex:index] ;
        aec.collectionShareWith=[collectionSharingArray objectAtIndex:index] ;
        aec.collectionOwnerId=[collectionUserIdArray objectAtIndex:index];
        
        CommunityViewController *cm ;
        HomeViewController *hm;
        if([manager isiPad])
        {
            cm=[[CommunityViewController alloc] initWithNibName:@"CommunityViewController_iPad" bundle:[NSBundle mainBundle]];
            hm = [[HomeViewController alloc] initWithNibName:@"HomeViewController_iPad" bundle:[NSBundle mainBundle]] ;
        }
        else
        {
            cm=[[CommunityViewController alloc] initWithNibName:@"CommunityViewController" bundle:[NSBundle mainBundle]];
            hm = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:[NSBundle mainBundle]] ;
        }
        
        [self.navigationController setViewControllers:[[NSArray alloc] initWithObjects:hm,cm,aec, nil]];
        
        [self.navigationController pushViewController:aec animated:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"Execption is %@",exception.description);
    }
    @finally {
        
    }
    
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
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
   
   // button.backgroundColor = [UIColor redColor];
    
    UILabel *titleLabel = [[UILabel alloc] init ];
    titleLabel.text=@"Your folders";
    titleLabel.textAlignment=NSTextAlignmentCenter;
   
    
    //add photo search button
    UIButton *searchBtn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [searchBtn addTarget:self action:@selector(searchViewOpen) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitle:@"Search" forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    if([manager isiPad])
    {
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 90.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
        titleLabel.frame = CGRectMake(self.view.center.x-75, NavBtnYPosForiPad, 150.0, NavBtnHeightForiPad);
        titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
        searchBtn.frame=CGRectMake(self.view.frame.size.width-100, NavBtnYPosForiPad, 100.0, NavBtnHeightForiPad);
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:23.0f];
    }
    else
    {
         button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
         button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        titleLabel.frame = CGRectMake(100.0, NavBtnYPosForiPhone, 120.0, NavBtnHeightForiPhone);
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        searchBtn.frame=CGRectMake(250.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        searchBtn.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    [navnBar addSubview:searchBtn];
    [navnBar addSubview:titleLabel];
    NSLog(@"tab index %d",self.tabBarController.selectedIndex);
   
    [navnBar addSubview:button];
    
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}
-(void)navBackButtonClick{
    if(![[self navigationController] popViewControllerAnimated:YES])
    {
        [self.tabBarController setSelectedIndex:0];
    }
}
-(void)searchViewOpen
{
    SearchPhotoViewController *searchController;
    if([manager isiPad])
    {
        searchController=[[SearchPhotoViewController alloc] initWithNibName:@"SearchPhotoViewController_iPad" bundle:[NSBundle mainBundle]];
    }
    else{
        searchController=[[SearchPhotoViewController alloc] initWithNibName:@"SearchPhotoViewController" bundle:[NSBundle mainBundle]];
    }
    [self.navigationController pushViewController:searchController animated:NO];
}


@end
