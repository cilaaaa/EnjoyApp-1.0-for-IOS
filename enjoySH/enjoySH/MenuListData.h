//
//  MenuListData.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/5/10.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuListData : NSObject<NSXMLParserDelegate>

@property (strong,nonatomic) NSMutableArray *dataArray;
@property (strong,nonatomic) NSMutableDictionary *dict;
@property (strong,nonatomic) NSMutableString *dataTmp;

-(void)StartParse:(NSString *)urlPath;

@end
