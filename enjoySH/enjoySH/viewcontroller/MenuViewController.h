//
//  MenuViewController.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/6/5.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableDictionary *dict;
@property (nonatomic,strong) NSString *clientId;

@end
