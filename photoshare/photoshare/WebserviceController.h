//
//  WebserviceController.h
//  photoshare
//
//  Created by Dhiru on 26/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

@protocol WebserviceDelegate <NSObject>

@required
-(void) webserviceCallback: (NSDictionary *)data;

@end

@interface WebserviceController : NSObject <NSURLConnectionDelegate>
{
    id<WebserviceDelegate> delegate;
    AFHTTPRequestOperationManager *manager ;
}

@property (nonatomic,strong) id<WebserviceDelegate> delegate;
-(void) call:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method ;
-(void)saveFileData:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method filePath:(NSURL *)filePath;
@end
