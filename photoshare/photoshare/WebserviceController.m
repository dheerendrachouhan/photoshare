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

@end

@implementation WebserviceController

@synthesize delegate;

-(id)init
{
    
    manager = [AFHTTPRequestOperationManager manager];
    
    return self;
}


-(void) call:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method
{
    

    
    NSDictionary *parameters = postData;
  
    if([controller isEqualToString:@"photo"] && [method isEqualToString:@"get"])
    {
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"image/png"];
        [manager setResponseSerializer:[AFImageResponseSerializer new]];
    }
    //www.burningwindmill.com
    [manager POST:[NSString stringWithFormat:@"http://54.194.160.22/api/index.php/%@/%@",controller,method ] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
       if( [responseObject isKindOfClass:[UIImage class]] )
       {
           NSLog(@"check ") ;
          
            [self.delegate webserviceCallbackImage:responseObject];
       }
        else
        {
        
        NSDictionary *JSON = (NSDictionary *) responseObject;
     
        
        [self.delegate webserviceCallback:JSON];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];


}




-(void)saveFileData:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method filePath:(NSData *)imageData{
    
    
    //manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = postData;
    
  /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"123-mobile-logo.png" ];
    
    NSURL *filePath = [NSURL fileURLWithPath:path];
    */
    
    //NSError* error = nil ;54.194.160.22
   [manager POST:[NSString stringWithFormat:@"http://54.194.160.22/api/index.php/%@/%@",controller,method] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFileURL:filePath name:@"file" error: nil];
         [formData appendPartWithFileData:imageData name:@"file" fileName:@"photo.png" mimeType:@"image/png"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary *JSON = (NSDictionary *) responseObject;
        [self.delegate webserviceCallback:JSON];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self.delegate webserviceCallback:[NSDictionary dictionaryWithObject:@0 forKey:@"exit_code"]];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Photo saving Failed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];

    }];
}

@end
