//
//  XmlLogin.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-20.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlLogin : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic,strong) NSData *received;
@property (nonatomic,strong) NSString* result;

-(void)Login:(NSString *)urlPath :(NSString *)username :(NSString *)password;

@end
