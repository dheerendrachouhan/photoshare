//
//  CommunityViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "CommunityViewController.h"
#import "CommonTopView.h"
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
    
    CommonTopView *topView=[[CommonTopView alloc] init];
    [self.view addSubview:topView];
    // Do any additional setup after loading the view from its nib.
    UINib *nib=[UINib nibWithNibName:@"CommunityCollectionCell" bundle:[NSBundle mainBundle]];
    
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
    NSInteger spacePerCentage=50;
    NSString *diskTitle=[NSString stringWithFormat:@"Disk spaced used (%li%@)",(long)spacePerCentage,@"%"];
    diskSpaceTitle.textColor=[UIColor colorWithRed:0.412 green:0.667 blue:0.839 alpha:1];
    diskSpaceTitle.text=diskTitle;
    float x=diskSpaceBlueLabel.frame.origin.x;
    float y=diskSpaceBlueLabel.frame.origin.y;
    float height=diskSpaceBlueLabel.frame.size.height;
    UILabel *diskSpaceLabel=[[UILabel alloc] initWithFrame:CGRectMake(x, y,2.8*spacePerCentage, height)];
    diskSpaceLabel.backgroundColor=[UIColor colorWithRed:0.004 green:0.478 blue:1 alpha:1];
    [diskSpaceBlueLabel removeFromSuperview];
    [self.view addSubview:diskSpaceLabel];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [collectionview reloadData];
    
}
-(IBAction)backToView:(id)sender
{
    [self.tabBarController setSelectedIndex:0];
}
//collection view delegate method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 45;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"CVCell";
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
     NSLog(@"random Index %ld",(long)[indexPath row]);
    /*if([indexPath row]==11)
    {
        UIImageView *folderIdentfierImage=(UIImageView *)[cell viewWithTag:102];
        folderIdentfierImage.hidden=YES;
    }*/
    UILabel *folderNamelbl=(UILabel *)[cell viewWithTag:103];
    folderNamelbl.text=@"myFolder";
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected index is %ld",(long)[indexPath row]);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
