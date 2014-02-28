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
    
    //apiUrl=@"www.burningwindmill.com/api/index.php";
    //apiUrl=@"api.123friday.com/index.php";
    //apiUrl=@"dev-iis.com/project/123fridaydebug/index.php";     //--
    //apiUrl=@"54.194.160.22/api/index.php";
    apiUrl=@"54.229.193.111/api/index.php";
    //apiUrl=@"54.72.11.106/api/index.php";
    //apiUrl=@"54.229.255.47/api/index.php";    //--
    
    
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
    
    [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,controller,method ] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        [self.delegate webserviceCallback:[NSDictionary dictionaryWithObject:@0 forKey:@"exit_code"]];
    }];

}

//save image
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
    //NSError* error = nil ;
   */
    
    
   [manager POST:[NSString stringWithFormat:@"http://%@/%@/%@",apiUrl,controller,method ] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //[formData appendPartWithFileURL:filePath name:@"file" error: nil];
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
