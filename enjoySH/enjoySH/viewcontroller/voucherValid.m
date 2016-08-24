//
//  voucherValid.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-4.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "voucherValid.h"

@implementation voucherValid

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _dict = [[NSMutableDictionary alloc]init];
    _dataTmp = [[NSMutableString alloc]init];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    [_dict setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return;
    }
    [_dataTmp appendString:string];
}

-(void)StartParse:(NSString *)urlPath :(NSString *)cid :(NSString *)vid :(NSString *)uid{
    NSXMLParser *parser;
    urlPath = [urlPath stringByAppendingString:[NSString stringWithFormat:@"cid=%@&vid=%@&uid=%@",cid,vid,uid]];
    NSURL *fileUrl = [NSURL URLWithString:urlPath];
    NSData *webData = [NSData dataWithContentsOfURL:fileUrl];
    parser = [[NSXMLParser alloc]initWithData:webData];
    parser.delegate = self;
    [parser parse];
}

@end
