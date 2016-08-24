//
//  diningViewController.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-13.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "ListViewController.h"
#import "MapViewController.h"
#import "VenueViewController.h"
#import "XmlDataParser.h"
#import "XmlArea.h"
#import "SlideNavigationController.h"
#import "mainViewController.h"
#import "GDLocalizableController.h"
#import "UIImageView+WebCache.h"

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@interface ListViewController (){
    NSMutableArray *_dataArray;
    UITableView *_tableView;
    NSMutableDictionary *_dict;
    UIButton *_category1;
    UIButton *_category2;
    UIButton *_category3;
    UITableView *categoryTable1;
    UITableView *categoryTable2;
    UITableView *categoryTable3;
    NSMutableArray *areaArray;
    NSString *newArea;
    NSString *sort;
    UIImageView *clientImage;
    UIActivityIndicatorView *_aiView;
    UIView *activityBackGround;
    UILabel *activityLab;
    UILabel *titleLab;
    UILabel *navline;
    BOOL _loadingMore;
    NSInteger page;
    NSInteger catestring2;
    NSInteger catestring3;
    NSMutableArray *MoreDateArray;
    UIImageView *a;
    UIImageView *b;
    UIImageView *c;
    UIActivityIndicatorView *tableFooterActivityIndicator;
}

@end

@implementation ListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLocate" object:nil];
    // Do any additional setup after loading the view.
    CGFloat Phonewidth = self.view.frame.size.width;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    [self.view setBackgroundColor:LabColor(0.94, 0.94, 0.94)];
    page = 0;
    [self initnav];
    [self initCategoryBtn];
    NSThread *listthread = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
    [listthread start];
    NSThread *areathread = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
    [areathread start];
    _tableView= [[UITableView alloc]initWithFrame:CGRectMake(10, 104, Phonewidth-10, self.view.bounds.size.height-114)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
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
    _tableView.hidden =YES;
    [self.view addSubview:_aiView];
    [self initDownList];
    catestring2 = -1;
    catestring3 = -1;
}

-(void)initnav{
    UIButton *right  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [right setExclusiveTouch:YES];
    [right setImage:[UIImage imageNamed:@"nearbywhite"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(dingwei)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIButton *left  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [left setExclusiveTouch:YES];
    [left setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [left addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    UIView *Statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    Statusview.backgroundColor = LabColor(0.90,0,0);
    [self.view addSubview:Statusview];
}

-(void)initCategoryBtn{
    _category1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width/3 ,40)];
    [_category1 addTarget:self action:@selector(categoryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _category1.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _category1.tag = 1;
    [_category1 setBackgroundColor:LabColor(0.90,0,0)];
    a = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3-10, 15, 10, 10)];
    a.contentMode = UIViewContentModeScaleAspectFit;
    a.image = [UIImage imageNamed:@"triangle"];
    [_category1 addSubview:a];
    [self.view addSubview:_category1];
    
    _category2 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3, 64, self.view.frame.size.width/3, 40)];
    [_category2 setTitle:GDLocalizedString(@"Area") forState:UIControlStateNormal];
    _category2.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _category2.tag = 2;
    [_category2 addTarget:self action:@selector(categoryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_category2 setBackgroundColor:LabColor(0.90,0,0)];
    b = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3-10, 15, 10, 10)];
    b.contentMode = UIViewContentModeScaleAspectFit;
    b.image = [UIImage imageNamed:@"triangle"];
    [_category2 addSubview:b];
    [self.view addSubview:_category2];
    
    _category3 = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3*2, 64, self.view.frame.size.width/3, 40)];
    [_category3 setTitle:GDLocalizedString(@"Sort") forState:UIControlStateNormal];
    _category3.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _category3.tag = 3;
    [_category3 addTarget:self action:@selector(categoryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_category3 setBackgroundColor:LabColor(0.90,0,0)];
    c = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/3-20, 15, 10, 10)];
    c.contentMode = UIViewContentModeScaleAspectFit;
    c.image = [UIImage imageNamed:@"triangle"];
    [_category3 addSubview:c];
    [self.view addSubview:_category3];

    UIView *navlinebackground = [[UIView alloc]initWithFrame:CGRectMake(0, 101, self.view.frame.size.width, 3)];
    navlinebackground.backgroundColor = LabColor(0.68, 0, 0.09);
    [self.view addSubview:navlinebackground];
    
    navline = [[UILabel alloc]initWithFrame:CGRectMake(0, 101, self.view.frame.size.width/3, 3)];
    navline.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navline];
    
    titleLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:15];
    self.navigationItem.titleView = titleLab;
    switch (_category.integerValue) {
        case 300:
            titleLab.text = GDLocalizedString(@"Dining");
            [_category1 setTitle:GDLocalizedString(@"Dining") forState:UIControlStateNormal];
            break;
        case 301:
            titleLab.text = GDLocalizedString(@"Nightlife");
            [_category1 setTitle:GDLocalizedString(@"Nightlife") forState:UIControlStateNormal];
            break;
        case 302:
            titleLab.text = GDLocalizedString(@"Health");
            [_category1 setTitle:GDLocalizedString(@"Health") forState:UIControlStateNormal];
            break;
        case 305:
            titleLab.text = GDLocalizedString(@"Shopping");
            [_category1 setTitle:GDLocalizedString(@"Shopping") forState:UIControlStateNormal];
            break;
        case 304:
            titleLab.text = GDLocalizedString(@"Lifestyle");
            [_category1 setTitle:GDLocalizedString(@"Lifestyle") forState:UIControlStateNormal];
            break;
        case 314:
            titleLab.text = GDLocalizedString(@"Travel");
            [_category1 setTitle:GDLocalizedString(@"Travel") forState:UIControlStateNormal];
            break;
        default:
            [_category1 setTitle:GDLocalizedString(@"ALL") forState:UIControlStateNormal];
            [_category3 setTitle:GDLocalizedString(@"Score") forState:UIControlStateNormal];
            break;
    }
}

-(void)initDownList{
    categoryTable1 = [[UITableView alloc] initWithFrame:CGRectMake(0, _category1.frame.origin.y+_category1.frame.size.height, self.view.frame.size.width, 240)];
    categoryTable1.delegate = self;
    categoryTable1.dataSource = self;
    categoryTable1.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
    categoryTable1.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    categoryTable1.separatorColor = [UIColor grayColor];
    categoryTable1.hidden = YES;
    categoryTable1.tag =1;
    categoryTable1.tableFooterView = [[UIView alloc]init];
    [categoryTable1 setBounces:NO];
    [self.view addSubview:categoryTable1];
    
    categoryTable2 = [[UITableView alloc] init];
    categoryTable2.frame = CGRectMake(0, _category2.frame.origin.y+_category2.frame.size.height, self.view.frame.size.width, 320);
    categoryTable2.delegate = self;
    categoryTable2.dataSource = self;
    categoryTable2.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
    categoryTable2.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    categoryTable2.separatorColor = [UIColor grayColor];
    categoryTable2.hidden = YES;
    categoryTable2.tag =2;
    [categoryTable2 setBounces:NO];
    categoryTable2.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:categoryTable2];
    
    categoryTable3 = [[UITableView alloc] initWithFrame:CGRectMake(0, _category3.frame.origin.y+_category3.frame.size.height, self.view.frame.size.width, 160)];
    categoryTable3.delegate = self;
    categoryTable3.dataSource = self;
    categoryTable3.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
    categoryTable3.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    categoryTable3.separatorColor = [UIColor grayColor];
    categoryTable3.hidden = YES;
    categoryTable3.tag =3;
    [categoryTable3 setBounces:NO];
    categoryTable3.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:categoryTable3];
}

-(void)initListData{
    XmlDataParser *parser = [XmlDataParser alloc];
    NSString *string2;
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if (_category == nil){
        string2= @"http://app.enjoylist.com/clients.asp?sortby=score";
    }else{
        NSString *string1 = @"http://app.enjoylist.com/clients.asp?category=";
        string2 = [string1 stringByAppendingString:_category];
    }
    if([[userdefault objectForKey:@"locationflag"] isEqualToString:@"1"]){
        string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&lat=%f&lng=%f",[userdefault doubleForKey:@"lng"],[userdefault doubleForKey:@"lat"]]];
    }
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string2 = [string2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [parser StartParse:string2];
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray = parser.dataArray;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changedLanguage" object:nil];
    if (_dataArray==nil) {
        [self performSelectorOnMainThread:@selector(netaltershow) withObject:nil waitUntilDone:NO];
    }else if(_dataArray!=nil){
        [self performSelectorOnMainThread:@selector(reloadListTable) withObject:nil waitUntilDone:NO];
    }
}

-(void)netaltershow{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    _tableView.hidden = YES;
    [_aiView stopAnimating];
    activityBackGround.hidden = YES;
    activityLab.hidden = YES;
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Network Promblem!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    alter.delegate = self;
    [alter show];
}

-(void)initArea{
    areaArray = [[NSMutableArray alloc]init];
    XmlArea *xmlarea = [[XmlArea alloc]init];
    NSString *string = @"http://app.enjoylist.com/area.asp?";
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string = [string stringByAppendingString:@"locale=zh-cn"];
    }if (_category != nil){
        if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"&category=%@",_category]];
        }else{
            string = [string stringByAppendingString:[NSString stringWithFormat:@"category=%@",_category]];
        }
    }
    [xmlarea StartParse:string];
    areaArray = xmlarea.dataArray;
    if (areaArray!=nil) {
        [self performSelectorOnMainThread:@selector(reloadAreaTable) withObject:nil waitUntilDone:NO];
    }
}

-(void)reloadAreaTable{
    CGRect newframe = categoryTable2.frame;
    if (areaArray.count <= 8) {
        newframe.size.height = areaArray.count*40;
        categoryTable2.frame = newframe;
    }else{
        newframe.size.height = 320;
        categoryTable2.frame = newframe;
    }
    if (catestring2 !=-1) {
        NSDictionary *dict = [areaArray objectAtIndex:catestring2];
        [_category2 setTitle:[dict objectForKey:@"title"] forState:UIControlStateNormal];
    }else{
        [_category2 setTitle:GDLocalizedString(@"Area") forState:UIControlStateNormal];
    }
    [categoryTable2 reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num;
    if (tableView.tag == 0) {
        num =  _dataArray.count;
    }
    else if (tableView.tag == 1){
        num = 6;
    }else if (tableView.tag == 2){
        num = [areaArray count];
    }else if (tableView.tag == 3){
        num = 4;
    }else{
        num = 0;
    }
    return num;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (tableView.tag == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        if (_dataArray!=nil) {
            _dict = [_dataArray objectAtIndex:indexPath.row];
            clientImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 5,self.view.frame.size.width-20, self.view.frame.size.width*0.65625-60)];
            clientImage.backgroundColor = [UIColor whiteColor];
            UIImageView *loadImageView = [[UIImageView alloc]init];
            loadImageView.frame = CGRectMake(0, 0, 32, 32);
            loadImageView.center = clientImage.center;
            loadImageView.animationImages = [NSArray arrayWithObjects:
                                             [UIImage imageNamed:@"load1.jpg"],
                                             [UIImage imageNamed:@"load2.jpg"],
                                             [UIImage imageNamed:@"load3.jpg"],
                                             [UIImage imageNamed:@"load4.jpg"],
                                             [UIImage imageNamed:@"load5.jpg"],
                                             [UIImage imageNamed:@"load6.jpg"],
                                             [UIImage imageNamed:@"load7.jpg"],
                                             [UIImage imageNamed:@"load8.jpg"],
                                             [UIImage imageNamed:@"load9.jpg"],
                                             [UIImage imageNamed:@"load10.jpg"],nil];
            loadImageView.animationDuration = 0.8f;
            loadImageView.animationRepeatCount = 0;
            [loadImageView startAnimating];
            [clientImage addSubview:loadImageView];
            [clientImage sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"iconx2"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [loadImageView removeFromSuperview];
            }];
            [cell.contentView addSubview:clientImage];
            if (![[_dict objectForKey:@"discount"] isEqualToString:@""]) {
                UIImageView *discountView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-105, 0, 40, 40)];
                if ([[_dict objectForKey:@"discount"] isEqualToString:@"DEAL"]) {
                    discountView.frame = CGRectMake(self.view.frame.size.width-105, 0, 40, 40);
                }
                discountView.image = [UIImage imageNamed:@"OFF"];
                [clientImage addSubview:discountView];
                UILabel *discount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
                if ([[_dict objectForKey:@"discount"] isEqualToString:@"DEAL"]) {
                    discount.frame = CGRectMake(0, 0, 40, 40);
                    discount.font = [UIFont systemFontOfSize:12];
                }else{
                    discount.font = [UIFont boldSystemFontOfSize:14];
                }
                discount.text = [_dict objectForKey:@"discount"];
                discount.textColor = [UIColor whiteColor];
                discount.textAlignment = NSTextAlignmentCenter;
                [discountView addSubview:discount];
              }
        }else{
            UIImageView *discountView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width-105, 0, 70, 40)];
            discountView.image = [UIImage imageNamed:@"OFF"];
            [clientImage addSubview:discountView];
            UILabel *discount = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 40)];
            discount.text = GDLocalizedString(@"No Discount");
            discount.font = [UIFont boldSystemFontOfSize:14];
            discount.textColor = [UIColor whiteColor];
            discount.textAlignment = NSTextAlignmentCenter;
            [discountView addSubview:discount];
        }
        UIImageView *shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, clientImage.frame.size.height-40, clientImage.frame.size.width, 50)];
        shadow.image = [UIImage imageNamed:@"Shadow 2"];
        [clientImage addSubview:shadow];
        
        UILabel *clientDetail = [[UILabel alloc]initWithFrame:CGRectMake(15, clientImage.frame.size.height-40, self.view.frame.size.width-50, 40)];
        clientDetail.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:12];
        clientDetail.text = [_dict objectForKey:@"name"];
        clientDetail.textColor = [UIColor whiteColor];
        clientDetail.numberOfLines = 0;
        clientDetail.lineBreakMode = NSLineBreakByWordWrapping;
        [clientImage addSubview:clientDetail];
        
        UIView *moreView = [[UIView alloc]initWithFrame:CGRectMake(0, clientImage.frame.size.height, self.view.frame.size.width-20, 50)];
        moreView.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:moreView];
        
        UILabel *voucherOffer= [[UILabel alloc]initWithFrame:CGRectMake(15, 5, self.view.frame.size.width-100, 20)];
        voucherOffer.font = [UIFont systemFontOfSize:15];
        voucherOffer.text = [_dict objectForKey:@"voucherOffer"];
        voucherOffer.textColor = LabColor(0.90, 0, 0);
        voucherOffer.numberOfLines = 1;
        voucherOffer.lineBreakMode = NSLineBreakByTruncatingTail;
        [moreView addSubview:voucherOffer];
        
        UILabel *voucherOfferDescription= [[UILabel alloc]initWithFrame:CGRectMake(15, 20, self.view.frame.size.width-100, 20)];
        voucherOfferDescription.font = [UIFont systemFontOfSize:12];
        voucherOfferDescription.text = [_dict objectForKey:@"voucherOfferDescription"];
        voucherOfferDescription.textColor = LabColor(0.33, 0.33, 0.33);
        voucherOfferDescription.numberOfLines = 1;
        voucherOfferDescription.lineBreakMode = NSLineBreakByTruncatingTail;
        [moreView addSubview:voucherOfferDescription];
        
        UILabel *distance = [[UILabel alloc]init];
        distance.font = [UIFont systemFontOfSize:12];
        distance.textColor = LabColor(0.33, 0.33, 0.33);
        if ([[_dict objectForKey:@"distance"] integerValue]>1000) {
            NSInteger newdistance =[[_dict objectForKey:@"distance"] integerValue]/1000;
            distance.text = [NSString stringWithFormat:@">%likm",(long)newdistance];
        }else{
            distance.text = [NSString stringWithFormat:@"%lim",(long)[[_dict objectForKey:@"distance"] integerValue]];
        }
        CGRect distanceRect = [distance.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:distance.font} context:nil];
        distance.frame = CGRectMake(self.view.frame.size.width-distanceRect.size.width-30, 22, distanceRect.size.width, distanceRect.size.height);
        [moreView addSubview:distance];
        
        UIImageView *distanceImage = [[UIImageView alloc]initWithFrame:CGRectMake(distance.frame.origin.x-13, 22-1.5,10, 15)];
        distanceImage.image =[UIImage imageNamed:@"location_s"];
        [moreView addSubview:distanceImage];
        
        UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width*0.65625-11, self.view.frame.size.width-20, 1)];
        line.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [cell.contentView addSubview:line];
    }
    else if(tableView.tag == 1){
        NSArray * arr = [[NSArray alloc] init];
        arr = [NSArray arrayWithObjects:GDLocalizedString(@"Dining"), GDLocalizedString(@"Nightlife"), GDLocalizedString(@"Health"),GDLocalizedString(@"Shopping"),GDLocalizedString(@"Lifestyle"),GDLocalizedString(@"Travel"),nil];
        cell.textLabel.text =[arr objectAtIndex:indexPath.row];
        cell.textLabel.textColor = LabColor(0.33, 0.33, 0.33);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = LabColor(0.90, 0, 0);
    }
    else if(tableView.tag == 2){
        NSDictionary *dict;
        if (areaArray!=nil) {
            dict = [areaArray objectAtIndex:indexPath.row];
            cell.textLabel.text =[dict objectForKey:@"title"];
            cell.textLabel.textColor = LabColor(0.33, 0.33, 0.33);
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
            cell.selectedBackgroundView.backgroundColor = LabColor(0.90, 0, 0);
        }
    }
    else if(tableView.tag == 3){
        NSArray * arr = [[NSArray alloc] init];
        arr = [NSArray arrayWithObjects:GDLocalizedString(@"Score"), GDLocalizedString(@"Name"), GDLocalizedString(@"Distance"),GDLocalizedString(@"Price"),nil];
        cell.textLabel.text =[arr objectAtIndex:indexPath.row];
        cell.textLabel.textColor = LabColor(0.33, 0.33, 0.33);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor redColor];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundView.backgroundColor = [UIColor colorWithRed:0.90/1 green:0/1 blue:0/1 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
}
-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = LabColor(0.33, 0.33, 0.33);
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = LabColor(0.33, 0.33, 0.33);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height;
    
    if (tableView.tag==0) {
        height = self.view.frame.size.width*0.65625-10;
    }
    else if (tableView.tag ==1){
        height = 40;
    }
    else if (tableView.tag ==2){
        height = 40;
    }
    else if (tableView.tag ==3){
        height = 40;
    }else{
        height = 0;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView.tag == 0) {
        categoryTable1.hidden=YES;
        categoryTable2.hidden=YES;
        categoryTable3.hidden=YES;
        VenueViewController *venueView = [VenueViewController new];
        venueView.clientid = [[_dataArray objectAtIndex:indexPath.row] objectForKey:@"id"];
        [self.navigationController pushViewController:venueView animated:YES];
    }else if (tableView.tag == 1){
        tableView.hidden =YES;
        [_category2 setTitle:GDLocalizedString(@"Area") forState:UIControlStateNormal];
        [_category3 setTitle:GDLocalizedString(@"Sort") forState:UIControlStateNormal];
        cell.textLabel.textColor = [UIColor whiteColor];
        newArea = nil;
        sort = nil;
        page = 0;
        catestring2 = -1;
        catestring3 = -1;
        _loadingMore = NO;
        switch (indexPath.row) {
            case 0:
            {
                _category = @"300";
                NSThread *reloadList = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
                [reloadList start];
                NSThread *reloadArea = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
                [reloadArea start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                titleLab.text = GDLocalizedString(@"Dining");
                [_category1 setTitle:GDLocalizedString(@"Dining") forState:UIControlStateNormal];
                _tableView.hidden =YES;
            }
                break;
            case 1:
            {
                _category = @"301";
                NSThread *reloadList = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
                [reloadList start];
                NSThread *reloadArea = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
                [reloadArea start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                titleLab.text = GDLocalizedString(@"Nightlife");
                [_category1 setTitle:GDLocalizedString(@"Nightlife") forState:UIControlStateNormal];
                _tableView.hidden =YES;
            }
                break;
            case 2:
            {
                _category = @"302";
                NSThread *reloadList = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
                [reloadList start];
                NSThread *reloadArea = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
                [reloadArea start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                titleLab.text = GDLocalizedString(@"Health");
                [_category1 setTitle:GDLocalizedString(@"Health") forState:UIControlStateNormal];
                _tableView.hidden =YES;
            }
                break;
            case 3:
            {
                _category = @"305";
                NSThread *reloadList = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
                [reloadList start];
                NSThread *reloadArea = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
                [reloadArea start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                titleLab.text = GDLocalizedString(@"Shopping");
                [_category1 setTitle:GDLocalizedString(@"Shopping") forState:UIControlStateNormal];
                _tableView.hidden =YES;
            }
                break;
            case 4:
            {
                _category = @"304";
                NSThread *reloadList = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
                [reloadList start];
                NSThread *reloadArea = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
                [reloadArea start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                titleLab.text = GDLocalizedString(@"Lifestyle");
                [_category1 setTitle:GDLocalizedString(@"Lifestyle") forState:UIControlStateNormal];
                _tableView.hidden =YES;
            }
                break;
            case 5:
            {
                _category = @"314";
                NSThread *reloadList = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
                [reloadList start];
                NSThread *reloadArea = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
                [reloadArea start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                titleLab.text = GDLocalizedString(@"Travel");
                [_category1 setTitle:GDLocalizedString(@"Travel") forState:UIControlStateNormal];
                _tableView.hidden =YES;
            }
                break;
            default:
                break;
        }
    }else if (tableView.tag == 2){
        page = 0;
        tableView.hidden =YES;
        _tableView.hidden =YES;
        cell.textLabel.textColor = [UIColor whiteColor];
        NSDictionary *dict;
        if (areaArray!=nil) {
            dict = [areaArray objectAtIndex:indexPath.row];
            catestring2 = indexPath.row;
            newArea = [dict objectForKey:@"name"];
            [_category2 setTitle:[dict objectForKey:@"title"] forState:UIControlStateNormal];
            [_aiView startAnimating];
            activityBackGround.hidden = NO;
            activityLab.hidden = NO;
            NSThread *reloadarea = [[NSThread alloc]initWithTarget:self selector:@selector(reloadArea) object:nil];
            [reloadarea start];
        }
    }
    else if (tableView.tag == 3){
        tableView.hidden =YES;
        _tableView.hidden =YES;
        page = 0;
        cell.textLabel.textColor = [UIColor whiteColor];
        catestring3 = indexPath.row;
        switch (indexPath.row) {
            case 0:
            {
                sort = @"score";
                NSThread *sortth = [[NSThread alloc]initWithTarget:self selector:@selector(sort) object:nil];
                [sortth start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                [_category3 setTitle:GDLocalizedString(@"Score") forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                sort = @"name";
                NSThread *sortth = [[NSThread alloc]initWithTarget:self selector:@selector(sort) object:nil];
                [sortth start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                [_category3 setTitle:GDLocalizedString(@"Name") forState:UIControlStateNormal];
                break;
            }
            case 2:
            {
                sort = @"distance";
                NSThread *sortth = [[NSThread alloc]initWithTarget:self selector:@selector(sort) object:nil];
                [sortth start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                [_category3 setTitle:GDLocalizedString(@"Distance") forState:UIControlStateNormal];
            }
                break;
            case 3:
            {
                sort = @"price";
                NSThread *sortth = [[NSThread alloc]initWithTarget:self selector:@selector(sort) object:nil];
                [sortth start];
                [_aiView startAnimating];
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                [_category3 setTitle:GDLocalizedString(@"Price") forState:UIControlStateNormal];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!_loadingMore && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
    {
        [self loadDataBegin];
    }
}

-(void)loadDataBegin{
    if (_loadingMore == NO)
    {
        _loadingMore = YES;
        tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(40.0f, 10.0f, 20.0f, 20.0f)];
        [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [tableFooterActivityIndicator startAnimating];
        [_tableView.tableFooterView addSubview:tableFooterActivityIndicator];
        [self loadDataing];
    }
}

-(void)loadDataing{
    page++;
    NSThread *loadmore = [[NSThread alloc]initWithTarget:self selector:@selector(initMoreListData) object:nil];
    [loadmore start];
}

-(void)initMoreListData{
    XmlDataParser *parser = [XmlDataParser alloc];
    NSString *string2;
    if (_category==nil) {
        string2= [NSString stringWithFormat: @"http://app.enjoylist.com/clients.asp?sortby=%@&start=%ld",sort,(long)page];
        if (newArea!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&area=%@",newArea]];
        }
    }else{
        string2 = [NSString stringWithFormat: @"http://app.enjoylist.com/clients.asp?category=%@&start=%ld",_category,(long)page];
        if (newArea!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&area=%@",newArea]];
        }else if (sort!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&sortby=%@",sort]];
        }
    }
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if([[userdefault objectForKey:@"locationflag"] isEqualToString:@"1"]){
        string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&lat=%f&lng=%f",[userdefault doubleForKey:@"lng"],[userdefault doubleForKey:@"lat"]]];
    }
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string2 = [string2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [parser StartParse:string2];
    MoreDateArray = parser.dataArray;
    if(MoreDateArray.count != 0){
        [self performSelectorOnMainThread:@selector(loadMoreListTable) withObject:nil waitUntilDone:NO];
    }else if(MoreDateArray.count == 0){
        _tableView.tableFooterView = nil;
        _loadingMore = YES;
        [tableFooterActivityIndicator stopAnimating];
    }
}

-(void)loadMoreListTable{
    [_dataArray addObjectsFromArray:MoreDateArray];
    [_tableView reloadData];
    [self loadDataEnd];
}

-(void)loadDataEnd{
    _loadingMore = NO;
    [self createTableFooter];
}

-(void)createTableFooter{
    _tableView.tableFooterView = nil;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _tableView.bounds.size.width, 40.0f)];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 180, 40.0)];
    [loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setFont:[UIFont systemFontOfSize:14]];
    [loadMoreText setTextAlignment:NSTextAlignmentCenter];
    [loadMoreText setText:GDLocalizedString(@"Pull up to show more data")];
    [tableFooterView addSubview:loadMoreText];
    _tableView.tableFooterView = tableFooterView;
}

-(void)dingweiBtnClick:(UIButton *)btn{
    MapViewController *mapView = [[MapViewController alloc]init];
    [self.navigationController pushViewController:mapView animated:YES];
}

-(void)reloadArea{
    XmlDataParser *parser = [XmlDataParser alloc];
    NSString *string2;
    if (_category==nil) {
        string2= [NSString stringWithFormat: @"http://app.enjoylist.com/clients.asp?sortby=%@",sort];
        if (newArea!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&area=%@",newArea]];
        }
    }else{
        string2 = [NSString stringWithFormat: @"http://app.enjoylist.com/clients.asp?category=%@",_category];
        if (newArea!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&area=%@",newArea]];
        }else if (sort!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&sortby=%@",sort]];
        }
    }
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if([[userdefault objectForKey:@"locationflag"] isEqualToString:@"1"]){
        string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&lat=%f&lng=%f",[userdefault doubleForKey:@"lng"],[userdefault doubleForKey:@"lat"]]];
    }
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string2 = [string2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [parser StartParse:string2];
    _dataArray = parser.dataArray;
    if (_dataArray!=nil){
        [self performSelectorOnMainThread:@selector(reloadListTable) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(netaltershow) withObject:nil waitUntilDone:NO];
    }
}

-(void)sort{
    XmlDataParser *parser = [XmlDataParser alloc];
    NSString *string2;
    if (_category==nil) {
        string2= [NSString stringWithFormat: @"http://app.enjoylist.com/clients.asp?sortby=%@",sort];
        if (newArea!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&area=%@",newArea]];
        }
    }else{
        string2 = [NSString stringWithFormat: @"http://app.enjoylist.com/clients.asp?category=%@",_category];
        if (newArea!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&area=%@",newArea]];
        }else if (sort!=nil) {
            string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&sortby=%@",sort]];
        }
    }
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if([[userdefault objectForKey:@"locationflag"] isEqualToString:@"1"]){
        string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"&lat=%f&lng=%f",[userdefault doubleForKey:@"lng"],[userdefault doubleForKey:@"lat"]]];
    }
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string2 = [string2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [parser StartParse:string2];
    _dataArray = parser.dataArray;
    if (_dataArray!=nil) {
        [self performSelectorOnMainThread:@selector(reloadListTable) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(netaltershow) withObject:nil waitUntilDone:NO];
    }
}

-(void)reloadListTable{
    self.navigationItem.leftBarButtonItem.enabled = YES;
    [_tableView reloadData];
    [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    _tableView.hidden = NO;
    [_aiView stopAnimating];
    activityBackGround.hidden = YES;
    activityLab.hidden = YES;
    if (_dataArray.count == 1){
        UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 300)];
        tableFooterView.backgroundColor = LabColor(0.94, 0.94, 0.94);
        _tableView.tableFooterView = tableFooterView;
    }
    else if (_dataArray.count == 2){
        UIView *tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        tableFooterView.backgroundColor = LabColor(0.94, 0.94, 0.94);
        _tableView.tableFooterView = tableFooterView;
    }
    else if (_dataArray.count > 2) {
        [self loadDataEnd];
    }else{
        _tableView.tableFooterView = nil;
    }
}

-(void)categoryBtnClick:(UIButton *)btn{
    if (btn.tag == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            navline.frame = CGRectMake(0, 101, self.view.frame.size.width/3, 3);
            if (a.transform.a == -1) {
                a.transform = CGAffineTransformMakeRotation(M_PI*2);
            }else{
                a.transform = CGAffineTransformMakeRotation(M_PI);
                b.transform = CGAffineTransformMakeRotation(M_PI*2);
                c.transform = CGAffineTransformMakeRotation(M_PI*2);
            }
        } completion:^(BOOL finished) {
            if (categoryTable1.hidden == YES) {
                categoryTable1.hidden = NO;
                categoryTable2.hidden = YES;
                categoryTable3.hidden = YES;
            }else{
                categoryTable1.hidden = YES;
            }
        }];
    }
    else if (btn.tag == 2){
        [UIView animateWithDuration:0.3 animations:^{
            navline.frame = CGRectMake(self.view.frame.size.width/3, 101, self.view.frame.size.width/3, 3);
            if (b.transform.a == -1) {
                b.transform = CGAffineTransformMakeRotation(M_PI*2);
            }else{
                b.transform = CGAffineTransformMakeRotation(M_PI);
                c.transform = CGAffineTransformMakeRotation(M_PI*2);
                a.transform = CGAffineTransformMakeRotation(M_PI*2);
            }
        } completion:^(BOOL finished) {
            if (categoryTable2.hidden == YES) {
                categoryTable2.hidden = NO;
                categoryTable1.hidden = YES;
                categoryTable3.hidden = YES;
            }else{
                categoryTable2.hidden = YES;
            }
        }];
    }
    else if (btn.tag == 3){
        [UIView animateWithDuration:0.3 animations:^{
            navline.frame = CGRectMake(self.view.frame.size.width/3*2, 101, self.view.frame.size.width/3, 3);
            if (c.transform.a == -1) {
                c.transform = CGAffineTransformMakeRotation(M_PI*2);
            }else{
                c.transform = CGAffineTransformMakeRotation(M_PI);
                b.transform = CGAffineTransformMakeRotation(M_PI*2);
                a.transform = CGAffineTransformMakeRotation(M_PI*2);
            }
        } completion:^(BOOL finished) {
            if (categoryTable3.hidden == YES) {
                categoryTable3.hidden = NO;
                categoryTable2.hidden = YES;
                categoryTable1.hidden = YES;
            }else{
                categoryTable3.hidden = YES;
            }
            
        }];
    }
}

-(void)dingwei{
    MapViewController *mapView = [[MapViewController alloc]init];
    [self.navigationController pushViewController:mapView animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (categoryTable1.hidden == NO || categoryTable2.hidden == NO || categoryTable3.hidden == NO) {
        categoryTable1.hidden = YES;
        categoryTable2.hidden = YES;
        categoryTable3.hidden = YES;
    }
}

-(void)backtoView{
    if (_category == nil) {
        mainViewController *mview = [[mainViewController alloc]init];
        [self.navigationController pushViewController:mview animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)changeLanguage{
    activityBackGround.hidden=NO;
    activityLab.hidden=NO;
    [_aiView startAnimating];
    switch (_category.integerValue) {
        case 300:
            titleLab.text = GDLocalizedString(@"Dining");
            [_category1 setTitle:GDLocalizedString(@"Dining") forState:UIControlStateNormal];
            break;
        case 301:
            titleLab.text = GDLocalizedString(@"Nightlife");
            [_category1 setTitle:GDLocalizedString(@"Nightlife") forState:UIControlStateNormal];
            break;
        case 302:
            titleLab.text = GDLocalizedString(@"Health");
            [_category1 setTitle:GDLocalizedString(@"Health") forState:UIControlStateNormal];
            break;
        case 305:
            titleLab.text = GDLocalizedString(@"Shopping");
            [_category1 setTitle:GDLocalizedString(@"Shopping") forState:UIControlStateNormal];
            break;
        case 304:
            titleLab.text = GDLocalizedString(@"Lifestyle");
            [_category1 setTitle:GDLocalizedString(@"Lifestyle") forState:UIControlStateNormal];
            break;
        case 314:
            titleLab.text = GDLocalizedString(@"Travel");
            [_category1 setTitle:GDLocalizedString(@"Travel") forState:UIControlStateNormal];
            break;
        default:
            [_category1 setTitle:GDLocalizedString(@"ALL") forState:UIControlStateNormal];
            [_category3 setTitle:GDLocalizedString(@"Score") forState:UIControlStateNormal];
            break;
    }
    NSThread *listthread = [[NSThread alloc]initWithTarget:self selector:@selector(initListData) object:nil];
    [listthread start];
    NSThread *areathread = [[NSThread alloc]initWithTarget:self selector:@selector(initArea) object:nil];
    [areathread start];
    [categoryTable1 reloadData];
    [categoryTable3 reloadData];
    if (catestring3 !=-1) {
        switch (catestring3) {
            case 0:
            {
                [_category3 setTitle:GDLocalizedString(@"Score") forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                [_category3 setTitle:GDLocalizedString(@"Name") forState:UIControlStateNormal];
                break;
            }
            case 2:
            {
                [_category3 setTitle:GDLocalizedString(@"Distance") forState:UIControlStateNormal];
            }
                break;
            case 3:
            {
                [_category3 setTitle:GDLocalizedString(@"Price") forState:UIControlStateNormal];
            }
                break;
        }
    }else{
        [_category3 setTitle:GDLocalizedString(@"Sort") forState:UIControlStateNormal];
    }
    [_category3 setTitle:_category3.titleLabel.text forState:UIControlStateNormal];
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
