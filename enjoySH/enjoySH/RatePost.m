//
//  RatePost.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/5/10.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "RatePost.h"

@implementation RatePost

-(void)Rate:(NSString *)urlPath :(NSInteger)food :(NSInteger)entertain :(NSInteger)service :(NSInteger)valueV :(NSString *)lid :(NSString *)cid :(NSString *)uid{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlPath] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    NSMutableData * body=[NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"food=%li&entertain=%li&service=%li&valueV=%li&lid=%@&cid=%@&uid=%@",(long)food,(long)entertain,(long)service,(long)valueV,lid,cid,uid] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    NSString *test = [NSString stringWithFormat:@"food=%li&entertain=%li&service=%li&valueV=%li&lid=%@&cid=%@&uid=%@",(long)food,(long)entertain,(long)service,(long)valueV,lid,cid,uid];
    NSLog(@"test:%@",test);
    _received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    _result = [[NSString alloc]initWithData:_received encoding:NSUTF8StringEncoding];
}

@end
