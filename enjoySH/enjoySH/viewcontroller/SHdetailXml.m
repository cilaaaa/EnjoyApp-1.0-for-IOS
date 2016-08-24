//
//  SHdetailXml.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-20.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "SHdetailXml.h"

@implementation SHdetailXml{
    NSInteger term;
    int flag;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray2 = [[NSMutableArray alloc]init];
    _dict = [[NSMutableDictionary alloc]init];
    _dict2 = [[NSMutableDictionary alloc]init];
    _dataTmp = [[NSMutableString alloc]init];
    flag = 0;
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    if ([elementName isEqualToString:@"client"]) {
        [_dict removeAllObjects];
    }else if ([elementName isEqualToString:@"photos"]) {
        flag = 1;
    }else if ([elementName isEqualToString:@"photo"]){
        [_dict2 removeAllObjects];
    }
    else
    {
        [_dataTmp setString:@""];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    if ([elementName isEqualToString:@"client"]) {
        [_dataArray addObject:[NSDictionary dictionaryWithDictionary:_dict]];
    }else if ([elementName isEqualToString:@"term"]){
        [_dict setObject:[NSString stringWithString:_dataTmp] forKey:[NSString stringWithFormat:@"term%li",(long)term]];
         term++;
    }else if ([elementName isEqualToString:@"terms"]){
    }else if ([elementName isEqualToString:@"photos"]){
        flag = 0;
    }else if ([elementName isEqualToString:@"photo"]){
        [_dataArray2 addObject:[NSDictionary dictionaryWithDictionary:_dict2]];
    }
    else{
        if (flag == 0) {
            [_dict setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
        }else if(flag == 1){
             [_dict2 setObject:[NSString stringWithString:_dataTmp] forKey:elementName];
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
