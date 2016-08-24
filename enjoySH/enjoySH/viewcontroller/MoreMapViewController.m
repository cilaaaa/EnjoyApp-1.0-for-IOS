//
//  MoreMapViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/6/2.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "MoreMapViewController.h"

#import "KCAnnotation.h"
#import "CustomAnnotationView.h"
#import "GDLocalizableController.h"

@interface MoreMapViewController ()

@end

@implementation MoreMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMap];
}

-(void)initMap{
    usermap = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    usermap.delegate = self;
    usermap.showsUserLocation = YES;
    [usermap setScrollEnabled:YES];
    [self.view addSubview:usermap];
    
    MKPointAnnotation  *annota = [[MKPointAnnotation alloc] init];
    annota.coordinate = CLLocationCoordinate2DMake(_lng, _lat);
    annota.title = _SHtitle;
    annota.subtitle = _excerpt;
    [usermap addAnnotation:annota];
    [self SetMapRegion:annota.coordinate];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 40, 40)];
    [backBtn setExclusiveTouch:YES];
    backBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [backBtn setBackgroundImage:[UIImage imageNamed:@"circular"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    [backBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [backBtn setAlpha:0.7];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 8, 10, 10)];
    [backBtn addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    [usermap addSubview:backBtn];
    
    UIButton *locationButton = [[UIButton alloc]init];
    [locationButton setExclusiveTouch:YES];
    locationButton.frame = CGRectMake(10, CGRectGetHeight(usermap.bounds)-50, 40, 40);
    locationButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [locationButton setBackgroundImage:[UIImage imageNamed:@"circular"] forState:UIControlStateNormal];
    [locationButton setImage:[UIImage imageNamed:@"routeWhite"] forState:UIControlStateNormal];
    [locationButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [locationButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [locationButton setAlpha:0.7];
    [locationButton addTarget:self action:@selector(navlocation) forControlEvents:UIControlEventTouchUpInside];
    [usermap addSubview:locationButton];
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
    self.navigationController.navigationBarHidden = NO;
}

-(void)SetMapRegion:(CLLocationCoordinate2D)myCoordinate
{
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=myCoordinate;
    theRegion.span.longitudeDelta = 0.005f;
    theRegion.span.latitudeDelta = 0.005f;
    [usermap setRegion:theRegion animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MKAnnotationView *annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"location"];
        annotationView.frame = CGRectMake(0, 0, 20, 26);
        annotationView.centerOffset = CGPointMake(6, -18);
        return annotationView;
    }
    return nil;
}

-(void)navlocation{
    CLLocationCoordinate2D coords2 = CLLocationCoordinate2DMake(_lng,_lat);
    MKMapItem *mapitem1 = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *mapitem2 = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:coords2 addressDictionary:nil]];
    NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
    [MKMapItem openMapsWithItems:@[mapitem1,mapitem2] launchOptions:options];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
