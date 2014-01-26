//
//  WebserviceController.h
//  photoshare
//
//  Created by Dhiru on 26/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebserviceDelegate <NSObject>

@required
-(void) webserviceCallback: (NSString *)data;

@end

@interface WebserviceController : NSObject <NSURLConnectionDelegate>
{
    id<WebserviceDelegate> delegate;
}

@property (nonatomic,strong) id<WebserviceDelegate> delegate;
-(void) call:(NSString *)postData controller:(NSString *)controller method:(NSString *)method ;

@end
