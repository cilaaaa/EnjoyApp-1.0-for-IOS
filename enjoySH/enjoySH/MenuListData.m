//
//  MenuListData.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/5/10.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "MenuListData.h"

@implementation MenuListData

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _dataArray = [[NSMutableArray alloc]init];
    _dict = [[NSMutableDictionary alloc]init];
    _dataTmp = [[NSMutableString alloc]init];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"menu"]) {
        [_dict removeAllObjects];
    }
    else
    {
        [_dataTmp setString:@""];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"menu"]) {
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
    NSURL *fileUrl = [NSURL URLWithString:urlPath];
    NSData *webData = [NSData dataWithContentsOfURL:fileUrl];
    parser = [[NSXMLParser alloc]initWithData:webData];
    parser.delegate = self;
    [parser parse];
}

@end
