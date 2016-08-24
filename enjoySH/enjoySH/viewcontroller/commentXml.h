//
//  commentXml.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-21.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface commentXml : NSObject<NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableArray *dataArray;
@property (strong,nonatomic) NSMutableArray *dataArray2;
@property (strong,nonatomic) NSMutableDictionary *dict;
@property (strong,nonatomic) NSMutableString *dataTmp;
@property (strong,nonatomic) NSMutableDictionary *dict2;
@property (strong,nonatomic) NSMutableDictionary *dict3;
@property (strong,nonatomic) NSMutableDictionary *dict4;

-(void)StartParse:(NSString *)urlPath;

@end
