//
//  CommentViewController.h
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-22.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQStarRatingView.h"

@interface CommentViewController : UIViewController<StarRatingViewDelegate,UITextViewDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) NSString *clientid;
@property (nonatomic,strong) NSString *locationId;

@end
