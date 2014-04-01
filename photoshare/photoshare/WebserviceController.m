
//
//  WebserviceController.m
//  photoshare
//
//  Created by Dhiru on 26/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "WebserviceController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFURLSessionManager.h"

@interface WebserviceController ()
{
    BOOL isGetPhoto;
}
@end

@implementation WebserviceController

@synthesize delegate;

-(id)init
{
    manager = [AFHTTPRequestOperationManager manager];
    apiUrl=@"api.123friday.com/v/1";
    return self;
}
-(void) call:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method
{
    NSDictionary *parameters = postData;
   if([controller isEqualToString:@"photo"] && [method isEqualToString:@"get"])
    {
        isGetPhoto=YES;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
        [manager setResponseSerializer:[AFImageResponseSerializer new]];
    }
    [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,controller,method ] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if( [responseObject isKindOfClass:[UIImage class]] )
        {
            isGetPhoto=NO;
            [self.delegate webserviceCallbackImage:responseObject];
        }
        else
        {
        NSDictionary *JSON = (NSDictionary *) responseObject;
        [self.delegate webserviceCallback:JSON];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Photo Error: %@", [error localizedDescription]);
        if(isGetPhoto)
        {
            UIImage *img=NULL;
             isGetPhoto=NO;
             [self.delegate webserviceCallbackImage:img];
        }
        else
        {
            [self.delegate webserviceCallback:[NSDictionary dictionaryWithObject:@0 forKey:@"exit_code"]];
        }
    }];
}

//save image
-(void)saveFileData:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method filePath:(NSData *)imageData{
    
   NSDictionary *parameters = postData;
    [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,controller,method ] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:imageData name:@"file" fileName:@"photo.png" mimeType:@"image/png"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary *JSON = (NSDictionary *) responseObject;
        [self.delegate webserviceCallback:JSON];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self.delegate webserviceCallback:[NSDictionary dictionaryWithObject:@0 forKey:@"exit_code"]];
            }];
}
@end
