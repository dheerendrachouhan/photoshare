//
//  ContentManager.m
//  schudio
//
//  Created by ignis3 on 16/01/14.
//  Copyright (c) 2014 ignis2. All rights reserved.
//

#import "ContentManager.h"

@implementation ContentManager
@synthesize loginDetailsDict;

static ContentManager *objContantManager = nil;

+(ContentManager *)sharedManager {
    if(objContantManager == Nil) {
        objContantManager = [[ContentManager alloc] init];
    }
    return objContantManager;
}


-(void)storeData:(id)storeObj:(NSString *)storeKey{
    
    
    @try {
        NSUserDefaults *defaultData = [NSUserDefaults standardUserDefaults];
        [defaultData removeObjectForKey:storeKey];
        [defaultData setObject:storeObj forKey:storeKey];
        
        [defaultData synchronize];
        NSLog(@"school info %@",[defaultData objectForKey:storeKey]);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}

-(id)getData:(NSString *)getKey{
    id getData = nil;
     getData = [[NSUserDefaults standardUserDefaults] objectForKey:getKey];
    return getData;
}

-(void)showAlert:(NSString *)alrttittle:(NSString *)msg:(NSString *)btnTittle:(NSString *)otherBtn{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alrttittle message:msg delegate:nil cancelButtonTitle:btnTittle otherButtonTitles:otherBtn, nil];
    [alert show];
}

@end
