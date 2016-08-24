//
//  CustomAnnotationView.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-22.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "CustomAnnotationView.h"



@interface  CustomAnnotationView()

@property (nonatomic,strong ,readwrite) CustomCalloutView *calloutView;

@end

@implementation CustomAnnotationView

@synthesize calloutView = _calloutView;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    if (selected)
    {
        if (self.calloutView == nil)
        {
#define kCalloutWidth 200.0
#define kCalloutHeight 60.0
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, kCalloutWidth, kCalloutHeight)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                                  -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
        }
        self.calloutView.title = _anno.title;
        self.calloutView.subtitle = _anno.subtitle;
        self.calloutView.lng = _anno.lng;
        self.calloutView.BtnTag = _anno.tag;
        self.calloutView.lat = _anno.lat;
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    [super setSelected:selected animated:animated];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    return inside;
}

@end
