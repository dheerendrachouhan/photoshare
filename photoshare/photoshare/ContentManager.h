//
//  ContentManager.h
//  schudio
//
//  Created by ignis3 on 16/01/14.
//  Copyright (c) 2014 ignis2. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentManager:NSObject{

}
@property (nonatomic, strong) NSMutableDictionary *loginDetailsDict;

+(ContentManager *)sharedManager;

-(void)storeData:(id)storedObj:(NSString *)storeKey;
-(id)getData:(NSString *)getKey;
-(void)showAlert:(NSString *)alrttittle:(NSString *)msg:(NSString *)btnTittle:(NSString *)otherBtn;

@end
