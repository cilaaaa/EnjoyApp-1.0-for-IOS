//
//  RatePost.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/5/10.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RatePost : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSData *received;
@property (nonatomic,strong) NSString* result;


-(void)Rate:(NSString *)urlPath :(NSInteger)food :(NSInteger)entertain :(NSInteger)service :(NSInteger)valueV :(NSString *)lid :(NSString *)cid :(NSString *)uid;

@end
