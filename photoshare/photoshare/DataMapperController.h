//
//  DataMapperController.h
//  photoshare
//
//  Created by Dhiru on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"

#define NavBtnYPosForiPhone 45.0f
#define NavBtnYPosForiPad 105.0f
#define NavBtnHeightForiPhone 30
#define NavBtnHeightForiPad 50

#define IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height==568)
#define IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height==480)
#define IS_OS_5_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
#define IS_OS_6_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@interface DataMapperController : UIViewController
{
    ContentManager *objManager;
}

-(void) setUserId:(NSString *)userid ;
-(void) setUserDetails:(NSDictionary *) dic;
-(void) setUserName:(NSString *)username;
-(void) setRememberMe:(NSString *)value;
-(void) setRememberFields:(NSDictionary *)dict;
-(void) sethomeIndex;
-(BOOL) gethomeIndex;
-(void) resetHomeIndex;
-(void)setCollectionDataList :(NSMutableArray *)collectionArray;
-(void)removeAllData;

-(NSMutableArray *)getCollectionDataList;

-(NSString * ) getUserId ;
-(NSDictionary *) getUserDetails ;
-(NSString *)getUserName;
-(NSString *)getRemeberMe;
-(NSDictionary *)getRememberFields;

@end
