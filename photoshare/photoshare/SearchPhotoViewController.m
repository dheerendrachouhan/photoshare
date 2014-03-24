//
//  SearchPhotoViewController.m
//  photoshare
//
//  Created by ignis2 on 13/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "SearchPhotoViewController.h"
#import "SVProgressHUD.h"
#import "LargePhotoViewController.h"
@interface SearchPhotoViewController ()

@end

@implementation SearchPhotoViewController
@synthesize searchType;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if([[ContentManager sharedManager] isiPad])
    {
        nibNameOrNil=@"SearchPhotoViewController_iPad";
    }
    else
    {
        nibNameOrNil=@"SearchPhotoViewController";
    }

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
    [self setUIForIOS6];
    //set the search bar become first responder
    [searchBarForPhoto becomeFirstResponder];
    manager =[ContentManager sharedManager];
    webservice =[[WebserviceController alloc] init];
    dmc = [[DataMapperController alloc] init];
    userid=[manager getData:@"user_id"];
    
    searchResultArray = [[NSArray alloc] init];
    photoArray =[[NSMutableArray alloc] init];
    photDetailArray =[[NSMutableArray alloc] init];
    
    //register collection view class
    [collectionViewForPhoto registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    
    //add tap Gesture on Collection View
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [collectionViewForPhoto addGestureRecognizer:tapGesture];
    
    [self addCustomNavigationBar];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=NO;
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUIForIOS6
{
    //Set for ios 6
    if(!IS_OS_7_OR_LATER && IS_OS_6_OR_LATER)
    {
        searchBarForPhoto.frame=CGRectMake(searchBarForPhoto.frame.origin.x, searchBarForPhoto.frame.origin.y-20, searchBarForPhoto.frame.size.width, searchBarForPhoto.frame.size.height);
        collectionViewForPhoto.frame=CGRectMake(collectionViewForPhoto.frame.origin.x, collectionViewForPhoto.frame.origin.y-20, collectionViewForPhoto.frame.size.width, collectionViewForPhoto.frame.size.height+65);
    }
}
#pragma mark - Search bar delegate Methods
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isStartGetPhoto=NO;
    [photoArray removeAllObjects];
    [photDetailArray removeAllObjects];
    
    [collectionViewForPhoto reloadData];
    
    [searchBar resignFirstResponder];
    NSLog(@"search bar text %@",searchBar.text);
    
    searchString=searchBar.text;
    [self searchPhotoOnServer];
    
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchString=searchBar.text;
    
}

#pragma mark - Fetch data on server
-(void)searchPhotoOnServer
{
   
    isSearchPhoto=YES;
    webservice=[[WebserviceController alloc] init];
    webservice.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"search_term":searchString};
    [webservice call:dicData controller:@"photo" method:@"search"];
}
//get Photo From Server
-(void)getPhotoFromServer :(int)photoIdIndex imageResize:(NSString *)resize
{
    
    NSDictionary *dicData;
    
    @try {
        if(photDetailArray.count>0)
        {
            isStartGetPhoto=YES;
            NSNumber *colId=[[photDetailArray objectAtIndex:photoIdIndex] objectForKey:@"photo_collection_id"];
            
            NSNumber *photoId=[[photDetailArray objectAtIndex:photoIdIndex] objectForKey:@"photo_id"];
            
            webservice.delegate=self;
            NSNumber *num = [NSNumber numberWithInt:1] ;
            
            dicData = @{@"user_id":userid,@"photo_id":photoId,@"get_image":num,@"collection_id":colId,@"image_resize":resize};
            [webservice call:dicData controller:@"photo" method:@"get"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is found :%@",exception.description);
    }
}

#pragma mark - webservice call back methods
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Call bAck Data %@",data);

    if(isSearchPhoto)
    {
        [photDetailArray removeAllObjects];
        [photoArray removeAllObjects];
        
        searchResultArray=[data objectForKey:@"output_data"];
         NSString *publicColId=[manager getData:@"public_collection_id"];
        NSMutableArray *collection=[dmc getCollectionDataList];
        NSMutableArray *colidsArray=[[NSMutableArray alloc] init];
        for (NSDictionary *dic in collection) {
            [colidsArray addObject:[dic objectForKey:@"collection_id"]];
        }
        [colidsArray removeObject:publicColId];
        @try {
                //Search for 123Public folders
                if([self.searchType isEqualToString:@"public"])
                {
                    for (int i=0; i<searchResultArray.count; i++)
                    {
                        @try {
                            NSNumber *seacrhSharingId=[[searchResultArray objectAtIndex:i] objectForKey:@"collection_sharing"];
                            
                            
                            if(seacrhSharingId.integerValue==1)
                            {
                                [photDetailArray addObject:[searchResultArray objectAtIndex:i]];
                            }
                        }
                        @catch (NSException *exception) {
                            
                        }
                    }
                }
                else if ([self.searchType isEqualToString:@"myfolders"])
                {
                    for (int i=0; i<searchResultArray.count; i++)
                    {
                        @try {
                            NSNumber *seacrhSharingId=[[searchResultArray objectAtIndex:i] objectForKey:@"collection_sharing"];
                            
                            if(seacrhSharingId.integerValue==0)
                            {
                                [photDetailArray addObject:[searchResultArray objectAtIndex:i]];
                            }
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
            }
           
        }
        @catch (NSException *exception) {
            NSLog(@"Exception in search %@",exception.description);
        }
        
        isSearchPhoto=NO;
        if(photDetailArray.count>0)
        {
            photoCount=0;
            isGetPhotoFromServer=YES;
            [collectionViewForPhoto reloadData];
            [self getPhotoFromServer:0 imageResize:@"80"];
        }
        else
        {
            [manager showAlert:@"Message" msg:@"No Photo Found" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
    }
}

-(void)webserviceCallbackImage:(UIImage *)image
{
    //dismiss the progress bar
     [SVProgressHUD dismiss];
    if(isGetPhotoFromServer)
    {
        if(image==NULL)
        {
            image=[UIImage imageNamed:@"photo-warning.png"];
        }
        [photoArray addObject:image];
        photoCount++;
        int count=photoArray.count;
        NSLog(@"Photo Array Count is : %d",count);
        UIImageView *imgView=(UIImageView *)[collectionViewForPhoto viewWithTag:100+count];
        UIActivityIndicatorView *indicator=(UIActivityIndicatorView *)[collectionViewForPhoto viewWithTag:1100+count];
        [indicator removeFromSuperview];
        imgView.backgroundColor=[UIColor clearColor];
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        imgView.layer.masksToBounds=YES;
        imgView.image=image;
        [collectionViewForPhoto reloadData];
        
        if(photoCount<photDetailArray.count)
        {
            isGetPhotoFromServer=YES;

            if(isPopFromSearchPhoto)
            {
                isPopFromSearchPhoto=NO;
            }
            else
            {
                if(isStartGetPhoto)
                {
                    [self getPhotoFromServer:photoCount imageResize:@"80"];
                }
            }
        }
        else
        {
            isGetPhotoFromServer=NO;
        }
    }
}

#pragma mark - remove the imageview
-(void)removeImgView :(UITapGestureRecognizer *)gesture
{
    [imgView1 removeFromSuperview];
    isViewLargeImageMode=NO;
    self.tabBarController.tabBar.hidden=NO;
}
#pragma mark - UICollection view delegate methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return photDetailArray.count ;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    for (UIView *vi in [cell.contentView subviews]) {
        [vi removeFromSuperview];
    }
    UIImageView *imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height-25)];
    
    int row=indexPath.row;
    
    imgView.tag=101+row;
    imgView.layer.masksToBounds=YES;
    
    UILabel *photoTitleLbl=[[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-25, cell.frame.size.width, 25)];
    photoTitleLbl.font=[UIFont fontWithName:@"Verdana" size:10];
    photoTitleLbl.numberOfLines=0;
    photoTitleLbl.textAlignment=NSTextAlignmentCenter;
    photoTitleLbl.text=[[photDetailArray objectAtIndex:row] objectForKey:@"photo_title"];
    
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
            activityIndicator.center = CGPointMake(CGRectGetWidth(imgView.bounds)/2, CGRectGetHeight(imgView.bounds)/2);
            [cell.contentView addSubview:activityIndicator];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception Name : %@",exception.name);
        NSLog(@"Exception Description : %@",exception.description);
    }
    
    [cell.contentView addSubview:imgView];
    [cell.contentView addSubview:photoTitleLbl];
    return cell;
}

#pragma mark - Gesture method
-(void)tapHandle :(UITapGestureRecognizer *)gesture
{
    [searchBarForPhoto resignFirstResponder];
    CGPoint p = [gesture locationInView:collectionViewForPhoto];
    
    NSIndexPath *indexPath = [collectionViewForPhoto indexPathForItemAtPoint:p];
    if(indexPath!=Nil)
    {
        if(photoArray.count<=indexPath.row)
        {
            [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            NSNumber *colId=[[photDetailArray objectAtIndex:indexPath.row] objectForKey:@"photo_collection_id"];
            
            NSNumber *photoId=[[photDetailArray objectAtIndex:indexPath.row] objectForKey:@"photo_id"];
            LargePhotoViewController *largePhoto=[[LargePhotoViewController alloc] init];
            largePhoto.photoId=photoId;
            largePhoto.colId=colId;
            [self.navigationController pushViewController:largePhoto animated:YES];
        }
    }
}

#pragma mark - Add custom navigation bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    navnBar = [[NavigationBar alloc] init];
    [navnBar loadNav];
    UIButton *button = [navnBar navBarLeftButton:@"< Back"];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    
    UILabel *titleLabel =[navnBar navBarTitleLabel:@"Search Photos"];
    
    [navnBar addSubview:titleLabel];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}
-(void)navBackButtonClick{
    isPopFromSearchPhoto=YES;
    [[self navigationController] popViewControllerAnimated:YES];
}



@end
