//
//  XmlDataParser.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-17.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "XmlDataParser.h"

@implementation XmlDataParser

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _dataArray = [[NSMutableArray alloc]init];
    _dict = [[NSMutableDictionary alloc]init];
    _dataTmp = [[NSMutableString alloc]init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"client"]) {
        [_dict removeAllObjects];
    }
    else
    {
        [_dataTmp setString:@""];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"client"]) {
        [_dataArray addObject:[NSDictionary dictionaryWithDictionary:_dict]];
    }
    else
    {
        [_dict setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return;
    }
    [_dataTmp appendString:string];
}

-(void)StartParse:(NSString *)urlPath{
    NSXMLParser *parser;
    NSString *encodedUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlPath, NULL, NULL, kCFStringEncodingUTF8));
    NSURL *fileUrl = [NSURL URLWithString:encodedUrl];
    NSData *webData = [NSData dataWithContentsOfURL:fileUrl];
    parser = [[NSXMLParser alloc]initWithData:webData];
    parser.delegate = self;
    [parser parse];
}

@end
