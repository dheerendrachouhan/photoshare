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
