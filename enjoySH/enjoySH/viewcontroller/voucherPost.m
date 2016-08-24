//
//  voucherPost.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-4.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "voucherPost.h"

@implementation voucherPost

-(void)PostVoucherInfo:(NSString *)urlPath :(NSString *)cid :(NSString *)vid{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSMutableData * body=[NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"cid=%@&vid=%@",cid,vid] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    NSLog(@"%@",[[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies] objectAtIndex:1]);
    _received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    _result = [[NSString alloc]initWithData:_received encoding:NSUTF8StringEncoding];
}

@end
