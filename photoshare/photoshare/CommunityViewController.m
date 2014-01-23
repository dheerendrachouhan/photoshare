//
//  CommunityViewController.m
//  photoshare
//
//  Created by Dhiru on 22/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "CommunityViewController.h"

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
    // Do any additional setup after loading the view from its nib.
    UINib *nib=[UINib nibWithNibName:@"CommunityCollectionCell" bundle:[NSBundle mainBundle]];
    [collectionview registerNib:nib forCellWithReuseIdentifier:@"CVCell"];
}
-(IBAction)backToView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    
    if([indexPath row]==2)
    {
        UIImageView *folderIdentfierImage=(UIImageView *)[cell viewWithTag:102];
        folderIdentfierImage.hidden=YES;
    }
    UILabel *folderNamelbl=(UILabel *)[cell viewWithTag:103];
    folderNamelbl.text=@"myFolder";
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
