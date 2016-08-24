//
//  commentXml.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-21.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "commentXml.h"

@implementation commentXml{
    NSString *flag;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray2 = [[NSMutableArray alloc]init];
    _dict = [[NSMutableDictionary alloc]init];
    _dict2 = [[NSMutableDictionary alloc]init];
    _dict3 = [[NSMutableDictionary alloc]init];
    _dict4 = [[NSMutableDictionary alloc]init];
    _dataTmp = [[NSMutableString alloc]init];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"review"]) {
        flag = @"review";
        _dataArray2  = [[NSMutableArray alloc]init];
       // [_dataArray2 removeAllObjects];
    }
    else if ([elementName isEqualToString:@"venue"]) {
        flag = @"venue";
    }
    else if ([elementName isEqualToString:@"user"]) {
        flag = @"user";
    }
    else if ([elementName isEqualToString:@"score"]) {
        flag = @"score";
    }
    else{
        [_dataTmp setString:@""];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"review"]) {
        //
        [_dataArray addObject:_dataArray2];
        [_dataArray2 addObject:[NSDictionary dictionaryWithDictionary:_dict]];
        [_dataArray2 addObject:[NSDictionary dictionaryWithDictionary:_dict2]];
        [_dataArray2 addObject:[NSDictionary dictionaryWithDictionary:_dict3]];
        [_dataArray2 addObject:[NSDictionary dictionaryWithDictionary:_dict4]];
    }else if ([elementName isEqualToString:@"venue"]) {
        
    }else if ([elementName isEqualToString:@"user"]){
        
    }else if ([elementName isEqualToString:@"score"]){
        flag = @"review";
    }
    else
    {
        if ([flag isEqualToString:@"venue"] ) {
            [_dict2 setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
        }else if ([flag isEqualToString:@"user"]){
            [_dict3 setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
        }else if ([flag isEqualToString:@"score"]){
            [_dict4 setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
        }else{
            [_dict setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
        }
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
