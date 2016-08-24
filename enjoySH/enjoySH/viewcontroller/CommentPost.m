//
//  CommentPost.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-7.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "CommentPost.h"

@implementation CommentPost

-(void)Comment:(NSString *)urlPath :(NSString *)comment :(NSString *)lid :(NSString *)uid :(NSString *)cid :(NSString *)avgPrice{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSMutableData * body=[NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"lid=%@&cid=%@&uid=%@&c=%@&avgPrice=%@",lid,cid,uid,comment,avgPrice] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    _received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    _result = [[NSString alloc]initWithData:_received encoding:NSUTF8StringEncoding];
}

@end
