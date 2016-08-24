//
//  mainViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/1.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "mainViewController.h"
#import "GDLocalizableController.h"
#import "MapViewController.h"
#import "ListViewController.h"
#import "FavoriteViewController.h"
#import "SlideNavigationController.h"
#import "homebannerXml.h"
#import "UIImageView+WebCache.h"

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义


@interface mainViewController (){
    NSTimer *timer;
    UIScrollView *_scrollView;
    UIPageControl *pageControl;
    UIScrollView *contentView;
    UIView *Statusview;
    UIImageView *shadow;
    UILabel *lbfornb;
    UILabel *lbforfav;
    UILabel *lbforpop;
    UILabel *dining;
    UILabel *nightlife;
    UILabel *live;
    UILabel *shopping;
    UILabel *travel;
    UILabel *health;
    NSMutableArray *photoarry;
    NSString *scroflag;
    UIImageView *shadow2;
    UIView *midview;
    UIImageView *loadImageView;
}

@end

@implementation mainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    [self initnav];
    [self initscrollView];
    [self initMidBtn];
    [self initMenu];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(loadpic) object:nil];
    [thread start];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLocate" object:nil];
    [self addTimer];
}

-(void)loadpic{
    homebannerXml *homebanner = [[homebannerXml alloc]init];
    NSString *string = @"http://app.enjoylist.com/homebanner.asp";
    [homebanner StartParse:string];
    photoarry = homebanner.dataArray;
    if (photoarry.count!=0) {
        [self performSelectorOnMainThread:@selector(loadclientpic) withObject:nil waitUntilDone:NO];
    }
}

-(void)loadclientpic{
    CGFloat imageW = _scrollView.frame.size.width;
    int tag;
    NSDictionary *dict = [[NSDictionary alloc]init];
    if (photoarry!=nil) {
        dict = [photoarry objectAtIndex:0];
        for (int i = 0; i < [dict count]; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            CGFloat imageX = i * imageW;
            imageView.frame = CGRectMake(imageX, 0, imageW, self.view.frame.size.width*3/4);
            [imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:[NSString stringWithFormat:@"banner%i",i]]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [loadImageView removeFromSuperview];
            }];
            imageView.tag = 10+tag;
            tag++;
            [_scrollView addSubview:imageView];
        }
        [_scrollView setContentSize:CGSizeMake(CGRectGetWidth(_scrollView.frame)*([dict count]), 0)];
        pageControl.numberOfPages = [dict count];
    }
}

-(void)initnav{
    UIButton *right  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [right setExclusiveTouch:YES];
    [right setImage:[UIImage imageNamed:@"nearbywhite"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(dingweiBtnClick:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIButton *left  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [left setExclusiveTouch:YES];
    [left setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [left addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:left];
    [SlideNavigationController sharedInstance].leftBarButtonItem = leftBarButtonItem;
}

-(void)initscrollView{
    CGFloat Phonewidth = self.view.frame.size.width;
    CGFloat Phoneheight = self.view.frame.size.height;

    contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -64, Phonewidth, Phoneheight+64)];
    contentView.delegate = self;
    contentView.bounces = YES;
    contentView.tag = 0;
    [self.view addSubview:contentView];
    
    Statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    Statusview.backgroundColor = LabColor(0.90, 0, 0);
    [self.view addSubview:Statusview];
    
    shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 10)];
    shadow.image = [UIImage imageNamed:@"Shadow 3"];
    shadow.hidden = YES;
    [self.view addSubview:shadow];
    
    shadow2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    shadow2.image = [UIImage imageNamed:@"Shadow 1"];
    [self.view addSubview:shadow2];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -Phonewidth*0.055, Phonewidth, Phonewidth*0.75)];
    [_scrollView setPagingEnabled:YES];
    _scrollView.tag = 1;
    [_scrollView setBounces:NO];
    [_scrollView setDelegate:self];
    [contentView addSubview:_scrollView];
    
    pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _scrollView.frame.origin.y+_scrollView.frame.size.height-20-Phonewidth*0.055, Phonewidth, 20)];
    pageControl.currentPage = 0;
    [contentView addSubview:pageControl];
    
    loadImageView = [[UIImageView alloc]init];
    loadImageView.frame = CGRectMake(0, 0, 32, 32);
    loadImageView.center = _scrollView.center;
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
    [_scrollView addSubview:loadImageView];
}

-(void)initMidBtn{
    CGFloat Phonewidth = self.view.frame.size.width;
    midview = [[UIView alloc]initWithFrame:CGRectMake(0, _scrollView.frame.origin.y+_scrollView.frame.size.height-Phonewidth*0.055, self.view.frame.size.width, 125)];
    midview.backgroundColor = [UIColor whiteColor];
    [contentView addSubview:midview];
    UIButton *popular = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/3-70, 24, 60, 60)];
    popular.layer.cornerRadius = 30;
    popular.layer.masksToBounds = YES;
    [popular setBackgroundImage:[UIImage imageNamed:@"Popular"] forState:UIControlStateNormal];
    popular.tag = 1;
    [popular setExclusiveTouch:YES];
    [popular addTarget:self action:@selector(mid:) forControlEvents:UIControlEventTouchUpInside];
    [midview addSubview:popular];
    
    lbforpop = [[UILabel alloc]initWithFrame:CGRectMake(popular.frame.origin.x-10, 88, 80, 12)];
    lbforpop.textAlignment = NSTextAlignmentCenter;
    lbforpop.font = [UIFont systemFontOfSize:12];
    lbforpop.text = GDLocalizedString(@"POPULAR2");
    [midview addSubview:lbforpop];
    
    UIButton *favorites = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/2-30, 24, 60, 60)];
    favorites.layer.cornerRadius = 30;
    favorites.layer.masksToBounds = YES;
    [favorites setBackgroundImage:[UIImage imageNamed:@"Favorites"] forState:UIControlStateNormal];
    favorites.tag = 2;
    [favorites setExclusiveTouch:YES];
    [favorites addTarget:self action:@selector(mid:) forControlEvents:UIControlEventTouchUpInside];
    [midview addSubview:favorites];
    
    lbforfav = [[UILabel alloc]initWithFrame:CGRectMake(favorites.frame.origin.x-10, 88, 80, 12)];
    lbforfav.textAlignment = NSTextAlignmentCenter;
    lbforfav.font = [UIFont systemFontOfSize:12];
    lbforfav.text = GDLocalizedString(@"FAVORITES2");
    [midview addSubview:lbforfav];
    
    UIButton *nearby = [[UIButton alloc]initWithFrame:CGRectMake(Phonewidth/3*2+10,24, 60, 60)];
    nearby.layer.cornerRadius = 30;
    nearby.layer.masksToBounds = YES;
    [nearby setBackgroundImage:[UIImage imageNamed:@"Nearby"] forState:UIControlStateNormal];
    nearby.tag = 3;
    [nearby setExclusiveTouch:YES];
    [nearby addTarget:self action:@selector(mid:) forControlEvents:UIControlEventTouchUpInside];
    [midview addSubview:nearby];
    
    lbfornb = [[UILabel alloc]initWithFrame:CGRectMake(nearby.frame.origin.x-10,88, 80, 12)];
    lbfornb.textAlignment = NSTextAlignmentCenter;
    lbfornb.font = [UIFont systemFontOfSize:12];
    lbfornb.text = GDLocalizedString(@"NEARBY2");
    [midview addSubview:lbfornb];
}

-(void)initMenu{
    CGFloat Phonewidth = self.view.frame.size.width;
    
    UIView *menuView = [[UIView alloc]initWithFrame:CGRectMake(10, _scrollView.frame.origin.y+_scrollView.frame.size.height+125-Phonewidth*0.055, Phonewidth-20, ((Phonewidth-20)/2-5+30)*3)];
    CGFloat menuViewWidth = menuView.frame.size.width;
    [contentView addSubview:menuView];
    
    UIView *diningView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, menuViewWidth/2-4, menuViewWidth/2-5+30)];
    [menuView addSubview:diningView];
    UIButton *diningImageView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, diningView.frame.size.width, diningView.frame.size.width)];
    [diningImageView setBackgroundImage:[UIImage imageNamed:@"dining"] forState:UIControlStateNormal];
    diningImageView.tag = 1;
    [diningImageView setExclusiveTouch:YES];
    [diningImageView addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *diningLabView = [[UIView alloc]initWithFrame:CGRectMake(0, diningView.frame.size.width, diningView.frame.size.width, 30)];
    UIColor *diningColor = LabColor(0.90,0,0);
    diningLabView.backgroundColor = diningColor;
    dining = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 100, 16)];
    dining.text = GDLocalizedString(@"DINING");
    dining.textColor = [UIColor whiteColor];
    dining.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    dining.backgroundColor = diningColor;
    diningLabView.contentMode = UIControlContentVerticalAlignmentCenter;
    UIButton *diningButton = [[UIButton alloc]initWithFrame:CGRectMake(diningLabView.frame.size.width-18, 7.5, 5, 15)];
    [diningButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [diningButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    diningButton.tag = 1;
    [diningLabView addSubview:diningButton];
    [diningLabView addSubview:dining];
    [diningView addSubview:diningLabView];
    [diningView addSubview:diningImageView];
    
    UIView *nightlifeView = [[UIView alloc]initWithFrame:CGRectMake(menuViewWidth/2+4, 0, menuViewWidth/2-5, menuViewWidth/2-5+30)];
    [menuView addSubview:nightlifeView];
    UIButton *nightlifeImageView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, nightlifeView.frame.size.width, nightlifeView.frame.size.width)];
    [nightlifeImageView setBackgroundImage:[UIImage imageNamed:@"nightlife"] forState:UIControlStateNormal];
    nightlifeImageView.tag = 2;
    [nightlifeImageView setExclusiveTouch:YES];
    [nightlifeImageView addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *nightlifeLabView = [[UIView alloc]initWithFrame:CGRectMake(0, nightlifeView.frame.size.width, nightlifeView.frame.size.width, 30)];
    UIColor *nightlifeColor = LabColor(0.96, 0.52, 0.11);
    nightlifeLabView.backgroundColor = nightlifeColor;
    nightlife = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 100, 16)];
    nightlife.text = GDLocalizedString(@"NIGHTLIFE");
    nightlife.textColor = [UIColor whiteColor];
    nightlife.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    nightlife.backgroundColor = nightlifeColor;
    nightlifeLabView.contentMode = UIControlContentVerticalAlignmentCenter;
    UIButton *nightlifeButton = [[UIButton alloc]initWithFrame:CGRectMake(nightlifeLabView.frame.size.width-18, 7.5, 5, 15)];
    nightlifeButton.tag = 2;
    [nightlifeButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [nightlifeButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [nightlifeLabView addSubview:nightlifeButton];
    [nightlifeLabView addSubview:nightlife];
    [nightlifeView addSubview:nightlifeLabView];
    [nightlifeView addSubview:nightlifeImageView];
    
    UIView *healthView = [[UIView alloc]initWithFrame:CGRectMake(0, menuViewWidth/2-5+40, menuViewWidth/2-4, menuViewWidth/2-5+30)];
    [menuView addSubview:healthView];
    UIButton *healImageView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, healthView.frame.size.width, healthView.frame.size.width)];
    [healImageView setBackgroundImage:[UIImage imageNamed:@"health"] forState:UIControlStateNormal];
    healImageView.tag = 3;
    [healImageView setExclusiveTouch:YES];
    [healImageView addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *healthLabView = [[UIView alloc]initWithFrame:CGRectMake(0, healthView.frame.size.width, healthView.frame.size.width, 30)];
    UIColor *healthColor = LabColor(0.49, 0.54, 0.91);
    healthLabView.backgroundColor = healthColor;
    health = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 100, 16)];
    health.text = GDLocalizedString(@"HEALTH");
    health.textColor = [UIColor whiteColor];
    health.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    health.backgroundColor = healthColor;
    healthLabView.contentMode = UIControlContentVerticalAlignmentCenter;
    UIButton *healthButton = [[UIButton alloc]initWithFrame:CGRectMake(healthLabView.frame.size.width-18, 7.5, 5, 15)];
    [healthButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    healthButton.tag = 3;
    [healthButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [healthLabView addSubview:healthButton];
    [healthLabView addSubview:health];
    [healthView addSubview:healthLabView];
    [healthView addSubview:healImageView];
    
    UIView *shoppingView = [[UIView alloc]initWithFrame:CGRectMake(menuViewWidth/2+4, menuViewWidth/2-5+40, menuViewWidth/2-5, menuViewWidth/2-5+30)];
    [menuView addSubview:shoppingView];
    UIButton *shoppingImageView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, shoppingView.frame.size.width, shoppingView.frame.size.width)];
    [shoppingImageView setBackgroundImage:[UIImage imageNamed:@"shopping"] forState:UIControlStateNormal];
    shoppingImageView.tag = 4;
    [shoppingImageView setExclusiveTouch:YES];
    [shoppingImageView addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *shoppingLabView = [[UIView alloc]initWithFrame:CGRectMake(0, shoppingView.frame.size.width, shoppingView.frame.size.width, 30)];
    UIColor *shoppingColor = LabColor(0, 0.75, 0.82);
    shoppingLabView.backgroundColor = shoppingColor;
    shopping = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 100, 16)];
    shopping.text = GDLocalizedString(@"SHOPPING");
    shopping.textColor = [UIColor whiteColor];
    shopping.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    shopping.backgroundColor = shoppingColor;
    shoppingLabView.contentMode = UIControlContentVerticalAlignmentCenter;
    UIButton *shoppingButton = [[UIButton alloc]initWithFrame:CGRectMake(shoppingLabView.frame.size.width-18, 7.5, 5, 15)];
    [shoppingButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    shoppingButton.tag = 4;
    [shoppingButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [shoppingLabView addSubview:shoppingButton];
    [shoppingLabView addSubview:shopping];
    [shoppingView addSubview:shoppingLabView];
    [shoppingView addSubview:shoppingImageView];
    
    UIView *liveView = [[UIView alloc]initWithFrame:CGRectMake(0, (menuViewWidth/2-5+40)*2, menuViewWidth/2-4, menuViewWidth/2-5+30)];
    [menuView addSubview:liveView];
    UIButton *liveImageView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, liveView.frame.size.width, liveView.frame.size.width)];
    [liveImageView setBackgroundImage:[UIImage imageNamed:@"life"] forState:UIControlStateNormal];
    liveImageView.tag = 5;
    [liveImageView setExclusiveTouch:YES];
    [liveImageView addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *liveLabView = [[UIView alloc]initWithFrame:CGRectMake(0, liveView.frame.size.width, liveView.frame.size.width, 30)];
    UIColor *liveColor = LabColor(0.91, 0.45, 0.69);
    liveLabView.backgroundColor = liveColor;
    live = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 100, 16)];
    live.text = GDLocalizedString(@"LIFESTYLE");
    live.textColor = [UIColor whiteColor];
    live.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    live.backgroundColor = liveColor;
    liveLabView.contentMode = UIControlContentVerticalAlignmentCenter;
    UIButton *liveButton = [[UIButton alloc]initWithFrame:CGRectMake(liveLabView.frame.size.width-18, 7.5, 5, 15)];
    [liveButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    liveButton.tag = 5;
    [liveButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [liveLabView addSubview:liveButton];
    [liveLabView addSubview:live];
    [liveView addSubview:liveLabView];
    [liveView addSubview:liveImageView];
    
    UIView *travelView = [[UIView alloc]initWithFrame:CGRectMake(menuViewWidth/2+4, (menuViewWidth/2-5+40)*2, menuViewWidth/2-5, menuViewWidth/2-5+30)];
    [menuView addSubview:travelView];
    UIButton *travelImageView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, travelView.frame.size.width, travelView.frame.size.width)];
    [travelImageView setBackgroundImage:[UIImage imageNamed:@"travel"] forState:UIControlStateNormal];
    travelImageView.tag = 6;
    [travelImageView setExclusiveTouch:YES];
    [travelImageView addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *travelLabView = [[UIView alloc]initWithFrame:CGRectMake(0, travelView.frame.size.width, travelView.frame.size.width, 30)];
    UIColor *travelColor = LabColor(0.52, 0.78, 0.33);
    travelLabView.backgroundColor = travelColor;
    travel = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 100, 16)];
    travel.text = GDLocalizedString(@"TRAVEL");
    travel.textColor = [UIColor whiteColor];
    travel.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:14];
    travel.backgroundColor = travelColor;
    UIButton *travelButton = [[UIButton alloc]initWithFrame:CGRectMake(travelLabView.frame.size.width-18, 7.5, 5, 15)];
    [travelButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    travelButton.tag = 6;
    [travelButton addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [travelLabView addSubview:travelButton];
    [travelLabView addSubview:travel];
    [travelView addSubview:travelLabView];
    [travelView addSubview:travelImageView];
    [contentView setContentSize:CGSizeMake(0, menuView.frame.origin.y+menuView.frame.size.height+30)];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView2{
    if (scrollView2.tag == 1) {
        [timer invalidate];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.tag == 1) {
        [self addTimer];
    }else if (scrollView.tag == 0) {
        if (scrollView.contentOffset.y < -64) {
            [UIView animateWithDuration:0.3 animations:^{
                [scrollView setContentOffset:CGPointMake(0, -64)];
            }];
        }
    }
}

- (void)addTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
- (void)nextImage
{
    int page = (int)pageControl.currentPage;
    if (page == 2) {
        page = 0;
    }else
    {
        page++;
    }
    CGFloat x = page * _scrollView.frame.size.width;
    [UIView animateWithDuration:1 animations:^{
        _scrollView.contentOffset = CGPointMake(x, 0);
    }];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 0) {
        if(scrollView.contentOffset.y > midview.frame.origin.y-128){
            shadow.hidden = NO;
            shadow2.alpha = 0;
            Statusview.alpha = 1;
        }else if(scrollView.contentOffset.y <= midview.frame.origin.y-128){
            shadow2.alpha = (midview.frame.origin.y-64-scrollView.contentOffset.y-64)/(midview.frame.origin.y-64);
            Statusview.alpha =  ((scrollView.contentOffset.y+64)/(midview.frame.origin.y-64));
            shadow.hidden = YES;
            if ([scroflag isEqualToString:@"1"]) {
                [self addTimer];
                scroflag = @"0";
                CGRect frame = _scrollView.frame;
                frame.origin.y = -self.view.frame.size.width*0.055;
                frame.size.height = self.view.frame.size.width*0.75;
                _scrollView.frame = frame;
            }
            if (scrollView.contentOffset.y < -64){
                [timer invalidate];
                scroflag = @"1";
                CGRect frame = _scrollView.frame;
                frame.origin.y = -self.view.frame.size.width*0.055+(scrollView.contentOffset.y+64)/2;
                frame.size.height = self.view.frame.size.width*0.75+ABS(scrollView.contentOffset.y+64);
                _scrollView.frame = frame;
                if(scrollView.contentOffset.y <-64-self.view.frame.size.width*0.11){
                    CGRect frame = _scrollView.frame;
                    frame.origin.y = -self.view.frame.size.width*0.11;
                    frame.size.height = self.view.frame.size.width*0.75;
                    _scrollView.frame = frame;
                }
            }
        }
    }else if (scrollView.tag == 1){
        CGFloat scrollViewW =  scrollView.frame.size.width;
        CGFloat x = scrollView.contentOffset.x;
        int page = (x + scrollViewW / 2) /  scrollViewW;
        pageControl.currentPage = page;
    }
}

-(void)dingweiBtnClick:(UIButton *)btn{
    MapViewController *mapView = [[MapViewController alloc]init];
    [self.navigationController pushViewController:mapView animated:YES];
}

-(void)mid:(UIButton *)btn{
    switch (btn.tag) {
        case 1:
        {
            ListViewController *lv = [[ListViewController alloc]init];
            [self.navigationController pushViewController:lv animated:YES];
        }
            break;
        case 2:
        {
            FavoriteViewController *fv = [[FavoriteViewController alloc]init];
            [self.navigationController pushViewController:fv animated:YES];
        }
            break;
        case 3:
        {
            MapViewController *mapView = [[MapViewController alloc]init];
            [self.navigationController pushViewController:mapView animated:YES];
        }
            break;
            
        default:
            break;
    }
}

-(void)menuBtnClick:(UIButton *)btn{
    ListViewController *listView = [[ListViewController alloc]init];
    if (btn.tag == 1) {
       listView.category = @"300";
    }
    else if (btn.tag == 2){
       listView.category = @"301";
    }
    else if (btn.tag == 3){
       listView.category = @"302";
    }
    else if (btn.tag == 4){
       listView.category = @"305";
    }
    else if (btn.tag == 5){
       listView.category = @"304";
    }
    else if (btn.tag == 6){
       listView.category = @"314";
    }
    [self.navigationController pushViewController:listView animated:YES];
}

-(void)changeLanguage{
    lbforpop.text = GDLocalizedString(@"POPULAR2");
    lbforfav.text = GDLocalizedString(@"FAVORITES2");
    lbfornb.text = GDLocalizedString(@"NEARBY2");
    dining.text = GDLocalizedString(@"DINING");
    nightlife.text = GDLocalizedString(@"NIGHTLIFE");
    shopping.text = GDLocalizedString(@"SHOPPING");
    health.text = GDLocalizedString(@"HEALTH");
    travel.text = GDLocalizedString(@"TRAVEL");
    live.text = GDLocalizedString(@"LIFESTYLE");
    if (self.navigationController.childViewControllers.count==2) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changedLanguage" object:nil];
    }
}

@end
