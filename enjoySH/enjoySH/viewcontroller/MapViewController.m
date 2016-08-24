//
//  RightMenuViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/7.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "MapViewController.h"
#import "XmlDataParser.h"
#import "VenueViewController.h"
#import "KCAnnotation.h"
#import "CustomAnnotationView.h"
#import "GDLocalizableController.h"
#import "UIImageView+WebCache.h"

@interface MapViewController (){
    NSInteger flag;
    NSMutableArray *dataArray;
    UITableView *menuTable;
    NSInteger annoTag;
    UIActivityIndicatorView *_aiView;
    UIView *activityBackGround;
    UILabel *activityLab;
}

@end

@implementation MapViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:NO];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMap];
    activityBackGround = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height)/2-30, 100, 80)];
    activityBackGround.backgroundColor = [UIColor blackColor];
    activityBackGround.layer.cornerRadius = 10;
    activityBackGround.hidden = NO;
    [self.view addSubview:activityBackGround];
    
    activityLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height/2+10, 100, 30)];
    activityLab.textAlignment = NSTextAlignmentCenter;
    activityLab.textColor = [UIColor whiteColor];
    activityLab.text = GDLocalizedString(@"LOAD");
    activityLab.hidden = NO;
    [self.view addSubview:activityLab];
    
    _aiView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _aiView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _aiView.hidesWhenStopped = YES;
    [_aiView startAnimating];
    [self.view addSubview:_aiView];
    [self initControls];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goDetail:) name:@"goDetail" object:nil];
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(initData) object:nil];
    [thread start];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initMap{
    usermap = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    usermap.delegate = self;
    usermap.showsUserLocation = YES;
    [usermap setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center = _currentLocation.coordinate;
    [usermap setScrollEnabled:YES];
    region.span.latitudeDelta=0.0125f;
    region.span.longitudeDelta=0.0125f;
    [usermap setRegion:region animated:YES];
    [self.view addSubview:usermap];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    _currentLocation = mapView.userLocation.location;
}

-(void)initData{
    dataArray = [[NSMutableArray alloc]init];
    XmlDataParser *xmlData = [[XmlDataParser alloc]init];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString *string = [NSString stringWithFormat:@"http://app.enjoylist.com/map.asp?radius=5000&lat=%f&lng=%f",[userdefault doubleForKey:@"lng"],[userdefault doubleForKey:@"lat"]];
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string = [string stringByAppendingString:@"&locale=zh-cn"];
    }
    [xmlData StartParse:string];
    dataArray = xmlData.dataArray;
    if (dataArray!=nil) {
        [self performSelectorOnMainThread:@selector(reloadmapView) withObject:nil waitUntilDone:NO];
    }else{
        activityLab.hidden = YES;
        activityBackGround.hidden = YES;
        [_aiView stopAnimating];
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Network Promblem!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [alter show];
    }
}

-(void)reloadmapView{
    activityLab.hidden = YES;
    activityBackGround.hidden = YES;
    [_aiView stopAnimating];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [[NSDictionary alloc]init];
    _annotations = [NSMutableArray array];
    for(int i = 0; i < [dataArray count];i++){
        KCAnnotation *annotation = [[KCAnnotation alloc] init];
        dict = [dataArray objectAtIndex:i];
        annotation.coordinate = CLLocationCoordinate2DMake([[dict objectForKey:@"lng"] doubleValue], [[dict objectForKey:@"lat"] doubleValue]);
        annotation.title = [dict objectForKey:@"name"];
        annotation.subtitle = [dict objectForKey:@"address"];
        if (![[dict objectForKey:@"near"] isEqualToString:@"()"]) {
            annotation.subtitle = [annotation.subtitle stringByAppendingString:[dict objectForKey:@"near"]];
        }
        if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
            annotation.subtitle = [dict objectForKey:@"chAddress"];
            if (![[dict objectForKey:@"chnear"] isEqualToString:@"()"]) {
                annotation.subtitle = [annotation.subtitle stringByAppendingString:[dict objectForKey:@"chnear"]];
            }
        }
        annotation.tag = [[dict objectForKey:@"id"] intValue];
        annotation.lng = [[dict objectForKey:@"lng"] doubleValue];
        annotation.lat = [[dict objectForKey:@"lat"] doubleValue];
        [_annotations addObject:annotation];
    }
    [usermap addAnnotations:_annotations];
    [usermap reloadInputViews];
}

-(void)goDetail:(NSNotification *)notification{
    self.navigationController.navigationBarHidden = NO;
    VenueViewController *vc = [[VenueViewController alloc]init];
    vc.clientid = [notification object];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)initControls{
    annoTag = -1;
    _locationButton = [[UIButton alloc]init];
    [_locationButton setExclusiveTouch:YES];
    _locationButton.frame = CGRectMake(10, CGRectGetHeight(usermap.bounds)-50, 40, 40);
    _locationButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [_locationButton setBackgroundImage:[UIImage imageNamed:@"circular"] forState:UIControlStateNormal];
    [_locationButton setImage:[UIImage imageNamed:@"navigation"] forState:UIControlStateNormal];
    [_locationButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_locationButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [_locationButton setAlpha:0.7];
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    [usermap addSubview:_locationButton];
    
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
    
    UIButton *refresh = [[UIButton alloc]init];
    refresh.frame = CGRectMake(usermap.frame.size.width-50, 20, 40, 40);
    [refresh setExclusiveTouch:YES];
    refresh.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [refresh setBackgroundImage:[UIImage imageNamed:@"circular"] forState:UIControlStateNormal];
    [refresh setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [refresh.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [refresh setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [refresh setAlpha:0.7];
    [refresh addTarget:self action:@selector(removeanno) forControlEvents:UIControlEventTouchUpInside];
    [usermap addSubview:refresh];
    
    UIButton *menuBtn = [[UIButton alloc]init];
    [menuBtn setExclusiveTouch:YES];
    menuBtn.frame = CGRectMake(usermap.frame.size.width-50, CGRectGetHeight(usermap.bounds)-50, 40, 40);
    menuBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"circular"] forState:UIControlStateNormal];
    [menuBtn setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
    [menuBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [menuBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [menuBtn setAlpha:0.7];
    [menuBtn addTarget:self action:@selector(menuBtn) forControlEvents:UIControlEventTouchUpInside];
    [usermap addSubview:menuBtn];
    
    menuTable = [[UITableView alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height/2-160, self.view.frame.size.width-20, 320)];
    menuTable.delegate = self;
    menuTable.dataSource = self;
    menuTable.bounces = NO;
    menuTable.tableFooterView = [[UIView alloc]init];
    menuTable.hidden = YES;
    [usermap addSubview:menuTable];
}

-(void)backtoView{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)removeanno{
    activityLab.hidden = NO;
    activityBackGround.hidden = NO;
    [_aiView startAnimating];
    [usermap removeAnnotations:_annotations];
    [usermap reloadInputViews];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLocate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadthemap) name:@"refreshLoc" object:nil];
}

-(void)reloadthemap{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(initData) object:nil];
    [thread start];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(KCAnnotation *)annotation{
    if ([annotation isKindOfClass:[KCAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        annotationView.canShowCallout = NO;
        annotationView.anno = annotation;
        annotationView.image = [UIImage imageNamed:@"location"];
        annotationView.frame = CGRectMake(0, 0, 20, 26);
        return annotationView;
    }
    return nil;
}

-(void)locationAction{
    if (usermap.userTrackingMode != MKUserTrackingModeFollow)
    {
        [usermap setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    }
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    menuTable.hidden = YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (menuTable.hidden == NO) {
        menuTable.hidden = YES;
    }
}

-(void)daohang{
    if(annoTag<0){
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Choose a client") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [alter show];
    }else{
        NSDictionary *dict = [[NSDictionary alloc]init];
        dict = [dataArray objectAtIndex:annoTag];
        MKMapItem *mylocation = [MKMapItem mapItemForCurrentLocation];
        //当前经维度
        float currentLatitude=mylocation.placemark.location.coordinate.latitude;
        float currentLongitude=mylocation.placemark.location.coordinate.longitude;
        CLLocationCoordinate2D coords1 = CLLocationCoordinate2DMake(currentLatitude,currentLongitude);
        CLLocationCoordinate2D coords2 = CLLocationCoordinate2DMake([[dict objectForKey:@"lng"] doubleValue], [[dict objectForKey:@"lat"] doubleValue]);
        if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] == NSOrderedAscending)
        {
            NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d", coords1.latitude,coords1.longitude,coords2.latitude,coords2.longitude];
            NSURL *aURL = [NSURL URLWithString:urlString];
            //打开网页google地图
            [[UIApplication sharedApplication] openURL:aURL];
        }else{
            MKMapItem *mapitem1 = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *mapitem2 = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:coords2 addressDictionary:nil]];
            NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
            [MKMapItem openMapsWithItems:@[mapitem1,mapitem2] launchOptions:options];
        }
        annoTag = -1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (dataArray!=nil) {
        NSDictionary *_dict = [dataArray objectAtIndex:indexPath.row];
        UIImageView *clientIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        [clientIcon sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"picx2"]]];
        [cell.contentView addSubview:clientIcon];
        UIView *clientDetailView = [[UIView alloc]init];
        [cell.contentView addSubview:clientDetailView];
        UILabel *clientName = [[UILabel alloc]init];
        clientName.text = [_dict objectForKey:@"name"];
        clientName.lineBreakMode = NSLineBreakByTruncatingTail;
        clientName.numberOfLines = 1;
        clientName.font = [UIFont boldSystemFontOfSize:13];
        CGRect clientNameRect = [clientName.text boundingRectWithSize:CGSizeMake(cell.frame.size.width-90, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:clientName.font} context:nil];
        clientName.frame = CGRectMake(80, 0, clientNameRect.size.width, clientNameRect.size.height);
        [clientDetailView addSubview:clientName];
        
        NSString *stars = [_dict objectForKey:@"score"];
        NSInteger starinter = stars.doubleValue+0.5;
        NSInteger j = 0;
        for (NSInteger i=0; i<starinter ; i++) {
            UIImageView *star = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star"]];
            CGRect _frame = CGRectMake(80+i*13+i*5, 3+clientName.frame.size.height, 13, 13);
            star.frame = _frame;
            [clientDetailView addSubview:star];
            j = i;
        }
        if (j!=0) {
            j++;
        }
        for (; j<5 ; j++) {
            UIImageView *blackstar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star2"]];
            CGRect _frame = CGRectMake(80+j*13+j*5, 3+clientName.frame.size.height, 13, 13);
            blackstar.frame = _frame;
            [clientDetailView addSubview:blackstar];
        }
        
        UILabel *excerpt = [[UILabel alloc]init];
        excerpt.text = [_dict objectForKey:@"tag"];
        excerpt.textColor = [UIColor grayColor];
        excerpt.textAlignment = NSTextAlignmentNatural;
        excerpt.font = [UIFont systemFontOfSize:12];
        excerpt.numberOfLines = 1;
        excerpt.lineBreakMode = NSLineBreakByTruncatingTail;
        [clientDetailView addSubview:excerpt];
        
        UILabel *pricelab = [[UILabel alloc]init];
        pricelab.font = [UIFont systemFontOfSize:12];
        pricelab.numberOfLines=1;
        pricelab.textColor = [UIColor grayColor];
        pricelab.lineBreakMode = NSLineBreakByTruncatingTail;
        NSString *priceString = [_dict objectForKey:@"price"];
        if(![priceString isEqualToString:@""]){
            priceString = [[_dict objectForKey:@"price"] substringFromIndex:1];
            pricelab.text = priceString;
            CGRect priceRect = [priceString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:pricelab.font} context:nil];
            pricelab.frame = CGRectMake(cell.frame.size.width-priceRect.size.width-80, 22+clientName.frame.size.height-1, priceRect.size.width, priceRect.size.height);
            UIImageView *price = [[UIImageView alloc]initWithFrame:CGRectMake(pricelab.frame.origin.x-15, 22+clientName.frame.size.height, 12, 12)];
            price.image = [UIImage imageNamed:@"average"];
            [clientDetailView addSubview:price];
        }
        [clientDetailView addSubview:pricelab];
        CGRect excerptRect = [excerpt.text boundingRectWithSize:CGSizeMake(pricelab.frame.origin.x-20-excerpt.frame.origin.x, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:excerpt.font} context:nil];
        CGRect newframe = excerpt.frame;
        newframe.origin.x = 95;
        newframe.origin.y = 22+clientName.frame.size.height-1;
        newframe.size.width = excerptRect.size.width;
        newframe.size.height = excerptRect.size.height;
        excerpt.frame = newframe;
        UIImageView *cuisine = [[UIImageView alloc]initWithFrame:CGRectMake(80, 22+clientName.frame.size.height, 12, 12)];
        cuisine.image = [UIImage imageNamed:@"cuisine"];
        [clientDetailView addSubview:cuisine];
        clientDetailView.frame = CGRectMake(0, (80-6-clientName.frame.size.height-13-excerpt.frame.size.height)/2, self.view.frame.size.width, 8+clientName.frame.size.height+13+excerpt.frame.size.height);
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationController.navigationBarHidden = NO;
    VenueViewController *venueView = [[VenueViewController alloc]init];
    venueView.clientid = [[dataArray objectAtIndex:indexPath.row] objectForKey:@"id"];
    [self.navigationController pushViewController:venueView animated:YES];
}


-(void)menuBtn{
    if (menuTable.hidden == YES) {
        [menuTable reloadData];
        menuTable.hidden = NO;
    }else{
        menuTable.hidden = YES;
    }
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
