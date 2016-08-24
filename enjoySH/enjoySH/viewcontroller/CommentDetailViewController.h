//
//  CommentDetailViewController.h
//  enjoySH
//
//  Created by 陈栋楠 on 15/6/10.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentDetailViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *commentArray;
@property (nonatomic,strong) NSMutableDictionary *dict;
@property (nonatomic,strong) NSString *clientId;

@end
