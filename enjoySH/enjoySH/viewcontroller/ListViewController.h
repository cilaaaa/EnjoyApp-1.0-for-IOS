//
//  diningViewController.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-13.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSString *category;

@end
