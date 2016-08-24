//
//  voucherValid.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-5-4.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface voucherValid : NSObject<NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableDictionary *dict;
@property (strong,nonatomic) NSMutableString *dataTmp;

-(void)StartParse:(NSString *)urlPath :(NSString *)cid :(NSString *)vid :(NSString *)uid;

@end
