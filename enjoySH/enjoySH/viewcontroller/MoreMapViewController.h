//
//  MoreMapViewController.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/6/2.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MoreMapViewController : UIViewController<MKMapViewDelegate>
{
    MKMapView *usermap;
}

@property (assign,nonatomic) double lng;
@property (assign,nonatomic) double lat;
@property (assign,nonatomic) NSString *SHtitle;
@property (assign,nonatomic) NSString *excerpt;

@end
