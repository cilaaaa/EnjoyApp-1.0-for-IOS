//
//  XmlArea.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-23.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XmlArea : NSObject<NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableArray *dataArray;
@property (strong,nonatomic) NSMutableDictionary *dict;
@property (strong,nonatomic) NSMutableString *dataTmp;

-(void)StartParse:(NSString *)urlPath;

@end
