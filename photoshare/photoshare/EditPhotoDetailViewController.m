//
//  EditPhotoDetailViewController.m
//  photoshare
//
//  Created by ignis2 on 06/02/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "EditPhotoDetailViewController.h"
#import "NavigationBar.h"
@interface EditPhotoDetailViewController ()

@end

@implementation EditPhotoDetailViewController
@synthesize photoDetail,photoId,collectionId;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self addCustomNavigationBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //initialize the WebService Object
    webservices=[[WebserviceController alloc] init];
    manager=[ContentManager sharedManager];
    
    userid =[manager getData:@"user_id"];
    
    //set text fielddelegate
    [photoTitletxt setDelegate:self];
    [photoTagTxt setDelegate:self];
    [photoLocationTxt setDelegate:self];
    [photoDescriptionTxt setDelegate:self];
    
    
    photoTitletxt.text=[photoDetail objectForKey:@"collection_photo_title"];
    photoDescriptionTxt.text=[photoDetail objectForKey:@"collection_photo_description"];
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
-(void)savePhotoDetailOnServer
{
    isPhotoDetailSaveOnServer=YES;
     NSDictionary *dicData=@{@"user_id":userid,@"photo_id":self.photoId,@"photo_title":photoTitletxt.text,@"photo_description":photoDescriptionTxt.text,@"photo_location":@"",@"photo_tags":photoTagTxt.text,@"photo_collections":self.collectionId};
    
    //NSDictionary *dicData=@{@"user_id":@"11",@"photo_id":@"412"};
    //NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    //[dic setObject:@"" forKey:@"user"];
   // [dic setObject:@"" forKey:@"photo"];
    
    //webservices.delegate=self;
    [webservices call:dicData controller:@"photo" method:@"change"];
    
}

-(IBAction)savePhotoDetail:(id)sender
{
    [self savePhotoDetailOnServer];
    [self.navigationController popViewControllerAnimated:YES];
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
    // navnBar.backgroundColor = [UIColor redColor];
    [navnBar addSubview:button];
    [[self view] addSubview:navnBar];
    
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
