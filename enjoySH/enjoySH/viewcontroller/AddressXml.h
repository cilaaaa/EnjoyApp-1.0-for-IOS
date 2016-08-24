//
//  AddressXml.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-20.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressXml : NSObject<NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableArray *dataArray;
@property (strong,nonatomic) NSMutableDictionary *dict;
@property (strong,nonatomic) NSMutableString *dataTmp;
@property (strong,nonatomic) NSMutableDictionary *dict2;
@property (strong,nonatomic) NSMutableArray *dataArray2;


-(void)StartParse:(NSString *)urlPath;

@end
