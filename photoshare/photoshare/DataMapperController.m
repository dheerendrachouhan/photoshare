//
//  DataMapperController.m
//  photoshare
//
//  Created by Dhiru on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "DataMapperController.h"
#import "ContentManager.h"
@interface DataMapperController ()

@end

@implementation DataMapperController

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
	// Do any additional setup after loading the view.
   
   
    

}

-(id)init
{
     objManager=[ContentManager sharedManager];
   
    return self;
}

-(void) setUserId:(NSString *)userid
{
  
  [objManager storeData:userid :@"user_id"];
    
}

-(void) setUserName:(NSString *)username
{
    [objManager storeData:username :@"user_username"];
}

-(void) setUserDetails:(NSDictionary *) dic
{
    [objManager storeData:dic :@"user_details"];

}

-(NSString *) getUserId
{
    NSString  *userid = [objManager getData:@"user_id"];
    return userid;
}

-(NSDictionary *) getUserDetails
{

    NSDictionary *user_details = [objManager getData:@"user_details"];
    return user_details;
}

-(NSString *)getUserName
{
    NSString *username = [objManager getData:@"user_username"];
    return username;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
