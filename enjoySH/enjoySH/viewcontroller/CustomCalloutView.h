//
//  CustomCalloutView.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-22.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCalloutView : UIView

@property (nonatomic, assign) double lng;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) int BtnTag;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


@end
