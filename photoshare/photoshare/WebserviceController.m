//
//  WebserviceController.m
//  photoshare
//
//  Created by Dhiru on 26/01/14.
//  Copyright (c) 2014 ignis. All rights reserved.
//

#import "WebserviceController.h"

@interface WebserviceController ()

@end

@implementation WebserviceController

@synthesize delegate;

-(void) call:(NSString *)postData controller:(NSString *)controller method:(NSString *)method
{
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://localserver/api/index.php/%@/%@",controller,method ]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    
    NSString *postString = postData ; //@"username=user&password=user";
    NSData *requestData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: requestData];
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    
    [connection start];

}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Error : %@",[error localizedDescription]);
}

-(void) connection: (NSURLConnection *) connection didReceiveData:(NSData *)data
{
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    
  // NSLog(@"Result : %@",output);
  
    [self.delegate webserviceCallback:output];
   

}


@end
