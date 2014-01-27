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
    self.title=@"Community folders";
   
    //set data for Collection view
    [self setDataForCollectionView];
    
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
    
    
     [collectionview reloadData];
       
}

-(void)setDataForCollectionView
{
    ContentManager *contentManagerObj=[ContentManager sharedManager];
    folderNameArray=[[NSMutableArray alloc] init];
    if([contentManagerObj getData:@"FolderArray"]==Nil)
    {
        [contentManagerObj storeData:folderNameArray :@"FolderArray"];
    }
    folderNameArray =[contentManagerObj getData:@"FolderArray"];
    
    /*for (int i=0; i<40; i++) {
        [folderNameArray addObject:[@"BirthDay" stringByAppendingString:[NSString stringWithFormat:@"%i",i]]];
    }*/
    float no=[folderNameArray count]/12;
    float nomodules=[folderNameArray count]%12;
    if(nomodules!=0)
    {
        noOfPagesInCollectionView=no+1;
    }
    else
    {
        noOfPagesInCollectionView=no;
    }
    if([folderNameArray count]==0)
    {
        noOfPagesInCollectionView=1;
    }
    NSLog(@"%d",noOfPagesInCollectionView);
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
    [self setDataForCollectionView];
  [collectionview reloadData];
    //set title for navigation controller
    self.title=@"Community folders";
    blueLabelImgFrame=diskSpaceBlueLabel.frame;
    [self setTheDiskSpace];
}
-(void)setTheDiskSpace
{
    //set up the diskspace progress
    NSInteger spacePerCentage=50;
    NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%li%@)",(long)spacePerCentage,@"%"];
    diskSpaceTitle.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    diskSpaceTitle.text=diskTitle;
    float x=blueLabelImgFrame.origin.x;
    float y=blueLabelImgFrame.origin.y;
    float height=blueLabelImgFrame.size.height;
    UILabel *diskSpaceLabel=[[UILabel alloc] initWithFrame:CGRectMake(x, y,2.8*spacePerCentage, height)];
    diskSpaceLabel.backgroundColor=[UIColor colorWithRed:0.004 green:0.478 blue:1 alpha:1];
    [diskSpaceBlueLabel removeFromSuperview];
    [self.view addSubview:diskSpaceLabel];
}

//collection view delegate method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return [folderNameArray count]+noOfPagesInCollectionView;
    return [folderNameArray count]+noOfPagesInCollectionView;
}
-(CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CVCell";
    obj_Cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    obj_Cell.folder_imgV.hidden=NO;
    obj_Cell.folder_name.text = [NSString stringWithFormat:@"Folder %d",(int)[indexPath row]];
    if(([indexPath row]+1)%12==0 || ([indexPath row]+1)==[folderNameArray count]+noOfPagesInCollectionView)
    {
        obj_Cell.folder_imgV.image=[UIImage imageNamed:@"add_folder.png"];
        obj_Cell.icon_img.hidden=YES;
        obj_Cell.folder_name.text=@"Add Folder";
        [self check];
    }
    else
    {
        obj_Cell.folder_imgV.image=[UIImage imageNamed:@"folder-icon.png"];
        obj_Cell.icon_img.hidden=NO;
        obj_Cell.folder_name.text=[folderNameArray objectAtIndex:([indexPath row]-indexPath.row/12)];
        
    }
    return obj_Cell;
}
//tap gesture method
-(void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
        
        if(([indexPath row]+1)%12==0 || ([indexPath row]+1)==[folderNameArray count]+noOfPagesInCollectionView)
        {
            [self addFolder];
            NSLog(@"Add Folder selected index is %ld",(long)[indexPath row]);
        }
        else
        {
            PhotoGalleryViewController *photoGallery=[[PhotoGalleryViewController alloc] initWithNibName:@"PhotoGalleryViewController" bundle:[NSBundle mainBundle]];
            photoGallery.isPublicFolder=NO;
            photoGallery.selectedFolderIndex=([indexPath row]-indexPath.row/12);
            [self.navigationController pushViewController:photoGallery animated:YES];
            photoGallery.navigationController.navigationBar.frame=CGRectMake(0, 0, 320, 90);

        }
        
    }
}
//longPress Gesture
-(void)longPressHandle:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:collectionview];
    
    NSIndexPath *indexPath = [collectionview indexPathForItemAtPoint:p];
    if (indexPath != nil){
       
        if(([indexPath row]+1)%12!=0 && ([indexPath row]+1)!=[folderNameArray count]+noOfPagesInCollectionView)
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
    aec.folderIndex=([indexPath row]-indexPath.row/12);
    
    CommunityViewController *cm = [[CommunityViewController alloc] init];
    HomeViewController *hm = [[HomeViewController alloc] init] ;
    [self.navigationController setViewControllers:[[NSArray alloc] initWithObjects:hm,cm,aec, nil]];
  
    [self.navigationController pushViewController:aec animated:NO];
    
}

-(void)check
{
    NSArray *arr=[collectionview visibleCells];
    UICollectionViewCell *cell=(UICollectionViewCell *)[arr lastObject];
    NSIndexPath *indexPath = [collectionview indexPathForCell:cell];
    
    NSLog(@"Visible cell %ld",[arr count]);
    
}

/*-(void)check{
 
     NSArray *arrV = [collectionview indexPathsForVisibleItems];
    NSIndexPath *last_index = [arrV firstObject];
    NSLog(@"roow-- %d %@",(int)[last_index row],arrV);
    
    UICollectionViewCell *cell_obj = [collectionview cellForItemAtIndexPath:last_index];
    cell_obj.backgroundColor = [UIColor greenColor];
    
}*/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //[self performSelector:@selector(check) withObject:self afterDelay:5.0f];
    
    //[arr removeAllObjects];
   
//    for (CollectionViewCell *cell in [collectionview visibleCells]) {
//        NSIndexPath *indexPath = [collectionview indexPathForCell:cell];
//        NSLog(@"%d",(int)indexPath.row);
//        [arr addObject:indexPath];
//    }
//    
//    NSIndexPath *last_index = [arr lastObject];
//    UICollectionViewCell *cell_obj = [collectionview cellForItemAtIndexPath:last_index];
//    cell_obj.hidden = YES;
}

//-(void)test:(NSArray *)indexArr {
//    NSIndexPath *last_index = [indexArr lastObject];
//    CollectionViewCell *cell_obj = [collectionview cellForItemAtIndexPath:last_index];
//    cell_obj.hidden = YES;
//}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
