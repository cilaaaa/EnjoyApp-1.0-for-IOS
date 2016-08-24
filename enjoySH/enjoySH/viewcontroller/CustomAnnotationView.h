//
//  CustomAnnotationView.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-22.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CustomCalloutView.h"
#import "KCAnnotation.h"

@interface CustomAnnotationView : MKAnnotationView

@property (nonatomic, readonly) CustomCalloutView *calloutView;
@property (nonatomic , strong ) KCAnnotation *anno;

@end
