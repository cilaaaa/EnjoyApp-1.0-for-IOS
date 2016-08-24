//
//  LeftMenuViewController.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/4/7.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"


@interface LeftMenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate>


@property (nonatomic, assign) BOOL slideOutAnimationEnabled;


@end

