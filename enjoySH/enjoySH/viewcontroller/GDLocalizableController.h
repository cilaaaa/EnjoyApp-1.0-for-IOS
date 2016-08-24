//
//  GDLocalizableController.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/3/31.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define GDLocalizedString(key) [[GDLocalizableController bundle] localizedStringForKey:(key) value:@"" table:nil]

@interface GDLocalizableController : NSObject

+(NSBundle *)bundle;//获取当前资源文件

+(void)initUserLanguage;//初始化语言文件

+(NSString *)userLanguage;//获取应用当前语言

+(void)setUserlanguage:(NSString *)language;//设置当前语言

@end
