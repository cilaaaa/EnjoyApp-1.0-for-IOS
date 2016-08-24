//
//  CommentPost.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-7.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentPost : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSData *received;
@property (nonatomic,strong) NSString* result;

-(void)Comment:(NSString *)urlPath :(NSString *)comment :(NSString *)lid :(NSString *)uid :(NSString *)cid :(NSString *)avgPrice;


@end
