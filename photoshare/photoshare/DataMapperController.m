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

-(void) setRememberMe:(NSString *)value
{
    [objManager storeData:value :@"user_remember"];
}

-(void) setRememberFields:(NSDictionary *)dict
{
    [objManager storeData:dict :@"user_loginFields"];
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

-(NSString *)getRemeberMe
{
    NSString *remeber = [objManager getData:@"user_remember"];
    return remeber;
}

-(NSDictionary *)getRememberFields
{
    NSDictionary *dictionary = [objManager getData:@"user_loginFields"];
    return dictionary;
}


-(void) sethomeIndex
{
    NSString *str= @"TRUE";
    [objManager storeData:str :@"setHomeIndex"];
}
-(BOOL) gethomeIndex
{
    NSString *str = [objManager getData:@"setHomeIndex"];
    return (BOOL)str;
}
-(void) resetHomeIndex
{
    NSString *str= @"FALSE";
    [objManager storeData:str :@"setHomeIndex"];
}
//store the collection data list
-(void)setCollectionDataList :(NSMutableArray *)collectionArray
{
    [objManager storeData:collectionArray :@"collection_data_list"];
}
-(NSMutableArray *)getCollectionDataList
{
    return [[objManager getData:@"collection_data_list"] mutableCopy];
}


//remove all the data on Logout from nsuser default except Remember fields
-(void)removeAllData
{
    NSString *rememberMe=[self getRemeberMe];
    NSDictionary *remeberFeild=[self getRememberFields];
    //remove all of the data from nsuser default
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    [self setRememberMe:rememberMe];
    [self setRememberFields:remeberFeild];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
