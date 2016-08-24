//
//  RightMenuViewController.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/7.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CLLocationManager *locationManager;
    MKMapView *usermap;
    UIButton *_locationButton;
    CLLocation *_currentLocation;
    NSMutableArray *_annotations;
}


@end
