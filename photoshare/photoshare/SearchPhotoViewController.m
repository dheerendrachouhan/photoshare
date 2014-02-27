//
//  SearchPhotoViewController.m
//  photoshare
//
//  Created by ignis2 on 13/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "SearchPhotoViewController.h"
#import "SVProgressHUD.h"

@interface SearchPhotoViewController ()

@end

@implementation SearchPhotoViewController

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
    
    //set the search bar become first responder
    [searchBarForPhoto becomeFirstResponder];
    
    
    manager =[ContentManager sharedManager];
    webservice =[[WebserviceController alloc] init];
    userid=[manager getData:@"user_id"];
    
    searchResultArray = [[NSArray alloc] init];
    photoArray =[[NSMutableArray alloc] init];
    photDetailArray =[[NSMutableArray alloc] init];
    
    //register collection view class
    [collectionViewForPhoto registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CVCell"];
    
    //add tap Gesture on Collection View
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [collectionViewForPhoto addGestureRecognizer:tapGesture];
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addCustomNavigationBar];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    isPopFromSearchPhoto=YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self addCustomNavigationBar];
}

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
-(void)searchPhotoOnServer
{
    isSearchPhoto=YES;
    webservice=[[WebserviceController alloc] init];
    webservice.delegate=self;
    NSDictionary *dicData=@{@"user_id":userid,@"search_term":searchString};
    [webservice call:dicData controller:@"photo" method:@"search"];
}
//call back method of webservice
-(void)webserviceCallback:(NSDictionary *)data
{
    NSLog(@"Call bAck Data %@",data);

    if(isSearchPhoto)
    {
        [photDetailArray removeAllObjects];
        [photoArray removeAllObjects];
    
        searchResultArray=[data objectForKey:@"output_data"];
        for (int i=0; i<searchResultArray.count; i++) {
            
            NSNumber *colId=[[searchResultArray objectAtIndex:i] objectForKey:@"photo_collection_id"];
            
            @try {
                NSLog(@"col is **%d",colId.integerValue);
                    [photDetailArray addObject:[searchResultArray objectAtIndex:i]];
                
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
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
    @finally {
        
    }
}
-(void)webserviceCallbackImage:(UIImage *)image
{
    //dismiss the progress bar
     [SVProgressHUD dismiss];
    if(isGetPhotoFromServer)
    {

        [photoArray addObject:image];
        photoCount++;
        int count=photoArray.count;
        NSLog(@"Photo Array Count is : %d",count);
        UIImageView *imgView=(UIImageView *)[collectionViewForPhoto viewWithTag:100+count];
        UIActivityIndicatorView *indicator=(UIActivityIndicatorView *)[collectionViewForPhoto viewWithTag:1100+count];
        [indicator removeFromSuperview];
        imgView.backgroundColor=[UIColor clearColor];
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
    else if(isGetOriginalPhotoFromServer)
    {
       
        //UIImageView for view the large image (imgView1)
        imgView1=[[UIImageView alloc] initWithFrame:self.view.frame];
        imgView1.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imgView1.contentMode=UIViewContentModeScaleAspectFit;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImgView:)];
        tap.numberOfTapsRequired=2;
        imgView1.backgroundColor=[UIColor blackColor];
        imgView1.userInteractionEnabled=YES;
        imgView1.layer.masksToBounds=YES;
        [imgView1 addGestureRecognizer:tap];
        
        imgView1.image=image;
        isViewLargeImageMode=YES;
        self.tabBarController.tabBar.hidden=YES;
        [self.view addSubview:imgView1];
        isGetOriginalPhotoFromServer=NO;
    }
}
-(void)removeImgView :(UITapGestureRecognizer *)gesture
{
    [imgView1 removeFromSuperview];
    isViewLargeImageMode=NO;
    self.tabBarController.tabBar.hidden=NO;
}
//collection view method
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
    @finally {
        
    }
    
    [cell.contentView addSubview:imgView];
    [cell.contentView addSubview:photoTitleLbl];

    return cell;
}


-(void)tapHandle :(UITapGestureRecognizer *)gesture
{
    [searchBarForPhoto resignFirstResponder];
    CGPoint p = [gesture locationInView:collectionViewForPhoto];
    
    NSIndexPath *indexPath = [collectionViewForPhoto indexPathForItemAtPoint:p];
    if(indexPath!=Nil)
    {
        if(photoArray.count!=photDetailArray.count)
        {
            [manager showAlert:@"Message" msg:@"Photo is Loading" cancelBtnTitle:@"Ok" otherBtn:Nil];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
            isGetOriginalPhotoFromServer=YES;
            NSString *resize=@"320";
            if ([manager isiPad])
            {
                resize=@"768";
            }
            [self getPhotoFromServer:indexPath.row imageResize:resize];
        }
    }
}

//add custom navigation bar
-(void)addCustomNavigationBar
{
    self.navigationController.navigationBarHidden = TRUE;
    
    NavigationBar *navnBar = [[NavigationBar alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(navBackButtonClick)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"< Back" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 47.0, 70.0, 30.0);
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    // button.backgroundColor = [UIColor redColor];
    
    UILabel *titleLabel = [[UILabel alloc] init ];
    titleLabel.text=@"Search Photos";
    titleLabel.textAlignment=NSTextAlignmentCenter;
    
    if([manager isiPad])
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
        }
        else
        {
            [navnBar loadNav:CGRectNull :true];
        }
        button.frame = CGRectMake(0.0, NavBtnYPosForiPad, 90.0, NavBtnHeightForiPad);
        button.titleLabel.font = [UIFont systemFontOfSize:23.0f];
        
        titleLabel.frame=CGRectMake(self.view.center.x-75, NavBtnYPosForiPad, 150.0, NavBtnHeightForiPad);
        titleLabel.font =[UIFont systemFontOfSize:23.0f];
        
    }
    else
    {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
        {
            [navnBar loadNav:CGRectNull :false];
            titleLabel.frame = CGRectMake(100.0, NavBtnYPosForiPhone, 120.0, NavBtnHeightForiPhone);
        }
        else
        {
            if([[UIScreen mainScreen] bounds].size.height == 480)
            {
                [navnBar loadNav:CGRectNull :true];
                titleLabel.frame = CGRectMake(180.0, NavBtnYPosForiPhone, 120.0, NavBtnHeightForiPhone);
            }
            else if([[UIScreen mainScreen] bounds].size.height == 568)
            {
                [navnBar loadNav:CGRectNull :true];
                titleLabel.frame = CGRectMake(220.0, NavBtnYPosForiPhone, 120.0, NavBtnHeightForiPhone);
            }
        }
        button.frame = CGRectMake(0.0, NavBtnYPosForiPhone, 70.0, NavBtnHeightForiPhone);
        button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        
        
        titleLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    
    [navnBar addSubview:titleLabel];
    [navnBar addSubview:button];
    if(!isViewLargeImageMode)
    {
        [[self view] addSubview:navnBar];
    }
    
    [navnBar setTheTotalEarning:manager.weeklyearningStr];
}
-(void)navBackButtonClick{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
