//
//  cardPost.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-4.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface cardPost : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSData *received;
@property (nonatomic,strong) NSString* result;

-(void)PostCardInfo:(NSString *)urlPath :(NSString *)cid;

@end
