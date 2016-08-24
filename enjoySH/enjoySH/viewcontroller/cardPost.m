//
//  cardPost.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-4.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "cardPost.h"

@implementation cardPost

-(void)PostCardInfo:(NSString *)urlPath :(NSString *)cid{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSMutableData * body=[NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"cid=%@",cid] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    _received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    _result = [[NSString alloc]initWithData:_received encoding:NSUTF8StringEncoding];
}

@end
