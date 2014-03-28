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

@interface CommunityViewController ()

@end

@implementation CommunityViewController
@synthesize isInNavigation,updateCollectionDetails;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if([[ContentManager sharedManager] isiPad])       nibNameOrNil=@"CommunityViewController_iPad";
    else nibNameOrNil=@"CommunityViewController";
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTheGlobalObject];
    [self addCustomNavigationBar];
    [self setUIForIOS6];
    
    NSString *nibName;
    if([manager isiPad]) nibName=@"CommunityCollectionCell_iPad";
    else nibName=@"CommunityCollectionCell";
    UINib *nib=[UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]];
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
    //Add The Tap and Longpress Gesture to the Collection view
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(tapHandle:)];
    UILongPressGestureRecognizer *longPressGesture=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    longPressGesture.minimumPressDuration=0.6;
    [collectionview addGestureRecognizer:tapGesture];
    [collectionview addGestureRecognizer:longPressGesture];   
    
    sharingIdArray=[[NSMutableArray alloc] init];
    collectionArrayWithSharing=[[NSMutableArray alloc] init];
    collectionDefaultArray=[[NSMutableArray alloc] init];
    collectionIdArray=[[NSMutableArray alloc] init];
    collectionNameArray=[[NSMutableArray alloc] init];
    collectionSharedArray=[[NSMutableArray alloc] init];
    collectionSharingArray=[[NSMutableArray alloc] init];
    collectionUserIdArray=[[NSMutableArray alloc] init];
    
    updateCollectionDetails=YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
    [self getCollectionInfoFromUserDefault];
    [self getStorageFromServer];
    //Set Tabbar item Selected
    [self.tabBarController setSelectedIndex:3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUIForIOS6
{
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        collectionview.frame=CGRectMake(collectionview.frame.origin.x, collectionview.frame.origin.y-20, collectionview.frame.size.width, collectionview.frame.size.height+70);
        progressView.frame=CGRectMake(progressView.frame.origin.x, progressView.frame.origin.y+45, progressView.frame.size.width, progressView.frame.size.height);
        diskSpaceTitle.frame=CGRectMake(diskSpaceTitle.frame.origin.x, diskSpaceTitle.frame.origin.y+45, diskSpaceTitle.frame.size.width, diskSpaceTitle.frame.size.height);
    }
}
-(void)initializeTheGlobalObject
{
    searchController=[[SearchPhotoViewController alloc] init];
    manager=[ContentManager sharedManager];
    //webservice
    webservices=[[WebserviceController alloc] init];
    dmc=[[DataMapperController alloc] init];
    //get the user ID from NSUSER Default
    userid=[manager getData:@"user_id"];
}
#pragma mark - Get Data from (NSUser Default)
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
    }
    [collectionview reloadData];
}

#pragma mark - Fetch and store the data on the server
-(void)getStorageFromServer
{
    @try {
        if(updateCollectionDetails)
        {
            [SVProgressHUD showWithStatus:@"Fetching" maskType:SVProgressHUDMaskTypeBlack];
        }
        isGetStorage=YES;
        webservices.delegate=self;
        NSDictionary *dicData=@{@"user_id":userid};
        [webservices call:dicData controller:@"storage" method:@"get"];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
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
}
//fetch shareing collection info from server
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
}

#pragma mark - Webservice call Back Methods
-(void) webserviceCallback:(NSDictionary *)data
{   
    //validate the user
    NSNumber *exitCode=[data objectForKey:@"exit_code"];
    
    if(isGetStorage)
    {
        if(exitCode.integerValue==1)
        {
            @try {
                NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
                
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
                @try {
                    if(usedStorage.integerValue==0)
                    {
                        
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Exception is %@",exception.description);
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
                
            }
            @catch (NSException *exception) {
                
            }
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        isGetStorage=NO;
        if (updateCollectionDetails)
        {
            //For update the collection info in nsuser default
            updateCollectionDetails=NO;
            [self getSharingusersId];
        }
    }
    else if(isGetSharingUserId)
    {
        if(exitCode.integerValue==1)
        {
            @try {
                NSMutableArray *outPutData=[data objectForKey:@"output_data"] ;
                sharingIdArray=[outPutData valueForKey:@"user_id"];
            }
            @catch (NSException *exception) {
                
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
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        isGetTheOwnCollectionListData=NO;
        if(sharingIdArray.count>0)
        {
            [self fetchSharingCollectionInfoFromServer];
        }
        else
        {
            [SVProgressHUD dismiss];
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
            [self getCollectionInfoFromUserDefault];
        }
    }
    else if (isGetTheSharingCollectionListData)
    {
        if(exitCode.integerValue==1)
        {
            [collectionArrayWithSharing addObjectsFromArray:[data objectForKey:@"output_data"]] ;
        }
        else
        {
            [SVProgressHUD dismiss];
        }
        countSharing++;
        if(countSharing==sharingIdArray.count)
        {
            [SVProgressHUD dismiss];
            [manager storeData:collectionArrayWithSharing :@"collection_data_list"];
            [self getCollectionInfoFromUserDefault];
        }
    }
}

#pragma mark - UICollectionView delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{   
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
                obj_Cell.icon_img.image=[UIImage imageNamed:@"sharedIcon.png"];
            }
            obj_Cell.folder_name.text=[collectionNameArray objectAtIndex:index];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception.description);
    }
   
        return obj_Cell;
}

#pragma mark - Gesture Methods
-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        if(indexPath.row==0)
        {
            [self addFolder];
        }
        else
        {
            @try {
                int index=indexPath.row-1;
                PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] init];
                photoGallery.isPublicFolder=NO;
                photoGallery.selectedFolderIndex=index;
                photoGallery.folderName=[collectionNameArray objectAtIndex:index];
                photoGallery.collectionId=[collectionIdArray objectAtIndex:index];
                photoGallery.collectionOwnerId=[collectionUserIdArray objectAtIndex:index];
                [manager storeData:@"NO" :@"istabcamera"];
                
                [self.navigationController pushViewController:photoGallery animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"Exception is %@",exception.description);
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
            selectedFolderIndex=indexPath.row;
            UICollectionViewCell *cell=[collectionview cellForItemAtIndexPath:indexPath];
           
            UIMenuItem *editPhoto = [[UIMenuItem alloc] initWithTitle:@"Edit" action:@selector(editFolder:)];
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            CGRect menucontrollerFrame;
            if([manager isiPad])
            {
                menucontrollerFrame=CGRectMake(cell.frame.origin.x+50,cell.frame.origin.y+50, 50, 50);
            }
            else
            {
                menucontrollerFrame=CGRectMake(cell.frame.origin.x+15,cell.frame.origin.y+40, 50, 50);
            }
            [menu setMenuItems:[NSArray arrayWithObjects:editPhoto,nil]];
            [menu setTargetRect:menucontrollerFrame inView:cell.superview];
            [menu setMenuVisible:YES animated:YES];

        }
    }
}

#pragma mark - UIMenu Controller Delegate Methods
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action==@selector(editFolder:))
    {
        return YES;
    }
    return NO;
}
//for UIMenu controller
- (BOOL)canBecomeFirstResponder {
	return YES;
}
#pragma mark - Folder action perform methods
-(void)addFolder
{
    AddEditFolderViewController *aec1=[[AddEditFolderViewController alloc] init];
    
    aec1.isAddFolder=YES;
    aec1.isEditFolder=NO;
    [self.navigationController pushViewController:aec1 animated:YES];
   
}
-(void)editFolder:(id)sender
{
    int index=selectedFolderIndex-1;
    
    @try {
       AddEditFolderViewController *aec=[[AddEditFolderViewController alloc] init];
        
        aec.isAddFolder=NO;
        aec.isEditFolder=YES;
        aec.setFolderName=[collectionNameArray objectAtIndex:index];
        aec.collectionId=[collectionIdArray objectAtIndex:index] ;
        aec.collectionOwnerId=[collectionUserIdArray objectAtIndex:index];
        
        //CommunityViewController *cm =[[CommunityViewController alloc] init];
        //HomeViewController *hm=[[HomeViewController alloc] init];
        
        //[self.navigationController setViewControllers:[[NSArray alloc] initWithObjects:hm,cm,aec, nil]];
    
        [self.navigationController pushViewController:aec animated:NO];
    }
    @catch (NSException *exception) {
        NSLog(@"Execption is %@",exception.description);
    }
}

#pragma mark - SearchViewController
-(void)searchViewOpen
{
    searchController=nil;
    searchController=[[SearchPhotoViewController alloc] init];
    searchController.searchType=@"myfolders";
    [self.navigationController pushViewController:searchController animated:NO];
}

#pragma mark - Custom Navigation Bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
   
    
    UILabel *titleLabel = [navnBar navBarTitleLabel:@"Your Folders"];
    
    UIButton *searchBtn=[navnBar navBarRightButton:@"Search"];
    [searchBtn addTarget:self action:@selector(searchViewOpen) forControlEvents:UIControlEventTouchUpInside];
    
    
    [navnBar addSubview:searchBtn];
    [navnBar addSubview:button];
    [navnBar addSubview:titleLabel];
    [[self view] addSubview:navnBar];
}
-(void)navBackButtonClick{
    
    [self.tabBarController setSelectedIndex:0];
    updateCollectionDetails=YES;
}


@end
