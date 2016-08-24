//
//  CommentDetailViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/6/10.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "GDLocalizableController.h"
#import <ShareSDK/ShareSDK.h>
#import "commentXml.h"
#import "UIImageView+WebCache.h"

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@interface CommentDetailViewController ()<UIActionSheetDelegate,ISSShareViewDelegate>{
    BOOL _loadingMore;
    UITableView *commenttableView;
    UIActivityIndicatorView *tableFooterActivityIndicator;
    int page;
    NSMutableArray *MoreDateArray;
}

@end

@implementation CommentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:LabColor(0.94, 0.94, 0.94)];
    [self initnav];
    [self initcommentTable];
    page = 0;
}

-(void)initnav{
    UIButton *right  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [right setExclusiveTouch:YES];
    [right setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
    [right addTarget:self action:@selector(fun:)forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIButton *back  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 12, 20)];
    [back setExclusiveTouch:YES];
    [back addTarget:self action:@selector(backtoView) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    UIBarButtonItem *backbar = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backbar;
    
    UIView *Statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [Statusview setBackgroundColor:LabColor(0.90,0,0)];
    [self.view addSubview:Statusview];
}

-(void)initcommentTable{
    commenttableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.bounds.size.height-64)];
    commenttableView.backgroundColor = [UIColor clearColor];
    commenttableView.dataSource = self;
    commenttableView.delegate = self;
    commenttableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self loadDataEnd];
    [self.view addSubview:commenttableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _commentArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    arr = [_commentArray objectAtIndex:indexPath.row];
    NSDictionary *dict1 = [[NSDictionary alloc]init];
    dict1 = [arr objectAtIndex:0];
    NSDictionary *dict2 = [[NSDictionary alloc]init];
    dict2 = [arr objectAtIndex:2];
    NSDictionary *dict3 = [[NSDictionary alloc]init];
    dict3 = [arr objectAtIndex:3];
    
    UIButton *commentSubView = [[UIButton alloc]init];
    commentSubView.backgroundColor = [UIColor whiteColor];
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 15, 60, 60)];
    icon.layer.cornerRadius = 20;
    [icon sd_setImageWithURL:[NSURL URLWithString:[dict2 objectForKey:@"iconx2"]] placeholderImage:[UIImage imageNamed:@"Avatar s"]];
    [commentSubView addSubview:icon];
    
    UILabel *name = [[UILabel alloc]initWithFrame:CGRectMake(80, 15, 200, 20)];
    name.font = [UIFont systemFontOfSize:13];
    name.text = [dict2 objectForKey:@"name"];
    [commentSubView addSubview:name];
    
    UILabel *commentText = [[UILabel alloc]initWithFrame:CGRectMake(80, 35, self.view.frame.size.width-120, 60)];
    commentText.font = [UIFont systemFontOfSize:12];
    commentText.textColor = LabColor(0.33, 0.33, 0.33);
    commentText.lineBreakMode = NSLineBreakByWordWrapping;
    commentText.numberOfLines = 0;
    commentText.text = [dict1 objectForKey:@"comment"];
    CGRect commentTextRect = [commentText.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-120, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:commentText.font} context:nil];
    commentText.frame = CGRectMake(80, 35, commentTextRect.size.width, commentTextRect.size.height);
    [commentSubView addSubview:commentText];
    
    NSInteger starvalue = floorf([[dict3 objectForKey:@"overall"] floatValue]+0.5);
    for (NSInteger i=0; i<starvalue; i++) {
        UIImageView *star = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star"]];
        CGRect _frame = CGRectMake(80+i*10+i*5, 40+commentTextRect.size.height, 12, 12);
        star.frame = _frame;
        [commentSubView addSubview:star];
    }
    
    UILabel *time = [[UILabel alloc]init];
    time.textColor = [UIColor grayColor];
    time.font = [UIFont systemFontOfSize:12];
    time.textAlignment = NSTextAlignmentRight;
    time.text = [self countTime:[dict2 objectForKey:@"datetime"]];
    CGRect timeRect = [time.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:time.font} context:nil];
    time.frame = CGRectMake(self.view.frame.size.width-timeRect.size.width-40, 40+commentTextRect.size.height-1, timeRect.size.width, timeRect.size.height);
    UIImageView *clock = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"time"]];
    clock.frame = CGRectMake(time.frame.origin.x-14, 40+commentTextRect.size.height, 12, 12);
    [commentSubView addSubview:clock];
    [commentSubView addSubview:time];
    
    
    if (clock.frame.origin.y+clock.frame.size.height+15<90) {
        commentSubView.frame = CGRectMake(0, 0, self.view.frame.size.width, 90);
    }else{
        commentSubView.frame = CGRectMake(0, 0, self.view.frame.size.width, clock.frame.origin.y+clock.frame.size.height+15);
    }
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(10, commentSubView.frame.size.height-1, self.view.frame.size.width-20, 1)];
    line.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [commentSubView addSubview:line];
    [cell addSubview:commentSubView];
    CGRect cellFrame = cell.frame;
    cellFrame.size.height = commentSubView.frame.size.height;
    cell.frame = cellFrame;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
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
        [commenttableView.tableFooterView addSubview:tableFooterActivityIndicator];
        [self loadDataing];
    }
}

-(void)loadDataing{
    page++;
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(initMoreListData) object:nil];
    [thread start];
}

-(void)initMoreListData{
    commentXml *parser = [commentXml alloc];
    NSString *string2;
    string2 = [NSString stringWithFormat:@"http://app.enjoylist.com/reviews.asp?id=%@&start=%li",_clientId,(long)page];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string2 = [string2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [parser StartParse:string2];
    MoreDateArray = parser.dataArray;
    if(MoreDateArray.count != 0){
        [self performSelectorOnMainThread:@selector(loadMoreListTable) withObject:nil waitUntilDone:NO];
    }else if(MoreDateArray.count == 0){
        commenttableView.tableFooterView = nil;
        _loadingMore = NO;
        [tableFooterActivityIndicator stopAnimating];
    }
}

-(void)loadMoreListTable{
    [_commentArray addObjectsFromArray:MoreDateArray];
    [commenttableView reloadData];
    [self loadDataEnd];
}

-(void)loadDataEnd{
    _loadingMore = NO;
    [self createTableFooter];
}

-(void)createTableFooter{
    commenttableView.tableFooterView = nil;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, commenttableView.bounds.size.width, 40.0f)];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 180, 40.0)];
    [loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setFont:[UIFont systemFontOfSize:14]];
    [loadMoreText setTextAlignment:NSTextAlignmentCenter];
    [loadMoreText setText:GDLocalizedString(@"Pull up to show more data")];
    [tableFooterView addSubview:loadMoreText];
    commenttableView.tableFooterView = tableFooterView;
}

-(void)fun:(UIButton *)btn{
    id<ISSContent> publishContent = [ShareSDK content:nil defaultContent:[_dict objectForKey:@"excerpt"] image:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]title:[_dict objectForKey:@"name"] url:[_dict objectForKey:@"sharelink"]description:[_dict objectForKey:@"description"] mediaType:SSPublishContentMediaTypeImage];
    [publishContent addSinaWeiboUnitWithContent:[NSString stringWithFormat:@"%@\n%@",[_dict objectForKey:@"name"],[_dict objectForKey:@"excerpt"]] image:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]];
    //定制微信好友信息
    NSString *sharelink = [[_dict objectForKey:@"sharelink"] stringByAppendingString:@"?"];
    //微信好友分享
    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:2]
                                         content:[_dict objectForKey:@"description"]
                                           title:[_dict objectForKey:@"name"]
                                             url:sharelink
                                      thumbImage:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]
                                           image:INHERIT_VALUE
                                    musicFileUrl:nil
                                         extInfo:[_dict objectForKey:@"excerpt"]
                                        fileData:nil
                                    emoticonData:nil];
    //朋友圈分享
    [publishContent addWeixinTimelineUnitWithType:[NSNumber numberWithInt:2]
                                          content:[_dict objectForKey:@"description"]
                                            title:[NSString stringWithFormat:@"%@\n%@",[_dict objectForKey:@"name"],[_dict objectForKey:@"excerpt"]]
                                              url:sharelink
                                       thumbImage:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]
                                            image:INHERIT_VALUE
                                     musicFileUrl:nil
                                          extInfo:nil
                                         fileData:nil
                                     emoticonData:nil];
    //qq分享
    [publishContent addQQUnitWithType:[NSNumber numberWithInt:2]
                              content:[_dict objectForKey:@"description"]
                                title:[NSString stringWithFormat:@"%@\n%@",[_dict objectForKey:@"name"],[_dict objectForKey:@"excerpt"]]
                                  url:sharelink
                                image:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]];
    //facebook分享
    [publishContent addFacebookWithContent:[NSString stringWithFormat:@"%@\n%@",[_dict objectForKey:@"name"],[_dict objectForKey:@"excerpt"]] image:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]];
    //twitter
    [publishContent addTwitterWithContent:[NSString stringWithFormat:@"%@\n%@",[_dict objectForKey:@"name"],[_dict objectForKey:@"excerpt"]] image:[ShareSDK imageWithUrl:[_dict objectForKey:@"picx2"]]];
    //短信
    [publishContent addSMSUnitWithContent:[NSString stringWithFormat:@"ClientName:%@,ClientUrl:%@",[_dict objectForKey:@"name"],sharelink]];
    //mail
    [publishContent addMailUnitWithSubject:@"enjoyShangHai" content:[NSString stringWithFormat:@"ClientName%@\nExcerpt%@\nUrl:%@",[_dict objectForKey:@"name"],[_dict objectForKey:@"excerpt"],sharelink] isHTML:[NSNumber numberWithInt:1] attachments:nil to:nil cc:nil bcc:nil];
    //2.调用分享菜单分享
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:btn arrowDirect:UIPopoverArrowDirectionUp];
    
    //自定义标题栏相关委托
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    //自定义标题栏相关委托
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:@"Share"
                                                              oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                               qqButtonHidden:YES
                                                        wxSessionButtonHidden:YES
                                                       wxTimelineButtonHidden:YES
                                                         showKeyboardOnAppear:NO
                                                            shareViewDelegate:self
                                                          friendsViewDelegate:nil
                                                        picViewerViewDelegate:nil];
    
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeSinaWeibo,ShareTypeFacebook,ShareTypeTwitter,ShareTypeWeixiSession,ShareTypeWeixiTimeline,ShareTypeQQ,ShareTypeMail,ShareTypeSMS, nil];
    [ShareSDK showShareActionSheet:container shareList:shareList content:publishContent statusBarTips:YES authOptions:authOptions shareOptions:shareOptions result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
        //如果分享成功
        if (state == SSResponseStateSuccess) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit") message:GDLocalizedString(@"Success to publish") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil];
            [alert show];
        }
        //如果分享失败
        if (state == SSResponseStateFail) {
            NSString *info = [GDLocalizedString(@"Failed to publish") stringByAppendingString:[NSString stringWithFormat:@"%@",[error errorDescription]]];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit") message:info delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil];
            [alert show];
        }
    }];
}

-(void)backtoView{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)countTime:(NSString *)str{
    NSDateFormatter *severDate = [[NSDateFormatter alloc]init];
    [severDate setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
    NSDate *d=[severDate dateFromString:str];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late+2*3600;
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[[NSString stringWithFormat:@"%@", timeString] stringByAppendingString:GDLocalizedString(@"minutes ago")];
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=  [[NSString stringWithFormat:@"%@", timeString] stringByAppendingString:GDLocalizedString(@"hours ago")];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[[NSString stringWithFormat:@"%@", timeString] stringByAppendingString:GDLocalizedString(@"days ago")];
    }
    return timeString;
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
