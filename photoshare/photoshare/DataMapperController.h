//
//  DataMapperController.h
//  photoshare
//
//  Created by Dhiru on 29/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentManager.h"

@interface DataMapperController : UIViewController
{
    ContentManager *objManager;
}

-(void) setUserId:(NSString *)userid ;
-(void) setUserDetails:(NSDictionary *) dic;
-(void) setUserName:(NSString *)username;
-(NSString * ) getUserId ;
-(NSDictionary *) getUserDetails ;
-(NSString *)getUserName;
@end
