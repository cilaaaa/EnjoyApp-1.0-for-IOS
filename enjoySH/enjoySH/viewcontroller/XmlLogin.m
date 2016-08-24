//
//  XmlLogin.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-20.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "XmlLogin.h"

@implementation XmlLogin

-(void)Login:(NSString *)urlPath :(NSString *)username :(NSString *)password{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSMutableData * body=[NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"uid=%@&psw=%@",username,password] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    _received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    _result = [[NSString alloc]initWithData:_received encoding:NSUTF8StringEncoding];
}

@end
