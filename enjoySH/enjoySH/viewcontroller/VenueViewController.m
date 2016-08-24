//
//  VenueViewController.m
//  enjoySH
//
//  Created by Chen Dongnan on 15-4-16.
//  Copyright (c) 2015年 陈栋楠. All rights reserved.
//

#import "VenueViewController.h"
#import "SHdetailXml.h"
#import "AddressXml.h"
#import "NewLoginViewController.h"
#import "GDLocalizableController.h"
#import <ShareSDK/ShareSDK.h>
#import "FMDB.h"
#import "commentXml.h"
#import "CommentViewController.h"
#import "CustomAnnotationView.h"
#import "MoreMapViewController.h"
#import "UIImageView+WebCache.h"
#import "voucherValid.h"
#import "cardPost.h"
#import "voucherPost.h"
#import "MenuViewController.h"
#import "CommentDetailViewController.h"
#import <MapKit/MapKit.h>

#define LabColor(r,g,b) [UIColor colorWithRed:r/1 green:g/1 blue:b/1 alpha:1] //颜色宏定义

@interface VenueViewController ()<ISSShareViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate,MKMapViewDelegate>{
    NSMutableArray *_dataArray;
    NSMutableDictionary *_dict;
    NSMutableArray *photoArray;
    UIView *Statusview;
    UIView *clientView;
    UIImageView *clientIcon;
    UILabel *clientName;
    UIView *clientdetailView;
    UILabel *excerpt;
    UILabel *pricelab;
    UIView *descriptionView;
    UILabel *descriptionText;
    UIView *detail;
    UILabel *busLab;
    UIActivityIndicatorView *loadData;
    UIView *bussinessTime;
    UIView *Btns;
    UIButton *offer;
    UIButton *reviews;
    UIButton *Location;
    UIScrollView *_scrollView;
    NSTimer *_timer;
    UIPageControl *_pageControl;
    UIScrollView *_contentView;
    UIImageView *_shadow;
    UIView *activityBackGround;
    UILabel *activityLab;
    UIView *navline;
    UIView *navlinebackground;
    UIView *offerview;
    UILabel *commentHit;
    UIView *commentView;
    UIView *locationView;
    NSMutableArray *commentArray;
    NSMutableArray *LocationArray;
    NSString *locationId;
    UILabel *DetailLine;
    UILabel *timeLine;
    NSString *xfFlag;
    UIButton *loginBtn;
    UILabel *userNumber;
    UIButton *discountBtn;
    UIButton *voucherBtn;
    NSString *scroflag;
    UIImageView *shadow2;
    UILabel *ExpireDate;
    UILabel *voucherLab;
    UIImageView *loadImageView;
    UILabel *discountLab;
}

@end

@implementation VenueViewController

-(void)cxvoucherValid{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *Id = [userDefaultes objectForKey:@"userId"];
    voucherValid *vValid = [[voucherValid alloc]init];
    [vValid StartParse:@"http://app.enjoylist.com/voucherValid.asp?" :[_dict objectForKey:@"id"] :[_dict objectForKey:@"voucherid"] :Id ];
    NSString *flag;
    if ([[vValid.dict objectForKey:@"voucherValid"] isEqualToString:@"1"]){
        flag = @"1";
        [self performSelectorOnMainThread:@selector(updateVoucherBtn:) withObject:flag waitUntilDone:NO];
    }else{
        flag = @"0";
        [self performSelectorOnMainThread:@selector(updateVoucherBtn:) withObject:flag waitUntilDone:NO];
    }
}

-(void)updateVoucherBtn:(NSString *)flag{
    [loadData stopAnimating];
    activityBackGround.hidden = YES;
    activityLab.hidden = YES;
    if ([flag isEqualToString:@"0"]){
        voucherLab.text = GDLocalizedString(@"NOT VALID");
        voucherBtn.enabled = NO;
        voucherBtn.alpha = 0.5;
    }else{
        voucherLab.text = GDLocalizedString(@"USEVOUCHER");
        voucherBtn.enabled = YES;
        voucherBtn.alpha = 1;
    }
    
}

-(void)havelogin{
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        if ([[userdefault objectForKey:@"flag"] isEqualToString:@"1"]) {
            loginBtn.hidden = YES;
            userNumber.text = [userdefault objectForKey:@"cardNumber"];
            userNumber.font = [UIFont boldSystemFontOfSize:30];
            ExpireDate.text = [userdefault objectForKey:@"validity"];
            NSThread *cxthread = [[NSThread alloc]initWithTarget:self selector:@selector(cxvoucherValid) object:nil];
            [loadData startAnimating];
            activityBackGround.hidden = NO;
            activityLab.hidden = NO;
            [cxthread start];
            if([_dict objectForKey:@"cardOffer"]!=nil){
                discountBtn.enabled = YES;
                discountBtn.alpha = 1;
            }
        }else{
            userNumber.text = GDLocalizedString(@"Please Login!");
            loginBtn.hidden = NO;
            voucherBtn.enabled = NO;
            voucherBtn.alpha = 0.5;
            discountBtn.alpha = 0.5;
            discountBtn.enabled = NO;
            userNumber.font = [UIFont boldSystemFontOfSize:18];
        }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:LabColor(0.95, 0.95, 0.95)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadLocate" object:nil];
    NSThread *COThread = [[NSThread alloc]initWithTarget:self selector:@selector(runComment) object:nil];
    [COThread start];
    NSThread *SHThread = [[NSThread alloc]initWithTarget:self selector:@selector(runData) object:nil];
    [SHThread start];
    NSThread *ADThread = [[NSThread alloc]initWithTarget:self selector:@selector(runData2) object:nil];
    [ADThread start];
    [self initnav];
    [self initView];
    [self initofferview];
    [self initCommentTable];
    [self initLocationScroll];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(havelogin) name:@"login" object:nil];
}

-(void)dealloc{
    _contentView.delegate = nil;
    
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
    [back addTarget:self action:@selector(backtoListView) forControlEvents:UIControlEventTouchUpInside];
    [back setBackgroundImage:[UIImage imageNamed:@"Back Arrow"] forState:UIControlStateNormal];
    UIBarButtonItem *backbar = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.navigationItem.leftBarButtonItem = backbar;
    self.navigationItem.leftBarButtonItem.enabled = NO;
}


-(void)initView{
    CGFloat Phonewidth = self.view.frame.size.width;
    CGFloat Phoneheight = self.view.frame.size.height;
    
    _contentView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -64, Phonewidth, Phoneheight+64)];
    _contentView.delegate = self;
    _contentView.bounces = YES;
    _contentView.tag = 0;
    [self.view addSubview:_contentView];
    
    Statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [Statusview setBackgroundColor:LabColor(0.90,0,0)];
    [self.view addSubview:Statusview];
    
    _shadow = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 10)];
    _shadow.image = [UIImage imageNamed:@"Shadow 3"];
    _shadow.hidden = YES;
    [self.view addSubview:_shadow];
    
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, -Phonewidth*0.055, Phonewidth, Phonewidth*0.75)];
    [_scrollView setBounces:NO];
    [_scrollView setDelegate:self];
    _scrollView.tag = 1;
    _scrollView.backgroundColor = [UIColor whiteColor];
    loadImageView = [[UIImageView alloc]init];
    loadImageView.frame = CGRectMake(Phonewidth/2-16, Phonewidth*0.375-16, 32, 32);
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
    _scrollView.pagingEnabled = YES;
    
    shadow2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    shadow2.image = [UIImage imageNamed:@"Shadow 1"];
    [self.view addSubview:shadow2];
    
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height+_scrollView.frame.origin.y-20-0.055*Phonewidth, self.view.frame.size.width, 20)];
    _pageControl.currentPage = 0;
    [_contentView addSubview:_pageControl];
    [_contentView addSubview:_scrollView];
    [_contentView bringSubviewToFront:_pageControl];
    
    clientView = [[UIView alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height+_scrollView.frame.origin.y-0.055*Phonewidth, Phonewidth, 100)];
    [clientView setBackgroundColor:[UIColor whiteColor]];
    [_contentView addSubview:clientView];
    
    UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(0, _scrollView.frame.size.height+_scrollView.frame.origin.y+100-0.055*Phonewidth, self.view.frame.size.width, 1)];
    line.backgroundColor = LabColor(0.82, 0.82, 0.82);
    [_contentView addSubview:line];
    
    clientdetailView = [[UIView alloc]init];
    [clientView addSubview:clientdetailView];
    
    clientIcon = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 80, 80)];
    clientIcon.contentMode = UIViewContentModeScaleToFill;
    [clientView addSubview:clientIcon];
    clientName = [[UILabel alloc]init];
    clientName.lineBreakMode = NSLineBreakByWordWrapping;
    clientName.numberOfLines = 0;
    clientName.font = [UIFont boldSystemFontOfSize:16];
    [clientdetailView addSubview:clientName];
    
    excerpt = [[UILabel alloc]initWithFrame:CGRectMake(125, 69, 135, 14)];
    excerpt.textAlignment = NSTextAlignmentNatural;
    excerpt.font = [UIFont systemFontOfSize:12];
    excerpt.textColor = [UIColor grayColor];
    excerpt.numberOfLines = 0;
    excerpt.lineBreakMode = NSLineBreakByWordWrapping;
    [clientdetailView addSubview:excerpt];
    
    pricelab = [[UILabel alloc]initWithFrame:CGRectMake(275, 69, 45, 14)];
    pricelab.textColor = [UIColor grayColor];
    pricelab.font = [UIFont systemFontOfSize:12];
    [clientdetailView addSubview:pricelab];
    
    descriptionView = [[UIView alloc]init];
    descriptionView.backgroundColor = [UIColor whiteColor];
    [_contentView addSubview:descriptionView];
    
    descriptionText = [[UILabel alloc]init];
    [descriptionText setNumberOfLines:0];
    descriptionText.font = [UIFont systemFontOfSize:13];
    descriptionText.textColor = LabColor(0.33, 0.33, 0.33);
    descriptionText.lineBreakMode = NSLineBreakByWordWrapping;
    [descriptionView addSubview:descriptionText];
    
    detail = [[UIView alloc]init];
    Btns = [[UIView alloc]init];
    
    offer = [[UIButton alloc]init];
    [offer setTitle:GDLocalizedString(@"Offer") forState:UIControlStateNormal];
    [offer setBackgroundColor:LabColor(0.90,0,0)];
    [offer setExclusiveTouch:YES];
    offer.titleLabel.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:13];
    offer.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    offer.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    offer.titleLabel.textAlignment = NSTextAlignmentCenter;
    offer.tag = 0;
    [offer addTarget:self action:@selector(detailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [Btns addSubview:offer];
    
    reviews = [[UIButton alloc]init];
    [reviews setTitle:GDLocalizedString(@"Reviews") forState:UIControlStateNormal];
    [reviews setBackgroundColor:LabColor(0.90,0,0)];
    [reviews setExclusiveTouch:YES];
    reviews.titleLabel.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:13];
    reviews.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    reviews.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    reviews.titleLabel.textAlignment = NSTextAlignmentCenter;
    reviews.tag = 1;
    [reviews addTarget:self action:@selector(detailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [Btns addSubview:reviews];
    
    Location = [[UIButton alloc]init];
    [Location setTitle:GDLocalizedString(@"Location") forState:UIControlStateNormal];
    [Location setBackgroundColor:LabColor(0.90,0,0)];
    Location.titleLabel.font = [UIFont fontWithName:@"ArialHebrew-Bold" size:13];
    Location.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    Location.contentEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    Location.titleLabel.textAlignment = NSTextAlignmentCenter;
    Location.tag = 2;
    [Location setExclusiveTouch:YES];
    [Location addTarget:self action:@selector(detailBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [Btns addSubview:Location];
    
    navlinebackground = [[UIView alloc]initWithFrame:CGRectMake(0, 46, self.view.frame.size.width-20, 4)];
    navlinebackground.backgroundColor = LabColor(0.68, 0, 0.09);
    [Btns addSubview:navlinebackground];
    
    navline = [[UIView alloc]initWithFrame:CGRectMake(0, 46, (self.view.frame.size.width-20)/3, 4)];
    navline.backgroundColor = [UIColor whiteColor];
    [Btns addSubview:navline];
    
    activityBackGround = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, (self.view.frame.size.height)/2-30, 100, 80)];
    activityBackGround.backgroundColor = [UIColor blackColor];
    activityBackGround.layer.cornerRadius = 10;
    activityBackGround.hidden = NO;
    [self.view addSubview:activityBackGround];
    
    activityLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-100)/2, self.view.frame.size.height/2+10, 100, 30)];
    activityLab.textAlignment = NSTextAlignmentCenter;
    activityLab.textColor = [UIColor whiteColor];
    activityLab.text = GDLocalizedString(@"LOAD");
    activityLab.hidden = NO;
    [self.view addSubview:activityLab];
    
    loadData = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadData.frame = CGRectMake(0, 0, Phonewidth, Phoneheight);
    loadData.hidesWhenStopped = YES;
    [loadData startAnimating];
    [self.view addSubview:loadData];
    [self.view bringSubviewToFront:loadData];
}

-(void)initofferview{
    offerview = [[UIView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width-20, 0)];
    [detail addSubview:offerview];
}

-(void)initCommentTable{
    commentView = [[UIView alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width-20, 0)];
    commentView.hidden = YES;
    commentView.backgroundColor = [UIColor whiteColor];
    [detail addSubview:commentView];
    
    commentHit = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height)];
    commentHit.text = GDLocalizedString(@"No comment");
    commentHit.hidden = YES;
    commentHit.textAlignment = NSTextAlignmentCenter;
    commentHit.textColor = LabColor(0.33,0.33,0.33);
    commentHit.font = [UIFont systemFontOfSize:15];
    [commentView addSubview:commentHit];
}

-(void)initLocationScroll{
    locationView = [[UIView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width-20, self.view.frame.size.height-180)];
    locationView.hidden = YES;
    [detail addSubview:locationView];
}

-(void)runData{
    SHdetailXml *parser = [SHdetailXml alloc];
    NSString *string1 = @"http://app.enjoylist.com/client.asp?cid=";
    NSString *string2 = [string1 stringByAppendingString:_clientid];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        string2 = [string2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [parser StartParse:string2];
    _dataArray = [[NSMutableArray alloc]init];
    _dataArray = parser.dataArray;
    photoArray = parser.dataArray2;
    if (_dataArray==nil) {
        [self performSelectorOnMainThread:@selector(netAlter) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(updateSHDetail) withObject:nil waitUntilDone:NO];
        [self performSelectorOnMainThread:@selector(loadclientpic) withObject:nil waitUntilDone:NO];
    }
}

-(void)netAlter{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Network Promblem!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    [alter show];
    [loadData stopAnimating];
    activityBackGround.hidden = YES;
    activityLab.hidden = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
}

-(void)updateSHDetail{
    if([_dataArray count]==0){
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"Hit"  message:@"This Client disappeared!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        alter.delegate = self;
        [alter show];
    }else{
        _dict = [_dataArray objectAtIndex:0];
        [clientIcon sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"picx2"]]];
        clientName.text = [_dict objectForKey:@"name"];
        CGRect clientNameRect = [clientName.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-120, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:clientName.font} context:nil];
        clientName.frame = CGRectMake(110, 0, clientNameRect.size.width, clientNameRect.size.height);
        NSString *stars = [_dict objectForKey:@"score"];
        NSInteger starinter = stars.doubleValue+0.5;
        NSInteger j = 0;
        for (NSInteger i=0; i<starinter ; i++) {
            UIImageView *star = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star"]];
            CGRect _frame = CGRectMake(110+i*13+i*5, 5+clientName.frame.size.height, 13, 13);
            star.frame = _frame;
            [clientdetailView addSubview:star];
            j = i;
        }
        if (j!=0) {
            j++;
        }
        for (; j<5 ; j++) {
            UIImageView *blackstar = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Star2"]];
            CGRect _frame = CGRectMake(110+j*13+j*5, 5+clientName.frame.size.height, 13, 13);
            blackstar.frame = _frame;
            [clientdetailView addSubview:blackstar];
        }
        
        excerpt.text = [_dict objectForKey:@"tag"];
        NSString *priceString = [_dict objectForKey:@"price"];
        if(![priceString isEqualToString:@""]){
            priceString = [[_dict objectForKey:@"price"] substringFromIndex:1];
            pricelab.text = priceString;
            CGRect priceRect = [priceString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:pricelab.font} context:nil];
            pricelab.frame = CGRectMake(self.view.frame.size.width-priceRect.size.width-30, 26+clientName.frame.size.height-1, priceRect.size.width, priceRect.size.height);
            UIImageView *price = [[UIImageView alloc]initWithFrame:CGRectMake(pricelab.frame.origin.x-15, 26+clientName.frame.size.height, 12, 12)];
            price.image = [UIImage imageNamed:@"average"];
            [clientdetailView addSubview:price];
        }
        
        CGRect excerptRect = [excerpt.text boundingRectWithSize:CGSizeMake(pricelab.frame.origin.x-20-excerpt.frame.origin.x, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:excerpt.font} context:nil];
        CGRect newframe = excerpt.frame;
        newframe.origin.y = 26+clientName.frame.size.height-1;
        newframe.size.width = excerptRect.size.width;
        newframe.size.height = excerptRect.size.height;
        excerpt.frame = newframe;
        UIImageView *cuisine = [[UIImageView alloc]initWithFrame:CGRectMake(110, 26+clientName.frame.size.height, 12, 12)];
        cuisine.image = [UIImage imageNamed:@"cuisine"];
        [clientdetailView addSubview:cuisine];
        clientdetailView.frame = CGRectMake(0, (100-6-clientName.frame.size.height-16-excerpt.frame.size.height)/2, self.view.frame.size.width, 6+clientName.frame.size.height+16+excerpt.frame.size.height);
        
        
        descriptionText.text = [_dict objectForKey:@"description"];
        CGRect descriptionTextRect = [descriptionText.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-40, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:descriptionText.font} context:nil];
        descriptionText.frame = CGRectMake(10, 10, descriptionTextRect.size.width, descriptionTextRect.size.height);
        descriptionView.frame = CGRectMake(10, _scrollView.frame.origin.y+_scrollView.frame.size.height+105-0.055*self.view.frame.size.width, self.view.frame
                                           .size.width-20, descriptionTextRect.size.height+(self.view.frame.size.width-20)/4*5/6+20);
        UIView *descriptionViewline = [[UIView alloc]initWithFrame:CGRectMake(0, descriptionView.frame.size.height-0.25, descriptionView.frame.size.width, 0.5)];
        descriptionViewline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [descriptionView addSubview:descriptionViewline];
        UIButton *collect = [[UIButton alloc]initWithFrame:CGRectMake(0, 20+descriptionTextRect.size.height, (self.view.frame.size.width-20)/4, (self.view.frame.size.width-20)/4*5/6)];
        [collect setExclusiveTouch:YES];
        [collect addTarget:self action:@selector(toolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        collect.tag = 5;
        UILabel *collectline2 = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20)/4-0.25, 25+descriptionTextRect.size.height, 0.5, (self.view.frame.size.width-20)/4*5/6-10)];
        collectline2.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [descriptionView addSubview:collect];
        [descriptionView addSubview:collectline2];
        UIImageView *collectimg = [[UIImageView alloc]initWithFrame:CGRectMake(collect.frame.size.width/3-1.5, (collect.frame.size.height/3*2-18)/2, collect.frame.size.width/3+3, collect.frame.size.height/3+3)];
        [collectimg setImage:[UIImage imageNamed:@"collect"]];
        [collect addSubview:collectimg];
        UILabel *collectLab = [[UILabel alloc]initWithFrame:CGRectMake(0, collectimg.frame.origin.y+collectimg.frame.size.height+2, collect.frame.size.width, 13)];
        collectLab.text = GDLocalizedString(@"COLLECT");
        collectLab.textAlignment = NSTextAlignmentCenter;
        collectLab.textColor = [UIColor grayColor];
        collectLab.font = [UIFont systemFontOfSize:12];
        [collect addSubview:collectLab];
        
        UIButton *comment = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20)/4, 20+descriptionTextRect.size.height, (self.view.frame.size.width-20)/4, (self.view.frame.size.width-20)/4*5/6)];
        comment.tag = 6;
        [comment setExclusiveTouch:YES];
        [comment addTarget:self action:@selector(toolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *commentline = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20)/2-0.25, 25+descriptionTextRect.size.height,0.5, (self.view.frame.size.width-20)/4*5/6-10)];
        commentline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [descriptionView addSubview:comment];
        [descriptionView addSubview:commentline];
        UIImageView *commentimg = [[UIImageView alloc]initWithFrame:CGRectMake(comment.frame.size.width/3-1.5, (comment.frame.size.height/3*2-18)/2, comment.frame.size.width/3+3, collect.frame.size.height/3+3)];
        [commentimg setImage:[UIImage imageNamed:@"comment"]];
        [comment addSubview:commentimg];
        UILabel *commentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, commentimg.frame.origin.y+commentimg.frame.size.height+2, comment.frame.size.width, 13)];
        commentLab.text = GDLocalizedString(@"COMMENT");
        commentLab.textAlignment = NSTextAlignmentCenter;
        commentLab.textColor = [UIColor grayColor];
        commentLab.font = [UIFont systemFontOfSize:12];
        [comment addSubview:commentLab];
        
        UIButton *menu = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20)/2, 20+descriptionTextRect.size.height, (self.view.frame.size.width-20)/4, (self.view.frame.size.width-20)/4*5/6)];
        menu.tag = 7;
        [menu setExclusiveTouch:YES];
        [menu addTarget:self action:@selector(toolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *menuline = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20)/4*3-0.25, 25+descriptionTextRect.size.height, 0.5, (self.view.frame.size.width-20)/4*5/6-10)];
        menuline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [descriptionView addSubview:menu];
        [descriptionView addSubview:menuline];
        UIImageView *menuimg = [[UIImageView alloc]initWithFrame:CGRectMake(menu.frame.size.width/3-1.5, (menu.frame.size.height/3*2-18)/2, menu.frame.size.width/3+3, menu.frame.size.height/3+3)];
        [menuimg setImage:[UIImage imageNamed:@"Venumenu"]];
        [menu addSubview:menuimg];
        UILabel *menuLab = [[UILabel alloc]initWithFrame:CGRectMake(0, menuimg.frame.origin.y+menuimg.frame.size.height+2, menu.frame.size.width, 13)];
        menuLab.text = GDLocalizedString(@"MENU");
        menuLab.textAlignment = NSTextAlignmentCenter;
        menuLab.textColor = [UIColor grayColor];
        menuLab.font = [UIFont systemFontOfSize:12];
        [menu addSubview:menuLab];
        
        UIButton *events = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20)/4*3, 20+descriptionTextRect.size.height, (self.view.frame.size.width-20)/4, (self.view.frame.size.width-20)/4*5/6)];
        events.tag = 8;
        [events setExclusiveTouch:YES];
        [events addTarget:self action:@selector(toolBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [descriptionView addSubview:events];
        UIImageView *eventsimg = [[UIImageView alloc]initWithFrame:CGRectMake(events.frame.size.width/3-1.5, (events.frame.size.height/3*2-18)/2, events.frame.size.width/3+3, events.frame.size.height/3+3)];
        [eventsimg setImage:[UIImage imageNamed:@"events"]];
        [events addSubview:eventsimg];
        UILabel *eventsLab = [[UILabel alloc]initWithFrame:CGRectMake(0, eventsimg.frame.origin.y+eventsimg.frame.size.height+2, events.frame.size.width, 13)];
        eventsLab.text = GDLocalizedString(@"EVENT");
        eventsLab.textAlignment = NSTextAlignmentCenter;
        eventsLab.textColor = [UIColor grayColor];
        eventsLab.font = [UIFont systemFontOfSize:12];
        [events addSubview:eventsLab];
        UILabel *collectline1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 20+descriptionTextRect.size.height-0.25, self.view.frame.size.width-30, 0.5)];
        collectline1.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [descriptionView addSubview:collectline1];
        
        UIView *userNum = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 80)];
        userNum.backgroundColor = [UIColor whiteColor];
        [offerview addSubview:userNum];
        UILabel *userline = [[UILabel alloc]initWithFrame:CGRectMake(0, userNum.frame.size.height, userNum.frame.size.width, 1)];
        userline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [userNum addSubview:userline];
        
        loginBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-20, 80)];
        [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [loginBtn setExclusiveTouch:YES];
        [offerview addSubview:loginBtn];
        
        UILabel *usertitle = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2-10, 10, 200, 15)];
        usertitle.text = GDLocalizedString(@"MEMBER NUMBER");
        usertitle.textAlignment = NSTextAlignmentCenter;
        usertitle.font = [UIFont systemFontOfSize:12];
        usertitle.textColor = [UIColor grayColor];
        [userNum addSubview:usertitle];
        
        userNumber = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/2-10, 21, 300, 40)];
        userNumber.textAlignment = NSTextAlignmentCenter;
        userNumber.font = [UIFont boldSystemFontOfSize:18];
        userNumber.textColor = LabColor(0.90,0,0);
        [userNum addSubview:userNumber];
        
        ExpireDate = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-300)/2-10, 55, 300, 15)];
        ExpireDate.textColor = [UIColor grayColor];
        ExpireDate.font = [UIFont systemFontOfSize:12];
        ExpireDate.textAlignment = NSTextAlignmentCenter;
        [userNum addSubview:ExpireDate];
        
        UIView *voucherView = [[UIView alloc]init];
        voucherView.backgroundColor = [UIColor whiteColor];
        [offerview addSubview:voucherView];
        UIImageView *voucherImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20-32)/2, 20, 32, 25 )];
        voucherImageView.image = [UIImage imageNamed:@"voucher"];
        [voucherView addSubview:voucherImageView];
        UILabel *voucherTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, self.view.frame.size.width-20, 25)];
        voucherTitle.text = [_dict objectForKey:@"voucherOffer"];
        voucherTitle.textColor = LabColor(0.90, 0, 0);
        voucherTitle.numberOfLines = 0;
        voucherTitle.lineBreakMode = NSLineBreakByWordWrapping;
        voucherTitle.textAlignment = NSTextAlignmentCenter;
        voucherTitle.font = [UIFont boldSystemFontOfSize:18];
        CGRect voucherTitleRect = [voucherTitle.text boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:voucherTitle.font} context:nil];
        voucherTitle.frame = CGRectMake((self.view.frame.size.width-20-voucherTitleRect.size.width)/2, 55, voucherTitleRect.size.width, voucherTitleRect.size.height);
        [voucherView addSubview:voucherTitle];
        UILabel *voucherDetail = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20-200)/2, 85, 200, 40)];
        voucherDetail.text = [NSString stringWithFormat:@"%@",[_dict objectForKey:@"voucherOfferDescription"]];
        voucherDetail.textColor = [UIColor grayColor];
        [voucherDetail setNumberOfLines:0];
        voucherDetail.lineBreakMode = NSLineBreakByWordWrapping;
        voucherDetail.font = [UIFont boldSystemFontOfSize:12];
        voucherDetail.textAlignment = NSTextAlignmentCenter;
        CGRect voucherDetailRect = [voucherDetail.text boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:voucherDetail.font} context:nil];
        voucherDetail.frame = CGRectMake((self.view.frame.size.width-20-voucherDetailRect.size.width)/2, 55+voucherTitleRect.size.height, voucherDetailRect.size.width, voucherDetailRect.size.height);
        [voucherView addSubview:voucherDetail];
        
        voucherBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20-170)/2, 55+voucherTitleRect.size.height+voucherDetail.frame.size.height+5, 170, 30)];
        [voucherBtn setExclusiveTouch:YES];
        voucherLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 30)];
        voucherLab.text = GDLocalizedString(@"USEVOUCHER");
        voucherLab.font = [UIFont systemFontOfSize:16];
        voucherLab.textColor = [UIColor whiteColor];
        voucherLab.textAlignment = NSTextAlignmentCenter;
        [voucherBtn addSubview:voucherLab];
        voucherBtn.backgroundColor = LabColor(0.90, 0, 0);
        voucherBtn.layer.cornerRadius = 15;
        [voucherBtn addTarget:self action:@selector(voucherBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [voucherView addSubview:voucherBtn];
        
        UILabel *voucherTin = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20-170)/2, 55+voucherTitleRect.size.height+voucherDetail.frame.size.height+40, 170, 10)];
        voucherTin.text = GDLocalizedString(@"ONLY FOR ONE TIME USE");
        voucherTin.textColor = [UIColor grayColor];
        voucherTin.font = [UIFont systemFontOfSize:10];
        voucherTin.textAlignment = NSTextAlignmentCenter;
        voucherView.frame = CGRectMake(0, 85, self.view.frame.size.width-20, 55+voucherTitleRect.size.height+voucherDetailRect.size.height+75) ;
        [voucherView addSubview:voucherTin];
        UILabel *voucherline = [[UILabel alloc]initWithFrame:CGRectMake(0, voucherView.frame.size.height, voucherView.frame.size.width, 1)];
        voucherline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [voucherView addSubview:voucherline];
        
        UIView *discountView = [[UIView alloc]init];
        discountView.backgroundColor = [UIColor whiteColor];
        
        UIImageView *discountImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-52)/2, 20, 32, 25 )];
        discountImageView.image = [UIImage imageNamed:@"card"];
        [discountView addSubview:discountImageView];
        UILabel *discountTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, self.view.frame.size.width-20, 25)];
        discountTitle.text = [_dict objectForKey:@"cardOffer"];
        if([_dict objectForKey:@"cardOffer"]==nil){
            discountTitle.text = GDLocalizedString(@"No Discount");
        }
        discountTitle.numberOfLines = 0;
        discountTitle.lineBreakMode = NSLineBreakByWordWrapping;
        discountTitle.textColor = LabColor(0.90,0,0);
        discountTitle.font = [UIFont boldSystemFontOfSize:18];
        discountTitle.textAlignment = NSTextAlignmentCenter;
        CGRect discountTitleRect = [discountTitle.text boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:discountTitle.font} context:nil];
        discountTitle.frame = CGRectMake((self.view.frame.size.width-20-discountTitleRect.size.width)/2, 55, discountTitleRect.size.width, discountTitleRect.size.height);
        [discountView addSubview:discountTitle];
        UILabel *discountDetail = [[UILabel alloc]init];
        discountDetail.text = [NSString stringWithFormat:@"%@",[_dict objectForKey:@"cardOfferDesc"]];
        [discountDetail setNumberOfLines:0];
        if([_dict objectForKey:@"cardOffer"]==nil){
            discountDetail.text = GDLocalizedString(@"To be continued.");
        }
        discountDetail.lineBreakMode = NSLineBreakByWordWrapping;
        discountDetail.font = [UIFont boldSystemFontOfSize:12];
        discountDetail.textColor = [UIColor grayColor];
        discountDetail.textAlignment = NSTextAlignmentCenter;
        CGRect discountDetailRect = [discountDetail.text boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:discountDetail.font} context:nil];
        discountDetail.frame = CGRectMake((self.view.frame.size.width-20-discountDetailRect.size.width)/2, 55+discountTitle.frame.size.height, discountDetailRect.size.width, discountDetailRect.size.height);
        [discountView addSubview:discountDetail];
        
        discountBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20-170)/2, 55+discountTitleRect.size.height+discountDetail.frame.size.height+5, 170, 30)];
        [discountBtn setExclusiveTouch:YES];
        discountLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 30)];
        discountLab.font = [UIFont systemFontOfSize:16];
        discountLab.textColor = [UIColor whiteColor];
        discountLab.textAlignment = NSTextAlignmentCenter;
        [discountBtn addSubview:discountLab];
        if([_dict objectForKey:@"cardOffer"]==nil){
            discountLab.text = GDLocalizedString(@"NOT VALID");
            discountBtn.enabled = NO;
            discountBtn.alpha = 0.5;
        }else{
            discountLab.text = GDLocalizedString(@"USE");
        }
        discountBtn.backgroundColor = LabColor(0.90, 0, 0);
        discountBtn.layer.cornerRadius = 15;
        [discountBtn addTarget:self action:@selector(discountBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        discountView.frame = CGRectMake(0, 90+voucherView.frame.size.height, self.view.frame.size.width-20, 55+discountTitleRect.size.height+discountDetail.frame.size.height+60);
        [discountView addSubview:discountBtn];
        UILabel *discountline = [[UILabel alloc]initWithFrame:CGRectMake(0, discountView.frame.size.height, discountView.frame.size.width, 1)];
        discountline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [discountView addSubview:discountline];
        [offerview addSubview:discountView];
        
        UIView *terms = [[UIView alloc]init];
        terms.backgroundColor = [UIColor whiteColor];
        
        UILabel *termsTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width-20, 20)];
        termsTitle.text = GDLocalizedString(@"TERMS OF USE");
        termsTitle.font = [UIFont boldSystemFontOfSize:16];
        termsTitle.textAlignment = NSTextAlignmentCenter;
        termsTitle.textColor = LabColor(0.33, 0.33, 0.33);
        [terms addSubview:termsTitle];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-20-270)/2, 45, 270, 1)];
        line.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [terms addSubview:line];
        
        UILabel *termsDetail  = [[UILabel alloc]init];
        NSString *termsString = [[NSString alloc]init];
        for (NSInteger i=0; i<100; i++) {
            if ([_dict objectForKey:[NSString stringWithFormat:@"term%li",(long)i]]!=nil) {
                termsString = [termsString stringByAppendingString:[NSString stringWithFormat:@"%@\n",[_dict objectForKey:[NSString stringWithFormat:@"term%li",(long)i]]]];
            }
            else{
                break;
            }
        }
        termsDetail.text = termsString;
        termsDetail.font = [UIFont systemFontOfSize:12];
        termsDetail.numberOfLines = 0;
        termsDetail.textAlignment = NSTextAlignmentCenter;
        termsDetail.textColor = [UIColor grayColor];
        CGRect termsDetailRect = [termsDetail.text boundingRectWithSize:CGSizeMake(250,CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:termsDetail.font} context:nil];
        termsDetail.frame = CGRectMake((self.view.frame.size.width-20-termsDetailRect.size.width)/2, 50, termsDetailRect.size.width, termsDetailRect.size.height);
        [terms addSubview:termsDetail];
        terms.frame = CGRectMake(0, discountView.frame.origin.y+discountView.frame.size.height+5, self.view.frame.size.width-20, termsDetail.frame.size.height+60);
        UILabel *termsline = [[UILabel alloc]initWithFrame:CGRectMake(0, terms.frame.size.height, terms.frame.size.width, 1)];
        termsline.backgroundColor = LabColor(0.82, 0.82, 0.82);
        [terms addSubview:termsline];
        [offerview addSubview:terms];
        offerview.frame = CGRectMake(0, 50, self.view.frame.size.width-20, terms.frame.origin.y+terms.frame.size.height);
        detail.frame = CGRectMake(10,descriptionView.frame.origin.y+descriptionView.frame.size.height+5 , self.view.frame.size.width-20, offerview.frame.size.height+70);
        Btns.frame = CGRectMake(0, 0, self.view.frame.size.width-20,50);
        CGFloat BtnsWidth = self.view.frame.size.width-20;
        offer.frame = CGRectMake(0, 0, BtnsWidth/3, 50);
        reviews.frame = CGRectMake(BtnsWidth/3, 0, BtnsWidth/3, 50);
        Location.frame = CGRectMake(BtnsWidth/3*2, 0, BtnsWidth/3, 50);
        [detail addSubview:Btns];
        [_contentView addSubview:detail];
        [_contentView setContentSize:CGSizeMake(0, detail.frame.origin.y+detail.frame.size.height+10)];
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        if ([[userdefault objectForKey:@"flag"] isEqualToString:@"1"]) {
            loginBtn.hidden = YES;
            userNumber.text = [userdefault objectForKey:@"cardNumber"];
            userNumber.font = [UIFont boldSystemFontOfSize:30];
            ExpireDate.text = [userdefault objectForKey:@"validity"];
            NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(cxvoucherValid) object:nil];
            [thread start];
            if([_dict objectForKey:@"cardOffer"]!=nil){
                discountBtn.enabled = YES;
                discountBtn.alpha = 1;
            }
        }else{
            userNumber.text = GDLocalizedString(@"Please Login!");
            loginBtn.hidden = NO;
            voucherBtn.enabled = NO;
            discountBtn.enabled = NO;
            discountBtn.alpha = 0.5;
            voucherBtn.alpha = 0.5;
            userNumber.font = [UIFont boldSystemFontOfSize:18];
        }
    }
    if (LocationArray!=nil) {
        [loadData stopAnimating];
        activityBackGround.hidden = YES;
        activityLab.hidden = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

-(void)runData2{
    AddressXml *addXml = [AddressXml alloc];
    NSString *addxmlstring1 = @"http://app.enjoylist.com/locations.asp?id=";
    NSString *addxmlstring2 = [addxmlstring1 stringByAppendingString:_clientid];
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if([[userdefault objectForKey:@"locationflag"] isEqualToString:@"1"]){
        addxmlstring2 = [addxmlstring2 stringByAppendingString:[NSString stringWithFormat:@"&lat=%f&lng=%f",[userdefault doubleForKey:@"lng"],[userdefault doubleForKey:@"lat"]]];
    }
    if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
        addxmlstring2 = [addxmlstring2 stringByAppendingString:@"&locale=zh-cn"];
    }
    [addXml StartParse:addxmlstring2];
    LocationArray = addXml.dataArray2;
    if(LocationArray !=nil){
        [self performSelectorOnMainThread:@selector(updateArea) withObject:nil waitUntilDone:NO];
    }
}

-(void)updateArea{
    NSInteger i;
    CGFloat height = 0.0f;
    
    for (i = 0; i<[LocationArray count]; i++) {
        NSMutableDictionary *locationDic = [[NSMutableDictionary alloc]init];
        locationDic = [LocationArray objectAtIndex:i];
        locationId = [locationDic objectForKey:@"id"];
        
        UIView *locationSubView = [[UIView alloc]init];
        UILabel *placename = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, locationView.frame.size.width-100, 30)];
        placename.text =[locationDic objectForKey:@"name"];
        placename.font = [UIFont systemFontOfSize:14];
        [locationSubView addSubview:placename];
        
        UILabel *DetailDistance = [[UILabel alloc]initWithFrame:CGRectMake(locationView.frame.size.width-60, 0, 50, 30)];
        if ([[locationDic objectForKey:@"distance"] integerValue]>1000) {
            NSInteger newdistance =[[locationDic objectForKey:@"distance"] integerValue]/1000;
            DetailDistance.text = [NSString stringWithFormat:@">%likm",(long)newdistance];
        }else{
            DetailDistance.text = [NSString stringWithFormat:@"%lim",(long)[[locationDic objectForKey:@"distance"] integerValue]];
        }
        DetailDistance.textColor = LabColor(0.33, 0.33, 0.33);
        DetailDistance.font = [UIFont systemFontOfSize:12];
        CGRect DetailDistanceRect = [DetailDistance.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 15) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:DetailDistance.font} context:nil];
        DetailDistance.frame = CGRectMake(self.view.frame.size.width-DetailDistanceRect.size.width-25, 7.5, DetailDistanceRect.size.width, DetailDistanceRect.size.height);
        
        [locationSubView addSubview:DetailDistance];
        
        UIImageView *distanceImage = [[UIImageView alloc]initWithFrame:CGRectMake(DetailDistance.frame.origin.x-13, 7.5,10, 15)];
        distanceImage.image =[UIImage imageNamed:@"location_s"];
        [locationSubView addSubview:distanceImage];
        
        UIView *mapView = [[UIView alloc]initWithFrame:CGRectMake(0, 30, locationView.frame.size.width, 220)];
        mapView.backgroundColor = [UIColor whiteColor];
        [locationSubView addSubview:mapView];
        
        UILabel *place = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-95, 70)];
        place.textColor = LabColor(0.33, 0.33, 0.33);
        place.font = [UIFont systemFontOfSize:16];
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
            place.text = [locationDic objectForKey:@"chAddress"];
            if (![[locationDic objectForKey:@"chnear"] isEqualToString:@"()"]) {
                place.text = [place.text stringByAppendingString:[locationDic objectForKey:@"chnear"]];
            }
        }else if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"en"]){
            place.text = [locationDic objectForKey:@"address"];
            if (![[locationDic objectForKey:@"near"] isEqualToString:@"()"]) {
                place.text = [place.text stringByAppendingString:[locationDic objectForKey:@"near"]];
            }
        }
        place.numberOfLines = 0;
        place.lineBreakMode = NSLineBreakByWordWrapping;
        [mapView addSubview:place];
        
        UIImageView *LocationCallline = [[UIImageView alloc]init];
        LocationCallline.image = [UIImage imageNamed:@"call_line"];
        [mapView addSubview:LocationCallline];
        UIButton *LocationCall = [[UIButton alloc]init];
        [LocationCall setBackgroundImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
        LocationCall.tag = i;
        [LocationCall setExclusiveTouch:YES];
        [LocationCall addTarget:self action:@selector(LocationPhone:) forControlEvents:UIControlEventTouchUpInside];
        LocationCallline.frame = CGRectMake(self.view.frame.size.width-78, 15, 1, 40);
        LocationCall.frame = CGRectMake(self.view.frame.size.width-68, 20, 30, 30);
        [mapView addSubview:LocationCall];
        MKMapView *usermap = [[MKMapView alloc]initWithFrame:CGRectMake(0, 70, mapView.frame.size.width, 150)];
        usermap.delegate = self;
        [usermap setUserInteractionEnabled:NO];
        MKPointAnnotation *annota = [[MKPointAnnotation alloc] init];
        annota.coordinate = CLLocationCoordinate2DMake([[locationDic objectForKey:@"lng"] doubleValue], [[locationDic objectForKey:@"lat"] doubleValue]);
        [usermap addAnnotation:annota];
        [self SetMapRegion:annota.coordinate:usermap];
        [mapView addSubview:usermap];
        
        UIButton *mapbtn = [[UIButton alloc]init];
        mapbtn.frame = usermap.frame;
        [mapbtn setExclusiveTouch:YES];
        mapbtn.tag = i;
        [mapbtn addTarget:self action:@selector(moreMapDetail:) forControlEvents:UIControlEventTouchUpInside];
        [mapView addSubview:mapbtn];
        UIView *ontime =[[UIView alloc]init];
        ontime.backgroundColor = [UIColor whiteColor];
        [locationSubView addSubview:ontime];
        if (![[locationDic objectForKey:@"hours"] isEqualToString:@""]) {
            UIImageView *hourimg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 11, 13, 13)];
            hourimg.image = [UIImage imageNamed:@"hour 2"];
            [ontime addSubview:hourimg];
            
            UILabel *ontimedetail = [[UILabel alloc]init];
            if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"ch"]) {
                ontimedetail.text = [locationDic objectForKey:@"chHours"];
            }else if ([[userdefault objectForKey:@"languageFlag"] isEqualToString:@"en"]){
                ontimedetail.text = [locationDic objectForKey:@"hours"];
            }
            ontimedetail.textColor = LabColor(0.33, 0.33, 0.33);
            ontimedetail.numberOfLines = 0;
            ontimedetail.font = [UIFont systemFontOfSize:13];
            ontimedetail.lineBreakMode = NSLineBreakByWordWrapping;
            [ontime addSubview:ontimedetail];
            CGRect ontimedetailrect = [ontimedetail.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width-59, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:ontimedetail.font} context:nil];
            ontimedetail.frame = CGRectMake(30, 10, ontimedetailrect.size.width, ontimedetailrect.size.height);
            ontime.frame = CGRectMake(0, 250, self.view.frame.size.width-20, ontimedetail.frame.size.height+20);
            if (ontime.frame.size.height<40) {
                ontimedetail.frame = CGRectMake(30, 10, ontimedetailrect.size.width, ontimedetailrect.size.height);
                ontime.frame = CGRectMake(0, 250, self.view.frame.size.width-20, ontimedetail.frame.size.height+20);
                hourimg.frame = CGRectMake(10, 11, 13, 13);
            }
        }else{
            CGRect newframe = ontime.frame;
            newframe.size.height = 0;
            ontime.frame = newframe;
        }
        locationSubView.frame = CGRectMake(0, i*270, locationView.frame.size.width, 270+ontime.frame.size.height);
        CGRect newframe = locationSubView.frame;
        newframe.origin.y +=height;
        locationSubView.frame = newframe;
        height += ontime.frame.size.height;
        [locationView addSubview:locationSubView];
    }
    
    CGFloat ViewHeight = 0.0f;
    for (UIView *view in locationView.subviews){
        ViewHeight += view.frame.size.height;
    }
    CGRect newframe = locationView.frame;
    newframe.size.height = ViewHeight;
    locationView.frame = newframe;
    if (_dataArray!=nil) {
        [loadData stopAnimating];
        activityBackGround.hidden = YES;
        activityLab.hidden = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

-(void)moreMapDetail:(UIButton *)btn{
    NSMutableDictionary *locationDic = [[NSMutableDictionary alloc]init];
    locationDic = [LocationArray objectAtIndex:btn.tag];
    MoreMapViewController *moremapview = [[MoreMapViewController alloc]init];
    moremapview.lng = [[locationDic objectForKey:@"lng"] doubleValue];
    moremapview.title = [_dict objectForKey:@"name"];
    moremapview.excerpt = [_dict objectForKey:@"excerpt"];
    moremapview.lat = [[locationDic objectForKey:@"lat"] doubleValue];
    [self.navigationController pushViewController:moremapview animated:YES];
    self.navigationController.navigationBarHidden = YES;
}


-(void)SetMapRegion:(CLLocationCoordinate2D)myCoordinate : (MKMapView *)map
{
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=myCoordinate;
    [map setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.005f;
    theRegion.span.latitudeDelta = 0.005f;
    [map setRegion:theRegion animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CustomAnnotationView *annotationView = (CustomAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
            
        }
        annotationView.image = [UIImage imageNamed:@"location"];
        annotationView.frame = CGRectMake(0, 0, 20, 26);
        return annotationView;
    }
    return nil;
}

-(void)loadclientpic{
    _pageControl.numberOfPages = [photoArray count];
    CGFloat imageW = _scrollView.frame.size.width;
    int tag = 0;
    if (photoArray.count!=0) {
        for (int i = 0; i < [photoArray count]; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            CGFloat imageX = i * imageW;
            imageView.frame = CGRectMake(imageX, 0, imageW, self.view.frame.size.width*3/4);
            NSDictionary *dict = [photoArray objectAtIndex:i];
            [imageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"url"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [loadImageView removeFromSuperview];
            }];
            imageView.tag = 10+tag;
            tag++;
            _scrollView.showsHorizontalScrollIndicator = NO;
            [_scrollView addSubview:imageView];
        }
    }
    _scrollView.contentSize = CGSizeMake([photoArray count]*imageW, 0);
}

- (void)addTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}
- (void)nextImage
{
    int page = (int)_pageControl.currentPage;
    if (page == [photoArray count]-1) {
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

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView.tag == 1) {
        [_timer invalidate];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.tag == 1) {
        [self addTimer];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 1) {
        CGFloat scrollviewW =  scrollView.frame.size.width;
        CGFloat x = scrollView.contentOffset.x;
        int page = (x + scrollviewW / 2) /  scrollviewW;
        _pageControl.currentPage = page;
    }
    else if (scrollView.tag == 0) {
        if(scrollView.contentOffset.y > clientView.frame.origin.y-128){
            _shadow.hidden = NO;
            shadow2.alpha = 0;
            Statusview.alpha = 1;
            if (scrollView.contentOffset.y > detail.frame.origin.y-128) {
                _shadow.hidden = YES;
                [self performSelector:@selector(xfBtn)];
            }else{
                _shadow.hidden = NO;
                [self performSelector:@selector(hyBtn)];
            }
        }else if(scrollView.contentOffset.y <= clientView.frame.origin.y-128){
            shadow2.alpha = (clientView.frame.origin.y-64-scrollView.contentOffset.y-64)/(clientView.frame.origin.y-64);
            Statusview.alpha =  ((scrollView.contentOffset.y+64)/(clientView.frame.origin.y-64));
            [self performSelector:@selector(hyBtn)];
            _shadow.hidden = YES;
            if ([scroflag isEqualToString:@"1"]) {
                [self addTimer];
                scroflag = @"0";
                CGRect frame = _scrollView.frame;
                frame.origin.y = -self.view.frame.size.width*0.055;
                frame.size.height = self.view.frame.size.width*0.75;
                _scrollView.frame = frame;
            }
            if (scrollView.contentOffset.y < -64){
                [_timer invalidate];
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
    }
}

-(void)xfBtn{
    xfFlag = @"1";
    CGRect newframe1 = Btns.frame;
    newframe1.origin.x = 0;
    newframe1.origin.y = 64;
    newframe1.size.width = self.view.frame.size.width;
    newframe1.size.height = 30;
    Btns.frame = newframe1;
    [UIView animateWithDuration:0.1 animations:^{
        offer.frame = CGRectMake(0, 0, Btns.frame.size.width/3, 30);
        reviews.frame = CGRectMake(Btns.frame.size.width/3, 0, Btns.frame.size.width/3, 30);
        Location.frame = CGRectMake(Btns.frame.size.width/3*2, 0, Btns.frame.size.width/3, 30);
        navlinebackground.frame = CGRectMake(0, 26, Btns.frame.size.width, 4);
        CGRect newframe2 = navline.frame;
        if (newframe2.origin.x == 0) {
            newframe2.origin.x = 0;
        }else if (newframe2.origin.x == (self.view.frame.size.width-20)/3){
            newframe2.origin.x = Btns.frame.size.width/3;
        }else if (newframe2.origin.x == (self.view.frame.size.width-20)/3*2){
            newframe2.origin.x = Btns.frame.size.width/3*2;
        }
        newframe2.origin.y = 26;
        newframe2.size.width = Btns.frame.size.width/3;
        navline.frame = newframe2;
    }];
    [self.view addSubview:Btns];
}

-(void)hyBtn{
    xfFlag = @"0";
    CGRect newframe1 = Btns.frame;
    newframe1.origin.x = 0;
    newframe1.origin.y = 0;
    newframe1.size.width = self.view.frame.size.width-20;
    newframe1.size.height = 50;
    Btns.frame = newframe1;
    [UIView animateWithDuration:0.1 animations:^{
        offer.frame = CGRectMake(0, 0, Btns.frame.size.width/3, 50);
        reviews.frame = CGRectMake(Btns.frame.size.width/3, 0, Btns.frame.size.width/3, 50);
        Location.frame = CGRectMake(Btns.frame.size.width/3*2, 0, Btns.frame.size.width/3, 50);
        navlinebackground.frame = CGRectMake(0, 46, Btns.frame.size.width, 4);
        CGRect newframe2 = navline.frame;
        if (newframe2.origin.x == 0) {
            newframe2.origin.x = 0;
        }else if (newframe2.origin.x >= (self.view.frame.size.width-20)/3-1 && newframe2.origin.x <= (self.view.frame.size.width-20)/3*2-1){
            newframe2.origin.x = (self.view.frame.size.width-20)/3;
        }else if (newframe2.origin.x >= (self.view.frame.size.width-20)/3*2){
            newframe2.origin.x = (self.view.frame.size.width-20)/3*2;
        }
        newframe2.origin.y = 46;
        newframe2.size.width = Btns.frame.size.width/3;
        navline.frame = newframe2;
    }];
    [detail addSubview:Btns];
}

-(void)runComment{
    commentArray = [[NSMutableArray alloc]init];
    commentXml *cxml = [[commentXml alloc]init];
    [cxml StartParse:[NSString stringWithFormat:@"http://app.enjoylist.com/reviews.asp?id=%@&start=0",_clientid]];
    commentArray = cxml.dataArray;
    if (commentArray!=nil) {
        [self performSelectorOnMainThread:@selector(reloadCommentTable) withObject:nil waitUntilDone:NO];
    }
}

-(void)reloadCommentTable{
    if (commentArray.count == 0) {
        CGRect newframe = commentView.frame;
        newframe.size.height = 50;
        commentView.frame = newframe;
        commentHit.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
        commentHit.hidden = NO;
    }else{
        NSInteger j = commentArray.count;
        if (j>3) {
            j=3;
        }
        for (int i = 0; i<j; i++) {
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            arr = [commentArray objectAtIndex:i];
            NSDictionary *dict1 = [[NSDictionary alloc]init];
            dict1 = [arr objectAtIndex:0];
            NSDictionary *dict2 = [[NSDictionary alloc]init];
            dict2 = [arr objectAtIndex:2];
            NSDictionary *dict3 = [[NSDictionary alloc]init];
            dict3 = [arr objectAtIndex:3];
            
            UIButton *commentSubView = [[UIButton alloc]init];
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
            UILabel *line = [[UILabel alloc]initWithFrame:CGRectMake(10, clock.frame.origin.y+clock.frame.size.height+14, self.view.frame.size.width-40, 1)];
            line.backgroundColor = LabColor(0.82, 0.82, 0.82);
            [commentSubView addSubview:line];
            
            CGFloat height;
            if (clock.frame.origin.y+clock.frame.size.height+15<90) {
                commentSubView.frame = CGRectMake(0, 0, self.view.frame.size.width-20, 90);
                line.frame = CGRectMake(10, 89, self.view.frame.size.width-40, 1);
            }else{
                commentSubView.frame = CGRectMake(0, 0, self.view.frame.size.width-20, clock.frame.origin.y+clock.frame.size.height+15);
            }
            
            CGRect newframe = commentSubView.frame;
            newframe.origin.y +=height;
            commentSubView.frame = newframe;
            if (clock.frame.origin.y+clock.frame.size.height+15<90) {
                height += 90;
            }else{
                height += clock.frame.origin.y+clock.frame.size.height+15;
            }
            [commentSubView addTarget:self action:@selector(morecomment) forControlEvents:UIControlEventTouchUpInside];
            [commentView addSubview:commentSubView];
        }
        CGFloat ViewHeight = 0.0f;
        for (UIView* view in commentView.subviews){
            ViewHeight += view.frame.size.height;
        }
        CGRect newframe = commentView.frame;
        newframe.size.height = ViewHeight;
        commentView.frame = newframe;
        if (commentArray.count>3) {
            UIButton *moreDetail = [[UIButton alloc]initWithFrame:CGRectMake(0, commentView.frame.size.height, self.view.frame.size.width-20, 30)];
            [moreDetail setTitle:GDLocalizedString(@"Click to show more comment") forState:UIControlStateNormal];
            moreDetail.titleLabel.font = [UIFont systemFontOfSize:13];
            moreDetail.backgroundColor = LabColor(0.90, 0, 0);
            [moreDetail addTarget:self action:@selector(morecomment) forControlEvents:UIControlEventTouchUpInside];
            [commentView addSubview:moreDetail];
        }
        CGFloat ViewHeight2 = 0.0f;
        for (UIView* view in commentView.subviews){
            ViewHeight2 += view.frame.size.height;
        }
        CGRect newframe2 = commentView.frame;
        newframe2.size.height = ViewHeight2;
        commentView.frame = newframe2;
    }
}

-(void)morecomment{
    CommentDetailViewController *cv = [[CommentDetailViewController alloc]init];
    cv.commentArray = commentArray;
    cv.dict = _dict;
    cv.clientId = _clientid;
    cv.title = GDLocalizedString(@"COMMENT");
    [self.navigationController pushViewController:cv animated:YES];
}

-(void)detailBtnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 0:
        {
            [UIView animateWithDuration:0.3 animations:^{
                if ([xfFlag isEqualToString:@"1"]) {
                    navline.frame = CGRectMake(0, 26, self.view.frame.size.width/3, 4);
                }else{
                    navline.frame = CGRectMake(0, 46, (self.view.frame.size.width-20)/3, 4);
                }
            }];
            offerview.hidden = NO;
            commentView.hidden = YES;
            locationView.hidden = YES;
            detail.frame = CGRectMake(10, descriptionView.frame.origin.y+descriptionView.frame.size.height+5, self.view.frame.size.width-20, offerview.frame.size.height+70);
            [_contentView setContentSize:CGSizeMake(0, detail.frame.origin.y+detail.frame.size.height+10)];
        }
            break;
        case 1:
        {
            [UIView animateWithDuration:0.3 animations:^{
                if ([xfFlag isEqualToString:@"1"]) {
                    navline.frame = CGRectMake(self.view.frame.size.width/3, 26, self.view.frame.size.width/3, 4);
                }else{
                    navline.frame = CGRectMake((self.view.frame.size.width-20)/3, 46, (self.view.frame.size.width-20)/3, 4);
                }
            }];
            offerview.hidden = YES;
            commentView.hidden = NO;
            locationView.hidden = YES;
            detail.frame = CGRectMake(10, descriptionView.frame.origin.y+descriptionView.frame.size.height+5, self.view.frame.size.width-20, commentView.frame.size.height+70);
            bussinessTime.hidden = YES;
            [_contentView setContentSize:CGSizeMake(0, detail.frame.origin.y+detail.frame.size.height+10)];
        }
            break;
        case 2:
        {
            [UIView animateWithDuration:0.3 animations:^{
                if ([xfFlag isEqualToString:@"1"]) {
                    navline.frame = CGRectMake(self.view.frame.size.width/3*2, 26, self.view.frame.size.width/3, 4);
                }else{
                    navline.frame = CGRectMake((self.view.frame.size.width-20)/3*2, 46, (self.view.frame.size.width-20)/3, 4);
                }
            }];
            offerview.hidden = YES;
            commentView.hidden = YES;
            locationView.hidden = NO;
            detail.frame = CGRectMake(10,descriptionView.frame.origin.y+descriptionView.frame.size.height+5, self.view.frame.size.width-20, locationView.frame.size.height+80);
            bussinessTime.hidden = YES;
            [_contentView setContentSize:CGSizeMake(0, detail.frame.origin.y+detail.frame.size.height+10)];
        }
            break;
        default:
            break;
    }
}

-(void)login{
    NewLoginViewController *login = [[NewLoginViewController alloc]init];
    [self.navigationController presentViewController:login animated:YES completion:nil];
}

-(void)LocationPhone:(UIButton *)btn{
    NSDictionary *dict = [[NSDictionary alloc]init];
    dict = [LocationArray objectAtIndex:btn.tag];
    if ([[dict objectForKey:@"phone"] isEqualToString:@""]) {
        [self performSelectorOnMainThread:@selector(nophone) withObject:nil waitUntilDone:NO];
    }else{
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",[dict objectForKey:@"phone"]];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
    }
}

-(void)nophone{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"The Client doesn't provide phone number!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
    alter.delegate = self;
    [alter show];
}

-(void)voucherBtnClick:(UIButton *)btn{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if ([[userDefaultes stringForKey:@"flag"]isEqualToString:@"1"]) {
        [self performSelectorOnMainThread:@selector(suretoUseVoucher) withObject:nil waitUntilDone:NO];
    }
    else{
        NewLoginViewController *login = [[NewLoginViewController alloc]init];
        [self.navigationController presentViewController:login animated:YES completion:nil];
    }
}

-(void)suretoUseVoucher{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Info")  message:GDLocalizedString(@"Are you sure to use?") delegate:self cancelButtonTitle:GDLocalizedString(@"No") otherButtonTitles:GDLocalizedString(@"Yes"), nil];
    alter.tag = 1;
    alter.delegate = self;
    [alter show];
}

-(void)discountBtnClick:(UIButton *)btn{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if ([[userDefaultes stringForKey:@"flag"]isEqualToString:@"1"]) {
        [self performSelectorOnMainThread:@selector(suretoUseDiscount) withObject:nil waitUntilDone:NO];
    }
    else{
        NewLoginViewController *login = [[NewLoginViewController alloc]init];
        [self.navigationController presentViewController:login animated:YES completion:nil];
    }
}

-(void)suretoUseDiscount{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Info")  message:GDLocalizedString(@"Are you sure to use?") delegate:self cancelButtonTitle:GDLocalizedString(@"No") otherButtonTitles:GDLocalizedString(@"Yes"), nil];
    alter.tag = 0;
    alter.delegate = self;
    [alter show];
}

-(void)card{
    cardPost *cpost = [[cardPost alloc]init];
    [cpost PostCardInfo:@"http://app.enjoylist.com/usecard.asp" :[_dict objectForKey:@"id"]];
    if([cpost.result rangeOfString:@"success"].location != NSNotFound){
        activityBackGround.hidden = YES;
        activityLab.hidden = YES;
        [loadData stopAnimating];
        discountBtn.enabled = NO;
        discountBtn.alpha = 0.5;
        discountLab.text = GDLocalizedString(@"USED");
    }else{
        [self performSelectorOnMainThread:@selector(netAlter) withObject:nil waitUntilDone:NO];
    }
}

-(void)voucher{
    voucherPost *vpost = [[voucherPost alloc]init];
    [vpost PostVoucherInfo:@"http://app.enjoylist.com/usevoucher.asp" :[_dict objectForKey:@"id"] :[_dict objectForKey:@"voucherid"] ];
    if([vpost.result rangeOfString:@"success"].location != NSNotFound){
        activityBackGround.hidden = YES;
        activityLab.hidden = YES;
        [loadData stopAnimating];
        voucherBtn.enabled = NO;
        voucherBtn.alpha = 0.5;
        voucherLab.text = GDLocalizedString(@"USED");
    }else{
        [self performSelectorOnMainThread:@selector(netAlter) withObject:nil waitUntilDone:NO];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 0:
        {
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                [loadData startAnimating];
                NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(card) object:nil];
                [thread start];
            }
        }
            break;
        case 1:
        {
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                activityBackGround.hidden = NO;
                activityLab.hidden = NO;
                [loadData startAnimating];
                NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(voucher) object:nil];
                [thread start];
            }
        }
            break;
        default:
            break;
    }
}

-(void)toolBtnClicked:(UIButton *)btn{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    switch (btn.tag) {
        case 5:
        {
            NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
            if ([[userdefaults stringForKey:@"flag"]isEqualToString:@"0"]){
                NewLoginViewController *login = [[NewLoginViewController alloc]init];
                [self.navigationController presentViewController:login animated:YES completion:nil];
            }else{
                NSInteger Uid = [userdefaults integerForKey:@"userId"];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDirectory = [paths objectAtIndex:0];
                NSString *dbPath = [documentDirectory stringByAppendingPathComponent:@"MyDatabase.db"];
                FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
                if (![db open]) {
                }
                else if([db open]){
                    FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM FavoriteList WHERE UID = '%li' AND CID = '%li'",(long)Uid,(long)[_clientid integerValue]]];
                    if([s next]==YES){
                        UIAlertView *alter2 = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"You have already collect this client!") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
                        [alter2 show];
                        alter2.delegate = self;
                        [db close];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"favorite" object:nil];
                        NSThread *thread2 = [[NSThread alloc]initWithTarget:self selector:@selector(savefav:) object:db];
                        [thread2 start];
                    }
                }
            }
        }
            break;
        case 6:
        {
            if ([[userdefaults stringForKey:@"flag"]isEqualToString:@"0"]){
                NewLoginViewController *login = [[NewLoginViewController alloc]init];
                [self.navigationController presentViewController:login animated:YES completion:nil];
            }else{
                CommentViewController *commentViewController = [[CommentViewController alloc]init];
                commentViewController.clientid = _clientid;
                commentViewController.locationId = locationId;
                [self.navigationController pushViewController:commentViewController animated:YES];
            }
        }
            break;
        case 7:
        {
            MenuViewController *menuview = [[MenuViewController alloc]init];
            menuview.title = GDLocalizedString(@"MENU");
            menuview.dict = _dict;
            menuview.clientId = _clientid;
            [self.navigationController pushViewController:menuview animated:YES];
        }
            break;
        case 8:
        {
            MenuViewController *menuview = [[MenuViewController alloc]init];
            menuview.title = GDLocalizedString(@"EVENT");
            menuview.dict = _dict;
            menuview.clientId = _clientid;
            [self.navigationController pushViewController:menuview animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)savefav:(FMDatabase *)db{
    NSString *ICONX2 = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[_dict objectForKey:@"picx2"], NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    NSString *EXCERPT = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[_dict objectForKey:@"tag"], NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    NSString *NAME = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[_dict objectForKey:@"name"], NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
    float SCORE = [[_dict objectForKey:@"score"] floatValue];
    NSString *PRICE = [_dict objectForKey:@"price"] ;
    if(![PRICE isEqualToString:@""]){
        PRICE = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)[[_dict objectForKey:@"price"] substringFromIndex:1], NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));        }
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSInteger Uid = [userdefaults integerForKey:@"userId"];
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO FavoriteList (CID,UID,ICONX2,EXCERPT,NAME,SCORE,PRICE)VALUES ('%li','%li','%@','%@','%@','%f','%@')",(long)[_clientid integerValue],(long)Uid,ICONX2,EXCERPT,NAME,SCORE,PRICE];
    BOOL insert = [db executeUpdate:sql];
    if (insert){
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit")  message:GDLocalizedString(@"Success to collect") delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        alter.delegate = self;
        [alter show];
    }
    [db close];
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
            alert.delegate = self;
            [alert show];
        }
        //如果分享失败
        if (state == SSResponseStateFail) {
            NSString *info = [GDLocalizedString(@"Failed to publish") stringByAppendingString:[NSString stringWithFormat:@"%@",[error errorDescription]]];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:GDLocalizedString(@"Hit") message:info delegate:self cancelButtonTitle:GDLocalizedString(@"Ok") otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
        }
        if (state == SSResponseStateCancel){
        }
    }];
}

-(void)backtoListView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
