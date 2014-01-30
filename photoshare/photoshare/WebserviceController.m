//
//  WebserviceController.m
//  photoshare
//
//  Created by Dhiru on 26/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "WebserviceController.h"
#import "AFHTTPRequestOperationManager.h"

@interface WebserviceController ()

@end

@implementation WebserviceController

@synthesize delegate;

-(void) call:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method
{
    
   
    
    manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *parameters = postData;
  
    

    [manager POST:[NSString stringWithFormat:@"http://www.burningwindmill.com/api/index.php/%@/%@",controller,method ] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *JSON = (NSDictionary *) responseObject;
     
        [self.delegate webserviceCallback:JSON];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];


}


-(void)saveFileData:(NSDictionary *)postData controller:(NSString *)controller method:(NSString *)method filePath:(NSURL *)filePath{
    
    
    manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = postData;
    
  /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:
                      @"123-mobile-logo.png" ];
    
    NSURL *filePath = [NSURL fileURLWithPath:path];
    */
    
    
    [manager POST:[NSString stringWithFormat:@"http://www.burningwindmill.com/api/index.php/%@/%@",controller,method ] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:@"file" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        NSDictionary *JSON = (NSDictionary *) responseObject;
        [self.delegate webserviceCallback:JSON];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }];

}

@end
