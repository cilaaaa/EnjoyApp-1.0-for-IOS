//
//  MenuViewController.m
//  enjoySH
//
//  Created by 陈栋楠 on 15/6/5.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "MenuViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "GDLocalizableController.h"
#import "MenuListData.h"

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@interface MenuViewController ()<UIActionSheetDelegate,ISSShareViewDelegate>{
    NSMutableArray *menuArray;
    UITableView *menuTableView;
    UILabel *menuHit;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:LabColor(0.95, 0.95, 0.95)];
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(runMenu) object:nil];
    [thread start];
    [self initnav];
    [self initMenuTable];
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

-(void)initMenuTable{
    menuTableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 74, self.view.frame.size.width-20, self.view.frame.size.height)];
    menuTableView.delegate = self;
    menuTableView.dataSource = self;
    menuTableView.tag =1;
    menuTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:menuTableView];
    
    menuHit = [[UILabel alloc]initWithFrame:CGRectMake(10, 74, self.view.frame.size.width-20, self.view.frame.size.height-74)];
    menuHit.text = GDLocalizedString(@"No menu");
    menuHit.hidden = YES;
    menuHit.textAlignment = NSTextAlignmentCenter;
    menuHit.textColor = LabColor(0.33,0.33,0.33);
    menuHit.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:menuHit];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [menuArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UILabel *menuName = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, cell.frame.size.width-80, 40)];
    menuName.numberOfLines = 0;
    menuName.lineBreakMode = NSLineBreakByWordWrapping;
    [cell.contentView addSubview:menuName];
    
    UILabel *menuPrice = [[UILabel alloc]init];
    menuPrice.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:menuPrice];
    if (menuArray!=nil) {
        NSDictionary *dict = [[NSDictionary alloc]init];
        dict = [menuArray objectAtIndex:indexPath.row];
        menuName.text = [dict objectForKey:@"menuName"];
        menuPrice.text = [dict objectForKey:@"price"];
        CGRect menuPriceRect = [menuPrice.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 40) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:menuPrice.font} context:nil];
        menuPrice.frame = CGRectMake(cell.frame.size.width-menuPriceRect.size.width-30, 0, menuPriceRect.size.width, menuPriceRect.size.height);
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)runMenu{
    menuArray = [[NSMutableArray alloc]init];
    MenuListData *menulistdata = [[MenuListData alloc]init];
    [menulistdata StartParse:[NSString stringWithFormat:@"http://app.enjoylist.com/menu.asp?cid=%@",_clientId]];
    menuArray = menulistdata.dataArray;
    if (menuArray!=nil) {
        [self performSelectorOnMainThread:@selector(reloadMenuTable) withObject:nil waitUntilDone:NO];
    }
}

-(void)reloadMenuTable{
    [menuTableView reloadData];
    if (menuArray.count == 0) {
        menuTableView.hidden = YES;
        menuHit.hidden = NO;
    }
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
