//
//  CustomCalloutView.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-22.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "CustomCalloutView.h"
#import <MapKit/MapKit.h>
#import "GDLocalizableController.h"

#define kArrorHeight        10

@interface CustomCalloutView()

@property (nonatomic, strong) UIButton *routeBtn2;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *Detail;

@end

@implementation CustomCalloutView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
#define kPortraitMargin 5
#define kPortraitWidth 200
#define kPortraitHeight 50
#define kTitleWidth         150
#define kTitleHeight        20
    // 添加图⽚片
    /*self.portraitView = [[UIImageView alloc] initWithFrame:CGRectMake(kPortraitMargin, kPortraitMargin, kPortraitWidth, kPortraitHeight)];
    self.portraitView.backgroundColor = [UIColor blackColor];
    self.portraitView.tag = 1;
    [self addSubview:self.portraitView];*/
    // 添加标题
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin*2, kPortraitMargin+2, kTitleWidth, kTitleHeight)];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = @"titletitletitletitle";
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.numberOfLines = 1;
    [self addSubview:self.titleLabel];
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPortraitMargin*2, kTitleHeight+kPortraitMargin-2, kTitleWidth, kTitleHeight)];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12];
    self.subtitleLabel.textColor = [UIColor lightGrayColor];
    self.subtitleLabel.text = @"subtitleLabelsubtitleLabelsubtitleLabel";
    self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.subtitleLabel.numberOfLines = 1;
    [self addSubview:self.subtitleLabel];
    
    _Detail = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kTitleWidth, kPortraitHeight)];
    _Detail.tag = 0;
    [_Detail addTarget:self action:@selector(goDetail:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_Detail];
    
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(kPortraitMargin*2+kTitleWidth+5, kPortraitMargin, 1, 40)];
    line.image = [UIImage imageNamed:@"call_line"];
    [self addSubview:line];
    
    _routeBtn2 = [[UIButton alloc]initWithFrame:CGRectMake(kPortraitMargin*2+kTitleWidth+11, 14.5, 21, 21)];
    [_routeBtn2 setBackgroundImage:[UIImage imageNamed:@"routeRed"] forState:UIControlStateNormal];
    [_routeBtn2 addTarget:self action:@selector(daohang) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.routeBtn2];
    
}

-(void)goDetail:(UIButton *)btn{
    NSString *btnflag = [NSString stringWithFormat:@"%li",(long)btn.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"goDetail" object:btnflag];
}

-(void)daohang{
    if(_routeBtn2.tag<0){
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Choose a client") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [alter show];
    }else{
        CLLocationCoordinate2D coords2 = CLLocationCoordinate2DMake(_lng, _lat);
        MKMapItem *mapitem1 = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *mapitem2 = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:coords2 addressDictionary:nil]];
        NSDictionary *options=@{MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
        [MKMapItem openMapsWithItems:@[mapitem1,mapitem2] launchOptions:options];
        _routeBtn2.tag = -1;
    }
}

#pragma mark - Override
- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}
- (void)setSubtitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
}

-(void)setBtnTag:(int)BtnTag{
    _Detail.tag = BtnTag;
}

#pragma mark - draw rect
- (void)drawRect:(CGRect)rect
{
    [self drawInContext:UIGraphicsGetCurrentContext()];
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
}
- (void)drawInContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    [self getDrawPath:context];
    CGContextFillPath(context);
}
- (void)getDrawPath:(CGContextRef)context
{
    
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-kArrorHeight;
    CGContextMoveToPoint(context, midx+kArrorHeight, maxy);
    CGContextAddLineToPoint(context,midx, maxy+kArrorHeight);
    CGContextAddLineToPoint(context,midx-kArrorHeight, maxy);
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

@end
